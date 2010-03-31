class implementation SKgeometry;

method SKconnect_to_pt (IGRlong *msg; IGRushort opts;
                        GRobjid ptobj; 
                        IGRint ptinx, myinx)
{
  OM_S_CHANSELECT chan_to_defpts, chan_to_geometries;

  *msg = EMS_S_Success;

  EMmake_chanselect (SKgeometry_to_defpts, &chan_to_defpts);
  EMmake_chanselect (SKvariable_to_geometries, &chan_to_geometries);

  return (om$send (msg = message Root.connect (chan_to_defpts, ptinx,
           ptobj, OM_Gw_current_OS, chan_to_geometries, myinx),
           targetid = my_id));
}

end implementation SKgeometry;

