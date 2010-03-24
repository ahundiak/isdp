#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "wl.h"
#include "wl_internal.h"

#if defined( X11 )
#if defined( XGL )


static WLuint32 last_lwin_no = WL_UNDEFINED_WINDOW;
static int last_win_type = -1;

extern WLhilite_enabled;

/*
#define	XGL_HILITE_COLOR	2
*/

static int	XglHiliteColor = -1;

#if XGL_HILITE_COLOR
#define SetXglHiliteColor \
{ \
if( XglHiliteColor == -1 ) \
   { \
   char	*l, *getenv(); \
 \
   XglHiliteColor = XGL_HILITE_COLOR; \
   l = getenv( "XGL_HILITE_COLOR" ); \
   if( l != NULL ) \
      sscanf( l, "%d", &XglHiliteColor ); \
   fprintf( stderr, "XglHiliteColor: %d\n", XglHiliteColor ); \
   } \
}
#endif

/*--- WLIclear_window_XGL ----------------------------------------*/

static int WLIclear_window_XGL(
   struct WLIwin *win_struct,
   struct WLIcontext *context_struct )

/*
NAME
   WLIclear_window_XGL (static)

KEYWORD
   WLI

DESCRIPTION
   This is the XGL implementation of WLclear_window
   for indexed windows without separate hilite windows.

SYNOPSIS
   static int WLIclear_window_XGL(
      struct WLIwin *win_struct,
      struct WLIcontext *context_struct )

PARAMETERS
   win_struct (IN) - window structure
   context_struct (IN) - context structure

GLOBALS USED
   none

RETURN VALUES
   WL_SUCCESS - Success
   WL_SYSTEM_ERROR - Windowing system error

HISTORY
   02/16/94 Shridar Subramanian
      Extracted from WLclear_window
*/

{
   xgl_context_new_frame( win_struct->native_info.xgl_context_3D );
   return( WL_SUCCESS );
} /* WLIclear_window_XGL */

/*--- WLIclear_window_XGL_HL ----------------------------------------*/

static int WLIclear_window_XGL_HL(
   struct WLIwin *win_struct,
   struct WLIcontext *context_struct )

/*
NAME
   WLIclear_window_XGL_HL (static)

KEYWORD
   WLI

DESCRIPTION
   This is the XGL implementation of WLclear_window
   for indexed windows with separate hilite windows.

SYNOPSIS
   static int WLIclear_window_XGL_HL(
      struct WLIwin *win_struct,
      struct WLIcontext *context_struct )

PARAMETERS
   win_struct (IN) - window structure
   context_struct (IN) - context structure

GLOBALS USED
   none

RETURN VALUES
   WL_SUCCESS - Success
   WL_SYSTEM_ERROR - Windowing system error

HISTORY
   02/16/94 Shridar Subramanian
      Extracted from WLclear_window
*/

{
   Xgl_attribute attr_list[3] = { XGL_CTX_PAINT_TYPE, 
                                  XGL_CTX_PLANE_MASK, 0};

   xgl_context_new_frame( win_struct->native_info.xgl_context_3D );

   xgl_context_push(  win_struct->native_info.hl_xgl_context_3D,
                      attr_list );

   xgl_object_set(  win_struct->native_info.hl_xgl_context_3D,
                    /*XGL_CTX_PLANE_MASK, context_struct->hilite_mask,*/
                    XGL_CTX_PAINT_TYPE, XGL_PAINT_TRANSPARENT, NULL );
   xgl_context_new_frame( win_struct->native_info.hl_xgl_context_3D );
   xgl_context_pop(  win_struct->native_info.hl_xgl_context_3D );
   return( WL_SUCCESS );

} /* WLIclear_window_XGL_HL */


/*--- WLIclear_hilite_XGL-----------------------------------------------*/
 
static int WLIclear_hilite_XGL(
   struct WLIwin *win_struct,
   struct WLIcontext *context_struct )
 
/*
NAME
   WLIclear_hilite_XGL ( static )
 
KEYWORD
   WLI
 
DESCRIPTION
   This is the XGL implemenation of WLclear_hilite without
   separate hilite windows.

SYNOPSIS
   static int WLIclear_hilite_XGL(
      struct WLIwin *win_struct,
      struct WLIcontext *context_struct )
 
PARAMETERS
   win_struct (IN) - The window structure
   context_struct (IN) - The context structure
 
GLOBALS USED
   none
 
RETURN VALUES
   WL_SUCCESS
      Success
 
NOTES
   This function assumes a TRUE COLOR context because we
   can't have TRUE COLOR in X (the only XGL implementation)
   without having separate hilite.

HISTORY
   02/16/94 Shridar Subramanian
      Initial definition and design
*/

{
   Xgl_attribute attr_list[2] = { XGL_CTX_PLANE_MASK, 0};

   xgl_context_push(  win_struct->native_info.xgl_context_3D,
                      attr_list );
   xgl_object_set( win_struct->native_info.xgl_context_3D,
                   XGL_CTX_PLANE_MASK, context_struct->hilite_mask, NULL );
   xgl_context_new_frame( win_struct->native_info.xgl_context_3D );
   xgl_context_pop(  win_struct->native_info.xgl_context_3D );
   return( WL_SUCCESS );
}  /* WLIclear_hilite_XGL */

/*--- WLIclear_hilite_XGL_HL-----------------------------------------------*/
 
static int WLIclear_hilite_XGL_HL(
   struct WLIwin *win_struct,
   struct WLIcontext *context_struct )
 
