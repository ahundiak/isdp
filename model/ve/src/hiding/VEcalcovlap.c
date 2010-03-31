
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:42:00 $
$Locker:  $
*/


#define CHECK_RETURN_CODES 1

#include <stdio.h>
#include <stdlib.h>
#include <math.h>

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
#include "veerr.h"

#include "ve_timing.h"

/* prototype files */
#include "VEpr_hiding.h"
#include "VEpr_utilfnc.h"

#include "bsadd_ktr.h"
#include "bscveval.h"
#include "bsxtractpar.h"

#if TIMING
extern IGRdouble  VEtime_water;
extern IGRint     VEcount_water;
extern struct tms VEs_time;
extern struct tms VEe_time;
#endif


#ifdef	PARTIAL_TOL
#undef	PARTIAL_TOL
#endif
#ifdef	PARALLEL_TOL
#undef	PARALLEL_TOL
#endif
#ifdef	MAX_ITERATIONS
#undef  MAX_ITERATIONS
#endif

#define DEBUG_FIND_TRANS	0
#define DEBUG_OVERLAP		0
#define PARTIAL_TOL		0.00000001
#define PARALLEL_TOL		0.99
#define MAX_ITERATIONS		13

/* External Global Variables */
extern struct VEexecution_parms VEexec_parms;

/* Static Local Variables */
static IGRdouble           line_knots[4] = {0.0, 0.0, 1.0, 1.0};
static IGRdouble           line_poles[6];
static IGRdouble           min_param, max_param;

static struct IGRbsp_curve global_line = { 2,                /* order                 */
	                                   FALSE, FALSE,     /* periodic, non-uniform */
	                                   2, line_poles,    /* num_poles, poles      */
	                                   4, line_knots,    /* num_knots, knots      */
	                                   FALSE, NULL,      /* ratinal, weights      */
	                                   FALSE, FALSE,     /* planar, phy_closed    */
	                                   0, NULL };        /* num_boudnaries, bdrys */

/* prototypes for static functions */
#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

static IGRboolean VEget_exact_transition_pt __((
						struct IGRbsp_curve *curve,
						IGRint              trans_index,
						IGRdouble           *param, 
						IGRdouble           *x,
						IGRdouble           *y,
						IGRdouble           *z,
						IGRdouble           knot_tol ));

static IGRboolean VEvectors_are_parallel __((	IGRdouble           v1_x,
						IGRdouble           v1_y, 
						IGRdouble           v2_x,
						IGRdouble           v2_y ));

static void VEfind_next_visib_trans_region __((	struct IGRbsp_curve *curve,
						IGRboolean          is_start,
						IGRdouble           *param1,
						IGRdouble           *param2,
						IGRdouble           *x,
						IGRdouble           *y,
						IGRdouble           *z,
						IGRboolean          *is_transition, 
						IGRboolean          *is_along_line_of_sight,
						IGRdouble           knot_tol,
						IGRdouble           cht ));

static void VEprocess_trans_pt __((		struct VEedge_header *edge,
					IGRdouble            trans_param,
					IGRdouble            last_trans,
					IGRdouble            next_trans,
					IGRdouble            trans_x,
					IGRdouble            trans_y,
					IGRdouble            trans_z,
					IGRdouble            knot_tol,
					IGRdouble            cht ));

static void VEmake_span_overlapped __((	IGRdouble            parm,
					struct VEtemp_node   *node_list,
					IGRdouble            visible_parm,
					IGRdouble            knot_tol ));

static void VEdetermine_overlaps __(( 	struct VEedge_header *edge,
					IGRdouble            knot_tol ));

#if defined(__cplusplus)
}
#endif

#undef __

/*-- VEget_exact_transition_pt -----------------------------------------*/

static IGRboolean VEget_exact_transition_pt( curve, trans_index, param, x, y, z, knot_tol )

	struct IGRbsp_curve *curve;
	IGRint              trans_index;
	IGRdouble           *param, *x, *y, *z, knot_tol;

