/* $Id: VDrowLineOut.I,v 1.1.1.1 2001/01/04 21:09:26 cvs Exp $ */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vds/vdtbl/cmd / VDrowLineOut.I
 *
 * Description:
 *      Implementation of the following method for VDCmdLineOut :
 *              lineout_table_row
 *
 * Dependencies:
 *
 * History:
 *
 *      07/24/95        R. Manem        Creation
 *      09/13/95        R. Manem        Added remove_lineout method
 *					Adapted lineout_table_row to directly
 *					set line out flag, and recompute,
 *					instead of using VDparentSetEmpty msg
 *
 * -------------------------------------------------------------------*/


class implementation VDCmdCrTbl;

/*
#define vdsDEBUG
#define vdserrDEBUG
*/

#include <stdio.h>
#include "string.h"

#include "OMmacros.h"
#include "OMprimitives.h"

#include "v_miscmacros.h"
#include "v_dbgmacros.h"
#include "v_datamacros.h"

#include "VDCmdDef.h"

from VDdrwTblRow	import	VDisRowLinedOut,
				VDputLineOutFlag,
				VDconstructRow,
				VDisUserDefinedRow,
				VDgetParentObjectList;

/*+me
 ---------------------------------------------------------------------------
  Public Message lineout_table_row

  Abstract
        This method lines out a located table row after validating the row

  Arguments
        IGRlong         *sts            O       Return code

  Notes/Remarks

  Status/Return Code
      *sts = VD_SUCCESS
 ---------------------------------------------------------------------------
-me*/

method  lineout_table_row ( long * sts )
{
    IGRshort		linedOut = 0;
    IGRint		nbObjs = 0;
    IGRlong		msg,
			status = OM_S_SUCCESS;
    struct GRid		rowId;

    SetProc( VDCmdCrTbl.lineout_table_row ); Begin

    *sts = VD_SUCCESS;

    rowId = me->event1.located_object[0].located_obj ;

    __DBGpr_obj( "Row Id", rowId );

    /* check if row is already lined out */

    status =
    _VD_SEND_OBJ( rowId, VDdrwTblRow.VDisRowLinedOut( &msg, &linedOut ) );
    CheckRC( status, msg );

    __DBGpr_int( "Line out value", linedOut );

    if( linedOut )
    {
	UI_status( "Row is already lined out" );
	goto wrapup;
    }

    /* validate row : row must not have any parent set objects */

    status =
    _VD_SEND_OBJ( rowId, VDdrwTblRow.VDgetParentObjectList( 	&msg, 
								&nbObjs,
								NULL ) );
    CheckRC( status, msg );
    __DBGpr_int( "Number of parent objects", nbObjs );

    if( nbObjs )
    {
	UI_status( "Invalid row selected : row is not user defined" );
	goto wrapup;
    }

    /* convert row to line out */

    status = _VD_SEND_OBJ( rowId, VDdrwTblRow.VDputLineOutFlag( &msg, 1 ) );
    CheckRC( status, msg );

    status = _VD_SEND_OBJ( rowId, VDdrwTblRow.VDconstructRow( &msg ) );
    CheckRC( status, msg );

wrapup :
    End
    return OM_S_SUCCESS;
}

/*+me
 ---------------------------------------------------------------------------
  Public Message remove_lineout

  Abstract
        This method removes the lineout of a table row

  Arguments
        IGRlong         *sts            O       Return code

  Notes/Remarks

  Status/Return Code
      *sts = VD_SUCCESS
 ---------------------------------------------------------------------------
-me*/

method remove_lineout ( long * sts )
{
    IGRshort		linedOut = 0,
			userDef = 0;
    IGRlong		msg,
			status = OM_S_SUCCESS;
    struct GRid		rowId;

    SetProc( VDCmdCrTbl.lineout_table_row ); Begin

    *sts = VD_SUCCESS;

    rowId = me->event1.located_object[0].located_obj ;

    __DBGpr_obj( "Row Id", rowId );

    /* check if row is already lined out */

    status =
    _VD_SEND_OBJ( rowId, VDdrwTblRow.VDisRowLinedOut( &msg, &linedOut ) );
    CheckRC( status, msg );

    __DBGpr_int( "Line out value", linedOut );

    if( !linedOut )
    {
	UI_status( "Invalid row selected : row is not lined out" );
	goto wrapup;
    }

    /* check if row is a user defined row */

    status =
    _VD_SEND_OBJ( rowId, VDdrwTblRow.VDisUserDefinedRow( &msg, &userDef ) );
    CheckRC( status, msg );

    __DBGpr_int( "User defined row flag", userDef );

    if( !userDef )
    {
	UI_status( "Invalid row selected : row is not user defined" );
	goto wrapup;
    }

    /* remove line out for the row and recompute */

    status = _VD_SEND_OBJ( rowId, VDdrwTblRow.VDputLineOutFlag( &msg, 0 ) );
    CheckRC( status, msg );

    status = _VD_SEND_OBJ( rowId, VDdrwTblRow.VDconstructRow( &msg ) );
    CheckRC( status, msg );

wrapup :
    End
    return OM_S_SUCCESS;
}
end implementation VDCmdCrTbl;
