/*
Name
        GRreffile.GRchgstyle

Description
        This method changes the style of the graphics object.

Synopsis
	GRchgstyle(msg,style)
        IGRlong *msg                    output completion code
                                                MSSUCC - successful completion
        IGRchar unsigned *style        input - new style 

History
	MAS     04/02/86 : Design date.
        dhm     07/05/92 : ANSI conversion.
        mrm     04/02/93 : Fixed typecast for color
*/

class implementation GRreffile;

#include "grimport.h"
#include "msdef.h"
#include "godef.h"
#include "gocmacros.h"
#include "refdef.h"

method GRchgstyle(IGRlong *msg;  IGRuchar *style)
{
	IGRlong	OMmsg;

	OMmsg = OM_S_SUCCESS;
	*msg = MSSUCC;

	if (me->ref_properties & GROVERRIDE_SYMBOLOGY)
	{
	    me->display_attr.style = *style;
 	}
	else
	{
	    me->ref_properties |= GROVERRIDE_SYMBOLOGY;
	    me->display_attr.style = *style;
	    me->display_attr.weight = (IGRuchar) ~0;
	    me->display_attr.color = (unsigned short) ~0;
	}

	GR_NOTIFY_LISTENERS(msg,&OMmsg,GR_ATTR_MODIFIED);

	return(OM_S_SUCCESS);
}

end implementation GRreffile;
