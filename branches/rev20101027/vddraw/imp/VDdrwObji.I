/* $Id: VDdrwObji.I,v 1.1.1.1 2001/01/04 21:08:38 cvs Exp $ */
/*---------------------------------------------------------------------------
/*  I/VDS
 *
 * File:        vddraw/imp/VDdrwObji.I
 *
 * Description:
 *
 *      This file implements common methods for visualization objects.
 *
 * Dependencies:
 *	VDdrwObj.S
 *
 * History:
 *      11/28/94        adz		Creation Date.
 *	03/27/95	adz		Modification for instance.
 *
 * -------------------------------------------------------------------------
 */

class implementation VDdrwObj;

#include <string.h>
#include "OMmacros.h"
#include "OMprimitives.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "asmacros.h"
#include "nddef.h"

#include "grerr.h"
#include "vds.h"
#include "vddrwattr.h"
#include "v_miscmacros.h"
#include "v_dbgmacros.h"
#include "VDmsg.h"
#include "SMmsg.h"

#include "AS_status.h"

from	GRcontext	import	GRgetmodule_env;
from	ACrg_collect	import	ACshow_data;
from	VDdrw2dVw	import	VDdeleteIfEmpty;
from	VDdrw3dVw	import	VDdeleteIfEmpty;

/*
 * prototypes include files.
 */
#include "v_ioproto.h"

/*+mo
 -------------------------------------------------------------------------

  Overridden Message
       GRgetobjinfo from GRgraphics

  Abstract

	Reports information about the object. 
	It has been overriden to display the type of the main surface when it
	is located (status field).

  Arguments


      IGRlong		*msg             O   	completion code
      struct GRobj_info	*info            O	structure for information about
                                 		the object

  Status/Return Code
     OM_S_SUCCESS	if success;
     OM_E_ABORT		if fails



 -------------------------------------------------------------------------
-mo*/
method GRgetobjinfo(IGRlong *msg; struct GRobj_info *info)
{
	IGRint			sts = OM_S_SUCCESS ;
	IGRchar			*mPtr = NULL ;
	GRname			macName, occName, ownName ;
	VDobjDef		objDef ;

        SetProc( VDdrwObj_GRgetobjinfo ); Begin

        *msg    = MSSUCC ;

        sts = _VD_SEND_MY( VDSroot.VDgetObjDef( msg, &objDef ));
        __CheckRC( sts, *msg, "VDSroot.VDgetObjDef", wrapup );

        strcpy( ownName, VDmsgkey2string( objDef.info ));

	strcpy(	macName, &me->info[0] );
	strcpy(	occName, &me->info[me->indx[0]] );

	mPtr = NULL ; mPtr = strchr( macName, '[' ); if( mPtr ) *mPtr = '\0' ;
	mPtr = NULL ; mPtr = strchr( occName, '[' ); if( mPtr ) *mPtr = '\0' ;

	sprintf( info->type, "%s -%s-%s",  ownName, occName, macName );

	wrapup:
		*msg = MSSUCC;
		return OM_S_SUCCESS;
}

/*+mo
 -------------------------------------------------------------------------

  Overridden Message
       GRdelete from GRgraphics

  Abstract

	Delete the 3d-model object link with the internal set.
	For recompute of the hidden objects.

  Arguments

      IGRlong		*rc              O   	completion code
      struct GRmd_env	*md_env          I	structure for environment

  Status/Return Code
     OM_S_SUCCESS	if success;
     OM_E_ABORT		if fails



 -------------------------------------------------------------------------
-mo*/

