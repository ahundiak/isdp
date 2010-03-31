class implementation EMSgraloop;

method EMtoggle_type(IGRlong *EMmsg; IGRboolean P_loop;
                      IGRboolean deletable;
                      GRobjid sender_obj;
                      IGRushort options;
                      IGRint *numtogloops; GRobjid **togloops;
                      IGRint *numdelloops; GRobjid **delloops;
                      IGRint *num_loops_received; GRobjid **loops_received)
{
  *EMmsg = EMS_S_Success;
  return(EMS_I_FeatureLoop);
}

end implementation EMSgraloop;

