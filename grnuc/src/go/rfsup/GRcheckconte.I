/* #######################    APOGEE COMPILED   ######################## */
class implementation GRcontext;

/* check for the existence of a context object for this reference
 * file.
 */

#include "grimport.h"
#include "msdef.h"


static OM_S_CHANSELECT chan;

%safe
static	int	chan_defined=0;
%endsafe

GRcheckcontext(msg,matrix,Super_id,ref_id,construct_flag,context,
	new_context)

IGRlong		*msg;
IGRdouble	*matrix;
struct GRid	*Super_id,
		*ref_id;
IGRboolean	*construct_flag;
struct GRid	*context;
IGRboolean	*new_context;

{
    IGRlong	OMmsg,
		msg1;

    IGRboolean	same = FALSE;

    OMmsg = OM_S_SUCCESS;

    /* If this attachment does not have a context
     * object in the current master space, which
     * is connected to the current context object,
     * construct an empty context object
     * to connect to the current context object.  
     */
    
    if (! chan_defined)
    {
	om$make_chanselect(
	    channame = "GRreffile.to_context",
	    p_chanselect = &chan);

	chan_defined = 1;

    }

    if (! *construct_flag)
    {
    	OMmsg = om$send(
	    msg = message GRcontext.GRrefcheck
		(&msg1,&Super_id->osnum,matrix,context,&same),
	    senderid = ref_id->objid,
	    targetos = ref_id->osnum,
	    p_chanselect = &chan);

        if ( same )
	{
	    *new_context = FALSE;
	}
    }

    if (*new_context)
    {
	/* Either the GRrfinit call is due to a construct
	 * method, or this reference file does not yet
	 * have a context object in this space.
	 */

        OMmsg = om$construct(
		    classname = "GRcontext",
		    p_objid = &context->objid,
	  	    osnum = Super_id->osnum,
		    msg = message GRcontext.GRconsemptyctx (msg));

	context->osnum = Super_id->osnum;

        if ( 1 & OMmsg & *msg)
	{
	    /* connect the context super, reffile, and context
	     * object.
	     */

	    OMmsg = GRconnchannels(msg,ref_id,Super_id,context);
 	}
   }

   return(OMmsg);

}

end implementation GRcontext;
