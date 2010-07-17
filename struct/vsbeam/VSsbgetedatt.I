/*
	I/STRUCT
*/ 
class implementation VSsrcBeam ;

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
	 * No editable attributes if object is the output of a macro occurrence.
	 */
	myGRid.objid = my_id ;
	myGRid.osnum = OM_Gw_current_OS ;

	ASget_as_owner(	&myGRid, &owner ) ;
	*attr = IF_NULL_OBJID( owner.objid ) ? VS_m_All : 0 ;
	*type = VS_m_SRC_BEAM ;

	*msg	= MSSUCC ;
	return OM_S_SUCCESS ;

} /* method VSgetUserEditableAttr */
/*----------------------------------------------------------------------------*/

end implementation VSsrcBeam ;

