/* #######################    APOGEE COMPILED   ######################## */
/*
 ------------------------------------------------------------------------------

  Module:  CO_ni_cd()

  Abstract:

     This function changes the specified directory to the default directory.
   A call to di$cd is made to change the default directory and then a call
   to di$pwd is made to display the modification.

  Example:  status = CO_ni_cd( ReturnMsg,
                               Events );

  Arguments:

     *ReturnMsg     IGRlong         Return message:
                                       MSSUCC - success
                                       MSFAIL - failure

     *Events        struct GRevent  Pointer to event containing the string
                                    describing the new default directory.

  History:   jsd   06/27/88   - created
  History:   jsd   09/26/89   - removed special check for '~'

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

extern IGRint GR_G_dir_mode;

#define one  Events[0]->event.keyin
#define sub  Events[0]->subtype

IGRlong CO_ni_cd( ReturnMsg,
                  Events )

    IGRlong            *ReturnMsg;    /* return information code      */
    struct GRevent     *Events[];     /* pointer to new default dir   */

{

    IGRchar    dir[DI_PATH_MAX];

    /* EV -- end local varaibles */


    *ReturnMsg = MSSUCC;

    if ( sub == GRst_DEFAULT )
    {
	DIstrcpy ( dir, "~" );
    }
    else
    {
	DIstrcpy ( dir, one );
    }

    *ReturnMsg = di$cd ( dirname = dir, path = DIR_G_cdpath );

    if ( *ReturnMsg == DIR_S_SUCCESS )
    {
	di$update_dir_form();
	di$pwd ( dirname = dir );

        ex$message ( field   = ERROR_FIELD,
	             msgnumb = GR_S_Pwd,
	             type    = "%s",
	             var     = dir );
    }

   return ( ( *ReturnMsg & 1 ) ? MSSUCC : MSFAIL );
}
