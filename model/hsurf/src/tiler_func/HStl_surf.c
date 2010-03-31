/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:42 $
$Locker:  $

HISTORY

        Sudha   07/27/93        Modified for BSprototypes ansification
*/

#include <stdio.h>
#include <stdlib.h>
#include <alloca.h>
#include "wl.h"

#if defined( ENV5 )
#include <EG.h>
#include <gpipe.h>
#endif

#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "exsysdep.h"
#include "igr.h"
#include "gr.h"
#include "igrdp.h"
#include "dp.h"
#include "dpstruct.h"

#include "bstypes.h"
#include "bssfarrevmt.h"
#include "bsfndsfcsp.h"

#include "hsdef.h"
#include "hsmacdef.h"
#include "hsmath.h"
#include "hstiler.h"
#include "hslight.h"
#include "hrstruct.h"
#include "hsdisplay.h"

#include "HStl_global.h"
#include "HStl_window.h"
#include "HStl_element.h"
#include "HSfem_spt.h"
#include "HSd_fixedpt.h"
#include "HSe2_mesher.h"

#include "HSpr_tiler_f.h"

/*-----------------------------
 *  for functions
 *     HSpaint
 */
 
#include "HSpr_display.h"

/*----------------------------
 *  for functions
 *     HSadd_vertex_to_buffered_trimesh
 *     HSdisplay_buffered_trimesh
 */
 
#include "HSpr_pbust_f.h"

/*----------------------------
 *  for functions
 *     HSdelete
 *     HSsave_surface
 *     HSshade_object
 */
 
#include "HSpr_driver.h"

/*----------------------------*/



/*
 *  Prototype declaration for static functions
 */

/* HStl_surf.c */
#if LOG_BSSFARREVMT_DATA
static void HSlog_BSsfarrevmt_data    (  struct IGRbsp_surface *surf, 
							IGRint num_upoints, 
						     IGRdouble *upoints, 
							IGRint num_vpoints, 
						     IGRdouble *vpoints, 
						    IGRboolean ind[4 ]);
#endif
						    
static void HSfind_sharp_knots    (      struct IGRbsp_surface *surf, 
							IGRint *num_u, 
							IGRint *num_v, 
						     IGRdouble **sharp_u_knots, 
						     IGRdouble **sharp_v_knots);
						     
static void HSrefine_sample_regions    (		IGRint num_sharps, 
						     IGRdouble *sharps, 
							IGRint num_points, 
						     IGRdouble *points, 
							IGRint *num_indexes, 
							IGRint *indexes);
							
static IGRint HSoutcode    (			      IGRpoint point, 
						     IGRdouble w);
						     
static void HSset_delete_flags    (		      IGRpoint *sfpoints, 
							IGRint num_upoints, 
							IGRint num_vpoints, 
							IGRint *u_delflags, 
							IGRint *v_delflags, 
							IGRint *num_udel, 
							IGRint *num_vdel, 
						    IGRboolean *skip_first_u, 
						    IGRboolean *skip_first_v, 
						    IGRboolean *skip_last_u, 
						    IGRboolean *skip_last_v);
						    
static void HSdelete_sample_points    (			IGRint num_udel, 
							IGRint num_vdel, 
							IGRint *u_delflags, 
							IGRint *v_delflags, 
						      IGRpoint *sfpoints, 
							IGRint num_upoints, 
							IGRint *num_upoints2, 
							IGRint num_vpoints, 
							IGRint *num_vpoints2, 
						     IGRdouble *upoints, 
						     IGRdouble *upoints2, 
						     IGRdouble *vpoints, 
						     IGRdouble *vpoints2, 
						    IGRboolean skip_first_u, 
						    IGRboolean skip_last_u, 
						    IGRboolean *u_skip_flags, 
						    IGRboolean skip_first_v, 
						    IGRboolean skip_last_v, 
						    IGRboolean *v_skip_flags);
						    
static void HSclear_knot_lo_bits    (		       IGRlong num_knots, 
						     IGRdouble *knots);
						     
static void HScompute_facet_normal    (		      IGRpoint *sfpoints, 
						     IGRdouble *w, 
							IGRint lo_u_lo_v, 
							IGRint lo_u_hi_v, 
							IGRint hi_u_lo_v, 
							IGRint hi_u_hi_v);
							
static void HSgenerate_fem_polygons    (		IGRint num_upoints, 
							IGRint num_vpoints, 
						     IGRdouble *upoints, 
						     IGRdouble *vpoints, 
						      IGRpoint *sfpoints);
						      
static void HSgenerate_surface_mesh    (		IGRint num_upoints, 
							IGRint num_vpoints, 
						      IGRpoint *sfpoints);
						      
static void HSgenerate_surface_polygons    (		IGRint num_upoints, 
							IGRint num_vpoints, 
						      IGRpoint *sfpoints, 
						    IGRboolean *normdir, 
						    IGRboolean u_closed, 
						    IGRboolean v_closed, 
						     IGRdouble ulo, 
						     IGRdouble vlo, 
						     IGRdouble vhi, 
						     IGRdouble *upoints, 
						     IGRdouble *vpoints);
						     
static void HSgenerate_surf_with_bound_polygons    (	IGRint num_upoints, 
							IGRint num_vpoints, 
						     IGRdouble *upoints, 
						     IGRdouble *vpoints, 
						      IGRpoint *sfpoints, 
						    IGRboolean *normdir, 
						    IGRboolean u_closed, 
						    IGRboolean v_closed, 
						struct HSbound *patch_bounds[], 
							IGRint *patch_index, 
						    IGRboolean *u_skip_flags, 
						    IGRboolean *v_skip_flags, 
						    IGRboolean origin_status, 
						    IGRboolean *next_u_status,
						    IGRboolean *next_v_status);
						     
static void HSdistribute_boundaries    (	struct HSbound *master_bounds, 
							IGRint num_upoints, 
							IGRint num_vpoints, 
						     IGRdouble upoints[], 
						     IGRdouble vpoints[], 
						struct HSbound *distributed_bounds[]);
						
#if DEBUG_SURFACE
static HSdump_surface    (		 struct IGRbsp_surface *surf);
#endif

static void HSset_cull_flag    (	 struct IGRbsp_surface *geometry_ptr, 
						    IGRboolean from_solid, 
							IGRint options, 
						     IGRdouble range[]);
						     
static void HScheck_object_range    (		     IGRdouble *range);

static void HScompare_coordinates    (			IGRint num_upoints, 
							IGRint num_vpoints, 
						     IGRdouble *upoints, 
						     IGRdouble *vpoints, 
						      IGRpoint *sfpoints);
						     
static void HSsurface_tiler    (	 struct IGRbsp_surface *surf, 
							IGRint num_upoints, 
							IGRint num_vpoints, 
						     IGRdouble *upoints, 
						     IGRdouble *vpoints);
						     
static int HScheck_bnds    (		 struct IGRbsp_surface *surf);

static void HScalc_surf_sample_points    (struct IGRbsp_surface *surf, 
							 IGRint acc_mode, 
							 IGRint accuracy, 
						      IGRdouble win_cht, 
						      IGRdouble *u_range, 
						      IGRdouble *v_range, 
							 IGRint *num_upoints, 
							 IGRint *num_vpoints, 
						      IGRdouble **upoints, 
						      IGRdouble **vpoints, 
							    int min_insert, 
						      IGRdouble basis_tol);
						      



#define POINTS_ARE_EQUAL( x, y )	((ABS(x[0] - y[0]) <= element_parms.interp_tol) &&	\
					 (ABS(x[1] - y[1]) <= element_parms.interp_tol) &&	\
					 (ABS(x[2] - y[2]) <= element_parms.interp_tol))

#define NEAR_Z_CLIPPED		(HSoutside_z_range(	TRUE,					\
							((active_window->perspective) ?		\
							 ((element_parms.ele_clip_range[2] -	\
							   active_window->dit_clip_range[2]) /	\
							  (active_window->dit_clip_range[5] -	\
					 		   active_window->dit_clip_range[2])) :	\
							 (active_window->z_min)),		\
							range))

#define FAR_Z_CLIPPED		(HSoutside_z_range(	FALSE,					\
							((active_window->perspective) ?		\
							 ((element_parms.ele_clip_range[5] -	\
							   active_window->dit_clip_range[2]) /	\
							  (active_window->dit_clip_range[5] -	\
					 		   active_window->dit_clip_range[2])) :	\
							 (active_window->z_max)),		\
							range))

#define	CANNOT_USE_LOCKED_BUFFERS	((options & (HS_BST_EDGES | HS_BST_REV_EDGES)) &&	\
					 ((element_parms.visible_weight > 0) || 		\
					  (tiling_parms.processing_mode & HS_PMODE_RHL_SHOW_HIDDEN)))


#ifdef	TRUE
#undef	TRUE
#endif
#ifdef	FALSE
#undef	FALSE
#endif
#define	FALSE		0		/* boolean values */
#define	TRUE		~FALSE


/* CLEAR_LO_BITS clears the low order */
/* 4 bits of the mantissa of a double */ 
#ifdef BIG_ENDIAN
#define CLEAR_LO_BITS( d_ptr )     \
	                           \
	{                          \
	char *c_ptr;               \
	c_ptr = (char *) (d_ptr);  \
	c_ptr += 7;                \
	*c_ptr &= ~0xF;            \
	}
#else
#define CLEAR_LO_BITS( d_ptr )     \
	                           \
	{                          \
	char *c_ptr;               \
	c_ptr = (char *) (d_ptr);  \
	*c_ptr &= ~0xF;            \
	}
#endif		

#define	KNOT_TOL	0.000005

#define DEBUG		0
#define DEBUG_SURFACE	0
#define EDGEII_DEBUG	0
#define FEM_DEBUG	0
#define LOG_BSSFARREVMT_DATA 0

/* Defines for stack space memory allocation.  The   */
/* values for these defines were EMPIRICALLY derived */
/* from allocation data obtained by shading  several */
/* test files.  It is hoped that the space will be   */
/* sufficient for the majority of surfaces and thus  */
/* reduce the number of calls we make to malloc().   */
#define REGION_INDEX_SPACE	20	/* doubles */
#define SF_POINT_SPACE		700	/* doubles */
#define NORMDIR_SPACE		100	/* booleans */
#define NORM_FIRST_SPACE	20	/* booleans */
#define ADJUSTED_POINTS_SPACE	10	/* doubles */
#define DELFLAGS_SPACE		10	/* ints */
#define REGION_BOUNDS_SPACE	100	/* pointers */
#define PATCH_BOUNDS_SPACE	100	/* pointers */
#define SKIP_FLAGS_SPACE        50      /* booleans */

/* The following macro is used to get memory when space has been     */
/* reserved on the stack that will handle the majority of the cases. */
/* The parameters are:                                               */
/*                                                                   */
/*   need - the number of elements needed                            */
/*   have - the number of elements in the stack space                */
/*   bytes_per - number of bytes per element                         */
/*   addr - address of the beginning of the stack space              */
/*                                                                   */
/* If enough space is available in the stack, a pointer to it is     */
/* returned, otherwise malloc is called to get the required space.   */
/* The caller is responsible for freeing malloced space.  The caller */
/* should free if the address that is returned is not equal to       */
/* 'addr' that is passed in.                                         */
#define GET_MEMORY( need, have, bytes_per, addr )      \
 	                                               \
	(((need) > (have)) ?                           \
	    (char *) malloc( (need) * (bytes_per) ) :  \
	    (char *) (addr));                          \


/*
struct HSbound		*preprocess_a_boundary();
struct HSbound		*sift_boundaries();
IGRboolean		get_horizontal_status();
IGRboolean		get_vertical_status();
IGRboolean		HSoutside_z_range();
IGRint			add_mesh_intersections();
void			construct_polygons();
void			HSdispose_bound_list();
void			rotate_normals();
void			transform_points();
*/


#if EDGEII_DEBUG
static int Bounds = 0, NoBounds = 0;
#endif

/*******************
 * LOCAL VARIABLES *
 *******************/

static struct IGResfct	*HSfem_local_fem_data;
static IGRboolean	HSfem_doing_mesh_lines;
static IGRdouble	min_x, min_u, min_v, max_u, max_v;
static IGRint		unorm_index, vnorm_index;
static IGRboolean	*unorm_first = NULL;
static IGRboolean	*vnorm_first = NULL;
static IGRint    	sharp_u_size = 0;
static IGRint    	sharp_v_size = 0;
static IGRdouble 	*sharp_u_buffer;
static IGRdouble 	*sharp_v_buffer;


#if LOG_BSSFARREVMT_DATA
/*--- HSlog_BSsfarrevmt_data -------------------------------------------------------*/

static void HSlog_BSsfarrevmt_data( struct IGRbsp_surface *surf,
						   IGRint num_upoints,
						IGRdouble *upoints,
						   IGRint num_vpoints,
						IGRdouble *vpoints,
						IGRboolean ind[4] )

/*
NAME
	HSlog_BSsfarrevmt_data

KEYWORD
	debug

DESCRIPTION
	This function logs the data for a call to BSsfarrevmt to stderr
	so it can be given to the math group for debugging.

PARAMETERS
	surf (IN) - the surface whose points are evaluated
	num_upoints (IN) - the number of U points
	upoints (IN) - array of U points
	num_vpoints (IN) - the number of V points
	vpoints (IN) - array of V points
	ind (IN) - array of output indicators

GLOBALS USED
	none

HISTORY
	01/30/92    S.P. Rogers
	   Creation Date
	02/10/92    S.P. Rogers
	   Added prologue documentation
*/

	{
	IGRchar name;
	IGRint  ii;

	fprintf( stderr, "BSsfarrevmt data ...\n\n" );
	BSprintbsps( stderr, &name, surf, FALSE );

	fprintf( stderr, "\n" );

	fprintf( stderr, "IND[0] = %d\n", ind[0] );
	fprintf( stderr, "IND[1] = %d\n", ind[1] );
	fprintf( stderr, "IND[2] = %d\n", ind[2] );
	fprintf( stderr, "IND[3] = %d\n", ind[3] );

	fprintf( stderr, "\n" );

	fprintf( stderr, "Num U Points: %d\n" );
	for ( ii = 0; ii < num_upoints; ii++ )
	   fprintf( stderr, "   %20.18lf\n", upoints[ii] );

	fprintf( stderr, "\n" );

	fprintf( stderr, "Num V Points: %d\n" );
	for ( ii = 0; ii < num_vpoints; ii++ )
	   fprintf( stderr, "   %20.18lf\n", vpoints[ii] );

	}  /* HSlog_BSsfarrevmt_data */
#endif


/*---- HSfind_sharp_knots ----------------------------------------------------------*/

static void HSfind_sharp_knots( struct IGRbsp_surface *surf,
					       IGRint *num_u,
					       IGRint *num_v,
					    IGRdouble **sharp_u_knots,
					    IGRdouble **sharp_v_knots )

/*
NAME
	HSfind_sharp_knots (static)

DESCRIPTION
	This function finds the knot values where a surface has cusp lines.

PARAMETERS
	surf (IN) - the surface whose sharp knots are to be found
	num_u (OUT) - the number of sharp knots in u
	num_v (OUT) - the number of sharp knots in v
	sharp_u_knots (OUT) - array of sharp u knots
	sharp_v_knots (OUT) - array of sharp v knots

GLOBALS USED
	sharp_u_size
	sharp_v_size
	sharp_u_buffer
	sharp_v_buffer

NOTES
	Global, re-useable arrays are used to hold the knot values that
	are returned by this function, so the calling routine should
	not free the arrays it is returned.

HISTORY
	09/18/87    S.P. Rogers
	   Creation Date
	02/10/92    S.P. Rogers
	   Added prologue documentation
*/

	{
	IGRlong   rc;

	(*num_u) = (*num_v) = 0;

	/* make sure buffers are large enough for sharp knots */
	/* (3): allow for possible addition of 0.0, 1.0 in surface_tiler.  CMJ  01/17/90 */
	if ( (surf->u_num_poles - surf->u_order + 3) > sharp_u_size )
	   {
	   if ( sharp_u_size )  free( (IGRchar *) sharp_u_buffer );
	   sharp_u_size = surf->u_num_poles - surf->u_order + 3; 
	   sharp_u_buffer = (IGRdouble *) malloc( sizeof( IGRdouble ) * sharp_u_size );
	   }

	if ( (surf->v_num_poles - surf->v_order + 3) > sharp_v_size )
	   {
	   if ( sharp_v_size )  free( (IGRchar *) sharp_v_buffer );
	   sharp_v_size = surf->v_num_poles - surf->v_order + 3;
	   sharp_v_buffer = (IGRdouble *) malloc( sizeof( IGRdouble ) * sharp_v_size );
	   }

	/* find the sharp knots (cusps on surface) */

	BSfndsfcsp( surf, num_u, sharp_u_buffer, num_v, sharp_v_buffer, &rc );

	*sharp_u_knots = sharp_u_buffer;
	*sharp_v_knots = sharp_v_buffer;

	}  /* HSfind_sharp_knots */


/*--- HSrefine_sample_regions ------------------------------------------------------*/

static void HSrefine_sample_regions( IGRint num_sharps,
				  IGRdouble *sharps,
				     IGRint num_points,
				  IGRdouble *points,
				     IGRint *num_indexes,
				     IGRint *indexes )

