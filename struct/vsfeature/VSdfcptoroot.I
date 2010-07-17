/*
	I/STRUCT
*/
class implementation VSdivFeature ;

#include "nddef.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
/*----------------------------------------------------------------------------*/
method NDcopy_to_root(	long		*msg ;
			int		cp_type ;
			struct GRmd_env	*myEnv,
					*rootEnv ;
			struct GRid	*rootId ; ) {

	return om$send(	msg	= message VSfeature.VScopy_to_root(
								msg,
								cp_type,
								myEnv,
								rootEnv,
								rootId ),
			targetid= my_id ) ;

} /* method NDcopy_to_root */
/*----------------------------------------------------------------------------*/

end implementation VSdivFeature ;
