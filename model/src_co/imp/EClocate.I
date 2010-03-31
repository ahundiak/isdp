/* ###################   APOGEE COMPILED   ################## */
/*
 Description

 The purpose of this method is to consolidate basic locate functionality
 into one method.  This is intended to reduce code and provide for a
 more uniform user interface.

 History

 12/08/87 : rlw : Pulled this out of ECconstruct execute method and put
                  it in a method by itself.
 12/18/87 : rlw : Added event mask argument to method.  Also made some
                  changes to the way I handled the return info. of locate.
 04/27/88 : rlw : A comment terminator was missing and therefore
                  valuable code was being skipped.
 08/01/88 : rlw : Modified entity read operations to allow for locate of
                  rigid components.  This was required to allow for
                  model space counterparts to work.
                  Also put in modifications to allow for group locates.
 08/02/88 : rlw : Turned on functionality which enables locating elements
                  by their assigned names.  Also added support for regular
                  expressions.  Also changed the put queue logic due
                  to changes in the locate filter.
 09/20/88 : rlw : Added functionality to locate such that previously
                  located objects will not be relocated by the command.
 09/26/88 : rlw : Initialized new field to select handler.
 12/06/88 : AIC : Store the accept window id.
 01/10/89 : rlw : At times me->msg was returning error codes not consistent
                  with the OSA standard.  This was because it allowed
                  lc$locate error codes to be returned, causing problems to
                  callers doing (1 & msg) type tests.
 01/20/89 : rlw : Modified not to put the accept event on the queue if
                  the element was located as a specified object.
 09/20/89 : rlw : Modified such that if a string is entered the filter will
                  not return a string reponse if an object is not located.
 10/02/92 : DLB : Once again allow place plane encompassing planar element
                  to locate sets.
 11/24/92 : AMD : Allow associative locate for 'Place solid by capping'
 11/01/93 : dhm : Allow rigid component locate for 'Insert pole' - type 78.

 */

class implementation ECconstruct;

%safe
#include <math.h>
%endsafe

#include "EMS.h"
#include "ems_m_inc.h"			/* Includes everything */
#include "EC_I.h"			/* Informational messages */
#include "grgsdef.h"			/* Needed for the macros */
#include "grgsmacros.h"			/* gr$gsput_locate_criteria() */
#include "EMSaction.h"			/* Locate action handler */

extern OMuword OPP_GRowner_class_id, OPP_EMSdatpln_class_id;

method locate_object(
 IGRlong	event_mask;
 IGRchar	*locate_string;
 IGRlong	locate_key;
 struct		RLW_locate_info *loc_info;
 IGRboolean	auto_put_on_queue;
 IGRboolean	*put_on_queue;
 IGRint		*response;
 IGRchar	*response_data)

