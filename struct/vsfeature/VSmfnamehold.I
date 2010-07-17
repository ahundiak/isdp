/*
	I/STRUCT
*/
class implementation VSmodFeature ;

#include <stdio.h>
#include "OMerrordef.h"
#include "msdef.h"
#include "vsdbgmacros.h"
/*----------------------------------------------------------------------------*/
method VSisNameHolder( int OMmsgType ) {

	/*
	 * I'm not a source part hence not a name holder.
	 */
	return OM_W_ABORT ;

} /* method VSisNameHolder */
/*----------------------------------------------------------------------------*/

end implementation VSmodFeature ;


