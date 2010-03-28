/*
Name
        GRntfyconn.I

Abstract
	This method connects the graphic object and the notification
	listener.

Arguments	
        IGRlong         *msg                    completion code
        struct GRid     *listeners_id           the listeners objid, osnum
        OM_S_CHANSELECT *listeners_chan         the listeners channel
        IGRint          *listeners_index        the index on the listeners 
                                                channel for the connection
        IGRboolean      *make_tagged_connect    flag to indicate a tagged 
                                                connection should be made
        OMuword         *tagged_os              the object space number 
                                                containing the tagged object

Return Values
    	*msg    MSSUCC if successful
	        MSFAIL error occurred
*/
	
class implementation GRnotify;

#include "grimport.h"
#include "msdef.h"
#include "godef.h"
#include "gocmacros.h"

method GRntfyconn(IGRlong *msg; 
                  struct GRid *listeners_id; 
                  OM_S_CHANSELECT *listeners_chan; 
                  IGRint *listeners_index;
                  IGRboolean *make_tagged_connect; 
                  OMuword *tagged_os)
{
    OMuint              dummy_tag;
    OMuword             prev_osnum, dummy;
    OMuint	        prev_tag, prev_state;
    IGRlong  	        OMmsg;
    OM_S_CHANSELECT     my_channel;
  
    *msg = MSSUCC;
    OMmsg = OM_S_SUCCESS;
    prev_tag = prev_state = 0;

    OMmsg = om$make_chanselect(p_chanselect = &my_channel,
                               channame = "GRnotify.notification");
    if (1 & OMmsg)
    {
	if (*make_tagged_connect)
	{
	    prev_state = om$enable_tagging(flag = TRUE);
	    prev_tag = om$enable_tag_connects(flag = TRUE);
	    om$set_tag_os(p_prev_osnum = &prev_osnum,
                          osnum = *tagged_os);

            /*
                Make sure both objects are tagged.  The object in the
                reference file *must* have the tag to avoid ISO connections.
                The object in the master file does not necessarily have to
                have the tag, but it doesn't hurt to put it there just in
                case.  The return status from om$add_tag is ignored; someone
                may have turned off tagging for a valid reason.
            */

            OMmsg = om$objid_to_tag(p_tag = &dummy_tag);
            if (OMmsg == OM_W_NOTTAGGED)
            {
                om$add_tag(p_tag = &dummy_tag); /* ignore return status */
            }
                                    
            OMmsg = om$objid_to_tag(osnum = listeners_id->osnum,
                                    objid = listeners_id->objid,
                                    p_tag = &dummy_tag);
            if (OMmsg == OM_W_NOTTAGGED)
            {
                om$add_tag(osnum = listeners_id->osnum,
                           objid = listeners_id->objid,
                           p_tag = &dummy_tag);
            }
   	}

	OMmsg = om$send(msg = message Root.connect(*listeners_chan,
                                                   OM_K_MAXINT,
                                                   my_id,
                                                   OM_Gw_current_OS,
                                                   my_channel,
                                                   *listeners_index),
                        senderid = my_id,
                        targetid = listeners_id->objid,
                        targetos = listeners_id->osnum);

	if (*make_tagged_connect)
	{
	    if (prev_tag)
	    {
	    	om$set_tag_os(p_prev_osnum = &dummy, osnum = prev_osnum);
	    }
	    else
	    {
	    	om$enable_tag_connects(flag = FALSE);
	    }

	    if (!prev_state)
	    {
	    	om$enable_tagging(flag = FALSE);
	    }
	}	
    }
    else
    {
	*msg = MSFAIL;
    }

    GR_NOTIFY_LISTENERS(msg,&OMmsg,GR_CHANNEL_USED);

    return(OMmsg);
}
end implementation GRnotify;
