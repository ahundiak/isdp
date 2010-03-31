/* ###################   APOGEE COMPILED   ################## */
/*
 Description

 This routine converts measurement data into a string for display
 to the operator.  It first converts the data into user units, optionally
 adds a unit indentifier  (mm,in,??), and then encodes this into the
 input string.

 Bugs

 This routine does not check to ensure that overflow on the strings
 does not take place.

 History

 ??/??/87 : pwd : Paul Dailey wrote this
 12/15/87 : rlw : Rewrote and renamed from EFshort_cvt()
 02/08/88 : rlw : Changed argument flag to get units string.  Comment in
                  griomacros.h were/are bad.
 */

class implementation Root;

%safe
#include <math.h>
%endsafe

#include "EMS.h"
#include "ems_m_inc.h"			/* Includes everything */

IGRlong EFconvert_to_user_units(
 distance,
 want_master_string,
 string,
 msg)

IGRdouble	distance;
IGRboolean	want_master_string;
IGRchar		string[80];
IGRlong		*msg;

{
 IGRchar	master_string[40];
 IGRlong	sts;
 IGRdouble	conversion_factor;
 OMuword	osnum;
/*
 * Initialize
 */
 *msg = MSSUCC;
/*
 * Get the readout object space number
 */
 {
  IGRint	bytes_in, bytes_out;
  struct	GRmd_env master_env;

  bytes_in = sizeof(struct GRmd_env);
  gr$get_module_env(
    msg = msg,
    sizbuf = &bytes_in,
    buffer = &master_env,
    nret = &bytes_out);
   if (! (1 & *msg)) goto wrapup;
  osnum = master_env.md_id.osnum;
 }
/*
 * Get the conversion factor
 */
 sts = co$cvt_imp_to_wrk(
   msg = msg,
   unit_type = "UOM_DISTANCE",
   osnum = osnum,
   primary = 1.0,
   result = &conversion_factor);
  if (! (1 & sts)) goto wrapup;
/*
 * Convert the input number into
 * users units
 */
 distance /= conversion_factor; 
/*
 * Get the master unit string
 */
 if (want_master_string)
  {
   IGRchar	strings[3][40];
   IGRshort	flag, number_of_defaults;

   flag = 0;		/* Get output stuff */
   sts = co$get_default_units(
     msg = msg,
     table_name = "UOM_DISTANCE",
     osnum = osnum,
     flag = &flag,
     num_defaults = &number_of_defaults,
     default_units = strings);
    if (! (1 & sts)) goto wrapup;
   strcpy(master_string,strings[0]);
  }
/*
 * Build the required string
 */
 {
  IGRchar	work_string[80];

  if (want_master_string)
   sprintf(work_string," %lg %s", distance, master_string); 
  else
   sprintf(work_string," %lg ", distance);
  strcat(string, work_string);
 }
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
