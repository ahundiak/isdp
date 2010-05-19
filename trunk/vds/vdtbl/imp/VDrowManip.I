/* $Id: VDrowManip.I,v 1.2 2001/02/07 20:23:00 ramarao Exp $  */
/*--------------------------------------------------------------------------
/* I/VDS
 *
 * File:        vdtbl/imp / VDrowManip.I
 *
 * Description:
 *	Implementation of the following methods  for VDdrwTblRow :
 *		VDmoveRow
 *		VDdeleteRow
 *
 * Dependencies:
 *
 * History:
 *      
 *	04/14/95	R. Manem	Creation
 *
 * -------------------------------------------------------------------------
 */

class implementation VDdrwTblRow;

/*
#define vdsDEBUG
#define vdserrDEBUG
*/

#include <stdio.h>

#include "v_miscmacros.h"
#include "v_dbgmacros.h"
#include "v_datamacros.h"

#include "OMmacros.h"
#include "OMprimitives.h"
#include "exmacros.h"

#include "emsdef.h"
#include "EMSutlmacros.h"

#include "godef.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"

#include "VDdrwlo.h"
#include "VDdrwtbl.h"

from VDdrwSet		import	VDdeleteSet;

/*+me
 -------------------------------------------------------------------------
  Public Message VDmoveRow

  Abstract
        This method moves itself by doing a GRxform on all its components.

  Arguments
        IGRlong         *msg      O     Return code
        IGRshort        *matType  I     Matrix type
        IGRmatrix       matrix    I     input transformation matrix

  Notes/Remarks

  Status/Return Code
      status == OM_S_SUCCESS    if success;
 -------------------------------------------------------------------------
-me*/

method  VDmoveRow(      IGRlong         *msg;
                        IGRshort        *matType;
                        IGRmatrix       matrix )
{
    IGRint		size = sizeof( struct GRmd_env );
    IGRlong             status = OM_S_SUCCESS;
    enum GRdpmode	dpmode;
    struct GRmd_env	mod_env;
    GRobjid		newObjid;
    OM_S_CHANSELECT	compChan;

    SetProc( VDdrwTblRow.VDmoveRow ); Begin

    *msg = MSSUCC;

    /* get current module environment */

    status =
    gr$get_module_env(	msg	= msg,
			sizbuf	= &size,
			buffer	= &mod_env );
    CheckRC( status, *msg );

    /* select the components channel : use ems macro (10 times faster) */

    status =
    ems$make_chanselect(	chan_label	= GRcmpowner_to_components,
				chan_selector	= &compChan );
    CheckRC( status, 1 );

    /* 
     * send GRxform message to all the components
     * The componenets (feet) are all GRowners which inturn pass the
     * message to all its components. 
     */

    __DBGpr_com( "Sending GRxform to feet (components channel)" );

    /* first erase myself */

    dpmode = GRbehe;
    status =
    _VD_SEND_MY( GRgraphics.GRdisplay(	msg,
					&mod_env.md_env.matrix_type,
					mod_env.md_env.matrix,
					&dpmode,
					&mod_env.md_id ) );
    CheckRC( status, *msg );

    /* transform myself */

    status =
    _VD_SEND_CHAN( compChan, GRgraphics.GRxform( 	msg,
							&mod_env,
							matType,
							matrix,
							&newObjid ) );
    CheckRC( status, *msg );

    /* display myself in new position */

    dpmode = GRbd;
    status =
    _VD_SEND_MY( GRgraphics.GRdisplay(	msg,
					&mod_env.md_env.matrix_type,
					mod_env.md_env.matrix,
					&dpmode,
					&mod_env.md_id ) );
    CheckRC( status, *msg );

    End
    return status;
}


/*+me
 -------------------------------------------------------------------------
  Public Message VDdeleteRow

  Abstract
        This method deletes itself and its parent associative set object.

  Arguments
        IGRlong         *msg      O     Return code

  Notes/Remarks

  Status/Return Code
      status == OM_S_SUCCESS    if success;
 -------------------------------------------------------------------------
-me*/

