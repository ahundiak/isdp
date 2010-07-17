/*
	I/STRUCT
*/
class implementation VSfeature ;

#include <string.h>
#include <math.h>
#include "grdpbdef.h"
#include "grdpb.h"
#include "fontdef.h"
#include "font.h"
#include "vsslcdef.h"
#include "vsslc.h"
#include "vsmiscmacros.h"
#include "vsdrwdef.h"
#include "vsdrw.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "vsdrwproto.h"

from ACcpx_defn	import ACgive_name ;
/*----------------------------------------------------------------------------*/
int VSdrwConstType( msg, constId, xData, constType )

long		  *msg ;	/* OUT: Completion code			*/
const struct GRid *constId ;	/* IN : Id of const (macro occurrence)	*/
VSdrwExecData	  *xData ;	/* IN : Data set during execution	*/
GRname		  constType ; {	/* OUT: Type of the construction	*/

	struct GRid	macDefId ;	/* Id of macro definition	*/
	char		*macDefName ;	/* Name of macro definition	*/

	*constType = '\0' ;

	*msg = om$send(	msg	= message ACcpx.find_macro( &macDefId ),
			senderid= constId->objid,
			targetid= constId->objid,
			targetos= constId->osnum ) ;

	if( !( *msg & 1 ) ) {
		/*
		 * Either the macro definition has been deleted or the macro
		 * library in which the macro definition lived is not here.
		 */
		if( xData->verbose ) {
			VSdrwPrintf( "!!! Cannot retrieve type of construction...\n" ) ;
			VSdrwPrintf( "!!! ... Macro library may be missing.\n" ) ;
		}
		goto wrapup ;
	}

	*msg = om$send(	msg	= message ACcpx_defn.ACgive_name( &macDefName ),
			senderid= macDefId.objid,
			targetid= macDefId.objid,
			targetos= macDefId.osnum ) ;
	if( !( *msg & 1 ) ) {
		if( xData->verbose ) {
			VSdrwPrintf( "!!! Error getting type of construction.\n" ) ;
		}
		goto wrapup ;
	}

	strncpy( constType, macDefName, GRNAME_SIZE - 1 )[GRNAME_SIZE-1] = '\0';

	wrapup :
		return *msg & 1 ;

} /* VSdrwConstType */
/*----------------------------------------------------------------------------*/

end implementation VSfeature ;


