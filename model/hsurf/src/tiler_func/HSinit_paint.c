

/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:41 $
$Locker:  $
*/

#include <stdio.h>
#include <stdlib.h>

#include "wl.h"

#if defined( ENV5 )
#include <EG.h>
#include <gpipe.h>
#endif

#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "igrdp.h"

#include "igecolordef.h"
#include "igecolor.h"
#include "gr.h"
#include "dp.h"
#include "dpstruct.h"

#include "hstiler.h"
#include "hslight.h"
#include "hsdisplay.h"
#include "hplot.h"
#include "hsdef.h"
#include "hsmacdef.h"

#include "HStl_global.h"
#include "HStl_window.h"
#include "HStl_element.h"
#include "HSfem_spt.h"
#include "HSd_fixedpt.h"
#include "HSe2_mesher.h"

#include "hsdisplay.h"
#include "HSpr_tiler_f.h"

/*--------------------------------------
 *  for functions
 *    HSarea_fill_ifb
 *    HSarea_fill_opaque
 *    HSarea_fill_trans
 *    HSconstant_shade_ifb
 *    HSconstant_shade_opaque
 *    HSconstant_shade_trans
 *    HScontinue_dzine
 *    HScontinue_pline_radge
 *    HScontinue_pline_radge_delete
 *    HScontinue_pline_vedge
 *    HScontinue_polyline_ifb
 *    HScontinue_polyline_rop
 *    HScontinue_swine
 *    HSfem_direct
 *    HSfem_dithered
 *    HSsmooth_shade_ifb
 *    HSsmooth_shade_opaque
 *    HSsmooth_shade_trans
 *    HSstart_dzine
 *    HSstart_pline_radge
 *    HSstart_pline_radge_delete
 *    HSstart_pline_vedge
 *    HSstart_polyline_ifb
 *    HSstart_polyline_rop
 *    HSstart_swine
 *    HStrap_radge
 *    HStrap_radge_delete
 *    HSzbuf_trap_ifb
 */

#include "HSpr_display.h"

/*----------------------------------
 *  for function
 *     HSget_rgb_value
 */

#include "HSpr_driver.h"

/*--------------------------------------*/

#define DEBUG 		0

void HSsilly_stub ()
   {
   }

void HSraster_stub ()
   {
   }

/*---HSinit_paint_fem-------------------------------------------------------------------*/

/*
NAME
    HSinit_paint_fem

DESCRIPTION
    Initialize the active color and define the surface rasterizer for
    fem display

PARAMETERS
    color       : (IN):  Logical color index
    request_code: (IN):  Bitmask defining the shading style

GLOBALS USED
    tiling_parms
    active_window

FUNCTIONS CALLED
    HSset_element_color
    HSset_element_delete_flag

HISTORY
    ??/??/??     S. Rapa, M. Lanier
         Created

*/

void HSinit_paint_fem (IGRint * color, IGRint * request_code)

   {
#	if DEBUG
   fprintf (stderr, "HSinit_paint_fem\n");
   fprintf (stderr, "   color ---- %d\n", *color);
   fprintf (stderr, "   request -- %x\n", *request_code);
#	endif

   /* Switch on the request code. */


   if (*request_code & GR_BST_SMOOTH)
      {
      if (tiling_parms.processing_mode & HS_PMODE_DIRECT)
         active_window->rasterizer[active_window->active_zbuffer] = HSsmooth_shade_opaque;
      else
         active_window->rasterizer[active_window->active_zbuffer] = HSsmooth_shade_fem_tritrap;

      /* the logical color is sent in now to HSset_element_color to store all
       * information */

      HSset_element_color (*color);
      }
   else if (*request_code & GR_BST_CONSTANT)
      {
      if (tiling_parms.processing_mode & HS_PMODE_DIRECT)
         active_window->rasterizer[active_window->active_zbuffer] = HSconstant_shade_opaque;
      else
         active_window->rasterizer[active_window->active_zbuffer] = HSsmooth_shade_fem_tritrap;

      /* the logical color is sent in now to HSset_element_color to store all
       * information */

      HSset_element_color (*color);
      }
   else if (*request_code & HS_FEM_DELETE)
      {
      HSset_element_delete_flag (TRUE);
      *request_code = HS_FEM_DELETE;
      active_window->rasterizer[active_window->active_zbuffer] = HSarea_fill_opaque;
      /* this element_parms.color will not be used with PSUEDO_COLOR */
      HSset_element_color (0);
      }
   else if (*request_code & HS_FEM_DITHERED)
      {
      active_window->rasterizer[active_window->active_zbuffer] = HSfem_dithered;
      /* this element_parms.color will not be used with PSUEDO_COLOR */
      HSset_element_color (*color);
      }
   else
      {
      active_window->rasterizer[active_window->active_zbuffer] = HSfem_direct;
      /* this element_parms.color will not be used with PSUEDO_COLOR */
      HSset_element_color (*color);
      }

   active_window->start_polyline[active_window->active_zbuffer] = HSstart_polyline_rop;
   active_window->continue_polyline[active_window->active_zbuffer] = HScontinue_polyline_rop;
   }


