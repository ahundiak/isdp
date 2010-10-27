/* $Id: VDtblIntFTbl.I,v 1.1.1.1 2001/01/04 21:09:26 cvs Exp $ */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vds/vdtbl/cmd / VDtblMisc.I
 *
 * Description:
 *      Implementation of the following methods for VDCmdCrTbl :
 *		init_from_table
 *
 * Dependencies:
 *
 * History:
 *
 *      05/15/95        R. Manem        Creation
 *      09/18/95        R. Manem        Fixed bug in init_from_table :
 *					Take care of deleted model objects,
 *					resulting in different values for
 *					initial set count and final set
 *					count with list of objects
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

#include "macro.h"

#include "VDdrwlo.h"
#include "VDdrwlo_pr.h"
#include "VDdrwtbl.h"
#include "VDtblCmdDef.h"

#include "VDCmdDef.h"
#include "FI.h"
#include "FEI.h"


extern GRclassid	OPP_VDdrwTblRow_class_id,
				OPP_VDdrwSet_class_id;

from VDdrwTbl		import	VDgetTotalNbOfRows;
from VDdrwTblHdr	import	VDgetRowInfo, VDrowNoToGRid;
from VDdrwTblRow	import 	VDdeleteRow, VDgetParentObjectList,
				VDgetQtyExpr,
				VDgetCurrentRowValues;
from VDdrwSet		import 	VDinitSet, VDaddObjectsToSet;

/*+me
 ---------------------------------------------------------------------------
  Public Message init_from_table

  Abstract
        This method initializes the instance data from the located table.
        This message is sent during "Modify Table" and "Split Table" 
	command after locating an existing table.

  Arguments
        IGRlong         *sts            O       Return code

  Notes/Remarks

  Status/Return Code
      *sts =    VD_SUCCESS
                VD_ERROR        (if no memory)
 ---------------------------------------------------------------------------
-me*/

