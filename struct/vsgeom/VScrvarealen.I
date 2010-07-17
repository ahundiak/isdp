/*
	I/STRUCT
*/
class implementation GRcurve ;

#include <stdio.h>
#include "OMminimum.h"
#include "msdef.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "gr.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
/*----------------------------------------------------------------------------*/
long VSlengthAndAreaOfClPlCv( msg, cvEnv, cvId, length, area )

long		*msg ;
struct GRmd_env	*cvEnv ;
struct GRid	*cvId ;
double		*length,
		*area ; {

	long		sts ;	/* OM return code	*/

	*length = *area = 0 ;

	sts = om$send(	msg	= message GRcurve.GRtotlength(
							msg,
							&cvEnv->_MATRIX_TYPE,
							cvEnv->_MATRIX,
							length ),
			senderid= cvId->objid,
			targetid= cvId->objid,
			targetos= cvId->osnum ) ;
	__CheckRC( sts, *msg, "GRcurve.GRtotlength", wrapup ) ;

	sts = om$send(	msg	= message GRcurve.GRarea(
							msg,
							&cvEnv->_MATRIX_TYPE,
							cvEnv->_MATRIX,
							area ),
			senderid= cvId->objid,
			targetid= cvId->objid,
			targetos= cvId->osnum ) ;
	__CheckRC( sts, *msg, "GRcurve.GRarea", wrapup ) ;

	wrapup :
		return sts ;

} /* VSlengthAndAreaOfClPlCv */
/*----------------------------------------------------------------------------*/

end implementation GRcurve ;
