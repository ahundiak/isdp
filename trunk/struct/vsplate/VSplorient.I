/*
	I/STRUCT
*/
class implementation VSplate ;

#include "msdef.h"
#include "EMSmsgdef.h"
#include "vsdbgmacros.h"
#include "vsmiscmacros.h"
/*
 * Includes of function prototypes.
 */
#include "vsioproto.h"
/*----------------------------------------------------------------------------*/
method VSshowOrientation(	long			*msg ;
				struct GRmd_env		*myEnv ;
				int			wantReversed ;
				enum GRdpmode		pen ;
				struct IGRdisplay	*symbology ) {

	long			sts ;		/* OM return code	*/
	struct GRobj_env	surface ;	/* Surface I own	*/

	sts = om$send(	msg	= message NDmacro.ACreturn_foot(
						msg,
						VS_K_plBotSfPath,
						&surface._grid,
						NULL, NULL ),
			targetid= my_id ) ;
	__CheckRC( sts, *msg, "NDmacro.ACreturn_foot", wrapup ) ;

	surface.mod_env = *myEnv ;
	sts = VSdisplaySurfaceNormal(	msg,
					&surface,
					wantReversed,
					symbology,
					pen ) ;
	__CheckRC( sts, *msg, "VSdisplaySurfaceNormal", wrapup ) ;

	wrapup :
		return sts ;

} /* method VSshowOrientation */
/*----------------------------------------------------------------------------*/

end implementation VSplate ;
