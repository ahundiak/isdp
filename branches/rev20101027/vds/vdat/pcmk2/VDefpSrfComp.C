/***************************************************************************
 * I/VDS
 *
 * File:        vdefp/VDefpSrfComp.I
 *
 * Description: Tran Surface Compare Routines
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDefpSrfComp.C,v $
 *      Revision 1.5  2001/07/23 16:20:03  ahundiak
 *      ah
 *
 *      Revision 1.4  2001/03/22 18:45:51  ahundiak
 *      ah
 *
 *      Revision 1.3  2001/03/19 16:03:29  ahundiak
 *      ah
 *
 *      Revision 1.2  2001/03/18 22:50:49  ahundiak
 *      ah
 *
 *      Revision 1.1  2001/03/16 17:10:46  ahundiak
 *      *** empty log message ***
 *
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 03/15/01  ah      Creation
 ***************************************************************************/
#include "VDtypedef.h"
#include "VDassert.h"
#include "VDlog.h"

#include "VDgeom.h"
#include "VDefp.h"
#include "VDefpSrf.h"
#include "VDobj.h"
#include "VDmem.h"

VDASSERT_FFN("VDefpSrfComp.C");

/* -----------------------------------------------
 * Take a single transformed point and see if it
 * matches a list of curves
 */
