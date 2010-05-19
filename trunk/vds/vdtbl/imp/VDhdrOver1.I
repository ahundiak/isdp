/* $Id: VDhdrOver1.I,v 1.1.1.1 2001/01/04 21:09:27 cvs Exp $  */
/*--------------------------------------------------------------------------
/* I/VDS
 *
 * File:        vdtbl/imp / VDhdrOver1.I
 *
 * Description:
 *	Implementation of the following overridden methods  for VDdrwTblHdr :
 *		GRgetobjinfo
 *		GRdelete
 *		GRcopy
 *		VDgetObjDef
 *		VDcreate
 *		VDcompute
 *
 * Dependencies:
 *
 * History:
 *      
 *	04/14/95	R. Manem	Creation
 *	06/19/95	R. Manem	override GRdelete 
 *	09/06/95	R. Manem	override GRcopy 
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
#include "exmacros.h"

#include "v_miscmacros.h"
#include "v_dbgmacros.h"
#include "v_datamacros.h"

#include "godef.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"

#include "DItypedef.h"
#include "DIdef.h"
#include "DIprims.h"

#include "nddef.h"

#include "vds.h"
#include "emsdef.h"
#include "EMSutlmacros.h"

#include "VDdrwlo.h"
#include "VDdrwtbl.h"

/*+mo
 -------------------------------------------------------------------------
  Overridden Message
        GRgetobjinfo from ACncpx

  Abstract
        Reports information about the object.
        Returns "TABLE "<table-name>": header (part <table part number>)"

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
    OM_S_CHANSELECT	ownerChan;

    
    SetProc( VDdrwTblHdr.GRgetobjinfo ); Begin

    /* select the channel */

    status =
    om$make_chanselect( channame        = "GRconnector.to_owners",
                        p_chanselect    = &ownerChan );
    __CheckRC( status, 1, "selecting toHdrChan", wrapup );

    /* get table name */

    status =
    om$send(	msg		= message GRgraphics.GRgetname( msg, pathname ),
		p_chanselect	= &ownerChan,
		from 		= 0,
		to		= 0 );
    __CheckRC( status, *msg, "GRgraphics.GRgetname", wrapup );

    /* strip off the directory name */

    status = di$split(	pathname	= pathname,
			name		= tblName );

    __DBGpr_str( "\n\ttblName", tblName );

    /* print the object info in the return structure */

    sprintf( info->type, "TABLE \"%s\": header (part %d)", tblName, 
							me->tblPartNo );

    End
    return OM_S_SUCCESS;

wrapup :

    sprintf( info->type, "TABLE: header (part %d)", me->tblPartNo );

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
        This prevents accidental deletion of header, using the delete
        button.  Header can only be deleted through the VDdeleteHdr message
        which will set the delete flag to 1.

  Arguments
        IGRlong                 *msg      O     completion code
        struct GRmd_env         *md_env   I     structure containing context
                                                info

 -------------------------------------------------------------------------
-mo*/

method  GRdelete(       IGRlong         *msg;
                        struct GRmd_env *md_env )
{
    enum GRdpmode	dpmode = GRbd;
    IGRlong             status = OM_S_SUCCESS;

    SetProc( VDdrwTblHdr.GRdelete ); Begin
    *msg = MSSUCC;

    /* verify that hdr delete flag is set */

    if( !( me->hdrInfo & VD_HDR_DELETE ) )
    {
        __DBGpr_com( "\n\tWARNING : Cannot delete table header, flag not set" );
	UI_status( "Cannot delete table header" );

	/* display myself */

	status =
	_VD_SEND_MY( GRgraphics.GRdisplay(	msg,
						&md_env->md_env.matrix_type,
						md_env->md_env.matrix,
						&dpmode,
						&md_env->md_id ) );
	CheckRC( status, *msg );
						
        goto wrapup;
    }

    /* delete myself */

    status =
    om$send(	msg		= message VDSroot.GRdelete( msg, md_env ),
		targetid	= my_id,
		mode		= OM_e_wrt_message );
    CheckRC( status, *msg );

wrapup :
    End
    return status;
}

/*+mo
 -------------------------------------------------------------------------
  Overridden Message
	GRcopy from GRgraphics

  Abstract
	Overridden to prevent copy of table header.

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
    UI_status( "Cannot copy table headers. Reset command" );

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

method  VDgetObjDef(    IGRlong         *msg;
                        VDobjDef        *objDef )
{
    IGRlong             status = OM_S_SUCCESS;

    SetProc( VDdrwTblHdr.VDgetObjDef ); Begin

    *msg = MSSUCC;

/*
????? need to define in message file
    objDef->info = VD_I_ObjTableHeader;
*/

    objDef->type = 0;

    return status;
}

/*+me
 -------------------------------------------------------------------------

  Public Message VDcreate

  Abstract
        This message fills all the parameters of the macro and
        place it.
	Overridden to avoid setting state to ND_DONT_MVRT.  Object should not
	be deleted if any parent is deleted.

  Arguments
        IGRlong         *msg            O : Completion code.
        IGRint          nbAttr          I : nb attributes in the ACrg_coll
        struct ACrg_coll *Attr          I : the attributes
        IGRchar         *macroName      I : Name of macro.
        IGRint          prop            I : Compute properties.
        IGRint          nbParents       I : number of graphical parent objects
        struct GRid     *parents        I : the surface

  Status/Return Code
        OM_S_SUCCESS    if success;
        OM_E_ABORT      if fails


 -------------------------------------------------------------------------
-me*/

method VDcreate(IGRlong                 *msg;
                IGRint                  nbAttr;
                struct ACrg_coll        *Attr;
                IGRchar                 *macroName;
                IGRint                  prop;
                IGRint                  nbParents;
                struct GRid             *parents )
{
    IGRlong		status = OM_S_SUCCESS;

    SetProc( VDdrwTblHdr.VDcreate ); Begin

    *msg = MSSUCC;

/*
????? Must check the ifdef vds_30 in the parent class method
*/

    status =
    _VD_SEND_WRT_M( my_id, VDSroot.VDcreate( 	msg,
						nbAttr,	
						Attr,
						macroName,
						prop,
						nbParents,
						parents ) );
    __CheckRC( status, *msg, "VDSroot.VDcreate", wrapup );

/*
    status =
    _VD_SEND_MY( NDnode.NDchg_state( ND_DEFAULT, ND_DEFAULT ) );
    __CheckRC( status, 1, "NDnode.NDchg_state", wrapup );
*/

wrapup :
    End
    return status;
}

/*+me
 -------------------------------------------------------------------------
  Public Message
        VDcompute

  Abstract
	Forces recompute of the object.
	Overridden to call "VDconstructHdrTrl"

  Status/Return Code
        OM_S_SUCCESS    if success;
        OM_E_ABORT      if fails

 -------------------------------------------------------------------------
-me*/

method VDcompute(       IGRlong                 *msg;
                        IGRint                  *type )
{
    IGRlong		status = OM_S_SUCCESS;

    SetProc( VDdrwTblHdr.VDcompute ); Begin

    *msg = MSSUCC;

    status =
    _VD_SEND_MY( VDdrwTblHdr.VDconstructHdrTrl( msg ) );
    CheckRC( status, *msg );

    End
    return status;
}


end implementation VDdrwTblHdr;

