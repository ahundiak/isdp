#include <stdio.h>
#if defined (CLIX)
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
#include "dpstruct.h"
#include "dp.h"
#include "dpdef.h"

#include "hstiler.h"
#include "hslight.h"
#include "hplot.h"
#include "hsdef.h"
#include "hpmsg.h"
#include "hsmacdef.h"
#include "hsdisplay.h"

#include "HStl_window.h"
#include "HStl_element.h"
#include "HStl_global.h"
#include "HPglobal.h"
#include "HSfem_spt.h"
#include "HPtiming.h"
#include "HPdef.h"
#include "HSd_fixedpt.h"
#include "HPpr_hplot_f.h"

/*---------------------------
 *  for
 *    CHT
 *    HSactivate_window
 *    HSbsurf_tiler
 */

#include "HSe2_mesher.h"
#include "HSpr_tiler_f.h"

/*--------------------------
 *  for function
 *     HScheck_range_with_zbuffer
 */

#include "HSpr_driver.h"

/*-------------------------------*/


#define KNOT_TOL	0.000005

static int status;

#define DEBUG	0

static struct HS_element_rendering_parms rend_parms;

static struct IGRbsp_surface surface = {
   0,		/* u_order		 */
   0,    	/* v_order		 */
   0,    	/* u_periodic		 */
   0,   	/* v_periodic		 */
   0,   	/* u_non_uniform	 */
   0,   	/* v_non_uniform	 */
   0,   	/* u_num_poles		 */
   0,   	/* v_num_poles		 */
   NULL,        /* *poles		 */
   0,   	/* u_num_knots		 */
   NULL,        /* *u_knots		 */
   0,   	/* v_num_knots		 */
   NULL,        /* *v_knots		 */
   0,   	/* rational		 */
   NULL,        /* *weights		 */
   0,   	/* planar		 */
   0,   	/* u_phys_closed	 */
   0,   	/* v_phys_closed	 */
   0,   	/* pos_orient		 */
   0,   	/* on/off		 */
   0,   	/* num_boundaries	 */
   NULL 	/* bdrys		 */
   };

static struct		IGRbsp_curve *bdrys = NULL;
static IGRint		num_bdrys = 0;
static IGRdouble	urange[2] = {0.0, 1.0};
static IGRdouble	vrange[2] = {0.0, 1.0};

static int scount = 0;

/*---HPzbuffered_surface-----------------------------------------------*/

/*
NAME
   HPzbuffered_surface
        
KEYWORDS
   HSplot
   surface
        
DESCRIPTION
   Read a surface from the shaded plotfile and send it the the
   hsurf tiler
        
PARATERMERS
   file_ptr	:(IN) : File pointer to the shaded plotfile.  Currently
                           pointing to the surface to read
   ele_range	:(IN) : range of the surface
   surface_count	:(IN) : surface counter
        
GLOBALS USED
   tiling_parms			: global structure
           status		:
           processing_mode	:
   element_parms		: global structure
           visible_weight	:
           color		:
           ele_clip_range	:
   HPglobal			: global structure
           line_width		:
           overlap		:
           debug		:
           active_color		:
           accuracy_mode	:
           accuracy		:
           tiling_tolerance:
           rendering_mode	:
   active_window		: global structure
           shading_style	:
   HPband_info			: global structure
           pipe_no		:
                
FUNCTIONS CALLED
   HPtiming_start
   read_nurb_surface
   HPconvert_surface_boundaries
   HScheck_range_with_zbuffer
   HSactivate_window
   CHT
   HSbsurf_tiler
   HPtiming_stop
   HPmessage
        
HISTORY
   ??/??/??	M. Lanier
           Created
*/

