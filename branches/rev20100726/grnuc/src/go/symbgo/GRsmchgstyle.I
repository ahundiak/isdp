/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
   GRchgstyle

Description
   This method changes the style of a symbol header object.

   *msg        IGRlong              completion code
   *style      IGRuchar             new style

Return Values
   MSSUCC - successful completion

History
   HGW   07/21/86 : Design date and Creation date
   HGW   11/04/87 : Changes for version 1.1
   scw   07/23/92 : ansi conversion
\*/

class implementation GRsmhdr;

#include "grimport.h"
#include "msdef.h"
#include "OMerrordef.h"
#include "grsymdef.h"
#include "gocmacros.h"

method GRchgstyle(IGRlong *msg;  IGRuchar *style)
{
IGRlong  om_msg;

   *msg = MSSUCC;
   om_msg = OM_S_SUCCESS;

   om_msg = om$send (mode = OM_e_wrt_message,
            msg = message GRvg.GRchgstyle (msg, style),
            senderid = my_id, targetid = my_id);

   me->owner_properties |= GR_SYM_STYLE;
   GR_NOTIFY_LISTENERS(msg, &om_msg, GR_ATTR_MODIFIED);
   return(om_msg);
}
end implementation GRsmhdr;

