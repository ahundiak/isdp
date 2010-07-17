/*
	I/STRUCT
*/
class implementation VSfeature ;

#include "nddef.h"
#include "exmacros.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
/*----------------------------------------------------------------------------*/
method VSgetConsumedParent(	long		*msg ;
				struct GRid	*consumedId ;
				struct GRmd_env	*consumedEnv ) {

	
	long		sts ;		/* OM return code	*/
	int		count ;		/* Parent count 	*/
	struct GRid	parent ;

	*msg = MSFAIL ;
	consumedId->objid = NULL_OBJID ;

	sts = om$send(	msg	= message NDnode.NDget_objects(	ND_ROOT,
								&parent,
								1,
								NULL,
						/* from = */	VS_K_ConsumedIx,
						/* to   = */	VS_K_ConsumedIx,
								&count ),
			targetid= my_id ) ;	
	__CheckRC( sts, 1, "NDnode.NDget_object", wrapup ) ;

	if( count ) {
		struct GRmd_env	buffer ;
		long		isConsumed ;

		sts = om$send(	msg	= message NDmacro.ACtest_consumed(
								&isConsumed ),
				targetid= parent.objid,
				targetos= parent.osnum ) ;
		if( !( isConsumed & 1 ) ) {
			sts = OM_S_SUCCESS ; *msg = MSSUCC ; goto wrapup ;
		}
		if( !consumedEnv ) consumedEnv = &buffer ;

		sts = om$send(	msg	= message NDmacro.ACreturn_foot(
						msg,
						"",
						consumedId,
						&consumedEnv->_MATRIX_TYPE,
						consumedEnv->_MATRIX ),
				targetid= parent.objid,
				targetos= parent.osnum ) ;
		*msg = *msg ? MSSUCC : MSFAIL ;

		consumedEnv->_MD_OS = consumedId->osnum ;
		ex$get_modid(	mod_osnum	= consumedEnv->_MD_OS,
				mod_id		= &consumedEnv->_MD_ID ) ;
	} else {
		sts = OM_E_INVARG ; *msg = MSINARG ;
	}

	wrapup :
		return sts ;
	
} /* method VSgetConsumedParent */
/*----------------------------------------------------------------------------*/

end implementation VSfeature ;

