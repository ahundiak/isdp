
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

#include "gr.h"
#include "godef.h"
#include "go.h"

#include "bs.h"
#include "bserr.h"
#include "bsparameters.h"

#include "ve.h"
#include "vedef.h"
#include "veerr.h"
#include "ve_timing.h"

/* prototype files */
#include "VEpr_hiding.h"
#include "VEpr_utilfnc.h"
#include "VEpr_utilimp.h"

#include "bscvkttol2.h"
#include "bscvnormal.h"
#include "bscveval.h"
#include "bsfreecv.h"
#include "bsdta_rducv.h"
#include "bsxtractpar.h"
#include "bssfnormal.h"
#include "bststcvfln.h"

/* prototypes for static functions */
#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

static struct VEelement_header *VEsort_surfaces_in_solid __((
				struct VEelement_header *elem_list ));

static void VEreduce_curve __((	struct VEedge_header *edge ));

static void VEcleanup_linear_edge __(( 
				struct VEedge_header *edge ));

static void VEfree_temp_lists __(( 
				struct VEelement_header *element ));

static void VEinit_edges_for_self_hiding __((
				struct VEelement_header *element ));
	
static void VEinsert_overlapped_region __((
				IGRdouble               l_parm, 
				IGRdouble               r_parm,
				IGRdouble               knot_tol,
				struct VEedge_header    *edge ));

static void VEprocess_self_overlaps __((
				struct VEedge_header    *edge,
				IGRdouble               knot_tol,
				IGRdouble               z_tolerance,
				IGRint                  nover,
				IGRdouble               *c_over,
				IGRdouble               *d_over,
				IGRdouble               *e_over,
				IGRdouble               *f_over ));

static void VEprocess_self_intersections __(( 
				struct VEedge_header    *edge,
				IGRdouble               knot_tol,
				IGRint                  nint,
				IGRdouble               *a_par,
				IGRdouble               *b_par ));

static IGRboolean VEshould_self_intersection_be_done __(( 
				struct VEedge_header    *edge ));

static void VEsplit_edges_with_self_overlaps __(( 
				struct VEelement_header *element ));

static void VEself_intersect_edges __(( 
				struct VEelement_header *element,
				IGRboolean              doing_hiding ));

static void VEremove_self_hidden_pieces __((
				struct VEelement_header *element ));

static void VEassign_unique_ids_to_edges __(( 
				struct VEelement_header *element ));

static void VEprocess_edges_against_each_other __(( 
				struct VEelement_header *element,
				IGRboolean              doing_hiding,
				IGRboolean              all_ints_miss ));

#if defined(__cplusplus)
}
#endif

#undef __


#if TIMING
extern IGRdouble  VEtime_cvred;
extern IGRint     VEcount_cvred;
extern struct tms VEs_time;
extern struct tms VEe_time;
#endif

#define SEVENTY_DEGREES 1.2217     /* RADIANS */

#define SIBLINGS_FROM_SAME_SELF_OVERLAP_SPLIT( e0, e1 )                            \
	                                                                           \
	( (e0->edge_id == e1->edge_id) && (e0->num_sh_spans == e1->num_sh_spans) ) \

/* External Global Variables */
extern struct VEtolerance_info   VEtolerances;
extern struct VEexecution_parms  VEexec_parms;
extern struct VEexecution_status VEexec_status;
extern struct VEresults_info     VEoutput_data;


/*--- VEsort_surfaces_in_solid ----------------------------------------*/

static struct VEelement_header *VEsort_surfaces_in_solid( elem_list )

	struct VEelement_header *elem_list;

/*
NAME
	VEsort_surfaces_in_solid (static)

DESCRIPTION
	This function takes a list of surfaces and orders them so that
	the ones that have a better chance of hiding something are at
	the front of the list.  It returns a pointer to the head of the
	re-ordered list.  Currently, it puts the surfaces that don't have
	boundaries at the front of the list.

PARAMETERS
	elem_list (IN) - solid element list

GLOBALS USED
	none

HISTORY
	08/20/90    S.P. Rogers
	   Creation Date
*/

	{
	struct VEelement_header *next_elem;
	struct VEelement_header *bounded_head, *bounded_tail;
	struct VEelement_header *non_bounded_head, *non_bounded_tail;

	bounded_head = bounded_tail = NULL;
	non_bounded_head = non_bounded_tail = NULL;

	while ( elem_list )
	   {
	   next_elem = elem_list->next_in_solid;
	   elem_list->next_in_solid = NULL;
	   if ( elem_list->flags & HAS_BOUNDARIES )
	      {
	      if ( bounded_tail == NULL )
	         {
	         bounded_head = bounded_tail = elem_list;
	         }
	      else
	         {
	         bounded_tail->next_in_solid = elem_list;
	         bounded_tail = elem_list;
	         }
	      }
	   else
	      {
	      if ( non_bounded_tail == NULL )
	         {
	         non_bounded_head = non_bounded_tail = elem_list;
	         }
	      else
	         {
	         non_bounded_tail->next_in_solid = elem_list;
	         non_bounded_tail = elem_list;
	         }
	      }

	   elem_list = next_elem;
	   }  /* end: while ( elem_list ) */

	if ( non_bounded_head )
	   {
	   non_bounded_tail->next_in_solid = bounded_head;
	   return( non_bounded_head );
	   }
	else
	   return( bounded_head );

	}  /* VEsort_surfaces_in_solid */


/*--- VEreduce_curve ----------------------------------------------*/

static void VEreduce_curve( edge )

	struct VEedge_header *edge;

