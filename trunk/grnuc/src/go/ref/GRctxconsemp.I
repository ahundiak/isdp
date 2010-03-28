/* #######################    APOGEE COMPILED   ######################## */
/*
Abstract
	GRconsemptyctx - construct empty context object
Synopsis
	GRconsemptyctx(msg)

	IGRlong *msg 		completion code

Description
	This method constructs an empty context object. This is
	necessary before initing a new file so the context object is
	available for the nested files to connect to.

Diagnostics
	The possible return codes values in the msg 
	field are:

	MSSUCC - successful completion
	MSFAIL - error
	
Notes
	None
History	
	MAS	05/18/87:   Creation date.
        dhm     07/01/92    ANSI conversion.
*/

class implementation GRcontext;

#include "grimport.h"
#include   "refdef.h"
#include   "msdef.h"
#include   "madef.h"

method GRconsemptyctx(IGRlong *msg)
{
    *msg = MSSUCC;

    MAidmx(msg,me->matrix);
    me->mx_type = MAIDMX;
    me->osnum = (uword) ~0;
    me->flags = GREMPTY_CONTEXT;
	
    return(OM_S_SUCCESS);

}
end implementation GRcontext;
