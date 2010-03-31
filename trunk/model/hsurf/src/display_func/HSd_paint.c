
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:36 $
$Locker:  $
*/

/*		Apogee compliant		*/

#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/times.h>

#include "wl.h"

#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "gr.h"

#include "hstiler.h"
#include "hslight.h"
#include "hsdisplay.h"
#include "hsmacdef.h"

#include "HStl_window.h"
#include "HStl_element.h"
#include "HStl_global.h"
#include "HSfem_spt.h"
#include "HSd_fixedpt.h"

#include "HSpr_display.h"


/*------------------------------
 *  for functions
 *     HSget_region_hardware_type
 *     HSget_region_original_style
 *     HSget_region_style
 *     HSget_region_update
 */

#include "HSe2_mesher.h"
#include "HSpr_tiler_f.h"

/*----------------------------------
 *  for function
 *     HSassign_edgeII_vlt_to_window
 */

#include "hsurf.h"
#include "HSpr_dpb_imp.h"

/*----------------------------------*/

#define DEBUG	0

static long last_time = 0;
static struct tms tbuffer;

#define MIN_SIZE	16      /* Minimum size of refresh area 	 */

#define		ICSTOP	10

/*---HSpaint-------------------------------------------------------------------------*/

void HSpaint(
   IGRint flush )

/*
NAME
    HSpaint

DESCRIPTION
    Display at regular intervals, or on demand, the hsurf image buffer.

PARAMETERS
    flush: (IN):  Instructs the function to display the image buffer,
                  regardless of the paint_delay status

GLOBALS USED
    active_window
    last_fime

FUNCTIONS CALLED
    painter: function pointer defined elsewhere
    times

NOTES
    Paint Delay:  Each time the image buffer is updated, the variable
                  last time is set to the current time.  After, when
                  this function is called, the delta from that call to
                  now is computed and, if it exceeded the paint_delay
                  value, then the image buffer is updated again.


HISTORY
    ??/??/??    M. Lanier
       Created

    2/2/93      T. Mink, M. Lanier
       WL converted
*/

{
#   if DEBUG
   if ( icount < ICSTOP )
   {
      fprintf( stderr, "HSpaint\n" );
      fprintf( stderr, "  active_zbuffer   %d\n", active_window->active_zbuffer );
      fprintf( stderr, "  xmin, ymin -- %d %d\n", active_window->x_min, active_window->y_min );
      fprintf( stderr, "  xmax, ymax -- %d %d\n", active_window->x_max, active_window->y_max );
      fprintf( stderr, "  zbuf, cbuf -- %x %x\n", active_window->zbuf, active_window->cbuf );
   }
#   endif

   if ( flush )
   {
      ( *active_window->painter[active_window->active_zbuffer] ) (  );

      if ( active_window->unsupported_zbuffer_allocated &&
           active_window->type & HShardware_ZB_MASK )
      {
         active_window->active_zbuffer = 1;
         ( *active_window->painter[active_window->active_zbuffer] ) (  );
         active_window->active_zbuffer = 0;
      }

      last_time = times( &tbuffer );
   }
   else
   {
      if ( ( ( times( &tbuffer ) ) - last_time ) >= active_window->paint_delay[active_window->active_zbuffer] )
      {
         ( *active_window->painter[active_window->active_zbuffer] ) (  );

         last_time = times( &tbuffer );
      }
   }
}

/*---HSpaint_screen_ROP-----------------------------------------------------*/

void HSpaint_screen_ROP(
   void )

/*
NAME
    HSpaint_screen_ROP

DESCRIPTION
    Display the image buffer to a ROP device

GLOBALS USED
    active_window

FUNCTIONS CALLED
    HSget_region_update

HISTORY:
    3/31/89    T. Mink
        Performance improvement... Forced the minimum area to be refreshed
        to be of width MIN_SIZE (or the window width whichever is lesser).

*/


