/*
	I/STRUCT
*/
class implementation VSfeature ;

#include "OMmacros.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
/*----------------------------------------------------------------------------*/
int VSgetConsumer( parent, count, children )

struct GRid	*parent,
		children[] ;
int		count ; {


	/*
	 * Among a list of children, finds the one who consumes `parent'
	 * (supposed to be a VSfeature).
	 */
	long		sts,
			msg ;
	int		i,
			index = -1 ;
	struct GRid	consumedId ;

	for( i = 0 ; i < count ; i++ ) {
		sts = om$send(	msg	= message VSfeature.VSgetConsumedParent(
						&msg, &consumedId, NULL ),
				senderid= children[i].objid,
				targetid= children[i].objid,
				targetos= children[i].osnum ) ;
		if( !( sts & 1 & msg ) ) continue ;
		if( IF_EQ_GRID( consumedId, *parent ) ) {
			index = i ;
			break ;
		}
	}

	return index ;

} /* VSgetConsumer */
/*----------------------------------------------------------------------------*/

end implementation VSfeature ;

