/* ###################   APOGEE COMPILED   ################## */
class implementation EMSloopset;

#include "EMSdpr.h"
#include "emsdef.h"

method EMmatch_topology(IGRlong *EMmsg; IGRushort options; struct
                        GRmd_env *md_env; GRobjid new_objid)
{
 IGRlong        OM_stat=OM_S_SUCCESS, EFsend_store_on(), EFmove_to_rhs();
 IGRboolean     EFmatch_classes();
 OM_S_CHANSELECT to_loops;
 

 *EMmsg = EMS_S_Success;

 if (!(options & EMstore_opt_MATCH_FAILED) && 
     !EFmatch_classes(EMmsg, my_id, new_objid, OM_Gw_current_OS, NULL))
 {
   options |= EMstore_opt_MATCH_FAILED;   
 }

 EMmake_chanselect(EMSloopset_to_loops, &to_loops);
 OM_stat = EFsend_store_on(EMmsg, my_id, OM_Gw_current_OS, new_objid,
                           &to_loops, options, md_env);
 if (!(1 & OM_stat & *EMmsg)) goto wrapup;                           

 /*Move my stuff to rhs (no tags if MATCH_FAILED)*/
 OM_stat = EFmove_to_rhs(EMmsg, my_id, new_objid, sender_id, OM_Gw_current_OS,
                         options); 
wrapup:
  EMWRAPUP(*EMmsg, OM_stat, "loopset.EMmatch_top");
  return(OM_stat);
}
end implementation EMSloopset;
