/* $Id: VDvalParse.c,v 1.6 2001/08/02 15:32:46 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdval/x2/VDvalParse.c
 *
 * Description:	Parse geometry from text strings
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDvalParse.c,v $
 *      Revision 1.6  2001/08/02 15:32:46  ahundiak
 *      ah
 *
 *      Revision 1.5  2001/07/23 16:28:36  ahundiak
 *      ah
 *
 *      Revision 1.4  2001/07/03 20:13:19  ahundiak
 *      ah
 *
 *      Revision 1.3  2001/06/22 19:50:40  ahundiak
 *      ah
 *
 *      Revision 1.2  2001/06/22 15:39:18  ahundiak
 *      ah
 *
 *      Revision 1.1  2001/06/22 15:18:31  ahundiak
 *      ah
 *
 *      Revision 1.4  2001/06/14 18:32:18  ahundiak
 *      ah
 *
 *      Revision 1.3  2001/06/07 19:05:24  ahundiak
 *      ah
 *
 *      Revision 1.2  2001/05/24 18:44:38  ahundiak
 *      ah
 *
 *      Revision 1.1  2001/05/17 14:55:28  ahundiak
 *      ah
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 05/14/01  ah      Creation
 ***************************************************************************/
#include "VDtypedefc.h"
#include "VDassert.h"
#include "VDlog.h"
#include "VDgeomc.h"
#include "VDval.h"

VDASSERT_FFN("VDvalParse.c");

/* -------------------------------------------------
 * Provide a debugging interface
 */
static drawFlag;
static TGRsymbology drawSymb;

void VDvalParseSetDrawFlag(IGRint flag, TGRsymbology *symb) 
{
  drawFlag = flag;
  if (symb) drawSymb = *symb;
}
void VDvalParseGetDrawFlag(IGRint *flag, TGRsymbology *symb) 
{
  if (flag) *flag = drawFlag;
  if (symb) *symb = drawSymb;
}

/* -----------------------------------------------
 * Debugging points
 */
static void drawPoint(IGRpoint pt)
{
  VDASSERT_FN("drawPoint");
  
  TGRid ptID;
  
  // Ignore
  if (drawFlag == 0) goto wrapup;
  if (!VDahIsIsdpRunning()) goto wrapup;
  
  // Arg check
  VDASSERTW(pt);
  
  // Do it
  VDdrawLinear(1,pt,NULL,&ptID);
  
wrapup:
  
  return;
}

static void drawBadPoint(IGRpoint pt)
{
  VDASSERT_FN("drawBadPoint");
  
  TGRid ptID;

  TGRsymbology symb;
  
  // Ignore
  if (drawFlag == 0) goto wrapup;
  if (!VDahIsIsdpRunning()) goto wrapup;
  
  // Arg check
  VDASSERTW(pt);
  
  // Do it
  symb = drawSymb;
  symb.display_attr.color = 2;
  symb.display_attr.weight = 5;
  VDahSetActiveSymbology(&symb);
  VDdrawLinear(1,pt,NULL,&ptID);
  VDahSetActiveSymbology(&drawSymb);

wrapup:  
  return;
}

/* -------------------------------------------------
 * Strip off any leading white space
 */
void VDvalStripWhitespace(IGRchar **buf)
{
  IGRchar *p = *buf;
  
  // Strip white space
  while((*p) && (*p <= ' ')) p++;
  
  *buf = p;
  return;
}

/* -------------------------------------------------
 * Grabs the next text from the buffer updating the pointer
 */
void VDvalParseText(IGRchar **buf, IGRchar *txt)
{
  VDASSERT_FN("VDvalParseText");
  
  IGRchar *p = *buf;
  IGRchar *px;
  IGRint   len;
  
  // Arg check
  VDASSERTW(txt); *txt = NULL;
  
  // Strip white space
  VDvalStripWhitespace(&p);
  if (*p == 0) goto wrapup;

  // Copy it
  px = p;
  while(*p > ' ') p++;
  len = p - px;
  memcpy(txt,px,len);
  *(txt + len) = 0;
  
 wrapup:
  *buf = p;
  return;
}

