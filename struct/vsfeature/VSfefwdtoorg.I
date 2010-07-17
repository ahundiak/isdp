/*
	I/STRUCT
*/
class implementation VSfeature ;

#include "vsdbgmacros.h"
/*----------------------------------------------------------------------------*/
method VSforwardToOriginal(	long			*msg ;
				enum OM_e_wrt_flag	deliver ;
				OM_p_MESSAGE		Message ) {

	long			sts,		/* OM return code	*/
				VSrc ;

	sts = om$send(	msg 	= message ACncpx.ACbubble_up(
					&VSrc,
					"",
					VS_K_ConsumedIx,
					message VSfeature.VSisOriginal(
							FALSE,
							VS_K_READ_OMmsg ),
					Message,
					deliver ),
			targetid= my_id ) ;

	*msg = sts & 1 ? MSSUCC : MSFAIL ;
	return sts ;

} /* method VSforwardToOriginal */
/*----------------------------------------------------------------------------*/

end implementation VSfeature ;

