/*
	I/STRUCT
*/ 
class implementation VSmodFeature ;

#include "nddef.h"
#include "vsdbgmacros.h"

extern IGRboolean dynamics_in_progress ;
/*----------------------------------------------------------------------------*/
method NDcopy(	long		*msg ;
		int		cp_type ;
                struct GRmd_env	*fr_env,
                		*to_env ;
                struct GRid	*newobjid ) {

	long sts ;

	if( dynamics_in_progress ) {
		*msg	= MSSUCC ;
		sts	= OM_S_SUCCESS ;
		newobjid->objid = NULL_OBJID ;
 	} else {

		sts = om$send(	mode     = OM_e_wrt_message,
				msg      = message VSfeature.NDcopy(
							msg, cp_type, fr_env,
							to_env, newobjid ),
				targetid = my_id ) ;
	}

	return sts ;

} /* method NDcopy */
/*----------------------------------------------------------------------------*/

end implementation VSmodFeature ;
