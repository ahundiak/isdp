/*
Author:  dh
Date:  Apr 6, 1995
*/
#include <stdio.h>
#include <stdlib.h>
#include <math.h>

#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "igrdp.h"

#include "dpstruct.h"

#include "bserr.h"
#include "bsparameters.h"

#include "ve.h"
#include "vedef.h"

#define PARALLEL_EPSILON	0.98

/* prototype files */
#include "VEpr_hiding.h"
#include "VEpr_utilfnc.h"

#include "bscveval.h"

/* prototypes for static functions */
#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C"
{
#endif
   static IGRboolean VEis_span_overlapped __( ( IGRdouble u0, IGRdouble u1,
                                                struct VEedge_header * edge,
                                                     IGRdouble knot_tol ) );

   static IGRint VEwhich_region_is_in_front __( ( 
                                               struct VEedge_header * edge0,
                                                        IGRdouble * e0_parm,
                                               struct VEedge_header * edge1,
                                                  IGRdouble z_tolerance ) );

   static IGRint VEget_span_visib_from_visib_list __( ( IGRdouble u0,
                                                               IGRdouble u1,
                                           struct VEvisib_node * visib_list,
                                                     IGRdouble knot_tol ) );

   static struct VEtemp_node *VEadd_temp_node __( ( IGRdouble parm,
                                                struct VEedge_header * edge,
                                                     IGRdouble knot_tol ) );

   static void VEadd_visibility_region_to_temp_list __( ( IGRdouble u0,
                                                               IGRdouble u1,
                                                struct VEedge_header * edge,
                                                               IGRint visib,
                                                     IGRdouble knot_tol ) );

   static void VEadd_same_z_overlap_unknown_nodes __( ( 
                                                struct VEedge_header * edge,
                                                          IGRdouble * parms,
                                                                IGRint vis0,
                                                                IGRint vis1,
                                                     IGRdouble knot_tol ) );

   static void VEprocess_same_z_overlap __( ( struct VEedge_header * edge0,
                                               struct VEedge_header * edge1,
                                                        IGRdouble * e0_parm,
                                                        IGRdouble * e1_parm,
                                            IGRboolean elem0_can_hide_elem1,
                                            IGRboolean elem1_can_hide_elem0,
                                                        IGRdouble knot_tol0,
                                                        IGRdouble knot_tol1,
                                                 IGRboolean self_hiding ) );
#if defined(__cplusplus)
}

#endif

#undef __

#define STACK_POLES                      100
#define CANT_DETERMINE_WHICH_IS_IN_FRONT 0
#define CURVE0_IS_IN_FRONT               1
#define CURVE1_IS_IN_FRONT               2

/* static space to hold an order 2, 2 pole curve */
static IGRdouble VEline_poles[6];
static IGRdouble VEline_knots[4] = {0.0, 0.0, 1.0, 1.0};

static struct IGRbsp_curve VEline = {2, /* order */
   FALSE, FALSE,        /* periodic, non-uniform */
   2, VEline_poles,     /* num_poles, poles */
   4, VEline_knots,     /* num_knots, knots */
   FALSE, NULL, /* rational, weights */
   FALSE, FALSE,        /* planar, phy_closed */
0, NULL};       /* num_boundaries, bdrys */

/* Global:  indicates special VDS-specific VE processing is in effect, */
/* which does not output results for "reference elements" */
extern IGRboolean VDS_REF_ELEM_PROCESSING;

/*--- VEis_span_overlapped --------------------------------*/

static IGRboolean VEis_span_overlapped( u0, u1, edge, knot_tol )

	IGRdouble            u0;
	IGRdouble            u1;
	struct VEedge_header *edge;
	IGRdouble            knot_tol;

/*
NAME
	VEis_span_overlapped (static)

DESCRIPTION
	This function returns TRUE if the span from 'u0' to 'u1' is 
	totally contained within an OVERLAPPED region of the visib_list
	or temp_list of 'edge'.

PARAMETERS
	u0 (IN) - the start of the span whose OVERLAPPED status is to
	          be determined
	u1 (IN) - the end of the span whose OVERLAPPED status is to
	          be determined
	edge (IN) - the edge whose visiblity list is to be used
	knot_tol (IN) - the knot tolerance to use

GLOBALS USED
	none

RETURN VALUES
	TRUE - if the span is in an OVERLAPPED region
	FALSE - if the span is not in an OVERALAPPED region

HISTORY
	11/15/89    S.P. Rogers
	   Creation Date
*/
	
	{
	IGRboolean          non_overlapped_region_found;
	IGRdouble           temp;
	struct VEvisib_node *test_visib;
	struct VEtemp_node  *test_temp;
	
	/* order u0 and u1 */
	if ( u0 > u1 )
	   {
	   temp = u0;
	   u0 = u1;
	   u1 = temp;
	   }

	/* See if u0 - u1 is in an OVERLAPPED span of the visib list */
	test_visib = edge->visib_list;
	while ( (test_visib->next) && ((test_visib->next->u - knot_tol) < u0) )
	   test_visib = test_visib->next;
	   
	if ( ! test_visib->next )
	   return( FALSE );

	non_overlapped_region_found = FALSE;
	do
	   {
	   if ( test_visib->visib != OVERLAPPED )
	      non_overlapped_region_found = TRUE;
	   else
	      test_visib = test_visib->next;
	   }
	while ( (! non_overlapped_region_found) && (test_visib) && ((test_visib->u + knot_tol) < u1) );
	
	if ( ! non_overlapped_region_found )
	   return( TRUE );
	else
	   {
	   /* See if u0 - u1 is in an OVERLAPPED span of the temp list */
	   test_temp = edge->temp_list;
	   while ( (test_temp->next) && ((test_temp->next->u - knot_tol) < u0) )
	      test_temp = test_temp->next;
	   
	   if ( ! test_temp->next )
	      return( FALSE );

	   non_overlapped_region_found = FALSE;
	   do
	      {
	      if ( test_temp->next_visib != OVERLAPPED )
	         non_overlapped_region_found = TRUE;
	      else
	         test_temp = test_temp->next;
	      }
	   while ( (! non_overlapped_region_found) && (test_temp) && ((test_temp->u + knot_tol) < u1) );
	
	   return( ! non_overlapped_region_found );
	   }
	
	}  /* VEis_span_overlapped */


