/* ###################   APOGEE COMPILED   ################## */
/* This file contains special purpose functions related to the split vertex
   and splitting of the edges. They are not intended for general use unless
   their existing functionality is suitable for some application.

   SM	28-Dec-87	Creation.
*/

class implementation EMSedge;

#include "EMS.h"

#include "emsdef.h"
#include "OMmacros.h"
#include "emsgeteddef.h"

from EMSloop import EMset_props;
from EMSloop import EMnext_edge;

extern OMuword OPP_EMSpartedge_class_id;
extern OM_S_OBJID current_creator;

/* The following function replaces the existing edge which has the specified
   direction wrt the svtx, with the input edge. Since the old edge is now
   replaced, the split that created it is useless, so the split is
   undone.
*/

IGRlong EMmove_split(EMmsg, direction, edgeid, svtxid)
	IGRlong	*EMmsg;
	IGRint	direction;
	GRobjid	edgeid, svtxid;
{
  IGRlong		sts, rc;
  OM_S_CHANSELECT	to_edges, to_split;
  GRobjid		existing_edge = NULL_OBJID, 
			other_edge = NULL_OBJID;
  IGRint		idx, other_idx;
  OM_S_OBJID		ed_creator = NULL_OBJID;

  sts = OM_S_SUCCESS;
  *EMmsg = EMS_S_Success;

  idx = direction == INCOMING ? 0 : 1;
  other_idx = direction == INCOMING ? 1 : 0;

  sts = EMmake_chanselect (EMSedge_to_owner, &to_split);
  EMerr_hndlr(!(1&sts), *EMmsg, EMS_E_OMerror, wrapup);

  sts = EMmake_chanselect (EMSbd_owner_to_comps, &to_edges);
  EMerr_hndlr(!(1&sts), *EMmsg, EMS_E_OMerror, wrapup);

  /* Disconnect the existing edge at the appropriate index.
     Direction : INCOMING --- index 0
     Direction : OUTGOING --- index 1
  */
  sts = om$send(msg = message EMSboundary.EMget_objid(EMmsg, &existing_edge), 
				p_chanselect = &to_edges, senderid = svtxid, 
				from = idx, to = idx);
  EMerr_hndlr(!(1&*EMmsg&sts), *EMmsg, EMS_E_EdgeError, wrapup);
  sts = om$send(msg = message EMSboundary.EMget_objid(EMmsg, &other_edge), 
				p_chanselect = &to_edges, senderid = svtxid, 
				from = other_idx, to = other_idx);
  EMerr_hndlr(!(1&*EMmsg&sts), *EMmsg, EMS_E_EdgeError, wrapup);

  if(!IF_NULL_OBJID(existing_edge))
   {
     GRobjid	loop;
     
      loop = NULL_OBJID;
      sts = EMsend_loops(&rc,message EMSboundary.EMget_objid
			(EMmsg,&loop), existing_edge, 0, MAXINT,
                          EMLP_SPLIT, NULL, NULL);
      if(!(1&*EMmsg&sts)) goto wrapup;

      sts = om$send(msg = message Root.disconnect(to_split, svtxid, 
				OM_Gw_current_OS, to_edges), 
		senderid = svtxid, targetid = existing_edge);
      EMerr_hndlr(!(1&*EMmsg&sts), *EMmsg, EMS_E_OMerror, wrapup);

      /* The EMLP_SPLIT property of the active loop owning the existing
	 edge needs to checked and set.
      */
    
      if(!IF_NULL_OBJID(loop))
       {
	 IGRushort split;
	 IGRint		    i;
         OMuint          count;
	 sts = om$get_channel_count(objid = loop, p_chanselect = &to_edges, 
				    count = &count);
	 if(!(1&sts)) goto wrapup;
	 
	 /* Turn the split bit off. As soon as one is found with the split
	    connections, turn it on and break.
	 */
	 sts = om$send(msg = message EMSloop.EMset_props
					(EMmsg, EMLP_SPLIT, EMS_O_OFF), 
			senderid = loop, targetid = loop);
	 if(!(1&*EMmsg&sts)) goto wrapup;
	 for(i=0; i<count; i++)
	  {
	    split = NULL;
	    sts = om$send(msg = message EMSedge.EMissplit
				(EMmsg, &split, NULL), 
			senderid = loop, p_chanselect = &to_edges, 
			from = i, to = i);
	    if(!(1&*EMmsg&sts)) goto wrapup;
	    if(split)
	     {
	       sts = om$send(msg = message EMSloop.EMset_props
					(EMmsg, EMLP_SPLIT, EMS_O_ON), 
			    senderid = loop, targetid = loop);
	       if(!(1&*EMmsg&sts)) goto wrapup;
	       break;
	     }  
	  }/* for(i=0; i<count; i++) */

	 /* After moving the split, we need to unsplit the edge to undo the
	    effect of the split operation. For a split to have occured, the
	    existing edge must be a partedge, and the full edge owned by
	    it and the next/previous edge should be the same.
	    The unsplit message uses EMLP_SPLIT property. So turn it back on 
	    again.
	
	    4/28/93 - Added a check to see that the partedges were created
	    by the current creator. Else skip.
	 */
	 if (!split)
	  {
	   /******* Attn Ashok *************/
	   if(EFisAncestryValid(EMmsg, existing_edge, OM_Gw_current_OS, 
	      OPP_EMSpartedge_class_id, FALSE))
	    {
	     GRobjid	other_edge_in_loop = NULL_OBJID, 
	                previous_edge1 = NULL_OBJID, 
	                previous_edge2 = NULL_OBJID;

	     ed_creator = NULL_OBJID;
	     sts = om$send(msg = message EMSboundary.EMget_put_creator_id
	           (EMmsg, &ed_creator, FALSE), targetid = existing_edge, 
	           senderid = existing_edge);
	     if(!(1&*EMmsg&sts)) goto wrapup;
	
	     if( (!IF_NULL_OBJID(ed_creator)) && 
	         (!IF_EQ_OBJID(ed_creator, current_creator)))
	      goto skip_unsplit;
	
	     sts = om$send(msg = message EMSloop.EMnext_edge(EMmsg, 
	           idx == INCOMING ? EMGetEd_Next : EMGetEd_Previous, 
	           existing_edge, &other_edge_in_loop), senderid = loop, 
	           targetid = loop);
	     if(!(1&*EMmsg&sts)) goto wrapup;
        	
	     sts = om$send(msg = message EMSboundary.EMget_objid
			(EMmsg, &previous_edge1), p_chanselect = &to_edges, 
				senderid = existing_edge);
	     if(!(1&*EMmsg&sts)) goto wrapup;
	
	     if(EFisAncestryValid(EMmsg, other_edge_in_loop, OM_Gw_current_OS, 
	        OPP_EMSpartedge_class_id, FALSE))
	      {
  	       ed_creator = NULL_OBJID;
	       sts = om$send(msg = message EMSboundary.EMget_put_creator_id
	             (EMmsg, &ed_creator, FALSE), 
	             targetid = other_edge_in_loop, 
	             senderid = other_edge_in_loop);
	       if(!(1&*EMmsg&sts)) goto wrapup;
	
	       if( (!IF_NULL_OBJID(ed_creator)) && 
	           (!IF_EQ_OBJID(ed_creator, current_creator)))
	        goto skip_unsplit;
	
	       sts = om$send(msg = message EMSboundary.EMget_objid
			(EMmsg, &previous_edge2), p_chanselect = &to_edges, 
				senderid = other_edge_in_loop);
	       if(!(1&*EMmsg&sts)) goto wrapup;
	      }
	     if(IF_EQ_OBJID(previous_edge1, previous_edge2))
	      {
	       sts = om$send(msg = message EMSloop.EMset_props
					(EMmsg, EMLP_SPLIT, EMS_O_ON), 
			senderid = loop, targetid = loop);
	       if(!(1&*EMmsg&sts)) goto wrapup;
	       sts = om$send(msg = message EMSedge.EMunsplityourself
			(EMmsg, NULL), p_chanselect = &to_edges, 
				senderid = existing_edge);
	       sts = om$send(msg = message EMSloop.EMset_props
					(EMmsg, EMLP_SPLIT, EMS_O_OFF), 
			senderid = loop, targetid = loop);
	       if(!(1&*EMmsg&sts)) goto wrapup;
	      }
	    }
	  }
       }/* if(!IF_NULL_OBJID(loop)) */
   }

skip_unsplit:
  /* Connect the new edge at the appropriate index.
     if 'other edge' and the incoming edge already belong to the same active
     loop then no split connections are necessary. In such a case delete
     the split vertex and turn off relevant bits in the edges.
   */
  {
    GRobjid	loop1, loop2;

    loop1 = loop2 = NULL_OBJID;
    sts = EMsend_loops(&rc,message EMSboundary.EMget_objid
			(EMmsg,&loop1), edgeid, 0, MAXINT,
                          EMLP_ACTIVE, NULL, NULL);
    if(!(1&*EMmsg&sts)) goto wrapup;

    sts = EMsend_loops(&rc,message EMSboundary.EMget_objid
			(EMmsg,&loop2), other_edge, 0, MAXINT,
                          EMLP_ACTIVE, NULL, NULL);
    if(!(1&*EMmsg&sts)) goto wrapup;

    if( IF_EQ_OBJID(loop1, loop2) && (!IF_NULL_OBJID(loop1)) && 
       (!IF_NULL_OBJID(loop2)))
     {
	/*IGRushort	props;*/
	
        sts = om$send(msg = message Root.delete(TRUE), 
		      senderid = svtxid, targetid = svtxid);
	if(!(1&sts)) goto wrapup;
     }
    else
      sts = om$send(msg = message Root.connect(to_edges, NULL, edgeid, 
				OM_Gw_current_OS, to_split, idx), 
			senderid = edgeid, targetid = svtxid);
  }

wrapup:
	EMWRAPUP(*EMmsg, sts, "In EMmove_split");
	return(sts);
	
}



