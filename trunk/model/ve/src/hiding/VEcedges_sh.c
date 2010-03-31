
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

static void VEdo_an_sh_intersection __((IGRdouble            p0,
					IGRdouble            p1,
					IGRdouble            z0,
					IGRdouble            z1,
					struct VEedge_header *edge0,
					struct VEedge_header *edge1,
					IGRdouble            z_tolerance,
					IGRdouble            knot_tol0,
					IGRdouble            knot_tol1 ));

#if defined(__cplusplus)
}
#endif
#undef __

extern struct VEexecution_status VEexec_status;


/*--- VEdo_an_sh_intersection ----------------------------------*/

static void VEdo_an_sh_intersection(p0, p1, z0, z1, edge0, edge1, z_tolerance, knot_tol0, knot_tol1)

	IGRdouble            p0, p1;
	IGRdouble            z0, z1;
	struct VEedge_header *edge0, *edge1;
	IGRdouble            z_tolerance, knot_tol0, knot_tol1;

/*
NAME
	VEdo_an_sh_intersection (static)

DESCRIPTION
	This procedure inserts a temp-node(s) into the appropriate temp-list(s)
	based on the criteria described in VEcompare_edges_sh.

PARAMETERS
	p0 (IN) - parameter of intersection on edge0
	p1 (IN) - parameter of intersection on edge1
	z0 (IN) - z value of intersection on edge0
	z1 (IN) - z value of intersection on edge1
	z_tolerance (IN) - the z tolerance to use
	knot_tol0 (IN) - knot tolerance for edge0
	knot_tol1 (IN) - knot tolerance for edge1

GLOBALS USED
	none

HISTORY
	xx/xx/xx    P. R. Slubicki
	   Creation Date
*/

	{
	if ( (z1 - z0) > z_tolerance )
	   {
	   if ( (edge0->type & EDGE_CAN_HIDE) && ((edge0->status & EDGE_CLASSIFICATION) == VISIBLE_PROFILE) )
	      VEinsert_temp_node( p1, edge1, knot_tol1 );
	   }
	else if ( (z0 - z1) > z_tolerance )
	   {
	   if ( (edge1->type & EDGE_CAN_HIDE) && ((edge1->status & EDGE_CLASSIFICATION) == VISIBLE_PROFILE) )
	      VEinsert_temp_node( p0, edge0, knot_tol0 );
	   }

	/* *** Same-Z Intersection *** */
   
	else
	   {
	   if ( (edge0->type & EDGE_CAN_HIDE) && ((edge0->status & EDGE_CLASSIFICATION) == VISIBLE_PROFILE) )
	      VEinsert_temp_node( p1, edge1, knot_tol1 );
	   if ( (edge1->type & EDGE_CAN_HIDE) && ((edge1->status & EDGE_CLASSIFICATION) == VISIBLE_PROFILE) )
	      VEinsert_temp_node( p0, edge0, knot_tol0 );
	   }

	}  /* VEdo_an_sh_intersection */


/*--- VEcompare_edges_sh ---------------------------------------*/

VEcompare_edges_sh( struct VEedge_header    *edge0,
		    struct VEedge_header    *edge1,
		    struct VEelement_header *element,
		    IGRboolean              doing_hiding,
		    IGRboolean              intersection_misses )