/*
NAME
	VEget_exact_transition_pt (static)

DESCRIPTION
	Given the index of a pole where a potential transition point may be,
	this routine will iterate to find the exact parameter and XYZ
	coordinates of the transition point.

PARAMETERS
	curve (IN) - the curve whose transition point is to be calculated
	trans_index (IN) - pole index of potential transition
	param (OUT) - parameter of transition point
	x (OUT) - X coordinate of transition point
	y (OUT) - Y coordinate of transition point
	z (OUT) - Z coordinate of transition point
	knot_tol (IN) - knot tolerance to use

RETURN VALUES
	TRUE - if a transition point was found
	FALSE - if a transition point was not found

GLOBALS USED
	min_param, max_param (static)

HISTORY
	09/02/87    S.A. Rapa
	   Created
*/

	{
	BSrc      rc;
	IGRint    cntr;
	IGRpoint  test_point[3];
	IGRdouble next_param,
	          dxdu, dydu,
	          abs_last_dxdu, abs_last_dydu;

#if DEBUG_FIND_TRANS
	fprintf( stderr, "   Possible transition near pole # %d\n", trans_index );
#endif

	*param = curve->knots[trans_index + 1];

	if ( curve->order == 2 )
	   {
	   /* if curve is order 2, then middle pole is exact transition point */
	   cntr = 3 * trans_index;
	   *x = curve->poles[cntr++];
	   *y = curve->poles[cntr++];
	   *z = curve->poles[cntr];

	   return (TRUE);
	   }
      	
	/*
	 * Possible start of overlap region found ... get node value
	 * for pole at "trans_index" as first guess of iteration to
	 * find solution.
	 */

	for ( cntr = trans_index + 2; cntr < trans_index + curve->order; cntr++ )
	   *param += curve->knots[cntr];
	*param /= (IGRdouble) (curve->order - 1);

	/* If our transition pole is at a sharp point on the curve (i.e. the node */
	/* value equals any knot used to compute the node since they're all       */
	/* identical), then the middle pole is the exact transition point.        */

	if (fabs( *param - curve->knots[trans_index + 1] ) < knot_tol)
 	   {
	   cntr = 3 * trans_index;
	   *x = curve->poles[cntr++];
	   *y = curve->poles[cntr++];
	   *z = curve->poles[cntr];

#if DEBUG_FIND_TRANS
	   fprintf( stderr, "   Sharp point: x, y, z = %13.7lf, %13.7lf, %13.7lf\n", *x, *y, *z );
	   fprintf( stderr, "                param   = %12.10lf\n", *param );
#endif

	   return( TRUE );
	   }

	/* Iterate to find point where dx/du = 0 and dy/du = 0. */
	abs_last_dxdu = 1e100;
	abs_last_dydu = 1e100;

	for ( cntr = 0; cntr < MAX_ITERATIONS; cntr++ )
	   {
	   BScveval( curve, *param, 2, (IGRpoint *)test_point[0], &rc );
	      BS_ERRCHK( rc, "VEget_exact_trans_pt: BScveval failed" );

	   if ( rc != BSSUCC )
	      return( FALSE );

#if DEBUG_FIND_TRANS
	   fprintf( stderr, "   Iteration point: x, y, z = %13.7lf, %13.7lf, %13.7lf\n",
	            test_point[0][0], test_point[0][1], test_point[0][2] );
	   fprintf( stderr, "                    param   = %12.10lf\n", *param );
	   fprintf( stderr, "                    x', x'' = %13.7lf, %13.7lf\n",
	            test_point[1][0], test_point[2][0] );
	   fprintf( stderr, "                    y', y'' = %13.7lf, %13.7lf\n",
	            test_point[1][1], test_point[2][1]);
#endif

	   dxdu = test_point[1][0];
	   dydu = test_point[1][1];

	   /* Have we found the transition point? */
	   if ( (fabs( dxdu ) < PARTIAL_TOL ) && (fabs( dydu ) < PARTIAL_TOL) )
	      {
#if DEBUG_FIND_TRANS
	      fprintf( stderr, "   Iteration complete.\n" );
#endif

	      *x = test_point[0][0];
	      *y = test_point[0][1];
	      *z = test_point[0][2];
	      return( TRUE );
	      }

	   /* Are dx/du and dy/du BOTH decreasing? */
	   if ( (fabs( dxdu ) > (abs_last_dxdu + PARTIAL_TOL)) ||
	        (fabs( dydu ) > (abs_last_dydu + PARTIAL_TOL)) )
	      return( FALSE );

	   /* Get next iteration point */
	   if ( fabs( test_point[2][0] ) > PARTIAL_TOL )
	      next_param = *param - (dxdu / test_point[2][0]);
	   else if ( fabs( test_point[2][1] ) > PARTIAL_TOL )
	      next_param = *param - (dydu / test_point[2][1]);
	   else
	      return( FALSE );
	     

	   /* With non-uniform curves and/or ones with order > 3, the */
	   /* second derrivative may not be constant, even over small */
	   /* regions. Thus, "next_param"  may be outside of the      */
           /* curve's knot vector.  Check for this & correct.         */
	   if ( next_param > max_param )
	      *param = (*param + max_param) * 0.5;
	   else if ( next_param < min_param )
	      *param = (*param + min_param) * 0.5;
	   else
	      *param = next_param;

	   abs_last_dxdu = fabs( dxdu );
	   abs_last_dydu = fabs( dydu );
	   } /* for ( cntr = 0; cntr < MAX_ITERATIONS; cntr++ ) */

	return( FALSE ); /* iteration limit exceeded */
	}  /* VEget_exact_transition_pt */


/*-- VEvectors_are_parallel --------------------------------------------*/

static IGRboolean VEvectors_are_parallel( v1_x, v1_y, v2_x, v2_y )

