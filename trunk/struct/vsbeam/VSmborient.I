/*
	I/STRUCT

*/
class implementation VSmodBeam ;

#include "OMerrordef.h"
#include "msdef.h"
#include "vsdbgmacros.h"
/*----------------------------------------------------------------------------*/
method VSsetOrientation(	long		*msg ;
				struct GRmd_env	*myEnv ;
				int		orientation ) {

	long			notUsed ;	/* Self-explanatory	*/

	return om$send(	msg	= message NDmacro.ACbubble_up(
					&notUsed,
					"",
					VS_K_ConsumedIx,
					message VSpart.VShasOrientation(
							VS_K_WRITE_OMmsg ),
					message VSpart.VSsetOrientation(
								msg,
								myEnv,
								orientation ),
					OM_e_wrt_object ),
			targetid= my_id ) ;

} /* method VSsetOrientation */
/*----------------------------------------------------------------------------*/
method VSgetOrientation(	long	*msg ;
				int	*orientation ) {

	long			notUsed ;	/* Self-explanatory	*/

	return om$send(	msg	= message NDmacro.ACbubble_up(
					&notUsed,
					"",
					VS_K_ConsumedIx,
					message VSpart.VShasOrientation(
							VS_K_READ_OMmsg ),
					message VSpart.VSgetOrientation(
								msg,
								orientation ),
					OM_e_wrt_object ),
			targetid= my_id ) ;
 
} /* method VSgetOrientation */
/*----------------------------------------------------------------------------*/

end implementation VSmodBeam ;


