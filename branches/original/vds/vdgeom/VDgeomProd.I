/* $Id: VDgeomProd.I,v 1.2 2001/01/11 18:41:18 art Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdah/VDgeomProd.I
 *
 * Description:	Geometry ProductionProcessing
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDgeomProd.I,v $
 *      Revision 1.2  2001/01/11 18:41:18  art
 *      sp merge
 *
# Revision 1.5  2000/10/18  18:28:16  pinnacle
# ah
#
# Revision 1.4  2000/06/19  18:06:40  pinnacle
# ah
#
# Revision 1.3  2000/04/28  19:32:24  pinnacle
# ah
#
# Revision 1.2  2000/04/25  16:15:56  pinnacle
# ah
#
# Revision 1.1  2000/04/11  17:14:28  pinnacle
# ah
#
# Revision 1.5  2000/04/05  22:18:28  pinnacle
# ah
#
# Revision 1.4  2000/03/31  17:00:56  pinnacle
# ah
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 03/21/00  ah      Added Header
 * 03/21/00  ah      Changed BSalloccv to VDgeomAllocCrv()
 * 04/05/00  ah      Changed GetKnot tolerance
 ***************************************************************************/
class implementation Root;

#include "VDtypedef.h"
#include "VDobj.h"
#include "VDchn.h"
#include "VDmem.h"
#include "VDgeom.h"

static int traceFlag;

/* ----------------------------------------------------------------------
 * Checks for circular edge line within tolerance
 *
 */
IGRstar VDgeomIsCrvCirArc(TGRbsp_curve *bsp, IGRdouble tol)
{
  IGRchar fn[] = "VDgeomIsCrvArc";
  IGRstat retFlag = 0;
  IGRstat sts;
    
  IGRpoint pt1,pt2,pt3,pt;
  TGRbsp_curve *arc = NULL;

  IGRchar arcBuf[VDGEOM_SIZE_ARC];
  
  IGRdouble totalLen,incLen,theLen;
  
  IGRdouble dist;
  
  TVDgeomKnots knots;
  IGRdouble    bufKnots[512];
  
  IGRint traceFlagx;

  // Init
  VDgeomInitKnots(&knots,bufKnots,512);
  
  // Say hi
  traceFlagx = traceFlag;
  // traceFlagx = 1;
  if (traceFlagx) {
    printf(">>> %s\n",fn);
    vdgeom$Print(crv = bsp);
  }

  // Arg check
  if (bsp == NULL) goto wrapup;
  if (tol < VDGEOM_TOL_ZERO) tol = VDGEOM_TOL_LINEAR;
  
  // If the curve is linear, fail with a status of 2
  sts = VDgeomIsCrvLinear(bsp,tol);
  if (sts & 1) {
    retFlag = 2;
    goto wrapup;
  }
  
  // Get the arc points
  VDgeomGetCrvPt(bsp,0.0,pt1);
  VDgeomGetCrvPt(bsp,0.5,pt2);  // Maybe should use mid distance
  VDgeomGetCrvPt(bsp,1.0,pt3);
  
  // Make an arc
  arc = (TGRbsp_curve*)arcBuf;
  sts = VDgeomMakeArcCurve(pt1,pt2,pt3,&arc);
  if (!(sts & 1)) goto wrapup;
  
  if (traceFlagx) {
    vdgeom$Print(crv = arc);
  }
  
  // Check Knots Point
  vdgeom$GetKnotsFromCurve(crv = bsp, knots = &knots);
  if (traceFlagx) {
    printf("Number of knots %d\n",knots.cnt);
  }
  
  for(knots.i = 0; knots.i < knots.cnt; knots.i++) {
    VDgeomGetCrvPt(bsp,knots.knots[knots.i],pt);
    VDgeomGetDisPtCv(pt,arc, &dist);
    if (dist > tol) goto wrapup;
  }
  if (traceFlagx) {
    printf("Passed knot check\n");
  }
  
  // Use points from arc length
  vdgeom$GetCrvArcLen(crv = bsp, len = &totalLen);
  if (totalLen < 1.0) {
    retFlag = 1;
    goto wrapup;
  }
  
  // Use 25 points or 1mm
  incLen = totalLen / 25.0;
  if (incLen < 1.0) incLen = 1.0;
  
  // Just march along
  for(theLen = incLen; theLen < totalLen; theLen += incLen) {

    // Check It
    vdgeom$GetCrvArcParPt(crv = bsp,len = theLen,pt = pt);
    VDgeomGetDisPtCv(pt,arc, &dist);
    if (dist > tol) goto wrapup;
  }
     
  // Done
  retFlag = 1;
  
wrapup:
  VDgeomFreeKnots(&knots);
  if (traceFlagx) {
    printf("<<< %s %d\n",fn,retFlag);
  }
  
  return retFlag;
}

