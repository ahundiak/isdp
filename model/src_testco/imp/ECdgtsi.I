/* ###################   APOGEE COMPILED   ################## */

/* HISTORY :

           Vadiraj   06/10/92   Modified for message subsystem compliance.
           Kumar N   02/14/93   Modified for WL .
	   07/12/93  H.S. Gandhi
	      Converted code for WL impact
           12/17/93  S. Yu      Corrected WL conversion errors and fixed
                                TR#119312906.
           08/14/94  scw        clarified sleep method
*/
class implementation ECdgts;

#include "EMS.h"
#include <sys/types.h>
#include <sys/times.h>
#include "EC_F.h"
#include "EC_I.h"
#include "EC_M.h"
#include "EC_P.h"
#include "EC_E.h"
#inculde "bserr.h"
#include "bsparameters.h"
#include "EMSlcdef.h"
#include "griomacros.h" /* For expression evaluation */
#include <stdio.h>
#include <wl.h>		/* include file for WL impact */
#include "igecolordef.h"
%safe
#include <math.h>
%endsafe
#include "FI.h"
#include "madef.h" /* For PI */

#include "igewindef.h"
#include "igewindow.h"
#include "igewinmacros.h" /* For ige$inq.. */

#include "grdpbdef.h"
#include "grdpbmacros.h" /* For gr$get_dy.. */
#include "dpgraphics.h"  /* for compile switch settings */
#include "EMSdpbmacros.h"

#define INPUT_FROM_POINT 2
#define INPUT_TO_POINT 3
#define STOP_INPUT 4
#define ERASE_STREAM 5
#define CONSTRUCT_CURVE 6

/* Defines for the slider form */
#define SLIDER 11
#define SAVE 1
#define DELTA_DIST 15
#define DELTA_ANGLE 16

%safe
 static int num_dyn = 0;
 static int num_poll = 0;
 static int poll_time = 0;
/*
 static double band_width = 0;
 static double band_width_sq = 0.0;
*/
 static double ddsq = 0.0;
 static double dd = 0.0;
 static double dotp = 1.0;
 static double da = 0.0;
 static short form_displayed = 0;
 static  IGRboolean cursor();
%endsafe

#define ERROR(sts_stupid, error_number, error_message)\
 {\
  if(!(sts_stupid & 1 & error_number))\
   {\
    if (!(1&msg)) EFprintcode(0,msg);\
    if (!(1&sts_stupid)) EFprintcode(0,sts_stupid);\
    *response = TERMINATE;\
    ex$message(msgnumb = EMS_F_0002)\
    return(OM_E_ABORT);\
   }\
 }
#define FORM1  1

static Form  form1;
extern OMuword OPP_GRbcsubbc_class_id;
from GRsubbc import EMleast_squares_fit_curvee;
from GRgraphics import GRdisplay;

