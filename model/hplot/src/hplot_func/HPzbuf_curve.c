#include <stdlib.h>
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
#include "grdpbdef.h"
#include "DEso.h"

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

/*-----------------------------
 *  for
 *    CHT
 *    HSbcurve_tiler
 *    HSset_element_weights
 *    HSset_line_style
 */

#include "HSe2_mesher.h"
#include "HSpr_tiler_f.h"

/*----------------------------*/



static int ccount = 0;

static double *boundary = NULL;
static int boundary_size = 0;

static int num_soos;
static struct HPsoo_info *soos;
static struct IGRbsp_curve curve = {
                  0,      /* order          */
                  0,      /* periodic       */
                  0,      /* non_uniform    */
                  0,      /* num_poles      */
                  NULL,   /* *poles         */
                  0,      /* num_knots      */
                  NULL,   /* *knots         */
                  0,      /* rational       */
                  NULL,   /* *weights       */
                  0,      /* planar         */
                  0,      /* phy_closed     */
                  0,      /* num_boundaries */
                  NULL};  /* *bdrys         */


/*---PLOT_CURVE------------------------------------------------------------*/

/*
NAME
   PLOT_CURVE: macro
        
KEYWORDS
   HSplot
   curve
   macro
        
DESCRIPTION
   Set the appropriate color, weight and style, then call the
   curve tiler
        
PARAMETERS
   colr   : active color
   wait   : active weight
   styl   : active style
        
GLOBALS USED
   HPcommand_line         : global structure
      black_and_white_edge: If the edges are to be black and white
      white_background    : If the background is to be white or colored
   HPglobal               : global structure
      color_table         : plotting colortable
      hsym                : hidden symbology parameters
      element_parms       : global structure
      color               : active color for the edge
      tiling_parms        : global structure
      processing_mode     : Set the "display hidden edges" flag, or not
   HPband_info            : global structure
      pipe_node           : gpipe id
      accuracy            : tiling accuracy
      acc_mode            : accuracy mode or not flag
                
FUNCTIONS CALLED
   HSset_line_style
   HSset_element_weights
   HSbcurve_tiler
*/

#define   PLOT_CURVE( colr, wait, styl )                                   \
                                                                           \
   {                                                                       \
   pndx = 0;                                                               \
                                                                           \
   if( !HPglobal.black_and_white_edges )                             \
      {                                                                    \
      if( (unsigned)HPglobal.color_table[colr][0] > 0x7f00 )  pndx |= 4;   \
      if( (unsigned)HPglobal.color_table[colr][1] > 0x7f00 )  pndx |= 2;   \
      if( (unsigned)HPglobal.color_table[colr][2] > 0x7f00 )  pndx |= 1;   \
      }                                                                    \
   else                                                                    \
      pndx = HPglobal.white_background ? 0 : 7;                      \
                                                                           \
   if( pndx == 14 ) pndx = 0;                                              \
                                                                           \
   if( pndx == 7 )                                                         \
      if( ( (unsigned)HPglobal.color_table[colr][0] > 0x7f00 ) &&          \
          ( (unsigned)HPglobal.color_table[colr][1] > 0x7f00 ) &&          \
          ( (unsigned)HPglobal.color_table[colr][2] > 0x7f00 ) ) pndx = 0; \
                                                                           \
   element_parms.color = pndx + 240;                                       \
                                                                           \
   if( HPglobal.display_hidden_edges )                                     \
      tiling_parms.processing_mode |= HS_PMODE_DISPLAY_HIDDEN_LINES;       \
                                                                           \
   if( HPglobal.hsym.flags & DPB_USE_ORIG_COLOR ||                         \
            HPglobal.black_and_white_edges )                         \
      element_parms.hidden_color = element_parms.color;                    \
   else                                                                    \
      element_parms.hidden_color = HPglobal.hsym.color + 240;              \
                                                                           \
   if( HPglobal.hsym.flags & DPB_USE_ORIG_STYLE )                          \
      HSset_line_style( (styl), (styl) );                                  \
   else                                                                    \
      HSset_line_style( (styl), HPglobal.hsym.style );                     \
                                                                           \
                                                                           \
   if( HPglobal.hsym.flags & DPB_USE_ORIG_WEIGHT )                         \
      HSset_element_weights( (wait), (wait) );                             \
   else                                                                    \
      HSset_element_weights( (wait), HPglobal.hsym.weight );               \
                                                                           \
   HSbcurve_tiler(                                                         \
      HPband_info.pipe_no,                                                 \
      &curve,                                                              \
      element_parms.color,                                                 \
      option,                                                              \
      TRUE,                                                                \
      HPband_info.acc_mode,                                                \
      HPband_info.accuracy,                                                \
      tolerance,                                                           \
      NULL );                                                              \
   }

