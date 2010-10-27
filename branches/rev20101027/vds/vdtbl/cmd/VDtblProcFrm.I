/* $Id: VDtblProcFrm.I,v 1.6 2002/06/06 17:08:18 ylong Exp $ */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vds/vdtbl/cmd / VDtblProcFrm.I
 *
 * Description:
 *	Implementation of the following methods for VDCmdCrTbl :
 *		VDprocessCreateForm
 *		VDprocessSplitForm
 *		process_ads_tblname
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDtblProcFrm.I,v $
 *      Revision 1.6  2002/06/06 17:08:18  ylong
 *      *** empty log message ***
 *
 *      Revision 1.5  2001/05/23 23:04:12  ylong
 *      *** empty log message ***
 *
 *      Revision 1.4  2001/05/02 14:52:35  ylong
 *      *** empty log message ***
 *
 *      Revision 1.3  2001/04/06 15:23:35  ylong
 *      TR3320 and TR4997
 *
 *      Revision 1.2  2001/02/15 15:39:23  ramarao
 *      Don't empty the collectors.
 *
 *      Revision 1.1.1.1  2001/01/04 21:09:27  cvs
 *      Initial import to CVS
 *
# Revision 1.2  1998/10/27  16:20:42  pinnacle
# Replaced: vdtbl/cmd/VDtblProcFrm.I for:  by mdong for vds
#
 *
 * History:
 *
 *      04/14/95        R. Manem        Creation
 *      06/22/95        R. Manem        Support for item numbers
 *      07/14/95        R. Manem        ADS support
 *	02/12/98	vini		TR-179800335
 *	10/27/98	Ming		TR179802034
 *	03/29/01	ylong		TR4997
 *	05/02/01	ylong		TR5164
 *	06/05/02	ylong		CR6391
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

from VDdrwTbl		import	VDputAdsTblName;
from VDdrwTblRow	import	ACfind_temp_obj,
				VDgetItemNumber,
				VDputItemNumber;
from ACrg_collect	import	ACrem_attribute,
				ACset_list_attribute;

/*+me
 ---------------------------------------------------------------------------
  Public Message VDprocessCreateForm

  Abstract
        This method processes the form, after it is checked off.  It
	reads the field values and sets up the rg_collector template for
	the row objects.

  Arguments
        IGRlong         *sts            O       Return code

  Notes/Remarks

  Status/Return Code
      status == OM_S_SUCCESS

 ---------------------------------------------------------------------------
-me*/

