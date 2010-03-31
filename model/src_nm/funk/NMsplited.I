class implementation NMvertex;

#include "OMmacros.h"
#include "godef.h"
#include "bsparameters.h"
#include "bserr.h"
#include "emsmacros.h"
#include "EMSprop.h"
#include "EMSopt.h"
#include "EMSfrtdef.h"

#define VtxUseBuffInc	10
#define NmEdInc		10

from NMvertex_use import NMget_incedence_info, NMconnect_edges, NMinit, 
			 NMreplace_edge;
from EMSboundary import EMget_objid;
from EMSedge import EMsplityourself, EMptproject, EMget_props;
from EMSloop import EMmodify_edge, EMset_props, EMget_props;
from NMfeaturelp import NMflpinit;

extern IGRboolean NMedgevtxuse_assoc;
extern OMuword OPP_NMedflp_class_id;


IGRint NMsplit_edge(EMmsg, edgeid, splitinfo, vtxuse, partol, prted, sfid, 
 		    ssi)
IGRlong *EMmsg;
struct GRid *edgeid;
struct EMSsfintedpar *splitinfo;
GRobjid vtxuse;
struct EMSpartolbasis *partol;
struct GRid *prted;	/* Array for 2 partedges */
struct GRid *sfid;
struct NMgmSSI *ssi;
{
 IGRlong		sts = OM_S_SUCCESS, rc;
 GRobjid		loopid = NULL_OBJID, locprted[2];
 OM_S_CHANSELECT	to_ed, to_lp;
 IGRint			i, num_orig_vtxuse = 0, j;
 GRobjid		*orig_vtxuse = NULL;
 enum EMScvinttype	**orig_loc_on_edge = NULL;
 IGRushort	save_lpprops = NULL, orig_edprops = NULL;
 IGRboolean		isflp = FALSE;

 /* If the edge is owned by NMfeaturelp, we split the edge and replace it.
    If the edge is owned by any other type of loop, create a NMfeaturelp, 
    consisting of the resultant partedges so as to make it transparent.
 */
 
 *EMmsg = EMS_S_Success;
 EMmake_chanselect(EMSbd_owner_to_comps, &to_ed);
 EMmake_chanselect(EMSedge_to_owner, &to_lp);

 sts = EMsend_loops(&rc, message EMSboundary.EMget_objid(EMmsg, &loopid), 
	edgeid->objid, 0, MAXINT, EMLP_ACTIVE, NULL, NULL);
 if(!(1&*EMmsg&sts)) goto wrapup;
 EMerr_hndlr(IF_NULL_OBJID(loopid), *EMmsg, EMS_E_Fail, wrapup);

 isflp = EFisAncestryValid(EMmsg, loopid, edgeid->osnum, 
         OPP_NMfeaturelp_class_id, FALSE);

 if(!isflp)
  {
   sts = om$send(msg = message EMSloop.EMget_props(EMmsg, &save_lpprops), 
         targetid = loopid, senderid = NULL_OBJID);
   if(!(1&*EMmsg&sts)) goto wrapup;
  }

 /* Get the vertex uses connected to the original edge.
 */
 sts = NMget_vertex_use(EMmsg, edgeid, &num_orig_vtxuse, &orig_vtxuse, NULL, 
       NULL, &orig_loc_on_edge, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
       NULL, NULL, NULL);
 if(!(1&*EMmsg&sts)) goto wrapup;

 /* Split the edge.
 */
 sts = om$send(msg = message EMSedge.EMsplityourself(EMmsg, &splitinfo, 
       NULL, NULL, locprted, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL), 
       targetid = edgeid->objid, targetos = edgeid->osnum, 
       senderid =NULL_OBJID);
 if(!(1&*EMmsg&sts)) goto wrapup;

 /* Change class of both the partedges from EMSpartedge to NMpartedge to
    make them transparent to unsuspecting operations.
    Any vertex use at the begining of the original edge needs to be transfered
    to the begining of locprted[0] and that at the end of the original edge
    to the end of locprted[1]. This fact has to be stored in the SSI for
    unevaluation.
 */
 for(i=0; i<2; i++)   
  {
   sts = om$change_class(objid = locprted[i], osnum = edgeid->osnum, 
         classname = "NMpartedge", 
         sd_override = OM_K_change_class_sd_override);
   if(!(1&sts)) goto wrapup;
  }

