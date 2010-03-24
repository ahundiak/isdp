#if defined( X11 )

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "wl.h"
#include "wl_internal.h"

/*--- WLIclear_window_X ----------------------------------------*/

int WLIclear_window_X(
   struct WLIwin *win_struct,
   struct WLIcontext *context_struct )

/*
NAME
   WLIclear_window_X (static)

KEYWORD
   WLI

DESCRIPTION
   This is the X implementation of WLclear_window
   without separate hilite windows.

SYNOPSIS
   static int WLIclear_window_X(
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
   int sts;
   if( win_struct->flags & WLI_WIN_DOUBLE_BUFFER_DISPLAYED )
   {
      sts = WLIclear_double_buffer( win_struct, win_struct->hwin_no );
      if(sts != WL_SUCCESS )
      {
         WL_REPORT_ERROR( sts );
         return( sts );
      }
   }
   else
   {
      XClearWindow( win_struct->native_info.EXdisplay, win_struct->hwin_no );
   }

   return( WL_SUCCESS );
} /* WLIclear_window_X */

/*--- WLIclear_window_X_HL ----------------------------------------*/

static int WLIclear_window_X_HL(
   struct WLIwin *win_struct,
   struct WLIcontext *context_struct )

/*
NAME
   WLIclear_window_X_HL (static)

KEYWORD
   WLI

DESCRIPTION
   This is the X implementation of WLclear_window
   with separate hilite windows.

SYNOPSIS
   static int WLIclear_window_X_HL(
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
    int sts;
   if( win_struct->flags & WLI_WIN_DOUBLE_BUFFER_DISPLAYED )
   {
      sts = WLIclear_double_buffer( win_struct, win_struct->hwin_no );
      if(sts != WL_SUCCESS )
      {
         WL_REPORT_ERROR( sts );
         return( sts );
      }
   }
   else
   {
      XClearWindow( win_struct->native_info.EXdisplay, win_struct->hwin_no );
   }


   XClearWindow( win_struct->native_info.EXdisplay, win_struct->hl_hwin_no );

   return( WL_SUCCESS );
} /* WLIclear_window_X_HL */

/*--- WLIclear_hilite_X-----------------------------------------------*/
 
static int WLIclear_hilite_X(
   struct WLIwin *win_struct,
   struct WLIcontext *context_struct )
 
/*
NAME
   WLIclear_hilite_X ( static )
 
KEYWORD
   WLI
 
DESCRIPTION
   This is the X implementation of WLclear_hilite
   without separate hilite windows.

SYNOPSIS
   static int WLIclear_hilite(
      struct WLIwin *win_struct,
      struct WLIcontext *context_struct )
 
PARAMETERS
   win_struct ( IN) - The window structure
   context_struct ( IN) - The context structure
 
GLOBALS USED
   none
 
RETURN VALUES
   WL_SUCCESS
      Success
 
RELATED INFORMATION
 
HISTORY
   06/28/93 Shridar Subramanian
      Initial definition, design
*/
{
   int hl_color;
   unsigned long base_mask, hilite_mask;
   XGCValues old_gc_val;
   XGCValues old_gc_mask;

   if ( ! (win_struct->flags & WLI_WIN_FLAGS_DYNAMICS_ON) )
   {
      /* dynamics isn't on in this window => we must make */
      /* sure that only the hilite plane is enabled       */
      XSetPlaneMask( win_struct->native_info.EXdisplay,
                     win_struct->native_info.EXgc, context_struct->hilite_mask );
   }
   XGetGCValues( win_struct->native_info.EXdisplay,
                 win_struct->native_info.EXgc, GCPlaneMask , 
                 &old_gc_mask );
   XSetPlaneMask( win_struct->native_info.EXdisplay,
                   win_struct->native_info.EXgc, context_struct->hilite_mask );

   XSetForeground( win_struct->native_info.EXdisplay,
                   win_struct->native_info.EXgc, 0 );

   XGetGCValues( win_struct->native_info.EXdisplay,
                 win_struct->native_info.EXgc, GCFillStyle , 
                 &old_gc_val );

   XSetFillStyle( win_struct->native_info.EXdisplay,
                  win_struct->native_info.EXgc, FillSolid );

   XFillRectangle( win_struct->native_info.EXdisplay, win_struct->hwin_no,
                   win_struct->native_info.EXgc, 0, 0, 
                   win_struct->bounds.width, win_struct->bounds.height );

   XSetFillStyle( win_struct->native_info.EXdisplay,
                  win_struct->native_info.EXgc, old_gc_val.fill_style );

   XSetPlaneMask( win_struct->native_info.EXdisplay,
                   win_struct->native_info.EXgc, old_gc_mask.plane_mask );

   /* reset the planes appropriately */
   if ( win_struct->flags & WLI_WIN_FLAGS_DYNAMICS_ON )
   {
      /* dynamics is on, just reset the hilite data (color) */
      if ( win_struct->flags & WLI_WIN_FLAGS_DYNAMICS_DRAW )
      {
         hl_color = 1 << context_struct->base_depth;
      }
      else
      {
         hl_color = 0;
      }

      XSetForeground( win_struct->native_info.EXdisplay,
                      win_struct->native_info.EXgc, hl_color );
   }
   else
   {
      /* we are not in dynamics so we may be drawing into */ 
      /* base and hilite planes => reset appropriately    */
      if ( ! ((win_struct->flags & WLI_WIN_BASE_MASK) == WLI_WIN_FLAGS_BASE_NOOP) )
      {
         /* enable base planes */
         base_mask = context_struct->base_mask;
      }
      else
      {
         base_mask = 0;
      }

      if ( ! ((win_struct->flags & WLI_WIN_HILITE_MASK) ==  WLI_WIN_FLAGS_HILITE_NOOP) )
      {
         hilite_mask = context_struct->hilite_mask;
      }
      else
      {
         hilite_mask = 0;
      }

      XSetPlaneMask( win_struct->native_info.EXdisplay,
                     win_struct->native_info.EXgc, base_mask | hilite_mask );

   }
   return( WL_SUCCESS );
}  /* WLIclear_hilite_X */

