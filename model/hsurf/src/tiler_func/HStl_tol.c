
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
#include <math.h>

#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "gr.h"

#include "bstypes.h"
#include "bssfarrevmt.h"
#include "bscvkttol2.h"
#include "bscvarreval.h"

#include "hsmath.h"
#include "hstiler.h"
#include "hslight.h"

#include "HStl_global.h"
#include "HStl_window.h"
#include "HStl_element.h"
#include "HSfem_spt.h"

#include "HSe2_mesher.h"
#include "hsdisplay.h"
#include "HSpr_tiler_f.h"


#if defined (__) 
#undef __
#endif

#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif



/* HStl_tol.c */
static void HSget_nodes __((			      IGRshort order, 
						       IGRlong num_knots, 
						     IGRdouble *knots, 
							IGRint *num_vals, 
						     IGRdouble *nodes, 
						     IGRdouble basis_tol));
						     
static IGRint HSnum_chord_height_points __((	     IGRdouble *xtan, 
						     IGRdouble *xcrd, 
						     IGRdouble delta, 
						     IGRdouble cht));
						     
static void HSget_num_points_to_add __((		IGRint num_a_points, 
							IGRint num_b_points, 
							IGRint a_incr, 
							IGRint b_incr, 
						     IGRdouble *a_points, 
						      IGRpoint *sfpoints, 
						      IGRpoint *a_partial, 
						     IGRdouble tolerance,
							   int min_insert, 
							IGRint *num_a_to_add));
							
static void HSadd_toleranced_points __((		IGRint num_points, 
						     IGRdouble *points, 
							IGRint *num_to_add, 
							IGRint *num_new_points, 
						     IGRdouble **new_points));

#if defined(__cplusplus)
}
#endif


#undef __


#define BSSFARREVMT_ENABLED	TRUE
#define KNOT_TOL	0.000005
#define DOT_TOL		0.00001


/*---add_pts_between_knots-------------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	void add_pts_between_knots( IGRshort order,
				     IGRlong num_knots,
				   IGRdouble *knots,
				      IGRint num_insert,
				      IGRint *num_vals,
				   IGRdouble **sample_pts )
#else
	void add_pts_between_knots( 
			order, 
			num_knots, 
			knots, 
			num_insert,
			num_vals, 
			sample_pts )

	IGRshort         order;        /* input  - order of curve                    */
	IGRlong          num_knots;    /* input  - number of knots                   */
	IGRdouble        *knots;       /* input  - knot vector                       */
	IGRint           num_insert;   /* input  - number of knots to be inserted    */
	                               /*          between adjacent knots            */
	IGRint           *num_vals;    /* output - number of knot values             */
	IGRdouble	 **sample_pts; /* output - ptr to array of knot values       */
#endif

/**
NAME
	add_pts_between_knots
	
DESCRIPTION
	Generates a list of sampling values which is the original knot vector
	with a requested number of extra points uniformly spaced between knots.

PARAMETERS
	order		:(IN) :  order of curve
	num_knots	:(IN) :  number of knots
	knots		:(IN) :  knot vector
	num_insert	:(IN) :  number of knots to be inserted between adjacent knots
	num_vals	:(OUT):  number of knot values
	sample_pts	:(OUT):  ptr to array of knot values
	
GLOBALS USED
	(none)

HISTORY: 
	09/01/86	S. A. Rapa
		created
		
	01/31/92	M. Lanier
		Added this header
**/

	{
	IGRdouble	value;
	IGRdouble	*pnts;
	register IGRint	i, j;


	if( order == 2 ) num_insert = 0;

	/*
	 * Allocate space for list of sampling points.
	 */

	pnts = (IGRdouble *)malloc( (unsigned)(1 + (num_insert+1) * (num_knots-order-1)) * sizeof (IGRdouble));
	
	if( !pnts )
		{
		HSset_status( HSSTAT_ALLOC_ERROR );
		}
	else
		{
		*sample_pts = pnts;
		*num_vals = 1;
		*pnts++ = knots[order - 1];

		for( i=order; i<=(num_knots - order); i++ )
			{
			
			/*
			 * Return only unique knot values.
			 */

			if( FABS(knots[i] - knots[i - 1]) > KNOT_TOL )
				{
				value = (knots[i] - knots[i - 1]) / (num_insert + 1);
				*num_vals += num_insert + 1;
	
				for( j=1; j<=num_insert; j++ )
					*pnts++ = knots[i - 1] + j * value;
				
				*pnts++ = knots[i];
				}
			}
		}
	}

