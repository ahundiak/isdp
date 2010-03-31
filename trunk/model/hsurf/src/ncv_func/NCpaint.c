
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:40 $
$Locker:  $
*/

#include <stdio.h>
#include <stdlib.h>
#include <stdio.h>

#include "wl.h"

#include "dpgraphics.h"
#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "hsdisplay.h"
#include "hstiler.h"
#include "hnmilling.h"
#include "hntiming.h"
#include "hnmill.h"

#include "HSpr_ncv_fun.h"


/**********************
 * EXTERNAL VARIABLES *
 **********************/

extern struct NC_window_parms    NCwindow;
extern struct NC_shading_parms   NCshading;
extern NCcbuf                    NCbackground_c;

/*---NCpaint-----------------------------------------------------*/

void NCpaint(void)

/*

DESCRIPTION
   Loops through the sub-region of the color buffer defined by
   minx, miny, maxx, maxy, drawing one line at a time.

HISTORY:   03/01/88   Created.            C. M. Jablonski


*/
{

   register int          y;
   register int          x;
   register NCcbuf       *cb;
   NCcbuf                *bg_cb;

   int                   x_min;
   int                   x_max;
   int                   x_delta;

   struct WLraster_data  image;
   WLuint32              context_no;
   

   START_NC_TIMING(NCtd_PAINT)

   /*
    *  Start at the bottom of the sub-region and move up
    */

   NCwindow.x_min >>= 16;
   NCwindow.x_max >>= 16;

   NCwindow.x_min &= 0xfffffffe;


   /*
    *  Get address of pixel in color-buffer at left side of
    *  of region, for the given y
    */


   cb = (NCcbuf *)NCwindow.cbuf + NCwindow.y_min *
                  NCwindow.px_dits + NCwindow.x_min;

   x_delta = (NCwindow.x_max - NCwindow.x_min) + 1;
   x_min = NCwindow.x_min + NCwindow.px_off;
   x_max = NCwindow.x_max + NCwindow.px_off;

#ifdef DEBUG
   fprintf( stderr, "  w_no ---- %d\n", NCwindow.win_no );
   fprintf( stderr, "  x_min --- %d\n", NCwindow.x_min );
   fprintf( stderr, "  x_max --- %d\n", NCwindow.x_max );
   fprintf( stderr, "  y_min --- %d\n", NCwindow.y_min );
   fprintf( stderr, "  y_max --- %d\n", NCwindow.y_max );
   fprintf( stderr, "  cb ------ %x\n", cb );
   fprintf( stderr, "  x_delta - %d\n", x_delta );
#endif


   WLget_window_base_context( NCwindow.win_no, &context_no );

   WLcreate_raster_data( NCwindow.win_no,
                         context_no,
                         &image,
                         x_min,
                         NCwindow.y_min + NCwindow.py_off,
                         x_max-x_min+1,
                         1,
                         8,
                         WL_SLOW_BUFFER,
                         (char *)cb );


   for ( y = NCwindow.y_min + NCwindow.py_off;
         y <= NCwindow.y_max + NCwindow.py_off; y++ )
   {

      bg_cb = NCwindow.bbuf + y*NCwindow.bx_dits + x_min;

      if ((y >= 0) && (y <= (NCwindow.py_off + NCwindow.py_dits)))
      {
         /* set background to background image buffer values */
         for (x=0; x < (x_max - x_min + 1); x++, bg_cb++)
         {
            if (*(cb+x) == NCbackground_c)
            {
               *(cb+x) = *bg_cb;
            }
         }

         image.buffer = (char *)cb;
         image.x = x_min;
         image.y = y;

         WLput_raster_data( NCwindow.win_no,
                            context_no,
                            &image );

         cb += NCwindow.px_dits;
      }
   }

   /*
    *  Reset min/max
    */
   WLfree_raster_data( &image );
   NCwindow.x_min = 0x7fffffff;
   NCwindow.y_min = 0x7fffffff;
   NCwindow.x_max = 0x80000000;
   NCwindow.y_max = 0x80000000;

   STOP_NC_TIMING(NCtd_PAINT)
}


/*---NCpaint_sim_tool------------------------------------------------*/

void NCpaint_sim_tool( IGRint *x1,
                       IGRint *y1,
                       IGRint *sx_dits,
                       IGRint *sy_dits )

/*

DESCRIPTION
   Paint the simulation tool buffer using the geven range.
   NOTE: it is assumed that x1 is even for horiziontal lines and
   y1 is even for vertical lines.

HISTORY:  09/25/88   Created.                                 K. M. Jehng
          10/03/88   Added vertical putline, double buffer    C. M. Jablonski
          09/14/93   added WLfree_raster_data and only one WLcreate_raster_data
                     call per function execution.             J. D. Underwood
*/