 if(prted)
  for(i=0; i<2; i++)
   {
    prted[i].objid = locprted[i];
    prted[i].osnum = edgeid->osnum;
   }

 if(isflp)
  {
   /* Store the edge out - edge in information.
   */
   sts = NMstore_edge_change(EMmsg, ssi, sfid, edgeid->objid, 2, locprted);
   if(!(1&*EMmsg&sts)) goto wrapup;
  }
 else
  {
   GRobjid flpid, nesting_parent;

   /* EMSedge.EMsplityourself has replaced the edge with the partedges in 
      all the loops. Undo that by replacing locprted[0] with the original
      edge (to maintain the index) and disconnecting locprted[1]. Put back
      the saved properties of the loop.
   */
   sts = om$send(msg = message EMSloop.EMmodify_edge(EMmsg, 
	 EMS_INS_REPLACE, 1, locprted[0], &edgeid->objid, FALSE), 
         targetid = loopid, senderid = NULL_OBJID);
   if(!(1&*EMmsg&sts)) goto wrapup;
   sts = om$send(msg = message Root.disconnect(to_ed, locprted[1], 
         edgeid->osnum, to_lp), targetid = loopid, senderid = NULL_OBJID);
   if(!(1&*EMmsg&sts)) goto wrapup;

   sts = om$send(msg = message EMSloop.EMset_props(EMmsg, NULL, EMS_O_SET), 
         targetid = loopid, senderid = NULL_OBJID);
   if(!(1&*EMmsg&sts)) goto wrapup;
   sts = om$send(msg = message EMSloop.EMset_props(EMmsg, save_lpprops, 
         EMS_O_SET), targetid = loopid, senderid = NULL_OBJID);
   if(!(1&*EMmsg&sts)) goto wrapup;

   /* Create a NMedflp which owns both the NMpartedges (for display, 
      locate, keypoint etc.). Store the edgeid belonging to the 
      region loop in the NMedflp, for future use.
   */
   sts = om$construct(osnum = edgeid->osnum, 
	 classid = OPP_NMedflp_class_id, p_objid = &flpid);
   if(!(1&sts)) goto wrapup;
   sts = om$send(msg = message EMSloop.EMmodify_edge(EMmsg, 
         EMS_INS_ATEND, 2, NULL_OBJID, locprted, FALSE), targetid = flpid, 
         targetos = edgeid->osnum, senderid = NULL_OBJID);
   if(!(1&*EMmsg&sts)) goto wrapup;

   nesting_parent = edgeid->objid;
   sts = om$send(msg = message NMfeaturelp.NMflpinit(EMmsg, partol,
	 NULL, EMLP_ACTIVE, EMGL_HOLD_UPDATE, sfid->objid, 
	 nesting_parent, NMinit_AddToSSI, ssi), targetid = flpid, 
	 targetos = edgeid->osnum, 
	 senderid = NULL_OBJID);
   if(!(1&*EMmsg&sts)) goto wrapup;

   /* Store the edges created.
   */
   sts = NMstore_edges_created(EMmsg, ssi, sfid, 2, locprted);
   if(!(1&*EMmsg&sts)) goto wrapup;
  }


 /* Transfer all the vertex uses connected to the original edge to the
    new edge.
 */
 if(num_orig_vtxuse)
  {
   sts = om$send(msg = message EMSedge.EMget_props(EMmsg, &orig_edprops), 
	 targetid = edgeid->objid, targetos = edgeid->osnum, 
	 senderid = NULL_OBJID);
   if(!(1&*EMmsg&sts)) goto wrapup;
  }