int	HPzbuffered_surface( FILE   *file_ptr,
                             double *ele_range,
                             int    surface_count )

   {
   IGRdouble	range[6];
   IGRdouble	CHT();
   IGRboolean	part_of_solid;
   IGRint	i;
   IGRint	option;
   IGRdouble	tolerance = 0.0;
   IGRboolean	raster_edges = TRUE;
   IGRint	surface_type;


   tiling_parms.status = HSSTAT_OK;

   HPtiming_start(3);

   /* Calculate the light weight for visible edges */

   element_parms.visible_weight = HPglobal.line_width;

   /*
    * Call a routine to read the surface and its boundaries from
    * the metafile.
    */

   status = read_nurb_surface ( file_ptr,
                                &surface,
                                &bdrys,
                                &num_bdrys,
                                &surface_type );

   if( status ) return( HSplot_error );

   /*
    * Convert the surface boundaries to packed boundaries in the surface
    * structure
    */

   if (surface.num_boundaries > 0)
      {
      HPconvert_surface_boundaries (&surface,
                                    bdrys,
                                    surface.num_boundaries,
                                    HPglobal.tiling_tolerance);
      }

   /*
    * Check the object range to see if its view aligned range box it totally
    * hidden by the zbuffer, and if so, exit
    */

   if (HScheck_range_with_zbuffer (&surface, ele_range))
      goto wrapup;

   /*
    * Tile the surface and rasterize
    */

   HSactivate_window (HPband_info.pipe_no);

   option = 0;

   /*
    * Eventually I will need to set range correctly in order to do
    * z-clipping.
    */

   for (i = 0; i < 6; i++) range[i] = 0.0;

   part_of_solid = FALSE;

   switch (HPglobal.rendering_mode)
      {
      case 1:
         option |= GR_BST_SMOOTH;
         raster_edges = FALSE;
         active_window->shading_style = HS_STYLE_SMOOTH;
         break;

      case 2:
         option |= GR_BST_CONSTANT;
         raster_edges = FALSE;
         active_window->shading_style = HS_STYLE_CONSTANT;
         break;

      case 3:
         option |= HS_BST_EDGES;
         tiling_parms.processing_mode &= ~HS_PMODE_RHL_SHOW_HIDDEN;
         raster_edges = TRUE;
         active_window->shading_style = HS_STYLE_RASTER;
         break;

      case 4:
         option |= HS_BST_REV_EDGES;
         tiling_parms.processing_mode &= ~HS_PMODE_RHL_SHOW_HIDDEN;
         raster_edges = TRUE;
         active_window->shading_style = HS_STYLE_FILLED_RASTER;
         break;

      case 5:
         option |= GR_BST_SOLID;
         raster_edges = FALSE;
         active_window->shading_style = HS_STYLE_AREAFILL;
         break;

         }      /* end switch */

   if (HPglobal.translucency != 0)
      {
      option |= GR_BST_TRANSP;
      if (HPglobal.trans_grid == 1)
         tiling_parms.processing_mode |= HS_PMODE_TRANS_1x1;
      else
         tiling_parms.processing_mode &= ~HS_PMODE_TRANS_1x1;
      }

   element_parms.color = HPglobal.active_color;

   if (!HPglobal.accuracy_mode)
      tolerance = CHT (HPband_info.pipe_no,
                       HPglobal.tiling_tolerance,
                       range);

   /*
    * if the object is not raster edges, move the viewport bounds back inside
    * the overlap region.  No need to process that data twice. If it is
    * raster edges and in a band other than the first, move the top clip line
    * in two overlap widths.  This region was set by copying data from the
    * previos zbuffer
    */

   if (!raster_edges)
      {
      element_parms.ele_clip_range[0] += HPglobal.overlap;
      element_parms.ele_clip_range[3] -= HPglobal.overlap;
      }

   rend_parms.surface_texture = NULL;
   rend_parms.texture_orientation = 0;

   if( !HPin_ignore_list( HPglobal.objid, HPglobal.osnum ) )
      {
      if (HPglobal.debug)
         {
         if (((++scount) % (HPglobal.debug)) == 0)
            fprintf (stderr, "Tile surface #%-5d     (%1d:%1d) (%1d)\n",
                     surface_count,
                     HPglobal.objid, HPglobal.osnum,
                     scount);
         }

      else 
      if (HPglobal.flags & HPpflag_FEEDBACK_OBJID)
         {
         fprintf (stderr, "Process surface : (%1d:%1d)\n",
                  HPglobal.objid, HPglobal.osnum);
         }

      else
      if( HPglobal.heartbeat )
         HPheartbeat();

      HSbsurf_tiler (HPband_info.pipe_no,
                     &surface,
                     range,
                     element_parms.color,
                     option,
                     0,
                     &rend_parms,
                     part_of_solid,
                     HPband_info.keyed_in_tol * HPband_info.world_to_view_scale,
                     0.0,
                     0.0,
                     0,
                     HPglobal.accuracy_mode,
                     HPglobal.accuracy,
                     tolerance,
                     urange,
                     vrange,
                     NULL);

      /*
       * any adjustments to the viewport must be backed out
       */
   
      if (!raster_edges)
         {
         element_parms.ele_clip_range[0] -= HPglobal.overlap;
         element_parms.ele_clip_range[3] += HPglobal.overlap;
         }

      /*
       * report any error that may have occured
       */

      switch (tiling_parms.status)
         {
         case -2:
            status = HP_E_RdBadMathCall;
            break;
   
         case -6:
            status = HP_E_RdDegSurface;
            break;
   
         case 100:
            status = HP_E_RdNoMemory;
            break;

         case 200:
            status = HP_E_RdBadBoundary;
            break;

         default:
            status = tiling_parms.status;
            break;
            }
         }

wrapup:
   HPtiming_stop (3);

   if (status)
      HPmessage (status, NULL, 0);

   return (HSplot_success);
   }
