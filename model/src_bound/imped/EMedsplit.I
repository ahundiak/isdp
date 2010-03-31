/*
Notes
	This method splits an edge into two partedges at the given
  parameter.The original edge is replaced by two partedges in the loop(s)
  that used it.The properties of the original edge are given to the new
  partedges. These 
  properties are individually set in the two partedges depending on the
  connections to the split(if any). The EMED_OPEN bit is ON 
  and the EMED_XYZ_CLOSED bit is OFF for the two new partedges.
	If the split vertex connections are to be made then the EMLP_SPLIT
  bit is ON in the active loop that used this edge.

	Following are the arguments and their significance-

	split_info	input - info about the edge to be split and its 
				common edge if applicable.
        options   	input - EMSplitEd_SplitTopology
				EMSplitEd_MaintainAssoc
				see include/emsimpdef.h

	svtx		input - objid of a split object to be introduced
				when the edge is split. If the caller is
				not interested in putting a split object
				in place, then a NULL can be passed.In such
				a case, the two part edges still replace
				the original edge in its loop(s).
	edges		output- 2 partedge objids are returned. If svtx is
				specified then edges[0] is the partedge
				connected to the split and edges[1] is the
				partedge not connected to the split. If the
				split_param was at the begin or end of the
				original edge, then no split occurs, and
				the edges returned are NULL_OBJIDs if split
				connections are not to be made. The
				split connections are however made if svtx
				is specified and same convention is followed
				for returning the edges as for middle
				split.
	spliting_edge	input - objid of the edge that should be used to
				split the original edge. If svtx is
				specified, then spliting_edge must also be
				specified.If svtx is NULL, then the 
				spliting_edge is ignored and only the
				split_param is used.
	direction	input - direction of the spliting_edge wrt the edge
				being split.It can be either INCOMING or
				OUTGOING.The direction is ignored if
				svtx is NULL.
NOTE:
      If option is EMImpBnd_SplitTopology then the arguments split_info, svtx, 
      edges, splitting_edge, direction have one extra dimension.
      i.e, svtx[1], edges[2] and edges[3], splitting_edge[1], direction[1]
      and split_info[1] will now pertain to the topological partner
      of the edge receiving this message. The significance of these
      arguments will be as if the topological partner had received the
      message directly.

	part		information about the partedge.If the message is
			sent to a partedge,it initializes this structure
			and passes the same message down to its full edge.
			While sending this message from outside,the caller
			should specify NULL for this argument.
	partolbasis	input - The parametric tolerance to be used by the
				method.
        env                     Module environment of the surface. This
                                argument is meaningful only if
				EMImpBnd_SplitTopology and the partner_param is
                                not provided upon input. The model space
                                check to avoid degenerate splits is conducted
                                only if env is passed in.
	If the caller is just interested in splitting and not in the 
  connectivity of the split object and if the split param is at the begin
  or end of the edge, then no action is taken.

Assumption
	The connections to the split object(if specified by the caller),
  are according to the following convention - 
	From the split object's point of veiw, incoming edges are at its
  index 0 on the channel 'to_edges', and the outgoing edges are at index 1.
	The above convention is assumed in closing of the open loops , by
  splitting the appropriate edges of the existing loops.
	This convention is irrelevant to the caller if the intention is
  just to split an edge into two partedges at a parameter and not care
  about split connections(or closing after the split).

History
	SM	03/05/87	Creation date
	SS	09/25/87	If this is a model-space edge, then the
				split pieces are connected to this
				edge's associations.
	SM	11-Nov-87	Modified due to argument change in 'EMinsert_
				edge'. The 'update_range' flag is set to
				FALSE in calling this method.
	SM	14-May-88	Modified to take in the structure EMSsfintedpar
				instead of the split parameter by
				itself. The structure has all the info needed
				including split location.
				Also added code to do model space checks
				to avoid generation of near degenerate
				edges. This check is made only if env info
				is passed in.
	SM	16-Jun-88	If a decision is made that the split should
				not take place because split point matches
				an end point in model space then the splitting
				edge (if supplied) should be altered and
				the relevant end point should be inserted
				into it to avoid a gap in uv space between
				two edges of a loop.
	DLB	09/28/91	direction param (NULLL)was being read from even
				though was passed as NULL.  Check for direction
				not NULL in several places.  Crashes on SUN but
				problem on clipper as well.  
	SM	04/01/92        When trying to get split param for common edge
				don't care if the surface is absent as
				long as this is a seam edge.
	SM      05/26/93	Major changes to handle multiple incedences
	                        at the same point. Earlier the such points
	                        would be merged to simulate non-incedence. All
	                        the new code is executed only if the global 
	                        variable WANT_POST220_BEHAVIOR is set to TRUE. 
				If this flag is FALSE, old behavior is 
				maintained.
        Sudha   07/06/93        modified for BSprototype includes
*/

class implementation EMSedge;
#include "EMS.h"
#include "EMSopt.h"
#include "emsdef.h"
#include "emsmacros.h"
#include "OMmacros.h"
#include "emsgeteddef.h"
#include "EMSbnddef.h"
#include "emsinter.h"
#include "emssfint.h"
#include "bserr.h"
#include "bsparameters.h"
#include "emsimpdef.h"
#include "EMStpmacros.h"
#include "EMSutlmacros.h"
#include "bssfeval.h"
#include "bsdistptpt.h"
#include "emsedgedef.h"


#ifndef DEBUG
#define DEBUG	0
#endif

#if DEBUG
#define CHECK_TOL_FACTOR	1000
#else
#define CHECK_TOL_FACTOR	100
#endif

#if DEBUG
#include <stdio.h>
#endif

#define PtEdgeBuf 10

from EMSloop import EMmodify_edge, EMnext_edge, EMset_props, EMget_props;
from EMSpartedge import EMpeinit;

extern IGRboolean WANT_POST220_BEHAVIOR;

