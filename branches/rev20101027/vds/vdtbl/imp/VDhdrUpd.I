/* $Id: VDhdrUpd.I,v 1.3 2002/04/09 15:16:33 ylong Exp $  */
/*--------------------------------------------------------------------------
/* I/VDS
 *
 * File:        vdtbl/imp / VDhdrUpd.I
 *
 * Description:
 *	Implementation of the following methods  for VDdrwTblHdr :
 *		VDinitTblHdr
 *		VDconstructHdrTrl
 *		VDsetMatrixFromCS
 *		VDsetSizeOfRowHeights
 *		VDnewRowHeight
 *		VDcomputeRowInfo
 *
 * Dependencies:
 *
 * History:
 *      
 *	04/14/95	R. Manem	Creation
 *	07/19/95	R. Manem	Removed VDupdateRowNumbers message
 * 	07/19/00	Ming		For Create Table by Stage cmd.
 *	04/08/02	ylong		Added method VDsetSizeOfRowHeights
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

#include "vds.h"
#include "emsdef.h"
#include "EMSutlmacros.h"

#include "VDdrwlo.h"
#include "VDdrwtbl.h"

from GRgencs		import	GRgetmatrix;
from VDdrwTblRow	import	VDgetRowNumber,
				VDputRowNumber;

/*+me
 ---------------------------------------------------------------------------
  Public Message VDinitTblHdr

  Abstract
        This method initializes instance data

  Arguments
        IGRlong         *msg            O       Return code

  Notes/Remarks

  Status/Return Code
      status == OM_S_SUCCESS    if success;
 ---------------------------------------------------------------------------
-me*/

method  VDinitTblHdr(   IGRlong         *msg )
{
    IGRlong             status = OM_S_SUCCESS;

    SetProc( VDdrwTblHdr.VDinitTblHdr ); Begin

    me->tblPartNo = 1;
    me->tblLayoutName[0] = '\0';
    me->startRowNo = 1;
    me->hdrInfo = 0;

    /* initialize header and trailer heights */

    status =
    om$vla_set_dimension(	varray	= me->rowHeights,
				size	= 2 );
    if( !(status & 1) )
    {
        printf("\nVDinitTblHdr : Error in dynamic memory allocation\n");
        goto wrapup;
    }

    me->rowHeights[0] = me->rowHeights[1] = 0.0;

    *msg = MSSUCC;

wrapup :
    End
    return status;
}


/*+me
 ---------------------------------------------------------------------------
  Public Message VDconstructHdrTrl

  Abstract
        This method constructs the row, by doing ACconstruct_feet, and 
	ACchange_feet

  Arguments
        IGRlong         *msg      O     Return code

  Notes/Remarks

  Status/Return Code
      status == OM_S_SUCCESS    if success;
 ---------------------------------------------------------------------------
-me*/

