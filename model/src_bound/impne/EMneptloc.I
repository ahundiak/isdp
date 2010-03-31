/* ###################   APOGEE COMPILED   ################## */
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

class implementation EMSnatedge;

#include "EMS.h"

#include "bserr.h"
#include "bsparameters.h"
%safe
#include "math.h"
%endsafe
#include "OMmacros.h"
#include "emsmacros.h"
#include "emsinter.h"
#include "emsgeteddef.h"

from EMSloop import EMnext_edge;

extern OMuword OPP_EMSptedge_class_id;

method EMpt_location(IGRlong *EMmsg;IGRdouble *point; 
                 struct EMSptloc_info *location;struct EMSpartedinfo *part;
		 struct EMSpartolbasis *partolbasis)
{
    IGRboolean		tolreset;
    IGRint 		sts,k;
    struct EMSedgebound	bound[2];
    IGRdouble		partollen,partolcollin, origtol;
    IGRdouble		begin_pt[2],end_pt[2];
    IGRlong 		rc;
    GRobjid	 	user_id;
    IGRushort	user_props;
    IGRboolean		in_middle,on_interval,on_left;
    IGRboolean		EMpar_on_edintvl(),EFextract_par();
    IGRint		EMsend_loops();
    IGRboolean		degenerate_edge = FALSE,   /* Partedge on a natural
						     edge can be degenerate.
						  */
			ambiguous_case = FALSE;
			
    enum EMScvinttype	pos;
    struct EMSproj_info	*proj_ptr;

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

/* extract the tolerance for the parametric space
*/
    sts = EFextract_par(BSTOLLENVEC,partolbasis->tol,&partollen,&rc);
    sts = EFextract_par(BSTOLCOLLINVEC,partolbasis->tol,&partolcollin,&rc);

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

/*   project the incoming point on myself (send down the bnd)
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

	/* Begin point
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

	/* Input point on End point
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
	
          } /* If end point */

/* If the input point was within tolerance but not on my vertex, then it 
   is on edge
*/
        else
            location->location = EMS_L_ONEDGE;

    } /* if dist < partollen */

/* If the input point is not on edge or on vertex, then try to find its
   location with respect to my nearest span - whether it is on right,left, 
   or collinear with the nearest span.
*/
   else if(!degenerate_edge)
    {
	IGRboolean		swap;
	IGRdouble		pt1[2],pt2[2],pt3[2];
	IGRint			size;
        IGRshort               	EMturn();

	size = 2 * sizeof(IGRdouble);
	OM_BLOCK_MOVE(proj_ptr->proj_pt, pt2, size);
	OM_BLOCK_MOVE(point, pt1, size);


/* 
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
	pt3 actually should be very near pt2 along the edge if the edge is
   >order2. But for order 2 edges,pt3 can be one of the endpoints of the span.
*/

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
    
	 if( (pos == EMScvint_lfend) || (pos == EMScvint_middle) )
	 {
	   OM_BLOCK_MOVE(end_pt,pt3,size);
	   swap = FALSE;
	 }
	else if( pos == EMScvint_rtend)
	 {
	   swap = TRUE;
	   OM_BLOCK_MOVE(begin_pt,pt3,size);
	 }
	else {*EMmsg = EMS_E_InvalidCase; goto wrapup;}


        location->location = EMS_L_UNKNWN;

        if(swap)
          location->location = EMturn(&rc,pt1,pt3,pt2,partolcollin);
        else
          location->location = EMturn(&rc,pt1,pt2,pt3,partolcollin);
    }



wrapup:
       if(degenerate_edge) *EMmsg = EMS_I_DegenerateEdge;
       if(ambiguous_case) *EMmsg = EMS_I_Ambiguous;
       if (tolreset) partolbasis->tol = origtol;

       EMWRAPUP(*EMmsg,sts,"In EMSnatedge.EMpt_location")
       return(sts);
}

end implementation EMSnatedge;
