/*
	I/VDS	Copy
*/
class implementation EMSsurface ;

#include "OMmacros.h"
#include "msdef.h"
#include "EMSmsgdef.h"
#include "v_geommacros.h"
#include "v_miscmacros.h"
#include "v_dbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "EMSutlmacros.h"
/*----------------------------------------------------------------------------*/
long VD_make_natural_boundary( msg, sfEnv, sfId )

/*
 * This function is interfaced by macro vd_$make_natural_boundary.
 */

long			*msg ;
struct GRmd_env		*sfEnv ;
struct GRid		*sfId ; {

	long			sts ;		/* OM return code	*/
	OM_S_CHANSELECT		toLoopSet ;	/* To-loopset channel	*/
	int			lsCount ;	/* Count of loop sets	*/

	ems$make_chanselect( chan_label    = EMSsubbs_to_loopset,
			     chan_selector = &toLoopSet ) ;

	*msg = EMS_E_OMerror ;
	sts = om$get_channel_count(	objid		= sfId->objid,
					osnum		= sfId->osnum,
					p_chanselect	= &toLoopSet,
					count		= (OMuint *) &lsCount ) ;
	__CheckRC( sts, 1, "om$get_channel_count", wrapup ) ;

	if( !lsCount ) {

		sts = om$send(	msg	= message EMSsurface.EMmk_nat_bdry(
						msg, &sfEnv->md_env, NULL ),
				senderid= sfId->objid,
				targetid= sfId->objid,
				targetos= sfId->osnum ) ;
		if( !( *msg & 1 ) ) *msg = EMS_E_SurfaceError ;
		__CheckRC( sts, *msg, "EMSsurface.EMmk_nat_bndry", wrapup ) ;

	} else *msg = MSSUCC ;

	wrapup :
		return sts ;

} /* VD_make_natural_boundary */
/*----------------------------------------------------------------------------*/

end implementation EMSsurface ;
