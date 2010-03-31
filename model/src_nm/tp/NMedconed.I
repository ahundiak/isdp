class implementation NMedge;

#include "EMSprop.h"
#include "OMmacros.h"
#include "emsmacros.h"

from EMSedge import EMget_props, EMtst_reversibility;
from EMSboundary import EMget_objid, EMgetsurface_info;
from NMvertex import NMcheck;

#define StaticBuf 10

method NMconnect_edges(IGRlong *EMmsg; IGRint num_edges;
		        struct GRid *edges, *surfs; IGRboolean *reverse;
			struct GRmd_env *env; struct NMgmSSI *ssi;
			unsigned int connect_opt)
{
 IGRlong		sts = OM_S_SUCCESS;
 IGRint			numuses = 0, i, num_new = 0, j, numvtxuse = 0;
 struct GRid		refuse, refsf;
 IGRboolean		seam = FALSE, duplicate;
 IGRushort	refprops = NULL;
 struct EMSobject_info	*parents = NULL, *oldp = NULL, oldpbuf[StaticBuf];
 struct GRvg_construct	construct;
 struct IGRdisplay	disp;
 struct GRid		*in_edges = NULL, in_edgesbuf[StaticBuf], 
			*in_surfs = NULL, in_surfsbuf[StaticBuf], 
			*vtx = NULL, *locsurfs = NULL, locsurfsbuf[StaticBuf];
 IGRint			num_in_edges = 0, numoldp = 0;
 OM_S_CHANSELECT	to_comm;
 IGRushort	initas_opt = EMS_no_const_assoc 
			| EMSinit_dont_store_recomp_info;
 GRobjid		ref_commid;
 enum EMScvinttype	atloc;
 unsigned int	nmquery_opt = NULL;
 IGRboolean		*reverse_known = NULL, *in_reverse = NULL, 
			in_reversebuf[StaticBuf], reverseknownbuf[StaticBuf], 
			*locreverse = NULL;

 *EMmsg = EMS_S_Success;

 if(connect_opt & NMconnect_ExternalToModel)
  nmquery_opt |= NMquery_ConsiderExternalToModel;

 /* Before any other processing, check the input edges and make sure that
    if any edge in the list has a common edge, that common edge is also
    connected.
 */
 if( (num_edges*2) > StaticBuf)
  {
   in_edges = (struct GRid *) om$malloc(size = num_edges * 2 * 
	      sizeof(struct GRid));
   if(surfs)
    in_surfs = (struct GRid *) om$malloc(size = num_edges * 2 * 
	      sizeof(struct GRid));
   if(reverse)
    in_reverse = (IGRboolean *) om$malloc(size = 2 * num_edges * 
		  sizeof(IGRboolean));
  }
 else
  {
   in_edges = in_edgesbuf;
   if(surfs) in_surfs = in_surfsbuf;
   if(reverse) in_reverse = in_reversebuf;
  }
 EMerr_hndlr(!in_edges, *EMmsg, EMS_E_NoDynamicMemory, wrapup);

 OM_BLOCK_MOVE(edges, in_edges, num_edges * sizeof(struct GRid));
 if(surfs) OM_BLOCK_MOVE(surfs, in_surfs, num_edges * sizeof(struct GRid));
 if(reverse)
  OM_BLOCK_MOVE(reverse, in_reverse, num_edges * sizeof(IGRboolean));

 num_in_edges = num_edges;
 
 EMmake_chanselect(EMSedge_to_common_edge, &to_comm);

 for(i=0; i<num_edges; i++)
  {
   GRobjid commid = NULL_OBJID;

   sts = om$send(msg = message EMSboundary.EMget_objid(EMmsg, &commid), 
	 senderid = edges[i].objid, p_chanselect = &to_comm);
   if(!(1&*EMmsg&sts)) goto wrapup;

   if(!IF_NULL_OBJID(commid))
    {
     IGRboolean found = FALSE;
     for(j=0; j<num_edges; j++)
      if(IF_EQ_OBJID(edges[j].objid, commid))
       {
        found = TRUE;
	break;
       }

     if(!found)
      {
       in_edges[num_in_edges].objid = commid;
       in_edges[num_in_edges].osnum = OM_Gw_current_OS;

       /*
         If the reverse flag is supplied for the input edge, we can deduce
         that for its common edge.
       */
       if(reverse)
        {
	 IGRushort edprops = NULL;
	
         sts = om$send(msg = message EMSedge.EMget_props(EMmsg, &edprops), 
	       targetid = commid);
         if(!(1&*EMmsg&sts)) goto wrapup;
         in_reverse[num_in_edges] = reverse[i];
         if(edprops & EMED_REVERSE_CONNECT)
          in_reverse[num_in_edges] = !in_reverse[num_in_edges];
        }
       else if(in_surfs)
        {
         in_surfs[num_in_edges].osnum = OM_Gw_current_OS;
         sts = om$send(msg = message EMSboundary.EMgetsurface_info(EMmsg, 
	       &in_surfs[num_in_edges].objid, NULL), 
	       targetid = commid);
         if(!(1&*EMmsg&sts)) goto wrapup;
        }
       num_in_edges++;

      } /* if(!found) */

    } /* if(!IF_NULL_OBJID(commid)) */

  } /* for(i=0; i<num_edges; i++) */

 sts = om$send(msg = message NMassoc.NMget_parent_info
       (EMmsg, &parents, 0, &numuses), targetid = my_id);
 if(!(1&*EMmsg&sts)) goto wrapup;

 /* if I already have some uses, make sure my reference use is still
    valid. If it is not reset the reference use.
    if I am empty, pick the first edge from the incoming list of edges
    to become the reference use.
 */
 if(numuses)
  {
   sts = om$send(msg = message NMedge.NMcheck(EMmsg, &refuse, &refsf), 
         targetid = my_id);
   if(!(1&*EMmsg&sts))
    {
     sts = om$send(msg = message NMedge.NMreset_refuse(EMmsg, &refuse, &refsf, 
           env), targetid = my_id);
     if(!(1&sts)) goto wrapup;
     if(parents) om$dealloc(ptr = parents);
     parents = NULL;
     numuses = 0;
     sts = om$send(msg = message NMassoc.NMget_parent_info
           (EMmsg, &parents, 0, &numuses), targetid = my_id);
     if(!(1&*EMmsg&sts)) goto wrapup;
    }

   /*
     if reverse flags have been input, but they are not wrt the reference
     edge already connected (if there is one), then error out. Should I
     ignore the input reverse flags and continue?
   */
   if(reverse && (!(IF_EQ_GRID(ME.NMedge->refuse, in_edges[0]))))
    {
     *EMmsg = EMS_E_InvalidCase;
     goto wrapup;
    }
   sts = om$send(msg = message NMedge.NMget_edge_info(EMmsg, &numuses, NULL, 
         NULL, NULL, &locreverse, nmquery_opt), targetid = my_id);
   if(!(1&*EMmsg&sts)) goto wrapup;
  }
 else
  {
   refuse = in_edges[0];
   if(in_surfs) refsf = in_surfs[0];
   ME.NMedge->refuse = refuse;
   ME.NMedge->refsf = refsf;
  }

 /* Capture the old parents data for future use.
 */
 if( (connect_opt & NMconnect_AddToSSI) && ssi && numuses)
  {
   if(numuses > StaticBuf)
    oldp = (struct EMSobject_info *) om$malloc(size = numuses * 
	    sizeof(struct EMSobject_info));
   else
    oldp = oldpbuf;
   EMerr_hndlr(!oldp, *EMmsg, EMS_E_NoDynamicMemory, wrapup);
   OM_BLOCK_MOVE(parents, oldp, numuses * sizeof(struct EMSobject_info));
   numoldp = numuses;
   
  }
 else numoldp = 0;


 if(numuses)
  {
   parents = (struct EMSobject_info *) om$realloc(ptr = (IGRchar *) parents, 
	      size = (numuses + num_in_edges) * sizeof(struct EMSobject_info));
   locreverse = (IGRboolean *) om$realloc(ptr = (IGRchar *) locreverse, 
	      size = (numuses + num_in_edges) * sizeof(IGRboolean));
  }
 else
  {
   parents = (struct EMSobject_info *) om$malloc(size = num_in_edges * 
	    sizeof(struct EMSobject_info));
   locreverse = (IGRboolean *) om$malloc(
	      size = num_in_edges * sizeof(IGRboolean));
  }
 EMerr_hndlr(!parents || !locreverse, *EMmsg, EMS_E_NoDynamicMemory, wrapup);

 if( (numuses + num_in_edges) > StaticBuf)
  {
   reverse_known = (IGRboolean *) om$malloc(size = (num_in_edges + numuses)
		   * sizeof(IGRboolean));
   locsurfs = (struct GRid *) om$malloc(size = (num_in_edges + numuses) *
			sizeof(struct GRid));
  }
 else
  {
   reverse_known = reverseknownbuf;
   locsurfs = locsurfsbuf;
  }

 for(i=0; i<numuses; i++) reverse_known[i] = TRUE;

 num_new = numuses;
 for(i=0; i<num_in_edges; i++)
  {
   duplicate = FALSE;
   for(j=0; j<num_new; j++)
    if(IF_EQ_GRID(parents[j].grid, in_edges[i]))
     {
      duplicate = TRUE;
      break;
     }
   if(duplicate) continue;
   parents[num_new].grid = in_edges[i];
   parents[num_new].env = *env;
   if(in_reverse)
    {
     locreverse[num_new] = in_reverse[i];
     reverse_known[num_new] = TRUE;
    }
   else
    {
     reverse_known[num_new] = FALSE;
     if(in_surfs) locsurfs[num_new] = in_surfs[i];
     else locsurfs[num_new].objid = NULL_OBJID;
    }
   num_new++;
  }

 EMerr_hndlr(num_new == numuses, *EMmsg, EMS_I_Useless, wrapup);

 if(numuses)
  {
   /* Disconnect all parents before reinitialization.
   */
   sts = om$send(msg = message NDnode.NDdisconnect(0, NULL), targetid = my_id);
   if(!(1&sts)) goto wrapup;
  }

 construct.display = &disp;
 construct.class_attr = NULL;
 construct.msg = EMmsg;
 construct.env_info = env;
 sts = om$send(msg = message EMSassoc.EMget_construction_info(EMmsg, &construct),
       targetid = my_id);
 if(!(1&*EMmsg&sts)) goto wrapup;
 construct.newflag = FALSE;

 /* Establish parent-child relationship with all the edges.
 */
 sts = om$send(msg = message EMSassoc.EMinit_associative(EMmsg, 
       initas_opt, num_new, parents, NULL, NULL, NULL, 
       &construct), targetid = my_id);
 if(!(1&*EMmsg&sts)) goto wrapup;

 sts = om$vla_set_dimension(varray = ME.NMedge->reverse, 
       size = num_new);
 if(!(1&sts)) goto wrapup;

 sts = om$send(msg = message EMSedge.EMget_props(EMmsg, &refprops), 
       targetid = refuse.objid, targetos = refuse.osnum);
 if(!(1&*EMmsg&sts)) goto wrapup;
 seam = refprops & EMED_SEAM;

 ref_commid = NULL_OBJID;
 sts = om$send(msg = message EMSboundary.EMget_objid(EMmsg, &ref_commid), 
       senderid = refuse.objid, p_chanselect = &to_comm);
 if(!(1&*EMmsg&sts)) goto wrapup;

 for(i=0; i<num_new; i++)
  {
   if(IF_EQ_GRID(refuse, parents[i].grid))
     ME.NMedge->reverse[i] = FALSE;
   else if(reverse_known[i]) ME.NMedge->reverse[i] = locreverse[i];
   else
    {
     GRobjid old_commid = NULL_OBJID;
     IGRboolean reverse_connect = FALSE;

     /* EMtst_reversilibility uses EMtwin_crv_parm message in some cases
	(for example if the edge are xyz closed). This latter message assumes
	that the test is being done on a pair of common edges. Hence I
	temporarily connect the two edges as common edges and then restore
	the original state after the test is done. I will clean this up after
	requesting and getting a fix in MODEL code to remove this
	assumption.
     */
     EMerr_hndlr(IF_NULL_OBJID(locsurfs[i].objid), *EMmsg, EMS_E_Fail, wrapup);

     sts = om$send(msg = message EMSboundary.EMget_objid(EMmsg, &old_commid), 
           senderid = parents[i].grid.objid, p_chanselect = &to_comm);
     if(!(1&*EMmsg&sts)) goto wrapup;

     /* Disconnect the edges from their existing common edges.
     */
     if(!IF_NULL_OBJID(ref_commid))
      {
       sts = om$send(msg = message Root.wild_disconnect(to_comm), 
	     targetid = refuse.objid);
       if(!(1&sts)) goto wrapup;
      }
     if(!IF_NULL_OBJID(old_commid))
      {
       sts = om$send(msg = message Root.wild_disconnect(to_comm), 
	     targetid = parents[i].grid.objid);
       if(!(1&sts)) goto wrapup;
      }

     /* Connect the edges as common edges.
     */
     sts = om$send(msg = message Root.connect(to_comm, 0, 
	   parents[i].grid.objid, parents[i].grid.osnum, to_comm, 0), 
	   targetid = refuse.objid);
     if(!(1&sts)) goto wrapup;

     sts = om$send(msg = message EMSedge.EMtst_reversibility(EMmsg, 
           &reverse_connect, parents[i].grid.objid, refsf.objid, 
           locsurfs[i].objid, seam, env), targetid = refuse.objid, 
           targetos = refuse.osnum);
     if(!(1&*EMmsg&sts)) goto wrapup;
     ME.NMedge->reverse[i] = reverse_connect ? TRUE : FALSE;

     /* Disconnect temporary connection.
     */
     sts = om$send(msg = message Root.wild_disconnect(to_comm), 
           targetid = refuse.objid);
     if(!(1&sts)) goto wrapup;

     /* Reconnect original edges. Maan, what a mess.
     */
     if(!IF_NULL_OBJID(ref_commid))
      {
       sts = om$send(msg = message Root.connect(to_comm, 0, ref_commid, 
	     refuse.osnum, to_comm, 0), targetid = refuse.objid);
       if(!(1&sts)) goto wrapup;
      }
     if(!IF_NULL_OBJID(old_commid))
      {
       sts = om$send(msg = message Root.connect(to_comm, 0, old_commid, 
	     parents[i].grid.osnum, to_comm, 0), 
	     targetid = parents[i].grid.objid);
       if(!(1&sts)) goto wrapup;
      }

    }

  } /* for(i=0; i<num_new; i++) */


 /* For all the edges connected to me, check whether the presence of a vertex
    at either end is consistent. If an edge is connected to a vertex at either
    end, so should all the other edges.
 */
 if(connect_opt & NMconnect_CompatibleVertices)
  {
   for(i=0; i<num_new; i++)
    for(j=0; j<2; j++)
     {
      if(vtx) om$dealloc(ptr = vtx);
      vtx = NULL;
      numvtxuse = 0;
      atloc = j ? EMScvint_rtend : EMScvint_lfend;
      sts = NMget_vertex_use(EMmsg, &parents[i].grid, &numvtxuse, NULL, NULL, 
	    NULL, NULL, &vtx, NULL, NULL, NULL, NULL, &atloc, NULL, NULL, 
	    nmquery_opt, NULL, NULL);
      if(!(1&*EMmsg&sts)) goto wrapup;
      if(*EMmsg == EMS_I_Fail) numvtxuse = 0;

      /* There should be only one vertex at the end of an edge.
      */
      EMerr_hndlr(numvtxuse>1, *EMmsg, EMS_E_InvalidCase, wrapup);
      if(numvtxuse)
       {
        /* Send a message to the vertex to check, and create if necessary, a
           vertex use in each parametric space.
        */
        sts = om$send(msg = message NMvertex.NMcheck(EMmsg, ssi, 
	      connect_opt), 
	      targetid = vtx[0].objid);
        if(!(1&*EMmsg&sts)) goto wrapup;
       }

     } /* for each end of each edge */

   } /* if(connect_opt & NMconnect_CompatibleVertices) */

 if( (connect_opt & NMconnect_AddToSSI) && ssi)
  {
   struct GRid sfid;
   IGRboolean was_oldp = FALSE;

   sfid.osnum = OM_Gw_current_OS;

   for(i=0; i<num_new; i++)
    {
     was_oldp = FALSE;
     for(j=0; j<numoldp; j++)
      if(IF_EQ_OBJID(oldp[j].grid.objid, parents[i].grid.objid))
       {
	was_oldp = TRUE;
	break;
       }
     if(!was_oldp)
      {
       sfid.objid = NULL_OBJID;
       sts = om$send(msg = message EMSboundary.EMgetsurface_info(EMmsg, 
             &sfid.objid, NULL), targetid = parents[i].grid.objid);
       if(!(1&*EMmsg&sts)) goto wrapup;
       EMerr_hndlr(IF_NULL_OBJID(sfid.objid), *EMmsg, EMS_E_Fail, wrapup);
       sts = NMstore_nmedge_change(EMmsg, ssi, &sfid, my_id,
             parents[i].grid.objid, TRUE);
       if(!(1&*EMmsg&sts)) goto wrapup;
      }
    }
  }

wrapup:
if(vtx) om$dealloc(ptr = vtx);
if(parents) om$dealloc(ptr = parents);
if(in_edges && (in_edges != in_edgesbuf)) om$dealloc(ptr = in_edges);
if(in_surfs && (in_surfs != in_surfsbuf)) om$dealloc(ptr = in_surfs);
if(oldp && (oldp != oldpbuf)) om$dealloc(ptr = oldp);
if(locreverse) om$dealloc(ptr = locreverse);
if(reverse_known && (reverse_known != reverseknownbuf))
 om$dealloc(ptr = reverse_known);
if(in_reverse && (in_reverse != in_reversebuf))
 om$dealloc(ptr = in_reverse);
if(locsurfs && (locsurfs != locsurfsbuf)) om$dealloc(ptr = locsurfs);

EMWRAPUP(*EMmsg, sts, "NMedge.NMconnect_edges");
return(sts);
}

end implementation NMedge;
