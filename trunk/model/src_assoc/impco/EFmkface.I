/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsfmkface;

/*
 * This function creates the associative make face object.
 *
 *           DLB : 08/12/92  Set assoc type to EMS_ASmkface_ver2_1
 *           DLB : 12/11/91  Check to see if state parent is not associative.
 *                           If not need to transform to assoc.
 *           DLB : 07/02/91  Was passing wrong ptr to move_to_root.
 *           DLB : 05/16/91  Mod so the surface to make the face on is on the
 *                           parents channel rather than stored as a tag.
 *           DLB : 05/13/91  If in a recompute null the state parent so 
 *                           EMmake_source doesn't complain.
 *           DLB : 05/03/91  Support init_associative functions and existing
 *                           id (dont create)
 *           DLB : 03/26/91  Add storage of cht for recompute.  Also, support
 *                           efficient display (added dis params to make_face_
 *                           execute).                
 * Creation : PP : 03/06/91
 */
#include "EMSas.h"
#include "bserr.h"
#include "bsparameters.h"
#include "EMSdpr.h"
#include "REmkface.h"

IGRlong EFmake_face (EMmsg, init_options, num_curves, cv_info, face_info,
                     construct_list, res_id, general_options)
IGRlong *EMmsg;
IGRushort init_options;
IGRint num_curves;           /* Number of curves being passed in */
struct GRlc_info *cv_info;   /* Curves which are to be used for make face */
struct GRlc_info *face_info; /* Surface on which a make face has to be done */
struct GRvg_construct *construct_list; /* Construction information */
struct GRid *res_id;         /* Resultant id */
IGRushort general_options;
{
 IGRdouble              cht;
 IGRlong                sts;
 IGRint                 i, obj_type,num_parents;
 struct  GRid           active_state_GRid, *src_parent_list=NULL;
 struct  EMSobject_info *list_ptr = NULL;
 IGRboolean             recompute=FALSE;
 OMuword                cnstr_class_id;
 extern OMuword         OPP_EMSsfmkface_class_id, OPP_EMSslmkface_class_id;
 extern OM_S_OBJID      current_creator;


 *EMmsg = EMS_S_Success;
 sts = OM_S_SUCCESS;

 if (res_id->objid == NULL_OBJID)
 {
   sts = om$send(msg = message EMSsurface.EMgetactiveid (EMmsg,
                       &active_state_GRid, NULL),
                 senderid = NULL_OBJID,
                 targetid = face_info->located_obj.objid,
                 targetos = face_info->located_obj.osnum);
   EMerr_hndlr(!(1&sts&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);

   if (active_state_GRid.objid == face_info->located_obj.objid &&
       active_state_GRid.osnum == face_info->located_obj.osnum)
   {
     /*Case of single surface mkface.  Check to see if surface is associative.
      * If not need to transform to assoc and update structs. 12/11/91
      */
     IGRboolean is_assoc;

     sts = om$send(msg = message EMSsurface.EMis_associative(EMmsg,
                         &is_assoc),
                   senderid = NULL_OBJID,
                   targetid = active_state_GRid.objid,
                   targetos = active_state_GRid.osnum);
     EMerr_hndlr(!(1&sts&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);

     if (!is_assoc)
     {
       sts = om$send(msg = message EMSsurface.EMtransform_to_associative(EMmsg,
                           &active_state_GRid.objid),
                     senderid = NULL_OBJID,
                     targetid = active_state_GRid.objid,
                     targetos = active_state_GRid.osnum);
       EMerr_hndlr(!(1&sts&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);

       face_info->located_obj.objid = active_state_GRid.objid;
     }
   }

   /*
    * Since the active id is also a parent and needs to be connected on
    * the parent child channel.
    */
   EFclassify_obj_type(EMmsg, &obj_type, &active_state_GRid);
   EMerr_hndlr(!(1&sts&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);
  
   if (obj_type == 0)
     cnstr_class_id = OPP_EMSsfmkface_class_id;
   else
     cnstr_class_id = OPP_EMSslmkface_class_id;
  
   sts = om$construct (classid = cnstr_class_id,
                       osnum = active_state_GRid.osnum,
                       p_objid = &res_id->objid);
   EMerr_hndlr(!(1&sts), *EMmsg, EMS_E_OMerror, wrapup);
   res_id->osnum = active_state_GRid.osnum;
 }
 else recompute = TRUE;

 current_creator = res_id->objid;

 /*parents are the curves, surface to make the face on and state parent*/
 num_parents = num_curves + 2;

 list_ptr = (struct EMSobject_info *)stackalloc
            (sizeof(struct EMSobject_info) * num_parents);
 EMerr_hndlr(!list_ptr, *EMmsg, EMS_E_DynamicMemoryAllocated, wrapup);

 for (i=0; i<num_curves; i++)
 {
   list_ptr[i].env = cv_info[i].module_info;
   list_ptr[i].grid = cv_info[i].located_obj;
 }

 list_ptr[num_parents - 2].grid = face_info->located_obj;
 list_ptr[num_parents - 2].env = face_info->module_info;

 if (!recompute)
 {
   list_ptr[num_parents - 1].grid = active_state_GRid;
   list_ptr[num_parents - 1].env = face_info->module_info;
 }
 else
 {
   /*Its a recompute so just NULL out the state parent*/
   list_ptr[num_parents - 1].grid.objid = NULL_OBJID;
 }

 { /*FILL RECOMPUTE INFO STRUCT- DLB*/
   IGRlong bs_msg;
   IGRboolean status;

   status = BSEXTRACTPAR(&bs_msg, BSTOLCHRDHT, cht);
   if (! status) {*EMmsg = EMS_E_BSerror; goto wrapup;}
 }

 if (!recompute)
 {
   /*
    * This function initializes and constructs the associative make face
    * object. 
    */
   sts = om$send(msg = message EMSassoc.EMinit_associative(EMmsg,
                       init_options,
                       num_parents, 
                       list_ptr,
                       EMS_ASmkface_ver2_1,
                       sizeof(IGRdouble), 
                       (IGRchar *) &cht,
                       construct_list),
                 senderid = NULL_OBJID,
                 targetid = res_id->objid,
                 targetos = res_id->osnum);
   /*EMerr_hndlr(!(1&sts&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);*/

   /* Maintain the return code for the command object.
      SM 2/10/93
   */
   if(!(1&sts&*EMmsg))  goto wrapup;

   if (general_options & EFfunc_PLACE_NON_ASSOC)
   {
     IGRlong loc_msg=EMS_S_Success, loc_sts=OM_S_SUCCESS;
     loc_sts = om$send(msg = message NDnode.NDmove_to_root(&loc_msg, res_id,
                             &face_info->module_info),
                       senderid = NULL_OBJID,
                       targetid = res_id->objid,
                       targetos = res_id->osnum);
     if (!(1 & loc_msg & loc_sts)) {sts=loc_sts; *EMmsg=loc_msg; goto wrapup;}
   }
 }
 else
 {
   if (general_options & EFfunc_CREATE_SOURCE)
   {
     src_parent_list = (struct GRid *) stackalloc
                       (num_parents * sizeof(struct GRid));
     if (!src_parent_list) {*EMmsg=EMS_E_NoStackMemory; goto wrapup;}
       
     /*Make source will ignore NULL_OBJID state parents now*/
     sts = om$send(msg = message EMSassoc.EMmake_source(EMmsg, NULL, 
                         num_parents, list_ptr, src_parent_list),
                   senderid = NULL_OBJID,
                   targetid = res_id->objid,
                   targetos = res_id->osnum);
     if (!(1 & sts & *EMmsg)) goto wrapup;                     
   }

   sts = om$send(msg = message EMSdpr.EMevaluateOps(EMmsg,
                       EMeval_op_DO_DISPLAY, construct_list->env_info,
                       num_parents, src_parent_list,
                       EMS_ASno_type, (IGRchar *) &cht),
                 senderid = NULL_OBJID,
                 targetid = res_id->objid,
                 targetos = res_id->osnum);
   if (!(1 & sts & *EMmsg)) goto wrapup;
 }

wrapup:
 current_creator = NULL_OBJID;
 if (list_ptr) stackfree (list_ptr);
 return (sts);
}
end implementation EMSsfmkface;

