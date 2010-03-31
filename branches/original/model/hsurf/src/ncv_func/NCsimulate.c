
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:40 $
$Locker:  $
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

#include "hsncdef.h"
#include "hnmilling.h"
#include "hnerror.h"
#include "hnsimulate.h"
#include "hntiming.h"
#include "hntool.h"
#include "hntoolpath.h"
#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "hsdisplay.h"
#include "hstiler.h"
#include "hnmill.h"

#include "igecolordef.h"

#include "wl.h"
#include "HSpr_ncv_fun.h"

/*------------------------
 *  for functions
 *     HSset_clip_mode
 *     transform_points
 */

#include "igrdp.h"
#include "gr.h"
#include "hskyoptypes.h"
#include "hsanimate.h"
#include "HSrle.h"
#include "HSsara.h"
#include "HSfem_spt.h"
#include "HStl_window.h"
#include "HStl_global.h"
#include "HStl_element.h"
#include "HSe2_mesher.h"
#include "HSpr_tiler_f.h"

/*--------------------------*/


#define DEBUG         FALSE
#define DEBUG_TOOL    FALSE
#define ROUND2(n)     ((IGRint)   (( (n) > 0.0 ) ? (n+0.5) : (n-0.5)))
#define DABS(x)       ((IGRdouble)   (( (x) > 0.0 ) ? (x) : -(x)))
#define MAX(x, y)     (x > y) ? (x) : (y)
#define TOL           1.e-5
#define FREE(ptr)     { if (ptr) {free(ptr); ptr = NULL;} }
#define MALLOC(x, n)  ((x *) malloc (n * sizeof(x)))

#define OUT_OF_MEM_HANDLING                              \
{                                                        \
   free_simbuf();                                        \
   NCerror_flags.memory_fault = TRUE;                    \
      return;                                            \
}

#define INIT_SIMDEX(simdex)                              \
{                                                        \
   simdex->near_z = simdex->far_z = NCbackground_z;      \
   simdex->near_c = simdex->far_c = NCbackground_c;      \
}

/**********************
 * EXTERNAL VARIABLES *
 **********************/

extern struct NC_error_flags     NCerror_flags;
extern struct NC_shading_parms   NCshading;
extern struct NC_sim_data        NCsim_data;
extern struct NC_tool_data       NCtool_data;
extern struct NC_toolpath_data   NCtoolpath_data;
extern struct NC_window_parms    NCwindow;
extern NCcbuf                    NCbackground_c;

/**********************
 * LOCAL VARIABLES    *
 **********************/

static IGRdouble      ncv_z_offset;
static IGRint         ncv_zero = 0;
static IGRdouble      ncv_old_loc[3];
static IGRdouble      ncv_old_orient[3];
static IGRint         ncv_old_toploc[3];
static IGRdouble      ncv_acc_err;

/* prev. start painting point */
static IGRint         ncv_prev_xlo;
static IGRint         ncv_prev_ylo;

static IGRint         ncv_sy_ds;
static IGRint         ncv_sx_ds;
static IGRint         p_dim;      /* pattern dimension.
                                     p_dim = 4 for half_tone;
                                     p_dim = 1 for direct      */

static IGRint         first_time = 0;

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

/* NCsimulate.c */
static void CreateCoordSystem __(( IGRvector vector,
                                   IGRvector x,
                                   IGRvector y,
                                   IGRvector z));

static IGRint sign __(( IGRint x ));

static void bresenham __(( IGRint x1,
                           IGRint y1,
                           IGRint z1,
                           IGRint x2,
                           IGRint y2,
                           IGRint z2,
                           IGRint *lastx,
                           IGRint *lasty,
                           IGRint *lastz,
                           IGRboolean do_endpt));

static void bresenham_five_axis __(( IGRdouble i1,
                                     IGRdouble j1,
                                     IGRdouble k1,
                                     IGRdouble i2,
                                     IGRdouble j2,
                                     IGRdouble k2,
                                     IGRint x1,
                                     IGRint y1,
                                     IGRint z1,
                                     IGRint x2,
                                     IGRint y2,
                                     IGRint z2,
                                     IGRint xt1,
                                     IGRint yt1,
                                     IGRint zt1,
                                     IGRint xt2,
                                     IGRint yt2,
                                     IGRint zt2,
                                     IGRint *lastx,
                                     IGRint *lasty,
                                     IGRint *lastz,
                                     IGRint *lastxt,
                                     IGRint *lastyt,
                                     IGRint *lastzt,
                                     IGRboolean do_endpt));

#if defined(__cplusplus)
}
#endif


#undef __



static void CreateCoordSystem( IGRvector vector,
                               IGRvector x,
                               IGRvector y,
                               IGRvector z )

{
   IGRint    i;
   IGRdouble size = 0.0;


   for (i = 0; i < 3; i++)
   {
      size += vector[i] * vector[i];
   }

   size = sqrt (size);

   for (i = 0; i < 3; i++)
   {
      z[i] = vector[i] / size;
   }

   if ((z[2] > 0.99999) || (z[2] < -0.99999))
   {
      x[0] = 1.0;
      x[1] = 0.0;
      x[2] = 0.0;
      y[0] = 0.0;
      y[1] = z[2];
      y[2] = 0.0;
   }
   else
   {
      IGRdouble denominator;

      denominator = sqrt (z[0] * z[0] + z[1] * z[1]);

      x[0] = - z[1] / denominator;
      x[1] =   z[0] / denominator;
      x[2] =   0.0;
      y[0] = - z[0] * z[2] / denominator;
      y[1] = - z[1] * z[2] / denominator;
      y[2] =   denominator;
   }
}

/*-----NCupdate_sim_location-------------------------------------------------*/

void NCupdate_sim_location(void)

/*
 * ABSTRACT:   NCupdate_sim_location updates the location of the simbuf.
 *
 * HISTORY:   09/13/88   Created.         C. M. Jablonski
 *
 */

{
   ncv_old_loc[0] = NCtoolpath_data.curr_location[0];
   ncv_old_loc[1] = NCtoolpath_data.curr_location[1];
   ncv_old_loc[2] = NCtoolpath_data.curr_location[2];
   transform_points( FALSE, 1, ncv_old_loc, 0 );

   /* reset the z-offset to the current location */
   ncv_z_offset = ncv_old_loc[2];
}


/*-----NCinit_simulation------------------------------------------------------*/

void NCinit_simulation(void)

/*
 * ABSTRACT:   NCinit_simulation performs initialization of simulation mode.
 *             It is assumed that the environment objects have already been
 *             dexelized and displayed, so now the z and image buffers can be
 *             freed.
 * 
 * HISTORY:   09/12/88   Created.                        C. M. Jablonski
 *            09/18/88   Added z_scale.                  K. M. Jehng
 *            11/23/88   Added 16 pattern for half_tone  K. M. Jehng
 *            11/28/88   Moved z_scale into window.      C. M. Jablonski
 *
 */

{
   /* initialize the simulation data */
   NCsim_data.simulation_speed = HSNC_DEFAULT_SIM_SPEED;   /* 2 */
   NCsim_data.active_tool_color = HSNC_USE_TOOL_COLOR;   /* -1 */

   /* calculate z_buffer scale */
   ncv_z_offset = 0.0;
   ncv_acc_err = 0.0;


   /* set up pattern dimension */
   p_dim = (NCshading.direct) ? 1 : 4;

   /* free the z-buffers */
   FREE(NCwindow.zbuf)
   FREE(NCwindow.zbuf2)

   /* free the color buffer */
   FREE(NCwindow.cbuf)
}

/*-----free_simbuf------------------------------------------------------kmj---*/

void free_simbuf(void)

{
   FREE(NCwindow.simbuf)

   FREE(NCwindow.shadebuf)
}

/*-----NCcleanup_simulation---------------------------------------------------*/

void NCcleanup_simulation( IGRboolean free_cbuf )

/*
 * ABSTRACT:   NCcleanup_simulation frees those data structures that are
 *             associated with simulation mode.
 *
 * HISTORY: 09/13/88   Created.              C. M. Jablonski
 *          08/10/90   Added free_cbuf.      C. M. Jablonski
 */

{
   /* free the simulation buffer */
   free_simbuf();

   /* free the color buffer */
   if (free_cbuf)
   {
      FREE (NCwindow.cbuf)
   }

   first_time = 0;
}


/*-----NCupdate_sim_buffer----------------------------------------------------*/

void NCupdate_sim_buffer( IGRboolean remove_old_tool )

/*
 * ABSTRACT:   NCsim_update_buffer updates the simulation buffer using the new
 *             tool/orientation.  First, it tiles the tool and finds the range
 *             box.  Then, it (re)allocates a simbuf and cbuf according to the
 *             new range.  And, finally, it dexelizes the tool trapezoids into
 *             the simbuf.
 *
 * HISTORY:   09/12/88   Created.         C. M. Jablonski
 *            09/27/88   If tool has been changed, then we need to paint
 *                       original tool area to current part or background
 *                        K. M. Jehng
 *            10/03/88   Added vertical scan lines.   C. M. Jablonski
 *            11/23/88   Added 16 patterns for ht   K. M. Jehng
 *
 */

