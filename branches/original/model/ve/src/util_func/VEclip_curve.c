
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:42:01 $
$Locker:  $
*/


#include <stdio.h>

#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "igrdp.h"

#include "dpstruct.h"

#include "bs.h"
#include "bsparameters.h"

#include "vedef.h"
#include "ve.h"

#include "go.h"

/* prototype files */
#include "VEpr_utilfnc.h"
#include "VEpr_utilimp.h"

#include "bscveval.h"
#include "bspl_cv_int.h"
#include "bsxtractpar.h"

/* prototypes for static functions */

#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

static IGRint VEcheck_visibility __(( 	IGRdouble           *point, 
					struct VEplane      *plane,
					IGRdouble           tol ));

static IGRboolean VEendpoint_is_visible __((
					IGRdouble           *point,
					IGRdouble           *tangent,
					struct VEplane      *plane,
					IGRdouble           tol ));

static IGRint VEcv_range_to_plane_relationship __((
					struct IGRbsp_curve *curve,
					struct VEplane	    *clip_plane,
					IGRdouble           tol ));

static struct VEedge_header *VEsetup_edge __((
					struct VEedge_header *parent_edge,
					struct IGRbsp_curve  *new_curve ));

static IGRboolean VEsplit_edge __((
					struct VEedge_header *parent_edge,
					IGRint               num_int,
					IGRdouble            *int_params,
					struct VEedge_header **split_list_head,
					struct VEedge_header **split_list_tail ));

static IGRboolean VEclip_per __((
			 		struct VEedge_header **edge_list,
					struct VEplane       *clip_plane,
					IGRboolean           z_clipping,
					IGRboolean           *was_clipped ));

#if defined(__cplusplus)
}
#endif

#undef __


#ifdef	DEBUG
#undef	DEBUG
#endif
#ifdef	KNOT_TOL
#undef	KNOT_TOL
#endif
#ifdef	PARTIAL_TOL
#undef	PARTIAL_TOL
#endif
#ifdef	VISIBLE
#undef	VISIBLE
#endif
#ifdef	INVISIBLE
#undef	INVISIBLE
#endif
#ifdef	ON_PLANE
#undef	ON_PLANE
#endif

#define DEBUG		0
#define KNOT_TOL	0.000001
#define PARTIAL_TOL	0.000001
#define VISIBLE		0
#define INVISIBLE	1
#define ON_PLANE	2
#define CROSS_PLANE	3


/* External Global Variables */
extern struct VEexecution_parms VEexec_parms;

/* Static Local Variables */
static
   IGRdouble	xyz_tol,
   		*int_params,
   		*start_params, *end_params;
static
   IGRdouble	*int_points;


/*-- VEcheck_visibility  -------------------------------------------------*/

static IGRint VEcheck_visibility( point, plane, tol )

	IGRdouble      *point, tol;
	struct VEplane *plane;

/*
NAME
	VEcheck_visibility (static)

DESCRIPTION
	Finds out if a point is visible, lies on the clip plane (within a given
	tolerance), or is invisible.  It assumes that the plane normal vector
	is already normalized as this will affect tolerancing.

PARAMETERS
	point (IN) - the point to test
	plane (IN) - the clip plane to test the point against
	tol (IN) - the tolerance to use in the test

RETURN VALUES
	VISIBLE - if the point is visible
	INVISIBLE - if the point is invisible
	ON_PLANE - if the point is on the plane

GLOBALS USED
	none

HISTORY
	05/01/87    S.A. Rapa
	   Created
*/

 {
   IGRdouble	plane_point[3],
		test_vector[3],
		dot;

   /*
    * Modify plane point to take tolerancing into account
    */

   plane_point[0] = plane->point[0] + (plane->normal[0] * tol);
   plane_point[1] = plane->point[1] + (plane->normal[1] * tol);
   plane_point[2] = plane->point[2] + (plane->normal[2] * tol);

   /*
    * Get vector from plane point to test point
    */

   test_vector[0] = point[0] - plane_point[0];
   test_vector[1] = point[1] - plane_point[1];
   test_vector[2] = point[2] - plane_point[2];

   /*
    * Dot product >= 0 means point is visible
    */

   dot = (test_vector[0] * plane->normal[0]) +
	 (test_vector[1] * plane->normal[1]) +
	 (test_vector[2] * plane->normal[2]);
   if (dot >= 0.0)
      return (VISIBLE);

   /*
    * Move plane point back a bit & recompute visibility to 
    * see if point lies within the plane.
    */

   plane_point[0] = plane->point[0] - (plane->normal[0] * tol);
   plane_point[1] = plane->point[1] - (plane->normal[1] * tol);
   plane_point[2] = plane->point[2] - (plane->normal[2] * tol);

   test_vector[0] = point[0] - plane_point[0];
   test_vector[1] = point[1] - plane_point[1];
   test_vector[2] = point[2] - plane_point[2];

   dot = (test_vector[0] * plane->normal[0]) +
	 (test_vector[1] * plane->normal[1]) +
	 (test_vector[2] * plane->normal[2]);
   if (dot >= 0.0)
      return (ON_PLANE);
   else
      return (INVISIBLE);
 }


