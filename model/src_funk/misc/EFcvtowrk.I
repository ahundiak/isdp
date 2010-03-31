/* ###################   APOGEE COMPILED   ################## */
/* ###################   ANSI COMPILED     ################## */
/*
 * This function does the necessary units conversion for doubles.
 * This function was taken mostly from prasad's EFconvert.
 * dhm   4/26/88   creation date.
 */

class implementation Root;

#include "EMS.h"
#include <stdio.h>
#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "griomacros.h"
#include "EMSerrordef.h"  /* EMSerror defintions */

void EFcvt_to_wrk(EMmsg, mod_os, invalue, outvalue)

 IGRlong *EMmsg;
 OMuword mod_os;
 IGRdouble invalue;
 IGRdouble *outvalue;
{
 IGRlong status, msg_loc;
 IGRdouble factor;

 *EMmsg = EMS_S_Success;

 status = co$cvt_imp_to_wrk(msg = &msg_loc,
                            unit_type = "UOM_DISTANCE",
                            osnum = mod_os,
                            primary = 1.0,
                            result = &factor);
 if (!(1&status&msg_loc)) 
 {
   *EMmsg = EMS_E_Fail;
   goto wrapup;
 }

*outvalue = invalue / factor;

wrapup:
 return ;

}
end implementation Root;
