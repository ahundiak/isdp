/* $Id: VDtblUpdCol.I,v 1.6 2002/06/06 17:12:37 ylong Exp $ */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vds/vdtbl/cmd / VDtblUpdCol.I
 *
 * Description:
 *	Implementation of the following methods for VDCmdCrTbl :
 *		VDinitInvDataCols
 *		VDupdateVisColDisp
 *		VDstoreSelectedColumnList
 *		VDupdate1stCol
 *		VDcheckColSize
 *
 * Dependencies:
 *
 * History:
 *
 *      04/14/95        R. Manem        Creation
 *      06/16/95        R. Manem        Lineout indication on form with '-' char
 *      08/16/95        R. Manem        Added VDcheckColSize method
 *      08/18/95        R. Manem        Fixed TR # 179527259
 *      02/09/00        Ming        	Fixed TR # 179901025
 *
 * -------------------------------------------------------------------*/


class implementation VDCmdCrTbl;

/*
#define vdsDEBUG
#define vdserrDEBUG
*/

#include <stdio.h>
#include "string.h"

#include "VDtblXml.h"

#include "OMmacros.h"
#include "OMprimitives.h"
#include "exproto.h"

#include "v_miscmacros.h"
#include "v_dbgmacros.h"
#include "v_datamacros.h"

#include "VDtypedef.h"

#include "vddlodef.h"
#include "vddlomacros.h"
#include "VDdrwlo.h"
#include "VDdrwlo_pr.h"
#include "VDdrwtbl.h"
#include "VDtblCmdDef.h"

#include "VDCmdDef.h"
#include "VDctx.h"

#include "VDobj.h"

#include "FI.h"
#include "FEI.h"


from VDdrwTblRow	import	VDisRowLinedOut,
				ACfind_temp_obj;

/*+me
 ---------------------------------------------------------------------------
  Public Message VDinitInvDataCols

  Abstract
        This method initializes the rows in the inv columns, starting from 
	startRowNo till the last row

  Arguments
        IGRlong         *sts            O       Return code
        IGRint          startRowNo      I       Starting row number

  Notes/Remarks
	This method is modified for TR5271. Any newly added blocks are marked 
	by TR5271 for this TR

  Status/Return Code
      status == OM_S_SUCCESS

 ---------------------------------------------------------------------------
-me*/

