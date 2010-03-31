
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:42:00 $
$Locker:  $
*/

#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <alloca.h>

#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "igrdp.h"

#include "dpstruct.h"

#include "bserr.h"
#include "bsparameters.h"

#include "ve_timing.h"
#include "vedef.h"
#include "ve.h"
#include "veerr.h"

#include "go.h"

/* prototype files */
#include "VEpr_hiding.h"
#include "VEpr_utilfnc.h"
#include "VEpr_utilimp.h"

#include "bscvcvint.h"
#include "bscv_slfint.h"
#include "bsgmcvcvint.h"
#include "bscveval.h"
#include "bschrdlkts.h"
#include "bschtptstcv.h"
#include "bschangepar.h"
#include "bsichgpar.h"
#include "bsmdstptscv.h"
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

static IGRdouble VEdetermine_dist_tol __((
			 	struct VEedge_header     *edge0,
				struct VEedge_header     *edge1,
				struct BSgeom_bsp_curve  *cv0,
				struct BSgeom_bsp_curve  *cv1,
				IGRdouble                to_world_scale0,
				IGRdouble                to_world_scale1 ));

static void VEconstruct_stroked_curve __(( struct VEedge_header *edge ));

static IGRdouble VEmap_from_stroked_curve __(( 
				IGRdouble                parm,
				struct BSgeom_bsp_curve  *stroked_curve,
				struct BSgeom_bsp_curve  *curve ));

static void VEintersect_curves_with_stroking __(( 
				struct VEelement_header *elem0,
				struct VEedge_header    *ed0,
				struct BSgeom_bsp_curve *gm_cv0,
				IGRdouble               to_world_scale0,
				struct VEelement_header *elem1,
				struct VEedge_header    *ed1,
				struct BSgeom_bsp_curve *gm_cv1,
				IGRdouble               to_world_scale1,
				IGRboolean              rbox_int,
				IGRboolean		*free_ints,
				IGRboolean		*free_overs,
				IGRint                  *n_int,
				IGRpoint                **int_pts,
				IGRdouble               **par0,
				IGRdouble               **par1,
				IGRint                  *n_over,
				IGRpoint                **end_pts,
				IGRdouble               **over0, 
				IGRdouble		**over1,
				IGRint                  *rc,
				IGRdouble               *edge_based_dist_tol ));

static IGRboolean VEcurve_endpoint_inside_range_box __(( 
				struct IGRbsp_curve     *curve,
				IGRdouble               *range ));

static struct BSgeom_bsp_curve *VEbuild_rangebox_curve __((
				IGRdouble               *range ));

static void VEsave_z __((
				IGRlong	                num_poles,
				IGRdouble               *poles, 
				IGRdouble               *z_list ));

static void VErestore_z __((
				IGRlong	                num_poles,
				IGRdouble               *poles,
				IGRdouble               *z_list ));
#if defined(__cplusplus)
}
#endif

#undef __

#define CHECK_RETURN_CODES	1

#define	DEBUG_RESULTS		0
#define	DEBUG_ERRORS_CVCV	0
#define	DEBUG_ERRORS_CVSLF	0
#define	DEBUG_ERRORS_CVCV3D	0

#define NUM_STATIC_INTS		50
#define NUM_STATIC_OVERS	25

#define NUM_STATIC_INTS_3D	50
#define NUM_STATIC_OVERS_3D	25

#define PARALLEL_TOL            0.99

#define LOTSA_POLES             20

/* External Variables */
extern struct VEexecution_parms VEexec_parms;
extern struct VEtolerance_info  VEtolerances;
extern IGRboolean               VEstroke_all_ints;
extern IGRdouble                VEstroke_cht;

#if TIMING
extern IGRdouble  VEtime_cvcv;
extern IGRdouble  VEtime_cvslf;
extern IGRint     VEcount_cvcv;
extern IGRint     VEcount_cvslf;
extern struct tms VEs_time;
extern struct tms VEe_time;
#endif

/* static space to hold an order 2, 5 pole curve representing a range box */
static IGRdouble rcurve_poles[15] = { 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
	                              0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0 };
static IGRdouble rcurve_knots[7]  = { 0.0, 0.0, 0.25, 0.50, 0.75, 1.0, 1.0 };

static struct IGRbsp_curve rcurve = { 2,                /* order                 */
	                              FALSE, FALSE,     /* periodic, non-uniform */
	                              5, rcurve_poles,  /* num_poles, poles      */
	                              7, rcurve_knots,  /* num_knots, knots      */
	                              FALSE, NULL,      /* rational, weights     */
	                              TRUE, TRUE,       /* planar, phy_closed    */
	                              0, NULL };        /* num_boundaries, bdrys */

static struct BSgeom_bsp_curve gm_rcurve = { FALSE, FALSE, 0,     /* geom_prop, bscv_flag, type */
                                             {0.0, 0.0, 0.0},     /* pt1 */
                                             {0.0, 0.0, 0.0},     /* pt2 */
                                             {0.0, 0.0, 0.0},     /* pt3 */
                                             {0.0, 0.0, 0.0},     /* pt4 */
                                             {0.0, 0.0, 0.0},     /* pt5 */
                                             {0.0, 0.0, 0.0},     /* vec1 */
                                             {0.0, 0.0, 0.0},     /* vec2 */
                                             {0.0, 0.0, 0.0},     /* vec3 */
                                             {0.0, 0.0, 0.0},     /* vec4 */
                                             {0.0, 0.0, 0.0},     /* vec5 */
                                             0.0, 0.0, 0.0, 0.0,  /* len1, len2. len3, len4 */
                                             0,                   /* int1 */
                                             NULL, NULL };        /* array1, bspcv */


/* Static space for BScvcvint ... should prevent the routine from */
/* allocating any space for most intersection cases.              */
static IGRdouble cv0_param[NUM_STATIC_INTS];
static IGRdouble cv1_param[NUM_STATIC_INTS];
static IGRpoint  int_points[NUM_STATIC_INTS];

static IGRdouble cv0_over[2 * NUM_STATIC_OVERS];
static IGRdouble cv1_over[2 * NUM_STATIC_OVERS];
static IGRpoint  overlaps[2 * NUM_STATIC_OVERS];

/* Static space for VEcvcv_int_3d */
static IGRdouble cv0_param_3d[NUM_STATIC_INTS_3D];
static IGRdouble cv1_param_3d[NUM_STATIC_INTS_3D];
static IGRpoint  int_points_3d[NUM_STATIC_INTS_3D];

static IGRdouble cv0_over_3d[2 * NUM_STATIC_OVERS_3D];
static IGRdouble cv1_over_3d[2 * NUM_STATIC_OVERS_3D];
static IGRpoint  overlaps_3d[2 * NUM_STATIC_OVERS_3D];


#if TIMING

#define START_TIMING                                                              \
                                                                                  \
   	 times( &VEs_time );                                                      \

#define STOP_TIMING                                                               \
	                                                                          \
	times( &VEe_time );                                                       \
                                                                                  \
	VEcount_cvcv++;                                                           \
	VEtime_cvcv += ( ( (VEe_time.tms_utime + VEe_time.tms_stime) -            \
	                   (VEs_time.tms_utime + VEs_time.tms_stime) ) / 60.0 );  \

#else

#define START_TIMING

#define STOP_TIMING

#endif


/*-- VEsave_z --------------------------------------------------------------------*/

static void VEsave_z( num_poles, poles, z_list )

	IGRlong	  num_poles;
	IGRdouble *poles, *z_list;

