class implementation COpdu;
/*
   This file loads all PDU/PDM functions called from EMS. 

   Author: Jamal Shakra
   Date: 9-30-93
*/

/* Include file section */
#include        "stdio.h"
#include        "OMlimits.h"
#include        "unistd.h"
#include        "DIdef.h"
#include        "DItypedef.h"
#include        "DIprims.h"
#include        "DIglob.h"
#include        "PDUerror.h"
#include        "PDUstr.h"
#include        "PDUintdef.h"
#include        "PDUpart.h"
#include        "msdef.h"
#include        "godef.h"
#include        "igrdp.h"
#include        "partmacros.h"
#include        "part.h"
#include        "partdef.h"
#include        "string.h"
#include        "dpmacros.h"
#include        "grdpbmacros.h"
#include        "MEMstruct.h"
#include        "MEMerrordef.h"
#include        "comnmacros.h"
#include        "ctype.h"
#include        "PDUuser.h"
#include        "PDUfile_def.h"
#include        "PDUgrpart.h"
#include        "PDUnode.h"
#include        "expriv.h"



/* Global external variables */
extern  int      PDMdebug_on;

/* Global variables */

/* Imported messages */

IGRint PDUload_PDUexit_save()
 {
  IGRint status;
  extern IGRint PDUexit_save();
  int  (*prev_function)();

  _pdm_debug("In the PDUload_PDUexit_save function", 0);

  status = ex$exit_function(
                            function = PDUexit_save,
                            previous_function = &prev_function
                           );
  _pdm_status("ex$exit_function", status);

  return(1);
 }


IGRint PDUload_PDUexit_nosave()
 {
  IGRint status;
  extern IGRint PDUexit_nosave();
  int  (*prev_function)();

  _pdm_debug("In the PDUload_PDUexit_nosave function", 0);

  status = ex$exit_function_no_save(
                                    function = PDUexit_nosave,
                                    previous_function = &prev_function
                                   );
  _pdm_status("ex$exit_function_no_save", status);

  return(1);
 }

end implementation COpdu;
