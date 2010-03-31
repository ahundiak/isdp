/* ###################   APOGEE COMPILED   ################## */
class implementation EMSlift;

#include "emsdef.h"     
#include "EMSdpr.h"
#include "EMSopt.h"
#include "OMmacros.h"

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
    EMS_S_Success if all is well

History
    09/05/91    DLB   Add env param.
    07/23/91    DLB   Only match surfs added; dont get ssi anymore.
    06/22/91    DLB   Disable topology matching.
    02/12/91    DLB   Support added surfs params.
    02/05/91    DLB   Use new match functions.
    01/28/91    gupta Creation.
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

  /*Removed toptology matching from here*/

wrapup:
  EMWRAPUP(*EMmsg, OM_stat, "lift.match")
  return(OM_stat);
}
end implementation EMSlift;

#if WE_EVER_WANT_TO_DO_TOPOLOGY_TAG_MATCHING_AGAIN_DLB_DLB
  IGRint                  ii;
  union EMSssi_table      *ssi=NULL;
  struct EMSlftssi_table  *my_info, *my_old_info;
  GRobjid                 *old_id, *id;
  IGRboolean              match_failed=FALSE;
  IGRushort       EMstore_options=NULL;
  extern OMuint           OM_Gf_verbose_warning;
   

  /*Get the new SSI*/
  OM_stat = om$send(msg = message EMSdpr.EMgetSSI(EMmsg, &ssi),
                    targetid = my_id);
  if (!(1 & OM_stat & *EMmsg)) goto wrapup;
 
  my_info = &ssi->lft_info;
  my_old_info = &old_ssi->lft_info;

  OM_stat = EFmatch_comps_surfs(EMmsg,
                                my_old_info->num_composites,
                                my_old_info->composite_ids,
                                my_info->num_composites,
                                my_info->composite_ids,
                                my_old_info->num_surfaces_out,
                                my_old_info->surface_out_ids,
                                my_info->num_surfaces_out,
                                my_info->surface_out_ids,
                                NULL);
  if (!(1 & OM_stat & *EMmsg)) goto wrapup;
  if (*EMmsg == EMS_I_Fail) match_failed = FALSE;

  OM_stat = EFmatch_surfs_loops(EMmsg,
                                my_old_info->num_sf_affected,
                                my_old_info->sf_affctd_ids,
                                my_info->num_sf_affected,
                                my_info->sf_affctd_ids,
                                my_old_info->num_regions_out,
                                my_old_info->region_out_ids,
                                my_info->num_regions_out,
                                my_info->region_out_ids,
                                my_old_info->num_regions_in,
                                my_old_info->region_in_ids,
                                my_info->num_regions_in,
                                my_info->region_in_ids,
                                OM_Gw_current_OS,
                                match_failed ? EMstore_opt_MATCH_FAILED:NULL);
  if (!(1 & OM_stat & *EMmsg)) goto wrapup;
  if (*EMmsg == EMS_I_Fail) match_failed = TRUE;

  OM_stat = EFmatch_loops_edges(EMmsg,
                                0,
                                NULL,
                                my_old_info->num_eds_rplcd,
                                my_old_info->ed_rplcd_ids,
                                my_info->num_eds_rplcd,
                                my_info->ed_rplcd_ids,
                                my_old_info->num_eds_in,
                                my_old_info->ed_in_ids,
                                my_info->num_eds_in,
                                my_info->ed_in_ids,
                                OM_Gw_current_OS,
                                match_failed?EMstore_opt_MATCH_FAILED:NULL);
  if (!(1 & OM_stat & *EMmsg)) goto wrapup;

  /*Pulled out Gupta's code from here*/

  /*Remap new SSI back into the newly moved tags and store'em in vla.*/
  OM_stat = om$send(msg = message EMSdpr.EMputSSI(EMmsg, ssi),
                    targetid = my_id);         
  if (! (1 & OM_stat & *EMmsg)) goto wrapup;


  if (ssi) om$dealloc(ptr = ssi);
#endif

#if PULLED_OUT_GUPTAS_CODE_WHICH_I_BELIEVE_IS_INCORRECT
  /* Now match edges-in if single surface lift */
  if (my_old_info->num_eds_wcm_eds)
  {
    old_id = my_old_info->ed_cm_ed_ids;
    id = my_info->ed_cm_ed_ids;
    if (! match_failed)
    {
      if (my_old_info->num_eds_wcm_eds != my_info->num_eds_wcm_eds)
      {
        match_failed = TRUE;
        if (OM_Gf_verbose_warning)
        {
          fprintf(stderr, "Mismatch: old # ed in %d, new # ed in %d\n",
                  my_old_info->num_eds_wcm_eds,
                  my_info->num_eds_wcm_eds);
        }
      }
    }

    if (match_failed) EMstore_options = EMstore_opt_MATCH_FAILED;

    for(ii=1; ii<my_old_info->num_eds_wcm_eds; ii+=2, old_id+=2, id+=2)
    {
      ae_id.grid.objid = match_failed ? NULL_OBJID : *id;
      OM_stat = om$send(msg = EMSboundary$EMstore(EMmsg, NULL, &ae_id,
                              EMstore_options),
                        targetid = *old_id);
      if (! (1 & OM_stat & *EMmsg)) goto wrapup;
    }
  }

  /* Now match comm_edges-in */
  old_id = my_old_info->ed_ced_ids;
  id = my_info->ed_ced_ids;
  if (! match_failed)
  {
    if (my_old_info->num_ed_wmv_cm != my_info->num_ed_wmv_cm)
    {
      match_failed = TRUE;
      if (OM_Gf_verbose_warning)
      {
        fprintf(stderr, "Mismatch: old # ed in %d, new # ed in %d\n",
                my_old_info->num_ed_wmv_cm,
                my_info->num_ed_wmv_cm);
      }
    }
  }

  if (match_failed) EMstore_options = EMstore_opt_MATCH_FAILED;

  for(ii=1; ii<my_old_info->num_ed_wmv_cm; ii+=2, old_id+=2, id+=2)
  {
    ae_id.grid.objid = match_failed ? NULL_OBJID : *id;
    OM_stat = om$send(msg = EMSboundary$EMstore(EMmsg, NULL, &ae_id,
                            EMstore_options),
                      targetid = *old_id);
    if (! (1 & OM_stat & *EMmsg)) goto wrapup;
  }

#endif