/*--- WLIclear_hilite_X_HL-----------------------------------------------*/
 
static int WLIclear_hilite_X_HL(
   struct WLIwin *win_struct,
   struct WLIcontext *context_struct )
 
/*
NAME
   WLIclear_hilite_X_HL ( static )
 
KEYWORD
   WLI
 
DESCRIPTION
   This is the X implementation of WLclear_hilite
   with separate hilite windows.

SYNOPSIS
   static int WLIclear_hilite_X_HL(
      struct WLIwin *win_struct,
      struct WLIcontext *context_struct )
 
PARAMETERS
   win_struct ( IN) - The window structure
   context_struct ( IN) - The context structure
 
GLOBALS USED
   none
 
RETURN VALUES
   WL_SUCCESS
      Success
 
RELATED INFORMATION
 
HISTORY
   06/28/93 Shridar Subramanian
      Initial definition, design
*/
{
   int hl_color;
   XWindowAttributes win_attr;
   XGCValues old_gc_val;


   XSetForeground( win_struct->native_info.EXdisplay,
                   win_struct->hl_native_info.hl_gc, 0 );

   XGetGCValues( win_struct->native_info.EXdisplay,
                 win_struct->hl_native_info.hl_gc,
                 GCFillStyle , &old_gc_val );

   XSetFillStyle( win_struct->native_info.EXdisplay,
                  win_struct->hl_native_info.hl_gc, FillSolid );

   XFillRectangle( win_struct->native_info.EXdisplay, 
                   win_struct->hl_hwin_no,
                   win_struct->hl_native_info.hl_gc, 
                   0, 0, win_struct->bounds.width, win_struct->bounds.height );

   XSetFillStyle( win_struct->native_info.EXdisplay,
                  win_struct->hl_native_info.hl_gc, old_gc_val.fill_style );
                  

   if ( win_struct->flags & WLI_WIN_FLAGS_DYNAMICS_ON )
   {
      /* dynamics is on, just reset the hilite data (color) */
      if ( win_struct->flags & WLI_WIN_FLAGS_DYNAMICS_DRAW )
      {
         hl_color = 1;
      }
      else
      {
         hl_color = 0;
      }

      XSetForeground( win_struct->native_info.EXdisplay,
                      win_struct->hl_native_info.hl_gc, hl_color );
   }

   return( WL_SUCCESS );
}  /* WLIclear_hilite_X_HL */

/*--- WLIset_drawing_mode_X -------------------------------------------*/

static int WLIset_drawing_mode_X(
   struct WLIwin *win_struct,
   struct WLIcontext *context_struct,
   int base_mask,
   int hilite_mask )