/* -------------------------------------------------
 * Grabs the next double from the buffer updating the pointer
 * when done
 */
IGRdouble VDvalParseDouble(IGRchar **buf)
{
  IGRdouble dbl = 0.0;
  
  IGRchar *p = *buf;
  
  // Strip white space
  VDvalStripWhitespace(&p);
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
IGRint VDvalParseInteger(IGRchar **buf)
{
  IGRint integer = -1;
  
  IGRchar *p = *buf;
  
  // Strip white space
  VDvalStripWhitespace(&p);
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
 * Validates a proposed segment from the line arc routine
 * basically, a line segment needs to be at least 1mm in length
 *
 * Right now ignore these segments though that leaves a gap but the 
 * merge takes care of any internal gaps and the overall process
 * should take care of any end gaps
 *
 * Reset the min length down to .1 mm,  Have several hits at 1.0,
 * Really need to adjust the line arc routine to make these go away
 */
static lineArcValidateSegmentFlag;

static IGRstat parseLineArcValidateSegment(IGRpoint pt1, IGRpoint pt2) 
{
  VDASSERT_FN("parseLineArcValidateSegment");
  IGRstat retFlag = 0;
  
  IGRdouble dis;
  IGRdouble tol;
  
  // Validate distance
  VDgeom2GetDisPtPt(pt1,pt2,&dis);
  VDvalGetTolerance(VDTOL_MIN_LINE_ARC_SEG_LEN,&tol);
  if (dis < tol) {
    VDvalLogError("Line arc segment length of %.02f at %.2f,%.2f,%.2f",
		  dis,pt1[0],pt1[1],pt1[2]);
    lineArcValidateSegmentFlag = 1;
    drawBadPoint(pt1);
    goto wrapup;
  }
  
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

extern IGRdouble VDgeomRadToDeg(IGRdouble angle);

/* -------------------------------------------------
 * check to see if a merge will result in a segment
 * doubling back on itself
 */
static IGRstat parseLineArcValidateMerge(TGRbsp_curve *crv1, TGRbsp_curve *crv2)
{
  VDASSERT_FN("parseLineArcValidateSegment");
  IGRstat retFlag = 0;
  
  IGRpoint pt1,pt2,pt3;
  
  IGRdouble len;
  IGRdouble angle;
  
  // End of crv1 should match beg of crv2
  VDgeom2GetCrvPt(crv2,0.0,pt2);
  
  // Back off a bit from the first curve
  VDgeom2GetCrvArcLen(crv1,0.0,1.0,&len);
  len -= 1.0; if (len < 0.0) len = 0.0;
  VDgeom2GetCrvArcParPt(crv1,0.0,1.0,len,NULL,pt1);
  
  // Go forward a bit on the second curve
  VDgeom2GetCrvArcLen(crv2,0.0,1.0,&len);
  if (len > 1.0) len = 1.0;
  VDgeom2GetCrvArcParPt(crv2,0.0,1.0,len,NULL,pt3);

  // Check the angles
  VDgeom2GetAngleFrom3Points(pt1,pt2,pt3,&angle);
  angle = VDgeom2RadToDeg(angle);  
  if (angle < 10.0) {
    VDvalLogError("Segment has reversed direction, Angle %.2f at %.2f,%.2f,%.2f",
		  angle,pt2[0],pt2[1],pt2[2]);
    lineArcValidateSegmentFlag = 1;
    drawBadPoint(pt2);
    goto wrapup;
  }
  
  // Ok
  retFlag = 1;

 wrapup:
  return retFlag;
}

/* -------------------------------------------------
 * parse a line arc buffer, retuning a bsp curve
 */
IGRstat VDvalParseLineArc(IGRchar *buf, IGRdouble z, TGRbsp_curve **crv_result)
{
  VDASSERT_FN("VDvalParseLineArc");
  
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

  TGRsymbology symb;
  
  // Check symbology
  if (drawFlag) {
    VDahGetActiveSymbology(&symb);
    VDahSetActiveSymbology(&drawSymb);
  }

  // Arg check
  VDASSERTW(buf);
  VDASSERTW(crv_result);
  
  // Say hi
  if (traceFlag) printf(">>> %s\n",fn);
  lineArcValidateSegmentFlag = 0;
  
  // Start with nothing
  *crv_result = NULL;
  pt1[2] = pt2[2] = pt3[2] = z;
  crv_segment = (TGRbsp_curve*)crv_buf;

  /* ----------------------------------------
   * Check for the first character to be a zero
   * Filters out other types of curves
   */
  VDvalStripWhitespace(&p);
  if (*p != '0') {
    VDvalLogError("%s called without a line arc, '%s'",fn,buf);
    goto wrapup;
  }
  
  // First type should always be zero
  type = VDvalParseInteger(&p);
  VDASSERTW(type == 0);
  pt1[0] = VDvalParseDouble(&p);
  pt1[1] = VDvalParseDouble(&p);
  drawPoint(pt1);
  
  // Loop on each segment
  while(1) {

    // Get the next type
    type = VDvalParseInteger(&p);
    if (type == -1) {
      retFlag = 1;
      goto wrapup;
    }
    pt2[0] = VDvalParseDouble(&p);
    pt2[1] = VDvalParseDouble(&p);
    drawPoint(pt2);
    segFlag = 0;
    
    // Is it a line segment or arc
    switch(type) {

      case 0:
	// Line segment
	sts = parseLineArcValidateSegment(pt1,pt2);
	if (sts == 1) {  
	  VDgeom2MakeLineCurve(pt1,pt2,&crv_segment);
	  VDASSERTW(crv_segment);
	  segFlag = 1;
	}
	break;
	
      case 1:
	// Arc segment
	type = VDvalParseInteger(&p);
	VDASSERTW(type == 0);
	pt3[0] = VDvalParseDouble(&p);
	pt3[1] = VDvalParseDouble(&p);
	drawPoint(pt3);
	
	// Validation
	sts = parseLineArcValidateSegment(pt1,pt3);
	if (sts == 1) {
	  sts = parseLineArcValidateSegment(pt1,pt2);
	  if (sts == 1) sts = parseLineArcValidateSegment(pt2,pt3);
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

	// Flags fold backs
	parseLineArcValidateMerge(*crv_result,crv_segment);
	
	VDgeom2MergeTwoCurves(*crv_result,crv_segment,&crv_merged);
	if (crv_merged == NULL) {  
	  VDvalLogError("Line arc segment merge curve failed");
	  goto wrapup;
	}
	free(*crv_result);
	*crv_result = crv_merged;
      }
    }
    
    // Next segment
    for(i = 0; i < 3; i++) pt1[i] = pt2[i];
  }
  
 wrapup:

  // Return false on any validation problems
  if (lineArcValidateSegmentFlag) retFlag = 0;

  if (drawFlag) {
    VDahSetActiveSymbology(&symb);
  }
  
  return retFlag;
}

/* -------------------------------------------------
 * Parse a hole circle
 */
IGRstat VDvalParseCircleCurve(IGRchar *buf, IGRdouble z, TGRbsp_curve **crv_result)
{
  VDASSERT_FN("VDvalParseCircleCurve");
  IGRstat retFlag = 0;
  
  IGRchar *p = buf;
  
  IGRdouble radius;
  IGRpoint  center;
  IGRpoint  pt1,pt2,pt3;
  
  IGRint i;
  
  IGRdouble tol;
  
  // Arg check
  VDASSERTW(crv_result); *crv_result = NULL;
  VDASSERTW(buf);
  
  // Only circles
  VDvalStripWhitespace(&p);
  if (strncasecmp(p,"CIRCLE ",7)) goto wrapup;
  p = strchr(p,' ');
  retFlag = 1;

  // Center and radius
  center[0] = VDvalParseDouble(&p);
  center[1] = VDvalParseDouble(&p);
  center[2] = z;
  radius    = VDvalParseDouble(&p) * .5;

  VDvalGetTolerance(VDTOL_MIN_HOLE_DIMENSION,&tol);
   
  if (radius < tol) {
    VDvalLogError("Very small radius of %.2f (tol %.2f) for circle hole at %.2f,%.2f,%.2f",
		  radius,tol,center[0],center[1],center[2]);
    drawBadPoint(center);
    radius = tol;
  }
  // Need 3 points on circum
  for(i = 0; i < 3; i++) {
    pt1[i] = pt2[i] = pt3[i] = center[i];
  }
  pt1[0] += radius;
  pt2[1] += radius;
  pt3[0] -= radius;

  // Make it
  VDgeom2MakeCircleCurve(pt1,pt2,pt3,crv_result);
  VDASSERTW(*crv_result);
  
 wrapup:
  return retFlag;
}

/* -------------------------------------------------
 * Parse a ellipse
 */
IGRstat VDvalParseEllipseCurve(IGRchar *buf, IGRdouble z, TGRbsp_curve **crv_result)
{
  VDASSERT_FN("VDvalParseEllipseCurve");
  IGRstat retFlag = 0;
  
  IGRchar *p = buf;
  
  IGRdouble width,depth;
  IGRpoint  center;
  IGRpoint  major,minor;
  
  IGRdouble tol;
  
  // Arg check
  VDASSERTW(crv_result); *crv_result = NULL;
  VDASSERTW(buf);
  
  // Only ellipses
  VDvalStripWhitespace(&p);
  if (strncasecmp(p,"ELLIPSE ",8)) goto wrapup;
  p = strchr(p,' ');
  retFlag = 1;
  
  // Extract
  center[0] = VDvalParseDouble(&p);
  center[1] = VDvalParseDouble(&p);
  center[2] = z;
  
  major[0] = VDvalParseDouble(&p);
  major[1] = VDvalParseDouble(&p);
  major[2] = z;

  minor[0] = VDvalParseDouble(&p);
  minor[1] = VDvalParseDouble(&p);
  minor[2] = z;

  // Depth and width
  VDgeom2GetDisPtPt(center,major,&width);
  VDgeom2GetDisPtPt(center,minor,&depth);
  VDvalGetTolerance(VDTOL_MIN_HOLE_DIMENSION,&tol);
  
  if (width < tol) {
    VDvalLogError("Very small width of %.2f for ellipse hole at %.2f,%.2f,%.2f",
		  width,center[0],center[1],center[2]);
    drawBadPoint(center);
  }
  if (depth < tol) {
    VDvalLogError("Very small depth of %.2f for ellipse hole at %.2f,%.2f,%.2f",
		  depth,center[0],center[1],center[2]);
    drawBadPoint(center);
  }

  // Make it
  VDgeom2MakeEllipseCurve(center,major,minor,crv_result);
  VDASSERTW(*crv_result);
  
 wrapup:
  return retFlag;
}

/* -------------------------------------------------
 * Parse a flat oval
 */
IGRstat VDvalParseFlatOvalCurve(IGRchar *buf, IGRdouble z, TGRbsp_curve **crv_result)
{
  VDASSERT_FN("VDvalParseFlatOvalCurve");
  IGRstat retFlag = 0;
  
  IGRchar *p = buf;
  
  IGRdouble width,depth;
  IGRpoint  center;
  IGRpoint  major,minor;

  IGRdouble tol;
  
  // Arg check
  VDASSERTW(crv_result); *crv_result = NULL;
  VDASSERTW(buf);
  
  // Only ellipses
  VDvalStripWhitespace(&p);
  if (strncasecmp(p,"OVAL ",5)) goto wrapup;
  p = strchr(p,' ');
  retFlag = 1;

  // Extract
  center[0] = VDvalParseDouble(&p);
  center[1] = VDvalParseDouble(&p);
  center[2] = z;
  
  major[0] = VDvalParseDouble(&p);
  major[1] = VDvalParseDouble(&p);
  major[2] = z;

  minor[0] = VDvalParseDouble(&p);
  minor[1] = VDvalParseDouble(&p);
  minor[2] = z;

  // Depth and width
  VDgeom2GetDisPtPt(center,major,&width);
  VDgeom2GetDisPtPt(center,minor,&depth);

  VDvalGetTolerance(VDTOL_MIN_HOLE_DIMENSION,&tol);
  
  if (width < tol) {
    VDvalLogError("Very small width of %.2f for flat oval hole at %.2f,%.2f,%.2f",
		  width,center[0],center[1],center[2]);
    drawBadPoint(center);
  }
  if (depth < tol) {
    VDvalLogError("Very small depth of %.2f for flat oval hole at %.2f,%.2f,%.2f",
		  depth,center[0],center[1],center[2]);
    drawBadPoint(center);
  }

  // Make it
  VDgeom2MakeFlatOvalCurve(center,major,minor,crv_result);
  VDASSERTW(*crv_result);
  
 wrapup:
  return retFlag;
}

/* -------------------------------------------------
 * Parse a generic curve, could be parametric or
 * line arc
 */
IGRstat VDvalParseGenericCurve(IGRchar *buf, IGRdouble z, TGRbsp_curve **crv_result, IGRchar *shape)
{
  VDASSERT_FN("VDvalParseGenericCurve");
  
  IGRstat retFlag = 0;
  IGRstat sts;
  
  IGRchar hdr[32];  

  IGRchar *p = buf;

  TGRsymbology symb;
  
  // Say hi
  traceFlagx = 0;
  if (traceFlagx) printf(">>> %s\n",fn);
  
  // Arg check
  VDASSERTW(crv_result); *crv_result = NULL;
  VDASSERTW(buf);

  // Check symbology
  if (drawFlag) {
    VDahGetActiveSymbology(&symb);
    VDahSetActiveSymbology(&drawSymb);
  }
  
  // Strip whitespace
  VDvalStripWhitespace(&p);
  if (traceFlagx) printf("'%s'\n",p);

  // Is it a circle
  sts = VDvalParseCircleCurve(p,z,crv_result);
  if (sts & 1) {
    retFlag = 1;
    if (shape) strcpy(shape,"CIRCLE");
    goto wrapup;
  }

  // Is it an oval
  sts = VDvalParseFlatOvalCurve(p,z,crv_result);
  if (sts & 1) {
    retFlag = 1;
    if (shape) strcpy(shape,"FLAT_OVAL");
    goto wrapup;
  }

  // Is it an ellipse
  sts = VDvalParseEllipseCurve(p,z,crv_result);
  if (sts & 1) {
    retFlag = 1;
    if (shape) strcpy(shape,"ELLIPSE");
    goto wrapup;
  }
  
  // Try for line arc
  sts = VDvalParseLineArc(p,z,crv_result);
  if (sts & 1) {    
    if (shape) strcpy(shape,"LINE_ARC");
    retFlag = 1;
    goto wrapup;
  }

  // Failed
  strncpy(hdr,buf,15);
  *(hdr+15) = 0;
  VDvalLogError("Unknown type of generic curve %s",hdr);
    
  // Done

 wrapup:
  if (drawFlag) {
    VDahSetActiveSymbology(&symb);
  }
  if (traceFlagx) printf("<<< %s %d\n",fn,retFlag);

  return retFlag;
}

