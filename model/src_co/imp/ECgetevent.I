/* ###################   APOGEE COMPILED   ################## */
/*
 Description

 The purpose of this method is to consolidate basic getevent functionality
 into one method.  This is intended to reduce code and provide for a
 more uniform user interface.

 History

 12/08/87 : rlw : Pulled this out of ECconstruct execute method and put
                  it in a method by itself.
 12/18/87 : rlw : Modified such that if asking for a value and a move on
                  is input then I pretend the user just hit a <cr>.
 01/15/88 : rlw : Modified such that if asking for a string and a move on
                  is input then I pretend the user just hit a <cr>.
 02/09/88 : rlw : Modified such that if asking for a moveone and a <cr>
                  is input then I pretend the user just hit the moveon.
 */
class implementation ECconstruct;

#include "EMS.h"
#include "EMSasmacros.h"

%safe
#include <math.h>
%endsafe

#include "EC_I.h"			/* Informational messages */
#incude "ems_m_inc.h"			/* Includes everything */

method getevent(
 IGRlong	type_of_value_needed;
 IGRlong	event_mask;
 IGRchar	*prompt_string;
 IGRlong	prompt_key;
 IGRint		*response;
 IGRchar	*response_data)

{
 IGRchar	string[80], value_string[MAX_VALUE_STRING];
 IGRboolean	things_worked_out;
 IGRlong	sts;
/*
 * Initialize
 */
 me->msg = MSSUCC;
/*
 * Get the prompt string.  Note that this is
 * necessary since the locate macro will not
 * accept a string and a key.
 */
 if (prompt_string)
  strcpy(string, prompt_string);
 else
  {
   ex$message(
    msgnumb = prompt_key,
    buff = string)
  }
/*
 * Generate a string which
 * is required by getevent
 */
 switch (type_of_value_needed)
  {
   case SCALAR:
    (void) strcpy(value_string, GRIO_SCALAR);
    event_mask |= GRm_VALUE;
    break;
   case DISTANCE:
    (void) strcpy(value_string, GRIO_DISTANCE);
    event_mask |= GRm_VALUE;
    break;
   case ANGLE:
    (void) strcpy(value_string, GRIO_ANGLE);
    event_mask |= GRm_VALUE;
    break;
   default:
    value_string[0] = '\0';
    break;
  }; /* switch (type_of_value_needed) */
/*
 * Get the event
 */
 do
  {
   things_worked_out = TRUE;
   sts = ems$getevent(
     msg =		&me->msg,
     event_mask = 	event_mask,
     prompt =		string,
     value_type =	value_string,
     response =		(IGRlong *)response,
     response_data =	response_data,
     event =		&me->event);
    if (! (1 & sts)) return(OM_E_ABORT);
   if (me->event.response == GR_UNKNOWN_TYPE)
    {
     switch (*response)
      {
       case EX_RJT_MOVEON:
        if (event_mask & GRm_VALUE)
         {
          me->msg = GRw_no_value;
          me->event.response = EX_VALUE;
          me->event.subtype = GRst_DEFAULT;
         }
        else if ((event_mask & GRm_STRING) ||
                 (event_mask & GRm_TEXT_VALUE))
         {
          me->msg = GRw_no_value;
          me->event.response = EX_STRING;
          me->event.subtype = GRst_DEFAULT;
         }
        else
         {
          ex$message(msgnumb = EMS_I_00005)		/* Input discarded */
          things_worked_out = FALSE;
         }
        break;
       case EX_STRING:
        if (((me->msg == GRw_no_value) ||
             (response_data[0] == '\0')) &&		/* String is NULL? */
            (event_mask & GRm_RJT_MOVEON))
         {
          me->event.response = EX_RJT_MOVEON;
         }
        break;
       case EX_DATA:
       case EX_BACK_UP:
       case EX_OBJID:
       case EX_RESTART:
        ex$message(msgnumb = EMS_I_00005)		/* Input discarded */
        things_worked_out = FALSE;
        break;
       default:
/*      noop; */			/* Just fall through the cracks */
        break;
      }
    } /* if (me->event.response == GR_UNKNOWN_TYPE) */
  }
 while (! things_worked_out);
/*
 * Eof
 */
 return(OM_S_SUCCESS);
}

end implementation ECconstruct;
