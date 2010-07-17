/*
	I/STRUCT
*/
class implementation VSfeature ;

#include <stdlib.h>
#include "OMmacros.h"
#include "nddef.h"
#include "EMSmsgdef.h"
#include "vsmiscmacros.h"
#include "vsdatamacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "vsgetchildrn.h"
#include "vsstrngproto.h"
/*----------------------------------------------------------------------------*/
method VSgetVisDivRes(	long		*msg ;
			int		*count ;
			struct GRid	**divList ) {

	long		sts ;		/* OM return code	*/
	int		cnt ;

	*count = cnt = 0 ; *divList = NULL ;
	/*
	 * First count to alloc later (hence the NULL pointer).
	 */
	sts = om$send(	msg	= message VSfeature.VS__getVisDivRes(
							msg, &cnt, NULL ),
			targetid= my_id ) ;
	__CheckRC( sts, *msg, "VSfeature.VS__getVisDivRes", wrapup ) ;

	if( !( *divList = _MALLOC( cnt, struct GRid ) ) ) vs$mem_fail() ;

	sts = om$send(	msg	= message VSfeature.VS__getVisDivRes(
							msg, count, *divList ),
			targetid= my_id ) ;
	__CheckRC( sts, *msg, "VSfeature.VS__getVisDivRes", wrapup ) ;

	wrapup :
		if( !( sts & 1 & *msg ) ) {
			_FREE( *divList ) ; *divList = NULL ; *count = 0 ;
		}
		return sts ;

} /* method VSgetVisDivRes */
/*----------------------------------------------------------------------------*/
method VS__getVisDivRes(long		*msg ;
			int		*count ;
			struct GRid	*divList ) {

	long		sts,		/* OM return code		*/
			amConsumed ;	/* Am I consumed ?		*/
	struct GRid	*myChildren,	/* My children			*/
			moi,		/* My little self		*/
			virtChild ;	/* My virtual consuming child	*/
	int		cnt,		/* Count of children		*/
			isConsumer,	/* Is child a consumer		*/
			i ;		/* Loop index			*/

	myChildren	= NULL ;
	moi.objid	= my_id ;
	moi.osnum	= OM_Gw_current_OS ;

	sts = om$send(	msg	= message NDmacro.ACtest_consumed( &amConsumed),
			targetid= my_id ) ;
	__CheckRC( sts, 1, "NDmacro.ACtest_consumed", wrapup ) ;

	if( !( amConsumed & 1 ) ) {

		if( divList ) {
			divList[*count].objid = my_id ;
			divList[*count].osnum = OM_Gw_current_OS ;
		}
		(*count)++ ;

		*msg	= MSSUCC ;
		sts	= OM_S_SUCCESS ;

		goto wrapup ;
	}

	/*
	 * Send same message to consuming children. There is is generaly one
	 * consuming child but for divided features the division manager is
	 * consumed by all its children. Since the consuming children may not
	 * necessarily be a direct one (on my to-children channel), but
	 * interfaced to me via an ACpretend (if I am in a macro and child is
	 * not) or an ACpretendin (if I am  not in the same design file as my
	 * child) object, `VSgetChildren' gets all types of children (in same
	 * OS or in other OSes), and message `VSisChildConsumingMe' does the
	 * necessary magic to find the consuming VSfeature-kind of object.
	 */
	sts = VSgetChildren( msg, &moi, &cnt, &myChildren ) ;
	__CheckRC( sts, *msg, "VSgetChildren", wrapup ) ;

	if( !cnt ) {
		/*
		 * I am consumed with no children ? Something is really wrong !
		 */
		 *msg = MSFAIL ; sts = OM_W_ABORT ; goto wrapup ;
	}

	for( i = 0 ; i < cnt ; i++ ) {
		sts = om$send(
			msg	= message VSfeature.VSisChildConsumingMe(
							msg,
							myChildren + i,
							&isConsumer,
							&virtChild ),
			targetid= my_id ) ;
		__CheckRC( sts, *msg, "VSfeature.VSisChildConsumingMe", wrapup);

		if( isConsumer ) {

			/*
			 * This one consumes me, send him message !
			 */
			sts = om$send(	msg	= OPPmargs,
					targetid= virtChild.objid,
					targetos= virtChild.osnum ) ;
			__CheckRC( sts, *msg, "VS__getVisDivRes", wrapup ) ;

		} /* if */
	} /* for */

	*msg	= MSSUCC ;
	sts	= OM_S_SUCCESS ;

	wrapup :
		_FREE( myChildren ) ;

		return sts ;

} /* method VS__getVisDivRes */
/*----------------------------------------------------------------------------*/

end implementation VSfeature ;
