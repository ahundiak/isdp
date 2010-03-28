/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
	GRrefcheck - determines if this is the context
		object for given input environment matrix.

		This method will use the input matrix and the
		context info from the context object this
		object is nested inside of to compute the
		context info to determine if this is the 
		correct method.
Synopsis
    	GRrefcheck(msg,super_osnum,ref_to_master_matrix,context_id,same)
	
 	IGRlong	*msg		completion code
	GRspacenum *super_osnum object space number of master space
	IGRmatrix ref_to_master_matrix	
				the reference file matrix
	struct GRid *context_id this objects id and space number
	IGRboolean *same	indicator of whether context 
				matches

Description

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
#include "OMmacros.h"

method GRrefcheck(IGRlong *msg; GRspacenum *super_osnum;
	IGRmatrix ref_to_master_matrix; struct GRid *context_id; 
	IGRboolean *same)
{
    IGRlong 	j;			/* loop index			*/
    IGRlong 	OMmsg,			/* local return codes		*/
		msg1;

    IGRshort  	ctx_type,
		test_type;

    IGRmatrix 	ctx_mx,
		test_mx;

    struct GRid	current_ctx;

    GRspacenum  ctx_osnum;
    IGRshort	ctx_flag;

    struct GRid	context;

    OM_S_CHANSELECT  nest_chan;

    OMmsg = OM_S_SUCCESS;		/* initialize return values	*/
    *msg = MSSUCC;
    *same = FALSE;

    context_id->objid = my_id;
    context_id->osnum = OM_Gw_current_OS;

    om$make_chanselect(channame = "GRcontext.to_nested_files",
	p_chanselect = &nest_chan);

    if (OM_Gw_current_OS == *super_osnum)
    {   
        OMmsg = om$send(
	    msg = message GRcontext.GRgetinstance
	    	(msg,&ctx_type,ctx_mx,&ctx_osnum,&ctx_flag,&context),
	    p_chanselect = &nest_chan,
	    from = 0,
	    to = 0);

    	if ( 1 & OMmsg & *msg)
    	{
	    GRgetcurrentctx(&msg1,&current_ctx);

	    if (! (IF_EQ_OBJID(current_ctx.objid,context.objid) &&
		  (current_ctx.osnum == context.osnum)))
	    {
		goto wrapup;
	    }
		
 	    GRcomputectx(&msg1,&ctx_type,ctx_mx,ref_to_master_matrix,
		&test_type,test_mx);

	    if ( 1 & msg1)
	    {
		if (test_type == me->mx_type)
		{
		    for ( j=0; j<16; ++j)
		    {
			if (test_mx[j] != me->matrix[j])
			{
			    j = 20;
			}
		    }
		    if ( j < 20)
		    {
			*same = TRUE;
			OMmsg = OM_I_STOP_SENDING;
		    }
		}
	    }
	}
    }

    wrapup:

    return( OMmsg );
}
end implementation GRcontext;