/*
NAME
	VEreduce_curve

DESCRIPTION
	This function reduces boundaries and standalone curves to the
	current CHT, if data reduction is enabled and the curve has
	more poles than the curve reduction pole threshold.
	
PARAMETERS
	edge (IN) - the edge to reduce

GLOBALS USED
	VEexec_parms

HISTORY
	08/07/89    S.P. Rogers
	   Creation Date
*/

	{
	IGRlong rc;
	IGRdouble           maxerr, avgerr, par, apar, pt[3], apt[3];
	struct IGRbsp_curve *cv, *appcurve;
	
	cv = edge->gm_curve3d->bspcv;
	if ( (VEexec_parms.VEdata_reduction) &&
	     ( (edge->type == BOUNDARY) || (edge->type == STANDALONE) ) && 
	     (cv->num_poles > VEexec_parms.VEcurve_threshold) )
	   {
#if TIMING
	   times( &VEs_time );
#endif

	   BSdta_rducv( cv, 0, 0, NULL, NULL, FALSE,
	                &maxerr, &avgerr, &par, pt, &apar, apt, &appcurve, &rc );

#if TIMING
	   times( &VEe_time );

	   VEcount_cvred++;
	   VEtime_cvred += ( ( (VEe_time.tms_utime + VEe_time.tms_stime) -
	                       (VEs_time.tms_utime + VEs_time.tms_stime) ) / 60.0 );
#endif
 
	   if ( rc == BSSUCC )
	      {
	      /* reduction succeeded => change curve to a general bspline */
	      edge->gm_curve3d->geom_prop = FALSE;
	      edge->gm_curve3d->bscv_flag = TRUE;
	      edge->gm_curve3d->type = BSGEN_BSP_CV;
	      edge->gm_curve3d->bspcv = appcurve;
	      BSfreecv( &rc, cv );
	      VEfree_geom_curve( edge->gm_curve2d );
	      }
	   else
	      {
	      BS_ERRCHK( rc, "VEreduce_curve: BSdta_rducv failed" );
	      }

	   }

	}  /* VEreduce_curve */


/*--- VEcleanup_linear_edge ---------------------------------------*/

static void VEcleanup_linear_edge( edge )

	struct VEedge_header *edge;
	
/*
NAME
	VEcleanup_linear_edge (static)

DESCRIPTION
	This function cleans up linear edges by replacing any order 2
	curve that is a straight line in XYZ space with an order 2 curve
	that has only 2 poles.  NOTE: It is assumed that the curve that
	is given as input is an order 2 curve.

PARAMETERS
	edge (IN) - the edge to try and clean-up

GLOBALS USED
	none

HISTORY
	xx/xx/xx    S.P. Rogers
	   Creation Date
*/

	{
	IGRlong                  rc;
	IGRboolean               is_line;
	IGRdouble                point1[3], point2[3];
	struct IGRbsp_curve      *curve;
	struct IGRbsp_curve      *new_curve;
	struct BSgeom_bsp_curve  *new_gmcurve;
	
	if ( ! edge->gm_curve3d )
	   return;

	curve = edge->gm_curve3d->bspcv;

	/* see if this order 2 curve can be replaced by two points */
	BStstcvfln( curve, &is_line, point1, point2, &rc );

	if ( (rc == BSSUCC) && (is_line) )
	   {
	   /* allocate and construct order 2, 2 pole curve */
	   new_gmcurve = VEalloc_geom_curve( 2, 2, FALSE, 0 );
	   new_gmcurve->type = BSLINE;
	         
	   /* free the current curve and assign new one to edge header */
	   VEfree_geom_curve( edge->gm_curve3d );
	   edge->gm_curve3d = new_gmcurve;

	   new_curve = new_gmcurve->bspcv;

	   new_curve->order       = 2;
	   new_curve->num_poles   = 2;
	   new_curve->num_knots   = 4;
	   new_curve->periodic    = FALSE;
	   new_curve->non_uniform = FALSE;
	   new_curve->planar      = TRUE;
	   new_curve->phy_closed  = FALSE;

	   /* assign poles and knots */
	   memcpy( (IGRchar *)new_curve->poles, (IGRchar *)point1, sizeof( IGRdouble ) * 3 );
	   memcpy( (IGRchar *)&new_curve->poles[3], (IGRchar *)point2, sizeof( IGRdouble ) * 3 );

	   new_curve->knots[0] = new_curve->knots[1] = 0.0;
	   new_curve->knots[2] = new_curve->knots[3] = 1.0;

	   /* change the visib_list to reflect the */
	   /* parameterization of the new curve    */
	   edge->visib_list->u = 0.0;
	   edge->visib_list->next->u = 1.0;
	         
	   }  /* end: if ( curve is linear ) */

	}  /* VEcleanup_linear_edge */


/*--- VEinit_temp_list ------------------------------------------------------*/

void VEinit_temp_list( edge )

	struct VEedge_header *edge;

/*
NAME
	VEinit_temp_list

DESCRIPTION
	This function initializes the temp list for an edge with
	endpoint nodes that match the parameterization of the curve.

PARAMETERS
	edge (IN) - the edge that is to have its temp-list
	            initialized

GLOBALS USED
	none

HISTORY
	xx/xx/xx    S.P. Rogers
	   Creation Date
*/

	{
	struct IGRbsp_curve *cv;

	cv = edge->gm_curve3d->bspcv;

	if ( (! (edge->status & TOTALLY_OVERLAPPED) ) &&
	     (! (edge->status & WAS_A_DUMMY) ) &&
	     ( cv ) )
	   {
	   /* Initialize temp-list with endpoint nodes. */
	   edge->temp_list = VEalloc_temp_node( cv->knots[cv->order - 1] );
	   edge->temp_list->next = VEalloc_temp_node( cv->knots[cv->num_knots - cv->order] );
	   }

	}  /* VEinit_temp_list */


/*--- VEfree_temp_lists ------------------------------------------------------*/

static void VEfree_temp_lists( element )

	struct VEelement_header *element;

/*
NAME
	VEfree_temp_lists (static)

DESCRIPTION
	This function frees the temp lists for all the edges of an
	element.

PARAMETERS
	element (IN) - the element whose edges are to have their temp
	               lists freed

GLOBALS USED
	none

HISTORY
	02/07/91    S.P. Rogers
	   Creation Date (extracted from VEself_hide)
*/

	{
	struct VEedge_header *this_edge;

	this_edge = element->edges;
	while ( this_edge )
	   {
	   if ( this_edge->temp_list )
	      {
	      VEfree_temp_node_list( this_edge->temp_list );
	      this_edge->temp_list = NULL;
	      }
	   this_edge = this_edge->next;
	   }

	}  /* VEfree_temp_lists */


