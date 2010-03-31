/* ###################   APOGEE COMPILED   ################## */
class implementation EMSlift;

#include "EMS.h"
extern OMuword  OPP_EMSsubbs_class_id;

method EMsavestatedelete(
       IGRlong           *EMmsg; 
       struct GRmd_env   *md_env;
       union EMSssi_table *ssi)
/*
Description

    This method will delete the saved assoc info that is not currently in
    the topology.  ONLY information that would never get a delete message
    by another path should be deleted.

Return values
    EMS_S_Success if all is well.

History
        DLB  04/01/91        Dont del added surfs if ssi is incoming
        RC   04/06/88        Creation Date
*/
{
 struct GRid                my_GRid, reject_GRid, *cmpnt_sf_ids;
 OM_S_CHANSELECT            lm_sfcmpnt_chan;
 union EMSssi_table         *loc_ssi;
 struct EMSlftssi_table  *my_info;
 IGRlong                    OM_stat;
IGRlong   mthd_stat;
 IGRint                     i, j, num_cmpnt_sf;
 GRobjid                    *sf_out, *sf_in, *lp_out, *lp_in, *ed_in;
 void                       EFgetobjids();

 *EMmsg = EMS_S_Success;
 OM_stat = OM_S_SUCCESS;
 loc_ssi = NULL;
 cmpnt_sf_ids = NULL;

 if (!ssi)
 {
   OM_stat = om$send(msg = message EMSdpr.EMgetSSI(&mthd_stat, &loc_ssi),
                     targetid = my_id);
   EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg, EMS_E_Fail,wrapup);
 }
 else 
   loc_ssi = ssi;

 my_info = &loc_ssi->lft_info;

 /*
  * If I am in the active path, delete all of the objects
  * which were taken out while performing this operation, namely:
  *
  * o Surfaces taken out.
  * o Loops taken out.
  * o Edges replaced.
  */

 if (ME.EMSdpr->dpr_props & EMSIS_ACTIVE_PATH)
 {
   sf_out = my_info->surface_out_ids;
   for (i = 0; i < my_info->num_composites; i++)
   {
     for (j = 0; j < my_info->num_surfaces_out[i]; j++, sf_out++)
     {
       OM_stat = om$send (msg = message GRgraphics.GRdelete (&mthd_stat,
                           md_env),
                          targetid = *sf_out);
       EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_SurfaceError,wrapup);
     } /* for (j = 0; j < my_info->num_surfaces_out[i]; j++, sf_out++) */

   } /* for (i = 0; i < my_info->num_composites; i++) */

   lp_out = my_info->region_out_ids;
   for (i = 0; i < my_info->num_sf_affected; i++)
   {
     for (j = 0; j < my_info->num_regions_out[i]; j++, lp_out++)
     {
       OM_stat = om$send(msg = message Root.delete(NULL),
                         targetid = *lp_out);
       EMerr_hndlr (!(1&OM_stat),*EMmsg,EMS_E_LoopError,wrapup);

     } /* for (j = 0; j < my_info->num_regions_out[i]; j++, lp_out++) */

   } /* for (i = 0; i < my_info->num_sf_affected; i++) */

   for (i = 0; i < my_info->num_eds_rplcd; i++)
   {
    if ( (OM_stat = om$is_objid_valid (objid = my_info->ed_rplcd_ids[i]))
          != OM_S_SUCCESS)
    {
      OM_stat = OM_S_SUCCESS; 
      continue;
    }
     OM_stat = om$send(msg = message Root.delete(NULL),
                       targetid = my_info->ed_rplcd_ids[i]);
     EMerr_hndlr (!(1&OM_stat),*EMmsg,EMS_E_EdgeError,wrapup);

   } /* for (i = 0; i < my_info->num_eds_rplcd; i++) */

 } /* if (ME.EMSdpr->dpr_props & EMSIS_ACTIVE_PATH) */

 else                /*  Not active    */
 {
   /*
    * If I am not active, delete all of the objects which
    * have been stored for redo purpose and can not be accessed
    * by anybody else:
    *
    * o Surfaces added.
    * o Loops added.
    * o Edges in.
    */
   
   if (!ssi)  /*DLB 4/1/91*/
   {
     if (my_info->num_sf_lifted)
     {
       reject_GRid.objid = my_info->sf_lifted_ids[0];
       reject_GRid.osnum = OM_Gw_current_OS;
     
     } /* if (my_info->num_sf_lifted) */
  
     lm_sfcmpnt_chan.type = OM_e_addr;
     lm_sfcmpnt_chan.u_sel.addr = &ME.GRcmpowner->to_components;
  
     my_GRid.objid = my_id;
     my_GRid.osnum = OM_Gw_current_OS;
  
     EFgetobjids (&mthd_stat, &my_GRid, &lm_sfcmpnt_chan, &cmpnt_sf_ids,
                  &num_cmpnt_sf, OPP_EMSsubbs_class_id, &reject_GRid, 
                  my_info->num_sf_lifted);
     EMerr_hndlr (!(1&mthd_stat),*EMmsg,EMS_E_Fail,wrapup); 
  
     for (i = 0; i < num_cmpnt_sf; i++)
     {
       OM_stat = om$send (msg = message GRgraphics.GRdelete(&mthd_stat,
                           md_env), 
                          targetid = cmpnt_sf_ids[i].objid);
       EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_SurfaceError,wrapup);
     } 
   }  

   lp_in = my_info->region_in_ids;
   for (i = 0; i < my_info->num_sf_affected; i++)
   {
     for (j = 0; j < my_info->num_regions_in[i]; j++, lp_in++)
     {
       OM_stat = om$send(msg = message Root.delete(NULL),
                         targetid = *lp_in);
       EMerr_hndlr (!(1&OM_stat),*EMmsg,EMS_E_LoopError,wrapup);

     } /* for (j = 0; j < my_info->num_regions_in[i]; j++, lp_in++) */

   } /* for (i = 0; i < my_info->num_sf_affected; i++) */

   ed_in = my_info->ed_in_ids;
   for (i = 0; i < my_info->num_eds_rplcd; i++) 
   {
     for (j = 0; j < my_info->num_eds_in[i]; j++, ed_in++)
     {
      if ( (OM_stat = om$is_objid_valid (objid = *ed_in ))
          != OM_S_SUCCESS)
      {
        OM_stat = OM_S_SUCCESS; 
        continue;
      }

       OM_stat = om$send(msg = message Root.delete(NULL),
                         targetid = *ed_in);
       EMerr_hndlr (!(1&OM_stat),*EMmsg,EMS_E_EdgeError,wrapup);

     } /* for (j = 0; j < my_info->num_eds_in[i]; j++, ed_in++) */

   } /* for (i = 0; i < my_info->num_eds_rplcd; i++) */

 } /* else for if (ME.EMSdpr->dpr_props & EMSIS_ACTIVE_PATH) */

 wrapup:
  if (loc_ssi && !ssi) om$dealloc(ptr = loc_ssi);
  if (cmpnt_sf_ids) om$dealloc (ptr = cmpnt_sf_ids);
  EMWRAPUP(*EMmsg, OM_stat, "In EMSlift.EMsavestatedelete");
  return(OM_stat);
}
end implementation EMSlift;
