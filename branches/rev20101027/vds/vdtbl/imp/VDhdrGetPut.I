/* $Id: VDhdrGetPut.I,v 1.2 2002/04/04 21:00:48 ylong Exp $  */
/*--------------------------------------------------------------------------
/* I/VDS
 *
 * File:        vdtbl/imp / VDhdrUpd.I
 *
 * Description:
 *	Implementation of the following methods  for VDdrwTblHdr :
 *		VDgetRowInfo
 *		VDputStartRowNo
 *		VDgetConstructInfo
 *		VDputConstructInfo
 *		VDgetCsLocation
 *		VDputCsLocation
 *		VDgetTableInfo
 *		VDputTableInfo
 *		VDgetCornerPointForRow
 *		VDgetRowConstructInfo
 *		VDrowNoToId
 *		VDgetRowHeight
 *
 * Dependencies:
 *
 * History:
 *      
 *	04/14/95	R. Manem	Creation
 *	05/15/95	R. Manem	Added VDrowNoToGRid method
 *	07/14/95	R. Manem	Added adsTblName argument for 
 *					VDgetRowConstructInfo method
 *
 * -------------------------------------------------------------------------
 */

class implementation VDdrwTblHdr;

/*
#define vdsDEBUG
#define vdserrDEBUG
*/

#include <stdio.h>

#include "OMmacros.h"
#include "OMprimitives.h"

#include "v_miscmacros.h"
#include "v_dbgmacros.h"
#include "v_datamacros.h"

#include "vds.h"
#include "emsdef.h"
#include "EMSutlmacros.h"

#include "VDdrwlo.h"
#include "VDdrwtbl.h"

from VDdrwTbl		import	VDgetAdsTblName;
from VDdrwTblRow	import	VDgetRowNumber;

/*+me
 ---------------------------------------------------------------------------
  Public Message VDgetRowInfo

  Abstract
        This method gets the row information : number of rows and starting row
        number

  Arguments
        IGRlong         *msg            O       Return code
        IGRint          *nbRows         O       number of rows
        IGRint          *startRowNo     O       Starting row number

  Notes/Remarks

  Status/Return Code
      status == OM_S_SUCCESS    if success;
 ---------------------------------------------------------------------------
-me*/

method  VDgetRowInfo(   IGRlong         *msg;
                        IGRint  	*nbRows;
                        IGRint  	*startRowNo )
{
    IGRlong             status = OM_S_SUCCESS;

    SetProc( VDdrwTblHdr.VDgetRowInfo ); Begin

    *msg = MSSUCC;

    if( nbRows )
        *nbRows = om$dimension_of( varray = me->rowHeights ) - 2;

    if( startRowNo )
        *startRowNo = me->startRowNo;

    End
    return status;
}


/*+me
 ---------------------------------------------------------------------------
  Public Message VDputStartRowNo

  Abstract
        This method puts the starting row number 

  Arguments
        IGRlong         *msg            O       Return code
        IGRint          startRowNo      I       Starting row number

  Notes/Remarks

  Status/Return Code
      status == OM_S_SUCCESS    if success;
 ---------------------------------------------------------------------------
-me*/

method  VDputStartRowNo(   	IGRlong         *msg;
                        	IGRint          startRowNo )
{
    IGRlong             status = OM_S_SUCCESS;

    SetProc( VDdrwTblHdr.VDputRowInfo ); Begin

    *msg = MSSUCC;

    me->startRowNo = startRowNo;

    End
    return status;
}


/*+me
 ---------------------------------------------------------------------------
  Public Message VDgetConstructInfo

  Abstract
        This method gets the construction information :
        header type, trailer type and the toConstructType

  Arguments
        IGRlong         *msg             O       Return code
        IGRshort        *headerType      O       type of header
        IGRshort        *trailerType     O       type of trailer
        IGRshort        *toConstructType O       what to construct

  Notes/Remarks

  Status/Return Code
      status == OM_S_SUCCESS    if success;
 ---------------------------------------------------------------------------
-me*/