method init_from_table ( long * sts )
{
    IGRint		i, j,
			ind, row,
			nbRows, nbLines, nbCols,
			nbObjs, tmpNbObjs,
			nbHdrs, nbHdrRows,
			nbValues,
			*lineNos = NULL,
			*colNos = NULL,
			startRowNo;
    IGRchar		**values = NULL;
    IGRlong		msg,
			status = OM_S_SUCCESS;

    SetProc( VDCmdCrTbl.init_from_table ); Begin

    /*
     * For "Modify Table" command, all the fields in me->rows need to be
     * initialized.  The me->locObjs also needs to be set up.
     * For "Split Table" command, only the rowIds and flags are needed.
     * The me->locObjs vla can be ignored.
     */

    *sts = VD_SUCCESS;

    nbHdrs = om$dimension_of( varray = me->hdrIds );
    __DBGpr_int( "Number of headers ", nbHdrs );

    /* allocate space for split locations vla */

    status = om$vla_set_dimension(	varray	= me->splitLocs,
					size	= nbHdrs );
    CheckRC( status, 1 );
    if( !(status & 1) )
    {
	UI_status( "Error in dynamic allocation : command terminated" );
	*sts = VD_ERROR;
	goto wrapup;
    }

    /* get total number of rows */

    status =
    _VD_SEND_OBJ( me->tblObj.obj_id, VDdrwTbl.VDgetTotalNbOfRows( 	
								&msg, 
								&nbRows ) );
    __CheckRC( status, msg, "VDdrwTbl.VDgetTotalNbOfRows", wrapup );

    __DBGpr_int( "Total number of rows", nbRows );

    if( !nbRows )
	goto wrapup;

    /* allocate memory */

    status = om$vla_set_dimension(	varray	= me->rows,
					size	= nbRows );
    __CheckRC( status, 1, "om$vla_set_dimension", wrapup );
    
    /* get the list of rowIds and initialize them into the me->rows vla */

    ind = 0;
    for( i = 0 ; i < nbHdrs ; i++ )
    {
	/* get row information */

	status =
	_VD_SEND_OBJ( me->hdrIds[i], VDdrwTblHdr.VDgetRowInfo(	&msg,
								&nbHdrRows,
								&startRowNo ) );
	__CheckRC( status, msg, "VDdrwTblHdr.VDgetRowInfo", wrapup );

	__DBGpr_int( "i", i );
	__DBGpr_int( "No of rows in header", nbHdrRows );
	__DBGpr_int( "StartRow number", startRowNo );
    
	/* splitLocs stores the last row number in the corresponding header */

	me->splitLocs[i] = startRowNo + nbHdrRows - 1 ;

	/* for each row, get the rowId, number of model objects, and qty */

	for( j = startRowNo ; j < (startRowNo + nbHdrRows) ; j++ )
	{
	    status = 
	    _VD_SEND_OBJ( me->hdrIds[i], VDdrwTblHdr.VDrowNoToGRid( 
						&msg,
						j, 
						&me->rows[ind].rowId ) );
	    __CheckRC( status, msg, "VDdrwTblHdr.VDrowNoToGRid", wrapup );
	    
	    __DBGpr_obj( "Row id ", me->rows[ind].rowId );

	    status =
	    _VD_SEND_OBJ( me->rows[ind].rowId, VDdrwTblRow.
				VDgetParentObjectList( &msg,
							&me->rows[ind].nbObjs, 
							NULL ) );
	    CheckRC( status, msg );
	    
	    __DBGpr_int( "No of parent set objects ", me->rows[ind].nbObjs );
	
	    status =
	    _VD_SEND_OBJ( me->rows[ind].rowId, VDdrwTblRow.VDgetQtyExpr(
							&msg,
							&me->rows[ind].qty ) );
	    __CheckRC( status, msg, "VDdrwTblHdr.VDgetQtyExpr", wrapup );

	    ind++;
	}
    }

    /* initialize the row entries */

    me->rows[0].startIndex = 0;
    me->rows[0].flag = VD_DRW_ROW_OLD;

    for( i = 1 ; i < nbRows ; i++ )
    {
	me->rows[i].startIndex = me->rows[i-1].startIndex +
					me->rows[i-1].nbObjs;
	me->rows[i].flag = VD_DRW_ROW_OLD;
    }

    /*
     *
     * rest of the operations are not needed for "Split table" command
     *
     */

    if( me->mytype == SPLIT_TABLE )
	goto wrapup;

    /* set up memory for list of located objects */

    nbObjs = me->rows[nbRows-1].startIndex + me->rows[nbRows-1].nbObjs;
    __DBGpr_int( "Total number of objects", nbObjs );

    status = om$vla_set_dimension(	varray	= me->locObjs,
					size	= nbObjs );
    __CheckRC( status, 1, "om$vla_set_dimension", wrapup );
    
    /* initialize mcf gadgets in form */

    nbLines = nbRows * me->maxLinesPerRow;
    __DBGpr_int( "Number of lines ", nbLines );

    FIfld_set_num_rows( VD_FP, VD_TBL_INV_COLDISP_FLD, nbLines );
    FIfld_set_num_rows( VD_FP, VD_TBL_VIS_COLDISP_FLD, nbLines );

    /* get number of columns */

    FImcf_get_num_cols( VD_FP, VD_TBL_INV_COLDISP_FLD, &nbCols );

    /* initialze rows in inv mcf to empty string */

    for( i = 0 ; i < nbLines ; i++ )
	for( j = 0 ; j < nbCols ; j++ )
	    FIfld_set_text( VD_FP, VD_TBL_INV_COLDISP_FLD, i, j, "", FALSE );

    /* initialize R.No column in vis mcf to NULL */

    for( i = 0 ; i < nbLines ; i++ )
	FIfld_set_text( VD_FP, VD_TBL_VIS_COLDISP_FLD, i, 0, "", FALSE );

    /* fill up the objects and initialize rows in form */

    ind = 0;
    for( i = 0 ; i < nbRows ; i++ )
    {
	if( me->rows[i].nbObjs )
	{
	    status =
	    _VD_SEND_OBJ( me->rows[i].rowId, VDdrwTblRow.VDgetParentObjectList( 
							&msg,
							&tmpNbObjs,
							&me->locObjs[ind] ) );
	    __CheckRC( status, msg, "VDdrwTblRow.VDgetParentObjectList", wrapup );
	
	    if( tmpNbObjs != me->rows[i].nbObjs )
	    {
		printf( "WARNING : could not retrieve parent objs for row [%d, %d]\n", 
			me->rows[i].rowId.objid, me->rows[i].rowId.osnum );
		__DBGpr_int( "Actual number of parents", tmpNbObjs );
		__DBGpr_int( "Previous number of parents", me->rows[i].nbObjs );
	    }

	    me->rows[i].nbObjs = tmpNbObjs;
	    ind += tmpNbObjs;
	}

	/* get the list of row values */

	status =
	_VD_SEND_OBJ( me->rows[i].rowId, VDdrwTblRow.VDgetCurrentRowValues(
								&msg,
								&nbValues,
								&lineNos,
								&colNos,
								&values ) );
	__CheckRC( status, msg, "VDdrwTblRow.VDgetCurrentRowValues", wrapup );

#ifdef vdsDEBUG
	printf( "\t\t# %d (nbValues = %d) : \n", i, nbValues );
	for( j = 0 ; j < nbValues ; j++ )
	    printf( "\t\t\t(%d, %d) = %s\n", lineNos[j], colNos[j], values[j] );
#endif

	/* update the row in the inv mcf */

	for( j = 0 ; j < nbValues ; j++ )
	{
	    row = (i * me->maxLinesPerRow) + lineNos[j] - 1;
	    FIfld_set_text( VD_FP, VD_TBL_INV_COLDISP_FLD, row, 
					colNos[j], values[j], FALSE );
	}

	/* free temporary buffers */

	_FREE( lineNos );
	_FREE( colNos );
	_LOOPFREE( values, nbValues );

	lineNos = NULL;
	colNos = NULL;
	values = NULL;
    }

    __DBGpr_int( "Total number of objects actually got", ind );

    if( ind != nbObjs )
    {
	__DBGpr_int( "Setting vla dimension to ", ind );

	status = om$vla_set_dimension(	varray	= me->locObjs,
						size	= ind );
	__CheckRC( status, 1, "om$vla_set_dimension", wrapup );

	nbObjs = ind;

	for( i = 1 ; i < nbRows ; i++ )
	{
	    me->rows[i].startIndex = me->rows[i-1].startIndex +
					me->rows[i-1].nbObjs;
	    me->rows[i].flag = VD_DRW_ROW_OLD;
	}
    }
	
    /* update the row number column */

    status = _VD_SEND_MY( VDCmdCrTbl.VDupdate1stCol( &msg ) );
    CheckRC( status, msg );

#ifdef vdsDEBUG

    printf("\n\tList of me->rows vla :\n");
    for( i = 0 ; i < nbRows ; i++ )
	printf( "\t\tstartIndex = %d, nbObjs = %d\n", me->rows[i].startIndex,
						      me->rows[i].nbObjs );

    printf("\n\tList of objects\n");
    for( i = 0 ; i < nbObjs ; i++ )
	printf( "\t\tObj # %d = [%d, %d]\n", i, me->locObjs[i].obj_id.objid,
						me->locObjs[i].obj_id.osnum );
#endif

wrapup :

    if( !(status & msg & 1) )
    {
	*sts = VD_ERROR;
	UI_status( "Error encountered : command terminated" );
    }
    End
    return OM_S_SUCCESS;
}

end implementation VDCmdCrTbl;