method  VDconstructHdrTrl( IGRlong         *msg )
{
    IGRint		nbRoots,
			nbFeet,
			size = sizeof( struct GRmd_env);
    enum GRdpmode	dpmode;
    IGRdouble		xLow, yLow,
			xHigh, yHigh;
    IGRlong             status = OM_S_SUCCESS;
    struct GRid		roots[3],
			feet[3];
    struct GRmd_env	mod_env;

    SetProc( VDdrwTblHdr.VDconstructHdrTrl ); Begin

    *msg = MSSUCC;

    /*
     * first set up the header corner point
     */

    me->headerCornerPoint[2] = 0.0;

    /* must get rectangle for header */

    status =
    VD_drwlo_grect(	msg,
			me->tblLayoutName,
			(me->headerType == VD_DRWLO_EN_BRKHDR ? 
				VD_DRWLO_EN_BRKHDR : VD_DRWLO_EN_HEADER ),
			0,
			NULL,
			0, NULL,
			&xLow, &yLow,
			&xHigh, &yHigh );
    CheckRC( status, *msg );

    if( me->csLocation == VD_DRW_CS_LOC_RIGHT && 
				me->tblOrient == VD_DRWLO_EN_ASCEND )
    {
	me->headerCornerPoint[0] = xLow - xHigh;
	me->headerCornerPoint[1] = 0;
    }
    else if( me->csLocation == VD_DRW_CS_LOC_RIGHT &&
				me->tblOrient == VD_DRWLO_EN_DESCEND )
    {
	me->headerCornerPoint[0] = xLow - xHigh;
	me->headerCornerPoint[1] = yLow - yHigh;
    }
    else if( me->csLocation == VD_DRW_CS_LOC_LEFT &&
				me->tblOrient == VD_DRWLO_EN_ASCEND )
    {
	me->headerCornerPoint[0] = 0;
	me->headerCornerPoint[1] = 0;
    }
    else if( me->csLocation == VD_DRW_CS_LOC_LEFT &&
				me->tblOrient == VD_DRWLO_EN_DESCEND )
    {
	me->headerCornerPoint[0] = 0;
	me->headerCornerPoint[1] = yLow - yHigh;
    }
  
    __DBGpr_vec( "Header corner point", me->headerCornerPoint );

    /* get current module environment */

    status =
    gr$get_module_env(  msg     = msg,
                        sizbuf  = &size,
                        buffer  = &mod_env );
    CheckRC( status, *msg );

    /* get the template objects, modified by Ming For Create Table 
       by Stage cmd */

    status =
    _VD_SEND_MY( NDnode.NDget_objects(	ND_ROOT,
					roots,
					3,
					NULL,
					0,
					OM_K_MAXINT,
					&nbRoots ) );
    __CheckRC( status, *msg, "NDnode.NDget_objects", wrapup );

    __DBGpr_objlist( "List of roots", nbRoots, roots );

    /* construct the feet */

    status =
    _VD_SEND_MY( ACncpx.ACconstruct_feet(	msg,
						0,
						nbRoots,
						roots,
						&mod_env,
						&nbFeet,
						feet ) );
    __CheckRC( status, *msg, "ACncpx.ACconstruct_feet", wrapup );
					
    __DBGpr_objlist( "List of feet", nbFeet, feet );

    /* change feet */

    status =
    _VD_SEND_MY( ACncpx.ACchange_feet(	nbFeet,
					feet,
					&mod_env ) );
    __CheckRC( status, *msg, "ACncpx.ACchange_feet", wrapup );
					
    /* display myself */

    dpmode = GRbd;
    status =
    _VD_SEND_MY( GRgraphics.GRdisplay(	msg,
					&mod_env.md_env.matrix_type,
					mod_env.md_env.matrix,
					&dpmode,
					&mod_env.md_id ) );
    CheckRC( status, *msg );

wrapup:
    End
    return status;
}


/*+me
 ---------------------------------------------------------------------------
  Public Message VDsetMatrixFromCS

  Abstract
        This method computes and sets the transformation matrix,
        using the parent coordinate system.

  Arguments
        IGRlong         *msg            O       Return code

  Notes/Remarks

  Status/Return Code
      status == OM_S_SUCCESS    if success;
 ---------------------------------------------------------------------------
-me*/

method  VDsetMatrixFromCS( IGRlong    *msg )
{
    IGRlong             status = OM_S_SUCCESS;
    struct GRid		csId;

    SetProc( VDdrwTblHdr.VDsetMatrixFromCS ); Begin

    *msg = MSSUCC;

    /* get the coordinate system */

    status =
    _VD_SEND_MY( VDdrwTblHdr.ACfind_temp_obj(	(int *)msg,	
						"cs",	
						&csId ) );
    __CheckRC( status, *msg, "VDdrwTblHdr.ACfind_temp_obj", wrapup );

    status =
    _VD_SEND_OBJ( csId, NDmacro.ACreturn_foot(  msg,
                                                "",
                                                &csId,
                                                NULL, NULL ) );
    __CheckRC( status, *msg, "NDmacro.ACreturn_foot", wrapup );

    __DBGpr_obj( "Coordinate system id", csId );

    /* get its matrix */

    status =
    _VD_SEND_OBJ( csId, GRgencs.GRgetmatrix( 	msg, me->tMatrix ) ); 
    CheckRC( status, *msg );

    __DBGpr_mat( "transformation matrix", me->tMatrix );

wrapup :
    End
    return status;
}

/*+me
 ---------------------------------------------------------------------------
  Public Message VDsetSizeOfRowHeights

  Abstract
	This method sets the dimension of rowHeights according to the number
        of rows. This method is only used when it is not consistent with
        the number of rows. You may also need to re calculate each rowHeights
        based on the row graphics, because you can not trust the values of
        rowHeights any more after the size is reset. Refer to
        VDtblValidateRows in vds/vdtbl/func/VDdrw_tblValid.I


  Arguments
        IGRlong         *msg             O       Return code

  Notes/Remarks

  Status/Return Code
      status == OM_S_SUCCESS    if success;
 ---------------------------------------------------------------------------
-me*/

