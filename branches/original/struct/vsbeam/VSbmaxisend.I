/*
	I/STRUCT
*/
class implementation VSbeam ;

#include "madef.h"
#include "grerr.h"
#include "EMSmsgdef.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "vsvecmxproto.h"

from	GRcurve		import	GRendpts ;
/*----------------------------------------------------------------------------*/
method VSgetSegmentEnds(	long		*msg ;
				struct GRmd_env	*myEnv ;
				IGRpoint	endp[2] ) {

	long		 sts ;		/* OM completion code	*/
        struct GRobj_env axis ;		/* Support axis		*/

	/*
	 * Retrieve support axis.
	 */
	sts = om$send(	msg	= message VSbeam.VSgetSupportAxis(
							msg, myEnv, &axis ),
			targetid= my_id ) ;
	__CheckRC( sts, *msg, "VSbeam.VSgetSupportAxis", wrapup ) ;

	sts = om$send(	msg	= message GRcurve.GRendpts(
						msg,
						&axis._matrix_type,
						axis._matrix,
						endp[0],
						endp[1] ),
			targetid= axis._objid,
			targetos= axis._osnum ) ;
	__CheckRC( sts, *msg, "GRcurve.GRendpts", wrapup ) ;

	/*
	 * Map end points to beam coordinate system.
	 */
	if( myEnv->_MATRIX_TYPE != MAIDMX ) {
		VSmxprodpt( myEnv->_MATRIX, endp[0], endp[0] ) ;
		VSmxprodpt( myEnv->_MATRIX, endp[1], endp[1] ) ;
	}
	wrapup :
		return sts ;

} /* method VSgetSegmentEnds */
/*----------------------------------------------------------------------------*/

end implementation VSbeam ;