/*--- VEwhich_region_is_in_front -----------------------------*/

static IGRint VEwhich_region_is_in_front( edge0, e0_parm, edge1, z_tolerance )
	                                   
	struct VEedge_header *edge0;
	IGRdouble            *e0_parm;
	struct VEedge_header *edge1;
	IGRdouble            z_tolerance;
	                                   
/*
NAME
	VEwhich_region_is_in_front (static)

DESCRIPTION
	Given an overlap region on two edges such that the endpoints of
	the overlap region on both curves of the same Z value, this function
	tries to determine if one region is in front of the other.  It does this
	by looking at the parametric midpoint of the overlap region on one of
	the edges and compares the Z value with the Z value of the other
	edge at the same XY value.  The Z value of the other edge is determined
	by intersecting the other edge with a line-segment that extends back
	in Z.
	
PARAMETERS
	edge0 (IN) - one edge that has the overlap span
	e0_parm (IN) - parameters of the overlap span with respect to edge0 
	edge1 (IN) - the other edge that has the overlap span
	z_tolerance (IN) - tolerance to use to decide if two Z values are equal

GLOBALS USED
	VEline (static)

RETURN VALUES
	CURVE0_IS_IN_FRONT - if curve0 is determined to be in front,
	CURVE1_IS_IN_FRONT - if curve1 is determined to be in front, or
	CANT_DETERMINE_WHICH_IS_IN_FRONT - if no determination could be made.
	   
HISTORY
	03/07/89    S.P. Rogers
	   Creation Date
*/

	{
	IGRlong     rc;
	IGRint      ret_val;
	IGRboolean  free_ints, free_overs;
	IGRint      n_int;
	IGRint      n_over;
	IGRdouble   *int_pts;
	IGRdouble   *par0, *par1;
	IGRdouble   *end_pts;
	IGRdouble   *over0, *over1;
	IGRdouble   mid_pt[3];
	IGRdouble   mid_u;
	
		
	ret_val = CANT_DETERMINE_WHICH_IS_IN_FRONT;
	
	/* evaluate the mid-point of edge0 */
	mid_u = (e0_parm[0] + e0_parm[1]) * 0.5;
	BScveval( edge0->gm_curve3d->bspcv, mid_u, 0, (IGRpoint *)mid_pt, &rc );
	
	/* build a line-segment from the evaluated point that extends */
	/* extends through the range of edge1 in Z                    */
	VEline_poles[0] = VEline_poles[3] =  mid_pt[0];
	VEline_poles[1] = VEline_poles[4] =  mid_pt[1];
	VEline_poles[2] = edge1->range[2] - (2.0 * z_tolerance);
	VEline_poles[5] = edge1->range[5] + (2.0 * z_tolerance);
	
	/* intersect edge1 and the line-segment */
	VEcvcv_int_3d( (IGRint *)&rc,
		       &VEline,
		       edge1->gm_curve3d->bspcv,
		       &n_int,
		       (IGRpoint **)&int_pts,
		       &par0, &par1,
		       &n_over,
		       (IGRpoint **)&end_pts,
		       &over0, &over1,
		       &free_ints, &free_overs );
		       
	if ( (rc == BSSUCC) && (n_int > 0) )
	   {
	   /* check the Z of the first intersection point with */
	   /* mid_pt to see which curve is in front            */
	   if ( (mid_pt[2] - int_pts[2]) > z_tolerance )
	      {
	      /* the intersetion point is closer to the eye => edge1 is in front */
	      ret_val = CURVE1_IS_IN_FRONT;
	      }
	   else if ( (int_pts[2] - mid_pt[2]) > z_tolerance )
	      {
	      /* mid_pt is closer to eye => edge0 is in front */
	      ret_val = CURVE0_IS_IN_FRONT;
	      }
	   else
	      {
	      /* coincidence */
	      ret_val = CANT_DETERMINE_WHICH_IS_IN_FRONT;
	      }

	   }  /* end: if ( rc == BSSUCC ) */
	   
	if ( free_ints )
	   {
	   if ( int_pts ) free( (IGRchar *) int_pts );
	   if ( par0 ) free( (IGRchar *) par0 );
	   if ( par1 ) free( (IGRchar *) par1 );
	   }

	if ( free_overs )
	   {
	   if ( end_pts ) free( (IGRchar *) end_pts );
	   if ( over0 ) free( (IGRchar *) over0 );
	   if ( over1 ) free( (IGRchar *) over1 );
	   }

	return( ret_val );

	}  /* VEwhich_region_is_in_front */


