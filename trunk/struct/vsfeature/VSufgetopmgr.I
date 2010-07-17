/*
	I/STRUCT
*/
class implementation VSsubFeature ;

#include "nddef.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
/*----------------------------------------------------------------------------*/
method VSgetOperationMgr(	long		*msg ;
				struct GRid	*opMgr ) {

	return om$send(	msg	= message VSfeature.VSgetConsumedParent(
							msg, opMgr, NULL ),
			targetid= my_id ) ;	

} /* method VSgetOperationMgr */
/*----------------------------------------------------------------------------*/

end implementation VSsubFeature ;

