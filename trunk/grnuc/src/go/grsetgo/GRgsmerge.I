/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
   GSmerge 

Description
   This method will merge this graphics set into the graphics set
   passed in gs_id.

   *msg          IGRlong            return code
   *gs_id        struct GRid        The object id of the target graphics
                                    set.                           
   *owner_id     struct GRid        The object id of the owner channel.
   gs_sel        OM_p_CHANSELECT    graphics set channel select.
   owners_sel    OM_p_CHANSELECT    The owners channel select.

Return Values
   MSSUCC  -- successful completion
   MSFAIL  -- failure

History
     Gray Winn    11/16/86    Creation date.
     msm          07/10/92    ANSI-C conversion.
\*/

class implementation GRgrset;

#include "grimport.h"
#include "msdef.h"

method GSmerge (IGRlong *msg; struct GRid *gs_id; struct GRid *owners_id;
                OM_p_CHANSELECT gs_sel; OM_p_CHANSELECT owners_sel)
{
IGRlong           om_msg;
unsigned int      count;
OM_S_CHANSELECT   sets_sel;
OM_S_CHANSELECT   chansel;

   *msg = MSSUCC;
   sets_sel.type = OM_e_name;
   sets_sel.u_sel.name = "GRgrset.to_sets";
   chansel.type = OM_e_name;
   chansel.u_sel.name = "GRgrset.to_owners";

   om_msg = om$send (
            msg = message GRgrset.GSmerge (msg, gs_id, owners_id,
            gs_sel, owners_sel),
            p_chanselect = &sets_sel);

   if (om_msg & *msg & 1)
   {
      /* 
       *  Get the number of owners.
       */

      om_msg = om$get_channel_count (object= me, p_chanselect = &chansel, 
               count = &count);
   
      if ((om_msg & 1) && !count)
      {
         /*
          *  Send the GSdissolve message to the my_self.
          */

         om_msg = om$send (
                  msg = message GRgrset.GSdissolve (msg),
                  targetid = my_id);
      }
   }
   return(om_msg);
}
end implementation GRgrset;
