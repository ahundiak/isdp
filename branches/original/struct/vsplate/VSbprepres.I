/*
	I/STRUCT
*/
class implementation VSbooPlate ;

#include "nddef.h"
#include "vsdbgmacros.h"
/*----------------------------------------------------------------------------*/
method ACset_NV_rep( VSdspRep rep ; struct GRmd_env *my_env ) {

	long			sts,		/* OM completion code	*/
				msg ;		/* Completion code	*/
	struct GRid		virualParent ;	/* My virtual parent	*/
	
	sts = om$send(	msg	= message VSfeature.VSgetConsumedParent(
						&msg, &virualParent, NULL ),
			targetid= my_id ) ;

	sts = om$send(	msg	= message VSplate.VSchgRepForConsume( rep ),
			targetid= virualParent.objid,
			targetos= virualParent.osnum ) ;

	sts = om$send(	msg	= message VSmodFeature.ACset_NV_rep(
								rep, my_env ),
			mode	= OM_e_wrt_message,
			targetid= my_id ) ;

	return sts ;

} /* method ACset_NV_rep */
/*----------------------------------------------------------------------------*/

end implementation VSbooPlate ;