method  VDinitInvDataCols(	IGRlong 	*msg; 
				IGRint		startRowNo )
{
    IGRint			i, j, k,
				row, col,
				nbRows, nbCols,
				nbLines,
				firstLine, lastLine,
				objIndex, 
				nbFixRecs,
				nbDatRecs;
    IGRlong			status = OM_S_SUCCESS;
    IGRchar			*fldVal = NULL;
    struct GRid			*rowId = NULL;
    struct GRid			collId;

    /* TR5271 */
    IGRchar			attName[40];
    IGRshort			usrValFlag = 0, isLinedOut = 0;
    VD_drwLoInfo		drwInfo;
    
    
    SetProc( VDCmdCrTbl.VDinitInvDataCols ); Begin
    *msg = MSSUCC;

    /* Added for TR5271 by ylong */
    collId.objid = NULL_OBJID ;
    status = vd$drw_layout_info (	msg	= msg,
					type	= VD_K_drwLO_tblUsrValue,
					info	= &drwInfo );
    if( (status&*msg&1) )
    {
	usrValFlag = drwInfo.val.iValue;
    }
    /* end TR5271 */

    /* current number of lines in field */

    FIfld_get_num_rows( VD_FP, VD_TBL_INV_COLDISP_FLD, &nbLines );
    __DBGpr_int( "Current number of lines in mcf ", nbLines );

    nbRows = om$dimension_of( varray = me->rows );
    nbLines = nbRows * me->maxLinesPerRow;

    __DBGpr_int( "Total number of rows", nbRows );
    __DBGpr_int( "Total number of lines", nbLines );

    FIfld_set_num_rows( VD_FP, VD_TBL_INV_COLDISP_FLD, nbLines );
    FIfld_set_num_rows( VD_FP, VD_TBL_VIS_COLDISP_FLD, nbLines );

    /* set all texts to NULL first */

    FImcf_get_num_cols( VD_FP, VD_TBL_INV_COLDISP_FLD, &nbCols );

    firstLine = startRowNo * me->maxLinesPerRow;
    lastLine = ( nbRows * me->maxLinesPerRow );

    __DBGpr_int( "First line ", firstLine );
    __DBGpr_int( "Last line ", lastLine );
   
    for( i = firstLine ; i < lastLine ; i++ )
	for( j = 0 ; j < nbCols ; j++ )
	    FIfld_set_text( VD_FP, VD_TBL_INV_COLDISP_FLD, i, j, "", FALSE );

    /* set the R.No column in vis mcf to NULL texts */

    for( i = firstLine ; i < lastLine ; i++ )
	FIfld_set_text( VD_FP, VD_TBL_VIS_COLDISP_FLD, i, 0, "", FALSE );

    nbFixRecs = om$dimension_of( varray = me->fixRecs );
    nbDatRecs = om$dimension_of( varray = me->datRecs );

    __DBGpr_int( "Number of fixed records", nbFixRecs );
    __DBGpr_int( "Number of data records", nbDatRecs );

    for( i = startRowNo ; i < nbRows ; i++ )
    {
	__DBGpr_com( "Updating fixed texts" );

	isLinedOut = 0;
	status =
	_VD_SEND_OBJ( me->rows[i].rowId, VDdrwTblRow.VDisRowLinedOut
						( msg, &isLinedOut ) );
	CheckRC( status, *msg );
	if( !(status&*msg&1) ) isLinedOut = 0;

	/* TR5271 and CR6391 */
	collId.objid = NULL_OBJID;
	if( usrValFlag || isLinedOut )
	{
	    status =
	    _VD_SEND_OBJ( me->rows[i].rowId, VDdrwTblRow.ACfind_temp_obj
					( (int*)msg, "coll", &collId  ) );
	    CheckRC( status, *msg );
	} /* end TR5271 */

	objIndex = me->rows[i].startIndex;

	for( j = 0 ; j < nbFixRecs ; j++ )
	{
	    col = me->fixRecs[j].VD.tx.colno;
	    row = me->fixRecs[j].VD.tx.lineno + ( i * me->maxLinesPerRow ) - 1;

	    FIfld_set_text( VD_FP, VD_TBL_INV_COLDISP_FLD, row, col,
			    (unsigned char *)me->fixRecs[j].VD.tx.Text, FALSE );
#ifdef vdsDEBUG
    printf("\t\ti = %d, j = %d, row = %d, col = %d, text = %s\n", i, j, 
				row, col, me->fixRecs[j].VD.tx.Text );
#endif
	}

	__DBGpr_com( "Updating variable components" );

	for( j = 0 ; j < nbDatRecs ; j++ )
	{
	    col = me->datRecs[j].colno;
	    row = me->datRecs[j].lineno + ( i * me->maxLinesPerRow ) - 1;

	    __DBGpr_int( "Column number", col );
	    __DBGpr_int( "row number", row );
	    __DBGpr_int( "Object index", objIndex );

	    _FREE( fldVal );
		
	    /* for TR5271 and CR6391 */
	    status = *msg = 0;
	    if( (usrValFlag || isLinedOut) && collId.objid != NULL_OBJID )
	    {
		sprintf( attName, "%d %d", 
			me->datRecs[j].colno, me->datRecs[j].lineno );
		status = VDdrw_getAttFromColl( msg, collId, attName, &fldVal );
	    } /* end TR5271 and CR6391 */

	    if( !(status&*msg&1) || !fldVal ) /* condition for TR5271 */
	    {
	    rowId = NULL;
	    if( me->rows[i].rowId.objid != NULL_OBJID )
		rowId = &me->rows[i].rowId;

	    status = VDdrw_getFldValue( msg, 
					me->rows[i].nbObjs, 
					&me->locObjs[objIndex], 
					me->datRecs[j], 
					me->rows[i].qty,
					rowId,
					&fldVal );
	    CheckRC( status, *msg );
	    }

	    __DBGpr_str( "Field Value ", fldVal );

	    FIfld_set_text( VD_FP, VD_TBL_INV_COLDISP_FLD, row, col,
			    (unsigned char *)fldVal, FALSE );
	}
    }

    __DBGpr_com( "Updating row number column" );

    status =
    _VD_SEND_MY( VDCmdCrTbl.VDupdate1stCol( msg ) );
    CheckRC( status, *msg );

    _FREE( fldVal );

    End
    return OM_S_SUCCESS;
}

