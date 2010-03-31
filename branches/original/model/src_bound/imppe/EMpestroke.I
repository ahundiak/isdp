/* ###################   APOGEE COMPILED   ################## */
class implementation EMSpartedge;

method EMstroke_iso_edge(
  IGRlong               *EMmsg;
  IGRmatrix             matrix;
  IGRshort              *mx_type;
  struct GRid           *srf_id;
  struct IGRbsp_surface *srf_geom;
  IGRboolean            reverse;
  struct EMSpartolbasis *my_partol;
  GRobjid               user_id;
  struct IGRpolyline    *stroked_geom;
  IGRboolean            update_instance_data)
/*
History
    25 Jan 1989 AIC Genesis
*/
{
  IGRlong           sts;
  OM_S_CHANSELECT   to_comps;

  EMmake_chanselect (EMSbd_owner_to_comps, &to_comps);
  if(user_id IS NULL_OBJID) user_id = my_id;
  sts = om$send(msg = message EMSedge.EMstroke_iso_edge(
                    EMmsg,
                    matrix,
                    mx_type,
                    srf_id,
                    srf_geom,
                    reverse,
                    my_partol,
                    user_id,
                    stroked_geom,
                    update_instance_data),
                p_chanselect = &to_comps);

wrapup:
  EMWRAPUP (*EMmsg, sts, "In EMSpartedge.EMstroke_iso_edge")
  return (sts);
}

end implementation EMSpartedge;
