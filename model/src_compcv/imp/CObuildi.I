/* ###################   APOGEE COMPILED   ################## */
class implementation CObuild;

/*
HISTORY

13 Jun 1989 jBk  Moved gr$get macros invocations from init to
                 wakeup.

                 Converted to use message subsystem.

21 Jun 1993 Sudha modified for BSprototype ansification
14 Aug 1994 scw  Clarified sleep method

*/

#include "EMScc.h"
#define TRUE 1
#define FALSE 0
#include <stdio.h>                      /* For print statements */
#include "igrdef.h"
#include "msdef.h"
#include "OMerrordef.h"
#include "grdpbdef.h"
/* igemacros replacement */

# ifndef grdpbmacros_include
# include "grdpbmacros.h" /* gr$get_active_display */
# endif
/* end of igemacros.h replacement */
#include "bserr.h"                      /* BS error codes */
#include "bsparameters.h"               /* Global tolerances */
# include "EMS_I.h"
# include "EMS_P.h"
# include "EMS_M.h"

extern struct IGEdpb *IGE_dpb_pntr[];

method init(int type; char *str_ptr)
{
 int msg, *tmp_msg, status;

 msg = MSSUCC;
 ME.super_cmd->state = 0;
 ME.super_cmd->mytype = type;

 tmp_msg = &msg;
 status = BSEXTRACTPAR(tmp_msg, BSTOLLENVEC, ME.CObuild->tolerance);
  if (!status)
   {
    fprintf(stderr, "\nIn CObuild init method error");
    fprintf(stderr, "\nBSEXTRACTPAR error %d", msg);
    return(OM_E_ABORT);
   }

 return (OM_S_SUCCESS);
}

method wakeup (int pos)
{
    int bytes_in, bytes_out, msg;

 bytes_in = sizeof(ME.CObuild->ActiveDisplay);
 gr$get_active_display(msg = &msg, sizbuf = &bytes_in,
   buffer = &ME.CObuild->ActiveDisplay, nret = &bytes_out);
  if (!(1 & msg))
   {
    fprintf(stderr, "\nIn CObuild init method error");
    fprintf(stderr, "\nget_active_display error %d", msg);
    return(OM_E_ABORT);
   }
 bytes_in = sizeof(ME.CObuild->ActiveLevel);
 gr$get_active_level(msg = &msg, sizbuf = &bytes_in,
   buffer = &ME.CObuild->ActiveLevel, nret = &bytes_out);
  if (!(1 & msg))
   {
    fprintf(stderr, "\nIn CObuild init method error");
    fprintf(stderr, "\nget_active_level error %d", msg);
    return(OM_E_ABORT);
   }
 bytes_in = sizeof(ME.CObuild->ModuleInfo);
 gr$get_module_env(msg = &msg, sizbuf = &bytes_in,
  buffer = &ME.CObuild->ModuleInfo, nret = &bytes_out);
  if (!(1 & msg))
   {
    fprintf(stderr, "\nIn CObuild init method error");
    fprintf(stderr, "\nget_module_env error %d", msg);
    return(OM_E_ABORT);
   }

    return OM_S_SUCCESS;
}

method super_cmd.sleep (int pos)
{
    ex$message (msgnumb = EMS_P_ClearPromptField);
    ex$message (msgnumb = EMS_I_ClearStatusField);
    ex$message (msgnumb = EM_M_ClearMessageField);

    return OM_S_SUCCESS;
}

end implementation CObuild;
