
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:41 $
$Locker:  $
*/

#include <stdio.h>

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
#include "hsdef.h"
#include "hsmacdef.h"
#include "hsemulation.h"

#include "HStl_global.h"
#include "HStl_element.h"
#include "HStl_window.h"
#include "HSe2_mesher.h"
#include "HSfem_spt.h"

#include "wl.h"

#include "hsdisplay.h"
#include "HSpr_tiler_f.h"

/*--- HSusing_GPIPE -------------------------------------------------------------*/

IGRint HSusing_GPIPE(
   IGRint pipe_id )

/*
NAME
   HSusing_GPIPE

DESCRIPTION
   This funtion determines if HSURF is using GPIPE to shade a window

SYNOPSIS
   IGRboolean HSusing_GPIPE(
      int pipe_id )

PARAMETERS
   pipe_id (IN) - the window to check

GLOBALS USED
   active_window

RETURN VALUES
   TRUE - if the pipe is using GPIPE
   FALSE - if the pipe is not using GPIPE

HISTORY
   08/19/93 S.P. Rogers
      Creation Date
*/

{
   HSactivate_window( pipe_id );
   return( active_window->type & HShardware_LB_GPIPE );
}  /* HSusing_GPIPE */

/*---HScheck_hardware_support----------------------------------------------------*/

/*
NAME
    HScheck_hardware_support
    
DESCRIPTION
    Will get the dimensions of the named logical screen, compute and return
    then mega pixel size of the screen and set the hardware mode to TURQ.    
    
PARAMETERS
    lscreen_no           : (IN): locical screen number
    lwin_no              : (IN): logical window number
    ignore_hw_zbuffer    : (IN): if TRUE, ignore Z buffer

FUNCTIONS CALLED
    WLget_screen_size

NOTES    
    If unable to get the screen dimensions, assume 1Mpx.  TURQ mode is
    defined because it uses putpixelblock to display the raster images
    where ROP mode uses repetative putlines.
    
HISTORY
    ??/??/?/    M. Lanier
        Created
    2/2/93      M. Lanier
        Re-written for WL
    04/21/93    S.P. Rogers
       Added lwin_no parameter for WL conversion and add more
       machine checks
    07/16/93   M. Lanier
       Change test on z_depth to set 24 bit zbuffer is the z_depth > 0
       This was because the function that returned the z_depth was
       returning 23, and the switch was failing.
*/

IGRint	HScheck_hardware_support(
   WLuint16 lscreen_no,
   WLuint32 lwin_no,
   IGRboolean ignore_hw_zbuffer )

