/*
Name
        GRreffile.GRchgweight

Description
        This method changes the weight of the graphics object.

Synopsis
	GRchgweight(msg,weight)
        IGRlong *msg                    output completion code
                                                MSSUCC - successful completion
        IGRchar unsigned *weight        input - new weight 

History
	MAS     04/02/86 : Design date.
        dhm     07/06/92 : ANSI conversion.
        mrm     04/02/93 : Fixed typecast for color
*/

class implementation GRreffile;

#include "grimport.h"
#include "msdef.h"
#include "godef.h"
#include "gocmacros.h"
#include "refdef.h"

method GRchgweight(IGRlong *msg; IGRuchar *weight)
{
	IGRlong	OMmsg;

	OMmsg = OM_S_SUCCESS;
	*msg = MSSUCC;

	if (me->ref_properties & GROVERRIDE_SYMBOLOGY)
	{
	    me->display_attr.weight = *weight;
 	}
	else
	{
	    me->ref_properties |= GROVERRIDE_SYMBOLOGY;
	    me->display_attr.weight = *weight;
	    me->display_attr.style = (IGRuchar) ~0;
	    me->display_attr.color = (unsigned short) ~0;
	}

	GR_NOTIFY_LISTENERS(msg,&OMmsg,GR_ATTR_MODIFIED);

	return(OM_S_SUCCESS);
}

end implementation GRreffile;

