/* #################   APOGEE  COMPILED   ######################### */
class implementation EMSloop;

#include "EMSobjmgrdef.h"
#include "EMSlcdef.h"

#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;

method EMremmsc (IGRlong *msg; IGRushort options)
{
  IGRlong stat_OM;
  OM_S_CHANSELECT proc_chan;

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  ME.EMSloop->lp_props &= ~EMLP_MSCEXISTS;

  if (options & EMSmsc_edges)
    {
    stat_OM = EMmake_chanselect (EMSbd_owner_to_comps, &proc_chan);
    EMomerr_exit (stat_OM, ret_end);

    stat_OM = om$send (msg = OPPmargs, p_chanselect = &proc_chan);
    EMomerr_exit (stat_OM, ret_end);
    EMerr_hndlr (EMSerror (*msg), *msg, *msg, ret_end);
    }

  if (options & EMSmsc_innerloops)
    {
    stat_OM = EMmake_chanselect (EMSloop_to_inner, &proc_chan);
    EMomerr_exit (stat_OM, ret_end);

    stat_OM = om$send (msg = OPPmargs, p_chanselect = &proc_chan);
    EMomerr_exit (stat_OM, ret_end);
    EMerr_hndlr (EMSerror (*msg), *msg, *msg, ret_end);
    }

ret_end:
  EMWRAPUP (*msg, stat_OM, "EMSloop.EMremmsc");
  return (stat_OM);
}


method EMputmsc (IGRlong *msg; IGRushort options; GRobjid mscobj)
{
  IGRboolean lpreverse;
  OMuint cvcount;
  IGRint i, j, relinx;
  IGRlong msg_loc, stat_OM;
  OM_S_OBJECT_LINKAGE *cvs;
  OM_S_CHANSELECT chan_to_comps, chan_to_edges;

  stat_OM = OM_S_SUCCESS;
  *msg = EMS_S_Success;

  cvs = NULL;

  if (options & EMSmsc_edges)
    {
    stat_OM = EMmake_chanselect (GRcmpowner_to_components, &chan_to_comps);
    EMomerr_exit (stat_OM, ret_end);

    stat_OM = om$get_channel_count (p_chanselect = &chan_to_comps,
               objid = mscobj, count = &cvcount);
    EMomerr_exit (stat_OM, ret_end);

    if (cvcount)
      {
      cvs = (OM_p_OBJECT_LINKAGE) stackalloc (cvcount *
             sizeof (OM_S_OBJECT_LINKAGE));
      EMerr_hndlr (!cvs, *msg, EMS_E_NoDynamicMemory, ret_end);
      }

    stat_OM = om$get_channel_objects (objid = mscobj,
               p_chanselect = &chan_to_comps, list = cvs, size = cvcount,
               count = &cvcount);
    EMomerr_exit (stat_OM, ret_end);

    stat_OM = EMmake_chanselect (EMSbd_owner_to_comps, &chan_to_edges);
    EMomerr_exit (stat_OM, ret_end);

    lpreverse = ME.EMSloop->lp_props & EMLP_REVERSED;
    for (i=0, j=cvcount-1; i<cvcount; i++, j--)
      {
      relinx = lpreverse ? j : i;

      stat_OM = om$send (msg = message EMSboundary.EMputmsc (&msg_loc, options,
                 cvs[i].S_objid), p_chanselect = &chan_to_edges,
                 from = relinx, to = relinx);
      EMomerr_exit (stat_OM, ret_end);
      EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_EdgeError, ret_end);
      }
    }

  ME.EMSloop->lp_props |= EMLP_MSCEXISTS;

ret_end:
  if (cvs)
    stackfree(cvs);

  EMWRAPUP (*msg, stat_OM, "EMSloop.EMputmsc");
  return (stat_OM);
}

method EMsendtomsc (IGRlong *msg; OM_p_MESSAGE messg; IGRushort opt)
{
/*  IGRboolean edgesend; */
  IGRlong stat_OM, msg_loc;
  GRobjid mscobj;
  OM_S_CHANSELECT proc_chan;

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

/*  edgesend = TRUE; */

  if (ME.EMSloop->lp_props & EMLP_MSCEXISTS)
    {
    stat_OM = om$send(msg = message EMSboundary.EMgetxyzobj(&msg_loc,
                                                    EMSlcopt_existingmsc,
                                                    NULL, NULL, NULL,
                                                    NULL, NULL,
                                                    OM_Gw_current_OS, &mscobj),
                      targetid = my_id);
    EMomerr_exit (stat_OM, ret_end);
    EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);

    if (mscobj != NULL_OBJID)
      {
      stat_OM = om$send (msg = messg, targetid = mscobj);
/*      edgesend = FALSE; */
      }
    }

  /* if EMSmsc_edges is set, send to the edges even if the message was sent to
   * the loop since the loop is not connected to the associative model-space
   * counterparts (non associative MSC are created for the loop).
   */

  if (opt & EMSmsc_edges/* && edgesend*/)
    {
    stat_OM = EMmake_chanselect (EMSbd_owner_to_comps, &proc_chan);
    EMomerr_exit (stat_OM, ret_end);

    stat_OM = om$send (msg = OPPmargs, p_chanselect = &proc_chan);
    EMomerr_exit (stat_OM, ret_end);
    EMerr_hndlr (EMSerror (*msg), *msg, *msg, ret_end);
    }

  if (opt & EMSmsc_innerloops)
    {
    stat_OM = EMmake_chanselect (EMSloop_to_inner, &proc_chan);
    EMomerr_exit (stat_OM, ret_end);

    stat_OM = om$send (msg = OPPmargs, p_chanselect = &proc_chan);
    EMomerr_exit (stat_OM, ret_end);
    EMerr_hndlr (EMSerror (*msg), *msg, *msg, ret_end);
    }

ret_end:
  EMWRAPUP (*msg, stat_OM, "EMSloop.EMsendtomsc");
  return (stat_OM);
}

end implementation EMSloop;