/*
NAME
	HSrefine_sample_regions (static)

DESCRIPTION
	This function defines the sample regions.  Originally, each sample region
	corresponded to a sharp region, that is, a region of the surface bounded
	by logically sharp knots.  But since we've been able to restrict sample
	points to the solid range of the patch, some sharp regions may be partially
	or completely outside our area of interest.  We can ignore these sharp
	regions, and define the sample regions as only those parts of sharp regions
	that are within our area of interest.  This function adjusts the sharp knot
	values accordingly, by excluding the sharp knot values that are outside our
	area of interest and including the minimum and maximum values of our range
	of interest, (points[0] and points[num_points - 1]).  It also finds the index
	of each sharp knot value in the sample point array and stores these indices
	in the index array.

PARAMETERS
	num_sharps (IN) - the number of sharp knots
	sharps (IN/OUT) - array of sharp knots
	num_points (IN) - number of sample points
	points (IN) - array of sample points
	num_indexes (OUT) - number of sample regions
	indexes (OUT) - array of sample regions (must be allocated by caller)

GLOBALS USED

HISTORY
	01/25/90    C.M. Jablonski
	   Created.
	04/25/90    C.M. Jablonski
	   Added last_index to skip redundant
	   sharp knot indexes, (Notebook V, p.9).
	02/10/92    S.P. Rogers
	   Added prologue documentation
	07/29/92    S.P. Rogers
	   Added special cases to check for all sharps being less than
	   or greater than the sample points; this keeps the for-loops
	   from running passed the end of the sharps array
*/

	{
	IGRint		start, end, last_index, index, sindex;

	/*
	 * Determine the active range of the knot array.
	 */

	if (num_sharps <= 0)
	{
		start = 0;
		end = -1;
	}
	else
	{
		if ( (sharps[num_sharps - 1] < points[0]) ||
		     (sharps[0] > points[num_points - 1]) )
		{
			/* special case:  all sharps less than the sample points */
			/* or all sharps are greater than the sample points      */
			start = 0; end = -1;
		}
		else
		{
			for (start = 0; sharps[start] <= points[0]; start++);
			for (end = num_sharps - 1; sharps[end] >= points[num_points - 1]; end--);
		}
	}


	/*
	 * Set up the index array and count.
	 */

	*num_indexes = 0;
	last_index = index = 0;
	indexes[(*num_indexes)++] = index++;
	for (sindex = start; (index < (num_points - 1)) && (sindex <= end); sindex++)
		{
		for (; (index < (num_points - 1)) && 
		       ((sharps[sindex] - points[index]) > KNOT_TOL); index++);
		if (index != last_index) indexes[(*num_indexes)++] = last_index = index;
		}
	if (indexes[(*num_indexes) - 1] < (num_points - 1))	
		indexes[(*num_indexes)++] = num_points - 1;


	/*
	 * Reset the sharp knot array so that "sharp knots" are exactly
	 * equal to their indexed sample points.
	 */

	for (index = 0; index < *num_indexes; index++)
		sharps[index] = points[indexes[index]];
	}  /* HSrefine_sample_regions */

	
/*--- HSoutcode ---------------------------------------------------------*/

static IGRint	HSoutcode( IGRpoint point, IGRdouble w)

/*
NAME
	HSoutcode (static)

DESCRIPTION
	Returns the outcode for the given point.  Only the outcodes
	with respect to X and Y are calculated.

PARAMETERS
	point (IN) - point whose outcode is to be determined
	w (IN) - w for point

GLOBALS USED
	active_window

RETURN VALUES
	The outcode that is returned has the following format:

 	   0x0000 0000
	          ^^^^
	          ||||
	          |||+-- point is to the RIGHT of window.
	          ||+--- point is to the LEFT of window.
	          |+---- point is ABOVE window.
	          +----- point is BELOW window.

HISTORY
	 01/22/90    C.M. Jablonski
	   Created.
	02/10/92    S.P. Rogers
	   Added prologue documentation
*/

	{
	IGRint		outcode;

	outcode = 0x00000000;

	if (active_window->perspective)
	   {
	   if (point[0] > w)
	      outcode |= 0x00000001;
	   else	 if (point[0] < (0.0 - w))
	      outcode |= 0x00000002;

	   if (point[1] > w)
	      outcode |= 0x00000004;
	   else	 if (point[1] < (0.0 - w))
	      outcode |= 0x00000008;
	   }
	else
	   {
	   if (point[0] > element_parms.ele_clip_range[3])
	      outcode |= 0x00000001;
	   else	 if (point[0] < element_parms.ele_clip_range[0])
	      outcode |= 0x00000002;

	   if (point[1] > element_parms.ele_clip_range[4])
	      outcode |= 0x00000004;
	   else	 if (point[1] < element_parms.ele_clip_range[1])
	      outcode |= 0x00000008;
	   }

	return( outcode );
	}  /* HSoutcode */

	
/*--- HSset_delete_flags ---------------------------------------------------------*/

static void HSset_delete_flags(	IGRpoint *sfpoints,
				  IGRint num_upoints,
				  IGRint num_vpoints,
				  IGRint *u_delflags,
				  IGRint *v_delflags,
				  IGRint *num_udel,
				  IGRint *num_vdel,
			      IGRboolean *skip_first_u,
			      IGRboolean *skip_first_v,
			      IGRboolean *skip_last_u,
			      IGRboolean *skip_last_v )

/*
NAME
	HSset_delete_flags (static)

DESCRIPTION
	This function calculates delete flags for the given sample points.

PARAMETERS
	sfpoints (IN) - surface points whose delete flags are to be set
	num_upoints (IN) - number of surface points in u
	num_vpoints (IN) - number of surface points in v
	u_delflags (OUT) - array of delete flags for U points
	v_delflags (OUT) - array of delete flags for V points
	num_udel (OUT) - number of deleted points in U
	num_vdel (OUT) - number of deleted points in V
	skip_first_u (OUT) - TRUE, if first u should be skipped
	skip_first_v (OUT) - TRUE, if first v should be skipped
	skip_last_u (OUT) - TRUE, if last u should be skipped
	skip_last_v (OUT) - TRUE, if last v should be skipped

GLOBALS USED
	active_window
	tiling_parms

HISTORY
	01/22/90    C.M. Jablonski
	   Created.
	02/10/92    S.P. Rogers
	   Added prologue documentation
*/

	{
	IGRint		i, j, code, code2;
	IGRdouble	*w;


	if ( (active_window->making_triangles) || 
	     (tiling_parms.processing_mode & HS_PMODE_DEXEL) )
	   {
	   /*
	    * Clear the delete flags because we can't delete sample
	    * points in Triangle or Dexel mode because the sample
	    * points are still in world coordinates.
	    */

	   memset( u_delflags, 0, num_upoints * sizeof( IGRint ) );
	   memset( v_delflags, 0, num_vpoints * sizeof( IGRint ) );
	   *num_udel = 0;
	   *num_vdel = 0;
	   *skip_first_u = FALSE;
	   *skip_last_u = FALSE;
	   *skip_first_v = FALSE;
	   *skip_last_v = FALSE;
	   }
	else
	   {
	   /*
	    * Initialize the outcode arrays.
	    */

	   for (i = 0; i < num_vpoints; i++)
	      v_delflags[i] = 0x0000000f;
	   for (i = 0; i < num_upoints; i++)
	      u_delflags[i] = 0x0000000f;

	   /*
	    * Calculate the outcodes.
	    */
	
	   w = sfpoints[2 * num_upoints * num_vpoints];
	   for (i = 0; i < num_vpoints; i++)
	      for (j = 0; j < num_upoints; j++)
	         if (v_delflags[i] || u_delflags[j])
	            {
	            code = HSoutcode(sfpoints[(i * num_upoints) + j],
	                           w[(i * num_upoints) + j]);
	            v_delflags[i] &= code;
	            u_delflags[j] &= code;
	            }

	   /*
	    * Convert outcodes to delete flags.
	    */

	   *skip_first_u = u_delflags[0] & u_delflags[1];
	   *skip_last_u = u_delflags[num_upoints - 2] & u_delflags[num_upoints - 1];
	   *num_udel = 0;
	   code = u_delflags[0];
	   for (i = 1; i < (num_upoints - 1); i++)
	      {
	      code2 = u_delflags[i];
	      if (u_delflags[i] = code & u_delflags[i] & u_delflags[i + 1])
	         (*num_udel)++;
	      code = code2;
	      }
	   u_delflags[0] = u_delflags[num_upoints - 1] = 0;

	   *skip_first_v = v_delflags[0] & v_delflags[1];
	   *skip_last_v = v_delflags[num_vpoints - 2] & v_delflags[num_vpoints - 1];
	   *num_vdel = 0;
	   code = v_delflags[0];
	   for (i = 1; i < (num_vpoints - 1); i++)
	      {
	      code2 = v_delflags[i];
	      if (v_delflags[i] = code & v_delflags[i] & v_delflags[i + 1])
	         (*num_vdel)++;
	      code = code2;
	      }
	   v_delflags[0] = v_delflags[num_vpoints - 1] = 0;
	   }
	}  /* HSset_delete_flags */

	
/*--- HSdelete_sample_points ---------------------------------------------------------*/

static void HSdelete_sample_points( IGRint num_udel, 
				    IGRint num_vdel, 
				    IGRint *u_delflags, 
				    IGRint *v_delflags, 
				  IGRpoint *sfpoints, 
				    IGRint num_upoints, 
				    IGRint *num_upoints2, 
				    IGRint num_vpoints, 
				    IGRint *num_vpoints2, 
				 IGRdouble *upoints, 
				 IGRdouble *upoints2, 
				 IGRdouble *vpoints, 
				 IGRdouble *vpoints2, 
			        IGRboolean skip_first_u, 
				IGRboolean skip_last_u, 
				IGRboolean *u_skip_flags, 
				IGRboolean skip_first_v, 
				IGRboolean skip_last_v, 
				IGRboolean *v_skip_flags)

/*
NAME
	HSdelete_sample_points (static)

DESCRIPTION
	This function deletes the indicated sample points from the data structures.

PARAMETERS
	num_udel (IN) - number of u points to delete
	num_vdel (IN) - number of v points to delete
	u_delflags (IN) - array of u delete flags
	v_delflags (IN) - array of v delete flags
	sfpoints (IN/OUT) - array of surface points
	num_upoints (IN) - number of u sample points
	num_upoints2 (OUT) - new number of u sample points
	num_vpoints (IN) - number of v sample points
	num_vpoints2 (OUT) - new number of v sample points
	upoints (IN) - array of u sample points
	upoints2 (OUT) - new array of u sample points
	vpoints (IN) - array of v sample points
	vpoints2 (OUT) - new array of v sample points
	skip_first_u (IN) - flag indicating whether first u should be skipped
	skip_last_u (IN) - flag indicating whether last u should be skipped
	u_skip_flags (OUT) - array of skip flags for u sample points
	skip_first_v (IN) - flag indicating whether first v should be skipped
	skip_last_v (IN) - flag indicating whether last v should be skipped
	v_skip_flags (OUT) - array of skip flags for v sample points

GLOBALS USED
	active_window
	element_parms

HISTORY
	01/23/90    C.M. Jablonski
	   Created.
	02/10/92    S.P. Rogers
	   Added all of the "skip" parameters to help fix TR 92n0793
	   See pg 22 of Notebook IX and prologue documentation
*/

	{
	IGRint 		i, j;
	IGRpoint	*pt, *pt2, *norm, *norm2;
	IGRdouble	*w, *w2;
	IGRboolean      *skip;

	/*
	 * Adjust the number of sample points.
	 */

	*num_upoints2 = num_upoints - num_udel;
	*num_vpoints2 = num_vpoints - num_vdel;

	if ( (num_udel == 0) && (num_vdel == 0) )
	   {
	   /*
	    * No points deleted => optimize performance via memcpy() 
	    */
	   memcpy( upoints2, upoints, *num_upoints2 * sizeof( IGRdouble ) );
	   memcpy( vpoints2, vpoints, *num_vpoints2 * sizeof( IGRdouble ) );
	   memset( u_skip_flags, 0, *num_upoints2 * sizeof( IGRboolean ) );
	   memset( v_skip_flags, 0, *num_vpoints2 * sizeof( IGRboolean ) );
	   }
	else
	   {
	   /*
	    * Adjust the sample point arrays.
	    */

	   w = upoints2;
	   skip = u_skip_flags;
	   for (i = 0; i < num_upoints; i++)
	      if (!u_delflags[i])
	         {
	         *w++ = upoints[i];
	         if ( i != (num_upoints -1) )
	            *skip++ = u_delflags[i+1];  /* skip building of facet if next point is removed */
	         }

	   w = vpoints2;
	   skip = v_skip_flags;
	   for (i = 0; i < num_vpoints; i++)
	      if (!v_delflags[i])
	         {
	         *w++ = vpoints[i];
	         if ( i != (num_vpoints -1) )
	            *skip++ = v_delflags[i+1];  /* skip building of facet if next point is removed */
	         }

	   u_skip_flags[0] = skip_first_u;
	   v_skip_flags[0] = skip_first_v;
	   u_skip_flags[*num_upoints2-1] = skip_last_u;
	   v_skip_flags[*num_vpoints2-1] = skip_last_v;


	   /*
	    * Adjust the point array.
	    */

	   pt = pt2 = sfpoints;
	   for (i = 0; i < num_vpoints; i++)
	      for (j = 0; j < num_upoints; j++)
	         if (v_delflags[i] || u_delflags[j])
	            {
	            pt++;
	            }
	         else
	            {
	            pt2[0][0] = pt[0][0];
	            pt2[0][1] = pt[0][1];
	            pt2[0][2] = pt[0][2];
	            pt2++;
	            pt++;
	            }

	   if (element_parms.doing_vertex_normals)
	      {
	      norm = sfpoints + (num_upoints * num_vpoints);
	      norm2 = sfpoints + ((*num_upoints2) * (*num_vpoints2));
	      for (i = 0; i < num_vpoints; i++)
	         for (j = 0; j < num_upoints; j++)
	            if (v_delflags[i] || u_delflags[j])
	               {
	               norm++;
	               }
	            else
	               {
	               norm2[0][0] = norm[0][0];
	               norm2[0][1] = norm[0][1];
	               norm2[0][2] = norm[0][2];
	               norm2++;
	               norm++;
	               }
	      }

	   if (active_window->perspective)
	      {
	      w = sfpoints[2 * num_upoints * num_vpoints];
	      w2 = sfpoints[2 * (*num_upoints2) * (*num_vpoints2)];
	      for (i = 0; i < num_vpoints; i++)
	         for (j = 0; j < num_upoints; j++)
	            if (v_delflags[i] || u_delflags[j])
	               {
	               w++;
	               }
	            else
	               {
	               *w2++ = *w++;
	               }
	      }

	   }  /* end: else */

	}  /* HSdelete_sample_points */


/*--- HSclear_knot_lo_bits ------------------------------------------------------*/

static void	HSclear_knot_lo_bits( IGRlong num_knots, IGRdouble *knots )

/*
NAME
	HSclear_knot_lo_bits (static)

DESCRIPTION
	Clear the low 4 bits of the mantissa for every knot in both
	the original and new knot vectors.  This fact will be used
	later for B-spline surfaces with boundaries to insure a 
	boundary point never lies exactly on a UV knot intersection.

PARAMETERS
	num_knots (IN) - number of knots
	knots (IN/OUT) - array of knots

GLOBALS USED
	none

HISTORY
	02/07/87   S.A. Rapa
	   Created
	02/10/92    S.P. Rogers
	   Added prologue documentation
*/

	{
	IGRint		i;

	for( i=0; i<num_knots; i++ )
		{
		CLEAR_LO_BITS( &knots[i] );
		}

	}  /* HSclear_knot_lo_bits */


/*--- HScompute_facet_normal ----------------------------------------------*/

static void	HScompute_facet_normal(	IGRpoint *sfpoints,
				       IGRdouble *w,
					  IGRint lo_u_lo_v,
					  IGRint lo_u_hi_v,
					  IGRint hi_u_lo_v,
					  IGRint hi_u_hi_v )

/*
NAME
	HScompute_facet_normal (static)

DESCRIPTION
	This function computes a global facet normal in such a way that
	it agrees in direction with the surface normals.

PARAMETERS
	sfpoints (IN) - array of surface points
	w (IN) - array of w values
	lo_u_lo_v (IN) - lower left index of facet
	lo_u_hi_v (IN) - upper left index of facet
	hi_u_lo_v (IN) - lower right index of facet
	hi_u_hi_v (IN) - upper right index of facet

GLOBALS USED
	element_parms - facet normals are set	

HISTORY
	01/20/87    S.A. Rapa
	   Created
	02/10/92    S.P. Rogers
	   Added prologue documentation
*/

	{
	IGRdouble	u_partial[3], v_partial[3];

	u_partial[0] =	(sfpoints[hi_u_lo_v][0] - sfpoints[lo_u_lo_v][0]) +
			(sfpoints[hi_u_hi_v][0] - sfpoints[lo_u_hi_v][0]);
	u_partial[1] =	(sfpoints[hi_u_lo_v][1] - sfpoints[lo_u_lo_v][1]) +
			(sfpoints[hi_u_hi_v][1] - sfpoints[lo_u_hi_v][1]);

	v_partial[0] =	(sfpoints[lo_u_hi_v][0] - sfpoints[lo_u_lo_v][0]) +
			(sfpoints[hi_u_hi_v][0] - sfpoints[hi_u_lo_v][0]);
	v_partial[1] =	(sfpoints[lo_u_hi_v][1] - sfpoints[lo_u_lo_v][1]) +
			(sfpoints[hi_u_hi_v][1] - sfpoints[hi_u_lo_v][1]);


	if ( (active_window->perspective) && (!active_window->making_triangles) )
		{
			
		/*
		 * In the case of perspective, W's are the same as Z's before
		 * the perspective transformation has been applied.
		 */

		u_partial[2] =	(w[hi_u_lo_v] - w[lo_u_lo_v]) +
				(w[hi_u_hi_v] - w[lo_u_hi_v]);
		v_partial[2] =	(w[lo_u_hi_v] - w[lo_u_lo_v]) +
				(w[hi_u_hi_v] - w[hi_u_lo_v]);
		}
	else
		{
		u_partial[2] =	(sfpoints[hi_u_lo_v][2] - sfpoints[lo_u_lo_v][2]) +
				(sfpoints[hi_u_hi_v][2] - sfpoints[lo_u_hi_v][2]);
		v_partial[2] =	(sfpoints[lo_u_hi_v][2] - sfpoints[lo_u_lo_v][2]) +
				(sfpoints[hi_u_hi_v][2] - sfpoints[hi_u_lo_v][2]);
		}

	HSset_facet_normal( ((u_partial[1] * v_partial[2]) - (u_partial[2] * v_partial[1])),
			    ((u_partial[2] * v_partial[0]) - (u_partial[0] * v_partial[2])),
			    ((u_partial[0] * v_partial[1]) - (u_partial[1] * v_partial[0])) );

	if ( (active_window->perspective) && (!active_window->making_triangles) )
	   HSsave_and_scale_facet_normal();
	}  /* HScompute_facet_normal */


/*---HSgenerate_fem_polygons-----------------------------------------------*/

static void HSgenerate_fem_polygons( IGRint num_upoints,
				     IGRint num_vpoints,
				  IGRdouble *upoints,
				  IGRdouble *vpoints,
				   IGRpoint *sfpoints )