/*
NAME
	VEvectors_are_parallel (static)

DESCRIPTION
	Given two vectors in XY space, this routine will determine if they are
	parallel (i.e. their dot product is greater than PARALLEL_TOL).

PARAMETERS
	v1_x (IN) - X coordinate of first vector
	v1_y (IN) - Y coordinate of first vector
	v2_x (IN) - X coordinate of second vector
	v2_y (IN) - Y coordinate of second vector

GLOBALS USED
	none

RETURN VALUES
	TRUE - if the vectors are parallel
	FALSE - if the vectors aren't parallel

HISTORY
	09/02/87    S.A. Rapa
	   Created
*/

	IGRdouble v1_x, v1_y, v2_x, v2_y;

	{
	IGRdouble len, dot;

	/* Normalize vectors; input vectors must have non-zero length */
	len = sqrt( (v1_x * v1_x) + (v1_y * v1_y) );
	v1_x /= len;
	v1_y /= len;

	len = sqrt( (v2_x * v2_x) + (v2_y * v2_y) );
	v2_x /= len;
	v2_y /= len;

	/* Dot them */
	dot = (v1_x * v2_x) + (v1_y * v2_y);

#if DEBUG_FIND_TRANS
	fprintf( stderr, "                dot     = %12.10lf\n", dot );
#endif

	return( (dot >= PARALLEL_TOL) );

	}  /* VEvectors_are_parallel */


/*-- VEfind_next_visib_trans_region ------------------------------------*/

static void VEfind_next_visib_trans_region(
	struct IGRbsp_curve *curve,
	IGRboolean          is_start,
	IGRdouble           *param1,
	IGRdouble           *param2,
	IGRdouble           *x,
	IGRdouble           *y,
	IGRdouble           *z,
	IGRboolean          *is_transition,
	IGRboolean          *is_along_line_of_sight,
	IGRdouble           knot_tol,
	IGRdouble           cht )

/*
NAME
	VEfind_next_visib_trans_region

DESCRIPTION
	Finds the first parameter of a point on the curve at which dx/du and
	dy/du are zero (may indicate a possible visibility transition).
	Searching for such a point begins from wherever the last one was found, 
	unless this is the first call for a given curve ("is_start" == TRUE).
	If "is_along_line_of_sight" is returned as TRUE, then two points are
	returned, representing a span of the curve which is along the line of
	sight (and therefore invisible).  In addition, such a span may also be
	at a place where the curve doubles back on itself; if so,
	"is_transition" will be TRUE.  "z" always corresponds to "param1".

PARAMETERS
	curve (IN) - curve to find the trans region on
	is_start (IN) - TRUE, if first call call for given curve
	param1 (OUT) - first return parameter
	param2 (OUT) - second return parameter
	x (OUT) - X coordinate of transition
	y (OUT) - Y coordinate of transition
	z (OUT) - Z coordinate of transition
	is_transition (OUT) - TRUE, if a transition was found
	is_along_line_of_sight (OUT) - TRUE, if this section of the curve
	                               runs along the line of sight
	knot_tol (IN) - the knot tolerance to use
	cht (IN) - the chord height tolerance to use

GLOBALS USED
	*pole_ptr, *w_ptr, x2, y2, z2, last_x, last_y (static)
	this_x, this_y, next_x, next_y, trans_index, next_index (static)

HISTORY
	09/01/87    S.A. Rapa
	   Created.
*/

	{
	static IGRdouble *pole_ptr,
	                 *w_ptr,
	                 x2, y2, z2,
	                 last_x, last_y,
	                 this_x, this_y,
	                 next_x, next_y;
	static IGRint    trans_index, next_index;

	IGRdouble        v1_x, v1_y, v2_x, v2_y;
	IGRboolean       t1_found, t2_found,
	                 next_point_found, pole_skipped;

#if DEBUG_FIND_TRANS
	fprintf( stderr, "\nLooking for transition pt, is_start = %d.\n", is_start );
#endif

	*is_along_line_of_sight = *is_transition = FALSE;

	if ( is_start )
	   {
	   pole_ptr = curve->poles;
	   this_x = pole_ptr[0];
	   this_y = pole_ptr[1];
	   if ( curve->rational )
	      {
	      w_ptr = curve->weights;
	      this_x /= *w_ptr;
	      this_y /= *w_ptr;
	      }

	   next_index = 0;
	   while ( next_index < (curve->num_poles - 1) )
	      {
	      next_index++;
	      pole_ptr += 3;
	      next_x = pole_ptr[0];
	      next_y = pole_ptr[1];
	      if ( curve->rational )
	         {
	         w_ptr++;
	         next_x /= *w_ptr;
	         next_y /= *w_ptr;
	         }

	      if ( (fabs( next_x - this_x ) > cht) || (fabs( next_y - this_y ) > cht) )
	         break;
	      }

	   /* If "trans" and "next" are not adjacent, check to see if this is a    */
	   /* section of the curve which is moving directly to or from the viewer. */

	   if ( next_index != 1 )
	      {
	      t1_found = VEget_exact_transition_pt( curve, 0, param1, x, y, z, knot_tol );
	      t2_found = VEget_exact_transition_pt( curve, (next_index - 1), param2,
	                                            &x2, &y2, &z2, knot_tol );

	      if ((t1_found) && (t2_found))
	         if ( fabs( *param1 - *param2 ) > knot_tol )
	            {
	            *is_along_line_of_sight = TRUE;
	            return;
	            }
	      }
	   }

	while ( (! *is_along_line_of_sight) && (! *is_transition) &&
	        (next_index < (curve->num_poles - 1)) )
	   {
	   /* Start testing at node corresponding to pole defining a local transition.  */
           /* Identify transition regions as set of distinct poles which "doubles-back" */
	   /* on itself.                                                                */

	   trans_index = next_index;
	   last_x = this_x;
	   last_y = this_y;
	   this_x = next_x;
	   this_y = next_y;

	   /* Get next unique point in XY space (within tolerance) */
	   next_point_found = FALSE;
	   pole_skipped = FALSE;
	   while ( next_index < (curve->num_poles - 1) )
	      {
	      next_index++;
	      pole_ptr += 3;
	      next_x = pole_ptr[0];
	      next_y = pole_ptr[1];
	      if ( curve->rational )
	         {
	         w_ptr++;
	         next_x /= *w_ptr;
	         next_y /= *w_ptr;
	         }

	      if ( (fabs( next_x - this_x ) > cht) || (fabs( next_y - this_y ) > cht) )
	         {
	         next_point_found = TRUE;
	         break;
	         }

	      pole_skipped = TRUE;
	      }

	   /* If "trans" and "next" are not adjacent, check to see if this is a section */
	   /* of the curve which is moving directly to or from the viewer.              */

	   if ( pole_skipped )
	      {
	      if ( ! next_point_found )
	         next_index++;
	      t1_found = VEget_exact_transition_pt( curve, trans_index, param1,
	                                            x, y, z, knot_tol );
	      t2_found = VEget_exact_transition_pt( curve, (next_index - 1), param2,
	                                            &x2, &y2, &z2, knot_tol );
	      if ( (t1_found) && (t2_found) )
	         if ( fabs( *param1 - *param2 ) > knot_tol )
	            *is_along_line_of_sight = TRUE;
	      }

	   /* Now see if the curve "doubles back" on itself */

	   if ( next_point_found )
	      if ( (((this_x >= last_x - cht) && (this_x >= next_x - cht)) ||
	            ((this_x <= last_x + cht) && (this_x <= next_x + cht)))
	                                      &&
	           (((this_y >= last_y - cht) && (this_y >= next_y - cht)) ||
	            ((this_y <= last_y + cht) && (this_y <= next_y + cht))) )
	         {
	         /* Make sure poles are collinear in XY space */

	         v1_x = this_x - last_x;
	         v1_y = this_y - last_y;
	         v2_x = this_x - next_x;
	         v2_y = this_y - next_y;

	         if ( VEvectors_are_parallel( v1_x, v1_y, v2_x, v2_y ) )
	            {
	            if ( ! *is_along_line_of_sight )
	               *is_transition = VEget_exact_transition_pt( curve, trans_index,
	                                                           param1, x, y, z, knot_tol );
	            else
	               *is_transition = TRUE;
 	            }
	         }

	   }/* while no points found yet */

	} /* VEfind_next_visib_trans_region */


