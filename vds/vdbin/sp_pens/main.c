#include "VDtypedefc.h"
#include "VDassert.h"
#include "VDxml.h"
#include "VDgeomc.h"

VDASSERT_FFN("main.c");

typedef struct 
{
  IGRchar   name [40];
  IGRchar   shape[40];
  IGRpoint  center;

  IGRdouble area;

  IGRdouble width;
  IGRdouble depth;

  IGRdouble radius;
  
  TGRbsp_curve *crv;
  
} Thole;

#define HOLE_MAX 200

typedef struct 
{
  IGRchar   type[40];
  IGRchar   text[40];
  IGRpoint  pt1,pt2;
  IGRdouble height;
  IGRdouble width;
} Tlabel;


typedef struct 
{
  IGRint initted;

  IGRchar name [64];
  IGRchar pcmk [64];
  IGRchar stage[64];
  
  IGRpoint pt1,pt2,pt3;

  IGRdouble expMajor,expMinor;

  TGRbsp_curve *outerCrv;
  IGRpoint ptMin,ptMax;
  
  Thole  holes[HOLE_MAX];
  IGRint holeCnt;

  Tlabel label;
  
} Tplate;

/* -------------------------------------------------
 * Grabs the next double from the buffer updating the pointer
 * when done
 */
static double parseDouble(IGRchar **buf)
{
  IGRdouble dbl = 0.0;
  
  IGRchar *p = *buf;
  
  // Strip white space
  while((*p) && (*p <= ' ')) p++;
  if (*p == 0) goto wrapup;

  // Convert it
  dbl = atof(p);
  
  // Move onto next one
  while(*p > ' ') p++;
  
 wrapup:
  *buf = p;
  return dbl;
}
/* -------------------------------------------------
 * Grabs the next integer from the buffer updating the pointer
 * when done
 */
static IGRint parseInteger(IGRchar **buf)
{
  IGRint integer = -1;
  
  IGRchar *p = *buf;
  
  // Strip white space
  while((*p) && (*p <= ' ')) p++;
  if (*p == 0) goto wrapup;

  // Only digits
  if ((*p < '0') || (*p > '9')) goto wrapup;
  
  // Convert it
  integer = atoi(p);
  
  // Move onto next one
  while(*p > ' ') p++;
  
 wrapup:
  *buf = p;
  return integer;
}

/* -------------------------------------------------
 * Parses the three reference points
 */
static void parseRefPts(Tplate *plate, IGRchar *buf)
{
  IGRchar *p = buf;
  
  plate->pt1[0] = parseDouble(&p);
  plate->pt1[1] = parseDouble(&p);
  plate->pt1[2] = parseDouble(&p);

  plate->pt2[0] = parseDouble(&p);
  plate->pt2[1] = parseDouble(&p);
  plate->pt2[2] = parseDouble(&p);

  plate->pt3[0] = parseDouble(&p);
  plate->pt3[1] = parseDouble(&p);
  plate->pt3[2] = parseDouble(&p);

  return;
  
}

/* -------------------------------------------------
 * Validates a proposed segment from the line arc routine
 * basically, a line segment needs to be at least 1mm in length
 *
 * Right now ignore these segments though that leaves a gap but the 
 * merge takes care of any internal gaps and the overall process
 * should take care of any end gaps
 */
