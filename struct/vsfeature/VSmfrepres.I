/*
	I/STRUCT

Abstract
	Puts/sets/gets NV representation to the part. Since this part comes in
	fact from an original un-end-treated part, the representation is in
	actually put to/set to/gotten from the original part.
*/
class implementation VSmodFeature ;


#omdef BUBBLE_UP( Message )
	om$send(	msg	= message VSfeature.VSsendToEveryoneUp(
							&Msg,
							OM_e_wrt_message,
							message Message ),
			targetid= my_id ) ;
#endomdef
#omdef BUBBLE_UP2( Message )
	om$send(	msg	= message Message,
			mode	= OM_e_wrt_message,
			targetid= my_id ) ;
#endomdef
#define bubble_up2
#include "vsdbgmacros.h"
/*----------------------------------------------------------------------------*/
method ACput_NV_rep( VSdspRep rep ) {

	long			sts ;		/* OM completion code	*/

	sts = BUBBLE_UP2( Message = ACncpx.ACput_NV_rep( rep ) ) ;

	return sts ;

} /* method ACput_NV_rep */
/*----------------------------------------------------------------------------*/
method ACset_NV_rep( VSdspRep rep ; struct GRmd_env *myEnv ) {

	long			sts,		/* OM completion code	*/
				Msg ;		/* Completion code	*/

	sts = BUBBLE_UP( Message = ACncpx.ACput_NV_rep( rep ) ) ;

	sts = om$send(
		msg	= message VSfeature.VSforwardToSource(
	 			&Msg,
				OM_e_wrt_object,
	 			message ACncpx.ACset_NV_rep( rep, myEnv ) ),
		targetid= my_id ) ;
	__CheckRC( sts, Msg, "VSfeature.VSforwardToSource", wrapup ) ;

	/*
	 * Since ACncpx has been optimized to do nothing if the new
	 * representation is the same as the old, it might well happen
	 * that this object does not get recomputed... So we force a
	 * change-node of the source feature.
	 * NOTE: should not put myEnv but source's env !!!
	 */

	sts = om$send(	msg	= message VSfeature.VSregenerate(),
			targetid= my_id ) ;
	__CheckRC( sts, Msg, "VSfeature.VSregenerate", wrapup ) ;

	wrapup :
		return sts ;

} /* method ACset_NV_rep */
/*----------------------------------------------------------------------------*/
method ACget_NV_rep( VSdspRep *p_rep ) {

	long			sts ;		/* OM completion code	*/

	sts = om$send(	msg	= message ACncpx.ACget_NV_rep( p_rep ),
			mode	= OM_e_wrt_message,
			targetid= my_id ) ;

	return sts ;

} /* method ACget_NV_rep */
/*----------------------------------------------------------------------------*/

end implementation VSmodFeature ;

