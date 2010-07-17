/*
	I/STRUCT
*/ 
class implementation VSstfBeam ;

#include <string.h>
#include "OMmacros.h"
#include "EMSmsgdef.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "ASsupport.h"
/*----------------------------------------------------------------------------*/
method VSgetUserEditableAttr(	long		*msg ;
				unsigned long	*type,
						*attr ; ) {

	struct GRid	myGRid,
			owner ;

	/*
	 * No editable attributes if object is a macro's output.
	 */
	myGRid.objid = my_id ;
	myGRid.osnum = OM_Gw_current_OS ;

	ASget_as_owner(	&myGRid, &owner ) ;
	if( IF_NULL_OBJID( owner.objid ) ) {
		/*
		 * Since a stiffener lies on a plate, it cannot go through
		 * it. Note that not all symmetries or cardinal points are
		 * allowed.
		 */
		*attr = VS_m_All & ~VS_m_RotAngle ;
	} else {
		*attr = 0 ;
	}

	*type = VS_m_STF_BEAM ;

	*msg	= MSSUCC ;
	return OM_S_SUCCESS ;


} /* method VSgetUserEditableAttr */
/*----------------------------------------------------------------------------*/

end implementation VSstfBeam ;

