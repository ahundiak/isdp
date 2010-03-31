/* ###################   APOGEE COMPILED   ################## */
class implementation EMSparamgm;

#include "msdef.h"
#include "lcdef.h"
#include "lc.h"

#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;

method GRlocate (struct GRlc_cvl *cvl; 
                 OM_p_KEY_DESC range_key)
{
  IGRlong stat_OM;
  struct GRlc_info myinfo;
  enum GRlocate_action action;

  cvl->msg = MSSUCC;

  myinfo.located_obj.objid = my_id;
  myinfo.located_obj.osnum = OM_Gw_current_OS;
  OM_BLOCK_MOVE (&cvl->module, &myinfo.module_info, sizeof (struct GRmd_env));

  action = add_all; 
  stat_OM = (*cvl->action_handler) (cvl->act_parms, &myinfo, cvl->locate_args,
             &action);
  EMomerr_exit (stat_OM, ret_end);  

ret_end:
  if (stat_OM != OM_I_STOP_SENDING)
    stat_OM = OM_S_SUCCESS;
  return (stat_OM);
}


method GRdelete (IGRlong *msg; struct GRmd_env *md_env)
{
  *msg = EMS_S_Success;
  return (OM_S_SUCCESS);
}

method GRdisplay (IGRlong *msg; 
                  IGRshort *mattyp; IGRmatrix mat;
                  enum GRdpmode *dpmode;
                  struct GRid *win_or_mod_id)
{
  IGRlong msg_loc;

  om$send (msg = message EMSparamgm.EMdisplay (&msg_loc, NULL,
   mattyp, mat, NULL, *dpmode, win_or_mod_id), targetid = my_id);

  *msg = EMS_S_Success;
  return (OM_S_SUCCESS);
}

end implementation EMSparamgm;
