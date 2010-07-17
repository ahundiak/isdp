/*
	I/STRUCT
*/
class implementation VSmodFeature ;

#include "vsdbgmacros.h"
/*----------------------------------------------------------------------------*/
method GRputattr(	long	*msg ;
			char	*attr ) {

	long			sts,		/* OM return code	*/
				notUsed ;	/* Self-explanatory	*/

	if( attr ) {
		/*
		 * Traverse the graph up through all the consumed parts.
		 */
		sts = om$send(	msg	= message VSfeature.VSforwardToSource(
					&notUsed, OM_e_wrt_object, OPPmargs ),
				targetid= my_id ) ;
	} else {
		*msg	= MSSUCC ;
		sts	= OM_S_SUCCESS ;
	}

	return sts ;

} /* method GRputattr */
/*----------------------------------------------------------------------------*/

end implementation VSmodFeature ;

