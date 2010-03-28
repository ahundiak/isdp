/* #######################    APOGEE COMPILED   ######################## */
/*
 ------------------------------------------------------------------------------

  Module:  CO_ni_mkdir()

  Abstract:

     This function creates a new directory that has the specified name.

  Example:  status = CO_ni_mkdir( ReturnMsg,
                                  Events );

  Arguments:

     *ReturnMsg     IGRlong         Return message:
                                       MSSUCC - success
                                       MSFAIL - failure

     *Events        struct GRevent  Pointer to event containing the string
                                    describing the directory to create.

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

IGRlong CO_ni_mkdir( ReturnMsg,
                     Events )

   IGRlong            *ReturnMsg;    /* return information code          */
   struct GRevent     *Events[];     /* pointer to dir/part(s) to create */

{
    _m_debug_str( ">  CO_ni_mkdir()" );
    *ReturnMsg = MSSUCC;

   *ReturnMsg = di$mkdir( dirname = name );

   if ( *ReturnMsg == DIR_S_SUCCESS )
   {
      di$update_dir_form();
      ex$message ( field   = ERROR_FIELD,
                   msgnumb = GR_S_Mkdir,
                   type    = "%s",
                   var     = name );
   }

   _m_debug_str( "< CO_ni_mkdir" );
   return ( ( *ReturnMsg & 1 ) ? MSSUCC : MSFAIL );
}
