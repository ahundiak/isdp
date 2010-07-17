/*
	I/STRUCT
*/ 
class implementation VSbeamCS ;

#include "vsdbgmacros.h"
/*----------------------------------------------------------------------------*/
method	GRgetattr(	long	*msg ;
			char	*attr ) {

	VSbmCsPos	*ptr = (VSbmCsPos *) attr ;

	ptr->cardPt	= me->cardPnt ;
	ptr->endNo	= me->endNo ;

	*msg = MSSUCC ;
	return OM_S_SUCCESS ;

} /* method GRgetattr */
/*----------------------------------------------------------------------------*/

end implementation VSbeamCS ;

