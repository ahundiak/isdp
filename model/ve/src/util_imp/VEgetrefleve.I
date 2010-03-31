
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:42:02 $
$Locker:  $
*/

class implementation GRcontext;

#include <stdio.h>

#include "igrtypedef.h"
#include "igetypedef.h"

#include "gr.h"
#include "igr.h"
#include "igrdp.h"

#include "godef.h"
#include "go.h"

#include "msdef.h" 

#include "ve.h"
#include "vedef.h"

/* prototype files */
#include "VEpr_utilimp.h"

#include "GRfindcontex.h"

from GRreffile import GRgetlevels;

IGRlong VEgetreflevels(msg,mx_type,matrix,osnum,levels)

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
	OMmsg = om$make_chanselect(channame = "GRcontext.to_reffile",
	    p_chanselect = &chan);

	OMmsg = om$send(msg = message GRreffile.GRgetlevels(msg,levels),
	    p_chanselect = &chan,
	    senderid = context_id.objid,
	    targetos = context_id.osnum);
    }
	    
    return(OMmsg);
}

end implementation GRcontext;
