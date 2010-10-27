/* $Id: VDrowOver1.I,v 1.1.1.1 2001/01/04 21:09:28 cvs Exp $  */
/*--------------------------------------------------------------------------
/* I/VDS
 *
 * File:        vdtbl/imp / VDrowOver1.I
 *
 * Description:
 *	Implementation of the following overridden methods  for VDdrwTblRow :
 *		GRgetobjinfo
 *		GRdelete
 *		GRcopy
 *		VDgetObjDef
 *
 * Dependencies:
 *
 * History:
 *      
 *	04/14/95	R. Manem	Creation
 *	06/19/95	R. Manem	Override GRdelete
 *	09/06/95	R. Manem	Override GRcopy
 *	09/20/95	R. Manem	Allow row deletion, if it is not
 *					connected to any header object.
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

#include "godef.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"

#include "DItypedef.h"
#include "DIdef.h"
#include "DIprims.h"

#include "go.h"

#include "vds.h"

#include "VDdrwlo.h"
#include "VDdrwtbl.h"

/*+mo
 -------------------------------------------------------------------------
  Overridden Message
        GRgetobjinfo from ACncpx

  Abstract
        Reports information about the object.
        Returns "TABLE "<table-name>":row(<row_number>)"

  Arguments
        IGRlong                 *msg      O     Return code
        struct GRobj_info       *info     O     Object info string

 -------------------------------------------------------------------------
-mo*/

method GRgetobjinfo(	IGRlong			*msg;
			struct GRobj_info	*info )
{
    IGRchar		pathname[DI_PATH_MAX];
    GRname		tblName;
    IGRlong		status = OM_S_SUCCESS;
    OMuint		count = 0;
    struct GRid		tblId;
    GRobjlink		hdrObj;
    OM_S_CHANSELECT	hdrChan, ownerChan;

    
    SetProc( VDdrwTblRow.GRgetobjinfo ); Begin

    /* select the channels */

    status =
    om$make_chanselect(	channame        = "VDdrwTblRow.to_tblHdr",
			p_chanselect    = &hdrChan );
    __CheckRC( status, 1, "VDdrwTblRow : make to_tblHdr chanselect", wrapup );

    status =
    om$make_chanselect(	channame        = "GRconnector.to_owners",
			p_chanselect    = &ownerChan );
    __CheckRC( status, 1, "VDdrwTblRow : make to_owners chanselect", wrapup );
    
    /* 
     * must get table name 
     */

    /* first get the header object */

    status =
    om$get_channel_objects(	objid		= my_id,
				p_chanselect	= &hdrChan,
				size		= 1,
				list		= &hdrObj,
				count		= &count );
    __CheckRC( status, 1, "om$get_channel_objects", wrapup );

#ifdef vdsDEBUG
    printf( "\n\tHeader id = [%d,%d]\n", hdrObj.S_objid, hdrObj.osnum );
#endif

    /* get the VDdrwTbl object */

    status =
    om$get_objid_at_index(	osnum		= hdrObj.osnum,
				objid		= hdrObj.S_objid,
				p_chanselect	= &ownerChan,
				index		= 0,
				objidaddr	= &tblId.objid,
				osnumaddr	= &tblId.osnum );
    __CheckRC( status, 1, "VDdrwTblRow : get_objid_at_index", wrapup );
    
    __DBGpr_obj( "Table id", tblId );

    /* get table name */

    status =
    _VD_SEND_OBJ( tblId, GRgraphics.GRgetname( 	msg,
						pathname ) );
    __CheckRC( status, *msg, "GRgraphics.GRgetname", wrapup );

    /* strip off the directory name */

    status = di$split(  pathname        = pathname,
                        name            = tblName );

    __DBGpr_str( "\n\ttblName", tblName );

    /* print the object info in the return structure */

    sprintf( info->type, "TABLE \"%s\": row[%d]", tblName, me->rowNumber );

    End
    return OM_S_SUCCESS;

wrapup :

    sprintf( info->type, "TABLE: row[%d]", me->rowNumber );

    End
    *msg = MSSUCC;
    return OM_S_SUCCESS;
}

