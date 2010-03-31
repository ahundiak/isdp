
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:42:00 $
$Locker:  $
*/

#define CHECK_RETURN_CODES 1

#define DEBUG_MULT_PROJ   0


#define UVRANGE_TOL 0.0000001

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

#include "OMminimum.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "igr.h"
#include "igrdp.h"

#include "dpstruct.h"
#include "godef.h"
#include "gr.h"
#include "go.h"

#include "bs.h"
#include "bserr.h"
#include "bsparameters.h"

#include "ve_timing.h"
#include "ve.h"
#include "vedef.h"
#include "veerr.h"

/* prototype files */
#include "VEpr_hiding.h"
#include "VEpr_debug.h"
#include "VEpr_utilimp.h"
#include "VEpr_utilfnc.h"

#include "bscveval.h"
#include "bscvkttol2.h"
#include "bspjptsgmsf.h"
#include "bsptnorsf.h"
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

static IGRboolean VEis_span_invisible __(( 
				IGRdouble             u0,
				IGRdouble             u1,
				struct VEvisib_node   **visib_list,
				IGRdouble             knot_tol ));

static void VEsetup_sh_spans __((
			 	struct VEedge_header  *edge ));

static IGRboolean VEuse_cht_offset_proj_scheme __(( 
				IGRboolean              self_hiding,
				struct VEedge_header    *edge,
				struct VEelement_header *other_element ));

static void VEcalc_cht_offset_proj_pts __((	
				IGRpoint            from_pt,
				IGRdouble           from_u,
				struct IGRbsp_curve *curve,
				IGRpoint            *points ));

static IGRboolean VEuse_dist_tol_offset_proj_scheme __((
				IGRboolean              self_hiding,
				struct VEedge_header    *edge,
				IGRpoint                from_pt,
				struct VEelement_header *element,
				struct VEelement_header *other_element ));

static void VEcalc_dist_tol_offset_proj_pts __((
				IGRpoint            from_pt,
				IGRdouble           from_u,
				struct IGRbsp_curve *curve,
				IGRpoint            *points ));

static IGRshort VEdetermine_point_visib_from_single_proj __((
				IGRint                  num_proj_pts,
				IGRdouble               *uv_par,
				struct VEelement_header *hiding_element,
				IGRchar                 *in_solid_flags ));

static IGRshort VEdetermine_point_visib_from_double_proj __((
				IGRint                  num0, 
				IGRint                  num1,
				struct VEelement_header *hiding_element,
        			IGRchar                 *in_solid_flags1, 
				IGRchar                 *in_solid_flags2 ));

static void VEdetermine_vis_with_mult_proj __((
				IGRint                  proj_count,
				IGRpoint                *proj_pt_array,
				struct VEpt_proj_node   **ptr_array,
				struct VEelement_header *hiding_element ));

static void VEadd_proj_points_to_master_list __(( 
				struct VEelement_header *from_elem ));

static void VEproject_into_element __((
				struct VEelement_header *to_elem ));

static void VEmerge_element_visibilities __(( 
				struct VEelement_header *element,
				IGRboolean              doing_hiding,
				IGRboolean              self_hiding ));

#if defined(__cplusplus)
}
#endif

#undef __


#define NUM_PROJ_VECS          1
#define MAX_PROJ_POINTS        120
#define AVERAGE_HITS_PER_POINT 1
#define HIT_ALLOCATION         MAX_PROJ_POINTS * AVERAGE_HITS_PER_POINT

#if TIMING
extern IGRint     VEnum_proj_points;
extern IGRdouble  VEtime_ptproj;
extern IGRint     VEcount_ptproj;
extern struct tms VEs_time;
extern struct tms VEe_time;
#endif

/* External Global Variables */
extern struct VEexecution_status VEexec_status;

/* Static variables used by the routines in this file */
static IGRvector proj_vec = { 0.0, 0.0, -1.0 };
static IGRdouble cht, offset_cht;
static IGRdouble dist_tol, offset_dist_tol;
static IGRdouble cht_z_displacement;
static struct VEpt_proj_node *master_proj_head, *master_proj_tail;


#define ADD_TO_MASTER_PROJ_LIST( node )                \
	{                                              \
	if ( master_proj_head == NULL )                \
	   {                                           \
	   master_proj_head = master_proj_tail = node; \
	   }                                           \
	else                                           \
	   {                                           \
	   master_proj_tail->next = node;              \
	   master_proj_tail = node;                    \
	   }                                           \
	}                                              \


/*--- VEis_span_invisible --------------------------------*/

static IGRboolean VEis_span_invisible( u0, u1, visib_list, knot_tol )

	IGRdouble           u0;
	IGRdouble           u1;
	struct VEvisib_node **visib_list;
	IGRdouble           knot_tol;

/*
NAME
	VEis_span_invisible (static)

DESCRIPTION
	This function returns TRUE if the span from 'u0' to 'u1' is 
	totally contained within HIDDEN and OVERLAPPED regions of 'visib_list'.
	It also assigns 'visib_list' to point to the first node that is less
	than 'u0'.  This is done so that multiple calls to this function with
	the same visibility list are more efficient.

PARAMETERS
	u0 (IN) - start parameter of span
	u1 (IN) - end parameter of span
	visib_list (IN) - the visibility list to test against
	knot_tol (IN) - the knot tolerance to use

RETURN VALUES
	TRUE - if the span is invisible
	FALSE - if the span is not invisible

GLOBALS USED
	none

HISTORY
	04/10/89    S.P. Rogers
	   Creation Date
*/
	
	{
	IGRboolean          visib_region_found;
	struct VEvisib_node *this_visib;
	struct VEvisib_node *test_visib;
	
	this_visib = *visib_list;
	while ( (this_visib->next) && ((this_visib->next->u - knot_tol) < u0) )
	   this_visib = this_visib->next;
	   
	if ( ! this_visib->next )
	   return( FALSE );

	visib_region_found = FALSE;
	test_visib = this_visib;
	do
	   {
	   if ( test_visib->visib == VISIBLE )
	      visib_region_found = TRUE;
	   else
	      test_visib = test_visib->next;
	   }
	while ( (test_visib) && 
	        (! visib_region_found) && ((test_visib->u + knot_tol) < u1) );
	
	*visib_list = this_visib;

	return( ! visib_region_found );
	
	}  /* VEis_span_invisible */


