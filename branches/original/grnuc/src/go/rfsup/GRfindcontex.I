/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
	GRfindcontext - this function finds the correct
		context object for the input information

Synopsis

	GRfindcontext(msg,ctx_mx_type,ctx_mx,osnum,context_id)

	IGRlong 	*msg;		 completion code		
	IGRshort 	*ctx_mx_type;	 context matrix type		
	IGRmatrix 	ctx_mx;		 context matrix		
	GRspacenum 	*osnum;		 osnum of located object	
	struct GRid 	*context_id;	 the context object

Description
	This function finds the context object for a particular input
	context information.

Diagnostics
	The possible return codes values in the msg 
	field are:

	MSSUCC - successful completion 
	MSFAIL - error occurred
Notes
	None.

History
	MAS  	12/15/87 	Design date.
    bbkr    04/12/96    Modified to compare matrix elements difference with
                        BSVALCLOSETOZERO. TR#119603821

\*/

class implementation GRcontext;

#include <math.h>
#include "grimport.h"
#include "msdef.h"
#include "refdef.h"
#include "madef.h"

#include "bs.h"
#include "bsxtractpar.h"
#include "bsparameters.h"


from GRreffile import GRinquireref;

IGRlong GRfindcontext(msg,ctx_mx_type,ctx_mx,osnum,context_id)

IGRlong 	*msg;			/* completion code		*/
IGRshort 	*ctx_mx_type;		/* context matrix type		*/
IGRmatrix 	ctx_mx;			/* context matrix		*/
GRspacenum 	*osnum;			/* osnum of located object	*/
struct GRid	*context_id;		/* the context id 		*/
{
    IGRboolean	found,
		cyclic_attachment;

/*    IGRboolean 	pass_on;	 pass to nested spaces flag	*/

    IGRchar 	osname[OM_K_MAXOSNAME_LEN];

    IGRshort	mx_type,
		flag;

    IGRint  	count;

    IGRlong 	i,j;			/* loop index			*/
    IGRlong 	OMmsg,			/* local return codes		*/
		msg1;

    GRspacenum	ref_osnum;
	
    OM_S_CHANSELECT super_chan,
		ref_chan;

    struct GRid Super,
		ctx_id;
/*
    struct GRinquire_list inquire_requests[2];
    struct GRmd_env  dummy_env,new_env;
*/

    IGRmatrix	ctx_matrix;
    IGRdouble   close_zero;
    BSrc        rc;

    OMmsg = OM_S_SUCCESS;		/* initialize return values	*/
    *msg = MSSUCC;
    found = FALSE;
    cyclic_attachment = FALSE;

    OMmsg = om$make_chanselect(channame = "Super_rfmgr.to_context",
	p_chanselect = &super_chan);

    OMmsg = om$make_chanselect(channame = "GRcontext.to_reffile",
	p_chanselect = &ref_chan);

    if ( 1 & OMmsg )
    {	
					/* get the context Super	*/
	OMmsg = GRgetctxsuper(msg,&Super);

	if ( 1 & OMmsg & *msg)
	{
	    OMmsg = om$get_channel_count(
		osnum = Super.osnum,
		objid = Super.objid,
		p_chanselect = &super_chan,
		count = (OMuint *)&count);

	    if (1 & OMmsg )
	    {
		for (i=0; i<count && (! found); ++i)
		{			/* get each context object	*/
		    OMmsg = om$send(
			msg = message GRcontext.GRgetinstance
			    (&msg1,&mx_type,ctx_matrix,&ref_osnum,
			     &flag,context_id),
			senderid = Super.objid,
			targetos = Super.osnum,
			p_chanselect = &super_chan,
			to = i,
			from = i);

	    	    if ( 1 & OMmsg & msg1)
	    	    {	
			/* see if this object space is active before
			 * trying to use this context object.
			 */

			 OMmsg = om$os_number_to_name(osnum=ref_osnum,
			     osname = osname);

			if (! (1 & OMmsg))
			{
			    continue;		/* skip this osnum	*/
			}

			if ( !( flag & GRACTIVATED_CONTEXT))
			{
			    continue;
			}

			/* see if this is the context object the
			 * user wants to connect to.  To determine the 
			 * correct one, the requested criteria must match:
			 * - same OS num as the located object.
			 * - the context matrix must match the input
			 *   context matrix
			 * - do not return master file context object
			 */

			if (ctx_mx_type && ctx_matrix)
			{
			    if ((*osnum == ref_osnum) && 
			    	(!(flag & GRMASTER_CONTEXT)))
			    {				
			    	if ( mx_type == *ctx_mx_type )
			    	{
				    found = TRUE;
                     
                    BSxtractpar( &rc, BSTOLCLOSETOZERO, &close_zero); 
						
				    for (j=0; j<16 && found; ++j)
				    {
				     if ((fabs(ctx_mx[j] - ctx_matrix[j])) > close_zero)
				      {
					   found = FALSE;
				      }
				    }
				}
			    }
			}
			else
		        {

			    if ( ! ((flag & GREMPTY_CONTEXT) ||
				    (flag & GRMASTER_CONTEXT)))
			    {
				if (ref_osnum == *osnum)
				{
				    found = TRUE;

				    /* if a cyclic attachment of this
				     * space exists, return an error
				     * so that an empty context
				     * object is constructed.
				     */

				    if (flag & GRCYCLIC_ATTACHMENT)
				    {
					cyclic_attachment = TRUE;
				    }

				    for (j=i; 
					 j<count && (! cyclic_attachment);
					 ++j)
		    		    {	
		    			OMmsg = om$send(
					    msg = 
					message GRcontext.GRgetinstance
			  		(&msg1,&mx_type,ctx_matrix,
					 &ref_osnum,&flag,&ctx_id),
					     senderid = Super.objid,
					     targetos = Super.osnum,
					     p_chanselect = &super_chan,
					     from = j ,to = j);

					if ((flag & GRACTIVATED_CONTEXT) 
					   && (!(flag & GREMPTY_CONTEXT))
					   && (ref_osnum == *osnum))
					{
					    if (flag & GRCYCLIC_ATTACHMENT)
					    {
						cyclic_attachment = TRUE;
					    }
					}				
				    }
				}
			    }
			}
		    }
		}
	    }
	}
    }

/* wrapup: */
    
    if ((!found) || cyclic_attachment)
    {
	*msg = MSFAIL;
	OMmsg = OM_E_ABORT;
    }
	  
    return( OMmsg );
}
end implementation GRcontext;


			    /* this function is being called as the
			     * object spaces are being opened.  The
			     * osnum stored in the context object may
			     * be incorrect now.  Get the osname from
			     * the reference file attached to this
			     * object to determine if it is the same
			     * osnum, provided the context object is
			     * not an empty context object.
			     */

/*
				inquire_requests[0].var = ENVIRONMENT_INFO;
				inquire_requests[0].var_ptr = &new_env;
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
				    senderid = context_id->objid,
				    targetos = context_id->osnum,
	    			    p_chanselect = &ref_chan);

				if (new_env.md_id.osnum == *osnum)
				{
				    found = TRUE;
				}

*/
