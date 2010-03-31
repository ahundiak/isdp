/*
  DESCRIPTION
    Implements the methods needed to incorporate a circle element into a
    profile.  2 SKptvars are created for a circle.  One of the ptvars
    is attached to a SKpoint that is also created.  
  
  HISTORY
    ????          : ??????? : Creation.
    Rajiv Agrawal : 12/1/92 : Code cleanup and standardization.
    Rajiv Agrawal : 1/25/93 : Removed SKcreate_constraints method.
    Sudha         : 7/02/93 : Modified for BSprototypes ansification
*/

class implementation SKcircle;

#include "grdpbdef.h"
#include "grdpb.h"
#include "gocmacros.h"
#include "ma.h"
#include "marotmx.h"
#include "maptsxfor.h"
#include "mamulmx.h"
#include "bsprepcircp.h"
#include "bsnorvec.h"
#include "bsmkvec.h"
#include "bsdistptpt.h"

#define CIRCUM  0
#define CENTRE  1

extern OMuword OPP_SKptvar_class_id, OPP_SKhorizvert_class_id,
               OPP_SKptpt_class_id;

from SKvariable   import   SKgetvar, SKputvar, SKgetprops;
from SKmgr        import   SKgetornt, SKget_xymat;
from SKconstraint import   SKinit;

method SKcreate_constraint_points(long *msg; 
                                  unsigned short options;
                                  short *matrix_type;
                                  double *matrix;
                                  OM_S_OBJID skmgr, *first, *last;
                                  int *element_no;
                                  int total_count)
{
  return (om$send (msg = message SKgeometry.SKcreate_ptvars (msg, options,
           matrix_type, matrix, NULL, NULL, &skmgr, NULL, NULL),
           targetid = my_id));
}

