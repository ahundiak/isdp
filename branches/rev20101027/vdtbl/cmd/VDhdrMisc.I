/* $Id: VDhdrMisc.I,v 1.4 2001/03/14 14:57:23 paul_noel Exp $ */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vds/vdtbl/cmd / VDhdrMisc.I
 *
 * Description:
 *      Implementation of the following methods for VDCmdPlHdr :
 *              my_init
 *              wrap_up
 *              store_cs
 *              VDsetDefaultTblName
 *
 * Dependencies:
 *
 * History:
 *
 *      04/14/95        R. Manem        Creation
 *      04/25/95        R. Manem        Handling of Show button
 *      08/15/95        R. Manem        Save form location
 *
 * -------------------------------------------------------------------*/



class implementation VDCmdPlHdr;

/* 
#define vdsDEBUG
#define vdserrDEBUG
*/

#include <stdio.h>
#include "string.h"

#include "OMmacros.h"
#include "OMprimitives.h"
#include "exproto.h"
#include "exmacros.h"

#include "DIdef.h"
#include "DItypedef.h"
#include "DIglob.h"
#include "DIprims.h"

#include "godef.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"

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
#include "vdtr_macros.h"

%safe
    static int		xPos = 3, yPos = 106; 
%endsafe
    static VDioBufDat VDtbl_expr_file;

from GRgraphics		import	GRdelete;

/*+me
 ---------------------------------------------------------------------------
  Public Message my_init

  Abstract
        This method initializes instance data

  Arguments
        IGRlong         *sts            O       Return code

  Notes/Remarks

  Status/Return Code
      status == OM_S_SUCCESS    
 ---------------------------------------------------------------------------
-me*/

method  my_init ( long * sts )
{
    IGRint		size = sizeof( struct GRmd_env );
    IGRlong		msg,
			status = OM_S_SUCCESS;
    SetProc( VDCmdPlHdr.my_init ); Begin

    *sts = VD_SUCCESS;

    me->tblLayoutName[0] = '\0';
    me->tblName[0] = '\0';

    /* get current module environment */

    status =
    gr$get_module_env(	msg	= &msg,
			sizbuf	= &size,
			buffer	= &me->mod_env );
    CheckRC( status, msg );

    /* initialize temporary objects */

    me->windowId.objid = NULL_OBJID;
    me->showOwnerId.objid = NULL_OBJID;

    /* set locaton for form */

    FIf_set_location( VD_FP, xPos, yPos );

    /* Set file pointer to NULL  */
    VDtbl_expr_file.filebuf = NULL ;
    VDtbl_expr_file.lines = 0 ;
    strcpy(VDtbl_expr_file.partpath,"config/drawing/");
    VDtbl_expr_file.linelength = VDIO_LINE_LEN ;
    strcpy( VDtbl_expr_file.filename, "expr_table" );
    /* read the expr_table file */
    VDio_read_file( &VDtbl_expr_file );


    End
    return OM_S_SUCCESS;
}

/*+me
 ---------------------------------------------------------------------------
  Public Message wrap_up

  Abstract
        This method wraps up the command

  Arguments
        IGRlong         *sts            O       Return code

  Notes/Remarks

  Status/Return Code
      status == OM_S_SUCCESS    
 ---------------------------------------------------------------------------
-me*/

method  wrap_up ( long * sts )
{
    IGRlong		msg,
			status = OM_S_SUCCESS;

    SetProc( VDCmdPlHdr.wrap_up ); Begin

    *sts = VD_SUCCESS;

    /* delete temporary window and owner */

    status = _VD_SEND_MY( VDCmdPlHdr.VDdelPreviewWindow( &msg ) );
    CheckRC( status, msg );

    /* save location of form */

    FIf_get_location( VD_FP, &xPos, &yPos );

    /* end of table layout interface */

    VD_drwlo_iclose( &msg );

   /* Clean file pointer to NULL  */
    if( VDtbl_expr_file.filebuf )
        _FREE( VDtbl_expr_file.filebuf );
    VDtbl_expr_file.filebuf = NULL;
    VDtbl_expr_file.lines = 0 ;
    VDtbl_expr_file.filename[0] = '\0';
    VDtbl_expr_file.partpath[0] = '\0';
    End
    return OM_S_SUCCESS;
}

/*+me
 ---------------------------------------------------------------------------
  Public Message store_cs

  Abstract
        This method stores the located coordinate system

  Arguments
        IGRlong         *sts            O       Return code

  Notes/Remarks

  Status/Return Code
      status == OM_S_SUCCESS
 ---------------------------------------------------------------------------
-me*/

