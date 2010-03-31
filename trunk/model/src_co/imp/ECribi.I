/*
 * This command object has been written for feature Rib/Web
 *
 * History:
 * Rustagi  ??????? Creation
 * Rustagi  9/20/93 Changed some prompt description and fixed a problem
 *                  related to SELECT_SOLID state. 
 * NP       11/1/93 Always display previously input value for thickness (except
 *                  for first time, when defaults are displayed). Also, changed
 *                  metric default for rib thickness to 2.5mm as per spec.
 * Rustagi 11/30/93 Did the following changes:
 *                   1) Do not allow non-profile curves to be located
 *                      for the rib placement.
 *                   2) The dynamic display for providing the projection
 *                      direction is more interactive than earlier. 
 * Rustagi 12/15/93 Fix for TR#119314515
 * NP      12/15/93 Do not allow solids from reference files to be picked. 
 * Rustagi 01/19/94 Fix for TR#119415849
 * Rustagi 01/24/94 Fix for TR#119415808
 * Rustagi 02/16/94 Fix for TR#119417172. Pingali sorted the Journaling
 *                  realted issue for this TR.
 * Rustagi 02/16/94 Fix for TR#119417231. Default units got somewhere
 *                  changed from "in" to "inches" in ver 03:00:00:29, and
 *                  proper values were not initialised subsequent to this
 *                  change.
 * scw     08/14/94 clarified sleep method
 */
class implementation ECrib;

#include <stdio.h>
#include "OMmacros.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "gr.h"
#include "dp.h"
#include "igr.h"
#include "igrdef.h"
#include "igrdp.h"
#include "godef.h"
#include "go.h"
#include "griodef.h"
#include "grio.h"
#include "griomacros.h"
#include "lcdef.h"
#include "lc.h"
#include "madef.h"
#include "exmacros.h" 
#include "lcmacros.h"
#include "dpdef.h"
#include "dpmacros.h"
#include "EC_I.h"
#include "EC_M.h"
#include "emsdef.h"
#include "EMSmsgdef.h"
#include "EMSopt.h"
#include "EMSaction.h"
#include "EMSasopts.h"
#include "EMSdpb.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "EMSasmacros.h"
#include "dpstruct.h"
#include "EMSfeadef.h"
#include "EMSasfeatdef.h"
#include "emsfeaopts.h"


#ifndef EMScmacros_include
#include "EMScmacros.h"
#endif

#ifndef EMSlogic_include
#include "EMSlogic.h"
#endif

#ifndef bserr_include
#include "bserr.h"
#endif

#ifndef bsparameters_include
#include "bsparameters.h"
#endif

#define FAIL 0

/* for me->const_state use */

#define INIT 0
#define EXEC 1
#define DONE 2 
#define UNDO 3 
#define DNUD 4 

/* command states */

#define BEGIN_STATE         0
#define ENTER_THICKNESS     1 
#define SELECT_PROFILE      2
#define ENTER_DISTANCE      3
#define SELECT_SOLID        4 
#define FEATURE_PLACEMENT_STATE 5 
#define OFFSET_SIDE         6 

#define THICKNESS_EVENT 0
#define PROFILE_EVENT 1
#define DISTANCE_EVENT 2
#define SOLID_EVENT 3
#define OFFSET_SIDE_EVENT 4

#define PLACE_RIB 1

#ifdef DEBUG
#define ERROR(sts, msg, error_message) \
 {\
    if(! (1 & sts & msg))\
    {\
        printf("\nIn ECrib: %s\n", error_message); \
        sts = FAIL; \
        goto ret_end;\
    }\
 }
#else
#define ERROR(sts, msg, error_message) \
 {\
    if(! (1 & sts & msg))\
    {\
        sts = FAIL; \
        goto ret_end;\
    }\
 }
#endif

/* imports */

from GRgraphics import GRdisplay;
from EMSdpr import EMundo;
from EMSassoc import EMpack_paraminfo;
from GRvg import GRdetplane, GRgetsize, GRgetgeom;
 
/* externs */

extern OMuword OPP_GRcurve_class_id, OPP_GRbspline_class_id;
extern OMuword OPP_GRlinear_class_id, OPP_GR3dpoint_class_id;
extern OMuword OPP_EMSdatpln_class_id, OPP_EMSsurface_class_id;
extern OMuword OPP_EMSsubbs_class_id, OPP_EMSslboolfea_class_id;
extern OMuword OPP_SKgeometry_class_id;

extern IGRboolean BScollin(), BSpl_of_cv();
extern void  BSsfnormal(), BSpl_tan_tc(), BSpl_nor_tc();
extern IGRboolean  BSnorvec(), BSprptoncv();
extern IGRdouble BSdistptpt(), BSdotp();
extern IGRboolean BSptlngen(), BSmkvec(), BSproj0(), BSproj1();

extern IGRlong EFlocate_action_handler();
extern IGRboolean EFloop_curves_locatable();
extern IGRboolean EFedge_curves_locatable();
extern IGRboolean EFboundary_curves_locatable();
extern IGRlong    EFplace_feature();

%safe
static IGRint EFarrwdyn(), EFlinedyn(), EFarrlinedyn();
static IGRint EFrib_dynamics();
%endsafe

IGRint donotcalldyn;

method init(int type; char *str_ptr)
{
 IGRlong sts, msg;
 IGRshort num_defaults=1, flag=0;
 IGRchar units[52];

 sts = OM_S_SUCCESS;

 ME.super_cmd->state = BEGIN_STATE;
 ME.super_cmd->form_id = NULL_OBJID;
 me->symmetric = TRUE;
 me->extend_curve = TRUE;
 me->numobjs = 0;
 me->is_finite = FALSE;
 me->const_state = INIT;
 me->form_displayed = FALSE;
 me->construct_id.objid = NULL_OBJID;
/*
 * Initialising the thickness value. The user SHOULD NOT switch between system
 * of units, once the command object  is invoked.
 */
 sts = co$get_default_units(msg = &msg,
                            table_name = GRIO_DISTANCE,
                            osnum = 2,
                            flag = &flag,
                            num_defaults = &num_defaults,
                            default_units = units);
 if(strncmp(units, "mm", 2) == 0)
  me->thickness = 2.5;
 else
  me->thickness = 0.1;

/* 
 * Initialise my parent stuff 
 */
 sts = om$send(mode = OM_e_wrt_message,
               msg = message COconst.init( type, str_ptr),
            targetid = my_id);
 ERROR(sts, 1, "init.init error")

ret_end:
 return(sts);
} /* init */

method wakeup(int pos)
{
 IGRlong msg, sts;
 enum GRdpmode DisplayMode;
 IGRboolean state;
 struct GRlc_info *info=NULL;
 IGRint ret;

 gr$get_associative_flag(buffer = &state);
 if(state)
 {
 me->associative = TRUE;
 GRdisplay_associative_button(TRUE);
 }
 else
  me->associative = FALSE;
 if(ME.super_cmd->mytype == PLACE_RIB)
 {
 ex$message(msgnumb = EM_M_PlaceRib)
 }
 msg = EMS_S_Success;
 sts = OM_S_SUCCESS;
 DisplayMode = GRbd;

 if(me->const_state == DONE || me->const_state == DNUD)
 {
 info = &me->loc_events[SOLID_EVENT].located_object[0];
 if(om$is_objid_valid(objid = me->construct_id.objid) == OM_S_SUCCESS)
  {
  sts = om$send(msg = message GRgraphics.GRdisplay(&msg,
             &info->module_info.md_env.matrix_type,
             info->module_info.md_env.matrix,
             &DisplayMode, &info->module_info.md_id),
           targetid = me->construct_id.objid,
           targetos = me->construct_id.osnum);
  ERROR(sts, msg, "wakeup.GRdisplay(1) error")
  }
 else
 if(om$is_objid_valid(objid = info->located_obj.objid) == OM_S_SUCCESS)
  {
  sts = om$send(msg = message GRgraphics.GRdisplay(&msg,
             &info->module_info.md_env.matrix_type,
             info->module_info.md_env.matrix,
             &DisplayMode, &info->module_info.md_id),
           targetid = info->located_obj.objid,
           targetos = info->located_obj.osnum);
  ERROR(sts, msg, "wakeup.GRdisplay error")
   }
  } 
 if(me->form_displayed == TRUE)
  ret = FIf_display(ME.ECrib->form1);

ret_end:
 return(OM_S_SUCCESS);
}

method super_cmd.sleep(int pos)
{
 IGRlong msg, sts, *response;
 IGRlong junk;
 enum GRdpmode DisplayMode;

 sts = OM_S_SUCCESS;
 msg = EMS_S_Success;
 DisplayMode = GRbdhe;

 response = (IGRlong *) &junk;
 sts = dp$erase_hilite(msg = &msg);
 ERROR(sts, msg, "dp$erase_hilite error")

 if(me->associative)
  GRdisplay_associative_button(FALSE); 
 if(me->form_displayed == TRUE)
  FIf_erase(ME.ECrib->form1);

 ex$message(msgnumb = EMS_P_ClearPromptField)
 ex$message(msgnumb = EMS_S_ClearStatusField)
 ex$message(msgnumb = EM_M_ClearMessageField)

ret_end:
 return(OM_S_SUCCESS);
}

