/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:41 $
$Locker:  $
*/

#include <stdio.h>
#include <stdlib.h>

#include <tools.h>
#if defined( ENV5 )
#include <gpipe.h>
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
#include "hsdef.h"
#include "hsurf.h"
#include "hsmath.h"
#include "hsmacdef.h"
#include "hsemulation.h"
#include "hsdisplay.h"

#include "HSsara.h"

#include "HStl_global.h"
#include "HStl_window.h"
#include "HStl_element.h"
#include "HSfem_spt.h"
#include "HSd_fixedpt.h"

#include "HSe2_mesher.h"
#include "HSpr_tiler_f.h"

/*------------------------------------
 *  for functions
 *     HScontinue_polyline_ifb
 *     HScontinue_polyline_rop
 *     HSdraw_point_FPE
 *     HSdraw_point_ROP
 *     HSpaint
 *     HSpaint_screen_FPE
 *     HSpaint_screen_merge24
 *     HSpaint_screen_putpixel
 *     HSpaint_screen_ROP
 *     HSpaint_screen_stub
 *     HSstart_polyline_ifb
 *     HSstart_polyline_rop
 */

#include "HSpr_display.h"

/*------------------------------------
 *  for functions
 *     HSdelete
 */

#include "HSpr_driver.h"

/*--------------------------------*/

/*------------------------------------
 *  for functions
 *     HSconvert_to_indexed_context
 *     HSrestore_window_context
 */
#include "hsanimate.h"
#include "hskyoptypes.h"
#include "HSpr_co_func.h"

#if defined (OPENGL)
extern int HSsend_trimesh_to_OPENGL ();

#endif
#if defined (XGL)
extern int HSsend_trimesh_to_XGL ();

#endif

#define PAINT_DELAY_MERGE    434
#define PAINT_DELAY_GS       434
#define PAINT_DELAY_GX       62

/* temp definition for FEM element display */
#define HS_FEM_MODE          0x00008000
#define UNDEFINED_VC         -1

#define    DEBUG             0
#define    EDGEII_DEBUG      0


extern IGRboolean DPdlist_feedback_in_progress;

/*******************
 * Local Variables *
 *******************/

static struct HS_window_parms *shading_window_list = NULL;      /* active  */
static struct HS_window_parms *free_window_list = NULL; /* deleted */


/*---HSdump_window_parms------------------------------------------------------*/

/*
NAME
    HSdump_window_parms

DESCRIPTION
    This function prints out the values of the active window parameters.

KEYWORD
    debug

PARAMETERS
    none

GLOBALS USED
    active_window

HISTORY
    08/29/90    C.M. Jablonski
       Created
*/

void HSdump_window_parms (void)

   {
   IGRint i;

   fprintf (stderr, "GLOBAL WINDOW PARAMETERS:\n");
   fprintf (stderr, "   pipe_no ---------- %17d\n", active_window->pipe_no);
   fprintf (stderr, "   persp_pipe_no ---- %17d\n", active_window->persp_pipe_no);
   fprintf (stderr, "   ortho_pipe_no ---- %17d\n", active_window->ortho_pipe_no);
   fprintf (stderr, "   win_no ----------- %17d\n", active_window->win_no);
   fprintf (stderr, "   vs_no ------------ %17d\n", active_window->vs_no);
   fprintf (stderr, "   EG_vc_no ------------ %17d\n", active_window->EG_vc_no);
   fprintf (stderr, "   perspective ------ %17d\n", active_window->perspective);
   fprintf (stderr, "   persp_x_scale ---- %17.8f\n", active_window->persp_x_scale);
   fprintf (stderr, "   persp_y_scale ---- %17.8f\n", active_window->persp_y_scale);
   fprintf (stderr, "   persp_z_scale ---- %17.8f\n", active_window->persp_z_scale);
   fprintf (stderr, "   wv_scale --------- %17.8f\n", active_window->wv_scale);
   fprintf (stderr, "   shading_style ---- %17d\n", active_window->shading_style);
   fprintf (stderr, "   org_x, org_y ----- %17d %17d\n",
            active_window->org_x, active_window->org_y);
   fprintf (stderr, "   x_dits, y_dits --- %17d %17d\n",
            active_window->x_dits, active_window->y_dits);
   fprintf (stderr, "   z_min, z_max ----- %17.8f %17.8f\n",
            active_window->z_min, active_window->z_max);
   fprintf (stderr, "   z_scale ---------- %17.8f\n", active_window->zscale);
   fprintf (stderr, "   dit_clip_range --- %17.8f %17.8f %17.8f\n",
            active_window->dit_clip_range[0],
            active_window->dit_clip_range[1],
            active_window->dit_clip_range[2]);
   fprintf (stderr, "                      %17.8f %17.8f %17.8f\n",
            active_window->dit_clip_range[3],
            active_window->dit_clip_range[4],
            active_window->dit_clip_range[5]);
   fprintf (stderr, "   grid_on ---------- %17d\n", active_window->grid_on);
   fprintf (stderr, "   depth_cue_on ----- %17d\n", active_window->depth_cue_on);
   fprintf (stderr, "   depth_cue_base --- %17.8f\n", active_window->depth_cue_base);
   fprintf (stderr, "   depth_cue_delta -- %17.8f\n", active_window->depth_cue_delta);
   fprintf (stderr, "   rotate_matrix ---- %17.8f %17.8f %17.8f\n",
            active_window->rotate_matrix[0][0],
            active_window->rotate_matrix[0][1],
            active_window->rotate_matrix[0][2]);
   fprintf (stderr, "                      %17.8f %17.8f %17.8f\n",
            active_window->rotate_matrix[1][0],
            active_window->rotate_matrix[1][1],
            active_window->rotate_matrix[1][2]);
   fprintf (stderr, "                      %17.8f %17.8f %17.8f\n",
            active_window->rotate_matrix[2][0],
            active_window->rotate_matrix[2][1],
            active_window->rotate_matrix[2][2]);
   fprintf (stderr, "   transform_matrix - %17.8f %17.8f %17.8f %17.8f\n",
            active_window->transform_matrix[0][0],
            active_window->transform_matrix[0][1],
            active_window->transform_matrix[0][2],
            active_window->transform_matrix[0][3]);
   fprintf (stderr, "                      %17.8f %17.8f %17.8f %17.8f\n",
            active_window->transform_matrix[1][0],
            active_window->transform_matrix[1][1],
            active_window->transform_matrix[1][2],
            active_window->transform_matrix[1][3]);
   fprintf (stderr, "                      %17.8f %17.8f %17.8f %17.8f\n",
            active_window->transform_matrix[2][0],
            active_window->transform_matrix[2][1],
            active_window->transform_matrix[2][2],
            active_window->transform_matrix[2][3]);
   fprintf (stderr, "                      %17.8f %17.8f %17.8f %17.8f\n",
            active_window->transform_matrix[3][0],
            active_window->transform_matrix[3][1],
            active_window->transform_matrix[3][2],
            active_window->transform_matrix[3][3]);
   fprintf (stderr, "   num_lights ------- %17d\n", active_window->num_lights);
   for (i = 0; i < active_window->num_lights; i++)
      {
      fprintf (stderr, "   LIGHT SOURCE[%d]:\n", i);
      fprintf (stderr, "      flags ---------- 0x%X\n",
               active_window->light_sources[i].flags);
      fprintf (stderr, "      rgb ----------- %17d %17d %17d\n",
               active_window->light_sources[i].red,
               active_window->light_sources[i].green,
               active_window->light_sources[i].blue);
      fprintf (stderr, "      location ------ %17.8f %17.8f %17.8f\n",
               active_window->light_sources[i].location[0],
               active_window->light_sources[i].location[1],
               active_window->light_sources[i].location[2]);
      fprintf (stderr, "      target -------- %17.8f %17.8f %17.8f\n",
               active_window->light_sources[i].target[0],
               active_window->light_sources[i].target[1],
               active_window->light_sources[i].target[2]);
      fprintf (stderr, "      direction ----- %17.8f %17.8f %17.8f\n",
               active_window->light_sources[i].direction[0],
               active_window->light_sources[i].direction[1],
               active_window->light_sources[i].direction[2]);
      fprintf (stderr, "      radius -------- %17.8f\n",
               active_window->light_sources[i].radius);
      fprintf (stderr, "      angle --------- %17.8f\n",
               active_window->light_sources[i].angle);
      }
   fprintf (stderr, "   x_min, y_min --- %17d %17d\n",
            active_window->x_min, active_window->y_min);
   fprintf (stderr, "   x_max, y_max --- %17d %17d\n",
            active_window->x_max, active_window->y_max);
   fprintf (stderr, "   x_min_us, y_min_us --- %17d %17d\n",
            active_window->x_min_us, active_window->y_min_us);
   fprintf (stderr, "   x_max_us, y_max_us --- %17d %17d\n",
            active_window->x_max_us, active_window->y_max_us);
   fprintf (stderr, "   x_min_rl, y_min_rl --- %17d %17d\n",
            active_window->x_min_rl, active_window->y_min_rl);
   fprintf (stderr, "   x_max_rl, y_max_rl --- %17d %17d\n",
            active_window->x_max_rl, active_window->y_max_rl);
   fprintf (stderr, "   zbuf_size ------ %17d\n", active_window->zbuf_size);
   fprintf (stderr, "   cbuf_size ------ %17d\n", active_window->cbuf_size);
   fprintf (stderr, "   num_bytes ------ %17d\n", active_window->num_bytes);
   fprintf (stderr, "   type ----------- %17d\n", active_window->type);
   fprintf (stderr, "   initialized ---- %17d\n", active_window->initialized);
   fprintf (stderr, "   making tris ---- %17d\n", active_window->making_triangles);
   fprintf (stderr, "   user_notified -- %17d\n", active_window->user_notified);
   fprintf (stderr, "   paint_delay ---- %17d %17d\n",
            active_window->paint_delay[0], active_window->paint_delay[1]);
   fprintf (stderr, "   ignore_locked -- %17d\n",
            active_window->ignore_locked_zbuffer);
   fprintf (stderr, "   unsup_alloc ---- %17d\n",
            active_window->unsupported_zbuffer_allocated);
   fprintf (stderr, "   active_zbuffer - %17d\n",
            active_window->active_zbuffer);
   fprintf (stderr, "   ---------------------------------------------------\n\n\n");
   }


