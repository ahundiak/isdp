/*
	I/STRUCT
*/
class implementation VSplstifCmd ;

#include <stdio.h>
#include "vsdef.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"

from GRgraphics import GRgetrang ;
from VSfeature	import VSgetResultType ;
/*----------------------------------------------------------------------------*/
long VSgetHeightOfCrossSectionDef( msg, scId, scEnv, height )

long		*msg ;
struct GRid	*scId ;
struct GRmd_env *scEnv ;
double		*height ; {

	long		sts ;
	short		world = TRUE ;
	GRrange 	range ;

	*height = 0 ;

	/*
	 * Get range of cross section.
	 */
	sts = om$send( msg	= message GRgraphics.GRgetrang(
							   msg,
							   &scEnv->_MATRIX_TYPE,
							   scEnv->_MATRIX,
							   &world,
							   range ),
		       senderid = scId->objid,
		       targetid = scId->objid,
		       targetos = scId->osnum ) ;
	__CheckRC( sts, *msg, "GRgraphics.GRgetrang", wrapup ) ;

	/*
	 * Compute height of cross section.
	 */
	*height = range[4] - range[1] ;

	sts  = OM_S_SUCCESS ;
	*msg = MSSUCC ;

	wrapup :
		return sts ;

} /* VSgetHeightOfCrossSectionDef */
/*----------------------------------------------------------------------------*/

end implementation VSplstifCmd ;
