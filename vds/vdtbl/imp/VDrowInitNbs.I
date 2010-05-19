/* $Id: VDrowInitNbs.I,v 1.1.1.1 2001/01/04 21:09:28 cvs Exp $  */
/*--------------------------------------------------------------------------
/* I/VDS
 *
 * File:        vdtbl/imp / VDrowInitNbs.I
 *
 * Description:
 *	Implementation of the following methods  for VDdrwTblRow :
 *		VDinitTblRow
 *		VDgetQtyExpr
 *		VDputQtyExpr
 *		VDgetRowNumber
 *		VDputRowNumber
 *		VDgetItemNumber
 *		VDputItemNumber
 *		VDisRowLinedOut
 *		VDputLineOutFlag
 *		VDputUserDefRowFlag
 *		VDisUserDefinedRow
 *
 * Dependencies:
 *
 * History:
 *      
 *	04/14/95	R. Manem	Creation
 *	05/15/95	R. Manem	Added VDputQtyExpr method
 *	06/19/95	R. Manem	Adapted to instance data changes
 *	09/13/95	R. Manem	Added VDputLineOutFlag, 
 *					VDputUserDefRowFlag, VDisUserDefinedRow
 *	09/20/95	R. Manem	Fixed bug in putting qty expression
 *
 * -------------------------------------------------------------------------
 */

class implementation VDdrwTblRow;

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

#include "VDdrwlo.h"
#include "VDdrwtbl.h"

/*+me
 -------------------------------------------------------------------------
  Public Message VDinitTblRow

  Abstract
        This method initializes instance data

  Arguments
        IGRlong         *msg            O       Return code

  Notes/Remarks

  Status/Return Code
      status == OM_S_SUCCESS    if success;
 -------------------------------------------------------------------------
-me*/

method  VDinitTblRow(   IGRlong         *msg )
{
    IGRlong		status = OM_S_SUCCESS;
 
    SetProc( VDdrwTblRow.VDinitTblRow ); Begin

    *msg = MSSUCC;

    me->itemNumber[0] = '\0';
    me->rowNumber = -1;
    me->rowInfo = 0;
    me->qtyExp[0] = '\0';

    End
    return status;
}

/*+me
 -------------------------------------------------------------------------
  Public Message VDgetQtyExpr

  Abstract
        This method gets the expression for quantity

  Arguments
        IGRlong                 *msg    O     Return code
        struct VDdrwlo_qtyExp   *qty    O     Expression for quantity

  Notes/Remarks

  Status/Return Code
      status == OM_S_SUCCESS    if success;
 -------------------------------------------------------------------------
-me*/

method  VDgetQtyExpr(   IGRlong                 *msg;
                        struct VDdrwlo_qtyExp   *qty )
{
    SetProc( VDdrwTblRow.VDgetQtyExpr ); Begin

    *msg = MSSUCC;

    if( me->rowInfo & VD_ROW_QTY_EXPRESSION )
    {
	__DBGpr_com( "quantity is EXPRESSION" );
	qty->nSflag = VD_DRWLO_EN_EXPRESS;
	strcpy( qty->szExp, me->qtyExp );
    }
    else
    {
	__DBGpr_com( "quantity is COUNT" );
	qty->nSflag = VD_DRWLO_EN_COUNT;
	qty->szExp[0] = '\0';
    }

    End
    return OM_S_SUCCESS;
}


/*+me
 -------------------------------------------------------------------------
  Public Message VDputQtyExpr

  Abstract
        This method puts the expression for quantity

  Arguments
        IGRlong                 *msg    O     Return code
        struct VDdrwlo_qtyExp   qty     I     Expression for quantity

  Notes/Remarks

  Status/Return Code
      status == OM_S_SUCCESS    if success;
 -------------------------------------------------------------------------
-me*/

method  VDputQtyExpr(   IGRlong                 *msg;
                        struct VDdrwlo_qtyExp   qty )
{
    IGRint		size;
    IGRshort		mask;
    IGRlong		status = OM_S_SUCCESS;
    SetProc( VDdrwTblRow.VDputQtyExpr ); Begin

    *msg = MSSUCC;

