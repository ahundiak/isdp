/* #######################    APOGEE COMPILED   ######################## */
class implementation GRcontext;

from GRreffile import GRgetlevels;

#include "grimport.h"
#include "msdef.h"
 
IGRlong GRgetreflevels(msg,mx_type,matrix,osnum,levels)

IGRlong		*msg;			/* return message		*/
IGRshort	*mx_type;
IGRmatrix	matrix;
GRspacenum	*osnum;
IGRint		*levels;		/* array of 35 ints		*/

{
    IGRlong	OMmsg;

    struct GRid	context_id;

    OM_S_CHANSELECT chan;

    OMmsg = OM_S_SUCCESS;
    *msg = MSSUCC;

    OMmsg = GRfindcontext(msg,mx_type,matrix,osnum,&context_id);
    if ( 1 & OMmsg & *msg)
    {
	om$make_chanselect(channame = "GRcontext.to_reffile",
	    p_chanselect = &chan);

	OMmsg = om$send(msg = message GRreffile.GRgetlevels(msg,levels),
	    p_chanselect = &chan,
	    senderid = context_id.objid,
	    targetos = context_id.osnum);
    }
	    
    return(OMmsg);
}

end implementation GRcontext;
