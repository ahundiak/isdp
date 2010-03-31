
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:42:00 $
$Locker:  $
*/

#define CHECK_RETURN_CODES 1

#include <stdio.h>
#include <stdlib.h>

#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igrdp.h"

#include "dpstruct.h"

#include "bs.h"
#include "bserr.h"
#include "bsparameters.h"

#include "ve.h"
#include "vedef.h"
#include "veerr.h"

/* prototype files */
#include "VEpr_hiding.h"
#include "VEpr_utilfnc.h"
#include "VEpr_debug.h"

#include "bscveval.h"
#include "bscvkttol2.h"

/* prototypes for static functions */
#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

static void VEprocess_hiding_pt __(( 	struct VEedge_header *near_edge,
					IGRdouble            near_par,
					struct VEedge_header *far_edge,
					IGRdouble            far_par,
					IGRdouble            knot_tol ));

static void VEdo_an_intersection __(( 	IGRdouble            param_0,
					IGRdouble            param_1,
					IGRdouble            z_0,
					IGRdouble            z_1,
					struct VEedge_header *edge0,
					struct VEedge_header *edge1,
					IGRdouble            z_tolerance,
					IGRdouble            knot_tol0,
					IGRdouble            knot_tol1,
					IGRboolean           e0_hides_e1, 
					IGRboolean           e1_hides_e0 ));

#if defined(__cplusplus)
}
#endif
#undef __


/*--- VEnot_hiding_with_self_hidden_pt --------------------------------*/

IGRboolean VEnot_hiding_with_self_hidden_pt( edge, par )

	struct VEedge_header *edge;
	IGRdouble            par;

/*
NAME
	VEnot_hiding_with_self_hidden_pt

DESCRIPTION
	Verifies that a potential hiding point is not inside a self-hidden
	region.

PARAMETERS
	edge (IN) - the edge whose self-hidden array is to be checked
	par (IN) - the parameter to test

RETURN VALUES
	TRUE - if 'par' is not a self-hidden point
	FALSE - if 'par' is a self-hidden point

GLOBALS USED
	none

HISTORY
	xx/xx/xx    Unknown Programmer
	   Creation Date
*/
   
	{
	IGRdouble *self_hidden_spans;
	IGRint	  span;

	self_hidden_spans = edge->sh_spans;
	for ( span = 0; span < (2 * edge->num_sh_spans); span += 2 )
	   {
	   if ( (self_hidden_spans[span]     <= par) &&
	        (self_hidden_spans[span + 1] >= par) )
	      return( FALSE );
	   }

	return( TRUE );
	} /* VEnot_hiding_with_self_hidden_pt */


/*--- VEprocess_hiding_pt ----------------------------------------------*/

static void VEprocess_hiding_pt( near_edge, near_par, far_edge, far_par, knot_tol )

	struct VEedge_header *near_edge;
	IGRdouble            near_par;
	struct VEedge_header *far_edge;
	IGRdouble            far_par;
	IGRdouble            knot_tol;

/*
NAME
	VEprocess_hiding_pt (static)

DESCRIPTION
	This function processes a posible hiding transition on an
	edge by adding a temp node if appropriate.

PARAMETERS
	near_edge (IN) - the edge closest to the eye
	near_par (IN) - parameter of the intersection on 'near_edge'
	far_edge (IN) - the edge farthest from the eye
	far_par(IN) - parameter of the intersection on 'far_edge'
	knot_tol (IN) - the knot tolerance to use

GLOBALS USED
	none

HISTORY
	xx/xx/xx    Unknown Parameter
	   Creation Date
*/

	{
	if (! (far_edge->status & TOTALLY_OVERLAPPED) )
	   {
	   if ( near_edge->type & EDGE_CAN_HIDE )
	      {
	      if ( VEnot_hiding_with_self_hidden_pt( near_edge, near_par ) )
	         VEinsert_temp_node( far_par, far_edge, knot_tol );
	      }
	   }
	} /* VEprocess_hiding_pt */


/*--- VEdo_an_intersection ---------------------------------------------*/

static void VEdo_an_intersection( IGRdouble            param_0,
				  IGRdouble            param_1,
				  IGRdouble            z_0,
				  IGRdouble            z_1,
				  struct VEedge_header *edge0,
				  struct VEedge_header *edge1,
				  IGRdouble            z_tolerance,
				  IGRdouble            knot_tol0,
				  IGRdouble            knot_tol1,
				  IGRboolean           e0_hides_e1,
				  IGRboolean           e1_hides_e0 )