/*---HSinit_paint_ROP-------------------------------------------------------------------*/

/*
NAME
    HSinit_paint_ROP

DESCRIPTION
    Initialize the active color and define the surface rasterizer for
    ROP based hsurf display

PARAMETERS
    color       : (IN):  Logical color index
    request_code: (IN):  Bitmask defining the shading style

GLOBALS USED
    tiling_parms
    active_window

FUNCTIONS CALLED
    HSset_element_color
    HSset_element_delete_flag

HISTORY
    ??/??/??     S. Rapa, M. Lanier
         Created

*/

void HSinit_paint_ROP (IGRint * color, IGRint * request_code)

   {
   IGRboolean transparent;
   IGRint az;

#	if DEBUG
   fprintf (stderr, "HSinit_paint_ROP\n");
   fprintf (stderr, "   color ---- %d\n", *color);
   fprintf (stderr, "   request -- %x\n", *request_code);
#	endif

   az = active_window->active_zbuffer;

   /* Check the transparent bit then clear it */

   if (*request_code & GR_BST_TRANSP)
      {
      *request_code &= ~GR_BST_TRANSP;
      transparent = TRUE;
      }
   else
      {
      transparent = FALSE;
      }

   /* If the number of shades is 1, then always do area fill */

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

   /* Check to see if the delete bit and/or edge delete bit is set */

   if (*request_code & HS_BST_DELETE)
      {
      HSset_element_delete_flag (TRUE);
      *request_code = HS_BST_DELETE;
      }
   else
      {
      if (*request_code & HS_BST_EDGES_DELETE)
         {
         HSset_element_delete_flag (TRUE);
         *request_code = HS_BST_EDGES_DELETE;
         }
      else
         {
         HSset_element_delete_flag (FALSE);
         }
      }


   /* Set the polyline rasterizes.  These will get changed if the */
   /* request is for raster edges                                 */

   if (tiling_parms.processing_mode & HS_PMODE_SWINE)
      {
      active_window->start_polyline[az] = HSstart_swine;
      active_window->continue_polyline[az] = HScontinue_swine;
      }
   else
      {
      active_window->start_polyline[az] = HSstart_polyline_rop;
      active_window->continue_polyline[az] = HScontinue_polyline_rop;
      }

   /* switch on the request code */

   switch (*request_code)
      {
      case GR_BST_SMOOTH:
         if (transparent)
            {
            active_window->rasterizer[az] = HSsmooth_shade_trans;
            }
         else
            {
            active_window->rasterizer[az] = HSsmooth_shade_opaque;
            }

         HSset_element_color (*color);
         break;

      case GR_BST_CONSTANT:
         if (transparent)
            {
            active_window->rasterizer[az] = HSconstant_shade_trans;
            }
         else
            {
            active_window->rasterizer[az] = HSconstant_shade_opaque;
            }

         HSset_element_color (*color);
         break;

      case GR_BST_SOLID:
         if (transparent)
            {
            active_window->rasterizer[az] = HSarea_fill_trans;
            }
         else
            {
            active_window->rasterizer[az] = HSarea_fill_opaque;
            }

         HSset_element_color (*color);
         break;

      case HS_BST_DELETE:
         if (transparent)
            {
            active_window->rasterizer[az] = HSarea_fill_trans;
            }
         else
            {
            active_window->rasterizer[az] = HSarea_fill_opaque;
            }

         HSset_element_color (0);
         break;

      case HS_BST_REV_EDGES:
      case HS_BST_EDGES:

         if( active_window->shading_style == HS_STYLE_FILLED_RASTER )
            active_window->rasterizer[az] = HStrap_radge_filled;
         else
            active_window->rasterizer[az] = HStrap_radge;
            
         if (tiling_parms.processing_mode & HS_PMODE_LVHL_EDGES)
            {
            active_window->start_polyline[az] = HSstart_pline_vedge;
            active_window->continue_polyline[az] = HScontinue_pline_vedge;
            }

         else
         if (tiling_parms.processing_mode & HS_PMODE_DONT_ZBUFFER)
            {
            active_window->start_polyline[az] = HSstart_dzine;
            active_window->continue_polyline[az] = HScontinue_dzine;
            }

         else
            {
            active_window->start_polyline[az] = HSstart_pline_radge;
            active_window->continue_polyline[az] = HScontinue_pline_radge;
            }

         HSset_element_color (*color);
         break;

      case HS_BST_EDGES_DELETE:
         active_window->rasterizer[az] = HStrap_radge_delete;
         active_window->start_polyline[az] = HSstart_pline_radge_delete;
         active_window->continue_polyline[az] = HScontinue_pline_radge_delete;

         HSset_element_color (*color);
         break;

      case HS_BST_POLYLINE:
      case HS_BST_POINT:
         HSset_element_delete_flag (FALSE);
         HSset_element_color (*color);
         break;

      case HS_BST_POLYLINE_DELETE:
      case HS_BST_POINT_DELETE:
         HSset_element_delete_flag (TRUE);
         HSset_element_color (*color);
         break;

      default:
         break;
         }
   }

