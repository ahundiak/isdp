/*
	I/STRUCT
*/ 
class implementation VSrflBeam ;

#include "vsdbgmacros.h"
/*----------------------------------------------------------------------------*/
method VSgetUserEditableAttr(	long		*msg ;
				unsigned long	*type,
						*attr ; ) {

	/*
	 * No editable attributes whatsoever: this is linked to a beam in
	 * a reference file (NOTE: the reference file may not be attached).
	 */
	*attr = 0 ;

	*type = VS_m_SRC_BEAM ;

	*msg	= MSSUCC ;

	return OM_S_SUCCESS ;

} /* method VSgetUserEditableAttr */
/*----------------------------------------------------------------------------*/

end implementation VSrflBeam ;

