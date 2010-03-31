/*
Notes
	This method determines the location of a point(2D) with respect to an
  edge. The location returned is one of the following - 
	EMS_L_ONEDGE   - point was on this edge
	EMS_L_ONVRTX   - point was on vertex
	EMS_L_RIGHT    - point was on the right of nearest span of this edge
	EMS_L_LEFT     - point was on the left of nearest span of this edge
	EMS_L_COLLINEAR- point was collinear with the nearest span

	In case of the point being on the vertex, both edges meeting at
  that vertex are returned. The convention followed is that, in the
  structure returned, edge[0] is the incoming edge wrt that vertex and
  edge[1] is the outgoing edge wrt that vertex.

Assumption
	An edge is reversed if its direction is opposite to the direction
   of parametrization of the linestring.
	The linestring comprising this edge has one or more 'spans', each
   span parametrized from 0 to 1.
	The edge is not selfintersecting.

History
	SM    02/26/87   creation date
	SM    29-Oct-87  modified to handle maximum of 3 edges meeting at
			 a point(with one of them being a EMSptedge).
	SM    27-Jan-88  If two spans are equidistant from the input point
			 set the return code to be EMS_I_Ambiguous.
	SM    11-Aug-88  Optimisation.
	SS    19-Oct-88  Added the option to use chord-height tolerance.
        Sudha  07/06/93  modified for BSprototype includes	

Algorithm
	Project the input point on the edge and find nearest span.
	If the point is within tolerance - 
	  find if it is on vertex (check the param).
	  If on vertex, send it to the next or previous edge as the case
		may be.
	  If not on vertex, but within tolerance, then on edge.
	If not within tolerance -
	  take third point in the direction of the edge. Find if the
	  input point(pt1), nearest point(pt2) and the third point(pt3),
	  make a right turn, left turn or are collinear.
	  If pt3 falls of the span when going in direction of the edge,
	  then go against the stream and swap pt2 and pt3.
*/

class implementation EMSlinedge;

#include "EMS.h"

# ifndef msdef_include
# include "msdef.h" /* MS message codes */
# endif

#include "bserr.h"
#include "bsparameters.h"
%safe
#include "math.h"
%endsafe
#include "OMmacros.h"
#include "emsmacros.h"
#include "emsdattyp.h"
#include "math.h"
#include "emsinter.h"
#include "emsgeteddef.h"

from EMSloop import EMnext_edge;
from GRvg import EMptatpr;

extern OMuword OPP_EMSptedge_class_id;

method EMpt_location(IGRlong *EMmsg;IGRdouble *point; 
                 struct EMSptloc_info *location;struct EMSpartedinfo *part;
		 struct EMSpartolbasis *partolbasis)
{
    IGRboolean		tolreset;
    IGRint 		sts,k,i;
    struct EMSedgebound	bound[2];
    IGRdouble		partolsqlen,partolcollin,partollen, dist, origtol;
    IGRdouble		begin_pt[2],end_pt[2];
    IGRlong 		rc;
    GRobjid	 	user_id;
    void 		EMspanbounds();
    IGRushort	user_props;
    IGRboolean		in_middle,on_interval,on_left,on_begin,on_end,
			closed,inter;
    IGRboolean		EMpar_on_edintvl(),EF2dpyint(),EFextract_par();
    IGRint		EMsend_loops();
    IGRshort		proj_inx;
    IGRboolean		degenerate_edge = FALSE, 
			ambiguous_case = FALSE;
    struct EMSproj_info	*proj_ptr;
    enum EMScvinttype	pos;