/*-- VEprocess_trans_pt ----------------------------------------*/

static void VEprocess_trans_pt( edge,
	                        trans_param, last_trans, next_trans,
	                        trans_x, trans_y, trans_z, knot_tol, cht )

	struct VEedge_header *edge;
	IGRdouble            trans_param, last_trans, next_trans,
	                     trans_x, trans_y, trans_z, knot_tol, cht;

/*
NAME
	VEprocess_trans_pt (static)

DESCRIPTION
	Given a transition point on an edge, project it along the line of sight
	and note where the projection intersects the curve.  If it intersects
	at a point nearer than the transition point, then the transition is
	invisible and nothing is done.  Otherwise the transition and the next
	furthest intersection (if it exists) are put on the temp-node list
	for the edge.  If intersections exist with the same z as the transition
	point, they are all added to the temp-list & the next furthest
	intersection is ignored.

PARAMETERS
	edge (IN) - the edge to process
	trans_param (IN) - the transition parameter
	last_trans (IN) - the last transition parameter
	next_trans (IN) - the next transition parameter
	trans_x (IN) - X coordinate of transition point
	trans_y (IN) - Y coordinate of transition point
	trans_z (IN) - Z coordinate of transition point
	knot_tol (IN) - knot tolerance to use
	cht (IN) - chord height tolerance to use

GLOBALS USED
	none

HISTORY
	09/01/87    S.A. Rapa
	   Created
*/

	{
	BSrc       rc;
	IGRint     num_int, num_over,
	           index;
	IGRdouble  int_param = 0.0, int_z, this_z,
	           *cv_par, *cv_over,
	           *ln_par, *ln_over;
	IGRpoint   *int_pts, *end_pts;
	IGRboolean same_z_int_exists, far_z_int_exists,
	           free_ints, free_overs;

	/* Compute projection line coordinates from transition point. */
	line_poles[0] = line_poles[3] = trans_x;
	line_poles[1] = line_poles[4] = trans_y;

#if DEBUG_OVERLAP
	fprintf( stderr, "\nTransition pt: params  = %12.10lf, %12.10lf, %12.10lf\n",
	         last_trans, trans_param, next_trans );
	fprintf( stderr, "                   x, y, z = %13.7lf, %13.7lf, %13.7lf\n",
	         trans_x, trans_y, trans_z );
#endif

	/* Project transition point onto curve */

	VEcvcv_int_3d( (IGRint *)&rc,		/* BSSUCC or BSNOMEMORY              */
	               &global_line,		/* curves to be intersected          */
	               edge->gm_curve3d->bspcv,
	               &num_int,		/* number of intersections           */
	               &int_pts,		/* cartesian values of intersections */
	               &ln_par, &cv_par,	/* u-values of the intersections     */
	               &num_over,		/* number of overlap regions         */
	               &end_pts,		/* overlap endpoints in xyz-space    */
	               &ln_over, &cv_over,	/* overlap endpoints in u            */
 	               &free_ints,
	               &free_overs );

	BS_ERRCHK( rc, "VEprocess_trans_pt: BScvcvint failed" );
	if ( rc != BSSUCC )
	   goto end_process_trans_pt;

	/* If the transition point is obscured by another part of the curve, */
	/* don't add it to the "temp list".                                  */
	for ( index = 0; index < num_int; index++ )
	   if ( int_pts[index][2] < (trans_z - cht) )
	      if ( (cv_par[index] < last_trans) || (cv_par[index] > next_trans) )
	         {
#if DEBUG_OVERLAP
	         fprintf( stderr, "Transition point is invisible.\n" );
#endif

	         goto end_process_trans_pt;
	         }

	/* If same-Z intersections exist, add all of them to the "temp list". */
	/* Otherwise just add the one intersection closest to the viewer.     */
	/* Also add the transition point.                                     */
	VEinsert_temp_node( trans_param, edge, knot_tol );

	int_z = 1.0E50;
	same_z_int_exists = FALSE;
	far_z_int_exists  = FALSE;

	for ( index = 0; index < num_int; index++ )
	   {
	   this_z = int_pts[index][2];

#if DEBUG_OVERLAP
	   fprintf( stderr, "Intersection param, z   = %12.10lf, %13.7lf\n", cv_par[index], this_z );
#endif

	   if ( (cv_par[index] < last_trans) ||
	        (cv_par[index] > next_trans) ) /* not the transition pt */
	      {
	      if ( this_z < (trans_z + cht) )   /* same-z intersection */
	         {
#if DEBUG_OVERLAP
	         fprintf (stderr, "   Same Z intersection at %12.10lf.\n", cv_par[index]);
#endif

	         VEinsert_temp_node( cv_par[index], edge, knot_tol );
	         same_z_int_exists = TRUE;
	         }
	      else  /* far-z intersection */
	         if (this_z < int_z)
	            {
 	            int_z = this_z;
	            int_param = cv_par[index];
	            far_z_int_exists = TRUE;
	            }
	      } /* if not the transition pt */

	   } /* for (index = 0; index < num_int; index++) */

	if ( (! same_z_int_exists) && (far_z_int_exists) )
	   {
#if DEBUG_OVERLAP
	   fprintf( stderr, "   Different Z intersection at %12.10lf.\n", int_param );
#endif

	   VEinsert_temp_node( int_param, edge, knot_tol );
	   }

end_process_trans_pt:

	if ( (free_ints) && (int_pts) )
	   {
	   free( (char *) int_pts );
	   free( (char *) ln_par );
	   free( (char *) cv_par );
	   }
	if ( (free_overs) && (end_pts) )
	   {
	   free( (char *) end_pts );
	   free( (char *) ln_over );
	   free( (char *) cv_over );
	   }

	} /* VEprocess_trans_pt */


