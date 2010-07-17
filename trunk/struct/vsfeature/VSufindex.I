/*
	I/STRUCT
*/
class implementation VSsubFeature ;

#include <stdio.h>
#include "OMerrordef.h"
#include "msdef.h"
#include "vsdbgmacros.h"
/*----------------------------------------------------------------------------*/
method VSsetIndex( long *msg ; int index ) {

	me->index = index ;
	*msg = MSSUCC ;
	return OM_S_SUCCESS ;

} /* method VSsetIndex */
/*----------------------------------------------------------------------------*/
method VSgetIndex( long *msg ; int *index ) {

	*index = me->index ;
	*msg = MSSUCC ;
	return OM_S_SUCCESS ;

} /* method VSgetIndex */
/*----------------------------------------------------------------------------*/

end implementation VSsubFeature ;