method  VDprocessCreateForm ( IGRlong *msg )
{
    IGRint			i, j, k,
				col, row,
				sel, pos,
				len = 0, maxLen = 0,
				nbRows, nbCols,
				nbFixRecs, nbDatRecs;
    IGRlong			status = OM_S_SUCCESS;
    IGRlong			tblSrc = 0;
    IGRchar			*buf = NULL,
				*datValue = NULL,
				attName[80];
    struct GRid			collId,
				*rowId = NULL;
    IGRint			itemNo = 0;
    
    SetProc( VDCmdCrTbl.VDprocessCreateForm ); Begin

    *msg = MSSUCC;

    /* get total number of rows */

    nbRows = om$dimension_of( varray = me->rows );
    __DBGpr_int( "Number of rows", nbRows );

    if( !nbRows )
	goto wrapup;

    /* total number of invisible columns */

    FImcf_get_num_cols( VD_FP, VD_TBL_INV_COLDISP_FLD, &nbCols );
    __DBGpr_int( "Number of inv columns ", nbCols );

    /* compute maximum length of text in form */

    for( i = 0 ; i < nbRows * me->maxLinesPerRow ; i++ )
	for( j = 1 ; j < nbCols ; j++ )
	{
	    FIfld_get_text_length( VD_FP, VD_TBL_INV_COLDISP_FLD, i, j, &len );
	    if( len > maxLen )
		maxLen = len;
	}
 
    __DBGpr_int( "Maximum text length", maxLen );

    /* allocate space for buffer */

    buf = _MALLOC( maxLen, IGRchar );
    if( !buf )
    {
	status = OM_E_NODYNMEM;
	goto wrapup;
    }

    /* number of fixed and variable records */

    nbFixRecs = om$dimension_of( varray = me->fixRecs );
    nbDatRecs = om$dimension_of( varray = me->datRecs );
    __DBGpr_int( "Number of fixed text records", nbFixRecs );
    __DBGpr_int( "Number of data records", nbDatRecs );

    /* 
     * for each row
     *     if flag = OLD, continue  (ie, row is not NEW and is not MODified)
     *     empty collector contents 
     *	   for each field in row  (fixed and variable texts)
     *		get the default value
     *	        get the value from the form
     *		if different, store in the rg_collector
     */

    for( i = 0 ; i < nbRows ; i++ )
    {
	__DBGpr_int( "Loop index i", i );

	/* removed for CR6391 
	if( me->rows[i].flag == VD_DRW_ROW_OLD )
	    continue;
	*/

#ifdef DEBUG
	printf("Print attrbutes at FILE: %s, LINE: %d\n", __FILE__,__LINE__);
	VDtblPrintRowAttributes( &me->rows[i].rowId );
#endif

	/* get the collector id */

	status =
	_VD_SEND_OBJ( me->rows[i].rowId, VDdrwTblRow.ACfind_temp_obj(	
								(int *)msg,
								"coll",
								&collId ) );
	CheckRC( status, *msg );

	if( !(status & *msg & 1) )
	    continue;

	__DBGpr_obj( "Collector id", collId );
    
	/* empty collector 

	status =
	_VD_SEND_OBJ( collId, ACrg_collect.ACset_list_attribute(msg,
								0, 
								NULL ) );
	*/

	CheckRC( status, *msg );

	/* loop through fixed texts */

	for( j = 0 ; j < nbFixRecs ; j++ )
	{
	    col = me->fixRecs[j].VD.tx.colno;
	    row = (i * me->maxLinesPerRow) + me->fixRecs[j].VD.tx.lineno  - 1;
	    __DBGpr_int( "Col number ", col );
	    __DBGpr_int( "Row number ", row );

	    /* get text from form */

	    FIfld_get_text( VD_FP, VD_TBL_INV_COLDISP_FLD, row, col, maxLen,
				(unsigned char *)buf, &sel, &pos );
	    __DBGpr_str( "Buffer value", buf );
	    __DBGpr_str( "Default value", me->fixRecs[j].VD.tx.Text );

	    /* compare with default value */

	    if( strcmp( buf, me->fixRecs[j].VD.tx.Text ) )
	    {
		/* add to collector */

		sprintf( attName, "%d %d", col, me->fixRecs[j].VD.tx.lineno );
		__DBGpr_str( "Name of attribute", attName );
		__DBGpr_str( "Value of attribute", buf );

		status = VDputAttInColl( msg, collId, attName, buf );
		CheckRC( status, *msg );
	    }
	}

	/* loop through variable texts */

	for( j = 0 ; j < nbDatRecs ; j++ )
	{
	    /* skip OVERFLOW lines */

	    if( me->datRecs[j].rectyp == VD_DRWLO_EN_OVERFLOW )
		continue;

	    col = me->datRecs[j].colno;
	    row = (i * me->maxLinesPerRow) + me->datRecs[j].lineno  - 1;
	    __DBGpr_int( "Col number ", col );
	    __DBGpr_int( "Row number ", row );

	    /* get text from form */

	    FIfld_get_text( VD_FP, VD_TBL_INV_COLDISP_FLD, row, col, maxLen,
				buf, &sel, &pos );

	    /* handle item number separately*/

	    if( me->datRecs[j].rectyp == VD_DRWLO_EN_ITEMNO )
	    {
		__DBGpr_str( "Item number", buf );

		/* if any row itemed, item new added, TR4997 related, by ylong*/
		if(buf[0] != '\0') 
		{
			itemNo = atoi(buf);
		}
		if(itemNo && buf[0] == '\0') 
		{
			sprintf(buf, "%d", ++itemNo);
			FIfld_set_text( VD_FP, VD_TBL_INV_COLDISP_FLD, 
					row, col, buf, FALSE );
		}

		/* set the item number in the row object */
		status =
		_VD_SEND_OBJ( me->rows[i].rowId, VDdrwTblRow.VDputItemNumber(
							msg, buf ) );
		CheckRC( status, *msg );

		/* handle ASCII table ( cretaed by import) */
		VDdrw_getTblSrc( me->tblObj.obj_id, &tblSrc );
		if( tblSrc == VD_CMD_ITBL_PL )
		{
		   attName[0] = '\0';
		   sprintf( attName, "%d %d", col, me->datRecs[j].lineno );
		   status = VDputAttInColl( msg, collId, attName, buf );
		   CheckRC( status, *msg );
		}
	
		continue;
	    }
	
	    /* get default value */

	    _FREE( datValue );
	    datValue = NULL;

	    rowId = NULL;
	    if( me->rows[i].rowId.objid != NULL_OBJID )
		rowId = &me->rows[i].rowId;

	    status = VDdrw_getFldValue(	msg,
					me->rows[i].nbObjs,
					&me->locObjs[ me->rows[i].startIndex ],
					me->datRecs[j],
					me->rows[i].qty,
					rowId,
					&datValue );
	    CheckRC( status, *msg );

	    __DBGpr_str( "Buffer value", buf );

	    if( datValue )
	        __DBGpr_str( "Default value", datValue );

	    /* compare the two */

	    attName[0] = '\0';
	    sprintf( attName, "%d %d", col, me->datRecs[j].lineno );
	    if( (!datValue && strlen(buf) ) || 
			( datValue && strcmp( buf, datValue ) ) )
	    {
		/* add to collector */

		__DBGpr_str( "Name of attribute", attName );
		__DBGpr_str( "Value of attribute", buf );

		status = VDputAttInColl( msg, collId, attName, buf );
		CheckRC( status, *msg );
	    }
	    else if( datValue && !strcmp( buf, datValue ) )
	    {
		IGRchar         subName[40];
                subName[0]      = '\0';

                status =
                _VD_SEND_OBJ (  collId,
                                ACrg_collect.ACrem_attribute( msg, attName ));
                CheckRC( status, *msg );
                if( (status&*msg&1) ) 
		{
                   for( k = 0; k < 100; k++ )
                   {
                      sprintf(subName, "%s(%d)", attName, k);
                      status =
                      _VD_SEND_OBJ (  collId,
                                ACrg_collect.ACrem_attribute( msg, subName ));
                      if( !(status&*msg&1) ) break;
                   }
                }
		*msg = MSSUCC;
		status = OM_S_SUCCESS;
	    }
	}
    }

wrapup :

    _FREE( buf );
    _FREE( datValue );
    End
    return status;
}

