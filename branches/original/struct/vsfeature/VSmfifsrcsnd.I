/*
	I/STRUCT
*/
class implementation VSmodFeature ;

#include "OMerrordef.h"
#include "msdef.h"
#include "vsdbgmacros.h"
/*----------------------------------------------------------------------------*/
method VSifSourceThenSend( int	OMmsgType ) {

	/*
	 * No, I'm not a source part :
	 */
	return OM_W_ABORT ;

} /* method VSifSourceThenSend */
/*----------------------------------------------------------------------------*/

end implementation VSmodFeature ;


