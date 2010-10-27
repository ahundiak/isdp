/* $Id: VDefpSrfTran.C,v 1.4 2002/05/01 19:56:15 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdat/pcmk2/VDefpSrfTran.C
 *
 * Description: Form Routines
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDefpSrfTran.C,v $
 *      Revision 1.4  2002/05/01 19:56:15  ahundiak
 *      ah
 *
 *      Revision 1.3  2001/03/22 18:45:51  ahundiak
 *      ah
 *
 *      Revision 1.2  2001/03/18 22:50:50  ahundiak
 *      ah
 *
 *      Revision 1.1  2001/03/16 17:10:46  ahundiak
 *      *** empty log message ***
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 03/13/01  ah      Creation
 ***************************************************************************/

#include "VDtypedef.h"
#include "VDassert.h"
#include "VDlog.h"

#include "VDgeom.h"
#include "VDefp.h"
#include "VDefpSrf.h"

#include "VDobj.h"
#include "VDmem.h"

#include "VDobj2.h"
#include "VDvla.h"
#include "VDchn.h"

VDASSERT_FFN("VDefpSrfTran.C");

extern IGRstat VDgeom2GetSurfaceNaturalContourGeometry __((TGRobj_env     *i_srfOE,
							   IGRint          i_bspMax,
							   TGRbsp_curve  **i_bsps,
							   IGRint         *o_bspCnt,
							   TGRbsp_curve ***o_bsps));

extern IGRstat VDgeom2MergeNaturalEdges __((TGRbsp_curve **bsps, 
					    IGRint         bspCnt, 
					    IGRdouble      tol));

extern IGRstat VDgeomGetCrvCMM __((TGRbsp_curve *crv,
				   IGRdouble     incAngle,
				   IGRdouble     tolAngle,
				   IGRpoint      center,
				   IGRpoint      major,
				   IGRpoint      minor));

/* -----------------------------------------------
 * Initialize data struct
 */
void VDefpInitSrfTranInfo(TVDefpSrfTranInfo *info)
{
  VDASSERT_FN("VDefpInitSrfTranInfo");
  VDASSERTW(info);
  memset(info,0,sizeof(TVDefpSrfTranInfo));
 wrapup:
  return;
}
/* -----------------------------------------------
 * Free up data struct
 */
void VDefpFreeSrfTranInfo(TVDefpSrfTranInfo *info)
{
  VDASSERT_FN("VDefpFreeSrfTranInfo");

  IGRint i;
  
  // Arg check
  VDASSERTW(info);

  // Outer one
  _FREE(info->edgeBsp);

  // Inner
  for(i = 0; i < info->inner.cnt; i++) {
    _FREE(info->inner.bsps[i]);
  }
  _FREE(info->inner.bsps);

  // Top flange
  for(i = 0; i < info->flange1.cnt; i++) {
    _FREE(info->flange1.bsps[i]);
  }
  _FREE(info->flange1.bsps);

  // Bot flange
  for(i = 0; i < info->flange2.cnt; i++) {
    _FREE(info->flange2.bsps[i]);
  }
  _FREE(info->flange2.bsps);

  // Stock points
  _FREE(info->stockPts);
  
  // Just to be safe
  VDefpInitSrfTranInfo(info);
  
 wrapup:
  return;
}

/* -----------------------------------------------
 * Fill in some infor about the outer contour
 */
