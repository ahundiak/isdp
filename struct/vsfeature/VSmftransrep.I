/*
	I/STRUCT
*/
class implementation VSmodFeature ;

#include "OMmacros.h"
#include "nddef.h"
#include "ndmacros.h"
#include "asbox.h"
#include "EMSmsgdef.h"
#include "vsmiscmacros.h"
#include "vsdatamacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "vsvirtualinf.h"
/*----------------------------------------------------------------------------*/
method VStransferRep(	long			*msg ;
			struct GRid		*realParent ;
			struct GRobj_env	*virtParent ) {

	long			sts ;		/* OM return code	*/
	VSdspRep		myRep ;
	struct GRobj_env	virtual ;

	sts = om$send(	msg	= message ACncpx.ACget_NV_rep( &myRep ),
			targetid= my_id ) ;
	__CheckRC( sts, 1, "ACncpx.ACget_NV_rep", wrapup ) ;

	if( !virtParent ) {
		virtParent = &virtual ;
		sts = VSgetVirtualInfo( msg, realParent, &virtual.mod_env,
					&virtual._grid ) ;
		__CheckRC( sts, *msg, "VSgetVirtualInfo", wrapup ) ;
	}

	/*
	 * NOTE : sent wrt message so that message will not bubble up.
	 */
	sts = om$send(	msg	= message ACncpx.ACset_NV_rep(
						myRep,	&virtParent->mod_env ),
			mode	= OM_e_wrt_message,
			targetid= virtParent->_objid,
			targetos= virtParent->_osnum ) ;
	__CheckRC( sts, 1, "ACncpx.ACset_NV_rep", wrapup ) ;

	wrapup :
		return sts ;

} /* method VStransferRep */
/*----------------------------------------------------------------------------*/

end implementation VSmodFeature ;