method GRdelete(IGRlong *rc ; struct GRmd_env *md_env)
{
	/* 
	 * Check for depencies ...
	 */
	IGRint			sts = OM_S_SUCCESS ;
	struct	GRid		myGRid ,
				drwVw ;
	OM_S_CHANSELECT		*to_set, *to_drw ;
	VDobjDef		objDef ;

	SetProc( VDdrw_GRdelete ); Begin 

	*rc = MSSUCC ;
	myGRid.objid	= my_id ;
	myGRid.osnum	= OM_Gw_current_OS ;

	/*
	 * Disconnect myself from the set before any future action.
	 */
	sts = _VD_SEND_MY( VDSroot.VDgetObjDef( rc, &objDef ));
	__CheckRC( sts, *rc, "VDSroot.VDgetObjDef", wrapup );

	sts = VDdrw_GetToDrwChannel( objDef.type, &to_drw );
	sts = VDdrw_GetToSetChannel( objDef.type, &to_set );
	sts = VDdrw_GetChannelOwner( rc, &myGRid, objDef.type, &drwVw );

	sts = _VD_SEND_MY( Root.disconnect(
				*to_set, drwVw.objid, drwVw.osnum, *to_drw ));
	CheckRC( sts, 1 );

	sts = _VD_SEND_WRT_M( my_id, ASnode.GRdelete( rc, md_env ));

	if( objDef.type & VD_O_drw2d ){
	  sts =
	  _VD_SEND_OBJN( drwVw, VDdrw2dVw.VDdeleteIfEmpty( rc, md_env ));
	}
	else{
	  sts =
	  _VD_SEND_OBJN( drwVw, VDdrw3dVw.VDdeleteIfEmpty( rc, md_env ));
	}
	__CheckRC( sts, *rc, "VDdrwVw.VDdeleteIfEmpty", wrapup );

	wrapup:	
		End ;
		return	sts ;
}

/*+mo
 -------------------------------------------------------------------------

  Overridden Message
        VDprint from VDSroot

  Abstract
        This method prints object information.

 -------------------------------------------------------------------------
-mo*/

method VDprint( long * sts )
{
	IGRint			status = OM_S_SUCCESS,
				count ;
	struct	GRobj_env	ModObj ;
	struct	GRid		myGRid, rgObj, tmpObj, drwVw;
	VDobjDef		objDef ;

	/*
	 * redirect to parents
	 */

	SetProc( VDdrwObj_VDprint ); Begin

	*sts = OM_S_SUCCESS ;

	myGRid.objid	= my_id ;
	myGRid.osnum	= OM_Gw_current_OS ;

	VD_ShowObj( &myGRid );

	/*
	 * find information from parent object.
	 */
	rgObj.objid = NULL_OBJID ;
	status =
	_VD_SEND_MY( NDnode.NDget_objects( 	ND_ROOT, &rgObj,
						1, NULL, 0, 0, &count ));

	VD_ShowObj( &rgObj );

	status =
	_VD_SEND_MY( NDnode.NDget_objects( 	ND_ROOT, &tmpObj,
						1, NULL, 1, 1, &count ));
	if( status & 1 ){
	  status =
	  _VD_SEND_OBJN(tmpObj,
			NDmacro.ACreturn_foot(
					sts,
					"",
					&ModObj._grid,
					&ModObj._matrix_type,
					ModObj._matrix ) );
	  if( status & *sts & 1 ){
		VD_ShowObj( &tmpObj );
		VD_ShowObj( &ModObj._grid );
	  }
	}

	printf("\n");
	printf("\tindexes   :\t%d\t%d\n", me->indx[0], me->indx[1] );
	printf("\tlevel     :\t%d\n", me->level );
        printf("\tsect macr :\t%s\n", &me->info[0] );
        printf("\tsect name :\t%s\n", &me->info[me->indx[0]] );
        printf("\tsect file :\t%s\n", &me->info[me->indx[1]] );

	printf("\n\t------------------------------------------\n\n\n");
	status =
	_VD_SEND_OBJ(	rgObj, ACrg_collect.ACshow_data( sts ));

	printf("\n\t------------------------------------------\n\n\n");

	/*
	 * find the list of all the VDdrw2d/VDdrw3d object which are
	 * connect to this Volume Control object.
	 */
	status = _VD_SEND_MY( VDSroot.VDgetObjDef( sts, &objDef ));
	__CheckRC( status, *sts, "VDSroot.VDgetObjDef", wrapup );

	status = VDdrw_GetChannelOwner( sts, &myGRid, objDef.type, &drwVw );
        __CheckRC( status, *sts, "VDdrw_GetChannelOwner", wrapup );

	VD_ShowObj( &drwVw );

	status = _VD_SEND_OBJ( drwVw, VDSroot.VDprint( sts ));

	wrapup:

		*sts = MSSUCC ;
		End ;
		return	OM_S_SUCCESS ;
}

end implementation VDdrwObj;

