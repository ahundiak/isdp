/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
   GRdrop

Description
   This method drops a symbol object.  The method will make a copy of
   all objects in the symbol into the active module space, and then 
   delete the symbol header object.

   *msg         IGRlong         completion code
   *mod_env     GRmd_env        module environment

Algorithm
   First a copy of all objects in the symbol definition are copied to 
   the specified space, then the objects are transformed by the symbol
   placement matrix.   Next, the delete message is sent to the symbol 
   header.  The delete method will perform what ever cleanup is needed.

Return Values
   MSSUCC if successful
   MSFAIL (severe) if failure

History
   HGW  07/28/86 : Design Date and Creation Date
   HGW  08/07/86 : Changed terminology
   HGW  11/06/87 : Changed for version 1.1
\*/

class implementation GRsmhdr;

#include "grimport.h"
#include "msdef.h"
#include "madef.h"
#include "OMerrordef.h"
#include "grsymdef.h"
#include "gocmacros.h"
#include "grerr.h"

from GRsmdfhdr    import GRcp_sd_to_ams;

method GRdrop  (IGRlong *msg; struct GRmd_env *mod_env)
{
IGRlong              om_msg;
IGRlong              ret_msg;
IGRint               i;                
IGRint               dis_attr;
IGRmatrix            matrix;  
struct GRsymbology   symb;
struct GRmd_env      local_mod_env;
struct IGRaltdisplay display_attr;
OM_S_CHANSELECT      chansel;

   *msg = MSSUCC;
   om_msg = OM_S_SUCCESS;
   chansel.type = OM_e_name;
   chansel.u_sel.name = "GRcmpowner.to_components";

   MAidmx (msg, matrix);

   /*
    *  Get the local module environment of the components.
    */

   om_msg = om$send (
            msg = message GRowner.GRget_context (msg, mod_env,
            &local_mod_env), targetid = my_id);


   /*
    *  Get the placement matrix of the symbol header into matrix.
    */

   for (i = 0; i < 3; ++i){
      matrix[i]   = me->matrix[i];
      matrix[i+4] = me->matrix[i+3];
      matrix[i+8] = me->matrix[i+6];
      matrix[4*i+3] = me->origin[i];
   }

   if (om_msg & *msg & 1)
   {
      /*
       *  If my display attributes are defined then retrive
       *  the display attributes.
       */

      om_msg = om$send(
               msg = message GRvg.GRgetsymb(&ret_msg, &symb),
               targetid = my_id);

      if (om_msg & ret_msg & 1)
      {
         if (ret_msg == GR_I_NODISATTR)
         {
            dis_attr = FALSE;
         }else
         {
            dis_attr = TRUE;
            if (me->owner_properties & GR_SYM_COLOR)
            {
               display_attr.color = &symb.display_attr.color;
            }else
            {
               display_attr.color = NULL;
            }

            if (me->owner_properties & GR_SYM_WEIGHT)
            {
               display_attr.weight = &symb.display_attr.weight;
            }else
            {
               display_attr.weight = NULL;
            }

            if (me->owner_properties & GR_SYM_STYLE)
            {
               display_attr.style = &symb.display_attr.style;
            }else
            {
               display_attr.style = NULL;
            }
         }

         /*
          *  Send a message to copy the symbol definition to the
          *  specified space.  Display attributes are sent if 
          *  defined by the symbol reference header.  A NULL 
          *  address is sent for the target object.
          */

         om_msg = om$send(
                  msg = message GRsmdfhdr.GRcp_sd_to_ams (msg, matrix,
                  (dis_attr) ? &display_attr : NULL, 
                  NULL, &local_mod_env, mod_env),
                  p_chanselect = &chansel);

         if (om_msg & *msg & 1)
         {
            /*
             *  Delete the symbol header.  This method will perform all
             *  neccessary cleanup.
             */

            om_msg = om$send(mode = OM_e_wrt_object,
                     msg = message GRowner.GRdelete (msg, mod_env ),
                     senderid = my_id, targetid = my_id);
         }
      }
   }

   GR_NOTIFY_LISTENERS(msg, &om_msg, GR_DELETED);
   return (om_msg);
}
end implementation GRsmhdr;
