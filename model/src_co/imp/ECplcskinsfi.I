/* ###################   APOGEE COMPILED   ################## */

class implementation ECplcskinsf;

%safe
#include <math.h>
%endsafe

#include "EMS.h"
#include "ems_m_inc.h"
#include "EMSmsgdef.h"		        /* EMS_I_NotFound */
#include "EC_M.h"		        /* Command strings */
#include "EC_P.h"			/* Prompt strings */
#include "EC_I.h"			/* Informational strings */
#include "EC_F.h"			/* Fatal strings */
#if defined( NT )
#if 0  /* because opp can not handle it */
#  include <windows.h>
#endif
#endif

#ifdef X11
#  include <X11/Xlib.h>
#  include <X11/Xutil.h>
#endif

#if defined(__STDC__) || defined(__cplusplus)
#if 0  /* because opp can not handle it */
#  if defined( X11 )
#    include <XFIproto_pub.h>
#  elif defined( ENV5 )
#    include <FIproto_pub.h>
#  elif defined( NT )
#    include <shampub.h>
#  endif
#  endif
#else
#  include <FI.h>
#  endif

#include "EMSdpb.h"
#include "emsdef.h"
#include "REsfsolid.h"
#include "EMSifmacros.h"
#include "EMSasmacros.h"

from GRgraphics import GRdelete;
from EMSsfsolid import EMcap_thyself;
from EMSassoc import EMinit_associative;

#define SURFACE 0
#define SOLID 1

#define FORM1  1

#define BIG_CURVE 0
#define LITTLE_CURVE 1
#define LITTLE_SURFACE 2
#define LITTLE_ELEMENT 3
#define ANY_ELEMENT 4
#define BIG_SURFACE 5

#define INITIALIZE           0
#define TRACE_CURVES         1
#define CROSS_CURVES         2
#define SURFACE_CLOSED       3
#define PRE_TANGENT_SURFACES 4
#define TANGENT_SURFACES     5
#define ABSOLUTE_ORIENTATION 6
#define PROCESS              7

extern OMuword OPP_EMSgenbs_class_id;
extern OMuword OPP_EMSsfsolid_class_id;
extern OMuword OPP_EMAgenbs_class_id;
extern OMuword OPP_EMScompsurf_class_id;

from NDnode import NDmove_to_root;

