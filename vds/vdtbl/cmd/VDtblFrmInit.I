/* $Id: VDtblFrmInit.I,v 1.1.1.1 2001/01/04 21:09:26 cvs Exp $ */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vds/vdtbl/cmd / VDtblFrmInit.I
 *
 * Description:
 *	Implementation of the following method for VDCmdCrTbl :
 *		init_create_form
 *		init_split_form
 *		update_form
 *
 * Dependencies:
 *
 * History:
 *
 *      04/14/95        R. Manem        Creation
 *      05/15/95        R. Manem        Modified method avoid updating
 *					inv columns here.
 *      07/14/95        R. Manem        Att driven symbol support
 *      07/19/95        R. Manem        Set max num rows for SELCOL_LIST fld
 *      11/19/99        ylong	        TR179900885
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
  Public Message init_create_form

  Abstract
        This method initializes the form

  Arguments
        IGRlong         *sts            O       Return code

  Notes/Remarks

  Status/Return Code
      status == OM_S_SUCCESS
 ---------------------------------------------------------------------------
-me*/

method  init_create_form ( long * sts )
{
    IGRint			i, j,
				sel, pos,
				nbFixRecs, nbDatRecs;
    long			attrMask = 0;
    IGRint			nbCols;
    IGRshort			nbAdsTbls = 0;
    IGRchar			(*adsNames)[VD_DRWLO_CHR_IDFLD] = NULL,
				buffer[VD_DRWLO_CHR_IDFLD];
    IGRlong			msg,
				status = OM_S_SUCCESS;
    struct VDdrw_colInfo	*colRecs = NULL;

    SetProc( VDCmdCrTbl.init_create_form ); Begin

    *sts = VD_SUCCESS;

    /* display/erase the proper gadget groups */

    if( me->tblType == VD_DRW_TBLTYPE_BOM )
	FIg_display( VD_FP, VD_TBL_BOM_BTNS_GRP );
    else
	FIg_erase( VD_FP, VD_TBL_BOM_BTNS_GRP );

    FIg_erase( VD_FP, VD_TBL_BOM_ATTR_GRP );
    FIg_erase( VD_FP, VD_TBL_COLDISP_GRP );
    FIg_erase( VD_FP, VD_TBL_ROWCNTS_GRP );

    /* 
     * initialize the list of columns 
     */

    nbFixRecs = om$dimension_of( varray	= me->fixRecs );
    nbDatRecs = om$dimension_of( varray	= me->datRecs );

    status =
    VDdrw_getColumnList( 	&msg, 
				nbFixRecs, nbDatRecs,
				me->fixRecs, me->datRecs,
				&nbCols, &me->maxLinesPerRow,
				&colRecs );

    if( !(status & msg & 1) )
    {
	*sts = VD_ERROR;
	UI_status( "Error encountered : command terminated" );
	goto wrapup;
    }

#ifdef vdsDEBUG
    printf("\tnbCols = %d, maxLinesPerRow = %d\n", nbCols, me->maxLinesPerRow );
#endif

    /* 
     * update the select column list field in the form.
     */

    FIfld_set_num_rows( VD_FP, VD_TBL_SELCOL_LIST_FLD, nbCols );
    FIfld_set_max_num_rows( VD_FP, VD_TBL_SELCOL_LIST_FLD, nbCols );

    for( i = 0 ; i < nbCols ; i++ )
    {
	FIfld_set_value( VD_FP, VD_TBL_SELCOL_LIST_FLD, i, 0, 
					(double)(i+1), FALSE );
	FIfld_set_text( VD_FP, VD_TBL_SELCOL_LIST_FLD, i, 1, 
					colRecs[i].colTitles[0], FALSE );
	FIfld_set_value( VD_FP, VD_TBL_SELCOL_LIST_FLD, i, 2, 
					(double)colRecs[i].nbChars, FALSE );
    }

    /*
     * initialize the number of columns for the invisible gadgets for 
     * column display :
     *		the title column
     *		sort column
     *		the data columns
     */

    /* 
     * if the maxLinesPerRow is more than 1 then, update the column title
     * gadgets
     */

    if( me->maxLinesPerRow > 1 )
    {
	/* enable vertical scrolling for the column title mcf */

	FImcf_get_attr( VD_FP, VD_TBL_VIS_COLTITL_FLD, &attrMask );
	attrMask = attrMask | FI_VERT_SCROLL | FI_DISPLAY_VSCROLL;
        FImcf_set_attr( VD_FP, VD_TBL_VIS_COLTITL_FLD, attrMask );
    }

    /* add the required columns for the invisible mcf fields */

    for( i = 0 ; i < nbCols ; i++ )
    {
	__DBGpr_int( "i", i );
	__DBGpr_int( "nbChars", colRecs[i].nbChars );

	/* column title field */

	FImcf_insert_col( VD_FP, VD_TBL_INV_COLTITL_FLD, i+1, 
				colRecs[i].nbChars, FI_REVIEW, FI_ALPHA );
    	FIg_activate( VD_FP, VD_TBL_INV_COLTITL_FLD );
	FIfld_set_num_vis_chars( VD_FP, VD_TBL_INV_COLTITL_FLD, i+1,
				colRecs[i].nbChars );

	/* data columns display field */

	FImcf_insert_col( VD_FP, VD_TBL_INV_COLDISP_FLD, i+1, 
				colRecs[i].nbChars, FI_INSERT, FI_ALPHA );
    	FIg_activate( VD_FP, VD_TBL_INV_COLDISP_FLD );
	FIfld_set_num_vis_chars( VD_FP, VD_TBL_INV_COLDISP_FLD, i+1,
				colRecs[i].nbChars );
    }

    /* set number of rows */

    __DBGpr_int( "MaxLinesPerRow ", me->maxLinesPerRow );

    FIfld_set_num_rows( VD_FP, VD_TBL_VIS_COLTITL_FLD, me->maxLinesPerRow );
    FIfld_set_max_num_rows( VD_FP, VD_TBL_VIS_COLTITL_FLD, me->maxLinesPerRow );
    FIg_activate( VD_FP, VD_TBL_VIS_COLTITL_FLD );

    FIfld_set_num_rows( VD_FP, VD_TBL_INV_COLTITL_FLD, me->maxLinesPerRow );
    FIfld_set_max_num_rows( VD_FP, VD_TBL_INV_COLTITL_FLD, me->maxLinesPerRow );
    FIg_activate( VD_FP, VD_TBL_INV_COLTITL_FLD );

    FIfld_set_num_rows( VD_FP, VD_TBL_INV_COLDISP_FLD, 0 );

    /* initialize the inv col title texts to empty string */

    for( i = 0 ; i < nbCols ; i++ )
	for( j = 0 ; j < me->maxLinesPerRow ; j++ )
	    FIfld_set_text( VD_FP, VD_TBL_INV_COLTITL_FLD, j, i+1, "", FALSE );

    /* update the column titles in the invisible column title field */

    for( i = 0 ; i < nbCols ; i++ )
    	for( j = 0 ; j < colRecs[i].nbLines ; j++ )
	{
#ifdef vdsDEBUG
	    printf("\n\ti = %d, j = %d, title = %s\n", i, j, 
					colRecs[i].colTitles[j] );
#endif
	    FIfld_set_text( VD_FP, VD_TBL_INV_COLTITL_FLD, j, i+1,
					colRecs[i].colTitles[j], FALSE );
	}

    FIg_activate( VD_FP, VD_TBL_INV_COLTITL_FLD );
    FIg_activate( VD_FP, VD_TBL_INV_COLDISP_FLD );

    /* initialize the list of att driven symbol tbl names */

    if( me->tblType == VD_DRW_TBLTYPE_BOM )
    {
	status = VD_adsym_getnm( &msg, FALSE, &nbAdsTbls, NULL );
	__CheckRC( status, msg, "VD_adsym_getnm", wrapup );
	__DBGpr_int( "No of ads tables", nbAdsTbls );

	if( nbAdsTbls )
	{
	    adsNames = (IGRchar (*)[VD_DRWLO_CHR_IDFLD]) malloc(
			sizeof(IGRchar) * VD_DRWLO_CHR_IDFLD * nbAdsTbls );
	  
	    if( !adsNames )
	    {
		*sts = VD_ERROR;
		UI_status( "Error in dynamic allocation : command terminated" );
		goto wrapup;
	    }
	    
	    status = VD_adsym_getnm( &msg, FALSE, &nbAdsTbls, 
						(IGRchar *)adsNames );
	    __CheckRC( status, msg, "VD_adsym_getnm", wrapup );
	    __DBGpr_int( "No of ads tables", nbAdsTbls );

	    FIfld_set_num_rows(  VD_FP, VD_TBL_ADS_FLD, nbAdsTbls );

	    for( i = 0 ; i < nbAdsTbls ; i++ )
	    {
		__DBGpr_str( "Ads Table name i", adsNames[i] );
		FIfld_set_text( VD_FP, VD_TBL_ADS_FLD, i, 0, adsNames[i], FALSE );
	    }

	    /* select the appropriate row, if applicable */

	    if( me->mytype == MODIFY_TABLE && strlen( me->adsTblName ) )
	    {
		for( i = 0 ; i < nbAdsTbls ; i++ )
		{
		    FIfld_get_text( VD_FP, VD_TBL_ADS_FLD, i, 0,
					VD_DRWLO_CHR_IDFLD, 
					(unsigned char *)buffer, &sel, &pos );

		    if( !strcmp( buffer, me->adsTblName ) )
		    {
		        __DBGpr_int( "Selecting row ", i );
			FIfld_set_select( VD_FP, VD_TBL_ADS_FLD, i, 0, TRUE );
		    }
		}
	    }
	}
    }
	    
wrapup :

    for( i = 0 ; i < nbCols ; i++ )
	_FREE( colRecs[i].colTitles );
    _FREE( colRecs );
    _FREE( adsNames );

    End
    return OM_S_SUCCESS;
}


