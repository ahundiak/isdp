/* $Id: VDsupCons.I,v 1.1.1.1 2001/01/04 21:09:25 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdsup/imp/VDsupCons.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDsupCons.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:09:25  cvs
 *      Initial import to CVS
 *
# Revision 1.2  2000/01/07  15:43:04  pinnacle
# Replaced: vdsup/imp/VDsupCons.I for:  by impd252 for vds
#
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.4  1997/11/25  15:50:52  pinnacle
# NULL_GRID
#
# Revision 1.3  1997/10/29  15:23:44  pinnacle
# Add VDmaster.h
#
# Revision 1.2  1997/10/28  18:16:14  pinnacle
# Assorted 2.5 Fixes
#
 *
 * History:
 *      MM/DD/YY        AUTHOR   DESCRIPTION
 *      10/28/97        ah       added header
 *      11/25/97        ah       Deleted extern NULL_GRID
 *      01/06/00        HF       Fix for TR # 179901001
 ***************************************************************************/

class implementation VDsupGen;

#include "bsalloccv.h"
#include "bsarclen.h"
#include "bsiarcln.h"
#include "bspartofcv.h"
#include "bsmdstptcv.h"
#include "bsmdistcvcv.h"
#include "bsmdistcvsf.h"
#include "bspl_cv_int.h"
#include "bsdistptpl.h"
#include "bscveval.h"

#include "VDmsg.h"
#include "vdAPImacros.h"

#include "VDsupMisc.h"
#include "VDsupMac.h"
#include "VDsupCons.h"

#define	VD_DEBUG
#include	<VDdebug.h>

from  EMSsubbs  import  EMproject_curve_along_surface_normals;
from  GRlinear  import  GRgetpolyline;

extern GRclassid OPP_GRcurve_class_id;
extern GRclassid OPP_GR3dpoint_class_id;
extern GRclassid OPP_GRbcsubbc_class_id;
extern GRclassid OPP_GR3dlinestr_class_id;
extern GRclassid OPP_EMSplane_class_id;
extern GRclassid OPP_EMSsurface_class_id;

/* -------------------------------------------------------
 * Given a set of points, place the curve
 */
