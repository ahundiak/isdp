/* $Id: VDvalSpades.c,v 1.10 2001/11/16 14:58:45 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdval/x2/VDvalSpades.c
 *
 * Description:	Spades macro routines
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDvalSpades.c,v $
 *      Revision 1.10  2001/11/16 14:58:45  ahundiak
 *      ah
 *
 *      Revision 1.9  2001/08/24 20:00:49  ahundiak
 *      ah
 *
 *      Revision 1.8  2001/08/14 19:07:27  ahundiak
 *      ah
 *
 *      Revision 1.7  2001/08/02 15:32:46  ahundiak
 *      ah
 *
 *      Revision 1.6  2001/07/03 20:13:19  ahundiak
 *      ah
 *
 *      Revision 1.5  2001/06/27 14:43:24  ahundiak
 *      ah
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 05/14/01  ah      Creation
 ***************************************************************************/

#include "VDtypedefc.h"
#include "VDassert.h"
#include "VDlog.h"
#include "VDbuf.h"
#include "VDtest.h"
#include "VDgeomc.h"
#include "VDxdom.h"
#include "VDctx.h"
#include "VDval.h"
#include "VDvalSpades.h"
#include "stdarg.h"

VDASSERT_FFN("VDvalSpades.c");

/* -----------------------------------------------
 * Debugging points and curves
 */
static void drawPoint(IGRpoint pt)
{
  TGRsymbology symb1;
  TGRsymbology symb2;
  
  TGRid ptID;

  // Ignore for stand alone programs
  if (!VDahIsIsdpRunning()) goto wrapup;
  
  VDahGetActiveSymbology(&symb1);
  VDahGetActiveSymbology(&symb2);
  symb2.level = 498;
  symb2.display_attr.color  = 2;
  symb2.display_attr.weight = 5;  
  VDahSetActiveSymbology(&symb2);
  
  VDdrawLinear(1,pt,NULL,&ptID);
  
  VDahSetActiveSymbology(&symb1);

 wrapup:
  return;
}

static void drawCurve(TVDvalSpadesInfo *info, TGRbsp_curve *crv)
{
  VDASSERT_FN("drawCurve");
  
  TGRsymbology symb1;
  TGRsymbology symb2;
  
  TGRid crvID;

  IGRdouble    *matrix = NULL;
  TGRbsp_curve *crvx = NULL;

  // Ignore for stand alone programs
  if (!VDahIsIsdpRunning()) goto wrapup;
  
  // 2d Symbology
  VDahGetActiveSymbology(&symb1);
  VDahGetActiveSymbology(&symb2);
  symb2.level = 492;
  symb2.display_attr.color  = 5;
  symb2.display_attr.weight = 0; 
  symb2.display_attr.style = 0; 
  VDahSetActiveSymbology(&symb2);
  
  VDdrawCurve(crv,NULL,&crvID);
  if (crvID.objid == NULL_OBJID) {
    VDvalLogError("Unable to create 2d geometry");
    goto wrapup;
  }
  if (info->macroFlag) VDbufAddGeometryChild(&info->drwGm2dID,&crvID);

  // 3d Symbology
  symb2.level = 491;
  symb2.display_attr.color  = 3;
  symb2.display_attr.weight = 0;  
  symb2.display_attr.style  = 0; 
  VDahSetActiveSymbology(&symb2);

  // Transform to 3d space and draw
  VDctxGetBinAtr(&info->plateID,"matrix",(void*)&matrix);
  if (matrix == NULL) goto wrapup;
  
  // Transform the contour
  VDgeom2CopyCurve(crv,&crvx);
  VDASSERTW(crvx);
  
  VDgeom2MatrixCurve(crvx,matrix);

  VDdrawCurve(crvx,NULL,&crvID);
  if (crvID.objid == NULL_OBJID) {
    VDvalLogError("Unable to create 3d geometry");
    goto wrapup;
  }
  if (info->macroFlag) VDbufAddGeometryChild(&info->drwGm3dID,&crvID);

 wrapup:
  if (VDahIsIsdpRunning()) {    
    VDahSetActiveSymbology(&symb1);
    if (crvx) free(crvx);
  }
  
  return;
}

/* -----------------------------------------------
 * Bounce two holes against each other
 */