method delete(int f_defer_flag)
{
 IGRlong  sts;
 sts = om$send(mode = OM_e_wrt_message, msg = message Root.delete(1),
            targetid = my_id);
 ERROR(sts, 1, "delete.me error")
ret_end:
 return(sts);

} /* delete */


method execute(int *response; char *response_data; int pos)
{
 IGRchar locate_prompt[52], accept_prompt[52], relocate_prompt[52];
 IGRlong locate_mask, accept_mask, object_was_located, display_flag;
 struct GRlc_locate attributes;
 OM_S_CLASSLIST rtree_classes, elig_classes;
 OMuword rclass, eliclass, reject_classid;
 IGRboolean oncurve, stat_func;
 IGRdouble cht, dotp, dotp_tol, display_thk;
 IGRpoint points[2]; 
 IGRlong sts, msg_loc, event_mask;
 IGRint event_size;
 struct GRevent event, acc_event, loc_event;
 struct GRlc_info *info=NULL;
 GRobjid *display_ids;
 struct dynfunc_args dynargs;
 struct IGRpolyline polyline;
 IGRdouble lnpoles_1[2][3], lnpoles_2[2][3], lnknots_1[4], lnknots_2[4];
 enum GRdpmode DisplayMode;
 IGRvector vector;
 struct IGRdisplay disp_attr;
 struct GRvg_construct const_args;
 IGRlong putque_size;
 BSrc rc;
 struct GRlc_dynamics rib_dyn;
 struct EMSfeature_data recomp_info;
 IGRdouble  upar, length=1.0;
 IGRint tmp_num_pars=1;
 IGRpoint tmp_results[1][2];
 IGRvector tan_vec, outvec;
 struct EMSrib_feature_parent_info parent_info;
 IGRboolean aflag = 0;

 sts = BSEXTRACTPAR(&rc, BSTOLCHRDHT, cht);
 sts = BSEXTRACTPAR(&rc, BSTOLORTHOVEC, dotp_tol);
 
 sts = OM_S_SUCCESS;
 *response = TERMINATE;
 display_ids = NULL;
 event_size = sizeof(struct GRevent);

 dynargs.curvebuff[0].poles = (IGRdouble *)lnpoles_1;
 dynargs.curvebuff[0].knots = (IGRdouble *)lnknots_1;
 dynargs.curvebuff[1].poles = (IGRdouble *)lnpoles_2;
 dynargs.curvebuff[1].knots = (IGRdouble *)lnknots_2;
 dynargs.cmd_id.objid = my_id;
 dynargs.cmd_id.osnum = OM_Gw_current_OS;
 dynargs.arrow_head[0].num_points = 3;
 dynargs.arrow_head[1].num_points = 3;
 dynargs.arrow_head[0].points = (IGRdouble *) dynargs.arrow_points[0];
 dynargs.arrow_head[1].points = (IGRdouble *) dynargs.arrow_points[1];
 dynargs.arrow_vector.num_points = 2;
 dynargs.arrow_vector.points = (IGRdouble *) dynargs.arrow_vector_pts;
 dynargs.prof_geom = NULL;

 if(ME.super_cmd->mytype == PLACE_RIB)
 {
 ex$message(msgnumb = EM_M_PlaceRib)
 }
do
 {
 switch(ME.super_cmd->state)
  {
 case BEGIN_STATE:
  ME.super_cmd->state = ENTER_THICKNESS;
  break;
 case ENTER_THICKNESS:


  /* always display "PREVIOUS" value (default values first time ONLY). 
   * (NP 11/1/93)
   */
  display_thk = ME.ECrib->thickness;
  ex$message(msgnumb = EMS_P_EnterThkns, type = "%.3f", var = `display_thk`);

  if(me->const_state == DONE)
  {
   ex$message(msgnumb = EMS_I_ProcessCompBackUpToUndo)
  }
  else
  {
   ex$message(msgnumb = EMS_I_InvkStatusFrm)
   GRstatus_display_button(1);
  }
  event_mask = GRm_VALUE | GRm_RJT_MOVEON | GRm_BACK_UP;
  sts = ems$getevent(msg = &msg_loc,
                     event_mask = event_mask,
                     value_type = GRIO_DISTANCE,
                     response = (long *)response,
                     response_data = response_data,
                     event = &event);
  ex$message(msgnumb = EMS_P_ClearPromptField)
  ex$message(msgnumb = EMS_S_ClearStatusField)
  GRstatus_display_button(0);
  if(!(1&sts)) { sts = FAIL; goto ret_end; }
  if(msg_loc == GRw_no_value)
   event.response = EX_RJT_MOVEON;
  switch(event.response)
   {
   case EX_VALUE:
    if(event.event.value < cht)
    {
    ex$message(msgnumb = EMS_E_ThkGtrCht)
    break;
    }
    me->thickness_stored_as_event = TRUE;
    me->thickness = event.event.value;
    me->const_state = INIT;
    ME.super_cmd->state = SELECT_PROFILE;     
    OM_BLOCK_MOVE(&event, &me->loc_events[THICKNESS_EVENT], event_size);
    break;
   case EX_RJT_MOVEON:
    me->thickness_stored_as_event = FALSE;
    ME.super_cmd->state = SELECT_PROFILE;
    me->const_state = INIT;
    break;
   case EX_BACK_UP:
    if(me->const_state == DONE)
    {
    IGRushort option; 
    IGRint display_count=0, involk_count=0;

    display_ids = NULL;
    option = EMS_UNDO_DELETE | EMS_DO_DISPLAY;
    info = &me->loc_events[SOLID_EVENT].located_object[0];
    sts = om$send(msg = message EMSdpr.EMundo(&msg_loc,
                            &option, &info->module_info, NULL, NULL, NULL,
                            &display_ids, &display_count, &involk_count),
                     targetid = me->construct_id.objid,
                     targetos = me->construct_id.osnum);
    ERROR(sts, msg_loc, "execute.EMundo error") 

    me->const_state = DNUD;

   /*
    * Redraw the profile.
    */
    DisplayMode = GRbd;
    info = &me->loc_events[PROFILE_EVENT].located_object[0];
    sts = om$send(msg = message GRgraphics.GRdisplay(&msg_loc,
                        &info->module_info.md_env.matrix_type,
                        info->module_info.md_env.matrix,
                        &DisplayMode,
                        &info->module_info.md_id),
                    targetid = info->located_obj.objid,
                    targetos = info->located_obj.osnum);
    ERROR(sts, msg_loc, "execute.GRgraphics.GRdisplay error") 
    ME.super_cmd->state = SELECT_PROFILE;
    }
   else
    ME.super_cmd->state = BEGIN_STATE;
  break;
 default:
   /* Avoiding the undo of the model not produced during this state
    * execution.
    */
   if(me->const_state == DONE)
    me->const_state = DNUD;
    return(OM_S_SUCCESS);
  } 
  break;

 case SELECT_PROFILE:
 {
 struct EMSaction_handler dont_locate;
 struct IGRplane pln_of_profile;
 IGRpoint locpoint;
 IGRvector locvector;
 
 disp_attr.color = ME.COconst->ActiveDisplay.color;
 disp_attr.weight = ME.COconst->ActiveDisplay.weight;
 disp_attr.style = (IGRchar)1;

 pln_of_profile.point = locpoint;
 pln_of_profile.normal = locvector;

 reject_classid = OPP_GR3dpoint_class_id;
 dont_locate.next = NULL;
 dont_locate.option = 2;
 dont_locate.type = 3;
 dont_locate.num_objects = 1;
 dont_locate.objects.classids = &reject_classid;

 display_flag = ALL_WINDOWS | ELEM_HILIGHT | NO_PROJ_ACCEPT_POINT;
 locate_mask = GRm_DATA | GRm_BACK_UP;
 accept_mask = GRm_DATA | GRm_BACK_UP;

 ex$message(msgnumb = EMS_P_IdentifyProfile, buff = locate_prompt)
 ex$message(msgnumb = EMS_P_AccWitSelProj, buff = accept_prompt)
 ex$message(msgnumb = EMS_I_ProfileNotFound, buff = relocate_prompt)

 attributes.properties = LC_LC_ONLY | LC_DP_ONLY | LC_PLANAR_ONLY |
                         LC_RW;
 aflag = pwIsActivationOn();
 if(aflag)
 {
 attributes.owner_action = LC_RIGID_COMP | LC_FLEX_COMP |
                           LC_NO_REF_HEADER | LC_REF_OBJECTS;
 } 
 else
 {
 attributes.owner_action = LC_RIGID_COMP | LC_FLEX_COMP |
                           LC_NO_REF_HEADER | LC_NO_REF_OBJECTS;
 }

 strcpy(attributes.classes, "GRcurve");

 rtree_classes.w_count = 1;
 elig_classes.w_count = 1;
 rtree_classes.w_flags = OM_CLST_subclass;
 elig_classes.w_flags = OM_CLST_subclass;
 rclass = OPP_GRcurve_class_id;
 eliclass = OPP_SKgeometry_class_id;
 rtree_classes.p_classes = &rclass;
 elig_classes.p_classes = &eliclass;

 rib_dyn.GRlc_dyn = EFrib_dynamics;
 rib_dyn.add_info = (IGRchar *)&dynargs;

 donotcalldyn = FALSE;
 stat_func = lc$locate(rc = &object_was_located,
                          event1 = &me->locate_event,
                          event2 = &acc_event,
                          event3 = &loc_event,
                          mask1 = locate_mask,
                          mask2 = accept_mask,
                          eventsize = &event_size, 
                          display_flag = display_flag,
                          response = response,
                          response_data = response_data,
                          locate_prompt = locate_prompt,
                          acc_prompt = accept_prompt,
                          relocate_prompt = relocate_prompt,
                          dyn = &rib_dyn,
                          act_handler = EFlocate_action_handler,
                          act_args = &dont_locate,
                          attributes = &attributes,
                          stack = &me->locate_stack,
                          rtree_classes = &rtree_classes,
                          eligible_classes = &elig_classes);

 ex$message(msgnumb = EMS_P_ClearPromptField)
 ex$message(msgnumb = EMS_S_ClearStatusField)

 if(stat_func == FALSE)
 {
 ex$message(msgnumb = EMS_E_FailInputProcExit)
 *response = TERMINATE;
 goto ret_end;
 }
 if(!object_was_located)
 {
 if(loc_event.response == EX_BACK_UP)
  ME.super_cmd->state = ENTER_THICKNESS;
 else
  return(OM_S_SUCCESS);
 }
 else
 { 
 sts = dp$erase_hilite(msg = &msg_loc);
 ERROR(sts, msg_loc, "execute.erase_hilite error")



 loc_event.event.button.x = acc_event.event.button.x;
 loc_event.event.button.y = acc_event.event.button.y;
 loc_event.event.button.z = acc_event.event.button.z;

 loc_event.event.button.objid = acc_event.event.button.objid;
 loc_event.event.button.osnum = acc_event.event.button.osnum;
 donotcalldyn = TRUE;
 EFrib_dynamics(&loc_event.located_object[0].located_obj, 
                &loc_event, (IGRchar *)&dynargs);

 sts = om$send(msg = message GRvg.GRdetplane(&msg_loc,
                   &loc_event.located_object[0].module_info.md_env.matrix_type,
                   loc_event.located_object[0].module_info.md_env.matrix,
                   &pln_of_profile),
                 targetid = loc_event.located_object[0].located_obj.objid,
                 targetos = loc_event.located_object[0].located_obj.osnum);
 if(!(1 & sts)) goto ret_end;
 if(msg_loc != MSSUCC)
  {
  if(dynargs.prof_geom->num_poles IS 2)
   {
   ex$message(msgnumb = EMS_S_LnmstConvProf)
   }
  else
   {
   ex$message(msgnumb = EMS_S_ThreeDcvNtAllow)
   }
  return(OM_S_SUCCESS);
  }
 OM_BLOCK_MOVE(&loc_event, &me->loc_events[PROFILE_EVENT],
               sizeof(struct GRevent));
 me->numobjs ++;

 switch(acc_event.response)
  {
  case EX_DATA:
    OM_BLOCK_MOVE(loc_event.located_object[0].proj_pnt, &me->pivot_pnt[0],
                  sizeof(IGRpoint));
    sts = BSmkvec(&rc, vector, &dynargs.arrow_vector_pts[0], 
                         &dynargs.arrow_vector_pts[1]);
    if(rc != BSSUCC){ sts = EMS_E_BSerror; goto ret_end;}
    BSnorvec(&rc, vector);
    me->matadd_vector[0] = dynargs.proj_vec[0] = vector[0];
    me->matadd_vector[1] = dynargs.proj_vec[1] = vector[1];
    me->matadd_vector[2] = dynargs.proj_vec[2] = vector[2];
    dotp = BSdotp(&rc, me->matadd_vector, me->vec_nor_prfpln);

    if ((dotp > -dotp_tol) && (dotp < dotp_tol))
      me->thickness_in_profile_plane = FALSE; /* rib type feature */
    else
      me->thickness_in_profile_plane = TRUE; /* web type feature */
   /*
    * Incase if 'WEB' type feature
    * Some other necessary information has to be generated at this time.
    * 1) Check if the dir of projection vector is in the SAME dir as the 
    *    normal to the profile plane.
    * 2) If it is,
    *       flip_projection_side = FALSE;
    *    else
    *       flip_projection_side = TRUE;
    *
    * In case of RIB type feature
    *
    * 1) Get the tangent to the curve at the pivot point( consider the
    *    the special case where the pivot point is lying on the linear
    *    segment) in the plane of the profile.
    * 2) Form the cross product between the tangent vector found in the
    *    first step and the normal to the profile plane. Call it result.
    *        (T x N is the order for cross product)
    * 3) Check if the proj. dir vector is in the SAME dir as "result".
    *    If it is,
    *       flip_projection_side = FALSE;
    *    else (OPPOSITE dir)
    *       flip_projection_side = TRUE;
    */
    if(me->thickness_in_profile_plane)
    {
    dotp = BSdotp(&rc, me->matadd_vector, me->vec_nor_prfpln);
    if(dotp > 0.0) /* they are in the same direction */
     me->flip_prj_side = FALSE;
    else
     me->flip_prj_side = TRUE; 
    }
    else
    {
    sts = BSprptoncv(&rc,dynargs.prof_geom,&me->pivot_pnt[0],&upar,&oncurve);
    if(rc != BSSUCC){ sts = EMS_E_BSerror; goto ret_end;}
    (void)BScvarrevt(dynargs.prof_geom, &upar, tmp_num_pars, length,
     tmp_results, &rc);
    sts = BSmkvec(&rc, tan_vec, tmp_results[0][0], tmp_results[0][1]);
    BSnorvec(&rc, tan_vec);
    BScrossp(&rc, tan_vec, me->vec_nor_prfpln, outvec);
    dotp = BSdotp(&rc, me->matadd_vector, outvec);
    if(dotp > 0.0) /* they are in the same direction */
     me->flip_prj_side = FALSE;
    else
     me->flip_prj_side = TRUE;
    }

    if(me->symmetric == FALSE)
     ME.super_cmd->state = OFFSET_SIDE;
    else /* It is by default ....SYMMETRIC rib */
    {
    if(me->is_finite)
     ME.super_cmd->state = ENTER_DISTANCE;
    else /* It will go all the way to fill up the material. */
    ME.super_cmd->state = SELECT_SOLID;
    }
   break;

  case EX_BACK_UP:
   ME.super_cmd->state = ENTER_THICKNESS;
   break;

  default:
   return(OM_S_SUCCESS); 
   } /* switch */

 }/* object was located */

 }/* case SELECT_PROFILE */

 break;

 case ENTER_DISTANCE:
  {
  IGRdouble loc_value;
   /*
    * In the the value is expected to be entered either through the
    * mouse or through the key in.
    */
   ex$message(msgnumb = EMS_P_EntrDist)
   points[0][0] = me->pivot_pnt[0];
   points[0][1] = me->pivot_pnt[1];
   points[0][2] = me->pivot_pnt[2];
   polyline.num_points = 2;
   polyline.points = &points[0][0];
   /*
    * Build the display buffer.
    */
   dp$build_dis_buffer(buffer = &dynargs.disbuf[0],
                      type = IGRPY,
                      display_att = &ME.COconst->ActiveDisplay,
                      geometry = &polyline);
   /*
    * Invoke dynamics.
    */ 
   dp$dynamics(dyn_fun = EFlinedyn, information = &dynargs);
   event_mask = GRm_VALUE | GRm_DATA | GRm_BACK_UP | GRm_RJT_MOVEON;
   sts = co$getevent(msg = &msg_loc,
                     event_mask = event_mask,
                     response = response,
                     response_data = response_data,
                     event = &acc_event);
   ERROR(sts, msg_loc, "co$getevent error")
   switch(acc_event.response)
   {
   case EX_DATA:
    EFlinedyn(&dynargs, &acc_event.event.button,NULL,NULL,NULL,NULL,
                 NULL, NULL, NULL, NULL, NULL, NULL, NULL);
    me->projection_dist_stored_as_event = FALSE;
    loc_value = BSdistptpt(&rc, &dynargs.disbuf[0].geometry.polyline->points[0],
                   &dynargs.disbuf[0].geometry.polyline->points[3]);
    if(rc != BSSUCC){ sts = EMS_E_BSerror; goto ret_end;}
    OM_BLOCK_MOVE(&acc_event, &me->loc_events[DISTANCE_EVENT], event_size); 
    if(loc_value < cht)
    {
     ex$message(msgnumb = EMS_E_DepthGtrCht)
     break;
     }
    else
    {
    /*
     * Verify the input. The input data point must be on the side of
     * projection direction given in the earlier step. Incase not "ERROR OUT"
     * with the confilicting inputs.
     */
    sts = BSmkvec(&rc, vector, &dynargs.disbuf[0].geometry.polyline->points[0],
                   &dynargs.disbuf[0].geometry.polyline->points[3]);
    if(rc != BSSUCC){ sts = EMS_E_BSerror; goto ret_end;}
    BSnorvec(&rc, vector);
    dotp = BSdotp(&rc, dynargs.proj_vec, vector);
    if(dotp < 0.0)
     {
      ex$message(msgnumb = EMS_E_ProjdirConflict)
     }
    else
      me->matdepth = loc_value;
    }
     ME.super_cmd->state = SELECT_SOLID;
     break;
   case EX_VALUE:
     me->projection_dist_stored_as_event = TRUE;
     OM_BLOCK_MOVE(&acc_event, &me->loc_events[DISTANCE_EVENT], event_size);
     loc_value = acc_event.event.value;
     if(loc_value < cht)
     {
     ex$message(msgnumb = EMS_E_DepthGtrCht)
     break;
     }
     else
      me->matdepth = loc_value;
      ME.super_cmd->state = SELECT_SOLID;
     break;
   case EX_BACK_UP:
    ME.super_cmd->state = SELECT_PROFILE;
    break;
   case EX_RJT_MOVEON:
     ME.super_cmd->state = ENTER_DISTANCE;
     break;
   default:
    return(OM_S_SUCCESS);
   }
  }

   break;

  case SELECT_SOLID:

   dp$erase_hilite(msg = &msg_loc);
   display_flag = ALL_WINDOWS | ELEM_HILIGHT;
   locate_mask = GRm_DATA | GRm_BACK_UP;
   accept_mask = GRm_DATA | GRm_BACK_UP;
   
   elig_classes.w_count = 1;
   eliclass = OPP_EMSsurface_class_id;
   elig_classes.p_classes = &eliclass;
   elig_classes.w_flags = OM_CLST_subclass;

   rtree_classes.w_count = 1;
   rclass = OPP_EMSsubbs_class_id;
   rtree_classes.w_flags = OM_CLST_subclass;
   rtree_classes.p_classes = &rclass;
    
   attributes.properties = LC_LC_ONLY | LC_DP_ONLY | LC_RW;
 aflag = pwIsActivationOn();
 if(aflag)
 {
   attributes.owner_action = LC_RIGID_OWNER | LC_FLEX_COMP |
                             LC_NO_REF_HEADER | LC_REF_OBJECTS |
                             LC_ASSOCIATIVE | LC_EXTERN_CONSTRAINED;
 }
 else 
 {
   attributes.owner_action = LC_RIGID_OWNER | LC_FLEX_COMP |
                             LC_NO_REF_HEADER | LC_NO_REF_OBJECTS |
                             LC_ASSOCIATIVE | LC_EXTERN_CONSTRAINED;
 }
  if(aflag = pwIsActivationOn())
  {
   extern IGRlong RFlocate_ref_plane_handler();
   GRspacenum osn;
   osn = pwGetActiveOs();
   lc$locate(rc = &object_was_located,
            event1 = &me->locate_event,
            event2 = &acc_event,
            event3 = &loc_event,
            mask1 = locate_mask,
            mask2 = accept_mask,
            display_flag = display_flag,
            response = response,
            response_data = response_data,
            locate_key = EMS_P_00032,
            acc_key = EMS_P_00038,
            relocate_key = EMS_I_00012,
            attributes = &attributes,
            stack = &me->locate_stack,
            rtree_classes = &rtree_classes,
            eligible_classes = &elig_classes,
            act_handler = RFlocate_ref_plane_handler,
            act_args = &osn);
  }
  else
  {
   lc$locate(rc = &object_was_located,
            event1 = &me->locate_event,
            event2 = &acc_event,
            event3 = &loc_event,
            mask1 = locate_mask,
            mask2 = accept_mask,
            display_flag = display_flag,
            response = response,
            response_data = response_data,
            locate_key = EMS_P_00032,
            acc_key = EMS_P_00038,
            relocate_key = EMS_I_00012,
            attributes = &attributes,
            stack = &me->locate_stack,
            rtree_classes = &rtree_classes,
            eligible_classes = &elig_classes);
  }
   if(!object_was_located)
    {
    switch(loc_event.response)
     {
     case EX_BACK_UP:
      if(me->symmetric)
      {
       if(me->is_finite)
        ME.super_cmd->state = ENTER_DISTANCE;
       else
        ME.super_cmd->state = SELECT_PROFILE;
      }
     else
      {
       if(me->is_finite)
        ME.super_cmd->state = ENTER_DISTANCE;
       else
        ME.super_cmd->state = OFFSET_SIDE;
      }
     break;
    default:
     return(OM_S_SUCCESS);
     }
    }
  else
   OM_BLOCK_MOVE(&loc_event, &me->loc_events[SOLID_EVENT], event_size);
   /*
    * put the event on the queue
    */
    putque_size = sizeof(acc_event.event) + sizeof(IGRint);
    sts = ex$putque(msg = &msg_loc, response = response,
                byte = &putque_size, buffer = (char *)&acc_event.event);
    ERROR(sts, msg_loc, "ex$putque error") 
    ME.super_cmd->state = FEATURE_PLACEMENT_STATE;
    sts = dp$erase_hilite(msg = &msg_loc);

    break;
   
   case FEATURE_PLACEMENT_STATE:

    ex$message(msgnumb = EMS_P_00038)
    event_mask = GRm_DATA | GRm_BACK_UP;
    sts = ems$getevent(msg = &msg_loc, event_mask = event_mask,
                 response = (IGRlong *)response, response_data = response_data,
                 event = &event);
    if(!(1&sts)) { sts = FAIL; goto ret_end; }
    switch(event.response)
    {
    case EX_DATA:
     
     const_args.msg = &msg_loc;
     const_args.newflag = FALSE;
     const_args.geometry = NULL;
     const_args.class_attr = NULL;
     const_args.name = NULL;
     const_args.level = ME.COconst->ActiveLevel;
     const_args.display = &ME.COconst->ActiveDisplay;
     const_args.env_info = 
              &me->loc_events[SOLID_EVENT].located_object[0].module_info;
     const_args.properties = GRIS_LOCATABLE | GRIS_DISPLAYABLE |
                             GRIS_NEW;
     me->construct_id.osnum = 
           me->loc_events[SOLID_EVENT].located_object[0].located_obj.osnum; 
   
     /*
      * Perform the actual feature placement operation.
      */
     recomp_info.attributes =(me->is_finite ? EMSfeature_finite : NULL) |
                             (me->symmetric ? EMSfeature_symmetric : NULL) |
                             (me->extend_curve?EMSfeature_profile_extend:NULL)|
                             (me->thickness_in_profile_plane?
                                EMSfeature_thickness_in_profile_plane : NULL);
    /*
     * fill in profile info
     */
    OM_BLOCK_MOVE(&me->loc_events[PROFILE_EVENT].located_object[0].located_obj, 
                 &parent_info.profile.grid, sizeof (struct GRid)); 
    OM_BLOCK_MOVE(&me->loc_events[PROFILE_EVENT].located_object[0].module_info, 
                    &parent_info.profile.env, sizeof (struct GRmd_env)); 
   /*
    * fill in base solid (active state) info 
    */
    OM_BLOCK_MOVE(&me->loc_events[SOLID_EVENT].located_object[0].located_obj,
                 &parent_info.solid.grid, sizeof (struct GRid));
    OM_BLOCK_MOVE(&me->loc_events[SOLID_EVENT].located_object[0].module_info,
                    &parent_info.solid.env, sizeof (struct GRmd_env));
    /*
     * fill in thickness info 
     */
    if (me->thickness_stored_as_event)
    {
       parent_info.thickness.type = EMSdatainfo_event;
       parent_info.thickness.valevent = (struct GRevent *) alloca
                                        (sizeof (struct GRevent));
       OM_BLOCK_MOVE (&me->loc_events[THICKNESS_EVENT],
                      parent_info.thickness.valevent,
                      sizeof (struct GRevent));
    }
    else /* it is a plain old value */
    {
      parent_info.thickness.type = EMSdatainfo_numeric;
      parent_info.thickness.val  = me->thickness;
    }

    /* 
     * if finite rib, fill in projection distance info 
     */
    if (me->is_finite)
    {
       if (me->projection_dist_stored_as_event)
       {
         parent_info.proj_dist.type = EMSdatainfo_event;
         parent_info.proj_dist.valevent = (struct GRevent *) alloca 
                                         (sizeof (struct GRevent));
         OM_BLOCK_MOVE (&me->loc_events[DISTANCE_EVENT],
                        parent_info.proj_dist.valevent, 
                        sizeof (struct GRevent)); 
       }
       else /* it is a plain old value */
       {
         parent_info.proj_dist.type = EMSdatainfo_numeric;
         parent_info.proj_dist.val  = me->matdepth;
       }
    }

    /* fill in "flip thickness side" info */
    parent_info.flip_thickness_side.type = EMSdatainfo_numeric;
    parent_info.flip_thickness_side.val  = me->flip_thick_side? 1.0 : 0.0;
    
    /* fill in "flip projection side" info */
    parent_info.flip_projection_side.type = EMSdatainfo_numeric;
    parent_info.flip_projection_side.val  = me->flip_prj_side? 1.0 : 0.0;

#ifdef DEBUG
    printf ("Flip projection side = %2.1f\n", 
                  parent_info.flip_projection_side.val);
    printf ("Flip thickness side = %2.1f\n", 
                  parent_info.flip_thickness_side.val);
#endif
    sts =  EFplace_feature(&msg_loc,
                            me->associative? NULL : EMSasconst_notassociative,
                            EMS_ASSOC_FEATURE_RIB,
                            &recomp_info,
                            (IGRchar *)&parent_info,&const_args, 
                            &me->construct_id);
     if(!(1&sts))
     {
      ex$message(msgnumb = EMS_I_ErrorInConstruction)
      sleep(3);
      sts = FAIL;
      goto ret_end;
     }
     me->const_state = DONE;
     ME.super_cmd->state = BEGIN_STATE;
     ex$message( msgnumb = EMS_I_ProcessCompBackUpToUndo)
     break;
   case EX_BACK_UP:
    
    if(me->symmetric)
    {
     if(me->is_finite)
      ME.super_cmd->state = ENTER_DISTANCE;
     else
      ME.super_cmd->state = SELECT_PROFILE;
    }
    else
    {
     if(me->is_finite)
       ME.super_cmd->state = ENTER_DISTANCE;
     else
       ME.super_cmd->state = OFFSET_SIDE;
    }

    break;
   default:
    return(OM_S_SUCCESS); 
    }

   break;
    
   case OFFSET_SIDE:
    ex$message(msgnumb = EMS_P_SelOffsetSide)
    /*
     * Here the dynamic arrow should be displayed. It can be noted here
     * that once the fate of the projection direction is decided we are
     * restricted for the offset direction as it will be perpandicular to
     * the direction of projection.
     */
    dp$dynamics(dyn_fun = EFarrlinedyn, information = &dynargs);
    event_mask = GRm_DATA | GRm_BACK_UP;
    sts = co$getevent(msg = &msg_loc,
                      event_mask = event_mask,
                      response = response,
                      response_data = response_data,
                      event = &acc_event);
    ERROR(sts, msg_loc, "co$getevent error") 
    switch(acc_event.response)
    {
    case EX_DATA:

    OM_BLOCK_MOVE(&acc_event, &me->loc_events[OFFSET_SIDE_EVENT], event_size);

    EFarrlinedyn(&dynargs, &acc_event.event.button,NULL,NULL,NULL,NULL,
                 NULL, NULL, NULL, NULL, NULL, NULL, NULL);

    sts = BSmkvec(&rc, vector, &dynargs.arrow_vector_pts[0],
                         &dynargs.arrow_vector_pts[1]);
    if(rc != BSSUCC){ sts = EMS_E_BSerror; goto ret_end;}
    BSnorvec(&rc, vector);
    me->thick_vector[0] = vector[0];
    me->thick_vector[1] = vector[1];
    me->thick_vector[2] = vector[2];
    /*
     * if WEB type:
     * 1) Get the tangent to the curve at the pivot point( consider the
     *    the special case where the pivot point is lying on the linear
     *     segment) in the plane of the profile.
     * 2) Form the cross product between the tangent vector found in the
     *    first step and the normal to the profile plane. Call it result.
     *    (T x N is the order for cross product)
     * 3) Check if the thickness vector is in the SAME dir as "result".
     *    If it is,
     *     flip_thickness_side = FALSE;
     *    else (OPPOSITE dir)
     *     flip_thickness_side = TRUE;
     *
     * if RIB type:
     *
     * 1) Check if the thickness vector is in the SAME dir as the
     *   normal to the profile plane.
     * 2) If it is,
     *      flip_thickness_side = FALSE;
     *   else
     *      flip_thickness_side = TRUE;
     */

    if(!me->thickness_in_profile_plane)
    {
    dotp = BSdotp(&rc, me->thick_vector, me->vec_nor_prfpln);
    if(dotp > 0.0) /* they are in the same direction */
     me->flip_thick_side = FALSE;
    else
     me->flip_thick_side = TRUE;
    }
    else
    {
    sts = BSprptoncv(&rc,dynargs.prof_geom,&me->pivot_pnt[0],&upar,&oncurve);
    if(rc != BSSUCC){ sts = EMS_E_BSerror; goto ret_end;}
    (void)BScvarrevt(dynargs.prof_geom, &upar, tmp_num_pars, length,
     tmp_results, &rc);
    sts = BSmkvec(&rc, tan_vec, tmp_results[0][0], tmp_results[0][1]);
    BSnorvec(&rc, tan_vec);
    BScrossp(&rc, tan_vec, me->vec_nor_prfpln, outvec);
    dotp = BSdotp(&rc, me->thick_vector, outvec);
    if(dotp > 0.0) /* they are in the same direction */
     me->flip_thick_side = FALSE;
    else
     me->flip_thick_side = TRUE;
    }

    if(me->is_finite)
     ME.super_cmd->state = ENTER_DISTANCE;
    else
     ME.super_cmd->state = SELECT_SOLID;
    break;
    case EX_BACK_UP:
     ME.super_cmd->state = SELECT_PROFILE;
     break;
    default:
      return(OM_S_SUCCESS);
    }
    break;
  } 
 }while(TRUE);
ret_end:
 if(dynargs.prof_geom) om$dealloc (ptr = dynargs.prof_geom);
 me->const_state = INIT;
 ME.super_cmd->state = BEGIN_STATE;
 sts = OM_S_SUCCESS; /* reset to return to case BEGIN_STATE */

 return(sts);
} /* execute */

