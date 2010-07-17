/* $Id: VSpsi1.I,v 1.3 2001/08/17 21:58:54 hans Exp $  */

/***************************************************************************
 * I/STRUCT
 *
 * File:        vshellexp/VSpsi1.I
 *
 * Description: For plane - surface intersections
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VSpsi1.I,v $
 *      Revision 1.3  2001/08/17 21:58:54  hans
 *      Fix for TR's 4388 & 4798
 *
 *      Revision 1.2  2001/02/20 01:19:09  build
 *      Replaced v_dbgmacros.h with product specific dbgmacros.h
 *
 *      Revision 1.1.1.1  2001/01/04 21:11:00  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:08:06  pinnacle
# STRUCT 2.5.1
#
# Revision 1.1  1998/03/01  15:02:52  pinnacle
# TR179701791
#
 *
 * History:
 * MM/DD/YY    AUTHOR  DESCRIPTION
 * 03/01/98    ah      Created, TR179701791 - Problems with Shell expansion
 * 08/18/2001  HF      TR's 4388 & 4798
 *
 ***************************************************************************/

class implementation Root;

#include <stdio.h>
#include "OMmacros.h"
#include "exmacros.h"
#include "msdef.h"
#include "igrtypedef.h"
#include "igrdef.h"
#include "godef.h"
#include "igr.h"
#include "igetypedef.h"

#include "gr.h"
#include "growner.h"
#include "grmacros.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"

#include "parametric.h"
#include "AS_status.h"
#include "nddef.h"
#include "ndmacros.h"
#include "asdef.h"
#include "asmacros.h"

#include "bserr.h"
#include "bstypes.h"
#include "bsplptnorrg.h"
#include "bsarclen.h"
#include "bsdistptpt.h"
#include "bsmdstptcv.h"

#include "bsfreesf.h"
#include "bspj_pt_sf.h"
#include "bspl_cv_int.h"
#include "bssfeval.h"
#include "bsbx2.h"

#include "vds.h"
#include "VDmsg.h"
#include "vdAPImacros.h"

#include "v_miscmacros.h"
#include "v_geommacros.h"
#include "vsdbgmacros.h"

#include "VDtypedef.h"
#include "VSpsi.h"

#define	VD_DEBUG
#include	<VDdebug.h>

from GRlinear    import GRgetpolyline;
from GRvg        import GRgenabsg, GRpostabsg, GRdetplane;
from EMSsurface  import GRgetrang;
from EMSplane    import GRconstruct;
from GRgraphics  import GRaltconstruct, GRcopy, GRdelete;

extern GRclassid OPP_GRbcsubbc_class_id;
extern GRclassid OPP_GR3dlinestr_class_id;
extern GRclassid OPP_EMSplane_class_id;

IGRstat VSpsiFreeInfo(VSpsiInfo *info, IGRint flag)
{
  IGRint  i;

  // Delete plane if have one
  if ((info->plane.obj.obj_id.objid != 0) &&
      (info->plane.obj.obj_id.objid != NULL_OBJID))
  {
    vd_$bulk_delete(
      theEnv = &info->md_env,
      grids  = &info->plane.obj.obj_id
    );
  }
  info->plane.obj.obj_id.objid = 0;

  // Get rid of curves
  if (info->crv.ids != NULL)
  {
    vd_$bulk_delete(
      theEnv = &info->md_env,
      count =   info->crv.cnt,
      grids =   info->crv.ids
    );
    _FREE(info->crv.ids);
    info->crv.ids = NULL;
  }

  // See if want to get rid of bsp stuff
  if (flag == 0) return 1;

  for(i = 0; i < info->crv.cnt; i++)
  {
    if (info->crv.bsps[i])
    {
      _FREE(info->crv.bsps[i]);
      info->crv.bsps[i] = NULL;
    }
  }
  info->crv.cnt = 0;

  return 1;
}

