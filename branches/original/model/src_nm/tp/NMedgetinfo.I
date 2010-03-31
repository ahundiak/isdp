class implementation NMedge;

#include "EMSprop.h"
#include "OMmacros.h"
#include "emsmacros.h"


method NMget_edge_info(IGRlong *EMmsg; IGRint *num_edges; struct GRid **edges, 
		       *refedge, *refsf; IGRboolean **reverse;
		       unsigned int nmquery_opt)
{
 IGRlong		sts = OM_S_SUCCESS;
 IGRint			count = 0, i;
 struct EMSobject_info	*parents = NULL;

 *EMmsg = EMS_S_Success;
 if(num_edges) *num_edges = 0;
 if(edges) *edges = NULL;
 if(reverse) *reverse = NULL;

 sts = om$send(msg = message NMassoc.NMget_parent_info(EMmsg, &parents, 
       0, &count), targetid = my_id);
 if(!(1&*EMmsg&sts)) goto wrapup;
 EMerr_hndlr(!count, *EMmsg, EMS_I_NoSolution, wrapup);

 if(edges) 
  *edges = (struct GRid *) om$malloc(size = count * sizeof(struct GRid));
 if(reverse) 
  *reverse = (IGRboolean *) om$malloc(size = count * sizeof(IGRboolean));

 if(edges)
  for(i=0; i<count; i++)
    (*edges)[i] = parents[i].grid;

 if(num_edges) *num_edges = count;
 if(reverse)
  OM_BLOCK_MOVE(ME.NMedge->reverse, *reverse, count * sizeof(IGRboolean));
 
 if(refedge) *refedge = ME.NMedge->refuse;
 if(refsf) *refsf = ME.NMedge->refsf;

wrapup:
if(parents) om$dealloc(ptr = parents);
EMWRAPUP(*EMmsg, sts, "NMedge.NMget_edge_info");
return(sts);
}



end implementation NMedge;
