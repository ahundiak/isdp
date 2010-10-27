/* $Id: VDtblInsDel.I,v 1.2 2001/05/07 14:25:13 ylong Exp $ */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vds/vdtbl/cmd / VDtblUpdCol.I
 *
 * Description:
 *	Implementation of the following methods for VDCmdCrTbl :
 *		VDdeleteVisCol
 *		VDinsertVisCol
 *
 * Dependencies:
 *
 * History:
 *
 *      04/14/95        R. Manem        Creation
 *      07/14/95        R. Manem        TR # 179526736
 *	05/07/01	ylong		CR5119
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
  Public Message VDdeleteVisCol

  Abstract
        This method deletes a column from the vis mcf.  It updates the 
	corresponding inv mcf col before deletion

  Arguments
        IGRlong         *sts            O       Return code
        IGRint          colIndex        I       Col index to delete

  Status/Return Code
      status == OM_S_SUCCESS

 ---------------------------------------------------------------------------
-me*/

method VDdeleteVisCol(	IGRlong		*msg;
			IGRint		colIndex )
{
    IGRint		destCol,
			nbVisCols,
			nbRows,
			updFlag = 0;
    IGRlong		status = OM_S_SUCCESS;
    
    SetProc( VDCmdCrTbl.VDdeleteVisCol ); Begin
    *msg = MSSUCC;

    __DBGpr_int( "Deleting column", colIndex );

    if( me->mytype == CREATE_TABLE )
	updFlag = FALSE;
    else if( me->mytype == MODIFY_TABLE )
	updFlag = TRUE;

    FImcf_get_num_vis_cols( VD_FP, VD_TBL_VIS_COLTITL_FLD, &nbVisCols );
    nbVisCols--;
    __DBGpr_int( "New Number of visible columns", nbVisCols );

    /* copy column, only if there is at least one row */

    nbRows = om$dimension_of( varray = me->rows );
    __DBGpr_int( "Number of rows", nbRows );

    if( nbRows )
    {
	destCol = me->selColList[colIndex-1];

#ifdef vdsDEBUG
    printf( "\t\tCopying vis col %d to inv col %d\n", colIndex, destCol );
#endif

	status =
	_VD_SEND_MY( VDCmdCrTbl.VDcopyColumn( 	msg, 
    						VD_TBL_VIS_COLDISP_FLD, 
						VD_TBL_INV_COLDISP_FLD,
						colIndex, destCol,
						updFlag ) );
	__CheckRC( status, *msg, "VDCmdCrTbl.VDcopyColumn", wrapup );
    }

    if( me->tblType == VD_DRW_TBLTYPE_BOM )
    {
        FImcf_delete_col( VD_FP, VD_TBL_REV_ROWVALS_FLD, colIndex );
    	FImcf_set_num_vis_cols( VD_FP, VD_TBL_REV_ROWVALS_FLD, nbVisCols );
    	FIg_activate( VD_FP, VD_TBL_REV_ROWVALS_FLD );
    	FIg_display( VD_FP, VD_TBL_REV_ROWVALS_FLD );
    }

    FImcf_delete_col( VD_FP, VD_TBL_VIS_COLDISP_FLD, colIndex );
    FImcf_delete_col( VD_FP, VD_TBL_VIS_COLTITL_FLD, colIndex );

    FImcf_set_num_vis_cols( VD_FP, VD_TBL_VIS_COLTITL_FLD, nbVisCols );
    FImcf_set_num_vis_cols( VD_FP, VD_TBL_VIS_COLDISP_FLD, nbVisCols );

    FIg_activate( VD_FP, VD_TBL_VIS_COLTITL_FLD );
    FIg_activate( VD_FP, VD_TBL_VIS_COLDISP_FLD );

    FIg_display( VD_FP, VD_TBL_VIS_COLTITL_FLD );
    FIg_display( VD_FP, VD_TBL_VIS_COLDISP_FLD );

wrapup :
    End
    return status;
}

/*+me
 ---------------------------------------------------------------------------
  Public Message VDinsertVisCol

  Abstract
        This method inserts a column in the vis mcf.  It updates the 
	inserted column, by copying data from the corresponding inv column.

  Arguments
        IGRlong         *sts            O       Return code
        IGRint          colNo        	I       Col index of inv mcf to 
						insert in the vis mcf
	IGRint		newPos		I	Pos in vis mcf, to insert col

  Status/Return Code
      status == OM_S_SUCCESS

 ---------------------------------------------------------------------------
-me*/

