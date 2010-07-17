/*
	I/STRUCT
*/
class implementation VSvrsnStamp ;

#include <stdio.h>
#include "OMerrordef.h"
#include "exdef.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "gr.h"
#include "vsdbgmacros.h"

extern void	VSgetCurrentVersion() ;
/*----------------------------------------------------------------------------*/
method sleep( int type ) {

	int	rr, uu, ss, tt ;

	/*
	 * Store version number of I/STRUCT, which will flag with which
	 * version of the software the structural objects of this file have
	 * been made.
	 */
	VSgetCurrentVersion( &rr, &uu, &ss, &tt ) ;

	me->version.rr = rr ;
	me->version.uu = uu ;
	me->version.ss = ss ;
	me->version.tt = tt ;

	return OM_S_SUCCESS ;

} /* method sleep */
/*----------------------------------------------------------------------------*/

end implementation VSvrsnStamp ;