/*+me
 ---------------------------------------------------------------------------
  Public Message VDprocessSplitForm

  Abstract
        This method reads the inpute from the split table form.
        It sets up the instance data for the split locations.

  Arguments
        IGRlong         *msg            O       Return code

  Notes/Remarks

  Status/Return Code
      status == OM_S_SUCCESS;
		OM_W_ABORT 	if invalid inputs
		OM_E_NODYNMEM	if no dynamic memory

 ---------------------------------------------------------------------------
-me*/

method  VDprocessSplitForm( IGRlong *msg )
{
    IGRint		i, j, k,
			sel, pos,
			nbParts,
			totalNbRows, cumNbRows,
			oldNbRows = 0, newNbRows,
			startRowNo,
			diffRows,
			nbToDel;
    double		endRow,
			startNo,
			nbRows;

    IGRlong		status = OM_S_SUCCESS;

    SetProc( VDCmdCrTbl.VDprocessSplitForm ); Begin

    *msg = MSSUCC;

    nbParts = om$dimension_of( varray	= me->splitLocs );
    __DBGpr_int( "Number of parts ", nbParts );
    FIfld_set_num_rows( VD_FP, VD_TBL_SPL_PART_LST_FLD, nbParts );

    totalNbRows = me->splitLocs[nbParts-1];
    __DBGpr_int( "Total Number of rows ", totalNbRows );

    startRowNo = 1;
    for( i = 0 ; i < nbParts ; i++ )
    {
	FIfld_get_value( VD_FP, VD_TBL_SPL_PART_LST_FLD, i, 2, 
						&endRow, &sel, &pos );
	__DBGpr_int( "End Row number", (int)endRow );

	FIfld_get_value( VD_FP, VD_TBL_SPL_PART_LST_FLD, i, 3, 
						&nbRows, &sel, &pos );
	__DBGpr_int( "Number of rows", (int)nbRows );

	/* validate end row number */

	if( (int)endRow < startRowNo || (int)endRow > totalNbRows )
	{
	    FIfld_set_text( VD_FP, FI_MSG_FIELD, 0, 0, 
				"Invalid end row number", FALSE );

	    /* restore old value */

	    endRow = startRowNo + nbRows - 1;
	    FIfld_set_value( VD_FP, VD_TBL_SPL_PART_LST_FLD, i, 2, 
						endRow, FALSE );
	    status = OM_W_ABORT;
	    goto wrapup;
	}
	
	/* validate nb of rows */

	if( (int)nbRows <= 0 || (int)nbRows > ( totalNbRows - startRowNo + 1 ) )
	{
	    FIfld_set_text( VD_FP, FI_MSG_FIELD, 0, 0, 
				"Invalid number of rows", FALSE );

	    /* restore old value */

	    nbRows = endRow - startRowNo + 1;
	    FIfld_set_value( VD_FP, VD_TBL_SPL_PART_LST_FLD, i, 3, 
						nbRows, FALSE );
	    status = OM_W_ABORT;
	    goto wrapup;
	}
	
	oldNbRows = me->splitLocs[i] - startRowNo + 1;
	__DBGpr_int( "Old Number of rows", oldNbRows );

	if( me->splitLocs[i] != (int)endRow )
	{
	    me->splitLocs[i] = (int)endRow;
	    nbRows = me->splitLocs[i] - startRowNo + 1;
	    FIfld_set_value( VD_FP, VD_TBL_SPL_PART_LST_FLD, i, 3,
					nbRows, FALSE );
	    break;
	}

	if( oldNbRows != (int)nbRows )
	{
	    me->splitLocs[i] = startRowNo + (int)nbRows - 1;
	    FIfld_set_value( VD_FP, VD_TBL_SPL_PART_LST_FLD, i, 2,
					(double)me->splitLocs[i], FALSE );
	    break;
	}
	    
	startRowNo = me->splitLocs[i] + 1;
    }

    /* if there is no need to update, wrapup */

    if( i == nbParts )
	goto wrapup;

    /* 
     * must update the info for the remaining parts 
     */

    /* if last part info was modified, may have to add a new row */

    if( i == nbParts-1 && me->splitLocs[i] < totalNbRows )
    {
	status = om$vla_set_dimension(	varray	= me->splitLocs,
					size	= nbParts+1 );
	__CheckRC( status, 1, "om$vla_set_dimension", wrapup );

	FIfld_set_num_rows( VD_FP, VD_TBL_SPL_PART_LST_FLD, nbParts+1 );

	me->splitLocs[nbParts] = totalNbRows;

	FIfld_set_value( VD_FP, VD_TBL_SPL_PART_LST_FLD, i+1, 0,
				(double)( nbParts+1 ), FALSE );

	FIfld_set_value( VD_FP, VD_TBL_SPL_PART_LST_FLD, i+1, 1,
				(double)( me->splitLocs[nbParts-1]+1 ), FALSE );

	FIfld_set_value( VD_FP, VD_TBL_SPL_PART_LST_FLD, i+1, 2,
				(double)( me->splitLocs[nbParts] ), FALSE );

	newNbRows = me->splitLocs[nbParts] - me->splitLocs[nbParts-1];
	__DBGpr_int( "Number of rows", newNbRows );

	FIfld_set_value( VD_FP, VD_TBL_SPL_PART_LST_FLD, i+1, 3,
				(double)( newNbRows ), FALSE );
    }
   
    /* 
     * if nb of rows gets reduced in some intermediate part, add those rows to
     * following part 
     */

    else if( (int)nbRows < oldNbRows )
    {
	diffRows = oldNbRows - (int)nbRows;
	__DBGpr_int( "Difference in number of rows", diffRows );

	FIfld_get_value( VD_FP, VD_TBL_SPL_PART_LST_FLD, i+1, 1, 
						&startNo, &sel, &pos );
	__DBGpr_int( "Current start no ", startNo );
	startNo -= (double)diffRows;
	__DBGpr_int( "New start no ", startNo );

	FIfld_set_value( VD_FP, VD_TBL_SPL_PART_LST_FLD, i+1, 1,
				startNo, FALSE );

	FIfld_get_value( VD_FP, VD_TBL_SPL_PART_LST_FLD, i+1, 3, 
						&nbRows, &sel, &pos );
	__DBGpr_int( "Current nbRows ", nbRows );
	newNbRows = (int)nbRows + diffRows;
	__DBGpr_int( "New nbRows ", nbRows );

	FIfld_set_value( VD_FP, VD_TBL_SPL_PART_LST_FLD, i+1, 3,
				(double)( newNbRows ), FALSE );
    }

    /* 
     * if nb of rows gets increased in some intermediate part, 
     * must subtract those rows from the following part and may have to delete
     * one or more of following rows.
     */

    else if( (int)nbRows > oldNbRows )
    {
	diffRows = (int)nbRows - oldNbRows;
	startRowNo = me->splitLocs[i] + 1;
	__DBGpr_int( "Difference in number of rows", diffRows );
	__DBGpr_int( "StartRowNo for next row", startRowNo );

	nbToDel = 0;
	cumNbRows = 0;
	for( j = i+1 ; j < (nbParts-nbToDel) ; )
 	{
	    /* get nb rows in the part */

	    FIfld_get_value( VD_FP, VD_TBL_SPL_PART_LST_FLD, j, 3, 
						&nbRows, &sel, &pos );
	    cumNbRows += (int)nbRows;
	    __DBGpr_int( "Cumulative number of rows", cumNbRows );

	    /* if cumulative nb rows is not enough, must delete the row */

	    if( cumNbRows <= diffRows )
	    {
		FIfld_delete_rows( VD_FP, VD_TBL_SPL_PART_LST_FLD, j, 1 );
		nbToDel++;
		
		if( cumNbRows == diffRows )
		    break;
	    }
	    else
	    {
		FIfld_set_value( VD_FP, VD_TBL_SPL_PART_LST_FLD, i+1, 1,
				(double)( startRowNo ), FALSE );

		nbRows = cumNbRows - diffRows;
		FIfld_set_value( VD_FP, VD_TBL_SPL_PART_LST_FLD, i+1, 2,
				(double)( startRowNo + nbRows - 1 ), FALSE );

		FIfld_set_value( VD_FP, VD_TBL_SPL_PART_LST_FLD, i+1, 3,
				(double)( nbRows), FALSE );
	        break;
	    }

	}

	if( nbToDel )
	{
	    /* update the first column in form */
    
	    __DBGpr_int( "Number of parts left", (nbParts-nbToDel) );

	    for( j = 0 ; j < (nbParts-nbToDel) ; j++ )
		FIfld_set_value( VD_FP, VD_TBL_SPL_PART_LST_FLD, j, 0,
							(double)(j+1), FALSE );

	    for( k = i+1 ; k < nbParts-nbToDel ; k++ )
		me->splitLocs[k] = me->splitLocs[k+nbToDel];

	    status = om$vla_set_dimension( 	varray 	= me->splitLocs,
						size 	= nbParts-nbToDel );
	    CheckRC( status, 1 );

	    /* set the number of rows */

	    FIfld_set_num_rows( VD_FP, VD_TBL_SPL_PART_LST_FLD, 
							(nbParts - nbToDel) );
	}
    }

#ifdef vdsDEBUG
    printf("\n\tFinal list of splitLoc vla:\n" );
    nbParts = om$dimension_of( varray = me->splitLocs );

    for( i = 0 ; i < nbParts ; i++ )
	printf("\t\t # %d : endrow no = %d\n", i, me->splitLocs[i] );
#endif
	
wrapup :
    End;
    return status;
}

