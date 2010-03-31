/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsfround;

#include "EMSdpr.h"         /*EMSinlist; KNOWN_DEPENDENT; etc.*/
#include "OMmacros.h"

#define INCREMENT 50        /*For rounds use a large increment.*/

method EMgetInInfo(IGRlong           *EMmsg; 
                   struct EMSinlist  *inlist; 
                   GRobjid           uneval_sender_id; 
                   IGRboolean        is_kd_on; 
                   IGRushort options)
/*
Description
    This message will return the in information for this state by adding it
    to the existing inlist.  This includes the surfaces of the state being
    unevaluated (if one exists). 

Return Values    
    EMSS_S_Success if all is well.

Notes
    This node must be the active state in order to return correct in
    information.  

    About parameters:
        inlist  - contains surf/loop/edge ids that have been added so far.
                  This structure may be passed this info aready in it.  
                  The memory may be malloc'd or realloc'd as necessary.
        uneval_sender_id - the id of the node that defines the path of
                           deactivation. 
                          if (options & EMget_in_inf_SHELL_ALL_DEP || is_kd_on)
                          then this may be passed as NULL_OBJID.
        is_kd_on  - indicates whether this node recieved a EMdeactivateState
                    message with the KD flag turned on.
        options - EMget_in_inf_SHELL_ALL_DEP if set all of the surfaces of the
                  uneval node will be gotten.  Otherwise, only those that are
                  affected by this operation will be gotten.

History
    SM  03/19/92 Exit if no ssi (can happen if NULL state)
    DLB 05/22/91 Support new options.
    DLB 01/28/91 Added EFget_ininfo_from_lpinfo call.
    DLB 11/08/90 EMgetInGeom param change.
    DLB 10/25/90 Creation.
*/
{
  IGRlong                 OM_stat=OM_S_SUCCESS;
  IGRint                  ii,  num_direct_add;
  union EMSssi_table      *ssi=NULL;
  struct EMSrndssi_table  *my_info=NULL;
  extern IGRlong          EFget_ininfo_from_lpinfo();
  extern void             EFgetInGeomInfo(), EFalloc_list();


  *EMmsg = EMS_S_Success;


  /*Get in info for this state.*/

  if (!(options & EMget_in_inf_NO_SURFS))
  {
    /*Get all the surfaces I generated.*/
    EFgetInGeomInfo(EMmsg, my_id, OM_Gw_current_OS, inlist, uneval_sender_id,
                    is_kd_on, INCREMENT, NULL); 
    if (!(1 & *EMmsg)) goto wrapup;
  }

  OM_stat = om$send(msg = message EMSdpr.EMgetSSI(EMmsg, &ssi),
                    targetid = my_id);
  if (!(1 & OM_stat & *EMmsg)) goto wrapup;                    
  EMerr_hndlr(!ssi, *EMmsg, EMS_I_Useless, wrapup);

  my_info = &ssi->rnd_info;

  if (!((options & EMget_in_inf_NO_LOOPS) && 
        (options & EMget_in_inf_NO_EDGES) && 
        (options & EMget_in_inf_NO_EDGES_FROM_LOOPS)))
  {
    OM_stat = EFget_ininfo_from_lpinfo(EMmsg,
                                       my_info->num_surfaces,
                                       my_info->num_regions_in,
                                       my_info->num_regions_out,
                                       my_info->region_in_ids,
                                       my_info->region_out_ids,
                                       inlist, OM_Gw_current_OS, options);
    if (!(1 & OM_stat & *EMmsg)) goto wrapup;
  }
  
  if (!(options & EMget_in_inf_NO_EDGES))
  {
    /*Process directly added edges*/
    for(num_direct_add=0, ii=0; ii<my_info->num_edges_out; ii++)
    {
      num_direct_add += my_info->num_edges_in[ii];
    }
  
    if (num_direct_add)
    {
      EFalloc_list(EMmsg, &inlist->edlist.edge_ids, inlist->edlist.num_edges,
                  &inlist->edlist.array_size, num_direct_add, INCREMENT, NULL);
      if (!(1 & *EMmsg)) goto wrapup;               
  
      OM_BLOCK_MOVE(my_info->edge_in_ids,
                    &inlist->edlist.edge_ids[inlist->edlist.num_edges],
                    num_direct_add * sizeof(GRobjid));
      inlist->edlist.num_edges += num_direct_add;
    }
  }

wrapup:
  if (ssi) om$dealloc(ptr = ssi);
  EMWRAPUP(*EMmsg, OM_stat, "sfrnd.getininf")
  return(OM_stat);
}
end implementation EMSsfround;
