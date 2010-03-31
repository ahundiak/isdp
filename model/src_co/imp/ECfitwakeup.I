/* ###################   APOGEE COMPILED   ################## */
class implementation ECfit;
/*
 Description

  This is the wakeup method for fitting commands.
  It merely loads the active parameters from the
  dpb into the command objects instance data and
  displays them to the user.

 History

  12/13/87 : rlw : The beginning
  12/16/87 : rlw : Added checks to ensure that order 2 cannot be periodic
  09/02/88 : rlw : Modified to output wakeup string for place fitted curve
  06/02/89 : rlw : Modified to output wakeup string for place helix curve
 */

%safe
#include <math.h>
%endsafe

#include "EMS.h"			/* Shared library stuff */
#include "ems_m_inc.h"			/* Includes everything */
#include "EC_I.h"			/* Informational messages */
#include "EMSdpb.h"			/* DPB include file */

method wakeup(int pos)
{
 IGRuchar buffer;
 IGRlong	loc_msg, sts;
/*
 * Do what my parent does
 */
 sts = om$send(
   mode = OM_e_wrt_message,
   msg = message ECconstruct.wakeup(pos),
   targetid = my_id);
  ERROR_ABORT
/*
 * Certain fit commands such as convex fit
 * points and networks do not care about
 * order, etc..
 */
 if ((me->mytype == 55) ||
     (me->mytype == 62))
  return(OM_S_SUCCESS);
/*
 * If I have no events then load
 * the active properties.  
 */
 if (! me->number_of_events_input)
  {
   sts = EMdpb_get(
     &loc_msg,
     EMSdpb_u_order,
     &buffer);
    if (! (1 & sts)) return(sts);
   me->u_order = buffer;
   sts = EMdpb_get(
     &loc_msg,
     EMSdpb_v_order,
     &buffer);
    if (! (1 & sts)) return(sts);
   me->v_order = buffer;
   sts = EMdpb_get(
     &loc_msg,
     EMSdpb_props,
     &buffer);
    if (! (1 & sts)) return(sts);
/*
 * rlw - added checks to insure periodic is
 * not set for 2nd order cases
 */
   if ((buffer & EMDPB_U_PERIODIC) &&
       (me->u_order > 2))
    me->u_periodic = TRUE;
   else
    me->u_periodic = FALSE;
   if ((buffer & EMDPB_V_PERIODIC) &&
       (me->v_order > 2))
    me->v_periodic = TRUE;
   else
    me->v_periodic = FALSE;
  }
/*
 * Display the active parameters
 */
 switch (me->mytype)
  {
   case 36:
   case 116:
   case 117:
    {
     IGRchar	status_string[160];
     IGRchar	tmp_string[80], tolerance_string[80];
     IGRboolean	status;
     extern	IGRlong EFconvert_to_user_units();
     IGRdouble	tolerance;

     me->u_periodic = FALSE;
     me->v_periodic = FALSE;
     status = BSEXTRACTPAR(
      &loc_msg,
      BSTOLCHRDHT,
      tolerance);
     tmp_string[0] = '\0';
     sts = EFconvert_to_user_units(
       tolerance,
       TRUE,
       tmp_string,
       &loc_msg);
      if (! (1 & sts))
       {
        me->msg = MSFAIL;
        return(OM_E_ABORT);
       }
     ex$message(
      msgnumb = EMS_I_00025,
      type = "%s",
      var = `tmp_string`,
      buff = tolerance_string);
     if (me->mytype == 36)
      strcpy(status_string, tolerance_string);
     else
      {
       ex$message(
        msgnumb = EMS_I_00028,
        type = "%2d%2d",
        var = `me->u_order, me->v_order`,
        buff = status_string);
       strcat(status_string, " ");
       strcat(status_string, tolerance_string);
      }
     ex$message(
      in_buff = status_string,
      field = ERROR_FIELD);
    }
    break;
   default:
    ex$message(
     msgnumb = EMS_I_00020,
     type = "%2d%2d%1d%1d",
     var = `me->u_order, me->v_order, me->u_periodic, me->v_periodic`);
    break;
  } /* switch (me->mytype) */
/*
 * eof
 */
 return(OM_S_SUCCESS);
}

end implementation ECfit;
