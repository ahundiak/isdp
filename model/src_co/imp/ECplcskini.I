class implementation ECplcskin;

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
#else
#  include <FI.h>
#endif
#else
#  include <FI.h>
#endif

#include "EMSdpb.h"
#include "emsdef.h"
#include "REsfsolid.h"
#include "EMSifmacros.h"
#include "EMSasmacros.h"
#include "SKnewdef.h"

from GRgraphics import GRdelete;
from EMSsfsolid import EMcap_thyself;
from EMSassoc import EMinit_associative;

/* for EFget_curve_information */
#define BIG_CURVE 0
#define LITTLE_CURVE 1
#define LITTLE_SURFACE 2
#define LITTLE_ELEMENT 3
#define ANY_ELEMENT 4
#define BIG_SURFACE 5

/* command states */
#define CASE_SELECT         99
#define INITIALIZE           0
#define TRACE_CURVES         1
#define CROSS_CURVES         2
#define SURFACE_CLOSED       3
#define PRE_TANGENT_SURFACES 4
#define TANGENT_SURFACES     5
#define PROCESS              6

extern OMuword OPP_EMSgenbs_class_id;
extern OMuword OPP_EMSsfsolid_class_id;
extern OMuword OPP_EMAgenbs_class_id;
extern OMuword OPP_EMScompsurf_class_id;
extern OMuword OPP_GRpoint_class_id;

from NDnode import NDmove_to_root;

%safe
static IGRboolean GS_composite = TRUE, GS_smooth = FALSE, GS_tansf = FALSE;
%endsafe

/*
Name
 option_invalidation

Description
 *controls the dis/enable of shape options for non-special cases (me->skinning_state 5 ... 14)
 *update permanent options form if disable occurs
 *inform the user about invalidation of shape options 

History
 02/02/94       R. Burkhart
    Creation date.
*/

method option_invalidation()
{
   IGRlong	ntr, ncs;
   IGRboolean   inform_just_now;

   inform_just_now = FALSE;
   me->violation_msg_key = NULL;

   ntr = me->num_trace;
   ncs = me->num_cross;

   /* delete old violation message */
   ex$message ( field = KEYIN_FIELD, msgnumb = EMS_I_00000);

   if (me->skinning_case > 4)
   {
      /* define me->skinning_case and msg_key */
      if      (ntr == 0 && ncs == 0)
         me->skinning_case = 5;
      else if (ntr == 1 && ncs == 0)
      {
         me->skinning_case = 6;
         if(me->state == CROSS_CURVES)
         {
            me->violation_msg_key = EMS_I_HgtScdisab;
            inform_just_now = TRUE;
         }
      }
      else if (ntr == 1 && ncs == 1)
      {
         me->skinning_case = 7; 
         if(me->state == CROSS_CURVES)
         {
            me->violation_msg_key = EMS_I_LawCvdisab;
         }
      }
      else if (ntr == 1 && ncs == 2)
      {
         me->skinning_case = 8; 
         if(me->state == CROSS_CURVES)
         {
            me->violation_msg_key = EMS_I_LawCvdisab;
            inform_just_now = TRUE;
         }
      }
      else if (ntr == 1 && ncs >= 3)
         me->skinning_case = 9; 
      else if (ntr == 2 && ncs == 0)
         me->skinning_case = 10; 
      else if (ntr == 2 && ncs == 1)
      {
         me->skinning_case = 10; 
         if(me->state == CROSS_CURVES)
         {
            me->violation_msg_key = EMS_I_LawCvdisab;
         }
      }
      else if (ntr == 2 && ncs == 2)
      {
         me->skinning_case = 11; 
         if(me->state == CROSS_CURVES)
         {
            me->violation_msg_key = EMS_I_LawCvdisab;
            inform_just_now = TRUE;
         }
      }
      else if (ntr == 2 && ncs == 3)
      {
         me->skinning_case = 12; 
         if(me->state == CROSS_CURVES)
         {
            me->violation_msg_key = EMS_I_HgtScdisab;
            inform_just_now = TRUE;
         }
      }
      else if (ntr == 2 && ncs > 3)
         me->skinning_case = 13; 
      else if (ntr == 3 && ncs >= 0)
      {
         me->skinning_case = 14; 
         me->violation_msg_key = EMS_I_AllOpdisab;
         inform_just_now = TRUE;
      }
      else 
      {
         me->skinning_case = 14;
         me->violation_msg_key = EMS_I_AllOpdisab;
         inform_just_now = TRUE;
      }

   }
   else
   {
      /* msg_keys for special cases */
      if (me->skinning_case == 3 && (me->state == TRACE_CURVES) )
      {
         me->violation_msg_key = EMS_I_HgtScdisab;
         inform_just_now = TRUE;
      }
      else if (me->skinning_case == 2 && (me->state == TRACE_CURVES) )
      {
         me->violation_msg_key = EMS_I_LawCvdisab;
         inform_just_now = TRUE;
      }
      else if (me->skinning_case == 1 && (me->state == TRACE_CURVES) )
      {
         me->violation_msg_key = EMS_I_Shapedisab;
         inform_just_now = TRUE;
      }
   }
   /* print out message, if needed */
   /* at this point we also check options form, to make sure, user is
   interested in these messages */
   if ( (inform_just_now && (me->active_form == SHAPE_OPTIONS_FORM)) ||
        (inform_just_now && (me->skinning_case < 4) ))
   {
      ex$message ( field = KEYIN_FIELD,
                   msgnumb = me->violation_msg_key,
                   justification = CENTER_JUS);
      me->violation_msg_key = NULL;
   }

   return ( OM_S_SUCCESS );
}


