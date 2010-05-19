/* $Id: VDtblFrmNot.I,v 1.5 2001/05/14 20:38:00 ylong Exp $ */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vds/vdtbl/cmd / VDtblFrmNot.I
 *
 * Description:
 *	Implementation of the following method for VDCmdCrTbl :
 *		form_notification
 *
 * Dependencies:
 *
 * History:
 *
 *      04/14/95        R. Manem        Creation
 *      04/24/95        R. Manem        Handled additional gadgets
 *      05/21/95        R. Manem        Don't let nbRows in mcf become 0
 *      05/27/95        R. Manem        TR # 179526568
 *      07/14/95        R. Manem        Small fixes
 *      08/18/95        R. Manem        Fixed TR 179527259
 *      09/13/95        R. Manem        Avoid showing row contents of lined
 *					out rows
 *      10/10/95        R. Manem        TR # 179527815.  Form not erased
 *					when item number form is processed
 *					Set is_lineout flag for item nb func
 *      10/11/95        R. Manem        Fixed bug in setting line out flag
 *	02/05/96	R. Manem	Fixes bug for TR 179528236.
 * 	12/15/97	vini		added 'Select All' button.
 *	10/05/99	Ming		TR179900802
 *	02/08/00	Ming		TR179901025
 *	05/06/01	ylong		CR5119
 *	05/08/01	ylong		TR5176
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
#include "VDitemNum.h"

#include "VDCmdDef.h"
#include "FI.h"
#include "FEI.h"

#define BUFLEN		100

from VDdrwTblRow	import	VDisRowLinedOut;

%safe
static IGRint	colSelected[BUFLEN];
%endsafe

/*+mo
 -------------------------------------------------------------------------
  Overridden Message
        form_notification from CEO

  Abstract
        Form notification routine for the CO

  Arguments
        int           form_label;     label of form which received user  input
        int           gadget_label;   gadget label  which received user  input
        double        value;          value of gadget ( or field row # )
        char          * form_ptr ;    ptr to I/Forms form which received input



 -------------------------------------------------------------------------
-mo*/