method execute(int *response; char *response_data; int pos)
{
 IGRlong sts,msg;
 IGRint event_mask;
 IGRchar string[80];
 enum GRdpmode display_mode;
 IGRint flags = DP_NO_CURSOR;
 struct GRevent event;
 struct IGRpolyline pts;
 struct IGRpointset point_set;

 sts = OM_S_SUCCESS;
 msg = MSSUCC;

 ex$message(msgnumb = EM_M_PCrDg);

/*
 * Enter infinite loop.
 */
 do
 {
  switch (ME.super_cmd->state)
  {
   case 0:
    ME.super_cmd->state = INPUT_FROM_POINT;
   break;

   case INPUT_FROM_POINT:
   {
    event_mask = GRm_DATA;

    if (me->polyline.points)
      om$dealloc(ptr = me->polyline.points);

    me->polyline.num_points = 0;
    me->polyline.points = NULL;
    me->info.firstcall = TRUE;

    /*strcpy(string,"Input start point");*/
    ex$message(msgnumb = EMS_P_00077, buff = string);

    sts = co$getevent(
     msg =		&msg,
     event_mask = 	event_mask,
     prompt =		string,
     response =		response,
     response_data =	response_data,
     event =		&event);
    if (! (1 & sts)) return(OM_E_ABORT);

    if (event.response == GR_UNKNOWN_TYPE)
     return (OM_S_SUCCESS);
    else if (event.response == EX_DATA)
    {
      struct EX_button *data;
      data = &event.event.button;
      me->from_point[0] = data->x;
      me->from_point[1] = data->y;
      me->from_point[2] = data->z;
      ME.super_cmd->state = INPUT_TO_POINT;;

    }
   }
   break;

   case INPUT_TO_POINT:
   {
    int EMgenptstream();

    OM_BLOCK_MOVE(me->from_point, me->info.start_pt,sizeof(IGRpoint));

    me->info.poly = &me->polyline;
    me->info.md_env = &ME.ECelement->md_env;

    event_mask = GRm_DATA | GRm_RJT_MOVEON | GRm_BACK_UP;
   
    ex$message(msgnumb = EMS_S_DrwMdDToErs);

    /*strcpy(string,"Data to stop digitising/Moveon");*/
    ex$message(msgnumb = EMS_P_DtToStpDgtMvOn, buff = string);
    ex$message(field = PROMPT_FIELD, justification = RIGHT_JUS,
               in_buff = string);  

    me->espy.is_closed = FALSE;
    pts.num_points = 0;
    pts.points = NULL;
    point_set.num_points = 0;
    point_set.points = NULL;

/*
 * Build buffers for displaying the polyline in background
 */

    dp$build_dis_buffer (buffer = &me->info.buff, type = IGRPY,
                         display_att = &ME.ECelement->active_display, 
                         ele_spec_att = &me->espy, geometry = &pts);

/*
 * Call dynamics for drawing.
 */
    EMinit_wininfo();

    dp$dynamics (dyn_fun = EMgenptstream, information = &me->info,
                 flags = &flags);

    sts = co$getevent(
     msg =		&msg,
     event_mask = 	event_mask,
     prompt     =       string,
     response =		response,
     response_data =	response_data,
     event =		&event);
    if (! (1 & sts)) return(OM_E_ABORT);

    if (event.response == GR_UNKNOWN_TYPE)
    {
     if ((*response == EX_CMD_KEY) && !(strcmp ("GRSlTnPnKy",
                                               response_data)))
     {
      if (me->polyline.num_points)
      {
       ME.super_cmd->state = ERASE_STREAM;
       me->info.store_num_points = me->polyline.num_points;
      }
      else
        ex$message(msgnumb = EMS_S_NoPtsToErs);

/*
 * The following getevent is necessary to remove the extra data point put
 * onto the queue by the tentative keypoint.
 */
      sts = co$getevent(
                   msg = &msg,
                   event_mask = event_mask,
                   prompt = "",
                   response = response,
                   response_data = response_data,
                   event = &event);
      
      break;
     }
     return (OM_S_SUCCESS);
    }
    else if (event.response == EX_BACK_UP)
    {
      if (me->polyline.num_points)
      {
        ECdisplayPointSetByBuffer(&msg,ME.ECelement->active_display,
                              ME.ECelement->md_env,
                              my_id,me->polyline.num_points,
                              me->polyline.points,FALSE);
        ERROR(1,msg,"In buffer display");
      }
      ME.super_cmd->state = INPUT_FROM_POINT;
    }
    else if (event.response == EX_DATA)
    {
       ME.super_cmd->state = STOP_INPUT;
       break;
    }
    else if (event.response == EX_RJT_MOVEON)
    {
       ME.super_cmd->state = CONSTRUCT_CURVE;
       break;
    }
    ex$message(msgnumb = EMS_S_ClearStatusField);
   }
   break;

  case STOP_INPUT:
  {
   event_mask = GRm_RJT_MOVEON | GRm_DATA | GRm_BACK_UP;

   /*strcpy(string,"Data to resume drawing/Moveon");*/
   ex$message(msgnumb = EMS_P_DtToResmDrawMvOn, buff = string);

   sts = co$getevent(
     msg =		&msg,
     event_mask = 	event_mask,
     prompt     =       string,
     response =		response,
     response_data =	response_data,
     event =		&event);
    if (! (1 & sts)) return(OM_E_ABORT);

   if (event.response == GR_UNKNOWN_TYPE)
      return (OM_S_SUCCESS);
   else if (event.response == EX_DATA)
     ME.super_cmd->state = INPUT_TO_POINT;
   else if (event.response == EX_BACK_UP)
   {
      if (me->polyline.num_points)
      {
        ECdisplayPointSetByBuffer(&msg,ME.ECelement->active_display,
                              ME.ECelement->md_env,
                              my_id,me->polyline.num_points,
                              me->polyline.points,FALSE);
        ERROR(1,msg,"In buffer display");
      }

     ME.super_cmd->state = INPUT_FROM_POINT;
   }
   else if (event.response == EX_RJT_MOVEON)
      ME.super_cmd->state = CONSTRUCT_CURVE;
  }
  break;

  case ERASE_STREAM:
  {
    int EMclrptstream();

    event_mask = GRm_RJT_MOVEON | GRm_BACK_UP;

    ex$message(msgnumb = EMS_S_ErsMdDToDrw);  

    /*strcpy(string,"Move cursor over portion to erase/Move on");*/
    ex$message(msgnumb = EMS_P_MvCrsrOvPornToErs, buff = string);
    ex$message(field = PROMPT_FIELD, justification = RIGHT_JUS,
               in_buff = string);

    EMinit_wininfo();

    pts.num_points = 0;
    pts.points = NULL;

    dp$dynamics (dyn_fun = EMclrptstream, information = &me->info,
                 flags = &flags);

    sts = co$getevent(
     msg =		&msg,
     event_mask = 	event_mask,
     prompt =		string,
     response =		response,
     response_data =	response_data,
     event =		&event);
    if (! (1 & sts)) return(OM_E_ABORT);

    if (event.response == GR_UNKNOWN_TYPE)
    {
     if ((*response == EX_CMD_KEY) && !(strcmp ("GRSlTnPnKy",
                                               response_data)))
     {
      if (me->polyline.num_points)
       ME.super_cmd->state = INPUT_TO_POINT;
      else
       ME.super_cmd->state = INPUT_FROM_POINT;
/*
 * The following getevent is necessary to remove the extra data point put
 * onto the queue by the tentative keypoint.
 */
       sts = co$getevent(
                   msg = &msg,
                   event_mask = event_mask,
                   prompt = "",
                   response = response,
                   response_data = response_data,
                   event = &event);
      break;
     }
     else
      return (OM_S_SUCCESS);
    }
    else if (event.response == EX_RJT_MOVEON)
    {
     ME.super_cmd->state = CONSTRUCT_CURVE;
    }
    else if (event.response == EX_BACK_UP)
    {
      if (me->polyline.num_points)
       {
        ECdisplayPointSetByBuffer(&msg,ME.ECelement->active_display,
                              ME.ECelement->md_env,
                              my_id,me->polyline.num_points,
                              me->polyline.points,
                              FALSE);
        ERROR(1,msg,"In buffer display");
       }

        me->polyline.num_points = me->info.store_num_points;

        if (me->polyline.num_points)
        {
         ECdisplayPointSetByBuffer(&msg,ME.ECelement->active_display,
                              ME.ECelement->md_env,
                              my_id,me->polyline.num_points,
                              me->polyline.points,
                              TRUE);
         ERROR(1,msg,"In buffer display");
        }
       ME.super_cmd->state = INPUT_TO_POINT;
     }
    ex$message(msgnumb = EMS_S_ClearStatusField);
    }
    break;
/*
 * This is a transition state. 
 */

  case CONSTRUCT_CURVE:
  {
     struct GRvg_construct construct_list;
     OM_S_OBJID newobjid;
     OMuword spacenum;
     IGRchar buff;
     IGRlong order;
     IGRboolean periodic = FALSE;
     IGRdouble avgerr, maxerr;
     IGRpoint seg[2];
     IGRlong errind;
/********************************************************************    
     EMdpb_get(&msg,EMSdpb_u_order,&buff);
********************************************************************/
     ems$dpb_get(msg = &msg,
                 parameter = EMSdpb_u_order,
                 buffer = (IGRuchar *)&buff);  
     ERROR(1,msg,"In getting order")

     order = buff;

     spacenum = ME.ECelement->md_env.md_id.osnum;

     construct_list.msg = &msg;
     construct_list.env_info = &ME.ECelement->md_env;
     construct_list.newflag = FALSE;
     construct_list.geometry = NULL;
     construct_list.class_attr = NULL;
     construct_list.level = ME.ECelement->active_level;
     construct_list.properties = GRIS_LOCATABLE | GRIS_DISPLAYABLE;
     construct_list.display = &ME.ECelement->active_display;
     construct_list.name = NULL;
      
      if (me->polyline.num_points)
      {
        ECdisplayPointSetByBuffer(&msg,ME.ECelement->active_display,
                              ME.ECelement->md_env,
                              my_id,me->polyline.num_points,
                              me->polyline.points,FALSE);
        ERROR(1,msg,"In buffer display");
      }

     ex$message(msgnumb = EMS_I_00003);
   
     if (me->polyline.num_points)
     {
      sts = om$construct(classid = OPP_GRbcsubbc_class_id,
                        p_objid = &newobjid,
                        osnum = spacenum,
                        msg = message GRsubbc.EMleast_squares_fit_curvee(
                              order,
                              periodic,
                              me->polyline.num_points,
                              (IGRpoint *)me->polyline.points,
                              NULL, /* no buffer */
                              NULL, /* Beginning tangent */
                              NULL, /* ending tangent */
                              0,    /* To cause the curve to undergo
                                       data reduction */
                              NULL, /* No reference curve */
                              &avgerr, /* Do not desire avgerr */
                              &maxerr, /* Do not desire max err */
                              &errind, /* Do not desire where it occured */
                              seg,
                              &construct_list));
     }

     if ((msg == MSFAIL) || (!me->polyline.num_points))
     {
       IGRboolean degenerate = FALSE;
 
       if (msg == MSFAIL)
       ex$message(msgnumb = EMS_E_ErrInConstrLnStrnConstr);

       if (!me->polyline.num_points) degenerate = TRUE;

       EFplace_line_string(NULL_OBJID, &construct_list, 
                           (degenerate ?  1 :
                                         me->polyline.num_points),
                           (degenerate ? me->info.start_pt : 
                                         me->polyline.points),
                           &newobjid,&msg);
       ERROR(1,msg,"In EFplace_line_string");

       msg = MSSUCC;
       sts = 1;
     }

     display_mode = GRbd;

     sts = om$send (msg = message GRgraphics.GRdisplay(&msg,
                         &me->md_env.md_env.matrix_type,
                         me->md_env.md_env.matrix,
                         &display_mode,
                         &me->md_env.md_id),
                   targetid = newobjid,
                   targetos = spacenum);
     ERROR(sts,msg,"In drawing surface")

      ex$message(msgnumb = EMS_S_ClearStatusField);
      ME.super_cmd->state = INPUT_FROM_POINT;
      break;
    }

  default:
  {
   return (OM_E_ABORT);
  }
 }
}
 while (TRUE);

 return (OM_S_SUCCESS);
}

