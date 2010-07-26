/* #######################    APOGEE COMPILED   ######################## */
/*
Name
	GRdecinvtable - 
Synopsis

	GRdecinvtable(msg,context_id,check_count_only,osnum,new_count)
	
	IGRlong *msg			return code
		MSSUCC - successful completion
		MSFAIL - error occurred
	struct GRid *context_id		the context object id
	IGRint	check_count_only
	GRspacenum osnum
	IGRint	new_count

Description

Diagnostics
	MSSUCC
	MSFAIL

History
	MAS	 09/21/87	Design Date
        scw      07/28/92       ansi conversion
*/

class implementation GRcontext;

#include "grimport.h"
#include 	"msdef.h"
#include	"ex.h"
#include	"refpriv.h"
#include 	"refdef.h"

GRdecinvtable(msg,context_id,count_check_only,osnum,new_count)

IGRlong		*msg;
struct GRid	*context_id;
IGRint		*count_check_only;
GRspacenum	*osnum;
IGRint		*new_count;
{
    IGRshort	type,			/* matrix type from context	*/
       		flag;			/* flag from context instance	*/

    IGRlong	OMmsg,			/* return codes			*/
		msg1;

    IGRint	i;
    OMuint      count;

    IGRmatrix	matrix;			/* context matrix		*/
    
    struct GRid	next_context_object;	/* nested context id		*/

    GRspacenum	nested_osnum;		

    OM_S_CHANSELECT context_chan;


    *msg =  MSSUCC;
    OMmsg = OM_S_SUCCESS;

    OMmsg = om$make_chanselect(channame = "GRcontext.to_nested_files",
		p_chanselect = &context_chan);

    if ( 1 & OMmsg)
    {
				    	/* get the nested files count	*/
        OMmsg = om$get_channel_count(objid = context_id->objid,
		osnum = context_id->osnum,
		p_chanselect = &context_chan,
		count = &count);
			
        if ( 1 & OMmsg)
        {					
	    if ( count > 1)		/* if there are any objects	*/
	    {
	        /* If there are nested files within this context object,
	     	 * their entries in the invisible table must be 
		 * decremented.  Retrieve the instance data of the context
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
			if (*count_check_only)
			{
			    if (*osnum == nested_osnum)
			    {
				--(*new_count);
			    }
			}
			else
			{
		            Decrement_num_opens(nested_osnum)

		            /* each of the context objects nested in 
			     * this file must be called recursively 
			     * to decrement the invisible table for 
			     * the files nested inside them.		
		             */
			}
			if ( ! (flag & GRCYCLIC_ATTACHMENT))
			{
			    GRdecinvtable(&msg1,&next_context_object,
			        count_check_only,osnum,new_count);
			}
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