/*+me
 ---------------------------------------------------------------------------
  Public Message init_split_form

  Abstract
        This method initializes the VDsplitTable form 

  Arguments
        IGRlong         *sts            O       Return code

  Notes/Remarks

  Status/Return Code
      status == OM_S_SUCCESS   
 ---------------------------------------------------------------------------
-me*/

method  init_split_form ( long * sts )
{
    IGRint		i,
			startRowNo,
			nbRows,
			nbParts = 0;
    IGRchar		buf[20];

    SetProc( VDCmdCrTbl.init_split_form ); Begin
    *sts = VD_SUCCESS;

    nbParts = om$dimension_of( varray	= me->cpyHdrs );
    __DBGpr_int( "Number of parts", nbParts );

    /* update total number of rows */

    sprintf( buf, "%d", me->splitLocs[nbParts-1] );
    __DBGpr_str( "total number of rows", buf );

    FIg_set_text( VD_FP, VD_TBL_SPL_NUM_ROWS_TXT, buf );

    /* set number of lines in the mcf */

    FIfld_set_num_rows( VD_FP, VD_TBL_SPL_PART_LST_FLD, nbParts );

    /* update the list of table part info */

    startRowNo = 1;
    for( i = 0 ; i < nbParts ; i++ )
    {
	/* table part number */

	FIfld_set_value( VD_FP, VD_TBL_SPL_PART_LST_FLD, i, 0, 
					(double)(i+1), FALSE );

	/* start row number */

	FIfld_set_value( VD_FP, VD_TBL_SPL_PART_LST_FLD, i, 1, 
					(double)startRowNo, FALSE );

	/* end row number */

	FIfld_set_value( VD_FP, VD_TBL_SPL_PART_LST_FLD, i, 2, 
					(double)me->splitLocs[i], FALSE );

	/* number of rows */

	nbRows = me->splitLocs[i] - startRowNo + 1;
	__DBGpr_int( "NUmber of rows in part", nbRows );
	FIfld_set_value( VD_FP, VD_TBL_SPL_PART_LST_FLD, i, 3, 
					(double)nbRows, FALSE );

	/* value of the starting row number of the next table part */

	startRowNo = me->splitLocs[i] + 1;
    }

    End
    return OM_S_SUCCESS;
}


