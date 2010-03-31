/*
  DESCRIPTION

    This function is used to perform the update of the geometry elements
    that comprise the system. Optionally, a list of the variables that
    have changed may be passed in. This method then updates only those
    geom-elements that have been affected.

  HISTORY

    SS  :  08/13/90  :  Creation
*/

class implementation SKmgr;

#include "grdpbdef.h"
#include "grdpbmacros.h"

from SKgeometry import SKrecompute_yourself;

method SKgeom_update (IGRlong *msg; IGRushort opts;
                      struct SKsolvevars *chg_vars;
                      struct GRmd_env *mod_env)
{
  IGRshort mattyp_to_lxyz;
  IGRint i;
  OMuint count;
  IGRlong msg_loc, stat_OM;
  IGRmatrix mat_to_lxyz;
  enum GRdpmode disp_mode;
  OM_S_CHANSELECT chan_to_components;
  IGRboolean      aflag = 0;
  struct GRmd_env display_env;

  gr$get_module_env(buffer = &display_env);
  aflag = pwIsActivationOn();
 
  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  EMmake_chanselect (GRcmpowner_to_components, &chan_to_components);

  if (opts & SK_UPDATE_ERASE)
    {
    disp_mode = GRbehe;
    stat_OM = om$send (msg = message GRgraphics.GRdisplay (&msg_loc,
               aflag?&display_env.md_env.matrix_type:
               &mod_env->md_env.matrix_type, 
               aflag?display_env.md_env.matrix:
               mod_env->md_env.matrix,
               &disp_mode, 
               aflag?&display_env.md_id:
               &mod_env->md_id),
               p_chanselect = &chan_to_components);
    EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
    }

  if (! (opts & SK_UPDATE_DONOTPOST))
    {
    stat_OM = om$send (msg = message SKmgr.SKget_xymat (&msg_loc,
               SK_OPT_GET_XY_TO_LXYZ, NULL, NULL, &mattyp_to_lxyz,
               mat_to_lxyz), targetid = my_id);
    EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);

    count = 0;
    om$get_channel_count (object = me, p_chanselect = &chan_to_components,
     count = &count);
    if (count)
      {
      for (i=0; i<count; i++)
        {
        stat_OM = om$send (msg = message SKgeometry.SKrecompute_yourself (
                   &msg_loc, mod_env, &mattyp_to_lxyz, mat_to_lxyz),
                   p_chanselect = &chan_to_components, from = i, to = i);
        EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);

        if (msg_loc == EMS_I_Degenerate)
          *msg = msg_loc;
        }
      }
    }

  if (opts & SK_UPDATE_DRAW)
    {
    disp_mode = GRbd;
    stat_OM = om$send (msg = message GRgraphics.GRdisplay (&msg_loc,
               aflag?&display_env.md_env.matrix_type:
               &mod_env->md_env.matrix_type, 
               aflag?display_env.md_env.matrix:
               mod_env->md_env.matrix,
               &disp_mode, 
               aflag?&display_env.md_id:
               &mod_env->md_id),
               p_chanselect = &chan_to_components);
    EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
    }

ret_end:
  EMWRAPUP (*msg, stat_OM, "SKmgr.SKgeom_update");
  return (stat_OM);
}

end implementation SKmgr;
