/*
	I/STRUCT
*/
class implementation VSdprPart ;

#include <stdio.h>
#include "OMmacros.h"
#include "msdef.h"
#include "EMSmsgdef.h"
#include "vsdatadef.h"
#include "vsmiscmacros.h"
#include "vsdatamacros.h"
#include "vsipthmacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "vsstrngproto.h"
/*----------------------------------------------------------------------------*/
method VSgetMatchingIPATHs(	long	*msg ;
				int	*rsize ;
				char	**p_rpaths ;
				int	*vsize ;
				char	**p_vpaths ) {

	long		sts ;	/* OM return code			*/
	int		vsz,
			rsz ;

	*rsize = rsz = om$dimension_of( varray	= me->realIPATHs ) ;
	*vsize = vsz = om$dimension_of( varray	= me->virtIPATHs ) ;

	*p_rpaths = VSmemdup( me->realIPATHs, rsz * sizeof( char ) ) ;
	*p_vpaths = VSmemdup( me->virtIPATHs, vsz * sizeof( char ) ) ;

	if( *p_rpaths && *p_vpaths ) {
		sts	= OM_S_SUCCESS ;
		*msg	= MSSUCC ;
	} else {
		_FREE( *p_rpaths ) ; _FREE( *p_vpaths ) ;
		vs$mem_fail() ;
	}

	wrapup :
		return sts ;
	
} /* method VSgetMatchingIPATHs */
/*----------------------------------------------------------------------------*/

end implementation VSdprPart ;
