/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsfstitch;

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
    DLB 06/23/91 Creation.
*/
{
  IGRlong                 OM_stat=OM_S_SUCCESS;
  union EMSssi_table      *ssi=NULL;
  struct EMSstchssi_table *my_info=NULL;
  extern void             EFalloc_list();


  *EMmsg = EMS_S_Success;

  /*Get out info for this state.*/
  OM_stat = om$send(msg = message EMSdpr.EMgetSSI(EMmsg, &ssi),
                    targetid = my_id);
  if (!(1 & OM_stat & *EMmsg)) goto wrapup;                    

  my_info = &ssi->stch_info;

  if (my_info->num_edges_out)
  {
    EFalloc_list(EMmsg, &outlist->edlist.edge_ids, outlist->edlist.num_edges,
                 &outlist->edlist.array_size, my_info->num_edges_out,
                 INCREMENT, NULL); 
    if (!(1 & *EMmsg)) goto wrapup;                 

    /*Now add the edges in.*/
    OM_BLOCK_MOVE(my_info->edges_out, 
                  &outlist->edlist.edge_ids[outlist->edlist.num_edges],
                  my_info->num_edges_out * sizeof(GRobjid));
    outlist->edlist.num_edges += my_info->num_edges_out;
  }

wrapup:
  if (ssi) om$dealloc(ptr = ssi);
  EMWRAPUP(*EMmsg, OM_stat, "stch.EMgetOutInfo")
  return(OM_stat);
}
end implementation EMSsfstitch;
