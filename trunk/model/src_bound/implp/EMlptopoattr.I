/*
  DESCRIPTION 
  
    This message can be used to determine if this loop 
    a) has any connections to any other topological entity (edge, inner loop),
    b) is actively participating in the loopset,
    c) encloses an area  or a hole,
    d) encloses the entire parametric space with 4 natural edges.
    Out of these any output argument not desired can be set to NULL.

  HISTORY

    SS  :  12/01/93  :  Creation
*/

class implementation EMSloop;

from EMSedge import EMtopoattr;

method EMtopoattr (IGRlong *msg; IGRushort opts; 
                   IGRboolean *is_connected,*is_active,*is_ploop,*is_natural)
{
  IGRushort i, lp_props;
  IGRuint count;
  IGRlong msg_loc, stat_OM;
  OM_S_CHANSELECT chan_to_edges, chan_to_inner;

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  lp_props = ME.EMSloop->lp_props;

  if (is_connected)
    {
    *is_connected = FALSE;

    EMmake_chanselect (EMSbd_owner_to_comps, &chan_to_edges);
    count = 0;
    om$get_channel_count (object = me, p_chanselect = &chan_to_edges,
     count = &count);
    for (i=0; i<count; i++)
      {
      stat_OM = om$send (msg = message EMSedge.EMtopoattr (&msg_loc, NULL,
                 is_connected, NULL, NULL, NULL),
                 p_chanselect = &chan_to_edges, from = i, to = i);
      EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
      
      if (*is_connected)
        break;
      }

    EMmake_chanselect (EMSloop_to_inner, &chan_to_inner);
    count = 0;
    om$get_channel_count (object = me, p_chanselect = &chan_to_inner,
     count = &count);
    if (count)
      *is_connected = TRUE;
    }

  if (is_active)
    *is_active = lp_props & EMLP_ACTIVE ? TRUE : FALSE;

  if (is_ploop)
    *is_ploop = lp_props & EMLP_PLOOP ? TRUE : FALSE;

  if (is_natural)
    *is_natural = lp_props & EMLP_NATURAL ? TRUE : FALSE;

ret_end:
  EMWRAPUP (*msg, stat_OM, "EMSloop.EMgeomattr");
  return (stat_OM);
}

end implementation EMSloop;

