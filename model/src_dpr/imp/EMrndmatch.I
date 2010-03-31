/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsfround;

#include "emsdef.h"     
#include "EMSdpr.h"
#include "EMSopt.h"

#if DEBUG
#include "stdio.h"
#endif

method EMmatch(IGRlong             *EMmsg;
               union EMSssi_table  *old_ssi;
               IGRint              old_num_surfs;
               GRobjid             *old_surfs;
               IGRint              new_num_surfs;
               GRobjid             *new_surfs;
               IGRushort   options;
               struct GRmd_env     *env)
/*
Description
    Topology and geometry tag matching code.

Return values
    EMSS_S_Success if all is well

History
    09/05/91    DLB Add env param.
    07/23/91    DLB Match only added geom; dont even get ssi anymore.
    06/22/91    DLB Disable topology matching.
    02/12/91    DLB Support surfs added.
    02/05/91    DLB Changed to use match functions.
    10/29/90    DLB Creation.
*/
{
  IGRlong                 OM_stat=OM_S_SUCCESS;

  *EMmsg = EMS_S_Success;
 
  /*Match added surfs*/
  OM_stat = EFmatch_surfs_added(EMmsg,
                                old_num_surfs,
                                old_surfs,
                                new_num_surfs,
                                new_surfs,
                                OM_Gw_current_OS, NULL,
                                env);
  if (!(1 & OM_stat & *EMmsg)) goto wrapup;                                

wrapup:
  EMWRAPUP(*EMmsg, OM_stat, "sfrnd.match")
  return(OM_stat);
}
end implementation EMSsfround;

#if WE_EVER_WANT_TO_DO_TOPOLOGY_TAG_MATCHING_AGAIN_DLB_DLB
  union EMSssi_table      *ssi=NULL;
  struct EMSrndssi_table  *my_info, *my_old_info;
  IGRboolean              match_failed=FALSE;
  extern OMuint           OM_Gf_verbose_warning;
   
  OM_stat = om$send(msg = message EMSdpr.EMgetSSI(EMmsg, &ssi),
                    targetid = my_id);
  if (!(1 & OM_stat & *EMmsg)) goto wrapup;
 
  my_info = &ssi->rnd_info;
  my_old_info = &old_ssi->rnd_info;
  

  OM_stat = EFmatch_surfs_loops(EMmsg,
                                my_old_info->num_surfaces,
                                my_old_info->surface_ids,
                                my_info->num_surfaces,
                                my_info->surface_ids,
                                my_old_info->num_regions_out,
                                my_old_info->region_out_ids,
                                my_info->num_regions_out,
                                my_info->region_out_ids,
                                my_old_info->num_regions_in,
                                my_old_info->region_in_ids,
                                my_info->num_regions_in,
                                my_info->region_in_ids,
                                OM_Gw_current_OS, NULL);
  if (!(1 & OM_stat & *EMmsg)) goto wrapup;

  if (*EMmsg == EMS_I_Fail) match_failed = TRUE;
                                  
  OM_stat = EFmatch_loops_edges(EMmsg,
                                0,
                                NULL,
                                my_old_info->num_edges_out,
                                my_old_info->edge_out_ids,
                                my_info->num_edges_out,
                                my_info->edge_out_ids,
                                my_old_info->num_edges_in,
                                my_old_info->edge_in_ids,
                                my_info->num_edges_in,
                                my_info->edge_in_ids,
                                OM_Gw_current_OS,
                                match_failed ? EMstore_opt_MATCH_FAILED:NULL);
  if (!(1 & OM_stat & *EMmsg)) goto wrapup;

  /*Remap new SSI back into the newly moved tags and store'em in vla.*/
  OM_stat = om$send(msg = message EMSdpr.EMputSSI(EMmsg, ssi),
                    targetid = my_id);         
  if (!(1 & OM_stat & *EMmsg)) goto wrapup;

  if (ssi) om$dealloc(ptr = ssi);
#endif
