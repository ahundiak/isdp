/*
To get the new uv point for the vertex use -

 This method assumes equal number of parents and the dimension of the edloc
 instance data array. The first valid edge parent's location is used to get
 the corresponding end point as the new uv point for the vertex use.
 
 The above only if new uv point is not supplied.
*/
class implementation NMvertex_use;

#include "EMSprop.h"
#include "OMmacros.h"
#include "emsmacros.h"

#define StaticBuf 10

from EMSedge import EMendpts;

extern OMuword OPP_EMSedge_class_id;
extern OMuint OM_Gf_verbose_warning;

method NMreset(IGRlong *EMmsg; IGRdouble *newuv; struct GRmd_env *env)
{
 IGRlong		sts = OM_S_SUCCESS;
 IGRint			count = 0, i, num_new = 0;
 GRobjid		*edges = NULL, edgesbuf[StaticBuf];
 enum EMScvinttype	*loc_on_edge = NULL, loconedgebuf[StaticBuf], tmploc;
 struct EMSobject_info	*parents = NULL;
 IGRdouble		uvpt[2];
 IGRboolean		got_uvpt = FALSE;
 unsigned int	connect_opt = NMconnect_ExternalToModel;

 *EMmsg = EMS_S_Success;

 sts = om$send(msg = message NMassoc.NMget_parent_info(EMmsg, &parents, 0, 
       &count), targetid = my_id);
 if(!(1&*EMmsg&sts)) goto wrapup;
 EMerr_hndlr(!count, *EMmsg, EMS_E_InvalidSend, wrapup);

 if( !newuv && 
     ((i = om$dimension_of(varray = ME.NMvertex_use->edloc)) != count))
  {
   *EMmsg = EMS_E_InvalidSend;
   goto wrapup;
  }

 if(count > StaticBuf)
  {
   edges = (GRobjid *) om$malloc(size = count * sizeof(GRobjid));
   loc_on_edge = (enum EMScvinttype *) om$malloc(size = count * 
		 sizeof(enum EMScvinttype));
  }
 else
  {
   edges = (GRobjid *) edgesbuf;
   loc_on_edge = loconedgebuf;
  }
 EMerr_hndlr(!edges || !loc_on_edge, *EMmsg, EMS_E_NoDynamicMemory, wrapup);


 /* An associative vertex use can rely on the fact that even if its parent
    edge is deleted, the corresponding pointer is still connected to it.
    This implies that there should never be a mismatch between the edloc
    instance data array dimension and the number of parents. Hence, as soon
    as a valid edge parent is detected, I pick up the location on that edge
    from the instance data and get the corresponding end point as the
    new uv point for the vertex use.
 */
 for(i=0; i<count; i++)
  {
   if(!EFisAncestryValid(EMmsg, parents[i].grid.objid, parents[i].grid.osnum, 
       OPP_EMSedge_class_id, TRUE)) continue;

   edges[num_new] = parents[i].grid.objid;
   loc_on_edge[num_new++] = ME.NMvertex_use->edloc[i];

   if(newuv || got_uvpt) continue;

   tmploc = ME.NMvertex_use->edloc[i];
   if( (tmploc == EMScvint_rtend) || (tmploc == EMScvint_lfend))
    {
     sts = om$send(msg = message EMSedge.EMendpts(EMmsg, 
           tmploc == EMScvint_rtend ? NULL : uvpt, 
	   tmploc == EMScvint_rtend ? uvpt : NULL, NULL, NULL, NULL), 
	   targetid = parents[i].grid.objid);
     if(!(1&*EMmsg&sts)) goto wrapup;
     got_uvpt = TRUE;
    }
  }

 EMerr_hndlr(!newuv && !got_uvpt, *EMmsg, EMS_E_Fail, wrapup);

 /* Disconnect the channel and reconnect the edges.
 */
 sts = om$send(msg = message NDnode.NDdisconnect(0, NULL), targetid = my_id);
 if(!(1&sts)) goto wrapup;

 sts = om$send(msg = message NMvertex_use.NMconnect_edges(EMmsg, num_new, 
       edges, loc_on_edge, newuv ? newuv :uvpt, connect_opt, NULL), 
       targetid = my_id);
 if(!(1&*EMmsg&sts)) goto wrapup;

wrapup:
if(parents) om$dealloc(ptr = parents);
if(edges && (edges != edgesbuf)) om$dealloc(ptr = edges);
if(loc_on_edge && (loc_on_edge != loconedgebuf)) om$dealloc(ptr = loc_on_edge);

if(OM_Gf_verbose_warning)
 {
  EMWRAPUP(*EMmsg, sts, "NMvertex_use.NMreset");
 }
return(sts);
}

end implementation NMvertex_use;
