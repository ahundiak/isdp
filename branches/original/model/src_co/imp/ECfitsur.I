/* ###################   APOGEE COMPILED   ################## */
/*
 Description

 This file contains the next event processing, verify event,
 perform construction, perform dynamics, and display construction
 methods for the following commands:

                 Command                      my_type
        ----------------------------------    -------
	Place surface by poles			58
	Place direct fit surface		59
	Place least squares fit surface		60
	Place direct fit surface - curves	61
	Place surface through network		62
						--
	Place fitted surface			117

 History

 12/23/87 : rlw : The beginning
 08/02/88 : rlw : Forget to set the flag indicating that a locate point
                  is required to be input.
 09/05/88 : rlw : Moved error reporting on fits to a function
                  Added Place fitted surface command.
 03/24/91 : pp  : Modified for handling associativity.
 08/08/91 : scw : Converted to use gr$dpb associative flag
 Sudha   06/02/93        modified to include for BSprototype headers
 */

class implementation ECfitsur;

%safe
#include <math.h>
%endsafe

#include "EMS.h"
#include "ems_m_inc.h"		/* Includes everything */
#include "OMmacros.h"		/* OM_BLOCK_MOVE stuff */
#include "EC_P.h"		/* Message keys for prompt strings */
#include "EC_I.h"		/* Message keys for status strings */
#include "EMSdpb.h"
#include "emsdef.h"
#include "bsparameters.h"

#define BIG_CURVE 0
#define LITTLE_CURVE 1
#define LITTLE_SURFACE 2

from EMSgenbs import EMsurface_by_poles;
from EMSgenbs import EMdirect_fit_surface;
from EMSgenbs import EMleast_squares_fit_surface;
from EMSgenbs import EMdirect_fit_surface_by_curves;
from EMSgenbs import EMnetwork_of_curves;

/* For EMS 2.0 */

from EMSassoc import EMinit_associative;
from NDnode import NDmove_to_root;

/* end if */

extern OMuword OPP_EMSgenbs_class_id;

method display_constructions(
 IGRboolean draw_background;
 IGRboolean draw_single)