/*---HSactivate_window--------------------------------------------------------*/

void HSactivate_window (
                             IGRint pipe_no)

/*
NAME
    HSactivate_window

DESCRIPTION
    This function activates the window with the given window number.
    Should the window not be currently active, it linearly searches
    the list of current shading windows.  Should the window not be there,
    space is allocated for it and default values are set.

PARAMETERS
    pipe_no (IN) - the window number of the window to activate

GLOBALS USED
    active_window - set to newly activated window

HISTORY
    02/16/87    S.A. Rapa
        Created
     11/09/87    Mike Lanier
        Modified for IFB support
    03/01/90    C.M. Jablonski
        Modified to set active_window instead of returning a window structure
    02/24/92    S.P. Rogers
        Added initialization of the "image_buffer_valid" field
*/

   {

   /**** Check to see if currently active window is one being requested. ****/

   if ((!active_window) ||
       (active_window->pipe_no != pipe_no))

      {

      /**** Look for window already out there. ****/

      active_window = shading_window_list;
      while ((active_window != NULL) && (active_window->pipe_no != pipe_no))
         active_window = active_window->next;


      /**** Create window data if none out there. ****/

      if (!active_window)
         {

         /**** Gets space for new window from free pool, if possible. ****/

         if (free_window_list)
            {
            active_window = free_window_list;
            free_window_list = free_window_list->next;
            }
         else
            {
            active_window = (struct HS_window_parms *) malloc (sizeof (struct HS_window_parms));
            if (!active_window)
               {
               HSset_status (HSSTAT_ALLOC_ERROR);
               goto wrapup;
               }
            }

         /**** add window to list ****/

         active_window->pipe_no = pipe_no;
         active_window->next = shading_window_list;
         shading_window_list = active_window;


         /**** set default values ****/

         active_window->initialized = FALSE;
         active_window->perspective = FALSE;
         active_window->x_max = -1;
         active_window->y_max = -1;
         active_window->x_min = 0;
         active_window->y_min = 0;
         active_window->x_dits = 0;
         active_window->y_dits = 0;
         active_window->zbuf = NULL;
         active_window->cbuf = NULL;
         active_window->unsupported_zbuffer_allocated = FALSE;
         active_window->ignore_locked_zbuffer = FALSE;
         active_window->using_ramps = IGEget_using_ramp_mode ();
         active_window->making_triangles = FALSE;
         active_window->active_zbuffer = 0;
         active_window->zbuf_size = 0;
         active_window->cbuf_size = 0;
         active_window->num_bytes = 0;
         active_window->type = 0;
         active_window->EG_vc_no = UNDEFINED_VC;
         active_window->image_buffer_valid = FALSE;
         active_window->saved_win_context = WL_UNDEFINED_WINDOW;
         active_window->image.lras_no = 9999;
         active_window->image.buffer = NULL;
         }
      }
#if defined( OPENGL )
#if defined( X11 )
   if ((active_window->initialized) &&
       (active_window->type & HShardware_LB_OPENGL))
      {
      WLglx_make_window_current (active_window->win_no, WL_GLX_BASE_WIN);
      }
#endif
#endif

wrapup:;
   }



/*--- HScalc_window_buffer_size -------------------------------------*/

/*
NAME
    HScalc_window_buffer_size

DESCRIPTION
    This function calculates the size of the Z and image buffers
    for a window in bytes and number of pixels.

PARAMETERS
    x_dits (IN/OUT) - the x extent of the window
    y_dits (IN/OUT) - the y extent of the window
    num_bytes (OUT) - number of bytes for Z/image buffers
    num_pixels (OUT) - number of pixels in window

GLOBALS USED
    none

HISTORY
    10/15/90    S.P. Rogers
       Extracted from HSallocate_active_window_buffers
*/

void HScalc_window_buffer_size (int *xdits,
                                     int *ydits,
                                     int *num_bytes,
                                     int *num_pixels)

   {

   /**** make sure the ranges are even for the display routines ****/

   if (*xdits & 1)
      (*xdits)++;
   if (*ydits & 1)
      (*ydits)++;


   /**** calculate the number of bytes required ****/

   *num_pixels = *xdits * *ydits;
   *num_bytes = *num_pixels * (sizeof (HSzbuf) + sizeof (HScbuf));

   /**** make sure the number of bytes is a multiple of 4 ****/

   (*num_bytes) += 4 - (*num_bytes % 4);

   }    /**** HScalc_window_buffer_size ****/


/*---HSallocate_active_window_buffers-----------------------------------------*/

/*
NAME
    HSallocate_active_window_buffers

DESCRIPTION
    This function allocates buffers for the active window.
    First it determines the number of bytes needed, then it calls the appropriate
    memory management routine to malloc or realloc the buffers.

PARAMETERS
    vs_no (IN) - the virtual screen number of the active window
    xdits IN) - the X extent of the window
    ydits (IN) - the Y extent of the window

GLOBALS USED
    active_window

NOTES
    This function assumes that the active window pointer is pointing to the
    window whose buffers are to be allocated.

HISTORY
    03/02/90    Mike Lanier/C. M. Jablonski
       Creation Date
*/

