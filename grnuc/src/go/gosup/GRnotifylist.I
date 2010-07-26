/* #######################    APOGEE COMPILED   ######################## */
class implementation GRnotify;

#include "grimport.h"

#include "DPdlist.h"

from GRlistener import GRnotifylis;


static OM_S_CHANSELECT  chandef;

%safe
static IGRint	chan_defined=0;
%endsafe

GRnotifylisteners(msg,OMmsg,mask,gr_message,gr_objid)

IGRlong		*msg;
IGRlong		*OMmsg;
IGRint		*mask;
OM_S_MESSAGE	*gr_message;
GRobjid		*gr_objid;
{
    IGRlong 		status;
    OMuint		count;
 
    status = OM_S_SUCCESS;

    /* notify the display list */
    DPdlist_wireframe_notify( *gr_objid, OM_Gw_current_OS, *mask );

    if (*mask & (GR_GEOM_MODIFIED | GR_GEOM_XFORMED | GR_GEOM_POSTED))
        om$change_tag_version(objid = *gr_objid);
  
    if ( ! chan_defined)
    {
				/* set up the channel information	*/
        status = om$make_chanselect(channame = "GRnotify.notification",
	    p_chanselect = &chandef);

	if (! (1 & status))
	{
	    goto wrapup;
	}

	chan_defined = 1;
    }
    				/* see if there are any listeners	*/
    status = om$get_channel_count(
            objid = *gr_objid,
            p_chanselect = &chandef,
            count = &count);    

    if ((1 & status) && (count))
    {				/* send notification to the listeners	*/
	status = om$send(
            msg = message GRlistener.GRnotifylis
		(msg,OMmsg,(long *)mask,gr_message),
            senderid = *gr_objid,
            p_chanselect = &chandef);
    }

wrapup:
    return (1);			/* cannot fail always return 1		*/
}
end implementation GRnotify;
