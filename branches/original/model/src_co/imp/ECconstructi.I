/* ###################   APOGEE COMPILED   ################## */
class implementation ECconstruct;
/*
 Description

  This file contains standard the wakeup, 
  load construct list, add event, backup,
  and transition from last state to first state
  event messages for EMS construction classes.

 History

  10/14/87 : rlw : The beginning
  12/23/87 : rlw : Modified load construct stuff method to load surface element
                   specific stuff.
  01/11/88 : rlw : Modified backup method to inform the last point form of
                   my actions.
  01/17/88 : rlw : My backup logic w.r.t. dummy events was not quite right.
                   I have attempted to repair this logic.
  01/20/88 : rlw : I was returning an uninitialized status from the last
                   state to first state method.
  09/12/88 : rlw : Modified to support suspend and non-suspend stuff
                   for the 1.2.0 release.
  02/20/89 : rlw : Pull active properties from ige dpb.
  03/09/89 : rlw : Tossed the above fix because Dieter had a file in
                   which our elements were not be displayed or located.
  04/18/89 : rlw : Added overrides for init and status_disp.  Also modified
                   sleep, wakeup, and delete methods to support status
                   display forms.
  08/16/89 : pp  : Modified the init and last_state_to_first_state methods
                   to permit jumping to state 3 for project curve along vector
                   onto surface command.
  10/24/89 : rlw : Modified status_disp method to set variable indicating that
                   the statud display form has been displayed.
  01/21/91 : pp  : Modified the display of status form to take defaults
                   enabling the position of the form to be set by the model
                   builder
  04/27/91 : pp  : Added support in wakeup to display the associative
                   button if the command is behaving associatively.
  08/08/91 : scw : Converted to use gr$dpb associative flag
  08/14/94 : scw : Clarified sleep method
 */

%safe
#include <math.h>
%endsafe

#include "EMS.h"			/* Shared library stuff */
#include "ems_m_inc.h"			/* Includes everything */
#include "EC_I.h"			/* Informational messages */
#include "OMmacros.h"			/* VLA macros */
#include "EMSdpb.h"			/* To get construction parameters */

#include "actparam.h"


#define TYPE_NONE 0
#define TYPE_REGULAR 1
#define TYPE_DUMMY 2

from GRgraphics import GRdelete;
from GRgraphics import GRdisplay;


/**********************
from FIform import erase_form, display_form, init_form;
**********************/

method init(int type; char *str_ptr)
{
 IGRlong	sts;
/*
 * Let my parent do it's stuff
 */
 sts = om$send(
  mode = OM_e_wrt_message,
  msg = message super_cmd.init(
   type,
   str_ptr),
  targetid = my_id);

/*
 * Initialize status display form variables
 */
 me->form_requested = FALSE;
 me->form_id =  NULL_OBJID;
 me->active_form_name[0] = '\0';

 switch (ME.super_cmd->mytype)
 {
/*
 * The following rigmarole is done so that we can allow user to
 * backup and do something else at the first state that he sees.
 */

  case 42:
  {
   IGRshort i;

   me->number_of_events_input = 3;
   for (i=0;i<3;i++)
    me->events[i].response = EX_MAX_RESPONSE;
  }
  break;

  default:
  break;
 }

/*
 * eof
 */
 return(OM_S_SUCCESS);
}

method restart()
{
 IGRint	pos, sts;

/*
 * Initialize
 */
 me->msg = MSSUCC;
/*
 * Erase any hilited objects and constructional geometry
 */
 pos = EX_suspend;
 sts = om$send(
  msg = message ECconstruct.sleep(pos),
  targetid = my_id);
/*
 * Reset my state
 */
 me->state = 0;
 me->number_of_events_input = 0;

/*
 * eof
 */
 return(sts);
}