/*
NAME
	VEsave_z (static)

DESCRIPTION
	Copies the z's of the poles to another array, then zeroes out the
	existing z's so that the intersections will be 2D.

PARAMETERS
	num_poles (IN) - the number of poles to save
	poles (IN) - array of poles to save
	z_list OUT) - array in which the Z poles are saved

GLOBALS USED
	none

NOTES
	The z_list array must be passed in by the caller

HISTORY
	05/06/87    S.A. Rapa
	   Creation Date
*/


	{
	IGRint	cnt;

	poles += 2;
	for (cnt = 0; cnt < num_poles; cnt++)
	   {
	   *z_list++ = *poles;
	   *poles = 0.0;
	   poles += 3;
	   }

	} /* VEsave_z */


/*-- VErestore_z -----------------------------------------------------------------*/

static void VErestore_z( num_poles, poles, z_list )

	IGRlong	  num_poles;
	IGRdouble *poles, *z_list;

/*
NAME
	VErestore_z (static)

DESCRIPTION
	Copies a list of values back into the z coordinates of the poles.

PARAMETERS
	num_poles (IN) - the number of poles to restore
	poles (IN/OUT) - array of poles where restoration is to take place
	z_list (IN) - array of Z poles to restore

GLOBALS USED
	none

HISTORY
	05/06/87    S.A. Rapa
	   Creation Date
*/

	{
	IGRint cnt;

	poles += 2;
	for (cnt = 0; cnt < num_poles; cnt++)
	   {
	   *poles = *z_list++;
	   poles += 3;
	   }

	}  /* VErestore_z */


/*--- VEdetermine_dist_tol -----------------------------------*/

static IGRdouble VEdetermine_dist_tol( edge0, edge1, gm_cv0, gm_cv1, to_world_scale0, to_world_scale1 )

	struct VEedge_header     *edge0;
	struct VEedge_header     *edge1;
	struct BSgeom_bsp_curve  *gm_cv0;
	struct BSgeom_bsp_curve  *gm_cv1;
	IGRdouble                to_world_scale0;
	IGRdouble                to_world_scale1;
	
/*
NAME
	VEdetermine_dist_tol (static)

DESCRIPTION
	This function determines the 'dist_tol' that should be used
	when intersecting two edges.

PARAMETERS
	edge0 (IN) - one of the edges being intersected
	edge1 (IN) - the other edge being intersection
	cv0 (IN) - the curve associated with 'edge0'
	cv1 (IN) - the curve associated with 'edge1'
	to_world_scale0 (IN) - the "to-world" scaling factor for 'cv0'
	to_world_scale1 (IN) - the "to-world" scaling factor for 'cv1'

ALGORITHM
	If (both edges are order 2, stroked curves) then
	   dist_tol = (scaled_cht * to_world_scale0) +
	              (scaled_cht * to_world_scale1)
	Else if ( edge0 is an order 2, stroked curve) then
	   dist_tol = scaled_cht * to_world_scale0
	Else if ( edge1 is an order 2, stroked curve) then
	   dist_tol = scaled_cht * to_world_scale1
	Else
	   dist_tol = 0.1 * scaled_cht

	dist_tol = dist_tol * 1.1  (make dist_tol a little larger just in case)

GLOBALS USED
	VEtolerances

HISTORY
	xx/xx/xx    S.P. Rogers
	   Creation Date
*/

	{
	IGRdouble dist_tol;
	
	if ((edge0->type == HORIZON_EDGE) || (edge0->type == HORIZON_CURVE) ||
	   ((edge0->type == BOUNDARY) && (edge0->gm_curve3d->bspcv->order == 2)) ||
	   (edge0->stroked_gmcurve == gm_cv0) )
	   {
	   if ((edge1->type == HORIZON_EDGE) || (edge1->type == HORIZON_CURVE) ||
	      ((edge1->type == BOUNDARY) && (edge1->gm_curve3d->bspcv->order == 2)) ||
	      (edge1->stroked_gmcurve == gm_cv1) )
	      dist_tol = (VEtolerances.VEscaled_cht * to_world_scale0) +
	                 (VEtolerances.VEscaled_cht * to_world_scale1);
	   else
	      dist_tol = VEtolerances.VEscaled_cht * to_world_scale0;
	   }

	else if ((edge1->type == HORIZON_EDGE) || (edge1->type == HORIZON_CURVE) ||
	        ((edge1->type == BOUNDARY) && (edge1->gm_curve3d->bspcv->order == 2)) ||
	        (edge1->stroked_gmcurve == gm_cv1) )
	      dist_tol = VEtolerances.VEscaled_cht * to_world_scale1;
	else
 	   dist_tol = VEtolerances.VEscaled_cht * 0.1;
      
	dist_tol *= 1.1;
	
	return( dist_tol );
	
	}  /* VEdetermine_dist_tol */

	                      
/*--- VEconstruct_stroked_curve ------------------------------------*/

static void VEconstruct_stroked_curve( struct VEedge_header *edge )

/*
NAME
	VEconstruct_stroked_curve (static)

DESCRIPTION
	This function takes an edge whose curve has an order greater
	than two and creates a stroked representation for it.

PARAMETERS
	edge (IN) - the edge whose stroked curve is to be constructed

RETURN VALUES
	none

GLOBALS USED
	none

HISTORY
	xx/xx/91    Joel Underwood
	   Creation Date
*/

	{
	IGRlong                 rc;
	IGRint                  num = 0;
	IGRdouble               default_cht;
	IGRdouble               *pts;
	IGRdouble               *pars;
	struct BSgeom_bsp_curve *gmcv;
	struct IGRbsp_curve     *cv;

	if ( edge->stroked_gmcurve )
	   return;

	if ( VEstroke_cht != 0.0 )
	   {
	   BSxtractpar( &rc, BSTOLCHRDHT, &default_cht );
	   BSchangepar( &rc, BSTOLCHRDHT, VEstroke_cht );
	   }

	BSchtptstcv( edge->gm_curve3d->bspcv, &num, (IGRpoint **)&pts, &pars, &rc );

	if ( VEstroke_cht != 0.0 )
	   {
	   BSchangepar( &rc, BSTOLCHRDHT, default_cht );
	   }

	if ( rc != BSSUCC )
	   return;

	free((IGRchar *) pars);

	/* construct 3D stroked curve */
	gmcv = VEalloc_geom_curve( 0, 0, 0, 0 );
	if ( ! gmcv )
	   {
	   free((IGRchar *) pts);
	   return;
	   }

	gmcv->geom_prop = FALSE;
	gmcv->bscv_flag = TRUE;
	gmcv->type = BSGEN_BSP_CV;

	gmcv->bspcv = cv = (struct IGRbsp_curve *) malloc( sizeof( struct IGRbsp_curve ) );
	if ( ! cv )
	   {
	   VEfree_geom_curve( gmcv );
	   free((IGRchar *) pts);
	   return;
	   }

	cv->knots = (IGRdouble *) malloc( (num + 2) * sizeof( IGRdouble ) );
	if ( ! cv->knots )
	   {
	   free( (IGRchar *) cv );
	   gmcv->bspcv = NULL;
	   VEfree_geom_curve( gmcv );
	   free((IGRchar *) pts);
	   return;
	   }

	cv->order = 2;
	cv->periodic = FALSE;
	cv->non_uniform = TRUE;
	cv->poles = pts;
	cv->num_poles = num;
	cv->num_knots = num + 2;
	cv->rational = FALSE;
	cv->weights  = NULL;
	cv->planar = FALSE;  /* FALSE, because of possible problems when projecting to 2D */
	cv->phy_closed = edge->gm_curve3d->bspcv->phy_closed;
	cv->num_boundaries = 0;
	cv->bdrys = NULL;
	      
	/* space knots with respect to arc length between poles */
	BSchrdlkts( &rc,
	            &cv->num_poles,
	            cv->poles,
	            &cv->order,
	            &cv->periodic,
	            cv->knots );

	   BS_ERRCHK( rc, "VEconstruct_stroked_curve: BSchrdlkts failed" );

	edge->stroked_gmcurve = gmcv;

	}  /* VEconstruct_stroked_curve */


