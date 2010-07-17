/*
	I/STRUCT
*/
class implementation VSdataMgr ;

#include <stdio.h>
#include "msdef.h"
#include "OMmacros.h"
#include "nddef.h"
#include "EMSmsgdef.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"

from	NDnode		import		NDchg_state,
					NDdelete ;
from	VSsharedData	import		VSputData ;
/*----------------------------------------------------------------------------*/
method VSgetCollection(	long		*msg ;
			int		count;
			VSdataDesc	data[] ;
			OM_S_OBJID	*collection ; ) {

	long	sts ;	/* OM return code			*/
	int	index ;	/* Index of collection on channel	*/

	*collection = NULL_OBJID ;

	sts = om$send(	msg	= message VSdataMgr.VSfindCollection(
					msg, count, data, collection, &index ),
			targetid= my_id ) ;
	__CheckRC( sts, *msg, "VSdataMgr.VSfindCollection", wrapup ) ;

	if( IF_NULL_OBJID( *collection ) ) {
		/*
		 * Construct a new one.
		 */
		extern OMuword	OPP_VSsharedData_class_id ;

		sts = om$construct(
			classid	= OPP_VSsharedData_class_id,
			osnum	= OM_Gw_current_OS,
			p_objid	= collection ) ;

		*msg = EMS_E_OMerror ;
		__CheckRC( sts, 1, "om$construct(VSsharedData)", wrapup ) ;

		/*
		 * Make it "support only".
		 */
		om$send(msg	= message NDnode.NDchg_state(	
						ND_WAIT_DEL | ND_DEL_NO_CH,
						ND_WAIT_DEL | ND_DEL_NO_CH ),
			targetid= *collection ) ;

		sts = om$send(	msg	= message VSsharedData.VSputData(
							msg, count, data ),
				targetid= *collection ) ;
		__CheckRC( sts, 1, "VSsharedData.VSputData", wrapup ) ;

		/*
		 * Insert collection on channel.
		 */
		sts = om$send(	msg	= message VSdataMgr.VSinsertCollection(
						msg, *collection, index ),
				targetid= my_id ) ;	
	}

	wrapup :
		if( !( *msg & 1 & sts ) && !IF_NULL_OBJID( *collection ) ) {
			om$send(msg	= message NDnode.NDdelete( NULL ),
				targetid= *collection ) ;
			*collection = NULL_OBJID ;
		}

		return sts ;

} /* method VSgetCollection */
/*----------------------------------------------------------------------------*/

end implementation VSdataMgr ;
