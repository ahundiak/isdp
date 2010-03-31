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
#include "emsinterdef.h"

from NMvertex_use import NMconnect_edges, NMinit;
from NMvertex import NMconnect_vertex_uses, NMinit;
from EMSsubbs import EMpartolbasis;
from EMSboundary import EMobint, EMget_objid;
from EMSedge import EMendpts;
from EMSloop import EMpt_location;

extern OMuword OPP_NMlistvtxuse_class_id, OPP_NMfeaturelp_class_id, 
	       OPP_NMedflp_class_id, OPP_NMptflp_class_id;

extern IGRboolean NMvertex_display_and_Rtree, NMedgevtxuse_assoc;

#define VtxInc 10
IGRint		NMcheck_ptflp_incedence();
IGRint NMintersection_vertex(EMmsg, sfid, ssi, inlp, construct, uvtol)
IGRlong *EMmsg;
struct GRid *sfid;
struct NMgmSSI *ssi;
GRobjid inlp;
struct GRvg_construct *construct;
IGRdouble *uvtol;
{
 IGRlong		sts = OM_S_SUCCESS, rc;
 struct GRid		*flps = NULL, junk;
 IGRint			numflps = 0, i, numint = 0, j;
 struct EMSsfintedpar	*flpint = NULL, *inlp_int = NULL, *this_edpar1, 
			*this_edpar2;
 GRspacenum		constos;
 GRobjid		thisvtxuse, thisvtx, thisvtxuse1, thisvtxuse2, 
			thisvtx1, thisvtx2;
 IGRpoint		xyzpt;
 struct EMSpartolbasis  partol;
 IGRdouble		xyztol;
 OMuword		no_clsid = OPP_NMedflp_class_id;
 IGRushort	obintopt = EMS_INTER_STARTPT | EMS_INTER_STOPPT
				   | EMS_INTER_MOREPRECISE;


 *EMmsg = EMS_S_Success;

 /* Get all feature loops except NMedflp types.
 */
 sts = NMget_feature_loops(EMmsg, sfid, &numflps, &flps, 
       NULL, NULL, &no_clsid, 1, NULL);
 if(!(1&*EMmsg&sts)) goto wrapup;
 if(!numflps) goto wrapup;
 constos = construct->env_info->md_id.osnum;
 BSEXTRACTPAR(&rc, BSTOLLENVEC, xyztol);

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

 for(i=0; i<numflps; i++)
  {
   numint = 0;
   if(flpint) EMsfintedpar_free(flpint, NULL);
   if(inlp_int) EMsfintedpar_free(inlp_int, NULL);
   flpint = NULL;
   inlp_int = NULL;
   sts = om$send(msg = message EMSboundary.EMobint(EMmsg, &partol, inlp, 
         &partol, obintopt, &numint, &flpint, &inlp_int), 
         senderid = NULL_OBJID, targetid = flps[i].objid, 
         targetos = flps[i].osnum);
   if(!(1&*EMmsg&sts)) goto wrapup;
   if(!numint)
    {
     sts = NMcheck_ptflp_incedence(EMmsg, flps[i].objid, inlp, &partol, 
	     &numint, &flpint, &inlp_int);
     if(!(1&*EMmsg&sts)) goto wrapup;
    }
   if(!numint)
    continue;

   this_edpar1 = inlp_int;
   this_edpar2 = flpint;
   for(j=0; j<numint; j++)
    {
     GRobjid edges[2];
     enum EMScvinttype edloc[2];
     IGRdouble *ptptr = NULL;

     sts = NMmodify_incedence(EMmsg, this_edpar1, partol.tol, sfid);
     if(!(1&*EMmsg&sts)) goto wrapup;
     sts = NMmodify_incedence(EMmsg, this_edpar2, partol.tol, sfid);
     if(!(1&*EMmsg&sts)) goto wrapup;
     /* 
       Due to tolerance problems, it is possible that we might encounter
       vertex uses at the intersection point, on both the edges, if the 
       intersection occurs at their ends. In a situation like this, the
       location on the existing feature loop (edge) is modified to be in
       middle, to force a split. This action is topologically o.k. This
       is to be done if different vertex uses are encountered at the ends
       of the two edges involved.
     */
     thisvtxuse = thisvtxuse1 = thisvtxuse2 = NULL_OBJID;
     thisvtx = thisvtx1 = thisvtx2 = NULL_OBJID;
     if( (this_edpar1->intloc != EMScvint_middle) &&
	 (this_edpar2->intloc != EMScvint_middle))
      {
       sts = NMget_matching_vtxuse(EMmsg, this_edpar1->edgeid, 
	     sfid->osnum, this_edpar1->point, partol.tol, 
	     &this_edpar1->intloc, &thisvtxuse1, &thisvtx1, NULL);
       if(!(1&*EMmsg&sts)) goto wrapup;

       sts = NMget_matching_vtxuse(EMmsg, this_edpar2->edgeid, 
             sfid->osnum, this_edpar2->point, partol.tol, 
	     &this_edpar2->intloc, &thisvtxuse2, &thisvtx2, NULL);
       if(!(1&*EMmsg&sts)) goto wrapup;

       if((!IF_NULL_OBJID(thisvtxuse1)) && (!IF_NULL_OBJID(thisvtxuse2)) &&
	  (!IF_EQ_OBJID(thisvtxuse1, thisvtxuse2)))
        {
	 thisvtx = thisvtx1;
	 thisvtxuse = thisvtxuse1;
	 this_edpar2->intloc = EMScvint_middle;
        }
       else if((!IF_NULL_OBJID(thisvtxuse1)))
        {
	 thisvtx = thisvtx1;
	 thisvtxuse = thisvtxuse1; 
        }
       else
        {
	 thisvtx = thisvtx2;
	 thisvtxuse = thisvtxuse2; 
        }
      }
     else
      {
       sts = NMget_matching_vtxuse(EMmsg, this_edpar1->edgeid, 
	     sfid->osnum, this_edpar1->point, partol.tol, 
	     &this_edpar1->intloc, &thisvtxuse, &thisvtx, NULL);
       if(!(1&*EMmsg&sts)) goto wrapup;

       if(IF_NULL_OBJID(thisvtxuse))
        {
         sts = NMget_matching_vtxuse(EMmsg, this_edpar2->edgeid, 
	       sfid->osnum, this_edpar2->point, partol.tol, 
	       &this_edpar2->intloc, &thisvtxuse,
               &thisvtx, NULL);
         if(!(1&*EMmsg&sts)) goto wrapup;
        }
      }

     edges[0] = this_edpar1->edgeid;
     edges[1] = this_edpar2->edgeid;
     edloc[0] = this_edpar1->intloc;
     edloc[1] = this_edpar2->intloc;

     /* Construct vertex use in this parametric space.
     */
     if(IF_NULL_OBJID(thisvtxuse))
      {
       sts = om$construct(osnum = constos, p_objid = &thisvtxuse, 
             classid = NMedgevtxuse_assoc ? OPP_NMvertex_use_class_id :
		       OPP_NMlistvtxuse_class_id, 
	     msg = message NMvertex_use.NMinit(EMmsg, NMinit_AddToSSI, 
		   NMvtxuse_Active, 0, NULL, NULL, NULL, ssi, sfid));
       if(!(1&*EMmsg&sts)) goto wrapup;
      }
     sts = om$send(msg = message NMvertex_use.NMconnect_edges(EMmsg, 2, 
	   edges, edloc, this_edpar2->point, NMconnect_AddToSSI, ssi), 
	   targetid = thisvtxuse, 
	   targetos = constos, senderid = NULL_OBJID);
     if(!(1&*EMmsg&sts)) goto wrapup;

     if(IF_NULL_OBJID(thisvtx))
      {
       /* Construct model space vertex for this vertex use.
       */
       sts = NMget_xyz_point(this_edpar1, construct, sfid->objid, xyzpt);
       if(!(1&sts)) goto wrapup;
       sts = NMget_matching_vtx(EMmsg, this_edpar1->edgeid, sfid->osnum,
	     xyzpt, xyztol, &this_edpar1->intloc, &thisvtx, NULL);
       if(!(1&*EMmsg&sts)) goto wrapup;
       if(IF_NULL_OBJID(thisvtx))
        {
         sts = NMget_matching_vtx(EMmsg, this_edpar2->edgeid,
	       sfid->osnum, xyzpt, xyztol, &this_edpar2->intloc, 
	       &thisvtx, NULL);
         if(!(1&*EMmsg&sts)) goto wrapup;
        }
       if(IF_NULL_OBJID(thisvtx))
        {
         ptptr = xyzpt;
	 sts = NMconstruct_vertex(EMmsg, construct, xyzpt, &thisvtx);
	 sts = om$send(msg = message NMvertex.NMinit(EMmsg, NMinit_AddToSSI,
	       NMvtx_Active, 0, NULL, NULL, ssi),
	       senderid = NULL_OBJID, targetid = thisvtx, 
	       targetos = constos);
	 if(!(1&*EMmsg&sts)) goto wrapup;
        }
      }

     junk.osnum = constos;
     junk.objid = thisvtxuse;
     sts = om$send(msg = message NMvertex.NMconnect_vertex_uses(EMmsg, 1, 
	   &junk, ptptr, ssi, NMconnect_AddToSSI), targetid = thisvtx, 
	   targetos = constos, 
	   senderid = NULL_OBJID);
     if(!(1&*EMmsg&sts)) goto wrapup;

     this_edpar1 = this_edpar1->next;
     this_edpar2 = this_edpar2->next;

    } /* for(j=0; j<numint; j++) */

  } /* for(i=0; i<numflps; i++) */

wrapup:
if(flps) om$dealloc(ptr = flps);
if(flpint) EMsfintedpar_free(flpint, NULL);
if(inlp_int) EMsfintedpar_free(inlp_int, NULL);
EMWRAPUP(*EMmsg, sts, "NMintersection_vertex");
return(sts);
}