static pt_last_index;
IGRstat VDefpCompareSrfTranInfoCrvPt(IGRdouble tol,
				     IGRpoint  pt,
				     IGRint    cnt,
				     TGRbsp_curve **crvs)
{
  VDASSERT_FN("VDefpCompareSrfTranInfoCrvPt");
  
  IGRstat  retFlag = 0;
  IGRstat  sts;

  IGRdouble dis;
  IGRint    i;

  // As a trick, try the last index that matched
  if (pt_last_index < cnt) {
    VDgeomGetDisPtCrv(pt,crvs[pt_last_index],&dis);
    if (dis <= tol) {
      retFlag = 1;
      goto wrapup;
    }
    if (traceFlag) printf("VDefpCompareSrfTranInfoCrvPt failed by %.3f\n",dis);
  }
  
  // Cycle through
  for(i = 0; i < cnt; i++) {
    VDgeomGetDisPtCrv(pt,crvs[i],&dis);
    if (dis <= tol) {
      pt_last_index = i;
      retFlag = 1;
      goto wrapup;
    }
    if (traceFlag) printf("VDefpCompareSrfTranInfoCrvPt failed by %.3f\n",dis);    
  }
  
  // No hits
 wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Compare a bunch of points from one curve
 * against an array of curves, 
 * retFlag is 1 as long as the points map somewhere
 */
IGRstat VDefpCompareSrfTranInfoCrv(IGRdouble      tol,
				   IGRint         segments,
				   IGRpoint       center1,
				   IGRpoint       center2,
				   TVDgeomMat3x3  mat,
				   TGRbsp_curve  *crv,
				   IGRint         cnt,
				   TGRbsp_curve **crvs)
{
  VDASSERT_FN("VDefpCompareSrfTranInfoCrv");
  
  IGRstat  retFlag = 0;
  IGRstat  sts;
  
  IGRint     i;
  IGRpoint   pt1,pt2;
  
  IGRdouble  pars[256];
  IGRdouble  par0 = 0.0;
  IGRdouble  par1 = 1.0;

  BSrc rc;
  
  // Say hi
  if (traceFlag) printf(">>> %s\n",fn);

  // Chop and try each point
  BSdividecv(&rc,crv,&par0,&par1,&segments,pars); 
  for(i = 0; i < segments; i++) {
      
    // Get it
    VDgeomGetCrvPt(crv,pars[i],pt1);
      
    // Transform
    VDgeomTransformPt(center1,center2,mat,pt1,pt2);
    
    // Test it
    sts = VDefpCompareSrfTranInfoCrvPt(tol,pt2,cnt,crvs);
    if (sts == 0) {
      if (traceFlag) {
	printf("From %10.2f %10.2f %10.2f\n",pt1[0],pt1[1],pt1[2]);
	printf("To   %10.2f %10.2f %10.2f\n",pt2[0],pt2[1],pt2[2]);
      }
      goto wrapup; 
    }
  }

  // Done
  retFlag = 1;
  
 wrapup:
  if (traceFlag) printf("<<< %s\n",fn);
  return retFlag;
}

/* -----------------------------------------------
 * Compare the two edges using the proposed matrix
 * By this time there is a pretty good chance they will match
 */
IGRstat VDefpCompareSrfTranInfo2(IGRdouble           tol,
				 TVDefpSrfTranInfo  *info1,
				 TVDefpSrfTranInfo  *info2,
				 TVDgeomMat3x3       mat)
{
  VDASSERT_FN("VDefpCompareSrfTranInfo2");
  
  IGRstat  retFlag = 0;
  IGRstat  sts;
  IGRint   i;

  // Say hi
  if (traceFlag) printf(">>> %s\n",fn);
 
  // Check outer edges
  sts = VDefpCompareSrfTranInfoCrv(tol,32,
				   info1->center,
				   info2->center,
				   mat,
				   info1->edgeBsp,
				   1,
				   &info2->edgeBsp);
  if (sts == 0) {
    if (traceFlag) printf("VDefpCompareSrfTranInfoCrv failed for outer contour\n");
    goto wrapup;
  }
  
  // Compare inner cutouts
  for(i = 0; i < info1->inner.cnt; i++) {
    sts = VDefpCompareSrfTranInfoCrv(tol,16,
				     info1->center,
				     info2->center,
				     mat,
				     info1->inner.bsps[i],
				     info2->inner.cnt,
				     info2->inner.bsps);

    if (sts == 0) {
      goto wrapup;
    }
  }
  // Compare top flange
  for(i = 0; i < info1->flange1.cnt; i++) {
    sts = VDefpCompareSrfTranInfoCrv(tol,16,
				     info1->center,
				     info2->center,
				     mat,
				     info1->flange1.bsps[i],
				     info2->flange1.cnt,
				     info2->flange1.bsps);

    if (sts == 0) {
      goto wrapup;
    }
  }
  // Compare bot flange
  for(i = 0; i < info1->flange2.cnt; i++) {
    sts = VDefpCompareSrfTranInfoCrv(tol,16,
				     info1->center,
				     info2->center,
				     mat,
				     info1->flange2.bsps[i],
				     info2->flange2.cnt,
				     info2->flange2.bsps);

    if (sts == 0) {
      goto wrapup;
    }
  }
  
  // Done
  retFlag = 1;
  
 wrapup:
  if (traceFlag) printf("<<< %s\n",fn);
  return retFlag;
}

/* -----------------------------------------------
 * Have one par parameter for minor point on
 * the second piece
 */
IGRstat VDefpCompareSrfTranInfo1(IGRdouble       bs_tol,
				 TVDefpSrfTranInfo *info1,
				 TVDefpSrfTranInfo *info2,
				 IGRdouble       minorPar,
				 IGRpoint        minorPt,
				 IGRdouble       minorMajorLen,
				 TVDgeomMat3x3   mat)
{
  VDASSERT_FN("VDefpCompareSrfTranInfo1");

  IGRstat      retFlag = 0;
  IGRstat      sts;
  
  IGRpoint     majorPt;
  IGRdouble    dis,delta;
  
  IGRdouble    arc1,arc2;
  TGRbsp_curve *crv;

  IGRvector    vec1,vec2;
  IGRvector    normal;
  
  IGRint       i;
  BSrc         rc;

  IGRshort       three = 3;
  TVDgeomMat3x3  inv_mat;

  // Say hi
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
  VDgeomGetTranForPts(info1->center,info1->minor,info1->major,
		      info2->center,minorPt,majorPt,mat);
  
  // See if the curves really match
  sts = VDefpCompareSrfTranInfo2(bs_tol,info1,info2,mat);
  if (sts == 0) {  
    if (traceFlag) {
      printf("+++ %s failed for \n",fn);
      printf("Minor %8.2f,%8.2f,%8.2f\n",minorPt[0],minorPt[1],minorPt[2]);
      printf("Major %8.2f,%8.2f,%8.2f\n",majorPt[0],majorPt[1],majorPt[2]);
    }
    goto wrapup;
  }
  
  // Reverse and try the other direction
  // Mainly to pick up cutouts in the second plate
  // This is now done at a higher level
#if 0
  three = 3;
  MAinvmx( &sts, &three, mat, inv_mat );

  sts = VDefpCompareSrfTranInfo2(bs_tol,info2,info1,inv_mat);
  if (sts == 0) {  
    if (traceFlag) {
      printf("+++ %s failed for \n",fn);
      printf("Minor %8.2f,%8.2f,%8.2f\n",minorPt[0],minorPt[1],minorPt[2]);
      printf("Major %8.2f,%8.2f,%8.2f\n",majorPt[0],majorPt[1],majorPt[2]);
    }
    goto wrapup;
  }
#endif

  // Done
  retFlag = 1;
  
 wrapup:
  if (traceFlag) printf("<<< %s %d\n",fn,retFlag); 
  return retFlag;
}

/* -----------------------------------------------
 * At this stage, have two srf tran info structures
 * See if the pieces are alike
 * Return translation matrix if so
 */
IGRstat VDefpCompareSrfTranInfo0(IGRdouble          bs_tol,
				TVDefpSrfTranInfo *info1,
				TVDefpSrfTranInfo *info2,
				TVDgeomMat3x3      a_mat)
{
  VDASSERT_FN("VDefpCompareSrfTranInfo0");
  
  IGRstat    retFlag = 0;
  IGRstat    sts;
  
  IGRdouble  delta;
  IGRint     i;
  
  // The min dist is the minor axis
  IGRshort   k,n;
  IGRdouble  dis;
  IGRdouble  par;
  IGRdouble  *pars    = NULL;
  IGRdouble  *intpars = NULL;
  BSrc       rc;
  
  IGRpoint   minor;
  IGRdouble  arclen;

  TVDgeomMat3x3 mat;
  
  // Say hi
  traceFlagx = traceFlag = 0;  
  if (traceFlag) printf(">>> %s\n",fn);
  
  // Arg check
  VDASSERTW(info1 && info1->edgeBsp);
  VDASSERTW(info2 && info2->edgeBsp);
  
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
  
  // Cutout distance should match
  delta = fabs(info1->cutout_distance - info2->cutout_distance);
  if (delta > bs_tol) {
    if (traceFlag) {
      printf("Cutout Distance do not match %.4f %.4f\n",
	     info1->cutout_distance,
	     info2->cutout_distance);
    }
    goto wrapup;
  }

  // Try each possible min distance point
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
    sts = VDefpCompareSrfTranInfo1(bs_tol,info1,info2,par,minor,arclen,mat);
    if (sts & 1) {
      retFlag = 1;
      goto wrapup;
    }
    
    // Try the other way
    arclen *= -1.0; 
    sts = VDefpCompareSrfTranInfo1(bs_tol,info1,info2,par,minor,arclen,mat);
    if (sts & 1) {
      retFlag = 1;
      goto wrapup;
    }
  }
  
  // They do not match
  retFlag = 0;
  
 wrapup:

  // Return matric
  if (a_mat) memcpy(a_mat,mat,sizeof(TVDgeomMat3x3));
  
  _FREE(pars);
  _FREE(intpars);
  
  if (traceFlag) printf("<<< %s %d\n",fn,retFlag);
  return retFlag;
}

