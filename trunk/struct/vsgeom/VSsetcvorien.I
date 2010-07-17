/*
	I/STRUCT
*/
class implementation GRcurve ;

#include <stdio.h>
#include <stdlib.h>
#include "bserr.h"
#include "bstypes.h"
#include "msdef.h"
#include "EMSmsgdef.h"
#include "vsdatamacros.h"
#include "vsgeommacros.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "maaddvc.h"
#include "bscveval.h"
#include "bsdotp.h"
#include "bssfeval.h"
/*----------------------------------------------------------------------------*/
long VSsetCurveOrientationAlongUVSf( msg, cvId, cvEnv, sfId, sfEnv )

long		*msg ;
struct GRid	*cvId ;
struct GRmd_env *cvEnv ;
struct GRid	*sfId ;
struct GRmd_env *sfEnv ; {

	/*
	 * This function is interfaced by macro 'vs$set_cv_orient_along_UVsf'.
	 */

	long			sts,
				rc ;
	double			cvEval[6],
				sfEval[12],
				dirUVsf[3] ;
	struct IGRbsp_curve	*cvGeom = NULL ;
	struct IGRbsp_surface	*sfGeom = NULL ;

	/*
	 * Get geometry of curve and surface.
	 */
	sts = vs$get_geometry( msg	= msg,
			       grobjId	= cvId,
			       grobjEnv = cvEnv,
			       geometry = &cvGeom ) ;
	__CheckRC( sts, *msg, "vs$get_geometry", wrapup ) ;

	sts = vs$get_geometry( msg	= msg,
			       grobjId	= sfId,
			       grobjEnv = sfEnv,
			       geometry = &sfGeom ) ;
	__CheckRC( sts, *msg, "vs$get_geometry", wrapup ) ;

	/*
	 * Get tangent of curve at middle.
	 */
	BScveval( cvGeom,
		  0.5,
		  1,
		  (IGRpoint *) cvEval,
		  &rc ) ;
	if( BSERROR( rc ) ) vs$error( msgval = EMS_E_BSerror ) ;

	/*
	 * Get tangents of surface at middle point.
	 */
	BSsfeval( sfGeom, 0.5, 0.5, 1, (IGRpoint *) sfEval, &rc ) ;
	if( BSERROR( rc ) ) vs$error( msgval = EMS_E_BSerror ) ;

	/*
	 * Compute direction of surface ( direction = U tangent + V tangent ).
	 */
	MAaddvc( &rc, sfEval + 3, sfEval + 6, dirUVsf ) ;

	/*
	 * If the dot product between the tangent of curve and the direction of
	 * surface is <0, reverse orientation of curve. Otherwise, don't change
	 * orientation of curve.
	 */
	if( BSdotp( &rc, cvEval + 3, dirUVsf ) < 0. ) {
		sts = om$send( msg	= message GRcurve.GRrevparm( msg,
								     cvEnv ),
			       senderid = cvId->objid,
			       targetid = cvId->objid,
			       targetos = cvId->osnum ) ;
		__CheckRC( sts, *msg, "GRcurve.GRrevparm", wrapup ) ;
	}

	sts  = OM_S_SUCCESS ;
	*msg = MSSUCC ;

	wrapup :
		_FREE( cvGeom ) ;
		_FREE( sfGeom ) ;

		return sts ;

} /* VSsetCurveOrientationAlongUVSf */
/*----------------------------------------------------------------------------*/

end implementation GRcurve ;
