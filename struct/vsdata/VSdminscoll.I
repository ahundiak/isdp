/*
	I/STRUCT
*/
class implementation VSdataMgr ;

#include <stdio.h>
#include "msdef.h"
#include "OMmacros.h"
#include "EMSmsgdef.h"
#include "vsmiscmacros.h"
#include "vsdatamacros.h"
#include "vsdbgmacros.h"
/*----------------------------------------------------------------------------*/
method VSinsertCollection(	long		*msg ;
				OM_S_OBJID	collection ;
				int		index ) {

	long			sts ;		/* OM return code	*/
	OM_S_CHANSELECT		toSharedData ;
	OM_S_CHANSELECT		toDataMgr ;

	*msg = MSSUCC ;

	toSharedData.type	= OM_e_addr ;
	toSharedData.u_sel.addr	= &me->toSharedData ;
	toDataMgr.type		= OM_e_name ;
	toDataMgr.u_sel.name    = "VSsharedData.toDataMgr" ;

	sts = om$send(	msg	= message Root.connect(
						toSharedData,
						0,
						collection,
						OM_Gw_current_OS,
						toDataMgr,
						index ),
			targetid= my_id ) ;
	__CheckRC( sts, 1, "Root.connect", wrapup ) ;

	wrapup :
		return sts ;

} /* method VSinsertCollection */
/*----------------------------------------------------------------------------*/

end implementation VSdataMgr ;
