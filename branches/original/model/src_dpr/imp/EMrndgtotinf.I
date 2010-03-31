/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsfround;

#include "EMSdpr.h"         /*EMSinlist; KNOWN_DEPENDENT; etc.*/
#include "OMmacros.h"

#define INCREMENT 50        /*For booleans use a large increment.*/

method EMgetOutInfo(IGRlong           *EMmsg; 
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
    DLB 01/29/91 Use EFget_outinfo_from_lpinfo().
    DLB 10/29/90 Creation.
*/
{
  IGRlong                 OM_stat=OM_S_SUCCESS;
  union EMSssi_table      *ssi=NULL;
  struct EMSrndssi_table  *my_info=NULL;
  extern IGRlong          EFget_outinfo_from_lpinfo();
  extern void             EFalloc_list();


  *EMmsg = EMS_S_Success;

  /*Get out info for this state.*/
  OM_stat = om$send(msg = message EMSdpr.EMgetSSI(EMmsg, &ssi),
                    targetid = my_id);
  if (!(1 & OM_stat & *EMmsg)) goto wrapup;                    

  my_info = &ssi->rnd_info;
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

  /*Now get explicit removed edges.*/
  if (my_info->num_edges_out)
  {
    EFalloc_list(EMmsg, &outlist->edlist.edge_ids, outlist->edlist.num_edges,
                 &outlist->edlist.array_size, my_info->num_edges_out,
                 INCREMENT, NULL); 
    if (!(1 & *EMmsg)) goto wrapup;                 

    OM_BLOCK_MOVE(my_info->edge_out_ids,
                  &outlist->edlist.edge_ids[outlist->edlist.num_edges],
                  my_info->num_edges_out * sizeof(GRobjid));
    outlist->edlist.num_edges += my_info->num_edges_out;
  }

wrapup:
  if (ssi) om$dealloc(ptr = ssi);
  EMWRAPUP(*EMmsg, OM_stat, "sfrnd.getotinf")
  return(OM_stat);
}
end implementation EMSsfround;

