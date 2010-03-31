class implementation NMvertex_use;

#include "OMmacros.h"

method NMreplace_edge(IGRlong *EMmsg; GRobjid exist_edgeid; 
		       IGRint num_replacements; GRobjid *replacements;
		       enum EMScvinttype *loc_on_replacements;
		       unsigned int connect_opt; struct NMgmSSI *ssi)

{
 IGRlong		sts = OM_S_SUCCESS;
 IGRint			old_num_edges = 0, new_num_edges = 0, i, idx = 0;
 GRobjid		*old_edges = NULL, *new_edges = NULL;
 enum EMScvinttype	*old_loc_on_edge = NULL, *new_loc_on_edge = NULL;
 IGRdouble		uvpt[2];
 IGRboolean		found = FALSE;
 unsigned int	nmquery_opt = NULL;

 *EMmsg = EMS_S_Success;

 if(connect_opt & NMconnect_InTransientState)
  nmquery_opt = NMquery_InTransientState;

 sts = om$send(msg = message NMvertex_use.NMget_incedence_info(EMmsg, 
       NULL_OBJID, &old_num_edges, &old_edges, &old_loc_on_edge, NULL, uvpt, 
       NULL, nmquery_opt), targetid = my_id);
 if(!(1&*EMmsg&sts)) goto wrapup;
 if(!old_num_edges)
  {
   if(!num_replacements)  /* intention was to simply disconnect and edge*/
    *EMmsg = EMS_I_InvalidSend;
   else
    *EMmsg = EMS_E_InvalidSend;
   goto wrapup;
  }

 new_edges = (GRobjid *) om$malloc(size = (old_num_edges + num_replacements)
		* sizeof(GRobjid));
 new_loc_on_edge = (enum EMScvinttype *) om$malloc(size = 
		   (old_num_edges + num_replacements) * 
		    sizeof(enum EMScvinttype));
 EMerr_hndlr(!new_edges || !new_loc_on_edge, *EMmsg, EMS_E_NoDynamicMemory, 
	     wrapup);

 for(i=0; i<old_num_edges; i++)
  {
   if(IF_EQ_OBJID(old_edges[i], exist_edgeid))
    {
     found = TRUE;
     break;
    }
   idx++;
  }

 if(!found)
  {
   if(!num_replacements)  /* intention was to simply disconnect and edge*/
    *EMmsg = EMS_I_InvalidSend;
   else
    *EMmsg = EMS_E_InvalidSend;
   goto wrapup;
  }

 if(idx)
  {
   OM_BLOCK_MOVE(old_edges, new_edges, idx * sizeof(GRobjid));
   OM_BLOCK_MOVE(old_loc_on_edge, new_loc_on_edge, idx * 
		 sizeof(enum EMScvinttype));
   new_num_edges = idx;
  }

 if(num_replacements)
  OM_BLOCK_MOVE(replacements, &new_edges[new_num_edges], 
	       num_replacements * sizeof(GRobjid));
	
 /* If no locations on the replacements are supplied assume them to be same
    as on the original edge.
 */
 if(num_replacements && loc_on_replacements)
  {
   OM_BLOCK_MOVE(loc_on_replacements, &new_loc_on_edge[new_num_edges], 
	         num_replacements * sizeof(enum EMScvinttype));
   new_num_edges += num_replacements;
  }
 else
  for(i=0; i<num_replacements; i++)
   new_loc_on_edge[new_num_edges++] = old_loc_on_edge[idx];


 if(idx < (old_num_edges - 1))
  {
   OM_BLOCK_MOVE(&old_edges[idx+1], &new_edges[new_num_edges], 
		 (old_num_edges - 1 - idx) * sizeof(GRobjid));
   OM_BLOCK_MOVE(&old_loc_on_edge[idx+1], &new_loc_on_edge[new_num_edges], 
		 (old_num_edges - 1 - idx) * sizeof(enum EMScvinttype));
   new_num_edges += (old_num_edges - 1 - idx);
  }

 sts = om$send(msg = message NDnode.NDdisconnect(0, NULL), targetid = my_id);
 if(!(1&sts)) goto wrapup;
 sts = om$vla_set_dimension(varray = ME.NMvertex_use->edloc, 
			    size = 0);
 if(!(1&sts)) goto wrapup;

 /* Don't request the NMconnect_edges method for any ssi storage since only
    this method knows it is a replacement.
 */
 sts = OM_S_SUCCESS;
 *EMmsg = EMS_S_Success;
 if(new_num_edges)
  {
   sts = om$send(msg = message NMvertex_use.NMconnect_edges(EMmsg, 
	 new_num_edges, new_edges, new_loc_on_edge, uvpt, connect_opt, NULL), 
	 targetid = my_id);
  }

 if(!(1&*EMmsg&sts))
  {
   IGRlong locsts, rc;

   /* Restore the vertex use to its original state, before exiting.
   */
   locsts = om$send(msg = message NMvertex_use.NMconnect_edges(&rc, 
	    old_num_edges, old_edges, old_loc_on_edge, uvpt, 
	    connect_opt | NMconnect_NoChecks, NULL),
	    targetid = my_id);
   goto wrapup;
  }

 if( (connect_opt & NMconnect_AddToSSI) && ssi)
  {
   struct GRid sfid;

   sfid.objid = NULL_OBJID;
   sfid.osnum = OM_Gw_current_OS;
   sts = om$send(msg = message NMvertex_use.NMgetsurface_info(EMmsg, 
         &sfid.objid, NULL), targetid = my_id);
   if(!(1&*EMmsg&sts)) goto wrapup;
   EMerr_hndlr(IF_NULL_OBJID(sfid.objid), *EMmsg, EMS_E_Fail, wrapup);

   if(!num_replacements) /* its a disconnect of an existing edge */
    {
     sts = NMstore_vtxuse_change(EMmsg, ssi, &sfid, my_id, exist_edgeid, 
           NULL_OBJID);
     if(!(1&*EMmsg&sts)) goto wrapup;
    }
   else
    for(i=0; i<num_replacements; i++)
     {
      sts = NMstore_vtxuse_change(EMmsg, ssi, &sfid, my_id, exist_edgeid, 
            replacements[i]);
      if(!(1&*EMmsg&sts)) goto wrapup;
     }
  }

wrapup:
if(old_edges) om$dealloc(ptr = old_edges);
if(old_loc_on_edge) om$dealloc(ptr = old_loc_on_edge);
if(new_edges) om$dealloc(ptr = new_edges);
if(new_loc_on_edge) om$dealloc(ptr = new_loc_on_edge);

EMWRAPUP(*EMmsg, sts, "NMvertex_use.NMreplace_edge");
return(sts);
}


end implementation NMvertex_use;