method  VDgetConstructInfo(     IGRlong         *msg;
                                IGRshort        *headerType;
                                IGRshort        *trailerType;
                                IGRshort        *toConstructType )
{
    IGRlong             status = OM_S_SUCCESS;

    SetProc( VDdrwTblHdr.VDgetConstructInfo ); Begin

    *msg = MSSUCC;

    if( headerType )
        *headerType = me->headerType;

    if( trailerType )
        *trailerType = me->trailerType;

    if( toConstructType )
        *toConstructType = me->toConstructType;

    End
    return status;
}


/*+me
 ---------------------------------------------------------------------------
  Public Message VDputConstructInfo

  Abstract
        This method puts the construction information :
        header type, trailer type and the toConstructType

  Arguments
        IGRlong         *msg             O       Return code
        IGRshort        *headerType      I       type of header
        IGRshort        *trailerType     I       type of trailer
        IGRshort        *toConstructType I       what to construct

  Notes/Remarks
        Don't put if NULL input

  Status/Return Code
      status == OM_S_SUCCESS    if success;
 ---------------------------------------------------------------------------
-me*/

method  VDputConstructInfo(     IGRlong         *msg;
                                IGRshort        *headerType;
                                IGRshort        *trailerType;
                                IGRshort        *toConstructType )
{
    IGRlong             status = OM_S_SUCCESS;

    SetProc( VDdrwTblHdr.VDputConstructInfo ); Begin

    *msg = MSSUCC;

    if( headerType )
        me->headerType = *headerType;

    if( trailerType )
        me->trailerType = *trailerType;

    if( toConstructType )
        me->toConstructType = *toConstructType;

    End
    return status;
}

/*+me
 ---------------------------------------------------------------------------
  Public Message VDgetCsLocation

  Abstract
        This method gets the location of the coordinate system
        (VD_DRW_CS_LOC_LEFT or VD_DRW_CS_LOC_RIGHT)

  Arguments
        IGRlong         *msg             O       Return code
        IGRshort        *csLoc           O       CS location

  Notes/Remarks

  Status/Return Code
      status == OM_S_SUCCESS    if success;
 ---------------------------------------------------------------------------
-me*/

method  VDgetCsLocation(     IGRlong             *msg;
                             IGRshort            *csLoc )
{
    IGRlong             status = OM_S_SUCCESS;

    SetProc( VDdrwTblHdr.VDgetCsLocation ); Begin

    *msg = MSSUCC;

    *csLoc = me->csLocation;

    End
    return status;
}


/*+me
 ---------------------------------------------------------------------------
  Public Message VDputCsLocation

  Abstract
        This method puts the location of the coordinate system in the instance
        (VD_DRW_CS_LOC_LEFT or VD_DRW_CS_LOC_RIGHT)

  Arguments
        IGRlong         *msg             O       Return code
        IGRshort        csLoc            I       CS location

  Notes/Remarks

  Status/Return Code
      status == OM_S_SUCCESS    if success;
 ---------------------------------------------------------------------------
-me*/

method  VDputCsLocation( IGRlong             *msg;
                         IGRshort            csLoc )
{
    IGRlong             status = OM_S_SUCCESS;

    SetProc( VDdrwTblHdr.VDputCsLocation ); Begin

    *msg = MSSUCC;

    me->csLocation = csLoc;

    End
    return status;
}


/*+me
 ---------------------------------------------------------------------------
  Public Message VDgetTableInfo

  Abstract
        This method gets the table information :
        table format name, table part number and table orientation

  Arguments
        IGRlong         *msg             O       Return code
        IGRchar         *tblLoName       O       table layout name
                                                 (size = VD_DRWLO_CHR_IDFLD)
        IGRint          *tblPartNo       O       Part number of the table
        IGRshort        *tblOrient       O       table orientation

  Notes/Remarks
        Suppress output if NULL

  Status/Return Code
      status == OM_S_SUCCESS    if success;
 ---------------------------------------------------------------------------
-me*/


