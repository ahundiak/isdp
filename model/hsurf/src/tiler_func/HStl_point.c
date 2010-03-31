
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:42 $
$Locker:  $
*/

#include <stdio.h>
#include <stdlib.h>

#if defined( ENV5 )
#include <EG.h>
#endif

#include "wl.h"

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
#include "hsdisplay.h"

#include "HStl_global.h"
#include "HStl_window.h"
#include "HStl_element.h"
#include "HSfem_spt.h"
#include "HSd_fixedpt.h"

#include "HSe2_mesher.h"
#include "HSpr_tiler_f.h"

/*------------------------------
 *  for function
 *     HSpaint
 */
 
#include "HSpr_display.h"

/*----------------------------
 *  for function
 *     HSsave_surface
 */
 
#include "HSpr_driver.h"

/*----------------------------*/



/*--- HSpoint_tiler ---------------------------------------------------------*/

/*
 * Tiles, clips, and sends out point data to the display module.
 *
 * HISTORY: 03/24/87 Created.				S. A. Rapa
 *	    04/06/87 Merged HSdisplay with IGE.		S. A. Rapa
 *	    06/25/92 changed MAXIMUM_Z to 
 *                   tiling_parms.maximum_z for correct
 *                   scaling.				Joel Underwood
 */

void HSpoint_tiler(
   IGRint pipe_no,
   IGRint num_points,
   IGRdouble *points,
   IGRint color,
   IGRint options,
   IGRdouble *range,
   IGRdouble *clip_range,
   int VDdisplay )

{
IGRdouble	*new_points,
   		*pts,
		*w_ptr,
   		x, y, z, w,
   		z_scale;
IGRint		p_num, status;
struct polyline_vertex	vertex;
IGRpoint	point;
#if defined( ENV5 )
float		*RGB;
EGRGBColor	EGcolor;
#endif

	HSactivate_window( pipe_no );
	if (tiling_parms.status != HSSTAT_OK) goto wrapup;

	HSset_ele_clip_range( clip_range );

	if (tiling_parms.processing_mode & HS_PMODE_FEEDBACK)
		{
		HSsave_surface( color, options, num_points, points );	
		}
	else
		{
		/*
		 * Set active tiling parameters.
		 */

		if (VDdisplay)
		{
#if defined( ENV5 )
			/* 'color' will contain an address in this case */
			RGB = (float *)color;
			EGcolor.red = RGB[0];
			EGcolor.green = RGB[1];
			EGcolor.blue = RGB[2];

			/* set the base color */
			status = EGSetBaseColor( active_window->EG_vc_no, &EGcolor );
#endif

		}
		else
			(*active_window->init_paint[active_window->active_zbuffer]) (&color, &options);

		/*
		 * Transform the points.
		 */

		new_points = (IGRdouble *) malloc((unsigned) (4 * num_points * sizeof (IGRdouble)));
		if (!new_points)
			{
			HSset_status( HSSTAT_ALLOC_ERROR );
			goto wrapup;
			}

		pts = new_points;

		for (p_num = 0; p_num < (3 * num_points); p_num++)
			new_points[p_num] = points[p_num];

		if ( active_window->making_triangles )
			{
			for (p_num = 0; p_num < num_points; p_num++)
				{
				point[0] = *new_points++;
				point[1] = *new_points++;
				point[2] = *new_points++;

				(*active_window->draw_point[active_window->active_zbuffer]) ( point );
				}
			}
		else
			{
			transform_points(	active_window->perspective,
						num_points,
						new_points,
						num_points );

			/*
			 * Clip and send out points.
			 */

			if (active_window->perspective)
				{
				w_ptr = new_points + (3 * num_points);
				for (p_num = 0; p_num < num_points; p_num++)
					{
					x = *new_points++;
					y = *new_points++;
					z = *new_points++;
					w = *w_ptr++;

					if ((x >= -w) && (y >= -w) && (z >= 0.0) &&
					    (x <= w) && (y <= w) && (z <= w))
						{
						vertex.x = (unsigned long)((((x / w) + 1.0) *
								    clip_range[3] * 0.5) +
								   0.5) << 16;
						vertex.y = (unsigned long)((((y / w) + 1.0) *
								    clip_range[4] * 0.5) +
								   0.5);
						vertex.z = (unsigned long)((z / w) * tiling_parms.maximum_z) + 0.5;
						
						(*active_window->draw_point[active_window->active_zbuffer]) (&vertex);
						HSpaint( 0 );
						}
					}
				}
			else
				{
				z_scale = tiling_parms.maximum_z / (clip_range[5] - clip_range[2]);
				for (p_num = 0; p_num < num_points; p_num++)
					{
					x = *new_points++;
					y = *new_points++;
					z = *new_points++;

					if ((x >= clip_range[0]) && (y >= clip_range[1]) &&
					    (z >= clip_range[2]) && (x <= clip_range[3]) &&
					    (y <= clip_range[4]) && (z <= clip_range[5]))
						{
						vertex.x = ((unsigned long) (x + 0.5)) << 16;
						vertex.y =  (unsigned long) (y + 0.5);
						vertex.z =  (unsigned long) ((z - clip_range[2]) * z_scale + 0.5);
						
						(*active_window->draw_point[active_window->active_zbuffer]) (&vertex);
						HSpaint( 0 );
						}
					}
				}
			}

		free (pts);
		}
wrapup:;
}
