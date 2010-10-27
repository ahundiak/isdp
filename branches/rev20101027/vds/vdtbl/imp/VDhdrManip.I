/* $Id: VDhdrManip.I,v 1.1.1.1 2001/01/04 21:09:27 cvs Exp $  */
/*--------------------------------------------------------------------------
/* I/VDS
 *
 * File:        vdtbl/set / VDhdrManip.I
 *
 * Description:
 *	Implementation of the following methods  for VDdrwTblHdr :
 *		VDremoveRow
 *		VDinsertRow
 *		VDdeleteHdr
 *		VDaddAndConstructRows
 *
 * Dependencies:
 *
 * History:
 *      
 *	04/14/95	R. Manem	Creation
 *	06/19/95	R. Manem	Added VDdeleteHdr message
 *	07/14/95	R. Manem	Modified VDinsertRow to handle recompute
 *	07/19/95	R. Manem	Removed VDmoveRow method
 *
 * -------------------------------------------------------------------------
 */

class implementation VDdrwTblHdr;

/*
#define vdsDEBUG
#define vdserrDEBUG
*/

#include <stdio.h>

#include "OMmacros.h"
#include "OMprimitives.h"

#include "v_miscmacros.h"
#include "v_dbgmacros.h"
#include "v_datamacros.h"

#include "godef.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"

#include "nddef.h"
#include "ndmacros.h"

#include "vds.h"
#include "emsdef.h"
#include "EMSutlmacros.h"

#include "VDdrwlo.h"
#include "VDdrwtbl.h"

from GRgencs		import	GRcvt_to_lcl_coords;

from VDdrwTblRow	import 	VDdeleteRow,
				VDgetRowNumber,
				VDputRowNumber,
				VDconstructRow,
				VDmoveRow;
/*+me
 ---------------------------------------------------------------------------
  Public Message VDremoveRow

  Abstract
        This message will disconnect the specified row.  If delete option is
        indicated, then the row object will be sent a VDdeleteRow message

  Arguments
        IGRlong         *msg       O     Return code
        IGRshort        *delOpt    I     Delete option :
                                         1 = delete row, 0 = don't delete row
        IGRint          *rowNo     I     Row number to remove.
        struct GRid     *rowId     I     GRid of the row object

  Notes/Remarks
        Either rowNo or rowId must be specified.

  Status/Return Code
      status == OM_S_SUCCESS    if success;
 ---------------------------------------------------------------------------
-me*/

method  VDremoveRow(    IGRlong         *msg;
                        IGRshort        delOpt;
                        IGRint          *rowNo;
                        struct GRid     *rowId )
{
    IGRint		i,
			nbRows,
			curRowNo,
			endRowNo,
			rowNoToMove,
			size = sizeof( struct GRmd_env ),
			vlaSize = 0;
    enum GRdpmode	dpmode;
    IGRshort		matType;
    IGRmatrix		tMatrix;
    IGRlong             status = OM_S_SUCCESS;
    IGRdouble		fromPoint[3],
			toPoint[3];
    struct GRid		rowIdToMove,
			csId,
			hdrId;
    struct GRmd_env	mod_env;
    OM_S_CHANSELECT	toHdrChan, 
			toRowsChan;

    SetProc( VDdrwTblHdr.VDremoveRow ); Begin

    *msg = MSSUCC;

    if( !rowNo && !rowId )
    {
        __DBGpr_com( "Must specify rowNo or rowId" );
        status = OM_W_ABORT;
        goto wrapup;
    }

    /* select the channels */

    status =
    om$make_chanselect( channame        = "VDdrwTblRow.to_tblHdr",
                        p_chanselect    = &toHdrChan );
    __CheckRC( status, 1, "selecting toHdrChan", wrapup );

    status =
    om$make_chanselect( channame        = "VDdrwTblHdr.to_tblRows",
                        p_chanselect    = &toRowsChan );
    __CheckRC( status, 1, "selecting toRowsChan", wrapup );

    /* get the coordinate system id */

    status =
    _VD_SEND_MY( VDdrwTblHdr.ACfind_temp_obj(   (int *)msg,
                                                "cs",
                                                &csId ) );
    __CheckRC( status, *msg, "VDdrwTblHdr.ACfind_temp_obj", wrapup );

    status =
    _VD_SEND_OBJ( csId, NDmacro.ACreturn_foot(	msg,
                                                "",
                                                &csId,
                                                NULL, NULL ) );
    __CheckRC( status, *msg, "NDmacro.ACreturn_foot", wrapup );

