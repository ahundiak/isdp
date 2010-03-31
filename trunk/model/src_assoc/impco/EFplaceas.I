class implementation EMSassoc;

#include "EMSopt.h"

IGRlong EFplace_associative_entity(EMmsg, options, 
                                   is_assoc,
                                   num_parents,
                                   parents, 
                                   info_size,
                                   info,
                                   function_name,
                                   construct_list, 
                                   class_name,
                                   res_id)
IGRlong *EMmsg;
unsigned int options;
int is_assoc;
IGRint num_parents;
struct EMSobject_info *parents;
IGRint info_size;
IGRchar *info;
IGRchar *function_name;
struct GRvg_construct *construct_list;
IGRchar *class_name;
OM_S_OBJID *res_id;
{
 OMuword constros;
 OM_S_OBJID loc_obj_id, new_objid;
 IGRlong status;

 *EMmsg = EMS_S_Success;
 status = OM_S_SUCCESS;
 *res_id = NULL_OBJID;

 /*
  * Check for valid input.
  */

  EMerr_hndlr(!((construct_list) || !(function_name) || !(res_id) 
              || !(parents) || !(num_parents)), *EMmsg,
              EMS_E_InvalidArg, wrapup);

  constros = construct_list->env_info->md_id.osnum;

  if (class_name)
  {
   status = om$construct(classname = class_name,
                       p_objid = &loc_obj_id,
                       osnum = constros);
   EMerr_hndlr(!(1&status), *EMmsg, EMS_E_OMerror, wrapup);
  }
  else
  {
    status = om$construct(classid = OPP_EMSassoc_class_id,
                       p_objid = &loc_obj_id,
                       osnum = constros);
    EMerr_hndlr(!(1&status), *EMmsg, EMS_E_OMerror, wrapup);
  }

  *res_id = loc_obj_id;

 status = om$send (msg = message EMSassoc.EMinit_associative_function(EMmsg,
                         NULL,num_parents,parents,function_name,
                         info_size,info,construct_list, &new_objid),
                   senderid = NULL_OBJID,
                   targetid = loc_obj_id,
                   targetos = constros);
 EMerr_hndlr(!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);

 *res_id = new_objid;

 if (!is_assoc)
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

