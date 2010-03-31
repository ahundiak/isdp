class implementation EMSedge;

#include "EMS.h"
#include "EMSopt.h"
#include "OMmacros.h"
#include "emsmacros.h"
#include "emsgeteddef.h"

#define BUFF_INCR 10

from EMSloop import EMnext_edge;

method EMget_encompassing_edges ( IGRlong *msg;
                                  IGRushort options;
                                  IGRboolean right_vertex;
                                  GRobjid    *loops;
                                  IGRint     *num_edges;
                                  GRobjid    **edges)
{
 IGRlong   sts;
 OM_S_CHANSELECT  to_common_edge, to_loops;
 GRobjid  first_edge, this_edge, tempid, 
          next_edge;
 OM_S_OBJECT_LINKAGE  comm_edge, this_loop; 
 IGRint  i;
 OMuint comm_edge_count, loop_count;

 *msg = EMS_S_Success;
 sts  = OM_S_SUCCESS;

 EMmake_chanselect (EMSedge_to_common_edge, &to_common_edge);

 /* Check if I am in the output buffer */

 first_edge = my_id;

 for(i=0; i < (*num_edges); i++)
   if (IF_EQ_OBJID (first_edge, (*edges)[i]))
     {
      sts = OM_I_STOP_SENDING;
      goto ret_end;
     }
 /* check for common_edges */

 sts = om$get_channel_objects(objid = first_edge,
                              p_chanselect = &to_common_edge,
                              list = &comm_edge,
                              size = 1,
                              count = &comm_edge_count);

 if(comm_edge_count)
  {
   /* check if this edge is owned by loops[1] */

   sts = EMmake_chanselect(EMSedge_to_owner, &to_loops);

   sts = om$get_channel_objects( objid = comm_edge.S_objid,
                                 p_chanselect = &to_loops,
                                 list = &this_loop,
                                 size = 1,
                                 count = &loop_count);

    if (this_loop.S_objid == loops[1])
     {
       this_edge = comm_edge.S_objid;
 
       tempid = loops[0];
       loops[0] = loops[1];
       loops[1] = tempid;

       /* get next edge in the correct direction */

        sts = om$send( msg = message EMSloop.EMnext_edge( msg,
                             EMGetEd_Next, this_edge, &next_edge),
                 targetid = loops[0]);

        sts = om$send (msg = message EMSedge.EMget_encompassing_edges
                      (msg , options, right_vertex, loops, num_edges,
                       edges),
                targetid = next_edge);
        if(sts == OM_I_STOP_SENDING) goto ret_end;            
     }

  } /* if common edge exists */

  if (! ((*num_edges) % BUFF_INCR))
   {
    if (! *num_edges)
     *edges = (GRobjid *) om$malloc (size = BUFF_INCR * 
               sizeof (GRobjid));
    else
     *edges = (GRobjid *) om$realloc (ptr = (IGRchar *)*edges, size = 
              (*num_edges + BUFF_INCR) * sizeof (GRobjid));
    EMerr_hndlr (! *edges , *msg, EMS_E_NoDynamicMemory,
    ret_end);
    }

  (*edges)[(*num_edges)] = first_edge;
  (*num_edges)++;

  sts = om$send( msg = message EMSloop.EMnext_edge( msg,
                       EMGetEd_Next, my_id, &next_edge),
           targetid = loops[0]);

  sts = om$send (msg = message EMSedge.EMget_encompassing_edges
                (msg , options, right_vertex, loops, num_edges,
                 edges),
          targetid = next_edge);

 ret_end:
   EMWRAPUP (*msg, sts , "EMSedge.EMget_encompassing_edges");
   return (sts);

}

end implementation EMSedge;         
