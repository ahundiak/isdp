/* #######################    APOGEE COMPILED   ######################## */
class implementation GRnotify;

#include "grimport.h"
#include "grerr.h"

/*
Abstract: 
	This method connects the graphics object and the notification
	listener.

Arguments	
     *listeners_id    struct GRid	the listeners objid, osnum
     *listeners_chan  OM_S_CHANSELECT	the listeners channel
     *msg	      IGRlong	 	completion code

Return Values
    	- MSSUCC if successful
	- MSFAIL error occurred
*/

method GRntfyconn(IGRlong *msg; struct GRid *listeners_id; 
	OM_S_CHANSELECT *listeners_chan)
{
    *msg = GRINVMSG;
    return (OM_E_ABORT);
}

/*
Abstract: 
	This method disconnects the graphics object and the notification
	listener.

Arguments	
     *listeners_id    struct GRid	the listeners objid, osnum
     *listeners_chan  OM_S_CHANSELECT	the listeners channel
     *msg	      IGRlong	 	completion code

Return Values
    	- MSSUCC if successful
	- MSFAIL error occurred
*/

method GRntfydisconn(IGRlong *msg; struct GRid *listeners_id; 
	OM_S_CHANSELECT *listeners_chan)
{
    *msg = GRINVMSG;
    return (OM_E_ABORT);
}
 
end implementation GRnotify;
