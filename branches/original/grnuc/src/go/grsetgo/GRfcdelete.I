/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
   GSdelete 

Description
   This method is used to delete all the members of the graphics set.

   *msg         IGRlong        return code 

Return Values
   MSSUCC  -- successful completion
   MSFAIL  -- failure

History
     Gray Winn    11/02/86    Creation date.
     msm          07/10/92    ANSI-C conversion.
     Sudha	  03/10/95    Fix for TR# 119420485 - get the channel count
			      before sending a GSdelete on the channel.
\*/

class implementation GRfcset;

#include "grimport.h"
#include "msdef.h"
#include "grgsdef.h"

method GSdelete (IGRlong *msg )
{
IGRlong           om_msg;
unsigned int      count;
OM_S_CHANSELECT   chansel;

   *msg = MSSUCC;
   chansel.type = OM_e_name;
   chansel.u_sel.name = "GRfcset.clip_overlap";


   if (me->properties & GRIS_POST_PROCESSING)
   {
      /*
       *  Send the GSdelete message to the clip_overlap members.
       */

      om_msg = om$get_channel_count (object= me, p_chanselect = &chansel,
               count = &count);

     if ( count )
     {
      if (om_msg & 1)
      {
         om_msg = om$send(
                  msg = message GRgrset.GSdelete (msg), 
                  p_chanselect = &chansel);
      
         if ( ! (om_msg & *msg & 1))
         {
            *msg = MSFAIL;
            return (om_msg);
         }
      }else
      {
         *msg = MSFAIL;
         return(om_msg);
      }
     }
   }

   /*
    *  Send the GSdelete message to my self.
    */
      
   om_msg = om$send(mode = OM_e_wrt_message,
            msg = message GRgrset.GSdelete(msg), targetid = my_id);
   return ( om_msg );
}
end implementation GRfcset;
