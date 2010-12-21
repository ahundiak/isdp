/* $Id: VDPenabUtil.I,v 1.1.1.1.2.1 2003/05/27 13:36:50 ahundiak Exp $  */

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
 *      09/02/98        Shailesh        Modified VDPGetEnabledListId for SIR
 *                                      Refer TR # 179801453
 *      09/28/95        MSM             Creation
 */

class implementation VDPenabObj;

/*#define vaimDEBUG
#define vaimerrDEBUG*/


#include <stdio.h>
#include "string.h"

#include "OMmacros.h"
#include "OMprimitives.h"
#include "exproto.h"
#include "exdef.h"
#include "exmacros.h"

#include "v_miscmacros.h"
#include "vadbgmacros.h"
#include "v_datamacros.h"

#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"

#include "VDPdef.h"

/*+fi
  Internal Function VDPGetEnabledListId()

  Abstract
        This returns the Objid of the Enabled List.
	This also creates the object and initialises if not already created.

  Algorithm
	1. Initialise all variables.
        2. Get the Os Name ( File name ) for the OS.
        3. Check if PME_GLOBAL exists.
        4. If it does not exist create it.
        5. Check if List Object exists.
        6. If it is not there Create it and initialise it.
        7. Add it to the directory system.
        8. return the List Object's ID.

  Notes/Remarks
      <Optional>

  Examples
      <Optional>

  Returns
        Successful Return               OM_S_SUCCESS.

* 22 May 2003 - Art Hundiak
* the WhichAim dependency means that this will not work unless someone
* has connected to sir during the current session.  Removed this dependency.

-fi*/

IGRint  VDPGetEnabledListId( IGRlong           *msg,
			     OMuword		osnum,
        	             struct GRid       *pEnabListId )
{
    IGRlong             status = OM_S_SUCCESS;
    struct GRid         DirId;
    IGRchar             DirName[DI_PATH_MAX],
			ListName[DI_PATH_MAX];
    IGRboolean		ListExist = FALSE,
			CreateList = FALSE;
    OMuword             curOs;
    extern GRclassid	OPP_VDPenabObj_class_id;


    SetProc( VDPGetEnabledListId ); Begin
    if( !msg || !pEnabListId ) return OM_E_INVARG;

    *msg = MSSUCC;
    pEnabListId->objid = NULL_OBJID;

    ex$get_cur_mod( osnum = &curOs );

    if ( curOs == osnum )
	CreateList = TRUE;
     
    /* get directory path name */

    status = di$give_pathname(  osnum           = osnum,
                                pathname        = DirName );

    __CheckRC( status, 1, "di$give_pathname", wrapup );
    __DBGpr_str( "Path name", DirName );

    strcat( DirName, SIR_GLOBAL_DIR );

    status =
    di$translate ( objname = DirName,
                   p_objid = &DirId.objid,
                   p_osnum = &DirId.osnum ) ;

    __DBGpr_obj( "Dir Id", DirId );


    /*A create SIR_GLOBAL if it does not exist     */
    if ( status != DIR_S_SUCCESS  && CreateList )
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
    else /*if (CreateList) */
    {
	sprintf( ListName,"%s%s",DirName,SIR_ENABLED_LIST );
	__DBGpr_str( "Enabled List name", ListName );
	
	status =
	di$translate  ( objname = ListName,
			p_objid = &pEnabListId->objid,
			p_osnum = &pEnabListId->osnum ) ;

	__DBGpr_obj( "Enabled List Id", *pEnabListId );

	if( status == DIR_S_SUCCESS )
		ListExist = TRUE;
	else
		ListExist = FALSE;

    }

    /* If List does not exist create the object and add it to NOD */

