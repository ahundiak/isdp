/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
   GRreplace

Description
   This method will replace an owner and its components with a new 
   definition of that owner and its components.

   *msg           IGRlong              completion code 
   *mod_env       struct GRmd_env      The module environment
   *lib_env       struct GRmd_env      The library environment
   *def_id        struct GRid          The definition id
   *new_id        struct GRid          The new id

Return Values
   MSSUCC  if successful
   MSFAIL  if failure

History
   Gray Winn   01/18/87    creation date
   Gray Winn   11/09/87    Changes for version 1.1
   Gray Winn   04/06/88    moved from GRsmhdr to GRowner
\*/

class implementation GRsmhdr;

#include "grimport.h"
#include "msdef.h"
#include "gocmacros.h"

method GRreplace (IGRlong *msg; struct GRmd_env *mod_env;
                  struct GRmd_env *lib_env; struct GRid *def_id;
                  struct GRid *new_id)
{
IGRlong           om_msg;
IGRint            count;
IGRint            definition_created;
struct GRid       original_sdh_id;
struct GRid       new_sdh_id;
OM_S_CHANSELECT   chansel;

   *msg = MSSUCC;
   new_id->osnum = OM_Gw_current_OS;
   new_id->objid = my_id;
   chansel.type = OM_e_name;
   chansel.u_sel.name = "GRcmpowner.to_components";

   /*
    *  Copy the symbol definition
    */

   definition_created = FALSE;
   new_sdh_id.osnum = mod_env->md_id.osnum;
   om_msg = om$send(
            msg = message GRgraphics.GRcopy(msg, lib_env, mod_env,
            &new_sdh_id.objid), 
            targetid = def_id->objid,
            targetos = def_id->osnum);

   if (om_msg & *msg & 1)
   {
      definition_created = TRUE;

      /*
       *  Get the original sdh id.
       */

      om_msg = om$send (
               msg = message GRowner.GRget_components (msg, mod_env,
               &original_sdh_id, 1, &count, NULL, OM_K_MAXINT), 
               targetid = my_id);

      if (om_msg & *msg & 1)
      {
         /*
          *  send message to self to move symbol header to a new symbol
          *  definition header.
          */

         om_msg = om$send(
                  msg = message GRsmhdr.GRmv_sh_to_new_sdh (msg, mod_env,
                  &new_sdh_id), targetid = my_id); 

         if (om_msg & *msg & 1)
         {
            definition_created = FALSE;

            /*
             *  Send message cleanup to original cell definition header.
             */

            om_msg = om$send(
                     msg = message GRgraphics.GRdelete (msg, mod_env),
                     targetid = original_sdh_id.objid,
                  targetos = original_sdh_id.osnum);
         }
      }
   }

   if ((!(om_msg & *msg & 1)) && definition_created)
   {
      om_msg = om$send(
               msg = message GRgraphics.GRdelete (msg, mod_env),
               targetid = new_sdh_id.objid,
               targetos = new_sdh_id.osnum);
   }

   GR_NOTIFY_LISTENERS(msg, &om_msg, GR_GEOM_MODIFIED);
   return (om_msg);
}
end implementation GRsmhdr;
