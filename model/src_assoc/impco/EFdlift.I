/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsfdlift;
/*
History
    SM      09/28/92    Added EMdlft_PLANE_CONVERSION bit mask in the type
                        for new constructions.
    Tapadia 11/08/91    Supported pocket/boss without draft & make & lift face.
    DLB    10/15/91     Allow standard lift face case.
    DLB    06/07/91     Creation.
*/
#include "EMSasdef.h"
#include "EMSas.h"
#include "bserr.h"
#include "bsparameters.h"
#include "OMmacros.h"
#include "EMSdpr.h"
#include "EMSasopts.h"


IGRlong EFdrafted_lift(EMmsg,
                       init_options,
                       construct_list,
                       dlift_info,
                       res_id,
                       general_options) 
IGRlong               *EMmsg;
IGRushort     init_options;
struct GRvg_construct *construct_list;
struct EMSdlft_info   *dlift_info;
struct GRid           *res_id;
IGRushort     general_options;
{
 IGRlong               OM_stat=OM_S_SUCCESS, bs_msg;
 IGRint                obj_type, num_parents, ii, jj;
 struct GRid           active_state_GRid, *src_parent_list=NULL;
 struct EMSobject_info *parent_list=NULL;
 struct EMSdrafted_lift recomp_info;
 IGRboolean            status, recompute=FALSE, standard_lift=FALSE;
 OMuword               osnum;
 extern OM_S_OBJID     current_creator;


 *EMmsg = EMS_S_Success;

 osnum = dlift_info->sf_GRid.osnum;

 if (res_id->objid == NULL_OBJID)
 {
   extern OMuword OPP_EMSsfdlift_class_id, OPP_EMSsldlift_class_id;

   /*Get the active id*/
   OM_stat = om$send(msg = message EMSsurface.EMgetactiveid(EMmsg,
                           &active_state_GRid, NULL),
                     senderid = NULL_OBJID,
                     targetid = dlift_info->sf_GRid.objid,
                     targetos = osnum);
   if (!(1 & OM_stat & *EMmsg)) goto wrapup;

   /*Determine if should create a surface or solid class*/
   EFclassify_obj_type(EMmsg, &obj_type, &active_state_GRid);
   if (!(1 & *EMmsg)) goto wrapup;

   res_id->osnum = osnum;
   OM_stat = om$construct(classid = (obj_type ? OPP_EMSsldlift_class_id :
                                                OPP_EMSsfdlift_class_id),
                          osnum = osnum,
                          p_objid = &res_id->objid);
   if (!(1 & OM_stat)) goto wrapup;
 }
 else recompute = TRUE;

 num_parents = 3;     /*vector magnatude, surface and active id (should go on
                        the end)*/ 
 if (dlift_info->uniform_surface)
 {
   if (dlift_info->assoc_draft_angle.type != EMSdatainfo_numeric)
     num_parents++;     /* surface draft angle*/
   else standard_lift = TRUE;
 }
 else
 {
   for(ii=0; ii<dlift_info->num_lps; ii++)
   {
     if (dlift_info->lps_info[ii].is_uniform)
       /*each loop and its draft angle*/
       num_parents += 2;
     else
     {
       /*each edge and its draft angle*/
       num_parents += dlift_info->lps_info[ii].num_eds * 2;  
     }
   }
 }

 parent_list = (struct EMSobject_info *) alloca
               (num_parents * sizeof(struct EMSobject_info));
 if (!parent_list) {*EMmsg = EMS_E_NoStackMemory; goto wrapup;}

 /*Construct the EMSparamval parent*/
 num_parents = 0;
 OM_stat = EMgetparval_object(EMmsg, osnum, NULL,
                              &dlift_info->assoc_magnatude,
                              &parent_list[num_parents++]);
 if (!(1 & OM_stat & *EMmsg)) goto wrapup;

 /*Add surface to lift*/
 parent_list[num_parents].grid = dlift_info->sf_GRid;
 parent_list[num_parents++].env = *(construct_list->env_info);

 if (dlift_info->uniform_surface)
 {
   if (!standard_lift)
   {
     /*Add the surface draft angle*/
     OM_stat = EMgetparval_object(EMmsg, osnum, NULL,
                                  &dlift_info->assoc_draft_angle,
                                  &parent_list[num_parents++]);
     if (!(1 & OM_stat & *EMmsg)) goto wrapup;
   }
 } 
 else
 {
   for(ii=0; ii<dlift_info->num_lps; ii++)
   {
     if (dlift_info->lps_info[ii].is_uniform)
     {
       /*Add the loop parent and its draft angle*/
       parent_list[num_parents].grid = dlift_info->lps_info[ii].lp_GRid;
       parent_list[num_parents++].env = *(construct_list->env_info);

       OM_stat = EMgetparval_object(EMmsg, osnum, NULL,
                                   &dlift_info->lps_info[ii].assoc_draft_angle,
                                   &parent_list[num_parents++]);
       if (!(1 & OM_stat & *EMmsg)) goto wrapup;
     }
     else
     {
       for(jj=0; jj<dlift_info->lps_info[ii].num_eds; jj++)
       {
         /*Add each edge parent and its draft angle.*/
         parent_list[num_parents].grid =
                                dlift_info->lps_info[ii].eds_info[jj].ed_GRid;
         parent_list[num_parents++].env = *(construct_list->env_info);

         OM_stat = EMgetparval_object(EMmsg, osnum, NULL,
                      &dlift_info->lps_info[ii].eds_info[jj].assoc_draft_angle,
                      &parent_list[num_parents++]);
         if (!(1 & OM_stat & *EMmsg)) goto wrapup;
       }
     }
   }
 }
  
 if (!recompute)
 {
   /*We want the dlift object to be a child of the active state.*/
   parent_list[num_parents].grid = active_state_GRid;
   parent_list[num_parents++].env = *(construct_list->env_info);
 }
 else
 {
   /*Its a recompute so just NULL out the state parent*/
   parent_list[num_parents++].grid.objid = NULL_OBJID;
 }

 /*Remember the cht for this op.*/
 status = BSEXTRACTPAR(&bs_msg, BSTOLCHRDHT, recomp_info.cht);
 if (! status) {*EMmsg = EMS_E_BSerror; goto wrapup;}

 recomp_info.dlift_info = dlift_info;
 recomp_info.num_views = 0;
 recomp_info.view_info = NULL;
 
 current_creator = res_id->objid;

 if (!recompute)
 {
   IGRint type;

   type = general_options & EFdlft_NEG_MAG_OUTSIDE ? EMdlft_NEG_MAG_OUTSIDE :
                                                    NULL;
   type |= general_options & EFdlft_NEG_ANGLE_OUTSIDE ? 
                                                     EMdlft_NEG_ANGLE_OUTSIDE :
                                                     NULL;
   type |= general_options & EFdlft_POS_MAG_INSIDE ? 
                                                     EMdlft_POS_MAG_INSIDE :
                                                     NULL;
   type |= general_options & EFlft_POS_WITH_VECT ? 
                                                     EMlft_POS_WITH_VECT :
                                                     NULL;
   type |= general_options & EFlft_WITH_POS_ORIENT ? 
                                                     EMlft_WITH_POS_ORIENT :
                                                     NULL;
   type |= EMdlft_PLANE_CONVERSION;

   /* Tapadia-8/27/91. If general options is non_assoc don't auto dimension */
   if(general_options & EFfunc_PLACE_NON_ASSOC)
     init_options |= EMSasconst_noautodimension;

   /* This function initializes and constructs the associative dlift object.*/
   OM_stat = om$send(msg = message EMSassoc.EMinit_associative(EMmsg,
                           init_options, 
                           num_parents,
                           parent_list,
                           type,
                           sizeof(struct EMSdrafted_lift),
                           (IGRchar *) &recomp_info,
                           construct_list),
                     senderid = NULL_OBJID,
                     targetid = res_id->objid,
                     targetos = res_id->osnum);
   if (!(1 & OM_stat & *EMmsg)) goto wrapup;
  
   if (general_options & EFfunc_PLACE_NON_ASSOC)
   {
     IGRlong loc_msg=EMS_S_Success, loc_sts=OM_S_SUCCESS;
     loc_sts = om$send(msg = message NDnode.NDmove_to_root(&loc_msg, res_id,
                             construct_list->env_info),
                       senderid = NULL_OBJID,
                       targetid = res_id->objid,
                       targetos = res_id->osnum);
     if (!(1&loc_msg&loc_sts)) {OM_stat=loc_sts; *EMmsg=loc_msg; goto wrapup;}
   }
 }
 else
 {
   if (general_options & EFfunc_CREATE_SOURCE)
   {
     src_parent_list = (struct GRid *) stackalloc
                       (num_parents * sizeof(struct GRid));
     if (!src_parent_list) {*EMmsg=EMS_E_NoStackMemory; goto wrapup;}
       
     OM_stat = om$send(msg = message EMSassoc.EMmake_source(EMmsg, NULL, 
                             num_parents, parent_list, src_parent_list),
                       senderid = NULL_OBJID,
                       targetid = res_id->objid,
                       targetos = res_id->osnum);
     if (!(1 & OM_stat & *EMmsg)) goto wrapup;                     
   }

   OM_stat = om$send(msg = message EMSdpr.EMevaluateOps(EMmsg,
                           EMeval_op_DO_DISPLAY, construct_list->env_info,
                           num_parents, src_parent_list, 
                           EMS_ASno_type, (IGRchar *) &recomp_info),
                     senderid = NULL_OBJID,
                     targetid = res_id->objid,
                     targetos = res_id->osnum);
   if (!(1 & OM_stat & *EMmsg)) goto wrapup;
 }

wrapup:
 current_creator = NULL_OBJID;
 EMWRAPUP(*EMmsg, OM_stat, "EFdrafted_lift")
 return (OM_stat);
}
end implementation EMSsfdlift;

