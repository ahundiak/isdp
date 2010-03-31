/* ###################   APOGEE COMPILED   ################## */
/*
 Description

 This file contains the next event processing, verify event,
 perform construction, perform dynamics, and display construction
 methods for the following commands:

                 Command                      my_type
        ----------------------------------    -------
	Place curve by poles - linestring	54
	Place convex fit curve			55
	Place direct fit curve			56
	Place least squares fit curve		57
						--
	Place fitted curve			116

 History

 12/14/87 : rlw : The beginning
 12/16/87 : rlw : Added checks for the periodic case
 12/23/87 : rlw : Added code to support element specific data
 02/11/88 : rlw : Modified such that on least squares fit if fit order is 2
                  then skip tangent vector and # sections questions.
 09/05/88 : rlw : Added curve fitting via data reduction
                  Move error reporting on fits to a function
 01/24/89 : rlw : Modified check on place fitted curve such that stroking
                  can be performed on non-linear curves before fitting.
                  Also reversed the way the end tangent vector is computed.
 02/28/89 : rlw : Modified to add conditional compilation statements
                  for the I/DRAW product.
 09/27/89 : rlw : Modified to allow reference knot vector for least squares
                  fit curve command.
 12/01/89 : rlw : Added check to ensure a curve is located for lsq fit curve
                  when asking for reference curve.
 10/08/92 :Carlos:Fixed problem with least squares curve not being computed
                  correctly.

 */

class implementation ECfitcur;

%safe
#include <math.h>
%endsafe

#include "EMS.h"		/* Shared library stuff */
#include "ems_m_inc.h"		/* Includes everything */
#include "OMmacros.h"		/* OM_BLOCK_MOVE stuff */
#include "EC_P.h"		/* Message keys for prompt strings */
#include "EC_I.h"		/* Message keys for status strings */
#include "EMSasopts.h"

#define BIG_CURVE 0
#define LITTLE_CURVE 1
#define LITTLE_SURFACE 2

from GRcurve import GRendpts;
from GRsubbc import EMleast_squares_fit_curvee;
#ifndef IDRAW
from GRsubbc import EMcurve_by_poles;
from GRsubbc import EMdirect_fit_curve;
from GRsubbc import EMconvex_fit_curve;
#endif

extern OMuword OPP_GRbcsubbc_class_id;

method next_event_processing(
 IGRchar	*prompt_string;
 IGRlong	*prompt_index;
 IGRlong	*event_mask;
 IGRlong	*type_of_value_needed;
 IGRboolean	*locate_desired;
 struct		RLW_locate_info *loc_info)

{
 extern		void EFget_locate_information();
 extern		IGRlong EFgetabstract();
 IGRboolean	message_not_encoded;
 IGRlong	sts, key, *my_msg, my_type;
/*
 * Compiler optimizations
 */
 my_msg = &me->msg;
 my_type = me->mytype;
/*
 * Initialize
 */
 *my_msg = MSSUCC;
 message_not_encoded = TRUE;
/*
 * Branch based on the command state
 */
 switch (me->number_of_events_input)
  {
/*
 * Event 1 prompt
 */
   case 0:
    *locate_desired = TRUE;
    EFget_locate_information(BIG_CURVE, loc_info);
    key = EMS_P_00087;
    loc_info->accept_event_type = dummy;
    loc_info->relocate_key = EMS_I_00021;
    break;
/*
 * Event 2 prompt
 */
   case 1:
    key = EMS_P_00084;
    *event_mask |= GRm_RJT_MOVEON;
    break;
/*
 * Event 3 prompt
 */
   case 2:
    key = EMS_P_00085;
    *event_mask |= GRm_RJT_MOVEON;
    break;
/*
 * Event 4 prompt
 */
   case 3:
    {
     IGRlong	base, height;
     struct	IGRbsp_curve *curve;

     *type_of_value_needed = SCALAR;
     key = EMS_P_00086;
     message_not_encoded = FALSE;
     if (me->u_periodic)
      base = 3;
     else
      base = 1;        
     sts = EFgetabstract(
       &me->events[0],
       my_id,
       &curve,
       my_msg);
      if (! (1 & sts)) goto wrapup;
     if (curve->order == 2)
      {
       height = curve->num_poles - 1;
       ex$message(
        msgnumb = key,
        type = "%d%d%d",
        var = `base, height, base`,
        buff = prompt_string);
      }
     else
      {
       ex$message(
        msgnumb = key,
        type = "%d%c%d",
        var = `base, '?', base`,
        buff = prompt_string);
      }
    }
    break;
/*
 * Event 5 prompt
 */
   case 4:
    key = EMS_P_00061;
    *event_mask |= GRm_RJT_MOVEON;
    break;
/*
 * Error 
 */
   default:
    *my_msg = MSFAIL;
    goto wrapup;
  } /* switch (me->number_of_events_input) */
/*
 * Fix the event mask
 */
 if (*type_of_value_needed)
  *event_mask |= GRm_VALUE;
/*
 * Get the prompt string
 */
 if (message_not_encoded)
  {
   ex$message(
    msgnumb = key,
    buff = prompt_string);
  }
/*
 * eof
 */
wrapup:
 if (1 & *my_msg)
  return(OM_S_SUCCESS);
 else
  return(OM_E_ABORT);
}