/*--- VEget_span_visib_from_visib_list --------------------------------*/

static IGRint VEget_span_visib_from_visib_list( u0, u1, visib_list, knot_tol )

	IGRdouble            u0;
	IGRdouble            u1;
	struct VEvisib_node  *visib_list;
	IGRdouble            knot_tol;

/*
NAME
	VEget_span_visib_from_visib_list (static)

DESCRIPTION
	This function determines the visibility status of a span from
	'u0' to 'u1' from the visib list of an edge.

PARAMETERS
	u0 (IN) - the start of the span whose visibility is to be determined
	u1 (IN) - the end of the span whose visibility is to be determined
	visib_list (IN) - the visibility list to use to determine the visibility
	knot_tol (IN) - the knot tolerance to use

GLOBALS USED
	none

RETURN VALUES
	The visibility of the span is returned if the span is totally
	contained within a span of the visib list.  If the span from
	'u0' to 'u1' is contained within more than one span of the 
	visib list than UNKNOWN is returned.

NOTES
	This function relies on the fact that a visib list will never
	contain adjacent nodes that have the same visibility.  That is,
	for a given node in a visib list the visibility of the node
	following it node must be different.

HISTORY
	04/08/92    S.P. Rogers
	   Creation Date
*/
	
	{
	IGRdouble           temp;
	
	/* order u0 and u1 */
	if ( u0 > u1 )
	   {
	   temp = u0;
	   u0 = u1;
	   u1 = temp;
	   }

	/* find the visib node that starts the span that 'u0' is contained in */
	while ( (visib_list->next) && ((visib_list->next->u - knot_tol) < u0) )
	   visib_list = visib_list->next;
	   
	if ( ! visib_list->next )
	   return( UNKNOWN );
	else if ( (visib_list->next->u + knot_tol) > u1 )
	   {
	   /* 'u0' - 'u1' is contained within span from 'visib_list->u' - 'visib_list->next->u' */
	   return( visib_list->visib );
	   }
	else
	   return( UNKNOWN );

	}  /* VEget_span_visib_from_visib_list */


#if NOT_USED_ANYMORE

/* This function has been replaced by VEget_span_visib_from_visib_list but I
   am keeping it around for awhile in case there are some problems - S.P. Rogers 04/09/92 */

/*--- VEget_span_visib_from_sh_array ---------------------------------------------*/

static IGRint VEget_span_visib_from_sh_array( u0, u1, num_sh_spans, sh_spans, knot_tol )

	IGRdouble u0;
	IGRdouble u1;
	IGRint    num_sh_spans;
	IGRdouble *sh_spans;
	IGRdouble knot_tol;
	
/*
NAME
	VEget_span_visib_from_sh_array (static)

DESCRIPTION
	This function determines the self-hiding visibility status of an
	edge from 'u0' to 'u1'.  It uses the array of self-hidden spans
	to determine the visibility.

PARAMETERS
	u0 (IN) - the start of the span whose visibility is to be determined
	u1 (IN) - the end of the span whose visibility is to be determined
	num_sh_spans (IN) - the number of self-hidden spans
	sh_spans (IN) - array of self-hidden spans
	knot_tol (IN) - the knot tolerance to use

GLOBALS USED
	none

RETURN VALUES
	   VISIBLE, if ('u0','u1') is totally outside of a self-hidden span
	   HIDDEN,  if ('u0','u1') is totally inside of a self-hidden span, or
	   UNKNOWN, if ('u0','u1') straddles a self-hidden span.
	
HISTORY
	03/30/89    S.P. Rogers
	   Creation Date
*/

	{
	IGRint             index;
	IGRdouble          temp;
	IGRdouble          low_u, high_u;
	
	if ( num_sh_spans == 0 )
	   return( VISIBLE );

	/* make sure 'u0' < 'u1' */
	if ( u0 > u1 )
	   {
	   temp = u0;
	   u0 = u1;
	   u1 = temp;
	   }

	num_sh_spans *= 2;
	
	/* skip self-hidden spans that are completely before 'u0' */
	index = 0;
	while ( index < num_sh_spans )
	   {
	   if ( (sh_spans[index+1] - knot_tol) < u0 )
	      index += 2;
	   else
	      break;

	   }  /* end: while */

	if ( index < num_sh_spans )
	   {
	   low_u = sh_spans[index];
	   high_u = sh_spans[index+1];
	      
	   /* At this point we know that 'high_u' is the high endpoint of */
	   /* the first self-hidden span that is greater than 'u0'.       */

	   if ( u0 < (low_u - knot_tol) )
	      {
	      /* 'u0' lies before this self-hidden span */
	      if ( u1 < (low_u - knot_tol) )
	         return( VISIBLE );
	      else
	         return( UNKNOWN );
	      }
	   else if ( u1 < (high_u + knot_tol) )
	      {
	      /* 'u0' and 'u1' are in the self-hidden span */
	      return( HIDDEN );
	      }
	   else
	      {
	      /* 'u0' is in the self-hidden span but 'u1' is outside */
	      return( UNKNOWN );
	      }
	   }
	else
	   {
	   /* 'u0' - 'u1' is completely after any self-hidden spans */
	   return( VISIBLE );
	   }

	}  /* VEget_span_visib_from_sh_array */
