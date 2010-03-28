/* #######################    APOGEE COMPILED   ######################## */
/*
Name
	GRincinvtable - 
Synopsis

	GRincinvtable(msg,context_id)
	
	IGRlong *msg			return code
		MSSUCC - successful completion
		MSFAIL - error occurred
	struct GRid *context_id		the context object id

Description

Diagnostics
	MSSUCC
	MSFAIL

History
	MAS	 09/21/87	Design Date
*/

class implementation GRcontext;

#include "grimport.h"
#include 	"msdef.h"
#include	"ex.h"
#include 	"refdef.h"
#include	"refpriv.h"

GRincinvtable(msg,context_id)

IGRlong		*msg;
struct GRid	*context_id;

{
    IGRshort	type,			/* matrix type from context	*/
		action,
       		flag;			/* flag from context instance	*/

    IGRlong	OMmsg,			/* return codes			*/
		msg1;

    IGRint	i,
		count;

    IGRmatrix	matrix;			/* context matrix		*/
    
    struct GRid	next_context_object;	/* nested context id		*/

    GRspacenum	nested_osnum;		

    OM_S_CHANSELECT context_chan;


    *msg =  MSSUCC;
    OMmsg = OM_S_SUCCESS;
    action = -1;

    OMmsg = om$make_chanselect(channame = "GRcontext.to_nested_files",
		p_chanselect = &context_chan);

    if ( 1 & OMmsg)
    {
				    	/* get the nested files count	*/
        OMmsg = om$get_channel_count(
		osnum = context_id->osnum,
		objid = context_id->objid,
		p_chanselect = &context_chan,
		count = (OMuint *)&count);
			
        if ( 1 & OMmsg)
        {					
	    if ( count > 1)		/* if there are any objects	*/
	    {
	        /* If there are nested files within this context object,
	     	 * their entries in the invisible table must be 
		 * incremented.  Retrieve the instance data of the context
		 * object to find out the osnum of the file.
	     	 */

		for (i=1; i<count; ++i)
		{
		    OMmsg = om$send (msg = message GRcontext.GRgetinstance
	    	    	(&msg1,&type,matrix,&nested_osnum,
			 &flag,&next_context_object),
	    	    	p_chanselect = &context_chan,
	    	    	senderid = context_id->objid,
			targetos = context_id->osnum,
	    	    	from = i,
	      	    	to = i);

		    if ( (1 & OMmsg & msg1)&&(flag & GRACTIVATED_CONTEXT))
		    {
		        Increment_num_opens(nested_osnum) 

		        /* each of the context objects nested in this file
		         * must be called recursively to increment the 
		         * invisible table for the files nested inside
		         * them.		
		         */

		        GRincinvtable(&msg1,&next_context_object);
		    }
		}
	    }
	}
	else
	{
	    *msg = MSFAIL;
	}
    }		     
    else
    {
	*msg = MSFAIL;
    }

    return (OMmsg);
}
end implementation GRcontext;