/*--- VEmake_span_overlapped ---------------------------------------*/

static void VEmake_span_overlapped( parm, node_list, visible_parm, knot_tol )

	IGRdouble          parm, visible_parm, knot_tol;
	struct VEtemp_node *node_list;

/*
NAME
	VEmake_span_overlapped (static)

DESCRIPTION
	Set the visibility of a temp_node span which contains "parm" ONLY IF
	   1) "visible_parm" is NOT in that span (see comment below), AND
	   2) "parm" is NOT within "knot_tol" of a node.

PARAMETERS
	parm (IN) - parameter in the span to mark as overlapped
	node_list (IN) - temp node list to use
	visible_parm (IN) - visibility test parameter
	knot_tol (IN) - the knot tolerance to use

GLOBALS USED
	none

HISTORY
	09/01/87    S.A. Rapa
	   Created
*/

	{
	struct VEtemp_node *prev_node, *this_node;

	prev_node = node_list;
	this_node = prev_node->next;

	/* Change visibility only if parameter is within a span */
	/* (i.e it doesn't count if "parm" is on a node)        */

	while ( this_node )
	   {
	   if ( ((prev_node->u + knot_tol) < parm) &&
	        ((this_node->u - knot_tol) > parm) )
	      {
	      /* Sometimes BScvcvint returns multiple intersections for what */
	      /* should really be a single point.  This will cause a problem */
	      /* if it happens within the topmost (visible) span because     */
	      /* we'll accidentally mark it as OVERLAPPED.  Correct this by  */
	      /* not processing ANY intersections with a span which contains */
	      /* a known visible point (i.e the topmost span, identified by  */
	      /* "visible_parm") since, theoretically, there can only be one */
	      /* intersection per span.                                      */

	      if ( (prev_node->u > visible_parm) || (this_node->u < visible_parm) )
	         {
#if DEBUG_OVERLAP
	         fprintf( stderr, "   Overlap region at parameter = %12.10lf\n", parm );
#endif

	         this_node->prev_visib = OVERLAPPED;
	         prev_node->next_visib = OVERLAPPED;
	         }

	      break;
	      }

	   else
	      {
	      prev_node = this_node;
	      this_node = prev_node->next;
	      }

	   } /* end: while */

	} /* VEmake_span_overlapped */