/*-- VEendpoint_is_visible -----------------------------------------------*/

static IGRboolean VEendpoint_is_visible (point, tangent, plane, tol)

	IGRdouble *point, *tangent, tol;
	struct VEplane *plane;

/*
NAME
	VEendpoint_is_visible (static)

DESCRIPTION
	Determines if a curve's endpoint is visible by using the tangent
	vector in cases where it lies on the clip plane.

PARAMETERS
	point (IN) - the curve endpoint to test
	tangent (IN) - the curve tangent at the endpoint
	plane (IN) - the plane to test against
	tol (IN) - the tolerance to use in the test

RETURN VALUES
	TRUE - if the point is visible
	FALSE - if the point is invisible

GLOBALS USED
	none

HISTORY
	05/01/87    S.A. Rapa
	   Created
*/

 {
   IGRint	visib;
   IGRdouble	dot;

   visib = VEcheck_visibility (point, plane, tol);
   if (visib == VISIBLE)
      return (TRUE);
   else if (visib == INVISIBLE)
      return (FALSE);
   else
    {
      dot = (tangent[0] * plane->normal[0]) +
	    (tangent[1] * plane->normal[1]) +
	    (tangent[2] * plane->normal[2]);
      if (dot >= 0.0)
         return (TRUE);
      else
         return (FALSE);
    }
 }


/*-- VEcv_range_to_plane_relationship ------------------------------------*/

static IGRint VEcv_range_to_plane_relationship( curve, clip_plane, tol )

	struct IGRbsp_curve *curve;
	struct VEplane	    *clip_plane;
	IGRdouble           tol;

/*
NAME
	VEcv_range_to_plane_relationship (static)

DESCRIPTION
	Scans the unweighted range of a curve's poles to see if they
	straddle a specified clipping plane.

PARAMETERS
	curve (IN) - curve to test
	clip_plane (IN) - clipping plane to test against
	tol (IN) - tolerance to use in the test

RETURN VALUES
	VISIBLE - if the curve is in front of the clipping plane
	INVISIBLE - if the curve is behind the clipping plane
	CROSS_PLANE - if the curve crosses the clipping plane
	ON_PLANE - if the curve is on the clipping plane

GLOBALS USED
	none

HISTORY
	03/27/87    S.A. Rapa
	   Created
*/

 {
   IGRdouble	*pole_ptr,
   		*w_ptr,
   		unweighted_pole[3];
   IGRint	pole,
		temp_visib;
   IGRboolean	visible_flag = FALSE,
		invisible_flag = FALSE;

   pole_ptr = curve->poles;

   if (curve->rational)
    {
      w_ptr = curve->weights;

      for (pole = 0; pole < curve->num_poles; pole++)
       {
         unweighted_pole[0] = *pole_ptr++ / *w_ptr;
         unweighted_pole[1] = *pole_ptr++ / *w_ptr;
         unweighted_pole[2] = *pole_ptr++ / *w_ptr++;
         temp_visib = VEcheck_visibility (unweighted_pole, clip_plane, tol);
         if (temp_visib == VISIBLE)
            visible_flag = TRUE;
         else if (temp_visib == INVISIBLE)
            invisible_flag = TRUE;
       }
    }

   else
    {
      for (pole = 0; pole < curve->num_poles; pole++)
       {
         temp_visib = VEcheck_visibility (pole_ptr, clip_plane, tol);
         pole_ptr += 3;
         if (temp_visib == VISIBLE)
            visible_flag = TRUE;
         else if (temp_visib == INVISIBLE)
            invisible_flag = TRUE;
       }
    }

   if (visible_flag)
      if (invisible_flag)
	 return (CROSS_PLANE);
      else
	 return (VISIBLE);
   else
      if (invisible_flag)
	 return (INVISIBLE);
      else
	 return (ON_PLANE);
 }