/* -----------------------------------------------
 * At this stage, have two srf tran info structures
 * See if the pieces are alike
 * Return translation matrix if so
 *
 * It's important that the routine be absoutly bi-directional
 * there are rare cases where a matches b but b does not match a
 * It's expensive but just do a complete check in both directions
 */
IGRstat VDefpCompareSrfTranInfo(IGRdouble          bs_tol,
				TVDefpSrfTranInfo *info1,
				TVDefpSrfTranInfo *info2,
				TVDgeomMat3x3      a_mat)
{
  VDASSERT_FN("VDefpCompareSrfTranInfo");
  
  IGRstat    retFlag = 0;
  IGRstat    sts;
  
  TVDgeomMat3x3 mat;
    
  // Say hi
  traceFlagx = traceFlag = 0;  
  if (traceFlag) printf(">>> %s\n",fn);
  
  // Arg check
  VDASSERTW(info1 && info1->edgeBsp);
  VDASSERTW(info2 && info2->edgeBsp);

  // Check backwards first
  sts = VDefpCompareSrfTranInfo0(bs_tol,info2,info1,mat);
  if (sts == 0) goto wrapup;
  
  // Check forwards
  sts = VDefpCompareSrfTranInfo0(bs_tol,info1,info2,mat);
  if (sts == 0) goto wrapup;

  // They match
  retFlag = 1;
  
 wrapup:

  // Return optional matrix
  if (a_mat) memcpy(a_mat,mat,sizeof(TVDgeomMat3x3));
  
  if (traceFlag) printf("<<< %s %d\n",fn,retFlag);
  return retFlag;
}