/*---HSinit_paint_fem_ramp-------------------------------------------------------------------*/

void HSinit_paint_fem_ramp (IGRint * color, IGRint * request_code)

   {
#	if DEBUG
   fprintf (stderr, "HSinit_paint_fem_ramp\n");
   fprintf (stderr, "   color ---- %d\n", *color);
   fprintf (stderr, "   request -- %x\n", *request_code);
#	endif
   struct IGEcontext_info IGEcontext_info;
   IGEload_context(active_window->context_no, &IGEcontext_info);

   /* Switch on the request code. */


   if (*request_code & GR_BST_SMOOTH)
      {
      if (tiling_parms.processing_mode & HS_PMODE_DIRECT)
         active_window->rasterizer[active_window->active_zbuffer] = HSsmooth_shade_opaque_direct;
      else
         active_window->rasterizer[active_window->active_zbuffer] = HSsmooth_shade_opaque_half;
      HSset_element_color (*color);
      }
   else if (*request_code & GR_BST_CONSTANT)
      {
      if (tiling_parms.processing_mode & HS_PMODE_DIRECT)
         active_window->rasterizer[active_window->active_zbuffer] = HSconstant_shade_opaque_direct;
      else
         active_window->rasterizer[active_window->active_zbuffer] = HSconstant_shade_opaque_half;
      HSset_element_color (*color);
      }
   else if (*request_code & HS_FEM_DELETE)
      {
      HSset_element_delete_flag (TRUE);
      *request_code = HS_FEM_DELETE;
      active_window->rasterizer[active_window->active_zbuffer] = HSarea_fill_opaque;
      }
   else if (*request_code & HS_FEM_DITHERED)
      {
      /* if for any reason the ramp wasn't set up (i.e. no room) use PTC to shade */
      if (IGEcontext_info.user_ramp_start_slot != -1)
      {
         active_window->rasterizer[active_window->active_zbuffer] = HSfem_dithered_ramp;
      }
      else
      {
         active_window->rasterizer[active_window->active_zbuffer] = HSfem_dithered;
      }
      }
   else
      {
      /* if for any reason the ramp wasn't set up (i.e. no room) use PTC to shade */
      if (IGEcontext_info.user_ramp_start_slot != -1)
      {
         active_window->rasterizer[active_window->active_zbuffer] = HSfem_direct_ramp;
      }
      else
      {
         active_window->rasterizer[active_window->active_zbuffer] = HSfem_direct;
      }
      }

   active_window->start_polyline[active_window->active_zbuffer] = HSstart_polyline_rop;
   active_window->continue_polyline[active_window->active_zbuffer] = HScontinue_polyline_rop;
   }


