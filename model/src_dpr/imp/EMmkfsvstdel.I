/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsfmkface;

#include "EMS.h"
extern OMuword OPP_EMSsubbs_class_id;

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
    DLB 04/01/91 Ignore error returns when deleting added edges.
    DLB 03/12/91 If ssi then don't delete the added surfs.
    RC  11/17/89 Check the validity of the edge_out before deleting it.
    DLB 11/08/87 Modified for version 1.1.0
    DLB 05/19/87 creation.
*/
{
 IGRlong               OM_stat;
 IGRint                num_sf_comp=0;
 union EMSssi_table    *mod_table;
 struct GRid *sf_comp_ids=NULL;
 struct EMSmfssi_table *my_info;
 IGRint                i, j, k;


 *EMmsg = EMS_S_Success;
 OM_stat = OM_S_SUCCESS;
 mod_table = NULL;
 
 if (!ssi)
 {
   /*Get the table of objects to delete from me.*/
   OM_stat = om$send(msg = message EMSdpr.EMgetSSI(EMmsg, &mod_table),
                     targetid = my_id);
   if (! (1 & OM_stat & *EMmsg)) goto wrapup;
 }
 else
   mod_table = ssi;

 my_info = &mod_table->mf_info;
 if (ME.EMSdpr->dpr_props & EMSIS_ACTIVE_PATH)
 {
   /*Delete all out loops.*/
   k=0;
   for (i = 0; i < my_info->num_surfaces; i++)
   {
     for (j = 0; j < my_info->num_regions_out[i]; j++)
     {
       OM_stat = om$send(msg = message Root.delete(NULL),
                         targetid = my_info->region_out_ids[k]);
       if (! (1 & OM_stat)) goto wrapup;
       k++;
     }
   }

   /*Delete all out edges.*/
   k=0;
   for (i = 0; i < my_info->num_regions; i++)
   {
     for (j = 0; j < my_info->num_edges_out[i]; j++)
     {
       /*
        * It may be possible that out edge has already been deleted
        * by one of its part edges. Threfore, check the validity of
        * the edge before deleting it. -- RC  11/17/89
        */

       OM_stat = om$is_objid_valid (objid = my_info->edge_out_ids[k],
                    osnum = OM_Gw_current_OS);

       if (OM_stat == OM_S_SUCCESS)
       {
        OM_stat = om$send(msg = message Root.delete(NULL),
                          targetid = my_info->edge_out_ids[k]);
        if (! (1 & OM_stat)) goto wrapup;
       }
       else OM_stat = OM_S_SUCCESS;

       k++;
     }
   }

 }
 else   /*Not active.*/
 {
   /*Delete all in loops.*/
   k=0;
   for (i = 0; i < my_info->num_surfaces; i++)
   {
     for (j = 0; j < my_info->num_regions_in[i]; j++)
     {
       if(my_info->region_in_ids[k] != NULL_OBJID)
       {
         OM_stat = om$send(msg = message Root.delete(NULL),
                           targetid = my_info->region_in_ids[k]);
         if (! (1 & OM_stat)) goto wrapup;
       }
       k++;
     }
   }

   /*Delete all in edges.*/
   k=0;
   for (i = 0; i < my_info->cum_num_edges_out; i++) /* RC */
   {
     for (j = 0; j < my_info->num_edges_in[i]; j++)
     {
       if(my_info->edge_in_ids[k] != NULL_OBJID)
       {
         /*Removed error checks - DLB 4/2/91*/
         om$send(msg = message Root.delete(NULL),
                 targetid = my_info->edge_in_ids[k]);
       }
       k++;
     }
   }

   if (!ssi)
   {
     /*Delete all added surfaces.*/
     struct GRid mod_sf_GRid, my_GRid;
     OM_S_CHANSELECT sfcomp_chan;

     sfcomp_chan.type = OM_e_addr;
     sfcomp_chan.u_sel.addr = &ME.GRcmpowner->to_components;  
     my_GRid.objid = my_id;
     my_GRid.osnum = OM_Gw_current_OS;
     mod_sf_GRid.objid = my_info->surface_ids[0];
     mod_sf_GRid.osnum = OM_Gw_current_OS;
  
     EFgetobjids(EMmsg, &my_GRid, &sfcomp_chan, &sf_comp_ids,
                 &num_sf_comp, OPP_EMSsubbs_class_id, &mod_sf_GRid, 1);
     if (!(1 & *EMmsg)) goto wrapup;

     for (i = 0; i < num_sf_comp; i++)
     {
       OM_stat = om$send (msg = message GRgraphics.GRdelete(EMmsg, my_env), 
                          targetid = sf_comp_ids[i].objid);
       if (!(1 & OM_stat & *EMmsg)) goto wrapup;
     } 
   }
 } /*end else*/

 if (!ssi)
 {
   /*Reset the instance data*/

   ME.EMSsfregmod->num_surfaces = 0;
   ME.EMSsfmkface->num_regions = 0;
   ME.EMSsfmkface->num_edges_out = 0;  /* RC */
   ME.EMSsfmkface->num_edges_copied = 0; /* SM 09/27/92 */
 }
 
 wrapup:
  if (mod_table && !ssi) om$dealloc(ptr = mod_table);
  if (sf_comp_ids) om$dealloc(ptr = sf_comp_ids);
  EMWRAPUP(*EMmsg, OM_stat, "In EMSsfmkface.EMsavestatedelete");
  return(OM_stat);
}
end implementation EMSsfmkface;
