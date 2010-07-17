/*
	I/STRUCT

Abstract
	Provokes the recomputation of a part. This part may be the result of
	several consumptions. Upon reception of this message, the target will
	forward the recompute order to the part high up in the hierachy which
	is eligible for initiating a recompute.
	If target is eligible itself, it will then recompute.

Arguments
	long		*msg	completion code
	struct GRmd_env	myEnv	module environment of target
*/
 
class implementation VSfeature ;

#include "nddef.h"
#include "ndmacros.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
/*----------------------------------------------------------------------------*/
method VSregenerate() {

	long		sts ;		/* OM return code	*/
	struct GRid	target ;
	int		cn_type = ND_COMP ;

	sts = om$send(	msg	= message VSpart.VSifSourceThenSend(
							      VS_K_READ_OMmsg ),
			targetid= my_id ) ;


	if( sts == OM_I_STOP_SENDING ) {
	  target.objid = my_id ; target.osnum = OM_Gw_current_OS ;
	} else {
	  long rc ;
	  sts = om$send( msg	 = message VSfeature.VSforwardToSource(
					     &rc, OM_e_wrt_object,
					     message NDmacro.ACreturn_foot(
					        &rc,"", &target, NULL, NULL ) ),
			 targetid= my_id ) ;
	}				
	nd$wait_batch(	type		= GR_GEOM_POSTED,
			l_object	= &target,
			l_obj_info	= &cn_type,
			nb_obj		= 1 ) ;
						
	return sts ;

} /* method VSregenerate */
/*----------------------------------------------------------------------------*/

end implementation VSfeature ;

