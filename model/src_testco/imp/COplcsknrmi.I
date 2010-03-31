/* ###################   APOGEE COMPILED   ################## */
 /*
  1) Select surface
  2) Accept with point to determine which side of the surface the
     cross section should be on (This point is displayed)
  3) Select trace curve
  4) Accept with starting end (This point is displayed.  Note that
     the dynamics are performed on this end of the trace)
  5) Select orientation view (Cross section is in this view)
  6) Select cross section
  7) Accept with reference point (This point is rubberbanded about
     the trace starting end)
  8) Input x axis point wrt reference point (This point is rubberbanded
     about the reference point)
  9) Input x vector point wrt trace starting end to determine how
     local x system lines up or moveon to use curve tangent cross surface
     normal.  If a vector is given then the cross section will not
     twist with the trace (same as absolute orientation for place skinning
     surface command).
 10) Data point to toggle/move on to accept (The cross section is
     displayed on site using a right-handed system.  If the user toggles
     then it is displayed using a left-handed system.)

 rlw : ??/??/87 : Thrown together for the GM demo
 rlw : 05/20/87 : Put in erase highlight stuff, took out print statements
 rlw : 01/03/87 : Converted to EMS 1.1 - Changed masks, routine names,
                  locate code, and reworked some.
 rlw : 04/13/88 : Modified to use message subsystem.
 jBk : 05/22/89 : Changed from use of GRgetevent to co$getevent;
                  changed comments from referring to GRlclocate to
                  refer to lc$locate.
 jBk : 06/12/89 : Moved UI_message from wakeup to execute;
                  enhanced wakeup to send to self wrt parent.
 rlw : 10/24/89 : Modified a message key.
 rlw : 11/17/89 : Added prompt to get x vector
 Tapadia 5/27/92  Modified for message sub system compliance
 scw : 08/14/94 : clarified sleep method
 */

class implementation COplcsknrm;

#include "EMS.h"
#define DEBUG 0
#if DEBUG
#include <stdio.h>      /* Needed for print statements */
#endif
# ifndef griodef_include
# include "griodef.h"
# endif
# ifndef igrtypedef_include
# include "igrtypedef.h"
# endif
# ifndef igrdp_include
# include "igrdp.h"
# endif
# ifndef dpstruct_include
# include "dpstruct.h"
# endif
#include "igrdef.h"     /* Has IGRPY */
# ifndef griodef_include
# include "griodef.h"
# endif

#include "EC_F.h"
#include "EC_I.h"
#include "EC_M.h"
#include "EC_P.h"
#include "local_dsp.h"  /* Local display macro */
#include "exmacros.h"   /* Has ex$putque */
#include "dpmacros.h"   /* Has dp$erase_hilite */
#include "msmacros.h"   /* Has message subsystem macros */
# include "griomacros.h"    /* co$getevent */

#define GENERAL 4                       /* A general matrix */
#if DEBUG 
#define ERROR(sts_stupid, error_number, error_message)\
 {\
  if(!(sts_stupid & 1))\
   {\
    *response = TERMINATE;\
    fprintf(stderr, "\n*************************");\
    fprintf(stderr, "\nIn COplcsknrm error condition encountered");\
    fprintf(stderr, "\n%s", error_message);\
    fprintf(stderr, "\nError number %d", error_number);\
    om$report_error(sts = sts_stupid);\
    fprintf(stderr, "\n*************************");\
    return(OM_E_ABORT);\
   }\
 }
#else
#define ERROR(sts_stupid, error_number, error_message)\
  if(!(sts_stupid & 1)) goto error_abort;
#endif 

from GRgraphics import GRdisplay;
from GRcurve import GRendpoint;
from EMSgenbs import EMmove_cross_section_normal_to_sf;
from IGEgragad import DPinrot;

extern OMuword OPP_GRbspline_class_id;
extern OMuword OPP_GRcurve_class_id;
extern OMuword OPP_EMSsubbs_class_id;
extern OMuword OPP_EMSgenbs_class_id;

