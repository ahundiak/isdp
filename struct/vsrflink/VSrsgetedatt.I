/*
	I/STRUCT
*/ 
class implementation VSrfsBeam ;

#include "vsdbgmacros.h"
/*----------------------------------------------------------------------------*/
method VSgetUserEditableAttr(	long		*msg ;
				unsigned long	*type,
						*attr ; ) {

	SetProc( VSrfsBeam_VSgetUserEditableAttr ) ; Begin ; __DBGpr_me() ;

	/*
	 * No editable attributes whatsoever: this is linked to a beam in
	 * a reference file (NOTE: the reference file may not be attached).
	 */
	*attr = 0 ;

	*type = VS_m_STF_BEAM ;

	*msg	= MSSUCC ;
	End
	return OM_S_SUCCESS ;

} /* method VSgetUserEditableAttr */
/*----------------------------------------------------------------------------*/

end implementation VSrfsBeam ;

