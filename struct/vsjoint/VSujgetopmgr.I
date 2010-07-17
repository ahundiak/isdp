/*
	I/STRUCT
*/
class implementation VSsubJoint ;

#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
/*----------------------------------------------------------------------------*/
method VSgetOperationMgr(	long		*msg ;
				struct GRid	*opMgr ) {

	long		sts ;		/* OM return code	*/
	int		ACrc ;

	opMgr->objid = NULL_OBJID ;
	sts = om$send(	msg	= message ACcpx.ACfind_temp_obj(
							&ACrc,
							VS_K_jnParentJn,
							opMgr ),
			targetid= my_id ) ;
	*msg = ACrc ? MSSUCC : MSFAIL ;

	return sts ;

} /* method VSgetOperationMgr */
/*----------------------------------------------------------------------------*/

end implementation VSsubJoint ;

