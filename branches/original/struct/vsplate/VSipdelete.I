/*
	I/STRUCT
*/
class implementation VSimbPlate ;

#include "nddef.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
/*----------------------------------------------------------------------------*/
method NDdelete( struct GRmd_env *my_env ) {

	return om$send(	msg	= message VSfeature.VSdelete( my_env ),
			targetid= my_id ) ;

} /* method NDdelete */
/*----------------------------------------------------------------------------*/

end implementation VSimbPlate ;