#endif

/*--- VEadd_temp_node ---------------------------------------*/

static struct VEtemp_node *VEadd_temp_node( parm, edge, knot_tol )

	IGRdouble            parm;
	struct VEedge_header *edge;
	IGRdouble            knot_tol;

/*
NAME
	VEadd_temp_node (none)

DESCRIPTION
	Adds an "UNKNOWN | UNKNOWN" node to the temp_list of an edge at
	a given parameter, unless another node already occupies that
	parameter or it is inside an overlap or hidden region.

PARAMETERS
	parm (IN) - the parameter at which to add the temp node
	edge (IN) - the edge to which to add the temp node
	knot_tol (IN) - the knot tolerance to use

GLOBALS USED
	none

RETURN VALUES
	   a pointer to the node was added,

	   a pointer to a node that already occupied the parameter,

	   a pointer to the node that started the overlapped or hidden
	   span that the parameter was in, or

	   NULL if no insertion could take place.

HISTORY
	03/30/89    S.P. Rogers
	   Creation Date
*/

	{
	struct VEtemp_node *prev_node;
	struct VEtemp_node *this_node;

	if (! ((edge->status & TOTALLY_OVERLAPPED) || (edge->status & TOTALLY_INVISIBLE)) )
	   {
	   prev_node = edge->temp_list;
	   this_node = prev_node->next;

	   while ( this_node )
	      {
	      if ( fabs( prev_node->u - parm ) < knot_tol )
	         {
	         /* add on top of prev_node */
	         return( prev_node );
	         }
	      else if ( (this_node->u - knot_tol) > parm )
	         {
	         /* add between prev_node and this_node => make sure */
	         /* we don't add in a span that is already marked    */
	         /* as OVERLAPPED or HIDDEN                          */
	         if ( (prev_node->next_visib != OVERLAPPED) ||
	              (prev_node->next_visib != HIDDEN) )
	            {
	            prev_node->next = VEalloc_temp_node( parm );
	            prev_node->next->next = this_node;
	            return( prev_node->next );
	            }
	         else
	            {
	            return( prev_node );
	            }
	         }
	      else
	         {
	         prev_node = this_node;
	         this_node = this_node->next;
	         }

	      } /* end: while */

	   /* check last node */
	   if ( fabs( prev_node->u - parm ) < knot_tol )
	      {
	      /* add on top of last node */
	      return( prev_node );
	      }
	      
	   } /* if edge is not totally overlapped */

	return( NULL );

	}  /* VEadd_temp_node */


/*--- VEadd_visibility_region_to_temp_list --------------------------------------*/

static void VEadd_visibility_region_to_temp_list( u0, u1, edge, visib, knot_tol )

	IGRdouble            u0;
	IGRdouble            u1;
	struct VEedge_header *edge;
	IGRint               visib;
	IGRdouble            knot_tol;

/*
NAME
	VEadd_visibility_region_to_temp_list (static)

DESCRIPTION
	This function adds a visibility region of visibility 'visib' to the
	temp list of 'edge' from 'u0' to 'u1'.  It is assumed that 'u0' < 'u1'.

PARAMETERS
	u0 (IN) - the start of the region to add
	u1 (IN) - the end of the region to add
	edge (IN) - the edge to which to add the temp node
	visib (IN) - the visibility of the region to add
	knot_tol (IN) - the knot tolerance to use

GLOBALS USED
	none

HISTORY
	03/30/89    S.P. Rogers
	   Creation Date
*/

	{
	struct VEtemp_node *temp_node;
	struct VEtemp_node *low_insert;
	struct VEtemp_node *high_insert;

	if ( low_insert = VEadd_temp_node( u0, edge, knot_tol ) )
	   {
	   if ( high_insert = VEadd_temp_node( u1, edge, knot_tol ) )
	      {
	      temp_node = low_insert;
	      while ( temp_node != high_insert )
	         {
	         if ( (visib > temp_node->next_visib) &&
	              (visib > temp_node->next->prev_visib) )
	            {
	            temp_node->next_visib = temp_node->next->prev_visib = visib;
	            }
	         temp_node = temp_node->next;
	         }  /* end: while */
	      }
	   }

	}  /* VEadd_visibility_region_to_temp_list */


/*--- VEadd_same_z_overlap_unknown_nodes -----------------------------------------*/

static void VEadd_same_z_overlap_unknown_nodes( edge, parms, vis0, vis1, knot_tol )

	struct VEedge_header *edge;
	IGRdouble            *parms;
	IGRint               vis0;
	IGRint               vis1;
	IGRdouble            knot_tol;
	
