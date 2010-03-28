/* #######################    APOGEE COMPILED   ######################## */
class implementation GRvg;

#include "grimport.h"
#include "msdef.h"

IGRlong GRconnchannels(msg,reffile,Super_id,context_id)

IGRlong		*msg;
struct GRid	*reffile;
struct GRid	*Super_id;
struct GRid	*context_id;

{
    IGRboolean  prev_tag,
		prev_state;

    IGRlong	OMmsg;

    GRspacenum  prev_osnum,
		dummy;

    IGRint 	index, count; 

    struct GRid curr_ctx;

    OM_S_CHANSELECT chan,
		context_chan;

    OMmsg = OM_S_SUCCESS;
    *msg = MSSUCC;
    index = OM_K_MAXINT;

    chan.type = OM_e_name;
    context_chan.type = OM_e_name;
            
    if (reffile)
    {
	/* connect the context object to the reference file object.
	 * This connection is a tagged connection.
	 */

        chan.u_sel.name = "GRcontext.to_reffile";

	context_chan.u_sel.name = "GRreffile.to_context";

	prev_state = om$enable_tagging(flag = TRUE);
	prev_tag = om$enable_tag_connects(flag = TRUE);

	om$set_tag_os(p_prev_osnum = &prev_osnum,
		osnum = reffile->osnum);
	
        OMmsg = om$send(msg = message Root.connect
		(context_chan,0,context_id->objid,context_id->osnum,
		 chan,0),
	    senderid = context_id->objid,
	    targetid = reffile->objid,
	    targetos = reffile->osnum);

	if (prev_tag)
	{
	    om$set_tag_os(p_prev_osnum = &dummy,
		osnum = prev_osnum);
	}
	else
	{
	    om$enable_tag_connects(flag = FALSE);
	}	
	om$enable_tagging(flag = prev_state);
	
        if (!( 1 & OMmsg))
	{
	    goto wrapup;
	}
    }
    if (Super_id)
    {
	/* connect the context object to the reference file Super.
	 */

	chan.u_sel.name = "Super_rfmgr.to_context";
      
	context_chan.u_sel.name = "GRcontext.to_super";
	
	OMmsg = om$send(mode = OM_e_wrt_object,
		msg = message Root.connect(chan,index,
			    context_id->objid,context_id->osnum,
			    context_chan,index),
		senderid = context_id->objid,
		targetid = Super_id->objid,
		targetos = Super_id->osnum);
    }
  
    if ( 1 & OMmsg)
    {				/* connect to nested files	*/
        if( ASMget_splitpart() == FALSE)
            GRgetcurrentctx(msg,&curr_ctx);
        else
          {
             chan.u_sel.name = "Super_rfmgr.to_context";

             om$get_channel_count(p_chanselect = &chan,
                     osnum = Super_id->osnum,
                     objid = Super_id->objid,
                     count = (OMuint *)&count);

             if (count)      /* object already exists                */
             {
                 om$get_objid_at_index(
                         osnum = Super_id->osnum,
                         objid = Super_id->objid,
                         p_chanselect = &chan,
                         index = 0,
                         objidaddr = &curr_ctx.objid,
                         osnumaddr = &curr_ctx.osnum);
             }


          }


	context_chan.u_sel.name = "GRcontext.to_nested_files";
	
        OMmsg = om$send(mode = OM_e_wrt_object,
			msg = message Root.connect
			    (context_chan,index,
			    context_id->objid,context_id->osnum,
			    context_chan,index),
			senderid = context_id->objid,
			targetid = curr_ctx.objid,
			targetos = curr_ctx.osnum);
    }
wrapup:
    return(OMmsg);
}
end implementation GRvg;
