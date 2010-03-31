class implementation NMnonmani;

#include "OMmacros.h"

from EMSboundary import EMgetsurface_info;
from NMvertex_use import NMget_incedence_info;

struct NMfindsf_considered
{
 GRobjid *edges, *vtxuses;
 IGRint num_edges, num_vtxuses, edbufsize, vtxusebufsize;
};

#define VtxInc 5
#define EdInc	10

%safe
void			NMsm_put_ed_considered(), 
				NMsm_put_vtxuse_considered();
short			NMsm_considered();
%endsafe

IGRint	NMfind_sf_no_matter_what(EMmsg, edid, sfid, ptol, considered)
IGRlong *EMmsg;
struct GRid *edid, *sfid;
struct EMSpartolbasis *ptol;
struct NMfindsf_considered *considered;
{
 IGRlong			sts = OM_S_SUCCESS;
 OM_S_OBJECT_LINKAGE		*pe = NULL;
 IGRint				numpe = 0, i, j, num_vtxuses = 0, 
				num_vtuedges =0;
 struct GRid			junk;
 GRobjid			*vtxuses = NULL, *vtuedges = NULL;
 struct NMfindsf_considered 	loc_considered;

 *EMmsg = EMS_S_Success;
 if(sfid) sfid->objid = NULL_OBJID;
 if(sfid) sfid->osnum = edid->osnum;
 if(ptol) ptol->is_valid = FALSE;
 junk.osnum = edid->osnum;
 loc_considered.num_edges = loc_considered.num_vtxuses =
 loc_considered.edbufsize = loc_considered.vtxusebufsize = 0;
 loc_considered.edges = NULL;
 loc_considered.vtxuses = NULL;
 if(!considered) considered = &loc_considered;

 if(NMsm_considered(considered, edid->objid)) 
  {
   *EMmsg = EMS_I_NotFound;
   goto wrapup;
  }

 /* Path for an edge upto the surface is -
  o via active loop
  o via some partedge which is owned by an active loop.
  o via some other edges of the vertex uses this edge is connected to.
 */
 sts = om$send(msg = message EMSboundary.EMgetsurface_info(EMmsg, 
       sfid ? &sfid->objid : NULL, ptol), senderid = NULL_OBJID, 
       targetid = edid->objid, targetos = edid->osnum);
 if(!(1&*EMmsg&sts)) goto wrapup;

 if(sfid && (!IF_NULL_OBJID(sfid->objid))) goto wrapup;
 if(ptol && ptol->is_valid) goto wrapup;

 NMsm_put_ed_considered(EMmsg, considered, edid->objid);
 if(!(1&*EMmsg)) goto wrapup;

 for(j=0; j<2; j++)
  {
   if(pe) om$dealloc(ptr = pe);
   pe = NULL;
   numpe = 0;
   if(j)
    sts = EMcount_partedges(EMmsg, edid->objid, &numpe, &pe, NULL, NULL, NULL);
   else
    sts = NMcount_nmpartedges(EMmsg, edid->objid, edid->osnum, &numpe, &pe, 
          NULL, NULL, NULL);
   if(!(1&sts&*EMmsg)) goto wrapup;

   for(i=0; i<numpe; i++)
    {
     junk.objid = pe[i].S_objid;
     sts = NMfind_sf_no_matter_what(EMmsg, &junk, sfid, ptol, considered);
     if(!(1&*EMmsg&sts)) goto wrapup;

     if(sfid && (!IF_NULL_OBJID(sfid->objid))) goto wrapup;
     if(ptol && ptol->is_valid) goto wrapup;
    }
  }

 /* Get all the vertex uses this edge is connected to. For each vertex use
    get all the edges and start looking up. I don't get all the edges in
    the same call so that I can stop as soon as the surface is found, without
    getting further edges.
 */
 sts = NMget_vertex_use(EMmsg, edid, &num_vtxuses, &vtxuses, NULL, NULL, NULL, 
       NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 
       NMquery_ConsiderExternalToModel | NMquery_ConsiderInactive, NULL, NULL);
 if(!(1&*EMmsg&sts)) goto wrapup;

