class implementation SKground;

method SKinit (IGRlong *msg; IGRushort options;
               struct GRmd_env *md_env;
               IGRint num_pts; GRobjid *pt_ids;
               IGRushort cnstr_props;
               GRobjid *geom_handle;
               IGRchar *moreinfo)
{
  /*
   * Initialize the properties to have this object behave as a ground
   * for X as well as Y. 
   */

  ME.SKconstraint->props |= SK_GROUND_X | SK_GROUND_Y;
  
  /*
   * Invoke the default implementation
   */

  return (om$send (mode = OM_e_wrt_parent,
           msg = message SKground.SKinit (msg, options, md_env,
           num_pts, pt_ids, cnstr_props, geom_handle, moreinfo),
           targetid = my_id));
}


end implementation SKground;
