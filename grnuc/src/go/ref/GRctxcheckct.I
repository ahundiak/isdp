/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
	GRcheckctx - checks input context against instance 
		data
Synopsis
    	GRcheckctx(msg,type,matrix,osnum,context_id,same)
	
 	IGRlong	*msg		completion code
	IGRshort *type		matrix type
	IGRmatrix matrix	the environment matix
	GRspacenum *osnum	object space number of ref. file
	struct GRid *context_id this objects id and space number
	IGRboolean *same	indicator of whether context 
				matches

Description
	This method verifies if the input context information 
	is equal to the instance data of the GRcontext object.

Diagnostics
	The possible return codes values in the msg 
	field are:

	MSSUCC - successful completion context matched
	
	MSFAIL - error; context different
Notes
	None.

History
	MAS  	05/27/87 	Design date.

\*/

class implementation GRcontext;

#include "grimport.h"
#include "msdef.h"

method GRcheckctx(IGRlong *msg;IGRshort *type;IGRmatrix matrix;
    GRspacenum *osnum; struct GRid *context_id; IGRboolean *same)

{
    IGRlong i;				/* loop index			*/
    IGRlong OMmsg;			/* local return codes		*/


    OMmsg = OM_S_SUCCESS;		/* initialize return values	*/
    *msg = MSSUCC;
    *same = TRUE;

    if (( *type == me->mx_type) && ( *osnum == me->osnum))
    {
	context_id->objid = my_id;
	context_id->osnum = OM_Gw_current_OS;

    	for (i=0; i<16 && *same; ++i)
    	{
	    if (me->matrix[i] != matrix[i])
	    {
		*msg = MSFAIL;
		OMmsg = OM_W_ABORT;
		*same = FALSE;
	    }
	}
	if (*same)
	{
	    OMmsg = OM_I_STOP_SENDING;
	}
    }
    else
    {
	*msg = MSFAIL;
	OMmsg = OM_W_ABORT;
	*same = FALSE;
    }

    return( OMmsg );
}
end implementation GRcontext;