/*--- VEinit_edges_for_self_hiding ---------------------------------------*/

static void VEinit_edges_for_self_hiding( element )

	struct VEelement_header *element;
	
/*
NAME
	VEinit_edges_for_self_hiding (static)

DESCRIPTION
	This function initializes edges for self-hiding by assigning
	a sub-edge id to their 'num_sh_spans' field, reducing their
	geometry if possible, replacing order 2 curves that approximate
	a line with a 2 pole linestring, setting the XY collinear bit
	and initializing the temp list.

PARAMETERS
	element (IN) - the element that is to have its edges
	               initialized for self-hiding

GLOBALS USED
	none

HISTORY
	xx/xx/xx    S.P. Rogers
	   Creation Date
*/

	{
	IGRint               subedge_id;
	struct VEedge_header *this_edge;
	struct IGRbsp_curve  *cv;

	subedge_id = 0;
	this_edge = element->edges;
	
	while ( this_edge )
	   {
	   /* assign self-hiding subedge_id to edge */
	   this_edge->num_sh_spans = subedge_id++;
	      
	   if ( this_edge->gm_curve3d )
	      {
	      VEreduce_curve( this_edge );

	      if ( (this_edge->gm_curve3d->bspcv->order == 2) && (this_edge->gm_curve3d->bspcv->num_poles > 2) )
	         VEcleanup_linear_edge( this_edge );

	      /* assigned here because VEcleanup_linear_edge() could have allocated a new curve */
	      cv = this_edge->gm_curve3d->bspcv;

	      /* set the collinear status of the edge */
	      if ( VExy_collinear( cv->num_poles, (IGRpoint *)cv->poles, cv->weights ) )
	         this_edge->status |= COLLINEAR_EDGE;

	      VEinit_temp_list( this_edge );
	      }  /* end: if ( this_edge->gm_curve3d ) */

	   this_edge = this_edge->next;
	   }  /* end: while */
	   
	}  /* VEinit_edges_for_self_hiding */


/*--- VEinsert_overlapped_region ------------------------------------*/

static void VEinsert_overlapped_region( l_parm, r_parm, knot_tol, edge )

	IGRdouble            l_parm, r_parm;
	IGRdouble            knot_tol;
	struct VEedge_header *edge;
  
/*
NAME
	VEinsert_overlapped_region (static)

DESCRIPTION
	This function inserts an overlapped region from 'l_parm' to 'r_parm'
	into the temp list of 'edge'.

PARAMETERS
	l_parm (IN) - start parameter of overlap region
	r_parm (IN) - end parameter of overlap region
	knot_tol (IN) - the knot tolerance to use
	edge (IN) - the edge that is to receive the overlapped region

GLOBALS USED
	none

HISTORY
	xx/xx/xx    S.P. Rogers
	   Creation Date
*/

	{
	IGRdouble          temp;
	struct VEtemp_node *prev_ovlap, *next_ovlap;

	prev_ovlap = NULL;
	next_ovlap = edge->temp_list;

	if ( l_parm > r_parm )
	   {
	   temp = l_parm;
	   l_parm = r_parm;
	   r_parm = temp;
	   }

	VEinsert_overlap_temp_node( l_parm,
	                            UNKNOWN,
	                            OVERLAPPED,
	                            knot_tol,
	                            &prev_ovlap,
	                            &next_ovlap );

	VEinsert_overlap_temp_node( r_parm,
	                            OVERLAPPED,
	                            UNKNOWN,
	                            knot_tol,
	                            &prev_ovlap,
	                            &next_ovlap );
  
	/* cleanup any nested overlap regions */
	VEremove_nested_overlaps( edge );
  
	} /* VEinsert_overlapped_region */


/*--- VEprocess_self_overlaps ------------------------------------------------------*/

static void VEprocess_self_overlaps( edge, knot_tol, z_tolerance,
	                             nover, c_over, d_over, e_over, f_over )

	struct VEedge_header *edge;
	IGRdouble            knot_tol;
	IGRdouble            z_tolerance;
	IGRint               nover;
	IGRdouble            *c_over;
	IGRdouble            *d_over;
	IGRdouble            *e_over;
	IGRdouble            *f_over;