/* -----------------------------------------------
 * Compute transformation between two plates
 */
IGRstat VDefpComputeCrvTran2(TGRobj_env *macOE,
			     IGRint     opFlag,
			     IGRint     *feetCntx,
			     TGRid      *feetIDs)
{
  VDASSERT_FN("VDefpComputeSrfTran2");
  
  IGRstat        retFlag = 0;
  IGRstat        sts,sts1,sts2;

  TVDefpSrfTranInfo info1,info2;
  
  TGRobj_env     piece1OE,piece2OE;
  IGRpoint       pts[20];
  
  IGRint         i;
  IGRint         feetCnt = 0;
  
  BSrc           rc;
  TGRmd_env      *env;
  TVDgeomMat3x3  mat;
  
  // Init
  VDefpInitSrfTranInfo(&info1);
  VDefpInitSrfTranInfo(&info2);
 
  // Arg check
  VDASSERTW(feetCntx); *feetCntx = 0;
  VDASSERTW(feetIDs);
  VDASSERTW(macOE);
  
  env = &macOE->mod_env;
  
  // Get 1st parent, 
  vdobj$GetTemplate(objOE      = macOE,
                    nth        = VDEFP_CRV_TRAN2_TEMP_IDX_PLATE1,
                    templateOE = &piece1OE);
  
  VDASSERTW(piece1OE.obj_id.objid != NULL_OBJID);
  
  // Get 2nd parent, 
  vdobj$GetTemplate(objOE      = macOE,
                    nth        = VDEFP_CRV_TRAN2_TEMP_IDX_PLATE2,
                    templateOE = &piece2OE);
  
  VDASSERTW(piece2OE.obj_id.objid != NULL_OBJID);
  
  // Get the info
  VDefpGetSrfTranInfo(&piece1OE,&info1);
  VDASSERTW(info1.edgeBsp);
  
  // Get the info
  VDefpGetSrfTranInfo(&piece2OE,&info2);
  VDASSERTW(info2.edgeBsp);
    
  // Create Contour Object
  VDdrawCurve(info1.edgeBsp,env,&feetIDs[feetCnt]);
  VDASSERTW(feetIDs[feetCnt].objid != NULL_OBJID);
  feetCnt++;
  
  VDdrawCurve(info2.edgeBsp,env,&feetIDs[feetCnt]);
  VDASSERTW(feetIDs[feetCnt].objid != NULL_OBJID);
  feetCnt++;
  
  // Show useful points
  VDgeomCpyPt(info1.center,pts[0]);
  VDgeomCpyPt(info1.minor, pts[1]);
  VDgeomCpyPt(info1.major, pts[2]);
  VDgeomCpyPt(info1.center,pts[3]);
  
  VDgeomCpyPt(info2.center,pts[4]);
  VDgeomCpyPt(info2.minor, pts[5]);
  VDgeomCpyPt(info2.major, pts[6]);
  VDgeomCpyPt(info2.center,pts[7]);
  
  VDdrawLinear(8,(IGRdouble*)pts,env,&feetIDs[feetCnt]);
  VDASSERTW(feetIDs[feetCnt].objid != NULL_OBJID);
  feetCnt++;
  
  // Are they like
  sts = VDefpCompareSrfTranInfo(2.0,&info1,&info2,mat);
  if (sts & 1) {
    
    UI_status("Like Parts V2");
    
    // Try a transformation
    for(i = 0; i < 4; i++) {
      VDgeomTransformPt(info1.center,info2.center,mat,pts[i],pts[i]);
      
    }
    VDdrawLinear(4,(IGRdouble*)pts,env,&feetIDs[feetCnt]);
    VDASSERTW(feetIDs[feetCnt].objid != NULL_OBJID);
    feetCnt++;
  }
  else UI_status("Not Like V2");
  
  // Done
  *feetCntx = feetCnt;
  retFlag = 1;
  
 wrapup:
  
  // Free edges
  VDefpFreeSrfTranInfo(&info1);
  VDefpFreeSrfTranInfo(&info2);
  
  return retFlag;
}

