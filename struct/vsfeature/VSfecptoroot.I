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
/*----------------------------------------------------------------------------*/
method NDcopy_to_root(	long		*msg ;
			int		cp_type ;
			struct GRmd_env	*myEnv,
					*rootEnv ;
			struct GRid	*rootId ; ) {

	long		sts ;		/* OM return code	*/

	rootId->objid = NULL_OBJID ;

	if( ( cp_type & ND_TO_MACRO ) || ( cp_type & ND_FROM_MACRO ) ) {

		/*
		 * Copying to or from macro definition.
		 */
		sts = om$send(	msg	= message ACncpx.NDcopy_to_root(
							msg,
							cp_type,
							myEnv,
							rootEnv,
							rootId ),
				mode	= OM_e_wrt_message,
				targetid= my_id ) ;
	} else {
		/*
		 * Return a frozen copy of yourself: a frozen object is dumb.
		 */
		sts = om$send(	msg	= message VSfeature.VScreateFrozenCopy(
						msg, myEnv, rootEnv, rootId ),
				targetid= my_id ) ;
	}

	return sts ;

} /* NDcopy_to_root */
/*----------------------------------------------------------------------------*/
method VScopy_to_root(	long		*msg ;
			int		cp_type ;
			struct GRmd_env	*myEnv,
					*rootEnv ;
			struct GRid	*rootId ; ) {

	long		sts ;		/* OM return code	*/
	char		myState,	/* My node state	*/
			cpyState ;	/* Copy's node state	*/
	struct GRid	cpyId ;		/* Id of non-root copy	*/

	sts = om$send(	msg	= message VSfeature.NDcopy(	msg,
								cp_type,
								myEnv,
								rootEnv,
								&cpyId ) ,
			targetid = my_id ) ;
	__CheckRC( sts, *msg, "VSfeature.NDcopy", wrapup ) ;

	if( IF_NULL_OBJID( cpyId.objid ) )  goto wrapup ;

	/*
	 * AF The following seems to break macro creation !.
	 */
	sts = om$send(	msg	= message NDnode.NDget_state( &myState ),
			targetid= my_id ) ;
	__CheckRC( sts, *msg, "NDnode.NDget_state", wrapup ) ;

	cpyState = myState & ~ND_DONT_MVRT ;

	sts = om$send(	msg	= message NDnode.NDchg_state( ~0, cpyState ),
			targetid= cpyId.objid,
			targetos= cpyId.osnum ) ;
	__CheckRC( sts, *msg, "NDnode.NDchg_state", wrapup ) ;
		  
	/*
	 * The following message is sent with respect to message: this
	 * copy-to-root message will only be used for objects which override
	 * the move-to-root message, but in this case we do not want to use
	 * their version of move-to-root but that of the ancestor class.
	 */
	sts = om$send(	msg	= message ACncpx.NDmove_to_root(
							msg, rootId, rootEnv ),
			mode	= OM_e_wrt_message,
			targetid= cpyId.objid,
			targetos= cpyId.osnum ) ;
	__CheckRC( sts, *msg, "ACncpx.NDmove_to_root", wrapup ) ;

	sts = om$send(	msg	= message NDnode.NDchg_state( ~0, myState ),
			targetid= rootId->objid,
			targetos= rootId->osnum );
	__CheckRC( sts, *msg, "NDnode.NDchg_state", wrapup ) ;

	wrapup :
		return sts ;

} /* method VScopy_to_root */
/*----------------------------------------------------------------------------*/

end implementation VSfeature ;