/*
NAME
	VEprocess_self_overlaps (static)

DESCRIPTION
	Process the self-overlaps of an edge by adding an overlap region to the
	edge for the overlap that is farthest from the eye.

PARAMETERS
	edge (IN) - the edge whose self-overlaps are to be processed
	knot_tol (IN) - the knot tolerance to use
	z_tolerance (IN) - the Z tolerance to use
	nover (IN) - the number of self-overlaps
	c_over (IN) - first array of overlap start parameters
	d_over (IN) - first array of overlap end parameters
	e_over (IN) - second array of overlap start parameters
	f_over (IN) - second array of overlap end parameters

GLOBALS USED
	none

HISTORY
	xx/xx/xx    S.P. Rogers
	   Creation Date
*/

	{
	IGRlong             rc;
	IGRint              i;
	IGRdouble           u_ovlap_midpt;
	IGRdouble           c_over_eval[3];
	IGRdouble           e_over_eval[3];
	IGRdouble           f_over_eval[3];
	IGRdouble           tst_over_eval[3];
	struct IGRbsp_curve *curve;
	
	
	edge->status |= HAS_SELF_OVERS;
	   
	curve = edge->gm_curve3d->bspcv;
	
	for ( i = 0; i < nover; i++ )
	   {
	   /* Evaluate the curve at the first endpoint of each overlap region to */
	   /* see which is higher in z. The region that is higher in z is the    */
	   /* overlapped region. If the first endpoints are at the same z, which */
	   /* may be the case if the curve immediately turns back on itself,     */
	   /* then evaluate one of the regions at its parametric midpoint to see */
	   /* which is higher in z.                                              */

	   if ( (fabs(c_over[i] - d_over[i]) < knot_tol) ||
	        (fabs(e_over[i] - f_over[i]) < knot_tol) )
	      continue;  /* degenerate overlap span */

	   BScveval( curve, c_over[i], 0, (IGRpoint *)c_over_eval, &rc );
                       
	   BScveval( curve, e_over[i], 0, (IGRpoint *)e_over_eval, &rc );

	   if ( (fabs(c_over_eval[0] - e_over_eval[0]) < z_tolerance) &&
	        (fabs(c_over_eval[1] - e_over_eval[1]) < z_tolerance) )
	      {
	      if (c_over_eval[2] - e_over_eval[2] > z_tolerance)
	         VEinsert_overlapped_region( c_over[i], d_over[i], knot_tol, edge );
	      else if (e_over_eval[2] - c_over_eval[2] > z_tolerance)
	         VEinsert_overlapped_region( e_over[i], f_over[i], knot_tol, edge );
	      else
	         {
	         u_ovlap_midpt = (c_over[i] + d_over[i]) * 0.5;
             
	         BScveval( curve, u_ovlap_midpt, 0, (IGRpoint *)tst_over_eval, &rc );
                            
	         if (tst_over_eval[2] > e_over_eval[2])
	            VEinsert_overlapped_region( c_over[i], d_over[i], knot_tol, edge );
	         else
	            VEinsert_overlapped_region( e_over[i], f_over[i], knot_tol, edge );
	         } /* end: else */
             
	      } /* end: if (fabs(c_over_eval[1,2] - e_over_eval[1,2]) < z_tolerance) */
            
	   else
	      {
	      BScveval( curve, f_over[i], 0, (IGRpoint *)f_over_eval, &rc );
                           
	      if (c_over_eval[2] - f_over_eval[2] > z_tolerance)
	         VEinsert_overlapped_region( c_over[i], d_over[i], knot_tol, edge );
	      else if (f_over_eval[2] - c_over_eval[2] > z_tolerance)
	         VEinsert_overlapped_region( e_over[i], f_over[i], knot_tol, edge );
	      else
	         {
	         u_ovlap_midpt = (c_over[i] + d_over[i]) * 0.5;
               
	         BScveval( curve, u_ovlap_midpt, 0, (IGRpoint *)tst_over_eval, &rc );
                            
	         if (tst_over_eval[2] > f_over_eval[2])
	            VEinsert_overlapped_region( c_over[i], d_over[i], knot_tol, edge );
	         else
	            VEinsert_overlapped_region( e_over[i], f_over[i], knot_tol, edge );

	         } /* end: else */

	      } /* end: else */ 

	   } /* end: for (i = 0; i < nover; i++) */

	}  /* VEprocess_self_overlaps */


/*--- VEprocess_self_intersections ------------------------------------------------------*/

static void VEprocess_self_intersections( edge, knot_tol, nint, a_par, b_par )

	struct VEedge_header *edge;
	IGRdouble            knot_tol;
	IGRint               nint;
	IGRdouble            *a_par;
	IGRdouble            *b_par;
	
/*
NAME
	VEprocess_self_intersections (static)

DESCRIPTION
	Process the self-intersections of an edge by adding adding temp_nodes
	to the edge at the intersection points that are farthest from the eye.

PARAMETERS
	edge (IN) - the edge whose self-intersections are to be processed
	knot_tol (IN) - the knot tolerance to use
	nint (IN) - the number of intersections
	a_par (IN) - fisrt array of intersection parameters
	b_par (IN) - second array of intersectio parameters

GLOBALS USED
	none

HISTORY
	xx/xx/xx    S.P. Rogers
	   Creation Date
*/

	{
	IGRlong              rc;
	IGRint               i;
	IGRdouble            a_par_eval[3];
	IGRdouble            b_par_eval[3];
	struct IGRbsp_curve *curve;
	
	/* Process the self-intersections */
	curve = edge->gm_curve3d->bspcv;
	for (i = 0; i < nint; i++)
	   {
	   /* Evaluate the curve at the two points representing the inter- */
	   /* section. The one which is higher in z is on the part of the  */
	   /* curve that is hidden.                                        */

	   BScveval( curve, a_par[i], 0, (IGRpoint *)a_par_eval, &rc );

	   BScveval( curve, b_par[i], 0, (IGRpoint *)b_par_eval, &rc );

	   if (a_par_eval[2] > b_par_eval[2])
	      VEinsert_temp_node( a_par[i], edge, knot_tol );
	   else
	      VEinsert_temp_node( b_par[i], edge, knot_tol );
	   } /* end: for (i = 0; i < nint; i++) */

	}  /* VEprocess_self_intersections */
	

/*--- VEshould_self_intersection_be_done --------------------------------------*/

static IGRboolean VEshould_self_intersection_be_done( edge )

	struct VEedge_header *edge;

/*
NAME
	VEshould_self_intersection_be_done (static)

DESCRIPTION
	This function returns TRUE if an edge should be self-intersected.  An
	edge should not be self-intersected if it is a point, it has less than
	3 poles, it is planar and not edge on, or it is a boundary and didn't
	contribute to the trimming of a parting line (i.e., it doesn't cross a
	parting	line on the surface)

PARAMETERS
	edge (IN) - the edge to test

RETURN VALUES
	TRUE - if edge should be self-intersected
	FALSE - if edge shouldn't be self-intersected

GLOBALS USED
	none

HISTORY
	10/01/90     S.P. Rogers
	   Creation Date (extracted from VEself_intersect_edges)
*/

	{
	IGRlong              rc;
	IGRdouble            angle;
	IGRdouble            normal[3];
	struct IGRbsp_curve  *this_curve;

	this_curve = edge->gm_curve3d->bspcv;

	if ( edge->type == SINGLE_POINT )
	   {
	   /* don't self-intersect points */
	   return( FALSE );
	   }
	if ( this_curve->num_poles < 3 )
	   {
	   /* we don't need to self-intersect 2 pole curves */
	   return( FALSE );
	   }
	else if ( this_curve->planar )
	   {
	   /* If we are not viewing this planar curve from edge on, we   */
	   /* don't have to self-intersect it.  Currently, we say we are */
	   /* viewing the curve edge on if its normal is within twenty   */
	   /* degrees of being perpindicular to the line of sight.       */
	   BScvnormal( &rc, this_curve, normal );

	   if ( rc == BSSUCC )
	      {
	      /* calculate the angle between the curve normal */
	      /* and the line of sight vector (i.e., (0,0,1)) */
	      normal[2] = fabs( normal[2] );
	      if ( normal[2] > 1.0 )
	         {
	         /* sometimes the value is slightly greater than 1.0 */
	         /* due to inaccuracies in the normal calculation => */
	         /* clamp the value to 1.0                           */
	         normal[2] = 1.0;
	         }
	      angle = acos( normal[2] );
	      if ( angle <= SEVENTY_DEGREES ) 
	         return( FALSE );
	      }
	         
	   }  /* end: else if ( this_curve->planar ) */
	
	else if ( (edge->type == BOUNDARY) &&
                  ((edge->status & TRIMMED_A_PARTING_LINE) != TRIMMED_A_PARTING_LINE) )
	   return( FALSE );

	return( TRUE );
	}  /* VEshould_self_intersection_be_done */


