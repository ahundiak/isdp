/* ###################   APOGEE COMPILED   ################## */
/*
Notes
	This method facilitates the modifications of edges in a loop.A set
   of edges can be inserted before a reference edge, can be inserted after
   a reference edge or the reference edge can be replaced by those set of
   edges. A set of edges can also be inserted at the begining or at the
   end, in which case the reference edge is neglected.
	Inserting edges before,or after the reference edge are relative
   to the geometrical endpoints of the edge. The loop to edge connections
   are adjusted such that the new edge(s) are introduced taking into account
   the direction of the edge. Thus for e.g in a reversed loop the 
   edge at index 1 may be connected on the channel 'after' edge at
   index 0,but still according to geometrical direction of the edges,the
   edge at index 1 is 'before' the edge at index 0.
	The input edges are expected as shown below - 

   N0 and N1 are the input edges in that order as far as the input edge
   array is concerned.   

		    <--
             --------------------
				|  ^
				|  |
				|
				|   N1 <--
				 ---------
					 |   ^
					 |N0 |

   OR
		    <--
             --------------------
	     |			|  ^
	   N0|			|  |
	     |			|
     --------			|   
       <-- N1

NOTE:
----
	Option EMS_DEL_EDGE_RESTORE_LOOP in EMSopt.h would cause the deletion
	 of the edge from the loop after restoring the order of othe edges in
     the loop.

Assumption
	The edges are connected to the loop on a relative channel so that
   expansion due to insertion of objects or contraction due to removal of
   objects from the channel is possible.
	It also assumed that the loop being reversed means that the edges
   are connected in the reverse order of their direction.

History
	SM		03/05/87	Creation date
        SM      	11-Nov-87	Added argument 'update_range' so that 
					the caller can choose to avoid it.
 	SAM     	03-Apr-88   	Modified such that, for the loop the 
					refrence edge would be deleted after 
					the restoring the order of other edges,
					changed name from EMinsert_edge to 
					EMmodify_edge.
     
*/
class implementation EMSloop;

#include "EMS.h"
#include "emsdef.h"
#include "EMSopt.h"
#include "emsmacros.h"

