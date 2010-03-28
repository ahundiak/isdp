/* #######################    APOGEE COMPILED   ######################## */
/*
 ------------------------------------------------------------------------------

  Module:  CO_ni_remove()

  Abstract:

     This function removes the specified element name from the directory
     sub-system.

  Example:  status = CO_ni_remove( ReturnMsg,
                                   Events );

  Arguments:

     *ReturnMsg     IGRlong         Return message:
                                       MSSUCC - success
                                       MSFAIL - failure

     *Events        struct GRevent  Pointer to event containing the element
				    name to remove.

  History:   jsd   06/27/88   - created

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
#include   "griomacros.h"
#include   "grdpbdef.h"
#include   "grdpbmacros.h"
#include   "igrmacros.h"
#include   "grmessage.h"
#include   "DItypedef.h"
#include   "DIdef.h"
#include   "DIprims.h"
#include   "DIglob.h"
#include   "DImacros.h"

IGRlong CO_ni_remove( ReturnMsg,
                      Events )

    IGRlong            *ReturnMsg;    /* return information code      */
    struct GRevent     *Events[];     /* pointer to element to remove */

{
   *ReturnMsg = di$rename( oldname = Events[0]->event.keyin );
   if (*ReturnMsg&1) di$update_dir_form();
   return( ( *ReturnMsg & 1 ) ? MSSUCC : MSFAIL );

}
