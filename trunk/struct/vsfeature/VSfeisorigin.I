/*
	I/STRUCT
*/
class implementation VSfeature ;

#include "OMmacros.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "ASsupport.h"
/*----------------------------------------------------------------------------*/
method VSisOriginal( int sendToNonOrig, OMmsgType ) {

	long		sts ;
	struct GRid	complex,
			myGRid ;

	/*
	 * This method implements the behavior for source features.
	 */

	myGRid.objid	= my_id ;
	myGRid.osnum	= OM_Gw_current_OS ;

	ASget_as_owner( &myGRid, &complex ) ;

	if( IF_NULL_OBJID( complex.objid ) ) {
		sts = OM_I_STOP_SENDING ;
	} else {
		/*
		 * If output of a macro occurrence, we do not forward the message
		 * up to consumed parent (which is in the macro definition).
		 */
		switch( OMmsgType ) {
			/*
			 * Read message: answer and stop.
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
	}

	return sts ;

} /* method VSisOriginal */
/*----------------------------------------------------------------------------*/

end implementation VSfeature ;

