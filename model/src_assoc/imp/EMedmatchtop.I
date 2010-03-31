/* ###################   APOGEE COMPILED   ################## */
class implementation EMSedge;

#include "EMSdpr.h"

method EMmatch_topology(IGRlong *EMmsg;
                        IGRushort options;
                        struct GRmd_env *md_env;
                        GRobjid  new_objid)
{
 IGRlong        OM_stat=OM_S_SUCCESS, EFmove_to_rhs();
 IGRboolean     EFmatch_classes();
 

 *EMmsg = EMS_S_Success;

 if (!(options & EMstore_opt_MATCH_FAILED) &&
     !EFmatch_classes(EMmsg, my_id, new_objid, OM_Gw_current_OS, NULL))
 {
     options |= EMstore_opt_MATCH_FAILED;
 }

 /*Move my stuff to rhs*/
 OM_stat = EFmove_to_rhs(EMmsg, my_id, new_objid, sender_id, OM_Gw_current_OS,
                         options); 
wrapup:
  EMWRAPUP(*EMmsg, OM_stat, "edge.EMmatch_top")
  return(OM_stat);
}
end implementation EMSedge;
