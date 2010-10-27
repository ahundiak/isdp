/* $Id: VDdrwchannel.I,v 1.1.1.1 2001/01/04 21:08:38 cvs Exp $ */
/*---------------------------------------------------------------------------
/*  I/VDS
 *
 * File:        vddraw/imp/VDdrwchannel.I
 *
 * Description:
 *
 *      This file implements the support functions for the visulization
 *	objects.
 *
 * Dependencies:
 *  	None.
 *
 * History:
 *      06/06/94        adz		Creation date.
 *	09/17/95	adz		Add check routine.
 *
 * -------------------------------------------------------------------------
 */

class implementation VDSroot;

%safe
#include <math.h>
%endsafe

#include <stdio.h>
#include <string.h>
#include "OMmacros.h"
#include "OMprimitives.h"
#include "OMerrordef.h"
#include "msdef.h"
#include "madef.h"

#include "dp.h"
#include "grerr.h"
#include "grgsdef.h"
#include "EMSmsgdef.h"

#include "vds.h"
#include "vddrwattr.h"
#include "VDmsg.h"
#include "vddrwattr.h"
#include "v_miscmacros.h"
#include "v_datamacros.h"
#include "v_dbgmacros.h"
#include "vdsmacros.h"

/*
 * TO GAIN SPEED WE ONLY HAVE ONE DEFINED CHANNEL BETWEEN EACH OF THE
 * OBJECTS; OTHER OCCURENCE WILL TAKE THE ADDRESS AND USE THIS.
 */

%safe
static	IGRint			VDdrw_S_channel	= 0 ;
static	OM_S_CHANSELECT		VDdrw_S_to_drw2d,
				VDdrw_S_to_drw3d,
				VDdrw_S_to_set2d,
				VDdrw_S_to_set3d;
%endsafe

/*----------------------------------------------------------------------------*/

long VDdrw_GenerateChannels( )
{
	/*
	 * Generate the static channels to be used.
	 */
	IGRint		sts = OM_S_SUCCESS ;

	SetProc( VDdrw_GenerateChannels ); Begin

	sts =
	om$make_chanselect(	channame	= "VDdrw3dVw.to_3d",
				p_chanselect	= &VDdrw_S_to_drw3d );
	__CheckRC( sts, 1, "make_chanselect_1", wrapup );

	sts =
	om$make_chanselect(	channame	= "VDdrw2dVw.to_2d",
				p_chanselect	= &VDdrw_S_to_drw2d );
	__CheckRC( sts, 1, "make_chanselect_2", wrapup );

	sts =
	om$make_chanselect(	channame	= "VDdrw3d.to_set3",
				p_chanselect	= &VDdrw_S_to_set3d );
	__CheckRC( sts, 1, "make_chanselect_3", wrapup );

	sts =
	om$make_chanselect(	channame	= "VDdrw2d.to_set2",
				p_chanselect	= &VDdrw_S_to_set2d );
	__CheckRC( sts, 1, "make_chanselect_4", wrapup );

	VDdrw_S_channel = 1 ;

	wrapup :
		End ;
		return sts ;
}

/*----------------------------------------------------------------------------*/

long VDdrw_GetToDrwChannel( type, to_drw )

IGRushort		type ;
OM_S_CHANSELECT		**to_drw ;
{
	/*
	 * find the list of all the VDdrw2d/VDdrw3d object which are
	 * connect to this Volume Control object.
	 */
	IGRint		sts = OM_S_SUCCESS ;

	if( ! VDdrw_S_channel ){ sts = VDdrw_GenerateChannels(); }

	*to_drw = ( type & VD_O_drw3d ) ? &VDdrw_S_to_drw3d
					: &VDdrw_S_to_drw2d ;
	return sts ;
}

/*----------------------------------------------------------------------------*/

long VDdrw_GetToSetChannel( type, to_set )

IGRushort		type ;
OM_S_CHANSELECT		**to_set ;
{
	/*
	 * find the list of all the VDdrw2d/VDdrw3d object which are
	 * connect to this Volume Control object.
	 */
	IGRint		sts = OM_S_SUCCESS ;

	if( ! VDdrw_S_channel ){ sts = VDdrw_GenerateChannels(); }

	*to_set = ( type & VD_O_drw3d ) ? &VDdrw_S_to_set3d
					: &VDdrw_S_to_set2d ;
	return sts ;
}

/*----------------------------------------------------------------------------*/

long VDdrw_GetOneChannelObject( msg, elmId, mdEnv, type, grids, objenvs )

IGRlong			*msg ;
struct	GRid		*elmId ;
struct	GRmd_env	*mdEnv ;
IGRushort		type ;
struct	GRid		*grids ;
struct	GRobj_env	*objenvs ; {

	/*
	 * Find the object connected to elmId. 
	 */

	IGRint			sts = OM_S_SUCCESS ;
	OMuint			cnt ;
	struct	GRid		tmpObj ;
	OM_S_CHANSELECT         *to_drw ;

	SetProc( VDdrw_GetOneChannelObjects ); Begin

	__DBGpr_obj( " Object To Check ", *elmId );

	*msg	= MSSUCC ;

	/*
	 * find the list of all the VDdrw2d/VDdrw3d object which are
	 * connect to this Volume Control object.
	 */
	sts = VDdrw_GetToDrwChannel( type, &to_drw );

