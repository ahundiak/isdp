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
#include "vsdatamacros.h"
/*
 * Includes for function prototypes.
 */
#include "vsshdatproto.h"
/*----------------------------------------------------------------------------*/
method debug() {

	long		sts,
			msg ;
	VSdataDesc	*items = NULL ;
	int		count = om$dimension_of( varray = me->loc ),
			i ;

	printf( "*-* VSsharedData [%2d, %4d] :\n", OM_Gw_current_OS, my_id ) ;

	if( !count ) {
		printf( "Object is empty." ) ;
		sts = OM_S_SUCCESS ; goto wrapup ;
	}
	if( !( items = _MALLOC( count, VSdataDesc ) ) ) {
		printf( "Cannot allocate %d bytes\n", count * sizeof *items ) ;
		sts = OM_E_NODYNMEM ; goto wrapup ;
	}

	for( i = 0 ; i < count ; i++ ) items[i].index = i ;

	sts = om$send(	msg	= message VSsharedData.VSgetData(
							&msg, count, items ),
			targetid= my_id ) ;
	if( !( sts & 1 & msg ) ) {
		printf( "Cannot get object content\n" ) ; goto wrapup ;
	}

	VSdumpSharedData( count, items ) ;

	VSfreeData( count, items ) ;

	wrapup :
		_FREE( items ) ;
		printf( "*-*\n" ) ;
		return sts ;

} /* method debug */
/*----------------------------------------------------------------------------*/

end implementation VSsharedData ;

