/*
	I/STRUCT
*/
class implementation VSfeature ;

#include "grownerdef.h"
/*----------------------------------------------------------------------------*/
method GRget_locate_properties( long *msg ; int *properties ) {

	long	sts,
		consumed ;

	sts = om$send(	msg	= message ACncpx.GRget_locate_properties(
							msg, properties ),
			mode	= OM_e_wrt_message,
			targetid= my_id ) ;

	om$send(	msg	= message NDmacro.ACtest_consumed( &consumed ),
			targetid= my_id ) ;

	if( consumed & 1 ) {
		*properties &= ~ ( GR_LC_OWN_WRITE | GR_LC_CMP_PRM_WRITE ) ;
	}

	return sts ;

} /* method GRget_locate_properties */
/*----------------------------------------------------------------------------*/

end implementation VSfeature ;