/*
NAME
	HSgenerate_fem_polygons (static)

DESCRIPTION
	This routine generates polygons from a FEM tile.  Its function
	is similar to that of "generate_surf_polygons."

PARAMETERS
	num_upoints (IN) - # of mesh points in U
	num_vpoints (IN) - # of mesh points in V
	upoints (IN) - array of U points
	vpoints (IN) - array of V points
	sfpoints (IN) - 2D array of surface points

GLOBALS USED
	HSfem_doing_mesh_lines (static)
	HSfem_local_data (static)
	
HISTORY
	03/20/89     C.M. Jablonski
	   Created
	02/10/92    S.P. Rogers
	   Added prologue documentation
*/

	{
	IGRint		u_cnt, v_cnt;
	IGRint		lo_u_lo_v, lo_u_hi_v;
	IGRint		hi_u_lo_v, hi_u_hi_v;
	IGRint		w_offset;
	IGRboolean	natural_top, natural_bottom, natural_left, natural_right;
	IGRdouble	d0, d1, d2, d3;
	unsigned char	s0, s1, s2, s3;
	int		i0, i1, i2, i3;
	IGRboolean	triangle;


	natural_top = natural_bottom = natural_left = natural_right = FALSE;
	w_offset = num_upoints * num_vpoints * 2;

	/* determine whether or not this is a triangular tile */
	lo_u_lo_v = 0;
	hi_u_lo_v = num_upoints - 1;
	hi_u_hi_v = (num_upoints * num_vpoints) - 1;
	lo_u_hi_v = hi_u_hi_v - num_upoints + 1;
	triangle =	POINTS_ARE_EQUAL(sfpoints[lo_u_hi_v], sfpoints[hi_u_hi_v]) ||
			POINTS_ARE_EQUAL(sfpoints[hi_u_hi_v], sfpoints[hi_u_lo_v]) ||
			POINTS_ARE_EQUAL(sfpoints[hi_u_lo_v], sfpoints[lo_u_lo_v]) ||
			POINTS_ARE_EQUAL(sfpoints[lo_u_lo_v], sfpoints[lo_u_hi_v]);

	for( v_cnt=1; v_cnt<num_vpoints; v_cnt++ )
		{
		lo_u_hi_v = v_cnt * num_upoints;
 		lo_u_lo_v = lo_u_hi_v - num_upoints;
		hi_u_hi_v = lo_u_hi_v + 1;
		hi_u_lo_v = lo_u_lo_v + 1;

		for( u_cnt=1; u_cnt<num_upoints; u_cnt++ )
			{
			/* set the natural edge flags */
			if (HSfem_doing_mesh_lines)
				{
				natural_top = ((1.0 - vpoints[v_cnt]) <= element_parms.basis_tol);
				natural_bottom = (vpoints[v_cnt - 1] <= element_parms.basis_tol);
				natural_left = (upoints[u_cnt - 1] <= element_parms.basis_tol);
				natural_right = ((1.0 - upoints[u_cnt]) <= element_parms.basis_tol);
#if DEBUG
				fprintf( stderr, "top, bottom, left, right = %x, %x, %x, %x\n",
					natural_top, natural_bottom, natural_left, natural_right );
				fprintf( stderr, "num_upoints = %d\tu_cnt = %d\n", num_upoints, u_cnt );
				fprintf( stderr, "num_vpoints = %d\tv_cnt = %d\n", num_vpoints, v_cnt );
				fprintf( stderr, "basis_tol = %lf\n", element_parms.basis_tol );
				fprintf( stderr, "ulo, uhi = %lf, %lf\tvlo, vhi = %lf, %lf\n",
					upoints[u_cnt-1], upoints[u_cnt], vpoints[v_cnt-1],
					vpoints[v_cnt] );
#endif
				}

			/* setup the shading factors.  NOTE: the shading factor calculations
			   use percents that are modified the same way that the percents
			   will be modified in the polybuster. */
			d0 = (double)(HSfem_local_fem_data->color_shade[lo_u_lo_v] >> 7);
			d1 = (double)(HSfem_local_fem_data->color_shade[hi_u_lo_v] >> 7);
			d2 = (double)(HSfem_local_fem_data->color_shade[lo_u_hi_v] >> 7);
			d3 = (double)(HSfem_local_fem_data->color_shade[hi_u_hi_v] >> 7);
			s0 = (unsigned char)(d0 + 0.5);
			s1 = (unsigned char)(d1 + 0.5);
			s2 = (unsigned char)(d2 + 0.5);
			s3 = (unsigned char)(d3 + 0.5);

			i0 = (int)(((s0 * 65536.0 / 255.0) + 0.5) * tiling_parms.apparent_shades_fem);
			i1 = (int)(((s1 * 65536.0 / 255.0) + 0.5) * tiling_parms.apparent_shades_fem);
			i2 = (int)(((s2 * 65536.0 / 255.0) + 0.5) * tiling_parms.apparent_shades_fem);
			i3 = (int)(((s3 * 65536.0 / 255.0) + 0.5) * tiling_parms.apparent_shades_fem);
			HSset_element_fem_parms(	triangle,
							(i2 - i0) / 65536.0,
							(((i3 - i1) / 65536.0) -
							 ((i2 - i0) / 65536.0)) /
							16777216.0,
							(i1 - i0) / 65536.0 );

			/* build facet & process */
			construct_fem_facet( sfpoints, lo_u_lo_v, 0.0, 0.0, HSfem_local_fem_data->color_shade[lo_u_lo_v], natural_left, w_offset );
			construct_fem_facet( sfpoints, lo_u_hi_v, 0.0, 1.0, HSfem_local_fem_data->color_shade[lo_u_hi_v], natural_top, w_offset );
			construct_fem_facet( sfpoints, hi_u_hi_v, 1.0, 1.0, HSfem_local_fem_data->color_shade[hi_u_hi_v], natural_right, w_offset );
			construct_fem_facet( sfpoints, hi_u_lo_v, 1.0, 0.0, HSfem_local_fem_data->color_shade[hi_u_lo_v], natural_bottom, w_offset );

			clip_and_shade();

			lo_u_lo_v++;
			lo_u_hi_v++;
			hi_u_hi_v++;
			hi_u_lo_v++;
			}
		}
	}


/*---HSgenerate_surface_mesh----------------------------------------*/

static void HSgenerate_surface_mesh( IGRint num_upoints,
				     IGRint num_vpoints,
				   IGRpoint *sfpoints )

/*
NAME
	HSgenerate_surface_mesh (static)

DESCRIPTION
	Builds a mesh for a region of the surface.  This region is assumed to
	not contain any boundaries; thus the vertices are simply the region's
	mesh of points. 

PARAMETERS
	num_upoints (IN) - # of mesh points in U
	num_vpoints (IN) - # of mesh points in V
	sfpoints (IN) - 2D array of surface points

GLOBALS USED
	element_parms

HISTORY
	03/28/90	C.M. Jablonski
	   Created
	02/10/92    S.P. Rogers
	   Added prologue documentation
*/

	{
	IGRint		u_cnt, v_cnt;
	IGRint		lo_u_lo_v, lo_u_hi_v;
	IGRint		hi_u_lo_v, hi_u_hi_v;
	IGRint		total_points;

	total_points = num_upoints * num_vpoints;

	for( v_cnt=1; v_cnt<num_vpoints; v_cnt++ )
		{
		lo_u_hi_v = v_cnt * num_upoints;
		lo_u_lo_v = lo_u_hi_v - num_upoints;
		hi_u_hi_v = lo_u_hi_v + 1;
		hi_u_lo_v = lo_u_lo_v + 1;

		/* add the first two vertices to the trimesh */
		if (element_parms.facet_type == SMOOTH_SHADE)
			{
			HSadd_vertex_to_buffered_trimesh( sfpoints[lo_u_lo_v], sfpoints[total_points + lo_u_lo_v], NULL );
			HSadd_vertex_to_buffered_trimesh( sfpoints[lo_u_hi_v], sfpoints[total_points + lo_u_hi_v], NULL );
			}
		else
			{
			HSadd_vertex_to_buffered_trimesh( sfpoints[lo_u_lo_v], NULL, NULL );
			HSadd_vertex_to_buffered_trimesh( sfpoints[lo_u_hi_v], NULL, NULL );
			}

		for( u_cnt=1; u_cnt<num_upoints; u_cnt++ )
			{
			HScompute_facet_normal( 
				sfpoints, sfpoints[total_points + total_points],
				lo_u_lo_v, lo_u_hi_v,
				hi_u_lo_v, hi_u_hi_v );

			HSnormalize_facet_normal();

			/* add these two vertices to the trimesh */
			if (element_parms.facet_type == SMOOTH_SHADE)
				{
				HSadd_vertex_to_buffered_trimesh( sfpoints[hi_u_lo_v], sfpoints[total_points + hi_u_lo_v], element_parms.facet_normal );
				HSadd_vertex_to_buffered_trimesh( sfpoints[hi_u_hi_v], sfpoints[total_points + hi_u_hi_v], element_parms.facet_normal );
				}
			else
				{
				HSadd_vertex_to_buffered_trimesh( sfpoints[hi_u_lo_v], NULL, element_parms.facet_normal );
				HSadd_vertex_to_buffered_trimesh( sfpoints[hi_u_hi_v], NULL, element_parms.facet_normal );
				}

			lo_u_lo_v++;
			lo_u_hi_v++;
			hi_u_hi_v++;
			hi_u_lo_v++;
			}

		/* display the trimesh */
		HSdisplay_buffered_trimesh();
		}
	}


/*---HSgenerate_surface_polygons-----------------------------------------*/

static void HSgenerate_surface_polygons( IGRint num_upoints, 
					 IGRint num_vpoints, 
				       IGRpoint *sfpoints, 
				     IGRboolean *normdir, 
				     IGRboolean u_closed, 
				     IGRboolean v_closed, 
				      IGRdouble ulo, 
				      IGRdouble vlo, 
				      IGRdouble vhi, 
				      IGRdouble *upoints, 
				      IGRdouble *vpoints)

/*
NAME
	HSgenerate_surface_polygons (static)

DESCRIPTION
	Builds a list of facets for a region of the surface.  This region
	is assumed to not contain any boundaries; thus the facets created are
	simply the 4-sided polygons defined by that region's mesh of points.
	After each facet is built it is processed by "clip_and_shade".

PARAMETERS
	num_upoints (IN) - # of mesh points in U
	num_vpoints (IN) - # of mesh points in V
	sfpoints (IN) - 2-D array of surface points
	normdir (IN) - 2-D array to hold normal directions
	u_closed (IN) - surface U physically closed flag
	v_closed (IN) - surface V physically closed flag
	ulo (IN) - U lo range for this region
	vlo (IN) - V lo range for this region
	vhi (IN) - V hi range for this region
	upoints (IN) - array of sample points in U
	vpoints (IN) - array of sample points in V

GLOBALS USED
	active_window
	element_parms

HISTORY
	09/01/86     S.A. Rapa
	   created
	02/07/87     S.A. Rapa
	   Replaced pipe with "clip_and_shade"
	05/15/89     C.M. Jablonski
	   Added normdir and edge marking
	09/28/89     C.M. Jablonski
	   Mark BOTH edges for each parting line and 
	   added u/vnorm_first, u/vnorm_index.
	02/10/92    S.P. Rogers
	   Added prologue documentation
*/

	{
	IGRint		u_cnt, v_cnt;
	IGRint		lo_u_lo_v, lo_u_hi_v;
	IGRint		hi_u_lo_v, hi_u_hi_v;
	IGRint		total_points;
	IGRboolean	top_mark = FALSE, bottom_mark = FALSE, left_mark = FALSE, right_mark = FALSE;
	IGRdouble	eye_vector[3], *w;

	total_points = num_upoints * num_vpoints;
	w = sfpoints[total_points + total_points];

	/* Initialize this section of the normal direction matrix */
	if( element_parms.marking_edges )
		{
		for( v_cnt=1; v_cnt<num_vpoints; v_cnt++ )
			{
			lo_u_hi_v = v_cnt * num_upoints;
			lo_u_lo_v = lo_u_hi_v - num_upoints;
			hi_u_hi_v = lo_u_hi_v + 1;
			hi_u_lo_v = lo_u_lo_v + 1;

			for( u_cnt=1; u_cnt<num_upoints; u_cnt++ )
				{
				HScompute_facet_normal( 
					sfpoints, sfpoints[total_points + total_points],
					lo_u_lo_v, lo_u_hi_v,
					hi_u_lo_v, hi_u_hi_v );

				/* save the normal direction */
				eye_vector[0] = sfpoints[lo_u_lo_v][0];
				eye_vector[1] = sfpoints[lo_u_lo_v][1];
				eye_vector[2] = w[lo_u_lo_v];
				normdir[lo_u_lo_v] = front_facing_facet( active_window->perspective,
									eye_vector );
				lo_u_lo_v++;
				lo_u_hi_v++;
				hi_u_hi_v++;
				hi_u_lo_v++;
				}
			}
		}

	for( v_cnt=1; v_cnt<num_vpoints; v_cnt++ )
		{
		lo_u_hi_v = v_cnt * num_upoints;
		lo_u_lo_v = lo_u_hi_v - num_upoints;
		hi_u_hi_v = lo_u_hi_v + 1;
		hi_u_lo_v = lo_u_lo_v + 1;

		for( u_cnt=1; u_cnt<num_upoints; u_cnt++ )
			{
			HScompute_facet_normal( 
				sfpoints, sfpoints[total_points + total_points],
				lo_u_lo_v, lo_u_hi_v,
				hi_u_lo_v, hi_u_hi_v );

			/* set the edge marks */
			if( element_parms.marking_edges )
				{
				if (v_cnt == (num_vpoints - 1))
					{
					if (!(top_mark = (vhi != 1.0)))
						{
						if (!(top_mark = !(v_closed)))
							{
							top_mark = (normdir[lo_u_lo_v] != unorm_first[unorm_index + u_cnt - 1]);
							}
						}
					}
				else
					top_mark = (normdir[lo_u_lo_v] != normdir[lo_u_lo_v + num_upoints]);

				if (u_cnt == (num_upoints - 1))
					{
					if (!(right_mark = (vhi != 1.0)))
						{
						if (!(right_mark = !(u_closed)))
							{
							right_mark = (normdir[lo_u_lo_v] != vnorm_first[vnorm_index + v_cnt - 1]);
							}
						}
					}
				else
					right_mark = (normdir[lo_u_lo_v] != normdir[lo_u_lo_v + 1]);

				if (v_cnt == 1)
					{
					if (!(bottom_mark = (vlo != 0.0)))
						{
						if (!(bottom_mark = !(v_closed)))
							unorm_first[unorm_index + u_cnt - 1] = normdir[lo_u_lo_v];
						}
					}
				else
					bottom_mark = (normdir[lo_u_lo_v] != normdir[lo_u_lo_v - num_upoints]);

				if (u_cnt == 1)
					{
					if (!(left_mark = (ulo != 0.0)))
						{
						if (!(left_mark = !(u_closed)))
							vnorm_first[vnorm_index + v_cnt - 1] = normdir[lo_u_lo_v];
						}
					}
				else
					left_mark = (normdir[lo_u_lo_v] != normdir[lo_u_lo_v - 1]);
				}

			/*
			 * Build facet & process
			 */

			switch( element_parms.render_parms->texture_orientation )
				{
				case 2:
				case 8:
					construct_facet( 
						sfpoints, 
						lo_u_lo_v, 
						total_points, 
						left_mark,
						upoints[u_cnt-1], 1.0-vpoints[v_cnt-1] );
				
					construct_facet( 
						sfpoints, 
						lo_u_hi_v, 
						total_points, 
						top_mark,
						upoints[u_cnt-1], 1.0-vpoints[v_cnt] );
				
					construct_facet( 
						sfpoints, 
						hi_u_hi_v, 
						total_points, 
						right_mark,
						upoints[u_cnt], 1.0-vpoints[v_cnt] );
				
					construct_facet( 
						sfpoints, 
						hi_u_lo_v, 
						total_points, 
						bottom_mark,
						upoints[u_cnt], 1.0-vpoints[v_cnt-1] );
						
					break;

				case 3:
				case 5:
					construct_facet( 
						sfpoints, 
						lo_u_lo_v, 
						total_points, 
						left_mark,
						1.0-upoints[u_cnt-1], vpoints[v_cnt-1] );
				
					construct_facet( 
						sfpoints, 
						lo_u_hi_v, 
						total_points, 
						top_mark,
						1.0-upoints[u_cnt-1], vpoints[v_cnt] );
				
					construct_facet( 
						sfpoints, 
						hi_u_hi_v, 
						total_points, 
						right_mark,
						1.0-upoints[u_cnt], vpoints[v_cnt] );
				
					construct_facet( 
						sfpoints, 
						hi_u_lo_v, 
						total_points, 
						bottom_mark,
						1.0-upoints[u_cnt], vpoints[v_cnt-1] );
						
					break;

				case 4:
				case 7:
					construct_facet( 
						sfpoints, 
						lo_u_lo_v, 
						total_points, 
						left_mark,
						1.0-upoints[u_cnt-1], 1.0-vpoints[v_cnt-1] );
				
					construct_facet( 
						sfpoints, 
						lo_u_hi_v, 
						total_points, 
						top_mark,
						1.0-upoints[u_cnt-1], 1.0-vpoints[v_cnt] );
				
					construct_facet( 
						sfpoints, 
						hi_u_hi_v, 
						total_points, 
						right_mark,
						1.0-upoints[u_cnt], 1.0-vpoints[v_cnt] );
				
					construct_facet( 
						sfpoints, 
						hi_u_lo_v, 
						total_points, 
						bottom_mark,
						1.0-upoints[u_cnt], 1.0-vpoints[v_cnt-1] );
						
					break;

				case 0:
				case 1:
				case 6:
				default:
					construct_facet( 
						sfpoints, 
						lo_u_lo_v, 
						total_points, 
						left_mark,
						upoints[u_cnt-1], vpoints[v_cnt-1] );
				
					construct_facet( 
						sfpoints, 
						lo_u_hi_v, 
						total_points, 
						top_mark,
						upoints[u_cnt-1], vpoints[v_cnt] );
				
					construct_facet( 
						sfpoints, 
						hi_u_hi_v, 
						total_points, 
						right_mark,
						upoints[u_cnt], vpoints[v_cnt] );
				
					construct_facet( 
						sfpoints, 
						hi_u_lo_v, 
						total_points, 
						bottom_mark,
						upoints[u_cnt], vpoints[v_cnt-1] );
						
					break;
				}									

#if EDGEII_DEBUG
			fprintf( stderr, "Here comes facet %d with no boundaries\n", ++NoBounds );
#endif

			(*active_window->prepare_facet[active_window->active_zbuffer])();

			lo_u_lo_v++;
			lo_u_hi_v++;
			hi_u_hi_v++;
			hi_u_lo_v++;
			}
		}
	}


/*---HSgenerate_surf_with_bound_polygons--------------------------------------*/

static void HSgenerate_surf_with_bound_polygons( IGRint num_upoints, 
						 IGRint num_vpoints, 
					      IGRdouble *upoints, 
					      IGRdouble *vpoints, 
					       IGRpoint *sfpoints, 
					     IGRboolean *normdir, 
					     IGRboolean u_closed, 
					     IGRboolean v_closed, 
					 struct HSbound *patch_bounds[], 
						 IGRint *patch_index, 
					     IGRboolean *u_skip_flags, 
					     IGRboolean *v_skip_flags, 
					     IGRboolean origin_status, 
					     IGRboolean *next_u_status,
					     IGRboolean *next_v_status)			    

