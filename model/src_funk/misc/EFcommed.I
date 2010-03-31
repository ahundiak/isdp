class implementation EMSsurface;

#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "EMSopt.h"


from EMSsubbs import EMget_edges;
from EMSboundary import EMgetsurface_info;

EFreturn_edges_between_surfs(EMmsg, surf_GRid1, surf_GRid2, num_edges,
                             edges)
IGRlong *EMmsg;
struct GRid *surf_GRid1;
struct GRid *surf_GRid2;
IGRint *num_edges;
struct GRid **edges;
/* *************************************************************************
   Description
   This function will return the edges on surf_GRid1 that connect it
   with surf_GRid2.
  
   Arguments
   EMmsg : I/O : Completion messages
                 EMS_S_Success: If all goes well.
                 EMS_E_DynamicMemoryAllcoated: If no memory
                 EMS_E_InvalidArg : Invalid Arguments
                 EMS_E_Fail : If there is some form of failure.

   surf_GRid1 : I : GRid of the first surface.
   surf_GRid2 : I : GRid of the second surface.
   num_edges  : O : Number of edges that connect surf_GRid1 to surf_GRid2
   edges      : O : List of edges. Can be set to NULL in which case only
                    number is returned. 
   Notes:
    It is the callers responsibility to free the edges parameter.

   History
      PP : 11/12/92 : Creation
 ************************************************************************** */
{
 IGRlong msg_loc;
 IGRint array_size=0;
 IGRint num_loc=0,i;
 struct GRid *loc_edges = NULL;
 IGRlong status;
 struct GRmd_env md_env;
 OM_S_CHANSELECT to_comm_ed;
 OM_S_OBJID comm_srf_id;
 IGRint  sizbuf, nret;

 msg_loc = *EMmsg = EMS_S_Success;
 status = OM_S_SUCCESS;
 *num_edges = 0;

 sizbuf = sizeof(struct GRmd_env);

 if (!surf_GRid1 || !surf_GRid2 || !num_edges)
 {
  *EMmsg = EMS_E_InvalidArg;
  goto wrapup;
 }

 gr$get_module_env (msg = &msg_loc,
                    sizbuf = &sizbuf,
                    buffer = &md_env,
                    nret = &nret );
 
 status = om$send (msg = message EMSsubbs.EMget_edges(&msg_loc,
                         OM_K_MAXINT,EMS_OPT_STITCHED, &md_env, &loc_edges,
                         &array_size,
                         &num_loc),
                   senderid = NULL_OBJID,
                   targetid = surf_GRid1->objid,
                   targetos = surf_GRid2->osnum); 
 EMerr_hndlr(!(1&status&msg_loc), *EMmsg, EMS_E_Fail, wrapup);

 EMmake_chanselect(EMSedge_to_common_edge, &to_comm_ed);
 array_size = 0;

 for (i=0;i<num_loc;i++)
 {
  comm_srf_id = NULL_OBJID;

  status = om$send (msg = message EMSboundary.EMgetsurface_info(&msg_loc,
                          &comm_srf_id,NULL),
                    senderid = loc_edges[i].objid,
                    p_chanselect = &to_comm_ed,
                    targetos = surf_GRid2->osnum);
  if (comm_srf_id == NULL_OBJID) continue;
  if (comm_srf_id == surf_GRid2->objid)
  {
   if (edges)
   {
    if ((*num_edges + 1) > array_size)
    {
     if (!(*edges))
     {
      *edges = (struct GRid *) om$malloc(size = sizeof(struct GRid) * 5);
      EMerr_hndlr(!(*edges), *EMmsg, EMS_E_DynamicMemoryAllocated, wrapup);
      array_size = 5;
     }
     else
     {
      *edges = (struct GRid *) om$realloc(ptr = (IGRchar *) (*edges),
                                         size = sizeof (struct GRid) *
                                         (array_size + 5));
      EMerr_hndlr(!(*edges), *EMmsg, EMS_E_DynamicMemoryAllocated, wrapup);
      array_size += 5;
     }
    }
  
    (*edges)[*num_edges].objid = loc_edges[i].objid;
    (*edges)[*num_edges].osnum = loc_edges[i].osnum;
   }
   (++(*num_edges));
  }
 }

wrapup:
if (!(1&status&msg_loc))
{
 if (*edges) om$dealloc(ptr = (*edges));
 (*edges) = NULL;
 (*num_edges) = 0;
}
if (loc_edges) om$dealloc(ptr = loc_edges);
return (status);
}
end implementation EMSsurface;

