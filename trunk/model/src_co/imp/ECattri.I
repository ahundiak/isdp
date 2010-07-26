/* ###################   APOGEE COMPILED   ################## */
/*
 DESCRIPTION

 This trivial command object allows the operator to modify the system
 tolerances.

 HISTORY

 rlw : 04/??/87 : Creation date
 rlw : 06/01/87 : Reworked to use dpb stuff and output tolerances in 
                  user units.  Also added checks to ensure that basis
                  tolerance is always less than other tolerances.
 rlw : 12/28/87 : Reworked to use message subsystem, etc..
 pp  : 04/29/88 : Modified to update the form (if active) once
                  the tolerances are changed
 rlw : 12/01/88 : Modified to display warning message for bastol.
 rlw : 02/01/89 : Erase warning message before returning.
 Sudha   06/02/93        modified to include for BSprototype headers

 */
class implementation ECattr;


%safe
#include <math.h>
%endsafe

#define CHT	0
#define OFFTOL	1
#define ARCTOL	2
#define BASTOL	3
#define IGE_IS_BROKEN 1

#include "EMS.h"
#include "ems_m_inc.h"		/* Includes everything */
#include "EC_P.h"		/* Message keys for prompt strings */
#include "EC_I.h"		/* Message keys for status strings */
#include "EC_M.h"		/* Message keys for command strings */
#include "EC_F.h"		/* Message keys for fatal error strings */
#include "bschgdeppar.h"
#include "bschangepar.h"

method execute(int *response; char *response_data; int pos)
{
 IGRboolean	use_default, status;
 IGRlong	sizbuf, nret, sts, *msg, loc_msg;
 IGRlong	command_key, prompt_key;
 IGRdouble	tolerance, bas_tol, cht_tol, arc_tol, off_tol;
/*
 * Initialize
 */
 msg = &me->msg;
 sizbuf = sizeof(IGRdouble);
/*
 * Enter infinite loop
 */
 do
  {
/*
 * Get the current tolerances
 */
   gr$get_chord_height_tolerance(
     msg = msg,
     sizbuf = &sizbuf,
     buffer = &cht_tol,
     nret = &nret);
    if (! (1 & *msg)) CMD_KILL
   gr$get_basis_tolerance(
     msg = msg,
     sizbuf = &sizbuf,
     buffer = &bas_tol,
     nret = &nret);
    if (! (1 & *msg)) CMD_KILL
   gr$get_arclength_tolerance(
     msg = msg,
     sizbuf = &sizbuf,
     buffer = &arc_tol,
     nret = &nret);
    if (! (1 & *msg)) CMD_KILL
   gr$get_offset_tolerance(
     msg = msg,
     sizbuf = &sizbuf,
     buffer = &off_tol,
     nret = &nret);
    if (! (1 & *msg)) CMD_KILL
   switch (me->mytype)
    {
     case CHT:
      command_key = EM_M_0063;
      prompt_key = EMS_P_00093;
      tolerance = cht_tol;
      break;
     case OFFTOL:
      command_key = EM_M_0064;
      prompt_key = EMS_P_00094;
      tolerance = off_tol;
      break;
     case ARCTOL:
      command_key = EM_M_0065;
      prompt_key = EMS_P_00095;
      tolerance = arc_tol;
      break;
     case BASTOL:
      {
       /*extern	IGRint UI_echo();*/
       IGRchar	string[80];

       command_key = EM_M_0066;
       prompt_key = EMS_P_00096;
       tolerance = bas_tol;
       ex$message(
        msgnumb = EMS_I_00099,
        buff = string);
       (void) UI_echo(string);
      }
      break;
     default:
      CMD_KILL
    }
/*
 * Display the appropriate messages
 */
   {
    IGRchar	status_string[80];

    status_string[0] = '\0';
    sts = EFconvert_to_user_units(
      tolerance,
      TRUE,
      status_string,
      msg);
     ON_ERROR CMD_KILL
    ex$message(
     msgnumb = command_key);
    ex$message(
     msgnumb = EMS_I_00025,
     type = "%s",
     var = `status_string`);
   }
/*
 * Get the tolerance
 */
   sts = om$send(
     msg = message ECconstruct.getevent(
      DISTANCE,
      NULL,
      NULL,
      prompt_key,
      response,
      response_data),
     targetid = my_id);
    ON_ERROR CMD_KILL
   use_default = (*msg == GRw_no_value);
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
      UI_echo("");
      return(OM_S_SUCCESS);
/*
 * We got a tolerance, validate it.
 */
     default:
      if (!use_default)
       {
        IGRboolean	valid_tolerance;
        IGRlong		error_key;

        valid_tolerance = TRUE;
        tolerance = me->event.event.value;
        switch (me->mytype)
         {
          case CHT:
          case OFFTOL:
          case ARCTOL:
           if (tolerance < bas_tol)
            {
             valid_tolerance = FALSE;
             error_key = EMS_I_00026;
            }
           break;
          case BASTOL:
           if ((tolerance > cht_tol) ||
               (tolerance > arc_tol) ||
               (tolerance > off_tol))
            {
             valid_tolerance = FALSE;
             error_key = EMS_I_00027;
            }
           break;
          default:
           CMD_KILL
         } /* switch (ME.super_cmd->mytype) */
/*
 * Change the tolerance, if valid
 */
        if (valid_tolerance)
         {
          switch (ME.super_cmd->mytype)
           {
            case CHT:
             gr$put_chord_height_tolerance(
               msg = msg,
               sizbuf = &sizbuf,
               buffer = &tolerance);
#if IGE_IS_BROKEN
             status = BSchangepar(
               &loc_msg,
               BSTOLCHRDHT,
               tolerance);
              if (! status) CMD_KILL
#endif
             break;
            case OFFTOL:
             gr$put_offset_tolerance(
               msg = msg,
               sizbuf = &sizbuf,
               buffer = &tolerance);
#if IGE_IS_BROKEN
             status = BSchangepar(
               &loc_msg,
               BSTOLOFFSET,
               tolerance);
              if (! status) CMD_KILL
#endif
             break;
            case ARCTOL:
             gr$put_arclength_tolerance(
               msg = msg,
               sizbuf = &sizbuf,
               buffer = &tolerance);
#if IGE_IS_BROKEN
             status = BSchangepar(
               &loc_msg,
               BSTOLARCLEN,
               tolerance);
              if (! status) CMD_KILL
#endif
             break;
            case BASTOL:
             gr$put_basis_tolerance(
               msg = msg,
               sizbuf = &sizbuf,
               buffer = &tolerance);
#if IGE_IS_BROKEN
             BSchgdeppar(
               tolerance,
               &loc_msg);
              if (loc_msg != BSSUCC) CMD_KILL
#endif
             break;
            default:
             CMD_KILL
           } /* switch (ME.super_cmd->mytype) */
           EFupdate_form();
         } /* if (valid_tolerance) */
/*
 * The tolerance that was selected is
 * invalid.  Display an error message to the
 * user informing him of this.
 */
        else
         {
          IGRchar	string[80];

          ex$message(
           msgnumb = error_key,
           buff = string);
          UI_echo(string);
         } /* ELSE FOR if (valid_tolerance) */
       } /* if (! use_default) */
      break;
    } /* switch (me->event.response) */
  } /* do */
 while(TRUE);
}

end implementation ECattr;
