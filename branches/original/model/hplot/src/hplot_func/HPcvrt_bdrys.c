#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#if defined (CLIX)
#include <EG.h>
#endif

#include "wl.h"

#include "OMminimum.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "igr.h"
#include "gr.h"
#include "hplot.h"
#include "hstiler.h"
#include "hslight.h"
#include "HStl_global.h"
#include "HStl_window.h"
#include "HStl_element.h"
#include "hsdisplay.h"
#include "HPglobal.h"
#include "HPdef.h"
#include "igrdp.h"
#include "dpstruct.h"
#include "dp.h"
#include "dpdef.h"
#include "HSd_fixedpt.h"

#include "HSfem_spt.h"

#include "HPpr_hplot_f.h"

/*----------------------
 *  for
 *     CHT
 *     add_pts_between_knots
 *     get_curve_sampling_points
 */

#include "HSe2_mesher.h" 
#include "HSpr_tiler_f.h"
#include "bstypes.h"
#include "bscveval.h"

/*---------------------*/

#define ORTHO_3D   1

#define DC_DEBUG   0


/*--- HPconvert_surface_boundaries ------------------------------------------*/

/*
NAME
	HPconvert_surface_boundaries
	
KEYWORD
	HSplot
	boundaries
	
DESCRIPTION
	Convert a bspline curve into a packed boundary
	
PARAMETERS
	surf             :(IN) : Pointer to the bspline surface geometry
	bdrys            :(IN) : Pointer to a list of bspline curves to pack
	num_bdrys        :(IN) : Has no use, should be removed
	tiling_tolerance :(IN) : Tolerance at which to stroke the curves
	
GLOBALS USED
	(none)
	
RETURN VALUES
	HP_I_Success:  The code assumes that there will be no errors.  This
	               should be expanded upon
	               
ALGORITHM
	For each boundary curve, call HPstroke_nurb_curve, which returns 
	a list vertices for the packed boundary.
	
HISTORY
	??/??/??	M. Lanier
		Created

*/

#if defined(__STDC__) || defined(__cplusplus)
	IGRint HPconvert_surface_boundaries    (struct IGRbsp_surface *surf, 
						  struct IGRbsp_curve *bdrys, 
								  int num_bdrys, 
							       double tiling_tolerance )						       
#else
	IGRint	HPconvert_surface_boundaries( surf, bdrys, num_bdrys, tiling_tolerance )

	struct IGRbsp_surface	*surf;
	struct IGRbsp_curve	*bdrys;
	int			num_bdrys;
	double			tiling_tolerance;
#endif

	{
	int                     i, j;
	IGRint			num_pts;
	IGRdouble		*bnd_cv_poles;

	struct IGRbsp_curve	boundary_curve;
	struct IGRbsp_curve	*bsp_bdry_curve;

	/*
         *  Convert the boundaries. Since the boundaries are stored in the metafile as
	 *  NURB curves, here I have to convert them to (u,v) linestring format before
	 *  writing them to surf.
	 */

	num_bdrys=0;
	if( surf->num_boundaries )
		{
		bsp_bdry_curve = bdrys;

		surf->bdrys = (struct IGRbsp_bdry_pts *)malloc
					( surf->num_boundaries * 
					sizeof( struct IGRbsp_bdry_pts ) );

		for( i=0; i < surf->num_boundaries; bsp_bdry_curve++, i++ )
			{
			if( bsp_bdry_curve->order == 2 )
				{
					
				/*
				 *  If the boundary curve is 2nd order, then stroking 
				 *  is unnecessary. The (u, v) linestring can be 
				 *  formed directly from the poles.
				 */
			 
				num_pts = bsp_bdry_curve->num_poles;
				surf->bdrys[i].num_points = num_pts;
				num_pts *= 2;
				surf->bdrys[i].points = (IGRdouble *)malloc( num_pts * sizeof(IGRdouble) );

				for( j=0; j<num_pts; j++ )
					surf->bdrys[i].points[j] = bsp_bdry_curve->poles[j];
				}
			else
				{
				
				/*
				 *  If the boundary curve is of order > 3, then the curve 
				 *  must be stroked. This is done in the routine stroke_nurb_curve.
				 */

				memset( &boundary_curve, 0, sizeof( boundary_curve ) );

				boundary_curve = *bsp_bdry_curve;
				bnd_cv_poles = boundary_curve.poles;
				boundary_curve.poles = (IGRdouble *)malloc( boundary_curve.num_poles * 3 * sizeof( IGRdouble ) );
				
				for( j=0; j<boundary_curve.num_poles; j++ )
					{					
					boundary_curve.poles[3*j    ] = bnd_cv_poles[2*j    ] * PRECISION_FACTOR;
					boundary_curve.poles[3*j + 1] = bnd_cv_poles[2*j + 1] * PRECISION_FACTOR;
					boundary_curve.poles[3*j + 2] = 0.0;
					}

				HPstroke_nurb_curve( 
						&boundary_curve, 
						tiling_tolerance,
						&surf->bdrys[i].num_points,
						&surf->bdrys[i].points );

				free( (char *)boundary_curve.poles );
				}
			}
		}
      
	return( HP_I_Success );
	}


static IGRdouble	*bound_buffer;

