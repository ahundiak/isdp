/* #######################    APOGEE COMPILED   ######################## */
class implementation GRconnector;

#include "grimport.h"
#include "msdef.h"

from GRcmpowner import GRlocowner;

GRfindowner(msg,objid,osnum,cvl,loc_parms,action,action_taken)

IGRlong		*msg;		/* completion code			
					MSSUCC - successful completion
					MSFAIL - error occured		*/
GRobjid		*objid;
GRspacenum 	*osnum;
struct GRlc_cvl *cvl;
struct GRlc_info *loc_parms;
enum GRlocate_action *action;
IGRint		*action_taken;	/* action taken			
				   0 - action handler not called
				   1 - all owners failed	
				   2 - owner handled action		*/

{
    OM_S_CHANSELECT	chandef;
    IGRlong 		OMmsg;
    IGRint		count,
			cnt,i;

    *action_taken = 0;
    *msg = MSSUCC;
    OMmsg = OM_S_SUCCESS;

	     	 		/* find out if object has any owners */
    OMmsg = om$make_chanselect(channame = "GRconnector.to_owners",
	 p_chanselect = &chandef);

    if ( 1 & OMmsg)
    {
	OMmsg = om$get_channel_count(
	    osnum = *osnum,
            objid = *objid,
            p_chanselect = &chandef,
            count = &count);    

	if (1 & OMmsg)
	{
	    cnt = 0;

    	    for (i = 0; i < count; ++i)
	    {
	        OMmsg = om$send(
                    msg = message GRcmpowner.GRlocowner
			(cvl,loc_parms,action),
                    senderid = *objid,
                    p_chanselect = &chandef,
                    from = i,
                    to = i);

		if (OMmsg == OM_I_STOP_SENDING)
		{
		    *action_taken = 2;
		    cnt=0;
		    i = count;
		}
		else if (! (1 & OMmsg))
		{
		    ++cnt;
	      	    OMmsg = OM_S_SUCCESS;
	        }
	    } 
	    if (count) 
	    {
		if (cnt == count)
		{
		    *action_taken = 1;
		}
		else
		{
		    *action_taken = 2;
		}
	    }
	}
    }

    return (OMmsg);
}
end implementation GRconnector;
