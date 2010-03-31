class implementation NMedge;

#include "EMSprop.h"
#include "OMmacros.h"
#include "emsmacros.h"

from EMSboundary import EMgetsurface_info;

extern OMuword OPP_EMSedge_class_id;
extern OMuint OM_Gf_verbose_warning;

#define StaticBuf 10

method NMreset_refuse(IGRlong *EMmsg; struct GRid *refuse, *refsf;
		      struct GRmd_env *env)
{
 IGRlong		sts = OM_S_SUCCESS;
 IGRint			count = 0, i, num_new = 0;
 struct GRid		*edges = NULL, edgesbuf[StaticBuf], 
			*surfs = NULL, surfsbuf[StaticBuf];
 struct EMSobject_info	*parents = NULL;

 *EMmsg = EMS_S_Success;

 sts = om$send(msg = message NMassoc.NMget_parent_info(EMmsg, &parents, 0, 
       &count), targetid = my_id);
 if(!(1&*EMmsg&sts)) goto wrapup;
 EMerr_hndlr(!count, *EMmsg, EMS_E_InvalidSend, wrapup);

 if(count > StaticBuf)
  {
   edges = (struct GRid *) om$malloc(size = count * sizeof(struct GRid));
   surfs = (struct GRid *) om$malloc(size = count * sizeof(struct GRid));
  }
 else
  {
   edges = (struct GRid *) edgesbuf;
   surfs = (struct GRid *) surfsbuf;
  }
 EMerr_hndlr(!edges || !surfs, *EMmsg, EMS_E_NoDynamicMemory, wrapup);

 /* Collect all edges, disconnect the channel and reconnect them.
 */
 sts = om$send(msg = message NDnode.NDdisconnect(0, NULL), targetid = my_id);
 if(!(1&sts)) goto wrapup;

 for(i=0; i<count; i++)
  {
   if(!EFisAncestryValid(EMmsg, parents[i].grid.objid, parents[i].grid.osnum, 
       OPP_EMSedge_class_id, TRUE)) continue;

   edges[num_new] = parents[i].grid;
   sts = om$send(msg = message EMSboundary.EMgetsurface_info(EMmsg, 
         &surfs[num_new].objid, NULL), targetid = edges[num_new].objid, 
         targetos = edges[num_new].osnum);
   if(!(1&*EMmsg&sts)) goto wrapup;
   surfs[num_new].osnum = edges[num_new].osnum;
   num_new++;
  }

 if(num_new)
  {
   sts = om$send(msg = message NMedge.NMconnect_edges(EMmsg, num_new, edges, 
         surfs, NULL, env, NULL, NULL), targetid = my_id);
   if(!(1&*EMmsg&sts)) goto wrapup;
   if(refuse) *refuse = edges[0];
   if(refsf) *refsf = surfs[0];
  }
 else *EMmsg = EMS_I_Useless;

wrapup:
if(parents) om$dealloc(ptr = parents);
if(edges && (edges != edgesbuf)) om$dealloc(ptr = edges);
if(surfs && (surfs != surfsbuf)) om$dealloc(ptr = surfs);

if(OM_Gf_verbose_warning)
 {
  EMWRAPUP(*EMmsg, sts, "NMedge.NMreset_refuse");
 }
return(sts);
}

end implementation NMedge;
