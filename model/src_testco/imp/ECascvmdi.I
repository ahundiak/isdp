/* ###################   APOGEE COMPILED   ################## */
class implementation ECascvmd;
/*
ABSTRACT

History
           dfl    created  07/94 
           uwa       "       "   


 */

#ifndef OM_DEFINE_ERRMSG
#define OM_DEFINE_ERRMSG
#endif

#define dflT1 0
#define dflT5 0


#include "memory.h"
#include "EMS.h"
#include "OMerrordef.h"
/* igemacros replacement */

# ifndef grdpbmacros_include
# include "grdpbmacros.h" /* gr$get_active_display */
# endif
/* end of igemacros.h replacement */

/* grutildef.h replacement */

# ifndef griodef_include
# include "griodef.h"
# endif

/* end of grutildef.h replacement */

/* grvaluedef.h replacement */

# ifndef griodef_include
# include "griodef.h"
# endif

/* end of grvaluedef.h replacement */
/*#include "grdef.h"*/
#include "igrdef.h"
#include "codef.h"
#include "msdef.h"

#include "griomacros.h" /* co$getevent */
#include "grgsmacros.h"
#include "grmacros.h"
#include "grwireframe.h"
#include "comiscmac.h"
#include "bserr.h"
#include "bsicmpcvoff.h"
#include "math.h"
#include "comisc.h"
#include "nddef.h"
#include "ndmacros.h"
#include "emsdef.h"
#include "emserr.h"
#include "EMSmsgdef.h"
#include "lcmacros.h"
#include "gotextdef.h"
#include "cotxmacros.h"
#include "dpdef.h"
#include "dpmacros.h"
#include "dpezmac.h"
#include "coplcmac.h"
#include "dpstruct.h"
#include "OMobjectcomm.h"
#include "exmacros.h"		/* ex$putqueue() */
#include "EC_M.h"
#include "EC_S.h"
#include "EC_P.h"
#include "EC_I.h"
#include "dpdef.h"
#include "dp.h"
#include "EMSasopts.h"
#include "EMSasnuc.h"
#include "EMSasmacros.h"
#include "nddef.h"
#include "exdef.h"
#include "ECascvmd.h"


/*vvvvv*/
#if defined ( NT )
#if 0 /* because opp cannot handle it */
#include <windows.h>
#endif
#endif

#ifdef X11
#include <X11/Xlib.h>
#unclude <X11/Xutil.h>
#endif

#if defined(__STDC__) || defined(__cplusplus)
#if 0 /* because opp cannot handle it */
#if defined ( X11 )
#include <XFIproto_pub.h>
#elif defined ( ENV5 )
#include <FIproto_pub.h>
#elif defined ( NT )
#include <shampub.h>
#endif
#else
#include <FI.h>
#endif
#else
#include <FI.h>
#endif
/*^^^^^*/

extern IGRdouble  bf_nr();
extern IGRdouble  bf_ra();
extern IGRboolean BSnorvec();
extern IGRboolean BScumdist();
extern IGRdouble 	BSdotp();
extern void BScveval();
extern IGRdouble      fabs(IGRdouble);
/*extern IGRint strlen();*/
IGRint dist_process_form ();
IGRint cvra_process_form ();
IGRint spol_process_form ();
IGRint sknt_process_form ();
IGRint tool, wool;

extern OMuword 			OPP_EMScomposite_class_id;
extern OMuword 			OPP_GR3dlineseg_class_id;
extern OMuword 			OPP_GR3dlinestr_class_id;
extern OMuword 			OPP_GA3dlinestr_class_id;
extern OMuword 			OPP_GRbspline_class_id;
extern OMuword 			OPP_GRcurve_class_id;
extern OMuword 			OPP_EMSdatpln_class_id;
extern OMuword 			OPP_EMSplane_class_id;
extern OMuword 			OPP_EMSsurface_class_id;
extern OMuword 			OPP_EMSsubbs_class_id;
extern OMuword 			OPP_GRbcsubbc_class_id;
extern OMuword 			OPP_GRsubbc_class_id;
extern OMuword                  OPP_GRlinear_class_id;
extern OMuword                  OPP_GAbspline_class_id;


from GRgraphics import 	GRlnproject, GRdisplay, GRgetrang, GRdelete, 
                       	GRgetobjinfo, GRptproject;
from GRvg import 	GRgetattr, GRdetplane, GRgeomprops, GRgetgeom,
                        GRgetprops, GRchgprops, GRpostabsg,
                 	GRgetsize, GRconstruct, GRprojpt, EMptatpr;
from EMSsubbs import EMtoggle_polygon;
from GR3dlinestr import GRgetpolyline, GRputpolyline;
from GRlinear import    GRvtadjseg, GRdelvertex;
from GRcurve import 	EMcvoffset, GRgenabsg, GRmidpoint, GRinsvertex;
from EMSassoc import    EMget_info, EMput_info;
from NDnode   import    NDget_objects;
from ASnode   import    NDchange_connect;

IGRlong get_projection_dist(IGRlong *msg, IGRboolean *prodist_b, IGRdouble *prodist)
{

  IGRlong msg_loc, stat_func;
  IGRchar loc_prompt[54];
  IGRlong response;
  IGRchar response_data[54];
  struct GRevent daccev;

        ex$message(msgnumb = EMS_P_EntDist, buff = loc_prompt);

        stat_func = co$getevent(
                  msg = &msg_loc,
                  event_mask = (GRm_VALUE |
                                GRm_DATA | 
                                GRm_RJT_MOVEON),
                  prompt = loc_prompt,
                  response = &response,
                  response_data = &response_data[0],
                  event = &daccev);

        switch (daccev.response) {

          case EX_RJT_MOVEON:
	  default:
            goto function_end;


          case EX_VALUE:
               *prodist = daccev.event.value;
               if( *prodist == 0.0)
                 *prodist_b = FALSE;
               else if(*prodist < 0.0) {
                 *prodist *= -1;
                 *prodist_b = TRUE;
               } else 
                 *prodist_b = TRUE;
               break;
	  }

function_end:
  return(OM_S_SUCCESS);

}

method init (IGRint type; IGRchar *string) 
{
  /***init***/
  IGRchar 	errmsg[EMMAXERRMSG_LEN]; 
  IGRint 	sts;

#if dflT1
  printf("in init \n"); 
#endif
  ME.super_cmd->state = me->command = GET_CURVE;
  me->prodist = 0.0;
  me->bed_a = me->shape_amount_left = BED_A;
  me->bed_e = me->shape_amount_right = BED_E;
  me->ex_cmd_pressed = FALSE;
  me->dynamic = FALSE;
  me->smooth = FALSE;
  me->smfac = 0.0;
  me->keep_planar = FALSE;
  me->n_anf = N_ANF;
  me->n_end = N_END;
  me->fromto = FALSE;
  me->ls_found = FALSE;
  me->polypoints_allocated = FALSE;
  me->cursor_sensitivity = 1;
  me->symetric = TRUE;
  me->left = FALSE;
  me->right = FALSE;
  me->range_mode = TRUE;
  me->shape_mode = FALSE;
  me->range = me->shape = SYMETRIC;
  me->pot_a = me->shape_amount_left = SHAPE_DFLT;
  me->pot_e = me->shape_amount_right = SHAPE_DFLT;
  me->init_on = TRUE;
  me->error_flag = FALSE;
  me->show_poles = FALSE;
  me->show_hedgehog = FALSE;
  me->show_curvature = FALSE;
  me->fxpos = main_WLOX;
  me->fypos = main_WLOY; 
  me->mark_point_id.objid = 0;

  sts = om$send (
        mode = OM_e_wrt_parent,
        msg = message ECascvmd.init (type, string),
        targetid = my_id);


  strcpy (errmsg, "ECascvmd.init");


  me->optform_requested = FALSE;
  me->form_id = NULL_OBJID;
  me->active_form_name[0] = '\0';

  ex$message(msgnumb = EMS_I_InvkStatusFrm);

 
  return sts;
  
}

method wakeup (int pos) 
{
  /***wakeup***/

  IGRint sts = OM_S_SUCCESS;
  sts = om$send (msg= message ECascvmd.wakeup(pos),
                 mode = OM_e_wrt_parent,
                 targetid = my_id);

  ME.super_cmd->state = me->command;
 
#if dflT1
  printf("in wakeup\n"); 
#endif
  
  /*gr$get_associative_flag ( buffer = &me->is_associative );

  if (me->is_associative)
    GRdisplay_associative_button(TRUE);*/

  if(me->optform_requested) 
       FIf_display(me->optform);
  ex$message(msgnumb = EMS_I_InvkStatusFrm);
  ex$message (msgnumb = EM_M_AsCvMd);
  GRstatus_display_button(TRUE);

  return sts;  

}

