class implementation SKhorizvert;

/*
  HISTORY

	Sudha  :  07/02/93  :  Modified for BSprototypes ansification
*/

#include "bserr.h"
#include "dimdef.h"
#include "dimdload.h"
#include "dim.h"
#include "dimmacros.h"
#include "bsptcvgen.h"
#include "bsnorvec.h"
#include "bscrossp.h"
#include "madef.h"
#include "mainvmx.h"
#include "maoptsxfo.h"
#include "matypemx.h"

#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;

#define FIRST  0
#define SECOND 1

extern GRclassid OPP_SKline_class_id;

from SKmgr import SKgetornt, SKget_xymat;
from SKvariable import SKgetvar, SKgetmgr;
from SKgmhndlpt import SKinit;

method SKcreate_geom (IGRlong *msg; unsigned short options;
                      struct GRmd_env *md_env; GRobjid *geom_handle)
{
  IGRboolean aflag=0;
  IGRboolean line_found;
  IGRshort *mattyp, xy_xyz_mattyp, disp_level, invmxtyp=MAIDMX;
  IGRuint count;
  IGRint i, j, k, hndl_exist;
  IGRlong index, stat_OM, msg_loc, sts=1;
  IGRdouble *mat, disp_len, ptcv_knots[4], *curr_vec;
  IGRpoint ptvals[2], anchorpt, crosspts[4],  ptcv_poles[2];
  IGRvector zaxis, xaxis, yaxis;
  IGRmatrix xy_xyz_mat, invmx;
  GRobjid ptids[2], geomid, mgrobj, dumobj, gmhndl, *gmhndls;
  struct IGRdisplay disp_attr;
  struct GRvg_construct cnstr_list;
  struct GRid my_grid;
  struct IGRbsp_curve ptcv;
  struct GRpost_info post_info;
  OM_S_CHANSELECT chan_to_cnstrvars;
  OM_S_OBJECT_LINKAGE objlist[3];

  stat_OM = OM_S_SUCCESS;
  *msg = EMS_S_Success;

  aflag = pwIsActivationOn();

  /*
   * Get the list of point variables defining this 
   * constraint.
   */

  EMmake_chanselect (SKconstraint_to_variables, &chan_to_cnstrvars);
  count = 0;
  om$get_channel_objects (object = me, p_chanselect = &chan_to_cnstrvars,
   count = &count, size = 3, list = objlist);
  EMerr_hndlr (count != 2, *msg, EMS_E_InvalidCase, ret_end);

  for (i=FIRST; i<=SECOND; i++)
    ptids[i] = objlist[i].S_objid;

  /*
   * Get the world coordinate of both my points. 
   */

