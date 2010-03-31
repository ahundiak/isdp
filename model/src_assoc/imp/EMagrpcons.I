class implementation EMSagrp;

#include "bserr.h"
#include "bsparameters.h"
#include "emssfintdef.h" /* For EMSINT_TRIM... */
#include "EMSopt.h" /* For EMS_UNDO_SAVE */
#include "EMSsffmacros.h"
#include "bsparameters.h"
#include "bschangepar.h"

from EMSsubbs import EMisoparcvs;
from EMSsurface import EMmake_active_state;
from EMSsurface import EMgetactiveid;
extern IGRboolean _fit_sfsfint_xyz_data;
extern short   _Pathway, _pathway_trim, _pathway_orient;

method EMconstruct_associative(IGRlong *EMmsg;
                               IGRushort const_options;
                               OM_S_OBJID old_objid;
                               IGRint nb_root;
                               IGRchar *parent_info;
                               IGRint type;
                               IGRchar *recomp_info;
                               struct GRvg_construct *construct_list)

/* *******************************************************************

Description

 This method serves as the central processing method for placing all
associative grouping entities.

Arguments
 Input
  nb_root : Number of roots.
  type : Type to interpret the recomputation information.
  old_objid : Objid of the object which has gotten a recompute message.
  const_options : Currently can be set to NULL.
  parent_info : Information about parents.
  env : Module environment of the master file.
  construct_list : construction information
  info : Recomputation information. This better not be NULL.

 Output
  EMmsg : Completion message.

Notes
 Upon exit the completion code will be one of the following:
  EMS_S_Success : If all goes well.
  EMS_E_Fail : If there is failure

  This method provides for placing the following entities associatively:
  a) intersection of two elements. 

History
 07/13/91 : pp  : Creation
 Sudha   06/01/93    modified to handle BSprototype headers
*********************************************************************** */

