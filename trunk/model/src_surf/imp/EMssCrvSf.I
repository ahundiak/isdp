/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsubbs;

#include "EMS.h"
# include <stdio.h>
# include "igrtypedef.h"
# include "igr.h"
# include "gocmacros.h"
# include "OMmacros.h"
# include "msdef.h"
# include "bserr.h"
# include "bsparameters.h"

# include "EMSbnddef.h"
# include "EMSbnd.h"
# include "EMSbnddef.h"
# include "EMSopt.h"

# include "emsdef.h"
# include "emserr.h"

from EMSloopset import  EMpt_location;

method EMcrvsrfint( IGRlong		  *msg;
		    struct GRvg_construct *cnst_list;
		    struct GRmdenv_info   *my_objenv;
		    struct IGRbsp_curve   *curve_in;
		    struct GRid		  *curve_obj;
		    struct GRmdenv_info   *curve_objenv;
		    IGRboolean		   hole_inter_valid;

		    IGRlong		  *pnt_slots;
		    IGRlong		  *grand_num_pnt;
		    struct GRid		  **pnt_ids;
		    struct GRparms	  **my_pnt_inters;
		    struct GRparms	  **curve_pnt_inters;
		    IGRdouble		  **inter_pnts_xyz;
		    IGRulong      	  **inter_props)

/*
Abstract
        This method intersects a surface with a curve.
  	I AM A SURFACE. I CAN INTERSECT ONLY CURVES / COMPCURVES        
Notes
	If the incoming object is a composite curve, then its component
	ids are retrieved one by one and this method is invoked

Arguments

IGRlong		      *msg;		Error return code
				
struct GRvg_construct *cnst_list;
		     	Required to construct points or curves. Can be NULL
		      	if pnt_ids is NULL

struct GRmdenv_info   *my_objenv;
			required to get my geometry
				        
struct IGRbsp_curve   *curve_in;
			caller can send the geometry of the curve I am
			intersecting. Obviously this can happen only
			if the other curve is not compcurve. Caller should set
		 	this to NULL if curve_obj is being sent.

struct GRid	      *curve_obj;
			id of the object I am intersecting.
		      	Can be NULL if curve structure is being sent.

struct GRmdenv_info   *curve_objenv;
			env info the the other object

IGRboolean	      hole_inter_valid;
			TRUE is the intersection points in a hole are to
			be returned. FALSE otherwise.

IGRlong		      *pnt_slots;
			number of slots allocated so far for storing
			intersection info. The total memory allocated is
			different for different options. But size is linked
			to number of intersections. If caller wishes to
			allocate some memory for storing the return variables,
			then this variable should indicate the number of slots
			allocated.

IGRlong		      *grand_num_pnt;
			number of intersections found = N
					
struct GRid	      **pnt_ids;
			non-NULL only if the points of intersection need to
			be constructed. #GRids = *grand_num_pnt

struct GRparms	      **my_pnt_inters;
			non-NULL only if the parametric info of intersections
			wrt 'me' is needed.  

			struct[I].u = u parm on 'my' surface
		 	struct[I].v = v parm on 'my' surface
		  	truct[I].polygon_inx = FALSE
		   	struct[I].leaf_id     = my_id
		    	0 <= I < N

struct GRparms	      **curve_pnt_inters;
			non-NULL only if the parametric info of intersections
			wrt other obj is needed.

			struct[I].u = parameter on curve
			struct[I].v = 0.0
			struct[I].polygon_inx = FALSE
			struct[I].leaf_id     = curve_obj
			0 <= I < N

IGRdouble	      **inter_pnts_xyz;
			non-NULL only if xyz co-ordinates of the intersection
			points are  needed. The returned double array is
			3 * (*grand_num_pnt) long.

IGRulong		**inter_props; 
			non-NULL only if info regarding the intersection
			point wrt edges on the surface is needed.

History
        gk      01/05/87        creation date
        gk      5/25/87         modified to identify EMSinters and
                                changed EMmkintlist call
	gk	12/4/87		arguments and philosophy changed
        PP      12/10/87        Made changes to set the properties of
                                the intersection point right and fixed
                                a bug which was causing the incorrect 
                                intersection parameters to be returned when
                                there is more than one intersection on the
                                surface.
        pp      12/31/87        Calling EMpartolbasis to determine the
                                parametric tolerance and added EMS_PTLOC_LS_
                                INFINITE to point location option in order
                                for unknown locations to be treated as hole
                                if the external loops are P loops.
        pp      01/29/89        Fixed a problem during realloc wherein the
                                pointers were not getting reset to their
                                new values thus causing some fudging of 
                                memory.
	BL	07/02/89	Modified the if statements that caused error
				when the input variables(pnt_ids, inter_props..)
				are NULL. See command below.
        NP	08/25/92	Modified for ANSI compliance. Added typecasts in
				om$realloc.
        NP      12/29/93        Math was returning intersection point on one 
                                seam, while the boundary was on the other seam.
                                If loopset point location returns point location
                                as "hole" or "unknown", then we check to see if
                                this surface has a seam, and if so if the point
                                is on it and if so, replace the point with the
                                matching (in XYZ) uv pt on the other seam and 
                                retry.
                                
*/