method super_cmd.sleep(int pos)
{
 void 		EFget_object_count();
 IGRlong	sts, number_of_objects;

/*
 * Initialize
 */
 sts = OM_S_SUCCESS;
 me->msg = MSSUCC;


/*
 * Erase the hilite plane
 */
 if (pos == EX_suspend)
  {
   EFget_object_count(
    me->number_of_events_input,
    me->events,
    &number_of_objects);
   if (number_of_objects)
    {
     dp$erase_hilite(
      msg = &me->msg,
      osnum = me->display_env.md_id.osnum,
      objid = me->display_env.md_id.objid);
    }
/*
 * Erase constructional geometry
 */
   sts = om$send(
     msg = message ECconstruct.display_constructions(
      FALSE,	/* Erase them */
      FALSE),	/* Erase all of them */
     targetid = my_id);
  } /* if (pos == EX_suspend) */
/*
 * Erase my status display form
 */
 if ((sender_id != my_id) &&
     me->form_requested)
  {
/***************************************************************
    sts = om$send(
    msg = message FIform.erase_form(
     FALSE,		
     FALSE),
    targetid = me->form_id,
    targetos = me->form_os);
****************************************************************/
  FIf_erase(me->form1);
  }
/*
 * Turn off the display of the associative button.
 */

 if (me->associative && (sender_id != my_id))
   GRdisplay_associative_button(FALSE);

/*
 * eof
 */
 return(sts);
}

method wakeup(int pos)
{
 IGRint		i, bytes_in, bytes_out, sts;
/*
 * If I am going to be doing an associative placement, highlight the
 * associative button.
 */
 
{
 IGRlong associative = FALSE;
/*
 * If the associative mode has been turned on then set the associative
 * flag to be TRUE if the command has been associatised. (which means we
 * are able to handle an associative construction for the said command.)
 * In such a case the surface/solid constructed is made dependent on 
 * the construction elements. Higlight the associative button to indicate
 * to the user that the command is behaving associatively.
 * pp 04/27/91
 */

 sts = om$send (msg = message ECconstruct.is_associative(ME.super_cmd->mytype,
                       &associative),
                   targetid = my_id);
 if (!(1&sts)) return (OM_E_ABORT);

 if (associative)
   me->associative = TRUE;
 else
   me->associative = FALSE;
}

 if (me->associative)
  GRdisplay_associative_button(TRUE);

/*
 * Get the active color, weight, style
 */

 bytes_in = sizeof(me->display);
 gr$get_active_display(
   msg = &me->msg, 
   sizbuf = &bytes_in,
   buffer = &me->display,
   nret = &bytes_out);
  ERROR_ABORT
/*
 * Get the active level
 */
 bytes_in = sizeof(me->construct_list.level);
 gr$get_active_level(
   msg = &me->msg,
   sizbuf = &bytes_in,
   buffer = &me->construct_list.level,
   nret = &bytes_out);
  ERROR_ABORT
/*
 * Get the enviroment in which displays
 * are to take place
 */
 bytes_in = sizeof(me->display_env);
 gr$get_display_env(
   msg = &me->msg,
   sizbuf = &bytes_in,
   buffer = &me->display_env,
   nret = &bytes_out);
  ERROR_ABORT
/*
 * Clear out the constructed object, if any.
 * I do this here such that if the command is
 * interrupted at the first state (after cycling
 * through a placement) an undo will not be
 * possible.  This is done because the user
 * could have gone off and deleted the constructed
 * object or worse placed it in a solid.  In these
 * cases the results could be very bad.
 */
 if (pos == EX_suspend)
  {
   me->have_a_constructed_object = FALSE;
/* 
 * Redraw any elements which I am saving, in
 * the hilite plane.
 */
   for (i = 0; i < me->number_of_events_input; i++)
    {
     struct	GRevent *event;

     event = &me->events[i];
     if (event->subtype == GRst_LOCATE)
      {
       enum	GRdpmode DisplayMode;
       struct	GRlc_info *loc_info;
       struct	GRid *id;
       struct	GRmdenv_info *mdenv_info;

       DisplayMode = GRhd;
       loc_info = &event->located_object[0];
       id = &loc_info->located_obj;
       mdenv_info = &loc_info->module_info.md_env;
       sts = om$send(
         msg = message GRgraphics.GRdisplay(
          &me->msg,
          &mdenv_info->matrix_type,
          mdenv_info->matrix,
          &DisplayMode, 
          &me->display_env.md_id),
         targetid = id->objid,
         targetos = id->osnum);
        ERROR_ABORT
      }
    } /* for (i = 0; i < me->number_of_events_input; i++) */
/*
 * Draw constructional geometry
 */
   sts = om$send(
     msg = message ECconstruct.display_constructions(
      TRUE,	/* Draw them */
      FALSE),	/* Draw all of them */
     targetid = my_id);
    ERROR_ABORT
  } /* if (pos == EX_suspend) */
/*
 * Draw my status display form, if I have one.
 */
 if ((sender_id != my_id) &&
     me->form_requested)
  {
   sts = om$send(		/* Don't check me->msg */
    msg = message ECconstruct.update_status_form(),
    targetid = my_id);
/***********************************************************
    sts = om$send(
    msg = message FIform.display_form(
     &me->msg,
     0,			      
     125),
    targetid = me->form_id,
    targetos = me->form_os);
************************************************************/
  FIf_set_location (me->form1, 0, 125);
  FIf_display(me->form1);
  }
/*
 * eof
 */
 return(OM_S_SUCCESS);
}

