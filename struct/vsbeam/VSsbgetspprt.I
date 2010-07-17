/*
	I/STRUCT
*/
class implementation VSsrcBeam ;

#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "vsgetinpbynm.h"
/*----------------------------------------------------------------------------*/
method VSgetSupportSf(	long			*msg ;
			struct GRmd_env		*myEnv ;
			struct GRobj_env 	*sf ) {

	struct GRid	moi ;

	moi.objid = my_id ;
	moi.osnum = OM_Gw_current_OS ;
	return VSgetInputByName( msg, &moi, VS_K_bmSuppSurf,
				 &sf->_grid, &sf->mod_env ) ;

} /* method VSgetSupportSf */
/*----------------------------------------------------------------------------*/
method VSgetSupportAxis(	long			*msg ;
				struct GRmd_env		*myEnv ;
				struct GRobj_env 	*axis ) {

	struct GRid	moi ;

	moi.objid = my_id ;
	moi.osnum = OM_Gw_current_OS ;
	return VSgetInputByName( msg, &moi, VS_K_bmSuppAxis,
				 &axis->_grid, &axis->mod_env ) ;

} /* method VSgetSupportAxis */
/*----------------------------------------------------------------------------*/

end implementation VSsrcBeam ;