static void validatePlateHolesPair(TGRid *hole1ID, TGRid *hole2ID)
{
  VDASSERT_FN("validatePlateHolesPair");
  
  TGRbsp_curve *crv1,*crv2;
  IGRpoint      center1,center2;
  IGRdouble     dis;
  
  IGRdouble tol;
  
  // Get the geometry
  VDctxGetBinAtr(hole1ID,"PDF_ATR_HOLE_CURVE",(void*)&crv1);
  if (crv1 == NULL) goto wrapup;
  VDctxGetBinAtr(hole2ID,"PDF_ATR_HOLE_CURVE",(void*)&crv2);
  if (crv2 == NULL) goto wrapup;
  
  // Start with centers
  VDgeom2GetCurveCenter(crv1,center1);
  VDgeom2GetCurveCenter(crv2,center2);
  
  VDgeom2GetDisPtPt(center1,center2,&dis);
  VDvalGetTolerance(VDTOL_MIN_DIS_HOLE_CENTERS,&tol);
  if (dis < tol) {
    VDvalLogError("Two holes with the same center at %.2f,%.2f,%.2f",
		  center1[0],center1[1],center1[2]);
    drawPoint(center1);    
    goto wrapup;
  }

  // See if the curves themselves are too close together
  VDgeom2GetDisCvCv(crv1,crv2,&dis);
  VDvalGetTolerance(VDTOL_MIN_DIS_HOLE_HOLE,&tol);
  if (dis < tol) {
    VDvalLogError("Distance between holes of %.2f at center %.2f,%.2f,%.2f",
		  dis,center1[0],center1[1],center1[2]);
    drawPoint(center1);    
    goto wrapup;
  }
  
 wrapup:
  return;
}

/* -----------------------------------------------
 * At this point in the process, the outer contour
 * and all of the internal cutouts have been parsed
 * and geometry generated
 *
 * now need to validate the geometry by looking for things like
 * overlapping holes, diplicate holes and other such nonsense
 */
static void validatePlateHoles(TGRid *plateID, void *data, IGRint *stopWalk)
{
  VDASSERT_FN("validatePlateHoles");
  
  TVDctxNodeList holes;

  IGRint i,j;
  
  // Init
  VDctxInitNodeList(&holes);
  
  // Grab the holes
  VDctxGetNodeListByType(plateID,"PDF_OBJ_HOLE",&holes);
  
  // Compare by pairs
  for(i = 0; i < holes.cnt; i++) {
    for(j = i + 1; j < holes.cnt; j++) {
      validatePlateHolesPair(&holes.listIDs[i],&holes.listIDs[j]);
    }
  }
  
  // Done
 wrapup:
  VDctxFreeNodeList(&holes);
}

/* -----------------------------------------------
 * Process one plate hole (inner cutout)
 */