method super_cmd.sleep(int pos)
{
 IGRboolean     draw_background = FALSE;
 IGRlong        msg, sts;

 sts = dp$erase_hilite(msg = &msg);
  ERROR(sts, msg, "dp$erase_hilite error")
 if (me->have_surface && me->have_side_pnt)
  {
   LOCAL_DISPLAY(sts, &msg, 1, me->side_pnt, draw_background)
    ERROR(sts, msg, "LOCAL_DISPLAY error")
  }
 if (me->have_trace && me->have_trace_pnt)
  {
   LOCAL_DISPLAY(sts, &msg, 1, me->trace.proj_pnt, draw_background)
    ERROR(sts, msg, "LOCAL_DISPLAY error")
  }
 if (me->have_ref_pnt)
  {
   LOCAL_DISPLAY(sts, &msg, 1, me->ref_pnt, draw_background)
    ERROR(sts, msg, "LOCAL_DISPLAY error")
  }
 if (me->have_vector)
  {
   LOCAL_DISPLAY(sts, &msg, 2, me->vector_pnts, draw_background)
    ERROR(sts, msg, "LOCAL_DISPLAY error")
  }
 if (me->absolute_orientation)
  {
   LOCAL_DISPLAY(sts, &msg, 2, me->absolute_pnts, draw_background)
    ERROR(sts, msg, "LOCAL_DISPLAY error")
  }
 return(OM_S_SUCCESS);
error_abort:
 ex$message(msgnumb = EMS_F_0002)
 return(OM_E_ABORT);
}

method wakeup(int pos)
{
 IGRboolean     draw_background = TRUE;
 IGRlong        msg, sts;
 enum           GRdpmode DisplayMode;

 sts = om$send (
    mode = OM_e_wrt_parent,
    msg = message COplcsknrm.wakeup (pos),
    targetid = my_id);
 ERROR (sts, msg, "wakeup parent");

 DisplayMode = GRhd;
 if (me->have_surface)
  {
   sts = om$send(msg = message GRgraphics.GRdisplay(&msg,
          &me->surface.module_info.md_env.matrix_type,
          me->surface.module_info.md_env.matrix, 
          &DisplayMode,
          &me->surface.module_info.md_id),
          targetid = me->surface.located_obj.objid,
          targetos = me->surface.located_obj.osnum);
    ERROR(sts, msg, "GRdisplay error")
   if (me->have_side_pnt)
    {
     LOCAL_DISPLAY(sts, &msg, 1, me->side_pnt, draw_background)
      ERROR(sts, msg, "LOCAL_DISPLAY error")
    }
  }
 if (me->have_trace)
  {
   sts = om$send(msg = message GRgraphics.GRdisplay(&msg,
          &me->trace.module_info.md_env.matrix_type,
          me->trace.module_info.md_env.matrix, 
          &DisplayMode,
          &me->trace.module_info.md_id),
          targetid = me->trace.located_obj.objid,
          targetos = me->trace.located_obj.osnum);
    ERROR(sts, msg, "GRdisplay error")
   if (me->have_trace_pnt)
    {
     LOCAL_DISPLAY(sts, &msg, 1, me->trace.proj_pnt, draw_background)
      ERROR(sts, msg, "LOCAL_DISPLAY error")
    }
  }
 if (me->have_cross_section)
  {
   sts = om$send(msg = message GRgraphics.GRdisplay(&msg,
          &me->cross_section.module_info.md_env.matrix_type,
          me->cross_section.module_info.md_env.matrix, 
          &DisplayMode,
          &me->cross_section.module_info.md_id),
          targetid = me->cross_section.located_obj.objid,
          targetos = me->cross_section.located_obj.osnum);
    ERROR(sts, msg, "GRdisplay error")
  }
 if (me->have_ref_pnt)
  {
   LOCAL_DISPLAY(sts, &msg, 1, me->ref_pnt, draw_background)
    ERROR(sts, msg, "LOCAL_DISPLAY error")
  }
 if (me->have_vector)
  {
   LOCAL_DISPLAY(sts, &msg, 2, me->vector_pnts, draw_background)
    ERROR(sts, msg, "LOCAL_DISPLAY error")
  }
 if (me->absolute_orientation)
  {
   LOCAL_DISPLAY(sts, &msg, 2, me->absolute_pnts, draw_background)
    ERROR(sts, msg, "LOCAL_DISPLAY error")
  }
 return(OM_S_SUCCESS);
error_abort:
 ex$message(msgnumb = EMS_F_0002)
 return(OM_E_ABORT);
}