method EMsplityourself( IGRlong *EMmsg;
			struct EMSsfintedpar **split_info;
			IGRushort options;
			GRobjid *svtx,*edges,*spliting_edge;
			IGRint *direction;
			struct EMSpartedinfo *part;
			struct EMSpartolbasis *partolbasis;
			struct GRmd_env *env; GRobjid **ptedges;
			IGRint *num_ptedges, *ptedges_buf)
{
  IGRlong		sts,rc;
  IGRint		i;
  IGRdouble		begin_pt[2],end_pt[2], lentol, check_tol;
  OM_S_CHANSELECT	to_edges, to_owners, to_comm;
  struct EMSedgebound	bound[2], boundary[2], *split_param, *partner_param, 
                        otherbnd[2];
  IGRboolean		in_middle, on_left, on_interval;
  extern OMuword	OPP_EMSpartedge_class_id;
  GRobjid		old_split[2],user_id;
  IGRushort	        split, begin_ed_props, end_ed_props, user_props;
  IGRboolean		EMpar_on_edintvl(),split_connect, split_partner;
  IGRboolean		degn_split = FALSE, left_ornt_known = FALSE, 
                        right_ornt_known = FALSE, both_ornt_known = FALSE;

  IGRuchar	user_curve_type;
  enum EMScvinttype	*split_location[2], loc_split_loc[2], save_split_loc;
  struct EMSsfintedpar  loc_split_info, *loc_split_info_ptr;
  struct GRid		my_surf;
  struct IGRbsp_surface *my_surf_geom = NULL;
  GRobjid		loc_edges[4];
  IGRshort 		ptloc, otherptloc;
  IGRushort 		getedopt;
  IGRboolean		EMorient_coinc();

  *EMmsg = EMS_S_Success;
  sts = OM_S_SUCCESS;

 if(WANT_POST220_BEHAVIOR)
  {
   if(options & EMSplitEd_ClosureOnLeft)
    left_ornt_known = TRUE;
   else if(options & EMSplitEd_ClosureOnRight)
    right_ornt_known = TRUE;
   else if(options & EMSplitEd_ClosureBothSides)
    both_ornt_known = TRUE;
  }

  my_surf.objid = NULL_OBJID;
  my_surf.osnum = OM_Gw_current_OS;

  for(i=0; i<4; i++)  loc_edges[i] = NULL_OBJID;

  if(!edges) edges = (GRobjid *) loc_edges;
  split_partner = options & EMSplitEd_SplitTopology ? TRUE : FALSE;

  if((options & EMSplitEd_BeginDegenerateSplit) ||
     (options & EMSplitEd_EndDegenerateSplit))
   degn_split = TRUE;
  else degn_split = FALSE;

  if(part)
   {
     user_id = part->edid;
     user_props = part->edprops;
     user_curve_type = part->edtype;
   }
  else
   {
     user_id = my_id;
     user_props = ME.EMSedge->ed_props;
     user_curve_type = ME.EMSedge->curve_type;
   }


  loc_split_loc[0] = loc_split_loc[1] = EMScvint_unknown;

  split_connect = (svtx) ? (IF_NULL_OBJID(svtx[0]) ? FALSE : TRUE ) : FALSE;

  split_param = &split_info[0]->edgepar;
  partner_param = split_partner && split_info[1] ? &split_info[1]->edgepar 
						 : NULL;
  split_location[0] = IF_EQ_OBJID(split_info[0]->edgeid, user_id) ? 
				&split_info[0]->intloc : loc_split_loc;

/* Put NULL objid in output edges. If the returned value remains NULL_OBJID
   then it means an attempt was made to split the edge at its either end 
   points and no split vertex was specified. The caller wished just to
     split the edge into two and cannot do that at the endpoints.
*/

  /*if(!IF_NULL_OBJID(edges[0]))*/edges[0] = NULL_OBJID;
  /*if(!IF_NULL_OBJID(edges[1]))*/edges[1] = NULL_OBJID;

/* Get my bounds in the order of my direction.
*/
  sts = om$send(msg=message EMSedge.EMendpts(EMmsg, begin_pt, end_pt,
	  bound, &bound[1], part), targetid = my_id);
  if(!(1&*EMmsg&sts)) goto wrapup;

  /*
   * If the caller has not supplied the split location then determine it.
   */
  if(*(split_location[0]) == EMScvint_unknown)
   {
    if(!EMpar_on_edintvl(&rc, user_id, &bound[0], begin_pt, &bound[1], end_pt,
        split_param, split_info[0]->point, partolbasis, &on_interval, 
        &in_middle, &on_left))
     {*EMmsg=EMS_E_InvalidArg;goto wrapup;}
    if( (!in_middle)&&(on_left)) *(split_location[0]) = EMScvint_lfend;
    else if( (!in_middle)&&(!on_left)) *(split_location[0]) = EMScvint_rtend;
    else if(in_middle) *(split_location[0]) = EMScvint_middle;
    if(WANT_POST220_BEHAVIOR && (*(split_location[0]) != EMScvint_middle) &&
       direction && split_connect)
     {
      if(user_props & EMED_DEGENERATE)
       {
	if(direction[0] == INCOMING)
	 *(split_location[0]) = EMScvint_lfend;
	else
	 *(split_location[0]) = EMScvint_rtend;	
       }
     }
   }

  /* If the split location is middle and if the split point is within
     check-range from an end point then do a model space check to make sure
     the split is really needed. If the split point is within tolerance from
     the end point in model space then the split location should be treated
     as being at the begin or end. This will avoid the generation of near
     degenerate edges. The check is to be performed if the env info is 
     available and if the edge has a path to its surface.
  */
  if( (*(split_location[0]) != EMScvint_middle) || !env || degn_split)
   goto SkipXyzCheck;

  sts = om$send(msg=message EMSboundary.EMgetsurface_info(EMmsg, 
        &my_surf.objid, partolbasis->is_valid ? NULL : partolbasis), 
	targetid = user_id);
  if(!(1&*EMmsg&sts) || IF_NULL_OBJID(my_surf.objid)) goto SkipXyzCheck;

   {
    IGRdouble		dist1, dist2, closer_pt_xyz[3], 
			mindist_uv, *split_pt_uv, split_pt_xyz[3], xyztol, 
			*closer_pt_uv, mindist_xyz;
    IGRint 		put_at = UNKNOWN;

    sts = EFextract_par(BSTOLLENVEC, partolbasis->tol, &lentol, &rc);
    check_tol = CHECK_TOL_FACTOR * lentol;
    BSEXTRACTPAR(&rc, BSTOLLENVEC, xyztol);

    dist1 = EM2ddistptpt(split_info[0]->point, begin_pt);
    dist2 = EM2ddistptpt(split_info[0]->point, end_pt);
    mindist_uv = dist1 < dist2 ? dist1 : dist2;
    closer_pt_uv = dist1 < dist2 ? begin_pt : end_pt;

    /* If the split point is within tolerance in uv space then no model
       space check needs to be done.
    */
    if(mindist_uv < lentol)
      *(split_location[0]) = dist1<dist2 ? EMScvint_lfend :
						   EMScvint_rtend;
    else if(mindist_uv > check_tol) goto SkipXyzCheck;

    sts = om$send(msg = message EMSedge.EMxyz_endpt(EMmsg, &my_surf, 
          &env->md_env, begin_pt, end_pt, dist1<dist2 ? closer_pt_xyz : NULL, 
          dist1<dist2 ? NULL : closer_pt_xyz, &my_surf_geom), 
          targetid = user_id);
    if(!(1 & *EMmsg & sts)) goto SkipXyzCheck;

    split_pt_uv = split_info[0]->point;
    BSsfeval(my_surf_geom,split_pt_uv[0],split_pt_uv[1], 0, (IGRpoint *)split_pt_xyz, &rc);
    if(rc != BSSUCC) goto SkipXyzCheck;

    mindist_xyz = BSdistptpt(&rc, closer_pt_xyz, split_pt_xyz);
    if(mindist_xyz >= xyztol) goto SkipXyzCheck;

    save_split_loc = *(split_location[0]);
    *(split_location[0]) = dist1<dist2 ? EMScvint_lfend : EMScvint_rtend;
						
    /* If a spliting edge is supplied, then introduce the relevant
       end point into it to match the end point of this edge.
    */
    if(!spliting_edge) goto SkipXyzCheck;
		
    sts = om$send(msg = message EMSedge.EMextend_geom
          (EMmsg, closer_pt_uv, &put_at, FALSE, NULL, NULL, NULL, partolbasis,
           NULL, my_surf.objid == NULL_OBJID ? NULL : &my_surf, my_surf_geom, 
           env->md_env.matrix, &env->md_env.matrix_type),
           targetid = spliting_edge[0]);
			
   /* If problem in extending geometry then degenerate split
      is better than gap in uv.
   */
   if((!(1&*EMmsg&sts)) || (*EMmsg == EMS_I_NoSolution))
     *(split_location[0]) = save_split_loc;
	
  } /* if(!IF_NULL_OBJID(my_surf.objid) && (1&*EMmsg&sts)) */

SkipXyzCheck:
 *EMmsg = EMS_S_Success;
 sts = OM_S_SUCCESS;

/* If the split location is begin or end and no split connections are to
   be made then return.
*/
   if( ((*(split_location[0])==EMScvint_lfend)||
       (*(split_location[0])==EMScvint_rtend))&&(!split_connect))
	goto wrapup;

  sts = ems$make_chanselect (chan_label = EMSbd_owner_to_comps,
        chan_selector = &to_edges);
  if(!(1&sts)) goto wrapup;
  sts = ems$make_chanselect (chan_label = EMSedge_to_owner,
        chan_selector = &to_owners);
  sts = ems$make_chanselect (chan_label = EMSedge_to_common_edge,
        chan_selector = &to_comm);            

/* Set the bit in my loop indicating that it is split. The split bit is
   set on only if split connections are to be made. */

  if(split_connect)
   {
      sts = ems$send_loops(msg = &rc, message = message EMSloop.EMset_props
            (EMmsg,EMLP_SPLIT,EMS_O_ON), sender_edge = user_id, 
            all_mask = EMLP_ACTIVE);
      if(!(1&*EMmsg&sts)) goto wrapup;
   }

 /* If spliting a degenerate edge and establishing split connections, validate
    the location based on topology.
 */
 if(WANT_POST220_BEHAVIOR && split_connect && direction && 
    (user_props & EMED_DEGENERATE))
  {
   split = NULL;
   sts = om$send(msg=message EMSedge.EMissplit(EMmsg, &split, old_split),
	 targetid = user_id);
   if(!(1&*EMmsg&sts)) goto wrapup;
   if( (split & EMSedge_BeginSplit) && (split & EMSedge_EndSplit) &&
       !EMorient_coinc(EMmsg, old_split[BEGIN], BEGIN, NULL_OBJID, spliting_edge[0], &to_comm, 
	&to_edges, partolbasis, &ptloc, options, OM_Gw_current_OS) && 
       !EMorient_coinc(EMmsg, old_split[END], END, NULL_OBJID, spliting_edge[0], &to_comm, 
	&to_edges, partolbasis, &otherptloc, options, OM_Gw_current_OS))
    {
     if(ptloc != otherptloc)
      *(split_location[0]) = EMScvint_middle;
     else if( (direction[0] == INCOMING) && (ptloc == EMS_L_LEFT))
      *(split_location[0]) = EMScvint_rtend;
     else if( (direction[0] == INCOMING) && (ptloc == EMS_L_RIGHT))
      *(split_location[0]) = EMScvint_lfend;
     else if( (direction[0] == OUTGOING) && (ptloc == EMS_L_LEFT))
      *(split_location[0]) = EMScvint_lfend;
     else if( (direction[0] == OUTGOING) && (ptloc == EMS_L_RIGHT))
      *(split_location[0]) = EMScvint_rtend;
    }
  }

  switch (*(split_location[0]))
  {
    case EMScvint_lfend:

      if( direction && (direction[0] == INCOMING) && split_connect )
       {
         if(IF_NULL_OBJID(edges[0])) edges[0] = user_id;
	 if(IF_NULL_OBJID(edges[1]))
	  {
	   getedopt = EMGetEd_Previous;
           sts = ems$send_loops(msg = &rc, message = message 
                 EMSloop.EMnext_edge (EMmsg, getedopt, user_id, 
                 &edges[1]), sender_edge = user_id,
                 all_mask = EMLP_ACTIVE);
           if(! (1 & *EMmsg & sts)) goto wrapup;	
	  }
	 split = NULL;
 	 sts = om$send(msg=message EMSedge.EMissplit(EMmsg, &split, old_split),
	       targetid = edges[1]);
   	 if(!(1&*EMmsg&sts)) goto wrapup;
	
	 /* If the accompanying edge has a split vertex at the end then
	    replace it with the splitting edge in the connection to the
	    split vertex.
	
	    This used to be the old behavior. Still available optionally.
	  */
         ptloc = otherptloc = EMS_L_UNKNWN;

	 if( !left_ornt_known && (split & EMSedge_EndSplit) && 
	     !EMorient_coinc(EMmsg, old_split[END], END, NULL_OBJID, spliting_edge[0], &to_comm, 
			&to_edges, partolbasis, &ptloc, options, OM_Gw_current_OS))
	  {
	    if(!WANT_POST220_BEHAVIOR || (ptloc == EMS_L_UNKNWN) ||
             right_ornt_known || (!both_ornt_known && (ptloc == EMS_L_RIGHT)))
	     {
	      sts = EMmove_split(EMmsg, INCOMING, spliting_edge[0], 
	            old_split[END]);
	      EMerr_hndlr(!(1&*EMmsg&sts), *EMmsg, EMS_E_Fail, wrapup);
	    
	      sts = om$send(msg = message Root.delete(TRUE),targetid =svtx[0]);
 	      EMerr_hndlr(!(1&sts), *EMmsg, EMS_E_OMerror, wrapup);
	      svtx[0] = NULL_OBJID;
	      *EMmsg = EMS_I_AlreadySplit;
	     }
	    else if(!both_ornt_known && (ptloc == EMS_L_LEFT))
	     {
  	      /* If this edge is already connected to a split vertex, at the
	         end we are looking at, there is probably some orientation 
	         problem. So do not do any split connections, return 
	         EMS_I_IntersectOrient and let the caller decide further
	         action.
	      */
	      GRobjid	junk[2];
	      IGRushort splt = NULL;
	
   	      sts = om$send(msg=message EMSedge.EMissplit
		    (EMmsg, &splt, junk), targetid = user_id);
   	      if(!(1&*EMmsg&sts)) goto wrapup;

  	      if(splt & EMSedge_BeginSplit)
	       {
	        *EMmsg = EMS_I_IntersectOrient;
	        edges[0] = NULL_OBJID;
	        edges[1] = NULL_OBJID;
	       }
	      else
	       {
	        sts = om$send(msg=message Root.connect(to_edges,
	              NULL, spliting_edge[0], OM_Gw_current_OS, to_owners,
	              INCOMING), targetid = svtx[0]);
	        if(!(1&sts)) goto wrapup;
	        sts = om$send(msg=message Root.connect(to_edges,
		      NULL, user_id, OM_Gw_current_OS, to_owners, OUTGOING),
		      senderid = user_id,targetid = svtx[0]);
	        if(!(1&sts)) goto wrapup;
	       }
	     }
	    else
	     {
	      IGRushort locopt, edprops;
          
	      /* If the accompanying edge is degenerate, we need to determine
	         if the incedence should really be at the left end of that
	         edge. If that edge has split connections at the begin AND
	         end, then check to see if the splitting edge input in this
	         call lies BETWEEN those edges. If it does, we need to shift
	         the incedence to be the degenerate edge. This reasoning is 
	         consistent with treating degenerate cases as limits
	         of a typical incedence.
	      */
	      split_info[0]->intloc = EMScvint_middle;
	      locopt = options;
	
 	      sts = om$send(msg=message EMSedge.EMget_props(EMmsg, &edprops),
	            targetid = edges[1]);
   	      if(!(1&*EMmsg&sts)) goto wrapup;

              sts = om$send(msg=message EMSedge.EMendpts(EMmsg, NULL, NULL, 
                    otherbnd, &otherbnd[1], NULL), 
                    targetid = edges[1]);
              if(!(1&*EMmsg&sts)) goto wrapup;

	      if((edprops & EMED_DEGENERATE) && (split & EMSedge_BeginSplit) &&
	           !EMorient_coinc(EMmsg, old_split[BEGIN], BEGIN, NULL_OBJID, spliting_edge[0],
	                     &to_comm, &to_edges, partolbasis, &otherptloc, options, OM_Gw_current_OS) &&
	          (otherptloc != EMS_L_UNKNWN))
	       {
		/* The degenerate edge has two edges connected to it via
		   splits. Considering this situation as non-degenerate, the
		   incedence information on the degenerate edge can be deduced
		   as follows -
		
		   a) The two existing edges on OPPOSITE sides of the
		      new edge - incedence in the middle of the
		      degenerate edge.
		   b) BOTH the existing edges on the RIGHT of the new
		      edge - incedence at the LEFT end of the degenerate edge.
		   c) BOTH the existing edges on the LEFT of the new
		      edge - incedence at the RIGHT end of the degenerate edge.
		      noop for this case, since this also means the LEFT
		      end of the current incedent edge.
		*/
		if(otherptloc != ptloc) /* Incedence on degenerate edge */
		 {
	          split_info[0]->edgeid = edges[1];
	          split_info[0]->edgepar = otherbnd[0];
	         }
	        else if(otherptloc == EMS_L_RIGHT)
	         {
	          split_info[0]->edgeid = edges[1];
	          split_info[0]->intloc = EMScvint_lfend;
	          split_info[0]->edgepar = otherbnd[0];
	         }
	        else
	         {
		  locopt |= EMSplitEd_BeginDegenerateSplit;
                  split_info[0]->edgeid = user_id;
	         }
	       }
	      else if(ptloc == EMS_L_RIGHT)
	       {       
	        split_info[0]->edgeid = edges[1];
	        split_info[0]->edgepar = otherbnd[1];
	        locopt |= EMSplitEd_EndDegenerateSplit;
	       }
	      else
	       {
		locopt |= EMSplitEd_BeginDegenerateSplit;
                split_info[0]->edgeid = user_id;
	       }
	
	      edges[0] = edges[1] = NULL_OBJID;
	
	      sts = om$send(msg = message EMSedge.EMsplityourself
		    (EMmsg, split_info, locopt, svtx, edges, spliting_edge, 
		     direction, NULL, partolbasis, env, ptedges, num_ptedges, 
		     ptedges_buf), 
		    targetid = split_info[0]->edgeid);
              if(! (1 & *EMmsg & sts)) goto wrapup;
	     }
	  }
	 else
	  {
	    /* If this edge is already connected to a split vertex, at the
	       end we are looking at, there is probably some orientation 
	       problem. So do not do any split connections, return 
	       EMS_I_IntersectOrient and let the caller decide further
	       action.
	    */
	    GRobjid	junk[2];
	    IGRushort splt = NULL;
	
 	    sts = om$send(msg=message EMSedge.EMissplit
		  (EMmsg, &splt, junk), targetid = user_id);
   	    if(!(1&*EMmsg&sts)) goto wrapup;

	    if(splt & EMSedge_BeginSplit)
	     {
	      *EMmsg = EMS_I_IntersectOrient;
	      edges[0] = NULL_OBJID;
	      edges[1] = NULL_OBJID;
	     }
	    else
	     {
	      sts = om$send(msg=message Root.connect(to_edges,
	            NULL, spliting_edge[0], OM_Gw_current_OS, to_owners,
	            INCOMING), targetid = svtx[0]);
	       if(!(1&sts)) goto wrapup;
	      sts = om$send(msg=message Root.connect(to_edges,
		    NULL, user_id, OM_Gw_current_OS, to_owners, OUTGOING),
		    senderid = user_id,targetid = svtx[0]);
	      if(!(1&sts)) goto wrapup;
	     }
	  }
       }
      else if( direction && (direction[0]==OUTGOING) && split_connect )
       {
	 if(IF_NULL_OBJID(edges[1])) edges[1] = user_id;
	 if(IF_NULL_OBJID(edges[0]))
	  {
	   getedopt = EMGetEd_Previous;
           sts = ems$send_loops(msg = &rc,message = message EMSloop.EMnext_edge
                 (EMmsg, getedopt, user_id, &edges[0]),
                  sender_edge = user_id, all_mask = EMLP_ACTIVE);  
           if(! (1 & *EMmsg & sts)) goto wrapup;
	  }
	 split_info[0]->intloc = EMScvint_rtend;
	 split_info[0]->edgeid = edges[0];
	
         sts = om$send(msg=message EMSedge.EMendpts(EMmsg, NULL, NULL, 
               NULL, &split_info[0]->edgepar, NULL), targetid = edges[0]);
         if(!(1&*EMmsg&sts)) goto wrapup;
	
	 sts = om$send(msg = message EMSedge.EMsplityourself
	       (EMmsg, split_info, options, svtx, edges, spliting_edge, 
	        direction, NULL, partolbasis, env, ptedges, num_ptedges, 
	        ptedges_buf), targetid = edges[0]);
         if(! (1 & *EMmsg & sts)) goto wrapup;
       }
      break;

    case EMScvint_rtend:

      if( direction && (direction[0] == INCOMING) && split_connect )
       {
	 if(IF_NULL_OBJID(edges[1])) edges[1] = user_id;
	 if(IF_NULL_OBJID(edges[0]))
	  {
	   getedopt = EMGetEd_Next;
           sts = ems$send_loops(msg = &rc,message = message EMSloop.EMnext_edge
                 (EMmsg, getedopt, user_id, &edges[0]),sender_edge = user_id,
                 all_mask = EMLP_ACTIVE); 
           if(! (1 & *EMmsg & sts)) goto wrapup;
	  }
	 split_info[0]->intloc = EMScvint_lfend;
	 split_info[0]->edgeid = edges[0];
	
         sts = om$send(msg=message EMSedge.EMendpts(EMmsg, NULL, NULL, 
               &split_info[0]->edgepar, NULL, NULL), targetid = edges[0]);
         if(!(1&*EMmsg&sts)) goto wrapup;
	
	 sts = om$send(msg = message EMSedge.EMsplityourself
	       (EMmsg, split_info, options, svtx, edges, spliting_edge, 
	       direction, NULL, partolbasis, env, ptedges, num_ptedges, 
	       ptedges_buf), targetid = edges[0]);
         if(! (1 & *EMmsg & sts)) goto wrapup;
       }
      else if( direction && (direction[0]==OUTGOING) && split_connect )
       {
         if(IF_NULL_OBJID(edges[0])) edges[0] = user_id;
	 if(IF_NULL_OBJID(edges[1])) 
	  {
	   getedopt = EMGetEd_Next;
           sts = ems$send_loops(msg = &rc,message = message EMSloop.EMnext_edge
                 (EMmsg, getedopt, user_id, &edges[1]),sender_edge = user_id,
                 all_mask = EMLP_ACTIVE);
           if(! (1 & *EMmsg & sts)) goto wrapup;
	  }
	 split = NULL;
   	 sts = om$send(msg=message EMSedge.EMissplit(EMmsg,&split,old_split),
   	       targetid = edges[1]);
   	 if(!(1&*EMmsg&sts)) goto wrapup;

	 /* If the accompanying edge has a split vertex at the begin then
	    replace it with the splitting edge.
	  */
	
         ptloc = otherptloc = EMS_L_UNKNWN;

	 if( !left_ornt_known && (split & EMSedge_BeginSplit) && 
	    !EMorient_coinc(EMmsg, old_split[BEGIN], BEGIN, NULL_OBJID, spliting_edge[0], 
	              &to_comm, &to_edges, partolbasis, &ptloc, options, OM_Gw_current_OS))
	  {
	   if(!WANT_POST220_BEHAVIOR || (ptloc == EMS_L_UNKNWN) ||
	      right_ornt_known || (!both_ornt_known && (ptloc == EMS_L_RIGHT)))
	    {
	     sts = EMmove_split(EMmsg, OUTGOING, spliting_edge[0], 
	           old_split[BEGIN]);
	     EMerr_hndlr(!(1&*EMmsg&sts), *EMmsg, EMS_E_Fail, wrapup);
	
	     sts = om$send(msg = message Root.delete(TRUE),targetid = svtx[0]);
 	     EMerr_hndlr(!(1&sts), *EMmsg, EMS_E_OMerror, wrapup);
	     svtx[0] = NULL_OBJID;
	     *EMmsg = EMS_I_AlreadySplit;
	    }
	   else if(!both_ornt_known && (ptloc == EMS_L_LEFT))
	    {
	      /* If this edge is already connected to a split vertex, at the
	         end we are looking at, there is probably some orientation 
	         problem. So do not do any split connections, return 
	         EMS_I_IntersectOrient and let the caller decide further
	         action.
	      */
	      GRobjid	junk[2];
	      IGRushort splt = NULL;
	
   	      sts = om$send(msg=message EMSedge.EMissplit
		    (EMmsg, &splt, junk), targetid = user_id);
   	      if(!(1&*EMmsg&sts)) goto wrapup;
	      if(splt & EMSedge_EndSplit)
	       {	
	        *EMmsg = EMS_I_IntersectOrient;
	        edges[0] = NULL_OBJID;
	        edges[1] = NULL_OBJID;
	       }
	      else
	       {
	        sts = om$send(msg=message Root.connect(to_edges,
		      NULL,user_id,OM_Gw_current_OS,to_owners,INCOMING),
	              targetid = svtx[0]);
	        if(!(1&sts)) goto wrapup;
	        sts = om$send(msg=message Root.connect(to_edges,
		      NULL,spliting_edge[0],OM_Gw_current_OS,
	              to_owners,OUTGOING), targetid = svtx[0]);
	        if(!(1&sts)) goto wrapup;
	       }
	    }
	   else
	    {
              IGRushort locopt, edprops;
  
	      /* Split the accompanying edge by treating this as a topological
	         non-coincedence. This will cause no merging of the coincedent
	         point and force a split.
	
	         If the accompanying edge is degenerate, special processing 
	         is required. See the analogous case for lfend/incoming above.
	      */
	      split_info[0]->intloc = EMScvint_middle;
	      locopt = options;
	
 	      sts = om$send(msg=message EMSedge.EMget_props(EMmsg, &edprops),
	            targetid = edges[1]);
   	      if(!(1&*EMmsg&sts)) goto wrapup;

              sts = om$send(msg=message EMSedge.EMendpts(EMmsg, NULL, NULL, 
                    otherbnd, &otherbnd[1], NULL), 
                    targetid = edges[1]);
              if(!(1&*EMmsg&sts)) goto wrapup;

	      if((edprops & EMED_DEGENERATE) && (split & EMSedge_EndSplit) &&
	           !EMorient_coinc(EMmsg, old_split[END], END, NULL_OBJID, spliting_edge[0],
	                     &to_comm, &to_edges, partolbasis, &otherptloc, options, OM_Gw_current_OS) &&
	          (otherptloc != EMS_L_UNKNWN))
	       {
		/* The degenerate edge has two edges connected to it via
		   splits. Considering this situation as non-degenerate, the
		   incedence information on the degenerate edge can be deduced
		   as follows -
		
		   a) The two existing edges on OPPOSITE sides of the
		      new edge - incedence in the middle of the
		      degenerate edge.
		   b) BOTH the existing edges on the RIGHT of the new
		      edge - incedence at the RIGHT end of the degenerate edge.
		   c) BOTH the existing edges on the LEFT of the new
		      edge - incedence at the LEFT end of the degenerate edge.
		      noop for this case, since this also means the RIGHT
		      end of the current incedent edge.
		*/
		if(otherptloc != ptloc) /* Incedence on degenerate edge */
		 {
	          split_info[0]->edgeid = edges[1];
	          split_info[0]->edgepar = otherbnd[0];
	         }
	        else if(otherptloc == EMS_L_RIGHT)
	         {
	          split_info[0]->edgeid = edges[1];
	          split_info[0]->intloc = EMScvint_rtend;
	          split_info[0]->edgepar = otherbnd[1];	
	         }
	        else
	         {
		  locopt |= EMSplitEd_EndDegenerateSplit;
		  split_info[0]->edgeid = user_id;
		 }
	       }
	      else if(ptloc == EMS_L_RIGHT)
	       {
		locopt |= EMSplitEd_BeginDegenerateSplit;
	        split_info[0]->edgeid = edges[1];
	        split_info[0]->edgepar = otherbnd[0];
	       }
	      else
	       {
		locopt |= EMSplitEd_EndDegenerateSplit;
		split_info[0]->edgeid = user_id;
	       }
	
	      edges[0] = edges[1] = NULL_OBJID;
	
	      sts = om$send(msg = message EMSedge.EMsplityourself
		    (EMmsg, split_info, locopt, svtx, edges, spliting_edge, 
		     direction, NULL, partolbasis, env, ptedges, num_ptedges, 
		     ptedges_buf), 
	            targetid = split_info[0]->edgeid);
              if(! (1 & *EMmsg & sts)) goto wrapup;
	    }
	  }
	 else
	  {
	    /* If this edge is already connected to a split vertex, at the
	       end we are looking at, there is probably some orientation 
	       problem. So do not do any split connections, return 
	       EMS_I_IntersectOrient and let the caller decide further
	       action.
	    */
	    GRobjid	junk[2];
	    IGRushort splt = NULL;
	
 	    sts = om$send(msg=message EMSedge.EMissplit
		  (EMmsg, &splt, junk), targetid = user_id);
   	    if(!(1&*EMmsg&sts)) goto wrapup;
	    if(splt & EMSedge_EndSplit)
	     {	
	      *EMmsg = EMS_I_IntersectOrient;
	      edges[0] = NULL_OBJID;
	      edges[1] = NULL_OBJID;
	     }
	    else
	     {
	      sts = om$send(msg=message Root.connect(to_edges,
		    NULL,user_id,OM_Gw_current_OS,to_owners,INCOMING),
	            targetid = svtx[0]);
	      if(!(1&sts)) goto wrapup;
	      sts = om$send(msg=message Root.connect(to_edges,
		    NULL,spliting_edge[0],OM_Gw_current_OS,
	            to_owners,OUTGOING), targetid = svtx[0]);
	      if(!(1&sts)) goto wrapup;
	     }
	  }
       }
      break;

    case EMScvint_middle:
    {
      OM_S_CHANSELECT		to_edge;
      GRobjid			new_edge[2];
      OMuint			count;
      IGRuchar		        new_curve_type;

      split = NULL;
      sts = om$send(msg=message EMSedge.EMissplit(EMmsg,&split,old_split),
	    targetid = user_id);
      if(!(1&*EMmsg&sts)) goto wrapup;

      sts = ems$make_chanselect (chan_label = EMSbd_owner_to_comps,
            chan_selector = &to_edge);
      if(!(1&sts)) goto wrapup;

/* Decide the curve_type for the part edges to be constructed, based on the
   curve_type of the parent.
*/
      sts = EFget_clipped_edge_type(EMmsg, user_curve_type, &new_curve_type);
      EMerr_hndlr(!(1&*EMmsg&sts), *EMmsg, EMS_E_Fail, wrapup);

/* Construct two part edges.
   new_edge[0] - part edge formed by compressing me.
   new_edge[1] - the other part edge
*/
      boundary[0] = bound[0];
      boundary[1] = *split_param;

      begin_ed_props = user_props;
      begin_ed_props &= ~EMED_XYZ_CLOSED & ~EMED_COMPATIBLE & ~EMED_MSCEXISTS;
      begin_ed_props |= EMED_OPEN;

      end_ed_props = begin_ed_props;

      if(options & EMSplitEd_BeginDegenerateSplit)
       begin_ed_props |= EMED_DEGENERATE;

      if(options & EMSplitEd_EndDegenerateSplit)
       end_ed_props |= EMED_DEGENERATE;

      sts = om$construct(classid=OPP_EMSpartedge_class_id,p_objid=new_edge,
	    msg = message EMSpartedge.EMpeinit
	    (EMmsg, begin_ed_props, boundary, 
       (options & EMSplitEd_BeginDegenerateSplit) ? EMpoint : new_curve_type));
      if(!(1&sts)) goto wrapup;

      boundary[0] = *split_param;
      boundary[1] = bound[1];      
      sts = om$construct(classid=OPP_EMSpartedge_class_id,p_objid=&new_edge[1],
	    msg = message EMSpartedge.EMpeinit
		  (EMmsg, end_ed_props, boundary, 
	(options & EMSplitEd_EndDegenerateSplit) ? EMpoint : new_curve_type));
      if(!(1&sts)) goto wrapup;

      /* Record the redundant topology created (the degenerate edges)
      */
      if(ptedges && num_ptedges && ptedges_buf &&
         ( (options & EMSplitEd_BeginDegenerateSplit) ||
           (options & EMSplitEd_EndDegenerateSplit)))
       {
	if(*ptedges_buf < 2)
	 {
	  if(!*ptedges)
	   *ptedges = (GRobjid *) om$malloc(size = PtEdgeBuf *sizeof(GRobjid));
	  else
	   *ptedges = (GRobjid *) om$realloc(ptr = (IGRchar *) *ptedges, 
	              size = (*num_ptedges + PtEdgeBuf) * sizeof(GRobjid));
	  EMerr_hndlr(!*ptedges, *EMmsg, EMS_E_NoDynamicMemory, wrapup);
	  *ptedges_buf = PtEdgeBuf;
	 }
	
	if(options & EMSplitEd_BeginDegenerateSplit)
	 {
	  (*ptedges)[*num_ptedges] = new_edge[0];
	  (*num_ptedges)++;
	  (*ptedges_buf)--;
	 }
	
	if(options & EMSplitEd_EndDegenerateSplit)
	 {
	  (*ptedges)[*num_ptedges] = new_edge[1];
	  (*num_ptedges)++;
	  (*ptedges_buf)--;
	 }
       }

/* connect the two partedges to me
*/
      sts = om$get_channel_count(objid=user_id,p_chanselect=&to_owners,
		 count=&count);
      if(!(1&sts)) goto wrapup;
      for(i=0;i<2;i++)
       {
         sts = om$send(msg=message Root.connect(to_edge,count,user_id,
	       OM_Gw_current_OS,to_owners,NULL),
	       senderid = user_id,targetid = new_edge[i]);
         if(!(1&sts)) goto wrapup;
	 count++;
       }


/* If I had any splitvertex connections at the end, transfer it
   as the end connection of the new edge[1].
   Similarly if I had any splitvertex at the begining transfer it as the
   begin of new edge[0].
*/
			
        if(split & EMSedge_EndSplit)  /* split vertex */
         {
           sts = om$send(msg=message Root.disconnect(to_edges, user_id,
                 OM_Gw_current_OS,to_owners),
                 senderid=user_id,targetid=old_split[END]);
           if(!(1&sts)) goto wrapup;
           sts = om$send(msg=message Root.connect(to_edges, NULL, new_edge[1],
                 OM_Gw_current_OS, to_owners,INCOMING),
                 targetid=old_split[END]);
           if(!(1&sts)) goto wrapup;
         }
	if(split & EMSedge_BeginSplit)
	 {
           sts = om$send(msg=message Root.disconnect(to_edges,
                             user_id,OM_Gw_current_OS,to_owners),
                             senderid=user_id,targetid=old_split[BEGIN]);
           if(!(1&sts)) goto wrapup;
           sts = om$send(msg=message Root.connect
                        (to_edges,NULL,new_edge[0],OM_Gw_current_OS,
			 to_owners,OUTGOING),targetid=old_split[BEGIN]);
           if(!(1&sts)) goto wrapup;
	 }

/* If the spliting edge is OUTGOING then the splitvertex is end of the 
   new_edge[0] and begin of the spliting edge. 
*/
     if( direction && (direction[0]==OUTGOING) && split_connect)
      {
	sts = om$send(msg=message Root.connect(to_edges,NULL,
			new_edge[0],OM_Gw_current_OS,to_owners,INCOMING),
			targetid = svtx[0]);
	if(!(1&sts)) goto wrapup;
	sts = om$send(msg=message Root.connect(to_edges,NULL,
			spliting_edge[0],OM_Gw_current_OS,to_owners,OUTGOING),
			targetid = svtx[0]);
	if(!(1&sts)) goto wrapup;
	edges[0] = new_edge[0];
	edges[1] = new_edge[1];
      }
/* If the spliting edge is INCOMING then the splitvertex is begin of the 
   new_edge[1] and end of the spliting edge. 
*/
     else if( direction && (direction[0]==INCOMING) && split_connect)
      {
	sts = om$send(msg=message Root.connect(to_edges,NULL,
			spliting_edge[0],OM_Gw_current_OS,to_owners,INCOMING),
			targetid = svtx[0]);
	if(!(1&sts)) goto wrapup;
	sts = om$send(msg=message Root.connect(to_edges,NULL,
			new_edge[1],OM_Gw_current_OS,to_owners,OUTGOING),
			targetid = svtx[0]);
	if(!(1&sts)) goto wrapup;
	edges[0] = new_edge[1];
	edges[1] = new_edge[0];
      }
     else
      {
/* If the caller is not interested in splitvertex and its relationship
   with the two edges then just return the ids of the edges formed as a
   result of the split
*/
	edges[0] = new_edge[0];
	edges[1] = new_edge[1];
      }

/* If the caller wants the topological partner to be split then take
   care of that.
*/
    if(split_partner)
     {
       OM_S_CHANSELECT		to_common_edge;
       struct EMSedgebound	other_param;
       IGRint			other_con[2];
       OMuint                   count;
       GRobjid			other_surf,other_edges[2];
       IGRushort	commoptions = NULL;

        sts = ems$make_chanselect (
                       chan_label = EMSedge_to_common_edge,
                       chan_selector = &to_common_edge);
	EMerr_hndlr(!(1&sts),*EMmsg,EMS_E_OMerror,wrapup);
	sts = om$get_channel_count(objid=user_id,p_chanselect=&to_common_edge,
				   count = &count);
	EMerr_hndlr(!(1&sts),*EMmsg,EMS_E_OMerror,wrapup);
	if(count)
         {
	  if( (partner_param) && (partner_param->param != UNKNOWN))
	    other_param = *partner_param;
	  else
	   {
	     other_surf = NULL_OBJID;
	
	     sts = om$send(msg = message EMSboundary.EMgetsurface_info
				(EMmsg, &other_surf, NULL), 
			senderid = user_id, p_chanselect = &to_common_edge);
	     EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_EdgeError,wrapup);
	
	     if( (IF_NULL_OBJID(other_surf)) && (!(user_props & EMED_SEAM))) 
	      count = 0;
	     else
	      {
	       sts = om$send(msg=message EMSedge.EMtwin_crv_parm
			(EMmsg, split_param, &other_param, env,
			UNKNOWN, &my_surf.objid, &other_surf),
			targetid = user_id);
	       EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_EdgeError,wrapup);
	       if(partner_param) *partner_param = other_param;
	      }
	    }
	  }
	
	 if(count)
	  {
		
/* Split my topological partner
*/
          if(!split_info[1])
           {
	    if(WANT_POST220_BEHAVIOR && (degn_split || 
	                              (user_props & EMED_DEGENERATE)))
 	      loc_split_info.intloc = EMScvint_middle;
            else
 	     loc_split_info.intloc = EMScvint_unknown;

	    sts = om$send(msg = message EMSboundary.EMget_objid
					(EMmsg, &loc_split_info.edgeid), 
				senderid = user_id,
				p_chanselect = &to_common_edge);
	    EMerr_hndlr(!(1&*EMmsg&sts), *EMmsg, EMS_E_EdgeError, wrapup);
	    loc_split_info.edgepar = other_param;
  	    sts = om$send(msg = message EMSedge.EMptatpr(EMmsg, 1,
                          &other_param, NULL, loc_split_info.point),
                    p_chanselect = &to_common_edge, senderid = user_id);
	    EMerr_hndlr(!(1&*EMmsg&sts), *EMmsg, EMS_E_EdgeError, wrapup);
	    loc_split_info.info = NULL;
	    loc_split_info.next = NULL;
	    loc_split_info_ptr = &loc_split_info;
	    split_location[1] = &loc_split_info.intloc;
           }
	  else
	   {
	    loc_split_info_ptr = split_info[1];
	    split_location[1] = &split_info[1]->intloc;
	   }
	  commoptions = options;
	  commoptions &= ~EMSplitEd_SplitTopology & 
	                 ~EMSplitEd_BeginDegenerateSplit &
	                 ~EMSplitEd_EndDegenerateSplit;

	  if(options & EMSplitEd_BeginDegenerateSplit)
	   {
	    if(user_props & EMED_REVERSE_CONNECT)
	     commoptions |= EMSplitEd_EndDegenerateSplit;
	    else
	     commoptions |= EMSplitEd_BeginDegenerateSplit;
	   }
	  else if(options & EMSplitEd_EndDegenerateSplit)
	   {
	    if(user_props & EMED_REVERSE_CONNECT)
	     commoptions |= EMSplitEd_BeginDegenerateSplit;
	    else
	     commoptions |= EMSplitEd_EndDegenerateSplit;
	   }
          else if(WANT_POST220_BEHAVIOR && (user_props & EMED_DEGENERATE))
           commoptions |= EMSplitEd_EndDegenerateSplit | 
                          EMSplitEd_BeginDegenerateSplit;
	  sts = om$send(msg=message EMSedge.EMsplityourself(EMmsg,
			 &loc_split_info_ptr, commoptions, 
  			 (svtx ? &svtx[1] : NULL), &edges[2],
	 		 &spliting_edge[1], 
			 (direction ? &direction[1] : NULL), NULL, partolbasis, 
			 env, ptedges, num_ptedges, ptedges_buf), 
			senderid = user_id, 
			p_chanselect = &to_common_edge);
	  EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_EdgeError,wrapup);

/* Split should occur in the middle for both the edges, 
   otherwise we are violating topology. This could
   potentially happen due to tolerance problems as in the following
   scenario -

   Edge A and B are common on a single surface (seam edges). An intersection
   spans across the UV space and cuts both of them. Typically the
   split parameter on A = 1 - split parameter on B. If this is exactly TRUE
   then when B tries to split itself it finds itself already split by A and
   does nothing. However due to tolerance if B splits itself again when
   it should not have then we have a problem. In such a case undo the damage
   pretend no splits occured. This is a topological check and should be
   less prone to errors.
*/
	if(*(split_location[1]) != EMScvint_middle)
    	 {
	   /* Disconnect the split vertex connections
	   */
	   sts = om$send(msg=message Root.wild_disconnect(to_edges), 
			targetid = svtx[0]);
	   if(!(1&sts)) goto wrapup;

	   /* Restore the transfered split connections 
	   */
           if(split & EMSedge_EndSplit)  /* split vertex */
            {
              sts = om$send(msg=message Root.disconnect(to_edges,
                             new_edge[1], OM_Gw_current_OS,to_owners),
                             senderid = new_edge[1],targetid = old_split[END]);
              if(!(1&sts)) goto wrapup;
              sts = om$send(msg=message Root.connect
                        (to_edges,NULL, user_id, OM_Gw_current_OS,
			 to_owners, INCOMING),targetid = old_split[END]);
              if(!(1&sts)) goto wrapup;
            }
	   if(split & EMSedge_BeginSplit)
	    {
              sts = om$send(msg=message Root.disconnect(to_edges,
                             new_edge[0], OM_Gw_current_OS, to_owners),
                             senderid = new_edge[0],targetid=old_split[BEGIN]);
              if(!(1&sts)) goto wrapup;
              sts = om$send(msg=message Root.connect
                        (to_edges, NULL, user_id, OM_Gw_current_OS,
			 to_owners, OUTGOING), targetid=old_split[BEGIN]);
              if(!(1&sts)) goto wrapup;
	    }

	   /* Delete the two partedges formed. */
	   for(i=0; i<2; i++)   
	    {
	      sts = om$send(mode = OM_e_wrt_message, 
			    msg = message Root.delete(TRUE), 
			targetid = edges[i]);
	      EMerr_hndlr(!(1&sts), *EMmsg, EMS_E_OMerror, wrapup);
	      edges[i] = new_edge[i] = NULL_OBJID;
	    }
	
	   /* Now that the harm of the undue split is undone, decide the
	      topologically correct split location and send the same message
	      to the user id.
	   */
	
	   if(*(split_location[1]) == EMScvint_lfend)
	    {
	      if(user_props & EMED_REVERSE_CONNECT)
	        *(split_location[0]) = EMScvint_rtend;
	      else *(split_location[0]) = EMScvint_lfend;
	    }
	   else if(*(split_location[1]) == EMScvint_rtend)
	    {
	      if(user_props & EMED_REVERSE_CONNECT)
	        *(split_location[0]) = EMScvint_lfend;
	      else *(split_location[0]) = EMScvint_rtend;
	      
	    }
	   else { *EMmsg = EMS_E_InvalidArg; goto wrapup;}
		
   	   sts = om$send(msg = message EMSedge.EMsplityourself
				(EMmsg, split_info, options, 
				 svtx, edges, spliting_edge, 
				 direction, part,
				 partolbasis, env, ptedges, num_ptedges, 
				 ptedges_buf), targetid = my_id);
           if(! (1 & *EMmsg & sts)) goto wrapup;
   	 }
	else
	 {
/* Get the two edges in proper order: 0 - being the edge formed by 
   compression and 1 being the other edge.
*/
          split_connect = (svtx) ? (IF_NULL_OBJID(svtx[1]) ? FALSE : TRUE ) 
			   : FALSE;
          if( direction && (direction[1] == INCOMING) && split_connect)
	    {
	      other_edges[0] = edges[3];
	      other_edges[1] = edges[2];
	    }
	  else 
	     OM_BLOCK_MOVE(&edges[2],other_edges,2*sizeof(GRobjid));
	

/* Re-establish the notorious topology for which all this trouble was
   taken.
*/
	  if(user_props & EMED_REVERSE_CONNECT)
  	    {
		other_con[0] = 1;
		other_con[1] = 0;
	    }
	   else
	    {
		other_con[0] = 0;
		other_con[1] = 1;
	    }
	   for(i=0;i<2;i++)
	    {
	      if(IF_NULL_OBJID(other_edges[other_con[i]])) continue;
	
	      sts = om$send(msg=message Root.connect(to_common_edge,NULL,
				new_edge[i],OM_Gw_current_OS,to_common_edge,
				NULL), targetid = other_edges[other_con[i]]);
	      EMerr_hndlr(!(1&sts),*EMmsg,EMS_E_OMerror,wrapup);
	    }
	
	  } /* if(*(split_location[1]) == EMScvint_middle) */
	
	 } /* if(count) */
	
     } /* if(split_partner) */

