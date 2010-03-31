/* ###################   APOGEE COMPILED   ################## */
class implementation EMSloop;

#include "EMS.h"
#include "emsdef.h"

from EMSedge import EMgetrange;

#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;

method EMsetrange (IGRlong *msg)
{
  OMuint count;
  IGRint i;
  IGRlong stat_OM, msg_loc;
  IGRdouble range[4];
  OM_S_CHANSELECT chan_to_edges;

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  chan_to_edges.type = OM_e_addr;
  chan_to_edges.u_sel.addr = &ME.EMSbd_owner->to_comps;

  stat_OM = om$get_channel_count (object = me, p_chanselect = &chan_to_edges,
             count = &count);
  EMomerr_exit (stat_OM, ret_end);

  ME.EMSloop->range[0] = MAXDOUBLE;
  ME.EMSloop->range[1] = MAXDOUBLE;
  ME.EMSloop->range[2] = -MAXDOUBLE;
  ME.EMSloop->range[3] = -MAXDOUBLE;
  for(i=0; i<count; i++)
    {
    stat_OM = om$send (msg = message EMSedge.EMgetrange (&msg_loc, range, 
           NULL), p_chanselect = &chan_to_edges, from = i, to = i);
    EMomerr_exit (stat_OM, ret_end);
    EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_EdgeError, ret_end);

    if (range[0] < ME.EMSloop->range[0]) ME.EMSloop->range[0] = range[0];
    if (range[1] < ME.EMSloop->range[1]) ME.EMSloop->range[1] = range[1];
    if (range[2] > ME.EMSloop->range[2]) ME.EMSloop->range[2] = range[2];
    if (range[3] > ME.EMSloop->range[3]) ME.EMSloop->range[3] = range[3];
    }
 
ret_end:
  EMWRAPUP (*msg, stat_OM, "EMSloop.EMsetrange");
  return (stat_OM);
}

end implementation EMSloop;