    *EMmsg = EMS_S_Success;
    sts = OM_S_SUCCESS;
    tolreset = FALSE;

/* Get the proper tolerance
*/
    if(!partolbasis->is_valid)
     {
	sts = om$send(msg=message EMSboundary.EMgetsurface_info
			(EMmsg,NULL,partolbasis),targetid=my_id);
	EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_EdgeError,wrapup);
     }

    origtol = partolbasis->tol;
    if (location->options & EMS_PTLOC_USECHTTOL)
     {
        IGRlong msg_loc;
	IGRdouble bastol, chttol, tolfactor;

        if (location->options & EMS_PTLOC_INCHTTOL)
          partolbasis->tol *= 2.0;
        else
          {
          BSEXTRACTPAR (&msg_loc, BSTOLLENVEC, bastol);
          BSEXTRACTPAR (&msg_loc, BSTOLCHRDHT, chttol);
          tolfactor = chttol / bastol;
          partolbasis->tol *= tolfactor;
          EMadjust_paramtol (&msg_loc, NULL, 
           partolbasis->tol, &partolbasis->tol);
          }
        tolreset = TRUE;
     }

/* extract the tolerances for the parametric space
*/
    sts = EFextract_par(BSTOLLENVEC,partolbasis->tol,&partollen,&rc);
    sts = EFextract_par(BSTOLSQLENVEC,partolbasis->tol,&partolsqlen,&rc);
    sts = EFextract_par(BSTOLCOLLINVEC,origtol,&partolcollin,&rc);

    if(!part)
      {
	user_id = my_id;
	user_props = ME.EMSedge->ed_props;
      }
    else 
      {
	user_id = part->edid;
        user_props = part->edprops;
      }

/* Get the endpoints for the user_id(which could be a partedge).
*/
       sts = om$send(msg=message EMSedge.EMendpts(EMmsg,begin_pt,end_pt,
					bound,&bound[1],part),
				targetid=my_id);
     if(!(1&*EMmsg&sts)) goto wrapup;

      for(k=0; k<MAX_LOCATED_EDGES; k++)
        location->edge[k].edge_id = NULL_OBJID;
      k = location->num_located_edges = 1;
      location->edge[k-1].edge_id = user_id;
      proj_ptr = &location->edge[k-1].nst_pt;
      proj_ptr->location = EMScvint_unknown;

/*   If the option to use xyz-geometry for on-edge/on-vertex checks has
     been set, check for the location of the point wrt edge in xyz space.
     If this test fails for any reason go ahead with the test in uv-space.
     This section of the code simply acts as an additional feature.
*/
     pos = EMScvint_unknown;
     if (location->options & EMS_PTLOC_XYZ_ONEDGE)
       {
       IGRlong msg_loc;
       IGRdouble chttol;
       enum EMScvinttype EMchkposonedge();

       BSEXTRACTPAR (&msg_loc, BSTOLCHRDHT, chttol);
       pos = EMchkposonedge (&msg_loc, OM_Gw_current_OS, user_id, point,
              chttol);
       }

/*   project the incoming point on myself (send down the bnd if any). 
*/    

       sts = om$send(msg = message EMSedge.EMptproject
                 (EMmsg, point, 1, proj_ptr, part, partolbasis),
                        targetid = my_id);
       if(!(1&*EMmsg&sts)) goto wrapup;
       degenerate_edge = (*EMmsg == EMS_I_DegenerateEdge) ? TRUE : FALSE;
       ambiguous_case = (*EMmsg == EMS_I_Ambiguous) ? TRUE : FALSE;