/*
NAME
   WLIclear_hilite_XGL_HL ( static )
 
KEYWORD
   WLI
 
DESCRIPTION
   This is the XGL implemenation of WLclear_hilite with
   separate hilite windows.

SYNOPSIS
   static int WLIclear_hilite_XGL_HL(
      struct WLIwin *win_struct,
      struct WLIcontext *context_struct )
 
PARAMETERS
   win_struct (IN) - The window structure
   context_struct (IN) - The context structure
 
GLOBALS USED
   none
 
RETURN VALUES
   WL_SUCCESS
      Success
 
RELATED INFORMATION
 
HISTORY
   02/16/94 Shridar Subramanian
      Initial definition and design
*/

{

   /* The background color is the transparent color for overlay planes */

if( WLhilite_enabled )
{
   xgl_context_new_frame( win_struct->native_info.hl_xgl_context_3D );
}

   return( WL_SUCCESS );
}  /* WLIclear_hilite_XGL_HL */

/*--- WLIset_drawing_mode_XGL -------------------------------------------*/

static int WLIset_drawing_mode_XGL(
   struct WLIwin *win_struct,
   struct WLIcontext *context_struct,
   int base_mask,
   int hilite_mask )

/*
NAME
   WLIset_drawing_mode_XGL (static)
 
KEYWORD
   WLI

DESCRIPTION
   This is the XGL implemenation of WLset_drawing_mode without
   separate hilite windows.

SYNOPSIS
   static int WLIset_drawing_mode_XGL(
      struct WLIwin *win_struct,
      struct WLIcontext *context_struct,
      int base_mask,
      int hilite_mask )

PARAMETERS
   win_struct (IN) - The window structure
   context_struct (IN) - The context structure
   base_mask (IN) - The base mask
   hilite_mask (IN) - The hilite mask

GLOBALS USED
   none

RETURN VALUES
   WL_SUCCESS
      Success

HISTORY
   06/28/94 Shridar Subramanian
      Initial definition and design
*/

{
   xgl_object_set( win_struct->native_info.xgl_context_3D, XGL_CTX_PLANE_MASK,
                   base_mask | hilite_mask, 0 );

   return( WL_SUCCESS );
} /*  WLIset_drawing_mode_XGL */

/*--- WLIset_drawing_mode_XGL_HL -------------------------------------------*/

static int WLIset_drawing_mode_XGL_HL(
   struct WLIwin *win_struct,
   struct WLIcontext *context_struct,
   int base_mask,
   int hilite_mask )

/*
NAME
   WLIset_drawing_mode_XGL_HL (static)
 
KEYWORD
   WLI

DESCRIPTION
   This is the XGL implemenation of WLset_drawing_mode with
   separate hilite windows.

SYNOPSIS
   static int WLIset_drawing_mode_XGL_HL(
      struct WLIwin *win_struct,
      struct WLIcontext *context_struct,
      int base_mask,
      int hilite_mask )

PARAMETERS
   win_struct (IN) - The window structure
   context_struct (IN) - The context structure
   base_mask (IN) - The base mask
   hilite_mask (IN) - The hilite mask

GLOBALS USED
   none

RETURN VALUES
   WL_SUCCESS
      Success

HISTORY
   02/16/94 Shridar Subramanian
      Initial definition and design
*/

{

   if ( context_struct->base_cmap_type == WL_CMAP_INDEXED )
   {
      xgl_object_set( win_struct->native_info.xgl_context_3D, 
                      XGL_CTX_PLANE_MASK,
                      base_mask, 0 );
   }
/* TRUE COLOR ???????? */

if( WLhilite_enabled )
{
   xgl_object_set( win_struct->native_info.hl_xgl_context_3D, 
                   XGL_CTX_PLANE_MASK,
                   hilite_mask, 0 );
}

   return( WL_SUCCESS );
} /*  WLIset_drawing_mode_XGL_HL */

/*--- WLIset_dynamics_drawing_mode_XGL -------------------------------------------*/

static int WLIset_dynamics_drawing_mode_XGL(
   struct WLIwin *win_struct,
   struct WLIcontext *context_struct,
   int mode )

/*
NAME
   WLIset_dynamics_drawing_mode_XGL (static)
 
KEYWORD
   WLI

DESCRIPTION
   This is the XGL implemenation of WLset_dynamics_drawing_mode
   without separate hilite windows.

SYNOPSIS
   static int WLIset_dynamics_drawing_mode_XGL(
      struct WLIwin *win_struct,
      struct WLIcontext *context_struct,
      int mode );

PARAMETERS
   win_struct (IN) - The window structure
   context_struct (IN) - The context structure
   mode (IN) - the drawing mode

GLOBALS USED
   none

RETURN VALUES
   WL_SUCCESS
      Success

HISTORY
   02/16/94 Shridar Subramanian
      Initial definition and design
*/

{

   /*if ( mode == WL_DYN_ERASE_MODE )
   {
      xgl_object_set( win_struct->native_info.xgl_context_3D, 
                      XGL_CTX_PLANE_MASK,0, 0 );
   }
   else <<>> removed per shridar (ML) */
   {
      xgl_object_set( win_struct->native_info.xgl_context_3D, 
                      XGL_CTX_PLANE_MASK, 
                      context_struct->hilite_mask, 0 );
   }

   return( WL_SUCCESS );
} /*  WLIset_dynamics_drawing_mode_XGL */

/*--- WLIset_dynamics_drawing_mode_XGL_HL -------------------------------------------*/

static int WLIset_dynamics_drawing_mode_XGL_HL(
   struct WLIwin *win_struct,
   struct WLIcontext *context_struct,
   int mode )

