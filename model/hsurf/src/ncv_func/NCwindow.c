
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:40 $
$Locker:  $
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "wl.h"

#include "hnmilling.h"
#include "hnerror.h"

#include "OMminimum.h"

#include "igetypedef.h"
#include "igrtypedef.h"
#include "igewindef.h"
#include "igr.h"

#include "hsdisplay.h"
#include "hstiler.h"
#include "hnmill.h"

#include "igecolordef.h"

#include "HSpr_ncv_fun.h"

/**********************
 * EXTERNAL VARIABLES *
 **********************/

extern void                     HSenable_dexels();
extern IGRboolean               HScheck_dexel_memory();

extern struct NC_error_flags    NCerror_flags;
extern struct NC_shading_parms  NCshading;
extern struct NC_window_parms   NCwindow;
extern NCcbuf                    NCbackground_c;

/*******************
 * LOCAL VARIABLES *
 *******************/

static IGRint      total_bytes;

/*---NCsetup_shading_window--------------------------------------------------*/

void   NCsetup_shading_window( IGRint         pipe_no,
                               IGRint         win_no,
                               IGRdouble      win_tol,
                               IGRdouble      z_scale,
                               IGRboolean     ifb,
                               IGRboolean     direct,
                               unsigned int   constant,
                               unsigned int   smooth,
                               unsigned char  *a_cbuf,
                               IGRint         aorg_x,
                               IGRint         aorg_y,
                               IGRint         ax_size,
                               IGRint         ay_size )

/*
 * ABSTRACT:  NCsetup_shading_window allocates and initializes the NCshading
 *            window information structure.  It also defines the shading flags.
 *
 * HISTORY:   07/26/88   Created.                    C. M. Jablonski
 *            10/25/88   initialize some variables   K. M. Jehng
 *
 */

{
   WLuint32 background_uint;
   WLuint32 context_no;

   /* initialize the local window data structure's fields */
   NCwindow.win_no = win_no;
   NCwindow.pipe_no = pipe_no;
   NCwindow.win_tol = win_tol;
   NCwindow.z_scale = z_scale;

   /* reset the range fields, so that trapezoids will determine the new range */
   NCwindow.x_min = 0x7fffffff;
   NCwindow.y_min = 0x7fffffff;
   NCwindow.x_max = 0x80000000;
   NCwindow.y_max = 0x80000000;

   /* reset the dorg fields, so that trapezoids will not be adjusted */
   NCwindow.dorg_x = 0;
   NCwindow.dorg_y = 0;

   /* define the shading flags */
   NCshading.direct = direct;
   NCshading.CONSTANT_SHADING = constant;
   NCshading.SMOOTH_SHADING = smooth;

   /* initialize the pointers */
   NCwindow.dexarry = NULL;
   NCwindow.simbuf = NULL;
   NCwindow.zbuf = NULL;
   NCwindow.zbuf2 = NULL;
   NCwindow.cbuf = NULL;

   /* initialize all offset and part / tool buffer sizes */
   NCwindow.px_off = NCwindow.py_off = NCwindow.px_dits = NCwindow.py_dits =
   NCwindow.dx_off = NCwindow.dy_off = NCwindow.dx_dits = NCwindow.dy_dits =
   NCwindow.sx_off = NCwindow.sy_off = NCwindow.sx_dits = NCwindow.sy_dits =
             NULL;

   /* set background buffer pointer and size fields */
   NCwindow.bbuf = a_cbuf;
   NCwindow.borg_x = aorg_x;
   NCwindow.borg_y = aorg_y;
   NCwindow.bx_dits = ax_size;
   NCwindow.by_dits = ay_size;

   /* initialize the background object image buffer */
   WLget_window_base_context( NCwindow.win_no, &context_no );
   IGEcmap_color_to_index( context_no, 0 /* logical background_color */, 0, 0, 0, 0, &background_uint );
   NCbackground_c = background_uint;
/*
   memset (NCwindow.bbuf, NCbackground_c, NCwindow.bx_dits*NCwindow.by_dits);
*/
}


/*---NCinit_window-------------------------------------------------------*/

IGRboolean   NCinit_window(void)

/*
 * ABSTRACT:   NCinit_window uses the current x-y min-max parameters
 *             to initialize the buffer size and clip range in NCwindow.
 *             This routine is designed to be called immediately after the
 *             workpiece has been made into trapezoids and before it has
 *             been painted, so that the x-y min-max parameters will equal
 *             the range of the workpiece.
 *
 * HISTORY:  07/26/88   Created.              C. M. Jablonski
 *           10/12/88   init dexarry->color   K. M. Jehng
 *
 */