/*+me
 ---------------------------------------------------------------------------
  Public Message VDupdateVisColDisp

  Abstract
        This method updates the vis column display according to the 
	selected column list.  The old columns are deleted and new columns
	are added to the vis mcf.

  Arguments
        IGRlong         *sts            O       Return code

  Notes/Remarks

  Status/Return Code
      status == OM_S_SUCCESS

 ---------------------------------------------------------------------------
-me*/

method  VDupdateVisColDisp ( IGRlong 	*msg )
{
    IGRint		i, 
			nbCols;
    IGRlong		status = OM_S_SUCCESS;
    
    SetProc( VDCmdCrTbl.VDupdateVisColDisp ); Begin

    *msg = MSSUCC;

    /* 
     * delete the existing vis columns 
     */

    FImcf_get_num_cols( VD_FP, VD_TBL_VIS_COLDISP_FLD, &nbCols );

    __DBGpr_int( "Number of columns in visible mcf", nbCols );

    for( i = nbCols-1 ; i > 0 ; i-- )
    {
	status =
	_VD_SEND_MY( VDCmdCrTbl.VDdeleteVisCol( msg, i ) );
	CheckRC( status, *msg );
    }

    /* get the newly selected column list */

    status =
    _VD_SEND_MY( VDCmdCrTbl.VDstoreSelectedColumnList( msg ) );
    CheckRC( status, *msg );

    __DBGpr_int( "Number of selected columns", me->nbSelCols );

    /*
     * check size : if it won't fit, me->nbSelCols is automatically
     * updated
     */

    status = _VD_SEND_MY( VDCmdCrTbl.VDcheckColSize( msg, 
						VD_TBL_SHOW_SELCOL_BTN ) );
    CheckRC( status, 1 );

    /* insert the columns */

    for( i = 0 ; i < me->nbSelCols ; i++ )
    {
	status =
	_VD_SEND_MY( VDCmdCrTbl.VDinsertVisCol( msg, me->selColList[i], i+1 ) );
	CheckRC( status, *msg );

	/* if the new column does not fit in the form, delete it ???  */
    }

    End
    return OM_S_SUCCESS;
}

/*+me
 ---------------------------------------------------------------------------
  Public Message VDstoreSelectedColumnList

  Abstract
        This method gets and stores the list of selected columns in the
	instance data

  Arguments
        IGRlong         *sts            O       Return code

  Notes/Remarks

  Status/Return Code
      status == OM_S_SUCCESS

 ---------------------------------------------------------------------------
-me*/

