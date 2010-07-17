/*
	I/STRUCT
 */
class implementation VSdivFeature ;

#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
/*----------------------------------------------------------------------------*/
method VSgetSubMask(	long		*msg ;
			unsigned int	*mask ;
			int		*count,
					*max ) {

	int i ;

	*msg = MSSUCC ;
	*mask = me->subMask ;
	/*
	 * We here force `*max' to 2.
	 */
	*max = 2 ;

	for( *count = i = 0 ; i < *max ; i++ ) {
		if( *mask & ( 1 << i ) ) (*count)++ ;
	}

	return OM_S_SUCCESS ;

} /* method VSgetSubMask */
/*----------------------------------------------------------------------------*/
method VSsetSubMask(	long		*msg ;
			int		action ;
			unsigned int	mask ) {

	long	sts ;

	*msg	= MSSUCC ;
	sts	= OM_S_SUCCESS ;

	switch( action ) {
		case VS_K_ADD_BITS : me->subMask |=  mask ; break ;
		case VS_K_REM_BITS : me->subMask &= ~mask ; break ;
		case VS_K_SET_BITS : me->subMask  =  mask ; break ;
		case VS_K_SET_ALL  : me->subMask  = 0xff  ; break ;
		default		   : *msg = MSINARG ;
				     sts  = OM_W_ABORT	  ; break ;
	}
	return sts ;

} /* method VSsetSubMask */
/*----------------------------------------------------------------------------*/

end implementation VSdivFeature ;