/*
NAME
	VEadd_same_z_overlap_unknown_nodes (static)

DESCRIPTION
	This function adds the unknown nodes to the edge involved in a
	same Z overlap that doesn't receive the overlap region.  An attempt
p	to determine the visibility between these nodes (ie., the visibility
	in the overlap region) is made by finding out the visibility of the
	overlap regions of both edges.  If both are VISIBLE, then the visibility
	must be VISIBLE.  If one is HIDDEN, then the visibility must be HIDDEN.
	Otherwise, the visibility is UNKNOWN.

PARAMETERS
	edge (IN) - the edge to which to add the nodes
	parms (IN) - the parameters of the nodes to add
	vis0 (IN) - visibility of region between nodes on first edge
	vis1 (IN) - visibility of region between nodes on second edge
	knot_tol (IN) - the knot tolerance to use

GLOBALS USED
	none

HISTORY
	03/30/89    S.P. Rogers
	   Creation Date
*/

	{
	IGRdouble u0, u1;
	
	if ( parms[0] < parms[1] )
	   {
	   u0 = parms[0];
	   u1 = parms[1];
	   }
	else
	   {
	   u0 = parms[1];
	   u1 = parms[0];
	   }
	   	
	if ( (vis0 == VISIBLE) && (vis1 == VISIBLE) )
	   VEadd_visibility_region_to_temp_list( u0, u1, edge, VISIBLE, knot_tol );
	else if ( (vis0 == HIDDEN) || (vis1 == HIDDEN) )
	   VEadd_visibility_region_to_temp_list( u0, u1, edge, HIDDEN, knot_tol );
	else
	   {
	   VEinsert_temp_node( u0, edge, knot_tol );
	   VEinsert_temp_node( u1, edge, knot_tol );
	   }
	   
	}  /* VEadd_same_z_overlap_unknown_nodes */

/*--- VEprocess_same_z_overlap --------------------------------------------*/

static void VEprocess_same_z_overlap( struct VEedge_header * edge0,
                                           struct VEedge_header * edge1,
                                           IGRdouble * e0_parm,
                                           IGRdouble * e1_parm,
                                           IGRboolean elem0_can_hide_elem1,
                                           IGRboolean elem1_can_hide_elem0,
                                           IGRdouble knot_tol0,
                                           IGRdouble knot_tol1,
                                           IGRboolean self_hiding )
