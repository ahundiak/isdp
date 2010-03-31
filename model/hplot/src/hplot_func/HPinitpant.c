#include <stdio.h>
#if defined (CLIX)
#include <gpipe.h>
#endif

#include "OMminimum.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "igr.h"
#include "hplot.h"
#include "hsdef.h"
#include "HStl_global.h"
#include "HStl_window.h"
#include "HStl_element.h"
#include "HPglobal.h"
#include "hsdisplay.h"
#include "HSd_fixedpt.h"
#include "HPpr_hplot_f.h"

#define DEBUG		0
#define COLOR_MASK	0x0ffffff

void HPsmooth_shade_opaque_phong ();
void HPstart_swine7 (struct polyline_vertex *start_point);
void HPcontinue_swine7 (struct polyline_vertex *next_vertex);

/*
void	HPsmooth_shade_opaque();
void	HPsmooth_shade_trans();
void	HPconstant_shade_opaque();
void	HPconstant_shade_trans();
void	HParea_fill_opaque();
void	HParea_fill_trans();
void	HPraster_lines();
void	HPraster_edges();
void	HPsilly_lines();

void	HPtrap_radge6();
void	HPtrap_radge5();
void	HPstart_polyline();
void	HPstart_pline_radge6();
void	HPstart_pline_radge5();
void	HPcontinue_polyline();
void	HPcontinue_pline_radge6();
void	HPcontinue_pline_radge5();

void	HPstart_swine6();
void	HPstart_swine5();
void	HPstart_dzine6();
void	HPstart_dzine5();
void	HPcontinue_swine5();
void	HPcontinue_swine6();
void	HPcontinue_dzine6();
void	HPcontinue_dzine5();
*/

/*
 *  Prototype declaration for static function
 */

#if defined(__STDC__) || defined(__cplusplus)

#if defined(__cplusplus)
extern "C"
   {
#endif

   static void HPsilly_lines_stub (void);

#if defined(__cplusplus)
   }

#endif

#else

static void HPsilly_lines_stub ();

#endif

/*---HPsilly_lines_stub-------------------------------------------------------------*/

static void HPsilly_lines_stub ()
   {
   }


/*---HPinit_paint-------------------------------------------------------------------*/

/*
NAME
        HPinit_paint
        
KEYWORD
        HSplot
        initialization
        rasterizer
        
DESCRIPTION
        Sets the rasterizer function for surfaces and curve, for shaded plotting
        
PARAMETERS
        color		:(IN) : The object color
        request_code	:(IN) : Contains the shading style of the current object
        
GLOBALS USED
        tiling_parms
                number_shades: If this value is 1, then only an area fill mode is
                        value
                processing_mode: Check the flags for the don't zbuffer, and show
                        hidden options
        active_window
                rasterizer, start_polyline, continue_polyline and silouetter
                        function variable are set according to the shading style.
        HPglobal
                bytes_per_pixel: This will be 5 or 6 and will determine which
                        polyline rasterize is to be used.
        element_parms
                color: Will be set to the active color color index, referencing
                        the shaded plot colortable
                delete: In some cases will be set to FALSE.
        
HISTORY
        ??/??/??	M. Lanier
                Created
*/

#if defined(__STDC__) || defined(__cplusplus)
void HPinit_paint (IGRint * color,
                        IGRint * request_code)
#else
void HPinit_paint (color, request_code)

   IGRint *color;
   IGRint *request_code;

