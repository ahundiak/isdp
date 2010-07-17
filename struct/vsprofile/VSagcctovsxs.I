/*
	I/STRUCT
*/
class implementation VSxscurve ;

#include "OMmacros.h"
#include "msdef.h"
#include "EMSmsgdef.h"
#include "vsdbgmacros.h"
/*----------------------------------------------------------------------------*/
long VSmoveAGccToVSxs( msg, AGccId, mapArray )

/*
 * This function interfaced by macro vs$moveAGccToXSection
 */

long		*msg ;
struct GRid	*AGccId ;
int		mapArray[] ; {

	long	sts ;	/* OM return code	*/

	SetProc( VSmoveAGccToVSxs ) ; Begin ;

	__DBGpr_obj( "Input comp. cv.", *AGccId ) ;
#ifdef vsDEBUG
	ShowObj( AGccId ) ;
#endif
	sts = om$change_class(	osnum		= AGccId->osnum,
				objid		= AGccId->objid,
				classname	= "VSxscurveAG" ) ;
	if( sts & 1 ) {
#ifdef vsDEBUG
		__DBGpr_com( "New comp. cv." ) ;
		ShowObj( AGccId ) ;
#endif
		sts = om$send(	msg	= message VScompcurve.VSinitMapping(
								msg, mapArray ),
				senderid= AGccId->objid,
				targetid= AGccId->objid,
				targetos= AGccId->osnum ) ;

		if( sts & 1 & *msg ) *msg = EMS_I_ChangeClass ;
	} else *msg = EMS_E_OMerror ;

	End
	return sts ;

} /* VSmoveAGccToVSxs */
/*----------------------------------------------------------------------------*/

end implementation VSxscurve ;
