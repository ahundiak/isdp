/* $Id: VDtblInfo.I,v 1.1.1.1 2001/01/04 21:09:28 cvs Exp $  */
/*--------------------------------------------------------------------------
/* I/VDS
 *
 * File:        vdtbl/imp / VDtblInit.I
 *
 * Description:
 *	Implementation of the following methods  for VDdrwTbl :
 *		VDgetTableLayoutName
 *		VDputTableLayoutName
 *		VDgetTableType
 *		VDputTableType
 *		VDgetTableParts
 *		VDgetTotalNbOfRows
 *		VDgetAdsTblName
 *		VDputAdsTblName
 *
 * Dependencies:
 *
 * History:
 *      
 *	04/14/95	R. Manem	Creation
 *	07/10/95	R. Manem	Added ADS methods
 *	07/21/95	R. Manem	Added table type access methods
 *	08/16/95	R. Manem	Initialized nbHdrs to 0
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

#include "emsdef.h"
#include "EMSutlmacros.h"

#include "VDdrwlo.h"
#include "VDdrwtbl.h"

from VDdrwTblHdr	import	VDgetRowInfo,
				VDgetTableInfo;

/*+me
 ---------------------------------------------------------------------------
  Public Message VDgetTableLayoutName

  Abstract
        This method gets the table layout name

  Arguments
        IGRlong         *msg            O       Return code
        IGRchar         *tblLayoutName  O       Table layout name
                                                (bufsize  = VD_DRWLO_CHR_IDFLD )

  Notes/Remarks

  Status/Return Code
      status == OM_S_SUCCESS    if success;
 ---------------------------------------------------------------------------
-me*/

method  VDgetTableLayoutName(   IGRlong         *msg;
                                IGRchar         *tblLayoutName )
{
    IGRlong             status = OM_S_SUCCESS;

    SetProc( VDdrwTbl.VDgetTableLayoutName ); Begin

    *msg = MSSUCC;

    strcpy( tblLayoutName, me->tblLayoutName );

    End
    return status;
}

/*+me
 ---------------------------------------------------------------------------
  Public Message VDputTableLayoutName

  Abstract
        This method puts the table layout name

  Arguments
        IGRlong         *msg            O       Return code
        IGRchar         *tblLayoutName  I       Table layout name
                                                (bufsize  = VD_DRWLO_CHR_IDFLD )

  Notes/Remarks

  Status/Return Code
      status == OM_S_SUCCESS    if success;
 ---------------------------------------------------------------------------
-me*/

method  VDputTableLayoutName(   IGRlong         *msg;
                                IGRchar         *tblLayoutName )
{
    IGRlong		status = OM_S_SUCCESS;

    SetProc( VDdrwTbl.VDputTableLayoutName ); Begin

    *msg = MSSUCC;

    strncpy( me->tblLayoutName, tblLayoutName, VD_DRWLO_CHR_IDFLD );

    __DBGpr_str( "table layout name", me->tblLayoutName );

    End
    return status;
}

/*+me
 ---------------------------------------------------------------------------
  Public Message VDgetTableType

  Abstract
        This method gets the type of the table layout

  Arguments
        IGRlong         *msg            O       Return code
        IGRchar         *tblType        O       Table type
                                                (bufsize  = VD_DRWLO_CHR_IDFLD )

  Notes/Remarks

  Status/Return Code
      status == OM_S_SUCCESS    if success;
 ---------------------------------------------------------------------------
-me*/

method  VDgetTableType( IGRlong         *msg;
                        IGRchar         *tblType )
{
    IGRlong             status = OM_S_SUCCESS;

    SetProc( VDdrwTbl.VDgetTableType ); Begin

    *msg = MSSUCC;

    strcpy( tblType, me->tblType );

    End
    return status;
}

/*+me
 ---------------------------------------------------------------------------
  Public Message VDputTableType

  Abstract
        This method puts the table type

  Arguments
        IGRlong         *msg            O       Return code
        IGRchar         *tblType        I       Table type
                                                (bufsize  = VD_DRWLO_CHR_IDFLD )

  Notes/Remarks

  Status/Return Code
      status == OM_S_SUCCESS    if success;
 ---------------------------------------------------------------------------
-me*/

method  VDputTableType( IGRlong         *msg;
                        IGRchar         *tblType )
{
    IGRlong		status = OM_S_SUCCESS;

    SetProc( VDdrwTbl.VDputTableType ); Begin

    *msg = MSSUCC;

    strncpy( me->tblType, tblType, VD_DRWLO_CHR_IDFLD );

    __DBGpr_str( "table type", me->tblType );

    End
    return status;
}


/*+me
 ---------------------------------------------------------------------------
  Public Message VDgetAdsTblName

  Abstract
        This method gets the attribute driven symbol table name

  Arguments
        IGRlong         *msg            O       Return code
        IGRchar         *adsTblName     O       ADS Table name
                                                (bufsize  = VD_DRWLO_CHR_IDFLD )

  Notes/Remarks

  Status/Return Code
      status == OM_S_SUCCESS    if success;
 ---------------------------------------------------------------------------
-me*/

method  VDgetAdsTblName(        IGRlong         *msg;
                                IGRchar         *adsTblName )
{
    IGRlong		status = OM_S_SUCCESS;

    SetProc( VDdrwTbl.VDgetAdsTblName ); Begin

    *msg = MSSUCC;

    __DBGpr_str( "ads tbl name", me->adsTblName );
    strcpy( adsTblName, me->adsTblName );

    End
    return status;
}

