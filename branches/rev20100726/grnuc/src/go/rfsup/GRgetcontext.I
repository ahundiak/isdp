/* #######################    APOGEE COMPILED   ######################## */

class implementation GRcontext;

#include  "grimport.h"
#include  "msdef.h"
#include  "OMerrordef.h"
#include  "refdef.h"
#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "gr.h"

GRgetcontext(msg,ref_id,mgr_id,osnum,context_id,flag)

IGRlong		*msg;

struct GRid	*ref_id,
		*mgr_id,
		*context_id;

OMuword		*osnum;

IGRshort	*flag;

{
	IGRboolean 
		found;

	IGRshort 
		ctx_type,
		ctx_flag;

	IGRlong  OMmsg;			/* method return status		*/
	IGRlong	 msg1,i;

	IGRint	 count=0;

	struct GRid 			/* temporary ids		*/
		new_context_id,
		Super_id;

	IGRmatrix 	mx;

	GRspacenum	ctx_osnum;

	OM_S_CHANSELECT 
			ref_chan;

   	OMmsg = OM_S_SUCCESS;
	*msg = MSSUCC;

     	om$make_chanselect(channame = "GRreffile.to_context",
			p_chanselect = &ref_chan);

	if (! mgr_id)
	{
	    GRgetctxsuper(msg,&Super_id);
	}
	else
	{
	    Super_id = *mgr_id;
	}					    

    	found = FALSE;

	om$get_channel_count(
	    osnum = ref_id->osnum,
	    objid = ref_id->objid,
	    p_chanselect = &ref_chan,
	    count = (OMuint *)&count);

    	for (i=0; i<count && (!found) ; ++i)
	{
	    OMmsg = om$send(msg = 
		message GRcontext.GRgetinstance
		    (&msg1,&ctx_type,mx,&ctx_osnum,&ctx_flag,
		     &new_context_id),
		senderid = ref_id->objid,
		targetos = ref_id->osnum,
		p_chanselect = &ref_chan,
	        from = i, to=i);

	    if ((1 & OMmsg) &&
		(ctx_flag & GRACTIVATED_CONTEXT) &&
/*
	        (new_context_id.osnum == Super_id.osnum) &&
*/
		(ctx_osnum == *osnum))
	    {
		*flag = ctx_flag;
		*context_id = new_context_id;
		found = TRUE;
	    }
	}
    	if (!found)
    	{
	    OMmsg = OM_E_ABORT;
	    *msg = MSFAIL;
    	}

    return (OMmsg);
}

end implementation GRcontext;
