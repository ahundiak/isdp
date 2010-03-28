/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
   GSinqcount 

Description
   This method is used to return the number of components owned 
   by the set.

   *count       IGRint         Number of object owned by set.
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

method GSinqcount (IGRlong *msg; IGRint *count)
{
IGRlong           om_msg;
IGRint            i;
unsigned int      num_sv;
IGRint            temp;
OM_S_CHANSELECT   overlap_chansel;

   *msg = MSSUCC;
   overlap_chansel.type = OM_e_name;
   overlap_chansel.u_sel.name = "GRfcset.clip_overlap";

   om_msg = om$send (mode = OM_e_wrt_message,
            msg = message GRgrset.GSinqcount (msg, count),
            targetid = my_id);

   if (me->properties & GRIS_POST_PROCESSING)
   {
      /*
       *  Get the channel count of the clip overlap channel.
       */

      om_msg = om$get_channel_count (object= me, 
               p_chanselect = &overlap_chansel, count = &num_sv);

      for (i=0; (i < num_sv) && (om_msg & *msg & 1); ++i)
      {
         /*
          *  Accumulate the total number of components.
          */
      
         om_msg = om$send (
                  msg = message GRgrset.GSinqcount (msg, &temp),
                  senderid = my_id, p_chanselect = &overlap_chansel,
                  from = i, to = i);

         *count = *count + temp;
      }
   }         
   return ( om_msg );
}
end implementation GRfcset;
