/*
  DESCRIPTION 
  
    This message can be used to determine if this loop has
    a) no geometric area (encloses a geometrically zero area or is open)and/or,
    b) is geometrically open and/or
    Out of these two any output argument not desired can be set to NULL.

  HISTORY

    SS  :  12/01/93  :  Creation
*/

class implementation EMSloop;

from EMSedge import EMgeomattr;

method EMgeomattr (IGRlong *msg; IGRushort opts; IGRdouble tol;
                   IGRboolean *is_noarea, *is_openloop)
{
  IGRboolean edge_degen_uv, edge_degen_xyz;
  IGRushort lp_props;
  IGRuint count;
  IGRlong i, msg_loc, stat_OM;
  OM_S_CHANSELECT chan_to_edges;

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  lp_props = ME.EMSloop->lp_props;

  if (is_noarea)
    {
    *is_noarea = TRUE;

    if (!(lp_props & EMLP_OPEN))
      {
      EMmake_chanselect (EMSbd_owner_to_comps, &chan_to_edges);
      count = 0;
      om$get_channel_count (object = me, p_chanselect = &chan_to_edges,
       count = &count);
      if (count)
        {
        for (i=0; i<count; i++)
          {
          stat_OM = om$send (msg = message EMSedge.EMgeomattr (&msg_loc, NULL,
                     tol, &edge_degen_uv, &edge_degen_xyz, NULL, NULL), 
                     p_chanselect = &chan_to_edges, from = i, to = i);
          EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, 
           ret_end);

          if (!edge_degen_uv && !edge_degen_xyz)
            {
            *is_noarea = FALSE;
            break;
            }
          }
        }
      }
    }

  if (is_openloop)
    *is_openloop = lp_props & EMLP_OPEN ? TRUE : FALSE;

ret_end:
  EMWRAPUP (*msg, stat_OM, "EMSloop.EMareaattr");
  return (stat_OM);
}

end implementation EMSloop;

