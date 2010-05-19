/* $Id: VDtblUpdRow.I,v 1.1.1.1 2001/01/04 21:09:27 cvs Exp $ */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vds/vdtbl/cmd / VDtblUpdRow.I
 *
 * Description:
 *	Implementation of the following method for VDCmdCrTbl :
 *		VDupdateRow
 *		VDupdateOrgRowValues
 *		VDshowRowContents
 *
 * Dependencies:
 *
 * History:
 *
 *      04/14/95        R. Manem        Creation
 *      04/24/95        R. Manem        Added VDupdateOrgRowValues and
 *					VDshowRowContents methods
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
#include "exproto.h"

#include "v_miscmacros.h"
#include "v_dbgmacros.h"
#include "v_datamacros.h"

#include "VDdrwlo.h"
#include "VDdrwlo_pr.h"
#include "VDdrwtbl.h"
#include "VDtblCmdDef.h"

#include "VDCmdDef.h"
#include "FI.h"
#include "FEI.h"

/*+me
 ---------------------------------------------------------------------------
  Public Message VDupdateRow

  Abstract
        This method updates the given row in both vis and inv mcfs

  Arguments
        IGRlong         *sts            O       Return code
	IGRint		rowNo		I	Row number to update

  Notes/Remarks

  Status/Return Code
      status == OM_S_SUCCESS

 ---------------------------------------------------------------------------
-me*/

method  VDupdateRow(	IGRlong 	*msg; 
			IGRint		rowNo )
{
    IGRint			i, j,
				row, col,
				lineNo,
				nbCols,
				nbFixRecs, nbDatRecs,
				objIndex;
    IGRlong			status = OM_S_SUCCESS;
    IGRchar			*fldVal = NULL;

    SetProc( VDCmdCrTbl.VDupdateRow ); Begin
    *msg = MSSUCC;

    lineNo = rowNo * me->maxLinesPerRow;
    __DBGpr_int( "Starting line number", lineNo );

    /* initialize to NULL the texts */

    FImcf_get_num_cols( VD_FP, VD_TBL_INV_COLDISP_FLD, &nbCols );
    __DBGpr_int( "Number of inv cols", nbCols );

    for( i = lineNo ; i < lineNo+me->maxLinesPerRow ; i++ )
	for( j = 0 ; j < nbCols ; j++ )
	    FIfld_set_text( VD_FP, VD_TBL_INV_COLDISP_FLD, i, j, "", FALSE );

    FImcf_get_num_cols( VD_FP, VD_TBL_VIS_COLDISP_FLD, &nbCols );
    __DBGpr_int( "Number of vis cols", nbCols );

    for( i = lineNo ; i < lineNo+me->maxLinesPerRow ; i++ )
	for( j = 0 ; j < nbCols ; j++ )
	    FIfld_set_text( VD_FP, VD_TBL_VIS_COLDISP_FLD, i, j, "", FALSE );

    nbFixRecs = om$dimension_of( varray = me->fixRecs );
    nbDatRecs = om$dimension_of( varray = me->datRecs );

    __DBGpr_int( "Number of selected columns", me->nbSelCols );

    /* update fixed texts in the vis and inv mcfs */

    __DBGpr_com( "\n\tUpdating fixed texts" );

    for( i = 0 ; i < nbFixRecs ; i++ )
    {
	col = me->fixRecs[i].VD.tx.colno;
	row = me->fixRecs[i].VD.tx.lineno + lineNo - 1;
	__DBGpr_int( "col number", col );
	__DBGpr_int( "row number", row );

	FIfld_set_text( VD_FP, VD_TBL_INV_COLDISP_FLD, row, col,
			(unsigned char *)me->fixRecs[i].VD.tx.Text, FALSE );

	for( j = 0 ; j < me->nbSelCols ; j++ )
	    if( me->selColList[j] == col )
		break;

	if( j != me->nbSelCols )
	{
	    __DBGpr_int( "Updating vis col ", j+1 );

	    FIfld_set_text( VD_FP, VD_TBL_VIS_COLDISP_FLD, row, j+1,
			    (unsigned char *)me->fixRecs[i].VD.tx.Text, FALSE );
	}
    }

    objIndex = me->rows[rowNo].startIndex;

    __DBGpr_int( "Row no", rowNo );
    __DBGpr_int( "Number of objs", me->rows[rowNo].nbObjs );

    /* update variable components in vis and inv mcfs */

    __DBGpr_com( "\n\tUpdating variable components" );

    for( i = 0 ; i < nbDatRecs ; i++ )
    {
	col = me->datRecs[i].colno;
	row = me->datRecs[i].lineno + lineNo - 1;

	_FREE( fldVal );
	fldVal = NULL;

	status = VDdrw_getFldValue(	msg,
					me->rows[rowNo].nbObjs,
					&me->locObjs[objIndex],
					me->datRecs[i],
					me->rows[rowNo].qty,
					NULL,
					&fldVal );
	CheckRC( status, *msg );

	if( !fldVal )
	    continue;

	__DBGpr_str( "Field Value ", fldVal );

	FIfld_set_text( VD_FP, VD_TBL_INV_COLDISP_FLD, row, col, 
				(unsigned char *)fldVal, FALSE );

	for( j = 0 ; j < me->nbSelCols ; j++ )
	    if( me->selColList[j] == col )
		break;

	if( j != me->nbSelCols )
	{
	    __DBGpr_int( "Updating vis col ", j+1 );

	    FIfld_set_text( VD_FP, VD_TBL_VIS_COLDISP_FLD, row, j+1, 
				(unsigned char *)fldVal, FALSE );
	}
    }

    _FREE( fldVal );

    End
    return status;
}