/*--- VEsetup_sh_spans -------------------------------------------*/

static void VEsetup_sh_spans( edge )

	struct VEedge_header *edge;

/*
NAME
	VEsetup_sh_spans (static)

DESCRIPTION
	Use the information in the 'visib-list' to set up an array of
	self-hidden spans for an edge.  A self-hidden span of an edge
	cannot provide any hiding information when hiding another surface,
	so this array is used to keep from doing unneccessary point
	projections.

PARAMETERS
	edge (IN) - the edge that is to have its self hidden span
	            array set-up

GLOBALS USED
	none

HISTORY
	xx/xx/xx    S.P. Rogers
	   Creation Date
*/
	
	{
	IGRint              num_spans, index;
	struct VEvisib_node *this_node;

	/* Count the hidden spans */
	num_spans = 0;
	this_node = edge->visib_list;
	while ( this_node )
	   {
	   if (this_node->visib == HIDDEN)
	      num_spans++;

	   this_node = this_node->next;
	   }

	edge->num_sh_spans = num_spans;
	if ( num_spans > 0 )
	   {
	   num_spans *= 2;
	   edge->sh_spans = (IGRdouble *) malloc( num_spans * sizeof( IGRdouble ) );
	   if ( ! edge->sh_spans )
	      {
	      edge->num_sh_spans = 0;
	      return;
	      }

	   /* Copy the hidden span endpoints to the array */
	   index = 0;
	   this_node = edge->visib_list;
	   while ( index < num_spans )
	      {
	      if ( this_node->visib == HIDDEN )
	         {
	         edge->sh_spans[index++] = this_node->u;
	         edge->sh_spans[index++] = this_node->next->u;
	         }

	      this_node = this_node->next;
	      }  /* end: while */

	   }  /* end: if */

	}  /* VEsetup_sh_spans */


/*--- VEis_corresponding_edge_in_edge_list --------------------------------*/

IGRboolean VEis_corresponding_edge_in_edge_list( edge, other_element )

	struct VEedge_header    *edge;
	struct VEelement_header *other_element;

/*
NAME
	VEis_corresponding_edge_in_edge_list

DESCRIPTION
	This function determines if the corresponding shared edge of an edge is
	in a given element's list of edges.
	
PARAMETERS
	edge (IN) - the edge whose shared edge is to be searched for in
	            another edge list
	other_element (IN) - the element that owns the edge list to be
	                     searched

RETURN VALUES
	TRUE - if the corresponding shared edge is in the edge list
	FALSE - if the corresponding shared edge is not in the edge list

GLOBALS USED
	none

HISTORY
	02/24/89    S.P. Rogers
	   Creation Date
*/

	{
	struct VEedge_header *edge_to_find;
	struct VEedge_header *test_edge;
	
	edge_to_find = edge->shared_edge;
	if ( edge_to_find )
	   {
	   test_edge = other_element->edges;
	   while ( test_edge )
	      {
	      if ( test_edge == edge_to_find )
	         return( TRUE );
	      test_edge = test_edge->next;

	      }  /* end: while */

	   }  /* end: if */

	return( FALSE );
	
	}  /* VEis_corresponding_edge_in_edge_list */


/*--- VEuse_cht_offset_proj_scheme ----------------------------------*/

static IGRboolean VEuse_cht_offset_proj_scheme(
					IGRboolean              self_hiding,
					struct VEedge_header    *edge,
					struct VEelement_header *other_element )
	
/*
NAME
	VEuse_cht_offset_proj_scheme (static)

DESCRIPTION
	This function determines whether the CHT based offset projection scheme
	should be used for all projections from an edge.  The CHT based offset
	projection scheme is used when:
	
	   1) we are self-hiding a parting line or a stroked boundary, or

	   2) we are projecting from a shared stroked boundary into the
	      surface that owns the other shared edge.

	This scheme helps to solve the tolerance problems encountered when
	projecting into a surface from a curve that was stroked from the
	surface (i.e., the original projection point is not on the
	surface).

	For more information on the CHT based offset projection scheme see the
	description of VEcalc_cht_offset_proj_pts().
	
PARAMETERS
	self_hiding (IN) - TRUE, if self-hiding is being performed
	edge (IN) - the edge that is being projected from
	other_element (IN) - the element being projected into

RETURN VALUES
	TRUE - if cht offset projections should be used
	FALSE - if cht offset projections should be not used

GLOBALS USED
	none

HISTORY
	02/24/89    S.P. Rogers
	   Creation Date
*/

	{
	if ( self_hiding )
	   {
	   if ( (edge->type == HORIZON_EDGE) || (edge->type == HORIZON_CURVE) ||
	      ( (edge->type == BOUNDARY) && (edge->gm_curve3d->bspcv->order == 2) ) )
	      return( TRUE );
	   }
	else if ( (edge->type == BOUNDARY) && (edge->gm_curve3d->bspcv->order == 2) )
	   {
	   /* see if we are projecting from a shared edge into the */
	   /* the surface that owns the other shared edge          */
	   return( VEis_corresponding_edge_in_edge_list( edge, other_element ) );
	   }
	   
	return( FALSE );
	}  /* VEuse_cht_offset_proj_scheme */

	
/*--- VEcalc_cht_offset_proj_pts -------------------------------------------------------*/

static void VEcalc_cht_offset_proj_pts( from_pt, from_u, curve, points )

	IGRpoint            from_pt;
	IGRdouble           from_u;
	struct IGRbsp_curve *curve;
	IGRpoint            *points;

