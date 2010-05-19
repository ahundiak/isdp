/***************************************************************************
 * I/VDS
 *
 * File:        vdefp/VDefpCrvLike.I
 *
 * Description: Like Parts Routines
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDefpLike.I,v $
 *      Revision 1.1  2001/01/11 19:04:49  art
 *      sp merge
 *
# Revision 1.1  2000/11/27  16:53:24  pinnacle
# ah
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 11/03/00  ah      Creation
 ***************************************************************************/
class implementation Root;

#include "VDtypedef.h"
#include "VDobj.h"
#include "VDchn.h"
#include "VDexp.h"
#include "VDmem.h"
#include "VDgeom.h"
#include "VDefp.h"

#include "VDassert.h"

VDASSERT_FFN("vdefp/VDefpLike.I");
    
/* -----------------------------------------------
 * Compare the two edges using the proposed matrix
 */
IGRstat VDefpComparePlates2(IGRdouble       bs_tol,
			    TVDefpTranInfo *info1,
			    TVDefpTranInfo *info2,
			    TVDgeomMat3x3   mat)
{
  VDASSERT_FN("VDefpComparePlates2");
  
  IGRstat retFlag = 0;
  
  TGRbsp_curve *crv1,*crv2;
  
  IGRint    i,j;
  IGRpoint  pt1,pt2;
  IGRdouble dis;
  IGRdouble delta;

  IGRdouble pars[17];
  IGRint    num = 16;
  IGRdouble par0 = 0.0;
  IGRdouble par1 = 1.0;
  
  TGRid ptID;
  
  BSrc rc;
  
  // Bounce against the edge
  crv2 = info2->edgeBsp;
  retFlag = 1;
  
  // Cycle through
  for(i = 0; i < info1->edgeCnt; i++) {

    // Chop into little bits
    crv1 = info1->edgeBsps[i];
    BSdividecv(&rc,crv1,&par0,&par1,&num,pars); 

    // Try each one
    for(j = 0; j < num; j++) {
      
      VDgeomGetCrvPt(crv1,pars[j],pt1);

      // Transform
      VDgeomTransformPt(info1->center,info2->center,mat,pt1,pt2);

      // Map
      VDgeomGetDisPtCrv(pt2,crv2,&dis);
      //printf("Check Distance %2d %12.4f\n",i,dis);

      // Display
      // VDdrawLinear(1,pt2,NULL,&ptID);
      
      // Check
      if (dis > bs_tol) {
	if (traceFlag | 0) printf("*** Geometry Distance Failed %.2f\n",dis);      
	retFlag = 0;
	if (1) goto wrapup;
      }    
    }
  }
    
  // Done
  // retFlag = 1;
  
wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Have one par parameter for minor point on
 * the second plate
 */
IGRstat VDefpComparePlates1(IGRdouble       bs_tol,
			    TVDefpTranInfo *info1,
			    TVDefpTranInfo *info2,
			    IGRdouble       minorPar,
			    IGRpoint        minorPt,
			    IGRdouble       minorMajorLen,
			    TVDgeomMat3x3   mat)
{
  VDASSERT_FN("VDefpComparePlates1");

  IGRstat retFlag = 0;
  IGRstat sts;

  IGRpoint  majorPt;
  IGRdouble dis,delta;
  
  IGRdouble arc1,arc2;
  TGRbsp_curve *crv;

  IGRvector vec1,vec2;
  IGRvector normal;
  
  IGRint i;
  BSrc   rc;
  
  traceFlag = 0;
  if (traceFlag) {
    printf(">>> %s %.2f %.2f\n",fn,minorPar,minorMajorLen);
  }
  
  /* -------------------------------------------
   * Calculate proposed major point using the minor point
   * and the arc length
   */
  crv = info2->edgeBsp;
  
  // Need arc length to minor pt
  vdgeom$GetCrvArcLen(crv =  crv, par0 = 0.0, par1 = minorPar, len = &arc1);

  arc2 = arc1 + minorMajorLen;
  if (arc2 > info2->edgeLen) arc2 -= info2->edgeLen;
  if (arc2 < 0.0) arc2 = info2->edgeLen + arc2;

  vdgeom$GetCrvArcParPt(crv = crv,
			len = arc2,
			pt  = majorPt);

  // Distance from center to the major should match
  VDgeomGetDisPtPt(info2->center,majorPt,&dis);
  delta = fabs(info1->center_major_distance - dis);
  if (delta > bs_tol) {
    if (traceFlag) {
      printf("Major distances do not match %.4f %.4f\n",
	     info1->center_major_distance,dis);
    }
    
    goto wrapup;
  }

  // Calc the matrix
  VDgeomGetTranForPts(info1->center,
		      info1->minor,
		      info1->major,
		      info2->center,
		      minorPt,
		      majorPt,
		      mat);
  
  // See if the curves really match
  sts = VDefpComparePlates2(bs_tol,info1,info2,mat);
  if (sts & 1) {
    retFlag = 1;
    goto wrapup;
  }
  if (traceFlag) {
    printf("+++ VDefpComparePlates2 failed for \n");
    printf("Minor %8.2f,%8.2f,%8.2f\n",minorPt[0],minorPt[1],minorPt[2]);
    printf("Major %8.2f,%8.2f,%8.2f\n",majorPt[0],majorPt[1],majorPt[2]);
  }
  
  // Done
  retFlag = 0;
  
wrapup:
  if (traceFlag) {
    printf("<<< %s %d\n",fn,retFlag);
  }
  
  return retFlag;
}

/* -----------------------------------------------
 * At this stage, have two tran info structures
 * See if the plates are like plates
 * Return translation matrix if so
 */
IGRstat VDefpComparePlates(IGRdouble      bs_tol,
			   TVDefpTranInfo *info1,
			   TVDefpTranInfo *info2,
			   TVDgeomMat3x3  mat)
{
  VDASSERT_FN("VDefpComparePlates");

  IGRstat retFlag = 0;
  IGRstat sts;
  
  IGRdouble delta;
  IGRint    i;
  
  // The min dist is the minor axis
  IGRshort   k,n;
  IGRdouble  dis;
  IGRdouble  par;
  IGRdouble *pars    = NULL;
  IGRdouble *intpars = NULL;
  BSrc       rc;

  IGRpoint  minor;
  IGRdouble arclen;
  
  traceFlag = 0;
  
  if (traceFlag) {
    printf(">>> %s\n",fn);
  }
  
  // Arg check
  VDASSERTW(info1 && info1->edgeBsp);
  VDASSERTW(info2 && info2->edgeBsp);
  VDASSERTW(mat);
  
  // Arc lengths need to match
  delta = fabs(info1->edgeLen - info2->edgeLen);
  if (delta > bs_tol) {
    if (traceFlag) {
      printf("edgLens do not match %.4f %.4f\n",info1->edgeLen,info2->edgeLen);
    }
    goto wrapup;
  }
  
  // Min distance neds to match
  delta = fabs(info1->center_minor_distance - info2->center_minor_distance);
  if (delta > bs_tol) {
    if (traceFlag) {
	printf("Minor Distance do not match %.4f %.4f\n",
	       info1->center_minor_distance,
	       info2->center_minor_distance);
    }
    goto wrapup;
  }
  
  // Try each possible min distance point
  retFlag = 1;
  BSmdistptcv(info2->edgeBsp,info2->center,&k,&n,&pars,&dis,&intpars,&rc);
  if (traceFlag) {
    printf("Number min points %d\n",n);
  }  
  for(i = 0; i < n; i++) {
    
    // Try each possible minor point
    par = pars[i];
    
    // Proposed Minor Point
    VDgeomGetCrvPt(info2->edgeBsp,par,minor);

    // Proposed Direction
    arclen = info1->minor_major_distance;
    
    // Try it
    sts = VDefpComparePlates1(bs_tol,info1,info2,par,minor,arclen,mat);
    if (sts & 1) goto wrapup;
    
    // Try the other way
    arclen *= -1.0;

    sts = VDefpComparePlates1(bs_tol,info1,info2,par,minor,arclen,mat);
    if (sts & 1) goto wrapup;

  }
  
  // They do not match
  retFlag = 0;
  
 wrapup:

  _FREE(pars);
  _FREE(intpars);

  if (traceFlag) {
    printf("<<< %s %d\n",fn,retFlag);
  }

  return retFlag;
}

end implementation Root;
