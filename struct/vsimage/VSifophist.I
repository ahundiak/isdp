/*
	I/STRUCT
*/
class implementation VSimgFeature ;

#include "madef.h"
#include "vsdbgmacros.h"
#include "vsmiscmacros.h"
/*
 * Includes of function prototypes.
 */
#include "vsvecmxproto.h"
/*----------------------------------------------------------------------------*/
method VSgetOperationHistory(	long		*msg ;
				struct GRmd_env	*myEnv ;
				VSopHistory	**p_history ; ) {
	long		sts ;
	struct GRmd_env	modelEnv ;
	struct GRid	modelId ;

	*p_history = NULL ;

	sts = om$send(	msg	= message VSimgFeature.VSgetModel(
							&modelId, &modelEnv ),
			targetid= my_id ) ;
	if( !( sts & 1 ) ) { *msg = MSFAIL ; goto wrapup ; }

	if( myEnv->_MATRIX_TYPE != MAIDMX ) {
		VSmulmx(	myEnv->_MATRIX,
				modelEnv._MATRIX,
				modelEnv._MATRIX,
				&modelEnv._MATRIX_TYPE ) ;
	}
	sts = om$send(	msg	= message VSfeature.VSgetOperationHistory(
						msg, &modelEnv, p_history ),
			targetid= modelId.objid,
			targetos= modelId.osnum ) ;
	wrapup :
		return sts ;

} /* method VSgetOperationHistory */
/*----------------------------------------------------------------------------*/

end implementation VSimgFeature ;
