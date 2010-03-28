/* #######################    APOGEE COMPILED   ######################## */
/*
Name
	GRcyclic_check - checks context objects for a 
		cyclic attachment
Synopsis

	GRcyclic_check(msg,nested_files_chan,context_id,osnum,flag)
	
	IGRlong *msg			return code
		MSSUCC - successful completion
		MSFAIL - error occurred
	OM_S_CHANSELECT *nested_files_chan
					channel to nested files
	GRobjid		*context_id;	context object id
	IGRint		*flag;		flags of context object,
					initialized to 0 before calling
Description
	This function checks the nested files for a cyclic 
	attachment

Diagnostics
	MSSUCC
	MSFAIL

History
	MAS	 09/21/87	Design Date
*/

class implementation GRcontext;

#include "grimport.h"
#include 	"msdef.h"
#include 	"madef.h"
#include 	"refdef.h"

from GRreffile import GRinquireref;

static OM_S_CHANSELECT ref_chan;

%safe
static int chan_initialized=0;
%endsafe

GRcyclic_check(msg,nested_files_chan,context_id,osnum,flag)

IGRlong		*msg;
OM_S_CHANSELECT *nested_files_chan;
struct GRid	*context_id;
GRspacenum	*osnum;
IGRshort	*flag;
{
    IGRboolean 	pass_on;		/* pass to nested spaces flag	*/

    IGRshort	nest_flag,
		type,
		change_flag=1;		/* flag for change properties	*/

    IGRlong	OMmsg,			/* return codes			*/
		msg1;

    IGRint	i,j,
		count;

    IGRmatrix	matrix;			/* local matrix for method	*/
    
    struct GRid	prev_context_id,	/* context ids			*/
		context_info;

    GRspacenum	nested_osnum;		
    struct GRinquire_list inquire_requests[2];
    struct GRmd_env dummy_env,new_env;

    *msg =  MSSUCC;
    OMmsg = OM_S_SUCCESS;

    nest_flag = *flag;
    prev_context_id = *context_id;

    if (!chan_initialized)
    {
	om$make_chanselect(channame = "GRcontext.to_reffile",
	    p_chanselect = &ref_chan);

	chan_initialized = 1;

    }
				    	/* get the nested files count	*/
    OMmsg = om$get_channel_count(objid = context_id->objid,
		osnum = context_id->osnum,
		p_chanselect = nested_files_chan,
		count = (OMuint *)&count);
		
    if ( 1 & OMmsg)
    {					
	if ( count)			/* if there are any objects	*/
	{
	    /* check to see if the context object represents a 
	     * cyclic attachment with an object in the tree to
	     * this point
	     */

	    while (! ( nest_flag & GRMASTER_CONTEXT))
	    {
		/* check backwards all objects in the tree to this point
		 * until you reach the master file context object
		 */

		OMmsg = om$send (msg = message GRcontext.GRgetinstance
	    	    	(&msg1,&type,matrix,&nested_osnum,
			 &nest_flag,&context_info),
	    	    p_chanselect = nested_files_chan,
	    	    senderid = prev_context_id.objid,
		    targetos = prev_context_id.osnum,
	    	    from = 0,
	      	    to = 0);
		
		prev_context_id = context_info;
		 
		if (! ( (nest_flag & GRACTIVATED_CONTEXT) ||
		        (nest_flag & GRMASTER_CONTEXT) ) )
		{
		    /* This context object has not yet been updated 
		     * with the new osnum get it from the reffile object
		     */
		
		    inquire_requests[0].var = ENVIRONMENT_INFO;
		    inquire_requests[0].var_ptr = (IGRchar *)&new_env;
		    inquire_requests[0].num_requested = sizeof(struct GRmd_env);
		    inquire_requests[1].var = END_REPORT_REQUEST;

		    MAidmx(msg,dummy_env.md_env.matrix);
			   dummy_env.md_env.matrix_type = MAIDMX;
			
		    dummy_env.md_id.objid = NULL_OBJID;
    		    pass_on = FALSE;

    		    OMmsg = om$send(
	    		msg = message GRreffile.GRinquireref
			    (&msg1,&dummy_env,inquire_requests,
			     &j,&pass_on,NULL),
			senderid = prev_context_id.objid,
			targetos = prev_context_id.osnum,
	                p_chanselect = &ref_chan);

  		    if (new_env.md_id.osnum == *osnum)
		    {
	    	    	*flag |= GRCYCLIC_ATTACHMENT;
		    	break;
		    }
		}   
		else if (nested_osnum == *osnum)
		{
	    	    *flag |= GRCYCLIC_ATTACHMENT;
		    break;
		}		    
	    }		

	    count -= 1;			/* adjust index			*/

	    /* After checking all the attachments above this one
	     * we must now check the attachments nested inside this
	     * attachment.  The check will start at the bottom of
	     * the tree and call this routine recursively to check
	     * all attachments.
	     */

	    for (i = count; i > 0; --i)
	    {
		OMmsg = om$send (msg = message GRcontext.GRgetinstance
	    	    	(&msg1,&type,matrix,&nested_osnum,
			 &nest_flag,&context_info),
	    	    p_chanselect = nested_files_chan,
	    	    senderid = context_id->objid,
		    targetos = context_id->osnum,
	    	    from = i,
	      	    to = i);
		
		if ( context_id->objid == context_info.objid)
		{
		     break;
		}		

		GRcyclic_check(&msg1,nested_files_chan,&context_info,
			&nested_osnum,&nest_flag);

		if (nest_flag & GRCYCLIC_ATTACHMENT)
		{
		    OMmsg = om$send(msg = message GRcontext.GRchgflag
				(&msg1,&change_flag,&nest_flag),
			p_chanselect = nested_files_chan,
			senderid = context_id->objid,
			targetos = context_id->osnum,
			from = i,
			to = i);

		    nest_flag = 0;
		}
	    }
	}
    }
    else
    {	
	*msg = MSFAIL;
    }

    return (OMmsg);
}
end implementation GRcontext;
