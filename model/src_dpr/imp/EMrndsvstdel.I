/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsfround;

extern OMuword OPP_EMSsubbs_class_id;

method EMsavestatedelete(IGRlong         *EMmsg;
                         struct GRmd_env *my_env;
                         union EMSssi_table *ssi)
/*
Description
    This method will delete the saved assoc info that is not currently in
    the topology.  ONLY information that would never get a delete message
    by another path should be deleted.

Return values
    EMS_S_Success if all is well.

History
    DLB   04/22/91 If ssi dont rest instance or delete added surfs.
    gupta 05/01/88 creation.
*/
{
 IGRlong                 stat_OM, msg;
 IGRint                  num_surf_ids = 0;
 IGRint                  i, j, k;
 union EMSssi_table      *mod_table;
 struct GRid             *surf_ids = NULL;
 struct GRid             my_GRid;
 struct EMSrndssi_table  *my_info;
 OM_S_CHANSELECT         to_comps;

/*------------------------------------------------------------------*/

 *EMmsg = EMS_S_Success;
 stat_OM = OM_S_SUCCESS;
 mod_table = NULL;
 
 if (!ssi)
 {
   /* Get the table of objects to delete from me */
   stat_OM = om$send(msg = message EMSdpr.EMgetSSI(&msg, &mod_table),
                     targetid = my_id);
   if (! (1 & stat_OM & msg)) goto wrapup;
 }
 else
   mod_table = ssi;

 my_info = &mod_table->rnd_info;

 if (ME.EMSdpr->dpr_props & EMSIS_ACTIVE_PATH)
 {
   /* Delete all out loops */
   k = 0;
   for (i=0; i<my_info->num_surfaces; i++)
   {
     for (j=0; j<my_info->num_regions_out[i]; j++)
     {
       stat_OM = om$send(msg = message Root.delete(NULL),
                         targetid = my_info->region_out_ids[k]);
       if (! (1 & stat_OM)) goto wrapup;
       k++;
     }
   }

   /* Delete all out edges */
   for (i=0; i<my_info->num_edges_out; i++)
   {
     stat_OM = om$send(msg = message Root.delete(NULL),
                       targetid = my_info->edge_out_ids[i]);
     if (! (1 & stat_OM)) goto wrapup;
   }
 }
 else   /* Not active */
 {
   /* Delete all in loops */
   k = 0;
   for (i=0; i<my_info->num_surfaces; i++)
    {
     for (j=0; j<my_info->num_regions_in[i]; j++)
      {
       if(my_info->region_in_ids[k] != NULL_OBJID)
        {
         stat_OM = om$send(msg = message Root.delete(NULL),
                           targetid = my_info->region_in_ids[k]);
         if (! (1 & stat_OM)) goto wrapup;
        }
      k++;
    }
   }

   /* Delete all in edges */
   k = 0;
   for (i=0; i<my_info->num_edges_out; i++)
   {
     for (j=0; j<my_info->num_edges_in[i]; j++)
     {
       if(my_info->edge_in_ids[k] != NULL_OBJID)
       {
         stat_OM = om$send(mode = OM_e_wrt_message,
                           msg = message Root.delete(NULL),
                           targetid = my_info->edge_in_ids[k]);
         if (! (1 & stat_OM)) goto wrapup;
       }
       k++;
     }
   }

   if (!ssi)
   {
     /* Delete all added surfaces */
     to_comps.type = OM_e_addr;
     to_comps.u_sel.addr = &ME.GRcmpowner->to_components;  
     my_GRid.objid = my_id;
     my_GRid.osnum = OM_Gw_current_OS;
    
     EFgetobjids (&msg, &my_GRid, &to_comps, &surf_ids, &num_surf_ids,
                  OPP_EMSsubbs_class_id, NULL, 0);
     if (! (1 & msg)) goto wrapup;
  
     for (i=0; i<num_surf_ids; i++)
     {
       stat_OM = om$send (msg = message GRgraphics.GRdelete(&msg,
                                my_env), 
                          targetid = surf_ids[i].objid);
       if (! (1 & stat_OM & msg)) goto wrapup;
     }
   } 
 }

wrapup:
 if (mod_table && !ssi) om$dealloc(ptr = mod_table);
 if (surf_ids) om$dealloc(ptr = surf_ids);
 EMWRAPUP(*EMmsg, stat_OM, "In EMSsfround.EMsavestatedelete");
 return(stat_OM);
}

end implementation EMSsfround;