/*--- VEmap_from_stroked_curve ------------------------------------*/

static IGRdouble VEmap_from_stroked_curve( parm, stroked_gmcurve, gmcurve )
 
	IGRdouble               parm;
	struct BSgeom_bsp_curve *stroked_gmcurve;
	struct BSgeom_bsp_curve *gmcurve;

/*
NAME
	VEmap_from_stroked_curve

DESCRIPTION
	This function takes a parameter on a stroked_curve that was
	stroked from a curve whose order is greater than two and
	maps the parameter from the stroked_curve to the other
	curve.

PARAMETERS
	parm (IN) - parameter on stroked curve
	stroked_curve (IN) - stroked curve
	curve (IN) - curve to map parameter to

RETURN VALUES
	The mapped parameter is returned.

GLOBALS USED
	none

HISTORY
	xx/xx/91    Joel Underwood
	   Creation Date
*/

	{
	IGRlong     rc;
	IGRpoint    base,point;
	IGRdouble   dist;
	IGRboolean  all_on_curve;

	/* if intersection is at the endpoint and is closed it would be
	   ambiguous to convert so must hardcode these cases to return
	   either the beginning value if u==0 or end value if u==1.0 */
	if ( parm == 0.0 )
	   return( gmcurve->bspcv->knots[gmcurve->bspcv->order-1] );
	else if ( parm==1.0 ) 
	   return( gmcurve->bspcv->knots[gmcurve->bspcv->num_knots - gmcurve->bspcv->order] );
	else
	   {  
	   /* stroked u to x,y,z */
	   BScveval( stroked_gmcurve->bspcv, parm, 0, (IGRpoint *)point, &rc );

	      BS_ERRCHK( rc, "VEmap_from_stroked_curve: BSmdstptscv failed" );

	   /* x,y,z to original curve u */
	   BSmdstptscv( 1, (IGRpoint *)point, gmcurve->bspcv, &parm, (IGRpoint *)base, 
				&dist, &all_on_curve, &rc );

	      BS_ERRCHK( rc, "VEmap_from_stroked_curve: BSmdstptscv failed" );

	   return( parm );
	   }      

	}  /* VEmap_from_stroked_curve */



/*--- VEok_to_stroke --------------------------------------------------*/

static IGRboolean VEok_to_stroke( gm_cv0, gm_cv1 )

	struct BSgeom_bsp_curve *gm_cv0;
	struct BSgeom_bsp_curve *gm_cv1;

/*
NAME
	VEok_to_stroke (static)

DESCRIPTION
	This function determines if it is ok to stroke two
	curves before intersecting them.  The determination
	is based on whether the curve/curve intersection
	is supported analytically and whether the accuracy
	might be a problem (e.g., order 3 vs. order 3).

PARAMETERS
	gm_cv0 (IN) - one curve
	gm_cv1 (IN) - the other curve

GLOBALS USED
	VEstroke_all_ints

RETURN VALUES
	TRUE, if it is ok to stroke the curves
	FALSE, if it is not

HISTORTY
	11/05/92    S.P. Rogers
	   Creation Date
*/

	{

	if ( (VEstroke_all_ints) ||
	     ( ((gm_cv0->bspcv->order > 2 ) && (gm_cv1->bspcv->order == 2)) ||
	       ((gm_cv0->bspcv->order == 2 ) && (gm_cv1->bspcv->order > 2)) ) )
	   {
	   /* don't stroke if the curve types are supported by the */
	   /* geometric curve/curve intersection routine           */
	   if ( (((gm_cv0->type == BSCIRCLE) || (gm_cv0->type == BSCIRC_ARC)) &&
	         ((gm_cv1->type == BSLINE) || (gm_cv1->type == BSINF_LINE))) ||

	        (((gm_cv1->type == BSCIRCLE) || (gm_cv1->type == BSCIRC_ARC)) &&
	         ((gm_cv0->type == BSLINE) || (gm_cv0->type == BSINF_LINE))) ||

	        (((gm_cv1->type == BSCIRCLE) || (gm_cv1->type == BSCIRC_ARC)) &&
	         ((gm_cv0->type == BSCIRCLE) || (gm_cv0->type == BSCIRC_ARC))) )
	      {
	      return( FALSE );
	      }
	   else
              {
              return( TRUE );
	      }

	   }
	else
	   {
	   return( FALSE );
	   }

	}  /* VEok_to_stroke */


/*--- VEintersect_curves_with_stroking --------------------------------------------------------*/

static void VEintersect_curves_with_stroking( 
				struct VEelement_header *elem0,
				struct VEedge_header    *ed0,
				struct BSgeom_bsp_curve *gm_cv0,
				IGRdouble               to_world_scale0,
				struct VEelement_header *elem1,
				struct VEedge_header    *ed1,
				struct BSgeom_bsp_curve *gm_cv1,
				IGRdouble               to_world_scale1,
				IGRboolean              rbox_int,
				IGRboolean		*free_ints,
				IGRboolean		*free_overs,
				IGRint                  *n_int,
				IGRpoint                **int_pts,
				IGRdouble               **par0,
				IGRdouble               **par1,
				IGRint                  *n_over,
				IGRpoint                **end_pts,
				IGRdouble               **over0, 
				IGRdouble		**over1,
				IGRint                  *rc,
				IGRdouble               *edge_based_dist_tol )

/*
NAME
	VEintersect_curves_with_stroking (static)

DESCRIPTION
	This function takes two curves and intersects them.  It will stroke the
	curves to order 2, if the intersection will be more efficient

PARAMETERS
	elem0 (IN) - element header of edge0
	ed0 (IN) - edge header of curve0
	gm_cv0 (IN) - first curve to be intersected
	to_world_scale0 (IN) - to_world_scale of cv0
	elem1 (IN) - element header of edge1
	ed1 (IN) - edge header of curve1
	gm_cv1 (IN) - second curve to be intersected
	to_world_scale1 (IN) - to_world_scale of cv1
	rbox_int (IN) - TRUE, if doing a range box intersection
	free_ints (OUT) - TRUE, if intersection arrays should be
	                  freed by the caller
	free_overs (OUT) - TRUE, if overlap arrays should be freed
	                   by the caller
	n_int (OUT) - number of intersections
	int_pts (OUT) - XYZ values of intersections
	par0 (OUT) - parameters of intersections on cv0
	par1 (OUT) - parameters of intersections on cv1
	n_over (OUT) - number of overlap regions
	end_pts (OUT) - XYZ values of overlap endpoints
	over0 (OUT) - parameters of overlap endpoints on cv0
	over1 (OUT) - parameters of overlap endpoints on cv1
	rc (OUT) -  return code from math routine
	edge_based_dist_tol (OUT) - dist_tol used to intersect edges

GLOBALS USED
	int_points, cv0_param, cv1_param (static)
	overlaps, cv0_over, cv1_over (static)

HISTORY
	xx/xx/91    Joel Underwood
	   Creation Date
*/

