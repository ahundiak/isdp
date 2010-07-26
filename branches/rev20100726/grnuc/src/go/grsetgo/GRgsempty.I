/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
   GSempty 

Description
   This method is used to remove all graphics objects from the 
   graphics set.

    *msg          IGRlong         return code
    *owner_id     GRid            Owner object.
    owner_chansel OM_p_CHANSELECT Channel of the owner object.

Notes
   The owner_chansel and owner_id can be NULL.

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
#include "grgsdef.h"

method GSempty (IGRlong *msg; struct GRid *owner_id;
                OM_p_CHANSELECT owner_chansel)
{
IGRlong           om_msg;
unsigned int      count;
OM_S_CHANSELECT   to_owner_chansel;
OM_S_CHANSELECT   sets_chansel;

   *msg = MSSUCC;
   om_msg = MSSUCC;

   to_owner_chansel.type = OM_e_name;
   to_owner_chansel.u_sel.name = "GRgrset.to_owners";
   sets_chansel.type = OM_e_name;
   sets_chansel.u_sel.name = "GRgrset.to_sets";

   /*
    *  Is the graphics set reusable.
    *  If so then empty the graphics set 
    *  otherwise disconnect from the owner and cleanup.
    */

   if (me->properties & GRIS_REUSABLE)
   {
      /*
       *  Empty all the savesets.
       */

      om_msg = om$send (msg = message GRgrset.GSempty (msg, owner_id,
               owner_chansel), p_chanselect = &sets_chansel);

      /*
       *  Delete all the attached member savesets.
       */

      om_msg = om$send (msg = message GRgrset.GSdissolve (msg),
               p_chanselect = &sets_chansel);
   }else
   {
      if (owner_chansel && owner_id)
      {
         /*
          *  Disconnect the graphics set form the command object.
          */

         om_msg = om$send(mode = OM_e_wrt_object,
                  msg = message Root.disconnect (*owner_chansel, my_id,
                  OM_Gw_current_OS, to_owner_chansel),
                  targetid = owner_id->objid, targetos = owner_id->osnum);
      }

      if (om_msg & 1)
      {
         /* 
          *  Get the number of owners.
          */

         om_msg = om$get_channel_count (object= me, 
                  p_chanselect = &to_owner_chansel, count = &count);

         if ((om_msg & 1) && !count)
         {
            /*
             *  Dissolve ourselves.
             */
   
            om_msg = om$send (msg = message GRgrset.GSdissolve (msg),
                     targetid = my_id);
         }
      }
   }
   return ( om_msg );
}

end implementation GRgrset;
