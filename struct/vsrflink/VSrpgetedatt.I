/*
	I/STRUCT
*/ 
class implementation VSrflPlate ;

#include "vsdbgmacros.h"
/*----------------------------------------------------------------------------*/
method VSgetUserEditableAttr(	long		*msg ;
				unsigned long	*type,
						*attr ; ) {

	SetProc( VSrflPlate_VSgetUserEditableAttr ) ; Begin ; __DBGpr_me() ;

	/*
	 * No editable attributes whatsoever: this is linked to a plate in
	 * a reference file (NOTE: the reference file may not be attached).
	 */
	*attr = 0 ;

	*type = VS_m_SRC_PLATE ;

	*msg	= MSSUCC ;
	End
	return OM_S_SUCCESS ;

} /* method VSgetUserEditableAttr */
/*----------------------------------------------------------------------------*/

end implementation VSrflPlate ;

