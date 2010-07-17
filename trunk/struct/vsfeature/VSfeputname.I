/*
	I/STRUCT

Abstract
	Names a part.
Arguments
	OUT	long	*msg	Completion code.
	IN	GRname	name	name for part.
Note
	If `name' is NULL or `*name' is '\0', this method does nothing
	and completes with success.

*/
class implementation VSfeature ;

#include "DIdef.h"
#include "DItypedef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "DImacros.h"
#include "grerr.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
/*----------------------------------------------------------------------------*/
method GRputname(	long	*msg ;
			GRname	name ) {

	long		sts ;		/* OM/DI return code	*/

	/*
	 * If I am a name holder, put-name is for me, else I forward it up
	 * till a part can carry it.
	 */
	sts = om$send(	msg	= message VSpart.VSisNameHolder(
							VS_K_READ_OMmsg ),
			targetid= my_id ) ;

	if( sts == OM_E_ABORT ) {
		/*
		 * Not allowed to set name
		 */
		sts  = OM_S_SUCCESS ;
		*msg = GR_E_INV_REQUEST ;

	} else 	if( sts != OM_I_STOP_SENDING ) {
		/*
		 * I cannot store the name ...
		 */
		long		notUsed ;

		sts = om$send(	msg 	= message NDmacro.ACbubble_up(
						&notUsed,
						"",
						VS_K_ConsumedIx,
						message VSpart.VSisNameHolder(
							VS_K_WRITE_OMmsg ),
						OPPmargs,
						OM_e_wrt_object ),
				targetid= my_id ) ;

	} else if( !( name && *name ) ) {
		*msg	= MSSUCC ;
		sts	= OM_S_SUCCESS ;
	} else {
		/*
		 * I can store the name.
		 */
		sts = om$send(	msg	= message ACncpx.GRputname( msg, name ),
				mode	= OM_e_wrt_message,
				targetid= my_id ) ;
	}

	return sts ;

} /* method GRputname */
/*----------------------------------------------------------------------------*/

end implementation VSfeature ;