IGRstat VDsupPlaceCurve(
  VDsupConsInfo *info,
  TGRpoint      *ptList,
  IGRlong        j
)
{
  IGRlong traceNum = info->traceNum;
  IGRstat sts,l_msg,l_ret;

  TGRmd_env *md_env = info->md_env;

  TGRvg_construct cnst;

  BSrc bsrc;

  struct {
    TGRid         id;
    TGRpolyline   polyline;
    TGRbsp_curve  bsp;
    IGRlong       order;
  } fit;

  struct {
    TGRlc_info lc;
    TGRid      id,footId,trimId;
    GRobjid   *list;
    IGRlong    num;
    IGRchar    name[DI_PATH_MAX];
  } proj;

  UI_status("Support Macro Placing Curve Begins...");

  l_ret = MSFAIL;

  memset(&fit, 0,sizeof(fit));
  memset(&proj,0,sizeof(proj));

  fit.id = NULL_GRID;

  /* Ready to make curve from traceList
   * However, BSdirftcv does not seem to like it when
   * you only have two points so just make a line string
   * in this case
   */
  if (traceNum == 2) {

    sts = VDsupConsObj(OPP_GR3dlinestr_class_id,md_env,&fit.id);
    __CheckSTS(sts,"Constructing Fit Object",wrapup);

    fit.polyline.num_points = traceNum;
    fit.polyline.points     = (IGRdouble*)ptList;

    VDsupInitCnst(&cnst);
    cnst.env_info = md_env;
    cnst.geometry = (IGRchar*)&fit.polyline;

    sts = om$send(
      msg = message GRgraphics.GRaltconstruct(&cnst),
      senderid = NULL_OBJID,
      targetid = fit.id.objid,
      targetos = fit.id.osnum
    );
    __CheckSTS(sts,"Constructing Fit Curve",wrapup);
  }

  else {

{
/*
  int i;
  for(i = 0; i < traceNum; i++) {
    printf("%8.2f %8.2f %8.2f\n",
      ptList[i].x,ptList[i].y,ptList[i].z);
  }
  printf("\n");
*/
}
    /* Fit the points onto a bspline */
    fit.order = 3; // Or should it be 4???

    fit.bsp.poles = (IGRdouble*) _CALLOC(traceNum + (fit.order - 1),IGRpoint);
    fit.bsp.knots = (IGRdouble*) _CALLOC(traceNum + (fit.order * 2),IGRdouble);

    __CheckPtr(fit.bsp.poles,"Allocating fit geom",wrapup);
    __CheckPtr(fit.bsp.knots,"Allocating fit geom",wrapup);

    BSdirfitcv(
       traceNum,
      (IGRpoint*)ptList,
       fit.order,
      0,0,0,NULL,NULL,
      &fit.bsp,
      &bsrc
    );
    __CheckBSRC(bsrc,"Generating Fit Curve",wrapup);

    /* Turn into object */
    sts = VDsupConsObj(OPP_GRbcsubbc_class_id,md_env,&fit.id);
    __CheckSTS(sts,"Constructing Fit Object",wrapup);

    VDsupInitCnst(&cnst);
    cnst.env_info = md_env;
    cnst.geometry = (IGRchar*)&fit.bsp;

    sts = om$send(
      msg = message GRgraphics.GRconstruct(&cnst),
      senderid = NULL_OBJID,
      targetid = fit.id.objid,
      targetos = fit.id.osnum
    );
    __CheckSTS(sts,"Constructing Fit Curve",wrapup);
  }

  /* Project to surface just to be sure get surface curve */
  proj.lc.module_info = *md_env;
  proj.lc.located_obj =  fit.id;

  cnst.geometry = NULL;
  sts = om$send(
    msg = message EMSsubbs.EMproject_curve_along_surface_normals(
      &proj.lc,
      &info->baseSurfLc,
      &cnst,
       FALSE,FALSE,
      &proj.num,&proj.list,
      &l_msg
    ),
    senderid = NULL_OBJID,
    targetid = info->baseSurfLc.located_obj.objid,
    targetos = info->baseSurfLc.located_obj.osnum
  );
  __CheckRC (sts,l_msg,"Constructing Projected Curve",wrapup);
  __CheckPtr(proj.list,"Constructing Projected Curve",wrapup);

  /* Find desired result */
  if (proj.num == 0) {
    __CheckRC(0,0,"No Projected Curves",wrapup);
  }
  if ((proj.num == 1) || (info->selBool != TRUE)) {
    proj.id.objid = proj.list[0];
    proj.id.osnum = md_env->md_id.osnum;
  }
  else {
    sts = VDsupSelectClosestCvObj(
      proj.num,
      proj.list,
      info->md_env,
     (IGRdouble*)&info->selPt,
     &proj.id
    );
    __CheckSTS(sts,"Getting Closest Curve",wrapup);
  }

  /* Convert linestrings to curve */
  if (vd_$is_ancestry_valid(
        object = &proj.id,
        classid = OPP_GR3dlinestr_class_id
      )
    ) {
      sts = VDsupLinestrToCurve(&proj.id,md_env,&cnst,&proj.footId);
      __CheckSTS(sts,"Converting line string",wrapup);
    }
  else {
    sts = vd_$grCopy(
      msg = &l_msg,
      frObj = &proj.id,     frEnv = md_env,
      toObj = &proj.footId, toEnv = md_env
    );
    __CheckRC(sts,l_msg,"Copying line string",wrapup);
  }

  /* Cut It */
  sts = VDsupCutCurve(info,&proj.footId,&proj.trimId);
  __CheckSTS(sts,"Cutting Curve",wrapup);

  if (proj.trimId.objid != NULL_OBJID) {
    vd_$bulk_delete(theEnv = md_env, grids = &proj.footId);
    proj.footId = proj.trimId;
  }

  info->feetListId[j] = proj.footId;
 *info->feetNum = *info->feetNum + 1;

  l_ret = MSSUCC;
  if (*info->occName == NULL) goto wrapup;

  sprintf(proj.name,"%s_%02d",info->occName,j+1);

  di$rm_name(
    regexp = proj.name,
    osnum  = proj.footId.osnum
  );

  om$send(
    msg = message GRvg.GRchgname(&l_msg,md_env,proj.name),
    senderid = NULL_OBJID,
    targetid = proj.footId.objid,
    targetos = proj.footId.osnum
  );

wrapup:

  vd_$bulk_delete(theEnv = md_env, objids = proj.list, count = proj.num);
  vd_$bulk_delete(theEnv = md_env, grids  = &fit.id);

  _FREE(fit.bsp.poles);
  _FREE(fit.bsp.knots);
  _FREE(proj.list);

  UI_status("Support Macro Placing Curve Complete");

  return l_ret;
}