/*---HSinit_paint_rop_ramp-------------------------------------------------------------------*/

void HSinit_paint_rop_ramp (IGRint * color, IGRint * request_code)

   {
   IGRboolean transparent;
   IGRint az;

#	if DEBUG
   fprintf (stderr, "HSinit_paint_rop_ramp\n");
   fprintf (stderr, "   color ---- %d\n", *color);
   fprintf (stderr, "   request -- %x\n", *request_code);
#	endif

   az = active_window->active_zbuffer;

   /* Check the transparent bit then clear it */

   if (*request_code & GR_BST_TRANSP)
      {
      *request_code &= ~GR_BST_TRANSP;
      transparent = TRUE;
      }
   else
      {
      transparent = FALSE;
      }

   /* If the number of shades is 1, then always do area fill */

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

   /* Check to see if the delete bit and/or edge delete bit is set */

   if (*request_code & HS_BST_DELETE)
      {
      HSset_element_delete_flag (TRUE);
      *request_code = HS_BST_DELETE;
      }
   else
      {
      if (*request_code & HS_BST_EDGES_DELETE)
         {
         HSset_element_delete_flag (TRUE);
         *request_code = HS_BST_EDGES_DELETE;
         }
      else
         {
         HSset_element_delete_flag (FALSE);
         }
      }


   /* switch on the request code */

   switch (*request_code)
      {
      case GR_BST_SMOOTH:
         if (transparent)
            {
            if (tiling_parms.processing_mode & HS_PMODE_DIRECT)
               active_window->rasterizer[az] = HSsmooth_shade_trans_direct;
            else
               active_window->rasterizer[az] = HSsmooth_shade_trans_half;
            }
         else
            {
            if (tiling_parms.processing_mode & HS_PMODE_DIRECT)
               active_window->rasterizer[az] = HSsmooth_shade_opaque_direct;
            else
               active_window->rasterizer[az] = HSsmooth_shade_opaque_half;
            }

         HSset_element_color (*color);
         break;

      case GR_BST_CONSTANT:
         if (transparent)
            {
            if (tiling_parms.processing_mode & HS_PMODE_DIRECT)
               active_window->rasterizer[az] = HSconstant_shade_trans_direct;
            else
               active_window->rasterizer[az] = HSconstant_shade_trans_half;
            }
         else
            {
            if (tiling_parms.processing_mode & HS_PMODE_DIRECT)
               active_window->rasterizer[az] = HSconstant_shade_opaque_direct;
            else
               active_window->rasterizer[az] = HSconstant_shade_opaque_half;
            }

         HSset_element_color (*color);
         break;

      case GR_BST_SOLID:
         if (transparent)
            active_window->rasterizer[az] = HSarea_fill_trans_ramp;
         else
            active_window->rasterizer[az] = HSarea_fill_opaque_ramp;

         HSset_element_color (*color);
         break;

      case HS_BST_DELETE:
         if (transparent)
            active_window->rasterizer[az] = HSarea_fill_trans_ramp;
         else
            active_window->rasterizer[az] = HSarea_fill_opaque_ramp;

         HSset_element_color (0);
         break;

      case HS_BST_REV_EDGES:
      case HS_BST_EDGES:
         active_window->silhouetter[az] = HSsilly_stub;

         if( active_window->shading_style == HS_STYLE_FILLED_RASTER )
            active_window->rasterizer[az] = HStrap_radge_filled;
         else
            active_window->rasterizer[az] = HStrap_radge;

         HSset_element_color (*color);
         break;

      case HS_BST_EDGES_DELETE:
         active_window->silhouetter[az] = HSsilly_stub;
         active_window->rasterizer[az] = HStrap_radge_delete;

         HSset_element_color (*color);
         break;

      case HS_BST_POLYLINE:
         HSset_element_delete_flag (FALSE);
         HSset_element_color (*color);
         break;

      case HS_BST_POINT:
         HSset_element_delete_flag (FALSE);
         HSset_element_color (*color);
         break;

      case HS_BST_POLYLINE_DELETE:
         HSset_element_delete_flag (TRUE);
         HSset_element_color (*color);
         break;

      case HS_BST_POINT_DELETE:
         HSset_element_delete_flag (TRUE);
         HSset_element_color (*color);
         break;

      default:
         break;
         }

   /* Set the polyline rasterizer */

   if (*request_code & (HS_BST_EDGES | HS_BST_REV_EDGES))
      {
      if (tiling_parms.processing_mode & HS_PMODE_LVHL_EDGES)
         {
         active_window->start_polyline[az] = HSstart_pline_vedge;
         active_window->continue_polyline[az] = HScontinue_pline_vedge;
         }
      else if (tiling_parms.processing_mode & HS_PMODE_DONT_ZBUFFER)
         {
         active_window->start_polyline[az] = HSstart_dzine;
         active_window->continue_polyline[az] = HScontinue_dzine;
         }
      else
         {
         active_window->start_polyline[az] = HSstart_pline_radge;
         active_window->continue_polyline[az] = HScontinue_pline_radge;
         }
      }
   else if (*request_code & (HS_BST_EDGES_DELETE))
      {
      active_window->start_polyline[az] = HSstart_pline_radge_delete;
      active_window->continue_polyline[az] = HScontinue_pline_radge_delete;
      }
   else
      {
      if (tiling_parms.processing_mode & HS_PMODE_SWINE)
         {
         active_window->start_polyline[az] = HSstart_swine;
         active_window->continue_polyline[az] = HScontinue_swine;
         }
      else
         {
         active_window->start_polyline[az] = HSstart_polyline_rop;
         active_window->continue_polyline[az] = HScontinue_polyline_rop;
         }
      }
   }

