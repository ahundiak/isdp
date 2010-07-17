/*
	I/STRUCT
*/
class implementation VSplate ;

#include "nddef.h"
#include "vsdbgmacros.h"
/*----------------------------------------------------------------------------*/
method VSchgRepForConsume( VSdspRep consumedRep ) {

	long		sts,		/* OM return code 	*/
			msg ;		/* Completion code	*/
	VSobjDef	myDef ;		/* My object definition	*/
	struct GRid	virualParent ;	/* My virtual parent	*/

	sts = om$send(	msg	= message VSfeature.VSputConsumedRep(
								consumedRep ),
			targetid= my_id ) ;

	sts = om$send(	msg	= message VSpart.VSifSourceThenSend(
	 						VS_K_READ_OMmsg ),
			targetid= my_id ) ;

	 if( sts == OM_I_STOP_SENDING ) {
	 	/*
	 	 * I'm a source feature: the train stops here !.
	 	 */
	 	 sts = OM_S_SUCCESS ;
	 	 goto wrapup ;
	}

	/*
	 * Set consumed representation of parent.
	 */
	sts = om$send(	msg	= message VScpx.VSgetObjDef( &msg, &myDef ),
			targetid= my_id ) ;

	sts = om$send(	msg	= message VSfeature.VSgetConsumedParent(
						&msg, &virualParent, NULL ),
			targetid= my_id ) ;

	sts = om$send(	msg	= message VSplate.VSchgRepForConsume(
					 consumedRep & myDef.parentRep ),
		 	targetid= virualParent.objid,
			targetos= virualParent.osnum ) ;

	wrapup :
		return sts ;

} /* method VSchgRepForConsume */
/*----------------------------------------------------------------------------*/

end implementation VSplate ;
