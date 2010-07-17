/*
	I/STRUCT
*/
class implementation VScpx ;

#include <stdlib.h>
#include "nddef.h"
#include "ndmacros.h"
#include "EMSmsgdef.h"
#include "vsdatamacros.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "vsstrngproto.h"
/*----------------------------------------------------------------------------*/
method VSwhoIsDying(	long		*msg ;
			int		*index ;
			struct GRid	*parent ; ) {

	/*
	 * NOTE: this method, which was very useful in 1.4 is much less so
	 * in 2.x since NDis_waiting will not always work. Nonetheless we
	 * now receive a NDnode.NDparent_deleted message (new 2.x feature)
	 * notifying us when one of our parent is being deleted.
	 */

	long		sts ;		/* OM return code	*/
	int		size,		/* For memory copies	*/
			i,		/* Loop index		*/
			nbRoots,	/* Count of my roots	*/
			*delIndex ;	/* Of parents in del. Q	*/
	struct GRid	*myRoots ;	/* List of my roots	*/

	/*
	 * Queries object for which of its parents is dying (this message is
	 * useful when the object receives a move-to-root triggered by the
	 * deletion of one of its parents, and it wants to have a different
	 * behavior based on which parent is being deleted ).
	 */

	delIndex = NULL ;
	myRoots  = NULL ;
	*msg	 = MSFAIL ;
	sts	 = OM_E_ABORT ;

	sts =  om$send(	msg	= message NDnode.NDget_objects(
							ND_ROOT | ND_IN_BUF,
							NULL,
							0,
							&myRoots,
							0,
							OM_K_MAXINT,
							&nbRoots ),
			targetid= my_id ) ;
	__CheckRC( sts, 1, "NDnode.NDget_objects", wrapup ) ;

	/*
	 * Move data from volatile cache buffer to private one.
	 */
	size = nbRoots * sizeof *myRoots ;
	if(    !( myRoots = (struct GRid *) VSmemdup( myRoots, size ) )
	    || !( delIndex = _MALLOC( nbRoots, int ) ) ) {
		vs$mem_fail() ;
	}

	for( i = 0 ; i < nbRoots ; i++ ) { delIndex[i] = -1 ; }

	sts = NDis_waiting(	GR_DELETED,
				0,
				myRoots,
				delIndex,
				NULL,	/* Don't want names	*/
				NULL,	/* Don't want info	*/
				nbRoots ) ;
	__CheckRC( sts, 1, "NDis_waiting", wrapup ) ;

	for( i = 0 ; i < nbRoots ; i++ ) {

		if( delIndex[i] != -1 ) {
			/*
			 * Parent to be deleted.
			 */
			*index = i ;
			*parent = myRoots[i] ;
		}
	}

	*msg	 = MSSUCC ;
	sts	 = OM_S_SUCCESS ;

	wrapup :
		_FREE( delIndex ) ; _FREE( myRoots ) ;
		return sts ;

} /* method VSwhoIsDying */
/*----------------------------------------------------------------------------*/

end implementation VScpx ;
