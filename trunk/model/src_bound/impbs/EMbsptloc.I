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
	PP    02/26/87   creation date
	SM    29-Oct-87  modified to handle maximum of 3 edges meeting at
			 a point(with one of them being a EMSptedge).
	SM    02-Dec-87  option changes to EMnext_edge.
        PP    01/27/88   Supporting the return of EMS_I_NoSolution and
                         EMS_I_Ambiguous from EMptproject.
        Sudha 06/04/93   modified to include BSprototype header files

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

class implementation EMSbsedge;

#include "EMS.h"

#include "bserr.h"
#include "bsparameters.h"
%safe
#include "math.h"
%endsafe
#include "OMmacros.h"
#include "emsmacros.h"
#include "emsdattyp.h"
#include "emsgeteddef.h"
#include "bschgdeppar.h"

from EMSloop import EMnext_edge;

extern OMuword OPP_EMSptedge_class_id;
extern IGRboolean WANT_POST220_BEHAVIOR;

method EMpt_location(IGRlong *EMmsg;IGRdouble *point; 
                 struct EMSptloc_info *location;struct EMSpartedinfo *part;
		 struct EMSpartolbasis *partolbasis)
{
    IGRint 		sts,k;
    struct EMSedgebound	bound[2];
    IGRdouble		partolcollin,partollen, origtol;
    IGRdouble		begin_pt[2],end_pt[2];
    IGRdouble		basis_tol;
    struct	IGRpolyline poly;
    IGRdouble		polyline_points[4];
    IGRlong 		rc;
    GRobjid	 	user_id;
    void 		EMspanbounds();
    IGRushort	user_props;
    IGRboolean		in_middle,on_interval,on_left, ambiguous_case = FALSE, 
			tolreset = FALSE;
    IGRboolean		EMpar_on_edintvl(),EF2dpyint(),EFextract_par();
    IGRint		EMsend_loops();
    IGRshort		EMturn();
    enum EMScvinttype	pos;
    struct EMSproj_info	*proj_ptr;

    *EMmsg = EMS_S_Success;
    sts = OM_S_SUCCESS;
    poly.points = polyline_points;


/* Get the proper tolerance
*/
    if(!partolbasis->is_valid)
     {
	sts = om$send(msg=message EMSboundary.EMgetsurface_info
			(EMmsg,NULL,partolbasis),targetid=my_id);
	EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_EdgeError,wrapup);
     }

    origtol = partolbasis->tol;
    if (WANT_POST220_BEHAVIOR && (location->options & EMS_PTLOC_USECHTTOL))
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

/*
 * Change the basis tolerance for purpose of handling bs math routines at
 * the parametric tolerance value
 */
    sts = BSEXTRACTPAR(&rc, BSTOLBASIS, basis_tol);
    BSchgdeppar (partolbasis->tol, &rc);

/* extract the tolerances for the parametric space
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
     if(!(1&*EMmsg&sts)) goto wrapup;

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

/*   project the incoming point on myself (send down the bnd if any)
*/    
       sts = om$send(msg = message EMSedge.EMptproject
                 (EMmsg,point,1,proj_ptr,part,partolbasis),
                        targetid = my_id);
       if(!(1&*EMmsg&sts)) goto wrapup;
       if ((*EMmsg == EMS_I_NoSolution) || (*EMmsg == EMS_I_Ambiguous))
       {
         ambiguous_case = TRUE;
         *EMmsg = EMS_S_Success;
       }



/* If the input point is within tolerance it is either on edge or on
   vertex. Check to see if the point is on vertex first.
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

          } /* begin point */

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
		  other_edge1=NULL_OBJID; /* assigned NULL_OBJID-Ashok 4/10/91 */
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
	
          } /* end point */
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
   else
    {
      IGRdouble cpsign;
      IGRdouble mag;    /* stores the magnitude of the vector */
     
      IGRdouble pt2[2]; /* projected point on the edge */
     

      IGRdouble p[2];  /* 2d vector from the projected point on the edge 
                           to the point that was projected */
      IGRdouble t[2];  /* 2d tangent vector at the projected point */


      OM_BLOCK_MOVE (proj_ptr->proj_pt,pt2,
                     2 * sizeof(IGRdouble));

      OM_BLOCK_MOVE (proj_ptr->tangent, t, 
                     2 * sizeof (IGRdouble));

     p[X] =  point[X] - pt2[X];
     p[Y] =  point[Y] - pt2[Y];

     mag =  proj_ptr->dist ;
     p[X] = p[X] / mag;
     p[Y] = p[Y] / mag;

     cpsign = p[X]*t[Y] - p[Y]*t[X];

     if (cpsign > partolcollin)
     {
       location->location = EMS_L_RIGHT;
     }
     else if (cpsign < -partolcollin)
     {
       location->location = EMS_L_LEFT;
     }
     else
     {
        sts = om$send (msg = message EMSedge.EMgetpygeom (EMmsg,
                                0, 1, FALSE, part, &poly, partolbasis, NULL),
                          targetid = my_id);
        EMerr_hndlr (!(1&sts&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);

        location->location = EMturn (&rc,point, &poly.points[0],
                                     &poly.points[2], partolcollin);
      }
    }
wrapup:
       BSchgdeppar (basis_tol, &rc);

       if(ambiguous_case) *EMmsg = EMS_I_Ambiguous;
       if (tolreset) partolbasis->tol = origtol;

       EMWRAPUP(*EMmsg,sts,"In EMSbsedge.EMpt_location")
       return(sts);
}

end implementation EMSbsedge;
