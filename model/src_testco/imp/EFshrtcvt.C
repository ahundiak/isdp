/* ###################   APOGEE COMPILED   ################## */
#define DEBUG 0
#if DEBUG
#include <stdio.h>
#endif

#include "EMS.h"
#include <string.h>
#include "bs.h"
#include "OMmacros.h"
#include "OMlimits.h"
#include "OMminimum.h"
#include "OMerrordef.h"
#include "griodef.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "gr.h"
#include "griomacros.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"

IGRlong EFshort_cvtn( header, value, option, size)

IGRchar      header[80];
IGRdouble    value;
IGRint       option;          /* =0 - load conversion factor AND convert
                                      AND append unit string
                                 =1 - load conversion factor AND convert
                                 =2 - convert AND append unit string
                                 =3 - convert ONLY 
                                 =4 - Respect inverse scaling AND
                                      convert AND append unit string */
IGRint       size; /* Size of the header array being passed in */
/* *********************************************************************

History
 dhm : ??/??/?? : Creation
 pp  : 10/10/89 : Added an option to respect inverse scaling during conversion.
 rlw : 11/17/89 : Modified because division was taking place with uninitialized
                  variable in some cases.

   ********************************************************************* */

{
 IGRchar	work_string[80], master_units[80];
 IGRlong	sts, msg;
 OMuword	osnum;
/*
 * Initialize
 */
 work_string[0] = '\0';
/*
 * Get the readout object space number
 */
 {
  IGRint	bytes_in, bytes_out;
  struct	GRmd_env master_env;

  bytes_in = sizeof(struct GRmd_env);
  gr$get_module_env(
    msg = &msg,
    sizbuf = &bytes_in,
    buffer = &master_env,
    nret = &bytes_out);
   if (! (1 & msg)) return(OM_E_ABORT);
  osnum = master_env.md_id.osnum;
 }
/*
 * Branch based on option
 */
 if (( option == 0) || ( option == 1) || (option == 2) || (option == 3))
  {   
   IGRchar	strings[3][40];
   IGRshort	flag, number_of_defaults;
   IGRdouble	conversion_factor, number;
/*
 * Get conversion factor
 */
   sts = co$cvt_imp_to_wrk(
     msg = &msg,
     unit_type = "UOM_DISTANCE",
     osnum = osnum,
     primary = 1.0,
     result = &conversion_factor);
    if (! (1 & msg)) return(OM_E_ABORT);
   flag = 0;		/* Get output stuff */
   sts = co$get_default_units(
     msg = &msg,
     table_name = "UOM_DISTANCE",
     osnum = osnum,
     flag = &flag,
     num_defaults = &number_of_defaults,
     default_units = strings);
    if (! (1 & msg)) return(OM_E_ABORT);
   strcpy(master_units, strings[0]);
   number = value / conversion_factor;
   if ((option == 0) || ( option == 2))
    sprintf(work_string," %lg %s", number, master_units);
   else if ((option == 1) || ( option == 3))
    sprintf(work_string," %lg ", number);
  } /* if option (0, 1, 2, or 3) */
 else if (option == 4)
  {
   IGRshort num_alias = 1;
   IGRshort field_size;
 
   /*
    * 12/03/92 - JSD - We must specify field_size in co$cvt_imp_to_alias
    * to prevent the default of 150.
    */
   field_size = sizeof(IGRchar) * 80;

   sts = co$cvt_imp_to_alias(
     msg = &msg,
     unit_type = GRIO_DISTANCE,
     osnum = osnum,
     working_units = &value,
     num_alias = &num_alias,
     field_size = &field_size,
     cvt_list = work_string);
    if (! (1 & msg)) return(OM_E_ABORT);
  } /* else if (option == 4) */
/*
 * Made the following modification to prevent a potential override of
 * memory.
 * pp (09/29/89)
 */
 strncat(header,work_string,size - strlen(header) - 1);
/*
 * eof
 */
 return(OM_S_SUCCESS);
}
