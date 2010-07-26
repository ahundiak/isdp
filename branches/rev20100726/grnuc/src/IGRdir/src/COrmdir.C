/* #######################    APOGEE COMPILED   ######################## */
/*
 ------------------------------------------------------------------------------

  Module:  CO_ni_rmdir()

  Abstract:

     This function removes the directory that has the specified name.

  Example:  status = CO_ni_rmdir( ReturnMsg,
                                  Events );

  Arguments:

     *ReturnMsg     IGRlong         Return message:
                                       MSSUCC - success
                                       MSFAIL - failure

     *Events        struct GRevent  Pointer to event containing the directory
                                    to remove.

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
#include   "godef.h"
#include   "gr.h"
#include   "igr.h"
#include   "igrdp.h"
#include   "ex.h"
#include   "exdef.h"
#include   "exmacros.h"
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

#define    name      Events[0]->event.keyin

IGRlong CO_ni_rmdir( ReturnMsg,
                     Events )

    IGRlong            *ReturnMsg;    /* return information code          */
    struct GRevent     *Events[];     /* pointer to dir/part(s) to remove */

{
    *ReturnMsg = di$rmdir( dirname = name );

    if (*ReturnMsg&1) di$update_dir_form();
    if ( *ReturnMsg == DIR_S_SUCCESS )
    {
        ex$message ( field   = ERROR_FIELD,
                     msgnumb = GR_S_Rmdir,
                     type    = "%s",
                     var     = name );
    }

   return ( ( *ReturnMsg & 1 ) ? MSSUCC : MSFAIL );
}