method VDinsertVisCol(	IGRlong		*msg;
			IGRint		colNo;
			IGRint		newPos )
{
    IGRint		sel, pos,
			attr_mask,
			nbVisCols;
    double		width;
    IGRlong		status = OM_S_SUCCESS;
    
    SetProc( VDCmdCrTbl.VDinsertVisCol ); Begin
    *msg = MSSUCC;

    FImcf_get_num_vis_cols( VD_FP, VD_TBL_VIS_COLTITL_FLD, &nbVisCols );
    __DBGpr_int( "Initial number of visible columns", nbVisCols );

    /* width of column */

    FIfld_get_value( VD_FP, VD_TBL_SELCOL_LIST_FLD, colNo-1, 2, &width,
					&sel, &pos );
#ifdef vdsDEBUG
    printf( "\t\tCol No = %d, newPos = %d, width = %d\n", colNo, 
				newPos, (IGRint)width );
#endif

    /* column title */

    FImcf_insert_col( VD_FP, VD_TBL_VIS_COLTITL_FLD, newPos, (int)width,
						FI_MULTI_SELECT, FI_ALPHA );
				// ylong	FI_REVIEW, FI_ALPHA );
    FIg_activate( VD_FP, VD_TBL_VIS_COLTITL_FLD );
    FIfld_set_num_vis_chars( VD_FP, VD_TBL_VIS_COLTITL_FLD, newPos, 
						(int)width );
    FIfld_get_attr( VD_FP, VD_TBL_VIS_COLTITL_FLD, newPos, &attr_mask );
    attr_mask = attr_mask | FI_HORT_SCROLL | FI_DISPLAY_HSCROLL;
    FIfld_set_attr( VD_FP, VD_TBL_VIS_COLTITL_FLD, newPos, attr_mask );


    /* data column */

    FImcf_insert_col( VD_FP, VD_TBL_VIS_COLDISP_FLD, newPos, (int)width,
						FI_INSERT, FI_ALPHA );
    FIg_activate( VD_FP, VD_TBL_VIS_COLDISP_FLD );
    FIfld_set_num_vis_chars( VD_FP, VD_TBL_VIS_COLDISP_FLD, newPos, 
						(int)width );
    FIfld_get_attr( VD_FP, VD_TBL_VIS_COLDISP_FLD, newPos, &attr_mask );
    attr_mask = attr_mask | FI_HORT_SCROLL | FI_DISPLAY_HSCROLL 
							| FI_NOTIFY_BY_LINE;
    FIfld_set_attr( VD_FP, VD_TBL_VIS_COLDISP_FLD, newPos, attr_mask );

    /* rev attr mcf for BOM */

    if( me->tblType == VD_DRW_TBLTYPE_BOM )
    {
	FImcf_insert_col( VD_FP, VD_TBL_REV_ROWVALS_FLD, newPos, (int)width,
					FI_REVIEW, FI_ALPHA );
	FIg_activate( VD_FP, VD_TBL_REV_ROWVALS_FLD );
	FIfld_set_num_vis_chars( VD_FP, VD_TBL_REV_ROWVALS_FLD, newPos, 
					(int)width );
        FIfld_get_attr( VD_FP, VD_TBL_REV_ROWVALS_FLD, newPos, &attr_mask );
        attr_mask = attr_mask | FI_HORT_SCROLL | FI_DISPLAY_HSCROLL;
        FIfld_set_attr( VD_FP, VD_TBL_REV_ROWVALS_FLD, newPos, attr_mask );
    }

    /* 
     * copy the contents for the new columns from the invisible columns 
     */

    /* data column */

    status =
    _VD_SEND_MY( VDCmdCrTbl.VDcopyColumn( 	msg, 
    						VD_TBL_INV_COLDISP_FLD, 
						VD_TBL_VIS_COLDISP_FLD,
						colNo, newPos,
						FALSE ) );
    __CheckRC( status, *msg, "VDCmdCrTbl.VDcopyColumn", wrapup );

    /* column title */

    status =
    _VD_SEND_MY( VDCmdCrTbl.VDcopyColumn( 	msg, 
    						VD_TBL_INV_COLTITL_FLD, 
						VD_TBL_VIS_COLTITL_FLD,
						colNo, newPos,
						FALSE ) );
    __CheckRC( status, *msg, "VDCmdCrTbl.VDcopyColumn", wrapup );

    /* update the number of visible columns */

    nbVisCols++;
    __DBGpr_int( "New Number of visible columns", nbVisCols );

    FImcf_set_num_vis_cols( VD_FP, VD_TBL_VIS_COLTITL_FLD, nbVisCols );
    FImcf_set_num_vis_cols( VD_FP, VD_TBL_VIS_COLDISP_FLD, nbVisCols );

    /* activate the gadgets and display them */

    FIg_activate( VD_FP, VD_TBL_VIS_COLTITL_FLD );
    FIg_activate( VD_FP, VD_TBL_VIS_COLDISP_FLD );

    FIg_display( VD_FP, VD_TBL_VIS_COLTITL_FLD );
    FIg_display( VD_FP, VD_TBL_VIS_COLDISP_FLD );

    if( me->tblType == VD_DRW_TBLTYPE_BOM )
    {
	FIfld_set_num_rows( VD_FP, VD_TBL_REV_ROWVALS_FLD, 0 );
	FImcf_set_num_vis_cols( VD_FP, VD_TBL_REV_ROWVALS_FLD, nbVisCols );
	FIg_activate( VD_FP, VD_TBL_REV_ROWVALS_FLD );
	FIg_display( VD_FP, VD_TBL_REV_ROWVALS_FLD );
    }

wrapup :
    End
    return status;
}

end implementation VDCmdCrTbl;