    __DBGpr_obj( "Coordinate system id", csId );

    nbRows = om$dimension_of( varray = me->rowHeights ) - 2;
    endRowNo = me->startRowNo + nbRows - 1;

    __DBGpr_int( "Number of rows", nbRows );
    __DBGpr_int( "Ending row number", endRowNo );

    /* 
     * if rowId is specified
     *		get the row number
     * else
     *		get the row id
     */

    if( rowId )
    {
        rowIdToMove = *rowId;
        
        __DBGpr_obj( "Row object id", rowIdToMove );

        status =
        _VD_SEND_OBJ( rowIdToMove, VDdrwTblRow.VDgetRowNumber( 
							msg, 
							&rowNoToMove ) );
        CheckRC( status, *msg );

        /* validate if the row object is actually on the to_tblRows channel */

        status =
        om$is_objid_on_channel(	objid_c		= my_id,
				p_chanselect	= &toRowsChan,
				objid		= rowIdToMove.objid,
				osnum2		= rowIdToMove.osnum );
        if( !(status & 1) )
        {
            __DBGpr_com( "Row object not connected to header" );
            status = OM_W_ABORT;
            goto wrapup;
        }
    }
    else
    {
        /* row number is given. first validate it */

        rowNoToMove = *rowNo;

        __DBGpr_int( "Row number to move", rowNoToMove );

        if( rowNoToMove > endRowNo || rowNoToMove < me->startRowNo )
        {
            __DBGpr_com( "Row number out of limits" );
            status = OM_W_ABORT;
            goto wrapup;
        }

        /* now get the row object */

        for( i = 0 ; i < OM_K_MAXINT ; i++ )
        {
            status =
            om$get_objid_at_index(  objid           = my_id,
                                    p_chanselect    = &toRowsChan,
                                    index           = i,
                                    objidaddr       = &rowIdToMove.objid,
                                    osnumaddr       = &rowIdToMove.osnum );
            if( !(status & 1) )
            {
		/* some error, the row object has not been found */

                __DBGpr_com( "Error: row object not found" );
                status = OM_W_ABORT;
                goto wrapup;
            }

            status =
            _VD_SEND_OBJ( rowIdToMove, VDdrwTblRow.VDgetRowNumber( 
								msg,
								&curRowNo ) );
            CheckRC( status, *msg );

            if( curRowNo == rowNoToMove )
                break; 
        }
    }

    __DBGpr_int( "rowNoToMove", rowNoToMove );
    __DBGpr_obj( "rowIdToMove", rowIdToMove );

    /* 
     * must construct the transformation matrix for moving the remaining
     * rows
     */

    /* first get from and to points */

    status =
    _VD_SEND_MY( VDdrwTblHdr.VDgetCornerPointForRow( 	msg,
							rowNoToMove + 1,
							fromPoint ) );
    __CheckRC( status, *msg, "VDdrwTblHdr.VDgetCornerPointForRow", wrapup );

    status =
    _VD_SEND_MY( VDdrwTblHdr.VDgetCornerPointForRow( 	msg,
							rowNoToMove,
							toPoint ) );
    __CheckRC( status, *msg, "VDdrwTblHdr.VDgetCornerPointForRow", wrapup );

    __DBGpr_vec( "fromPoint", fromPoint );
    __DBGpr_vec( "toPoint", toPoint );

    /* construct the transformation matrix */

    VD_drwtb_getMatrixFrom2Points( 	msg, 
					fromPoint, toPoint, 
					&csId,
					&matType, tMatrix );

    /* erase and disconnect the row object */

    /* get current module environment */

    status = gr$get_module_env(	msg	= msg,
				sizbuf	= &size,
				buffer	= &mod_env );
    CheckRC( status, *msg );

    dpmode = GRbe;
    status =
    _VD_SEND_OBJ( rowIdToMove, GRgraphics.GRdisplay(	
						msg,
						&mod_env.md_env.matrix_type,
						mod_env.md_env.matrix,
						&dpmode,
						&mod_env.md_id ) );
    CheckRC( status, *msg );

    status =
    _VD_SEND_OBJ( rowIdToMove, Root.disconnect(	toHdrChan,
						my_id,
						OM_Gw_current_OS,
						toRowsChan ) );
    __CheckRC( status, *msg, "Root.disconnect", wrapup );

    /* delete the object if necessary */

    if( delOpt )
    {
        /* delete the row object */

        status =
        _VD_SEND_OBJ( rowIdToMove, VDdrwTblRow.VDdeleteRow( msg ) );
        CheckRC( status, *msg );
    }

