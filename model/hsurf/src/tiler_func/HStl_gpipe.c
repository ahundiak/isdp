
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:42 $
$Locker:  $
*/

#if defined( ENV5 )

#include <stdio.h>

#include <stdlib.h>

#include <gpipe.h>

#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "gr.h"
#include "igrdp.h"
#include "dp.h"
#include "dpstruct.h"

#include "hstiler.h"
#include "hslight.h"
#include "hsdef.h"
#include "hsurf.h"
#include "hsmath.h"

#include "hsdisplay.h"
#include "HStl_window.h"
#include "HStl_element.h"
#include "HStl_global.h"
#include "HSfem_spt.h"

#include "HSe2_mesher.h"
#include "HSpr_tiler_f.h"

/*---------------------------
 *  for function
 *     HSdelete
 */
 
#include "HSpr_driver.h"

/*------------------------------*/


/*-----HSdelete_GPIPE_shading_window------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	void HSdelete_GPIPE_shading_window(void)
#else
	void HSdelete_GPIPE_shading_window()
#endif

/*
 * DESCRIPTION:
 *	HSdelete_GPIPE_shading_window disables the active pipe's Z buffer.
 *
 * HISTORY:
 * 	04/06/90 Taken from HSdelete_shading_window.		C. M. Jablonski
 */

	{
	GPEnableZbuffer( active_window->gpipe_id, 0 );
	}


/*-----HSsetup_GPIPE_lights----------------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	void HSsetup_GPIPE_lights( struct HS_light_source global_lights[MAX_LIGHTS] )
#else
	void HSsetup_GPIPE_lights( global_lights  )

	struct HS_light_source global_lights[MAX_LIGHTS];
#endif

/*
 * DESCRIPTION:
 *	HSsetup_GPIPE_lights sets the necessary GPIPE light structures.
 *
 * HISTORY:
 * 	04/06/90 Taken from HSsetup_window_lights.		C. M. Jablonski
 */

{
IGRint               	ii, status, num_lights;
struct HS_light_source	aligned_lights[MAX_LIGHTS];
GPlight			gp_light[MAX_LIGHTS];


	/* Get the window lights into world coordinates */
	HSalign_view_lights_to_world( global_lights, aligned_lights );

	/* Define the GPlight structures */
	num_lights = 0;
	for( ii=0; ii < MAX_LIGHTS; ii++ )
		{
		if ( aligned_lights[ii].flags & HS_LIGHT_ENABLED )
			{
			switch (aligned_lights[ii].flags & HS_LIGHT_TYPE) {

				case HS_LIGHT_POINT :
				case HS_LIGHT_SPOT :

					gp_light[num_lights].source = 1.0;
					gp_light[num_lights].lx = aligned_lights[ii].location[0];
					gp_light[num_lights].ly = aligned_lights[ii].location[1];
					gp_light[num_lights].lz = aligned_lights[ii].location[2];
	
					break;

				case HS_LIGHT_PARALLEL :
				case HS_LIGHT_PENCIL :

					gp_light[num_lights].source = 0.0;
		        		gp_light[num_lights].lx = -aligned_lights[ii].direction[0];
		        		gp_light[num_lights].ly = -aligned_lights[ii].direction[1];
	        			gp_light[num_lights].lz = -aligned_lights[ii].direction[2];

					break;

				}

			gp_light[num_lights].pntrad = aligned_lights[ii].radius;

			/* Take the average of the RGB intensities and get between 0 and 1 */
			gp_light[num_lights].intensity = (aligned_lights[ii].red +
	                                                  aligned_lights[ii].green +
						          aligned_lights[ii].blue) / (3.0 * 255.0);
			num_lights++;
			}  /* light is enabled */
		}

	/* The 0 in the following call indicates that the lights are in world   */
	/* coordinates and the 0.0 is the ambient light intensity from 0.0-1.0  */
	status = GPSetLightSource(	active_window->gpipe_id,
					gp_light,
					num_lights,
					0,
					0.0 );
	}


