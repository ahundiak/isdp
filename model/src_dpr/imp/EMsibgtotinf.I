/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsfimpbnd;

#include "EMSdpr.h"         /*EMSinlist; KNOWN_DEPENDENT; etc.*/
#include "OMmacros.h"

#define INCREMENT 50 

method EMgetOutInfo(IGRlong *EMmsg; 
                    struct EMSoutlist *outlist; 
                    IGRushort options)
/*
Description
    This message will return the out information for this state by adding it
    to the existing outlist.  This includes the surfaces of the state that
    were removed (if any). 

Return Values    
    EMSS_S_Success if all is well.

Notes
    About parameters:
        outlist  - contains surf/loop/edge ids that have been removed so far.
                   This structure may be passed this info aready in it.  
                   The memory may be malloc'd or realloc'd as necessary.
        options - none at the moment.

History
    DLB 06/22/91 Creation.
*/
{
  IGRlong                 OM_stat=OM_S_SUCCESS;
  IGRint                  num_eds_out, ii;
  union EMSssi_table      *ssi=NULL;
  struct EMSsfssi_table   *my_info=NULL;
  extern IGRlong          EFget_outinfo_from_lpinfo();
  extern void             EFalloc_list();


  *EMmsg = EMS_S_Success;

  /*Get out info for this state.*/
  OM_stat = om$send(msg =  message EMSdpr.EMgetSSI(EMmsg, &ssi),
                    targetid = my_id);
  if (!(1 & OM_stat & *EMmsg)) goto wrapup;                    

  my_info = &ssi->sf_info;

  OM_stat = EFget_outinfo_from_lpinfo(EMmsg,
                                      0,
                                      NULL,
                                      NULL,
                                      my_info->num_surfaces,
                                      my_info->surface_ids,
                                      my_info->num_regions_in,
                                      my_info->num_regions_out,
                                      my_info->region_in_ids,
                                      my_info->region_out_ids,
                                      outlist, OM_Gw_current_OS, NULL);
  if (!(1 & OM_stat & *EMmsg)) goto wrapup;

  num_eds_out = my_info->cum_num_edges_out + my_info->num_edges_copied;

  if (num_eds_out)
  {
    GRobjid *ed;

    EFalloc_list(EMmsg, &outlist->edlist.edge_ids, outlist->edlist.num_edges,
                 &outlist->edlist.array_size, num_eds_out,
                 INCREMENT, NULL); 
    if (!(1 & *EMmsg)) goto wrapup;                 

    if (my_info->cum_num_edges_out)
    {
      /*Now add the edges in.*/
      OM_BLOCK_MOVE(my_info->edge_out_ids, 
                    &outlist->edlist.edge_ids[outlist->edlist.num_edges],
                    my_info->cum_num_edges_out * sizeof(GRobjid));
      outlist->edlist.num_edges += my_info->cum_num_edges_out;
    }

    ed = my_info->ed_cp_ed_ids;  
    for(ii=0; ii<my_info->num_edges_copied; ii++, ed+=2)
    {
      outlist->edlist.edge_ids[outlist->edlist.num_edges] = *ed;
      outlist->edlist.num_edges++;
    }      
  }

wrapup:
  if (ssi) om$dealloc(ptr = ssi);
  EMWRAPUP(*EMmsg, OM_stat, "sib.EMgetOutInfo")
  return(OM_stat);
}
end implementation EMSsfimpbnd;