{
   IGRint             x_min;
   IGRint             x_max;
   IGRint             y_min;
   IGRint             y_max;
   IGRint             total_dexels;
   register simDexel  *simdex;
   register simDexel  *shadex;
   register int       x;
   register int       y;


   /* if user changes tool, then repaint tool region to part/background   */
   if (remove_old_tool && NCwindow.cbuf)
   {
      NCremove_tool_region( FALSE );
   }

   /* free the previous simulation buffer                */
   NCcleanup_simulation (!remove_old_tool);

   /* set the simbuf to the current location             */
   if (first_time == 0 || !NCtoolpath_data.five_axis)
   {
      NCupdate_sim_location();
   }

   /*
    * Reset the range fields, so that trapezoids will determine the new range.
    * NOTE: since we are not clipping, the range may be entirely negative,
    * so initialize the max fields to the most negative numbers and the min
    * fields to the greatest positive numbers.
    */

   NCwindow.x_min = 0x7fffffff;
   NCwindow.y_min = 0x7fffffff;
   NCwindow.x_max = 0x80000000;
   NCwindow.y_max = 0x80000000;


   /* turn off tiler clipping  */
   HSset_clip_mode( FALSE );


   /* tile the tool */
   START_NC_TIMING(NCtd_TILE)
   NCtile_tool();
   STOP_NC_TIMING(NCtd_TILE)

   /*
    * Get the range of the tiled tool.  NOTE: we need to add the dorg values
    * since they were subtracted in NCsave_trap.
    */

   y_min = NCwindow.y_min + NCwindow.dorg_y;
   y_max = NCwindow.y_max + NCwindow.dorg_y + 10;


   /*
    * UN-shift x_min and x_max to convert from fixed-point to true integer
    * values.
    */

   x_min = (NCwindow.x_min + NCwindow.dorg_x) >> 16;
   x_max = ((NCwindow.x_max + NCwindow.dorg_x) >> 16) + 10;

#if DEBUG
   fprintf(stderr, "ymin, ymax, xmin, xmax: %d %d %d %d\n",
                    y_min, y_max, x_min, x_max);
#endif

   /* Add the tool border. */
   if (NCtoolpath_data.five_axis)
   {
      x_min -= 2*NCsim_data.simulation_speed;
      x_max += 2*NCsim_data.simulation_speed;
      y_min -= 2*NCsim_data.simulation_speed;
      y_max += 2*NCsim_data.simulation_speed;
   }
   else
   {
      x_min -= NCsim_data.simulation_speed;
      x_max += NCsim_data.simulation_speed;
      y_min -= NCsim_data.simulation_speed;
      y_max += NCsim_data.simulation_speed;
   }
#if DEBUG
   fprintf(stderr, "ymin, ymax, xmin, xmax: %d %d %d %d\n",
                    y_min, y_max, x_min, x_max);
#endif


   /* Set the extent of the buffers to be that of the tool. */
   NCwindow.sx_dits = x_max - x_min + 1;
   NCwindow.sy_dits = y_max - y_min + 1;


   /*
    * Set the scan direction flag.  If the buffer has fewer dits in x than
    * in y, we will paint vertical scan lines in order to have fewer
    * putline calls.
    * if ifb engine, we use putpixelblock which only accept horizontal scan
    * line.
    */

   NCwindow.horizontal_scan =
                     ((NCwindow.sx_dits >= NCwindow.sy_dits) || NCshading.ifb);


   /*
    * Make sure the display area is an even number of dexels wide.
    * If not, PUT_LINE does not work right.
    */

    if (NCwindow.horizontal_scan)
    {
       if ( NCwindow.sx_dits & 1 )
       {
          NCwindow.sx_dits++;
       }
    }
    else
    {
       if ( NCwindow.sy_dits & 1 )
       {
          NCwindow.sy_dits++;
       }
    }


   /*
    * The total number of dexels in a window is equal to the number
    * of dits in x times the number of dits in y.
    */

   total_dexels = NCwindow.sx_dits * NCwindow.sy_dits;


   /*
    * Set the sorg fields, which are the offsets in x and y of the
    * buffers from the viewport origin, defined in org_x and org_y.
    */

   NCwindow.sorg_x = x_min << 16;
   NCwindow.sorg_y = y_min;
   NCwindow.sx_off = x_min - NCwindow.dx_off;
   NCwindow.sy_off = y_min - NCwindow.dy_off;

#if DEBUG
   fprintf(stderr, "sx_off, sy_off, dx_off, dy_off: %d %d %d %d\n",
                    NCwindow.sx_off, NCwindow.sy_off, NCwindow.dx_off,
                    NCwindow.dy_off);
#endif

   /* (Re)allocate the simbuf and cbuf. */

   if ( !(NCwindow.simbuf = MALLOC(simDexel, total_dexels)))
   {
      OUT_OF_MEM_HANDLING
   }

   if ( !(NCwindow.shadebuf = MALLOC(simDexel, total_dexels)))
   {
      OUT_OF_MEM_HANDLING
   }

   if ( !(NCwindow.cbuf = MALLOC(NCcbuf, total_dexels)))
   {
      OUT_OF_MEM_HANDLING
   }

   /* Initialize the simulation buffer values. */

   for ( x=0, simdex=NCwindow.simbuf, shadex=NCwindow.shadebuf;
         x<NCwindow.sx_dits; 
         x++, simdex++, shadex++)
   {
      INIT_SIMDEX(simdex)
      INIT_SIMDEX(shadex)
   }

   for ( y=1;
         y<NCwindow.sy_dits;
         y++, simdex += NCwindow.sx_dits, shadex += NCwindow.sx_dits )
   {
      memcpy( simdex, NCwindow.simbuf,
              sizeof(simDexel) * NCwindow.sx_dits );
      memcpy( shadex, NCwindow.shadebuf,
              sizeof(simDexel) * NCwindow.sx_dits );
   }

   /* Initialize the color buffer. */
   memset( NCwindow.cbuf, NCbackground_c, total_dexels );

   /*
    * Set the paint region extents and offsets equal to those of the simbuf.
    */

   NCwindow.px_dits = NCwindow.sx_dits;
   NCwindow.py_dits = NCwindow.sy_dits;
   NCwindow.px_off = NCwindow.sx_off + NCwindow.dx_off;
   NCwindow.py_off = NCwindow.sy_off + NCwindow.dy_off;

   /* dexelize the tool trapezoids into the simbuf */
   NCdexelize_tool();

   /*
    * We can optimize the simbuf by removing those dexels whose near-z and
    * far-z are equal to each other.
    */

   for ( x = 0, simdex = NCwindow.simbuf;
         x < total_dexels;
         x++, simdex++ )
   {
      if ((simdex->near_z != NCbackground_z) &&
          (simdex->near_z == simdex->far_z))
      {
         INIT_SIMDEX(simdex)
      }
   }

   /* reset the paint range to exactly cover the simbuf */
   NCwindow.x_min = 0;
   NCwindow.y_min = 0;
   NCwindow.x_max = (NCwindow.sx_dits - 1) << 16;
   NCwindow.y_max = NCwindow.sy_dits - 1;

#if DEBUG
   fprintf (stderr,"sorg_x=%d, sorg_y=%d\n", NCwindow.sorg_x, NCwindow.sorg_y);
   fprintf (stderr,"sx_off=%d, sy_off=%d\n", NCwindow.sx_off, NCwindow.sy_off);
   fprintf (stderr,"sx_dits=%d, sy_dits=%d\n", NCwindow.sx_dits,
            NCwindow.sy_dits);
   fprintf (stderr,"x_min=%d,(%d) y_min=%d\n", NCwindow.x_min,
            NCwindow.x_min>>16, NCwindow.y_min);
   fprintf (stderr,"x_max=%d,(%d) y_max=%d\n", NCwindow.x_max,
            NCwindow.x_max>>16, NCwindow.y_max);
#endif

   /* turn on tiler clipping */
   HSset_clip_mode( TRUE );

   /* global variables */
   if (!NCshading.ifb)
   {
      if (NCtoolpath_data.five_axis)
      {
         ncv_sx_ds = NCwindow.sx_dits - (NCsim_data.simulation_speed << 1);
         ncv_sy_ds = NCwindow.sy_dits - (NCsim_data.simulation_speed << 1);
      }
      else
      {
         ncv_sx_ds = NCwindow.sx_dits - NCsim_data.simulation_speed;
         ncv_sy_ds = NCwindow.sy_dits - NCsim_data.simulation_speed;
      }

      /* reset previous start painting point */
      ncv_prev_xlo = ncv_prev_ylo = 0;
   }


   /* if user changes tool, then repaint tool region to part/background */
   if (remove_old_tool && NCwindow.cbuf)
   {
      NCremove_tool_region( TRUE );
   }
}


/*-----NCupdate_sim_speed--------------------------------------------------*/

void NCupdate_sim_speed( IGRint newspeed )

/*
 * ABSTRACT:   NCupdate_sim_speed changes the simulation speed and reallocates
 *             the simbuf and cbuf.
 *
 * HISTORY:    09/21/88   Created.               C. M. Jablonski
 *             10/01/88   global values          K. M. Jehng
 *
 */

{
   IGRint           diff;
   IGRint           new_sx_dits;
   IGRint           new_sy_dits;
   IGRint           total_dexels;
   IGRint           x;
   IGRint           y;
   simDexel         *new_simbuf;
   simDexel         *new_shadebuf;

   simDexel         *new_simdex;
   simDexel         *old_simdex;

   simDexel         *new_shadex;
   simDexel         *old_shadex;

   register IGRint  border_factor;


#if DEBUG
   fprintf( stderr, "update_sim_speed: input newspeed=%d, ",  newspeed );
   fprintf( stderr, "NCsim_data.simulation_speed=%d\n",
                    NCsim_data.simulation_speed);
#endif

   if (newspeed == NCsim_data.simulation_speed)
   {
      return;
   }

   /* free the color buffer */
   FREE(NCwindow.cbuf)

   /* determine the change in speed */
   diff = newspeed - NCsim_data.simulation_speed;

   /* determine the new range */
   if (NCtoolpath_data.five_axis)
   {
      border_factor = 4;
   }
   else
   {
      border_factor = 2;
   }

   new_sx_dits = NCwindow.sx_dits + (border_factor * diff);
   new_sy_dits = NCwindow.sy_dits + (border_factor * diff);

   total_dexels = new_sx_dits * new_sy_dits;

   /* allocate the new simbuf */
   if ( !(new_simbuf = MALLOC(simDexel, total_dexels)))
   {
      OUT_OF_MEM_HANDLING
   }

   if ( !(new_shadebuf = MALLOC(simDexel, total_dexels)))
   {
      OUT_OF_MEM_HANDLING
   }


   /* Initialize the simulation buffer values. */
   new_simdex = new_simbuf;
   new_shadex = new_shadebuf;

   for ( x=0; x < new_sx_dits; x++, new_simdex++, new_shadex++)
   {
      INIT_SIMDEX(new_simdex)
      INIT_SIMDEX(new_shadex)
   }

   for ( y=1;
         y<new_sy_dits;
         y++, new_simdex += new_sx_dits, new_shadex += new_sx_dits )
   {
      memcpy( new_simdex, new_simbuf, sizeof(simDexel) * new_sx_dits );
      memcpy( new_shadex, new_shadebuf, sizeof(simDexel) * new_sx_dits );
   }

   /* Copy the values from the old simbuf into the new one.   */
   for (y = 0;
        y < (NCwindow.sy_dits - (border_factor * NCsim_data.simulation_speed));
        y++ )
   {
      if (NCtoolpath_data.five_axis)
      {
         old_simdex = NCwindow.simbuf +
                      ((y + 2 * NCsim_data.simulation_speed) *
                      NCwindow.sx_dits) +
                      2 * NCsim_data.simulation_speed;

         new_simdex = new_simbuf +
                      ((y + 2 * newspeed) * new_sx_dits) + 2 * newspeed;

         old_shadex = NCwindow.shadebuf +
                      ((y + 2 * NCsim_data.simulation_speed)
                      * NCwindow.sx_dits) +
                      2 * NCsim_data.simulation_speed;

         new_shadex = new_shadebuf +
                      ((y + 2 * newspeed) * new_sx_dits) + 2 * newspeed;
      }
      else
      {
         old_simdex = NCwindow.simbuf +
                      ((y + NCsim_data.simulation_speed)
                       * NCwindow.sx_dits) +
                      NCsim_data.simulation_speed;

         old_shadex = NCwindow.shadebuf +
                      ((y + NCsim_data.simulation_speed)
                       * NCwindow.sx_dits) +
                       NCsim_data.simulation_speed;

         new_simdex = new_simbuf +
                     ((y + newspeed) * new_sx_dits) + newspeed;

         new_shadex = new_shadebuf +
                             ((y + newspeed) * new_sx_dits) + newspeed;
      }

      for( x = 0;
           x<(NCwindow.sx_dits - (border_factor *
                          NCsim_data.simulation_speed));
           x++, old_simdex++, new_simdex++, old_shadex++, new_shadex++ )
      {
         if (old_simdex->near_z != NCbackground_z)
         {
            new_simdex->near_z = old_simdex->near_z;
            new_simdex->far_z = old_simdex->far_z;

            new_simdex->near_c = old_simdex->near_c;
            new_simdex->far_c = old_simdex->far_c;

            new_shadex->near_c = old_shadex->near_c;
            new_shadex->far_c = old_shadex->far_c;
         }
      }
   }

   /* free the old simulation buffer */
   FREE(NCwindow.simbuf)
   FREE(NCwindow.shadebuf)

   /* assign the new simulation buffer to the window */
   NCwindow.simbuf = new_simbuf;
   NCwindow.shadebuf = new_shadebuf;

   /* adjust the range */
   NCwindow.sx_dits = new_sx_dits;
   NCwindow.sy_dits = new_sy_dits;

   /* adjust the offsets */
   NCwindow.sx_off -= diff;
   NCwindow.sy_off -= diff;

   /* adjust the paint region */
   NCwindow.px_dits = NCwindow.sx_dits;
   NCwindow.py_dits = NCwindow.sy_dits;
   NCwindow.px_off = NCwindow.sx_off + NCwindow.dx_off;
   NCwindow.py_off = NCwindow.sy_off + NCwindow.dy_off;


   /* reset the paint range to exactly cover the simbuf */
   NCwindow.x_min = NCwindow.y_min = 0;
   NCwindow.x_max = (NCwindow.sx_dits - 1) << 16;
   NCwindow.y_max = NCwindow.sy_dits - 1;

   /* allocate the new color buffer */
   if ( !(NCwindow.cbuf = MALLOC(NCcbuf, total_dexels)))
   {
      OUT_OF_MEM_HANDLING
   }

   /* change the active speed */
   NCsim_data.simulation_speed = newspeed;

   if (!NCshading.ifb)
   {
      /* global values */
      if (NCtoolpath_data.five_axis)
      {
         ncv_sx_ds = NCwindow.sx_dits - 2*NCsim_data.simulation_speed;
         ncv_sy_ds = NCwindow.sy_dits - 2*NCsim_data.simulation_speed;
      }
      else
      {
         ncv_sx_ds = NCwindow.sx_dits - NCsim_data.simulation_speed;
         ncv_sy_ds = NCwindow.sy_dits - NCsim_data.simulation_speed;
      }

      /* reset previous start painting point            */
      ncv_prev_xlo = ncv_prev_ylo = 0;
   }
}