    if( qty.nSflag == VD_DRWLO_EN_COUNT )
    {
	__DBGpr_com( "quantity is COUNT" );

	mask = ~(0 | VD_ROW_QTY_EXPRESSION );
	me->rowInfo &= mask;
	me->qtyExp[0] = '\0';
    }
    else if( qty.nSflag == VD_DRWLO_EN_EXPRESS )
    {
	__DBGpr_com( "quantity is EXPRESSION" );

	me->rowInfo |= VD_ROW_QTY_EXPRESSION;

	/* allocate memory if necessary */

	size = strlen( qty.szExp ) + 1;
	__DBGpr_int( "Size of qty expr", size );

	if( om$dimension_of( varray = me->qtyExp ) != size )
	{
	    __DBGpr_com( "Allocating memory for qtyExp" );

	    status = om$vla_set_dimension(	varray	= me->qtyExp,
						size	= size );
	    __CheckRC( status, 1, "om$vla_set_dimension", wrapup );
	}

	strcpy( me->qtyExp, qty.szExp );
    }

    __DBGpr_int( "rowInfo bits", me->rowInfo );

wrapup :
    End
    return OM_S_SUCCESS;
}


/*+me
 -------------------------------------------------------------------------
  Public Message VDgetRowNumber

  Abstract
        This method gets the row number

  Arguments
        IGRlong         *msg      O     Return code
        IGRint          *rowNo    O     Row number

  Notes/Remarks

  Status/Return Code
      status == OM_S_SUCCESS    if success;
 -------------------------------------------------------------------------
-me*/

method  VDgetRowNumber( IGRlong         *msg;
                        IGRint          *rowNo )
{
    IGRlong             status = OM_S_SUCCESS;

    SetProc( VDdrwTblRow.VDgetRowNumber ); Begin

    *msg = MSSUCC;

    *rowNo = me->rowNumber;

    End
    return status;
}

/*+me
 -------------------------------------------------------------------------
  Public Message VDputRowNumber

  Abstract
        This method puts the row number

  Arguments
        IGRlong         *msg      O     Return code
        IGRint          rowNo     O     Row number

  Notes/Remarks

  Status/Return Code
      status == OM_S_SUCCESS    if success;
 -------------------------------------------------------------------------
-me*/

method  VDputRowNumber( IGRlong         *msg;
                        IGRint          rowNo )
{
    IGRlong             status = OM_S_SUCCESS;

    SetProc( VDdrwTblRow.VDputRowNumber ); Begin

    *msg = MSSUCC;

    me->rowNumber = rowNo;

    End
    return status;
}

/*+me
 -------------------------------------------------------------------------
  Public Message VDgetItemNumber

  Abstract
        This method gets the item number, and the pfx string for the row

  Arguments
        IGRlong         *msg      O     Return code
        IGRint          *bufSize  O     size of buffer = strlen(itemNo) + 1
        IGRchar         *itemNo   O     Item Number string

  Notes/Remarks
        Memory for itemNo to be allocated by caller.
        If itemNo = NULL, output is suppressed

  Status/Return Code
      status == OM_S_SUCCESS    if success;
 -------------------------------------------------------------------------
-me*/

method  VDgetItemNumber(        IGRlong         *msg;
				IGRint		*bufSize;
                                IGRchar         *itemNo )
{
    IGRint		len = 0;
    IGRlong             status = OM_S_SUCCESS;

    SetProc( VDdrwTblRow.VDgetItemNumber ); Begin

    *msg = MSSUCC;

    len = strlen( me->itemNumber );
    __DBGpr_int( "Length", len );

    if( bufSize )
        *bufSize = len + 1;

    if( itemNo )
	strcpy( itemNo, me->itemNumber );

    End
    return status;
}

/*+me
 -------------------------------------------------------------------------
  Public Message VDputItemNumber

  Abstract
        This method puts the item number for the row

  Arguments
        IGRlong         *msg      O     Return code
        IGRchar         *itemNo   I     Item number

  Notes/Remarks

  Status/Return Code
      status == OM_S_SUCCESS    if success;
 -------------------------------------------------------------------------
-me*/

