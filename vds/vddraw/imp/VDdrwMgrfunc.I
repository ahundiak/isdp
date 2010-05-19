/* $Id: VDdrwMgrfunc.I,v 1.1.1.1 2001/01/04 21:08:38 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vddraw/imp/VDdrwMgrfunc.I
 *
 * Description:
 *      This file implements drawing management functions in I/VDS.
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDdrwMgrfunc.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:08:38  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.3  1995/08/23  20:04:22  pinnacle
# Replaced: vddraw/imp/VDdrwMgrfunc.I for:  by azuurhou for vds.240
#
# Revision 1.2  1995/07/11  21:52:10  pinnacle
# Replaced: vddraw/imp/VDdrwMgrfunc.I for:  by azuurhou for vds.240
#
# Revision 1.1  1995/06/27  21:07:22  pinnacle
# Created: vddraw/imp/VDdrwMgrfunc.I by azuurhou for vds.240
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *	06/06/95	adz		new.
 *
 * -------------------------------------------------------------------*/

class implementation Root;

#include <stdio.h>
#include <math.h>
#include "OMminimum.h"
#include "OMprimitives.h"
#include "OMerrordef.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "godef.h"
#include "go.h"
#include "macro.h"
#include "griomacros.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "EMSmsgdef.h"

#include "vddrwattr.h"
#include "v_datamacros.h"
#include "v_miscmacros.h"
#include "v_geommacros.h"
#include "v_dbgmacros.h"

from	GRvg		import	GRgetattr, GRputattr ;
from	GRconnector	import	GRflexconn;

extern	OMuword		OPP_VDdrw2dVw_class_id ,
			OPP_VDdrw3dVw_class_id ;


/*+fe
Function   VDdrwMgrGetInfo()

Abstract
	This function give information back about the visualization 
	control objects, visualization objects and the eventual 3-model
	objects, connected to the visualization objects.

Arguments
	OUT	IGRlong		*msg		return status
	IN	struct GRmd_env	*mdEnv		Module Environment
	IN	IGRushort	type		Object Type (see vddrwattr.h)
	IN(opt)	IGRchar		*name		Object Name
	IN(opt)	IGRushort	mask		Select Mask for objects.
	OUT	IGRint		*number		Number Found.
	OUT	struct GRid	**grids		List of Object Identifiers.
	OUT	struct GRobj_env **objenvs	List of Object Id + Env.
	
Important
	This function will allocate memory for the output list. Either
	'grids' or 'objenvs' can be defined as output list.
	Memory needs to be freeed.

Return status
	OM_S_SUCCESS	oke.
	OM_E_NODYNMEM	No memory allocation problem.
	OM_E_ABORT	otherwise.

History
	06/06/95	adz		creation date
-fe*/

long VDdrwMgrGetInfo ( msg, mdEnv, type, name, mask, number, grids, objenvs )

IGRlong		*msg;			/* return status             */
struct GRmd_env	*mdEnv;			/* Module Environment        */
IGRushort	type;			/* Object Type (vddrwattr.h) */
IGRchar		*name;			/* Object Name               */
IGRushort	*mask;			/* Select Mask for objects.  */
IGRint		*number;		/* Number Found.             */
struct GRid	*grids[];		/* List of Object Id.        */
struct GRobj_env *objenvs[] ;		/* List of Object Id+Env     */
	
{
	/*
	 * Get all needed information using the VDdrwMgr object as
	 * reference object.
	 */
	IGRint			sts = OM_S_SUCCESS,
				i,
				typCount = 0,
				drwCount = 0,
				count = 0 ;
	struct	GRid		drwMgr ,
				drwVw ;
	OMuword			classId ;
	GRobjlink		*Comps = NULL ;
	VDpartAttr		attr ;
	OM_S_CHANSELECT		to_comp;

	SetProc( VDdrwMgrGetInfo ); Begin

	*msg		= MSSUCC;
	*number		= 0 ;

	if( grids )	*grids   = NULL ;
	if( objenvs )	*objenvs = NULL ;

