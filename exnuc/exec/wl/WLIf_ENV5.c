#if defined( ENV5 )

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "wl.h"
#include "wl_internal.h"

static WLuint32  WLIsolid_pattern[32] = {
                          0xffffffff, 0xffffffff, 0xffffffff, 0xffffffff,
                          0xffffffff, 0xffffffff, 0xffffffff, 0xffffffff,
                          0xffffffff, 0xffffffff, 0xffffffff, 0xffffffff,
                          0xffffffff, 0xffffffff, 0xffffffff, 0xffffffff,
                          0xffffffff, 0xffffffff, 0xffffffff, 0xffffffff,
                          0xffffffff, 0xffffffff, 0xffffffff, 0xffffffff,
                          0xffffffff, 0xffffffff, 0xffffffff, 0xffffffff,
                          0xffffffff, 0xffffffff, 0xffffffff, 0xffffffff };


/*--- WLIclear_window_ENV5 ----------------------------------------*/

static int WLIclear_window_ENV5(
   struct WLIwin *win_struct,
   struct WLIcontext *context_struct )

/*
NAME
   WLIclear_window_ENV5 (static)

KEYWORD
   WLI

DESCRIPTION
   This is the ENV5 implementation of WLclear_window
   without hilite ability.

SYNOPSIS
   static int WLIclear_window_ENV5(
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
   int old_fgdata, bgdata;
   int old_enabledata;
   int x_min, y_min, x_max, y_max;

   /* set the foreground color to the window background color */
   /* and draw a filled rectangle to clear the window         */

   Inq_bgdata( win_struct->hwin_no, IMAGE_DATA, &bgdata );
   Inq_fgdata( win_struct->hwin_no, IMAGE_DATA, &old_fgdata );
   Inq_enabledata( win_struct->hwin_no, IMAGE_DATA, &old_enabledata );
   fgdata( win_struct->hwin_no, IMAGE_DATA, bgdata );

   enabledata( win_struct->hwin_no, IMAGE_DATA,
               context_struct->base_mask | context_struct->hilite_mask );

   Inq_win_region( win_struct->hwin_no, &x_min, &y_min, &x_max, &y_max );
   rectf( win_struct->hwin_no, 0, 0, x_max - x_min, y_max - y_min );

   /* reset the old color, planes, etc */
   fgdata( win_struct->hwin_no, IMAGE_DATA, old_fgdata );
   enabledata( win_struct->hwin_no, IMAGE_DATA, old_enabledata );

   return( WL_SUCCESS );
} /* WLIclear_window_ENV5 */

/*--- WLIclear_window_ENV5_HL ----------------------------------------*/

static int WLIclear_window_ENV5_HL(
   struct WLIwin *win_struct,
   struct WLIcontext *context_struct )

/*
NAME
   WLIclear_window_ENV5_HL (static)

KEYWORD
   WLI

DESCRIPTION
   This is the ENV5 implementation of WLclear_window
   with hilite ability.

SYNOPSIS
   static int WLIclear_window_ENV5_HL(
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
   int old_fgdata, old_hl_fgdata, bgdata;
   int old_enabledata, old_hl_enabledata;
   int x_min, y_min, x_max, y_max;

   /* set the foreground color to the window background color */
   /* and draw a filled rectangle to clear the window         */
   Inq_bgdata( win_struct->hwin_no, IMAGE_DATA, &bgdata );
   Inq_fgdata( win_struct->hwin_no, IMAGE_DATA, &old_fgdata );
   Inq_enabledata( win_struct->hwin_no, IMAGE_DATA, &old_enabledata );
   fgdata( win_struct->hwin_no, IMAGE_DATA, bgdata );

   Inq_fgdata( win_struct->hwin_no, HIGHLIGHT_DATA, &old_hl_fgdata );
   Inq_enabledata( win_struct->hwin_no, HIGHLIGHT_DATA, &old_hl_enabledata );
   fgdata( win_struct->hwin_no, HIGHLIGHT_DATA, 0 );
   enabledata( win_struct->hwin_no, IMAGE_DATA, context_struct->base_mask );
   enabledata( win_struct->hwin_no, HIGHLIGHT_DATA, context_struct->hilite_mask );

   Inq_win_region( win_struct->hwin_no, &x_min, &y_min, &x_max, &y_max );
   rectf( win_struct->hwin_no, 0, 0, x_max - x_min, y_max - y_min );

   /* reset the old color, planes, etc */
   fgdata( win_struct->hwin_no, IMAGE_DATA, old_fgdata );
   enabledata( win_struct->hwin_no, IMAGE_DATA, old_enabledata );
   fgdata( win_struct->hwin_no, HIGHLIGHT_DATA, old_hl_fgdata );
   enabledata( win_struct->hwin_no, HIGHLIGHT_DATA, old_hl_enabledata );

   return( WL_SUCCESS );
} /* WLclear_window_ENV5_HL */


