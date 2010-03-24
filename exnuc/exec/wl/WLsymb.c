#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "wl.h"
#include "wl_internal.h"

extern int WLIglx_last_win_type;
extern int WLhilite_enabled;

/*--WLdefine_style-----------------------------------------*/

int WLdefine_style(
	int lstyle_no,
	WLuint16 pattern )
/*
NAME
	WLdefine_style

KEYWORD
	WL

DESCRIPTION
	This function defines a line style specified by "pattern"
	and associates it with lstyle_no.

SYNOPSIS
	int WLdefine_style(
        	int lstyle_no,
        	WLuint16 pattern )


PARAMETERS
	lstyle_no (IN) - The logical style number
	pattern (IN) - The 16 bit style pattern

GLOBALS USED
	not yet

RETURN VALUES
	WL_SUCCESS
		Success

	WL_BAD_STYLE_NUMBER
		The logical style number is < 0 or >= WL_MAX_STYLES

HISTORY
	08/28/92 S.P.Rogers
		Initial definition

	10/22/92 Shridar Subramanian
		Initial design
*/
{
   if ( ( lstyle_no < 0 ) || ( lstyle_no >= WL_MAX_STYLES ) )
   {
      WL_REPORT_ERROR( WL_BAD_STYLE_NUMBER );
      return ( WL_BAD_STYLE_NUMBER );
   }

   WLIline_style[lstyle_no].pattern = pattern;
   WLIline_style[lstyle_no].change_count = (WLuint8)
     ( (WLint32) (WLIline_style[lstyle_no].change_count + 1) % 256 );
   if( WLIline_style_factor == WLI_TRUE )
   {
      WLIline_style[lstyle_no].pattern_factor = 2;
   }
   else
   {
      WLIline_style[lstyle_no].pattern_factor = 1;
   }
      ( (WLint32) (WLIline_style[lstyle_no].change_count + 1) % 256 );
#if defined( X11 ) || defined( WIN32 )
   if ( pattern == 0xffff )
   {
      WLIline_style[lstyle_no].flags |= WLI_STYLE_SOLID;
      WLIline_style[lstyle_no].nitems = 1;
      WLIline_style[lstyle_no].offset = 0;
      WLIline_style[lstyle_no].dash_list[0] = 16;
      /* Set the half hilight dash list  */
      WLIconvert_dashes_with_blend( WLIline_style[lstyle_no].nitems,
                                    WLIline_style[lstyle_no].offset,
                                    WLIline_style[lstyle_no].dash_list,
                                    &WLIline_style[lstyle_no].hh_nitems,
                                    WLIline_style[lstyle_no].hh_dash_list );
   }
   else
   {
      WLIstyle_convert_to_dashes(pattern,&WLIline_style[lstyle_no].nitems,
         &WLIline_style[lstyle_no].offset,
         WLIline_style[lstyle_no].dash_list);

      /* Set the half hilight dash list  */
      WLIconvert_dashes_with_blend( WLIline_style[lstyle_no].nitems,
                                    WLIline_style[lstyle_no].offset,
                                    WLIline_style[lstyle_no].dash_list,
                                    &WLIline_style[lstyle_no].hh_nitems,
                                    WLIline_style[lstyle_no].hh_dash_list );

      WLIline_style[lstyle_no].hh_offset = WLIline_style[lstyle_no].offset;
           
      WLIline_style[lstyle_no].flags &= ~WLI_STYLE_SOLID;
   }
#if defined( XGL )
      /* sys_state is a global defined in WLinit.c */
   WLIline_style[lstyle_no].lpat = 
                     xgl_object_create( sys_state, XGL_LPAT, NULL, 
                                        XGL_LPAT_DATA_TYPE, XGL_DATA_INT,
                                        XGL_LPAT_DATA_SIZE,
                                        (Xgl_usgn32)WLIline_style[lstyle_no].nitems,
                                        XGL_LPAT_DATA,
                                        WLIline_style[lstyle_no].dash_list,
                                        XGL_LPAT_OFFSET,
                                        (float)WLIline_style[lstyle_no].offset,
                                        XGL_LPAT_STYLE,XGL_LPAT_FIXED_OFFSET,
                                        NULL );
               
   WLIline_style[lstyle_no].hh_lpat = 
                    xgl_object_create( sys_state, XGL_LPAT, NULL, 
                                       XGL_LPAT_DATA_TYPE, XGL_DATA_INT,
                                       XGL_LPAT_DATA_SIZE,
                                       (Xgl_usgn32)WLIline_style[lstyle_no].hh_nitems,
                                       XGL_LPAT_DATA,
                                       WLIline_style[lstyle_no].hh_dash_list,
                                       XGL_LPAT_OFFSET,
                                       (float)WLIline_style[lstyle_no].hh_offset,
                                       XGL_LPAT_STYLE,XGL_LPAT_FIXED_OFFSET,
                                       NULL );
               
   
   
#endif
#endif

   return ( WL_SUCCESS );

} /* WLdefine_style */


