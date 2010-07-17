/*
	I/STRUCT
*/
class implementation VSfeature ;

#include "vsdbgmacros.h"
/*----------------------------------------------------------------------------*/
method GRlocate(	struct GRlc_cvl	*cvl ;
			OM_p_KEY_DESC	rangeKey ) {

	/*
	 * This message will only be received by source or sub-features which
	 * are the only ones having a name.
	 */

	long	sts ;	/* OM return code	*/

	if( cvl && cvl->locate_args && GR_nam_loc == cvl->locate_args->type ) {
		/*
		 * This is a locate-by-name: if I am consumed, I have no
		 * graphics: I am represented by the feature at the bottom of
		 * the consume hierarchy which has graphics, and to the user,
		 * is me. But since I bear the name for everybody, I got the
		 * GRlocate (by name) message.
		 */
		GRname		myName ;
		struct GRid	visObj ;
		long		*msg = &cvl->msg ;

		/*
		 * If I got this message, the I must have a name.
		 */
		sts = om$send(	msg	= message GRgraphics.GRgetname(
								msg, myName ),
				targetid= my_id ) ;
		__CheckRC( sts, *msg, "GRgraphics.GRgetname", ANCESTOR_MSG ) ;

		/*
		 * Find visible feature at the bottom of the consume hierarchy,
		 * if any.
		 */
		sts = om$send(
			msg	= message VSfeature.VSgetVisibleObjByName(
							msg, myName, &visObj ),
			targetid= my_id ) ;
		__CheckRC( sts, *msg, "VSfeature.VSgetVisibleObjByName", ANCESTOR_MSG ) ;

		/*
		 * Now send GRlocate to visible object with respect to message,
		 * since visible object being of a class sub-class of VSfeature,
		 * it would re-start this very process if sent with respect to
		 * object.
		 * NOTE : the visible object may be me if I am not consumed.
		 */
		sts = om$send(	msg	= message ACncpx.GRlocate( cvl, rangeKey ),
				mode	= OM_e_wrt_message,
				targetid= visObj.objid,
				targetos= visObj.osnum ) ;
	} else {
		/*
		 * Other type of locate, invoke ancestor's method.
		 */
		ANCESTOR_MSG :
		sts = om$send(	msg	= message ACncpx.GRlocate( cvl, rangeKey ),
				mode	= OM_e_wrt_message,
				targetid= my_id ) ;
	}

	return sts ;

} /* method GRlocate */
/*----------------------------------------------------------------------------*/

end implementation VSfeature ;
