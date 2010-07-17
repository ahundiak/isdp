/*
	I/STRUCT
*/
class implementation VSimgFeature ;

#include <string.h>
#include "exmacros.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "maidmx.h"
#include "matypemx.h"
/*----------------------------------------------------------------------------*/
method VSgetModel( struct GRid *modelId ; struct GRmd_env *modelEnv ) {

	long		sts,
			rc ;

	sts = om$send(	msg	= message ACheader.ACfind_model( &rc, modelId ),
			targetid= my_id ) ;
	__CheckRC( sts, rc, "ACheader.ACfind_model", wrapup ) ;

	if( modelEnv ) {
		struct IGRlbsys	lbsys ;
		short		mxtype = MAIDMX ;
		IGRmatrix	mx ;

		/*
		 * Get transformation matrix
		 *	model of this image -> this image
		 */

		MAidmx( &rc, mx ) ;
		sts = om$send(	msg	= message GRvg.GRgetgeom(
							&rc,
							&mxtype,
							mx,
							(char *) &lbsys ),
				targetid= my_id ) ;
		__CheckRC( sts, rc, "GRvg.GRgetgeom", wrapup ) ;

		memcpy(	(char *) modelEnv->_MATRIX,
			(char *) lbsys.matrix,
			sizeof lbsys.matrix ) ;

		MAtypemx( &rc, modelEnv->_MATRIX, &modelEnv->_MATRIX_TYPE ) ;

		modelEnv->_MD_OS = modelId->osnum ;
		ex$get_modid(	mod_id		= &modelEnv->_MD_ID,
				mod_osnum	= modelEnv->_MD_OS ) ;
	}

	wrapup :
		if( sts & 1 ) {
			if( !( rc & 1 ) ) sts = OM_W_ABORT ;
		}
	return sts ;

} /* method VSgetModel */
/*----------------------------------------------------------------------------*/

end implementation VSimgFeature ;