	VD_drwConst_VDdrwMgrSuper( msg, &drwMgr );

	sts = GRget_to_comp_chansel( &to_comp );
	sts = GRget_to_comp_info( &to_comp, drwMgr.osnum, drwMgr.objid, &count);
	
	if( ! count ) goto wrapup ;

	if( !(Comps = _MALLOC(	count, GRobjlink )))
		vd_$mem_fail();
	
	sts =
	om$get_channel_objects(	objid		=  drwMgr.objid,
				osnum		=  drwMgr.osnum,
				p_chanselect	=  &to_comp,
				list		=  Comps,
				size		=  (OMuint )   count,
				count		=  (OMuint *) &count );

	/*
	 * Get the needed object (depending on "type").
	 */
	typCount = 0 ;
	for( i=0 ; i<count ; i++ ){

		sts =
		om$get_classid(	osnum	= Comps[i].osnum,
				objid	= Comps[i].S_objid,
				p_classid = &classId );

		if( om$is_ancestry_valid(
				subclassid	= classId,
				superclassid	= OPP_VDdrw2dVw_class_id ) ==
							OM_S_SUCCESS ){

		  if( type & VD_O_drw2d )	Comps[typCount++] = Comps[i] ;
		}
		else{

		  if( type & VD_O_drw3d )	Comps[typCount++] = Comps[i] ;
		}
	}

#ifdef	vdsDEBUG
	__DBGpr_com( "Found Objects ");
	for( i=0 ; i<typCount ; i++ )
		printf("\tObject\t:%d,%d\n", Comps[i].S_objid, Comps[i].osnum);
#endif
	if( ! typCount ){
		*msg = MSSUCC ;
		sts  = OM_S_SUCCESS ;
		goto wrapup ;
	}

	if( type & VD_O_drwVw ){
		/*
		 * Allocate memory for the output buffer.
		 */
		if ( ! name || strlen( name ) == 0 ){
		  if( grids ){
		    if( !( *grids = _MALLOC( typCount, struct GRid )))
			vd_$mem_fail();
		  }
		  else{
		    if( !( *objenvs = _MALLOC( typCount, struct GRobj_env )))
			vd_$mem_fail();
		  }

		  for( i=0 ; i<typCount ; i++ ){
		    if( grids ){(*grids)[i].objid	= Comps[i].S_objid ;
				(*grids)[i].osnum	= Comps[i].osnum ;
		    }
		    else{	(*objenvs)[i]._objid	= Comps[i].S_objid ;
				(*objenvs)[i]._osnum	= Comps[i].osnum ;
				(*objenvs)[i].mod_env	= *mdEnv ;
		    }
		  }
		  *number = typCount ;
		  *msg = MSSUCC ;
		  sts  = OM_S_SUCCESS ;
		  goto wrapup ;
		}

		if ( ! name || strlen( name ) == 0 ){
			*number = typCount ;
			*msg = MSSUCC ;
			sts  = OM_S_SUCCESS ;
			goto wrapup ;
		}
		else{
		  /*
		   * find the VDdrwXdVw object with this name.
		   */

		  attr.Iwant = VD_I_drwInternalName ;
		  for( i=0 ; i<typCount ; i++ ){

		    sts =
		    om$send(msg	  = message GRvg.GRgetattr( msg, (char *)&attr),
			    targetid= Comps[i].S_objid,
			    targetos= Comps[i].osnum,
			    senderid= Comps[i].S_objid );
		    __CheckRC( sts, *msg, "GRvg.GRgetattr", wrapup );

		    if( strcmp( name, attr.aString ) == 0 ){

		      *number = 1 ;

		      if( grids ){
		        if( !( *grids = _MALLOC( *number, struct GRid )))
		  	  vd_$mem_fail();

			(*grids)[0].objid	= Comps[i].S_objid ;
			(*grids)[0].osnum	= Comps[i].osnum ;
			*msg = MSSUCC ; sts = OM_S_SUCCESS ;
			goto wrapup ;
		      }
		      else{
		        if( !( *objenvs = _MALLOC( *number, struct GRobj_env )))
			  vd_$mem_fail();

		   	(*objenvs)[0]._objid	= Comps[i].S_objid ;
			(*objenvs)[0]._osnum	= Comps[i].osnum ;
			(*objenvs)[0].mod_env	= *mdEnv ;
			*msg = MSSUCC ; sts = OM_S_SUCCESS ;
			goto wrapup ;
		      }
		    }
		  } /* for ... finding name */
		}
		goto wrapup ;	/* Nothing found. */
	}

