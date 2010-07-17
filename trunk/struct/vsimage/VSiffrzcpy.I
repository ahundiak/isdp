/*
	I/STRUCT
*/
class implementation VSimgFeature ;

#include "vsdbgmacros.h"
/*----------------------------------------------------------------------------*/
method VScreateFrozenCopy(	long		*msg ;
				struct GRmd_env	*myEnv,
						*cpyEnv ;
				struct GRid	*copy ) {

	long		sts ;
	struct GRid	modelId ;
	struct GRmd_env	modelEnv ;

	*msg = MSFAIL ; copy->objid = NULL_OBJID ;

	sts = om$send(	msg	= message VSimgFeature.VSgetModel(
							&modelId, &modelEnv ),
			targetid= my_id ) ;
	__CheckRC( sts, 1, "VSimgFeature.VSgetModel", wrapup ) ;

	sts = om$send(	msg	= message VSfeature.VScreateFrozenCopy(
								msg,
								&modelEnv,
								cpyEnv,
								copy ),
			targetid= modelId.objid,
			targetos= modelId.osnum ) ;
	__CheckRC( sts, *msg, "VSfeature.VScreateFrozenCopy", wrapup ) ;

	wrapup :
		return sts ;

} /* method VScreateFrozenCopy */
/*----------------------------------------------------------------------------*/

end implementation VSimgFeature ;

