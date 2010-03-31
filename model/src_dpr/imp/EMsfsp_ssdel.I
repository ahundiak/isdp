/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsfsplit;

#include "EMS.h"
#include "OMmacros.h"

extern OMuword OPP_EMSsubbs_class_id;

from EMSboundary import EMget_objid;

method EMsavestatedelete(IGRlong *EMmsg; struct GRmd_env *my_env;
                         union EMSssi_table *ssi)
/*
Description
    This method will delete the saved assoc info that is not currently in
    the topology.  ONLY information that would never get a delete message
    by another path should be deleted.

Return values
    EMS_S_Success if all is well.

History
    gupta 11/17/87 changed the edge delete logic
    DLB 11/03/87 Modified for version 1.1.0
    DLB 04/08/87 creation.
*/
{
 IGRlong                OM_stat;
 IGRlong                msg, msg1;
 IGRint                 i, num_surf_ids=0;
 IGRint                 EMsend_loops();
 GRobjid                loop_id;
 union EMSssi_table     *loc_ssi;
 struct EMSsspssi_table *my_info;
 struct GRid            *surf_ids=NULL;


 *EMmsg = EMS_S_Success;
 OM_stat = OM_S_SUCCESS;
 
 loc_ssi = NULL;
 my_info = NULL;

 if (!ssi)
 {
   OM_stat = om$send(msg = message EMSdpr.EMgetSSI(EMmsg, &loc_ssi),
                     targetid = my_id);
   if (!(1 & OM_stat & *EMmsg)) goto wrapup;
 }
 else
   loc_ssi = ssi;

 my_info = &loc_ssi->spl_info;

 if (ME.EMSdpr->dpr_props & EMSIS_ACTIVE_PATH)
 {
   /*Delete all REMOVED surfaces*/
   for (i = 0; i < my_info->num_srf; i ++)
   {
     OM_stat = om$send(msg = message GRgraphics.GRdelete(EMmsg, my_env),
                       targetid = my_info->srf_ids[i]);
     if (! (1 & OM_stat & *EMmsg)) goto wrapup;
   }
 }
 else
 {
   /*Delete the added surfaces on my to_comps channel.*/
   struct GRid temp_id;
   OM_S_CHANSELECT to_comps;

   to_comps.type = OM_e_addr;
   to_comps.u_sel.addr = &ME.GRcmpowner->to_components;
   temp_id.objid = my_id;
   temp_id.osnum = OM_Gw_current_OS;

   EFgetobjids(EMmsg, &temp_id, &to_comps, &surf_ids, &num_surf_ids, 
               OPP_EMSsubbs_class_id, NULL, 0);
   if (!(1 & *EMmsg)) goto wrapup;

   for (i=0; i<num_surf_ids; i++)
   {
     OM_stat = om$send(msg = message GRgraphics.GRdelete(EMmsg, my_env),
                       targetid = surf_ids[i].objid);
     if (!(1 & OM_stat & *EMmsg)) goto wrapup;
   }
 }

 for (i=0; i < my_info->num_edges; i++)
 {
   OM_stat = om$is_objid_valid(objid = my_info->edge_ids[i],
                               osnum = OM_Gw_current_OS);

   if (OM_stat != OM_S_SUCCESS)
     OM_stat = OM_S_SUCCESS;
   else
   { 
     OM_stat = EMsend_loops(&msg,
                            message EMSboundary.EMget_objid (&msg1,
                            &loop_id), my_info->edge_ids[i],0,OM_K_MAXINT,
                            EMLP_ACTIVE, NULL, NULL);
     EMerr_hndlr(EMis_error(msg1), *EMmsg, msg, wrapup);
     EMerr_hndlr(EMis_error(msg), *EMmsg, msg, wrapup);

     if ((ME.EMSdpr->dpr_props & EMSIS_ACTIVE_PATH) &&
         (IF_NULL_OBJID(loop_id)))
     {
       OM_stat = om$send(msg = message Root.delete(NULL),
                         targetid = my_info->edge_ids[i]);
       if (! (1 & OM_stat)) goto wrapup;
     }
     else 
     if (! (ME.EMSdpr->dpr_props & EMSIS_ACTIVE_PATH) &&
        (! (IF_NULL_OBJID(loop_id))))
     {
       OM_stat = om$send(msg = message Root.delete(NULL),
                         targetid = my_info->edge_ids[i]);
       if (! (1 & OM_stat)) goto wrapup;
     }
   }
   loop_id = NULL_OBJID;
 }

 wrapup:
  if (loc_ssi && !ssi) om$dealloc(ptr = loc_ssi);
  if (surf_ids) om$dealloc(ptr = surf_ids);
  EMWRAPUP(*EMmsg, OM_stat, "In EMSsfsplit.EMsavestatedelete")
  return(OM_stat);
}

end implementation EMSsfsplit;