    /* 
     * update the rowHeights instance data  :
     * 		get dimension of vla 
     * 		move following row heights one position up 
     * 		reduce vla size by one 
     */

    vlaSize = om$dimension_of( 	varray	= me->rowHeights );

    for( i = (rowNoToMove - me->startRowNo + 1) ; i < vlaSize-1 ; i++ )
        me->rowHeights[i] = me->rowHeights[i+1];

    status =
    om$vla_set_dimension(	varray	= me->rowHeights,
				size	= vlaSize -1 );

    nbRows--;

#ifdef vdsDEBUG
    printf("\tUpdated rowHeights array :\n");
    for( i = 0 ; i < nbRows ; i++ )
         printf("\t\t(%d) : %g\n", i, me->rowHeights[i] );
#endif

    /* 
     * move the remaining rows and trailer
     */

    hdrId.objid = my_id;
    hdrId.osnum = OM_Gw_current_OS;

    status = VD_drwtb_moveRowsOfTbl( 	msg,
					rowNoToMove + 1,
					endRowNo,
					-1,
					0, 1, 0,
					hdrId,
					matType,
					tMatrix );
    CheckRC( status, *msg );

wrapup :
    End
    return status;
}


/*+me
 ---------------------------------------------------------------------------
  Public Message VDinsertRow

  Abstract
        This message will insert the specified row at the specified location.
        New flag specifies whether, this is a newly created row object
        whose feet need to be constructed, or a row object which
        needs to be recomputed or an existing object which simply has to
        be moved to the specified location

  Arguments
        IGRlong         *msg            O       Return code
        IGRshort        *newFlag        I       New flag :
						    2 = mod row (recompute)
						    1 = new row (construct)
						    0 = existing row (move)
        IGRint          rowPos          I       position to insert row
        struct GRid     rowId           I       GRid of the VDdrwTblRow object.
        IGRdouble       *rowHeight      I       rowHeight if row is an
                                                existing one
        IGRdouble       *oldCornerPnt   I       Old corner point of the row.

  Notes/Remarks
        If row has to be moved, must specify oldCornerPnt and rowHeight
        If row is new or modified, pass NULL for these arguments
        If the rowPos is greater than the last row number then, it will be
	added after the last row, before the trailer.  The row number of 
	the row object will be updated according to the insert position.

  Status/Return Code
      status == OM_S_SUCCESS    if success;
		OM_W_ABORT	if insufficient arguments
				or any other error
 ---------------------------------------------------------------------------
-me*/

