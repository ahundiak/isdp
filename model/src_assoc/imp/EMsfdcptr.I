class implementation EMSsfdpr;

# include "EMS.h"
# include "parametric.h"
# include "EMSerrordef.h"
# include "godef.h" /* For GR_RIGID_RELATIONSHIP */
# include "nddef.h" /* For ND_TO_MACRO */
# include "EMSopt.h" /* For EMS_UNDO_SAVE */
# include "EMcp.h" /* For copy info */

from EMSsubbs import EMupdateGradata;

method NDcopy_to_root(IGRlong *EMmsg;IGRint cp_type;
                      struct GRmd_env *fr_env,*to_env;
                      struct GRid *newgrid)
{
 IGRlong status;

 status = OM_S_SUCCESS;
 *EMmsg = MSSUCC;

 newgrid->objid = NULL_OBJID;
 newgrid->osnum = to_env->md_id.osnum;

/*
 * This would perfrom a non-associative copy of myself.
 */

 status = om$send (msg = message EMAsurface.NDcopy_to_root (EMmsg,
                         cp_type, fr_env, to_env,
                         newgrid),
                   mode = OM_e_wrt_message,
                   targetid = my_id);
 EMerr_hndlr (!(1&status&*EMmsg), *EMmsg, MSFAIL, wrapup);

/*
 * Store the fact that the copy is neither active nor
 * in the active path.
 */
 {
  unsigned short props;
  IGRboolean action = FALSE;
  OM_S_OBJID top_dpr_id;

  status = om$send (msg = message EMSsurface.EMget_tree_top(EMmsg,
                          &top_dpr_id, NULL, NULL),
                    targetid = my_id);
  EMerr_hndlr(!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);

  if (!(top_dpr_id == my_id))
  {
/*
 * Turn the active state bit off.
 */
   props = EMSIS_ACTIVE_STATE;
   status = om$send (msg = message EMSdpr.EMsetprops(EMmsg, &action, &props),
                    targetid = newgrid->objid,
                    targetos = newgrid->osnum);
   EMerr_hndlr(!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);
  }
/*
 * Turn on the active path bit and the uneval state and null state bit
 * upon Dave's recommendation.
 */
  props = EMSIS_ACTIVE_PATH | EMS_UNEVAL_STATE | EMS_NULL_STATE;
  action = TRUE;
  status = om$send (msg = message EMSdpr.EMsetprops(EMmsg, &action, &props),
                   targetid = newgrid->objid,
                   targetos = newgrid->osnum);
  EMerr_hndlr(!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);
 }

wrapup:
 EMWRAPUP (*EMmsg, status, "In EMSsfdpr: NDcopy error");
 return (status);
}
end implementation EMSsfdpr;

