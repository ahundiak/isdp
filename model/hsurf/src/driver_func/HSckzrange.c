
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:37 $
$Locker:  $
*/

#include <stdio.h>

#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "gr.h"
#include "dp.h"
#include "dpstruct.h"

#include "hstiler.h"
#include "hslight.h"

#include "HStl_global.h"
#include "HStl_window.h"
#include "HStl_element.h"

#include "HSe2_mesher.h"
#include "HSpr_driver.h"


/*
 *  Prototype declaration for static functions
 */


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


/* HSckzrange.c */
static void HSget_range_modifier __((void));
static void xxx_perspective_projection __((double *point));
static void HSget_screenspace_range __((double range[]));
static int HStotally_hidden __((double range[]));

#if defined(__cplusplus)
}
#endif


#undef __



static int	total_surfaces;
static int	num_surf_with_range;
static int	num_candidates;
static int	tossed_surfaces;
static int	first_time = TRUE;
static int	range_modifier;

/*---HSget_range_modifier------------------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	static void	HSget_range_modifier(void)
#else
	static void	HSget_range_modifier()
#endif

	{
	char	*expr, *getenv();
	
	range_modifier = -1;
	expr = getenv( "HS_RANGE_MODIFIER" );
	if( expr != NULL )
		sscanf( expr, "%d", &range_modifier );	
	}
	
/*---HSdebug_range_test_init---------------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	HSdebug_range_test_init(void)
#else
	HSdebug_range_test_init()
#endif

	{
	total_surfaces = 0;
	num_surf_with_range = 0;
	num_candidates = 0;
	tossed_surfaces =0;
	}

/*---HSdebug_range_test_info----------------------------------------------------*/
	
#if defined(__STDC__) || defined(__cplusplus)
	HSdebug_range_test_info(void)
#else
	HSdebug_range_test_info()
#endif

	{
	fprintf( stderr, "number of surfaces processed --- %d\n", total_surfaces );
	fprintf( stderr, "number of surfaces with range -- %d\n", num_surf_with_range );
	fprintf( stderr, "number of surface candidates --- %d\n", num_candidates );
	fprintf( stderr, "number of surfaces tossed ------ %d\n", tossed_surfaces );
	}
	