/* replace myself with the two partedges in all the loops that use me.
   There is no need to update the range of the loop.
*/
    if(!IF_NULL_OBJID(new_edge[0]) && !IF_NULL_OBJID(new_edge[1]))
     {   
      sts = ems$send_loops(msg = &rc,
                           message = message EMSloop.EMmodify_edge
                           (EMmsg, EMS_INS_REPLACE, 2, user_id, new_edge,
                           FALSE), sender_edge = user_id,
                           toinx = MAXINT,
                           all_mask = EMLP_ACTIVE);
      if(! (1&*EMmsg&sts))goto wrapup;
     }

   }
    break;

    default:
    *EMmsg = EMS_E_InvalidCase;
    goto wrapup;
  }
  
  /*
   * If this edge is a model-space edge, connect it's split pieces, if
   * any to the associations of this edge.
   */

  if (((ME.EMSedge->ed_props & EMED_XYZ)||(options & EMSplitEd_MaintainAssoc)) 
	&& 
      *(split_location[0]) == EMScvint_middle &&
      !IF_NULL_OBJID(edges[0]) &&
      !IF_NULL_OBJID(edges[1]))
    {
     IGRlong rc;
    sts = om$send (msg = message EMSedge.EMconn_to_myassoc (&rc,
           2, edges), targetid = my_id);
    EMerr_hndlr(!(1&rc&sts),*EMmsg,EMS_E_EdgeError,wrapup);
    }

