/* ###################   APOGEE COMPILED   ################## */
class implementation EMAsurface;

method EMastore (IGRlong *EMmsg; 
                 IGRushort options;
                 struct GRmd_env *md_env; GRobjid new_objid)
/*
Description
 Override to send EMmatch_geometry

History
 DLB    03/11/91    Creation
*/
{
  IGRlong OM_stat=OM_S_SUCCESS;

  *EMmsg = EMS_S_Success;
  if (new_objid == my_id) goto wrapup;

  options |= EMastore_DONT_MOVE_TAGS;
  OM_stat = om$send(mode = OM_e_wrt_message,
                    msg = message EMSassoc.EMastore(EMmsg,
                          options, md_env, new_objid),
                    targetid = my_id);
  if (!(1 & OM_stat & *EMmsg)) goto wrapup;

  OM_stat = om$send(msg = message EMSsurface.EMmatch_geometry(EMmsg,
                          NULL, md_env, new_objid),
                    targetid = my_id);

wrapup:
  EMWRAPUP(*EMmsg, OM_stat, "asurf.EMastore")
  return(OM_stat);
}
end implementation EMAsurface;