/*
NAME
	VEdo_an_intersection (static)

DESCRIPTION
	Adds parameter nodes to the appropriate list(s) for a single
	curve-curve intersection point.

PARAMETERS
	param_0 (IN) - intersection parameter on 'edge0'
	param_1 (IN) - intersection parameter on 'edge1'
	z_0 (IN) - Z value of intersection on 'edge0'
	z_1 (IN) - Z value of intersection on 'edge1'
	edge0 (IN) - one of the edges involved in the intersection
	edge1 (IN) - the other edge involved in the intersection
	z_tolerance (IN) - the Z tolerance to use
	knot_tol0 (IN) - the knot tolerance for 'edge0'
	knot_tol1 (IN) - the knot tolerance for 'edge1'
	e0_hides_e1 (IN) - TRUE, if 'element0' can hide 'element1'
	e1_hides_e0 (IN) - TRUE, if 'element1' can hide 'element0'

GLOBALS USED
	none

HISTORY
	xx/xx/xx    Unknown Programmer
	   Creation Date
*/

	{
	/* If the z-value of curve0 at this intersection is lower then */
	/* process accordingly. Curve0 is on the hiding surface.       */

	if ( (z_1 - z_0) > z_tolerance )
	   {
	   if ( e0_hides_e1 && ((edge0->status & EDGE_CLASSIFICATION) == VISIBLE_PROFILE) )
	      VEprocess_hiding_pt( edge0, param_0, edge1, param_1, knot_tol1 );
	   }

	/* If the z-value of curve1 at this intersection is lower then */
	/* process accordingly. Curve1 is on the hiding surface.       */

	else if ( (z_0 - z_1) > z_tolerance )
	   {
	   if ( e1_hides_e0 && ((edge1->status & EDGE_CLASSIFICATION) == VISIBLE_PROFILE) )
	      VEprocess_hiding_pt( edge1, param_1, edge0, param_0, knot_tol0 );
	   }

	else /* coincidence */
	   {
	   /* Put a node on each list in which the intersection isn't at the endpoint. */
	   if ( e0_hides_e1 && ((edge0->status & EDGE_CLASSIFICATION) == VISIBLE_PROFILE) )
	      VEprocess_hiding_pt( edge0, param_0, edge1, param_1, knot_tol1 );
	   if ( e1_hides_e0 && ((edge1->status & EDGE_CLASSIFICATION) == VISIBLE_PROFILE) )
	      VEprocess_hiding_pt( edge1, param_1, edge0, param_0, knot_tol0 );
	   }

	}  /* VEdo_an_intersection */


/*--- VEcompare_edges  -------------------------------------------------*/

void VEcompare_edges( struct VEedge_header    *edge0, 
                      struct VEedge_header    *edge1,
                      struct VEelement_header *element0,
                      struct VEelement_header *element1,
                      IGRboolean              e0_hides_e1,
                      IGRboolean               e1_hides_e0,
                      IGRboolean              pseudo_int,
                      IGRboolean              self_hiding )

