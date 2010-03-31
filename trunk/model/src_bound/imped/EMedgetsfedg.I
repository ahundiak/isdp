/* ###################   APOGEE COMPILED   ################## */
class implementation EMSedge;

#include "EMS.h"
#include "EMSopt.h"
#include "emsmacros.h"
#include "EMSlmdef.h"
#include "emsgeteddef.h"

from EMSloop import EMnext_edge;

method EMget_sf_edges (
        IGRlong         *EMmsg;
        IGRshort        search_flag;	
        struct GRid     *edge_ids;
        IGRint          *num_edges)
/*
 Notes
    The search flag can have one of the following options:

         EMS_WHL_EDGE -      Return all of the edges(non degenrate)
                             of the surface sharing my begin as well 
                             as end pt in (xyz) space.
         EMS_EDGE_BEG_PT -   Return the edge (non_degenerate) sharing
                             my begin pt in the (xyz) space.
         EMS_EDGE_END_PT   - Return the edge (non_degenrate) sharing
                             my end pt in the (xyz) space.

         These definitions are included in EMSlmdef.h

    The memory should be allocated for the edges' GRids
    reurned. The maximum number of edges returned can be atmost 2.

History	
          RC      03/29/87        Creation date
	  SM	  02-Dec-87	  option changes in EMnext_edge
*/
	
{
   IGRlong              OM_stat;
IGRlong   mthd_stat;
   IGRint               sts, rc, EMsend_loops();
   IGRushort    edge_prop, next_edge_option;
   GRobjid              last_edge, nxt_edge;
   IGRshort             num_recursion;
   OM_S_CHANSELECT      to_loop_chan;

   OM_stat = OM_S_SUCCESS;
   *EMmsg = EMS_S_Success;

   *num_edges = 0;

   switch (search_flag)
   {
       case EMS_WHL_EDGE:
          num_recursion =2;
          next_edge_option = EMGetEd_Previous;
          break;

       case EMS_EDGE_BEG_PT:
          num_recursion = 1;
          next_edge_option = EMGetEd_Previous;
          break;

       case EMS_EDGE_END_PT:
          num_recursion = 1;
          next_edge_option = EMGetEd_Next;
          break;

       default:
          *EMmsg = EMS_E_InvalidArg;
          goto wrapup;

   } /* switch (search_flag) */

   to_loop_chan.type = OM_e_addr;
   to_loop_chan.u_sel.addr = &ME.EMSedge->to_owner;
    
   last_edge = my_id;

    do
    {
       sts = EMsend_loops(&rc,
                message EMSloop.EMnext_edge (&mthd_stat, next_edge_option,
                 last_edge, &nxt_edge),
                last_edge, NULL, OM_K_MAXINT, EMLP_ACTIVE, NULL, NULL);
       EMerr_hndlr (!(1&OM_stat&sts),*EMmsg,EMS_E_Fail,wrapup);

       /*
        * get the nxt_edge property
        */
	
       OM_stat = om$send (msg = message EMSedge.EMget_props( &mthd_stat,
                           &edge_prop), targetid = nxt_edge);
       EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_EdgeError,wrapup);

       if ( edge_prop & EMED_DEGENERATE )
          last_edge = nxt_edge;
       else
       {
          edge_ids[*num_edges].objid = nxt_edge;
          edge_ids[*num_edges].osnum = OM_Gw_current_OS;
          ++(*num_edges);
          --num_recursion;
          if (search_flag == EMS_WHL_EDGE)
          {
            next_edge_option = EMGetEd_Next;
            last_edge = my_id;
          }
        }

      } while (num_recursion);

wrapup:

  EMWRAPUP (*EMmsg,OM_stat,"In EMSedge.EMget_sf_edges");
  return (OM_stat);

}
end implementation EMSedge;
