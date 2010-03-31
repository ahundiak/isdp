/*
Given an EMSedge/NMpartedge, this function will obtain the top
NMpartedges if any and then for the top edges it will -

 1) Create NMvertices at either/both ends based on the options, if none exists.
 2) Create NMedge based on the options, if none exists.
 3) Look for NMnonmanitp object (create one if not found) and append the
    ssi information to it, based on the options.

All the required output will be returned via the ssi structure. For example, 
if an EMSedge is input and there were multiple NMpartedges on top of it, the
ssi structure will contain multiple NMedges (one for each NMpartedge) upon
output.

THIS FUNCTION WILL NOT DO ANYTHING ABOUT EMSloop.

The argument 'ssi' is strictly for output purpose, and does not necessarily
reflect the created entities. For example when looking for an NMedge,
the output will contain a NMedge id in the 'ssi' structure, but that NMedge
may be already existing or may have been created by the function.

Recording of the created entities into proper instance data will be done
by the function.

The optional argument 'created_ssi' will contain only those entities which
got created in this call to the function.
*/
class implementation NMnonmanitp;

#include "nddef.h"
#include "OMmacros.h"

from EMSboundary import EMgetsurface_info;
from EMSedge import EMget_top_part_edges;

extern IGRboolean NMedgevtxuse_assoc;
extern OM_S_OBJID current_creator;

IGRint NMassociative_preprocess(EMmsg, refobj, refobj_env, nmassocpre_opt, 
				nmquery_opt, ssi, created_ssi, nmtpid, construct)
IGRlong *EMmsg;
struct GRid *refobj;
struct GRmd_env *refobj_env;
unsigned int nmassocpre_opt, nmquery_opt;
struct NMgmSSI *ssi, *created_ssi;
struct GRid *nmtpid;
struct GRvg_construct *construct;
{
 IGRlong		sts = OM_S_SUCCESS, rc;
 struct GRid    	surfid, nmedge, locnmtpid;
 IGRboolean		free_ed = FALSE;
 GRobjid		*toped = NULL, topedbuf, *vtxuse = NULL;
 IGRint			num_toped = 0, topedbufsize = 0, i;
 struct NMentities	*thisnm;
 IGRint 		numvtxuse = 0;
 enum EMScvinttype 	edloc;
 struct GRid 		refedge, *xyzvtx = NULL;
 struct NMgmSSI		locssi;
 IGRboolean		save_global;
 struct GRvg_construct  locconstruct;
 struct IGRdisplay	locdisp;
 struct GRmd_env	locenv;

 *EMmsg = EMS_S_Success;
 NMinit_ssi(&locssi);


 save_global = NMedgevtxuse_assoc;
 if(nmquery_opt & NMquery_ConsiderExternalToModel)
  NMedgevtxuse_assoc = TRUE;
 else
  NMedgevtxuse_assoc = FALSE;
    
 locnmtpid.objid = NULL_OBJID;

 EMerr_hndlr(!ssi, *EMmsg, EMS_E_InvalidArg, wrapup);

 if(!EFisAncestryValid(EMmsg, refobj->objid, refobj->osnum, 
	  OPP_EMSedge_class_id, TRUE))
  {
   *EMmsg = EMS_E_InvalidArg;
   goto wrapup;
  }

 surfid.objid = NULL_OBJID;

 sts = om$send(msg = message EMSboundary.EMgetsurface_info(EMmsg, 
       &surfid.objid, NULL), targetid = refobj->objid, 
       targetos = refobj->osnum, senderid = NULL_OBJID);
 if(!(1&*EMmsg&sts)) goto wrapup;
 EMerr_hndlr(IF_NULL_OBJID(surfid.objid), *EMmsg, EMS_E_Fail, wrapup);
 surfid.osnum = refobj->osnum;

