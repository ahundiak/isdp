/* ###################   APOGEE COMPILED   ################## */
class implementation ECconstruct;
/*
 Description

  This is the execute method for construction commands.  It was
  written in order to reduce code and prompt a uniform/consistent
  interface.

 History

  11/03/87 : rlw : The beginning
  11/30/87 : rlw : Added locates for reference file elements
  12/09/87 : rlw : Broke the functional pieces down into methods.
  12/18/87 : rlw : Added event mask to locate method
  12/29/87 : rlw : Pulled out construction logic and put it in a method
                   such that modification commands could ovverride it.
  01/06/88 : rlw : Interupts on locates had problems if something was
                   on the stack.  I was using the wrong response.
  07/11/88 : rlw : Display constructions did not work properly when
                   dummy events were added.
  07/28/88 : rlw : Modified to check the error return code from the wakeup
                   method.  I did this because the cross hatch command can
                   determine, in the wakeup method, that the command can not
                   possibly continue with the currently active parameters.
  09/12/88 : rlw : Modified to support suspend and non-suspend stuff
                   for the 1.2.0 release.
  07/26/89 : rlw : Forgot to take care of case where a valid move-on is
                   input at a locate prompt.
  09/28/89 : rlw : Erase prompt message when processing begins.
  12/01/89 : rlw : Modified such that when a event fails verification tests
                   the backup_event() method is not invoked.  This created
                   problems since the backup_event() method tried to
                   display_constructions() which were not valid.
 */

%safe
#include <math.h>
%endsafe

#include "EMS.h"		/* Shared library stuff */
#include "ems_m_inc.h"		/* Includes everything */
#include "EC_P.h"		/* Prompt messages */
#include "EC_I.h"		/* Status messages */
#include "EC_F.h"		/* Error box messages */