/*
NAME
	HSgenerate_surf_with_bound_polygons (static)

DESCRIPTION
	If a region of a surface to be tiled is cut by some boundaries, this
	routine is called instead of 'HSgenerate_surface_polygons' (their
	purposes are identical). 'Region' here means an area of the surface
	bounded by logically sharp knots.

PARAMETERS
	num_upoints (IN) - # of mesh points in U
	num_vpoints (IN) - # of mesh points in V
	sfpoints (IN) -	2-D array of surface points
	normdir (IN) - 2-D array for normal directions
	u_closed (IN) - surface U physically closed flag
	v_closed (IN) - surface V physically closed flag
	upoints	(IN) - array of U points
	vpoints	(IN) - array of V points
	patch_bounds (IN) - list of bounds per patch
	patch_index (IN/OUT) - current patch being processed
	u_skip_flags (IN) - array of U facet skipping flags
	v_skip_flags (IN) - array of V facet skipping flags
	origin_status (IN) - origin of region is in a solid
	next_u_status (OUT) - next region in U starts solid
	next_v_status (OUT) - next region in V starts solid
	
GLOBALS USED
	element_parms
	active_window
	
HISTORY
	09/01/86    S.A. Rapa
	   created
	02/07/87    S.A. Rapa
	   Replace pipe with "clip_and_shade".
	05/15/89    C.M. Jablonski
	   Added normdir and edge marking.
	09/28/89    C.M. Jablonski
	   Mark BOTH edges for each parting line,
	   added u/vnorm_first, u/vnorm_index.
	02/10/92    S.P. Rogers
	   Added u_skip_flags, v_skip_flags to replace skip_ulo, skip_uhi, etc.
           to fix TR 92n0793,  see Notebook IX, pg. 22 and added prologue documentation
*/

	{
	IGRint		u_cnt, v_cnt;
	IGRint		lo_u_lo_v, lo_u_hi_v;
	IGRint		hi_u_lo_v, hi_u_hi_v;
	IGRint		norm_off;
	IGRboolean	next_horizontal_status = FALSE;
	IGRboolean	next_vertical_status = FALSE;
	IGRboolean	this_corner_status;
	struct HSbound	*these_bounds;
	IGRboolean	top_mark = FALSE, bottom_mark = FALSE, left_mark = FALSE, right_mark = FALSE;
	IGRdouble	eye_vector[3], *w;
	IGRboolean	build_v_facet, build_uv_facet;

	norm_off = num_upoints * num_vpoints;
	next_vertical_status = origin_status;

	w = sfpoints[norm_off + norm_off];

	/* Initialize this section of the normal direction matrix */
	if( element_parms.marking_edges )
		{
		for( v_cnt=1; v_cnt<num_vpoints; v_cnt++ )
			{
			lo_u_hi_v = v_cnt * num_upoints;
			lo_u_lo_v = lo_u_hi_v - num_upoints;
			hi_u_hi_v = lo_u_hi_v + 1;
			hi_u_lo_v = lo_u_lo_v + 1;

			for( u_cnt=1; u_cnt<num_upoints; u_cnt++ )
				{
				HScompute_facet_normal( 
					sfpoints, sfpoints[norm_off + norm_off],
					lo_u_lo_v, lo_u_hi_v,
					hi_u_lo_v, hi_u_hi_v );

				/* save the normal direction */
				eye_vector[0] = sfpoints[lo_u_lo_v][0];
				eye_vector[1] = sfpoints[lo_u_lo_v][1];
				eye_vector[2] = w[lo_u_lo_v];
				normdir[lo_u_lo_v] = front_facing_facet( active_window->perspective,
									eye_vector );
				lo_u_lo_v++;
				lo_u_hi_v++;
				hi_u_hi_v++;
				hi_u_lo_v++;
				}
			}
		}

	for( v_cnt=1; v_cnt<num_vpoints; v_cnt++ )
		{
		build_v_facet = ! v_skip_flags[v_cnt - 1];

		/* 
		 * Get indexes of this tile's corner points.
		 */

		lo_u_hi_v = v_cnt * num_upoints;
		lo_u_lo_v = lo_u_hi_v - num_upoints;
		hi_u_hi_v = lo_u_hi_v + 1;
		hi_u_lo_v = lo_u_lo_v + 1;

		for( u_cnt=1; u_cnt<num_upoints; u_cnt++ )
			{
			build_uv_facet = build_v_facet &&
			                 (! u_skip_flags[u_cnt-1]);

			these_bounds = patch_bounds [*patch_index];
			*patch_index += 1;

			/*
			 * Determine if the lower-left corner of this tile is in a
			 * hole or not.
			 */

			if( u_cnt == 1 )
				{
				this_corner_status = next_vertical_status;
				next_vertical_status = get_vertical_status(
								upoints[u_cnt - 1],
								these_bounds,
								this_corner_status);
				}
			else
				{
				this_corner_status = next_horizontal_status;
	   			}

			next_horizontal_status = get_horizontal_status(
							vpoints[v_cnt - 1],
							these_bounds,
							this_corner_status);

        		if( these_bounds != NIL_BOUND )
				{
				HScompute_facet_normal( 
					sfpoints, sfpoints[norm_off + norm_off],
					lo_u_lo_v, lo_u_hi_v,
					hi_u_lo_v, hi_u_hi_v );

				/* set the edge marks */
				if( element_parms.marking_edges )
					{
					if (v_cnt == (num_vpoints - 1))
						{
						if (!(top_mark = (vpoints[num_vpoints - 1] != 1.0)))
							{
							if (!(top_mark = !(v_closed)))
								{
								top_mark = (normdir[lo_u_lo_v] != unorm_first[unorm_index + u_cnt - 1]);
								}
							}
						}
					else
						top_mark = (normdir[lo_u_lo_v] != normdir[lo_u_lo_v + num_upoints]);

					if (u_cnt == (num_upoints - 1))
						{
						if (!(right_mark = (upoints[num_upoints - 1] != 1.0)))
							{
							if (!(right_mark = !(u_closed)))
								{
								right_mark = (normdir[lo_u_lo_v] != vnorm_first[vnorm_index + v_cnt - 1]);
								}
							}
						}
					else
						right_mark = (normdir[lo_u_lo_v] != normdir[lo_u_lo_v + 1]);

					if (v_cnt == 1)
						{
						if (!(bottom_mark = (vpoints[0] != 0.0)))
							{
							if (!(bottom_mark = !(v_closed)))
								unorm_first[unorm_index + u_cnt - 1] = normdir[lo_u_lo_v];
							}
						}
					else
						bottom_mark = (normdir[lo_u_lo_v] != normdir[lo_u_lo_v - num_upoints]);

					if (u_cnt == 1)
						{
						if (!(left_mark = (upoints[0] != 0.0)))
							{
							if (!(left_mark = !(u_closed)))
								vnorm_first[vnorm_index + v_cnt - 1] = normdir[lo_u_lo_v];
							}
						}
					else
						left_mark = (normdir[lo_u_lo_v] != normdir[lo_u_lo_v - 1]);
					}
							
				if (build_uv_facet)
					{
					construct_polygons( 
						upoints[u_cnt - 1],
						vpoints[v_cnt - 1],
						upoints[u_cnt],
						vpoints[v_cnt],
						sfpoints, norm_off,
						lo_u_lo_v, lo_u_hi_v,
						hi_u_hi_v, hi_u_lo_v,
		    				these_bounds,
						this_corner_status,
						left_mark, top_mark, right_mark, bottom_mark );
					}
				}
			else
				{
				if( this_corner_status == TRUE )
					{
						
					/*
					 * If this tile patch is not cut by any boundaries,
					 * process it the same way 'HSgenerate_surface_polygons'
					 * would.
					 */

#if PLOT_BOUNDS
{
/* draw this solid facet */
PBset_color(7);
PBclip_and_draw_line(upoints[u_cnt - 1], vpoints[v_cnt - 1], upoints[u_cnt - 1], vpoints[v_cnt]);
PBclip_and_draw_line(upoints[u_cnt - 1], vpoints[v_cnt], upoints[u_cnt], vpoints[v_cnt]);
PBclip_and_draw_line(upoints[u_cnt], vpoints[v_cnt], upoints[u_cnt], vpoints[v_cnt - 1]);
PBclip_and_draw_line(upoints[u_cnt], vpoints[v_cnt - 1], upoints[u_cnt - 1], vpoints[v_cnt - 1]);
}
#endif
					HScompute_facet_normal( 
						sfpoints, sfpoints[norm_off + norm_off],
						lo_u_lo_v, lo_u_hi_v,
						hi_u_lo_v, hi_u_hi_v );


					/* if making triangles, directly mesh this facet */
					if ( active_window->making_triangles )
						{
						HSnormalize_facet_normal();

						/* set the trimesh vertices */
						if (element_parms.facet_type == SMOOTH_SHADE)
							{
							HSadd_vertex_to_buffered_trimesh( sfpoints[lo_u_lo_v], sfpoints[norm_off + lo_u_lo_v], NULL );
							HSadd_vertex_to_buffered_trimesh( sfpoints[lo_u_hi_v], sfpoints[norm_off + lo_u_hi_v], NULL );
							HSadd_vertex_to_buffered_trimesh( sfpoints[hi_u_lo_v], sfpoints[norm_off + hi_u_lo_v], element_parms.facet_normal );
							HSadd_vertex_to_buffered_trimesh( sfpoints[hi_u_hi_v], sfpoints[norm_off + hi_u_hi_v], element_parms.facet_normal );
							}
						else
							{
							HSadd_vertex_to_buffered_trimesh( sfpoints[lo_u_lo_v], NULL, NULL );
							HSadd_vertex_to_buffered_trimesh( sfpoints[lo_u_hi_v], NULL, NULL );
							HSadd_vertex_to_buffered_trimesh( sfpoints[hi_u_lo_v], NULL, element_parms.facet_normal );
							HSadd_vertex_to_buffered_trimesh( sfpoints[hi_u_hi_v], NULL, element_parms.facet_normal );
							}

						/* display the trimesh */
						HSdisplay_buffered_trimesh();
						}
					else
						{
						/* set the edge marks */
						if( element_parms.marking_edges )
							{
							if (v_cnt == (num_vpoints - 1))
								{
								if (!(top_mark = (vpoints[num_vpoints - 1] != 1.0)))
									{
									if (!(top_mark = !(v_closed)))
										{
										top_mark = (normdir[lo_u_lo_v] != unorm_first[unorm_index + u_cnt - 1]);
										}
									}
								}
							else
								top_mark = (normdir[lo_u_lo_v] != normdir[lo_u_lo_v + num_upoints]);

							if (u_cnt == (num_upoints - 1))
								{
								if (!(right_mark = (upoints[num_upoints - 1] != 1.0)))
									{
									if (!(right_mark = !(u_closed)))
										{
										right_mark = (normdir[lo_u_lo_v] != vnorm_first[vnorm_index + v_cnt - 1]);
										}
									}
								}
							else
								right_mark = (normdir[lo_u_lo_v] != normdir[lo_u_lo_v + 1]);

							if (v_cnt == 1)
								{
								if (!(bottom_mark = (vpoints[0] != 0.0)))
									{
									if (!(bottom_mark = !(v_closed)))
										unorm_first[unorm_index + u_cnt - 1] = normdir[lo_u_lo_v];
									}
								}
							else
								bottom_mark = (normdir[lo_u_lo_v] != normdir[lo_u_lo_v - num_upoints]);

							if (u_cnt == 1)
								{
								if (!(left_mark = (upoints[0] != 0.0)))
									{
									if (!(left_mark = !(u_closed)))
										vnorm_first[vnorm_index + v_cnt - 1] = normdir[lo_u_lo_v];
									}
								}
							else
								left_mark = (normdir[lo_u_lo_v] != normdir[lo_u_lo_v - 1]);
							}

						if (build_uv_facet)
							{
							/*
						 	* Build facet & process
						 	*/

						switch( element_parms.render_parms->texture_orientation )
							{
							case 2:
							case 8:
								construct_facet( 
									sfpoints, 
									lo_u_lo_v, 
									norm_off,
									left_mark,
									upoints[u_cnt-1], 1.0-vpoints[v_cnt-1] );
				
								construct_facet( 
									sfpoints, 
									lo_u_hi_v, 
									norm_off, 
									top_mark,
									upoints[u_cnt-1], 1.0-vpoints[v_cnt] );
				
								construct_facet( 
									sfpoints, 
									hi_u_hi_v, 
									norm_off, 
									right_mark,
									upoints[u_cnt], 1.0-vpoints[v_cnt] );
				
								construct_facet( 
									sfpoints, 
									hi_u_lo_v, 
									norm_off, 
									bottom_mark,
									upoints[u_cnt], 1.0-vpoints[v_cnt-1] );
						
								break;

							case 3:
							case 5:
								construct_facet( 
									sfpoints, 
									lo_u_lo_v, 
									norm_off, 
									left_mark,
									1.0-upoints[u_cnt-1], vpoints[v_cnt-1] );
				
								construct_facet( 
									sfpoints, 
									lo_u_hi_v, 
									norm_off, 
									top_mark,
									1.0-upoints[u_cnt-1], vpoints[v_cnt] );
				
								construct_facet( 
									sfpoints, 
									hi_u_hi_v, 
									norm_off, 
									right_mark,
									1.0-upoints[u_cnt], vpoints[v_cnt] );
				
								construct_facet( 
									sfpoints, 
									hi_u_lo_v, 
									norm_off, 
									bottom_mark,
									1.0-upoints[u_cnt], vpoints[v_cnt-1] );
						
								break;

							case 4:
							case 7:
								construct_facet( 
									sfpoints, 
									lo_u_lo_v, 
									norm_off, 
									left_mark,
									1.0-upoints[u_cnt-1], 1.0-vpoints[v_cnt-1] );
				
								construct_facet( 
									sfpoints, 
									lo_u_hi_v, 
									norm_off, 
									top_mark,
									1.0-upoints[u_cnt-1], 1.0-vpoints[v_cnt] );
				
								construct_facet( 
									sfpoints, 
									hi_u_hi_v, 
									norm_off, 
									right_mark,
									1.0-upoints[u_cnt], 1.0-vpoints[v_cnt] );
				
								construct_facet( 
									sfpoints, 
									hi_u_lo_v, 
									norm_off, 
									bottom_mark,
									1.0-upoints[u_cnt], 1.0-vpoints[v_cnt-1] );
						
								break;

							case 0:
							case 1:
							case 6:
							default:
								construct_facet( 
									sfpoints, 
									lo_u_lo_v, 
									norm_off, 
									left_mark,
									upoints[u_cnt-1], vpoints[v_cnt-1] );
				
								construct_facet( 
									sfpoints, 
									lo_u_hi_v, 
									norm_off, 
									top_mark,
									upoints[u_cnt-1], vpoints[v_cnt] );
				
								construct_facet( 
									sfpoints, 
									hi_u_hi_v, 
									norm_off, 
									right_mark,
									upoints[u_cnt], vpoints[v_cnt] );
				
								construct_facet( 
									sfpoints, 
									hi_u_lo_v, 
									norm_off, 
									bottom_mark,
									upoints[u_cnt], vpoints[v_cnt-1] );
						
								break;
							}									

#if EDGEII_DEBUG
							fprintf( stderr, "Here comes facet %d with boundaries\n",
								++Bounds );
#endif

							(*active_window->prepare_facet[active_window->active_zbuffer])();
							}
						}
					}
#if PLOT_BOUNDS
else
{
/* dehilight this facet */
PBset_color(6);
PBclip_and_draw_line(upoints[u_cnt - 1], vpoints[v_cnt - 1], upoints[u_cnt - 1], vpoints[v_cnt]);
PBclip_and_draw_line(upoints[u_cnt - 1], vpoints[v_cnt], upoints[u_cnt], vpoints[v_cnt]);
PBclip_and_draw_line(upoints[u_cnt], vpoints[v_cnt], upoints[u_cnt], vpoints[v_cnt - 1]);
PBclip_and_draw_line(upoints[u_cnt], vpoints[v_cnt - 1], upoints[u_cnt - 1], vpoints[v_cnt - 1]);
}
#endif
				}
				
			lo_u_lo_v++;
			lo_u_hi_v++;
			hi_u_hi_v++;
			hi_u_lo_v++;
			}

		if( v_cnt == 1 ) *next_u_status = next_horizontal_status;
		}

	*next_v_status = next_vertical_status;
	}

	
/*--- HSdistribute_boundaries -----------------------------------------------------*/

static void HSdistribute_boundaries( struct HSbound *master_bounds,
					     IGRint num_upoints,
					     IGRint num_vpoints,
					  IGRdouble upoints[],
					  IGRdouble vpoints[],
				     struct HSbound *distributed_bounds[] )

/*
NAME
	HSdistribute_boundaries (static)

DESCRIPTION
	Uses all boundaries to build an array of boundary lists, where each array
	entry represents the boundaries which cut a mesh quad.  The array is set up
	so that entries are in the same order that their corresponding quads
	will be processed.

PARAMETERS
	master_bounds (IN) - master boundary list
	distributed_bounds (OUT) - array of boundary lists
	num_upoints (IN) - number of sample points in U
	num_vpoints (IN) - number of sample points in V
	upoints (IN) - array of U sample points
	vpoints (IN) - array of V sample points

GLOBALS USED
	tiling_parms

HISTORY
	09/01/86    S.A. Rapa
	   Created
	01/16/90    C.M. Jablonski
	   Separated region from patch processing
	02/10/92    S.P. Rogers
	   Added prologue documentation
*/

	{
	IGRint		u_patch, v_patch;
	IGRint		patch_index;

	patch_index = 0;
	for( v_patch = 0; v_patch < (num_vpoints - 1); v_patch++ )
		for( u_patch = 0; u_patch < (num_upoints - 1); u_patch++ )
			{
			distributed_bounds[patch_index++] = sift_boundaries(
								master_bounds,
								upoints[u_patch],
								vpoints[v_patch],
								upoints[u_patch + 1],
								vpoints[v_patch + 1] );

			if (tiling_parms.status != HSSTAT_OK) return;
			}
	}

	
#if DEBUG_SURFACE
/*---HSdump_surface--------------------------------------------------------*/

static HSdump_surface( struct IGRbsp_surface *surf )