/*

Name
  execute

Abstract
 Places a skinning surface/solid.

Synopsis
 int *response; 
 char *response_data; 
 int pos;

Description
 This is the command object for the place skinning surface/solid functionality.
 The basic flow is as follows:
 Collect all traces.
 Collect all cross sections.
 Ask if surface is to be closed.
 Ask for supporting tangent surfaces.
 Ask if cross sections are to be absolutely oriented about the traces.
 Ask if height scaling is desired.
 Ask for orientation and shape law curves.

Return Value

Notes

Index

Keywords
 place,skinning,solid,surface,execute
History

 10/26/89 :rlw :  Creation date.  This command was written based on the
                  old command ECplcsknsfi.I.
 05/28/90 :rlw :  Modified to remove warning message about cross sections
                  at cusp points which was put in by Chopra.  1.3.2 math
                  now handles this condition.  Also modified such that
                  height scaling option is possible when 2 traces and
                  2 cross sections are present.  Earlier it only applied when
                  2 traces and 1 cross section were present.
 03/26/91 :mm  :  Changed to c-based form.
 06/04/91 :DLB :  Support current_creator.
 08/08/91 :scw :  Converted to use gr$dpb associative flag
 10/05/91 :DLB :  dp$display macro takes matrix_type as a *int!!!!!!! SUN
 01/20/93 : Kumar N : ported to NT.
 06/14/93 :scw :  Removed references to the X11 directory for include files.
		  crash.
 06/22/93 : Carlos M. Diaz : modified it for new skinning surface/solid.
 			     It creates composites now.

*/
%safe
static IGRboolean GS_composite = TRUE, GS_smooth = FALSE;
%endsafe
method execute(int *response; char *response_data; int pos)
{
 IGRchar        prompt[80];
 IGRboolean	put_on_queue, use_default, is_curve_reversed;
 IGRlong        event_mask, i, key, sts, msg, previous_state;
 struct		GRprops	props;
 struct		GRlc_info *lc_info;
 struct		RLW_locate_info loc_info;
/*
 * Initialize
 */
 if (me->mytype == SURFACE)
  ex$message(msgnumb = EM_M_0096)
 else
  ex$message(msgnumb = EM_M_0097)
/*
 * Enter infinite loop
 */
 do
  {
/*
 * I am trying to save the position of the command before it enters
 * the processing state so that I can backup to that state again
 * after processing.
 */
   if (me->state != PROCESS)
    previous_state = me->state;
/*
 * Branch based on our state
 */
   switch(me->state)
    {
/*
 * Room for growth
 */
     case INITIALIZE:
      me->previous_trace_count = me->num_trace;   /* Save for wrap around */
      me->previous_cross_count = me->num_cross;
      me->num_trace = 0;
      me->num_cross = 0;
      me->create_composite = GS_composite; /* global static */
      me->smooth = GS_smooth;		   /* global static */
/*    ex$message (msgnumb = EMS_I_00104);   rlw 05/28/90 */
      me->state = TRACE_CURVES;
      ex$message(msgnumb = EMS_I_InvkStatusFrm);
      GRstatus_display_button(1);
/*       sleep(1); */

/*
 * Get the curves
 */
     case TRACE_CURVES:
      event_mask = GRm_DATA | GRm_BACK_UP | GRm_RESTART;
      if (me->num_trace == 0)
       key = EMS_P_00122;                /* Identify trace ? */
      else
       {
        event_mask |= GRm_RJT_MOVEON;
        key = EMS_P_00123;               /* Identify trace ?/moveon */
       }
      i = me->num_trace + 1;
      ex$message(
       msgnumb = key,
       type = "%d",
       var = `i`,
       buff = prompt);
      EFget_locate_information(
       BIG_CURVE,
       &loc_info);
      loc_info.identify_event_type = good_data;
      loc_info.acc_key = EMS_P_00045;       /* Accept with next curve/reject */
      loc_info.accept_event_type = chained;
      sts = om$send(
        msg = message ECconstruct.locate_object(
         event_mask,
         prompt,
         LC_NO_MSG,		/* No locate key */
         &loc_info,
         TRUE,                  /* Automatically put accept event on queue */
         &put_on_queue,         /* Is possible to put accept event on queue? */
         response,
         response_data),
        targetid = my_id);
       ON_ERROR goto kill_command;
      if (me->locate_stack.num_entries) return(OM_S_SUCCESS);
      switch (me->event.response)
       {
        case GR_UNKNOWN_TYPE:
         return(OM_S_SUCCESS);
        case EX_BACK_UP:
         {
          IGRboolean	wraping;
 
          wraping = ((me->number_of_events_input == 0) &&
                     me->have_a_constructed_object);
          if (wraping)
           {
            me->num_trace = me->previous_trace_count;
            me->num_cross = me->previous_cross_count;
           }
          sts = om$send(
            msg = message ECconstruct.backup_event(),
            targetid = my_id);
           ON_ERROR goto kill_command;
          if (wraping)
           {}
          else if (me->num_trace == 0)
           me->state = INITIALIZE;
          else
           {
            me->num_trace--;
            lc_info = &me->trcobj[me->num_trace];
            is_curve_reversed = lc_info->geom_parms.polygon_inx;
/*********************************************************************
            sts = EFdisplay_curve_normal_or_tangent(
              lc_info,		The curve 
              NULL,		Not used for tangents 
              FALSE,		Display the tangent vector 
              is_curve_reversed,
              my_id,
              GRbe,		 Erase 
              &me->display_env,
              &me->display,
              &msg);
**************************************************************************/
            sts = ems$display_curve_normal_or_tangent(
                                     loc_info = lc_info,
                                     display_normal_tangent = FALSE,
                                     reverse_vector = is_curve_reversed,
                                        senderid = my_id,
                                     draw_mode = GRbe,
                                     display_mdenv = &me->display_env,
                                     display = &me->display,
                                        msg = &msg);
             ON_ERROR goto kill_command;
           }
         }
         break;
        case EX_RESTART:
         sts = om$send(
           msg = message ECconstruct.restart(),
           targetid = my_id);
          ON_ERROR goto kill_command;
         break;
        case EX_RJT_MOVEON:
         sts = om$send(
           msg = message ECconstruct.add_event(
            FALSE),               /* Not a located object */
           targetid = my_id);
          ON_ERROR goto kill_command;
         me->traces_are_closed = TRUE;
         for (i = 0; (i < me->num_trace) && me->traces_are_closed; i++)
          {
           if (! me->trcobj[i].geom_parms.leaf_id.objid)
            me->traces_are_closed = FALSE;
          }
         me->state = CROSS_CURVES;
         break;
        default:                  /* Object was located */
         {
          IGRlong	current_size;
 
          sts = om$send(
            msg = message ECconstruct.add_event(
             TRUE),                /* It is a located object */
            targetid = my_id);
           ON_ERROR goto kill_command;
          current_size = om$dimension_of(varray = me->trcobj);
          if (me->num_trace == current_size)
           {
            sts = om$vla_set_dimension(
              varray = me->trcobj,
              size = current_size + 10);
             ON_ERROR goto kill_command;
           }
          sts = EFdetermine_direction(
            &me->event,
            my_id,
            &msg);
           ON_ERROR goto kill_command;
          sts = EFgetprops(
            &me->event,
            my_id,
            &props,
            &msg);
           ON_ERROR goto kill_command;
          me->trcobj[me->num_trace] = me->event.located_object[0];
          lc_info = &me->trcobj[me->num_trace];
          is_curve_reversed = lc_info->geom_parms.polygon_inx;
          lc_info->geom_parms.leaf_id.objid = props.phy_closed;
/*************************************************************************
          sts = EFdisplay_curve_normal_or_tangent(
            lc_info,		The curve 
            NULL,		Not used for tangents 
            FALSE,		Display the tangent vector 
            is_curve_reversed,
            my_id,
            GRbd,		Draw background 
            &me->display_env,
            &me->display,
            &msg);
**************************************************************************/
          sts = ems$display_curve_normal_or_tangent(
                                   loc_info = lc_info,
                                    display_normal_tangent = FALSE,
                                           reverse_vector = is_curve_reversed,
                                          senderid = my_id,
                                          draw_mode = GRbd,
                                       display_mdenv = &me->display_env,
                                             display = &me->display,
                                                 msg = &msg);
           ON_ERROR goto kill_command;
          me->num_trace++;
          if(me->num_trace == 2)
           {
           ex$message(msgnumb = EMS_I_InvkStatusFrm);
           GRstatus_display_button(1);
/*            sleep(1); */
           }
         }
         break;
       } /* switch (me->event.response) */
      break;
/*
 * Get the cross sections
 */
     case CROSS_CURVES:
      event_mask = GRm_DATA | GRm_BACK_UP | GRm_RESTART;
      if ((me->num_cross == 0)  || 
          ((me->num_cross == 1) && 
           (me->num_trace > 2)))
       key = EMS_P_00117;           /* Identify cross section i*/
      else
       {
        event_mask |= GRm_RJT_MOVEON;
        key = EMS_P_00124;          /* Identify cross section i/moveon */
       }
      i = me->num_cross + 1;
      ex$message(
       msgnumb = key,
       type = "%d",
       var = `i`,
       buff = prompt)
      EFget_locate_information(
       BIG_CURVE,
       &loc_info);
      loc_info.identify_event_type = good_data;
      loc_info.acc_key = EMS_P_00045;       /* Accept with next curve/reject */
      loc_info.accept_event_type = chained;
      if (me->mytype == SOLID)              /* Locate nearly planar for sf */
       loc_info.planar_flag = LC_PLANAR_ONLY;
      sts = om$send(
        msg = message ECconstruct.locate_object(
         event_mask,
         prompt,
         LC_NO_MSG,             /* No locate key, use string */
         &loc_info,
         FALSE,                 /* Don't put accept event on queue */
         &put_on_queue,         /* Is possible to put accept event on queue? */
         response,
         response_data),
        targetid = my_id);
       ON_ERROR goto kill_command;
      if (me->locate_stack.num_entries) return(OM_S_SUCCESS);
      switch (me->event.response)
       {
        case GR_UNKNOWN_TYPE:
         return(OM_S_SUCCESS);
        case EX_BACK_UP:
         sts = om$send(
           msg = message ECconstruct.backup_event(),
           targetid = my_id);
          ON_ERROR goto kill_command;
         if (me->num_cross == 0)
          me->state = TRACE_CURVES;
         else
          {
           me->num_cross--;
           lc_info = &me->crsobj[me->num_cross];
           is_curve_reversed = lc_info->geom_parms.polygon_inx;
/************************************************************************
           sts = EFdisplay_curve_normal_or_tangent(
             lc_info,		The curve 
             NULL,		Not used for tangents 
             FALSE,		Display the tangent vector
             is_curve_reversed,
             my_id,
             GRbe,		Erase
             &me->display_env,
             &me->display,
             &msg);
*************************************************************************/
           sts = ems$display_curve_normal_or_tangent(
                                  loc_info = lc_info,
                                   display_normal_tangent = FALSE,
                                   reverse_vector = is_curve_reversed,
                                       senderid = my_id,
                                       draw_mode = GRbe,
                                       display_mdenv = &me->display_env,
                                       display = &me->display,
                                           msg = &msg);
            ON_ERROR goto kill_command;
          }
         break;
        case EX_RESTART:
         sts = om$send(
           msg = message ECconstruct.restart(),
           targetid = my_id);
          ON_ERROR goto kill_command;
         break;
        case EX_RJT_MOVEON:
         sts = om$send(
           msg = message ECconstruct.add_event(
            FALSE),               /* Not a located object */
           targetid = my_id);
          ON_ERROR goto kill_command;
         me->crosses_are_closed = TRUE;
         for (i = 0; (i < me->num_cross) && me->crosses_are_closed; i++)
          {
           if (! me->crsobj[i].geom_parms.leaf_id.objid)
            me->crosses_are_closed = FALSE;
          }
         if (me->traces_are_closed)
          {
           if (me->num_cross > 1)
            me->state = SURFACE_CLOSED;
           else
            {
             me->surface_is_open = FALSE;
             me->state = PRE_TANGENT_SURFACES;
            }
          }
         else
          {
           me->surface_is_open = TRUE;
           me->state = PRE_TANGENT_SURFACES;
          }
         break;
        default:                  /* Object was located */
         {
          IGRboolean	valid_object = TRUE;
          IGRlong	current_size;
 
          sts = om$send(
            msg = message ECconstruct.add_event(
             TRUE),                /* It is a located object */
            targetid = my_id);
           ON_ERROR goto kill_command;
          current_size = om$dimension_of(varray = me->crsobj);
          if (me->num_cross == current_size)
           {
            sts = om$vla_set_dimension(
              varray = me->crsobj,
              size = current_size + 10);
             ON_ERROR goto kill_command;
           }
          sts = EFdetermine_direction(
            &me->event,
            my_id,
            &msg);
           ON_ERROR goto kill_command;
          sts = EFgetprops(
            &me->event,
            my_id,
            &props,
            &msg);
           ON_ERROR goto kill_command;
          me->crsobj[me->num_cross] = me->event.located_object[0];
          lc_info = &me->crsobj[me->num_cross];
          is_curve_reversed = lc_info->geom_parms.polygon_inx;
          lc_info->geom_parms.leaf_id.objid = props.phy_closed;
          if ((me->mytype == SOLID) &&
              (! props.phy_closed))
           {
            valid_object = FALSE;
            ex$message(msgnumb = EMS_I_00014)
            sts = om$send(
              msg = message ECconstruct.backup_event(),
              targetid = my_id);
             ON_ERROR goto kill_command;
           }
          else
           {
/**************************************************************************
            sts = EFdisplay_curve_normal_or_tangent(
              lc_info,		The curve 
              NULL,		Not used for tangents 
              FALSE,		Display the tangent vector 
              is_curve_reversed,
              my_id,
              GRbd,		Draw background 
              &me->display_env,
              &me->display,
              &msg);
***************************************************************************/
            sts = ems$display_curve_normal_or_tangent(
                                    loc_info = lc_info,
                                    display_normal_tangent = FALSE,
                                            reverse_vector = is_curve_reversed,
                                               senderid = my_id,
                                               draw_mode = GRbd,
                                              display_mdenv = &me->display_env,
                                                 display = &me->display,
                                                     msg = &msg);
             ON_ERROR goto kill_command;
            me->num_cross++;
            if (put_on_queue)
             {
              IGRlong	sizeof_event;
 
              sizeof_event = sizeof(struct GRevent);
              sts = ex$putque(
                msg = &msg,
                response = &me->event1.response,
                byte = &sizeof_event,		/* Should be slightly less */
                buffer = (IGRchar *)&me->event1.event);
               ON_ERROR goto kill_command;
             } /* if (put_on_queue) */
           } /* if (valid_object) */
         }
        break;
       } /* switch (me->event.response) */
      break;
/*
 * Determine if the surface to be generated should be closed.
 */
     case SURFACE_CLOSED:
      key = EMS_P_00160;  /* Should the generated surface be closed? y/n [y] */
      event_mask = GRm_TEXT_VALUE | GRm_BACK_UP | GRm_RESTART;
      sts = om$send(
        msg = message ECconstruct.getevent(
         NONE,                           /* Don't need a value */
         event_mask,
         NULL,                           /* No prompt string */
         key,
         response,
         response_data),
        targetid = my_id);
       ON_ERROR goto kill_command;
      switch (me->event.response)
       {
        case GR_UNKNOWN_TYPE:
         return(OM_S_SUCCESS);
        case EX_BACK_UP:
         sts = om$send(
           msg = message ECconstruct.backup_event(),
           targetid = my_id);
          ON_ERROR goto kill_command;
         me->state = CROSS_CURVES;
         break;
        case EX_RESTART:
         sts = om$send(
           msg = message ECconstruct.restart(),
           targetid = my_id);
          ON_ERROR goto kill_command;
         break;
        default:
         use_default = (me->msg == GRw_no_value);
         if (use_default ||
             (toupper(me->event.event.keyin[0]) == 'Y'))
          me->surface_is_open = FALSE;
         else if (toupper(me->event.event.keyin[0]) == 'N')
          me->surface_is_open = TRUE;
         else
          return(OM_S_SUCCESS);              /* Must have meant a command */
         sts = om$send(
           msg = message ECconstruct.add_event(
            FALSE),                /* Not a located object */
           targetid = my_id);
          ON_ERROR goto kill_command;
         me->state = PRE_TANGENT_SURFACES;
         break;
       } /* switch (me->event.response) */
      break;
/*
 * Initialize the supporting tangency information.
 */
     case PRE_TANGENT_SURFACES:
      for (i = 0; i < 4; i++) 
       {
        me->supporting_curve[i].located_obj.objid = NULL_OBJID;
        me->tangent_surfaces[i].located_obj.objid = NULL_OBJID;
       }
      if (me->crosses_are_closed)
       me->num_tansf = 2;
      else
       {
        me->num_tansf = 0;
        me->supporting_curve[0] = me->trcobj[0];
        if (me->num_trace > 1)
         me->supporting_curve[1] = me->trcobj[me->num_trace - 1];
       }
      if (me->surface_is_open)
       {
        me->supporting_curve[2] = me->crsobj[0];
        if (me->num_cross > 1)
         me->supporting_curve[3] = me->crsobj[me->num_cross - 1];
       }
      if ((! me->crosses_are_closed) ||
          me->surface_is_open)
       me->state = TANGENT_SURFACES;
      else if (me->num_trace > 2)
       me->state = PROCESS;
      else
       me->state = ABSOLUTE_ORIENTATION;
      break;
/*
 * Collect the supporting tangency surfaces, if any
 */
     case TANGENT_SURFACES:
      key = EMS_P_00161;       /* Identify surface for tangency/move on */
      ex$message(msgnumb = key)
      {
       enum	GRdpmode mode[2];
       IGRuchar heavy_weight;
       IGRlong  dlb_mtx_type;
       IGRmatrix *dlb_mtx_ptr;
       struct	GRlc_info *lc_info;
       struct	GRid *id;
       struct	GRmdenv_info *mdenv_info;
       struct	IGRaltdisplay heavy_stuff;

       lc_info = &me->supporting_curve[me->num_tansf];
       id = &lc_info->located_obj;
       mdenv_info = &lc_info->module_info.md_env;
       mode[0] = GRhhd;
       mode[1] = GRhe;
       heavy_weight = me->display.weight + 4;
/*     heavy_stuff.rgb_value = &me->display.rgb_value; */
       heavy_stuff.color     = &me->display.color;
       heavy_stuff.weight    = &heavy_weight;
       heavy_stuff.style     = &me->display.style;

	/**************************
		DLB 10/05/91 : Crazy dp$display macro takes a *int as 
				matrix type instead of *short.  A *short
				will work fine on the Clipper but will crash
				on the Sparc due to byte reversal factors.
				Also, dp$display takes an ARRAY of ptrs
				to matrices!!
	***************************/

       dlb_mtx_type = mdenv_info->matrix_type; 
       dlb_mtx_ptr = (IGRmatrix *)mdenv_info->matrix;

       for (i = 0; i < 2; i++)
        {
         sts = dp$display(
           msg = &msg,
           osnum = me->display_env.md_id.osnum,
           objid = me->display_env.md_id.objid,
           mode = mode[i],
           num_elem = 1,
           oids = id,
           alt_symb = &heavy_stuff,
           mtx_type = &dlb_mtx_type,
           matrix = &dlb_mtx_ptr);
          ON_ERROR goto kill_command;
         if (i == 0)
          {
           extern	int EX_check_input();

           EX_check_input();
          }
        } /* for (i = 0; i < 2; i++) */
      }
      event_mask = GRm_DATA | GRm_BACK_UP | GRm_RESTART | GRm_RJT_MOVEON;
      EFget_locate_information(
       LITTLE_SURFACE,
       &loc_info);
      loc_info.accept_event_type = dummy;
      sts = om$send(
        msg = message ECconstruct.locate_object(
         event_mask,
         NULL,			/* No locate prompt */
         key,
         &loc_info,
         FALSE,                 /* Don't put accept event on queue */
         &put_on_queue,         /* Is possible to put accept event on queue? */
         response,
         response_data),
        targetid = my_id);
       ON_ERROR goto kill_command;
      if (me->locate_stack.num_entries) return(OM_S_SUCCESS);
     switch (me->event.response)
      {
       case GR_UNKNOWN_TYPE:
        return(OM_S_SUCCESS);
       case EX_BACK_UP:
        {
         IGRlong	previous_curve;

         sts = om$send(
           msg = message ECconstruct.backup_event(),
           targetid = my_id);
          ON_ERROR goto kill_command;
         previous_curve = -1;
         for (i = 0; i < me->num_tansf; i++)
          {
           if (me->supporting_curve[i].located_obj.objid != NULL_OBJID)
            previous_curve = i;
          }
         if (previous_curve == -1)
          {
           if (me->traces_are_closed &&
               (me->num_cross > 1))
            me->state = SURFACE_CLOSED;
           else
            me->state = CROSS_CURVES;
          }
         else
          me->num_tansf = previous_curve;
        }
        break;
       case EX_RESTART:
        sts = om$send(
          msg = message ECconstruct.restart(),
          targetid = my_id);
         ON_ERROR goto kill_command;
        break;
       case EX_RJT_MOVEON:
       default:                  /* Object was located */
        {
         IGRboolean	not_finished = TRUE, located_surface;

         located_surface = (me->event.response != EX_RJT_MOVEON);
         sts = om$send(
           msg = message ECconstruct.add_event(
            located_surface),                /* It is a located object */
           targetid = my_id);
          ON_ERROR goto kill_command;
         if (located_surface)
          me->tangent_surfaces[me->num_tansf] = me->event.located_object[0];
         else
          me->tangent_surfaces[me->num_tansf].located_obj.objid = NULL_OBJID;
         for (i = me->num_tansf + 1; (i < 4) && not_finished; i++)
          {
           if (me->supporting_curve[i].located_obj.objid != NULL_OBJID)
            {
             me->num_tansf = i;
             not_finished = FALSE;
            }
          }
         if (not_finished)
          {
           if (me->num_trace > 2)
            me->state = PROCESS;
           else
            me->state = ABSOLUTE_ORIENTATION;
          } /* if (not_finished) */
        }
        break;
      } /* switch (me->event.response) */
      break;
/*
 * Determine if the orientation of the cross sections w.r.t. the trace
 * should be absolute or relative.
 */
     case ABSOLUTE_ORIENTATION:
      if ((me->num_trace == 2) ||
          ((me->num_trace <= 2) && (me->num_cross == 2) &&
           me->surface_is_open))
       {
        ex$message(msgnumb = EMS_I_InvkStatusFrm);
        GRstatus_display_button(1);
        strcpy(
         me->active_form_name,
         "EMSoptSknsf");
       }
      key = EMS_P_00162;
      event_mask = GRm_TEXT_VALUE | GRm_BACK_UP | GRm_RESTART;
      sts = om$send(
        msg = message ECconstruct.getevent(
         NONE,                      /* Don't need a value */
         event_mask,
         NULL,                      /* No prompt string */
         key,
         response,
         response_data),
        targetid = my_id);
       ON_ERROR goto kill_command;
      switch (me->event.response)
       {
        case GR_UNKNOWN_TYPE:
         return(OM_S_SUCCESS);
        case EX_BACK_UP:
         sts = om$send(
           msg = message ECconstruct.backup_event(),
           targetid = my_id);
          ON_ERROR goto kill_command;
         if (me->surface_is_open ||
             (! me->crosses_are_closed))
          me->state = TANGENT_SURFACES;
         else if (me->traces_are_closed &&
                  (me->num_cross > 1))
          me->state = SURFACE_CLOSED;
         else
          me->state = CROSS_CURVES;
         break;
        case EX_RESTART:
         sts = om$send(
           msg = message ECconstruct.restart(),
           targetid = my_id);
          ON_ERROR goto kill_command;
         break;
        default:
         use_default = (me->msg == GRw_no_value);
         if (use_default ||
             (toupper(me->event.event.keyin[0]) == 'R'))
          me->absolute_orientation = FALSE;
         else if (toupper(me->event.event.keyin[0]) == 'A')
          me->absolute_orientation = TRUE;
         else
          return(OM_S_SUCCESS);              /* Must have meant a command */
         sts = om$send(
           msg = message ECconstruct.add_event(
            FALSE),                /* Not a located object */
           targetid = my_id);
          ON_ERROR goto kill_command;
         me->state = PROCESS;
         break;
       } /* switch (me->event.response) */
/*
 * The status display form is only valid for this particular state.
 * I delete the form because some of the fields have possibly been
 * erased.
 */
      if (me->form_requested)
       {
        me->form_requested = FALSE;
          FIf_erase(me->form1);
       } /* if (me->form_requested) */
      break;
/*
 * Unhighlight all the geometry
 */
     case PROCESS:
      ex$message(msgnumb = EMS_P_00000)
      ex$message(msgnumb = EMS_I_00004, type = "%s", var = " . ")
      pos = EX_suspend;
      sts = om$send(
        msg = message super_cmd.sleep(
         pos),
        targetid = my_id);
       ON_ERROR goto kill_command;
/*
 * Get the construct list
 */
      sts = om$send(
        msg = message ECconstruct.load_construction_information(),
        targetid = my_id);
       ON_ERROR goto kill_command;
      ex$message(msgnumb = EMS_I_00004, type = "%s", var = " .. ")
/*
 * Finally let's do something
 */
      {
       extern		void EMget_lawcurve();
       OMuword		osnum;
       IGRboolean	construction_failed;

       construction_failed = FALSE;
       osnum = me->construct_env.md_id.osnum;

/* Added for associativity */
       {
         IGRint sksurf_size;
         IGRint tot_crv = 0;
         IGRint cnt = 0;
         IGRchar *char_info = NULL;
         struct EMSskinning_surface *sksurf = NULL;
         struct EMSobject_info *list_ptr = NULL;

         sksurf_size = sizeof (struct EMSskinning_surface) + 
                       (me->num_cross + me->num_trace) * sizeof(char);
         if (me->orientation_law[0] != '\0')
          sksurf_size += strlen(me->orientation_law)* sizeof (char) + 1;

         if (me->shape_law[0] != '\0')
         sksurf_size += strlen(me->shape_law) * sizeof (char) + 1;

         sksurf = (struct EMSskinning_surface *)stackalloc(sksurf_size);
         if (!sksurf) 
         {
          msg = MANOMEMORY;
          goto kill_command;
         }
         sksurf->skinning_surf_props = 0;
         sksurf->tangent_surf_props = 0;
 
         sksurf->number_of_sections = me->num_cross;
         sksurf->number_of_trace_curves = me->num_trace;

         if (me->surface_is_open)
          sksurf->skinning_surf_props |= EMS_IS_SURFACE_OPEN;
         if (me->absolute_orientation)
          sksurf->skinning_surf_props |= EMS_IS_ABSOLUTE_ORIENTATION;
         if (!(me->no_height_scaling))
          sksurf->skinning_surf_props |= EMS_IS_HEIGHT_SCALING;
         if (me->orientation_law[0] != '\0')
          sksurf->skinning_surf_props |= EMS_IS_ORIENTATION_LAW;
         if (me->shape_law[0] != '\0')
          sksurf->skinning_surf_props |= EMS_IS_SHAPE_LAW;
         if (me->create_composite)
          sksurf->skinning_surf_props |= EMS_COMPOSITE_WANTED;
         if (me->smooth)
          sksurf->skinning_surf_props |= EMS_IS_ARC_LENGTH_PARAM;



         if (me->tangent_surfaces[0].located_obj.objid != NULL_OBJID)
         {
          sksurf->tangent_surf_props |= EMS_FIRST_SURF;
          ++tot_crv;
         }
         if (me->tangent_surfaces[1].located_obj.objid != NULL_OBJID) 
         {
          sksurf->tangent_surf_props |= EMS_SECOND_SURF;
          ++tot_crv;
         }
         if (me->tangent_surfaces[2].located_obj.objid != NULL_OBJID) 
         {
          sksurf->tangent_surf_props |= EMS_THIRD_SURF;
          ++tot_crv;
         }
         if (me->tangent_surfaces[3].located_obj.objid != NULL_OBJID) 
         {
          sksurf->tangent_surf_props |= EMS_FOURTH_SURF;
          ++tot_crv;
         }
          
         tot_crv += me->num_cross + me->num_trace; 

         list_ptr = (struct EMSobject_info *) stackalloc
                (sizeof (struct EMSobject_info) * tot_crv);
         if (!list_ptr)
         {
          msg = MANOMEMORY;
          if (sksurf) stackfree(sksurf); 
          sksurf = NULL;
          goto kill_command;
         }

         char_info =  sksurf->chardata;

         for (i=0;i<me->num_cross;i++,cnt++)
         {
          list_ptr[cnt].grid = me->crsobj[i].located_obj;
          list_ptr[cnt].env = me->crsobj[i].module_info;
          if (me->crsobj[i].geom_parms.polygon_inx) 
           char_info[0] = 1;
          else
           char_info[0] = 0;
          ++char_info;
         }

         for (i=0;i<me->num_trace;i++,cnt++)
         {
          list_ptr[cnt].grid = me->trcobj[i].located_obj;
          list_ptr[cnt].env = me->trcobj[i].module_info;
          if (me->trcobj[i].geom_parms.polygon_inx) char_info[0] = 1;
          else char_info[0] = 0;
          ++char_info;
         }

          if (me->tangent_surfaces[0].located_obj.objid != NULL_OBJID)
          {
           list_ptr[cnt].grid = me->tangent_surfaces[0].located_obj;
           list_ptr[cnt].env = me->tangent_surfaces[0].module_info;
           ++cnt;
          } 
          if (me->tangent_surfaces[1].located_obj.objid != NULL_OBJID) 
          {
           list_ptr[cnt].grid = me->tangent_surfaces[1].located_obj;
           list_ptr[cnt].env = me->tangent_surfaces[1].module_info;
           ++cnt;
          }
          if (me->tangent_surfaces[2].located_obj.objid != NULL_OBJID) 
          {
           list_ptr[cnt].grid = me->tangent_surfaces[2].located_obj;
           list_ptr[cnt].env = me->tangent_surfaces[2].module_info;
           ++cnt;
          }
          if (me->tangent_surfaces[3].located_obj.objid != NULL_OBJID) 
          {
           list_ptr[cnt].grid = me->tangent_surfaces[3].located_obj;
           list_ptr[cnt].env = me->tangent_surfaces[3].module_info;
           ++cnt;
          }

         if (me->orientation_law[0] != '\0')
         {
          strcpy(char_info, me->orientation_law);
          char_info = char_info + strlen(me->orientation_law) + 1;
         }

         if (me->shape_law[0] != '\0')
         {
          strcpy(char_info, me->shape_law);
         }

         if (me->mytype == SOLID) 
         /*
          * start first group of 2.4 changes
          */
         {
           sts = ems$associative_element_by_function ( 
	   		msg = &msg,
			associative = me->associative,
	   		num_parents = tot_crv,
	   		parents = list_ptr,
			info_size = sksurf_size,
			info = (IGRchar *)sksurf,
	   		function_name = "EFSkinSolid",
	   		construct_list = &me->construct_list,
	   		class_name = "EMSsfsolid",
	   		created_id = &me->constructed_object);
        }
         else 
         {
	   sts = ems$associative_element_by_function (
	   		msg = &msg,
			associative = me->associative,
	   		num_parents = tot_crv,
	   		parents = list_ptr,
			info_size = sksurf_size,
			info = (IGRchar *)sksurf,
	   		function_name = "EFSkinSurface",
	   		construct_list = &me->construct_list,
	   		class_name = "EMSgencompsf",
	   		created_id = &me->constructed_object);
         } /* ends associative surface construction */
         /*
          * end first group of changes for 2.4
          */  
       if (sksurf) 
         {
          stackfree(sksurf);
          sksurf = NULL;
         }
          /*
           * start second group of 2.4 changes
           * (deleted NDmove_to_root since it is done
           * down stream)
           * end second group of 2.4 changes
           */
       } /* ends associative processing */
         

       if (!(1 & sts))
        construction_failed = TRUE;

       me->have_a_constructed_object = TRUE;

       if (construction_failed)
        {
         me->constructed_object = NULL_OBJID;
         ex$message(msgnumb = EMS_I_00002)
        }
       else
        {
         enum	GRdpmode DisplayMode;

         ex$message(msgnumb = EMS_I_00004, type = "%s", var = " ... ")
         DisplayMode = GRbd;
         sts = om$send(
           msg = message ECconstruct.display_constructed_object(
            DisplayMode),
           targetid = my_id);
          ON_ERROR goto kill_command;
         ex$message(msgnumb = EMS_I_00000)
        }
/*
 * Clear my memory for a fresh start
 */
        me->state = previous_state + 1;     /* Don't ask me why */
        sts = om$send(
          msg = message ECconstruct.last_state_to_first_state(),
          targetid = my_id);
         ON_ERROR goto kill_command;
       }
      break;
/*
 * Something has messed up our state table
 */
     default:
      goto kill_command;
    }
  }
 while(TRUE);
/*
 * Kill the command
 */
kill_command:
 CMD_KILL
}