/*-- VEdelete_edge -----------------------------------------------------*/

void VEdelete_edge( edge_address )

	struct VEedge_header **edge_address;

/*
NAME
	VEdelete_edge

DESCRIPTION
	Frees up all memory associated with an edge node & removes that node
	from the edge list.

PARAMETERS
	edge_address (IN/OUT) - pointer to the "next" field of the previous
	                        edge in the edge list

GLOBALS USED
	none

HISTORY
	03/27/87    S.A. Rapa
	   Created
*/

 {
   struct
      VEedge_header	*next;

   next = (*edge_address)->next;

   VEfree_visib_node_list( (*edge_address)->visib_list );
   VEfree_edge_header( (*edge_address) );  /* also frees up curve	*/
   
   *edge_address = next;
 }


/*-- VEsetup_edge --------------------------------------------------------*/

static struct VEedge_header *VEsetup_edge( parent_edge, new_curve )

	struct VEedge_header *parent_edge;
	struct IGRbsp_curve  *new_curve;

/*
NAME
	VEsetup_edge (static)

DESCRIPTION
	Returns a new edge node for a given curve & initializes it with 
	data taken from the curve's parent.  It assumes the new curve is
	a piece of the parent edge (i.e. an active split).

PARAMETERS
	parent_edge (IN) - parent edge of the new, split curve
	new_curve (IN) - geometry of the new split curve

GLOBALS USED
	none

RETURN VALUES
	A pointer to a new edge representing the new_curve is returned.

HISTORY
	03/27/87    S.A. Rapa
	   Created
*/

 {
   struct
      VEedge_header	*new_edge;
   struct
      VEvisib_node	*prev_node,	/* points to parent's list	*/
      			*this_node,	/* points to parent's list	*/
      			*new_node,	/* points to new list		*/
      			*end_node;	/* points to new list		*/
   IGRint		order;
   IGRdouble		min_u,
   			max_u;

   new_edge = VEalloc_edge_header();
   new_edge->gm_curve3d        = VEalloc_geom_curve( 0, 0, 0, 0 );
   new_edge->gm_curve3d->bspcv = new_curve;
   new_edge->type              = parent_edge->type;
   new_edge->iso_parm          = parent_edge->iso_parm;
   new_edge->edge_id           = parent_edge->edge_id;
   new_edge->status            = parent_edge->status;

   VEset_split_curve_geom_type( parent_edge->gm_curve3d, new_edge->gm_curve3d );

   /*
    * Copy pertinent part of parent's visibility list.
    */

   order = new_curve->order;
   min_u = new_curve->knots[order - 1];
   max_u = new_curve->knots[new_curve->num_knots - order];

   /*
    * First node; 
    */

   prev_node = parent_edge->visib_list;
   this_node = prev_node->next;
   while (this_node->u <= min_u)
    {
      prev_node = this_node;
      this_node = prev_node->next;
    }
   new_node = VEalloc_visib_node(min_u);
   new_node->visib      = prev_node->visib;
   new_edge->visib_list	= new_node;
   end_node		= new_node;

   /*
    * Middle nodes
    */

   while (this_node->u < max_u)
    {
      new_node = VEalloc_visib_node(this_node->u);
      new_node->visib      = this_node->visib;
      end_node->next	   = new_node;
      end_node		   = new_node;

      this_node = this_node->next;
    }

   /*
    * Last node
    */

   new_node = VEalloc_visib_node(max_u);
   new_node->visib      = this_node->visib;
   end_node->next	= new_node;

   return (new_edge);
 }


/*-- VEsplit_edge --------------------------------------------------------*/

