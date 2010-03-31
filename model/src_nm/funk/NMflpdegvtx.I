/*
This function will create NMvertex_use/NMvertex objects for a point feature
loop.
*/
class implementation NMnonmani;

#include "nm.h"
#include "OMmacros.h"

from NMvertex_use import NMconnect_edges, NMinit;
from NMvertex import NMconnect_vertex_uses, NMinit;
from EMSsubbs import EMpartolbasis;
from EMSboundary import EMget_objid;
from EMSedge import EMendpts;

extern OMuword OPP_NMlistvtxuse_class_id, OPP_EMSptedge_class_id, 
	       OPP_NMvertex_use_class_id;

extern IGRboolean NMvertex_display_and_Rtree, NMedgevtxuse_assoc;


IGRint NMdegenerate_vertex(EMmsg, sfid, ssi, inlp, construct, uvtol)
IGRlong *EMmsg;
struct GRid *sfid;
struct NMgmSSI *ssi;
GRobjid inlp;
struct GRvg_construct *construct;
IGRdouble *uvtol;
{
 IGRlong		sts = OM_S_SUCCESS;
 IGRint			i;
 struct EMSsfintedpar	edpar;
 GRspacenum		constos;
 GRobjid		thisvtxuse, thisvtx;
 IGRpoint		xyzpt;
 struct EMSpartolbasis  partol;
 OM_S_CHANSELECT	to_edges;
 struct GRid		junk;

 *EMmsg = EMS_S_Success;

 constos = construct->env_info->md_id.osnum;

 if(!uvtol)
  {
   sts = om$send(msg = message EMSsubbs.EMpartolbasis(EMmsg, 
         &construct->env_info->md_env.matrix_type, construct->env_info->md_env.matrix, 
         NULL, TRUE, &partol.tol), senderid = NULL_OBJID, 
         targetid = sfid->objid, targetos = sfid->osnum);
   if(!(1&*EMmsg&sts)) goto wrapup;
  }
 else partol.tol = *uvtol;

 partol.is_valid = TRUE;
 partol.mattyp = &construct->env_info->md_env.matrix_type;
 partol.mat = construct->env_info->md_env.matrix;

 EMmake_chanselect(EMSbd_owner_to_comps, &to_edges);

 /* Get the point edge from the input loop.
 */
 edpar.edgeid = NULL_OBJID;
 sts = om$send(msg = message EMSboundary.EMget_objid(EMmsg, &edpar.edgeid), 
       senderid = inlp, targetos = sfid->osnum, p_chanselect = &to_edges, 
       from = 0, to = 0);
 if(!(1&*EMmsg&sts)) goto wrapup;
 if( (IF_NULL_OBJID(edpar.edgeid)) || 
     (!EFisAncestryValid(EMmsg, edpar.edgeid, sfid->osnum, 
       OPP_EMSptedge_class_id, FALSE)))
  {
   *EMmsg = EMS_E_InvalidArg;
   goto wrapup;
  }

 sts = om$send(msg = message EMSedge.EMendpts(EMmsg, edpar.point, NULL,
       &edpar.edgepar, NULL, NULL), 
       targetid = edpar.edgeid, targetos = sfid->osnum, senderid =NULL_OBJID);
 if(!(1&*EMmsg&sts)) goto wrapup;

 /* Check to see whether a vertex already exists. If so exit.
 */
 for(i=0; i<2; i++)
  {
   thisvtxuse = NULL_OBJID;
   thisvtx =  NULL_OBJID;
   edpar.intloc = i ? EMScvint_rtend : EMScvint_lfend; 
   sts = NMget_matching_vtxuse(EMmsg, edpar.edgeid, sfid->osnum, edpar.point, 
         partol.tol, &edpar.intloc, &thisvtxuse, &thisvtx, NULL);
   if(!(1&*EMmsg&sts)) goto wrapup;
   if(!(IF_NULL_OBJID(thisvtxuse))) goto wrapup;
  }

 /* Construct vertex use in this parametric space.
 */
 sts = om$construct(osnum = constos, p_objid = &thisvtxuse, 
       classid = NMedgevtxuse_assoc ? OPP_NMvertex_use_class_id :
  	         OPP_NMlistvtxuse_class_id, 
       msg = message NMvertex_use.NMinit(EMmsg, ssi ? NMinit_AddToSSI : NULL, 
		   NMvtxuse_Active, 0, NULL, NULL, NULL, ssi, sfid));
 if(!(1&*EMmsg&sts)) goto wrapup;

 sts = om$send(msg = message NMvertex_use.NMconnect_edges(EMmsg, 1, 
       &edpar.edgeid, &edpar.intloc, edpar.point, 
       ssi ? NMconnect_AddToSSI : NULL, ssi), 
       targetid = thisvtxuse, targetos = constos, senderid = NULL_OBJID);
 if(!(1&*EMmsg&sts)) goto wrapup;

 /* Construct model space vertex for this vertex use.
 */
 sts = NMget_xyz_point(&edpar, construct, sfid->objid, xyzpt);
 if(!(1&sts)) goto wrapup;
 sts = NMconstruct_vertex(EMmsg, construct, xyzpt, &thisvtx);
 sts = om$send(msg = message NMvertex.NMinit(EMmsg, 
       ssi ? NMinit_AddToSSI : NULL, NMvtx_Active, 0, NULL, NULL, ssi),
       senderid = NULL_OBJID, targetid = thisvtx, targetos = constos);
	 if(!(1&*EMmsg&sts)) goto wrapup;

 junk.osnum = constos;
 junk.objid = thisvtxuse;
 sts = om$send(msg = message NMvertex.NMconnect_vertex_uses(EMmsg, 1, 
       &junk, xyzpt, ssi, ssi ? NMconnect_AddToSSI : NULL), targetid = thisvtx,
       targetos = constos, senderid = NULL_OBJID);
 if(!(1&*EMmsg&sts)) goto wrapup;

wrapup:
EMWRAPUP(*EMmsg, sts, "NMdegenerate_vertex");
return(sts);
}

end implementation NMnonmani;
