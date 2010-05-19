/* $Id: VDdrw_updTbl.I,v 1.1.1.1 2001/01/04 21:09:27 cvs Exp $  */

/* I/VDS
 * -------------------------------------------------------------------------
 *
 * File:        vdtbl/func / VDdrw_recomp.I
 *
 * Description:
 *	Implementation of the following functions for checking and 
 *	updating table dependencies:  
 *		VDdrw_checkTblDependency
 *		VDupdateBrokenDep
 *		VDupdateMismatchDep
 *		VDdrw_checkDependency
 *
 *
 * Dependencies:
 *
 * History:
 *
 *	10/10/95	R. Manem	Creation
 *	10/11/95	R. Manem	Added VDdrw_checkDependency
 *					Backup, to remove support for
 *					minimal table update.
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
#include "execmsg.h"
#include "msmacros.h"

#include "nddef.h"
#include "ndmacros.h"
#include "asbox.h"

#include "godef.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"

#include "v_miscmacros.h"
#include "v_dbgmacros.h"
#include "v_datamacros.h"

#include "VDdrwlo.h"
#include "VDdrwtbl.h"

from NDnode		import	NDmove_to_root,
				ASreturn_go,
				NDget_objects,
				NDchange_node;
from VDdrwTbl		import	VDgetTotalNbOfRows,
				VDgetTableParts;
from VDdrwTblHdr	import	VDgetRowInfo,
				VDrowNoToGRid;
from VDdrwTblRow	import	VDgetParentSetId;

#ifdef MIN_TBL_UPDATE	/* -----------Begin MIN_TBL_UPDATE------------- */

/*+fe
 -------------------------------------------------------------------------
  Function VDupdateBrokenDep

  Abstract
	Function updates the dependency of the broken connection

  Arguments
	IGRlong			*msg	    	O	return code
	OM_S_TAG_CON_INFO	tag		I	tag info

  Remarks
	The dependency is updated by sending the NDmove_to_root message
	to the children.

  Returns
	OM_S_SUCCESS	= if success
 -------------------------------------------------------------------------
-fe*/

IGRlong VDupdateBrokenDep(	IGRlong			*msg,
				OM_S_TAG_CON_INFO	tag )
{
    IGRint		size = sizeof( struct GRmd_env );
    IGRlong		status = OM_S_SUCCESS;
    struct GRmd_env	mod_env;
    struct GRid		obj;

    SetProc( VDupdateBrokenDep ); Begin

    /* get current module environment */

    status = gr$get_module_env( msg     = msg,
                                sizbuf  = &size,
                                buffer  = &mod_env );
    CheckRC( status, *msg );

    om$send(	msg		= message NDnode.NDmove_to_root( msg, 
							&obj, &mod_env ),
		senderid	= tag.objid,
		p_chanselect	= &ND_children,
		targetos	= mod_env.md_id.osnum );

    /* delete the temporary pretendin */

    obj.objid = tag.objid;
    obj.osnum = mod_env.md_id.osnum;

    __DBGpr_obj( "Deleting object", obj );
    _VD_SEND_OBJN( obj, Root.delete( 0 ) );

    *msg = MSSUCC;
    status = OM_S_SUCCESS;

    End
    return status;
}

/*+fe
 -------------------------------------------------------------------------
  Function VDupdateMismatchDep

  Abstract
	Function updates the dependency of the mismatched connection

  Arguments
	IGRlong			*msg	    	O	return code
	OM_S_TAG_CON_INFO	tag		I	tag info

  Returns
	OM_S_SUCCESS	= if success
 -------------------------------------------------------------------------
-fe*/

