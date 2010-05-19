/* $Id: VDtblSumItm.I,v 1.3 2001/11/28 21:43:04 ylong Exp $ */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vds/vdtbl/cmd / VDtblSumItm.I
 *
 * Description:
 *	Implementation of the following methods for VDCmdCrTbl :
 *		VDsummarizeRows
 *		VDitemizeRow
 *		summ_and_sort_objs
 *
 * Dependencies:
 *
 * History:
 *
 *      04/14/95        R. Manem        Creation
 *      05/15/95        R. Manem        Added summ_and_sort_objs method
 *      06/16/95        R. Manem        Retain user-defined entries in first
 *					of summarized rows
 *      07/14/95        R. Manem        Summarizing and sorting
 *      08/15/95        R. Manem        Fixed TR on item number uniformity
 *					while summarizing rows, during
 *					Create and Modify Table
 *      09/22/95        R. Manem        Included qty in VDsortinfo structure
 *      11/19/99        ylong	        TR179900885 whenever user adds new objs
 *					to table, all objs are sorted together
 *					and refilled into the table.
 * 	03/17/00	Ming		TR179901201
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

from VDdrwTblRow        import  VDisRowLinedOut;

/*+me
 ---------------------------------------------------------------------------
  Public Message VDsummarizeRows

  Abstract
        This method gets the list of selected rows from the form and
	summarizes them

  Arguments
        IGRlong         *sts            O       Return code

  Notes/Remarks

  Status/Return Code
      status == OM_S_SUCCESS

 ---------------------------------------------------------------------------
-me*/