void VDvalSpadesPlateHole(TGRid *holeID, void *data, IGRint *stopWalk)
{
  VDASSERT_FN("VDvalSpadesPlateHole");

  IGRstat sts;
  
  TVDvalSpadesInfo *info = data;
  
  IGRchar *txt;
  
  TGRbsp_curve *crv   = NULL;
  TGRbsp_curve *outer = NULL;
  
  IGRpoint  pt1,pt2;
  IGRdouble dis;

  IGRdouble area,areax;
  IGRpoint  center;
  
  IGRdouble tol;

  IGRdouble *range;
  IGRdouble z = 0.0;
  
  // Only want holes
  if (!VDctxIsNodeType(holeID,"PDF_OBJ_HOLE")) goto wrapup;
  traceFlagx = 0;
  if (traceFlagx) printf(">>> %s\n",fn);
  
  // Need to be careful about long attributes
  VDctxGetTxtAtrPtr(holeID,"PDF_ATR_HOLE_CURVE",&txt);
  if (traceFlagx) printf(">>> Got the hole curve attribute\n");

  // Need the z depth
  VDctxGetBinAtr(&info->plateID,"range",(void*)&range);
  if (range) z = range[2];
  if (traceFlagx) printf(">>> Got the z depth\n");

  // Get the geometry
  sts = VDvalParseGenericCurve(txt,z,&crv,NULL);
  if ((sts == 0) || (crv == NULL)) {
    VDvalLogError("Problem getting hole geometry");
    goto wrapup;
  }
  if (traceFlagx) printf(">>> Got the hole curve geometry\n");
  VDctxSetBinAtr(holeID,"PDF_ATR_HOLE_CURVE",crv,NULL);
  if (traceFlagx) printf(">>> Set the hole curve geometry\n");

  // For debugging
  drawCurve(info,crv);
  
  // Check the area
  VDgeom2GetCurveCenter(crv,center);
  VDgeom2GetCurveArea  (crv,&area);
  VDvalGetTolerance(VDTOL_MIN_AREA_HOLE,&tol);
  if (area < tol) {
    VDvalLogError("Area of hole is %.2f sqmm at %.2f,%.2f,%.2f",
		  area,center[0],center[1],center[2]);
    drawPoint(center);    
  }
  VDctxGetDblAtr(&info->plateID,"outer_area",&areax);
  VDvalGetTolerance(VDTOL_PLATE_HOLE_AREA_FACTOR,&tol);
  if ((tol*area) >= areax) {
    VDvalLogError("Area of hole          is %.2f sqmm at %.2f,%.2f,%.2f",
		  area,center[0],center[1],center[2]);
    VDvalLogError("Area of outer contour is %.2f sqmm",areax);
    VDvalLogError("Hole is big compared to the entire plate area");
    drawPoint(center);    
  }

  // Check for being closed
  VDgeom2GetCrvEndPts(crv,pt1,pt2);
  VDgeom2GetDisPtPt(pt1,pt2,&dis);
  VDvalGetTolerance(VDTOL_CONTOUR_GAP,&tol);
  if (dis > tol) {
    VDvalLogError("Gap in hole contour of %.2f at %.2f,%.2f,%.2f",
		  dis,pt1[0],pt1[1],pt1[2]);
    drawPoint(pt1);    
  }

  // Make sure it respects the outer contour
  VDctxGetBinAtr(&info->plateID,"outer_contour",(void*)&outer);
  if (outer == NULL) goto wrapup;

  VDgeom2GetDisCvCv(crv,outer,&dis);
  VDvalGetTolerance(VDTOL_MIN_DIS_HOLE_CONTOUR,&tol);
  if (dis < tol) {
    VDvalLogError("Hole is close (%.2fmm) to outer contour, center at %.2f,%.2f,%.2f",
		  dis,center[0],center[1],center[2]);
    drawPoint(center);    
  }
  if (traceFlagx) printf("<<< %s\n",fn);
  
 wrapup:
  return;
}

/* -----------------------------------------------
 * Process one plate edge
 */
static void processPlateEdge(TGRid *edgeID, void *data, IGRint *stopWalk)
{
  VDASSERT_FN("processPlateEdge");

  IGRstat sts;
  
  TGRid *plateID = data;
  TGRid  crvID;
  
  IGRchab nodeType;
  IGRchar *txt;

  TGRbsp_curve *crv_edge   = NULL;
  TGRbsp_curve *crv_outer  = NULL;
  TGRbsp_curve *crv_merged = NULL;
  
  IGRpoint pt1,pt2;
  IGRdouble dis;
  
  IGRdouble tol;
  IGRdouble z;
  IGRdouble *range;
  
  // Only want plate edges
  VDctxGetNodeType(edgeID,nodeType);
  if (strcmp(nodeType,"PDF_OBJ_PLATE_EDGE")) goto wrapup;

  // Need to be careful about long attributes
  VDctxGetTxtAtrPtr(edgeID,"PDF_ATR_PLATE_EDGE_CURVE",&txt);

  // Need the z depth
  VDctxGetBinAtr(plateID,"range",(void*)&range);
  if (range) z = range[2];
  else       z = 0.0;

  // Get the geometry
  sts = VDvalParseLineArc(txt,z,&crv_edge);
  if (sts == 0) {
    VDvalLogError("Problem processing plate edge curve");
  }
  VDASSERTW(crv_edge);
  VDctxSetBinAtr(edgeID,"PDF_ATR_PLATE_EDGE_CURVE",crv_edge,NULL);
  
  // Add this curve to form a composite outer contour
  VDctxGetBinAtr(plateID,"outer_contour",(void*)&crv_outer);
  if (crv_outer == NULL) {
    VDgeom2CopyCurve(crv_edge,&crv_outer);
    VDctxAppBinAtr(plateID,"outer_contour",crv_outer,NULL);
    goto wrapup;
  }
    
  // The edge itself should not be closed
  VDgeom2GetCrvEndPts(crv_edge,pt1,pt2);
  VDgeom2GetDisPtPt(pt1,pt2,&dis);
  VDvalGetTolerance(VDTOL_EDGE_NOT_CLOSED,&tol);
  if (dis < tol) {
    VDvalLogError("Closed outer contour segment at %.2f,%.2f,%.2f",
	     pt1[0],pt1[1],pt1[2]);
    drawPoint(pt1);
  }

  // Check for gaps
  VDgeom2GetCrvPt(crv_outer,1.0,pt1);
  VDgeom2GetCrvPt(crv_edge, 0.0,pt2);
  VDgeom2GetDisPtPt(pt1,pt2,&dis);
  VDvalGetTolerance(VDTOL_CONTOUR_GAP,&tol);
  if (dis > tol) {
    VDvalLogError("Gap between two outer contour segments of %.2f at %.2f,%.2f,%.2f",
	     dis,pt1[0],pt1[1],pt1[2]);
    drawPoint(pt1);
  }
  VDgeom2LinkCurves(crv_outer,crv_edge);
  VDgeom2MergeTwoCurves(crv_outer,crv_edge,&crv_merged);

  // Update the attribute
  VDctxSetBinAtr(plateID,"outer_contour",crv_merged,NULL);
  free(crv_outer);
  
 wrapup:
  return;
}