/* If the input point is within tolerance it is either on edge or on
   vertex. Check to see if the point is on vertex first. If the edge is
   degenerate then only ONEDGE or ONVRTX will make sense. If none of these
   and the edge is degenerate then return.
*/

     if(pos != EMScvint_unknown || proj_ptr->dist <= partollen)
      {
        GRobjid	other_edge, other_edge1;
        OMuword other_classid;

        /* Find the location of the projected point on the span if not already
           determined.
        */
        if (pos == EMScvint_unknown)
          pos = proj_ptr->location;

        if(pos == EMScvint_unknown)      
         {
           sts = EMpar_on_edintvl(&rc, user_id, &bound[0], begin_pt, &bound[1],
		end_pt, &proj_ptr->param, proj_ptr->proj_pt, partolbasis,
		&on_interval, &in_middle,&on_left);
           if(!sts) {*EMmsg=EMS_E_OutOfBounds;goto wrapup;}
           EMerr_hndlr(!(1&rc),*EMmsg,EMS_E_EdgeError,wrapup);

           if(on_interval && !in_middle && on_left) 
	      pos = EMScvint_lfend;
           else if(on_interval && !in_middle && !on_left)
	      pos = EMScvint_rtend;
           else if(on_interval && in_middle)
	      pos = EMScvint_middle;
         }

	
	/* Input point is on Begin point
	*/
	if(pos == EMScvint_lfend)
          {
            location->location = EMS_L_ONVRTX;
	    other_edge = NULL_OBJID;
            sts = EMsend_loops(&rc,message EMSloop.EMnext_edge
                           (EMmsg,EMGetEd_Previous,user_id,&other_edge),
				user_id,0,0,EMLP_ACTIVE,NULL,NULL);
            if(!(1&*EMmsg&sts)) goto wrapup;
            if(!IF_EQ_OBJID(other_edge,user_id) && !IF_NULL_OBJID(other_edge))
             {
	
	       location->num_located_edges++;
	       location->edge[1] = location->edge[0];
	       location->edge[0].edge_id = other_edge;
               sts = om$send(msg=message EMSedge.EMptproject
                              (EMmsg,point,1, &location->edge[0].nst_pt,
				NULL,partolbasis),
                         targetid = other_edge);
               if(!(1&*EMmsg&sts)) goto wrapup;

	       sts = om$get_classid(objid = other_edge, 
				    p_classid = &other_classid);
	       EMerr_hndlr(!(1&sts), *EMmsg, EMS_E_OMerror, wrapup);
	       if(other_classid == OPP_EMSptedge_class_id)
	        {
		  other_edge1 = NULL_OBJID;
            	  sts = EMsend_loops(&rc,message EMSloop.EMnext_edge
                           (EMmsg,EMGetEd_Previous,other_edge,&other_edge1),
				other_edge,0,0,EMLP_ACTIVE,NULL,NULL);
            	  if(!(1&*EMmsg&sts)) goto wrapup;
		  if(!IF_EQ_OBJID(other_edge, other_edge1) &&
		     !IF_EQ_OBJID(other_edge1, user_id) && 
		     !IF_NULL_OBJID(other_edge1))
		   {
		     location->num_located_edges++;
		     location->edge[2] = location->edge[1];
		     location->edge[1] = location->edge[0];
		     location->edge[0].edge_id = other_edge1;
                     sts = om$send(msg=message EMSedge.EMptproject
                              (EMmsg,point,1, &location->edge[0].nst_pt,
				NULL,partolbasis),
                         targetid = other_edge1);
                     if(!(1&*EMmsg&sts)) goto wrapup;
		   }
		
	        } /* if(other_classid == OPP_EMSptedge_class_id) */
	
             } /* if(!IF_EQ_OBJID(other_edge, user_id)) */

           } /* if begin point */
	
	/* Input point is on End point.
	 */

	else if(pos == EMScvint_rtend)
          {
            location->location = EMS_L_ONVRTX;
	    other_edge = NULL_OBJID;
            sts = EMsend_loops(&rc,message EMSloop.EMnext_edge
                               (EMmsg,EMGetEd_Next,user_id,&other_edge),
				user_id,0,0,EMLP_ACTIVE,NULL,NULL);
            if(!(1&*EMmsg&sts)) goto wrapup;
            if(!IF_EQ_OBJID(other_edge,user_id) && !IF_NULL_OBJID(other_edge))
             {
	       location->num_located_edges++;
	       location->edge[1].edge_id = other_edge;
               sts = om$send(msg=message EMSedge.EMptproject
                              (EMmsg,point,1, &location->edge[1].nst_pt,
				NULL,partolbasis),
                         targetid = other_edge);
               if(!(1&*EMmsg&sts)) goto wrapup;

               sts = om$get_classid(objid = other_edge, 
				    p_classid = &other_classid);
	       EMerr_hndlr(!(1&sts), *EMmsg, EMS_E_OMerror, wrapup);
	       if(other_classid == OPP_EMSptedge_class_id)
	        {
		  other_edge1 = NULL_OBJID;
                  sts = EMsend_loops(&rc,message EMSloop.EMnext_edge
                           (EMmsg,EMGetEd_Next,other_edge,&other_edge1),
				other_edge,0,0,EMLP_ACTIVE,NULL,NULL);
                  if(!(1&*EMmsg&sts)) goto wrapup;
	          if(!IF_EQ_OBJID(other_edge, other_edge1) &&
		     !IF_EQ_OBJID(other_edge1, user_id) &&
		     !IF_NULL_OBJID(other_edge1))
		   {
   	             location->edge[2].edge_id = other_edge1;
                     sts = om$send(msg=message EMSedge.EMptproject
                              (EMmsg,point,1, &location->edge[2].nst_pt,
				NULL,partolbasis),
                             targetid = other_edge1);
                     if(!(1&*EMmsg&sts)) goto wrapup;
		   }
		
	         } /* if(other_classid == OPP_EMSptedge_class_id) */
	
	      } /* if(!IF_EQ_OBJID(other_edge, user_id)) */
	
          }  /* If end point */
/* If the input point was within tolerance but not on my vertex, then it 
   is on edge
*/
        else
            location->location = EMS_L_ONEDGE;

    }  /* if dist < partollen */

