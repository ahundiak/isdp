/*
	I/STRUCT
	This method is OK for modified beams since VSget_support bubbles up.
*/
class implementation VSornBeam ;

#include "grerr.h"
#include "EMSmsgdef.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"

from	GRcurve		import	GRendpts ;
/*----------------------------------------------------------------------------*/
method VSgetSegmentEnds(	long		*msg ;
				struct GRmd_env	*myEnv ;
				IGRpoint	endp[2] ) {

	long			sts ;	/* OM completion code		*/
	struct GRobj_env	pBeam ;	/* Consumed parent beam		*/
	double			swap ;	/* Buffer to swap points	*/
	int			i ;	/* Loop index			*/

	/*
	 * Get segment ends from parent beam then swap them.
	 */
	sts = om$send(	msg	= message VSfeature.VSgetConsumedParent(
					msg, &pBeam._grid, &pBeam.mod_env ),
			targetid= my_id ) ;
	__CheckRC( sts, *msg, "VSfeature.VSgetConsumedParent", wrapup ) ;

	sts = om$send(	msg	= message VSbeam.VSgetSegmentEnds(
						msg, &pBeam.mod_env, endp ),
			targetid= pBeam._objid,
			targetos= pBeam._osnum ) ;
	__CheckRC( sts, *msg, "VSbeam.VSgetSegmentEnds", wrapup ) ;

	for( i = 0 ; i < 3 ; i++ ) {
		swap = endp[0][i] ; endp[0][i] = endp[1][i] ; endp[1][i] = swap;
	}


	wrapup :
		return sts ;

} /* method VSgetSegmentEnds */
/*----------------------------------------------------------------------------*/

end implementation VSornBeam ;

