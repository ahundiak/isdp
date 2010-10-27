/* $Id: VDPpmrUtil.I,v 1.1.1.1 2001/01/04 21:09:04 cvs Exp $  */

/* I/VDS
 *
 * File:       vdpenable/imp/VDPenabUtil.I
 *
 * Description:
 *
 * Dependencies:
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *      -------------------------------------------
 *      09/28/95        MSM             Creation
 */

class implementation VDPpmrWpkg;

/*
#define vdsDEBUG
#define vdserrDEBUG
*/

#include <stdio.h>
#include "string.h"

#include "OMmacros.h"
#include "OMprimitives.h"
#include "exproto.h"
#include "exdef.h"
#include "exmacros.h"

#include "v_miscmacros.h"
#include "v_dbgmacros.h"
#include "v_datamacros.h"

#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"

#include "VDPdef.h"

/*+fi
  Internal Function VDPGetWrkPkgId()

  Abstract
        This returns the Objid of the work package.
	This also creates the object and initialises if not already created.

  Notes/Remarks
      <Optional>

  Examples
      <Optional>

  Returns
        Successful Return               OM_S_SUCCESS.

-fi*/

IGRint  VDPGetWrkPkgId( IGRlong           *msg,
        	        struct GRid       *pWrkPkgId )
{
    IGRlong             status = OM_S_SUCCESS;
    struct GRid         DirId;
    IGRchar             DirName[DI_PATH_MAX],
			ListName[DI_PATH_MAX];
    IGRboolean		ListExist = FALSE;
    OMuword             curOs;
    extern GRclassid	OPP_VDPpmrWpkg_class_id;


    SetProc( VDPGetWrkPkgId ); Begin
    if( !msg || !pWrkPkgId ) return OM_E_INVARG;

    *msg = MSSUCC;
    pWrkPkgId->objid = NULL_OBJID;

    ex$get_cur_mod( osnum = &curOs );

    /* get directory path name */

    status = di$give_pathname(  osnum           = curOs,
                                pathname        = DirName );

    __CheckRC( status, 1, "di$give_pathname", wrapup );
    __DBGpr_str( "Path name", DirName );

    strcat( DirName, PME_GLOBAL_DIR );

    status =
    di$translate ( objname = DirName,
                   p_objid = &DirId.objid,
                   p_osnum = &DirId.osnum ) ;

    __DBGpr_obj( "Dir Id", DirId );

    /*A create PME_GLOBAL if it does not exist     */
    if ( status != DIR_S_SUCCESS )
    {
	DirId.objid = NULL_OBJID;

	status =
	di$mkdir( dirname = DirName,
		  p_dirid = &DirId.objid,
		  p_osnum = &DirId.osnum );

        __DBGpr_obj( "Dir Id", DirId );

         if( status != DIR_S_SUCCESS )
        {
                  /*A Cannot create directory*/
                  di$report_error( sts = status ) ;
                  goto    wrapup;
	}
    }
    else
    {
	sprintf( ListName,"%s%s",DirName,PME_WRKPKG );
	__DBGpr_str( "Work Package Name", ListName );
	
	status =
	di$translate  ( objname = ListName,
			p_objid = &pWrkPkgId->objid,
			p_osnum = &pWrkPkgId->osnum ) ;

	__DBGpr_obj( "Work Package Id", *pWrkPkgId );

	if( status == DIR_S_SUCCESS )
		ListExist = TRUE;
	else
		ListExist = FALSE;

    }

    /* If List does not exist create the object and add it to NOD */

    if( !ListExist )
    {
	pWrkPkgId->osnum = curOs;

        status =
        om$construct (  classid = OPP_VDPpmrWpkg_class_id,
                        p_objid = &(pWrkPkgId->objid),
                        osnum   = pWrkPkgId->osnum,
                        msg = message VDPpmrWpkg.VDPinit( msg) );
	__CheckRC( status, *msg,"om$construct", wrapup );
	__DBGpr_obj ( "List Id ", *pWrkPkgId );

	sprintf( ListName,"%s%s",DirName,PME_WRKPKG );
	__DBGpr_str( "Work Package name", ListName );
	status =
	di$add_name ( objname = ListName,
		      osnum   = pWrkPkgId->osnum,
		      objid   = pWrkPkgId->objid );
        __CheckRC( status, 1, "di$add_name", wrapup );
    }

wrapup :

    End
    return status;
}

end implementation VDPpmrWpkg;
