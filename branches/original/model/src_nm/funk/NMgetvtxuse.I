class implementation NMvertex_use;

/*
   HISTORY

        Sudha   06/28/93        Modified for BSprototype ansification
*/

#define StaticBuf 10

#include "OMmacros.h"
#include "emsmacros.h"
#include "EMSprop.h"
#include "bserr.h"
#include "bsdistptpt.h"

extern OMuword OPP_NMvertex_use_class_id, OPP_NMlistvtxuse_class_id;

from EMSboundary import EMgetsurface_info;
from EMSedge import EMendpts, EMptproject, EMget_props;
from NMvertex import NMconnect_vertex_uses, NMinit;

extern IGRboolean NMedgevtxuse_assoc;

IGRint NMget_vertex_use(EMmsg, refedge, numvtxuse, vtxuse, numedges, edges, 
			loc_on_edge, xyzvtx, uvpt, xyzpt, checkuvpt, 
			checkxyzpt, atloc, uvtol, xyztol, nmquery_opt, 
			ssi, construct)
IGRlong *EMmsg;
struct GRid *refedge;
IGRint *numvtxuse;
GRobjid **vtxuse;
IGRint **numedges;
GRobjid ***edges;
enum EMScvinttype ***loc_on_edge;
struct GRid **xyzvtx;
IGRdouble **uvpt, **xyzpt, *checkuvpt, *checkxyzpt, *uvtol, *xyztol;
enum EMScvinttype *atloc;
unsigned int nmquery_opt;
struct NMgmSSI *ssi;
struct GRvg_construct *construct;
{
 IGRlong 		sts = OM_S_SUCCESS;
 struct GRid		*deps = NULL;
 GRobjid		*locvtxuse = NULL, locvtxusebuf[StaticBuf];
 IGRint			i, numdeps = 0, locnumvtxuse = 0, depbufsize = 0;
 unsigned char	vtuprops = NULL;
 OMuword		chkclsid = OPP_NMvertex_use_class_id;
 IGRushort	edprops = NULL;

 *EMmsg = EMS_S_Success;

 if(numvtxuse) *numvtxuse = 0;
 if(numedges) *numedges = NULL;
 if(edges) *edges = NULL;
 if(loc_on_edge) *loc_on_edge = NULL;
 if(vtxuse) *vtxuse = NULL;
 if(xyzvtx) *xyzvtx = NULL;
 if(uvpt) *uvpt = NULL;
 if(xyzpt) *xyzpt = NULL;

 sts = NMget_comp_dependents(EMmsg, refedge, &chkclsid, &numdeps, &deps, 
       &depbufsize, NULL, 0, MAXINT);
 if(!(1&*EMmsg&sts)) goto wrapup;
 sts = NMget_comp_listeners(EMmsg, refedge, &chkclsid, &numdeps, &deps, 
       &depbufsize, NULL, 0, MAXINT);
 if(!(1&*EMmsg&sts)) goto wrapup;

 if(numdeps > StaticBuf)
   locvtxuse = (GRobjid *) om$malloc(size = numdeps * sizeof(GRobjid));
 else
   locvtxuse = locvtxusebuf;
 EMerr_hndlr(!locvtxuse, *EMmsg, EMS_E_NoDynamicMemory, wrapup);

 for(i=0; i<numdeps; i++)
  {
   sts = om$send(msg = message NMvertex_use.NMprop(EMmsg, NMprop_Get, 
          &vtuprops), targetid = deps[i].objid, senderid = NULL_OBJID, 
          targetos = deps[i].osnum);
   if(!(1&*EMmsg&sts)) goto wrapup;

   /* If vtx uses created external to modeling operations are to be ignored
      check and do it.
   */
   if( (!(nmquery_opt & NMquery_ConsiderExternalToModel)) && 
       (vtuprops & NMvtxuse_ExternalToModel))
    continue;

   /* If inactive vtx uses are to be ignored, check and do it.
   */
   if( (!(nmquery_opt & NMquery_ConsiderInactive)) && 
       (!(vtuprops & NMvtxuse_Active)))
    continue;

   locvtxuse[locnumvtxuse++] = deps[i].objid;
  }

