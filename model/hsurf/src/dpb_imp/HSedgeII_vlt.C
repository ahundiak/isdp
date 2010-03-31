/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:37 $
$Locker:  $
*/

#include <stdio.h>
#include <stdlib.h>

#include "wl.h"

#include "OMminimum.h"

#include "igrtypedef.h"
#include "igetypedef.h"
#include "igr.h"
#include "gr.h"

#include "dp.h"
#include "igecolor.h"
#include "igecolordef.h"
#include "igecolmacros.h"

#include "hsurf.h"
#include "hslight.h"

#include "HSpr_dpb_imp.h"

/*------------------------------
 *  for functions
 *     HSget_region_update
 *     HSget_region_xy_minmax
 */

#include "igrdp.h"
#include "hskyoptypes.h"
#include "hsanimate.h"
#include "hstiler.h"
#include "HSrle.h"
#include "HSsara.h"
#include "HSfem_spt.h"
#include "HStl_window.h"
#include "HStl_global.h"
#include "HStl_element.h"

#include "HSe2_mesher.h"
#include "hsdisplay.h"
#include "HSpr_tiler_f.h"

extern IGRboolean DPdynamic_update_in_progress;

/*--- HSclear_window ---------------------------------------------*/

IGRint HSclear_window ( IGRint lwin_no)

/*
NAME
   HSclear_window

DESCRIPTION
   This function clears a window by filling it with the background color.

PARAMETERS
   lwin_no (IN) - the logical window to clear

SYNOPSIS
   IGRint HSclear_window( IGRint lwin_no )

HISTORY
   09/07/90  S.P. Rogers
      Creation Date
   05/03/93  S.P. Rogers
      WL Converted
*/

   {
   IGRlong			msg;
   IGRboolean			region_update = FALSE;
   struct WLbounds		bounds;
   struct DPdit_range		range;
   WLuint32			context_no;

#  if defined( OPENGL )
   GLXContext			gl_base_context, gl_hilite_context;
   struct WLcontext_info	context_info;
   int				temp;
#  endif

#  if defined( XGL )
   Xgl_object			xgl_context, hl_xgl_context;
   Xgl_bounds_d3d		region_dc_viewport, old_dc_viewport;
   Xgl_color			xgl_background_color;
   int				temp;
   WLuint32			background_red, background_green, background_blue;
   ushort			background_color[3];
   double			gamma[3] = { 2.2, 2.2, 2.2 };
#  endif

   HSget_region_update (&region_update);

   if (region_update)
      {
      HSget_region_xy_minmax (&range.xlo, &range.ylo, &range.xhi, &range.yhi);

#     if defined( ENV5 )

      /* kludge for display region in Environ 5 does not update upper edge */

      range.ylo++;
#     endif
      }
   else
      {
      WLget_window_bounds (lwin_no, NULL, &bounds);
      range.xlo = 0;
      range.ylo = 0;
      range.xhi = bounds.width - 1;
      range.yhi = bounds.height - 1;
      }

#  if defined( OPENGL )
   WLset_drawing_mode (lwin_no, WL_BASE_ERASE | WL_HILITE_ERASE);
   if (region_update)
      {
      WLget_window_bounds (lwin_no, NULL, &bounds);
      }

   /* the y is flipped in OPENGL, so compensate for that */

   temp = bounds.height - 1 - range.yhi;
   range.yhi = bounds.height - 1 - range.ylo;
   range.ylo = temp;

   WLglx_get_window_contexts (lwin_no,
                              &gl_base_context, &gl_hilite_context);
   if (gl_base_context)
      {
      WLget_window_base_context (lwin_no, &context_no);
      WLget_context_info (context_no, &context_info);
      WLglx_make_window_current (lwin_no, WL_GLX_BASE_WIN);

      glScissor (range.xlo, range.ylo,
                 range.xhi - range.xlo + 1, range.yhi - range.ylo + 1);

      glPushAttrib (GL_COLOR_BUFFER_BIT | GL_SCISSOR_TEST);
      glEnable (GL_SCISSOR_TEST);

      if (context_info.base_cmap_type)
         {
         glColorMask (GL_TRUE, GL_TRUE, GL_TRUE, GL_TRUE);
         }
      else
         {
         glIndexMask ((1 << context_info.base_depth) - 1);
         }

      glClear (GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

      glPopAttrib ();

      if (gl_hilite_context && !DPdynamic_update_in_progress)
         {
         WLglx_make_window_current (lwin_no, WL_GLX_HILITE_WIN);

         glScissor (range.xlo, range.ylo,
                    range.xhi - range.xlo + 1, range.yhi - range.ylo + 1);

         glEnable (GL_SCISSOR_TEST);

         glClear (GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

         glDisable (GL_SCISSOR_TEST);
         }

      WLset_drawing_mode (lwin_no, WL_BASE_DRAW | WL_HILITE_NOOP);
      return (0);
      }

   if (DPdynamic_update_in_progress)
      WLset_drawing_mode (lwin_no, WL_BASE_DRAW | WL_HILITE_NOOP);
   else
#  endif

#  if defined( XGL )
   WLset_drawing_mode (lwin_no, WL_BASE_ERASE | WL_HILITE_ERASE);

   WLxgl_get_window_contexts (lwin_no, &xgl_context, &hl_xgl_context);
   if (xgl_context)
      {

      /*
       *  Get the background color and set it into XGL
       */

      WLget_window_base_context (lwin_no, &context_no);

      IGEcmap_color_to_rgb( context_no, 
                            IGE_LOGICAL_BACKGROUND, 
                            0, 0, 0, 0,
                            &background_red, 
                            &background_green, 
                            &background_blue );

      background_color[0] = background_red;
      background_color[1] = background_green;
      background_color[2] = background_blue;

      xgl_background_color.rgb.r = (float)background_red / 65535.0;
      xgl_background_color.rgb.g = (float)background_green / 65535.0;
      xgl_background_color.rgb.b = (float)background_blue / 65535.0;

      /*
       *  This will color compensate the RGB.  I found that the wireframe
       *  windows was not using the unconpensated color, so I took this out, but
       *  just for future reference, I left the lines here commented out.  
       *  (Mike Lanier : 09-06-96)

      IGEcolor_compensate( 1, background_color, gamma, 0 );

      xgl_background_color.rgb.r = (float)background_color[0] / 65535.0;
      xgl_background_color.rgb.g = (float)background_color[1] / 65535.0;
      xgl_background_color.rgb.b = (float)background_color[2] / 65535.0;
      */

/*
      fprintf( stderr, "%d %d %d --- %f %f %f\n",
        background_red, background_green, background_blue,
        xgl_background_color.rgb.r, 
        xgl_background_color.rgb.g, 
        xgl_background_color.rgb.b );
*/

      xgl_object_set( xgl_context, 
                      XGL_CTX_BACKGROUND_COLOR, 
                      xgl_background_color, 
                      NULL );

      xgl_context_new_frame (xgl_context);

      if (hl_xgl_context && !DPdynamic_update_in_progress)
         {
         xgl_context_new_frame (hl_xgl_context);
         }

      WLset_drawing_mode (lwin_no, WL_BASE_DRAW | WL_HILITE_NOOP);
      return (0);
      }

   if (DPdynamic_update_in_progress)
      WLset_drawing_mode (lwin_no, WL_BASE_DRAW | WL_HILITE_NOOP);
   else

#  endif
   WLset_drawing_mode (lwin_no, WL_BASE_DRAW | WL_HILITE_ERASE);

   DPerase (&msg, &lwin_no, &range);

   return (0);
   }    /* HSclear_window */