/*
NAME
	HSdump_surface (static)

KEYWORD
	debug

DESCRIPTION
	Dumps out the surface definition to standard output. Debugging tool only.

PARAMETERS
	surf (IN) - the surface to dump out

GLOBALS USED
	none

HISTORY
	09/01/86    S.A. Rapa
	   created
	02/10/92    S.P. Rogers
	   Added prologue documentation and changed to use BSprintbsps()
*/

	{
	IGRchar name;

	BSprintbsps( stderr, &name, surf, FALSE );

	}
#endif


/*---HSset_surf_parms-----------------------------------------------------------*/

void	HSset_surf_parms ( IGRint color, IGRint options )

/*
NAME
	HSset_surf_parms

DESCRIPTION
	HSset_surf_parms sets the bspline surface tiling parameters
	according to the given color and option flags.

PARAMETERS
	color (IN) - the color of the surface
	options (IN) - tiling options flags

GLOBALS USED
	tiling_parms.processing_mode
	active_window

HISTORY
	05/11/88    C. M. Jablonski
	   Creation Date
	02/10/92    S.P. Rogers
	   Added prologue documentation
*/
 
	{
	/* set general parms */
	HSset_element_edge_marking_flag (options & (HS_BST_EDGES | HS_BST_REV_EDGES));

	/* set facet type */
	if( options & GR_BST_CONSTANT )
		HSset_element_facet_type( CONST_SHADE );
	else if( options & GR_BST_SMOOTH )
		HSset_element_facet_type( SMOOTH_SHADE );
	else if( options & HS_BST_EDGES  ) 
		HSset_element_facet_type( RASTER_EDGES );
	else if( options & HS_BST_REV_EDGES ) 
		HSset_element_facet_type( REV_EDGES );
	else
		HSset_element_facet_type( AREA_FILL );

	/* initialize paint routine */
	if (!(tiling_parms.processing_mode & HS_PMODE_FEEDBACK))
		if (tiling_parms.processing_mode & HS_PMODE_DEXEL)
			HSset_element_color( color );
	   	else
	      		(*active_window->init_paint[active_window->active_zbuffer]) (&color, &options );
	      		
	}


/*--- HSset_cull_flag ---------------------------------------------------------*/

static void HSset_cull_flag(	 struct IGRbsp_surface *geometry_ptr, 
					    IGRboolean from_solid, 
						IGRint options, 
					     IGRdouble range[])						     

/*
NAME
	HSset_cull_flag (static)

DESCRIPTION
	This function sets the back plane culling status flag.
	Back plane culling can occur if the surface is:
		1) not transparent,
		2) not near-z clipped,
		3) not area-filled,
		  AND
		4) its part of a solid

	Culling may be positive or negative, depending on the
	surface definition.

PARAMETERS
	geometry_ptr (IN) - surface geometry
	from_solid (IN) - flag indicating whether surface is from a solid
	options (IN) - tiling options word
	range (IN) - range of surface

GLOBALS USED
	element_parms
	tiling_parms
	active_window
	
HISTORY
	02/27/89	C.M. Jablonski
	   Created
	02/10/92    S.P. Rogers
	   Added prologue documentation
*/
 
{
	/*
	 * Set the back plane cull flag.  
	 */
	 
	if ( (!(options & GR_BST_TRANSP)) &&
	     (element_parms.facet_type != AREA_FILL) &&
	     (!(tiling_parms.processing_mode & HS_PMODE_RHL_SHOW_HIDDEN)) &&
	     /*(element_parms.facet_type != REV_EDGES) &&*/
	     (element_parms.facet_type != FEM_TILE) )
		{  /* surface is not transparent and not area filled */
		if (from_solid)	
			{  /* surface is part of a solid */
			if (geometry_ptr->pos_orient)
				HSset_element_cull_flag( HS_CULL_POSITIVE );
			else
				HSset_element_cull_flag( HS_CULL_NEGATIVE );
			}
		else   			
			HSset_element_cull_flag( HS_CULL_NONE );
		
		if ((element_parms.culling_back_planes != HS_CULL_NONE) &&
		    (!(tiling_parms.processing_mode & HS_PMODE_FEEDBACK)) &&
		    (active_window->z_min == active_window->dit_clip_range[2]))
			{
			if (NEAR_Z_CLIPPED)
				HSset_element_cull_flag( HS_CULL_NONE );
			}
 		}
	else
		HSset_element_cull_flag( HS_CULL_NONE );
}


/*--- HScheck_object_range ---------------------------------------------------------*/

static void	HScheck_object_range ( IGRdouble *range )

/*
NAME
	HScheck_object_range (static)

DESCRIPTION
	HScheck_object_range compares the z-range of the object to the
	z-range of the window.  If part of the object range falls outside
	the window z-range, then the user is notified that the object
	cannot be displayed in this window and FALSE is returned.
	(We cannot display objects that fall outside the z-range
	because they can't be represented in the z-buffer.)

PARAMETERS
	range (IN) - the range of the object

GLOBALS USED
	active_window

HISTORY
	07/20/89	C.M. Jablonski
	   Created
	02/10/92    S.P. Rogers
	   Added prologue documentation
*/
 
	{
	 if (((active_window->z_min != active_window->dit_clip_range[2]) &&
	      (NEAR_Z_CLIPPED)) ||
	     ((active_window->z_max != active_window->dit_clip_range[5]) &&
	      (FAR_Z_CLIPPED)))
		HSset_status( HSSTAT_OUT_OF_RANGE );

	}  /* HScheck_object_range */

/*--- HScompare_coordinates-----------------------------------------------*/

static void HScompare_coordinates( IGRint num_upoints,
				   IGRint num_vpoints,
				IGRdouble *upoints,
				IGRdouble *vpoints,
				 IGRpoint *sfpoints )

/*
NAME
	HScompare_coordinates (static)

DESCRIPTION
	This routine searches each given region to find the minimum x-coordinate
	within or bounding the active region.

PARAMETERS
	num_upoints (IN) - # of mesh points in U
	num_vpoints (IN) - # of mesh points in V
	upoints (IN) - array of U points
	vpoints (IN) - array of V points
	sfpoints (IN) 2-D array of surface points

GLOBALS USED
	active_window
	
HISTORY
	09/25/89    C.M. Jablonski
	   Created
	02/10/92    S.P. Rogers
	   Added prologue documentation
*/

	{
	IGRint		i, j, array_index, min_u_index, max_u_index, min_v_index, max_v_index;
	IGRdouble	x_scale, *w;

	if (!((upoints[0] > max_u) || (upoints[num_upoints - 1] < min_u) ||
	    (vpoints[0] > max_v) || (vpoints[num_vpoints - 1] < min_v)))
	   {
	   w = sfpoints[2 * num_upoints * num_vpoints];
	   x_scale = (active_window->dit_clip_range[3] - active_window->dit_clip_range[0]) * 0.5;

	   for (	min_u_index = 0;
			((min_u_index + 1) < num_upoints) && (upoints[min_u_index + 1] <= min_u);
			min_u_index++ );
	   for (	max_u_index = num_upoints - 1;
			(max_u_index > min_u_index) && (upoints[max_u_index - 1] >= max_u);
			max_u_index-- );
	
	   for (	min_v_index = 0;
			((min_v_index + 1) < num_vpoints) && (vpoints[min_v_index + 1] <= min_v);
			min_v_index++ );
	   for (	max_v_index = num_vpoints - 1;
			(max_v_index > min_v_index) && (vpoints[max_v_index - 1] >= max_v);
			max_v_index-- );
	
	   for (i = min_u_index; i <= max_u_index; i++)
	      for (j = min_v_index; j <= max_v_index; j++)
	         {
	         array_index = (j * num_upoints) + i;

	         if (active_window->perspective)
	            sfpoints[array_index][0] =	((sfpoints[array_index][0] /
						  w[array_index]) + 1.0) * x_scale;

	         if ((sfpoints[array_index][0] < min_x) ||
	             (min_x == (IGRdouble)HR_TOSS_SURFACE))
	            min_x = sfpoints[array_index][0];
	         }
	   }
	}  /* HScompare_coordinates */
	

/*--- HSsurface_tiler ---------------------------------------------------------*/

static void HSsurface_tiler( struct IGRbsp_surface *surf,
					    IGRint num_upoints,
					    IGRint num_vpoints,
					 IGRdouble *upoints,
					 IGRdouble *vpoints )