IGRstat VSpsiInitInfo(VSpsiInfo *info)
{
  IGRstat retFlag = 0;
  IGRstat sts,msg;

  IGRint  md_env_size;
  IGRint  md_env_rec;
  IGRint  md_env_msg;

  IGRint i;

  // Need Module Env Later */
  md_env_size = sizeof( TGRmd_env );
  sts = gr$get_module_env(
    msg     = &md_env_msg,
    sizbuf  = &md_env_size,
    buffer  = &info->md_env,
    nret    = &md_env_rec
  );
  if (!(sts & 1))
  {
    printf("Could not get module enviroment\n");
    goto wrapup;
  }

  // Construction Stuff
  ASget_active_symb(&info->cst.level,&info->dis);

  info->cst.msg        = &info->msg;
  info->cst.properties = GRIS_LOCATABLE | GRIS_NEW | GRIS_DISPLAYABLE;
  info->cst.display    = &info->dis;
  info->cst.env_info   = &info->md_env;
  info->cst.newflag    = 0;
  info->cst.geometry   = NULL;
  info->cst.class_attr = 0;
  info->cst.name       = 0;

  // Plane structure
  info->plane.geom.point  = info->plane.point;
  info->plane.geom.normal = info->plane.normal;

  for(i = 0; i < 3; i++)
  {
    info->plane.point [i] = 0.0;
    info->plane.normal[i] = 0.0;
  }
  info->plane.normal[0] = -1.0;

  // Get surface range in world coordinates
  info->range.world = 1;

  sts = om$send(
    msg = message EMSsurface.GRgetrang(
      &msg,
      &info->srfObj.mod_env.md_env.matrix_type,
       info->srfObj.mod_env.md_env.matrix,
      &info->range.world,
       info->range.geom
    ),
    senderid = NULL_OBJID,
    targetid = info->srfObj.obj_id.objid,
    targetos = info->srfObj.obj_id.osnum
  );
  if (!(sts & msg & 1)) {
    printf("Problem getting surface range\n");
    goto wrapup;
  }

  // Init Plane Creation Stuff
  info->plane.scale = 2.0;
  info->plane.bsp.poles   = &info->plane.poles[0]   ;
  info->plane.bsp.u_knots = &info->plane.u_knots[0] ;
  info->plane.bsp.v_knots = &info->plane.v_knots[0] ;
  info->plane.bsp.weights = NULL ;
  info->plane.bsp.bdrys   = NULL ;

  info->plane.obj.mod_env = info->md_env;

  retFlag = 1;

wrapup:
  return retFlag;
}
#ifdef XXX
IGRstat VSpsiMovePlane(VSpsiInfo *info, IGRdouble x1, IGRdouble x2)
{
  IGRstat retFlag = 0;
  IGRstat sts,msg;

  TGRmdenv_info mat;

  MAidmx(&msg,mat.matrix);

  mat.matrix[3] = x2 - x1;
  mat.matrix_type = MAIDMX;

  return 1;
}

  memset(&mat,0,sizeof(mat));

  mat.matrix[0] = 1.0;
  mat.matrix[5] = 1.0;
  mat.matrix[0] = 1.0;

#endif

IGRstat VSpsiCreatePlane(VSpsiInfo *info, IGRdouble x)
{
  IGRstat retFlag = 0;
  IGRstat sts;

  BSrc rc;

  // Plane Geometry
  info->plane.obj.obj_id.objid = NULL_OBJID ;
  info->plane.obj.obj_id.osnum = info->md_env.md_id.osnum;
  info->plane.point[0] = x;

  BSplptnorrg(
    &info->range.geom[0],
    &info->range.geom[3],
     info->plane.point,
     info->plane.normal,
     info->plane.scale,
    &info->plane.in_range,
    &info->plane.bsp, /* bounded B-spline plane */
    &rc
  );

  if (rc != BSSUCC) {
    printf("Problem getting plane range geometry\n");
    goto wrapup;
  }

  // Construct the new plane
  info->cst.geometry = (char *)&info->plane.bsp;

  sts = om$construct(
    classid = OPP_EMSplane_class_id,
    p_objid = &info->plane.obj.obj_id.objid,
    osnum   =  info->plane.obj.obj_id.osnum
  );
  if (!(sts & 1)) {
    printf("Problem Constructing Plane Object\n");
    goto wrapup;
  }

  sts = om$send(
    msg = message EMSplane.GRconstruct(&info->cst),
    senderid = NULL_OBJID,
    targetid = info->plane.obj.obj_id.objid,
    targetos = info->plane.obj.obj_id.osnum
  );
  if (!(sts & info->msg & 1)) {
    printf("Problem EMSplane.GRconstruct\n");
    goto wrapup;
  }
  // vd_$bulk_display(theEnv = &info->md_env, grids = &info->plane.obj.obj_id);

  retFlag = 1;

wrapup:
  return retFlag;
}