#argsused
static IGRint EFarrwdyn(dynargs,
              cursor_pt,
              matrix,
              objects,
              num_objects,
              buffer,
              num_buffers,
              in_dummy1,
              in_dummy2,
              in_dummy3,
              out_dummy1,
              out_dummy2,
              out_dummy3)
struct dynfunc_args *dynargs;
struct DPele_header **buffer;
struct GRid **objects;
struct EX_button *cursor_pt;
IGRint *num_objects, *num_buffers;
IGRdouble *matrix;
IGRchar **in_dummy1, **in_dummy2, **in_dummy3;
IGRchar **out_dummy1, **out_dummy2, **out_dummy3;
{
 IGRpoint curpt, projpt1, projpt2, pt_of_interest, temp_pt, temp_curpt;
 IGRdouble line1[2][3], line2[2][3], val1, val2, diag_val, junk_value;
 IGRdouble result1, result2;
 IGRvector temp_vec, test_vec1, test_vec2, test_vec3;
 IGRint N, i, j;
 struct IGRbsp_curve *cvgeom=NULL;
 IGRboolean is_degen1, is_degen2;
 BSrc rc;
 IGRmatrix matrix1;
 IGRlong sts, msg_loc, bytes_retrn, ret_stat;
 extern void EMgetarrowheads();
 IGRdouble junk_arrow_vec[2][3];
 struct var_list list_var[2];

 sts = OM_S_SUCCESS;
 val1 = 0.0;
 val2 = 0.0;
 for(j=0; j <2; j++)
  {
   list_var[j].var = (j == 0) ? VW_ROT_NO_CON : END_PARAM;
   list_var[j].var_ptr = (j == 0) ? (char *)matrix1 : NULL;
   list_var[j].num_bytes = (j == 0) ? (16 * sizeof(IGRdouble)) : 0;
   list_var[j].bytes_returned = (j == 0) ? &bytes_retrn : NULL;
  }

 sts = dp$inq_set_gragad(msg = &msg_loc,
                         inq0_set1 = 0,
                         osnum = cursor_pt->osnum,
                         gragad_objid = cursor_pt->objid,
                         which_error = &ret_stat,
                         var_list = list_var);
 if(!(1&sts&msg_loc)) goto ret_end;
 OM_BLOCK_MOVE(&matrix1[8], temp_vec, sizeof(IGRvector));
 OM_BLOCK_MOVE(dynargs->the_point, temp_pt, sizeof(IGRpoint));

 cvgeom = &dynargs->curvebuff[0];
 N = cvgeom->num_poles;
 sts = BSproj1(&rc, &cvgeom->poles[0], temp_vec, temp_pt, &line1[0][0]);
 sts = BSproj1(&rc,&cvgeom->poles[3 * (N - 1)],temp_vec,temp_pt,&line1[1][0]);
/*
 OM_BLOCK_MOVE(&cvgeom->poles[0], &line1[0][0], sizeof(IGRpoint));
 OM_BLOCK_MOVE(&cvgeom->poles[3 * (N - 1)], &line1[1][0], sizeof(IGRpoint));
*/

 cvgeom = &dynargs->curvebuff[1];
 N = cvgeom->num_poles;
 sts = BSproj1(&rc, &cvgeom->poles[0], temp_vec, temp_pt, &line2[0][0]);
 sts = BSproj1(&rc,&cvgeom->poles[3 * (N - 1)],temp_vec,temp_pt,&line2[1][0]);
/*
 OM_BLOCK_MOVE(&cvgeom->poles[0], &line2[0][0], sizeof(IGRpoint));
 OM_BLOCK_MOVE(&cvgeom->poles[3 * (N - 1)], &line2[1][0], sizeof(IGRpoint));
*/

 diag_val = BSdistptpt(&rc, &dynargs->range[0], &dynargs->range[3]);
 dynargs->length_fraction = 1.0/12.0;
 junk_value = diag_val * dynargs->length_fraction;
 /*
  * This number 12 is addressed by the spec as the fraction size for the arrow 
  * to be displayed.
  */
 temp_curpt[0] = cursor_pt->x;
 temp_curpt[1] = cursor_pt->y;
 temp_curpt[2] = cursor_pt->z;

 sts = BSproj1(&rc, &temp_curpt[0], temp_vec, temp_pt, &curpt[0]);
 /*
  * Do point project of this point on the lines contained in the 
  * buffer.
  */
 (void)BSproj0(&rc, curpt, line1, projpt1);
 if(rc == BSIDGENRAT)
  is_degen1 = TRUE;
 else
  {
  val1 = BSdistptpt(&rc, curpt, projpt1);
  is_degen1 = FALSE;
  }

 (void)BSproj0(&rc, curpt, line2, projpt2);
 if(rc == BSIDGENRAT)
  is_degen2 = TRUE;
 else
  {
  val2 = BSdistptpt(&rc, curpt, projpt2);
  is_degen2 = FALSE;
  }

 /*
  * Find which of the projected point is near to the curpt.
  */
 if(is_degen1)
  {
  sts = BSmkvec(&rc, test_vec1, dynargs->the_point, projpt2);
  sts = BSmkvec(&rc, test_vec2, dynargs->the_point, &line2[0][0]);
  sts = BSmkvec(&rc, test_vec3, dynargs->the_point, &line2[1][0]);
  result1 = BSdotp(&rc, test_vec1, test_vec2);
  result2 = BSdotp(&rc, test_vec1, test_vec3);
  if(result1 > result2)
   OM_BLOCK_MOVE(&dynargs->curvebuff[1].poles[0],pt_of_interest,
                                                    sizeof(IGRpoint));
  else
   OM_BLOCK_MOVE(&dynargs->curvebuff[1].poles[3],pt_of_interest,
                                                    sizeof(IGRpoint));
  }
 else
  if(is_degen2)
  {
  sts = BSmkvec(&rc, test_vec1, dynargs->the_point, projpt1);
  sts = BSmkvec(&rc, test_vec2, dynargs->the_point, &line1[0][0]);
  sts = BSmkvec(&rc, test_vec3, dynargs->the_point, &line1[1][0]);
  result1 = BSdotp(&rc, test_vec1, test_vec2);
  result2 = BSdotp(&rc, test_vec1, test_vec3);
  if(result1 > result2)
   OM_BLOCK_MOVE(&dynargs->curvebuff[0].poles[0],pt_of_interest,
                                                    sizeof(IGRpoint));
  else
   OM_BLOCK_MOVE(&dynargs->curvebuff[0].poles[3],pt_of_interest,
                                                    sizeof(IGRpoint));
  }
 else /* !is_degen1 & !is_degen2 */
 {
  if(val1 <= val2)
  {
  sts = BSmkvec(&rc, test_vec1, dynargs->the_point, projpt1);
  sts = BSmkvec(&rc, test_vec2, dynargs->the_point, &line1[0][0]);
  sts = BSmkvec(&rc, test_vec3, dynargs->the_point, &line1[1][0]);
  result1 = BSdotp(&rc, test_vec1, test_vec2);
  result2 = BSdotp(&rc, test_vec1, test_vec3);
  if(result1 > result2)
   OM_BLOCK_MOVE(&dynargs->curvebuff[0].poles[0],pt_of_interest,
                                                    sizeof(IGRpoint));
  else
   OM_BLOCK_MOVE(&dynargs->curvebuff[0].poles[3],pt_of_interest,
                                                    sizeof(IGRpoint));
  }
 else
  {
  sts = BSmkvec(&rc, test_vec1, dynargs->the_point, projpt2);
  sts = BSmkvec(&rc, test_vec2, dynargs->the_point, &line2[0][0]);
  sts = BSmkvec(&rc, test_vec3, dynargs->the_point, &line2[1][0]);
  result1 = BSdotp(&rc, test_vec1, test_vec2);
  result2 = BSdotp(&rc, test_vec1, test_vec3);
  if(result1 > result2)
   OM_BLOCK_MOVE(&dynargs->curvebuff[1].poles[0],pt_of_interest,
                                                    sizeof(IGRpoint));
  else
   OM_BLOCK_MOVE(&dynargs->curvebuff[1].poles[3],pt_of_interest,
                                                    sizeof(IGRpoint));
  }
 }
 sts = BSmkvec(&rc, dynargs->curr_vec, dynargs->the_point, pt_of_interest);
 BSnorvec(&rc, dynargs->curr_vec);

 OM_BLOCK_MOVE(dynargs->the_point, junk_arrow_vec[0], 3*sizeof(IGRdouble));
 for(i=0; i<3; i++)
 junk_arrow_vec[1][i] = junk_arrow_vec[0][i] + junk_value * dynargs->curr_vec[i];

 EMgetarrowheads(&msg_loc, junk_arrow_vec, dynargs->arrow_points, 1.0);

 dp$build_dis_buffer(buffer = &dynargs->disbuf[0],
                      type = IGRPY,
                      display_att = dynargs->display_stuff,
                      geometry = &dynargs->arrow_head[0]);

 dp$build_dis_buffer(buffer = &dynargs->disbuf[4],
                      type = IGRPY,
                      display_att = dynargs->display_stuff,
                      geometry = &dynargs->arrow_head[1]);

 OM_BLOCK_MOVE(junk_arrow_vec, dynargs->arrow_vector_pts, 2*sizeof(IGRpoint));

 dp$build_dis_buffer(buffer = &dynargs->disbuf[3],
                      type = IGRPY,
                      display_att = dynargs->display_stuff,
                      geometry = &dynargs->arrow_vector);

 if (buffer)
 {
  *buffer = dynargs->disbuf;
  *num_buffers = 6;
 }
ret_end:
 return(TRUE);
}
#argsused
static IGRint EFlinedyn(dynargs,
              cursor_pt,
              matrix,
              objects,
              num_objects,
              buffer,
              num_buffers,
              in_dummy1,
              in_dummy2,
              in_dummy3,
              out_dummy1,
              out_dummy2,
              out_dummy3)