IGRstat VDefpGetSrfTranInfoOuterContour(TVDefpSrfTranInfo *info)
{
  VDASSERT_FN("VDefpGetSrfTranInfoOuterContour");
  IGRstat retFlag = 1;
  IGRstat sts;

  IGRdouble dis,par0,par1;
  BSrc rc;

  IGRpoint center;
  IGRint i;
  
  // Arg check
  VDASSERTW(info && info->edgeBsp);
  
  // Store its arc len
  vdgeom$GetCrvArcLen(crv =  info->edgeBsp, 
		      len = &info->edgeLen);
  
  // Get some points
  // VDgeomGetSymCrvAxis(info->edgeBsp,info->center,info->major,info->minor);
  VDgeomGetCrvCMM(info->edgeBsp,90.0,10.0,info->center,info->minor,info->major);
    
  // Some distances
  VDgeomGetDisPtPt(info->center,info->minor,&info->center_minor_distance);
  VDgeomGetDisPtPt(info->center,info->major,&info->center_major_distance);
  
  // Want included arc length from minor to major
  VDgeomGetDisPtParCrv(info->minor,info->edgeBsp,&dis,&par0);
  VDgeomGetDisPtParCrv(info->major,info->edgeBsp,&dis,&par1);
  vdgeom$GetCrvArcLen(crv  = info->edgeBsp,
		      par0 = par0,
		      par1 = par1,
		      len  = &info->minor_major_distance);
#if 0
  printf("Minor Par %.4f, Major Par %.4f, Distance %.4f\n",
	 par0,
	 par1,
	 info->minor_major_distance);
#endif
  
  // Some vectors
  BSmkvec(&rc,info->center_minor_vec,info->center,info->minor);
  BSmkvec(&rc,info->center_major_vec,info->center,info->major);
  
  MAunitvc(&rc,info->center_minor_vec,info->center_minor_vec);
  MAunitvc(&rc,info->center_major_vec,info->center_major_vec);
  
  BScrossp(&rc,info->center_minor_vec,info->center_major_vec,info->normal);
  
  // Like to know the angle
  VDgeomGetAngleFrom3Points(info->minor,
			    info->center,
			    info->major,
			    &info->angle);
  
  info->angle = VDgeomRadToDeg(info->angle);
  
  // Some tracing
#if 0
  printf("------ Outer Edge Info ------\n");
  printf("%-20s %-8.2f\n",
	 "Edge Length",info->edgeLen);
  printf("%-20s %-8.2f\n",
	 "Arc  Length",info->minor_major_distance);
  printf("%-20s %-8.2f %-82.f\n",
	 "Minor Distance", info->center_minor_distance,par0);
  printf("%-20s %-8.2f %-8.2f\n",
	 "Major Distance", info->center_major_distance,par1);
#endif
#if 0
  printf("------ Outer Edge Info ------\n");
  printf("Center %12.4f %12.4f %12.4f\n",info->center[0],info->center[1],info->center[2]);
  printf("Minor  %12.4f %12.4f %12.4f\n",info->minor [0],info->minor [1],info->minor [2]);
  printf("Major  %12.4f %12.4f %12.4f\n",info->major [0],info->major [1],info->major [2]);
#endif

  /* ---------------------------------------------
   * Calculate the total distance from the center 
   * of each inner cutout to the center of the surface
   * 
   * Use this number to detect most cutout position changes
   *
   * Can go away once the full geometry is saved in the snapshot
   */
  for(i = 0; i < info->inner.cnt; i++) {

    BSfndcent(info->inner.bsps[i],center,&rc);

    if (rc == BSSUCC) {
      VDgeomGetDisPtPt(info->center,center,&dis);
      info->cutout_distance += dis;
    }
  }
    
  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * From a surface, get all the contours and store them
 * If outerBsp is passed then return it and do not
 * put in the list
 */
IGRstat VDefpGetSrfTranInfoContours(TGRobj_env      *srfOE, 
				    TGRbsp_curve   **outerBsp,
				    TVDgeomListBsps *listBsps)
{
  VDASSERT_FN("VDefpGetSrfTranInfoContours");
  IGRstat retFlag = 1;
  IGRstat sts;

  TGRbsp_curve **bsps = NULL;
  IGRint i,cnt,cntx;
  IGRint ix;
  
  // Arg check
  if (outerBsp) *outerBsp = NULL;
  VDASSERTW(listBsps);
  memset(listBsps,0,sizeof(TVDgeomListBsps));
  VDASSERTW(srfOE && srfOE->obj_id.objid != NULL_OBJID);
  
  // Grab list of contours
  sts = VDgeom2GetSurfaceNaturalContourGeometry(srfOE,0,NULL,&cnt,&bsps);
  VDASSERTW(sts == 1);
  VDASSERTW(cnt);

  // Reduce em
  VDgeom2MergeNaturalEdges(bsps,cnt,.1);
  VDASSERTW(sts == 1);
  VDASSERTW(bsps[0]);

  // The first one is the merged outer contour
  if (outerBsp) {
    *outerBsp = bsps[0];
    ix = 1;
  }
  else ix = 0;
  
  // See how many inner ones have
  cntx = 0;
  for(i = ix; i < cnt; i++) { if (bsps[i]) cntx++; }
  if (cntx == 0) {
    retFlag = 1;
    goto wrapup;
  }
  
  // Xfer them over
  listBsps->bsps = calloc(cntx,sizeof(TGRbsp_curve*));
  VDASSERTW(listBsps->bsps);
  cntx = 0;
  for(i = ix; i < cnt; i++) {
    if (bsps[i]) {
      listBsps->bsps[cntx] = bsps[i];
      cntx++;
    }
  }
  listBsps->cnt = cntx;

  // Done
  retFlag = 1;
  
 wrapup:

  _FREE(bsps);
  return retFlag;
}

/* -----------------------------------------------
 * Get the info for a piece
 */
IGRstat VDefpGetSrfTranInfo(TGRobj_env *pieceOE, TVDefpSrfTranInfo *info)
{
  VDASSERT_FN("VDefpGetSrfTranInfo");
  IGRstat retFlag = 1;
  IGRstat sts;
  
  TGRobj_env srfOE;
  TGRobj_env flangeOE;
  
  IGRint isPlate = 0;
  IGRint isBeam  = 0;

  TVDvlaID  *vla = NULL;
  IGRint     i;
  TGRid      stockID;
  IGRchar    macName[32];

  // Init
  srfOE.obj_id.objid = NULL_OBJID;

  // Arg check
  VDASSERTW(info); VDefpInitSrfTranInfo(info);
  VDASSERTW(pieceOE && pieceOE->obj_id.objid != NULL_OBJID);
  
  // Need a surface
  sts = VDobjIsAncestryValid(pieceOE,NULL,OM_K_NOTUSING_CLASSID,"VSplate");
  if (sts & 1) {
    VDobjGetFoot(pieceOE,NULL,VDEFP_PLATE_BASE_SURF_NAME,&srfOE);
    VDASSERTW(srfOE.obj_id.objid != NULL_OBJID);
    isPlate = 1;
  }
  sts = VDobjIsAncestryValid(pieceOE,NULL,OM_K_NOTUSING_CLASSID,"VSbeam");
  if (sts & 1) {
    VDobjGetFoot(pieceOE,NULL,VDEFP_BEAM_WEB_LEFT_NAME,&srfOE);
    VDASSERTW(srfOE.obj_id.objid != NULL_OBJID);
    isBeam = 1;
  }
  if ((isBeam == 0) && (isPlate == 0)) goto wrapup;
  VDASSERTW(srfOE.obj_id.objid != NULL_OBJID);
  
  // Grab list of contours
  VDefpGetSrfTranInfoContours(&srfOE,&info->edgeBsp,&info->inner);
  VDASSERTW(info->edgeBsp);
  
  // Assorted points and such
  VDefpGetSrfTranInfoOuterContour(info);
    
  // Done for plates
  if (isPlate) {
    retFlag = 1;
    goto wrapup;
  }
  
  // Upper flange
  VDobjGetFoot(pieceOE,NULL,VDEFP_BEAM_TOP_FLANGE_NAME,&flangeOE);
  if (flangeOE.obj_id.objid != NULL_OBJID) {
    VDefpGetSrfTranInfoContours(&flangeOE,NULL,&info->flange1);
  }
  // Lower flange
  VDobjGetFoot(pieceOE,NULL,VDEFP_BEAM_BOT_FLANGE_NAME,&flangeOE);
  if (flangeOE.obj_id.objid != NULL_OBJID) {
    VDefpGetSrfTranInfoContours(&flangeOE,NULL,&info->flange2);
  }
  retFlag = 1;

#if 0
  // Stock points
  vla = malloc(sizeof(TVDvlaID));
  if (vla == NULL) goto wrapup;
  vdvla_id$Construct(vla = vla);

  /* Grab any macros */
  vdchn$GetChildrenByClass(objOE = pieceOE,
                           className = "ACconst",
                           vla = vla);

  /* Cycle once for a count */
  for(i = 0; 
      vdvla_id$GetAt(vla = vla, nth = i, objID = &stockID); 
      i = i + 1) {
    VDobjGetMacName(NULL,&stockID,macName);
    if (!strncmp(macName,"PPstock",7)) {
      info->numStockPts++;
    }
  }
  // Alloc room for stock pts
  if (info->numStockPts == 0) goto wrapup;
  info->stockPts = malloc(info->numStockPts * 3 * sizeof(IGRdouble));
  if (info->stockPts == NULL) goto wrapup;
  info->numStockPts = 0;

  // Cycle again for pts
  for(i = 0; 
      vdvla_id$GetAt(vla = vla, nth = i, objID = &stockID); 
      i = i + 1) {
    VDobjGetMacName(NULL,&stockID,macName);
    if (!strncmp(macName,"PPstock",7)) {
      VDefpGetStockPoint(&stockID,&info->stockPts[info->numStockPts * 3]);
      info->numStockPts++;
    }
  }
  printf("Found %d stock points\n",info->numStockPts);
#endif

 wrapup:
  if (vla) {
    vdvla_id$Delete(vla = vla);
    free(vla);
  }    
  return retFlag;
}
/* -----------------------------------------------
 * Compute
 * Hook to new surface tran routine
 */
IGRstat VDefpComputeSrfTran(TGRobj_env *macOE,
			    IGRint      opFlag,
			    IGRint     *feetCnt,
			    TGRid      *feetIDs)
{
  VDASSERT_FN("VDefpComputeSrfTran");
  
  IGRstat    retFlag = 0;
  
  TGRobj_env pieceOE;
    
  TVDefpSrfTranInfo info;
  
  IGRint i;
  IGRint j;
  
  IGRpoint pts[20];
  
  // Init
  VDefpInitSrfTranInfo(&info);
  pieceOE.obj_id.objid = NULL_OBJID;
  
  // Arg check
  VDASSERTW(feetCnt); *feetCnt = 0;
  VDASSERTW(feetIDs);
  VDASSERTW(macOE);
  
  // Get 1st parent, 
  vdobj$GetTemplate(objOE      = macOE,
                    nth        = VDEFP_SRF_TRAN_TEMP_IDX_PIECE,
                    templateOE = &pieceOE);
  VDASSERTW(pieceOE.obj_id.objid != NULL_OBJID);
  
  // Get the information
  VDefpGetSrfTranInfo(&pieceOE,&info);
  VDASSERTW(info.edgeBsp);

  // Create some feet
  i = 0;

  // Draw little triangle
  VDgeomCpyPt(info.center,pts[0]);
  VDgeomCpyPt(info.minor, pts[1]);
  VDgeomCpyPt(info.major, pts[2]);
  VDgeomCpyPt(info.center,pts[3]);
  VDdrawLinear(4,(IGRdouble*)pts,&macOE->mod_env,&feetIDs[i]);
  VDASSERTW(feetIDs[i].objid != NULL_OBJID);
  i++;
  
  // Outer contour
  VDdrawCurve(info.edgeBsp,&macOE->mod_env,&feetIDs[i]);
  VDASSERTW(feetIDs[i].objid != NULL_OBJID);
  i++;
  
  // Inner cutouts
  for(j = 0; j < info.inner.cnt; j++) {
    if (i < VDEFP_SRF_TRAN_FOOT_MAX) {  
      VDdrawCurve(info.inner.bsps[j],&macOE->mod_env,&feetIDs[i]);
      VDASSERTW(feetIDs[i].objid != NULL_OBJID);
      i++;
    }
  }

  // Top flange
  for(j = 0; j < info.flange1.cnt; j++) {
    if (i < VDEFP_SRF_TRAN_FOOT_MAX) {  
      VDdrawCurve(info.flange1.bsps[j],&macOE->mod_env,&feetIDs[i]);
      VDASSERTW(feetIDs[i].objid != NULL_OBJID);
      i++;
    }
  }

  // Bot flange
  for(j = 0; j < info.flange2.cnt; j++) {
    if (i < VDEFP_SRF_TRAN_FOOT_MAX) {  
      VDdrawCurve(info.flange2.bsps[j],&macOE->mod_env,&feetIDs[i]);
      VDASSERTW(feetIDs[i].objid != NULL_OBJID);
      i++;
    }
  }

  // Done
  *feetCnt = i;
  retFlag  = 1;
    
 wrapup:
  
  // Free
  VDefpFreeSrfTranInfo(&info);

  if (retFlag == 0) {
    printf("*** srf_tran macro compute failed\n");
    vdobj$Print(objOE =  macOE);
    vdobj$Print(objOE = &pieceOE);
  }
  
  return retFlag;
}

extern IGRdouble fabs(IGRdouble x);

/* ----------------------------------------------------------
 * This guy gets the actual major point
 * within the specified tolerance
 */
IGRstat VDgeomGetCrvCMMMajor(TGRbsp_curve *crv,
			     IGRdouble     incAngle,
			     IGRdouble     tolAngle,
			     IGRpoint      center,
			     IGRpoint      minor,
			     IGRdouble     totalArcLen,
			     IGRdouble     minorArcLen,
			     IGRint        factor,
			     IGRpoint      major)
{
  VDASSERT_FN("VDgeomGetCrvCMM");

  IGRstat retFlag = 0;
  
  IGRdouble deltaArcLen;
  IGRdouble majorArcLen;
  
  IGRint i;

  IGRdouble angle,delta;
  
  // This is the arc distances to try
  deltaArcLen = totalArcLen / factor;
  majorArcLen = minorArcLen;
  
  // Loop through
  factor--;
  for(i = 0; i < factor; i++) {

    // Setup next try
    majorArcLen += deltaArcLen;    
    if (majorArcLen > totalArcLen) majorArcLen -= totalArcLen;

    // Grab the point
    vdgeom$GetCrvArcParPt(crv = crv, len = majorArcLen, pt = major);

    // Check the angle
    VDgeomGetAngleFrom3Points(minor,center,major,&angle);
    angle = VDgeomRadToDeg(angle);

    // printf("Angle %8.2f\n",angle);
    
    delta = fabs(angle - incAngle);
    if (delta < tolAngle) {
      retFlag = 1;
      goto wrapup;
    }
  }

  // Failed

 wrapup:
  return retFlag;
}

/* ----------------------------------------------------------
 * Given a closed curve
 * Return center,minor points
 * Return a "major" point such that the angle between the
 * major and minor falls within tolerance of arguments
 */
IGRstat VDgeomGetCrvCMM(TGRbsp_curve *crv,
			IGRdouble     incAngle,
			IGRdouble     tolAngle,
			IGRpoint      center,
			IGRpoint      minor,
			IGRpoint      major)
{
  VDASSERT_FN("VDgeomGetCrvCMM");
  
  IGRstat  retFlag = 0;
  IGRstat  sts;
  
  IGRdouble len,lenTotal;
  IGRdouble angle;

  IGRdouble totalArcLen;
  IGRdouble minorArcLen;

  IGRint i,j;
  
  // The min dist is the minor axis
  IGRshort   k,n;
  IGRdouble  dis;
  IGRdouble  par;
  IGRdouble *pars    = NULL;
  IGRdouble *intpars = NULL;

  BSrc       rc;
  
  // Arg check
  VDASSERTW(crv);
  VDASSERTW(center);
  VDASSERTW(major);
  VDASSERTW(minor);

  // Get the center
  BSfndcent(crv,center,&rc);
  VDASSERTW(rc == BSSUCC);
  
  // Get the minor axis (min dist)
  BSmdistptcv(crv,center,&k,&n,&pars,&dis,&intpars,&rc);

  if ((pars) && (n > 0)) par = pars[0];
  else                   par = 0.0;
  
  VDgeomGetCrvPt(crv,par,minor);
  
  // Setup for calculating major
  vdgeom$GetCrvArcLen(crv = crv,             len = &totalArcLen);
  vdgeom$GetCrvArcLen(crv = crv, par1 = par, len = &minorArcLen);

  // Basically trial and error
  j = 1;
  for(i = 0; i < 4; i++) {
    j *= 4;

    sts = VDgeomGetCrvCMMMajor(crv,incAngle,tolAngle,
			       center,minor,totalArcLen,minorArcLen,
			       j,major);
    if (sts == 1) {
      retFlag = 1;
      goto wrapup;
    }
  }
  
#if 0
  // Try some
  retFlag = 1;
  sts = VDgeomGetCrvCMMMajor(crv,incAngle,tolAngle,
			     center,minor,totalArcLen,minorArcLen,
			     4,major);
  if (sts & 1) goto wrapup;

  sts = VDgeomGetCrvCMMMajor(crv,incAngle,tolAngle,
			     center,minor,totalArcLen,minorArcLen,
			     8,major);
  if (sts & 1) goto wrapup;
  sts = VDgeomGetCrvCMMMajor(crv,incAngle,tolAngle,
			     center,minor,totalArcLen,minorArcLen,
			     16,major);
  if (sts & 1) goto wrapup;
  sts = VDgeomGetCrvCMMMajor(crv,incAngle,tolAngle,
			     center,minor,totalArcLen,minorArcLen,
			     32,major);
  if (sts & 1) goto wrapup;
#endif

  printf("*** The %d check failed\n",j);
    
#if 1
  // The major axis should be 1/4 distance around
  vdgeom$GetCrvArcLen(crv = crv, len = &lenTotal);
  vdgeom$GetCrvArcLen(crv = crv, par1 = par, len = &len);

  len += (lenTotal * .25);
  if (len > lenTotal) len -= lenTotal;

  vdgeom$GetCrvArcParPt(crv = crv, len = len, pt = major);

  // Make sure not almost straight
  VDgeomGetAngleFrom3Points(minor,center,major,&angle);
  angle = VDgeomRadToDeg(angle);
  // printf("Angle %.2f\n",angle);
  if ((angle > 30.0) && (angle < 150.0)) {
    retFlag = 1;
    goto wrapup;
  }

  // Shift it
  len += (lenTotal * .125);
  if (len > lenTotal) len -= lenTotal;
  vdgeom$GetCrvArcParPt(crv = crv, len = len, pt = major);

  // Make sure not almost straight
  VDgeomGetAngleFrom3Points(minor,center,major,&angle);
  angle = VDgeomRadToDeg(angle);
  if ((angle > 30.0) && (angle < 150.0)) {
    retFlag = 1;
    goto wrapup;
  }
  printf("*** Have Collinear Center,Minor,Major\n");
#endif

  // Done
  retFlag = 1;
  
wrapup:
  _FREE(pars);
  _FREE(intpars);
  
  return retFlag;
}
