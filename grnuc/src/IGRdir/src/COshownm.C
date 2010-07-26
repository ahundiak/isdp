/* #######################    APOGEE COMPILED   ######################## */
/*
 ------------------------------------------------------------------------------

  Module:  CO_ni_shownm()

  Abstract:

     This function shows the name of the located element.

  Example:  status = CO_ni_shownm( ReturnMsg,
                                   Events );

  Arguments:

     *ReturnMsg     IGRlong         Return message:
                                       MSSUCC - success
                                       MSFAIL - failure

     *Events        struct GRevent  Pointer to event containing the string
                                    describing the located element.

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

extern IGRint GR_G_dir_mode;

#define obj Events[0]->located_object[0].located_obj.objid
#define os  Events[0]->located_object[0].located_obj.osnum


IGRlong CO_ni_shownm( ReturnMsg,
                      Events )

    IGRlong            *ReturnMsg;    /* return information code     */
    struct GRevent     *Events[];     /* element whose name is shown */

{

    IGRchar name     [DI_PATH_MAX];

    /* EV -- end local varaibles */

    _m_debug_str( ">  CO_ni_shownm()" );
    *ReturnMsg = MSSUCC;

    *ReturnMsg = di$untranslate ( objname = name, objid = obj, osnum = os );

    if ( *ReturnMsg == DIR_S_SUCCESS )
    {
        ex$message ( field   = ERROR_FIELD,
	             msgnumb = GR_S_Showname,
	             type    = "%s",
	             var     = name );
    }

    _m_checkp( *ReturnMsg,
                "CO_ni_shownm : di$shownm FAILED" );
    _m_checkq( *ReturnMsg );


quit:
   _m_debug_str( "< CO_ni_shownm" );
   return( ( *ReturnMsg & 1 ) ? MSSUCC : MSFAIL );

}