static IGRstat parseLineArcValidateSegment(Tplate *plate, IGRpoint pt1, IGRpoint pt2) 
{
  VDASSERT_FN("parseLineArcValidateSegment");
  IGRstat retFlag = 0;
  
  IGRdouble dis;

  // Validate distance
  VDgeom2GetDisPtPt(pt1,pt2,&dis);
  if (dis < 1.0) {
    // printf("*** PC %s, segment length is %.2f\n",plate->pcmk,dis);
    goto wrapup;
  }
  
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

/* -------------------------------------------------
 * parse a line arc buffer, retuning a bsp curve
 */
static IGRstat parseLineArc(Tplate *plate, IGRchar *buf, TGRbsp_curve **crv_result)
{
  VDASSERT_FN("parseLineArc");
  
  IGRstat retFlag = 0;
  IGRstat sts;
  
  IGRint type;
  IGRchar *p = buf;
  
  IGRpoint pt1,pt2,pt3;

  IGRchar       crv_buf[VDGEOM_SIZE_BUF];
  TGRbsp_curve *crv_segment;
  TGRbsp_curve *crv_merged;
  
  IGRint segFlag;
  
  IGRint i;

  // Say hi
  if (traceFlag) printf(">>> %s\n",fn);
  
  // Start with nothing
  *crv_result = NULL;
  pt1[2] = pt2[2] = pt3[2] = 0.0;
  crv_segment = (TGRbsp_curve*)crv_buf;
  
  // First type should always be zero
  type = parseInteger(&p);
  VDASSERTW(type == 0);
  pt1[0] = parseDouble(&p);
  pt1[1] = parseDouble(&p);

  // Loop on each segment
  while(1) {

    // Get the next type
    type = parseInteger(&p);
    if (type == -1) {
      retFlag = 1;
      goto wrapup;
    }
    pt2[0] = parseDouble(&p);
    pt2[1] = parseDouble(&p);
    segFlag = 0;
    
    // Is it a line segment or arc
    switch(type) {

      case 0:
	// Line segment
	sts = parseLineArcValidateSegment(plate,pt1,pt2);
	if (sts == 1) {  
	  VDgeom2MakeLineCurve(pt1,pt2,&crv_segment);
	  VDASSERTW(crv_segment);
	  segFlag = 1;
	}
	break;
	
      case 1:
	// Arc segment
	type = parseInteger(&p);
	VDASSERTW(type == 0);
	pt3[0] = parseDouble(&p);
	pt3[1] = parseDouble(&p);

	// Validation
	sts = parseLineArcValidateSegment(plate,pt1,pt3);
	if (sts == 1) {
	  sts = parseLineArcValidateSegment(plate,pt1,pt2);
	  if (sts == 1) sts = parseLineArcValidateSegment(plate,pt2,pt3);
	  if (sts == 1) VDgeom2MakeArcCurve (pt1,pt2,pt3,&crv_segment);
	  else          VDgeom2MakeLineCurve(pt1,pt3,    &crv_segment);
	  VDASSERTW(crv_segment);
	  segFlag = 1;
	  for(i = 0; i < 3; i++) pt2[i] = pt3[i];
	}
	
	break;
	
      default:
	VDASSERTW(0);
    }

    // Possible no segment was made
    if (segFlag) {
      
      // Either the first or append it
      if (*crv_result == NULL) {
	VDgeom2CopyCurve(crv_segment,crv_result);
	VDASSERTW(*crv_result);
      }
      else {
	VDgeom2MergeTwoCurves(*crv_result,crv_segment,&crv_merged);
	if (crv_merged == NULL) printf("Merged curve failed\n%s\n",p);
	VDASSERTW(crv_merged);
	free(*crv_result);
	*crv_result = crv_merged;
      }
    }
    
    // Next segment
    for(i = 0; i < 3; i++) pt1[i] = pt2[i];
  }
  
 wrapup:
  return retFlag;
}

/* -------------------------------------------------
 * Parse a hole circle
 */
static IGRstat parseHoleCircle(Tplate *plate, IGRchar *buf)
{
  IGRstat retFlag = 0;
  
  IGRchar *p;
  
  IGRdouble radius;
  
  Thole *hole;
  
  // Only circles
  p = strstr(buf,"CIRCLE ");
  if (p == NULL) goto wrapup;

  // Processed no matter what
  retFlag = 1;
  p += strlen("CIRCLE ");
  
  // Make sure have room
  if (plate->holeCnt >= HOLE_MAX) {
    printf("*** Too many holes PC %4s, %d\n",plate->pcmk,HOLE_MAX);
    goto wrapup;
  }
  
  // Xfer it
  hole = &plate->holes[plate->holeCnt];
  plate->holeCnt++;
  
  strcpy(hole->shape,"RD");
  
  hole->center[0] = parseDouble(&p);
  hole->center[1] = parseDouble(&p);
  
  // Get the area
  hole->depth =  parseDouble(&p);
  radius = hole->depth * .5;
  hole->area = 3.14159 * radius * radius;
    
 wrapup:
  return retFlag;
}
/* -------------------------------------------------
 * Parse a hole oval (actually a flat oval)
 */
static IGRstat parseHoleOval(Tplate *plate, IGRchar *buf)
{
  IGRstat retFlag = 0;
  
  IGRchar *p;
  
  IGRdouble radius;
  
  Thole *hole;
  
  IGRpoint majorPt,minorPt;
  
  // Only ovals
  p = strstr(buf,"OVAL ");
  if (p == NULL) goto wrapup;

  // Processed no matter what
  retFlag = 1;
  p += strlen("OVAL ");
  
  // Make sure have room
  if (plate->holeCnt >= HOLE_MAX) {
    printf("*** Too many holes PC %4s, %d\n",plate->pcmk,HOLE_MAX);
    goto wrapup;
  }
  
  // Xfer it
  hole = &plate->holes[plate->holeCnt];
  plate->holeCnt++;
  
  strcpy(hole->shape,"FO");
  
  hole->center[0] = parseDouble(&p);
  hole->center[1] = parseDouble(&p);
  
  majorPt[0] = parseDouble(&p);
  majorPt[1] = parseDouble(&p);
  majorPt[2] = 0.0;
  minorPt[0] = parseDouble(&p);
  minorPt[1] = parseDouble(&p);
  minorPt[2] = 0.0;

  // Depth and width
  VDgeom2GetDisPtPt(hole->center,majorPt,&hole->width);
  VDgeom2GetDisPtPt(hole->center,minorPt,&hole->depth);

  hole->width *= 2.0;
  hole->depth *= 2.0;
    
 wrapup:
  return retFlag;
}

/* -------------------------------------------------
 * Parse a hole ellipse
 */
static IGRstat parseHoleEllipse(Tplate *plate, IGRchar *buf)
{
  IGRstat retFlag = 0;
  
  IGRchar *p;
  
  IGRdouble radius;
  
  Thole *hole;
  
  IGRpoint majorPt,minorPt;
  
  // Only ovals
  p = strstr(buf,"ELLIPSE ");
  if (p == NULL) goto wrapup;

  // Processed no matter what
  retFlag = 1;
  p += strlen("ELLIPSE ");
  
  // Make sure have room
  if (plate->holeCnt >= HOLE_MAX) {
    printf("*** Too many holes PC %4s, %d\n",plate->pcmk,HOLE_MAX);
    goto wrapup;
  }
  
  // Xfer it
  hole = &plate->holes[plate->holeCnt];
  plate->holeCnt++;
  
  strcpy(hole->shape,"EL");
  
  hole->center[0] = parseDouble(&p);
  hole->center[1] = parseDouble(&p);
  
  majorPt[0] = parseDouble(&p);
  majorPt[1] = parseDouble(&p);
  majorPt[2] = 0.0;
  minorPt[0] = parseDouble(&p);
  minorPt[1] = parseDouble(&p);
  minorPt[2] = 0.0;

  // Depth and width
  VDgeom2GetDisPtPt(hole->center,majorPt,&hole->width);
  VDgeom2GetDisPtPt(hole->center,minorPt,&hole->depth);

  hole->width *= 2.0;
  hole->depth *= 2.0;
    
 wrapup:
  return retFlag;
}

/* -------------------------------------------------
 * Parse a hole attribute object
 */
static void parseHoleCurve(Tplate *plate, IGRchar *buf)
{
  IGRstat sts;
  
  IGRchar *p;
  
  IGRdouble radius;
  
  Thole *hole;

  TGRbsp_curve *crv = NULL;
  
  // Is it a circle
  sts = parseHoleCircle(plate,buf);
  if (sts & 1) goto wrapup;
  
  // Is it an oval
  sts = parseHoleOval(plate,buf);
  if (sts & 1) goto wrapup;

  // Is it an ellipse
  sts = parseHoleEllipse(plate,buf);
  if (sts & 1) goto wrapup;

  // Try for line arc
  sts = parseLineArc(plate,buf,&crv);
  if (sts == 0) {
    printf("*** PC %s, Problem reading hole curve\n",plate->pcmk);
  }
  if (crv == NULL) goto wrapup;
  
  // Make sure have room
  if (plate->holeCnt >= HOLE_MAX) {
    printf("*** Too many holes PC %4s, %d\n",plate->pcmk,HOLE_MAX);
    goto wrapup;
  }
  
  // Xfer it
  hole = &plate->holes[plate->holeCnt];
  plate->holeCnt++;

  strcpy(hole->shape,"XX");
  
  VDgeom2GetCurveCenter(crv, hole->center);
  VDgeom2GetCurveArea  (crv,&hole->area);
  
  
  // Done

 wrapup:
  if (crv) free(crv);
  return;
}

/* -------------------------------------------------
 * Parse a label attribute
 */
static void parseLabelAtr(Tlabel *label, IGRchar *atrName, IGRchar *atrValue)
{
  IGRchar *p;
  
  if (!strcmp(atrName,"PDF_ATR_LABEL_TYPE")) {
    strcpy(label->type,atrValue);
    goto wrapup;
  }
  if (!strcmp(atrName,"PDF_ATR_LABEL_TEXT")) {
    strcpy(label->text,atrValue);
    goto wrapup;
  }
  if (!strcmp(atrName,"PDF_ATR_LABEL_LOCATION")) {
    p = atrValue;
    label->pt1[0] = parseDouble(&p);
    label->pt1[1] = parseDouble(&p);
    label->pt2[0] = parseDouble(&p);
    label->pt2[1] = parseDouble(&p);
    goto wrapup;
  }
  if (!strcmp(atrName,"PDF_ATR_LABEL_HEIGHT_WIDTH")) {
    p = atrValue;
    label->height = parseDouble(&p);
    label->width  = parseDouble(&p);
    goto wrapup;
  }
  
 wrapup:
  return;
}

/* -------------------------------------------------
 * Process the label
 * Called when the label structure is filled
 */
static void processLabel(Tplate *plate, Tlabel *label)
{
  VDASSERT_FN("processLabel");
  
  IGRchar *p;

  IGRpoint  pt;
  IGRdouble dis,disClosest;
  
  IGRint i,nthClosest;

  Thole *hole;

  // Only labels starting with PEN are processed
  p = strstr(label->text,"PEN-");
  if (p != label->text) goto wrapup;

  // Find the center
  pt[0] = (label->pt1[0] + label->pt2[0]) * .5;
  pt[1] = (label->pt1[1] + label->pt2[1]) * .5;
  pt[2] = 0.0;
  
  pt[1] += (label->height * .5);

  // Find closest point
  disClosest =  1000.0 * 1000.0;
  nthClosest = -1;

  for(i = 0; i < plate->holeCnt; i++) {
    hole = &plate->holes[i];
    
    VDgeom2GetDisPtPt(pt,hole->center,&dis);
    if (dis < disClosest) {
      disClosest = dis;
      nthClosest = i;
    }
  }
  if (disClosest >= 5.0) {

    // Probably on the outer contour
    VDgeom2GetDisPtCv(pt,plate->outerCrv,&dis);

    // Just to be safe, make sure it's closest to the outer contour
    if (dis > disClosest) {      
      printf("*** PC %s, Distance from label to nearest hole %d %s is %.2f, To outer contour %.2f\n",
	     plate->pcmk,nthClosest,label->text,disClosest,dis);
      goto wrapup;
    }
    
    // Need to basically treat this as a new hole
    if (plate->holeCnt >= HOLE_MAX) {
      printf("*** Too many holes PC %4s, %d\n",plate->pcmk,HOLE_MAX);
      goto wrapup;
    }
    hole = &plate->holes[plate->holeCnt];
    plate->holeCnt++;

    strcpy(hole->name,label->text);
    strcpy(hole->shape,"OC");
    for(i = 0; i < 3; i++) hole->center[i] = pt[0];
    hole->depth = dis;
    goto wrapup;
  }
  
  hole = &plate->holes[nthClosest];

#if 0
  printf("Piece %4s, Label %s, Index %d, Distance %.2f\n",
	 plate->pcmk,label->text,nthClosest,disClosest);
  printf("Label center %.2f %.2f\n",pt[0],pt[1]);
  printf("Hole  center %.2f %.2f\n",hole->center[0],hole->center[1]);
#endif

  /* ---------------------------------------------
   * Make sure not already claimed
   */
  if (*hole->name) {
    printf("*** PC %s, Duplicate Label %s %s\n",
	   plate->pcmk,hole->name,label->text);
    goto wrapup;
  }  
  strcpy(hole->name,label->text);
  
 wrapup:
  return;
}

/* -------------------------------------------------
 * Process one hole on the plate
 */
static void processPlateHole(Tplate *plate, Thole *hole, FILE *file)
{
  IGRpoint pt1,pt2,pt3;
  IGRint i;

  TVDgeomMat3x3 mat;

  IGRpoint center2d;
  IGRpoint center3d;
  
  IGRint expFlag = 0;
  
  // Filter
  if (*hole->name == 0) goto wrapup;
  
  // The origin reference points
  for(i = 0; i < 3; i++) {
    pt1[i] = pt2[i] = pt3[i] = 0.0;
  }
  pt2[0] += 1000.0;
  pt3[1] += 2000.0;

  // Calc the transformation matrix
  VDgeom2GetTranForPts(plate->pt1,plate->pt2,plate->pt3,
		       pt1,pt2,pt3,
		       mat);

  // printf("mat %.2f %.2f %.2f\n",mat[0][0],mat[0][1],mat[0][2]);
  // printf("    %.2f %.2f %.2f\n",mat[1][0],mat[1][1],mat[1][2]);
  // printf("    %.2f %.2f %.2f\n",mat[2][0],mat[2][1],mat[2][2]);
  
  // Get the holes 2d center
  for(i = 0; i < 3; i++) center2d[i] = hole->center[i];
  
  // Unexpand the major (left to right)
  center2d[0] = plate->ptMin[0] + ((center2d[0] - plate->ptMin[0]) / plate->expMajor);

  // Unexpand the minor (top to bottom)
  center2d[1] = plate->ptMax[1] + ((center2d[1] - plate->ptMax[1]) / plate->expMinor);
  
  // Transform center to 3d space
  VDgeom2TransformPt(pt1,plate->pt1,mat,center2d,center3d);
  
  // Have any expansion
  if (plate->expMajor > 1.000001) expFlag = 1;
  if (plate->expMinor > 1.000001) expFlag = 1;
  
  // Report it
#if 0
  fprintf(file,"Piece %4s, Label %s, Area %8.2f, Center %10.2f %10.2f %10.2f\n",
	  plate->pcmk,hole->name,hole->area,
	  center3d[0],center3d[1],center3d[2]);
#endif
  fprintf(file,"%d|%s|%s|%s|%.2f|%.2f|%.2f|%.2f|%.2f|%.2f|%.2f|\n",
	  expFlag,
	  plate->pcmk,
	  hole->name+4,
	  hole->shape,

	  hole->depth,
	  hole->width,
	  hole->radius,
	  hole->area,

	  center3d[0],center3d[1],center3d[2]);

 wrapup:
  return;
}

/* -------------------------------------------------
 * Process the plate
 * Basically list the penetration holes
 */
static void processPlate(Tplate *plate)
{
  VDASSERT_FN("processPlate");
  
  FILE *file = stdout;
  
  Thole *hole;

  IGRint i;
  
  // Should have a contour
  VDASSERTW(plate->outerCrv);
  VDgeom2GetCurveRange(plate->outerCrv,plate->ptMin,plate->ptMax);
  
  // Cycle through holes
  for(i = 0; i < plate->holeCnt; i++ ) {

    hole = &plate->holes[i];

    processPlateHole(plate,hole,file);

    // Free up any curve
    if (hole->crv) free(hole->crv);
    
  }
  
  // Done
 wrapup:
  return;
}

/* -------------------------------------------------
 * Parse a plate edge curve, merging them all
 * together to get a single curve
 */
static void parsePlateEdgeCurve(Tplate *plate, TGRbsp_curve **crv_result, IGRchar *buf)
{
  VDASSERT_FN("parsePlateEdgeCurve");
  IGRstat sts;
  
  TGRbsp_curve *crv = NULL;
  TGRbsp_curve *crv_merge;
  
  // Get the curve
  sts = parseLineArc(plate,buf,&crv);
  if (sts == 0) {
    printf("*** PC %s, problem getting plate edge curve\n",plate->pcmk);
    goto wrapup;
  }
  VDASSERTW(crv);
  
  // See if its first
  if (*crv_result == NULL) {
    *crv_result = crv;
    crv = NULL;
    goto wrapup;
  }
  
  // Else merge
  VDgeom2MergeTwoCurves(*crv_result,crv,&crv_merge);
  free(crv); crv = NULL;
  VDASSERTW(crv_merge);
  
  // Xfer
  free(*crv_result);
  *crv_result = crv_merge;
  
 wrapup:
  if (crv) free(crv);
}
  
/* -------------------------------------------------
 * Call back for filling in pcmk infos
 */
static IGRstat genPenReportCallback(TVDxml2ParseInfo *parseInfo)
{
  VDASSERT_FN("genPenReportCallback");
  
  IGRstat retFlag = 1;

  Tplate *plate = (Tplate*)parseInfo->data;

  TVDxml2EleInfo *eleInfo = &parseInfo->eleInfo;

  // Say Hi
  if (traceFlag) printf(">>> %s\n",fn);
  
  switch(eleInfo->type) {

    case VDXML_TYPE_BEG_ELEMENT:
      
      // Have another plate
      if (!strcmp("PDF_OBJ_PLATE",eleInfo->eleType)) {
	memset(plate,0,sizeof(Tplate));
	plate->initted = 1;
	plate->expMajor = 1.0;
	plate->expMinor = 1.0;	
	goto wrapup;
      }

      // Reset the label
      if (!strcmp("PDF_OBJ_LABEL",eleInfo->eleType)) {
	memset(&plate->label,0,sizeof(Tlabel));
      }
            
      break;

    case VDXML_TYPE_END_ELEMENT:

      // Done with plate
      if (!strcmp("PDF_OBJ_PLATE",eleInfo->eleType)) {
	VDASSERTW(plate->initted);
#if 0
	if (plate->holeCnt) {  
	  printf("PLATE %4s, Hole Count %2d %.2f\n",plate->pcmk,plate->holeCnt,plate->holes[0].diam);
	}
#endif
	processPlate(plate);
	if (plate->outerCrv) {
	  free(plate->outerCrv);
	  plate->outerCrv = NULL;
	}
	goto wrapup;
      }

      // Done with label
      if (!strcmp("PDF_OBJ_LABEL",eleInfo->eleType)) {
	processLabel(plate,&plate->label);	
	goto wrapup;
      }
      
      break;
      
    case VDXML_TYPE_ATTRIBUTE:

      // For plates
      if (!strcmp("PDF_OBJ_PLATE",eleInfo->eleType)) {
	
	if (!strcmp("PDF_ATR_TREE_NODE_NAME",eleInfo->atrType)) {
	  strcpy(plate->name,eleInfo->atrValue);
	  goto wrapup;
	}
	if (!strcmp("PDF_ATR_TREE_NODE_PCMK",eleInfo->atrType)) {
	  strcpy(plate->pcmk,eleInfo->atrValue);
	  goto wrapup;
	}
	if (!strcmp("PDF_ATR_TREE_NODE_PARENT",eleInfo->atrType)) {
	  strcpy(plate->stage,eleInfo->atrValue);
	  goto wrapup;
	}

	if (!strcmp("PDF_ATR_PIECE_3D_REF_PTS",eleInfo->atrType)) {
	  parseRefPts(plate,eleInfo->atrValue);
	  goto wrapup;
	}

	if (!strcmp("PDF_ATR_PLATE_EXPAND_MAJOR",eleInfo->atrType)) {
	  plate->expMajor = atof(eleInfo->atrValue);
	  goto wrapup;
	}
	if (!strcmp("PDF_ATR_PLATE_EXPAND_MINOR",eleInfo->atrType)) {
	  plate->expMinor = atof(eleInfo->atrValue);
	  goto wrapup;
	}

      }

      // Plate edge (always outer edges???), what about internal bevels???
      if (!strcmp("PDF_OBJ_PLATE_EDGE",eleInfo->eleType)) {

	// The outer contour
	if (!strcmp("PDF_ATR_PLATE_EDGE_CURVE",eleInfo->atrType)) {
	  parsePlateEdgeCurve(plate,&plate->outerCrv,eleInfo->atrValue);
	  goto wrapup;
	}
      }
      
      // For holes
      if (!strcmp("PDF_OBJ_HOLE",eleInfo->eleType)) {

	if (!strcmp("PDF_ATR_HOLE_CURVE",eleInfo->atrType)) {
	  parseHoleCurve(plate,eleInfo->atrValue);
	}
      }

      // For Labels
      if (!strcmp("PDF_OBJ_LABEL",eleInfo->eleType)) {
	parseLabelAtr(&plate->label,eleInfo->atrType,eleInfo->atrValue);	
      }

      break;
      
  }

  // Done
  retFlag = 1;
  
 wrapup:

  if (retFlag == 0) parseInfo->retFlag = 1;

  // Say Bi
  if (traceFlag) printf("<<< %s\n",fn,retFlag);
  return retFlag;
}

/* -----------------------------------------------
 * Generate a spades penetration report
 */
void VDpdfGeneratePenetrationReportFromXmlFile(IGRchar *xmlFileName)
{
  VDASSERT_FN("VDpdfGeneratePenetrationReportFromXmlFile");

  TVDxml2ParseInfo parseInfo;
  
  Tplate plate;
  
  // Arg check
  VDASSERTW(xmlFileName && *xmlFileName);

  // The parser does most of the work
  VDxml2ParseFile(&parseInfo,xmlFileName,genPenReportCallback,&plate);

 wrapup:
  return;
}

/* -----------------------------------------------
 * Main traffic director
 */
main(IGRint argc, IGRchar *argv[])
{

  IGRint i;
  
  // Init system
  VDgblInitStaticData(0);
  
  // Say Hi
  printf("EXP|PCMK|HOLE#|SHAPE|DEPTH/DIAM|WIDTH|RADIUS|AREA|X|Y|Z|\n");
  
  // Cycle through
  if (argc == 1) VDpdfGeneratePenetrationReportFromXmlFile("spades.xml");
  else {
    for(i = 1; i < argc; i++) {
      // Make the report
      VDpdfGeneratePenetrationReportFromXmlFile(argv[i]);
    }
  }
  
  // Done
 wrapup:
  return 0;
  
}
