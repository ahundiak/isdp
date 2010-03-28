/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
	GRloadctx - loads the instance data for the context object

Synopsis
        GRloadctx(msg,mx_type,matrix,osnum,flags)

	IGRlong 	*msg 		completion code
	IGRshort 	*mx_type	context matrix type
	IGRmatrix 	matrix 		context matrix
	GRspacenum 	*osnum 		reference file osnum
	IGRshort 	*flags		flags word

Description
	This method loads the instance data for the context object

Diagnostics
	The possible return codes values in the msg 
	field are:

	MSSUCC - successful completion
	MSFAIL - error
Notes
	None.

History	
	MAS	05/18/87:   Creation date.
\*/

class implementation GRcontext;

#include "grimport.h"
#include   "refdef.h"
#include   "msdef.h"

method GRloadctx(IGRlong *msg; IGRshort *mx_type;
	IGRmatrix matrix; GRspacenum *osnum; IGRshort *flags)
{
    IGRlong	i;

    *msg = MSSUCC;

    me->flags = *flags;
    me->osnum = *osnum;
    me->mx_type = *mx_type;

    for ( i=0; i<16; ++i)
    {
	me->matrix[i] = matrix[i];
    }    	

    return(OM_S_SUCCESS);
}
end implementation GRcontext;
