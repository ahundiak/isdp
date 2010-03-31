class implementation EMSassoc;

#include "EMSopt.h"
#include "emsdef.h"

extern OMuword OPP_ACconst_class_id, OPP_EMSdpr_class_id;
extern OMuword OPP_EMSsurface_class_id;

from ASnode import ACgive_path;
from EMSdpr import EMmake_primitive1;

IGRint EFconsume_copy(EMmsg, options, old_objid, new_objid,num_parents,
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
 IGRlong status,msg_loc;
 union EMSparent_info *roots = NULL;
 IGRuint root_count;
 IGRuint root_type;
 struct GRid *copyee_GRid, copied_GRid;
 OM_S_OBJID save_creator;
 extern OM_S_OBJID current_creator;
 char footname[1024];

 *EMmsg = EMS_S_Success;
 status = OM_S_SUCCESS;

 root_count = num_parents;

 roots = (union EMSparent_info *)stackalloc(root_count*
         sizeof(union EMSparent_info));
 EMerr_hndlr(!roots, *EMmsg, EMS_E_DynamicMemoryAllocated,wrapup);

 if (root_count > 1)
 {
  *EMmsg = EMS_E_InvalidArg;
  goto wrapup;
 }

 root_type = EMSlcinfo;

 status = om$send (msg = message EMSassoc.EMget_parent_info(EMmsg,NULL,
                   root_count, parent_info, &root_type,roots),
                   senderid = new_objid,
                   targetid = new_objid);
 EMerr_hndlr(!(1&status), *EMmsg, EMS_E_Fail,wrapup);

/*
 * copyee_GRid is the entity getting consumed
 */

 copyee_GRid = &roots[0].lc_info.located_obj;

 if (EFisAncestryValid(EMmsg, copyee_GRid->objid,
                       copyee_GRid->osnum, OPP_EMSsurface_class_id, FALSE))
 {
   IGRshort props;
   OM_S_OBJID owner_id;
   OMuword owner_os;
   OM_S_CHANSELECT to_owners;

   EMmake_chanselect(GRconnector_to_owners, &to_owners);

   status = om$send (msg = message GRgraphics.GRgetprops(&msg_loc, &props),
                     senderid = new_objid,
                     targetid = copyee_GRid->objid,
                     targetos = copyee_GRid->osnum);
   EMerr_hndlr(!(1&status&msg_loc), *EMmsg, EMS_E_Fail, wrapup);

   if (props & GR_RIGID_RELATIONSHIP)
   {
    status = om$get_objid_at_index(objid = copyee_GRid->objid,
                                    osnum = copyee_GRid->osnum,
                                    p_chanselect = &to_owners,
                                    index = 0,
                                    objidaddr = &owner_id,
                                    osnumaddr = &owner_os);
    EMerr_hndlr(!(1&status), *EMmsg, EMS_E_OMerror, wrapup);

    if (EFisAncestryValid(EMmsg, owner_id, owner_os,
                            OPP_ACconst_class_id, FALSE))
    {
      footname[0] = '\0';
      status = om$send (msg = message ASnode.ACgive_path((IGRint *)&msg_loc,
                           copyee_GRid, footname),
                        senderid = NULL_OBJID,
                        targetid = owner_id,
                        targetos = owner_os);
      EMerr_hndlr(!(1&status), *EMmsg, EMS_E_Fail, wrapup);

      save_creator = current_creator;
      current_creator = NULL_OBJID;

      status = om$send (msg = message NDmacro.ACconsume(&msg_loc, footname,
                           TRUE,&copied_GRid, construct_list->env_info),
                        senderid = NULL_OBJID,
                        targetos = owner_os,
                        targetid = owner_id);
      current_creator = save_creator;
      EMerr_hndlr(!(1&status&msg_loc), *EMmsg, EMS_E_Fail, wrapup);
    }
    else
    {
     *EMmsg = EMS_E_InvalidArg;
     goto wrapup;
    }
   }
   else
   {
    *EMmsg = EMS_E_InvalidArg;
    goto wrapup;
   }
 }
 else
 {
  *EMmsg = EMS_E_InvalidArg;
  goto wrapup;
 }

 constr_os = construct_list->env_info->md_id.osnum;

 if (EFisAncestryValid(EMmsg, copied_GRid.objid,
                       constr_os, OPP_EMSdpr_class_id, FALSE))
 {
  struct GRid new_GRid;
  save_creator = current_creator;
  current_creator = NULL_OBJID;
  status = om$send (msg = message EMSdpr.EMmake_primitive1(EMmsg,
                          construct_list->env_info, &new_GRid),
                    senderid = new_objid,
                    targetid = copied_GRid.objid,
                    targetos = constr_os);
  current_creator = save_creator;
  EMerr_hndlr(!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);

  copied_GRid.objid = new_GRid.objid;
 }

 if (!(EFisAncestryValid(EMmsg, copied_GRid.objid,
                       constr_os, OPP_EMSassoc_class_id, FALSE)))
 {
  struct GRid non_assoc_GRid;

  non_assoc_GRid.objid = copied_GRid.objid;
  non_assoc_GRid.osnum = constr_os;

  EFtransform_to_associative(EMmsg, NULL, &non_assoc_GRid);
  if (!(1&*EMmsg)) goto wrapup;
  *mod_new_id = non_assoc_GRid.objid;
 }
 else
  *mod_new_id = copied_GRid.objid;


wrapup:
 if (!(1&status&*EMmsg)) *mod_new_id = NULL_OBJID;
 return (status);
}

IGRlong EFplace_consume_copy(EMmsg, options, copyee_info,
                            construct_list, res_id)
IGRlong *EMmsg;
unsigned int options;
struct GRlc_info *copyee_info;
struct GRvg_construct *construct_list;
OM_S_OBJID *res_id;
{
 OMuword constros;
 IGRint num_parents = 1;
 IGRlong status;
 GRobjid loc_obj_id, new_objid;
 struct EMSobject_info list[3];

 *EMmsg = EMS_S_Success;
 status = OM_S_SUCCESS;
 *res_id = NULL_OBJID;

 list[0].grid = copyee_info->located_obj;
 list[0].env = copyee_info->module_info;
 num_parents = 1;
 constros = construct_list->env_info->md_id.osnum;

 status = om$construct(classid = OPP_EMSassoc_class_id,
                       p_objid = &loc_obj_id,
                       osnum = constros);
 EMerr_hndlr(!(1&status), *EMmsg, EMS_E_OMerror, wrapup);
 *res_id = loc_obj_id;

 status = om$send (msg = message EMSassoc.EMinit_associative_function(EMmsg,
                         NULL,num_parents,list,"EFconsume_copy",
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
end implementation EMSassoc;