#if defined( ENV5 )
/*---HSinit_paint_IFB-------------------------------------------------------------------*/

void HSinit_paint_IFB (IGRint * color, IGRint * request_code)

   {
   IGRint transparent;
   IGRint az;

#	if DEBUG
   fprintf (stderr, "HSinit_paint_ifb\n");
   fprintf (stderr, "   color ---- %d\n", *color);
   fprintf (stderr, "   request -- %x\n", *request_code);
#	endif


   az = active_window->active_zbuffer;

   /* Check the translucent bit and clear it */

   if (*request_code & GR_BST_TRANSP)
      {
      *request_code &= ~GR_BST_TRANSP;
      transparent = tiling_parms.processing_mode & HS_PMODE_TRANS_1x1 ? 1 : 2;
      }
   else
      {
      transparent = 0;
      }

   /* If the number of shades == 1 then always do area fill */

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


   /* Check to see if the delete bit is set */

   if (*request_code & HS_BST_DELETE)
      {
      HSset_element_delete_flag (TRUE);

      /* If the request was for a smooth shading display then user the
       * scanline shading routine.  If the request was for constant or area
       * fill, use the ztrap shading routine. */

      if (*request_code & GR_BST_SMOOTH)
         *request_code = HS_BST_DELETE;
      else
         *request_code = GR_BST_SOLID;

      sh_set_bright_edge_tol (active_window->hwin_no, 0, tiling_parms.number_shades);
      }
   else
      {
      if (*request_code & HS_BST_EDGES_DELETE)
         {
         HSset_element_delete_flag (TRUE);
         *request_code = HS_BST_EDGES_DELETE;
         }
      else
         {
         HSset_element_delete_flag (FALSE);
         }

      sh_set_bright_edge_tol (active_window->hwin_no, 1, tiling_parms.number_shades);
      }


   sh_set_dither_mode (active_window->hwin_no,
                    tiling_parms.processing_mode & HS_PMODE_DIRECT ? 0 : 1);

   switch (*request_code)
      {
      case GR_BST_SMOOTH:
         HSset_element_delete_flag (FALSE);
         active_window->rasterizer[az] = HSsmooth_shade_ifb;

         sh_set_trans_mode (active_window->hwin_no, transparent);

         HSset_element_color (*color);
         break;

      case GR_BST_CONSTANT:
         HSset_element_delete_flag (FALSE);
         active_window->rasterizer[az] = /* HSconstant_shade_ifb */ HSzbuf_trap_ifb;

         sh_set_trans_mode (active_window->hwin_no, transparent);

         HSset_element_color (*color);
         break;

      case GR_BST_SOLID:
         HSset_element_delete_flag (FALSE);
         active_window->rasterizer[az] = /* HSarea_fill_ifb */ HSzbuf_trap_ifb;

         sh_set_trans_mode (active_window->hwin_no, transparent);

         HSset_element_color (*color);
         break;

      case HS_BST_DELETE:
         HSset_element_delete_flag (TRUE);
         active_window->rasterizer[az] = HSarea_fill_ifb /* HSzbuf_trap_ifb */ ;

         HSset_element_color (HS_BACKGROUND_COLOR);
         break;

      case HS_BST_EDGES:
      case HS_BST_REV_EDGES:
      case HS_BST_EDGES_DELETE:
         active_window->silhouetter[az] = HSsilly_stub;
         break;

      case HS_BST_POLYLINE:
         HSset_element_delete_flag (FALSE);
         HSset_element_color (*color);
         break;

      case HS_BST_POINT:
         HSset_element_delete_flag (FALSE);
         HSset_element_color (*color);
         break;

      case HS_BST_POLYLINE_DELETE:
         HSset_element_delete_flag (TRUE);
         HSset_element_color (HS_BACKGROUND_COLOR);
         break;

      case HS_BST_POINT_DELETE:
         HSset_element_delete_flag (TRUE);
         HSset_element_color (HS_BACKGROUND_COLOR);
         break;

      default:
         break;
         }

   WLset_active_symbology (active_window->win_no, element_parms.color, 0, 0xFFFF, 0, WL_SYMB_CHANGE_COLOR);

   /* Set the polyline rasterizer */

   if (*request_code & (HS_BST_EDGES | HS_BST_REV_EDGES))
      {
      if (tiling_parms.processing_mode & HS_PMODE_LVHL_EDGES)
         {
         active_window->start_polyline[az] = HSstart_pline_vedge;
         active_window->continue_polyline[az] = HScontinue_pline_vedge;
         }
      else
         {
         active_window->start_polyline[az] = HSstart_pline_radge;
         active_window->continue_polyline[az] = HScontinue_pline_radge;
         }
      }
   else
      {
      /*if (tiling_parms.processing_mode & HS_PMODE_SWINE)
         {
         active_window->start_polyline[az] = HSstart_swine;
         active_window->continue_polyline[az] = HScontinue_swine;
         }
      else*/
         {
         active_window->start_polyline[az] = HSstart_polyline_ifb;
         active_window->continue_polyline[az] = HScontinue_polyline_ifb;
         }
      }
   }

