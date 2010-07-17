/*
	I/STRUCT
*/
class implementation VSimgFeature ;

/*
 * Includes of function prototypes.
 */
#include "vselmsonsupp.h"
/*----------------------------------------------------------------------------*/
method VSgetSupportedElements(	long		*msg ;
				int		wantVisibleOnes,
						*count ;
				struct GRid	**list ) {

	long		sts ;		/* OM return code		*/
	unsigned long	myType ;	/* My structural type		*/
	struct GRid	myGRid ;	/* Moi ...			*/

	sts = om$send(	msg	= message VSfeature.VSgetResultType(
								msg, &myType ),
			targetid= my_id ) ;

	if( myType & VS_m_PLATE ) {
		myGRid.objid = my_id ;
		myGRid.osnum = OM_Gw_current_OS ;
		sts = VSgetElementsOnSupport( msg, &myGRid, VS_m_STF_BEAM,
						wantVisibleOnes, count, list ) ;
	} else {
		*count = 0 ; *list = NULL ; *msg = MSSUCC ; sts = OM_S_SUCCESS ;
	}

	return sts ;

} /* method VSgetSupportedElements */
/*----------------------------------------------------------------------------*/

end implementation VSimgFeature ;

