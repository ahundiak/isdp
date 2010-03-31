/*
Notes
	This method determines the location of a point(2D) with respect to a
  loop. The location returned is one of the following - 
	EMS_L_ONEDGE   - point was on this edge
	EMS_L_ONVRTX   - point was on vertex
	EMS_L_INSIDE   - point was inside the loop(for closed loop only)
	EMS_L_OUTSIDE  - point was outside the loop.(for closed loop only)

	In case of the point being on the vertex, both edges meeting at
  that vertex are returned. The convention followed is that, in the
  structure returned, edge[0] is the incoming edge wrt that vertex and
  edge[1] is the outgoing edge wrt that vertex.
	Maximum number of located edges are 2(in case when point is on
  vertex). There is a  EMSlocated_edge structure for each located edge
  as part of the output. It contains information generated about that edge.
  The significance of different fields can be found in file 'emssfbnd.h'.

NOTE : The option EMS_PTLOC_BOXCHECK is used to determine whether it is ok
	to do a trivial range box check with the point. If the point is
	outside the range box of the loop then the location is immediately
	set to EMS_L_OUTSIDE and the method will exit. In a case like this
	NO EDGE INFO IS RETURNED. The method does not generate nearest edge
	minimum distance etc. and hence does not retun it. In cases where
	this is not desirable, the option should not be used.
	
Assumption
	The loop is non-selfintersecting.
	P loops are clockwise.
	C loops are anticlockwise.
	The loop type of the loop is set in its properties bits.

History
	SM    02/26/87   creation date
	SM    27-Jan-88  If the nearest edges have returned EMS_L_UNKNWN
			 location or if the two nearest edges are
			 equidistant, from the input point, 
			 use the alternate algorithm of ray casting.
        NP    05-May-92  Added function calls to time this method.
*/

class implementation EMSloop;

#include "EMS.h"
#include "emsdef.h"
#include "EMSbnddef.h"
#include "EMSopt.h"
#include "bsparameters.h"
#include "OMmacros.h"
#include "emsmacros.h"
#include "timerdef.h"
#include "bserr.h"
#include "bsparameters.h"
%safe
#include "math.h"
%endsafe

from EMSedge import EMpt_location,EMgetpygeom,EMendpts;
from EMSedge import EMget_coincedent_edge;

extern IGRboolean  _use_timers, WANT_POST220_BEHAVIOR;

method EMpt_location( IGRlong *EMmsg;IGRdouble *point;  
                      struct EMSptloc_info *location;
		      struct EMSpartolbasis *partolbasis)
{
    IGRlong                  sts, count,rc;
    OMuint                   num_edges;
    IGRint                   i,j, doublesize, structsize;
    struct EMSptloc_info     nst_edges[2],temp;
    IGRboolean               P_loop, EFextract_par(),inter;
    OM_S_CHANSELECT          to_edges;
    IGRdouble		     partolsqlen,partollen, partolcollin;
    struct IGRpolyline	     poly1,poly2;
    IGRdouble		     pts1[4],pts2[4];
    IGRdouble		     begin_pt1[2],end_pt1[2],begin_pt2[2],end_pt2[2];
    IGRdouble		     dist0, dist1, new_dist;
    IGRdouble		     v1[2], v2[2], v3[2], dotp1, dotp2;
    IGRboolean		     all_degenerate_edges = FALSE, 
			     alternate_algorithm = FALSE;
    GRobjid		     coin_edge;

   /* start timer for EMpt_location */
   if (_use_timers)
     start_timer (T_EMPT_LOCATION);

   *EMmsg = EMS_S_Success;
   sts = OM_S_SUCCESS;

   poly1.points = &pts1[0];
   poly2.points = &pts2[0];

   doublesize = sizeof(IGRdouble);
   structsize = sizeof(struct EMSptloc_info);

/* Get the proper tolerances
*/
   if(!partolbasis->is_valid)
    {
     sts = om$send(msg=message EMSboundary.EMgetsurface_info
			(EMmsg,NULL,partolbasis),targetid=my_id);
     EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_LoopError,wrapup);
    }

   sts = EFextract_par(BSTOLSQLENVEC,partolbasis->tol,&partolsqlen,&rc);
   sts = EFextract_par(BSTOLLENVEC,partolbasis->tol,&partollen,&rc);
   sts = EFextract_par(BSTOLCOLLINVEC,partolbasis->tol,&partolcollin,&rc);

   location->num_located_edges=0;
   location->location = EMS_L_UNKNWN;
   location->loop_id = my_id;


