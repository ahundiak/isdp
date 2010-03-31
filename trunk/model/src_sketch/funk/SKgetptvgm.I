class implementation SKptvar;

IGRlong SKgetptvargeoms (msg, ptvar, os, max_geoms, num_geoms, geoms)
IGRlong *msg; 
GRobjid ptvar;
GRspacenum os;
IGRint max_geoms, *num_geoms;
GRobjid *geoms;
{
  IGRuint count;
  IGRlong i, stat_OM;
  OM_S_CHANSELECT chan_to_geom;
  OM_p_OBJECT_LINKAGE geomobjs;

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  EMmake_chanselect (SKvariable_to_geometries, &chan_to_geom);

  geomobjs = (OM_p_OBJECT_LINKAGE) alloca (max_geoms * 
              sizeof (OM_S_OBJECT_LINKAGE));
  count = 0;
  om$get_channel_objects (objid = ptvar, osnum = os,
   p_chanselect = &chan_to_geom, count = &count, size = max_geoms,
   list = geomobjs);
  EMerr_hndlr (!count, *msg, EMS_I_NotFound, wrapup);

  for (i=0; i<count; i++)
  {
    geoms[i] = geomobjs[i].S_objid;
  }
  *num_geoms = count;

wrapup:
  EMWRAPUP (*msg, stat_OM, "SKptvgeom");
  return (stat_OM);
}

end implementation SKptvar;