method load_construction_information()
{
 IGRboolean	no_construct_enviroment;
 IGRint		bytes_in, bytes_out, i;

 IGRboolean aflag;
 IGRint rfsts;

/*
 * Initialize
 */
 me->msg = MSSUCC;
/*
 * Set up the construct list pointers
 */
 me->construct_list.msg = &me->msg;
 me->construct_list.env_info = &me->construct_env;
 me->construct_list.newflag = FALSE;
 me->construct_list.geometry = NULL;
 me->construct_list.display = &me->display;
 me->construct_list.name = NULL;
/*
 * Set up the element specific data
 */
 {
  IGRuchar buffer;
  IGRlong	sts, loc_msg;
  struct	IGResbs *surface_specific;

  surface_specific = &me->surface_element_specific;
  me->construct_list.class_attr = (IGRchar *) surface_specific;
  surface_specific->is_surfdis = TRUE;		/* Required */
  surface_specific->is_slowdis = FALSE;		/* Doesn't matter */
  surface_specific->type = NULL;		/* Doesn't matter */
  sts = EMdpb_get(
    &loc_msg,
    EMSdpb_props,
    &buffer);
   if (! (1 & sts))
    {
     me->msg = MSFAIL;
     return(OM_E_ABORT);
    }
  surface_specific->is_polydis = buffer & EMDPB_POLYGON_DISPLAY_ON;
  sts = EMdpb_get(
    &loc_msg,
    EMSdpb_u_rules,
    &buffer);
   if (! (1 & sts))
    {
     me->msg = MSFAIL;
     return(OM_E_ABORT);
    }
  surface_specific->u_rules = buffer;
  sts = EMdpb_get(
    &loc_msg,
    EMSdpb_v_rules,
    &buffer);
   if (! (1 & sts))
    {
     me->msg = MSFAIL;
     return(OM_E_ABORT);
    }
  surface_specific->v_rules = buffer;
 }
/*
 * Determine if elements are being named.  This
 * is a futures sort of thing.  It really depends
 * on what I/DRAFT does in this area.
 */
#if IGE_WORKS_AS_DESIGNED
 bytes_in = sizeof(IGRboolean); 
 gr$get_name_mode(
   msg = &me->msg,
   sizbuf = &bytes_in,
   buffer = &me->naming_elements,
   nret = &bytes_out);
  ERROR_ABORT
#endif
/*
 * Load the active properties.  We should load these
 * because someone may wish to drive command through the
 * CI and therefore may wish to place non-displayable
 * objects.
 */
#if IGE_WORKS_AS_DESIGNED
 bytes_in = sizeof(me->construct_list.properties);
 gr$get_active_prop(
   msg = &me->msg,
   sizbuf = &bytes_in,
   buffer = &me->construct_list.properties,
   nret = &bytes_out);
  ERROR_ABORT
#else
 me->construct_list.properties = GRIS_DISPLAYABLE | GRIS_LOCATABLE;
#endif
/*
 * Load the construction enviroment
 */
 bytes_in = sizeof(me->construct_env);
 for (i = 0, no_construct_enviroment = TRUE;
      (i < me->number_of_events_input) && no_construct_enviroment;
      i++)
  {
   if (me->events[i].response == EX_DATA)
    {
     aflag = pwIsActivationOn();
     if (aflag)
     {
        rfsts = pwGetActiveModuleEnv(&me->construct_env);
        no_construct_enviroment = FALSE;
     }
     else
     {
        gr$get_construct_env(
          msg = &me->msg,
          point = &me->events[i].event.button,
          sizbuf = &bytes_in,
          buffer = &me->construct_env,
          nret = &bytes_out);
         ERROR_ABORT
        no_construct_enviroment = FALSE;
     }
    }
  }
 if (no_construct_enviroment)
  {
   gr$get_module_env(
     msg = &me->msg,
     sizbuf = &bytes_in,
     buffer = &me->construct_env,
     nret = &bytes_out);
    ERROR_ABORT
  }
/*
 * eof
 */
 return(OM_S_SUCCESS);
}