/*--- VEsplit_edges_with_self_overlaps ------------------------------------------------*/

static void VEsplit_edges_with_self_overlaps( element )

	struct VEelement_header *element;

/*
NAME
	VEsplit_edges_with_self_overlaps (static)

DESCRIPTION
	This function takes an element whose edges have already been
	self-intersected and splits all edges with overlapped regions into
	edges that have no overlapped regions.

PARAMETERS
	element (IN) - the element whose edges are to be split

GLOBALS USED
	none

HISTORY
	10/18/90   S.P. Rogers
	   Creation Date (extracted from VEself_intersect_edges)
*/

	{
	struct VEedge_header    *this_edge, *next_edge, *temp_edge;
	struct VEedge_header    *new_head, *new_tail;
	struct VEedge_header    *split_head, *split_tail;
	struct VEedge_header    *saved_dummy_ptr;
	struct VEelement_header *saved_elem_ptr;
	IGRint                  subedge_id;

	next_edge = element->edges;
	new_head = new_tail = NULL;
	while ( next_edge )
	   {
	   this_edge = next_edge;
	   next_edge = this_edge->next;
	   this_edge->next = NULL;
	   
	   if ( this_edge->status & HAS_SELF_OVERS )
	      {
	      VEcreate_overlapped_soos_for_edge( element, this_edge );

	      /* save self-hiding subedge_id for 'this_edge' because 'this_edge' */
	      /* is freed by VEsplit_out_temp_list_overlaps()                    */
	      subedge_id = this_edge->num_sh_spans;
	      saved_dummy_ptr = this_edge->shared_edge;
	      saved_elem_ptr  = this_edge->shared_elem;
	      VEsplit_out_temp_list_overlaps( this_edge, &split_head, &split_tail );

	      if ( (element->flags & ELEM_FROM_SOLID) && (saved_dummy_ptr) )
	         VEcreate_dummies_for_split_pieces( element, split_head, saved_dummy_ptr, saved_elem_ptr );

	      /* Make all of the split pieces have the same subedge_id as the  */
	      /* parent edge (stored in the num_sh_spans field). This id will  */
	      /* be used during the edge/edge comparison portion of self-      */
	      /* hiding to make sure we don't compare these edges against each */
	      /* other because all of their intersections and overlaps should  */
	      /* have been found when the edge they were split from was        */
	      /* self-intersected.                                             */
	      temp_edge = split_head;
	      while ( temp_edge )
	         {
	         temp_edge->num_sh_spans = subedge_id;
	         temp_edge = temp_edge->next;
	         }

	      VEadd_edges_to_list( split_head, &new_head, &new_tail );
	      }
	   else
	      {
	      VEadd_edges_to_list( this_edge, &new_head, &new_tail );
	      }
	   }  /* end: while */
	      
	element->edges = new_head;
	}  /* VEsplit_edges_with_self_overlaps */


/*--- VEself_intersect_edges ------------------------------------------------------*/
                                          
static void VEself_intersect_edges( 	struct VEelement_header *element,
					IGRboolean              doing_hiding )
	
/*
NAME
	VEself_intersect_edges (static)

DESCRIPTION
	Perfrom the processing required to self-intersect all of the edges
	of an element.
	
	   1) Add nodes to the edge's temp_lists to denote self-overlaps and
	      self-intersections.
	      
	   2) Split any edge with OVERLAPPED spans into multiple edges
	      with no OVERLAPPED spans.

PARAMETERS
	element (IN) - the element whose edges are to be self-intersected
	doing_hiding (IN) - TRUE, if hiding is being performed

GLOBALS USED
	none

HISTORY
	xx/xx/xx    S.P. Rogers
	   Creation Date
*/

	{
	IGRlong              rc;
	IGRboolean           change_made;
	IGRboolean           some_self_overs;
	IGRint               nint;
	IGRint               nover;
	IGRdouble            knot_tol;
	IGRdouble            edge_based_dist_tol;
	IGRdouble            *a_par, *b_par;
	IGRdouble            *c_over, *d_over, *e_over, *f_over;
	struct VEedge_header *this_edge;
	struct IGRbsp_curve  *this_curve;
	

	/* Process edge self-overlapping and self-hiding. */

	some_self_overs = FALSE;
	this_edge = element->edges;
	while ( this_edge )
	   {
	   if ( (this_edge->gm_curve3d) && (this_edge->status & EDGE_CLASSIFICATION) == VISIBLE_PROFILE )
	      {
	      /* determine if we need to do the self intersection of this curve */
	      if ( VEshould_self_intersection_be_done( this_edge ) )
	         {
	         this_curve = this_edge->gm_curve3d->bspcv;

	         /* determine the knot tolerance for the curve */
	         BScvkttol2( this_curve->order, this_curve->knots, this_curve->num_poles,
	                     this_curve->poles, this_curve->weights, &knot_tol, &rc );

	         if ( this_edge->status & COLLINEAR_EDGE )
	            {
	            /* edge is collinear in XY space => process it */
	            /* with the special waterfall algorithm        */
	            VEfind_self_overlaps_for_collinear_edge( this_edge,
	                                                     &change_made, element->range,
	                                                     knot_tol );
	            if ( change_made )
	               {
	               this_edge->status |= HAS_SELF_OVERS;
	               some_self_overs = TRUE;
	               }
	            }
	         else
	            {
	            /* add knots at points where the curve doubles back on itself */
	            /* in XY space to help out BScv_slfint().                     */
	            VEadd_knots_at_transition_points( this_curve, knot_tol );

	            /* Call VEcv_slfint to see where the curve self-overlaps */
	            /* and self-intersects itself in 2D.                     */
	            VEcv_slfint( (IGRint *)&rc,
	                         this_edge,
	                         this_curve,
	                         element->env->to_world_scale,
	                         &nint, &a_par, &b_par,
	                         &nover, &c_over, &d_over, &e_over, &f_over,
	                         &edge_based_dist_tol );

	               BS_ERRCHK(rc, "VEself_intersect_edges: BScv_slfint failed");

	            if ( nover )
	               {
	               some_self_overs = TRUE;
	               VEprocess_self_overlaps( this_edge, knot_tol, edge_based_dist_tol,
	                                        nover, c_over, d_over, e_over, f_over );
	               }

	            if ( (doing_hiding) &&
	                 (this_edge->type & EDGE_CAN_SELF_HIDE) && 
	                 (nint) )
	               {
	               VEprocess_self_intersections( this_edge, knot_tol,
	                                             nint, a_par, b_par );
	               }

	            if (a_par != NULL)
	               {
	               free ((IGRchar *) a_par);
	               free ((IGRchar *) b_par);
	               }

	            if (c_over != NULL)
	               {
	               free ((IGRchar *) c_over);
	               free ((IGRchar *) d_over);
	               free ((IGRchar *) e_over);
	               free ((IGRchar *) f_over);
	               }

	            }  /* end: else */

	         } /* end: if this_edge is not a point or self-intersection required */

	      }  /* end: if ( this_edge is not a dummy shared edge */

	   this_edge = this_edge->next;
	   } /* end: while  */

	if ( some_self_overs )
	   {
	   /* There is at least one edge with self-overlaps => Loop */
	   /* over all edges and split out their overlap regions    */
	   VEsplit_edges_with_self_overlaps( element );
	   }  /* end: if ( some_self_overs ) */
	
	}  /* VEself_intersect_edges */
	