/*+me
 ---------------------------------------------------------------------------
  Public Message VDputAdsTblName

  Abstract
        This method puts the attribute driven symbol table name

  Arguments
        IGRlong         *msg            O       Return code
        IGRchar         *adsTblName     I       ADS Table name
                                                (bufsize  = VD_DRWLO_CHR_IDFLD )

  Notes/Remarks

  Status/Return Code
      status == OM_S_SUCCESS    if success;
 ---------------------------------------------------------------------------
-me*/

method  VDputAdsTblName(        IGRlong         *msg;
                                IGRchar         *adsTblName )

{
    IGRlong		status = OM_S_SUCCESS;

    SetProc( VDdrwTbl.VDputAdsTblName ); Begin

    *msg = MSSUCC;

    strncpy( me->adsTblName, adsTblName, VD_DRWLO_CHR_IDFLD );

    __DBGpr_str( "ADS table name", me->adsTblName );

    End
    return status;
}

/*+me
 ---------------------------------------------------------------------------
  Public Message VDgetTableParts

  Abstract
        This method gets the number/list of parts in this table.

  Arguments
        IGRlong         *msg       O     Return code
        IGRint          *nbParts   O     Nb of parts
        struct GRid     *list      O     List of headers

  Notes/Remarks
        Suppress output for list if NULL
        Memory for list must be allocated by caller.

  Status/Return Code
      status == OM_S_SUCCESS    if success;
 ---------------------------------------------------------------------------
-me*/

method  VDgetTableParts(      	IGRlong         *msg;
                              	IGRint          *nbParts;
				struct GRid	*list )
{
    IGRint		i,
			partNo,
			nbHdrs = 0;
    IGRlong             status = OM_S_SUCCESS;
    struct GRid		hdrId;
    OM_S_CHANSELECT	compChan;
    OM_S_OBJECT_LINKAGE	*myList = NULL;

    SetProc( VDdrwTbl.VDgetTableParts ); Begin

    *msg = MSSUCC;

    /* 
     * validate first : never know if VDdrwTblHdr objects get 
     * deleted somehow
     */

    /* select the components channel */

    status =
    ems$make_chanselect(        chan_label      = GRcmpowner_to_components,
                                chan_selector   = &compChan );
    __CheckRC( status, 1, "make_chanselect", wrapup );

    /* get the count */

    status =
    om$get_channel_count(	objid		= my_id,
				p_chanselect	= &compChan,
				count		= (OMuint *)&nbHdrs );
    CheckRC( status, 1 );

    __DBGpr_int( "No of header objects on channel", nbHdrs );

    *nbParts = nbHdrs;

    if( !nbHdrs )
	goto wrapup;

    /* fill up output list */

    if( list )
    {
	myList = _MALLOC( nbHdrs, OM_S_OBJECT_LINKAGE );
	if( !myList )
	    vd_$mem_fail( sts = status );

	status =
	om$get_channel_objects(	objid		= my_id,
				p_chanselect	= &compChan,
				size		= nbHdrs,
				list		= myList,
				count		= (OMuint *)&nbHdrs );
	CheckRC( status, 1 );
	    
	for( i = 0 ; i < nbHdrs ; i++ )
	{
	    hdrId.objid = myList[i].S_objid;
	    hdrId.osnum = myList[i].osnum;

	    /* get the table header part number */

	    status =	
	    _VD_SEND_OBJ( hdrId, VDdrwTblHdr.VDgetTableInfo(	msg,
								NULL,
								&partNo,
								NULL ) );
	    __CheckRC( status, *msg, "VDdrwTblHdr.VDgetTableInfo", wrapup );

	    __DBGpr_int( "Header part number ", partNo );

	    /* validate partNo limits */

	    if( partNo <= 0 || partNo > nbHdrs )
	    {
		__DBGpr_com( "Header partnumber is invalid");
		status = OM_E_ABORT;
		goto wrapup;
	    }

	    list[partNo-1] = hdrId;
	}
    }

wrapup :

    _FREE( myList );

    End
    return status;
}


/*+me
 ---------------------------------------------------------------------------
  Public Message VDgetTotalNbOfRows

  Abstract
        This method gets the total number of rows in the table

  Arguments
        IGRlong         *msg       O     Return code
        IGRint          *nbRows    O     Total Number of rows

  Notes/Remarks

  Status/Return Code
      status == OM_S_SUCCESS    if success;
 ---------------------------------------------------------------------------
-me*/

method  VDgetTotalNbOfRows( IGRlong    *msg;
                            IGRint     *nbRows )
{
    IGRint		i, nbHdrs = 0,
			hdrRows = 0;
    IGRlong             status = OM_S_SUCCESS;
    OM_S_CHANSELECT	compChan;

    SetProc( VDdrwTbl.VDgetTotalNbOfRows ); Begin

    *msg = MSSUCC;

    /* select the components channel */

    status =
    ems$make_chanselect(        chan_label      = GRcmpowner_to_components,
                                chan_selector   = &compChan );
    __CheckRC( status, 1, "make_chanselect", wrapup );

    status =
    om$get_channel_count(	objid		= my_id,
				p_chanselect	= &compChan,
				count		= (OMuint *)&nbHdrs );
    CheckRC( status, 1 );

    __DBGpr_int( "No of header objects on channel", nbHdrs );

    /* get the number of rows for each header and sum up */

    *nbRows = 0;
    for( i = 0 ; i < nbHdrs ; i++ )
    {
        status =
        om$send( msg		= message VDdrwTblHdr.VDgetRowInfo( msg,
								&hdrRows,
								NULL ),
		p_chanselect	= &compChan,
		from		= i,
		to		= i );

	CheckRC( status, *msg );

        __DBGpr_int( "No of rows", hdrRows );

        if( status & *msg & 1 )
            *nbRows += hdrRows;
    }

    __DBGpr_int( "Total no of rows", *nbRows );

wrapup :
    End
    return status;
}

end implementation VDdrwTbl;