/*--- WLIclear_hilite_ENV5-----------------------------------------------*/
 
int WLIclear_hilite_ENV5(
   struct WLIwin *win_struct,
   struct WLIcontext *context_struct )

 
/*
NAME
   WLIclear_hilite_ENV5 ( static )
 
KEYWORD
   WLI
 
DESCRIPTION
   This is the ENV5 implementation of WLclear_hilite
   without hilite ability.

SYNOPSIS
   static int WLIclear_hilite_ENV5(
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
   int xmin, ymin, xmax, ymax;

   enableplane( win_struct->hwin_no, context_struct->hilite_mask );

   fgcolor( win_struct->hwin_no, 0 );
   Inq_win_region( win_struct->hwin_no, &xmin, &ymin, &xmax, &ymax );

   /* !!! what about blend area, texture, etc. !!! */
   blendarea( win_struct->hwin_no, WLIsolid_pattern );
   texture( win_struct->hwin_no, WLIsolid_pattern );
   rectf( win_struct->hwin_no, 0, 0, xmax - xmin, ymax - ymin );

   /* reset the planes appropriately */
   if ( win_struct->flags & WLI_WIN_FLAGS_DYNAMICS_ON )
   {
      hl_color = 0;
      /* dynamics is on, just reset the hilite data (color) */
      if ( win_struct->flags & WLI_WIN_FLAGS_DYNAMICS_DRAW )
      {
         hl_color = 1 << context_struct->base_depth;
      }

      fgcolor( win_struct->hwin_no, hl_color );
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

       enableplane( win_struct->hwin_no, base_mask | hilite_mask ); 

   }
   return( WL_SUCCESS );
}  /* WLIclear_hilite_ENV5 */

/*--- WLIclear_hilite_ENV5_HL-----------------------------------------------*/

int WLIclear_hilite_ENV5_HL(
   struct WLIwin *win_struct,
   struct WLIcontext *context_struct )

 