/*
NAME
	HSsurface_tiler (static)

DESCRIPTION
	Given a B-spline surface definition, this routine will generate a list
	of facets which approximate the surface and which observe all 
	imposed boundaries (line strings in parametric space identifying
	visible & invisible regions of the surface).  Each facet is
	a collection of planar (or nearly planar) polygons; the first
	polygon of each facet is a solid region while the remaining polygons
	define holes in it.  The polygons (loops) themselves are an ordered
	list of surface points and their associated normal vectors.  Loops
	are terminated by a special double-floating value, except for the
	last loop which uses a different double-floating value to signify
	end-of-facet.  All output is clipped and displayed by clip_and_shade.

ALGORITHM
	The surface is approximated by creating a grid ('mesh') of 
	points in UV space, projecting these points to real space, and
	building facets which represent the areas between adjacent mesh
	lines.  Mesh values are simply the unique knot values in U and V
	with a number of additional evenly spaced values between knots;
	the number of points to be added is in 'accuracy'.  With
	the list of U and V mesh values created, calls to 'BSsfarrevnd'
	give the surface points and normals associated with the mesh.
	Rather than making one call to 'BSsfarrevnd' for the whole surface,
	the mesh is broken up along logically sharp knots (i.e. parameters with
	discontinuous partial derrivatives) and the function is called 
	separately for each of these regions.  That way points which lie on
	sharp knots will have the correct normal depending on which region it is
	associated with.

	If the surface has boundaries, special data structures (linked lists
	of boundary points) are set up to represent them by
	'preprocess_a_boundary' ... ultimately the 'patch_bounds' array
	will be set up to contain the boundaries and/or boundary
	pieces associated with each patch.  A 4 step approach is then used to 
	make facets for patches cut by boundaries:

	STEP 1: Create a list of all intersection points of boundaries
		with patch sides & sort them so that they are in the order
		that you would find them if you started at the lower-left 
		corner of the patch and went around the its sides clockwise.  
		Each node (type 'HSxsect') contains information like:
	  	- a pointer to the intersection point on the boundary
		- a pointer to the other endpoint's intersection node
		- a key used to sort the intersection nodes by
		- a flag indicating if this intersection point is
		  the beginning or end of the boundary piece (used to
		  decide if the order of boundary points must be reversed
	 	  in order to plug it into the patch)
		This step is done by 'build_intersection_list'.
	
	STEP 2: If all of the patch's boundaries are loops completely 
		contained within it, then:
			If the patch itself is solid, generate a single facet
		  	  with the boundaries treated as hole polygons in the facet
			  ('do_patch_with_no_open_boundaries').
			Otherwise the patch is not solid ... go to step 4.

	STEP 3: Using the list created in step 1, start traversing intersections
		until a set of boundary pieces are found which define a single
		solid region.  Connect the endpoints of these boundaries to the
		sides of the patch ('link_bound_to_*_side' and
		'link_*_side_to_bound') to make a single linked list of points.
		Send this out as the first (solid) polygon of a facet, then 
		check the remaining list boundaries for holes within this area and
		include them too ('add_contained_loops').  Remove all
		intersections used from the list and repeat this step until
		none are left.

	STEP 4: Make facets with the remaining closed boundaries
		('clean_up_remaining_boundaries').

PARAMETERS
	surf (IN/OUT) - the surface to tile  (see note)
	num_upoints (IN) - number of sample points in u
	num_vpoints (IN) - number of sample points in v
	upoints (IN) - array of sample points in u
	vpoints (IN) - array of sample points in v

RETURN VALUES
	 As of 11/03/89, the global flag "tiling_parms.status" will carry the return
	 values.  HSSTAT_OK is returned if the function completes successfully.
	 If memory cannot be allocated for some reason, HSSTAT_ALLOC_ERROR is returned.
	 If it is detected that boundaries cross, HSSTAT_BOUND_ERROR is returned. 
	 If a math routine doesn't pass back a 0, that error code is returned.

NOTES
	The low-order 4 bits of the mantissas of the knots in the surface 
	structure will be cleared.  This helps insure that, as boundary/mesh
	line intersection points are added to the boundaries, no intersection
	point will lie exactly on a patch corner (mesh point).

HISTORY
	09/01/86    S.A. Rapa
	   Created
	02/07/87    S.A. Rapa
	    Made changes to support merging part of XFORM
	    with IGE and per-window tolerancing.
	03/10/87
	    Sample points are now passed as parameters
	01/22/88    C.M. Jablonski
	    Made changes to support back plane culling
	04/19/88    C.M. Jablonski
	    Made changes to support feedback mode
	04/22/88    C.M. Jablonski
	    Made changes to support direct bndry pt evaluation
	02/16/89    C.M. Jablonski
	    Added checks on num_upoints, num_vpoints
	03/03/89    C.M. Jablonski
	    Added partolbasis
	03/20/89    C.M. Jablonski
	    Added FEM-specific data
	05/15/89    C.M. Jablonski
	    Added normdir, edge marking
	07/20/89    C.M. Jablonski
	    Removed all option processing; this routine now
	    only tiles surfaces. That's all.
	09/28/89    C.M. Jablonski
	    Added u/vnorm_first, u/vnorm_index.
	11/03/89    C.M. Jablonski
	    Added global tiling_parms.status flag.
	01/16/90    C.M. Jablonski
	    Separated per-region and per-patch bnd processing.
	10/04/90    S.P. Rogers
	    Added stack space memory management
	02/10/92    S.P. Rogers
	   Added prologue documentation
*/

	{
	IGRlong		rc;		    		/* return code			*/
	IGRpoint	*sfpoints = NULL,      		/* array of points, norms, w's	*/
			st_sfpoints[SF_POINT_SPACE];
	IGRboolean 	*normdir = NULL,      		/* array of normal directions	*/
			st_normdir[NORMDIR_SPACE];
	IGRint		*u_region_indexes = NULL,	/* sharp knot index arrays	*/
			*v_region_indexes = NULL,
			st_u_region_indexes[REGION_INDEX_SPACE],
			st_v_region_indexes[REGION_INDEX_SPACE];
	IGRint		num_u_reg_points,		/* sharp knot counters		*/
			num_v_reg_points;
	struct HSbound	*master_bound_list = NULL;	/* master boundary list		*/
	struct HSbound	**region_bounds = NULL,		/* per-region bndry list array	*/
			*st_region_bounds[REGION_BOUNDS_SPACE];
	struct HSbound	**patch_bounds = NULL,		/* per-patch bndry list array	*/
			*st_patch_bounds[PATCH_BOUNDS_SPACE];
	IGRboolean	skip_first_u,			/* patch processing flags	*/
			skip_first_v,
			skip_last_u,
			skip_last_v;
	IGRboolean	origin_status;			/* solid/hole status flag	*/
	IGRboolean	next_u_status = FALSE;		/* next solid/hole status flag	*/
	IGRboolean	next_v_status;			/* next solid/hole status flag	*/
	IGRboolean	save_v_status;			/* solid/hole storage flag	*/
	IGRint		u_index, v_index;		/* indexes			*/
	IGRint		uoffset, voffset;		/* array offsets		*/
	IGRint		region_number;			/* region counter		*/
	IGRint		patch_number;			/* patch counter		*/
	IGRint		total_points;			/* point counter		*/
	IGRint		max_u_per_region,		/* max sample pts per region	*/
			max_v_per_region;
	IGRint		num_u_sharp,			/* sharp knot counters		*/
			num_v_sharp;
	IGRint		*u_delflags = NULL,		/* delete flag arrays		*/
			*v_delflags = NULL,
			st_u_delflags[DELFLAGS_SPACE],
			st_v_delflags[DELFLAGS_SPACE];
	IGRint		num_udel, num_vdel;		/* number of deleted points	*/
	IGRint		num_upoints2;			/* adjusted num of u sample pts	*/
	IGRint		num_vpoints2;			/* adjusted num of v sample pts	*/
	IGRdouble	*u_region_values = NULL;	/* sharp knot array		*/
	IGRdouble	*v_region_values = NULL;	/* sharp knot array		*/
	IGRdouble	*upoints2 = NULL,		/* adjusted u sample pnt array	*/
			st_upoints2[ADJUSTED_POINTS_SPACE];
	IGRdouble	*vpoints2 = NULL,		/* adjusted v sample pnt array	*/
			st_vpoints2[ADJUSTED_POINTS_SPACE];
	IGRboolean	ind[4];			/* flags for BSsfarrevmt	*/
	IGRint		num_deg, *deg_ind = NULL;
	IGRboolean	st_unorm_first[NORM_FIRST_SPACE];
	IGRboolean	st_vnorm_first[NORM_FIRST_SPACE];
	IGRboolean      *u_skip_flags = NULL, *v_skip_flags = NULL;
	IGRboolean	st_u_skip_flags[SKIP_FLAGS_SPACE], st_v_skip_flags[SKIP_FLAGS_SPACE];
#if PLOT_BOUNDS
	IGRdouble	u0,v0,u1,v1,*ptr;	/* logging values		*/
	IGRint		x,y,z,index;		/* logging values		*/
#endif


#if DEBUG_SURFACE
{
HSdump_surface( surf );

fprintf( stderr, "\nList of U grid points:\n");
for(u_index = 0; u_index < num_upoints; u_index++)
	fprintf( stderr, "upoints[%d]=%20.18f \n", u_index, upoints[u_index] );
	
fprintf( stderr, "\nList of V grid points:\n" );
for(v_index = 0; v_index < num_vpoints; v_index++)
	fprintf( stderr, "vpoints[%d]=%20.18f \n", v_index, vpoints[v_index] );
}
#endif

#if PLOT_BOUNDS
{
PBinit();
/* draw the sample rule lines */
PBset_color(2);
for(x=0;x<num_upoints;x++)
   PBclip_and_draw_line(upoints[x], vpoints[0], upoints[x], vpoints[num_vpoints-1]);
for(x=0;x<num_vpoints;x++)
   PBclip_and_draw_line(upoints[0], vpoints[x], upoints[num_upoints-1], vpoints[x]);
PBrefresh_window();
}
#endif


	/*
	 * Modify knot and sampling points to prevent problems
	 * when building polygons out of patches cut by boundaries
	 */

	HSclear_knot_lo_bits (num_upoints, upoints);
	HSclear_knot_lo_bits (num_vpoints, vpoints);


	if (element_parms.facet_type == FEM_TILE)
		{
		/*
		 * Since we are not interested in normals, we can process
		 * the entire surface as one sharp region.
		 */

		u_region_indexes = (IGRint *) GET_MEMORY( 2, REGION_INDEX_SPACE,
							  sizeof( IGRint ),
							  st_u_region_indexes );

		v_region_indexes = (IGRint *) GET_MEMORY( 2, REGION_INDEX_SPACE,
							  sizeof( IGRint ),
							  st_v_region_indexes );
		if (!u_region_indexes || !v_region_indexes)
			{
			HSset_status( HSSTAT_ALLOC_ERROR );
			goto wrapup;
			}

		/*
		 * Setup the sharp knot index arrays.
		 */

		num_u_reg_points = 2;
		u_region_indexes[0] = 0;
		u_region_indexes[1] = num_upoints - 1;

		num_v_reg_points = 2;
		v_region_indexes[0] = 0;
		v_region_indexes[1] = num_vpoints - 1;
		}
	else
		{
		/*
		 * Allocate needed memory for sharp knot indexes.
		 */

		u_region_indexes = (IGRint *) GET_MEMORY( surf->u_num_knots, REGION_INDEX_SPACE,
					                  sizeof(IGRint),
					                  st_u_region_indexes );

		v_region_indexes = (IGRint *) GET_MEMORY( surf->v_num_knots, REGION_INDEX_SPACE,
					                  sizeof(IGRint),
					                  st_v_region_indexes );

		if (!u_region_indexes || !v_region_indexes)
			{
			HSset_status( HSSTAT_ALLOC_ERROR );
			goto wrapup;
			}

		/*
		 * Find out what knots are sharp (i.e. multiplicity = order-1).
		 * Divide the parametric plane along each sharp knot and process
		 * these regions individually.
		 */

		HSfind_sharp_knots(	surf, 
					&num_u_sharp, &num_v_sharp,
					&u_region_values, &v_region_values );

		HSrefine_sample_regions(	num_u_sharp, u_region_values,
						num_upoints, upoints,
						&num_u_reg_points, u_region_indexes );
		
		HSrefine_sample_regions(	num_v_sharp, v_region_values,
						num_vpoints, vpoints,
						&num_v_reg_points, v_region_indexes );
		}
		
	if (tiling_parms.status != HSSTAT_OK) goto wrapup;

	/*
	 * Modify knot and sampling points to prevent problems
	 * when building polygons out of patches cut by boundaries
	 */

	HSclear_knot_lo_bits (surf->u_num_knots, surf->u_knots);
	HSclear_knot_lo_bits (surf->v_num_knots, surf->v_knots);


#if DEBUG_SURFACE
{
IGRint		index;

fprintf( stderr, "\nList of U sharp grid points:\n" );

for( index=0; index<num_u_reg_points; index++ )
	fprintf( stderr, "%17.9lf \n", upoints[u_region_indexes[index]] );

fprintf( stderr, "\nList of V sharp grid points:\n" );

for( index=0; index<num_v_reg_points; index++ )
	fprintf( stderr, "%17.9lf \n", vpoints[v_region_indexes[index]] );
}
#endif

	/*
	 * Allocate sfpoints (to hold points, normals, and w's, in that order).
	 * The amount of space to allocate is based on the largest sample region.
	 */

	max_u_per_region = u_region_indexes[1] - u_region_indexes[0];
	for( u_index=1; u_index<(num_u_reg_points - 1); u_index++ )
		if( max_u_per_region < (total_points = u_region_indexes[u_index + 1] - u_region_indexes[u_index]) )
			max_u_per_region = total_points;
	max_u_per_region++;

	max_v_per_region = v_region_indexes[1] - v_region_indexes[0];
	for( v_index=1; v_index<(num_v_reg_points - 1); v_index++ )
		if( max_v_per_region < (total_points = v_region_indexes[v_index + 1] - v_region_indexes[v_index]) )
			max_v_per_region = total_points;
	max_v_per_region++;

	
	/* The seven doubles for each point are: 3 for XYZ, 3 for the normal and 1 for w */
	sfpoints = (IGRpoint *) GET_MEMORY( (max_u_per_region * max_v_per_region * 7),
					    SF_POINT_SPACE,
					    sizeof(IGRdouble),
					    st_sfpoints );

	if (!sfpoints)
		{
		HSset_status( HSSTAT_ALLOC_ERROR );
		goto wrapup;
		}

	if (element_parms.marking_edges)
		{
		normdir = (IGRboolean *) GET_MEMORY( (max_u_per_region*max_v_per_region), NORMDIR_SPACE,
					              sizeof(IGRboolean),
					              st_normdir );

		unorm_first = (IGRboolean *) GET_MEMORY( num_upoints, NORM_FIRST_SPACE,
							 sizeof(IGRboolean),
							 st_unorm_first );

		vnorm_first = (IGRboolean *) GET_MEMORY( num_vpoints, NORM_FIRST_SPACE,
							 sizeof(IGRboolean),
							 st_vnorm_first );

		if(!normdir  || !unorm_first || !vnorm_first)
			{
			HSset_status( HSSTAT_ALLOC_ERROR );
			goto wrapup;
			}
		}

	if( surf->num_boundaries != 0 )
		{
		/*
		 * Allocate the necessary structures.
		 */

		upoints2 = (IGRdouble *) GET_MEMORY( max_u_per_region, ADJUSTED_POINTS_SPACE,
						     sizeof(IGRdouble),
						     st_upoints2 );

		vpoints2 = (IGRdouble *) GET_MEMORY( max_v_per_region, ADJUSTED_POINTS_SPACE,
						     sizeof(IGRdouble),
						     st_vpoints2 );

		u_delflags = (IGRint *) GET_MEMORY( max_u_per_region, DELFLAGS_SPACE,
						    sizeof(IGRint),
						    st_u_delflags );

		v_delflags = (IGRint *) GET_MEMORY( max_v_per_region, DELFLAGS_SPACE,
						    sizeof(IGRint),
						    st_v_delflags );

		region_bounds = (struct HSbound **)
				GET_MEMORY( ((num_u_reg_points - 1) * (num_v_reg_points - 1)),
					    REGION_BOUNDS_SPACE,
					    sizeof( struct HSbound *),
					    st_region_bounds );

		patch_bounds = (struct HSbound **)
				GET_MEMORY( ((max_u_per_region - 1) * (max_v_per_region - 1)),
					    REGION_BOUNDS_SPACE,
					    sizeof( struct HSbound *),
					    st_patch_bounds );

		if (!upoints2 || !vpoints2 || !u_delflags || !v_delflags || !region_bounds || !patch_bounds)
			{
			HSset_status( HSSTAT_ALLOC_ERROR );
			goto wrapup;
			}

		/*
		 * Create linked lists of points to represent boundaries,
		 * (one linked list per sample region).
		 */

		if (surf->on_off)
			save_v_status = TRUE;
		else
			save_v_status = FALSE;

		master_bound_list = NIL_BOUND;
		for( u_index = 0; u_index < surf->num_boundaries; u_index++ )
			{
			master_bound_list = preprocess_a_boundary(	master_bound_list,
									surf->bdrys[u_index].num_points,
									surf->bdrys[u_index].points,
									upoints[0], vpoints[0],
									&save_v_status  );

			if (tiling_parms.status != HSSTAT_OK) goto wrapup;
			}

		if ((num_u_reg_points <= 2) && (num_v_reg_points <= 2))
			{
			region_bounds[0] = master_bound_list;
			}
		else
			{
			add_mesh_intersections(	master_bound_list,
						num_u_reg_points, u_region_values,
						num_v_reg_points, v_region_values );

			if (tiling_parms.status != HSSTAT_OK) goto wrapup;

#if DEBUG_SURFACE
{
struct HSbound	*this_bound;
struct HSpoint	*this_point;
IGRdouble	retptr[3];
IGRdouble	u_val,v_val;

fprintf( stderr, "\nBoundary points with intersections added:" );

this_bound = master_bound_list;

ind[0] = 1;
ind[1] = ind[2] = ind[3] = 0;

while( NIL_BOUND != this_bound )
	{
	fprintf( stderr, "\n");

	this_point = this_bound->start_pt;

	u_val = this_point->u;
	v_val = this_point->v;

	BSsfarrevmt(	surf,
			1, &u_val,
			1, &v_val,
			ind,
			retptr,
			NULL, NULL, NULL,
			&num_deg, &deg_ind,
			&rc );

	fprintf( stderr, "u=%f v=%f x=%f y=%f z=%f\n", 
		this_point->u, this_point->v,
		retptr[0], retptr[1], retptr[2] );

	do
		{
		this_point = this_point->next;
		u_val = this_point->u;
		v_val = this_point->v;

		BSsfarrevmt(	surf,
				1, &u_val,
				1, &v_val,
				ind,
				retptr,
				NULL, NULL, NULL,
				&num_deg, &deg_ind,
				&rc );

		fprintf( stderr, "u=%f v=%f x=%f y=%f z=%f\n", 
			this_point->u, this_point->v,
			retptr[0], retptr[1], retptr[2] );
		}

	while( this_point != this_bound->end_pt );

	this_bound = this_bound->next;
	}
}
#endif

#if PLOT_BOUNDS
{
struct HSbound	*this_bound;
struct HSpoint	*this_point;

this_bound = master_bound_list;

while( NIL_BOUND != this_bound )
	{
	this_point = this_bound->start_pt;

	PBset_color(1);

	PBdraw_big_point(this_point->u, this_point->v);
				
	PBset_color(7);

	do
		{
		PBdraw_bound_line(this_point->u, this_point->v,
			this_point->next->u, this_point->next->v);
		this_point = this_point->next;
		}
	while( this_point != this_bound->end_pt );

	PBset_color(6);

	PBdraw_big_point(this_point->u, this_point->v);

	this_bound = this_bound->next;
	}
}
#endif

			HSdistribute_boundaries(	master_bound_list,
						num_u_reg_points, num_v_reg_points,
						u_region_values, v_region_values,
						region_bounds);
				
			if (master_bound_list != NIL_BOUND)
				HSdispose_bound_list( master_bound_list );

			if (tiling_parms.status != HSSTAT_OK) goto wrapup;
			}
		}

	/*
	 * Tile the surface; process one sample region at a time.
	 */

#if PLOT_BOUNDS
{
/* draw the sharp knot lines */
PBset_color(6);
for(x=0;x<num_u_reg_points;x++)
   PBclip_and_draw_line(upoints[u_region_indexes[x]], vpoints[v_region_indexes[0]], upoints[u_region_indexes[x]], vpoints[v_region_indexes[num_v_reg_points-1]]);
for(x=0;x<num_v_reg_points;x++)
   PBclip_and_draw_line(upoints[u_region_indexes[0]], vpoints[v_region_indexes[x]], upoints[u_region_indexes[num_u_reg_points-1]], vpoints[v_region_indexes[x]]);
}
#endif

	region_number = 0;
	for( v_index=0; v_index<(num_v_reg_points - 1); v_index++ )
		{
		voffset = vnorm_index = v_region_indexes[v_index];
		num_vpoints = v_region_indexes[v_index + 1] - voffset + 1;

		for( u_index=0; u_index<(num_u_reg_points - 1); u_index++ )
			{
			uoffset = unorm_index = u_region_indexes[u_index];
			num_upoints = u_region_indexes[u_index + 1] - uoffset + 1;


#if PLOT_BOUNDS
{
u0 = upoints[uoffset];
v0 = vpoints[voffset];
u1 = upoints[u_region_indexes[u_index+1]];
v1 = vpoints[v_region_indexes[v_index+1]];

/* hilight this region */
PBset_color(4);
PBclip_and_draw_line(u0, v0, u0, v1);
PBclip_and_draw_line(u0, v1, u1, v1);
PBclip_and_draw_line(u1, v1, u1, v0);
PBclip_and_draw_line(u1, v0, u0, v0);
PBrefresh_window();
/* SHARP REGION WINDOW */
PBinit_region_window(u0, v0, u1, v1);
/* draw the sample rule lines */
PBset_color(2);
for(x=uoffset;x<u_region_indexes[u_index+1];x++)
   PBclip_and_draw_line(upoints[x], v0, upoints[x], v1);
for(x=voffset;x<v_region_indexes[v_index+1];x++)
   PBclip_and_draw_line(u0, vpoints[x], u1, vpoints[x]);
/* hilight this region */
PBset_color(4);
PBclip_and_draw_line(u0, v0, u0, v1);
PBclip_and_draw_line(u0, v1, u1, v1);
PBclip_and_draw_line(u1, v1, u1, v0);
PBclip_and_draw_line(u1, v0, u0, v0);
PBrefresh_window();
}
#endif
			
			/*
			 * Get surface points and normals
			 */
		  
			total_points = num_upoints * num_vpoints;
		
			if( element_parms.doing_vertex_normals )
				{
				ind[0] = ind[3] = 1;
				ind[1] = ind[2] = 0;

				BSsfarrevmt(	surf,
						num_upoints,
						upoints + uoffset,
	 					num_vpoints,
						vpoints + voffset,
						ind,
						sfpoints[0],
						NULL, NULL,
						sfpoints[total_points],
						&num_deg, &deg_ind,
						&rc );

#if DEBUG_SURFACE
{
int		b,c;

fprintf( stderr, "\nSurface points in Object Space coordinates from BSsfarrevnd ...\n" );

c = num_upoints * num_vpoints;

for( b=0; b<num_upoints*num_vpoints; b++ )
	{
	fprintf( stderr, "\n(%lf, %lf, %lf)",
		sfpoints[b][0], sfpoints[b][1], sfpoints[b][2]);

	if( element_parms.doing_vertex_normals )
		fprintf( stderr, "\n   (%lf, %lf, %lf)",
			sfpoints[b+c][0],
			sfpoints[b+c][1],
			sfpoints[b+c][2]);
	}
					
	fprintf( stderr, "\n" );
}
#endif
	
			
				if ( !active_window->making_triangles )
					{
					transform_points(	active_window->perspective,
								total_points, 
								(IGRdouble *)sfpoints, 
								2 * total_points );
				
					rotate_normals( total_points, (IGRdouble *)(sfpoints + total_points) );
					}
#if DEBUG_SURFACE
{
int		b,c;

fprintf( stderr, "\nTRANSFORMED surface points ...\n" );

c = num_upoints * num_vpoints;

for( b=0; b<num_upoints*num_vpoints; b++ )
	{
	fprintf( stderr, "\n(%lf, %lf, %lf)",
		sfpoints[b][0], sfpoints[b][1], sfpoints[b][2]);

	if( element_parms.doing_vertex_normals )
		fprintf( stderr, "\n   (%lf, %lf, %lf)",
			sfpoints[b+c][0],
			sfpoints[b+c][1],
			sfpoints[b+c][2]);
	}
					
	fprintf( stderr, "\n" );
}
#endif
				}
			else
				{
				ind[0] = 1;
				ind[1] = ind[2] = ind[3] = 0;

				BSsfarrevmt(	surf,
						num_upoints,
						upoints + uoffset,
	 					num_vpoints,
						vpoints + voffset,
						ind,
						sfpoints[0],
						NULL, NULL, NULL,
						&num_deg, &deg_ind,
						&rc );

#if DEBUG_SURFACE
{
int		b,c;

fprintf( stderr, "\nSurface points in Object Space coordinates from BSsfarrev0 ...\n" );


for( b=0; b<num_upoints*num_vpoints; b++ )
	{
	fprintf( stderr, "\n(%lf, %lf, %lf)",
		sfpoints[b][0], sfpoints[b][1], sfpoints[b][2]);

	if( element_parms.doing_vertex_normals )
		fprintf( stderr, "\n   (%lf, %lf, %lf)",
			sfpoints[b+c][0],
			sfpoints[b+c][1],
			sfpoints[b+c][2]);
	}

fprintf( stderr, "\n" );
}
#endif
				
				if ( !active_window->making_triangles )
					{
					transform_points(	active_window->perspective,
								total_points, 
								(IGRdouble *)sfpoints, 
								2 * total_points );
					}
				}

			/*
			if( rc != 0 )
				{
				HSset_status( rc );
				goto wrapup;
				}
			*/
			
			/*
			 * Create polygons out of array of surface points.
			 */
	
			if (element_parms.facet_type == FIND_MIN_X)
				{
				HScompare_coordinates(	num_upoints, num_vpoints,
							upoints + uoffset,
							vpoints + voffset,
		 					sfpoints );
				}
			else if (element_parms.facet_type == FEM_TILE)
				{
				HSgenerate_fem_polygons(	num_upoints, num_vpoints,
								upoints + uoffset,
								vpoints + voffset,
			 					sfpoints);
				}
			else
			if( surf->num_boundaries == 0 )
				{
				if ( active_window->making_triangles )
					{
					HSgenerate_surface_mesh( num_upoints, num_vpoints, sfpoints );
					}
				else
					{
					HSgenerate_surface_polygons(
							num_upoints, num_vpoints, sfpoints,
							normdir,
							surf->u_phy_closed,
							surf->v_phy_closed,
							upoints[u_region_indexes[u_index]],
							vpoints[v_region_indexes[v_index]],
							vpoints[v_region_indexes[v_index + 1]],
							upoints+uoffset,
							vpoints+voffset );
					}
				}
			else
				{
				/*
				 * Calculate delete flags for the sample points.
				 */

				HSset_delete_flags(	sfpoints,
							num_upoints, num_vpoints,
							u_delflags, v_delflags,
							&num_udel, &num_vdel,
							&skip_first_u, &skip_first_v,
							&skip_last_u, &skip_last_v );

				u_skip_flags = ( IGRboolean *)
					GET_MEMORY( num_upoints,
						    SKIP_FLAGS_SPACE,
						    sizeof( IGRboolean ),
						    st_u_skip_flags );

				v_skip_flags = ( IGRboolean *)
					GET_MEMORY( num_vpoints,
						    SKIP_FLAGS_SPACE,
						    sizeof( IGRboolean ),
						    st_v_skip_flags );
				/*
				 * Delete the indicated sample points.
				 */

				HSdelete_sample_points(	num_udel,
							num_vdel,
							u_delflags,
							v_delflags,
							sfpoints,
							num_upoints, &num_upoints2,
							num_vpoints, &num_vpoints2,
							upoints + uoffset, upoints2,
							vpoints + voffset, vpoints2,
							skip_first_u, skip_last_u, u_skip_flags,
							skip_first_v, skip_last_v, v_skip_flags );
						
#if EDGEII_DEBUG
				fprintf( stderr, "After HSdelete_sample_points()\n" );
				fprintf( stderr, "num_udel = %d\tnum_vdel = %d\t", num_udel, num_vdel );
				fprintf( stderr, "num_upoints = %d\tnum_vpoints = %d\t",
					num_upoints, num_vpoints );
				fprintf( stderr, "num_upoints2 = %d\tnum_vpoints2 = %d\n",
					num_upoints2, num_vpoints2 );
#endif

#if DEBUG_SURFACE
{
fprintf(stderr, "REGION[%d]: ORIG NUM U=%d; NUM DELETED U=%d; ADJUSTED NUM U=%d\n",
region_number, num_upoints, num_udel, num_upoints2);
ptr = upoints2; x = 0;
for (index = 0; index < num_upoints; index++)
{
if (u_delflags[index])
   fprintf(stderr, "ORIG U[%d]=%f, DELFLG U[%d]=%d\n",
   index, upoints[index], index, u_delflags[index]);
else
   fprintf(stderr, "ORIG U[%d]=%f, DELFLG U[%d]=%d ADJ U[%d]=%f\n",
   index, upoints[index], index, u_delflags[index], x, ptr[x++]);
}

fprintf(stderr, "REGION[%d]: ORIG NUM V=%d; NUM DELETED V=%d; ADJUSTED NUM V=%d\n",
region_number, num_vpoints, num_vdel, num_vpoints2);
ptr = vpoints2; x = 0;
for (index = 0; index < num_vpoints; index++)
{
if (v_delflags[index])
   fprintf(stderr, "ORIG V[%d]=%f, DELFLG V[%d]=%d\n",
   index, vpoints[index], index, v_delflags[index]);
else
   fprintf(stderr, "ORIG V[%d]=%f, DELFLG V[%d]=%d ADJ V[%d]=%f\n",
   index, vpoints[index], index, v_delflags[index], x, ptr[x++]);
}

for (index = 0; index < num_vpoints2 * num_upoints2; index++)
{
fprintf(stderr, "POINT[%d] = %f, %f, %f\n",
index, sfpoints[index][0], sfpoints[index][1], sfpoints[index][2]);
}

for (index = num_vpoints2 * num_upoints2; index < 2 * num_vpoints2 * num_upoints2; index++)
{
fprintf(stderr, "NORMAL[%d] = %f, %f, %f\n",
index, sfpoints[index][0], sfpoints[index][1], sfpoints[index][2]);
}
}
#endif

				/*
				 * Process this region's boundaries.
				 */

				add_mesh_intersections(	region_bounds[region_number],
							num_upoints2, upoints2,
							num_vpoints2, vpoints2 );

				if (tiling_parms.status != HSSTAT_OK) goto wrapup;

				HSdistribute_boundaries(	region_bounds[region_number],
								num_upoints2, num_vpoints2,
								upoints2, vpoints2,
								patch_bounds);
				
				if (region_bounds[region_number] != NIL_BOUND)
					{
					HSdispose_bound_list( region_bounds[region_number] );
					region_bounds[region_number] = NIL_BOUND;
					}

				if (tiling_parms.status != HSSTAT_OK) goto wrapup;

				region_number++;
				patch_number = 0;

				if((u_index == 0) ||
				   (u_region_indexes[u_index] == u_region_indexes[0]))
					{
					origin_status = save_v_status;
					}
				else
					{
					origin_status = next_u_status;
					}
					
#if EDGEII_DEBUG
				fprintf( stderr, "Calling HSgenerate_surf_with_bound_polygons\t" );
				fprintf( stderr, "with num_vpoints = %d\tnum_vpoints2 = %d\n",
					num_vpoints, num_vpoints2 );
#endif

				HSgenerate_surf_with_bound_polygons(
							num_upoints2, num_vpoints2,
							upoints2,
							vpoints2,
		 					sfpoints, normdir,
							surf->u_phy_closed,
							surf->v_phy_closed,
							patch_bounds, &patch_number,
							u_skip_flags,
							v_skip_flags,
							origin_status,
							&next_u_status,
							&next_v_status);

				if((u_index == 0) ||
				   (u_region_indexes[u_index] == u_region_indexes[0]))
					save_v_status = next_v_status;
				}


#if PLOT_BOUNDS
{
/* dehilight this region */
PBenable_surface_window();
PBset_color(5);
PBclip_and_draw_line(u0, v0, u0, v1);
PBclip_and_draw_line(u0, v1, u1, v1);
PBclip_and_draw_line(u1, v1, u1, v0);
PBclip_and_draw_line(u1, v0, u0, v0);
}
#endif
			} 
		}

wrapup:

	if ((!(tiling_parms.processing_mode & HS_PMODE_DEXEL)) && 
	    (!(tiling_parms.processing_mode & HS_PMODE_FEEDBACK))) HSpaint( 0 );

	/* 
	 * Deallocate memory used
	 */

	HScleanup_boundary_structures();
	if ( (sfpoints) && (sfpoints != st_sfpoints) )
	   free( (char *) sfpoints );
	if ( (normdir) && (normdir != st_normdir) )
	   free( (char *) normdir );
	if ( (u_region_indexes) && (u_region_indexes != st_u_region_indexes) )
	   free( (char *) u_region_indexes );
	if ( (v_region_indexes) && (v_region_indexes != st_v_region_indexes) )
	   free( (char *) v_region_indexes );
	if ( (unorm_first) && (unorm_first != st_unorm_first) )
	   { free( (char *) unorm_first );}

/*Since unorm_first and vnorm_first are global variables they need to be reset
 otherwise in the next iteration, trying to free these variables will result
 in errors */

        unorm_first = NULL; 
	if ( (vnorm_first) && (vnorm_first != st_vnorm_first) )
	   { free( (char *) vnorm_first );}
        vnorm_first = NULL; 
	if ( (upoints2) && (upoints2 != st_upoints2) )
	   free( (char *) upoints2 );
	if ( (vpoints2) && (vpoints2 != st_vpoints2) )
	   free( (char *) vpoints2 );
	if ( (u_delflags) && (u_delflags != st_u_delflags) )
	   free( (char *) u_delflags );
	if ( (v_delflags) && (v_delflags != st_v_delflags) )
	   free( (char *) v_delflags );
	if ( (patch_bounds) && (patch_bounds != st_patch_bounds) )
	   free( (char *) patch_bounds );
	if ( (region_bounds) && (region_bounds != st_region_bounds) )
	   free( (char *) region_bounds );
	if ( (u_skip_flags) && (u_skip_flags != st_u_skip_flags) )
	   free( (char *) u_skip_flags );
	if ( (v_skip_flags) && (v_skip_flags != st_v_skip_flags) )
	   free( (char *) v_skip_flags );
	
#if PLOT_BOUNDS
{
PBexit();
}
#endif
	}  /* HSsurface_tiler */


