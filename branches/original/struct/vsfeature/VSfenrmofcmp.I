/*
	I/STRUCT
*/
class implementation VSfeature ;

#include "vsmiscmacros.h"
#include "vsgeommacros.h"
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

	long		sts ;	/* OM return code			*/
	struct GRid	cmp ;	/* Component, supposed to be a surface	*/
	struct GRmd_env	idEnv,
			*pEnv ;
	double		uv[2] ;

	/*
	 * Get component, then get normal.
	 */
	sts = om$send( msg	= message NDmacro.ACreturn_foot(
					msg, pathName, &cmp, NULL, NULL ),
			targetid= my_id ) ;
	__CheckRC( sts, *msg, "NDmacro.ACreturn_foot", wrapup ) ;

	/*
	 * We compute the normal to the surface with the identity matrix,
	 * then transform the vector: in case of a mirror the normal of
	 * the mirrored surface is *not* the mirror of the normal of the
	 * original surface: the cross-product is not conserved by a mirror
	 * operation.
	 */
	if( myEnv->_MATRIX_TYPE != MAIDMX ) {
		idEnv._MATRIX_TYPE = MAIDMX ;
		MAidmx( msg, idEnv._MATRIX ) ;
		idEnv.md_id = myEnv->md_id ;
		pEnv = &idEnv ;
	} else {
		pEnv = myEnv ;
	}
	uv[0] = U ; uv[1] = V ;
	sts = vs$get_normal(	msg	= msg,
				sfId	= &cmp,
				sfEnv	= pEnv,
				parm	= uv,
				normal	= normal ) ;
	__CheckRC( sts, *msg, "vs$get_normal", wrapup ) ;

	if( myEnv->_MATRIX_TYPE != MAIDMX ) {
		VSmxprodvc( myEnv->_MATRIX, normal, normal ) ;
	}

	wrapup :
		return sts ;

} /* method VSgetNormalOfComponent */
/*----------------------------------------------------------------------------*/

end implementation VSfeature ;

