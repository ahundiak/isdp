/*
	I/STRUCT
*/
class implementation VSdataMgr ;

#include "msdef.h"
#include "OMmacros.h"
#include "EMSmsgdef.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
/*----------------------------------------------------------------------------*/
method debug() {

	long		sts ;	/* OM return code	*/
	int		count ;
	OM_S_CHANSELECT	toSharedData ;

	toSharedData.type	= OM_e_addr ;
	toSharedData.u_sel.addr = &me->toSharedData ;
	sts = om$get_channel_count(	p_chanselect	= &toSharedData,
					count		= (OMuint *) &count,
					objid		= my_id ) ;

	printf( "*-* VSdataMgr [%2d, %4d]\n", OM_Gw_current_OS, my_id ) ;
	printf( "\tCount of collections %d\n", count ) ;
	printf( "\tList of collections:\n" ) ;

	sts = om$send(	msg		= message Root.debug(),
			p_chanselect	= &toSharedData ) ;

	printf( "\t\nEnd of list\n*-*\n" ) ;

	return sts ;

} /* method debug */
/*----------------------------------------------------------------------------*/

end implementation VSdataMgr ;