/*
NAME
	VEcalc_cht_offset_proj_pts (static)

DESCRIPTION
	This function calculates the CHT based offset projection points given
	a starting point and a curve.  The two points are returned in the array
	"points".  The two projection points are determined by offseting the
	original projection point by (1.1 * CHT) along the vector perpindicular
	to the line segment of the order 2 curve on which the original
	projection point lies.  In order for "from_pt" to be hidden both of
	the offset projection points must project into the target surface.
	
PARAMETERS
	from_pt (IN) - the point from which the projection is being done
	from_u (IN) - the parameter from which the projection is
	              being done
	curve (IN) - the curve from which the projection is being done
	points (OUT) - array of cht offset projection points

NOTES
	The ingenious double point projection algorithm was originally
	discovered and implemented by P.R. Slubicki.
	
GLOBALS USED
	none

HISTORY
	07/27/88    S.P. Rogers
	   Creation Date.
*/

	{
	IGRint     knot_index;
	IGRint     pole_index;
	IGRdouble  len;
	IGRdouble  perp_vec[2];
	IGRdouble  *knot_array;
	IGRdouble  *pole_array;
  
	/* Find the poles between which from_pt lies. */
	knot_array = curve->knots;
	pole_array = curve->poles;
	knot_index = 2;
	while (knot_array[knot_index] <= from_u)
	   knot_index++;
	pole_index = (knot_index - 2) * 3;

	/* Find the vector that is perpendicular to the chord that from_pt is on and  */
	/* normalize it. Since a vector parallel to the chord is <(x2 - x1), (y2 - y1)>, */
	/* where (x1, y1) and (x2, y2) are the endpoints of the chord, then a  vector    */
	/* perpendicular to the chord is <(y2 - y1), (x1 - x2)>.                         */
	perp_vec[0] = pole_array[pole_index + 4] - pole_array[pole_index + 1];
	perp_vec[1] = pole_array[pole_index] - pole_array[pole_index + 3];

	/* normalize and scale vector */
	len = sqrt( perp_vec[0] * perp_vec[0] + perp_vec[1] * perp_vec[1] );
	 
	if ( len != 0.0 )
	   {
	   perp_vec[0] = (perp_vec[0] / len) * offset_cht;
	   perp_vec[1] = (perp_vec[1] / len) * offset_cht;
	   }

	points[0][0] = from_pt[0] + perp_vec[0];
	points[0][1] = from_pt[1] + perp_vec[1];
	points[0][2] = from_pt[2];
                     
	points[1][0] = from_pt[0] - perp_vec[0];
	points[1][1] = from_pt[1] - perp_vec[1];
	points[1][2] = from_pt[2];
    
	} /* VEcalc_cht_offset_proj_pts */

	
/*--- VEuse_dist_tol_offset_proj_scheme ----------------------------------*/

static IGRboolean VEuse_dist_tol_offset_proj_scheme(
					IGRboolean              self_hiding,
					struct VEedge_header    *edge,
					IGRpoint                from_pt,
					struct VEelement_header *element,
					struct VEelement_header *other_element )
	
/*
NAME
	VEuse_dist_tol_offset_proj_scheme (static)

DESCRIPTION
	This function determines whether the DIST_TOL based offset projection
	schemeshould be used for a given projection point.  The DIST_TOL
	based offset projection scheme is used when:
	
	   1) (we are self-hiding an edge that is not a parting line
	      or a stroked boundary), OR (we are projecting from a shared
	      natural edge or non-stroked boundary into the surface that
	      owns the other shared edge) AND (the projection projection
	      point plus a small offset in Z is still within 1.5*DIST_TOL
	      of the surface)

	This scheme helps to solve tolerance problems encountered when
	projecting from regions on surfaces that have small degrees (i.e.,
	a large radius) of curvature.  If a surface has a small curvature
	and we offset our projection point a small distance in Z, the new
	projection point might still be within DIST_TOL of the surface.
	This results in improper hiding because we get a projection point
	almost equal to	the original point back and consider the point
	hidden.

	For more information on the DIST_TOL based offset projection scheme
	see the description of VEcalc_dist_tol_offset_proj_pts().
	
PARAMETERS
	self_hiding (IN) - TRUE, if self-hiding is being performed
	edge (IN) - the edge being projected from
	from_pt (IN) - the point being projected from
	element (IN) - the element being projected from
	other_element (IN) - the element being projected into

RETURN VALUES
	TRUE - if dist-tol based offset projections should be used
	FALSE - if dist-tol based offset projections should not be used

GLOBALS USED
	none

HISTORY
	02/24/89    S.P. Rogers
	   Creation Date
*/

	{
	IGRlong               rc;
	IGRint                num;
	IGRdouble             u,v;		
	IGRdouble             dist;
	IGRpoint              bpoint, temp_pt;
	struct IGRbsp_surface *test_surf;

	if ( element->type != SURFACE )
	   return( FALSE );
	
	/* The following test is sufficient to determine if we have an appropriate */
	/* edge to check for the distance of from point to the surface bacause     */
	/* it assumes that the check for using the CHT based offset projection     */
	/* scheme has already been made for this edge.                             */
	if ( (self_hiding) ||
	     (VEis_corresponding_edge_in_edge_list( edge, other_element )) )
	   {
	   if ( self_hiding )
	      test_surf = element->geom.gmsurf->bspsf;
	   else
	      test_surf = other_element->geom.gmsurf->bspsf;
	      
	   /* check distance from from_pt to surface and return TRUE if it */
	   /* is less than dist_tol                                        */
	   temp_pt[0] = from_pt[0];
	   temp_pt[1] = from_pt[1];
	   temp_pt[2] = from_pt[2] - cht_z_displacement;

	   BSptnorsf( test_surf, temp_pt, &num, &u, &v, bpoint, &dist, &rc );
	   
	      BS_ERRCHK( rc, "VEuse_dist_tol_offset_proj_scheme:  BSptnorsf failed" );
	      
	   return( (num == 1) && (dist < (1.5*dist_tol)) );
	   }
	else
	   {
	   return( FALSE );
	   }

	}  /* VEuse_dist_tol_offset_proj_scheme */
	

/*--- VEcalc_dist_tol_offset_proj_pts -------------------------------------------*/