/*
NAME
	VEcompare_edges_sh

DESCRIPTION
	This procedure compares, through a call to VEcvcv_int, the edges edge0
	and edge1 of the element element and processes the intersection and
	overlap	data determined by the comparison. This procedure is called
	during the self-hiding of element.

	The processing of overlap regions is done in the procedure 
	VEprocess_overlap which is in the module VEoverlap.c, and the
	documentation for how this is done can be found there.

	The intersections are used to determine potential visibility transition
	points. If, for example, edge0 and edge1 intersect at u = .4 on edge0,
	and and edge0 is greater in z at this point (the z-axis "goes into"
	the screen), then there is a possible visibility transition point on
	edge0 at u = .4. A node is thus then placed on edge0's temp-list at
	u = .4, and in VEset_visibs.c it will be determined if there is a
	visibility transition at this point. If the two edges intersect in the
	same z, and both edges are parting lines or sharp edges, then there
	are potential visibility transitions on both adges at the point of
	intersection. Thus, nodes are placed on both egdes' temp_lists. If an
	intersection is in the same z, and one edge is a parting line or
	boundary, and the other is a natural edge or boundary, then there is
	a potential transition point on the natural edge or boundary.
	If doing_hiding is FALSE, then only the overlaps are processed.

	If intersection_misses is TRUE, then the calling routine has determined
	that the result of intersecting these two edges will be 0 intersections
	and 0 overlaps.  If this is the case, this routine is only being called
	so that the curve/curve intersection saving algorithm will function
	properly.
  
PARAMETERS
	edge0 (IN) - the first edge to compare
	edge1 (IN) - the second edge to compare
	element (IN) - the element that owns the edges
	doing_hiding (IN) - TRUE, if hiding is being done
	intersection_misses (IN) - TRUE, if the calling routines knows that
	                           the two edges cannot intersect and is only
	                           making this call to keep the saved 
	                           intersection algorithm working correctly

GLOBALS USED
	none

HISTORY
	xx/xx/xx    P. R. Slubicki
	   Creation Date
*/  

	{
	IGRboolean          free_ints, free_overs;
	BSrc                rc;
	IGRdouble           *int_pts,
	                    *par0, *par1,
	                    *end_pts,
	                    *over0, *over1;
	IGRint              n_int, ii;
	IGRlong             n_over;
	IGRpoint            eval0[2], eval1[2];
	IGRdouble           knot_tol0, knot_tol1;
	IGRdouble           edge_based_dist_tol;
	struct IGRbsp_curve *curve0, *curve1;
   

	if ( (edge0->status & DEBUG_EDGE) || (edge1->status & DEBUG_EDGE) )
	   {
	   fprintf( stderr, "INTERSECTING EDGES (sh):\n" );
	   VEedge_debug( edge0 );
	   VEedge_debug( edge1 );
	   }

	VEupdate_heartbeat();

	/* Call VEcvcv_int to compute the intersections and overlaps of curve0 and  */
	/* curve1 in xy-space. I need to call this procedure even if both edges are */
	/* totally overlapped so that the saved intersection list may be processed  */
	/* correctly.                                                               */
	VEcvcv_int( (IGRint *)&rc,            /* BSSUCC or BSNOMEMORY              */
	            element, element,
	            edge0, edge1,             /* edge headers of curves            */
                    &n_int,                   /* number of intersections           */
                    (IGRpoint **)&int_pts,    /* cartesian values of intersections */
                    &par0, &par1,             /* u-values of the intersections     */
                    (IGRint *)&n_over,        /* number of overlap regions         */
                    (IGRpoint **)&end_pts,    /* overlap endpoints in xyz-space    */
                    &over0, &over1,           /* overlap endpoints in u            */
                    &free_ints,
                    &free_overs,
                    intersection_misses,
                    FALSE,
	            &edge_based_dist_tol );

	   BS_ERRCHK(rc, "VEcompare_edges_sh: BScvcvint failed");

	if ( intersection_misses )
	   return;
      
	/* If both edges are totally overlapped, then there is no need to process */
	/* the intersection or overlap regions.                                   */
	if ( (rc == BSSUCC) &&
	     (!(edge0->status & TOTALLY_OVERLAPPED) || !(edge1->status & TOTALLY_OVERLAPPED)) )
	   {
	   curve0 = edge0->gm_curve3d->bspcv;
	   curve1 = edge1->gm_curve3d->bspcv;

	   if (n_int || n_over)
	      {
	      BScvkttol2( curve0->order, curve0->knots, curve0->num_poles,
	                  curve0->poles, curve0->weights, &knot_tol0, &rc );

	      BScvkttol2( curve1->order, curve1->knots, curve1->num_poles,
	                  curve1->poles, curve1->weights, &knot_tol1, &rc );
	      } /* end if (n_int || n_over) */
     
	   /* Process overlaps - mark all overlapped regions as OVERLAPPED. */
	   n_over *= 2;
	   for ( ii = 0; ii < n_over; ii += 2 )
	      {
	      BScveval( curve0, over0[ii], 0, (IGRpoint *)eval0[0], &rc );
	         BS_ERRCHK(rc, "VEcompare_edges_sh: BScveval 0 failed");

	      BScveval( curve1, over1[ii], 0, (IGRpoint *)eval1[0], &rc );
	         BS_ERRCHK(rc, "VEcompare_edges_sh: BScveval 1 failed");

	      BScveval( curve0, over0[ii + 1], 0, (IGRpoint *)eval0[1], &rc );
	         BS_ERRCHK(rc, "VEcompare_edges_sh: BScveval 2 failed");

	      BScveval( curve1, over1[ii + 1], 0, (IGRpoint *)eval1[1], &rc );
	         BS_ERRCHK(rc, "VEcompare_edges_sh: BScveval 3 failed");

	      /* Check for overlap regions that should really be intersections */
	      /* and process accordingly.  Overlap regions must cross in Z and */
	      /* not be parallel in XYZ space to be considered intersections.  */
	      if (VEoverlap_is_really_intersection( eval0[0], eval1[0],
	                                            eval0[1], eval1[1], edge_based_dist_tol ))
	         {
	         if (doing_hiding)
	            {
	            over0[ii] = (over0[ii] + over0[ii+1]) * 0.5;
	            over1[ii] = (over1[ii] + over1[ii+1]) * 0.5;

	            VEdo_an_sh_intersection( over0[ii], over1[ii],
	                                     eval0[0][2], eval0[0][2],
	                                     edge0, edge1,
	                                     edge_based_dist_tol, knot_tol0, knot_tol1 );
	            }
	         }
	      else
	         {
	         VEprocess_overlap( edge0, edge1,
	                            &(over0[ii]), &(over1[ii]),
	                            (IGRdouble *)eval0, (IGRdouble *)eval1,
	                            doing_hiding, doing_hiding,
	                            edge_based_dist_tol, knot_tol0, knot_tol1, TRUE );
	         }

	      } /* end for ( ii = 0; ii < n_over; ii += 2 ) */

	   /* Process intersections if the surface is nonplanar - find hidden */
	   /* edges and mark accordingly.                                     */
	   if ( (doing_hiding) && (!element->geom.gmsurf->bspsf->planar) )
	      {
	      for ( ii = 0; ii < n_int; ii++ )
	         {
	         /* Evaluate the intersection point on each curve to */
	         /* find which is closer in z.                       */
	         BScveval( curve0, par0[ii], 0, (IGRpoint *)eval0[0], &rc );
	            BS_ERRCHK(rc, "VEcompare_edges_sh: BScveval 4 failed");

	         BScveval( curve1, par1[ii], 0, (IGRpoint *)eval1[0], &rc );
	            BS_ERRCHK(rc, "VEcompare_edges_sh: BScveval 5 failed");

	         VEdo_an_sh_intersection( par0[ii], par1[ii], eval0[0][2], eval1[0][2], edge0, edge1,
	                                  edge_based_dist_tol, knot_tol0, knot_tol1 );

	         } /* end for ( ii = 0; ii < n_int; ii++ ) */

	      } /* end if ( (doing_hiding) && (!element->geom.gmsurf->bspsf->planar) ) */

	   } /* end if both edges are not totally overlapped */

	/* Free the memory used for the VEcvcv_int output if it is not to be saved. */
	if ( (free_overs) && (end_pts) )
	   {
	   free( (char *) end_pts );
	   free( (char *) over0 );
	   free( (char *) over1 );
	   }

	if ( (free_ints) && (int_pts) )
	   {
	   free( (char *) int_pts );
	   free( (char *) par0 );
	   free( (char *) par1 );
	   }

	if ( (edge0->status & DEBUG_EDGE) || (edge1->status & DEBUG_EDGE) )
	   {
	   fprintf( stderr, "FINISHED INTERSECTING EDGES (sh):\n" );
	   VEedge_debug( edge0 );
	   VEedge_debug( edge1 );
	   }

	}  /* VEcompare_edges_sh */