/*+me
 ---------------------------------------------------------------------------
  Public Message VDupdateOrgRowValues

  Abstract
        This method updates the original row values in the
        VD_TBL_REV_ROWVALS_FLD

  Arguments
        IGRlong         *sts            O       Return code
        IGRint          rowNo           I       Row number  whose values are
                                                to be shown

  Notes/Remarks

  Status/Return Code
      status == OM_S_SUCCESS

 ---------------------------------------------------------------------------
-me*/

method  VDupdateOrgRowValues(   IGRlong         *msg;
                                IGRint          rowNo )
{
    IGRint			i, j,
				row, col,
				objIndex, 
				nbFixRecs, nbDatRecs;
    IGRlong			status = OM_S_SUCCESS;
    IGRchar			*fldVal = NULL;
    struct GRid			*rowId = NULL;

    SetProc( VDCmdCrTbl.VDupdateOrgRowValues ); Begin
    *msg = MSSUCC;

    __DBGpr_int( "Row no", rowNo );

    nbFixRecs = om$dimension_of( varray = me->fixRecs );
    nbDatRecs = om$dimension_of( varray = me->datRecs );

    __DBGpr_int( "Number of fixed records", nbFixRecs );
    __DBGpr_int( "Number of data records", nbDatRecs );
    __DBGpr_int( "Number of selected columns", me->nbSelCols );

    objIndex = me->rows[rowNo].startIndex;

    __DBGpr_int( "Object index ", objIndex );

#ifdef vdsDEBUG
    printf("\n\tList of objects\n" );
    for( i = 0 ; i < me->rows[rowNo].nbObjs ; i++ )
	printf( "\t\t# %d : [%d, %d]\n", i,
					 me->locObjs[objIndex+i].obj_id.objid,
					 me->locObjs[objIndex+i].obj_id.osnum );
#endif

    /* update row number */

    FIfld_set_value( VD_FP, VD_TBL_REV_ROWVALS_FLD, 0, 0, (double)(rowNo+1), 
								FALSE );

    /* update fixed texts */

    for( i = 0 ; i < nbFixRecs ; i++ )
    {
	col = me->fixRecs[i].VD.tx.colno;
	row = me->fixRecs[i].VD.tx.lineno - 1;
	__DBGpr_int( "col number", col );
	__DBGpr_int( "row number", row );

	for( j = 0 ; j < me->nbSelCols ; j++ )
	    if( me->selColList[j] == col )
		break;

	if( j != me->nbSelCols )
	{
	    __DBGpr_int( "Updating col ", j+1 );

	    FIfld_set_text( VD_FP, VD_TBL_REV_ROWVALS_FLD, row, j+1,
			    (unsigned char *)me->fixRecs[i].VD.tx.Text, FALSE );
	}
    }

    /* update variable components */

    __DBGpr_com( "\n\tUpdating variable components" );

    for( i = 0 ; i < nbDatRecs ; i++ )
    {
	col = me->datRecs[i].colno;
	row = me->datRecs[i].lineno - 1;

	for( j = 0 ; j < me->nbSelCols ; j++ )
	    if( me->selColList[j] == col )
		break;

	if( j != me->nbSelCols )
	{
	    __DBGpr_int( "Updating col ", j+1 );

	    _FREE( fldVal );
	    fldVal = NULL;

            __DBGpr_int( "Number of objs", me->rows[rowNo].nbObjs );
    
            rowId = NULL;
            if( me->rows[rowNo].rowId.objid != NULL_OBJID )
                rowId = &me->rows[rowNo].rowId;

	    status = VDdrw_getFldValue(	msg,
					me->rows[rowNo].nbObjs,
					&me->locObjs[objIndex],
					me->datRecs[i],
					me->rows[rowNo].qty,
					rowId,
					&fldVal );
	    CheckRC( status, *msg );

	    if( !fldVal )
	        continue;

	    __DBGpr_str( "Field Value ", fldVal );

	    FIfld_set_text( VD_FP, VD_TBL_REV_ROWVALS_FLD, row, j+1, 
				(unsigned char *)fldVal, FALSE );
	}
    }

    _FREE( fldVal );
    End
    return status;
}