/*
NAME
   WLIset_dynamics_drawing_mode_XGL_HL (static)
 
KEYWORD
   WLI

DESCRIPTION
   This is the XGL implemenation of WLset_dynamics_drawing_mode
   with separate hilite windows.

SYNOPSIS
   static int WLIset_dynamics_drawing_mode_XGL_HL(
      struct WLIwin *win_struct,
      struct WLIcontext *context_struct,
      int mode )

PARAMETERS
   win_struct (IN) - The window structure
   context_struct (IN) - The context structure
   mode (IN) - the drawing mode

GLOBALS USED
   none

RETURN VALUES
   WL_SUCCESS
      Success

HISTORY
   06/28/94 Shridar Subramanian
      Initial definition and design
*/

{
   /*if ( mode == WL_DYN_ERASE_MODE )
   {
      xgl_object_set( win_struct->native_info.hl_xgl_context_3D, 
                      XGL_CTX_PLANE_MASK,0, 0 );
   }
   else <<>> removed per shridar (ML) */
   {
      xgl_object_set( win_struct->native_info.hl_xgl_context_3D, 
                      XGL_CTX_PLANE_MASK, 
                      context_struct->hilite_mask, 0 );
   }

   return( WL_SUCCESS );
} /*  WLIset_dynamics_drawing_mode_XGL_HL */



/*---WLIget_fg_and_hl_XGL_IX-----------------------------------------*/

static int WLIget_fg_and_hl_XGL_IX(
   struct WLIwin *win_struct,
   struct WLIcontext *context_struct)

/*
NAME
	WLIget_fg_and_hl_XGL_IX
 
KEYWORD
	WLI (static)
 
DESCRIPTION
	This is an XGL implementation of get_fg_and_hl without
        separate hilite windows 

SYNOPSIS
        int WLIget_fg_and_hl_XGL_IX(
           struct WLIwin *win_struct,
           struct WLIcontext *context_struct )

PARAMETERS
	win_struct (IN) - The window structure
	context_struct (IN) - The context structure
 
RETURN VALUES
	WL_SUCCESS
		Success

HISTORY
	07/02/94 Shridar Subramanian
		Initial definition, implementation
*/
{
   Xgl_color xgl_color;
   int    sts;

   if ( ( win_struct->flags & WLI_WIN_BASE_MASK ) == WLI_WIN_FLAGS_BASE_DRAW )
   {
      xgl_color.index = win_struct->color_index;
   }
   else
   {
      xgl_color.index = win_struct->background_color_index;
   }

   if ( ( win_struct->flags & WLI_WIN_HILITE_MASK ) == WLI_WIN_FLAGS_HILITE_DRAW )
   {
      xgl_color.index |= 1 << context_struct->base_depth;
   }
   
   xgl_object_set( win_struct->native_info.xgl_context_3D, 
                   XGL_3D_CTX_SURF_BACK_COLOR, &xgl_color,
                   XGL_CTX_SURF_FRONT_COLOR, &xgl_color,
                   XGL_CTX_LINE_COLOR, &xgl_color,
                   XGL_CTX_STEXT_COLOR, &xgl_color,NULL );
                  
   return( WL_SUCCESS );

}/* WLIget_fg_and_hl_XGL_IX */

/*---WLIget_fg_and_hl_XGL_IX_HL-----------------------------------------*/

static int WLIget_fg_and_hl_XGL_IX_HL(
   struct WLIwin *win_struct,
   struct WLIcontext *context_struct)

/*
NAME
	WLIget_fg_and_hl_XGL_IX_HL
 
KEYWORD
	WLI (static)
 
DESCRIPTION
	This is an XGL implementation of get_fg_and_hl with
        separate hilite windows 

SYNOPSIS
        int WLIget_fg_and_hl_XGL_IX_HL(
           struct WLIwin *win_struct,
           struct WLIcontext *context_struct )

PARAMETERS
	win_struct (IN) - The window structure
	context_struct (IN) - The context structure
 
RETURN VALUES
	WL_SUCCESS
		Success

HISTORY
	07/02/94 Shridar Subramanian
		Initial definition, implementation
*/
{
   int sts;
   Xgl_color xgl_color;
   Xgl_paint_type paint_type;

   if ( (win_struct->flags & WLI_WIN_HILITE_MASK) != WLI_WIN_FLAGS_HILITE_NOOP )
   {
      if ( ( win_struct->flags & WLI_WIN_HILITE_MASK ) == WLI_WIN_FLAGS_HILITE_DRAW )
      {
         xgl_color.index = context_struct->hl_native_info.opaque_index;
         paint_type = XGL_PAINT_OPAQUE; /* <<>> was OPAQUE */
      }
      else
      {
         xgl_color.index = context_struct->hl_native_info.transparent_index;
         paint_type = XGL_PAINT_TRANSPARENT;
      }

      xgl_object_set( win_struct->native_info.hl_xgl_context_3D, 
                      XGL_3D_CTX_SURF_BACK_COLOR, &xgl_color,
                      XGL_CTX_SURF_FRONT_COLOR, &xgl_color,
                      XGL_CTX_LINE_COLOR, &xgl_color,
                      XGL_CTX_STEXT_COLOR, &xgl_color,
                      XGL_CTX_PAINT_TYPE, paint_type, NULL );

   }
   

   if ( (win_struct->flags & WLI_WIN_BASE_MASK) != WLI_WIN_FLAGS_BASE_NOOP )
   {
      if ( ( win_struct->flags & WLI_WIN_BASE_MASK ) == WLI_WIN_FLAGS_BASE_DRAW )
      {
         xgl_color.index = win_struct->color_index;
      }
      else
      {
         xgl_color.index = win_struct->background_color_index;
      }
      xgl_object_set( win_struct->native_info.xgl_context_3D, 
                      XGL_3D_CTX_SURF_BACK_COLOR, &xgl_color,
                      XGL_CTX_SURF_FRONT_COLOR, &xgl_color,
                      XGL_CTX_LINE_COLOR, &xgl_color,
                      XGL_CTX_STEXT_COLOR, &xgl_color,NULL );


   }

   return( WL_SUCCESS );

} /* WLIget_fg_and_hl_XGL_IX_HL */

