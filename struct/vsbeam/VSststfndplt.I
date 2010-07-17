/*
	I/STRUCT
*/
class implementation VSstfBeam ;

#include "vsmiscmacros.h"
/*
 * Includes of function prototypes.
 */
#include "vsvirtualinf.h"
/*----------------------------------------------------------------------------*/
method VSgetStiffenedPlate( long *msg ; struct GRobj_env *plate ) {

	long		sts ;
	int		rc ;
	struct GRid	realParent ;

	sts = om$send(	msg	= message ACcpx.ACfind_temp_obj(
							&rc,
							VS_K_stSuppPlate,
							&realParent ),
			targetid= my_id ) ;
	if( !( rc & 1 ) ) { *msg = MSFAIL ; goto wrapup ; }

	sts = VSgetVirtualInfo(	msg,
				&realParent,
				&plate->mod_env,
				&plate->_grid ) ;

	wrapup :
		return sts ;

} /* method VSgetStiffenedPlate */
/*----------------------------------------------------------------------------*/

end implementation VSstfBeam ;

