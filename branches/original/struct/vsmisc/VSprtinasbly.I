/*
	I/STRUCT
*/
class implementation VSfeature ;

#include <stdio.h>
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
/*----------------------------------------------------------------------------*/
int VSisPartInAssembly( msg, part ) long *msg ; struct GRid *part ; {

	long		sts ;
	struct GRid	real ;
	int		inAssembly ;
	unsigned long	res ;

	inAssembly = FALSE ;

	sts = om$send(	msg	= message NDmacro.ACreturn_foot(
						msg, "", &real, NULL, NULL ),
			senderid= part->objid,
			targetid= part->objid,
			targetos= part->osnum ) ;
	*msg = *msg ? MSSUCC : MSFAIL ;
	__CheckRC( sts, *msg, "NDmacro.ACreturn_foot", wrapup ) ;

	sts = om$send(	msg	= message VSfeature.VSgetResultType( msg, &res),
			senderid= part->objid,
			targetid= real.objid,
			targetos= real.osnum ) ;			
	__CheckRC( sts, *msg, "VSfeature.VSgetResultType", wrapup ) ;

	inAssembly = res & VS_m_IN_ASSEMBLY ;

	wrapup :
		return inAssembly ;

} /* VSisPartInAssembly */
/*----------------------------------------------------------------------------*/

end implementation VSfeature ;