/*
NAME
   WLIset_drawing_mode_X (static)
 
KEYWORD
   WLI

DESCRIPTION
   This is the X implementation of WLset_drawing_mode
   without separate hilite windows.

SYNOPSIS
   static int WLIset_drawing_mode_X(
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
   06/29/93 Shridar Subramanian
      Initial definition, design, Implementation
*/
{
  if ( ! (win_struct->flags & WLI_WIN_FLAGS_DYNAMICS_ON) )
  {
     XSetPlaneMask( win_struct->native_info.EXdisplay, 
                  win_struct->native_info.EXgc, base_mask | hilite_mask );
  }
  else
  {
     XSetPlaneMask( win_struct->native_info.EXdisplay, 
                  win_struct->native_info.EXgc, hilite_mask );
  } 
        
   return( WL_SUCCESS );
} /*  WLIset_drawing_mode_X */

/*--- WLIset_drawing_mode_X_HL -------------------------------------------*/

static int WLIset_drawing_mode_X_HL(
   struct WLIwin *win_struct,
   struct WLIcontext *context_struct,
   int base_mask,
   int hilite_mask )

/*
NAME
   WLIset_drawing_mode_X_HL (static)
 
KEYWORD
   WLI

DESCRIPTION
   This is the X implementation of WLset_drawing_mode
   with separate hilite windows.

SYNOPSIS
   static int WLIset_drawing_mode_X_HL(
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
   06/29/93 Shridar Subramanian
      Initial definition, design, Implementation
*/

{
   XSetPlaneMask( win_struct->native_info.EXdisplay, 
                  win_struct->hl_native_info.hl_gc, hilite_mask );
   XSetPlaneMask( win_struct->native_info.EXdisplay, 
                  win_struct->native_info.EXgc, base_mask );
        
   return( WL_SUCCESS );
} /*  WLIset_drawing_mode_X_HL */

/*--- WLIset_dynamics_drawing_mode_X -------------------------------------------*/

static int WLIset_dynamics_drawing_mode_X(
   struct WLIwin *win_struct,
   struct WLIcontext *context_struct,
   int mode )

/*
NAME
   WLIset_dynamics_drawing_mode_X (static)
 
KEYWORD
   WLI

DESCRIPTION
   This is the X implementation of WLset_dynamics_drawing_mode
   without separate hilite windows.

SYNOPSIS
   static int WLIset_dynamics_drawing_mode_X(
      struct WLIwin *win_struct,
      struct WLIcontext *context_struct,
      int mode )

PARAMETERS
   win_struct (IN) - the window structure
   context_struct (IN) - the context structure
   mode (IN) - Specifies the dynamics drawing mode. Values could be 
               WL_DYN_DRAW_MODE or WL_DYN_ERASE_MODE

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
   if ( mode == WL_DYN_ERASE_MODE )
   {
      XSetForeground( win_struct->native_info.EXdisplay, 
                      win_struct->native_info.EXgc, 0 );
   }
   else
   {
      XSetForeground( win_struct->native_info.EXdisplay, 
                      win_struct->native_info.EXgc,
                      context_struct->hilite_mask );
   }

   return( WL_SUCCESS );

} /*  WLIset_dynamics_drawing_mode_X */

/*--- WLIset_dynamics_drawing_mode_X_HL -------------------------------------------*/

static int WLIset_dynamics_drawing_mode_X_HL(
   struct WLIwin *win_struct,
   struct WLIcontext *context_struct,
   int mode )

/*
NAME
   WLIset_dynamics_drawing_mode_X_HL (static)
 
KEYWORD
   WLI

DESCRIPTION
   This is the X implementation of WLset_dynamics_drawing_mode
   with separate hilite windows.

SYNOPSIS
   static int WLIset_dynamics_drawing_mode_X_HL(
      struct WLIwin *win_struct,
      struct WLIcontext *context_struct,
      int mode )

PARAMETERS
   win_struct (IN) - the window structure
   context_struct (IN) - the context structure
   mode (IN) - Specifies the dynamics drawing mode. Values could be 
               WL_DYN_DRAW_MODE or WL_DYN_ERASE_MODE

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
   if ( mode == WL_DYN_ERASE_MODE )
   {
      XSetForeground( win_struct->native_info.EXdisplay, 
                      win_struct->hl_native_info.hl_gc, 0 );
   }
   else
   {
      XSetForeground( win_struct->native_info.EXdisplay, 
                      win_struct->hl_native_info.hl_gc, 1 );
   }

   return( WL_SUCCESS );
} /*  WLIset_dynamics_drawing_mode_X_HL */


/*---WLIactivate_symbology_X-----------------------------------------*/