method  VDinsertRow(    IGRlong         *msg;
                        IGRshort        *newFlag;
			IGRint		rowPos;
                        struct GRid     rowId;
			IGRdouble	*rowHeight;
                        IGRdouble       *oldCornerPnt )
{
    IGRint		i,
			type = ND_COMP,
			nbRows,
			curRowNo,
			endRowNo,
			vlaSize = 0;
    IGRshort		matType;
    IGRchar		csType[] = "rectangular";
    IGRmatrix		tMatrix;
    IGRlong             status = OM_S_SUCCESS;
    IGRdouble		fromPoint[3],
			toPoint[3],
			newRowHeight = 0.0;
    struct GRid		hdrId,
			csId;
    OM_S_CHANSELECT	toHdrChan, 
			toRowsChan;

    SetProc( VDdrwTblHdr.VDinsertRow ); Begin

    *msg = MSSUCC;

    if( !newFlag && (!oldCornerPnt || !rowHeight) )
    {
        __DBGpr_com( "oldCornerPnt and rowHeight must be specified" );
        status = OM_W_ABORT;
        goto wrapup;
    }

    __DBGpr_int( "Row position to insert", rowPos );

    /* select the required channels */

    status =
    om$make_chanselect( channame        = "VDdrwTblRow.to_tblHdr",
                        p_chanselect    = &toHdrChan );
    __CheckRC( status, 1, "selecting toHdrChan", wrapup );

    status =
    om$make_chanselect( channame        = "VDdrwTblHdr.to_tblRows",
                        p_chanselect    = &toRowsChan );
    __CheckRC( status, 1, "selecting toRowsChan", wrapup );

    /* get the coordinate system id */

    status =
    _VD_SEND_MY( VDdrwTblHdr.ACfind_temp_obj(   (int *)msg,
                                                "cs",
                                                &csId ) );
    __CheckRC( status, *msg, "VDdrwTblHdr.ACfind_temp_obj", wrapup );

    __DBGpr_obj( "Coordinate system id", csId );

    nbRows = om$dimension_of( varray = me->rowHeights ) - 2;
    endRowNo = me->startRowNo + nbRows - 1;

    __DBGpr_int( "Number of rows", nbRows );
    __DBGpr_int( "nbRows", nbRows );

    /* check position to insert row */

    if( rowPos < me->startRowNo || rowPos > endRowNo )
        rowPos = endRowNo + 1;

    /* update the row number for the row object */

    status =
    _VD_SEND_OBJ( rowId, VDdrwTblRow.VDputRowNumber( 	msg,
							rowPos ) );
    CheckRC( status, *msg );

    /*
     * update the rowHeights instance data  :
     *          get dimension of vla
     *          increase dimension of vla by one
     *          move following row heights one position down
     */

    status =
    om$vla_set_dimension(       varray  = me->rowHeights,
                                size    = nbRows + 3 );

    vlaSize = nbRows + 3;

    for( i = vlaSize-1 ; i > (rowPos - me->startRowNo + 1) ; i-- )
        me->rowHeights[i] = me->rowHeights[i-1];

    /*
     * update the row numbers of the following rows.  
     */

    for( i = 0 ; i < nbRows ; i++ )
    {
        status =
        om$send(msg             = message VDdrwTblRow.VDgetRowNumber( msg,
                                                                    &curRowNo ),
                p_chanselect    = &toRowsChan,
                from            = i,
                to              = i );
        CheckRC( status, *msg );

        if( (status & *msg & 1) && curRowNo >= rowPos )
        {
            status =
            om$send(msg         = message VDdrwTblRow.VDputRowNumber(
                                                            msg,
                                                            curRowNo+1 ),

                    p_chanselect    = &toRowsChan,
                    from            = i,
                    to              = i );
            CheckRC( status, *msg );
        }
    }

    /* connect the object */

    status =
    _VD_SEND_OBJ( rowId, Root.connect(	toHdrChan, OM_K_MAXINT,
                                       	my_id,
                                       	OM_Gw_current_OS,
                                       	toRowsChan, OM_K_MAXINT ) );
    __CheckRC( status, *msg, "Root.connect", wrapup );


    /*
     * if the row is new or mod, construct its feet;  when feet are constructed,
     * 		the VDnewRowHeight message will be sent to the header 
     *		The header will move remaining rows if the rowHeight was >=0. 
     *		Avoid this by initializing row height to -1. 
     * else 
     *   	move row from its old position to the new position
     */

    if( *newFlag == 2 )
    {
        me->rowHeights[rowPos - me->startRowNo + 1] = -1;

	/* recompute the row */

	status =
	_VD_SEND_OBJ( rowId, VDSroot.VDcompute( msg, &type ) );
        __CheckRC( status, *msg, "VDSroot.VDcompute", wrapup );
	
	nd$exec_batch();

        newRowHeight = me->rowHeights[rowPos - me->startRowNo + 1];
    }
    else if( *newFlag == 1 )
    {
        me->rowHeights[rowPos - me->startRowNo + 1] = -1;

        /* construct the feet */

        status =
        _VD_SEND_OBJ( rowId, VDdrwTblRow.VDconstructRow( msg ) );
        __CheckRC( status, *msg, "VDdrwTblRow.VDconstructRow", wrapup );

        newRowHeight = me->rowHeights[rowPos - me->startRowNo + 1];
    }
    else
    {
        /* construct transformation matrix and move the given row */

	/* old corner pnt is in world coordinates.  convert to local first */

	__DBGpr_vec( "oldCornerPnt in world coords", oldCornerPnt );

	status =
	_VD_SEND_OBJ( csId, GRgencs.GRcvt_to_lcl_coords(msg,
							csType,
							1,
							oldCornerPnt,
							fromPoint ) );
	__CheckRC( status, *msg, "GRgencs.GRcvt_to_lcl_coords", wrapup );

	__DBGpr_vec( "From point after converting to local coords", fromPoint );

        status =
        _VD_SEND_MY( VDdrwTblHdr.VDgetCornerPointForRow(	msg,
                                                        	rowPos,
                                                        	toPoint ) );
        __CheckRC( status, *msg, "VDdrwTblHdr.VDgetCornerPointForRow", wrapup );

        __DBGpr_com( "Transformation points for row" );
   
        __DBGpr_vec( "fromPoint", fromPoint );
        __DBGpr_vec( "toPoint", toPoint );

        VD_drwtb_getMatrixFrom2Points( 	msg, 
					fromPoint, toPoint, 
					&csId,
					&matType, tMatrix );

        status =
        _VD_SEND_OBJ( rowId, VDdrwTblRow.VDmoveRow(	msg,
							&matType,
							tMatrix ) );
        CheckRC( status, *msg );

        newRowHeight 	= me->rowHeights[rowPos - me->startRowNo + 1] 
			= *rowHeight ;

    }

    __DBGpr_dbl( "New row height", newRowHeight );

#ifdef vdsDEBUG
    printf("\tUpdated rowHeights array :\n");
    for( i = 0 ; i < vlaSize ; i++ )
         printf("\t\t(%d) : %g\n", i, me->rowHeights[i] );
#endif

    /* 
     * must construct the transformation matrix for moving the remaining
     * rows
     */

    /* first compute from and to points */

    for( i = 0 ; i < 3 ; i++ )
        fromPoint[i] = toPoint[i] = me->headerCornerPoint[i];

    if( me->tblOrient == VD_DRWLO_EN_DESCEND )
        toPoint[1] -= newRowHeight;
    else
        toPoint[1] += newRowHeight;

    __DBGpr_vec( "fromPoint", fromPoint );
    __DBGpr_vec( "toPoint", toPoint );

    /* construct the transformation matrix */

    VD_drwtb_getMatrixFrom2Points( 	msg, 
					fromPoint, toPoint, 
					&csId,
					&matType, tMatrix );

    /* 
     * move the remaining rows and trailer
     */

    hdrId.objid = my_id;
    hdrId.osnum = OM_Gw_current_OS;

    status = VD_drwtb_moveRowsOfTbl( 	msg,
				    	rowPos + 1,
					endRowNo + 1,
					1,
					0, 1, 0,
					hdrId,
					matType,
					tMatrix );
    CheckRC( status, *msg );

wrapup :
    End
    return status;
}

