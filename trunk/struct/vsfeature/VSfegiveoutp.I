/*
	I/STRUCT
*/
class implementation VSfeature ;

#include <string.h>
/*
 * Includes of function prototypes.
 */
#include "vsioproto.h"
/*----------------------------------------------------------------------------*/
method DIgive_output( char *output ) {

	long		sts,
			msg,
			VSrc ;
	VSobjDef	objDef ;

	sts = om$send(	msg 	= message VSfeature.VSforwardToOriginal(
						&VSrc,
						OM_e_wrt_object,
						message VScpx.VSgetObjDef(
								&msg,
								&objDef ) ),
			targetid= my_id ) ;

	if( sts & VSrc & msg & 1 ) {
		strcat( output, "[" ) ;
		strcat( output, VSmsgkey2string( objDef.info ) ) ;
		strcat( output, "]" ) ;
	} else {
		strcat( output, "[]" ) ;
	}
	return OM_S_SUCCESS ;

} /* method DIgive_output */
/*----------------------------------------------------------------------------*/

end implementation VSfeature ;