{
   int xdits, ydits;
   int mp = 1, lb, zb, cp;
#if defined( ENV5 )
   int vsi_flags, fpe_status;
   WLuint32 base_context_no;
   struct WLnative_info native_info;
   struct WLcontext_info context_info;
   struct scr_info screen_info[MAX_WINDOW];
#endif
#if defined( X11 )
#if defined( OPENGL )
   GLXContext glx_context, hl_glx_context;
   GLboolean rgba;
   GLint z_depth;
#endif
#if defined( XGL )
   WLuint32 base_context_no;
   struct WLnative_info native_info;
   Xgl_object xgl_context_3D, hl_xgl_context_3D;
#endif
#endif

   lb = HShardware_LB_HSURF_ROP;
   zb = HShardware_ZB_NONE;
   cp = HShardware_CP_NONE;

   if ( WLget_screen_size( lscreen_no, &xdits, &ydits ) == WL_SUCCESS )
   {
      mp = (xdits * ydits) / 1000000;
   }

#if defined( ENV5 )

   WLget_window_base_context( lwin_no, &base_context_no );
   WLget_context_info( base_context_no, &context_info );

   if ( context_info.base_depth > 5 )
   {
      /* we're not on a ROP */
      lb = HShardware_LB_HSURF;
   }

   if ( ! ignore_hw_zbuffer )
   {
      WLget_native_info( lwin_no, base_context_no, &native_info );
      Inq_screen_info ( screen_info );
      vsi_flags = screen_info[native_info.vs_no].vsi_flags;

      if ( context_info.base_cmap_type == WL_CMAP_TRUE_COLOR )
      {
         if ( (vsi_flags & VSI_24_ZB_ABILITY) &&
              (vsi_flags & VSI_TRC_ABILITY) )
         {
            /* this isn't the best test for an EdgeII but it will do */
            lb = HShardware_LB_EG;
            zb = HShardware_ZB_24;
         }
      }
      else
      {
         /* Check for ASAP1 */
         /* RAMPS: need to check if ramps are on */
         if ( IGEget_using_ramp_mode() )
         {
            if( vsi_flags & VSI_32_ZB_ABILITY )
               zb = HShardware_ZB_32;

            GPInqStatus( &fpe_status );
/*fpe_status = 0;*/
            if ( fpe_status )
            {
               cp = HShardware_CP_ASAP1;
               lb = HShardware_LB_GPIPE;
            }
         }
      }
   }

#elif defined( X11 )
#if defined( OPENGL )

   WLglx_get_window_contexts( lwin_no, &glx_context, &hl_glx_context );
   if ( glx_context != NULL )
   {
      WLglx_make_window_current( lwin_no, WL_GLX_BASE_WIN );
      glGetBooleanv( GL_RGBA_MODE, &rgba );

      if ( rgba )
      {
         /* true color context => we can use OpenGL */
         lb = HShardware_LB_OPENGL;
   
         /* only check that Zbuffer exists, looking for */
         /* exact depth caused problems on the Elan     */
         glGetIntegerv( GL_DEPTH_BITS, &z_depth );
         if ( z_depth > 0 )
         {
            zb = HShardware_ZB_24;
         }
         else
         {
            /* unsupported Z buffer range => don't use OpenGL */
            lb = HShardware_LB_HSURF;
         }
      }
   }
#endif
#  if defined( XGL )

   /*  need to check the ignore flag incase we're in a mode in which we're  */
   /*  generating an 8bit raster image for a 24bit window  */

   if( !ignore_hw_zbuffer )
      {
      WLxgl_get_window_contexts( lwin_no, &xgl_context_3D, &hl_xgl_context_3D );
      if ( xgl_context_3D != NULL )
         {
         WLget_window_base_context( lwin_no, &base_context_no );
         WLget_native_info( lwin_no, base_context_no, &native_info );
   
         if (native_info.xgl_color_type .rgb /* == XGL_COLOR_RGB*/ )
            {
            /* true color context => we can use XGL */
            lb = HShardware_LB_XGL;
      
            if ( native_info.xgl_hlhsr_mode == XGL_HLHSR_Z_BUFFER )
               {
               zb = HShardware_ZB_24;
               }
            else
               {
               /* unsupported Z buffer range => don't use XGL */
               lb = HShardware_LB_HSURF;
               }
            }
         }
      }
#endif
#endif

   return( mp | lb | zb | cp );

}  /* HScheck_hardware_support */

/*---HSset_active_max_z------------------------------------------------------------*/

/*
NAME
    HSset_active_max_z
    
DESCRIPTION
    Based on the display type, initialize the active max z.  In all cases
    the max z is 31 bites.  Exceptions are Raster Hidden Line in screen 
    display and HSplot, 5 byte/pixel modes, then the z is 29 bites.
    
PARAMETERS 
    pipe_no        : (IN): The window (viewport) id number
    style          : (IN): The active shading style
    shaded_plotting: (IN): Whether this was called by HSplot
    bytes_per_pixel: (IN): If HSplot, the z/image buffer size
    
GLOBALS USED
    active_window
    
FUNCTIONS CALLED
    HSactivate_window
    HSset_maximum_z

NOTES
    The reason RHL uses 29 bit z's is because the algorithm needs 3 
    for marks.
        
HISTORY
    ??/??/??     M. Lanier
          Created
*/

void	HSset_active_max_z( int pipe_no,
			    int style,
			    int shaded_plotting,
			    int bytes_per_pixel )

    {
    /* If running NC, do nothing. -Trevor Mink 3/16/92 */
    if( tiling_parms.processing_mode & HS_PMODE_DEXEL ) return;

    HSactivate_window( pipe_no );
	
    if( shaded_plotting && bytes_per_pixel == 6 )
        {
        HSset_maximum_z( (double)(0x7fffffff) );
        active_window->ignore_locked_zbuffer = TRUE;
        }
    else
        {
        switch( style )
            {			
            case HS_STYLE_RASTER:
            case HS_STYLE_FILLED_RASTER:
                HSset_maximum_z( (double)(0x1fffffff) );
                active_window->ignore_locked_zbuffer = TRUE;
                break;

            default:
            case HS_STYLE_SMOOTH:
            case HS_STYLE_CONSTANT:
                HSset_maximum_z( (double)(0x7fffffff) );
                active_window->ignore_locked_zbuffer = shaded_plotting;
                break;
            }
        }		
    }

/*---HSzbuffer_24_locked--------------------------------------------------------------*/

IGRint	HSzbuffer_24_locked( int vs_no )

	{
fprintf( stderr, "HSzbuffer_24_locked: always returns FALSE\n" );
	return( /*hardwar_flags[vs_no] & HShardware_ZB_24*/FALSE );
	}

/*--------------------------------*/