/* If the option specifies that the input point is to be processed only by
   active loops and if I am inactive then just return.
*/
   if( (location->options & EMS_PTLOC_ACTLOOP) &&
       (!(ME.EMSloop->lp_props&EMLP_ACTIVE)))
	goto wrapup;


/* If the caller wants the box check to be done, see if the point is inside
   my range box or not. If the input point is outside my range box then the
   the point is definately outside me.
   The box check is done only for closed loops. Inside/Outside does not
   make sense for open loops.
*/
   if( (location->options&EMS_PTLOC_BOXCHECK) && 
       (!(ME.EMSloop->lp_props&EMLP_OPEN)))
    {
       IGRdouble range_box[4], loctol;
       IGRint size = sizeof(IGRdouble) * 4;

       OM_BLOCK_MOVE(ME.EMSloop->range,range_box,size);

       if(WANT_POST220_BEHAVIOR && (location->options & EMS_PTLOC_USECHTTOL))
        {
         IGRlong msg_loc;
	 IGRdouble bastol, chttol, tolfactor;

         if (location->options & EMS_PTLOC_INCHTTOL)
          loctol = partollen * 2.0;
         else
          {
           BSEXTRACTPAR (&msg_loc, BSTOLLENVEC, bastol);
           BSEXTRACTPAR (&msg_loc, BSTOLCHRDHT, chttol);
           tolfactor = chttol / bastol;
           loctol = partollen * tolfactor;
           EMadjust_paramtol (&msg_loc, NULL, 
            partolbasis->tol, &partolbasis->tol);
          }
        }
       else loctol = partollen;

       EM2dbxinc(range_box,loctol/2.0);
       if(!(EM2dptinbx(range_box,point)))
        {
          *EMmsg = EMS_S_Success;
          sts = OM_S_SUCCESS;
          location->location = EMS_L_OUTSIDE;
          goto wrapup;
        }
     }

     to_edges.type = OM_e_addr;
     to_edges.u_sel.addr = &ME.EMSbd_owner->to_comps;


/* get a count of the number of edges involved */

    sts = om$get_channel_count(object = me,
                      p_chanselect = &to_edges,count = &num_edges);
    EMerr_hndlr(!(1&sts),*EMmsg,EMS_E_OMerror,wrapup);

    nst_edges[0].edge[0].nst_pt.dist = MAXDOUBLE;  /* Any big number */
    nst_edges[1].edge[0].nst_pt.dist = MAXDOUBLE;
    nst_edges[0].loop_id = nst_edges[1].loop_id = my_id;

/* Give the input point to each edge for a location test. Keep track of
   the two nearest edges.
*/
    all_degenerate_edges = TRUE;

    for(i=0;i<num_edges;i++)
     {

       location->num_located_edges = 0;
       location->location = EMS_L_UNKNWN;

       sts = om$send(msg = message EMSedge.EMpt_location
                            (EMmsg,point,location,NULL,partolbasis),
                        p_chanselect = &to_edges,from = i,to = i);
       EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_EdgeError,wrapup);

/* If the edge returns the location as on edge or on vertex, then no
   further processing is needed.
*/
       if ((location->location == EMS_L_ONEDGE) ||
           (location->location == EMS_L_ONVRTX) )
         {all_degenerate_edges = FALSE; goto wrapup;}

/* If the edge was degenerate then ignore it.
*/
       if(*EMmsg == EMS_I_DegenerateEdge) continue;

	/* If the edges just processed had two spans equidistant from
	   the input point the set the location to EMS_L_UNKNWN so the
	   the alternate algorithm can be applied to it if this happens
	   to be (one of) the nearest edge(s)
        */

       if(*EMmsg == EMS_I_Ambiguous) location->location = EMS_L_UNKNWN;

