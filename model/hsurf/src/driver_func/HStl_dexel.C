
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:37 $
$Locker:  $
*/

#include <stdio.h>

#include "wl.h"

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
#include "hsmacdef.h"
#include "hsmacros.h"
#include "hnsimulate.h"

#include "HStl_global.h"
#include "HStl_window.h"
#include "HStl_element.h"

#include "HSe2_mesher.h"
#include "HSpr_driver.h"

#include "igecolmacros.h"

/* External Variables */

extern void                NCsave_trap();
extern void                NCsetup_shading_window();
extern void                HSinitialize_buffers();

extern struct NC_sim_data  NCsim_data;

/* Local Variables */

static void        (*rasterizer)();
static IGRdouble   saved_dcr[6];
static IGRdouble   saved_z_min;
static IGRdouble   saved_z_max;
static IGRboolean  env_obj_finished = FALSE;
static HScbuf      *local_cbuf = NULL;
   

/*----------------------------------------------------------------------------*/

void HSenable_dexels( IGRint window_no )

/*
 * ABSTRACT:   HSenable_dexels kicks the tiler into dexel mode by set
 *      the tiling_parms.processing_mode dexel flag, and changing the
 *           rasterizer on the active window.
 *  
 * HISTORY:   04/26/88   Created.         C. M. Jablonski
 *
 */

{
   HSactivate_window( window_no );   /* ignore returned status */

   /* save the clip range */
   saved_dcr[0] = active_window->dit_clip_range[0];
   saved_dcr[1] = active_window->dit_clip_range[1];
   saved_dcr[2] = active_window->dit_clip_range[2];
   saved_dcr[3] = active_window->dit_clip_range[3];
   saved_dcr[4] = active_window->dit_clip_range[4];
   saved_dcr[5] = active_window->dit_clip_range[5];
   saved_z_min = active_window->z_min;
   saved_z_max = active_window->z_max;
   
   /* set maximum_z to scale to 16-bit (short) z_values */
   HSset_maximum_z( 65535.0 );
   
   /* save and reset global information */
   rasterizer = active_window->rasterizer[active_window->active_zbuffer];

   active_window->rasterizer[active_window->active_zbuffer] = NCsave_trap;

   HSset_dexel_mode( TRUE );

   /* set the env_obj_finished flag */
   env_obj_finished = FALSE;
}


/*----------------------------------------------------------------------------*/

void HSsetup_nc_window( IGRint     window_no,
                        IGRdouble  *rng_ptr )

/*
 * ABSTRACT:   HSsetup_nc_window calls NCsetup_shading_window with the
 *             parameters to initialize the NC data structures, and may adjust
 *             the window's z range.
 *
 * HISTORY:   08/19/88   Created.         C. M. Jablonski
 */
 
