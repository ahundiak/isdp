/*
	I/STRUCT
*/
class implementation VSxscurve ;

#include "msdef.h"
#include "EMSutlmacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "vsnameproto.h"
/*----------------------------------------------------------------------------*/
method VStransUsrNmToCmp(	long		*msg ;
				GRname		cmpNm ;
				int		*p_cmpIndex ;
				struct GRid	*p_cmpId ) {

	long		sts ;		/* OM return code	*/
	int		usrIndex ;

	__DBGpr_str( "Component name", cmpNm ) ;

	if( VSreadGenericNameAcceptNegative( cmpNm, &usrIndex ) ) {
		OM_S_CHANSELECT toCmps ;

		/*
		 * Name is in the form "$<n>", where n is the component index.
		 */
		if( p_cmpIndex ) *p_cmpIndex = usrIndex ;

		if( p_cmpId ) {
			ems$make_chanselect( chan_label    = GRcmpowner_to_components,
	  				     chan_selector = &toCmps ) ;
			sts = om$get_objid_at_index(	
					objid		= my_id,
					p_chanselect	= &toCmps,
					index		= usrIndex,
					objidaddr	= &p_cmpId->objid,
					osnumaddr	= &p_cmpId->osnum ) ;
			if( !( sts & 1 ) ) { *msg = MSFAIL ; goto wrapup ; }
		}
		sts	= OM_S_SUCCESS ;
		*msg	= MSSUCC ;
	} else {
		sts = VStransFaceNmToNumber( msg, cmpNm, &usrIndex ) ;
		__CheckRC( sts, *msg, "VStransFaceNameToNumber", wrapup ) ;

		sts = om$send(	msg	= message VScompcurve.VStransUsrIxToCmp(
						msg, usrIndex,
						p_cmpIndex, p_cmpId ),
				targetid= my_id ) ;
	}

	wrapup :
		return sts ;

} /* method VStransUsrNmToCmp */
/*----------------------------------------------------------------------------*/

end implementation VSxscurve ;