static void VEcalc_dist_tol_offset_proj_pts( from_pt, from_u, curve, points )

	IGRpoint            from_pt;
	IGRdouble           from_u;
	struct IGRbsp_curve *curve;
	IGRpoint            *points;
	
/*
NAME
	VEcalc_dist_tol_offset_prj_pts (static)

DESCRIPTION
	This function calculates the DIST_TOL based offset projection points
	given a starting point and a curve.  The two points are returned in
	the array "points".  The two projection points are determined by
	offsetting the original projection point by (2.2 * dist_tol) along
	the curve normal at the projection point in the XY plane.  In order
	from "from_pt" to be hidden both of the offset porjection points
	must project into the target surface.
	
PARAMETERS
	from_pt (IN) - the point being projected from
	from_u (IN) - the parameter being projected from
	curve (IN) - the curve being projected from
	points (OUT) - array of offset projection points

GLOBALS USED
	none

HISTORY
	02/24/89    S.P. Rogers
	   Creation Date.
*/

	{
	IGRlong    rc;
	IGRdouble  len;
	IGRdouble  normal[2];
	IGRpoint   eval_pt[2];

	/* Find curve normal in XY plane by finding the perpindicular */
	/* to the curve tangent vector in the XY plane                */
	
	/* evaluate curve to get first derivative (tangent) */
	BScveval( curve, from_u, 1, (IGRpoint *)eval_pt, &rc );

	   BS_ERRCHK(rc, "VEcalc_dist_tol_offset_proj_pts: BScveval failed\n");
		
	/* find vector perpindicular to tangent */
	normal[0] = -eval_pt[1][1];
	normal[1] = eval_pt[1][0];
	
	/* normalize and scale vector */
	len = sqrt( normal[0]*normal[0] + normal[1]*normal[1] );
	if ( len != 0.0 )
	   {
	   normal[0] = (normal[0] / len) * offset_dist_tol;
	   normal[1] = (normal[1] / len) * offset_dist_tol;
	   }
	   
	/* calculate offset points */
	points[0][0] = from_pt[0] + normal[0];
	points[0][1] = from_pt[1] + normal[1];
	points[0][2] = from_pt[2] - cht_z_displacement;
                     
	points[1][0] = from_pt[0] - normal[0];
	points[1][1] = from_pt[1] - normal[1];
	points[1][2] = from_pt[2] - cht_z_displacement;

	}  /* VEcalc_dist_tol_offset_proj_pts */


/*--- VEdetermine_point_visib_from_single_proj --------------------------------------------*/

static IGRshort VEdetermine_point_visib_from_single_proj( num_proj_pts, uv_par, hiding_element, in_solid_flags )
	      	                  
	IGRint                  num_proj_pts;
	IGRdouble               *uv_par;
	struct VEelement_header *hiding_element;
	IGRchar                 *in_solid_flags;

/*
NAME
	VEdetermine_point_visib_from_single_point (static)

DESCRIPTION
	This function determines the visibility of a point given the parametric
	point projection results from that point.
	
PARAMETERS
	num_proj_pts (IN) - number of hit points for this point
	uv_par (IN) - array of hit parameters on hiding surface
	hiding_element (IN) - the hiding element
	in_solid_flags (IN) - solid/hole status array for hit parameters

RETURN VALUES
	VISIBLE - if there are no projection points or all of the
	          projection points lie in HOLE regions of the surface.
	             
	HIDDEN - if there is a projection point that lies in a SOLID
	         region of the surface.

GLOBALS USED
	none

HISTORY
	08/25/88    S.P. Rogers
	   Creation date
*/

	{
	IGRint ii;
	
	if ( hiding_element->flags & HAS_BOUNDARIES )
	   {
	   /* hiding element has boundaries => test each */
	   /* projection point's SOLID/HOLE status       */
	   ii = 0;
	   while ( ii < num_proj_pts )
	      {
              if ( in_solid_flags[ii] )
	         return( HIDDEN );

	      uv_par += 2;
	      ii++;
	      }  /* end: while */
	   
	   /* no projection points were in SOLID regions */
	   return( VISIBLE );

	   }  /* end: ( if hiding_element ... ) */
	else
	   {
	   return( (num_proj_pts == 0) ? VISIBLE : HIDDEN );
	   }
	
	}  /* VEdetermine_point_visib_from_single_proj */


/*--- VEdetermine_point_visib_from_double_proj --------------------------------------------*/

static IGRshort VEdetermine_point_visib_from_double_proj( num0, num1, hiding_element,
	                                                  in_solid_flags1, in_solid_flags2 )
	      	                  
	IGRint                  num0, num1;
	struct VEelement_header *hiding_element;
        IGRchar                 *in_solid_flags1, *in_solid_flags2;

/*
NAME
	VEdetermine_point_visib_from_double_proj (static)

DESCRIPTION
	This function determines the visibility of a point given the parametric
	double point projection results from that point.
	
PARAMETERS
	num0 (IN) - number of hit points for first point
	num1 (IN) - number of hit points for second point
	hiding_element (IN) - the hiding element
	in_solid_flags1 (IN) - solid/hole status array for first hit parameters
	in_solid_flags1 (IN) - solid/hole status array for second hit parameters

RETURN VALUES
	VISIBLE - if there are no projection points or all of the projection
	          points lie in HOLE regions of the surface.
	             
	HIDDEN - if there is a projection point from both projections that lies
	         in a SOLID region of the surface.

GLOBALS USED
	none

HISTORY
	08/25/88    S.P. Rogers
	   Creation date
*/

	{
        IGRchar   *max_in_solid_flags, *min_in_solid_flags;
        IGRint    index1, index2;
	IGRint    ii;
	IGRint    min_num, max_num;
	
	if ( (num0 == 0) || (num1 == 0) )
	   {
	   /* one of the two projections doesn't have any hits => VISIBLE */
	   return( VISIBLE );
	   }
	else if ( ! (hiding_element->flags & HAS_BOUNDARIES) )
	   {
	   /* both projections have hits and the surface has no boundaries => HIDDEN */
	   return( HIDDEN );
	   }
	else
	   {
	   if ( num0 < num1 )
	      {
	      min_num = num0;
	      max_num = num1;
              min_in_solid_flags = in_solid_flags1;
              max_in_solid_flags = in_solid_flags2;
	      }
	   else
	      {
	      min_num = num1;
	      max_num = num0;
              min_in_solid_flags = in_solid_flags2;
              max_in_solid_flags = in_solid_flags1;
	      }

           index1 = index2 = 0;
	   ii = 0;
	   while ( ii < min_num )
	      {
	      if ( min_in_solid_flags[index1] )
	         {
	         /* found a hit from the min array => look for */ 
	         /* one in the max array                       */
	         ii = 0;
	         while ( ii < max_num )
	            {
	            if ( max_in_solid_flags[index2] )
	               return( HIDDEN );
                    index2++;
	            ii++;
	            }  /* end: while */

	         /* no projection points were in SOLID regions of max array */
	         return( VISIBLE );  
	         }

              index1++;
	      ii++;
	      }  /* end: while */

	   /* no projection points were in SOLID regions of min array */
	   return( VISIBLE );

	   }  /* end: else */

	}  /* VEdetermine_point_visib_from_double_proj */