/* -----------------------------------------------
 * Process the outer contour
 */
void VDvalSpadesPlateOuterContour(TGRid *plateID, void *data, IGRint *stopWalk)
{
  VDASSERT_FN("VDvalSpadesPlateOuterContour");

  TVDvalSpadesInfo *info = data;

  IGRchab nodeType;

  TGRbsp_curve *crv_outer = NULL;
  
  IGRpoint  pt1,pt2;
  IGRdouble dis;
  IGRdouble area;

  IGRdouble tol;

  // Arg check
  VDASSERTW(plateID && plateID->objid != NULL_OBJID);

  // Walk through and process each plate edge curve
  VDctxWalkNode(plateID,1,processPlateEdge,plateID,stopWalk);
  
  // Get the outer contour
  VDctxGetBinAtr(plateID,"outer_contour",(void*)&crv_outer);
  if (crv_outer == NULL) {
    VDvalLogError("Unable to get the outer contour after processing edges");
    goto wrapup;
  }

  // Check for gaps
  VDgeom2GetCrvEndPts(crv_outer,pt1,pt2);
  VDgeom2GetDisPtPt(pt1,pt2,&dis);
  VDvalGetTolerance(VDTOL_CONTOUR_GAP,&tol);
  if (dis >= tol) {
    VDvalLogError("Gap between outer contour segments of %.2f at %.2f,%.2f,%.2f",
	     dis,pt1[0],pt1[1],pt1[2]);
    drawPoint(pt1);
  }
  drawCurve(info,crv_outer);

  // Save the area (and maybe the center)
  VDgeom2GetCurveArea(crv_outer,&area);
  VDvalGetTolerance(VDTOL_MIN_AREA_OUTER_CONTOUR,&tol);
  if (area < tol) {
    VDvalLogError("Area enclosed by outer contour is only %.2f sqmm",area);
  }
  VDctxAppDblAtr(plateID,"outer_area",area);
  
 wrapup:
  return;
}

/* -----------------------------------------------
 * Check various attributes
 */