/* ----------------------------------------------------------------------
 * Checks for linear edge line within tolerance
 *
 * 28 March 2000 - Not tested, don't think it's working right
 * 31 March 2000 - Working now!
 */
IGRstar VDgeomIsCrvLinear(TGRbsp_curve *bsp, IGRdouble tol)
{
  IGRchar fn[] = "VDgeomIsCrvLinear";
  IGRstat retFlag = 0;
  IGRstat sts;
    
  IGRpoint pt1,pt2,pt;
  TGRbsp_curve *line = NULL;

  IGRchar lineBuf[VDGEOM_SIZE_LINE];
  
  IGRdouble totalLen,incLen,theLen;
  
  IGRdouble dist;
  
  TVDgeomKnots knots;
  IGRdouble    bufKnots[512];
  
  IGRint traceFlagx;

  // Init
  VDgeomInitKnots(&knots,bufKnots,512);
  
  // Say hi
  traceFlagx = traceFlag;
  //traceFlagx = 1;
  if (traceFlagx) {
    printf(">>> %s\n",fn);
    vdgeom$Print(crv = bsp);
  }

  // Arg check
  if (bsp == NULL) goto wrapup;
  if (tol < VDGEOM_TOL_ZERO) tol = VDGEOM_TOL_LINEAR;
  
  /* Input curve might already be a line segment
   */
  if ((bsp->order == 2) && (bsp->num_poles == 2)) {
    retFlag = 1;
    goto wrapup;
  }
  
  // Get the end points
  VDgeomGetCrvPt(bsp,0.0,pt1);
  VDgeomGetCrvPt(bsp,1.0,pt2);
  
  // Make a line segment
  line = (TGRbsp_curve*)lineBuf;
  VDgeomMakeLineCurve(pt1,pt2,&line);
  
  if (traceFlagx) {
    vdgeom$Print(crv = line);
  }
  
  // Check Knots Point
  vdgeom$GetKnotsFromCurve(crv = bsp, knots = &knots);
  if (traceFlagx) {
    printf("Number of knots %d\n",knots.cnt);
  }
  
  for(knots.i = 0; knots.i < knots.cnt; knots.i++) {
    VDgeomGetCrvPt(bsp,knots.knots[knots.i],pt);
    VDgeomGetDisPtCv(pt,line, &dist);
    if (dist > tol) goto wrapup;
  }
  if (traceFlagx) {
    printf("Passed knot check\n");
  }
  
  // Use points from arc length
  vdgeom$GetCrvArcLen(crv = bsp, len = &totalLen);
  if (totalLen < 1.0) {
    retFlag = 1;
    goto wrapup;
  }
  
  // Use 25 points or 1mm
  incLen = totalLen / 25.0;
  if (incLen < 1.0) incLen = 1.0;
  
  // Just march along
  for(theLen = incLen; theLen < totalLen; theLen += incLen) {

    // Check It
    vdgeom$GetCrvArcParPt(crv = bsp,len = theLen,pt = pt);
    VDgeomGetDisPtCv(pt,line, &dist);
    if (dist > tol) goto wrapup;
  }
     
  // Done
  retFlag = 1;
  
wrapup:
  VDgeomFreeKnots(&knots);
  if (traceFlagx) {
    printf("<<< %s %d\n",fn,retFlag);
  }
  
  return retFlag;
}

