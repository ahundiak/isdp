/* ###################   APOGEE COMPILED   ################## */
class implementation EMSdpr;

#include "EMS.h"
#include "EMSmsgdef.h"

method EMprep_reex(IGRlong *EMmsg; struct GRmd_env *env)

/*
Description
    This method will traverse up the dpr tree setting the reexecute bit on
    for those states who need to be recomputed due to a change in history.

Return Values
    EMS_S_Success if all is well

Notes

History
   DLB 11/02/87 Modified for version 1.1.0
   DLB 4/29/87  creation.
*/
{
 IGRlong OM_stat = OM_S_SUCCESS;
 OM_S_CHANSELECT to_owners;


 *EMmsg = EMS_S_Success;

 if (ME.EMSdpr->dpr_props & EMS_PERFORM_REEX) goto wrapup;
 to_owners.type = OM_e_addr;
 to_owners.u_sel.addr = &ME.GRconnector->to_owners;

 OM_stat = om$send(msg = OPPmargs, p_chanselect = &to_owners);
 if (! (1 & OM_stat & *EMmsg) && (OM_stat != OM_W_UNKNOWN_MSG)) goto wrapup;

 /*Delete my save state info.*/
 OM_stat = om$send(msg = message EMSdpr.EMsavestatedelete(EMmsg, env, NULL),
                   targetid = my_id);
 if (! (1 & OM_stat & *EMmsg)) goto wrapup;

 ME.EMSdpr->dpr_props |= EMS_PERFORM_REEX;

 wrapup:
  EMWRAPUP(*EMmsg, OM_stat, "In EMSdpr.EMprep_reex")
  return(OM_stat);
}
end implementation EMSdpr;
