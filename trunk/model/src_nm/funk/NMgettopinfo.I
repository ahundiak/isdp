/*
Non manifold interface for EMget_loops messages for loopset/surface/solid. 
The output from this function is a super set of the output received by sending
the message to either of these elements.
*/
class implementation NMnonmani;

#include "OMmacros.h"
#include "EMSopt.h"

extern OMuword OPP_GRowner_class_id, OPP_NMedflp_class_id, 
	       OPP_NMnonmanigm_class_id;

from NMfeaturelp import NMget_nesting_parent;
from EMSsubbs import EMpassloop;
from EMSboundary import EMget_edges, EMgetsurface_info;
from EMSloopset import EMget_loops;
from EMSloop import EMget_loops;
from NMnonmanigm import NMget_number_components, NMget_components;

#define StaticBuf 10
#define PloopInc 4
#define CloopInc 8
#define EdInc	10
void		NMedgesOut();

IGRint NMget_faces_edges(EMmsg, refid, num_comps, compids, compidslistsize, 
		       num_faces_per_comp, faceids, faceidslistsize, 
		       num_comps_per_face, face_compids, face_compidslistsize, 
		       num_edges_per_face, edges, edgeslistsize, edopt, 
		       nmquery_opt)
IGRlong		*EMmsg;
struct GRid	*refid;
IGRint		*num_comps, *compidslistsize;
struct GRid	**compids;
IGRint		**num_faces_per_comp, *faceidslistsize;
struct GRid	**faceids;
IGRint		**num_comps_per_face, *face_compidslistsize;
struct GRid	**face_compids;
IGRint		**num_edges_per_face, *edgeslistsize;
struct GRid	**edges;
IGRlong		edopt;
unsigned int nmquery_opt;
{
 IGRlong		sts = OM_S_SUCCESS;
 IGRint			loc_num_comps = 0, count = 0, j, i, m, depth, 
			total_edges = 0;
 struct GRid		*loc_comps = NULL, loc_compsbuf[StaticBuf], 
			*flps = NULL, *edflps = NULL, junkGRid;
 struct GRmd_env	env;
 GRobjid		*loc_plps = NULL, *loc_clps = NULL, 
			*loc_flps_parents = NULL;
 IGRint			loc_numplps = 0, loc_plpslistsize = 0, tmpbufsize = 0, 
			loc_numclps = 0, loc_clpslistsize = 0,
			total_plps = 0, total_clps = 0, num_flps = 0, 
			loc_flps_parents_listsize = 0, num_edflps = 0;
 struct GRid		*loc_edges = NULL;
 IGRint			loc_numedges = 0, loc_edgeslistsize = 0;
 OMuword		no_list = OPP_NMedflp_class_id, 
			exact_clsid = OPP_NMedflp_class_id;


 *EMmsg = EMS_S_Success;
 EMidmatrix(EMmsg, &env.md_env.matrix_type, env.md_env.matrix);
 env.md_id.objid = NULL_OBJID;
 env.md_id.osnum = refid->osnum;

 /* If the refid is a composite, break it down into its leaf components.
 */
 if(EFisAncestryValid(EMmsg, refid->objid, refid->osnum, 
    OPP_GRowner_class_id, FALSE)) 
  {
   if(EFisAncestryValid(EMmsg, refid->objid, refid->osnum, 
      OPP_NMnonmanigm_class_id, FALSE)) 
    sts = om$send(msg = message NMnonmanigm.NMget_number_components(EMmsg, 
	  &count), targetid = refid->objid, targetos = refid->osnum, 
	 senderid =NULL_OBJID);
   else
    sts = om$send(msg = message GRowner.GRget_number_components(EMmsg, &count),
	 targetid = refid->objid, targetos = refid->osnum, 
	 senderid =NULL_OBJID);
	
   if(!(1&*EMmsg&sts)) goto wrapup;

   EMerr_hndlr(!count, *EMmsg, EMS_E_Fail, wrapup);
   if(count > StaticBuf)  
    loc_comps = (struct GRid *) om$malloc(size = count * sizeof(struct GRid));
   else loc_comps = loc_compsbuf;
   EMerr_hndlr(!loc_comps, *EMmsg, EMS_E_NoDynamicMemory, wrapup);

   if(EFisAncestryValid(EMmsg, refid->objid, refid->osnum, 
      OPP_NMnonmanigm_class_id, FALSE)) 
    sts = om$send(msg = message NMnonmanigm.NMget_components(EMmsg, &env,
	  loc_comps, count, &loc_num_comps, 0, MAXINT), 
	  targetid = refid->objid, targetos = refid->osnum, 
	  senderid = NULL_OBJID);
   else
    sts = om$send(msg = message GRowner.GRget_components(EMmsg, &env,loc_comps,
	  count, &loc_num_comps, 0, MAXINT), targetid = refid->objid, 
	  targetos = refid->osnum, senderid = NULL_OBJID);
	
   if(!(1&*EMmsg&sts)) goto wrapup;
  }
 else
  {
   loc_num_comps = 1;
   loc_comps = loc_compsbuf;
   loc_comps[0] = *refid;
  }

 /* Return component info if requested.
 */
 if(compidslistsize && (*compidslistsize < loc_num_comps))
  {
   if(compids)
    {
     if(*compids)
      *compids = (struct GRid *) om$realloc(ptr = (IGRchar *) *compids, size = 
                 loc_num_comps * sizeof(struct GRid));
     else 
      *compids = (struct GRid *) om$malloc(size = loc_num_comps *
	         sizeof(struct GRid));
     EMerr_hndlr(!*compids, *EMmsg, EMS_E_NoDynamicMemory, wrapup);
    }

   if(num_faces_per_comp)
    {
     if(*num_faces_per_comp)
      *num_faces_per_comp = (IGRint *) om$realloc(ptr = (IGRchar *) *num_faces_per_comp, 
			    size = loc_num_comps * sizeof(IGRint));
     else
      *num_faces_per_comp = (IGRint *) om$malloc(
			    size = loc_num_comps * sizeof(IGRint));
     EMerr_hndlr(!*num_faces_per_comp, *EMmsg, EMS_E_NoDynamicMemory, wrapup);
    }
   *compidslistsize = loc_num_comps;
  }


 if(compids)
   OM_BLOCK_MOVE(loc_comps, *compids, loc_num_comps * sizeof(struct GRid));
 if(num_comps) *num_comps = loc_num_comps;


 /* Start obtaining the information from each component.
   
    o Get all P-loops
      For each P-loop
       Get all nested C loops
    o Get all NM Featureloops
      For each feature loop
       add it as a nested child under the appropriate P-loop
    
    The above generates a list of faces for this component.
    
    o For each face
      Get the edges from each loop in the face (including the P-loop)
      If any NMedflps exist, replace the relevant EMS edges by those from
      the NMedflp.
 */
 loc_plps = (GRobjid *) om$malloc(size = PloopInc * sizeof(GRobjid));
 loc_clps = (GRobjid *) om$malloc(size = CloopInc * sizeof(GRobjid));
 loc_flps_parents = (GRobjid *) om$malloc(size = CloopInc * sizeof(GRobjid));
 EMerr_hndlr(!loc_plps || !loc_clps || !loc_flps_parents, *EMmsg, 
	     EMS_E_NoDynamicMemory, wrapup);
 loc_plpslistsize = PloopInc;
 loc_clpslistsize = CloopInc;
 loc_flps_parents_listsize = CloopInc;

 loc_edges = (struct GRid *) om$malloc(size = EdInc * sizeof(struct GRid));
 EMerr_hndlr(!loc_edges, *EMmsg, EMS_E_NoDynamicMemory, wrapup);
 loc_edgeslistsize = EdInc;

 for(i=0; i<loc_num_comps; i++)
  {
   IGRlong rc;

   tmpbufsize = loc_plpslistsize;
   loc_numplps = 0;
   depth = MAXINT;
   sts = om$send(msg = message EMSsubbs.EMpassloop(&rc, message 
         EMSloopset.EMget_loops(EMmsg, EMS_OPT_PLOOP, &depth,
	 &loc_plps, NULL, &tmpbufsize, &loc_numplps)), 
	 targetid = loc_comps[i].objid, targetos = loc_comps[i].osnum, 
	 senderid = NULL_OBJID);
   if(!(1&rc)) *EMmsg = EMS_E_Fail;
   if(!(1&*EMmsg&sts)) goto wrapup;
   loc_plpslistsize = tmpbufsize + loc_numplps; /* for next call */

   if(flps) om$dealloc(ptr = flps);
   flps = NULL;
   num_flps = 0;
   if(edflps) om$dealloc(ptr = edflps);
   edflps = NULL;
   num_edflps = 0;

   /* Get all the NMedflp loops and other NM feature loops seperately.
   */
   sts = NMget_feature_loops(EMmsg, &loc_comps[i], &num_flps, &flps, NULL, 
	 NULL, &no_list, 1, nmquery_opt);
   if(!(1&*EMmsg&sts)) goto wrapup;
   sts = NMget_feature_loops(EMmsg, &loc_comps[i], &num_edflps, &edflps, 
	 &exact_clsid, 1, NULL, NULL, nmquery_opt);
   if(!(1&*EMmsg&sts)) goto wrapup;

   if(loc_flps_parents_listsize < num_flps)
    {
     loc_flps_parents = (GRobjid *) om$realloc(ptr = (IGRchar *) loc_flps_parents, 
	 size = (loc_flps_parents_listsize + num_flps) * sizeof(GRobjid));
     EMerr_hndlr(!loc_flps_parents, *EMmsg, EMS_E_NoDynamicMemory, wrapup);
     loc_flps_parents_listsize += num_flps;
    }

   for(j=0; j<num_flps; j++)
    {
     sts = om$send(msg = message NMfeaturelp.NMget_nesting_parent(EMmsg, 
	   &loc_flps_parents[j], TRUE), targetid = flps[j].objid, 
	   targetos = flps[j].osnum, senderid = NULL_OBJID);
     if(!(1&*EMmsg&sts)) goto wrapup;
    }

   /* If face ids are requested return them.
   */
   if(num_faces_per_comp) (*num_faces_per_comp)[i] = loc_numplps;

   if(faceidslistsize && (*faceidslistsize < (loc_numplps+total_plps)))
    {
     if(faceids)
      {
       if(*faceids)
        *faceids = (struct GRid *) om$realloc(ptr = (IGRchar *) *faceids, size = 
		    (total_plps + loc_numplps + PloopInc)*sizeof(struct GRid));
       else
        *faceids = (struct GRid *) om$malloc(size = 
		    (total_plps + loc_numplps + PloopInc)*sizeof(struct GRid));
       EMerr_hndlr(!*faceids, *EMmsg, EMS_E_NoDynamicMemory, wrapup);
      }

     if(num_comps_per_face)
      {
       if(*num_comps_per_face)
        *num_comps_per_face = (IGRint *) om$realloc(ptr = (IGRchar *) *num_comps_per_face, 
	      size = (total_plps + loc_numplps + PloopInc) * sizeof(IGRint));
       else
        *num_comps_per_face = (IGRint *) om$malloc(
	      size = (total_plps + loc_numplps + PloopInc) * sizeof(IGRint));
       EMerr_hndlr(!*num_comps_per_face,*EMmsg, EMS_E_NoDynamicMemory, wrapup);
      }

     if(num_edges_per_face)
      {
       if(*num_edges_per_face)
        *num_edges_per_face = (IGRint *) om$realloc(ptr = (IGRchar *) *num_edges_per_face, 
	      size = (total_plps + loc_numplps + PloopInc) * sizeof(IGRint));
       else
        *num_edges_per_face = (IGRint *) om$malloc(
	      size = (total_plps + loc_numplps + PloopInc) * sizeof(IGRint));
       EMerr_hndlr(!*num_edges_per_face,*EMmsg, EMS_E_NoDynamicMemory, wrapup);
      }
     *faceidslistsize = total_plps + loc_numplps + PloopInc;
    }


   /* Create a list of C loops and NMfeature loops nested under each P loop
   */
   for(j=0; j<loc_numplps; j++)
    {
     IGRint num_flps_thisplp = 0;

     if(faceids)
      {
       (*faceids)[total_plps].objid = loc_plps[j];
       (*faceids)[total_plps].osnum = refid->osnum;
      }
     tmpbufsize = loc_clpslistsize;
     loc_numclps = 0;
     depth = 2;
     sts = om$send(msg = message EMSloop.EMget_loops(EMmsg, EMS_OPT_CLOOP, 
	 &depth, &loc_clps, NULL, &tmpbufsize, &loc_numclps), 
	 targetid = loc_plps[j], targetos = refid->osnum, 
	 senderid = NULL_OBJID);
     if(!(1&*EMmsg&sts)) goto wrapup;
     loc_clpslistsize = tmpbufsize + loc_numclps; /* for next call */


     for(m=0; m<num_flps; m++)
      if(IF_EQ_OBJID(loc_flps_parents[m], loc_plps[j])) 
       num_flps_thisplp++;

     if(num_comps_per_face)
      (*num_comps_per_face)[total_plps] = loc_numclps + num_flps_thisplp;

     if(face_compidslistsize && 
	 (*face_compidslistsize < (loc_numclps + num_flps_thisplp + total_clps)))
      {
       if(face_compids)
        {
         if(*face_compids)
          *face_compids = (struct GRid *) om$realloc(ptr = (IGRchar *) *face_compids, 
			  size = (total_clps + loc_numclps + CloopInc + 
			  num_flps_thisplp) * sizeof(struct GRid));
         else
          *face_compids = (struct GRid *) om$malloc(size = 
		    (total_clps + loc_numclps + CloopInc + num_flps_thisplp) * 
		    sizeof(struct GRid));
         EMerr_hndlr(!*face_compids, *EMmsg, EMS_E_NoDynamicMemory, wrapup);
        }
       *face_compidslistsize = total_clps + loc_numclps + CloopInc +
			       num_flps_thisplp;
      }

     if(face_compids)
      {
       for(m=0; m<loc_numclps; m++)
	{
	 (*face_compids)[total_clps].objid = loc_clps[m];
	 (*face_compids)[total_clps++].osnum = refid->osnum;
	}
       for(m=0; m<num_flps; m++)
        if(IF_EQ_OBJID(loc_flps_parents[m], loc_plps[j]))
         (*face_compids)[total_clps++] = flps[m];
      }      

     /* If edges are requested, get them for this face set (this p-loop and
	its nested c-loops and NM feature loops).
     */
     if(!(edges && num_edges_per_face)) goto next_plp;


     /* Get the edges from the p-loop.
     */
     loc_numedges = 0;
     junkGRid.objid = loc_plps[j];
     junkGRid.osnum = refid->osnum;
     sts = NMget_edges_from_loop(EMmsg, &junkGRid, &loc_numedges, &loc_edges, 
	   &loc_edgeslistsize, num_edflps, edflps, edopt, 1, nmquery_opt);
     if(!(1&*EMmsg&sts)) goto wrapup;

     NMedgesOut(EMmsg, edgeslistsize, edges, loc_numedges, loc_edges, 
		&total_edges);
     if(!(1&*EMmsg)) goto wrapup;

     if(num_edges_per_face)
      (*num_edges_per_face)[j] = loc_numedges;

     /* Get the edges from the c-loops.
     */
     for(m=0; m<loc_numclps; m++)
      {
       loc_numedges = 0;
       junkGRid.objid = loc_clps[m];
       junkGRid.osnum = refid->osnum;
       sts = NMget_edges_from_loop(EMmsg, &junkGRid, &loc_numedges, &loc_edges,
	     &loc_edgeslistsize, num_edflps, edflps, edopt, 1, nmquery_opt);
       if(!(1&*EMmsg&sts)) goto wrapup;

       NMedgesOut(EMmsg, edgeslistsize, edges, loc_numedges, loc_edges, 
		&total_edges);
       if(!(1&*EMmsg)) goto wrapup;

       if(num_edges_per_face)
       (*num_edges_per_face)[j] += loc_numedges;
      }


     /* Get the edges from the feature loops.
     */
     for(m=0; m<num_flps; m++)
      {
       if(!IF_EQ_OBJID(loc_plps[j], loc_flps_parents[m])) continue;

       loc_numedges = 0;
       sts = NMget_edges_from_loop(EMmsg, &flps[m], &loc_numedges, &loc_edges,
	     &loc_edgeslistsize, num_edflps, edflps, edopt, 1, nmquery_opt);
       if(!(1&*EMmsg&sts)) goto wrapup;

       NMedgesOut(EMmsg, edgeslistsize, edges, loc_numedges, loc_edges, 
		&total_edges);
       if(!(1&*EMmsg)) goto wrapup;

       if(num_edges_per_face)
       (*num_edges_per_face)[j] += loc_numedges;
      }


next_plp:
     total_plps++;

    } /* for(j=0; j<loc_numplps; j++) */

  } /* for(i=0; i<loc_num_comps; i++) */

wrapup:

if(loc_comps && (loc_comps != loc_compsbuf)) om$dealloc(ptr = loc_comps);
if(loc_flps_parents) om$dealloc(ptr = loc_flps_parents);
if(loc_plps) om$dealloc(ptr = loc_plps);
if(loc_clps) om$dealloc(ptr = loc_clps);

EMWRAPUP(*EMmsg, sts, "NMget_faces_edges");
return(sts);
}