/*--- WLget_defined_style -----------------------------------------*/

int WLget_defined_style(
	int lstyle_no,
	WLuint16 *pattern )

/*
NAME
	WLget_defined_style

KEYWORD
	WL

DESCRIPTION
	This function gets the bit pattern for a logical style.

SYNOPSIS
	int WLget_defined_style(
		int lstyle_no,
		WLuint16 *pattern )

PARAMETERS
	lstyle_no (IN) - The logical style number
	pattern (OUT) - The 16 bit pattern

GLOBALS USED
	not yet

RETURN VALUES
	WL_SUCCESS
		Success

	WL_BAD_STYLE_NUMBER
		The logical style number is  < 0 or >= WL_MAX_STYLES

	WL_BAD_PARAMETER
		The pattern pointer is NULL

HISTORY
	08/28/92 S.P.Rogers
    		Initial definition

	10/22/92 Shridar Subramanian
		Initial design
*/
{
   if ( !pattern )
   {
      WL_REPORT_ERROR( WL_BAD_PARAMETER );
      return ( WL_BAD_PARAMETER );
   }

   if ( ( lstyle_no < 0 ) || ( lstyle_no >= WL_MAX_STYLES ) )
   {
      WL_REPORT_ERROR( WL_BAD_STYLE_NUMBER );
      return ( WL_BAD_STYLE_NUMBER );
   }

   *pattern = WLIline_style[lstyle_no].pattern;

   return ( WL_SUCCESS );

} /* WLget_defined_style */

/*--- WLset_active_symbology ------------------------------------------------*/

int WLset_active_symbology(
   WLuint32 lwin_no,
   WLcolorref color_ref,
   int lstyle_no,
   WLuint16 blend,
   int weight,
   int change_mask )

/*
NAME
   WLset_active_symbology

KEYWORD
   WL

DESCRIPTION
   This function sets the active symbology.  All subsequent drawing
   functions will use this symbology.

SYNOPSIS
   int WLset_active_symbology(
      WLuint32 lwin_no,
      WLcolorref color_ref,
      int lstyle_no,
      WLuint16 blend,
      int weight,
      int change_mask )

PARAMETERS
   lwin_no (IN) - logical window number
   context_no (IN)  - context number
   color_ref (IN) - packed color
   lstyle_no (IN) - logical line style
   blend (IN) - the 16 bit blending mask for the style
   weight (IN) - the new weight
   change_mask (IN) - mask indicating what values are to be changed

GLOBALS USED
   not yet

RETURN VALUES
   WL_SUCCESS
      Success

   WL_BAD_WINDOW_NUMBER
      The logical window number is invalid

   WL_BAD_STYLE_NUMBER
      The logical style number is  < 0 or > WL_MAX_STYLES

   WL_BAD_WEIGHT
      The weight is < 0 or > WL_MAX_WEIGHT

RELATED INFORMATION
   Functions: WLcreate_window()

HISTORY
   08/28/92 Shridar Subramanian
      Initial definition

   10/22/92 Shridar Subramanian
      Initial design
*/
{
   int status;

   if ( ( change_mask & WL_SYMB_CHANGE_STYLE ) &&
        ( ( lstyle_no < 0 ) || ( lstyle_no > WL_MAX_STYLES ) ) )
   {
      WL_REPORT_ERROR( WL_BAD_STYLE_NUMBER );
      return( WL_BAD_STYLE_NUMBER );
   }

   if ( ( change_mask & WL_SYMB_CHANGE_WEIGHT ) &&
        ( ( weight < 0 ) || ( weight > WL_MAX_WEIGHT ) ) )
   {
      WL_REPORT_ERROR( WL_BAD_WEIGHT );
      return( WL_BAD_WEIGHT );
   }
   /* validate color */

   if ( change_mask & WL_SYMB_CHANGE_STYLE )
   {
      status = WLIwin_set_active_style( lwin_no, lstyle_no, blend );
      if (status != WL_SUCCESS)
      {
         WL_REPORT_ERROR( status );
         return( status );
      }
   }

   if ( change_mask & WL_SYMB_CHANGE_WEIGHT )
   {
      status = WLIwin_set_active_weight( lwin_no, weight );
      if ( status != WL_SUCCESS )
      {
         WL_REPORT_ERROR( status );
         return( status );
      }
   }

   if ( change_mask & WL_SYMB_CHANGE_COLOR )
   {
      status = WLIwin_set_active_foreground( lwin_no, color_ref );

      if ( status != WL_SUCCESS )
      {
         WL_REPORT_ERROR( status );
         return (status);
      }
   }

   return( WL_SUCCESS );

}  /* WLset_active_symbology */

