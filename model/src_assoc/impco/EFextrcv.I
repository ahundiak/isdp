class implementation EMSassoc;

#include "EMSopt.h"
#include "EMSasmacros.h"

from GRbspline import EMpartofcv;


IGRint EFextract_curve(EMmsg, options, old_objid, new_objid,num_parents,
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
/*
  Description
  This is the recomputation/placement function that implements the associative
  extraction  of a partial curve. This function is called
  initially during placement and whenever any of the parents that are listed
  get modified.

  Arguments
   These are standard for any recomputation/placement function.

  Notes
   Upon exit the completion code will be one of the following:
   EMS_S_Success : If all goes well
   EMS_E_Fail    : If there is failure of sorts.

  WARNING
   The name of this function should not change ever since the same is stored
   in the instance data of objects. If we have to change the name of the object
   then we need to provide a conversion mechanism to the new name.

  History:
    Creation : PP : 10/25/93
 ********************************************************************** */
{
 OMuword constr_os;
 IGRlong status;
 IGRint i, num_param;
 IGRshort mattyp;
 IGRdouble *matrix;
 union EMSparent_info *roots = NULL;
 IGRuint root_count;
 IGRuint root_type[4];
 struct GRparms begin_pt, end_pt, middle_pt;
 GRobjid partcvid;

 *EMmsg = EMS_S_Success;
 status = OM_S_SUCCESS;

 root_count = num_parents;

 roots = (union EMSparent_info *)stackalloc(root_count*
         sizeof(union EMSparent_info));
 EMerr_hndlr(!roots, *EMmsg, EMS_E_DynamicMemoryAllocated,wrapup);

 if (root_count > 4)
 {
  *EMmsg = EMS_E_InvalidArg;
  goto wrapup;
 }

 root_type[0] = EMSlcinfo;
 for (i=1;i<root_count;i++)
  root_type[i] = EMSpoint;

/*
 * Message which gets the real parents of the object.
 */

 status = om$send (msg = message EMSassoc.EMget_parent_info(EMmsg,NULL,
                   root_count, parent_info, root_type,roots),
                   senderid = new_objid,
                   targetid = new_objid);
 EMerr_hndlr(!(1&status), *EMmsg, EMS_E_Fail,wrapup);

 mattyp = construct_list->env_info->md_env.matrix_type;
 matrix = construct_list->env_info->md_env.matrix;

 status = om$send (msg = message GRvg.EMpratpt(EMmsg,&mattyp, matrix,
                         roots[1].point, &begin_pt.u,&num_param),
                   senderid = new_objid,
                   targetid = roots[0].lc_info.located_obj.objid,
                   targetos = roots[0].lc_info.located_obj.osnum);
 EMerr_hndlr(!(1&status), *EMmsg, EMS_E_Fail,wrapup);

 status = om$send (msg = message GRvg.EMpratpt(EMmsg,&mattyp, matrix,
                         roots[2].point, &end_pt.u,&num_param),
                   senderid = new_objid,
                   targetid = roots[0].lc_info.located_obj.objid,
                   targetos = roots[0].lc_info.located_obj.osnum);
 EMerr_hndlr(!(1&status), *EMmsg, EMS_E_Fail,wrapup);

 if (root_count == 4)
 {
  status = om$send (msg = message GRvg.EMpratpt(EMmsg,&mattyp, matrix,
                         roots[3].point, &middle_pt.u,&num_param),
                   senderid = new_objid,
                   targetid = roots[0].lc_info.located_obj.objid,
                   targetos = roots[0].lc_info.located_obj.osnum);
  EMerr_hndlr(!(1&status), *EMmsg, EMS_E_Fail,wrapup);
 }
 else
   middle_pt.u = begin_pt.u;

 status = om$send (msg = message GRbspline.EMpartofcv(EMmsg,&mattyp,matrix,
                         construct_list,&begin_pt,&middle_pt, &end_pt,
                         &partcvid),
                   senderid = new_objid,
                   targetid = roots[0].lc_info.located_obj.objid,
                   targetos = roots[0].lc_info.located_obj.osnum);
 EMerr_hndlr(!(1&status), *EMmsg, EMS_E_Fail,wrapup);

                
 *mod_new_id = partcvid;


wrapup:
 om$send (msg = message Root.delete(1),
          senderid = new_objid,
          targetid = new_objid);
 if (!(1&status&*EMmsg)) *mod_new_id = NULL_OBJID;
 return (status);
}

IGRlong EFextract_part_of_curve(EMmsg, options, curve_info,
                                begin_pt, 
                                end_pt,
                                middle_pt,
                                construct_list, res_id)
IGRlong *EMmsg;
unsigned int options;
struct GRlc_info *curve_info;
struct EMSpoint_info *begin_pt;
struct EMSpoint_info *end_pt;
struct EMSpoint_info *middle_pt;
struct GRvg_construct *construct_list;
OM_S_OBJID *res_id;
{
 OMuword constros;
 IGRint num_parents;
 IGRdouble *mat;
 IGRshort mattyp;
 IGRlong status, msg_loc;
 struct EMSobject_info list[4];

 *EMmsg = EMS_S_Success;
 status = OM_S_SUCCESS;
 *res_id = NULL_OBJID;

 num_parents = 3;
 if (middle_pt) ++num_parents;

 list[0].grid = curve_info->located_obj;
 list[0].env = curve_info->module_info;

 mattyp = construct_list->env_info->md_env.matrix_type;
 mat = construct_list->env_info->md_env.matrix;

 constros = construct_list->env_info->md_id.osnum;

 status = EMgetparpt_object (&msg_loc,
                     &construct_list->env_info->md_env.matrix_type,
                     construct_list->env_info->md_env.matrix,constros,
                     begin_pt,&list[1]);
 EMerr_hndlr(!(1&msg_loc&status), *EMmsg, EMS_E_Fail, wrapup);

 status = EMgetparpt_object (&msg_loc,
                     &construct_list->env_info->md_env.matrix_type,
                     construct_list->env_info->md_env.matrix,constros,
                     end_pt,&list[2]);
 EMerr_hndlr(!(1&msg_loc&status), *EMmsg, EMS_E_Fail, wrapup);

 if (middle_pt)
 {
  status = EMgetparpt_object (&msg_loc,
                     &construct_list->env_info->md_env.matrix_type,
                     construct_list->env_info->md_env.matrix,constros,
                     middle_pt,&list[3]);
  EMerr_hndlr(!(1&msg_loc&status), *EMmsg, EMS_E_Fail, wrapup);
 }


 status = ems$associative_element_by_function(msg = EMmsg,
                associative = (options & EMSasconst_notassociative ? FALSE : 
                               TRUE),
                num_parents = num_parents,
                parents = list,
                function_name = "EFextract_curve",
                construct_list = construct_list,
                created_id = res_id);
 EMerr_hndlr(!(1&status&*EMmsg), *EMmsg, *EMmsg, wrapup);


wrapup:
 return (status);
}
end implementation EMSassoc;