 /* Generate default env info if not supplied.
 */
 if(!refobj_env)   
  {
   EMidmatrix(EMmsg, &locenv.md_env.matrix_type, locenv.md_env.matrix);
   locenv.md_id.osnum = surfid.osnum;
   locenv.md_id.objid = NULL_OBJID;
   refobj_env = &locenv;
  }

 /* Generate default construct list if one is not supplied.
 */
 if(!construct)
  {
   locconstruct.geometry = NULL;
   locconstruct.display = &locdisp;
   locconstruct.class_attr = NULL;
   locconstruct.msg = EMmsg;
   locconstruct.env_info = refobj_env;
   sts = EFget_construction_info_from_id(EMmsg, &locconstruct, surfid.objid, 
	 surfid.osnum);
   if(!(1&*EMmsg&sts)) goto wrapup;
   locconstruct.newflag = FALSE;
   construct = &locconstruct;
  }

/* BYRON 12/11/91
 * construct nmtp before edges or vertices are constructed
 * and set current_creator to the nmtp
*/
 if(nmtpid || (!(nmassocpre_opt & NMassocpre_NoSaveState)))
  {
   sts = NMcreate_nmtp(EMmsg, &surfid, refobj_env, &locnmtpid, NULL, NULL, 
         construct);
   if(!(1&*EMmsg&sts)) goto wrapup;
   EMerr_hndlr(IF_NULL_OBJID(locnmtpid.objid), *EMmsg, EMS_E_Fail, wrapup);
   if(nmtpid) *nmtpid = locnmtpid;
  }

  current_creator = locnmtpid.objid;
/*BYRON*/


 sts = NMsetUpSSI(EMmsg, &surfid, ssi, &thisnm);
 if(!(1&*EMmsg&sts)) goto wrapup;
 EMerr_hndlr(!thisnm, *EMmsg, EMS_E_Fail, wrapup);

 /* Get the top NMpartedges if they exist.
 */
 if(nmassocpre_opt & NMassocpre_NoTopEdges)
  {
   num_toped = 1;
   toped = &topedbuf;
   topedbuf = refobj->objid;
  }
 else
  {
   sts = NMsend_to_partedges(&rc, message EMSedge.EMget_top_part_edges
         (&rc, &toped, &num_toped, &topedbufsize), refobj->objid, 
         refobj->osnum, 0, MAXINT, NULL, NULL, NULL);
   EMerr_hndlr (!(1&sts&rc),*EMmsg,EMS_E_EdgeError,wrapup);
   if(!num_toped)
    {
     num_toped = 1;
     toped = &topedbuf;
     topedbuf = refobj->objid;
    }
   else free_ed = TRUE;
  }

