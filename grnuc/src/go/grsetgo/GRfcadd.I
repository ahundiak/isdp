/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
   GSadd 

Description
   This method is used to add an object to the current save set.

   *msg         IGRlong       return code 
   *obj_id      GRid          The object id of the object to be
                              added to the save set.
   *rp_relation IGRint        contains the relationship with the
                              right prism (i.e. inside, outside,
                              or overlap)

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

method GSadd (IGRlong *msg; struct GRid *obj_id; IGRint *rp_relation)
{
IGRlong           om_msg;

   om_msg = MSSUCC;
   *msg = MSSUCC;

   if (me->properties & GRIS_POST_PROCESSING)
   {
      switch (*rp_relation)
      {
         case GO_INSIDE:
         {
            if (me->properties & GRIS_OUTSIDE)
            {
               return (OM_S_SUCCESS);
            }else
            {
               /*
                *  Add to the members channel.
                */
   
               om_msg = om$send (mode = OM_e_wrt_message,
                        msg = message GRgrset.GSadd (msg, obj_id, 
                        rp_relation), targetid = my_id);
            }
         }
         break;
      
         case GO_OUTSIDE:
         {
            if (me->properties & GRIS_INSIDE)
            {
               return(OM_S_SUCCESS);
            }else
            {
               /*
                *  Add to the members channel.
                */
   
               om_msg = om$send (mode = OM_e_wrt_message,
                        msg = message GRgrset.GSadd (msg, obj_id, 
                        rp_relation), targetid = my_id);
            }
         }
         break;
   
         case GO_OVERLAP:
         {
            if (me->properties & GRIS_CURRENT)
            {
               /*
                *  Send the add message to the current overlapping
                *  save set.
                */
   
               om_msg = om$send (
                        msg = message GRgrset.GSadd (msg, obj_id, 
                        rp_relation),
                        targetid = me->current_overlap_sv.objid,
                        targetos = me->current_overlap_sv.osnum);
            }else
            {
               *msg = MSFAIL;
            }
         }
         break;
      }
   }else
   {
      /*
       *  If the fence set is not post processing then
       *  invoke the graphics set method to add the object to 
       *  the members channel.
       */
   
      om_msg = om$send (mode = OM_e_wrt_message,
               msg = message GRgrset.GSadd (msg, obj_id, 
               rp_relation), targetid = my_id);
   }
   return (om_msg);
}
end implementation GRfcset;