  stat_OM = om$send (msg = message SKvariable.SKgetmgr (&msg_loc, &mgrobj),
             targetid = ptids[FIRST]);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);

  mattyp = &md_env->md_env.matrix_type;
  mat = md_env->md_env.matrix;

  /*
   * Get the matrix that wil transform the plane space ptvars to model space.
   */
  stat_OM = om$send (msg = message SKmgr.SKget_xymat (&msg_loc, 
             SK_OPT_GET_XY_TO_XYZ, mattyp, mat, &xy_xyz_mattyp, xy_xyz_mat),
             targetid = mgrobj);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);

  /*
   * Get the points corresponding to the ptvars in model space.
   */
  for (i=FIRST; i<=SECOND; i++)
    {
    stat_OM = om$send (msg = message SKvariable.SKgetvar (&msg_loc,
               SK_OPT_FULL_TRANSFORM, &xy_xyz_mattyp, xy_xyz_mat, ptvals[i]),
               targetid = ptids[i]);
    EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
    }

  /*
   * The color, weight, level of the handle are obtained w.r.t current env.
   * Obtain any existing handles.
   */

  SKdisp_geomhandle (&msg_loc, OM_Gw_current_OS, mgrobj, 
   &disp_attr, &disp_level, &disp_len);
  EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
  disp_len /= 2.0;

  gmhndls = &gmhndl;
  SKexist_geomhandle (&msg_loc, OM_Gw_current_OS, my_id,
   1, &hndl_exist, &gmhndls);
  EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);

  /*
   * A hor-ver cross is drawn at the mid-point between the two points.
   */

  stat_OM = om$send (msg = message SKmgr.SKgetornt (&msg_loc, NULL, xaxis,
             zaxis), targetid = mgrobj);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);

  if(aflag)
  {
    /*
     * SKgetornt gets the axis vectors in ref-space. consciously transform them
     * to model space.
     */
    sts = RFtransform( mat, *mattyp, FALSE, xaxis, NULL, zaxis, NULL);
    EMerr_hndlr (!(1&sts), *msg, EMS_E_Fail, ret_end);
  }

  BScrossp (&msg_loc, zaxis, xaxis, yaxis);
  EMerr_hndlr (msg_loc != BSSUCC, *msg, EMS_E_BSerror, ret_end);

  BSnorvec (&msg_loc, yaxis);
  EMerr_hndlr (msg_loc != BSSUCC, *msg, EMS_E_BSerror, ret_end);

  for (i=0; i<3; i++)
    anchorpt[i] = ptvals[FIRST][i] +
                   (ptvals[SECOND][i] - ptvals[FIRST][i]) / 2.0;

  for (i=FIRST, j=0; i<=SECOND; i++, j+=2)
    {
    curr_vec = i == FIRST ? xaxis : yaxis;
    for (k=X; k<=Z; k++)
      {
      crosspts[j][k] = anchorpt[k] + disp_len * curr_vec[k];
      crosspts[j+1][k] = anchorpt[k] - disp_len * curr_vec[k];
      }
    }

  if(aflag)
  {
    /*
     * The crosspts and ptvals have been computed in model space. But as the 
     * geometric handle's SKinit needs them in ref-space, transform them, 
     * by the inverse of mat.
     */
    int num_pts = 4;
    sts = RFinverse_pts( mat, num_pts, crosspts);
    EMerr_hndlr (!(1&sts), *msg, EMS_E_Fail, ret_end);

    num_pts = 2;
    sts = RFinverse_pts( mat, num_pts, ptvals);
    EMerr_hndlr (!(1&sts), *msg, EMS_E_Fail, ret_end);
  }

  /*
   * Figure out if these two points define a real line in the
   * data-base.
   */

  SKget_included_geom (&msg_loc, NULL, ptids, OPP_SKline_class_id, &geomid);
  EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
  line_found = msg_loc == EMS_I_Found;

  /*
   * The defining points (in case this constraint is not a data-base line) and
   * the points for the cross are used to initialize the special point handle. 
   */

  ptcv.poles = (IGRdouble *) ptcv_poles;
  ptcv.knots = ptcv_knots;
  ptcv.weights = NULL;

  BSptcvgen (anchorpt, 2, FALSE, &ptcv, &msg_loc);
  EMerr_hndlr (msg_loc != BSSUCC, *msg, EMS_E_BSerror, ret_end);

  if (!hndl_exist)
    {
    EMinitvgcnstr (&msg_loc, md_env, &disp_attr, NULL, &cnstr_list);
    EMgetvgcnstr (NULL, NULL, md_env, disp_level, &disp_attr, NULL, NULL,
     &cnstr_list);

    cnstr_list.geometry = (IGRchar *) &ptcv;
    stat_OM = om$construct (classid = OPP_SKgmhndlpt_class_id,
               msg = message GRgraphics.GRconstruct (&cnstr_list),
               p_objid = &gmhndl);
    EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);

    my_grid.objid = my_id;
    my_grid.osnum = OM_Gw_current_OS;
    index = OM_K_MAXINT;
    stat_OM = om$send (msg = message GRconnector.GRrigidconn (&msg_loc,
               &my_grid, &index), targetid = gmhndl);
    EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
    }
  else
    {
    post_info.construct_flag = FALSE;
    stat_OM = om$send (msg = message GRvg.GRpostabsg (&msg_loc, md_env,
               &post_info, (IGRchar *) &ptcv, &dumobj), targetid = gmhndl);
    EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);

    stat_OM = om$send (msg = message GRvg.GRchgdp (&msg_loc, &disp_attr),
               targetid = gmhndl);
    EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
    }

  stat_OM = om$send (msg = message SKgmhndlpt.SKinit (&msg_loc, NULL,
             SK_CNSTR_HORIZVERT, 4, crosspts, line_found ? 0 : 2, ptvals),
             targetid = gmhndl);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);

  /*
   * Return one of the point handles as the geometric handle to this
   * constraint
   */

  if (geom_handle)
    *geom_handle = gmhndl;

ret_end:
  EMWRAPUP (*msg, stat_OM, "SKhorizvert.SKcreate_geom");
  return (stat_OM);
}

end implementation SKhorizvert;