method display_constructions(
 IGRboolean	draw_background;
 IGRboolean	draw_single)
{
 enum		GRdpmode mode;   
 IGRboolean	is_curve_reversed;
 IGRlong	i, sts;
 struct		GRlc_info *lc_info;
/*
 * Initialize
 */
 me->msg = MSSUCC;
 if (draw_single) return(OM_S_SUCCESS);
/*
 * Draw the vectors
 */
 mode = (draw_background ? GRbd : GRbe);
 for (i = 0; i < me->num_trace; i++)
  {
   lc_info = &me->trcobj[i];
   is_curve_reversed = lc_info->geom_parms.polygon_inx;
/*********************************************************************
   sts = EFdisplay_curve_normal_or_tangent(
     lc_info,		The curve 
     NULL,		Not used for tangents
     FALSE,		Display the tangent vector
     is_curve_reversed,
     my_id,
     mode,
     &me->display_env,
     &me->display,
     &me->msg);
*************************************************************************/
    sts = ems$display_curve_normal_or_tangent(
                              loc_info = lc_info,
                               display_normal_tangent = FALSE,
                                    reverse_vector = is_curve_reversed,
                                    senderid = my_id,
                                    draw_mode = mode,
                                    display_mdenv = &me->display_env,
                                          display = &me->display,
                                              msg = &me->msg);
    ON_ERROR return(sts);
  } /* for (i = 0; i < me->num_trace; i++) */
 for (i = 0; i < me->num_cross; i++)
  {
   lc_info = &me->crsobj[i];
   is_curve_reversed = lc_info->geom_parms.polygon_inx;
/***************************************************************************
   sts = EFdisplay_curve_normal_or_tangent(
     lc_info,		The curve 
     NULL,		Not used for tangents 
     FALSE,		Display the tangent vector 
     is_curve_reversed,
     my_id,
     mode,
     &me->display_env,
     &me->display,
     &me->msg);
******************************************************************************/
   sts = ems$display_curve_normal_or_tangent(
                                  loc_info = lc_info,
                                display_normal_tangent = FALSE,
                                        reverse_vector = is_curve_reversed,
                                       senderid = my_id,
                                     draw_mode = mode,
                                     display_mdenv = &me->display_env,
                                     display = &me->display,
                                         msg = &me->msg); 
    ON_ERROR return(sts);
  } /* for (i = 0; i < me->num_cross; i++) */
/*
 * eof
 */
 return(OM_S_SUCCESS);
}