#ifndef MICROCODE
/*---CHT-------------------------------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	IGRdouble CHT( IGRint pipe_no,
		    IGRdouble win_tol,
		    IGRdouble *range )
#else
	IGRdouble	CHT( pipe_no, win_tol, range )

	IGRint		pipe_no;
	IGRdouble	win_tol;
	IGRdouble	*range;
#endif

/**
NAME
	CHT
	
DESCRIPTION
	Computes an appropriate dit-based chord-height tolerance based on
	the world-based CHT, window scale, and perspective.
	
PARAMETERS
	pipe_no		:(IN) :  active window gpipe id
	win_tol		:(IN) :  window based chord-height tolerance
	range		:(IN) :  range of the element

GLOBALS USED
	active_window
	
RETURN VALUES
	chord_height_tolerance:
	
HISTORY
	02/04/87	S. A. Rapa
		Created
		
	01/31/92	M. Lanier
		Added this header
**/

	{
	IGRint		x, y, z, w;
	IGRdouble	ele_range[32], *ele_range_ptr;
	IGRdouble	max_z, min_z, sample_z;
	IGRdouble	temp_range[6];
	IGRdouble	chord_height_tolerance;


	HSactivate_window( pipe_no );

	chord_height_tolerance =  win_tol / active_window->wv_scale;

	if( active_window->perspective )
		{
		if (range==0) 
		{
			if (getenv("HS_REPORT_RANGE_NULL"))
				fprintf(stderr,"HStl_tol.c CHT error range sent in as NULL (set to 0,0,0 .1,.1,.1)\n"); 
			temp_range[0]=temp_range[1]=temp_range[2]=0.0;
			temp_range[3]=temp_range[4]=temp_range[5]=0.1;
			range=temp_range;
		}

		/*
		 * Transform the range cube.
		 */

		ele_range_ptr = (IGRdouble *)ele_range;
		
		for( x=0; x<6; x+=3 )
		for( y=1; y<6; y+=3 )
		for( z=2; z<6; z+=3 )
			{
			*ele_range_ptr++ = range[x];
			*ele_range_ptr++ = range[y];
			*ele_range_ptr++ = range[z];
			}

		transform_points( TRUE, 8, ele_range, 8 );

		/*
		 * Get the transformed range.
		 */

		min_z = ele_range[24];
		max_z = min_z;
		
		for( w=25; w<32; w++ )
			{
			if( ele_range[w] < min_z ) min_z = ele_range[w];
			if( ele_range[w] > max_z ) max_z = ele_range[w];
			}

		if( min_z < 0.0 ) min_z = 0.0;
		if( max_z < 0.025) max_z = 0.025;

		/*
		 * Choose sample z (z of nearest visible facet) to be 
		 * slightly further that nearest corner of range cube
		 * (20% back).  Make sure such a point isn't too close
		 * or behind the eye.
		 */

		sample_z = (max_z - min_z) * 0.2 + min_z;
		chord_height_tolerance *= sample_z;
		}

	return( chord_height_tolerance );
	}
#endif
 