 if(!locnumvtxuse) goto create_vtxuse;
 
 if(vtxuse) 
  {
   *vtxuse = (GRobjid *) om$malloc(size = locnumvtxuse * sizeof(GRobjid));
   EMerr_hndlr(!*vtxuse, *EMmsg, EMS_E_NoDynamicMemory, wrapup);
   OM_BLOCK_MOVE(locvtxuse, *vtxuse, locnumvtxuse * sizeof(GRobjid));
  }
 if(numvtxuse) *numvtxuse = locnumvtxuse;


 if(numedges || edges || loc_on_edge || xyzvtx || uvpt || xyzpt ||
    checkuvpt || checkxyzpt || atloc)
  {
   IGRint num = 0;
   IGRboolean skip = FALSE;
   IGRdouble locuvpt[2], locxyzpt[3], BSdistptpt();
   IGRlong rc;

   if(numedges)
    *numedges = (IGRint *) om$malloc(size = locnumvtxuse * sizeof(IGRint));
   if(edges)
    *edges = (GRobjid **) om$malloc(size = locnumvtxuse*sizeof(GRobjid *));
   if(loc_on_edge)
    *loc_on_edge = (enum EMScvinttype **) om$malloc(size = locnumvtxuse *
                   sizeof(enum EMScvinttype *));
   if(xyzvtx)
    *xyzvtx = (struct GRid *) om$malloc(size = locnumvtxuse *
              sizeof(struct GRid));
   if(uvpt)
    *uvpt = (IGRdouble *) om$malloc(size = locnumvtxuse * 2 * 
	      sizeof(IGRdouble));
   if(xyzpt)
    *xyzpt = (IGRdouble *) om$malloc(size = locnumvtxuse * 3 * 
	      sizeof(IGRdouble));

   if(numvtxuse) *numvtxuse = 0;

   sts = om$send(msg = message EMSedge.EMget_props(EMmsg, &edprops), 
	 targetid = refedge->objid, targetos = refedge->osnum, 
	 senderid = NULL_OBJID);
   if(!(1&*EMmsg&sts)) goto wrapup;

   for(i=0; i<locnumvtxuse; i++)
    {
     skip = FALSE;

     if(checkuvpt || checkxyzpt || atloc)
      {
       enum EMScvinttype *thisedloc = NULL;

       /* If a check point is supplied, see whether this vtx use is within
          tolerance. If not skip it. If explicit location is specified check
	  that too. These checks are not mutually exclusive. All checks are
	  possible in the same call.
       */
       sts = om$send(msg = message NMvertex_use.NMget_incedence_info(EMmsg, 
             refedge->objid, NULL, NULL, atloc ? &thisedloc : NULL, NULL, 
	     checkuvpt ? locuvpt : NULL, checkxyzpt ? locxyzpt : NULL, NULL), 
           targetid = locvtxuse[i], targetos = refedge->osnum, 
           senderid = NULL_OBJID);
       if(!(1&*EMmsg&sts)) goto wrapup;
       if( (*EMmsg == EMS_I_Fail) && checkxyzpt)
        {
	 skip = TRUE;
	 *EMmsg = EMS_S_Success;
        }
       else
        {
	 /* When vertex uses at either ends of an edge are desired,
	    avoid any geometrical checks.
	 */
	 if(atloc && ( (*atloc == EMScvint_rtend)||(*atloc == EMScvint_lfend)))
	  {
	   /* If the edge is closed, then lfend and rtend can be treated
	      as being the same.
	   */
	   if(!(edprops & EMED_OPEN))
	    {
	     if( (*thisedloc != EMScvint_rtend) && 
		 (*thisedloc != EMScvint_lfend))
	      skip = TRUE;
	    }
	   else if(*atloc != *thisedloc) skip = TRUE;
	  }
	 else
	  {
           if(checkuvpt && (EM2ddistptpt(checkuvpt, locuvpt) > *uvtol))
            skip = TRUE;

           if(checkxyzpt && (BSdistptpt(&rc, checkxyzpt, locxyzpt) > *xyztol))
            skip = TRUE;

	   if(atloc && (*atloc != *thisedloc)) skip = TRUE;
          }
        }

       if(thisedloc) om$dealloc(ptr = thisedloc);
       thisedloc = NULL;
      }

     if(!skip)
      {
       if(xyzvtx) (*xyzvtx)[num].objid = NULL_OBJID;
       sts = om$send(msg = message NMvertex_use.NMget_incedence_info(EMmsg, 
             refedge->objid, numedges ? &(*numedges)[num] : NULL, 
             edges ? &(*edges)[num] : NULL, 
             loc_on_edge ? &(*loc_on_edge)[num] : NULL, 
             xyzvtx ? &(*xyzvtx)[num] : NULL, 
             uvpt ? &(*uvpt)[2 * num] : NULL, 
             xyzpt ? &(*xyzpt)[3 * num] : NULL, NULL), 
             targetid = locvtxuse[i], targetos = refedge->osnum, 
             senderid = NULL_OBJID);
       if(!(1&*EMmsg&sts)) goto wrapup;
       if(vtxuse) (*vtxuse)[num] = locvtxuse[i];
       num++;
      }

    } /* for(i=0; i<locnumvtxuse; i++) */

   if(numvtxuse) *numvtxuse = num;
   locnumvtxuse = num;
  }


