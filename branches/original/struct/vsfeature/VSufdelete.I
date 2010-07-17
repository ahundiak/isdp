/*
	I/STRUCT
*/
class implementation VSsubFeature ;

#include "nddef.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
/*----------------------------------------------------------------------------*/
method NDdelete( struct GRmd_env *my_env ) {

	long		sts,		/* OM return code	*/
			msg ;		/* Completion code	*/
	int		count ;		/* Parent count		*/
	struct GRid	superFeature ;	/* Consumed parent	*/
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
		 * Count = 0 will drive control to the "hard" delete case below.
		 */
		count = 0 ;
	} else {
		sts = om$send(	msg	= message NDnode.NDget_objects(
								ND_ROOT,
								&superFeature,
								1,
								NULL,
						/* from = */	VS_K_ConsumedIx,
						/* to   = */	VS_K_ConsumedIx,
								&count ),
			targetid= my_id ) ;
		__CheckRC( sts, 1, "NDnode.NDget_object", wrapup ) ;
	}

	/*
	 * We may have lost our parent ...
	 */
	if( count ) {
		sts = om$send(	msg	= message VSfeature.VSchildDeleted(
							&msg,
							my_id,
							OM_Gw_current_OS,
							my_env ),
				targetid= superFeature.objid,
				targetos= superFeature.osnum ) ;
	}
	/*
	 * Now the "hard" delete...
	 */
	sts = om$send(	msg	= message VSfeature.NDdelete( my_env ),
			mode	= OM_e_wrt_message,
			targetid= my_id ) ;
	__CheckRC( sts, 1, "VSfeature.NDdelete", wrapup ) ;

	wrapup :
		return sts ;

} /* methode NDdelete */
/*----------------------------------------------------------------------------*/

end implementation VSsubFeature ;
