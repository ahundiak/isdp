/*
	I/STRUCT
*/
class implementation VSfeature ;

#include "DIdef.h"
#include "DItypedef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "grerr.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
/*----------------------------------------------------------------------------*/
method GRgetname(	long	*msg ;
			GRname	name ) {

	long		sts ;		/* OM return code	*/

	/*
	 * If I am a name holder, get-name is for me, else I forward it up
	 * till a part can give a name.
	 */
	sts = om$send(	msg	= message VSpart.VSisNameHolder(
							VS_K_READ_OMmsg ),
			targetid= my_id ) ;

	if( sts != OM_I_STOP_SENDING ) {
		long		notUsed ;

		/*
		 * I do not store the name ...
		 */
		sts = om$send(	msg 	= message NDmacro.ACbubble_up(
						&notUsed,
						"",
						VS_K_ConsumedIx,
						message VSpart.VSisNameHolder(
							VS_K_READ_OMmsg ),
						OPPmargs,
						OM_e_wrt_object ),
				targetid= my_id ) ;
	} else {
		*name = '\0' ;
		sts = om$send(	msg 	= message ACncpx.GRgetname( msg, name ),
				mode	= OM_e_wrt_message,
				targetid= my_id ) ;

		if( !( sts & 1 & *msg ) ) {
			*name	= '\0' ;
			sts	= OM_S_SUCCESS ;
			*msg	= MSSUCC ;
		}
	}

	return sts ;

} /* method GRgetname */
/*----------------------------------------------------------------------------*/

end implementation VSfeature ;