method form_notification( int      form_label;
                          int      gadget_label;
                          double   value;
                          char     *form_ptr )
{
    IGRint		i, j, k,
			len,
			row = 0, col = 0, 
			line = 0, 
			mcf,
			retCode,
			sel, pos,
			count,
			rowNo=0,
			nbObjs = 0,
			nbLines,
			nbRows, nbCols,
			nbInvRows, nbInvCols,
			nbVisCols, 
			colToInsert,
			colToDelete,
			nbDatRecs,
			xlo, ylo,
			xhi, yhi,
			resp;
    double		scrollVal,
			blkStart, blkEnd,
			stepSize;
    IGRchar		buf[10],
			messStr[BUFLEN],
			info[20], resetOpt[40],
			*datValue = NULL;
    IGRlong		msg,
			status = OM_S_SUCCESS;
    VD_itemList_t	*itemList = NULL;
    struct GRid		rowId;

    IGRint		mynbCols, allCols;
    IGRint 		nbSelCols_old, fit_flag;

    SetProc( VDCmdCrTbl.form_notification ); Begin

    fit_flag = 1;

    FIfld_set_text( VD_FP, FI_MSG_FIELD, 0, 0, "", FALSE );
    switch( me->mytype )
    {
      case CREATE_TABLE :
      case MODIFY_TABLE :

        switch( gadget_label )
        {

	    case VD_TBL_SELECT_ALL:
		FIfld_get_num_rows( VD_FP, VD_TBL_SELCOL_LIST_FLD, &mynbCols );
		for( i = 0 ; i < mynbCols ; i++ )
		    FImcf_set_select(VD_FP, VD_TBL_SELCOL_LIST_FLD, i, TRUE );
		break;

	    case FI_ACCEPT :

	        nbRows = om$dimension_of( varray	= me->rows );
		__DBGpr_int( "Number of rows", nbRows );

		if( nbRows )
		{
		    /* validate uniqueness of item numbers */

		    status = _VD_SEND_MY( VDCmdCrTbl.VDvalidateItemNos( &msg,
								messStr,
								BUFLEN ) );
		    CheckRC( status, msg );

		    if( strlen( messStr ) )
		    {
		        FIfld_set_text( VD_FP, FI_MSG_FIELD, 0, 0, messStr, 
									FALSE );
		        break;
		    }

	            /* 
	             * must update the invisible columns from the visible ones :
	             * simply delete the existing vis ones
	             */
	    
	            FImcf_get_num_cols( VD_FP, VD_TBL_VIS_COLDISP_FLD, 
								&nbCols );
	            __DBGpr_int( "Number of vis columns ", nbCols );

		    FImcf_set_active_col( VD_FP, VD_TBL_VIS_COLDISP_FLD, 0, 0 );

	            for( i = nbCols-1 ; i > 0 ; i-- )
	            {
		        status =
		        _VD_SEND_MY( VDCmdCrTbl.VDdeleteVisCol( &msg, i ) );
		        CheckRC( status, msg );
	            }
		}

	        resp = VD_FORM_ACCEPT;
	        ex$putque(	msg		= &msg,
				response 	= &resp );
	        break;

	    case FI_CANCEL :
	        resp = VD_FORM_CANCEL;
	        ex$putque(	msg		= &msg,
				response 	= &resp );
	        break;

	    case VD_TBL_SHOW_SELCOL_BTN :

	        /* if invalid state, break */

	        if( me->formState == VD_TBL_ROW_CNTS_ST )
		    break;

	        /* 
	         * update the invisible data column entries
	         */

	        if( me->formState == VD_TBL_BLNK_DISP_ST )
	        {
		    /* display the appropriate gadgets */

		    if( me->tblType == VD_DRW_TBLTYPE_BOM )
		    {
		        FIg_display( VD_FP, VD_TBL_BOM_ATTR_GRP );
		    }

		    FIg_display( VD_FP, VD_TBL_COLDISP_GRP );

		    /* update the row move type */

		    FIg_set_state( VD_FP, VD_TBL_MOVE_TYPE_BTN, FALSE );
		    FIg_erase( VD_FP, VD_TBL_BLK_START_FLD );
		    FIg_erase( VD_FP, VD_TBL_BLK_START_TXT );
		    FIg_erase( VD_FP, VD_TBL_BLK_END_FLD );
		    FIg_erase( VD_FP, VD_TBL_BLK_END_TXT );

		    me->formState = VD_TBL_COL_DISP_ST;
	        }

		FImcf_set_active_col( VD_FP, VD_TBL_VIS_COLDISP_FLD, 0, 0 );
		FImcf_set_active_col( VD_FP, VD_TBL_VIS_COLTITL_FLD, 0, 0 );

	        status =
	        _VD_SEND_MY( VDCmdCrTbl.VDupdateVisColDisp( &msg ) );
	        CheckRC( status, msg );

	        /* refresh the form */

	        FIf_get_size( VD_FP, &xhi, &yhi );
	        FIg_get_location( VD_FP, VD_TBL_VIS_COLTITL_FLD, &xlo, &ylo );
	        FIf_paint_area( VD_FP, xlo, ylo, xhi, yhi );
		for( i = 0; i < BUFLEN; i++ ) {
		   colSelected[i] = 0;
		}

	        break;

	    case VD_TBL_ADS_FLD :

	        break;

	    case VD_TBL_SUM_SELROWS_BTN :
	        /*
	         * summarize the selected rows 
	         */

	        count = 0;

	        nbRows = om$dimension_of( varray	= me->rows );
	        nbLines = nbRows * me->maxLinesPerRow;
	        __DBGpr_int( "Number of rows", nbRows );
    
	        for( i = 0 ; i < nbLines && count < 2 ; i=i+me->maxLinesPerRow )
	        {
		    FIfld_get_text( VD_FP, VD_TBL_VIS_COLDISP_FLD, i, 0, 10,
						buf, &sel, &pos );
		    if( sel )
		        count++;
	        }

	        if( !count )
	        {
		    FIfld_set_text( VD_FP, FI_MSG_FIELD, 0, 0, 
						"No rows selected", FALSE );
		    break;
	        }

	        if( count == 1 )
	        {
		    FIfld_set_text( VD_FP, FI_MSG_FIELD, 0, 0, 
					"Only one row selected", FALSE );
		    break;
	        }

	        status =
	        _VD_SEND_MY( VDCmdCrTbl.VDsummarizeRows( &msg ) );
	        __CheckRC( status, msg, "VDCmdCrTbl.VDsummarizeRows", wrapup );

	        /* refresh form */

	        FIf_get_size( VD_FP, &xhi, &yhi );
	        FIg_get_location( VD_FP, VD_TBL_VIS_COLTITL_FLD, &xlo, &ylo );
	        FIf_paint_area( VD_FP, xlo, ylo, xhi, yhi );

	        break;

	    case VD_TBL_ITEM_SELROW_BTN :
	        /*
	         * itemize the selected row : update both invis and vis cols.
	         */

	        count = 0;

	        nbRows = om$dimension_of( varray	= me->rows );
	        nbLines = nbRows * me->maxLinesPerRow;
	        __DBGpr_int( "Number of rows", nbRows );

	        for( i = 0 ; i < nbLines && count < 2 ; i=i+me->maxLinesPerRow )
	        {
		    FIfld_get_text( VD_FP, VD_TBL_VIS_COLDISP_FLD, i, 0, 10,
						buf, &sel, &pos );
		    if( sel )
		    {
		        rowNo = i;
		        count++;
		    }
	        }

	        if( !count )
	        {
		    FIfld_set_text( VD_FP, FI_MSG_FIELD, 0, 0, 
						"No row selected", FALSE );
		    break;
	        }

	        if( count > 1 )
	        {
		    FIfld_set_text( VD_FP, FI_MSG_FIELD, 0, 0, 
					"Multiple rows selected", FALSE );
		    break;
	        }

	        /* check if it is a summarized row entry */

	        FIfld_get_text( VD_FP, VD_TBL_VIS_COLDISP_FLD, rowNo, 0, 10,
						buf, &sel, &pos );
	        len = strlen( buf );
	        if( buf[len-1] != '*' )
	        {
		    FIfld_set_text( VD_FP, FI_MSG_FIELD, 0, 0, 
				"Selected row is not summarized", FALSE );
		    break;
	        }

	        rowNo = rowNo / me->maxLinesPerRow;
	        __DBGpr_int( "Row number to itemize", rowNo );

	        status =
	        _VD_SEND_MY( VDCmdCrTbl.VDitemizeRow( &msg, rowNo ) );
	        __CheckRC( status, msg, "VDCmdCrTbl.VDitemizeRow", wrapup );
	  
	        /* refresh form */

	        FIf_get_size( VD_FP, &xhi, &yhi );
	        FIg_get_location( VD_FP, VD_TBL_VIS_COLTITL_FLD, &xlo, &ylo );
	        FIf_paint_area( VD_FP, xlo, ylo, xhi, yhi );

	        break;

	    case VD_TBL_GEN_ITEMNBS_BTN :

	        /*
	         * generate item numbers : invoke command/function from item
	         * number module.
	         */

		/* check number of rows */

		nbRows = om$dimension_of( varray = me->rows );
		__DBGpr_int( "Number of rows", nbRows );

		if( !nbRows )
		{
		    FIfld_set_text( VD_FP, FI_MSG_FIELD, 0, 0,
					"No rows present", FALSE );
		    break;
		}

		/* 
		 * find out itemnumber column in vis col disp; if it is not
		 * present in vis column, use its position in the invis col
		 */

		nbDatRecs = om$dimension_of( varray = me->datRecs );
		__DBGpr_int( "Number of data records", nbDatRecs );

		for( i = 0 ; i < nbDatRecs ; i++ )
		    if( me->datRecs[i].rectyp == VD_DRWLO_EN_ITEMNO )
		    {
			col = me->datRecs[i].colno;
			line = me->datRecs[i].lineno;
			break;
		    }

		if( i >= nbDatRecs )
		{
		    /* 
		     * should never come here, because the gadget must 
		     * already be disabled
		     */

		    FIfld_set_text( VD_FP, FI_MSG_FIELD, 0, 0, 
				"Item number column is not present", FALSE );
		    break;
	        }
		
		__DBGpr_int( "Column number for item number", col );
		__DBGpr_int( "Line number for item number", line );
		
		mcf = VD_TBL_INV_COLDISP_FLD;

		/* check if present in vis col mcf */

		for( i = 0 ; i < me->nbSelCols ; i++ )
		    if( me->selColList[i] == col )
		    {
			col = i + 1;
			mcf = VD_TBL_VIS_COLDISP_FLD;
			break;
		    }
		__DBGpr_int( "Column number for item number", col );
		__DBGpr_int( "mcf value", mcf );

		/* set up the input structure */

		itemList = _MALLOC( nbRows, VD_itemList_t );
		if( !itemList )
		{
		    UI_status( "Error in dynamic allocation : command terminated" );
		    me->state = _terminate;
	        }

		for( i = 0 ; i < nbRows ; i++ )
		{
		    itemList[i].is_modified = FALSE;
		    itemList[i].num_objs = me->rows[i].nbObjs;
		    itemList[i].objs = &me->locObjs[ me->rows[i].startIndex];
		    FIfld_get_text( VD_FP, mcf, i*me->maxLinesPerRow + line-1,
				col, VD_ITEMNUM_LEN, 
				(unsigned char *)itemList[i].itemNo,
				&sel, &pos );
		    if( me->rows[i].flag == VD_DRW_ROW_NEW )
			itemList[i].is_lineout = FALSE;
		    else
		        _VD_SEND_OBJ( 	me->rows[i].rowId, 
					VDdrwTblRow.VDisRowLinedOut( &msg, 
						 &itemList[i].is_lineout ) );

		    __DBGpr_int( "Loop index", i );
		    __DBGpr_int( "Number of objects", itemList[i].num_objs );
		    __DBGpr_str( "Item Number", itemList[i].itemNo );
		    __DBGpr_int( "is_lineout", itemList[i].is_lineout );
		}

		/* temporarily disable gadgets */

		FIg_disable( VD_FP, VD_TBL_BOM_BTNS_GRP );
		FIg_disable( VD_FP, VD_TBL_BOM_ATTR_GRP );
		FIg_disable( VD_FP, VD_TBL_COLDISP_GRP );
		FIg_disable( VD_FP, VD_TBL_SHOW_SELCOL_BTN );
		FIg_disable( VD_FP, VD_TBL_SELCOL_LIST_FLD );
		FIg_disable( VD_FP, FI_ACCEPT );
		FIg_disable( VD_FP, FI_CANCEL );

		FIf_cvrt_to_perm_win ( VD_FP );

		/* generate item numbers */

		VD_drwGenItemNum( itemList, nbRows );

		/* enable gadgets */

		FIg_enable( VD_FP, VD_TBL_BOM_BTNS_GRP );
		FIg_enable( VD_FP, VD_TBL_BOM_ATTR_GRP );
		FIg_enable( VD_FP, VD_TBL_COLDISP_GRP );
		FIg_enable( VD_FP, VD_TBL_SHOW_SELCOL_BTN );
		FIg_enable( VD_FP, VD_TBL_SELCOL_LIST_FLD );
		FIg_enable( VD_FP, FI_ACCEPT );
		FIg_enable( VD_FP, FI_CANCEL );

		/* update the item number column */

		for( i = 0 ; i < nbRows ; i++ )
		{
		    __DBGpr_str( "Final item number ", itemList[i].itemNo );
		    FIfld_set_text( VD_FP, mcf, i*me->maxLinesPerRow + line-1,
			col, (unsigned char *)itemList[i].itemNo, FALSE );
		}

		/* update the modified flag, if necessary */

		if( me->mytype == MODIFY_TABLE )
		    for( i = 0 ; i < nbRows ; i++ )
			if( itemList[i].is_modified )
			{
			    __DBGpr_int( "Item number modified for row", i );

			    if( me->rows[i].flag != VD_DRW_ROW_NEW )
			        me->rows[i].flag = VD_DRW_ROW_MOD;
			}

	        break;

	    case VD_TBL_VIS_COLDISP_FLD :
    
	        /* set number of rows for the mcf */

	        nbRows = om$dimension_of( varray	= me->rows );
	        nbLines = nbRows * me->maxLinesPerRow;
	        __DBGpr_int( "VIS_COLDISP_FLD : nbLines ", nbLines );

		/* if there are no rows, then forms crashes */
    
		if( !nbLines )
		{
		    /* clear fields by deleting row */
	
	            FIfld_set_num_rows( VD_FP, VD_TBL_VIS_COLDISP_FLD, nbLines );
		    nbLines = 1;
		}

	        __DBGpr_int( "Changing nbLines to ", nbLines );

	        FIfld_set_num_rows( VD_FP, VD_TBL_VIS_COLDISP_FLD, nbLines );

	        /* get number of visible columns */

	        FImcf_get_num_cols( VD_FP, VD_TBL_VIS_COLDISP_FLD, &nbVisCols );
	        __DBGpr_int( "Number of vis cols ", nbVisCols );
	    
	        /* set the active character to 0 in each visible column */

	        for( i = 1 ; i < nbVisCols ; i++ )
		    FIfld_set_active_char( VD_FP, VD_TBL_VIS_COLDISP_FLD, 
								i, 0, 0 );

	        break;

	    case VD_TBL_SHOW_ROWCNTS_BTN :

	        count = 0;

	        nbRows = om$dimension_of( varray	= me->rows );
	        nbLines = nbRows * me->maxLinesPerRow;
	        __DBGpr_int( "Number of rows", nbRows );

	        for( i = 0 ; i < nbLines && count < 2 ; i=i+me->maxLinesPerRow )
	        {
		    FIfld_get_text( VD_FP, VD_TBL_VIS_COLDISP_FLD, i, 0, 10,
						buf, &sel, &pos );
		    if( sel )
		    {
		        rowNo = i / me->maxLinesPerRow;
		        count++;
		    }
	        }

	        if( !count )
	        {
		    FIfld_set_text( VD_FP, FI_MSG_FIELD, 0, 0, 
						"No row selected", FALSE );
		    break;
	        }

	        if( count > 1 )
	        {
		    FIfld_set_text( VD_FP, FI_MSG_FIELD, 0, 0, 
					"Multiple rows selected", FALSE );
		    break;
	        }

		/* check if row is lined out */

		FIfld_get_text( VD_FP, VD_TBL_VIS_COLDISP_FLD, 
					rowNo * me->maxLinesPerRow, 0, 10,
					buf, &sel, &pos );
		len = strlen( buf );
		if( buf[len-1] == '-' )
		{
		    FIfld_set_text( VD_FP, FI_MSG_FIELD, 0, 0, 
				"Cannot show lined out row contents", FALSE );
		    break;
	        }

	        /* update gadget display */

	        FIg_erase( VD_FP, VD_TBL_BOM_ATTR_GRP );
	        FIg_erase( VD_FP, VD_TBL_COLDISP_GRP );
	        FIg_erase( VD_FP, VD_TBL_BOM_BTNS_GRP );

		/* disable gadgets */
	
		FIg_disable( VD_FP, FI_ACCEPT );
		FIg_disable( VD_FP, VD_TBL_SHOW_SELCOL_BTN );

	        /* show row contents */

	        status = _VD_SEND_MY( VDCmdCrTbl.VDshowRowContents( &msg,
								rowNo ) );
	        CheckRC( status, msg );

	        FIg_display( VD_FP, VD_TBL_ROWCNTS_GRP );
	        FIg_display( VD_FP, VD_TBL_VIS_COLTITL_FLD );

		/* tr179602164 */
	        FIg_get_state( VD_FP, VD_TBL_ROWCNTS_ACC_BTN, &sel );
		if( sel) 
	           FIg_set_state( VD_FP, VD_TBL_ROWCNTS_ACC_BTN, FALSE );

	        me->formState = VD_TBL_ROW_CNTS_ST;

	        break;

	    case VD_TBL_ROWCNTS_ACC_BTN :

	        /* update gadget display */

	        FIg_display( VD_FP, VD_TBL_BOM_ATTR_GRP );
	        FIg_display( VD_FP, VD_TBL_COLDISP_GRP );
	        FIg_display( VD_FP, VD_TBL_BOM_BTNS_GRP );

		/* tr179602164 */
	        FIg_get_state( VD_FP, VD_TBL_SHOW_ROWCNTS_BTN, &sel );
		if( sel) 
	           FIg_set_state( VD_FP, VD_TBL_SHOW_ROWCNTS_BTN, FALSE );

		/* enable gadgets */
	
		FIg_enable( VD_FP, FI_ACCEPT );
		FIg_enable( VD_FP, VD_TBL_SHOW_SELCOL_BTN );

	        FIg_get_state( VD_FP, VD_TBL_MOVE_TYPE_BTN, &sel );
	        if( sel )
	        {
		    FIg_display( VD_FP, VD_TBL_BLK_START_FLD );
		    FIg_display( VD_FP, VD_TBL_BLK_START_TXT );
		    FIg_display( VD_FP, VD_TBL_BLK_END_FLD );
		    FIg_display( VD_FP, VD_TBL_BLK_END_TXT );
	        }
	        else
	        {
		    FIg_erase( VD_FP, VD_TBL_BLK_START_FLD );
		    FIg_erase( VD_FP, VD_TBL_BLK_START_TXT );
		    FIg_erase( VD_FP, VD_TBL_BLK_END_FLD );
		    FIg_erase( VD_FP, VD_TBL_BLK_END_TXT );
	        }

	        FIg_erase( VD_FP, VD_TBL_ROWCNTS_GRP );
    
	        me->formState = VD_TBL_COL_DISP_ST;

	        /* refresh lower half of form : note xlo = 0.0*/

	        FIf_get_size( VD_FP, &xhi, &yhi );
	        FIg_get_location( VD_FP, VD_TBL_VIS_COLTITL_FLD, &xlo, &ylo );
	        FIf_paint_area( VD_FP, 0, ylo, xhi, yhi );

	        break;

	    case VD_TBL_MOVE_UP_BTN :

	    case VD_TBL_MOVE_DN_BTN :
	    {

	        FIfld_get_value( VD_FP, VD_TBL_STEP_SIZE_FLD, 0, 0, 
				&stepSize, &sel, &pos );
    
	        if( gadget_label == VD_TBL_MOVE_UP_BTN )
	            stepSize = -stepSize;

	        __DBGpr_int( "Step size", stepSize );

	        /* get type of move */

	        FIg_get_state( VD_FP, VD_TBL_MOVE_TYPE_BTN, &sel );

	        if( sel )
	        {
		    __DBGpr_com( "\n\tBlock Move\n");
		
		    FIfld_get_value( VD_FP, VD_TBL_BLK_START_FLD, 0, 0,
				&blkStart, &sel, &pos );
		    FIfld_get_value( VD_FP, VD_TBL_BLK_END_FLD, 0, 0,
				&blkEnd, &sel, &pos );
		    __DBGpr_int( "Block start", (int)blkStart );
		    __DBGpr_int( "Block End", (int)blkEnd );

		    status =
		    _VD_SEND_MY( VDCmdCrTbl.VDmoveRows( &msg, 
							(IGRint)stepSize,
							(IGRint)(blkStart-1), 
							(IGRint)(blkEnd-1) ) );
		    CheckRC( status, msg );
	        }
	        else
	        {
		    __DBGpr_com( "\n\tSingle Row Move\n");

	            /* check if number of selected rows is > 1 */

	            count = 0;

	            FIfld_get_num_rows( VD_FP, VD_TBL_VIS_COLDISP_FLD, 
								&nbLines );

	            for( i = 0 ; i < nbLines && count < 2 ; i++ )
	            {
		        FIfld_get_text( VD_FP, VD_TBL_VIS_COLDISP_FLD, i, 0, 10,
						buf, &sel, &pos );
		        if( sel && strlen(buf) )
		            count++;
	            }

	            if( !count )
	            {
		        FIfld_set_text( VD_FP, FI_MSG_FIELD, 0, 0, 
						"No row selected", FALSE );
		        break;
	            }

		    if( count > 1 )
		    {
		        FIfld_set_text( VD_FP, FI_MSG_FIELD, 0, 0, 
					"Multiple rows selected", FALSE );
		        break;
	            }

	            for( i = 0 ; i < nbLines ; i++ )
	            {
		        FIfld_get_text( VD_FP, VD_TBL_VIS_COLDISP_FLD, i, 0, 10,
						buf, &sel, &pos );
		        if( sel && strlen(buf) )
		        {
			    FIfld_set_select( VD_FP, VD_TBL_VIS_COLDISP_FLD,
						i, 0, FALSE );

			    i = i / me->maxLinesPerRow;
			    __DBGpr_int( "Moving row ", i );

			    status =
			    _VD_SEND_MY( VDCmdCrTbl.VDmoveRows( &msg,
							    (IGRint)stepSize,
							    i, i ) );
			    CheckRC( status, msg );

			    rowNo = (i+stepSize) * me->maxLinesPerRow;
			    __DBGpr_int( "Selecting ", rowNo );

			    FIfld_set_select( VD_FP, VD_TBL_VIS_COLDISP_FLD,
						rowNo, 0, TRUE );
    
			    FIfld_get_num_vis_rows( VD_FP, 
							VD_TBL_VIS_COLDISP_FLD,
							&nbLines );
			    __DBGpr_int( "Number of visible lines", nbLines );

			    pos = nbLines / 2;
			    FIfld_set_active_row( VD_FP, VD_TBL_VIS_COLDISP_FLD,
						rowNo, pos );
			    break;
		        }
		    }
	        }

	        /* refresh the form */

	        FIf_get_size( VD_FP, &xhi, &yhi );
	        FIg_get_location( VD_FP, VD_TBL_VIS_COLTITL_FLD, &xlo, &ylo );
	        FIf_paint_area( VD_FP, xlo, ylo, xhi, yhi );

	        break;
	    }

	    case VD_TBL_STEP_SIZE_FLD :
	        break;

	    case VD_TBL_MOVE_TYPE_BTN :

		FIg_get_state( VD_FP, VD_TBL_MOVE_TYPE_BTN, &sel );
		__DBGpr_int( "Select state", sel );

		if( sel )
		{
		    FIg_display( VD_FP, VD_TBL_BLK_START_FLD );
		    FIg_display( VD_FP, VD_TBL_BLK_START_TXT );
		    FIg_display( VD_FP, VD_TBL_BLK_END_FLD );
		    FIg_display( VD_FP, VD_TBL_BLK_END_TXT );
		}
		else
		{
		    FIg_erase( VD_FP, VD_TBL_BLK_START_FLD );
		    FIg_erase( VD_FP, VD_TBL_BLK_START_TXT );
		    FIg_erase( VD_FP, VD_TBL_BLK_END_FLD );
		    FIg_erase( VD_FP, VD_TBL_BLK_END_TXT );
		}
	    break;

	    case VD_TBL_BLK_START_FLD :
	        break;

	    case VD_TBL_BLK_END_FLD :
	        break;

	    case VD_TBL_SCROLL_TO_BTN :

	        /* total number of rows */

	        nbRows = om$dimension_of( varray = me->rows );
	        __DBGpr_int( "Number of rows", nbRows );

	        /* get the scroll to field value */

	        FIfld_get_value( VD_FP, VD_TBL_SCROLL_TO_FLD, 0, 0, &scrollVal,	
							&sel, &pos );
	        __DBGpr_int( "Scroll to value ", (int)scrollVal );

		if( scrollVal <= 0 )
		    break;

	        if( scrollVal > nbRows )
		    scrollVal = nbRows;
	
	        /* get number of visible rows */
	
	        FIfld_get_num_vis_rows( VD_FP, VD_TBL_VIS_COLDISP_FLD, &count );
	        __DBGpr_int( "Number of visible rows", count );

	        scrollVal = (scrollVal-1) * me->maxLinesPerRow ;
	        __DBGpr_int( "Scroll Position", (int)scrollVal );
	 
	        FIfld_set_active_row( VD_FP, VD_TBL_VIS_COLDISP_FLD, 
						(int)scrollVal, count/2 );

	        break;

	    case VD_TBL_ADD_ROW_BTN :

	        /* add a new row */

	        nbRows = om$dimension_of( varray = me->rows );
	        __DBGpr_int( "Number of rows", nbRows );

	        nbLines = (nbRows+1) * me->maxLinesPerRow;
	        __DBGpr_int( "ADD ROW : new number of lines", nbLines );

	        FIfld_set_num_rows( VD_FP, VD_TBL_VIS_COLDISP_FLD, nbLines );
	        FIfld_set_num_rows( VD_FP, VD_TBL_INV_COLDISP_FLD, nbLines );

	        /* enhance the me->rows vla */

	        nbRows = om$dimension_of( varray	= me->rows );
	        status = om$vla_set_dimension(	varray	= me->rows,
						size	= nbRows + 1 );
	        CheckRC( status, 1 );
	        if( !(status & 1) )
	        {
		    UI_status( "Error encountered : command terminated" );
		    me->state = _terminate;
	        }

	        me->rows[nbRows].rowId.objid = NULL_OBJID;
	        me->rows[nbRows].nbObjs = 0;
	        me->rows[nbRows].startIndex = 0;
	        me->rows[nbRows].qty.nSflag = VD_DRWLO_EN_COUNT;
	        me->rows[nbRows].qty.szExp[0] = '\0';
	        me->rows[nbRows].flag = VD_DRW_ROW_NEW;

		/* update row */

		status = _VD_SEND_MY( VDCmdCrTbl.VDupdateRow( &msg, nbRows ) );
		CheckRC( status, msg );

	        /* initialize the row serial number */

	        rowNo = nbLines / me->maxLinesPerRow;
	        __DBGpr_int( "ADD ROW : new row serial number", rowNo );

	        FIfld_set_value( VD_FP, VD_TBL_VIS_COLDISP_FLD, 
					nbLines-me->maxLinesPerRow, 0, 
					(double)rowNo, FALSE );
	        FIfld_set_value( VD_FP, VD_TBL_INV_COLDISP_FLD, 
					nbLines-me->maxLinesPerRow, 0, 
					(double)rowNo, FALSE );

	        /* refresh the form */

	        FIf_get_size( VD_FP, &xhi, &yhi );
	        FIg_get_location( VD_FP, VD_TBL_VIS_COLTITL_FLD, &xlo, &ylo );
	        FIf_paint_area( VD_FP, xlo, ylo, xhi, yhi );

	        break;

	    case VD_TBL_DEL_ROW_BTN :

	        /* count the number of selected rows */

	        count = 0;

	        nbRows = om$dimension_of( varray	= me->rows );
	        __DBGpr_int( "Current dimension of me->rows", nbRows );

	        nbLines = nbRows * me->maxLinesPerRow;

	        for( i = 0 ; i < nbLines ; i=i+me->maxLinesPerRow )
	        {
		    FIfld_get_text( VD_FP, VD_TBL_VIS_COLDISP_FLD, i, 0, 10,
						buf, &sel, &pos );
		    if( sel )
		        count++;
	        }
    
	        if( !count )
	        {
		    FIfld_set_text( VD_FP, FI_MSG_FIELD, 0, 0, 
						"No row selected", FALSE );
		    break;
	        }

	        if( count > 1 )
	        {
	            sprintf( info, "Delete %d rows?", count );
	            retCode = GRconfirm_box( info );

	            if( !retCode )
	                break;
	        }
	    
	        /* delete the rows */

	        for( i = nbLines - me->maxLinesPerRow ; i >= 0 ; 
						i=i-me->maxLinesPerRow )
	        {
		    FIfld_get_text( VD_FP, VD_TBL_VIS_COLDISP_FLD, i, 0, 10,
						buf, &sel, &pos );
		    if( sel )
		    {
		        /* delete in form */

		        rowNo = i / me->maxLinesPerRow;
		        __DBGpr_int( "Row Number to delete", rowNo );
		    
		        FIfld_delete_rows( VD_FP, VD_TBL_VIS_COLDISP_FLD, i,
							me->maxLinesPerRow );
		        FIfld_delete_rows( VD_FP, VD_TBL_INV_COLDISP_FLD, i,
							me->maxLinesPerRow );

		        /* 
		         * delete from me->rows and me->locObjs
		         */

		        /* delete the row object if present */

		        if( me->rows[rowNo].rowId.objid != NULL_OBJID )
		        {
			    __DBGpr_obj( "Deleting row object", 
					me->rows[rowNo].rowId );

			    status =
			    _VD_SEND_MY( VDCmdCrTbl.VDrowToBeDeleted( 
						&msg,
						me->rows[rowNo].rowId ) );
			    __CheckRC( status, msg, 
					"VDCmdCrTbl.VDrowToBeDeleted", wrapup );
		        }

		        /* remove the corresponding objects from the obj list */

		        count = me->rows[rowNo].nbObjs;    

		        nbObjs = om$dimension_of( varray	= me->locObjs );

		        if( count > 0 )
		        {
			    for( j = me->rows[rowNo].startIndex ; 
						j < nbObjs - count ; j++ )
			        me->locObjs[j] = me->locObjs[ j+count ];
		        }
    
		        om$vla_set_dimension(	varray	= me->locObjs,
						size	= nbObjs - count );

		        /* delete the entry from me->rows */

		        for( j = rowNo ; j < nbRows-1 ; j++ )
			    me->rows[j] = me->rows[j+1];
		        nbRows--;
		    }
	        }

	        om$vla_set_dimension(	varray	= me->rows,
					size	= nbRows );
	        __DBGpr_int( "New size of me->rows", nbRows );

		/* if all rows are deleted, break */

		if( !nbRows )
		    break;

	        /* update start index */

	        me->rows[0].startIndex = 0;
	        for( i = 1 ; i < nbRows ; i++ )
		    me->rows[i].startIndex = me->rows[i-1].startIndex + 
						me->rows[i-1].nbObjs;

	        /* update the 1st column */

	        status =
	        _VD_SEND_MY( VDCmdCrTbl.VDupdate1stCol( &msg ) );
	        CheckRC( status, msg );

#ifdef vdsDEBUG
    printf( "\n\tNew list of located objects :\n" );
    for( i = 0 ; i < nbObjs - count ; i++ )
        printf("\t\tObj # %d = [%d, %d]\n", i,  me->locObjs[i].obj_id.objid,
                                                me->locObjs[i].obj_id.osnum );
#endif

	        break;

	    case VD_TBL_SCROLL_LEFT_BTN :

	        if( !me->nbSelCols )
		    break;

	        if( me->selColList[0] == 1 )
	        {
		    FIfld_set_text( VD_FP, FI_MSG_FIELD, 0, 0, 
				"Cannot scroll further", FALSE );
		    break;
	        }

		/* Modified by Ming for TR179900802 and TR179901025 */

		/* get total number of columns */
                FIfld_get_num_rows( VD_FP, VD_TBL_SELCOL_LIST_FLD,  &nbCols );
                __DBGpr_int( "Total number of columns", nbCols );

		nbSelCols_old = me->nbSelCols;
 		for( k = 1 ; k <= nbSelCols_old ; k++ )
		{
		  status =
		  _VD_SEND_MY( VDCmdCrTbl.VDcheckColSize(&msg, gadget_label) );
		  CheckRC( status, 1 );

		  if( msg == MSSUCC ) break; 
		
		  /*
		  ** if we cannot fit columns, do nothing
		  */
		  if( (msg!=MSSUCC) && (k==nbSelCols_old) )
		  {
                    fit_flag = 0;
                    break;
                  }

		  for( i = 0 ; i < nbCols ; i++ )
                    FImcf_set_select( VD_FP, VD_TBL_SELCOL_LIST_FLD, i, FALSE );

                  for( i = 0 ; i < me->nbSelCols-1 ; i++ )
                    FImcf_set_select( VD_FP,
				      VD_TBL_SELCOL_LIST_FLD,
                                      me->selColList[i]-1,
				      TRUE );

		  /*
		  ** update the list of selected columns
		  */
		  status =
                  _VD_SEND_MY( VDCmdCrTbl.form_notification( 
					  form_label,
					  VD_TBL_SHOW_SELCOL_BTN,
					  value,
					  form_ptr) );
                  CheckRC( status, 1 );
		}

		if( !fit_flag ) break;

		/* update the column selection */

	        FIfld_get_num_rows( VD_FP, VD_TBL_SELCOL_LIST_FLD,  &nbCols );
	        __DBGpr_int( "Total number of columns", nbCols );
	
		for( i = 0 ; i < nbCols ; i++ )
    	            FImcf_set_select( VD_FP, VD_TBL_SELCOL_LIST_FLD, i, FALSE );
		    
		for( i = 0 ; i < me->nbSelCols ; i++ )
    	            FImcf_set_select( VD_FP, VD_TBL_SELCOL_LIST_FLD, 
				me->selColList[i]-1, TRUE );

	        /* delete the last column */

	        colToDelete = me->nbSelCols;
	        __DBGpr_int( "Column number to delete", colToDelete );

		FImcf_set_active_col( VD_FP, VD_TBL_VIS_COLDISP_FLD, 0, 0 );

	        status = 
	        _VD_SEND_MY( VDCmdCrTbl.VDdeleteVisCol( &msg, colToDelete ) );
	        CheckRC( status, msg );

    	        FImcf_set_select( VD_FP, VD_TBL_SELCOL_LIST_FLD, 
				me->selColList[colToDelete-1]-1, FALSE );
    
	        /* insert the column preceding the first one */

	        colToInsert = me->selColList[0] - 1;
	        __DBGpr_int( "Column number to insert", colToInsert );

	        status = 
	        _VD_SEND_MY( VDCmdCrTbl.VDinsertVisCol( &msg, colToInsert, 1 ));
	        CheckRC( status, msg );

    	        FImcf_set_select( VD_FP, VD_TBL_SELCOL_LIST_FLD, 
						colToInsert-1, TRUE );

	        FIfld_set_active_row( VD_FP, VD_TBL_SELCOL_LIST_FLD, 
						colToInsert-1, 1 );

	        /* update the list of selected columns */

	        status =
	        _VD_SEND_MY( VDCmdCrTbl.VDstoreSelectedColumnList( &msg ) );
	        CheckRC( status, msg );

		/* 
		 * poke the active row, so that forms aligns the
		 * column data properly
		 */

		FIfld_get_active_row( VD_FP, VD_TBL_VIS_COLDISP_FLD, &row, &pos );
		FIfld_pos_cursor( VD_FP, VD_TBL_VIS_COLDISP_FLD, 
					row, 0, 0, 0, 0, 0 );

	        /* refresh the form */

	        FIf_get_size( VD_FP, &xhi, &yhi );
	        FIg_get_location( VD_FP, VD_TBL_VIS_COLTITL_FLD, &xlo, &ylo );
	        FIf_paint_area( VD_FP, xlo, ylo, xhi, yhi );

		/* set selection for col titles, by ylong */
		for( i = 0; i < me->nbSelCols; i++ ) 
		{
		   for( j = 0; j < me->maxLinesPerRow; j++ ) 
		   {
			FIfld_set_select( VD_FP,VD_TBL_VIS_COLTITL_FLD, j, i+1, 
					colSelected[me->selColList[i]]);
		   }
		}

	        break;
    
	    case VD_TBL_SCROLL_RIGHT_BTN :

	        if( !me->nbSelCols )
		    break;

	        /* get total number of columns */

	        FIfld_get_num_rows( VD_FP, VD_TBL_SELCOL_LIST_FLD,  &nbCols );
	        __DBGpr_int( "Total number of columns", nbCols );

	        if( me->selColList[me->nbSelCols - 1] == nbCols )
	        {
		    FIfld_set_text( VD_FP, FI_MSG_FIELD, 0, 0, 
				"Cannot scroll further", FALSE );
		    break;
	        }

		/* check size */

		/* Modified by Ming for TR179900802 and TR179901025 */

		nbSelCols_old = me->nbSelCols;
 		for( k = 1 ; k <= nbSelCols_old ; k++ )
		{
		  status =
		  _VD_SEND_MY( VDCmdCrTbl.VDcheckColSize(&msg, gadget_label) );
		  CheckRC( status, 1 );

		  if( msg == MSSUCC ) break; 
		
		  /*
		  ** if we cannot fit columns, do nothing
		  */
		  if( (msg!=MSSUCC) && (k==nbSelCols_old) )
		  {
                    fit_flag = 0;
                    break;
                  }

		  for( i = 0 ; i < nbCols ; i++ )
                    FImcf_set_select( VD_FP, VD_TBL_SELCOL_LIST_FLD, i, FALSE );

                  for( i = 1 ; i < me->nbSelCols ; i++ )
                    FImcf_set_select( VD_FP,
				      VD_TBL_SELCOL_LIST_FLD,
                                      me->selColList[i]-1,
				      TRUE );

		  /*
		  ** update the list of selected columns
		  */
		  status =
                  _VD_SEND_MY( VDCmdCrTbl.form_notification( 
					  form_label,
					  VD_TBL_SHOW_SELCOL_BTN,
					  value,
					  form_ptr) );
                  CheckRC( status, 1 );
		}

		if( !fit_flag ) break;

		/* update the column selection */

		for( i = 0 ; i < nbCols ; i++ )
    	            FImcf_set_select( VD_FP, VD_TBL_SELCOL_LIST_FLD, i, FALSE );
		    
		for( i = 0 ; i < me->nbSelCols ; i++ )
    	            FImcf_set_select( VD_FP, VD_TBL_SELCOL_LIST_FLD, 
				me->selColList[i]-1, TRUE );

	        /* delete the first column */

	        colToDelete = 1;
	        __DBGpr_int( "Column number to delete", colToDelete );

		FImcf_set_active_col( VD_FP, VD_TBL_VIS_COLDISP_FLD, 0, 0 );

	        status = 
	        _VD_SEND_MY( VDCmdCrTbl.VDdeleteVisCol( &msg, colToDelete ) );
	        CheckRC( status, msg );

    	        FImcf_set_select( VD_FP, VD_TBL_SELCOL_LIST_FLD, 
						me->selColList[0]-1, FALSE );

	        /* insert the column succeeding the last one */

	        colToInsert = me->selColList[me->nbSelCols-1] + 1;
	        __DBGpr_int( "Column number to insert", colToInsert );

	        FImcf_get_num_vis_cols( VD_FP, VD_TBL_VIS_COLDISP_FLD, 
								&nbVisCols );
	        __DBGpr_int( "Number of visible columns = newPos", nbVisCols );

	        status = 
	        _VD_SEND_MY( VDCmdCrTbl.VDinsertVisCol(	&msg, 
							colToInsert, 
							nbVisCols ) );
	        CheckRC( status, msg );

    	        FImcf_set_select( VD_FP, VD_TBL_SELCOL_LIST_FLD, 
						colToInsert-1, TRUE );

	        FIfld_set_active_row( VD_FP, VD_TBL_SELCOL_LIST_FLD, 
						colToInsert-1, 2 );

	        /* update the list of selected columns */

	        status =
	        _VD_SEND_MY( VDCmdCrTbl.VDstoreSelectedColumnList( &msg ) );
	        CheckRC( status, msg );

		/* 
		 * poke the active row, so that forms aligns the
		 * column data properly
		 */

		FIfld_get_active_row( VD_FP, VD_TBL_VIS_COLDISP_FLD, &row, &pos );
		FIfld_pos_cursor( VD_FP, VD_TBL_VIS_COLDISP_FLD, 
					row, 0, 0, 0, 0, 0 );

	        /* refresh the form */

	        FIf_get_size( VD_FP, &xhi, &yhi );
	        FIg_get_location( VD_FP, VD_TBL_VIS_COLTITL_FLD, &xlo, &ylo );
	        FIf_paint_area( VD_FP, xlo, ylo, xhi, yhi );

		/* set selection for col titles, by ylong */
		for( i = 0; i < me->nbSelCols; i++ ) 
		{
		   for( j = 0; j < me->maxLinesPerRow; j++ ) 
		   {
			FIfld_set_select( VD_FP, VD_TBL_VIS_COLTITL_FLD, j, i+1,
					colSelected[me->selColList[i]]);
		   }
		}

	        break;

	    case VD_TBL_REV_ROWVALS_BTN :

	        /*
	         * Show the default/computed values of the row
	         * This includes fixed and variable text values
	         */

	        count = 0;

	        nbRows = om$dimension_of( varray	= me->rows );
	        nbLines = nbRows * me->maxLinesPerRow;
	        __DBGpr_int( "Number of rows", nbRows );

	        for( i = 0 ; i < nbLines && count < 2 ; i=i+me->maxLinesPerRow )
	        {
		    FIfld_get_text( VD_FP, VD_TBL_VIS_COLDISP_FLD, i, 0, 10,
						buf, &sel, &pos );
		    if( sel )
		    {
		        rowNo = i;
		        count++;
		    }
	        }

	        if( !count )
	        {
		    FIfld_set_text( VD_FP, FI_MSG_FIELD, 0, 0, 
						"No row selected", FALSE );
		    break;
	        }

	        if( count > 1 )
	        {
		    FIfld_set_text( VD_FP, FI_MSG_FIELD, 0, 0, 
					"Multiple rows selected", FALSE );
		    break;
	        }

	        rowNo /= me->maxLinesPerRow;
	        __DBGpr_int( "Row number to review", rowNo );

	        /* update the review attribute field */
    	
	        status = _VD_SEND_MY( VDCmdCrTbl.VDupdateOrgRowValues( &msg,
								rowNo ) );
	        CheckRC( status, msg );

	        break;

	    case VD_TBL_REV_ROWVALS_FLD :
	        break;

	    case VD_TBL_VIS_COLTITL_FLD:
		/* This case is added for reset to original values, by ylong */
		FImcf_get_active_col( VD_FP, VD_TBL_VIS_COLTITL_FLD, &col, &pos);
		FIfld_get_active_row( VD_FP, VD_TBL_VIS_COLTITL_FLD, &row, &pos);
		FIfld_get_select(  VD_FP, VD_TBL_VIS_COLTITL_FLD, row, col, &sel);
		FIg_get_text( VD_FP, VD_TBL_RESET_ROW_TGL, resetOpt );
		for( i = 0; i < me->maxLinesPerRow; i++ ) {
		   if (	!strcmp(resetOpt, VD_TBL_RESET_OPT_ROW) ||
			!strcmp(resetOpt, VD_TBL_RESET_OPT_TBL) ) 
		   {
			FImcf_set_select( VD_FP, VD_TBL_VIS_COLTITL_FLD, 
							i, sel);
		   }
		   else
		   {
			FIfld_set_select( VD_FP, VD_TBL_VIS_COLTITL_FLD, 
							i, col, sel);
		   }
		}
		
		if (	!strcmp(resetOpt, VD_TBL_RESET_OPT_ROW) ||
			!strcmp(resetOpt, VD_TBL_RESET_OPT_TBL) ) 
		{
		   FImcf_get_num_cols( VD_FP, VD_TBL_INV_COLDISP_FLD, &nbInvCols);
		   for( i = 0; i < nbInvCols; i++ ) 
		      colSelected[i] = sel;
		}
		else
		{
		   colSelected[ me->selColList[col-1]] = sel;
		}

		break;

	    case VD_TBL_RESET_ROW_TGL:

		for( i = 0; i < BUFLEN; i++ ) {
		   colSelected[i] = 0;
		}
		
		for( i = 0; i < me->maxLinesPerRow; i++ ) {
		   FImcf_set_select( VD_FP, VD_TBL_VIS_COLTITL_FLD, i, FALSE );
		}

		FIfld_get_num_rows( VD_FP, VD_TBL_VIS_COLDISP_FLD, &nbRows );
		for( i = 0; i < nbRows; i++ ) {
		   FImcf_set_select( VD_FP, VD_TBL_VIS_COLDISP_FLD, i, FALSE );
		}
		
		break;

	    case VD_TBL_RESET_ROW_BTN:
		/* this case is added for reset to original values, by ylong */
		nbDatRecs = om$dimension_of( varray = me->datRecs );

		FIg_get_text( VD_FP, VD_TBL_RESET_ROW_TGL, resetOpt );
		FIfld_get_num_rows( VD_FP, VD_TBL_INV_COLDISP_FLD, &nbInvRows);
	        FImcf_get_num_cols( VD_FP, VD_TBL_INV_COLDISP_FLD, &nbInvCols );
		FIfld_get_num_rows( VD_FP, VD_TBL_VIS_COLDISP_FLD, &nbRows );

		for( i = 0; i < nbRows; i++ ) 
		{
		   FIfld_get_select( VD_FP, VD_TBL_VIS_COLDISP_FLD, i, 0, &sel);

		   if (	!strcmp(resetOpt, VD_TBL_RESET_OPT_TBL) ||
			!strcmp(resetOpt, VD_TBL_RESET_OPT_COL) )
		   {
			sel = TRUE;
		   }
		   if( !sel )  continue;

		   for( j = 0; j < nbInvCols; j++ ) 
		   {
		      if( !strcmp( resetOpt, VD_TBL_RESET_OPT_ROW ) ||
			  !strcmp( resetOpt, VD_TBL_RESET_OPT_TBL ) )
		      {
			 colSelected[j] = 1;
		      }
		      if( !colSelected[j] ) continue;

		      for( k = 0; k < nbDatRecs; k++ ) 
		      {
		         if( me->datRecs[k].rectyp != VD_DRWLO_EN_USERDEFINED &&
			     me->datRecs[k].rectyp != VD_DRWLO_EN_ITEMNO      &&
			     me->datRecs[k].colno == j )
		         {
			    _FREE( datValue );
			    status = VDdrw_getFldValue( &msg,
                                    me->rows[i].nbObjs,
                                    &me->locObjs[me->rows[i].startIndex],
                                    me->datRecs[k],
                                    me->rows[i].qty,
                                    &me->rows[i].rowId,
                                    &datValue );
			    if( !(status&msg&1) ) break;

			    FIfld_set_text( VD_FP, VD_TBL_INV_COLDISP_FLD, 
						i, j, datValue, FALSE );
			    for( col = 1; col <= me->nbSelCols; col++ )
			    {
				if( me->selColList[col-1] == j )
				{
				  FIfld_set_text( VD_FP, VD_TBL_VIS_COLDISP_FLD,
						  i, col, datValue, FALSE );
				  break;
				}
			    }

			    break;
		         }
		      }
		   }
		}

		for( i = 0; i < BUFLEN; i++ ) {
		   colSelected[i] = 0;
		}
		
		for( i = 0; i < me->maxLinesPerRow; i++ ) {
		   FImcf_set_select( VD_FP, VD_TBL_VIS_COLTITL_FLD, i, FALSE );
		}

		for( i = 0; i < nbRows; i++ ) {
		   FImcf_set_select( VD_FP, VD_TBL_VIS_COLDISP_FLD, i, FALSE );
		}
		
		break;

	    default :
	        break;
        }

	break;

      /*    ---------------- VDsplitTable form ----------------- */

      case SPLIT_TABLE :

        switch( gadget_label )
        {
	    case FI_ACCEPT :

		/* validate inputs */

		status = _VD_SEND_MY( VDCmdCrTbl.VDprocessSplitForm( &msg ) );
		CheckRC( status, msg );

		if( status == OM_E_NODYNMEM )
		{
		    UI_status( "Error encountered : command terminated" );
		    me->state = _terminate;
	        }

		if( status == OM_W_ABORT )
		    break;

	        resp = VD_FORM_ACCEPT;
	        ex$putque(	msg		= &msg,
				response 	= &resp );
	        break;

	    case FI_CANCEL :
	        resp = VD_FORM_CANCEL;
	        ex$putque(	msg		= &msg,
				response 	= &resp );
	        break;

	    case VD_TBL_SPL_LOC_ROW_BTN :
	        resp = VD_TBL_LOCATE_ROW;
	        ex$putque(	msg		= &msg,
				response 	= &resp );
		break;

	    case VD_TBL_SPL_PART_LST_FLD :

		status = _VD_SEND_MY( VDCmdCrTbl.VDprocessSplitForm( &msg ) );
		CheckRC( status, msg );

		if( status == OM_E_NODYNMEM )
		{
		    UI_status( "Error encountered : command terminated" );
		    me->state = _terminate;
	        }
		break;
		
	    default :
		break;
	}

	break;

      default :
	break;
    }

wrapup :

    _FREE( itemList );
    _FREE(datValue);

    End
    return OM_S_SUCCESS;
}

end implementation VDCmdCrTbl;
