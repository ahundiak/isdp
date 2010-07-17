/*
	I/STRUCT
*/
class implementation VSfeature ;

#include "vsdbgmacros.h"
/*----------------------------------------------------------------------------*/
method VSchildDeleted(	long		*msg ;
			OM_S_OBJID	his_id ;
			OMuword		his_os ;
			struct GRmd_env	*his_env ; ) {

	*msg = MSSUCC ;
	return OM_S_SUCCESS ;

} /* method VSchildDeleted */
/*----------------------------------------------------------------------------*/

end implementation VSfeature ;

