/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsfregmod;

#include "EMS.h"
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
    mrm 06/10/91 If ssi is incoming then don't reset instance data
    DLB 11/03/87 Modified for version 1.1.0
    DLB 04/08/87 creation.
*/
{
 IGRlong                  OM_stat;
 IGRint                   i, j, k;
 GRobjid                  *id;
 union EMSssi_table       *mod_table;
 struct EMSsfssi_table    *my_info;


 *EMmsg = EMS_S_Success;
 OM_stat = OM_S_SUCCESS;
 mod_table = NULL;
 
 if (!ssi)
 {
   /*Get the table of objects to delete from me.*/
   OM_stat = om$send(msg = message EMSsfregmod.EMgetSSI(EMmsg, &mod_table),
                     targetid = my_id);
   if (! (1 & OM_stat & *EMmsg)) goto wrapup;
 }
 else 
   mod_table = ssi;

 my_info = &mod_table->sf_info;
 if (ME.EMSdpr->dpr_props & EMSIS_ACTIVE_PATH)
 {
   /*Delete all out loops*/
   id = my_info->region_out_ids;
   for (i = 0; i < my_info->num_surfaces; i++)
   {
     for (j = 0; j < my_info->num_regions_out[i]; j++)
     {
      if( (OM_stat = om$is_objid_valid(objid = *id)) 
		!= OM_S_SUCCESS) {OM_stat = OM_S_SUCCESS; id++; continue;}
		
       OM_stat = om$send(msg = message Root.delete(NULL),
                         targetid = *id);
       if (! (1 & OM_stat)) goto wrapup;
       id++;
     }
   }

   /*Delete all out edges.*/
   k=0;
   for (i = 0; i < my_info->num_regions; i++)
   {
     for (j = 0; j < my_info->num_edges_out[i]; j++)
     {
      if( (OM_stat = om$is_objid_valid(objid = my_info->edge_out_ids[k])) 
		!= OM_S_SUCCESS) {OM_stat = OM_S_SUCCESS; k++; continue;}
			
       OM_stat = om$send(msg = message Root.delete(NULL),
                         targetid = my_info->edge_out_ids[k]);
       if (! (1 & OM_stat)) goto wrapup;
       k++;
     }
   }

   /* Delete all the edges that were replaced by their copies*/
   for(i=0; i<my_info->num_edges_copied; i++)   
   {
     OM_stat = om$is_objid_valid(objid = my_info->ed_cp_ed_ids[2*i]);
     if(OM_stat == OM_S_SUCCESS)
       OM_stat = om$send(
			msg = message Root.delete(TRUE), 
			targetid = my_info->ed_cp_ed_ids[2*i]);
     else OM_stat = OM_S_SUCCESS;
   }   
 }
 else  /*Not active*/
 {
   /*Delete all in loops*/
   id = my_info->region_in_ids;
   for (i = 0; i < my_info->num_surfaces; i++)
   {
     for (j = 0; j < my_info->num_regions_in[i]; j++)
     {
      if( (OM_stat = om$is_objid_valid(objid = *id)) 
		!= OM_S_SUCCESS) {OM_stat = OM_S_SUCCESS; id++; continue;}
		
       if(*id != NULL_OBJID)
       {
         OM_stat = om$send(msg = message Root.delete(NULL),
                           targetid = *id);
         if (! (1 & OM_stat)) goto wrapup;
       }
       id++;
     }
   }

   /*Delete all in edges.*/
   k=0;
   for (i = 0; i < my_info->cum_num_edges_out; i++) /* RC */
   {
     for (j = 0; j < my_info->num_edges_in[i]; j++)
     {
      if( (OM_stat = om$is_objid_valid(objid = my_info->edge_in_ids[k])) 
		!= OM_S_SUCCESS) {OM_stat = OM_S_SUCCESS; k++; continue;}
			
       if(my_info->edge_in_ids[k] != NULL_OBJID)
       {
         OM_stat = om$send(msg = message Root.delete(NULL),
                           targetid = my_info->edge_in_ids[k]);
         if (! (1 & OM_stat)) goto wrapup;
       }
       k++;
     }
   }

   /* Delete all the copy edges that replaced original edges*/
   for(i=0; i<my_info->num_edges_copied; i++)   
   {
     OM_stat = om$is_objid_valid(objid = my_info->ed_cp_ed_ids[2*i + 1]);
     if(OM_stat == OM_S_SUCCESS)
       OM_stat = om$send(mode = OM_e_wrt_message, msg = message Root.delete(TRUE), 
			targetid = my_info->ed_cp_ed_ids[2*i + 1]);
     else OM_stat = OM_S_SUCCESS;
   }   
 } /*end else*/

 /*Reset the instance data*/
 if (!ssi) ME.EMSsfregmod->num_surfaces = 0;

 wrapup:
  if (mod_table && !ssi) om$dealloc(ptr = mod_table);
  EMWRAPUP(*EMmsg, OM_stat, "In EMSsfregmod.EMsavestatedelete");
  return(OM_stat);
}
end implementation EMSsfregmod;