/*---HSinit_paint_EG-------------------------------------------------------------------*/

void HSinit_paint_EG (IGRint * color, IGRint * request_code)

   {
   IGRint status, az;
   IGRint rgb_value;
   EGRGBColor EGcolor;

   az = active_window->active_zbuffer;

   /* rasterizers can be stubbed because they're never called */

   active_window->rasterizer[az] = HSraster_stub;
   active_window->silhouetter[az] = HSsilly_stub;

   if (*request_code & HS_BST_DELETE)
      {
      /* set the active window data */

      HSset_element_delete_flag (TRUE);
      HSset_element_color (HS_BACKGROUND_COLOR);

      /* define the base color */

      EGcolor.red = 0.0;
      EGcolor.green = 0.0;
      EGcolor.blue = 0.0;

      EGSetLightingMode (active_window->EG_vc_no, EG_OFF);
      }
   else
      {

      /* set the active window data */

      HSset_element_delete_flag (FALSE);
      HSset_element_color (*color);

      /* define the base color */

      rgb_value = HSget_rgb_value (*color);
      EGcolor.red = (IGRdouble) ((rgb_value >> 20) & 0x3ff) / (IGRdouble) (0x3ff);
      EGcolor.green = (IGRdouble) ((rgb_value >> 10) & 0x3ff) / (IGRdouble) (0x3ff);
      EGcolor.blue = (IGRdouble) (rgb_value & 0x3ff) / (IGRdouble) (0x3ff);

      EGSetLightingMode (active_window->EG_vc_no, EG_ON);
      }

   /* set the base color */

   status = EGSetBaseColor (active_window->EG_vc_no, &EGcolor);
   if (status)
      fprintf (stderr, "EGSetBaseColor failed; status = %d\n", status);
   }    /* HSinit_paint_EG */