/*---WLIget_fg_and_hl_XGL_TC_HL-----------------------------------------*/

static int WLIget_fg_and_hl_XGL_TC_HL(
   struct WLIwin *win_struct,
   struct WLIcontext *context_struct)

/*
NAME
	WLIget_fg_and_hl_XGL_TC_HL
 
KEYWORD
	WLI (static)
 
DESCRIPTION
	This is an XGL implementation of get_fg_and_hl with
        separate hilite windows 

SYNOPSIS
        int WLIget_fg_and_hl_XGL_TC_HL(
           struct WLIwin *win_struct,
           struct WLIcontext *context_struct )

PARAMETERS
	win_struct (IN) - The window structure
	context_struct (IN) - The context structure
 
RETURN VALUES
	WL_SUCCESS
		Success

HISTORY
	07/02/94 Shridar Subramanian
		Initial definition, implementation
*/
{
   int sts;
   Xgl_color xgl_color;
   Xgl_paint_type paint_type;

   if ( (win_struct->flags & WLI_WIN_HILITE_MASK) != WLI_WIN_FLAGS_HILITE_NOOP )
   {
      if ( ( win_struct->flags & WLI_WIN_HILITE_MASK ) == WLI_WIN_FLAGS_HILITE_DRAW )
      {
         xgl_color.index = context_struct->hl_native_info.opaque_index;
         paint_type = XGL_PAINT_OPAQUE; /* <<>> was OPAQUE */
#if XGL_HILITE_COLOR
SetXglHiliteColor
xgl_color.index = XglHiliteColor;
#endif
      }
      else
      {
         xgl_color.index = context_struct->hl_native_info.transparent_index;
         paint_type = XGL_PAINT_TRANSPARENT;
      }

      xgl_object_set( win_struct->native_info.hl_xgl_context_3D, 
                      XGL_3D_CTX_SURF_BACK_COLOR, &xgl_color,
                      XGL_CTX_SURF_FRONT_COLOR, &xgl_color,
                      XGL_CTX_LINE_COLOR, &xgl_color,
                      XGL_CTX_STEXT_COLOR, &xgl_color,
                      XGL_CTX_PAINT_TYPE, paint_type, NULL );

   }
      
   if ( (win_struct->flags & WLI_WIN_BASE_MASK) != WLI_WIN_FLAGS_BASE_NOOP )
   {
      if ( (win_struct->flags & WLI_WIN_BASE_MASK) == WLI_WIN_FLAGS_BASE_DRAW )
      {
         xgl_color.rgb.r = (( float )win_struct->red)/WL_MAX_COLOR;
         xgl_color.rgb.g = (( float )win_struct->green)/WL_MAX_COLOR;
         xgl_color.rgb.b = (( float )win_struct->blue)/WL_MAX_COLOR;
      }
      else
      {
         xgl_color.rgb.r = (( float )win_struct->background_red)/WL_MAX_COLOR;
         xgl_color.rgb.g = (( float )win_struct->background_green)/WL_MAX_COLOR;
         xgl_color.rgb.b = (( float )win_struct->background_blue)/WL_MAX_COLOR;
      }
      xgl_object_set( win_struct->native_info.xgl_context_3D, 
                      XGL_3D_CTX_SURF_BACK_COLOR, &xgl_color,
                      XGL_CTX_SURF_FRONT_COLOR, &xgl_color,
                      XGL_CTX_LINE_COLOR, &xgl_color,
                      XGL_CTX_STEXT_COLOR, &xgl_color,NULL );

   }

   return( WL_SUCCESS );
}/* WLIget_fg_and_hl_XGL_TC_HL */

/*---WLIget_fg_and_hl_XGL_TC-----------------------------------------*/

static int WLIget_fg_and_hl_XGL_TC(
   struct WLIwin *win_struct,
   struct WLIcontext *context_struct)

/*
NAME
	WLIget_fg_and_hl_XGL_TC
 
KEYWORD
	WLI (static)
 
DESCRIPTION
	This is an XGL implementation of get_fg_and_hl without
        separate hilite windows 

SYNOPSIS
        int WLIget_fg_and_hl_XGL_TCHL(
           struct WLIwin *win_struct,
           struct WLIcontext *context_struct )

PARAMETERS
	win_struct (IN) - The window structure
	context_struct (IN) - The context structure
 
RETURN VALUES
	WL_SUCCESS
		Success

HISTORY
	07/02/94 Shridar Subramanian
		Initial definition, implementation
*/
{
   int sts;
   Xgl_color xgl_color;

   if ( (win_struct->flags & WLI_WIN_BASE_MASK) != WLI_WIN_FLAGS_BASE_NOOP )
   {
      if ( (win_struct->flags & WLI_WIN_BASE_MASK) == WLI_WIN_FLAGS_BASE_DRAW )
      {
         xgl_color.rgb.r = (( float )win_struct->red)/WL_MAX_COLOR;
         xgl_color.rgb.g = (( float )win_struct->green)/WL_MAX_COLOR;
         xgl_color.rgb.b = (( float )win_struct->blue)/WL_MAX_COLOR;
      }
      else
      {
         xgl_color.rgb.r = (( float )win_struct->background_red)/WL_MAX_COLOR;
         xgl_color.rgb.g = (( float )win_struct->background_green)/WL_MAX_COLOR;
         xgl_color.rgb.b = (( float )win_struct->background_blue)/WL_MAX_COLOR;
      }
      xgl_object_set( win_struct->native_info.xgl_context_3D, 
                      XGL_3D_CTX_SURF_BACK_COLOR, &xgl_color,
                      XGL_CTX_SURF_FRONT_COLOR, &xgl_color,
                      XGL_CTX_LINE_COLOR, &xgl_color,
                      XGL_CTX_STEXT_COLOR, &xgl_color,NULL );

   }

   return( WL_SUCCESS );
}/* WLIget_fg_and_hl_XGL_TC_HL */

