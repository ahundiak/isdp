
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:42 $
$Locker:  $
*/

#include <stdio.h>
#include <stdlib.h>

#include "wl.h"

#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "gr.h"

#include "hsdef.h"
#include "hsurf.h"
#include "hstiler.h"
#include "hslight.h"
#include "hsdisplay.h"
#include "hrstruct.h"

#include "HStl_global.h"
#include "HStl_window.h"
#include "HStl_element.h"
#include "HSfem_spt.h"

#include "HSe2_mesher.h"
#include "HSpr_tiler_f.h"

/*------------------------------
 *  for function
 *     HRset_rendering_lights
 */
 
#include "HSpr_render.h"

/*------------------------------*/



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
/* HStl_light.c */
static void HSview_align_global_lights __((	struct HS_light_source lights[MAX_LIGHTS ], 
						struct HS_light_source aligned_lights[MAX_LIGHTS ]));
#if defined(__cplusplus)
}
#endif


#undef __



/*-----HSalign_view_lights_to_world----------------------------------------------------*/

/*
 *
 * HSalign_view_lights_to_world() takes an array of locally defined lights. If the light is
 * a parallel source in view-aligned coordinates, then its coordinates are converted to world
 * coordinates. If it's a point light source, it's already in world coordinates.
 *
 * HISTORY: 07/18/89	Created
 *								Trevor Mink
 *
 */

void HSalign_view_lights_to_world( struct HS_light_source lights[], 
				   struct HS_light_source aligned_lights[] )

	{
	int ii;
	struct HSvertex vertex;

	vertex.next = &vertex;  /* circular linked list with 1 entry */

	memcpy( aligned_lights, lights, sizeof( struct HS_light_source ) * MAX_LIGHTS );

	for ( ii = 0; ii < MAX_LIGHTS; ii++ ) {

		if ( (lights[ii].flags & HS_LIGHT_ENABLED) &&
	             !(lights[ii].flags & HS_LIGHT_DATABASE) )
			{

			memcpy( vertex.coord, aligned_lights[ii].direction, sizeof( IGRdouble ) * 3 );
			vertex.coord[3] = 1.0;  /* w for perspective */

			/* Rotate light vector from view-aligned coordinates to world coordinates */
			HSUnRotateVectors( 1, vertex.coord );

			memcpy( aligned_lights[ii].direction, vertex.coord, sizeof( IGRdouble ) * 3 );
			}

		}  /* end: for */

	}  /* HSalign_view_lights_to_world() */


/*--- HSview_align_global_lights -----------------------------------------------*/

static void HSview_align_global_lights(	struct HS_light_source lights[MAX_LIGHTS], 
					struct HS_light_source aligned_lights[MAX_LIGHTS] )

/*
DESCRIPTION
	This function takes an array of global (database aligned) lights and
	aligns them with the current view using the transformation and rotation
	matrices stored in the current active window structure.

HISTORY
	S.P. Rogers  07/13/89  Creation Date

	07/21/89	Removed scaling of point light radius and removed perspective
			scaling of point light sources.  Also, added squaring of radius.

								Trevor Mink
*/

	{
	IGRint          i;
	struct HSvertex vertex;
	double Radius;

	vertex.next = &vertex;  /* circular linked list with 1 entry */
	
	memcpy( aligned_lights, lights, sizeof( struct HS_light_source ) * MAX_LIGHTS );

	for ( i = 0; i < MAX_LIGHTS; i++ )
	   {
	   if ( (aligned_lights[i].flags & HS_LIGHT_ENABLED) &&
	        (aligned_lights[i].flags & HS_LIGHT_DATABASE) )
	      {
	      switch (aligned_lights[i].flags & HS_LIGHT_TYPE)
	         {
	         case HS_LIGHT_PARALLEL :

	            memcpy( vertex.coord, aligned_lights[i].direction, sizeof( IGRdouble ) * 3 );
	            vertex.coord[3] = 1.0;  /* w for perspective divide (not needed) */

	            /* rotate light vector to view-aligned coordinates */
	            rotate_normals( 1, vertex.coord );

	            memcpy( aligned_lights[i].direction, vertex.coord, sizeof( IGRdouble ) * 3 );
	            break;

	         case HS_LIGHT_POINT :

	            memcpy( vertex.coord, aligned_lights[i].location, sizeof( IGRdouble ) * 3 );
	            vertex.coord[3] = 1.0;  /* w for perspective divide (not needed) */

	            /* transform point light to normalized coordinates (no w needed for persp divide) */
	            transform_points( FALSE, 1, vertex.coord, 3 );
 	            if ( ! active_window->perspective )
	               vertex.coord[2] -= active_window->z_min;

	            memcpy( aligned_lights[i].location, vertex.coord, sizeof( IGRdouble ) * 3 );

	            /* We scale the radius to screen view volume (parallel window only)	*/
	            /* Perspective uses Radius in world coordinates 			*/
	            if ( ! active_window->perspective )
	               Radius = aligned_lights[i].radius * active_window->wv_scale;
	            else
	               Radius = aligned_lights[i].radius;

	            /* use Radius-squared to save from using 'sqrt' function */
	            aligned_lights[i].radius = Radius * Radius;
	            break;

	         case HS_LIGHT_SPOT :

	            memcpy( vertex.coord, aligned_lights[i].location, sizeof( IGRdouble ) * 3 );
	            vertex.coord[3] = 1.0;  /* w for perspective divide (not needed) */

	            /* transform point light to normalized coordinates (no w needed for persp divide) */
	            transform_points( FALSE, 1, vertex.coord, 3 );
 	            if ( ! active_window->perspective )
	               vertex.coord[2] -= active_window->z_min;

	            memcpy( aligned_lights[i].location, vertex.coord, sizeof( IGRdouble ) * 3 );

	            memcpy( vertex.coord, aligned_lights[i].direction, sizeof( IGRdouble ) * 3 );
	            vertex.coord[3] = 1.0;  /* w for perspective divide (not needed) */

	            /* rotate light vector to view-aligned coordinates */
	            rotate_normals( 1, vertex.coord );

	            memcpy( aligned_lights[i].direction, vertex.coord, sizeof( IGRdouble ) * 3 );

	            /* We scale the radius to screen view volume (parallel window only)	*/
	            /* Perspective uses Radius in world coordinates 			*/
	            if ( ! active_window->perspective )
	               Radius = aligned_lights[i].radius * active_window->wv_scale;
	            else
	               Radius = aligned_lights[i].radius;

	            /* use Radius-squared to save from using 'sqrt' function */
	            aligned_lights[i].radius = Radius * Radius;
	            break;

	         case HS_LIGHT_PENCIL :

	            memcpy( vertex.coord, aligned_lights[i].location, sizeof( IGRdouble ) * 3 );
	            vertex.coord[3] = 1.0;  /* w for perspective divide (not needed) */

	            /* transform point light to normalized coordinates (no w needed for persp divide) */
	            transform_points( FALSE, 1, vertex.coord, 3 );
 	            if ( ! active_window->perspective )
	               vertex.coord[2] -= active_window->z_min;

	            memcpy( aligned_lights[i].location, vertex.coord, sizeof( IGRdouble ) * 3 );

	            memcpy( vertex.coord, aligned_lights[i].direction, sizeof( IGRdouble ) * 3 );
	            vertex.coord[3] = 1.0;  /* w for perspective divide (not needed) */

	            /* rotate light vector to view-aligned coordinates */
	            rotate_normals( 1, vertex.coord );

	            memcpy( aligned_lights[i].direction, vertex.coord, sizeof( IGRdouble ) * 3 );

	            /* We scale the radius to screen view volume (parallel window only)	*/
	            /* Perspective uses Radius in world coordinates 			*/
	            if ( ! active_window->perspective )
	               aligned_lights[i].radius *= active_window->wv_scale;
	            break;

	         }  /* end: switch */

	      }  /* end: if (light is enabled and is database aligned) */

	   }  /* end: for */

	}  /* HSview_align_global_lights */