/*-----NCdisplay_sim_tool-----------------------------------------------------*/

void NCdisplay_sim_tool(void)


/*
 * ABSTRACT:  display simulated tool at current position
 *
 * HISTORY:   09/16/88   Created.         K. M. Jehng
 *
 */
{
   /* initialize the five axis location offset variables */
   if (NCtoolpath_data.five_axis)
   {
      NCsim_data.x_loc = NCsim_data.y_loc = 0;
   }

   /* subtract tool from block in entire tool paint region */
   NCsubtract_sim_tool( ncv_zero,
                        ncv_zero,
                        NCwindow.sx_dits,
                        NCwindow.sy_dits,
                        ROUND2( ((ncv_old_loc[2] - ncv_z_offset) *
                                 NCwindow.z_scale) ) );

   /* paint the cbuf to the screen */
   NCpaint_sim_tool(&ncv_zero, 
                    &ncv_zero,
                    &NCwindow.sx_dits,
                    &NCwindow.sy_dits);
}


/*-----sign-------------------------------------------------------------------*/

static IGRint sign( IGRint x )

{
   if (x>0)
   {
      return (1);
   }
   else if (x<0)
   {
      return (-1);
   }
   else
   {
      return (0);
   }
}


/*-----bresenham--------------------------------------------------------------*/

static void bresenham( IGRint      x1,
                       IGRint      y1,
                       IGRint      z1,
                       IGRint      x2,
                       IGRint      y2,
                       IGRint      z2,
                       IGRint      *lastx,
                       IGRint      *lasty,
                       IGRint      *lastz,
                       IGRboolean  do_endpt )

/*
 * ABSTRACT:   This routine is a Bresenham algorithm modified to sample the
 *      given line segment (toolpath) at non-unit (NCsim_data.simulation_speed)
 *      intervals.  It also takes into account any accumulated error
 *      and returns the coordinates of the last point sampled.
 *
 * PARAMETERS:
 *      IGRint x1, y1, z1, x2, y2, z2;  (I) the endpoints of the line
 *                                            (z's NOT scaled)
 *      IGRint *lastx, *lasty, *lastz;  (O) the coordinates of the last point
 *                                            sampled
 *      IGRboolean do_endpt;            (I) the flag to sample the endpoint.
 *                                           If TRUE, the  endpoint (x2, y2) is
 *                                           sampled automatically
 *
 * HISTORY:   11/11/88  Created.                       C. M. Jablonski
 *            11/23/88  Allow Z to be major axis.      C. M. Jablonski
 *
 *      Changed major -> major_r  minor -> minor_r for
 *      compilation on Sun Workstation
 */

{
   IGRint      x;
   IGRint      y;
   IGRint      z;

   IGRint      sx;
   IGRint      sy;
   IGRint      sz;

   IGRint      dx;
   IGRint      dy;
   IGRint      dz;

   IGRint      temp;
   IGRint      i;

   IGRint      xlo;
   IGRint      xhi;

   IGRint      ylo;
   IGRint      yhi;

   IGRint      sx_off;
   IGRint      sy_off;

   IGRint      px_off;
   IGRint      py_off;

   IGRint      sx_dits;
   IGRint      sy_dits;

   IGRint      *major_r;
   IGRint      *minor_r;

   IGRint      s_major;
   IGRint      s_minor;

   IGRint      si_major;
   IGRint      si_minor;

   IGRint      d_major;
   IGRint      d_minor;

   IGRint      d2_major;
   IGRint      d2_minor;

   IGRint      d2i_minor;
   IGRint      e_minor;
   IGRint      *minor2;
   IGRint      s_minor2;
   IGRint      si_minor2;
   IGRint      d_minor2;
   IGRint      d2_minor2;
   IGRint      d2i_minor2;
   IGRint      e_minor2;

   IGRboolean  set_paint_range = FALSE;


   START_NC_TIMING(NCtd_BRESENHAM)

   /* initialize variables */
   *lastx = x = x1;
   *lasty = y = y1;
   *lastz = z = z1;

   /* set the x variables */
   dx = x2 - x1;
   sx = sign(dx);
   dx *= sx;

   /* set the y variables */
   dy = y2 - y1;
   sy = sign(dy);
   dy *= sy;

   /* set the z variables */
   dz = z2 - z1;
   sz = sign(dz);
   dz *= sz;

   if ( ((dx > 0) &&
                (dx >= (NCsim_data.simulation_speed - ROUND2(ncv_acc_err)))) ||
        ((dy > 0) &&
                (dy >= (NCsim_data.simulation_speed - ROUND2(ncv_acc_err)))) ||
        ((dz > 0) &&
                (dz >= (NCsim_data.simulation_speed - ROUND2(ncv_acc_err)))) )
   {
      /* determine the subtract/paint range from the toolpath direction */
      if (NCshading.ifb)
      {
         /* if ifb engine, we use putpixelblock which needs full speed region */
         xlo = ylo = 0;
         xhi = NCwindow.sx_dits;
         yhi = NCwindow.sy_dits;
      }
      else
      {
         NCtoolpath_dir(dx, dy, sx, sy, &xlo, &ylo, &xhi, &yhi);
         NCwindow.px_off += (xlo - ncv_prev_xlo);
         NCwindow.py_off += (ylo - ncv_prev_ylo);
         ncv_prev_xlo = xlo;
         ncv_prev_ylo = ylo;
         sx_dits = xhi - xlo;
         sy_dits = yhi - ylo;
      }
      set_paint_range = TRUE;

      /* save the original offsets */
      sx_off = NCwindow.sx_off;
      sy_off = NCwindow.sy_off;
      px_off = NCwindow.px_off;
      py_off = NCwindow.py_off;

      /* determine the major axis */
      if (dy > dx)
      {
         /* X is a minor axis */
         minor_r = &x;
         s_minor = sx;
         si_minor = s_minor * NCsim_data.simulation_speed;
         d_minor = dx;
         d2_minor = d_minor * 2;
         d2i_minor = d2_minor * NCsim_data.simulation_speed;

         if (dy > dz)
         {
            /* Y is the major axis */
            major_r = &y;
            s_major = sy;
            si_major = s_major * NCsim_data.simulation_speed;
            d_major = dy;
            d2_major = d_major * 2;

            /* Z is a minor axis */
            minor2 = &z;
            s_minor2 = sz;
            si_minor2 = s_minor2 * NCsim_data.simulation_speed;
            d_minor2 = dz;
            d2_minor2 = d_minor2 * 2;
            d2i_minor2 = d2_minor2 * NCsim_data.simulation_speed;
         }
         else
         {
            /* Z is the major axis */
            major_r = &z;
            s_major = sz;
            si_major = s_major * NCsim_data.simulation_speed;
            d_major = dz;
            d2_major = d_major * 2;

            /* Y is a minor axis */
            minor2 = &y;
            s_minor2 = sy;
            si_minor2 = s_minor2 * NCsim_data.simulation_speed;
            d_minor2 = dy;
            d2_minor2 = d_minor2 * 2;
            d2i_minor2 = d2_minor2 * NCsim_data.simulation_speed;
         }
      }
      else
      {
         /* Y is a minor axis */
         minor_r = &y;
         s_minor = sy;
         si_minor = s_minor * NCsim_data.simulation_speed;
         d_minor = dy;
         d2_minor = d_minor * 2;
         d2i_minor = d2_minor * NCsim_data.simulation_speed;

         if (dx > dz)
         {
            /* X is the major axis */
            major_r = &x;
            s_major = sx;
            si_major = s_major * NCsim_data.simulation_speed;
            d_major = dx;
            d2_major = d_major * 2;

            /* Z is a minor axis */
            minor2 = &z;
            s_minor2 = sz;
            si_minor2 = s_minor2 * NCsim_data.simulation_speed;
            d_minor2 = dz;
            d2_minor2 = d_minor2 * 2;
            d2i_minor2 = d2_minor2 * NCsim_data.simulation_speed;
         }
         else
         {
            /* Z is the major axis */
            major_r = &z;
            s_major = sz;
            si_major = s_major * NCsim_data.simulation_speed;
            d_major = dz;
            d2_major = d_major * 2;

            /* X is a minor axis */
            minor2 = &x;
            s_minor2 = sx;
            si_minor2 = s_minor2 * NCsim_data.simulation_speed;
            d_minor2 = dx;
            d2_minor2 = d_minor2 * 2;
            d2i_minor2 = d2_minor2 * NCsim_data.simulation_speed;
         }
      }

      /*
       * Directly calculate the first point, using the accumulated error.
       */

      /* initialize the error terms */
      e_minor = (d2_minor *
                 (NCsim_data.simulation_speed - ROUND2(ncv_acc_err))) -
                 d_major;
      e_minor2 = (d2_minor2 *
                 (NCsim_data.simulation_speed - ROUND2(ncv_acc_err))) -
                  d_major;

      /* adjust the minor axes */
      if (e_minor >= 0)
      {
         temp = (e_minor / d2_major) + 1;
         *minor_r += temp * s_minor;
         e_minor -= temp * d2_major;
      }

      if (e_minor2 >= 0)
      {
         temp = (e_minor2 / d2_major) + 1;
         *minor2 += temp * s_minor2;
         e_minor2 -= temp * d2_major;
      }

      /* adjust the major axis */
      *major_r += s_major * (NCsim_data.simulation_speed - ROUND2(ncv_acc_err));

      /* move the simbuf offset, paint region */
      NCwindow.sx_off = sx_off + x - x1;
      NCwindow.sy_off = sy_off + y - y1;
      NCwindow.px_off = px_off + x - x1;
      NCwindow.py_off = py_off + y - y1;

      /* subtract the tool, paint the region.  NOTE: we need to paint the   */
      /* ENTIRE speed region in order to be sure of painting over the last  */
      /* tool on the previous segment.                                      */
      NCsubtract_sim_tool( ncv_zero,
                           ncv_zero,
                           NCwindow.sx_dits,
                           NCwindow.sy_dits,
                           ROUND2(z * NCwindow.z_scale) );
      NCwindow.px_off -= (ncv_prev_xlo);
      NCwindow.py_off -= (ncv_prev_ylo);

      NCpaint_sim_tool( &ncv_zero,
                        &ncv_zero,
                        &NCwindow.sx_dits,
                        &NCwindow.sy_dits );
      NCwindow.px_off += (ncv_prev_xlo);
      NCwindow.py_off += (ncv_prev_ylo);

      /* update the count and error for the main loop */
      i = ((2 * NCsim_data.simulation_speed) - ROUND2(ncv_acc_err)) - 1;

      e_minor += d2_minor * NCsim_data.simulation_speed;
      e_minor2 += d2_minor2 * NCsim_data.simulation_speed;

      /*
       * Main Loop: we are now taking uniform steps of size 
       * (NCsim_data.simulation_speed).
       */

      while (i < d_major)
      {
         /* if necessary, update the minor axes */
         if (e_minor >= 0)
         {
            temp = (e_minor / d2_major) + 1;
            *minor_r += temp * s_minor;
            e_minor -= temp * d2_major;
         }

         if (e_minor2 >= 0)
         {
            temp = (e_minor2 / d2_major) + 1;
            *minor2 += temp * s_minor2;
            e_minor2 -= temp * d2_major;
         }

         /* update the major axis */
         *major_r += si_major;

         /* move the simbuf offset, paint region */
         NCwindow.sx_off = sx_off + x - x1;
         NCwindow.sy_off = sy_off + y - y1;
         NCwindow.px_off = px_off + x - x1;
         NCwindow.py_off = py_off + y - y1;

         /* subtract the tool, paint the region */
         NCsubtract_sim_tool ( xlo, ylo, xhi, yhi, ROUND2(z * NCwindow.z_scale) );
         NCpaint_sim_tool ( &xlo, &ylo, &sx_dits, &sy_dits );

         /* update the count and errors */
         i += NCsim_data.simulation_speed;
         e_minor += d2i_minor;
         e_minor2 += d2i_minor2;
      }

      /* set the return parms */
      *lastx = x;
      *lasty = y;
      *lastz = z;

      /* reset the accumulated error */
      ncv_acc_err = 0.0;

      /* move the simbuf offset, paint region to the end of the segment */
      NCwindow.sx_off = sx_off + x2 - x1;
      NCwindow.sy_off = sy_off + y2 - y1;
      NCwindow.px_off = px_off + x2 - x1;
      NCwindow.py_off = py_off + y2 - y1;
   }
   else
   {
      /* move the simbuf offset, paint region to the end of the segment */
      NCwindow.sx_off += x2 - x1;
      NCwindow.sy_off += y2 - y1;
      NCwindow.px_off += x2 - x1;
      NCwindow.py_off += y2 - y1;
   }

   /* if necessary, sample the last point */
   if (do_endpt)
   {
      if (!set_paint_range)
      {
         /* determine the subtract/paint range from the toolpath direction */
         if (NCshading.ifb)
         {
            /* if ifb engine, we use putpixelblock which needs full speed  */
            /* region                                                      */
            xlo = ylo = 0;
            xhi = NCwindow.sx_dits;
            yhi = NCwindow.sy_dits;
         }
         else
         {
            NCtoolpath_dir(dx, dy, sx, sy, &xlo, &ylo, &xhi, &yhi);
            NCwindow.px_off += (xlo - ncv_prev_xlo);
            NCwindow.py_off += (ylo - ncv_prev_ylo);
            ncv_prev_xlo = xlo;
            ncv_prev_ylo = ylo;
            sx_dits = xhi - xlo;
            sy_dits = yhi - ylo;
         }
      }

      /* subtract the tool, paint the region */
      NCsubtract_sim_tool ( xlo, ylo, xhi, yhi, ROUND2(z2 * NCwindow.z_scale) );
      NCpaint_sim_tool ( &xlo, &ylo, &sx_dits, &sy_dits );

      /* set the return parms */
      *lastx = x2;
      *lasty = y2;
      *lastz = z2;

      /* reset the accumulated error */
      ncv_acc_err = 0.0;
   }

   STOP_NC_TIMING(NCtd_BRESENHAM)
}


