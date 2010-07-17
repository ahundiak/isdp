/*
	I/STRUCT
*/ 
class implementation VSimgFeature ;

#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "maidmx.h"
#include "vsvecmxproto.h"
/*----------------------------------------------------------------------------*/
method VSgetNormalOfComponent(	long		*msg ;
				struct GRmd_env	*myEnv ;
				char*		pathName ;
				double		U,
						V ;
				IGRvector	normal ) {
	long		sts ;
	struct GRmd_env	modelEnv ;
	struct GRid	modelId ;
	IGRmatrix	xform ;

	sts = om$send(	msg	= message VSimgFeature.VSgetModel(
							&modelId, &modelEnv ),
			targetid= my_id ) ;
	if( !( sts & 1 ) ) { *msg = MSFAIL ; goto wrapup ; }

	if( myEnv->_MATRIX_TYPE != MAIDMX ) {
		short mxType ;
		VSmulmx( myEnv->_MATRIX, modelEnv._MATRIX, xform, &mxType ) ;
	} else {
		memcpy( xform, modelEnv._MATRIX, sizeof( IGRmatrix ) ) ;
	}
	modelEnv._MATRIX_TYPE = MAIDMX ;
	MAidmx( msg, modelEnv._MATRIX ) ;

	sts = om$send(	msg	= message VSfeature.VSgetNormalOfComponent(
						msg, &modelEnv, pathName,
						U, V, normal ),
			targetid= modelId.objid,
			targetos= modelId.osnum ) ;
	__CheckRC( sts, *msg, "VSfeature.VSgetNormalOfComponent", wrapup ) ;

	xform[3] = xform[7] = xform[11] = 0 ;
	VSmxprodvc( xform, normal, normal ) ;

	wrapup :
		return sts ;

} /* method VSgetNormalOfComponent */
/*----------------------------------------------------------------------------*/

end implementation VSimgFeature ;