/*--- WLIset_background_helper ---------------------------------------*/

static int WLIset_background_helper(
   WLuint32 lwin_no,
   void *data )

/*
NAME
   WLIset_background_helper (static)

KEYWORD
   WL (INTERNAL)

DESCRIPTION
   This function is used as a helper by WLset_background when it has
   to set the background for all WL windows.  This function will be
   called for each WL window by WLIenumerate_windows().

SYNOPSIS
   static int WLIset_background_helper(
      WLuint32 lwin_no,
      void *data )

PARAMETERS
   lwin_no (IN) - the logical window number
   data (IN) - data passed through WLIenumerate_windows

GLOBALS USED
   none

RETURN VALUES
   WL_SUCCESS
      Success

   WL_BAD_WINDOW_NUMBER
      The logical window number is bad
*/

{
   int status;
   struct WLIwin win_struct;

   status = WLIwin_retrieve_entry( lwin_no, &win_struct );
   if ( status != WL_SUCCESS)
   {
      WL_REPORT_ERROR( status );
      return( status );
   }

   if ( win_struct.flags & WLI_WIN_FLAGS_WL_CREATED )
   {
      return( WLset_background( lwin_no, *((WLcolorref *) data ) ) );
   }

   return( WL_SUCCESS );

}  /* WLIset_background_helper */


/*--- WLset_background -----------------------------------------------*/

int WLset_background(
   WLuint32 lwin_no,
   WLcolorref color_ref)