/*
NAME
   WLIclear_hilite_ENV5_HL ( static )
 
KEYWORD
   WLI
 
DESCRIPTION
   This is the ENV5 implementation of WLclear_hilite
   with hilite ability.

SYNOPSIS
   static int WLIclear_hilite_ENV5_HL(
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

   int xmin, ymin, xmax, ymax;

   if ( ! (win_struct->flags & WLI_WIN_FLAGS_DYNAMICS_ON) )
   {
      /* dynamics isn't on in this window => we must make */
      /* sure that only the hilite plane is enabled       */
      enabledata( win_struct->hwin_no, HIGHLIGHT_DATA, 1 );

      enabledata( win_struct->hwin_no, IMAGE_DATA, 0 );
   }

   fgdata( win_struct->hwin_no, HIGHLIGHT_DATA, 0 );

   Inq_win_region( win_struct->hwin_no, &xmin, &ymin, &xmax, &ymax );

   /* !!! what about blend area, texture, etc. !!! */
   rectf( win_struct->hwin_no, 0, 0, xmax - xmin, ymax - ymin );

   /* reset the planes appropriately */
   if ( win_struct->flags & WLI_WIN_FLAGS_DYNAMICS_ON )
   {
      hl_color = 0;

      /* dynamics is on, just reset the hilite data (color) */
      if ( win_struct->flags & WLI_WIN_FLAGS_DYNAMICS_DRAW )
      {
         hl_color = 1;
      }

      fgdata( win_struct->hwin_no, HIGHLIGHT_DATA, hl_color );
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
         /* enable hilite plane */
         hilite_mask = context_struct->hilite_mask;
      }
      else
      {
         hilite_mask = 0;
      }

      enabledata( win_struct->hwin_no, IMAGE_DATA, base_mask );
      enabledata( win_struct->hwin_no, HIGHLIGHT_DATA, hilite_mask );
   }
   return( WL_SUCCESS );
}  /* WLIclear_hilite_ENV5_HL */

/*--- WLIset_drawing_mode_ENV5 -------------------------------------------*/

/*ARGSUSED*/
static int WLIset_drawing_mode_ENV5(
   struct WLIwin *win_struct,
   struct WLIcontext *context_struct,
   int base_mask,
   int hilite_mask )

/*
NAME
   WLIset_drawing_mode_ENV5 (static)
 
KEYWORD
   WLI

DESCRIPTION
   This is the ENV5 implementation of WLset_drawing_mode
   without hilite ability.

SYNOPSIS
   static int WLIset_drawing_mode_ENV5(
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

   WL_BAD_WINDOW
      The logical window number is invalid

HISTORY
   06/29/93 Shridar Subramanian
      Initial definition, design, Implementation
*/
{
   if ( ! (win_struct->flags & WLI_WIN_FLAGS_DYNAMICS_ON) )
   {
      enableplane( win_struct->hwin_no, base_mask | hilite_mask );
   }
   else
   {
      enableplane( win_struct->hwin_no, hilite_mask );
   }
   return( WL_SUCCESS );
} /*  WLIset_drawing_mode_ENV5 */

/*--- WLIset_drawing_mode_ENV5_HL -------------------------------------------*/

/*ARGSUSED*/
static int WLIset_drawing_mode_ENV5_HL(
   struct WLIwin *win_struct,
   struct WLIcontext *context_struct,
   int base_mask,
   int hilite_mask )

/*
NAME
   WLIset_drawing_mode_ENV5_HL (static)
 
KEYWORD
   WLI

DESCRIPTION
   This is the ENV5 implementation of WLset_drawing_mode
   with hilite ability.

SYNOPSIS
   static int WLIset_drawing_mode_ENV5_HL(
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

   WL_BAD_WINDOW
      The logical window number is invalid

HISTORY
   06/29/93 Shridar Subramanian
      Initial definition, design, Implementation
*/
{
  
   enabledata( win_struct->hwin_no, IMAGE_DATA, base_mask );
   enabledata( win_struct->hwin_no, HIGHLIGHT_DATA, hilite_mask );
   return( WL_SUCCESS );
} /*  WLIset_drawing_mode_ENV5_HL */

/*--- WLIset_dynamics_drawing_mode_ENV5 -------------------------------------------*/

static int WLIset_dynamics_drawing_mode_ENV5(
   struct WLIwin *win_struct,
   struct WLIcontext *context_struct,
   int mode )

/*
NAME
   WLIset_dynamics_drawing_mode_ENV5 (static)
 
KEYWORD
   WLI

DESCRIPTION
   This is the ENV5 implementation of WLset_dynamics_drawing_mode
   without hilite ability.

SYNOPSIS
   static int WLIset_dynamics_drawing_mode_ENV5(
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
      fgdata( win_struct->hwin_no, IMAGE_DATA, 0 );
   }
   else
   {
      fgdata( win_struct->hwin_no, IMAGE_DATA,
              context_struct->hilite_mask );
   }

   return( WL_SUCCESS );

} /*  WLIset_dynamics_drawing_mode_ENV5 */