void HSallocate_active_window_buffers (IGRint vs_no,
                                            IGRint xdits,
                                            IGRint ydits)

   {
   HSzbuf *zbuf;
   IGRint num_pixels, num_bytes;
   IGRint num_pixels_tmp, num_bytes_tmp;
   IGRboolean region_update = FALSE;
   IGRint x_dits_tmp, y_dits_tmp;

   HSget_region_update (&region_update);

   HScalc_window_buffer_size (&xdits, &ydits, &num_bytes, &num_pixels);
   if (region_update)
      {

      /****  if allocated size is already full window, don't allocate ****/
      /****  smaller region size keep same size                       ****/

      HSget_region_window_dits (&x_dits_tmp, &y_dits_tmp);
      HScalc_window_buffer_size (&x_dits_tmp, &y_dits_tmp, &num_bytes_tmp, &num_pixels_tmp);

      if (num_bytes_tmp == active_window->num_bytes)
         {
         /***  *HSset_win allocate active window buffers already window size  ****/
         return;
         }
      }

   /**** if a zbuffer does not exist for the window, malloc ****/

   if (active_window->num_bytes == 0)
      {
      zbuf = (HSzbuf *) (*tiling_parms.zmalloc) (0, num_bytes, NULL, active_window);

      if (zbuf == NULL)
         {
         tiling_parms.status = HSSTAT_ALLOC_ERROR;
         }
      else
         {
         active_window->zbuf = zbuf;
         active_window->cbuf = (HScbuf *) (zbuf + num_pixels);
         active_window->zbuf_size = num_pixels * sizeof (HSzbuf);
         active_window->cbuf_size = num_pixels * sizeof (HScbuf);
         active_window->num_bytes = num_bytes;
         active_window->num_pixels = num_pixels;
         active_window->x_dits = xdits;
         active_window->y_dits = ydits;
         WLcreate_raster_data (active_window->win_no, active_window->context_no, &active_window->image,
                               0, 0, active_window->x_dits, active_window->y_dits, sizeof (HScbuf) * 8, WL_SLOW_BUFFER,
                               (char *) active_window->cbuf);
         }
      }

   /**** else, if a zbuffer does exist but is the wrong size, realloc ****/

   else if (active_window->num_bytes != num_bytes)
      {
      zbuf = (HSzbuf *) (*tiling_parms.zrealloc) (
                                                  0,
                                                  num_bytes,
                                                  NULL,
                                                  active_window,
                                                  active_window->zbuf);

      if (zbuf == NULL)
         {
         tiling_parms.status = HSSTAT_ALLOC_ERROR;
         }
      else
         {
         active_window->zbuf = zbuf;
         active_window->cbuf = (HScbuf *) (zbuf + num_pixels);
         active_window->zbuf_size = num_pixels * sizeof (HSzbuf);
         active_window->cbuf_size = num_pixels * sizeof (HScbuf);
         active_window->num_bytes = num_bytes;
         active_window->num_pixels = num_pixels;
         active_window->x_dits = xdits;
         active_window->y_dits = ydits;
         WLcreate_raster_data (active_window->win_no, active_window->context_no, &active_window->image,
                               0, 0, active_window->x_dits, active_window->y_dits, sizeof (HScbuf) * 8, WL_SLOW_BUFFER,
                               (char *) active_window->cbuf);
         }
      }

#   if DEBUG
   fprintf (stderr, "      num_pixels ----- %1d\n", num_pixels);
   fprintf (stderr, "      num_bytes ------ %1d\n", num_bytes);
   fprintf (stderr, "      vs_no ---------- %1d\n", vs_no);
   fprintf (stderr, "      zbuf ----------- %x\n", active_window->zbuf);
#   endif
   }

/*---HSfree_active_window_buffers---------------------------------------------*/

/*
NAME
    HSfree_active_window_buffers

DESCRIPTION
    This function deletes the buffers from the active window
    and updates the necessary memory data structures.

PARAMETERS
    none

GLOBALS USED
    active_window

NOTES
    This function assumes that the active window pointer points to the
    window whose buffers are to be freed.

HISTORY
    03/02/90    Mike Lanier/C. M. Jablonski
       Creation Date
*/

static void HSfree_active_window_buffers (void)

   {
   (*tiling_parms.zfree) (0, active_window->zbuf);

   active_window->initialized = FALSE;
   active_window->x_dits = 0;
   active_window->y_dits = 0;
   active_window->zbuf = NULL;
   active_window->cbuf = NULL;
   active_window->unsupported_zbuffer_allocated = FALSE;
   active_window->ignore_locked_zbuffer = FALSE;
   active_window->using_ramps = IGEget_using_ramp_mode ();
   active_window->making_triangles = FALSE;
   active_window->active_zbuffer = 0;
   active_window->zbuf_size = 0;
   active_window->cbuf_size = 0;
   active_window->num_bytes = 0;
   active_window->type = 0;
   WLfree_raster_data (&active_window->image);
   }


/*---HSset_HSURF_routines------------------------------------------------------*/

/*
NAME
    HSset_HSURF_routines (static)

DESCRIPTION
    This function sets the default function pointers in the active window
    to unix functions without hardware support.

PARAMETERS
    none

GLOBALS USED
    active_window
    tiling_parms.processing_mode

NOTES
    This function assumes that the active window pointer points to the
    window whose function pointers are to be set.

HISTORY
    03/02/90    Mike Lanier/C. M. Jablonski
       Creation Date
    06/14/90    S.P. Rogers
       Changed to use HSpaint_screen_putpixel if running on a machine
       with more than 5 planes.
*/

static void HSset_HSURF_routines (
                                       void)

   {
   if (active_window->using_ramps)
      active_window->init_paint[0] = HSinit_paint_rop_ramp;
   else
      active_window->init_paint[0] = HSinit_paint_ROP;

   active_window->init_window[0] = HSinit_window_ROP;
   active_window->start_polyline[0] = HSstart_polyline_rop;
   active_window->continue_polyline[0] = HScontinue_polyline_rop;
   active_window->draw_point[0] = HSdraw_point_ROP;

   if (active_window->type & HShardware_LB_HSURF_ROP)
      {
      active_window->painter[0] = HSpaint_screen_ROP;
      active_window->paint_delay[0] = PAINT_DELAY_GS;
      }
   else
      {
      active_window->painter[0] = HSpaint_screen_putpixel;
      active_window->paint_delay[0] = PAINT_DELAY_GX;
      }

   active_window->prepare_facet[0] = clip_and_shade;
   active_window->add_vertex[0] = add_vertex_to_loop;
   active_window->end_loop[0] = end_facet_loop;

   if (!(tiling_parms.processing_mode & HS_PMODE_FEEDBACK))
      active_window->process_facet = process_facet;
   }    /* HSset_HSURF_routines */

#if defined( ENV5 )
/*---HSset_EG_routines--------------------------------------------------------*/

static void HSset_EG_routines (void)

/*
NAME
    HSset_EG_routines

DESCRIPTION
    This function sets the default function pointers in the active window
    to EDGEII-supported functions.

PARAMETERS
    none

GLOBALS USED
    active_window

NOTES
    This function assumes that the active window pointer already points to
    the window whose function pointers are to be set.

HISTORY
    05/18/93    M. Lanier
       Added conditional compile for SGI build

    03/06/90    C.M. Jablonski
       Created.
*/

   {
   active_window->init_window[0] = HSinit_window_EG;
   active_window->painter[0] = HSpaint_screen_stub;
   active_window->init_paint[0] = HSinit_paint_EG;
   active_window->start_polyline[0] = HSstart_polyline_rop;
   active_window->continue_polyline[0] = HScontinue_polyline_rop;

   active_window->draw_point[0] = HSdraw_point_EG;

   active_window->paint_delay[0] = PAINT_DELAY_GS;
   active_window->prepare_facet[0] = HSdoTriMesh;
   active_window->add_vertex[0] = HSadd_tri_vertex;
   active_window->end_loop[0] = HSend_tri_loop;

   active_window->process_mesh = HSsend_trimesh_to_EG;

   if (!(tiling_parms.processing_mode & HS_PMODE_FEEDBACK))
      active_window->process_facet = process_facet;
   }    /* HSset_EG_routines */

/*---HSset_GPIPE_routines-------------------------------------------------------*/

static void HSset_GPIPE_routines (void)

/*
NAME
    HSset_GPIPE_routines

DESCRIPTION
    This function sets the default function pointers in the active window
    to FPE-supported functions.

PARAMETERS
    none

GLOBALS USED
    active_window

NOTES
    This function assumes that the active window pointer already points to
    the window whose function pointers are to be set.

HISTORY
    03/02/90   Mike Lanier/C. M. Jablonski
       Creation Date
*/

   {
   active_window->init_window[0] = HSinit_window_FPE;
   active_window->painter[0] = HSpaint_screen_FPE;
   active_window->init_paint[0] = HSinit_paint_IFB;
   active_window->start_polyline[0] = HSstart_polyline_ifb;
   active_window->continue_polyline[0] = HScontinue_polyline_ifb;
   active_window->draw_point[0] = HSdraw_point_FPE;

   active_window->paint_delay[0] = PAINT_DELAY_GS;
   active_window->prepare_facet[0] = clip_and_shade;
   active_window->add_vertex[0] = add_vertex_to_loop;
   active_window->end_loop[0] = end_facet_loop;

   if (!(tiling_parms.processing_mode & HS_PMODE_FEEDBACK))
      active_window->process_facet = process_facet;
   }    /* HSset_GPIPE_routines */