/*-----bresenham five axis-------------------------------------------------------*/

static void bresenham_five_axis( IGRdouble   i1,
                                 IGRdouble   j1,
                                 IGRdouble   k1,
                                 IGRdouble   i2,
                                 IGRdouble   j2,
                                 IGRdouble   k2,
                                 IGRint      x1,
                                 IGRint      y1,
                                 IGRint      z1,
                                 IGRint      x2,
                                 IGRint      y2,
                                 IGRint      z2,
                                 IGRint      xt1,
                                 IGRint      yt1,
                                 IGRint      zt1,
                                 IGRint      xt2,
                                 IGRint      yt2,
                                 IGRint      zt2,
                                 IGRint      *lastx,
                                 IGRint      *lasty,
                                 IGRint      *lastz,
                                 IGRint      *lastxt,
                                 IGRint      *lastyt,
                                 IGRint      *lastzt,
                                 IGRboolean  do_endpt )

/*
 * ABSTRACT:   This routine is a Bresenham algorithm modified to sample the
 *             given line segment (toolpath) at non-unit (NCsim_data.simulat-
 *             ion_speed) intervals.  It also takes into account any
 *             accumulated error and returns the coordinates of the last
 *             point sampled. This version handles five-axis tool motion.
 *
 * HISTORY:    11/21/88 Created - three axis.
 *                      - C.  M.  Jablonski
 *             10/2/89  Extended to treat five-axis tool motion
 *                      - Mitch Giesy
 *
 * PARAMETERS: IGRdouble i1, i2, j1, j2, k1, k2;  (I) Orientation vectors at
 *                                                    sub-toolpath endpoints
 *             IGRint  x1, y1, z1, x2, y2, z2;    (I) The endpoints of the line
 *                                                    (z's NOT scaled)
 *             IGRint  xt1, yt1, zt1, xt2, yt2, zt2;  Endpoints of path along
 *                                                    top of tool
 *             IGRint  *lastx, *lasty, *lastz;      (O) The coordinates of the
 *                                                    last point sampled
 *             IGRint *lastxt, *lastyt, *lastzt;  (O) The coordinates of the
 *                                                    last top point
 *             IGRboolean  do_endpt;              (I) The flag to sample the
 *                                                    endpoint.  If TRUE, the
 *                                                    endpoint (x2, y2) is
 *                                                    sampled automatically
 */