method init(int type; char *str_ptr)
{
  IGRint process_form();
  int		  status = OM_S_SUCCESS;
  IGRlong EMmsg;
  IGRint ret;

  EMmsg = 1;
  me->polyline.num_points = 0;
  me->polyline.points = NULL;
  poll_time = 5;
  ddsq = 0.0;
  dd = 0.0;
  dotp = 0.0;
  da = 0.0;
  me->form_id = NULL_OBJID;

  ex$message(msgnumb = EMS_I_InvkStatusFrm);
                     /* Invoke status form to review options */
  sleep(1);
   ret = FIf_new (FORM1, "MDdgts", process_form, &form1);
   if (ret) {
      status = FALSE;
   }

  return (status);
}

method wakeup(int pos)
{
 IGRlong status;
 IGRlong msg;
 IGRlong nret;
 IGRlong sizebuff;
 int ret;

 status = OM_S_SUCCESS;

 GRstatus_display_button(1);

 status = om$send(mode = OM_e_wrt_message,
                  msg = message ECelement.wakeup(pos),
                  targetid = my_id);
 if (!(1&status)) return (OM_E_ABORT);

 if (me->polyline.num_points)
 {
   ECdisplayPointSetByBuffer(&msg,ME.ECelement->active_display,
                              ME.ECelement->md_env,
                              my_id,me->polyline.num_points,
                              me->polyline.points,
                              TRUE);
   if (!(1&msg)) return (OM_E_ABORT);
 }

 if (form_displayed)
 {
  ret = FIf_set_location (form1,970,605);
  if (ret)
    return (OM_E_ABORT);
  ret = FIf_display(form1);
  if (ret)
    return (OM_E_ABORT);
 }
 
 sizebuff = sizeof(IGRboolean);
 status = gr$get_dynamics_on(msg = &msg,sizbuf = &sizebuff,
                             buffer = &me->dynamics_on,nret = &nret);
 if (!(1&status&msg)) return (OM_E_ABORT);

 if (!me->dynamics_on)
 {
  me->dynamics_on = TRUE;
  nret = sizeof(IGRboolean);
  status = gr$put_dynamics_on(msg = &msg,sizbuf = &nret,
                              buffer = &me->dynamics_on);
  if (!(1&status&msg)) return (OM_E_ABORT);
 }
 else 
  me->dynamics_on = FALSE;

/*
 * We turn dynamics in all windows to prevent the buffering of display
 * of the linestring.
 */

 sizebuff = sizeof(IGRboolean);
  status = gr$get_dynamics_all_windows(msg = &msg,sizbuf = &sizebuff,
                     buffer = &me->dynamics_all_windows, nret = &nret);
  if (!(1&status&msg)) return (OM_E_ABORT);

  if (!me->dynamics_all_windows)
  {
   me->dynamics_all_windows = TRUE;
   nret = sizeof(IGRboolean);

   status = gr$put_dynamics_all_windows(msg = &msg,sizbuf = &nret,
                                        buffer = &me->dynamics_all_windows);
   if (!(1&status&msg)) return (OM_E_ABORT);
  }
  else
   me->dynamics_all_windows = FALSE;

  {
     IGRchar	status_string[160];
     IGRchar	tmp_string[80], tolerance_string[80];
     IGRboolean	sts;
     IGRint u_order, v_order;
     extern	IGRlong EFconvert_to_user_units();
     IGRdouble	tolerance;
     IGRuchar buffer;
     IGRchar  buff1[160]; 
/***********************************************************************
     status = EMdpb_get(
       &msg,
       EMSdpb_u_order,
       &buffer);
*************************************************************************/
     status = ems$dpb_get(
              msg = &msg,
              parameter = EMSdpb_u_order,
              buffer = &buffer);
     if (! (1 & status)) return(status);
     u_order = buffer;
/*************************************************************************
     status = EMdpb_get(
       &msg,
       EMSdpb_v_order,
       &buffer);
*************************************************************************/
     status = ems$dpb_get(
                 msg = &msg,
                 parameter = EMSdpb_v_order,
                 buffer = &buffer);
     if (! (1 & status)) return(status);

     v_order = buffer;

     sts = BSEXTRACTPAR(
      &msg,
      BSTOLCHRDHT,
      tolerance);
     tmp_string[0] = '\0';
     status = EFconvert_to_user_units(
       tolerance,
       TRUE,
       tmp_string,
       &msg);
     if (! (1 & status))
        return(OM_E_ABORT);

     ex$message(
      msgnumb = EMS_I_00025,
      type = "%s",
      var = `tmp_string`,
      buff = tolerance_string);

     ex$message(
       msgnumb = EMS_I_00028,
       type = "%2d%2d",
       var = `u_order, v_order`,
       buff = status_string);
     ex$message(msgnumb = EMS_S_ClearStatusField, buff = buff1); 
     strcat(status_string, buff1);
     strcat(status_string, tolerance_string);

     ex$message(
      in_buff = status_string,
      field = ERROR_FIELD);

    }
  
 return (status);
}

