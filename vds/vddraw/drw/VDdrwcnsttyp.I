/*
	I/VDS	Copy.
*/
class implementation VDSroot ;

#include <string.h>
#include <math.h>
#include "grdpbdef.h"
#include "grdpb.h"
#include "fontdef.h"
#include "font.h"
#include "v_slcdef.h"
#include "v_slc.h"
#include "v_miscmacros.h"
#include "v_drwdef.h"
#include "v_drw.h"
#include "v_miscmacros.h"
#include "v_dbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "v_drwproto.h"

from ACcpx_defn	import ACgive_name ;
/*----------------------------------------------------------------------------*/
int VD_drwConstType( msg, constId, xData, constType )

long		  *msg ;	/* OUT: Completion code			*/
const struct GRid *constId ;	/* IN : Id of const (macro occurrence)	*/
VD_drwExecData	  *xData ;	/* IN : Data set during execution	*/
GRname		  constType ; {	/* OUT: Type of the construction	*/

	struct GRid	macDefId ;	/* Id of macro definition	*/
	char		*macDefName ;	/* Name of macro definition	*/

	SetProc( VD_drwConstType ); Begin

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
			VD_drwPrintf( "!!! Cannot retrieve type of construction...\n" ) ;
			VD_drwPrintf( "!!! ... Macro library may be missing.\n" ) ;
		}
		goto wrapup ;
	}

	*msg = om$send(	msg	= message ACcpx_defn.ACgive_name( &macDefName ),
			senderid= macDefId.objid,
			targetid= macDefId.objid,
			targetos= macDefId.osnum ) ;
	if( !( *msg & 1 ) ) {
		if( xData->verbose ) {
			VD_drwPrintf( "!!! Error getting type of construction.\n" ) ;
		}
		goto wrapup ;
	}

	strncpy( constType, macDefName, GRNAME_SIZE - 1 )[GRNAME_SIZE-1] = '\0';

	wrapup :
		End
		return *msg & 1 ;

} /* VD_drwConstType */
/*----------------------------------------------------------------------------*/

end implementation VDSroot ;


