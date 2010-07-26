#if defined( WIN32 )

#include "wl.h"
#include "wl_internal.h"

/*--- WLIclear_window_WIN32 ----------------------------------------*/

static int WLIclear_window_WIN32(
   struct WLIwin *win_struct,
   struct WLIcontext *context_struct )

/*
NAME
   WLIclear_window_WIN32 (static)

KEYWORD
   WLI

DESCRIPTION
   This is the WIN32 implementation of WLclear_window.

SYNOPSIS
   static int WLIclear_window_WIN32(
      struct WLIwin *win_struct,
      struct WLIcontext *context_struct )

PARAMETERS
   win_struct (IN) - window structure
   context_struct (IN) - context structure

GLOBALS USED
   none

RETURN VALUES
   WL_SUCCESS
      Success

HISTORY
   06/25/93 S.P. Rogers
      Extracted from WLclear_window
*/

{
   HBRUSH brush_handle;
   RECT rect;

   /* get the background brush for the window and fill */
   /* the entire client area of the window with it     */ 
   brush_handle = (HBRUSH)GetClassLong( win_struct->hwin_no, GCL_HBRBACKGROUND );
   GetClientRect( win_struct->hwin_no, &rect );
   FillRect( win_struct->native_info.hdc, &rect, brush_handle );
   return( WL_SUCCESS );
} /* WLIclear_window_WIN32 */

/*--- WLIclear_hilite_WIN32 ----------------------------------------------------*/

static int WLIclear_hilite_WIN32(
   struct WLIwin *win_struct,
   struct WLIcontext *context_struct )

/*
NAME
   WLIclear_hilite_WIN32 (static)

DESCRIPTION
   This is the WIN32 implementation of WLclear_hilite

KEYWORD
   WLI

SYNOPSIS
   static int WLIclear_hilite_WIN32(
      struct WLIwin *win_struct,
      struct WLIcontext *context_struct )

PARAMETERS
   win_struct (IN) - window structure
   context_struct (IN) - context structure

GLOBALS USED
   none

RETURN VALUES
   WL_SUCCESS
      Success

HISTORY
   06/25/93 S.P. Rogers
      Extracted from WLclear_hilite
*/

{
   /* hilite not implemented in WIN32 */
   return( WL_SUCCESS );
} /* WLIclear_hilite_WIN32 */

/*--- WLIset_drawing_mode_WIN32 ----------------------------------------------------*/

static int WLIset_drawing_mode_WIN32(
   struct WLIwin *win_struct,
   struct WLIcontext *context_struct,
   int base_mask,
   int hilite_mask )

/*
NAME
   WLIset_drawing_mode_WIN32 (static)

DESCRIPTION
   This is the WIN32 implementation of WLset_drawing_mode

KEYWORD
   WLI

SYNOPSIS
   static int WLIset_drawing_mode_WIN32(
      struct WLIwin *win_struct,
      struct WLIcontext *context_struct,
      int base_mask,
      int hilite_mask )

PARAMETERS
   win_struct (IN) - window structure
   context_struct (IN) - context structure
   base_mask (IN) - the base mask to use
   hilite_mask (IN) the hilite mask to use

GLOBALS USED
   none

RETURN VALUES
   WL_SUCCESS
      Success

HISTORY
   06/29/93 S.P. Rogers
      Extracted from WLset_drawing_mode
*/

{
   /* drawing modes not implemented in WIN32 */
   return( WL_SUCCESS );
} /* WLIset_drawing_mode_WIN32 */

/*--- WLIset_dynamics_drawing_mode_WIN32 ----------------------------------------------------*/

static int WLIset_dynamics_drawing_mode_WIN32(
   struct WLIwin *win_struct,
   struct WLIcontext *context_struct,
   int mode )

/*
NAME
   WLIset_dynamics_drawing_mode_WIN32 (static)

DESCRIPTION
   This is the WIN32 implementation of WLset_dynamics_drawing_mode

KEYWORD
   WLI

SYNOPSIS
   static int WLIset_drawing_mode_WIN32(
      struct WLIwin *win_struct,
      struct WLIcontext *context_struct,
      int mode )

PARAMETERS
   win_struct (IN) - window structure
   context_struct (IN) - context structure
   mode (IN) - the dynamics drawing mode

GLOBALS USED
   none

RETURN VALUES
   WL_SUCCESS
      Success

HISTORY
   06/29/93 S.P. Rogers
      Extracted from WLset_dynamics_drawing_mode
*/

{
   /* drawing modes not implemented in WIN32 */
   return( WL_SUCCESS );
} /* WLIset_dynamics_drawing_mode_WIN32 */



/*---WLIactivate_symbology_WIN32-----------------------------------------*/

static int WLIactivate_symbology_WIN32(
   struct WLIwin *win_struct,
   struct WLIcontext *context_struct,
   struct WLIstyle_struct *style_struct,
   int fill_flag )

/*
NAME
	WLIactivate_symbology_WIN32
 
KEYWORD
	WLI (static)
 
DESCRIPTION
	This is an WIN32 implementation of WLIactivate_symbology without
        separate hilite windows 

SYNOPSIS
        int WLIactivate_symbology_WIN32(
           struct WLIwin *win_struct,
           struct WLIcontext *context_struct,
           struct WLIstyle_struct *style_struct,
           int fill_flag )

PARAMETERS
	win_struct (IN) - The window structure
	context_struct (IN) - The context structure
        style_struct (IN) - The style structure
        fill_flag (IN) - TRUE, if the drawing routine is going to fill
 
RETURN VALUES
	WL_SUCCESS
		Success

HISTORY
	07/02/93 Shridar Subramanian
		Initial definition, implementation
*/

