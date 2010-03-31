/* ###################   APOGEE COMPILED   ################## */
class implementation EMScompsurf;

#include "EMS.h"
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

    Disclaimer:
        This message has been specifically written for the D & M project of
        Salvagnini Transferica.  Due to this the following restriction
        applies: 
            o This message is only supported for primitives in a pure
              boolean tree.

History
  DLB 02/04/92 Ignore UNK_MSG when sending up chan.
  DLB 03/03/89 Added num_active parameter.
  DLB 11/20/88 Creation.
*/
{
  IGRlong         OM_stat=OM_S_SUCCESS;
  IGRint          ii, comp_count=0;
  struct GRid     *comp_list=NULL;    
  OM_S_CHANSELECT to_owners;
 
 
  *EMmsg = EMS_S_Success;
 
  /*Get surfaces of this composite and fill the surf_ids array.*/
  EFgetcomponents(EMmsg, my_id, my_id, OM_Gw_current_OS, &comp_count,
                  &comp_list);
  if (!(1 & *EMmsg)) goto wrapup; 
 
  for(ii=0; ii<comp_count; ii++) 
  {
    EFrealloc_if_needed(EMmsg, surf_ids, *num_surf, 
                       DPR_BUFF_INCR, sizeof(GRobjid));
    if (!(1 & *EMmsg)) goto wrapup;
                          
    (*surf_ids)[*num_surf] = comp_list[ii].objid;
    (*num_surf)++;
  }
 
  *num_active = comp_count;
 
  /*There may be surfaces removed by my boolean parents so go up the tree
   * and check for such a case.
   */
 
  to_owners.type = OM_e_addr;
  to_owners.u_sel.addr = &ME.GRconnector->to_owners;
  
  OM_stat = om$send(msg = message EMSsurface.EMgetSurfsOfPrim(EMmsg, my_id,
                          surf_ids, num_surf, num_active),
                    p_chanselect = &to_owners);
  if (OM_stat == OM_W_UNKNOWN_MSG) OM_stat = OM_S_SUCCESS;

wrapup:
  if (comp_list) om$dealloc(ptr = comp_list);
  EMWRAPUP(*EMmsg, OM_stat, "csf.EMgetSurfsOfPrim")
  return(OM_stat);
}
end implementation EMScompsurf;