static IGRint NMcheck_ptflp_incedence(EMmsg, flp, inlp, partol, numint, 
				      flpint, inlpint)
IGRlong *EMmsg;
GRobjid flp, inlp;
struct EMSpartolbasis *partol;
IGRint *numint;
struct EMSsfintedpar **flpint, **inlpint;
{
 IGRlong		sts = OM_S_SUCCESS;
 IGRboolean		flp_pt = FALSE, inlp_pt = FALSE;
 GRobjid		ptflp, lp, ptedid;
 IGRdouble		uvpt[2];
 struct EMSptloc_info	location;
 struct EMSsfintedpar   *EMsfintedpar_malloc(), *lpbdry, *ptflpbdry;
 OM_S_CHANSELECT	to_edges;

 *EMmsg = EMS_S_Success;
 EMmake_chanselect(EMSbd_owner_to_comps, &to_edges);

 flp_pt = EFisAncestryValid(EMmsg, flp, OM_Gw_current_OS, OPP_NMptflp_class_id,
	  TRUE);
 inlp_pt = EFisAncestryValid(EMmsg, inlp, OM_Gw_current_OS, 
	   OPP_NMptflp_class_id, TRUE);
 if( (flp_pt && inlp_pt) || (!flp_pt && !inlp_pt))
  {
   *EMmsg = EMS_I_Useless;
   goto wrapup;
  }

