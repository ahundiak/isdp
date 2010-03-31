#include <stdio.h>
#include <string.h>
#if defined (CLIX)
#include <EG.h>
#endif
#include "wl.h"

#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "gr.h"
#include "hplot.h"
#include "hsmath.h"
#include "hstiler.h"
#include "hslight.h"
#include "HStl_global.h"
#include "HStl_window.h"
#include "HStl_element.h"
#include "HSfem_spt.h"
#include "hsdef.h"
#include "hsmacdef.h"
#include "HPglobal.h"
#include "HPtiming.h"
#include "HPdef.h"
#include "hsdisplay.h"
#include "HSd_fixedpt.h"

#include "HPpr_hplot_f.h"

/*---------------------------
 *   for
 *      HSset_clip_mode
 *      HSset_default_active_window_functions
 *      HSset_ele_clip_range
 *      HSset_maximum_z
 *      HSset_rendering_mode
 *      HSset_transparency
 *      HSsetup_shading_window
 */
  
#include "HSe2_mesher.h"
#include "HSpr_tiler_f.h"

/*------------------------------------*/


void	HPinit_paint();
void	HPdraw_point();

/*---HPdummy_stub-----------------------------------------------------------*/

/*
NAME
	HPdummy_stub
	
KEYWORD
	HSplot
	stub
	
DESCRIPTION
	Used to satisfy a request for a function name when one
	is not really needed
	
HISTORY
	??/??/??	M. Lanier
		Created
*/
	
void	HPdummy_stub()

	{
	}

/*---HPinit_band-----------------------------------------------------*/

/*
NAME
	HPinit_band
	
KEYWORD
	HSplot
	banding
	
DESCRIPTION
	Sets up the viewport for the current band and initializes
	the tiler.
	
GLOBALS USED
	HPglobal
	HPband_info
	active_window
	tiling_parms

FUNCTIONS CALLED
	HPtiming_start
	fprintf
	ROUND
	HSset_default_active_window_functions
	HSset_rendering_mode
	HSset_clip_range
	HSset_maximum_z
	HPinit_paint
	HPdraw_point
	HPget_scale
	HSsetup_shading_window
	HSset__ele_clip_range
	HSset_transparency
	memcpy
	memset

HISTORY
	??/??/??	M. Lanier
		Created
		
*/

#if defined(__STDC__) || defined(__cplusplus)
	int	HPinit_band( void )
#else
	int	HPinit_band()
