/*
	I/STRUCT
*/
class implementation VSimgFeature ;

#include "madef.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "vsvecmxproto.h"
/*----------------------------------------------------------------------------*/
method VSgetMassProperties(	long		*msg ;
				struct GRmd_env *myEnv ;
				VSintegral	*mp ) {

	long		sts ;
	struct GRmd_env	modelEnv ;
	struct GRid	modelId ;

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
	sts = om$send(	msg	= message VSpart.VSgetMassProperties(
							msg, &modelEnv, mp ),
			targetid= modelId.objid,
			targetos= modelId.osnum ) ;

	wrapup :
		return sts ;

} /* method VSgetMassProperties */
/*----------------------------------------------------------------------------*/

end implementation VSimgFeature ;
