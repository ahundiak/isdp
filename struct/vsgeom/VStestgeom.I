/*
	I/STRUCT
*/
class implementation GRvg ;

#include "msdef.h"
#include "madef.h"
#include "bserr.h"
#include "bstypes.h"
#include "EMSmsgdef.h"
#include "vsmiscmacros.h"
#include "vsgeommacros.h"
#include "vsdatamacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "bstst_plan.h"
#include "bststcvfln.h"
/*----------------------------------------------------------------------------*/
int VSisSurfacePlanar( msg, surfId, surfEnv, surfGeom )

long			*msg ;
struct GRid		*surfId ;
struct GRmd_env		*surfEnv ;
struct IGRbsp_surface	*surfGeom ; {

	long			sts ;		/* OM return code	*/
	IGRboolean		isPlanar ;
	long			rc ;
	IGRvector		normal ;

	isPlanar = FALSE ;

	if( !surfGeom ) {
		if( surfId && surfEnv ) {
			sts = om$send(	msg	= message GRvg.GRgenabsg(
							msg,
							&surfEnv->_MATRIX_TYPE,
							surfEnv->_MATRIX,
							(char **) &surfGeom ),
					senderid= surfId->objid,
					targetid= surfId->objid,
					targetos= surfId->osnum ) ;
			__CheckRC( sts, *msg, "GRvg.GRgenabsg", wrapup ) ;
		} else {
			*msg = MSINARG ; goto wrapup ;
		}
	}

	BStst_plan(	surfGeom->u_num_poles * surfGeom->v_num_poles,
			surfGeom->poles,
			(surfGeom->rational ? surfGeom->weights : NULL),
			&isPlanar,
			normal,
			&rc ) ;

	if( BSERROR( rc ) ) vs$error( msgval = EMS_E_BSerror ) ;

	*msg = MSSUCC ;

	wrapup :
		return isPlanar ;

} /* VSisSurfacePlanar */
/*----------------------------------------------------------------------------*/
int VSisCurveLinear( msg, curveId, curveEnv, curveGeom )

long			*msg ;
struct GRid		*curveId ;
struct GRmd_env		*curveEnv ;
struct IGRbsp_curve	*curveGeom ; {

	long			sts,		/* OM return code	*/
				rc ;		/* BS return code	*/
	IGRpoint		startPnt,
				endPnt ;
	short			isLine ;
	int			isLinear ;

	isLinear = FALSE ;

	if( !curveGeom ) {
		if( curveId && curveEnv ) {
			sts = om$send(	msg	= message GRvg.GRgenabsg(
							msg,
							&curveEnv->_MATRIX_TYPE,
							curveEnv->_MATRIX,
							(char **) &curveGeom ),
					senderid= curveId->objid,
					targetid= curveId->objid,
					targetos= curveId->osnum ) ;
			__CheckRC( sts, *msg, "GRvg.GRgenabsg", wrapup ) ;
		} else {
			*msg = MSINARG ; goto wrapup ;
		}
	}
	
	BStstcvfln( curveGeom,
		    &isLine,
		    startPnt,
		    endPnt,
		    &rc ) ;
		    
	if( BSERROR( rc ) ) vs$error( msgval = EMS_E_BSerror ) ;

	if( isLine == 1 ) isLinear = TRUE ;
	
	*msg = MSSUCC ;

	wrapup :
		return isLinear ;

} /* VSisCurveLinear */
/*----------------------------------------------------------------------------*/

end implementation GRvg ;
