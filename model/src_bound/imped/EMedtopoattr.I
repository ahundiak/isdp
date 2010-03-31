/*
  DESCRIPTION 
  
    This message can be used to determine if this loop 
    a) has any connections to any other edge,
    b) is the dominant of the two edges that are connected,
    c) is reverse-connected to it's common-edge.
    d) is part of the natural boundary of the parametric space,
    Out of these any output argument not desired can be set to NULL.

  HISTORY

    SS  :  12/01/93  :  Creation
*/

class implementation EMSedge;

method EMtopoattr (IGRlong *msg; IGRushort opts; 
                   IGRboolean *is_connected, *is_dominant, *is_revconnected;
                   IGRboolean *is_natural)
{
  IGRushort ed_props;
  IGRuint count;
  OM_S_CHANSELECT chan_to_common;

  *msg = EMS_S_Success;

  ed_props = ME.EMSedge->ed_props;

  if (is_connected)
    {
    *is_connected = FALSE;

    EMmake_chanselect (EMSedge_to_common_edge, &chan_to_common);
    count = 0;
    om$get_channel_count (object = me, p_chanselect = &chan_to_common,
     count = &count);
    if (count)
      *is_connected = TRUE;
    }

  if (is_dominant)
    *is_dominant = ed_props & EMED_SUBORDINATE ? FALSE : TRUE;

  if (is_revconnected)
    *is_revconnected = ed_props & EMED_REVERSE_CONNECT ? TRUE : FALSE;

  if (is_natural)
    *is_natural = ed_props & EMED_NATURAL ? TRUE : FALSE;

  return (OM_S_SUCCESS);
}

end implementation EMSedge;