method add_event(IGRboolean is_a_located_object)
{
 IGRlong	sts, current_size;
/*
 * Initialize
 */
 me->msg = MSSUCC;
/*
 * Set the type we will store
 */
 if (is_a_located_object)
  me->event.subtype = GRst_LOCATE;
 else if (me->event.subtype == GRst_LOCATE)
  me->event.subtype = GRst_DEFAULT;
/*
 * Add the event.  I don't know how I picked the number three.
 */
 current_size = om$dimension_of(varray = me->events);
 if ((me->number_of_events_input + 3) >= current_size)
  {
   sts = om$vla_set_dimension(
     varray = me->events,
     size = current_size + 10);
    ON_ERROR
     {
      me->msg = MSFAIL;
      return(OM_E_ABORT);
     }
  }
 me->events[me->number_of_events_input] = me->event;
 me->number_of_events_input++;
/*
 * Set the constructed object to NULL.  I do
 * this here such that if we wrap back to the first
 * state and we move forward from that state then
 * an undo is no longer possible.  This is sane since
 * if user moves forward then some of the events needed
 * to backup will be distroyed.
 */
 me->have_a_constructed_object = FALSE;
/*
 * eof
 */
 return(OM_S_SUCCESS);
}

method backup_event()
{
 IGRboolean	at_the_beginning, recycle;
 IGRint		bytes_in, i, sts;
 IGRlong	type_of_event_discarded;
/*
 * Initialize
 */
 me->msg = MSSUCC;
 type_of_event_discarded = TYPE_NONE;
 at_the_beginning = (me->number_of_events_input == 0);
 recycle = at_the_beginning && me->have_a_constructed_object;
/*
 * If we are at the beginning of the command and the
 * user has already cycled through the command, then
 * delete the last object constructed.
 */
 if (recycle)
  {
   enum		GRdpmode DisplayMode;
   IGRlong	pos;

   me->state = me->final_state - 1;
   me->number_of_events_input = me->final_event_count;
   if (me->constructed_object != NULL_OBJID)
    {
     DisplayMode = GRbe;
     sts = om$send(
       msg = message ECconstruct.display_constructed_object(
        DisplayMode),
       targetid = my_id);
      ERROR_ABORT
     sts = om$send(
       msg = message GRgraphics.GRdelete(
        &me->msg,
        me->construct_list.env_info),
       targetid = me->constructed_object,
       targetos = me->construct_env.md_id.osnum);
      ERROR_ABORT
    } /* if (me->constructed_object != NULL_OBJID) */
/*
 * Note whether we are tossing a dummy event
 */
   me->number_of_events_input--;
   if (me->events[me->number_of_events_input].response == EX_MAX_RESPONSE)
    type_of_event_discarded = TYPE_DUMMY;
   else
    type_of_event_discarded = TYPE_REGULAR;
/*
 * Redraw any objects which I have in the hilite plane
 */
   pos = EX_suspend;
   sts = om$send(
     msg = message super_cmd.wakeup(pos),
     targetid = my_id);
    ERROR_ABORT
  } /* if (recycle) */
/*
 * Is this an unrecognized backup?
 */
 else if (at_the_beginning)
  {
   ex$message(msgnumb = EMS_I_00005)		/* Input discarded */
  }
/*
 * Decrement the count of events
 */
 else
  {
   struct	GRevent *event;

   me->number_of_events_input--;
   event = &me->events[me->number_of_events_input];
/*
 * Note whether we are tossing a dummy event
 */
   if (event->response == EX_MAX_RESPONSE)	/* Filler event? */
    type_of_event_discarded = TYPE_DUMMY;
   else
    {
     type_of_event_discarded = TYPE_REGULAR;
/*
 * If the event being tossed was an object,
 * then erase the object
 */
     if (event->subtype == GRst_LOCATE)
      {
       void	EFget_object_count();
       IGRlong	number_of_objects;

       EFget_object_count(
        me->number_of_events_input,
        me->events,
        &number_of_objects);
       if (number_of_objects)
        {
         enum	GRdpmode DisplayMode;
         struct	GRlc_info *loc_info;
         struct	GRid *id;
         struct	GRmdenv_info *mdenv_info;

         DisplayMode = GRhe;
         loc_info = &event->located_object[0];
         id = &loc_info->located_obj;
         mdenv_info = &loc_info->module_info.md_env;
         sts = om$send(
           msg = message GRgraphics.GRdisplay(
            &me->msg,
            &mdenv_info->matrix_type,
            mdenv_info->matrix,
            &DisplayMode, 
            &me->display_env.md_id),
           targetid = id->objid,
           targetos = id->osnum);
          ERROR_ABORT
        } /* if (number_of_objects) */
       else
        {
         dp$erase_hilite(
          msg = &me->msg,
          osnum = me->display_env.md_id.osnum,
          objid = me->display_env.md_id.objid);
        } /* ELSE FOR if (number_of_objects) */
      } /* if (event->subtype == GRst_LOCATE) */
/*
 * Even if the event was a locate go through the erase code
 * as we may have had some display associated with the 
 * object, e.g. a normal vector.
 */
     me->number_of_events_input++;
     sts = om$send(
       msg = message ECconstruct.display_constructions(
        FALSE,		/* Erase */
        TRUE),		/* Erase just one */
       targetid = my_id);
      ERROR_ABORT
     me->number_of_events_input--;
    } /* ELSE FOR if (event->reponse == EX_MAX_RESPONSE) */
  } /* ELSE FOR else if (at_the_beginning) */
/*
 * Fix stuff up
 */
 if (me->number_of_events_input)
  {
/*
 * If we tossed a dummy event then backup again.
 */
   if (type_of_event_discarded == TYPE_DUMMY)
    {
     sts = om$send(
       msg = message ECconstruct.backup_event(),
       targetid = my_id);
      ERROR_ABORT
    } /* if (type_of_event_discarded == TYPE_DUMMY) */
/*
 * Restore the last point stuff
 */
   else
    {
     IGRlong	event_index;

     event_index = me->number_of_events_input - 1;
     bytes_in = sizeof(me->events[0].event.button);
     for (i = event_index; i >= 0; i--)
      {
       if (me->events[i].response == EX_DATA)
        {
         gr$put_last_point(
           msg = &me->msg,
           sizbuf = &bytes_in,
           buffer = &me->events[i].event.button);
          ERROR_ABORT
         co$update_current_point_form(msg = &me->msg);
          ERROR_ABORT
         break;
        } /* if (me->events[i].response == EX_DATA) */
      } /* for (i = me->number_of_events_input - 1; i >= 0; i--) */
    } /* ELSE FOR if (type_of_event_discarded == TYPE_DUMMY) */
  } /* if (me->number_of_events_input) */
/*
 * eof
 */
 return(OM_S_SUCCESS);
}

