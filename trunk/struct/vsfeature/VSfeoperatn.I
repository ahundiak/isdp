/*
	I/STRUCT
*/
class implementation VSfeature ;

#include <stdlib.h>
#include "EMSmsgdef.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "vsvirtualinf.h"
/*----------------------------------------------------------------------------*/
method VSgetOperation(	long		*msg ;
			VSopHistory	*history ) {

	long		sts ;
	VSopHistory	myOperation,
			*p_myOperation = NULL ;
	struct GRid	myGRid ;

	myGRid.objid = myOperation.resultId	= my_id ;
	myGRid.osnum = myOperation.resultOs	= OM_Gw_current_OS ;

	VSgetVirtualInfo( msg, &myGRid, &myOperation.resultEnv, NULL ) ;

	myOperation.opCount	= 0 ;
	myOperation.opList	= NULL ;
	myOperation.next	= NULL ;

	sts = om$send(	msg	= message VSfeature.VSgetResultType(
						msg, &myOperation.resultType ),
			targetid= my_id ) ;
	__CheckRC( sts, *msg, "VSpart.VSgetResultType", wrapup ) ;

	if( myOperation.resultType & VS_m_IN_ASSEMBLY ) {
		/*
		 * Object is inside a macro occurrence.
		 */
		myOperation.opCount	= 0 ;
		myOperation.opList	= NULL ;
	} else {
		int	opCount ;
		sts = om$send(	msg	= message VSfeature.VSgetOperators(
							msg,
							&opCount,
							&myOperation.opList ),
				targetid= my_id ) ;
		__CheckRC( sts, *msg, "VSfeature.VSgetOperators", wrapup ) ;

		myOperation.opCount = opCount ;
	}
	if( p_myOperation = _MALLOC( 1, VSopHistory ) ) {
		*p_myOperation		= myOperation ;
		p_myOperation->next	= history->next ;
		history->next		= p_myOperation ;
		*msg	= MSSUCC ;
		sts	= OM_S_SUCCESS ;
	} else {
		*msg	= EMS_E_NoDynamicMemory ;
		sts	= OM_E_NODYNMEM ;
	}
	wrapup :
		if( !( sts & 1 & *msg ) ) {
			_FREE( p_myOperation ) ;
		}
		return sts ;

} /* method VSgetOperation */
/*----------------------------------------------------------------------------*/

end implementation VSfeature ;