method EMmodify_edge(IGRlong *EMmsg;IGRlong option,num_edges;
			GRobjid ref_edge, *edge;
			IGRboolean update_range)
{
  IGRlong 		sts;
  OMuint		count, index;
  IGRint                con=0,i,edcount;
  OM_S_CHANSELECT 	to_edges, to_loop;

  *EMmsg = EMS_S_Success;
  sts = OM_S_SUCCESS;

  edcount = 0;

  to_edges.type = OM_e_addr;
  to_edges.u_sel.addr = &ME.EMSbd_owner->to_comps;

  sts = EMmake_chanselect (EMSedge_to_owner, &to_loop);
  EMerr_hndlr(! (1 & sts),*EMmsg,EMS_E_OMerror,wrapup);
  sts = om$get_channel_count(object = me,p_chanselect = &to_edges,
                             count = &count);
  EMerr_hndlr(!(1&sts),*EMmsg,EMS_E_OMerror,wrapup);

/* Get the index of the reference edge. If the option is ATBEGIN then 
   always put the new edges BEFORE some edge. If the loop is reversed
   put the new edges BEFORE the edge at index count-1 else put them 
   before edge at index 0. If the option is ATEND always put the new
   edges AFTER some edge. If the loop is reversed then put the new edges
   AFTER edge at index 0 else put them AFTER the edge at index
   count-1.
*/
  if(option==EMS_INS_ATBEGIN)
   {
     index = ME.EMSloop->lp_props&EMLP_REVERSED ? count-1 : 0;
     option = EMS_INS_BEFORE;
   }
  else if(option==EMS_INS_ATEND)
   {
     index = ME.EMSloop->lp_props&EMLP_REVERSED? 0 : count-1;
     option = EMS_INS_AFTER;
   }
  else
   {
     sts = om$get_index(object_c = me, p_chanselect = &to_edges,
		     objid = ref_edge, osnum2 = OM_Gw_current_OS,
		     indexaddr = &index);
     EMerr_hndlr(!(1&sts),*EMmsg,EMS_E_OMerror,wrapup);
   }

  /* If c = number of edges in the loop(count), i = index of refrence 
      edge. The order before deletion is:
			
			 E  E  . . . E    E  E    . . . E 
			  0  1        i-1  i  i+1        c-1
     Then after deletion of the refrence edge the order of edges in
      the loop becomes:
			
			 E   . . . E    E  E . . . E   
			  i+1       c-1  0  1       i-1
  */

  if(option == EMS_DEL_EDGE_RESTORE_LOOP)
  {
   if((index != 0) && (index != count - 1))
   {
    GRobjid neighbors;
    OMuword osnumaddr;
    OMuint loop_index;
    
    for(i = count - 1; i >= index + 1; i--)
    {
     sts = om$get_objid_at_index(osnum = OM_Gw_current_OS,
				objid = my_id,
				p_chanselect = &to_edges,
				index = i,
				objidaddr = &neighbors,
				osnumaddr = &osnumaddr);
     EMerr_hndlr(!(1&sts), *EMmsg, EMS_E_OMerror, wrapup);
     
     sts = om$get_index(osnum_c = OM_Gw_current_OS,
			objid_c = neighbors,
			p_chanselect = &to_loop,
			objid = my_id,
			osnum2 = OM_Gw_current_OS,
			indexaddr = &loop_index);
     EMerr_hndlr(!(1&sts), *EMmsg, EMS_E_OMerror, wrapup);
     
     sts = om$send(msg = message Root.disconnect(
		to_loop, my_id, OM_Gw_current_OS, to_edges),
				   targetid = neighbors);
     EMerr_hndlr(!(1&sts), *EMmsg, EMS_E_OMerror, wrapup);

     sts = om$send(msg = message Root.connect(
		to_loop, 0, my_id, OM_Gw_current_OS, to_edges, loop_index),
				  targetid = neighbors);
     EMerr_hndlr(!(1&sts), *EMmsg, EMS_E_OMerror, wrapup);
    } /* For loop */

   } /* If((index !=0) && (index != count -1)) */

   sts = om$send(msg = message Root.delete(TRUE),
			     targetid = ref_edge);
   EMerr_hndlr(!(1&sts), *EMmsg, EMS_E_OMerror, wrapup);
  }

  else /* option != EMS_DEL_EDGE_RESTORE_LOOP */
  {
   switch(option)
    {
     case EMS_INS_AFTER:
	 con = ME.EMSloop->lp_props & EMLP_REVERSED ? index : index + 1;
     break;
     
     case EMS_INS_BEFORE:
	 con = ME.EMSloop->lp_props & EMLP_REVERSED ? index + 1 : index;
     break;

     case EMS_INS_REPLACE:
	 con = ME.EMSloop->lp_props & EMLP_REVERSED ? index + 1 : index;
     break;

     default:
	 *EMmsg = EMS_E_InvalidArg;
     break;
   }

   if(ME.EMSloop->lp_props & EMLP_REVERSED)
    {
      for(i=0; i<num_edges;i++)
       {
  	 sts = om$send(msg = message Root.connect
		(to_edges,MAXINT, edge[i],OM_Gw_current_OS, to_loop,con),
		targetid = my_id);
	 EMerr_hndlr(!(1&sts), *EMmsg, EMS_E_OMerror, wrapup);
       }
     }
    else
     {
       for(i=(num_edges-1);i>=0;i--)
        {
  	  sts = om$send(msg = message Root.connect
		(to_edges, MAXINT, edge[i],OM_Gw_current_OS, to_loop,con),
		targetid = my_id);
	 EMerr_hndlr(!(1&sts), *EMmsg, EMS_E_OMerror, wrapup);
	}
      }
  
    if(option == EMS_INS_REPLACE)
     {
       sts = om$send(msg=message Root.disconnect(to_loop,my_id,
				OM_Gw_current_OS,to_edges),
				targetid = ref_edge);
       EMerr_hndlr(!(1&sts),*EMmsg,EMS_E_OMerror,wrapup);
     }
   } /* option != EMS_DEL_EDGE_RESTORE_LOOP */

/* Update the range of the loop.
*/
   if(update_range)
     sts = om$send(msg=message EMSloop.EMsetrange(EMmsg),
			targetid = my_id);

wrapup:
  EMWRAPUP(*EMmsg, sts, "In EMSloop.EMmodify_edge")
  return(sts);
}

end implementation EMSloop;
