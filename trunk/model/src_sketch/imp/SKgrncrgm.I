class implementation SKground;

/*
  HISTORY

	Sudha  :  07/02/93  :  Modified for BSprototypes ansification
*/

#include "OMmacros.h"
#include "dimdef.h"
#include "dimdload.h"
#include "dim.h"
#include "dimmacros.h"
#include "bserr.h"
#include "bsptcvgen.h"
#include "bsnorvec.h"
#include "bscrossp.h"

#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;

#define FIRST  0
#define SECOND 1
#define THIRD  2
#define FOURTH 3

#define X 0
#define Y 1
#define Z 2

#define POSITIVE  1
#define NEGATIVE  -1

/*
 * To create an equilateral triangle with base = L, the altitude as
 * a function of L = L/2 * tan(60) = l * 0.86602.
 */

#define ALTITUDE_FACTOR 0.86602

from SKmgr import SKgetornt;
from SKvariable import SKgetvar;
from SKgmhndlpt import SKinit;

method SKcreate_geom (IGRlong *msg; unsigned short options;
                      struct GRmd_env *md_env; GRobjid *geom_handle)
{
  IGRshort disp_level;
  IGRuint count;
  IGRint sign, i, j, hndl_exist;
  IGRlong index, stat_OM, msg_loc;
  IGRdouble disp_len, ptcv_knots[4];
  IGRpoint ptval, tripts[4], ptcv_poles[2];
  IGRvector xaxis, yaxis, zaxis;
  GRobjid ptid, mgrobj, gmhndl, dumobj, *gmhndls;
  struct IGRdisplay disp_attr;
  struct GRvg_construct cnstr_list;
  struct GRid my_grid;
  struct IGRbsp_curve ptcv;
  struct GRpost_info post_info;
  OM_S_CHANSELECT chan_to_cnstrvars;
  OM_S_OBJECT_LINKAGE objlist;
  long sts = 1;

  IGRmatrix t_mat;
  IGRshort t_type;
  IGRboolean aflag;

  stat_OM = OM_S_SUCCESS;
  *msg = EMS_S_Success;

  /*
   * Get the list of point variables defining this 
   * constraint.
   */

  EMmake_chanselect (SKconstraint_to_variables, &chan_to_cnstrvars);
  count = 0;
  om$get_channel_objects (object = me, p_chanselect = &chan_to_cnstrvars,
   count = &count, size = 1, list = &objlist);
  EMerr_hndlr (count != 1, *msg, EMS_E_InvalidCase, ret_end);
  ptid = objlist.S_objid;

  /*
   * Get the world coordinate of my point. 
   */

  aflag = pwIsActivationOn();
  stat_OM = om$send (msg = message SKvariable.SKgetvar (&msg_loc,
             NULL, &md_env->md_env.matrix_type, md_env->md_env.matrix,
             ptval), targetid = ptid);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);

  /*
   * The color, weight, level of the handle are obtained w.r.t current env.
   * Obtain any existing handles.
   */

  stat_OM = om$send (msg = message SKconstraint.SKgetmgr (&msg_loc, &mgrobj),
             targetid = my_id);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);

  SKdisp_geomhandle (&msg_loc, OM_Gw_current_OS, mgrobj, 
   &disp_attr, &disp_level, &disp_len);
  EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
  disp_len /= 2.0;

  gmhndls = &gmhndl;
  SKexist_geomhandle (&msg_loc, OM_Gw_current_OS, my_id,
   1, &hndl_exist, &gmhndls);
  EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);

  /*
   * A triangle is drawn with the apex at them constrained point.
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
    sts = RFtransform(md_env->md_env.matrix , md_env->md_env.matrix_type,
                      FALSE, xaxis, NULL, zaxis, NULL);
    EMerr_hndlr (!(1&sts), *msg, EMS_E_Fail, ret_end);
  }


  BScrossp (&msg_loc, zaxis, xaxis, yaxis);
  EMerr_hndlr (msg_loc != BSSUCC, *msg, EMS_E_BSerror, ret_end);

  BSnorvec (&msg_loc, yaxis);
  EMerr_hndlr (msg_loc != BSSUCC, *msg, EMS_E_BSerror, ret_end);


  for (i=FIRST, sign=POSITIVE; i<=SECOND; i++, sign=NEGATIVE)
    for (j=X; j<=Z; j++)
      tripts[i][j] = ptval[j] + sign * disp_len * xaxis[j] -
                      disp_len * ALTITUDE_FACTOR * yaxis[j];
  OM_BLOCK_MOVE (ptval, tripts[THIRD], sizeof (IGRpoint));
  OM_BLOCK_MOVE (tripts[FIRST], tripts[FOURTH], sizeof (IGRpoint));

  /*
   * Initialize the special point handle. 
   */

  ptcv.poles = (IGRdouble *) ptcv_poles;
  ptcv.knots = ptcv_knots;
  ptcv.weights = NULL;

  BSptcvgen (ptval, 2, FALSE, &ptcv, &msg_loc);
  EMerr_hndlr (msg_loc != BSSUCC, *msg, EMS_E_BSerror, ret_end);

  if(aflag)
  {
    /*
     * The tripts have been computed in model space. But as the geometric
     * handle's SKinit needs that in ref-space, transform them to ref-space
     * by the inverse of mat.
     */
    int num_pts = 4;
    sts = RFinverse_pts(md_env->md_env.matrix , num_pts, tripts);
    EMerr_hndlr (!(1&sts), *msg, EMS_E_Fail, ret_end);
  }
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
             SK_CNSTR_GROUND, 4, tripts, 0, NULL), targetid = gmhndl);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);

  /*
   * Return one of the point handles as the geometric handle to this
   * constraint
   */

  if (geom_handle)
    *geom_handle = gmhndl;

ret_end:
  EMWRAPUP (*msg, stat_OM, "SKground.SKcreate_geom");
  return (stat_OM);
}

end implementation SKground;