/*-------------------------------------------------------------------------------*/

static void VEdetermine_vis_with_mult_proj( proj_count, proj_pt_array, ptr_array, hiding_element )

	IGRint                  proj_count;
	IGRpoint                *proj_pt_array;
	struct VEpt_proj_node   **ptr_array;
	struct VEelement_header *hiding_element;		

/*
NAME
	VEdetermine_vis_with_mult_proj (static)

DESCRIPTION
	This function determines the visibilities of "proj_count" UNKNOWN
	regions.  Pointers to the temp nodes that start the UNKNOWN regions
	are accessed through the array of pointers, 'ptr_array'.  It calls
	the math function, BSpjptsgmsf(), to perform a multiple point
	projection and then processes the hit points that were returned
	against the boundaries of the hiding element to ensure that they
	are in the "solid" region of the surface.
	
PARAMETERS
	proj_count (IN) - the number of unknown regions whose visibility
	                  is to be determined
	proj_pt_array (IN) - array of projection points
	ptr_array (IN) - array of pointers to the point projection nodes for
	                 each projection point
	hidint_element (IN) - the element to project into

GLOBALS USED
	VEexec_status

HISTORY
	07/27/88    S.P. Rogers
	   Creation Date
*/

	{
	IGRlong              rc;
	IGRboolean           had_to_alloc;
	IGRint               num[MAX_PROJ_POINTS];
	IGRint               *num_ptr;
	IGRdouble            stack_uv_par[HIT_ALLOCATION * 2];
	IGRdouble            *uv_par, *saved_uv_par=NULL;
	IGRpoint             stack_proj_pts[HIT_ALLOCATION];
	IGRpoint             *proj_pts, *saved_proj_pts=NULL;
	struct VEtemp_node   *this_temp;
	struct VEtemp_node   *next_temp;
        IGRchar              *in_solid_flags;
	IGRint               ii, jj, index;
	
	
	VEupdate_heartbeat();
	if ( IGEstop() )
	   {
	   VEexec_status.VEabort = TRUE;
	   return;
	   }

	num_ptr = num;

#if DEBUG_MULT_PROJ
	VElog_mult_proj_data( hiding_element,
	                      proj_count,
	                      proj_pt_array,
	                      1,
	                      proj_vec,
	                      FALSE,
	                      HIT_ALLOCATION );
#endif
	                      
	had_to_alloc = FALSE;

#if TIMING
	VEnum_proj_points += proj_count;
	times( &VEs_time );
#endif

	BSpjptsgmsf( hiding_element->geom.gmsurf,
		     proj_count,
		     proj_pt_array,
		     NUM_PROJ_VECS, (IGRvector *)proj_vec,
		     hiding_element->u_range, hiding_element->v_range,
	  	     FALSE,
		     HIT_ALLOCATION, stack_proj_pts, stack_uv_par,
		     &had_to_alloc,
		     num,
		     &proj_pts, &uv_par,
		     &rc );
		    
#if TIMING
	{
	times( &VEe_time );

	VEcount_ptproj++;
	VEtime_ptproj += ( ( (VEe_time.tms_utime + VEe_time.tms_stime) -
	                     (VEs_time.tms_utime + VEs_time.tms_stime) ) / 60.0 );
	}
#endif
	
	   BS_ERRCHK( rc, "VEdetermine_vis_with_mult_proj:  BSpjptsgmsf failed" );
	   
	if ( rc != BSSUCC )
	   {
	   /* point projection failed:  make hit array all zeros */
	   memset( num, 0, sizeof( IGRint ) * proj_count );
	   }

	if ( ! had_to_alloc )
	   {
	   /* math routine was able to use pre-allocated stack space */
	   proj_pts = stack_proj_pts;
	   uv_par   = stack_uv_par;
	   }
	else
	   {
	   saved_proj_pts = proj_pts;
	   saved_uv_par = uv_par;
	   }

	in_solid_flags = (IGRchar *) proj_pts;
	if ( hiding_element->flags & HAS_BOUNDARIES )
	   VEdetermine_visib_via_mult_trim( hiding_element, num, proj_count, uv_par, in_solid_flags );
	else
	   {
	   index = 0;
	   for ( ii = 0; ii < proj_count; ii++ )
	      for ( jj = 0; jj < num[ii]; jj++ )
	         in_solid_flags[index++] = TRUE;
	   }

#if DEBUG_MULT_PROJ
	VElog_mult_proj_output( proj_count,
	                        num,
	                        proj_pts,
	                        uv_par );
#endif

	while ( proj_count )
	   {
	   /* get pointers to temp-nodes that define the UNKNOWN region */
	   this_temp = (*ptr_array)->temp_node;
	   next_temp = this_temp->next;

	   if ( this_temp->status & DOUBLE_PROJ_USED )
	      {
	      if ( VEdetermine_point_visib_from_double_proj( *num_ptr, *(num_ptr + 1),
	                                                     hiding_element,
	                                                     in_solid_flags,
                                                             (in_solid_flags + *num_ptr) ) == HIDDEN )
	         {
	         this_temp->next_visib = next_temp->prev_visib = HIDDEN;
	         }
	        
	      /* adjust pointers */
	      ptr_array += 2;
	      uv_par += ( (*num_ptr + *(num_ptr + 1)) * 2 );
              in_solid_flags += (*num_ptr +*(num_ptr+1));
	      num_ptr += 2;
	      proj_count -= 2;

	      this_temp->status &= ~DOUBLE_PROJ_USED;
	      }
	   else
	      {
	      if ( VEdetermine_point_visib_from_single_proj( *num_ptr, uv_par, hiding_element, in_solid_flags ) == HIDDEN )
	         {
	         this_temp->next_visib = next_temp->prev_visib = HIDDEN;
	         }

	      /* adjust pointers */
	      ptr_array++;
	      uv_par += (*num_ptr * 2);
              in_solid_flags += (*num_ptr);
	      num_ptr++;
	      proj_count--;
	      }
	     
	   } /* end: while */

	/* Free memory allocated by the multiple point projection routine */
	if ( had_to_alloc )
	   {
	   if ( saved_proj_pts ) free( (IGRchar *) saved_proj_pts );
	   if ( saved_uv_par ) free( (IGRchar *) saved_uv_par );
	   }
	
	}  /* VEdetermine_vis_with_mult_proj */


