/*
	I/STRUCT
*/
class implementation VSfeature ;

#include "OMmacros.h"
#include "nddef.h"
#include "ndmacros.h"
#include "EMSmsgdef.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"

from	VSmodFeature	import VSremoveOperator ;
/*----------------------------------------------------------------------------*/
method VSmove_to_root(	long		*msg ;
			struct GRid	*src ;
			struct GRmd_env	*myEnv ; ) {

	long		sts ;		/* OM return code	*/
	int		who ;		/* Index of who is going*/
	struct GRid	parent ;	/* One of my roots	*/

	*msg	 = MSFAIL ;
	sts	 = OM_E_ABORT ;

	sts = om$send(	msg	= message VScpx.VSwhoIsDying(	msg,
								&who,
								&parent ),
			targetid= my_id ) ;
	__CheckRC( sts, *msg, "VScpx.VSwhoIsDying", wrapup ) ;

	if( who == 0 ) {
		/*
		 * Parent feature being deleted or some other operation.
		 */
		sts = om$send(	msg	= message ACncpx.NDmove_to_root(
							msg, src, myEnv ),
				mode	= OM_e_wrt_message,
				targetid= my_id ) ;
	} else {
		int AmDeleted ;

		sts = om$send(	msg	= message VSmodFeature.VSremoveOperator(
								msg,
								myEnv,
								&parent,
								&AmDeleted ),
				targetid= my_id ) ;
		__CheckRC( sts, *msg, "VSmodFeature.VSremoveOperator", wrapup );
	}

	*msg	 = MSSUCC ;
	sts	 = OM_S_SUCCESS ;

	wrapup :
		return sts ;

} /* method VSmove_to_root */
/*----------------------------------------------------------------------------*/
method VSparentsDeleted(	long		*msg ;
				int		deletedCount ;
				struct GRid	deletedList[] ; 
				struct GRid	*newObj ;
				struct GRmd_env *myEnv ) {

	/*
	 * Same as VSfeature.VSmove_to_root, only here we are input the list
	 * of deleted parents.
	 */
	long		sts ;
	struct GRid	parent0 ;
	int		parentCount ;
	int		i ;
	int		who ;

	sts = om$send(	msg	= message NDnode.NDget_objects(
							ND_ROOT,
							&parent0,
							1,
							NULL,
							0,
							0,
							&parentCount ),
			targetid= my_id ) ;

	who = -1 ;
	for( i = 0 ; i < deletedCount ; i++ ) {
		if(    IF_EQ_OBJID( parent0.objid, deletedList[i].objid )
		    && parent0.osnum == deletedList[i].osnum ) {
		    	who = 0 ; break ;
		}
	}

	if( who == 0 ) {
		sts = om$send(	msg	= message ACncpx.NDmove_to_root(
							msg, newObj, myEnv ),
				mode	= OM_e_wrt_message,
				targetid= my_id ) ;
	} else {
		int AmDeleted ;

		sts = om$send(	msg	= message VSmodFeature.VSremoveOperator(
								msg,
								myEnv,
								&deletedList[0],
								&AmDeleted ),
				targetid= my_id ) ;
		__CheckRC( sts, *msg, "VSmodFeature.VSremoveOperator", wrapup );
	}

	*msg	 = MSSUCC ;
	sts	 = OM_S_SUCCESS ;

	wrapup :
		return sts ;

} /* VSparentsDeleted */
/*----------------------------------------------------------------------------*/

end implementation VSfeature ;