/*--- WLIset_dynamics_drawing_mode_ENV5_HL -------------------------------------------*/

/*ARGSUSED*/
static int WLIset_dynamics_drawing_mode_ENV5_HL(
   struct WLIwin *win_struct,
   struct WLIcontext *context_struct,
   int mode )

/*
NAME
   WLIset_dynamics_drawing_mode_ENV5_HL (static)
 
KEYWORD
   WLI

DESCRIPTION
   This is the ENV5 implementation of WLset_dynamics_drawing_mode
   with hilite ability.

SYNOPSIS
   static int WLIset_dynamics_drawing_mode_ENV5_HL(
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
      fgdata( win_struct->hwin_no, HIGHLIGHT_DATA, 0 );
   }
   else
   {
      fgdata( win_struct->hwin_no, HIGHLIGHT_DATA, 1 );
   }

   return( WL_SUCCESS );
} /*  WLIset_dynamics_drawing_mode_ENV5_HL */



/*---WLIactivate_symbology_ENV5_HL-----------------------------------------*/

static int WLIactivate_symbology_ENV5_HL(
   struct WLIwin *win_struct,
   struct WLIcontext *context_struct,
   struct WLIstyle_struct *style_struct,
   int fill_flag )

/*
NAME
	WLIactivate_symbology_ENV5_HL
 
KEYWORD
	WLI (static)
 
DESCRIPTION
	This is an ENV5 implementation of WLIactivate_symbology with
        separate hilite windows 

SYNOPSIS
        int WLIactivate_symbology_ENV5_HL(
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
   int    fg_color, hl_color;

   /* color */
   /* Change the foreground color only if not in dynamics */
   if ( !( win_struct->flags & WLI_WIN_FLAGS_DYNAMICS_ON ) )
   {
      (*win_struct->get_fg_and_hl)( win_struct, context_struct, 
                                  &fg_color, &hl_color );

      fgdata( win_struct->hwin_no, IMAGE_DATA, fg_color );
      fgdata( win_struct->hwin_no, HIGHLIGHT_DATA, hl_color );
   }
   else if ( context_struct->hilite_used )
   {
      /* dynamics is on and we have a hilite plane => use the dynamic */
      /* drawing mode to determine how to set the hilite color        */

      if ( win_struct->flags & WLI_WIN_FLAGS_DYNAMICS_DRAW )
      {
         hl_color = 1;
      }
      else
      {
         hl_color = 0;
      }

      fgdata( win_struct->hwin_no, HIGHLIGHT_DATA, hl_color );
   }
   blendline( win_struct->hwin_no, win_struct->active_blend );
   linestyle( win_struct->hwin_no, style_struct->pattern );

   weight( win_struct->hwin_no, win_struct->active_weight );

   if ( (!fill_flag) || (win_struct->flags & WLI_WIN_FLAGS_B_PATTERN_SOLID) )
   {
      if ( win_struct->flags &  WLI_WIN_FLAGS_B_PATTERN_OPAQUE )
      {
         blendarea( win_struct->hwin_no, WLIsolid_pattern );
      }
      else
      {
         texture( win_struct->hwin_no, WLIsolid_pattern );
      }
   }
   else
   {
      if ( win_struct->flags &  WLI_WIN_FLAGS_B_PATTERN_OPAQUE )
      {
         blendarea( win_struct->hwin_no, win_struct->blend_pattern );
      }
      else
      {
         texture( win_struct->hwin_no, win_struct->blend_pattern );
      }
   }

   return( WL_SUCCESS );

} /* WLIactivate_symbology_ENV5_HL  */

/*---WLIactivate_symbology_ENV5-----------------------------------------*/