/* --------------------------------------------
 * Gets the geometry of curve or surface
 */
IGRstat VDsupGetCrvOrSurfGeom(
  VDsupConsInfo *info,
  TGRlc_info    *lc,
  TGRbsp_curve **bsp
)
{
  IGRstat    sts,l_msg;
  IGRstat    l_ret = MSFAIL;

  TGRid      id = NULL_GRID;
  TGRmd_env *md_env = info->md_env;

  /* Use curve as is */
  if (vd_$is_ancestry_valid(
        object = &lc->located_obj,
        classid = OPP_GRcurve_class_id)) {

    sts = vd_$get_geometry(
      msg = &l_msg,
      grobjId  = &lc->located_obj,
      grobjEnv = &lc->module_info,
      geometry = bsp
    );
    __CheckRC(sts,l_msg,"Base Geometry",wrapup);

    return MSSUCC;
  }

  /* Intersect Surfaces */
  if (vd_$is_ancestry_valid(
        object = &lc->located_obj,
        classid = OPP_EMSsurface_class_id)) {

    /* Assume surface and intersect */
    sts = VDsupGetIntersection(
       info,
      &info->baseSurfLc,
       lc,
      &id
    );
    __CheckSTS(sts,"Intersecting Ref Surface",wrapup);

    sts = vd_$get_geometry(
      msg      = &l_msg,
      grobjId  = &id,
      grobjEnv =  md_env,
      geometry =  bsp
    );
    __CheckRC(sts,l_msg,"Base Geometry",wrapup);

    l_ret = MSSUCC;

    goto wrapup;
  }

wrapup:

  vd_$bulk_delete(theEnv = md_env, grids = &id);

  return l_ret;
}

/* --------------------------------------------------------------------
 * FCT VDsupGetIntersection
 * Returns the intersection between two elements closest to point
 */

IGRstat	VDsupGetIntersection (
  VDsupConsInfo *info,
  TGRlc_info    *obj1Lc,
  TGRlc_info    *obj2Lc,
  TGRid         *intId
)
{
  TGRobj_env obj1,obj2;
  TGRid     *intListId = NULL;
  IGRint     intNum = 0;
  IGRint     i;
  IGRstat    l_ret = MSFAIL;
  IGRstat    sts;

  SetProc( VDsupGetIntersection ); Begin

  UI_status("Support Macro Intersection Begins ...");

  *intId = NULL_GRID;

  /* Build GRobj_env's */
  obj1.mod_env = obj1Lc->module_info;
  obj2.mod_env = obj2Lc->module_info;
  obj1.obj_id  = obj1Lc->located_obj;
  obj2.obj_id  = obj2Lc->located_obj;

  sts = vd$int2elem(
    elem1 = &obj1,
    elem2 = &obj2,
    trim1req =  2,
    trim2req =  0,
    NumbInt  = &intNum,
    GRidInt  = &intListId
  );

  if (intNum == 0) {
    __CheckRC(0,0,"No Intersections",wrapup);
  }

  if ((intNum == 1) || (info->selBool != TRUE)) {
    *intId = intListId[0];
    l_ret = MSSUCC;
    goto wrapup;
  }

  sts = VDsupSelectClosestCv(
     intNum,
     intListId,
     info->md_env,
     (IGRdouble*)&info->selPt,
     intId
  );
  __CheckSTS(sts,"Closest Curve",wrapup);

  l_ret = MSSUCC;

wrapup:

  for (i = 0; i < intNum; i++) {
    if (intId->objid != intListId[i].objid) {
      vd_$bulk_delete(theEnv = info->md_env, grids = &intListId[i]);
    }
  }
  _FREE(intListId);

  End
  UI_status("Support Macro Intersection Complete");
  return l_ret;
}