{
   register int y;
   register HScbuf *cb;

   int x_delta;

   int MinWidth = MIN_SIZE;     /* Minimum refresh area width */
   IGRboolean region_update;
   IGRint orig_style, style;
   IGRboolean wire_window, shd_window;
   IGRboolean rhl_display, shd_display, hwzbuf;
   IGRint type;

   HSget_region_update( &region_update );

   /* Start at the bottom of the sub-region and move up */

   active_window->x_min >>= 16;
   active_window->x_max >>= 16;

   active_window->x_min &= 0xfffffffe;

   /* Get address of pixel in color-buffer at left side of of region, for the
    * given y */

   cb = ( HScbuf * ) active_window->cbuf + active_window->y_min *
      active_window->x_dits + active_window->x_min;

   if ( region_update )
   {
      HSget_region_style( &style );
      HSget_region_original_style( &orig_style );

      rhl_display = ( style == HS_STYLE_RASTER ) || ( style == HS_STYLE_FILLED_RASTER );
      shd_display = ( style == HS_STYLE_SMOOTH ) || ( style == HS_STYLE_CONSTANT );
      shd_window = ( orig_style == HS_STYLE_SMOOTH ) || ( orig_style == HS_STYLE_CONSTANT );
      wire_window = ( orig_style == HS_STYLE_WIREFRAME );

      HSget_region_hardware_type( &type );

      hwzbuf = ( type & HShardware_ZB_MASK ) ? 1 : 0;

      if ( !hwzbuf && shd_display && wire_window )
         active_window->x_max -= 1;

      if ( ( hwzbuf && rhl_display && shd_window ) || ( rhl_display && wire_window ) )
      {
         if ( active_window->x_min == 0 )
         {
            cb += 4;
            active_window->x_max -= 4;
         }
         else
         {
            active_window->x_min -= 4;
            active_window->x_max -= 4;
         }
      }
   }

   active_window->x_max++;

   if ( !region_update )
   {
      /* don't have a minwidth for a region */

      x_delta = ( active_window->x_max - active_window->x_min ) + 1;


      /* Adjust MinWidth for smaller windows */

      if ( active_window->x_dits < ( MinWidth - 1 ) )
         MinWidth = active_window->x_dits + 1;


      /* Make sure width is at least the minimum */

      if ( x_delta < MinWidth )
         active_window->x_max = active_window->x_min + MinWidth - 1;
   }

   /* Add in offset, incase clip range origin and window origin are  */
   /* not the same                                                   */

   active_window->x_min += tiling_parms.x_offset;
   active_window->x_max += tiling_parms.x_offset;
   active_window->y_min += tiling_parms.y_offset;
   active_window->y_max += tiling_parms.y_offset;

#   if DEBUG
   if ( icount++ < ICSTOP )
   {
      fprintf( stderr, "HSpaint_screen_ROP\n" );
      fprintf( stderr, "  w_no ---- %d\n", active_window->win_no );
      fprintf( stderr, "  x_min --- %d\n", active_window->x_min );
      fprintf( stderr, "  x_max --- %d\n", active_window->x_max );
      fprintf( stderr, "  y_min --- %d\n", active_window->y_min );
      fprintf( stderr, "  y_max --- %d\n", active_window->y_max );
      fprintf( stderr, "  cb ------ %x\n", cb );
   }
#   endif
   
   active_window->image.width = active_window->x_max - active_window->x_min + 1;
   active_window->image.height = 1;

#  if defined (XGL)
      {
      /*
       *  In XGL, I'm drawing 8bit data in a 24 bit window.  To do this
       *  I use the WL local colormap in mapping the 8 bit index
       *  to 24 bit RGB.  In the RHL case, the colormap that I want is
       *  attached to the forms context.  But I cannot use the forms
       *  context in the call WLput_raster_data because that function
       *  validates and won't display anything.  So, I'm sneeky and am
       *  coping the colormap from the forms context to the active window
       *  context.  Because XGL ignores the active window index, doing this
       *  will have no ill effects on shading (Mike 01/10/96)
       */

      WLuint32	context_no8;
      CMget_exnuc_forms_context( active_window->vs_no, &context_no8 );
      WLIcontext_copy_cmap( context_no8, active_window->context_no );
      }
#  endif
 
   for ( y = active_window->y_min; y <= active_window->y_max; y++ )
   {
      active_window->image.buffer = ( char * ) cb;
      active_window->image.x = active_window->x_min;
      active_window->image.y = y;

      WLput_raster_data( active_window->win_no,
                         active_window->context_no,
                         &active_window->image );

      cb += active_window->x_dits;
   }

   /* Reset min/max and trapezoid count */

   active_window->x_min = active_window->x_dits << 16;
   active_window->y_min = active_window->y_dits;
   active_window->x_max = 0;
   active_window->y_max = 0;

} /* HSpaint_screen_top */

