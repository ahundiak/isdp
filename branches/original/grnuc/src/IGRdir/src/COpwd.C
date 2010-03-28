/* #######################    APOGEE COMPILED   ######################## */
/*
 ------------------------------------------------------------------------------

  Module:  CO_ni_pwd()

  Abstract:

     This function shows the default directory using a form interface.

  Example:  status = CO_ni_pwd( ReturnMsg,
                                Events );

  Arguments:

     *ReturnMsg     IGRlong         Return message:
                                       MSSUCC - success
                                       MSFAIL - failure

     *Events        struct GRevent  Pointer to event containing the string
                                    describing the default directory.

  History:   jsd   06/27/88   - created
	     hgb   28/12/88   - suppress the creation of the super

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

#argsused
IGRlong CO_ni_pwd( ReturnMsg,
                   Events )

    IGRlong            *ReturnMsg;    /* return information code */
    struct GRevent     *Events[];     /* default directory       */

{
    IGRchar pwd[DI_PATH_MAX];

    _m_debug_str( ">  CO_ni_pwd()" );
    *ReturnMsg = MSSUCC;

    di$pwd( dirname = pwd );

    ex$message ( field   = ERROR_FIELD,
                 msgnumb = GR_S_Pwd,
                 type    = "%s",
                 var     = pwd );

   _m_debug_str( "< CO_ni_pwd" );
   return ( MSSUCC );
}