{
   IGRint                   total_dexels;
   IGRint                   x_min;
   IGRint                   x_max;
   IGRint                   y_min;
   IGRint                   y_max;
   register struct NCdexel  *dexarry;
   register int             x;
   register int             y;


   /*
    * Special handling of no environment objects. In this case,
    * the dexel region will default to {(0,0), (1,0)}.
    */

   if (NCwindow.y_min > NCwindow.y_max)
   {
      NCwindow.y_min = 0;
      NCwindow.y_max = 0;
      NCwindow.x_min = 0 << 16;
      NCwindow.x_max = 0 << 16;
   }

   y_min = NCwindow.y_min;
   y_max = NCwindow.y_max;

   /*
    * UN-shift x_min and x_max to convert from fixed-point to true integer
    * values.
    */

   x_min = NCwindow.x_min >> 16;
   x_max = (NCwindow.x_max >> 16) + 1;

   /*
    * Change the extent of the arrays to be that of the workpiece.
    */

   NCwindow.dx_dits = x_max - x_min + 1;
   NCwindow.dy_dits = y_max - y_min + 1;


   /*
    * Make sure the display area is an even number of dexels wide.
    * If not, PUT_LINE does not work right.
    */

   if ( NCwindow.dx_dits & 1 ) NCwindow.dx_dits++;


   /*
    * The total number of dexels in a window is equal to the number
    * of dits in x times the number of dits in y.
    */

   total_dexels = NCwindow.dx_dits * NCwindow.dy_dits;


   /*
    * Allocate memory for the buffers.
    */

   total_bytes = ( total_dexels * 1.2 ) * sizeof ( struct NCdexel );

   NCerror_flags.memory_fault = !HScheck_dexel_memory(total_bytes);

   if (!NCerror_flags.memory_fault)
   {
      NCinit_dexel_buffers( total_dexels,
                            &NCwindow.dexarry,
                            &NCwindow.zbuf,
                            &NCwindow.zbuf2,
                            &NCwindow.cbuf );

      if (!NCerror_flags.memory_fault)
      {
         /*
          * Initialize the dexel array values.
          */

         dexarry = NCwindow.dexarry;

         for ( x=0; x<NCwindow.dx_dits; x++ )
         {
            dexarry->u.z.near_z = dexarry->u.z.far_z = NCbackground_z;
            dexarry->next_hi = dexarry->next_lo = NULL;
            dexarry->color = NCbackground_c;
            dexarry++;
         }

         for ( y=1; y<NCwindow.dy_dits; y++ )
         {
            memcpy( dexarry, NCwindow.dexarry,
                    sizeof( struct NCdexel ) * NCwindow.dx_dits );
            dexarry += NCwindow.dx_dits;
         }


         /*
          * Initialize the color buffer.
          */

         memset( NCwindow.cbuf, NCbackground_c, total_dexels );


         /*
          * Set the dorg fields, which are the offsets in x and y of the
          * dexel arrays from the viewport origin, defined in org_x and org_y.
          */

         NCwindow.dorg_x = x_min << 16;
         NCwindow.dorg_y = y_min;
         NCwindow.dx_off = x_min;
         NCwindow.dy_off = y_min;


         /*
          * Set the paint region extents and offsets equal to those
          * of the dexel array.
          */

         NCwindow.px_dits = NCwindow.dx_dits;
         NCwindow.py_dits = NCwindow.dy_dits;
         NCwindow.px_off = NCwindow.dx_off;
         NCwindow.py_off = NCwindow.dy_off;


         /*
          * Adjust the tiler to now produce trapezoids for swept volumes.
          */

         HSadjust_dexels ( &(NCshading.apparent_shades),
                           x_min,
                           y_min,
                           x_max,
                           y_max );

#ifdef DEBUG
{
         fprintf (stderr, "dorg_x=%d, dorg_y=%d, dx_off=%d, dy_off = %d\n",
                           NCwindow.dorg_x,
                           NCwindow.dorg_y,
                           NCwindow.dx_off,
                           NCwindow.dy_off);

         fprintf (stderr, "dx_dits=%d, dy_dits=%d\n",
                           NCwindow.dx_dits,
                           NCwindow.dy_dits);

         fprintf (stderr, "x_min=%d,(%d) y_min=%d\n",
                           NCwindow.x_min,
                           NCwindow.x_min>>16,
                           NCwindow.y_min);

         fprintf (stderr, "x_max=%d,(%d) y_max=%d\n",
                           NCwindow.x_max,
                           NCwindow.x_max>>16,
                           NCwindow.y_max);
}
#endif
      }
      else
      {
         /* not enough memory, so clean up */
         HSrestore_dexel_memory(total_bytes);
      }
   }
   return(TRUE);
}


/*---NCcleanup_window-------------------------------------------------------*/

void   NCcleanup_window(void)

/*
 * ABSTRACT:   NCcleanup_window frees the window-related data structures.
 *
 * HISTORY:   07/26/88   Created.         C. M. Jablonski
 *
 */

{
   HSrestore_dexel_memory(total_bytes);

   if (NCwindow.dexarry)
   {
      free(NCwindow.dexarry);
      NCwindow.dexarry = NULL;
   }
   free_simbuf();

   if (NCwindow.zbuf)
   {
      free(NCwindow.zbuf);
      NCwindow.zbuf = NULL;
   }

   if (NCwindow.zbuf2)
   {
      free(NCwindow.zbuf2);
      NCwindow.zbuf2 = NULL;
   }

   if (NCwindow.cbuf)
   {
      free(NCwindow.cbuf);
      NCwindow.cbuf = NULL;
   }
}

