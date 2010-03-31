/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsfboolean;

#include "emsdef.h"     
#include "EMSdpr.h"
#include "EMSopt.h"

#if DEBUG
#include "stdio.h"
#endif

method EMmatch(IGRlong             *EMmsg;
               union EMSssi_table  *old_ssi;
               IGRint              num_old_surfs;
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
    09/05/91    DLB     Add env param.
    07/23/91    DLB Cleanup acc warnings.
    06/22/91    DLB Disable topology matching (this effectively disables the
                    entire method).
    02/12/91    DLB Support surfs added params.
    02/05/91    DLB Use new match functions.
    10/15/90    DLB modified to ignore # of out loops (Horizon!!)
    10/02/90    DLB modified to flag tags if mismatch found.
    09/27/90    DLB Modified to ignore out loops (Horizon!!)
    09/04/90    DLB Creation.
*/
{
  *EMmsg = EMS_S_Success;

  return(OM_S_SUCCESS);
}
end implementation EMSsfboolean;

#if IF_WE_EVER_USE_TOPOLOGY_TAG_MATCHING_AGAIN_USE_THIS_HEY_THERE
  IGRlong               OM_stat=OM_S_SUCCESS;
  union EMSssi_table    *ssi=NULL;
  union EMSri_table     *ri=NULL;
  struct EMSboolssi_table  *my_info, *my_old_info;
  IGRboolean            match_failed=FALSE;
  extern OMuint         OM_Gf_verbose_warning;
   

 
  /*Since booleans never add surfaces... just ignore them and maybe they will
   * go away.
   */

  /*First get the new SSI, RI.*/
  OM_stat = om$send(msg = message EMSdpr.EMgetSSI(EMmsg, &ssi),
                    targetid = my_id);
  if (!(1 & OM_stat & *EMmsg)) goto wrapup;
 
  OM_stat = om$send(msg = message EMSdpr.EMgetRI(EMmsg, &ri),
                    targetid = my_id);
  if (!(1 & OM_stat & *EMmsg)) goto wrapup;
    
  my_info = &ssi->bool_info;
  my_old_info = &old_ssi->bool_info;
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
  if (*EMmsg == EMS_I_Fail) match_failed = TRUE;

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
                                OM_Gw_current_OS,
                                match_failed?EMstore_opt_MATCH_FAILED:NULL);
  if (!(1 & OM_stat & *EMmsg)) goto wrapup;

  /*Remap new SSI back into the newly moved tags and store'em in vla.*/
  OM_stat = om$send(msg = message EMSdpr.EMputSSI(EMmsg, ssi),
                    targetid = my_id);         
  if (!(1 & OM_stat & *EMmsg)) goto wrapup;

  if (ri)
  {
    /*Restore RI which was lost due to above putSSI*/
    OM_stat = om$send(msg = message EMSdpr.EMputRI(EMmsg, ri),
                      targetid = my_id);
    if (!(1 & OM_stat & *EMmsg)) goto wrapup;
  }

wrapup:
  if (ri) om$dealloc(ptr = ri);
  if (ssi) om$dealloc(ptr = ssi);

  EMWRAPUP(*EMmsg, OM_stat, "EMSsfbool.EMmatch")
  return(OM_stat);
#endif

#if       MATCH_OUT_LOOPS_DLB_20
IGRboolean EFmatch_flat_nest(EMmsg, old_id, new_id, osnum, num_ids, inx,
                             options) 
IGRlong           *EMmsg;
GRobjid           **old_id, **new_id;
OMuword           osnum;
IGRint            num_ids;
IGRint            *inx;
IGRushort options;
{
  /*Special processing for flat nested loops*/
  IGRlong              OM_stat=OM_S_SUCCESS;
  IGRint               tmp_cnt, ii;
  GRobjid              *tmp_id;
  OM_S_CHANSELECT      *chansel;
  OM_S_OBJECT_LINKAGE  outter_id;
  extern OM_S_CHANSELECT EMSloopset$to_loops_chanselect,
                         EMSloop$to_outter_chanselect,
                         EMSloop$to_inner_chanselect;
  extern OMuword         OPP_EMSloopset_class_id;

  /*See if *id && *id+n is on same to to_outter chan*/
  OM_stat = om$get_channel_objects(objid = **new_id,
                        osnum = osnum,
                        p_chanselect = &EMSloop$to_outter_chanselect,
                        list = &outter_id,
                        size = 1,
                        count = &tmp_cnt);
  if (!(1 & OM_stat)) goto wrapup;
  if (! tmp_cnt) {*EMmsg = EMS_E_ChanCountWrong; goto wrapup;}

  if (EFisAncestryValid(EMmsg, outter_id.S_objid, osnum,
                        OPP_EMSloopset_class_id, FALSE))
    chansel = &EMSloopset$to_loops_chanselect;
  else
    chansel = &EMSloop$to_inner_chanselect;            

  tmp_id = *new_id;
  tmp_id++;   
  tmp_cnt = 0;
  for(ii=0; ii<num_ids-(*inx)-1; ii++, tmp_id++, tmp_cnt++)
  {
    if (om$is_objid_on_channel(objid_c = outter_id.S_objid,
        osnum_c = osnum, p_chanselect = chansel, objid = *tmp_id,
        osnum2 = osnum) != OM_S_SUCCESS) 
      break;
  }            
  if (tmp_cnt)
  {
    /*Compare in reverse order new to forward order old*/
    GRobjid *tmp_old_id;
    tmp_old_id = *old_id;
    tmp_id--;
    for(ii=0; ii<=tmp_cnt; ii++, tmp_id--, tmp_old_id++)
    {
      if (*tmp_old_id != *tmp_id) break;
    }
  }                          

  if (ii<=tmp_cnt)
  {
    /*compare failed!*/
    return(FALSE);
  }
  else
  {
    /*They matched baby! Fix up ptrs and incs*/
    *new_id += tmp_cnt;
    *old_id += tmp_cnt;
    *inx += tmp_cnt;
    return(TRUE);
  }
wrapup:
  EMWRAPUP(*EMmsg, OM_stat, "EFmatch_flat_nest")
  return(FALSE);
}
#endif
