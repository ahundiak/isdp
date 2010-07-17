/*
	I/STRUCT
*/
class implementation VSsharedData ;

#include <stdlib.h>
#include "msdef.h"
#include "OMmacros.h"
#include "EMSmsgdef.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
/*----------------------------------------------------------------------------*/
method VSgetMemoryContent(	long		*msg ;
				int		*size;
				char		**content ) {

	long		sts ;	/* OM return code	*/

	*msg	= MSSUCC ;
	sts	= OM_S_SUCCESS ;

	*content = NULL ;
	if( *size = om$dimension_of( varray = me->data ) ) {

		if( *content = _MALLOC( *size, char ) ) {
			OM_BLOCK_MOVE( me->data, *content, *size ) ;
		} else {
			*msg	= EMS_E_NoDynamicMemory ;
			sts	= OM_E_NODYNMEM ;
		}
	}

	return sts ;

} /* method VSgetMemoryContent */
/*----------------------------------------------------------------------------*/

end implementation VSsharedData ;