/*-- xxx_perspective_projection -------------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	static void	xxx_perspective_projection( double *point )
#else
	static void	xxx_perspective_projection( point )

	double	*point;
#endif

	{
	double	x_scale, y_scale, z_scale;
	int	i, j, k;

	x_scale = (active_window->dit_clip_range[3] - active_window->dit_clip_range[0]) * 0.5;
	y_scale = (active_window->dit_clip_range[4] - active_window->dit_clip_range[1]) * 0.5;
	z_scale = (active_window->z_max - active_window->z_min);
	
	j = 0;
	k = 24;
	for( i=0; i<8; i++ )
		{
		point[j]   = ((point[j]   / point[k]) + 1.0) * x_scale;
		point[j+1] = ((point[j+1] / point[k]) + 1.0) * y_scale;
		point[j+2] =  (point[j+2] / point[k])        * z_scale;
	
		j += 3;
		k++;
		}
	}

/*---HSget_screenspace_range-------------------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	static void	HSget_screenspace_range( double range[] )
#else
	static void	HSget_screenspace_range( range )

	double	range[];
#endif

	{
	double	cube[32];

	cube[0] = range[0];
	cube[1] = range[1];
	cube[2] = range[2];
	cube[3] = range[0];
	cube[4] = range[1];
	cube[5] = range[5];
	cube[6] = range[0];
	cube[7] = range[4];
	cube[8] = range[2];
	cube[9] = range[0];
	cube[10] = range[4];
	cube[11] = range[5];
	cube[12] = range[3];
	cube[13] = range[1];
	cube[14] = range[2];
	cube[15] = range[3];
	cube[16] = range[1];
	cube[17] = range[5];
	cube[18] = range[3];
	cube[19] = range[4];
	cube[20] = range[2];
	cube[21] = range[3];
	cube[22] = range[4];
	cube[23] = range[5];
	
	transform_points( active_window->perspective, 8, cube, 8 );
	if( active_window->perspective )
		xxx_perspective_projection( cube );
		
	range[0] = (double)(0x7fffffff);
	range[1] = range[0];
	range[2] = range[0];
	range[3] = -range[0];
	range[4] = range[3];
	range[5] = range[3];
	
	if( cube[0]  < range[0] ) range[0] = cube[0];
	if( cube[3]  < range[0] ) range[0] = cube[3];
	if( cube[6]  < range[0] ) range[0] = cube[6];
	if( cube[9]  < range[0] ) range[0] = cube[9];
	if( cube[12] < range[0] ) range[0] = cube[12];
	if( cube[15] < range[0] ) range[0] = cube[15];
	if( cube[18] < range[0] ) range[0] = cube[18];
	if( cube[21] < range[0] ) range[0] = cube[21];
	
	if( cube[1]  < range[1] ) range[1] = cube[1];
	if( cube[4]  < range[1] ) range[1] = cube[4];
	if( cube[7]  < range[1] ) range[1] = cube[7];
	if( cube[10] < range[1] ) range[1] = cube[10];
	if( cube[13] < range[1] ) range[1] = cube[13];
	if( cube[16] < range[1] ) range[1] = cube[16];
	if( cube[19] < range[1] ) range[1] = cube[19];
	if( cube[22] < range[1] ) range[1] = cube[22];
	
	if( cube[2]  < range[2] ) range[2] = cube[2];
	if( cube[5]  < range[2] ) range[2] = cube[5];
	if( cube[8]  < range[2] ) range[2] = cube[8];
	if( cube[11] < range[2] ) range[2] = cube[11];
	if( cube[14] < range[2] ) range[2] = cube[14];
	if( cube[17] < range[2] ) range[2] = cube[17];
	if( cube[20] < range[2] ) range[2] = cube[20];
	if( cube[23] < range[2] ) range[2] = cube[23];
	
	if( cube[0]  > range[3] ) range[3] = cube[0];
	if( cube[3]  > range[3] ) range[3] = cube[3];
	if( cube[6]  > range[3] ) range[3] = cube[6];
	if( cube[9]  > range[3] ) range[3] = cube[9];
	if( cube[12] > range[3] ) range[3] = cube[12];
	if( cube[15] > range[3] ) range[3] = cube[15];
	if( cube[18] > range[3] ) range[3] = cube[18];
	if( cube[21] > range[3] ) range[3] = cube[21];
	
	if( cube[1]  > range[4] ) range[4] = cube[1];
	if( cube[4]  > range[4] ) range[4] = cube[4];
	if( cube[7]  > range[4] ) range[4] = cube[7];
	if( cube[10] > range[4] ) range[4] = cube[10];
	if( cube[13] > range[4] ) range[4] = cube[13];
	if( cube[16] > range[4] ) range[4] = cube[16];
	if( cube[19] > range[4] ) range[4] = cube[19];
	if( cube[22] > range[4] ) range[4] = cube[22];
	}
	
/*---HStotally_hidden--------------------------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	static int	HStotally_hidden( double range[] )
#else
	static int	HStotally_hidden( range )

	double	range[];
#endif

	{
	int	xleft, xright;
	int	ystart, ystop;
	int	x, z;
	double	z_scale;
	HSzbuf	*zb;
	
	xleft  = (int)(range[1]) - 1;
	xright = (int)(range[4]) + 1;
	ystart = (int)(range[0]) - 1;
	ystop  = (int)(range[3]) + 1;
	
	if( xleft  < 0 ) xleft  = 0;
	if( ystart < 0 ) ystart = 0;
	if( xright > active_window->x_dits ) xright = active_window->x_dits;
	if( ystop  > active_window->y_dits ) ystop  = active_window->y_dits;
	
	z_scale = tiling_parms.maximum_z / (active_window->z_max - active_window->z_min);
	z = (int)(range[2] * z_scale);
	
	while( ystart <= ystop )
		{
		zb = active_window->zbuf + ystart * active_window->x_dits + (x = xleft);
		
		while( x <= xright )
			{
			if( *zb >= z )
				return( FALSE );
				
			x++;
			zb++;
			}
			
		ystart++;
		}
		
	return( TRUE );
	}


/*---HScheck_range_with_zbuffer----------------------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	int	HScheck_range_with_zbuffer( struct IGRbsp_surface *surface,
							IGRdouble *ele_range )
#else
	int	HScheck_range_with_zbuffer( surface, ele_range )

	struct IGRbsp_surface	*surface;
	IGRdouble		*ele_range;
#endif

	{
	int	num_poxels;
	int	bndx;
	double	dx, dy;
	int	num_pixels;

	total_surfaces++;

	if( first_time )
		{
		HSget_range_modifier();
		first_time = FALSE;
		}

	if( range_modifier >= 0 && ele_range != NULL && active_window->zbuf != NULL )	
		{
		num_surf_with_range++;

		HSget_screenspace_range( ele_range );
		
		/*
		 *  count the poles.  u_num_poles * v_num_poles + (for every boundary) num_points
		 */
 
		num_poxels = surface->u_num_poles * surface->v_num_poles;

		for( bndx=0; bndx<surface->num_boundaries; bndx++ )
			num_poxels += surface->bdrys[bndx].num_points;
	
		/*
		 *  the number of pixels in the range is dx * dy
		 *
		 *  where
		 *    dx = ele_range[3] - ele_range[0];
		 *    dy = ele_range[4] - ele_range[1];
		 *
		 */

		dx = ele_range[3] - ele_range[0];
		dy = ele_range[4] - ele_range[1];

		num_pixels = (int)((dx * dy) + 0.5);
		num_poxels <<= range_modifier;

		if( num_poxels >= num_pixels )
			{
			num_candidates++;
			if( HStotally_hidden( ele_range ) )
				{
				tossed_surfaces++;
				return( TRUE );
				}
			}
		}
		
	return( FALSE );
	}
