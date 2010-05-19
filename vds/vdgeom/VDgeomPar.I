/* $Id: VDgeomPar.I,v 1.1 2001/01/11 18:41:18 art Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdah/VDgeomPar.I
 *
 * Description:	Parametric (circle and oval) processing
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDgeomPar.I,v $
 *      Revision 1.1  2001/01/11 18:41:18  art
 *      sp merge
 *
# Revision 1.3  2000/04/28  19:32:24  pinnacle
# ah
#
# Revision 1.2  2000/04/25  16:15:56  pinnacle
# ah
#
# Revision 1.1  2000/04/11  17:14:28  pinnacle
# ah
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 04/17/00  ah      Creation
 ***************************************************************************/
class implementation Root;

#include "VDtypedef.h"
#include "VDobj.h"
#include "VDmem.h"
#include "VDgeom.h"

static int traceFlag;

from GRcurve import GRendpts;

/* -----------------------------------------------
 * Checks to see if a curve object is physically closed
 * with respect to the tolerance.  Sometimes the phy_closed property
 * does not get set when a curve is closed for production reasons
 */
IGRstat VDgeomIsCurveObjectClosed(TGRobj_env *crvOE, IGRdouble tol, IGRint *closed)
{
  IGRstat retFlag = 0;
  IGRstat sts,msg;

  IGRpoint pt1,pt2;
  IGRdouble dist = -1.0;
  
  // Arg check
  if (closed == NULL) goto wrapup;
  *closed = 0;
  if (crvOE == NULL) goto wrapup;
  if (tol < VDGEOM_TOL_ZERO) tol = VDGEOM_TOL_IS_CLOSED;
  
  // Grab the end points
  sts = om$send(msg = message GRcurve.
		GRendpts(&msg,
			 &crvOE->mod_env.md_env.matrix_type,
			  crvOE->mod_env.md_env.matrix,
			 pt1,pt2),
		senderid = NULL_OBJID,
		targetid = crvOE->obj_id.objid,
		targetos = crvOE->obj_id.osnum);
  if (!(sts & msg & 1)) goto wrapup;
  
  // Check distance within tolerance
  VDgeomGetDisPtPt(pt1,pt2,&dist);
  if (dist > tol) goto wrapup;
  
  // It's closed
  *closed = 1;
  retFlag = 1;
  
 wrapup:
#if 0
  printf("Distance %12.4f %d\n",dist,retFlag);
  printf("Point 1  %12.4f %12.4f %12.4f\n",pt1[0],pt1[1],pt1[2]);
  printf("Point 2  %12.4f %12.4f %12.4f\n",pt2[0],pt2[1],pt2[2]);
#endif
  return retFlag;
}

/* -----------------------------------------------
 * Checks to see if a curve is physically closed
 * with respect to the tolerance.  Sometimes the phy_closed property
 * does not get set when a curve is closed for production reasons
 */
IGRstat VDgeomIsCurveClosed(TGRbsp_curve *crv, IGRdouble tol, IGRint *closed)
{
  IGRstat retFlag = 0;
  IGRstat sts,msg;

  IGRpoint pt1,pt2;
  IGRdouble dist = -1.0;
  
  // Arg check
  if (closed == NULL) goto wrapup;
  *closed = 0;
  if (crv == NULL) goto wrapup;
  if (tol < VDGEOM_TOL_ZERO) tol = VDGEOM_TOL_IS_CLOSED;
  
  // Grab the end points
  VDgeomGetCrvPt(crv,0.0,pt1);
  VDgeomGetCrvPt(crv,1.0,pt2);
  
  // Check distance within tolerance
  VDgeomGetDisPtPt(pt1,pt2,&dist);
  if (dist > tol) goto wrapup;
  
  // It's closed
  *closed = 1;
  retFlag = 1;
  
 wrapup:
#if 0
  printf("Distance %12.4f %d\n",dist,retFlag);
  printf("Point 1  %12.4f %12.4f %12.4f\n",pt1[0],pt1[1],pt1[2]);
  printf("Point 2  %12.4f %12.4f %12.4f\n",pt2[0],pt2[1],pt2[2]);
#endif
  return retFlag;
}

/* ----------------------------------------------------------------------
 * See if the two corves are the same within production tolerance
 * Check knots then check ppont by point
 *
 * Used by linear, circle checkers
 * crv2 is derived from crv1
 */
IGRstat VDgeomDoCurvesMatch(TGRbsp_curve *crv1, 
			    TGRbsp_curve *crv2,
			    IGRdouble     tol,
			    IGRint       *match)
{
  IGRchar fn[] = "VDgeomDoCurvesMatch";
  IGRstat retFlag = 0;
  IGRstat sts;
    
  IGRpoint  pt;
  
  IGRdouble totalLen,incLen,theLen;  
  IGRdouble dist;

  TVDgeomKnots knots;
  IGRdouble    knotsBuf[512];
  
  IGRint traceFlagx;

  // Init
  VDgeomInitKnots(&knots,knotsBuf,512);
  
  // Say hi
  traceFlagx = traceFlag;
  //traceFlagx = 1;
  if (traceFlagx) {
    printf(">>> %s\n",fn);
    //vdgeom$Print(crv = crv1);
    //vdgeom$Print(crv = crv2);
  }

  // Arg check
  if (match == NULL) goto wrapup;
  *match = 0;
  if (crv1 == NULL) goto wrapup;
  if (crv2 == NULL) goto wrapup;
  if (tol < VDGEOM_TOL_ZERO) tol = VDGEOM_TOL_CURVES_MATCH;
   
  // Check Knots Point
  vdgeom$GetKnotsFromCurve(crv = crv1, knots = &knots);
  for(knots.i = 0; knots.i < knots.cnt; knots.i++) {
    VDgeomGetCrvPt(crv1,knots.knots[knots.i],pt);
    VDgeomGetDisPtCv(pt,crv2, &dist);
    if (dist > tol) {
      if (traceFlagx) {
	printf("Failed knot check %2d %12.4f,%12.4f,%12.4f, Distance %.4f\n",
	       knots.i,pt[0],pt[1],pt[2],dist);
      }
      goto wrapup;
    }
    
  }
  if (traceFlagx) {
    printf("Passed knot check\n");
  }
  
  // Use points from arc length
  vdgeom$GetCrvArcLen(crv = crv1, len = &totalLen);
  if (totalLen < 1.0) {
    retFlag = 1;
    goto wrapup;
  }
  
  // Use 100 points or 1mm
  incLen = totalLen / 100.0;
  if (incLen < 1.0) incLen = 1.0;
  if (traceFlagx) {
    printf("Total Length %.2f, incLen %.2f\n",totalLen,incLen);
  }
  
  // Just march along
  for(theLen = incLen; theLen < totalLen; theLen += incLen) {

    // Check It
    vdgeom$GetCrvArcParPt(crv = crv1,len = theLen,pt = pt);
    VDgeomGetDisPtCv(pt,crv2, &dist);
    if (dist > tol) {
      if (traceFlagx) {
	printf("Failed len check %12.4f of %12.4f, Distance %12.4f\n",
	       theLen,totalLen,dist);
	printf("PT %12.4f,%12.4f,%12.4f\n",pt[0],pt[1],pt[2]);
      }
      goto wrapup;
    }
    
  }
     
  // Done
  retFlag = 1;
  
wrapup:
  VDgeomFreeKnots(&knots);
  if (traceFlagx) {
    printf("<<< %s %d\n",fn,retFlag);
  }
  if (match) *match = retFlag;
  return retFlag;
}


end implementation Root;




