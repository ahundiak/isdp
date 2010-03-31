/* ###################   APOGEE COMPILED   ################## */
/*

 History
 
 08/14/94 : scw : clarified sleep method
 28 May 92 : Tapadia : Modified for message sub system compliance
 July 6,90:Inasu: Fix for TR 90n1738.

 10/17/89 : rlw : Modified such that event generator logic will not
                  put RO element on the queue if a write command is waiting
                  for an element.

12 Jun 1989 jBk Moved UI_message from wakeup to execute;

                enhanced wakeup to send to self wrt parent.

22 May 1989 jBk Removed extern IGRlong GRgetevent () declaration;

                changed comments referring to GRlclocate to
                lc$locate.

 07/28/87 : jBk : Moved around some inclusions and definitions.
 01/06/88 : rlw : Rewritten to conform to ems verison 1.1.
                  I believe that Brooke originally wrote this command.

 */

class implementation ECparatpt;

#include "EMS.h"

%safe
#include <math.h>
%endsafe

#define REGULAR_CURVE   0
#define REGULAR_SURFACE 1
#define EVENT_CURVE     2
#define EVENT_SURFACE   3

#define START                   0
#define GET_ELEMENT             1
#define GET_INFO                2
#define PROCESS_POINT           3
#define GET_V_VALUE             4
#define PROCESS_PARAMETERS      5

#define ERROR(sts_stupid, error_number, error_message)\
 {\
  if(!(sts_stupid & 1))\
   {\
    *response = TERMINATE;\
    return(OM_E_ABORT);\
   }\
 }

#include "ems_m_inc.h"
#include "local_dsp.h"
#include "OMmacros.h"
#include "EC_M.h"
#include "EC_S.h"
#include "EC_P.h"
#include "EC_I.h"
#include "ECmsg.h"
#include "ASmsg.h"
#include "grmsg.h"

from GRvg       import EMptatpr;
from GRgraphics import GRdisplay;

extern OMuword OPP_GRbspline_class_id;
extern OMuword OPP_EMSsubbs_class_id;

method super_cmd.sleep(int pos)
{
 IGRlong        i, msg, sts, *response;

 response = &i;

 ex$message(msgnumb = EMS_P_ClearPromptField);
 ex$message(msgnumb = EMS_I_ClearStatusField);
 ex$message(msgnumb = EM_M_ClearMessageField);
 sts = dp$erase_hilite(msg = &msg);
 ERROR(sts, msg, "dp$erase_hilite error")
 return(OM_S_SUCCESS);
}

method wakeup(int pos)
{
 IGRlong        i, msg, sts, *response;
 enum           GRdpmode DisplayMode;

 response = &i; 
 sts = om$send (
    mode = OM_e_wrt_parent,
    msg = message ECparatpt.wakeup (pos),
    targetid = my_id
 );
 ERROR (sts, msg, "wakeup parent");

 if (me->have_element)
  {
   DisplayMode = GRhd;
   sts = om$send(
     msg = message GRgraphics.GRdisplay(
      &msg,
      &me->element.module_info.md_env.matrix_type,
      me->element.module_info.md_env.matrix, 
      &DisplayMode,
      &me->element.module_info.md_id),
     targetid = me->element.located_obj.objid,
     targetos = me->element.located_obj.osnum);
    ERROR(sts, msg, "GRdisplay error")
  }
 return(OM_S_SUCCESS);
}