#endif

	{
	IGRint			x, y;
	IGRdouble		xlo, ylo, zlo, xhi, yhi, zhi;
	HSzbuf			*zb;
	HScbuf			*cb;
	IGRdouble		HPget_scale();
	static IGRdouble	unmolested_viewport[6];

	HPtiming_start(2);
	
	/*
	 *  Get the viewport coordinates.  Swap the x and y coordinate because 
	 *  of a 90 degree rotation for plotting.
	 */
		
	if( HPglobal.band_count == 1 )
		{
		unmolested_viewport[0] = HPglobal.viewport[0];
		unmolested_viewport[1] = HPglobal.viewport[1];
		unmolested_viewport[2] = HPglobal.viewport[2];
		unmolested_viewport[3] = HPglobal.viewport[3];
		unmolested_viewport[4] = HPglobal.viewport[4];
		unmolested_viewport[5] = HPglobal.viewport[5];
		}

	/*
	 *  Compute the viewport range.  The xhi will either be
	 *  x max of the total viewport, or x min plus the height
	 *  of the band.
	 */
	 	 
	xlo = HPglobal.viewport[0];
	ylo = HPglobal.viewport[1];
	zlo = HPglobal.viewport[2];
	yhi = HPglobal.viewport[4];
	zhi = HPglobal.viewport[5];

	if( HPglobal.band_count < HPglobal.total_bands )
		{
		xhi = xlo + HPglobal.band_height - 1;
			
		HPglobal.viewport[0] = xhi + 1;
		}
	else
		{
		xhi = HPglobal.viewport[3];
		}

	if( HPglobal.debug )
		{
		fprintf( stderr, "\nHPinit_band(%1d:%1d)\n", 
			HPglobal.band_count, HPglobal.total_bands );
		fprintf( stderr, "   view %17.8f %17.8f %17.8f\n", xlo, ylo, zlo );
		fprintf( stderr, "        %17.8f %17.8f %17.8f\n", xhi, yhi, zhi );
		}

	/*
	 *  for the first band, extent the clip region overlap scanlines north
	 *  and south.  After that extent the clip region 2*overlap scanlines
	 *  south
	 */

	ylo -= HPglobal.overlap;
	yhi += HPglobal.overlap;
	xlo -= HPglobal.overlap;	
	xhi += HPglobal.overlap;


	/*
	 *  Load the clip range
	 */

	HPband_info.org_y  = ROUND( xlo );
	HPband_info.org_x  = ROUND( ylo );
	HPband_info.y_dits = ROUND( (xhi - xlo) );
	HPband_info.x_dits = ROUND( (yhi - ylo) );
	
	HPband_info.clip_range[0] = xlo;
	HPband_info.clip_range[1] = ylo;
	HPband_info.clip_range[2] = zlo;
	HPband_info.clip_range[3] = xhi;
	HPband_info.clip_range[4] = yhi;
	HPband_info.clip_range[5] = zhi;

	if( HPglobal.debug )
		{
		fprintf( stderr, "\n   band %17.8f %17.8f %17.8f\n", 
			HPband_info.clip_range[0], HPband_info.clip_range[1], HPband_info.clip_range[2] );
		fprintf( stderr, "        %17.8f %17.8f %17.8f\n\n", 
			HPband_info.clip_range[3], HPband_info.clip_range[4], HPband_info.clip_range[5] );
		}
    
	HPband_info.screen_door = 4;
	
	if( HPglobal.perspective )
		{
		HPband_info.x_scale = HPglobal.post_rotation[0];
		HPband_info.y_scale = HPglobal.post_rotation[5];
		HPband_info.z_scale = HPglobal.post_rotation[14];
		}
	else
		{
		HPband_info.x_scale = 0.0;
		HPband_info.y_scale = 0.0;
		HPband_info.z_scale = 0.0;
		}
	
	HPband_info.grid_on = 64;
	HPband_info.acc_mode = FALSE;
	HPband_info.keyed_in_tol = 0.5;
	HPband_info.trans_pat = 1;
	HPband_info.accuracy = 3;
		
	HPband_info.pipe_no = HPband_info.w_no = HPglobal.id;

	/*
	 *  Call HSset_shade_table, this will load the color shade configuation
	 *  into HSURF.  HSset_default_functionality() will set function
	 *  pointers within HSURF to a default (IP32) state.  Normally within
	 *  HSURF, we would have called HScheck_configuration(), but this allocates
	 *  memory for an image and z buffer.  Since the data structure of these
	 *  buffers may change for this application, we want to allocate later.
	 */
	 

	HSset_default_active_window_functions( 0 );
	
	active_window->type = 
		HShardware_1MPX | HShardware_LB_HSURF_ROP | HShardware_ZB_NONE | HShardware_CP_NONE;
		
	HSset_rendering_mode( 0 );
	HSset_clip_mode( TRUE );

	if( HPglobal.bytes_per_pixel == 5 )
		{
		HSset_maximum_z( (double)(0x1fffffff) );
		}
	else
		{
		HSset_maximum_z( (double)(0x7fffffff) );
		}
	
	/*
	 *  Set the function pointers for HP support
	 */

	tiling_parms.processing_mode &= ~HS_PMODE_RHL_SHOW_HIDDEN;
	active_window->init_window[0] = HPdummy_stub;
	active_window->init_paint[0] = HPinit_paint;
	active_window->painter[0] = HPdummy_stub;
	active_window->draw_point[0] = HPdraw_point;
	
	HPband_info.world_to_view_scale = HPget_scale();
	
	/*
	 *  This will initialize HSURF for shading this scene.  Because we are overriding
	 *  the init_window function pointer, HSURF will not talk to a window.
	 */

	/*dump_window_info();*/

	HSsetup_shading_window(
			NULL, NULL, NULL, NULL, NULL, NULL,
			HPband_info.pipe_no, HPband_info.w_no,
			HPband_info.org_x, HPband_info.org_y, 
			HPband_info.x_dits, HPband_info.y_dits,
			NULL,
			unmolested_viewport,
			HPglobal.xform.m4x4,
			HPglobal.rotation.m4x4,
			HPglobal.global_lights,
			&HPglobal.ambient_light,
			(double)((unsigned char)HPglobal.depth_cue_near),
			(double)HPglobal.depth_cue_far,
			HPband_info.world_to_view_scale,
			HPband_info.x_scale, HPband_info.y_scale, HPband_info.z_scale,
			HPglobal.perspective, 
			HPband_info.grid_on,
			HPglobal.depth_cue_near != HPglobal.depth_cue_far,
			FALSE );


	if( HPglobal.perspective )
		HSset_ele_clip_range( unmolested_viewport );
	else
		HSset_ele_clip_range( HPband_info.clip_range );

	/*
	HPglobal.color_table[0][0] = 0;
	HPglobal.color_table[0][1] = 0;
	HPglobal.color_table[0][2] = 0;
	*/
	/*		
	if( (HPglobal.band_count & 1) == 0 )
		{
		HPglobal.color_table[0][0] = 0xffff;
		HPglobal.color_table[0][1] = 0xffff;
		HPglobal.color_table[0][2] = 0xffff;
		}
	else
		{
		HPglobal.color_table[0][0] = 0xeeee;
		HPglobal.color_table[0][1] = 0xeeee;
		HPglobal.color_table[0][2] = 0xeeee;
		}
	*/
	
	active_window->zbuf = HPglobal.band_buffer;
	active_window->cbuf = (unsigned char *)HPglobal.band_buffer + 
							(HPglobal.total_pixels * 4);
							
	active_window->x_dits = HPband_info.x_dits;
	active_window->y_dits = HPband_info.y_dits;
	
	HSset_transparency( HPband_info.trans_pat );

	/*
	 *  Initialize the zbuffer and image buffer
	 */
	 
	zb = active_window->zbuf;
	cb = active_window->cbuf;
	
	for( x=0; x<HPband_info.x_dits; x++ )
		*(zb++) = (int)tiling_parms.maximum_z;
	
	for( y=1; y<=HPband_info.y_dits; y++ )
		{
		memcpy( zb, active_window->zbuf, sizeof( HSzbuf ) * HPband_info.x_dits );
		zb += HPband_info.x_dits;
		}

   if( HPglobal.bytes_per_pixel == 7 )
      {
      unsigned short	*bk;
      unsigned char	r, g, b;
      int		i;

      active_window->cbuf_size = HPglobal.total_pixels * 3;

      bk = (unsigned short *)HPglobal.color_table;

      r = (unsigned char)(*bk++ >> 4);
      g = (unsigned char)(*bk++ >> 4);
      b = (unsigned char)(*bk >> 4);

      for( i=0; i<HPglobal.total_pixels; i++ )
         {
         *cb++ = r;
         *cb++ = g;
         *cb++ = b;
         }
      }

   else
      {
      if( HPglobal.bytes_per_pixel == 5 )
         active_window->cbuf_size = HPglobal.total_pixels;
      else
         active_window->cbuf_size = HPglobal.total_pixels * 2;
		
      memset( cb, 0, active_window->cbuf_size );
      }
		
	active_window->x_min_rl = (active_window->x_dits-2) << 16;
	active_window->y_min_rl = (active_window->y_dits-2);
	active_window->x_max_rl = 2;
	active_window->y_max_rl = 2;

	return( HP_I_Success );
	}