 ptflp = flp_pt ? flp : inlp;
 lp = flp_pt ? inlp : flp;

 sts = om$send(msg = message EMSedge.EMendpts(EMmsg, uvpt, NULL, NULL, NULL, 
       NULL), senderid = ptflp, p_chanselect = &to_edges);
 if(!(1&*EMmsg&sts)) goto wrapup;

 location.options = NULL;
 sts = om$send(msg = message EMSloop.EMpt_location(EMmsg, uvpt, &location, 
	partol), targetid = lp, senderid = NULL_OBJID);
 if(!(1&*EMmsg&sts)) goto wrapup;
 if( (location.location != EMS_L_ONEDGE) && 
     (location.location != EMS_L_ONVRTX))
  {
   *EMmsg = EMS_I_NoIntersection;
   goto wrapup;
  }

 *flpint = EMsfintedpar_malloc(EMmsg, 2);
 *inlpint = EMsfintedpar_malloc(EMmsg, 2);

 ptflpbdry = flp_pt? *flpint : *inlpint;
 lpbdry = flp_pt? *inlpint : *flpint;
 
 EMerr_hndlr(!*flpint || !*inlpint, *EMmsg, EMS_E_NoDynamicMemory, wrapup);

 lpbdry->intloc = lpbdry->next->intloc = location.edge[0].nst_pt.location;
 lpbdry->edgepar = lpbdry->next->edgepar = location.edge[0].nst_pt.param;
 OM_BLOCK_MOVE(location.edge[0].nst_pt.proj_pt, lpbdry->point, 
		2 * sizeof(IGRdouble));
 OM_BLOCK_MOVE(location.edge[0].nst_pt.proj_pt, lpbdry->next->point, 
		2 * sizeof(IGRdouble));
 lpbdry->edgeid = lpbdry->next->edgeid = location.edge[0].edge_id;


 sts = om$send(msg = message EMSboundary.EMget_objid(EMmsg, &ptedid), 
       senderid = ptflp, p_chanselect = &to_edges);
 if(!(1&*EMmsg&sts)) goto wrapup;

 ptflpbdry->intloc = ptflpbdry->next->intloc = EMScvint_lfend;
 ptflpbdry->edgepar.param = ptflpbdry->next->edgepar.param = 0.0;
 ptflpbdry->edgepar.span_inx = ptflpbdry->next->edgepar.span_inx = 0;
 OM_BLOCK_MOVE(uvpt, ptflpbdry->point, 2 * sizeof(IGRdouble));
 OM_BLOCK_MOVE(uvpt, ptflpbdry->next->point, 2 * sizeof(IGRdouble));
 ptflpbdry->edgeid = ptflpbdry->next->edgeid = ptedid;

 *numint = 1;

wrapup:
return(sts);
}
end implementation NMnonmani;