method delete(int f_defer_flag)
{
 IGRlong	sts;
/*
 * Clear out the vsd
 */
 clear_vsd;
/*
 * Delete my status display form, if any
 */
 if (me->form_id != NULL_OBJID)
  {
   sts = om$send(
    msg = message Root.delete(f_defer_flag),
    targetid = me->form_id,
    targetos = me->form_os);
  }
/*
 * Death
 */
 sts = om$send(
   mode = OM_e_wrt_message,
   msg = message Root.delete(f_defer_flag),
   targetid = my_id);
  return(sts);
}

method last_state_to_first_state()
{
/*
 * Initialize
 */
 me->msg = MSSUCC;
/*
 * Save the the last state information
 * such that we can return to this state,
 * if desired
 */
 me->final_state = me->state;
 me->final_event_count = me->number_of_events_input;
/*
 * Reset my state
 */
 if (me->mytype != 42)
 {
  me->state = 0;
  me->number_of_events_input = 0;
 }
 else
 {
  if (me->events[0].response == EX_MAX_RESPONSE)
  {
   me->state = 0;
   me->number_of_events_input = 3;
  }
  else
   me->number_of_events_input = 0;
 }
/*
 * eof
 */
 return(OM_S_SUCCESS);
}

method display_constructed_object(enum	GRdpmode DisplayMode)
{
 IGRlong	sts;
 struct		GRmdenv_info *mdenv_info;

 mdenv_info = &me->construct_env.md_env;
 sts = om$send(
  msg = message GRgraphics.GRdisplay(
  &me->msg,
  &mdenv_info->matrix_type,
  mdenv_info->matrix,
  &DisplayMode, 
  &me->display_env.md_id),
  targetid = me->constructed_object,
  targetos = me->construct_env.md_id.osnum);
 return(sts);
}