{
   int    sts;
   int    foreground;
   int    fg_color, hl_color;
   COLORREF color_ref;
   LOGBRUSH logbrush;
   int index;
   int cplanes;

   /* color */
   /* Change the foreground color only if not in dynamics */
   if ( !( win_struct->flags & WLI_WIN_FLAGS_DYNAMICS_ON ) )
   {
      (*win_struct->get_fg_and_hl( win_struct, context_struct, 
                                  &fg_color, &hl_color );

         color_ref = 0;
         if ( context.base_cmap_type == WL_CMAP_TRUE_COLOR )
         {
            red = win.red >> 8;
            green = win.green >> 8;
            blue = win.blue >> 8;
            color_ref = PALETTERGB( red, green, blue );
         }
         else
         {
            color_ref = PALETTEINDEX( win.color_index );
         }
   }
   else if ( context.hilite_used )
   {
         /* dynamics is on and we have a hilite plane => use the dynamic */
         /* drawing mode to determine how to set the hilite color        */

         /* !!! if WIN32 ever supports plane masking / hilite planes !!! */
         /* !!! this case will have to have a WIN32 implementation !!!   */

   }
   else
   {
      /* dynamics is on and we don't have a hilite plane */

      /* Set the colorref to half the color table size as the pivot point */
      /* for XOR. This need to be done only for NT, because the colors    */
      /* can be maintained and need not be set all the time ( CreatePen ) */

      color_ref = 0;
      if ( context.base_cmap_type == WL_CMAP_TRUE_COLOR )
      {
         red =  ( WL_MAX_COLOR / 2 ) >>  8; 
         green =  ( WL_MAX_COLOR / 2 ) >>  8; 
         blue =  ( WL_MAX_COLOR / 2 ) >>  8; 
         color_ref = PALETTERGB( red, green, blue );
      }
      else
      {
         index = 1 <<  ( context.base_depth - 1 ); 
         color_ref = PALETTEINDEX( index );
      }
   }

   /* always set the text color */
   SetTextColor( win.native_info.hdc, color_ref );

   /* Create a brush for filling */
   if (  (!fill_flag) || (win.flags & WLI_WIN_FLAGS_B_PATTERN_SOLID) )
   {
      DeleteObject( SelectObject( win.native_info.hdc, 
                                  CreateSolidBrush( color_ref ) ) );
   }
   else
   {
      cplanes = GetDeviceCaps( win.native_info.hdc, PLANES );
      DeleteObject( SelectObject( win.native_info.hdc,
                            CreatePatternBrush( CreateBitmap( 8, 8,
                                                cplanes, 1, 
                                                win.blend_pattern ) ) ) );
   }

   logbrush.lbStyle = BS_SOLID;
   logbrush.lbColor = color_ref;
   logbrush.lbHatch = 0;

   if ( win.active_weight > 0 )
   {
      if ( style_struct.flags & WLI_STYLE_SOLID )
      {
          DeleteObject( SelectObject( win.native_info.hdc, 
                                      ExtCreatePen( PS_GEOMETRIC | 
                                           PS_SOLID |PS_ENDCAP_FLAT | 
                                           PS_JOIN_MITER, win.active_weight + 1,
                                           &logbrush,(DWORD ) NULL, 
                                           ( LPDWORD ) NULL ) ) );
      }
      else
      {
          DeleteObject( SelectObject( win.native_info.hdc, 
                                      ExtCreatePen( 
                                          PS_GEOMETRIC | PS_USERSTYLE | 
                                          PS_ENDCAP_FLAT | PS_JOIN_MITER, 
                                          win.active_weight + 1, &logbrush, 
                                          ( DWORD )style_struct.nitems, 
                                          (LPDWORD ) style_struct.dash_list ) ) );
      }
   }
   else
   {
      if ( style_struct.flags & WLI_STYLE_SOLID )
      {
          DeleteObject( SelectObject( win.native_info.hdc,
                                      CreatePen( PS_SOLID, win.active_weight + 1,
                                                 color_ref ) ) );
      }
      else
      {
         DeleteObject( SelectObject( win.native_info.hdc,
                                     ExtCreatePen( 
                                         PS_GEOMETRIC | PS_USERSTYLE | 
                                         PS_ENDCAP_FLAT | PS_JOIN_MITER, 
                                         win.active_weight + 1, &logbrush, 
                                         ( DWORD )style_struct.nitems, 
                                         (LPDWORD ) style_struct.dash_list ) ) );
      }
   }
   return( WL_SUCCESS );

}/* WLIactivate_symbology_WIN32   */

/*--- WLIset_window_functions ------------------------------------------*/

int WLIset_window_functions(
   struct WLIwin *win_struct )

/*
NAME
   WLIset_window_functions

DESCRIPTION
   This function sets the function pointers for a window for
   WIN32 windows.

KEYWORD
   WLI

SYNOPSIS
   int WLIset_window_functions(
      struct WLIwin *win_struct )

PARAMETERS
   win_struct (IN) - pointer to the window structure

GLOBALS USED
   none

RETURN VALUES
   WL_SUCCESS - Success

HISTORY
   06/25/93 S.P. Rogers
      Initial creation.
*/

{

   win_struct->clear_window = WLIclear_window_WIN32;
   win_struct->clear_hilite = WLIclear_hilite_WIN32;
   win_struct->set_drawing_mode = WLIset_drawing_mode_WIN32;
   win_struct->set_dynamics_drawing_mode = WLIset_dynamics_drawing_mode_WIN32;
   win_struct->get_fg_and_hl = NULL;
   win_struct->activate_symbology = WLIactivate_symbology_WIN32;

   return( WL_SUCCESS );
} /* WLIset_window_functions */

#endif