static IGRboolean VEsplit_edge( parent_edge, num_int, int_params,
	                        split_list_head, split_list_tail )

	struct VEedge_header *parent_edge,
	                     **split_list_head,
	                     **split_list_tail;
	IGRint               num_int;
	IGRdouble            *int_params;

/*
NAME
	VEsplit_edge

DESCRIPTION
	Splits an edge node in a list of edges with nodes that represent
	the visible portions of the original edge.  Parameterization of
	the split pieces will match that of the parent curve.  The split
	pieces are returned as a linked list via pointers to the head
	and tail of the list.

PARAMETERS
	parent_edge (IN) - parent edge of the split
	split_list_head (OUT) - pointer to head of the list of split edges
	split_list_tail (OUT) - pointer to tail of the list of split edges
	num_int (IN) - number of places to split edge
	int_params (IN) - array of parameters at which to split the edge

RETURN VALUES
	TRUE - if split succeeded
	FALSE - if split failed	

GLOBALS USED
	none

HISTORY
	03/27/87    S.A. Rapa
	   Created
*/

 {
   struct
      VEedge_header	*this_edge;
   struct
      IGRbsp_curve	*active_curve;
   IGRint		sort1, sort2,
   			piece;
   IGRdouble		temp_sort;
   IGRboolean		first_split;


   /*
    * Sort the sub-piece end points (intersection list).
    */
  
   for (sort1 = 0; sort1 < num_int - 1; sort1++)
      for (sort2 = sort1 + 1; sort2 < num_int; sort2++)
         if (int_params[sort1] > int_params[sort2])
	  {
  	    temp_sort	    = int_params[sort1];
  	    int_params[sort1] = int_params[sort2];
  	    int_params[sort2] = temp_sort;
	  }

   /*
    * Split out the visible pieces.
    */

   for (piece = 0, first_split = TRUE; piece < num_int; piece += 2)
    {
      active_curve = VEcurve_split( parent_edge->gm_curve3d->bspcv,
                                    int_params[piece],
                                    int_params[piece + 1] );
                                    
      /*
       * Add new edge to list.	
       */

      if ( active_curve )
         {
	 /* the curve split succeeded */
         this_edge = VEsetup_edge( parent_edge, active_curve );
         if (first_split)
            *split_list_tail = this_edge;

         this_edge->next  = *split_list_head;
         *split_list_head = this_edge;
         first_split = FALSE;
         }
    } /* for every new curve */

   return ( ! first_split );
 }

/*--- VEclip_per ----------------------------------------------------------*/

static IGRboolean VEclip_per( 	struct VEedge_header **edge_list,
				struct VEplane       *clip_plane,
				IGRboolean           z_clipping,
				IGRboolean           *was_clipped )