{
   IGRint      x;
   IGRint      y;
   IGRint      z;
   IGRint      sx;
   IGRint      sy;
   IGRint      sz;
   IGRint      dx;
   IGRint      dy;
   IGRint      dz;

   IGRint      xt;
   IGRint      yt;
   IGRint      zt;
   IGRint      sxt;
   IGRint      syt;
   IGRint      szt;
   IGRint      dxt;
   IGRint      dyt;
   IGRint      dzt;

   IGRint      *tempxyz;
   IGRint      *tempd;
   IGRint      *temps;

   IGRint      temp;
   IGRint      i;

   IGRint      xlo;
   IGRint      xhi;

   IGRint      ylo;
   IGRint      yhi;

   IGRint      sx_off;
   IGRint      sy_off;
   IGRint      px_off;
   IGRint      py_off;

   IGRint      sx_dits;
   IGRint      sy_dits;

   IGRint      *major_r;
   IGRint      s_major;
   IGRint      si_major;
   IGRint      d_major;
   IGRint      d2_major;

   IGRint      *minor_r;
   IGRint      s_minor;
   IGRint      si_minor;
   IGRint      d_minor;
   IGRint      d2_minor;
   IGRint      d2i_minor;
   IGRint      e_minor;

   IGRint      *minor2;
   IGRint      s_minor2;
   IGRint      si_minor2;
   IGRint      d_minor2;
   IGRint      d2_minor2;
   IGRint      d2i_minor2;
   IGRint      e_minor2;

   IGRint      *minor3;
   IGRint      s_minor3;
   IGRint      si_minor3;
   IGRint      d_minor3;
   IGRint      d2_minor3;
   IGRint      d2i_minor3;
   IGRint      e_minor3;

   IGRint      *minor4;
   IGRint      s_minor4;
   IGRint      si_minor4;
   IGRint      d_minor4;
   IGRint      d2_minor4;
   IGRint      d2i_minor4;
   IGRint      e_minor4;

   IGRint      *minor5;
   IGRint      s_minor5;
   IGRint      si_minor5;
   IGRint      d_minor5;
   IGRint      d2_minor5;
   IGRint      d2i_minor5;
   IGRint      e_minor5;

   IGRint      temp_sim_speed;
   IGRint      ncv_acc_error;

   IGRboolean  set_paint_range = FALSE;

   IGRdouble   di;
   IGRdouble   dj;
   IGRdouble   dk;

   IGRvector   orient_vector;
   IGRvector   vi;
   IGRvector   vj;
   IGRvector   vk;

   IGRdouble   tool_rot[3][3];

   IGRdouble   old_z_off;
   IGRdouble   z_diff = 0;


   START_NC_TIMING(NCtd_BRESENHAM)

   /* initialize variables */
   *lastx = x = x1;
   *lasty = y = y1;
   *lastz = z = z1;

   /* set the x variables */
   dx = x2 - x1;
   sx = sign(dx);
   dx *= sx;

   /* set the y variables */
   dy = y2 - y1;
   sy = sign(dy);
   dy *= sy;

   /* set the z variables */
   dz = z2 - z1;
   sz = sign(dz);
   dz *= sz;

   /* Set up the changes in i, j, k. Also calculate the changes in x, y and z
      at the top of the tool.  */
   di = (i2 - i1);
   dj = (j2 - j1);
   dk = (k2 - k1);

   /* need some initial values for Xt, Yt and Zt */
   *lastxt = xt = xt1;
   *lastyt = yt = yt1;
   *lastzt = zt = zt1;

   dxt = (xt2 - xt1);
   sxt = sign(dxt);
   dxt *= sxt;

   dyt = (yt2 - yt1);
   syt = sign(dyt);
   dyt *= syt;

   dzt = (zt2 - zt1);
   szt = sign(dzt);
   dzt *= szt;

#if DEBUG
   fprintf(stderr, "x, y, z: %d, %d, %d\n", x, y, z);
   fprintf(stderr, "dx, dy, dz: %d, %d, %d\n", dx*sx, dy*sy, dz*sz);
   fprintf(stderr, "xt, yt, zt: %d, %d, %d\n", xt, yt, zt);
   fprintf(stderr, "dxt, dyt, dzt: %d, %d, %d\n", dxt*sxt, dyt*syt, dzt*szt);
#endif

   ncv_acc_error = ROUND2(ncv_acc_err);

   if ( ((dx > 0) && (dx >= (NCsim_data.simulation_speed - ncv_acc_error))) ||
        ((dy > 0) && (dy >= (NCsim_data.simulation_speed - ncv_acc_error))) ||
        ((dz > 0) && (dz >= (NCsim_data.simulation_speed - ncv_acc_error))) ||
        ((dxt > 0) && (dxt >= (NCsim_data.simulation_speed - ncv_acc_error))) ||
        ((dyt > 0) && (dyt >= (NCsim_data.simulation_speed - ncv_acc_error))) ||
        ((dzt > 0) && (dzt >= (NCsim_data.simulation_speed - ncv_acc_error))) )
   {
      set_paint_range = TRUE;

      /* save the original offsets */
      sx_off = NCwindow.sx_off;
      sy_off = NCwindow.sy_off;
      px_off = NCwindow.px_off;
      py_off = NCwindow.py_off;
      NCsim_data.x_loc = 0; /* initialize global x and y offsets from simbuff*/
      NCsim_data.y_loc = 0;

      /****************************
        determine the major axis
      *****************************/
      if (dy > dx)
      {
         /* X is a minor axis */
         minor_r = &x;
         s_minor = sx;
         d_minor = dx;
         tempxyz = &y;
         temps = &sy;
         tempd = &dy;
      }
      else
      {
         /* Y is a minor axis */
         minor_r = &y;
         s_minor = sy;
         d_minor = dy;
         tempxyz = &x;
         temps = &sx;
         tempd = &dx;
      }

      if (*tempd > dz)
      {
         /* Z is a minor axis */
         minor2 = &z;
         s_minor2 = sz;
         d_minor2 = dz;
      }
      else
      {
         minor2 = tempxyz;
         s_minor2 = *temps;
         d_minor2 = *tempd;
         tempxyz = &z;
         temps = &sz;
         tempd = &dz;
      }

      if (*tempd > dxt)
      {
         /* Xt is a minor axis */
         minor3 = &xt;
         s_minor3 = sxt;
         d_minor3 = dxt;
      }
      else
      {
         minor3 = tempxyz;
         s_minor3 = *temps;
         d_minor3 = *tempd;
         tempxyz = &xt;
         temps = &sxt;
         tempd = &dxt;
      }

      if (*tempd > dyt)
      {
         /* Yt is a minor axis */
         minor4 = &yt;
         s_minor4 = syt;
         d_minor4 = dyt;
      }
      else
      {
         minor4 = tempxyz;
         s_minor4 = *temps;
         d_minor4 = *tempd;
         tempxyz = &yt;
         temps = &syt;
         tempd = &dyt;
      }

      if (*tempd > dzt)
      {
         /* zt is a minor axis */
         minor5 = &zt;
         s_minor5 = szt;
         d_minor5 = dzt;
         /* major axis has been found */
         major_r = tempxyz;
         s_major = *temps;
         d_major = *tempd;
      }
      else
      {
         /* Zt is the major axis */
         major_r = &zt;
         s_major = szt;
         d_major = dzt;
         minor5 = tempxyz;
         s_minor5 = *temps;
         d_minor5 = *tempd;
      }

      /* adjust simulation speed so that any shrinkage/growth in the size of
       * the tool region does not cause the tool to move at a rate of
       * (d_major/d_minor) simulation speed.
       */

      /* Leave the simulation speed alone for now. Adjusting the speed correctly
       * would involve calculations at each tool step, to determine shrinkage
       * that needs counteracted. The algorithm below is not applicable in all
       * cases.
       */
/*
      speed_xt = (double) dxt * NCsim_data.simulation_speed / (double) d_major;
      speed_yt = (double) dyt * NCsim_data.simulation_speed / (double) d_major;
      speed_zt = (double) dzt * NCsim_data.simulation_speed / (double) d_major;
      speed_x = (double) dx * NCsim_data.simulation_speed / (double) d_major;
      speed_y = (double) dy * NCsim_data.simulation_speed / (double) d_major;
      speed_z = (double) dz * NCsim_data.simulation_speed / (double) d_major;

      if (sxt == sx)
      {
         speed_x = speed_xt + speed_xt - speed_x;
      }
      else
      {
         speed_x = speed_xt + speed_xt + speed_x;
      }

      if (syt == sy)
      {
         speed_y = speed_yt + speed_yt - speed_y;
      }
      else
      {
         speed_y = speed_yt + speed_yt + speed_y;
      }

      if (szt == sz)
      {
         speed_z = speed_zt + speed_zt - speed_z;
      }
      else
      {
         speed_z = speed_zt + speed_zt + speed_z;
      }
*/

      temp_sim_speed = NCsim_data.simulation_speed;

/*
      if ((speed_x > NCsim_data.simulation_speed) ||
          (speed_y > NCsim_data.simulation_speed) ||
          (speed_z > NCsim_data.simulation_speed))
      {
         if (speed_x >= speed_y)
         {
            if (speed_x > speed_z)
            {
               NCsim_data.simulation_speed -=
                         ROUND2((speed_x - NCsim_data.simulation_speed) / 2.0);
            }
            else
            {
               NCsim_data.simulation_speed -=
                         ROUND2((speed_z - NCsim_data.simulation_speed) / 2.0);
            }
         }
         else
         {
            if (speed_y > speed_z)
            {
               NCsim_data.simulation_speed -=
                         ROUND2((speed_y - NCsim_data.simulation_speed) / 2.0);
            }
            else
            {
               NCsim_data.simulation_speed -=
                         ROUND2((speed_z - NCsim_data.simulation_speed) / 2.0);
            }
         }
      }
*/


/*
      if (NCsim_data.simulation_speed == 0)
      {
          NCsim_data.simulation_speed = 1;
      }
*/

      /* set the bresenham related quantities for the minor axes */
      si_minor   = s_minor * NCsim_data.simulation_speed;
      d2_minor   = d_minor * 2;
      d2i_minor  = d2_minor * NCsim_data.simulation_speed;
      si_minor2  = s_minor2 * NCsim_data.simulation_speed;
      d2_minor2  = d_minor2 * 2;
      d2i_minor2 = d2_minor2 * NCsim_data.simulation_speed;
      si_minor3  = s_minor3 * NCsim_data.simulation_speed;
      d2_minor3  = d_minor3 * 2;
      d2i_minor3 = d2_minor3 * NCsim_data.simulation_speed;
      si_minor4  = s_minor4 * NCsim_data.simulation_speed;
      d2_minor4  = d_minor4 * 2;
      d2i_minor4 = d2_minor4 * NCsim_data.simulation_speed;
      si_minor5  = s_minor5 * NCsim_data.simulation_speed;
      d2_minor5  = d_minor5 * 2;
      d2i_minor5 = d2_minor5 * NCsim_data.simulation_speed;
      si_major   = s_major * NCsim_data.simulation_speed;
      d2_major   = d_major * 2;

      /* determine the subtract/paint range from the toolpath direction */
      if (NCshading.ifb)
      {
         /* if ifb engine, we use putpixelblock which needs full speed region */
         xlo = ylo = 0;
         xhi = NCwindow.sx_dits;
         yhi = NCwindow.sy_dits;
      }
      else
      {
         NCtoolpath_fxdir(dx,
                          dy,
                          dxt,
                          dyt,
                          sx,
                          sy,
                          sxt,
                          syt,
                          &xlo,
                          &ylo,
                          &xhi,
                          &yhi);
/*
         NCwindow.px_off += (xlo - ncv_prev_xlo);
         NCwindow.py_off += (ylo - ncv_prev_ylo);
*/
         ncv_prev_xlo = xlo;
         ncv_prev_ylo = ylo;
         sx_dits = xhi - xlo;
         sy_dits = yhi - ylo;
      }

      /*
       * Directly calculate the first point, using the accumulated error.
       */

      /* initialize the error terms */
      e_minor = (d2_minor * (NCsim_data.simulation_speed - ncv_acc_error)) - 
                 d_major;
      e_minor2 = (d2_minor2 * (NCsim_data.simulation_speed - ncv_acc_error)) -
                 d_major;
      e_minor3 = (d2_minor3 * (NCsim_data.simulation_speed - ncv_acc_error)) -
                 d_major;
      e_minor4 = (d2_minor4 * (NCsim_data.simulation_speed - ncv_acc_error)) -
                 d_major;
      e_minor5 = (d2_minor5 * (NCsim_data.simulation_speed - ncv_acc_error)) -
                 d_major;

      /* adjust the minor axes */
      if (e_minor >= 0)
      {
         temp = (e_minor / d2_major) + 1;
         *minor_r += temp * s_minor;
         e_minor -= temp * d2_major;
      }

      if (e_minor2 >= 0)
      {
         temp = (e_minor2 / d2_major) + 1;
         *minor2 += temp * s_minor2;
         e_minor2 -= temp * d2_major;
      }

      if (e_minor3 >= 0)
      {
         temp = (e_minor3 / d2_major) + 1;
         *minor3 += temp * s_minor3;
         e_minor3 -= temp * d2_major;
      }

      if (e_minor4 >= 0)
      {
         temp = (e_minor4 / d2_major) + 1;
         *minor4 += temp * s_minor4;
         e_minor4 -= temp * d2_major;
      }

      if (e_minor5 >= 0)
      {
         temp = (e_minor5 / d2_major) + 1;
         *minor5 += temp * s_minor5;
         e_minor5 -= temp * d2_major;
      }

      /* adjust the major axis */
      *major_r += s_major * (NCsim_data.simulation_speed - ncv_acc_error);

      /* adjust the orientation vector */
      orient_vector[0] = i1 + di * 
             (((double) NCsim_data.simulation_speed - ncv_acc_error) / d_major);
      orient_vector[1] = j1 + dj *
             (((double) NCsim_data.simulation_speed - ncv_acc_error) / d_major);
      orient_vector[2] = k1 + dk *
             (((double) NCsim_data.simulation_speed - ncv_acc_error) / d_major);

      /**************************************************************
       * for 5-axis simulation: tile and dexelize the tool at the new
       * location and orientation
       **************************************************************/

      CreateCoordSystem( orient_vector, vi, vj, vk);

      /* transpose of rotation matrix */
      tool_rot[0][0] = vi[0];
      tool_rot[0][1] = vi[1];
      tool_rot[0][2] = vi[2];

      tool_rot[1][0] = vj[0];
      tool_rot[1][1] = vj[1];
      tool_rot[1][2] = vj[2];

      tool_rot[2][0] = vk[0];
      tool_rot[2][1] = vk[1];
      tool_rot[2][2] = vk[2];

      NCchange_orientation (tool_rot);

      NCinit_tool_vars();

      NCsim_data.x_loc = x - x1;
      NCsim_data.y_loc = y - y1;

      /* need to save the difference for subtraction.  - CMJ 06/01/90 */
      old_z_off = ncv_z_offset;
      NCupdate_sim_buffer(FALSE);
      z_diff += ncv_z_offset - old_z_off;

      /* move the simbuf offset, paint region */
      NCwindow.sx_off += NCsim_data.x_loc;
      NCwindow.sy_off += NCsim_data.y_loc;
      NCwindow.px_off += NCsim_data.x_loc;
      NCwindow.py_off += NCsim_data.y_loc;

      /* subtract the tool, paint the region.  NOTE: we need to paint the  */
      /* ENTIRE speed region in order to be sure of painting over the last */
      /* tool on the previous segment.                                     */

      NCsubtract_sim_tool( ncv_zero,
                           ncv_zero,
                           NCwindow.sx_dits,
                           NCwindow.sy_dits,
                           ROUND2((z - z_diff) * NCwindow.z_scale) );
/*
      NCwindow.px_off -= (ncv_prev_xlo);
      NCwindow.py_off -= (ncv_prev_ylo);
*/

      NCpaint_sim_tool( &ncv_zero,
                        &ncv_zero,
                        &NCwindow.sx_dits,
                        &NCwindow.sy_dits );

/*
      NCwindow.px_off += (ncv_prev_xlo);
      NCwindow.py_off += (ncv_prev_ylo);
*/

      /* update the count and error for the main loop */
      i = ((2 * NCsim_data.simulation_speed) - ncv_acc_error) - 1;

      e_minor  += d2_minor * NCsim_data.simulation_speed;
      e_minor2 += d2_minor2 * NCsim_data.simulation_speed;
      e_minor3 += d2_minor3 * NCsim_data.simulation_speed;
      e_minor4 += d2_minor4 * NCsim_data.simulation_speed;
      e_minor5 += d2_minor5 * NCsim_data.simulation_speed;

      /*
       * Main Loop: we are now taking uniform steps of size
       * (NCsim_data.simulation_speed).
       */

      di = di * (double) NCsim_data.simulation_speed / d_major;
      dj = dj * (double) NCsim_data.simulation_speed / d_major;
      dk = dk * (double) NCsim_data.simulation_speed / d_major;

      while (i < d_major)
      {
         /* if necessary, update the minor axes */
         if (e_minor >= 0)
         {
            temp = (e_minor / d2_major) + 1;
            *minor_r += temp * s_minor;
            e_minor -= temp * d2_major;
         }

         if (e_minor2 >= 0)
         {
            temp = (e_minor2 / d2_major) + 1;
            *minor2 += temp * s_minor2;
            e_minor2 -= temp * d2_major;
         }

         if (e_minor3 >= 0)
         {
            temp = (e_minor3 / d2_major) + 1;
            *minor3 += temp * s_minor3;
            e_minor3 -= temp * d2_major;
         }

         if (e_minor4 >= 0)
         {
            temp = (e_minor4 / d2_major) + 1;
            *minor4 += temp * s_minor4;
            e_minor4 -= temp * d2_major;
         }

         if (e_minor5 >= 0)
         {
            temp = (e_minor5 / d2_major) + 1;
            *minor5 += temp * s_minor5;
            e_minor5 -= temp * d2_major;
         }

         /* update the major axis */
         *major_r += si_major;

         /* adjust the orientation vector */
         orient_vector[0] += di;
         orient_vector[1] += dj;
         orient_vector[2] += dk;

         /**************************************************************
          * for 5-axis simulation: tile and dexelize the tool at the new
          * location and orientation
          **************************************************************/

         CreateCoordSystem( orient_vector, vi, vj, vk);

         tool_rot[0][0] = vi[0]; /* transpose of rotation matrix */
         tool_rot[0][1] = vi[1];
         tool_rot[0][2] = vi[2];

         tool_rot[1][0] = vj[0];
         tool_rot[1][1] = vj[1];
         tool_rot[1][2] = vj[2];

         tool_rot[2][0] = vk[0];
         tool_rot[2][1] = vk[1];
         tool_rot[2][2] = vk[2];

         NCchange_orientation (tool_rot);

         NCinit_tool_vars();

         NCsim_data.x_loc = x - x1;
         NCsim_data.y_loc = y - y1;

         /* need to save the difference for subtraction.  - CMJ 06/01/90 */
         old_z_off = ncv_z_offset;
         NCupdate_sim_buffer(FALSE);
         z_diff += ncv_z_offset - old_z_off;

         if (NCshading.ifb)
         {
            /* if ifb engine, we use putpixelblock which needs full speed region */
            xlo = ylo = 0;
            xhi = NCwindow.sx_dits;
            yhi = NCwindow.sy_dits;
         }
         else
         {
            NCtoolpath_fxdir(dx,
                             dy,
                             dxt,
                             dyt,
                             sx,
                             sy,
                             sxt,
                             syt,
                             &xlo,
                             &ylo,
                             &xhi,
                             &yhi);
/*
            NCwindow.px_off += (xlo - ncv_prev_xlo);
            NCwindow.py_off += (ylo - ncv_prev_ylo);
*/
            ncv_prev_xlo = xlo;
            ncv_prev_ylo = ylo;
            sx_dits = xhi - xlo;
            sy_dits = yhi - ylo;
         }

#if DEBUG
         fprintf(stderr, "3location x y z: %d %d %d\n",
                          NCtoolpath_data.curr_location[0],
                          NCtoolpath_data.curr_location[1],
                          NCtoolpath_data.curr_location[2]);
         fprintf(stderr, "3NCwindow.sx_off, sy_off, px_off, " );
         fprintf(stderr, "py_off: %d %d %d %d\n",
                          NCwindow.sx_off,
                          NCwindow.sy_off,
                          NCwindow.px_off,
                          NCwindow.py_off);
#endif

         /* move the simbuf offset, paint region */
         NCwindow.sx_off += NCsim_data.x_loc;
         NCwindow.sy_off += NCsim_data.y_loc;
         NCwindow.px_off += NCsim_data.x_loc + xlo;
         NCwindow.py_off += NCsim_data.y_loc + ylo;

         /* subtract the tool, paint the region */
         NCsubtract_sim_tool ( xlo,
                               ylo,
                               xhi,
                               yhi,
                               ROUND2((z - z_diff) * NCwindow.z_scale) );

         NCpaint_sim_tool ( &xlo,
                            &ylo,
                            &sx_dits,
                            &sy_dits );

         /* update the count and errors */
         i += NCsim_data.simulation_speed;
         e_minor += d2i_minor;
         e_minor2 += d2i_minor2;
         e_minor3 += d2i_minor3;
         e_minor4 += d2i_minor4;
         e_minor5 += d2i_minor5;
      }

      /* set the return parms */
      *lastx = x;
      *lasty = y;
      *lastz = z;
      *lastxt = xt;
      *lastyt = yt;
      *lastzt = zt;

      /* reset the simulation speed */
      NCsim_data.simulation_speed = temp_sim_speed;

      /* reset the accumulated error */
      ncv_acc_err = 0.0;

      /* move the simbuf offset, paint region to the end of the segment */
      NCwindow.sx_off += x2 - x1;
      NCwindow.sy_off += y2 - y1;
      NCwindow.px_off += x2 - x1;
      NCwindow.py_off += y2 - y1;
   }
   else
   {
      /* move the simbuf offset, paint region to the end of the segment */
      NCwindow.sx_off += x2 - x1;
      NCwindow.sy_off += y2 - y1;
      NCwindow.px_off += x2 - x1;
      NCwindow.py_off += y2 - y1;
   }

   /* if necessary, sample the last point */
   if (do_endpt)
   {
      if (!set_paint_range)
      {
         /* determine the subtract/paint range from the toolpath direction */
         if (NCshading.ifb)
         {
            /* if ifb engine, we use putpixelblock which needs full speed  */
            /* region                                                      */
            xlo = ylo = 0;
            xhi = NCwindow.sx_dits;
            yhi = NCwindow.sy_dits;
         }
         else
         {
            NCtoolpath_fxdir(dx,
                             dy,
                             dxt,
                             dyt,
                             sx,
                             sy,
                             sxt,
                             syt,
                             &xlo,
                             &ylo,
                             &xhi,
                             &yhi);
/*
            NCwindow.px_off += (xlo - ncv_prev_xlo);
            NCwindow.py_off += (ylo - ncv_prev_ylo);
*/
            ncv_prev_xlo = xlo;
            ncv_prev_ylo = ylo;
            sx_dits = xhi - xlo;
            sy_dits = yhi - ylo;
         }
      }

      /* adjust the orientation vector */
      orient_vector[0] = i2;
      orient_vector[1] = j2;
      orient_vector[2] = k2;

      /**************************************************************
       * for 5-axis simulation: tile and dexelize the tool at the new
       * location and orientation
       **************************************************************/

      CreateCoordSystem( orient_vector,
                         vi,
                         vj,
                         vk);

      /* transpose of rotation matrix */
      tool_rot[0][0] = vi[0];
      tool_rot[0][1] = vi[1];
      tool_rot[0][2] = vi[2];

      tool_rot[1][0] = vj[0];
      tool_rot[1][1] = vj[1];
      tool_rot[1][2] = vj[2];

      tool_rot[2][0] = vk[0];
      tool_rot[2][1] = vk[1];
      tool_rot[2][2] = vk[2];

      NCchange_orientation (tool_rot);

      NCinit_tool_vars();

      NCsim_data.x_loc = x2 - x1;
      NCsim_data.y_loc = y2 - y1;

      /* need to save the difference for subtraction.  - CMJ 06/01/90 */
      old_z_off = ncv_z_offset;
      NCupdate_sim_buffer(FALSE);
      z_diff += ncv_z_offset - old_z_off;

      /* subtract the tool, paint the region */
      NCwindow.sx_off += NCsim_data.x_loc;
      NCwindow.sy_off += NCsim_data.y_loc;
      NCwindow.px_off += NCsim_data.x_loc;
      NCwindow.py_off += NCsim_data.y_loc;
      NCsubtract_sim_tool( ncv_zero,
                           ncv_zero,
                           NCwindow.sx_dits,
                           NCwindow.sy_dits,
                           ROUND2((z - z_diff) * NCwindow.z_scale) );
/*
      NCsubtract_sim_tool ( xlo, ylo, xhi, yhi, ROUND2(z2 * NCwindow.z_scale) );
      NCwindow.px_off -= (ncv_prev_xlo);
      NCwindow.py_off -= (ncv_prev_ylo);
*/

      NCpaint_sim_tool( &ncv_zero,
                        &ncv_zero,
                        &NCwindow.sx_dits,
                        &NCwindow.sy_dits );

/*
      NCpaint_sim_tool ( &xlo, &ylo, &sx_dits, &sy_dits );
*/

      /* set the return parms */
      *lastx = x2;
      *lasty = y2;
      *lastz = z2;
      *lastxt = xt2;
      *lastyt = yt2;
      *lastzt = zt2;

      /* reset the accumulated error */
      ncv_acc_err = 0.0;
      }

   STOP_NC_TIMING(NCtd_BRESENHAM)
}