/*--- VEremove_self_hidden_pieces -------------------------------------------*/

static void VEremove_self_hidden_pieces( element )

	struct VEelement_header *element;

/*
NAME
	VEremove_self_hidden_pieces (static)

DESCRIPTION
	This function removes the self hidden pieces from the edges of a solid
	after the solid has been self hidden.  All spans on the visiblity
	lists of the edges that are not VISIBLE are output and the edge is
	split into a list of edges containing only VISIBLE spans.  Removing
	geometry from the edges that is self hidden should speed up subsequent
	curve/curve intersections with the edges.

PARAMETERS
	element (IN) - the solid whose self-hidden pieces are to be
	               removed

GLOBALS USED
	VEoutput_data
	VEexec_status

HISTORY
	09/07/90    S.P. Rogers
	   Creation Date
*/

	{
	struct VEedge_header    *this_edge, *temp_edge, *next_edge;
	struct VEedge_header    *visib_head, *visib_tail, *hidden_head, *hidden_tail;
	struct VEedge_header    *saved_dummy_ptr;
	struct VEedge_header    *new_list_head, *new_list_tail;
	struct VEelement_header *saved_elem_ptr;
	struct IGRdisplay       orig_attr;

	while ( element )
	   {
	   VEget_element_base_attr( element->objid, element->env->osnum, &element->env->ref_symb, &orig_attr );

	   this_edge = element->edges;	
	   new_list_head = new_list_tail = NULL;
	   while ( this_edge )
	      {
	      if ( (this_edge->gm_curve3d) &&
	           ( (this_edge->visib_list->visib != VISIBLE) || (this_edge->visib_list->next->next) ) )
	         {
	         /* 'this_edge' has some non-visible spans on it */
	         saved_dummy_ptr = this_edge->shared_edge;
	         saved_elem_ptr  = this_edge->shared_elem;
	         next_edge = this_edge->next;
	         VEsplit_out_hidden_pieces( this_edge, &visib_head, &visib_tail, &hidden_head, &hidden_tail );

	         /* output all non VISIBLE spans */
	         while ( hidden_head )
	            {
	            if ( VEoutput_data.output_solid_self_hidden_edges )
	               VEcreate_curves_for_edge( element, hidden_head, &orig_attr );
	            temp_edge = hidden_head->next;
	            VEfree_visib_node_list( hidden_head->visib_list );
	            VEfree_edge_header( hidden_head );
	            hidden_head = temp_edge;
	            }

	         /* construct new dummies for the split visible pieces, if needed */
	         if ( saved_dummy_ptr )
	            VEcreate_dummies_for_split_pieces( element, visib_head, saved_dummy_ptr, saved_elem_ptr );

	         if ( visib_head )
	            {
	            /* assign saved cvcv id's to visible pieces */
	            temp_edge = visib_head;
	            while ( temp_edge )
	               {
	               temp_edge->saved_cvcv_id = VEexec_status.VEnext_saved_cvcv_id++;
	               temp_edge = temp_edge->next;
	               }

	            if ( new_list_head == NULL )
	               new_list_head = visib_head;
	            else
	               new_list_tail->next = visib_head;
	            new_list_tail = visib_tail;

	            }  /* end: if ( visib_head ) */

	         this_edge = next_edge;
	         }  /* end: if ( this_edge->gm_curve3d ) */
	      else
	         {
	         if ( new_list_head == NULL )
	            new_list_head = this_edge;
	         else
	            new_list_tail->next = this_edge;
	         new_list_tail = this_edge;

	         this_edge = this_edge->next;
	         }

	      }  /* end: while ( this_edge ) */

	   if ( new_list_tail )
	      new_list_tail->next = NULL;
	   element->edges = new_list_head;

	   element = element->next_in_solid;
	   }  /* end: while ( element ) */

	}  /* VEremove_self_hidden_pieces */


/*--- VEassign_unique_ids_to_edges -----------------------------------------------*/

static void VEassign_unique_ids_to_edges( element )

	struct VEelement_header *element;