/* -----------------------------------------------
 * Given three points, return the angle between the
 * line segments from pt1-p2 and pt2-pt3
 */
IGRstat VDgeomGetAngleFrom3Points(IGRpoint pt1,
				  IGRpoint pt2,
				  IGRpoint pt3,
				  IGRdouble *angle)
{
  IGRstat retFlag = 0;
  BSrc    rc;
  
  IGRdouble dotp;
  IGRvector vec21,vec23;
  
  // Arg check
  if (angle == NULL) goto wrapup;
  *angle = 0.0;
  if ((pt1 == NULL) || (pt2 == NULL) || (pt3 == NULL)) goto wrapup;

  // Vectors and dot product
  BSmkvec(&rc,vec21,pt2,pt1); MAunitvc(&rc,vec21,vec21);
  BSmkvec(&rc,vec23,pt2,pt3); MAunitvc(&rc,vec23,vec23);
  dotp = BSdotp(&rc,vec21,vec23);

  // Range check (sometimes -1.0 kicks off DOMAIN errors)
  if (dotp > 1.0) {
    //printf("dotp %f\n",dotp);
    dotp = 1.0;
  }
  if (dotp < -1.0) {
    //printf("dotp %f\n",dotp);
    dotp = -1.0;
  }
  *angle = acos(dotp);
  
  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

/* ----------------------------------------------------------------------
 * Determine if two curves should be merged for production purposes
 * the curves would be merged if a smooth curve would result
 */
IGRstat VDgeomTestProductionMerge(TGRbsp_curve *bsp1, 
				  TGRbsp_curve *bsp2,
				  IGRdouble     tol,
				  IGRdouble     len)
{
  IGRchar fn[] = "VDgeomTestProductionMerge";
  IGRstat retFlag = 0;
  
  IGRdouble dist;

  struct {
    IGRpoint  endPt,thePt;
    IGRdouble par;
    IGRdouble len;
  } crv1,crv2;
 
  IGRdouble angle = 0.0;

  IGRint traceFlagx;
  
  // Say Hi
  traceFlagx = traceFlag;
  //traceFlagx = 1;
  if (traceFlagx) printf(">>> %s\n",fn);
  
  // Arg check
  if (bsp1 == NULL) goto wrapup;
  if (bsp2 == NULL) goto wrapup;
  if (tol < VDGEOM_TOL_ZERO) tol = VDGEOM_TOL_IS_CLOSED;
  if (len < 0.0001) len = 1.0;
  
  // First, end points should match
  VDgeomGetCrvPt(bsp1,1.0,crv1.endPt);
  VDgeomGetCrvPt(bsp2,0.0,crv2.endPt);
  VDgeomGetDisPtPt(crv1.endPt,crv2.endPt,&dist);
  if (dist > tol) goto wrapup;
  
  // Want to get points len distance away from ends
  vdgeom$GetCrvArcLen(crv = bsp1, len = &crv1.len);

  // Use a percent if curve is tiny?
  if (crv1.len <= len) crv1.len *= .75;
  else                 crv1.len -= len;
  
  vdgeom$GetCrvArcParPt(crv = bsp1, len = crv1.len, par = &crv1.par, pt = crv1.thePt);

  if (traceFlagx) {  
    printf("----- Point Comparision\n");
    printf("Curve 1 length %8.2f, par %8.2f\n",crv1.len,crv1.par);
  }
  
  // Want to get points len distance away from ends
  vdgeom$GetCrvArcLen(crv = bsp2, len = &crv2.len);

  // Use a percent if curve is tiny?
  if (crv2.len <= len) crv2.len *= .25;
  else                 crv2.len  = len;
  
  vdgeom$GetCrvArcParPt(crv = bsp2, len = crv2.len, par = &crv2.par, pt = crv2.thePt);

  // Determine the angle
  VDgeomGetAngleFrom3Points(crv1.thePt,crv1.endPt,crv2.thePt,&angle);
  angle = VDgeomRadToDeg(angle);

  if (traceFlagx) {
    
    printf("Production Point %8.2f,%8.2f,%8.2f\n",
	   crv1.thePt[0],
	   crv1.thePt[1],
	   crv1.thePt[2]);

    printf("Production Point %8.2f,%8.2f,%8.2f\n",
	   crv2.thePt[0],
	   crv2.thePt[1],
	   crv2.thePt[2]);

    printf("Production Point %8.2f,%8.2f,%8.2f, Angle %8.2f\n",
	   crv1.endPt[0],
	   crv1.endPt[1],
	   crv1.endPt[2],angle);
  }
  
  if (angle < 179.0) goto wrapup;
  
  // Done
  retFlag = 1;
  
wrapup:
  if (traceFlagx) printf("<<< %s %.2f %d\n",fn,angle,retFlag);
  
  return retFlag;
}


/* -----------------------------------------------
 * Given 3 parameter values, find the angle between
 * the two segments
 */
IGRstat VDgeomGetCurveAngle(TGRbsp_curve *crv, 
			    IGRdouble     par1, 
			    IGRdouble     par2, 
			    IGRdouble     par3, 
			    IGRdouble    *angle) 
{
  IGRstat retFlag = 0;
  BSrc    rc;
  
  IGRpoint pt1,pt2,pt3;
  
  // Arg check
  if (angle == NULL) goto wrapup;
  *angle = 0.0;
  if (crv == NULL) goto wrapup;

  // Three points
  VDgeomGetCrvPt(crv,par1,pt1);
  VDgeomGetCrvPt(crv,par2,pt2);
  VDgeomGetCrvPt(crv,par3,pt3);

  // Get the angle
  VDgeomGetAngleFrom3Points(pt1,pt2,pt3,angle);
  
  // Done
  retFlag = 1;
  
wrapup:
  return retFlag;
}


/* -----------------------------------------------
 * Test the angle processor
 */
IGRstat VDgeomTestAngle(TGRobj_env *objOE)
{
  IGRstat retFlag = 0;
  
  TVDgeomKnots knots;
  IGRdouble    bufKnots[256];
  
  TGRbsp_curve *crv = NULL;

  IGRdouble par1,par2,par3,angle;
  
  // Init
  VDgeomInitKnots(&knots,bufKnots,256);
  
  // Arg check
  printf(">>> ------- VDgeomTestAngle --------\n");
  if (objOE == NULL) goto wrapup;
  
  // Get the geomotry
  vdgeom$Get2(objOE = objOE, crv = &crv);
  if (crv == NULL) goto wrapup;
  vdgeom$Print(crv = crv);
  
  // Get some knots
  vdgeom$GetKnotsFromCurve(crv = crv,knots = &knots);
  
  // Cycle through
  for(knots.i = 2; knots.i < knots.cnt; knots.i++) {

    par1 = knots.knots[knots.i-2];
    par2 = knots.knots[knots.i-1];
    par3 = knots.knots[knots.i-0];
    
    VDgeomGetCurveAngle(crv,par1,par2,par3,&angle);
    angle = VDgeomRadToDeg(angle);
    printf("PARS  %3d, P1 %8.4f, P2 %8.4f, P3 %8.4f %12.4f\n",
	   knots.i,par1,par2,par3,angle);
  }
  
  // Done
  retFlag = 1;
  
wrapup:

  // The curve
  _FREE(crv);
  
  // May have allocated knots
  VDgeomFreeKnots(&knots);

  return retFlag;
}

end implementation Root;
