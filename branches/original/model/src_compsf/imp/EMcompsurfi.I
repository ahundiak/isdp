/*
   FILE DESCRIPTION

     This file contains all the trivial implementations of this class.
     Typically, those implementations that are basically, passons or
     are implementations that compute and/or return something trivially
     known by this object. 
*/

class implementation EMScompsurf;

method EMchksliver (IGRlong *msg; IGRushort options;
                    IGRshort *mattyp; IGRmatrix mat;
                    IGRdouble xyztol;
                    IGRint num_samplepts_edge;
                    IGRint *num_slivers;
                    GRobjid (**sliver_edges)[2])
{
  IGRuint count;
  IGRint i;
  OM_S_CHANSELECT chan_to_comps;

  *msg = EMS_S_Success;

  EMmake_chanselect (GRcmpowner_to_components, &chan_to_comps);
  count = 0;
  om$get_channel_count (object = me, p_chanselect = &chan_to_comps,
   count = &count);
  for (i=0; i<count; i++)
    om$send (msg = OPPmargs, p_chanselect = &chan_to_comps, from = i,
     to = i);
  *msg = EMS_S_Success;

  return (OM_S_SUCCESS);
}

end implementation EMScompsurf;
