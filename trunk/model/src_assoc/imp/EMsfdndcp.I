class implementation EMSsfdpr;

# include "EMS.h"
# include "parametric.h"
# include "EMSerrordef.h"
# include "godef.h" /* For GR_RIGID_RELATIONSHIP */
# include "nddef.h" /* For ND_TO_MACRO */
# include "EMSopt.h" /* For EMS_UNDO_SAVE */

from EMSsubbs import EMupdateGradata;

method NDcopy_graph(IGRlong *EMmsg;IGRint cp_type;
  		    struct GRmd_env *fr_env,*to_env;
		    struct NDcp_list *list;
                    int list_count;
		    int position)
{
 IGRlong status;
 OMuword copyos;
 struct NDcp_list *myinx;

 status = OM_S_SUCCESS;
 *EMmsg = MSSUCC;

 myinx = &list[position];
 myinx->original = my_id;
 myinx->clone = NULL_OBJID;

 copyos = to_env->md_id.osnum;

 status = om$send (msg = message EMAsurface.NDcopy_graph (EMmsg,
                         cp_type, fr_env, to_env,
                         list, list_count, position),
                   mode = OM_e_wrt_message,
                   targetid = my_id);
 EMerr_hndlr (!(1&status&*EMmsg), *EMmsg, MSFAIL, wrapup);

/*
 * Compress the SSI vla and store the fact that the copy is neither active nor
 * in the active path if I am in the body of the graph.
 */

 if (myinx->position & ND_BODY)
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
   props = EMSIS_ACTIVE_STATE;
   status = om$send (msg = message EMSdpr.EMsetprops(EMmsg, &action, &props),
                    targetid = myinx->clone,
                    targetos = copyos);
   EMerr_hndlr(!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);
  }

  props = EMSIS_ACTIVE_PATH | EMS_UNEVAL_STATE | EMS_NULL_STATE;

  action = TRUE;
  status = om$send (msg = message EMSdpr.EMsetprops(EMmsg, &action, &props),
                    targetid = myinx->clone,
                    targetos = copyos);
  EMerr_hndlr(!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);

  status = om$send (msg = message EMSsfdpr.EMresetSSI(EMmsg),
                    targetid = myinx->clone,
                    targetos = copyos);
  EMerr_hndlr(!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);
 }

wrapup:
 EMWRAPUP (*EMmsg, status, "In EMSsfdpr: NDcopy_graph error");
 return (status);
}
end implementation EMSsfdpr;

