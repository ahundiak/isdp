/*
	I/STRUCT
*/
class implementation VScompcurve ;

#include <limits.h>
#include <stdlib.h>
#include "OMmacros.h"
#include "msdef.h"
#include "EMSmsgdef.h"
#include "vsdatadef.h"
#include "vsdatamacros.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
/*----------------------------------------------------------------------------*/
method VSgetMapping( long *msg ; int *size, **usrIndices ) {

	long	sts ;	/* OM return code	*/
	int	i,	/* Loop index		*/
		sz ;

	SetProc( VScompcurve_VSgetMapping ) ; Begin ; __DBGpr_me() ;


	*size		= 0 ;
	*usrIndices	= NULL ;

	sz = om$dimension_of( varray = me->cmpToUsr ) ;

	if( sz ) {
		if( !( *usrIndices = _MALLOC( sz, int ) ) ) vs$mem_fail() ;

		for( i = 0 ; i < sz ; i++ ) {
			(*usrIndices)[i] = me->cmpToUsr[i] ;
		}
		*size = sz ; sts = OM_S_SUCCESS ; *msg = MSSUCC ;
	} else {
		sts = OM_W_ABORT ; *msg = MSFAIL ;
	}
	
#ifdef vsDEBUG
	for( i = 0 ; i < *size ; i++ ) {
		__DBGpr_int( "Array", usrIndices[i] ) ;
	}
#endif

	wrapup :
		End
		return sts ;

} /* method VSgetMapping */
/*----------------------------------------------------------------------------*/

end implementation VScompcurve ;