method VDstoreSelectedColumnList( IGRlong	*msg )
{
    IGRint		i,
			sel, 
			index = 0,
			nextCol,
			nbCols,
			vlaSize,
			nbSelCols = 0;
    IGRlong		status = OM_S_SUCCESS;
    SetProc( VDCmdCrTbl.VDstoreSelectedColumnList ); Begin

    *msg = MSSUCC;

    /* get total number of columns for the table */

    FIfld_get_num_rows( VD_FP, VD_TBL_SELCOL_LIST_FLD, &nbCols );
    __DBGpr_int( "TOtal number of columns ", nbCols );

    /* current vla size of selColList */

    vlaSize = om$dimension_of( varray	= me->selColList );
    __DBGpr_int( "Current selColList size", vlaSize );

    /* Added by Ming for TR179901025 */
    for( i = 0 ; i < nbCols ; i++ )
    {
	FIfld_get_select( VD_FP, VD_TBL_SELCOL_LIST_FLD, i, 0, &sel );
	if( sel ) nbSelCols++;
    }

    if( nbSelCols > vlaSize )
    {
      status = om$vla_set_dimension( varray  = me->selColList,
                                     size    = nbSelCols );
      __CheckRC( status, 1, "vla_set_dimension", wrapup );
    }

    /* update list */
    for( i = 0 ; i < nbCols ; i++ )
    {
	FIfld_get_select( VD_FP, VD_TBL_SELCOL_LIST_FLD, i, 0, &sel );

        /* Commented by Ming for TR179901025
	if( sel )
	{
	    nbSelCols++;
	    if( index < vlaSize )
	        me->selColList[index++] = i+1;
	}
        */

        /* Added by Ming for TR179901025 */
	if( sel ) me->selColList[index++] = i+1;
    }

    __DBGpr_int( "Number of selected columns", nbSelCols );

    /* 
     * if number of selected columns exceeds vlaSize, resize the vla, and
     * update the remaining entries
     */

    /* Commented by Ming for TR179901025
    if( nbSelCols > vlaSize )
    {
	status = om$vla_set_dimension( 	varray	= me->selColList,
					size	= nbSelCols );
	__CheckRC( status, 1, "vla_set_dimension", wrapup );

	nextCol = me->selColList[index-1];
    	for( i = nextCol ; i < nbCols ; i++ )
    	{
	    FIfld_get_select( VD_FP, VD_TBL_SELCOL_LIST_FLD, i, 0, &sel );
	    if( sel )
	        me->selColList[index++] = i+1;
        }
    }
    */

    me->nbSelCols = nbSelCols;

#ifdef vdsDEBUG
    printf("\n\tList of selected columns :\n\t\t");
    for( i = 0 ; i < index ; i++ )
	printf("%d, ", me->selColList[i] );
    printf("\n\n");
#endif

wrapup :

    End
    return OM_S_SUCCESS;
}

/*+me
 ---------------------------------------------------------------------------
  Public Message VDupdate1stCol

  Abstract
        This method updates the R.No column in both vis and inv mcfs.  
	Summarized rows are indicated by the row number followed by a '*'

  Arguments
        IGRlong         *sts            O       Return code

  Notes/Remarks

  Status/Return Code
      status == OM_S_SUCCESS

 ---------------------------------------------------------------------------
-me*/

method VDupdate1stCol(	IGRlong		*msg )
{
    IGRint		i,
			row,
			nbRows;
    IGRchar		buf[10];
    IGRshort		isLinedOut;
    IGRlong		status = OM_S_SUCCESS;

    SetProc( VDCmdCrTbl.VDupdate1stCol ); Begin

    *msg = MSSUCC;

    nbRows = om$dimension_of( varray = me->rows );

    for( i = 0 ; i < nbRows ; i++ )
    {
	row = i * me->maxLinesPerRow;
	
	buf[0] = '\0';
	sprintf( buf, "%d", i+1 );

	if( me->rows[i].nbObjs > 1 )
	    strcat( buf, "*" );

	/* if row is lined out, append a '-' */

	if( me->rows[i].rowId.objid != NULL_OBJID )
	{
	    /* get line out flag */

	    isLinedOut = 0;
	    status =
	    _VD_SEND_OBJ( me->rows[i].rowId, VDdrwTblRow.VDisRowLinedOut( msg,
								&isLinedOut ) );
	    CheckRC( status, *msg );

	    if( isLinedOut )
		strcat( buf, "-" );
	}

	FIfld_set_text( VD_FP, VD_TBL_INV_COLDISP_FLD, row, 0,
			(unsigned char *)buf, FALSE );
	FIfld_set_text( VD_FP, VD_TBL_VIS_COLDISP_FLD, row, 0,
			(unsigned char *)buf, FALSE );
    }

    End
    return status;
}