/*
NAME
	VEcompare_edges

DESCRIPTION
	Adds all overlap regions and potential visibility transition points
	to the "temp lists" of two compared curves.

PARAMETERS
	edge0 (IN) - one of the edges to compare
	edge1 (IN) - the other edge to compare
	element0 (IN) - the element that owns 'edge0'
	element1 (IN) - the element that owns 'edge1'
	e0_hides_e1 (IN) - TRUE, if 'element0' can hide 'element1'
	e1_hides_e0 (IN) - TRUE, if 'element1' can hide 'element0'
	pseudo_int (IN) - TRUE, if calling routine knows that the
	                  edges don't intersect and is only making this
	                  call to make the saved intersection alg.
	                  work correctly
	self_hiding (IN) - TRUE, if self-hiding is being done

GLOBALS USED
	none

HISTORY
	xx/xx/xx    Unkown Programmer
	   Creation Date
*/

	{
	BSrc rc;
	IGRpoint eval0[2], eval1[2];
	IGRboolean free_ints, free_overs;
	IGRdouble *int_pts, *par0, *par1, *end_pts, *over0, *over1;
	IGRint n_int, ii;
	IGRlong n_over;
	IGRdouble knot_tol0, knot_tol1;
	IGRdouble edge_based_dist_tol;
	struct IGRbsp_curve  *curve0, *curve1;

  
	VEupdate_heartbeat();

	if ( (edge0->status & DEBUG_EDGE) || (edge1->status & DEBUG_EDGE) )
	   {
	   fprintf( stderr, "INTERSECTING EDGES:\n" );
	   VEedge_debug( edge0 );
	   VEedge_debug( edge1 );
	   }

	/* Call VEcvcv_int to compute the intersections of curve0 and curve1 in xy-space. */
	VEcvcv_int( (IGRint *)&rc,
	            element0, element1,
	            edge0, edge1,
	            &n_int,                 /* number of intersections           */
	            (IGRpoint **)&int_pts,  /* cartesian values of intersections */
	            &par0, &par1,           /* u-values of the intersections     */
	            (IGRint *)&n_over,      /* number of overlap regions         */
	            (IGRpoint **)&end_pts,  /* overlap endpoints in xyz-space    */
	            &over0, &over1,         /* overlap endpoints in u            */
	            &free_ints,
	            &free_overs,
	            FALSE,
	            pseudo_int,
	            &edge_based_dist_tol );

	   BS_ERRCHK( rc, "VEcompare_edges:  BScvcvint failed" );

	if ( (rc == BSSUCC) &&
	     ( ! pseudo_int ) &&
	     ( !(edge0->status & TOTALLY_OVERLAPPED) || !(edge1->status & TOTALLY_OVERLAPPED) ) )
	   {
	   curve0 = edge0->gm_curve3d->bspcv;
	   curve1 = edge1->gm_curve3d->bspcv;

	   if ( n_int || n_over )
	      {
	      BScvkttol2( curve0->order, curve0->knots, curve0->num_poles,
	                  curve0->poles, curve0->weights, &knot_tol0, &rc );
                
	      BScvkttol2( curve1->order, curve1->knots, curve1->num_poles,
	                  curve1->poles, curve1->weights, &knot_tol1, &rc);
	      } /* end if (n_int || n_over) */

	   /* Process overlaps - mark all hidden portions of temp-list as OVERLAPPED. */
	   n_over *= 2;
	   for ( ii = 0; ii < n_over; ii += 2 )
	      {
	      /* Evaluate the curves at the first endpoint of each overlap region */
	      /* to see which is greater in z. The region which is greater in z   */
	      /* should be marked as OVERLAPPED.                                  */

	      BScveval( curve0, over0[ii], 0, (IGRpoint *)eval0[0], &rc );
	         BS_ERRCHK(rc, "VEcompare_edges: BScveval 0 failed");
 
	      BScveval( curve1, over1[ii], 0, (IGRpoint *)eval1[0], &rc );
	         BS_ERRCHK(rc, "VEcompare_edges: BScveval 1 failed");

	      BScveval( curve0, over0[ii+1], 0, (IGRpoint *)eval0[1], &rc );
	         BS_ERRCHK(rc, "VEcompare_edges: BScveval 2 failed");
 
	      BScveval( curve1, over1[ii+1], 0, (IGRpoint *)eval1[1], &rc );
	         BS_ERRCHK(rc, "VEcompare_edges: BScveval 3 failed");

	      /* Check for overlap regions that should really be intersections */
	      /* and process accordingly.  Overlap regions must cross in Z and */
	      /* not be parallel in XYZ space to be considered intersections.  */

	      if ( VEoverlap_is_really_intersection( eval0[0], eval1[0],
	                                             eval0[1], eval1[1], edge_based_dist_tol ) )
	         {
	         over0[ii] = (over0[ii] + over0[ii+1]) * 0.5;
	         over1[ii] = (over1[ii] + over1[ii+1]) * 0.5;

	         VEdo_an_intersection( over0[ii], over1[ii], eval0[0][2], eval0[0][2], edge0, edge1,
	                               edge_based_dist_tol, knot_tol0, knot_tol1,
	                               e0_hides_e1, e1_hides_e0 );
	         }
	      else /* legitimate overlap region */
	         {
	         VEprocess_overlap( edge0, edge1,
	                            &(over0[ii]), &(over1[ii]),
	                            (IGRdouble *)eval0, 
                                    (IGRdouble *)eval1,
	                            e0_hides_e1, e1_hides_e0,
	                            edge_based_dist_tol, knot_tol0, knot_tol1, self_hiding );
	         }
	      } /* end: for */

	   /* Process intersections - find points of potential visibility */
	   /* transition and mark accordingly.                            */
	   if ( (e0_hides_e1) || (e1_hides_e0) )
	      {
	      for ( ii = 0; ii < n_int; ii++ )
	         {
	         /* Evaluate the intersection point on each curve to find which is */
	         /* closer in z.                                                   */

	         BScveval( curve0, par0[ii], 0, (IGRpoint *)eval0[0], &rc );
	            BS_ERRCHK(rc, "VEcompare_edges: BScveval 4 failed");

	         BScveval( curve1, par1[ii], 0, (IGRpoint *)eval1[0], &rc );
	            BS_ERRCHK(rc, "VEcompare_edges: BScveval 5 failed");

	         VEdo_an_intersection( par0[ii], par1[ii], eval0[0][2], eval1[0][2], edge0, edge1,
	                               edge_based_dist_tol, knot_tol0, knot_tol1,
	                               e0_hides_e1, e1_hides_e0 );

	         } /* end: for */

	      } /* end: if */

	   } /* end if both edges are not totally overlapped */ 

	if ( (int_pts) && (free_ints) )
	   {
	   free( (char *) int_pts );
	   free( (char *) par0 );
	   free( (char *) par1 );
	   }

	if ( (end_pts) && (free_overs) )
	   {
	   free( (char *) end_pts );
	   free( (char *) over0 );
	   free( (char *) over1 );
	   }

	if ( (edge0->status & DEBUG_EDGE) || (edge1->status & DEBUG_EDGE) )
	   {
	   fprintf( stderr, "FINISHED INTERSECTING EDGES:\n" );
	   VEedge_debug( edge0 );
	   VEedge_debug( edge1 );
	   }

	}  /* VEcompare_edges */