IGRint process_form(form_label, gadget_label, value)
int form_label, gadget_label;
double value;
{
 IGRlong sts,EMmsg;
 int sel, rpos;
 char str[132];
 IGRint update_form = FALSE;
 
 sts = OM_S_SUCCESS;

 if (form_label == FORM1) {
    switch (gadget_label)
 {
  case SLIDER:
   poll_time  = 100 - value;
   if ((poll_time < 0) || (poll_time > 100))
    return (OM_E_ABORT);
  break;

  case DELTA_DIST:
  {
   IGRdouble temp;
   FIfld_get_text(form1, gadget_label, 0,0, 132, str, &sel, &rpos);
   sts = co$expreval(
         msg = &EMmsg,
         expression = str,
         unit_type = "UOM_DISTANCE",
         result = &temp);
   if (1&sts&EMmsg) 
   {
    dd = temp;
    ddsq = dd * dd;
   }
    update_form = TRUE;
  }
  break;

  case DELTA_ANGLE:
  {
   IGRdouble angle;
   FIfld_get_text(form1, gadget_label, 0,0, 132, str, &sel, &rpos);
   sts = co$expreval(
       msg = &EMmsg,
       scale_flag = GRIO_NO_SCALE,
       expression = str,
       unit_type = "UOM_ANGLE",
       result = &angle);
   if (1&sts&EMmsg)
   {
    da = angle;
    dotp = cos(da);
   }
   update_form = TRUE;
  }
  break;

/*
  case BAND_WIDTH:
  {
   band_width = form_data->value.dvalue;
   EFconvert(&EMmsg,band_width,&band_width,1);
   if (!(1&EMmsg)) return (OM_E_ABORT);

   band_width_sq = band_width * band_width;
  }
  break;
*/

  case SAVE:
  {
   FIg_set_state_off (form1, gadget_label);
   FIf_erase (form1);
   form_displayed = FALSE;
   update_form = TRUE;
  }
  break;
 }

 if (update_form)
 {
  update_this_form();
 }
}
 return (sts);
}