IGRstat VDvalSpadesPlateAttributes(TGRid *plateID, void *data, IGRint *stopWalk)
{
  VDASSERT_FN("VDvalSpadesPlateAttributes");
  IGRstat retFlag = 0;
  IGRstat sts;
  
  IGRchab family,part_num,material,grade;
  IGRchab buf;
  IGRchar *p,*px;
  
  IGRdouble thickness1;
  IGRdouble thickness2;
  IGRdouble tol;
  
  IGRpoint pt3d1,pt3d2,pt3d3;
  IGRpoint pt2d1,pt2d2,pt2d3;
  IGRint   i;

  IGRdouble *pts;  
  IGRdouble *range;
  IGRdouble *matrix;
  
  // Arg check
  VDASSERTW(plateID && plateID->objid != NULL_OBJID);
  
  // Need these
  VDctxGetTxtAtr(plateID,"PDF_ATR_PIECE_FAMILY",   family);
  VDctxGetTxtAtr(plateID,"PDF_ATR_PIECE_PART_NUM", part_num);
  VDctxGetTxtAtr(plateID,"PDF_ATR_PIECE_MAT_TYPE", material);
  VDctxGetTxtAtr(plateID,"PDF_ATR_PIECE_MAT_GRADE",grade);

  if (*family < ' ') {
    VDvalLogError("Missing plate family");
    goto wrapup;
  }
  if (*part_num < ' ') {
    VDvalLogError("Missing plate part_num");
    goto wrapup;
  }
  if (*material < ' ') {
    VDvalLogError("Missing plate material");
    goto wrapup;
  }
  if (*grade < ' ') {
    VDvalLogError("Missing plate grade");
    goto wrapup;
  }
  
  // See if material-grade match
  VDvalGetGradeMaterial(grade,buf);
  if (strcmp(material,buf)) {
    VDvalLogError("Invalid grade(%s) material(%s) combination",
	     grade,material);
    goto wrapup;
  }

  // Get the thickness which also validates the part
  sts = VDvalGetPartThickness(family,part_num,material,&thickness1);
  if (sts == 0) {
    VDvalLogError("Invalid family(%s) part_num(%s) material(%s) combination",
	     family,part_num,material);
    goto wrapup;
  }
  VDctxGetDblAtr(plateID,"PDF_ATR_PLATE_THICKNESS",&thickness2);

  VDvalGetTolerance(VDTOL_STANDARD_PLATE_THICKNESS,&tol);

  if (fabs(thickness1 - thickness2) >= tol) {
    VDvalLogError("Invalid plate thickness %.2f, should be %.2f",
	     thickness2,thickness1);
    goto wrapup;
  }
  
  // The 4x3 matrix
  VDctxGetTxtAtrPtr(plateID,"PDF_ATR_PIECE_MATRIX",&px);
  if ((px == NULL) || (*px == 0)) {
    VDvalLogError("No 4x3 translation matrix");
    goto wrapup;
  }
  p = px;
  matrix = malloc(16 * sizeof(IGRdouble));
  for(i = 0; i < 12; i++) {
    matrix[i] = VDvalParseDouble(&p);
  }
  matrix[12] = matrix[13] = matrix[14] = 0.0;
  matrix[15] = 1.0;
  VDctxAppBinAtr(plateID,"matrix",matrix,NULL);
  
  // The range just because
  VDctxGetTxtAtrPtr(plateID,"PDF_ATR_PIECE_RANGE",&px);
  if ((px == NULL) || (*px == 0)) {
    VDvalLogError("No piece range");
    goto wrapup;
  }
  p = px;
  range = malloc(6 * sizeof(IGRdouble));
  for(i = 0; i < 6; i++) {
    range[i] = VDvalParseDouble(&p);
  }
  VDctxAppBinAtr(plateID,"range",range,NULL);
  
  // Save points just for grins
  VDctxGetTxtAtrPtr(plateID,"PDF_ATR_PIECE_3D_REF_PTS",&px);
  if ((px == NULL) || (*px == 0)) {
    VDvalLogError("No 3d reference points");
    goto wrapup;
  }
  p = px;
  pts = malloc(sizeof(IGRdouble) * 9);
  for(i = 0; i < 9; i++) {
    pts[i] = VDvalParseDouble(&p);
  }
  VDctxAppBinAtr(plateID,"pts",pts,NULL);
  
  // Done
  retFlag = 1;
  
 wrapup:  
  return retFlag;
}

/* -----------------------------------------------
 * Routine to validates a spades plate
 */
void VDvalSpadesPlate(TGRid *plateID, TVDvalSpadesInfo *info, IGRint *stopWalk)
{
  VDASSERT_FN("VDvalSpadesPlate");

  // Init
  VDvalResetLogErrorData();
  
  // Only for plates
  VDASSERTW(plateID && plateID->objid != NULL_OBJID);
  if (!VDctzIsPlate(plateID)) goto wrapup;
  VDvalSetPieceError(plateID);
  
  // Check the attributes, pulling out some good stuff
  VDvalSpadesPlateAttributes(plateID,info,stopWalk);

  // Process the outer contour
  VDvalSpadesPlateOuterContour(plateID,info,stopWalk);
  
  // Process the holes
  VDctxWalkNode(plateID,1,VDvalSpadesPlateHole,info,stopWalk);

  // Bounce the holes against each other
  validatePlateHoles(plateID,info,stopWalk);
 
  // Done
 wrapup:
  VDvalResetLogErrorData();
  return;
}