method execute(int *response; char *response_data; int pos)
{
 IGRchar	prompt_string[80];
 IGRboolean	was_valid_event, done, use_default;
 IGRboolean	locate_desired, put_on_queue;
 IGRlong	sts, event_mask, type_of_value_needed, prompt_index;
 struct		RLW_locate_info loc_info;
/*
 * Determine if the wakeup method failed.
 * If the error return code is MSINARG then I will
 * assume that the wakeup method has taken care to
 * inform the user that something was wrong.
 */
 if (! (1 & me->msg))
  {
   if (me->msg == MSINARG)
    {
     *response = TERMINATE;
     return(OM_S_SUCCESS);
    }
   else
    CMD_KILL
  }
/*
 * Output the name of this command
 * in the command field
 */
 sts = om$send(
   msg = message ECconstruct.output_command_string(),
   targetid = my_id);
  ON_ERROR CMD_KILL
/*
 * Enter infinite loop
 */
 do
  {
/*
 * Initialize
 */
   done = FALSE;
/*
 * Get the correct prompt message and
 * the mask needed for the next event
 */
   event_mask = GRm_DATA | GRm_RESTART | GRm_BACK_UP;
   locate_desired = FALSE;
   type_of_value_needed = NONE;
   prompt_index = GRIO_NO_MSG;
   sts = om$send(
     msg = message ECconstruct.next_event_processing(
      prompt_string,
      &prompt_index,
      &event_mask,
      &type_of_value_needed,        
      &locate_desired,
      &loc_info),
     targetid = my_id);
    ON_ERROR CMD_KILL
   if (prompt_index != GRIO_NO_MSG)
    {
     ex$message(
      msgnumb = prompt_index,
      buff = prompt_string)
    }
/*
 * Perform an element location, if desired
 */
   if (locate_desired)
    {
     sts = om$send(
       msg = message ECconstruct.locate_object(
        event_mask,
        prompt_string,
        LC_NO_MSG,
        &loc_info,
        FALSE,		/* Do not automatically put accept on queue */
        &put_on_queue,
        response,
        response_data),
       targetid = my_id);
      ON_ERROR CMD_KILL
     if (me->locate_stack.num_entries) return(OM_S_SUCCESS);
    } /* if (locate_desired) */
   else
    {
/*
 * Perform dynamics (We never perform dynamics during
 * a locate operation).
 */
     if (me->number_of_events_input &&
         vsd_and_queue_empty)
      {
       UI_prompt(prompt_string);
       sts = om$send(
         msg = message ECconstruct.perform_dynamics(),
         targetid = my_id);
        ON_ERROR CMD_KILL
      }
/*
 * Finally, get the required event
 */
     sts = om$send(
       msg = message ECconstruct.getevent(
        type_of_value_needed,
        event_mask,
        prompt_string,
        GRIO_NO_MSG,
        response,
        response_data),
       targetid = my_id);
      ON_ERROR CMD_KILL
    } /* ELSE FOR if (locate_desired) */
/*
 * The information as to whether the user input a <cr>
 * in response to a question is not contained in the event.
 * Therefore save this information for the verification
 * process.
 */
   use_default = (me->msg == GRw_no_value);
/*
 * Branch based on the type of response
 */
   switch (me->event.response)
    {
/*
 * If the event is unknown and is an event that
 * the command server may understand then let 
 * it have the event, else just discard it.
 */
     case GR_UNKNOWN_TYPE:
      return(OM_S_SUCCESS);
/*
 * If the event is backup then throw away the
 * last event and reload the last point dpb stuff
 */
     case EX_BACK_UP:
      sts = om$send(
        msg = message ECconstruct.backup_event(),
        targetid = my_id);
       ON_ERROR CMD_KILL
      break;
/*
 * If the event is restart then clean
 * up instance data and reset the state
 */
     case EX_RESTART:
      sts = om$send(
        msg = message ECconstruct.restart(),
        targetid = my_id);
       ON_ERROR CMD_KILL
      break;
/*
 * We must have gotten an event that was understood.
 * Call the routine which will add this point.  If an
 * error occurs then we will not add the point to the
 * event buffer.
 */
     default:
      {
       IGRlong	events_before;

       sts = om$send(
         msg = message ECconstruct.add_event(
          locate_desired && (me->event.response != EX_RJT_MOVEON)),
         targetid = my_id);
        ON_ERROR CMD_KILL
       events_before = me->number_of_events_input;
       sts = om$send(
         msg = message ECconstruct.verify_event(
          use_default,
          &was_valid_event,
          &done),
         targetid = my_id);
        ON_ERROR CMD_KILL
       if (!was_valid_event)
        {
         me->number_of_events_input--;
        }
/*
 * Added logic to take care of display cases where the verification
 * process has added dummy events in order to skip certain questions.
 * In this case we need to display the event that was verified.  I do
 * not display the dummy events since they should have have a display.
 *
 * rlw - 07/11/88
 */
       else if (!done)
        {
         IGRlong	dummy_events_added, temp;

         temp = me->number_of_events_input;
         dummy_events_added = me->number_of_events_input - events_before;
         if (dummy_events_added > 0)	/* Were dummy events added? */
          me->number_of_events_input = events_before;
         sts = om$send(
           msg = message ECconstruct.display_constructions(
            TRUE,	/* Draw in background */
            TRUE),	/* Display one state */
           targetid = my_id);
          ON_ERROR CMD_KILL
         me->number_of_events_input = temp;
         if (locate_desired &&
             put_on_queue)
          {
           IGRlong	sizeof_event;

           sizeof_event = sizeof(struct GRevent);
           sts = ex$putque(
             msg = &me->msg,
             response = &me->event1.response,
             byte = &sizeof_event,		/* Should be slightly less */
             buffer = (IGRchar *)&me->event1.event);
            ON_ERROR CMD_KILL
          } /* if (located_desired && put_on_queue) */
        } /* else if (!done) */
      } /* default: */
      break;
    } /* switch (me->event.response) */
/*
 * Construct and display the required object
 */
   if (done)
    {
/*
 * If the last event that I have is not a located object then 
 * decrement the number of events that I have before going to sleep.
 * This is done because sleep will erase via display constructions.
 * Display constructions does not know how to display the last
 * piece of information since it would only flash on the screen.
 */
     if (!locate_desired) me->number_of_events_input--;
     pos = EX_suspend;
     sts = om$send(
       msg = message ECconstruct.sleep(pos),
       targetid = my_id);
      ON_ERROR CMD_KILL
     if (!locate_desired) me->number_of_events_input++;
     ex$message(msgnumb = EMS_P_00000)		/* Erase prompt message */
     ex$message(msgnumb = EMS_I_00003)		/* Processing */
/*
 * Get the construction information
 */
     sts = om$send(
       msg = message ECconstruct.load_construction_information(),
       targetid = my_id);
      ON_ERROR CMD_KILL
/*
 * Construct the desired object
 */
     sts = om$send(
       msg = message ECconstruct.perform_duty(),
       targetid = my_id);
      ON_ERROR CMD_KILL
/*
 * Make the transition from the last state to 
 * the first state.
 */
     sts = om$send(
       msg = message ECconstruct.last_state_to_first_state(),
       targetid = my_id);
      ON_ERROR CMD_KILL
    } /* if (done) */
  } /* do */
 while(TRUE);
}

/*
 Description

 This method calls the construction method and displays it's
 results.

 History

 rlw : 12/29/87 : Creation date
 */
method perform_duty()
{
 IGRlong	sts;
/*
 * Construct the desired object
 */
 sts = om$send(
   msg = message ECconstruct.perform_construction(),
   targetid = my_id);
  me->have_a_constructed_object = TRUE;
/*
 * If an error occured then inform the user
 * that the construction failed
 */
  ON_ERROR
   ex$message(msgnumb = EMS_I_00002)	/* Construction failed */
/*
 * If no object was constructed then inform the user
 * that no solution was found.  This is not an error
 * condition.
 */
  else if (me->constructed_object == NULL_OBJID)
   ex$message(msgnumb = EMS_I_00019)	/* No solution found */
/*
 * Display the constructed object
 */
  else
   {
    enum	GRdpmode DisplayMode;

    ex$message(				/* Processing . */
     msgnumb = EMS_I_00004,
     type = "%s",
     var = " . ")
    DisplayMode = GRbd;
    sts = om$send(
      msg = message ECconstruct.display_constructed_object(
       DisplayMode),
      targetid = my_id);
    ex$message(msgnumb = EMS_I_00000)	/* Clear field */
     ON_ERROR
      {
       me->msg = MSFAIL;
       return(OM_E_ABORT);
      }
   }
/*
 * eof
 */
 me->msg = MSSUCC;
 return(OM_S_SUCCESS);
}

end implementation ECconstruct;