/*+me
 ---------------------------------------------------------------------------
  Public Message VDshowRowContents

  Abstract
        This method expands a row, to show its default values in the
        VD_TBL_ROWCNTS_FLD

  Arguments
        IGRlong         *sts            O       Return code
        IGRint          rowNo           I       Row number  whose values are
                                                to be shown

  Notes/Remarks

  Status/Return Code
      status == OM_S_SUCCESS

 ---------------------------------------------------------------------------
-me*/

method  VDshowRowContents(      IGRlong         *msg;
                                IGRint          rowNo )
{
    IGRint			i, j,
				nbLines,
				row, col,
				sel, pos,
				attrMask,
				nbCols,
				nbObjs, objIndex,
				nbFixRecs, nbDatRecs;
    IGRlong			status = OM_S_SUCCESS;
    IGRdouble			width;
    IGRchar			*fldVal = NULL;

    SetProc( VDCmdCrTbl.VDshowRowContents ); Begin
    *msg = MSSUCC;

    __DBGpr_int( "Row no", rowNo );

    /* delete existing columns */

    FImcf_get_num_cols( VD_FP, VD_TBL_ROW_CNTS_FLD, &nbCols );
    __DBGpr_int( "Number of columns", nbCols );

    for( i = nbCols-1 ; i > 0 ; i-- )
	FImcf_delete_col( VD_FP, VD_TBL_ROW_CNTS_FLD, i );

    __DBGpr_int( "Number of selected columns", me->nbSelCols );

    /* add appropriate columns */

    for( i = 0 ; i < me->nbSelCols ; i++ )
    {
	/* width of column */

	FIfld_get_value( VD_FP, VD_TBL_SELCOL_LIST_FLD, me->selColList[i]-1,
				2, &width, &sel, &pos );

	FImcf_insert_col( VD_FP, VD_TBL_ROW_CNTS_FLD, i+1, (int)width,
					FI_REVIEW, FI_ALPHA );
	FIg_activate( VD_FP, VD_TBL_ROW_CNTS_FLD );
	FIfld_set_num_vis_chars( VD_FP, VD_TBL_ROW_CNTS_FLD, i+1, (int)width );

	FIfld_get_attr( VD_FP, VD_TBL_ROW_CNTS_FLD, i+1, &attrMask );
	attrMask = attrMask | FI_HORT_SCROLL | FI_DISPLAY_HSCROLL;
	FIfld_set_attr( VD_FP, VD_TBL_ROW_CNTS_FLD, i+1, attrMask );
    }

    FImcf_set_num_vis_cols( VD_FP, VD_TBL_ROW_CNTS_FLD, me->nbSelCols + 1 );
    FIg_activate( VD_FP, VD_TBL_ROW_CNTS_FLD );
    FIg_display( VD_FP, VD_TBL_ROW_CNTS_FLD );

    nbFixRecs = om$dimension_of( varray = me->fixRecs );
    nbDatRecs = om$dimension_of( varray = me->datRecs );

    __DBGpr_int( "Number of fixed records", nbFixRecs );
    __DBGpr_int( "Number of data records", nbDatRecs );

    nbObjs = me->rows[rowNo].nbObjs;
    nbLines = nbObjs * me->maxLinesPerRow;
    objIndex = me->rows[rowNo].startIndex;
    __DBGpr_int( "Number of objects", nbObjs );
    __DBGpr_int( "object index", objIndex );
    __DBGpr_int( "Number of lines", nbLines );

    /* set number of lines */

    FIfld_set_num_rows( VD_FP, VD_TBL_ROW_CNTS_FLD, nbLines );

    /* update the serial number column */

    for( i = 0 ; i < nbObjs ; i++ )
	FIfld_set_value( VD_FP, VD_TBL_ROW_CNTS_FLD, i*me->maxLinesPerRow, 0,
						(double)(i+1), FALSE );

    /* update fixed texts */

    for( i = 0 ; i < nbFixRecs ; i++ )
    {
	col = me->fixRecs[i].VD.tx.colno;
	__DBGpr_int( "col number", col );

	for( j = 0 ; j < me->nbSelCols ; j++ )
	    if( me->selColList[j] == col )
		break;

	if( j != me->nbSelCols )
	{
	    col = j+1;
	    __DBGpr_int( "Updating col ", col );

	    for( j = 0 ; j < nbObjs ; j++ )
	    {
	        row = (j*me->maxLinesPerRow) + me->fixRecs[i].VD.tx.lineno - 1;
	        __DBGpr_int( "row number", row );

	        FIfld_set_text( VD_FP, VD_TBL_ROW_CNTS_FLD, row, col,
			    (unsigned char *)me->fixRecs[i].VD.tx.Text, FALSE );
	    }
	}
    }

    /* update variable components */

    __DBGpr_com( "\n\tUpdating variable components" );

    for( i = 0 ; i < nbDatRecs ; i++ )
    {
	col = me->datRecs[i].colno;

	for( j = 0 ; j < me->nbSelCols ; j++ )
	    if( me->selColList[j] == col )
		break;

	if( j != me->nbSelCols )
	{
	    col = j+1;
	    __DBGpr_int( "Updating col ", col );

	    for( j = 0 ; j < nbObjs ; j++ )
	    {
	        row = (j*me->maxLinesPerRow) + me->datRecs[i].lineno - 1;
		__DBGpr_int( "Row number", row );

	        _FREE( fldVal );
	        fldVal = NULL;

	        status = VDdrw_getFldValue(	msg,
						1,
						&me->locObjs[objIndex+j],
						me->datRecs[i],
						me->rows[rowNo].qty,
						NULL,
						&fldVal );
	    	CheckRC( status, *msg );

	        if( !fldVal )
	            continue;

	        __DBGpr_str( "Field Value ", fldVal );

	        FIfld_set_text( VD_FP, VD_TBL_ROW_CNTS_FLD, row, col, 
				(unsigned char *)fldVal, FALSE );
	    }
	}
    }

    _FREE( fldVal );
    End
    return status;
}

end implementation VDCmdCrTbl;
