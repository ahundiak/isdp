/* #######################    APOGEE COMPILED   ######################## */
/*
 ------------------------------------------------------------------------------

  Module:  CO_ni_toggle_dir_mode()

  Abstract:

   This function toggles the DIRECTORY MODE between SYSTEM MODE and USER
   MODE.

  Example:  status = CO_ni_set_dir_mode( ReturnMsg,
                                         Events );

  Arguments:

     *ReturnMsg     IGRlong         Return message:
                                       MSSUCC - success
                                       MSFAIL - failure

     *Events        struct GRevent  Pointer to event containing the string
                                    describing the new default directory.
				    This argument is ignored for this function!

  History:   jsd   09/05/88   - created
  History:   srh   11/20/89   - changed message for system mode to a warning

 -----------------------------------------------------------------------------
 */

/* EH */

#include   "coimport.h"
#include   "codebug.h"
#include   "OMminimum.h"
#include   "OMprimitives.h"
#include   "igrtypedef.h"
#include   "igetypedef.h"
#include   "msdef.h"
#include   "msmacros.h"
#include   "exdef.h"
#include   "godef.h"
#include   "gr.h"
#include   "igr.h"
#include   "igrdp.h"
#include   "ex.h"
#include   "go.h"
#include   "griodef.h"
#include   "grio.h"

/* disabled in v. 2.0.0 */
#argsused
IGRlong CO_ni_toggle_dir_mode( ReturnMsg,
                               Events )

    IGRlong            *ReturnMsg;    /* return information code      */
    struct GRevent     *Events[];     /* pointer to new default dir   */

{
   return( *ReturnMsg = MSFAIL );
}