/*---HSset_IFB_routines-------------------------------------------------------*/

static void HSset_IFB_routines (void)

/*
NAME
    HSset_IFB_routines

DESCRIPTION
    This function sets the default function pointers in the active window
    to IFB-supported functions.

PARAMETERS
    none

GLOBALS USED
    active_window

NOTES
    This function assumes that the active window pointer already points to
    the window whose function pointers are to be set.

HISTORY
    03/02/90   Mike Lanier/C. M. Jablonski
       Creation Date
*/

   {
   active_window->init_window[0] = HSinit_window_IFB;
   active_window->painter[0] = HSpaint_screen_IFB;
   active_window->init_paint[0] = HSinit_paint_IFB;
   active_window->start_polyline[0] = HSstart_polyline_ifb;
   active_window->continue_polyline[0] = HScontinue_polyline_ifb;
   active_window->draw_point[0] = HSdraw_point_IFB;

   active_window->paint_delay[0] = PAINT_DELAY_GS;
   active_window->prepare_facet[0] = clip_and_shade;
   active_window->add_vertex[0] = add_vertex_to_loop;
   active_window->end_loop[0] = end_facet_loop;

   if (!(tiling_parms.processing_mode & HS_PMODE_FEEDBACK))
      active_window->process_facet = process_facet;
   }    /* HSset_IFB_routines */

#endif

#if defined( OPENGL )
/*---HSset_OPENGL_routines--------------------------------------------------------*/

static void HSset_OPENGL_routines (
                                        void)

/*
NAME
    HSset_OPENGL_routines

DESCRIPTION
    This function sets the default function pointers in the active window
    to OPENGL-supported functions.

PARAMETERS
    none

GLOBALS USED
    active_window

NOTES
    This function assumes that the active window pointer already points to
    the window whose function pointers are to be set.

HISTORY
    03/06/90    C.M. Jablonski
       Created.
*/

   {
   active_window->init_window[0] = HSinit_window_OPENGL;
   active_window->painter[0] = HSpaint_screen_OPENGL;
   active_window->init_paint[0] = HSinit_paint_OPENGL;
   active_window->start_polyline[0] = HSstart_polyline_rop;
   active_window->continue_polyline[0] = HScontinue_polyline_rop;
   active_window->draw_point[0] = HSdraw_point_OPENGL;

   active_window->paint_delay[0] = PAINT_DELAY_GS;
   active_window->prepare_facet[0] = HSdoTriMesh;
   active_window->add_vertex[0] = HSadd_tri_vertex;
   active_window->end_loop[0] = HSend_tri_loop;

   active_window->process_mesh = HSsend_trimesh_to_OPENGL;

   if (!(tiling_parms.processing_mode & HS_PMODE_FEEDBACK))
      active_window->process_facet = process_facet;
   }    /* HSset_OPENGL_routines */

#endif


#if defined( XGL )
/*---HSset_XGL_routines--------------------------------------------------------*/

static void HSset_XGL_routines (
                                     void)

/*
NAME
    HSset_XGL_routines

DESCRIPTION
    This function sets the default function pointers in the active window
    to XGL-supported functions.

PARAMETERS
    none

GLOBALS USED
    active_window

NOTES
    This function assumes that the active window pointer already points to
    the window whose function pointers are to be set.

HISTORY
    03/06/90    C.M. Jablonski
       Created.
*/

   {
   active_window->init_window[0] = HSinit_window_XGL;
   active_window->painter[0] = HSpaint_screen_XGL;
   active_window->init_paint[0] = HSinit_paint_XGL;
   active_window->start_polyline[0] = HSstart_polyline_rop;
   active_window->continue_polyline[0] = HScontinue_polyline_rop;
   active_window->draw_point[0] = HSdraw_point_XGL;

   active_window->paint_delay[0] = PAINT_DELAY_GS;
   active_window->prepare_facet[0] = HSdoTriMesh;
   active_window->add_vertex[0] = HSadd_tri_vertex;
   active_window->end_loop[0] = HSend_tri_loop;

   active_window->process_mesh = HSsend_trimesh_to_XGL;

   if (!(tiling_parms.processing_mode & HS_PMODE_FEEDBACK))
      active_window->process_facet = process_facet;
   }    /* HSset_XGL_routines */

#endif


/*---HSset_default_active_window_functions------------------------------------*/

/*
NAME
    HSset_default_active_window_functions

DESCRIPTION
    HSset_default_active_window_functions sets the function pointers for
    the given z-buffer in the active window to functions without hardware
    support.

PARAMETERS
    active_zbuffer (IN) - the index of the functions in the active window
                          to set (either 0 or 1)

GLOBALS USED
    active_window

NOTES
    This function assumes that the active window pointer already points to
    the window whose function pointers are to be set.

HISTORY
    03/02/90    Mike Lanier/C. M. Jablonski
       Creation Date
*/

void HSset_default_active_window_functions (IGRint active_zbuffer)

   {
   active_window->init_paint[active_zbuffer] = HSinit_paint_ROP;
   active_window->init_window[active_zbuffer] = HSinit_window_ROP;
   active_window->start_polyline[active_zbuffer] = HSstart_polyline_rop;
   active_window->continue_polyline[active_zbuffer] = HScontinue_polyline_rop;
   active_window->draw_point[active_zbuffer] = HSdraw_point_ROP;

   if (active_zbuffer == 0)
      {
      active_window->painter[active_zbuffer] = HSpaint_screen_ROP;
      active_window->paint_delay[active_zbuffer] = PAINT_DELAY_GS;
      }
#if defined( ENV5 )
   else
      {
      if (active_window->type & HShardware_LB_EG)
         {
         active_window->painter[active_zbuffer] = HSpaint_screen_merge24;
         active_window->paint_delay[active_zbuffer] = PAINT_DELAY_MERGE;
         }
      else
         {
         active_window->painter[active_zbuffer] = HSpaint_screen_merge;
         active_window->paint_delay[active_zbuffer] = PAINT_DELAY_MERGE;
         }
      }
#endif

   active_window->prepare_facet[active_zbuffer] = clip_and_shade;
   active_window->add_vertex[active_zbuffer] = add_vertex_to_loop;
   active_window->end_loop[active_zbuffer] = end_facet_loop;

   if (!(tiling_parms.processing_mode & HS_PMODE_FEEDBACK))
      active_window->process_facet = process_facet;
   }


/*---HSinitialize_active_window_functions-------------------------------------*/

/*
NAME
    HSinitialize_active_window_functions

DESCRIPTION
    This function sets the function pointers for the active window
    according to its type.

PARAMETERS
    none

GLOBALS USED
    active_window

NOTES
    This function assumes that the active window pointer already points to
    the window whose function pointers are to be set.

HISTORY
    03/02/90    Mike Lanier/C. M. Jablonski
       Creation Date
    03/06/90    C.M. Jablonski
       Added EG support.
*/

void HSinitialize_active_window_functions (void)

   {

   /* RAMPS: need to set using_ramps */

   active_window->using_ramps = IGEget_using_ramp_mode ();

#  if defined( ENV5 )
   if (active_window->type & HShardware_LB_EG)
      {
      HSset_EG_routines ();
      }

   else if (active_window->type & HShardware_LB_GPIPE)
      {
      HSset_GPIPE_routines ();
      }

   else if (active_window->type & HShardware_ZB_32)
      {
      HSset_IFB_routines ();
      }
#  else
   if (FALSE)
      {
      ;
      }
#  endif

#  if defined( OPENGL )
   else if (active_window->type & HShardware_LB_OPENGL)
      {
      HSset_OPENGL_routines ();
      }
#  endif
#  if defined( XGL )
   else if (active_window->type & HShardware_LB_XGL)
      {
      HSset_XGL_routines ();
      }
#  endif
   else
      {
      HSset_HSURF_routines ();
      }


   /* set up the function pointers for non-supported objects */
   /* set the active z-buffer index */

   HSset_default_active_window_functions (1);

   active_window->active_zbuffer = 0;

   active_window->making_triangles =
      (active_window->type & (HShardware_LB_EG | HShardware_LB_OPENGL | HShardware_LB_XGL));

   }    /* HSinitialize_active_window_functions */