/*--- VEadd_proj_points_to_master_list -----------------------------------------------*/

static void VEadd_proj_points_to_master_list( from_elem )

	struct VEelement_header *from_elem;

/*
NAME
	VEadd_proj_points_to_master_list (static)

DESCRIPTION
	This function adds the points from which point projections need
	to be done for an element to the master list of point projections.
	It loops over all the edges of the element and adds a node to the
	master list that represents the mid-point of each UNKNOWN span.

PARAMETERS
	from_elem (IN) - the element that is being projected from

GLOBALS USED
	none

HISTORY
	08/20/90    S.P. Rogers
	   Creation Date
*/

	{
	IGRlong               rc;
	IGRboolean            this_edge_used;
	IGRdouble             from_u;
	IGRdouble             knot_tol;
	IGRdouble             from_pt[3];
	struct VEtemp_node    *this_temp;
	struct VEtemp_node    *next_temp;
	struct VEvisib_node   *visib_node;
	struct VEedge_header  *this_edge;
	struct IGRbsp_curve   *this_curve;
	struct VEpt_proj_node *proj_node;


	this_edge = from_elem->edges;
	while ( this_edge )
	   {
	   /* skip over edges without a temp_list (i.e., */
	   /* dummies and totally overlapped edges)      */
	   if ( this_edge->temp_list )
	      {
	      if ( this_edge->status & DEBUG_EDGE )
	         {
	         fprintf( stderr, "ADDING EDGE'S TRANSTITIONS TO MASTER PROJ LIST\n" );
	         VEedge_debug( this_edge );
	         }

	      this_edge_used = FALSE;
	      this_curve = this_edge->gm_curve3d->bspcv;
	      BScvkttol2( this_curve->order, this_curve->knots, this_curve->num_poles,
	                  this_curve->poles, this_curve->weights, &knot_tol, &rc );

	      /* traverse this_edge's temp list looking for UNKNOWN regions */
	      this_temp = this_edge->temp_list;
	      visib_node = this_edge->visib_list;
	      while ( this_temp->next )
	         {
	         next_temp = this_temp->next;

	         if ( this_temp->next_visib == UNKNOWN )
	            {
	            /* If a region on the temp-list is contained within a */
	            /* HIDDEN or OVERLAPPED region on the visib-list,     */
	            /* then I do not need to do a projection.             */
	            if ( VEis_span_invisible( this_temp->u, next_temp->u,
	                                      &visib_node, knot_tol ) )
	               {
	               this_temp->next_visib = VISIBLE;
	               next_temp->prev_visib = VISIBLE;
	               }

	            else if ( this_temp->next_visib == VISIBLE ||
	                      next_temp->prev_visib == VISIBLE )
	               {
	               this_temp->next_visib = next_temp->prev_visib = VISIBLE;
	               }

	            else
	               {
	               from_u = (this_temp->u + next_temp->u) * 0.5;
	               BScveval( this_curve, from_u, 0, (IGRpoint *)from_pt, &rc );

	                  BS_ERRCHK(rc, "VEset_visibilities_mult_proj: BScveval failed\n");
      
	               if ( rc == BSSUCC )
	                  {
	                  if ( ! this_edge_used )
	                     {
	                     /* add new edge indicator to list */
	                     this_edge_used = TRUE;
	                     proj_node = VEalloc_pt_proj_node();
	                     proj_node->temp_node = NULL;
	                     proj_node->variants.ptrs.elem = from_elem;
	                     proj_node->variants.ptrs.edge = this_edge;
	                     ADD_TO_MASTER_PROJ_LIST( proj_node );
	                     }

	                  if ( this_edge->status & DEBUG_EDGE )
	                     fprintf( stderr, "   ADDING PROJECTION FROM: %20.15lf\n", from_u );

	                  proj_node = VEalloc_pt_proj_node();
	                  memcpy( proj_node->variants.pt, from_pt, sizeof( IGRdouble ) * 3 );
	                  proj_node->temp_node = this_temp;
	                  ADD_TO_MASTER_PROJ_LIST( proj_node );
	                  }	                     

	               } /* end: else of if ( span is already invisible ) */

	            }  /* end: if (this_temp->next_visib == UNKNOWN) */

	         this_temp = this_temp->next;
	         }  /* end:  while ( this_temp ... */

	      }  /* end: if ( this_edge->temp_list ) */

	   this_edge = this_edge->next;
	   }  /* end: while ( this_edge ) */

	}  /* VEadd_proj_points_to_master_list */


/*--- VEproject_into_element --------------------------------------------------*/

static void VEproject_into_element( to_elem )

	struct VEelement_header *to_elem;

