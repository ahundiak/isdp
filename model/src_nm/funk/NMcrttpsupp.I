/*
This function will accept intersection data on a surface and construct
non manifold topological elements.
*/
class implementation NMnonmani;

#include "nm.h"
#include "OMmacros.h"
#include "EMSprop.h"
#include "EMSopt.h"
#include "emsmacros.h"
#include "godef.h"
#include "bserr.h"
#include "bsparameters.h"

from EMSboundary import EMgetsurface_info;

IGRint NMget_xyz_point(edpar, construct, sfid, xyzpt)
struct EMSsfintedpar *edpar;
struct GRvg_construct *construct;
IGRpoint xyzpt;
GRobjid sfid;
{
 IGRlong sts, rc;
 IGRdouble junk[4];

 if(IF_NULL_OBJID(sfid))
  {
   sts = om$send(msg = message EMSboundary.EMgetsurface_info(&rc, &sfid, NULL),
         targetid = edpar->edgeid, targetos = construct->env_info->md_id.osnum, 
         senderid = NULL_OBJID);
   if(!(1&sts&rc)) goto wrapup;
  }

 sts = om$send(msg = message GRvg.EMptatpr(&rc,
       &construct->env_info->md_env.matrix_type, 
       construct->env_info->md_env.matrix, edpar->point, 2, junk), 
       targetid = sfid, targetos = construct->env_info->md_id.osnum, 
       senderid = NULL_OBJID);
 if(!(1&rc&sts)) goto wrapup;
 OM_BLOCK_MOVE(junk, xyzpt, sizeof(IGRpoint));

wrapup:
EMWRAPUP(rc, sts, "NMget_xyz_point");
return(sts);
}

IGRint NMget_matching_vtxuse(EMmsg, edgeid, edgeos, uvpt, tol, atloc, vtxuse, 
			     vtx, nmquery_opt)
IGRlong *EMmsg;
GRobjid edgeid;
GRspacenum edgeos;
IGRdouble *uvpt, tol;
enum EMScvinttype *atloc;
GRobjid *vtxuse, *vtx;
unsigned int nmquery_opt;
{
 IGRlong		sts = OM_S_SUCCESS;
 GRobjid		*locvtxuse = NULL;
 IGRint			numlocvtxuse = 0;
 struct GRid		*locvtx = NULL, refedge;

 *EMmsg = EMS_S_Success;
 if(vtx) *vtx = NULL_OBJID;
 *vtxuse = NULL_OBJID;

 refedge.objid = edgeid;
 refedge.osnum = edgeos;

 sts = NMget_vertex_use(EMmsg, &refedge, &numlocvtxuse, &locvtxuse, 
       NULL, NULL, NULL, &locvtx, NULL, NULL, uvpt, NULL, atloc, &tol, NULL, 
       nmquery_opt, NULL, NULL);
 if(!(1&*EMmsg&sts)) goto wrapup;
 if( (*EMmsg == EMS_I_Fail) && numlocvtxuse) locvtx[0].objid = NULL_OBJID;
 if(numlocvtxuse)
  {
   *vtxuse = locvtxuse[0];
   *vtx = locvtx[0].objid;
  }
wrapup:
if(locvtxuse) om$dealloc(ptr = locvtxuse);
if(locvtx) om$dealloc(ptr = locvtx);
EMWRAPUP(*EMmsg, sts, "NMget_matching_vtxuse");
return(sts);
}


IGRint NMget_matching_vtx(EMmsg, edgeid, edgeos, xyzpt, tol, atloc, vtx, 
			  nmquery_opt)
IGRlong *EMmsg;
GRobjid edgeid, *vtx;
GRspacenum edgeos;
IGRdouble *xyzpt, tol;
enum EMScvinttype *atloc;
unsigned int nmquery_opt;
{
 IGRlong		sts = OM_S_SUCCESS;
 struct GRid		*edgemates = NULL, *locvtx = NULL, refedge;
 IGRint			numedgemates = 0, numvtxuse = 0, i;
 IGRboolean		*reverse = NULL, consider_rev = FALSE, 
			ref_rev = FALSE;
 enum EMScvinttype	locatloc;

 *vtx = NULL_OBJID;
 refedge.objid = edgeid;
 refedge.osnum = edgeos;
 
 if(atloc && ( (*atloc == EMScvint_rtend) || (*atloc == EMScvint_lfend)))
  consider_rev = TRUE;

 sts = NMget_edge_mates(EMmsg, &refedge, &numedgemates, &edgemates, 
       consider_rev ? &reverse : NULL, NULL, NULL, NULL, nmquery_opt, NULL, 
       NULL);
 if(!(1&*EMmsg&sts)) goto wrapup;

 if(consider_rev)
  for(i=0; i<numedgemates; i++)
   if(IF_EQ_GRID(refedge, edgemates[i]))
    {
     ref_rev = reverse[i];
     break;
    }

 for(i=0; i<numedgemates; i++)
  {
   if(locvtx) om$dealloc(ptr = locvtx);
   locvtx = NULL;
   numvtxuse = 0;

   /* If the vertex at either ends is desired, and if it is sought from
      a mate of the input edge, then the location on the mate edge has to
      adjusted based upon reverse connectivity between the reference edge
      and the mate edge.
   */
   if(consider_rev && (!IF_EQ_GRID(refedge, edgemates[i])))   
    {
     if((ref_rev && !reverse[i]) || (!ref_rev && reverse[i]))
      locatloc = (*atloc == EMScvint_rtend) ? EMScvint_lfend : EMScvint_rtend;
     else locatloc = *atloc;
    }
   else if(atloc) locatloc = *atloc;


   sts = NMget_vertex_use(EMmsg, &edgemates[i], &numvtxuse, NULL, NULL, NULL, 
	 NULL, &locvtx, NULL, NULL, NULL, xyzpt, atloc ? &locatloc : NULL, 
	 NULL, &tol, nmquery_opt, NULL, NULL);
   if(!(1&*EMmsg&sts)) goto wrapup;
   if(*EMmsg == EMS_I_Fail) numvtxuse = 0;
   if(numvtxuse)
    {
     *vtx = locvtx[0].objid;
     break;
    }
  }

wrapup:

if(locvtx) om$dealloc(ptr = locvtx);
if(edgemates) om$dealloc(ptr = edgemates);
if(reverse) om$dealloc(ptr = reverse);

EMWRAPUP(*EMmsg, sts, "NMget_matching_vtx");
return(sts);
}