/*+mo
 -------------------------------------------------------------------------
  Overridden Message
        GRdelete from GRgraphics

  Abstract
        This method deletes the graphics objects from the object space.
        Overridden to avoid deleting myself, if the delete flag is not set.
        This prevents accidental deletion of row, by user using the delete
        button.  Row can only be deleted through the VDdeleteRow message
        which will set the delete flag to 1.

	09/20/95 - Row is also allowed to be deleted, if it is not
	connected to any header object.  This is necessary just in case
	the Modify Table command aborts, leaving the row objects disconnected

  Arguments
        IGRlong                 *msg      O     completion code
        struct GRmd_env         *md_env   I     structure containing context
                                                info

 -------------------------------------------------------------------------
-mo*/

method 	GRdelete(	IGRlong		*msg;
			struct GRmd_env	*md_env )
{
    enum GRdpmode	dpmode = GRbd;
    IGRlong		status = OM_S_SUCCESS;
    OMuint		count = 0;
    GRobjlink		hdrObj;
    OM_S_CHANSELECT	hdrChan;
   
    SetProc( VDdrwTblRow.GRdelete ); Begin
    *msg = MSSUCC;

    /* select header channel */

    status =
    om$make_chanselect(	channame        = "VDdrwTblRow.to_tblHdr",
			p_chanselect    = &hdrChan );
    __CheckRC( status, 1, "VDdrwTblRow : make to_tblHdr chanselect", wrapup );

    /* get the header object */

    hdrObj.S_objid = NULL_OBJID;

    om$get_channel_objects(	objid		= my_id,
				p_chanselect	= &hdrChan,
				size		= 1,
				list		= &hdrObj,
				count		= &count );

#ifdef vdsDEBUG
    printf( "\n\tHeader id = [%d,%d]\n", hdrObj.S_objid, hdrObj.osnum );
#endif

    /* verify that row can be deleted */

    if( !( me->rowInfo & VD_ROW_DELETE ) && hdrObj.S_objid != NULL_OBJID )
    {
	__DBGpr_com( "\n\tWARNING : Cannot delete table row, flag not set" );
	UI_status( "Cannot delete table row" );

        /* display myself */

        status =
        _VD_SEND_MY( GRgraphics.GRdisplay(      msg,
                                                &md_env->md_env.matrix_type,
                                                md_env->md_env.matrix,
                                                &dpmode,
                                                &md_env->md_id ) );
        CheckRC( status, *msg );
	
	goto wrapup;
    }

    /* delete myself */

    status =
    om$send(    msg             = message ASnode.GRdelete( msg, md_env ),
                targetid        = my_id,
                mode            = OM_e_wrt_message );
    CheckRC( status, *msg );

wrapup :
    End
    return status ;
}

/*+mo
 -------------------------------------------------------------------------
  Overridden Message
	GRcopy from GRgraphics

  Abstract
	Overridden to prevent copy of table row.

  Arguments
	IGRlong		*msg	  	O	Return code
	struct GRmd_env	*obj_dsenv 	I	Object's present env
	struct GRmd_env	*new_dsenv 	I	Object's copy env
	GRobjid		*newobjid	O	objid of copied object

  Return Status
	status  = OM_S_SUCCESS
	*msg	= MSSUCC

  Notes :
	*newobjid is set to NULL_OBJID; A message is displayed in status
	field.

 -------------------------------------------------------------------------
-mo*/

method  GRcopy(	IGRlong			*msg;
		struct GRmd_env		*obj_dsenv;
		struct GRmd_env		*new_dsenv;
		GRobjid			*newobjid )
{
    IGRlong		status = OM_S_SUCCESS;

    SetProc( VDdrwTblRow.GRcopy ); Begin
    *msg = MSSUCC;

    *newobjid = NULL_OBJID;
    UI_status( "Cannot copy table row. Reset command" );

    End
    return status;
}


/*+mo
 -------------------------------------------------------------------------
  Overridden Message
        VDgetObjDef from VDSroot

  Abstract
        Returns the definition of the object

  Arguments
        IGRlong                 *msg      O     Return code
        VDobjDef                *objDef   O     Object definition

 -------------------------------------------------------------------------
-mo*/

method  VDgetObjDef(	IGRlong		*msg;
			VDobjDef	*objDef )
{
    IGRlong		status = OM_S_SUCCESS;

    SetProc( VDdrwTblRow.VDgetObjDef ); Begin

    *msg = MSSUCC;

/*
????? need to define in message file
    objDef->info = VD_I_ObjTableRow;
*/

    objDef->type = 0;

    return status;
}

end implementation VDdrwTblRow;