{
 IGRchar	prompt_string[80];
 IGRboolean	things_worked_out;
 IGRint         i;
 IGRlong	sts, accept_mask, display_flag;
 struct		GRevent event2;
 struct		GRlc_locate attributes;
 struct		EMSaction_handler already_located;
/*
 * Initialize
 */
 me->msg = MSSUCC;
 loc_info->rtree_classes.p_classes = &loc_info->r_classes[0];
 loc_info->eligible_classes.p_classes = &loc_info->e_classes[0];
/*
 * Set up the display flag information
 */
 display_flag = 
  ELEM_HILIGHT		| 	/* Hilite the whole element */
  NO_PROJ_ACCEPT_POINT	| 	/* Don't project the accept point */
  ACC_REJ_CYCLE		|	/* Run through accept reject cycle */
  RELOCATE		| 	/* Relocate if none found */
  LC_REGULAR_HIGHLIGHT;		/* Use regular hilite not 1/2 */
/*
 * We must add string to the locate mask if we wish
 * to locate an element by it's name.  We must also
 * be careful since some commands use the locate point
 * to determine directional information.  If this is the
 * case then tell locate that if an element is located by
 * name then also ask the user for a data point.
 */
 event_mask |= GRm_TEXT_VALUE;		/* Element name */
 if (loc_info->identify_event_type == good_data)
  display_flag |= LC_INPUT_LOC_POINT;
/*
 * Accept elements with a data point and with a name
 * if we are performing a chained locate.
 */
 accept_mask = GRm_DATA;
 if (loc_info->accept_event_type == chained)
  {
   display_flag |= LC_ACCEPT_CURSOR;
   accept_mask |= GRm_TEXT_VALUE;	/* Element name */
  }
/*
 * Determine if I already have any elements in the
 * hilite plane.  If so then I must erase pixel by
 * pixel.
 */
 {
  void		EFget_object_count();
  IGRlong	number_of_objects;

  already_located.next = NULL;
  already_located.option = 0;
  already_located.type = 0;
  already_located.num_objects = 0;
  EFget_object_count(
   me->number_of_events_input,
   me->events,
   &number_of_objects);
  if (number_of_objects == 0)
   {
    display_flag |= LC_ERASE_ALL;
   }
/*
 * Build up a list of the objects which
 * we have already located
 */
  else
   {
    IGRlong i, j;

    display_flag |= LC_ERASE_LOC_ELEMENT;
    if (! loc_info->allow_duplicate_objects)
     {
      if (number_of_objects < RLW_STACK_SIZE)
       already_located.num_objects = number_of_objects;
      else
       already_located.num_objects = RLW_STACK_SIZE;
      for (i = 0, j = 0;
           (i < me->number_of_events_input) && (j < RLW_STACK_SIZE);
           i++)
       {
        if (me->events[i].subtype == GRst_LOCATE)
         {
          already_located.objects.lc_info[j++] = 
           &me->events[i].located_object[0];
         }
       } /* for (i = 0; i < me->number_of_events_input; i++) */
     } /* if (! loc_info->allow_duplicate_objects) */
   } /* ELSE FOR if (number_of_objects == 0) */
 }
/*
 * Setup the properties word
 */
 attributes.properties = 
  LC_LC_ONLY		|	/* Locate locatable objects */
  LC_DP_ONLY		|	/* Locate displayable objects */
  IGN_MOD_BIT           |	/* Ignore modified and new props */
  loc_info->planar_flag;        /* Planar flag */
/*
 * Setup the owner action bits
 */
 switch (loc_info->operation_type)
  {
   case entity_read_only:		/* rlw - Added rigid comps */
   case info_read_only:
    attributes.properties |= LC_RW;

    /*******DLB TR#119220210 PPEPE should allow locate of sets****
    if (me->mytype == 35)
    {
        loc_info->are_groups_allowed = FALSE;
        attributes.owner_action = LC_RIGID_OWNER   | LC_RIGID_COMP |
                                  LC_NO_FLEX_OWNER | LC_FLEX_COMP;
    }
    else
    ******************************************************************/

    {
        attributes.owner_action = LC_RIGID_COMP  | LC_FLEX_COMP |
                                  LC_RIGID_OWNER | LC_FLEX_OWNER;
    }
    break;

   case display_modification:
    attributes.properties |= LC_WRITE_ONLY;
    attributes.owner_action = 
     LC_RIGID_COMP  |
     LC_FLEX_COMP   |
     LC_RIGID_OWNER |
     LC_FLEX_OWNER  ;
    break;
   case geometry_modification:
    attributes.properties |= LC_WRITE_ONLY;
    attributes.owner_action = 
     LC_FLEX_COMP   |
     LC_RIGID_OWNER ;
    /* AMD  11/24/92 : Added for 'Place solid by capping' */
    if(me->mytype == 76)
     attributes.owner_action |= LC_ASSOCIATIVE | 
                                LC_EXTERN_CONSTRAINED;
    /* dhm 11/1/93 : Added for 'Insert Pole w/o changing shape' */
    if (me->mytype == 78)
        attributes.owner_action |= LC_RIGID_COMP;
    break;
   default:
    me->msg = MSFAIL;
    return(OM_E_ABORT);
  } /* switch (loc_info->operation_type) */
 attributes.owner_action |= 
  LC_REF_OBJECTS |		/* Objects in ref. files are O.K. */
  LC_NO_REF_HEADER;		/* No reference file headers */
/*
 * Get the prompt string.  Note that this is
 * necessary since the locate macro will not
 * accept a string and a key.
 */
 if (locate_string)
  strcpy(prompt_string, locate_string);
 else
  {
   ex$message(
    msgnumb = locate_key,
    buff = prompt_string)
  }
/*
 * If reference planes are going to be located then set the owner action
 * properties such that we allow handles to get located. 
 * pp 07/06/92
 */

 for (i=0;i<loc_info->eligible_classes.w_count;i++)
 {
   if ((loc_info->e_classes[i]) == OPP_EMSdatpln_class_id)
   {
     attributes.owner_action |= LC_HANDLES;
     break;
   }
 }
/*
 * If groups are eligible then add them to the eligible list.
 * We must also deposit this stuff so that fences will allow
 * for these type of objects to be located.
 */
 if (loc_info->are_groups_allowed)
  {
   extern	IGRlong GRgsmgr_fun();

   event_mask |= GRm_SPECIFIED_OBJ;	/* We will take groups */
   loc_info->e_classes[loc_info->eligible_classes.w_count++] =
    OPP_GRowner_class_id;	/* Groups */
   sts = gr$gsput_locate_criteria(
     msg = &me->msg,
     attributes = &attributes,
     rtree_classes = &loc_info->rtree_classes,
     eligible_classes = &loc_info->eligible_classes);
    if (! (1 & sts)) return(OM_E_ABORT);
  } /* if (loc_info->are_groups_allowed) */
/*
 * Perform the locate.
 * 
 * The way locate uses the events is as follows:
 *
 * me->event -  Will contain the identify event as given by the operator.
 * me->event1 - Will contain the accept event as given by the operator.
 * event2     - Will contain the located object.
 *
 * If the operator snaps for the first event then (me->event == me->event1),
 * i.e. no accept event is asked for.
 */
 do
  {
   extern	IGRlong EFlocate_action_handler();

   things_worked_out = TRUE;
   sts = lc$locate(
     rc =		&me->msg,
     event1 =		&me->event,
     event2 =		&me->event1,
     event3 =		&event2,
     mask1 =		event_mask,
     mask2 =		accept_mask,
     display_flag =	display_flag,
     unhilight_mode =	(enum GRdpmode ) GRhd,	/* Don't unhilite */
     locate_prompt =	prompt_string,
     acc_key = 		loc_info->acc_key,
     relocate_key = 	loc_info->relocate_key,
     attributes = 	&attributes,
     act_handler = 	EFlocate_action_handler,
     act_args =         &already_located,
     stack = 		&me->locate_stack,
     rtree_classes = 	&loc_info->rtree_classes,
     eligible_classes =	&loc_info->eligible_classes,
     regex = 		loc_info->are_groups_allowed);
    if (! (1 & sts)) return(OM_E_ABORT);
/*
 * If an object was located then move that objects information
 * into the first event.  I want to make the first event completely
 * determine the object.
 */
   if (me->msg == LC_OBJ_LOCATED)
    {
     me->event.num_id = event2.num_id;
     me->event.located_object[0] = event2.located_object[0];
     me->window_id.objid = me->event1.event.button.objid;
     me->window_id.osnum = me->event1.event.button.osnum;
    }
/*
 * Determine if the user has interrupted the locate during the 
 * accept/reject cycle.  In this case we have to interpret a little
 * more carefully.
 */
   else if (me->locate_stack.num_entries)
    {
     switch (*response)
      {
       case EX_BACK_UP:	/* Should be taken care of by the filter */
        me->locate_stack.num_entries = 0;
        things_worked_out = FALSE;
        break;
       case EX_RESTART:
        me->locate_stack.num_entries = 0;
        me->event.response = *response;
        break;
       default:
/*      noop; */			/* Just fall through the cracks */
        break;
      } /* switch (*response) */
    } /* else if (me->locate_stack.num_entries) */
/*
 * We have not located an object and we have no
 * elements on the stack.
 */
   else
    {
/*
 * Determine if locate has erroneously returned
 * control to us.
 */
     if (me->event.response == EX_DATA)
      things_worked_out = FALSE;
/*
 * If a string is returned and an object is not located then
 * this should be given back to the command server as I certainly
 * don't need it.
 */
     else if (me->event.response == EX_STRING)
      me->event.response = GR_UNKNOWN_TYPE;
/*
 * Determine if we should return this event to
 * command server or merely discard it.
 */
     else if (me->event.response == GR_UNKNOWN_TYPE)
      {
       switch (*response)
        {
         case EX_DATA:
         case EX_RJT_MOVEON:
         case EX_BACK_UP:
         case EX_OBJID:
         case EX_RESTART:
          ex$message(msgnumb = EMS_I_00005)		/* Input discarded */
          things_worked_out = FALSE;
          break;
         default:
/*        noop; */			/* Just fall through the cracks */
          break;
        }
      }
    } /* We came out of a locate w/o an object or stack entries */
  }
 while (! things_worked_out);
/*
 * If we located an object then inform the caller 
 * whether he should put the accept event (me->event1) 
 * on the stack.
 */
 if (me->msg == LC_OBJ_LOCATED)
  {
   switch (loc_info->accept_event_type)
    {
/*
 * If the accept point has no meaning, except acceptance, then
 * don't put it on the queue
 */
     case dummy:
      *put_on_queue = FALSE;
      break;
/*
 * If the accept point is a point we need then put it on the queue
 * unless we needed the identify point and these two points are the
 * same.
 */
     case good_data:
      if (me->event.response == EX_OBJID)
       *put_on_queue = FALSE;
      else if ((loc_info->identify_event_type == good_data) &&
               (me->event.subtype != GRst_REGULAR) &&
               me->event.num_id)
       *put_on_queue = FALSE;
      else
       *put_on_queue = TRUE;
      break;
/*
 * If we are performing a chained locate then put the accept event 
 * on the queue as long as doing this does not cause the same
 * object to get located twice.
 */
     case chained:
      if (me->event.response == EX_OBJID)
       *put_on_queue = FALSE;
      else if ((me->event.subtype != GRst_REGULAR) &&
               me->event.num_id && 
               (me->event.located_object[0].located_obj.objid ==
                me->event1.located_object[0].located_obj.objid))
       *put_on_queue = FALSE;
      else
       *put_on_queue = TRUE;
      break;
     default:
      me->msg = MSFAIL;
      return(OM_E_ABORT);
    } /* switch (loc_info->accept_event_type) */
/*
 * If the accept event should be put on the
 * queue and the caller wants us to do it
 * for him, then do so.
 */
   if (*put_on_queue &&
       auto_put_on_queue)
    {
     IGRlong	sizeof_event;

     sizeof_event = sizeof(struct GRevent);
     sts = ex$putque(
       msg = &me->msg,
       response = &me->event1.response,
       byte = &sizeof_event,		/* Should be slightly less */
       buffer = (IGRchar *)&me->event1.event);
      if (! (1 & sts)) return(OM_E_ABORT);
    } /* if (*put_on_queue) */
  } /* if (me->msg == LC_OBJ_LOCATED) */
/*
 * If no object was located then we certainly
 * do not want to put the nonexistant acceptance
 * event on the queue.
 */
 else
  *put_on_queue = FALSE;
/*
 * Eof
 */
 me->msg = MSSUCC;		/* rlw - 01/10/88 */
 return(OM_S_SUCCESS);
}

end implementation ECconstruct;
