/*
	I/STRUCT
*/
class implementation VSsomeObjcVw ;

#include "OMmacros.h"
#include "vsdbgmacros.h"

from GRnotify	import	GRntfyconn,
			GRntfydisconn ;
/*----------------------------------------------------------------------------*/
method setObjectToDisplay( struct GRid *theObjToDisplay ) {

	long		sts = OM_S_SUCCESS,
			msg ;
	struct GRid	listener,
			previousObj ;
	OM_S_CHANSELECT	toObjToDisp ;
	int		index		= OM_K_MAXINT ;
	IGRboolean	taggedConn	= FALSE ;

	listener.objid		= my_id ;
	listener.osnum		= OM_Gw_current_OS ;

	toObjToDisp.type	= OM_e_addr ;
	toObjToDisp.u_sel.addr	= &me->toObjToDisplay ;

	/*
	 * Disconnect first previous object if any.
	 */
	om$send(msg	= message VSsomeObjcVw.getObjectToDisplay(
								&previousObj ),
		targetid= my_id ) ;

	if( !IF_NULL_OBJID( &previousObj.objid ) ) {
		om$send(msg	= message GRnotify.GRntfydisconn(
								&msg,
								&listener,
								&toObjToDisp ),
			targetid= previousObj.objid,
			targetos= previousObj.osnum ) ;
	}

	sts = om$send(	msg	= message GRnotify.GRntfyconn(	&msg,
								&listener, 
								&toObjToDisp,
								&index,
								&taggedConn,
								NULL ),
			targetid= theObjToDisplay->objid,
			targetos= theObjToDisplay->osnum ) ;

	if( !( sts & 1 & msg ) ) sts = OM_W_ABORT ;

	return sts ;

} /* method setObjectToDisplay */
/*----------------------------------------------------------------------------*/

end implementation VSsomeObjcVw ;
