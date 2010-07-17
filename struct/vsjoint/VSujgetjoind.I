/*
	I/STRUCT
*/
class implementation VSsubJoint ;

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

	long		sts ;		/* OM return code		*/
	int		count ;		/* Of my parents		*/
#define PARENTJN	0		/* PARENT JoinT			*/
#define SBFEATURE	1		/* SuB-FEATURE			*/
#define OTFEATURE	2		/* OTher FEATURE		*/
#define MAX		3
	struct GRid	parents[MAX] ;	/* My parents			*/
	

	SetProc( VSsubJoint_VSgetJoinedFeatures ) ; Begin ; __DBGpr_me() ;

	sts = om$send(	msg	= message NDnode.NDget_objects(	ND_ROOT,
								parents,
								MAX,
								NULL,
						/* From */	0,
						/* To   */	MAX-1,
								&count ),
			targetid= my_id ) ;
	__CheckRC( sts, 1, "NDnode.NDget_objects", wrapup ) ;

	/*
	 * Get virtual parent corresponding to the sub-feature (my real
	 * parent may be a pretend !).
	 */
	sts = VSgetVirtualInfo(	msg,
				parents + SBFEATURE,
				&feature0->mod_env,
				&feature0->_grid ) ;
	__CheckRC( sts, *msg, "VSgetVirtualInfo", wrapup ) ;

	/*
	 * Get virtual parent corresponding to the other feature (my real
	 * parent may be a pretend !).
	 */
	sts = VSgetVirtualInfo(	msg,
				parents + OTFEATURE,
				&feature1->mod_env,
				&feature1->_grid ) ;
	__CheckRC( sts, *msg, "VSgetVirtualInfo", wrapup ) ;

	if( parentJoint ) {
		/*
		 * Get virtual parent corresponding to my parent divided joint.
		 * (my real parent may be a pretend !).
		 */
		sts = VSgetVirtualInfo(	msg,
					parents + PARENTJN,
					&parentJoint->mod_env,
					&parentJoint->_grid ) ;
		__CheckRC( sts, *msg, "VSgetVirtualInfo", wrapup ) ;
	}

	wrapup :
		End
		return sts ;

} /* VSgetJoinedFeatures */
/*----------------------------------------------------------------------------*/

end implementation VSsubJoint ;

