/*
	I/STRUCT
*/
class implementation VSimgFeature ;

#include "vsdbgmacros.h"
/*----------------------------------------------------------------------------*/
method VSforwardToOriginal(	long			*msg ;
				enum OM_e_wrt_flag	deliver ;
				OM_p_MESSAGE		Message ) {

	long			sts ;		/* OM return code	*/
	struct GRid		mdl ;

	sts = om$send(	msg	= message VSimgFeature.VSgetModel( &mdl, NULL ),
			targetid= my_id ) ;
	if( !( sts & 1 ) ) { *msg = MSFAIL ; goto wrapup ; }

	sts = om$send(	msg	= message VSfeature.VSforwardToOriginal(
							msg, deliver, Message ),
			targetid= mdl.objid,
			targetos= mdl.osnum ) ;
	wrapup :
		return sts ;

} /* method VSforwardToOriginal */
/*----------------------------------------------------------------------------*/

end implementation VSimgFeature ;

