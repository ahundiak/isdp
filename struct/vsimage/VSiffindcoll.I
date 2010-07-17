/*
	I/STRUCT
*/ 
class implementation VSimgFeature ;

#include "nddef.h"
#include "vsdbgmacros.h"
/*----------------------------------------------------------------------------*/
method VSfindCollection( long *msg ; char *name ; struct GRid *coll ) {

	long		sts ;
	struct GRid	numberTwo ;
	int		parentCount ;

	coll->objid = NULL_OBJID ;

	/*
	 * If I have a collection of user attributes, it is my third parent
	 * (#2).
	 */
	sts = om$send(	msg	= message NDnode.NDget_objects(	ND_ROOT,
								&numberTwo,
								1,
								NULL,
						/* From : */	2,
						/* To   : */	2,
								&parentCount ),
			targetid= my_id ) ;
	__CheckRC( sts, 1, "NDnode.NDget_objects", wrapup ) ;

	if( parentCount >= 3 ) {
		*coll	= numberTwo ;
		*msg	= MSSUCC ;
	} else {
		*msg	= MSFAIL ;
	}
	sts = OM_S_SUCCESS ;

	wrapup :
		return sts ;

} /* method VSfindCollection */
/*----------------------------------------------------------------------------*/

end implementation VSimgFeature ;

