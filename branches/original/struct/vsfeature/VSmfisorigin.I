/*
	I/STRUCT
*/
class implementation VSmodFeature ;

#include "OMmacros.h"
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

	myGRid.objid	= my_id ;
	myGRid.osnum	= OM_Gw_current_OS ;

	ASget_as_owner( &myGRid, &complex ) ;

	if( IF_NULL_OBJID( complex.objid ) ) {
		/*
		 * Will pass message up ?
		 */
		sts = sendToNonOrig ? OM_S_SUCCESS : OM_W_ABORT ;
	} else {
		/*
		 * If output  of a macro occurrence, we do not forward the
		 * message up to consumed parent (which is in the macro
		 * definition).
		 */
		switch( OMmsgType ) {
			/*
			 * Read message: answer and pass up.
			 */
			case VS_K_READ_OMmsg	:
				sts = sendToNonOrig ? OM_S_SUCCESS
						    : OM_W_ABORT ; break ;
			default			:
			/*
			 * Write message : don't answer and stop.
			 */
			case VS_K_WRITE_OMmsg	: sts = OM_E_ABORT   ; break ;
		}
	}
	return sts ;

} /* method VSisOriginal */
/*----------------------------------------------------------------------------*/

end implementation VSmodFeature ;
