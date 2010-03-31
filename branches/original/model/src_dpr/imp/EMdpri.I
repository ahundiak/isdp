class implementation EMSdpr;

method EMgetInInfo(IGRlong *EMmsg; struct EMSinlist *inlist;
                   GRobjid uneval_sender_id; IGRboolean is_kd_on;
                   IGRushort options)
{
  *EMmsg = EMS_S_Success;
  return (OM_S_SUCCESS);
}

method EMgetOutInfo(IGRlong *EMmsg; struct EMSoutlist *outlist;
                    IGRushort options)
{
  *EMmsg = EMS_S_Success;
  return (OM_S_SUCCESS);
}

method EMmatch(IGRlong            *EMmsg;
               union EMSssi_table *old_ssi;
               IGRint             old_num_surfs;
               GRobjid            *old_surfs;
               IGRint             new_num_surfs;
               GRobjid            *new_surfs;
               IGRushort  options;
               struct GRmd_env    *env)
/*
History
    09/05/91    DLB     Added env param.
*/
{
  IGRlong OM_stat=OM_S_SUCCESS;

  *EMmsg = EMS_S_Success;

  /*Match added surfs*/
  OM_stat = EFmatch_surfs_added(EMmsg,
                                old_num_surfs,
                                old_surfs,
                                new_num_surfs,
                                new_surfs,
                                OM_Gw_current_OS, NULL,
                                env);
  EMWRAPUP(*EMmsg, OM_stat, "dpr.match")
  return(OM_stat);
}

method EMpartial_delete_group_feature(IGRlong         *EMmsg;
                                       struct GRmd_env *env;
                                       GRobjid         group_comp_id;
                                       OMuword         options)
{
  *EMmsg = EMS_S_Success;
  return (OM_S_SUCCESS);
}

end implementation EMSdpr;



