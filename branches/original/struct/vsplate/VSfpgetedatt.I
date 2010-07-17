/*
	I/STRUCT
*/ 
class implementation VSfrzPlate ;

#include <string.h>
#include "EMSmsgdef.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
/*----------------------------------------------------------------------------*/
method VSgetUserEditableAttr(	long		*msg ;
				unsigned long	*type,
						*attr ; ) {

	/*
	 * No editable attributes whatsoever: this is a frozen plate.
	 */
	*attr = 0 ;
	*type = VS_m_SRC_PLATE ;

	*msg	= MSSUCC ;
	return OM_S_SUCCESS ;

} /* method VSgetUserEditableAttr */
/*----------------------------------------------------------------------------*/

end implementation VSfrzPlate ;