wrapup:
  if(my_surf_geom) om$dealloc(ptr = my_surf_geom);

  EMWRAPUP(*EMmsg,sts,"In EMSedge.EMsplityourself")
  return(OM_S_SUCCESS);
}


#define NUM_INTERNAL_PTS 4

IGRboolean EMorient_coinc(EMmsg, svtx, idx, oldedg, newedg, to_comm, 
                  to_comps, partolbasis, location, options, edos)
IGRlong		*EMmsg;
GRobjid		svtx;
IGRint		idx;
GRobjid		oldedg, newedg;
OM_S_CHANSELECT *to_comm, *to_comps;
struct EMSpartolbasis *partolbasis;
IGRshort	*location;
IGRushort	options;
GRspacenum	edos;
{
 IGRlong		sts, junk;
 GRobjid		junked = NULL_OBJID;
 IGRdouble		samplepts[NUM_INTERNAL_PTS][2], bsparam = 0.5;
 IGRint			i;
 struct EMSptloc_info 	ptloc;
 IGRboolean		sameed = FALSE;
 struct EMSpartedinfo	intpt_part;
 struct EMSedgebound	intpt_bnd[2], ptloc_bnd[2], edbnd[2];
 OM_S_CHANSELECT        to_owners, to_edge, loc_to_comm;

 *EMmsg = EMS_S_Success;
 sts = OM_S_SUCCESS;
 *location = EMS_L_UNKNWN;


 if(IF_NULL_OBJID(oldedg) && !IF_NULL_OBJID(svtx) && to_comps)
   sts = om$send(msg = message EMSboundary.EMget_objid(&junk, &oldedg), 
				p_chanselect = to_comps, senderid = svtx, 
				from = idx, to = idx);

 if(IF_NULL_OBJID(oldedg)) return(FALSE);
/* if(!WANT_POST220_BEHAVIOR && IF_EQ_OBJID(newedg, oldedg)) return(TRUE);*/


 /* Following statement has effectively disabled this function. This
    action was taken because there is not enough time left to debug the
    functionality for EMS 3.

    SM 12/19/93.
 */
 goto wrapup;


 if(options & EMSplitEd_ClosureOnRight)
  {
   *location = EMS_L_RIGHT;
   goto wrapup;
  }
 else if(options & EMSplitEd_ClosureOnLeft)
  {
   *location = EMS_L_LEFT;
   goto wrapup;
  }

 /* If the edges are the same use part of it for internal points and part
    for ptlocation.
 */

 if(IF_EQ_OBJID(newedg, oldedg))
  {
   sameed = TRUE;

   /* begin of edge to the midpoint - used for internal points.
      midpoint to end of edge - used for pt location.

      By getting the bounds of the edge in its logical direction, 
      the edge reversal is accounted for.
   */
   sts = om$send(msg=message EMSedge.EMendpts(EMmsg, NULL, NULL, 
        edbnd, &edbnd[1], NULL), senderid = NULL_OBJID, 
        targetid = newedg, targetos = edos);
   if(!(1&*EMmsg&sts)) goto wrapup;

   OM_BLOCK_MOVE(edbnd, intpt_bnd, sizeof(struct EMSedgebound));
   sts = om$send(msg = message EMSedge.EMbstobnd(EMmsg, 1, &bsparam, 
         &intpt_bnd[1]), targetid = newedg, senderid = NULL_OBJID, 
         targetos = edos);
   if(!(1&*EMmsg&sts)) goto wrapup;

   OM_BLOCK_MOVE(&intpt_bnd[1], ptloc_bnd, sizeof(struct EMSedgebound));
   OM_BLOCK_MOVE(&edbnd[1], &ptloc_bnd[1], sizeof(struct EMSedgebound));

   /* Construct a partedge to do point location. This may be accomplished
      by simply specifying the parted info on the edge, when doing the
      point location. But I don't want to take a chance of some code relying
      on the partedge actually being there.
   */
   sts = om$send(msg = message EMSedge.EMget_props_type(EMmsg, 
         &intpt_part.edprops, &intpt_part.edtype), targetos = edos, 
         targetid = newedg, senderid = NULL_OBJID);
   if(!(1&*EMmsg&sts)) goto wrapup;

   intpt_part.edprops |= EMED_OPEN;
   OM_BLOCK_MOVE(intpt_bnd, intpt_part.edbdry, 2*sizeof(struct EMSedgebound));
   intpt_part.edid = newedg;

   sts = om$construct(classid=OPP_EMSpartedge_class_id, p_objid = &junked, 
         osnum = edos, 
         msg = message EMSpartedge.EMpeinit(EMmsg, intpt_part.edprops, 
         ptloc_bnd, intpt_part.edtype));
   if(!(1&*EMmsg&sts)) goto wrapup;

   sts = ems$make_chanselect (chan_label = EMSedge_to_owner,
         chan_selector = &to_owners);

   sts = ems$make_chanselect (chan_label = EMSbd_owner_to_comps,
            chan_selector = &to_edge);
   if(!(1&sts)) goto wrapup;

   sts = om$send(msg=message Root.connect(to_edge, NULL, newedg,
         OM_Gw_current_OS, to_owners, NULL), targetos = edos, 
         senderid = newedg, targetid = junked);
   if(!(1&sts)) goto wrapup;
  }
 else
  sameed = FALSE;

 if(to_comm)
  sts = om$is_objid_on_channel(objid_c = oldedg, osnum_c = edos, 
        p_chanselect = to_comm, objid = newedg, osnum2 = edos);
 else sts = OM_W_NOTONCHAN;

 if(sts == OM_S_SUCCESS) return(TRUE);
 else
  {
   /* Take some sample points on the oldedg and find their location wrt the
      newedg (left or right). Stop as soon as a non-onedge location is
      found.
   */
   sts = om$send(msg = message EMSedge.EMinternalpt(EMmsg, NUM_INTERNAL_PTS, 
         NULL, (IGRdouble *) samplepts, sameed ? &intpt_part : NULL, 
         partolbasis), senderid = oldedg, targetid = oldedg, 
         targetos = edos);
   if(!(1&*EMmsg&sts)) goto wrapup;

   for(i=0; i<NUM_INTERNAL_PTS; i++)
    {
     ptloc.location = EMS_L_UNKNWN;
     sts = om$send(msg = message EMSedge.EMpt_location(EMmsg, samplepts[i], 
           &ptloc, NULL, partolbasis), targetos = edos, 
           senderid = newedg, targetid = sameed ? junked : newedg);
     if(!(1&*EMmsg&sts)) goto wrapup;

     /* If not a clean determination, ignore the location.
     */
     if(ptloc.edge[0].nst_pt.location != EMScvint_middle)
      ptloc.location = EMS_L_UNKNWN;


     if( (ptloc.location == EMS_L_RIGHT) || (ptloc.location == EMS_L_LEFT))
      {
       *location = ptloc.location;
       break;
      }
    }
  }

wrapup:
if(!IF_NULL_OBJID(junked))
 {
  sts = om$send(msg = message Root.wild_disconnect(to_edge), 
        targetid = junked, senderid = NULL_OBJID, targetos = edos);
  sts = om$send(msg = message Root.delete(TRUE), 
        targetid = junked,  senderid = NULL_OBJID, targetos = edos);
 }

if(!(1&*EMmsg&sts))
 *location = EMS_L_UNKNWN;

if( (*location != EMS_L_UNKNWN) && IF_EQ_OBJID(newedg, oldedg))
 {
  IGRlong rc;

  if(!to_comm)
   {
    sts = ems$make_chanselect (chan_label = EMSedge_to_common_edge,
         chan_selector = &loc_to_comm);
    to_comm = &loc_to_comm;
   }
  sts = om$send(msg = message EMSedge.EMset_props(&rc, EMED_OPEN, EMS_O_ON), 
        targetid = newedg, targetos = edos, senderid = newedg);
  sts = om$send(msg = message EMSedge.EMset_props(&rc, EMED_OPEN, EMS_O_ON), 
        senderid = newedg, p_chanselect = to_comm);
  sts = om$send(msg = message EMSedge.EMset_props(&rc, EMED_XYZ_CLOSED, 
        EMS_O_OFF), targetid = newedg, targetos = edos, senderid = newedg);
  sts = om$send(msg = message EMSedge.EMset_props(&rc, EMED_XYZ_CLOSED, 
        EMS_O_OFF), senderid = newedg, p_chanselect = to_comm);
 }

return(FALSE);
}
end implementation EMSedge;