/*---HPzbuffered_curve------------------------------------------------------*/

/*
NAME
   HPzbuffered_curve
        
KEYWORDS
   HSplot
   curve
        
DESCRIPTION
   Read a curve from the shaded plotfile and send it to the tiler,
   in pieces if there is an override, for processing.
        
PARAMETERS
   file_ptr    :(IN) : File pointer for the shaded plot file.  Current
                       location is the active curve
   curve_count :(IN) : Counter of curves
   object_type :(IN) : The type of curve being processed
        
GLOBALS USED
   HPband_info         : global structure
      pipe_no          : gpipe id
   HPglobal            : global structure
      tiling_tolerance :
      rendering_mode   :
      debug            :
      overlap          : Number of scanlines, bands overlap
      active_window    : global structure
      shading_style    :
      tiling_parms     : global structure
      processing_mode  :
      status           : tiler status
      element_parms    : global structure
      ele_clip_range   : viewport range
                
FUNCTIONS CALLED
   read_nurb_curve
   CHT
   PLOT_CURVE
   HPtiming_start
   HPtiming_stop
        
HISTORY
   ??/??/??   M. Lanier
      Created
*/


int HPzbuffered_curve( FILE *file_ptr, int curve_count, int object_type )

   {
   IGRint     pndx;
   IGRdouble  tolerance, range[6];
   IGRint     i, j, status;
   IGRdouble  CHT ();
   IGRint     option;
   IGRboolean raster_edges = TRUE;

   HPtiming_start (4);

   /*
    *  check for new or old style curve/edge's
    */
    
   if( object_type == NURB_CURVE || object_type == NURB_EDGE )
      num_soos = 1;
   else
      num_soos = 0;
      
   status = read_nurb_curve( file_ptr, 3, &curve, &num_soos, &soos );

   if( status ) return (HSplot_error);

   for( i=0; i<6; i++ ) range[i] = 0.0;
   
   tolerance = CHT( HPband_info.pipe_no,
                    HPglobal.tiling_tolerance,
                    range );

   option = 0;

   switch( HPglobal.rendering_mode )
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
         }

   /*
    * if the object is not raster edges, move the viewport bounds back inside
    * the overlap region.  No need to process that data twice. If it is
    * raster edges and in a band other than the first, move the top clip line
    * in two overlap widths.  This region was set by copying data from the
    * previos zbuffer
    */

   if( !raster_edges )
      {
      element_parms.ele_clip_range[0] += HPglobal.overlap;
      element_parms.ele_clip_range[3] -= HPglobal.overlap;
      }

   if( HPglobal.debug )
      {
      if( ((++ccount) % (HPglobal.debug)) == 0 )
         fprintf( stderr, "Tile curve   #%-5d     (%1d:%1d) (%1d)\n",
            curve_count, HPglobal.objid, HPglobal.osnum, ccount );
      }
   else
   if( HPglobal.flags & HPpflag_FEEDBACK_OBJID )
      {
      fprintf( stderr, "Process curve   : (%1d:%1d)\n",
         HPglobal.objid, HPglobal.osnum );
      }


   if( num_soos > 0 )
      {

      /*
       * Allocate memory for the soo boundary buffer.  put all soo boundary
       * points in the buffer and send to the tiler to plot the original
       * curve with the boundary spans out.
       */

      if( num_soos > boundary_size )
         {
         if( boundary != NULL ) free( boundary );
         boundary = (double *)malloc( sizeof(double) * ((2 * num_soos) + 2) );
         boundary_size = num_soos;
         }

      if( !(soos[0].parms[0] == 0.0 &&
            soos[0].parms[1] == 1.0) )
         {

         /* Build a boundary that turns off only the soo regions of the
          * curve. */

         for( i=0, j=0; i<num_soos; i++ )
            {
            boundary[j++] = soos[i].parms[0];
            boundary[j++] = soos[i].parms[1];
            }

         curve.num_boundaries = num_soos;
         curve.bdrys = boundary;

#        if DEBUG
         fprintf (stderr, "original\n");
         for( i=0, j=0; i<curve.num_boundaries; i++, j += 2 )
            fprintf( stderr, "%3d %f %f\n", i, boundary[j], boundary[j+1] );
#        endif

         PLOT_CURVE( HPglobal.active_color,
                     HPglobal.line_width,
                     HPglobal.line_style );
         }

      for( i=0; i<num_soos; i++ )
         {

         j = 0;
         curve.num_boundaries = 0;

         /*
          * If the soo does not start at the startpoint of the curve place a
          * boundary from the startpoint of the curve to the start of the
          * soo.
          */

         if( soos[i].parms[0] != 0.0 )
            {
            boundary[j++] = 0.0;
            boundary[j++] = soos[i].parms[0];
            curve.num_boundaries++;
            }

         /*
          * If the soo does not end at the end point of the curve, place a
          * boundary from the end of the soo to the endpoint of the curve
          */

         if( soos[i].parms[1] != 1.0 )
            {
            boundary[j++] = soos[i].parms[1];
            boundary[j++] = 1.0;
            curve.num_boundaries++;
            }

         /*
          * Plot the curve with the ith soo's attributes, if there is at
          * least one boundary.
          * 
          * If the soo is DE_INVIS and it's color is 0xffff, which I assume to
          * mean the invisible soo is off, don't call the tiler.  This will
          * leave a hole in the curve, which is what we want.
          */

         if( !(soos[i].type & DE_INVIS && soos[i].color == 0xffff) )
            if( tiling_parms.processing_mode & HS_PMODE_DISPLAY_HIDDEN_LINES ||
                !(soos[i].type & DE_HIDDEN) )
               {
               element_parms.hidden_color = soos[i].color;

#              if DEBUG
               fprintf( stderr, "soo #%1d\n", i );
               for( l=0, j=0; l<curve.num_boundaries; l++, j += 2 )
                  fprintf( stderr, "%3d %f %f\n", l, boundary[j], boundary[j+1] );
#              endif

               HSset_element_weights( soos[i].weight, soos[i].weight );
               HSset_line_style( soos[i].style, soos[i].style );

               PLOT_CURVE( soos[i].color,
                           soos[i].weight,
                           soos[i].style );
               }
         }
      }
   else
      {
      curve.num_boundaries = 0;
      curve.bdrys = NULL;

      PLOT_CURVE( HPglobal.active_color,
                  HPglobal.line_width,
                  HPglobal.line_style );
      }

   /* any adjustments to the viewport must be backed out */

   if (!raster_edges)
      {
      element_parms.ele_clip_range[0] -= HPglobal.overlap;
      element_parms.ele_clip_range[3] += HPglobal.overlap;
      }

   if (tiling_parms.status != HSSTAT_OK)
      {
      status = HP_I_Success;
      }

   HPtiming_stop (4);
   return (HP_I_Success);
   }