/* --------------------------------------------------------
 * Finds the trimming parameter for one trim curve
 */
IGRstat VDsupGetTrimPar(
  TGRbsp_curve *crvBsp,
  TGRlc_info   *lcInfo,
  IGRdouble    *par
)
{
  IGRstat sts,l_msg,l_ret;
  GRclassid classId;

  __enterFunction ( name = "VDsupGetTrimPar" );

  l_ret = MSFAIL;
/*
printf("Getting trim parameter for %d,%d\n",
  lcInfo->located_obj.osnum,
  lcInfo->located_obj.objid);
*/
  sts = om$get_classid(
    osnum = lcInfo->located_obj.osnum,
    objid = lcInfo->located_obj.objid,
    p_classid = &classId
  );
  __CheckRC(sts,1,"Getting Class ID",wrapup);

  /* --------------------------------------------- */
  /* Trim object is a point                        */
  sts = om$is_ancestry_valid(
    superclassid = OPP_GR3dpoint_class_id,
    subclassid   = classId);
  if (sts == OM_S_SUCCESS) {

    IGRint      Action = 1;
    IGRdouble   pt[3],base[3];
    TGRpolyline polyLine;
    IGRdouble   dist;
    BSrc        rc;

    polyLine.points = pt;

    sts = om$send(
      msg = message GRlinear.GRgetpolyline(
        &l_msg,
        (IGRshort*)&lcInfo->module_info.md_env.matrix_type,
         lcInfo->module_info.md_env.matrix,
        &Action,
        &polyLine
      ),
      senderid = NULL_OBJID,
      targetid = lcInfo->located_obj.objid,
      targetos = lcInfo->located_obj.osnum
    );
    __CheckRC(sts,l_msg,"GRgetpolyline",wrapup);

    BSmdstptcv(crvBsp,pt,par,base,&dist,&rc);
    __CheckBSRC(rc,"Min Dist Pt Crv",wrapup);

    l_ret = MSSUCC;
    goto wrapup;

  }

  /* ------------------------------------------------ */
  /* Trim Object is a curve                           */
  sts = om$is_ancestry_valid(
    superclassid = OPP_GRcurve_class_id,
    subclassid   = classId);

  if (sts == OM_S_SUCCESS) {

    TGRbsp_curve *lciBsp = NULL;
    IGRint     num = 0;
    IGRdouble *crvPar = NULL;
    IGRdouble *lciPar = NULL;
    IGRpoint  *crvPt  = NULL;
    IGRpoint  *lciPt  = NULL;
    IGRdouble  dist;
    BSrc       rc;

    sts = vd_$get_geometry(
      msg = &l_msg,
      grobjId  = &lcInfo->located_obj,
      grobjEnv = &lcInfo->module_info,
      geometry = &lciBsp
    );
    __CheckRC(sts,l_msg,"Base Geometry",wrapup);

    BSmdistcvcv(crvBsp,lciBsp,&num,&crvPar,&lciPar,&crvPt,&lciPt,&dist,&rc);
    __CheckBSRC(rc,"Min Dist Crv Crv",cleanup_curve);

    if (num < 1) goto cleanup_curve;
    *par = crvPar[0];
    l_ret = MSSUCC;

cleanup_curve:
    _FREE(lciBsp);
    _FREE(crvPar);
    _FREE(lciPar);
    _FREE(crvPt);
    _FREE(lciPt);

    goto wrapup;
  }

  /* ------------------------------------------------ */
  /* Trim Object is a surface                         */
  sts = om$is_ancestry_valid(
    superclassid = OPP_EMSsurface_class_id,
    subclassid   = classId);

  if (sts == OM_S_SUCCESS) {

    /* ---------------------------------------------- */
    /* Trim object is a plane                         */
    sts = om$is_ancestry_valid(
      superclassid = OPP_EMSplane_class_id,
      subclassid   = classId);

    if (sts != OM_S_SUCCESS) {

      /* -------------------------------------------- */
      /* Trim Object is non-planar surface            */

      TGRbsp_surface *lciBsp = NULL;
      IGRint     num = 0;
      IGRdouble *crvPar = NULL;
      IGRdouble *lciPar = NULL;
      IGRpoint  *crvPt  = NULL;
      IGRpoint  *lciPt  = NULL;
      IGRdouble  dist;
      BSrc       rc;
      struct GRid objId;

// printf("Object is non-planar\n");

      // HF: Start Fix for TR # 179901001
      // get the correct matrix and matrix_type BEFORE calling vd_$get_geometry()
      __printf ("lcInfo->matrix_type = %d, lcInfo->located_obj = [%d,%d]",
                `lcInfo->module_info.md_env.matrix_type,
                 lcInfo->located_obj.osnum, lcInfo->located_obj.objid` );
      /*
       * find object in model and its macro definition
       */
      sts =
        om$send(msg = message NDmacro.ACreturn_foot(  &l_msg,
                                                      "",
                                                      &objId,
                                                      &lcInfo->module_info.md_env.matrix_type,
                                                       lcInfo->module_info.md_env.matrix ),
                senderid = NULL_OBJID,
                targetid = lcInfo->located_obj.objid,
                targetos = lcInfo->located_obj.osnum );

      // HF: End Fix for TR # 179901001

      __CheckRC( sts, l_msg, "NDmacro.ACreturn_foot", wrapup );

      sts = vd_$get_geometry(
        msg      = &l_msg,
        grobjId  = &lcInfo->located_obj,
        grobjEnv = &lcInfo->module_info,
        geometry = &lciBsp
      );
      __CheckRC(sts,l_msg,"Base Geometry",wrapup);

      BSmdistcvsf(crvBsp,lciBsp,&num,&crvPar,&lciPar,&crvPt,&lciPt,&dist,&rc);
      __CheckBSRC(rc,"Min Dist Crv Srf",cleanup_non_planar);

      if (num < 1) goto cleanup_non_planar;
      *par = crvPar[0];
      l_ret = MSSUCC;

  cleanup_non_planar:
      _FREE(lciBsp);
      _FREE(crvPar);
      _FREE(lciPar);
      _FREE(crvPt);
      _FREE(lciPt);

      goto wrapup;
    }

    /* ----------------------------------------- */
    /* Have Planar Surface                       */
    else {

      TGRplane  lciPlane;
      IGRvector lciNormal;
      IGRpoint  lciOrigin;

      IGRint num_int = 0;
      IGRint num_seg = 0;

      IGRdouble *pts = NULL;
      IGRdouble *u   = NULL;
      IGRdouble *a   = NULL;
      IGRdouble *b   = NULL;

      BSrc rc;

      lciPlane.point  = lciOrigin;
      lciPlane.normal = lciNormal;

// printf("Object is planar\n");

      sts = om$send(
        msg = message GRvg.GRdetplane(
          &l_msg,
          (IGRshort*)&lcInfo->module_info.md_env.matrix_type,
                      lcInfo->module_info.md_env.matrix,
          &lciPlane
        ),
        senderid = NULL_OBJID,
        targetid = lcInfo->located_obj.objid,
        targetos = lcInfo->located_obj.osnum
      );
      __CheckRC(sts,l_msg,"GRvg.GRdetplane",wrapup);

      pts = _MALLOC(crvBsp->num_poles*3,IGRdouble);
      u   = _MALLOC(crvBsp->num_poles,  IGRdouble);
      a   = _MALLOC(crvBsp->num_poles,  IGRdouble);
      b   = _MALLOC(crvBsp->num_poles,  IGRdouble);

      BSpl_cv_int(&rc,crvBsp,lciOrigin,lciNormal,&num_int,pts,u,&num_seg,a,b);
      __CheckBSRC(rc,"Int Crv Plane",cleanup_planar);

      if (num_int < 1) {

        // Try again with min distance, probable a tolerance issue
        // No min dist pt plane routine that I could find but
        // It should be at one end or the other

        IGRdouble dis1,dis2;
        IGRpoint  pnt1,pnt2;

        BScveval(crvBsp,0.0,0,&pnt1,&rc);
        BScveval(crvBsp,1.0,0,&pnt2,&rc);

        BSdistptpl(&rc,pnt1,lciOrigin,lciNormal,&dis1);
        BSdistptpl(&rc,pnt2,lciOrigin,lciNormal,&dis2);

   //   printf("Distance 1 %10.4f\n",dis1);
   //   printf("Distance 2 %10.4f\n",dis2);

        if (dis1 < dis2) *par = 0.0;
        else             *par = 1.0;

      }
      else {
        *par  = u[0];
      }
      l_ret = MSSUCC;

  cleanup_planar:
      _FREE(pts);
      _FREE(u);
      _FREE(a);
      _FREE(b);

      goto wrapup;
    }
  }

wrapup:
  // if (l_ret != MSSUCC)  printf("Trim Parameter Failed\n");
  // else                  printf("Trim Parameter Ok\n");

  __exitFunction ( name = "VDsupGetTrimPar" );

  return l_ret;

}

