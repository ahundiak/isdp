class implementation EMSagrp;

/***
DLB	11/02/91	Pass *char to init_assoc instead of *int - SUN PORT.
***/

IGRint EFacvbool(EMmsg, options, old_objid, new_objid,num_parents,
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
 OM_S_OBJID copyid;
 IGRint num_ret=0,code,loc_msg;
 IGRlong status,i;
 OM_S_OBJID *comp_cv_ids=NULL;
 struct GRid new_GRid;
 union EMSparent_info *roots = NULL;
 IGRuint root_count;
 IGRuint *root_type = NULL;

 *EMmsg = EMS_S_Success;
 status = OM_S_SUCCESS;

 constr_os = construct_list->env_info->md_id.osnum;

 new_GRid.objid = new_objid;
 new_GRid.osnum = constr_os;
 
 code = (IGRint) recomp_info[0];

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

/*
 * Copy each of the individual curves.
 */

/*
 for (i=0;i<root_count;i++)
 {
  status = om$send (msg = message GRgraphics.GRcopy(&loc_msg, 
                          &roots[i].lc_info.module_info,
                          construct_list->env_info,
                          &copyid),
                    senderid = NULL_OBJID,
                    targetid = roots[i].lc_info.located_obj.objid,
                    targetos = roots[i].lc_info.located_obj.osnum);

  EMerr_hndlr(!(1&status&loc_msg), *EMmsg, EMS_E_Fail, wrapup);

  roots[i].lc_info.located_obj.objid = copyid;
  roots[i].lc_info.located_obj.osnum = constr_os;
 }
*/

 status = EMmult_boolean(&loc_msg, roots, root_count, code, construct_list,
                         &num_ret, &comp_cv_ids);
 EMerr_hndlr(!(1&status&loc_msg), *EMmsg, EMS_E_Fail, wrapup);

 for (i=0;i<num_ret;i++)
 {
  status = om$send (msg = message GRconnector.GRrigidconn((IGRlong *)&loc_msg, &new_GRid,
                          &i),
                    senderid = new_objid,
                    targetid = comp_cv_ids[i],
                    targetos = constr_os);
  EMerr_hndlr(!(1&status&loc_msg), *EMmsg, EMS_E_Fail, wrapup);
 }

 *mod_new_id = new_objid;

wrapup:
 if (comp_cv_ids) om$dealloc(ptr=comp_cv_ids);
 if (!(1&status&*EMmsg)) *mod_new_id = NULL_OBJID;
 return (status);
}

IGRlong EFplace_associative_curve_boolean(EMmsg, options, num_curves, cvinfo,
                                          code,
                                          construct_list, res_id)
IGRlong *EMmsg;
unsigned int options;
unsigned int num_curves;
struct GRlc_info *cvinfo;
IGRint code;
struct GRvg_construct *construct_list;
OM_S_OBJID *res_id;
{
 OMuword constros;
 IGRlong status,i;
 OM_S_OBJID loc_obj_id, new_objid;
 struct EMSobject_info *list=NULL;
 IGRchar  short_code;

 *EMmsg = EMS_S_Success;
 status = OM_S_SUCCESS;
 *res_id = NULL_OBJID;

 short_code = code;	/*SUN PORT*/

 list = (struct EMSobject_info *)stackalloc(num_curves*
                                 sizeof(struct EMSobject_info));
 EMerr_hndlr(!list, *EMmsg, EMS_E_DynamicMemoryAllocated,wrapup);

 for (i=0;i<num_curves;i++)
 {
  list[i].grid = cvinfo[i].located_obj;
  list[i].env = cvinfo[i].module_info;
 }
 constros = construct_list->env_info->md_id.osnum;

 status = om$construct(classid = OPP_EMSagrp_class_id,
                       p_objid = &loc_obj_id,
                       osnum = constros);
 EMerr_hndlr(!(1&status), *EMmsg, EMS_E_OMerror, wrapup);

 status = om$send (msg = message EMSassoc.EMinit_associative_function(EMmsg,
                         NULL,num_curves,list,"EFacvbool",
                         1,(IGRchar *) &short_code,construct_list, &new_objid),
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
end implementation EMSagrp;