method delete(int defer_flag)
{
 IGRlong sts = OM_S_SUCCESS;

 if (me->form_id != NULL_OBJID)
 {
  sts = om$send (msg = message Root.delete(1),
       targetid = me->form_id);
  if (!(1&sts)) return (sts);
 }
  sts = om$send(mode = OM_e_wrt_ancestor,
                msg = message Root.delete(1),
                targetid = my_id);
  return (sts);
}

method super_cmd.sleep(int pos)
{
 IGRlong sts;
 IGRlong msg;
 IGRlong nret;

 sts = OM_S_SUCCESS;

 GRstatus_display_button(0);

 if (me->polyline.num_points)
 {
   ECdisplayPointSetByBuffer(&msg,ME.ECelement->active_display,
                              ME.ECelement->md_env,
                              my_id,me->polyline.num_points,
                              me->polyline.points,
                              FALSE);
   if (!(1&msg)) return (OM_E_ABORT);
 }

 if (form_displayed)
 {
  FIf_erase (form1);
 }

 if (me->dynamics_on)
 {
  me->dynamics_on = FALSE;
  nret = sizeof(IGRboolean);
  sts = gr$put_dynamics_on(msg = &msg,sizbuf = &nret,
                           buffer = &me->dynamics_on);
  if (!(1&sts&msg)) return (OM_E_ABORT);
 }
/*
 * If dynamics has been turned on in all windows by this command then turn
 * it back off.
 */

 if (me->dynamics_all_windows)
 {
  me->dynamics_all_windows = FALSE;
  nret = sizeof(IGRboolean);
  sts = gr$put_dynamics_all_windows(msg = &msg,sizbuf = &nret,
                           buffer = &me->dynamics_all_windows);
  if (!(1&sts&msg)) return (OM_E_ABORT);
 }

 return (sts);
}

update_this_form()
{
 double dvalue;
 char alpha1[132];
 char alpha2[132];
 extern IGRlong EFshort_cvtn();
 IGRlong sts;
 IGRlong EMmsg;
 IGRchar inp_buff[80];
 EMmsg = 1;

 dvalue = 100 - poll_time;
 FIg_set_value(form1, SLIDER, dvalue);
 
 alpha1[0] = '\0';
 sts = EFshort_cvtn(
    alpha1,
    dd, 
    4, 
    132); /* Maximum size of the character array being passed in */
 FIg_set_text(form1, DELTA_DIST, alpha1);

 alpha2[0] = '\0';
 ex$message(msgnumb = EMS_I_Dgs, buff = inp_buff);
 sprintf(
  alpha2,
   "%.1f %s",
   da * 180.0 / PI, inp_buff);
 FIg_set_text(form1, DELTA_ANGLE, alpha2);

 return(1);
}

method status_disp()
{
 IGRlong status;
 IGRlong EMmsg;
 int ret;
 
 status = OM_S_SUCCESS;
 EMmsg = 1;

  update_this_form();

  if (!form_displayed)
  {
  ret = FIf_set_location (form1,970,605);
  if (ret){
      status = FALSE;
      goto wrapup;
   }
  ret = FIf_display(form1);
  if (ret){
      status = FALSE;
      goto wrapup;
   }
   form_displayed = TRUE;
  }

wrapup:
 if (!(1&status&EMmsg))
   return (OM_E_ABORT);
 return (status);
}


/*
 * Constants used within this file. Their names
 * are self-explanatory.
 */

#define GENERATE_STREAM	0
#define CLEAR_STREAM	1

#define BUFF_INCR  50

#define XMIN 0
#define YMIN 1
#define ZMIN 2
#define XMAX 3
#define YMAX 4
#define ZMAX 5

#define X 0
#define Y 1
#define Z 2

#define X1 0
#define Y1 1
#define Z1 2
#define X2 3
#define Y2 4
#define Z2 5

#define XCOMP_BLINE 8
#define YCOMP_BLINE 9
#define ZCOMP_BLINE 10

%safe
static IGRint prev_realtime;
%endsafe

#argsused
IGRint EMgenptstream (buff_info, newpt, mtx, objs, num_objs, buffs, num_buffs,
                      dummy1, dummy2, dummy3, outflags, dummy5, dummy6)
