/*
	I/STRUCT
*/
class implementation VSfrzPlate ;

#include "nddef.h"
#include "macro.h"
#include "EMSutlmacros.h"
#include "vsRDBdef.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "maidmx.h"

extern struct GRid	NULL_GRID ;
/*----------------------------------------------------------------------------*/
method VSformatUsingOriginal(	long			*msg ;
				struct GRmd_env		*myEnv ;
				struct GRobj_env	*original ) {

	long			sts ;
	int			ACrc,
				nbParents,
				count,
				map[2] ;
	struct GRid		privAttr,
				userAttr,
				parents[2],
				hisOutput ;
	GRname			cmpNames[2] ;

	/*
	 * Bind yourself to a new macro definition (we still point to that of
	 * the original).
	 */
	sts = om$send(	msg	= message ACcpx.ACattach( &ACrc, "VSfrzPlate" ),
			targetid= my_id ) ;
	if( !( sts & 1 & ACrc ) ) { *msg = MSFAIL ; goto wrapup ; }

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
	if( !( sts & 1 & ACrc ) ) { *msg = MSFAIL ; goto wrapup ; }

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
	 * 1. It is understood by all types of plates (source/modified/sub)
	 * 2. User attributes are also viewed as a virtual foot, ie. a sub-
	 *    collection of the plate.
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
	if( !( sts & 1 ) ) { *msg = MSFAIL ; goto wrapup ; }

	/*
	 * We have to store the mapping top/bottom which indicates us
	 * which is the top and bottom surface since we have not support surface
	 * to help us find it.
	 */
	sts = om$send(	msg	= message NDmacro.ACreturn_foot(
						msg, VS_K_plGrCmpName, &hisOutput,
						NULL, NULL ),
			targetid= original->_objid,
			targetos= original->_osnum ) ;
	*msg = *msg ? MSSUCC : MSFAIL ;
	__CheckRC( sts, *msg, "NDmacro.ACreturn_foot", wrapup ) ;

	/*
	 * Note: the following call will fail if plate is in 2D, since
	 * foot will be a component but not an owner, but it does not matter
	 * since in this case we will not need the mapping...
	 */
	{ OM_S_CHANSELECT toCmps ;
	  ems$make_chanselect( chan_label    = GRcmpowner_to_components,
	  		       chan_selector = &toCmps ) ;

	  sts = om$get_channel_count(	p_chanselect	= &toCmps,
					objid		= hisOutput.objid,
					osnum		= hisOutput.osnum,
					count		= (OMuint *) &count ) ;
	}
	if( !( sts & 1 ) ) { sts = OM_S_SUCCESS ; *msg = MSSUCC ; goto wrapup ; }

	sts = om$send( msg	= message VSplate.VStopBottomMapping(
						msg, count, map, cmpNames ),
			targetid= original->_objid,
			targetos= original->_osnum ) ;
	__CheckRC( sts, *msg, "VSplate.VStopBottomMapping", wrapup ) ;

	me->map[0] = map[0] ; me->map[1] = map[1] ; 

	*msg	= MSSUCC ;
	sts	= OM_S_SUCCESS ;

	wrapup :
		return sts ;

} /* method VSformatUsingOriginal */
/*----------------------------------------------------------------------------*/

end implementation VSfrzPlate ;
