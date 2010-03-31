class implementation SKptonelmt;

/*
  HISTORY

	Sudha  :  07/02/93  :  Modified for BSprototypes ansification
*/

#include "OMmacros.h"
#include "bserr.h"
#include "bsptcvgen.h"

#define FIRST  0

from SKvariable import SKgetvar;
from SKgmhndlpt import SKinit;
from SKmgr import SKget_xymat;

method SKcreate_geom (IGRlong *msg; unsigned short options;
                      struct GRmd_env *md_env; GRobjid *geom_handle)
{
  IGRshort disp_level;
  IGRint hndl_exist;
  IGRlong index, stat_OM, msg_loc;
  IGRdouble ptcv_knots[4];
  IGRpoint ptval, ptcv_poles[2];
  GRobjid ptid, mgrobj, gmhndl, *gmhndls, dumobj;
  GRspacenum dumos;
  struct IGRdisplay disp_attr;
  struct GRvg_construct cnstr_list;
  struct GRid my_grid;
  struct IGRbsp_curve ptcv;
  struct GRpost_info post_info;
  OM_S_CHANSELECT chan_to_cnstrvars;
  IGRboolean aflag=0;
  IGRlong sts = 1;
  IGRshort *mattyp,xy_xyz_mattyp;
  IGRmatrix xy_xyz_mat;
  IGRdouble *mat;


  stat_OM = OM_S_SUCCESS;
  *msg = EMS_S_Success;

  aflag = pwIsActivationOn();
  /*
   * Get the point variable that is affected by this
   * constraint.
   */

  EMmake_chanselect (SKconstraint_to_variables, &chan_to_cnstrvars);
  ptid = NULL_OBJID;
  om$get_objid_at_index (object = me, p_chanselect = &chan_to_cnstrvars,
   index = FIRST, objidaddr = &ptid, osnumaddr = &dumos);
  EMerr_hndlr (IF_NULL_OBJID (ptid), *msg, EMS_E_InvalidCase, ret_end);

  stat_OM = om$send (msg = message SKconstraint.SKgetmgr (&msg_loc, &mgrobj),
             targetid = my_id);

  mattyp = &md_env->md_env.matrix_type;
  mat = md_env->md_env.matrix;

  /*
   * Get the world coordinate of my point. 
   */

  stat_OM = om$send (msg = message SKvariable.SKgetvar (&msg_loc,
             NULL, &md_env->md_env.matrix_type, md_env->md_env.matrix,
             ptval), targetid = ptid);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
 

  /*
   * The color, weight, level of the handle are obtained w.r.t current env.
   * Obtain any existing handles.
   */


  SKdisp_geomhandle (&msg_loc, OM_Gw_current_OS, mgrobj, 
   &disp_attr, &disp_level, NULL);
  EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);

  gmhndls = &gmhndl;
  SKexist_geomhandle (&msg_loc, OM_Gw_current_OS, my_id,
   1, &hndl_exist, &gmhndls);
  EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);

  /*
   * Initialize the special point handle. This point is drawn with 
   * a bigger weight.
   */

  ptcv.poles = (IGRdouble *) ptcv_poles;
  ptcv.knots = ptcv_knots;
  ptcv.weights = NULL;

  BSptcvgen (ptval, 2, FALSE, &ptcv, &msg_loc);
  EMerr_hndlr (msg_loc != BSSUCC, *msg, EMS_E_BSerror, ret_end);

  if(aflag)
  {
    /* Transform the ptval into Ref Space. SKinit needs the point in 
       Ref Space */
    
    int num_pts = 1;
    sts = RFinverse_pts( mat, num_pts, &ptval);
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
             SK_CNSTR_PTONELEM, 1, (IGRpoint *) ptval, 0, NULL),
             targetid = gmhndl);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);

  /*
   * Return one of the point handles as the geometric handle to this
   * constraint
   */

  if (geom_handle)
    *geom_handle = gmhndl;

ret_end:
  EMWRAPUP (*msg, stat_OM, "SKptonelmt.SKcreate_geom");
  return (stat_OM);
}

end implementation SKptonelmt;
