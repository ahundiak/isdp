/*
	I/STRUCT
*/ 
class implementation VSselector ;

#include <string.h>
#include "OMmacros.h"
#include "EMSmsgdef.h"
#include "vsdbgmacros.h"
/*----------------------------------------------------------------------------*/
method	GRputattr(	long	*msg ;
			char	*attr ) {

	int	l = strlen( attr ) ;
	long	sts ;

	/*
	 * Set instance data.
	 */
	sts = om$vla_set_dimension(	varray	= me->program,
					size	= 1 + l ) ;
	if( sts & 1 ) {
		strcpy( me->program, attr ) ;
		*msg = MSSUCC ;
	} else {
		*msg = EMS_E_NoDynamicMemory ;
	}
	
	return sts ;

} /* method GRputattr */
/*----------------------------------------------------------------------------*/

end implementation VSselector ;

