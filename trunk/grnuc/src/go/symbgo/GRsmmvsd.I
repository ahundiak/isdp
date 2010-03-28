/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
   GRmv_sh_to_new_sdh

Description
   This method is used to move a symbol header to a new symbol 
   definition header.  

   *msg           IGRlong              return code 
   *mod_env       struct GRmd_env      The module environment
   *new_sdh_id    struct GRid          The symbol definition to 
                                       connect to.

RETURN VALUES
   MSSUCC   -  if successful.
   MSFAIL   -  if failure.

HISTORY
   Gray Winn   01/18/87 :  creation date
   Gray Winn   11/09/87 :  Changes for version 1.1
   scw         07/23/93 :  ansi conversion
\*/

class implementation GRsmhdr;

#include "grimport.h"
#include "msdef.h"
#include "gocmacros.h"

method GRmv_sh_to_new_sdh (IGRlong *msg; struct GRmd_env *mod_env;
                            struct GRid *new_sdh_id)
{
IGRlong              om_msg;
IGRlong              ret_msg;
IGRlong              index;
IGRlong              flag;
GRrange              old_range;
GRrange              new_range;
IGRboolean           world;
OM_S_CHANSELECT      chansel;
OM_S_CHANSELECT      own_chansel;
struct GRpost_info   post_info;
struct GRid          my_GRid;

   *msg = MSSUCC;
   world = FALSE;
   flag = FALSE;
   index = OM_K_MAXINT;
   my_GRid.objid = my_id;
   my_GRid.osnum = OM_Gw_current_OS;
   chansel.type = OM_e_name;
   chansel.u_sel.name = "GRcmpowner.to_components";
   own_chansel.type = OM_e_name;
   own_chansel.u_sel.name = "GRconnector.to_owners";

   om_msg = GRis_symbol_replacable (OM_Gw_current_OS, my_id, &own_chansel);

   if (om_msg & 1)
   {   
      om_msg = om$send(
               msg = message GRvg.GRgetrang (&ret_msg, NULL, NULL, 
               &world, old_range ), targetid = my_id );
      
      if (om_msg & ret_msg & 1)
      {
         /*
          *  Disconnect the symbol header from the the symbol definition
          *  header.
          */

         om_msg = om$send(
                  msg = message GRconnector.GRdisconn (&ret_msg, &my_GRid),
                  p_chanselect = &chansel);

         if (om_msg & ret_msg & 1)
         {
            /*
             *  Connect the symbol reference to the new symbol definition
             *  header.
             */

            om_msg = om$send(
                     msg = message GRconnector.GRflexconn (&ret_msg, &flag,
                     &my_GRid, &index, &index),
                     targetid = new_sdh_id->objid, 
                     targetos = new_sdh_id->osnum);

            if (om_msg & ret_msg & 1)
            {
               /*
                *  Get the new range of the symbol reference.
                */

               om_msg = om$send(
                        msg = message GRvg.GRgetrang (&ret_msg, NULL, NULL,
                        &world, new_range ), targetid = my_id );

               if (om_msg & ret_msg & 1)
               {  
                  /*
                   *  Update the rtree.
                   */

                  post_info.construct_flag = FALSE;
   
                  om_msg = GRupdaterng(&ret_msg, mod_env, &post_info,
                           &my_id, &me->properties, old_range, new_range);
               }
            }
         }
      }
   }else
   {  
      om_msg = OM_S_SUCCESS;
   }
   GR_NOTIFY_LISTENERS(msg, &om_msg, GR_GEOM_MODIFIED);
   return (om_msg);
}
end implementation GRsmhdr;
