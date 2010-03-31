/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsfrembnd;

#include "EMSdpr.h"         /*EMSinlist; KNOWN_DEPENDENT; etc.*/
#include "OMmacros.h"

#define INCREMENT 50

/* HISTORY

 August, 1991  :  AMD  :  Creation

*/

method EMgetInInfo(IGRlong *EMmsg; 
                   struct EMSinlist *inlist; 
                   GRobjid uneval_sender_id; 
                   IGRboolean is_kd_on; 
                   IGRushort options)

{
  IGRlong                 OM_stat=OM_S_SUCCESS;
  IGRint                  num_ed_in=0, ii;
  union EMSssi_table      *ssi=NULL;
  struct EMSdbssi_table   *my_info=NULL;
  extern void             EFalloc_list();

  *EMmsg = EMS_S_Success;

  if (!(options & EMget_in_inf_NO_EDGES))
  {
    /*Get the SSI stuff.*/
    OM_stat = om$send(msg = message EMSdpr.EMgetSSI(EMmsg, &ssi),
                      targetid = my_id);
    if (!(1 & OM_stat & *EMmsg)) goto wrapup;                    

    my_info = &ssi->db_info;

    /* Get edges which are disconnected. These are not geometry added
       but are still being included to take care of the inconsistencies
       of the recompute mechanism.  AMD : 03/25/93  */


    if (my_info->num_edges_disconnected)
    {
      EFalloc_list(EMmsg, &inlist->edlist.edge_ids, inlist->edlist.num_edges,
                   &inlist->edlist.array_size,
                   my_info->num_edges_disconnected, INCREMENT, NULL);
      if (!(1 & *EMmsg)) goto wrapup;                 
  
      /*Now add the edges in.*/
      OM_BLOCK_MOVE(my_info->edges_disconnected,
                    &inlist->edlist.edge_ids[inlist->edlist.num_edges],
                    my_info->num_edges_disconnected * sizeof(GRobjid));
      inlist->edlist.num_edges += my_info->num_edges_disconnected;
    }
  }


wrapup:
  if (ssi) om$dealloc(ptr = ssi);
  EMWRAPUP(*EMmsg, OM_stat, "stch.getInInfo")
  return(OM_stat);

}
end implementation EMSsfrembnd;