/*
Name
 select_case

Description
 Call the functions for manipulation of case selection form.

Parameters
 form_action (IN)   -  	action to perform	

History
 11/30/93 	R. Burkhart
    Creation date.
*/

method select_case(IGRint form_action;
                   int *response; char *response_data)
{
  int event_response, skin_case;
  switch (form_action)
  {
     case SkCs_EXECUTE_FORM:
       SkCs_manag (TRUE,&event_response,response,response_data,&skin_case);
       me->skinning_case  = skin_case;
       me->event.response = event_response;
       break;

     case SkCs_DELETE_FORM:
       SkCs_delete_form();
       break;
   }
   return ( OM_S_SUCCESS );
}

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
 (1) Select case of configuration of traces and cross sections.
 (2) Collect all traces.
 (3) Collect all cross sections.
 (4) Ask if surface is to be closed.
 (5) Ask for supporting tangent surfaces.
 (6) Notify if cross sections are to be absolutely oriented about the traces.
 (7) Notify if height scaling is desired.
 (8) Notify the orientation and shape law curve.
 Items 2 - 8 will be invoked dependend on case of configuration and on selected options.

Keywords
 place,skinning,solid,surface,execute
History
 11/30/93       R. Burkhart
    Creation date. This command was rewritten based on the old command ECplcskinsfi.I
    to change the user interface.
*/