method  VDdeleteRow( IGRlong         *msg )
{
    IGRint		size = sizeof( struct GRmd_env );
    IGRlong		status = OM_S_SUCCESS;
    enum GRdpmode	dpmode;
    struct GRid		setId;
    struct GRmd_env	mod_env;
  
    SetProc( VDdrwTblRow.VDdeleteRow ); Begin

    *msg = MSSUCC;

    /* get current module environment */

    status =
    gr$get_module_env(	msg	= msg,
			sizbuf	= &size,
			buffer	= &mod_env );
    CheckRC( status, *msg );

    /* get the parent set id */

    status = 
    _VD_SEND_MY( VDdrwTblRow.VDgetParentSetId(	msg,
						&setId ) );
    CheckRC( status, *msg );

    if( status & *msg & 1 )
    {
        /* delete the set */

        status =
        _VD_SEND_OBJ( setId, VDdrwSet.VDdeleteSet( msg ) );
        CheckRC( status, *msg );
    }

    /* set delete flag */

    me->rowInfo |= VD_ROW_DELETE;

    /* first erase myself */

    dpmode = GRbehe;
    status =
    _VD_SEND_MY( GRgraphics.GRdisplay(	msg,
					&mod_env.md_env.matrix_type,
					mod_env.md_env.matrix,
					&dpmode,
					&mod_env.md_id ) );
    CheckRC( status, *msg );

    /* now delete myself */

    status =
    _VD_SEND_MY( VDdrwTblRow.GRdelete( msg, &mod_env ) );
    CheckRC( status, *msg );

    End
    return status;
}

method VDgetTableHeader( IGRlong         *msg;
                         struct GRid     *TblHdrId;
			 struct GRid	 *TblId )
{
    IGRlong             status = OM_S_SUCCESS;
    OMuint              count = 0;
    struct GRid         tblId;
    GRobjlink           hdrObj;
    OM_S_CHANSELECT     hdrChan, ownerChan;

    SetProc( VDdrwTblRow.VDgetTableHeader ); Begin

    *msg = MSSUCC;

    status =
    om$make_chanselect( channame        = "VDdrwTblRow.to_tblHdr",
                        p_chanselect    = &hdrChan );
    __CheckRC( status, 1, "VDdrwTblRow : make to_tblHdr chanselect", wrapup );

    status =
    om$make_chanselect( channame        = "GRconnector.to_owners",
                        p_chanselect    = &ownerChan );
    __CheckRC( status, 1, "VDdrwTblRow : make to_owners chanselect", wrapup );
   
    /*
     * must get table name
     */

    /* first get the header object */

    status =
    om$get_channel_objects(     objid           = my_id,
                                p_chanselect    = &hdrChan,
                                size            = 1,
                                list            = &hdrObj,
                                count           = &count );
    __CheckRC( status, 1, "om$get_channel_objects", wrapup );

#ifdef vdsDEBUG
    printf( "\n\tHeader id = [%d,%d]\n", hdrObj.S_objid, hdrObj.osnum );
#endif

    /* get the VDdrwTbl object */

    status =
    om$get_objid_at_index(      osnum           = hdrObj.osnum,
                                objid           = hdrObj.S_objid,
                                p_chanselect    = &ownerChan,
                                index           = 0,
                                objidaddr       = &tblId.objid,
                                osnumaddr       = &tblId.osnum );
    __CheckRC( status, 1, "VDdrwTblRow : get_objid_at_index", wrapup );

    if( TblHdrId )	
    {
	TblHdrId->objid = hdrObj.S_objid;
	TblHdrId->osnum = hdrObj.osnum;
    }

    if( TblId )		*TblId = tblId;

wrapup:
    End
    return status;
}

end implementation VDdrwTblRow;

