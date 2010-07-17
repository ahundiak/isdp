/*
	I/STRUCT
*/
class implementation VSsharedData ;

#include "madef.h"
/*
 * Includes of function prototypes.
 */
#include "maidmx.h"
/*----------------------------------------------------------------------------*/
method ASreturn_go(	struct GRid	*GOid ;
			short		*mxType ;
			IGRmatrix	mx ) {

	GOid->objid = my_id ;
	GOid->osnum = OM_Gw_current_OS ;

	if( mxType ) *mxType = MAIDMX ;
	if( mx ) {
		long msg ;
		MAidmx( &msg, mx ) ;
	}
	return OM_S_SUCCESS ;

} /* method ASreturn_go */
/*----------------------------------------------------------------------------*/

end implementation VSsharedData ;