method  VDgetTableInfo(     IGRlong             *msg;
                            IGRchar             *tblLoName;
                            IGRint              *tblPartNo;
                            IGRshort            *tblOrient )
{
    IGRlong             status = OM_S_SUCCESS;

    SetProc( VDdrwTblHdr.VDgetTableInfo ); Begin

    *msg = MSSUCC;

    if( tblLoName )
        strcpy( tblLoName, me->tblLayoutName );

    if( tblPartNo )
        *tblPartNo = me->tblPartNo;

    if( tblOrient )
        *tblOrient = me->tblOrient;

    End
    return status;
}


/*+me
 ---------------------------------------------------------------------------
  Public Message VDputTableInfo

  Abstract
        This method puts the table information :
        table format name, table part number and table orientation

  Arguments
        IGRlong         *msg             O       Return code
        IGRchar         *tblLoName       I       table layout name
        IGRint          *tblPartNo       I       Part number of the table
        IGRshort        *tblOrient       I       table orientation

  Notes/Remarks
        Suppress change if NULL


  Status/Return Code
      status == OM_S_SUCCESS    if success;
 ---------------------------------------------------------------------------
-me*/

method  VDputTableInfo(     IGRlong             *msg;
                            IGRchar             *tblLoName;
                            IGRint              *tblPartNo;
                            IGRshort            *tblOrient )
{
    IGRlong             status = OM_S_SUCCESS;

    SetProc( VDdrwTblHdr.VDputTableInfo ); Begin

    *msg = MSSUCC;

    if( tblLoName )
        strncpy( me->tblLayoutName, tblLoName, VD_DRWLO_CHR_IDFLD );

    if( tblPartNo )
        me->tblPartNo = *tblPartNo;

    if( tblOrient )
        me->tblOrient = *tblOrient;

    End
    return status;
}


/*+me
 ---------------------------------------------------------------------------
  Public Message VDgetCornerPointForRow

  Abstract
        This method gets the corner point for a given row.  It is the Header
        corner point offset by the sum of all previous row heights.


  Arguments
        IGRlong         *msg            O       Return code
        IGRint          rowNo           I       Input Row number
        IGRdouble       *cornerPoint    O       Corner point for row

  Notes/Remarks
	If the number of data rows in the table header is 10, and the start
	row number is 5, then the valid values for rowNo are 0,5,6...,14,15.  
	(0 for header, 15 for the new row or trailer, 5 - 14 for existing rows).
	vla dimension is 12 (10rows + header + trailer).

	Refer to spec file more details.
	-----

  Status/Return Code
      status == OM_S_SUCCESS    if success;
      		OM_E_ABORT	if rowNo exceeds limits
 ---------------------------------------------------------------------------
-me*/

method  VDgetCornerPointForRow( IGRlong         *msg;
                                IGRint          rowNo;
                                IGRdouble       *cornerPoint )
{
    IGRint		i,
			nbRows = 0,
			vlaSize = 0;
    IGRlong             status = OM_S_SUCCESS;
    IGRdouble		totalHeight = 0.0;

    SetProc( VDdrwTblHdr.VDgetCornerPointForRow ); Begin

    *msg = MSSUCC;

    /* get the rowHeights dimension */

    vlaSize = om$dimension_of( varray	= me->rowHeights );

    nbRows = vlaSize - 2;

    __DBGpr_int( "rowNo ", rowNo );
    __DBGpr_int( "nbRows ", nbRows );
    
    if( rowNo == 0 )
        totalHeight = 0;
    else if( rowNo <= (nbRows + me->startRowNo) && rowNo >= me->startRowNo )
    {
        for( i = 0 ; i < (rowNo - me->startRowNo + 1) ; i++ )
            totalHeight += me->rowHeights[i];
    }
    else
    {
        __DBGpr_com( "rowNo is out of range : aborting" );
        status = OM_W_ABORT;
        *msg = MSFAIL;
        goto wrapup;
    }

    __DBGpr_dbl( "totalHeight", totalHeight );

    /* 
     * compute the corner point : 
     *		y coordinate increases for bottom-up orientation (ASCEND)
     *			     decreases for top-down orientation  (DESCEND)
     * Also for ASCEND, header corner point is on line with cs and does not
     *					include the height of the header
     * But for DESCEND, header corner point is below the cs displaced by the
     *					header height
     */

    for( i = 0 ; i < 3 ; i++ )
        cornerPoint[i] = me->headerCornerPoint[i];

    if( me->tblOrient == VD_DRWLO_EN_DESCEND )
        cornerPoint[1] = cornerPoint[1] - totalHeight + me->rowHeights[0];
    else
        cornerPoint[1] += totalHeight;

    __DBGpr_vec( "corner point", cornerPoint );

wrapup :
    End
    return status;
}


