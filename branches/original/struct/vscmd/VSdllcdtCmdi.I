/*
	I/STRUCT
*/
class implementation VSdllcdtCmd ;

#include "vscmddef.h"

extern void VSrdbDelCachedDefs __(( void )) ;
/*----------------------------------------------------------------------------*/
method delRDBCache() {

	/*
	 * Delete cached ASCII data in transient object space, used by
	 * "Place/Modify Beam/Stiffener/Plate,etc." for speed purposes (ie.
	 * to not access the RDB all the time).
	 */
	VSrdbDelCache() ;
	/*
	 * Delete cached graphics and DB info in current model.
	 * (NOTE: this will not delete user-made composite profiles since they
	 * are stored in the active file when created and do not correspond to
	 * anything in the RDB).
	 */
	VSrdbDelCachedDefs() ;

	me->ret = VS_K_ACT_SUCCESS ;
	return OM_S_SUCCESS ;

} /* method delRDBCache */
/*----------------------------------------------------------------------------*/

end implementation VSdllcdtCmd ;