/*
NAME
	VEassign_unique_ids_to_edges (static)


DESCRIPTION
	This function assigns each edge of the element a unique id to 
	be used for saving curve/curve intersection data.

PARAMETERS
	element (IN) - the element whose edges are to be assigned
	               unique ids

GLOBALS USED
	VEexec_status

HISTORY
	02/07/91    S.P. Rogers
	   Creation Date (extracted from VEself_hide)
*/

	{
	struct VEedge_header *this_edge;

	this_edge = element->edges;
	while ( this_edge )
	   {
	   this_edge->saved_cvcv_id = VEexec_status.VEnext_saved_cvcv_id++;
	   this_edge = this_edge->next;
	   }
	            
	}  /* VEassign_unique_ids_to_edges */


/*--- VEprocess_edges_against_each_other --------------------------------------------*/

static void VEprocess_edges_against_each_other(
				struct VEelement_header *element,
				IGRboolean              doing_hiding,
				IGRboolean              all_ints_miss )

/*
NAME
	VEprocess_edges_against_each_other (static)

DESCRIPTION
	This function intersects all of the edges of an element against each
	other.

PARAMETERS
	element (IN) - the element whose edges are to be processed
	doing_hiding (IN) - TRUE, if hiding is being performed
	all_ints_miss (IN) - TRUE, if calling routine knows that none of
	                     the edges intersect and is just making this
	                     call so the saved intersection algorithm
	                     works properly

GLOBALS USED
	none

HISTORY
	02/07/91    S.P. Rogers
	   Creation Date (extracted from VEself_hide)
*/

	{
	BSrc                 rc;
	IGRboolean           this_edge_is_dummy = FALSE,
	                     pass_edge_is_dummy = FALSE;
	IGRdouble            mod_cht;
	struct VEedge_header *this_edge, *real_this_edge;
	struct VEedge_header *pass_edge, *real_pass_edge;


	BSxtractpar( &rc, BSTOLCHRDHT, &mod_cht );
	mod_cht *= 2.0;

	/* Process each edge against the remaining edges in the surface. */
	this_edge = element->edges;
	while ( this_edge->next )
	   {
	   if ( ! DUMMY_EDGE_FROM_SOLID( element, this_edge ) )
	      {
	      if (this_edge->gm_curve3d == NULL)
	         {
	         this_edge->gm_curve3d = this_edge->shared_edge->gm_curve3d;
	         this_edge->gm_curve2d = this_edge->shared_edge->gm_curve2d;
	         this_edge_is_dummy = TRUE;
	         real_this_edge = this_edge->shared_edge;
	         }
	      else
	         real_this_edge = this_edge;

	      pass_edge = this_edge->next;
	      while ( pass_edge )
	         {
	         if ( ! DUMMY_EDGE_FROM_SOLID( element, pass_edge ) )
	            {
	            if (pass_edge->gm_curve3d == NULL)
	               {
	               pass_edge->gm_curve3d = pass_edge->shared_edge->gm_curve3d;
	               pass_edge->gm_curve2d = pass_edge->shared_edge->gm_curve2d;
	               pass_edge_is_dummy = TRUE;
	               real_pass_edge = pass_edge->shared_edge;
	               }
	            else
	               real_pass_edge = pass_edge;

	            if ( (! SIBLINGS_FROM_SAME_SELF_OVERLAP_SPLIT( real_this_edge, real_pass_edge )) &&
	                 (! SIBLINGS_FROM_PLANAR_PARENT( real_this_edge, real_pass_edge ) ) )
	               {
	               /* These two edges are not siblings from the same parent    */
	               /* edge that was split up due to self-overlaps.  And they   */
	               /* aren't edges that were split from the same planar parent */
	               /* during classify, trimming, clipping, etc. Compare them   */
	               /* if their range boxes overlap.                            */
	               if ( !( (this_edge->range[XMIN] > pass_edge->range[XMAX] + mod_cht) ||
	                       (this_edge->range[XMAX] < pass_edge->range[XMIN] - mod_cht) ||
	                       (this_edge->range[YMIN] > pass_edge->range[YMAX] + mod_cht) ||
	                       (this_edge->range[YMAX] < pass_edge->range[YMIN] - mod_cht) ) )
	                  {
	                  if ( (this_edge->range[ZMIN] < (pass_edge->range[ZMIN] - mod_cht)) &&
	                       (this_edge->range[ZMAX] < (pass_edge->range[ZMIN] - mod_cht)) )
	                     {
	                     /* this_edge is totally in front */
	                     if ( (this_edge->status & EDGE_CLASSIFICATION) == VISIBLE_PROFILE )
	                        VEcompare_edges_sh( this_edge, pass_edge,
	                                            element, doing_hiding, all_ints_miss );
	                     }
	                  else if ( (pass_edge->range[ZMIN] < (this_edge->range[ZMIN] - mod_cht)) &&
	                            (pass_edge->range[ZMAX] < (this_edge->range[ZMIN] - mod_cht)) )
	                     {
	                     /* pass_edge is totally in front */
	                     if ( (pass_edge->status & EDGE_CLASSIFICATION) == VISIBLE_PROFILE )
	                        VEcompare_edges_sh( this_edge, pass_edge,
	                                            element, doing_hiding, all_ints_miss );
	                     }
	                  else
	                     {
	                     /* this_edge and pass_edge overlap in Z */
	                     if ( ((this_edge->status & EDGE_CLASSIFICATION) == VISIBLE_PROFILE) ||
	                          ((pass_edge->status & EDGE_CLASSIFICATION) == VISIBLE_PROFILE) )
	                        VEcompare_edges_sh( this_edge, pass_edge,
	                                           element, doing_hiding, all_ints_miss );
	                     }

	                  } /* end: if this_edge and pass_edge are in the same range */

	               }  /* end: edges haven't already been compared */

	            if (pass_edge_is_dummy)
	               {
	               pass_edge->gm_curve3d = NULL;
	               pass_edge->gm_curve2d = NULL;
	               pass_edge_is_dummy = FALSE;
	               }

	            } /* end: if ( ! DUMMY_EDGE_FROM_SOLID ... ) */

	         pass_edge = pass_edge->next;
	         } /* while (pass_edge != NULL) */

	      if (this_edge_is_dummy)
	         {
		 this_edge->gm_curve3d = NULL;
		 this_edge->gm_curve2d = NULL;
	         this_edge_is_dummy = FALSE;
	         }

	      }  /* end: if ( ! DUMMY_EDGE_FROM_SOLID ... ) */

	   /* Reset the num_sh_spans field because the self-hiding */
	   /* sub-edge id is no longer needed.                     */
	   this_edge->num_sh_spans = 0;
	         
	   this_edge = this_edge->next;
	   } /* end: while (this_edge->next != NULL) */

	/* Reset the num_sh_spans field of the last edge in the edge list */
	/* because it doesn't get reset in the previous while loop.       */
	this_edge->num_sh_spans = 0;

	}  /* VEprocess_edges_against_each_other */


