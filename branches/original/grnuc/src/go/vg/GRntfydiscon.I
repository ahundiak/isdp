/* #######################    APOGEE COMPILED   ######################## */
/*
   GRntfydiscon.I
*/

class implementation GRnotify;

#include "grimport.h"
#include "msdef.h"
#include "godef.h"
#include "godef.h"
#include "gocmacros.h"

method GRntfydisconn(IGRlong *msg; struct GRid *listeners_id; 
	OM_S_CHANSELECT *listeners_chan)
{
    IGRlong  	OMmsg;			/* OM return value		*/
    OMuint	count;

    OM_S_CHANSELECT my_channel;

    *msg = MSSUCC;
    OMmsg = OM_S_SUCCESS;

    OMmsg = om$make_chanselect(
	p_chanselect = &my_channel,
	channame = "GRnotify.notification");

	if ( 1 & OMmsg )
	{
	    OMmsg = om$send(mode = OM_e_wrt_object,
		msg = message Root.disconnect(
		    *listeners_chan,my_id, OM_Gw_current_OS,my_channel),
		senderid = my_id,
		targetid = listeners_id->objid,
		targetos = listeners_id->osnum);

	    om$get_channel_count(
		p_chanselect = &my_channel,
		objid = my_id,
		count = &count);

	}
	else
	{
	    *msg = MSFAIL;
	}

    	GR_NOTIFY_LISTENERS(msg,&OMmsg,GR_CHANNEL_USED);

    	return(OMmsg);
}

end implementation GRnotify;