/*
NAME
   VEprocess_same_z_overlap (static)

DESCRIPTION
   This function processes a same Z overlap between two edges.  In general,
   we must put an overlap region on one of the two edges and on the other
   edge we must put UNKNOWN temp nodes because the visibility of both edges
   can change at the overlap endpoints.  This function does some special
   tests to try to take the randomness out of the choice of which edge should
   get the overlap region and which edge should get the UNKNOWN temp nodes.

PARAMETERS
   edge0 (IN) - one edge involved in the overlap
   edge1 (IN) - the other edge involved in the overlap
   e0_parm (IN) - parameters of the overlap region on 'edge0'
   e1_parm (IN) - parameters of the overlap region on 'edge1'
   elem0_can_hide_elem1 (IN) - TRUE, if the element that owns 'edge0' can
         hide the element that owns 'edge1'
   elem1_can_hide_elem0 (IN) - TRUE, if the element that owns 'edge1' can
         hide the element that owns 'edge0'
   knot_tol0 (IN) - knot tolerance for 'edge0'
   knot_tol1 (IN) - knot tolerance for 'edge1'
   self_hiding (IN) - TRUE, if self-hiding is being done

GLOBALS USED
   none

HISTORY
   xx/xx/xx    S.P. Rogers    Creation Date
   04/08/92    S.P. Rogers    Changed to get the span visibilities from the
         visib_list instead of from the self-hidden span array.
   06/04/95    dh    Added VDS reference element specific processing to force
         same z overlapped curves NOT to be marked as overlaps - since the
         reference element's results will be deleted and therefore the only
         displayable edge of an overlapped pair might be deleted.
*/
{
   IGRint vis0, vis1;
   IGRboolean edge0_totally_overlaps_edge1;
   IGRboolean edge1_totally_overlaps_edge0;
   IGRdouble start_u, end_u;
   struct IGRbsp_curve *curve;

   /* Determine the visibilities of the OVERLAP regions on both edges.  If */
   /* we are still self-hiding, the visibilities should be UNKNOWN. */
   if ( self_hiding )
   {
      vis0 = vis1 = UNKNOWN;
   }
   else
   {
      vis0 = VEget_span_visib_from_visib_list( e0_parm[0], e0_parm[1],
                                             edge0->visib_list, knot_tol0 );
      vis1 = VEget_span_visib_from_visib_list( e1_parm[0], e1_parm[1],
                                             edge1->visib_list, knot_tol1 );
   }

   if ( ( edge0->status & WAS_A_DUMMY ) || ( edge1->status & WAS_A_DUMMY ) )
   {
      /* One of the edges is a dummy edge => add UNKNOWN temp nodes */
      /* instead of an overlap region */
      if ( elem0_can_hide_elem1 )
      {
         VEadd_same_z_overlap_unknown_nodes( edge1, e1_parm, vis0, vis1,
                                             knot_tol1 );
      }
      if ( elem1_can_hide_elem0 )
      {
         VEadd_same_z_overlap_unknown_nodes( edge0, e0_parm, vis0, vis1,
                                             knot_tol0 );
      }
   }
   else if ( VEis_span_overlapped( e0_parm[0], e0_parm[1], edge0, knot_tol0 )
         || VEis_span_overlapped( e1_parm[0], e1_parm[1], edge1, knot_tol1 )
             || VDS_REF_ELEM_PROCESSING )
   {
      /* One of the edges is already overlapped for this span (or VDS- */
      /* specific VE processing is in effect, which does not output */
      /* results for "reference elements") => put UNKNOWN nodes on both */
      /* edges */
      if ( elem0_can_hide_elem1 )
      {
         VEadd_same_z_overlap_unknown_nodes( edge1, e1_parm, vis0, vis1,
                                             knot_tol1 );
      }
      if ( elem1_can_hide_elem0 )
      {
         /* The following line was changed from "knot_tol1" to */
         /* "knot_tol0", since it seemed to be an error.  -dh  4/6/95 */
         VEadd_same_z_overlap_unknown_nodes( edge0, e0_parm, vis0, vis1,
                                             knot_tol0 );
      }
   }
   else if ( edge0->gm_curve3d->bspcv->order >
             edge1->gm_curve3d->bspcv->order )
   {
      /* Curve0 has a higher order than curve1 => put overlap on edge1 and */
      /* UNKNOWN nodes on edge0 */
      VEadd_overlap_region( e1_parm[0], e1_parm[1], edge1,
                  ( elem0_can_hide_elem1 ? UNKNOWN : VISIBLE ), knot_tol1 );
      if ( elem1_can_hide_elem0 )
      {
         VEadd_same_z_overlap_unknown_nodes( edge0, e0_parm, vis0, vis1,
                                             knot_tol0 );
      }
   }
   else if ( edge1->gm_curve3d->bspcv->order >
             edge0->gm_curve3d->bspcv->order )
   {
      /* Curve1 has a higher order than curve0 => put overlap on edge0 and */
      /* UNKNOWN nodes on edge1 */
      VEadd_overlap_region( e0_parm[0], e0_parm[1], edge0,
                  ( elem1_can_hide_elem0 ? UNKNOWN : VISIBLE ), knot_tol0 );
      if ( elem0_can_hide_elem1 )
      {
         VEadd_same_z_overlap_unknown_nodes( edge1, e1_parm, vis0, vis1,
                                             knot_tol1 );
      }
   }
   else
   {
      curve = edge1->gm_curve3d->bspcv;
      start_u = curve->knots[curve->order - 1];
      end_u = curve->knots[curve->num_knots - curve->order];
      edge0_totally_overlaps_edge1 =
         ( ( ( e1_parm[0] == start_u ) && ( e1_parm[1] == end_u ) ) ||
           ( ( e1_parm[0] == end_u ) && ( e1_parm[1] == start_u ) ) );

      curve = edge0->gm_curve3d->bspcv;
      start_u = curve->knots[curve->order - 1];
      end_u = curve->knots[curve->num_knots - curve->order];
      edge1_totally_overlaps_edge0 =
         ( ( ( e0_parm[0] == start_u ) && ( e0_parm[1] == end_u ) ) ||
           ( ( e0_parm[0] == end_u ) && ( e0_parm[1] == start_u ) ) );

      if ( edge0_totally_overlaps_edge1 )
      {
         /* Edge0 totally overlaps edge1=> put overlap on edge1 and */
         /* UNKNOWN nodes on edge0 */
         VEadd_overlap_region( e1_parm[0], e1_parm[1], edge1,
                  ( elem0_can_hide_elem1 ? UNKNOWN : VISIBLE ), knot_tol1 );
         if ( elem1_can_hide_elem0 )
         {
            VEadd_same_z_overlap_unknown_nodes( edge0, e0_parm, vis0, vis1,
                                                knot_tol0 );
         }
      }
      else if ( edge1_totally_overlaps_edge0 )
      {
         /* Edge1 totally overlaps edge0=> put overlap on edge0 and */
         /* UNKNOWN nodes on edge1 */
         VEadd_overlap_region( e0_parm[0], e0_parm[1], edge0,
                  ( elem1_can_hide_elem0 ? UNKNOWN : VISIBLE ), knot_tol0 );
         if ( elem0_can_hide_elem1 )
         {
            VEadd_same_z_overlap_unknown_nodes( edge1, e1_parm, vis0, vis1,
                                                knot_tol1 );
         }
      }
      else if ( elem0_can_hide_elem1 )
      {
         VEadd_overlap_region( e1_parm[0], e1_parm[1], edge1, UNKNOWN,
                               knot_tol1 );
         if ( elem1_can_hide_elem0 )
         {
            VEadd_same_z_overlap_unknown_nodes( edge0, e0_parm, vis0, vis1,
                                                knot_tol0 );
         }
      }
      else if ( elem1_can_hide_elem0 )
      {
         VEadd_overlap_region( e0_parm[0], e0_parm[1], edge0, UNKNOWN,
                               knot_tol0 );
      }
      else
      {
         VEadd_overlap_region( e0_parm[0], e0_parm[1], edge0, VISIBLE,
                               knot_tol0 );
      }
   }
}/* VEprocess_same_z_overlap */