/*
 * It is important that this method not modify the variable
 * me->msg as this screws up the locate filter.  In general,
 * this method should be extremely careful about modifying
 * any instance data.
 */

 /*
  * changed for 2.4: 
  * FIg_erase   changed to FIg_disable
  * FIg_display changed to FIg_enable
  */
method update_status_form()
{
 char  alpha[132];
/*
 * Display or erase the height scaling option
 */
   FIg_display(me->form1, 13);
   FIg_display(me->form1, 14);
   FIg_display(me->form1, 15);
   FIg_display(me->form1, 16);
   FIg_display(me->form1, 17);
   FIg_display(me->form1, 18);
   FIg_display(me->form1, 19);
   FIg_display(me->form1, 20);
   FIg_display(me->form1, 21);
   FIg_display(me->form1, 22);
   FIg_display(me->form1, 23);


  /*
   * added for 2.4
   */
  if (me->create_composite == 0)
     FIg_set_state_on (me->form1, 20);
    else if (me->create_composite == 1)
            FIg_set_state_off (me->form1, 20);
  if (me->smooth == 0)
     FIg_set_state_on (me->form1, 23);
    else if (me->smooth == 1)
            FIg_set_state_off (me->form1, 23);
  /*
   * end added for 2.4
   */

 if (me->num_trace == 2)
  {
   if (me->no_height_scaling == 1){
       FIg_set_state_on (me->form1, 13);
    }
    else if (me->no_height_scaling == 0){
      FIg_set_state_off (me->form1, 13);
   }
  } /* if (me->num_trace == 2) */
 else
  {
   /*
    * 2.4:changed from erase to disable
    */
   FIg_disable(me->form1, 12);
   FIg_disable(me->form1, 13);
  } /* ELSE FOR if (me->num_trace == 2) */
/*
 * Display or erase the law options
 */
 if ((me->num_trace <= 2) &&
     (me->num_cross == 2) &&
     me->surface_is_open)
  {
  strcpy(alpha, me->orientation_law);
  FIfld_set_text(me->form1, 16, 0, 0, alpha);
  strcpy(alpha, me->shape_law);
  FIfld_set_text(me->form1, 18, 0, 0, alpha);
  FIg_enable(me->form1, 14);
  FIg_enable(me->form1, 15);
  FIg_enable(me->form1, 16);
  FIg_enable(me->form1, 17);
  FIg_enable(me->form1, 18);
  FIg_enable(me->form1, 21);
  
  } /* if ((me->num_trace <= 2) && (me->num_cross == 2)) */
 else
  {
   /* changed from erase to disable for 2.4 */
   FIg_disable(me->form1, 14);
   FIg_disable(me->form1, 15);
   FIg_disable(me->form1, 16);
   FIg_disable(me->form1, 17);
   FIg_disable(me->form1, 18);
   FIg_disable(me->form1, 21);
  } /* ELSE FOR if ((me->num_trace <= 2) && (me->num_cross == 2)) */
/*
 * eof
 */
 return(OM_S_SUCCESS);
}

