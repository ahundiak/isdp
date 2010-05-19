/* $Id: VDvalGeom.c,v 1.3 2001/11/16 14:58:38 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdval/x3/VDvalGeom.c
 *
 * Description:	Piece geometry routines
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDvalGeom.c,v $
 *      Revision 1.3  2001/11/16 14:58:38  ahundiak
 *      ah
 *
 *      Revision 1.2  2001/11/09 15:01:40  ahundiak
 *      ah
 *
 *      Revision 1.1  2001/10/16 15:10:40  ahundiak
 *      ah
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 09/24/01  ah      Creation
 ***************************************************************************/
#include "VDtypedefc.h"
#include "VDassert.h"
#include "VDlog.h"
#include "VDtest.h"
#include "VDgeomc.h"
#include "VDctx.h"
#include "VDval.h"
#include "VDvalLike.h"
#include "VDss.h"
#include "stdarg.h"
#include "glib.h"

VDASSERT_FFN("VDvalGeom.c");

/* -----------------------------------------------
 * Wrap a few common attrributes
 */
static void getKey(TGRid *nodeID, IGRchar *key)
{
  VDctxGetTxtAtr(nodeID,VDCTX_ATR_SS_PIECE_PCMK_KEY,key);
  return;
}
static void getTranInfo(TGRid *nodeID, TVDvalSrfTranInfo **info)
{
  VDctxGetBinAtr(nodeID,"tran_info2",(void**)info);
  return;
}

/* -----------------------------------------------
 * Take a single transformed point and see if it
 * matches a list of curves
 */