struct dynfunc_args *dynargs;
struct DPele_header **buffer;
struct GRid **objects;
struct EX_button *cursor_pt;
IGRint *num_objects, *num_buffers;
IGRdouble *matrix;
IGRchar **in_dummy1, **in_dummy2, **in_dummy3;
IGRchar **out_dummy1, **out_dummy2, **out_dummy3;
{
 struct IGRbsp_curve *cvgeom=NULL;
 IGRint N;
 IGRpoint curpt, projpt;
 IGRdouble line1[2][3], line2[2][3], lentol;
 IGRdouble result1, result2;
 BSrc rc;
 IGRvector vector;
 IGRlong sts;

 sts = OM_S_SUCCESS;
 BSEXTRACTPAR (&rc, BSTOLLENVEC, lentol);
/*
 * Finding the buffer which is parallel to the material addition
 * or the projection vector direction.
 */
 cvgeom = &dynargs->curvebuff[0];
 N = cvgeom->num_poles;

 OM_BLOCK_MOVE(&cvgeom->poles[0], &line1[0][0], sizeof(IGRpoint));
 OM_BLOCK_MOVE(&cvgeom->poles[3], &line1[1][0], sizeof(IGRpoint));
 BSmkvec(&rc, vector, &line1[0][0], &line1[1][0]);
 BSnorvec(&rc, vector);
 result1 = BSdotp(&rc, dynargs->proj_vec, vector);
 if(rc != BSSUCC){ sts = EMS_E_BSerror; goto ret_end;}

 cvgeom = &dynargs->curvebuff[1];
 N = cvgeom->num_poles;
 OM_BLOCK_MOVE(&cvgeom->poles[0], &line2[0][0], sizeof(IGRpoint));
 OM_BLOCK_MOVE(&cvgeom->poles[3], &line2[1][0], sizeof(IGRpoint));
 BSmkvec(&rc, vector, &line2[0][0], &line2[1][0]);
 BSnorvec(&rc, vector);
 if(rc != BSSUCC){ sts = EMS_E_BSerror; goto ret_end;}

 result2 = BSdotp(&rc, dynargs->proj_vec, vector);
 if(rc != BSSUCC){ sts = EMS_E_BSerror; goto ret_end;}
 /*
  * either result1 or result2 should be zero , the other value will be
  * '1' or '-1'. The non-zero value account for the vector which is 
  * parallel to the material addition vector.
  */
 curpt[0] = cursor_pt->x;
 curpt[1] = cursor_pt->y;
 curpt[2] = cursor_pt->z;
 
 if ( result1 > -lentol && result1 < lentol )
 {   /* zero */
 (void)BSproj0(&rc, curpt, line2, projpt);
 if(rc != BSSUCC){ sts = EMS_E_BSerror; goto ret_end;}
 }
 else
 {   /* non zero */
 (void)BSproj0(&rc, curpt, line1, projpt);
 if(rc != BSSUCC){ sts = EMS_E_BSerror; goto ret_end;}
 }

 dynargs->disbuf[0].geometry.polyline->points[3] = projpt[0];
 dynargs->disbuf[0].geometry.polyline->points[4] = projpt[1];
 dynargs->disbuf[0].geometry.polyline->points[5] = projpt[2];

 if (buffer)
 {
  *buffer = dynargs->disbuf;
  *num_buffers = 1;
 }
ret_end:
 return(TRUE);
}

