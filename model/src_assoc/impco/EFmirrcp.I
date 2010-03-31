class implementation EMSassoc;

#include "EMSopt.h"
#include "EMSasmacros.h"

from EMSdatpln import EMget_pln_info;
from EMSdpr import EMmake_primitive1;
from EMSsurface import EMgetactiveid, EMmake_active_state;

extern OMuword OPP_EMSsurface_class_id,
               OPP_EMSdpr_class_id;

IGRint EFmirror_copy(EMmsg, options, old_objid, new_objid,num_parents,
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
  mirror copy and copy in place functionality. This function is called
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
    Creation : PP : 01/01/92
 ********************************************************************** */
{
 OMuword constr_os;
 IGRboolean undone = FALSE;
 IGRlong status;
 IGRint i, ref_pln_inx;
 union EMSparent_info *roots = NULL;
 IGRushort undo_option;
 IGRuint root_count;
 IGRuint root_type[3];
 IGRpoint pln_pt;
 IGRvector pln_nrml;
 IGRmatrix tmat;
 GRobjid new_copied_id;
 struct GRid *copyee_GRid, active_GRid;
 struct IGRplane mirror_pln;
 extern IGRboolean MAgrefmx(), MAidmx();
 OM_S_OBJID save_creator;
 extern OM_S_OBJID current_creator;

 *EMmsg = EMS_S_Success;
 status = OM_S_SUCCESS;

 mirror_pln.point = pln_pt;
 mirror_pln.normal = pln_nrml;
 active_GRid.objid = NULL_OBJID;

 root_count = num_parents;

 roots = (union EMSparent_info *)stackalloc(root_count*
         sizeof(union EMSparent_info));
 EMerr_hndlr(!roots, *EMmsg, EMS_E_DynamicMemoryAllocated,wrapup);

 if (root_count > 3)
 {
  *EMmsg = EMS_E_InvalidArg;
  goto wrapup;
 }

 for (i=0;i<root_count;i++)
  root_type[i] = EMSlcinfo;

/*
 * Message which gets the real parents of the object.
 */

 status = om$send (msg = message EMSassoc.EMget_parent_info(EMmsg,NULL,
                   root_count, parent_info, root_type,roots),
                   senderid = new_objid,
                   targetid = new_objid);
 EMerr_hndlr(!(1&status), *EMmsg, EMS_E_Fail,wrapup);

/*
 * copyee_GRid is the entitiy getting mirror copied.
 */

 copyee_GRid = &roots[0].lc_info.located_obj;

/*
 * If the entity being copied is a surface then we need to make sure that
 * the state at which the surface was copied is active.
 */

 if (EFisAncestryValid(EMmsg, copyee_GRid->objid,
                       copyee_GRid->osnum, OPP_EMSsurface_class_id, FALSE))
 {
   status = om$send (msg = message EMSsurface.EMgetactiveid(EMmsg,
                           &active_GRid,NULL),
                     senderid = new_objid,
                     targetid = copyee_GRid->objid,
                     targetos = copyee_GRid->osnum);
   EMerr_hndlr(!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);

   if (active_GRid.objid != roots[1].lc_info.located_obj.objid)
   {
    undo_option = EMS_UNDO_SAVE;
    
    status = om$send (msg = message EMSsurface.EMmake_active_state(EMmsg,
                            &undo_option,
                            &roots[0].lc_info.module_info, NULL,NULL,
                             NULL,NULL,NULL,NULL),
                       senderid = new_objid,
                       targetid = roots[1].lc_info.located_obj.objid,
                       targetos = roots[1].lc_info.located_obj.osnum);
    if (!(1&status&*EMmsg)) goto wrapup;
    undone = TRUE;
   }
   ref_pln_inx = 3;
 }
 else
   ref_pln_inx = 2;

/*
 * If a reference plane does not exist then copy in place.
 */

 if (root_count == ref_pln_inx) 
 {
  struct GRid pln_GRid;
  pln_GRid = roots[ref_pln_inx-1].lc_info.located_obj;

  status = EFget_orientation_from_parent(EMmsg,
           &roots[ref_pln_inx-1].lc_info.located_obj,
           &roots[ref_pln_inx-1].lc_info.module_info,
           NULL,NULL,mirror_pln.normal,
           mirror_pln.point);
  EMerr_hndlr(!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);
                        
  status = MAgrefmx(EMmsg, &mirror_pln, tmat);
  EMerr_hndlr(!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);
 }
 else
   status = MAidmx(EMmsg, tmat);

 constr_os = construct_list->env_info->md_id.osnum;

 save_creator = current_creator;
 current_creator = NULL_OBJID;
 status = om$send (msg = message GRgraphics.GRcptform(EMmsg,
                         &roots[0].lc_info.module_info,tmat,
                         construct_list->env_info,&new_copied_id),
                   senderid = new_objid,
                   targetid = roots[0].lc_info.located_obj.objid,
                   targetos = roots[0].lc_info.located_obj.osnum);
 current_creator = save_creator;
 EMerr_hndlr(!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);


 if (EFisAncestryValid(EMmsg, new_copied_id,
                       constr_os, OPP_EMSdpr_class_id, FALSE))
 {
  struct GRid new_GRid;
  save_creator = current_creator;
  current_creator = NULL_OBJID;
  status = om$send (msg = message EMSdpr.EMmake_primitive1(EMmsg,
                          construct_list->env_info, &new_GRid),
                    senderid = new_objid,
                    targetid = new_copied_id,
                    targetos = constr_os);
  current_creator = save_creator;
  EMerr_hndlr(!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);

  new_copied_id = new_GRid.objid;

 }

 *mod_new_id = new_copied_id;


wrapup:
 if (undone)
 {
  IGRlong l_msg;
/*
 * Restore the state.
 */
  undo_option = EMS_UNDO_SAVE;

  om$send (msg = message EMSsurface.EMmake_active_state(&l_msg,
                 &undo_option, &roots[0].lc_info.module_info,NULL,NULL,
                 NULL,NULL,NULL,NULL),
           senderid = new_objid,
           targetid = active_GRid.objid,
           targetos = active_GRid.osnum);
 }
 if (!(1&status&*EMmsg)) *mod_new_id = NULL_OBJID;
 return (status);
}

IGRlong EFplace_mirror_copy(EMmsg, options, copyee_info,
                            refpln_info,
                            construct_list, res_id)
IGRlong *EMmsg;
unsigned int options;
struct GRlc_info *copyee_info;
struct GRlc_info *refpln_info;
struct GRvg_construct *construct_list;
OM_S_OBJID *res_id;
{
 OMuword constros;
 IGRint num_parents = 1;
 IGRlong status;
 struct GRid active_GRid;
 struct EMSobject_info list[3];

 *EMmsg = EMS_S_Success;
 status = OM_S_SUCCESS;
 *res_id = NULL_OBJID;

 list[0].grid = copyee_info->located_obj;
 list[0].env = copyee_info->module_info;
 num_parents = 1;
 constros = construct_list->env_info->md_id.osnum;

 if (EFisAncestryValid(EMmsg,list[0].grid.objid,list[0].grid.osnum,
                       OPP_EMSsurface_class_id,FALSE))
 {
  status = om$send (msg = message EMSsurface.EMgetactiveid(EMmsg,
                          &active_GRid,NULL),
                    senderid = NULL_OBJID,
                    targetid = list[0].grid.objid,
                    targetos = list[0].grid.osnum);
  if (!(1&status&*EMmsg)) goto wrapup;

  list[1].grid = active_GRid;
  list[1].env = copyee_info->module_info;

  ++(num_parents);
 }

 if (refpln_info->located_obj.objid != NULL_OBJID)
 {
  list[num_parents].grid = refpln_info->located_obj;
  list[num_parents].env = refpln_info->module_info;
  ++num_parents;
 }

 status = ems$associative_element_by_function(msg = EMmsg,
                associative = (options & EMSasconst_notassociative ? FALSE : 
                               TRUE),
                num_parents = num_parents,
                parents = list,
                function_name = "EFmirror_copy",
                construct_list = construct_list,
                created_id = res_id);
 EMerr_hndlr(!(1&status&*EMmsg), *EMmsg, *EMmsg, wrapup);


wrapup:
 return (status);
}
end implementation EMSassoc;