method execute(int *response; char *response_data; int pos)
{
 IGRshort       matrix_type, status;
 IGRboolean     was_curve_on_surface, EFskinning_matrix_support();
 IGRlong        sts, msg, mask, size;
 IGRlong        object_was_located, display_flag, locate_mask, accept_mask;
 enum           GRdpmode DisplayMode;
 struct         GRlc_locate attributes;
 struct         GRevent event, accept_event;
/*
 * Initialize
 */
 size = sizeof(event);
 ex$message(msgnumb = EM_M_0095)
/*
 * Enter infinite loop
 */
 do
  {
   switch(me->state)
    {
/*
 * Room for growth
 */
     case 0:
      me->have_surface = FALSE;
      me->have_side_pnt = FALSE;
      me->have_trace = FALSE;
      me->have_trace_pnt = FALSE;
      me->have_cross_section = FALSE;
      me->have_ref_pnt = FALSE;
      me->have_vector = FALSE;
      me->is_left_hand_system = FALSE;
      me->absolute_orientation = FALSE;
      me->state = 1;
/*
 * Get the surface the cross section will move normal to
 */
     case 1: 
      locate_mask = GRm_DATA | GRm_BACK_UP;
      accept_mask = GRm_DATA;
      {
       OMuword          r_classes[5], e_classes[5];
       OM_S_CLASSLIST   rtree_classes, eligible_classes;

       display_flag = 
        ONE_WINDOW              |       /* Hilite in only one window */
        ELEM_HILIGHT            |       /* Hilite the whole element */
        NO_PROJ_ACCEPT_POINT    |       /* Don't project the accept point */
        ACC_REJ_CYCLE           |       /* Run through accept reject cycle */
        RELOCATE                |       /* Relocate if none found */
        LC_REGULAR_HIGHLIGHT    |       /* Use regular hilite not 1/2 */
        LC_ERASE_ALL;                   /* Erase hilite on reject */
       attributes.properties = 
        LC_LC_ONLY              |       /* Locate locatable objects */
        LC_DP_ONLY              |       /* Locate displayable objects */
        IGN_MOD_BIT             |       /* Ignore modified and new props */
        LC_PLANAR_NON_PLANAR    |       /* Planar or not */
        LC_RW;                          /* This is a read operation */
       attributes.owner_action = 
        LC_RIGID_COMP  |
        LC_FLEX_COMP   |
        LC_REF_OBJECTS |                /* Objects in ref. files are O.K. */
        LC_NO_REF_HEADER;               /* No reference file headers */
       rtree_classes.w_count = 1;
       rtree_classes.w_flags = OM_CLST_subclass;
       rtree_classes.p_classes = &r_classes[0];
       eligible_classes.w_count = 1;
       eligible_classes.w_flags = OM_CLST_subclass;
       eligible_classes.p_classes = &e_classes[0];
       r_classes[0] = OPP_EMSsubbs_class_id;
       e_classes[0] = OPP_EMSsubbs_class_id;
       sts = lc$locate(
         rc =                   &object_was_located,
         event1 =               &me->locate_event,
         event2 =               &accept_event,
         mask1 =                locate_mask,
         mask2 =                accept_mask,
         display_flag =         display_flag,
         unhilight_mode =       (enum GRdpmode ) GRhd,  /* Don't unhilite */
         locate_key =           EMS_P_00031,
         acc_key =              EMS_P_00115,
         relocate_key =         EMS_I_00011,
         attributes =           &attributes,
         stack =                &me->locate_stack,
         rtree_classes =        &rtree_classes,
         eligible_classes =     &eligible_classes);
       ERROR(sts, object_was_located, "lc$locate error")
      }
      if (!object_was_located)
       {
        if (me->locate_event.response == EX_BACK_UP)
         me->state = 0;
        else
         return(OM_S_SUCCESS);
       }
      else
       {
        me->have_surface = TRUE;
        me->surface = accept_event.located_object[0];
        sts = ex$putque(msg = &msg, response = response,
                        byte = &size, buffer = (char *)&accept_event.event);
         ERROR(sts, msg, "ex$putque error")
        me->state = 2;
       }
      break;
/*
 * Get the normal point
 */
     case 2:
      mask = GRm_DATA | GRm_BACK_UP;
      sts = co$getevent (
            msg = &msg,
            event_mask = mask,
            msgnum = EMS_P_00112,
            response = response,
            response_data = response_data,
            event = &event);
      ERROR(sts, msg, "co$getevent error")
      ex$message(msgnumb = EMS_I_00000)
      if (event.response == GR_UNKNOWN_TYPE)
       return(OM_S_SUCCESS);
      else if (event.response == EX_BACK_UP)
       {
        me->have_surface = FALSE;
        sts = dp$erase_hilite(msg = &msg);
         ERROR(sts, msg, "dp$erase_hilite error")
        me->state = 1;
       }
      else
       {
        me->have_side_pnt = TRUE;
        me->side_pnt[0] = event.event.button.x;
        me->side_pnt[1] = event.event.button.y;
        me->side_pnt[2] = event.event.button.z;
        LOCAL_DISPLAY(sts, &msg, 1, me->side_pnt, TRUE)
         ERROR(sts, msg, "LOCAL_DISPLAY error")
        me->state = 3;
       }
      break;
/*
 * Get the trace
 */
     case 3: 
      locate_mask = GRm_DATA | GRm_BACK_UP;
      accept_mask = GRm_DATA;
      {
       OMuword          r_classes[5], e_classes[5];
       OM_S_CLASSLIST   rtree_classes, eligible_classes;

       display_flag = 
        ONE_WINDOW              |       /* Hilite in only one window */
        ELEM_HILIGHT            |       /* Hilite the whole element */
        NO_PROJ_ACCEPT_POINT    |       /* Don't project the accept point */
        ACC_REJ_CYCLE           |       /* Run through accept reject cycle */
        RELOCATE                |       /* Relocate if none found */
        LC_REGULAR_HIGHLIGHT    |       /* Use regular hilite not 1/2 */
        LC_ERASE_LOC_ELEMENT;           /* Don't erase hilite */
       attributes.properties = 
        LC_LC_ONLY              |       /* Locate locatable objects */
        LC_DP_ONLY              |       /* Locate displayable objects */
        IGN_MOD_BIT             |       /* Ignore modified and new props */
        LC_PLANAR_NON_PLANAR    |       /* Planarity doesn't matter */
        LC_RW;                          /* I'm only going to read */
       attributes.owner_action = 
        LC_FLEX_COMP   |
        LC_RIGID_COMP  |
        LC_RIGID_OWNER |
        LC_REF_OBJECTS |                /* Objects in ref. files are O.K. */
        LC_NO_REF_HEADER;               /* No reference file headers */
       rtree_classes.w_count = 1;
       rtree_classes.w_flags = OM_CLST_subclass;
       rtree_classes.p_classes = &r_classes[0];
       eligible_classes.w_count = 1;
       eligible_classes.w_flags = OM_CLST_subclass;
       eligible_classes.p_classes = &e_classes[0];
       r_classes[0] = OPP_GRbspline_class_id;
       e_classes[0] = OPP_GRcurve_class_id;
       sts = lc$locate(
         rc =                   &object_was_located,
         event1 =               &me->locate_event,
         event2 =               &accept_event,
         mask1 =                locate_mask,
         mask2 =                accept_mask,
         display_flag =         display_flag,
         unhilight_mode =       (enum GRdpmode ) GRhd,  /* Don't unhilite */
         locate_key =           EMS_P_00118,
         acc_key =              EMS_P_00107,
         relocate_key =         EMS_I_00010,
         attributes =           &attributes,
         stack =                &me->locate_stack,
         rtree_classes =        &rtree_classes,
         eligible_classes =     &eligible_classes);
       ERROR(sts, object_was_located, "lc$locate error")
      }
      if (!object_was_located)
       {
        if (me->locate_event.response == EX_BACK_UP)
         {
          me->have_side_pnt = FALSE;
          LOCAL_DISPLAY(sts, &msg, 1, me->side_pnt, FALSE)
           ERROR(sts, msg, "LOCAL_DISPLAY error")
          me->state = 2;
         }
        else
         return(OM_S_SUCCESS);
       }
      else
       {
        me->have_trace = TRUE;
        me->trace = accept_event.located_object[0];
        sts = ex$putque(msg = &msg, response = response,
                        byte = &size, buffer = (char *)&accept_event.event);
         ERROR(sts, msg, "ex$putque error")
        me->state = 4;
       }
      break;
/*
 * Get a point near the starting end of trace
 */
     case 4:
      mask = GRm_DATA | GRm_BACK_UP;
      sts = co$getevent (
            msg = &msg,
            event_mask = mask,
            msgnum = EMS_P_00077,
            response = response,
            response_data = response_data,
            event = &event);
      ERROR(sts, msg, "co$getevent error")
      ex$message(msgnumb = EMS_I_00000)
      if (event.response == GR_UNKNOWN_TYPE)
       return(OM_S_SUCCESS);
      else if (event.response == EX_BACK_UP)
       {
        me->have_trace = FALSE;
        DisplayMode = GRhe;
        sts = om$send(msg = message GRgraphics.GRdisplay(&msg,
               &me->trace.module_info.md_env.matrix_type,
               me->trace.module_info.md_env.matrix, 
               &DisplayMode,
               &me->trace.module_info.md_id),
               targetid = me->trace.located_obj.objid,
               targetos = me->trace.located_obj.osnum);
         ERROR(sts, msg, "GRdisplay error")
        me->state = 3;
       }
      else
       {
        IGRboolean      status, EFboreline();
        IGRpoint        point1, point2;
        struct          IGRline bore_line;

        bore_line.point1 = &point1[0];
        bore_line.point2 = &point2[0];
        status = EFboreline(&msg, my_id, &event, &bore_line);
         ERROR(status, msg, "EFboreline error")
        sts = om$send(msg = message GRcurve.GRendpoint(&msg,
               &me->trace.module_info.md_env.matrix_type,
               me->trace.module_info.md_env.matrix, 
               &bore_line, me->trace.proj_pnt),
               targetid = me->trace.located_obj.objid,
               targetos = me->trace.located_obj.osnum);
         ERROR(sts, msg, "GRendpoint error")
        me->have_trace_pnt = TRUE;
        LOCAL_DISPLAY(sts, &msg, 1, me->trace.proj_pnt, TRUE)
         ERROR(sts, msg, "LOCAL_DISPLAY error")
        me->state = 5;
       }
      break;
/*
 * Get the orientation view
 */
     case 5:
      mask = GRm_DATA | GRm_BACK_UP;
      sts = co$getevent (
            msg = &msg,
            event_mask = mask,
            msgnum = EMS_P_00110,
            response = response,
            response_data = response_data,
            event = &event);
      ERROR(sts, msg, "co$getevent error")
      ex$message(msgnumb = EMS_I_00000)
      if (event.response == GR_UNKNOWN_TYPE)
       return(OM_S_SUCCESS);
      else if (event.response == EX_BACK_UP)
       {
        LOCAL_DISPLAY(sts, &msg, 1, me->trace.proj_pnt, FALSE)
         ERROR(sts, msg, "LOCAL_DISPLAY error")
        me->have_trace_pnt = FALSE;
        me->state = 4;
       }
      else
       {
        sts = om$send(msg = message IGEgragad.DPinrot(
                       &msg, (IGRdouble *) me->view_matrix),
                      targetid = event.event.button.objid,
                      targetos = event.event.button.osnum);
         ERROR(sts, msg, "DPinrot error")
        me->state = 6;
       }
      break;
/*
 * Get the cross section
 */
     case 6:
      locate_mask = GRm_DATA | GRm_BACK_UP;
      accept_mask = GRm_DATA;
      {
       OMuword          r_classes[5], e_classes[5];
       OM_S_CLASSLIST   rtree_classes, eligible_classes;

       display_flag = 
        ONE_WINDOW              |       /* Hilite in only one window */
        ELEM_HILIGHT            |       /* Hilite the whole element */
        NO_PROJ_ACCEPT_POINT    |       /* Don't project the accept point */
        ACC_REJ_CYCLE           |       /* Run through accept reject cycle */
        RELOCATE                |       /* Relocate if none found */
        LC_REGULAR_HIGHLIGHT    |       /* Use regular hilite not 1/2 */
        LC_ERASE_LOC_ELEMENT;           /* Don't erase hilite */
       attributes.properties = 
        LC_LC_ONLY              |       /* Locate locatable objects */
        LC_DP_ONLY              |       /* Locate displayable objects */
        IGN_MOD_BIT             |       /* Ignore modified and new props */
        LC_PLANAR_NON_PLANAR    |       /* Planarity doesn't matter */
        LC_RW;                          /* I'm only going to read */
       attributes.owner_action = 
        LC_FLEX_COMP   |
        LC_RIGID_COMP  |
        LC_RIGID_OWNER |
        LC_REF_OBJECTS |                /* Objects in ref. files are O.K. */
        LC_NO_REF_HEADER;               /* No reference file headers */
       rtree_classes.w_count = 1;
       rtree_classes.w_flags = OM_CLST_subclass;
       rtree_classes.p_classes = &r_classes[0];
       eligible_classes.w_count = 1;
       eligible_classes.w_flags = OM_CLST_subclass;
       eligible_classes.p_classes = &e_classes[0];
       r_classes[0] = OPP_GRbspline_class_id;
       e_classes[0] = OPP_GRcurve_class_id;
       sts = lc$locate(
         rc =                   &object_was_located,
         event1 =               &me->locate_event,
         event2 =               &accept_event,
         mask1 =                locate_mask,
         mask2 =                accept_mask,
         display_flag =         display_flag,
         unhilight_mode =       (enum GRdpmode ) GRhd,  /* Don't unhilite */
         locate_key =           EMS_P_00163,
         acc_key =              EMS_P_00116,
         relocate_key =         EMS_I_00010,
         attributes =           &attributes,
         stack =                &me->locate_stack,
         rtree_classes =        &rtree_classes,
         eligible_classes =     &eligible_classes);
       ERROR(sts, object_was_located, "lc$locate error")
      }
      if (!object_was_located)
       {
        if (me->locate_event.response == EX_BACK_UP)
         me->state = 5;
        else
         return(OM_S_SUCCESS);
       }
      else
       {
        me->have_cross_section = TRUE;
        me->cross_section = accept_event.located_object[0];
        sts = ex$putque(msg = &msg, response = response,
                        byte = &size, buffer = (char *)&accept_event.event);
         ERROR(sts, msg, "ex$putque error")
        me->state = 7;
       }
      break;
/*
 * Get the reference point
 */
     case 7:
      ex$message(msgnumb = EMS_P_00113)
      EFrblineseg(me->trace.proj_pnt, &me->ActiveDisplay);
      mask = GRm_DATA | GRm_BACK_UP;
      sts = co$getevent (
            msg = &msg,
            event_mask = mask,
            response = response,
            response_data = response_data,
            event = &event);
      ERROR(sts, msg, "co$getevent error")
      ex$message(msgnumb = EMS_I_00000)
      if (event.response == GR_UNKNOWN_TYPE)
       return(OM_S_SUCCESS);
      else if (event.response == EX_BACK_UP)
       {
        me->have_cross_section = FALSE;
        DisplayMode = GRhe;
        sts = om$send(msg = message GRgraphics.GRdisplay(&msg,
               &me->cross_section.module_info.md_env.matrix_type,
               me->cross_section.module_info.md_env.matrix, 
               &DisplayMode,
               &me->cross_section.module_info.md_id),
               targetid = me->cross_section.located_obj.objid,
               targetos = me->cross_section.located_obj.osnum);
         ERROR(sts, msg, "GRdisplay error")
        me->state = 6;
       }
      else
       {
        me->ref_pnt[0] = event.event.button.x;
        me->ref_pnt[1] = event.event.button.y;
        me->ref_pnt[2] = event.event.button.z;
        me->have_ref_pnt = TRUE;
        LOCAL_DISPLAY(sts, &msg, 1, me->ref_pnt, TRUE)
         ERROR(sts, msg, "LOCAL_DISPLAY error")
        me->state = 8;
       }
      break;
/*
 * Get the x vector point
 */
     case 8:
      ex$message(msgnumb = EMS_P_00114)
      EFrblineseg(me->ref_pnt, &me->ActiveDisplay);
      mask = GRm_DATA | GRm_BACK_UP;
      sts = co$getevent (
            msg = &msg,
            event_mask = mask,
            response = response,
            response_data = response_data,
            event = &event);
      ERROR(sts, msg, "co$getevent error")
      ex$message(msgnumb = EMS_I_00000)
      if (event.response == GR_UNKNOWN_TYPE)
       return(OM_S_SUCCESS);
      else if (event.response == EX_BACK_UP)
       {
        me->have_ref_pnt = FALSE;
        LOCAL_DISPLAY(sts, &msg, 1, me->ref_pnt, FALSE)
         ERROR(sts, msg, "LOCAL_DISPLAY error")
        me->state = 7;
       }
      else
       {
        me->vector_pnts[0][0] = me->ref_pnt[0];
        me->vector_pnts[0][1] = me->ref_pnt[1];
        me->vector_pnts[0][2] = me->ref_pnt[2];
        me->vector_pnts[1][0] = event.event.button.x;
        me->vector_pnts[1][1] = event.event.button.y;
        me->vector_pnts[1][2] = event.event.button.z;
        me->have_vector = TRUE;
        LOCAL_DISPLAY(sts, &msg, 2, me->vector_pnts, TRUE)
         ERROR(sts, msg, "LOCAL_DISPLAY error")
        me->state = 9;
       }
      break;
/*
 * Get the x vector point wrt the trace
 */
     case 9:
      ex$message(msgnumb = EMS_P_InXVecPtMoReOri);
      EFrblineseg(me->trace.proj_pnt, &me->ActiveDisplay);
      mask = GRm_DATA | GRm_BACK_UP | GRm_RJT_MOVEON;
      sts = co$getevent(
        msg = &msg,
        event_mask = mask,
        response = response,
        response_data = response_data,
        event = &event);
       ERROR(sts, msg, "co$getevent error")
      ex$message(msgnumb = EMS_I_00000)
      if (event.response == GR_UNKNOWN_TYPE)
       return(OM_S_SUCCESS);
      else if (event.response == EX_BACK_UP)
       {
        me->have_vector = FALSE;
        LOCAL_DISPLAY(sts, &msg, 2, me->vector_pnts, FALSE)
         ERROR(sts, msg, "LOCAL_DISPLAY error")
        me->state = 8;
       }
      else if (event.response == EX_RJT_MOVEON)
       me->state = 10;
      else
       {
        me->absolute_orientation = TRUE;
        me->absolute_pnts[0][0] = me->trace.proj_pnt[0];
        me->absolute_pnts[0][1] = me->trace.proj_pnt[1];
        me->absolute_pnts[0][2] = me->trace.proj_pnt[2];
        me->absolute_pnts[1][0] = event.event.button.x;
        me->absolute_pnts[1][1] = event.event.button.y;
        me->absolute_pnts[1][2] = event.event.button.z;
        LOCAL_DISPLAY(sts, &msg, 2, me->absolute_pnts, TRUE)
         ERROR(sts, msg, "LOCAL_DISPLAY error")
        me->state = 10;
       }
      if (me->state == 10)
       {
        ex$message(msgnumb = EMS_P_00000);
	ex$message(msgnumb = EMS_S_CompSectOnSite);
        status = EFskinning_matrix_support(
          my_id, 
          &me->surface,
          &me->trace,
          &me->cross_section,
          me->side_pnt, 
          me->ref_pnt, 
          me->view_matrix,
          me->vector_pnts,
          (me->absolute_orientation ? me->absolute_pnts : NULL),
          me->cross_section.module_info.md_env.matrix, 
          me->rhs_matrix,
          me->lhs_matrix,
          &msg);
         if ((! (1 & status)) ||
             (! (1 & msg)))
          {
	   ex$message(msgnumb = EMS_S_UnableToCompSec);
           if (me->absolute_orientation)
            {
             LOCAL_DISPLAY(sts, &msg, 2, me->absolute_pnts, FALSE)
              ERROR(sts, msg, "LOCAL_DISPLAY error")
             me->absolute_orientation = FALSE;
            }
           me->state = 9;
          }
       } /* if (me->state == 10) */
      break;
/*
 * Display the section on site and ask the user if he or she wishes
 * to mirror the section
 */
     case 10:
      ex$message(msgnumb = EMS_I_00072)
      matrix_type = GENERAL;
      DisplayMode = GRbd;
      sts = om$send(msg = message GRgraphics.GRdisplay(&msg,
             &matrix_type, (IGRdouble *)
             (me->is_left_hand_system ? me->lhs_matrix : me->rhs_matrix),
             &DisplayMode,
             &me->cross_section.module_info.md_id),
             targetid = me->cross_section.located_obj.objid,
             targetos = me->cross_section.located_obj.osnum);
       ERROR(sts, msg, "GRdisplay error")
      ex$message(msgnumb = EMS_I_00000)
      mask = GRm_DATA | GRm_RJT_MOVEON | GRm_BACK_UP;
      sts = co$getevent (
            msg = &msg,
            event_mask = mask,
            msgnum = EMS_P_00038,
            response = response,
            response_data = response_data,
            event = &event);
      ERROR(sts, msg, "co$getevent error")
      ex$message(msgnumb = EMS_I_00000)
      DisplayMode = GRbe;
      sts = om$send(msg = message GRgraphics.GRdisplay(&msg,
             &matrix_type,
             (me->is_left_hand_system ? me->lhs_matrix : me->rhs_matrix),
             &DisplayMode,
             &me->cross_section.module_info.md_id),
             targetid = me->cross_section.located_obj.objid,
             targetos = me->cross_section.located_obj.osnum);
       ERROR(sts, msg, "GRdisplay error")
      if (event.response == GR_UNKNOWN_TYPE)
       return(OM_S_SUCCESS);
      else if (event.response == EX_BACK_UP)
       {
        if (me->absolute_orientation)
         {
          LOCAL_DISPLAY(sts, &msg, 2, me->absolute_pnts, FALSE)
           ERROR(sts, msg, "LOCAL_DISPLAY error")
          me->absolute_orientation = FALSE;
         }
        me->state = 9;
       }
      else if (event.response == EX_RJT_MOVEON)
       me->is_left_hand_system = (me->is_left_hand_system ? FALSE : TRUE);
      else
       me->state = 11;
      break;
/*
 * Unhighlight all the geometry
 */
     case 11:
      ex$message(msgnumb = EMS_P_00000)
      ex$message(msgnumb = EMS_I_00004, type = "%s", var = " . ")
      sts = om$send(
        msg = message super_cmd.sleep(0),
        targetid = my_id);
       ERROR(sts, 0, "Sleep error")
/*
 * Finally let's do something
 */
      ex$message(msgnumb = EMS_I_00004, type = "%s", var = " .. ")
      {
       IGRdouble        matrix[9];
       struct           GRid surface_GRid;
       struct           GRvg_construct construct_list;

       matrix[0] = me->view_matrix[0];
       matrix[1] = me->view_matrix[1];
       matrix[2] = me->view_matrix[2];
       matrix[3] = me->view_matrix[4];
       matrix[4] = me->view_matrix[5];
       matrix[5] = me->view_matrix[6];
       matrix[6] = me->view_matrix[8];
       matrix[7] = me->view_matrix[9];
       matrix[8] = me->view_matrix[10];
       construct_list.msg = &msg;
       construct_list.env_info = &me->ModuleInfo;
       construct_list.newflag = FALSE;
       construct_list.geometry = NULL;
       construct_list.class_attr = NULL;
       construct_list.level = me->ActiveLevel;
       construct_list.properties = GRIS_LOCATABLE | GRIS_DISPLAYABLE;
       construct_list.display = &me->ActiveDisplay;
       construct_list.name = NULL;
       surface_GRid.osnum = me->ModuleInfo.md_id.osnum;
       sts = om$construct(
              classid = OPP_EMSgenbs_class_id,
              p_objid = &surface_GRid.objid,
              osnum = surface_GRid.osnum,
              msg = message EMSgenbs.EMmove_cross_section_normal_to_sf(
               &msg, 
               &was_curve_on_surface,
               &construct_list, 
               &me->surface,
               &me->trace,
               &me->cross_section,
               me->side_pnt, 
               me->ref_pnt,
               me->is_left_hand_system, 
               matrix,
               me->vector_pnts,
               (me->absolute_orientation ? me->absolute_pnts : NULL)));
       if (!(1 & sts))
        ex$message(msgnumb = EMS_I_00002)
       else
        {
         ex$message(msgnumb = EMS_I_00004, type = "%s", var = " ... ")
         DisplayMode = GRbd;
         sts = om$send(msg = message GRgraphics.GRdisplay(&msg,
                        &me->ModuleInfo.md_env.matrix_type, 
                        me->ModuleInfo.md_env.matrix, &DisplayMode, 
                        &me->ModuleInfo.md_id),
                        targetid = surface_GRid.objid,
                        targetos = surface_GRid.osnum);
          ERROR(sts, msg, "GRgraphics.GRdisplay error");
         if (!was_curve_on_surface) 
          ex$message(msgnumb = EMS_I_00073)
         else
          ex$message(msgnumb = EMS_I_00000)
        }
       }
      me->state = 0;
      break;
/*
 * Something has messed up our state table
 */
     default:
      ERROR(OM_E_ABORT, 0, "Default state reached")
    }
  }
 while(TRUE);
error_abort:
 *response = TERMINATE;
 ex$message(msgnumb = EMS_F_0002)
 return(OM_E_ABORT);
}

end implementation COplcsknrm;