/* If the edge was coincedent with some other edge in the same loop
   then ignore it
*/
	coin_edge = NULL_OBJID;
	sts = om$send(msg = message EMSedge.EMget_coincedent_edge
				(EMmsg, &coin_edge), 
			p_chanselect = &to_edges, from=i, to=i);
	EMerr_hndlr(!(1&*EMmsg&sts), *EMmsg, EMS_E_EdgeError, wrapup);
	if(!IF_NULL_OBJID(coin_edge))
	 {
	   sts = om$is_objid_on_channel(object_c = me, 
					p_chanselect = &to_edges, 
					objid = coin_edge);
	   if(sts == OM_S_SUCCESS) continue;
	   else sts = OM_S_SUCCESS;
	 }
	all_degenerate_edges = FALSE;

	/* If the edges just processed had two spans equidistant from
	   the input point the set the location to EMS_L_UNKNWN so the
	   the alternate algorithm can be applied to it.
        */


       /* Following code is related to choosing the two nearest edges.
          nst_edges[0] will have the nearest edge and nst_edges[1] the
          second nearest edge after all the edges have been processed.
	  'Nearest' is based on the minimum distance between the input
	  point and the edge.
	
          When a new edge is processed-- 

	  If it is nearer than nst_edges[1]
	  move it in to nearest_edges[1] unconditionally.
	
	  If the new edge processed happens to be equidistant then give
	  priority to the edge which has returned non collinear
	  location.
	
	  If both the edges are equidistant and have non collinear locations
	  then if nst_edges[0] and nst_edges[1] are equidistant and have
	  same locations, replace nst_edges[1] by the new edge. The fact
	  that two edges are equidistant and have determined the same
	  location, means that one of them is providing redundant information
	  and hence is expendable.
	*/
	
       OM_BLOCK_MOVE(&location->edge[0].nst_pt.dist, &new_dist, doublesize);
       OM_BLOCK_MOVE(&nst_edges[1].edge[0].nst_pt.dist, &dist1, doublesize);
       OM_BLOCK_MOVE(&nst_edges[0].edge[0].nst_pt.dist, &dist0, doublesize);

       if((new_dist + partollen) < dist1)
         OM_BLOCK_MOVE(location, &nst_edges[1], structsize);
       else if(fabs(new_dist-dist1) < partollen)
        {
	  if( (nst_edges[1].location == EMS_L_COLLINEAR) &&
	      (location->location != EMS_L_COLLINEAR))
            OM_BLOCK_MOVE(location, &nst_edges[1], structsize);
	  else if( (fabs(dist0-dist1) < partollen) &&
		   (nst_edges[0].location == nst_edges[1].location) &&
		   (nst_edges[1].location != location->location) &&
		   (location->location != EMS_L_COLLINEAR))
            OM_BLOCK_MOVE(location, &nst_edges[1], structsize);

	  else continue; /* ignore new edge */
	}
       else continue;  /* the new edge is farther then nst_edges[1] so ignore*/

       /*
          Among the two nearest edges, we need to make nst_edges[0] the
	  nearest and nst_edges[1] the second nearest. Again use the 
	  same criterion as above except that if nst_edges[1] is equidistant
	  and nst_edges[0] has non collinear location, then leave them
	  as they are since it is not going to make any difference.
	  This part of code will be executed only if the new edge has been
	  used in nst_edges[1].
	*/
	
       OM_BLOCK_MOVE(&nst_edges[1].edge[0].nst_pt.dist, &dist1, doublesize);
       OM_BLOCK_MOVE(&nst_edges[0].edge[0].nst_pt.dist, &dist0, doublesize);

       if( ( (dist1 + partollen) < dist0) ||
	   ( ( fabs(dist1 - dist0) < partollen) &&
	     (nst_edges[0].location == EMS_L_COLLINEAR) &&
	     (nst_edges[1].location != EMS_L_COLLINEAR)))
          {
              OM_BLOCK_MOVE(&nst_edges[0], &temp, structsize);
              OM_BLOCK_MOVE(&nst_edges[1], &nst_edges[0], structsize);
              OM_BLOCK_MOVE(&temp, &nst_edges[1], structsize);
          }             

     }/* for(i=0;i<num_edges;i++) */

