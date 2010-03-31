/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsfsplit;

#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;

extern GRclassid OPP_EMSsubbs_class_id;

from EMSboundary import EMget_objid;

method EMgetmodinfo (IGRlong *msg; IGRushort options;
                     struct EMSmodobjinfo *modobjinfo)
{
  OMuint i, num_edsdel, num_lpsmod, count, dumcount;
  IGRlong msg_loc, send_rc, stat_OM;
  GRobjid *ids, lpobj, *edsdel, *lpsmod, *outmem, **memptrs;
  OM_S_CHANSELECT chan_to_loopset, chan_to_loops;
  OM_S_CHANSELECT chan_to_edges, chan_to_commedge;
  OM_S_OBJECT_LINKAGE objlist, *objslist;
  extern void EMgetobjids();
  extern IGRlong EMsend_loops();

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;
  
  objslist = NULL;
  outmem = NULL;
  memptrs = NULL;

  ids = ME.EMSdpr->ids;

  modobjinfo->num_sfsdel = 1;
  modobjinfo->sfsdel = &ids[1];
  modobjinfo->num_sfsmod = 0;
  
  EMmake_chanselect (EMSsubbs_to_loopset, &chan_to_loopset);
  EMomerr_exit (stat_OM, ret_end);

  stat_OM = om$get_channel_objects (objid = ids[1],
             p_chanselect = &chan_to_loopset, list = &objlist, size = 1,
             count = &count);
  EMomerr_exit (stat_OM, ret_end);

  EMmake_chanselect (EMSloopset_to_loops, &chan_to_loops);
  EMomerr_exit (stat_OM, ret_end);

  stat_OM = om$get_channel_objects (objid = objlist.S_objid,
             p_chanselect = &chan_to_loops, list = &objlist, size = 1,
             count = &count);
  EMomerr_exit (stat_OM, ret_end);

  EMmake_chanselect (EMSbd_owner_to_comps, &chan_to_edges);
  EMomerr_exit (stat_OM, ret_end);

  stat_OM = om$get_channel_count (objid = objlist.S_objid,
             p_chanselect = &chan_to_edges, count = &count);
  EMomerr_exit (stat_OM, ret_end);

  objslist = (OM_p_OBJECT_LINKAGE) om$malloc (size = count *
              sizeof (OM_S_OBJECT_LINKAGE));
  EMerr_hndlr (!objslist, *msg, EMS_E_NoDynamicMemory, ret_end);

  stat_OM = om$get_channel_objects (objid = objlist.S_objid,
             p_chanselect = &chan_to_edges, list = objslist, size = count,
             count = &count);
  EMomerr_exit (stat_OM, ret_end);

  outmem = (GRobjid *) om$malloc (size = 2 * count * sizeof (GRobjid));
  EMerr_hndlr (!outmem, *msg, EMS_E_NoDynamicMemory, ret_end);
  edsdel = outmem;
  lpsmod = &edsdel[count];

  EMmake_chanselect (EMSedge_to_common_edge, &chan_to_commedge);
  EMomerr_exit (stat_OM, ret_end);

  num_edsdel = 0;
  num_lpsmod = 0;
  for (i=0; i<count; i++)
    {
    send_rc = om$get_channel_objects (objid = objslist[i].S_objid,
               p_chanselect = &chan_to_commedge, list = &objlist, size = 1,
               count = &dumcount);
    if (!EMSerror (send_rc) && dumcount) /* no. of objects != 0 */
      {
      edsdel[num_edsdel++] = objlist.S_objid;

      send_rc = EMsend_loops (&send_rc, message EMSboundary.EMget_objid
                 (&msg_loc, &lpobj), objlist.S_objid, 0, 0,
                 EMLP_ACTIVE, NULL, NULL);
      if (!EMSerror (send_rc & msg_loc))
        lpsmod[num_lpsmod++] = lpobj;
      }
    }

  modobjinfo->num_lpsmod = num_lpsmod;
  modobjinfo->lpsmod = lpsmod;
  modobjinfo->num_lpsdel = 0;

  modobjinfo->num_edsmod = 0;
  modobjinfo->num_edsdel = num_edsdel;
  modobjinfo->edsdel = edsdel;

  memptrs = (GRobjid **)  om$malloc (size = sizeof (GRobjid *));
  EMerr_hndlr (!memptrs, *msg, EMS_E_NoDynamicMemory, ret_end);
  memptrs[0] = outmem;
  modobjinfo->ptrs_malloced = (IGRchar **) memptrs;
  modobjinfo->num_ptrs_malloced = 1;

ret_end:
  if (objslist)
    om$dealloc (ptr = objslist);
  if (EMSerror (*msg & stat_OM))
    {
    if (outmem)
      om$dealloc (ptr = outmem);
    if (memptrs)
      om$dealloc (ptr = memptrs);
    }
  return (stat_OM);
}

end implementation EMSsfsplit;

