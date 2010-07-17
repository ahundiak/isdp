/*
	I/STRUCT
*/
class implementation VSmodJoint ;

#include "EMSmsgdef.h"
#include "nddef.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "vsvirtualinf.h"
/*----------------------------------------------------------------------------*/
method VSgetJoinedFeatures(	long			*msg ;
				struct GRobj_env	*feature0,
							*feature1,
							*parentJoint ) {

	long		sts ;	/* OM return code	*/
	int		count ;
	struct GRid	parents[3] ;

	sts = om$send(	msg	= message NDnode.NDget_objects(	ND_ROOT,
								parents,
								3,
								NULL,
								0, /* From */
								2, /* To   */
								&count ),
			targetid= my_id ) ;
	__CheckRC( sts, 1, "NDnode.NDget_objects", wrapup ) ;

	sts = VSgetVirtualInfo(	msg,
				parents + 1,
				&feature0->mod_env,
				&feature0->_grid ) ;
	__CheckRC( sts, *msg, "VSgetVirtualInfo", wrapup ) ;

	sts = VSgetVirtualInfo(	msg,
				parents + 2,
				&feature1->mod_env,
				&feature1->_grid ) ;
	__CheckRC( sts, *msg, "VSgetVirtualInfo", wrapup ) ;

	if( parentJoint ) {
		sts = VSgetVirtualInfo(	msg,
					parents + 0,
					&parentJoint->mod_env,
					&parentJoint->_grid ) ;
		__CheckRC( sts, *msg, "VSgetVirtualInfo", wrapup ) ;
	}

	wrapup :
		return sts ;

} /* VSgetJoinedFeatures */
/*----------------------------------------------------------------------------*/

end implementation VSmodJoint ;

