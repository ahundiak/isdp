/*
	I/STRUCT
*/
class implementation EMSsubbs ;

#include "OMmacros.h"
#include "msdef.h"
#include "EMSmsgdef.h"
#include "EMSssprops.h"
#include "vsgeommacros.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
/*----------------------------------------------------------------------------*/
long VSreverse_sf_orientation( msg, surfaceId, ignRevFlag )

/*
 * This function is interfaced by macro vs$reverse_sf_orientation.
 */
long		*msg ;
struct GRid	*surfaceId ;
int		ignRevFlag ; {

	long		sts ;	/* OM return code	*/
	unsigned char	props ;	/* Surface's properties	*/
	
	sts = om$send(	msg	= message EMSsubbs.EMget_props( msg, &props ),
			senderid= surfaceId->objid,
			targetid= surfaceId->objid,
			targetos= surfaceId->osnum ) ;
	__CheckRC( sts, *msg, "EMSsubbs.EMget_props", wrapup ) ;

	if( ignRevFlag || !( props & EMSIS_NRML_REVERSED ) ) {
		sts = om$send(	msg	= message EMSsurface.EMrevorient( msg ),
				senderid= surfaceId->objid,
				targetid= surfaceId->objid,
				targetos= surfaceId->osnum ) ;
		__CheckRC( sts, *msg, "EMSsurface.EMrevorient", wrapup ) ;
	}
	wrapup :
		return sts ;

} /* VSreverse_sf_orientation */
/*----------------------------------------------------------------------------*/

end implementation EMSsubbs ;