/*--- VEprocess_overlap ----------------------------------------*/

void VEprocess_overlap(	struct VEedge_header *edge0,
			struct VEedge_header *edge1,
			IGRdouble            *e0_parm, 
			IGRdouble            *e1_parm,
			IGRdouble            *e0_xyz,
                        IGRdouble            *e1_xyz,
			IGRboolean           elem0_can_hide_elem1,
			IGRboolean           elem1_can_hide_elem0,
			IGRdouble            z_tolerance,
			IGRdouble            knot_tol0, 
			IGRdouble            knot_tol1,
			IGRboolean           self_hiding )

/*
NAME
	VEprocess_overlap

DESCRIPTION
	This function Takes two curves and an overlap region on each (in
	both parametric and XYZ space) and puts the appropriate nodes on
	their temp-lists.

PARAMETERS
	edge0 (IN) - one edge involved in the overlap
	edge1 (IN) - the other edge involved in the overlap
	e0_parm (IN) - parameters of the overlap region on 'edge0'
	e1_parm (IN) - parameters of the overlap region on 'edge1'
	e0_xyz (IN) - XYZ points for the overlap region on 'edge0'
	e1_xyz (IN) - XYZ points for the overlap region on 'edge1'
	elem0_can_hide_elem1 (IN) - TRUE, if the element that owns 'edge0'
	                            can hide the element that owns 'edge1'
	elem1_can_hide_elem0 (IN) - TRUE, if the element that owns 'edge1'
	                            can hide the element that owns 'edge0'
	z_tolerance (IN) - tolerance to use to decide if two Z values are equal
	knot_tol0 (IN) - knot tolerance for 'edge0'
	knot_tol1 (IN) - knot tolerance for 'edge1'
	self_hiding (IN) - TRUE, if self-hiding is being done

GLOBALS USED
	none

HISTORY
	08/26/87    S.A. Rapa
	   Creation Date
*/

	{
	IGRshort  visibility;
      
	if ((e1_xyz[2] - e0_xyz[2] > z_tolerance) ||
	    (e1_xyz[5] - e0_xyz[5] > z_tolerance)   )
	   {
	   visibility = (elem0_can_hide_elem1) ? UNKNOWN : VISIBLE;

	   if ((e1_xyz[2] - e0_xyz[2] > z_tolerance) &&
	       (e1_xyz[5] - e0_xyz[5] > z_tolerance)   )
	      {
	      /* Edge 0 is on top of edge 1 */
	      VEadd_overlap_region (e1_parm[0], e1_parm[1], edge1, visibility, knot_tol1);
	      }

	   else if (fabs (e1_xyz[2] - e0_xyz[2]) < z_tolerance)
	      {
	      /* Edge 0 is on top of edge 1, but they share endpoint 0 */
	      VEadd_overlap_region (e1_parm[0], e1_parm[1], edge1, visibility, knot_tol1);
	      if ( elem1_can_hide_elem0 )
	         VEinsert_temp_node (e0_parm[0], edge0, knot_tol0);
	      }
	   else if (fabs (e1_xyz[5] - e0_xyz[5]) < z_tolerance)
	      {
	      /* Edge 0 is on top of edge 1, but they share endpoint 1 */
	      VEadd_overlap_region (e1_parm[0], e1_parm[1], edge1, visibility, knot_tol1);
	      if ( elem1_can_hide_elem0 )
	         VEinsert_temp_node (e0_parm[1], edge0, knot_tol0);
	      }
	   } /* end if edge 0 on top of edge 1 */

	else if ((e0_xyz[2] - e1_xyz[2] > z_tolerance) ||
	         (e0_xyz[5] - e1_xyz[5] > z_tolerance)   )
	   {
	   visibility = (elem1_can_hide_elem0) ? UNKNOWN : VISIBLE;

	   if ((e0_xyz[2] - e1_xyz[2] > z_tolerance) &&
	       (e0_xyz[5] - e1_xyz[5] > z_tolerance)   )
	      {
	      /* Edge 1 is on top of edge 0 */
	      VEadd_overlap_region (e0_parm[0], e0_parm[1], edge0, visibility, knot_tol0);
	      }
	   else if (fabs (e1_xyz[2] - e0_xyz[2]) < z_tolerance)
	      {
	      /* Edge 1 is on top of edge 0, but they share endpoint 0 */
	      VEadd_overlap_region (e0_parm[0], e0_parm[1], edge0, visibility, knot_tol0);
	      if ( elem0_can_hide_elem1 )
	         VEinsert_temp_node (e1_parm[0], edge1, knot_tol1);
	      }
	   else if (fabs (e1_xyz[5] - e0_xyz[5]) < z_tolerance)
	      {
	      /* Edge 1 is on top of edge 0, but they share endpoint 1 */
	      VEadd_overlap_region (e0_parm[0], e0_parm[1], edge0, visibility, knot_tol0);
	      if ( elem0_can_hide_elem1 )
	         VEinsert_temp_node (e1_parm[1], edge1, knot_tol1);
	      }
	   } /* end if edge 1 on top of edge 0 */

	else

	   {
	   /* Same-Z overlap */

	   /* see if we can find out if one edge is in front of the other */
	   switch( VEwhich_region_is_in_front( edge0, e0_parm, edge1, z_tolerance ) )
	      {
	      case CURVE0_IS_IN_FRONT :
	   
	         /* edge0 is in front => add overlap region to edge1 and */
	         /* add unknown temp nodes to edge0                      */
	         visibility = (elem0_can_hide_elem1) ? UNKNOWN : VISIBLE;

                 VEadd_overlap_region( e1_parm[0], e1_parm[1], edge1, visibility, knot_tol1 );
	      
	         if ( elem1_can_hide_elem0 )
	            {
                    VEinsert_temp_node( e0_parm[0], edge0, knot_tol0 );
                    VEinsert_temp_node( e0_parm[1], edge0, knot_tol0 );
	            }
	         break;

	      case CURVE1_IS_IN_FRONT :
	   
	         /* edge1 is in front => add overlap region to edge0 and */
	         /* add unknown temp nodes to edge1                      */
	         visibility = (elem1_can_hide_elem0) ? UNKNOWN : VISIBLE;

                 VEadd_overlap_region( e0_parm[0], e0_parm[1], edge0, visibility, knot_tol0 );
	      
	         if ( elem0_can_hide_elem1 )
	            {
                    VEinsert_temp_node( e1_parm[0], edge1, knot_tol1 );
                    VEinsert_temp_node( e1_parm[1], edge1, knot_tol1 );
	            }
	         break;
	      	         	
	      case CANT_DETERMINE_WHICH_IS_IN_FRONT :
	   
	         /* can't determine which edge is in front => try some other things */
	         VEprocess_same_z_overlap( edge0, edge1,
	                                   e0_parm, e1_parm,
	                                   elem0_can_hide_elem1, elem1_can_hide_elem0,
	                                   knot_tol0, knot_tol1,
	                                   self_hiding );
	         break;
	         
	      }  /* end: switch */

	   } /* end same z overlap */

	} /* VEprocess_overlap */


