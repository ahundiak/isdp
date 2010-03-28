/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
	GRchkconnection - checks to see if a given graphics 
		object is connected to this context 
		object
Synopsis
    	GRchkconnection(msg,gr_oid,context_id)
	
 	IGRlong	*msg		completion code
	struct GRid *gr_oid	graphics object
	struct GRid *context_id returned context id,osnum

Description
	This method checks to see if a particular graphics
	object is connected to it.  If so, the object id
	and space number of this context object are returned.

Diagnostics
	The possible return codes values in the msg 
	field are:

	MSSUCC - successful completion 
	MSFAIL - not on channel

Notes
	None.

History
	MAS  	08/10/87 	Design date.

\*/

class implementation GRcontext;

#include "grimport.h"
#include "msdef.h"

method GRchkconnection(IGRlong *msg;struct GRid *gr_oid, *context_id)

{
    IGRlong OMmsg;			/* local return codes		*/
    OM_S_CHANSELECT chan;


    OMmsg = OM_S_SUCCESS;		/* initialize return values	*/
    *msg = MSFAIL;

    chan.type = OM_e_addr;
    chan.u_sel.addr = &me->to_reffile;

    OMmsg = om$is_objid_on_channel(objid_c = my_id,
		p_chanselect = &chan,
		objid = gr_oid->objid,
		osnum2 = gr_oid->osnum);

    if (OMmsg == OM_S_SUCCESS)
    {
	context_id->objid = my_id;
	context_id->osnum = OM_Gw_current_OS;

	*msg = MSSUCC;
    }

    return( OMmsg );
}
end implementation GRcontext;
