/*
	I/STRUCT
*/
class implementation VSbeam ;

#include <stdio.h>
#include "msdef.h"
#include "EMSmsgdef.h"
#include "vsdef.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "vsgetaxofstf.h"
#include "vsvecmxproto.h"

from VSbeamAxis import VSgetXdirectionForCrossSectionCS ;
/*----------------------------------------------------------------------------*/
method VSgetXdirectionForCrossSectionCS( long		*msg ;
					 int		*haveDir ;
					 IGRvector	xDir ) {

	/*
	 * This method returns in 'xDir', the available direction of the
	 * x-vector of STIFFENER cross section CS.
	 * This direction is computed with respect to the the normal of the
	 * parent surface #1 of the axis.
	 *
	 *			/|
	 *		       / |
	 *		      /  |
	 *		     /	 |
	 *		    /(n) /	      <- Parent surface #1 of axis.
	 *		   / -> /
	 *		   |   /
	 *		   |  /
	 *		   | /
	 *		   |/
	 *
	 *
	 *		 -----------------
	 *		/	/(a)	/|    <- (a) axis.
	 *	       /       /       / /
	 *	      /       /       / /
	 *	     /	  y^ ^z      / /      <- Plate.
	 *	    /	   |/	    / /
	 *	   /	   .-> x   / /	      <- Coodinate of the cross section
	 *	  ----------------- /		 with the available direction
	 *	  |		  |/		 for the x-vector.
	 *	  -----------------
	 *
	 *
	 * The available direction for the x-vector is the same as the normal
	 * of the parent surface #1. If the parent #1 of axis is a curve, we
	 * cannot compute the direction, so '*haveDir' will be FALSE, otherwise
	 * '*haveDir' will be TRUE.
	 */

	long		sts ;
	unsigned long	type,
			attr ;
	struct GRid	my_grid,
			my_axis ;

	VSzerovc( xDir ) ;
	*haveDir = FALSE ;

	/*
	 * See if I'm a stiffener.
	 */
	sts = om$send( msg	= message VSpart.VSgetUserEditableAttr( msg,
									&type,
									&attr ),
		       targetid = my_id ) ;

	__CheckRC( sts, *msg, "VSpart.VSgetUserEditableAttr", wrapup ) ;

	if( type != VS_m_STF_BEAM ) {
		goto wrapup ;
	}

	/*
	 * Get my original axis.
	 */
	my_grid.objid = my_id ;
	my_grid.osnum = OM_Gw_current_OS ;

	sts = VSgetBeamAxisOfStiffener( msg,
					&my_grid,
					&my_axis ) ;
	if( !( sts & 1 & *msg ) ) {
		/*
		 * If you fail, pretend you have no direction.
		 */
		*msg = EMS_I_Fail ; sts = OM_S_SUCCESS ; goto wrapup ;
	}

	/*
	 * Get available direction for x-vector of cross section CS from axis.
	 */
	sts = om$send( msg	=
		   message VSbeamAxis.VSgetXdirectionForCrossSectionCS( msg,
									haveDir,
									xDir ),
		       targetid = my_axis.objid,
		       targetos = my_axis.osnum ) ;
	__CheckRC( sts, *msg, "VSbeamAxis.VSgetXdirectionForCrossSectionCS",
		   wrapup ) ;

	sts  = OM_S_SUCCESS ;
	*msg = MSSUCC ;

	wrapup :
		return sts ;

} /* method VSgetXdirectionForCrossSectionCS */
/*----------------------------------------------------------------------------*/

end implementation VSbeam ;