static int WLIactivate_symbology_X(
   struct WLIwin *win_struct,
   struct WLIcontext *context_struct,
   struct WLIstyle_struct *style_struct,
   int fill_flag )

/*
NAME
	WLIactivate_symbology_X
 
KEYWORD
	WLI (static)
 
DESCRIPTION
	This is an X implementation of WLIactivate_symbology with
        separate hilite windows 

SYNOPSIS
        int WLIactivate_symbology_X(
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
   XGCValues values;
   unsigned long valuemask = 0;
   int    fg_color, hl_color;


   /* color */
   /* Change the foreground color only if not in dynamics */
   if ( !( win_struct->flags & WLI_WIN_FLAGS_DYNAMICS_ON ) )
   {
      (*win_struct->get_fg_and_hl)( win_struct, context_struct, 
                                   &fg_color, &hl_color );
      values.foreground = fg_color | hl_color;
      valuemask |= GCForeground;

   }
   else if ( context_struct->hilite_used )
   {
      /* dynamics is on and we have a hilite plane => use the dynamic */
      /* drawing mode to determine how to set the hilite color        */

      if ( win_struct->flags & WLI_WIN_FLAGS_DYNAMICS_DRAW )
      {
         values.foreground = 1 << context_struct->base_depth;
      }
      else
      {
         values.foreground = 0;
      }

      valuemask |= GCForeground;
       
   }

   /* style  and weight and pattern */

   if ( ( style_struct->flags & WLI_STYLE_SOLID ) && 
        ( win_struct->active_blend == 0xffff ) )
   {
      /* use 0 weight here, if possible, to get best speed for solid lines */

      values.line_width = (win_struct->active_weight == 0) ? 0 : win_struct->active_weight + 1;
      values.line_style = LineSolid;
      valuemask |= ( GCLineWidth | GCLineStyle );
   }
   else
   {
      if ( win_struct->active_blend == 0xaaaa )
      {
         /* Half hilite  */
         XSetDashes( win_struct->native_info.EXdisplay, win_struct->native_info.EXgc,
                     style_struct->hh_offset, style_struct->hh_dash_list,
                     style_struct->hh_nitems );
      }
      else
      {
         XSetDashes( win_struct->native_info.EXdisplay, win_struct->native_info.EXgc,
                     style_struct->offset, style_struct->dash_list,
                     style_struct->nitems );
      }
      values.line_width = win_struct->active_weight + 1;
      values.line_style = LineOnOffDash;
      valuemask |= ( GCLineWidth | GCLineStyle );
   }

   values.cap_style = CapButt;
   values.join_style = JoinBevel;
   valuemask |= ( GCCapStyle | GCJoinStyle );

   if ( (!fill_flag) || (win_struct->flags & WLI_WIN_FLAGS_B_PATTERN_SOLID) )
   {
      values.fill_style = FillSolid;
      valuemask |= GCFillStyle;
   }
   else
   {

      values.stipple = win_struct->blend_pattern;
      valuemask |= GCStipple ;

      if ( win_struct->flags &  WLI_WIN_FLAGS_B_PATTERN_OPAQUE )
      {
         values.fill_style = FillOpaqueStippled;
         valuemask |= GCFillStyle;
      }
      else
      {
         values.fill_style = FillStippled;
         valuemask |= GCFillStyle;
      }
   }
   XChangeGC( win_struct->native_info.EXdisplay, win_struct->native_info.EXgc, 
             valuemask, &values );

   return( WL_SUCCESS );

} /*  WLIactivate_symbology_X */

/*---WLIactivate_symbology_X_HL-----------------------------------------*/

static int WLIactivate_symbology_X_HL(
   struct WLIwin *win_struct,
   struct WLIcontext *context_struct,
   struct WLIstyle_struct *style_struct,
   int fill_flag )