{
	IGRboolean stroke;
	IGRlong    rc1;
	IGRint     i;
	IGRdouble  dist_tol;
	IGRdouble  default_dist_tol;
	IGRdouble  default_overlap_tol;
	IGRdouble  *saved_poles0, *saved_poles1;

	/* don't stroke if this is a range box intersection or if the edges are */
	/* on the same surface because of shared edge connections (i.e., a      */
	/* self-hiding situation.                                               */
	stroke = ! ( (rbox_int) || 
	             (elem0 == elem1) ||
	             (ed0->shared_elem == elem1) ||
                     (ed1->shared_elem == elem0) ||
	             ((ed0->shared_elem != NULL) && (ed0->shared_elem == ed1->shared_elem)) );

	if ( stroke ) 
	   { 
	   if ( VEok_to_stroke( gm_cv0, gm_cv1 ) )
	      {
	      if ( gm_cv0->bspcv->order > 2 )
	         {
	         VEconstruct_stroked_curve( ed0 );
	         if ( ed0->stroked_gmcurve )
	            {
	            gm_cv0 = ed0->stroked_gmcurve;

	            /* project stroked curve to Z=0 plane */
	            saved_poles0 = (IGRdouble *) alloca( gm_cv0->bspcv->num_poles * sizeof( IGRdouble ) );
	            VEsave_z( gm_cv0->bspcv->num_poles, gm_cv0->bspcv->poles, saved_poles0 );
	            }
	         }

	      if ( gm_cv1->bspcv->order > 2 )
	         {
	         VEconstruct_stroked_curve( ed1 );
	         if ( ed1->stroked_gmcurve )
	            {
	            gm_cv1 = ed1->stroked_gmcurve;

	            /* project stroked curve to Z=0 plane */
	            saved_poles1 = (IGRdouble *) alloca( gm_cv1->bspcv->num_poles * sizeof( IGRdouble ) );
	            VEsave_z( gm_cv1->bspcv->num_poles, gm_cv1->bspcv->poles, saved_poles1 );
	            }
	         }
	      }
	   }

	/* Set the tolerances required to perform intersection */
	BSxtractpar( &rc1, BSTOLLENVEC,  &default_dist_tol );
	BSxtractpar( &rc1, BSTOLOVERLAP, &default_overlap_tol );

	dist_tol = VEdetermine_dist_tol( ed0, ed1, gm_cv0, gm_cv1,
	                                 to_world_scale0, to_world_scale1 );

	*edge_based_dist_tol = dist_tol;

	BSchangepar( &rc1, BSTOLLENVEC, dist_tol );
	BSchangepar( &rc1, BSTOLSQLENVEC, dist_tol * dist_tol );
	BSchangepar( &rc1, BSTOLOVERLAP, VEtolerances.VEscaled_trace_tol );

	START_TIMING;

	BSgmcvcvint( gm_cv0, gm_cv1,
	             FALSE, 
	                 
	             /* Static memory */
	                                 
	             NUM_STATIC_INTS, NUM_STATIC_OVERS,
	             int_points, cv0_param, cv1_param, 
	             overlaps, cv0_over, cv1_over,   
	                                            
	             /* Memory allocated by routine */ 
	                                             
	             n_int, n_over,                    
	             free_ints, free_overs,            
	             int_pts, par0, par1,              
	             end_pts, over0, over1,            
	             (BSrc *)rc );

	STOP_TIMING;                               

	/* Reset the tolerances */
	BSchangepar( &rc1, BSTOLLENVEC, default_dist_tol );
	BSchangepar( &rc1, BSTOLSQLENVEC, default_dist_tol * default_dist_tol );
	BSchangepar( &rc1, BSTOLOVERLAP, default_overlap_tol );

	/* free_ints & free_overs flags of where the values of BScvcvint are returned */
	if ( ! *free_ints )
	   {
	   *int_pts = int_points;
	   *par0    = cv0_param;
	   *par1    = cv1_param;
	   }

	if ( ! *free_overs )
	   {
	   *end_pts = overlaps;
	   *over0   = cv0_over;
	   *over1   = cv1_over;
	   }

	if ( stroke )
	   {
	   /* stroked curve parameter values need to be mapped */
	   /* to original curve parameter values               */
	   if ( (gm_cv0 == ed0->stroked_gmcurve) || 
	        (gm_cv1 == ed1->stroked_gmcurve) )
	      {
	      if ( gm_cv0 == ed0->stroked_gmcurve )
	         {
	         VErestore_z( gm_cv0->bspcv->num_poles, gm_cv0->bspcv->poles, saved_poles0 );
	         for ( i = 0; i < *n_int; i++ )
	            (*par0)[i] = VEmap_from_stroked_curve( (*par0)[i], gm_cv0, ed0->gm_curve3d );
	         }

	      if ( gm_cv1 == ed1->stroked_gmcurve )
	         {
	         VErestore_z( gm_cv1->bspcv->num_poles, gm_cv1->bspcv->poles, saved_poles1 );
	         for ( i = 0; i < *n_int; i++ )
	            (*par1)[i] = VEmap_from_stroked_curve( (*par1)[i], gm_cv1, ed1->gm_curve3d );
	         }

	      if ( gm_cv0 == ed0->stroked_gmcurve )
	         {
	         for ( i = 0; i < (*n_over * 2); i++ )
	            (*over0)[i] = VEmap_from_stroked_curve( (*over0)[i], gm_cv0, ed0->gm_curve3d );
	         }

	      if ( gm_cv1 == ed1->stroked_gmcurve )
	         {
	         for ( i = 0; i < (*n_over * 2); i++ )
	            (*over1)[i] = VEmap_from_stroked_curve( (*over1)[i], gm_cv1, ed1->gm_curve3d );
	         }

	      }	                                           

	   }

	}  /* VEintersect_curves_with_stroking */


/*-- VEcurve_endpoint_inside_range_box --------------------------------------------------------------------*/

static IGRboolean VEcurve_endpoint_inside_range_box( 
				struct IGRbsp_curve *curve,
				IGRdouble           *range )
	
/*
NAME
	VEcurve_endpoint_inside_range_box (static)

DESCRIPTION
	This function determines if the endpoint of a curve is inside a range
	box.  It returns TRUE if it is and FALSE otherwise.
	
PARAMETERS
	curve (IN) - curve whose endpoint is to be tested
	range (IN) - range box to test against

RETURN VALUES
	TRUE - if curve endpoint is inside the range box
	FALSE - if curve endpoint is outside the range box

GLOBALS USED
	none

HISTORY
	10/24/88    S.P. Rogers
	   Creation Date
*/

	{
	IGRlong   rc;
	IGRdouble inside;
	IGRdouble eval_point[3];
	
	BScveval( curve, curve->knots[ curve->order - 1 ], 0, (IGRpoint *)eval_point, &rc );

	inside = (eval_point[0] > range[XMIN]) && (eval_point[0] < range[XMAX]) &&
	         (eval_point[1] > range[YMIN]) && (eval_point[1] < range[YMAX]);	

	return( inside );
	}  /* VEcurve_endpoint_inside_range_box */
	

/*-- VEbuild_rangebox_curve --------------------------------------------------------------------*/

static struct BSgeom_bsp_curve *VEbuild_rangebox_curve( range )

	IGRdouble *range;

/*
NAME
	VEbuild_rangebox_curve (static)

DESCRIPTION
	This function fills the XY poles of a static curve structure
	with the endpoints of a range box with the data required to build
	an order 2 B-Spline curve to represent a range box. It returns a pointer
	to the curve representing the range box.

PARAMETERS
	range (IN) - the range from which to be the curve

RETURN VALUES
	A pointer to the rangebox curve definition is returned.

NOTES
	The curve that is returned resides in static space and should not
	be freed by the calling function.  The curve is also only valid
	until the next call to this function.

GLOBALS USED
	rcurve (static)

HISTORY
	10/24/88    S.P. Rogers
	   Creation Date
*/

	{
	IGRpoint *pnts;
	
	pnts = (IGRpoint *) rcurve.poles;

	pnts[0][0] = range[XMIN];
	pnts[0][1] = range[YMIN];

	pnts[1][0] = range[XMIN];
	pnts[1][1] = range[YMAX];

	pnts[2][0] = range[XMAX];
	pnts[2][1] = range[YMAX];

	pnts[3][0] = range[XMAX];
	pnts[3][1] = range[YMIN];

	pnts[4][0] = range[XMIN];
	pnts[4][1] = range[YMIN];

	gm_rcurve.geom_prop = FALSE;
	gm_rcurve.bscv_flag = TRUE;
	gm_rcurve.type = BS3DLINESTR;
	gm_rcurve.bspcv = &rcurve;

        if ( gm_rcurve.array1 )
           {
           /* free previous use */
           free( gm_rcurve.array1 );
           }

        gm_rcurve.int1 = 0;
        gm_rcurve.array1 = NULL;

	return( &gm_rcurve );

        }  /* VEbuild_rangebox_curve */


