/*
	I/STRUCT
*/
class implementation VSdpb ;

#include "OMerrordef.h"
#include "OMmacros.h"
/*----------------------------------------------------------------------------*/
method have_beam_data( int *loaded ) {

	*loaded = om$dimension_of( varray = me->B_type ) != 0 ;
	return OM_S_SUCCESS ;

} /* method have_beam_data */
/*----------------------------------------------------------------------------*/
method have_plate_data( int *loaded ) {

	*loaded = om$dimension_of( varray = me->P_type ) != 0 ;
	return OM_S_SUCCESS ;

} /* method have_plate_data */
/*----------------------------------------------------------------------------*/

end implementation VSdpb ;