	/*
	 * See if need to find one of the connected objects.
	 */
	if( type & VD_O_drwObj || type & VD_O_drwPar ){

		/*
		 * Get the object connected to the object.
		 * A name need to ne given, A mask is optional.
		 */
		if( ! name || strlen( name ) == 0 ){
			*msg = OM_E_INVARG ;
			goto wrapup ;
		}

		attr.Iwant = VD_I_drwInternalName ;
		for( i=0 ; i<typCount ; i++ ){

		  sts =
		  om$send(msg	  = message GRvg.GRgetattr( msg,(char *)&attr),
			  targetid= Comps[i].S_objid,
			  targetos= Comps[i].osnum,
			  senderid= Comps[i].S_objid );
		  __CheckRC( sts, *msg, "GRvg.GRgetattr", wrapup );

		  if( strcmp( name, attr.aString ) == 0 ) break ;
		}

		if( i==typCount )	goto wrapup ;	/* Nothing found. */

		drwVw.objid	= Comps[i].S_objid ;
		drwVw.osnum	= Comps[i].osnum ;

		sts =
		VDdrw_GetChannelObjects(msg, &drwVw, mdEnv, type, &drwCount,
					grids, objenvs );
		__CheckRC( sts, *msg, "VDdrw_GetChannelObjects", wrapup );
	}

	/*
	 * See if we need to preselect the object depending on a given
	 * 'mask'. 
	 */
	if( mask ){
		
	    VDpartAttr		attr ;
	    IGRint		outCount = 0 ;

	    attr.Iwant = VD_I_drwChkStsMask ;
	    attr.aType = *mask ;

	    if( grids ){
	      for( i=0 ; i<drwCount ; i++ ){
		sts =
		_VD_SEND_OBJN(	(*grids)[i],
				GRvg.GRgetattr( msg, (char *)&attr ));
		if( !(sts&*msg&1)) continue ;
		(*grids)[outCount++] = (*grids)[i] ;
	      }
	    }
	    else{
	      for( i=0 ; i<drwCount ; i++ ){
		sts = 
		_VD_SEND_OBJN(	(*objenvs)[i]._grid,
				GRvg.GRgetattr( msg, (char *)&attr ));
		if( !(sts&*msg&1)) continue ;
		(*objenvs)[outCount++] = (*objenvs)[i] ;
	      }
	    }
	    drwCount = outCount ;

	    __DBGpr_int( "Object after Masks ", drwCount );
	}

	/*
	 * See if we need the parent objects from the visualization objects.
	 */
	if( type & VD_O_drwPar ){
		
	    VDpartAttr		attr ;
	    IGRint		outCount = 0 ;

	    attr.Iwant = VD_I_drwParentObj ;

	    if( grids ){
	      for( i=0 ; i<drwCount ; i++ ){
		sts =
		_VD_SEND_OBJN(	(*grids)[i],
				GRvg.GRgetattr( msg, (char *)&attr ));
		if( !(sts&*msg&1)) continue ;
		(*grids)[outCount++] = attr.obj._grid ;
	      }
	    }
	    else{
	      for( i=0 ; i<drwCount ; i++ ){
		sts = 
		_VD_SEND_OBJN(	(*objenvs)[i]._grid,
				GRvg.GRgetattr( msg, (char *)&attr ));
		if( !(sts&*msg&1)) continue ;
		(*objenvs)[outCount++] = attr.obj ;
	      }
	    }
	    drwCount = outCount ;

	    __DBGpr_int( " Objects after Masks", drwCount );
	}