/*--- HSget_nodes -------------------------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	static void HSget_nodes( IGRshort order, 
				  IGRlong num_knots, 
				IGRdouble *knots, 
				   IGRint *num_vals, 
				IGRdouble *nodes, 
				IGRdouble basis_tol)						     
#else
	static void	HSget_nodes( order, num_knots, knots, num_vals, nodes, basis_tol )

	IGRshort	order;
	IGRlong 	num_knots;
	IGRdouble  	*knots;
	IGRint  	*num_vals;
	IGRdouble 	*nodes;
	IGRdouble	basis_tol;
#endif

/**
NAME
	HSget_nodes
	
DESCRIPTION
	Computes a list of nodes from the given knot vector (if order = 2 for
	this parameter, then it simply returns the knots).  These will later
	be used as sampling points for computing a tolerance, so only
	interior nodes are returned.  It is not necessary that the knot
	vector be normalized.

PARAMETERS
	order		:(IN) :  order of the object
	num_knots	:(IN) :  number of knots
	knots		:(IN) :  array of knots
	num_vals	:(OUT):  number nodes
	nodes		:(OUT):  array of nodes
	
HISTORY
	02/04/87	S. A. Rapa
		Created
		
	01/31/92	M. Lanier
		Added this header
		Change function name from get_nodes
**/

	{
	IGRdouble	max_knot, min_knot;
	IGRdouble	knotsum;
	IGRint		i, j;

	/*
	 * If order 2, return the knots; otherwise return nodes.
	 */
	 
	if( order == 2 )
		{
		for( i=1; i<(num_knots - 1); i++ )
			*nodes++ = knots[i];
		*num_vals = num_knots - 2;
		}
	else
		{
		max_knot = knots[num_knots - order];
		min_knot = knots[order - 1];
		*nodes++ = min_knot;

		*num_vals = num_knots - order + 2;
		
		for( i=0; i<(num_knots - order); i++ )
			{
			knotsum = 0;
			
			for( j=1; j<order; j++ )
				knotsum += knots[i + j];
				
			knotsum /= (order - 1);

			if( (knotsum > (min_knot + basis_tol)) &&
			    (knotsum < (max_knot - basis_tol)) )
				*nodes++ = knotsum;
			else
				*num_vals -= 1;
			}

		*nodes = max_knot;
		}
	}

/*--- HSnum_chord_height_points -----------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	static IGRint HSnum_chord_height_points( IGRdouble *xtan,
						 IGRdouble *xcrd,
						 IGRdouble delta,
						 IGRdouble cht )
#else
	static IGRint	HSnum_chord_height_points( xtan, xcrd, delta, cht )
	
	IGRdouble	*xtan;		/* input - tangent vector at point a	*/
	IGRdouble	*xcrd;		/* input - point a - point b		*/
	IGRdouble	delta;		/* input - delta parametric distance	*/
	IGRdouble	cht;		/* input - chord-height tolerance	*/
#endif

/**
NAME
	HSnum_chord_height_points
	
DESCRIPTION
	Uses an estimated chord-height tolerancing scheme to determine how many 
	points should be sampled between two given points "a" and "b".

PARAMETERS
	xtan	:(IN) : tangent vector at point a
	xcrd	:(IN) : point a minus point b
	delta	:(IN) : delta parameteric distance
	cht	:(IN) : chord-height tolerance

RETURN VALUES
	the number of sample points to add in span
		
HISTORY
	02/04/87	S. A. Rapa
		Created

	02/16/89	M. Lanier / C. M. Jablonski
		Added pixel-tolerance optimization

	06/21/89	C. M. Jablonski
		Changed algorithm, changed return to IGRint.
		
	01/31/92	M. Lanier
		Added this header
		Changed the arguments tan, crd to xtan, xcrd, added local
			arrays tan, crd.  Copied contents xtan -> tan and
			xcrd -> crd.  Fixed problem inwhich contents of
			array in caller was getting corrupted.
		Change name of this function from num_chord_height_points.
**/

	{
	IGRdouble	crdlen, length, rad, alpha, cos_alpha, new_alpha;
	IGRdouble	crd[3], tan[3];
	
	if( cht < DOT_TOL ) return 0;

	memcpy( crd, xcrd, sizeof(double)*3 );
	memcpy( tan, xtan, sizeof(double)*3 );

	/* Normalize crd */
	crdlen = SQRT((crd[0] * crd[0]) + (crd[1] * crd[1]) + (crd[2] * crd[2]));

	if( crdlen < cht ) return(-1);

	if( crdlen > 0.0 )
		{
		crd[0] /= crdlen;
		crd[1] /= crdlen;
		crd[2] /= crdlen;
		}
	else
		{
		crd[0] = 0.0;
		crd[1] = 0.0;
		crd[2] = 0.0;
		}

	/* Normalize tan */
	length = SQRT((tan[0] * tan[0]) + (tan[1] * tan[1]) + (tan[2] * tan[2]));

	if( length > 0.0 )
		{
		tan[0] /= length;
		tan[1] /= length;
		tan[2] /= length;
		}
	else
		{
		tan[0] = 0.0;
		tan[1] = 0.0;
		tan[2] = 0.0;
		}

	/* Dot crd and tan */
	cos_alpha = (tan[0] * crd[0]) + (tan[1] * crd[1]) + (tan[2] * crd[2]);

	if ( (cos_alpha > 1 - DOT_TOL) || (cos_alpha < DOT_TOL) )
		{  /* vectors are parallel; insert 0 points */
		return(0);
		}  
	else
		{
		alpha = ACOS(cos_alpha);
		rad = crdlen / ( 2 * SIN(alpha) );
		if (rad < cht)
			{
			return(0);
			}
		else
			{
			new_alpha = ACOS(1 - cht / rad);

			if( new_alpha < DOT_TOL ) return 0;
			return((IGRint)(alpha / new_alpha));
			}
		}
	}