method  VDsummarizeRows( IGRlong 	*msg  )
{
    IGRint		i, j,
			row, col,
			curInd,
			count,
			nbObjs,
			objIndex,
			nbSumObjs, nbDatRecs,
			nbRows, rowNo,
			nbLines,
			first = 0, last = 0,
			firstObjInd, lastObjInd,
			firstRow, lastRow,
			sel, pos;
    IGRlong		status = OM_S_SUCCESS;
    IGRchar		buf[10],
			*fldVal = NULL;
    struct GRobj_env	*tmpObjBuf = NULL;

    SetProc( VDCmdCrTbl.VDsummarizeRows ); Begin
    *msg = MSSUCC;

    nbRows = om$dimension_of( varray = me->rows );
    nbLines = nbRows * me->maxLinesPerRow;
    __DBGpr_int( "Number of Rows", nbRows );


#ifdef vdsDEBUG
    printf( "\n\tInitial list of me->rows vla :\n");
    for( i = 0 ; i < nbRows ; i++ )
        printf( "\t\tstartIndex = %d, nbObjs = %d\n", me->rows[i].startIndex,
                                                        me->rows[i].nbObjs );
#endif

    /* get the first selected row */

    for( i = 0 ; i < nbLines ; i=i+me->maxLinesPerRow )
    {
	FIfld_get_text( VD_FP, VD_TBL_VIS_COLDISP_FLD, i, 0, 10, 
					(unsigned char *)buf, &sel, &pos );
	if( sel )
	{
	    __DBGpr_int( "First Line selected ", i );
	    first = i;
	    break;
	}
    }

    /* get the last selected row */

    for( i = nbLines-me->maxLinesPerRow ; i > first ; i=i-me->maxLinesPerRow )
    {
	FIfld_get_text( VD_FP, VD_TBL_VIS_COLDISP_FLD, i, 0, 10, 
					(unsigned char *)buf, &sel, &pos );
	if( sel )
	{
	    __DBGpr_int( "Last Line selected ", i );
	    last = i;
	    break;
	}
    }

    /* copy appropriate list of objects in temp buffer */

    firstRow = first / me->maxLinesPerRow;
    lastRow = last / me->maxLinesPerRow;
    firstObjInd = me->rows[firstRow+1].startIndex;
    lastObjInd = me->rows[lastRow].startIndex + me->rows[lastRow].nbObjs;

    __DBGpr_int( "First object index", firstObjInd );
    __DBGpr_int( "Last object index", lastObjInd );
    __DBGpr_int( "First row number", firstRow );
    __DBGpr_int( "Last row number", lastRow );

    tmpObjBuf = _MALLOC( lastObjInd - firstObjInd, struct GRobj_env );

    if( !tmpObjBuf )
    {
	status = OM_E_NODYNMEM;
	goto wrapup;
    }

    for( i = firstObjInd ; i < lastObjInd ; i++ )
	tmpObjBuf[i-firstObjInd] = me->locObjs[i];

    nbObjs = om$dimension_of( varray = me->locObjs );
    __DBGpr_int( "Number of located objects", nbObjs );

#ifdef vdsDEBUG
    printf("\n\n\tInitial list of objects\n");
    for( i = 0 ; i < nbObjs ; i++ )
	printf("\t\tObj # %d = [%d, %d]\n", i, me->locObjs[i].obj_id.objid,
						me->locObjs[i].obj_id.osnum );

    printf("\n\tList of tmp Buf objects\n");
    for( i = 0 ; i < lastObjInd-firstObjInd ; i++ )
	printf("\t\tObj # %d = [%d, %d]\n", i, tmpObjBuf[i].obj_id.objid,
						tmpObjBuf[i].obj_id.osnum );
#endif

    /* update the list of located objects */

    curInd = firstObjInd;

    /* copy selected row objects */

    for( i = first+me->maxLinesPerRow ; i <= last ; i=i+me->maxLinesPerRow )
    {
	FIfld_get_text( VD_FP, VD_TBL_VIS_COLDISP_FLD, i, 0, 10, buf, 
							&sel, &pos );
	if( sel )
	{
	    rowNo = i / me->maxLinesPerRow;
	    __DBGpr_int( "Row number to collapse", rowNo );

	   for( j = 0 ; j < me->rows[rowNo].nbObjs ; j++ )
	    {
		__DBGpr_int( "Current index", curInd );
		__DBGpr_int( "Target index", 
			j + me->rows[rowNo].startIndex - firstObjInd );
		me->locObjs[curInd++] = 	
		    tmpObjBuf[ j + me->rows[rowNo].startIndex - firstObjInd];
	    }
	}
    }

    /* copy unselected row objects */

    for( i = first+me->maxLinesPerRow ; i <= last ; i=i+me->maxLinesPerRow )
    {
	FIfld_get_text( VD_FP, VD_TBL_VIS_COLDISP_FLD, i, 0, 10, buf, 
							&sel, &pos );
	if( !sel )
	{
	    rowNo = i / me->maxLinesPerRow;
	    __DBGpr_int( "Row number to retain", rowNo );

	    for( j = 0 ; j < me->rows[rowNo].nbObjs ; j++ )
	    {
		__DBGpr_int( "Current index", curInd );
		__DBGpr_int( "Target index", 
			j + me->rows[rowNo].startIndex - firstObjInd );
		me->locObjs[curInd++] = 	
		    tmpObjBuf[ j + me->rows[rowNo].startIndex - firstObjInd];
	    }
	}
    }
 
    _FREE( tmpObjBuf );

#ifdef vdsDEBUG
    printf("\n\n\tFinal list of objects\n");
    for( i = 0 ; i < nbObjs ; i++ )
	printf("\t\tObj # %d = [%d, %d]\n", i, me->locObjs[i].obj_id.objid,
						me->locObjs[i].obj_id.osnum );
#endif

    /* delete the remaining rows that were summarized with the first one */
    
    /* counter for number of deleted rows */
    count = 0;

    /* counter for total number of objects in summarized row */
    nbSumObjs = me->rows[firstRow].nbObjs;

    for( i = last ; i > first ; i=i-me->maxLinesPerRow )
    {
	FIfld_get_text( VD_FP, VD_TBL_VIS_COLDISP_FLD, i, 0, 10, buf, 
							&sel, &pos );
	if( sel )
	{
	    rowNo = i / me->maxLinesPerRow;
	    __DBGpr_int( "Row number to delete", rowNo );

	    /* update counters */

	    count++;
	    nbSumObjs += me->rows[rowNo].nbObjs;

	    if( me->rows[rowNo].rowId.objid != NULL_OBJID )
	    {
		/* delete the row object */

		status =
		_VD_SEND_MY( VDCmdCrTbl.VDrowToBeDeleted( msg,
						me->rows[rowNo].rowId ) );
		__CheckRC( status, *msg, "VDCmdCrTbl.VDrowToBeDeleted", wrapup);
	    }
	
	    /* delete from me->rows */

	    for( j = rowNo ; j < nbRows-1 ; j++ )
		me->rows[j] = me->rows[j+1];

	    /* delete from the vis and invis mcfs */

	    FIfld_delete_rows( VD_FP, VD_TBL_VIS_COLDISP_FLD, i, 
							me->maxLinesPerRow );
	    FIfld_delete_rows( VD_FP, VD_TBL_INV_COLDISP_FLD, i, 
							me->maxLinesPerRow );
	}
    }

    __DBGpr_int( "Number of rows deleted", count );
    __DBGpr_int( "Total number of objects for sum row", nbSumObjs );

    /* resize me->rows vla */

    nbRows -= count;
    om$vla_set_dimension(	varray	= me->rows,
				size	= nbRows );

    /* update the summarized row entry */

    me->rows[firstRow].nbObjs = nbSumObjs;
    if( me->rows[firstRow].flag == VD_DRW_ROW_OLD )
	me->rows[firstRow].flag = VD_DRW_ROW_MOD;

    /* update the startIndex for me->rows */

    for( i = firstRow+1 ; i < nbRows; i++ )
	me->rows[i].startIndex = me->rows[i-1].startIndex +
						me->rows[i-1].nbObjs;

    /* 
     * update the row values in the vis and invis gadgets 
     * Leave the user-defined, and fixed text entries, untouched.
     */

    /* get number of data records */

    nbDatRecs = om$dimension_of( varray = me->datRecs );
    __DBGpr_int( "Number of data records", nbDatRecs );

    objIndex = me->rows[firstRow].startIndex;
    __DBGpr_int( "Object index ", objIndex );

    for( i = 0 ; i < nbDatRecs ; i++ )
    {
	/* avoid overflow lines too */

	if( me->datRecs[i].rectyp == VD_DRWLO_EN_USERDEFINED ||	
				me->datRecs[i].rectyp == VD_DRWLO_EN_OVERFLOW )
	    continue;

	col = me->datRecs[i].colno;
	row = me->datRecs[i].lineno + ( firstRow * me->maxLinesPerRow ) - 1;

	__DBGpr_int( "Row number", row );
	__DBGpr_int( "Column number", col );

	_FREE( fldVal );
	fldVal = NULL;

	status = VDdrw_getFldValue(	msg,
					me->rows[firstRow].nbObjs,
					&me->locObjs[objIndex],
					me->datRecs[i],
					me->rows[firstRow].qty,
					NULL,
					&fldVal );
	CheckRC( status, *msg );

	if( !fldVal )
	    continue;

	__DBGpr_str( "Field value", fldVal );

	/* update text in inv mcf */

	FIfld_set_text( VD_FP, VD_TBL_INV_COLDISP_FLD, row, col, 
					(unsigned char *)fldVal, FALSE );

	/* update text in vis mcf if column is present */

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
 
    /* update the first column */

    status =
    _VD_SEND_MY( VDCmdCrTbl.VDupdate1stCol( msg ) );
    CheckRC( status, *msg );

#ifdef vdsDEBUG
    printf( "\n\tFinal list of me->rows vla :\n");
    for( i = 0 ; i < nbRows ; i++ )
        printf( "\t\tstartIndex = %d, nbObjs = %d\n", me->rows[i].startIndex,
                                                        me->rows[i].nbObjs );
#endif

wrapup :
    _FREE( fldVal );

    End
    return status;
}

/*+me
 ---------------------------------------------------------------------------
  Public Message VDitemizeRow

  Abstract
        This method itemizes the given summarized row.

  Arguments
        IGRlong         *sts            O       Return code
	IGRint		rowNo		I	Row number to itemize

  Notes/Remarks

  Status/Return Code
      status == OM_S_SUCCESS

 ---------------------------------------------------------------------------
-me*/

method  VDitemizeRow(	IGRlong 	*msg; 
			IGRint		rowNo )
{
    IGRint		i, count,
			lineNo,
			nbLines,
			nbNewLines,
			vlaSize;
    IGRlong		status = OM_S_SUCCESS;

    SetProc( VDCmdCrTbl.VDitemizeRow ); Begin
    *msg = MSSUCC;

    count = me->rows[rowNo].nbObjs;
    __DBGpr_int( "Number of objects in summarized row", count );

    nbNewLines = (count-1) * me->maxLinesPerRow;
    __DBGpr_int( "Number of extra lines", nbNewLines );

    lineNo = (rowNo + 1) * me->maxLinesPerRow;
    __DBGpr_int( "Line number to insert new lines", lineNo );

    vlaSize = om$dimension_of( varray = me->rows );
    __DBGpr_int( "Original Vla size", vlaSize );

    nbLines = vlaSize * me->maxLinesPerRow;
    __DBGpr_int( "Number of lines", nbLines );

    /* insert blank rows in columns */

    if( lineNo == nbLines )
    {
	__DBGpr_int( "Setting nb of lines to ", nbLines+nbNewLines );

	FIfld_set_num_rows( VD_FP, VD_TBL_INV_COLDISP_FLD, nbLines+nbNewLines );
	FIfld_set_num_rows( VD_FP, VD_TBL_VIS_COLDISP_FLD, nbLines+nbNewLines );
    }
    else
    {
    	for( i = 0 ; i < nbNewLines ; i++ )
    	{
	    FIfld_insert_blank_row( VD_FP, VD_TBL_INV_COLDISP_FLD, lineNo );
	    FIfld_insert_blank_row( VD_FP, VD_TBL_VIS_COLDISP_FLD, lineNo );
	}
    }

    /* resize me->rows vla */

#ifdef vdsDEBUG
    printf( "\n\tInitial list of me->rows vla :\n");
    for( i = 0 ; i < vlaSize ; i++ )
        printf( "\t\tstartIndex = %d, nbObjs = %d\n", me->rows[i].startIndex,
                                                        me->rows[i].nbObjs );
#endif

    vlaSize += (count-1);
    __DBGpr_int( "New Vla size", vlaSize );

    status = om$vla_set_dimension(	varray	= me->rows,
					size	= vlaSize );
    __CheckRC( status, 1, "om$vla_set_dimension", wrapup );

    /* push remaining elements behind */

    for( i = vlaSize-1 ; i > (rowNo+count-1) ; i-- )
	me->rows[i] = me->rows[i-count+1];

    /* update the count of itemized row, and the newly inserted rows */

    me->rows[rowNo].nbObjs = 1;
    if( me->rows[rowNo].flag == VD_DRW_ROW_OLD )
    	me->rows[rowNo].flag = VD_DRW_ROW_MOD;

    for( i = rowNo+1 ; i < rowNo+count ; i++ )
    {
	me->rows[i].rowId.objid = NULL_OBJID;
	me->rows[i].nbObjs = 1;
	me->rows[i].startIndex = me->rows[i-1].startIndex + 1;
	me->rows[i].flag = VD_DRW_ROW_NEW;
	me->rows[i].qty = me->rows[rowNo].qty;
    }

#ifdef vdsDEBUG
    printf( "\n\tFinal list of me->rows vla :\n");
    for( i = 0 ; i < vlaSize ; i++ )
        printf( "\t\tstartIndex = %d, nbObjs = %d\n", me->rows[i].startIndex,
                                                        me->rows[i].nbObjs );
#endif

    /* update the contents of the rows in the form */

    for( i = rowNo ; i < rowNo+count ; i++ )
    {
    	status =
    	_VD_SEND_MY( VDCmdCrTbl.VDupdateRow( msg, i ) );
    	CheckRC( status, *msg );
    }

    /* update first column */

    status =
    _VD_SEND_MY( VDCmdCrTbl.VDupdate1stCol( msg ) );
    CheckRC( status, *msg );

wrapup :
    End
    return status;
}

/*+me
 ---------------------------------------------------------------------------
  Public Message summ_and_sort_objs

  Abstract
        This method summarizes and sorts the newly located objects.

  Arguments
        IGRlong         *sts            O       Return code

  Notes/Remarks

  Status Code
      status == OM_S_SUCCESS

  Return Code
      *sts =    VD_SUCCESS  if success
                VD_ERROR if  no memory
 ---------------------------------------------------------------------------
-me*/

method  summ_and_sort_objs( long *sts )
{
    IGRint		i, j,
			objInd,
			rowInd,
			nbObjs,
			nbRows,
			nbNewRows;
    IGRlong		msg,
			locMsg,
			status = OM_S_SUCCESS;
    struct VDdrwlo_tab	tblRec;
    struct VDrowinfo	*sortRows = NULL;
    IGRshort 		isLinedOut, numLinedOut;
    struct VDdrw_rowInfo tmpLinedOut, *LinedOut = NULL;
    IGRint 		tmpnb;

    SetProc( VDCmdCrTbl.summ_and_sort_objs ); Begin

    *sts = VD_SUCCESS;

    if( !VDdrw_getSumSortFlag() ) goto wrapup;

    /* retrieve table names */

    status = VD_drwlo_gtab( &msg, me->tblLayoutName, &tblRec );
    __CheckRC( status, msg, "VD_drwlo_gtab", wrapup );

    __DBGpr_str( "Summ. tbl name", tblRec.SumFil );
    __DBGpr_str( "Sort tbl name", tblRec.SortFil );

    nbObjs = om$dimension_of( varray = me->locObjs );
    __DBGpr_int( "Total number of objects", nbObjs );

    nbRows = om$dimension_of( varray = me->rows );
    __DBGpr_int( "Total number of rows", nbRows );

    /* Added by Ming for TR179900821 */
    if( nbRows > nbObjs ) tmpnb = nbRows;
    else tmpnb = nbObjs; 

    numLinedOut = 0;
    for( i = 0 ; i < nbRows ; i++ )
    {
      isLinedOut = 0;
      status =
      _VD_SEND_OBJ( me->rows[i].rowId, 
			VDdrwTblRow.VDisRowLinedOut(&msg, &isLinedOut) );
      CheckRC( status, msg );

      if( isLinedOut ) numLinedOut++;
    }

    if( numLinedOut )
    {
      LinedOut = _MALLOC( numLinedOut, struct VDdrw_rowInfo );
      if( !LinedOut )
      {
        *sts = VD_ERROR;
        goto wrapup;
      }
    }

    for( i = 0 ; i < nbRows ; i++ )
    {
      isLinedOut = 0;
      status =
      _VD_SEND_OBJ( me->rows[i].rowId, 
                        VDdrwTblRow.VDisRowLinedOut(&msg, &isLinedOut) );
      CheckRC( status, msg );

      if( isLinedOut )
      {
        memcpy(	(char *) &tmpLinedOut,
        	(char *) &me->rows[i], 
		sizeof( struct VDdrw_rowInfo ) ) ;
        for( j = i+1 ; j < nbRows ; j++ )
        {
          isLinedOut = 0;
          status =
          _VD_SEND_OBJ( me->rows[j].rowId,
                        VDdrwTblRow.VDisRowLinedOut(&msg, &isLinedOut) );
          CheckRC( status, msg );

          if( !isLinedOut )
    	  {
	    memcpy( (char *) &me->rows[i],
                    (char *) &me->rows[j],
                    sizeof( struct VDdrw_rowInfo ) ) ;
	    memcpy( (char *) &me->rows[j],
                    (char *) &tmpLinedOut,
                    sizeof( struct VDdrw_rowInfo ) ) ;
	    break;
	  }
        }
      } 
    }

    for( i = 0 ; i < numLinedOut ; i++ )
    {
      memcpy( (char *) &LinedOut[i],
              (char *) &me->rows[nbRows-numLinedOut+i],
              sizeof( struct VDdrw_rowInfo ) ) ;
    }

    status = om$vla_set_dimension( varray  = me->rows,
                                   size    = tmpnb+numLinedOut );

    nbNewRows = me->nbNewLocObjs;
    __DBGpr_int( "Number of new objects/rows ", me->nbNewLocObjs );

/*
    For some cases, it will cause problems - disconnecting rows with header.
    Either check it at the beginning and wrapup if necessary, or just do not 
    check and let the method summ and sort entirely, in case some objects
    changed, enevn without new added objects at all. - by ylong

    if( !nbNewRows )
	goto wrapup;
*/

    rowInd = nbRows - nbNewRows;
    __DBGpr_int( "Start index for rows", rowInd );

   /*
    *  Added by ylong for TR179900885, always sum and sort sort all objects 
    *  whenever new objs added to table. To resume it to previous version, 
    *  just remove following two lines and restore original parameters for
    *  func call VDsort_tbl().
    */
    rowInd = 0 ;
    nbNewRows = nbObjs ;


    objInd = me->rows[rowInd].startIndex;
    __DBGpr_int( "Start index for loc objs", objInd );

    /* summarize the objects */

    status = VDdrw_summarizeObjs( 	&msg, 
					tblRec.SumFil,
					&nbNewRows,
					&me->rows[rowInd],
					&me->locObjs[objInd] );
    __CheckRC( status, msg, "VDdrw_summarizeObjs", wrapup );

    __DBGpr_int( "Number of rows after summarization", nbNewRows );

    nbRows = rowInd + nbNewRows;
    __DBGpr_int( "New size of me->rows vla", nbRows );

    if( !(rowInd + nbNewRows) )
    {
	*sts = VD_ERROR;
	goto wrapup;
    }

    /* Added by Ming for TR179900821 */
    for( i = nbRows ; i < nbRows + numLinedOut ; i++ )
    {
      memcpy( (char *) &me->rows[i],
              (char *) &LinedOut[i-nbRows],
              sizeof( struct VDdrw_rowInfo ) ) ;
    }

    tmpnb = nbRows + numLinedOut;
    status = om$vla_set_dimension(	varray	= me->rows,
					size	= tmpnb );

    /* resize the rows vla */

    /* Commented by Ming for TR179901201
    status = om$vla_set_dimension(	varray	= me->rows,
					size	= nbRows );
    */

    /* sort the objects */

    /* allocate memory for rowinfo structures */

    sortRows = _MALLOC( nbNewRows, struct VDrowinfo );
    if( !sortRows )
    {	
	*sts = VD_ERROR;
	goto wrapup;
    }

    /* initialize buffer */

    for( i = 0 ; i < nbNewRows ; i++ )
    {

	sortRows[i].start_rindex = me->rows[i+rowInd].startIndex;
	sortRows[i].nbsumobjs = me->rows[i+rowInd].nbObjs;
	sortRows[i].qty = me->rows[i+rowInd].qty;

	__DBGpr_int( "Index", i );
	__DBGpr_int( "\t\tstart_rindex", sortRows[i].start_rindex );
	__DBGpr_int( "\t\tnbsumobjs", sortRows[i].nbsumobjs );
	__DBGpr_str( "\t\t\tqty expr", sortRows[i].qty.szExp );

#ifdef vdsDEBUG
{
	IGRint	j;
	for( j = 0 ; j < sortRows[i].nbsumobjs ; j++ )
	    printf("\t\t\tobj %d : [%d, %d]\n", j, 
		me->locObjs[me->rows[i+rowInd].startIndex + j].obj_id.objid, 
		me->locObjs[me->rows[i+rowInd].startIndex + j].obj_id.osnum );
}
#endif
			
    }

    /* 
     * don't check for return codes for sorting.  It does not matter even if
     * some error occured, can still continue with the command, with the
     * unsorted rows
     */

    VDsort_tbl( 	&locMsg,	
			tblRec.SortFil,
			&me->locObjs[objInd],
			sortRows,
			nbObjs, //me->nbNewLocObjs, changed for TR179900885
			nbNewRows );
/*
    __CheckRC( status, msg, "VDsort_tbl", wrapup );
*/

    /* update the sorted row info's number of objects */

    for( i = 0 ; i < nbNewRows ; i++ )
    {
	me->rows[i+rowInd].nbObjs = sortRows[i].nbsumobjs;
	me->rows[i+rowInd].qty = sortRows[i].qty;
    }

    /* update the startIndex for all rows */

    me->rows[0].startIndex = 0;
    for( i = 1 ; i < nbRows ; i++ )
	me->rows[i].startIndex = me->rows[i-1].startIndex + me->rows[i-1].nbObjs;

#ifdef vdsDEBUG
{
    IGRint	i;


    printf( "\n\tFinal list of objects\n" );
    for( i = 0 ; i < nbObjs ; i++ )
	printf( "\n\tObj # %d = [%d, %d]\n", i, me->locObjs[i].obj_id.objid,
						me->locObjs[i].obj_id.osnum );

    printf( "\n\tFinal list of row info\n" );
    for( i = 0 ; i < nbRows ; i++ )
    {
	IGRint j;
	printf( "\n\tRow # %d : startIndex = %d, nbObjs = %d\n", i,
				me->rows[i].startIndex, me->rows[i].nbObjs );
	printf( "\t\tqty flag = %d, qty expr = %s\n", me->rows[i].qty.nSflag,
						me->rows[i].qty.szExp );
	for( j = 0 ; j < me->rows[i].nbObjs ; j++ )
	    printf( "\t\tObj # %d : [%d, %d]\n", j,
		me->locObjs[me->rows[i].startIndex + j].obj_id.objid,
		me->locObjs[me->rows[i].startIndex + j].obj_id.osnum );
    }
}
#endif

wrapup :

    if( !( status & msg & 1 ) )
    {
	*sts = VD_ERROR;
	UI_status( "Error encountered : command terminated" );
    }

    _FREE( LinedOut );
    _FREE( sortRows );

    End
    return OM_S_SUCCESS;
}

end implementation VDCmdCrTbl;