    if( !ListExist && CreateList )
    {
	pEnabListId->osnum = curOs;

        status =
        om$construct (  classid = OPP_VDPenabObj_class_id,
                        p_objid = &(pEnabListId->objid),
                        osnum   = pEnabListId->osnum,
                        msg = message VDPenabObj.VDPinit( msg) );
	__CheckRC( status, *msg,"om$construct", wrapup );
	__DBGpr_obj ( "List Id ", *pEnabListId );

	sprintf( ListName,"%s%s",DirName,SIR_ENABLED_LIST );
	__DBGpr_str( "Enabled List name", ListName );
	status =
	di$add_name ( objname = ListName,
		      osnum   = pEnabListId->osnum,
		      objid   = pEnabListId->objid );
        __CheckRC( status, 1, "di$add_name", wrapup );
    }


wrapup :

    End
    return status;
}

/*+fe
  External function  VDPenableObject

  Abstract
     This function adds a VDS object to the enabled list.

  Algortithm
     1. Get the List OBJID.
     2. Verify if the Object already exists in the list.
     3. If it does not add it to the list.
     4. Return.

  Notes/Remarks

  Return Values
     status = OM_S_SUCCESS
-fe*/

IGRint	VDPEnableObject( IGRlong	*msg,
			 struct GRid		VdsObj )
{
    IGRlong             status = OM_S_SUCCESS;
    struct GRid         EnabListId;
    IGRboolean		bFlag=FALSE;
    OMuword		curOs;

    SetProc( VDPEnableObject ); Begin
    if( !msg ) return OM_E_INVARG;

    *msg = MSSUCC;

    __DBGpr_obj ( "Object to be enabled", VdsObj ); 
    ex$get_cur_mod( osnum = &curOs );
    __DBGpr_int ( "Current OS:", curOs );
    if( VdsObj.osnum != curOs )
    {
	UI_status ( "Cannot enable objects in reference file");
	status = OM_E_ABORT;
	goto wrapup;
    }
	
    EnabListId.objid = NULL_OBJID;

    status = VDPGetEnabledListId ( msg, curOs, &EnabListId );
    __CheckRC ( status, *msg, "VDPGetEnabledListId", wrapup );
    __DBGpr_obj( "Enabled List Id", EnabListId );

    status =
    _VD_SEND_OBJN( EnabListId, VDPenabObj.VDPIsObjEnabled (
							msg,
							VdsObj.objid,
							&bFlag ));
    __CheckRC( status, *msg, "IsObjEnabled", wrapup );

    if( bFlag == FALSE )
    {
	status =
	_VD_SEND_OBJN( EnabListId, VDPenabObj.VDPEnableObject( 
							msg,
							VdsObj.objid ));
	__CheckRC( status, *msg, "EnableObject", wrapup );
    }
	
wrapup :
    End
    return status;
}

IGRint	VDPDisableObject( IGRlong	*msg,
			  struct GRid	VdsObj )
{
    IGRlong             status = OM_S_SUCCESS;
    struct GRid         EnabListId;
    IGRboolean		bFlag=FALSE;
    OMuword		curOs;

    SetProc( VDPDisableObject ); Begin
    if( !msg ) return OM_E_INVARG;

    *msg = MSSUCC;

    __DBGpr_obj ( "Object to be disabled", VdsObj ); 
    ex$get_cur_mod( osnum = &curOs );
    __DBGpr_int ( "Current OS:", curOs );
    if( VdsObj.osnum != curOs )
    {
	status = OM_E_ABORT;
	goto wrapup;
    }
    EnabListId.objid = NULL_OBJID;

    status = VDPGetEnabledListId ( msg, curOs, &EnabListId );
    __CheckRC ( status, *msg, "VDPGetEnabledListId", wrapup );
    __DBGpr_obj( "Enabled List Id", EnabListId );

    status =
    _VD_SEND_OBJN( EnabListId, VDPenabObj.VDPDisableObject( 
							msg,
							VdsObj.objid ));
    __CheckRC( status, *msg, "DisableObject", wrapup );

wrapup :
    End
    return status;
}

end implementation VDPenabObj;
