/*
	I/STRUCT
*/
class implementation VSsubFeature ;

#include <stdio.h>
#include "OMerrordef.h"
#include "msdef.h"
#include "vsdbgmacros.h"
/*----------------------------------------------------------------------------*/
method VSisNameHolder(	int OMmsgType ) {

	long		sts, 		/* OM return code	*/
			msg ;		/* Completion code	*/
	int		myIndex ;

	om$send(msg	= message VSsubFeature.VSgetIndex( &msg, &myIndex ),
		targetid= my_id ) ;

	sts = myIndex != 0 ? OM_I_STOP_SENDING : OM_W_ABORT ;

	return sts ;

} /* method VSisNameHolder */
/*----------------------------------------------------------------------------*/

end implementation VSsubFeature ;