/*--VEeliminate_erroneous_intersects_and_overlaps  -----------------------*/

static void VEeliminate_erroneous_intersects_and_overlaps( 
		 IGRint                  *n_int,
		 IGRint                  *n_over,
		 IGRdouble               **par0,
		 IGRdouble               **par1,
		 IGRdouble               **over0,
		 IGRdouble               **over1,
		 struct VEedge_header    *edge0,
		 struct VEedge_header    *edge1 )

/*
NAME
      VEeliminate_erroneous_intersects_and_overlaps

DESCRIPTION
      This function eliminates curve/curve intersections and overlaps
      that are outside of the parametric ranges of the curves being
      compared.  This function was put in to provide a safety net for
      the BSgmcvcvint() function which was returning the out of range
      parametric values in the par# and over# arrays.

PARAMETERS
      n_int  (OUT) - number of intersections
      n_over (OUT) - number of overlap regions
      par0   (OUT) - parameters of intersections on cv0
      par1   (OUT) - parameters of intersections on cv1
      over0  (OUT) - parameters of overlap endpoints on cv0
      over1  (OUT) - parameters of overlap endpoints on cv1
      edge0  (IN) - edge header of curve0
      edge1  (IN) - edge header of curve1

GLOBALS USED
       

HISTORY
       01/11/94    T.S. Fox Creation Date
       02/16/94    Modified memmove() function calls in both intersection and
                   overlap processing loops so that they are now passing the
                   addresses of the memory to move instead of the contents of
                   array elements.  I also now decrement the for loop counter
                   i value after the arrays are moved up. This is because once I move
                   memory up to overwrite the invalid intersection/overlap, I need
                   to reevaluate the just overwritten array element again.  The new
                   value in this spot is actually the next element after the
                   invalid element, which has not been evaluated yet.

*/

{
      IGRint               i;
      IGRint               remove_intersection;
      IGRint               remove_overlap;
      IGRint               low;
      IGRint               high;
      IGRint               par_size;
      IGRint               over_size;
      IGRint               block_size;
      IGRdouble            min0;
      IGRdouble            min1;
      IGRdouble            max0;
      IGRdouble            max1;
      struct IGRbsp_curve  *curve0;
      struct IGRbsp_curve  *curve1;


      par_size  = sizeof(double);
      over_size = 2 * par_size;

      curve0 = edge0->gm_curve3d->bspcv;
      curve1 = edge1->gm_curve3d->bspcv;

      /*find the maximum and minimum parametric knot values of the
        two curves being compared*/

      min0 = curve0->knots[curve0->order - 1];
      max0 = curve0->knots[curve0->num_knots - curve0->order];

      min1 = curve1->knots[curve1->order - 1];
      max1 = curve1->knots[curve1->num_knots - curve1->order];

      /* look over the intersection arrays to see if any of the parametric values
         returned from the BSgmcvcvint() function are less than the minimum knot
         value or greater than the maximum knot value of the corresponding curve.
         If so then delete the corresponding intersection in both of the par arrays */

      for (i=0; i < *n_int; i++)
        {
          remove_intersection = FALSE;

          if (((*par0)[i] < min0) || ((*par0)[i] > max0))
            remove_intersection = TRUE;

          if ((remove_intersection == FALSE) && (((*par1)[i] < min1) || ((*par1)[i] > max1)))
            remove_intersection = TRUE;

          if (remove_intersection == TRUE)
            {
              /* if the intersection to delete is not the last intersection in the par arrays
                 then we must move all intersections below the intersection to be deleted up
                 one spot in the arrays*/

              if (i <= (*n_int - 2))
                {
                  /*calculate how many intersections need to be moved up*/

                  block_size = par_size * (*n_int - (i + 1));

                  /*move up the intersections below the intersection to delete on top
                    of the deleted intersection.  This needs to be done in both arrays*/

                  memmove((*par0)+i, (*par0)+i+1, block_size);
                  memmove((*par1)+i, (*par1)+i+1, block_size);

                  (*n_int)--;   /*we say that now there is one less intersection*/
                  i--;   /*adjust for counter so that just ovewritten element is reevaluated.*/
                }
              else
                /* otherwise we are dealing with the only intersection in the list
                   so all we need to do is decrement the count of how many intersections
                   there are in the arrays*/

                (*n_int)--;
            }
        }

      /* look over the overlap arrays to see if any of the parametric values
         returned from the BSgmcvcvint() function are less than the minimum knot
         value or greater than the maximum knot value of the corresponding curve.
         If so then delete the corresponding overlap in both of the par arrays */

      for (i=0; i< *n_over; i++)
        {
          remove_overlap = FALSE;

          low  = i * 2;      /*since there is a low and high value in the each overlap*/
          high = low + 1;    /*calculate the element positions in the arrays for each overlap*/

          if ((((*over0)[low] < min0) || ((*over0)[high] < min0)) ||
              (((*over0)[low] > max0) || ((*over0)[high] > max0)))
            remove_overlap = TRUE;

          if ((remove_overlap == FALSE) &&
              ((((*over1)[low] < min1) || ((*over1)[high] < min1)) ||
               (((*over1)[low] > max1) || ((*over1)[high] > max1))))
            remove_overlap = TRUE;

          if (remove_overlap == TRUE)
            {
              /* if the overlap to delete is not the last overlap in the over arrays
                 then we must move all overlaps below the overlap to be deleted up
                 one spot in the arrays*/

              if (i <= (*n_over - 2))
                {
                  /*calculate how many overlaps need to be moved up*/

                  block_size = over_size * (*n_over - (i + 1));

                  /*move the overlaps below the overlap to delete onto the top
                   of the deleted overlap.  This needs to be done in both arrays*/

                  memmove((*over0)+low, (*over0)+high+1, block_size);
                  memmove((*over1)+low, (*over1)+high+1, block_size);

                  (*n_over)--;  /*we say that now there is one less overlap region*/
                  i--;    /*adjust for counter so that just ovewritten element is reevaluated.*/
                }
              else
                /* otherwise we are dealing with the only overlap in the list
                   so all we need to do is decrement the count of how many overlaps
                   there are in the arrays*/

                (*n_over)--;
            }
        }
}


/*-- VEcvcv_int ----------------------------------------------------------------*/

void VEcvcv_int( IGRint                  *rc,
		 struct VEelement_header *elem0, 
		 struct VEelement_header *elem1,
		 struct VEedge_header    *edge0,
		 struct VEedge_header    *edge1,
		 IGRint                  *n_int,
		 IGRpoint                **int_pts,
		 IGRdouble               **par0,
		 IGRdouble               **par1,
		 IGRint                  *n_over,
		 IGRpoint                **end_pts,
		 IGRdouble               **over0,
		 IGRdouble               **over1,
		 IGRboolean              *free_ints,
	         IGRboolean              *free_overs,
		 IGRboolean              intersection_misses,
		 IGRboolean              pseudo_int,
		 IGRdouble               *edge_based_dist_tol )

