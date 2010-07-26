/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
	GRgetctxid - gets the context object for a given graphics 
		object 

Synopsis
    	GRgetctxid(msg,type,matrix,gr_oid,context_id)
	
 	IGRlong	*msg		completion code
	IGRshort *type		type of context matrix
	IGRmatrix matrix	transformation matrix to go from 
				reference file coordinates to master 
				file coordinates
	struct GRid *gr_oid	graphics object
	struct GRid *context_id returned context id,osnum

Description


Diagnostics
	The possible return codes values in the msg 
	field are:

	MSSUCC - successful completion 
	MSFAIL - object does not have a context object in this
		master file.
Notes
	None.

History
	MAS  	08/10/87 	Design date.

\*/

class implementation GRcontext;

#include "grimport.h"
#include "msdef.h"

IGRlong GRgetctxid(msg,type,matrix,gr_oid,context_id)

IGRlong *msg;
IGRshort *type;
IGRmatrix matrix;
struct GRid *gr_oid;
struct GRid *context_id;
{
    IGRboolean	found;

    IGRshort	mx_type,
		flag;

    IGRint  	count;

    IGRlong 	i,j;			/* loop index			*/
    IGRlong 	OMmsg,			/* local return codes		*/
		msg1;

    GRspacenum	ref_osnum;
	
    OM_S_CHANSELECT chan;

    struct GRid Super;

    GRobjid	context_objid;
    GRspacenum	context_osnum;

    IGRmatrix	ctx_matrix;

    OMmsg = OM_S_SUCCESS;		/* initialize return values	*/
    *msg = MSSUCC;
    found = FALSE;

    OMmsg = om$make_chanselect(channame = "GRreffile.to_context",
	p_chanselect = &chan);

    if ( 1 & OMmsg )
    {					/* get count of context objects	*/
	OMmsg = om$get_channel_count(
		osnum = gr_oid->osnum,
		objid = gr_oid->objid,
		p_chanselect = &chan,
		count = (OMuint *)&count);

	if (count)
	{		
					/* get the context Super	*/
	    OMmsg = GRgetctxsuper(msg,&Super);

	    if (1 & OMmsg & *msg)
	    {
		for (i=0; i<count; ++i)
		{			/* get each context object	*/
	    	    OMmsg = om$get_objid_at_index(
			osnum = gr_oid->osnum,
			objid = gr_oid->objid,
			p_chanselect = &chan,
			index = i,
			objidaddr = &context_objid,
			osnumaddr = &context_osnum);

	    	    if ( 1 & OMmsg)
	    	    {	
			/* If the file is a nested file there may be
			 * other context object's connected to the
			 * attachment.  To determine the correct one,
			 * the following criteria must match:
			 * - same OS num as context Super
			 * - the context matrix must match the context
			 *   stored in the cache.
			 */

			if ( context_osnum == Super.osnum)
			{
			    OMmsg = om$send(
				msg = message GRcontext.GRgetinstance
				    (&msg1,&mx_type,ctx_matrix,&ref_osnum,
				     &flag,context_id),
				senderid = gr_oid->objid,
				targetid = context_objid,
				targetos = context_osnum);

			    /* see if this is the context object for
			     * the input reference file object	
			     */

			    if ( mx_type == *type )
			    {
				found = TRUE;
						
				for (j=0; j<16; ++j)
				{
				    if (matrix[j] != ctx_matrix[j])
				    {
					j = 16;
					found = FALSE;
				    }
				}
				if (found)
				{
				    i = count;
				}
			    }
			}
		    }
		}
	    }
	}
    }

/* wrapup: */
    
    if ( ! found)
    {
	*msg = MSFAIL;
	OMmsg = OM_E_ABORT;
    }
 
    return( OMmsg );
}
end implementation GRcontext;