/*+me
 ---------------------------------------------------------------------------
  Public Message process_ads_tblname

  Abstract
        This method gets the ADS table name from the form, and updates
        the instance in VDdrwTbl class. It also sets the flag for recomputing
        all rows, if the name has changed

  Arguments
        long         *sts            O       Return code

  Status code
        status = OM_S_SUCCESS

  Return Code
        *sts == VD_SUCCESS

 ---------------------------------------------------------------------------
-me*/

method  process_ads_tblname( long *sts )
{
    IGRint		i, nbRows, 
			nbTbls = 0,
			sel, pos;
    IGRlong		msg,
			status = OM_S_SUCCESS;
    IGRchar		adsBuf[VD_DRWLO_CHR_IDFLD];
    
    SetProc( process_ads_tblname ); Begin
    *sts = VD_SUCCESS;

    /* get ads table name if table type is BOM */

    if( me->tblType == VD_DRW_TBLTYPE_BOM )
    {
	FIfld_get_num_rows( VD_FP, VD_TBL_ADS_FLD, &nbTbls );
	__DBGpr_int( "Number of rows in ADS field ", nbTbls );

	for( i = 0 ; i < nbTbls ; i++ )
	{
    	    FIfld_get_text( VD_FP, VD_TBL_ADS_FLD, i, 0, VD_DRWLO_CHR_IDFLD,
				(unsigned char *)adsBuf, &sel, &pos );
	    if( sel && strlen( adsBuf ) )
	        break;
	}

	if( i >= nbTbls )
	    adsBuf[0] = '\0';

    	__DBGpr_str( "ADS table name", adsBuf );

	/* 
	 * if MODIFY Table, must check if it has been modified or not
	 */

	if( me->mytype == CREATE_TABLE )	
	    strcpy( me->adsTblName, adsBuf );
	else if( me->mytype == MODIFY_TABLE )
	{
	    /* 
	     * if the ads tbl name has been modified, must recompute
	     * all the rows of the BOM
	     */

// TR-179800335	    if( strcmp( me->adsTblName, adsBuf ) )
	    {
		__DBGpr_com( "Must recompute all rows of BOM" );

	        strcpy( me->adsTblName, adsBuf );

    		nbRows = om$dimension_of( varray = me->rows );
    		__DBGpr_int( "Number of rows", nbRows );

		for( i = 0 ; i < nbRows ; i++ )
		/* TR179802034 by Ming   */
		{
		  if( me->rows[i].flag == VD_DRW_ROW_OLD )
		    me->rows[i].flag = VD_DRW_ROW_MOD;
		}
	    }
	}
    }

    /* update the instance in table class */

    status =
    _VD_SEND_OBJ( me->tblObj.obj_id, VDdrwTbl.VDputAdsTblName(	
							&msg,
							me->adsTblName ) );
    CheckRC( status, msg );

    End
    return OM_S_SUCCESS;
}
    
end implementation VDCmdCrTbl;