/*---HScheck_bnds--------------------------------------------------------------*/

static int	HScheck_bnds( struct IGRbsp_surface *surf )

/*
NAME
	HScheck_bnds (static)

DESCRIPTION
	Look at the list of boundaries on the surface and move all 3 point 
	boundaries to the top of the list.

PARAMETERS
	surf (IN/OUT) - surface definition

GLOBALS USED
	none

RETURN VALUES
	The number of good boundaries is returned.

HISTORY
	xx/xx/xx	Unknown Programmer
		Creation
	02/10/92    S.P. Rogers
	   Added prologue documentation
*/
 
	{
	int		lo, hi;
	int		num_points;
	IGRdouble	*points;
	
	/*
	 *  If there are no boundaries on the surface then return 0
	 */
	 
	if( surf->num_boundaries == 0 )
		{
		hi = -1;
		}
	else
		{
			
		/*
		 *  Initialize the index values
		 */
		 
		lo = 0;
		hi = surf->num_boundaries - 1;
		
		while( lo <= hi )
			{
			if( surf->bdrys[lo].num_points <= 3 )
				{
				num_points = surf->bdrys[lo].num_points;
				points     = surf->bdrys[lo].points;
				
				surf->bdrys[lo].num_points = surf->bdrys[hi].num_points;
				surf->bdrys[lo].points     = surf->bdrys[hi].points;
				
				surf->bdrys[hi].num_points = num_points;
				surf->bdrys[hi].points     = points;
				
				hi--;
				}
			else
				{				
				lo++;
				}
			}
		}
		
	return( hi+1 );
	}  /* HScheck_bounds */


/*--- HScalc_surf_sample_points--------------------------------------------------------*/

static void HScalc_surf_sample_points( struct IGRbsp_surface *surf,
						      IGRint acc_mode,
						      IGRint accuracy,
						   IGRdouble win_cht,
						   IGRdouble *u_range,
						   IGRdouble *v_range,
						      IGRint *num_upoints,
						      IGRint *num_vpoints,
						   IGRdouble **upoints,
						   IGRdouble **vpoints,
							 int min_insert,
						   IGRdouble basis_tol )

/*
NAME
	HScalc_surf_sample_points (static)

DESCRIPTION
	This function calculates the array of sample points for a surface.

PARAMETERS
	surf (IN) - surface definition
	acc_mode (IN) - accuracy mode flag
	accuracy (IN) - tiling accuracy, if in accuracy mode
	win_cht (IN) - window based tiling tolerance
	u_range (IN) - active U range of the surface
	v_range (IN) - active V range of the surface
	num_upoints (OUT) - number of u sample points
	num_vpoints (OUT) - numver of v sample points
	upoints (OUT) - array of u sample points, caller must free this array
	vpoints (OUT) - array of v sample points, caller must free this array
 	basis_tol (IN) - parametric basis tolerance for surface
	min_insert (IN) - minimum points to insert between nodes

GLOBALS USED
	tiling_parms

HISTORY
	09/13/90    S.P. Rogers
	   Extracted from HSshade_object()
	02/10/92    S.P. Rogers
	   Added prologue documentation
*/

	{
	if( acc_mode != HS_ACCURACY_MODE_WINDOW )
		{
		add_pts_between_knots(
				surf->u_order,
				surf->u_num_poles + surf->u_order, 
				surf->u_knots,
				accuracy,
 				num_upoints,
 				upoints);

		if (tiling_parms.status != HSSTAT_OK) goto wrapup;

		add_pts_between_knots(
				surf->v_order,
				surf->v_num_poles + surf->v_order, 
				surf->v_knots,
				accuracy,
				num_vpoints,
				vpoints);

		if (tiling_parms.status != HSSTAT_OK) goto wrapup;
		}
	else
		{
		get_surf_sampling_points(
				surf,
				win_cht,
				u_range,
				v_range,
 				num_upoints,
 				num_vpoints,
				upoints,
				vpoints,
 				min_insert,
  				basis_tol );

		if (tiling_parms.status != HSSTAT_OK) goto wrapup;
		}
wrapup:;
	}  /* HScalc_surf_sample_points */


/*--- HSbsurf_tiler---------------------------------------------------------*/

void HSbsurf_tiler(     IGRint pipe_no,
         struct IGRbsp_surface *surf,
                     IGRdouble range[],
                        IGRint color,
                        IGRint options,
                    IGRboolean ele_shading_style,
         struct HS_element_rendering_parms *render_parms,
                    IGRboolean from_solid,
                     IGRdouble surface_tolerance,
                     IGRdouble pt_basis,
                     IGRdouble dis_tol,
                    IGRboolean dont_cull,
                        IGRint acc_mode,
                        IGRint accuracy,
                     IGRdouble win_cht,
                     IGRdouble *u_range,
                     IGRdouble *v_range,
                     IGRdouble *clip_range )

/*
NAME
   HSbsurf_tiler

DESCRIPTION
   HSbsurf_tiler tiles a bspline surface.  It processes the surface
   according to hardware type; if GPIPE is here it calls GPIPE.
   For the non-GPIPE case it sets up the necessary global variables
   before calling HSsurface_tiler to actually tile the surface.

PARAMETERS
   pipe_no (IN) - gpipe id
   surf (IN) - surface definition
   range (IN) - surface range points
   color (IN) - surface color
   options (IN) -  display options
   ele_shading_style (IN) - TRUE if using element shading style
   render_parms (IN) - rendering parameter pointer
   from_solid (IN) - TRUE if part of a solid
   surface_tolerance (IN) - surface interpolation check tol
   pt_basis (IN) - surface parameter basis tolerance
   dis_tol (IN) - world-coordinate distance tolerance
   dont_cull (IN) - if TRUE, dont cull back planes
   acc_mode (IN) - shading accuracy mode
   accuracy (IN) - active shading accuracy
   win_cht (IN) - window based shading accuracy
   u_range (IN) - active u range of surface
   v_range (IN) - active v range of surface
   clip_range (IN) - element clip range in dits

GLOBALS USED
   active_window
   tiling_parms

HISTORY
   xx/xx/xx   S. Rapa
      Created
   09/13/90   S.P. Rogers
      Changed to calculate sample points instead of having them passed in
   02/10/92    S.P. Rogers
      Added prologue documentation
   05/18/93    M. Lanier
      Conditional compile declaration for depthCueRep because the SGI does not
      know what EGDepthCueRep is.
*/

   {
#  if defined( ENV5 )
   IGRboolean  use_ASAP1;
   IGRdouble   near_z = 0.0, far_z = tiling_parms.maximum_z;
   IGRdouble   near_z_pct = 1.0, far_z_pct = 1.0;
   IGRint      vlt_index;
#  endif

   IGRint      actual_num_boundaries;
   IGRint      status;
   IGRint      num_upoints, num_vpoints;
   IGRdouble   *upoints = NULL, *vpoints = NULL;

#  if defined (ENV5)
   EGDepthCueRep   depthCueRep;
#  endif

   /*  Check the surface to see if it's boundaries, if it has any has */
   /*  invalid parameters.  And, if it does, ignore the surface */

   int i, j;
   for( i=0; i<surf->num_boundaries; i++ )
      {
      for( j=0; j<surf->bdrys[i].num_points; j++ )
         {
         if( surf->bdrys[i].points[j*2]     > 1.0 ||
             surf->bdrys[i].points[j*2+1]   > 1.0 || 
             surf->bdrys[i].points[j*2]     < 0.0 || 
             surf->bdrys[i].points[j*2+1]   < 0.0 ) 
            {
            HSset_status( HSSTAT_BOUND_ERROR );
            return;
            }
         }
      }

   HSactivate_window( pipe_no );

   if (tiling_parms.status != HSSTAT_OK) goto wrapup2;

   /* throw out surfaces whose u/v range is too small to process */

   if ( ((u_range[1] - u_range[0]) < KNOT_TOL) ||
        ((v_range[1] - v_range[0]) < KNOT_TOL) )
      {
      goto wrapup2;
      }

#  if defined( ENV5 )

   use_ASAP1 = ( (active_window->type & HShardware_LB_GPIPE) &&
                 !(options & (HS_BST_EDGES | HS_BST_REV_EDGES) ) &&
                 !(tiling_parms.processing_mode & HS_PMODE_FEEDBACK) &&
                 !(tiling_parms.processing_mode & HS_PMODE_DEXEL) );

   if( use_ASAP1 )
      {
         
      /* 
       *  The FPE cannot handle subranges
       */
       
      u_range[0] = 0.0;
      u_range[1] = 1.0;
      v_range[0] = 0.0;
      v_range[1] = 1.0;
      }

#  endif

   /*
    * View Dynamics substitutes Smooth Shading for all styles
    * except Constant.
    */

   if ( tiling_parms.processing_mode & HS_PMODE_FEEDBACK )
      {
      if (!(options & GR_BST_CONSTANT))
         {
         options &= ~(GR_BST_SOLID | HS_BST_EDGES | HS_BST_REV_EDGES);
         options |= GR_BST_SMOOTH;
         }
      }

   if( clip_range != NULL )
      HSset_ele_clip_range( clip_range );

#  if defined( ENV5 )
   if ( !use_ASAP1 )
#  endif
      {
      /* set surface tiling parameters */
      HSset_surf_parms ( color, options );

      /* set the rendering parameters for EG to use */
      HSset_element_rendering_parms( render_parms );
   
      /* set back plane cull flag */
      if (!(tiling_parms.processing_mode & HS_PMODE_DEXEL))
         {
         if ( dont_cull )
            HSset_element_cull_flag( HS_CULL_NONE );
         else
            HSset_cull_flag( surf, from_solid, options, range );
         }
      }


   HScalc_surf_sample_points(
            surf,
            acc_mode,
            accuracy,
            win_cht,
            u_range, v_range,
            &num_upoints, &num_vpoints,
            &upoints, &vpoints,
            (int)0, pt_basis );

#  if defined( ENV5 )   
    /*
     * If there is a locked zbuffer tell hardware it is delete mode
     */

   if( (active_window->type & HShardware_LB_GPIPE) && (options & HS_BST_DELETE) )
      sh_set_delete_mode( active_window->hwin_no, 1, HS_BACKGROUND_Z );
#  endif

   /*
    * Tile the surface according to the hardware type.
    */

#  if defined( ENV5 )
   if( active_window->type & HShardware_LB_EG )
      {
      if( active_window->depth_cue_on )
         {
         EGSetDepthCueMode( active_window->EG_vc_no, EG_ON );

         depthCueRep.scaleFact[0] = 1.0 - active_window->depth_cue_base;
         depthCueRep.scaleFact[1] = 1.0 - (active_window->depth_cue_base +
                                           active_window->depth_cue_delta *
                                          (active_window->dit_clip_range[5] -
                                           active_window->dit_clip_range[2]));

         depthCueRep.refPlane[0] = 0;
         depthCueRep.refPlane[1] = 1.0;
         depthCueRep.color.red = 0.0;
         depthCueRep.color.green = 0.0;
         depthCueRep.color.blue = 0.0;

         status = EGSetDepthCueRep( active_window->EG_vc_no, &depthCueRep );
         }
      else
         {
         EGSetDepthCueMode( active_window->EG_vc_no, EG_OFF );
         }
      }
#  endif

#  if defined( OPENGL )
   if( active_window->type & HShardware_LB_OPENGL )
      {
      WLglx_make_window_current( active_window->win_no, WL_GLX_BASE_WIN );
      if ( active_window->depth_cue_on )
         {
         glEnable( GL_FOG );
         }
      else
         {
         glDisable( GL_FOG );
         }
      }
#  endif

#  if defined( ENV5 )
   if ( use_ASAP1 )
      {
      if( active_window->depth_cue_on )
         {

         /*
          * Set up depth cue parameters.
          */

         near_z_pct = active_window->depth_cue_base;
         far_z_pct =   active_window->depth_cue_base +
                       active_window->depth_cue_delta *
                      (active_window->dit_clip_range[5] -
                       active_window->dit_clip_range[2]);

         GPSetDepthCueing(
               active_window->gpipe_id,
               1,
               near_z, near_z_pct,
               far_z,  far_z_pct );
         }

      if( options & HS_BST_DELETE )
         {

         /*
          *  Set the base color to background, and force
          *  the color shade config to 1 shade so GPIPE will
          *  not interpolate shades
          */
          
         color = 0;
         vlt_index = get_color_index( &color );
         GPSetShadeTable( active_window->gpipe_id, 1, 0 );
         }
      else
         {
         vlt_index = get_color_index( &color );
         }

      if( options & GR_BST_TRANSP )
         {
         GPSetTransparency( 
            active_window->gpipe_id, 
            tiling_parms.processing_mode & HS_PMODE_TRANS_1x1 ? 1 : 2 );
         }

      HSset_surf_parms ( color, options );
      status = GPBsplineTiler(
                  active_window->gpipe_id,
                  surf->u_order, surf->v_order,
                  surf->u_num_poles, surf->v_num_poles,
                  surf->poles,
                  surf->u_knots, surf->v_knots,
                  surf->weights,
                  surf->rational,
                  num_upoints, num_vpoints,
                  upoints, vpoints,
                  surf->num_boundaries, surf->bdrys,
                  surf->on_off,
                  vlt_index,
                  options );
            
      if (!status) HSset_status( status );
      if (!(tiling_parms.processing_mode & HS_PMODE_FEEDBACK)) HSpaint( 0 );

      if( active_window->depth_cue_on )
         {
         GPSetDepthCueing(
                  active_window->gpipe_id,
                  0,
                  near_z, near_z_pct,
                  far_z,  far_z_pct );
         }

      if( options & HS_BST_DELETE )
         {
         GPSetShadeTable(
                  active_window->gpipe_id, 
                  tiling_parms.number_shades, 
                  (tiling_parms.processing_mode & HS_PMODE_DIRECT) ? 0 : 1  );
         }

      if( options & GR_BST_TRANSP )
         {
         GPSetTransparency( active_window->gpipe_id, 0 );
         }
      }
   else
#  endif

      {
      
      /*
       *  Remember the number of boundaries then call routine to
       *  check for 3 point boundaries.  Process the surface then
       *  return the actual num boundaries to the structure
       */

      actual_num_boundaries = surf->num_boundaries;
      surf->num_boundaries = HScheck_bnds( surf );

      if ((surf->num_boundaries) ||
          (surf->on_off) ||
          (!actual_num_boundaries))
         {    
         if (tiling_parms.processing_mode & HS_PMODE_FEEDBACK)
            {
            /* save the surface color and options */
            HSsave_surface( color, options, 0, NULL );
            }
         else
            {
            /* check the range */
            HScheck_object_range( range );
            if (tiling_parms.status != HSSTAT_OK) goto wrapup;
            }
   
         /* set the global variables necessary to check surface interpolation */

         HSset_element_geometry( surf );
         HSset_element_tolerances(
                  surface_tolerance,
                  pt_basis,
                  dis_tol );

         /* tile the surface */

         HSsurface_tiler(
               surf,
               num_upoints, num_vpoints,
               upoints, vpoints );
         }
            
      if (surf->num_boundaries != actual_num_boundaries)
         {
         surf->num_boundaries = actual_num_boundaries;
         }
      }

wrapup:;
   /*
    * Reset the IFB delete mode.
    */

#  if defined( ENV5 )
   if( (active_window->type & HShardware_LB_GPIPE) && (options & HS_BST_DELETE) )
      sh_set_delete_mode( active_window->hwin_no, 0, HS_BACKGROUND_Z );
#  endif

   if (upoints) free( (char *) upoints );
   if (vpoints) free( (char *) vpoints );

wrapup2:;
   }  /* HSbsurf_tiler */


