class implementation EMSparameter;

method EMis_externally_constrained(IGRlong *EMmsg; 
                                   IGRboolean *is_externally_constrained)
{
  *EMmsg = EMS_S_Success;
  *is_externally_constrained = FALSE;
  return(OM_S_SUCCESS);
}

method EMpasschild (IGRlong *msg; IGRushort opts;
                    OM_p_MESSAGE messg)
{
  OMuint count;
  IGRlong stat_OM;
  OM_S_CHANSELECT chan_to_child;

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  EMmake_chanselect (NDchildren_children, &chan_to_child);
  count = 0;
  om$get_channel_count (object = me, p_chanselect = &chan_to_child,
   count = &count);

  if (!count)
    *msg = EMS_I_NotFound;
  else
    stat_OM = om$send (msg = messg, p_chanselect = &chan_to_child);

  return (stat_OM);
}

end implementation EMSparameter;