/*--- VEdetermine_overlaps ---------------------------------*/

static void VEdetermine_overlaps( edge, knot_tol )

	struct VEedge_header *edge;
	IGRdouble            knot_tol;

/*
NAME
	VEdetermine_overlaps (static)

DESCRIPTION
	Does a series of point projections (curve-curve intersections) to find
	out which parts of the curve are visible.  Note that a single projection
	will set all spans but the nearest which contain intersection points
	to OVERLAPPED; this cuts down on the number of projections needed vs.
	doing one projection per span.

PARAMETERS
	edge (IN) - the edge to use
	knot_tol (IN) - the knot tolerance to use

GLOBALS USED
	prev_node, this_node (static)

HISTORY
	09/01/87   S.A. Rapa
	   Created
*/

	{
	BSrc               rc;
	struct VEtemp_node *prev_node, *this_node;
	IGRdouble          project_param,
	                   low_z, low_parm,
	                   *cv_par, *cv_over,
	                   *ln_par, *ln_over;
	IGRpoint           *int_pts, *end_pts,
	                   project_pt;
	IGRint             low_index, index,
	                   num_int, num_over;
	IGRboolean         free_ints, free_overs;

#if DEBUG_OVERLAP
	fprintf( stderr, "\nSetting overlap spans ...\n" );
#endif

	prev_node = edge->temp_list;
	this_node = prev_node->next;
	while ( this_node )
	   {
	   if ( prev_node->next_visib != OVERLAPPED )
	      {
	      project_param = (prev_node->u + this_node->u) * 0.5;
	      BScveval( edge->gm_curve3d->bspcv, project_param, 0, (IGRpoint *)project_pt, &rc );
	         BS_ERRCHK( rc, "VEdetermine_overlaps; BScveval failed" );

#if DEBUG_OVERLAP
	      fprintf( stderr, "Projecting from %18.16lf\n", project_param );
#endif

	      /* Compute projection line coordinates */
	      line_poles[0] = project_pt[0];
	      line_poles[1] = project_pt[1];
	      line_poles[3] = project_pt[0];
	      line_poles[4] = project_pt[1];

	      VEcvcv_int_3d( (IGRint *)&rc,	/* BSSUCC or BSNOMEMORY              */
	                     &global_line,	/* curves to be intersected          */
	                     edge->gm_curve3d->bspcv,
	                     &num_int,		/* number of intersections           */
	                     &int_pts,		/* cartesian values of intersections */
	                     &ln_par, &cv_par,	/* u-values of the intersections     */
	                     &num_over,		/* number of overlap regions         */
	                     &end_pts,		/* overlap endpoints in xyz-space    */
	                     &ln_over, &cv_over,/* overlap endpoints in u            */
	                     &free_ints,
	                     &free_overs );

	         BS_ERRCHK( rc, "VEdetermine_overlaps: BScvcvint failed" );

	      /* Locate the intersection with the nearest Z ... this */
	      /* will be ignored later when setting overlaps.        */
	      low_z = int_pts[0][2];
	      low_index = 0;
	      low_parm = cv_par[0];
	      for ( index = 1; index < num_int; index++ )
	         if (low_z > int_pts[index][2])
	            {
	            low_z = int_pts[index][2];
	            low_index = index;
	            low_parm = cv_par[index];
	            }

	      /* Now process intersections & set overlap regions */
	      for ( index = 0; index < num_int; index++ )
	         if ( index != low_index )
	            VEmake_span_overlapped( cv_par[index], edge->temp_list, low_parm, knot_tol );

	      /* Free memory used by BScvcvint */
	      if ( (free_ints) && (int_pts) )
	         {
	         free( (char *) int_pts );
	         free( (char *) ln_par );
	         free( (char *) cv_par );
	         }
	      if ( (free_ints) && (end_pts) )
	         {
	         free( (char *) end_pts );
	         free( (char *) ln_over );
	         free( (char *) cv_over );
	         }
	      }

	   prev_node = this_node;
	   this_node = prev_node->next;
	   }

	/* Clean up temp list by removing unnecessary nodes. */
	prev_node = edge->temp_list;
	this_node = prev_node->next;
	while ( this_node->next )
	   {
	   if ( this_node->prev_visib == this_node->next_visib )
	      {
	      prev_node->next = this_node->next;
	      VEfree_temp_node( this_node );
	      this_node = prev_node->next;
	      }
	   else
	      {
	      prev_node = this_node;
	      this_node = this_node->next;
	      }

	   }  /* end: while */

	}  /* VEdetermine_overlaps */