extern OMuword OPP_NMpartedge_class_id;

IGRint NMmodify_incedence(EMmsg, this_edpar, partol, sfid)
IGRlong *EMmsg;
struct EMSsfintedpar *this_edpar;
IGRdouble partol;
struct GRid *sfid;
{
 IGRlong		sts = OM_S_SUCCESS;
 struct EMSsfintedpar	outedpar;
 struct EMSpartolbasis  struct_partol;

 *EMmsg = EMS_S_Success;

 if(!this_edpar || (IF_NULL_OBJID(this_edpar->edgeid)) ||
      EFisAncestryValid(EMmsg, this_edpar->edgeid, sfid->osnum, 
      OPP_NMpartedge_class_id, FALSE)) goto wrapup;

 struct_partol.tol = partol;
 struct_partol.is_valid = TRUE;

 outedpar.edgeid = NULL_OBJID;
 sts = NMincedence(EMmsg, this_edpar, sfid, &struct_partol, &outedpar);
 if(!(1&*EMmsg&sts)) goto wrapup;
   
 if( (*EMmsg != EMS_I_NotFound) && (!IF_NULL_OBJID(outedpar.edgeid)))
  *this_edpar = outedpar;

wrapup:
EMWRAPUP(*EMmsg, sts, "NMmodify_incedence");
return(sts);
}

from NMedge import NMedge_reversed;
from NMvertex_use import NMedge_reversed;
from EMSedge import EMset_props, EMgetbounds;
from EMSpartedge import EMputbounds;

extern OMuword OPP_EMSpartedge_class_id;

IGRint NMreverse_the_edge(EMmsg, edgeid, edgeos)
IGRlong *EMmsg;
GRobjid edgeid;
GRspacenum edgeos;
{
 IGRlong sts = OM_S_SUCCESS;
 struct GRid junkedge, nm;
 GRobjid *allvtxuses = NULL;
 IGRint numallvtxuses = 0, v;

 *EMmsg = EMS_S_Success;

 sts = om$send(msg = message EMSedge.EMset_props(EMmsg, EMED_REVERSED, 
       EMS_O_TOGGLE), targetid = edgeid, targetos = edgeos, 
       senderid = NULL_OBJID);
 if(!(1&*EMmsg&sts)) goto wrapup;
	
 if(EFisAncestryValid(EMmsg, edgeid, edgeos, OPP_EMSpartedge_class_id, FALSE))
  {
   struct EMSedgebound bounds[2], tmpbound;
	
   sts = om$send(msg = message EMSedge.EMgetbounds(EMmsg, bounds), 
         targetid = edgeid, targetos = edgeos, 
         senderid = NULL_OBJID);
   if(!(1&*EMmsg&sts)) goto wrapup;
   tmpbound = bounds[0];
   bounds[0] = bounds[1];
   bounds[1] = tmpbound;
   sts = om$send(msg = message EMSpartedge.EMputbounds(EMmsg, bounds), 
         targetid = edgeid, targetos = edgeos, 
         senderid = NULL_OBJID);
   if(!(1&*EMmsg&sts)) goto wrapup;
  }
	 
 /* Since we have reversed this edge, the NMedge and the NMvertex_use
    that it was connected to need to be notified.
 */
 junkedge.osnum = edgeos;
 junkedge.objid = edgeid;

 nm.objid = NULL_OBJID;
 sts = NMget_edge_mates(EMmsg, &junkedge, NULL, NULL, NULL, NULL,
       NULL, &nm, NULL, NULL, NULL);
 if(!(1&*EMmsg&sts)) goto wrapup;
 if(!IF_NULL_OBJID(nm.objid))
  {
   sts = om$send(msg = message NMedge.NMedge_reversed
         (EMmsg, &junkedge), targetid = nm.objid, targetos = nm.osnum, 
         senderid = NULL_OBJID);
   if(!(1&*EMmsg&sts)) goto wrapup;	
  }

 numallvtxuses = 0;
 sts = NMget_vertex_use(EMmsg, &junkedge, &numallvtxuses, &allvtxuses, 
       NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 
       NULL,NMquery_ConsiderExternalToModel | NMquery_ConsiderInactive,
       NULL, NULL);
 if(!(1&*EMmsg&sts)) goto wrapup;
 for(v=0; v<numallvtxuses; v++)
  {
   sts = om$send(msg = message NMvertex_use.NMedge_reversed
	 (EMmsg, &junkedge), targetid = allvtxuses[v], 
	 targetos = edgeos, senderid = NULL_OBJID);
   if(!(1&*EMmsg&sts)) goto wrapup;	
  }

	
wrapup:
if(allvtxuses) om$dealloc(ptr = allvtxuses);
return(sts);
}
end implementation NMnonmani;