/*
NAME
   WLset_background

KEYWORD
   WL

DESCRIPTION
   This function sets the background color of the "main window".
   If 'lwin_no' is WL_UNDEFINED_WINDOW, all windows known by
   WL will have their background set.

SYNOPSIS
   int WLset_background(
      WLuint32 lwin_no,
      WLcolorref color_ref)

NOTE
   Depending on how the transparent windows are implemented in Xlib, we
   may use the context_no parameter to set the background colors for
   different individual contexts.
   context_no (IN) - context number

PARAMETERS
   lwin_no (IN)  - logical window number, WL_UNDEFINED_WINDOW for all
                   WL windows
   color_ref (IN) - packed color

GLOBALS USED
   none

RETURN VALUES
   WL_SUCCESS
      Success

   WL_BAD_WINDOW_NUMBER
      The logical window number is invalid

   WL_BAD_COLOR_SPECIFICATION
      The colormap mapping function "cmap_entry_func" for this
      color failed.

   WL_BAD_RGB
      Either the red or the green or the blue value is < 0
      or > WL_MAX_COLOR

    WL_BAD_COLOR_INDEX
      The logical color index is invalid
 
RELATED INFORMATION
   Functions: WLcreate_window()
 
HISTORY
   08/28/92 Shridar Subramanian
      Initial definition
 
   10/22/92 Shridar Subramanian
      Initial design
*/
{
   
   int status;
   struct WLIwin win_struct;
   struct WLIcontext context_struct;
   WLuint32 color_index = 0;
   WLuint32 red = 0;
   WLuint32 green = 0;
   WLuint32 blue = 0;
   WLuint32 out_red = 0;
   WLuint32 out_green = 0;
   WLuint32 out_blue = 0;
   WLuint32 color_flag = 0;
   unsigned int background;
#if defined ( WIN32 )
   LOGBRUSH logbrush;
#elif defined ( X11 )
   int left_shift_factor, right_shift_factor;
#if defined( XGL )
   Xgl_color xgl_color;
#endif
#endif


   if ( lwin_no == WL_UNDEFINED_WINDOW )
   {
      status = WLIenumerate_windows( WLIset_background_helper, &color_ref );
      if ( status != WL_SUCCESS)
      {
         WL_REPORT_ERROR( status );
         return( status );
      }
   }
   else
   {
      status = WLIwin_retrieve_entry( lwin_no, &win_struct );
      if ( status != WL_SUCCESS)
      {
         WL_REPORT_ERROR( status );
         return( status );
      }

      status = WLIcontext_retrieve_entry( win_struct.context_no, &context_struct );
      if ( status != WL_SUCCESS )
      {
         WL_REPORT_ERROR( status );
         return( status );
      }

      status = WLIwin_unpack_colorref( color_ref, &color_index, &red, &green,
               &blue, &color_flag );
      if ( status != WL_SUCCESS )
      {
         WL_REPORT_ERROR( status );
         return( status );
      }

      if ( context_struct.base_cmap_type == WL_CMAP_TRUE_COLOR )
      {
         /* Use the RGB values */
         if ( (color_flag & WL_COLOR_RGB) &&
              ( (red > WL_MAX_COLOR) || (green > WL_MAX_COLOR) || (blue > WL_MAX_COLOR) ) )
         {
            WL_REPORT_ERROR( WL_BAD_RGB );
            return( WL_BAD_RGB );
         }

         if ( (color_flag & WL_COLOR_PHYSICAL) && !(color_flag & WL_COLOR_RGB) )
         {
            WL_REPORT_ERROR( WL_BAD_COLOR_REF );
            return( WL_BAD_COLOR_REF );
         }
      
         if ( color_flag & WL_COLOR_PHYSICAL )
         {
            out_red = red;
            out_green = green;
            out_blue = blue;
         }
         else
         {
            (*context_struct.cmap_color_to_rgb)(
               win_struct.context_no, color_index, red, green,
               blue, color_flag, &out_red, &out_green, &out_blue );
         }

#if defined( OPENGL )
         if ( win_struct.flags & WLI_WIN_FLAGS_USING_OPENGL )
         {
#if defined( X11 )
            WLglx_make_window_current( lwin_no, WL_GLX_BASE_WIN );
#endif
            glClearColor( (GLclampf) (out_red / (float) WL_MAX_COLOR),
                          (GLclampf) (out_green / (float) WL_MAX_COLOR),
                          (GLclampf) (out_blue / (float) WL_MAX_COLOR),
                          0.0 );
#if defined( X11 )
            if ( win_struct.flags & WLI_WIN_SEPARATE_HILITE )
            {
               WLglx_make_window_current( lwin_no, WL_GLX_HILITE_WIN );
               /* load in the transparent index for clearing */
               glClearIndex( context_struct.hl_native_info.transparent_index );
            }
#endif
         }
#endif

#if defined ( X11 )
         red = out_red >> context_struct.right_shifter;
         green = out_green >> context_struct.right_shifter;
         blue = out_blue >> context_struct.right_shifter;
#if defined( XGL )
         if ( win_struct.flags & WLI_WIN_FLAGS_USING_XGL )
         {
            xgl_color.rgb.r = 1.0 * red / WL_MAX_COLOR; 
            xgl_color.rgb.g = 1.0 * green / WL_MAX_COLOR;
            xgl_color.rgb.b = 1.0 * blue / WL_MAX_COLOR;
            xgl_object_set( win_struct.native_info.xgl_context_3D,
                            XGL_CTX_BACKGROUND_COLOR, &xgl_color, NULL );
         }
#endif
            
         background = ( blue << context_struct.blue_shifter ) |
                      ( green << context_struct.green_shifter ) |
                      ( red << context_struct.red_shifter );

         XSetWindowBackground( win_struct.native_info.EXdisplay, win_struct.hwin_no, background );
         XSetBackground( win_struct.native_info.EXdisplay,
                         win_struct.native_info.EXgc, background );
         if ( win_struct.flags & WLI_WIN_SEPARATE_HILITE )
         {
            background = 0;
#if defined( XGL )
            if ( win_struct.flags & WLI_WIN_FLAGS_USING_XGL )
            {
               xgl_color.index=context_struct.hl_native_info.transparent_index;
               xgl_object_set( win_struct.native_info.hl_xgl_context_3D,
                               XGL_CTX_BACKGROUND_COLOR, &xgl_color, NULL );
            }
#else
            XSetWindowBackground( win_struct.native_info.EXdisplay, 
                                  win_struct.hl_hwin_no, background );
#endif
            XSetBackground( win_struct.native_info.EXdisplay,
                            win_struct.hl_native_info.hl_gc, background ); 
         }

#elif defined (ENV5 )

         red = out_red >> context_struct.right_shifter;
         green = out_green >> context_struct.right_shifter;
         blue = out_blue >> context_struct.right_shifter;
         background = ( blue << context_struct.blue_shifter ) |
                      ( green << context_struct.green_shifter ) |
                      ( red << context_struct.red_shifter );

         bgdata( win_struct.hwin_no, IMAGE_DATA, background );

#elif defined ( WIN32 )
         /* Delete the old background brush and set a new one */
         logbrush.lbStyle = BS_SOLID;
         logbrush.lbColor = PALETTERGB( out_red, out_green, out_blue );
         logbrush.lbHatch = 0;

         DeleteObject(
            (HGDIOBJ) SetClassLong( win_struct.hwin_no, GCL_HBRBACKGROUND,
                       (LONG) CreateBrushIndirect( &logbrush ) ) );
         SetBkColor( win_struct.native_info.hdc,
                     PALETTERGB( out_red, out_green, out_blue ) );
#endif
      }
      else
      {
         if ( (color_flag & WL_COLOR_PHYSICAL) && (color_flag & WL_COLOR_RGB) )
         {
            WL_REPORT_ERROR( WL_BAD_COLOR_REF );
            return( WL_BAD_COLOR_REF );
         }

         if ( !(color_flag & WL_COLOR_PHYSICAL) )
         {
            (*context_struct.cmap_color_to_index)(
               win_struct.context_no, color_index, red, green, blue,
               color_flag, &background );
         }
         else
         {
            background = color_index;
         }

#if defined( OPENGL )
         if ( win_struct.flags & WLI_WIN_FLAGS_USING_OPENGL )
         {
#if defined( X11 )
            WLglx_make_window_current( lwin_no, WL_GLX_BASE_WIN );
#endif
            glClearIndex( (GLfloat) background );

#if defined( X11 )
            if ( win_struct.flags & WLI_WIN_SEPARATE_HILITE )
            {
               WLglx_make_window_current( lwin_no, WL_GLX_HILITE_WIN );
               /* load in the transparent index for clearing */
               glClearIndex( context_struct.hl_native_info.transparent_index );
            }
#endif
         }
#endif

#if defined ( X11 )
#if defined( XGL )
         if ( win_struct.flags & WLI_WIN_FLAGS_USING_XGL )
         {
            xgl_color.index = background;
            xgl_object_set( win_struct.native_info.xgl_context_3D,
                            XGL_CTX_BACKGROUND_COLOR, &xgl_color, NULL );
         }
#endif
         XSetWindowBackground( win_struct.native_info.EXdisplay,
                               win_struct.hwin_no, background );
         XSetBackground( win_struct.native_info.EXdisplay,
                         win_struct.native_info.EXgc, background ); 
         if ( win_struct.flags & WLI_WIN_SEPARATE_HILITE )
         {
            background = 0;
#if defined( XGL )
            if ( win_struct.flags & WLI_WIN_FLAGS_USING_XGL )
            {
               xgl_color.index=context_struct.hl_native_info.transparent_index;
               xgl_object_set( win_struct.native_info.hl_xgl_context_3D,
                               XGL_CTX_BACKGROUND_COLOR, &xgl_color, NULL );
            }
#else
            XSetWindowBackground( win_struct.native_info.EXdisplay,
                                  win_struct.hl_hwin_no, background );
#endif
            XSetBackground( win_struct.native_info.EXdisplay,
                            win_struct.hl_native_info.hl_gc, background );
         }

#elif defined ( ENV5 )
         bgdata( win_struct.hwin_no, IMAGE_DATA, background);

#elif defined ( WIN32 )
         /* Delete the old background brush and set a new one */
         logbrush.lbStyle = BS_SOLID;
         logbrush.lbColor = PALETTEINDEX( background );
         logbrush.lbHatch = 0;

         DeleteObject(
            (HGDIOBJ) SetClassLong( win_struct.hwin_no, GCL_HBRBACKGROUND,
                       (LONG) CreateBrushIndirect( &logbrush ) ) );
         SetBkColor( win_struct.native_info.hdc,
                     PALETTEINDEX( background ) );
#endif
      }

      status = WLIwin_set_active_background( lwin_no, color_ref );
      if ( status != WL_SUCCESS )
      {
         WL_REPORT_ERROR( status );
         return( status );
      }
   }

   return ( WL_SUCCESS );
}  /* WLset_background */