	*number = drwCount ;
	*msg	= MSSUCC ;
	sts	= OM_S_SUCCESS ;

	wrapup:

		if( !(sts & *msg & 1 )){
			if( grids )	_FREE( *grids ); 
			if( objenvs )	_FREE( *objenvs );
			*number = 0 ;
		}
			
		_FREE( Comps );
		End ;
		return sts;
}

/* -------------------------------------------------------------------------- */

/*+fe
Function   VDdrwMgr_ConnectVw

Abstract
	This function connects a VDdrw2dVw/VDdrw3dVw object to the mananger
	object and does the initialization of the instance values.

Arguments
	OUT	IGRlong		*msg		return status
	IN	struct GRmd_env	*mdEnv		Module Environment
	IN	IGRint		type		Object Type (see vddrwattr.h)
	IN/OUT	struct GRid	*elmId		Object Identifiers.
	
Return status
	OM_S_SUCCESS	oke.
	OM_E_ABORT	otherwise.

History
	06/06/95	adz		creation date
-fe*/

long VDdrwMgr_ConnectVw( msg, mdEnv, type, elmId )

IGRlong		*msg;			/* return status             */
struct GRmd_env	*mdEnv;			/* Module Environment        */
IGRushort	type;			/* Object Type               */
struct GRid	*elmId;			/* Object Id.   	     */
	
{
	/*
	 * Construct an new object and connect it to the manager. Give the
	 * object and unique internal name.
	 */
	IGRint			sts = OM_S_SUCCESS,
				number;
	IGRlong			index, flag ;
	IGRchar			*pfxName ;
	GRname			VwName ;
	OMuword			classId ;
	struct	GRid		drwMgr ,
				*grids ;
	VDpartAttr		attr ;

	SetProc( VDdrwMgr_ConnectVw ); Begin

	*msg		= MSSUCC;
	grids		= NULL ;

	classId = ( type & VD_O_drw3d ) ? OPP_VDdrw3dVw_class_id 
					: OPP_VDdrw2dVw_class_id ;
	pfxName = ( type & VD_O_drw3d ) ? VD_S_drw3dVwName : VD_S_drw2dVwName ;

	elmId->osnum	= mdEnv->_MD_OS ;
	elmId->objid	= NULL_OBJID ;
	
	sts =
        om$construct(	classid = classId ,
                        osnum   = elmId->osnum,
                        p_objid = &(elmId->objid) );
	__CheckRC( sts, 1, "om_construct", wrapup );
	
	attr.Iwant	= VD_I_drwInitialization ;
	sts =
	_VD_SEND_OBJN( *elmId, GRvg.GRputattr( msg, (char *)&attr ));
	__CheckRC( sts, *msg, "GRvg.GRputattr", wrapup );

	/*
	 * Give the object an internal name.
	 */
	index	= 0 ;
	number	= 1 ;	/* to get into the loop */
	while( number ){
	  sprintf( VwName, "%s%d", pfxName, index++ );

	  __DBGpr_str( "Set Name ", VwName );

	  number = 0 ;
	  sts =
	  VDdrwMgrGetInfo( msg, mdEnv, type, VwName, 
				(IGRushort *) NULL, &number,
				&grids, (struct GRobj_env **) NULL);
	  __CheckRC( sts, *msg, "VDdrwMgrGetInfo", wrapup );
	  _FREE( grids );
	}

	/*
	 * Add name to the elmId 
	 */
	__DBGpr_str( "VwName ", VwName );
	
	attr.Iwant = VD_I_drwInternalName ;
	strcpy(	attr.aString , VwName );
	sts =
	_VD_SEND_OBJN( *elmId, GRvg.GRputattr( msg, (char *)&attr));
	__CheckRC( sts, *msg, "GRvg.GRgetattr", wrapup );

	/*
	 * Connect the object to the manager.
	 */
	sts = VD_drwConst_VDdrwMgrSuper( msg, &drwMgr );

