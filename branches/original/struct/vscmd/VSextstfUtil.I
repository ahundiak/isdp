/*
	I/STRUCT
*/
class implementation VSextstfCmd ;

#include <stdio.h>
#include "OMmacros.h"
#include "nddef.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "vsgetaxofstf.h"

from VSfeature	import VSforwardToOriginal ;
from NDnode	import NDget_objects ;
from ACpretend	import ACfind_parent ;
/*----------------------------------------------------------------------------*/
long VSgetBeamAxisOfStiffener( msg, stiffener, beamAxis )

long			*msg ;
const struct GRid	*stiffener ;
struct GRid		*beamAxis ; {

	long		sts ;
	int		ACcount ;
	struct GRid	ACpretend ;

	/*
	 * Get root ACpretend #1 of given stiffener.
	 */
	sts = om$send( msg	= message VSfeature.VSforwardToOriginal(
				      msg,
				      OM_e_wrt_object,
				      message NDnode.NDget_objects( ND_ROOT,
								    &ACpretend,
								    1,
								    NULL,
								    1,
								    1,
								    &ACcount )),
		       senderid = stiffener->objid,
		       targetid = stiffener->objid,
		       targetos = stiffener->osnum ) ;
	__CheckRC( sts, *msg, "VSfeature.VSforwardToOriginal", wrapup ) ;

	/*
	 * Get beam axis from ACpretend #1.
	 */
	sts = om$send( msg	= message ACpretend.ACfind_parent(
							beamAxis, NULL, NULL ),
		       senderid = ACpretend.objid,
		       targetid = ACpretend.objid,
		       targetos = ACpretend.osnum ) ;
	__CheckRC( sts, 1, "ACpretend.ACfind_parent", wrapup ) ;

	wrapup :
		if( !(sts & 1 & *msg) ) beamAxis->objid = NULL_OBJID ;

		return sts ;

} /* VSgetBeamAxisOfStiffener */
/*----------------------------------------------------------------------------*/

end implementation VSextstfCmd ;