method status_disp()
{ 
  IGRlong status, EMmsg;
  int ret;
  IGRint ECplcskinsf_process_form();

  status = OM_S_SUCCESS;
  EMmsg = 1;

 if ( !me->form1 )
 {
  ret = FIf_new (FORM1, "EMSoptSknsf", ECplcskinsf_process_form, &me->form1);
  if (ret) {
      status = FALSE;
      goto wrapup;
   }
 }
  ret = FIf_set_cmd_oid_os(me->form1, my_id, OM_Gw_current_OS);
  if (ret) {
      status = FALSE;
      goto wrapup;
   }
  status = om$send(msg = message ECconstruct.update_status_form(),
                targetid = my_id);
  if (!me->form_requested)
  {
    ret = FIf_set_location (me->form1, 0, 125);
    if (ret) {
       status = FALSE;
      goto wrapup;
   }
 if(
     ( (me->num_trace <= 2)&&(me->num_cross == 2)&&(me->surface_is_open) )
       ||   (me->num_trace== 2) || (me->num_trace== 0)  
   )  
    {
    ret = FIf_display(me->form1);
    if (ret) { status = FALSE; goto wrapup; }
    me->form_requested = TRUE;
    }
  }

wrapup:
 if (!(1&status&EMmsg))
   return (OM_E_ABORT);
 return (status);
}