/*--- HSget_num_points_to_add -------------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	static void HSget_num_points_to_add( IGRint num_a_points,
					     IGRint num_b_points,
					     IGRint a_incr,
					     IGRint b_incr,
					  IGRdouble *a_points,
					   IGRpoint *sfpoints,
					   IGRpoint *a_partial,
					  IGRdouble tolerance,
						int min_insert,
					     IGRint *num_a_to_add )
#else
	static void	HSget_num_points_to_add(
				num_a_points, num_b_points,
				a_incr, b_incr,
				a_points, sfpoints, a_partial,
				tolerance,
				min_insert,
				num_a_to_add )
	
	IGRint		num_a_points;	/* input - number of sampling points	*/
	IGRint		num_b_points;
	IGRint		a_incr;		/* input - # of values between adjacent */
	IGRint		b_incr;		/*			points in a given dimension  */
	IGRdouble	*a_points;	/* input - array of parametric points	*/
	IGRpoint	*sfpoints;	/* input - array of surface points	*/
	IGRpoint	*a_partial;	/* input - array of partials along "a"	*/
	IGRdouble	tolerance;	/* input - chord-height tolerance	*/
	int		min_insert;
	IGRint		*num_a_to_add;	/* output - array of # of additional	*/
#endif
				/*		 points to sample		*/
/**
NAME
	HSget_num_points_to_add
	
DESCRIPTION
	Computes how many sampling points should be added between adjacent
	array entries by choosing the maximum number of chord-height tol.
	points needed for all mesh points in the other parametric dimension.
	The dimension (U or V) for which points will be added is "a", and the
	other one is "b".

PARAMETERS
	num_a_points, num_b_points	:(IN) :  number of sampling points
	a_incr, b_incr			:(IN) :  # of values between adjacent points 
							in a given dimension
	a_points			:(IN) :  array of parametric points
	sfpoints			:(IN) :  array of surface points
	a_partial			:(IN) :  array of partials along "a"
	tolerance			:(IN) :  chord-height tolerance
	min_insert			:(IN) :  minimum points to add
	num_a_to_add			:(OUT):  array of # of additional points to sample
	
HISTORY
	02/01/87	S. A. Rapa
		created

	05/05/89	C. M. Jablonski
		Added second call to N_C_H_P

	06/21/89	C. M. Jablonski
		Removed second call to N_C_H_P
		
	01/31/92	M. Lanier
		Added this header
		changed name from get_num_points_to_add
**/

	{
	IGRdouble	facet_vector[3];
	IGRint		max_insert, cht_points;
	IGRint		a_index1, a_index2, b_index, index;
	IGRint		next_point;

	for( a_index1=0, a_index2=1; a_index2<num_a_points; )
		{
			
		/*
		 * Find the maximum # of CHT points along "b".
		 */

		max_insert = -1;
		index = a_index1 * a_incr;
		next_point = a_index2 * a_incr;
		
		for( b_index=0; b_index<num_b_points; b_index++ )
			{
			facet_vector[0] = sfpoints[next_point][0] - sfpoints[index][0];
			facet_vector[1] = sfpoints[next_point][1] - sfpoints[index][1];
			facet_vector[2] = sfpoints[next_point][2] - sfpoints[index][2];

			cht_points = HSnum_chord_height_points(
					a_partial[index], facet_vector,
					a_points[a_index2] - a_points[a_index1],
					tolerance );
			
	 		if (cht_points > max_insert) max_insert = cht_points;
	 		
			index += b_incr;
			next_point += b_incr;
			}

		if( max_insert < min_insert ) max_insert = min_insert;

		num_a_to_add[a_index2 - 1] = max_insert;
		if (num_a_to_add[a_index2 - 1] >= 0) a_index1 = a_index2;
		a_index2++;
		}
	}