struct modbuff_info *buff_info;
struct EX_button *newpt;
IGRdouble *mtx;
struct GRid **objs;
IGRint *num_objs;
struct DPele_header **buffs;
IGRint *num_buffs;
IGRchar *dummy1, *dummy2, *dummy3;
IGRint *outflags, *dummy5, *dummy6;
{
  IGRboolean stat_func, genpoint;
  IGRint curr_realtime, numpts, numslots;
  IGRlong msg_loc;
  IGRpoint *pts,dumpt;
  struct IGRpolyline *py, *bpy;
  struct tms timebuff;

  /*
   * Added following code to address WL impact.
   * Since in WL dynamics mode, drawing is done in highlight plane.
   * To draw in background plane in active color as needed by this
   * function, we have to exit dynamics mode and set proper drawing
   * mode. This is to fix TR#119312906. SY. 12/17/93
   */
  IGRint num_wins, i;
  IGRint wins[EX_MAX_WINDOW];

  EMget_active_lwins(&num_wins, wins);
  for (i = 0; i < num_wins; i++)
  {
      WLexit_dynamics( wins[i] );
      WLset_drawing_mode( wins[i], WL_BASE_DRAW );
  }

  stat_func = TRUE;
  
  /*
   * Check if this point needs to be added. If this is the first
   * time the call is being made, then add. If the time elapsed since
   * the last call is greater than or equal to the specified time,
   * then add.
   */
  py = buff_info->poly;
  pts = (IGRpoint *)py->points;

  OM_BLOCK_MOVE (&newpt->x, dumpt, sizeof (IGRpoint));

  if (buff_info->firstcall)
    {
    num_dyn = 0;
    num_poll = 0;
    genpoint = TRUE;
    prev_realtime = times (&timebuff);

    if (genpoint && (dd != 0.0))
    {
      IGRdouble dumddsq;
      IGRint rc;
      extern IGRdouble BSdistptpts();

      dumddsq = BSdistptpts(&rc,dumpt,buff_info->start_pt);
      if (rc != 0) dumddsq = ddsq;

      if (dumddsq >= ddsq)
       genpoint = TRUE;
      else
       genpoint = FALSE;
     }
    }
  else
    {
    curr_realtime = times (&timebuff);
    if (curr_realtime - prev_realtime >= poll_time)
      {
      genpoint = TRUE;
      prev_realtime = curr_realtime;
      ++num_poll;
      }
    else
      genpoint = FALSE;

    if (genpoint && (dd != 0.0))
    {
      IGRdouble dumddsq;
      IGRint rc;
      extern IGRdouble BSdistptpts();

      dumddsq = BSdistptpts(&rc,dumpt,pts[py->num_points - 1]);
      if (rc != 0) dumddsq = ddsq;

      if (dumddsq >= ddsq)
       genpoint = TRUE;
      else
       genpoint = FALSE;
    }

    if (genpoint && (da != 0.0) && (py->num_points >= 2))
    {
     IGRvector vec1,vec2;
     IGRint numpts,j,rc;
     IGRboolean bssts;
     extern IGRboolean BSnorvec();
     IGRdouble dumdotp;

     numpts = py->num_points;


     for (j=0;j<3;j++)
     {
      vec1[j] = pts[numpts - 1][j] - pts[numpts - 2][j]; 
      vec2[j] = dumpt[j] - pts[numpts - 1][j]; 
     }
     bssts = BSnorvec(&rc,vec1);
     if (rc==0)
     {
      bssts  = BSnorvec(&rc,vec2);
      if (rc==0) 
      {
        dumdotp = vec1[0]*vec2[0] + vec1[1]*vec2[1] + vec1[2]*vec2[2];

        if (dumdotp <= dotp) genpoint = TRUE;
        else genpoint = FALSE;
      }
      else genpoint = FALSE;
     }
     else genpoint = FALSE;
    }

/*
    if (genpoint && (band_width != 0.0) && (py->num_points >= 2))
    {
     extern  IGRboolean  MAptlnproj();
     IGRdouble t;
     IGRdouble tempdistsq;
     struct IGRline line;
     IGRpoint line_pt;
     IGRint numpts;
     
     numpts = py->num_points;

     line.point1 = (IGRdouble *)pts[numpts - 2];
     line.point2 = (IGRdouble *)pts[numpts - 1];

     stat_func = MAptlnproj (&msg_loc,dumpt,&line,line_pt,&t);
     if (!stat_func) return (0);

     tempdistsq = BSdistptpts(&msg_loc,dumpt,line_pt);

     if (tempdistsq < band_width_sq)
      OM_BLOCK_MOVE (line_pt, dumpt, sizeof (IGRpoint));
    }
*/
      ++num_dyn;
    }

  if (genpoint)
    {
    if (buff_info->firstcall)
      {
      pts = (IGRpoint *) om$malloc (size = BUFF_INCR * sizeof (IGRpoint));
      EMerr_hndlr (!pts, stat_func, FALSE, ret_end);
      py->points = (IGRdouble *)pts;

      OM_BLOCK_MOVE (buff_info->start_pt, pts, sizeof (IGRpoint));
      OM_BLOCK_MOVE (dumpt, pts[1], sizeof (IGRpoint));
      numpts = py->num_points = 2;
      buff_info->firstcall = FALSE;
      }
    else
      {
      numpts = py->num_points;
      numslots = (numpts / BUFF_INCR) * BUFF_INCR + 
                 (numpts % BUFF_INCR ? BUFF_INCR : 0);
      if (numpts + 1 > numslots)
        {
        pts = (IGRpoint *) om$realloc (size = (numslots + BUFF_INCR) * sizeof (IGRpoint),
               ptr = (char *)pts);
        EMerr_hndlr (!pts, stat_func, FALSE, ret_end);
        py->points = (IGRdouble *)pts;
        }

      OM_BLOCK_MOVE (dumpt, pts[numpts], sizeof (IGRpoint));
      numpts = ++py->num_points;
      }
 
    if (!stat_func)
      goto ret_end;


    bpy = buff_info->buff.geometry.polyline;

    bpy->num_points = 2;
    bpy->points = pts[numpts-2];


    stat_func = dp$display (msg = &msg_loc,
                osnum = buff_info->md_env->md_id.osnum,
                objid = buff_info->md_env->md_id.objid,
                mode = GRbd, 
                num_elem = 1, 
                buffer = &buff_info->buff);
    if (!stat_func)
      goto ret_end;
   }

 stat_func = dp$erase_hilite (msg = &msg_loc);

 stat_func = cursor (newpt, GENERATE_STREAM);
   if (!stat_func)
     goto ret_end;

 *num_buffs = 0;
 *outflags |= DP_DONT_ERASE;

  /*
   * Added following code to address WL impact.
   * This will silent the WL_REPORT_ERROR to report
   * WL_NOT_IN_DYNAMICS (31).
   */
  for (i = 0; i < num_wins; i++)
  {
      WLenter_dynamics( wins[i] );
      WLset_dynamics_drawing_mode( wins[i], WL_DYN_DRAW_MODE );
  }

ret_end:
  return (stat_func);
}