 create_vtxuse:
 /* If the options call for creation of a vertex use/vertex, if none found, 
    do so. Else exit.
 */
 if(!locnumvtxuse)
  {
   if(nmquery_opt & NMquery_CreateIfNotFound)
    {
     struct GRid surfid;
     unsigned char vtxuse_props = NMvtxuse_Active, vtx_props = NMvtx_Active;
     enum EMScvinttype *edlocptr = NULL, edloc;
     IGRdouble constuvpt[2], *uvptptr = NULL, constxyzpt[3], *xyzptptr = NULL;
     GRobjid locvtx = NULL_OBJID;
     GRspacenum constos;
     struct GRvg_construct  locconstruct;
     struct IGRdisplay	locdisp;
     struct GRmd_env	locenv;
     unsigned int	connect_opt = NULL;

     surfid.objid = NULL_OBJID;
     sts = om$send(msg = message EMSboundary.EMgetsurface_info
	   (EMmsg, &surfid.objid, NULL), targetid = refedge->objid, 
	   targetos = refedge->osnum, senderid = NULL_OBJID);
     if(!(1&*EMmsg&sts)) goto wrapup;
     EMerr_hndlr(IF_NULL_OBJID(surfid.objid), *EMmsg, EMS_E_Fail, wrapup);
     surfid.osnum = refedge->osnum;

     /* Generate default construct list if one is not supplied.
     */
     if(!construct)
      {
       locconstruct.geometry = NULL;
       locconstruct.display = &locdisp;
       locconstruct.class_attr = NULL;
       locconstruct.msg = EMmsg;
       locconstruct.env_info = &locenv;

       EMidmatrix(EMmsg, &locenv.md_env.matrix_type, locenv.md_env.matrix);
       locenv.md_id.osnum = surfid.osnum;
       locenv.md_id.objid = NULL_OBJID;

       sts = EFget_construction_info_from_id(EMmsg, &locconstruct, surfid.objid, 
 	     surfid.osnum);
       if(!(1&*EMmsg&sts)) goto wrapup;
       locconstruct.newflag = FALSE;
       construct = &locconstruct;
      }

     constos = construct->env_info->md_id.osnum;

     /* Determine the location of this vertex use on the reference edge.
     */
     if(atloc)
      {
       edloc = *atloc;
       edlocptr = &edloc;
       if(checkuvpt)
        {
	 OM_BLOCK_MOVE(checkuvpt, constuvpt, 2 * sizeof(IGRdouble));
	 uvptptr = constuvpt;
        }
       else if(edloc == EMScvint_rtend)
        {
	 sts = om$send(msg = message EMSedge.EMendpts(EMmsg, NULL, constuvpt, 
	       NULL, NULL, NULL), targetid = refedge->objid, 
	       targetos = refedge->osnum, senderid = NULL_OBJID);
	 if(!(1&*EMmsg&sts)) goto wrapup;
	 uvptptr = constuvpt;
        }
       else if(edloc == EMScvint_lfend)
        {
	 sts = om$send(msg = message EMSedge.EMendpts(EMmsg, constuvpt, NULL, 
	       NULL, NULL, NULL), targetid = refedge->objid, 
	       targetos = refedge->osnum, senderid = NULL_OBJID);
	 if(!(1&*EMmsg&sts)) goto wrapup;
	 uvptptr = constuvpt;
        }
      }

     if(checkuvpt)
      {
       if(!uvptptr)
        {
	 OM_BLOCK_MOVE(checkuvpt, constuvpt, 2 * sizeof(IGRdouble));
	 uvptptr = constuvpt;
        }

       if(!edlocptr)
        {
	 struct EMSproj_info projinfo;
         struct EMSpartolbasis partol;

         if(uvtol)
          {
	   partol.tol = *uvtol;
	   partol.is_valid = TRUE;
          }
         else
          {
	   partol.is_valid = FALSE;
	   partol.mattyp = &construct->env_info->md_env.matrix_type;
	   partol.mat = construct->env_info->md_env.matrix;
          }
	 sts = om$send(msg = message EMSedge.EMptproject(EMmsg, checkuvpt, 1, 
	       &projinfo, NULL, &partol), targetid = refedge->objid, 
	       targetos = refedge->osnum, senderid = NULL_OBJID);
	 if(!(1&*EMmsg&sts)) goto wrapup;
	 edloc = projinfo.location;
	 edlocptr = &edloc;
	 OM_BLOCK_MOVE(projinfo.proj_pt, constuvpt, 2 * sizeof(IGRdouble));
	 uvptptr = constuvpt;
        }
      }

     /* At this point we must have the uv point for the vertex use as well
        as its location on the edge. Failure to have both indicates lack
        of enough information for the function to create a vertex use.
     */
     EMerr_hndlr(!edlocptr || !uvptptr, *EMmsg, EMS_E_Fail, wrapup);

     /* Determine the xyz point for the vertex to be constructed.
     */
     if(checkxyzpt)
      {
       OM_BLOCK_MOVE(checkxyzpt, constxyzpt, sizeof(IGRpoint));
       xyzptptr = constxyzpt;
      }
     else
      {
       struct EMSsfintedpar junk;

       junk.edgeid = refedge->objid;
       OM_BLOCK_MOVE(uvptptr, junk.point, 2 * sizeof(IGRdouble));
       junk.intloc = *edlocptr;

       /* Evaluate the uv point on the surface.
       */
       sts = NMget_xyz_point(&junk, construct, surfid.objid, constxyzpt);
       if(!(1&sts)) goto wrapup;
       xyzptptr = constxyzpt;
      }

     /* Must have a xyz point.
     */
     EMerr_hndlr(!xyzptptr, *EMmsg, EMS_E_Fail, wrapup);

     if(nmquery_opt & NMquery_ConsiderExternalToModel)
      {
       vtxuse_props |= NMvtxuse_ExternalToModel;
       vtx_props |= NMvtx_ExternalToModel;
       connect_opt |= NMconnect_ExternalToModel;
      }

     if(ssi)
      connect_opt |= NMconnect_AddToSSI;

     /* Construct a vertex use.
     */
     sts = om$construct(osnum = constos, p_objid = locvtxuse, 
           classid = NMedgevtxuse_assoc ? OPP_NMvertex_use_class_id 
   	             : OPP_NMlistvtxuse_class_id, 
           msg = message NMvertex_use.NMinit 
                 (EMmsg, ssi ? NMinit_AddToSSI : NULL, vtxuse_props, 0, NULL, 
   	         NULL, NULL, ssi, &surfid));
     if(!(1&*EMmsg&sts)) goto wrapup;

     /* Connect the vertex use to the edge.
     */
     sts = om$send(msg = message NMvertex_use.NMconnect_edges(EMmsg, 1,
           &refedge->objid, edlocptr, uvptptr, connect_opt,
	   ssi), senderid = NULL_OBJID, targetid = locvtxuse[0], 
	   targetos = constos);
     if(!(1&sts)) goto wrapup;
	
     /* Construct a NMvertex.
     */
     sts = NMconstruct_vertex(EMmsg, construct, xyzptptr, &locvtx);
     if(!(1&sts)) goto wrapup;
     sts = om$send(msg = message NMvertex.NMinit
           (EMmsg, ssi ? NMinit_AddToSSI : NULL, vtx_props, 0, NULL, NULL, 
           ssi), senderid = NULL_OBJID, 
           targetid = locvtx, targetos = constos);
     if(!(1&*EMmsg&sts)) goto wrapup;

     /* Connect the vertex use to the vertex.
     */
     {
      struct GRid junk;

      junk.objid = locvtxuse[0];
      junk.osnum = constos;

      sts = om$send(msg = message NMvertex.NMconnect_vertex_uses(EMmsg, 
            1, &junk, xyzptptr, ssi, connect_opt), 
	   targetid = locvtx,
           senderid = NULL_OBJID, targetos = constos);
      if(!(1&*EMmsg&sts)) goto wrapup;
     }
    
    /* Rather than calling the function recursively, I could fill in all 
       the output information right here. But... Later.
    */
    if(numedges && *numedges) om$dealloc(ptr = *numedges);
    if(edges && *edges) om$dealloc(ptr = *edges);
    if(loc_on_edge && *loc_on_edge) om$dealloc(ptr = *loc_on_edge);
    if(xyzvtx && *xyzvtx) om$dealloc(ptr = *xyzvtx);
    if(uvpt && *uvpt) om$dealloc(ptr = *uvpt);
    if(xyzpt && *xyzpt) om$dealloc(ptr = *xyzpt);
    if(vtxuse && *vtxuse) om$dealloc(ptr = *vtxuse);

    if(numvtxuse) *numvtxuse = 0;
    if(numedges) *numedges = NULL;
    if(edges) *edges = NULL;
    if(loc_on_edge) *loc_on_edge = NULL;
    if(vtxuse) *vtxuse = NULL;
    if(xyzvtx) *xyzvtx = NULL;
    if(uvpt) *uvpt = NULL;
    if(xyzpt) *xyzpt = NULL;

    nmquery_opt &= (~NMquery_CreateIfNotFound);
    sts = NMget_vertex_use(EMmsg, refedge, numvtxuse, vtxuse, numedges, 
	  edges, loc_on_edge, xyzvtx, uvpt, xyzpt, checkuvpt, 
	  checkxyzpt, atloc, uvtol, xyztol, nmquery_opt, ssi, construct);
    if(!(1&*EMmsg&sts)) goto wrapup;

    } /* if(nmquery_opt & NMquery_CreateIfNotFound) */

   else
    {
     *EMmsg = EMS_I_Useless;
     goto wrapup;
    }
  }

wrapup:
if(deps) om$dealloc(ptr = deps);
if(locvtxuse && (locvtxuse != locvtxusebuf)) om$dealloc(ptr = locvtxuse);
EMWRAPUP(*EMmsg, sts, "NMget_vertex_use")
return(sts);
}


end implementation NMvertex_use;