method verify_event(
 IGRboolean	use_default;
 IGRboolean	*was_valid_event;
 IGRboolean	*done)

{
 extern		IGRlong EFgetabstract();
 IGRlong	key, sts, *my_msg, my_type;
 struct		GRevent *event;
/*
 * Compiler optimizations
 */
 my_msg = &me->msg;
 my_type = me->mytype;
/*
 * Initialize
 */
 *my_msg = MSSUCC;
 *done = FALSE;
 key = EMS_I_00022;
 *was_valid_event = TRUE;
 event = &me->events[me->number_of_events_input - 1];
/*
 * Branch based on the command state
 */
 switch (me->number_of_events_input)
  {
/*
 * Event 1 verification
 */
   case 1:
    {
     IGRboolean	get_my_endpoints;
     struct	IGRbsp_curve *curve;

     get_my_endpoints = FALSE;
/*
 * Find out how many points we are talking about
 */
     sts = EFgetabstract(
       event,
       my_id,
       &curve,
       my_msg);
      if (! (1 & sts)) goto wrapup;
     switch (my_type)
      {
#ifndef IDRAW
       case 54:		/* By poles */
        if ((curve->num_poles < me->u_order) ||
            (me->u_periodic && (curve->num_poles < 4)))
         *was_valid_event = FALSE;
        else
         *done = TRUE;
        break;
       case 55:		/* Convex fit */
        if (curve->num_poles < 4)
         *was_valid_event = FALSE;
        else
         get_my_endpoints = TRUE;
        break;
       case 56:		/* Direct fit */
        if ((curve->num_poles < me->u_order) ||
            (me->u_periodic && (curve->num_poles < 4)))
         *was_valid_event = FALSE;
        else if (me->u_periodic)
         *done = TRUE;
        else
         get_my_endpoints = TRUE;
        break;
       case 57:		/* Lsq fit */
        if (me->u_order == 2)
         {
          me->events[3].event.value = 1.0;   /* Not data reduction fit */
          *done = TRUE;
         }
        else if (((curve->num_poles < me->u_order) ||
                  (me->u_periodic && (curve->num_poles < 4))) &&
                 (curve->order == 2)) 
         *was_valid_event = FALSE;
        else if (me->u_periodic)	/* Push 2 dummy events on the stack */
         {
          IGRlong	i;

          me->event.subtype = GRst_DEFAULT;
          me->event.response = EX_MAX_RESPONSE;
          for (i = 0; i < 2; i++)
           {
            sts = om$send(
              msg = message ECconstruct.add_event(FALSE),
              targetid = my_id);
             if (! (1 & sts)) goto wrapup;
           }
         } /* else if (me->u_periodic) */
        else
         get_my_endpoints = TRUE;
        break;
#endif
       case 116:	/* Data reduction fit */
        if (me->u_order == 2)
         *done = TRUE;
        else if ((curve->order == 2) &&
                 (! curve->rational) &&
                 (curve->num_poles < me->u_order))
         *was_valid_event = FALSE;
        else
         get_my_endpoints = TRUE;
        break;
       default:
        *my_msg = MSFAIL;
        goto wrapup;
      } /* switch (my_type) */
     if (get_my_endpoints)
      {
       struct		GRlc_info *loc_info;
       struct		GRid *id;
       struct		GRmdenv_info *mdenv_info;

       loc_info = &event->located_object[0];
       id = &loc_info->located_obj;
       mdenv_info = &loc_info->module_info.md_env;
       sts = om$send(
         msg = message GRcurve.GRendpts(
          my_msg,
          &mdenv_info->matrix_type,
          mdenv_info->matrix,
          loc_info->proj_pnt,				/* 1st end point */
          &event->located_object[1].proj_pnt[0]),	/* 2nd end point */
         targetid = id->objid,
         targetos = id->osnum);
        if (! (1 & sts)) goto wrapup;
      } /* if (get_my_endpoints) */
    }
    break;
/*
 * Event 2 verification - Begin tangent
 */
   case 2:
/*  noop; */ 
    break;
/*
 * Event 3 verification - End tangent
 */
   case 3:
    switch (my_type)
     {
      case 55:
      case 56:
      case 116:
       *done = TRUE;
       break;
      default:
/*     noop; */
       break;
     } /* switch (my_type) */
    break;
/*
 * Event 4 verification - # polynomial sections
 */
   case 4:
#ifndef IDRAW
    {
     IGRlong	base, height;
     struct	IGRbsp_curve *curve;

     if (event->response == EX_DATA)
      {
       if ((me->event.subtype != GRst_REGULAR) &&
           me->event.num_id)
        {
         extern	IGRlong EFgetprops();
         struct	GRprops properties;

         sts = EFgetprops(
           event,
           my_id,
           &properties,
           my_msg);
          if (! (1 & sts)) goto wrapup;
         if (properties.type == GRCURVE)
          {
           sts = EFgetabstract(
             event,
             my_id,
             &curve,
             my_msg);
            if (! (1 & sts)) goto wrapup;
           if (curve->order > me->u_order)
            {
             *was_valid_event = FALSE;
             key = EMS_I_00102;
            }
          } /* if (properties.type == GRCURVE) */
         else
          {
           *was_valid_event = FALSE;
           key = EMS_I_00010;
          } /* ELSE FOR if (properties.type == GRCURVE) */
        }
       else
        {
         *was_valid_event = FALSE;
         key = EMS_I_00010;
        }
      } /* if( event->response == EX_DATA) */
     else
      {
       if (me->u_periodic)
        base = 3;
       else
        base = 1;        
       if (use_default)
        event->event.value = base;
       else if (event->event.value < base)
        *was_valid_event = FALSE;
       else
        {
         sts = EFgetabstract(
           &me->events[0],
           my_id,
           &curve,
           my_msg);
          if (! (1 & sts)) goto wrapup;
         if (curve->order == 2)
          {
           height = curve->num_poles - 1;
           if (event->event.value > height)
            *was_valid_event = FALSE;
          }
        }
       if (*was_valid_event)
        *done = TRUE;
       else
        key = EMS_I_00009;
      } /* ELSE FOR if (event->response == EX_DATA) */
    }
#endif
    break;
/*
 * Event 5 verification - correct flow direction
 */
   case 5:
#ifndef IDRAW
    {
     IGRboolean		*reversed;

     *done = TRUE;
     reversed = &me->events[3].located_object[0].geom_parms.polygon_inx;
     if (event->response == EX_DATA)
      *reversed = FALSE;
     else
      *reversed = TRUE;
    }
#endif
    break;
/*
 * Error 
 */
   default:
    *my_msg = MSFAIL;
    goto wrapup;
  } /* switch (me->number_of_events_input) */
/*
 * Output the error message, if any
 */
 if (! *was_valid_event)
  ex$message(msgnumb = key)
/*
 * eof
 */
wrapup:
 if (1 & *my_msg)
  return(OM_S_SUCCESS);
 else
  return(OM_E_ABORT);
}

