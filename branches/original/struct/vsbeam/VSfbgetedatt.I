/*
	I/STRUCT
*/ 
class implementation VSfrzBeam ;

#include <string.h>
#include "OMmacros.h"
#include "EMSmsgdef.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
/*----------------------------------------------------------------------------*/
method VSgetUserEditableAttr(	long		*msg ;
				unsigned long	*type,
						*attr ; ) {

	/*
	 * No editable attributes whatsoever: this is a frozen beam.
	 */
	*attr = 0 ;

	*type = VS_m_SRC_BEAM ;

	*msg	= MSSUCC ;
	return OM_S_SUCCESS ;

} /* method VSgetUserEditableAttr */
/*----------------------------------------------------------------------------*/

end implementation VSfrzBeam ;