{
 IGRlong status,rc;
 unsigned int root_count;
 int i;
 IGRdouble save_cht;
 IGRlong   number_of_objects = 0;
 OM_S_OBJID  *objids = NULL;
 struct    GRid *grids = NULL;
 struct    GRid my_GRid;
 union EMSparent_info *roots = NULL;
 IGRuint *root_type = NULL;
 IGRboolean save_fit_flag = FALSE;

 status = OM_S_SUCCESS;
 *EMmsg = EMS_S_Success;
 save_fit_flag = _fit_sfsfint_xyz_data;

 BSEXTRACTPAR(&rc, BSTOLCHRDHT, save_cht);
 my_GRid.objid = my_id;
 my_GRid.osnum = OM_Gw_current_OS;

 root_count = nb_root;
 root_type = (unsigned int *) alloca(sizeof(IGRint) * root_count);
 EMerr_hndlr(!root_type, *EMmsg, EMS_E_DynamicMemoryAllocated, wrapup);


 status = om$send (msg = message EMSagrp.EMget_parent_type(EMmsg, 
                         type,
                         root_count,
                         root_type),
                   targetid = my_id);
 EMerr_hndlr(!(1&status), *EMmsg, EMS_E_Fail, wrapup);

 roots = (union EMSparent_info *)alloca(root_count*
              sizeof(union EMSparent_info));
 EMerr_hndlr(!roots, *EMmsg, EMS_E_DynamicMemoryAllocated, wrapup);

 status = om$send (msg = message EMSassoc.EMget_parent_info(EMmsg, NULL,
                         root_count,
                         parent_info,root_type, roots),
                   targetid = my_id);
 EMerr_hndlr(!(1&status), *EMmsg, EMS_E_Fail, wrapup);

 switch (type)
 {
  case EMS_ASintersect_elements:
  case EMS_ASintersect_elements1:
  {
   IGRushort trimming_options, undo_option;
   /*extern IGRlong EMintersect_two_element();*/
   struct               EMSintersect_elements *info = NULL;
   struct               GRlc_info *first_element_lc_info,
                                  *second_element_lc_info;
   struct               GRid *first_element_GRid,
                             *second_element_GRid;
   struct               GRid first_active_GRid,
                             second_active_GRid;


   info = (struct EMSintersect_elements *) recomp_info;

   trimming_options =  ((info->props & EMS_TRIMMING_REQUIRED) ?
                        EMSINT_TRIM_OUTPUT | EMSINT_TRIM_BDRYISAREA |
                         EMSINT_TRIM_COPLANAR | EMSINT_TRIM_PROCOVERLAP :
                        NULL);
   
/*
 * If this is the first construction, handle stop otherwise do not handle
 * stop.
 */

   first_active_GRid.objid = NULL_OBJID;
   second_active_GRid.objid = NULL_OBJID;

   if (!(const_options & EMSasconst_recompute))
    trimming_options |= EMSINT_TRIM_HANDLESTOP;

   /* Set the global data fitting flag of OFF for all old models.
      SM 09/30/92.
   */ 
   if ((const_options & EMSasconst_recompute) &&
       (type == EMS_ASintersect_elements))
    _fit_sfsfint_xyz_data = FALSE;

   BSchangepar(&rc, BSTOLCHRDHT,info->cht);

   first_element_lc_info = &roots[0].lc_info;
   first_element_GRid = &roots[0].lc_info.located_obj;

   if (EFisAncestryValid(EMmsg, first_element_GRid->objid,
                                first_element_GRid->osnum,
                                OPP_EMSsurface_class_id, FALSE))
   {
    status = om$send (msg = message EMSsurface.EMgetactiveid(EMmsg,
                           &first_active_GRid,NULL),
                     senderid = NULL_OBJID,
                     targetid = first_element_GRid->objid,
                     targetos = first_element_GRid->osnum);
    if (!(1&status&*EMmsg)) goto wrapup;

    if (first_active_GRid.objid != roots[1].lc_info.located_obj.objid)
    {
     undo_option = EMS_UNDO_SAVE;

     status = om$send (msg = message EMSsurface.EMmake_active_state(EMmsg,
                             &undo_option,
                             &roots[0].lc_info.module_info, NULL,NULL,
                             NULL,NULL,NULL,NULL),
                       targetid = roots[1].lc_info.located_obj.objid,
                       targetos = roots[1].lc_info.located_obj.osnum);
     if (!(1&status&*EMmsg)) goto wrapup;
    }
    else
     first_active_GRid.objid = NULL_OBJID;

    second_element_lc_info = &roots[2].lc_info;
   }
   else
    second_element_lc_info = &roots[1].lc_info;

    second_element_GRid = &second_element_lc_info->located_obj;

   if (EFisAncestryValid(EMmsg, second_element_GRid->objid,
                                second_element_GRid->osnum,
                                OPP_EMSsurface_class_id, FALSE))
   {
    status = om$send (msg = message EMSsurface.EMgetactiveid(EMmsg,
                           &second_active_GRid,NULL),
                     senderid = NULL_OBJID,
                     targetid = second_element_GRid->objid,
                     targetos = second_element_GRid->osnum);
    if (!(1&status&*EMmsg)) goto wrapup;

    if (second_active_GRid.objid != roots[nb_root-1].lc_info.located_obj.objid)
    {
     undo_option = EMS_UNDO_SAVE;

     status = om$send (msg = message EMSsurface.EMmake_active_state(EMmsg,
                             &undo_option,
                             &roots[nb_root-1].lc_info.module_info, NULL,NULL,
                             NULL,NULL,NULL,NULL),
                       targetid = roots[nb_root-1].lc_info.located_obj.objid,
                       targetos = roots[nb_root-1].lc_info.located_obj.osnum);
     if (!(1&status&*EMmsg)) goto wrapup;
    }
    else
     second_active_GRid.objid = NULL_OBJID;
   }
/***********************************************************************
   status = EMintersect_two_element(
        first_element_lc_info,
        second_element_lc_info,
        trimming_options,
        construct_list,
        &number_of_objects,
        &grids,
        EMmsg);
***********************************************************************/
   if (_Pathway)
   {
     _pathway_trim  =1;
     if (trimming_options & EMSINT_TRIM_OUTPUT)
     _pathway_orient=1;
   }
   status = ems$intersect_two_element(
                         msg = EMmsg,
                         object1 = first_element_lc_info,
                         object2 = second_element_lc_info,
                         trim_opts = trimming_options,
                         construction_args = construct_list,
                         num_inters = &number_of_objects,
                         inters = &grids);
   if (_Pathway)
   {
     _pathway_trim  =0;
     _pathway_orient=0;
   }

   if (first_active_GRid.objid != NULL_OBJID)
   {
     IGRlong l_msg;

     undo_option = EMS_UNDO_SAVE;

     om$send (msg = message EMSsurface.EMmake_active_state(&l_msg,
                             &undo_option,
                             &roots[0].lc_info.module_info, NULL,NULL,
                             NULL,NULL,NULL,NULL),
                       targetid = first_active_GRid.objid,
                       targetos = first_active_GRid.osnum);

   }

   if (second_active_GRid.objid != NULL_OBJID)
   {
     IGRlong l_msg;

     undo_option = EMS_UNDO_SAVE;

     om$send (msg = message EMSsurface.EMmake_active_state(&l_msg,
                             &undo_option,
                             &roots[nb_root-1].lc_info.module_info, NULL,NULL,
                             NULL,NULL,NULL,NULL),
                       targetid = second_active_GRid.objid,
                       targetos = second_active_GRid.osnum);

   }
    if (!(const_options & EMSasconst_recompute) && (*EMmsg == EMS_I_Interrupt))
      goto wrapup;
    if (!(1&status&*EMmsg)) goto wrapup;
  }
  break;

  case EMS_ASiso_parametric_curves:
  {
   IGRint i,j;
   IGRboolean trimming_required, use_u_curve;
   IGRdouble incval;
   IGRdouble *parms;
   struct EMSisoparametric_curves *info;
   struct GRmdenv_info *mdenv_info;
   struct GRid *id;

   number_of_objects = 0;
   objids = NULL;
   mdenv_info = &roots[0].lc_info.module_info.md_env;
   id = &roots[0].lc_info.located_obj;

   info = (struct EMSisoparametric_curves *)recomp_info;

   if (info->props & EMS_TRIMMING_REQUIRED)
    trimming_required = 1;
   else
    trimming_required = 0;

   if (info->props & EMS_USE_U_DIRECTION)
    use_u_curve = 1;
   else
    use_u_curve = 0;

   parms = (IGRdouble *) alloca(info->num_parms * sizeof(IGRdouble));
  if (!parms)
  {
   *EMmsg = EMS_E_DynamicMemoryAllocated;
   goto wrapup;
  }

  j = info->num_parms - 1;
  parms[j] = info->end_param;
  parms[0] = info->start_param;
  incval = (info->end_param - info->start_param) / j;

  for (i = 1; i < j; i++)
    parms[i] = parms[i-1] + incval;

   status = om$send(
       msg = message EMSsubbs.EMisoparcvs(
        EMmsg,
        &mdenv_info->matrix_type,
        mdenv_info->matrix,
        construct_list,
        trimming_required,
        info->num_parms,
        parms,
        use_u_curve,
        &number_of_objects,
        &objids),
       targetid = id->objid,
       targetos = id->osnum);
   if (!(1&status&*EMmsg)) goto wrapup;
  }
  break;
 }

 if (number_of_objects && (grids || objids))
 {
  OM_S_OBJID temp_id;

  for (i=0;i<number_of_objects;i++)
  {
   if (grids)
    temp_id = grids[i].objid;
   else
    temp_id = objids[i];
    
   status = om$send (msg = message GRconnector.GRrigidconn(EMmsg,
                           &my_GRid, (IGRlong *) &i),
                     targetid = temp_id);
   if (!(1&status&*EMmsg)) goto wrapup;
  }
 }


wrapup:
 if (grids) free (grids);
 if (objids) free (objids);
 BSchangepar(&rc, BSTOLCHRDHT,save_cht);
 EMWRAPUP (*EMmsg, status, "In EMSagrp: EMintersect_elements error");
 _fit_sfsfint_xyz_data = save_fit_flag;
 return (status);

}
end implementation EMSagrp;