/*--- WLactivate_symbology ------------------------------------------------*/

int WLactivate_symbology(
   WLuint32 lwin_no,
   int fill_flag,
   int force_flag )

/*
NAME
   WLactivate_symbology
 
KEYWORD
   WL
 
DESCRIPTION
   This function activates the current active symbology
   maintained by WL for a window by sending it to the
   native windowing system.

SYNOPSIS
   int WLactivate_symbology(
      WLuint32 lwin_no,
      int fill_flag,
      int force_flag )

PARAMETERS
   lwin_no (IN) - logical window number
   fill_flag (IN) - TRUE, if filled drawing is going to be done
   force_flag (IN) - if TRUE, send the symbology to the
                     windowing system regardless of whether
                     WL thinks it is up to date

NOTES
   This routine is designed to be used by applications who are
   bypassing the normal WL drawing routines and want WL to update
   the symbology to the windowing system immediatley instead of
   waiting for a drawing call to be made.  If an application is
   making WLset_active_symbology() calls and WLdraw_??? calls,
   this routine does not need to be called.

GLOBALS USED
   none

RETURN VALUES
   WL_SUCCESS
      Success

   WL_BAD_WINDOW_NUMBER
      The logical window number is invalid

HISTORY
   01/14/93 S.P. Rogers
      Initial definition

   01/14/93 S.P. Rogers
      Initial design

   01/14/93 S.P. Rogers
      Initial implementation
*/

