/*
   FILE DESCRIPTION

     This file contains all the trivial implementations of this class.
     Typically, those implementations that are basically, passons or
     are implementations that compute and/or return something trivially
     known by this object. 
*/

class implementation EMSloop;

method EMchksliver (IGRlong *msg; IGRushort options;
                    IGRdouble uvtol;
                    IGRint num_samplepts_edge;
                    IGRint *num_slivers;
                    GRobjid (**sliver_edges)[2])
{
  IGRuint count;
  IGRint i;
  IGRlong stat_OM=OM_S_SUCCESS;
  OM_S_CHANSELECT chan_to_edges, chan_to_inner;

  *msg = EMS_S_Success;

  EMmake_chanselect (EMSbd_owner_to_comps, &chan_to_edges);
  count = 0;
  om$get_channel_count (object = me, p_chanselect = &chan_to_edges,
   count = &count);
  for (i=0; i<count; i++)
  {
    stat_OM = om$send (msg = OPPmargs, p_chanselect = &chan_to_edges, from = i,
               to = i);
    if (stat_OM == OM_I_STOP_SENDING)
      goto wrapup;

    stat_OM = OM_S_SUCCESS;
    *msg = EMS_S_Success;
  }

  EMmake_chanselect (EMSloop_to_inner, &chan_to_inner);
  count = 0;
  om$get_channel_count (object = me, p_chanselect = &chan_to_inner,
   count = &count);
  for (i=0; i<count; i++)
  {
    stat_OM = om$send (msg = OPPmargs, p_chanselect = &chan_to_inner, from = i,
               to = i);
    if (stat_OM == OM_I_STOP_SENDING)
      goto wrapup;

    stat_OM = OM_S_SUCCESS;
    *msg = EMS_S_Success;
  }

wrapup:
  return (stat_OM);
}

end implementation EMSloop;
