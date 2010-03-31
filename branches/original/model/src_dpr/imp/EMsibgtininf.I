/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsfimpbnd;

#include "EMSdpr.h"         /*EMSinlist; KNOWN_DEPENDENT; etc.*/
#include "OMmacros.h"

#define INCREMENT 50

method EMgetInInfo(IGRlong *EMmsg; 
                   struct EMSinlist *inlist; 
                   GRobjid uneval_sender_id; 
                   IGRboolean is_kd_on; 
                   IGRushort options)
/*
Description
    This message will return the in information for this state by adding it
    to the existing inlist.

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
    DLB 06/22/91    Creation.
*/
{
  IGRlong                 OM_stat=OM_S_SUCCESS;
  IGRint                  num_ed_in=0, ii;
  union EMSssi_table      *ssi=NULL;
  struct EMSsfssi_table   *my_info=NULL;
  extern IGRlong          EFget_ininfo_from_lpinfo();
  extern void             EFalloc_list();


  *EMmsg = EMS_S_Success;

  if (!((options & EMget_in_inf_NO_LOOPS) && 
        (options & EMget_in_inf_NO_EDGES) && 
        (options & EMget_in_inf_NO_EDGES_FROM_LOOPS)))
  {
    /*Get in info for this state.*/
    OM_stat = om$send(msg = message EMSdpr.EMgetSSI(EMmsg, &ssi),
                      targetid = my_id);
    if (!(1 & OM_stat & *EMmsg)) goto wrapup;                    
  
    my_info = &ssi->sf_info;
  
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
    /*Now get edges added directly to existing loops*/
    for(ii=0; ii<my_info->cum_num_edges_out; ii++)
    {
      num_ed_in += my_info->num_edges_in[ii];
    }    
    
    if (num_ed_in || my_info->num_edges_copied)
    {
      GRobjid *ed;
  
      EFalloc_list(EMmsg, &inlist->edlist.edge_ids, inlist->edlist.num_edges,
                   &inlist->edlist.array_size,
                   num_ed_in + my_info->num_edges_copied , INCREMENT, NULL);
      if (!(1 & *EMmsg)) goto wrapup;                 
  
      if (my_info->cum_num_edges_out)
      {
        /*Now add the edges in.*/
        OM_BLOCK_MOVE(my_info->edge_in_ids,
                      &inlist->edlist.edge_ids[inlist->edlist.num_edges],
                      num_ed_in * sizeof(GRobjid));
        inlist->edlist.num_edges += num_ed_in;
      }
  
      ed = my_info->ed_cp_ed_ids;
      for(ii=0, ed++; ii<my_info->num_edges_copied; ii++, ed+=2)
      {
        inlist->edlist.edge_ids[inlist->edlist.num_edges] = *ed;
        inlist->edlist.num_edges++;      
      }
    }
  }


wrapup:
  if (ssi) om$dealloc(ptr = ssi);
  EMWRAPUP(*EMmsg, OM_stat, "sib.getInInfo")
  return(OM_stat);
}
end implementation EMSsfimpbnd;