/*+me
 ---------------------------------------------------------------------------
  Public Message update_form

  Abstract
        This method initialized the columns of the invisible mcf, for the
        newly located objects.

  Arguments
        IGRlong         *sts            O       Return code

  Notes/Remarks

  Status/Return Code
      *sts =    VD_SUCCESS
                VD_ERROR        (if no memory)
 ---------------------------------------------------------------------------
-me*/

method  update_form ( long * sts )
{
    IGRint		nbRows = 0,
			startRowNo;
    IGRlong		status = OM_S_SUCCESS,
			msg = MSSUCC;
    SetProc( VDCmdCrTbl.update_form ); Begin

    *sts = VD_SUCCESS;

    /* set up the invisible data field */

    FIfld_get_num_rows( VD_FP, VD_TBL_INV_COLDISP_FLD, &nbRows );
    startRowNo = nbRows / me->maxLinesPerRow;

    /* Following line is added by ylong for TR179900885. To resume previous
     * version, just remove it, and you also need to restore VDtblSumItm.I
     */
    startRowNo = 0 ;


    __DBGpr_int( "Total no of rows in mcf", nbRows );
    __DBGpr_int( "Starting row number", startRowNo );

    status =
    _VD_SEND_MY( VDCmdCrTbl.VDinitInvDataCols( &msg, startRowNo ) );
    CheckRC( status, msg );

    if( !(status & msg & 1) )
    {
	*sts = VD_ERROR;
	UI_status( "Error encountered : command terminated" );
 	goto wrapup;
    }

wrapup :
    End
    return OM_S_SUCCESS;
}

end implementation VDCmdCrTbl;
