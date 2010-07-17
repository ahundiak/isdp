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
 * Include for function prototypes.
 */
#include "vsshdatproto.h"

extern long	VSpackData() ;
/*----------------------------------------------------------------------------*/
method VSputData(	long		*msg ;
			int		count;
			VSdataDesc	list[] ) {

	long		sts ;			/* OM return code	*/
	char		*data 	= NULL ;
	unsigned	size ;
	VSdataLoc	*loc	= NULL ;

	sts = VSpackData( msg, count, list, &data, &loc, &size ) ;
	__CheckRC( sts, *msg, "VSpackData", wrapup );

	if( !(    om$vla_set_dimension(	varray	= me->loc,
					size	= count )
		& 1
		& om$vla_set_dimension(	varray	= me->data,
					size	= size ) ) ) vs$mem_fail() ;

	OM_BLOCK_MOVE( loc , me->loc , count * sizeof *loc  ) ;
	OM_BLOCK_MOVE( data, me->data, size  * sizeof *data ) ;

	*msg = MSSUCC ;

	wrapup :
		_FREE( data ) ; _FREE( loc ) ;
		return sts ;

} /* method VSputData */
/*----------------------------------------------------------------------------*/

end implementation VSsharedData ;
