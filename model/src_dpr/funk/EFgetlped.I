class implementation EMSsubbs;

#include "EMS.h"
#include "EMSmsgdef.h"
#include "EMSopt.h"
#include "emsdef.h"

#define INCREMENT 20

from EMSloopset import EMget_loops;
from EMSboundary import EMget_edges;

void EFgetLoopsEdges(EMmsg, num_surfs, surfs,
                     loop_array_size, num_loops, loops,
                     edge_array_size, num_edges, edges, surfs_os) 
IGRlong         *EMmsg;
IGRint          num_surfs;
GRobjid         *surfs;
IGRint          *loop_array_size;
IGRint          *num_loops;
GRobjid         **loops;
IGRint          *edge_array_size;
IGRint          *num_edges;
GRobjid         **edges;
OMuword         surfs_os;
/*
Description
     This function will returns all loops and edges on the input surfaces.

Return Values
     *EMmsg;          EMS_S_Success if all goes well.           
     *loop_array_size, 
     *edge_array_size   Size of the malloc'd arrays.
     *num_loops,
     *num_edges       Number of ids in the arrays.
     **loops, 
     **edges          Arrays of object ids.

Notes 
     About parameters:
         num_surfs and surfs are input only.
         Either (loop_array_size & num_loops & loops) or 
                (edge_array_size & num_edges & edges) may be passed as NULL if
                not wanted. 
     This function mallocs the arrays and it is assumed that the user will 
     free this memory using om$dealloc.

History
     DLB  06/27/91 Fixed get loops cause the numbers get reset for each surf.
     DLB  11/19/89 EMget_edges returns GRids instead of GRobjids!!!
     DLB  10/04/89 creation.
*/
{
  IGRlong           OM_stat=OM_S_SUCCESS;
  IGRint            ii, depth;
  IGRint            num_GRids=0, buff_size=0, num_ret_lps=0,
                    ret_lp_array_size=0; 
  GRobjid           *ret_lps=NULL;
  OM_S_CHANSELECT   to_loopset;
  struct GRid       *GRids=NULL;
  IGRboolean        process_loops, process_edges;
  IGRushort options;
      

  *EMmsg = EMS_S_Success;
  process_loops = process_edges = FALSE;
    
  if (loop_array_size && num_loops && loops) 
  {
    process_loops = TRUE;
  }
  if (edge_array_size && num_edges && edges)
  {
    process_edges = TRUE;
  }

  depth = MAXINT;
  options = EMS_OPT_ALL;

  EMmake_chanselect(EMSsubbs_to_loopset, &to_loopset);

  for(ii=0; ii<num_surfs; ii++)
  {
    if (process_loops)
    {
      OM_stat = om$send(msg = message EMSloopset.EMget_loops(EMmsg, options, 
                              &depth, &ret_lps, NULL, &ret_lp_array_size,
                              &num_ret_lps),   
                        senderid = surfs[ii],
                        p_chanselect = &to_loopset,
                        targetos = surfs_os);
      if (!(1 & OM_stat & *EMmsg)) goto wrapup;

      if (num_ret_lps)
      {
        OMuint jj;

        (void) EFalloc_list(EMmsg, loops, *num_loops, loop_array_size,
                            num_ret_lps, INCREMENT, NULL);
        if (!(1 & *EMmsg)) goto wrapup;                        
    
        /*And finally move the loops.*/
    
        for(jj=0; jj<num_ret_lps; jj++)
        {
          (*loops)[*num_loops] = ret_lps[jj];
          (*num_loops)++;
        }                                                                     
      }
      if (ret_lps) om$dealloc(ptr = ret_lps);
      ret_lp_array_size = num_ret_lps = 0;
      ret_lps = NULL;
    }

    if (process_edges)
    {
      OM_stat = om$send(msg = message EMSboundary.EMget_edges(EMmsg, depth, 
                              options, &GRids, &buff_size, &num_GRids),
                        senderid = surfs[ii],
                        p_chanselect = &to_loopset,
                        targetos = surfs_os);
      if (!(1 & OM_stat & *EMmsg)) goto wrapup;
    }
  }

  if (num_GRids)
  {
    /*Move GRids into GRobjids array.*/
    /*Realloc or malloc as needed.*/
    
    (void) EFalloc_list(EMmsg, edges, *num_edges, edge_array_size,
                        num_GRids, INCREMENT, NULL);
    if (!(1 & *EMmsg)) goto wrapup;                        

    /*And finally move the edge.*/

    for(ii=0; ii<num_GRids; ii++)
    {
      (*edges)[*num_edges] = GRids[ii].objid;
      (*num_edges)++;
    }                                                                     
  }    

  wrapup:
   if (!(1 & OM_stat & *EMmsg))
   {
     if (*loops) om$dealloc(ptr = *loops);
     if (*edges) om$dealloc(ptr = *edges);
   }
   if (GRids) om$dealloc(ptr = GRids);
   if (ret_lps) om$dealloc(ptr = ret_lps);
   EMWRAPUP(*EMmsg, OM_stat, "EFgetLoopsEdges")
   return;
}
end implementation EMSsubbs;