/*-----NCmove_sim_tool--------------------------------------------------------*/

void NCmove_sim_tool( IGRboolean  paint_at_end,
                      IGRboolean  first_move_tool )

/*
 * ABSTRACT:   move simulated tool from old loc. to new loc.
 *             in VCS (view coord sys)
 *
 * HISTORY:   09/16/88  Created.                                 K. M. Jehng
 *            11/11/88  Changed to Bresenham-based algorithm.    C. M. Jablonski
 *            9/15/89   Added support for five-axis tool motion  M. R. Giesy
 *
 */
{
   IGRint     x1;
   IGRint     y1;
   IGRint     z1;

   IGRint     x2;
   IGRint     y2;
   IGRint     z2;

   IGRint     fx;
   IGRint     fy;
   IGRint     fz;

   IGRint     fxt;
   IGRint     fyt;
   IGRint     fzt;

   IGRint     xt1;
   IGRint     yt1;
   IGRint     zt1;

   IGRint     xt2=0;
   IGRint     yt2=0;
   IGRint     zt2=0;

   IGRdouble  aew;
   IGRdouble  aex;
   IGRdouble  aey;
   IGRdouble  aez;

   IGRdouble  aei;
   IGRdouble  aej;
   IGRdouble  aek;

   IGRdouble  new_loc[3];

   IGRdouble  t_orienta[3];
   IGRdouble  t_orientb[3];
   IGRdouble  top1[3];
   IGRdouble  top2[3];

   IGRdouble  len;
   IGRdouble  original_z_offset;

   START_NC_TIMING(NCtd_MOVE_TOOL)

   /* move buffer to the new location in WCS. */
   new_loc[0] = NCtoolpath_data.next_location[0];
   new_loc[1] = NCtoolpath_data.next_location[1];
   new_loc[2] = NCtoolpath_data.next_location[2];

   /* transform the new location from WCS to VCS */
   transform_points( FALSE, 1, new_loc, 0 );

   /* set the endpoints of the sub-toolpath */
   x1 = ROUND2( ncv_old_loc[0] );
   y1 = ROUND2( ncv_old_loc[1] );
   z1 = ROUND2( (ncv_old_loc[2] - ncv_z_offset) );
   x2 = ROUND2( new_loc[0] );
   y2 = ROUND2( new_loc[1] );
   z2 = ROUND2( (new_loc[2] - ncv_z_offset) );

   /* save the offset; it may change during the bresenham.  - CMJ 05/31/90   */
   original_z_offset = ncv_z_offset;

   if (NCtoolpath_data.five_axis)
   {
/*
      This check is removed so that when we are in a 5-axis move we assume 
      it is the first tool movement.  This solves the problem of having a 
      five axis tool move, a reorientation of the tool by a three axis move,
      and then a 5-axis move.  Previously, the tool jumped back to its previous
      orientaion rather than staying in the new orientaion. - bd  

      if (first_move_tool)
      {
*/
         t_orienta[0] = NCtoolpath_data.curr_orient_vec[0];
         t_orienta[1] = NCtoolpath_data.curr_orient_vec[1];
         t_orienta[2] = NCtoolpath_data.curr_orient_vec[2];

         len = sqrt(t_orienta[0]*t_orienta[0] +
                    t_orienta[1]*t_orienta[1] +
                    t_orienta[2]*t_orienta[2]);

         t_orienta[0] = t_orienta[0] / len;
         t_orienta[1] = t_orienta[1] / len;
         t_orienta[2] = t_orienta[2] / len;

         top1[0] = t_orienta[0] * NCtool_data.height;
         top1[1] = t_orienta[1] * NCtool_data.height;
         top1[2] = t_orienta[2] * NCtool_data.height;

         transform_points( FALSE, 1, top1, 0);

         xt1 = ROUND2(top1[0]);
         yt1 = ROUND2(top1[1]);
         zt1 = ROUND2(top1[2]);

/*
      See above for explanation as to why commented out.  Remove when verified
      that fix does not break anything important.

         first_time = 0;
      }
      else
      {
         first_time = 1;

         t_orienta[0] = ncv_old_orient[0];
         t_orienta[1] = ncv_old_orient[1];
         t_orienta[2] = ncv_old_orient[2];

         xt1 = ncv_old_toploc[0];
         yt1 = ncv_old_toploc[1];
         zt1 = ncv_old_toploc[2];
      }
*/
      t_orientb[0] = NCtoolpath_data.next_orient_vec[0];
      t_orientb[1] = NCtoolpath_data.next_orient_vec[1];
      t_orientb[2] = NCtoolpath_data.next_orient_vec[2];

      /* normalize the two orientation vectors */
      len = sqrt(t_orientb[0]*t_orientb[0] +
                 t_orientb[1]*t_orientb[1] +
                 t_orientb[2]*t_orientb[2]);

      t_orientb[0] = t_orientb[0] / len;
      t_orientb[1] = t_orientb[1] / len;
      t_orientb[2] = t_orientb[2] / len;

      /* set the endpoints of the path formed by the motion of the top of  */
      /* the tool                                                          */
      top2[0] = t_orientb[0] * NCtool_data.height;
      top2[1] = t_orientb[1] * NCtool_data.height;
      top2[2] = t_orientb[2] * NCtool_data.height;

      transform_points( FALSE, 1, top2, 0);

      xt2 = ROUND2(top2[0]);
      yt2 = ROUND2(top2[1]);
      zt2 = ROUND2(top2[2]);

      /* sample the sub-toolpath */
      bresenham_five_axis (t_orienta[0],
                           t_orienta[1],
                           t_orienta[2],
                           t_orientb[0],
                           t_orientb[1],
                           t_orientb[2],
                           x1,
                           y1,
                           z1,
                           x2,
                           y2,
                           z2,
                           xt1,
                           yt1,
                           zt1,
                           xt2,
                           yt2,
                           zt2,
                           &fx,
                           &fy,
                           &fz,
                           &fxt,
                           &fyt,
                           &fzt,
                           paint_at_end );
   }
   else
   {
      bresenham( x1,
                 y1,
                 z1,
                 x2,
                 y2,
                 z2,
                 &fx,
                 &fy,
                 &fz,
                 paint_at_end );
   }

   /* set the accumulated error */
   aex = DABS(new_loc[0] - fx);
   aey = DABS(new_loc[1] - fy);
   aez = DABS((new_loc[2] - original_z_offset) - fz);
   aew = MAX(aex, aey);

   if (NCtoolpath_data.five_axis)
   {
      aei = DABS(top2[0] - fxt);
      aej = DABS(top2[1] - fyt);
      aek = DABS(top2[2] - fzt);
      aew = MAX(aew, aez);
      aew = MAX(aew, aei);
      aew = MAX(aew, aej);
      ncv_acc_err += MAX(aew, aek);
   }
   else
   {
      ncv_acc_err += MAX(aew, aez);
   }

   /* update the location */
   ncv_old_loc[0] = new_loc[0];
   ncv_old_loc[1] = new_loc[1];
   ncv_old_loc[2] = new_loc[2];

   if (NCtoolpath_data.five_axis)
   {
      xt1 = xt2;
      yt1 = yt2;
      zt1 = zt2;

      ncv_old_orient[0] = t_orientb[0];
      ncv_old_orient[1] = t_orientb[1];
      ncv_old_orient[2] = t_orientb[2];

      ncv_old_toploc[0] = xt2;
      ncv_old_toploc[1] = yt2;
      ncv_old_toploc[2] = zt2;
   }

   STOP_NC_TIMING(NCtd_MOVE_TOOL)
}