method sleep(int pos) 
{
    /***sleep***/

    IGRint 	sts;
 
#if dflT1
  printf("in sleep\n"); 
#endif


    /*clear fields */
    ex$message( field=PROMPT_FIELD,
             msgnumb = EMS_P_00000 );
    ex$message( field = ERROR_FIELD,
             msgnumb = EMS_I_00000 );

    /*if (me->is_associative)
      GRdisplay_associative_button(FALSE);*/

    if(me->optform_requested) 
       FIf_erase(me->optform);

    GRstatus_display_button(FALSE);

    sts = om$send (
        mode = OM_e_wrt_parent,
        msg = message ECascvmd.sleep (pos),
        targetid = my_id);

    me->command = ME.super_cmd->state;
    ME.ECelement->elem_hilit = FALSE;

    return(sts); 
}
method status_disp() 
{
  /***status_disp***/

  IGRlong 	status, EMmsg;
  /*OM_S_OBJID 	set_id = NULL_OBJID;*/
  int 		ret;
  IGRint 	opt1_process_form();

#if dflT1
  printf("in status_disp\n"); 
#endif

  status = OM_S_SUCCESS;
  EMmsg = 1;

  if(me->optform_requested) 
     goto wrapup;

  ret = FIf_new (OPTFORM, 
                 "EMAsCrvMod", 
                 opt1_process_form, 
                 &me->optform);
  if (ret) {
      status = FALSE;
      goto wrapup;
  }

  ret = FIf_set_cmd_oid_os(me->optform, 
                           my_id, 
                           OM_Gw_current_OS);
  if (ret) {
      status = FALSE;
      goto wrapup;
  } 

  if (!me->optform_requested) {
    ret = FIf_set_location (me->optform, me->fxpos, me->fypos);
    if (ret) {
       status = FALSE;
      goto wrapup;
    }

      ret = FIf_display(me->optform);
      if (ret) {
       status = FALSE;
       goto wrapup;
      }

    me->optform_requested = TRUE;
  }

  if(me->optform_requested) {
    FIg_set_value(me->optform, S_PRODIST_F, me->prodist); 

    if(me->ls_found)
       FIg_set_state_on(me->optform, S_LSIDFID_CI);  
    if (me->cursor_sensitivity)
          FIg_set_state(me->optform, S_CURSOR_S,TRUE);
    else
          FIg_set_state(me->optform, S_CURSOR_S,FALSE);
    if (me->smooth) {
          FIg_set_state_on(me->optform, S_SMOOTH_B);
          FIg_set_value(me->optform,S_SMFAC_F,(IGRdouble)
               me->smfac);
    }      
    if (me->set_stpt) 
          FIg_set_state_on(me->optform, S_STARTPT_B);
    if(me->stfree)
          FIg_set_state_on(me->optform, S_SFREE_B);
    if(me->stfix)
          FIg_set_state_on(me->optform, S_SFIX_B);
    if(me->stta)
          FIg_set_state_on(me->optform, S_STA_B);
    if(me->stcrv)
          FIg_set_state_on(me->optform, S_SCURV_B);
    if(me->efree)
          FIg_set_state_on(me->optform, S_EFREE_B);
    if(me->efix)
          FIg_set_state_on(me->optform, S_EFIX_B);
    if(me->eta)
          FIg_set_state_on(me->optform, S_ETA_B);
    if(me->ecrv)
          FIg_set_state_on(me->optform, S_ECURV_B);
    if (me->set_ept)
          FIg_set_state_on(me->optform, S_ENDPT_B);
    if (me->set_ept)
          FIg_set_state_on(me->optform, S_ENDPT_B);
    if (me->keep_planar)
          FIg_set_state_on(me->optform, S_PLANAR_B);
    if (me->range_mode)
          FIg_set_state_on(me->optform, S_RANGE_B);
    if (me->shape_mode )
          FIg_set_state_on(me->optform, S_SHAPE_B);
    if (me->symetric)
          FIg_set_state_on(me->optform, S_SYM_B);
    if (me->left)
          FIg_set_state_on(me->optform, S_LEFT_B);
    if (me->right)
          FIg_set_state_on(me->optform, S_RIGHT_B);
    if (me->fromto)    
          FIg_set_state(me->optform, S_FROMTO_B,FALSE);
    else
          FIg_set_state(me->optform, S_FROMTO_B,TRUE);
    if (me->show_hedgehog)
          FIg_set_state(me->optform, S_SHCU_B,TRUE);
    if (me->show_curvature)
          FIg_set_state(me->optform, S_SHCU_B,TRUE);
    if (me->show_poles)
          FIg_set_state(me->optform, S_SHPO_B,TRUE);
    if (me->show_distance)
          FIg_set_state(me->optform, S_SHDI_B,TRUE);
    if (me->show_vertices)
          FIg_set_state(me->optform, S_SHVE_B,TRUE);
    FIg_set_value(me->optform,S_RSHAPE_F,(IGRdouble)
               me->shape_amount_right);
    FIg_set_value(me->optform,S_LSHAPE_F,(IGRdouble)
               me->shape_amount_left);
    FIg_set_value(me->optform,S_RRANGE_F,(IGRdouble)
               me->n_end);
    FIg_set_value(me->optform,S_LRANGE_F,(IGRdouble)
               me->n_anf);
 
  }



wrapup:
 if (!(1&status&EMmsg))
   return (OM_E_ABORT);

  return (status); 
}


IGRint opt1_process_form (form_label, gadget_label, value,
form_ptr) 
  int form_label, gadget_label; double value; Form form_ptr; 
{
  /***opt1_process_form***/

  IGRint stat_func, stat_OM;
  IGRlong msg_loc;
  GRobjid cmdobj;
  GRspacenum cmdos;
  

#if dflT1
  printf("in process slider form\n"); 
#endif

  stat_OM = OM_S_SUCCESS;

  stat_func = FIf_get_cmd_oid_os (form_ptr, &cmdobj, &cmdos);
  if (stat_func)
    return (OM_E_ABORT);

  stat_OM = om$send (msg = message ECascvmd.opt_do_form (&msg_loc,
                                                       form_label,
                                                       gadget_label, 
                                                       value),
                     senderid = NULL_OBJID, 
                     targetid = cmdobj, 
                     targetos = cmdos);
  if(! (stat_OM & 1)) {
    return (OM_E_ABORT); 
  }

  return (stat_OM); 

}