IGRstat VSpsiCreateLineStr(VSpsiInfo *info, IGRdouble *pts)
{
  IGRstat retFlag = 0;
  IGRstat sts;

  TGRpolyline polyline;
  TGRid   lineId;

  lineId.objid = NULL_OBJID ;
  lineId.osnum = info->md_env.md_id.osnum;

  sts = om$construct(
    classid = OPP_GR3dlinestr_class_id,
    p_objid = &lineId.objid,
    osnum   =  lineId.osnum
  );
  if (!(sts & 1)) {
    printf("Problem Constructing Line String Object\n");
    goto wrapup;
  }

  polyline.num_points = 2;
  polyline.points = pts;

  info->cst.geometry = (IGRchar*)&polyline;

  sts = om$send(
    msg = message GRgraphics.GRaltconstruct(&info->cst),
    senderid = NULL_OBJID,
    targetid = lineId.objid,
    targetos = lineId.osnum
  );
  if (!(sts & info->msg & 1)) {
    printf("Problem GR3dlinestr.GRconstruct\n");
    goto wrapup;
  }
  vd_$bulk_display(theEnv = &info->md_env, grids = &lineId);

  retFlag = 1;

wrapup:
  return retFlag;
}

IGRstat VSpsiProcessPlane(VSpsiInfo *info, IGRdouble x)
{
  IGRstat retFlag = 0;
  IGRstat sts,msg;
  IGRchar status[128];
  IGRint  i;

  __enterFunction ( name = "VSpsiProcessPlane" //, argfmt = "", args = ``
  );

  // Cleanup any existing curves
  VSpsiFreeInfo(info,1);

  // Make a plane
  sts = VSpsiCreatePlane(info,x);
  if (!(sts & 1)) goto wrapup;

  // Intersect against surface
  sprintf(status,"Intersecting Frame %10.4f ...",x);
  // printf("Intersecting: %10.4f",x);
  UI_status(status);

  sts = vd$int2elem(
    elem1 = &info->srfObj,
    elem2 = &info->plane.obj,
    trim1req =  0,
    trim2req =  0,
    NumbInt  = &info->crv.cnt,
    GRidInt  = &info->crv.ids
  );
  // printf(", %d\n",info->crv.cnt);
  if (!(sts & 1)) goto wrapup;

  // Optional Display
/*
  vd_$bulk_display(
    theEnv = &info->md_env,
    count =   info->crv.cnt,
    grids =   info->crv.ids
  );
*/
  // Get too many, something major is wrong
  if (info->crv.cnt > VS_PSI_CRV_MAX)
  {
    printf("Too Many Curves from shell/plane intersection\n");
    goto wrapup;
  }

  // Get geometry for each curve
  for(i = 0; i < info->crv.cnt; i++)
  {
    sts = vd_$get_geometry(
      msg      = &msg,
      grobjId  = &info->crv.ids[i],
      grobjEnv = &info->md_env,
      geometry = &info->crv.bsps[i]
    );
    __CheckRC(sts,msg,"Curve Geometry",wrapup);
  }

  retFlag = 1;

wrapup:

  // Free intermediate stuff
  VSpsiFreeInfo(info,0);

  __exitFunction ( name = "VSpsiProcessPlane", argfmt = "retFlag = %d, info->crv.cnt = %d", args = `retFlag, info->crv.cnt` );

  return retFlag;
}

// For a given point, find parameter on nearest curve
IGRstat VSpsiGetCurve(
  VSpsiInfo *info,
  IGRpoint   aPt,
  IGRint    *aIndex,
  IGRdouble *aPar)
{
  IGRstat retFlag = 0;
  IGRint  i;
  BSrc rc;

  struct
  {
    IGRdouble dist;
    IGRdouble par;
    IGRint    index;
    IGRpoint  pt;
  } min,cur;

  __enterFunction ( name = "VSpsiGetCurve" , argfmt = "aPt = %lf %lf %lf", args = `aPt[0], aPt[1], aPt[2]` );

  // Init
  min.par   = -1.0;
  min.dist  = 1000000.0 * 1000000.0 * 1000000.0;
  min.index = -1;
  *aIndex   = -1;

  // Check each curve
  for(i = 0; i < info->crv.cnt; i++)
  {
    if (info->crv.bsps[i] == NULL)
    {
      printf("Problem with finding point on curve\n");
      goto wrapup;
    }

    BSmdstptcv (info->crv.bsps[i], aPt, &cur.par, cur.pt, &cur.dist, &rc);
    if (rc != BSSUCC)
    {
      printf("Problem with BSmsdtptcv\n");
      goto wrapup;
    }
    if (cur.dist < min.dist)
    {
      min.dist  = cur.dist;
      min.par   = cur.par;
      min.index = i;
    }
  }

  // Make sure got one

  *aPar   = min.par;
  *aIndex = min.index;

  if (min.index == -1) goto wrapup;
  retFlag = 1;

wrapup:

  __exitFunction ( name = "VSpsiGetCurve", argfmt = "retFlag = %d, aIndex = %d, aPar = %lf", args = `retFlag, *aIndex, *aPar` );

  return retFlag;
}