/*--- HSrendering_window_stub ------------------------------------------------*/

/*
NAME
    HSrendering_window_stub

DESCRIPTION
    Stub for the window specific routines for rendering windows

PARAMTERS
    none

GLOBALS USED
    none

HISTORY
    03/02/90    C.M. Jablonksi
       Creation Date
*/

static void HSrendering_window_stub (void)

   {
   }


/*---HSinitialize_active_window_for_rendering---------------------------------*/

/*
NAME
    HSinitialize_active_window_for_rendering

DESCRIPTION
    This function sets the fields of the active window for rendering.

PARAMETERS
    none

GLOBALS USED
    active_window

NOTES
    This function assumes that the active window pointer already points to
    the window that is to be initialized for rendering.

HISTORY
    03/02/90    Mike Lanier/C. M. Jablonski
       Creation Date
*/

static void HSinitialize_active_window_for_rendering (void)

   {
   /* do not allocate z-buffers in rendering mode */
   active_window->type = 0;
   active_window->zbuf = NULL;
   active_window->cbuf = NULL;


   active_window->prepare_facet[0] = clip_and_shade;
   active_window->add_vertex[0] = add_vertex_to_loop;
   active_window->end_loop[0] = end_facet_loop;
   active_window->process_facet = process_facet;

   /* stub out unnecessary window-specific functions */
   active_window->init_paint[0] =
      active_window->init_window[0] =
      active_window->start_polyline[0] =
      active_window->continue_polyline[0] =
      active_window->draw_point[0] =
      active_window->painter[0] = HSrendering_window_stub;

   active_window->active_zbuffer = 0;
   }

/*--- HSdlist_window_stub --------------------------------------------*/

static void HSdlist_window_stub (
                                      void)

/*
NAME
    HSdlist_window_stub

DESCRIPTION
    Stub for the window specific routines for display_lists windows

PARAMTERS
    none

GLOBALS USED
    none

HISTORY
    07/12/93    Shridar Subramanian
       Creation Date
*/

   {
   }    /* HSdlist_window_stub */

/*---HSinitialize_active_window_for_dlist----------------------------*/

static void HSinitialize_active_window_for_dlist (
                                                       void)

/*
NAME
    HSinitialize_active_window_for_dlist

DESCRIPTION
    This function sets the fields of the active window for display_list.

PARAMETERS
    none

GLOBALS USED
    active_window

NOTES
    This function assumes that the active window pointer already points to
    the window that is to be initialized for display list.

HISTORY
    07/12/93    Shridar Subramanian
       Creation Date
*/

   {
   /* do not allocate z-buffers in rendering mode */
   active_window->initialized = TRUE;
   active_window->active_zbuffer = 0;
   active_window->zbuf = NULL;
   active_window->cbuf = NULL;

   active_window->paint_delay[0] = PAINT_DELAY_GS;
   active_window->prepare_facet[0] = HSdoTriMesh;
   active_window->add_vertex[0] = HSadd_tri_vertex;
   active_window->end_loop[0] = HSend_tri_loop;

   /* stub out unnecessary window-specific functions */
   active_window->init_paint[0] =
      active_window->init_window[0] =
      active_window->start_polyline[0] =
      active_window->continue_polyline[0] =
      active_window->draw_point[0] =
      active_window->painter[0] = HSdlist_window_stub;

   }    /* HSinitialize_active_window_for_dlist */

/*---HSinit_shading_window----------------------------------------------------*/

/*
NAME
    HSinit_shading_window

DESCRIPTION
    This function initializes a window for shading.  First,
    it activates the window, creating a new one if necessary.  Then
    it initializes the active window according to tiler mode and
    hardware support:

    1) If rendering, initialize for rendering and return, otherwise:

     2) Check hardware support.  Possibilities are:
        a)  Zbuffer not locked        (00)
        b)  Zbuffer locked, no FPE    (01)
        c)  Zbuffer locked, FPE        (11)
        d)  Zbuffer locked, EdgeII

        also, for 2Mpx display or in    (100)

    3) If a) attempt to allocate zbuffer memory.

    4) If 3) fails, return failure, otherwise:

    5) Create and initialize an active window structure for the window,
       return success.

PARAMETERS
    vs_no (IN) - virtual screen no on which the window resides
    w_no (IN) - window number of the window
    gpipe_no (IN) - gpipe pipe number of the window
    xdits (IN) - x size of window in dits
    ydits (IN) - y size of window in dits
    shading_style (IN) - shading style for the window

GLOBALS USED
    active_window
    tiling_parms.processing_mode
    tiling_parms.status

RETURN VALUES
    TRUE - if successful
    FALSE - otherwise

HISTORY
    03/02/90    Mike Lanier/C. M. Jablonski
       Created.
    03/06/90    C.M. Jablonski
       Added EG support.
    01/23/92    S.P. Rogers
       Put in call to initialize buffers (TR 92N0412)
    02/21/92    S.P. Rogers
       Set grid_on to FALSE before calling HSinitialize_buffers() kludge
    09/16/93    S.P. Rogers
       Removed the intialize buffers calls because it is no longer needed
       with the image_buffer_valid flag in the active_window structure
*/

IGRboolean HSinit_shading_window (WLuint16 lscreen_no,  /* logical screen number  */
                                             IGRint w_no,       /* window number of the
                                                                 * window */
                                             IGRint gpipe_no,   /* gpipe pipe number of
                                                                 * the window */
                                             IGRint xdits,      /* window size in dits */
                                             IGRint ydits,
                                             IGRint shading_style,      /* shading style for the
                                                                         * window */
                                             OM_S_OBJID gragad_id,      /* gragad id of window */
                                             OMuword gragad_os) /* os of the window */

   {
   struct WLnative_info native_info;

   if (gragad_id != NULL_OBJID)
      {
      if (shading_style == HS_STYLE_RASTER ||
          shading_style == HS_STYLE_FILLED_RASTER)
         {

         /*  For XGL, we display 8bit raster in a 24bit window, so  */
         /*  rather than converting the window to 8bit, instruct hsurf  */
         /*  to ignore the hardware zbuffer, so that it will generate an  */
         /*  8bit raster image, and leave the window 24bit  */

#        if defined (XGL)
            HSactivate_window (gpipe_no);
            active_window->ignore_locked_zbuffer = TRUE;
#        else
            HSconvert_to_indexed_context( w_no, gragad_id, gragad_os );
#        endif

#        if DEBUG
         printf (" CONVERTING WINDOW %d\n", shading_style);
#        endif
         }
      else
         {
         if (!(tiling_parms.processing_mode & HS_PMODE_DEXEL) &&
             !(tiling_parms.processing_mode & HS_FEM_MODE))
            {

            /*  In XGL, hsurf never converts the window to 8bit, so  */
            /*  all we have to do is toggle the ignore flag back to  */
            /*  FALSE  */

#           if defined (XGL)
               active_window->ignore_locked_zbuffer = FALSE;
#           else
               HSrestore_window_context( w_no, gragad_id, gragad_os );
#           endif
            }
         }

      /*
       * Reset the gpipe_no to that in the active window structure because
       * the above functions might change it
       */

      if (active_window != NULL) gpipe_no = active_window->pipe_no;
      }

   /**** reset the tiler status ****/
   HSset_status (HSSTAT_OK);

   /**** get an active window structure for the window ****/
   HSactivate_window (gpipe_no);
   if (tiling_parms.status != HSSTAT_OK) goto wrapup;

   active_window->shading_style = shading_style;

   active_window->vs_no = (int) lscreen_no;
   active_window->win_no = w_no;

   if (DPdlist_feedback_in_progress)
      {
      /* setup to feedback triangle meshes */
      active_window->context_no = WL_DEFAULT_CONTEXT;
      active_window->type = HShardware_LB_EG | HShardware_ZB_24;
      active_window->making_triangles = TRUE;
      active_window->active_zbuffer = 0;
      HSinitialize_active_window_for_dlist ();
      goto wrapup;
      }

   WLget_window_base_context (w_no, &active_window->context_no);
   WLget_native_info (w_no, active_window->context_no, &native_info);
   active_window->hwin_no = native_info.base_win;

   /**** if rendering, initialize the active window for rendering ****/
   if (tiling_parms.processing_mode & HS_PMODE_RENDER_IMAGE)
      {
      HSinitialize_active_window_for_rendering ();
      goto wrapup;
      }

   active_window->type = HScheck_hardware_support (lscreen_no,
                                                   w_no,
                                      active_window->ignore_locked_zbuffer);

#if defined( ENV5 )
   /* if on an EDGE2, create and initialize a viewing context if one hasn't */
   /* been created for this window, yet                                     */

   if ((active_window->type & HShardware_LB_EG) &&
       (active_window->EG_vc_no == UNDEFINED_VC))
      {
      DLget_EG_data (active_window->pipe_no, &active_window->EG_vc_no);
      }

   if (active_window->type & HShardware_LB_GPIPE)
      {
      DLget_GPIPE_data (active_window->pipe_no, &active_window->gpipe_id);
      }
#endif

   active_window->initialized = TRUE;

   /* set function pointers for the active window */
   HSinitialize_active_window_functions ();

   /* if buffers are not locked down, attempt to (re)allocate */
   if (!(active_window->type & HShardware_ZB_MASK) && (xdits + ydits))
      {
      HSallocate_active_window_buffers (lscreen_no, xdits, ydits);
      if (tiling_parms.status != HSSTAT_OK)
         goto wrapup;
      }

wrapup:

   return (tiling_parms.status == HSSTAT_OK);

   }    /* HSinit_shading_window */


