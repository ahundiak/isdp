/* ----------------------------------------------------------------------------
 * I/VDS
 *
 * File :       vds/vdpzone/imp/VDPZnFunc.I
 *
 * Description:
 *      Implementation of the following functions
 *
 * Dependencies:
 *
 * History:
 *
 *      12/19/95        MSM             Creation
 *
 * --------------------------------------------------------------------------*/

class implementation Root;

/*
#define vdsDEBUG
#define vdserrDEBUG
*/

#include <stdio.h>
#include <string.h>

#include "OMmacros.h"
#include "OMprimitives.h"
#include "exproto.h"
#include "exdef.h"
#include "exmacros.h"
#include "grmacros.h"
#include "dpmacros.h"
#include "griomacros.h"

#include "v_miscmacros.h"
#include "v_dbgmacros.h"
#include "v_datamacros.h"

#include "VDPdef.h"
#include "VDPzone.h"

#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"

from VDPZnMgr import 	VDPinit;


/*+fi
    Internal Function VDPGetZoneListId()

    Abstract
	This returns the Objid of the Zone List

    Algorithm

    Notes/Remarks

    Returns
	status = OM_S_SUCCESS		Successful Return

-fi*/

IGRint	VDPGetZoneListId( IGRlong	*msg,
			  struct GRid	*pZoneListId )
{
    IGRlong		status = OM_S_SUCCESS;
    struct GRid		DirId;
    IGRchar             DirName[DI_PATH_MAX],
                        ListName[DI_PATH_MAX];
    IGRboolean		ListExist=FALSE;
    OMuword		curOs;
    extern GRclassid	OPP_VDPZnMgr_class_id;

    SetProc ( VDPGetZoneListId ); Begin
    if (!msg || !pZoneListId ) return OM_E_INVARG;

    *msg = MSSUCC;
    pZoneListId->objid = NULL_OBJID;

    ex$get_cur_mod(osnum = &curOs );

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
        sprintf( ListName,"%s%s",DirName,PME_ZONE_LIST );
        __DBGpr_str( "Zone List name", ListName );

        status =
        di$translate  ( objname = ListName,
                        p_objid = &pZoneListId->objid,
                        p_osnum = &pZoneListId->osnum ) ;

        __DBGpr_obj( "Zone List Id", *pZoneListId );

        if( status == DIR_S_SUCCESS )
                ListExist = TRUE;
        else
                ListExist = FALSE;
    }

    /* If the object does not exist create the object and add it to the 
     * directory subsystem 						*/

    if (!ListExist )
    {
	pZoneListId->osnum = curOs;

	status =
	om$construct (  classid = OPP_VDPZnMgr_class_id,
			p_objid = &(pZoneListId->objid),
			osnum = pZoneListId->osnum,
			msg = message VDPZnMgr.VDPinit( msg ));

	__CheckRC( status, *msg,"om$construct", wrapup );
	__DBGpr_obj ( "List Id ", *pZoneListId );

	sprintf( ListName,"%s%s",DirName,PME_ZONE_LIST );
	__DBGpr_str( "Zone List name", ListName );
	status =
	di$add_name ( objname = ListName,
		      osnum   = pZoneListId->osnum,
		      objid   = pZoneListId->objid );
	__CheckRC( status, 1, "di$add_name", wrapup );
    }

wrapup :

    End
    return status;
}

end implementation Root;