 for(j=0; j<num_orig_vtxuse; j++)
  {
   /* Handle the case of the begin/end vertex use of a closed original
      edge specially.
   */
   if( ((orig_loc_on_edge[j][0] == EMScvint_rtend) ||
       (orig_loc_on_edge[j][0] == EMScvint_lfend)) &&
       (!(orig_edprops & EMED_OPEN)))
    {
     enum EMScvinttype edloc[2];

     edloc[0] = EMScvint_lfend;
     edloc[1] = EMScvint_rtend;
     sts = om$send(msg = message NMvertex_use.NMreplace_edge(EMmsg, 
            edgeid->objid, 2, locprted, edloc, NMconnect_AddToSSI, ssi), 
            targetid = orig_vtxuse[j], senderid = NULL_OBJID);
     if(!(1&*EMmsg&sts)) goto wrapup;
    }
   else if(orig_loc_on_edge[j][0] == EMScvint_rtend)
    {
     sts = om$send(msg = message NMvertex_use.NMreplace_edge(EMmsg, 
           edgeid->objid, 1, &locprted[1], &orig_loc_on_edge[j][0], 
           NMconnect_AddToSSI, ssi), 
           targetid = orig_vtxuse[j], senderid = NULL_OBJID);
     if(!(1&*EMmsg&sts)) goto wrapup;
    }
   else if(orig_loc_on_edge[j][0] == EMScvint_lfend)
    {
     sts = om$send(msg = message NMvertex_use.NMreplace_edge(EMmsg, 
           edgeid->objid, 1, &locprted[0], &orig_loc_on_edge[j][0], 
           NMconnect_AddToSSI, ssi), 
           targetid = orig_vtxuse[j], senderid = NULL_OBJID);
     if(!(1&*EMmsg&sts)) goto wrapup;
    }
   else if(IF_EQ_OBJID(orig_vtxuse[j], vtxuse))
    {
     enum EMScvinttype edloc[2];

     edloc[0] = EMScvint_rtend;
     edloc[1] = EMScvint_lfend;
     sts = om$send(msg = message NMvertex_use.NMreplace_edge(EMmsg, 
            edgeid->objid, 2, locprted, edloc, NMconnect_AddToSSI, ssi), 
            targetid = orig_vtxuse[j], senderid = NULL_OBJID);
     if(!(1&*EMmsg&sts)) goto wrapup;
    }
   else if(orig_loc_on_edge[j][0] == EMScvint_middle)
     {
      struct EMSsfintedpar inedpar, outedpar;
      struct EMSproj_info projinfo;

      inedpar.edgeid = edgeid->objid;
      inedpar.intloc = EMScvint_middle;

      sts = om$send(msg = message NMvertex_use.NMget_incedence_info(EMmsg, 
            NULL_OBJID, NULL, NULL, NULL, NULL, inedpar.point, NULL, NULL), 
            targetid = orig_vtxuse[j], senderid = NULL_OBJID);
      if(!(1&*EMmsg&sts)) goto wrapup;

      sts = om$send(msg = message EMSedge.EMptproject(EMmsg, inedpar.point, 
            1, &projinfo, NULL, partol), senderid = NULL_OBJID, 
            targetid = edgeid->objid);
      if(!(1&*EMmsg&sts)) goto wrapup;
      inedpar.edgepar = projinfo.param;

      outedpar.edgeid = NULL_OBJID;
      sts = NMincedence(EMmsg, &inedpar, sfid, partol, &outedpar);
      if(!(1&*EMmsg&sts)) goto wrapup;
   
      if( (*EMmsg == EMS_I_NotFound) || (IF_NULL_OBJID(outedpar.edgeid)))
       continue;
         
      sts = om$send(msg = message NMvertex_use.NMreplace_edge(EMmsg, 
            edgeid->objid, 1, &outedpar.edgeid, &outedpar.intloc, 
            NMconnect_AddToSSI, ssi), 
            targetid = orig_vtxuse[j], senderid = NULL_OBJID);
      if(!(1&*EMmsg&sts)) goto wrapup;
     }

  } /* for(j=0; j<num_orig_vtxuse; j++) */

wrapup:
if(orig_loc_on_edge) om$dealloc(ptr = orig_loc_on_edge);
if(orig_vtxuse) om$dealloc(ptr = orig_vtxuse);

EMWRAPUP(*EMmsg, sts, "NMsplit_edge");
return(sts);
}

end implementation NMvertex;
