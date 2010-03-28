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

class implementation GRgrset;

#include "grimport.h"
#include "msdef.h"

method GSinqcount (IGRlong *msg; IGRint *count)
{
IGRlong           om_msg;
IGRint            i;
unsigned int      num_sv;
IGRint            temp;
OM_S_CHANSELECT   chansel;

   *msg = MSSUCC;
   chansel.type = OM_e_name;
   chansel.u_sel.name = "GRgrset.to_sets";


   /*
    *  Get the channel count of the members channel.
    */

   om_msg = om$get_channel_count (object= me, p_chanselect = &chansel, 
            count = &num_sv);

   for (i=0; (i < num_sv) && (om_msg & *msg & 1); ++i)
   {
      /*
       *  Accumulate the total number of components.
       */
      
      om_msg = om$send (
               msg = message GRgrset.GSinqcount (msg, &temp),
               senderid = my_id, p_chanselect = &chansel,
               from = i, to = i);

      *count = *count + temp;
   }         
   return ( om_msg );
}
end implementation GRgrset;