/*---HSdelete_active_window---------------------------------------------------*/

/*
NAME
    HSdelete_active_window

DESCRIPTION
    This function removes the active window from the shading window
    list, attaches it to the free list, and frees up the buffers
    associated with it.

PARAMETERS
    none

GLOBALS USED
    active_window

NOTES
    This function assumes that the active window pointer already points to
    the window that is to be deleted.

HISTORY
    04/28/86    S.A. Rapa
       Created.
    03/01/90    C.M. Jablonski
       Modified to delete active_window instead of a given window id.
*/

void HSdelete_active_window (void)

   {
   struct HS_window_parms *prev_window;
   struct HS_window_parms *this_window;

#if defined( ENV5 )
   struct WLnative_info native_info;

#endif

#if defined( ENV5 )
   /**** enable vs swapping for the window ****/
   WLget_native_info (active_window->win_no, active_window->context_no, &native_info);
   Set_win_vs_swap (native_info.base_win, 1);
#endif

#if defined( ENV5 )
   if (active_window->type & HShardware_LB_EG)
      {
      HSdelete_EG_shading_window ();
      }
#else
   if (FALSE)
      {
      ;
      }
#endif
#if defined( OPENGL )
   else if (active_window->type & HShardware_LB_OPENGL)
      {
      HSdelete_OPENGL_shading_window ();
      }
#endif
#if defined( XGL )
   else if (active_window->type & HShardware_LB_XGL)
      {
      HSdelete_XGL_shading_window ();
      }
#endif
#if defined( ENV5 )
   else if (active_window->type & HShardware_LB_GPIPE)
      {
      HSdelete_GPIPE_shading_window ();
      }
#endif

   /* free the window's buffers */
   if (active_window->zbuf)
      {
      HSfree_active_window_buffers ();
      }

   /* remove active window from shading list */
   prev_window = NULL;
   this_window = shading_window_list;

   while ((this_window) && (this_window != active_window))
      {
      prev_window = this_window;
      this_window = this_window->next;
      }

   if (this_window)
      {
      if (prev_window)
         {
         prev_window->next = this_window->next;
         }
      else
         {
         shading_window_list = this_window->next;
         }

      /* add the deleted window to the free list */
      this_window->next = free_window_list;
      free_window_list = this_window;
      }

   /* reset active_window */
   active_window = NULL;
   }    /* HSdelete_active_window */


/*---HSset_active_transformation----------------------------------------------*/

/*
NAME
    HSset_active_transformation

DESCRIPTION
    This function sets the transformation matrix of the active window.

PARAMETERS
    xform (IN) - the transformation to set

GLOBALS USED
    active_window

NOTES
    This function assumes that the active window pointer already points to
    the window that is to have its transformation matrix set.

HISTORY
    04/02/90    C. M. Jablonski
       Creation Date
*/

void HSset_active_transformation (IGRdouble xform[4][4])

   {
   memcpy (active_window->transform_matrix, xform, sizeof (IGRdouble) * 16);
   }


/*---HSset_active_rotation----------------------------------------------------*/

/*
NAME
    HSset_active_rotation

DESCRIPTION
    This function sets the rotation matrix of the active window.

PARAMETERS
    rot (IN) - the rotation matrix to set

GLOBALS USED
    active_window

NOTES
    This function assumes that the active window pointer already points to
    the window that is to have its transformation matrix set.

HISTORY
    04/02/90    C.M. Jablonski
       Creation Date
*/

void HSset_active_rotation (IGRdouble rot[4][4])

   {
   active_window->rotate_matrix[0][0] = rot[0][0];
   active_window->rotate_matrix[0][1] = rot[0][1];
   active_window->rotate_matrix[0][2] = rot[0][2];

   active_window->rotate_matrix[1][0] = rot[1][0];
   active_window->rotate_matrix[1][1] = rot[1][1];
   active_window->rotate_matrix[1][2] = rot[1][2];

   active_window->rotate_matrix[2][0] = rot[2][0];
   active_window->rotate_matrix[2][1] = rot[2][1];
   active_window->rotate_matrix[2][2] = rot[2][2];
   }


/*---HSset_active_lights------------------------------------------------------*/

/*
NAME
    HSset_active_lights

DESCRIPTION
    This function sets the light sources of the active window.

PARAMETERS
    lights (IN) - the light sources to set

GLOBALS USED
    active_window

NOTES
    This function assumes that the active window pointer already points to
    the window that is to have its lights set.

HISTORY
    04/02/90    C. M. Jablonski
       Creation Date
*/

void HSset_active_lights (struct HS_light_source lights[MAX_LIGHTS])

   {
   IGRint ii, num = 0;

   /* copy all active lights to the window light source array */
   for (ii = 0; ii < MAX_LIGHTS; ii++)
      {
      if (lights[ii].flags & HS_LIGHT_ENABLED)
         {
         memcpy (&active_window->light_sources[num], &lights[ii], sizeof (struct HS_light_source));
         num++;
         }
      }

   active_window->num_lights = num;
   }


/*---HSset_active_perspective_scales------------------------------------------*/

/*
NAME
    HSset_active_perspective_scales

DESCRIPTION
    This function sets the perspective scale values for the window.

PARAMETERS
    x_scale (IN) - the perspective x scale
    y_scale (IN) - the perspective y scale
    z_scale (IN) - the perspective z scale

GLOBALS USED
    active_window

NOTES
    This function assumes that the active window pointer already points to
    the window that is to have its perspective scale factors set.

HISTORY
    04/02/90  Created            C. M. Jablonski
*/

void HSset_active_perspective_scales (IGRdouble x_scale,
                                           IGRdouble y_scale,
                                           IGRdouble z_scale)

   {
   active_window->persp_x_scale = x_scale;
   active_window->persp_y_scale = y_scale;
   active_window->persp_z_scale = z_scale;
   }


/*---HSset_dit_clip_range-----------------------------------------------------*/

/*
NAME
    HSset_dit_clip_range

DESCRIPTION
    This function sets the clip range for the window.

PARAMETERS
    clip_range (IN) - the dit clip range to set

GLOBALS USED
    active_window

NOTES
    This function assumes that the active window pointer already points to
    the window that is to have its dit clip range set.

HISTORY
    04/02/90    C. M. Jablonski
       Creation Date
*/

void HSset_dit_clip_range (IGRdouble clip_range[6])

   {
   memcpy (active_window->dit_clip_range, clip_range, sizeof (IGRdouble) * 6);
   }


/*---HSset_active_z_range-----------------------------------------------------*/