/* --------------------------------------------------------
 * Trims the curve (for single support curve)
 */
IGRstat VDsupTrimCurve(
  VDsupConsInfo *info,
  TGRid         *crvId,
  TGRid         *trimId
)
{
  IGRstat sts,l_msg,l_ret;

  TGRbsp_curve *crvBsp  = NULL;

  IGRdouble par1,par2;

  /* Default is to do nothing */
  trimId->objid = NULL_OBJID;
  l_ret = MSFAIL;

  /* See if Have Any Trim Curves */
  if (info->trim1Lc.located_obj.objid == NULL) {
    l_ret = MSSUCC;
    goto wrapup;
  }
  if (info->trim2Lc.located_obj.objid == NULL) {
    l_ret = MSSUCC;
    goto wrapup;
  }
/*
  l_ret = MSSUCC;
  if (1) goto wrapup;
*/

  /* Grab Geometry */
  sts = vd_$get_geometry(
    msg      = &l_msg,
    grobjId  =  crvId,
    grobjEnv =  info->md_env,
    geometry = &crvBsp
  );
  __CheckRC(sts,l_msg,"Getting Geometry",wrapup);

//printf("Getting trim parameters\n");

  sts = VDsupGetTrimPar(crvBsp,&info->trim1Lc,&par1);
  __CheckRC(sts,1,"Getting Curve Parameter 1",wrapup);
  sts = VDsupGetTrimPar(crvBsp,&info->trim2Lc,&par2);
  __CheckRC(sts,1,"Getting Curve Parameter 2",wrapup);


//printf("Curve parameters: %.2f,%.2f\n",par1,par2);

  /* Make the curve from geometry */
  sts = VDsupMakeCurveFromPars(info,crvBsp,par1,par2,trimId);
  __CheckSTS(sts,"Making Curve",wrapup);

  l_ret = MSSUCC;

wrapup:

  _FREE( crvBsp);
  return l_ret;
}