IGRint	EMconnect_split(EMmsg, in_edgeid, out_edgeid, svtxid, to_edges, 
			to_split)
	IGRlong		*EMmsg;
	GRobjid		in_edgeid, out_edgeid, svtxid;
	OM_S_CHANSELECT	*to_edges, *to_split;
{

   IGRlong		sts;
   OM_S_CHANSELECT	loc_to_edges, loc_to_split;

   sts = OM_S_SUCCESS;
   *EMmsg = EMS_S_Success;
   if(!to_split)
    {
     sts = EMmake_chanselect (EMSedge_to_owner, &loc_to_split);
     EMerr_hndlr(!(1&sts), *EMmsg, EMS_E_OMerror, wrapup);
     to_split = &loc_to_split;
    }
   if(!to_edges)
    {
     sts = EMmake_chanselect (EMSbd_owner_to_comps, &loc_to_edges);
     EMerr_hndlr(!(1&sts), *EMmsg, EMS_E_OMerror, wrapup);
     to_edges = &loc_to_edges;
    }

  /* Connect the incoming edge to the svtx ( on index 0 of the svtx)
   */

  sts = om$send(msg=message Root.connect(*to_edges, NULL, in_edgeid, 
			OM_Gw_current_OS, *to_split, INCOMING),
			targetid = svtxid, senderid = in_edgeid);
  if(!(1&sts)) goto wrapup;

  /* Connect the outgoing edge to the svtx (on index 1 of the svtx)
   */

  sts = om$send(msg=message Root.connect(*to_edges, NULL, out_edgeid,
			  OM_Gw_current_OS, *to_split, OUTGOING),
			  targetid = svtxid, senderid = out_edgeid);
  if(!(1&sts)) goto wrapup;


wrapup:
  EMWRAPUP(*EMmsg, sts, "In EMconnect_split");
  return(sts);
}

end implementation EMSedge;
