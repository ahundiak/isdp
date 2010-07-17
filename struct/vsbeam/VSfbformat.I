/*
	I/STRUCT
*/
class implementation VSfrzBeam ;

#include "OMmacros.h"
#include "nddef.h"
#include "asmacros.h"
#include "macro.h"
#include "vsRDBdef.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"

extern struct GRid	NULL_GRID ;
/*----------------------------------------------------------------------------*/
method VSformatUsingOriginal(	long			*msg ;
				struct GRmd_env		*myEnv ;
				struct GRobj_env	*original ) {

	long			sts ;
	int			ACrc,
				nbParents,
				index ;
	struct GRid		privAttr,
				userAttr,
				parents[2] ;
	struct ret_struct	attr ;

	/*
	 * Bind yourself to a new macro definition (we still point to that of
	 * the original).
	 */
	sts = om$send(	msg	= message ACcpx.ACattach( &ACrc, "VSfrzBeam" ),
			targetid= my_id ) ;
	if( !( sts & 1 & ACrc ) ) {
		*msg = MSFAIL ;
		goto wrapup ;
	}

	/*
	 * Get original's private data.
	 */
	sts = om$send(  msg     = message VSfeature.VSforwardToSource(
					msg,
					OM_e_wrt_object,
					message ACcpx.ACfind_temp_obj(
							&ACrc,
							VS_K_prPrvAttr,
							&privAttr ) ),
			targetid= original->_objid,
			targetos= original->_osnum ) ;

	if( !( sts & 1 & ACrc ) ) {
		*msg = MSFAIL ;
		goto wrapup ;
	}

	if( privAttr.osnum != OM_Gw_current_OS ) {
		struct GRmd_env	frEnv,
				toEnv ;
		struct GRid	UAinMyOS ;

		MAidmx( msg, frEnv._MATRIX ) ;
		frEnv._MATRIX_TYPE = MAIDMX ;
		frEnv._MD_OS = privAttr.osnum ;

		MAidmx( msg, toEnv._MATRIX ) ;
		toEnv._MATRIX_TYPE = MAIDMX ;
		toEnv._MD_OS = OM_Gw_current_OS ;
		
		sts = om$send(	msg	= message NDnode.NDcopy(msg,
								0,
								&frEnv,
								&toEnv,
								&UAinMyOS ),
				targetid= privAttr.objid,
				targetos= privAttr.osnum ) ;
		__CheckRC( sts, *msg, "NDnode.NDcopy", wrapup ) ;

		om$send(msg	= message NDnode.NDchg_state(	
						ND_WAIT_DEL | ND_DEL_NO_CH,
						ND_WAIT_DEL | ND_DEL_NO_CH ),
				targetid= UAinMyOS.objid,
				targetos= UAinMyOS.osnum ) ;

		privAttr = UAinMyOS ;
	}

	/*
	 * Get original's collection of user attributes, if any.
	 * Though this is a parent of the original, "ACreturn_foot" is the
	 * good message to send, since
	 * 1. It is understood by all types of beams (source/modified/sub)
	 * 2. User attributes are also viewed as a virtual output, ie. a sub-
	 *    collection of the beam.
	 */
	sts = om$send(  msg     = message NDmacro.ACreturn_foot(
						msg, VS_K_prUsrAttr,
						&userAttr, NULL, NULL ),
			targetid= original->_objid,
			targetos= original->_osnum ) ;
	if( !*msg ) userAttr.objid = NULL_OBJID ;

	if(    !IF_NULL_OBJID( userAttr.objid )
	    && userAttr.osnum != OM_Gw_current_OS ) {
		struct GRmd_env	frEnv,
				toEnv ;
		struct GRid	UAinMyOS ;

		MAidmx( msg, frEnv._MATRIX ) ;
		frEnv._MATRIX_TYPE = MAIDMX ;
		frEnv._MD_OS = userAttr.osnum ;

		MAidmx( msg, toEnv._MATRIX ) ;
		toEnv._MATRIX_TYPE = MAIDMX ;
		toEnv._MD_OS = OM_Gw_current_OS ;
		
		sts = om$send(	msg	= message NDnode.NDcopy(msg,
								0,
								&frEnv,
								&toEnv,
								&UAinMyOS ),
				targetid= userAttr.objid,
				targetos= userAttr.osnum ) ;
		__CheckRC( sts, *msg, "NDnode.NDcopy", wrapup ) ;

		om$send(msg	= message NDnode.NDchg_state(	
						ND_WAIT_DEL | ND_DEL_NO_CH,
						ND_WAIT_DEL | ND_DEL_NO_CH ),
				targetid= UAinMyOS.objid,
				targetos= UAinMyOS.osnum ) ;

		userAttr = UAinMyOS ;
	}

	parents[0] = privAttr ;
	if( IF_NULL_OBJID( userAttr.objid ) ) {
		nbParents = 1 ;
	} else {
		parents[1] = userAttr ;
		nbParents  = 2 ;
	}

	sts = om$send(	msg	= message NDnode.NDconnect(
						nbParents, parents,
						NULL_GRID, ND_NEW ),
			targetid= my_id ) ;
	if( !( sts & 1 ) ) {
		*msg = MSFAIL ; goto wrapup ;
	}

	/*
	 * Since we have no support curve (being frozen), we cannot compute
	 * the axis length or decide of our geometric type: let's get them
	 * from the original and store them in our instance data: we need them
	 * when we get checked in.
	 */
	sts = om$send(	msg	= message VSbeam.VSgetBeamLength(
						msg, &original->mod_env,
						&me->length ),
			targetid= original->_objid,
			targetos= original->_osnum ) ;
	if( !( sts & 1 & *msg ) ) me->length = 0 ; /* Oh, well ... */

	sts = om$send(	msg	= message NDmacro.ACgive_structure(
						&ACrc, &index,
						VS_K_prMbrGeoAttr,
						&attr, &original->mod_env ),
			targetid= original->_objid,
			targetos= original->_osnum ) ;
	if( !( sts & 1 & ACrc ) ) { *msg = MSFAIL ; }
	__CheckRC( sts, *msg, "NDmacro.ACgive_structure", wrapup ) ;

	*msg	= MSSUCC ;
	sts	= OM_S_SUCCESS ;

	wrapup :
		return sts ;

} /* method VSformatUsingOriginal */
/*----------------------------------------------------------------------------*/

end implementation VSfrzBeam ;
