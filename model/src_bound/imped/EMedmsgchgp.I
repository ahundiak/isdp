/*
  ABSTRACT

  This message is used in an esoteric situation, where one would like
  to send a message to this edge, with the edge properties temporarily
  changed, for the duration of this target message. On return from this
  method the edge is restored to it's earlier state.

  
  HISTORY

  SS  :  Apr 2, 1995  :  Creation
*/

class implementation EMSedge;

method EMsendmsg_changing_props (IGRlong *msg; 
                                 IGRushort chgprops; IGRshort chgopt;
                                 OM_p_MESSAGE messg)
{
  IGRushort save_props;
  IGRlong stat_OM;

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  save_props = ME.EMSedge->ed_props;

  EMbitmanip (&ME.EMSedge->ed_props, chgprops, chgopt);

  stat_OM = om$send (msg = messg, targetid = my_id);

  ME.EMSedge->ed_props = save_props;

  return (stat_OM);
}

end implementation EMSedge;
