/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsfstitch;

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
    DLB 06/23/91    Creation.
*/
{
  IGRlong                 OM_stat=OM_S_SUCCESS;
  IGRint                  num_ed_in=0, ii;
  union EMSssi_table      *ssi=NULL;
  struct EMSstchssi_table *my_info=NULL;
  extern void             EFalloc_list();


  *EMmsg = EMS_S_Success;


  if (!(options & EMget_in_inf_NO_EDGES))
  {
    /*Get the SSI stuff.*/
    OM_stat = om$send(msg = message EMSdpr.EMgetSSI(EMmsg, &ssi),
                      targetid = my_id);
    if (!(1 & OM_stat & *EMmsg)) goto wrapup;                    

    my_info = &ssi->stch_info;

    /*Get edges added directly to existing loops*/
    for(ii=0; ii<my_info->num_edges_out; ii++)
    {
      num_ed_in += my_info->num_edges_in[ii];
    }    
    
    if (num_ed_in)
    {
      EFalloc_list(EMmsg, &inlist->edlist.edge_ids, inlist->edlist.num_edges,
                   &inlist->edlist.array_size,
                   num_ed_in, INCREMENT, NULL);
      if (!(1 & *EMmsg)) goto wrapup;                 
  
      /*Now add the edges in.*/
      OM_BLOCK_MOVE(my_info->edges_in,
                    &inlist->edlist.edge_ids[inlist->edlist.num_edges],
                    num_ed_in * sizeof(GRobjid));
      inlist->edlist.num_edges += num_ed_in;
    }
  }


wrapup:
  if (ssi) om$dealloc(ptr = ssi);
  EMWRAPUP(*EMmsg, OM_stat, "stch.getInInfo")
  return(OM_stat);
}
end implementation EMSsfstitch;