{
   IGRdouble             tol;
   IGRdouble             z1;
   IGRdouble             z2;
   IGRint                y;
   HScbuf                *cb;
   IGRboolean            was_null = FALSE;
   WLuint16              lscreen_no;
   int                   screen_type;
   WLuint32              context_no;
   struct WLraster_data  image;
   int                   pixel_size;


   WLget_raster_size( active_window->win_no, 1, 1, &pixel_size);

   /* save the clip range */
   saved_dcr[0] = active_window->dit_clip_range[0];
   saved_dcr[1] = active_window->dit_clip_range[1];
   saved_dcr[2] = active_window->dit_clip_range[2];
   saved_dcr[3] = active_window->dit_clip_range[3];
   saved_dcr[4] = active_window->dit_clip_range[4];
   saved_dcr[5] = active_window->dit_clip_range[5];
   saved_z_min = active_window->z_min;
   saved_z_max = active_window->z_max;
   
   /* if a range was supplied, adjust the z-range */
   if (rng_ptr)
   {
      HScalc_window_z_range( rng_ptr, &z1, &z2 );
      HSset_active_z_range( z1, z2 );
   }

   hs$get_shading_tolerance( tolerance = (&tol) );
   
   /* if locked-down z_buffer, update buffers */
   if (active_window->type & HShardware_ZB_MASK)
   {
      /* if no buffer, allocate it */
      if (was_null = (active_window->cbuf == NULL))
      {
         active_window->cbuf = local_cbuf =
                          (HScbuf *)malloc((unsigned)active_window->x_dits *
                                            active_window->y_dits *
                                            sizeof(HScbuf)); 
               
         if( !active_window->cbuf )
         {
            fprintf(stderr, "HSURF: Can't allocate image buffer memory\n" );
            return;
         }
      }

      /* update the cbuf */
      cb = active_window->cbuf;

      WLcreate_raster_data( active_window->win_no,
                            active_window->context_no,
                            &image,
                            0,
                            0,
                            active_window->x_dits,
                            active_window->y_dits,
                            pixel_size * 8,
                            WL_FAST_BUFFER,
                            (char *)cb );

      WLget_raster_data( active_window->win_no,
                         active_window->context_no,
                         &image );

   }

   NCsetup_shading_window ( active_window->pipe_no,
                            active_window->win_no,
                            tol / active_window->wv_scale,
                            (tiling_parms.maximum_z / 
                                 (active_window->z_max - active_window->z_min)),
                            (active_window->type & HShardware_CP_ASAP1),
                            tiling_parms.processing_mode & HS_PMODE_DIRECT,
                            CONST_SHADE,
                            SMOOTH_SHADE,
                            active_window->cbuf,
                            active_window->org_x,
                            active_window->org_y,
                            active_window->x_dits,
                            active_window->y_dits );

   if (was_null)
   {
      active_window->cbuf = NULL;
   }
}


/*----------------------------------------------------------------------------*/

void HSget_dexel_facet_parms( IGRint      *color,
                              IGRint      *facet_type,
                              IGRboolean  *front_facing )

/*
 * ABSTRACT:   HSget_dexel_display_parms returns the active color and facet
 *      type.
 *
 * HISTORY:   08/19/88   Created.         C. M. Jablonski
 */

{
   if( IGEget_using_ramp_mode())
   {
      *color = element_parms.color;
   }
   else
   {
      *color = element_parms.color_logical;
   }

   *facet_type = element_parms.facet_type;

   if (env_obj_finished)
   {
      *front_facing = element_parms.front_facing_facet;
   }
   else
   {
      *front_facing = ((element_parms.surf_geom->pos_orient) &&
                       !(element_parms.front_facing_facet)) ||
                      (!(element_parms.surf_geom->pos_orient) &&
                        (element_parms.front_facing_facet));
   }
}


/*----------------------------------------------------------------------------*/

void HSset_dexel_color( IGRboolean  change_color,
                        IGRint      color,
                        IGRint      *index )

/*
 * ABSTRACT:   HSchange_dexel_color returns index values for colors.  If the
 *             change_color flag is TRUE, color becomes the active color. If
 *             it is FALSE, color is ignored.  In either case, active color
 *             is returned as the index parameter.  NOTE: color is assumed
 *             to be an UNMODIFIED database value, so we need to translate it
 *             ourselves (not call get_color_index).
 *
 * HISTORY:   07/27/88   Created.         C. M. Jablonski
 *            07/29/92   send in logical color for PSUEDO
 *                       TRUE COLOR because that is what it
 *                       accepts now.         J. D. Underwood
 *
 */

{
   if (change_color)
   {
      HSset_element_color( color );
   }

   if( IGEget_using_ramp_mode())
   {
      *index = element_parms.color;
   }
   else
   {
      *index = element_parms.color_logical;
   }
}


/*----------------------------------------------------------------------------*/

void HSset_dexel_shading_style( unsigned int style )


/*
 * ABSTRACT:   HSset_dexel_shading_style sets the current shading style.
 *
 * HISTORY:   08/20/88   Created.         C. M. Jablonski
 *
 */
 
{
   HSset_element_facet_type( style );
}


/*----------------------------------------------------------------------------*/

void HSadjust_dexels( IGRint *shades,
                      IGRint x_min,
                      IGRint y_min,
                      IGRint x_max,
                      IGRint y_max )