#argsused
IGRint EMclrptstream (buff_info, newpt, mtx, objs, num_objs, buffs, num_buffs,
                      dummy1, dummy2, dummy3, outflags, dummy5, dummy6)
struct modbuff_info *buff_info;
struct EX_button *newpt;
IGRdouble *mtx;
struct GRid **objs;
IGRint *num_objs;
struct DPele_header **buffs;
IGRint *num_buffs;
IGRchar *dummy1, *dummy2, *dummy3;
IGRint *outflags, *dummy5, *dummy6;
{
  IGRboolean stat_func, clrpoint;
  IGRshort relation;
  IGRint numpts;
  IGRlong msg;
  IGRdouble *seg, pixtol, segknots[4], dumpar;
  IGRpoint *pts, blinpt1, blinpt2, segpoles[2], dumpt;
  IGRmatrix wvmat;
  GRrange segrng;
  struct IGRpolyline *py, *bpy, segpy;
  struct IGRline blin;
  struct IGRbsp_curve segcv;
  extern void BSmdptcvbx();
  extern IGRboolean EMcnvtpybsn(),MAlncuberel(), EMgetwininfo();

  stat_func = TRUE;

  /*
   * Since only the last segment may be cleared, if the number of
   * points is less than 2, this is a noop.
   */

  py = buff_info->poly;
  if (py->num_points >= 2)
  {
  /*
   * Obtain the boreline and check if the last segment lies within the
   * dit-range of the cursor.
   */

  stat_func = EMgetwininfo (newpt->objid, newpt->osnum, wvmat, NULL, NULL,
               NULL, NULL,&pixtol, NULL, NULL);
  if (EMSerror (stat_func))
    goto ret_end;

  OM_BLOCK_MOVE (&newpt->x, blinpt1, sizeof (IGRpoint));
  blinpt2[X] = blinpt1[X] + wvmat[XCOMP_BLINE];
  blinpt2[Y] = blinpt1[Y] + wvmat[YCOMP_BLINE];
  blinpt2[Z] = blinpt1[Z] + wvmat[ZCOMP_BLINE];
  blin.point1 = blinpt1;
  blin.point2 = blinpt2;
  
  numpts = py->num_points;
  pts = (IGRpoint *)py->points;
  seg = pts[numpts-2];
  if (seg[X1] < seg[X2])
    {
    segrng[XMIN] = seg[X1];
    segrng[XMAX] = seg[X2];
    }
  else
    {
    segrng[XMIN] = seg[X2];
    segrng[XMAX] = seg[X1];
    }
  if (seg[Y1] < seg[Y2])
    {
    segrng[YMIN] = seg[Y1];
    segrng[YMAX] = seg[Y2];
    }
  else
    {
    segrng[YMIN] = seg[Y2];
    segrng[YMAX] = seg[Y1];
    }
  if (seg[Z1] < seg[Z2])
    {
    segrng[ZMIN] = seg[Z1];
    segrng[ZMAX] = seg[Z2];
    }
  else
    {
    segrng[ZMIN] = seg[Z2];
    segrng[ZMAX] = seg[Z1];
    }

  clrpoint = FALSE;
  MAlncuberel (&msg, &blin, &segrng[XMIN], &segrng[XMAX], &pixtol, &relation);
  EMerr_hndlr (EMSerror (msg), stat_func, FALSE, ret_end);
  if (relation == HIT)
    {
    segpy.num_points = 2;
    segpy.points = seg;
    segcv.poles = (IGRdouble *)segpoles;
    segcv.knots = segknots;
    EMcnvtpybsn (&msg, 3, &segpy, &segcv);
    EMerr_hndlr (EMSerror (msg), stat_func, FALSE, ret_end);
    
    BSmdptcvbx (&segcv, blinpt1, blinpt2, pixtol, &dumpar, dumpt, &relation,
     &msg);
    EMerr_hndlr (msg != BSSUCC, stat_func, FALSE, ret_end);
    if (relation == HIT)
      clrpoint = TRUE;
    }

  if (clrpoint)
    {
    py->num_points--;

    bpy = buff_info->buff.geometry.polyline;
    bpy->num_points = 2;
    bpy->points = seg;
    stat_func = dp$display (msg = &msg, osnum = buff_info->md_env->md_id.osnum,
                 objid = buff_info->md_env->md_id.objid, mode = GRbe,
                 num_elem = 1, buffer = &buff_info->buff);
    if (!stat_func)
      goto ret_end;
    }
  }

 stat_func = dp$erase_hilite (msg = &msg);
 if (!stat_func)
     goto ret_end;

 stat_func = cursor (newpt, CLEAR_STREAM);
 if (!stat_func)
   goto ret_end;

 *num_buffs = 0;
 *outflags |= DP_DONT_ERASE;

ret_end:
  return (stat_func);
}