/*+me
 ---------------------------------------------------------------------------
  Public Message VDgetRowConstructInfo

  Abstract
        This method gets the row construction information :
        table format name, table orientation, coordinate system, 
        previous row's corner point and attribute driven symbol name.

  Arguments
        IGRlong         *msg             O       Return code
        IGRint          rowNo            I       Row number to construct
        IGRchar         *tblLoName       O       table layout name
                                                 (size = VD_DRWLO_CHR_IDFLD)
        IGRshort        *tblOrient       O       table orientation
        struct GRid     csId             O       Coordinate system id
        IGRdouble       *cornerPoint     O       row's corner point
        IGRchar         *adsTblName      O       att driven symbol table name

  Notes/Remarks
	Suppress output if NULL.

  Status/Return Code
      status == OM_S_SUCCESS    if success;
 ---------------------------------------------------------------------------
-me*/

method  VDgetRowConstructInfo(  IGRlong         *msg;
				IGRint		rowNo;
                                IGRchar         *tblLoName;
                                IGRshort        *tblOrient;
                                struct GRid     *csId;
                                IGRdouble       *cornerPoint;
				IGRchar		*adsTblName )
{
    IGRlong		status = OM_S_SUCCESS;
    OM_S_CHANSELECT	ownerChan;

    SetProc( VDdrwTblHdr.VDgetRowConstructInfo ); Begin

    *msg = MSSUCC;

    if( tblLoName )
        strcpy( tblLoName, me->tblLayoutName );

    if( tblOrient )
        *tblOrient = me->tblOrient;

    if( cornerPoint )
    {
        status =
        _VD_SEND_MY( VDdrwTblHdr.VDgetCornerPointForRow( msg,
							 rowNo,
							 cornerPoint ) );
        CheckRC( status, *msg );
    }

    if( csId )
    {
        status =
        _VD_SEND_MY( VDdrwTblHdr.ACfind_temp_obj(   (int *)msg,
                                                    "cs",
                                                    csId ) );
        CheckRC( status, *msg );

	status =
	_VD_SEND_OBJ( *csId, NDmacro.ACreturn_foot(	msg,
							"",
							csId,
							NULL, NULL ) );
	__CheckRC( status, *msg, "NDmacro.ACreturn_foot", wrapup );
    }

    if( adsTblName )
    {
	/* select owner channel */

	status =
	om$make_chanselect(	channame	= "GRconnector.to_owners",
				p_chanselect	= &ownerChan );
	__CheckRC( status, 1, "selecting owner channel", wrapup );

	/* get ads tbl name */

	status =
	om$send(	msg		= message VDdrwTbl.VDgetAdsTblName( 
								msg, 
								adsTblName ),
			p_chanselect	= &ownerChan,
			from		= 0,
			to		= 0 );
	__CheckRC( status, *msg, "VDdrwTbl.VDgetAdsTblName", wrapup );

	__DBGpr_str( "ADS tbl name", adsTblName );
    }

wrapup:
    End
    return status;
}