#argsused
static IGRint EFarrlinedyn(dynargs,
              cursor_pt,
              matrix,
              objects,
              num_objects,
              buffer,
              num_buffers,
              in_dummy1,
              in_dummy2,
              in_dummy3,
              out_dummy1,
              out_dummy2,
              out_dummy3)
struct dynfunc_args *dynargs;
struct DPele_header **buffer;
struct GRid **objects;
struct EX_button *cursor_pt;
IGRint *num_objects, *num_buffers;
IGRdouble *matrix;
IGRchar **in_dummy1, **in_dummy2, **in_dummy3;
IGRchar **out_dummy1, **out_dummy2, **out_dummy3;
{
 struct IGRbsp_curve *cvgeom=NULL;
 IGRint N, i;
 IGRpoint  curpt, projpt;
 IGRdouble line1[2][3], line2[2][3];
 IGRdouble result1, result2, lentol;
 BSrc rc;
 IGRvector vector;
 IGRlong sts, msg_loc;
 IGRdouble diag_val, junk_value;
 IGRdouble junk_arrow_vec[2][3];
 extern void EMgetarrowheads();

 sts = OM_S_SUCCESS;
 BSEXTRACTPAR (&msg_loc, BSTOLLENVEC, lentol);
/*
 * Finding the buffer which is perpandicular to the material addition
 * or the projection vector direction.
 */
 cvgeom = &dynargs->curvebuff[0];
 N = cvgeom->num_poles;

 OM_BLOCK_MOVE(&cvgeom->poles[0], &line1[0][0], sizeof(IGRpoint));
 OM_BLOCK_MOVE(&cvgeom->poles[3], &line1[1][0], sizeof(IGRpoint));
 BSmkvec(&rc, vector, &line1[0][0], &line1[1][0]);
 BSnorvec(&rc, vector);
 result1 = BSdotp(&rc, dynargs->proj_vec, vector);

 cvgeom = &dynargs->curvebuff[1];
 N = cvgeom->num_poles;
 OM_BLOCK_MOVE(&cvgeom->poles[0], &line2[0][0], sizeof(IGRpoint));
 OM_BLOCK_MOVE(&cvgeom->poles[3], &line2[1][0], sizeof(IGRpoint));
 BSmkvec(&rc, vector, &line2[0][0], &line2[1][0]);
 BSnorvec(&rc, vector);

 result2 = BSdotp(&rc, dynargs->proj_vec, vector);
 if(rc != BSSUCC){ sts = EMS_E_BSerror; goto ret_end;}
 /*
  * either result1 or result2 should be zero , the other value will be
  * '1' or '-1'. The zero value account for the vector which is 
  * perpandicular to the material addition vector.
  */
 diag_val = BSdistptpt(&rc, &dynargs->range[0], &dynargs->range[3]);
 dynargs->length_fraction = 1.0/12.0;
 junk_value = diag_val * dynargs->length_fraction;

 curpt[0] = cursor_pt->x;
 curpt[1] = cursor_pt->y;
 curpt[2] = cursor_pt->z;

 if ( result1 > -lentol && result1 < lentol )
 {
 (void)BSproj0(&rc, curpt, line1, projpt);
 if(rc != BSSUCC){ sts = EMS_E_BSerror; goto ret_end;}
 }
 else
 {
 (void)BSproj0(&rc, curpt, line2, projpt);
 if(rc != BSSUCC){ sts = EMS_E_BSerror; goto ret_end;}
 }
 
 sts = BSmkvec(&rc, dynargs->curr_vec, dynargs->the_point, projpt);
 BSnorvec(&rc, dynargs->curr_vec);

 OM_BLOCK_MOVE(dynargs->the_point, junk_arrow_vec[0], 3*sizeof(IGRdouble));
 for(i=0; i<3; i++)
 junk_arrow_vec[1][i] = junk_arrow_vec[0][i] + junk_value * dynargs->curr_vec[i];

 EMgetarrowheads(&msg_loc, junk_arrow_vec, dynargs->arrow_points, 1.0);

  dp$build_dis_buffer(buffer = &dynargs->disbuf[0],
                      type = IGRPY,
                      display_att = dynargs->display_stuff,
                      geometry = &dynargs->arrow_head[0]);

  dp$build_dis_buffer(buffer = &dynargs->disbuf[1],
                      type = IGRPY,
                      display_att = dynargs->display_stuff,
                      geometry = &dynargs->arrow_head[1]);

 OM_BLOCK_MOVE(junk_arrow_vec, dynargs->arrow_vector_pts, 2*sizeof(IGRpoint));

  dp$build_dis_buffer(buffer = &dynargs->disbuf[2],
                      type = IGRPY,
                      display_att = dynargs->display_stuff,
                      geometry = &dynargs->arrow_vector);

 if (buffer)
 {
  *buffer = dynargs->disbuf;
  *num_buffers = 3;
 }
ret_end:
 return(TRUE);
}


