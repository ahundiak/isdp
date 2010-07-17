/*
	I/STRUCT
*/ 
class implementation VSbeamCS ;

#include "OMmacros.h"
#include "EMSmsgdef.h"
#include "vsdbgmacros.h"
/*----------------------------------------------------------------------------*/
method	GRputattr(	long	*msg ;
			char	*attr ) {

	VSbmCsPos	*ptr = (VSbmCsPos *) attr ;

	/*
	 * Set instance data.
	 */
	me->cardPnt	= ptr->cardPt ;
	me->endNo	= ptr->endNo ;

	*msg = MSSUCC ;
	return OM_S_SUCCESS ;

} /* method GRputattr */
/*----------------------------------------------------------------------------*/

end implementation VSbeamCS ;

