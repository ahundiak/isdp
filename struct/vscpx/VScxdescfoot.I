/*
	I/STRUCT
*/
class implementation VScpx ;

#include <string.h>
/*----------------------------------------------------------------------------*/
method VSdescribeOutput( long *msg ; char *nameOfOutput, *description ) {

	strcpy( description, nameOfOutput ) ;
	*msg = MSSUCC ;
	return OM_S_SUCCESS ;

} /* method VSdescribeOutput */
/*----------------------------------------------------------------------------*/

end implementation VScpx ;
