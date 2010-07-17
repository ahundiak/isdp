/*
	I/STRUCT
*/ 
class implementation VSmodFeature ;

#include "vsdbgmacros.h"
/*----------------------------------------------------------------------------*/
method GRgetattr(	long	*msg ;
			char	*attr ) {

	long			sts,		/* OM return code	*/
				notUsed ;	/* Self-explanatory	*/

	/*
	 * Traverse the graph up through all the consumed parts.
	 */
	sts = om$send(	msg	= message VSfeature.VSforwardToSource(
					&notUsed, OM_e_wrt_object, OPPmargs ),
			targetid= my_id ) ;
	return sts ;

} /* method GRgetattr */
/*----------------------------------------------------------------------------*/

end implementation VSmodFeature ;

