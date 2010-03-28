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
\*/

class implementation GRsvset;

#include "grimport.h"
#include "msdef.h"

method GSdelete (IGRlong *msg )
{
IGRlong           om_msg;
unsigned int      count;
IGRint            i;
struct GRmd_env   temp_env;
OM_S_CHANSELECT   chansel;

   *msg = MSSUCC;
   temp_env = me->path;
   chansel.type = OM_e_name;
   chansel.u_sel.name = "GRcmpowner.to_components";

   om_msg = om$get_channel_count (object= me, p_chanselect = &chansel, 
            count = &count);

   for (i = count-1; i >= 0; i = i-1)
   {
      om_msg = om$send(
               msg = message GRgraphics.GRdelete (msg, &temp_env), 
               p_chanselect = &chansel, from = i, to = i);
   }

   if (om_msg & *msg & 1)
   {
      /*
       *  Send the GSdissolve message to my self.
       */
      
      om_msg = om$send(msg = message GRgrset.GSdissolve (msg), 
               targetid = my_id);
   }
   return ( om_msg );
}

end implementation GRsvset;
