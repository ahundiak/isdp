/*
	I/STRUCT
*/
class implementation VSfeature ;

#include "EMSutlmacros.h"
#include "vsdbgmacros.h"
/*----------------------------------------------------------------------------*/
method GRdrop( long *msg ; struct GRmd_env *myEnv ) {

	long		sts ;		/* OM return code		*/
	struct GRid	moi ;
	OM_S_CHANSELECT toCmps ;

	*msg	= MSSUCC ;

	moi.objid	= my_id ;
	moi.osnum	= OM_Gw_current_OS ;

	ems$make_chanselect( chan_label    = GRcmpowner_to_components,
	  		     chan_selector = &toCmps ) ;

	sts = om$send( msg	   = message GRconnector.GRdisconn( msg, &moi ),
		       p_chanselect= &toCmps ) ;
	__CheckRC( sts, *msg, "GRconnector.GRdisconn", wrapup ) ;

	sts = om$send(	msg	= message GRgraphics.GRdelete( msg, myEnv ),
			targetid= my_id ) ;
	__CheckRC( sts, *msg, "GRgraphics.GRdelete", wrapup ) ;

	wrapup :
		return sts ;

} /* method GRdrop */
/*----------------------------------------------------------------------------*/

end implementation VSfeature ;