method SKrecompute_yourself (long *msg; struct GRmd_env *md_env;
                             short *mattyp_to_lxyz; double *mat_to_lxyz)
{
  OM_S_CHANSELECT       geom_pts_chan, pts_mgr_chan, pts_cnstr_chan;
  struct GRpost_info    post_info;
  struct IGRbsp_curve   cv_geom;
  unsigned short        vprops;
  short                 xy_xyz_mattyp;
  double                pts[6], mgr_point[3], x_axis[3], radius;
  double                cv_weights[BSCIRCLE_NUM_POLES_MAX],
                        cv_knots[BSCIRCLE_NUM_KNOTS_MAX],
                        cv_poles[BSCIRCLE_NUM_POLES_MAX*3];
  IGRvector             mgr_normal, dum_vec;
  long                  stat_OM, mthd_stat, rc, one=1;
  OMuint                num_dia;
  int                   i, type;
  IGRmatrix             rotmx, xy_xyz_mat;
  IGRvector             zvec, xvec, xf_xvec;
  IGRpoint              loc_xf_xvec_pt, xf_xvec_pt;
  GRobjid               newobjid, center_id, radial_ptid;
  GRspacenum            dum_os;
  unsigned short        xform_opts;

  short                 four=4, mattyp;
  double                *mat;
  IGRmatrix             mat_store;

  IGRboolean aflag = 0;
  aflag = pwIsActivationOn();

  stat_OM = OM_S_SUCCESS;
  *msg = EMS_S_Success;

  if (mattyp_to_lxyz && mat_to_lxyz)
  {
    xform_opts = SK_OPT_FULL_TRANSFORM;
    mattyp = md_env->md_env.matrix_type;
    if (mattyp != MAIDMX)
    {
      mat = mat_store;
      MAmulmx (&mthd_stat, &four, &four, &four, 
          md_env->md_env.matrix, mat_to_lxyz, mat);
      EMerr_hndlr (EMSerror (mthd_stat), *msg, EMS_E_Fail, ret_end);
      MAtypemx( &mthd_stat, mat, &mattyp);
    }
    else
    {
      mattyp = *mattyp_to_lxyz;
      mat = mat_to_lxyz;
    }
  }
  else
  {
    xform_opts = NULL;
    mattyp = md_env->md_env.matrix_type;
    mat = md_env->md_env.matrix;
  }

  cv_geom.poles = cv_poles;
  cv_geom.knots = cv_knots;
  cv_geom.weights = cv_weights;

  EMmake_chanselect (SKgeometry_to_defpts, &geom_pts_chan);
  stat_OM = om$send (msg = message SKvariable.SKgetvar (&mthd_stat,
      xform_opts, &mattyp, mat, pts),
      p_chanselect = &geom_pts_chan,
      from = 1, to = 1);
  EMerr_hndlr (!(1&stat_OM&mthd_stat),*msg,EMS_E_Fail,ret_end);

  stat_OM = om$get_objid_at_index (object = me, 
      p_chanselect = &geom_pts_chan, index = 0, 
      objidaddr = &radial_ptid, osnumaddr = &dum_os);
  EMerr_hndlr (!(1&stat_OM), *msg, EMS_E_OMerror, ret_end);

  EMmake_chanselect (SKvariable_to_constraints, &pts_cnstr_chan);
  stat_OM = om$get_channel_count (objid = radial_ptid, osnum = dum_os,
      p_chanselect = &pts_cnstr_chan, count = &num_dia);
  EMerr_hndlr (!(1&stat_OM), *msg, EMS_E_OMerror, ret_end);

  if (num_dia)
  {

    stat_OM = om$send (msg = message SKvariable.SKgetvar (&mthd_stat,
        xform_opts, &mattyp, mat,
        &pts[3]),
        targetid = radial_ptid);
    EMerr_hndlr (!(1&stat_OM&mthd_stat),*msg,EMS_E_Fail,ret_end);

    radius = BSdistptpt (&rc, pts, &pts[3]);
  }
  else 
    radius = ME.GR3dcircle->radius;

  stat_OM = om$get_objid_at_index (object = me, 
      p_chanselect = &geom_pts_chan, index = 1, 
      objidaddr = &center_id, osnumaddr = &dum_os);
  EMerr_hndlr (!(1&stat_OM), *msg, EMS_E_OMerror, ret_end);

  EMmake_chanselect (SKvariable_to_mgr, &pts_mgr_chan);
  stat_OM = om$send (msg = message SKmgr.SKgetornt(&mthd_stat, mgr_point,
      x_axis, mgr_normal),
      senderid = center_id, p_chanselect = &pts_mgr_chan);
  EMerr_hndlr (!(1&stat_OM&mthd_stat),*msg,EMS_E_Fail,ret_end);

  if (aflag)
  {
    RFtransform(md_env->md_env.matrix, md_env->md_env.matrix_type, FALSE,
                x_axis, mgr_normal, NULL, mgr_point);
  }


 /*
  * Rotate the circumference point by the stored angle. This is the
  * start/end-point of the circle. Also, if the direction of this circle
  * is opposing (determined by the property-bit in the centre-variable),
  * then obtain the curve-geometry reversed.
  */

  zvec[0] = zvec[1] = 0.0; 
  zvec[2] = 1.0;
  MArotmx (&rc, zvec, &ME.SKcircle->radangle, rotmx);
  EMerr_hndlr (EMSerror (rc), *msg, EMS_E_MAerror, ret_end);

  /* rotate an x vector in the SKmgr plane to get the diameter point */
  xvec[0] = 1.0; 
  xvec[1] = xvec[2] = 0.0;
  MAptsxform (&rc, &one, rotmx, xvec, loc_xf_xvec_pt);
  EMerr_hndlr (EMSerror (rc), *msg, EMS_E_MAerror, ret_end);

  /* we have the point in the SKmgr plane, so we transform it to put it in the
    model space */
  stat_OM = om$send (msg = message SKmgr.SKget_xymat (&mthd_stat,
      SK_OPT_GET_XY_TO_XYZ,
      &md_env->md_env.matrix_type, md_env->md_env.matrix,
      &xy_xyz_mattyp, xy_xyz_mat),
      senderid = center_id, p_chanselect = &pts_mgr_chan);
  EMerr_hndlr (EMSerror (stat_OM & mthd_stat), *msg, EMS_E_Fail, ret_end);

  MAptsxform (&rc, &one, xy_xyz_mat, loc_xf_xvec_pt, xf_xvec_pt);
  EMerr_hndlr (EMSerror (rc), *msg, EMS_E_MAerror, ret_end);

  /* we make sure that the vector is still normalized (since the end
    point - not the vector - has been rotated */
  BSmkvec (&rc, xf_xvec, mgr_point, xf_xvec_pt);
  BSnorvec (&rc, xf_xvec);
  EMerr_hndlr (rc != BSSUCC, *msg, EMS_E_BSerror, ret_end);

  /* we compute the diameter point */
  for (i=0; i<3; i++)
    pts[3+i] = pts[i] + xf_xvec[i] * radius;

  vprops = NULL;
  om$send (msg = message SKvariable.SKgetprops (&rc, &vprops),
      p_chanselect = &geom_pts_chan, from = CENTRE, to = CENTRE);
  if (vprops & SK_VAR_NEGDIRGEOM)
    for (i=0; i<3; i++)
      mgr_normal[i] = -mgr_normal[i];

  BSprepcircp (&rc, pts, &pts[3], mgr_normal, &cv_geom, dum_vec, &type);
  EMerr_hndlr (rc != BSSUCC, *msg, EMS_E_BSerror, ret_end);

  post_info.construct_flag = FALSE;
  stat_OM = om$send (msg = message GRvg.GRpostabsg (&mthd_stat,
      md_env, &post_info, (IGRchar *) &cv_geom, &newobjid),
      targetid = my_id);
  EMerr_hndlr (!(1&stat_OM&mthd_stat), *msg, EMS_E_Fail, ret_end);

  GRabsg_del_by_objid(&my_id, &OM_Gw_current_OS);

ret_end:
  GR_NOTIFY_LISTENERS(msg, &stat_OM, GR_GEOM_MODIFIED);
  EMWRAPUP(*msg, stat_OM, "SKarc.SKrecompute_yourself");
  return (stat_OM);
}



method SKputradang (long *msg; double radang)
{
  *msg = EMS_S_Success;
  ME.SKcircle->radangle = radang;
  return (OM_S_SUCCESS);
}

end implementation SKcircle;