	flag	= 1 ;
	index	= OM_K_MAXINT ;
	sts =
	_VD_SEND_OBJN(	*elmId,
			GRconnector.GRflexconn( msg, &flag, &drwMgr,
						&index, &index ));
	__CheckRC( sts, *msg, "GRconnector.GRflexconn", wrapup );

	wrapup :

		if( !(sts & *msg & 1 )){
		    if( elmId->objid != NULL_OBJID ){
			/*
			 * Delete object.
			 */
			sts =
			vd_$bulk_delete(	count	= 1,
						grids	= elmId,
						theEnv	= mdEnv );
		    }
		}
		
		_FREE( grids );
		End ;
		return sts ;
}

/* -------------------------------------------------------------------------- */

/*+fe
Function   VDdrwMgr_ConnectObjectsToVw

Abstract
	This function connects the VDdrw2d/VDdrw3d objects to the 
	VDdrw2dVw/VDdrw3dVw object mananger. When the manager is not
	defined, it will be generated.

Arguments
	OUT	IGRlong		*msg		return status
	IN	struct GRmd_env	*mdEnv		Module Environment
	IN	IGRint		type		Object Type (see vddrwattr.h)
	IN/OUT	struct GRid	*elmVw		Object Identifiers.
	INT	IGRint		count		Number of VDdrw2d/VDdrw3d objs
	IN	struct GRid	*grids		VDdrw2d/VDdrw3d objects
	
Return status
	OM_S_SUCCESS	oke.
	OM_E_ABORT	otherwise.

History
	06/06/95	adz		creation date
-fe*/

long VDdrwMgr_ConnectObjectsToVw ( msg, mdEnv, type, elmVw, count, grids )

IGRlong		*msg;			/* return status             */
struct GRmd_env	*mdEnv;			/* Module Environment        */
IGRushort	type;			/* Object Type               */
struct GRid	*elmVw;			/* Object Id.   	     */
IGRint		count;			/* Number of object to conn. */
struct	GRid	*grids;			/* List of objects.	     */
	
{
	/*
	 * Construct new objects and connect it to the manager. Give the
	 * object and unique internal name.
	 */
	IGRint			sts = OM_S_SUCCESS,
				i ;
	OMuword			classId ;
	OM_S_CHANSELECT		*to_drw, *to_set ;

	SetProc( VDdrwMgr_ConnectObjectsToVw ); Begin

	*msg	= MSSUCC;

	UI_status( "Connecting Object to Control Object" );
	UI_echo( "" );

	sts = VDdrw_GetToSetChannel( type, &to_set );
	sts = VDdrw_GetToDrwChannel( type, &to_drw );
	classId = ( type & VD_O_drw3d ) ? OPP_VDdrw3dVw_class_id 
					: OPP_VDdrw2dVw_class_id ;

	if( !(vd_$is_ancestry_valid(	object	= elmVw,
					classid = classId ))){
		/*
		 * Object is not an VDdrw2dVw/VDdrw3dVw object.
		 */

		IGRint	prop	= AChdr_nodisplay | AChdr_nocompute ;

		elmVw->objid = NULL_OBJID ;
		sts = VDdrwMgr_ConnectVw ( msg, mdEnv, type, elmVw );
		__CheckRC( sts, *msg, "VDdrwMgr_ConnectVw", wrapup );

                sts =
                VDdrw_ConstMacroVw( msg, type, elmVw, mdEnv, prop, 0, NULL );
                __CheckRC( sts, *msg, "VDdrw_ConstMacroVw", wrapup );
	}

	/*
	 * Connect the object to the View Area or View Volume object.
	 */
	for( i=0 ; i<count ; i++ ){
		
		sts =
		_VD_SEND_OBJN(	*elmVw,
				Root.connect(	*to_drw, 0, 
						grids[i].objid, grids[i].osnum,
						*to_set, 0 ));
		if( !(sts & 1)){
			/*
			 * Connect Failed. Delete the object.
			 */
			vd_$bulk_delete(count	= 1,
					theEnv	= mdEnv,
					grids	= grids +i );
		}
	}

	wrapup :
		End ;
		return sts ;
}

end implementation Root ;

