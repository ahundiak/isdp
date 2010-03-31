class implementation NMvertex_use;

#include "OMmacros.h"

method NDdisconnect(IGRint num; struct GRid *parents)
{
 IGRlong		sts = OM_S_SUCCESS, EMmsg = EMS_S_Success;
 IGRint			num_old_edges = 0, num_new_edges = 0, i, j;
 GRobjid		*old_edges = NULL, *new_edges = NULL;
 enum EMScvinttype	*old_loc_on_edge = NULL, *new_loc_on_edge = NULL;
 IGRdouble		uvpt[2];

 /* If all the parents are getting disconnected, just set numedges = 0 and
    send NDnode.NDdisconnect to myself.
 */
 if(!num && !parents)
  {
   sts = om$vla_set_dimension(varray = ME.NMvertex_use->edloc, 
			    size = 0);
   if(!(1&sts)) goto wrapup;

   sts = om$send(mode = OM_e_wrt_message, msg = message NDnodein.NDdisconnect
         (num, parents), targetid = my_id);
   goto wrapup;
  }
 else
  {
   sts = om$send(msg = message NMvertex_use.NMget_incedence_info
         (&EMmsg, NULL_OBJID, &num_old_edges, &old_edges, &old_loc_on_edge, 
	  NULL, uvpt, NULL, NULL), targetid = my_id);
   if(!(1&EMmsg&sts)) goto wrapup;
   /*
    Create a list of edges that are going to remain.
   */
   new_edges = (GRobjid *) om$malloc(size = num_old_edges * sizeof(GRobjid));
   new_loc_on_edge = (enum EMScvinttype *) om$malloc(size = num_old_edges
			* sizeof(enum EMScvinttype));
   EMerr_hndlr(!new_edges || !new_loc_on_edge, EMmsg, EMS_E_NoDynamicMemory, 
		wrapup);
   for(i=0; i<num_old_edges; i++)
    for(j=0; j<num; j++)
     if(IF_EQ_OBJID(old_edges[i], parents[j].objid))
      {
	old_edges[i] = NULL_OBJID;
	break;
      }
   for(i=0; i<num_old_edges; i++)
    if(!IF_NULL_OBJID(old_edges[i]))
     {
      new_edges[num_new_edges] = old_edges[i];
      new_loc_on_edge[num_new_edges++] = old_loc_on_edge[i];
     }

   /* Disconnect ALL the parents and reconnect those not in the input list.
   */
   sts = om$send(mode = OM_e_wrt_message, msg = message NDnodein.NDdisconnect
	 (0, NULL), targetid = my_id);
   if(!(1&sts)) goto wrapup;
   sts = om$vla_set_dimension(varray = ME.NMvertex_use->edloc, 
			    size = 0);
   if(!(1&sts)) goto wrapup;

   sts = om$send(msg = message NMvertex_use.NMconnect_edges
	 (&EMmsg, num_new_edges, new_edges, new_loc_on_edge, uvpt, NULL, NULL),
	 targetid = my_id);
  }

wrapup:
EMWRAPUP(EMmsg, sts, "NMvertex_use.NDdisconnect");
return(sts);
}

end implementation NMvertex_use;