/*
NAME
	WLIactivate_symbology_X_HL
 
KEYWORD
	WLI (static)
 
DESCRIPTION
	This is an X implementation of WLIactivate_symbology with
        separate hilite windows 

SYNOPSIS
        int WLIactivate_symbology_X_HL(
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
   unsigned long valuemask = 0, hl_valuemask = 0;
   XGCValues values, hl_values;
   int    foreground;
   int    hl_color, fg_color;

   /* color */
   /* Change the foreground color only if not in dynamics */
   if ( !( win_struct->flags & WLI_WIN_FLAGS_DYNAMICS_ON ) )
   {
      (*win_struct->get_fg_and_hl)( win_struct, context_struct, 
                                  &fg_color, &hl_color );
      values.foreground = fg_color;
      hl_values.foreground = hl_color;
      valuemask |= GCForeground;
      hl_valuemask |= GCForeground;
   }
   else 
   {
      /* dynamics is on and we have a hilite plane => use the dynamic */
      /* drawing mode to determine how to set the hilite color        */

      if ( win_struct->flags & WLI_WIN_FLAGS_DYNAMICS_DRAW )
      {
         hl_values.foreground = 1;
      }
      else
      {
         hl_values.foreground = 0;
      }
      hl_valuemask |= GCForeground;

   }
   if ( ( style_struct->flags & WLI_STYLE_SOLID ) && 
        ( win_struct->active_blend == 0xffff ) )
   {
      /* use 0 weight here, if possible, to get best speed for solid lines */
      hl_values.line_width = values.line_width = 
                    (win_struct->active_weight == 0) ? 0 : win_struct->active_weight + 1;
      hl_values.line_style = values.line_style = LineSolid;
      valuemask |= ( GCLineWidth | GCLineStyle );
      hl_valuemask |= ( GCLineWidth | GCLineStyle );
   }
   else
   {
      if ( win_struct->active_blend == 0xaaaa )
      {
      /* Half hilite  */
      XSetDashes( win_struct->native_info.EXdisplay, win_struct->hl_native_info.hl_gc,
                  style_struct->hh_offset, style_struct->hh_dash_list,
                  style_struct->hh_nitems );
      XSetDashes( win_struct->native_info.EXdisplay, win_struct->native_info.EXgc,
                  style_struct->hh_offset, style_struct->hh_dash_list,
                  style_struct->hh_nitems );
      }
      else
      {
      XSetDashes( win_struct->native_info.EXdisplay, win_struct->hl_native_info.hl_gc,
                  style_struct->offset, style_struct->dash_list,
                  style_struct->nitems );
      XSetDashes( win_struct->native_info.EXdisplay, win_struct->native_info.EXgc,
                  style_struct->offset, style_struct->dash_list,
                  style_struct->nitems );
      }
      hl_values.line_width = values.line_width = win_struct->active_weight + 1;
      hl_values.line_style = values.line_style = LineOnOffDash;
      valuemask |= ( GCLineWidth | GCLineStyle );
      hl_valuemask |= ( GCLineWidth | GCLineStyle );
   }
   hl_values.cap_style = values.cap_style = CapButt;
   hl_values.join_style = values.join_style = JoinBevel;
   valuemask |= ( GCCapStyle | GCJoinStyle );
   hl_valuemask |= ( GCCapStyle | GCJoinStyle );

   if ( (!fill_flag) || (win_struct->flags & WLI_WIN_FLAGS_B_PATTERN_SOLID) )
   {
      hl_values.fill_style = values.fill_style = FillSolid;
      valuemask |= GCFillStyle;
      hl_valuemask |= GCFillStyle;
   }
   else
   {
      hl_values.stipple = values.stipple = win_struct->blend_pattern;
      valuemask |=  GCStipple; 
      hl_valuemask |=  GCStipple;

      if ( win_struct->flags &  WLI_WIN_FLAGS_B_PATTERN_OPAQUE )
      {
            hl_values.fill_style = values.fill_style = FillOpaqueStippled;
      }
      else
      {
            hl_values.fill_style = values.fill_style = FillStippled;
      }
      valuemask |= GCFillStyle;
      hl_valuemask |= GCFillStyle;
   }
   XChangeGC( win_struct->native_info.EXdisplay, win_struct->native_info.EXgc, 
             valuemask, &values );
   XChangeGC( win_struct->native_info.EXdisplay, win_struct->hl_native_info.hl_gc, 
             hl_valuemask, &hl_values );

   return( WL_SUCCESS );

} /*  WLIactivate_symbology_X_HL */

/*--- WLIset_window_functions ------------------------------------------*/

int WLIset_window_functions(
   struct WLIwin *win_struct )

