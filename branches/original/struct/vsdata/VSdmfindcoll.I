/*
	I/STRUCT
*/
class implementation VSdataMgr ;

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "msdef.h"
#include "OMmacros.h"
#include "EMSmsgdef.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
#include "vsdatamacros.h"

extern long		VSpackData() ;

from	VSsharedData	import		VSgetMemoryContent ;
/*----------------------------------------------------------------------------*/
method VSfindCollection(long		*msg ;
			int		count;
			VSdataDesc	data[] ;
			OM_S_OBJID	*collection ;
			int		*p_index ) {

	long		sts ;	/* OM return code			*/
	int		nbcoll,	/* Of collections on the channel	*/
			min,
			max,
			old,
			found,
			index,
			colsize,
			new,
			n ;
	unsigned	newsize ;
	char		*newdata = NULL,
			*coldata = NULL ;
	OM_S_CHANSELECT toSharedData ;

	*collection = NULL_OBJID ; *p_index = -1 ;

	*msg = EMS_E_OMerror ;

	toSharedData.type	= OM_e_addr ;
	toSharedData.u_sel.addr = &me->toSharedData ;

	sts = om$get_channel_count(	p_chanselect	= &toSharedData,
					objid		= my_id,
					count		= (OMuint *) &nbcoll ) ;
	__CheckRC( sts, 1, "om$get_channel_count", wrapup ) ;

	/*
	 * Format input data so as to make them comparable.
	 */
	sts = VSpackData(	msg,
				count,
				data,
				&newdata,
				(VSdataLoc **) NULL,
				&newsize ) ;
	__CheckRC( sts, *msg, "VSpackData", wrapup ) ;

	min = 0 ; max = nbcoll ; index = -1 ; found = FALSE ; new = 0 ;
	if( nbcoll ) do {
		old = index ;
		index = ( min + max ) / 2 ;

		if( old == index ) {
			found = FALSE ; 
			break ;
		}
		/*
		 * Inquire collection for its data.
		 */			
		sts = om$send(
			msg	= message VSsharedData.VSgetMemoryContent(
							msg,
							&colsize,
							&coldata ),
			p_chanselect	= &toSharedData,
			from		= index,
			to		= index ) ;

		/*
		 * Memory areas may have different sizes, take the minimum.
		 */
		n = colsize ; if( n > newsize ) n = newsize ;
		n = memcmp( newdata, coldata, n ) ;

		if( !n ) {
			if( colsize < newsize ) {
				max = index ; new = index - 1 ;
			} else if( colsize > newsize ) {
				min = index ; new = index + 1 ;
			} else found = TRUE	;
		} else {
			if( n < 0 ) {
				max = index ; new = index - 1 ;
			} else /* n > 0 */ {
				min = index ; new = index + 1 ;
			}
		}

	} while( !found ) ;

	if( found ) {
		OMuword	osnum ;

		om$get_objid_at_index(	p_chanselect	= &toSharedData,
					objid		= my_id,
					index		= index,
					objidaddr	= collection,
					osnumaddr	= &osnum ) ;

		*p_index = index ;
	} else {
		/*
		 * Return index where new entry should be inserted.
		 * It ranges between -1 and count.
		 */
		if( new == -1 ) new = 0 ;

		*p_index = new ;
	}
	wrapup :
		_FREE( newdata ) ; _FREE( coldata );
		return sts ;

} /* method VSfindCollection */
/*----------------------------------------------------------------------------*/

end implementation VSdataMgr ;