IGRint ECplcskinsf_process_form (form_label, gadget_label, value, form_ptr)
IGRint form_label;
IGRint  gadget_label;
IGRdouble value;
Form form_ptr;
{
  IGRint stat_func, stat_OM;
  IGRlong msg_loc;
  GRobjid cmdobj;
  GRspacenum cmdos;


  stat_OM = OM_S_SUCCESS;

  stat_func = FIf_get_cmd_oid_os (form_ptr, &cmdobj, &cmdos);
  if (stat_func != FI_SUCCESS)
    return (OM_E_ABORT);

  stat_OM = om$send (msg = message ECplcskinsf.do_form (&msg_loc, form_label,
                     gadget_label, value),
             senderid = NULL_OBJID, targetid = cmdobj, targetos = cmdos);
  if (!(stat_OM & 1))
    return (OM_E_ABORT);

return (stat_OM);
}

/*
 * It is important that this method not modify the variable
 * me->msg as this screws up the locate filter.  In general,
 * this method should be extremely careful about modifying
 * any instance data.
 */
method do_form(IGRlong *msg; IGRint form_label; IGRint gadget_label;
               IGRdouble value)
{
 IGRboolean	update_form;
 IGRlong	sts;
/*
 * Initialize
 */
 update_form = TRUE;
/*
 * Branch based on the form label
 * which was affected.
 */
 if (form_label == 1){
   switch (gadget_label)
   {
   case 1:
    update_form = FALSE;
    FIg_set_state_off (me->form1, gadget_label);
    me->form_requested = FALSE;
    FIf_erase(me->form1);
    break;
   case 13:
    me->no_height_scaling = (me->no_height_scaling ? FALSE : TRUE);
    if (me->no_height_scaling == 1){
       FIg_set_state_off (me->form1, gadget_label);
    }
    else if (me->no_height_scaling == 0){
      FIg_set_state_on (me->form1, gadget_label);
   }
    break;
   case 16:
   case 18:
    {
     extern		void EMget_lawcurve();
     IGRchar		*string, str[132];
     IGRint             sel, rpos;
     IGRlong		msg, curve_index;

     if (gadget_label == 16)
      string = me->orientation_law;
     else
      string = me->shape_law;
     FIfld_get_text(me->form1, gadget_label, 0,0, 132, str, &sel, &rpos);     
     if (str[0] == '\0')
      string[0] = '\0';
     else
      {
       EMget_lawcurve(
         &msg,
         str,         
         &curve_index,
         NULL);			/* Don't want the law curve geometry */
        if ((1 & msg) &&
            (msg != EMS_I_NotFound))
         {
          strcpy(   
           string,
           str);
         } /* if law was valid */
      } /* ELSE FOR if (form_data->value.alpha[0] == '\0') */
    }
    break;
   /*
    * added case 20 for 2.4 
    */
   case 20:
    GS_composite = me->create_composite = (me->create_composite ? FALSE : TRUE);
    if (me->create_composite == 0){
       FIg_set_state_off (me->form1, gadget_label);
       }
    else if (me->create_composite == 1){
      FIg_set_state_on (me->form1, gadget_label);
      }
    break;
   /*
    * added case 23 for 2.4 
    */
   case 23:
    GS_smooth = me->smooth = (me->smooth ? FALSE : TRUE);
    if (me->smooth == 0){
       FIg_set_state_off (me->form1, gadget_label);
       }
    else if (me->smooth == 1){
      FIg_set_state_on (me->form1, gadget_label);
      }
    break;
   default:
    update_form = FALSE;
    break;
 } /* switch (form_data->label) */
}
/*
 * Update the form, if required
 */
 if (update_form)
  {
   sts = om$send(
    msg = message ECconstruct.update_status_form(),
    targetid = my_id);
  } /* if (update_form) */
/*
 * eof
 */
 return(OM_S_SUCCESS);
}


method is_associative(IGRint type; IGRlong *associative)
{
 IGRlong    EMmsg;
 IGRboolean state;

 EMmsg = 1;

 gr$get_associative_flag( buffer = &state );

 if (state)
  *associative = TRUE;
 else
  *associative = FALSE;
 return(OM_S_SUCCESS); 
}

end implementation ECplcskinsf;