{
   int status;
   struct WLIwin win_struct;
   struct WLIcontext context_struct;

   status = WLIwin_retrieve_entry( lwin_no, &win_struct );
   if (status != WL_SUCCESS)
   {
      WL_REPORT_ERROR( status );
      return ( status );
   }

   status = WLIcontext_retrieve_entry( win_struct.context_no, &context_struct );
   if (status != WL_SUCCESS)
   {
      WL_REPORT_ERROR( status );
      return ( status );
   }

   if ( force_flag )
   {
      /* force update of symbology by setting the window */
      /* flags to indicate the symbology has changed     */
      win_struct.flags |= (WLI_WIN_FLAGS_COLOR_CHANGED |
                           WLI_WIN_FLAGS_STYLE_CHANGED |
                           WLI_WIN_FLAGS_WEIGHT_CHANGED |
                           WLI_WIN_FLAGS_B_PATTERN_CHANGED);

      status = WLIwin_set_flags( lwin_no, win_struct.flags );
      if ( status != WL_SUCCESS )
      {
         WL_REPORT_ERROR( status );
         return( status );
      }
   }

   status = WLIactivate_symbology( &win_struct, &context_struct, fill_flag );
   if ( status != WL_SUCCESS )
   {
      WL_REPORT_ERROR( status );
      return( status );
   }

   return( WL_SUCCESS );

}  /* WLactivate_symbology */


