
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

#include "bscvkttol2.h"

static IGRboolean debug;

/*--- VEdisjoint_z_compare_edges -------------------------------------------------*/

void VEdisjoint_z_compare_edges( struct VEedge_header	 *near_edge,
				 struct VEedge_header    *far_edge,
				 struct VEelement_header *near_element,
				 struct VEelement_header *far_element,
				 IGRboolean              near_can_hide_far,
				 IGRboolean              pseudo_int )

/*
NAME
	VEdisjoint_z_compare_edges

DESCRIPTION
	Adds all overlap regions and potential visibility transition points
	to the "temp lists" of two compared edges knowing that the range boxes
	of the curves do not overlap in Z.  This means we know that overlaps and
	intersections will only be added to the far edge.

PARAMETERS
	near_edge (IN) - the edge closest to the eye
	far_edge (IN) - the edge furthest from the eye
	near_element (IN) - the element that owns the near edge
	far_element (IN) - the element that owns the far edge
	near_edge_can_hide_far (IN) - TRUE, if the near edge
	                              can hide the far edge
	psuedo_int (IN) - TRUE, if the calling routine doesn't
	                  care about the results of the comparison
	                  and is only calling this function so that
	                  the saved intersection algorithm will work
	                  properly

GLOBALS USED
	none

HISTORY
	08/26/88    S.P. Rogers
	   Creation Date
*/

	{
	BSrc                rc;
	IGRboolean          free_ints;
	IGRboolean          free_overs;
	IGRshort            visibility;
	IGRint              n_int;
	IGRint              i;
	IGRlong             n_over;
	IGRdouble           *int_pts;
	IGRdouble           *near_par;
	IGRdouble           *far_par;
	IGRdouble           *end_pts;
	IGRdouble           *near_over;
	IGRdouble           *far_over;
	IGRdouble           far_knot_tol;
	IGRdouble           edge_based_dist_tol;
	struct IGRbsp_curve *far_curve;


	debug = (near_edge->status & DEBUG_EDGE) || (far_edge->status & DEBUG_EDGE);
	if ( debug )
	   {
	   fprintf( stderr, "INTERSECTING (disjoint)\n" );
	   VEedge_debug( near_edge );
	   VEedge_debug( far_edge );
	   }

	VEupdate_heartbeat();

	/* Call VEcvcv_int to compute the intersections of near_curve and         */
	/* far_curve in xy-space. We must do the intersection even if far_edge is */
	/* TOTALLY_OVERLAPPED to keep the curve/curve intersection saving         */
	/* algorithm working properly. It expects curve/curve intersections to be */
	/* performed a certain number of times and if they aren't it will not     */
	/* clean up its data structures properly so they can be re-used           */

	VEcvcv_int( (IGRint *)&rc,                /* BSSUCC or BSNOMEMORY              */
	            near_element, far_element,
	            near_edge, far_edge,          /* edge headers of curves            */
	            &n_int,                       /* number of intersections           */
	            (IGRpoint **)&int_pts,        /* cartesian values of intersections */
	            &near_par, &far_par,          /* u-values of the intersections     */
	            (IGRint *)&n_over,            /* number of overlap regions         */
	            (IGRpoint **)&end_pts,        /* overlap endpoints in xyz-space    */
	            &near_over, &far_over,        /* overlap endpoints in u            */
	            &free_ints,
	            &free_overs,
	            FALSE,
	            pseudo_int,
	            &edge_based_dist_tol );

	if ( debug )
	   {
	   for ( i = 0; i < n_over; i++ )
              fprintf( stderr, "  %20.15lf - %20.15lf  :  %20.15lf %20.15lf\n",
	               near_over[i*2], near_over[i*2+1], far_over[i*2], far_over[i*2+1] );

	   for ( i = 0; i < n_int; i++ )
              fprintf( stderr, "  %20.15lf  :  %20.15lf \n", near_par[i], far_par[i] );

	   }


	if ( rc == BSSUCC )
	   {
	   far_curve = far_edge->gm_curve3d->bspcv;

	   if ( ( ! pseudo_int ) && 
	        ( !(far_edge->status & TOTALLY_OVERLAPPED) ) &&
	        ( n_int || n_over ) )
	      {
	      /* far edge isn't already totally overlapped => add nodes to it */
	      BScvkttol2( far_curve->order,
	                  far_curve->knots,
	                  far_curve->num_poles,
	                  far_curve->poles,
	                  far_curve->weights,
	                  &far_knot_tol,
 	                  &rc );
    
	      /* Process overlaps */
	      visibility = (near_can_hide_far) ? UNKNOWN : VISIBLE;
	      n_over *= 2;
	      for (i = 0; i < n_over; i += 2)
	         {
	         if ( debug )
	            fprintf( stderr, "   ADDING OVERLAP REGION: %20.15lf %20.15lf\n", far_over[i], far_over[i+1] );
	         VEadd_overlap_region( far_over[i], far_over[i+1],
	                               far_edge, visibility, far_knot_tol );
	         } /* end: for */

	      /* Only process the intersection points if (the near element can  */
	      /* hide the far element) AND (the near edge can hide) AND (the    */
	      /* far edge is not TOTALLY_OVERLAPPED). We must check the         */
	      /* TOTALLY_OVERLAPPED status of far_edge again, because the       */
	      /* addition of OVERLAPPED spans above could have changed its      */
	      /* status to TOTALLY_OVERLAPPED.                                  */
	      if ( (near_can_hide_far) &&
	           (near_edge->type & EDGE_CAN_HIDE) &&
	           ( ! (far_edge->status & TOTALLY_OVERLAPPED) ) )
	         {
	         for (i = 0; i < n_int; i++)
	            {
	            /* add a temp_node to the far edge */
	            if ( VEnot_hiding_with_self_hidden_pt( near_edge, near_par[i] ) )
	                {
	                if ( debug )
	                   fprintf( stderr, "   ADDING INTERSECTION:  %20.15lf\n", far_par[i] );
	                VEinsert_temp_node( far_par[i], far_edge, far_knot_tol );
	                }
	            } /* end: for */

	         } /* end: if (hiding should be done) */
	
	      } /* end: if */ 

	   }  /* end: if ( rc == BSSUCC ) */

	/* free the memory that was allocated by curve/curve intersection */
	if ( (free_ints) && (int_pts) )
	   {
	   free( (IGRchar *) int_pts);
	   free( (IGRchar *) near_par);
	   free( (IGRchar *) far_par);
	   }

	if ( (free_overs) && (end_pts) )
	   {
	   free( (IGRchar *) end_pts);
	   free( (IGRchar *) near_over);
	   free( (IGRchar *) far_over);
	   }

	if ( debug )
	   {
	   fprintf( stderr, "FINISHED INTERSECTING (disjoint)\n" );
	   VEedge_debug( near_edge );
	   VEedge_debug( far_edge );
	   }

	}  /* VEdisjoint_z_compare_edges */

