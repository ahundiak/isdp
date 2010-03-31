/* ###################   APOGEE COMPILED   ################## */
/*
 Description

 This file contains the next event processing, verify event,
 perform construction, perform dynamics, and display construction
 methods for the blend surface command.

 History

 06/29/88 : rlw : Creation date
 11/29/88 : rlw : Broke the functionality out of ECconstruct and reworked
                  to support an arbitrary number of curves.
 12/02/88 : rlw : Fixed logic bug in going to distance prompt
 07/26/89 : rlw : Added verification check to ensure that curves form
                  a valid closed contour.
 08/31/89 : rlw : Modified to allow locating the same surface more than once.
 08/08/91 : scw : Converted to use gr$dpb associative flag
 */

class implementation ECblndnsrf;

#ifndef SUNOS5
%safe
#include <math.h>
%endsafe
#endif

#include "EMS.h"
#include "ems_m_inc.h"		/* Includes everything */
#include "OMmacros.h"		/* OM_BLOCK_MOVE stuff */
#include "EC_P.h"		/* Message keys for prompt strings */
#include "EC_I.h"		/* Message keys for status strings */
#include "EMSasnucdef.h"        
#include "EMSasnuc.h"           /* For EMSdata_info.. */
#include "EMSasopts.h"
#include "EMSdpb.h"             /* For EMSdpb_assoc_placement */
#include "EMSascmacros.h"

#define MAXIMUM_CURVES 200
#define BIG_CURVE 0
#define LITTLE_CURVE 1
#define LITTLE_SURFACE 2

from GRgraphics import GRgetrang;
from EMSgenbs import EMblend_3_or_more_curves;

extern OMuword OPP_EMSgenbs_class_id;