/*-----NCtoolpath_dir---------------------------------------------------------*/

NCtoolpath_dir( IGRint dx,
                IGRint dy,
                IGRint sx,
                IGRint sy,
                IGRint *x1,
                IGRint *y1,
                IGRint *x2,
                IGRint *y2 )

/*
 * ABSTRACT:   find current toolpath direction, and decide start/end points of
 *             tool speed region.
 *             e.g. if current tool motion direction is along east-south, then
 *
 *           \
 *            \
 *            _\/
 *           (x1, y1)
 *         -----------------
 *         |        |
 *         |  -------------|
 *         |  |      |
 *         |  |       |
 *         |  |      |
 *         |  |      |
 *         -----------------
 *               (x2, y2)
 *
 * PARAMETERS:
 *      IGRint      dx, dy, sx, sy;      (I) distances and signs
 *      IGRint      *x1, *y1, *x2, *y2;  (O) start/end points for tool
 *                                               region
 *
 * HISTORY:   09/26/88  Created.              K. M. Jehng
 *            11/11/88  Changed parameters.   C. M. Jablonski
 *
 */
{
   if (dx)                  /* motion along E-W */
   {
      if (dy)               /* motion along N-S */
      {
         if (sx > 0)
         {
            if (sy > 0)            /* motion along SE */
            {
               *x1 = *y1 = 0;
               *x2 = ncv_sx_ds;
               *y2 = ncv_sy_ds;
            }
            else
            {
               /* motion alone north-east   */
               *x1 = 0;
               *y1 = NCsim_data.simulation_speed;
               *x2 = ncv_sx_ds;
               *y2 = NCwindow.sy_dits;
            }
         }
         else
         {
            if (sy > 0)
            {
               /* motion along south-west   */
               *x1 = NCsim_data.simulation_speed; *y1 = 0;
               *x2 = NCwindow.sx_dits;   *y2 = ncv_sy_ds;
            }
            else
            {
               /* motion along north-west   */
               *x1 = *y1 = NCsim_data.simulation_speed;
               *x2 = NCwindow.sx_dits;   *y2 = NCwindow.sy_dits;
            }
         }
      }
      else
      {
         if (sx > 0)
         {
            /* motion along E */
            *x1 = 0;
            *y1 = NCsim_data.simulation_speed;
            *x2 = ncv_sx_ds;
            *y2 = ncv_sy_ds;
         }
         else
         {
            /* motion along W */
            *x1 = *y1 = NCsim_data.simulation_speed;
            *x2 = NCwindow.sx_dits;
            *y2 = ncv_sy_ds;
         }
      }
   }
   else
   {
      /* motion along S-N      */
      if (sy > 0)
      {
         /* motion along S      */
         *x1 = NCsim_data.simulation_speed;
         *y1 = 0;
         *x2 = ncv_sx_ds;
         *y2 = ncv_sy_ds;
      }
      else
      {
         /* motion along   N      */
         *x1 =  NCsim_data.simulation_speed;
         *y1 = NCsim_data.simulation_speed;
         *x2 = ncv_sx_ds;
         *y2 = NCwindow.sy_dits;
      }
   }

   /* In order to do correct putline (see NCpaint) we need to start the
      subtract/paint region on an even offset. */

   if (NCwindow.horizontal_scan)
   {
      *x1 &= 0xfffffffe;
   }
   else
   {
      *y1 &= 0xfffffffe;
   }

#if DEBUG
   fprintf(stderr, "(x1,y1,x2,y2) = (%d, %d, %d, %d)\n", *x1, *y1, *x2, *y2);
#endif
}

/*-----NCtoolpath_fxdir-------------------------------------------------------*/

NCtoolpath_fxdir( IGRint dx,
                  IGRint dy,
                  IGRint dxt,
                  IGRint dyt,
                  IGRint sx,
                  IGRint sy,
                  IGRint sxt,
                  IGRint syt,
                  IGRint *x1,
                  IGRint *y1,
                  IGRint *x2,
                  IGRint *y2 )
/*
 * ABSTRACT:   Find current toolpath direction, and decide start/end points of
 *             tool speed region.
 *
 * PARAMETERS:  IGRint  dx, dy, sx, sy;         (I) distances and signs
 *              IGRint  dxt, dyt, sxt, syt;     (I) distances and signs
 *                                                  of tool top motion
 *              IGRint  *x1, *y1, *x2, *y2;     (O) start/end points for
 *                                                  tool region
 *
 * HISTORY:   09/26/88  Created three axis version.     K. M. Jehng
 *            09/15/89   Created five axis version.     M. R. Giesy
 *
 */
{
   IGRint   sgnx;
   IGRint   sgny;

   /* determine which end of tool moves the greatest distance */
   if (dx > dxt)
   {
      sgnx = sx;
   }
   else
   {
      sgnx = sxt;
   }

   if (dy > dyt)
   {
      sgny = sy;
   }
   else
   {
      sgny = syt;
   }

   if (dx || dxt)               /* motion along E-W      */
   {
      if (dy || dyt)            /* motion along N-S      */
      {
         if (sgnx > 0)
         {
            if (sgny > 0)            /* motion along south-east   */
            {
               *x1 = *y1 = 0;
               *x2 = ncv_sx_ds;
               *y2 = ncv_sy_ds;
            }
            else             /* motion alone north-east   */
            {
               *x1 = 0;
               *y1 = NCsim_data.simulation_speed << 1;
               *x2 = ncv_sx_ds;
               *y2 = NCwindow.sy_dits;
            }
         }
         else
         {
            if (sgny > 0)         /* motion along south-west   */
            {
               *x1 = NCsim_data.simulation_speed << 1;
               *y1 = 0;
               *x2 = NCwindow.sx_dits;
               *y2 = ncv_sy_ds;
            }
            else             /* motion along north-west   */
            {
               *x1 = NCsim_data.simulation_speed << 1;
               *y1 = NCsim_data.simulation_speed << 1;
               *x2 = NCwindow.sx_dits;
               *y2 = NCwindow.sy_dits;
            }
         }
      }
      else
      {
         if (sgnx > 0)         /* motion along E      */
         {
            *x1 = 0;
            *y1 = NCsim_data.simulation_speed << 1;
            *x2 = ncv_sx_ds;
            *y2 = ncv_sy_ds;
         }
         else                  /* motion along W      */
         {
            *x1 = NCsim_data.simulation_speed << 1;
            *y1 = NCsim_data.simulation_speed << 1;
            *x2 = NCwindow.sx_dits;
            *y2 = ncv_sy_ds;
         }
      }
   }
   else               /* motion along S-N      */
   {
      if (sgny > 0)         /* motion along S      */
      {
         *x1 = NCsim_data.simulation_speed << 1;
         *y1 = 0;
         *x2 = ncv_sx_ds;
         *y2 = ncv_sy_ds;
      }
      else             /* motion along   N      */
      {
         *x1 = NCsim_data.simulation_speed << 1;
         *y1 = NCsim_data.simulation_speed << 1;
         *x2 = ncv_sx_ds;
         *y2 = NCwindow.sy_dits;
      }
   }

   /* In order to do correct putline (see NCpaint) we need to start the  */
   /* subtract/paint region on an even offset.                           */

   if (NCwindow.horizontal_scan)
   {
      *x1 &= 0xfffffffe;
   }
   else
   {
      *y1 &= 0xfffffffe;
   }

#if DEBUG
   fprintf(stderr, "(x1,y1,x2,y2) = (%d, %d, %d, %d)\n",*x1,*y1,*x2,*y2);
#endif
}