/* --------------------------------------------------------
 * Cuts the curve
 * Used to be part of trim/cut routine
 * but seperated out to make things easier
 */
IGRstat VDsupCutCurve(
  VDsupConsInfo *info,
  TGRid         *crvId,
  TGRid         *trimId
)
{
  IGRstat sts,l_msg,l_ret;

  TGRbsp_curve *crvBsp  = NULL;

  BSrc rc;
  IGRboolean bool;

  IGRdouble par0,par1,parM;
  IGRdouble pas0,pas1;
  IGRdouble lenTotal,lenCut;

  /* Default is to do nothing */
  trimId->objid = NULL_OBJID;
  l_ret = MSFAIL;

  /* See if need to cut */
  if (info->cutf > .0001) {
    l_ret = MSSUCC;
    goto wrapup;
  }
  if ((info->cut1 < .0001) && (info->cut2 < .0001)){
    l_ret = MSSUCC;
    goto wrapup;
  }

  /* Get Geometry */
  sts = vd_$get_geometry(
    msg      = &l_msg,
    grobjId  =  crvId,
    grobjEnv =  info->md_env,
    geometry = &crvBsp
  );
  __CheckRC(sts,l_msg,"Getting Geometry",wrapup);

  /* Grab Total Arc Length */
  par0 = 0.0;
  par1 = 1.0;
  parM = 0.5;
  lenTotal = 0.0;

  BSarclen(&rc,&bool,crvBsp,&par0,&par1,&parM,&lenTotal);

  pas0 = 0.0;
  lenCut = info->cut1;;
  BSiarcln(&rc,crvBsp,&par0,&lenCut,&par1,&pas0);

  pas1 = 0.0;
  lenCut = lenTotal - info->cut2;
  BSiarcln(&rc,crvBsp,&par0,&lenCut,&par1,&pas1);

  if (pas0 >= pas1) {
    printf("Cut lengths exceed total curve length!\n");
    goto wrapup;
  }

  /* Make the curve from geometry */
  sts = VDsupMakeCurveFromPars(info,crvBsp,pas0,pas1,trimId);
  __CheckSTS(sts,"Making Curve",wrapup);

  l_ret = MSSUCC;

wrapup:

  _FREE(crvBsp);
  return l_ret;
}

