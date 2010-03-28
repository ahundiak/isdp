/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
	GRputosnum - stores the object space number in the context object
Synopsis
    	GRputosnum(msg,osnum)
	
 	IGRlong	*msg		completion code
	GRspacenum *osnum	object space number of the reference
				file
Description
	This method stores the object space number in the context object

Diagnostics
	The possible return codes values in the msg 
	field are:

	MSSUCC - successful completion
Notes
	None.

History
	MAS  	05/27/87 	Design date.

\*/

class implementation GRcontext;

#include "grimport.h"
#include   "msdef.h"

method GRputosnum(IGRlong *msg; GRspacenum *osnum)
{
    *msg = MSSUCC;

    me->osnum = *osnum;
	
    return(OM_S_SUCCESS);
}
end implementation GRcontext;
