class implementation NMedge;

#include "EMSprop.h"
#include "OMmacros.h"
#include "emsmacros.h"

from EMSboundary import EMget_objid, EMgetsurface_info;

extern OMuword OPP_EMSedge_class_id;

#define StaticBuf 10

method NMdisconnect_edges(IGRlong *EMmsg; IGRint num_edges;
		        struct GRid *edges, *surfs; struct GRmd_env *env;
		        unsigned int connect_opt; struct NMgmSSI *ssi)
{
 IGRlong		sts = OM_S_SUCCESS;
 IGRint			numuses = 0, i, num_new = 0, j;
 IGRboolean		ref_discon = FALSE, skip = FALSE;
 struct EMSobject_info	*parents = NULL, *newp = NULL, newpbuf[StaticBuf];
 struct GRvg_construct	construct;
 struct IGRdisplay	disp;
 struct GRid		*newed = NULL, newedbuf[StaticBuf], *newsf = NULL, 
			newsfbuf[StaticBuf];
 IGRboolean		*newrev = NULL, newrevbuf[StaticBuf];
 struct GRid		*in_edges = NULL, in_edgesbuf[StaticBuf];
 IGRint			num_in_edges = 0;
 OM_S_CHANSELECT	to_comm;
 IGRushort	initas_opt = EMS_no_const_assoc 
			| EMSinit_dont_store_recomp_info;
 

 *EMmsg = EMS_S_Success;
 EMerr_hndlr(!num_edges, *EMmsg, EMS_I_InvalidArg, wrapup);

 /* Before any other processing, check the input edges and make sure that
    if any edge in the list has a common edge, that common edge is also
    disconnected.
 */
 if( (num_edges*2) > StaticBuf)
  in_edges = (struct GRid *) om$malloc(size = num_edges * 2 * 
		sizeof(struct GRid));
 else in_edges = in_edgesbuf;
 EMerr_hndlr(!in_edges, *EMmsg, EMS_E_NoDynamicMemory, wrapup);
 OM_BLOCK_MOVE(edges, in_edges, num_edges * sizeof(struct GRid));
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
       in_edges[num_in_edges++].osnum = OM_Gw_current_OS;
      }
    }
  }

 sts = om$send(msg = message NMassoc.NMget_parent_info
       (EMmsg, &parents, 0, &numuses), targetid = my_id);
 if(!(1&*EMmsg&sts)) goto wrapup;
 EMerr_hndlr(!numuses, *EMmsg, EMS_I_InvalidSend, wrapup);

 /* Is my reference use being disconnected?
 */
 for(i=0; i<num_in_edges; i++)
  if( (IF_EQ_GRID(ME.NMedge->refuse, in_edges[i])) || 
      (!EFisAncestryValid(EMmsg, ME.NMedge->refuse.objid, 
                         ME.NMedge->refuse.osnum, OPP_EMSedge_class_id, TRUE)))
   {
    ref_discon = TRUE;
    break;
   }

 if( (numuses-num_in_edges) > StaticBuf)
  newp = (struct EMSobject_info *) om$malloc(size = (numuses-num_in_edges)
	 * sizeof(struct EMSobject_info));
 else newp = newpbuf;
 EMerr_hndlr(!newp, *EMmsg, EMS_E_NoDynamicMemory, wrapup);

 /* Create a list of new parents which are going to remain.
 */
 num_new = 0;
 for(i=0; i<numuses; i++)
  {
   skip = FALSE;

   /* Is the old parent still valid? If not skip it too. The function call
      will check objid validity and ancestry.
   */
   if(!EFisAncestryValid(EMmsg, parents[i].grid.objid, parents[i].grid.osnum, 
			 OPP_EMSedge_class_id, TRUE))
    skip = TRUE;
   else
    {
     for(j=0; j<num_in_edges; j++)
      if(IF_EQ_GRID(parents[i].grid, in_edges[j]))
       {
        skip = TRUE;
        break;
       }
    }
   if(!skip) newp[num_new++] = parents[i];
  }

 /* If none of the input edges were found in the existing edges list, 
    get out of here.
 */
 EMerr_hndlr(num_new == numuses, *EMmsg, EMS_I_NotFound, wrapup);

 if(ref_discon) 
  {
   /* Since the reference use itself is being disconnected, do the connection
      again, picking a new reference use.
   */
   if(num_new > StaticBuf)
    {
     newed = (struct GRid *) om$malloc(size = num_new * sizeof(struct GRid));
     newsf = (struct GRid *) om$malloc(size = num_new * sizeof(struct GRid));
    }
   else
    {
     newed = newedbuf;
     newsf = newsfbuf;
    }
   EMerr_hndlr(!newed || !newsf, *EMmsg, EMS_E_NoDynamicMemory, wrapup);

   for(i=0; i<num_new; i++)
    {
     newed[i] = newp[i].grid;
     sts = om$send(msg = message EMSboundary.EMgetsurface_info(EMmsg, 
	   &newsf[i].objid, NULL), targetid = newed[i].objid);
     if(!(1&*EMmsg&sts)) goto wrapup;
     newsf[i].osnum = newed[i].osnum;
    }

   /* Disconnect all parents before reinitialization.
   */
   sts = om$send(msg = message NDnode.NDdisconnect(0, NULL), targetid = my_id);
   if(!(1&sts)) goto wrapup;

   if(num_new)
    {
     sts = om$send(msg = message NMedge.NMconnect_edges(EMmsg, num_new, 
	   newed, newsf, NULL, env, NULL, NULL), targetid = my_id);
     if(!(1&*EMmsg&sts)) goto wrapup;
    }

  } /* if(ref_discon) */
 else
  {
   /* Since the reference use is not being disconnected, the reversibility
      info for remaining edges is still valid.
   */
   if(num_new > StaticBuf)
    newrev = (IGRboolean *) om$malloc(size = num_new * sizeof(IGRboolean));
   else newrev = newrevbuf;

   num_new = 0;
   for(i=0; i<numuses; i++)
    {
     skip = FALSE;
     for(j=0; j<num_in_edges; j++)
      if(IF_EQ_GRID(parents[i].grid, in_edges[j]))
       {
        skip = TRUE;
        break;
       }
     if(!skip) newrev[num_new++] = ME.NMedge->reverse[i];
    }

   construct.display = &disp;
   construct.class_attr = NULL;
   construct.msg = EMmsg;
   construct.env_info = env;
   sts = om$send(msg = message EMSassoc.EMget_construction_info(EMmsg, &construct),
         targetid = my_id);
   if(!(1&*EMmsg&sts)) goto wrapup;
   construct.newflag = FALSE;

   /* Disconnect all parents before reinitialization.
   */
   sts = om$send(msg = message NDnode.NDdisconnect(0, NULL), targetid = my_id);
   if(!(1&sts)) goto wrapup;

   /* Establish parent-child relationship with all the edges.
   */
   if(num_new)
    {
     sts = om$send(msg = message EMSassoc.EMinit_associative(EMmsg, 
           initas_opt, num_new, newp, NULL, NULL, NULL, 
           &construct), targetid = my_id);
     if(!(1&*EMmsg&sts)) goto wrapup;

     sts = om$vla_set_dimension(varray = ME.NMedge->reverse, 
           size = num_new);
     if(!(1&sts)) goto wrapup;
     OM_BLOCK_MOVE(newrev, ME.NMedge->reverse, num_new * sizeof(IGRboolean));
    }
  }


 if( (connect_opt & NMconnect_AddToSSI) && ssi)
  for(i=0; i<num_edges; i++)
   {
     sts = NMstore_nmedge_change(EMmsg, ssi, &surfs[i], my_id, edges[i].objid,
           FALSE);
     if(!(1&*EMmsg&sts)) goto wrapup;
    }

 /* If no edges left to connect, set appropriate return code.
 */
 if(!num_new) *EMmsg = EMS_I_Useless;


wrapup:
if(parents) om$dealloc(ptr = parents);
if(newp && (newp != newpbuf)) om$dealloc(ptr = newp);
if(in_edges && (in_edges != in_edgesbuf)) om$dealloc(ptr = in_edges);
if(newed && (newed != newedbuf)) om$dealloc(ptr = newed);
if(newsf && (newsf != newsfbuf)) om$dealloc(ptr = newsf);
if(newrev && (newrev != newrevbuf)) om$dealloc(ptr = newrev);

EMWRAPUP(*EMmsg, sts, "NMedge.NMdisconnect_edges");
return(sts);
}

end implementation NMedge;