static int WLIactivate_symbology_ENV5(
   struct WLIwin *win_struct,
   struct WLIcontext *context_struct,
   struct WLIstyle_struct *style_struct,
   int fill_flag )

/*
NAME
	WLIactivate_symbology_ENV5
 
KEYWORD
	WLI (static)
 
DESCRIPTION
	This is an ENV5 implementation of WLIactivate_symbology without
        separate hilite windows 

SYNOPSIS
        int WLIactivate_symbology_ENV5(
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
   int    fg_color, hl_color;

   /* color */
   /* Change the foreground color only if not in dynamics */
   if ( !( win_struct->flags & WLI_WIN_FLAGS_DYNAMICS_ON ) )
   {
      (*win_struct->get_fg_and_hl)( win_struct, context_struct, 
                                  &fg_color, &hl_color );
      fgcolor( win_struct->hwin_no, fg_color | hl_color );
   }
   else if ( context_struct->hilite_used )
   {
      /* dynamics is on and we have a hilite plane => use the dynamic */
      /* drawing mode to determine how to set the hilite color        */

      if ( win_struct->flags & WLI_WIN_FLAGS_DYNAMICS_DRAW )
      {
         hl_color = 1 << context_struct->base_depth;
      }
      else
      {
         hl_color = 0;
      }

      fgcolor( win_struct->hwin_no, hl_color );
   }

   blendline( win_struct->hwin_no, win_struct->active_blend );
   linestyle( win_struct->hwin_no, style_struct->pattern );

   weight( win_struct->hwin_no, win_struct->active_weight );

   if ( (!fill_flag) || (win_struct->flags & WLI_WIN_FLAGS_B_PATTERN_SOLID) )
   {
      if ( win_struct->flags &  WLI_WIN_FLAGS_B_PATTERN_OPAQUE )
      {
         blendarea( win_struct->hwin_no, WLIsolid_pattern );
      }
      else
      {
         texture( win_struct->hwin_no, WLIsolid_pattern );
      }
   }
   else
   {
      if ( win_struct->flags &  WLI_WIN_FLAGS_B_PATTERN_OPAQUE )
      {
         blendarea( win_struct->hwin_no, win_struct->blend_pattern );
      }
      else
      {
         texture( win_struct->hwin_no, win_struct->blend_pattern );
      }
   }
   return ( WL_SUCCESS );
} /* WLIactivate_symbology_ENV5  */

/*--- WLIset_window_functions ------------------------------------------*/

int WLIset_window_functions(
   struct WLIwin *win_struct )

/*
NAME
   WLIset_window_functions

DESCRIPTION
   This function sets the function pointers for a window for
   ENV5.

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
   int sts;

   sts = WLIcontext_retrieve_entry( win_struct->context_no, &context_struct );
   if ( sts != WL_SUCCESS )
   {
      WL_REPORT_ERROR( sts );
      return( sts );
   }
 

   if ( win_struct->native_info.env5_vsi_flags & VSI_HL )
   {
      win_struct->clear_window = WLIclear_window_ENV5_HL;
      win_struct->clear_hilite = WLIclear_hilite_ENV5_HL;
      win_struct->set_drawing_mode = WLIset_drawing_mode_ENV5_HL;
      win_struct->set_dynamics_drawing_mode = WLIset_dynamics_drawing_mode_ENV5_HL;
      win_struct->activate_symbology = WLIactivate_symbology_ENV5_HL;
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
      win_struct->clear_window = WLIclear_window_ENV5;
      win_struct->clear_hilite = WLIclear_hilite_ENV5;
      win_struct->set_drawing_mode = WLIset_drawing_mode_ENV5;
      win_struct->set_dynamics_drawing_mode = WLIset_dynamics_drawing_mode_ENV5;
      win_struct->activate_symbology = WLIactivate_symbology_ENV5;
      win_struct->get_fg_and_hl = WLIget_fg_and_hl_IX;
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

#endif



