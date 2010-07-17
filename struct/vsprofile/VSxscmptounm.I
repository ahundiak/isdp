/*
	I/STRUCT
*/
class implementation VSxscurve ;

#include "msdef.h"
#include "EMSmsgdef.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "vsnameproto.h"
/*----------------------------------------------------------------------------*/
method VStransCmpToUsrNm(	long		*msg ;
				int		cmpIx ;
				struct GRid	*cmpId ;
				GRname		cmpNm ; ) {

	long	sts ;		/* OM return code	*/
	int	usrIndex ;

	__DBGpr_int( "Component index", cmpIx ) ;

	sts = om$send(	msg	= message VScompcurve.VStransCmpToUsrIx(
						msg, cmpIx, cmpId, &usrIndex ),
			targetid= my_id ) ;
	__CheckRC( sts, *msg, "VScompcurve.VStransCmpToUsrIx", wrapup ) ;

	if( usrIndex < 0 ) {
		/*
		 * Curve has not been named: message returns the opposite of
		 * its component index.
		 */
		VSgenCmpName( -usrIndex,  cmpNm ) ;
	} else {
		sts = VStransFaceNumberToNm( msg, usrIndex, cmpNm ) ;
	}

	__DBGpr_str( "Component name", cmpNm ) ;

	wrapup :
		return sts ;

} /* method VStransCmpToUsrNm */
/*----------------------------------------------------------------------------*/

end implementation VSxscurve ;