static int curve_count = 0;

static int	vcount = 0;

/*---HPstroke_nurb_curve--------------------------------------------------------------*/

/*
NAME
	HPstroke_nurb_curve
	
KEYWORD
	HSplot
	boundaries
	memory question
	stroke question
	
DESCRIPTION
	Give a bspline curve, stroke at the given tiling_tolerance.  Return the
	stroke points and cound to the caller.
	
PARAMETERS
	curve            :(IN) : Pointer to the bspline curve geometry
	tiling_tolerance :(IN) : Tolerance at which to stroke the curve.  Notice
	                         that it is never reference.  It's need is questioned.
	num_points       :(OUT): The number of strokes generated
	points           :(OUT): List of strokes generated
	
GLOBALS USED
	HPband_info      : Get the accuracy mode and value, and the pipe number
	HPglobal         : global information, this case references perspective
	
RETURN VALUES
	status           : A status value generated during the stroking.  

NOTES
	   Need to look at a memory management issue concerning the bound_buffer allocated
	in this code	
	
	   Need to look at why the number of points is divided by 2 after the strokes
	have been placed in the output buffer

HISTORY
	??/??/??	M. Lanier
		Created
*/

#if defined(__STDC__) || defined(__cplusplus)
	int HPstroke_nurb_curve    (struct IGRbsp_curve *curve, 
						 double tiling_tolerance, 
						IGRlong *num_points, 
					      IGRdouble **points )					 
#else
	int	HPstroke_nurb_curve( curve, tiling_tolerance, num_points, points )

	struct IGRbsp_curve	*curve;
	double			tiling_tolerance;
	int			*num_points;
	double			**points;
#endif

	{
	IGRdouble	range[6];
	IGRint		num_upoints;
	IGRdouble	*upoints, *p;
	IGRdouble	tolerance;
	IGRint		i, status;
	IGRdouble	CHT();
	
	/*
	 *  Get list of parametric points to create line strings with.
	 *
	 *  If accuracy mode is active, us the accuracy method to generate
	 *  sample points for the curve
	 */

	tiling_tolerance = 0.0;		
	if( HPband_info.acc_mode )
		{
		add_pts_between_knots(
			curve->order,
			curve->num_poles + curve->order,
			curve->knots,
			HPband_info.accuracy,
			&num_upoints,
			&upoints );
							
		if( tiling_parms.status != HSSTAT_OK ) goto wrapup;
		}
	else
		{
		p = curve->poles;

		/*
		 *  Get the range of the curve from the poles
		 */
		 
		range[3] = range[0] = *p++;
		range[4] = range[1] = *p++;
		range[5] = range[2] = *p++;

		for( i=1; i<curve->num_poles; i++ )
			{
			if( *p < range[0] ) range[0] = *p;
			if( *p > range[3] ) range[3] = *p;
			p++;

			if( *p < range[1] ) range[1] = *p;
			if( *p > range[4] ) range[4] = *p;
			p++;

			if( *p < range[2] ) range[2] = *p;
			if( *p > range[5] ) range[5] = *p;
			p++;

			}

		/*
		 *  Call CHT to get the tolerance for this curve, then call
		 *  get_curve_sampling_points to get sample points for the
		 *  curve.
		 */
		 
		tolerance = CHT(HPband_info.pipe_no,
				(double)1.0,
 				range );

		get_curve_sampling_points(
			curve,
			tolerance,
			&num_upoints,
			&upoints );
							
		if( tiling_parms.status != HSSTAT_OK ) goto wrapup;
		}

	if( HPglobal.debug )
		{
                if( ((++curve_count) % (HPglobal.debug)) == 0 )
                         fprintf( stderr, "Tile boundary#%-5d     (%1d:%1d) (%1d)\n",
                            curve_count, HPglobal.objid, HPglobal.osnum, curve_count );
		}
        else
        if( HPglobal.flags & HPpflag_FEEDBACK_OBJID )
                {
                fprintf( stderr, "Process boundary: (%1d:%1d)\n",
                                HPglobal.objid, HPglobal.osnum );
                }



	/*
	 *  Allocate a place to store the strokes and then call BScveval to
	 *  stroke the curve.  
	 *
	 *  <<<< Is bound buffer ever free'd >>>>
	 */
	 
	bound_buffer = (IGRdouble *)malloc( num_upoints * 2 * sizeof( IGRdouble ) );

	vcount = 0;
		{
		int	xi;
		double	xp[3];
	
		for( xi=0; xi<num_upoints; xi++ )
			{
			BScveval( curve, upoints[xi], 0, (IGRpoint *)xp, (BSrc *)&status );
			bound_buffer[vcount++] =  xp[0] / PRECISION_FACTOR;
			bound_buffer[vcount++] =  xp[1] / PRECISION_FACTOR;
			}
		}

	/*
	 *  <<<< Guessing, I would say that the num_points value represent
	 *  then number of pairs of point.  But I wonder.  Need to verify
	 *  what is going on here >>>>
	 */
	 
	*num_points = vcount >> 1;
	*points = bound_buffer;

wrapup:

	if( upoints ) free( upoints );
	
	if( status )
		status = HP_I_Success;
		
	return( status );
	}