IGRlong VDupdateMismatchDep(	IGRlong			*msg,
				OM_S_TAG_CON_INFO	tag )
{
    IGRint		size = sizeof( struct GRmd_env );
    IGRlong		status = OM_S_SUCCESS;
    OM_S_OBJID		tagId;
    OMuword		version,
			TagConVers,
			refOs;
    OM_S_CHANSELECT	toTaggedObj,
			toChild;
    struct GRmd_env	mod_env;
    struct GRid		obj, goId;

    SetProc( VDupdateMismatchDep ); Begin

    /* get current module environment */

    status = gr$get_module_env( msg     = msg,
                                sizbuf  = &size,
                                buffer  = &mod_env );
    CheckRC( status, *msg );

    /* need reference osnum : get it from parent object in ref file */

    obj.objid = tag.objid;
    obj.osnum = mod_env.md_id.osnum;

    status =
    _VD_SEND_OBJN( obj, NDnode.ASreturn_go( &goId, NULL, NULL ) );
    CheckRC( status, *msg );

    __DBGpr_obj( "Graphic object id", goId );

    refOs = goId.osnum;
    __DBGpr_int( "Reference osnum", refOs );

    /* just copied code from vdstartup/imp/VDupdrefdep.I */

    /* put obj in compute batch via NDchange_node */

    om$send(	msg	= message NDnode.NDchange_node( &mod_env ),
		senderid = tag.objid,	
		targetid = tag.objid,
		targetos = mod_env.md_id.osnum );

    /* have this obj's tag version now match that of its parent */

    om$tag_to_objid(	osnum	= refOs,
			tag	= tag.tag,
			p_objid	= &tagId );
    __DBGpr_int( "Tagged id", tagId );

    toTaggedObj.type		= OM_e_num;
    toTaggedObj.u_sel.number	= tag.tag_chan;
    toChild.type		= OM_e_num;
    toChild.u_sel.number	= tag.chan;

    om$test_connection(	objid			= tag.objid,
			osnum			= mod_env.md_id.osnum,
			p_chanselect		= &toChild,
			tag_osnum		= refOs,
			tag_objid		= tagId,
			p_tag_version		= &version,
			p_tag_connect_version	= &TagConVers,
			p_tag_chanselect	= &toTaggedObj,
			force_flag		= TRUE );

    End
    return status;
}

/*+fe
 -------------------------------------------------------------------------
  Function VDdrw_checkTblDependency

  Abstract
	Function checks if the table rows are up-to-date w.r.t objects
	in the reference files.  It also optionally updates the dependencies.

  Arguments
	IGRlong		*msg	    	O	return code
	struct GRid	*tblId		I	GRid of table to check dep.
	struct GRid	*rowId		I	GRid of row to check dep.
	IGRint		update		I	1 = update dependency
						0 = do not update
	IGRint		*upToDate	O	1 = up to date
						0 = out of date (need updating)

  Remarks
	Either tblId or rowId must be specified.  If rowId is specified
	only that row is checked if it is up-to-date.
	If tblId is specified, then all rows in the table are checked.
	If update flag is 1, then the rowId (if rowId is specified) or
	all dependent table rows (if tblId is specified) will be updated.
	
  Returns
	OM_S_SUCCESS	= if success
	OM_E_ABORT	= if error
 -------------------------------------------------------------------------
-fe*/

