class implementation EMSlift;

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
  DLB 02/04/92 Creation.
*/
{
  IGRlong                 OM_stat=OM_S_SUCCESS;
  IGRint                  ii, jj;
  union EMSssi_table      *ssi=NULL;
  struct EMSlftssi_table  *my_info;
  GRobjid                 *sf_out;
  OM_S_CHANSELECT         to_owners;
 
 
  *EMmsg = EMS_S_Success;
 
  if (!(ME.EMSdpr->dpr_props & EMS_NULL_STATE))
  {
    OM_stat = om$send(msg = message EMSdpr.EMgetSSI(EMmsg, &ssi),
                      targetid = my_id);
    if (!(1 & OM_stat & *EMmsg)) goto wrapup;
 
    my_info = &ssi->lft_info;
 
    sf_out = my_info->surface_out_ids;  
 
    for(ii=0; ii<my_info->num_composites; ii++)
    {
      if (my_info->composite_ids[ii] == prim_id)
      {
        for(jj=0; jj<my_info->num_surfaces_out[ii]; jj++)
        {
          EFrealloc_if_needed(EMmsg, surf_ids, *num_surf, 
                              DPR_BUFF_INCR, sizeof(GRobjid));
          if (!(1 & *EMmsg)) goto wrapup;
                          
          (*surf_ids)[*num_surf] = *sf_out;
          (*num_surf)++;
 
          sf_out++;
        }
      }
      else sf_out += my_info->num_surfaces_out[ii];
    }
  }
 
  /*There may be surfaces removed by my parents so go up the tree
   * and check for such a case.
   */
 
  to_owners.type = OM_e_addr;
  to_owners.u_sel.addr = &ME.GRconnector->to_owners;
  
  /*May not be a dpr owner so check return code*/
  OM_stat = om$send(msg = OPPmargs,
                    p_chanselect = &to_owners);
  if (OM_stat == OM_W_UNKNOWN_MSG) OM_stat = OM_S_SUCCESS;
 
wrapup:
  if (ssi) om$dealloc(ptr = ssi);
  EMWRAPUP(*EMmsg, OM_stat, "lft.EMgetSurfsOfPrim")
  return(OM_stat);
}
end implementation EMSlift;
