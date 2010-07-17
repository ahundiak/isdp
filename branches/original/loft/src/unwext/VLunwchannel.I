/* $Id: VLunwchannel.I,v 1.2 2001/02/20 01:07:37 build Exp $  */

/*************************************************************************
 * I/LOFT
 *
 * File:        src/unwext/VLunwchannel.I
 *
 * Description: Simple functions to get objects on channels.
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VLunwchannel.I,v $
 *      Revision 1.2  2001/02/20 01:07:37  build
 *      Replaced v_dbgmacros.h with product specific dbgmacros.h
 *
 *      Revision 1.1.1.1  2001/01/04 21:11:47  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:32:50  pinnacle
# LOFT 2.5.1
#
# Revision 1.1  1997/10/28  15:30:36  pinnacle
# Created: src/unwext/VLunwchannel.I by rchennup for loft
#
 *
 * History:
 *      MM/DD/YY   AUTHOR       DESCRIPTION
 *      10/28/97   Rama Rao     File Creation
 *************************************************************************/

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
#include "vdsmacros.h"
#include "vldbgmacros.h"

#define vdsDEBUG    1
#define vdserrDEBUG 1

/*----------------------------------------------------------------------------*/

long VLunw_GetOneChannelObject( msg, elmId, mdEnv, grids, objenvs )

IGRlong			*msg ;
struct	GRid		*elmId ;
struct	GRmd_env	*mdEnv ;
struct	GRid		*grids ;
struct	GRobj_env	*objenvs ; {

	/*
	 * Find the object connected to elmId. 
	 */

	IGRint			sts = OM_S_SUCCESS ;
	OMuint			cnt ;
	struct	GRid		tmpObj ;
	OM_S_CHANSELECT         to_feat ;

	SetProc( VLunw_GetOneChannelObjects ); Begin

	__DBGpr_obj( " Object To Check ", *elmId );

	*msg	= MSSUCC ;

	/*
	 * find the list of all the VLunwFeat object which are
	 * connect to this VLunwObj object.
	 */
        to_feat.type       = OM_e_name;
        to_feat.u_sel.name = "VLunwObj.to_feat";

	cnt = 0 ;
	sts =
	om$get_channel_count(	objid		= elmId->objid,
				osnum		= elmId->osnum,
				p_chanselect	= &to_feat,
				count		= &cnt );

	__DBGpr_int("  Object Found ", cnt );

	if( cnt && (sts&1) ){
	
	  cnt = 0 ;
	  sts =
	  om$get_objid_at_index(objid		= elmId->objid,
				osnum		= elmId->osnum,
				p_chanselect	= &to_feat,
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

long VLunw_GetChannelObjects( msg, elmId, mdEnv, count, grids, objenvs )

IGRlong			*msg ;
struct	GRid		*elmId ;
struct	GRmd_env	*mdEnv ;
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
	OM_S_CHANSELECT         to_feat ;
	GRobjlink		*List ;

	SetProc( VLunw_GetChannelObjects ); Begin

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
        to_feat.type       = OM_e_name;
        to_feat.u_sel.name = "VLunwObj.to_feat";

	cnt = 0 ;
	sts =
	om$get_channel_count(	objid		= elmId->objid,
				osnum		= elmId->osnum,
				p_chanselect	= &to_feat,
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
				p_chanselect	= &to_feat,
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

end implementation VDSroot;
 

