/*
	I/STRUCT
*/
class implementation EMSedge ;

#include <stdlib.h>
#include "msdef.h"
#include "growner.h"
#include "vsdef.h"
#include "vs.h"
#include "vsweld.h"
#include "vsjointdef.h"
#include "vsjoint.h"
#include "vsmiscmacros.h"
#include "vsgeommacros.h"
#include "vsdatamacros.h"
#include "vsdbgmacros.h"
/*----------------------------------------------------------------------------*/
long VSgetEdgesByProps( msg, loopset, wprops, count, list )

long			*msg ;
struct GRid		*loopset ;
unsigned		wprops ;
int			*count ;
struct GRid		**list ; {

	long		sts ;
	int		size	= 0,
			edCnt 	= 0,
			i ;
	struct GRid	*edList	= NULL ;
	unsigned short	props ;

	*list = NULL ; *count = 0 ;

	sts = om$send(	msg	= message EMSboundary.EMget_edges(
					msg,
					OM_K_MAXINT, /* tree depth */
					EMS_OPT_ALL,
					&edList,
					&size,
					&edCnt ),
			senderid= loopset->objid,
			targetid= loopset->objid,
			targetos= loopset->osnum ) ;
	__CheckRC( sts, *msg, "EMSboundary.EMget_edges", wrapup ) ;

	if( !count ) vs$failure() ;

	if( !( *list = _MALLOC( edCnt, struct GRid ) ) ) vs$mem_fail() ;

	for( i = 0 ; i < edCnt ; i++ ) {
		sts = om$send(	msg	= message EMSedge.EMget_props(
								msg, &props ),
				senderid= NULL_OBJID,
				targetid= edList[i].objid,
				targetos= edList[i].osnum ) ;
		__CheckRC( sts, *msg, "EMSedge.EMget_props", wrapup ) ;

		if(     ( props & wprops )
		    || !( props & EMED_DEGENERATE ) ) {
		    	(*list)[(*count)++] = edList[i] ;
		}
	}
	if( !*count ) { _FREE( *list ) ; *list = NULL ; }

	sts	= OM_S_SUCCESS ;
	*msg	= MSSUCC ;

	wrapup :
		_FREE( edList ) ;
		if( !( sts & 1 & *msg ) ) {
			_FREE( *list ) ;
		}
		return sts ;

} /* VSgetEdgesByProps */
/*----------------------------------------------------------------------------*/

end implementation EMSedge ;

