/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
	GRcontextconn - this function finds the correct
		context object for an application to connect to
		and does a channel connection of the user_chan
		and the to_misc channel on the context object.
Synopsis

	GRcontextconn(msg,ctx_mx_type,ctx_mx,osnum,user_id,user_chan,
	user_index)

	IGRlong 	*msg;		 completion code		
	IGRshort 	*ctx_mx_type;	 context matrix type		
	IGRmatrix 	ctx_mx;		 context matrix		
	GRspacenum 	*osnum;		 osnum of located object	
	struct GRid 	*user_id;	 object to connect context
					   object			
	OM_S_CHANSELECT *user_chan;	 channel from user_id object	
	IGRint		*user_index;	 index to be used on user_chan

Description
	This function finds the context object for a particular input
	context information and performs a channel connection to this
	object.

	This function will typically be used for an application desiring
	to connect to the context object to be able to be notified
	of changes to the reference file attachment object and to 
	be able to retrieve the context information for an object in
	the reference file space.

Diagnostics
	The possible return codes values in the msg 
	field are:

	MSSUCC - successful completion 
	MSFAIL - error occurred
Notes
	None.

History
	MAS  	12/15/87 	Design date.

\*/

class implementation GRcontext;

#include "grimport.h"
#include "msdef.h"

IGRlong GRcontextconn(msg,ctx_mx_type,ctx_mx,osnum,user_id,user_chan,
	user_index)

IGRlong 	*msg;			/* completion code		*/
IGRshort 	*ctx_mx_type;		/* context matrix type		*/
IGRmatrix 	ctx_mx;			/* context matrix		*/
GRspacenum 	*osnum;			/* osnum of located object	*/
struct GRid 	*user_id;		/* object to connect context
					   object			*/
OM_S_CHANSELECT *user_chan;		/* channel from user_id object	*/
IGRint		*user_index;		/* index to be used on user_chan*/

{
    IGRlong 	OMmsg;			/* local return codes		*/

    struct GRid	context_id;
    OM_S_CHANSELECT misc_chan;

    OMmsg = OM_S_SUCCESS;		/* initialize return values	*/
    *msg = MSSUCC;

    OMmsg = GRfindcontext(msg,ctx_mx_type,ctx_mx,osnum,&context_id);

    if ( 1 & OMmsg & *msg)
    {
        OMmsg = om$make_chanselect(channame = "GRcontext.to_misc",
	    p_chanselect = &misc_chan);
	if ( 1 & OMmsg)
	{
    	    OMmsg = om$send(
	   	msg = message Root.connect(*user_chan,OM_K_MAXINT,
		    context_id.objid,context_id.osnum,misc_chan,
		    *user_index),
		senderid = context_id.objid,
		targetid = user_id->objid,
		targetos = user_id->osnum);
	}
	if ( ! (1 & OMmsg))
	{
	    *msg = MSFAIL;
	}
    }
 
    return( OMmsg );
}
end implementation GRcontext;
