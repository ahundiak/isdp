/* ###################   APOGEE COMPILED   ################## */
/*
Notes
	This method provides random access to the edges of a loop. It
  returns the next or the previous edge wrt to the reference edge.
	If the loop is open and there is no edge in the direction
  asked for (next/previous) then NULL_OBJID is returned. In case of an
  closed loop with only one edge, the same edge will be returned due to 
  circular wrapup.

Algorithm
	Find the index of the refernce edge on the channel 'to_edges'.
 	Determine the index of the edge in the direction asked for.If the
	loop is closed, use a circular list of edges.Return the objid of
	the edge at the suitable index.
	
Assumption
	With the option EMGetEd_NonDegenerate, it is assumed that this loop
	has atleast one non degenerate edge. If the loop has only one edge
	and it is degenerate then that loop must be of class EMSptloop and
	NOT of EMSloop.
		Also degenerate edges are assumed to be of class EMSptedge.
		
History
	SM	03/03/87	Creation date
	SM	02-Dec-87	made options argument a bit mask.
				see file emsgeteddef.h
*/

class implementation EMSloop;

#include "EMS.h"
#include "EMSopt.h"
#include "emsmacros.h"
#include "emsgeteddef.h"
#include "OMmacros.h"

#define INVALID_INDEX	-1

extern OMuword	OPP_EMSptedge_class_id;

from EMSedge import EMget_props;

method EMnext_edge(IGRlong *EMmsg; IGRushort option;
		   GRobjid ref_edge, *edge)
{
  IGRlong sts;
  OMuint count;
  IGRint index;
  OM_S_CHANSELECT to_edges;
  IGRboolean edge_found = FALSE;
  /*OMuword	edge_classid;*/
  GRobjid first_edge_found = NULL_OBJID;

  *EMmsg = EMS_S_Success;
  sts = OM_S_SUCCESS;

  to_edges.type = OM_e_addr;
  to_edges.u_sel.addr = &ME.EMSbd_owner->to_comps;

  sts = om$get_channel_count(object=me,p_chanselect=&to_edges,
                             count=&count);
  EMerr_hndlr(!(1&sts),*EMmsg,EMS_E_OMerror,wrapup);

  if(option & EMGetEd_First)
     index = ME.EMSloop->lp_props & EMLP_REVERSED ? count-1 : 0;
  else if(option & EMGetEd_Last)
     index = ME.EMSloop->lp_props & EMLP_REVERSED ? 0 : count-1;
  else
     sts = om$get_index(object_c = me, p_chanselect = &to_edges,
		     objid = ref_edge, osnum2 = OM_Gw_current_OS,
		     indexaddr = (OMuint *)&index);
  EMerr_hndlr(!(1&sts),*EMmsg,EMS_E_OMerror,wrapup);

  while(!edge_found)
   {
	
    if(option & EMGetEd_Next)
     {
      index = (ME.EMSloop->lp_props & EMLP_OPEN)&&(index==
                ((ME.EMSloop->lp_props&EMLP_REVERSED)? 0 :(count-1))) ?
              INVALID_INDEX :
              ( (ME.EMSloop->lp_props & EMLP_REVERSED) ? 
                  (index-1+(IGRint)count) : (index + 1));
       if(index!=INVALID_INDEX) index = index % (IGRint)count;
     }
    else if(option & EMGetEd_Previous)
     {
      index = (ME.EMSloop->lp_props & EMLP_OPEN)&&(index==
                ((ME.EMSloop->lp_props&EMLP_REVERSED) ? (count-1) : 0)) ?
               INVALID_INDEX:
               ( (ME.EMSloop->lp_props & EMLP_REVERSED) ? 
                  (index + 1) : (index - 1 + (IGRint)count));

      if(index!=INVALID_INDEX) index = index % (IGRint)count;
     }
    else if( !((option & EMGetEd_First) || (option & EMGetEd_Last)) )
     {
      *EMmsg = EMS_E_InvalidArg;
      goto wrapup;
     }


    if(index == INVALID_INDEX)
     {
       *EMmsg = EMS_I_OutOfBounds;
       *edge = NULL_OBJID;
       edge_found = TRUE;
     }
    else
     {
       sts = om$send(msg = message EMSboundary.EMget_objid(EMmsg, edge),
		p_chanselect = &to_edges,from=index,to=index);
       EMerr_hndlr(!(1&sts),*EMmsg,EMS_E_OMerror,wrapup);

       if(IF_NULL_OBJID(first_edge_found))
         first_edge_found = *edge;
       else if(IF_EQ_OBJID(first_edge_found, *edge))
        {
         *EMmsg = EMS_I_OutOfBounds;
         *edge = NULL_OBJID;
         edge_found = TRUE;
         break;
        }

       if(option & EMGetEd_NonDegenerate)
        {
	 IGRushort edprops;
	
	 sts = om$send(msg = message EMSedge.EMget_props(EMmsg, &edprops), 
	       targetid = *edge);
	 EMerr_hndlr(!(1&sts), *EMmsg, EMS_E_EdgeError, wrapup);
	
	 /*******
	  sts = om$get_classid(objid = *edge, p_classid = &edge_classid);
	  EMerr_hndlr(!(1&sts), *EMmsg, EMS_E_OMerror, wrapup);
	 *******/
	
	  /* If the caller wants non degenerate edge, then -
	    1) If first non degenerate edge is required, set the option
	       to EMGetEd_Next, so that we get the next non degenerate
	       edge if the first one happens to be degenerate. Similar
	       reasoning applies to the last edge being degenerate.
	    2) If the caller wants some non degenerate internal edge in 
	       relation to the reference edge then continue search till we
	       find one in the required direction.
			The assumption here is that the loop has atleast
	       one non degenerate edge.
	  */
	
	/* if(edge_classid != OPP_EMSptedge_class_id) edge_found = TRUE;*/
	  if(!(edprops & EMED_DEGENERATE)) edge_found = TRUE;
	  else
	   {
	     if(option & EMGetEd_First)
	      {
		option &= ~EMGetEd_First;
		option |= EMGetEd_Next;
		OM_BLOCK_MOVE(edge, &ref_edge, sizeof(GRobjid));
	      }
	     else if(option & EMGetEd_Last)
	      {
		option &= ~EMGetEd_Last;
		option |= EMGetEd_Previous;
		OM_BLOCK_MOVE(edge, &ref_edge, sizeof(GRobjid));
	      }
	
	   } /* if(edge_classid == OPP_EMSptedge_class_id) */
	
        } /* if(option & EMGetEd_NonDegenerate) */

       else edge_found = TRUE;

     }  /* if(index != INVALID_INDEX) */

  } /* While(!edge_found) */

wrapup:
  EMWRAPUP(*EMmsg, sts, "In EMSloop.EMnext_edge")
  return(sts);
}

end implementation EMSloop;