/*
NAME
	VEclip_per (static)

DESCRIPTION
	Clip an edge against a clipping plane and replace it in its edge
	list with the list of clipped pieces

PARAMETERS
	edge_list (IN/OUT) - pointer to the next field of the previous edge
	clip_plane (IN) - clipping plane to clip against
	z_clipping (IN) - TRUE, if this is a z clipping plane
	was_clipped (OUT) - TRUE, if edge was clipped; FALSE, otherwise

GLOBALS USED
	none

HISTORY
	xx/xx/87    S.A. Rapa
	   Created
*/

 {
   BSrc			rc;
   IGRboolean		return_code,
   			status;
   IGRint		order,
   			num_knots,
   			num_int,
   			num_segs_in_plane,
   			this_intersection,
   			cv_pl_relationship;
   IGRdouble		low_param, high_param;
   IGRpoint		test_point[2];
   struct
      VEedge_header	*parent_edge,
			**parent_edge_address,
			*split_head,
			*split_tail;

   /*
    * BEGIN
    */

   return_code = TRUE;
   parent_edge_address = edge_list;

   while ( *parent_edge_address )
    {
      parent_edge = *parent_edge_address;

      if ( parent_edge->gm_curve3d )
         {
         cv_pl_relationship = VEcv_range_to_plane_relationship
	   	 		   (parent_edge->gm_curve3d->bspcv, clip_plane, xyz_tol);
         if (cv_pl_relationship == CROSS_PLANE)
            {
  	    /*
 	     * Find out how the curve is parameterized
	     */

	    order      = parent_edge->gm_curve3d->bspcv->order;
	    num_knots  = parent_edge->gm_curve3d->bspcv->num_knots;
	    low_param  = parent_edge->gm_curve3d->bspcv->knots[order - 1];
	    high_param = parent_edge->gm_curve3d->bspcv->knots[num_knots - order];

	    /*
	     * Intersect with clip plane.
	     */

	    status = BSpl_cv_int  (&rc,
   				   parent_edge->gm_curve3d->bspcv,
   				   clip_plane->point,
   				   clip_plane->normal,
   				   &num_int,
   				   int_points,
   				   int_params,
   				   &num_segs_in_plane,
   				   start_params,
   				   end_params);

	    if (!status)
	       {
	       fprintf (stderr, "VEclip_curve: Error in BSpl_cv_int # %d.\n", rc);
               return_code = FALSE;
               break;
	       }

	    /*
	     * Evaluate curve at start point ... will need this info later whether
	     * it actually intersected the plane or not.
	     */

	    BScveval (parent_edge->gm_curve3d->bspcv, low_param, 1, test_point, &rc);
	    if (rc != BSSUCC)
	       {
	       fprintf (stderr, "VEclip_curve: Error in BScveval (1) # %d.\n", rc);
               return_code = FALSE;
               break;
               }

	    /*
	     * Remove curve endpoints from intersection list ... they don't count
	     * as "real" intersections for our purposes.
	     */

	    this_intersection = 0;
	    while (this_intersection < num_int)
	       if ((int_params[this_intersection] < (low_param + KNOT_TOL)) ||
	 	   (int_params[this_intersection] > (high_param - KNOT_TOL))  )
	          {
	          num_int--;
	          if (this_intersection < num_int)
	             int_params[this_intersection] = int_params[num_int];
	          }
	       else
	          this_intersection++;

	    if (num_int == 0)
	       {
	       /*
	        * Not clipped; check visibility of whole curve.  Whenever an
	        * endpoint is tested for visibility, if it is within tolerance
	        * of the clip plane the first derrivative is used to find
	        * visibility at that point.
	        */

	       if (! VEendpoint_is_visible (test_point[0], test_point[1], clip_plane, xyz_tol))
	          {
	          /*
	           * Edge is invisible, so remove it from the list.
	           */

#if DEBUG
fprintf (stderr, "VEclip_curve: Edge rejected, no intersections.\n");
#endif

	          *was_clipped = TRUE;
	          VEdelete_edge (parent_edge_address);
	          }
	       else
	          {
	          /* Edge is totally visible */
#if DEBUG
fprintf (stderr, "VEclip_curve: Edge accepted, no intersections.\n");
#endif

	          parent_edge_address = &(parent_edge->next);
	          }
	       }

	    else		/* the curve does intersect clip plane */
	       {

#if DEBUG
fprintf (stderr, "VEclip_curve: Edge accepted and split with intersections.\n");
#endif

	       *was_clipped = TRUE;

	       /*
	        * Add endpoints of parent curve to list if they are visible
	        */

	       if (VEendpoint_is_visible (test_point[0], test_point[1], clip_plane, xyz_tol))
	          {
	          int_params[num_int] = low_param;
	          num_int++;
	          }

	       BScveval (parent_edge->gm_curve3d->bspcv, high_param, 1, test_point, &rc);
	       if (rc != BSSUCC)
	          {
	          fprintf (stderr, "VEclip_curve: Error in BScveval (2) # %d.\n", rc);
                  return_code = FALSE;
                  break;
	          }

	       test_point[1][0] = - test_point[1][0];	/* tangent must point towards */
	       test_point[1][1] = - test_point[1][1];	/* the center of the curve    */
	       test_point[1][2] = - test_point[1][2];
	       if (VEendpoint_is_visible (test_point[0], test_point[1], clip_plane, xyz_tol))
	          {
	          int_params[num_int] = high_param;
	          num_int++;
	          }
	    
	         return_code = VEsplit_edge (parent_edge, num_int, int_params,
		 		           &split_head, &split_tail		);
	       if (! return_code)
	          break;

	       /*
	        * Replace the parent node in the list with the split list.  If 
	        * Z clipping, make sure the newly formed curves are clipped
	        * again to insure that all poles are in front of the clip plane.
	        */

	       VEdelete_edge (parent_edge_address);
	       split_tail->next = *parent_edge_address;
	       *parent_edge_address = split_head;
	       if (! z_clipping)
	          parent_edge_address = &(split_tail->next);
	       }
            }

         else if (cv_pl_relationship == INVISIBLE) /* edge's range does not straddle clip plane */
            {
	    /*
	     * Edge is trivially rejected, so remove it from the list.
	     */

#if DEBUG
fprintf (stderr, "VEclip_curve: Edge trivially rejected.\n");
#endif

	    *was_clipped = TRUE;
	    VEdelete_edge (parent_edge_address);
	    }
	 else
	    {
	    /*
	     * Edge is trivially accepted.
	     */

#if DEBUG
fprintf (stderr, "VEclip_curve: Edge trivially accepted.\n");
#endif

	    parent_edge_address = &(parent_edge->next);
            }
         }
      else
         {
         /* accept dummy shared edge */
         parent_edge_address = &(parent_edge->next);
         }
    } /* while */

   return (return_code);   
 }