/*
NAME
	VEcvcv_int

DESCRIPTION
	Provides an interface to the math routine BScvcvint by making
	modifications needed for VE processing to the curves.  The change
	is forcing the poles to lie in the same Z plane.

PARAMETERS
	rc (OUT) -  return code from math routine
	elem0 (IN) - element header of edge0
	elem1 (IN) - element header of edge1
	edge0 (IN) - edge header of curve0
	edge1 (IN) - edge header of curve1
	n_int (OUT) - number of intersections
	int_pts (OUT) - XYZ values of intersections
	par0 (OUT) - parameters of intersections on cv0
	par1 (OUT) - parameters of intersections on cv1
	n_over (OUT) - number of overlap regions
	end_pts (OUT) - XYZ values of overlap endpoints
	over0 (OUT) - parameters of overlap endpoints on cv0
	over1 (OUT) - parameters of overlap endpoints on cv1
	free_ints (OUT) - TRUE, if intersection arrays should be
	                  freed by the caller
	free_overs (OUT) - TRUE, if overlap arrays should be freed
	                   by the caller
	intersection_misses (IN) - TRUE, if calling routine already
	                           knows that the intersection will
	                           0 ints and 0 overs.  The calling
	                           routine is only calling this routine
	                           so that the saved intersection alg.
	                           will work properly
	pseudo_int (IN) - TRUE, if the calling routine doesn't
		          care about the intersection between
		          the two curves and is only calling
		          this routine so the saved int. alg.
		          will work properly.  This flag is
	                  intended to be used with no trace
	                  Visible Edges.
	edge_based_dist_tol (OUT) - dist_tol used to intersect edges

GLOBALS USED
	VEexec_parms

HISTORY
	05/06/87    S.A. Rapa
	   Creation Date
*/

	{
	IGRlong                 my_rc;
	IGRboolean              disabled_overlaps = FALSE;
	IGRboolean              small_inside_big;
	IGRdouble               area_cv0;
	IGRdouble               area_cv1;
	IGRdouble               dx0, dy0, dx1, dy1;
	IGRdouble               *small_range;
	IGRdouble               *big_range;
	struct VEedge_header    *real_edge0;
	struct VEedge_header    *real_edge1;
	struct IGRbsp_curve     *curve0, *curve1;
	struct BSgeom_bsp_curve *big_gmcv, *small_gmcv, *rbox_gmcv;
	struct VEedge_header    *small_edge, *big_edge;
	struct VEelement_header *small_elem, *big_elem;

	/* use stored intersection information if it is available */
	if ( ( VEexec_parms.VEhiding ) &&
	     ( VEretrieve_intersection_info( edge0, edge1,
	                                     n_int, n_over, par0, par1, over0, over1 ) ) )
	   {
	   *rc = BSSUCC;
	   *free_ints = *free_overs = FALSE;
	   return;
	   }

	/* get the real edges associated with these two edges */
	if ( (edge0->shared_edge == NULL) || (edge0->status & REAL_SHARED_EDGE) )
	   real_edge0 = edge0;
	else
	   real_edge0 = edge0->shared_edge;

	if ( (edge1->shared_edge == NULL) || (edge1->status & REAL_SHARED_EDGE) )
	   real_edge1 = edge1;
	else
	   real_edge1 = edge1->shared_edge;

	if ( (intersection_misses) ||
	     (real_edge0->status & real_edge1->status & TOTALLY_OVERLAPPED) ||
	     ( (pseudo_int) && (real_edge0->status & real_edge1->status & TOTALLY_INVISIBLE) ) )
	   {
	   /* the calling routine knows the intersection misses OR both real edges   */
	   /* are totally overlapped and can't change OR the calling routine doesn't */
	   /* care about the intersection and both real edges are totally invisible  */
	   /* (no trace GVE) =>  don't do an intersection                            */
	   *n_int = *n_over = 0;
	   *rc = BSSUCC;
	   *free_ints = *free_overs = FALSE;
	   }
	else
	   {
           VEcreate_2d_curve( edge0 );
           VEcreate_2d_curve( edge1 );

	   curve0 = edge0->gm_curve2d->bspcv;
	   curve1 = edge1->gm_curve2d->bspcv;

	   if ( (!curve0) || (!curve1) )
	      {
	      *n_int = *n_over = 0;
	      *rc = BSFAIL;
	      *free_ints = *free_overs = FALSE;
	      return;
	      }

	   if ( (curve0->order == 2) && (curve1->order == 2) )
	      {
	      if ( (edge0->status & COLLINEAR_EDGE) && (edge1->status & COLLINEAR_EDGE) )
	         {
	         /* both edges are order 2 and collinear in xy space =>   */
	         /* disable overlap calculations if they are not parallel */
	         VEget_xyslope( curve0->num_poles, (IGRpoint *)curve0->poles, curve0->weights, &dx0, &dy0 );
	         VEget_xyslope( curve1->num_poles, (IGRpoint *)curve1->poles, curve1->weights, &dx1, &dy1 );

	         if ( (fabs(dx0 * dx1 + dy0 * dy1)) < PARALLEL_TOL )
	            {
	            disabled_overlaps = TRUE;
	            BSichgpar( BSCVORD2_OVERLAP, 0, &my_rc );
	            }
	         }

	      }  /* end:  if ( both curves are order 2 */
	      
	   area_cv0 = (edge0->range[XMAX] - edge0->range[XMIN]) *
	              (edge0->range[YMAX] - edge0->range[YMIN]);
	            
	   area_cv1 = (edge1->range[XMAX] - edge1->range[XMIN]) *
	              (edge1->range[YMAX] - edge1->range[YMIN]);
	            
	   /* set small curve to be the curve whose range box has the smallest area */
	   if ( area_cv0 < area_cv1 )
	      {
	      small_gmcv = edge0->gm_curve2d;
	      small_range = edge0->range;
	      small_edge = edge0;
	      small_elem = elem0;
	      big_gmcv = edge1->gm_curve2d;
	      big_range = edge1->range;
	      big_edge = edge1;
	      big_elem = elem1;
	      }
	   else
	      {
	      small_gmcv = edge1->gm_curve2d;
	      small_range = edge1->range;
	      small_edge = edge0;
	      small_elem = elem0;
	      big_gmcv = edge0->gm_curve2d;
	      big_range = edge0->range;
	      big_edge = edge0;
	      big_elem = elem0;
	      }
	
	   small_inside_big = (small_range[XMIN] > big_range[XMIN]) &&
	                      (small_range[YMIN] > big_range[YMIN]) &&
	                      (small_range[XMAX] < big_range[XMAX]) &&
	                      (small_range[YMAX] < big_range[YMAX]);
	                   
	   if ( small_inside_big )
	      {
	      if ( small_gmcv->bspcv->num_poles > LOTSA_POLES )
	         {
	         /* The small curve is contained inside the range box of the larger    */
	         /* curve and the small curve has a lot of poles.  Intersect the range */
	         /* box of the smaller curve with the larger curve.                    */
	         rbox_gmcv = VEbuild_rangebox_curve( small_range );
	      
	         VEintersect_curves_with_stroking( small_elem, small_edge, rbox_gmcv, small_elem->env->to_world_scale,
	                         big_elem, big_edge, big_gmcv, big_elem->env->to_world_scale,
	                         TRUE,
	                         free_ints,free_overs,
	                         n_int, int_pts, par0, par1,
	                         n_over, end_pts, over0, over1,
	                         rc, edge_based_dist_tol );

	         /* free memory that was allocated by curve/curve intersection */
	         if ( (*free_ints) && (*int_pts) )
	            {
	            free( (IGRchar *) *int_pts );
	            free( (IGRchar *) *par0 );
	            free( (IGRchar *) *par1 );
	            }

	         if ( (*free_overs) && (*end_pts) )
	            {
	            free( (IGRchar *) *end_pts );
	            free( (IGRchar *) *over0 );
	            free( (IGRchar *) *over1 );
	            }

	         if ( (*n_int == 0) && (*n_over == 0) )
	            {
	            /* The large curve didn't intersect or overlap the range box of the */
	            /* small curve.  If the large curve is inside the range box of the  */
	            /* small curve, we must intersect the two curves.  If not, we know  */
	            /* the two curves do not intersect.                                 */
	            if ( VEcurve_endpoint_inside_range_box( big_gmcv->bspcv, small_range ) )
	               {
	               VEintersect_curves_with_stroking( elem0, edge0, edge0->gm_curve2d, elem0->env->to_world_scale,
	                               elem1, edge1, edge1->gm_curve2d, elem1->env->to_world_scale,
	                               FALSE,
	                               free_ints,free_overs, 
	                               n_int, int_pts, par0, par1,
	                               n_over, end_pts, over0, over1,
	                               rc, edge_based_dist_tol );
	               }
	            else
	               {
	               *n_int = *n_over = 0;
	               *free_ints = *free_overs = FALSE;
	               }
	            }
	         else
	            {
	            /* The large curve intersected the range box of the */
	            /* small curve.  We must intersect the two curves.  */
	            VEintersect_curves_with_stroking( elem0, edge0, edge0->gm_curve2d, elem0->env->to_world_scale,
	                            elem1, edge1, edge1->gm_curve2d, elem1->env->to_world_scale,
	                            FALSE,
	                            free_ints, free_overs, 
	                            n_int, int_pts, par0, par1,
	                            n_over, end_pts, over0, over1,
	                            rc, edge_based_dist_tol );
	            }
	         }
	      else
	         {
	         /* The small curve is contained inside the range box of the larger     */
	         /* curve but it doesn't have a lot of poles.  Intersect the two curves */
	         VEintersect_curves_with_stroking( elem0, edge0, edge0->gm_curve2d, elem0->env->to_world_scale, 
	                         elem1, edge1, edge1->gm_curve2d, elem1->env->to_world_scale,
	                         FALSE,
	                         free_ints, free_overs, 
	                         n_int, int_pts, par0, par1,
	                         n_over, end_pts, over0, over1,
	                         rc, edge_based_dist_tol );
	         }
	      }
	   else
	      {
	      /* set small curve to be the curve that has the fewest poles */
	      if ( curve0->num_poles < curve1->num_poles )
	         {
	         small_gmcv = edge0->gm_curve2d;
	         small_range = edge0->range;
	         small_edge = edge0;
	         small_elem = elem0;
	         big_gmcv = edge1->gm_curve2d;
	         big_range = edge1->range;
	         big_edge = edge1;
	         big_elem = elem1;
	         }
	      else
	         {
	         small_gmcv = edge1->gm_curve2d;
	         small_range = edge1->range;
	         small_edge = edge0;
	         small_elem = elem0;
	         big_gmcv = edge0->gm_curve2d;
	         big_range = edge0->range;
	         big_edge = edge0;
	         big_elem = elem0;
	         }

	      if ( big_gmcv->bspcv->num_poles > LOTSA_POLES )
	         {
	         /* The big curve has a lot of poles.  Intersect the range */
	         /* box of the larger curve with the smaller curve.        */
	         rbox_gmcv = VEbuild_rangebox_curve( big_range );

	         VEintersect_curves_with_stroking( big_elem, big_edge, rbox_gmcv, big_elem->env->to_world_scale,
	                         small_elem, small_edge, small_gmcv, small_elem->env->to_world_scale,
	                         TRUE,
	                         free_ints, free_overs, 
	                         n_int, int_pts, par0, par1,
	                         n_over, end_pts, over0, over1,
	                         rc, edge_based_dist_tol );

	         /* free memory that was allocated by curve/curve intersection */
	         if ( (*free_ints) && (*int_pts) )
	            {
	            free( (IGRchar *) *int_pts );
	            free( (IGRchar *) *par0 );
	            free( (IGRchar *) *par1 );
	            }

	         if ( (*free_overs) && (*end_pts) )
	            {
	            free( (IGRchar *) *end_pts );
	            free( (IGRchar *) *over0 );
	            free( (IGRchar *) *over1 );
	            }
 
	         if ( (*n_int == 0) && (*n_over == 0) )
	            {
	            /* The small curve didn't intersect or overlap the range box of the */
	            /* large curve.  If the small curve is inside the range box of the  */
	            /* large curve, we must intersect the two curves.  If not, we know  */
	            /* the two curves do not intersect.                                 */
	            if ( VEcurve_endpoint_inside_range_box( small_gmcv->bspcv, big_range ) )
	               {
	               VEintersect_curves_with_stroking( elem0, edge0, edge0->gm_curve2d, elem0->env->to_world_scale, 
	                               elem1, edge1, edge1->gm_curve2d, elem1->env->to_world_scale,
	                               FALSE,
	                               free_ints, free_overs, 
	                               n_int, int_pts, par0, par1,
	                               n_over, end_pts, over0, over1,
	                               rc, edge_based_dist_tol );
	               }
	            else
	               {
	               *n_int = *n_over = 0;
	               *free_ints = *free_overs = FALSE;
	               }
	            }
	         else
	            {
	            /* The small curve intersected the range box of the */
	            /* large curve.  We must intersect the two curves.  */
	            VEintersect_curves_with_stroking( elem0, edge0, edge0->gm_curve2d, elem0->env->to_world_scale,
	                            elem1, edge1, edge1->gm_curve2d, elem1->env->to_world_scale,
	                            FALSE,
	                            free_ints, free_overs, 
	                            n_int, int_pts, par0, par1,
	                            n_over, end_pts, over0, over1,
	                            rc, edge_based_dist_tol );
	            }
	         }
	      else
	         {
	         /* The large curve doesn't have a lot of poles. */
	         /* Intersect the two curves.                    */
	         VEintersect_curves_with_stroking( elem0, edge0, edge0->gm_curve2d, elem0->env->to_world_scale,
	                         elem1, edge1, edge1->gm_curve2d, elem1->env->to_world_scale,
	                         FALSE,
	                         free_ints, free_overs, 
	                         n_int, int_pts, par0, par1,
	                         n_over, end_pts, over0, over1,
	                         rc, edge_based_dist_tol );
	         }
	      }
	    
	   /* enable overlaps */
	   if ( disabled_overlaps )
	      BSichgpar( BSCVORD2_OVERLAP, 1, &my_rc );

#if DEBUG_RESULTS
	   {
	   int i;
	   if ( *rc == BSSUCC )
	      {
	      fprintf (stderr, "\nBScvcvint: # of intersections = %d\n", *n_int);
	      for (i = 0; i < *n_int; i++)
	         fprintf( stderr, "%lf %lf %lf / %lf / %lf\n",
	                  (*int_pts)[i][0], (*int_pts)[i][1], (*int_pts)[i][2],
	                  (*par0)[i], (*par1)[i] );
	      }
	   }
#endif

	   }  /* end: else */

        VEeliminate_erroneous_intersects_and_overlaps(
                 n_int, n_over, par0, par1, over0, over1, edge0, edge1);

	if ( VEexec_parms.VEhiding )
	   {
	   VEsave_intersection_info( edge0, edge1, elem0, elem1,
	                             *n_int, *n_over, *par0, *par1, *over0, *over1 );
	   }

	}  /* VEcvcv_int */


