/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
   GRgetsymb

Description
   This method retrieves the symbology of symbol header.

   *msg         IGRlong                completion code
   *symb        struct GRsymbology     symbology internal format

Return Values
   MSSUCC - successful completion

Notes
   If the symbol header display attributes flag is not set.  Then the
   method returns an informational msg and the symbology of the first
   component.

History
   HGW   07/21/86 : Design date and Creation date
   HGW   07/21/86 : Changed Terminology
   HGW   11/05/87 : Changes for version 1.1
\*/

class implementation GRsmhdr;

#include "grimport.h"
#include "msdef.h"
#include "OMerrordef.h"
#include "grsymdef.h"
#include "grerr.h"
#include "gocmacros.h"

method GRgetsymb(IGRlong *msg; struct GRsymbology *symb)
{
IGRlong  om_msg;

   *msg = MSSUCC;
   om_msg = OM_S_SUCCESS;

   /*
    *  If the display attributes are defined for the symbol reference
    *  then return MSSUCC else return GR_I_NODISATTR and the symbology
    *  of the first component.
    */

   om_msg = om$send (mode = OM_e_wrt_message,
            msg = message GRvg.GRgetsymb(msg, symb), 
            targetid = my_id);

   if (!(me->owner_properties & GR_SYM_DISPLAY_ATTR))
   {
      *msg = GR_I_NODISATTR;
   }
   return(om_msg);
}
end implementation GRsmhdr;
