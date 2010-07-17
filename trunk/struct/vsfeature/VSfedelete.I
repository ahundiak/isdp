/*
	I/STRUCT
*/
class implementation VSfeature ;

#include "OMmacros.h"
#include "nddef.h"
#include "ndmacros.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "vsvirtualinf.h"

from VSmodFeature	import	VStransferRep ;
/*----------------------------------------------------------------------------*/
method VSdelete( struct GRmd_env *myEnv ) {

	long		sts ;		/* OM return code	*/
	int		count ;		/* Parent count		*/
	struct GRid	operand ;	/* Consumed parent	*/
	unsigned long	myType ;	/* My struct. type	*/

	/*
	 * Do not do any special processing if you are inside a macro
	 * definition: expected parents may be pretends which points to
	 * nothing.
	 */
	sts = om$send(	msg	= message VSfeature.VSgetResultType(
								&sts, &myType ),
			targetid= my_id ) ;

	if( myType & VS_m_IN_DEFINITION ) {
		/*
		 * I'm in a macro definition.
		 * Count = 0 will drive control to the "hard" delete case below.
		 */
		count = 0 ;
	} else {
		sts = om$send(	msg	= message NDnode.NDget_objects(
								ND_ROOT,
								&operand,
								1,
								NULL,
						/* from = */	VS_K_ConsumedIx,
						/* to   = */	VS_K_ConsumedIx,
								&count ),
				targetid= my_id ) ;
		__CheckRC( sts, 1, "NDnode.NDget_object", wrapup ) ;
	}

	if( count ) {
		long			msg ;	/* Completion code	*/
		int			deleteParent ;
		struct GRobj_env	virtual ;

		/*
		 * Find consumed parent, then unconsume parent.
		 */
		sts = VSgetVirtualInfo(	&msg,
					&operand,
					&virtual.mod_env,
					&virtual._grid ) ;

		__CheckRC( sts, msg, "VSgetVirtualInfo", wrapup );

		/*
		 * Either REAL parent = VIRTUAL parent, in this case we get
		 * rid of parent too, or REAL parent != VIRTUAL parent, ie.
		 * real parent is a pretend meaning taht VIRTUAL parent is
		 * either the output of some macro or in a reference file :
		 * we do not get rid of it, but rather have it come back.
		 */

		deleteParent = IF_EQ_GRID( virtual._grid, operand ) ;

		if( !deleteParent ) {
			sts = om$send(
				msg	= message VSmodFeature.VStransferRep(
						&msg, &operand, &virtual ),
				targetid= my_id ) ;

		}
		sts = vs$unconsume(	msg	= &msg,
					mod_env	= &virtual.mod_env,
					object	= &operand ) ;
		__CheckRC( sts, msg, "vs$unconsume", wrapup );

		vs$bulk_display( objids = &my_id, theEnv = myEnv, dpmode = GRbe ) ;

		sts = om$send(	msg	= message VSfeature.NDdelete( myEnv ),
				mode	= OM_e_wrt_message,
				targetid= my_id ) ;
		__CheckRC( sts, 1, "VSfeature.NDdelete", wrapup ) ;

		if( deleteParent ) {
			sts = nd$wait_batch(	
					type		= GR_DELETED,
					l_object	= &operand,
					nb_obj 		= 1 ) ;
			__CheckRC( sts, 1, "nd$wait_batch", wrapup ) ;
		}
	} else {
		/*
		 * If I do not have any parents, this is a delete from the
		 * move-to-root operation: perform "hard" delete only.
		 */

		sts = om$send(	msg	= message VSfeature.NDdelete( myEnv ),
				mode	= OM_e_wrt_message,
				targetid= my_id ) ;
		__CheckRC( sts, 1, "VSfeature.NDdelete", wrapup ) ;
	}

	wrapup :
		return sts ;

} /* method VSdelete */
/*----------------------------------------------------------------------------*/

end implementation VSfeature ;
