/*
	I/STRUCT
*/
class implementation VSdivFeature ;

#include "nddef.h"
#include "ndmacros.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
#include "EMSmsgdef.h"
/*----------------------------------------------------------------------------*/
method VSget_sub_features(	long		*msg ;
				int		*count ;
				struct GRid	features[VS_K_MAX_SUBS] ) {

	long		sts ;		/* OM return code		*/
	unsigned	subMask ;	/* Mask of sub-features		*/
	int		c,		/* Loop-on-children index	*/
			p,		/* Loop-on-sub-features index	*/
			nbChildren,	/* Count of my children		*/
			maxSubFeatures,	/* Maximum of sub-features	*/
			nbSF ;		/* Number of sub-features	*/
	struct GRid	*children ;	/* Buffer for children		*/

	*count = 0 ;

	/*
	 * Get children : VSsubFeatures.
	 */
	sts = om$send(	msg	= message NDnode.NDget_objects(
							ND_CHILDREN | ND_IN_BUF,
							NULL,
							0,
							&children,
							0,
							OM_K_MAXINT,
							&nbChildren ),
			targetid= my_id ) ;
	__CheckRC( sts, 1, "NDnode.NDget_objects", wrapup ) ;

	sts = om$send(	msg	= message VSdivFeature.VSgetSubMask(
					msg, &subMask, &nbSF, &maxSubFeatures ),
			targetid= my_id ) ;

	if( nbChildren < nbSF ) {
		/*
		 * We have unwanted children : we abort ! (Hee hee hee!)
		 */
		*msg = MSFAIL ; sts = OM_E_ABORT ; goto wrapup ;
	}
	
	*count = maxSubFeatures ;
	if( nbSF ) {

		int	j ;

		/*
		 * Copy children to the good slot. Put NULL_OBJID for
		 * sub-features which have disappeared.
		 */
		 for( j = c = p = 0 ; j < maxSubFeatures ; j++ ) {
	 		if( subMask & ( 1 << j ) ) {
	 			features[p++] = children[c++] ;
		 	} else {
		 		features[p++].objid = NULL_OBJID ;
		 	}
		}
	}

	wrapup :
		return sts ;

} /* method VSget_sub_features */
/*----------------------------------------------------------------------------*/

end implementation VSdivFeature ;
