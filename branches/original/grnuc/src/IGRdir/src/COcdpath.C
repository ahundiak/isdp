/* #######################    APOGEE COMPILED   ######################## */
/*
 ------------------------------------------------------------------------------

  Module:  CO_ni_cdpath()

  Abstract:

     This function sets the default directory and displays the modification.

  Example:  status = CO_ni_cdpath( ReturnMsg,
                                   Events );

  Arguments:

     *ReturnMsg     IGRlong         Return message:
                                       MSSUCC - success
                                       MSFAIL - failure

     *Events        struct GRevent  Pointer to event containing the string
                                    describing the directory search path.

  History:   jsd   06/27/88   - created
  History:   jsd   09/26/89   - fixed NULL cdpath initialization

 -----------------------------------------------------------------------------
 */

/* EH */

#include   "coimport.h"
#include   "codebug.h"
#include   <ctype.h>
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

extern char *strncat();


#define cd_path Events[0]->event.keyin

IGRlong CO_ni_cdpath( ReturnMsg,
                      Events )

    IGRlong            *ReturnMsg;    /* return information code          */
    struct GRevent     *Events[];     /* pointer to directory search path */

{

    extern DIchar DIR_G_cdpath [DI_PATH_MAX];

    *ReturnMsg = MSSUCC;

    DIstrcpy ( DIR_G_cdpath, cd_path );

    ex$message ( field   = ERROR_FIELD,
                 msgnumb = GR_S_Cdpath,
                 type    = "%s",
                 var     = cd_path );

   return( MSSUCC );

}
