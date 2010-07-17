/*
	I/STRUCT
*/
class implementation VSfeature ;

#include <string.h>
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
method VSgetVisibleObjByName(	long		*msg ;
				GRname		name ;
				struct GRid	*visibleId ) {

	long		sts,		/* OM return code	*/
			amConsumed ;	/* Am I consumed ?	*/
	struct GRid	*myChildren,	/* My children		*/
			moi,		/* My little self	*/
			virtChild ;	/* My virtual consuming
					    child		*/
	int		count,		/* Count of children	*/
			isConsumer,	/* Child is a consumer ?*/
			i ;		/* Loop index		*/

	myChildren	= NULL ;
	visibleId->objid= NULL_OBJID ;
	moi.objid	= my_id ;
	moi.osnum	= OM_Gw_current_OS ;

	sts = om$send(	msg	= message NDmacro.ACtest_consumed( &amConsumed),
			targetid= my_id ) ;
	__CheckRC( sts, 1, "NDmacro.ACtest_consumed", wrapup ) ;

	if( !( amConsumed & 1 ) ) {

		if( !name || !*name ) {
			/*
			 * No name input, return yourself (this may not be
			 * the good object in case of a divided feature ...)
			 */
			visibleId->objid = my_id ;
			visibleId->osnum = OM_Gw_current_OS ;
		} else { 
			GRname myName ;

			/*
			 * Check that `name' is my name.
			 */
			sts = om$send(	msg	= message GRgraphics.GRgetname(
								msg, myName ),
					targetid= my_id ) ;
			__CheckRC( sts, *msg, "GRgraphics.GRgetname", wrapup ) ;

			if( !strcmp( name, myName ) ) {
				visibleId->objid = my_id ;
				visibleId->osnum = OM_Gw_current_OS ;
			} /* else not me */
		}
		*msg	= MSSUCC ;
		sts	= OM_S_SUCCESS ;

		goto wrapup ;
	}

	/*
	 * Send same message to consuming children. There is is generaly one
	 * consuming child but for divided features the division manager is
	 * consumed by all its children. Since the consuming children may not
	 * necessarily a direct one (on my to-children channel), but interfaced
	 * to me via an ACpretend (if I am in a macro and child is not) or
	 * an ACpretendin (if I am  not in the same design file as my child)
	 * object, `VSgetChildren' get all types of children (in same OS or
	 * in other OSes), and message `VSisChildConsumingMe' does the necessary
	 * magic to find the consuming VSfeature-kind of object.
	 */
	sts = VSgetChildren( msg, &moi, &count, &myChildren ) ;
	__CheckRC( sts, *msg, "VSgetChildren", wrapup ) ;

	if( !count ) {
		/*
		 * I am consumed with no children ? Something is really wrong !
		 */
		 *msg = MSFAIL ; sts = OM_W_ABORT ; goto wrapup ;
	}

	for( i = 0 ; i < count ; i++ ) {

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
			 * This one is a consumer, send it message !
			 */
			sts = om$send(	msg	= OPPmargs,
					targetid= virtChild.objid,
					targetos= virtChild.osnum ) ;
			__CheckRC( sts, *msg, "VSgetVisibleObjByName", wrapup );

			if( !IF_NULL_OBJID( visibleId->objid ) ) {
				/*
				 * We have it.
				 */
				break ;
			}
		} /* if */
	} /* for */

	*msg	= MSSUCC ;
	sts	= OM_S_SUCCESS ;

	wrapup :
		_FREE( myChildren ) ;

		return sts ;

} /* method VSgetVisibleObjectByName */
/*----------------------------------------------------------------------------*/

end implementation VSfeature ;