static void NMedgesOut(EMmsg, listsize, ed, num, newed, oldnum)
IGRlong *EMmsg;
IGRint *listsize;
struct GRid **ed, *newed;
IGRint num, *oldnum;
{
	
 if(listsize && (*listsize < (num + *oldnum)))
  {
   if(ed)
    {
     if(*ed)
      *ed = (struct GRid *) om$realloc(ptr = (IGRchar *) *ed, size = (num + *oldnum + 
	     EdInc) * sizeof(struct GRid));
     else
      *ed = (struct GRid *) om$malloc(size = (num + *oldnum + EdInc)
	  * sizeof(struct GRid));
     EMerr_hndlr(!*ed, *EMmsg, EMS_E_NoDynamicMemory, wrapup);
     *listsize = num + *oldnum + EdInc;
    }
  }

 if(ed && num)
  {
   OM_BLOCK_MOVE(newed, &(*ed)[*oldnum], num * sizeof(struct GRid));
   (*oldnum) += num;
  }

wrapup:
;
}



/*
Non manifold interface for EMSloop.EMget_edges.
*/

#define StaticBuf 10

IGRint NMget_edges_from_loop(EMmsg, lpid, numed, ed, edlistsize, num_edflps, 
			     edflps, edopt, depth, nmquery_opt)
