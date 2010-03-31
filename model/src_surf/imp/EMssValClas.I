/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsubbs;

extern OMuword OPP_EMSgenbs_class_id;

method EMvalidateClass(
 IGRlong               *EMmsg;
 struct  GRmd_env      *md_env;
 GRobjid               *new_objid;
 struct IGRbsp_surface *sf_geom)

/*
Abstract
    This method performs the class validation with respect to the
    geometry.

Arguments

    md_env    - input
        The module info the object.

    new_objid - output
        The object id of the new object if the surface changes class.
        Otherwise it will be the id of the original surface.

    sf_geom - input
        The caller may send the surface geometry, or NULL. If surf is
        NULL, the geometry will be generated from the surface object.

History
        DLB  11/08/88     Check to see if I am already a gen bs object.
        RC    1/18/87     Creation Date
*/

{
  IGRlong   OM_stat = OM_S_SUCCESS;
  OMuword   my_classid;

  *EMmsg = EMS_S_Success;

  /*
   * Change class to freefrom if not already.
   */
  OM_stat = om$get_classid(object = me,
                           p_classid = &my_classid);
  if (!(1 & OM_stat)) goto wrapup;

  if (my_classid != OPP_EMSgenbs_class_id)                             
  {
    OM_stat = om$change_class (objid = my_id, osnum = OM_Gw_current_OS,
                               classname = "EMSgenbs",
                               sd_override = OM_K_change_class_sd_override);
    EMerr_hndlr (!(1&OM_stat),*EMmsg, EMS_E_OMerror,wrapup);
  }

  wrapup:
    EMWRAPUP (*EMmsg, OM_stat, "In EMSsubbs.EMvalidateClass")
    return (OM_stat);
}
end implementation EMSsubbs;
