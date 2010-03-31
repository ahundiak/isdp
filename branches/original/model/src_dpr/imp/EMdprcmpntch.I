/* ###################   APOGEE COMPILED   ################## */
class implementation EMSdpr;

#include "EMS.h"
#include "EMSmsgdef.h"
#include "OMmacros.h"

method EMcomponentchanged(IGRlong *EMmsg; GRobjid old_id; IGRint num_newids;
                          GRobjid *new_ids)
/*
Description
   This method is used to notify EMS composite objects that one of their
   components ids has changed.  Since the component could have changed to
   multiple ids, an array of new ids is passed.

Return values 
   EMS_S_Success    if all is well.
   EMS_I_InvalidArg if 'num_newids' > 1.

Notes
   This override will update the ids vla by changing the reference to the
   old id with the new id. 
   If 'num_newids' is greater than one then I  cannot determine how
   to update the vla.  In this case an info message is returned (see above).

   If this situation is possible for a given class then this message should
   be overridden for that class to handle the multiple id change.

History
   DLB  11/09/87  Creation.
*/
{
 IGRlong         OM_stat = OM_S_SUCCESS;
 OM_S_CHANSELECT to_owners;
 

 *EMmsg = EMS_S_Success;

 /*Let EMScomposite do its work.*/
 OM_stat = om$send(mode = OM_e_wrt_message,
                   msg = message EMScomposite.EMcomponentchanged(EMmsg,
                         old_id, num_newids, new_ids),
                   targetid = my_id);
 if (!(1 & OM_stat & *EMmsg)) goto wrapup;

 /*Can I handle this change?*/
 if (num_newids >1) 
 {
   *EMmsg = EMS_I_InvalidArg; 
   goto wrapup;
 }

 {
   IGRint  vla_size, i;  /*DECL*/

   /*Make my change.*/
   vla_size = om$dimension_of(varray = ME.EMSdpr->ids);

   for (i = 0; i < vla_size; i ++)
   {
     if (old_id == ME.EMSdpr->ids[i])
     {
       /*Got one!*/
       ME.EMSdpr->ids[i] = new_ids[0];
     }
   } 
 }

 wrapup:
  EMWRAPUP(*EMmsg, OM_stat, "In EMSdpr.EMcomponentchanged")
  return(OM_stat);
}
end implementation EMSdpr;