/*--- VEself_hide ----------------------------------------------*/

void VEself_hide( struct VEelement_header *element,
		  IGRboolean              doing_hiding )

/*
NAME
	VEself_hide

DESCRIPTION
	This function determines the visiblity and overlaps of the edges
	of an element with respect to the element.

PARAMETERS
	element (IN) - the element to self hide
	doing_hiding (IN) - TRUE, if hiding is being performed

GLOBALS USED
	VEexec_status

HISTORY
	xx/xx/xx    S.P. Rogers
	   Creation Date
*/

	{
	BSrc                    rc;
	IGRdouble               normal[3];
	IGRboolean              all_ints_miss;
	IGRdouble               angle;
	struct VEelement_header *this_element, *first_element;
	struct VEelement_header *dom_elem, *pass_elem;


	if ( element->type == SOLID_HEADER )
	   first_element = element->next_in_solid;  /* skip header of a solid */
	else
	   first_element = element;

        if( !first_element ) return;  /*don't allow test to examine members if pointer null*/

	if ( first_element->type == POINT )
	   {
	   /* don't self-hide points => but assign saved */
	   /* curve/curve id to the edge                 */
	   VEassign_unique_ids_to_edges( first_element );
	   return;
	   }

	/* process each surface/curve in the element against itself */
	this_element = first_element;
	while ( this_element )
	   {
	   VEupdate_heartbeat();
	   if ( IGEstop() )
	      {
	      VEexec_status.VEabort = TRUE;
	      break;
	      }

	   if ( this_element->edges )
	      {
	      VEinit_edges_for_self_hiding( this_element );

	      all_ints_miss = FALSE;
	      if ( (this_element->type == SURFACE) && (this_element->geom.gmsurf->bspsf->planar) )
	         {
	         /* If the normal to this planar surface is within 70 degrees      */
	         /* of the line of sight vector, we know that all curve-self       */
	         /* and curve/curve intersections will result in 0 intersections   */
	         /* and 0 overlaps.  We must still call VEcompare_edges_sh() for   */
	         /* all pairs of edges whose range boxes overlap so that the       */
	         /* curve/curve intersection saving algorithm will work correctly. */
	         /* We will call VEcompare_edges_sh() with a flag saying that we   */
	         /* know that the intersection will yield 0 intersections and 0    */
	         /* overlaps.  It will pass this flag to VEcvcv_int() and it will  */
	         /* be used to avoid calling BScvcvint().                          */
	         BSsfnormal( this_element->geom.gmsurf->bspsf, normal, &rc );

	            BS_ERRCHK( rc, "VEself_hide: BSsfnormal failed");

	         if ( rc == BSSUCC )
	            {
	            normal[2] = fabs( normal[2] );
	            if ( normal[2] > 1.0 )
	               {
	               /* sometimes the value is slightly greater than 1.0 */
	               /* due to inaccuracies in the normal calculation => */
	               /* clamp the value to 1.0                           */
	               normal[2] = 1.0;
	               }
	            angle = acos( normal[2] );
	            all_ints_miss = (angle <= SEVENTY_DEGREES);
	            }
	         }
	         
	      if ( ! all_ints_miss )
	         VEself_intersect_edges( this_element, doing_hiding );

	      if ( this_element->edges )
	         {
	         /* The element still has edges after self-intersection.  This  */
	         /* should always be TRUE, but could be FALSE due to unforeseen */
	         /* circumstances.  This check will keep a memory fault from    */
	         /* occuring if the element does lose all of its edges.         */

	         VEassign_unique_ids_to_edges( this_element );

	         if ( this_element->type != SURFACE )
	            {
	            /* standalone curves don't need any more processing */
	            VEfree_temp_lists( this_element );
	            return;
	            }
      
	         VEprocess_edges_against_each_other( this_element, doing_hiding, all_ints_miss );
	         }  /* end: if ( this_element->edges ) */

	      }  /* end: if ( this_element->edges ) */

	   this_element = this_element->next_in_solid;
	   }  /* end: while ( this_element ) */

	/* order surfaces in solid for optimum (we think) performance */
	if ( element->type == SOLID_HEADER )
	   {
	   element->next_in_solid = first_element = VEsort_surfaces_in_solid( first_element );
	   }

	if ( ! VEexec_status.VEabort )
	   {
	   /* compare a surface to all the other ones in this element */
	   dom_elem = first_element;
	   while ( dom_elem->next_in_solid )
	      {
	      pass_elem = dom_elem->next_in_solid;
	      while ( pass_elem )
	         {
	         VEcomp_surfs( dom_elem, pass_elem, doing_hiding, TRUE );
	         pass_elem = pass_elem->next_in_solid;
	         if ( VEexec_status.VEabort )
	            break;
	         }
	      dom_elem = dom_elem->next_in_solid;
	      if ( VEexec_status.VEabort )
	         break;
	      }

	   if ( ! VEexec_status.VEabort )
	      {
	      /* Determine the visibility of the edges */
	      VEset_visibilities_mult_proj( first_element, first_element,
	                                    (element->type != SOLID_HEADER), doing_hiding );
	
	      if ( (! VEexec_status.VEabort) && (element->type == SOLID_HEADER) && (! VEexec_parms.VEtracing) )
	         VEremove_self_hidden_pieces( first_element );
	      }
	   }

	} /* VEself_hide */