/* -----------------------------------------------
 * See how many feet are required
 */
static void countFeet(TGRid *nodeID, void *data, IGRint *stopWalk)
{
  VDASSERT_FN("countFeet");

  IGRint *cnt = data;
    
  // Each hole gets a foot
  if (VDctxIsNodeType(nodeID,"PDF_OBJ_HOLE")) {
    *cnt = *cnt + 1;
    goto wrapup;
  }
  
 wrapup:
  return;
}

/* -----------------------------------------------
 * Recompute a spades plate
 */
IGRstat VDvalSpadesCompute(TGRobj_env *macOE,
			   IGRint      opFlag,
			   IGRint     *feetCnt,
			   TGRid      *feetIDs)
{
  VDASSERT_FN("VDvalSpadesCompute");
  
  IGRstat retFlag = 0;
  IGRstat sts,msg;

  IGRchab  pcmk;
  
  TGRid plateID;
  IGRint stopWalk = 0;
  IGRint cnt;
  
  TVDvalSpadesInfo info;
  
  IGRdouble *range = NULL;
  
  IGRpoint pt;
  
  // Init
  *feetCnt = 0;
  plateID.objid = NULL_OBJID;
  memset(&info,0,sizeof(TVDvalSpadesInfo));
  info.macroFlag = 1;

  // Need the xml data
  VDbufGetDomTree(macOE,&plateID);
  VDASSERTW(plateID.objid != NULL_OBJID);
  info.plateID = plateID;
  
  // Trace
  VDctzGetPieceMark(&plateID,pcmk);

  // Need to know number of feet to allow for
  cnt = 1;
  VDctxWalkNode(&plateID,1,countFeet,&cnt,&stopWalk);
  
  // Mainly for symbology control
  VDbufCreateCollector(macOE->obj_id.osnum,&info.collID);
  //pt[0] = pt[1] = pt[2] = 0.0;
  //VDdrawLinear(1,pt,NULL,&info.collID);
  VDASSERTW(info.collID.objid != NULL_OBJID);
  
  // Add some feet
  VDbufCreateDrawingGeometry(macOE->obj_id.osnum,cnt,&info.drwGm2dID);
  VDASSERTW(info.drwGm2dID.objid != NULL_OBJID);

  VDbufCreateDrawingGeometry(macOE->obj_id.osnum,cnt,&info.drwGm3dID);

  //VDbufCreateGraphicGroup(&macOE->mod_env,&info.drwGm3dID);
  VDASSERTW(info.drwGm3dID.objid != NULL_OBJID);

  feetIDs[0] = info.collID;
  feetIDs[1] = info.drwGm2dID;
  feetIDs[2] = info.drwGm3dID;
  *feetCnt = 3;

  // Validate it
  VDvalSpadesPlate(&plateID,&info,&stopWalk);

  // Done
  retFlag = 1;
  
 wrapup:
  VDctxDeleteNode(&plateID);
  
  return retFlag;
}

/* -----------------------------------------------
 * Process one plate in the loaded spades tree
 */
void VDvalSpadesPlaceXmlPlate(TGRid *plateID, void *data, IGRint *stopWalk)
{
  VDASSERT_FN("VDvalSpadesPlaceXmlPlate");
  IGRchab pcmk;
    
  TGRobj_env macOE;
  
  // Only want plates
  if (!VDctzIsPlate(plateID)) goto wrapup;

  // Trace
  VDctzGetPieceMark(plateID,pcmk);
  
  // Place the macro
  VDbufPlaceMacro("VDxml","unw_spades",pcmk,NULL,plateID,&macOE);
  if (macOE.obj_id.objid == NULL_OBJID) {
    VDlogPrintFmt(VDLOG_ERROR,1,"*** Could not place unw_spades macro for piece %s",pcmk);
    goto wrapup;
  }
  
 wrapup:
  
  return;
}
/* -----------------------------------------------
 * Process one plate in the loaded spades tree
 */
