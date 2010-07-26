/*
Name
        GRvg.GRchgprops

Abstract
        This method sets or clears bits in the properties word based on the
        input mask.

Description
        Given a mask, this method adjusts the object's properties word by
        clearing, replacing or setting the the properties word with the
        indicated mask.

Synopsis
	GRchgprops(msg, action, mask)
        IGRlong *msg            Out - completion code message
				    MSSUCC if successful
				    MSINARG if invalid action requested
        IGRshort *action	In - indictor of whether to set or clear the
                                properties
				    1  - set with mask
				    0  - clear using mask
				    -1 - replace properties with input
					 properties
        IGRshort *mask         	In - mask to be used

History
	SDG 	06/24/86 : Creation date.

*/

class implementation GRvg;

#include "grimport.h"
#include "msdef.h"
#include "godef.h"
#include "gocmacros.h"
#include "madef.h"

extern IGRboolean MAidmx();

method GRchgprops(IGRlong *msg; IGRshort *action; IGRshort *mask)

{

	IGRshort  mx_type,
		  local_mask;

	IGRlong   OMmsg;


	IGRmatrix mx;

	struct GRprops geom_props;

	*msg = MSSUCC;
	OMmsg = OM_S_SUCCESS;

	if (*action)
	{
	    local_mask = *mask;

	    if (*mask & GRFILLED_DISPLAY)
	    {
	    	MAidmx(msg,mx);
	    	mx_type = MAIDMX;

		OMmsg = om$send (msg = message GRvg.GRgeomprops
			(msg, &mx_type,mx,&geom_props),
		    targetid = my_id);

	        if ( !( 1 & OMmsg & *msg))
		{
		    OMmsg = OM_E_ABORT;
		    goto wrapup;
		}

		if (! geom_props.phy_closed)
		{
		    local_mask &= (~GRFILLED_DISPLAY);
		}
	    }
	    if ( *action == 1)			/* set bits		*/
	    {
	        me->properties = me->properties | local_mask;
	    }
	    else if (*action == -1)		/* replace properties  */
	    {
	    	me->properties = local_mask;
	    }
	    else
	    {
	        *msg = MSINARG;
	    	OMmsg = OM_E_ABORT;
	    }
	}
	else				/* clear bits		*/
	{
	    me->properties = me->properties &  ~*mask;
	}

	GR_NOTIFY_LISTENERS(msg,&OMmsg,GR_ATTR_MODIFIED);
wrapup: 
	return(OMmsg);

}

end implementation GRvg;
