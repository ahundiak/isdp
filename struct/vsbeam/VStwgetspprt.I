/*
	I/STRUCT
*/
class implementation VStwsBeam ;

/*
 * Includes of function prototypes.
 */
#include "vsgetinpbynm.h"
#include "vsbmsuppdef.h"
#include "vsbeamdef.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
/*----------------------------------------------------------------------------*/
method VSgetSupportSf(	long			*msg ;
			struct GRmd_env		*myEnv ;
			struct GRobj_env 	*surface ) 
{

	long 			sts ;
	int			ACrc ;		/* ACreturn code	*/
	struct GRid		bmSupp ;
	struct GRobj_env	supports[1] ;	/* 0: surface, 1: curve	*/

	sts = om$send(	msg	= message ACcpx.ACfind_temp_obj(
						&ACrc,
						VS_K_bmSuppSurf,
						&bmSupp),
			targetid= my_id ) ;
	*msg = ACrc ? MSSUCC : MSFAIL ;
	__CheckRC( sts, *msg, "ACcpx.ACfind_temp_obj", wrapup );
	__DBGpr_obj("Beam Support Object", bmSupp );

	sts = om$send(	msg	= message VScpx.VSget_graphic_input(
					msg, 1, &bmSupp, supports ),
			targetid = my_id ) ;
	__CheckRC( sts, *msg, "VScpx.VSget_graphic_input", wrapup ) ;

	*surface = supports[0] ;
	__DBGpr_obj(" support Surface", surface->obj_id );

wrapup:

	return sts ;
	
} /* method VSgetSupportSf */
/*----------------------------------------------------------------------------*/

end implementation VStwsBeam ;