method status_disp()
{
 OM_S_OBJID	set_id;
 IGRlong	*my_msg, sts;
/*
 * Compiler code reductions
 */
 my_msg = &me->msg;
/*
 * Initialize
 */
 *my_msg = MSSUCC;
/*
 * If the status display form is not already present
 * then create the form, initialize it, load the
 * values, and finally display the form.
 */
 if ((! me->form_requested) &&           /* Form not already displayed? */
     (me->active_form_name[0] != '\0'))  /* I have a status display form? */
  {
   if (me->form_id == NULL_OBJID)
    {
     me->form_os = OM_Gw_TransOSnum_0;
/**************************************************************
     sts = om$construct(
       classname = "FIform",
       osnum = me->form_os,
       p_objid = &me->form_id);
***************************************************************/
      if (! (1 & sts))
       {
        *my_msg = MSFAIL;
        goto wrapup;
       }
     set_id = NULL_OBJID;
/**************************************************************
     sts = om$send(
       msg = message FIform.init_form(
        my_msg,
        0,	
        my_id,
        OM_Gw_current_OS,
        &set_id,	
        0,	
        me->active_form_name),
       targetid = me->form_id,
       targetos = me->form_os);
******************************************************************/
      if ((! (1 & sts)) || (! (1 & *my_msg)))
       {
        *my_msg = MSFAIL;
        goto wrapup;
       }
    } /* if (me->form_id == NULL_OBJID) */
    sts = om$send(		/* Don't check me->msg */
      msg = message ECconstruct.update_status_form(),
      targetid = my_id);
    if (! (1 & sts)) goto wrapup;
/**********************************************************************
    sts = om$send(
      msg = message FIform.display_form(
       my_msg,
       0,	
       125),	
      targetid = me->form_id,
      targetos = me->form_os);
*********************************************************************/
    if ((! (1 & sts)) || (! (1 & *my_msg)))
     {
      *my_msg = MSFAIL;
      goto wrapup;
     }
   me->form_requested = TRUE;				/* rlw - 10/24/89 */
  } /* if ((! me->form_requested) && ... */
/*
 * eof
 */
wrapup:
 if (1 & *my_msg)
  return(OM_S_SUCCESS);
 else
  return(OM_E_ABORT);
}

/*
 Description

  This function counts the number of objects
  contained in the event structure.

 History

  11/03/87 : rlw : The beginning
 */

void EFget_object_count(
 number_of_events,		/* Number of input events */
 events,			/* Event structures */
 number_of_objects)		/* Number of objects found */

IGRlong		number_of_events;
struct		GRevent events[];
IGRlong		*number_of_objects;
{
 IGRlong	i, count;

 count = 0;
 for (i = 0; i < number_of_events; i++)
  {
   if (events[i].subtype == GRst_LOCATE) count++;
  }
 *number_of_objects = count;
}

end implementation ECconstruct;
