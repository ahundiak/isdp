/*
	I/STRUCT
*/
class implementation VSfrzPlate ;

#include "nddef.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
/*----------------------------------------------------------------------------*/
method NDcopy_to_root(	long		*msg ;
			int		cp_type ;
			struct GRmd_env	*myEnv,
					*rootEnv ;
			struct GRid	*rootId ) {

	long		sts ;		/* OM return code	*/

	rootId->objid = NULL_OBJID ;

	if( ( cp_type & ND_TO_MACRO ) || ( cp_type & ND_FROM_MACRO ) ) {

		/* -- Copying to or from macro definition --
		 */
		sts = om$send(	msg	= message VSfeature.NDcopy_to_root(
							msg,
							cp_type,
							myEnv,
							rootEnv,
							rootId ),
				mode	= OM_e_wrt_message,
				targetid= my_id ) ;
		__CheckRC( sts, *msg, "ACncpx.NDcopy_to_root", wrapup ) ;
	} else {
	       sts = om$send(	msg	= message VSfeature.VScreateFrozenCopy(
						msg, myEnv, rootEnv, rootId ),
				targetid= my_id ) ;
	       __CheckRC( sts, *msg, "VSfeature.VScreateFrozenCopy.GRcopy", wrapup ) ;
	}

	wrapup :
		return sts ;

} /* method NDcopy_to_root */
/*----------------------------------------------------------------------------*/

end implementation VSfrzPlate ;