/*-- VEfind_self_overlaps_for_collinear_edge ---------------------------------------*/

void VEfind_self_overlaps_for_collinear_edge( edge, changes_made, elem_range, knot_tol )

	struct VEedge_header *edge;
	IGRboolean           *changes_made;
	IGRdouble            *elem_range;
	IGRdouble            knot_tol;

/*
NAME
	VEfind_self_overlaps_for_collinear_edge

DESCRIPTION
	Set all parts of an edge which are invisible because they are
	   1) behind another part of the curve, or 2) are long the line
	      of sight to OVERLAPPED.

PARAMETERS
	edge (IN) - the edge that is to have its self-overlaps found
	changes_made (OUT) - TRUE, if changes were made to the edge
	elem_range (IN) - range of the element that owns the edge
	knot_tol (IN) - the knot tolerance to use

GLOBALS USED
	min_param, max_param (static)

HISTORY
	09/01/87    S.A. Rapa
	   Created
*/

	{
	BSrc                rc;
	IGRboolean          is_transition, is_along_line_of_sight,
	                    next_pt_is_transition, next_pt_is_along_line_of_sight;
	IGRdouble           trans_param1, trans_param2,
	                    next_param1, next_param2,
	                    last_param1, first_param1,
	                    trans_x, trans_y, trans_z,
	                    next_x, next_y, next_z;
	IGRpoint            test_pt;
	struct IGRbsp_curve *curve;
	IGRdouble           cht;

#if TIMING
	times( &VEs_time );
#endif

	*changes_made = FALSE;

	BSxtractpar( &rc, BSTOLCHRDHT, &cht );

	/* Initialize the projection line structure */
	line_poles[2] = elem_range[2];
	line_poles[5] = elem_range[5];

	curve = edge->gm_curve3d->bspcv;
	min_param = curve->knots[curve->order - 1];
	max_param = curve->knots[curve->num_knots - curve->order];

	/* Are there any transition points for this curve? */
	VEfind_next_visib_trans_region( curve, TRUE,
	                                &trans_param1, &trans_param2,
	                                &trans_x, &trans_y, &trans_z,
	                                &is_transition,
	                                &is_along_line_of_sight,
	                                knot_tol, cht );

	if ( (is_transition) || (is_along_line_of_sight) )
	   {
	   *changes_made = TRUE;

	   /* For all potential visibility (overlap) transition points, */
	   /* add appropriate temp nodes to list.                       */
	   last_param1 = min_param;
	   first_param1 = trans_param1;

	   while ( (is_transition) || (is_along_line_of_sight) )
	      {
	      /* Get next transition point; we need the parameter values of      */
	      /* the two adjacent transitions before we can process this one     */
	      /* since they are used to determine if a curve-curve intersection  */
	      /* point should also be considered a visibility transition or not. */

	      VEfind_next_visib_trans_region( curve, FALSE,
	                                      &next_param1, &next_param2,
	                                      &next_x, &next_y, &next_z,
	                                      &next_pt_is_transition,
	                                      &next_pt_is_along_line_of_sight,
	                                      knot_tol, cht );

	      if (! ((next_pt_is_transition) || (next_pt_is_along_line_of_sight)) )
	         next_param1 = max_param;

	      /* Now process the current transition point */

	      if ( is_along_line_of_sight )
	         VEadd_overlap_region( trans_param1, trans_param2, edge,
	                               UNKNOWN, knot_tol );

	      if (is_transition)
	         VEprocess_trans_pt( edge, trans_param1, last_param1, next_param1,
	                             trans_x, trans_y, trans_z, knot_tol, cht );

	      last_param1  = trans_param1;
	      trans_param1 = next_param1;
	      trans_param2 = next_param2;
	      trans_x = next_x;
	      trans_y = next_y;
	      trans_z = next_z;
	      is_transition = next_pt_is_transition;
	      is_along_line_of_sight = next_pt_is_along_line_of_sight;

	      }  /* end: while */

	   /* Do projections from curve endpoints. */
	   if (! curve->phy_closed)
	      {
	      BScveval( curve, min_param, 0, (IGRpoint *)test_pt, &rc );
	         BS_ERRCHK( rc, "VEfind_self_overlaps_for_collinear_edge: BScveval failed" );
	      VEprocess_trans_pt( edge, min_param, min_param, first_param1,
	                          test_pt[0], test_pt[1], test_pt[2], knot_tol, cht );
	      BScveval( curve, max_param, 0, (IGRpoint *)test_pt, &rc );
	         BS_ERRCHK( rc, "VEfind_self_overlaps_for_collinear_edge: BScveval failed" );
	      VEprocess_trans_pt( edge, max_param, last_param1, max_param,
	                          test_pt[0], test_pt[1], test_pt[2], knot_tol, cht );
	      }

	   /* Do some line intersections to find out which spans are visible */
	   VEdetermine_overlaps( edge, knot_tol );

	   }  /* end: if ( (is_transition) || (is_along_line_of_sight) ) */

#if TIMING
	times( &VEe_time );

	VEcount_water++;
	VEtime_water += ( ( (VEe_time.tms_utime + VEe_time.tms_stime) -
	                    (VEs_time.tms_utime + VEs_time.tms_stime) ) / 60.0 );
#endif

	}  /* VEfind_self_overlaps_for_collinear_edge */


