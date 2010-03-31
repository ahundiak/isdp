/* ###################   APOGEE COMPILED   ################## */
/*
 Description

 This function reports the fitting errors to the operator.
 The input consists of the maximum error, average error, and a line
 which indicates the point of maximum error between the original
 data and the fitted data.

 History

 09/05/88 : rlw : Creation date
 */

class implementation Root;

%safe
#include <math.h>
%endsafe

#include "EMS.h"		/* Shared library stuff */
#include "ems_m_inc.h"		/* Includes everything */
#include "EC_I.h"		/* Informational messages */
#include "msdef.h"
#include "msmacros.h"

IGRlong EFreport_fit_errors(
 maximum_error,			/* Input - maximum error in fit */
 average_error,			/* Input - average error in fit */
 maximum_segment,		/* Input - line to be drawn */
 display,			/* Input - Color, weight, etc. */
 display_env,			/* Input - Active display enviroment */
 my_stupid_id,			/* Input - Who the caller is */
 msg)				/* Output - error return code */

IGRdouble	maximum_error;
IGRdouble	average_error;
IGRpoint	maximum_segment[2];
struct		IGRdisplay *display;
struct		GRmd_env *display_env;
OM_S_OBJID	my_stupid_id;
IGRlong		*msg;

{
 IGRlong	sts;
/*
 * Initialize
 */
 *msg = MSSUCC;
/*
 * Build up the error string and report it
 */
 {
  /*extern	int UI_echo();*/
  IGRchar	average_error_string[80], maximum_error_string[80];
  IGRchar	string[80];
  extern	IGRlong	EFconvert_to_user_units();

  average_error_string[0] = '\0';		/* No characters */
  sts = EFconvert_to_user_units(
    average_error,
    FALSE,
    average_error_string,
    msg);
   if (! (1 & sts)) goto wrapup;
  maximum_error_string[0] = '\0';		/* No characters */
  sts = EFconvert_to_user_units(
    maximum_error,
    TRUE,
    maximum_error_string,
    msg);
   if (! (1 & sts)) goto wrapup;
  ex$message(
   msgnumb = EMS_I_00023,
   type = "%s%s",
   var = `average_error_string, maximum_error_string`,
   buff = string);
   ex$message(in_buff = string, field = ERROR_FIELD);

 }
/*
 * Display the max deviation marker
 */
 if (maximum_error != 0.0)
  {
   extern	IGRlong	ECdisplayPointSetByBuffer();
   struct	IGRdisplay my_display;

   my_display = *display;
   my_display.weight += 3;
   sts = ECdisplayPointSetByBuffer(
     msg,
     my_display,
     *display_env,
     my_stupid_id,
     2,
     maximum_segment,
     TRUE);
    if (! (1 & sts))
     {
      *msg = MSFAIL;
      goto wrapup;
     }
  } /* if (maximum_error != 0.0) */
/*
 * Eof
 */
wrapup:
 if (1 & *msg)
  return(TRUE);
 else
  return(FALSE);
}

end implementation Root;
