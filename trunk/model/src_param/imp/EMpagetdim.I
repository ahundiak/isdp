/* ###################   APOGEE COMPILED   ################## */
/*
 * HISTORY:
 * 06/03/92 Carlos	Changed EMgetdimgeom to send 
 * 			EMassoc_autodimparam to children 
 */
class implementation EMSparameter;

from EMSassoc import EMassoc_autodimparam;

method EMgetdimgeom (IGRlong *msg; IGRushort opts;
                     IGRshort *mattyp; IGRmatrix mat;
                     struct IGRplane *dim_plane;
                     IGRdouble *dim_plane_xaxis;
                     struct EMSgeomdata *dim_geom;
                     IGRint *dim_type)
{
  OMuint num_children;
  IGRint i;
  IGRlong msg_loc, stat_OM;
  OM_S_CHANSELECT chan_to_children;

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  /*
   * Obtain the dimension parameters through the call to
   * the associative object that this point is driving.
   */

  EMmake_chanselect (NDchildren_children, &chan_to_children);

  om$get_channel_count (object = me, p_chanselect = &chan_to_children,
   count = &num_children);

  msg_loc = EMS_I_NoResponse;
  for (i=0; i<num_children; i++)
    {
    om$send (msg = message EMSassoc.EMassoc_autodimparam (&msg_loc, opts,
     mattyp, mat, my_id, dim_plane, dim_plane_xaxis, dim_geom, dim_type),
     p_chanselect = &chan_to_children, from = i, to = i);
    EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
    if (msg_loc == EMS_S_Success)
      break;
    }
  EMerr_hndlr (msg_loc == EMS_I_NoResponse, *msg, EMS_E_InvalidArg, ret_end);

ret_end:
  EMWRAPUP (*msg, stat_OM, "EMparameter.EMgetdimgeom");
  return (stat_OM);
}

end implementation EMSparameter;