/*-- VEadd_knots_at_transition_points ---------------------------------------*/

void VEadd_knots_at_transition_points( curve, knot_tol )

	struct IGRbsp_curve *curve;
	IGRdouble           knot_tol;

/*
NAME
	VEadd_knots_at_transition_points

DESCRIPTION
	This function add knots at the points where a curve turns back
	on itself.  Adding knots in these places helps BScvslf_int() give
	the correct overlap result when self-intersecting the curve.

PARAMETERS
	curve (IN/OUT) - the curve that is to have the knots added
	knot_tol (IN) - the knot tolerance to use

GLOBALS USED
	none

HISTORY
	xx/xx/xx    S.A. Rapa
	   Creation Date
*/

	{
	IGRlong    rc;
	IGRint     i;
	IGRint     mult;
	IGRboolean is_transition;
	IGRboolean is_along_line_of_sight;
	IGRboolean first_time;
	IGRboolean enough_memory;
	IGRdouble  trans_param1;
	IGRdouble  trans_param2;
	IGRdouble  trans_x, trans_y, trans_z;
	IGRint     trans_size;
	IGRint     num_trans;
	IGRdouble  *trans_pts;
	IGRdouble  cht;


	if ( curve->order == 2 )
	   return;
	   
	BSxtractpar( &rc, BSTOLCHRDHT, &cht );

	/* Get temporary storage to hold transition points. */
	/* There can't be more than num_poles transition    */
	/* points so get an array of doubles that is        */
	/* num_poles is size.                               */
	trans_size = (curve->num_poles / 3) + 1;
	VEget_unweighted_pole_storage( trans_size, &trans_pts );
	
	min_param = curve->knots[curve->order - 1];
	max_param = curve->knots[curve->num_knots - curve->order];

	/* find all transition points and save them so they */
	/* can be added to the curve later                  */
	first_time = TRUE;
        num_trans = 0;
	do
	   {
	   VEfind_next_visib_trans_region( curve, first_time,
	                                   &trans_param1, &trans_param2,
	                                   &trans_x, &trans_y, &trans_z,
	                                   &is_transition,
	                                   &is_along_line_of_sight,
	                                   knot_tol, cht );

	   if ( (is_transition) &&
	        (! ( (fabs(trans_param1 - min_param) < knot_tol) ||
	             (fabs(trans_param1 - max_param) < knot_tol) ) ) )
	      {
	      /* transition point that isn't at the min and max parameter of the curve */
	      trans_pts[ num_trans++ ] = trans_param1;
	      }

	   if ( (is_along_line_of_sight) &&
	        (! ( (fabs(trans_param2 - min_param) < knot_tol) ||
	             (fabs(trans_param2 - max_param) < knot_tol) ) ) )
	      {
	      /* line of sight point that isn't at the min and max parameter of the curve */
	      trans_pts[ num_trans++ ] = trans_param2;
	      }
	    
	   if ( first_time )
	      first_time = FALSE;
         
	   }
	while ( is_transition || is_along_line_of_sight );
   
	/* add knots at all of the transition points */
	if ( num_trans > 0 )
	   {
	   /* re-allocate poles, knots and weights for curve so they can */
	   /* hold all of the transition points that were found.         */
	   curve->knots = (IGRdouble *) realloc( curve->knots,
	                              (curve->num_knots + num_trans) * sizeof( IGRdouble ) );
	   curve->poles = (IGRdouble *) realloc( curve->poles,
	                              (curve->num_poles + num_trans) * 3 * sizeof( IGRdouble ) );
	   if ( curve->rational )
	      curve->weights = (IGRdouble *) realloc( curve->weights,
	                              (curve->num_poles + num_trans) * sizeof( IGRdouble ) );

	   mult = 1;
	   enough_memory = TRUE;
	   for ( i = 0; i < num_trans; i++ )
	      {
	      /* add a knot to the curve at param */
	      BSadd_ktr( &rc, curve, &trans_pts[i], &mult, &enough_memory );
              		  
	         BS_ERRCHK( rc, "VEadd_knots_at_transition_points: BSadd_ktr failed" );
	      }  /* end: for */
	   
	   }  /* end: if ( num_trans > 0 ) */
	   
	}  /* VEadd_knots_at_transition_points */
