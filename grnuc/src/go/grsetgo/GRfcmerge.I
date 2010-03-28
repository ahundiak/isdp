/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
   GSmerge 

Description
   This method will merge the elements on the member channel with 
   the graphics set. 

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
     Gray Winn    03/02/87    Creation date.
     msm          07/13/92    ANSI-C conversion.
\*/

class implementation GRfcset;

#include "grimport.h"
#include "msdef.h"
#include "grgsdef.h"

method GSmerge (IGRlong *msg; struct GRid *gs_id; struct GRid *owners_id;
                OM_p_CHANSELECT gs_sel; OM_p_CHANSELECT owners_sel)
{
IGRlong           om_msg;
OM_S_CHANSELECT   to_sets_sel;
OM_S_CHANSELECT   to_owners_sel;

   *msg = MSSUCC;
   to_sets_sel.type = OM_e_name;
   to_sets_sel.u_sel.name = "GRgrset.to_sets";
   to_owners_sel.type = OM_e_name;
   to_owners_sel.u_sel.name = "GRgrset.to_owners";

   if (! (me->properties & GRIS_POST_PROCESSING))
   {
      /*
       *  Invoke the graphics set merge message.
       */

      om_msg = om$send (mode = OM_e_wrt_message,
               msg = message GRgrset.GSmerge (msg, gs_id, owners_id,
               gs_sel, owners_sel),
               targetid = my_id);
   }else
   {
      /*
       *  Send the merge to the members objects.
       */

      om_msg = om$send (
               msg = message GRgrset.GSmerge (msg, gs_id, owners_id,
               gs_sel, owners_sel),
               p_chanselect = &to_sets_sel);

      if (om_msg & *msg & 1)
      {
         /*
          *  Connect the fence set to the owner.
          */

         om_msg = om$send(
                  msg = message Root.connect (to_owners_sel, OM_K_MAXINT,
                  owners_id->objid, owners_id->osnum, *owners_sel,
                  OM_K_MAXINT), targetid = my_id);

         if (om_msg & 1)
         {
            om_msg = om$send(
                     msg = message GRgrset.GSdissolve (msg),
                     p_chanselect = &to_sets_sel);                     
         }
      }
   }
   return(om_msg);
}
end implementation GRfcset;
