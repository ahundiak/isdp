/*
	I/STRUCT
*/
class implementation VSplate ;

/*
 * Includes of function prototypes.
 */
#include "vselmsonsupp.h"
/*----------------------------------------------------------------------------*/
method VSgetSupportedElements(	long		*msg ;
				int		wantVisibleOnes,
						*count ;
				struct GRid	**list ) {

	struct GRid	myGRid ;	/* Moi ...			*/

	myGRid.objid = my_id ;
	myGRid.osnum = OM_Gw_current_OS ;
	return VSgetElementsOnSupport( msg, &myGRid, VS_m_STF_BEAM,
					wantVisibleOnes, count, list ) ;

} /* method VSgetSupportedElements */
/*----------------------------------------------------------------------------*/

end implementation VSplate ;

