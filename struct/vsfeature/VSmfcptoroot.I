/*
	I/STRUCT
*/
class implementation VSmodFeature ;

#include "nddef.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
/*----------------------------------------------------------------------------*/
method NDcopy_to_root(	long		*msg ;
			int		cp_type ;
			struct GRmd_env	*myEnv,
					*rootEnv ;
			struct GRid	*rootId ; ) {

	long		sts ;

	if( ( cp_type & ND_TO_MACRO ) || ( cp_type & ND_FROM_MACRO ) ) {
		/*
		 * Copying to or from macro definition.
		 */
		sts = om$send(	msg	= message VSfeature.VScopy_to_root(
								msg,
								cp_type,
								myEnv,
								rootEnv,
								rootId ),
				targetid= my_id ) ;
	} else {
		/*
		 * Return a frozen copy of yourself.
		 */
		sts = om$send(	msg	= message VSfeature.VScreateFrozenCopy(
						msg, myEnv, rootEnv, rootId ),
				targetid= my_id ) ;
	}
	return sts ;

} /* method NDcopy_to_root */
/*----------------------------------------------------------------------------*/

end implementation VSmodFeature ;