method perform_construction()
{
 OMuword	space_number;
 IGRboolean	periodic;
 IGRlong	order, sts, *my_msg, mytype, max_indicator;
 IGRdouble	average_error, maximum_error;
 IGRpoint	points[20], error_line[2];
 IGRvector	*beg_tan, *end_tan;
 IGRvector	start_tangent, end_tangent;
 GRobjid	*my_constructed_object;
 struct		GRvg_construct *my_construct_list;
 struct		GRlc_info *linestring, *reference_curve;
 struct		IGResbs *surface_specific;
 struct		IGResbc curve_specific;
/*
 * Compiler code reductions
 */
 my_msg = &me->msg;
 my_construct_list = &me->construct_list;
 my_constructed_object = &me->constructed_object;
 periodic = me->u_periodic;
 order = me->u_order;
 mytype = me->mytype;
/*
 * Initialize
 */
 *my_msg = MSSUCC;
 *my_constructed_object = NULL_OBJID;
 space_number = me->construct_env.md_id.osnum;
 EFextract_points(
  me->number_of_events_input,
  me->events,
  points);
 linestring = &me->events[0].located_object[0];
 reference_curve = NULL;
 OM_BLOCK_MOVE(
  linestring->proj_pnt,
  points[0],
  sizeof(IGRpoint));
 OM_BLOCK_MOVE(
  &me->events[0].located_object[1].proj_pnt[0],
  points[3],
  sizeof(IGRpoint));
 beg_tan = (IGRvector *)&start_tangent[0];
 end_tan = (IGRvector *)&end_tangent[0];
 surface_specific = (struct IGResbs *) my_construct_list->class_attr;
/*
 * Fix the element specific attributes
 */
 curve_specific.is_polydis = surface_specific->is_polydis;
 curve_specific.is_curvedis = TRUE;
 my_construct_list->class_attr = (IGRchar *) &curve_specific;
/*
 * Construct the curve
 */
 switch (mytype)
  {
#ifndef IDRAW
   case 54:
    sts = om$construct(
      classid = OPP_GRbcsubbc_class_id,
      msg = message GRsubbc.EMcurve_by_poles(
       order,
       periodic,
       NULL,
       NULL,
       linestring,
       my_construct_list),
      p_objid = my_constructed_object,
      osnum = space_number);
    break;
#endif
   case 55:
   case 116:
    periodic = FALSE;
/*  no break on purpose */
   case 56:
   case 57:
    if (periodic ||
        ((order == 2) && ((mytype == 57) || (mytype == 116))))
     {
      beg_tan = NULL;
      end_tan = NULL;
     }
    else
     {
      if (me->events[1].response == EX_RJT_MOVEON)
       beg_tan = NULL;
      else
       {
        start_tangent[0] = points[1][0] - points[0][0];
        start_tangent[1] = points[1][1] - points[0][1];
        start_tangent[2] = points[1][2] - points[0][2];
       }
      if (me->events[2].response == EX_RJT_MOVEON)
       end_tan = NULL;
      else
       {
        end_tangent[0] = points[3][0] - points[2][0];
        end_tangent[1] = points[3][1] - points[2][1];
        end_tangent[2] = points[3][2] - points[2][2];
       }     
     }
    switch (me->mytype)
     {
#ifndef IDRAW
      case 55:
       sts = om$construct(
         classid = OPP_GRbcsubbc_class_id,
         msg = message GRsubbc.EMconvex_fit_curve(
          NULL,
          NULL,
          linestring,
          beg_tan,
          end_tan,
          my_construct_list),
         p_objid = my_constructed_object,
         osnum = space_number);
       break;
      case 56:
       sts = om$construct(
         classid = OPP_GRbcsubbc_class_id,
         msg = message GRsubbc.EMdirect_fit_curve(
          order,
          periodic,
          NULL,
          NULL,
          linestring,
          beg_tan,
          end_tan,
          my_construct_list),
         p_objid = my_constructed_object,
         osnum = space_number);
       break;
#endif
      case 57:
       if (me->events[3].response == EX_DATA)
        reference_curve = &me->events[3].located_object[0];
       sts = om$construct(
         classid = OPP_GRbcsubbc_class_id,
         msg = message GRsubbc.EMleast_squares_fit_curvee(
          order,
          periodic,
          NULL,
          NULL,
          linestring,
          beg_tan,
          end_tan,
          me->events[3].event.value,
          reference_curve,
          &average_error,
          &maximum_error,
          &max_indicator,
          error_line,
          my_construct_list),
         p_objid = my_constructed_object,
         osnum = space_number);
        break;
      case 116:
       sts = GAbcsubbc_AScurve_by_data_reduction_func(my_msg,
                         (me->associative ? NULL : EMSasconst_notassociative),
                                          order,
                                          beg_tan,
                                          end_tan,
                                          linestring,
                                          my_construct_list,
                                          my_constructed_object,
                                          &average_error,
                                          &maximum_error,
                                          &max_indicator,
                                          error_line);
       break;
     } /* switch (me->my_type) */
    break;
   default:
    *my_msg = MSFAIL;
    break;
  } /* switch (mytype) */
 if (! (1 & sts)) 
  *my_msg = MSFAIL;
/*
 * Special processing for least squares
 */
 else if (((mytype == 57) || (mytype == 116)) &&
          (max_indicator != -1))
  {
   extern	IGRlong EFreport_fit_errors();
   IGRlong	sts;

   sts = EFreport_fit_errors(
     maximum_error,
     average_error,
     error_line,
     &me->display,
     &me->display_env,
     my_id,
     my_msg);
  }
/*
 * eof
 */
wrapup:
 my_construct_list->class_attr = (IGRchar *) surface_specific;
 if (1 & *my_msg)
  return(OM_S_SUCCESS);
 else
  {
   *my_constructed_object = NULL_OBJID;
   return(OM_E_ABORT);
  }
}