/*---HSsetGPmatrix-------------------------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	void HSsetGPmatrix( IGRdouble transformation_matrix[4][4] )
#else
	void HSsetGPmatrix( transformation_matrix )

	IGRdouble	transformation_matrix[4][4];
#endif

	{
	IGRint		row, col;
	IGRdouble	transpose[4][4];
	IGRdouble	trans_matrix[4][4];
	IGRdouble	scale_matrix[4][4];
	IGRdouble	temp_matrix[4][4];
	IGRdouble	gwindow_matrix[4][4];

	for( row=0; row<4; row++)
	for( col=0; col<4; col++)
		transpose[row][col] = transformation_matrix[col][row];
		
	trans_matrix[0][0] = 1.0;
	trans_matrix[0][1] = 0.0;
	trans_matrix[0][2] = 0.0;
	trans_matrix[0][3] = 0.0;
		
	trans_matrix[1][0] = 0.0;
	trans_matrix[1][1] = 1.0;
	trans_matrix[1][2] = 0.0;
	trans_matrix[1][3] = 0.0;
		
	trans_matrix[2][0] = 0.0;
	trans_matrix[2][1] = 0.0;
	trans_matrix[2][2] = 1.0;
	trans_matrix[2][3] = 0.0;
		
	trans_matrix[3][0] = 0.0;
	trans_matrix[3][1] = 0.0;
	trans_matrix[3][2] = active_window->dit_clip_range[5] - active_window->dit_clip_range[2];
	trans_matrix[3][3] = 1.0;

		
	scale_matrix[0][0] = 1.0;
	scale_matrix[0][1] = 0.0;
	scale_matrix[0][2] = 0.0;
	scale_matrix[0][3] = 0.0;
		
	scale_matrix[1][0] = 0.0;
	scale_matrix[1][1] = 1.0;
	scale_matrix[1][2] = 0.0;
	scale_matrix[1][3] = 0.0;
		
	scale_matrix[2][0] = 0.0;
	scale_matrix[2][1] = 0.0;

	scale_matrix[2][2] = tiling_parms.maximum_z /
			     (active_window->dit_clip_range[5] -
			      active_window->dit_clip_range[2]);
	scale_matrix[2][3] = 0.0;
		
	scale_matrix[3][0] = 0.0;
	scale_matrix[3][1] = 0.0;
	scale_matrix[3][2] = 0.0;
	scale_matrix[3][3] = 1.0;
		
	MATRIX_MULT( transpose, trans_matrix, temp_matrix );
	MATRIX_MULT( transpose, scale_matrix, gwindow_matrix );
		
	if( active_window->perspective )
		{
		GPPutMatrix( active_window->gpipe_id, transpose );
		}
	else
		{
		GPPutMatrix( active_window->gpipe_id, gwindow_matrix );
		GPSetScaleRatios(	active_window->gpipe_id,
					1.0,
					(active_window->dit_clip_range[5] -
					 active_window->dit_clip_range[2]) /
					tiling_parms.maximum_z );
		}
	}


/*---HSsetup_GPIPE_window-----------------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	void HSsetup_GPIPE_window( IGRdouble *clip_range, 
				   IGRdouble transformation_matrix[4][4], 
				   IGRdouble eye_pt[3] )
#else
	void HSsetup_GPIPE_window( clip_range, transformation_matrix, eye_pt )

	IGRdouble		*clip_range;
	IGRdouble		transformation_matrix[4][4];
	IGRdouble		eye_pt[3];
#endif

/*
 * ABSTRACT:	HSsetup_GPIPE_window sets those GPIPE window parameters that
 *		may change on a per-update basis.
 *
 * HISTORY:	04/05/90 Taken from HSsetup_shading_window.	C. M. Jablonski
 */

{
IGRdouble v[3];

	GPSetShadeTable(	active_window->gpipe_id, 
				tiling_parms.number_shades, 
				(tiling_parms.processing_mode & HS_PMODE_DIRECT) ? 0 : 1  );

	GPPutViewport(	active_window->gpipe_id,
			clip_range[0], clip_range[1], 0.0,
			clip_range[3], clip_range[4], tiling_parms.maximum_z );

	HSsetGPmatrix( transformation_matrix );	

	if (active_window->perspective)
		{
		/* For perspective, set the eye point in world coordinates. */
		GPSetPerspEyepoint(	active_window->gpipe_id,
					eye_pt[0], eye_pt[1], eye_pt[2]);
		}
	else
		{
		/* Set the view vector in world coordinates. */
		v[0] = 0.0;	v[1] = 0.0;	v[2] = -1.0;
		HSUnRotateVectors( 1, v );
		GPSetOrthoViewVector( active_window->gpipe_id, v[0], v[1], v[2]);
		}

}

/*---HSdraw_point_FPE--------------------------------------------------------------*/

void HSdraw_point_FPE( point )

struct polyline_vertex    *point;

{
    GPxyz         polys[4];
    IGRint        num_verts[1], num_polys=1, options=0, tempx;
    IGRdouble    save_mtx[4][4];

        int        point_size;

    tempx = (point->x >> 16);

    GPGetMatrix( active_window->gpipe_id, save_mtx);    
    GPResetMatrix(active_window->gpipe_id);    

    point_size = element_parms.visible_weight;

    polys[0].x = ( tempx - point_size );
    polys[0].y = ( point->y - point_size );
    polys[0].z = ( point->z );

    polys[1].x = ( tempx - point_size );
    polys[1].y = ( point->y + point_size );
    polys[1].z = ( point->z );

    polys[2].x = ( tempx + point_size );
    polys[2].y = ( point->y + point_size );
    polys[2].z = ( point->z );

    polys[3].x = ( tempx + point_size );
    polys[3].y = ( point->y - point_size );
    polys[3].z = ( point->z );

    num_verts[0] = 4;

    GPPolyFill3D( active_window->gpipe_id, polys, num_verts, num_polys, options );

    GPPutMatrix( active_window->gpipe_id, save_mtx );
    
}    

/*---HSpaint_screen_FPE-----------------------------------------------------*/

void HSpaint_screen_FPE( void )

{

   GPFlushImageBuffer( active_window->gpipe_id );
}

#endif