/* If the input point is not on edge or on vertex, then try to find its
   location with respect to my nearest span - whether it is on right,left, 
   or collinear with the nearest span. If the edge is degenerate (it has
   only two points and they are within tolerance) then it cannot determine
   the location any further. In such a case the return code is set to
   EMS_I_DegenerateEdge.
*/
   else if(!degenerate_edge)
    {
	IGRboolean		swap[2];
	IGRdouble		pt1[2],pt2[2],pt3[2][2],span_pt[4];
	IGRint			size,num_spans, j;
        IGRshort               	EMturn();
	struct EMSedgebound	left[2],right[2],eval[2];
	IGRdouble		eval_pt[2][4];
	IGRdouble		v1[2], v2[2], v3[2], dotp1, dotp2, dotp3;
	IGRboolean		degenerate_span_found = FALSE;
	IGRboolean		atleast_one_span = FALSE, one_span = FALSE;
	
	size = 2 * sizeof(IGRdouble);
	OM_BLOCK_MOVE(proj_ptr->proj_pt, pt2, size);
	OM_BLOCK_MOVE(point, pt1, size);

	num_spans = 1;

	if(bound[0].span_inx == bound[1].span_inx) one_span = TRUE;
	
/* left[0] - begining of the span on which the point was projected.
   right[0]- end of the span on which the point was projected.
	These are considering the direction of the edge.
*/

        EMspanbounds(bound, proj_ptr->param.span_inx, left, right,
			(user_props&EMED_REVERSED));
	    

/* eval_pt[0] - endpoints of the span on which the point was projected
   eval_pt[1] - endpoints of the other equidistant span if the projected
		point was the end point of a span.
	At the most there can be 2 equidistant spans of the edge/partedge.
*/

        OM_BLOCK_MOVE(&ME.EMSlinedge->points[left[0].span_inx*2],
			span_pt,size);
        OM_BLOCK_MOVE(&ME.EMSlinedge->points[left[0].span_inx*2+2],
			&span_pt[2],size);
    
        if(left[0].param == 0.0) 
         OM_BLOCK_MOVE(span_pt, eval_pt[0], size);
	else if(left[0].param == 1.0)
	 OM_BLOCK_MOVE(&span_pt[2], eval_pt[0], size);
	else
	 {
	  eval_pt[0][0] = span_pt[0]+left[0].param * (span_pt[2] - span_pt[0]);
	  eval_pt[0][1] = span_pt[1]+left[0].param * (span_pt[3] - span_pt[1]);
	 }
	
	if(right[0].param == 0.0)
	 OM_BLOCK_MOVE(span_pt, &eval_pt[0][2], size);
	else if(right[0].param == 1.0)
	 OM_BLOCK_MOVE(&span_pt[2], &eval_pt[0][2], size);
	else
	 {
	  eval_pt[0][2] = span_pt[0]+right[0].param *(span_pt[2] - span_pt[0]);
	  eval_pt[0][3] = span_pt[1]+right[0].param *(span_pt[3] - span_pt[1]);
	 }
	
	
/* If the point was projected on one of my points, then I may have to 
   process 2 spans. Both these spans will be equidistant from the input
   point.Find the location of the proj_pt on the span.
*/
	if(!one_span)
	 {
          sts = EMpar_on_edintvl(&rc, user_id, left, eval_pt[0], right,
			&eval_pt[0][2], &proj_ptr->param,
			pt2, partolbasis, &on_interval, &in_middle, &on_left);
	  if(!sts){*EMmsg=EMS_E_OutOfBounds;sts=OM_S_SUCCESS;goto wrapup;}
	  EMerr_hndlr(!(1&rc),*EMmsg,EMS_E_EdgeError,wrapup);
	 }
        else
        {
	 on_interval = TRUE;
	 in_middle = proj_ptr->location == EMScvint_middle ? TRUE : FALSE;
	 on_left = proj_ptr->location == EMScvint_lfend ? TRUE : FALSE;
        }
	
	closed = user_props & EMED_OPEN ? FALSE : TRUE;
/************************
	closed = (EM2ddistptpts(begin_pt,end_pt)<partolsqlen)?TRUE:FALSE;
**************************/
	on_begin = ((on_interval)&&(!in_middle)&&(on_left))?TRUE:FALSE;
	on_end = ((on_interval)&&(!in_middle)&&(!on_left))?TRUE:FALSE;
	proj_inx = proj_ptr->param.span_inx;

/* See if there is any other span equidistant from the input point and
   calculate its end points also.
	The side to which the input point lies is determined by the cross
   product of the two vectors formed by pt1,pt2,pt3 - 
   pt1 - input point
   pt2 - nearest point on the edge
   pt3 - If pt2 is in the middle of the span then pt3 is its nearest endpt.
	 If pt2 is begin or endpt of a span then pt3 is the other endpt of
	 the span.
   If the cross product is positive then pt1,pt2,pt3(in that order), make
   a left turn.If it is less than 0 then they make a left turn and if it is
   zero,they are collinear.pt3 is in the direction of the edge.If it is
   necessary to make the vector pt2-pt3 against the direction of the edge
   then pt2 and pt3 are simply swaped and the turn is found between
   pt1,pt3,pt2(in that order).
	In the following code pt3[0] is the third point for the span on
   which the input point(pt1) is projected.pt3[1] is the third point for
   the second equidistant span(if any).
	pt3 actually should be very near pt2 along the edge if the edge is
   >order2. But for order edges(like the linear edge),pt3 can be one of the
   endpoints of the span.
*/
        if( on_begin && (proj_inx==bound[0].span_inx)&& closed && (!one_span))
	 {
/* If the point was projected on the begining of span 0 and if I am closed
   then my last span is also equidistant from the input point. If the last
   span happens to be degenerate then consider the span before that.
*/
	   num_spans = 2;
	   swap[0] = FALSE;
	   OM_BLOCK_MOVE(&eval_pt[0][2],pt3[0],size);
	   degenerate_span_found = TRUE;
	   atleast_one_span = TRUE;
	
	   eval[1].span_inx = bound[1].span_inx;
	   OM_BLOCK_MOVE(eval_pt,&eval_pt[1][2],size);
	   while(degenerate_span_found && atleast_one_span)
	    {
	     if(user_props & EMED_REVERSED)
    	       OM_BLOCK_MOVE(&ME.EMSlinedge->points[eval[1].span_inx*2+2],
			 &eval_pt[1][0],size);
	     else
    	       OM_BLOCK_MOVE(&ME.EMSlinedge->points[eval[1].span_inx*2],
			 &eval_pt[1][0],size);
	     if(EM2ddistptpts(&eval_pt[1][2], &eval_pt[1][0])<partolsqlen)
	      {
		OM_BLOCK_MOVE(&eval_pt[1][0], &eval_pt[1][2], size);
		if(user_props & EMED_REVERSED)
		 {
		   eval[1].span_inx++;
		   if(eval[1].span_inx > bound[0].span_inx)
		      atleast_one_span = FALSE;
		 }
		else 
		 {
		   eval[1].span_inx--;
		   if(eval[1].span_inx < bound[0].span_inx)
		      atleast_one_span = FALSE;
		 }
	      }
	     else degenerate_span_found = FALSE;
	
	    } /* while(degenerate_span_found && atleast_one_span) */

	   if(degenerate_span_found && !atleast_one_span) num_spans = 1;
	
           OM_BLOCK_MOVE(&eval_pt[1][0],pt3[1],size);
	   swap[1] = TRUE;
	
	 } /*if(on_begin&&(proj_inx==bound[0].span_inx)&&closed&&(!one_span))*/
	
	 else if(on_begin && (proj_inx!=bound[0].span_inx) && (!one_span))
	 {
	   num_spans = 2;
	   eval[0] = right[0];		
	   swap[0] = FALSE;
	   OM_BLOCK_MOVE(&eval_pt[0][2],pt3[0],size);
	   degenerate_span_found = TRUE;
	   atleast_one_span = TRUE;
           if(user_props&EMED_REVERSED)
		eval[1].span_inx = eval[0].span_inx + 1;
	   else
	        eval[1].span_inx = eval[0].span_inx - 1;

/* Get the parametric bounds of the second span
*/
           OM_BLOCK_MOVE(eval_pt,&eval_pt[1][2],size);
	   while(degenerate_span_found && atleast_one_span)
	    {
	      EMspanbounds(bound,eval[1].span_inx,&left[1],&right[1],
				(user_props&EMED_REVERSED));

  	      OM_BLOCK_MOVE(&ME.EMSlinedge->points[left[1].span_inx*2],
			span_pt,size);
	      OM_BLOCK_MOVE(&ME.EMSlinedge->points[left[1].span_inx*2+2],
			&span_pt[2],size);
	      eval_pt[1][0] = span_pt[0]+left[1].param*(span_pt[2]-span_pt[0]);
	      eval_pt[1][1] = span_pt[1]+left[1].param*(span_pt[3]-span_pt[1]);

	      if(EM2ddistptpts(&eval_pt[1][2], &eval_pt[1][0])<partolsqlen)
	      {
		OM_BLOCK_MOVE(&eval_pt[1][0], &eval_pt[1][2], size);
		if(user_props & EMED_REVERSED) 
		 {
		   eval[1].span_inx++;
		   if(eval[1].span_inx > bound[0].span_inx)
		     atleast_one_span = FALSE;
		 }
		else 
		 {
		   eval[1].span_inx--;
		   if(eval[1].span_inx < bound[0].span_inx)
		     atleast_one_span = FALSE;
		 }
	      }
	     else degenerate_span_found = FALSE;
	
	    } /* while(degenerate_span_found && atleast_one_span) */
	
	   if(degenerate_span_found && !atleast_one_span) num_spans = 1;
	
	   swap[1] = TRUE;
	   OM_BLOCK_MOVE(&eval_pt[1][0],pt3[1],size);
	
	 } /* else if(on_begin&&(proj_inx!=bound[0].span_inx)&&(!one_span)) */

/* If the point was projected on the end of a span, then for all spans
   except the last, there is an equidistant span. If I am closed, then 
   even for the last span, span 0  is equidistant
*/
	else if(on_end &&(proj_inx==bound[1].span_inx)&&closed&&(!one_span))
	 {
	   num_spans = 2;
	   swap[0] = TRUE;
	   OM_BLOCK_MOVE(eval_pt,pt3[0],size);
	   OM_BLOCK_MOVE(&eval_pt[0][2],&eval_pt[1][0],size);
	   degenerate_span_found = TRUE;
	   atleast_one_span = TRUE;
	   eval[1].span_inx = bound[0].span_inx;
	   while(degenerate_span_found && atleast_one_span)
	    {
	      if(user_props & EMED_REVERSED)
  	        OM_BLOCK_MOVE(&ME.EMSlinedge->points[eval[1].span_inx*2],
			 &eval_pt[1][2],size);
	      else
  	        OM_BLOCK_MOVE(&ME.EMSlinedge->points[eval[1].span_inx*2+2],
			 &eval_pt[1][2],size);
	      if(EM2ddistptpts(&eval_pt[1][2], &eval_pt[1][0])<partolsqlen)
	      {
		OM_BLOCK_MOVE(&eval_pt[1][2], &eval_pt[1][0], size);
		if(user_props & EMED_REVERSED) 
		 {
		   eval[1].span_inx--;
		   if(eval[1].span_inx < bound[1].span_inx)
		     atleast_one_span = FALSE;
		 }
		else 
		 {
		   eval[1].span_inx++;
		   if(eval[1].span_inx > bound[1].span_inx)
		     atleast_one_span = FALSE;
		 }
	      }
	     else degenerate_span_found = FALSE;
	
	    }  /* while(degenerate_span_found && atleast_one_span) */
	
	   if(degenerate_span_found && !atleast_one_span) num_spans = 1;
	
	   OM_BLOCK_MOVE(&eval_pt[1][2],pt3[1],size);
	   swap[1] = FALSE;
	
	 }/*else if(on_end&&(proj_inx==bound[1].span_inx)&&closed
	                  &&(!one_span)) */
	
	else if( on_end &&(proj_inx!=bound[1].span_inx) && (!one_span))
	 {
	   num_spans = 2;
	   swap[0] = TRUE;
	   degenerate_span_found = TRUE;
	   atleast_one_span = TRUE;
	
	   OM_BLOCK_MOVE(eval_pt,pt3[0],size);
	   OM_BLOCK_MOVE(&eval_pt[0][2],&eval_pt[1][0],size);
	   if(user_props&EMED_REVERSED)
		   eval[1].span_inx = left[0].span_inx - 1;
	   else
		   eval[1].span_inx = left[0].span_inx + 1;

	   while(degenerate_span_found && atleast_one_span)
	    {
/* Get the parametric bounds of the second span
*/
	      EMspanbounds(bound,eval[1].span_inx,&left[1],&right[1],
				(user_props&EMED_REVERSED));
  	      OM_BLOCK_MOVE(&ME.EMSlinedge->points[right[1].span_inx*2],
			span_pt,size);
	      OM_BLOCK_MOVE(&ME.EMSlinedge->points[right[1].span_inx*2+2],
			&span_pt[2],size);
	      eval_pt[1][2] =span_pt[0]+right[1].param*(span_pt[2]-span_pt[0]);
	      eval_pt[1][3] =span_pt[1]+right[1].param*(span_pt[3]-span_pt[1]);
	      if(EM2ddistptpts(&eval_pt[1][2], &eval_pt[1][0])<partolsqlen)
	      {
		OM_BLOCK_MOVE(&eval_pt[1][2], &eval_pt[1][0], size);
		if(user_props & EMED_REVERSED) 
		 {
		   eval[1].span_inx--;
		   if(eval[1].span_inx < bound[1].span_inx)
		     atleast_one_span = FALSE;
		 }
		else 
		 {
		   eval[1].span_inx++;
		   if(eval[1].span_inx > bound[1].span_inx)
		     atleast_one_span = FALSE;
		 }
	      }
	     else degenerate_span_found = FALSE;
	
	    } /* while(degenerate_span_found && atleast_one_span) */
	
	   if(degenerate_span_found && !atleast_one_span) num_spans = 1;
	
	   swap[1] = FALSE;
	   OM_BLOCK_MOVE(&eval_pt[1][2],pt3[1],size);
	
	 } /* if(on_end &&(proj_inx!=bound[1].span_inx) && (!one_span)) */
	
/* If none of the above conditions are satisfied then there is only one
   span to process. If the projected point(pt2) is nearer to the left(begin) 
   then use the right(end) point of the span as pt3.If pt2 is nearer to
   the right of the span, then use the left(begin) point of the span as
   pt3 and swap pt2,pt3.
*/
	else if(on_begin || in_middle)
	 {
	   num_spans = 1;
	   swap[0] = FALSE;
	   OM_BLOCK_MOVE(&eval_pt[0][2],pt3[0],size);
	 }
	else if(on_end)
	 {
	   num_spans = 1;
	   swap[0] = TRUE;
	   OM_BLOCK_MOVE(eval_pt,pt3[0],size);
	 }
	else {*EMmsg = EMS_E_InvalidCase; goto wrapup;}

/* At this point eval_pt has the endpts of each span involved(max 2).
   pt3 for each span involved has also been obtained.
	If there are two equidistant spans then both need to be processed
   for the following reasons - 
   1)pt1 can be collinear with a span in which case the second span is
     used.pt1 cannot be collinear with both the equidistant
     spans.pt1,pt2,pt3 being collinear means that pt2 is an end point of
     the span,in which case there can be another equidistant span.
   2)If the line segment pt1-pt3,for a span intersects the other span then
     the other span is used to determine the turn.This is necessary 
     because a span whose pt1-pt3 segment intersects other span,gives 
     the opposite turn for the point than what it actually is. This case
	is commonly known as the BERMUDA TRIANGLE and is solved as follows-
     Find the normalised vectors v1 (pt3-pt2), v2 (pt3'-pt2), and v3 (pt1-pt2)
     Find which of the vectors v1 or v2 makes lesser angle with v3 and use
      the corresponding span.
     If v1 and v2 make equal angles, then see if the spans overlap. If they
      do, then declare this case to be an ambiguous one and exit. Otherwise
      it does not matter which span gets used.
*/

   location->location = EMS_L_UNKNWN;
   for(i=0;i<num_spans;i++)
     {
	if( (location->location == EMS_L_LEFT) ||
	    (location->location == EMS_L_RIGHT))
	    break;
	inter = FALSE;

	 if( (num_spans==2) && (i==0))
	  {
	    IGRint		m;
	
	    m = !i;
	    dist = sqrt(EM2ddistptpts(pt2, pt3[i]));
	    for(j=0;j<2;j++)
	      v1[j] = (pt3[i][j] - pt2[j])/dist;
	
	    dist = sqrt(EM2ddistptpts(pt2, pt3[m]));
	    for(j=0;j<2;j++)
	      v2[j] = (pt3[m][j] - pt2[j])/dist;
	
	    dist = sqrt(EM2ddistptpts(pt2, pt1));
	    for(j=0;j<2;j++)
	      v3[j] = (pt1[j] - pt2[j])/dist;

	    dotp1 = v1[0] * v3[0] + v1[1] * v3[1];
	    dotp2 = v2[0] * v3[0] + v2[1] * v3[1];

	    /* If dotp1 and dotp2 are within tolerance then the angles are
	       same. Need to check whether the spans overlap
	    */
	    if( fabs(dotp1 - dotp2) < partolcollin)
	     {
	      dotp3 = v1[0] * v2[0] + v1[1] * v2[1];
	
	      /* If spans overlap, exit.
	      */
              if( fabs(1.0 - dotp3) < partolcollin)
               {
	        location->location = EMS_L_UNKNWN;
	        *EMmsg = EMS_I_Ambiguous;
	        ambiguous_case = TRUE;
	        goto wrapup;
	       }
	     }
	    inter = (dotp1 < dotp2 ) ? TRUE : FALSE;
	
	  } /* if(num_spans==2) && (i==0) */
	
	 if(!inter)
	  {
            if(swap[i])
              location->location = EMturn(&rc,pt1,pt3[i],pt2,partolcollin);
            else
              location->location = EMturn(&rc,pt1,pt2,pt3[i],partolcollin);
	  }
	
      } /* for(i=0; i<num_spans; i++) */

    } /* else for if(dist < partollen) */



wrapup:
       if(degenerate_edge) *EMmsg = EMS_I_DegenerateEdge;
       if(ambiguous_case) *EMmsg = EMS_I_Ambiguous;
       if (tolreset) partolbasis->tol = origtol;

       EMWRAPUP(*EMmsg,sts,"In EMSlinedge.EMpt_location")
       return(sts);
}

end implementation EMSlinedge;
