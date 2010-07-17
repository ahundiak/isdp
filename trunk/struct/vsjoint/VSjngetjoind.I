/*
	I/STRUCT
*/
class implementation VSjoint ;

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
	struct GRid	parents[2] ;

	SetProc( VSjoint_VSgetJoinedFeatures ) ; Begin ; __DBGpr_me() ;

	sts = om$send(	msg	= message NDnode.NDget_objects(	ND_ROOT,
								parents,
								2,
								NULL,
								0, /* From */
								1, /* To   */
								&count ),
			targetid= my_id ) ;
	__CheckRC( sts, 1, "NDnode.NDget_objects", wrapup ) ;

	sts = VSgetVirtualInfo(	msg,
				parents + 0,
				&feature0->mod_env,
				&feature0->_grid ) ;
	__CheckRC( sts, *msg, "VSgetVirtualInfo", wrapup ) ;

	sts = VSgetVirtualInfo(	msg,
				parents + 1,
				&feature1->mod_env,
				&feature1->_grid ) ;
	__CheckRC( sts, *msg, "VSgetVirtualInfo", wrapup ) ;

	if( parentJoint ) parentJoint->_objid = NULL_OBJID ;

	wrapup :
		End
		return sts ;

} /* VSgetJoinedFeatures */
/*----------------------------------------------------------------------------*/

end implementation VSjoint ;