 refedge.osnum = refobj->osnum;
 for(i=0; i<num_toped; i++)
  {
   refedge.objid = toped[i];

   if(vtxuse) om$dealloc(ptr = vtxuse);
   if(xyzvtx) om$dealloc(ptr = xyzvtx);
   vtxuse = NULL;
   xyzvtx = NULL;
   numvtxuse = 0;

   /* Call appropriate function to look for the NMtopology objects. If an
      object gets constructed in the query function it will be recorded in
      the structure 'locssi'. The input structure 'ssi' is simply for
      output.
   */

   /* Need vertex at the begining?
   */
   if(nmassocpre_opt & NMassocpre_StartVtx)
    {
     edloc = EMScvint_lfend;
						
     sts = NMget_vertex_use(EMmsg, &refedge, &numvtxuse, &vtxuse, NULL, NULL, 
	   NULL, &xyzvtx, NULL, NULL, NULL, NULL, &edloc, NULL, NULL, 
	   nmquery_opt | NMquery_CreateIfNotFound, &locssi, construct);
     if(!(1&*EMmsg&sts)) goto wrapup;
     EMerr_hndlr(numvtxuse != 1, *EMmsg, EMS_E_Fail, wrapup);

     sts = NMsetUpSSI(EMmsg, &surfid, ssi, &thisnm);
     if(!(1&*EMmsg&sts)) goto wrapup;
     ssi->vtx[ssi->num_vtx++] = xyzvtx[0].objid;
     ssi->vtxbufsize--;
    }

   if(vtxuse) om$dealloc(ptr = vtxuse);
   if(xyzvtx) om$dealloc(ptr = xyzvtx);
   vtxuse = NULL;
   xyzvtx = NULL;
   numvtxuse = 0;

   /* Need vertex at the end?
   */
   if(nmassocpre_opt & NMassocpre_StopVtx)
    {
     edloc = EMScvint_rtend;
						
     sts = NMget_vertex_use(EMmsg, &refedge, &numvtxuse, &vtxuse, NULL, NULL, 
	   NULL, &xyzvtx, NULL, NULL, NULL, NULL, &edloc, NULL, NULL, 
	   nmquery_opt | NMquery_CreateIfNotFound, &locssi, construct);
     if(!(1&*EMmsg&sts)) goto wrapup;
     EMerr_hndlr(numvtxuse != 1, *EMmsg, EMS_E_Fail, wrapup);

     sts = NMsetUpSSI(EMmsg, &surfid, ssi, &thisnm);
     if(!(1&*EMmsg&sts)) goto wrapup;
     ssi->vtx[ssi->num_vtx++] = xyzvtx[0].objid;
     ssi->vtxbufsize--;
    }

   /* Need a NMedge ?
   */
   if(nmassocpre_opt & NMassocpre_NMedge)
    {
     nmedge.objid = NULL_OBJID;

     sts = NMget_edge_mates(EMmsg, &refedge, NULL, NULL, NULL, NULL, NULL, 
	   &nmedge, nmquery_opt | NMquery_CreateIfNotFound, &locssi, construct);
     if(!(1&*EMmsg&sts)) goto wrapup;
     EMerr_hndlr(IF_NULL_OBJID(nmedge.objid), *EMmsg, EMS_E_Fail, wrapup);
     sts = NMsetUpSSI(EMmsg, &surfid, ssi, &thisnm);
     if(!(1&*EMmsg&sts)) goto wrapup;
     ssi->nmedges[ssi->num_nmedges++] = nmedge.objid;
     ssi->nmedgesbufsize--;
    }

  } /* for(i=0; i<num_toped; i++) */

/*BYRON
 if(nmtpid || (!(nmassocpre_opt & NMassocpre_NoSaveState)))
  {
   sts = NMcreate_nmtp(EMmsg, &surfid, refobj_env, &locnmtpid, NULL, NULL, 
         construct);
   if(!(1&*EMmsg&sts)) goto wrapup;
   EMerr_hndlr(IF_NULL_OBJID(locnmtpid.objid), *EMmsg, EMS_E_Fail, wrapup);
   if(nmtpid) *nmtpid = locnmtpid;
  }
*/

 /* If no recording needs to be done about the created entities, we are all
    done, otherwise obtain a NMnonmanitp node and append the information
    to it.
 */
 if(nmassocpre_opt & NMassocpre_NoSaveState) goto wrapup;

 /* Post data if something got created.
 */
 if(locssi.num_vtx || locssi.num_nmedges)
  {
   sts = om$send(msg = message NMnonmanigm.NMappend_SSI(EMmsg, &locssi, NULL), 
         targetid = locnmtpid.objid, targetos = locnmtpid.osnum, 
         senderid = NULL_OBJID);
   if(!(1&*EMmsg&sts)) goto wrapup;
  }

wrapup:

/*BYRON*/
current_creator = NULL_OBJID;


NMedgevtxuse_assoc = save_global;
if( (1&*EMmsg&sts) && created_ssi)
 *created_ssi = locssi;
else NMfree_ssi(&locssi);

if(free_ed) om$dealloc(ptr = toped);
if(vtxuse) om$dealloc(ptr = vtxuse);
if(xyzvtx) om$dealloc(ptr = xyzvtx);
EMWRAPUP(*EMmsg, sts, "NMassociative_preprocess");
return(sts);
}
end implementation NMnonmanitp;