void VDvalSpadesProcessPlate(TGRid *plateID, void *data, IGRint *stopWalk)
{
  VDASSERT_FN("VDvalSpadesProcessPlate");
  IGRchab pcmk;
  TVDvalSpadesInfo info;

  IGRchar *buf = NULL;

  // Init
  memset(&info,0,sizeof(TVDvalSpadesInfo));
  
  // Only want plates
  if (!VDctzIsPlate(plateID)) goto wrapup;
  info.plateID = *plateID;
  
  // Trace
  VDctzGetPieceMark(plateID,pcmk);
  // printf("Piece %s\n",pcmk);

  VDvalSpadesPlate(plateID,&info,stopWalk);

 wrapup:
  if (buf) free(buf);
  
  return;
}

/* -----------------------------------------------
 * Validate a spades xml file either using
 * xml macro or just direct function
 */
void VDvalValidateSpadesFile(IGRchar *fileName, IGRint useMacro, IGRint drawPoints)
{
  VDASSERT_FN("VDvalValidateSpadesFile");
  
  TGRid  treeID;
  IGRint stopWalk = 0;
  
  TGRsymbology symb_save;
  TGRsymbology symb;
  
  TGRid stagingID;
  TGRid platesID;
  TGRid setupID;
  TGRid childID;
  
  IGRint i;
  
  IGRchar ts[128];
  
  // Init
  treeID.objid    = NULL_OBJID;
  stagingID.objid = NULL_OBJID;
  platesID.objid  = NULL_OBJID;
  
  VDvalResetLogErrorData();
  
  VDlogOpenCat("spades_val.err");

  // Parseing symbology
  VDahGetActiveSymbology(&symb_save);
  VDahGetActiveSymbology(&symb);
  symb.level = 499;
  symb.display_attr.color  = 3;
  symb.display_attr.weight = 3;  
  symb.display_attr.style  = 0;  
  VDvalParseSetDrawFlag(drawPoints,&symb);
  
  // Load in the spades file
  if (fileName == NULL) fileName = "spades.xml";
  VDxdomCreateTreeFromXmlFile(fileName,&treeID);
  VDASSERTW(treeID.objid != NULL_OBJID);
  
  // Cycle through and pull on top level nodes
  for(i = 0; VDctxGetNthTreeChild(&treeID,i,&childID); i++) {
    if (VDctxIsNodeType(&childID,"PDF_OBJ_SETUP"))  setupID   = childID;
    if (VDctxIsNodeType(&childID,"PDF_OBJ_TREE"))   stagingID = childID;
    if (VDctxIsNodeType(&childID,"PDF_OBJ_PLATES")) platesID  = childID;
  }
  if (setupID.objid != NULL_OBJID) VDctxGetTxtAtr(&setupID,"PDF_ATR_SETUP_FILE_NAME",ts);
  else VDsysGetTimeStamp(ts);
  VDlogPrintFmt(VDLOG_ERROR,0,"Spades Validation Error Log, %s",ts);
  
  // Walk through and process each staging tree node
  if (stagingID.objid != NULL_OBJID) {  
    VDvalValidateStagingTree(&stagingID,NULL);
  }
  
  // Walk through and process each plate
  if (platesID.objid != NULL_OBJID) {  
    if (useMacro) VDctxWalkNode(&platesID,1,VDvalSpadesPlaceXmlPlate,NULL,&stopWalk);
    else          VDctxWalkNode(&platesID,1,VDvalSpadesProcessPlate, NULL,&stopWalk);
  }
  
  // Piece mark check
  if ((stagingID.objid != NULL_OBJID) && (platesID.objid != NULL_OBJID)) {  
    VDvalValidateStagingPieceMarks(&stagingID,&platesID);
  }
  
  // Done
 wrapup:

  VDvalParseSetDrawFlag(0,NULL);
  VDahSetActiveSymbology(&symb_save);
  
  VDctxDeleteNode(&treeID);
  
  VDlogCloseCat("spades_val.err");
  VDlogShowCat ("spades_val.err");

  VDvalResetLogErrorData();
  
  return;
}

/* -----------------------------------------------
 * Main test routine
 */
void VDtestSpadesValidate(TVDtestTestInfo *testInfo)
{
  VDASSERT_FN("VDtestSpadesValidate");
  
  // Simple
  VDvalValidateSpadesFile("spades.xml",1,1);
  testInfo->worked = 1;
    
 wrapup:  
  return;
}