method  VDsetSizeOfRowHeights( IGRlong         *msg )
{
    IGRlong             status = OM_S_SUCCESS;
    IGRint		nbRows = 0, size = 0;
    OM_S_CHANSELECT	toRowsChan;

    SetProc( VDdrwTblHdr.VDsetSizeOfRowHeights ); Begin

    *msg = MSSUCC;

    status =
    om$make_chanselect(	channame	= "VDdrwTblHdr.to_tblRows",
			p_chanselect	= &toRowsChan );
    __CheckRC( status, 1, "selecting toRowsChan", wrapup );

    status = 
    om$get_channel_count(	objid		= my_id,
				p_chanselect	= &toRowsChan,
				count		= (OMuint *)&nbRows );
    __CheckRC( status, 1, "get row count from toRowsChan", wrapup );

    size = om$dimension_of( varray = me->rowHeights );

    if( size != nbRows + 2 )
    {
	status =
	om$vla_set_dimension(	varray	= me->rowHeights,
				size	= nbRows + 2 );
	__CheckRC( status, 1, "om$vla_set_dimension", wrapup );
    }

wrapup :
    End
    return status;
}

/*+me
 ---------------------------------------------------------------------------
  Public Message VDnewRowHeight

  Abstract
        This message comes from the row object during its compute.
        It notifies the header of its new row height, which may or may not
        have changed from its previous value.  The header compares the previous
        and new values to determine if it has changed, and accordingly moves
        the remaining rows and trailer. But if the previous height was 
	initialized to -1, it means that the following rows should not be moved.

  Arguments
        IGRlong         *msg             O       Return code
        IGRint          rowNo            I       Row number
        IGRdouble       newHeight        I       New height of the row.

  Notes/Remarks

  Status/Return Code
      status == OM_S_SUCCESS    if success;
 ---------------------------------------------------------------------------
-me*/

method  VDnewRowHeight( IGRlong         *msg;
                        IGRint          rowNo;
                        IGRdouble       newHeight )
{
    IGRint		nbRows,
			endRowNo,
			nextRow,
			rowIndex;
    IGRshort		matType;
    IGRmatrix		tMatrix;
    IGRdouble		fromPoint[3],
			toPoint[3];
    IGRlong             status = OM_S_SUCCESS;
    struct GRid		hdrId,
			csId;

    SetProc( VDdrwTblHdr.VDnewRowHeight ); Begin

    *msg = MSSUCC;

    /* get the coordinate system id */

    status =
    _VD_SEND_MY( VDdrwTblHdr.ACfind_temp_obj(   (int *)msg,
                                                "cs",
                                                &csId ) );
    __CheckRC( status, *msg, "VDdrwTblHdr.ACfind_temp_obj", wrapup );

    __DBGpr_obj( "Coordinate system id", csId );

    nbRows = om$dimension_of( varray = me->rowHeights ) - 2;
    endRowNo = me->startRowNo + nbRows - 1;

    /* validate the row number */

    /* if rowNo is 0, it is the new header height */

    if( (rowNo != 0 ) && (rowNo > endRowNo || rowNo < me->startRowNo ) )
    {
        __DBGpr_com( "Row number out of limits" );
        status = OM_W_ABORT;
        goto wrapup;
    }

    if( rowNo == 0 )
        rowIndex = 0;
    else
        rowIndex = rowNo - me->startRowNo + 1;

    __DBGpr_int( "number of rows", nbRows );
    __DBGpr_int( "endRowNo", endRowNo );
    __DBGpr_int( "row index", rowIndex );

    if( me->rowHeights[rowIndex] == -1 )
    {
        /* simply update the height and return */

        me->rowHeights[rowIndex] = newHeight;
        goto wrapup;
    }

    /* if the rowHeight has not changed do nothing */

    if( me->rowHeights[rowIndex] == newHeight )
        goto wrapup;

    /* row height has changed : update height, and move following rows */

    if( rowNo == 0 )
        nextRow = me->startRowNo;
    else
        nextRow = rowNo + 1;

    status =
    _VD_SEND_MY( VDdrwTblHdr.VDgetCornerPointForRow( 	msg, 
							nextRow,
							fromPoint ) );
    CheckRC( status, *msg );

    me->rowHeights[rowIndex] = newHeight;

    status =
    _VD_SEND_MY( VDdrwTblHdr.VDgetCornerPointForRow( 	msg, 
							nextRow,
							toPoint ) );
    CheckRC( status, *msg );

    __DBGpr_vec( "From Point", fromPoint );
    __DBGpr_vec( "To Point", toPoint );

    VD_drwtb_getMatrixFrom2Points( 	msg,
					fromPoint, toPoint, 
					&csId,
					&matType, tMatrix );

    hdrId.objid = my_id;
    hdrId.osnum = OM_Gw_current_OS;

    status = VD_drwtb_moveRowsOfTbl(	msg,
					nextRow,
					endRowNo,
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
