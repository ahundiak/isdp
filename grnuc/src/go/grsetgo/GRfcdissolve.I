/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
   GSdissolve 

Description
   This method is used to disconnect all members from the graphics
   set and then delete the graphics set.

    *msg         IGRlong        return code

Return Values
   MSSUCC  -- successful completion
   MSFAIL  -- failure

History
     Gray Winn    11/02/86    Creation date.
     msm          07/10/92    ANSI-C conversion.
\*/

class implementation GRfcset;

#include "grimport.h"
#include "msdef.h"
#include "grgsdef.h"

method GSdissolve (IGRlong *msg )
{
IGRlong           om_msg;
unsigned int      count;
OM_S_CHANSELECT   chansel;

   *msg = MSSUCC;
   chansel.type = OM_e_name;
   chansel.u_sel.name = "GRfcset.clip_overlap";

   if (me->properties & GRIS_POST_PROCESSING)
   {
      om_msg = om$get_channel_count (object= me, p_chanselect = &chansel, 
               count = &count);

      if ((om_msg & 1) && count)
      {
         /*
          *  Send the GSdissolve message to members.
          */

         om_msg = om$send(
                  msg = message GRgrset.GSdissolve (msg),
                  senderid = my_id, p_chanselect = &chansel);


         if (! (om_msg & *msg & 1 ))
         {
            *msg = MSFAIL;
            return (om_msg);
         }
      }else
      {
         *msg = MSFAIL;
         return(OM_E_ABORT);
      }
   }

   /*
    *  Send the message to myself.
    */
 
   om_msg = om$send(mode = OM_e_wrt_message,
            msg = message GRgrset.GSdissolve(msg), targetid = my_id);

   return ( om_msg );
}
end implementation GRfcset;