method  VDputItemNumber(        IGRlong         *msg;
                                IGRchar         *itemNo )
{
    IGRint		len = 0;
    IGRlong             status = OM_S_SUCCESS;

    SetProc( VDdrwTblRow.VDputItemNumber ); Begin

    *msg = MSSUCC;
   
    if( !itemNo )
	goto wrapup;

    len = strlen( itemNo ) + 1;
    __DBGpr_int( "Input string length + 1", len );

    /* allocate memory if needed */

    if( om$dimension_of( varray = me->itemNumber ) !=  len )
    {
    	status = om$vla_set_dimension(	varray	= me->itemNumber,
					size	= len );
    	__CheckRC( status, 1, "om$vla_set_dimension", wrapup );
    }

    strcpy( me->itemNumber, itemNo );

wrapup :
    End
    return status;
}

/*+me
 -------------------------------------------------------------------------
  Public Message VDisRowLinedOut

  Abstract
        This message tells whether the row is lined out or not

  Arguments
        IGRlong         *msg            O     Return code
        IGRshort        *isLinedOut     O     1 = lined out, 0 = not lined out

  Status/Return Code
      status == OM_S_SUCCESS    if success;
 -------------------------------------------------------------------------
-me*/

method  VDisRowLinedOut(IGRlong         *msg;
                        IGRshort        *isLinedOut )
{
    SetProc( VDdrwTblRow.VDisRowLinedOut ); Begin

    *msg = MSSUCC;

    if( me->rowInfo & VD_ROW_LINEOUT )
    	*isLinedOut = 1;
    else
	*isLinedOut = 0;

    __DBGpr_int( "Line out flag", *isLinedOut );

    End
    return OM_S_SUCCESS;
}

/*+me
 -------------------------------------------------------------------------
  Public Message VDputLineOutFlag

  Abstract
        This message sets or resets the lineOut flag

  Arguments
        IGRlong         *msg            O     Return code
        IGRshort        flag            I     1 = lined out
                                              0 = not lined out

  Status/Return Code
      status == OM_S_SUCCESS    always ;
 -------------------------------------------------------------------------
-me*/

method  VDputLineOutFlag(       IGRlong         *msg;
                                IGRshort        flag )
{
    IGRlong             status = OM_S_SUCCESS;
    IGRshort		mask;

    SetProc( VDdrwTblRow.VDputLineOutFlag ); Begin

    *msg = MSSUCC;
   
    if( flag == 1 )
	me->rowInfo |= VD_ROW_LINEOUT;
    else if( flag == 0 )
    {
	mask = ~(0 | VD_ROW_LINEOUT );
	me->rowInfo &= mask;
    }

    End
    return status;
}

/*+me
 -------------------------------------------------------------------------
  Public Message VDputUserDefRowFlag

  Abstract
        This message sets or resets the user-defined row flag

  Arguments
        IGRlong         *msg            O     Return code
        IGRshort        flag            I     1 = is user-defined row
                                              0 = not user-defined row

  Status/Return Code
      status == OM_S_SUCCESS    always ;
 -------------------------------------------------------------------------
-me*/

method  VDputUserDefRowFlag(    IGRlong         *msg;
                                IGRshort        flag )
{
    IGRlong             status = OM_S_SUCCESS;
    IGRshort		mask;

    SetProc( VDdrwTblRow.VDputUserDefRowFlag ); Begin

    *msg = MSSUCC;
   
    if( flag == 1 )
	me->rowInfo |= VD_ROW_USER_DEFINED;
    else if( flag == 0 )
    {
	mask = ~(0 | VD_ROW_USER_DEFINED );
	me->rowInfo &= mask;
    }

    End
    return status;
}

/*+me
 -------------------------------------------------------------------------
  Public Message VDisUserDefinedRow

  Abstract
        This message tells whether the row is user defined or not

  Arguments
        IGRlong         *msg            O     Return code
        IGRshort        *isUserDef      O     1 = user-def, 0 = not user-def

  Status/Return Code
      status == OM_S_SUCCESS    if success;
 -------------------------------------------------------------------------
-me*/

method  VDisUserDefinedRow(     IGRlong         *msg;
                                IGRshort        *isUserDef )
{
    SetProc( VDdrwTblRow.VDisUserDefinedRow ); Begin

    *msg = MSSUCC;

    if( me->rowInfo & VD_ROW_USER_DEFINED )
    	*isUserDef = 1;
    else
	*isUserDef = 0;

    __DBGpr_int( "User defined row flag", *isUserDef );

    End
    return OM_S_SUCCESS;
}


end implementation VDdrwTblRow;