/*--- HSadd_toleranced_points -------------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	static void HSadd_toleranced_points( IGRint num_points,
					  IGRdouble *points,
					     IGRint *num_to_add,
					     IGRint *num_new_points,
					  IGRdouble **new_points )
#else
	static void	HSadd_toleranced_points( 	num_points, 
							points, 
							num_to_add,
							num_new_points, 
							new_points )

	IGRint		num_points;
	IGRdouble	*points;
	IGRint		*num_to_add;
	IGRint		*num_new_points;
	IGRdouble	**new_points;
#endif

/*
NAME
	HSadd_toleranced_points

DESCRIPTION
	Builds an array of sampling points by taking the array of nodes
	and adding the specified number of points between values as 
	computed by "HSget_num_points_to_add".

PARAMETERS
	num_points	:(IN) : number of points current;
	points		:(IN) : array of current list of points
	num_to_add;	:(IN) : array containing number of points to
					add withing each span
	num_new_points	:(OUT): number of points in expanded list
	new_points	:(OUT): array containing expanding list of points
	
HISTORY
	02/01/87	S. A. Rapa
		created
		
	01/31/92	M. Lanier
		Added this header
		Change name from add_toleranced_points
**/

{
	IGRint		span, this_point;
	IGRint		total_span_points;
	IGRdouble	current_value, delta;
	IGRdouble	*array;


	/*
	 * Allocate memory
	 */

	/* start with one to count the last point */
	*num_new_points = 1;

	/* guarantee that the first point is sampled */
	if( num_to_add[0] < 0 ) num_to_add[0] = 0;

	for( span=0; span<(num_points - 1); span++ )
		{
		if( num_to_add[span] >= 0 )
			*num_new_points += num_to_add[span] + 1;
		}
 		
	array = (IGRdouble *) malloc ((unsigned) *num_new_points * sizeof (IGRdouble));
	
	if( !array )
		{
		HSset_status( HSSTAT_ALLOC_ERROR );
		}
	else
		{
		*new_points = array;
 		current_value = points[0];
	
		for( span=0; span<(num_points-1); span++ )
			{
			if( num_to_add[span] >= 0 )
				{
				total_span_points = num_to_add[span] + 1;
 				delta = (points[span+1] - current_value) / total_span_points;
			
				for( this_point=0; this_point<total_span_points; this_point++ )
					{
					*array++ = current_value;
					current_value += delta;
					}
				
				current_value = points[span+1];
				}
			}
		
		/* sample the last point */
		*array = points[num_points - 1];
		}
	}

/*--- get_surf_sampling_points ----------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	void get_surf_sampling_points( struct IGRbsp_surface *surf,
						   IGRdouble tolerance,
						   IGRdouble *u_range,
						   IGRdouble *v_range,
						      IGRint *num_u,
						      IGRint *num_v,
						   IGRdouble **new_u,
						   IGRdouble **new_v,
							 int min_insert,
						   IGRdouble basis_tol )
#else
	void	get_surf_sampling_points(	surf, 
						tolerance,
						u_range, v_range,
						num_u, num_v, 
						new_u, new_v,
						min_insert, 
	 					basis_tol )

	struct	IGRbsp_surface	*surf;		/* input - surface definition	   */
	IGRdouble		tolerance;	/* input - chord-height tolerance  */
	IGRdouble		*u_range;	/* input - active parametric range */
	IGRdouble		*v_range;	/* input - active parametric range */
	IGRint			*num_u;		/* output - number of U sample pts */
	IGRint			*num_v;		/* output - number of V sample pts */
	IGRdouble		**new_u;	/* output - ptr to array of U pts  */
	IGRdouble		**new_v;	/* output - ptr to array of V pts  */
	IGRdouble		basis_tol;	/* input - basis tolerance */
	int			min_insert;
#endif