method opt_do_form(IGRlong *msg; IGRint form_label; IGRint gadget_label;
               IGRdouble value) 
{
 /***opt_do_form***/

 IGRlong        stat_OM, sts, msg_loc, stat_func;
 enum GRdpmode dpmode;
 IGRint toggle=0;
 IGRint ret;

 sts = OM_S_SUCCESS;
 stat_OM = OM_S_SUCCESS;
 strcpy(me->errmsg,"ECascvmd.opt_do_form");
 
 if (form_label == OPTFORM) {
 switch (gadget_label)
  {
   case RESET_B:
     if(!me->dynamic) {
       me->prodist = 0.0;
       me->common_dist = FALSE;
       me->bed_a = me->shape_amount_left = BED_A;
       me->bed_e = me->shape_amount_right = BED_E;
       me->n_anf = N_ANF;
       me->n_end = N_END;
       me->cursor_sensitivity = 1;
       me->symetric = TRUE;
       me->left = FALSE;
       me->right = FALSE;
       me->range_mode = TRUE;
       me->shape_mode = FALSE;
       me->range = me->shape = SYMETRIC;
       me->pot_a = me->shape_amount_left = SHAPE_DFLT;
       me->pot_e = me->shape_amount_right = SHAPE_DFLT;
       if(me->optform_requested) {
          FIg_set_value(me->optform, S_PRODIST_F,me->prodist );
          if (me->cursor_sensitivity)
             FIg_set_state(me->optform, S_CURSOR_S,TRUE);
          else
             FIg_set_state(me->optform, S_CURSOR_S,FALSE);
          if (me->range_mode)
             FIg_set_state_on(me->optform, S_RANGE_B);
          if (me->shape_mode )
             FIg_set_state_on(me->optform, S_SHAPE_B);
          if (me->symetric)
             FIg_set_state_on(me->optform, S_SYM_B);
          if (me->left)
             FIg_set_state_on(me->optform, S_LEFT_B);
          if (me->right)
             FIg_set_state_on(me->optform, S_RIGHT_B);
          if (me->fromto)    
             FIg_set_state(me->optform, S_FROMTO_B,FALSE);
          else
             FIg_set_state(me->optform, S_FROMTO_B,TRUE);
          FIg_set_value(me->optform,S_RSHAPE_F,(IGRdouble)
               me->shape_amount_right);
          FIg_set_value(me->optform,S_LSHAPE_F,(IGRdouble)
               me->shape_amount_left);
          FIg_set_value(me->optform,S_RRANGE_F,(IGRdouble)
               me->n_end);
          FIg_set_value(me->optform,S_LRANGE_F,(IGRdouble)
               me->n_anf);
          FIg_set_value(me->optform, S_PRODIST_F, me->prodist); 
 
	}

     } else {
       if(me->optform_requested) {
         FIg_set_value(me->optform, S_PRODIST_F, me->prodist); 
         if(me->ls_found)
           FIg_set_state_on(me->optform, S_LSIDFID_CI);  
         if (me->cursor_sensitivity)
            FIg_set_state(me->optform, S_CURSOR_S,TRUE);
         else
            FIg_set_state(me->optform, S_CURSOR_S,FALSE);
         if (me->set_stpt) 
            FIg_set_state_on(me->optform, S_STARTPT_B);
         if(me->stfree)
            FIg_set_state_on(me->optform, S_SFREE_B);
         if(me->stfix)
            FIg_set_state_on(me->optform, S_SFIX_B);
         if(me->stta)
            FIg_set_state_on(me->optform, S_STA_B);
         if(me->stcrv)
            FIg_set_state_on(me->optform, S_SCURV_B);
         if(me->efree)
            FIg_set_state_on(me->optform, S_EFREE_B);
         if(me->efix)
            FIg_set_state_on(me->optform, S_EFIX_B);
         if(me->eta)
            FIg_set_state_on(me->optform, S_ETA_B);
         if(me->ecrv)
            FIg_set_state_on(me->optform, S_ECURV_B);
         if (me->set_ept)
            FIg_set_state_on(me->optform, S_ENDPT_B);
         if (me->set_ept)
            FIg_set_state_on(me->optform, S_ENDPT_B);
         if (me->keep_planar)
            FIg_set_state_on(me->optform, S_PLANAR_B);
         if (me->range_mode)
            FIg_set_state_on(me->optform, S_RANGE_B);
         if (me->shape_mode )
            FIg_set_state_on(me->optform, S_SHAPE_B);
         if (me->symetric)
            FIg_set_state_on(me->optform, S_SYM_B);
         if (me->left)
            FIg_set_state_on(me->optform, S_LEFT_B);
         if (me->right)
            FIg_set_state_on(me->optform, S_RIGHT_B);
         if (me->fromto)    
            FIg_set_state(me->optform, S_FROMTO_B,FALSE);
         else
            FIg_set_state(me->optform, S_FROMTO_B,TRUE);
         if (me->show_hedgehog)
            FIg_set_state(me->optform, S_SHCU_B,TRUE);
         if (me->show_curvature)
            FIg_set_state(me->optform, S_SHCU_B,TRUE);
         if (me->show_poles)
            FIg_set_state(me->optform, S_SHPO_B,TRUE);
         if (me->show_distance)
            FIg_set_state(me->optform, S_SHDI_B,TRUE);
         if (me->show_vertices)
            FIg_set_state(me->optform, S_SHVE_B,TRUE);
         FIg_set_value(me->optform,S_RSHAPE_F,(IGRdouble)
               me->shape_amount_right);
         FIg_set_value(me->optform,S_LSHAPE_F,(IGRdouble)
               me->shape_amount_left);
         FIg_set_value(me->optform,S_RRANGE_F,(IGRdouble)
               me->n_end);
         FIg_set_value(me->optform,S_LRANGE_F,(IGRdouble)
               me->n_anf); 
       }

    }
    break;

   case ACCEPT_B:
    me->optform_requested = FALSE;
    /*me->error_flag = FALSE;*/
    FIf_get_location(me->optform,&me->fxpos, &me->fypos);
    ret = FIf_erase(me->optform);


    dpmode = GRbd;
    stat_OM = om$send(mode = OM_e_wrt_object,
                      msg = message GRgraphics.GRdisplay (
                                 &msg_loc,
                                 &me->md_env.md_env.matrix_type,
                                 me->md_env.md_env.matrix,
                                 &dpmode, 
                                 &me->md_env.md_id),
                      senderid = my_id,
                      targetid = me->cv_info.located_obj.objid,
                      targetos = me->cv_info.located_obj.osnum);

    break;

  case S_PRODIST_B:

    ex$message(msgnumb = EMS_P_EntDist);
    stat_func = get_projection_dist(
             &msg_loc, &me->common_dist, &me->prodist);
    FIg_set_value(me->optform, S_PRODIST_F, me->prodist); 
    FIg_set_state_off(me->optform, S_PRODIST_B);

    break;


  case S_RANGE_B:
    FIg_get_state(me->optform, S_RANGE_B, &toggle);

    if(!me->dynamic) {
      if(toggle)
         FIg_set_state_off(me->optform, S_RANGE_B);
      else
         FIg_set_state_on(me->optform, S_RANGE_B);
    } else {
       me->range_mode = TRUE;
       me->shape_mode = FALSE;
       me->range = me->shape;
       FIg_set_state_on(me->optform, S_RANGE_B);
       FIg_set_state_off(me->optform, S_SHAPE_B);
    }
    break;

  case S_SHAPE_B:
    FIg_get_state(me->optform, S_SHAPE_B, &toggle);

    if(!me->dynamic) {
      if(toggle)
         FIg_set_state_off(me->optform, S_SHAPE_B);
      else
         FIg_set_state_on(me->optform, S_SHAPE_B);
    } else {
        me->shape_mode = TRUE;
        me->range_mode = FALSE;
        me->shape = me->range;
        FIg_set_state_on(me->optform, S_SHAPE_B);
        FIg_set_state_off(me->optform, S_RANGE_B);
    }
    break;

  case S_SYM_B:
    FIg_get_state(me->optform, S_SYM_B, &toggle);


    if(me->dynamic) {
       FIg_set_state_on(me->optform, S_SYM_B);
       if(me->shape_mode) 
         me->shape = SYMETRIC;
       if(me->range_mode) 
         me->range = SYMETRIC;
      me->symetric = TRUE;
    } else {
      if(toggle)
         FIg_set_state_off(me->optform, S_SYM_B);
      else
         FIg_set_state_on(me->optform, S_SYM_B);
    }
    break;

  case S_LEFT_B:
    FIg_get_state(me->optform, S_LEFT_B, &toggle);

    if(me->dynamic) {
       FIg_set_state_on(me->optform, S_LEFT_B);
       if(me->shape_mode) 
         me->shape = ANFANG;
       if(me->range_mode) 
         me->range = ANFANG;
      me->left = TRUE;
    } else {
      if(toggle)
         FIg_set_state_off(me->optform, S_LEFT_B);
      else
         FIg_set_state_on(me->optform, S_LEFT_B);
    }
    break;

  case S_RIGHT_B:
    FIg_get_state(me->optform, S_RIGHT_B, &toggle);
    if(me->dynamic) {
       FIg_set_state_on(me->optform, S_RIGHT_B);
       if(me->shape_mode) 
         me->shape = ENDE;
       if(me->range_mode) 
         me->range = ENDE;
      me->right = TRUE;
    } else {
      if(toggle)
         FIg_set_state_off(me->optform, S_RIGHT_B);
      else
         FIg_set_state_on(me->optform, S_RIGHT_B);
    }

    break;

  case S_PLUS_B:


    FIg_get_state(me->optform, S_PLUS_B, &toggle);
    if(toggle && !me->dynamic) {
      FIg_set_state_off(me->optform, S_PLUS_B);
      goto function_end;
    }
    if(me->range_mode) {
      if(me->range == SYMETRIC
      && me->n_anf < (me->p_s - me->bed_a)) {
         me->n_anf += 1;
         FIg_set_value(me->optform,S_LRANGE_F,(IGRdouble)me->n_anf);
      }
      if(me->range == SYMETRIC
      && me->n_end < (me->crv->num_poles - me->p_s - me->bed_e - me->m_p)) {
         me->n_end += 1;
         FIg_set_value(me->optform,S_RRANGE_F,(IGRdouble)me->n_end);
      }
      if(me->range == ANFANG 
      && me->n_anf < (me->p_s - me->bed_a)) {
         me->n_anf += 1;
         FIg_set_value(me->optform,S_LRANGE_F,(IGRdouble)me->n_anf);
      } else if(me->range == ENDE  
        && me->n_end < (me->crv->num_poles - me->p_s - me->bed_e - 
                                                               me->m_p)) {
         me->n_end += 1;
         FIg_set_value(me->optform,S_RRANGE_F,(IGRdouble)me->n_end);
      }
    } else if(me->shape_mode) {
             if(me->shape == SYMETRIC
             && me->shape_amount_left < SHAPE_MAX) {
               me->shape_amount_left += 1;
               FIg_set_value(me->optform,S_LSHAPE_F,(IGRdouble)
                              me->shape_amount_left);
	     }
             if(me->shape == SYMETRIC
             && me->shape_amount_right < SHAPE_MAX) {
               me->shape_amount_right += 1;
               FIg_set_value(me->optform,S_RSHAPE_F,(IGRdouble)
                              me->shape_amount_right);
	     }
             if(me->shape == ANFANG 
             && me->shape_amount_left < SHAPE_MAX) {
               me->shape_amount_left += 1;
               FIg_set_value(me->optform,S_LSHAPE_F,(IGRdouble)
                              me->shape_amount_left);
	     } else if(me->shape == ENDE  
                    && me->shape_amount_right < SHAPE_MAX) {
                       me->shape_amount_right += 1;
                       FIg_set_value(me->optform,S_RSHAPE_F,(IGRdouble)
                              me->shape_amount_right);
		    }
             }

    break;

  case S_MINUS_B:

    FIg_get_state(me->optform, S_MINUS_B, &toggle);
    if(toggle && !me->dynamic) {
      FIg_set_state_off(me->optform, S_MINUS_B);
      goto function_end;
    }
               if(me->shape_mode) {
                 if(me->shape == SYMETRIC
                 && me->shape_amount_left > SHAPE_MIN) {
                   me->shape_amount_left -= 1;
                   FIg_set_value(me->optform,S_LSHAPE_F,(IGRdouble)
                              me->shape_amount_left);
		 }
                 if(me->shape == SYMETRIC
                      &&me->shape_amount_right > SHAPE_MIN) {
                   me->shape_amount_right -= 1;
                   FIg_set_value(me->optform,S_RSHAPE_F,(IGRdouble)
                              me->shape_amount_right);
		 }
                 if(me->shape == ANFANG 
                      &&  me->shape_amount_left > SHAPE_MIN) {
                   me->shape_amount_left -= 1;
                   FIg_set_value(me->optform,S_LSHAPE_F,(IGRdouble)
                              me->shape_amount_left);
		 }
                 else if(me->shape == ENDE  
                      &&me->shape_amount_right > SHAPE_MIN) {
                   me->shape_amount_right -= 1;
                   FIg_set_value(me->optform,S_RSHAPE_F,(IGRdouble)
                              me->shape_amount_right);
		 }
               }
               else if(me->range_mode) {
                 if(me->range == SYMETRIC
                 && me->n_anf > 0) {
                   me->n_anf -= 1;
                   FIg_set_value(me->optform,S_LRANGE_F,(IGRdouble)
                              me->n_anf);
		 }
                 if(me->range == SYMETRIC 
                      && me->n_end > 0) {
                   me->n_end -= 1;
                   FIg_set_value(me->optform,S_RRANGE_F,(IGRdouble)
                              me->n_end);
		 }
                 if(me->range == ANFANG 
                      &&  me->n_anf > 0) {
                   me->n_anf -= 1;
                   FIg_set_value(me->optform,S_LRANGE_F,(IGRdouble)
                              me->n_anf);
		 }
                 else if(me->range == ENDE  
                      && me->n_end > 0) {
                   me->n_end -= 1;
                   FIg_set_value(me->optform,S_RRANGE_F,(IGRdouble)
                              me->n_end);
		 }
               }
    break;



  case S_PLANAR_B:
    FIg_get_state(me->optform, S_PLANAR_B, &toggle);
    if(!me->dynamic) {
      if(toggle) {
        if(me->crv_found) {
          stat_OM = om$send(msg = message ECascvmd.det_crv_plane(
                              &msg_loc),
                        targetid = my_id);
          TEST_ERROR(stat_OM,msg_loc,"ECascvmd.det_crv_plane",function_end);
          if(me->planar) {
            me->keep_planar = TRUE;
          }
        } else {
          FIg_set_state_off(me->optform, S_PLANAR_B);
        }
      } else {
          me->keep_planar = FALSE;
      }
    } else {
      if(toggle)           
         FIg_set_state_off(me->optform, S_PLANAR_B);
      else
         FIg_set_state_on(me->optform, S_PLANAR_B);
    }


    break;

  case S_SHVE_B:
    FIg_get_state(me->optform, S_SHVE_B, &toggle);

    if(!me->dynamic) {
      if(toggle)
         FIg_set_state_off(me->optform, S_SHVE_B);
      else
         FIg_set_state_on(me->optform, S_SHVE_B);
    } else {
      if(toggle) {
         FIg_set_state_off(me->optform, S_SHVE_B);
         ex$message(msgnumb = EMS_I_UsHK);
      } else {
         ex$message(msgnumb = EMS_I_UsHK);
         FIg_set_state_on(me->optform, S_SHVE_B);
      }
    }
    break;   


  case S_SHCU_B:
    FIg_get_state(me->optform, S_SHCU_B, &toggle);
    if(!me->dynamic) {
      if(toggle)
         FIg_set_state_off(me->optform, S_SHCU_B);
      else
         FIg_set_state_on(me->optform, S_SHCU_B);
    } else {
      if(toggle) {
         FIg_set_state_off(me->optform, S_SHCU_B);
         ex$message(msgnumb = EMS_I_UsHK);
      } else {
         ex$message(msgnumb = EMS_I_UsHK);
         FIg_set_state_on(me->optform, S_SHCU_B);
      }
    }


    break;   

  case S_SHPO_B:
    FIg_get_state(me->optform, S_SHPO_B, &toggle);
    if(!me->dynamic) {
      if(toggle)
         FIg_set_state_off(me->optform, S_SHPO_B);
      else
         FIg_set_state_on(me->optform, S_SHPO_B);
    } else {
      if(toggle) {
         FIg_set_state_off(me->optform, S_SHPO_B);
         ex$message(msgnumb = EMS_I_UsHK);
      } else {
         ex$message(msgnumb = EMS_I_UsHK);
         FIg_set_state_on(me->optform, S_SHPO_B);
      }
    }

    break;   

  case S_SHDI_B:
    FIg_get_state(me->optform, S_SHDI_B, &toggle);
    if(!me->dynamic) {
      if(toggle)
         FIg_set_state_off(me->optform, S_SHDI_B);
      else
         FIg_set_state_on(me->optform, S_SHDI_B);
    } else {
      if(toggle) {
         FIg_set_state_off(me->optform, S_SHDI_B);
         ex$message(msgnumb = EMS_I_UsHK);
      } else {
         ex$message(msgnumb = EMS_I_UsHK);
         FIg_set_state_on(me->optform, S_SHDI_B);
      }
    }
     
    break;


  case S_IDLS_B:

    if(me->ls_found) {        
       FIg_set_state_off(me->optform, S_IDLS_B);
       ex$message(msgnumb = EMS_I_LsAI);
    }
    if(toggle && !me->ls_found) {
     me->idls_req = TRUE;
     ex$message(msgnumb = EMS_P_SeLs);
    }
     
    break; 

  case S_FROMTO_B:  
    FIg_get_state(me->optform, S_FROMTO_B, &toggle);
    if(!me->dynamic) {
      if(toggle) {
        me->fromto = FALSE;
        me->command = ME.super_cmd->state = GET_TO_POINT;
      } else {
       me->fromto = TRUE;
       me->command = ME.super_cmd->state = GET_FROM_POINT;
      }
    } else {
       if(toggle) 
          FIg_set_state_off(me->optform, S_FROMTO_B);
       else
          FIg_set_state_on(me->optform, S_FROMTO_B);
    }

    break;

  case S_CURSOR_S:

    FIg_get_state(me->optform, S_CURSOR_S, &toggle);
    if(!me->dynamic) {
       if(toggle) 
          FIg_set_state_off(me->optform, S_CURSOR_S);
       else
          FIg_set_state_on(me->optform, S_CURSOR_S);
    } else {
       if(toggle) {
          me->cursor_sensitivity = 1;
          me->cms = CURSOR_SENS1;
       } else {
          me->cursor_sensitivity = 0;
          me->cms = CURSOR_SENS0;
       }
    }
    break; 

  case S_SMOOTH_B:

    FIg_get_state(me->optform, S_SMOOTH_B, &toggle);
    if(toggle && !me->dynamic) {
      FIg_set_state_off(me->optform, S_SMOOTH_B);
      goto function_end;
    }
    if(!toggle) {
       me->smooth = FALSE;
    } else {
       me->smooth = TRUE;
    }
    break;

  case S_LESS_B:
    FIg_get_state(me->optform, S_LESS_B, &toggle);
    if(toggle && !me->dynamic) {
      FIg_set_state_off(me->optform, S_LESS_B);
      goto function_end;
    }
    if(me->smooth) {
      if(me->smfac > 0)
        me->smfac -= 0.01;
      FIg_set_value(me->optform,S_SMFAC_F,(IGRdouble)
                              me->smfac);
    }
    break;
                
  case S_GREAT_B:
    FIg_get_state(me->optform, S_GREAT_B, &toggle);
    if(toggle && !me->dynamic) {
      FIg_set_state_off(me->optform, S_GREAT_B);
      goto function_end;
    }
    if(me->smooth) {
      me->smfac += 0.01;
      FIg_set_value(me->optform,S_SMFAC_F,(IGRdouble)
                              me->smfac);
    }
    break;
                


  case S_STARTPT_B:

    FIg_set_state_on(me->optform, S_STARTPT_B);
    FIg_set_state_off(me->optform, S_ENDPT_B);
    me->set_stpt = TRUE;
    me->set_ept = FALSE;

    break;

  case S_ENDPT_B:

    FIg_set_state_on(me->optform, S_ENDPT_B);
    FIg_set_state_off(me->optform, S_STARTPT_B);
    me->set_ept = TRUE;
    me->set_stpt = FALSE;

    break;

  case S_SFREE_B:

      if(me->set_stpt)
         FIg_set_state_off(me->optform, S_STARTPT_B);
      me->stfree = TRUE;
      me->stfix = FALSE;
      me->stta = FALSE;
      me->stcrv = FALSE;
      me->bed_a = 0;
  
    break;

  case S_SFIX_B:
      if(me->set_stpt)
         FIg_set_state_off(me->optform, S_STARTPT_B);
      me->stfix = TRUE;
      me->stfree = FALSE;
      me->stta = FALSE;
      me->stcrv = FALSE;
      me->bed_a = 1;

    break;

  case S_STA_B:
      if(me->set_stpt)
         FIg_set_state_off(me->optform, S_STARTPT_B);
      me->stta = TRUE;
      me->stfree = FALSE;
      me->stfix = FALSE;
      me->stcrv = FALSE;
      me->bed_a = 2;

    break;

  case S_SCURV_B:
      if(me->set_stpt)
         FIg_set_state_off(me->optform, S_STARTPT_B);
      me->stcrv = TRUE;
      me->stfree = FALSE;
      me->stfix = FALSE;
      me->stta = FALSE;
      me->bed_a = 3;

    break;


  case S_EFREE_B:
      if(me->set_ept)
         FIg_set_state_off(me->optform, S_ENDPT_B);
      me->efree = TRUE;
      me->efix = FALSE;
      me->eta = FALSE;
      me->ecrv = FALSE;
      me->bed_e = 0;
  
    break;

  case S_EFIX_B:
      if(me->set_ept)
         FIg_set_state_off(me->optform, S_ENDPT_B);
      me->efix = TRUE;
      me->efree = FALSE;
      me->eta = FALSE;
      me->ecrv = FALSE;
      me->bed_e = 1;

    break;

  case S_ETA_B:
      if(me->set_ept)
         FIg_set_state_off(me->optform, S_ENDPT_B);
      me->eta = TRUE;
      me->efree = FALSE;
      me->efix = FALSE;
      me->ecrv = FALSE;
      me->bed_e = 2;


    break;

  case S_ECURV_B:
      if(me->set_ept)
         FIg_set_state_off(me->optform, S_ENDPT_B);
      me->ecrv = TRUE;
      me->efree = FALSE;
      me->efix = FALSE;
      me->eta = FALSE;
      me->bed_e = 3;

    break;



  }

 }

function_end:

  return(stat_OM);


}
  

