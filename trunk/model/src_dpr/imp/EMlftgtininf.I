/* ###################   APOGEE COMPILED   ################## */
class implementation EMSlift;

#include "EMSdpr.h"         /*EMSinlist; KNOWN_DEPENDENT; etc.*/
#include "OMmacros.h"

#define INCREMENT 30

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
                  NO_SURFS - Dont return any surfs.
                  NO_LOOPS - Dont return any loops.
                  NO_EDGES - ''   ''     ''  edges.
                  NO_EDGES_FROM_LOOPS - Dont return any edges added as a result
                                        of adding a loop.

History
    DLB 02/22/92    Treat copied common edges as added edges.
    DLB 07/01/91    Treat the lifted surface as an added surface since it is
                    being geometrically modified.
    DLB 05/22/91    Support new options.
    DLB 02/13/91    Creation.
*/
{
  IGRlong                 OM_stat=OM_S_SUCCESS;
  IGRint                  num_ed_in=0, ii;
  GRobjid                 *ssi_id;
  union EMSssi_table      *ssi=NULL;
  struct EMSlftssi_table  *my_info=NULL;
  extern IGRint           EFget_ininfo_from_lpinfo();
  extern void             EFgetInGeomIds(), EFalloc_list();


  *EMmsg = EMS_S_Success;

  OM_stat = om$send(msg = message EMSdpr.EMgetSSI(EMmsg, &ssi),
                    targetid = my_id);
  if (!(1 & OM_stat & *EMmsg)) goto wrapup;                    

  my_info = &ssi->lft_info;

  if (!(options & EMget_in_inf_NO_SURFS))
  {
    /*Get all the surfaces I generated.*/
    uneval_sender_id = my_info->sf_lifted_ids[0];
    EFgetInGeomInfo(EMmsg, my_id, OM_Gw_current_OS, inlist, uneval_sender_id,
                    is_kd_on, INCREMENT, NULL); 
    if (!(1 & *EMmsg)) goto wrapup;

    /*Treat the lifted surface like an added surface*/
    EFalloc_list(EMmsg, &inlist->sflist.surf_ids, inlist->sflist.num_surfs,
                 &inlist->sflist.array_size,
                 1, INCREMENT, NULL);
    if (!(1 & *EMmsg)) goto wrapup;                 

    inlist->sflist.surf_ids[inlist->sflist.num_surfs] = 
                                                     my_info->sf_lifted_ids[0];
    inlist->sflist.num_surfs++;
  }

  if (!((options & EMget_in_inf_NO_LOOPS) && 
        (options & EMget_in_inf_NO_EDGES) && 
        (options & EMget_in_inf_NO_EDGES_FROM_LOOPS)))
  {
    OM_stat = EFget_ininfo_from_lpinfo(EMmsg, 
                                       my_info->num_sf_affected,
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
    for(ii=0; ii<my_info->num_eds_rplcd; ii++)
    {
      num_ed_in += my_info->num_eds_in[ii];
    }    
    
    if (num_ed_in)
    {
      EFalloc_list(EMmsg, &inlist->edlist.edge_ids, inlist->edlist.num_edges,
                   &inlist->edlist.array_size,
                   num_ed_in, INCREMENT, NULL);
      if (!(1 & *EMmsg)) goto wrapup;                 
  
      /*Now add the edges in.*/
      OM_BLOCK_MOVE(my_info->ed_in_ids,
                    &inlist->edlist.edge_ids[inlist->edlist.num_edges],
                    num_ed_in * sizeof(GRobjid));
      inlist->edlist.num_edges += num_ed_in;
    }

    if (my_info->num_eds_wcm_md)
    {
      /*Handle case of edge-common edge being separated and new sf inserted
       * between.  Treat these modified edges as added edges.
       */
      EFalloc_list(EMmsg, &inlist->edlist.edge_ids, inlist->edlist.num_edges,
                   &inlist->edlist.array_size,
                   my_info->num_eds_wcm_md * 2, INCREMENT, NULL);
      if (!(1 & *EMmsg)) goto wrapup;                 

      ssi_id = my_info->ed_mcm_ed_ids;

      for(ii=0; ii<my_info->num_eds_wcm_md; ii++, ssi_id += 4)
      {
        inlist->edlist.edge_ids[inlist->edlist.num_edges++] = *ssi_id;
        inlist->edlist.edge_ids[inlist->edlist.num_edges++] = *(ssi_id+1);
      }
    }
  }

wrapup:
  if (ssi) om$dealloc(ptr = ssi);
  EMWRAPUP(*EMmsg, OM_stat, "lft.EMgetInInfo")
  return(OM_stat);
}
end implementation EMSlift;