/*--- HSsetup_window_lights --------------------------------------------------*/

void HSsetup_window_lights( struct HS_light_source global_lights[MAX_LIGHTS],
	                    struct HS_light_source *ambient_light )


/*
DESCRIPTION
	This function sets up the lights for a window.  It assumes that
	'active_window' is set to the window for which the lights are to be
	set.
	
HISTORY
	S.P. Rogers  07/12/89  Creation Date
	Trevor Mink  11/15/89  Removed inappropriate offset of eyepoint to move behind proj. plane.
	S.P. Rogers  10/13/91  Removed eyepoint parameter
*/

	{
	IGRint                  ii;
	IGRboolean              found_one;
	struct HS_light_source	aligned_lights[MAX_LIGHTS];


	if ( !(global_lights && ambient_light) )
	   return;

	/* if no lights are defined, define a default view-aligned */
	/* directional light with a vector of (-1,-2,-16)          */
	for ( found_one = FALSE, ii = 0; ii < MAX_LIGHTS; ii++ )
	   {
	   if ( global_lights[ii].flags & HS_LIGHT_ENABLED )
	      {
	      found_one = TRUE;
	      break;
	      }
	   }

	if ( ! found_one )
	   {
	   global_lights[0].direction[0] = -1.0 / 16.155494;
	   global_lights[0].direction[1] =  2.0 / 16.155494;
	   global_lights[0].direction[2] = 16.0 / 16.155494;
	   global_lights[0].red = global_lights[0].green = global_lights[0].blue = 255;
	   global_lights[0].flags = HS_LIGHT_ENABLED | HS_LIGHT_PARALLEL;
	   }

#if defined( ENV5 )
	/* set the GPIPE lights */
	if (active_window->type & HShardware_LB_GPIPE)
		HSsetup_GPIPE_lights( global_lights );

	/* set the EG lights */
	if (active_window->type & HShardware_LB_EG)
		HSsetup_EG_lights( global_lights, ambient_light );
#endif

#if defined( OPENGL )
	/* set the OpenGL lights */
	if (active_window->type & HShardware_LB_OPENGL)
		HSsetup_OPENGL_lights( global_lights, ambient_light );
#endif
#if defined( XGL )
	/* set the XGL lights */
	if (active_window->type & HShardware_LB_XGL)
		HSsetup_XGL_lights( global_lights, ambient_light );
#endif

	/* Get the global parallel light sources in view-aligned coordinates */
	/* and the global point light sources in normalized coordinates.     */
	
	HSview_align_global_lights( global_lights, aligned_lights );

	/* Place list of lights in active window structure */
	HSset_active_lights( aligned_lights );

	/*
	 * Set up the light sources for rendering mode.
	 * NOTE: if perspective, the active xyz scales must
	 * be defined!  CMJ 12/05/89
	 */

	if (tiling_parms.processing_mode & HS_PMODE_RENDER_IMAGE) 
		HRset_rendering_lights( ambient_light );

	HSset_ambient_light_intensities( ambient_light );
	
	}  /* HSsetup_window_lights */