/*---HSfem_tiler------------------------------------------------------------------------*/

void HSfem_tiler( IGRint pipe_no,
                  struct IGRbsp_surface *surf,
                  IGRint num_upoints,
                  IGRint num_vpoints,
               IGRdouble *upoints,
               IGRdouble *vpoints,
               IGRdouble range[],
                  IGRint color,
                  IGRint options,
               IGRdouble surface_tolerance,
         struct IGResfct *fem_data,
               IGRdouble *clip_range )

/*
NAME
   HSfem_tiler

DESCRIPTION
   HSfem_tiler sets the global variables for FEM tiling and then calls
   HSsurface_tiler to tile the FEM contour tile.

PARAMETERS
   pipe_no (IN) - gpipe id
   surf (IN) - surface definition
   num_upoints (IN) - number of points in u
   num_vpoints (IN) - number of points in v
   upoints (IN) - array of sample points in u
   vpoints (IN) - array of sample points in v
   range (IN) - surface range points
   color (IN) - surface color
   options (IN) - display options
   surface_tolerance (IN) - surface interpolation check tol
   fem_data (IN) - FEM type-specific data
   clip_range (IN) - element clip range in dits

GLOBALS USED
   tiling_parms
   active_window

HISTORY
   07/20/89    C.M. Jablonski
      Created
   02/10/92    S.P. Rogers
      Added prologue documentation

*/

   {
#  if defined( ENV5 )
   IGRint      save_type;
#  endif

   HSactivate_window( pipe_no );
   if (tiling_parms.status != HSSTAT_OK) goto wrapup;

   /*
    *  Lets check for an unsupported object
    */
    
#  if defined( ENV5 )
   save_type = active_window->type;
   
   /* FEM elements cannot be displayed if zbuffer is locked */
   if (active_window->type & HShardware_ZB_MASK)
      {
      active_window->type = (active_window->type & HShardware_MPX_MASK);
      active_window->active_zbuffer = 1;
      
      if( active_window->zbuf == NULL )
         {
         HSallocate_active_window_buffers(   active_window->vs_no,
                                             active_window->x_dits,
                                             active_window->y_dits );
                                             
         if (tiling_parms.status != HSSTAT_OK) goto wrapup;

         (*active_window->init_window[active_window->active_zbuffer])(
                        active_window->x_dits,
                        active_window->y_dits );
                        
         active_window->unsupported_zbuffer_allocated = TRUE;
         }
      }
#  endif

   /* check the range */
   
   HScheck_object_range( range );
   if (tiling_parms.status != HSSTAT_OK) goto wrapup;

   /* set active tiling parameters */
   
   HSset_ele_clip_range( clip_range );
   if (options & HS_FEM_DELETE)
      HSset_element_facet_type( AREA_FILL );
   else
      HSset_element_facet_type( FEM_TILE );
      
   HSset_element_tolerances( surface_tolerance, 0.000001, 0.0 );
   HSfem_local_fem_data = fem_data;
   HSfem_doing_mesh_lines = options & HS_FEM_MESH;
   if (active_window->using_ramps)
   {
      HSinit_paint_fem_ramp( &color, &options );
   }
   else
   {
      HSinit_paint_fem( &color, &options );
   }
   
   /* tile the surface */
   
   HSsurface_tiler(
         surf,
         num_upoints, num_vpoints,
         upoints, vpoints);

#  if defined( ENV5 )
   /*
    *  Reset back for supported objects
    */

   active_window->type = save_type;
   active_window->active_zbuffer = 0;
#  endif

wrapup:;
   }  /* HSfem_tiler */



/*---HSfem_tilerII--------------------------------------------------------------------------*/


void HSfem_tilerII( IGRint pipe_no,
                    struct HSfem_tri_mesh *mesh,
                 IGRdouble *clip_range,
                    IGRint color,
                    IGRint options,
                 IGRdouble surface_tolerance )

/* 
NAME
   HSfem_tilerII

DESCRIPTION
   HSfem_tilerII is designed to streamline the shading of FEM structures.
   This function takes as input a mesh of trianglular facets and sends them
   directly to the faceting/processing functions.

PARAMETERS
   pipe_no (IN) - gpipe id
   mesh (IN) - mesh of triangular facets
   clip_range (IN) - range for clipping functions
   color (IN) - surface color
   options (IN) - display options
   surface_tolerance (IN) - surface interpolation check tol

GLOBALS USED
   tiling_parms
   active_window

HISTORY
   5/17/91       R. Druzynski
      Created
   02/10/92    S.P. Rogers
      Added prologue documentation
*/

{
#  if defined( ENV5 )
   IGRint            save_type;
#  endif

   int            i;
   struct fem_vert       *current_triangle=NULL;   /* first vertex of triangle */
   struct fem_color       *current_color=NULL;   /* color of vertex or triangle */
   struct HStri_mesh              trimesh;

   HSactivate_window( pipe_no );

#  if defined( ENV5 )
   if (active_window->type & HShardware_LB_EG)
      {
      HSconvert_to_trimesh(mesh, &trimesh); 
         (*active_window->process_mesh)( active_window->EG_vc_no, &trimesh );
      }
   else 
#  endif
      {

      /*
       * Need to transform the mesh points from world coordinates to 
       * normalized coordinates.
       */

      HSfem_transform( mesh );

      if (tiling_parms.status != HSSTAT_OK) goto wrapup;

      /*
       *  Lets check for an unsupported object
       */
    

#     if defined( ENV5 )
      save_type = active_window->type;

      /* FEM elements cannot be displayed if zbuffer is locked */
      
      if (active_window->type & HShardware_ZB_MASK)
         {
         active_window->type = (active_window->type & HShardware_MPX_MASK);
         active_window->active_zbuffer = 1;
      
         if( active_window->zbuf == NULL )
            {
            HSallocate_active_window_buffers(   active_window->vs_no,
                                                active_window->x_dits,
                                                active_window->y_dits );
                                                
            if (tiling_parms.status != HSSTAT_OK) goto wrapup;

            (*active_window->init_window[active_window->active_zbuffer])(
                        active_window->x_dits,
                        active_window->y_dits );
                        
            active_window->unsupported_zbuffer_allocated = TRUE;
            }
         }
#     endif

      /* set active tiling parameters */

      HSset_element_edge_marking_flag(options & (HS_BST_EDGES | HS_BST_REV_EDGES));
      HSset_ele_clip_range( clip_range );
      HSset_element_cull_flag ( HS_CULL_NONE );

      if (options & HS_FEM_DELETE)
         HSset_element_facet_type( AREA_FILL );
      else
         HSset_element_facet_type( FEM_MESH );

      HSset_element_tolerances( surface_tolerance, 0.000001, 0.0 );
      HSfem_doing_mesh_lines = options & HS_FEM_MESH;

      HSinit_paint_fem(&color, &options);

      /* process the mesh */

      for (i=0; i<(mesh->num_verts-2); i++)      /* for each triangle */
         {
         current_triangle = &mesh->verts[i];   /* assign first vertex of facet*/
         current_color = &mesh->colors[i];   /* assign first color of facet */
         HScreate_fem_facetII(current_triangle, current_color, mesh->area_fill); 
         clip_and_shade();
         }
      
#     if defined( ENV5 )
      /*
       *  Reset back for supported objects
       */

      active_window->type = save_type;
      active_window->active_zbuffer = 0;
#  endif
      }
wrapup:;
   }  /* HSfem_tilerII */

/*---HSrender_tiler------------------------------------------------------------------------*/

void   HSrender_tiler( IGRint pipe_no,
                       struct IGRbsp_surface *surf,
                    IGRdouble range[],
                   IGRboolean from_solid,
                    IGRdouble surface_tolerance,
                    IGRdouble pt_basis,
                    IGRdouble dis_tol,
                       struct HS_element_rendering_parms *render_parms,
                   IGRboolean dont_cull,
                       IGRint acc_mode,
                       IGRint accuracy,
                    IGRdouble win_cht,
                    IGRdouble *u_range,
                    IGRdouble *v_range,
                    IGRdouble *clip_range )

/*
NAME
   HSrender_tiler

DESCRIPTION
   HSrender_tiler sets the global variables needed for rendering,
   then calls HSsurface_tiler to tile the surface.

PARAMETERS
   pipe_no (IN) - gpipe id
   surf (IN) - surface definition
   range (IN) - surface range points
   from_solid (IN) - TRUE if part of a solid
   surface_tolerance (IN) - surface interpolation check tol
   pt_basis (IN) - surface parameter basis tolerance
   dis_tol (IN) - world-coordinate distance tolerance
   render_parms (IN) - rendering parameter pointer
   dont_cull (IN) - TRUE, if no culling should be done
   acc_mode (IN) - shading accuracy mode
   accuracy (IN) - active shading accuracy
   win_cht (IN) - window based shading accuracy
   u_range (IN) - u range of boundaries
   v_range (IN) - v range of boundaries
   clip_range (IN) - element clip range in dits

GLOBALS USED
   active_window
   tiling_parms

HISTORY
   07/20/89   C.M. Jablonski
      Created
   11/28/89   S.P. Rogers
      Added dont_cull flag
   09/13/90     S.P. Rogers
      Changed to calculate sample points instead of having them passed in
   02/10/92    S.P. Rogers
      Added prologue documentation
*/

   {
   IGRint      actual_num_boundaries;
   IGRint      transparency;
   IGRint      num_upoints;      /* number of points in u      */
   IGRint      num_vpoints;      /* number of points in v      */
   IGRdouble   *upoints = NULL;       /* array of sample points in u      */
   IGRdouble   *vpoints = NULL;   /* array of sample points in v      */
   int         min_insert;

   HSactivate_window( pipe_no );
   if (tiling_parms.status != HSSTAT_OK) goto wrapup;

   /* throw out surfaces whose u/v range is too small to process */
   if ( ((u_range[1] - u_range[0]) < KNOT_TOL) ||
        ((v_range[1] - v_range[0]) < KNOT_TOL) )
      {
      goto wrapup;
      }

   min_insert = 0;
   if( active_window->perspective )
      if( render_parms->surface_texture != NULL &&
          render_parms->surface_texture->Fname[0] != 0 )
             {
             min_insert = 15;
             }
      
   HScalc_surf_sample_points(
            surf,
            acc_mode,
            accuracy,
            win_cht,
            u_range,
            v_range,
            &num_upoints,
            &num_vpoints,
            &upoints,
            &vpoints,
            min_insert,
            pt_basis );

   /*
    *  Remember the number of boundaries then call routine to
    *  check for 3 point boundaries.  Process the surface then
    *  return the actual num boundaries to the structure
    */

   actual_num_boundaries = surf->num_boundaries;
   surf->num_boundaries = HScheck_bnds(surf);

   if ((surf->num_boundaries) ||
       (surf->on_off) ||
       (!actual_num_boundaries))
      {    

      /* check the range */

      HScheck_object_range( range );
      if (tiling_parms.status != HSSTAT_OK) goto wrapup;

      /* set active tiling parameters */

      HSset_ele_clip_range( clip_range );
      HSset_element_facet_type( RENDERED );
      HSset_element_rendering_parms( render_parms );

      /* set back plane cull flag */

      transparency = (render_parms->transparency > 0.0) ? (GR_BST_TRANSP) : (0);

      if ( dont_cull )
         HSset_element_cull_flag( HS_CULL_NONE  );
      else
         HSset_cull_flag ( surf, from_solid, transparency, range );
   
      /* set the global variables necessary to check surface interpolation */

      HSset_element_geometry( surf );
      HSset_element_tolerances(
            ((surface_tolerance < 1.0) ? (1.0) : (surface_tolerance)),
            pt_basis,
            dis_tol );

      /* tile the surface */

      HSsurface_tiler(
            surf,
            num_upoints, num_vpoints,
            upoints, vpoints );
      }
            
   if (surf->num_boundaries != actual_num_boundaries)
      {
      HSset_status( HSSTAT_BOUND_ERROR );
      surf->num_boundaries = actual_num_boundaries;
      }
            
wrapup:
   if (upoints) free( (char *) upoints );
   if (vpoints) free( (char *) vpoints );
   }  /* HSrender_tiler */


/*---HSget_minimum_x----------------------------------------------------------*/

IGRint HSget_minimum_x( IGRint pipe_no,
                        struct IGRbsp_surface *surf,
                     IGRdouble range[],
                    IGRboolean from_solid,
                     IGRdouble surface_tolerance,
                     IGRdouble pt_basis,
                        struct HS_element_rendering_parms *render_parms,
                        IGRint acc_mode,
                        IGRint accuracy,
                     IGRdouble win_cht,
                     IGRdouble *u_range,
                     IGRdouble *v_range )

/*
NAME
   HSget_minimum_x

DESCRIPTION
   HSget_minimum_x returns the minimum x in viewing coordinates
   within the given active parametric region.  It finds the minimum
   x value by tiling the surface and searching all points within the
   active region.

PARAMETERS
   pipe_no (IN) - gpipe id
   surf (IN) - surface definition
   range (IN) - surface range points
   from_solid (IN) - TRUE if part of a solid
   surface_tolerance (IN) - surface interpolation check tol
   pt_basis (IN) - surface parameter basis tolerance
   render_parms (IN) - rendering parameter pointer
   acc_mode (IN) - shading accuracy mode
   accuracy (IN) - active shading accuracy
   win_cht (IN) - window based shading accuracy
   u_range (IN) - u range of boundaries
   v_range (IN) - v range of boundaries

RETURN VALUES
   The minimu X in viewing coordinates of the surface or HR_TOSS_SURFACE
   if an error occured.

GLOBALS USED
   active_window
   tiling_parms

HISTORY
   07/20/89   C.M. Jablonski
      Created
   09/13/90  S.P. Rogers
      Changed to calculate sample points
      instead of having them passed in
   02/10/92    S.P. Rogers
      Added prologue documentation

*/

   {
   IGRint      num_upoints;      /* number of points in u      */
   IGRint      num_vpoints;      /* number of points in v      */
   IGRdouble   *upoints = NULL;       /* array of sample points in u      */
   IGRdouble   *vpoints = NULL;       /* array of sample points in v      */


   /* throw out surfaces whose u/v range is too small to process */

   if ( ((u_range[1] - u_range[0]) < KNOT_TOL) ||
        ((v_range[1] - v_range[0]) < KNOT_TOL) )
      {
      goto wrapup;
      }

   /* initialize the static range parameters */

   min_x = (IGRdouble)HR_TOSS_SURFACE;
   min_u = u_range[0];
   max_u = u_range[1];
   min_v = v_range[0];
   max_v = v_range[1];

   HScalc_surf_sample_points(
            surf,
            acc_mode,
            accuracy,
            win_cht,
            u_range, v_range,
            &num_upoints, &num_vpoints,
            &upoints, &vpoints,
            (int)0, pt_basis );

   /* check the surface against the window range */

   HSactivate_window( pipe_no );
   HScheck_object_range( range );
   if (tiling_parms.status != HSSTAT_OK)
      {
      min_x = (IGRdouble)HR_TOSS_SURFACE;
      goto wrapup;
      }

   /* set active tiling parameters */

   HSset_element_facet_type( FIND_MIN_X );

   /* tile the surface */

   HSsurface_tiler (surf, num_upoints, num_vpoints, upoints, vpoints);
   if (tiling_parms.status != HSSTAT_OK) min_x = (IGRdouble)HR_TOSS_SURFACE;

wrapup:
   if (upoints) free( (char *) upoints );
   if (vpoints) free( (char *) vpoints );

   return( (IGRint)(min_x) );
   }  /* HSget_minimum_x */

