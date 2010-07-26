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
   HGW  11/02/87 : Changes for version 1.1
\*/

class implementation GRsmdfhdr;

#include "grimport.h"
#include "msdef.h"
#include "OMerrordef.h"
#include "grsymdef.h"
#include "grsymmacros.h"

method GRdelete_owner (IGRlong *msg; struct GRmd_env *mod_env)
{
IGRlong           om_msg;
OM_S_CHANSELECT   chansel;

   *msg = MSSUCC;
   om_msg = OM_S_SUCCESS;
   chansel.type = OM_e_name;
   chansel.u_sel.name = "GRcmpowner.to_components";

   /* 
    *  If the object is named then remove the object from 
    *  the symbol index object.
    */

   if (strlen(me->symbol_name))
   {
      om_msg = gr$symsd_remove( msg = msg,
               sl_osnum = mod_env->md_id.osnum,
               sd_name = me->symbol_name, 
               sd_objid = my_id);
   }

   if (om_msg & *msg & 1)
   {
      om_msg = om$send (
               msg = message Root.wild_disconnect (chansel),
               targetid = my_id);
      /*
       *  Send a delete msg wrt to my owner
       */

      om_msg = om$send (
               msg = message Root.delete (NULL),
               targetid = my_id);
   }
   return (om_msg);
}
end implementation GRsmdfhdr;
