/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
	GRchgflag - Given a flag, this method adjusts the object's 
		flags word by clearing, replacing or setting the
		the flags word with the indicated flag.
Synopsis
	GRchgflag(msg,action,flag)
	
 	IGRlong	*msg		completion code
	IGRshort *action	action to take
				-1 replace
				 0 clear
				 1 set
	IGRshort  *flag		mask to use

Description
	This method alters the flags word in the context object
	using the input flag by the action requested.

Diagnostics
	The possible return codes values in the msg 
	field are:

	MSSUCC - successful completion context matched
	MSINARG - invalid input argument

Notes
	None.

History
	MAS  	05/27/87 	Design date.

\*/

class implementation GRcontext;

#include "grimport.h"
#include "msdef.h"

method GRchgflag(IGRlong *msg; IGRshort *action; IGRshort *flag)
{

	IGRlong OMmsg;

	*msg = MSSUCC;
	OMmsg = OM_S_SUCCESS;


	if ( *action == 1)
	{
	    me->flags = me->flags | *flag;
	}
	else if (*action == 0)
	{
	    me->flags = me->flags &  ~*flag;
	}
	else if (*action == -1)
	{
	    me->flags = *flag;
	}
	else
	{
	    *msg = MSINARG;
	    OMmsg = OM_E_ABORT;
	}
	 
	return(OMmsg);

}

end implementation GRcontext;