/*
NAME
    HSset_active_z_range

DESCRIPTION
    This function sets the z range of the active window.

PARAMETERS
    z_min (IN) - the minimum Z for the window
    z_max (IN) - the maximum Z for the window

GLOBALS USED
    active_window

NOTES
    This function assumes that the active window pointer already points to
    the window that is to have its Z range set.

HISTORY
    04/02/90    C. M. Jablonski
       Creation Date
*/

void HSset_active_z_range (IGRdouble z_min, IGRdouble z_max)

   {
   active_window->z_min = z_min;
   active_window->z_max = z_max;
   }


/*---HSsetup_shading_window---------------------------------------------------*/

/*
NAME
    HSsetup_shading_window

DESCRIPTION
    This function sets those window parameters that may change
    on a per-update basis.

PARAMETERS
    wld_to_view (IN) - the world to view matrix of the window
    vw_vol (IN) - the view volume of the window
    eye_pt (IN) - the eye point of the window (for perspective)
    vrp (IN) - the view reference point of the window (for perspective)
    vpn (IN) - the view plane normal of the window (for perspective)
    vup (IN) - the view up vector of the window (for perspective)
    pipe_no (IN) - the gpipe number of the window
    win_no (IN) - the window number of the window
    org_x (IN) - the x origin of the window in pixels
    org_y (IN) - the y origin of the window in pixels
    x_dits (IN) - the x size of the window in pixels
    y_dits (IN) - the y size of the window in pixels
    fit_range (IN) - the fit range of the window
    clip_range (IN) - the dit clip range of the window
    transformation_matrix (IN) - the transformation (world-to-viewport) matrix of the window
    rotation_matrix (IN) - the rotation matrix of the window
    global_lights (IN) - the lights for the window
    ambient_light (IN) - the ambient light for the window
    max_shade_near (IN) - near depth cue intensity for the window
    max_shade_far (IN) - far depth cue intensity for the window
    world_to_viewport_scale (IN) - world to viewport scale for the window
    x_persp_scale (IN) - X perspective scale for the window
    y_persp_scale (IN) - Y perspective scale for the window
    z_persp_scale (IN) - Z perspective scale for the window
    perspective (IN) - flag indicating whether the window is in perspective
    grid (IN) - flag indicating whether the grid is on in the window
    depth_cueing (IN) - flag indicating whether depth cueing is on for the window
    can_use_edge2 (IN) - flag indicating whether edgeII capabilities can be used

GLOBALS USED
    active_window
    tiling_parms.processing_mode

HISTORY
    xx/xx/xx    Unknown
       Creation Date
     04/05/90    C.M. Jablonski
       Restructured and cleaned up.
*/