IGRstat VSpsiIntShell(
  TGRobj_env *srfObj,
  IGRdouble   xBeg,
  IGRdouble   xInc,
  IGRint      xCnt
)
{
  IGRstat retFlag = 0;
  IGRstat sts;
  IGRchar status[128];

  VSpsiInfo info;
  IGRint i;
  IGRdouble x;

  __enterFunction ( name = "VSpsiIntShell" //, argfmt = "", args = ``
  );

  // Init Stuff
  memset(&info,0,sizeof(info));
  info.srfObj = *srfObj;

  sts = VSpsiInitInfo(&info);
  if (!(sts & 1)) goto wrapup;

  info.file = fopen("crv.txt","wt");

  // Loop Through
  for(x = xBeg, i = 0; i < xCnt; i++)
  {
    // Make a plane
    sts = VSpsiCreatePlane(&info,x);
    if (!(sts & 1)) continue;

    // Intersect against surface
    info.crv.cnt = 0;
    info.crv.ids = NULL;

    sprintf(status,"Intersecting Frame %10.4f ...",x);
    printf("Intersecting: %10.4f\n",x);
    UI_status(status);

    sts = vd$int2elem(
      elem1 = &info.srfObj,
      elem2 = &info.plane.obj,
      trim1req =  0,
      trim2req =  0,
      NumbInt  = &info.crv.cnt,
      GRidInt  = &info.crv.ids
    );

    vd_$bulk_display(
      theEnv = &info.md_env,
      count =   info.crv.cnt,
      grids =   info.crv.ids
    );

    if (info.crv.ids)
    {
      _FREE(info.crv.ids);
      info.crv.ids = NULL;
    }
    vd_$bulk_delete(
      theEnv = &info.md_env,
      grids =  &info.plane.obj.obj_id
    );

    // Next X
    x += xInc;
  }

  retFlag = 1;

wrapup:

  if (info.crv.ids)
  {
    _FREE(info.crv.ids);    // free
  }
  if (info.file) fclose(info.file);

  __exitFunction ( name = "VSpsiIntShell", argfmt = "retFlag = %d", args = `retFlag` );

  return retFlag;
}

