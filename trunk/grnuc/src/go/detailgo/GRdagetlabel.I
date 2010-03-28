/*\
Name
    GRget_drawview_label

Description
    This method returns the label of the drawing view.

Arguments
    *msg           IGRlong           return code
    *label         IGRchar           label string

Return Values
    MSSUCC   -  if success
    MSFAIL   -  if failure
\*/

class implementation GRdvattach;

#include "grimport.h"
#include "msdef.h"
#include "OMerrordef.h"
#include "OMmacros.h"
#include "detaildef.h"
#include "exfi.h"

from GRtext import GRgettxattr;

method GRget_drawview_label (IGRlong *msg; IGRchar *label)
{
    IGRlong         om_msg;
    IGRshort        length;
    IGRchar         *text;
    struct IGRestx  *text_attr;

    *msg = MSSUCC;

    text = NULL;
    text_attr = NULL;
    om_msg = GRcomponent_pass_fun ( msg, 
                                    message GRtext.GRgettxattr
                                                    ( msg, 
                                                      text_attr, 
                                                      &length,
                                                      (IGRuchar **)&text), 
                                    GR_DV_TEXTNAME, 
                                    my_id, 
                                    OM_Gw_current_OS);

    if ( text && (length < EXFI_STRLEN))
    {
        strncpy (label, text, length);
        label[length] = '\0';
        om$dealloc ( ptr = text );
    }
    else label[0] = '\0';

    return(om_msg);
}
end implementation GRdvattach;