{
   struct WLraster_data   image;
   WLuint32               context_no;

#ifdef DEBUG
   fprintf( stderr, "\n**** NCpaint_sim_tool ****\n");
   fprintf(stderr,
           "x1=%d, y1=%d, xd=%d, yd=%d, pxo=%d, pyo=%d, pxd=%d, pyd=%d\n",
            *x1, *y1, *sx_dits, *sy_dits, NCwindow.px_off, NCwindow.py_off,
            NCwindow.px_dits, NCwindow.py_dits);
#endif

   START_NC_TIMING(NCtd_PAINT_SIM)

   WLget_window_base_context( NCwindow.win_no, &context_no );

   /* putpixelblock is much faster for ifb engine            */
   if (NCshading.ifb)
   {
      WLcreate_raster_data( NCwindow.win_no,
                            context_no,
                            &image,
                            NCwindow.px_off,
                            NCwindow.py_off,
                            NCwindow.sx_dits + NCwindow.px_off - 1,
                            NCwindow.sy_dits + NCwindow.py_off - 1,
                            8,
                            WL_SLOW_BUFFER,
                            (char *)NCwindow.cbuf );

      WLput_raster_data( NCwindow.win_no,
                         context_no,
                         &image );

      WLfree_raster_data( &image );
   }
   else
   {
      register NCcbuf  *cb;
      register NCcbuf  *cb2;
      int              start_x=0;
      int              start_y=0;
      int              x_max;
      int              y_max;


      if (NCwindow.horizontal_scan)
      {
         cb2 = (NCcbuf *)NCwindow.cbuf + *y1 * NCwindow.px_dits + *x1;
         cb = (NCcbuf *)NCwindow.cbuf + *y1 * NCwindow.px_dits + *x1;

         if( NCwindow.py_off < 0 )
         {
            cb2 = cb -= (NCwindow.px_dits * NCwindow.py_off);
            start_y = 0;
         }
         else
         {
            start_y = NCwindow.py_off;
         }

         x_max = *sx_dits;
         y_max = *sy_dits + NCwindow.py_off;

         if ( NCwindow.px_off < 0 )
         {
            start_x = 0;
            x_max += NCwindow.px_off;
            cb2 = cb -= NCwindow.px_off;
         }
         else
         {
            start_x = NCwindow.px_off;
         }

#ifdef DEBUG
         fprintf(stderr, "start_y = %d, start_x = %d, y_max = %d, x_max = %d\n",
                  start_y, start_x, y_max, x_max );
#endif
         WLcreate_raster_data( NCwindow.win_no,
                                  context_no,
                                  &image,
                                  start_x,
                                  start_y,
                                  x_max,
                                  1,
                                  8,
                                  WL_SLOW_BUFFER,
                                  (char *)cb );

         image.x = start_x;
         image.width = x_max;
         image.height = 1;
         for ( image.y = start_y; image.y < y_max; image.y+=2 )
         {
            image.buffer = (char *)cb;

            WLput_raster_data( NCwindow.win_no,
                               context_no,
                               &image );

            cb += 2 * NCwindow.px_dits;
         }

         cb = cb2 + NCwindow.px_dits;
         /*image.x = start_x;*/
         /*image.width = x_max;*/
         /*image.height = 1;*/

         for ( image.y = start_y + 1; image.y < y_max; image.y+=2 )
         {
            image.buffer = (char *)cb;

            WLput_raster_data( NCwindow.win_no,
                               context_no,
                               &image );

            cb += 2 * NCwindow.px_dits;
         }
         WLfree_raster_data( &image );
      }
      else
      {
         cb2 = cb = (NCcbuf *)NCwindow.cbuf + *x1 * NCwindow.py_dits + *y1;

         if( NCwindow.px_off < 0 )
         {
            cb2 = cb -= (NCwindow.py_dits * NCwindow.px_off);
            start_x = 0;
         }
         else
         {
            start_x = NCwindow.px_off;
         }

         x_max = *sx_dits + NCwindow.px_off;
         y_max = *sy_dits;

         if ( NCwindow.py_off < 0 )
         {
            start_y = 0;
            y_max += NCwindow.py_off;
            cb2 = cb -= NCwindow.py_off;
         }
         else
         {
            start_y = NCwindow.py_off;
         }

#ifdef DEBUG
fprintf( stderr, "start_x = %d, start_y = %d, y_max = %d, x_max = %d\n",
                  start_x, start_y, y_max, x_max );
#endif
         WLcreate_raster_data( NCwindow.win_no,
                                  context_no,
                                  &image,
                                  start_x,
                                  start_y,
                                  1,
                                  y_max,
                                  8,
                                  WL_SLOW_BUFFER,
                                  (char *)cb );

         image.y = start_y;
         image.width = 1;
         image.height = y_max;
         for ( image.x = start_x; image.x < x_max; image.x+=2 )
         {
            image.buffer = (char *)cb;
            WLput_raster_data( NCwindow.win_no,
                               context_no,
                               &image );

            cb += 2 * NCwindow.py_dits;
         }

         cb = cb2 + NCwindow.py_dits;
         /*image.y = start_y;*/
         /*image.width = 1;*/
         /*image.height = y_max;*/
         for ( image.x = start_x + 1; image.x < x_max; image.x+=2 )
         {
            image.buffer = (char *)cb;
            WLput_raster_data( NCwindow.win_no,
                               context_no,
                               &image );

            cb += 2 * NCwindow.py_dits;
         }
         WLfree_raster_data( &image );
      }
   }

   STOP_NC_TIMING(NCtd_PAINT_SIM)
}
