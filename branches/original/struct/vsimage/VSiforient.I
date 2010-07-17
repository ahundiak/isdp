/*
	I/STRUCT
*/
class implementation VSimgFeature ;

#include "madef.h"
#include "EMSmsgdef.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "vsvecmxproto.h"
/*----------------------------------------------------------------------------*/
method VSsetOrientation(	long		*msg ;
				struct GRmd_env	*myEnv ;
				int		orientation ) {

	*msg = EMS_I_Fail ;
	return OM_S_SUCCESS ;

} /* method VSsetOrientation */
/*----------------------------------------------------------------------------*/
method VSshowOrientation(	long			*msg ;
				struct GRmd_env		*myEnv ;
				int			wantReverse ;
				enum GRdpmode		pen ;
				struct IGRdisplay	*symbology ) {

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

	sts = om$send(	msg	= message VSpart.VSshowOrientation(
							msg,
							&modelEnv,
							wantReverse,
							pen,
							symbology ),
			targetid= modelId.objid,
			targetos= modelId.osnum ) ;

	wrapup :
		return sts ;

} /* method VSshowOrientation */
/*----------------------------------------------------------------------------*/

end implementation VSimgFeature ;
