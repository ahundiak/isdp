/* $Id: VDdrw_recomp.I,v 1.1.1.1 2001/01/04 21:09:27 cvs Exp $  */

/* I/VDS
 * -------------------------------------------------------------------------
 *
 * File:        vdtbl/func / VDdrw_recomp.I
 *
 * Description:
 *	Function :  VDdrw_recomputeTable
 *
 *
 * Dependencies:
 *
 * History:
 *
 *	10/05/95	R. Manem	Creation
 *	10/13/95	R. Manem	Change order of recomputing :
 *					first headers then rows.  This will
 *					fix problems of line out row display
 *					when header height is changed
 *
 * -------------------------------------------------------------------------
 */

class implementation Root;

/*
#define vdsDEBUG
#define vdserrDEBUG
*/

#include <stdio.h>

#include "igrtypedef.h"
#include "OMerrordef.h"
#include "OMminimum.h"
#include "OMprimitives.h"
#include "igetypedef.h"
#include "gr.h"

#include "nddef.h"
#include "ndmacros.h"

#include "godef.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"

#include "v_miscmacros.h"
#include "v_dbgmacros.h"
#include "v_datamacros.h"

#include "VDdrwlo.h"
#include "VDdrwtbl.h"

from GRgraphics		import	GRdisplay;
from GRgencs		import	GRcvt_to_wld_coords;
from NDmacro		import	ACreturn_foot;
from VDdrwTbl		import	VDgetTableParts,
				VDgetTotalNbOfRows;
from VDdrwTblHdr	import	VDconstructHdrTrl,
				VDgetRowInfo,
				VDremoveRow,
				VDinsertRow,
				ACfind_temp_obj,
				VDputConstructInfo,
				VDgetCornerPointForRow,
				VDgetRowHeight,
				VDrowNoToGRid;
from VDdrwTblRow	import	VDisRowLinedOut;
from VDSroot		import	VDcompute;

/*+fe
 -------------------------------------------------------------------------
  Function VDdrw_recomputeTable

  Abstract
	Function recomputes the entire table (header and rows)

  Arguments

	IGRlong		*msg	    	O	return code
	struct GRid	tblId		I	GRid of table to recompute
	IGRint		compHdrs	I	1 = recompute headers	
						0 = do not recompute headers
	IGRint		compRows	I	1 = recompute rows	
						0 = do not recompute rows
	
  Returns
	OM_S_SUCCESS	= if success
	OM_E_ABORT	= if error
 -------------------------------------------------------------------------
-fe*/