/*-- VEcv_slfint ---------------------------------------------------------------*/

void VEcv_slfint( rc,
	          edge,
	          curve,
	          to_world_scale,
	          n_int,
	          a_par, b_par,
	          n_over,
	          c_over, d_over, e_over, f_over,
	          edge_based_dist_tol )

	IGRint               *rc;                /* BSSUCC or BSNOMEMORY      */
	struct VEedge_header *edge;              /* edge header for curve     */
	struct IGRbsp_curve  *curve;             /* curve to be intersected   */
	IGRdouble            to_world_scale;     /* to_world_scale for curve  */
	IGRint               *n_int;             /* number of intersections   */
	IGRdouble            **a_par, **b_par;   /* intersection parameters   */
	IGRint               *n_over;	         /* number of overlap regions */
	IGRdouble            **c_over, **d_over, /* overlap parameters        */
	                     **e_over, **f_over;
	IGRdouble            *edge_based_dist_tol;

/*
NAME
	VEcv_slfint

DESCRIPTION
	Provides an interface to the math routine BScv_slfint by making
	modifications needed for VE processing to the curves.  The change
	is forcing the poles to lie in the same Z plane.

PARAMETERS
	rc (OUT) - return code from math routine
	edge (IN) - edge header for curve
	curve (IN) - curve to be self-intersected
	to_world_scale (IN) - to_world_scale for curve
	n_int (OUT) - number of intersections
	a_par (OUT) - first array of intersection parameters
	b_par (OUT) - second array of intersection parameters
	n_over (OUT) - number of overlap regions
	c_over (OUT) - first array of overlap start points
	d_over (OUT) - first array of overlap end points
	e_over (OUT) - second array of overlap start points
	f_over (OUT) - second array of overlap end points
	edge_based_dist_tol (OUT) - dist tol used to intersect edges

GLOBALS USED
	VEtolerances	

HISTORY
	05/06/87   S.A. Rapa
	   Creation Date
*/

	{
	IGRlong     rc1;
	IGRboolean  old_planar, status;
	IGRdouble   dist_tol, default_dist_tol;
	IGRdouble   *saved_poles;

	*a_par  = *b_par = *c_over = *d_over = *e_over = *f_over = NULL;

	old_planar = curve->planar;
	curve->planar = FALSE;

	/* save and zero out the Z poles of the curves */
	saved_poles = (IGRdouble *) alloca( curve->num_poles * sizeof( IGRdouble ) );
	VEsave_z( curve->num_poles, curve->poles, saved_poles );

#if TIMING
	times( &VEs_time );
#endif
	
	/* Set the tolerances required to perform intersection */
	BSxtractpar( &rc1, BSTOLLENVEC,  &default_dist_tol );

	if ( (edge->type == HORIZON_EDGE) || (edge->type == HORIZON_CURVE) ||
	     ( (edge->type == BOUNDARY) && (curve->order == 2) ) )
	   dist_tol = VEtolerances.VEscaled_cht * to_world_scale;
	else
	   dist_tol = VEtolerances.VEscaled_cht * 0.1;

	dist_tol *= 1.1;
	*edge_based_dist_tol = dist_tol;
	         
	BSchangepar( &rc1, BSTOLLENVEC, dist_tol );
	BSchangepar( &rc1, BSTOLSQLENVEC, dist_tol * dist_tol );

	status = BScv_slfint( (BSrc *)rc, curve, n_int, a_par, b_par, n_over,
	                      c_over, d_over, e_over, f_over );

	BSchangepar( &rc1, BSTOLLENVEC, default_dist_tol );
	BSchangepar( &rc1, BSTOLSQLENVEC, default_dist_tol * default_dist_tol );

#if TIMING
	times( &VEe_time );

	VEcount_cvslf++;
	VEtime_cvslf += ( ( (VEe_time.tms_utime + VEe_time.tms_stime) -
	                    (VEs_time.tms_utime + VEs_time.tms_stime) ) / 60.0 );
#endif

#if DEBUG_ERRORS_CVSLF
	if ( *rc != BSSUCC )
	   VElog_cvslf_int_data( curve );
#endif

	VErestore_z( curve->num_poles, curve->poles, saved_poles );

	curve->planar = old_planar;

	}  /* VEcv_slfint */