/* --------------------------------------------------------
 * Make new object out of curve
 * Used to be part of trim/cut routine
 * but seperated out to make things easier
 */
IGRstat VDsupMakeCurveFromPars(
  VDsupConsInfo *info,
  TGRbsp_curve  *crvBsp,
  IGRdouble      par1,
  IGRdouble      par2,
  TGRid         *newId
)
{
  IGRstat sts,l_ret;

  TGRvg_construct cst;
  TGRbsp_curve *newBsp = NULL;

  IGRdouble parM;
  BSrc      rc;

  l_ret = MSFAIL;

  /* Sort parameter */
  if (par1 > par2) {
    parM = par1;
    par1 = par2;
    par2 = parM;
  }

  /* Length Check */
  if ((par2 - par1) < .001) {
    printf(
      "The result of a cut/trim operation would be a very short curve.\n"
      "Canceling the cut/trim operation.\n"
      "Check trim objects and cutback distances.\n"
    );
    par1 = 0.0;
    par2 = 1.0;
  }

  parM = (par1 + par2) / 2.0;

  /* Allocate new curve geometry */
  BSalloccv(
    crvBsp->order ,
    crvBsp->num_poles + ((2*crvBsp->order) - 1),
    crvBsp->rational ,
    crvBsp->num_boundaries ,
   &newBsp,
    &rc
  );

  if ((rc != BSSUCC) || (newBsp == NULL)) {
    printf("Problem Allocating cut curve\n");
    goto wrapup;
  }

  BSpartofcv(&rc,crvBsp,par1,parM,par2,newBsp);
  if (rc != BSSUCC) {
    printf("Problem generating cut curve\n");
    goto wrapup;
  }

  /* Make the curve */
  VDsupInitCnst(&cst);

  cst.geometry = (char *)newBsp;
  cst.env_info = info->md_env;

  sts = VDsupConsObj(OPP_GRbcsubbc_class_id,info->md_env,newId);
  __CheckSTS(sts,"Constructing Object",wrapup);

  sts = om$send(
    msg  = message GRgraphics.GRconstruct(&cst),
    senderid = NULL_OBJID,
    targetid = newId->objid,
    targetos = newId->osnum
  );
  __CheckSTS(sts,"Constructing Object",wrapup);

  l_ret = MSSUCC;

wrapup:
  _FREE(newBsp);
  return l_ret;
}

end implementation VDsupGen;