IGRlong VDdrw_recomputeTable(	IGRlong		*msg,
				struct GRid	tblId,
				IGRint		compHdrs,
				IGRint		compRows )
{
    IGRint		i, j,
			ind = 0,
			nbParts,
			nbRows,
			nbHdrRows,
			startRowNo,
			size = sizeof( struct GRmd_env );
    IGRchar		csType[] = "rectangular";
    IGRshort		newFlag,
			isLinedOut,
			cnstType = VD_DRW_CNST_BOTH;
    IGRlong		status = OM_S_SUCCESS;
    IGRdouble		oldPoint[3],
			oldWldPnt[3],
			rowHeight;
    enum GRdpmode	dpmode = GRbe;
    struct GRid		*hdrIds = NULL,
			*cpyIds = NULL,
			*csIds = NULL,
			*rowIds = NULL;
    struct GRmd_env	mod_env;

    SetProc( VDdrw_recomputeTable ); Begin
    *msg = MSSUCC;

    /* get current module environment */

    status = gr$get_module_env( msg     = msg,
                                sizbuf  = &size,
                                buffer  = &mod_env );
    CheckRC( status, *msg );

    /* get table headers */

    status =
    _VD_SEND_OBJN( tblId, VDdrwTbl.VDgetTableParts( msg, &nbParts, NULL ) );
    __CheckRC( status, *msg, "VDdrwTbl.VDgetTableParts", wrapup );

    __DBGpr_int( "Number of table parts", nbParts );

    /* allocate memory for headers, copy and coordinate systems */

    hdrIds = _MALLOC( nbParts * 3 , struct GRid );
    if( !hdrIds )
    {
	status = OM_E_NODYNMEM;
	printf( "Error in dynamic allocation" );
	goto wrapup;
    }

    status =
    _VD_SEND_OBJN( tblId, VDdrwTbl.VDgetTableParts( msg, &nbParts, hdrIds ) );
    __CheckRC( status, *msg, "VDdrwTbl.VDgetTableParts", wrapup );

    __DBGpr_objlist( "Header ids", nbParts, hdrIds );

    cpyIds = &hdrIds[nbParts];

    /* copy header */

    for( i = 0 ; i < nbParts ; i++ )
    {
	cpyIds[i].osnum = hdrIds[i].osnum;

	status =
	om$construct_and_copy(	objid	= hdrIds[i].objid,
				obj_osnum	= hdrIds[i].osnum,
				osnum		= hdrIds[i].osnum,
				p_objid		= &cpyIds[i].objid );
	__CheckRC( status, 1, "om$construct_and_copy", wrapup );
    }

    __DBGpr_objlist( "List of header copies", nbParts, cpyIds );

    csIds = &hdrIds[nbParts*2];

    /* get the coordinate systems */

    for( i = 0 ; i < nbParts ; i++ )
    {
	status =
	_VD_SEND_OBJN( hdrIds[i], VDdrwTblHdr.ACfind_temp_obj( (int*) msg,
								"cs",
								&csIds[i] ) );
	__CheckRC( status, *msg, "VDdrwTblHdr.ACfind_temp_obj", wrapup );
	
	status =
	_VD_SEND_OBJN( csIds[i], NDmacro.ACreturn_foot( 	msg, "",
								&csIds[i],
								NULL, NULL ) );
	__CheckRC( status, *msg, "NDmacro.ACreturn_foot", wrapup );
    }

    __DBGpr_objlist( "List of cs ids", nbParts, csIds );
    
    /* get total number of rows */

    status =
    _VD_SEND_OBJN( tblId, VDdrwTbl.VDgetTotalNbOfRows( msg, &nbRows ) );
    __CheckRC( status, *msg, "VDdrwTbl.VDgetTotalNbOfRows", wrapup );

    __DBGpr_int( "Total nb of rows", nbRows );

    if( nbRows )
    {
	/* allocate memory for rows */

	rowIds = _MALLOC( nbRows, struct GRid );
	if( !rowIds )
	{
	    status = OM_E_NODYNMEM;
	    printf( "Error in dynamic allocation" );
	    goto wrapup;
	}
    }

    UI_status( "WARNING : Do not hit the stop button" );

    /* recompute headers if needed */

    if( compHdrs )
    {
	for( i = 0 ; i < nbParts ; i++ )
	{
	    /* erase header */

	    status =
	    _VD_SEND_OBJN( hdrIds[i], GRgraphics.GRdisplay( 
                                                msg,
                                                &mod_env.md_env.matrix_type,
                                                mod_env.md_env.matrix,
                                                &dpmode,
                                                &mod_env.md_id ) );
	    CheckRC( status, *msg );

	    __DBGpr_obj( "Recomputing header", hdrIds[i] );

	    /* set the construct type */

	    status = 
	    _VD_SEND_OBJN( hdrIds[i], VDdrwTblHdr.VDputConstructInfo( 
							msg,
							NULL, NULL,
							&cnstType ) );
	    __CheckRC( status, *msg, "VDdrwTblHdr.VDputConstructInfo", wrapup );

	    status = 
	    _VD_SEND_OBJN( hdrIds[i], VDdrwTblHdr.VDconstructHdrTrl( msg ) );
	    __CheckRC( status, *msg, "VDdrwTblHdr.VDconstructHdrTrl", wrapup );
	}
    }

    if( compRows )
    {
    	for( i = 0 ; i < nbParts ; i++ )
    	{
	    status =
	    _VD_SEND_OBJN( hdrIds[i], VDdrwTblHdr.VDgetRowInfo( 	msg,
								&nbHdrRows,
								&startRowNo ) );
	    __CheckRC( status, *msg, "VDdrwTblHdr.VDgetRowInfo", wrapup );

	    __DBGpr_int( "No of rows in header", nbHdrRows );
	    __DBGpr_int( "Start row number", startRowNo );
	
	    /* get the row ids */

	    for( j = startRowNo ; j < startRowNo+nbHdrRows; j++ )
	    {
	         status =
	         _VD_SEND_OBJN( hdrIds[i], VDdrwTblHdr.VDrowNoToGRid(
								msg, 
								j,
								&rowIds[ind] ) );
	        __CheckRC( status, *msg, "VDdrwTblHdr.VDrowNoToGRid", wrapup );

		__DBGpr_obj( "Row id", rowIds[ind] );
	
	        ind++;
	    }

	    /* disconnect the rows */

	    for( j = (startRowNo+nbHdrRows-1); j >= startRowNo; j-- )
	    {
		__DBGpr_int( "Disconnecting row", j );

	        status =
	        _VD_SEND_OBJN( hdrIds[i], VDdrwTblHdr.VDremoveRow(
							msg, 0, 
							&j, NULL ) ); 
	        __CheckRC( status, *msg, "VDdrwTblHdr.VDremoveRow", wrapup );
	    }

	    for( j = startRowNo ; j < startRowNo+nbHdrRows; j++ )
	    {

		__DBGpr_int( "\n\tRow number", j );

	        isLinedOut = 0;
	        status =
	        _VD_SEND_OBJN( rowIds[j-1], VDdrwTblRow.VDisRowLinedOut( msg,
								&isLinedOut ) );
	        CheckRC( status, *msg );
		__DBGpr_int( "isLinedOut", isLinedOut );

	        if( isLinedOut )
		{
		    /* need to move the row */

		    /* get old corner point */

		    __DBGpr_obj( ":::::: Lined out row", rowIds[j-1] );

		    status =
		    _VD_SEND_OBJN( cpyIds[i], VDdrwTblHdr.
					VDgetCornerPointForRow( msg, j,
								oldPoint ) );
		    __CheckRC( status, *msg, "VDdrwTblHdr.VDgetCornerPointForRow", wrapup );
		    __DBGpr_vec( "Old corner point", oldPoint );

		    /* get row height */

		    status =
		    _VD_SEND_OBJN( cpyIds[i], VDdrwTblHdr.VDgetRowHeight(
								msg, j,
								&rowHeight ) );
		    __CheckRC( status, *msg, "VDdrwTblHdr.VDgetRowHeight", wrapup );
		    __DBGpr_dbl( "Old Row height", rowHeight );

		    status =
		    _VD_SEND_OBJN( csIds[i], GRgencs.GRcvt_to_wld_coords(
								msg, 
								csType, 1,
								oldPoint,
								oldWldPnt ) );
		    __CheckRC( status, *msg, "GRgencs.GRcvt_to_wld_coords", wrapup );
		    __DBGpr_vec( "Old World point ", oldWldPnt );

		    newFlag = 0;

		    _VD_SEND_OBJN( hdrIds[i], VDdrwTblHdr.VDinsertRow(
								msg, 
								&newFlag,
								j,
								rowIds[j-1],
								&rowHeight,
								oldWldPnt ) );
		    __CheckRC( status, *msg, "VDdrwTblHdr.VDinsertRow", wrapup );

		    continue;
		}

		__DBGpr_obj( "Inserting row", rowIds[j-1] );

		newFlag = 2;
	        status =
	        _VD_SEND_OBJN( hdrIds[i], VDdrwTblHdr.VDinsertRow( 
							msg, 
							&newFlag,
							j,
							rowIds[j-1],
							NULL, NULL ) );
	        __CheckRC( status, *msg, "VDdrwTblRow.VDcompute", wrapup );

	        /* execute immediately */
    
	        nd$exec_batch();
	    }
        }
    }
	    
wrapup :    
    _FREE( hdrIds );
    _FREE( rowIds );

    End
    return status;
}

end implementation Root;