static IGRboolean cursor (atpt, type)
struct EX_button *atpt;
IGRshort type;
{
  IGRboolean stat_func;
  IGRshort wvpmattyp, win_no, scrpt[2];
  IGRint one = 1;
  IGRdouble d_dittol;
  IGRint dittol;
  IGRlong msg_loc;
  IGRpoint dpt;
  IGRmatrix wvpmat;
  IGRint sts = 0;
  struct WLpoint points[5];
  extern IGRboolean EMgetwininfo(), MAoptsxform();

  /*
   * Added following code to address WL impact. SY. 12/17/93.
   */
  IGRint num_wins, i;
  IGRint wins[EX_MAX_WINDOW];

  EMget_active_lwins(&num_wins, wins);
  for (i = 0; i < num_wins; i++)
  {
      WLset_drawing_mode( wins[i], WL_HILITE_DRAW );
  }

  stat_func = TRUE;

  /*
   * Obtain the transformation matrix for this window for going from
   * world to screen coordinates.
   */

  stat_func = EMgetwininfo (atpt->objid, atpt->osnum, NULL, NULL, wvpmat,
			    &wvpmattyp, &win_no, NULL, &d_dittol, NULL);
  if (!stat_func)
    goto ret_end;

  dittol = d_dittol;

  /*
   * Transform the button point to screen cooridinates
   */

  stat_func = MAoptsxform (&msg_loc, &one, &wvpmattyp, wvpmat, &atpt->x, 
			   dpt);
  if (!stat_func)
    goto ret_end;
  scrpt[X] = dpt[X];
  scrpt[Y] = dpt[Y];

  /* Draw the cursor at this point setting the weight and the style. */
  /* This is done for WL layer */

  /*
   * Do not do the following so that dp$erase_hilite will erase the
   * highlight cursor. SY. 12/17/93.
   */
  /*
  sts = WLpack_index_colorref( IGE_LOGICAL_HILITE, (WLcolorref *)&col_ref,
			       (WLuint32)FALSE );
  if( sts != WL_SUCCESS)
  {     
#ifdef DEBUG
      fprintf(stderr, "Error packing index colorref; Error %d\n", sts);
#endif
  }
  */

  /*
   * Comment out the following code. See comments above.  SY. 12/17/93.
   */
  /*
  for (i = 0; i < num_wins; i++)
  {
      sts = WLset_active_symbology((WLuint32) wins[i], (WLcolorref) col_ref,
				   (WLuint32) DP_SOLID_LINE_STYLE,
				   (WLuint16 ) 0xffff, (int) 0,
				   WL_SYMB_CHANGE_STYLE | WL_SYMB_CHANGE_WEIGHT| WL_SYMB_CHANGE_COLOR);
      if( sts != WL_SUCCESS)
      {     
#ifdef DEBUG
	  fprintf(stderr, "Error setting active symbology; Error %d\n", sts);
#endif
      }
  }
  */

  if(type == GENERATE_STREAM)
  {
     points[0].x = scrpt[X]-dittol; points[0].y = scrpt[Y]-dittol;
     points[1].x = scrpt[X]+dittol; points[1].y = scrpt[Y]+dittol;
     points[2].x = scrpt[X]+dittol; points[2].y = scrpt[Y]-dittol;
     points[3].x = scrpt[X]-dittol; points[3].y = scrpt[Y]+dittol;
     /*
      * Have to do this for each window. SY. 12/17/93.
      */
     for (i = 0; i < num_wins; i++)
     {
	 WLdraw_2D_line_string((WLuint32) wins[i], (int) 2, points);
	 WLdraw_2D_line_string((WLuint32) wins[i], (int) 2, points + 2);
	 if(sts != WL_SUCCESS)
	 {     
#ifdef DEBUG
	     fprintf(stderr, "Error drawing 2D line string; Error %d\n", sts);
#endif
	 }
     }
  }
  else 
  {
     points[0].x = scrpt[X]-dittol; points[0].y = scrpt[Y]-dittol;
     points[1].x = scrpt[X]+dittol; points[1].y = scrpt[Y]-dittol;
     points[2].x = scrpt[X]+dittol; points[2].y = scrpt[Y]+dittol;
     points[3].x = scrpt[X]-dittol; points[3].y = scrpt[Y]+dittol;
     points[4].x = scrpt[X]-dittol; points[4].y = scrpt[Y]-dittol;
     /*
      * Have to do this for each window. SY. 12/17/93.
      */
     for (i = 0; i < num_wins; i++)
     {
	 WLdraw_2D_line_string((WLuint32) wins[i], (int) 5,  points);
	 if(sts != WL_SUCCESS)
	 {     
#ifdef DEBUG
	     fprintf(stderr, "Error drawing 2D line string; Error %d\n", sts);
#endif
	 }
     }
  }

  /*
   * Have to do this for each window. SY. 12/17/93.
   */
  for (i = 0; i < num_wins; i++)
  {
      sts = WLflush((WLuint32) wins[i] );
  }
  if(sts != WL_SUCCESS)
  {     
#ifdef DEBUG
    fprintf(stderr, "Error flushing the graphics pipeline; Error %d\n", sts);
#endif
  }
ret_end:
  return (stat_func);
}

/*
 * This function returns the number of current active logical windows
 * and their ids. This is needed to be used with WL routines.
 * 12/10/93 : SY : Creation.
 */
IGRint EMget_active_lwins(num_wins, wins)
IGRint *num_wins, *wins;
{
    IGRlong msg, nbytes_ret, which_error;
    IGRint sts, i;
    struct GRid windows[EX_MAX_WINDOW];
    struct var_list list[2];

    /*
     * number of active windows
     */
    sts = dp$get_gragad_id(msg = &msg,
			   name = "*",
			   type_gragad = ALL_GG_CLASSES | GG_WIN_ON | ACTIVE_GG,
			   array_size = EX_MAX_WINDOW,
			   numberofids = num_wins,
			   found_GRids = windows);

    for (i = 0; i < *num_wins; i++)
    {
	/* get the window number */
	list[0].var = WIN_NO;
	list[0].var_ptr = (IGRchar *) &wins[i];
	list[0].num_bytes = sizeof(WLuint32);
	list[0].bytes_returned = &nbytes_ret;

	list[1].var = END_PARAM;
	    
	sts = dp$inq_set_gragad(msg = &msg,
				gragad_objid = windows[i].objid,
				osnum = windows[i].osnum,
				which_error = &which_error,
				var_list = list);
    }
    return sts;
}

end implementation ECdgts;