/*
NAME
	get_surf_sampling_points
	
DESCRIPTION
	Builds two arrays (U and V) of parametric sampling points, using
	a tolerancing scheme to determine optimum placement of such points.
	Space for the arrays is allocated here.

PARAMETERS
	surf		:(IN) :  pointer to surface geometry
	tolerance	:(IN) :  chord-height tolerance
	u_range		:(IN) :  active parametric range
	v_range		:(IN) :  active parametric range
	num_u		:(OUT):  number of U sample pts
	num_v		:(OUT):  number of V sample pts
	new_u		:(OUT):  ptr to array of U pts
	new_v		:(OUT):  ptr to array of V pts
	min_insert	:(IN) :  min point to add per span
	
HISTORY
	02/04/87	S. A. Rapa
		Created

	01/24/90	C. M. Jablonski
		Adjust sample point range.
		
	01/31/92	M. Lanier
		Added this header
*/

	{
	IGRdouble	*u_points, *v_points, *dbl_ptr;
	IGRpoint	*sfpoints, *u_partial, *v_partial;
	IGRint		*num_u_to_insert, *num_v_to_insert;
	IGRint		num_u_points, num_v_points, total_points;
	IGRint		i, j;
        BSrc	        math_return_code;
	IGRboolean	ind[4];
	IGRint		num_deg, *deg_ind = NULL;


	/*
	 *  Allocate space
	 */

	num_u_points = surf->u_num_knots - surf->u_order;
	num_v_points = surf->v_num_knots - surf->v_order;
	total_points = num_u_points * num_v_points;

	u_points = (IGRdouble *) malloc ((unsigned) num_u_points * sizeof (IGRdouble));
	v_points = (IGRdouble *) malloc ((unsigned) num_v_points * sizeof (IGRdouble));
	
	num_u_to_insert = (IGRint *) malloc ((unsigned) num_u_points * sizeof (IGRint));
	num_v_to_insert = (IGRint *) malloc ((unsigned) num_v_points * sizeof (IGRint));
	
	sfpoints = (IGRpoint *) malloc ((unsigned) total_points * sizeof (IGRpoint));
	
	u_partial = (IGRpoint *) malloc ((unsigned) total_points * sizeof (IGRpoint));
	v_partial = (IGRpoint *) malloc ((unsigned) total_points * sizeof (IGRpoint));
	
	if(!((u_points) && 
	     (v_points) && 
	     (num_u_to_insert) &&
	     (num_v_to_insert) && 
	     (sfpoints) && 
	     (u_partial) && 
	     (v_partial)))
		{
		HSset_status( HSSTAT_ALLOC_ERROR );
		}
	else
		{
		HSget_nodes(	surf->u_order, 
				surf->u_num_knots, 
				surf->u_knots,
				&num_u_points, 
				u_points, basis_tol);

		HSget_nodes(	surf->v_order, 
				surf->v_num_knots, 
				surf->v_knots,
				&num_v_points, 
				v_points, basis_tol);
			
			
		if( (surf->u_order > 2) || (surf->v_order > 2) || min_insert )
			{
			ind[0] = 1;
			ind[1] = 1;
			ind[2] = 1;
			ind[3] = 0;

#			if BSSFARREVMT_ENABLED
				BSsfarrevmt(	surf,
						num_u_points, u_points,
						num_v_points, v_points,
						ind,
						(IGRdouble *)sfpoints, 
						(IGRdouble *)u_partial, 
						(IGRdouble *)v_partial, NULL,
						&num_deg, &deg_ind,
						&math_return_code );
#			else
				BSsfarrev1(	&math_return_code, 
						surf,
				 		num_u_points, u_points,
				 		num_v_points, v_points,
				 		sfpoints, u_partial, v_partial );
#			endif
				 
			if (math_return_code)
				{
				HSset_status( math_return_code );
				goto wrapup;
 				}
			}

		/*
		 * U sampling points
		 */

		if( surf->u_order > 2 || min_insert )
			{
			HSget_num_points_to_add(num_u_points, num_v_points,
						1, 
						num_u_points, u_points, 
						sfpoints, 
						u_partial,
						tolerance,
						surf->u_order == 2 ? min_insert : (int)0,
						num_u_to_insert );
						
			HSadd_toleranced_points(	num_u_points, u_points,
						num_u_to_insert, num_u, new_u);
					
			if (tiling_parms.status != HSSTAT_OK) goto wrapup;

                        /* this is a kludge to keep sample points from lying  */
                        /* exactly on the middle of the boundaries of unioned */
                        /* cylinders.  See TR 119304946, and 91n4176          */
                        /* The 0.0000005 number was chosen because it is less */
                        /* than KNOT_TOL used in the tiler                    */
                        for ( i = 0; i < *num_u; i++ )
                           {
                           if ( (*new_u)[i] == 0.5 )
                              {
                              (*new_u)[i] = 0.5 - 0.0000005;
                              }
                           }

			}
		else
			{
			*num_u = num_u_points;
			*new_u = u_points;
			}

		/* limit the U sample points to the active U range */
		if ((u_range[0] > 0.0) || (u_range[1] < 1.0))
			{
			dbl_ptr = (IGRdouble *)(*new_u);
			for (i = 0; dbl_ptr[i] < (u_range[0] + basis_tol); i++);
			dbl_ptr[0] = u_range[0];
			j = 1;
			while (dbl_ptr[i] <( u_range[1] - basis_tol))
				dbl_ptr[j++] = dbl_ptr[i++];
			dbl_ptr[j] = u_range[1];
			*num_u = j + 1;
			}

		/*
		 * V sampling points
		 */

		if( surf->v_order > 2 || min_insert )
			{
			HSget_num_points_to_add(num_v_points, 
						num_u_points,
						num_u_points, 
						1,
						v_points, 
						sfpoints, 
						v_partial,
						tolerance,
						surf->v_order == 2 ? min_insert : (int)0,
						num_v_to_insert );
			
			HSadd_toleranced_points(	num_v_points, v_points,
						num_v_to_insert, num_v, new_v );
				
			if (tiling_parms.status != HSSTAT_OK) goto wrapup;

                        /* this is a kludge to keep sample points from lying  */
                        /* exactly on the middle of the boundaries of unioned */
                        /* cylinders.  See TR 119304946, and 91n4176          */
                        /* The 0.0000005 number was chosen because it is less */
                        /* than KNOT_TOL used in the tiler                    */
                        for ( i = 0; i < *num_v; i++ )
                           {
                           if ( (*new_v)[i] == 0.5 )
                              {
                              (*new_v)[i] = 0.49995;
                              }
                           }
			}
		else
			{
			*num_v = num_v_points;
			*new_v = v_points;
			}

		/* limit the V sample points to the active V range */
		if ((v_range[0] > 0.0) || (v_range[1] < 1.0))
			{
			dbl_ptr = (IGRdouble *)(*new_v);
			for (i = 0; dbl_ptr[i] < (v_range[0] + basis_tol); i++);
			dbl_ptr[0] = v_range[0];
			j = 1;
			while (dbl_ptr[i] < (v_range[1] - basis_tol))
				dbl_ptr[j++] = dbl_ptr[i++];
			dbl_ptr[j] = v_range[1];
			*num_v = j + 1;
			}
		}


wrapup:
	if( surf->u_order > 2 && u_points )	free((char *) u_points);		
	if( surf->v_order > 2 && v_points )	free((char *) v_points);
	
	if( num_u_to_insert )			free ((char *) num_u_to_insert);
	if( num_v_to_insert )			free ((char *) num_v_to_insert);
	
	if( u_partial )				free ((char *) u_partial);
	if( v_partial )				free ((char *) v_partial);
	if( sfpoints )				free ((char *) sfpoints);
	}