method store_cs( long *sts )
{
    SetProc( VDCmdPlHdr.store_cs ); Begin

    *sts = VD_SUCCESS;

    me->csId.obj_id = me->event1.located_object[0].located_obj ;
    me->csId.mod_env = me->event1.located_object[0].module_info ;

    __DBGpr_obj( "Coordinate system", me->csId.obj_id );
    
    return OM_S_SUCCESS;
}

/*+me
 ---------------------------------------------------------------------------
  Public Message VDsetDefaultTblName

  Abstract
        This method sets the default name for the table in the form

  Arguments
        IGRlong         *sts            O       Return code

  Notes/Remarks

  Status/Return Code
      status == OM_S_SUCCESS
 ---------------------------------------------------------------------------
-me*/

method VDsetDefaultTblName( long *sts )
{
    IGRint		i,
			row, 
			pos, sel;
    IGRchar		*ptr = NULL,
			tmpName[DI_PATH_MAX];
    IGRlong		status = OM_S_SUCCESS;
    OMuword		os;
    struct GRid		obj;

    SetProc( VDCmdPlHdr.VDsetDefaultTblName ); Begin

    *sts = MSSUCC;

    /* get the selected table layout name */

    FIfld_get_active_row( VD_FP, VD_HDR_FMT_LIST_FLD, &row, &pos );
    FIfld_get_text( VD_FP, VD_HDR_FMT_LIST_FLD, row, 0, VD_DRWLO_CHR_IDFLD,
			(unsigned char *)me->tblLayoutName, &sel, &pos );

    if( !sel || !strlen( me->tblLayoutName ) )
	goto wrapup;

    __DBGpr_str( "Table layout name", me->tblLayoutName );

    /* get the path name */

    ex$get_cur_mod(	osnum	= &os );

    status =
    di$give_pathname(	osnum		= os,
			pathname	= tmpName );
    __CheckRC( status, 1, "di$give_pathname", wrapup );

    __DBGpr_str( "Path name ", tmpName );

    ptr = tmpName + strlen(tmpName);

    sprintf( ptr, ":usr:drw_tables:%s", me->tblLayoutName );
    __DBGpr_str( "Full Path name ", tmpName );

    ptr = tmpName + strlen( tmpName );

    for( i = 0 ; i < 1000 ; i++ )
    {
	if( i < 100 )
	    sprintf( ptr, "_%02d", i );
	else
	    sprintf( ptr, "_%03d", i );

	status =
	di$translate(	objname	= tmpName,
			p_objid	= &obj.objid,
			p_osnum	= &obj.osnum );
	
	if( status != DIR_S_SUCCESS )
	{
	    status = OM_S_SUCCESS;
	    break;
	}
    }

    if( i == 1000 )
    {
	__DBGpr_com( "Too many tables : cannot generate default name" );
        FIfld_set_text( VD_FP, VD_HDR_TBL_NAME_FLD, 0, 0, "", FALSE );
	goto wrapup;
    }

    ptr = strrchr( tmpName, ':' );
    ptr++;
    __DBGpr_str( "Table name", ptr );

    strcpy( me->tblName, tmpName );

    __DBGpr_str( "Table name", me->tblName );
    
    FIfld_set_text( VD_FP, VD_HDR_TBL_NAME_FLD, 0, 0, ptr, FALSE );

wrapup :
    End
    return status;
}

method VDdelPreviewWindow( IGRlong *msg )
{
    IGRlong		status = OM_S_SUCCESS;

    SetProc( VDCmdPlHdr.VDdelPreviewWindow ); Begin

    *msg = MSSUCC;

    if( me->windowId.objid != NULL_OBJID )
    {
	status = _VD_SEND_OBJ( me->windowId, Root.delete( 0 ) );
	CheckRC( status, 1 );
    }
	    
    /* if show owner exists, delete it first */

    if( me->showOwnerId.objid != NULL_OBJID )
    {
	status = 
	_VD_SEND_OBJ( me->showOwnerId, GRgraphics.GRdelete( 
						msg,
						&me->mod_env ) );
	CheckRC( status, *msg );
    }

    End;
    return status;
}


/*
 *  We define a small routine which permits to work with the statis structure 
 * outside the source file.
 */
void VDtbl_get_expr_file ( VDioBufDat *info )
{
  *info = VDtbl_expr_file ;
}


end implementation VDCmdPlHdr;
