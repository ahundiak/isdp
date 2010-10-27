/* $Id: VDtblCpMv.I,v 1.1.1.1 2001/01/04 21:09:26 cvs Exp $ */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vds/vdtbl/cmd / VDtblUpdCol.I
 *
 * Description:
 *	Implementation of the following methods for VDCmdCrTbl :
 *		VDcopyColumn
 *		VDmoveRows
 *
 * Dependencies:
 *
 * History:
 *
 *      04/14/95        R. Manem        Creation
 *      04/20/95        R. Manem        Fixed bug in row move
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

#include "emsdef.h"
#include "EMSutlmacros.h"

#include "VDdrwlo.h"
#include "VDdrwlo_pr.h"
#include "VDdrwtbl.h"
#include "VDtblCmdDef.h"

#include "VDCmdDef.h"
#include "FI.h"
#include "FEI.h"

/*+me
 ---------------------------------------------------------------------------
  Public Message VDcopyColumn

  Abstract
        This method copies a column from one mcf to another.  It also updates
	the flag for the rows if required.

  Arguments
        IGRlong         *sts            O       Return code
	IGRint		fromMcf		I	Gadget label for source column
	IGRint		toMcf		I	Gadget label for dest col
	IGRint		srcCol		I	Source column index
	IGRint		destCol		I	Dest column index
	IGRint		updFlag		I	Update Flag : if 1, check
						for changes, and update the
						corresponding row flag.
						if 0, ignore changes.
  Status/Return Code
      status == OM_S_SUCCESS
 ---------------------------------------------------------------------------
-me*/

method	VDcopyColumn(	IGRlong		*msg;
			IGRint		fromMcf;
			IGRint		toMcf;
			IGRint		srcCol;
			IGRint		destCol;
			IGRint		updFlag )
{
    IGRint	i,
		sel, pos,
		len = 0,
		rowNo,
		maxSrcLen = 0, 
		maxDstLen = 0,
		nbRows;
    IGRchar	*srcBuf = NULL,
		*dstBuf = NULL;
    IGRlong	status = OM_S_SUCCESS;

    SetProc( VDCmdCrTbl.VDcopyColumn ); Begin

    *msg = MSSUCC;

#ifdef vdsDEBUG
    printf( "\t\tfromMcf = %d, toMcf = %d, srcCol = %d, destCol = %d\n",
			fromMcf, toMcf, srcCol, destCol );
#endif

    FIfld_get_num_rows( VD_FP, fromMcf, &nbRows );
    __DBGpr_int( "Number of rows", nbRows );

    if( !nbRows )
	goto wrapup;

    FIfld_set_num_rows( VD_FP, toMcf, nbRows );

    /* compute max text length for src column */

    for( i = 0 ; i < nbRows ; i++ )
    {
	FIfld_get_text_length( VD_FP, fromMcf, i, srcCol, &len );
	if( len > maxSrcLen )
	    maxSrcLen = len;
    }

    __DBGpr_int( "\n\tMaxSrcLen ", maxSrcLen );

    /* allocate space for src buffer */

    srcBuf = _MALLOC( maxSrcLen, IGRchar );
    if( !srcBuf )
	vd_$mem_fail( sts = status );
	
    /* compute max text length for dest column only if updFlag is TRUE */

    if( updFlag )
    {
    	for( i = 0 ; i < nbRows ; i++ )
    	{
	    FIfld_get_text_length( VD_FP, toMcf, i, destCol, &len );
	    if( len > maxDstLen )
	        maxDstLen = len;
        }

        __DBGpr_int( "\n\tMaxDstLen ", maxDstLen );

        /* allocate space for dest buffer  */

        dstBuf = _MALLOC( maxDstLen, IGRchar );
        if( !dstBuf )
	    vd_$mem_fail( sts = status );
    }

    for( i = 0 ; i < nbRows ; i++ )
    {
	srcBuf[0] = '\0';
	FIfld_get_text( VD_FP, fromMcf, i, srcCol, maxSrcLen, 
				(unsigned char *)srcBuf, &sel, &pos );

#ifdef vdsDEBUG
    printf("\t\t# %d : text = %s\n", i, srcBuf );
#endif

	/* 
	 * if we need to update the instance data when data has 
	 * been modified , then we should get the value from the dest column 
	 * and compare the two
	 */

	rowNo = i / me->maxLinesPerRow;
	__DBGpr_int( "Row number ", rowNo );

	if( updFlag && me->rows[rowNo].flag == VD_DRW_ROW_OLD )
	{
	    dstBuf[0] = '\0';
	    FIfld_get_text( VD_FP, toMcf, i, destCol, maxDstLen, 
				(unsigned char *)dstBuf, &sel, &pos );
	    __DBGpr_str( "Destbuf value ", dstBuf );

	    /* update flag if values are different */

	    if( strcmp( dstBuf, srcBuf ) )
		me->rows[rowNo].flag = VD_DRW_ROW_MOD;
	}

	/* set text in destination column */

	FIfld_set_text( VD_FP, toMcf, i, destCol, srcBuf, FALSE );
    }

wrapup :

    _FREE( srcBuf );
    _FREE( dstBuf );
    End
    return status;
}

