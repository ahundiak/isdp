/* ###################   APOGEE COMPILED   ################## */
class implementation ECcurbypol;

%safe
#include <math.h>
%endsafe

#include "EMS.h"
#include "ems_m_inc.h"		/* Includes everything */
#include "EC_P.h"		/* Message keys for prompt strings */

from GRsubbc import EMcurve_by_poles;

extern OMuword OPP_GRbcsubbc_class_id;

method next_event_processing(
 IGRchar	*prompt_string;
 IGRlong	*prompt_index;
 IGRlong	*event_mask;
 IGRlong	*type_of_value_needed;
 IGRboolean	*locate_desired;
 struct		RLW_locate_info *loc_info)

{
 IGRlong	key, num_points;
/*
 * Initialize
 */
 me->msg = MSSUCC;
/*
 * Determine if the user can move on yet
 */
 num_points = me->number_of_events_input;
 if (num_points >= me->u_order)
  {
   key = EMS_P_00083;
   *event_mask |= GRm_RJT_MOVEON;
  }
 else
  key = EMS_P_00082;
/*
 * Build the prompt string
 */
 num_points++;
 ex$message(
  msgnumb = key,
  type = "%d",
  var = `num_points`,
  buff = prompt_string);
/*
 * Eof
 */
 return(OM_S_SUCCESS);
}

method verify_event(
 IGRboolean	use_default;
 IGRboolean	*was_valid_event;
 IGRboolean	*done)

{
 struct		GRevent *event;
/*
 * Initialize
 */
 me->msg = MSSUCC;
 *was_valid_event = TRUE;
/*
 * Check the type of event input
 */
 event = &me->events[me->number_of_events_input - 1];
 if (event->response == EX_RJT_MOVEON) 
  *done = TRUE;
/*
 * Eof
 */
 return(OM_S_SUCCESS);
}

method perform_construction()
{
 IGRlong	sts, number_of_points;
 IGRpoint	*points;
 struct		GRvg_construct *my_construct_list;
 struct		IGResbs *surface_specific;
 struct		IGResbc curve_specific;
/*
 * Compiler optimizations
 */
 my_construct_list = &me->construct_list;
/*
 * Initialize
 */
 me->msg = MSSUCC;
 points = NULL;
 number_of_points = me->number_of_events_input - 1;
 surface_specific = (struct IGResbs *) my_construct_list->class_attr;
/*
 * Fix the element specific attributes
 */
 curve_specific.is_polydis = surface_specific->is_polydis;
 curve_specific.is_curvedis = TRUE;
 my_construct_list->class_attr = (IGRchar *) &curve_specific;
/*
 * Get the points
 */
 points = (IGRpoint *) malloc(number_of_points * sizeof(IGRpoint));
  if (!points)
   {
    me->msg = MANOMEMORY;
    goto wrapup;
   }
 EFextract_points(
  number_of_points,
  me->events,
  points);
/*
 * Construct the curve
 */
 sts = om$construct(
   classid = OPP_GRbcsubbc_class_id,
   msg = message GRsubbc.EMcurve_by_poles(
    me->u_order,
    me->u_periodic,
    number_of_points,
    points,
    NULL,
    my_construct_list),
   p_objid = &me->constructed_object,
   osnum = me->construct_env.md_id.osnum);
  if (! (1 & sts)) me->msg = MSFAIL;
/*
 * eof
 */
wrapup:
 my_construct_list->class_attr = (IGRchar *) surface_specific;
 if (points) free(points);
 if (1 & me->msg)
  return(OM_S_SUCCESS);
 else
  {
   me->constructed_object = NULL_OBJID;
   return(OM_E_ABORT);
  }
}

end implementation ECcurbypol;