/*---get_curve_sampling_points---------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	void get_curve_sampling_points( struct IGRbsp_curve *curve,
						  IGRdouble tolerance,
						     IGRint *num_u,
						  IGRdouble **new_u )
#else
	void	get_curve_sampling_points(
			curve, 
			tolerance, 
			num_u, new_u )

	struct IGRbsp_curve	*curve;		/* input - curve definition		*/
	IGRdouble		tolerance;	/* input - chord-height tolerance  */
	IGRint			*num_u;		/* output - number of U sample pts */
	IGRdouble		*new_u;		/* output - ptr to array of U pts  */
#endif

/*
NAME
	get_curve_sampling_points
	
DESCRIPTION
	Builds an array of parametric sampling points, using
	a tolerancing scheme to determine optimum placement of such points.
	Space for the arrays is allocated here.

PARAMETERS
	curve		:(IN) :  pointer to curve geometry
	tolerance	:(IN) :  chord-height tolerance
	num_u		:(OUT):  number of U sample pts
	new_u		:(OUT):  ptr to array of U pts

HISTORY
	02/12/92	M. Lanier
		Joel added a call to BScvkttol2 on 02/10/92 which was causing
		HSplot to display "sqrt: DOMAIN error" every time it tried to
		process a curve.  Problem is the call requires the structure to
		have a NULL value for the weights if the curve is not rational,
		and the curve structure comming from HSplot has a valid weight
		address, even if the curve is rational or not.  I solved the 
		problem by conditionally calling BScvkttol2, with the weight 
		argument set to NULL if the curve was not rational.  I guess 
		I could have changed my curve structure, but this was easier,
		and quicker. Trust me.
	
	01/31/92	M. Lanier
		Added this header

	05/05/89	C. M. Jablonski
		Added second call to N_C_H_P

	02/04/87	S. A. Rapa
		Created

*/

	{
	IGRdouble	*points;
	IGRpoint	*cvpoints;
	IGRint		*num_to_insert;
	IGRint		num_points;
	BSrc		math_return_code;
	IGRint		span, cvp_index, pts_to_add;
 	IGRdouble	knot_tol;
 	BSrc		rc;
	IGRpoint	seg_vector;


	/*
	 * Allocate space
	 */

	num_points = curve->num_knots - curve->order;

	points = (IGRdouble *) malloc ((unsigned) num_points * sizeof (IGRdouble));
	num_to_insert = (IGRint *) malloc ((unsigned) num_points * sizeof (IGRint));
	cvpoints = (IGRpoint *) malloc ((unsigned) 2 * num_points * sizeof (IGRpoint));
	
	if(!((points) && (num_to_insert) && (cvpoints)))
		{
		HSset_status( HSSTAT_ALLOC_ERROR );
		}
	else
		{
		if( curve->rational )
	 		BScvkttol2( curve->order, curve->knots, curve->num_poles, curve->poles, curve->weights, &knot_tol, &rc);
	 	else
	 		BScvkttol2( curve->order, curve->knots, curve->num_poles, curve->poles, NULL, &knot_tol, &rc);
	 		
		HSget_nodes(	curve->order, 
				curve->num_knots, 
				curve->knots,
				&num_points, points, knot_tol );

		if( curve->order > 2 )
			{
			BScvarreval(	&math_return_code, 
					curve, 
					points, 
					num_points, 
					1, 
					(IGRdouble *)cvpoints );
				
			if( math_return_code )
				{
				HSset_status( math_return_code );
				goto wrapup;
				}

			for( span=0; span<(num_points - 1); span++ )
				{
				cvp_index = span << 1;
				
				seg_vector[0] = cvpoints[cvp_index + 2][0] - cvpoints[cvp_index][0];
				seg_vector[1] = cvpoints[cvp_index + 2][1] - cvpoints[cvp_index][1];
				seg_vector[2] = cvpoints[cvp_index + 2][2] - cvpoints[cvp_index][2];
				
				num_to_insert[span] = HSnum_chord_height_points(
									cvpoints[cvp_index + 1], 
									seg_vector,
									points[span + 1] - points[span],
									tolerance );

				pts_to_add = HSnum_chord_height_points(	cvpoints[cvp_index + 3], 
									seg_vector,
									points[span + 1] - points[span],
									tolerance );
				if (pts_to_add > num_to_insert[span])
					num_to_insert[span] = pts_to_add;
				}
			
			HSadd_toleranced_points(	num_points, points,
						num_to_insert, num_u, new_u);
					
			if (tiling_parms.status != HSSTAT_OK) goto wrapup;
			}
		else
			{
			*num_u = num_points;
			*new_u = points;
			}
		}

wrapup:
	if( (curve->order > 2) && points )	free ((char *) points);
	if( num_to_insert )			free ((char *) num_to_insert);
	if( cvpoints )				free ((char *) cvpoints);
	}
