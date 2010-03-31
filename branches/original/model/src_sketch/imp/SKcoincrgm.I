class implementation SKcoincident;

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
#define FIFTH  4

#define X 0
#define Y 1
#define Z 2

#define POS  1
#define NEG  -1

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
  IGRint s1, s2, i, j, hndl_exist;
  IGRlong index, stat_OM, msg_loc;
  IGRdouble disp_len, ptcv_knots[4];
  IGRpoint ptval, dtripts[5], ptcv_poles[2];
  IGRvector xaxis, yaxis, zaxis;
  GRobjid dumobj, cnstrid, ptid, mgrobj, gmhndl, *gmhndls;
  GRspacenum dum_os;
  struct GRvg_construct cnstr_list;
  struct GRid my_grid;
  struct IGRbsp_curve ptcv;
  struct IGRdisplay disp_attr;
  struct GRpost_info post_info;
  OM_S_CHANSELECT chan_to_cnstrvars, chan_to_memcnstrs;
  IGRboolean aflag = 0;
  IGRlong sts = 1;

  stat_OM = OM_S_SUCCESS;
  *msg = EMS_S_Success;

  aflag = pwIsActivationOn();
  /*
   * Get a point variable that is a part of this constraint. Any one out
   * of the two unique ones will suffice.
   */

  EMmake_chanselect (SKinterface_to_member_constrs, &chan_to_memcnstrs);
  cnstrid = NULL_OBJID;
  om$get_objid_at_index (object = me, p_chanselect = &chan_to_memcnstrs,
   index = FIRST, objidaddr = &cnstrid, osnumaddr = &dum_os);
  EMerr_hndlr (IF_NULL_OBJID (cnstrid), *msg, EMS_E_InvalidCase, ret_end);

  EMmake_chanselect (SKconstraint_to_variables, &chan_to_cnstrvars);
  ptid = NULL_OBJID;
  om$get_objid_at_index (objid = cnstrid, p_chanselect = &chan_to_cnstrvars,
   index = FIRST, objidaddr = &ptid, osnumaddr = &dum_os);
  EMerr_hndlr (IF_NULL_OBJID (ptid), *msg, EMS_E_InvalidCase, ret_end);

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

  stat_OM = om$send (msg = message SKconstraint.SKgetmgr (&msg_loc, &mgrobj),
             targetid = my_id);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);

  SKdisp_geomhandle (&msg_loc, OM_Gw_current_OS, mgrobj, 
   &disp_attr, &disp_level, &disp_len);
  EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);

  gmhndls = &gmhndl;
  SKexist_geomhandle (&msg_loc, OM_Gw_current_OS, my_id,
   1, &hndl_exist, &gmhndls);
  EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);

  /*
   * An hour-glass triangle is drawn with the centre at the constrained point.
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

  disp_len /= 2.0;
  for (i=FIRST, s1=POS, s2=NEG; i<=FOURTH; i++, s1=-s1, s2=i>SECOND?POS:NEG)
    for (j=X; j<=Z; j++)
      dtripts[i][j] = ptval[j] + s1 * disp_len * xaxis[j] +
                      s2 * disp_len * ALTITUDE_FACTOR * yaxis[j];
  OM_BLOCK_MOVE (dtripts[FIRST], dtripts[FIFTH], sizeof (IGRpoint));

  if(aflag)
  {
    /*
     * The dtripts have been computed in model space. But as the geometric
     * handle's SKinit needs that in ref-space, transform them to ref-space
     * by the inverse of mat.
     */
    int  num_pts=5;
    sts = RFinverse_pts( md_env->md_env.matrix, num_pts, dtripts);
    EMerr_hndlr (!(1&sts), *msg, EMS_E_Fail, ret_end);
  }
  /*
   * Initialize the special point handle. If no handle exists, one is
   * created with current display and level. Else, the display attributes
   * are changed to current env.
   */

  ptcv.poles = (IGRdouble *) ptcv_poles;
  ptcv.knots = ptcv_knots;
  ptcv.weights = NULL;

  BSptcvgen (ptval, 2, FALSE, &ptcv, &msg_loc);
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
             SK_CNSTR_COINCIDENT, 5, dtripts, 0, NULL), targetid = gmhndl);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);

  /*
   * Return one of the point handles as the geometric handle to this
   * constraint
   */

  if (geom_handle)
    *geom_handle = gmhndl;

ret_end:
  EMWRAPUP (*msg, stat_OM, "SKcoincident.SKcreate_geom");
  return (stat_OM);
}

end implementation SKcoincident;