/*--- VEoverlap_is_really_intersection ---------------------------------*/

IGRboolean VEoverlap_is_really_intersection (pt0, pt1, pt2, pt3, z_tolerance)

	IGRpoint  pt0, pt1, pt2, pt3;
	IGRdouble z_tolerance;

/*
NAME
	VEoverlap_is_really_intersection

DESCRIPTION
	Given the endpoints of two overlap regions in XYZ space, determine if
	they should be considered as a single intersection point.

PARAMETERS
	pt0 (IN) - XYZ point of beginning of overlap on first edge
	pt1 (IN) - XYZ point of end of overlap on first edge
	pt2 (IN) - XYZ point of beginning of overlap on second edge
	pt3 (IN) - XYZ point of end of overlap on second edge
	z_tolerance (IN) - tolerance to use to decide if two Z values are equal

GLOBALS USED
	none

RETURN VALUES
	TRUE - if overlap should be treated as an intersection
	FALSE - if overlap should not be treated as an intersection (i.e.,
	        treat it as an overlap)

HISTORY
	xx/xx/xx   S.A. Rapa
	   Creation Date
*/

	{
	IGRvector v1, v2;
	IGRdouble len, dot;

	/* See if segments defined by endpoints cross in Z. */
	/* Segments are (pt0, pt2) and (pt1, pt3).          */

	if ( ! (((pt0[2] > pt1[2] + z_tolerance) && (pt2[2] < pt3[2] - z_tolerance)) ||
	        ((pt0[2] < pt1[2] - z_tolerance) && (pt2[2] > pt3[2] + z_tolerance))   ))
	   return (FALSE);

	/* They cross in Z, so see if the segments are almost parallel */

	v1[0] = pt0[0] - pt2[0];
	v1[1] = pt0[1] - pt2[1];
	v1[2] = pt0[2] - pt2[2];

	v2[0] = pt1[0] - pt3[0];
	v2[1] = pt1[1] - pt3[1];
	v2[2] = pt1[2] - pt3[2];

	/* Normalize vectors */
	len = sqrt( (v1[0] * v1[0]) + (v1[1] * v1[1]) + (v1[2] * v1[2]) );
	v1[0] /= len;
	v1[1] /= len;
	v1[2] /= len;

	len = sqrt( (v2[0] * v2[0]) + (v2[1] * v2[1]) + (v2[2] * v2[2]) );
	v2[0] /= len;
	v2[1] /= len;
	v2[2] /= len;

	/* Dot them */
	dot = (v1[0] * v2[0]) + (v1[1] * v2[1]) + (v1[2] * v2[2]);
	if ( fabs( dot ) < PARALLEL_EPSILON )
	   return (TRUE);
	else
	   return (FALSE);

	}  /* VEoverlap_is_really_intersection */