/*
NAME
	VEproject_into_element (static)

DESCRIPTION
	This function projects from all of the points in the master
	projection list that overlap the XY range of 'to_elem'
	into 'to_elem'

PARAMETERS
	to_elem (IN) - the element to project into

GLOBALS USED
	master_proj_head (static)
	VEexec_status

HISTORY
	xx/xx/90   S.P. Rogers
	   Creation Date
*/

	{
	IGRboolean              use_cht_proj_scheme = FALSE;
	IGRboolean              edge_on;
	IGRboolean              cur_edge_on_to_elem;
	IGRboolean              dont_need_to_project = FALSE;
	IGRint                  proj_count;
	IGRdouble               mod_ele_range[5];
	IGRdouble               *xyz_range;
	IGRdouble               *u_range;
	IGRdouble               *v_range;
	IGRdouble               *from_pt;
	IGRpoint                proj_pt_array[MAX_PROJ_POINTS];    
	struct VEpt_proj_node   *ptr_array[MAX_PROJ_POINTS];
	struct VEpt_proj_node   *proj_node;
	struct VEelement_header *cur_elem = NULL;
	struct VEedge_header    *cur_edge = NULL;

	u_range = to_elem->u_range;
	v_range = to_elem->v_range;
	xyz_range = to_elem->range;

	edge_on = ( (to_elem->geom.gmsurf->bspsf->planar) &&
	            ( (xyz_range[XMIN] == xyz_range[XMAX]) ||
	              (xyz_range[YMIN] == xyz_range[YMAX]) ) );

	if ( (! edge_on) && 
	     ((u_range[1] - u_range[0]) > UVRANGE_TOL) &&
	     ((v_range[1] - v_range[0]) > UVRANGE_TOL) )
	   {
	   /* extend the range of the hiding element by CHT */
	   mod_ele_range[XMIN] = xyz_range[XMIN] - cht;
	   mod_ele_range[YMIN] = xyz_range[YMIN] - cht;
	   mod_ele_range[ZMIN] = xyz_range[ZMIN] - cht;
	   mod_ele_range[XMAX] = xyz_range[XMAX] + cht;
	   mod_ele_range[YMAX] = xyz_range[YMAX] + cht;

	   /* traverse master projection list and do point projections */
	   proj_count = 0;
	   proj_node = master_proj_head;
	   while ( proj_node )
	      {
	      if ( proj_node->temp_node == NULL )
	         {
	         /* new edge indicator */
	         cur_edge = proj_node->variants.ptrs.edge;
	         cur_elem = proj_node->variants.ptrs.elem;
	         cur_edge_on_to_elem = VEis_corresponding_edge_in_edge_list( cur_edge, to_elem );
	         dont_need_to_project = ( ((cur_edge_on_to_elem) || (cur_elem == to_elem)) &&
	                                  to_elem->geom.gmsurf->bspsf->planar );
	         proj_node = proj_node->next;

	         /* see if all projections from this edge should use */
	         /* the CHT based offset projection scheme           */
	         use_cht_proj_scheme = VEuse_cht_offset_proj_scheme( (cur_elem == to_elem),
	                                                             cur_edge,
	                                                             to_elem );
	         if ( cur_edge->status & DEBUG_EDGE )
	            {
	            fprintf( stderr, "PROJECTING INTO:\n" );
	            VEelement_debug( to_elem );
	            }
	         }

	      from_pt = proj_node->variants.pt;
	      if ( (! dont_need_to_project) &&
	           (proj_node->temp_node->next_visib == UNKNOWN) &&
	           (from_pt[2] > mod_ele_range[ZMIN]) &&
	           (from_pt[0] > mod_ele_range[XMIN]) &&
 	           (from_pt[0] < mod_ele_range[XMAX]) &&
	           (from_pt[1] > mod_ele_range[YMIN]) &&
	           (from_pt[1] < mod_ele_range[YMAX]) )
	         {
	         if ( use_cht_proj_scheme )
	            {
	            /* CHT based offset point projections are required */
	            /* for this edge => calculate and add both points  */
	            /* to the the array of projection points           */
	            proj_node->temp_node->status |= DOUBLE_PROJ_USED;
	            VEcalc_cht_offset_proj_pts( from_pt,
	                                        (proj_node->temp_node->u + proj_node->temp_node->next->u) * 0.5,
	                                        cur_edge->gm_curve3d->bspcv,
	                                        (IGRpoint *) proj_pt_array[proj_count] );

	            ptr_array[proj_count++] = proj_node;
	            ptr_array[proj_count++] = proj_node;
	            
	            if ( cur_edge->status & DEBUG_EDGE )
	               fprintf( stderr, "   CHT DOUBLE FROM: %20.15lf\n", proj_node->temp_node->u );
	            }
	         else if ( VEuse_dist_tol_offset_proj_scheme( (cur_elem == to_elem),
	                                                      cur_edge, from_pt,
	                                                      cur_elem,
	                                                      to_elem ) )
	            {
	            /* DIST_TOL based offset point projections are required */
	            /* for this edge => calculate and add both points to    */
	            /* the the array of projection points                   */
	            proj_node->temp_node->status |= DOUBLE_PROJ_USED;
	            VEcalc_dist_tol_offset_proj_pts( from_pt,
	                                             (proj_node->temp_node->u + proj_node->temp_node->next->u) * 0.5,
	                                             cur_edge->gm_curve3d->bspcv,
	                                             (IGRpoint *) proj_pt_array[proj_count] );
	                           	                   
	                           	                  
	            ptr_array[proj_count++] = proj_node;
	            ptr_array[proj_count++] = proj_node;
	            if ( cur_edge->status & DEBUG_EDGE )
	               fprintf( stderr, "   DIST TOL DOUBLE FROM: %20.15lf\n", proj_node->temp_node->u );
	            }
	         else
	            {
	            /* A single projection is required => add point to  */
	            /* the array of projection points.  Also, move      */
	            /* projection point closer to the eye in order to   */
	            /* avoid problems of getting invalid projection     */
	            /* points (i.e., ones we don't want)                */
	            proj_pt_array[proj_count][0] = from_pt[0];
	            proj_pt_array[proj_count][1] = from_pt[1];
	            proj_pt_array[proj_count][2] = from_pt[2] - cht_z_displacement;

	            ptr_array[proj_count++] = proj_node;
	            if ( cur_edge->status & DEBUG_EDGE )
	               fprintf( stderr, "   SINGLE FROM: %20.15lf\n", proj_node->temp_node->u );
	            } /* end: else */

	         if ( proj_count >= (MAX_PROJ_POINTS - 1) )
	            {
	            /* We have filled up the space that has been allocated */
	            /* for the multiple point projection => determine the  */
	            /* visibilities of the points so far and start filling */
	            /* the array of points again.                          */
	            VEdetermine_vis_with_mult_proj( proj_count, proj_pt_array, ptr_array, to_elem );
	            if ( VEexec_status.VEabort )
	               break;
	                  
	            proj_count = 0;
	            }

	         }  /* end: if */

	      proj_node = proj_node->next;
	      }  /* end: while ( proj_node ) */

	   /* do the last set of projections */
	   if ( (!VEexec_status.VEabort) && (proj_count != 0) )
	      {
	      VEdetermine_vis_with_mult_proj( proj_count, proj_pt_array, ptr_array, to_elem );
	      }

	   }  /* end: if ( projections should be done into to_elem ) */

	}  /* VEproject_into_element */


