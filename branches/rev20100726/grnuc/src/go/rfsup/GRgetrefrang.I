/* #######################    APOGEE COMPILED   ######################## */
class implementation GRreffile;

#include "grimport.h"
#include "msdef.h"
#include "referr.h"
#include "refdef.h"
#include "refpriv.h"

from GRcontext import GRgetinstance,GRcheckctx;

IGRlong GRgetrefrange(msg,osnum,context_type,context_matrix,
	window_range,world_to_dit_matrix,range)

IGRlong		*msg;
GRspacenum	*osnum;
IGRshort	*context_type;
IGRmatrix	context_matrix;
IGRdouble	*window_range;
IGRmatrix 	world_to_dit_matrix;
GRrange		range;

{
    IGRboolean	world,
		same;

    IGRshort 	objects_mx_type,
		flag,
		num_opens,
		num_opens_processed;

    IGRlong	OMmsg,
		msg1;

    IGRint	i,
    		count;

    IGRmatrix	objects_context_matrix;

    OM_S_CHANSELECT super_chan,
		context_chan,
		reffile_chan;

    GRrange	ref_range,
		win_range;

    GRspacenum 	osnum1,
		osnum2;

    struct GRid Super,
		previous_context,
		context_id;

    OMmsg = OM_S_SUCCESS;
    *msg = MSSUCC;
	
    OMmsg = GRgetctxsuper(msg,&Super);

    if ( 1 & OMmsg & *msg)
    {				/* set up channel information	*/
	om$make_chanselect(p_chanselect = &super_chan,
		channame = "Super_rfmgr.to_context");
	om$make_chanselect(p_chanselect = &context_chan,
		channame = "GRcontext.to_nested_files");
	om$make_chanselect(p_chanselect = &reffile_chan,
		channame =  "GRcontext.to_reffile");

        world = TRUE;			/* range flag			*/

	num_opens = 0;
	num_opens_processed = 0;

	GRget_num_opens(msg1,*osnum,num_opens);

	if (!( 1 & msg1))
	{
	    OMmsg = OM_E_ABORT;
	    *msg = MSFAIL;
	    goto wrapup;
  	}

	OMmsg = om$get_channel_count(
		p_chanselect = &super_chan,
		osnum = Super.osnum,
		objid = Super.objid,
		count = (OMuint *)&count);

	if ( 1 & OMmsg)
	{		
	    win_range[0] = window_range[0];
	    win_range[1] = window_range[1];
	    win_range[2] = window_range[2];
	    win_range[3] = window_range[3];
	    win_range[4] = window_range[4];
	    win_range[5] = window_range[5];
	    osnum2 = *osnum;
	    
	    for (i=0; 
		((i < count) && (num_opens_processed < num_opens)); ++i)
	    {
	 	OMmsg = om$send
		    (msg = message GRcontext.GRcheckctx
			(&msg1,context_type,context_matrix,osnum,
			 &context_id,&same),
		    senderid = Super.objid,
		    targetos = Super.osnum,
		    p_chanselect = &super_chan,
		    from = i, to = i);

		if (1 & OMmsg & msg1 & same)
		{
		    /* Match found, set variables to terminate loop.
		     * Loop backwards through the nested context
		     * objects until you reach to master context
		     * object to determine the range.
		     */

		    num_opens_processed = num_opens;
		    flag = 0;

		    while ( ! ( flag & GRMASTER_CONTEXT))
		    {
	                OMmsg = om$send(mode = OM_e_wrt_object,
		            msg = message GRcontext.GRgetinstance
			        (&msg1,&objects_mx_type,
				 objects_context_matrix,
			         &osnum1,&flag,&previous_context),
		            senderid = context_id.objid,
			    targetos = context_id.osnum,
		    	    p_chanselect = &context_chan,
		    	    from = 0, to = 0);

		    	if (1 & OMmsg)
		    	{		
			    OMmsg = om$send(
			    	msg = message GRvg.GRgetrang
			 	    (&msg1,&objects_mx_type,
			    	     objects_context_matrix,
			    	     &world,ref_range),
			        senderid = context_id.objid,
				targetos = context_id.osnum,
		    	        p_chanselect = &reffile_chan,
			        from = 0,
 			        to = 0);

			    if ( 1 & OMmsg)
			    {
				DPintr_rng(&msg1,ref_range,
				    win_range,world_to_dit_matrix,
				    range);

				win_range[0] = range[0];
				win_range[1] = range[1];
				win_range[2] = range[2];
				win_range[3] = range[3];
				win_range[4] = range[4];
				win_range[5] = range[5];

				context_id = previous_context;
			    }
			    else
			    {
				*msg = MSFAIL;
				goto wrapup;
			    }
		   	}
			else
			{
			    *msg = MSFAIL;
			    goto wrapup;
			}
		    }
		}
		else
		{
		    if ( msg1 == GR_E_SAME_OSNUM)
		    {
			++num_opens_processed;
		    }
		}
	    }
	}
    }

wrapup:

    return(OMmsg);
}
end implementation GRreffile;