	cnt = 0 ;
	sts =
	om$get_channel_count(	objid		= elmId->objid,
				osnum		= elmId->osnum,
				p_chanselect	= to_drw,
				count		= &cnt );

	__DBGpr_int("  Object Found ", cnt );

	if( cnt && (sts&1) ){
	
	  cnt = 0 ;
	  sts =
	  om$get_objid_at_index(objid		= elmId->objid,
				osnum		= elmId->osnum,
				p_chanselect	= to_drw,
				index		= cnt,
				objidaddr	= &tmpObj.objid,
				osnumaddr	= &tmpObj.osnum );

	  if( grids ){	grids->objid	= tmpObj.objid ;
			grids->osnum	= tmpObj.osnum ;
	  }
	  else{		objenvs->_objid	= tmpObj.objid ;
			objenvs->_osnum	= tmpObj.osnum ;
			objenvs->mod_env= *mdEnv ;
	  }

	  __DBGpr_obj(" Found ", tmpObj );
	}
	else{
		*msg = MSFAIL ;
		goto wrapup ;
	}

	wrapup :
		End ;
		return	sts ;
}

/*----------------------------------------------------------------------------*/

long VDdrw_GetChannelObjects( msg, elmId, mdEnv, type, count, grids, objenvs )

IGRlong			*msg ;
struct	GRid		*elmId ;
struct	GRmd_env	*mdEnv ;
IGRushort		type ;
IGRint			*count ;
struct	GRid		**grids ;
struct	GRobj_env	**objenvs ; {

	/*
	 * Find the object connected to elmId. Allocate the needed memory
	 * and return list back to the user.
	 */
	IGRint			sts = OM_S_SUCCESS,
				i ;
	OMuint			cnt ;
	OM_S_CHANSELECT         *to_drw ;
	GRobjlink		*List ;

	SetProc( VDdrw_GetChannelObjects ); Begin

	__DBGpr_obj( " Object To Check ", *elmId );

	*msg	= MSSUCC ;
	*count	= 0 ;
	List	= NULL ;

	if( grids )	*grids	= NULL ;
	if( objenvs ){	*objenvs = NULL ;
		if( ! mdEnv ){
			*msg = MSFAIL ;
			goto wrapup ;
		}
	}

	/*
	 * find the list of all the VDdrw2d/VDdrw3d object which are
	 * connect to this Volume Control object.
	 */
	sts = VDdrw_GetToDrwChannel( type, &to_drw );

	cnt = 0 ;
	sts =
	om$get_channel_count(	objid		= elmId->objid,
				osnum		= elmId->osnum,
				p_chanselect	= to_drw,
				count		= &cnt );

	if( cnt && (sts&1) ){
	
	  __DBGpr_int("  Object Found ", cnt );

	  if( !( List = _MALLOC( cnt, GRobjlink ))){
		goto wrapup;
	  }
	
	  if( grids ){
	    if( !( *grids = _MALLOC( cnt, struct GRid )))
		vd_$mem_fail();
	  }
	  else{
	    if( !( *objenvs = _MALLOC( cnt, struct GRobj_env )))
		vd_$mem_fail();
	  }
	
	  sts =
	  om$get_channel_objects(objid		= elmId->objid,
				osnum		= elmId->osnum,
				p_chanselect	= to_drw,
				size		= cnt,
				list		= List,
				count		= &cnt );

	
	  for( i=0 ; i<cnt; i++ ){

	    if( grids ){	(*grids)[i].objid	= List[i].S_objid ;
				(*grids)[i].osnum	= List[i].osnum ;
	    }
	    else{		(*objenvs)[i]._objid	= List[i].S_objid ;
				(*objenvs)[i]._osnum	= List[i].osnum ;
				(*objenvs)[i].mod_env	= *mdEnv ;
	    }
	  }

	  *count = (IGRint) cnt ;
	}


	wrapup :
		if( !(sts & *msg & 1 )){
		  if( grids )  { _FREE( *grids );	*grids = NULL ; }
		  if( objenvs ){ _FREE( *objenvs );	*objenvs = NULL ; }
		  *count = 0 ;
		}

		_FREE( List );
		End ;
		return	sts ;
}

/*----------------------------------------------------------------------------*/

long	VDdrw_GetChannelOwner(	msg, elmId, type, ownId )

IGRlong			*msg ;
struct	GRid		*elmId ;
IGRushort		type ;
struct	GRid		*ownId ; {

	/*
	 * Get the owner object of VDdrw2d/VDdrw3d.
	 */
	IGRint			sts = OM_S_SUCCESS,
				count ;
        OM_S_CHANSELECT         *to_set ;
        GRobjlink		drwVw ;

	SetProc( VDdrw_GetChannelOwner ); Begin

	*msg = MSSUCC ;

	sts = VDdrw_GetToSetChannel( type, &to_set );

        sts =
        om$get_channel_objects( objid           = elmId->objid,
				osnum		= elmId->osnum,
                                p_chanselect    = to_set,
                                size            = 1,
                                list            = &drwVw,
                                count           = (OMuint *)&count );

	if( count != 1 ){
		*msg = MSFAIL ;
		goto wrapup ;
	}

	if( ownId ){
		ownId->objid	= drwVw.S_objid ;
		ownId->osnum	= drwVw.osnum ;

		__DBGpr_obj(" Owner ", *ownId );
	}

	wrapup :

		End ;
		return sts ;
}

/*----------------------------------------------------------------------------*/

end implementation VDSroot;
 

