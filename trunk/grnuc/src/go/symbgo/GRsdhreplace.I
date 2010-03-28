/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
   GRreplace

Description
   This method will replace an owner and its components with a new 
   definition of that owner and its components.  This method moves all
   symbol headers pointing to this definition to another symbol 
   definition header and cleans up this definition.

   *msg           IGRlong              completion code 
   *mod_env       struct GRmd_env      The module environment
   *lib_env       struct GRmd_env      The library environment
   *def_id        struct GRid          The definition id
   *new_id        struct GRid          The new id

Return Values
   MSSUCC  if successful
   MSFAIL  if failure

History
   Gray Winn   02/01/87    creation date
   Gray Winn   11/03/87    changed for version 1.1
   Gray Winn   04/06/88    moved message from GRsmdfhdr to GRowner
   scw         07/23/92    ansi conversion
\*/

class implementation GRsmdfhdr;

#include "grimport.h"
#include "msdef.h"

from GRsmhdr   import   GRmv_sh_to_new_sdh;

method GRreplace (IGRlong *msg; struct GRmd_env *mod_env;
                  struct GRmd_env *lib_env; struct GRid *def_id;
                  struct GRid *new_id)
{
IGRlong           om_msg;
OMuint            count;
IGRint            i;
OM_S_CHANSELECT   chansel;

   *msg = MSSUCC;
   chansel.type = OM_e_name;
   chansel.u_sel.name = "GRconnector.to_owners";

   /*
    * Copy the symbol definition to the local symbol library.
    */

   new_id->osnum = mod_env->md_id.osnum;
   om_msg = om$send(
            msg = message GRgraphics.GRcopy(msg, lib_env, mod_env,
            &new_id->objid),
            targetos = def_id->osnum, targetid = def_id->objid);

   if (om_msg & *msg & 1)
   {
      if ((new_id->objid != my_id) || 
          (new_id->osnum != OM_Gw_current_OS))
      {
         om_msg = om$get_channel_count (object= me, 
                  p_chanselect = &chansel, count = &count);

         /*
          *  send message to all instances of the symbol definition to 
          *  move to the new sdh.
          */
   
         for (i=count-1; i >= 0; --i)
         {
            om_msg = om$send(
                     msg = message GRsmhdr.GRmv_sh_to_new_sdh (msg, 
                     mod_env, new_id),    
                     p_chanselect = &chansel, from = i, to = i);
         }

         /*
          *  Send delete to self.
          */

         om_msg = om$send(
                  msg = message GRgraphics.GRdelete (msg, mod_env),
                  targetid = my_id);
      }
   }
   return (om_msg);
}
end implementation GRsmdfhdr;