#endif

   {
   int transparent;

#if DEBUG
   fprintf (stderr, "HPinit_paint\n");
   fprintf (stderr, "   color ---- %d\n", *color);
   fprintf (stderr, "   request -- %x\n", *request_code);
#endif

   /*
    * Check the transparent bit then clear it
    */

   if (*request_code & GR_BST_TRANSP)
      {
      *request_code &= ~GR_BST_TRANSP;
      transparent = TRUE;
      }
   else
      {
      transparent = FALSE;
      }

   /*
    * If the number of shades is 1, then always do area fill
    */

   if (tiling_parms.number_shades == 1)
      {
      switch (*request_code)
         {
         case GR_BST_SMOOTH:
         case GR_BST_CONSTANT:
            *request_code = GR_BST_SOLID;
            break;

         default:
            break;
            };
      }

   /*
    * switch on the request code
    */

   switch (*request_code)
      {
      case GR_BST_SMOOTH:
         if( tiling_parms.processing_mode & HS_PMODE_PHONG_LIGHTS )
            {
            if (transparent)
               active_window->rasterizer[0] = HPsmooth_shade_opaque_phong;
            else
               active_window->rasterizer[0] = HPsmooth_shade_opaque_phong;

            HPset_rendering_attributes(&transparent);
            }
         else
            {
            if (transparent)
               active_window->rasterizer[0] = HPsmooth_shade_trans;
            else
               active_window->rasterizer[0] = HPsmooth_shade_opaque;
            }

         active_window->start_polyline[0] = HPstart_polyline;
         active_window->continue_polyline[0] = HPcontinue_polyline;

         if (HPglobal.bytes_per_pixel == 5)
            {
            active_window->start_polyline[0] = HPstart_swine5;
            active_window->continue_polyline[0] = HPcontinue_swine5;
            }

         else
         if (HPglobal.bytes_per_pixel == 6)
            {
            active_window->start_polyline[0] = HPstart_swine6;
            active_window->continue_polyline[0] = HPcontinue_swine6;
            }

         else
            {
            active_window->start_polyline[0] = HPstart_swine7;
            active_window->continue_polyline[0] = HPcontinue_swine7;
            }

         element_parms.color = *color;
         break;

      case GR_BST_CONSTANT:
         if (transparent)
            active_window->rasterizer[0] = HPconstant_shade_trans;
         else
            active_window->rasterizer[0] = HPconstant_shade_opaque;

         if (HPglobal.bytes_per_pixel == 5)
            {
            active_window->start_polyline[0] = HPstart_swine5;
            active_window->continue_polyline[0] = HPcontinue_swine5;
            }
         else
            {
            active_window->start_polyline[0] = HPstart_swine6;
            active_window->continue_polyline[0] = HPcontinue_swine6;
            }

         active_window->start_polyline[0] = HPstart_polyline;
         active_window->continue_polyline[0] = HPcontinue_polyline;

         element_parms.color = *color;
         break;

      case GR_BST_SOLID:
         if (transparent)
            active_window->rasterizer[0] = HParea_fill_trans;
         else
            active_window->rasterizer[0] = HParea_fill_opaque;

         if (HPglobal.bytes_per_pixel == 5)
            {
            active_window->start_polyline[0] = HPstart_swine5;
            active_window->continue_polyline[0] = HPcontinue_swine5;
            }
         else
            {
            active_window->start_polyline[0] = HPstart_swine6;
            active_window->continue_polyline[0] = HPcontinue_swine6;
            }

         active_window->start_polyline[0] = HPstart_polyline;
         active_window->continue_polyline[0] = HPcontinue_polyline;

         element_parms.color = *color;
         break;

      case HS_BST_EDGES:
      case HS_BST_REV_EDGES:
      case HS_BST_EDGES_DELETE:
         active_window->silhouetter[0] = HPsilly_lines_stub;
         if (HPglobal.bytes_per_pixel == 5)
            {
            active_window->rasterizer[0] = HPtrap_radge5;

            if (tiling_parms.processing_mode & HS_PMODE_DONT_ZBUFFER)
               {
               active_window->start_polyline[0] = HPstart_dzine5;
               active_window->continue_polyline[0] = HPcontinue_dzine5;
               }
            else
               {
               active_window->start_polyline[0] = HPstart_pline_radge5;
               active_window->continue_polyline[0] = HPcontinue_pline_radge5;
               }
            }
         else
            {
            active_window->rasterizer[0] = HPtrap_radge6;

            if (tiling_parms.processing_mode & HS_PMODE_DONT_ZBUFFER)
               {
               active_window->start_polyline[0] = HPstart_dzine6;
               active_window->continue_polyline[0] = HPcontinue_dzine6;
               }
            else
               {
               active_window->start_polyline[0] = HPstart_pline_radge6;
               active_window->continue_polyline[0] = HPcontinue_pline_radge6;
               }
            }

         element_parms.color = *color;
         break;

      case HS_BST_DELETE:
         if (transparent)
            active_window->rasterizer[0] = HParea_fill_trans;
         else
            active_window->rasterizer[0] = HParea_fill_opaque;

         active_window->start_polyline[0] = HPstart_polyline;
         active_window->continue_polyline[0] = HPcontinue_polyline;

         if (HPglobal.bytes_per_pixel == 5)
            {
            active_window->start_polyline[0] = HPstart_swine5;
            active_window->continue_polyline[0] = HPcontinue_swine5;
            }
         else
            {
            active_window->start_polyline[0] = HPstart_swine6;
            active_window->continue_polyline[0] = HPcontinue_swine6;
            }

         element_parms.color = *color;
         break;

      case HS_OLD_EDGES:
      case HS_OLD_EDGES_DELETE:
         if (tiling_parms.processing_mode & HS_PMODE_RHL_SHOW_HIDDEN)
            {
            active_window->silhouetter[0] = HPsilly_lines_stub;
            active_window->rasterizer[0] = HPraster_edges;
            }
         else
            {
            active_window->silhouetter[0] = HPsilly_lines;
            active_window->rasterizer[0] = HPraster_lines;
            HPraster_lines_init ();
            }

         if (HPglobal.bytes_per_pixel == 5)
            {
            active_window->start_polyline[0] = HPstart_swine5;
            active_window->continue_polyline[0] = HPcontinue_swine5;
            }
         else
            {
            active_window->start_polyline[0] = HPstart_swine6;
            active_window->continue_polyline[0] = HPcontinue_swine6;
            }

         element_parms.color = *color;
         break;

      case HS_BST_POLYLINE:
      case HS_BST_POLYLINE_DELETE:
      case HS_BST_POINT:
      case HS_BST_POINT_DELETE:
         element_parms.delete = FALSE;

         active_window->start_polyline[0] = HPstart_polyline;
         active_window->continue_polyline[0] = HPcontinue_polyline;

         if (HPglobal.bytes_per_pixel == 5)
            {
            active_window->start_polyline[0] = HPstart_swine5;
            active_window->continue_polyline[0] = HPcontinue_swine5;
            }
         else
            {
            active_window->start_polyline[0] = HPstart_swine6;
            active_window->continue_polyline[0] = HPcontinue_swine6;
            }

         element_parms.color = *color;
         break;

      default:
         break;
         }
   }
