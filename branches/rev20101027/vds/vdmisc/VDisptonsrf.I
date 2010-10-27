/*
	I/VDS	Copy
*/
class implementation EMSloopset ;

#include "msdef.h"
#include "bstypes.h"
#include "growner.h"
#include "EMSbnddef.h"
#include "EMSbnd.h"
#include "EMSopt.h"
#include "v_miscmacros.h"
#include "v_geommacros.h"
#include "v_dbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "bsdistptpt.h"
#include "EMSutlmacros.h"

from EMSsubbs	import	EMpratmpt ;
/*----------------------------------------------------------------------------*/
long VD_isPointOnSurface( msg, sfEnv, sfId, mkNatBdry, testPoint, inside )

long			*msg ;
struct GRmd_env		*sfEnv ;
struct GRid		*sfId ;
int			mkNatBdry ;
IGRpoint		testPoint ;
int			*inside ; {

	long			sts ;		/* OM return code	*/
	OM_S_OBJECT_LINKAGE	loopSet ;	/* Loop set's id	*/
	OM_S_CHANSELECT		toLoopSet ;	/* To-loopset channel	*/
	IGRpoint		project ;	/* Of test point	*/
	struct GRparms		parm ;		/* Of projected point	*/
	int			count ;		/* Of loop sets		*/
	struct EMSpartolbasis	tol ;
	struct EMSptloc_info 	location ;

	if( mkNatBdry ) {
		sts = vd_$make_natural_boundary(
				surfaceEnv	= sfEnv,
				surfaceId	= sfId,
				msg		= msg ) ;
		__CheckRC( sts, *msg, "vd_$make_natural_boundary", wrapup ) ;
	}

	ems$make_chanselect( chan_label    = EMSsubbs_to_loopset,
			     chan_selector = &toLoopSet ) ;

	sts = om$get_channel_objects(	osnum		= sfId->osnum,
					objid		= sfId->objid,
					p_chanselect	= &toLoopSet,
					list		= &loopSet,
					size		= 1,
					count		= (OMuint *) &count ) ;
	__CheckRC( sts, 1, "om$get_channel_objects", wrapup ) ;

 	/* Get point in u,v */
	sts = om$send(	msg	= message GRgraphics.GRptproject(
							msg,
							&sfEnv->_MATRIX_TYPE,
							sfEnv->_MATRIX,
							testPoint,
							project,
							&parm ),
			senderid= sfId->objid,
			targetid= sfId->objid,
			targetos= sfId->osnum ) ;
	__CheckRC( sts, *msg, "GRgraphics.GRptproject", wrapup ) ;

       /* If inside surface test with respect to boundary */
	if( count == 1 ) {
		double UV[2] ;
	
		UV[0]		= parm.u ;
		UV[1]		= parm.v ;
		location.options= 0 ;
		tol.is_valid	= FALSE ;
		tol.in_world	= FALSE ;
		tol.mattyp	= &sfEnv->_MATRIX_TYPE ;
		tol.mat    	= sfEnv->_MATRIX ;

		sts = om$send(	msg	= message EMSloopset.EMpt_location(
								msg,
								UV,
								&location,
								&tol ),
				senderid= loopSet.S_objid,
				targetid= loopSet.S_objid,
				targetos= loopSet.osnum ) ;
		__CheckRC( sts, *msg, "EMSloopset.EMpt_location", wrapup ) ;
	} else {
		double epsilon = 1.e-6 ;

		/* natural boundary */
		if(	parm.u < epsilon || parm.u > 1. - epsilon
		    ||	parm.v < epsilon || parm.v > 1. - epsilon )
			location.location = EMS_L_ONEDGE ;
		else	location.location = EMS_L_INAREA ;
	}

	switch( location.location ) {
		case EMS_L_ONEDGE : *inside = FALSE ; break ;
		case EMS_L_INAREA : *inside = TRUE  ; break ;
		case EMS_L_ONVRTX : *inside = FALSE ; break ;
		case EMS_L_INHOLE : *inside = FALSE ; break ;
		case EMS_L_UNKNWN : *inside = FALSE ; break ;
	}

	*msg = MSSUCC ;

	wrapup :
		return sts ;

} /* VD_isPointOnSurface */
/*----------------------------------------------------------------------------*/

end implementation EMSloopset ;
