/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
	GRgetflag - Retrieve the flags stored in the context object

Synopsis
	GRgetflag(msg,flag)
	
 	IGRlong	*msg		completion code
	IGRshort  *flag		mask to use

Description
	This method retrieves the flags word in the context object.

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

method GRgetflag(IGRlong *msg; IGRshort *flag)
{
    *msg = MSSUCC;

    *flag = me->flags;
	
    return(OM_S_SUCCESS);
}
end implementation GRcontext;
