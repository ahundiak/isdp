/*
	I/STRUCT
*/
class implementation VSornBeam ;

#include "OMerrordef.h"
#include "nddef.h"
#include "msdef.h"
#include "vsdbgmacros.h"
#include "vsmiscmacros.h"
/*----------------------------------------------------------------------------*/
method VSgetOrientation(	long	*msg ;
				int	*orientation ) {

	long		sts ;		/* OM return code		*/
	struct GRid	myParent ;	/* My parent beam		*/

	sts = om$send(	msg	= message VSfeature.VSgetConsumedParent(
							msg, &myParent, NULL ),
			targetid= my_id ) ;
	__CheckRC( sts, *msg, "VSfeature.VSgetConsumedParent", wrapup ) ;

	sts = om$send(	msg	= message VSpart.VSgetOrientation(
							msg, orientation ),
			targetid= myParent.objid,
			targetos= myParent.osnum ) ;
	__CheckRC( sts, *msg, "VSpart.VSgetOrientation", wrapup ) ;
						
	switch( *orientation ) {
		case VS_K_NatOrient : *orientation = VS_K_RevOrient ; break ;
		case VS_K_RevOrient : *orientation = VS_K_NatOrient ; break ;
	}

	wrapup :
		return sts ;

} /* method VSgetOrientation */
/*----------------------------------------------------------------------------*/
method VShasOrientation( int OMmsgType ) {

	long		sts,
			msg ;
	unsigned long	result ;

	sts = om$send(	msg	= message VSfeature.VSgetResultType(
								&msg, &result ),
			targetid= my_id ) ;
	if( sts & 1 & msg ) {
		if( result & VS_m_IN_ASSEMBLY ) {
			switch( OMmsgType ) {
				/*
				 * Read message: answer and pass up.
				 */
				case VS_K_READ_OMmsg	:
					sts = OM_I_STOP_SENDING ; break ;

				default			:
				/*
				 * Write message : don't answer and stop.
				 */
				case VS_K_WRITE_OMmsg	:
					sts = OM_E_ABORT   ; break ;
			}
		} else sts = OM_I_STOP_SENDING ;
	} else sts = OM_E_ERROR ;

	return sts ;

} /* method VShasOrientation */
/*----------------------------------------------------------------------------*/

end implementation VSornBeam ;