/*
 * ABSTRACT:   HSadjust_dexels reconfigures the tiler to generate swept-volume
 *             tiles.  This includes changing the active color, adjusting the
 *             clip range and changing the rasterizer.  This routine is called
 *             after the workpiece has been processed in order to set the color
 *             for the tool.
 *
 * HISTORY:
 *
 */
 
{
   IGRdouble   range[6];


   /* set display values */
   *shades = tiling_parms.apparent_shades;
 
   /* turn off culling */
   HSset_element_cull_flag( HS_CULL_NONE );
   
   if( NCsim_data.simulation_mode )
   {
      range[0] = saved_dcr[0];
      range[1] = saved_dcr[1];
      range[3] = saved_dcr[3];
      range[4] = saved_dcr[4];
   }
   else
   {
      /* x,y extents for swept volume (Tool is not displayed) */
      /* reduce the clip range to the range of the workpiece */
      range[0] = (double)x_min;
      range[1] = (double)y_min;
      range[3] = (double)x_max;
      range[4] = (double)y_max;
   }
    
   range[2] = active_window->dit_clip_range[2];
   range[5] = active_window->dit_clip_range[5];

   HSset_ele_clip_range( range );
   HSset_dit_clip_range( range );

   /* set the env_obj_finished flag */
   env_obj_finished = TRUE;
}

 
/*----------------------------------------------------------------------------*/

   void HSdisable_dexels(void)


/*
 * ABSTRACT:   HSdisable_dexels kicks the tiler out of dexel mode by setting
 *      the tiling_parms.dexel_mode flag to FALSE and restoring all tiler
 *      flags to their original state.
 *
 * HISTORY:   04/26/88   Created.         C. M. Jablonski
 *
 */

{
   IGRdouble   range[6];

   /* delete allocated cbuf */
   if (local_cbuf)
   {
      free( local_cbuf );
      local_cbuf = NULL;
   }

   /* reset window information */
   if (active_window)
   {
      range[0] = saved_dcr[0];
      range[1] = saved_dcr[1];
      range[2] = saved_dcr[2];
      range[3] = saved_dcr[3];
      range[4] = saved_dcr[4];
      range[5] = saved_dcr[5];

      HSset_dit_clip_range( range );

      active_window->rasterizer[active_window->active_zbuffer] = rasterizer;

      HSset_active_z_range( saved_z_min, saved_z_max );
   }

   /* reset global information */
   HSset_maximum_z( 2147483640.0 );
   HSset_dexel_mode( FALSE );
}

 
/*----------------------------------------------------------------------------*/

void HSadd_dexel_vertex( IGRdouble  x,
                         IGRdouble  y,
                         IGRdouble  z,
                         IGRdouble  w,
                         IGRdouble  nx,
                         IGRdouble  ny,
                         IGRdouble  nz )


/*
 * ABSTRACT:   HSadd_dexel_vertex adds another vertex to the current facet
 *      loop being constructed.
 *
 * HISTORY:   05/15/88   Created.         C. M. Jablonski
 *
 */

{
   if (element_parms.doing_vertex_normals)
   {
      add_vertex_to_loop( x, y, z, w, FALSE, nx, ny, nz );
   }
   else
   {
      add_vertex_to_loop( x, y, z, w, FALSE );
   }
}
 
/*----------------------------------------------------------------------------*/

IGRboolean HScheck_dexel_memory( IGRint total_bytes )

/*
 * ABSTRACT:   HScheck_dexel_memory returns TRUE if total_bytes are available
 *      from the current pool, FALSE otherwise.
 *
 * HISTORY:   05/15/88   Created.         C. M. Jablonski
 *
 */

{
   return( TRUE );
}

 
/*----------------------------------------------------------------------------*/

void HSrestore_dexel_memory( IGRint total_bytes )


/*
 * ABSTRACT:   HSrestore_dexel_memory resets the memory flags
 *
 * HISTORY:   06/08/88   Created.         C. M. Jablonski
 *
 */

{

}

