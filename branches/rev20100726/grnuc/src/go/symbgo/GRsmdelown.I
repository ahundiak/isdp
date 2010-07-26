/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
   GRdelete_owner

Description
   The method is used to delete the header object and not the components.

   *msg           IGRlong              return code 
   *mod_env       struct GRmd_env      The module environment

Return Values
   MSSUCC   -  if successful.
   MSFAIL   -  if failure.

History
   HGW  07/28/86 : Design Date and Creation Date
   HGW  08/07/86 : Changed terminolgy
   HGW  11/04/87 : Chnges for version 1.1
\*/

class implementation GRsmhdr;

#include "grimport.h"
#include "msdef.h"
#include "gocmacros.h"

method GRdelete_owner (IGRlong *msg; struct GRmd_env *mod_env)
{
IGRlong           om_msg;
OM_S_CHANSELECT   chansel;

   *msg = MSSUCC;
   chansel.type = OM_e_name;
   chansel.u_sel.name = "GRcmpowner.to_components";

   om_msg = om$send(mode = OM_e_wrt_message, 
            msg = message GRvg.GRdelete (msg, mod_env),
            targetid = my_id);

   om_msg = om$send(
            msg = message Root.wild_disconnect (chansel),
            targetid = my_id);

   GR_NOTIFY_LISTENERS(msg, &om_msg, GR_DELETED);
   return (om_msg);
}
end implementation GRsmhdr;