method execute (IGRint *response; IGRchar *response_data; IGRint pos)
{
  /***execute***/
  IGRboolean            stat_func;

 
  IGRint 		display_flag=0;
  IGRint                action=0;

  IGRint                response2;

  IGRchar		ksl;
  IGRchar 		errmsg[EMMAXERRMSG_LEN]; 

  IGRchar 		loc_prompt[54], 
                        acc_prompt[54], 
                        reloc_prompt[54];

  IGRlong 		event_size=0;
  IGRlong 		stat_OM, msg_loc;
  IGRlong 		loc_mask, acc_mask;

  IGRdouble             *par_vec = NULL, 
                        *cv_pts = NULL, 
                        *dists = NULL;


  struct GRlc_locate 	lc_attr;

  struct IGRpolyline polyline;
  struct GRevent        accev;
  IGRdouble             *polypts = NULL;

  enum GRdpmode 	dpmode;
  OM_S_CLASSLIST 	rtree_classes, eligible_classes;
  OMuword 		r_classes[5], 
                        e_classes[5];

  extern IGRdouble 	BSdotp();
  extern IGRdouble 	BSdistptpt();
  extern void 		BScveval();
  extern IGRboolean 	BSnorvec();
  extern IGRboolean 	BScrossp();
  extern IGRboolean     BSfreecv(),
                        BSplane3pt(), 
			BSprj_cv_pl();

  extern void		BSallocv();
  extern IGRint 	EMgetvggeom(IGRlong *, IGRshort *,IGRmatrix,
                                    struct GRid *,IGRchar **, IGRint *);

  IGRint                count=0;
  struct GRid           *list=NULL;

#if dflT1
  printf("in execute\n");
#endif

  ex$message(msgnumb = EMS_P_ClearPromptField);
 
  /**response = TERMINATE;*/
  stat_OM = OM_S_SUCCESS;
  event_size = sizeof (struct GRevent);
  strcpy (errmsg, "MCplasofcv.execute");
  me->response = response;
  me->response_data = response_data;

  do {


    switch (ME.super_cmd->state) {

      case GET_CURVE:

#if dflT1
  printf("in execute state GET CURVE\n");
#endif

        if (ME.ECelement->elem_hilit) {
          stat_OM = dp$erase_hilite(msg = &msg_loc);

          ME.ECelement->elem_hilit = FALSE;
        }

        ex$message(msgnumb = EMS_M_PcCv, buff = loc_prompt);

        accev.event.keyin[0] = '\0';
        LCdef_cursor();
        stat_func = co$getevent(
                  msg = &msg_loc,
                  mode = EX_ALL_CHAR_MODE | EX_LINE_MODE,
                  event_mask = (GRm_DATA | 
                                /* GRm_CHAR | */
                                GRm_STRING |
                                GRm_RJT_MOVEON | 
                                GRm_BACK_UP),
                  prompt = loc_prompt,
                  response = response,
                  response_data = response_data,
                  event = &accev);
        LCrestore_cursor();

        switch (*response) {

          case EX_RJT_MOVEON:
            *response = TERMINATE;
            goto command_end;


          case EX_DATA:
        
#if dflT1
 printf("in get curve co$getevent  case EX DATA\n");
#endif

            /*event_size = sizeof(struct EX_button);*/
            /*stat_func = ex$clear_event_queue ( );*/
              event_size = sizeof(struct GRevent);
     
              stat_func = ex$putque(
                            msg = &msg_loc,
                            pos = FRONT,
                            response = response,
                            byte = &event_size,
                            buffer = (char *) &accev.event);
	    
                            /*buffer = (char *) &me->accev.event.button);*/
            break;

          case EX_CHAR:
            ME.super_cmd->state = me->command = GET_CURVE;
            /*ksl = accev.event.keyin[0];*/
            ksl = response_data[0];
            if(ksl == ESC) {
              accev.event.keyin[0] = '\033';
              accev.event.keyin[1] = '\0';
              GRput_keybuff(accev.event.keyin);
              ex$message(field=KEYIN_FIELD,msgnumb=EMS_I_escape);

              goto Locate1;
            }

            accev.event.keyin[1] = '\013';
            GRput_keybuff(accev.event.keyin);
           
            switch(ksl) {

            case PRODIST:
                if(me->optform_requested) 
                  FIg_set_state_on(me->optform, S_PRODIST_B); 
                stat_func = get_projection_dist(
                             &msg_loc, &me->common_dist, &me->prodist);
                if(me->optform_requested) {
                 FIg_set_value(me->optform, S_PRODIST_F, me->prodist); 
                 FIg_set_state_off(me->optform, S_PRODIST_B); 
	        }

                break;

            case OPTIONS:
              if(me->optform_requested) {
                me->optform_requested = FALSE;
                FIf_get_location(me->optform,&me->fxpos, &me->fypos);
                stat_func = FIf_erase(me->optform);
              } else {
                stat_OM = om$send(msg = message ECascvmd.status_disp(),
                                  targetid = my_id);
              }
              goto command_end;

            case PLANAR:
              if(!me->keep_planar) {
                if(!me->crv_found) {
                  ex$message(msgnumb = EMS_I_NoCvIdfd);
                } else {
                  stat_OM = om$send(msg = message ECascvmd.det_crv_plane(
                                        &msg_loc),
                                 targetid = my_id);
                  TEST_ERROR(stat_OM,msg_loc,"ECascvmd.det_crv_plane",command_end);
                  if(me->planar) {
                    me->keep_planar = TRUE;
                    if(me->optform_requested)
                       FIg_set_state_on(me->optform, S_PLANAR_B);
                  } else {
                    ex$message(msgnumb = EMS_I_CvNPl);
                  }
                  ME.super_cmd->state = me->command = GET_CURVE;
                }
	      } else {
                  me->keep_planar = FALSE;
                  if(me->optform_requested)
                     FIg_set_state_off(me->optform, S_PLANAR_B);
                  ME.super_cmd->state = me->command = GET_CURVE;
	      }
              goto command_end;
                            

            case FROMTO:
                me->fromto = TRUE;
                if(me->optform_requested)
                  FIg_set_state(me->optform, S_FROMTO_B,FALSE);
                ME.super_cmd->state = me->command = GET_CURVE;
                goto command_end;

	    case PROJECT:
                me->fromto = FALSE;
                if(me->optform_requested)
                   FIg_set_state(me->optform, S_FROMTO_B,TRUE);
                ME.super_cmd->state = me->command = GET_CURVE;
                goto command_end;
            
                

            case STPT:
                if(me->optform_requested) {
                   FIg_set_state_on(me->optform, S_STARTPT_B);
                   FIg_set_state_off(me->optform, S_ENDPT_B);
		}
                me->set_stpt = TRUE;
                me->set_ept = FALSE;

                goto command_end;

            case EPT:
                if(me->optform_requested) {
                  FIg_set_state_on(me->optform, S_ENDPT_B);
                  FIg_set_state_off(me->optform, S_STARTPT_B);
                }
                me->set_ept = TRUE;
                me->set_stpt = FALSE;

              goto command_end;

            case FIX:
              if(me->set_stpt) {
                if(me->optform_requested) {
                   FIg_set_state_on(me->optform, S_SFIX_B);
                   FIg_set_state_off(me->optform, S_STARTPT_B);
		}
                me->stfix = TRUE;
                me->stfree = FALSE;
                me->stta = FALSE;
                me->stcrv = FALSE;
                me->bed_a = 1;
              } else if(me->set_ept) {
                if(me->optform_requested) {
                   FIg_set_state_on(me->optform, S_EFIX_B);
                   FIg_set_state_off(me->optform, S_ENDPT_B);
		}
                me->efix = TRUE;
                me->efree = FALSE;
                me->ecrv = FALSE;
                me->eta = FALSE;
                me->bed_e = 1;
              }
              goto command_end;

            case FREE:
              if(me->set_stpt) {
                if(me->optform_requested) {
                   FIg_set_state_on(me->optform, S_SFREE_B);
                   FIg_set_state_off(me->optform, S_STARTPT_B);
		}
                me->stfree = TRUE;
                me->stfix = FALSE;
                me->stta = FALSE;
                me->stcrv = FALSE;
                me->bed_a = 0;
              } else if(me->set_ept) {
                if(me->optform_requested) {
                   FIg_set_state_on(me->optform, S_EFIX_B);
                   FIg_set_state_off(me->optform, S_ENDPT_B);
		}
                me->efree = TRUE;
                me->efix = FALSE;
                me->ecrv = FALSE;
                me->eta = FALSE;
                me->bed_e = 0;
              }
              goto command_end;

            case TANGENT:
              if(me->set_stpt) {
                if(me->optform_requested)  {
                   FIg_set_state_on(me->optform, S_STA_B);
                   FIg_set_state_off(me->optform, S_STARTPT_B);
		}
                me->stta = TRUE;
                me->stfree = FALSE;
                me->stfix = FALSE;
                me->stcrv = FALSE;
                me->bed_a = 2;
              } else if(me->set_ept) {
                if(me->optform_requested) {
                   FIg_set_state_on(me->optform, S_ETA_B);
                   FIg_set_state_off(me->optform, S_ENDPT_B);
	        }
                me->eta = TRUE;
                me->efree = FALSE;
                me->efix = FALSE;
                me->ecrv = FALSE;
                me->bed_e = 2;
              }
              goto command_end;

            case CURVA:
              if(me->set_stpt) {
                if(me->optform_requested) {
                   FIg_set_state_on(me->optform, S_SCURV_B);
                   FIg_set_state_off(me->optform, S_STARTPT_B);
		}
                me->stcrv = TRUE;
                me->stfree = FALSE;
                me->stfix = FALSE;
                me->stta = FALSE;
                me->bed_a = 3;
              } else if(me->set_ept) {
                if(me->optform_requested) {
                   FIg_set_state_on(me->optform, S_ECURV_B);
                   FIg_set_state_off(me->optform, S_ENDPT_B);
		}
                me->ecrv = TRUE;
                me->efree = FALSE;
                me->efix = FALSE;
                me->eta = FALSE;
                me->bed_e = 3;
              }
              goto command_end; 


            case FINIS:
              *response = TERMINATE;
              goto command_end;

	     case IDLS:
               if(me->ls_found) {
                 ex$message(msgnumb = EMS_I_LsAI);
                 if(me->optform_requested)
                    FIg_set_state_off(me->optform, S_IDLS_B);
                 goto command_end;
               } else {
                  ex$message(msgnumb = EMS_M_SeLs, buff = loc_prompt);
                  ex$message(msgnumb = EMS_P_SeLs);
                  ME.super_cmd->state = GET_LINESTRING;
                  if(me->optform_requested)
                     FIg_set_state_on(me->optform, S_IDLS_B);
                  me->old_command = GET_CURVE;
                  goto command_end;               
	       }
	    }


          default:
            goto command_end;

	}
 Locate1:


        loc_mask = GRm_DATA |
                   GRm_RJT_MOVEON | 
                   GRm_BACK_UP;
        acc_mask = GRm_DATA;



        ex$message(msgnumb = EMS_P_00038, buff = acc_prompt);
        ex$message(msgnumb = EMS_I_00010, buff = reloc_prompt);
    
        /*ex$message (msgnumb = EMS_M_PcCv);*/
        lc_attr.properties = LC_LC_ONLY | 
                             LC_DP_ONLY | 
                             LC_RW | 
                             IGN_MOD_BIT;

        lc_attr.owner_action = LC_RIGID_COMP | 
                               LC_RIGID_OWNER |
                               LC_FLEX_COMP | 
                               LC_REF_OBJECTS | 
                               LC_NO_REF_HEADER;

        display_flag = ALL_WINDOWS | 
                       ELEM_HILIGHT | 
                       /*LC_ACC_ONE_ELEMENT |*/
                       PROJ_ACCEPT_POINT;


        ex$message(msgnumb = EMS_M_PcCv, buff = loc_prompt);
        rtree_classes.w_count = 1;
        eligible_classes.w_count = 1;
        rtree_classes.w_flags = eligible_classes.w_flags 
                              = OM_CLST_subclass;

/* bug fix ,report from vdo, no 2.7.3, 8/10/97 */
/* do not allow to pick conics */
        r_classes[0] = OPP_GRbcsubbc_class_id;
/*    	e_classes[0] = OPP_GRcurve_class_id; */
    	e_classes[0] = OPP_GRbcsubbc_class_id;

    	rtree_classes.p_classes = &r_classes[0];
    	eligible_classes.p_classes = &e_classes[0];

    	stat_func = lc$locate(
              	rc = &msg_loc,
              	event1 = &ME.ECelement->locev, 
              	event2 = &me->accev,
              	mask1 = loc_mask, 
              	mask2 = acc_mask,
              	eventsize= (int *)&event_size, 
              	display_flag = display_flag,
              	response = response,
              	response_data = response_data, 
              	locate_prompt = loc_prompt, 
              	acc_prompt = acc_prompt,
              	relocate_key = EMS_I_00010, 
              	attributes = &lc_attr, 
              	stack = &ME.ECelement->locate_stack, 
              	rtree_classes = &rtree_classes, 
              	eligible_classes = &eligible_classes);
        
            if(!me->error_flag && ME.ECelement->locate_stack.window.objid != 0) {
              me->error_flag = TRUE;
              me->window_objid = ME.ECelement->locate_stack.window.objid;
            }


        me->XXXXX = 144;
        switch (me->accev.response) {

          case EX_DATA:
#if dflT1
 printf("in get curve locate case EX DATA\n");
#endif
            /* bug fix ,report from vdo, no 2.6.1, 8/10/97 */
            /* do not allow associative dependent curves */
            /* test, if this curve has a parent */   
            count = 0;  
            stat_OM = om$send(msg = message NDnode.NDget_objects
                                    (ND_ROOT | ND_IN_BUF,
				     NULL,0,&list,0,OM_K_MAXINT,&count),
		     targetid = me->accev.located_object[0].located_obj.objid,
		     targetos = me->accev.located_object[0].located_obj.osnum);
            if(count > 0) { 
               ex$message (msgnumb = EMS_E_AsscEleNtCurntSupptd);
               stat_OM = INFO;
               goto command_end;
            }

            
            me->error_flag = FALSE;
            ME.ECelement->locate_stack.window.objid = me->window_objid;            
            ME.ECascvmd->cv_info = me->accev.located_object[0];
            ME.ECelement->elem_hilit = TRUE;
            ME.ECelement->elem.located_obj.objid = me->accev.located_object[0].
                                         located_obj.objid;
            ME.ECelement->elem.located_obj.osnum = me->accev.located_object[0].
                                         located_obj.osnum;

            me->u_par = me->accev.located_object[0].geom_parms.u;

            me->pnt_lot[X] = me->accev.located_object[0].proj_pnt[X];
            me->pnt_lot[Y] = me->accev.located_object[0].proj_pnt[Y];
            me->pnt_lot[Z] = me->accev.located_object[0].proj_pnt[Z];

            me->cvname = (IGRint) ME.ECelement->elem.located_obj.objid;

            stat_OM = om$send (msg = message ECascvmd.get_bsp_info(
                                      &msg_loc),
                               targetid = my_id);
            TEST_ERROR(stat_OM,msg_loc,"MClsedit.get_bsp_info",command_end);


            if(!me->fromto)
               me->command = ME.super_cmd->state = GET_TO_POINT;
            else
               me->command = ME.super_cmd->state = GET_FROM_POINT;

            me->crv_found = TRUE;
            goto command_end;

          case EX_RJT_MOVEON:
            *response = TERMINATE;
            if(me->mark_point_id.objid) {
               gr$delete_object(msg = &msg_loc,
                  md_env = NULL,
                  object_id = &me->mark_point_id);
            }
            goto command_end;

          default:
#if dflT1
 printf("in get curve locate default\n");
#endif
            goto command_end;
          }
        


      case GET_LINESTRING:

#if dflT1
  printf("in execute state GET_LINESTRING\n");
#endif

        if (ME.ECelement->elem_hilit) {
          stat_OM = dp$erase_hilite(msg = &msg_loc);

          ME.ECelement->elem_hilit = FALSE;
        }
        loc_mask = GRm_DATA | 
                   GRm_BACK_UP;
        acc_mask = GRm_DATA;



        ex$message(msgnumb = EMS_P_00038, buff = acc_prompt);
        ex$message(msgnumb = EMS_I_00010, buff = reloc_prompt);
    
        ex$message (msgnumb = EM_M_AsCvMd);
        lc_attr.properties = LC_LC_ONLY | 
                             LC_DP_ONLY | 
                             LC_RW | 
                             IGN_MOD_BIT;

        lc_attr.owner_action = LC_RIGID_COMP | 
                               LC_RIGID_OWNER |
                               LC_FLEX_COMP | 
                               LC_REF_OBJECTS | 
                               LC_NO_REF_HEADER;

        display_flag = ALL_WINDOWS | 
                       ELEM_HILIGHT | 
                       /*LC_ACC_ONE_ELEMENT |*/
                       PROJ_ACCEPT_POINT;


        rtree_classes.w_count = 1;
        eligible_classes.w_count = 1;
        rtree_classes.w_flags = eligible_classes.w_flags 
                              = OM_CLST_subclass;
        r_classes[0] = OPP_GRbspline_class_id;
    	e_classes[0] = OPP_GR3dlinestr_class_id;

    	rtree_classes.p_classes = &r_classes[0];
    	eligible_classes.p_classes = &e_classes[0];

        ex$message(msgnumb = EMS_M_SeLs, buff = loc_prompt);

    	stat_func = lc$locate(
              	rc = &msg_loc,
              	event1 = &ME.ECelement->locev, 
              	event2 = &me->accev,
              	mask1 = loc_mask, 
              	mask2 = acc_mask,
              	eventsize= (int *)&event_size, 
              	display_flag = display_flag,
              	response = response,
              	response_data = response_data, 
              	locate_prompt = loc_prompt, 
              	acc_prompt = acc_prompt,
              	relocate_key = EMS_I_00010, 
              	attributes = &lc_attr, 
              	stack = &ME.ECelement->locate_stack, 
              	rtree_classes = &rtree_classes, 
              	eligible_classes = &eligible_classes);

        switch (me->accev.response) {

          case EX_DATA:
            ME.ECascvmd->ls_info = me->accev.located_object[0];
            me->ls_found = TRUE;
            ME.ECelement->elem_hilit = TRUE;
            ME.ECelement->elem.located_obj.objid = me->accev.located_object[0].
                                         located_obj.objid;
            ME.ECelement->elem.located_obj.osnum = me->accev.located_object[0].
                                         located_obj.osnum;

            ME.super_cmd->state = me->command = me->old_command;

            if(me->optform_requested) {
               FIg_set_state_off(me->optform, S_IDLS_B);
               FIg_set_state_on(me->optform, S_LSIDFID_CI);
	    }
            goto command_end;


          default:
            /* *response = TERMINATE;
            if(me->mark_point_id.objid) {
               gr$delete_object(msg = &msg_loc,
                  md_env = NULL,
                  object_id = &me->mark_point_id);
            } */
            ME.super_cmd->state = me->command = me->old_command;
            if(me->optform_requested) 
               FIg_set_state_off(me->optform, S_IDLS_B);
            goto command_end;

          }
        



      case GET_FROM_POINT:
#if dflT1
  printf("in execute state GET_FROM_POINT\n");
#endif

        if (ME.ECelement->elem_hilit) {
          stat_OM = dp$erase_hilite(msg = &msg_loc);

          ME.ECelement->elem_hilit = FALSE;
        }


        ex$message(msgnumb = EMS_M_SeFp, buff = loc_prompt);
        me->accev.event.keyin[0] = '\0';
           LCdef_cursor();
           stat_func = co$getevent(
                  msg = &msg_loc,
                  mode = EX_ALL_CHAR_MODE | EX_LINE_MODE,
                  event_mask = (GRm_DATA | 
                                /*GRm_CHAR | */
                                GRm_STRING |
                                GRm_RJT_MOVEON | 
                                GRm_BACK_UP),
                  prompt = loc_prompt,
                  response = response,
                  response_data = response_data,
                  event = &me->accev);
           LCrestore_cursor();

        switch (*response) {

          case EX_RJT_MOVEON:
            *response = TERMINATE;
            if(me->mark_point_id.objid) {
               gr$delete_object(msg = &msg_loc,
                  md_env = NULL,
                  object_id = &me->mark_point_id);
            }
            goto command_end;


          case EX_DATA:
        

            event_size = sizeof(struct EX_button);
            stat_func = ex$putque(
                            msg = &msg_loc,
                            pos = FRONT,
                            response = response,
                            byte = &event_size,
                            buffer = (char *) &me->accev.event.button);
            break;

          case EX_CHAR:
            ME.super_cmd->state = me->command = GET_FROM_POINT;
            ksl = response_data[0];
            me->accev.event.keyin[0] = '\0';
            me->accev.event.keyin[1] = '\013';
            GRput_keybuff(me->accev.event.keyin);

            if(ksl == ESC) {
              me->accev.event.keyin[0] = '\033';
              me->accev.event.keyin[1] = '\0';
              GRput_keybuff(me->accev.event.keyin);
              ex$message(field=KEYIN_FIELD,msgnumb=EMS_I_escape);

              goto Locate2;
            }


            switch(ksl) {


            case PRODIST:
                if(me->optform_requested) 
                  FIg_set_state_on(me->optform, S_PRODIST_B); 
                stat_func = get_projection_dist(
                             &msg_loc, &me->common_dist, &me->prodist);
                if(me->optform_requested) {
                 FIg_set_value(me->optform, S_PRODIST_F, me->prodist); 
                 FIg_set_state_off(me->optform, S_PRODIST_B); 
	        }

                break;

            case OPTIONS:
              if(me->optform_requested) {
                me->optform_requested = FALSE;
                FIf_get_location(me->optform,&me->fxpos, &me->fypos);
                stat_func = FIf_erase(me->optform);
              } else {
                stat_OM = om$send(msg = message ECascvmd.status_disp(),
                                  targetid = my_id);
              }
              goto command_end;

            case PLANAR:
              if(!me->keep_planar) {
                if(!me->crv_found) {
                  ex$message(msgnumb = EMS_I_NoCvIdfd);
                } else {
                  stat_OM = om$send(msg = message ECascvmd.det_crv_plane(
                                        &msg_loc),
                                 targetid = my_id);
                  TEST_ERROR(stat_OM,msg_loc,"ECascvmd.det_crv_plane",command_end);
                  if(me->planar) {
                    me->keep_planar = TRUE;
                    if(me->optform_requested)
                       FIg_set_state_on(me->optform, S_PLANAR_B);
                  } else {
                    ex$message(msgnumb = EMS_I_CvNPl);
                  }
                  ME.super_cmd->state = me->command = GET_FROM_POINT;
                }
	      } else {
                  me->keep_planar = FALSE;
                  if(me->optform_requested)
                     FIg_set_state_off(me->optform, S_PLANAR_B);
                  ME.super_cmd->state = me->command = GET_FROM_POINT;
	      }
              goto command_end;
                            

            case FROMTO:
                me->fromto = TRUE;
                if(me->optform_requested)
                  FIg_set_state(me->optform, S_FROMTO_B,FALSE);
                ME.super_cmd->state = me->command = GET_FROM_POINT;
                goto command_end;

	    case PROJECT:
                me->fromto = FALSE;
                if(me->optform_requested)
                   FIg_set_state(me->optform, S_FROMTO_B,TRUE);
                ME.super_cmd->state = me->command = GET_TO_POINT;
                goto command_end;
            
                

            case STPT:
                if(me->optform_requested) {
                   FIg_set_state_on(me->optform, S_STARTPT_B);
                   FIg_set_state_off(me->optform, S_ENDPT_B);
		}
                me->set_stpt = TRUE;
                me->set_ept = FALSE;

                goto command_end;

            case EPT:
                if(me->optform_requested) {
                  FIg_set_state_on(me->optform, S_ENDPT_B);
                  FIg_set_state_off(me->optform, S_STARTPT_B);
                }
                me->set_ept = TRUE;
                me->set_stpt = FALSE;

              goto command_end;

            case FIX:
              if(me->set_stpt) {
                if(me->optform_requested) {
                   FIg_set_state_on(me->optform, S_SFIX_B);
                   FIg_set_state_off(me->optform, S_STARTPT_B);
		}
                me->stfix = TRUE;
                me->stfree = FALSE;
                me->stta = FALSE;
                me->stcrv = FALSE;
                me->bed_a = 1;
              } else if(me->set_ept) {
                if(me->optform_requested) {
                   FIg_set_state_on(me->optform, S_EFIX_B);
                   FIg_set_state_off(me->optform, S_ENDPT_B);
		}
                me->efix = TRUE;
                me->efree = FALSE;
                me->ecrv = FALSE;
                me->eta = FALSE;
                me->bed_e = 1;
              }
              goto command_end;

            case FREE:
              if(me->set_stpt) {
                if(me->optform_requested) {
                   FIg_set_state_on(me->optform, S_SFREE_B);
                   FIg_set_state_off(me->optform, S_STARTPT_B);
		}
                me->stfree = TRUE;
                me->stfix = FALSE;
                me->stta = FALSE;
                me->stcrv = FALSE;
                me->bed_a = 0;
              } else if(me->set_ept) {
                if(me->optform_requested) {
                   FIg_set_state_on(me->optform, S_EFIX_B);
                   FIg_set_state_off(me->optform, S_ENDPT_B);
		}
                me->efree = TRUE;
                me->efix = FALSE;
                me->ecrv = FALSE;
                me->eta = FALSE;
                me->bed_e = 0;
              }
              goto command_end;

            case TANGENT:
              if(me->set_stpt) {
                if(me->optform_requested)  {
                   FIg_set_state_on(me->optform, S_STA_B);
                   FIg_set_state_off(me->optform, S_STARTPT_B);
		}
                me->stta = TRUE;
                me->stfree = FALSE;
                me->stfix = FALSE;
                me->stcrv = FALSE;
                me->bed_a = 2;
              } else if(me->set_ept) {
                if(me->optform_requested) {
                   FIg_set_state_on(me->optform, S_ETA_B);
                   FIg_set_state_off(me->optform, S_ENDPT_B);
	        }
                me->eta = TRUE;
                me->efree = FALSE;
                me->efix = FALSE;
                me->ecrv = FALSE;
                me->bed_e = 2;
              }
              goto command_end;

            case CURVA:
              if(me->set_stpt) {
                if(me->optform_requested) {
                   FIg_set_state_on(me->optform, S_SCURV_B);
                   FIg_set_state_off(me->optform, S_STARTPT_B);
		}
                me->stcrv = TRUE;
                me->stfree = FALSE;
                me->stfix = FALSE;
                me->stta = FALSE;
                me->bed_a = 3;
              } else if(me->set_ept) {
                if(me->optform_requested) {
                   FIg_set_state_on(me->optform, S_ECURV_B);
                   FIg_set_state_off(me->optform, S_ENDPT_B);
		}
                me->ecrv = TRUE;
                me->efree = FALSE;
                me->efix = FALSE;
                me->eta = FALSE;
                me->bed_e = 3;
              }
              goto command_end; 



            case FINIS:
              *response = TERMINATE;
            if(me->mark_point_id.objid) {
               gr$delete_object(msg = &msg_loc,
                  md_env = NULL,
                  object_id = &me->mark_point_id);
            }
              goto command_end;

	     case IDLS:
               if(me->ls_found) {
                 ex$message(msgnumb = EMS_I_LsAI);
                 if(me->optform_requested)
                    FIg_set_state_off(me->optform, S_IDLS_B);
                 goto command_end;
               } else {
                  ex$message(msgnumb = EMS_M_SeLs, buff = loc_prompt);
                  ex$message(msgnumb = EMS_P_SeLs);
                  ME.super_cmd->state = GET_LINESTRING;
                  if(me->optform_requested)
                     FIg_set_state_on(me->optform, S_IDLS_B);
                  me->old_command = GET_TO_POINT;
                  goto command_end;               
	       }
	    }


          default:
            goto command_end;

	}
 Locate2:
        loc_mask = GRm_DATA |
                   GRm_RJT_MOVEON | 
                   GRm_BACK_UP;
        acc_mask = GRm_DATA;



        ex$message(msgnumb = EMS_P_00038, buff = acc_prompt);
        ex$message(msgnumb = EMS_I_00010, buff = reloc_prompt);
    
        ex$message (msgnumb = EMS_M_SeFp);
        lc_attr.properties = LC_LC_ONLY | 
                             LC_DP_ONLY | 
                             LC_RW | 
                             IGN_MOD_BIT;

        lc_attr.owner_action = LC_RIGID_COMP | 
                               LC_RIGID_OWNER |
                               LC_FLEX_COMP | 
                               LC_REF_OBJECTS | 
                               LC_NO_REF_HEADER;

        display_flag = ALL_WINDOWS | 
                       ELEM_HILIGHT | 
                       /*LC_ACC_ONE_ELEMENT |*/
                       PROJ_ACCEPT_POINT;



        ex$message(msgnumb = EMS_M_SeFp, buff = loc_prompt);
        rtree_classes.w_count = 1;
        eligible_classes.w_count = 1;
        rtree_classes.w_flags = eligible_classes.w_flags 
                              = OM_CLST_subclass;

        r_classes[0] = OPP_GRbspline_class_id;
    	e_classes[0] = OPP_GRcurve_class_id;

    	rtree_classes.p_classes = &r_classes[0];
    	eligible_classes.p_classes = &e_classes[0];

    	stat_func = lc$locate(
              	rc = &msg_loc,
              	event1 = &ME.ECelement->locev, 
              	event2 = &me->accev,
              	mask1 = loc_mask, 
              	mask2 = acc_mask,
              	eventsize= (int *)&event_size, 
              	display_flag = display_flag,
              	response = response,
              	response_data = response_data, 
              	locate_prompt = loc_prompt, 
              	acc_prompt = acc_prompt,
              	relocate_key = EMS_I_00010, 
              	attributes = &lc_attr, 
              	stack = &ME.ECelement->locate_stack, 
              	rtree_classes = &rtree_classes, 
              	eligible_classes = &eligible_classes);
        

        switch (me->accev.response) {

          case EX_DATA:
            me->u_par = me->accev.located_object[0].geom_parms.u;

            me->pnt_lot[X] = me->accev.located_object[0].proj_pnt[X];
            me->pnt_lot[Y] = me->accev.located_object[0].proj_pnt[Y];
            me->pnt_lot[Z] = me->accev.located_object[0].proj_pnt[Z];
            ME.super_cmd->state = me->command = GET_TO_POINT;
            goto command_end;


          default:
            goto command_end;

	  }


      case GET_TO_POINT:
#if dflT1
  printf("in execute state GET_TO_POINT\n");
#endif

        if (ME.ECelement->elem_hilit) {
          stat_OM = dp$erase_hilite(msg = &msg_loc);

          ME.ECelement->elem_hilit = FALSE;
        }

        if(me->escaped) {
          me->escaped = FALSE;
          me->accev = me->baccev;
          me->accev.event.button.x = me->dyaccev.event.button.x;
          me->accev.event.button.y = me->dyaccev.event.button.y;
          me->accev.event.button.z = me->dyaccev.event.button.z;
          event_size = sizeof(struct GRevent);
          *response = EX_DATA;
          
          stat_func = ex$putque(
                            msg = &msg_loc,
                            pos = FRONT,
                            response = response,
                            byte = &event_size,
                            buffer = (char *) &me->accev);
        }

        ex$message(msgnumb = EMS_M_AcWTp, buff = loc_prompt);
           stat_func = co$getevent(
                  msg = &msg_loc,
                  mode = EX_ALL_CHAR_MODE | EX_LINE_MODE,
                  event_mask = (GRm_DATA | 
                                /*GRm_CHAR | */
                                GRm_STRING |
                                GRm_RJT_MOVEON | 
                                GRm_BACK_UP),
                  prompt = loc_prompt,
                  response = response,
                  response_data = response_data,
                  event = &me->accev);

        switch (*response) {

          case EX_DATA:
           if(me->command == GET_LINESTRING) {
             *response = EX_DATA; 
             event_size = sizeof(struct EX_button);
              stat_func = ex$putque(
                    msg = &msg_loc,
                    pos = FRONT,
                    response = response,
                    byte = &event_size,
                    buffer = (char *) &me->accev.event.button);
              goto command_end;
	    }
            me->baccev = me->accev;
            me->to_pnt[X] = me->accev.event.button.x;
            me->to_pnt[Y] = me->accev.event.button.y;
            me->to_pnt[Z] = me->accev.event.button.z;
            ME.super_cmd->state = me->command = MAIN_PROCESS;
            goto command_end;

          case EX_RJT_MOVEON:
            me->XXXXX = 9555;
            if(me->mark_point_id.objid) {
               gr$delete_object(msg = &msg_loc,
                  md_env = NULL,
                  object_id = &me->mark_point_id);
            }
            *response = TERMINATE;
            goto command_end;
            
          case EX_CHAR:
            ME.super_cmd->state = me->command = GET_TO_POINT;
            ksl = response_data[0];
            me->accev.event.keyin[0] = '\0';
            me->accev.event.keyin[1] = '\013';
            GRput_keybuff(me->accev.event.keyin);


            switch(ksl) {


            case PRODIST:
                if(me->optform_requested) 
                  FIg_set_state_on(me->optform, S_PRODIST_B); 
                stat_func = get_projection_dist(
                             &msg_loc, &me->common_dist, &me->prodist);
                if(me->optform_requested) {
                 FIg_set_value(me->optform, S_PRODIST_F, me->prodist); 
                 FIg_set_state_off(me->optform, S_PRODIST_B); 
	        }

                break;

            case OPTIONS:
              if(me->optform_requested) {
                me->optform_requested = FALSE;
                FIf_get_location(me->optform,&me->fxpos, &me->fypos);
                stat_func = FIf_erase(me->optform);
              } else {
                stat_OM = om$send(msg = message ECascvmd.status_disp(),
                                  targetid = my_id);
              }
              goto command_end;

            case PLANAR:
              if(!me->keep_planar) {
                if(!me->crv_found) {
                  ex$message(msgnumb = EMS_I_NoCvIdfd);
                } else {
                  stat_OM = om$send(msg = message ECascvmd.det_crv_plane(
                                        &msg_loc),
                                 targetid = my_id);
                  TEST_ERROR(stat_OM,msg_loc,"ECascvmd.det_crv_plane",command_end);
                  if(me->planar) {
                    me->keep_planar = TRUE;
                    if(me->optform_requested)
                       FIg_set_state_on(me->optform, S_PLANAR_B);
                  } else {
                    ex$message(msgnumb = EMS_I_CvNPl);
                  }
                  ME.super_cmd->state = me->command = GET_TO_POINT;
                }
	      } else {
                  me->keep_planar = FALSE;
                  if(me->optform_requested)
                     FIg_set_state_off(me->optform, S_PLANAR_B);
                  ME.super_cmd->state = me->command = GET_TO_POINT;
	      }
              goto command_end;
                            

            case FROMTO:
                me->fromto = TRUE;
                if(me->optform_requested)
                  FIg_set_state(me->optform, S_FROMTO_B,FALSE);
                ME.super_cmd->state = me->command = GET_FROM_POINT;
                goto command_end;

	    case PROJECT:
                me->fromto = FALSE;
                if(me->optform_requested)
                   FIg_set_state(me->optform, S_FROMTO_B,TRUE);
                ME.super_cmd->state = me->command = GET_TO_POINT;
                goto command_end;
            
                

            case STPT:
                if(me->optform_requested) {
                   FIg_set_state_on(me->optform, S_STARTPT_B);
                   FIg_set_state_off(me->optform, S_ENDPT_B);
		}
                me->set_stpt = TRUE;
                me->set_ept = FALSE;

                goto command_end;

            case EPT:
                if(me->optform_requested) {
                  FIg_set_state_on(me->optform, S_ENDPT_B);
                  FIg_set_state_off(me->optform, S_STARTPT_B);
                }
                me->set_ept = TRUE;
                me->set_stpt = FALSE;

              goto command_end;

            case FIX:
              if(me->set_stpt) {
                if(me->optform_requested) {
                   FIg_set_state_on(me->optform, S_SFIX_B);
                   FIg_set_state_off(me->optform, S_STARTPT_B);
		}
                me->stfix = TRUE;
                me->stfree = FALSE;
                me->stta = FALSE;
                me->stcrv = FALSE;
                me->bed_a = 1;
              } else if(me->set_ept) {
                if(me->optform_requested) {
                   FIg_set_state_on(me->optform, S_EFIX_B);
                   FIg_set_state_off(me->optform, S_ENDPT_B);
		}
                me->efix = TRUE;
                me->efree = FALSE;
                me->ecrv = FALSE;
                me->eta = FALSE;
                me->bed_e = 1;
              }
              goto command_end;

            case FREE:
              if(me->set_stpt) {
                if(me->optform_requested) {
                   FIg_set_state_on(me->optform, S_SFREE_B);
                   FIg_set_state_off(me->optform, S_STARTPT_B);
		}
                me->stfree = TRUE;
                me->stfix = FALSE;
                me->stta = FALSE;
                me->stcrv = FALSE;
                me->bed_a = 0;
              } else if(me->set_ept) {
                if(me->optform_requested) {
                   FIg_set_state_on(me->optform, S_EFREE_B);
                   FIg_set_state_off(me->optform, S_ENDPT_B);
		}
                me->efree = TRUE;
                me->efix = FALSE;
                me->ecrv = FALSE;
                me->eta = FALSE;
                me->bed_e = 0;
              }
              goto command_end;

            case TANGENT:
              if(me->set_stpt) {
                if(me->optform_requested)  {
                   FIg_set_state_on(me->optform, S_STA_B);
                   FIg_set_state_off(me->optform, S_STARTPT_B);
		}
                me->stta = TRUE;
                me->stfree = FALSE;
                me->stfix = FALSE;
                me->stcrv = FALSE;
                me->bed_a = 2;
              } else if(me->set_ept) {
                if(me->optform_requested) {
                   FIg_set_state_on(me->optform, S_ETA_B);
                   FIg_set_state_off(me->optform, S_ENDPT_B);
	        }
                me->eta = TRUE;
                me->efree = FALSE;
                me->efix = FALSE;
                me->ecrv = FALSE;
                me->bed_e = 2;
              }
              goto command_end;

            case CURVA:
              if(me->set_stpt) {
                if(me->optform_requested) {
                   FIg_set_state_on(me->optform, S_SCURV_B);
                   FIg_set_state_off(me->optform, S_STARTPT_B);
		}
                me->stcrv = TRUE;
                me->stfree = FALSE;
                me->stfix = FALSE;
                me->stta = FALSE;
                me->bed_a = 3;
              } else if(me->set_ept) {
                if(me->optform_requested) {
                   FIg_set_state_on(me->optform, S_ECURV_B);
                   FIg_set_state_off(me->optform, S_ENDPT_B);
		}
                me->ecrv = TRUE;
                me->efree = FALSE;
                me->efix = FALSE;
                me->eta = FALSE;
                me->bed_e = 3;
              }
              goto command_end; 

            case ESC:
              me->accev.event.keyin[0] = '\033';
              me->accev.event.keyin[1] = '\0';
              GRput_keybuff(me->accev.event.keyin);
              ex$message(field=KEYIN_FIELD,msgnumb=EMS_I_escape);
              me->old_command = GET_TO_POINT;
              ME.super_cmd->state = me->command = EXECUTE_COMMAND;
              goto command_end;


            case FINIS:
              *response = TERMINATE;
              goto command_end;


	     case IDLS:
               if(me->ls_found) {
                 ex$message(msgnumb = EMS_I_LsAI);
                 if(me->optform_requested)
                    FIg_set_state_off(me->optform, S_IDLS_B);
                 goto command_end;
               } else {
                  ex$message(msgnumb = EMS_M_SeLs, buff = loc_prompt);
                  ex$message(msgnumb = EMS_P_SeLs);
                  ME.super_cmd->state = GET_LINESTRING;
                  if(me->optform_requested)
                     FIg_set_state_on(me->optform, S_IDLS_B);
                  me->old_command = GET_TO_POINT;
                  goto command_end;               
	       }
	      }
          default:
            goto command_end;

	      }


    case EXECUTE_COMMAND:
#if dflT1
  printf("in execute state EXECUTE_COMMAND\n");
#endif

        loc_mask = GRm_DATA | 
                   GRm_CHAR |
                   GRm_BACK_UP;
        acc_mask = GRm_DATA;



        /*clear fields */

        ex$message(msgnumb = EMS_P_00000, buff = loc_prompt);
        ex$message(msgnumb = EMS_P_00000, buff = acc_prompt);
        ex$message(msgnumb = EMS_I_00000, buff = reloc_prompt);

        ex$message (msgnumb = EM_M_AsCvMd);
        lc_attr.properties = LC_LC_ONLY | 
                             LC_DP_ONLY | 
                             LC_RW | 
                             IGN_MOD_BIT;

        lc_attr.owner_action = LC_RIGID_COMP | 
                               LC_RIGID_OWNER |
                               LC_FLEX_COMP | 
                               LC_REF_OBJECTS | 
                               LC_NO_REF_HEADER;

        display_flag = ALL_WINDOWS | 
                       ELEM_HILIGHT | 
                       /*LC_ACC_ONE_ELEMENT |*/
                       PROJ_ACCEPT_POINT;



        rtree_classes.w_count = 1;
        eligible_classes.w_count = 1;
        rtree_classes.w_flags = eligible_classes.w_flags 
                              = OM_CLST_subclass;

        r_classes[0] = OPP_GRbspline_class_id;
    	e_classes[0] = OPP_GRcurve_class_id;

    	rtree_classes.p_classes = &r_classes[0];
    	eligible_classes.p_classes = &e_classes[0];

    	stat_func = lc$locate(
              	rc = &msg_loc,
              	event1 = &ME.ECelement->locev, 
              	event2 = &me->accev,
              	mask1 = loc_mask, 
              	mask2 = acc_mask,
              	eventsize= (int *)&event_size, 
              	display_flag = display_flag,
              	response = response,
              	response_data = response_data, 
              	locate_prompt = loc_prompt, 
              	acc_prompt = acc_prompt,
              	relocate_key = EMS_I_00010, 
              	attributes = &lc_attr, 
              	stack = &ME.ECelement->locate_stack, 
              	rtree_classes = &rtree_classes, 
              	eligible_classes = &eligible_classes);
      me->XXXXX = 8642;
      switch (me->accev.response) {
      case EX_CHAR:
#if dflT1
  printf("in EXECUTE COMMAND case EX_CHAR\n");
#endif
        me->command = ME.super_cmd->state = EXECUTE_COMMAND;
        goto command_end;
      case EX_DATA:
#if dflT1
  printf("in EXECUTE COMMAND case EX_DATA\n");
#endif
        if(me->ex_pocket_pressed) {
          me->plocp[X] = me->accev.located_object[0].proj_pnt[X];
          me->plocp[Y] = me->accev.located_object[0].proj_pnt[Y];
          me->plocp[Z] = me->accev.located_object[0].proj_pnt[Z];
        }
        me->command = ME.super_cmd->state = me->old_command;
        /*me->command = ME.super_cmd->state = MAIN_PROCESS;*/
        goto command_end;

      default:
#if dflT1
  printf("in EXECUTE COMMAND case default\n");
#endif
        me->command = ME.super_cmd->state = me->old_command;
        /*me->command = ME.super_cmd->state = me->GET_TO_POINT;
        me->escaped = TRUE;*/
        goto command_end;
      }


    case MAIN_PROCESS:
#if dflT1
  printf("in execute state MAIN_PROCESS\n");
#endif
            
            dpmode  = GRbe;
            stat_OM = om$send(mode = OM_e_wrt_object,
                          msg = message GRgraphics.GRdisplay (
                                 &msg_loc,
                                 &me->md_env.md_env.matrix_type,
                                 me->md_env.md_env.matrix,
                                  &dpmode, 
                                 &me->md_env.md_id),
                          senderid = my_id,
                          targetid = me->cv_info.located_obj.objid,
                          targetos = me->cv_info.located_obj.osnum);
            if(me->ls_found && !me->polypoints_allocated) {
               action = 0;
               stat_OM = om$send (msg = message GR3dlinestr.GRgetpolyline(
                           &msg_loc,
                           &me->md_env.md_env.matrix_type,
                           me->md_env.md_env.matrix,
                           &action,
                           &polyline),
                    targetid = me->ls_info.located_obj.objid,
                    targetos = me->ls_info.located_obj.osnum);
               TEST_ERROR(stat_OM,msg_loc,"GRgetpolyline",command_end);
                           
               polypts = (IGRdouble *) om$malloc( size =
                  (polyline.num_points * 3) * sizeof(IGRdouble));
               if(!polypts) 
                 REPORT_ERROR(stat_OM,OM_E_NODYNMEM,"stackalloc(polypts)",command_end);

               polyline.points = polypts;
               action = 1; /* get polyline itself */
               stat_OM = om$send (msg = message GR3dlinestr.GRgetpolyline(
                           &msg_loc,
                           &me->md_env.md_env.matrix_type,
                           me->md_env.md_env.matrix,
                           &action,
                           &polyline),
                    targetid = me->ls_info.located_obj.objid,
                    targetos = me->ls_info.located_obj.osnum);
               TEST_ERROR(stat_OM,msg_loc,"GRgetpolyline",command_end);
               me->polypoints_allocated = TRUE;
               me->vx = polypts;
               me->nvx = polyline.num_points;
             
               par_vec = (IGRdouble *) om$malloc (size = (polyline.num_points * sizeof(IGRdouble)));
               if(!par_vec)
                 REPORT_ERROR(stat_OM,OM_E_NODYNMEM,"om$malloc(par_vec)",command_end);
               me->par_vec = par_vec;
               cv_pts = (IGRdouble *) om$malloc (size = (3 * polyline.num_points * sizeof(IGRdouble)));
               if(!cv_pts)
                 REPORT_ERROR(stat_OM,OM_E_NODYNMEM,"om$malloc(cv_pts)",command_end);
               me->cv_pts = cv_pts;
               dists = (IGRdouble *) om$malloc (size = (polyline.num_points * sizeof(IGRdouble)));
               if(!dists)
                 REPORT_ERROR(stat_OM,OM_E_NODYNMEM,"om$malloc(dists)",command_end);
               me->dists = dists;

	    }

            stat_OM = om$send(msg = message ECascvmd.create_curve_dynamics_buffer(
                                    &msg_loc,
                                    &response2),
                              targetid = my_id);
            TEST_ERROR(stat_OM,msg_loc,"create_curve_dynamics_buffer",command_end);
            

           goto command_end;

      

    case FINISH:
#if dflT1
  printf("in execute state FINISH\n");
#endif
        *response = TERMINATE;
        goto command_end;

   } /* end super_cmd switch */

  } while (ME.super_cmd->state != FINISH); /* end do  */

command_end:
 
 if(*response == TERMINATE) {
   if(polypts)  {
     om$dealloc(ptr = polypts);
     polypts = NULL;
   }
   if(cv_pts) {
     om$dealloc(ptr = cv_pts);
     cv_pts = NULL;
   }
   if(dists) {
     om$dealloc(ptr = dists);
     dists = NULL;
   }
   if(par_vec) {
     om$dealloc(ptr = par_vec);
     par_vec = NULL;
   }
 }

#if dflT1
  printf("*** return end ***\n");
#endif
  return (stat_OM);
}

end implementation ECascvmd;