IGRlong VDdrw_checkTblDependency(	IGRlong		*msg,
					struct GRid	*tblId,
					struct GRid	*rowId,
					IGRint		update,
					IGRint		*upToDate )
{
    IGRint		i, j, k,
			ind = 0,
			nbRows,
			nbParts,
			nbPars,
			nbHdrRows,
			startRowNo,
			nbMismatch, nbBroken,
			size = sizeof( struct GRmd_env );
    IGRlong		status = OM_S_SUCCESS;
    struct GRid		*hdrIds = NULL,
			*rowIds = NULL,
			setId,
			*lPars = NULL,
			oneRow;
    struct GRmd_env	mod_env;
    OM_S_TAG_CON_INFO	*misTags = NULL,
			*brkTags = NULL;

    SetProc( VDdrw_checkTblDependency ); Begin
    *msg = MSSUCC;

    *upToDate = TRUE;

    if( !tblId && !rowId )
	goto wrapup;

    if( tblId )
	__DBGpr_obj( "Table id", *tblId );

    if( rowId )
    	__DBGpr_obj( "Row id", *rowId );

    __DBGpr_int( "Update flag", update );

    /* get current module environment */

    status = gr$get_module_env( msg     = msg,
                                sizbuf  = &size,
                                buffer  = &mod_env );
    CheckRC( status, *msg );

    /* get the list of dependencies */

    VDScheckRefFilesDependency( msg, FALSE, 	
				&nbMismatch, NULL,
				&nbBroken, NULL,
				NULL, NULL,
				NULL, NULL );

    /* If No mismatched or broken connections, no update needed */

    if( !nbMismatch && !nbBroken )
	goto wrapup;
   
    /* allocate memory for output buffers */

    if( nbMismatch )
    {
	misTags = _MALLOC( nbMismatch, OM_S_TAG_CON_INFO );
	if( !misTags )
	{
	    status = OM_E_NODYNMEM;
	    goto wrapup;
	}
    }

    if( nbBroken )
    {
	brkTags = _MALLOC( nbBroken, OM_S_TAG_CON_INFO );
	if( !brkTags )
	{
	    status = OM_E_NODYNMEM;
	    goto wrapup;
	}
    }

    /* get the list */

    VDScheckRefFilesDependency( msg, FALSE, 	
				&nbMismatch, misTags,
				&nbBroken, brkTags,
				NULL, NULL,
				NULL, NULL );

#ifdef vdsDEBUG
    printf( "\n\tNumber of mismatched tags : %d\n", nbMismatch );
    for( i = 0 ; i < nbMismatch ; i++ )
        printf( "\t\t# %d : %d\n", i, misTags[i].objid );

    printf( "\n\tNumber of broken tags : %d\n", nbBroken );
    for( i = 0 ; i < nbBroken ; i++ )
        printf( "\t\t# %d : %d\n", i, brkTags[i].objid );
#endif

    /* if rowId is specified just check if it is in the list */

    if( rowId )
    {
	/* only one row to check */

	rowIds = &oneRow;
	rowIds[0] = *rowId;
	nbRows = 1;
    }

    if( tblId )
    {
	/* get total number of rows in table */

	status =
	_VD_SEND_OBJN( *tblId, VDdrwTbl.VDgetTotalNbOfRows( msg, &nbRows ) );
	__CheckRC( status, *msg, "VDdrwTbl.VDgetTotalNbOfRows", wrapup );

	if( !nbRows )
	{
	    __DBGpr_int( "No rows in table", nbRows );
	    goto wrapup;
	}

	/* allocate memory for rows */

	rowIds = _MALLOC( nbRows, struct GRid );
	if( !rowIds )
	{
	    status = OM_E_NODYNMEM;
	    printf( "Error in dynamic allocation\n" );
	    goto wrapup;
	}

	/* get table headers */

	status =
	_VD_SEND_OBJN( *tblId, VDdrwTbl.VDgetTableParts( msg, &nbParts, NULL ) );
	__CheckRC( status, *msg, "VDdrwTbl.VDgetTableParts", wrapup );

	__DBGpr_int( "Number of table parts", nbParts );

	if( !nbParts )
	{
	    __DBGpr_com( "Error : no table parts" );
	    goto wrapup;
	}

	/* allocate memory for headers */

	hdrIds = _MALLOC( nbParts, struct GRid );
	if( !hdrIds )
	{
	    printf( "Error in dynamic allocation" );
	    goto wrapup;
	}

	status =
	_VD_SEND_OBJN( *tblId, VDdrwTbl.VDgetTableParts( msg, &nbParts, hdrIds ) );
	__CheckRC( status, *msg, "VDdrwTbl.VDgetTableParts", wrapup );

	__DBGpr_objlist( "Header ids", nbParts, hdrIds );

	/* for each header, get row info */

	for( i = 0 ; i < nbParts ; i++ )
	{
	    status =
	    _VD_SEND_OBJN( hdrIds[i], VDdrwTblHdr.VDgetRowInfo( msg,
								&nbHdrRows,
								&startRowNo ) );
	    __CheckRC( status, *msg, "VDdrwTblHdr.VDgetRowInfo", wrapup );

	    __DBGpr_int( "No of rows in header", nbHdrRows );
	    __DBGpr_int( "Start row number", startRowNo );
	
	    for( j = startRowNo ; j < (startRowNo + nbHdrRows) ; j++ )
	    {
		status =
		_VD_SEND_OBJN( hdrIds[i], VDdrwTblHdr.VDrowNoToGRid(
							msg, 
							j,
							&rowIds[ind] ) );
		__CheckRC( status, *msg, "VDdrwTblHdr.VDrowNoToGRid", wrapup );
	
		ind++;
	    }
	}
	__DBGpr_objlist( "List of rowIds", nbRows, rowIds );
    }

    /* for each row check the dependency */

    for( i = 0 ; i < nbRows ; i++ )
    {
	/* get parent set id */

	status =
	_VD_SEND_OBJN( rowIds[i], VDdrwTblRow.VDgetParentSetId( msg, &setId ) );
	
	/* message will fail for user defined rows */

	if( !(status & *msg & 1) )
	    continue;

	__DBGpr_obj( "Parent set id", setId );

	/* get list of parents for the setId */

	nbPars = 0;
	status =
	_VD_SEND_OBJN( setId, NDnode.NDget_objects(	ND_ROOT,
							NULL,
							0,
							NULL,
							0,
							OM_K_MAXINT,
							&nbPars ) );
	__CheckRC( status, 1, "NDnode.NDget_objects", wrapup );
	
	__DBGpr_int( "Number of parents", nbPars );

	/* allocate memory and get the list */

	_FREE( lPars );
	lPars = _MALLOC( nbPars, struct GRid );
	if( !lPars )
	{
	    printf( "Error in dynamic allocation\n" );
	    status = OM_E_NODYNMEM;
	    goto wrapup;
	}

	status =
	_VD_SEND_OBJN( setId, NDnode.NDget_objects(	ND_ROOT,
							lPars,
							nbPars,
							NULL,
							0,
							OM_K_MAXINT,
							&nbPars ) );
	__CheckRC( status, 1, "NDnode.NDget_objects", wrapup );

	__DBGpr_objlist( "List of parents", nbPars, lPars );
	
	/* 
	 * for each of these parents, probably pretendins, check if it is
	 * in the list of mismatched or broken connections 
	 */

	for( j = 0 ; j < nbPars ; j++ )
	{
	    /* first check in broken connections list */

	    __DBGpr_int( "Loop index j", j );
	    __DBGpr_int( "lPars[j].objid", lPars[j].objid );

	    for( k = 0 ; k < nbBroken ; k++ )
	    {

		if( lPars[j].objid == brkTags[k].objid )
		{
		    *upToDate = FALSE;

		    /* update if necessary */

		    if( update )
		    {
			VDupdateBrokenDep( msg, brkTags[k] );
/*
			status =
			_VD_SEND_OBJN( setId, NDnode.NDmove_to_root( 
								msg,
								&obj,
								&mod_env ) );
			CheckRC( status, *msg );
*/
		    }

		    break;
		}
	    }

	    if( k < nbBroken )
		continue;

	    /* check in mismatched connections list */

	    for( k = 0 ; k < nbMismatch ; k++ )
	    {
		if( lPars[j].objid == misTags[k].objid )
		{
		    *upToDate = FALSE;

		    if( update )
			VDupdateMismatchDep( msg, misTags[k] );

		    break;
		}
	    }
	}
    }

wrapup :    

    if( rowIds != &oneRow )
        _FREE( rowIds );
    _FREE( brkTags );
    _FREE( misTags );
    _FREE( hdrIds );
    _FREE( lPars );

    *msg = MSSUCC;

    End
    return status;
}

