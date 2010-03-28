/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
   GRchgcolor

Description
   This method changes the color of an object.

   *msg           IGRlong              completion code
   *rgb_value     IGRuint              rgb value
   *color         IGRushort            new color

Return Values
   MSSUCC  -- successful completion
   MSFAIL  -- failure

HISTORY
   HGW   07/21/86 : Desigin and Creation date
   scw   07/23/92 : ansi conversion
\*/

class implementation GRsmhdr;

#include "grimport.h"
#include "msdef.h"
#include "OMerrordef.h"
#include "grsymdef.h"
#include "gocmacros.h"

method GRchgcolor(IGRlong *msg; IGRuint *rgb_value;
                  IGRushort *color)
{
IGRlong  om_msg;

   *msg = MSSUCC;
   om_msg = OM_S_SUCCESS;

   om_msg = om$send (mode = OM_e_wrt_message,
            msg = message GRvg.GRchgcolor (msg, rgb_value, color),
            senderid = my_id, targetid = my_id);

   me->owner_properties |= GR_SYM_COLOR;
   GR_NOTIFY_LISTENERS(msg, &om_msg, GR_ATTR_MODIFIED);
   return(om_msg);
}

end implementation GRsmhdr;

