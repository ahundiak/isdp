/*
	I/STRUCT
*/
class implementation VSsomeObjcVw ;

#include "godef.h"
/*----------------------------------------------------------------------------*/
method GRnotifylis(	long		*msg ;
			long		*OMmsg ;
			long		*mask ;
			OM_S_MESSAGE	*graphics_msg ) {

	if( *mask & GR_DELETED ) {
		OM_S_CHANSELECT	toParent ;

		/*
		 * Delete parent window.
		 */
		toParent.type		= OM_e_addr ;
		toParent.u_sel.addr	= &me->to_parent ;

		om$send(	msg		= message Root.delete( 0 ),
				p_chanselect	= &toParent ) ;
	}
	*msg = MSSUCC ;

	return ( *OMmsg = OM_S_SUCCESS ) ;

} /* message GRnotifylis */
/*----------------------------------------------------------------------------*/

end implementation VSsomeObjcVw ; 
