class implementation EMSsubbs;

#include "EMSdprquery.h"  /*DPR_BUFF_INCR*/

method EMgetSurfsOfPrim(IGRlong *EMmsg; GRobjid prim_id;
                        GRobjid **surf_ids; IGRint *num_surf, *num_active)
/*
Description
    This message will return all surfaces of a primitive in the state tree.

Return Values
    EMmsg - EMS_S_Success if all is well.

Notes 
    About parameters:
        The inital sender of this message need not supply the prim_id 
        (NULL_OBJID will do fine).  This parameter will be used internally
        during recursion.

        surf_ids should be set to NULL.

        num_surf should be set to 0.

        The surf_ids array will be allocated using om$malloc and should be
        freed by om$dealloc.

        num_active is the  number of surfaces (starting at the beginning of
        the list) that are still an active part of the boolean tree. 
        Inactive surfaces will be at the end of the list.

History
  DLB 02/06/92 Creation.
*/
{
  IGRlong OM_stat=OM_S_SUCCESS;
  *EMmsg = EMS_S_Success;
 
  EFrealloc_if_needed(EMmsg, surf_ids, *num_surf, 
                      DPR_BUFF_INCR, sizeof(GRobjid));
  if (!(1 & *EMmsg)) goto wrapup;
                        
  (*surf_ids)[*num_surf] = my_id;
  (*num_surf)++;
 
  *num_active = 1;
 
wrapup:
  EMWRAPUP(*EMmsg, OM_stat, "ss.EMgetSurfsOfPrim")
  return(OM_stat);
}
end implementation EMSsubbs;