/*-- VEcvcv_int_3d -------------------------------------------------------------*/

void VEcvcv_int_3d( rc,
	            curve0, curve1,
	            n_int,
	            int_pts,
	            par0, par1,
	            n_over,
	            end_pts, 
	            over0, over1,
	            free_ints,
	            free_overs )

	IGRint              *rc;
	struct IGRbsp_curve *curve0, *curve1;
	IGRint              *n_int;
	IGRpoint            **int_pts;
	IGRdouble           **par0, **par1;
	IGRint              *n_over;
	IGRpoint            **end_pts;
	IGRdouble           **over0, **over1;
	IGRboolean          *free_ints,
	                    *free_overs;

/*
NAME
	VEcvcv_int_3d

DESCRIPTION
	Provides an interface to the math routine BScvcvint, like VEcvcv_int,
	but does a full 3D intersection.  Its purpose is to simplify the 
	handling of static vs. dynamic storage for the intersections and
	overlaps found.

PARAMETERS
	rc (OUT) -  return code from math routine
	curve0 (IN) - first curve to intersect
	curve1 (IN) - other curve to intersect
	n_int (OUT) - number of intersections
	int_pts (OUT) - XYZ values of intersections
	par0 (OUT) - parameters of intersections on curve0
	par1 (OUT) - parameters of intersections on curve1
	n_over (OUT) - number of overlap regions
	end_pts (OUT) - XYZ values of overlap endpoints
	over0 (OUT) - parameters of overlap endpoints on curve0
	over1 (OUT) - parameters of overlap endpoints on curve1
	free_ints (OUT) - TRUE, if intersection arrays should be
	                  freed by the caller
	free_overs (OUT) - TRUE, if overlap arrays should be freed
	                   by the caller

GLOBALS USED
	cv0_param_3d, cv1_param_3d, int_points_3d (static)
	cv0_over_3d, cv1_over_3d, overlaps_3d (static)

HISTORY
	09/15/87    S.A. Rapa
	   Creation Date
*/

	{
	IGRboolean old_planar0, old_planar1;

	old_planar0   = curve0->planar;
	old_planar1   = curve1->planar;
	curve0->planar = FALSE;
	curve1->planar = FALSE;

        BScvcvint( curve0, curve1,
	           FALSE,

	           /* Static memory */

	           NUM_STATIC_INTS_3D, NUM_STATIC_OVERS_3D,
	           int_points_3d, cv0_param_3d, cv1_param_3d,
	           overlaps_3d, cv0_over_3d, cv1_over_3d,

	           /* Memory allocated by routine */

	           n_int, n_over,
	           free_ints, free_overs,
	           int_pts, par0, par1,
	           end_pts, over0, over1,
	           (BSrc *)rc );

#if DEBUG_ERRORS_CVCV3D
	if ( *rc != BSSUCC )
	   VElog_cvcv_int_data( curve0, curve1 );
#endif

	curve0->planar = old_planar0;
	curve1->planar = old_planar1;

	if ( ! *free_ints )
	   {
	   *int_pts = int_points_3d;
	   *par0    = cv0_param_3d;
	   *par1    = cv1_param_3d;
	   }

	if ( ! *free_overs )
	   {
	   *end_pts = overlaps_3d;
	   *over0   = cv0_over_3d;
	   *over1   = cv1_over_3d;
	   }

#if DEBUG_RESULTS
	{
	int i;
	if ( *rc == BSSUCC )
	   {
	   fprintf (stderr, "\nBScvcvint: # of intersections = %d\n", *n_int);
	   for (i = 0; i < *n_int; i++)
	      fprintf( stderr, "%lf %lf %lf / %lf / %lf\n",
	               (*int_pts)[i][0], (*int_pts)[i][1], (*int_pts)[i][2],
 	               (*par0)[i], (*par1)[i] );
	    }
	}
#endif

	}  /* VEcvcv_int_3d */