# define MEMORY_ERROR_PROCESS(ptr, destination_label)   \
if( !ptr )      \
 {      \
        fprintf(stderr, "EMsscrvsf:Memory Allocation Failure\n");       \
        *msg = MSNOMEM;         \
        status = OM_E_ABORT;    \
        goto destination_label; \
 }

#define GRAIN_SIZE 10

{
  IGRchar               errmsg[EMMAXERRMSG_LEN], *char_ptr = NULL;
  IGRlong               status, objsize, numb_ints, i, j, k, loc_msg,
			count, id_index, numb_required,
			EMoutput_point();
  IGRlong		parm_bytes,vect_bytes,long_bytes,grid_bytes;
  IGRuint		numb_children; /* om$get_channel_count needs IGRuint */
  struct GRprops        geo_props;
  struct GRparms	*temp_parm;
  struct GRid           my_GRid, null_obj, child_obj;
  IGRdouble		*para = NULL, *u_par = NULL, *v_par = NULL,
			*int_pts = NULL, test_par[2];
  IGRboolean		in_world = TRUE, log_status;
  struct EMSptloc_info	location;
  struct EMSpartolbasis	partolbasis;
  struct IGRbsp_curve   *int_curve = NULL;
  struct IGRbsp_surface *int_surface = NULL;
  OM_S_CHANSELECT	to_children;

  IGRboolean            on_seam, second_pass;
  IGRlong               side;
  IGRdouble             dist1, dist2, new_uv1[2], new_uv2[2];

  extern  IGRboolean    EFfind_closest_uv_side();
  extern  IGRboolean    BScv_sf_int();


/* ------------------------------------------------------------- */

  *msg = MSSUCC;
  strcpy (errmsg, "EMSsubbs.EMcrvsrfint");

  my_GRid.objid = my_id;
  my_GRid.osnum = OM_Gw_current_OS;
  null_obj.osnum = 0;
  null_obj.objid = 0;

/* See whom do I need to intersect */

 if (curve_obj)
 {
  status = om$send(msg = message GRvg.GRgeomprops(msg,
                                 &curve_objenv->matrix_type,
                                  curve_objenv->matrix,
                                 &geo_props),
                   targetid = curve_obj->objid,
                   targetos = curve_obj->osnum);
  if(EMSmsgReport(status, "EMcrvsfint: get props", FALSE)) goto wrapup;;
 }

  if(curve_obj && (geo_props.subtype IS GRCC))
   {

/* In this case get the ids of the component curves and invoke OPPmargs */

     status = EMmake_chanselect (GRcmpowner_to_components, &to_children);
     if(EMSmsgReport(status, "EMcrvsfint: chan select", FALSE))goto wrapup;
    
     status = om$get_channel_count(objid = curve_obj->objid,
				   osnum = curve_obj->osnum,
				   p_chanselect = &to_children,
				   count = &numb_children);
     if(EMSmsgReport(status, "EMcrvsfint: chan objs", FALSE))goto wrapup;

     for(i = 0; i < numb_children; i ++)
      {
	status = om$get_objid_at_index(osnum = curve_obj->osnum,
				       objid = curve_obj->objid,
				       p_chanselect = &to_children,
				       index = i,
				       objidaddr = &child_obj.objid,
				       osnumaddr = &child_obj.osnum);
        if(EMSmsgReport(status, "EMcrvsfint: obj at index", FALSE))goto wrapup;

	status = om$send(msg = message EMSsurface.EMcrvsrfint( msg, cnst_list,
		    	       my_objenv, NULL, &child_obj, curve_objenv,
			       hole_inter_valid, pnt_slots, grand_num_pnt,
			       pnt_ids, my_pnt_inters, curve_pnt_inters,
			       inter_pnts_xyz, inter_props),
		 	 targetid = my_id);
        if(EMSmsgReport(status, "EMcrvsfint: intersection", FALSE))goto wrapup;
      }
   }
  else
   {
/*   Get other object geometry if need be*/

     if(curve_in)
      {
	int_curve = (struct IGRbsp_curve *)curve_in;
      }
     else
      {
        status = om$send(msg = message GRvg.GRgetsize(msg,
                 &curve_objenv->matrix_type, curve_objenv->matrix, &objsize),
                      targetid = curve_obj->objid,
                      targetos = curve_obj->osnum);
        if(EMSmsgReport(status, "EMcrvsfint: get size", FALSE)) goto wrapup;;
        if( ! *msg & 1 )
         {
           fprintf(stderr, "EMsscrvsf:GRgetsize %d\n", *msg);
           goto wrapup;
         }

        char_ptr = (IGRchar *)om$malloc(size = (IGRuint)objsize);
        MEMORY_ERROR_PROCESS(char_ptr, wrapup);

        status = om$send(msg = message GRvg.GRgetgeom(msg,
                 &curve_objenv->matrix_type, curve_objenv->matrix, char_ptr),
                      targetid = curve_obj->objid,
                      targetos = curve_obj->osnum);
        if(EMSmsgReport(status, "EMcrvsfint: get geom", FALSE)) goto wrapup;
        if( ! *msg & 1 )
         {
           fprintf(stderr, "EMsscrvsf:GRgetgeom %d\n", *msg);
           goto wrapup;
         }
	int_curve = (struct IGRbsp_curve *)char_ptr;
        if( NOT int_curve->rational )       int_curve->weights = NULL;
        if( NOT int_curve->num_boundaries ) int_curve->bdrys   = NULL;
        if(     int_curve->num_poles IS 2 ) int_curve->planar  = FALSE;
      }

/*   Get my geometry */

     status = om$send(msg = message GRvg.GRgetsize(msg,
                 &my_objenv->matrix_type, my_objenv->matrix, &objsize),
                      targetid = my_id);
     if(EMSmsgReport(status, "EMcrvsfint: get size", FALSE)) goto wrapup;;
     if( ! *msg & 1 )
      {
        fprintf(stderr, "EMsscrvsf:GRgetsize %d\n", *msg);
        goto wrapup;
      }

     char_ptr = (IGRchar *)om$malloc(size = (IGRuint)objsize);
     MEMORY_ERROR_PROCESS(char_ptr, wrapup);

     status = om$send(msg = message GRvg.GRgetgeom(msg,
                 &my_objenv->matrix_type, my_objenv->matrix, char_ptr),
                      targetid = my_id);
     if(EMSmsgReport(status, "EMcrvsfint: get geom", FALSE)) goto wrapup;
     if( ! *msg & 1 )
      {
        fprintf(stderr, "EMsscrvsf:GRgetgeom %d\n", *msg);
        goto wrapup;
      }

     int_surface  = (struct IGRbsp_surface *)char_ptr;

/* We have a surface and a curve. Intersect them */

     log_status = BScv_sf_int(&loc_msg, int_curve, int_surface, &numb_ints,
                              &int_pts, &para, &u_par, &v_par);

     if( (NOT log_status) OR (loc_msg ISNT BSSUCC))
      {
        fprintf(stderr, "EMcrvsrfint: BScv_sf_int msg = %d\n", loc_msg);
        *msg = MSFAIL;
        status = OM_E_ABORT;
        goto wrapup;
      }


/*   See what needs to be constructed */

     if( numb_ints )    /* do I have any intersections at all */
      {
	numb_required = (*grand_num_pnt) + numb_ints;

	if( numb_required > *pnt_slots)	/* need to allocate */
	{
	   log_status = ( *pnt_slots IS 0) ? TRUE : FALSE;

	   *pnt_slots += GRAIN_SIZE;
	   if(numb_required > *pnt_slots) *pnt_slots = numb_required;

	   grid_bytes = (*pnt_slots) * (sizeof(struct GRid));
	   vect_bytes = (*pnt_slots) * (sizeof(IGRdouble) * 3);
	   parm_bytes = (*pnt_slots) * (sizeof(struct GRparms));
	   long_bytes = (*pnt_slots) * (sizeof(IGRulong));

    /*
     * BL : 07/02/89  Modified if statements such that the variables(pnt_ids, 
     *		      my_pnt_inters..) can be NULL if caller isn't interested.
     */
				 
	   if( log_status )	/* first time */
	   {
	      if(pnt_ids) 	
	      {
		  (*pnt_ids) = (struct GRid *) om$malloc(size = (IGRuint)grid_bytes);
	          MEMORY_ERROR_PROCESS( *pnt_ids, wrapup);
	      } /* if */

	      if(my_pnt_inters)	
	      {
		  (*my_pnt_inters) = (struct GRparms *)
						om$malloc(size=(IGRuint)parm_bytes);
	          MEMORY_ERROR_PROCESS( *my_pnt_inters, wrapup);
	      } /* if */

	      if(curve_pnt_inters) 
	      {
		  (*curve_pnt_inters) = (struct GRparms *)
						om$malloc(size=(IGRuint)parm_bytes);
	          MEMORY_ERROR_PROCESS( *curve_pnt_inters, wrapup);
	      } /* if */

	      if(inter_pnts_xyz) 
	      {
		  (*inter_pnts_xyz)=(IGRdouble *)om$malloc(size=(IGRuint)vect_bytes);
	          MEMORY_ERROR_PROCESS( *inter_pnts_xyz, wrapup);
	      } /* if */

	      if(inter_props)
	      {
		  (*inter_props) = (IGRulong *)  om$malloc(size=(IGRuint)long_bytes);
	          MEMORY_ERROR_PROCESS( *inter_props, wrapup);
	      } /* if */

	   } /* if log_status */
	   else	/* reallocation */
	   {
	      if(pnt_ids) 
              {
                *pnt_ids = (struct GRid *)om$realloc( ptr = (IGRchar *)(*pnt_ids),
					    size = (IGRuint)grid_bytes);
	        MEMORY_ERROR_PROCESS( *pnt_ids, wrapup);
              }

	      if(my_pnt_inters)
              {
               *my_pnt_inters =  (struct GRparms *)om$realloc( ptr = 
			(IGRchar *)(*my_pnt_inters), size = (IGRuint)parm_bytes);
	       MEMORY_ERROR_PROCESS( *my_pnt_inters, wrapup);
              }

	      if(curve_pnt_inters) 
              {
                 *curve_pnt_inters = (struct GRparms *)om$realloc( ptr = 
			(IGRchar *)(*curve_pnt_inters), size = (IGRuint)parm_bytes);
	         MEMORY_ERROR_PROCESS( *curve_pnt_inters, wrapup);
              }

	      if(inter_pnts_xyz)   
              {
               *inter_pnts_xyz = (IGRdouble *)om$realloc( ptr = 
			(IGRchar *)(*inter_pnts_xyz), size = (IGRuint)vect_bytes);
	       MEMORY_ERROR_PROCESS( *inter_pnts_xyz, wrapup);
              }

	      if(inter_props)      
              {
                *inter_props = (IGRulong *)om$realloc( ptr = 
			(IGRchar *)(*inter_props), size = (IGRuint)long_bytes);
	        MEMORY_ERROR_PROCESS( *inter_props, wrapup);
              }
	    }
	 }

        status = om$send (msg = message EMSsubbs.EMpartolbasis(msg, 
                         &my_objenv->matrix_type,
                         my_objenv->matrix, &in_world, TRUE,
                         &partolbasis.tol),
                   targetid = my_id); 
        if (!(1&status&*msg)) goto wrapup;

        location.options = EMS_PTLOC_BOXCHECK | EMS_PTLOC_ACTLOOP | 
                           EMS_PTLOC_LS_INFINITE;
        partolbasis.is_valid = TRUE;
        partolbasis.in_world = TRUE;

	count = 0;
        for( i = 0; i < numb_ints; i ++ )
         {

           second_pass = FALSE; 

           RetryThisPoint: /* JUMP BACK HERE FOR RETRY OF SEAM POINT */

           test_par[0] = u_par[i];
           test_par[1] = v_par[i];
           location.location = EMS_L_UNKNWN;    /* initialize */

           status = om$send(msg = message EMSsubbs.EMpassloop(msg, 
                                  message EMSloopset.EMpt_location
                                  (msg, test_par, &location, &partolbasis)), 
                            targetos = my_GRid.osnum,
                            targetid = my_GRid.objid);

	   if( (status IS OM_S_SUCCESS) 	   AND 
	      ((location.location IS EMS_L_INHOLE) || (location.location IS
                EMS_L_UNKNWN)) AND
	       (NOT hole_inter_valid) ) 
           {
             /* This point may be in the hole because it was on the wrong seam
              * of the surface, i.e. the surface boundary may be on the 
              * opposite seam of the surface. Check if this is true. If it is,
              * then get the matching seam point and send it back into the pt-
              * location method. We also need to update the u_par and
              * v_par with the new point. In case the point location still fails
              * it does not matter anyway and if it succeeds, then we have the
              * corerct point in the array. Make the second pass check ONLY if 
              * the surface is either closed in U or V, because otherwise it has
              * no chance of having a seam.
              */
              if (second_pass || 
                 (!(int_surface->u_phy_closed) && !(int_surface->v_phy_closed)))
                  continue;
              else
              {
                on_seam = FALSE;
                on_seam = EFfind_closest_uv_side(
                         int_surface->u_knots[int_surface->u_order - 1],
                         int_surface->u_knots[int_surface->u_num_poles],
                         int_surface->v_knots[int_surface->v_order - 1],
                         int_surface->v_knots[int_surface->v_num_poles],
                         test_par[0], test_par[1], partolbasis.tol, &side,
                         &(new_uv1[0]), &(new_uv1[1]),
                         &(new_uv2[0]), &(new_uv2[1]));                
                if (on_seam)
                {
                  dist1 = (test_par[0]-new_uv1[0])*(test_par[0]-new_uv1[0]) +
                          (test_par[1]-new_uv1[1])*(test_par[1]-new_uv1[1]);
                  dist2 = (test_par[0]-new_uv2[0])*(test_par[0]-new_uv2[0]) +
                          (test_par[1]-new_uv2[1])*(test_par[1]-new_uv2[1]);

                  if (dist1 > dist2)
                  {
                     u_par[i] = new_uv1[0]; v_par[i] = new_uv1[1];
                  }
                  else
                  {
                     u_par[i] = new_uv2[0]; v_par[i] = new_uv2[1];
                  }
                  second_pass = TRUE;
                  goto RetryThisPoint;
                }
                else
                 continue; /* move on to next uv point */
               
              }

           }

	   if( status IS OM_I_CHAN_EMPTY ) status = OM_S_SUCCESS;

           if(EMSmsgReport(status, "EMcrvsfint: passloop", FALSE)) goto wrapup;

	   id_index = *grand_num_pnt;
	   j = 3 * i;
	   k = 3 * id_index;

           ++(*grand_num_pnt);

	   if(pnt_ids)	/* add to GRids */
	    {
	      status = EMoutput_point(&loc_msg, my_id, cnst_list, 1,
		       &int_pts[j], &( (*pnt_ids)[id_index]) );
	      if(loc_msg ISNT BSSUCC)
	       {
		 status = OM_E_ABORT;
		 *msg = MSFAIL;
		 goto wrapup;
	       }
	    }

	   if(inter_pnts_xyz)	/* add to intersection points */
	    {
	      (*inter_pnts_xyz)[k]   = int_pts[j];
	      (*inter_pnts_xyz)[k+1] = int_pts[j+1];
	      (*inter_pnts_xyz)[k+2] = int_pts[j+2];
	    }

	   if(my_pnt_inters)	/* Add to my_pnt_inters the u and v values  */
	    {
	      temp_parm = (struct GRparms*) &( (*my_pnt_inters)[id_index]);
	      temp_parm->u = u_par[i];
	      temp_parm->v = v_par[i];
	      temp_parm->polygon_inx = FALSE;
	      temp_parm->leaf_id.osnum = my_GRid.osnum;
	      temp_parm->leaf_id.objid = my_GRid.objid;
	    }

            if (inter_props)
             (*inter_props)[id_index] = location.location;

	   if(curve_pnt_inters) /* Add to curve_pnt_inters the par2 values */
	    {
	      temp_parm = (struct GRparms *) &( (*curve_pnt_inters)[id_index]);
	      temp_parm->u = para[i];
	      temp_parm->v = 0.0;
	      temp_parm->polygon_inx = FALSE;
	      if(curve_obj)	/* object was sent in */
	       {
	         temp_parm->leaf_id.osnum = curve_obj->osnum;
	         temp_parm->leaf_id.objid = curve_obj->objid;
	       }
	      else		/* buffer was sent in */
	       {
	         temp_parm->leaf_id.osnum = null_obj.osnum;
	         temp_parm->leaf_id.objid = null_obj.objid;
	       }

	    }

         }	/* for i = 0-numb_ints */

      } /* END IF( numb_ints ) */

   }    /* if geo_props is SUBBC or SUBBS*/

wrapup:
  if( (NOT curve_in) AND int_curve )    om$dealloc( ptr = int_curve );
  if( int_surface )  om$dealloc( ptr = int_surface );
  if( para )         om$dealloc( ptr = para );
  if( u_par )        om$dealloc( ptr = u_par );
  if( v_par )        om$dealloc( ptr = v_par );
  if( int_pts)       om$dealloc( ptr = int_pts );
  return(status);
}

end implementation EMSsubbs;