method execute(int *response; char *response_data; int pos)
{
 IGRchar        prompt[80];
 IGRboolean	put_on_queue, use_default, is_curve_reversed;
 IGRlong        event_mask, i, key, sts, msg, previous_state;
 struct		GRprops	props;
 struct		GRlc_info *lc_info;
 struct		RLW_locate_info loc_info;

 /* Initialize */
 if (me->mytype == SURFACE)
  ex$message(msgnumb = EM_M_0096)
 else
  ex$message(msgnumb = EM_M_0097)

 /* Enter infinite loop */
 do
 {
  /*
   * I am trying to save the position of the command before it enters
   * the processing state so that I can backup to that state again
   * after processing.
   */
   if (me->state != PROCESS)
      previous_state = me->state;

   /* Branch based on our state */
   switch(me->state)
   {

     /* Room for growth */

     case CASE_SELECT:
        sts = om$send( msg = message ECplcskin.select_case(SkCs_EXECUTE_FORM,
                                                        response,response_data),
                  targetid = my_id);

        if (me->event.response == GR_UNKNOWN_TYPE)
        {
          return(OM_S_SUCCESS);
        }
        ON_ERROR goto kill_command;
        me->state = INITIALIZE;

        /* make it possible to manipulate the law field of the form before any curve is selected */
        if ((me->skinning_case == 3) || (me->skinning_case == 4) ||
            (me->skinning_case == 5) )
           me->surface_is_open = TRUE;
        break;

     case INITIALIZE:
        me->previous_trace_count = me->num_trace;   /* Save for wrap around */
        me->previous_cross_count = me->num_cross;
        me->num_trace = 0;
        me->num_cross = 0;
        me->create_composite = GS_composite; /* global static */
        me->smooth = GS_smooth;		     /* global static */
        me->tan_constrnt = GS_tansf;	     /* global static */
        me->state = TRACE_CURVES;
        if (me->have_a_constructed_object)
            key = EMS_I_PrCompBcUp;
        else
            key = EMS_I_InvkStatusFrm;

        ex$message(msgnumb = key);
        GRstatus_display_button(1);
        break;

     /* Get the trace curves */
     case TRACE_CURVES:

      /* calculate new non-special skinning_case and update form if necessary */ 
      sts = om$send( msg = message ECplcskin.option_invalidation(),
                targetid = my_id);
       ON_ERROR goto kill_command;

      event_mask = GRm_DATA | GRm_BACK_UP | GRm_RESTART;
      if ( (me->num_trace == 0)  ||
           ((me->num_trace == 1) && (me->skinning_case == 2)) ||
           ((me->num_trace == 1) && (me->skinning_case == 4))  )

       key = EMS_P_SelTrCurve;          /* Select trace curve */
      else
       {
        event_mask |= GRm_RJT_MOVEON;
        key =  EMS_P_IdntTrMvOn;        /* Identify trace curve/Move on */
       }
      i = me->num_trace + 1;
      ex$message( msgnumb = key, buff = prompt);

      EFget_locate_information( BIG_CURVE, &loc_info);
      loc_info.identify_event_type = good_data;
      loc_info.acc_key = EMS_P_AcNxTrRejt;       /* Accept with next trace curve/Reject */
      loc_info.accept_event_type = chained;
          if ( (i == 1 && me->skinning_case == 1) ||
               (i == 1 && me->skinning_case == 3) ||
               (i == 2 && me->skinning_case == 2) ||
               (i == 2 && me->skinning_case == 4)  )
          {
             loc_info.acc_key = EMS_P_AcScCvRejt; /* Accept with section curve/Reject */
          }

      sts = om$send( msg = message ECconstruct.locate_object(
                                        event_mask,
                                        prompt,
                                        LC_NO_MSG,	/* No locate key */
                                        &loc_info,
                                        TRUE,           /* Automatically put accept event on queue */
                                        &put_on_queue,  /* Is possible to put accept event on queue? */
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

           /* decrement number of events, reloads last point information */
           sts = om$send( msg = message ECconstruct.backup_event(),
                     targetid = my_id);
           ON_ERROR goto kill_command;
           if (wraping)
           {
              /* switch from backup_msg to options_msg */
              ex$message(msgnumb = EMS_I_InvkStatusFrm);
 
              /* set correct state, for backup */
              if (me->tan_constrnt && ( me->surface_is_open || (! me->crosses_are_closed)) )
                 me->state = TANGENT_SURFACES;
              else if (me->traces_are_closed && (me->previous_cross_count > 1))
                 me->state = SURFACE_CLOSED;
              else
              {
                 /* handle special cases */
                 if ( (me->num_cross == 1 && me->skinning_case == 1) ||
                      (me->num_cross == 1 && me->skinning_case == 2) ||
                      (me->num_cross == 2 && me->skinning_case == 3) ||
                      (me->num_cross == 2 && me->skinning_case == 4)  )
                 {
                    me->num_cross--;
                    lc_info = &me->crsobj[me->num_cross];
                    is_curve_reversed = lc_info->geom_parms.polygon_inx;
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
                 me->state = CROSS_CURVES;
              }
           }
           else if (me->num_trace == 0)
              me->state = INITIALIZE;
           else
           {
              me->num_trace--;
              lc_info = &me->trcobj[me->num_trace];
              is_curve_reversed = lc_info->geom_parms.polygon_inx;
/*********************************************************************
              EFdisplay_curve_normal_or_tangent:
                               lc_info 		The curve 
                               NULL 		Not used for tangents 
                               FALSE 		Display the tangent vector 
                               GRbe 		Drawmode: Erase 
                               &me->display     color, weight, style
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
         sts = om$send( msg = message ECconstruct.restart(),
                   targetid = my_id);
          ON_ERROR goto kill_command;
         break;

        case EX_RJT_MOVEON:
         sts = om$send( msg = message ECconstruct.add_event( FALSE),  /* Not a located object */
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
 
          sts = om$send( msg = message ECconstruct.add_event(TRUE),    /* It is a located object */
                    targetid = my_id);
           ON_ERROR goto kill_command;

          /* check number of alloc. elements for VLA, change size */
          current_size = om$dimension_of(varray = me->trcobj);
          if (me->num_trace == current_size)
           {
            sts = om$vla_set_dimension( varray = me->trcobj,
                                          size = current_size + 10);
             ON_ERROR goto kill_command;
           }

          /* curve parameter flow */
          sts = EFdetermine_direction( &me->event, my_id, &msg);
           ON_ERROR goto kill_command;

          /*get properties of input event (closed,segmented,obj.type ...)*/
          sts = EFgetprops( &me->event, my_id, &props, &msg);
           ON_ERROR goto kill_command;

          me->trcobj[me->num_trace] = me->event.located_object[0];
          lc_info = &me->trcobj[me->num_trace];
          is_curve_reversed = lc_info->geom_parms.polygon_inx;
          lc_info->geom_parms.leaf_id.objid = props.phy_closed;
/*************************************************************************
          EFdisplay_curve_normal_or_tangent:
                                  lc_info	The curve 
                                  NULL 		Not used for tangents 
                                  FALSE		Display the tangent vector 
                                  GRbd 		Draw background 
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

          /* handle special cases */
          if ( (me->num_trace == 1 && me->skinning_case == 1) ||
               (me->num_trace == 1 && me->skinning_case == 3) ||
               (me->num_trace == 2 && me->skinning_case == 2) ||
               (me->num_trace == 2 && me->skinning_case == 4)  )
          {
             me->traces_are_closed = TRUE;
             for (i = 0; (i < me->num_trace) && me->traces_are_closed; i++)
             {
                if (! me->trcobj[i].geom_parms.leaf_id.objid)
                   me->traces_are_closed = FALSE;
             }
             me->state = CROSS_CURVES;
          }    /* end if special cases */

        }
        break; /* end case default */
      }        /* end switch (me->event.response) */
      break;   /* end case TRACE_CURVES */

     /* Get the cross sections */
     case CROSS_CURVES:

        /* calculate new non-special skinning_case and update form if necessary */ 
        sts = om$send( msg = message ECplcskin.option_invalidation(),
                  targetid = my_id);
         ON_ERROR goto kill_command;

        event_mask = GRm_DATA | GRm_BACK_UP | GRm_RESTART;
        if ( (me->num_cross == 0)  || 
             ((me->num_cross == 1) && (me->num_trace > 2))      ||
             ((me->num_cross == 1) && (me->skinning_case == 3)) ||
             ((me->num_cross == 1) && (me->skinning_case == 4))  )

         key = EMS_P_SelScCurve  ;           /* Select cross section curve*/
        else
         {
          event_mask |= GRm_RJT_MOVEON;
          key =  EMS_P_IdntScMvOn;          /* Identify section curve/Moveon */
         }
        i = me->num_cross + 1;
        ex$message( msgnumb = key, buff = prompt)

        EFget_locate_information( BIG_CURVE, &loc_info);
        loc_info.identify_event_type = good_data;
        loc_info.acc_key = EMS_P_AcNxScRejt;   /* Accept with next section curve/Reject */
        loc_info.accept_event_type = chained;
        if (me->mytype == SOLID)               /* Locate nearly planar for sf */
           loc_info.planar_flag = LC_PLANAR_ONLY;
        if ( (i == 2 && me->skinning_case == 3) ||
             (i == 2 && me->skinning_case == 4) ||
             (i == 1 && me->skinning_case == 1) ||
             (i == 1 && me->skinning_case == 2)  )
        {
           loc_info.accept_event_type = dummy;
           loc_info.acc_key = EMS_P_00038;           /* Accept/Reject */
        }

        sts = om$send( msg = message ECconstruct.locate_object(
                                          event_mask,
                                          prompt,
                                          LC_NO_MSG,       /* No locate key, use string */
                                          &loc_info,
                                          FALSE,           /* Don't put accept event on queue */
                                          &put_on_queue,   /* Is possible to put accept event on queue? */
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
             sts = om$send( msg = message ECconstruct.backup_event(),
                       targetid = my_id);
             ON_ERROR goto kill_command;
             if (me->num_cross == 0)
             {
                /* handle special cases */
                if ( (me->num_trace == 1 && me->skinning_case == 1) ||
                     (me->num_trace == 1 && me->skinning_case == 3) ||
                     (me->num_trace == 2 && me->skinning_case == 2) ||
                     (me->num_trace == 2 && me->skinning_case == 4)  )
                {
                    me->num_trace--;
                    lc_info = &me->trcobj[me->num_trace];
                    is_curve_reversed = lc_info->geom_parms.polygon_inx;

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
                } /* end if num_cross=0 */ 
                me->state = TRACE_CURVES;
             }    /* end if special cases */ 
             else
             {
                me->num_cross--;
                lc_info = &me->crsobj[me->num_cross];
                is_curve_reversed = lc_info->geom_parms.polygon_inx;
/************************************************************************
                EFdisplay_curve_normal_or_tangent:
                                     lc_info,	The curve 
                                     NULL,	Not used for tangents 
                                     FALSE,	Display the tangent vector
                                     GRbe,	Erase
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
           sts = om$send( msg = message ECconstruct.restart(),
                     targetid = my_id);
           ON_ERROR goto kill_command;
           break;

        case EX_RJT_MOVEON:
           sts = om$send( msg = message ECconstruct.add_event( FALSE),    /* Not a located object */
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
           if (me->violation_msg_key)
           {
              ex$message(msgnumb = me->violation_msg_key,
                         field = KEYIN_FIELD,
                         justification = CENTER_JUS);
              me->violation_msg_key = NULL;
           }

           break;

        default:                  /* Object was located */
        {
           IGRboolean	valid_object = TRUE;
           IGRlong	current_size;
 
           sts = om$send( msg = message ECconstruct.add_event( TRUE),   /* It is a located object */
                     targetid = my_id);
            ON_ERROR goto kill_command;
           current_size = om$dimension_of(varray = me->crsobj);
           if (me->num_cross == current_size)
           {
              sts = om$vla_set_dimension( varray = me->crsobj,
                                            size = current_size + 10);
               ON_ERROR goto kill_command;
           }
           sts = EFdetermine_direction( &me->event, my_id, &msg);
            ON_ERROR goto kill_command;

           sts = EFgetprops( &me->event, my_id, &props, &msg);
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
              sts = om$send( msg = message ECconstruct.backup_event(),
                        targetid = my_id);
               ON_ERROR goto kill_command;
           }
           else
           {
/**************************************************************************
            EFdisplay_curve_normal_or_tangent:
                                    lc_info,	The curve 
                                    NULL,	Not used for tangents 
                                    FALSE,	Display the tangent vector 
                                    GRbd,	Draw background 
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
                 sts = ex$putque( msg = &msg,
                             response = &me->event1.response,
                                 byte = &sizeof_event,	/* Should be slightly less */
                               buffer = (IGRchar *)&me->event1.event);
                  ON_ERROR goto kill_command;
              } /* if (put_on_queue) */

              /* handle special cases */
              if ( (me->num_cross == 2 && me->skinning_case == 3) ||
                   (me->num_cross == 2 && me->skinning_case == 4) ||
                   (me->num_cross == 1 && me->skinning_case == 1) ||
                   (me->num_cross == 1 && me->skinning_case == 2)  )
              {
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
              } /* end if special cases */
           }    /* if (valid_object) */
         }
         break;
       } /* switch (me->event.response) */
       break;

     /* Determine if the surface to be generated should be closed.  */
     case SURFACE_CLOSED:
        key = EMS_P_00160;  /* Should the generated surface be closed? y/n [y] */
        event_mask = GRm_TEXT_VALUE | GRm_BACK_UP | GRm_RESTART;
        sts = om$send( msg = message ECconstruct.getevent(
                                                     NONE,     /* Don't need a value */
                                               event_mask,
                                                     NULL,     /* No prompt string */
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
             sts = om$send( msg = message ECconstruct.backup_event(),
                       targetid = my_id);
              ON_ERROR goto kill_command;

             /* handle special cases */
             if ( (me->num_cross == 1 && me->skinning_case == 1) ||
                  (me->num_cross == 1 && me->skinning_case == 2) ||
                  (me->num_cross == 2 && me->skinning_case == 3) ||
                  (me->num_cross == 2 && me->skinning_case == 4)  )
             {
                me->num_cross--;
                lc_info = &me->crsobj[me->num_cross];
                is_curve_reversed = lc_info->geom_parms.polygon_inx;
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

             me->state = CROSS_CURVES;
             break;

          case EX_RESTART:
             sts = om$send( msg = message ECconstruct.restart(),
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
                return(OM_S_SUCCESS);       /* Must have meant a command */

             sts = om$send( msg = message ECconstruct.add_event( FALSE),  /* Not a located object */
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
        if (me->tan_constrnt)
        {
           if ((! me->crosses_are_closed) || me->surface_is_open)
              me->state = TANGENT_SURFACES;
           else 
              me->state = PROCESS;
        }
        else
        {
           me->state = PROCESS;
        } /* end if tan_constrnt */
        break;

     /* Collect the supporting tangency surfaces, if any */
     case TANGENT_SURFACES:
        key = EMS_P_00161;       /* Identify surface for tangency/Move on */
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
         sts = dp$display( msg = &msg,
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
      EFget_locate_information( LITTLE_SURFACE, &loc_info);
      loc_info.accept_event_type = dummy;
      sts = om$send( msg = message ECconstruct.locate_object(
                                      event_mask,
                                      NULL,		/* No locate prompt */
                                      key,
                                      &loc_info,
                                      FALSE,            /* Don't put accept event on queue */
                                      &put_on_queue,    /* Is possible to put accept event on queue? */
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

         sts = om$send( msg = message ECconstruct.backup_event(),
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
           if (me->traces_are_closed && (me->num_cross > 1))
              me->state = SURFACE_CLOSED;
           else
           {
              /* handle special cases */
              if ( (me->num_cross == 1 && me->skinning_case == 1) ||
                   (me->num_cross == 1 && me->skinning_case == 2) ||
                   (me->num_cross == 2 && me->skinning_case == 3) ||
                   (me->num_cross == 2 && me->skinning_case == 4)  )
              {
                 me->num_cross--;
                 lc_info = &me->crsobj[me->num_cross];
                 is_curve_reversed = lc_info->geom_parms.polygon_inx;
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
              me->state = CROSS_CURVES;
           }
         }
         else
            me->num_tansf = previous_curve;
       }
       break;

       case EX_RESTART:
          sts = om$send( msg = message ECconstruct.restart(),
                    targetid = my_id);
           ON_ERROR goto kill_command;
          break;

       case EX_RJT_MOVEON:
       default:                  /* Object was located */
       {
         IGRboolean	not_finished = TRUE, located_surface;

         located_surface = (me->event.response != EX_RJT_MOVEON);
         sts = om$send( msg = message ECconstruct.add_event( located_surface),  /* It is a located object */
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
            me->state = PROCESS;
        }
        break;
      } /* switch (me->event.response) */
      break;

     case PROCESS:
        /*may be the form should not be erased at this point*/
        if (me->form_requested)
        {
           me->form_requested = FALSE;
           FIf_erase(me->form1);
        } /* if (me->form_requested) */

        /* delete violation messages */
        ex$message ( field = KEYIN_FIELD, msgnumb = EMS_I_00000);

        /* Determine if the orientation of the cross sections w.r.t. the trace
         * should be absolute or relative for the auto case  */
        if (me->auto_orientation)
        {
           IGRboolean found_point;

           found_point = FALSE;
           if ((me->num_trace < 3) && (me->num_cross >= 2))
           {
              /* handling special case first/last cs = point => absolute */
              for (i=0;i<me->num_cross;i+=me->num_cross-1)
              {
                 if (EFisAncestryValid(&msg, me->crsobj[i].located_obj.objid,
                                       me->crsobj[i].located_obj.osnum,
                                       OPP_GRpoint_class_id, FALSE))
                 {
                    found_point  = TRUE;
                    break;
                 }
              }
           }
           if (found_point)
              me->absolute_orientation = TRUE;
           else 
              me->absolute_orientation = FALSE;
        }

        /* Unhighlight all the geometry */
        ex$message(msgnumb = EMS_P_00000)
        ex$message(msgnumb = EMS_I_00004, type = "%s", var = " . ")
        pos = EX_suspend;
        sts = om$send( msg = message super_cmd.sleep( pos),
                  targetid = my_id);
         ON_ERROR goto kill_command;

        /* Turn associative button on again (sleep changed it) */
        if (me->associative)
           GRdisplay_associative_button(TRUE);

        /* Get the construct list */
        sts = om$send( msg = message ECconstruct.load_construction_information(),
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
           * (deleted NDmove_to_root since it is done down stream)
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
         sts = om$send( msg = message ECconstruct.display_constructed_object(DisplayMode),
                   targetid = my_id);
          ON_ERROR goto kill_command;
         ex$message(msgnumb = EMS_I_00000)
        }

        /* Clear my memory for a fresh start */
        me->state = previous_state + 1;  /* see backup_event() and last_state_to_first_state() */
        sts = om$send( msg = message ECconstruct.last_state_to_first_state(),
                  targetid = my_id);
         ON_ERROR goto kill_command;
       }
      break;

     /* Something has messed up our state table */
     default:
      goto kill_command;
    }
 }
 while(TRUE);

/* Kill the command */
kill_command:
 CMD_KILL
}

method display_constructions( IGRboolean draw_background; IGRboolean draw_single)
{
 enum		GRdpmode mode;   
 IGRboolean	is_curve_reversed;
 IGRlong	i, sts;
 struct		GRlc_info *lc_info;

 /* Initialize */
 me->msg = MSSUCC;
 if (draw_single) return(OM_S_SUCCESS);

 /* Draw the vectors */
 mode = (draw_background ? GRbd : GRbe);
 for (i = 0; i < me->num_trace; i++)
 {
   lc_info = &me->trcobj[i];
   is_curve_reversed = lc_info->geom_parms.polygon_inx;
    
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
   EFdisplay_curve_normal_or_tangent:
                    lc_info,		The curve 
                    NULL,		Not used for tangents 
                    FALSE,		Display the tangent vector 
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

 /* eof */
 return(OM_S_SUCCESS);
}

/*
 * It is important that this method not modify the variable
 * me->msg as this screws up the locate filter.  In general,
 * this method should be extremely careful about modifying
 * any instance data.
 */

method update_status_form()
{
 char  alpha[132];

  FIg_display (me->form1,SkOp_COMPOSITE_TGL);
  FIg_display (me->form1,SkOp_SMOOTH_TGL);
  FIg_display (me->form1,SkOp_TANGENCY_TGL);

  if (me->active_form == SHAPE_OPTIONS_FORM)
     FIg_display (me->form1,SkOp_HTSCALING_TGL);
 
  if (me->create_composite == 0)
     FIg_set_state_on (me->form1, SkOp_COMPOSITE_TGL);
  else if (me->create_composite == 1)
      FIg_set_state_off (me->form1, SkOp_COMPOSITE_TGL);

  if (me->smooth == 0)
     FIg_set_state_on (me->form1, SkOp_SMOOTH_TGL);
  else if (me->smooth == 1)
     FIg_set_state_off (me->form1, SkOp_SMOOTH_TGL);

  if (me->tan_constrnt == 1)
     FIg_set_state_on (me->form1, SkOp_TANGENCY_TGL);
  else if (me->tan_constrnt == 0)
     FIg_set_state_off (me->form1, SkOp_TANGENCY_TGL);

  if (me->no_height_scaling == 1)
     FIg_set_state_on (me->form1, SkOp_HTSCALING_TGL);
  else if (me->no_height_scaling == 0)
     FIg_set_state_off (me->form1, SkOp_HTSCALING_TGL);

  strcpy(alpha, me->shape_law);
  FIfld_set_text(me->form1, SkOp_LAWCRV_TXT, 0, 0, alpha);
  
  /* disable or enable shape gadgets dependend on configuration */
  if (me->active_form == SHAPE_OPTIONS_FORM)
  { 
     SkOp_set_skinn_option (me->surface_is_open, me->skinning_case, me->form1);
  }

 return(OM_S_SUCCESS);
}


void SkOp_set_skinn_option (IGRboolean surface_is_open,
                            int SkOp_options_case, Form fp )

/*
NAME
        SkOp_set_skinn_option

DESCRIPTION
        This function will update the shape gadgets of the options form dependend
        on configuration of traces/cross-sections.
 
SYNOPSIS
        extern void SkOp_set_skinn_option (IGRboolean surface_is_open,
                                           int SkOp_options_case, Form fp )

PARAMETERS
   SkOp_options_case (IN)       - case of trace/cross-section configuration
   fp (IN)                      - Pointer to the form
   surface_is_open (IN)         - same as me->surface_is_open

NOTES
HISTORY
        01/03/94    Ralf Burkhart 
*/

{
   struct SkOp_options_switch
   {
      IGRboolean	height_shape;	/* height scaling option enabled or disabled */
      IGRboolean	law_shape;	/* shape law curve option enabled or disabled */
      IGRboolean	orient_control;	/* orientation option enabled or disabled */
   };
 
   static struct SkOp_options_switch swf[] =
                            {                       /*   traces    sections  main case  */ 
                               { 0, 0, 0 },         /*     dummy case                   */
                               { 0, 0, 1 },         /*     1           1         x      */
                               { 1, 0, 1 },         /*     2           1         x      */
                               { 0, 1, 1 },         /*     1           2         x      */
                               { 1, 1, 1 },         /*     2           2         x      */
                               { 1, 1, 1 },         /*     0           0         x      */
                               { 0, 1, 1 },         /*     1           0                */
                               { 0, 0, 1 },         /*     1           1                */
                               { 0, 1, 1 },         /*     1           2                */
                               { 0, 0, 1 },         /*     1           3+               */
                               { 1, 0, 1 },         /*     2           1 /\ 0           */
                               { 1, 1, 1 },         /*     2           2                */
                               { 1, 0, 1 },         /*     2           3                */
                               { 0, 0, 1 },         /*     2           3<               */
                               { 0, 0, 0 }          /*     3           0+               */
                            };
   {
      if ( swf [SkOp_options_case].height_shape )
      {
         FIg_enable  ( fp, SkOp_HTSCALING_TGL );
         FIg_enable  ( fp, SkOp_HTSCALING_TXT );
      } 
      else
      {
         FIg_disable ( fp , SkOp_HTSCALING_TGL ); 
         FIg_disable ( fp , SkOp_HTSCALING_TXT ); 
      } 
      if ( swf [SkOp_options_case].law_shape && surface_is_open)
      {
         FIg_enable  ( fp, SkOp_LAWCRV_FLD );
         FIg_enable  ( fp, SkOp_LAWCRV_TXT );
      } 
      else
      {
         FIg_disable ( fp , SkOp_LAWCRV_FLD );
         FIg_disable ( fp , SkOp_LAWCRV_TXT );
      } 
      if ( swf [SkOp_options_case].orient_control )
      {
         FIg_enable  ( fp, SkOp_ORIENT_BTN );
         FIg_enable  ( fp, SkOp_ORIENT_BTN_REL );
         FIg_enable  ( fp, SkOp_ORIENT_BTN_ABS );
         FIg_enable  ( fp, SkOp_ORIENT_TXT );
      } 
      else
      {
         FIg_disable ( fp , SkOp_ORIENT_BTN );
         FIg_disable ( fp , SkOp_ORIENT_BTN_REL );
         FIg_disable ( fp , SkOp_ORIENT_BTN_ABS );
         FIg_disable ( fp , SkOp_ORIENT_TXT );
      } 
   }
}

method status_disp()

{
  IGRlong status, EMmsg;
  int display_status, ret;

  status = OM_S_SUCCESS;
  EMmsg = 1;

  if (me->state != CASE_SELECT)
  {
     status = om$send(msg = message ECconstruct.update_status_form(),
                 targetid = my_id);

      if (me->active_form == GLOBAL_OPTIONS_FORM)
      {
         FIf_is_displayed( me->op_form1, &display_status );
         if ( ! display_status )
         {
            ret = FIf_display(me->op_form1);
            if (ret) { status = FALSE; goto wrapup; }
            me->form_requested = TRUE;
         }
      }
      else
      {
         FIf_is_displayed( me->op_form2, &display_status );
         if ( ! display_status )
         {
            ret = FIf_display(me->op_form2);
            if (ret) { status = FALSE; goto wrapup; }
            me->form_requested = TRUE;
         }
      }
   }   

wrapup:
 if (!(1&status&EMmsg))
   return (OM_E_ABORT);
 return (status);
}

IGRint ECplcskin_process_form (form_label, gadget_label, value, form_ptr)
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

  stat_OM = om$send (msg = message ECplcskin.do_form (&msg_loc, form_label,
                     gadget_label, value, form_ptr),
             senderid = NULL_OBJID, targetid = cmdobj, targetos = cmdos);
  if (!(stat_OM & 1))
    return (OM_E_ABORT);

return (stat_OM);
}


/*
NAME
        do_form

DESCRIPTION
        Notification method of Skinning options forms, which is invoked from
        function ECplcskin_process_form.
NOTES
        It is important that this method not modify the variable
        me->msg as this screws up the locate filter.  In general,
        this method should be extremely careful about modifying
        any instance data.
HISTORY
        12/20/93    Ralf Burkhart
*/

method do_form(IGRlong *msg; IGRint form_label; IGRint gadget_label;
               IGRdouble value; Form fp)
{
  IGRboolean	update_form;
  int  display_status, form_mask;

  /* Initialize */
  update_form = TRUE;
  value = value;

 /* Branch based on the form label which was affected. */

  switch ( form_label )
  {
    case GLOBAL_OPTIONS_FORM:
    case SHAPE_OPTIONS_FORM:
       switch ( gadget_label )
       {
         case FI_CVT_TO_PERM_WIN:
            FIf_cvrt_to_perm_win ( fp );
            if ( me->active_form == SHAPE_OPTIONS_FORM)
               me->chk_perm_form = TRUE;
            break;

         case FI_ACCEPT:
            update_form = FALSE;
            FIg_set_state_off (fp, gadget_label);
            me->form_requested = FALSE;
            FIf_erase(fp);
            GRstatus_display_button(1);
            break;

         case SkOp_COMPOSITE_TGL:
            GS_composite = me->create_composite = (me->create_composite ? FALSE : TRUE);
            if (me->create_composite == 0){
               FIg_set_state_off (fp, gadget_label);
               }
            else if (me->create_composite == 1){
               FIg_set_state_on (fp, gadget_label);
               }
            break;

         case SkOp_SMOOTH_TGL:
            GS_smooth = me->smooth = (me->smooth ? FALSE : TRUE);
            if (me->smooth == 0){
               FIg_set_state_off (fp, gadget_label);
               }
            else if (me->smooth == 1){
               FIg_set_state_on (fp, gadget_label);
               }
            break;

         case SkOp_TANGENCY_TGL:
            GS_tansf = me->tan_constrnt = (me->tan_constrnt ? FALSE : TRUE);
            if (me->tan_constrnt == 1){
               FIg_set_state_off (fp, gadget_label);
               }
            else if (me->tan_constrnt == 0){
               FIg_set_state_on (fp, gadget_label);
               }
            break;

         case SkOp_SHAPE_BTN:
            FIf_delete(fp);
            me->active_form = SHAPE_OPTIONS_FORM;
            me->form1 = me->op_form2;

            /* set save_restore bit of form */
            FIf_get_attr(me->op_form2, &form_mask);
            form_mask |= FI_SAVE_RESTORE;
            FIf_set_attr(me->op_form2, form_mask);

            om$send(msg = message ECconstruct.update_status_form(),
               targetid = my_id);
            FIf_display(me->op_form2);
            break;

         case SkOp_HTSCALING_TGL:
            me->no_height_scaling = (me->no_height_scaling ? FALSE : TRUE);
            if (me->no_height_scaling == 1){
               FIg_set_state_off (fp, gadget_label);
               }
            else if (me->no_height_scaling == 0){
              FIg_set_state_on (fp, gadget_label);
              }
            break;

         case SkOp_ORIENT_BTN:
         case SkOp_ORIENT_BTN_REL:
         case SkOp_ORIENT_BTN_ABS:
            FIg_set_state_on (fp, gadget_label);

            /* unset save_restore bit of me->op_form2 */
            FIf_erase (fp);
            FIf_get_attr(fp, &form_mask);
            form_mask &= ~FI_SAVE_RESTORE;
            FIf_set_attr(fp, form_mask);
            FIf_display (fp);

            /* update and display subform */
            FIf_get_attr(me->subform, &form_mask);
            form_mask |= FI_SAVE_RESTORE;
            FIf_set_attr(me->subform, form_mask);
            /* set position of subform relative to SHAPE_OPTIONS_FORM */
            FIf_set_rel_location (me->subform, 308, 51, me->op_form2);
            FIf_display (me->subform );
            break;

         case SkOp_LAWCRV_FLD:
         {
          extern             void EMget_lawcurve();
          IGRchar            *string, str[132];
          IGRint             sel, rpos;
          IGRlong            msg, curve_index;

          string = me -> shape_law;
          FIfld_get_text (fp, gadget_label, 0,0, 132, str, &sel, &rpos);
          if (str[0] == '\0')
             string[0] = '\0';
          else
          {
             EMget_lawcurve( &msg, str,&curve_index, NULL);
               /* NULL - because we don't want the law curve geometry */
             if ((1 & msg) && (msg != EMS_I_NotFound))
             {
                strcpy( string, str);
             } /* if law was valid */
          }
         }
         break;

         default:
            update_form = FALSE;
            break;

       } /* END switch ( gadget_label ) */
       break;

    case ORIENT_OPTIONS_FORM:
       FIf_erase( me->subform );
       /* set save_restore bit of me->op_form2 */
       if (!(me->chk_perm_form))
       {
            FIf_erase (me->op_form2);
            FIf_get_attr(me->op_form2, &form_mask);
            form_mask |= FI_SAVE_RESTORE;
            FIf_set_attr(me->op_form2, form_mask);
            FIg_enable(me->op_form2,5);
       }
       FIg_is_displayed( me->op_form2,SkOp_ORIENT_BTN_REL, &display_status );
          if ( display_status )
          {
            FIg_erase(me->op_form2, SkOp_ORIENT_BTN_REL);
          }
       FIg_is_displayed( me->op_form2,SkOp_ORIENT_BTN_ABS, &display_status );
          if ( display_status )
          {
            FIg_erase(me->op_form2, SkOp_ORIENT_BTN_ABS);
          }
       FIg_is_displayed( me->op_form2,SkOp_ORIENT_BTN, &display_status );
          if ( display_status )
          {
            FIg_erase(me->op_form2, SkOp_ORIENT_BTN);
          }


       switch ( gadget_label )
       {
         case SkOp_AUTO_ORIENT_BTN:
            FIg_display(me->op_form2, SkOp_ORIENT_BTN);
            me->auto_orientation = TRUE;
            break;

         case SkOp_REL_ORIENT_BTN:
            FIg_display(me->op_form2, SkOp_ORIENT_BTN_REL);
            me->auto_orientation = FALSE;
            me->absolute_orientation = FALSE;
            break;

         case SkOp_ABS_ORIENT_BTN:
            FIg_display(me->op_form2, SkOp_ORIENT_BTN_ABS);
            me->auto_orientation = FALSE;
            me->absolute_orientation = TRUE;
            break;

       } /* END switch ( gadget_label ORIENT_OPTIONS_FORM) */
       FIf_display (me->op_form2);
       break;

  } /* END switch ( form_label ) */

  /* Update the form, if required */
  if (update_form)
  {
     om$send( msg = message ECconstruct.update_status_form(),
         targetid = my_id);
   }

   return(OM_S_SUCCESS);
} 

method create_form (int form_label;
                    char *form_name; Form *form)
{
        int status, form_mask;
        IGRint ECplcskin_process_form();


        status = FIf_new(form_label, form_name, ECplcskin_process_form, form);
        if (status != FI_SUCCESS)
        {
                return(OM_E_ABORT);
        }
        status = FIf_set_cmd_oid_os(*form, my_id, OM_Gw_current_OS);
        if (status != FI_SUCCESS)
        {
                return(OM_E_ABORT);
        }
        /* unset save_restore bit of form */
        FIf_get_attr(*form, &form_mask);
        form_mask &= ~FI_SAVE_RESTORE;
        FIf_set_attr(*form, form_mask);
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

method init(int type; char *str_ptr)
{

   IGRint status;
   int form_mask;

   status = OM_S_SUCCESS;

   /* let the parents work */
   status = om$send( msg = message ECconstruct.init(type, str_ptr),
                targetid = my_id,
                    mode = OM_e_wrt_message);
    if(!(1&status)){goto wrapup;}

   /* initialize option forms */
   status =  om$send( msg = message ECplcskin.create_form(GLOBAL_OPTIONS_FORM,
                                                  "EMskin2.frm",&me->op_form1),
              targetid = my_id);
    if(!(1&status)){goto wrapup;}
   FIf_set_location (me->op_form1, 0, 125);
   me->active_form  = GLOBAL_OPTIONS_FORM;
   me->form1 = me->op_form1;

   /* set save_restore bit of form */
   FIf_get_attr(me->op_form1,&form_mask);
   form_mask |= FI_SAVE_RESTORE;
   FIf_set_attr(me->op_form1,form_mask);

   status = om$send( msg = message ECplcskin.create_form(SHAPE_OPTIONS_FORM,
                                               "EMskin2a.frm",&me->op_form2),
                targetid = my_id);
    if(!(1&status)){goto wrapup;}
   FIf_set_location (me->op_form2, 0, 125);

   status = om$send( msg = message ECplcskin.create_form(ORIENT_OPTIONS_FORM,
                                                 "EMskin2b.frm",&me->subform),
                targetid = my_id);
    if(!(1&status)){goto wrapup;}

   /* set special start values of the command */
   me->state = CASE_SELECT;
   me->auto_orientation = TRUE;
   me->absolute_orientation = FALSE;
   me->no_height_scaling = FALSE;
   me->chk_perm_form = FALSE;

wrapup:
   if (!(status & 1))
     return (OM_E_ABORT);

 return(status); 

}


method sleep(int pos)
{
   IGRint status;
   int display_status, ret;

   status = OM_S_SUCCESS;

   FIf_is_displayed( me->subform, &display_status );
   if ( display_status )
   {
      ret = FIf_erase(me->subform);
       if (ret) { status = FALSE; goto wrapup; }
   }

   /* delete violation messages */
   ex$message ( field = KEYIN_FIELD, msgnumb = EMS_I_00000);


   /* let the parents work */
   status = om$send( msg = message ECconstruct.sleep(pos),
                senderid = NULL_OBJID,
                targetid = my_id,
                    mode = OM_e_wrt_message);
    if(!(1&status)){goto wrapup;}

wrapup:
   if (!(status & 1))
     return (OM_E_ABORT);

 return(status);

}

end implementation ECplcskin;
