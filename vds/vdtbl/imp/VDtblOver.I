/* $Id: VDtblOver.I,v 1.1.1.1 2001/01/04 21:09:28 cvs Exp $  */
/*--------------------------------------------------------------------------
/* I/VDS
 *
 * File:        vdtbl/imp / VDtblOver.I
 *
 * Description:
 *	Implementation of the following overridden methods  for VDdrwTbl :
 *		GRgetobjinfo
 *		GRdelete
 *
 * Dependencies:
 *
 * History:
 *      
 *	04/14/95	R. Manem	Creation
 *	06/19/95	R. Manem	override GRdelete
 *	07/25/95	R. Manem	Fixed TR on GRdelete
 *	09/06/95	R. Manem	Override GRcopy
 *
 * -------------------------------------------------------------------------
 */

class implementation VDdrwTbl;

/*
#define vdsDEBUG
#define vdserrDEBUG
*/

#include <stdio.h>

#include "v_miscmacros.h"
#include "v_dbgmacros.h"
#include "v_datamacros.h"

#include "vds.h"
#include "emsdef.h"
#include "EMSutlmacros.h"

#include "VDdrwlo.h"
#include "VDdrwtbl.h"

from VDdrwTblRow	import	VDdeleteRow;
from VDdrwTblHdr	import	VDdeleteHdr;

/*+mo
 -------------------------------------------------------------------------
  Overridden Message
        GRgetobjinfo from ACncpx

  Abstract
        Reports information about the object.
        Returns "TABLE"

  Arguments
        IGRlong                 *msg      O     Return code
        struct GRobj_info       *info     O     Object info string

 -------------------------------------------------------------------------
-mo*/

method GRgetobjinfo(	IGRlong			*msg;
			struct GRobj_info	*info )
{
    IGRlong		status = OM_S_SUCCESS;
    
    SetProc( VDdrwTbl.GRgetobjinfo ); Begin

    sprintf( info->type, "%s", "TABLE" );

    End
    *msg = MSSUCC;
    return status;
}

/*+mo
 -------------------------------------------------------------------------
  Overridden Message
        GRdelete from GRgraphics

  Abstract
        Overridden to delete all the rows of the table along with the
        header components

  Arguments
        IGRlong                 *msg      O     completion code
        struct GRmd_env         *md_env   I     structure containing context
                                                info

 -------------------------------------------------------------------------
-mo*/

#define HDR_BUFSIZE	5

method  GRdelete(	IGRlong		*msg;
			struct GRmd_env	*md_env )
{
    IGRint		i,
			nbHdrs = 0;
    struct GRid		*hdrs = NULL,
			ownerId,
			hdrBuf[HDR_BUFSIZE];
    OM_S_CHANSELECT	toRowsChan;
    IGRlong		status = OM_S_SUCCESS;

    SetProc( VDdrwTbl.GRdelete ); Begin
    *msg = MSSUCC;

    /* select to_tblRows */

    status = 
    om$make_chanselect(	channame	= "VDdrwTblHdr.to_tblRows",
			p_chanselect	= &toRowsChan );
    __CheckRC( status, 1, "om$make_chanselect", wrapup );

    /* get the count of headers */

    status =
    _VD_SEND_MY( VDdrwTbl.VDgetTableParts( msg, &nbHdrs, NULL ) );
    __CheckRC( status, *msg, "VDdrwTbl.VDgetTableParts", wrapup );

    __DBGpr_int( "Number of headers", nbHdrs );

    if( nbHdrs > HDR_BUFSIZE )
    {
	hdrs = _MALLOC( nbHdrs, struct GRid );
	if( !hdrs )
	    vd_$mem_fail( sts = status );
    }
    else
	hdrs = hdrBuf;
   
    /* get the header list */

    status =
    _VD_SEND_MY( VDdrwTbl.VDgetTableParts( msg, &nbHdrs, hdrs ) );
    __CheckRC( status, *msg, "VDdrwTbl.VDgetTableParts", wrapup );

    ownerId.objid = my_id;
    ownerId.osnum = OM_Gw_current_OS;

    /* delete individual rows */

    for( i = 0 ; i < nbHdrs ; i++ )
    {
	__DBGpr_obj( "Current header id", hdrs[i] );

	/* delete rows */

	status =
	om$send(	msg		= message VDdrwTblRow.VDdeleteRow(msg),
			senderid	= hdrs[i].objid,
			p_chanselect	= &toRowsChan,
			targetos	= hdrs[i].osnum );
	CheckRC( status, *msg );

	/* first disconnect the header */

        status =
        _VD_SEND_OBJ( hdrs[i], GRconnector.GRdisconn(  msg,
                                                       &ownerId ) );
        CheckRC( status, *msg );

	/* delete the header */

	status =
	_VD_SEND_OBJ( hdrs[i], VDdrwTblHdr.VDdeleteHdr( msg ) );
	CheckRC( status, *msg );
    }

    /* delete myself */

    status =
    om$send(    msg             = message GRowner.GRdelete( msg, md_env ),
                targetid        = my_id,
                mode            = OM_e_wrt_message );
    CheckRC( status, *msg );

wrapup :

    if( hdrs != hdrBuf )
	_FREE( hdrs );
    End
    return status;
}

/*+mo
 -------------------------------------------------------------------------
  Overridden Message
	GRcopy from GRgraphics

  Abstract
	Overridden to prevent copy of table.

  Arguments
	IGRlong		*msg	  	O	Return code
	struct GRmd_env	*obj_dsenv 	I	Object's present env
	struct GRmd_env	*new_dsenv 	I	Object's copy env
	GRobjid		*newobjid	O	objid of copied object

  Return Status
	status  = OM_S_SUCCESS
	*msg	= MSSUCC

  Notes :
	*newobjid is set to NULL_OBJID; A message is displayed in status
	field.

 -------------------------------------------------------------------------
-mo*/

method  GRcopy(	IGRlong			*msg;
		struct GRmd_env		*obj_dsenv;
		struct GRmd_env		*new_dsenv;
		GRobjid			*newobjid )
{
    IGRlong		status = OM_S_SUCCESS;

    SetProc( VDdrwTblRow.GRcopy ); Begin
    *msg = MSSUCC;

    *newobjid = NULL_OBJID;
    UI_status( "Cannot copy table. Reset command" );

    End
    return status;
}

end implementation VDdrwTbl;

