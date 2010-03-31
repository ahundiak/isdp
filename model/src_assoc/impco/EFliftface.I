/* ###################   APOGEE COMPILED   ################## */
class implementation EMSlift;
/*
History
    DLB     9/06/91     New parameter: lift_with_pos_orient must be specified
                        if vect is NULL.  This indicates the lift will be
                        normal to the surface.  
    DLB     6/31/91     New opt to lift with vect if neg mag else take absval.
    DLB     6/29/91     Take a vector and magnatude rather than from, to pts.
    DLB     5/16/91     Make face a real parent.
    DLB     5/13/91     Handle state parents during recompute.
    DLB     5/03/91     Support init_assoc options.
    DLB     3/27/91     Creation.
*/
#include "EMSas.h"
#include "bserr.h"
#include "bsparameters.h"
#include "EMSdpr.h"

#define MAX_NUM_PARENTS 4

IGRlong EFlift_face(EMmsg, init_options, sf_info, vect, mag,
                    lift_with_pos_orient, 
                    construct_list, res_id, general_options)
IGRlong              *EMmsg;
IGRushort    init_options;
struct GRlc_info     *sf_info;            /* Surface to lift*/
struct EMSvector_info *vect;              /* Vector for lift direction*/
struct EMSvalue_info  *mag;               /* Magnatude of lift*/
IGRboolean            lift_with_pos_orient; /* normal lift in or out*/
struct GRvg_construct *construct_list;    /* Construction information */
struct GRid          *res_id;             /* Resultant id */
IGRushort    general_options;
{
 IGRlong               OM_stat=OM_S_SUCCESS, bs_msg;
 IGRint                obj_type;
 OMuint                cur_par=0;
 IGRdouble             *mat;
 struct GRid           active_state_GRid; 
 struct EMSobject_info parent_list[MAX_NUM_PARENTS];
 struct EMSassoc_lift  r_c_info;
 struct GRid           *src_parent_list=NULL;
 IGRshort              mat_type;
 IGRboolean            status, recompute=FALSE;
 OMuword               parent_os;
 extern OMuword        OPP_EMSsf_lift_class_id, OPP_EMSsl_lift_class_id;
 extern OM_S_OBJID     current_creator;


 *EMmsg = EMS_S_Success;

 mat_type = construct_list->env_info->md_env.matrix_type;
 mat = construct_list->env_info->md_env.matrix;

 parent_os = construct_list->env_info->md_id.osnum;

 if (vect)
 {
   OM_stat = EMgetparvec_object(EMmsg, mat_type, mat, parent_os, vect,
                                &parent_list[cur_par++]);
   if (!(1 & OM_stat & *EMmsg)) goto wrapup;
 }
 else r_c_info.lift_with_pos_orient = lift_with_pos_orient;
  
 OM_stat = EMgetparval_object(EMmsg, parent_os, NULL, mag, 
                              &parent_list[cur_par++]);
 if (!(1 & OM_stat & *EMmsg)) goto wrapup;

 parent_list[cur_par].grid = sf_info->located_obj;
 parent_list[cur_par++].env = sf_info->module_info;

 if (res_id->objid == NULL_OBJID)
 {
   OM_stat = om$send(msg = message EMSsurface.EMgetactiveid(EMmsg,
                           &active_state_GRid, NULL),
                     senderid = NULL_OBJID,
                     targetid = sf_info->located_obj.objid,
                     targetos = sf_info->located_obj.osnum);
   if (!(1 & OM_stat & *EMmsg)) goto wrapup;

   /* Since the active id is also a parent, it needs to be connected on
    * the parent child channel.
    */
   parent_list[cur_par].grid = active_state_GRid;
   parent_list[cur_par++].env = sf_info->module_info;
  
   EFclassify_obj_type(EMmsg, &obj_type, &active_state_GRid);
   if (!(1 & *EMmsg)) goto wrapup;

   res_id->osnum = active_state_GRid.osnum;
   OM_stat = om$construct(classid = (obj_type ? OPP_EMSsl_lift_class_id :
                                                OPP_EMSsf_lift_class_id),
                          osnum = res_id->osnum,
                          p_objid = &res_id->objid);
   if (!(1 & OM_stat)) goto wrapup;
 }
 else
 {
   recompute = TRUE;

   /*Its a recompute so just NULL out the state parent*/
   parent_list[cur_par++].grid.objid = NULL_OBJID;
 }

 current_creator = res_id->objid;

 status = BSEXTRACTPAR(&bs_msg, BSTOLCHRDHT, r_c_info.cht);
 if (! status) {*EMmsg = EMS_E_BSerror; goto wrapup;}

 if (!recompute)
 {
   /* Tapadia-8/27/91. If general options is non_assoc don't auto dimension */
   if(general_options & EFfunc_PLACE_NON_ASSOC)
     init_options |= EMSasconst_noautodimension;

   /* This function initializes and constructs the associative lift face
    * object. 
    */
   OM_stat = om$send(msg = message EMSassoc.EMinit_associative(EMmsg,
                           init_options, 
                           cur_par,
                           parent_list,
                           (general_options & EFlft_POS_WITH_VECT ? 
                          EMlft_POS_WITH_VECT : NULL) | EMlft_PLANE_CONVERSION,
                           sizeof(struct EMSassoc_lift), 
                           (IGRchar *) &r_c_info,
                           construct_list),
                     senderid = NULL_OBJID,
                     targetid = res_id->objid,
                     targetos = res_id->osnum);
   if (!(1 & OM_stat & *EMmsg)) goto wrapup;

   if (general_options & EFfunc_PLACE_NON_ASSOC)
   {
     IGRlong loc_msg=EMS_S_Success, loc_sts=OM_S_SUCCESS;
     loc_sts = om$send(msg = message NDnode.NDmove_to_root(&loc_msg, res_id,
                             &sf_info->module_info),
                       senderid = NULL_OBJID,
                       targetid = res_id->objid,
                       targetos = res_id->osnum);
     if (!(1 & loc_msg & loc_sts)) 
     {OM_stat=loc_sts; *EMmsg=loc_msg; goto wrapup;}
   }
 }
 else
 {
   if (general_options & EFfunc_CREATE_SOURCE)
   {
     src_parent_list = (struct GRid *) stackalloc
                        (cur_par * sizeof(struct GRid));
     if (!src_parent_list) {*EMmsg=EMS_E_NoStackMemory; goto wrapup;}
       
     OM_stat = om$send(msg = message EMSassoc.EMmake_source(EMmsg, NULL, 
                             cur_par, parent_list, src_parent_list),
                       senderid = NULL_OBJID,
                       targetid = res_id->objid,
                       targetos = res_id->osnum);
     if (!(1 & OM_stat & *EMmsg)) goto wrapup;                     
   }

   OM_stat = om$send(msg = message EMSdpr.EMevaluateOps(EMmsg,
                           EMeval_op_DO_DISPLAY, construct_list->env_info,
                           cur_par, src_parent_list, 
                           EMS_ASno_type, (IGRchar *) &r_c_info),
                     senderid = NULL_OBJID,
                     targetid = res_id->objid,
                     targetos = res_id->osnum);
   if (!(1 & OM_stat & *EMmsg)) goto wrapup;
 }

wrapup:
 current_creator = NULL_OBJID;
 if (src_parent_list) stackfree(src_parent_list);
 EMWRAPUP(*EMmsg, OM_stat, "EFlift_face")
 return (OM_stat);
}
end implementation EMSlift;