/*--- VEmerge_element_visibilities -----------------------------------------------*/

static void VEmerge_element_visibilities( struct VEelement_header *element,
					  IGRboolean              doing_hiding,
					  IGRboolean              self_hiding )

/*
NAME
	VEmerge_element_visibilities (static)

DESCRIPTION
	This function merges the visibilities on the temp lists of all the
	edges in 'element' into the corresponding visib lists.

PARAMETERS
	element (IN) - the element whose visibilities are to be merged
	doing_hiding (IN) - TRUE, if hiding is being performed
	self_hiding (IN) - TRUE, if self-hiding is being performed

GLOBALS USED
	none

HISTORY
	01/02/92    S.P. Rogers
	   Creation Date (extracted from VEset_visibilities_mult_proj)
*/

	{
	struct VEelement_header *this_elem;
	struct VEedge_header    *this_edge;

	this_elem = element;
	while ( this_elem )
	   {
	   this_edge = this_elem->edges;
	   while ( this_edge )
	      {
	      if ( this_edge->temp_list )
	         {
	         VEmerge_visibs( this_edge );

	         if ( (self_hiding) && (doing_hiding) )
	            VEsetup_sh_spans( this_edge );

	         if ( this_edge->status & DEBUG_EDGE )
	            {
	            fprintf( stderr, "FINISHED WITH EDGE\n" );
	            VEedge_debug( this_edge );
	            }
  	         }

	      this_edge = this_edge->next;

	      }  /* end: while ( this_edge ) */

	   this_elem = this_elem->next_in_solid;
	   }  /* end: while ( this_elem ) */

	}  /* VEmerge_element_visibilities */


/*--- VEset_visibilities_mult_proj --------------------------------------------------------*/

void VEset_visibilities_mult_proj( struct VEelement_header *element,         /* Element to set visibilities of */
				   struct VEelement_header *hiding_element,  /* Hiding element                 */
				   IGRboolean              self_hiding,      /* TRUE, if self-hiding           */
				   IGRboolean              doing_hiding )    /* TRUE, if hiding should be done */

/*
NAME
	VEset_visibilities_mult_proj

PARAMETERS
	element (IN) - the element whose UNKNOWN visibilities are to be set
	hiding_element (IN) - the element to project into
	doing_hiding (IN) - TRUE, if hiding is being performed
	self_hiding (IN) - TRUE, if self-hiding is being performed

DESCRIPTION
	This function sets the visibilities of all the UNKNOWN regions on 
	"element"'s edge list with respect to "hiding_element".  The 
	visibilities are determined by point projecting from the mid point
	of each UNKNOWN	region.
	
GLOBALS USED
	master_proj_head, master_proj_tail (static)
	VEexec_status

HISTORY
	08/29/88    S.P. Rogers
	   Creation Date
*/

	{
	BSrc                    rc;
	struct VEelement_header *from_elem, *to_elem;

        if ( !hiding_element ) return;    /*dont allow test of member if pointer is null*/

	if ( (doing_hiding) && (hiding_element->type == SURFACE) )
	   {
	   BSxtractpar( &rc, BSTOLLENVEC, &dist_tol );
	   offset_dist_tol = 2.2 * dist_tol;
	   
	   BSxtractpar( &rc, BSTOLCHRDHT, &cht );
	   offset_cht = 1.1 * cht;
	   cht_z_displacement = 1.2 * cht;

	   /* This check was put in for arrow.ems because the CHT */
	   /* was equal to DIST_TOL.  For EMS to be stable, this  */
	   /* should never happen.                                */
	   if ( cht_z_displacement < offset_dist_tol )
	      cht_z_displacement = 2.0 * offset_dist_tol;
	      
	   /* build the master list of point projections */
	   master_proj_head = master_proj_tail = NULL;
	   from_elem = element;
	   while ( from_elem )
	      {
	      VEadd_proj_points_to_master_list( from_elem );
	      from_elem = from_elem->next_in_solid;
	      }

	   to_elem = hiding_element;
	   while ( to_elem )
	      {
	      VEproject_into_element( to_elem );
	      if ( VEexec_status.VEabort )
	         break;
	      to_elem = to_elem->next_in_solid;
	      }  /* end: while ( to_elem ) */

	   /* free the master point projection list */
	   if ( master_proj_head )
	      VEfree_pt_proj_node_list( master_proj_head );

	   }  /* end: if ( doing_hiding ) */

	if ( ! VEexec_status.VEabort )
	   {
	   /* merge the visibilities into the visibility lists */
	   VEmerge_element_visibilities( element, doing_hiding, self_hiding );
	   }

	} /* VEset_visibilities_mult_proj */