void HSsetup_shading_window (
                                  IGRdouble wld_to_view[4][4],
                                  IGRdouble vw_vol[6],
                                  IGRdouble eye_pt[3],
                                  IGRdouble vrp[3],
                                  IGRdouble vpn[3],
                                  IGRdouble vup[3],
                                  IGRint pipe_no,
                                  IGRint win_no,
                                  IGRint org_x,
                                  IGRint org_y,
                                  IGRint x_dits,
                                  IGRint y_dits,
                                  IGRdouble * fit_range,
                                  IGRdouble * clip_range,
                                  IGRdouble transformation_matrix[4][4],
                                  IGRdouble rotation_matrix[4][4],
                           struct HS_light_source global_lights[MAX_LIGHTS],
                                  struct HS_light_source * ambient_light,
                                  IGRdouble max_shade_near,
                                  IGRdouble max_shade_far,
                                  IGRdouble world_to_viewport_scale,
                                  IGRdouble x_persp_scale,
                                  IGRdouble y_persp_scale,
                                  IGRdouble z_persp_scale,
                                  IGRint perspective,
                                  IGRint grid,
                                  IGRint depth_cueing,
                                  IGRboolean can_use_edge2)

   {
   IGRdouble slope;
   IGRdouble z_min, z_max;
   IGRdouble local_matrix[4][4];


/*======================================================================

fprintf( stderr, "HSsetup_shading_window:\n" );

fprintf( stderr, "   wld_to_view: " );
if( wld_to_view )
   {
   fprintf( stderr, "\n" );
   fprintf( stderr, "      %f %f %f %f\n",
      wld_to_view[0][0], wld_to_view[0][1],
      wld_to_view[0][2], wld_to_view[0][3] );
   fprintf( stderr, "      %f %f %f %f\n",
      wld_to_view[1][0], wld_to_view[1][1],
      wld_to_view[1][2], wld_to_view[1][3] );
   fprintf( stderr, "      %f %f %f %f\n",
      wld_to_view[2][0], wld_to_view[2][1],
      wld_to_view[2][2], wld_to_view[2][3] );
   fprintf( stderr, "      %f %f %f %f\n",
      wld_to_view[3][0], wld_to_view[3][1],
      wld_to_view[3][2], wld_to_view[3][3] );
   }
else
   fprintf( stderr, "NULL: \n" );

fprintf( stderr, "   vw_vol: " );
if( vw_vol )
   fprintf( stderr, "%f %f %f - %f %f %f\n",
      vw_vol[0], vw_vol[1], vw_vol[2], vw_vol[3], vw_vol[4], vw_vol[5]  );
else
   fprintf( stderr, "NULL\n" );

fprintf( stderr, "   eye_pt: " );
if( eye_pt )
   fprintf( stderr, "%f %f %f\n", eye_pt[0], eye_pt[1], eye_pt[2] );
else
   fprintf( stderr, "NULL\n" );

fprintf( stderr, "   vrp: " );
if( vrp )
   fprintf( stderr, "%f %f %f\n", vrp[0], vrp[1], vrp[2] );
else
   fprintf( stderr, "NULL\n" );

fprintf( stderr, "   vpn: " );
if( vpn )
   fprintf( stderr, "%f %f %f\n", vpn[0], vpn[1], vpn[2] );
else
   fprintf( stderr, "NULL\n" );

fprintf( stderr, "   vup: " );
if( vup )
   fprintf( stderr, "%f %f %f\n", vup[0], vup[1], vup[2] );
else
   fprintf( stderr, "NULL\n" );

fprintf( stderr, "   pipe_no: %d\n", pipe_no );
fprintf( stderr, "   win_no: %d\n", win_no );
fprintf( stderr, "   org_x, org_y: %d %d\n", org_x, org_y );
fprintf( stderr, "   x_dits, y_dits: %d %d\n", x_dits, y_dits );

fprintf( stderr, "   fit_range: " );
if( fit_range )
   fprintf( stderr, "%f %f %f - %f %f %f\n",
      fit_range[0], fit_range[1], fit_range[2],
      fit_range[3], fit_range[4], fit_range[5] );
else
   fprintf( stderr, "NULL\n" );

fprintf( stderr, "   clip_range: " );
if( clip_range )
   fprintf( stderr, "%f %f %f - %f %f %f\n",
      clip_range[0], clip_range[1], clip_range[2],
      clip_range[3], clip_range[4], clip_range[5] );
else
   fprintf( stderr, "NULL\n" );

   fprintf( stderr, "   transformation_matrix\n" );
   fprintf( stderr, "      %f %f %f %f\n",
      transformation_matrix[0][0], transformation_matrix[0][1],
      transformation_matrix[0][2], transformation_matrix[0][3] );
   fprintf( stderr, "      %f %f %f %f\n",
      transformation_matrix[1][0], transformation_matrix[1][1],
      transformation_matrix[1][2], transformation_matrix[1][3] );
   fprintf( stderr, "      %f %f %f %f\n",
      transformation_matrix[2][0], transformation_matrix[2][1],
      transformation_matrix[2][2], transformation_matrix[2][3] );
   fprintf( stderr, "      %f %f %f %f\n",
      transformation_matrix[3][0], transformation_matrix[3][1],
      transformation_matrix[3][2], transformation_matrix[3][3] );

   fprintf( stderr, "   rotation_matrix\n" );
   fprintf( stderr, "      %f %f %f %f\n",
      rotation_matrix[0][0], rotation_matrix[0][1],
      rotation_matrix[0][2], rotation_matrix[0][3] );
   fprintf( stderr, "      %f %f %f %f\n",
      rotation_matrix[1][0], rotation_matrix[1][1],
      rotation_matrix[1][2], rotation_matrix[1][3] );
   fprintf( stderr, "      %f %f %f %f\n",
      rotation_matrix[2][0], rotation_matrix[2][1],
      rotation_matrix[2][2], rotation_matrix[2][3] );
   fprintf( stderr, "      %f %f %f %f\n",
      rotation_matrix[3][0], rotation_matrix[3][1],
      rotation_matrix[3][2], rotation_matrix[3][3] );

{
int	i;

for( i=0; i<MAX_LIGHTS; i++ )
{
fprintf( stderr, "   global_light: %d\n", i );
fprintf( stderr, "      target: %f %f %f\n",
   global_lights[i].target[0],
   global_lights[i].target[1],
   global_lights[i].target[2] );
fprintf( stderr, "      location: %f %f %f\n",
   global_lights[i].location[0],
   global_lights[i].location[1],
   global_lights[i].location[2] );
fprintf( stderr, "      direction: %f %f %f\n",
   global_lights[i].direction[0],
   global_lights[i].direction[1],
   global_lights[i].direction[2] );
fprintf( stderr, "      radius: %f\n", global_lights[i].radius );
fprintf( stderr, "      angle: %f\n", global_lights[i].angle );
fprintf( stderr, "      red, green, blue: %x %x %x\n",
   global_lights[i].red, global_lights[i].green, global_lights[i].blue );
fprintf( stderr, "      flags: %x\n", global_lights[i].flags );
}
}
fprintf( stderr, "   ambient: \n" );
fprintf( stderr, "      target: %f %f %f\n",
   ambient_light->target[0],
   ambient_light->target[1],
   ambient_light->target[2] );
fprintf( stderr, "      location: %f %f %f\n",
   ambient_light->location[0],
   ambient_light->location[1],
   ambient_light->location[2] );
fprintf( stderr, "      direction: %f %f %f\n",
   ambient_light->direction[0],
   ambient_light->direction[1],
   ambient_light->direction[2] );
fprintf( stderr, "      radius: %f\n", ambient_light->radius );
fprintf( stderr, "      angle: %f\n", ambient_light->angle );
fprintf( stderr, "      red, green, blue: %x %x %x\n",
   ambient_light->red, ambient_light->green, ambient_light->blue );
fprintf( stderr, "      flags: %x\n", ambient_light->flags );

fprintf( stderr, "  max_shade_near, max_shade_far: %f %f\n",
   max_shade_near, max_shade_far );
fprintf( stderr, "  world_to_viewport_scale: %f\n", world_to_viewport_scale );
fprintf( stderr, "  x_persp_scale: %f\n", x_persp_scale );
fprintf( stderr, "  y_persp_scale: %f\n", y_persp_scale );
fprintf( stderr, "  z_persp_scale: %f\n", z_persp_scale );
fprintf( stderr, "  perspective: %d\n", perspective );
fprintf( stderr, "  grid: %d\n", grid );
fprintf( stderr, "  depth_cueing: %d\n", depth_cueing );
fprintf( stderr, "  can_use_edge2: %d\n", can_use_edge2 );

======================================================================*/

   /* activate the window */
   HSactivate_window (pipe_no);

   /* set known values */
   active_window->pipe_no = pipe_no;
   active_window->win_no = win_no;
   active_window->wv_scale = world_to_viewport_scale;
   active_window->perspective = perspective;
   active_window->org_x = org_x;
   active_window->org_y = org_y;
   active_window->grid_on = grid;
   active_window->depth_cue_on = depth_cueing;
   active_window->user_notified = FALSE;

#if defined( ENV5 )
   /* disable vs swapping for the window */
   Set_win_vs_swap (active_window->win_no, 0);
#endif

   /* setup the clip range */
   HSset_dit_clip_range (clip_range);

   /* setup the transformation and rotation matrices */
   HSconvert_transformation_matrix (transformation_matrix, local_matrix);
   HSset_active_transformation (local_matrix);
   HSconvert_rotation_matrix (rotation_matrix, local_matrix);
   HSset_active_rotation (local_matrix);

   /*
    * Set up depth cue parameters; remember that, when depth cues are
    * applied, the minimum z is already subtracted off from the vertices.
    * Thus z's will range from [0.0 - 1.0] for perspective and [0.0 - (dcr[5]
    * - dcr[2])] for parallel projections.  NOTE: depth cues are defined
    * relative to the window clipping range, and are NOT affected by the
    * z_min and z_max values in active_window.
    */

   if (depth_cueing)
      {
      slope = (max_shade_far - max_shade_near);
      if (!perspective)
         slope /= (active_window->dit_clip_range[5] -
                   active_window->dit_clip_range[2]);

      active_window->depth_cue_base = max_shade_near / 255.0;
      active_window->depth_cue_delta = slope / 255.0;
      }


   /*
    * Set the active z range, (the range of Z values that can be represented
    * by the Z-buffer for window: z_min to z_max).
    */

   if (active_window->perspective)
      {
      HSset_active_perspective_scales (x_persp_scale, y_persp_scale, z_persp_scale);
      HSset_active_z_range (active_window->dit_clip_range[2], active_window->dit_clip_range[5]);
      }
   else
      {
      if ((fit_range == NULL) ||
          ((active_window->type & HShardware_LB_GPIPE) &&
           (!(tiling_parms.processing_mode & HS_PMODE_RENDER_IMAGE))))
         {
         HSset_active_z_range (active_window->dit_clip_range[2], active_window->dit_clip_range[5]);
         }
      else
         {
         /* calculate a reasonable z_max, z_min for the window */
         HScalc_window_z_range (fit_range, &z_min, &z_max);
         HSset_active_z_range (z_min, z_max);
         }
      }

   /*
    * If we are going to be using the EG library, setup the viewing context
    * and set the function pointers.
    */

#if defined( ENV5 )
   if ((!(tiling_parms.processing_mode & HS_PMODE_RENDER_IMAGE)) &&
       (active_window->type & HShardware_LB_EG))
      HSsetup_EG_window (wld_to_view, vw_vol, eye_pt, vrp, vpn, vup, x_dits, y_dits, TRUE);
#endif

#if defined( OPENGL )
   if ((!(tiling_parms.processing_mode & HS_PMODE_RENDER_IMAGE)) &&
       (active_window->type & HShardware_LB_OPENGL))
      HSsetup_OPENGL_window (wld_to_view, vw_vol, eye_pt, vrp, vpn, vup, x_dits, y_dits, TRUE);
#endif

#if defined( XGL )
   if ((!(tiling_parms.processing_mode & HS_PMODE_RENDER_IMAGE)) &&
       (active_window->type & HShardware_LB_XGL))
      HSsetup_XGL_window (wld_to_view, vw_vol, eye_pt, vrp, vpn, vup, x_dits, y_dits, TRUE);
#endif


   /* If making triangles, get the View vector (in world coordinates) */
   if (active_window->making_triangles)

      {

      /*
       * Take the world-to-view rotation's inverse to get the view vector in
       * world coordinates
       */
      HScalc_world_view_vector (rotation_matrix, active_window->perspective, eye_pt);
      }

#if defined( ENV5 )

   /*
    * If we are going to be using GPIPE, setup there.
    */

   if ((!(tiling_parms.processing_mode & HS_PMODE_RENDER_IMAGE)) &&
       (active_window->type & HShardware_LB_GPIPE))
      HSsetup_GPIPE_window (clip_range, transformation_matrix, eye_pt);

#endif

   /* set light sources for this window */
   HSsetup_window_lights (global_lights, ambient_light);

   /*
    * See if z/color buffers must be reallocated for this window
    */

   (*active_window->init_window[active_window->active_zbuffer]) (x_dits, y_dits);

#if defined( ENV5 )
   if (active_window->unsupported_zbuffer_allocated)
      (*active_window->init_window[1]) (x_dits, y_dits);

#endif

   }

/*---HSwindow_initialized--------------------------------------*/

IGRboolean HSwindow_initialized (IGRint pipe_no)

/*
NAME
    HSwindow_initialized

DESCRIPTION
    Return the initialized status of the given window.

PARAMETERS
    pipe_no: (IN): logical window number

GLOBALS USED
    active_window

HISTORY
    ??/??/??    ???
        Created
*/

   {
   HSactivate_window (pipe_no);

   if (active_window != NULL)
      return (active_window->initialized);
   else
      return (FALSE);

   }    /* HSwindow_initialized */