/*---WLIactivate_symbology_XGL-----------------------------------------*/

static int WLIactivate_symbology_XGL(
   struct WLIwin *win_struct,
   struct WLIcontext *context_struct,
   struct WLIstyle_struct *style_struct,
   int fill_flag )

/*
NAME
	WLIactivate_symbology_XGL
 
KEYWORD
	WLI (static)
 
DESCRIPTION
	This is an XGL implementation of WLIactivate_symbology without
        separate hilite windows 

SYNOPSIS
        int WLIactivate_symbology_XGL(
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
	07/02/94 Shridar Subramanian
		Initial definition, implementation
*/

{
   int    sts;
   Xgl_color xgl_color;
   Xgl_lpat  lpat;
   Xgl_line_style line_style;
   Xgl_surf_fill_style fill_style;
   


   /* color */
   /* Change the foreground color only if not in dynamics */
   if ( !( win_struct->flags & WLI_WIN_FLAGS_DYNAMICS_ON ) )
   {
      (*win_struct->get_fg_and_hl_XGL)(win_struct, context_struct);
                                          
   }
   else if ( context_struct->hilite_used )
   {
      /* dynamics is on and we have a hilite plane => use the dynamic */
      /* drawing mode to determine how to set the hilite color        */

      if ( win_struct->flags & WLI_WIN_FLAGS_DYNAMICS_DRAW )
      {
         xgl_color.index = 1 << context_struct->base_depth;
      }
      else
      {
         xgl_color.index = 0;
      }
      xgl_object_set( win_struct->native_info.xgl_context_3D, 
                      XGL_3D_CTX_SURF_BACK_COLOR, &xgl_color,
                      XGL_CTX_SURF_FRONT_COLOR, &xgl_color,
                      XGL_CTX_LINE_COLOR, &xgl_color,
                      XGL_CTX_STEXT_COLOR, &xgl_color,NULL );


   }

   /* gl style */
   if( win_struct->active_blend == 0xaaaa )
   {
      lpat = style_struct->hh_lpat;
   }
   else
   {
      lpat = style_struct->lpat;
   }
   if ( ( style_struct->flags & WLI_STYLE_SOLID ) &&
        ( win_struct->active_blend == 0xffff) ) 
   {
      line_style = XGL_LINE_SOLID;
   }
   else
   {
      line_style = XGL_LINE_PATTERNED;
   }

   /* xgl pattern */
   if ( (!fill_flag ) || ( win_struct->flags & WLI_WIN_FLAGS_B_PATTERN_SOLID ) )
   {
      fill_style = XGL_SURF_FILL_SOLID;
      xgl_object_set( win_struct->native_info.xgl_context_3D, 
                      XGL_CTX_SURF_FRONT_FILL_STYLE, fill_style,
                      XGL_3D_CTX_SURF_BACK_FILL_STYLE, fill_style,
                      NULL );
   }
   else
   {
      fill_style = XGL_SURF_FILL_STIPPLE;
      xgl_object_set( win_struct->native_info.xgl_context_3D, 
                      XGL_CTX_SURF_FRONT_FILL_STYLE, fill_style,
                      XGL_3D_CTX_SURF_BACK_FILL_STYLE, fill_style,
                      XGL_CTX_SURF_FRONT_FPAT, 
                      win_struct->native_info.mem_ras,
                      XGL_3D_CTX_SURF_BACK_FPAT, 
                      win_struct->native_info.mem_ras,
                      NULL );
   }


   if ( line_style == XGL_LINE_SOLID )
   {
      xgl_object_set( win_struct->native_info.xgl_context_3D, 
                      XGL_CTX_LINE_WIDTH_SCALE_FACTOR, 
                      (float)(win_struct->active_weight+1),
                      XGL_CTX_LINE_STYLE, line_style, NULL );
   }
   else
   {
      xgl_object_set( win_struct->native_info.xgl_context_3D, 
                      XGL_CTX_LINE_WIDTH_SCALE_FACTOR, 
                      (float)(win_struct->active_weight+1),
                      XGL_CTX_LINE_STYLE, line_style,
                      XGL_CTX_LINE_PATTERN, lpat, NULL );
   }
                   

   return( WL_SUCCESS );
} /* WLIactivate_symbology_XGL */

/*---WLIactivate_symbology_XGL_HL-----------------------------------------*/

static int WLIactivate_symbology_XGL_HL(
   struct WLIwin *win_struct,
   struct WLIcontext *context_struct,
   struct WLIstyle_struct *style_struct,
   int fill_flag )

/*
NAME
	WLIactivate_symbology_XGL_HL
 
KEYWORD
	WLI (static)
 
DESCRIPTION
	This is an XGL implementation of WLIactivate_symbology with
        separate hilite windows 

SYNOPSIS
        int WLIactivate_symbology_XGL_HL(
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
	07/02/94 Shridar Subramanian
		Initial definition, implementation
*/