/*
NAME
   WLIset_window_functions

DESCRIPTION
   This function sets the function pointers for a window for
   X windows.

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
   struct WLIcontext context_struct;
   int   sts;

   sts = WLIcontext_retrieve_entry( win_struct->context_no, &context_struct );
   if ( sts != WL_SUCCESS )
   {
      WL_REPORT_ERROR( sts );
      return( sts );
   }
   if ( win_struct->flags & WLI_WIN_SEPARATE_HILITE )
   {
      win_struct->clear_window = WLIclear_window_X_HL;
      win_struct->clear_hilite = WLIclear_hilite_X_HL;
      win_struct->set_drawing_mode = WLIset_drawing_mode_X_HL;
      win_struct->set_dynamics_drawing_mode = WLIset_dynamics_drawing_mode_X_HL;
      win_struct->activate_symbology = WLIactivate_symbology_X_HL;
      if ( context_struct.base_cmap_type == WL_CMAP_TRUE_COLOR )
      {
         win_struct->get_fg_and_hl = WLIget_fg_and_hl_HL_TC;
      }
      else
      {
         win_struct->get_fg_and_hl = WLIget_fg_and_hl_HL_IX;
      }
   }
   else
   {
      win_struct->clear_window = WLIclear_window_X;
      win_struct->clear_hilite = WLIclear_hilite_X;
      win_struct->set_drawing_mode = WLIset_drawing_mode_X;
      win_struct->set_dynamics_drawing_mode = WLIset_dynamics_drawing_mode_X;
      win_struct->activate_symbology = WLIactivate_symbology_X;
      if ( context_struct.base_cmap_type == WL_CMAP_TRUE_COLOR )
      {
         win_struct->get_fg_and_hl = WLIget_fg_and_hl_TC;
      }
      else
      {
         win_struct->get_fg_and_hl = WLIget_fg_and_hl_IX;
      }
   }

   return( WL_SUCCESS );
} /* WLIset_window_functions */

/*--- WLIclear_double_buffer ------------------------------------------*/

int WLIclear_double_buffer(
   struct WLIwin *win_struct,
   Multibuffer double_buffer)
/*
NAME
   WLIclear_double_buffer

DESCRIPTION
   This function  clears a double buffer as XClearWindow does not work on
   a buffer.

SYNOPSIS
   int WLIclear_double_buffer(
   struct WLIwin *win_struct,
   Multibuffer *double_buffer)


PARAMETERS
   win_struct (IN) - pointer to the window structure

GLOBALS USED
   none

RETURN VALUES
   WL_SUCCESS - Success

HISTORY
   06/25/93 Ravi Parthasarathy
      Initial creation.
*/

{
   int sts, x,y;
   unsigned int width, height, border, depth;
   Window root;
   XGCValues values;
   int fgcolor;
   int left_shift_factor, right_shift_factor, red, green, blue;
   struct WLIcontext context_struct;

   sts = WLIcontext_retrieve_entry( win_struct->context_no, &context_struct );
   if ( sts != WL_SUCCESS )
   {
      WL_REPORT_ERROR( sts );
      return( sts );
   }

   if ( context_struct.base_cmap_type == WL_CMAP_INDEXED )
   {
      fgcolor = win_struct->background_color_index;
   }
   else
   {
      if ( context_struct.base_depth == 12 )
      {
         right_shift_factor = 12;
         left_shift_factor = 4;
      }
      else
      {
         right_shift_factor = 8;
         left_shift_factor = 8;
      }
      red = win_struct->background_red >> right_shift_factor;
      green = win_struct->background_green >> right_shift_factor;
      blue = win_struct->background_blue >> right_shift_factor;
      fgcolor = ( blue << ( 2 * left_shift_factor ) );
      fgcolor |= ( green << left_shift_factor );
      fgcolor |=  red;
 
   }
 
   XGetGCValues( win_struct->native_info.EXdisplay,
                 win_struct->native_info.EXgc,
                 GCForeground | GCPlaneMask, &values);
   XSetPlaneMask( win_struct->native_info.EXdisplay,
                  win_struct->native_info.EXgc,
                  AllPlanes );
   XGetGeometry( win_struct->native_info.EXdisplay,
                 win_struct->hwin_no,
                 &root, &x, &y, &width, &height, &border, &depth);
   XSetForeground( win_struct->native_info.EXdisplay,
                   win_struct->native_info.EXgc,
                   fgcolor );
   XFillRectangle( win_struct->native_info.EXdisplay,
                   double_buffer,
                   win_struct->native_info.EXgc,
                   0,0, width, height);


   XSetPlaneMask( win_struct->native_info.EXdisplay,
                  win_struct->native_info.EXgc,
                  values.plane_mask );
   XSetForeground( win_struct->native_info.EXdisplay,
                   win_struct->native_info.EXgc,
                   values.foreground );
 
   return( WL_SUCCESS );
} /* WLIclear_double_buffer */

#endif