/*+me
 ---------------------------------------------------------------------------
  Public Message VDcheckColSize

  Abstract
        This method checks if the columns in the visible mcf will fit
	on the form.

  Arguments
        IGRlong         *msg            O       Return code
	IGRint		gadLabel	I	The gadget label, for which
						the column display has to be
						updated :
						    VD_TBL_SHOW_SELCOL_BTN,
						    VD_TBL_SCROLL_LEFT_BTN,
						    VD_TBL_SCROLL_RIGHT_BTN
  Status
	status = OM_S_SUCCESS

  Return code

	*msg	= MSSUCC, if columns will fit on the form
		  MSFAIL, if columns will not fit

 ---------------------------------------------------------------------------
-me*/

method  VDcheckColSize(	IGRlong 	*msg;
			IGRint		gadLabel )
{
    IGRint		i,
			fx, fy,		/* form size 	*/
			gx, gy,		/* gadget size 	*/
			nbCols, nbRows,
			nbChars,
			sel, pos,
			row,
			maxX, reqX;
    long		attrMask = 0;
    IGRdouble		width;

    SetProc( VDCmdCrTbl.VDcheckColSize ); Begin
    *msg = MSSUCC;

    /* form size and gadget location */

    FIf_get_size( VD_FP, &fx, &fy );
    FIg_get_location( VD_FP, VD_TBL_VIS_COLDISP_FLD, &gx, &gy );

    /* max width of column */

    maxX = fx - gx - VD_TBL_SCROLL_WIDTH;

    /* if scroll buttons are present in column title field, decrease by 10 */
    
    FImcf_get_attr( VD_FP, VD_TBL_VIS_COLTITL_FLD, &attrMask );
    if( attrMask & FI_DISPLAY_VSCROLL )
	maxX -= 10;

    __DBGpr_int( "Maximum mcf width", maxX );

    nbCols = 0;
    nbChars = VD_TBL_ROWNO_COL_CHARS;

    switch( gadLabel )
    {
	case VD_TBL_SHOW_SELCOL_BTN :
	    
	    FIfld_get_num_rows( VD_FP, VD_TBL_SELCOL_LIST_FLD, &nbRows );
	    __DBGpr_int( "Total Number of rows ", nbRows );

	    /* count number of columns, and total number of chars */

	    for( i = 0 ; i < nbRows ; i++ )
	    {
		FImcf_get_select( VD_FP, VD_TBL_SELCOL_LIST_FLD, i, &sel );

		if( sel )
		{
		    nbCols++;
		    FIfld_get_value( VD_FP, VD_TBL_SELCOL_LIST_FLD, i, 2,
						&width, &sel, &pos );
#ifdef vdsDEBUG
		    printf("\tRow %d selected : width = %d\n", i,									(IGRint)width );
#endif

		    nbChars += (IGRint)width;

    		    /* compute current total width required */

		    reqX = ( nbCols * VD_TBL_COLSEP_WIDTH ) + 
			( nbChars * VD_TBL_CHAR_WIDTH ) + VD_TBL_CONST_FACTOR;
		    __DBGpr_int( "Number of columns", nbCols );
		    __DBGpr_int( "Number of chars", nbChars );
		    __DBGpr_int( "Required width", reqX );

		    if( reqX > maxX )
		    {
			FIfld_set_text( VD_FP, FI_MSG_FIELD, 0, 0,
				"Could not fit all columns on form", FALSE );
			*msg = MSFAIL;

			me->nbSelCols = nbCols - 1;
			__DBGpr_int( "Number of selected columns changed to",
							me->nbSelCols );
	
			break;
		    }
		}
	    }

	    break;

	case VD_TBL_SCROLL_LEFT_BTN :

	case VD_TBL_SCROLL_RIGHT_BTN :

	    nbCols = me->nbSelCols;
	    __DBGpr_int( "Number of columns", nbCols );

	    if( nbCols <= 0 ) break;

	    /* count number of characters in the middle rows */

	    for( i = 1 ; i < nbCols-1 ; i++ )
	    {
		row = me->selColList[i] - 1;
		FIfld_get_value( VD_FP, VD_TBL_SELCOL_LIST_FLD, row, 2,
						&width, &sel, &pos );
#ifdef vdsDEBUG
		printf("\trow = %d, width = %d\n", row, (IGRint)width );
#endif

		nbChars += (IGRint)width;
	    }

	    if( gadLabel == VD_TBL_SCROLL_LEFT_BTN )
	    {
		/* get first col + one before it */

		/* Modified by Ming for TR179901025 */
                if( nbCols > 1 )
                {
		  row = me->selColList[0] - 1;
		  FIfld_get_value( VD_FP, VD_TBL_SELCOL_LIST_FLD, row, 2,
						&width, &sel, &pos );
#ifdef vdsDEBUG
		  printf("\trow = %d, width = %d\n", row, (IGRint)width );
#endif
		  nbChars += (IGRint)width;
   		}

		row = me->selColList[0] - 2;
		FIfld_get_value( VD_FP, VD_TBL_SELCOL_LIST_FLD, row, 2,
						&width, &sel, &pos );
#ifdef vdsDEBUG
		printf("\trow = %d, width = %d\n", row, (IGRint)width );
#endif
		nbChars += (IGRint)width;
	    }
	    else if( gadLabel == VD_TBL_SCROLL_RIGHT_BTN )
	    {
		/* get last column + one after it */

		/* Modified by Ming for TR179901025 */
                if( nbCols > 1 )
                {
		  row = me->selColList[nbCols-1] - 1;
		  FIfld_get_value( VD_FP, VD_TBL_SELCOL_LIST_FLD, row, 2,
						&width, &sel, &pos );
#ifdef vdsDEBUG
		  printf("\trow = %d, width = %d\n", row, (IGRint)width );
#endif
		  nbChars += (IGRint)width;
    		}

		row = me->selColList[nbCols-1];
		FIfld_get_value( VD_FP, VD_TBL_SELCOL_LIST_FLD, row, 2,
						&width, &sel, &pos );
#ifdef vdsDEBUG
		printf("\trow = %d, width = %d\n", row, (IGRint)width );
#endif
		nbChars += (IGRint)width;
	    }

	    /* compute total width required */

	    reqX = ( nbCols * VD_TBL_COLSEP_WIDTH ) + 
			( nbChars * VD_TBL_CHAR_WIDTH ) + VD_TBL_CONST_FACTOR;
	    __DBGpr_int( "Number of columns", nbCols );
	    __DBGpr_int( "Number of chars", nbChars );
	    __DBGpr_int( "Required width", reqX );

	    if( reqX > maxX )
	    {
		if( gadLabel == VD_TBL_SCROLL_LEFT_BTN )
		    FIfld_set_text( VD_FP, FI_MSG_FIELD, 0, 0,
			"Previous column too large to fit on form", FALSE );
		else
		    FIfld_set_text( VD_FP, FI_MSG_FIELD, 0, 0,
			"Next column too large to fit on form", FALSE );
		*msg = MSFAIL;
	    }

	    break;

	default :
	    __DBGpr_com( "Unknown gadget label" );
	    break;
	}

    End
    return OM_S_SUCCESS;
}

end implementation VDCmdCrTbl;