/*---NCremove_tool_region-------------------------------------------------------*/

NCremove_tool_region( IGRboolean paint )

/*

DESCRIPTION
   repaint tool region after tool has been removed. e.g. if tool has
   been changed during toolpath verification, we need to remove old
   tool (repaint to part/background), then paint new tool

   08/14/90:  Added PAINT flag.  One may wonder what the heck is going
   on - why are we saving globals in statics and then reassigning them.
   Good question.  Y'see, when this routine was first written it simply
   repainted the region covered by the tool (simbuf).  That way we could
   change the simbuf and paint the new one without worrying about the old
   extents (which we didn't have anymore).  This method left the screen
   without a tool while the new simbuf was being filled in.  Unfortunately,
   sometimes this took a little too long, so we got a request to keep the
   old tool on the screen while the new one was being set.  No problem.
   Here's how it works.  First, NCremove_tool_region is called with
   paint set to FALSE.  This causes the cbuf (which as you know exactly
   covers the tool region) to be filled block/background colors.  If we
   were to paint it to the screen, it would cover the tool (i.e. the tool
   would "disappear").  However, we DON'T paint it.  Instead, we save
   all the global variables we're gonna need to paint it in local static
   variables.  We then return, and proceed to wipe out the old simbuf
   and define a new one.  This kills all the globals.  After we're done,
   we call NCremove_tool_region with PAINT set to TRUE.  This causes
   us to restore the globals to their old values and paint the cbuf.
   This wipes out the tool on the screen.  We then reset the globals
   to their new values and return.  Viola, we're done.  Piece 'o cake.


HISTORY:   09/27/88   Created.         K. M. Jehng
      10/03/88   Added vertical scan lines.   C. M. Jablonski
*/
{
   register IGRint  x;
   register IGRint  y;

   IGRint           sy_off_y;
   IGRint           sx_off_x;
   IGRint           delta_cb_base;
   IGRint           delta_first;
   IGRint           delta_cb;

   struct NCdexel   *first;

   NCcbuf           *cb;
   NCcbuf           *cb_base;

   IGRint           tpx_off;
   IGRint           tpy_off;
   IGRint           tpx_dits;
   IGRint           tpy_dits;
   IGRint           tsx_dits;
   IGRint           tsy_dits;
   IGRint           thoriz;
   IGRint           tzero;

   static IGRint    px_off;
   static IGRint    py_off;
   static IGRint    px_dits;
   static IGRint    py_dits;
   static IGRint    sx_dits;
   static IGRint    sy_dits;
   static IGRint    horiz;
   static IGRint    zero;

   static NCcbuf    *cbuf;


   if (!paint)
   {
      sy_off_y = NCwindow.sy_off;

      first = NCwindow.dexarry +
              (sy_off_y * NCwindow.dx_dits) +
              NCwindow.sx_off;

      delta_first   = NCwindow.dx_dits - NCwindow.sx_dits;
      cb_base       = NCwindow.cbuf;
      delta_cb_base = (NCwindow.horizontal_scan) ? NCwindow.sx_dits : 1;

      /* display part without display tool               */
      for ( y = 0;
            y < NCwindow.sy_dits;
            y++, sy_off_y++, cb_base += delta_cb_base, first += delta_first)
      {
         sx_off_x = NCwindow.sx_off;
         cb       = cb_base;
         delta_cb = (NCwindow.horizontal_scan) ? 1 : NCwindow.sy_dits;

         for (x = 0;
              x < NCwindow.sx_dits;
              x++, sx_off_x++, cb += delta_cb, first++)
         {
            /* algorithms see NCsubtract_sim_tool      */
            *cb = ( sy_off_y <  1 ||
                    sx_off_x <  1 ||
                    sy_off_y >= NCwindow.dy_dits ||
                    sx_off_x >= NCwindow.dx_dits ) ?
                  NCbackground_c : first->color;
         }
      }

      /* reset painting offset */
      NCwindow.px_off = NCwindow.sx_off + NCwindow.dx_off;
      NCwindow.py_off = NCwindow.sy_off + NCwindow.dy_off;

      /* save the pertinent variables */
      px_off = NCwindow.px_off;
      py_off = NCwindow.py_off;
      px_dits = NCwindow.px_dits;
      py_dits = NCwindow.py_dits;
      sx_dits = NCwindow.sx_dits;
      sy_dits = NCwindow.sy_dits;
      horiz = NCwindow.horizontal_scan;
      cbuf = NCwindow.cbuf;
      zero = ncv_zero;
   }
   else
   {
      /* set painting parameters */
      tpx_off = NCwindow.px_off;
      tpy_off = NCwindow.py_off;
      tpx_dits = NCwindow.px_dits;
      tpy_dits = NCwindow.py_dits;
      tsx_dits = NCwindow.sx_dits;
      tsy_dits = NCwindow.sy_dits;
      thoriz = NCwindow.horizontal_scan;
      cb = NCwindow.cbuf;
      tzero = ncv_zero;
      NCwindow.px_off = px_off;
      NCwindow.py_off = py_off;
      NCwindow.px_dits = px_dits;
      NCwindow.py_dits = py_dits;
      NCwindow.sx_dits = sx_dits;
      NCwindow.sy_dits = sy_dits;
      NCwindow.horizontal_scan = horiz;
      NCwindow.cbuf = cbuf;
      ncv_zero = zero;

      /* paint the old cbuf to the screen */
      NCpaint_sim_tool( &ncv_zero,
                        &ncv_zero,
                        &NCwindow.sx_dits,
                        &NCwindow.sy_dits);

      /* free the old cbuf */
      free (cbuf);

      /* reset painting parameters */
      NCwindow.px_off = tpx_off;
      NCwindow.py_off = tpy_off;
      NCwindow.px_dits = tpx_dits;
      NCwindow.py_dits = tpy_dits;
      NCwindow.sx_dits = tsx_dits;
      NCwindow.sy_dits = tsy_dits;
      NCwindow.horizontal_scan = thoriz;
      NCwindow.cbuf = cb;
      ncv_zero = tzero;
   }
}



/*---NCupdate_tool_color----------------------------------------------------*/


NCupdate_tool_color( short new_color )

/*

DESCRIPTION
   update current active tool color to input color for swvol & sim tool modes

HISTORY:   10/24/88   Created.         K. M. Jehng
*/

{

   IGRint           shade_map;
   IGRint           using_ptc = TRUE;

   simDexel         *shade_tool;
   simDexel         *tool;

   register IGRint  x;
   register IGRint  y;


   if( IGEget_using_ramp_mode())
   {
      using_ptc = FALSE;
   }

   HSset_dexel_color( TRUE, (IGRint)new_color, &(NCshading.active_color));

   if (NCsim_data.simulation_mode)
   {
      tool = NCwindow.simbuf;

      if( using_ptc )
      {
         shade_tool = NCwindow.shadebuf;
      }

#if DEBUG_TOOL
      fprintf( stderr, "\nTOOL\n" );
      NCdebug_tool_map( tool );

      if( using_ptc )
      {
         fprintf( stderr, "\nSHADE MAP\n" );
         NCdebug_tool_map( shade_tool );
      }
#endif

      if( !using_ptc )
      {
         shade_map = NCshading.active_color -
                     NCsim_data.active_tool_color;

         for (y = 0; y < NCwindow.sy_dits; y++)
         {
            for (x = 0; x < NCwindow.sx_dits; x++, tool++)
            {
               if (tool->near_z != NCbackground_z)
               {
                  tool->near_c += shade_map;
                  tool->far_c  += shade_map;
               }
            }
         }
      }
      else
      {
         NCconvert_tool_color( tool, shade_tool );
      }
   }

   NCsim_data.active_tool_color = NCshading.active_color;
}


/*---- NCconvert_tool_color -------------------------------------------------*/

NCconvert_tool_color( simDexel *tool, simDexel *shade_map )

{
   double  new_shade_front;
   double  new_shade_back;
   
   int     red;
   int     green;
   int     blue;

   int     temp_red;
   int     temp_green;
   int     temp_blue;

   int     x;
   int     y;


#if DEBUG_TOOL
   fprintf( stderr, "   NCshading.active_color = %d\n",
            NCshading.active_color );
#endif

   IGEindex_to_rgb( active_window->context_no,
                    IGE_LOGICAL_INDEX_TO_LOG,
                    NCshading.active_color,
                    &red,
                    &green,
                    &blue);

   temp_red = red;
   temp_green = green;
   temp_blue = blue;

#if DEBUG_TOOL
   fprintf( stderr, "   red =   %d\n", red);
   fprintf( stderr, "   green = %d\n", green);
   fprintf( stderr, "   blue =  %d\n", blue);
#endif

   for( y  = 0; y < NCwindow.sy_dits; y++ )
   {
      for( x = 0; x < NCwindow.sx_dits; x++, tool++, shade_map++ )
      {
         if (tool->near_z != NCbackground_z )
         {
            new_shade_front = shade_map->near_c / 255.0;
            new_shade_back = shade_map->far_c / 255.0;

            red = temp_red * new_shade_front;
            green = temp_green * new_shade_front;
            blue = temp_blue * new_shade_front;

            tool->near_c =IGErgb_to_index( active_window->context_no,
                                           x,
                                           y,
                                           red,
                                           green,
                                           blue);

            red = temp_red * new_shade_back;
            green = temp_green * new_shade_back;
            blue = temp_blue * new_shade_back;

            tool->far_c = IGErgb_to_index( active_window->context_no,
                                           x,
                                           y,
                                           red,
                                           green,
                                           blue);
         }
      }
   }
}

/*---- NCdebug_tool_map -----------------------------------------------------*/

void NCdebug_tool_map( simDexel *tool )

{
   int x;
   int y;

   for( y  = 0; y < NCwindow.sy_dits; y++ )
   {
      for( x = 0; x < NCwindow.sx_dits; x++, tool++ )
      {
         fprintf( stderr, "%d   ", tool->near_c);
      }
      fprintf( stderr, "\n");
   }
}