/*+me
 ---------------------------------------------------------------------------
  Public Message VDmoveRows

  Abstract
        This method moves a block of rows.

  Arguments
        IGRlong         *sts            O       Return code
        IGRint          blkStart        I       Starting row number of block
						to move
        IGRint          blkEnd          I       Ending row number of block

  Status/Return Code
      status == OM_S_SUCCESS
 ---------------------------------------------------------------------------
-me*/

method  VDmoveRows(     IGRlong         *msg;
                        IGRint          stepSize;
                        IGRint          blkStart;
                        IGRint          blkEnd )
{
    IGRint			i, j,
				retCode,
				nb, step,
				nbLines,
				insRowPos,
				endLine, startLine,
				sel, pos,
				ind, curInd,
				len, maxLen = 0,
				nbRows, nbObjs,
				nbVisCols, nbInvCols;
    IGRlong			status = OM_S_SUCCESS;
    IGRchar			*buf = NULL,
				info[50];
    struct VDdrw_rowInfo	*tmpRowBuf = NULL;
    struct GRobj_env		*tmpObjBuf = NULL;

    SetProc( VDCmdCrTbl.VDmoveRows ); Begin

    *msg = MSSUCC;

    __DBGpr_int( "Block Start", blkStart );
    __DBGpr_int( "Block End", blkEnd );
    __DBGpr_int( "Step size", stepSize );

    /* get the total number of rows */

    nbRows = om$dimension_of( varray = me->rows );
    __DBGpr_int( "Total Number of rows", nbRows );

    nbLines = nbRows * me->maxLinesPerRow;
    __DBGpr_int( "Number of lines", nbLines );

    FIfld_set_num_rows( VD_FP, VD_TBL_VIS_COLDISP_FLD, nbLines );
    FIfld_set_num_rows( VD_FP, VD_TBL_INV_COLDISP_FLD, nbLines );

    /* validate block limits */

    if( blkStart < 0 || blkStart >= nbRows || 
		blkEnd < 0 || blkEnd >= nbRows || blkStart > blkEnd )
    {
	FIfld_set_text( VD_FP, FI_MSG_FIELD, 0, 0, "Invalid block limits", 
							FALSE );
	goto wrapup;
    }

    /* validate stepSize */

    if( !stepSize )
    {
	FIfld_set_text( VD_FP, FI_MSG_FIELD, 0, 0, "step size is 0", FALSE );
	goto wrapup;
    }

    if( stepSize > 0 && stepSize > (nbRows-1 - blkEnd))
    {
	stepSize = nbRows - 1 - blkEnd;
	__DBGpr_int( "Changing step size to ", stepSize );
    }
    else if( stepSize < 0 && -stepSize > blkStart )
    {
	stepSize = -blkStart;
	__DBGpr_int( "Changing step size to ", stepSize );
    }

    if( !stepSize )
    {
	FIfld_set_text( VD_FP, FI_MSG_FIELD, 0, 0, "Cannot move further", 
							FALSE );
	goto wrapup;
    }

    
    /* if block move, confirm */
 
    FIg_get_state( VD_FP, VD_TBL_MOVE_TYPE_BTN, &sel );
    __DBGpr_int( "Select state of MOVE type btn ", sel );

    if( sel )
    {
	sprintf( info, "Move block (%d - %d)?", blkStart+1, blkEnd+1 );

	retCode = GRconfirm_box( info );
	if( !retCode )
	    goto wrapup;
    }

    startLine = blkStart * me->maxLinesPerRow;
    endLine = (blkEnd * me->maxLinesPerRow) + me->maxLinesPerRow - 1;
    __DBGpr_int( "Starting line number", startLine );
    __DBGpr_int( "Ending line number", endLine );

    /* get number of columns in both vis and invis mcfs */

    FImcf_get_num_cols( VD_FP, VD_TBL_INV_COLDISP_FLD, &nbInvCols );
    FImcf_get_num_cols( VD_FP, VD_TBL_VIS_COLDISP_FLD, &nbVisCols );

    __DBGpr_int( "Number of inv columns", nbInvCols );
    __DBGpr_int( "Number of vis columns", nbVisCols );

    /* compute max length of buffer needed */

    for( i = 0 ; i < nbInvCols ; i++ )
	for( j = startLine ; j <= endLine ; j++ )
	{
	    FIfld_get_text_length( VD_FP, VD_TBL_INV_COLDISP_FLD, j, i, &len );
	    if( len > maxLen )
		maxLen = len;
	}
    
    for( i = 0 ; i < nbVisCols ; i++ )
	for( j = startLine ; j <= endLine ; j++ )
	{
	    FIfld_get_text_length( VD_FP, VD_TBL_VIS_COLDISP_FLD, j, i, &len );
	    if( len > maxLen )
		maxLen = len;
	}

    __DBGpr_int( "Maximum length of text", maxLen );

    /* set up buffer */

    buf = _MALLOC( maxLen, IGRchar );
    if( !buf )
	vd_$mem_fail( sts = status );

    /* move rows in both visible and invisible data columns */

    step = stepSize * me->maxLinesPerRow;
    __DBGpr_int( "step ", step );

    if( step < 0 )
    {
        for( i = startLine ; i <= endLine ; i++ )
        {
	    insRowPos = i+step;

	    __DBGpr_int( "Value of i", i );
	    __DBGpr_int( "Inserting blank row at", insRowPos );

	    /* invisible column display */

	    FIfld_insert_blank_row( VD_FP, VD_TBL_INV_COLDISP_FLD, insRowPos );
	    for( j = 1 ; j < nbInvCols ; j++ )
	    {
		FIfld_get_text( VD_FP, VD_TBL_INV_COLDISP_FLD, i+1, j, maxLen, 
					(unsigned char *)buf, &sel, &pos );
		__DBGpr_str( "Text ", buf );
		FIfld_set_text( VD_FP, VD_TBL_INV_COLDISP_FLD, insRowPos, j,
						buf, FALSE );
	    }

	    FIfld_set_active_row( VD_FP, VD_TBL_INV_COLDISP_FLD, insRowPos, 0);

	    __DBGpr_int( "Deleting line ", i+1 );

	    FIfld_delete_rows( VD_FP, VD_TBL_INV_COLDISP_FLD, i+1, 1 );

	    /* visible column display */

	    FIfld_insert_blank_row( VD_FP, VD_TBL_VIS_COLDISP_FLD, insRowPos );
	    for( j = 1 ; j < nbVisCols ; j++ )
	    {
		FIfld_get_text( VD_FP, VD_TBL_VIS_COLDISP_FLD, i+1, j, maxLen, 
					(unsigned char *)buf, &sel, &pos );
		__DBGpr_str( "Text ", buf );
		FIfld_set_text( VD_FP, VD_TBL_VIS_COLDISP_FLD, insRowPos, j,
						buf, FALSE );
	    }

	    /* 
	     * the newly inserted row will not be deleted 
	     * if we delete the active row, then the forms system crashes.
	     */
	    FIfld_set_active_row( VD_FP, VD_TBL_VIS_COLDISP_FLD, insRowPos, 0);

	    __DBGpr_int( "Deleting line ", i+1 );

	    FIfld_delete_rows( VD_FP, VD_TBL_VIS_COLDISP_FLD, i+1, 1 );
	}
    }
    else
    {
        for( i = endLine ; i >= startLine ; i-- )
        {
	    /* invisible column display */

	    insRowPos = i+step+1;

	    __DBGpr_int( "Value of i", i );
	    __DBGpr_int( "Inserting blank row at", insRowPos );

	    if( insRowPos == nbLines )
		FIfld_set_num_rows( VD_FP, VD_TBL_INV_COLDISP_FLD, nbLines+1 );
	    else
	        FIfld_insert_blank_row( VD_FP, VD_TBL_INV_COLDISP_FLD, 
								insRowPos );
	    for( j = 1 ; j < nbInvCols ; j++ )
	    {
		FIfld_get_text( VD_FP, VD_TBL_INV_COLDISP_FLD, i, j, maxLen, 
					(unsigned char *)buf, &sel, &pos );
		__DBGpr_str( "Text ", buf );
		FIfld_set_text( VD_FP, VD_TBL_INV_COLDISP_FLD, insRowPos, j,
							buf, FALSE );
	    }

	    FIfld_set_active_row( VD_FP, VD_TBL_INV_COLDISP_FLD, 
						insRowPos, 0);

	    __DBGpr_int( "Deleting line ", i );

	    FIfld_delete_rows( VD_FP, VD_TBL_INV_COLDISP_FLD, i, 1 );

	    /* visible column display */

	    if( insRowPos == nbLines )
		FIfld_set_num_rows( VD_FP, VD_TBL_VIS_COLDISP_FLD, nbLines+1 );
	    else
	        FIfld_insert_blank_row( VD_FP, VD_TBL_VIS_COLDISP_FLD, 
								insRowPos );
	    for( j = 1 ; j < nbVisCols ; j++ )
	    {
		FIfld_get_text( VD_FP, VD_TBL_VIS_COLDISP_FLD, i, j, maxLen, 
					(unsigned char *)buf, &sel, &pos );
		__DBGpr_str( "Text ", buf );
		FIfld_set_text( VD_FP, VD_TBL_VIS_COLDISP_FLD, insRowPos, j,
							buf, FALSE );
	    }

	    FIfld_set_active_row( VD_FP, VD_TBL_VIS_COLDISP_FLD, 
						insRowPos, 0);

	    __DBGpr_int( "Deleting line ", i );

	    FIfld_delete_rows( VD_FP, VD_TBL_VIS_COLDISP_FLD, i, 1 );

	}
    }

    /* move the elements in me->rows vla */

#ifdef vdsDEBUG
    printf( "\n\tInitial list of me->rows vla :\n");
    for( i = 0 ; i < nbRows ; i++ )
	printf( "\t\tstartIndex = %d, nbObjs = %d\n", me->rows[i].startIndex,
							me->rows[i].nbObjs );
#endif

    tmpRowBuf = _MALLOC( blkEnd - blkStart + 1, struct VDdrw_rowInfo );
    if( !tmpRowBuf )
    {
	status = OM_E_NODYNMEM;
	goto wrapup;
    }

    /* store the rows to be moved */

    for( i = blkStart, j = 0 ; i <= blkEnd ; i++, j++ )
	tmpRowBuf[j] = me->rows[i];
    
    /* move the appropriate rows */

    if( stepSize < 0 )
	for( i = blkStart-1 ; i >= blkStart+stepSize ; i-- )
	    me->rows[i+(blkEnd-blkStart+1)] = me->rows[i];
    else
	for( i = blkEnd+1 ; i <= blkEnd+stepSize ; i++ )
	    me->rows[i-(blkEnd-blkStart+1)] = me->rows[i];

    /* store the rows to be moved in the correct locations */

    for( i = blkStart, j = 0 ; i <= blkEnd ; i++, j++ )
	me->rows[i+stepSize] = tmpRowBuf[j];

#ifdef vdsDEBUG
    printf( "\n\tFinal list of me->rows vla :\n");
    for( i = 0 ; i < nbRows ; i++ )
	printf( "\t\tstartIndex = %d, nbObjs = %d\n", me->rows[i].startIndex,
							me->rows[i].nbObjs );
#endif

    /* update the me->locObjs vla */

    nbObjs = om$dimension_of( varray = me->locObjs );
    __DBGpr_int( "Number of objects", nbObjs );

#ifdef vdsDEBUG
    printf( "\n\tOriginal list of objects \n");
    for( i = 0 ; i < nbObjs ; i++ )
	printf("\t\tObj[%d] = [%d, %d]\n", i, me->locObjs[i].obj_id.objid,
					   me->locObjs[i].obj_id.osnum );
#endif

    if( nbObjs )
    {
	tmpObjBuf = _MALLOC( nbObjs, struct GRobj_env );
    	if( !tmpObjBuf )
    	{
	    status = OM_E_NODYNMEM;
	    goto wrapup;
    	}

        for( i = 0 ; i < nbObjs ; i++ )
	    tmpObjBuf[i] = me->locObjs[i];
    
        curInd = 0;
        for( i = 0 ; i < nbRows ; i++ )
        {
	    ind = me->rows[i].startIndex;
	    nb = me->rows[i].nbObjs;
	    for( j = ind ; j < ind + nb ; j++ )
	        me->locObjs[curInd++] = tmpObjBuf[j];
        }
    }

#ifdef vdsDEBUG
    printf( "\n\tFinal list of objects \n");
    for( i = 0 ; i < nbObjs ; i++ )
	printf("\t\tObj[%d] = [%d, %d]\n", i, me->locObjs[i].obj_id.objid,
					   me->locObjs[i].obj_id.osnum );
#endif

    /* correct the startIndex in me->rows */

    me->rows[0].startIndex = 0;
    for( i = 1 ; i < nbRows ; i++ )
	me->rows[i].startIndex = me->rows[i-1].startIndex + 
							me->rows[i-1].nbObjs;

    /* update 1st column */

    status =
    _VD_SEND_MY( VDCmdCrTbl.VDupdate1stCol( msg ) );
    CheckRC( status, *msg );

wrapup :

    _FREE( buf );
    _FREE( tmpRowBuf );
    _FREE( tmpObjBuf );

    End
    return status;
}

end implementation VDCmdCrTbl;
