class implementation EMSassoc;

extern OMuword OPP_ASkeypt_class_id;

IGRlong EFconstruct_key_points(EMmsg, options, snap_point, cvinfo,
        construct_list, res_id)
IGRlong *EMmsg;
IGRuint options;
IGRpoint snap_point;
struct GRlc_info *cvinfo;
struct GRvg_construct *construct_list;
GRobjid *res_id;
{
 IGRlong status;

 struct GRas asso_lis;     /* associative information   */

 status = OM_S_SUCCESS;
 *EMmsg = EMS_S_Success;

 construct_list->class_attr = (IGRchar *) &asso_lis;
 asso_lis.num_parents = 1;
 asso_lis.parents = &(cvinfo->located_obj);
 asso_lis.context = NULL;
 asso_lis.as_attr = (IGRchar *) snap_point;

 status = om$construct ( classid = OPP_ASkeypt_class_id,
                         osnum = construct_list->env_info->md_id.osnum,
                         p_objid = res_id,
                         msg = message GRgraphics.GRconstruct( construct_list));

 if (1&status)
 {
  if (options & EMSasconst_notassociative)
  {
   struct GRid new_GRid;

   om$send (msg = message NDnode.NDmove_to_root (EMmsg, &new_GRid,
                  construct_list->env_info),
            senderid = NULL_OBJID,
            targetid = *res_id,
            targetos = construct_list->env_info->md_id.osnum);

   *res_id = new_GRid.objid;
  }
 }

 return (status);
}

end implementation EMSassoc;