IGRlong *EMmsg;
struct GRid *lpid;
IGRint *numed;
struct GRid **ed;
IGRint *edlistsize, num_edflps, depth;
struct GRid *edflps;
IGRlong edopt;
unsigned int nmquery_opt;
{
 IGRlong		sts = OM_S_SUCCESS;
 struct GRid		*loc_edflps = NULL;
 IGRint			loc_numedflps = 0, tmpedbufsize = 0, 
			new_numed = 0, flp_edges_bufsize = 0,
			num_flp_edges = 0, i, j;
 IGRboolean		found = FALSE;
 struct GRid		*tmped = NULL, tmpedbuf[StaticBuf], 
			*flp_edges = NULL;
 
 *EMmsg = EMS_S_Success;
 *numed = 0;
 tmped = tmpedbuf;
 tmpedbufsize = StaticBuf;

 sts = om$send(msg = message EMSloop.EMget_edges(EMmsg, depth, edopt, ed, 
       edlistsize, numed), targetid = lpid->objid, targetos = lpid->osnum, 
       senderid = NULL_OBJID);
 if(!(1&*EMmsg&sts)) goto wrapup;

 loc_edflps = edflps;
 loc_numedflps = num_edflps;

 if(!loc_numedflps)
  {
   struct GRid	surfid;
   OMuword exact_clsid = OPP_NMedflp_class_id;

   surfid.objid = NULL_OBJID;
   sts = om$send(msg = message EMSboundary.EMgetsurface_info(EMmsg,
	 &surfid.objid, NULL), targetid = lpid->objid, targetos = lpid->osnum, 
       senderid = NULL_OBJID);
   if(!(1&*EMmsg&sts)) goto wrapup;
   if(IF_NULL_OBJID(surfid.objid)) goto wrapup;
    surfid.osnum = lpid->osnum;

   /* Get the edflps here.
   */
   sts = NMget_feature_loops(EMmsg, &surfid, &loc_numedflps, &loc_edflps, 
	 &exact_clsid, 1, NULL, NULL, nmquery_opt);
   if(!(1&*EMmsg&sts)) goto wrapup;
  }

 if(!loc_numedflps) goto wrapup;

 /* If there exists an edflp which claims this loop as the overlapping loop, 
    replace the appropriate edges from this loop with the edges from the
    edflp.
 */
 for(i=0; i<loc_numedflps; i++)
  {
   GRobjid region_edge;
   IGRint edidx;

   sts = om$send(msg = message NMfeaturelp.NMget_nesting_parent(EMmsg, 
         &region_edge, TRUE), targetid = loc_edflps[i].objid, 
         targetos = loc_edflps[i].osnum, senderid = NULL_OBJID);
   if(!(1&*EMmsg&sts)) goto wrapup;
   found = FALSE;
   edidx = 0;
   for(j=0; j<*numed; j++)
    {
     if(IF_EQ_OBJID(region_edge, (*ed)[j].objid))
      {
       found = TRUE;
       break;
      }
     edidx++;
    }
   if(!found) continue;	   /* No overlap found */

   num_flp_edges = 0;
   sts = om$send(msg = message EMSboundary.EMget_edges(EMmsg, 1, 
         edopt, &flp_edges, &flp_edges_bufsize, &num_flp_edges), 
	 targetid = loc_edflps[i].objid, targetos = loc_edflps[i].osnum, 
         senderid = NULL_OBJID);
   if(!(1&*EMmsg&sts)) goto wrapup;
   EMerr_hndlr(!num_flp_edges, *EMmsg, EMS_E_Fail, wrapup);

   if(*edlistsize < (*numed + num_flp_edges))
    {
     if(*ed)
      *ed = (struct GRid *) om$realloc(ptr = (IGRchar *) *ed, size = 
	    (*numed + num_flp_edges + EdInc) * sizeof(struct GRid));
     else 
      *ed = (struct GRid *) om$malloc(size = (num_flp_edges + EdInc)
		    * sizeof(struct GRid));
     EMerr_hndlr(!(*ed), *EMmsg, EMS_E_NoDynamicMemory, wrapup);
     *edlistsize = *numed + num_flp_edges + EdInc;
    }

   if(tmpedbufsize < *numed)
    {
     if(tmped != tmpedbuf)
      tmped = (struct GRid *) om$realloc(ptr = (IGRchar *) tmped, size = 
		   *numed * sizeof(struct GRid));
     else tmped = (struct GRid *) om$malloc(size = *numed
		  * sizeof(struct GRid));
     EMerr_hndlr(!tmped, *EMmsg, EMS_E_NoDynamicMemory, wrapup);
     tmpedbufsize = *numed;
    }

    OM_BLOCK_MOVE(*ed, tmped, *numed * sizeof(struct GRid));

    new_numed = 0;
    if(edidx)
     {
      OM_BLOCK_MOVE(tmped, *ed, edidx * sizeof(struct GRid));
      new_numed = edidx;
     }
 
    OM_BLOCK_MOVE(flp_edges, &(*ed)[new_numed], num_flp_edges * 
		  sizeof(struct GRid));
    new_numed += num_flp_edges;

    if(edidx < (*numed - 1))
     {
      OM_BLOCK_MOVE(&tmped[edidx+1], &(*ed)[new_numed], 
      (*numed - 1 - edidx) * sizeof(struct GRid));
      new_numed += (*numed - 1 - edidx);
     }
    *numed = new_numed;

       
  } /* for(i=0; i<loc_numedflps; i++) */

wrapup:
if(loc_edflps && (loc_edflps != edflps)) om$dealloc(ptr = loc_edflps);
if(flp_edges) om$dealloc(ptr = flp_edges);
if(tmped && (tmped != tmpedbuf)) om$dealloc(ptr = tmped);

EMWRAPUP(*EMmsg, sts, "NMget_edges_from_loop");
return(sts);
}


end implementation NMnonmani;