/*---HSpaint_screen_putpixel-----------------------------------------------------*/

void HSpaint_screen_putpixel(
   void )

/*
NAME
    HSpaint_screen_putpixel

DESCRIPTION
    Loops through the sub-region of the color buffer defined by
    minx, miny, maxx, maxy, accumilating consecutive pixels with
    the same shade and calls 'draw_line' to display those pixels


*/

{
   register HScbuf *cb;

#    ifdef X11
   XImage *xi;

#    endif

   IGRboolean region_update;

   HSget_region_update( &region_update );

   /* for case of a region using our z buffer and a region already  */
   /* there the cbuffer would put the color buffer over the region  */

   if ( region_update )
   {
      HSpaint_screen_ROP(  );
      return;
   }

   if ( active_window->y_min > active_window->y_max )
      return;   /* no trapezoids rasterized since last paint */

   /* make y_min a multiple of 4 so the buffer given */
   /* to putpixelblock will be 32 bit aligned        */

   active_window->y_min &= 0xFFFFFFFC;

   if ( active_window->y_max & 1 )
      active_window->y_max++;

#   if DEBUG
   if ( icount++ < ICSTOP )
   {
      fprintf( stderr, "HSpaint_screen_putpixel\n" );
      fprintf( stderr, "  w_no ---- %d\n", active_window->win_no );
      fprintf( stderr, "  x_min --- %d\n", active_window->x_min );
      fprintf( stderr, "  x_max --- %d\n", active_window->x_max );
      fprintf( stderr, "  y_min --- %d\n", active_window->y_min );
      fprintf( stderr, "  y_max --- %d\n", active_window->y_max );
      fprintf( stderr, "  cb ------ %x\n", active_window->cbuf );
   }
#   endif

   cb = ( HScbuf * ) active_window->cbuf + active_window->y_min *
      active_window->x_dits;


   /* Add in offset, incase clip range origin and window origin are not the
    * same */

   /* instead of calling WLcreate_raster_data and WLfree_raster_data set up once for window */
   active_window->image.x = tiling_parms.x_offset;
   active_window->image.y = active_window->y_min + tiling_parms.y_offset;
   active_window->image.width = active_window->x_dits;
   active_window->image.height = active_window->y_max - active_window->y_min + 1;
   active_window->image.buffer = (char *) cb;

   WLput_raster_data( active_window->win_no, active_window->context_no, &active_window->image );

   /* Reset min/max and trapezoid count */

   active_window->x_min = active_window->x_dits << 16;
   active_window->y_min = active_window->y_dits;
   active_window->x_max = 0;
   active_window->y_max = 0;

}/* HSpaint_screen_putpixel */


#if defined( ENV5 )

/*---HSpaint_screen_IFB-----------------------------------------------------*/

void HSpaint_screen_IFB(void)

   {
#  if DEBUG
      if( icount++ < ICSTOP )
         {
         fprintf( stderr, "HSpaint_screen_IFB....\n" );
         fprintf( stderr, "  delete mode --- %d\n", element_parms.delete );
         fprintf( stderr, "  xmin, ymin ---- %d %d\n", 
            active_window->x_min >> 16, active_window->y_min );
         fprintf( stderr, "  xmax, ymax ---- %d %d\n", 
            active_window->x_max >> 16, active_window->y_max );
         }
#  endif

   if( element_parms.delete )
      {
      sh_set_zbuf( active_window->hwin_no,
                   active_window->x_min >> 16,
                   active_window->y_min,
                   active_window->x_max >> 16,
                   active_window->y_max,
                   HS_BACKGROUND_Z );
      }
		
   /*
    *  Reset min/max
    */

   active_window->x_min = active_window->x_dits << 16;
   active_window->y_min = active_window->y_dits;
   active_window->x_max = 0;
   active_window->y_max = 0;
   }

