class implementation EMSpsphere;

method GRreport (IGRlong *msg; struct GRmd_env *md_env; IGRint *list_size;
                 struct GRreport_item *list; 
                 struct GRreport_processor *processor)
{
  return (om$send (msg = message EMSrevol.GRreport (msg, md_env, list_size,
           list, processor), mode = OM_e_wrt_message, targetid = my_id));
}

method GRreport_defaults (IGRlong *msg; IGRchar *form; IGRint *label;
                          IGRint *list_size; 
                          struct GRreport_processor *processor )
{
  return (om$send (msg = message EMSrevol.GRreport_defaults (msg, form,
           label, list_size, processor), mode = OM_e_wrt_message,
           targetid = my_id));
}

method GRupdate_gadgets (IGRlong *msg; IGRchar *form_ptr)
{
  return (om$send (msg = message EMSrevol.GRupdate_gadgets (msg, form_ptr),
           mode = OM_e_wrt_message, targetid = my_id));
}

method EMget_params (IGRlong *msg; struct IGRbsp_surface *geom;
                     struct GRmd_env *env; IGRushort *type;
                     struct EMsurface_params *params)
{
  /*                  parent              parent
   *      EMSpsphere <------- EMSsphere  <------- EMSrevol 
   * TR # 119311434 -- GMK -- 10/19/93 
   * mode is changed from OM_e_wrt_message to OM_e_wrt_parent.
   *
  return (om$send (msg = message EMSrevol.EMget_params (msg, geom,
           env, type, params), mode = OM_e_wrt_message, targetid = my_id));
   *
   */
  return (om$send (msg = message EMSrevol.EMget_params (msg, geom,
           env, type, params), mode = OM_e_wrt_parent, targetid = my_id));
}

method EMget_natedge_info (IGRlong *msg; struct GRmdenv_info *md_env;
                           IGRuchar *curve_type;
                           IGRushort *edge_props) 
{
  return (om$send (msg = message EMSrevol.EMget_natedge_info (msg, md_env,
           curve_type, edge_props), mode = OM_e_wrt_message,
           targetid = my_id));
}

end implementation EMSpsphere;