/*--- WLget_background -----------------------------------------------*/

int WLget_background(
   WLuint32 lwin_no,
   WLcolorref *color_ref)

/*
NAME
   WLget_background

KEYWORD
   WL

DESCRIPTION
   This function gets the background color of the "main window".

SYNOPSIS
   int WLget_background(
      WLuint32 lwin_no,
      WLcolorref *color_ref)

PARAMETERS
   lwin_no (IN)  - logical window number
   color_ref (OUT) - packed color

GLOBALS USED
   not yet

RETURN VALUES
   WL_SUCCESS
      Success

   WL_BAD_WINDOW_NUMBER
      The logical window number is invalid

HISTORY
   03/04/93 Shridar Subramanian
      Initial definition
 
   03/04/93 Shridar Subramanian
      Initial design
*/
{
   
   int status;
   struct WLIwin win_struct;
   struct WLIcontext context_struct;

   status = WLIwin_retrieve_entry( lwin_no, &win_struct );
   if ( status != WL_SUCCESS )
   {
      WL_REPORT_ERROR( status );
      return( status );
   }
   
   status = WLIcontext_retrieve_entry( win_struct.context_no, &context_struct );
   if ( status != WL_SUCCESS )
   {
      WL_REPORT_ERROR( status );
      return( status );
   }
 
   if ( context_struct.base_cmap_type == WL_CMAP_TRUE_COLOR )
   {
      status = WLpack_rgb_colorref( win_struct.background_red, 
                                    win_struct.background_green, 
                                    win_struct.background_blue, color_ref, 1 );
      if ( status != WL_SUCCESS )
      {
         WL_REPORT_ERROR( status );
         return( status );
      }
   }
   else
   {
      status = WLpack_index_colorref( win_struct.background_color_index, 
                                      color_ref, 1 );
      if ( status != WL_SUCCESS )
      {
         WL_REPORT_ERROR( status );
         return( status );
      }
   }
   
   return( WL_SUCCESS );
} /* WLget_background */

/*---WLset_line_style_factor-----------------------------------------*/

int WLset_line_style_factor(
   int flag)
/*
NAME
   WLset_line_style_factor

KEYWORD
   WL

DESCRIPTION
   This function sets the global variable  WLIline_style_factor to TRUE/FALSE.
   This function was specifically written to solve the problem of pre-defined
   line-styles looking different on solaris in relation to the ENV5 and
   Sunos 4.1.3 X.

SYNOPSIS
   int WLset_line_style_factor(
         int flag )

PARAMETERS
    flag (IN) - TRUE/FALSE

GLOBALS USED
  WLIline_style_factor

RETURN VALUES
   WL_SUCCESS
      Success

HISTORY
   11/12/93 Shridar Subramanian
      Initial definition

   11/12/93 Ravi Parthasarathy
     Design
*/

{
#if defined ( X11 )
   if ( flag )
   {
      WLIline_style_factor = WLI_TRUE;
   }
   else
   {
     WLIline_style_factor = WLI_FALSE;
   }
#endif
  return ( WL_SUCCESS ) ;
} /* WLset_line_style_factor */




int WLenable_hilite( WLuint32 lwin_no )  
   { 
   int status;
   struct WLIwin win_struct;
   struct WLIcontext context_struct;

   WLhilite_enabled = 1; 
   status = WLIwin_retrieve_entry( lwin_no, &win_struct );
   if (status != WL_SUCCESS)
      {
      WL_REPORT_ERROR( status );
      return ( status );
      }

   /* force update of symbology by setting the window */
   /* flags to indicate the symbology has changed     */
   win_struct.flags |= (WLI_WIN_FLAGS_COLOR_CHANGED |
                        WLI_WIN_FLAGS_STYLE_CHANGED |
                        WLI_WIN_FLAGS_WEIGHT_CHANGED |
                        WLI_WIN_FLAGS_B_PATTERN_CHANGED);

   status = WLIwin_set_flags( lwin_no, win_struct.flags );
   if ( status != WL_SUCCESS )
      {
      WL_REPORT_ERROR( status );
      return( status );
      }
   }

void WLdisable_hilite() { WLhilite_enabled = 1; }
   
