/*
	I/STRUCT
*/ 
class implementation VSselector ;

#include "OMmacros.h"
#include "EMSmsgdef.h"
#include "vsdatamacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "vsstrngproto.h"
/*----------------------------------------------------------------------------*/
method GRgetattr(	long	*msg ;
			char	*attr ) {

	char	**ptr = (char **) attr ;
	long	sts ;

	if( *ptr = VSstrdup( me->program ) ) {
		sts	= OM_S_SUCCESS ;
		*msg	= MSSUCC ;
	} else vs$mem_fail() ;

	wrapup :
		return sts ;

} /* method GRgetattr */
/*----------------------------------------------------------------------------*/

end implementation VSselector ;