static IGRint EFrib_dynamics(grid, grevent, add_info)
struct GRid *grid;
struct GRevent *grevent;
IGRchar *add_info;
{
 IGRlong sts, msg_loc;
 struct dynfunc_args *dynargs;

 sts = OM_S_SUCCESS;
 msg_loc = EMS_S_Success;
 dynargs = (struct dynfunc_args *)add_info;

 if(EFisAncestryValid(&msg_loc, grid->objid, grid->osnum,
                      OPP_GRcurve_class_id, FALSE))
 {
 sts = om$send(msg = message ECrib.ECrib_perform_dynamics(&msg_loc,
                       dynargs, grevent),
                    senderid = NULL_OBJID,
                    targetid = dynargs->cmd_id.objid,
                    targetos = dynargs->cmd_id.osnum);
 if(!(1&sts)) goto ret_end;
 }
ret_end:
 return(TRUE);
}

method ECrib_perform_dynamics(IGRlong *msg; struct dynfunc_args *dynargs;
                              struct GRevent *loc_event)
{
 struct GRid prof_id;
 IGRlong sts, msg_loc, num_bytes, ret_stat, bytes_retrn;
 struct IGRplane pln_of_curve, other_plane;
 IGRpoint point1, point2;
 IGRvector vec1, tmp_vec, vec2;
 IGRdouble uval, a=1.0, b=1.0, vwvolume[6];
 IGRdouble line_pts[6], line_size;
 IGRpoint startpt_line1, stoppt_line1, startpt_line0, stoppt_line0;
 IGRint type, j;
 struct var_list list_var[2];
 IGRboolean oncurve, flag;
 struct IGRbsp_surface plane;
 IGRdouble poles[4][3], u_knots[4], v_knots[4];
 struct IGRdisplay display, loc_disp;
 struct DPele_header lines_buff[3];
 struct IGResbc ele_attr;
 BSrc rc;
 
