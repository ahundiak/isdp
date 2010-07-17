/*
	I/STRUCT
*/
class implementation VSfeature ;

#include "nddef.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
/*----------------------------------------------------------------------------*/
method VSgetOperationMgr(	long		*msg ;
				struct GRid	*opMgr ) {

	*msg		= MSSUCC ;
	opMgr->objid	= my_id ;
	opMgr->osnum	= OM_Gw_current_OS ;

	return OM_S_SUCCESS ;

} /* method VSgetOperationMgr */
/*----------------------------------------------------------------------------*/

end implementation VSfeature ;