/* If the loop is open and the point is neither on edge or on vertex, then
   return unknown location.Further processing for inside/outside location
   of the point wrt a loop is valid only for closed loops.
*/

  if( (!(ME.EMSloop->lp_props & EMLP_OPEN)) &&   /* if closed then is ok */
      (!all_degenerate_edges))
   {

    P_loop = ME.EMSloop->lp_props & EMLP_PLOOP; 
    count = (num_edges==1) ? 1 : 2;

    location->location = EMS_L_UNKNWN;
    for(i=0;i<count;i++)
     {
       struct EMSlocated_edge *loced1, *loced2;
       struct EMSproj_info *proj1, *proj2;
       extern IGRboolean EMis_samevertex();
       
       if(location->location != EMS_L_UNKNWN) break;

/* If there are two nearest edges and both are equidistant from the point
   then the loop needs to do some processing-(Bermuda Traingle !). If
   the nearest point happens to be a logical vertex (rt-end of one edge
   and the lf-end of a subsequent edge), then regardless of the min-dist
   take this to mean the Bermuda Triangle case. Because of gaps between
   the ends of edges meeting at a vertex, the min-dist could be out of
   tolerance and a simple distance check may not always flag this condition
   as the BT-case.

   27-Jan-88 - The Bermuda triangle case is solved using the alternate 
   algorithm first. If that fails then go for the following processing. 
   This is also true for the coincedent edges problem.
*/
       j=!i;
       loced1 = &nst_edges[i].edge[0];
       loced2 = &nst_edges[j].edge[0];
       proj1 = &loced1->nst_pt;
       proj2 = &loced2->nst_pt;
       inter = FALSE;
       if(count == 2 && !i) 
        {
          if (EMis_samevertex (proj1->location, loced1->edge_id,
               proj2->location, loced2->edge_id, OM_Gw_current_OS, NULL) ||
              fabs (proj1->dist - proj2->dist) < partollen)
           {
             OM_BLOCK_MOVE(&nst_edges[i], location, structsize);
             sts = om$send(msg = message EMSloop.EMalternate_pt_location
				(EMmsg, point, location, partolbasis), 
				targetid = my_id);
	     EMerr_hndlr(!(1&*EMmsg&sts), *EMmsg, EMS_E_LoopError, wrapup);
	     alternate_algorithm = TRUE;
           }
	}

       /* The following processing is required only if 
	  o There are two nearest edges (loop has more then one edge)
	  o The other edge ([j]) has not determined EMS_L_COLLINEAR
	  o The two nearest edges have determined different locations
	  o We are considering the first nearest edge
	  o The two nearest edges are equidistant
	  o The alternate algorithm was invoked and was unable to determine
	    the location.
       */

       if( (count==2) && (nst_edges[j].location != EMS_L_COLLINEAR) &&
	   (nst_edges[j].location != nst_edges[i].location) && !i &&
           (EMis_samevertex (proj1->location, loced1->edge_id,
             proj2->location, loced2->edge_id, OM_Gw_current_OS, NULL) ||
	    fabs(dist0 - dist1) < partollen) && 
	   (location->location == EMS_L_UNKNWN))
	{
	  IGRdouble	proj_pt1[2], proj_pt2[2];
	  IGRint size = 2 * sizeof(IGRdouble);
	  IGRboolean	reverse;
	
	  OM_BLOCK_MOVE(nst_edges[i].edge[0].nst_pt.proj_pt, proj_pt1, size);
	  OM_BLOCK_MOVE(nst_edges[j].edge[0].nst_pt.proj_pt, proj_pt2, size);
	
/* Get the endpoints of both the edges
*/
	  sts = om$send(msg=message EMSedge.EMendpts
				(EMmsg,begin_pt1,end_pt1,NULL,NULL,NULL),
			targetid = nst_edges[i].edge[0].edge_id);
	  EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_EdgeError,wrapup);
	  sts = om$send(msg=message EMSedge.EMendpts
				(EMmsg,begin_pt2,end_pt2,NULL,NULL,NULL),
			targetid = nst_edges[j].edge[0].edge_id);
	  EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_EdgeError,wrapup);
	
/* The projected points of both the edges should be the same. If not then
   make them the same. The project_distance for both the edges might be the
   same but still the projected points may be different. These relatively
   expensive distance  checks will take place only in rare cases.
*/
	  if(EM2ddistptpts(proj_pt1, proj_pt2) > partolsqlen)
	   {
	     if(EM2ddistptpts(proj_pt1, begin_pt2) < partolsqlen)
		OM_BLOCK_MOVE(begin_pt2, proj_pt2, size);
	     else if(EM2ddistptpts(proj_pt1, end_pt2) < partolsqlen)
		OM_BLOCK_MOVE(end_pt2, proj_pt2, size);
	     else if(EM2ddistptpts(proj_pt2, begin_pt1) < partolsqlen)
		OM_BLOCK_MOVE(begin_pt1, proj_pt1, size);
	     else if(EM2ddistptpts(proj_pt2, end_pt1) < partolsqlen)
		OM_BLOCK_MOVE(end_pt1, proj_pt1, size);
	   }
	
/* If the projected point is begin pt of an edge get the pygeom for first
   span else get the pygeom of first span in reversed direction.
   The assumption here is that when reversed flag is set to TRUE,
   EMgetpygeom returns the pygeom of the last span(which is now the
   first span in reversed direction.
*/
	  reverse = (EM2ddistptpts(begin_pt1,proj_pt1) <partolsqlen) ?
					FALSE : TRUE;
          sts = om$send(msg=message EMSedge.EMgetpygeom
				(EMmsg,0,1,reverse,NULL,&poly1,
                                 partolbasis, NULL),
			targetid = nst_edges[i].edge[0].edge_id);
	  EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_EdgeError,wrapup);

	  reverse = (EM2ddistptpts(begin_pt2,proj_pt2) <partolsqlen) ?
					FALSE : TRUE;
          sts = om$send(msg=message EMSedge.EMgetpygeom
				(EMmsg,0,1,reverse,NULL,&poly2,
                                 partolbasis, NULL),
			targetid = nst_edges[j].edge[0].edge_id);
	  EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_EdgeError,wrapup);