static pt_last_index;
static IGRstat compareCurvePoint(IGRdouble tol,
				 IGRpoint  pt,
				 IGRint    cnt,
				 TGRbsp_curve **crvs)
{
  VDASSERT_FN("compareCurvePoint");
  
  IGRstat  retFlag = 0;
  IGRstat  sts;

  IGRdouble dis;
  IGRint    i;

  // As a trick, try the last index that matched
  if (pt_last_index < cnt) {
    VDgeom2GetDisPtCrv(pt,crvs[pt_last_index],&dis);
    if (dis <= tol) {
      retFlag = 1;
      goto wrapup;
    }
    if (traceFlag) printf("%s failed by %.3f\n",fn,dis);
  }
  
  // Cycle through
  for(i = 0; i < cnt; i++) {
    VDgeom2GetDisPtCrv(pt,crvs[i],&dis);
    if (dis <= tol) {
      pt_last_index = i;
      retFlag = 1;
      goto wrapup;
    }
    if (traceFlag) printf("%s failed by %.3f\n",fn,dis);    
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
static IGRstat compareCurve(IGRdouble      tol,
			    IGRint         segments,
			    IGRpoint       center1,
			    IGRpoint       center2,
			    TVDgeomMat3x3  mat,
			    TGRbsp_curve  *crv,
			    IGRint         cnt,
			    TGRbsp_curve **crvs)
{
  VDASSERT_FN("compareCurve");
  
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
    VDgeom2GetCrvPt(crv,pars[i],pt1);
      
    // Transform
    VDgeom2TransformPt(center1,center2,mat,pt1,pt2);
    
    // Test it
    sts = compareCurvePoint(tol,pt2,cnt,crvs);
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
static IGRstat compareNodeGeometry2(TGRid *node1ID,
				    TGRid *node2ID,
				    TVDvalSrfTranInfo  *info1,
				    TVDvalSrfTranInfo  *info2,
				    IGRdouble           tol,
				    TVDgeomMat3x3       mat)
{
  VDASSERT_FN("compareNodeGeometry2");
  
  IGRstat  retFlag = 0;
  IGRstat  sts;
  IGRint   i;

  // Say hi
  if (traceFlag) printf(">>> %s\n",fn);
 
  // Check outer edges
  sts = compareCurve(tol,32,
		     info1->center,
		     info2->center,
		     mat,
		     info1->contour.crv,
		     1,
		     &info2->contour.crv);
  if (sts == 0) {
    if (traceFlag) printf("VDefpCompareSrfTranInfoCrv failed for outer contour\n");
    goto wrapup;
  }
  
  // Compare inner cutouts
  for(i = 0; i < info1->inner.cnt; i++) {
    sts = compareCurve(tol,16,
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
    sts = compareCurve(tol,16,
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
    sts = compareCurve(tol,16,
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
static IGRstat compareNodeGeometry1(TGRid *node1ID,
				    TGRid *node2ID,
				    TVDvalSrfTranInfo *info1,
				    TVDvalSrfTranInfo *info2,
				    IGRdouble       bs_tol,
				    IGRdouble       minorPar,
				    IGRpoint        minorPt,
				    IGRdouble       minorMajorLen,
				    TVDgeomMat3x3   mat)
{
  VDASSERT_FN("compareNodeGeometry1");

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

  // Say hi
  if (traceFlag) {
    printf(">>> %s %.2f %.2f\n",fn,minorPar,minorMajorLen);
  }

  /* -------------------------------------------
   * Calculate proposed major point using the minor point
   * and the arc length
   */
  crv = info2->contour.crv;
  
  // Need arc length to minor pt
  VDgeom2GetCrvArcLen(crv,0.0,minorPar,&arc1);
  
  arc2 = arc1 + minorMajorLen;
  if (arc2 > info2->contour.len) arc2 -= info2->contour.len;
  if (arc2 < 0.0) arc2 = info2->contour.len + arc2;
  
  VDgeom2GetCrvArcParPt(crv,0.0,1.0,arc2,NULL,majorPt);
  
  // Distance from center to the major should match
#if 0
  VDgeom2GetDisPtPt(info2->center,majorPt,&dis);
  delta = fabs(info1->center_major_distance - dis);
  if (delta > bs_tol) {
    if (traceFlag | 1) {
      printf("Major distances do not match %.4f %.4f\n",
	     info1->center_major_distance,dis);
    }
    
    goto wrapup;
  }
#endif

  // Calc the matrix
  VDgeom2GetTranForPts(info1->center,info1->minor,info1->major,
		       info2->center,minorPt,majorPt,mat);
  
  // See if the curves really match
  sts = compareNodeGeometry2(node1ID,node2ID,info1,info2,bs_tol,mat);
  if (sts == 0) {  
    if (traceFlag) {
      printf("+++ %s failed for \n",fn);
      printf("Minor %8.2f,%8.2f,%8.2f\n",minorPt[0],minorPt[1],minorPt[2]);
      printf("Major %8.2f,%8.2f,%8.2f\n",majorPt[0],majorPt[1],majorPt[2]);
    }
    goto wrapup;
  }
  
  // Done
  retFlag = 1;
  
 wrapup:
  if (traceFlag) printf("<<< %s %d\n",fn,retFlag); 
  return retFlag;
}

/* -----------------------------------------------
 * Does a one way comparision with node 1 and 2
 */
static IGRstat compareNodeGeometry0(TGRid         *node1ID,
				    TGRid         *node2ID,
				    TVDvalSrfTranInfo *info1,
				    TVDvalSrfTranInfo *info2,
				    IGRdouble      bs_tol,
				    TVDgeomMat3x3  mat)
{
  VDASSERT_FN("compareNodeGeometry0");
  
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

  TGRbsp_curve *crv1,*crv2;

  IGRdouble *pts1;
  IGRdouble *pts2;

  IGRdouble *val1;
  IGRdouble *val2;
  
  // Say hi
  if (traceFlag) printf(">>> %s\n",fn);

  // Try each possible min distance point
  BSmdistptcv(info2->contour.crv,info2->center,&k,&n,&pars,&dis,&intpars,&rc);
  if (traceFlag) {
    printf("Number min points %d\n",n);
  }  
  for(i = 0; i < n; i++) {
    
    // Try each possible minor point
    par = pars[i];
    
    // Proposed Minor Point
    VDgeom2GetCrvPt(info2->contour.crv,par,minor);
   
    // Proposed Direction
    arclen = info1->minor_major_distance;
    sts = compareNodeGeometry1(node1ID,node2ID,info1,info2,bs_tol,par,minor,arclen,mat);
    if (sts & 1) {
      retFlag = 1;
      goto wrapup;
    }
    
    // Try the other way
    arclen *= -1.0; 
    sts = compareNodeGeometry1(node1ID,node2ID,info1,info2,bs_tol,par,minor,arclen,mat);
    if (sts & 1) {
      retFlag = 1;
      goto wrapup;
    }
  }


  // They do not match
  retFlag = 0;
  
 wrapup:

  // Return matrix
  
  if (pars)    free(pars);
  if (intpars) free(intpars);
  
  if (traceFlag) printf("<<< %s %d\n",fn,retFlag);
  return retFlag;
}

/* -----------------------------------------------
 * Compare the geometry of these two nodes to determine
 * if they are like
 * returns an optional martix
 *
 * Automatically add a tran_info2 attribute for future caching
 */
IGRstat VDvalCompareNodeGeometry(TGRid         *node1ID,
				 TGRid         *node2ID,
				 IGRdouble      bs_tol,
				 TVDgeomMat3x3  a_mat)
{
  VDASSERT_FN("VDvalCompareNodeGeometry");
  
  IGRstat    retFlag = 0;
  IGRstat    sts;
  
  TVDgeomMat3x3 mat;

  TVDvalSrfTranInfo *info1 = NULL;
  TVDvalSrfTranInfo *info2 = NULL;
  
  // Say hi
  // traceFlagx = traceFlag = 1;  
  if (traceFlag) printf(">>> %s\n",fn);

  printf(">>> %s %ld %ld\n",fn,node1ID->objid,node2ID->objid);
  
  // Arg check
  VDASSERTW(node1ID && node1ID->objid != NULL_OBJID);
  VDASSERTW(node2ID && node2ID->objid != NULL_OBJID);

  // The infos should be set
  getTranInfo(node1ID,&info1);
  if (info1 == NULL) {
    sts = VDvalGenerateLikePartInfo(node1ID);
    if (sts == 0) goto wrapup;
    getTranInfo(node1ID,&info1);
  }
  getTranInfo(node2ID,&info2);
  if (info2 == NULL) {
    sts = VDvalGenerateLikePartInfo(node2ID);
    if (sts == 0) goto wrapup;
    getTranInfo(node2ID,&info2);
  }
  VDASSERTW(info1 && info2);

  // The various lengths work both ways

  // Check backwards first
  sts = compareNodeGeometry0(node1ID,node2ID,
			     info1,info2,
			     bs_tol,mat);
  
  if (sts == 0) goto wrapup;
  
  // Check forwards
  sts = compareNodeGeometry0(node2ID,node1ID,
			     info2,info1,
			     bs_tol,mat);  
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
 * Given a piece node, construct all the binary
 * attributes needed for like part checking
 */
IGRstat VDvalGenerateLikePartInfo(TGRid *pieceID)
{
  VDASSERT_FN("VDvalGenerateLikePartInfo");
  IGRstat retFlag = 0;
  IGRstat sts;
  
  TGRbsp_curve *crv = NULL;
  IGRchar      *buf = NULL;
  
  IGRchar txt[128];

  TVDvalSrfTranInfo *info = NULL;

  IGRdouble par0,par1;
  
  // Arg check
  VDASSERTW(pieceID && pieceID->objid != NULL_OBJID);
  
  // See if already have it
  getTranInfo(pieceID,&info);
  if (info) {
    retFlag = 1;
    goto wrapup;
  }
  
  // Overall collector
  info = g_new0(TVDvalSrfTranInfo,1);
  VDctxAppBinAtr(pieceID,"tran_info2",info,NULL);
  
  // Start with contour geometry
  VDctxGetBinAtr(pieceID,"outer_contour",(void**)&crv);
  if (crv == NULL) {  
    VDctxGetTxtAtrPtr(pieceID,"outer_contour",&buf);
    VDvalConvertTextToBspCurve(buf,&crv);
    VDASSERTW(crv);
    VDctxSetBinAtr(pieceID,"outer_contour",crv,NULL);
  }
  info->contour.crv = crv;
  
  // Need reference points
  sts = VDgeom2GetCrvCMM(crv,90.0,10.0,info->center,info->minor,info->major);
  VDASSERTW(sts == 1);

  // Area
  VDctxGetTxtAtr(pieceID,VDCTX_ATR_SS_PLATE_AREA,txt);
  info->contour.area = atof(txt);

  // Calc from curve is the plate attribute is not available
  if (info->contour.area < .01) {
    //VDgeom2GetCurveArea(crv,&info->contour.area);
  }
  
  // Edge length
  VDgeom2GetCrvArcLen(crv,0.0,1.0,&info->contour.len);
  
  // Dis center to minor and major axis
  VDgeom2GetDisPtPt(info->center,info->minor,&info->center_minor_distance);
  VDgeom2GetDisPtPt(info->center,info->major,&info->center_major_distance);

  // Want included arc length from minor to major
  VDgeom2GetParPtCrv(info->minor,info->contour.crv,&par0);
  VDgeom2GetParPtCrv(info->major,info->contour.crv,&par1);
  VDgeom2GetCrvArcLen(info->contour.crv,par0,par1,&info->minor_major_distance);
  
  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}
