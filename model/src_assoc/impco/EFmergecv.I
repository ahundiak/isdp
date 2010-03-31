class implementation GAbcsubbc;


IGRint EFamrge_curves(EMmsg, options, old_objid, new_objid,num_parents,
                     parent_info, recomp_info, construct_list, mod_new_id)
IGRlong *EMmsg;
IGRuint options;
GRobjid old_objid;
GRobjid new_objid;
IGRint num_parents;
IGRchar *parent_info;
IGRchar *recomp_info;
struct GRvg_construct *construct_list;
GRobjid *mod_new_id;
{
 OMuword constr_os;
 IGRlong status,i;
 union EMSparent_info *roots = NULL;
 IGRuint root_count;
 IGRuint *root_type = NULL;

 *EMmsg = EMS_S_Success;
 status = OM_S_SUCCESS;

 constr_os = construct_list->env_info->md_id.osnum;

 root_count = num_parents;

 roots = (union EMSparent_info *)stackalloc(root_count*
         sizeof(union EMSparent_info));
 EMerr_hndlr(!roots, *EMmsg, EMS_E_DynamicMemoryAllocated,wrapup);

 root_type = (IGRuint *) stackalloc(root_count*
              sizeof(IGRint));
 EMerr_hndlr(!root_type, *EMmsg, EMS_E_DynamicMemoryAllocated,wrapup);

 for (i=0;i<root_count;i++)
  root_type[i] = EMSlcinfo;

 status = om$send (msg = message EMSassoc.EMget_parent_info(EMmsg,NULL,
                   root_count, parent_info, root_type,roots),
                   senderid = new_objid,
                   targetid = new_objid);
 EMerr_hndlr(!(1&status), *EMmsg, EMS_E_Fail,wrapup);

 constr_os = construct_list->env_info->md_id.osnum;

 status = om$send (msg = message GRsubbc.EMmerge_curves(root_count,
                         (struct GRlc_info *)roots, construct_list, EMmsg),
                   senderid = NULL_OBJID,
                   targetid = new_objid,
                   targetos = constr_os);
 EMerr_hndlr(!(1&status), *EMmsg, EMS_E_Fail,wrapup);
 *mod_new_id = new_objid;

wrapup:
 if (!(1&status&*EMmsg)) *mod_new_id = NULL_OBJID;
 return (status);
}

IGRlong EFplace_merged_curve(EMmsg, options, num_curves, cvinfo,
                            construct_list, res_id)
IGRlong *EMmsg;
unsigned int options;
unsigned int num_curves;
struct GRlc_info *cvinfo;
struct GRvg_construct *construct_list;
OM_S_OBJID *res_id;
{
 OMuword constros;
 IGRlong status,i;
 OM_S_OBJID loc_obj_id, new_objid;
 struct EMSobject_info *list=NULL;

 *EMmsg = EMS_S_Success;
 status = OM_S_SUCCESS;
 *res_id = NULL_OBJID;

 list = (struct EMSobject_info *)stackalloc(num_curves*
                                 sizeof(struct EMSobject_info));
 EMerr_hndlr(!list, *EMmsg, EMS_E_DynamicMemoryAllocated,wrapup);

 for (i=0;i<num_curves;i++)
 {
  list[i].grid = cvinfo[i].located_obj;
  list[i].env = cvinfo[i].module_info;
 }
 constros = construct_list->env_info->md_id.osnum;

 status = om$construct(classid = OPP_GAbcsubbc_class_id,
                       p_objid = &loc_obj_id,
                       osnum = constros);
 EMerr_hndlr(!(1&status), *EMmsg, EMS_E_OMerror, wrapup);

 status = om$send (msg = message EMSassoc.EMinit_associative_function(EMmsg,
                         NULL,num_curves,list,"EFamrge_curves",
                         0,NULL,construct_list, &new_objid),
                   senderid = NULL_OBJID,
                   targetid = loc_obj_id,
                   targetos = constros);
 EMerr_hndlr(!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);
 *res_id = new_objid;

 if (options & EMSasconst_notassociative)
 {
  struct GRid src_GRid;
  src_GRid.objid = NULL_OBJID;
  status = om$send (msg = message NDnode.NDmove_to_root(EMmsg,
                          &src_GRid, construct_list->env_info),
                    senderid = new_objid,
                    targetid = new_objid,
                    targetos = constros);
  if (1&status&*EMmsg)
   *res_id = src_GRid.objid;
  else
  {
   *EMmsg = EMS_E_Fail;
   goto wrapup;
  }
 }

wrapup:
 if (!(1&status&*EMmsg))
 {
  IGRlong l_msg;

  if (*res_id != NULL_OBJID)
  {
   om$send (msg = message GRgraphics.GRdelete(&l_msg,
                  construct_list->env_info),
            senderid = NULL_OBJID,
            targetid = *res_id,
            targetos = constros);
   *res_id = NULL_OBJID;
  }
 }
 return (status);
}
end implementation GAbcsubbc;