method execute(int *response; char *response_data; int pos)
{
 IGRchar        locate_prompt[80], accept_prompt[80], relocate_prompt[80];
 OMuword        r_classes[5], e_classes[5];
 OM_S_CLASSLIST rtree_classes, eligible_classes;
 IGRlong        sts, msg, mask, size, number_of_parameters = 0;
 IGRlong        object_was_located, display_flag, locate_mask, accept_mask;
 IGRpoint       point;
 struct         GRparms *geom_parms;
 struct         GRlc_locate attributes;
 struct         GRevent event, accept_event;
 IGRchar	my_tmp_buff[20];
/*
 * Initialize
 */
 size = sizeof(event);

 switch (me->mytype)
  {
   case REGULAR_CURVE:
    ex$message(msgnumb = EM_M_DisCurParaPt);
    break;
   case REGULAR_SURFACE:
    ex$message(msgnumb = EM_M_DisSurParaPt);
    break;
   case EVENT_CURVE:
    ex$message(msgnumb = EM_M_PtAtCurPara);
    break;
   case EVENT_SURFACE:
    ex$message(msgnumb = EM_M_PtAtSurPara);
    break;
  } /* switch (me->mytype) */

/*
 * Enter infinite loop
 */
 do
  {
   switch(ME.super_cmd->state)
    {
/*
 * Room for growth
 */
     case START:
      me->state = 1;
/*
 * Get the curve or surface
 */
     case GET_ELEMENT:
      switch (me->mytype)
       {
        case REGULAR_CURVE:
        case EVENT_CURVE:
         ex$message ( buff = locate_prompt, msgnumb = AS_P_IdCurve );
         ex$message ( buff = accept_prompt, msgnumb = GR_P_Acc );
         ex$message ( buff = relocate_prompt, msgnumb = EMS_I_CvNotLocated );

         strcpy(attributes.classes, "GRbspline");
         r_classes[0] = OPP_GRbspline_class_id;
         e_classes[0] = OPP_GRbspline_class_id;
         break;
        case REGULAR_SURFACE:
        case EVENT_SURFACE:
         ex$message ( buff = locate_prompt, msgnumb = EMS_P_00031 );
         ex$message ( buff = accept_prompt, msgnumb = GR_P_Acc );
         ex$message ( buff = relocate_prompt, msgnumb = EMS_I_00011 );

         strcpy(attributes.classes, "EMSsubbs");
         r_classes[0] = OPP_EMSsubbs_class_id;
         e_classes[0] = OPP_EMSsubbs_class_id;
         break;
       } /* switch (me->mytype) */
      locate_mask = GRm_DATA | GRm_BACK_UP;
      accept_mask = GRm_DATA;
      display_flag = 
       ONE_WINDOW               |       /* Hilite in only one window */
       ELEM_HILIGHT             |       /* Hilite the whole element */
       NO_PROJ_ACCEPT_POINT     |       /* Don't project the accept point */
       ACC_REJ_CYCLE            |       /* Run through accept reject cycle */
       RELOCATE                 |       /* Relocate if none found */
       LC_REGULAR_HIGHLIGHT     |       /* Use regular hilite not 1/2 */
       LC_ERASE_ALL;                    /* Erase hilite on reject */
      if ((me->mytype == EVENT_CURVE) ||
          (me->mytype == EVENT_SURFACE))
       display_flag |= LC_Retrieve_Criteria;
      attributes.properties = 
       LC_LC_ONLY               |       /* Locate locatable objects */
       LC_DP_ONLY               |       /* Locate displayable objects */
       IGN_MOD_BIT              |       /* Ignore modified and new props */
       LC_PLANAR_NON_PLANAR     |       /* Planar or not */
       LC_RW;                           /* This is a read operation */
      attributes.owner_action = 
       LC_RIGID_COMP  |
       LC_FLEX_COMP   |
       LC_REF_OBJECTS |                 /* Objects in ref. files are O.K. */
       LC_NO_REF_HEADER;                /* No reference file headers */
      rtree_classes.w_count = 1;
      rtree_classes.w_flags = OM_CLST_subclass;
      rtree_classes.p_classes = &r_classes[0];
      eligible_classes.w_count = 1;
      eligible_classes.w_flags = OM_CLST_subclass;
      eligible_classes.p_classes = &e_classes[0];
      sts = lc$locate(
        rc =                    &object_was_located,
        event1 =                &event,
        event2 =                &accept_event,
        mask1 =                 locate_mask,
        mask2 =                 accept_mask,
        display_flag =          display_flag,
        unhilight_mode =        (enum GRdpmode ) GRhd,  /* Don't unhilite */
        locate_prompt =         locate_prompt,
        acc_prompt =            accept_prompt,
        relocate_prompt =       relocate_prompt,
        attributes =            &attributes,
        stack =                 &me->locate_stack,
        rtree_classes =         &rtree_classes,
        eligible_classes =      &eligible_classes);
       ERROR(sts, object_was_located, "lc$locate error")
      if (!object_was_located)
       {
        if (event.response == EX_BACK_UP)
         me->state = START;
        else
         return(OM_S_SUCCESS);
       }
      else
       {
        me->have_element = TRUE;
        me->element = accept_event.located_object[0];
        me->state = GET_INFO;
       }
      break;
/*
 * Get the point or keyin value
 */
     case GET_INFO:
      mask = GRm_DATA | GRm_VALUE | GRm_BACK_UP;
      sts = co$getevent(
        msg =           &msg,
        event_mask =    mask,
	msgnum =  EMS_P_EnPtKyInUParm,
        value_type =    GRIO_SCALAR,
        response =      response,
        response_data = response_data,
        event =         &event);
       ERROR(sts, msg, "co$getevent error")
      ex$message(msgnumb = EMS_I_ClearStatusField);
      if (event.response == GR_UNKNOWN_TYPE)
       return(OM_S_SUCCESS);
      else if (event.response == EX_BACK_UP)
       {
        me->have_element = FALSE;
        sts = dp$erase_hilite(msg = &msg);
         ERROR(sts, msg, "dp$erase_hilite error")
        me->state = GET_ELEMENT;
       }
      else if (event.response == EX_DATA)
       {
        sts = EFpoint_on_object(
          &me->element,
          &event,
          my_id,
          &msg);
         ERROR(sts, msg, "EFpoint_on_object error")
        me->state = PROCESS_POINT;
       }
      else if (msg == GRw_no_value)
	ex$message(msgnumb = EMS_I_00006)
      else
       {
        me->uv[0] = event.event.value;         
        switch (me->mytype)
         {
          case REGULAR_CURVE:
          case EVENT_CURVE:
           me->state = PROCESS_PARAMETERS;
           break;
          case REGULAR_SURFACE:
          case EVENT_SURFACE:
           me->state = GET_V_VALUE;
           break;
         } /* switch (me->mytype) */
       }
      break;
/*
 * Build the point event
 */
     case PROCESS_POINT:
      geom_parms = &event.located_object[0].geom_parms;
      switch (me->mytype)
       {
        case REGULAR_CURVE:
        case EVENT_CURVE:
	ex$message(msgnumb = EMS_P_UValue, type = "%lg",
		var = `geom_parms->u`, buff = locate_prompt);
         break;

        case REGULAR_SURFACE:
        case EVENT_SURFACE:
	ex$message(msgnumb = EMS_P_UValue, type = "%lg ",
		var = `geom_parms->u`, buff = locate_prompt);
	ex$message(msgnumb = EMS_P_VValue, type = "%lg",
		var = `geom_parms->v`, buff = my_tmp_buff);
	strcat(locate_prompt, my_tmp_buff);
         break;
       } /* switch (me->mytype) */

      ex$message(field = ERROR_FIELD, in_buff = locate_prompt);
      ex$message(msgnumb = EMS_P_XValue, buff = locate_prompt);
      sts = EFconvert_to_user_units(
        event.event.button.x,
        FALSE,
        locate_prompt,
        &msg);
       ERROR(sts, msg, "EFconvert_to_user_units")
      ex$message(msgnumb = EMS_P_YValue, buff = my_tmp_buff);
      strcat(locate_prompt, my_tmp_buff);
      sts = EFconvert_to_user_units(
        event.event.button.y,
        FALSE,
        locate_prompt,
        &msg);
       ERROR(sts, msg, "EFconvert_to_user_units")
      ex$message(msgnumb = EMS_P_ZValue, buff = my_tmp_buff);
      strcat(locate_prompt, my_tmp_buff);
      sts = EFconvert_to_user_units(
        event.event.button.z,
        TRUE,
        locate_prompt,
        &msg);
       ERROR(sts, msg, "EFconvert_to_user_units")

      ex$message(field = KEYIN_FIELD, justification = LEFT_JUS,
		in_buff = locate_prompt);	 

      switch (me->mytype)
       {
        case REGULAR_CURVE:
        case REGULAR_SURFACE:
         LOCAL_DISPLAY(
           sts, 
           &msg, 
           1,
           &event.event.button.x,
           TRUE)
          ERROR(sts, msg, "LOCAL_DISPLAY error")
         me->state = GET_INFO;
         break;
        case EVENT_CURVE:
        case EVENT_SURFACE:
         sts = ex$putque(
           msg = &msg,
           response = &event.response,
           byte = &size,                        /* Should be slightly less */
	   buffer = (char *)&event.event );
          ERROR(sts, msg, "ex$putque error")
         *response = TERMINATE;
         return(OM_S_SUCCESS);
       } /* switch (me->mytype) */
      break;
/*
 * Get the V value
 */
     case GET_V_VALUE:
      mask = GRm_VALUE | GRm_BACK_UP;
      sts = co$getevent(
        msg =           &msg,
        event_mask =    mask,
	msgnum = EMS_P_KyInVParm,
        value_type =    GRIO_SCALAR,
        response =      response,
        response_data = response_data,
        event =         &event);
       ERROR(sts, msg, "co$getevent error")
      ex$message(msgnumb = EMS_I_ClearStatusField);
      if (event.response == GR_UNKNOWN_TYPE)
       return(OM_S_SUCCESS);
      else if (event.response == EX_BACK_UP)
       me->state = GET_INFO;
      else if (msg == GRw_no_value)
	ex$message(msgnumb = EMS_I_00006)
      else
       {
        me->uv[1] = event.event.value;         
        me->state = PROCESS_PARAMETERS;
       }
      break;
/*
 * Get the data point for the parameter value(s)
 */
     case PROCESS_PARAMETERS:
      switch (me->mytype)
       {
        case EVENT_CURVE:
        case REGULAR_CURVE:
         number_of_parameters = 1;
         break;
        case EVENT_SURFACE:
        case REGULAR_SURFACE:
         number_of_parameters = 2;
         break;
       } /* switch (me->mytype) */
      sts = om$send(
        msg = message GRvg.EMptatpr(
         &msg,
         &me->element.module_info.md_env.matrix_type,
         me->element.module_info.md_env.matrix, 
         me->uv,
         number_of_parameters,
         point),
        targetid = me->element.located_obj.objid,
        targetos = me->element.located_obj.osnum);
      if (! (1 & sts))
       {
	ex$message(msgnumb = EMS_S_ParValueOutOfRange);
        me->state = GET_INFO;
       }
      else
       {
        event.response = EX_DATA;
        OM_BLOCK_MOVE(
         point,
         &event.event.button.x,
         sizeof(IGRpoint));
        event.subtype = GRst_PROJECT;
        event.num_id = 1;
        event.num_val = 0;
        event.located_object[0] = me->element;
        OM_BLOCK_MOVE(
         point,
         event.located_object[0].proj_pnt,
         sizeof(IGRpoint));
        geom_parms = &event.located_object[0].geom_parms;
        geom_parms->u = me->uv[0];
        geom_parms->v = me->uv[1];
        geom_parms->polygon_inx = 0;
        me->state = PROCESS_POINT;
       }
      break;
/*
 * Something has messed up our state table
 */
     default:
      ERROR(OM_E_ABORT, 0, "Default state reached")
    }
  }
 while(TRUE);
}

end implementation ECparatpt;