#endif 			/* -----------End MIN_TBL_UPDATE------------- */

/*+fe
 -------------------------------------------------------------------------
  Function VDdrw_checkDependency

  Abstract
        Function checks if the design file is up to date or not.  If
	it is not up-to-date, it displays a message box saying so.

  Arguments
        IGRlong                 *msg            O       return code
	IGRint			*upToDate	O	1 = uptodate
							0 = not uptodate
  Returns
        OM_S_SUCCESS    = if success
 -------------------------------------------------------------------------
-fe*/

IGRlong VDdrw_checkDependency(	IGRlong		*msg,
				IGRint		*upToDate )
{
    IGRint		nbModRef;
    IGRlong		status = OM_S_SUCCESS;
    
    SetProc( VDdrw_checkDependency ); Begin

    status = VDScheckRefFilesDependency( msg, FALSE, &nbModRef, NULL );
    __DBGpr_int( "nbModRef", nbModRef );

    if( nbModRef > 0 )
    {
	*upToDate = 0;

        ex$message(	msgnumb		= EX_F_Var1,
			type		= "%s",
			var		= "Ref. files have been modified since this file was saved. Use \"Update Drawing\" to update dependencies before using this command" );
    }
    else
	*upToDate = 1;


wrapup :

    End
    return status;
}

end implementation Root;
