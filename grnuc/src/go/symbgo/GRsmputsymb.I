/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
   GRputsymb

Description
   This method defines the symbology of the symbol header.

   *msg        IGRlong              completion code
   *symb       struct GRsymbology   symbology internal format

Return Vales
   MSSUCC - successful completion

History
   HGW     07/07/86 : Design date.
   HGW     08/07/86 : Changed terminology.
   HGW     11/05/87 : Changes for version 1.1
\*/

class implementation GRsmhdr;

#include "grimport.h"
#include "msdef.h"
#include "grsymdef.h"
#include "gocmacros.h"

method GRputsymb(IGRlong *msg; struct GRsymbology *symb)
{
IGRlong  om_msg;

   *msg = MSSUCC;

   om_msg = om$send (mode=OM_e_wrt_message,
            msg = message GRvg.GRputsymb (msg, symb),
            senderid = my_id, targetid = my_id);

   me->owner_properties |= GR_SYM_DISPLAY_ATTR;
   GR_NOTIFY_LISTENERS(msg, &om_msg, GR_ATTR_MODIFIED);
   return(om_msg);
}
end implementation GRsmhdr;
