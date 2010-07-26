/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
   GRchgweight

Description
   This method changes the weight of the symbol header.

   *msg       IGRlong               completion code
   *weight    IGRuchar              new weight 

Return Values
   MSSUCC - successful completion

History
   HGW   07/21/86 :  Design date and  Creation date   
   HGW   11/04/87 :  Changed for version 1.1
   scw   07/23/92 :  ansi conversion
\*/

class implementation GRsmhdr;

#include "grimport.h"
#include "msdef.h"
#include "OMerrordef.h"
#include "grsymdef.h"
#include "gocmacros.h"

method GRchgweight(IGRlong *msg; IGRuchar *weight)
{
IGRlong  om_msg;

   *msg = MSSUCC;
   om_msg = OM_S_SUCCESS;

   om_msg = om$send (mode = OM_e_wrt_message,
            msg = message GRvg.GRchgweight (msg, weight),
            senderid = my_id, targetid = my_id);

   me->owner_properties |= GR_SYM_WEIGHT;
   GR_NOTIFY_LISTENERS(msg, &om_msg, GR_ATTR_MODIFIED);
   return(om_msg);
}
end implementation GRsmhdr;