{
   int    sts;
   Xgl_color xgl_color;
   Xgl_lpat  lpat;
   Xgl_line_style line_style;
   Xgl_surf_fill_style fill_style;
   Xgl_paint_type paint_type;

   /* Change the foreground color only if not in dynamics */
   if ( !( win_struct->flags & WLI_WIN_FLAGS_DYNAMICS_ON ) )
   {
      (*win_struct->get_fg_and_hl_XGL)(win_struct, context_struct);
                                          
   }
   else
   {
      
      /* dynamics is on and we have a hilite plane => use the dynamic */
      /* drawing mode to determine how to set the hilite color        */

      if ( win_struct->flags & WLI_WIN_FLAGS_DYNAMICS_DRAW )
      {
         xgl_color.index = context_struct->hl_native_info.opaque_index;
         paint_type = XGL_PAINT_OPAQUE; /* <<>> was OPAQUE */
#if XGL_HILITE_COLOR
SetXglHiliteColor
xgl_color.index = XglHiliteColor;
#endif
      }
      else
      {
         xgl_color.index = context_struct->hl_native_info.transparent_index;
         paint_type = XGL_PAINT_TRANSPARENT;
      }

      xgl_object_set( win_struct->native_info.hl_xgl_context_3D, 
                      XGL_3D_CTX_SURF_BACK_COLOR, &xgl_color,
                      XGL_CTX_SURF_FRONT_COLOR, &xgl_color,
                      XGL_CTX_LINE_COLOR, &xgl_color,
                      XGL_CTX_STEXT_COLOR, &xgl_color,
                      XGL_CTX_PAINT_TYPE, paint_type, NULL );


   }

   /* style and weight and pattern */
   if ( (!(win_struct->flags & WLI_WIN_FLAGS_DYNAMICS_ON)) &&
        ((win_struct->flags & WLI_WIN_BASE_MASK) != WLI_WIN_FLAGS_BASE_NOOP) )
   {
      /* gl style */
      if( win_struct->active_blend == 0xaaaa )
      {
         lpat = style_struct->hh_lpat;
      }
      else
      {
         lpat = style_struct->lpat;
      }
      if (  ( style_struct->flags & WLI_STYLE_SOLID )  &&
           ( win_struct->active_blend == 0xFFFF ) )
      {
         line_style = XGL_LINE_SOLID;
      }
      else
      {
         line_style = XGL_LINE_PATTERNED;
      }

      if ( (!fill_flag ) || ( win_struct->flags & WLI_WIN_FLAGS_B_PATTERN_SOLID ) )
      {
         fill_style = XGL_SURF_FILL_SOLID;
         xgl_object_set( win_struct->native_info.xgl_context_3D, 
                         XGL_CTX_SURF_FRONT_FILL_STYLE, fill_style,
                         XGL_3D_CTX_SURF_BACK_FILL_STYLE, fill_style,
                         NULL );
      }
      else
      {
         fill_style = XGL_SURF_FILL_STIPPLE;
         xgl_object_set( win_struct->native_info.xgl_context_3D, 
                         XGL_CTX_SURF_FRONT_FILL_STYLE, fill_style,
                         XGL_3D_CTX_SURF_BACK_FILL_STYLE, fill_style,
                         XGL_CTX_SURF_FRONT_FPAT, 
                         win_struct->native_info.mem_ras,
                         XGL_3D_CTX_SURF_BACK_FPAT, 
                         win_struct->native_info.mem_ras,
                         NULL );
      }


      if ( line_style == XGL_LINE_SOLID )
      {
         xgl_object_set( win_struct->native_info.xgl_context_3D, 
                         XGL_CTX_LINE_WIDTH_SCALE_FACTOR, 
                         (float)(win_struct->active_weight+1),
                         XGL_CTX_LINE_STYLE, line_style, NULL );
      }
      else
      {
         xgl_object_set( win_struct->native_info.xgl_context_3D, 
                         XGL_CTX_LINE_WIDTH_SCALE_FACTOR, 
                         (float)(win_struct->active_weight+1),
                         XGL_CTX_LINE_STYLE, line_style,
                         XGL_CTX_LINE_PATTERN, lpat, NULL );
      }
                      
   }

   if ( (win_struct->flags & WLI_WIN_FLAGS_DYNAMICS_ON) ||
        ( (win_struct->flags & WLI_WIN_HILITE_MASK) 
                                   != WLI_WIN_FLAGS_HILITE_NOOP) )
   {
      /* gl style */
      if( win_struct->active_blend == 0xaaaa )
      {
         lpat = style_struct->hh_lpat;
      }
      else
      {
         lpat = style_struct->lpat;
      }
      if (  ( style_struct->flags & WLI_STYLE_SOLID ) &&
           ( win_struct->active_blend == 0xFFFF ) )
      {
         line_style = XGL_LINE_SOLID;
      }
      else
      {
         line_style = XGL_LINE_PATTERNED;
      }

      if ( (!fill_flag ) || ( win_struct->flags & WLI_WIN_FLAGS_B_PATTERN_SOLID ) )
      {
         fill_style = XGL_SURF_FILL_SOLID;
         xgl_object_set( win_struct->native_info.hl_xgl_context_3D, 
                         XGL_CTX_SURF_FRONT_FILL_STYLE, fill_style,
                         XGL_3D_CTX_SURF_BACK_FILL_STYLE, fill_style,
                         NULL );
      }
      else
      {
       /*Uncomment this when blendarea is supported in overlay planes */ 
/*
         fill_style = XGL_SURF_FILL_STIPPLE;
         xgl_object_set( win_struct->native_info.hl_xgl_context_3D, 
                         XGL_CTX_SURF_FRONT_FILL_STYLE, fill_style,
                         XGL_3D_CTX_SURF_BACK_FILL_STYLE, fill_style,
                         XGL_CTX_SURF_FRONT_FPAT, 
                         win_struct->native_info.hl_mem_ras,
                         XGL_3D_CTX_SURF_BACK_FPAT, 
                         win_struct->native_info.hl_mem_ras,
                         NULL );
*/
      }

      if ( line_style == XGL_LINE_SOLID )
      {
         xgl_object_set( win_struct->native_info.hl_xgl_context_3D, 
                         XGL_CTX_LINE_WIDTH_SCALE_FACTOR, 
                         (float)(win_struct->active_weight+1),
                         XGL_CTX_LINE_STYLE, line_style, NULL );
      }
      else
      {
         xgl_object_set( win_struct->native_info.hl_xgl_context_3D, 
                         XGL_CTX_LINE_WIDTH_SCALE_FACTOR, 
                         (float)(win_struct->active_weight+1),
                         XGL_CTX_LINE_STYLE, line_style,
                         XGL_CTX_LINE_PATTERN, lpat, NULL );
      }
                      
   }

   return( WL_SUCCESS );
} /* WLIactivate_symbology_XGL_HL */

