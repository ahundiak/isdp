/* $Id */

/* I/Vds
 *
 *
 * File:        vdpzone/imp/VDPZnMgri.I
 *
 * Description:
 *      Implementation of the following methods for VDPZnMgr
 *
 * Dependencies:
 *
 * History:
 *
 *      12/19/95        MSM        Creation
 *
 */

class implementation VDPZnMgr;

/*
#define vdsDEBUG
#define vdserrDEBUG
*/

#include <stdio.h>

#include "OMmacros.h"
#include "OMprimitives.h"
#include "exproto.h"
#include "exdef.h"
#include "exmacros.h"

#include "godef.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"

#include "v_miscmacros.h"
#include "v_dbgmacros.h"
#include "v_datamacros.h"

#include "VDPdef.h"
#include "VDPzone.h"

from VDPZoneObj import VDPGetInstance;

/*+me
    Public Message VDPinit

    Abstract
	This message initialises the Zone Object.

    Algorithm

    Arguments
	IGRlong		*msg		I/O	return message
						MSSUCC/MSFAIL

    Notes/Remarks

    Examples

    Status/Return Code
	status = OM_S_SUCCESS	if success;
		 OM_E_xxx	 if error
-me*/

method VDPinit ( IGRlong *msg )
{
    IGRlong		status = OM_S_SUCCESS;

    SetProc( VDPZnMgr.VDPinit ); Begin
    if( !msg )
	return OM_E_INVARG;

    *msg = MSSUCC;

    /* For later */
    /* status = _VD_SEND_MY( VDPZnMgr.VDPqueryZoneList( msg )); */
    CheckRC ( status, *msg );

    End
    return status;
}

/*+me
    Public Message VDPgetZoneList

    Abstract
	This message returns a list of all the zones.

    Algorithm

    Arguments
	IGRlong		*msg		O	return message
						MSSUCC/MSFAIL
	IGRint		*nbZones	0	number of Zones
	struct VDPzone	**ZoneObjs	O	structure of all Zone Objects

    Notes/Remarks

    Examples

    Status/Return Code
	status = OM_S_SUCCESS	if success;
		 OM_E_xxx	 if error
-me*/

method	VDPgetZoneList ( IGRlong		*msg;
			 IGRint			*nbZones;
			 struct VDPzone		**ZoneObjs )
{
    IGRlong		status = OM_S_SUCCESS;
    IGRint		i;
    OMuint		count;
    OM_S_OBJECT_LINKAGE	*Zones = NULL;
    OM_S_CHANSELECT	to_components;

    SetProc (VDPZnMgr.VDPgetZoneList ); Begin
    if( !msg )
	return OM_E_INVARG;

    *msg = MSSUCC;

    /* Get the number of Zones on the components channel */

    status = om$make_chanselect( channame 	= "GRcmpowner.to_components",
                                 p_chanselect 	= &to_components );
    CheckRC ( status, 1 );

    status = om$get_channel_count( objid	= my_id,
				   osnum	= OM_Gw_current_OS,
				   p_chanselect = &to_components,
				   count	= &count );
    CheckRC ( status, 1 );

    if ( count )
	Zones = _MALLOC ( count, OM_S_OBJECT_LINKAGE  );
    __DBGpr_int("Size of array ", count );

    status = om$get_channel_objects( objid	= my_id,
				     osnum	= OM_Gw_current_OS,
				     p_chanselect = &to_components,
				     list	= Zones,
				     size	= count,
				     count	= &count );
				     
    CheckRC ( status, 1 );

    *nbZones = count;
    if( *nbZones )
    {
	*ZoneObjs = _MALLOC ( *nbZones, struct VDPzone );
	if (! *ZoneObjs )
	{
	    UI_status("Error in dynamic allocation of memory" );
	    goto wrapup;
	}
    }
    for ( i = 0; i < *nbZones; i++ )
    {
	(*ZoneObjs)[i].ZoneId.objid = NULL_OBJID;

	status = om$send ( msg = message VDPZoneObj.VDPGetInstance (
						msg,
						&(*ZoneObjs)[i] ),
			   targetid = Zones[i].S_objid,
			   targetos = Zones[i].osnum );

	CheckRC ( status, *msg );
    }

wrapup:
    End
    return status;
}

/*+me
    Public Message VDPqueryZoneList

    Abstract
	This message queries the Database for all the Zones.

    Algorithm

    Arguments
	IGRlong		*msg		O	return message
						MSSUCC/MSFAIL
    Status/Return Code
	status = OM_S_SUCCESS	if success;
		 OM_E_xxx	 if error
*/

method VDPqueryZoneList ( IGRlong  *msg )
{
    IGRlong		status = OM_S_SUCCESS;
    struct VDPzone	*ZoneList=NULL;
    IGRchar		FileId[VDPOBID_LEN]="";
    IGRint		nbZones=0;
    OMuword		curOs;

    SetProc (VDPZnMgr.VDPqueryZoneList ); Begin

    *msg = MSSUCC;

    ex$get_cur_mod(osnum = &curOs );

    /* Get the File Id */
    status = VDPGetFileId(msg, curOs, FileId );
    __DBGpr_str( "File Id ", FileId );
    CheckRC ( status, 1 );

    /* Get the List of Zones for this file and a list of Free Zones */

    status = VDPqueryListofZones ( msg, FileId, &nbZones, &ZoneList );

    __CheckRC ( status, *msg, "VDPqueryListofZones", wrapup );

    __DBGpr_int ("Number of Zones ", nbZones );
/* 
 *  Right now I am not doing anything. But in future the zones should be
 *  queried from the DB and be set in the design file.
 */

/*
 *   status = om$vla_set_dimension ( varray = me->ZoneObjs, size = nbZones );
 *
 *  CheckRC ( status, 1 );
 *
 */

wrapup:
    _FREE( ZoneList );
    End
    return status;
}

end implementation VDPZnMgr;