 sts = OM_S_SUCCESS;
 msg_loc = EMS_S_Success;

 pln_of_curve.point = point1;
 pln_of_curve.normal = vec1;
 other_plane.point = point2;
 other_plane.normal = vec2;

 plane.poles = (IGRdouble *)poles;
 plane.weights = NULL;
 plane.u_knots = (IGRdouble *)u_knots;
 plane.v_knots = (IGRdouble *)v_knots;

 prof_id.objid = loc_event->located_object[0].located_obj.objid;
 prof_id.osnum = loc_event->located_object[0].located_obj.osnum;


 me->window.objid = me->locate_event.event.button.objid;
 me->window.osnum = me->locate_event.event.button.osnum;
 /*
  * Getting the size and geometry of the curve.
  */
 sts = om$send(msg = message GRvg.GRgetsize(&msg_loc,
                   &loc_event->located_object[0].module_info.md_env.matrix_type,
                   loc_event->located_object[0].module_info.md_env.matrix,
                   &num_bytes),
                 targetid = prof_id.objid,
                 targetos = prof_id.osnum);
 ERROR(sts, msg_loc, "execute.GRvg.GRgetsize error")
 dynargs->prof_geom = (struct IGRbsp_curve *) om$malloc (size = num_bytes);
 sts = om$send(msg = message GRvg.GRgetgeom(&msg_loc,
                   &loc_event->located_object[0].module_info.md_env.matrix_type,
                   loc_event->located_object[0].module_info.md_env.matrix,
                   (IGRchar *)dynargs->prof_geom),
                  targetid = prof_id.objid,
                  targetos = prof_id.osnum);
 ERROR(sts, msg_loc, "execute.GRvg.GRgetgeom error")