/*+me
 ---------------------------------------------------------------------------
  Public Message VDrowNoToGRid

  Abstract
        This method converts the given row number to GRid of the row
        object.

  Arguments
        IGRlong         *msg            O       Return code
        IGRint          rowNo           I       Row number
        struct GRid     *rowId          O       GRid of the row object

  Notes/Remarks

  Status/Return Code
      status == OM_S_SUCCESS    if success;
 ---------------------------------------------------------------------------
-me*/

method  VDrowNoToGRid(  IGRlong         *msg;
                        IGRint          rowNo;
                        struct GRid     *rowId )
{
    IGRint		i,
			tmpRowNo,
			nbRows;
    IGRlong		status = OM_S_SUCCESS;
    OM_S_CHANSELECT	toRowsChan;

    SetProc( VDdrwTblHdr.VDrowNoToGRid ); Begin

    /* fail message : if row Id is found, msg will be set to MSSUCC */

    *msg = MSFAIL;

    nbRows = om$dimension_of( varray = me->rowHeights ) - 2;

    /* validate if row number is within limits */

    if( rowNo < me->startRowNo || rowNo > (me->startRowNo + nbRows - 1) )
    {
	__DBGpr_com( "Row number out of range" );
	status = OM_E_ABORT;
	goto wrapup;
    }

    /* select the toRows channel */

    status =
    om$make_chanselect(	channame	= "VDdrwTblHdr.to_tblRows",
			p_chanselect	= &toRowsChan );
    __CheckRC( status, 1, "selecting toRowsChan", wrapup );
   
    /* get the row Id from the channel */

    for( i = 0 ; i < OM_K_MAXINT ; i++ )
    {
	/* get object at index */

	status =
	om$get_objid_at_index(	objid		= my_id,
				p_chanselect	= &toRowsChan,
				index		= i,
				objidaddr	= &(rowId->objid),
				osnumaddr	= &(rowId->osnum) );
	if( !(status & 1) )
	{
	    /* end of objects on channel */
	
	    break;
	}
	
	/* get row number of the object */

	tmpRowNo = 0;

	status =
	_VD_SEND_OBJ( *rowId, VDdrwTblRow.VDgetRowNumber(	msg,
								&tmpRowNo ) );
	CheckRC( status, *msg );

	__DBGpr_int( "Current row number", tmpRowNo );

	if( tmpRowNo == rowNo )
	{
	    *msg = MSSUCC;
	    break;
	}
    }
	
wrapup:
    End
    return status;
}

/*+me
 ---------------------------------------------------------------------------
  Public Message VDgetRowHeight

  Abstract
        This method gets the height of a given row number.

  Arguments
        IGRlong         *msg             O       Return code
        IGRint          rowNo            I       Row number
        IGRdouble       *rowHeight       O       rows height

  Notes/Remarks

  Status/Return Code
      status == OM_S_SUCCESS    if success;
 ---------------------------------------------------------------------------
-me*/

method  VDgetRowHeight( IGRlong         *msg;
                        IGRint          rowNo;
                        IGRdouble       *rowHeight )
{
    IGRint		nbRows;
    IGRlong		status = OM_S_SUCCESS;

    SetProc( VDdrwTblHdr.VDgetRowHeight ); Begin

    *msg = MSSUCC;
  
    __DBGpr_int( "Row number ", rowNo );

{// dirty code to correct dimension of rwoHeight
    if( rowNo == -1 ) {
	status =
        om$vla_set_dimension(	varray  = me->rowHeights,
				size    = (int)(*rowHeight) );
	goto wrapup;

    }
}

    nbRows = om$dimension_of( varray = me->rowHeights ) - 2;
    __DBGpr_int( "Number of rows ", nbRows );
    __DBGpr_int( "StartRowNo ", me->startRowNo );
   
    /* validate row limits */

    if( rowNo < me->startRowNo || rowNo > (me->startRowNo + nbRows - 1) )
    {
	__DBGpr_com( "Row number out of range" );
	status = OM_E_ABORT;
	goto wrapup;
    }

    *rowHeight = me->rowHeights[rowNo - me->startRowNo + 1];

wrapup :
    End
    return status;
}

end implementation VDdrwTblHdr;