 for(i=0; i<num_vtxuses; i++)
  {
   if(NMsm_considered(considered, vtxuses[i]))
    continue;

   if(vtuedges) om$dealloc(ptr = vtuedges);
   vtuedges = NULL;
   num_vtuedges = 0;
   sts = om$send(msg = message NMvertex_use.NMget_incedence_info(EMmsg, 
         NULL_OBJID, &num_vtuedges, &vtuedges, NULL, NULL, NULL, NULL, NULL), 
	 targetid = vtxuses[i], targetos = edid->osnum, senderid = NULL_OBJID);
   if(!(1&*EMmsg&sts)) goto wrapup;

   NMsm_put_vtxuse_considered(EMmsg, considered, vtxuses[i]);
   if(!(1&*EMmsg)) goto wrapup;

   for(j=0; j<num_vtuedges; j++)
    {
     if(IF_EQ_OBJID(edid->objid, vtuedges[j])) continue;

     junk.objid = vtuedges[j];
     sts = NMfind_sf_no_matter_what(EMmsg, &junk, sfid, ptol, considered);
     if(!(1&*EMmsg&sts)) goto wrapup;

     if(sfid && (!IF_NULL_OBJID(sfid->objid))) goto wrapup;
     if(ptol && ptol->is_valid) goto wrapup;
    }
  }

wrapup:

if(pe) om$dealloc(ptr = pe);
if(vtxuses) om$dealloc(ptr = vtxuses);
if(vtuedges) om$dealloc(ptr = vtuedges);
if(loc_considered.edges) om$dealloc(ptr = loc_considered.edges);
if(loc_considered.vtxuses) om$dealloc(ptr = loc_considered.vtxuses);

EMWRAPUP(*EMmsg, sts, "NMfind_sf_no_matter_what");
return(sts);
}


static void NMsm_put_ed_considered(EMmsg, consi, ed)
IGRlong *EMmsg;
struct NMfindsf_considered *consi;
GRobjid ed;
{
 *EMmsg = EMS_S_Success;
	
 if(!consi->edbufsize)
  {
   if(consi->edges)
    consi->edges = (GRobjid *) om$realloc(ptr = (IGRchar *) consi->edges, 
         size = 
	(consi->num_edges + EdInc) * sizeof(GRobjid));
   else
    consi->edges = (GRobjid *) om$malloc(size = EdInc * sizeof(GRobjid));
   EMerr_hndlr(!consi->edges, *EMmsg, EMS_E_NoDynamicMemory, wrapup);
   consi->edbufsize = EdInc;
  }
 consi->edges[consi->num_edges++] = ed;
 consi->edbufsize--;

wrapup:
;
}

static void NMsm_put_vtxuse_considered(EMmsg, consi, vtxuse)
IGRlong *EMmsg;
struct NMfindsf_considered *consi;
GRobjid vtxuse;
{
 *EMmsg = EMS_S_Success;
	
 if(!consi->vtxusebufsize)
  {
   if(consi->vtxuses)
    consi->vtxuses = (GRobjid *) om$realloc(ptr = (IGRchar *) consi->vtxuses,
         size = 
	(consi->num_vtxuses + VtxInc) * sizeof(GRobjid));
   else
    consi->vtxuses = (GRobjid *) om$malloc(size = VtxInc * sizeof(GRobjid));
   EMerr_hndlr(!consi->vtxuses, *EMmsg, EMS_E_NoDynamicMemory, wrapup);
   consi->vtxusebufsize = VtxInc;
  }
 consi->vtxuses[consi->num_vtxuses++] = vtxuse;
 consi->vtxusebufsize--;

wrapup:
;
}

static IGRboolean NMsm_considered(consi, obj)
struct NMfindsf_considered *consi;
GRobjid obj;
{
 IGRint	i;

 for(i=0; i<consi->num_edges; i++)
  if(IF_EQ_OBJID(consi->edges[i], obj))
   return(TRUE);

 for(i=0; i<consi->num_vtxuses; i++)
  if(IF_EQ_OBJID(consi->vtxuses[i], obj))
   return(TRUE);

 return(FALSE);
}

end implementation NMnonmani;
