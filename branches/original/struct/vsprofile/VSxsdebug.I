/*
	I/STRUCT
*/
class implementation VSxscurve ;

#include "OMmacros.h"
/*----------------------------------------------------------------------------*/
method debug() {

	long	msg ;
	int	i, size ;
	GRname	cmpNm ;

	printf( "\n* - * Dump of cross-section curve OD = %d Id = %d\n",
		OM_Gw_current_OS, my_id ) ;

	size = om$dimension_of( varray = me->cmpToUsr ) ;

	printf( "\tSize of mapping array: %d\n", size ) ;

	for( i = 0 ; i < size ; i++ ) {
		VStransFaceNumberToNm( &msg, me->cmpToUsr[i], cmpNm ) ;
		printf( "\tName index of curve #%2d : <%s>\n",
			i, cmpNm ) ;
	}
	printf( "\n* - * End dump\n\n" ) ;

	return OM_S_SUCCESS ;

} /* method debug */
/*----------------------------------------------------------------------------*/

end implementation VSxscurve ;

