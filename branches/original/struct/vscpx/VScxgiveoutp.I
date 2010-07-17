/*
	I/STRUCT
*/
class implementation VScpx ;

#include <string.h>
/*
 * Includes of function prototypes.
 */
#include "vsioproto.h"
/*----------------------------------------------------------------------------*/
method DIgive_output( char *output ) {

	long		sts,
			msg ;
	VSobjDef	objDef ;

	/*
	 * Pretty-print yourself in "Display Directory Command" form.
	 */
	sts = om$send(	msg 	= message VScpx.VSgetObjDef( &msg, &objDef ),
			targetid= my_id ) ;

	if( sts & 1 & msg ) {
		strcat( output, "[" ) ;
		strcat( output, VSmsgkey2string( objDef.info ) ) ;
		strcat( output, "]" ) ;
	} else {
		/*
		 * Just in case the messages failed ...
		 */
		strcat( output, "[]" ) ;
	}
	return OM_S_SUCCESS ;

} /* method DIgive_output */
/*----------------------------------------------------------------------------*/

end implementation VScpx ;

