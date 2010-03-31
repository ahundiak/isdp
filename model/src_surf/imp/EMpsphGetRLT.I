class implementation EMSpsphere;

method EMgetRuleLineTable (IGRlong *msg; IGRboolean nat_edges;
                           IGRint *u_stripes, *v_stripes;
                           struct IGRbsp_surface *in_surf;
                           IGRint *mx_type; IGRmatrix mx;
                           IGRchar *in_buffer; IGRint buffer_size;
                           struct IGResqbs **rlt)
{
  return (om$send (msg = message EMSrevol.EMgetRuleLineTable (msg, nat_edges,
           u_stripes, v_stripes, in_surf, mx_type, mx, in_buffer, buffer_size,
           rlt), mode = OM_e_wrt_message, targetid = my_id));
}


end implementation EMSpsphere;