/*--- WLIset_window_functions_XGL --------------------------------*/

int WLIset_window_functions_XGL(
   struct WLIwin *win_struct )

/*
NAME
   WLIset_window_functions_XGL

DESCRIPTION
   This function sets the functions pointers for a window
   that supports XGL

SYNOPSIS
   int WLIset_window_functions_XGL(
      struct WLIwin *win_struct )

PARAMETERS
   win_struct (IN) - the window structure to set

GLOBALS USED
   none

RETURN VALUES
   WL_SUCCESS
      Success

HISTORY
   06/28/94  Shridar Subramanian
      Intitial design and implementation
*/

{
   struct WLIcontext context_struct;
   int sts;

   if ( win_struct->flags & WLI_WIN_FLAGS_USING_XGL )
   {
      sts = WLIcontext_retrieve_entry( win_struct->context_no, &context_struct );
      if ( sts != WL_SUCCESS )
      {
         WL_REPORT_ERROR( sts );
         return( sts );
      }

      if ( win_struct->flags & WLI_WIN_SEPARATE_HILITE )
      {
         win_struct->clear_hilite = WLIclear_hilite_XGL_HL;
         win_struct->set_drawing_mode = WLIset_drawing_mode_XGL_HL;
         win_struct->set_dynamics_drawing_mode = WLIset_dynamics_drawing_mode_XGL_HL;
         win_struct->activate_symbology = WLIactivate_symbology_XGL_HL;
         win_struct->clear_window = WLIclear_window_XGL_HL;
         if( context_struct.base_cmap_type == WL_CMAP_INDEXED )
         {
            win_struct->get_fg_and_hl_XGL = WLIget_fg_and_hl_XGL_IX_HL;
         }
         else
         {
            win_struct->get_fg_and_hl_XGL = WLIget_fg_and_hl_XGL_TC_HL;
         }
      }
      else
      {
         win_struct->clear_hilite = WLIclear_hilite_XGL;
         win_struct->set_drawing_mode = WLIset_drawing_mode_XGL;
         win_struct->set_dynamics_drawing_mode = WLIset_dynamics_drawing_mode_XGL;
         win_struct->activate_symbology = WLIactivate_symbology_XGL;
         win_struct->clear_window = WLIclear_window_XGL;
         if( context_struct.base_cmap_type == WL_CMAP_INDEXED )
         {
            win_struct->get_fg_and_hl_XGL = WLIget_fg_and_hl_XGL_IX;
         }
         else
         {
            win_struct->get_fg_and_hl_XGL = WLIget_fg_and_hl_XGL_TC;
         }
      }
   }
 
   return( WL_SUCCESS );

} /* WLIset_window_functions_XGL */


/*--- WLxgl_get_window_contexts -------------------------------------*/

int WLxgl_get_window_contexts( 
   WLuint32 lwin_no,
   Xgl_object *xgl_context_3D,
   Xgl_object *hl_xgl_context_3D )

/*
NAME
   WLxgl_get_window_contexts

KEYWORD
   WL

DESCRIPTION
   This function gets the XGL rendering context(s) for a 
        logical window.

SYNOPSIS
int WLxgl_get_window_contexts( 
   WLuint32 lwin_no,
   Xgl_object *xgl_context_3D,
   Xgl_object *hl_xgl_context_3D )

PARAMETERS
   lwin_no (IN) - the window whose context is to be retrieved
   xgl_context_3D (OUT) - the XGL rendering context; NULL, if an XGL
                       rendering context doesn't exist for the window
   hl_xgl_context_3D (OUT) - the XGL rendering context for the hilite
                          window; NULL, if a separate hilite window
                          doesn't exist

RETURN VALUES
   WL_SUCCESS
      Success

   WL_BAD_PARAMETER
      'xgl_context_3D' or 'hl_xgl_context_3D' is NULL.

   WL_BAD_WINDOW_NUMBER
      The logical window number is invalid.

GLOBALS USED
   none

HISTORY
   01/11/93    S.P. Rogers
      Initial definition
*/
{
   int status;
   struct WLIwin win_struct;

   if ( (! xgl_context_3D) || (! hl_xgl_context_3D) )
   {
      WL_REPORT_ERROR( WL_BAD_PARAMETER );
      return( WL_BAD_PARAMETER );
   }

   status = WLIwin_retrieve_entry( lwin_no, &win_struct );
   if ( status != WL_SUCCESS )
   {
      WL_REPORT_ERROR( status );
      return( status );
   }

   if ( win_struct.flags & WLI_WIN_FLAGS_USING_XGL )
   {
      *xgl_context_3D = win_struct.native_info.xgl_context_3D;
      *hl_xgl_context_3D = win_struct.native_info.hl_xgl_context_3D;
   }
   else
   {
      *xgl_context_3D = *hl_xgl_context_3D = NULL;
   }

   return( WL_SUCCESS );

}  /* WLxgl_get_window_contexts */

static Xgl_matrix_f3d	imat = {
   { 1.0, 0.0, 0.0, 0.0 },
   { 0.0, 1.0, 0.0, 0.0 },
   { 0.0, 0.0, 1.0, 0.0 },
   { 0.0, 0.0, 0.0, 1.0 } };