/*+me
 -------------------------------------------------------------------------
  Public Message VDdeleteHdr

  Abstract
        This method sets the delete flag and deletes myself with GRdelete
        message

  Arguments
        IGRlong         *msg      O     Return code

  Notes/Remarks

  Status/Return Code
      status == OM_S_SUCCESS    if success;
 -------------------------------------------------------------------------
-me*/

method  VDdeleteHdr( IGRlong         *msg )
{
    IGRint              size = sizeof( struct GRmd_env );
    IGRlong             status = OM_S_SUCCESS;
    struct GRmd_env     mod_env;

    SetProc( VDdrwTblRow.VDdeleteHdr ); Begin

    *msg = MSSUCC;

    __DBGpr_me();

    /* get current module environment */

    status =
    gr$get_module_env(  msg     = msg,
                        sizbuf  = &size,
                        buffer  = &mod_env );
    CheckRC( status, *msg );

    /* set delete flag */

    me->hdrInfo |= VD_HDR_DELETE;
    __DBGpr_int( "Hdr Info", me->hdrInfo );

    status = 
    _VD_SEND_MY( VDdrwTblHdr.GRdelete( msg, &mod_env ) );
    CheckRC( status, *msg );

    End
    return status;
}

/*+me
 ---------------------------------------------------------------------------
  Public Message VDaddAndConstructRows

  Abstract
        This message will add the given rows on its channel, and make the rows
        to construct feet.  The rows are assumed to be newly created and
        have their templates initialized.  The row numbers will be set by the
        header object automatically.  The rows will be added after the last
        row in the table part.

  Arguments
        IGRlong         *msg            O       Return code
	IGRint		nbRows		I	Number of rows to add
        struct GRid     *rowIds         I       GRids of the VDdrwTblRow
                                                objects to be added.
  Notes/Remarks

  Status/Return Code
      status == OM_S_SUCCESS    if success;
 ---------------------------------------------------------------------------
-me*/

method  VDaddAndConstructRows(  IGRlong         *msg;
				IGRint		nbRows;
                                struct GRid     *rowIds )
{
    IGRint		i,
			vlaSize = 0,
			myNbRows,	
			endRowNo,
			newRowNo;
    IGRshort		matType;
    IGRdouble		fromPoint[3],
			toPoint[3];
    IGRmatrix		tMatrix;
    IGRlong             status = OM_S_SUCCESS;
    OM_S_CHANSELECT	toHdrChan,
			toRowsChan;
    struct GRid		hdrId,
			csId;

    SetProc( VDdrwTblHdr.VDaddAndConstructRows ); Begin