method perform_construction()
{
 OMuword	space_number;
 IGRboolean	done, have_distance;
 IGRlong	loc_msg, i, *my_msg, sts, number_of_curves;
 GRobjid	*my_constructed_object, tmp_objid;
 IGRdouble	distance;
 IGRpoint	center_point;
 IGRvector	normal_vector;
 struct 	EMSvalue_info dist_par;
 struct		GRvg_construct *my_construct_list;
 struct		GRlc_info *curves[MAXIMUM_CURVES], *surfaces[MAXIMUM_CURVES];
/*
 * Compiler code reductions
 */
 my_msg = &me->msg;
 my_construct_list = &me->construct_list;
 my_constructed_object = &me->constructed_object;
 space_number = me->construct_env.md_id.osnum;
/*
 * Initialize
 */
 *my_msg = MSSUCC;
 *my_constructed_object = NULL_OBJID;
/*
 * Create separate arrays of curve and surface objects
 */
 i = 0;
 done = FALSE;
 number_of_curves = 0;
 do
  {
   if (me->events[i].response != EX_RJT_MOVEON)
    {
     curves[number_of_curves] = &me->events[i].located_object[0];
     i++;
     if (me->events[i].response == EX_RJT_MOVEON)
      surfaces[number_of_curves] = NULL;
     else
      surfaces[number_of_curves] = &me->events[i].located_object[0];
     i++;
     number_of_curves++;
     if (number_of_curves > MAXIMUM_CURVES)
      {
       *my_msg = MSFAIL;
       goto wrapup;
      }
    }
   else
    {
     i++;
     if (i == me->number_of_events_input)
      {
       have_distance = FALSE;
       distance = 0.0;
       dist_par.type = EMSdatainfo_numeric;
       dist_par.val = 0.0;
        
      }
     else
      {
       have_distance = TRUE;
       distance = me->events[i].event.value;
       dist_par.type = EMSdatainfo_event;
       dist_par.valevent = &me->events[i];
      }
     done = TRUE;
    }
  }
 while (!done);
/*
 * Construct the surface
 */
/****************************************************************************
 sts = EFblend_3_or_more_curves(&loc_msg,(me->associative ? 
       NULL : EMSasconst_notassociative), number_of_curves,
       curves, surfaces, &dist_par, center_point, normal_vector,
       my_construct_list, my_constructed_object);
****************************************************************************/
 sts = ems$blnd_3_or_more_crvs(msg = &loc_msg,
               options = (me->associative ? NULL : EMSasconst_notassociative),
               number_of_curves = number_of_curves,
               curve_info = curves,
               surf_info = surfaces,
               dist_par = &dist_par,
               center_point = center_point,
               normal_vector = normal_vector,
               construction_list = my_construct_list,
               constructed_object = my_constructed_object);
 if (! (1 & sts & loc_msg)) 
  *my_msg = MSFAIL;
/*
 * If more than 4 curves were input then we need to
 * display the normal vector at the center point on
 * the screen.  In addition, if a distance was not
 * input then we need to add a dummy value event on
 * the queue such that the user can back into this
 * hidden state.
 */
 else if (number_of_curves > 4)
  {
   extern	void EFdraw_vector_on_screen();
   enum		GRdpmode display_mode;
   IGRboolean	in_world;
   GRrange	range_box;
   struct	GRmdenv_info *mdenv_info;

   in_world = TRUE;
   mdenv_info = &me->construct_env.md_env;
   sts = om$send(
     msg = message GRgraphics.GRgetrang(
       my_msg,
       &mdenv_info->matrix_type,
       mdenv_info->matrix,
       &in_world,
       range_box),
     targetid = *my_constructed_object,
     targetos = space_number);
    if (! (1 & sts)) goto wrapup;
   display_mode = GRhhd;
   EFdraw_vector_on_screen(
    my_id,
    &me->display,
    &me->display_env,
    display_mode,
    FALSE,		/* Don't reverse vector */
    center_point,
    normal_vector,
    range_box,
    my_msg);
   if (have_distance)		/* Distance was input */
    me->events[me->number_of_events_input - 2].event.value = distance;
   else
    {
     me->event.subtype = GRst_DEFAULT;
     me->event.response = EX_VALUE;
     me->event.event.value = 0.0;
     sts = om$send(
       msg = message ECconstruct.add_event(FALSE),
       targetid = my_id);
    } /* if (have_distance) */
  } /* else if (number_of_curves > 4) */
/*
 * eof
 */
wrapup:
 if (1 & *my_msg)
  return(OM_S_SUCCESS);
 else
  {
   *my_constructed_object = NULL_OBJID;
   return(OM_E_ABORT);
  }
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
 IGRlong	sts, integer_to_encode, key, *my_msg;
/*
 * Compiler optimizations
 */
 my_msg = &me->msg;
/*
 * Initialize
 */
 *my_msg = MSSUCC;
 integer_to_encode = 0;
/*
 * Determine whether we should be asking for
 * a surface or a distance.  If the last input
 * was a move on then we need a distance.
 */
 if (me->number_of_events_input % 2)
  {
   if (me->events[me->number_of_events_input - 1].response == EX_RJT_MOVEON)
    {
     *event_mask &= ~GRm_DATA;
     *type_of_value_needed = DISTANCE;
     key = EMS_P_00155;
    }
   else
    {
     *locate_desired = TRUE;
     EFget_locate_information(LITTLE_SURFACE, loc_info);
     key = EMS_P_00139;
     loc_info->allow_duplicate_objects = TRUE;
     loc_info->accept_event_type = dummy;
     *event_mask |= GRm_RJT_MOVEON;
     integer_to_encode = (me->number_of_events_input / 2) + 1;
    }
  }
/*
 * If we need a curve then ask for one.
 */
 else
  {
   IGRlong	number_of_curves;

   *locate_desired = TRUE;
   EFget_locate_information(BIG_CURVE, loc_info);
   loc_info->accept_event_type = dummy;
   number_of_curves = (me->number_of_events_input / 2);
   integer_to_encode = number_of_curves + 1;
   if (number_of_curves > 2)
    {
     key = EMS_P_00037;
     *event_mask |= GRm_RJT_MOVEON;
    }
   else
    key = EMS_P_00035;
  }
/*
 * Get the prompt string
 */
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
 IGRlong	sts, *my_msg;
 struct		GRevent *event;
/*
 * Compiler optimizations
 */
 my_msg = &me->msg;
/*
 * Initialize
 */
 *my_msg = MSSUCC;
 *done = FALSE;
 *was_valid_event = TRUE;
 event = &me->events[me->number_of_events_input - 1];
/*
 * If we were asking for a curve and a move on was input then
 * we are done.  We are also done if we are asking for the distance.
 */
 if (me->number_of_events_input % 2)
  {
   if (event->response == EX_RJT_MOVEON)
    {
     extern		IGRlong EMreport_curve_gaps();
     IGRboolean		gaps_exist;
     IGRlong		i, j, number_of_curves;
     struct		EX_button buttons[MAXIMUM_CURVES];
     struct		GRlc_info lc_info[MAXIMUM_CURVES];

     number_of_curves = me->number_of_events_input / 2;
     for (i = 0; i < number_of_curves; i++)
      {
       j = 2 * i;
       lc_info[i] = me->events[j].located_object[0];
       buttons[i] = me->events[j].event.button;
       if (me->events[j].response != EX_DATA)
        buttons[i].objid = NULL_OBJID;
      } /* for (i = 0; i < number_of_curves; i++) */
     sts = EMreport_curve_gaps(
       number_of_curves,
       lc_info,
       buttons,
       (number_of_curves > 3) ? TRUE : FALSE,
       &me->display,
       &me->display_env,
       &gaps_exist,
       my_msg);
      if (! (1 & sts)) goto wrapup;
     if (gaps_exist)
      {
       *was_valid_event = FALSE;
       ex$message(msgnumb = EMS_I_00074);
      }
     else
      {
       *done = TRUE;
       event->event.value = 0.0;
      }
    } /* if (event->response == EX_RJT_MOVEON) */
  } /* if (me->number_of_events_input % 2) */
 else if (event->response == EX_VALUE)	/* Asked for distance? */
  {
   IGRdouble previous_distance;

   previous_distance = me->events[me->number_of_events_input - 2].event.value;
   if (use_default) event->event.value = 0.0;
   event->event.value += previous_distance;
   *done = TRUE;
  }
/*
 * eof
 */
wrapup:
 return(OM_S_SUCCESS);
}

method display_constructions(
 IGRboolean draw_background;
 IGRboolean draw_single)
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

method is_associative(IGRint type; IGRlong *associative)
{
 IGRlong    EMmsg;
 IGRboolean state;

 EMmsg = 1;

 *associative = FALSE;
 gr$get_associative_flag( buffer = &state );

 if (state)
    *associative = TRUE;

 return(OM_S_SUCCESS); 
}

end implementation ECblndnsrf;
