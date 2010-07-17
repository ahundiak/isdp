/* $Id: VSbaxdirCS.I,v 1.2 2001/02/22 17:14:05 ramarao Exp $  */
/* --------------------------------------------------------------------
 * I/STRUCT
 *
 * File:        struct/vsbmaxis/VSbaxdirCS.I
 *
 * Description: Function to get the direction of beam.
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VSbaxdirCS.I,v $
 *      Revision 1.2  2001/02/22 17:14:05  ramarao
 *      Fixed TR# 4529 and Added Header.
 *
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *      02/22/00        Rama Rao        Header Creation & Fixed TR# 4529.
 * -------------------------------------------------------------------*/

class implementation VSbeamAxis ;

#include <stdio.h>
#include "msdef.h"
#include "vsbmaxisdef.h"
#include "vsgeommacros.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "vsvecmxproto.h"
#include "vsvirtualinf.h"
/*----------------------------------------------------------------------------*/
method VSgetXdirectionForCrossSectionCS( long		*msg ;
					 int		*haveDir ;
					 IGRvector	xDir ) {

	/*
	 * This method returns in 'xDir', the available direction of the
	 * x-vector of the cross section CS.
	 * This direction is computed with respect to the the normal of the
	 * parent surface #1 of axis.
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

	long			sts ;
	int			ctype,
				rc ;
	struct GRid		ASsup1 ;
	struct GRobj_env	GRsup1 ;

	VSzerovc( xDir ) ;
	*haveDir = FALSE ;

	/*
	 * See if my parent #1 is a surface.
	 */
	sts = om$send( msg	= message VSbeamAxis.VSgetConstructionType(
							       msg, &ctype ),
		       targetid = my_id ) ;
	if( ctype == VS_K_baProjection || !(sts&1&(*msg) ) ) {
		/*
		 * Parent #1 is a curve: -> No direction found 
		 *	   OR
		 * Return always success. - TR# 4529
	      	 */
		sts = *msg = MSSUCC;
		goto wrapup ;
	}

	/*
	 * Get my parent surface #1.
	 */
	sts = om$send( msg	= message ACcpx.ACfind_temp_obj(
							      &rc,
							      VS_K_baSurfOrLine,
							      &ASsup1 ),
		       targetid = my_id ) ;
	*msg = rc & 1 ? MSSUCC : MSFAIL ;
	__CheckRC( sts, *msg, "ACcpx.ACfind_temp_obj", wrapup ) ;

	sts = VSgetVirtualInfo( msg,
				&ASsup1,
				&GRsup1.mod_env,
				&GRsup1._grid ) ;
	__CheckRC( sts, *msg, "VSgetVirtualInfo", wrapup ) ;

	/*
	 * Get normal of parent surface #1 which will be the direction of
	 * x-vector.
	 */
	sts = vs$get_normal( msg	= msg,
			     sfId	= &GRsup1._grid,
			     sfEnv	= &GRsup1.mod_env,
			     normal	= xDir ) ;
	__CheckRC( sts, *msg, "vs$get_normal", wrapup ) ;

	*haveDir = TRUE ;

	sts  = OM_S_SUCCESS ;
	*msg = MSSUCC ;

	wrapup :
		return sts ;

} /* method VSgetXdirectionForCrossSectionCS */
/*----------------------------------------------------------------------------*/

end implementation VSbeamAxis ;
