/*
	I/STRUCT
*/
class implementation VSstfBeam ;

/*
 * Includes of function prototypes.
 */
#include "vsgetinpbynm.h"
/*----------------------------------------------------------------------------*/
method VSgetSupportSf(	long			*msg ;
			struct GRmd_env		*myEnv ;
			struct GRobj_env 	*sf ) {

	return om$send(	msg	= message VSstfBeam.VSgetPlateSurface(
							msg, myEnv, NULL, sf ),
			targetid= my_id ) ;

} /* method VSgetSupportSf */
/*----------------------------------------------------------------------------*/

end implementation VSstfBeam ;