/*
    Normalise the vectors pts1(A), pts2(B) and pts1-point(C). Then get the dot
    product between A-C and B-C. Select the vector which has smaller included
    angle with C (i.e the one which gives larger dot product). Use the edge
    corresponding to that vector to determine the location.
*/
	   {
		IGRint	j;
		IGRdouble dist;
		
		dist = sqrt(EM2ddistptpts(pts1, &pts1[2]));
		for(j=0;j<2;j++)
		    v1[j] = (pts1[j+2] - pts1[j])/dist;

		dist = sqrt(EM2ddistptpts(pts2, &pts2[2]));
		for(j=0;j<2;j++)
		    v2[j] = (pts2[j+2] - pts2[j])/dist;

		dist = sqrt(EM2ddistptpts(point, pts1));
		for(j=0;j<2;j++)
		    v3[j] = (point[j] - pts1[j])/dist;

	   }  
	   dotp1 = v1[0] * v3[0] + v1[1] * v3[1];
	   dotp2 = v2[0] * v3[0] + v2[1] * v3[1];
	
	   if(fabs(dotp1 - dotp2) < partolcollin)
	    {
	      location->location = EMS_L_UNKNWN;
	      *EMmsg = EMS_I_Ambiguous;
	      goto wrapup;
	    }
	
	   inter = (dotp1 < dotp2) ? TRUE : FALSE;
	
	} /* Special processing for bermuda triangle */

       if( (!inter) && (location->location == EMS_L_UNKNWN) )
        {
       	  if (nst_edges[i].location == EMS_L_LEFT)   
              nst_edges[i].location = P_loop ? EMS_L_OUTSIDE : EMS_L_INSIDE;
          else if(nst_edges[i].location == EMS_L_RIGHT)
              nst_edges[i].location = P_loop ? EMS_L_INSIDE : EMS_L_OUTSIDE;
          else 
	    {
	      /* This nearest edge had a problem with main algorithm.
		 Use alternate algorithm.
	      */
	      sts = om$send(msg = message EMSloop.EMalternate_pt_location
				(EMmsg, point, &nst_edges[i], partolbasis), 
				targetid = my_id);
	    }          
          OM_BLOCK_MOVE(&nst_edges[i], location, structsize);
	}
	
     }  /* for(i=0; i<count; i++) */

   } /* if(loop is closed) */
   
wrapup:

       /* If the location so far was not one of the expected then following
          may be the reason -

          o If the loop is inactive and the message was supposed to go only
	    to active loops - set return code to EMS_I_InactiveLoop & exit.
	  o The loop had all degenerate edges. So if the point is neither
	    on edge or on vertex, it must be outside. Set the return code
	    to EMS_I_DegenerateLoop.
	  o The loop is open and the point is neither on edge or on
	    vertex. Set the return code to EMS_I_NoSolution.
	  o The location was EMS_L_COLLINEAR or EMS_L_UNKNWN and the alternate
	    algorithm was not yet used. This means that the loop geometry
	    under the existing tolerance value lends itself to be out invalid
	    for the main algorithm. So try the alternate algorithm of
	    ray casting. If even that algorithm fails, we are out of
	    luck.

	*/
	
       if( (location->location != EMS_L_INSIDE) &&
	   (location->location != EMS_L_OUTSIDE) &&
	   (location->location != EMS_L_ONEDGE) &&
	   (location->location != EMS_L_ONVRTX)
	 )
	{
	  if( (location->options & EMS_PTLOC_ACTLOOP) &&
	      (!(ME.EMSloop->lp_props & EMLP_ACTIVE)))
	     *EMmsg = EMS_I_InactiveLoop;
	  else if(all_degenerate_edges)
	    {
	      location->location = EMS_L_OUTSIDE;
	      *EMmsg = EMS_I_DegenerateLoop;
	    }
	  else if(ME.EMSloop->lp_props & EMLP_OPEN)
	      *EMmsg = EMS_I_NoSolution;
	  else if(!alternate_algorithm)
	    sts = om$send(msg = message EMSloop.EMalternate_pt_location
					(EMmsg, point, location, partolbasis), 
					targetid = my_id);
	}

        /* stop timer for EMpt_location */
        if (_use_timers)
          stop_timer (T_EMPT_LOCATION, FALSE, "");

        EMWRAPUP(*EMmsg,sts,"In EMSloop.EMpt_location")
        return(sts);   
}



end implementation EMSloop;