{
 IGRlong	i, alpha, omega, *my_msg;
 struct		IGRdisplay *my_display;
 struct		GRmd_env *my_display_env;
 struct		GRevent *event;
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
 * Enter the loop
 */
 for (i = alpha; i <= omega; i++)
  {
/*
 * Branch based on our state
 */
   event = &me->events[i - 1];
   if (event->subtype == GRst_LOCATE)
    {
     IGRboolean	is_curve_reversed;
     IGRlong	sts, EFdisplay_curve_normal_or_tangent();
     struct	GRlc_info *lc_info;

     lc_info = &event->located_object[0];
     is_curve_reversed = lc_info->geom_parms.polygon_inx;
     sts = EFdisplay_curve_normal_or_tangent(
       lc_info,		/* The curve */
       NULL,		/* Not used for tangents */
       FALSE,		/* Display the tangent vector */
       is_curve_reversed,
       my_id,
       draw_background ? GRbd : GRbe,
       my_display_env,
       my_display,
       my_msg);
      if (! ( 1 & sts)) goto wrapup;
    }
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

method perform_construction()
{
 OMuword	space_number;
 IGRboolean	u_periodic, v_periodic;
 IGRuchar       *rev_info = NULL, type = 0, *recomp_info = NULL;
 IGRlong        check_associative = FALSE;
 IGRlong	i, j, *my_msg, base, sts,recomp_size, fitted_surf_info_size;
 IGRlong	number_of_curves_1, number_of_curves_2;
 IGRlong	u_order, v_order, max_indicator[2];
 IGRdouble	average_error, maximum_error;
 IGRpoint	error_line[2];
 struct         EMSfitted_surface *fitted_surf_info = NULL;
 struct         EMSobject_info *list = NULL;
 struct		GRlc_info *direction_1, *direction_2, *lc_info_ptr;
 struct         EMSnetwork_of_curves *network_info = NULL;
 GRobjid	*my_constructed_object;
 struct		GRvg_construct *my_construct_list;
 extern OMuword OPP_EMAgenbs_class_id;
/*
 * Compiler code reductions
 */
 my_msg = &me->msg;
 my_construct_list = &me->construct_list;
 my_constructed_object = &me->constructed_object;
 space_number = me->construct_env.md_id.osnum;
 u_order = me->u_order;
 v_order = me->v_order;
 u_periodic = me->u_periodic;
 v_periodic = me->v_periodic;
/*
 * Initialize
 */
 *my_msg = MSSUCC;
 *my_constructed_object = NULL_OBJID;
 direction_1 = NULL;
 direction_2 = NULL;
/*
 * Determine how may objects we have
 */
 for (i = 0; i < me->number_of_events_input; i++)
  {
   if (me->events[i].response == EX_RJT_MOVEON)
    {
     number_of_curves_1 = i;
     direction_1 = (struct GRlc_info *) malloc(number_of_curves_1 *
       sizeof(struct GRlc_info));
      if (! direction_1)
       {
        *my_msg = MANOMEMORY;
        goto wrapup;
       }
     for (j = 0; j < i; j++)
      direction_1[j] = me->events[j].located_object[0];
     break;
    }
  } /* for (i = 0; i < me->number_of_events_input; i++) */
 base = number_of_curves_1 + 1;
/*
 * Determine how may objects we have in the other direction
 */
 if (me->mytype == 62)
  {
   for (i = base; i < me->number_of_events_input; i++)
    {
     if (me->events[i].response == EX_RJT_MOVEON)
      {
       number_of_curves_2 = i - base;
       direction_2 = (struct GRlc_info *) malloc(number_of_curves_2 *
         sizeof(struct GRlc_info));
        if (! direction_2)
         {
          *my_msg = MANOMEMORY;
          goto wrapup;
         }
       for (j = base; j < i; j++)
        direction_2[j - base] = me->events[j].located_object[0];
       break;
      }
    } /* for (i = base; i < me->number_of_events_input; i++) */
  } /* if (me->mytype == 62) */
/*
 * Branch based on type
 */
 switch (me->mytype)
  {
   case 58:		/* By poles */
   case 59:             /* Direct fit surface */
   case 61:             /* Direct fit surface by curves */
   {
    IGRint j;

    check_associative = TRUE;
    list = (struct EMSobject_info *) stackalloc(sizeof (struct EMSobject_info) *
             number_of_curves_1);
    rev_info = (unsigned char *) stackalloc(sizeof (char) * number_of_curves_1);
    if (!list || !rev_info ) 
    {
     *my_msg = MANOMEMORY;
     goto wrapup;
    }
  
    for (j = 0; j < number_of_curves_1; j++)
    {
     lc_info_ptr = &me->events[j].located_object[0];
     list[j].grid = lc_info_ptr->located_obj;
     list[j].env  = lc_info_ptr->module_info;
     rev_info[j] = lc_info_ptr->geom_parms.polygon_inx;
    }

    switch (me->mytype)
    {
     case 58:
      type = EMS_ASsurface_by_poles;
     break;

     case 59:
      type = EMS_ASdirect_fit_surface;
     break;

     case 61:
      type = EMS_ASdirect_fit_surface_by_curves;
     break;
    }

    recomp_size = number_of_curves_1*sizeof(char);
    recomp_info = rev_info;

    sts = om$construct(classid = OPP_EMAgenbs_class_id,
                       msg = message EMSassoc.EMinit_associative(my_msg,NULL,
                              number_of_curves_1, list, type,
                              recomp_size,
                              (IGRchar *)recomp_info,my_construct_list),
                        p_objid = my_constructed_object,
                        osnum = space_number);
   }
   break;
                    
   case 60:		/* By lsq fit point */
    sts = om$construct(
      classid =  OPP_EMSgenbs_class_id,
      msg = message EMSgenbs.EMleast_squares_fit_surface(
       u_order,
       v_order,
       u_periodic,
       v_periodic,
       number_of_curves_1,
       direction_1,
       (me->mytype == 117) ? 0 : me->events[base].event.value,
       (me->mytype == 117) ? 0 : me->events[base + 1].event.value,
       &average_error,
       &maximum_error,
       max_indicator,
       error_line,
       my_construct_list),
      p_objid = my_constructed_object,
      osnum = space_number);
    break;

   case 117:
   {
    IGRint rc;

    check_associative = TRUE;
    list = (struct EMSobject_info *) stackalloc(sizeof (struct EMSobject_info) *
             number_of_curves_1);

    fitted_surf_info_size = sizeof (struct EMSfitted_surface) + 
                       (sizeof (char)) * number_of_curves_1;

    fitted_surf_info = (struct EMSfitted_surface *)
                       stackalloc (fitted_surf_info_size);

    if (!list || !fitted_surf_info ) 
    {
     *my_msg = MANOMEMORY;
     goto wrapup;
    }
    BSEXTRACTPAR(&rc, BSTOLCHRDHT, fitted_surf_info->cht);
 
    rev_info = (unsigned char *) fitted_surf_info->rev_info;
  
    for (j = 0; j < number_of_curves_1; j++)
    {
     lc_info_ptr = &me->events[j].located_object[0];
     list[j].grid = lc_info_ptr->located_obj;
     list[j].env  = lc_info_ptr->module_info;
     rev_info[j] = lc_info_ptr->geom_parms.polygon_inx;
    }

    type = EMS_ASfitted_surface;
    sts = om$construct(classid = OPP_EMAgenbs_class_id,
                       msg = message EMSassoc.EMinit_associative(my_msg,NULL,
                              number_of_curves_1, list, type,
                              fitted_surf_info_size,
                              (IGRchar *)fitted_surf_info,my_construct_list),
                        p_objid = my_constructed_object,
                        osnum = space_number);
    }

   break;

   case 62:		/* By network of curves */
   {
    int total_curves, network_info_size;
    check_associative = TRUE;

    total_curves = number_of_curves_1 + number_of_curves_2;
    list = (struct EMSobject_info *) stackalloc(sizeof (struct EMSobject_info) *
             total_curves);
    network_info_size = sizeof (struct EMSnetwork_of_curves) + total_curves *  
                        sizeof (char);
    network_info = (struct EMSnetwork_of_curves *) 
                         stackalloc(network_info_size);
    if (!list || !network_info ) 
    {
     *my_msg = MANOMEMORY;
     goto wrapup;
    }
    network_info->numu = number_of_curves_1;
    network_info->numv = number_of_curves_2;

    rev_info = (unsigned char *) (network_info->rev_info);
  
    for (j = 0; j < number_of_curves_1; j++)
    {
     lc_info_ptr = &me->events[j].located_object[0];
     list[j].grid = lc_info_ptr->located_obj;
     list[j].env  = lc_info_ptr->module_info;
     rev_info[j] = lc_info_ptr->geom_parms.polygon_inx;
    }

    for (i=0,j = number_of_curves_1; j < total_curves; j++,i++)
    {
     list[j].grid = direction_2[i].located_obj;
     list[j].env  = direction_2[i].module_info;
     rev_info[j] = direction_2[i].geom_parms.polygon_inx;
    }

    sts = om$construct(classid = OPP_EMAgenbs_class_id,
                       msg = message EMSassoc.EMinit_associative(my_msg,NULL,
                              total_curves, list, EMS_ASnetwork_of_curves,
                              network_info_size,
                              (IGRchar *)network_info,my_construct_list),
                        p_objid = my_constructed_object,
                        osnum = space_number);

    break;
   }
   default:
    *my_msg = MSFAIL;
    goto wrapup;
  } /* switch (me->mytype) */
 if (! (1 & sts)) 
  *my_msg = MSFAIL;
/*
 * Special processing for least squares
 */
/*
 else if ((me->mytype == 60) ||
          (max_indicator[0] != -1))
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
*/

  if (1&*my_msg&check_associative)
  {
   IGRlong loc_msg;
   struct GRid src_GRid;
   src_GRid.objid = NULL_OBJID;

   if (!me->associative)
   {
     sts = om$send (msg = message NDnode.NDmove_to_root(&loc_msg,
                               &src_GRid, my_construct_list->env_info),
                    targetid = *my_constructed_object,
                    targetos = space_number);
     if (!(1&sts)) 
      *my_msg= MSFAIL;
     else
       *my_constructed_object = src_GRid.objid;
   }
  }
/*
 * eof
 */
wrapup:
 if (list) stackfree (list);
 if (direction_1) free(direction_1);
 if (direction_2) free(direction_2);
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
 * eof
 */
 return(OM_S_SUCCESS);
}

method next_event_processing(
 IGRchar	*prompt_string;
 IGRlong	*prompt_index;
 IGRlong	*event_mask;
 IGRlong	*type_of_value_needed;
 IGRboolean	*locate_desired;
 struct		RLW_locate_info *loc_info)

{
 void		EFget_locate_information();
 IGRboolean	encode_message;
 IGRlong	sts, integer_to_encode, key, *my_msg, my_type;
 IGRlong	state, break_point, index, i;
/*
 * Compiler optimizations
 */
 my_msg = &me->msg;
 my_type = me->mytype;
/*
 * Initialize
 */
 *my_msg = MSSUCC;
 integer_to_encode = 0;
 encode_message = TRUE;
/*
 * Determine if we are in the first or second
 * phase of the command
 */
 state = 0;
 break_point = 0;
 for (i = 0; i < me->number_of_events_input; i++)
  {
   if (me->events[i].response == EX_RJT_MOVEON)
    {
     state = 1;
     break_point = i + 1;
     break;
    }
  } /* for (i = 0; i < me->number_of_events_input; i++) */
 index = me->number_of_events_input - break_point;
/*
 * Branch based on our state
 */
 if (state == 0)
  {
   IGRlong	number_of_linestrings;

   *locate_desired = TRUE;
   EFget_locate_information(BIG_CURVE, loc_info);
   loc_info->identify_event_type = good_data;      /* We need this point */
   loc_info->accept_event_type = chained;
   number_of_linestrings = me->number_of_events_input;
   integer_to_encode = number_of_linestrings + 1;
   switch (my_type)
    {
     case 58:
     case 59:
     case 60:
     case 117:
      loc_info->acc_key = EMS_P_00092;
      loc_info->relocate_key = EMS_I_00021;
      if (me->v_periodic) number_of_linestrings++;	/* Just pretend */
      if ((number_of_linestrings < me->v_order) ||
          (me->v_periodic && (number_of_linestrings < 4)))
       key = EMS_P_00088;
      else
       {
        key = EMS_P_00089;		/* Has the move on part */
        *event_mask |= GRm_RJT_MOVEON;
       }
      break;
     case 61:
      loc_info->acc_key = EMS_P_00045;
      if (me->v_periodic) number_of_linestrings++;	/* Just pretend */
      if ((number_of_linestrings < me->v_order) ||
          (me->v_periodic && (number_of_linestrings < 4)))
       key = EMS_P_00035;
      else
       {
        key = EMS_P_00037;		/* Has the move on part */
        *event_mask |= GRm_RJT_MOVEON;
       }
      break;
     case 62:
      loc_info->acc_key = EMS_P_00045;
      if (number_of_linestrings < 2)
       key = EMS_P_00035;
      else
       {
        key = EMS_P_00037;		/* Has the move on part */
        *event_mask |= GRm_RJT_MOVEON;
       }
      break;
     default:
      *my_msg = MSFAIL;
      goto wrapup;
    } /* switch (my_type) */
  } /* if (state == 0) */
 else
  {
   switch (my_type)
    {
     case 60:
      {
       IGRboolean	periodic;
       IGRlong		minimum_index, maximum_index;

       if (index == 0)
        {
         IGRlong	i, minimum_points = 0;
         struct		IGRbsp_curve *curve;
 
         key = EMS_P_00090;
         periodic = me->u_periodic;
         for (i = 0; i < (me->number_of_events_input - 1); i++)
          {
           sts = EFgetabstract(
             &me->events[i],
             my_id,
             &curve,
             my_msg);
            if (! (1 & sts)) goto wrapup;
           if ((curve->num_poles < minimum_points) || (i == 0))
            minimum_points = curve->num_poles;
          } /* for (i = 0; i < (me->number_of_events_input - 1); i++) */
         maximum_index = minimum_points - 1;
        } /* if (index == 0) */
       else
        {
         key = EMS_P_00091;
         maximum_index = break_point - 2;
         periodic = me->v_periodic;
         if (periodic) maximum_index++;		/* Pretend as if 1 more */
        } /* ELSE FOR if (index == 0) */
       *event_mask &= ~GRm_DATA;
       *type_of_value_needed = SCALAR;
       if (periodic)
        minimum_index = 3;
       else
        minimum_index = 1;        
       ex$message(
        msgnumb = key,
        type = "%d%d%d",
        var = `minimum_index, maximum_index, minimum_index`,
        buff = prompt_string);
       encode_message = FALSE;
      }
      break;
/*
 * Get the prompt
 */
     case 62:
      {
       IGRlong	number_of_linestrings;

       *locate_desired = TRUE;
       EFget_locate_information(BIG_CURVE, loc_info);
       loc_info->identify_event_type = good_data;      /* We need this point */
       loc_info->accept_event_type = chained;
       loc_info->acc_key = EMS_P_00045;
       number_of_linestrings = index;
       integer_to_encode = number_of_linestrings + 1;
       if (number_of_linestrings < 2)
        key = EMS_P_00035;
       else
        {
         key = EMS_P_00037;		/* Has the move on part */
         *event_mask |= GRm_RJT_MOVEON;
        }
      }
      break;
     default:
      *my_msg = MSFAIL;
      goto wrapup;
    } /* switch (my_type) */
  } /* ELSE FOR if (state == 0) */
/*
 * Get the prompt string
 */
 if (encode_message)
  {
   if (integer_to_encode)
    {
     ex$message(
      msgnumb = key,
      type = "%d",
      var = `integer_to_encode`,
      buff = prompt_string);
    }
   else
    {
     ex$message(
      msgnumb = key,
      buff = prompt_string);
    }
  } /* if (encode_message) */
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
 IGRboolean	verify_element;
 IGRlong	key, sts, *my_msg, my_type;
 IGRlong	state, break_point, index, i;
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
 *was_valid_event = TRUE;
 key = EMS_I_00022;		/* Insufficent number of points */
 event = &me->events[me->number_of_events_input - 1];
/*
 * Determine if we are in the first or second
 * phase of the command
 */
 state = 0;
 break_point = 0;
 for (i = 0; i < me->number_of_events_input; i++)
  {
   if (me->events[i].response == EX_RJT_MOVEON)
    {
     IGRlong	base;

     base = i + 1;
     if (base != me->number_of_events_input)
      {
       state = 1;
       break_point = base;
      }
     break;
    }
  } /* for (i = 0; i < me->number_of_events_input; i++) */
 index = me->number_of_events_input - break_point;
/*
 * Branch based on our state
 */
 if (state == 0)
  {
   if (event->response == EX_RJT_MOVEON)
    {
     switch (my_type)
      {
       case 58:
       case 59:
       case 61:
       case 117:
        *done = TRUE;
        break;
       case 60:
       case 62:
/*      noop; */
        break;
       default:
        *my_msg = MSFAIL;
        goto wrapup;
      } /* switch (my_type) */
    } /* if (event->response == EX_RJT_MOVEON) */
   else
    {
     IGRlong	num_points;
     struct	IGRbsp_curve *curve;

     sts = EFgetabstract(
       event,
       my_id,
       &curve,
       my_msg);
      if (! (1 & sts)) goto wrapup;
     num_points = curve->num_poles;
     switch (my_type)
      {
       case 58:
        {
         IGRlong	*previous_num_points;

         previous_num_points = (IGRlong *)
                               &me->events[0].located_object[0].geom_parms.u;
         if (me->number_of_events_input == 1)
          {
           if ((num_points < me->u_order) ||
               (me->u_periodic && (num_points < 4)))
            *was_valid_event = FALSE;
           else
            *previous_num_points = num_points;
          }
         else if (num_points != *previous_num_points)
          {
           *was_valid_event = FALSE;
           if (*previous_num_points > num_points)
            key = EMS_I_00024;		/* Too many points */
          }
        }
        break;
       case 59:
       case 60:
       case 117:
        if ((num_points < me->u_order) ||
            (me->u_periodic && (num_points < 4)))
         *was_valid_event = FALSE;
        break;
       case 61:
       case 62:
/*      noop; */
        break;
       default:
        *my_msg = MSFAIL;
        goto wrapup;
      } /* switch (my_type) */
/*
 * Verify the element's direction
 */
     if (*was_valid_event)
      {
       sts = EFdetermine_direction(
         event,
         my_id,
         my_msg);
        if (! (1 & sts)) goto wrapup;
      } /* if (*was_valid_event) */
    } /* ELSE FOR if (event->response == EX_RJT_MOVEON) */
  } /* if (state == 0) */
/*
 * Are we into the second state of the command?
 */
 else
  {
   switch (my_type)
    {
     case 60:
      {
       IGRboolean	periodic;
       IGRlong		minimum_index, maximum_index;

       if (index == 1)
        {
         IGRlong	i, minimum_points = 0;
         struct		IGRbsp_curve *curve;
 
         periodic = me->u_periodic;
         for (i = 0; i < (me->number_of_events_input - 2); i++)
          {
           sts = EFgetabstract(
             &me->events[i],
             my_id,
             &curve,
             my_msg);
            if (! (1 & sts)) goto wrapup;
           if ((curve->num_poles < minimum_points) || (i == 0))
            minimum_points = curve->num_poles;
          } /* for (i = 0; i < (me->number_of_events_input - 2); i++) */
         maximum_index = minimum_points - 1;
        } /* if (index == 1) */
       else
        {
         maximum_index = break_point - 2;
         periodic = me->v_periodic;
         if (periodic) maximum_index++;		/* Pretend as if 1 more */
        } /* ELSE FOR if (index == 1) */
       if (periodic)
        minimum_index = 3;
       else
        minimum_index = 1;        
       if (use_default)
        event->event.value = minimum_index;
       else if ((event->event.value < minimum_index) ||
                (event->event.value > maximum_index))
        {
         *was_valid_event = FALSE;
         key = EMS_I_00009;		/* Invalid value */
        }
       if ((index == 2) &&
           *was_valid_event)
        *done = TRUE;
      }
      break;
     case 62:
      if (event->response == EX_RJT_MOVEON) 
       *done = TRUE;
      else
       {
        sts = EFdetermine_direction(
          event,
          my_id,
          my_msg);
         if (! (1 & sts)) goto wrapup;
       }
      break;
     default:
      *my_msg = MSFAIL;
      goto wrapup;
    } /* switch (my_type) */
  } /* ELSE if (state == 0) */
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

method is_associative(IGRint type; IGRlong *associative)
{
 IGRlong    EMmsg;
 IGRboolean state;

 EMmsg = 1;

 *associative = FALSE;
 gr$get_associative_flag( buffer = &state );

 if (state)
 {
  switch (type)
  {
   case 58:
   case 59:
   case 61:
   case 62:
   case 117:
    *associative = TRUE;
    break;
  }
 }

 return(OM_S_SUCCESS); 
}
end implementation ECfitsur;
