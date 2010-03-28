/* #######################    APOGEE COMPILED   ######################## */
class implementation GRlistener;

#include "grimport.h"
#include "grerr.h"
#include "OMerrordef.h"

method GRnotify(IGRlong *msg; IGRlong OMmsg; IGRlong *mask;
	OM_S_MESSAGE *graphics_msg)

/*
Abstract: 
	This method is the means whereby a graphics object notifies a
	listener of what operation has been performed on the graphics 
	object.

Arguments	
	*msg		IGRlong		the return message from the
					operation on the graphics object
	*OMmsg		IGRlong		the om return code from the
					operation on the graphics object
	*mask		IGRlong		the mask indicating what sort
					of operation was performed
	*graphics_msg	OM_S_MESSAGE	the message that was sent to
					the graphics object
Return Values
	No value should be returned

Notes
	The listener should use the input arguments for reference only
	and should not alter any value.  The return codes are for
	input only, to notify the listener of the status of the
	operation on the graphics object
*/

{
    *msg = GRINVMSG;
    return(OM_S_SUCCESS);
}
 
end implementation GRlistener;
