/*
	I/STRUCT
*/
class implementation VSfeature ;

#include "DIdef.h"
#include "vsdbgmacros.h"
/*----------------------------------------------------------------------------*/
method dump(	int		*DImsg ;
		char		*regExp ;
		OM_p_CLASSLIST  classList ;
		char		***lines ;
		DIgrid		**grids ;
		int		*count ;
		char		options ) {

	long		sts,	/* OM return code	*/
			msg ;
	GRname		myName ;
	struct GRid	visObj ;

	if( options & OPT_SYS ) {
		*count	= 0 ; msg = MSSUCC ; sts = OM_S_SUCCESS ;
		goto wrapup ;
	}

	/*
	 * This is a directory-dump, if I am consumed, some of my members do
	 * not have the right values: I am represented by the feature at the
	 * bottom of the consume hierarchy which has right member values,
	 * and to the user, is me. But since I bear the name for everybody,
	 * I got the dump message.
	 */

	/*
	 * If I got this message, the I must have a name.
	 */
	sts = om$send(	msg	= message GRgraphics.GRgetname( &msg, myName ),
			targetid= my_id ) ;
	__CheckRC( sts, msg, "GRgraphics.GRgetname", wrapup ) ;

	/*
	 * Find visible feature at the bottom of the consume hierarchy,
	 * if any.
	 */
	sts = om$send(	msg	= message VSfeature.VSgetVisibleObjByName(
							&msg, myName, &visObj ),
			targetid= my_id ) ;
	__CheckRC( sts, msg, "VSfeature.VSgetVisibleObjByName", wrapup ) ;

	/*
	 * Now send dump to visible object with respect to message,
	 * since visible object being of a class sub-class of VSfeature,
	 * it would re-start this very process if sent with respect to
	 * object.
	 * NOTE : the visible object may be me if I am not consumed.
	 */
	sts = om$send(	msg	= message ACncpx.dump(	DImsg,
							regExp,
							classList,
							lines,
							grids,
							count,
							options ),
			mode	= OM_e_wrt_message,
			targetid= visObj.objid,
			targetos= visObj.osnum ) ;
	if( !( sts & 1 & *DImsg ) ) {
		/*
		 * Some trouble somewhere, send to self wrt message.
		 */

		sts = om$send(	msg	= message ACncpx.dump(
							DImsg,
							regExp,
							classList,
							lines,
							grids,
							count,
							options ),
				mode	= OM_e_wrt_message,
				targetid= my_id ) ;
		msg = *DImsg & 1 ? MSSUCC : MSFAIL ;
	}

	wrapup :
		if( sts & 1 ) {
			*DImsg = msg & 1 ? DIR_S_SUCCESS : DIR_E_ABORT ;
		} else {
			*DImsg = DIR_E_ABORT ;
		}
		return sts ;

} /* method dump */
/*----------------------------------------------------------------------------*/

end implementation VSfeature ;