/*--- WLxgl_enter_2D -------------------------------------*/

int WLxgl_enter_2D( WLuint32 lwin_no, int hilite )

/*
NAME
   WLxgl_enter_2D

KEYWORD
   WL

DESCRIPTION
   This function sets up 2D for hilite or base depending on the flag hilite

SYNOPSIS
   int WLxgl_enter_2D( WLuint32 lwin_no, int hilite )

PARAMETERS
   lwin_no (IN) - the window whose context is to be retrieved
   hilite (IN) - whether the hilite or the base is to be converted

RETURN VALUES
   WL_SUCCESS
      Success

   WL_BAD_WINDOW_NUMBER
      The logical window number is invalid.

GLOBALS USED
   none

HISTORY
   01/11/93    S.P. Rogers
      Initial definition
*/

   {
   int			sts;
   struct WLIwin	*win_struct;
   Xgl_bounds_d3d	xgl_window;
   Xgl_attribute	push_attr_list[6] = {XGL_CTX_GLOBAL_MODEL_TRANS,
					     XGL_CTX_LOCAL_MODEL_TRANS,
					     XGL_CTX_VIEW_TRANS,
					     /*XGL_CTX_DC_VIEWPORT,*/
					     XGL_CTX_VDC_WINDOW, NULL };


   sts = WLIwin_retrieve_entry_ptr( lwin_no, &win_struct );
   if ( win_struct->flags & WLI_WIN_FLAGS_USING_XGL )
      {
      xgl_window.xmin = 0;
      xgl_window.xmax = win_struct->area_bounds.width -1;
      xgl_window.ymin = 0;
      xgl_window.ymax = win_struct->area_bounds.height -1;

      /*  Translate the viewport up and left by half its extent  */
      /*  I was having to do this to get perspective eye points  */
      /*  in the middle of the viewport.  (ML)                   */

      xgl_window.xmax = win_struct->area_bounds.width / 2;
      xgl_window.ymax = win_struct->area_bounds.height / 2;
      xgl_window.xmin = -xgl_window.xmax;
      xgl_window.ymin = -xgl_window.ymax;

      xgl_window.zmin = -1;
      xgl_window.zmax = 1;

      /*  2D display uses an identity matrix.  Add the translation */
      /*  to the matrix and load it AFFINE (non-perspective)       */

      imat[3][0] = (float)xgl_window.xmin;
      imat[3][1] = (float)xgl_window.ymin;

      if ( hilite )
         {
         if( WLhilite_enabled )
            {
            WLI_SETUP_XGL_FOR_2D( win_struct->native_info.hl_xgl_context_3D,
                                  win_struct->native_info.hl_global_model_trans,
                                  win_struct->native_info.hl_local_model_trans,
                                  win_struct->native_info.hl_view_trans, 0  );

            win_struct->native_info.hilite_in_2d=1;

            xgl_transform_write_specific( 
                  win_struct->native_info.hl_view_trans,
                  imat, 
                  XGL_TRANS_MEMBER_AFFINE );
            }
         }
      else
         {
         WLI_SETUP_XGL_FOR_2D( win_struct->native_info.xgl_context_3D,
                               win_struct->native_info.global_model_trans,
                               win_struct->native_info.local_model_trans,
                               win_struct->native_info.view_trans, 0  );

         win_struct->native_info.base_in_2d=1;

         xgl_transform_write_specific( 
               win_struct->native_info.view_trans,
               imat, 
               XGL_TRANS_MEMBER_AFFINE );
         }
      }
   
   return( WL_SUCCESS );

   }  /* WLxgl_enter_2D */


/*--- WLxgl_exit_2D -------------------------------------*/

int WLxgl_exit_2D( WLuint32 lwin_no, int hilite )

/*
NAME
   WLxgl_exit_2D

KEYWORD
   WL

DESCRIPTION
   This function exits 2D setup for hilite or base depending on the flag hilite

SYNOPSIS
   int WLxgl_exit_2D( WLuint32 lwin_no, int hilite )

PARAMETERS
   lwin_no (IN) - the window whose context is to be retrieved
   hilite (IN) - whether the hilite or the base is to be converted

RETURN VALUES
   WL_SUCCESS
      Success

   WL_BAD_WINDOW_NUMBER
      The logical window number is invalid.

GLOBALS USED
   none

HISTORY
   01/11/93    S.P. Rogers
      Initial definition
*/

   {
   int			sts;
   struct WLIwin	*win_struct;
   Xgl_bounds_d3d	xgl_window;
   Xgl_attribute	push_attr_list[6] = {XGL_CTX_GLOBAL_MODEL_TRANS,
					     XGL_CTX_LOCAL_MODEL_TRANS,
					     XGL_CTX_VIEW_TRANS,
					     /*XGL_CTX_DC_VIEWPORT,*/
					     XGL_CTX_VDC_WINDOW, NULL };


   sts = WLIwin_retrieve_entry_ptr( lwin_no, &win_struct );
   if ( win_struct->flags & WLI_WIN_FLAGS_USING_XGL )
      {
      if ( hilite )
         {
         if( WLhilite_enabled )
            {
            WLI_RESTORE_XGL_TO_3D( win_struct->native_info.hl_xgl_context_3D, 
                                   0 );

            win_struct->native_info.hilite_in_2d=0;
            }
         }
      else
         {
         WLI_RESTORE_XGL_TO_3D( win_struct->native_info.xgl_context_3D, 0 );
         win_struct->native_info.base_in_2d=0;
         }
      }
   
   return( WL_SUCCESS );

   }  /* WLxgl_exit_2D */

#endif  /* XGL */
#endif  /* X11 */