method perform_dynamics()
{
/*
 * Initialize
 */
 me->msg = MSSUCC;
/*
 * Branch based on the command state
 */
 switch (me->number_of_events_input)
  {
/*
 * Event 1 dynamics
 */
   case 1:
    EFrblineseg(
     &me->events[0].located_object[0].proj_pnt[0],
     &me->display);
    break;
/*
 * Event 2 dynamics
 */
   case 2:
    EFrblineseg(
     &me->events[0].located_object[1].proj_pnt[0],
     &me->display);
    break;
/*
 * Default
 */
   default:
/*  noop; */
    break;
  } /* switch (me->number_of_events_input) */
/*
 * eof
 */
 return(OM_S_SUCCESS);
}

method display_constructions(
 IGRboolean draw_background;
 IGRboolean draw_single)

{
 IGRlong	number_of_points, i, alpha, omega, *my_msg;
 IGRpoint	points[10];
 struct		IGRdisplay *my_display;
 struct		GRmd_env *my_display_env;
/*
 * Compiler optimizations
 */
 my_display = &me->display;
 my_display_env = &me->display_env;
 my_msg = &me->msg;
/*
 * Initialize
 */
 *my_msg = MSSUCC;
/*
 * Set up the loop indices
 */
 omega = me->number_of_events_input;
 if (!omega) goto wrapup;		/* Degenerate case */
 if (draw_single)
  alpha = omega;
 else
  alpha = 1;
/*
 * Enter the loop - Note that it is necessary to
 * reextract the points each time since they are
 * messed up in order to perform the display.
 */
 for (i = alpha; i <= omega; i++)
  {
   number_of_points = 0;
   EFextract_points(
    i,				/* me->number_of_events_input */
    me->events,
    points);
/*
 * Branch based on the command state
 */
   switch (i)
    {
/*
 * Event 1 construction lines
 */
     case 1:
#ifndef IDRAW
      if (me->mytype == 57)
       {
        extern		IGRlong EFdisplay_curve_normal_or_tangent();
        IGRlong		sts;
        struct		GRlc_info *lc_info;

        lc_info = &me->events[0].located_object[0];
        sts = EFdisplay_curve_normal_or_tangent(
          lc_info,		/* The curve */
          NULL,			/* Not used for tangents */
          FALSE,		/* Display the tangent vector */
          FALSE,		/* is_curve_reversed */
          my_id,
          draw_background ? GRbd : GRbe,
          my_display_env,
          my_display,
          my_msg);
       }
#endif
      break;
/*
 * Event 2 construction lines
 */
     case 2:
      if (me->events[1].response == EX_DATA)
       {
        number_of_points = 2;
        OM_BLOCK_MOVE(
         &me->events[0].located_object[0].proj_pnt[0],
         points[0],
         sizeof(IGRpoint));
       }
      break;
/*
 * Event 3 construction lines
 */
     case 3:
      if (me->events[2].response == EX_DATA)
       {
        number_of_points = 2;
        OM_BLOCK_MOVE(
         &me->events[0].located_object[1].proj_pnt[0],
         points[0],
         sizeof(IGRpoint));
        OM_BLOCK_MOVE(
         points[2],
         points[1],
         sizeof(IGRpoint));
       }
      break;
/*
 * Event 4 construction lines
 */
     case 4:
#ifndef IDRAW
      if (me->mytype == 57)
       {
        extern		IGRlong EFdisplay_curve_normal_or_tangent();
        IGRlong		sts;
        struct		GRlc_info *lc_info;

        lc_info = &me->events[3].located_object[0];
        sts = EFdisplay_curve_normal_or_tangent(
          lc_info,		/* The curve */
          NULL,			/* Not used for tangents */
          FALSE,		/* Display the tangent vector */
          FALSE,		/* is_curve_reversed */
          my_id,
          draw_background ? GRbd : GRbe,
          my_display_env,
          my_display,
          my_msg);
       }
#endif
      break;
/*
 * Default
 */
     default:
/*    noop; */
      break;
    } /* switch (i) */
/*
 * Draw it
 */
   if (number_of_points)
    {
     IGRlong	sts;
     extern	IGRlong ECdisplayPointSetByBuffer();

     sts = ECdisplayPointSetByBuffer(
       my_msg,
       *my_display,
       *my_display_env,
       my_id,
       number_of_points,
       points,
       draw_background);
      if (! (1 & sts))
       {
        *my_msg = MSFAIL;
        goto wrapup;
       }
    } /* if (number_of_points) */
  } /* for (i = start; i <= end; i++) */
/*
 * eof
 */
wrapup:
 if (1 & *my_msg)
  return(OM_S_SUCCESS);
 else
  return(OM_E_ABORT);
}

end implementation ECfitcur;