    *msg = MSSUCC;

    __DBGpr_me( );
    __DBGpr_int( "nbRows", nbRows );
    __DBGpr_objlist( "List of row objects to add", nbRows, rowIds );

    if( !nbRows )
    {
	__DBGpr_com( "No rows to add" );
	goto wrapup;
    }

    /* select the required channels */

    status =
    om$make_chanselect( channame        = "VDdrwTblRow.to_tblHdr",
                        p_chanselect    = &toHdrChan );
    __CheckRC( status, 1, "selecting toHdrChan", wrapup );

    status =
    om$make_chanselect( channame        = "VDdrwTblHdr.to_tblRows",
                        p_chanselect    = &toRowsChan );
    __CheckRC( status, 1, "selecting toRowsChan", wrapup );

    vlaSize = om$dimension_of( varray	= me->rowHeights );
    myNbRows = vlaSize - 2;
    endRowNo = myNbRows + me->startRowNo - 1;

    __DBGpr_int( "vlaSize", vlaSize );
    __DBGpr_int( "myNbRows", myNbRows );
    __DBGpr_int( "endRowNo", endRowNo );

    /* resize vla and initialize new entries*/

    status =
    om$vla_set_dimension(	varray	= me->rowHeights,
				size	= vlaSize + nbRows );
    if( !(status & 1) )
        vd_$mem_fail( sts = status );

    /* update trailer height before initialization */

    me->rowHeights[ vlaSize + nbRows - 1] = me->rowHeights[vlaSize - 1];

    for( i = vlaSize - 1 ; i < vlaSize + nbRows - 1 ; i++ )
        me->rowHeights[i] = -1.0;

    /* fromPoint for moving trailer */

    status =
    _VD_SEND_MY( VDdrwTblHdr.VDgetCornerPointForRow(	msg,
							vlaSize-1,
							fromPoint ) );
    CheckRC( status, *msg );

    newRowNo = endRowNo + 1;

    __DBGpr_int( "new row number", newRowNo );

    for( i = 0 ; i < nbRows ; i++ )
    {
        /* set the row number */

        status =
        _VD_SEND_OBJ( rowIds[i], VDdrwTblRow.VDputRowNumber( msg, newRowNo ) );
        CheckRC( status, *msg );

        newRowNo++;

        /* connect the row object */

        status =
        _VD_SEND_OBJ( rowIds[i], Root.connect(	toHdrChan, OM_K_MAXINT,
                                        	my_id,
                                        	OM_Gw_current_OS,
                                        	toRowsChan, OM_K_MAXINT ) );
        __CheckRC( status, *msg, "Root.connect", wrapup );

        /* construct the row */

        status =
        _VD_SEND_OBJ( rowIds[i], VDdrwTblRow.VDconstructRow( msg ) );
        CheckRC( status, *msg );
    }

    /* get the coordinate system id */

    status =
    _VD_SEND_MY( VDdrwTblHdr.ACfind_temp_obj(   (int *)msg,
                                                "cs",
                                                &csId ) );
    __CheckRC( status, *msg, "VDdrwTblHdr.ACfind_temp_obj", wrapup );

    status =
    _VD_SEND_OBJ( csId, NDmacro.ACreturn_foot(	msg,
                                                "",
                                                &csId,
                                                NULL, NULL ) );
    __CheckRC( status, *msg, "NDmacro.ACreturn_foot", wrapup );

    __DBGpr_obj( "Coordinate system id", csId );

    __DBGpr_int( "New row number = trailer row number = ", newRowNo );

    /* must move the trailer */

    status =
    _VD_SEND_MY( VDdrwTblHdr.VDgetCornerPointForRow(	msg,
							newRowNo,
							toPoint ) );
    __CheckRC( status, *msg, "VDdrwTblHdr.VDgetCornerPointForRow", wrapup );
    
    __DBGpr_vec( "fromPoint", fromPoint );
    __DBGpr_vec( "toPoint", toPoint );

    VD_drwtb_getMatrixFrom2Points( 	msg, 
					fromPoint, toPoint, 
					&csId,
					&matType, tMatrix );

    hdrId.objid = my_id;
    hdrId.osnum = OM_Gw_current_OS;

    /* move only the trailer */

    status = VD_drwtb_moveRowsOfTbl( 	msg,
					0, 0,
					0,
					0, 1, 0,
					hdrId,
					matType,
					tMatrix );
    CheckRC( status, *msg );
        
wrapup :
    End
    return status;
}

end implementation VDdrwTblHdr;