#endif

#if defined( OPENGL )

/*---HSinit_paint_OPENGL-------------------------------------------------------------------*/

/*
History
   07/16/93   Mike
      Added calls (from HSset_element_rendering_parms) to set the
      object ambient and diffuse light
*/

void HSinit_paint_OPENGL (
                               IGRint * color,
                               IGRint * request_code)

   {
   IGRint az;
   WLcolorref color_ref;
   WLuint32 log_color;

   WLglx_make_window_current( active_window->win_no, WL_GLX_BASE_WIN );

   az = active_window->active_zbuffer;

   /* rasterizers can be stubbed because they're never called */
   active_window->rasterizer[az] = HSraster_stub;
   active_window->silhouetter[az] = HSsilly_stub;

   /* translucency is not supported */
   if (*request_code & HS_BST_DELETE)
      {
      HSset_element_delete_flag (TRUE);
      HSset_element_color (HS_BACKGROUND_COLOR);

      WLpack_index_colorref (IGE_LOGICAL_BACKGROUND, &color_ref, 0);
      WLset_active_symbology (active_window->win_no, color_ref, 0, 0xFFFF, 0, WL_SYMB_CHANGE_COLOR);

      glDisable (GL_LIGHTING);
      }
   else
      {
      HSset_element_delete_flag (FALSE);
      HSset_element_color (*color);

      WLpack_index_colorref (*color, &color_ref, 0);
      WLset_active_symbology (active_window->win_no, color_ref, 0, 0xFFFF, 0, WL_SYMB_CHANGE_COLOR);

      if (*request_code & (GR_BST_SMOOTH | GR_BST_CONSTANT))
         {
         glEnable (GL_LIGHTING);
         }
      else
         {
         glDisable (GL_LIGHTING);
         }
      }

   WLactivate_symbology (active_window->win_no, FALSE, TRUE);

   }    /* HSinit_paint_OPENGL */

#endif

#if defined( XGL )

/*---HSinit_paint_XGL-------------------------------------------------------------------*/

/*
History
   07/16/93   Mike
      Added calls (from HSset_element_rendering_parms) to set the
      object ambient and diffuse light
*/

void HSinit_paint_XGL (
                               IGRint * color,
                               IGRint * request_code)

   {
   IGRint az;
   WLcolorref color_ref;
   WLuint32 log_color;

   az = active_window->active_zbuffer;

   /* rasterizers can be stubbed because they're never called */
   active_window->rasterizer[az] = HSraster_stub;
   active_window->silhouetter[az] = HSsilly_stub;

   /* translucency is not supported */
   if (*request_code & HS_BST_DELETE)
      {
      HSset_element_delete_flag (TRUE);
      HSset_element_color (HS_BACKGROUND_COLOR);

      WLpack_index_colorref (IGE_LOGICAL_BACKGROUND, &color_ref, 0);
      WLset_active_symbology (active_window->win_no, color_ref, 0, 0xFFFF, 0, WL_SYMB_CHANGE_COLOR);

/*      glDisable (GL_LIGHTING);*/
      }
   else
      {
      HSset_element_delete_flag (FALSE);
      HSset_element_color (*color);

      WLpack_index_colorref (*color, &color_ref, 0);
      WLset_active_symbology (active_window->win_no, color_ref, 0, 0xFFFF, 0, WL_SYMB_CHANGE_COLOR);

      if (*request_code & (GR_BST_SMOOTH | GR_BST_CONSTANT))
         {
/*         glEnable (GL_LIGHTING);*/
         }
      else
         {
/*         glDisable (GL_LIGHTING);*/
         }
      }

   WLactivate_symbology (active_window->win_no, FALSE, TRUE);

   }    /* HSinit_paint_XGL */

#endif