IGRstat VSpsiProcessPlaneExtendedSurf
(
  IGRlong               *msg,               // O
  VSpsiInfo             *info,              // I
  IGRdouble              x,                 // I
  struct IGRbsp_surface *shGeom,            // I
  double                 refLine,           // I
  short                 *havePjRLP,         // O
  double                *pjRLP              // O
)
{
  IGRstat retFlag = 0;
  IGRstat sts;
  IGRchar status[128];
  IGRint  i0, i;
  IGRint  md_env_size;
  IGRint  md_env_rec;
  IGRint  md_env_msg;
  BSrc    bsRC;

  IGRboolean              reduce_data = 0;
  IGRlong                 num_poles   = shGeom->u_num_poles * shGeom->v_num_poles;
  GRrange                 ext_range, surf_range;
  struct GRobj_env        newobjid;
  struct IGRbsp_surface  *tmpsf = NULL;
  struct GRpost_info      post_info ;
  struct GRmd_env         Mod_Env;
  extern IGRboolean       GRabsg_del_all();

  __enterFunction ( name = "VSpsiProcessPlaneExtendedSurf" , argfmt = "x = %lg, refLine = %lg", args = `x, refLine` );

  md_env_size = sizeof( struct GRmd_env );
  sts = gr$get_module_env(
    msg     = &md_env_msg,
    sizbuf  = &md_env_size,
    buffer  = &Mod_Env,
    nret    = &md_env_rec
  );
  if (!(sts & 1))
  {
    printf("Could not get module enviroment\n");
    goto wrapup;
  }

  // Cleanup any existing curves
  VSpsiFreeInfo(info,1);

  // Make a plane
  sts = VSpsiCreatePlane(info,x);
  if (!(sts & 1)) goto wrapup;

  // Intersect against surface
  sprintf(status,"Intersecting Frame %10.4f ...",x);
  // printf("Intersecting: %10.4f",x);
  UI_status(status);

  // First extend the surface ...
  /*
   * Get range of initial surface
   */
  BSbx2 ( &bsRC, &num_poles, ( IGRpoint * ) shGeom->poles,
          ( shGeom->rational ? shGeom->weights : NULL ),
          &surf_range[0], &surf_range[3] );
  if( BSERROR( bsRC ) ) goto wrapup;

  // Extend range by 10 % around the surface ...
  for (i0=0; i0 < 3; i0++)
  {
    ext_range[i0  ] = surf_range[i0  ] - .1 * surf_range[i0  ];
    ext_range[i0+3] = surf_range[i0+3] + .1 * surf_range[i0+3];
  }
  sts = SMextentSrfRg( msg, shGeom, ext_range, reduce_data, &tmpsf );

  __printf("SMextentSrfRg() sts = %d, msg = %#x, tmpsf[u_v] = %d %d", `sts, *msg, tmpsf->u_num_poles, tmpsf->v_num_poles`);

  __CheckRC( sts, *msg, "SMextentSrfRg", wrapup ) ;

  newobjid.obj_id.objid = NULL_OBJID;
  newobjid.obj_id.osnum = 2;
  newobjid.mod_env = Mod_Env;
  sts = om$send( msg = message GRgraphics.GRcopy( msg,
                                                 &info->srfObj.mod_env,
                                                 &Mod_Env,
                                                 &newobjid.obj_id.objid ),
                 senderid = NULL_OBJID,
                 targetid = info->srfObj.obj_id.objid,
                 targetos = info->srfObj.obj_id.osnum);

  __printf("GRgraphics.GRcopy(tmpsf)  sts = %d, msg = %#x, srfObj = [%d,%d], newobjid = [%d,%d]",
           `sts, *msg, info->srfObj.obj_id.osnum, info->srfObj.obj_id.objid, newobjid.obj_id.osnum, newobjid.obj_id.objid`);

  __CheckRC(sts, *msg,"GRgraphics.GRcopy",wrapup);

  post_info.construct_flag = FALSE ;

  sts = om$send( msg = message GRvg.GRpostabsg( msg,
                                               &Mod_Env,
                                               &post_info,
                                               (IGRchar *) tmpsf,
                                               &newobjid.obj_id.objid ),
                 senderid = NULL_OBJID,
                 targetid = newobjid.obj_id.objid,
                 targetos = newobjid.obj_id.osnum);

  __printf("GRvg.GRpostabsg  (tmpsf)  sts = %d, msg = %#x, srfObj = [%d,%d], newobjid = %d",
           `sts, *msg, info->srfObj.obj_id.osnum, info->srfObj.obj_id.objid, newobjid.obj_id.objid`);

  __CheckRC(sts, *msg,"GRvg.GRpostabsg",wrapup);

  // Find the intersection curve[s] with the extended surface ...

  sts = vd$int2elem(
    elem1 = &newobjid,    // &info->srfObj,
    elem2 = &info->plane.obj,
    trim1req =  0,
    trim2req =  0,
    NumbInt  = &info->crv.cnt,
    GRidInt  = &info->crv.ids
  );

  sts = om$send( msg = message GRgraphics.GRdelete( msg, &Mod_Env ),
                 senderid = NULL_OBJID,
                 targetid = newobjid.obj_id.objid,
                 targetos = newobjid.obj_id.osnum);

  __CheckRC(sts, *msg,"GRgraphics.GRdelete",wrapup);

  // Optional Display
/*
  vd_$bulk_display(
    theEnv = &info->md_env,
    count =   info->crv.cnt,
    grids =   info->crv.ids
  );
*/
  // Get too many, something major is wrong
  if (info->crv.cnt > VS_PSI_CRV_MAX)
  {
    printf("Too Many Curves from shell/plane intersection\n");
    goto wrapup;
  }

  // Get geometry for each curve
  for(i = 0; i < info->crv.cnt; i++)
  {
    sts = vd_$get_geometry(
      msg      =  msg,
      grobjId  = &info->crv.ids[i],
      grobjEnv = &info->md_env,
      geometry = &info->crv.bsps[i]
    );
    __CheckRC(sts, *msg,"vd_$get_geometry(Curve)",wrapup);
  }

  // Find the projection point on the extended surface ...

  sts = VSsxProjectReferenceLinePointOntoShell( msg,
                                                tmpsf,
                                                x,
                                                refLine,
                                                havePjRLP,
                                                pjRLP ) ;

  __CheckRC(sts, *msg,"VSsxProjectReferenceLinePointOntoShell",wrapup);

  retFlag = 1;

  sts  = OM_S_SUCCESS ;
  *msg = MSSUCC ;

wrapup:

  // Free intermediate/temporary stuff
  VSpsiFreeInfo(info,0);
  if (tmpsf) BSfreesf( &bsRC, tmpsf ) ;

  __exitFunction ( name = "VSpsiProcessPlaneExtendedSurf", argfmt = "sts = %d, msg = %#x, retFlag = %d, info->crv.cnt = %d, havePjRLP = %d",
                   args = `sts, *msg, retFlag, info->crv.cnt, *havePjRLP` );

  return retFlag;
}

end implementation Root;
