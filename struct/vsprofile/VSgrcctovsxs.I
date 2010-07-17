/*
	I/STRUCT
*/
class implementation VSxscurve ;

#include "OMmacros.h"
#include "msdef.h"
#include "EMSmsgdef.h"
#include "vsdbgmacros.h"
/*----------------------------------------------------------------------------*/
long VSmoveGRccToVSxs( msg, GRccId, mapArray )

/*
 * This function interfaced by macro vs$moveGRccToXSection
 */

long		*msg ;
struct GRid	*GRccId ;
int		mapArray[] ; {

	long	sts ;	/* OM return code	*/

	SetProc( VSmoveGRccToVSxs ) ; Begin ;

	__DBGpr_obj( "Input comp. cv.", *GRccId ) ;
#ifdef vsDEBUG
	ShowObj( GRccId ) ;
#endif
	sts = om$change_class(	osnum		= GRccId->osnum,
				objid		= GRccId->objid,
				classname	= "VSxscurve" ) ;
	if( sts & 1 ) {
#ifdef vsDEBUG
		__DBGpr_com( "New comp. cv." ) ;
		ShowObj( GRccId ) ;
#endif
		sts = om$send(	msg	= message VScompcurve.VSinitMapping(
								msg, mapArray ),
				senderid= GRccId->objid,
				targetid= GRccId->objid,
				targetos= GRccId->osnum ) ;

		if( sts & 1 & *msg ) *msg = EMS_I_ChangeClass ;
	} else *msg = EMS_E_OMerror ;

	End
	return sts ;

} /* VSmoveGRccToVSxs */
/*----------------------------------------------------------------------------*/

end implementation VSxscurve ;