 sts = om$send(msg = message GRvg.GRdetplane(&msg_loc,
                   &loc_event->located_object[0].module_info.md_env.matrix_type,
                   loc_event->located_object[0].module_info.md_env.matrix,
                   &pln_of_curve),
                 targetid = prof_id.objid,
                 targetos = prof_id.osnum);
 if(!(1 & sts)) goto ret_end;
 if(msg_loc == MSSUCC)
  {
  me->vec_nor_prfpln[0] = pln_of_curve.normal[0];
  me->vec_nor_prfpln[1] = pln_of_curve.normal[1];
  me->vec_nor_prfpln[2] = pln_of_curve.normal[2];
  }
 else
  {
   /* ex$message(msgnumb = EMS_S_IndetminPlane) */
   goto ret_end;
  }

 /*
  * Find a line which is lying in the plane of the profile(it by default
  * means that it is perpandicular ot the first line) and normal to the
  * profile at the pivot point.
  * Get the plane normal to the profile at the pivot point.
  */
 OM_BLOCK_MOVE(loc_event->located_object[0].proj_pnt, &me->pivot_pnt[0],
                  sizeof(IGRpoint));

 sts = BSprptoncv(&rc, dynargs->prof_geom, &me->pivot_pnt[0], &uval, &oncurve);
 if(rc != BSSUCC){ sts = EMS_E_BSerror; goto ret_end;}

 if(dynargs->prof_geom->order > 2)
 {
  BSpl_tan_tc(dynargs->prof_geom, uval, a, b, &plane, &rc);
  if(rc != BSSUCC){ sts = EMS_E_BSerror; goto ret_end;}
  BSsfnormal(&plane, tmp_vec, &rc);
  if(rc != BSSUCC){ sts = EMS_E_BSerror; goto ret_end;}
  BSnorvec(&rc, tmp_vec);
  me->vec_along_prfpln[0] = tmp_vec[0];
  me->vec_along_prfpln[1] = tmp_vec[1];
  me->vec_along_prfpln[2] = tmp_vec[2];
 }
 else /* We need to do something special for the line curve */
 {
 flag = FALSE;
 BSpl_nor_tc(&rc, dynargs->prof_geom, &uval, &flag, NULL, 
        &other_plane.point[0], &other_plane.normal[0], NULL);
 if(rc != BSSUCC){ sts = EMS_E_BSerror; goto ret_end;}
 BScrossp(&rc, &me->vec_nor_prfpln[0], &other_plane.normal[0],
         &me->vec_along_prfpln[0]);
 if(rc != BSSUCC){ sts = EMS_E_BSerror; goto ret_end;}
 BSnorvec(&rc, &me->vec_along_prfpln[0]);
 }

 OM_BLOCK_MOVE(&me->vec_nor_prfpln[0], tmp_vec, sizeof(IGRvector));

 line_pts[0] = line_pts[1] = line_pts[2] = GRDGNLIMITS_MIN_D;
 line_pts[3] = line_pts[4] = line_pts[5] = GRDGNLIMITS_MAX_D;

 line_size = BSdistptpt(&rc, &line_pts[0], &line_pts[3]);
 line_size *= 0.5;

 startpt_line0[0] = me->pivot_pnt[0] + line_size * tmp_vec[0];
 startpt_line0[1] = me->pivot_pnt[1] + line_size * tmp_vec[1];
 startpt_line0[2] = me->pivot_pnt[2] + line_size * tmp_vec[2];

 stoppt_line0[0]  = me->pivot_pnt[0] - line_size * tmp_vec[0];
 stoppt_line0[1]  = me->pivot_pnt[1] - line_size * tmp_vec[1];
 stoppt_line0[2]  = me->pivot_pnt[2] - line_size * tmp_vec[2];
 /*
  * Creating a line between these two points.
  */
 sts = BSptlngen(&rc, startpt_line0, stoppt_line0,
                    &(dynargs->curvebuff[0]), &type);
 if(rc != BSSUCC){ sts = EMS_E_BSerror; goto ret_end;}

 OM_BLOCK_MOVE(&me->vec_along_prfpln[0], tmp_vec, sizeof(IGRvector));

 startpt_line1[0] = me->pivot_pnt[0] + line_size * tmp_vec[0];
 startpt_line1[1] = me->pivot_pnt[1] + line_size * tmp_vec[1];
 startpt_line1[2] = me->pivot_pnt[2] + line_size * tmp_vec[2];

 stoppt_line1[0]  = me->pivot_pnt[0] - line_size * tmp_vec[0];
 stoppt_line1[1]  = me->pivot_pnt[1] - line_size * tmp_vec[1];
 stoppt_line1[2]  = me->pivot_pnt[2] - line_size * tmp_vec[2];

 sts = BSptlngen(&rc, startpt_line1, stoppt_line1,
                    &(dynargs->curvebuff[1]), &type);
 if(rc != BSSUCC){ sts = EMS_E_BSerror; goto ret_end;}
 /*
  * The following stuff is for getting the size of the arrow.
  */
 for(j=0; j <2; j++)
  {
   list_var[j].var = (j == 0) ? VW_VOLUME : END_PARAM;
   list_var[j].var_ptr = (j == 0) ? (char *)vwvolume : NULL;
   list_var[j].num_bytes = (j == 0) ? (6 * sizeof(IGRdouble)) : 0;
   list_var[j].bytes_returned = (j == 0) ? &bytes_retrn : NULL;
  }
 sts = dp$inq_set_gragad(msg = &msg_loc, osnum = me->window.osnum,
                gragad_objid = me->window.objid, which_error = &ret_stat,
                var_list = list_var); 
 OM_BLOCK_MOVE(&vwvolume[0], &dynargs->range[0], 6 * sizeof(IGRdouble));
 OM_BLOCK_MOVE(&loc_event->located_object[0].module_info, &dynargs->modenvcv,
               sizeof(struct GRmd_env));
 OM_BLOCK_MOVE(me->pivot_pnt, dynargs->the_point, sizeof(IGRpoint));
 dynargs->display_stuff = &ME.COconst->ActiveDisplay;

 display.color = dynargs->display_stuff->color;
 display.weight = dynargs->display_stuff->weight + 2;
 display.style = (IGRchar)1;
 ele_attr.is_polydis = FALSE;
 ele_attr.is_curvedis = TRUE;
 dp$build_dis_buffer(buffer = &lines_buff[0],
                      type = IGRBC,
                      display_att = &display,
                      ele_spec_att = &ele_attr,
                      geometry = &dynargs->curvebuff[0]);
 dp$build_dis_buffer(buffer = &lines_buff[1],
                      type = IGRBC,
                      display_att = &display,
                      ele_spec_att = &ele_attr,
                      geometry = &dynargs->curvebuff[1]);
 loc_disp.color = display.color;
 loc_disp.weight = dynargs->display_stuff->weight + 1;
 loc_disp.style = (IGRchar)0;
 dp$build_dis_buffer(buffer = &lines_buff[2],
                      type = IGRBC,
                      display_att = &loc_disp,
                      ele_spec_att = &ele_attr,
                      geometry = dynargs->prof_geom);

 dynargs->disbuf[1] = lines_buff[0];
 dynargs->disbuf[2] = lines_buff[1];
 dynargs->disbuf[5] = lines_buff[2];

 /*
  * The dynamics for displaying the arrow from the pivot point should be
  * done at this stage.
  */
 if (donotcalldyn)
    EFarrwdyn(dynargs, &loc_event->event.button,(IGRdouble *)NULL,
               (struct GRid **)NULL, (IGRint *)NULL,
               (struct DPele_header **)NULL, (IGRint *)NULL,
               (IGRchar **)NULL, (IGRchar **)NULL, (IGRchar **)NULL, 
               (IGRchar **)NULL, (IGRchar **)NULL, (IGRchar **)NULL);
 else
  dp$dynamics(dyn_fun = EFarrwdyn, information = dynargs);

ret_end:
return(sts);
}

end implementation ECrib;



