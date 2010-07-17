/*
	I/STRUCT
*/
class implementation VScompcurve ;

#include "OMmacros.h"
/*----------------------------------------------------------------------------*/
method debug() {

	int	i, size ;

	printf( "\n* - * Dump of composite curve OD = %d Id = %d\n",
		OM_Gw_current_OS, my_id ) ;

	size = om$dimension_of( varray = me->cmpToUsr ) ;

	printf( "\tSize of mapping array: %d\n", size ) ;

	for( i = 0 ; i < size ; i++ ) {
		printf( "\tUser index of curve #%2d : %2d\n",
			i, me->cmpToUsr[i] ) ;
	}
	printf( "\n* - * End dump\n\n" ) ;

	return OM_S_SUCCESS ;

} /* method debug */
/*----------------------------------------------------------------------------*/

end implementation VScompcurve ;