/*-- VEclip_curve ------------------------------------------------------*/

IGRboolean VEclip_curve( edge_list, clipping_planes, was_clipped )

	struct VEedge_header **edge_list;
	struct VEplane       *clipping_planes;
	IGRboolean           *was_clipped;

/*
NAME
	VEclip_curve

DESCRIPTION
	Clip a list of edges against an array of clipping planes and replace
	the clipped edges with their clipped pieces.

PARAMETERS
	edge_list (IN) - the list of edges to clip
	clipping_planes (IN) - array of six clipping planes
	was_clipped (IN) - TRUE, if any edges were clipped

RETURN VALUES
	TRUE, if clipping was successful
	FALSE, otherwise

GLOBALS USED
	int_params, start_params, end_params, int_points (static)

HISTORY
	xx/xx/87    S.A. Rapa
	   Creation Date
*/

 {
   IGRboolean	status;
   BSrc		rc;
   IGRint	max_poles;
   struct
      VEedge_header	*this_edge;

   status = TRUE;
   *was_clipped = FALSE;
   
   BSxtractpar (&rc, BSTOLCHRDHT, &xyz_tol);

#if DEBUG
fprintf (stderr, "\nVEclip_curve: xyz_tol = %20.10lf\n", xyz_tol);
#endif

   /*
    * Pre-scan edge list to find maximum number of poles on a curve.
    */

   max_poles = 0;
   this_edge = *edge_list;
   while (this_edge)
    {
      if ( this_edge->gm_curve3d )
         {
         if (this_edge->gm_curve3d->bspcv->num_poles > max_poles)
            max_poles = this_edge->gm_curve3d->bspcv->num_poles;
         }
      this_edge = this_edge->next;
    }

   if ( max_poles == 0 )
      {
      /* the edge list contained all dummy edges => return */
      return( TRUE );
      }
      
   /* Get re-usable temporary memory needed for intersecting */
   VEget_curve_clip_memory( max_poles,
   	                    &int_points, &int_params, &start_params, &end_params );

   /*
    * Clip against the 4 planes
    */

#if DEBUG
fprintf (stderr, "FAR Z CLIP:\n\n");
#endif

   if (status)
      status = VEclip_per (edge_list, &clipping_planes[5], FALSE, was_clipped );

#if DEBUG
fprintf (stderr, "MIN X CLIP:\n\n");
#endif

   if (status)
      status = VEclip_per (edge_list, &clipping_planes[0], FALSE, was_clipped );

#if DEBUG
fprintf (stderr, "MIN Y CLIP:\n\n");
#endif

   if (status)
      status = VEclip_per (edge_list, &clipping_planes[1], FALSE, was_clipped );

#if DEBUG
fprintf (stderr, "MAX X CLIP:\n\n");
#endif

   if (status)
      status = VEclip_per (edge_list, &clipping_planes[3], FALSE, was_clipped );

#if DEBUG
fprintf (stderr, "MAX Y CLIP:\n\n");
#endif

   if (status)
      status = VEclip_per (edge_list, &clipping_planes[4], FALSE, was_clipped );

   return (status);
 }