/*---HSpaint_screen_merge24-------------------------------------------------------------------------*/

void HSpaint_screen_merge24(
   void )

{
   int status;
   struct WLnative_info native_info;

#   if DEBUG
   if ( icount++ < ICSTOP )
   {
      fprintf( stderr, "HSpaint_screen_merge24\n" );
      fprintf( stderr, "  x_dits, y_dits -- %d %d\n", active_window->x_dits, active_window->y_dits );
      fprintf( stderr, "  zbuf, cbuf ------ %x %x\n", active_window->zbuf, active_window->cbuf );
   }
#   endif

   if ( (active_window->cbuf != NULL) &&
        ( active_window->unsupported_zbuffer_allocated) )
   {
      fprintf( stderr, "PAINT SCREEN MERGE24:  need indexex VLT to assign to window\n" );
      WLhide_cursor( active_window->win_no, FALSE );
      WLget_native_info( active_window->win_no, active_window->context_no, &native_info );

      mergeZbufferpixelblock24( native_info.base_win,
                                0,
                                0,
                                active_window->x_dits - 1,
                                active_window->y_dits - 1,
                                active_window->cbuf,
                                active_window->zbuf );


      WLhide_cursor( active_window->win_no, 1 );
      WLflush( active_window->win_no );
   }

}  /* HSpaint_screen_merge24 */

/*---HSpaint_screen_merge-------------------------------------------------------------------------*/

void HSpaint_screen_merge(
   void )

{
   int status;
   struct WLnative_info native_info;

#   if DEBUG
   if ( icount++ < ICSTOP )
   {
      fprintf( stderr, "HSpaint_screen_merge24\n" );
      fprintf( stderr, "  x_dits, y_dits -- %d %d\n", active_window->x_dits, active_window->y_dits );
      fprintf( stderr, "  zbuf, cbuf ------ %x %x\n", active_window->zbuf, active_window->cbuf );
   }
#   endif

   if ( (active_window->cbuf != NULL) &&
        ( active_window->unsupported_zbuffer_allocated) )
   {
      WLhide_cursor( active_window->win_no, FALSE );
      WLget_native_info( active_window->win_no, active_window->context_no, &native_info );

      mergeZbufferpixelblock( native_info.base_win,
                                0,
                                0,
                                active_window->x_dits - 1,
                                active_window->y_dits - 1,
                                active_window->cbuf,
                                active_window->zbuf );


      WLhide_cursor( active_window->win_no, 1 );
      WLflush( active_window->win_no );
   }

}  /* HSpaint_screen_merge24 */

#else
void HSpaint_screen_merge24( void )
   {
   printf( "STUB: HSpaint_screen_merge24\n" );
   }
void HSpaint_screen_merge( void )
   {
   printf( "STUB: HSpaint_screen_merge\n" );
   }
#endif

/*---HSpaint_screen_stub-----------------------------------------------------*/

void HSpaint_screen_stub(
   void )

{
#   if DEBUG
   if ( icount++ < ICSTOP )
      fprintf( stderr, "HSpaint_screen_stub....\n" );
#   endif

   if ( active_window->x_min_us > active_window->x_min )
      active_window->x_min_us = active_window->x_min;
   if ( active_window->y_min_us > active_window->y_min )
      active_window->y_min_us = active_window->y_min;
   if ( active_window->x_max_us < active_window->x_max )
      active_window->x_max_us = active_window->x_max;
   if ( active_window->y_max_us < active_window->y_max )
      active_window->y_max_us = active_window->y_max;
}

