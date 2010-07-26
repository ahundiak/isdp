#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "wl.h"
#include "wl_internal.h"

#if defined( OPENGL )

#if defined( X11 )

static WLuint32 last_lwin_no = WL_UNDEFINED_WINDOW;
extern int WLhilite_enabled;
extern int WLIglx_last_win_type;

/* static function pointer */
static int (*WLIglx_choose_function)( struct WLcontext_info *context,
                                      XVisualInfo *avail_visuals,
                                      int num_avail,
                                      int *chosen_index ) = NULL;

/*--- WLIglx_reset_last_lwin_no ----------------------------------------------*/

int WLIglx_reset_last_lwin_no(
   void )
   
/*
NAME
   WLIglx_reset_last_lwin_no

DESCRIPTION
   This function resets the last lwin_no used to limit calls to
   glXMakeCurrent() to WL_UNDEFINED_WINDOW.  It is intended to be
   called when a window is deleted.

SYNOPSIS
   int WLIglx_reset_last_lwin_no(
      void )

PARAMETERS
   none

GLOBALS USED
   last_lwin_no (static)

RETURN VALUES
   WL_SUCCESS
      Success

HISTORY
   10/19/93 S.P. Rogers
      Initial definition and implementation
*/

{
   last_lwin_no = WL_UNDEFINED_WINDOW;
   return( WL_SUCCESS );
} /* WLIglx_reset_last_lwin_no */

/*--- WLglx_get_choose_visual_function --------------------------------------*/

int WLglx_get_choose_visual_function(
   int (**glx_choose_function)(
      struct WLcontext_info *context,
      XVisualInfo *avail_visuals,
      int num_avail,
      int *chosen_index ) )
/*
NAME
   WLglx_get_choose_visual_function

KEYWORD
   WL

DESCRIPTION
   This function gets the function that will be called to choose a visual
   for a WL context that will support OpenGL.

SYNOPSIS
   int WLglx_get_choose_visual_function(
      int (**glx_choose_function)( struct WLcontext_info *context,
                                   XVisualInfo *avail_visuals,
                              int num_avail,
                                   int *chosen_index ) )

PARAMETERS
   glx_choose_function (IN) - The function pointer to get

GLOBALS USED
   none

RETURN VALUES
   WL_SUCCESS
      Success

   WL_BAD_PARAMETER
      'glx_choose_function' is NULL

HISTORY
   01/11/93    S.P. Rogers
      Initial Definition
*/

{
   if ( ! glx_choose_function )
   {
      WL_REPORT_ERROR( WL_BAD_PARAMETER );
      return( WL_BAD_PARAMETER );
   }
   *glx_choose_function = WLIglx_choose_function;

   return( WL_SUCCESS );

}  /* WLglx_get_choose_visual_function */

/*--- WLglx_set_choose_visual_function --------------------------------------*/

int WLglx_set_choose_visual_function(
   int (*glx_choose_function)( struct WLcontext_info *context,
                               XVisualInfo *avail_visuals,
                               int num_avail,
                               int *chosen_index ) )
/*
NAME
   WLglx_set_choose_visual_function

KEYWORD
   WL

DESCRIPTION
   This function sets the function that will be called to choose a visual
   for a WL context that will support OpenGL.  This function will be called
   whenever a context is being created by WL.  This lets applications that
   are using WL choose the visual that they want their contexts created with
   based on the OpenGL attributes that they want.

SYNOPSIS
   int WLglx_set_choose_visual_function(
      int (*glx_choose_function)(
         struct WLcontext_info *context,
         XVisualInfo *avail_visuals,
         int num_avail,
        int *chosen_index ) )

PARAMETERS
   glx_choose_function (IN) - A pointer to the application's visual
                              choosing function;  Setting this function
                              to NULL indicates that contexts should not
                              be initialized for OpenGL rendering.

NOTES
   The synposis of the visual choosing function is:

   int glx_choose_function(
      struct WLcontext_info *context,
      XVisualInfo *avail_visuals,
      int num_avail,
      int *chosen_index )

   context (IN) - the context that is being created
   avail_visuals (IN) - array of available visuals that match the context
   num_avail (IN) - the number of available visuals
   chosen_index (OUT) - an index into the available visuals array that
                        indicates the visual to use.  If OpenGL is not to
                        be used for the context, set this parameter to -1.

   This function should return WL_SUCCESS to indicate successful
   completion or WL_ERROR to indicate failure.
                        
GLOBALS USED
   none

RETURN VALUES
   WL_SUCCESS
      Success

HISTORY
   01/11/93    S.P. Rogers
      Initial Definition
*/
{
   WLIglx_choose_function = glx_choose_function;

   return( WL_SUCCESS );

}  /* WLglx_set_choose_visual_function */


/*--- WLglx_make_window_current -------------------------------------*/

int WLglx_make_window_current(
   WLuint32 lwin_no,
   int win_type )

/*
NAME
   WLglx_make_window_current

DESCRIPTION
   This function makes the given window the current OpenGL rendering
   window.  It must be called before any OpenGL operations can be
   performed on the window.

SYNOPSIS
   int WLglx_make_window_current(
      WLuint32 lwin_no,
           int win_type )

PARAMETERS
   lwin_no (IN) - the window to make current
   win_type (IN) - the type of window to make current,
                   either WL_GLX_BASE_WIN or WL_GLX_HILITE_WIN

GLOBALS USED
   none

RETURN VALUES
   WL_SUCCESS
      Success

   WL_BAD_WINDOW_NUMBER
      The logical window number is invalid

   WL_BAD_PARAMETER
      The logical window was not configured to support OpenGL.

   WL_SYSTEM_ERROR
      An OpenGL call failed

HISTORY
   01/11/93    S.P. Rogers
      Creation Date
*/
{
   int status;
   struct WLIwin win_struct;
 
   if ( (lwin_no != last_lwin_no) ||
        (win_type != WLIglx_last_win_type) )
   {
      status = WLIwin_retrieve_entry( lwin_no, &win_struct );
      if ( status != WL_SUCCESS )
      {
         WL_REPORT_ERROR( status );
         return( status );
      }

      if ( ! (win_struct.flags & WLI_WIN_FLAGS_USING_OPENGL) )
      {
         WL_REPORT_ERROR( WL_BAD_PARAMETER );
         return( WL_BAD_PARAMETER );
      }

      if ( win_type == WL_GLX_BASE_WIN )
      {
         glXMakeCurrent( win_struct.native_info.EXdisplay, win_struct.hwin_no,
                         win_struct.native_info.glx_context );
      }
      else if ( (win_struct.flags & WLI_WIN_SEPARATE_HILITE) &&
                (win_type == WL_GLX_HILITE_WIN) )
      {
         glXMakeCurrent( win_struct.native_info.EXdisplay, win_struct.hl_hwin_no,
                         win_struct.native_info.hl_glx_context );
      }

      last_lwin_no = lwin_no;
      WLIglx_last_win_type = win_type;
   }
   return( WL_SUCCESS );

}  /* WLglx_make_window_current */

/*--- WLglx_get_window_contexts -------------------------------------*/

int WLglx_get_window_contexts( 
   WLuint32 lwin_no,
   GLXContext *glx_context,
   GLXContext *hl_glx_context )

/*
NAME
   WLglx_get_window_contexts

KEYWORD
   WL

DESCRIPTION
   This function gets the OpenGL rendering context(s) for a 
        logical window.

SYNOPSIS
   int WLglx_get_contexts( 
      WLuint32 lwin_no,
      GLXContext **glx_context,
      GLXcontext **hl_glx_context )

PARAMETERS
   lwin_no (IN) - the window whose context is to be retrieved
   glx_context (OUT) - the OpenGL rendering context; NULL, if an OpenGL
                       rendering context doesn't exist for the window
   hl_glx_context (OUT) - the OpenGL rendering context for the hilite
                          window; NULL, if a separate hilite window
                          doesn't exist

RETURN VALUES
   WL_SUCCESS
      Success

   WL_BAD_PARAMETER
      'glx_context' or 'hl_glx_context' is NULL.

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
   
   if ( (! glx_context) || (! hl_glx_context) )
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

   if ( win_struct.flags & WLI_WIN_FLAGS_USING_OPENGL )
   {
      *glx_context = win_struct.native_info.glx_context;
      *hl_glx_context = win_struct.native_info.hl_glx_context;
   }
   else
   {
      *glx_context = *hl_glx_context = NULL;
   }

   return( WL_SUCCESS );

}  /* WLglx_get_window_contexts */
#endif

/*--- WLIclear_window_OPENGL_IX ----------------------------------------*/

static int WLIclear_window_OPENGL_IX(
   struct WLIwin *win_struct,
   struct WLIcontext *context_struct )

/*
NAME
   WLIclear_window_OPENGL_IX (static)

KEYWORD
   WLI

DESCRIPTION
   This is the OPENGL implementation of WLclear_window
   for indexed windows without separate hilite windows.

SYNOPSIS
   static int WLIclear_window_OPENGL_IX(
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
   06/25/93 S.P. Rogers
      Extracted from WLclear_window
*/

{
   GLint old_mask;

#if defined( X11 )
   WLglx_make_window_current( win_struct->lwin_no, WL_GLX_BASE_WIN );
#endif

   glGetIntegerv( GL_INDEX_WRITEMASK, &old_mask );
   glIndexMask( 0xFFFFFFFF );

   glClear( GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT );

   glIndexMask( (GLuint) old_mask );

   return( WL_SUCCESS );
} /* WLIclear_window_OPENGL_IX */

/*--- WLIclear_window_OPENGL_IX ----------------------------------------*/

static int WLIclear_window_OPENGL_TC(
   struct WLIwin *win_struct,
   struct WLIcontext *context_struct )

/*
NAME
   WLIclear_window_OPENGL_TC (static)

KEYWORD
   WLI

DESCRIPTION
   This is the OPENGL implementation of WLclear_window
   for true color windows without separate hilite windows.

SYNOPSIS
   static int WLIclear_window_OPENGL_TC(
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
   06/25/93 S.P. Rogers
      Extracted from WLclear_window
*/

{
   GLboolean old_masks[4];

#if defined( X11 )
   WLglx_make_window_current( win_struct->lwin_no, WL_GLX_BASE_WIN );
#endif

   glGetBooleanv( GL_COLOR_WRITEMASK, old_masks );
   glColorMask( GL_TRUE, GL_TRUE, GL_TRUE, GL_TRUE );
   glClear( GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT );
   glColorMask( old_masks[0], old_masks[1], old_masks[2], old_masks[3] );

   return( WL_SUCCESS );
} /* WLIclear_window_OPENGL_TC */

/*--- WLIclear_window_OPENGL_IX_HL ----------------------------------------*/

static int WLIclear_window_OPENGL_IX_HL(
   struct WLIwin *win_struct,
   struct WLIcontext *context_struct )

/*
NAME
   WLIclear_window_OPENGL_IX_HL (static)

KEYWORD
   WLI

DESCRIPTION
   This is the OPENGL implementation of WLclear_window
   for indexed windows with separate hilite windows.

SYNOPSIS
   static int WLIclear_window_OPENGL_IX_HL(
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
   06/25/93 S.P. Rogers
      Extracted from WLclear_window
*/

{
   GLint old_mask;

   /* clear hilite first so we leave the base window active when leaving */
#if defined( X11 )
   WLglx_make_window_current( win_struct->lwin_no, WL_GLX_HILITE_WIN );
#endif

   glGetIntegerv( GL_INDEX_WRITEMASK, &old_mask );
   glIndexMask( 0xFFFFFFFF );
   glClear( GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT );
   glIndexMask( (GLuint) old_mask );

#if defined( X11 )
   WLglx_make_window_current( win_struct->lwin_no, WL_GLX_BASE_WIN );
#endif

   glGetIntegerv( GL_INDEX_WRITEMASK, &old_mask );
   glIndexMask( 0xFFFFFFFF );

   glClear( GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT );

   glIndexMask( old_mask );

   return( WL_SUCCESS );

} /* WLIclear_window_OPENGL_IX_HL */

/*--- WLIclear_window_OPENGL_TC_HL ----------------------------------------*/

static int WLIclear_window_OPENGL_TC_HL(
   struct WLIwin *win_struct,
   struct WLIcontext *context_struct )

/*
NAME
   WLIclear_window_OPENGL_TC_HL (static)

KEYWORD
   WLI

DESCRIPTION
   This is the OPENGL implementation of WLclear_window
   for true color windows with separate hilite windows.

SYNOPSIS
   static int WLIclear_window_OPENGL_TC_HL(
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
   06/25/93 S.P. Rogers
      Extracted from WLclear_window
*/

{
   GLboolean old_masks[4];
   GLint old_mask;

   /* clear hilite first so we leave the base window active when leaving */
#if defined( X11 )
   WLglx_make_window_current( win_struct->lwin_no, WL_GLX_HILITE_WIN );
#endif

   glGetIntegerv( GL_INDEX_WRITEMASK, &old_mask );
   glIndexMask( 0xFFFFFFFF );
   glClear( GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT );
   glIndexMask( (GLuint) old_mask );

#if defined( X11 )
   WLglx_make_window_current( win_struct->lwin_no, WL_GLX_BASE_WIN );
#endif

   glGetBooleanv( GL_COLOR_WRITEMASK, old_masks );
   glColorMask( GL_TRUE, GL_TRUE, GL_TRUE, GL_TRUE );
   glClear( GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT );
   glColorMask( old_masks[0], old_masks[1], old_masks[2], old_masks[3] );

   return( WL_SUCCESS );

} /* WLIclear_window_OPENGL_TC_HL */

/*--- WLIclear_hilite_OPENGL-----------------------------------------------*/
 
static int WLIclear_hilite_OPENGL(
   struct WLIwin *win_struct,
   struct WLIcontext *context_struct )
 
/*
NAME
   WLIclear_hilite_OPENGL ( static )
 
KEYWORD
   WLI
 
DESCRIPTION
   This is the OPENGL implemenation of WLclear_hilite without
   separate hilite windows.

SYNOPSIS
   static int WLIclear_hilite_OPENGL(
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
   can't have TRUE COLOR in X (the only OPENGL implementation)
   without having separate hilite.

HISTORY
   06/28/93 S.P. Rogers
      Initial definition and design
*/

{
   unsigned long base_mask, hilite_mask;

#if defined( X11 )
   WLglx_make_window_current( win_struct->lwin_no, WL_GLX_BASE_WIN );
#endif

   if ( ! (win_struct->flags & WLI_WIN_FLAGS_DYNAMICS_ON) )
   {
      /* dynamics isn't on in this window => we must make */
      /* sure that only the hilite plane is enabled       */
      glIndexMask( context_struct->hilite_mask );
   }

   glClear( GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT );

   /* reset the planes appropriately */
   if ( !( win_struct->flags & WLI_WIN_FLAGS_DYNAMICS_ON) )
   {
      /* we are not in dynamics so we may be drawing into */ 
      /* base and hilite planes => reset appropriately    */

      if ( ! ((win_struct->flags & WLI_WIN_BASE_MASK) == WLI_WIN_FLAGS_BASE_NOOP) )
      {
         /* enable base planes */
         base_mask = (1 << context_struct->base_depth) - 1;
      }
      else
      {
         base_mask = 0;
      }

      if ( ! ((win_struct->flags & WLI_WIN_HILITE_MASK) ==  WLI_WIN_FLAGS_HILITE_NOOP) )
      {
         hilite_mask = 1 << context_struct->base_depth;
      }
      else
      {
         hilite_mask = 0;
      }

      glIndexMask( base_mask | hilite_mask );
   }

   return( WL_SUCCESS );

}  /* WLIclear_hilite_OPENGL */

/*--- WLIclear_hilite_OPENGL_HL-----------------------------------------------*/
 
static int WLIclear_hilite_OPENGL_HL(
   struct WLIwin *win_struct,
   struct WLIcontext *context_struct )
 
/*
NAME
   WLIclear_hilite_OPENGL_HL ( static )
 
KEYWORD
   WLI
 
DESCRIPTION
   This is the OPENGL implemenation of WLclear_hilite with
   separate hilite windows.

SYNOPSIS
   static int WLIclear_hilite_OPENGL_HL(
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
   06/28/93 S.P. Rogers
      Initial definition and design
*/

{
   int status;
   GLint old_mask;

#if defined( X11 )
   WLglx_make_window_current( win_struct->lwin_no, WL_GLX_HILITE_WIN );
#endif

   if( WLhilite_enabled || WLIglx_last_win_type != WL_GLX_HILITE_WIN )
      {
      glGetIntegerv( GL_INDEX_WRITEMASK, &old_mask );
      glIndexMask( 0xFFFFFFFF );

      glClear( GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT );

      glIndexMask( old_mask );
      }

   return( WL_SUCCESS );
}  /* WLIclear_hilite_OPENGL_HL */

/*--- WLIset_drawing_mode_OPENGL -------------------------------------------*/

static int WLIset_drawing_mode_OPENGL(
   struct WLIwin *win_struct,
   struct WLIcontext *context_struct,
   int base_mask,
   int hilite_mask )

/*
NAME
   WLIset_drawing_mode_OPENGL (static)
 
KEYWORD
   WLI

DESCRIPTION
   This is the OPENGL implemenation of WLset_drawing_mode without
   separate hilite windows.

SYNOPSIS
   static int WLIset_drawing_mode_OPENGL(
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
   06/28/93 S.P. Rogers
      Initial definition and design
*/

{
#if defined( X11 )
   WLglx_make_window_current( win_struct->lwin_no, WL_GLX_BASE_WIN );
#endif

   glIndexMask( base_mask | hilite_mask );

   return( WL_SUCCESS );
} /*  WLIset_drawing_mode_OPENGL */

/*--- WLIset_drawing_mode_OPENGL_HL -------------------------------------------*/

static int WLIset_drawing_mode_OPENGL_HL(
   struct WLIwin *win_struct,
   struct WLIcontext *context_struct,
   int base_mask,
   int hilite_mask )

/*
NAME
   WLIset_drawing_mode_OPENGL_HL (static)
 
KEYWORD
   WLI

DESCRIPTION
   This is the OPENGL implemenation of WLset_drawing_mode with
   separate hilite windows.

SYNOPSIS
   static int WLIset_drawing_mode_OPENGL_HL(
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
   06/28/93 S.P. Rogers
      Initial definition and design
*/

{
#if defined( X11 )
   WLglx_make_window_current( win_struct->lwin_no, WL_GLX_BASE_WIN );
#endif

   if ( context_struct->base_cmap_type == WL_CMAP_INDEXED )
   {
      glIndexMask( base_mask );
   }
   else
   {
      if ( base_mask )
      {
         glColorMask( GL_TRUE, GL_TRUE, GL_TRUE, GL_TRUE );
      }
      else
      {
         glColorMask( GL_FALSE, GL_FALSE, GL_FALSE, GL_FALSE );
      }
   }

#if defined( X11 )
   WLglx_make_window_current( win_struct->lwin_no, WL_GLX_HILITE_WIN );
#endif

   if( WLhilite_enabled || WLIglx_last_win_type != WL_GLX_HILITE_WIN )
      glIndexMask( hilite_mask );

   return( WL_SUCCESS );
} /*  WLIset_drawing_mode_OPENGL_HL */

/*--- WLIset_dynamics_drawing_mode_OPENGL -------------------------------------------*/

static int WLIset_dynamics_drawing_mode_OPENGL(
   struct WLIwin *win_struct,
   struct WLIcontext *context_struct,
   int mode )

/*
NAME
   WLIset_dynamics_drawing_mode_OPENGL (static)
 
KEYWORD
   WLI

DESCRIPTION
   This is the OPENGL implemenation of WLset_dynamics_drawing_mode
   without separate hilite windows.

SYNOPSIS
   static int WLIset_dynamics_drawing_mode_OPENGL(
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
   06/28/93 S.P. Rogers
      Initial definition and design
*/

{
#if defined( X11 )
   WLglx_make_window_current( win_struct->lwin_no, WL_GLX_BASE_WIN );
#endif

   if ( mode == WL_DYN_ERASE_MODE )
   {
      glIndexi( 0 );
   }
   else
   {
      glIndexi( context_struct->hilite_mask );
   }

   return( WL_SUCCESS );
} /*  WLIset_dynamics_drawing_mode_OPENGL */

/*--- WLIset_dynamics_drawing_mode_OPENGL_HL -------------------------------------------*/

static int WLIset_dynamics_drawing_mode_OPENGL_HL(
   struct WLIwin *win_struct,
   struct WLIcontext *context_struct,
   int mode )

/*
NAME
   WLIset_dynamics_drawing_mode_OPENGL_HL (static)
 
KEYWORD
   WLI

DESCRIPTION
   This is the OPENGL implemenation of WLset_dynamics_drawing_mode
   with separate hilite windows.

SYNOPSIS
   static int WLIset_dynamics_drawing_mode_OPENGL_HL(
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
   06/28/93 S.P. Rogers
      Initial definition and design
*/

{
#if defined( X11 )
   WLglx_make_window_current( win_struct->lwin_no, WL_GLX_HILITE_WIN );
#endif

   if ( mode == WL_DYN_ERASE_MODE )
   {
      glIndexi( 0 );
   }
   else
   {
      glIndexi( context_struct->hilite_mask );
   }

   return( WL_SUCCESS );
} /*  WLIset_dynamics_drawing_mode_OPENGL_HL */



/*---WLIget_fg_and_hl_OPENGL_IX-----------------------------------------*/

static int WLIget_fg_and_hl_OPENGL_IX(
   struct WLIwin *win_struct,
   struct WLIcontext *context_struct)

/*
NAME
	WLIget_fg_and_hl_OPENGL_IX
 
KEYWORD
	WLI (static)
 
DESCRIPTION
	This is an OPENGL implementation of get_fg_and_hl without
        separate hilite windows 

SYNOPSIS
        int WLIget_fg_and_hl_OPENGL_IX(
           struct WLIwin *win_struct,
           struct WLIcontext *context_struct )

PARAMETERS
	win_struct (IN) - The window structure
	context_struct (IN) - The context structure
 
RETURN VALUES
	WL_SUCCESS
		Success

HISTORY
	07/02/93 Shridar Subramanian
		Initial definition, implementation
*/
{
   int    sts;
   int    fg_color, hl_color;

   if ( ( win_struct->flags & WLI_WIN_BASE_MASK ) == WLI_WIN_FLAGS_BASE_DRAW )
   {
      fg_color = win_struct->color_index;
   }
   else
   {
      fg_color = win_struct->background_color_index;
   }

   if ( ( win_struct->flags & WLI_WIN_HILITE_MASK ) == WLI_WIN_FLAGS_HILITE_DRAW )
   {
      hl_color = 1 << context_struct->base_depth;
   }
   else
   {
      hl_color = 0;
   }
   
   if ( win_struct->flags & WLI_WIN_FLAGS_USING_OPENGL )
   {
      sts = WLglx_make_window_current( win_struct->lwin_no, WL_GLX_BASE_WIN );
      if ( sts != WL_SUCCESS )
      {
         WL_REPORT_ERROR( sts );
         return( sts );
      }

      glIndexi( (GLint) (fg_color | hl_color) );
   }
   return( WL_SUCCESS );

}/* WLIget_fg_and_hl_OPENGL_IX */

/*---WLIget_fg_and_hl_OPENGL_IX_HL-----------------------------------------*/

static int WLIget_fg_and_hl_OPENGL_IX_HL(
   struct WLIwin *win_struct,
   struct WLIcontext *context_struct)

/*
NAME
	WLIget_fg_and_hl_OPENGL_IX_HL
 
KEYWORD
	WLI (static)
 
DESCRIPTION
	This is an OPENGL implementation of get_fg_and_hl with
        separate hilite windows 

SYNOPSIS
        int WLIget_fg_and_hl_OPENGL_IX_HL(
           struct WLIwin *win_struct,
           struct WLIcontext *context_struct )

PARAMETERS
	win_struct (IN) - The window structure
	context_struct (IN) - The context structure
 
RETURN VALUES
	WL_SUCCESS
		Success

HISTORY
	07/02/93 Shridar Subramanian
		Initial definition, implementation
*/
{
   int sts;
   GLint fg_color, hl_color;

   if ( (win_struct->flags & WLI_WIN_HILITE_MASK) != WLI_WIN_FLAGS_HILITE_NOOP )
   {
      sts = WLglx_make_window_current( win_struct->lwin_no, WL_GLX_HILITE_WIN );
      if ( sts != WL_SUCCESS )
      {
         WL_REPORT_ERROR( sts );
         return( sts );
      }

      if ( ( win_struct->flags & WLI_WIN_HILITE_MASK ) == WLI_WIN_FLAGS_HILITE_DRAW )
      {
         hl_color = 1;
      }
      else
      {
         hl_color = 0;
      }
      
      glIndexi( hl_color );

   }
   

   if ( (win_struct->flags & WLI_WIN_BASE_MASK) != WLI_WIN_FLAGS_BASE_NOOP )
   {
      sts = WLglx_make_window_current( win_struct->lwin_no, WL_GLX_BASE_WIN );
      if ( sts != WL_SUCCESS )
      {
         WL_REPORT_ERROR( sts );
         return( sts );
      }

      if ( ( win_struct->flags & WLI_WIN_BASE_MASK ) == WLI_WIN_FLAGS_BASE_DRAW )
      {
         fg_color = win_struct->color_index;
      }
      else
      {
         fg_color = win_struct->background_color_index;
      }

      glIndexi( fg_color );
   }

   return( WL_SUCCESS );

} /* WLIget_fg_and_hl_OPENGL_IX_HL */

/*---WLIget_fg_and_hl_OPENGL_TC_HL-----------------------------------------*/

static int WLIget_fg_and_hl_OPENGL_TC_HL(
   struct WLIwin *win_struct,
   struct WLIcontext *context_struct)

/*
NAME
	WLIget_fg_and_hl_OPENGL_TC_HL
 
KEYWORD
	WLI (static)
 
DESCRIPTION
	This is an OPENGL implementation of get_fg_and_hl with
        separate hilite windows 

SYNOPSIS
        int WLIget_fg_and_hl_OPENGL_TC_HL(
           struct WLIwin *win_struct,
           struct WLIcontext *context_struct )

PARAMETERS
	win_struct (IN) - The window structure
	context_struct (IN) - The context structure
 
RETURN VALUES
	WL_SUCCESS
		Success

HISTORY
	07/02/93 Shridar Subramanian
		Initial definition, implementation
*/
{
   int sts;
   GLint hl_color;
   GLushort red, green, blue;

   if ( (win_struct->flags & WLI_WIN_HILITE_MASK) != WLI_WIN_FLAGS_HILITE_NOOP )
   {
      if ( ( win_struct->flags & WLI_WIN_HILITE_MASK ) == WLI_WIN_FLAGS_HILITE_DRAW )
      {
         hl_color = 1;
      }
      else
      {
         hl_color = 0;
      }

      sts = WLglx_make_window_current( win_struct->lwin_no, WL_GLX_HILITE_WIN );
      if ( sts != WL_SUCCESS )
      {
         WL_REPORT_ERROR( sts );
         return( sts );
      }

      glIndexi( hl_color );

   }
      
   if ( (win_struct->flags & WLI_WIN_BASE_MASK) != WLI_WIN_FLAGS_BASE_NOOP )
   {
      if ( (win_struct->flags & WLI_WIN_BASE_MASK) == WLI_WIN_FLAGS_BASE_DRAW )
      {
         red = win_struct->red;
         green = win_struct->green;
         blue = win_struct->blue;
      }
      else
      {
         red = win_struct->background_red;
         green = win_struct->background_green;
         blue = win_struct->background_blue;
      }

      sts = WLglx_make_window_current( win_struct->lwin_no, WL_GLX_BASE_WIN );
      if ( sts != WL_SUCCESS )
      {
         WL_REPORT_ERROR( sts );
         return( sts );
      }

      glColor3us( red, green, blue );

   }

   return( WL_SUCCESS );
}/* WLIget_fg_and_hl_OPENGL_TC_HL */


/*---WLIactivate_symbology_OPENGL-----------------------------------------*/

static int WLIactivate_symbology_OPENGL(
   struct WLIwin *win_struct,
   struct WLIcontext *context_struct,
   struct WLIstyle_struct *style_struct,
   int fill_flag )

/*
NAME
	WLIactivate_symbology_OPENGL
 
KEYWORD
	WLI (static)
 
DESCRIPTION
	This is an OPENGL implementation of WLIactivate_symbology without
        separate hilite windows 

SYNOPSIS
        int WLIactivate_symbology_OPENGL(
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
   int   hl_color;


#if defined( X11 )
   sts = WLglx_make_window_current( win_struct->lwin_no, WL_GLX_BASE_WIN );
   if ( sts != WL_SUCCESS )
   {
      WL_REPORT_ERROR( sts );
      return( sts );
   }
#endif

   /* color */
   /* Change the foreground color only if not in dynamics */
   if ( !( win_struct->flags & WLI_WIN_FLAGS_DYNAMICS_ON ) )
   {
      (*win_struct->get_fg_and_hl_OPENGL)(win_struct, context_struct);
                                          
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

      glIndexs( (GLshort) hl_color );
         
   }

   /* gl style */
   if( win_struct->active_blend == 0xaaaa )
   {
      glLineStipple( (GLint)style_struct->pattern_factor,
               (GLushort) style_struct->pattern & win_struct->active_blend );
   }
   else
   {
      glLineStipple( (GLint)style_struct->pattern_factor,
                     (GLushort) style_struct->pattern );
   }
   if ( ( style_struct->pattern == (short) 0xFFFF ) && 
        ( win_struct->active_blend == 0xFFFF ) )
   {
      glDisable( GL_LINE_STIPPLE );
   }
   else
   {
      glEnable( GL_LINE_STIPPLE );
   }

   /* gl pattern */
   glPolygonStipple( (GLubyte *) win_struct->exp_pattern );
   if ( (!fill_flag) || (win_struct->flags & WLI_WIN_FLAGS_B_PATTERN_SOLID) )
   {
      glDisable( GL_POLYGON_STIPPLE );
   }
   else
   {
      glEnable( GL_POLYGON_STIPPLE );
   }

   /* gl weight (NOTE: weights start at 1) */
   glLineWidth( (float) win_struct->active_weight + 1 );
   glPointSize( (float) win_struct->active_weight + 1 );

   return( WL_SUCCESS );
} /* WLIactivate_symbology_OPENGL */

/*---WLIactivate_symbology_OPENGL_HL-----------------------------------------*/

static int WLIactivate_symbology_OPENGL_HL(
   struct WLIwin *win_struct,
   struct WLIcontext *context_struct,
   struct WLIstyle_struct *style_struct,
   int fill_flag )

/*
NAME
	WLIactivate_symbology_OPENGL_HL
 
KEYWORD
	WLI (static)
 
DESCRIPTION
	This is an OPENGL implementation of WLIactivate_symbology with
        separate hilite windows 

SYNOPSIS
        int WLIactivate_symbology_OPENGL_HL(
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
   int   hl_color;

   /* Change the foreground color only if not in dynamics */
   if ( !( win_struct->flags & WLI_WIN_FLAGS_DYNAMICS_ON ) )
   {
      (*win_struct->get_fg_and_hl_OPENGL)(win_struct, context_struct);
                                          
   }
   else
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

#if defined( X11 )
      sts = WLglx_make_window_current( win_struct->lwin_no, WL_GLX_HILITE_WIN );
      if ( sts != WL_SUCCESS )
      {
         WL_REPORT_ERROR( sts );
         return( sts );
      }
#endif
      glIndexs( (GLshort) hl_color );
   }

   /* style and weight and pattern */
   if ( (!(win_struct->flags & WLI_WIN_FLAGS_DYNAMICS_ON)) &&
        ((win_struct->flags & WLI_WIN_BASE_MASK) != WLI_WIN_FLAGS_BASE_NOOP) )
   {
#if defined( X11 )
      sts = WLglx_make_window_current( win_struct->lwin_no, WL_GLX_BASE_WIN );
      if ( sts != WL_SUCCESS )
      {
         WL_REPORT_ERROR( sts );
         return( sts );
      }
#endif
      /* gl style */
      if( win_struct->active_blend == 0xaaaa )
      {
         glLineStipple( (GLint)style_struct->pattern_factor,
                  (GLushort) style_struct->pattern & win_struct->active_blend );
      }
      else
      {
         glLineStipple( (GLint)style_struct->pattern_factor,
                     (GLushort) style_struct->pattern );
      }
      if ( ( style_struct->pattern == (short) 0xFFFF ) && 
           ( win_struct->active_blend == 0xFFFF ) )
      {
         glDisable( GL_LINE_STIPPLE );
      }
      else
      {
         glEnable( GL_LINE_STIPPLE );
      }

      /* gl pattern */
      glPolygonStipple( (GLubyte *) win_struct->exp_pattern );
      if ( (!fill_flag) || (win_struct->flags & WLI_WIN_FLAGS_B_PATTERN_SOLID) )
      {
         glDisable( GL_POLYGON_STIPPLE );
      }
      else
      {
         glEnable( GL_POLYGON_STIPPLE );
      }

      /* gl weight (NOTE: weights start at 1) */
      glLineWidth( (float) win_struct->active_weight + 1 );
      glPointSize( (float) win_struct->active_weight + 1 );

   }

   if ( (win_struct->flags & WLI_WIN_FLAGS_DYNAMICS_ON) ||
        ( (win_struct->flags & WLI_WIN_HILITE_MASK) 
                                   != WLI_WIN_FLAGS_HILITE_NOOP) )
   {
#if defined( X11 )
      sts = WLglx_make_window_current( win_struct->lwin_no, WL_GLX_HILITE_WIN );
      if ( sts != WL_SUCCESS )
      {
         WL_REPORT_ERROR( sts );
         return( sts );
      }
#endif

      /* gl style */
      if( win_struct->active_blend == 0xaaaa )
      {
         glLineStipple( (GLint)style_struct->pattern_factor,
                  (GLushort) style_struct->pattern & win_struct->active_blend );
      }
      else
      {
         glLineStipple( (GLint)style_struct->pattern_factor,
                     (GLushort) style_struct->pattern );
      }
      if ( ( style_struct->pattern == (short) 0xFFFF ) && 
           ( win_struct->active_blend == 0xFFFF ) )
      {
         glDisable( GL_LINE_STIPPLE );
      }
      else
      {
         glEnable( GL_LINE_STIPPLE );
      }

      /* gl pattern */
      glPolygonStipple( (GLubyte *) win_struct->exp_pattern );
      if ( (!fill_flag) || (win_struct->flags & WLI_WIN_FLAGS_B_PATTERN_SOLID) )
      {
         glDisable( GL_POLYGON_STIPPLE );
      }
      else
      {
         glEnable( GL_POLYGON_STIPPLE );
      }

      /* gl weight (NOTE: weights start at 1) */
      glLineWidth( (float) win_struct->active_weight + 1 );
      glPointSize( (float) win_struct->active_weight + 1 );
   }

   return( WL_SUCCESS );
} /* WLIactivate_symbology_OPENGL_HL */

/*--- WLIset_window_functions_OPENGL --------------------------------*/

int WLIset_window_functions_OPENGL(
   struct WLIwin *win_struct )

/*
NAME
   WLIset_window_functions_OPENGL

DESCRIPTION
   This function sets the functions pointers for a window
   that supports OPENGL

SYNOPSIS
   int WLIset_window_functions_OPENGL(
      struct WLIwin *win_struct )

PARAMETERS
   win_struct (IN) - the window structure to set

GLOBALS USED
   none

RETURN VALUES
   WL_SUCCESS
      Success

HISTORY
   06/28/93  S.P. Rogers
      Intitial design and implementation
*/

{
   struct WLIcontext context_struct;
   int sts;

   if ( win_struct->flags & WLI_WIN_FLAGS_USING_OPENGL )
   {
      WLIcontext_retrieve_entry( win_struct->context_no, &context_struct );
      if ( sts != WL_SUCCESS )
      {
         WL_REPORT_ERROR( sts );
         return( sts );
      }

      if ( win_struct->flags & WLI_WIN_SEPARATE_HILITE )
      {
         win_struct->clear_hilite = WLIclear_hilite_OPENGL_HL;
         win_struct->set_drawing_mode = WLIset_drawing_mode_OPENGL_HL;
         win_struct->set_dynamics_drawing_mode = WLIset_dynamics_drawing_mode_OPENGL_HL;
         win_struct->activate_symbology = WLIactivate_symbology_OPENGL_HL;
         if ( context_struct.base_cmap_type == WL_CMAP_TRUE_COLOR )
         {
            win_struct->clear_window = WLIclear_window_OPENGL_TC_HL;
            win_struct->get_fg_and_hl_OPENGL = WLIget_fg_and_hl_OPENGL_TC_HL;
         }
         else
         {
            win_struct->clear_window = WLIclear_window_OPENGL_IX_HL;
            win_struct->get_fg_and_hl_OPENGL = WLIget_fg_and_hl_OPENGL_IX_HL;
         }
      }
      else
      {
         win_struct->clear_hilite = WLIclear_hilite_OPENGL;
         win_struct->set_drawing_mode = WLIset_drawing_mode_OPENGL;
         win_struct->set_dynamics_drawing_mode = WLIset_dynamics_drawing_mode_OPENGL;
         win_struct->activate_symbology = WLIactivate_symbology_OPENGL;
         if ( context_struct.base_cmap_type == WL_CMAP_TRUE_COLOR )
         {
            win_struct->clear_window = WLIclear_window_OPENGL_TC;
            win_struct->get_fg_and_hl_OPENGL = WLIget_fg_and_hl_OPENGL_TC_HL;
         }
         else
         {
            win_struct->clear_window = WLIclear_window_OPENGL_IX;
            win_struct->get_fg_and_hl_OPENGL = WLIget_fg_and_hl_OPENGL_IX;
         }
      }
   }
 
   return( WL_SUCCESS );

} /* WLIset_window_functions_OPENGL */

/*--- WLopengl_enter_2D -------------------------------------*/

int WLopengl_enter_2D( 
   WLuint32 lwin_no,
   int hilite )

/*
NAME
   WLopengl_enter_2D

KEYWORD
   WL

DESCRIPTION
   This function sets up 2D for hilite or base depending on the flag hilite

SYNOPSIS
int WLopengl_enter_2D( 
   WLuint32 lwin_no,
   int hilite )

PARAMETERS
   lwin_no (IN) - the window whose context is to be retrieved
   hilite (IN) - whether the hilite or the base is to be converted

RETURN VALUES
   WL_SUCCESS
      Success

   WL_BAD_WINDOW_NUMBER
      The logical window number is invalid.

B
GLOBALS USED
   none

HISTORY
   06/08/94    Bob Druzynski
      Initial definition
*/
{
   int sts;
   struct WLIwin *win_struct;

   sts = WLIwin_retrieve_entry_ptr( lwin_no, &win_struct );

   if ( win_struct->flags & WLI_WIN_FLAGS_USING_OPENGL )
   {
      if( hilite )
      {
         WLglx_make_window_current( lwin_no, WL_GLX_HILITE_WIN );
         WLI_SETUP_OPENGL_FOR_2D( win_struct, 0 );
         win_struct->native_info.hilite_in_2d=1;
      }
      else
      {
         WLglx_make_window_current( lwin_no, WL_GLX_BASE_WIN );
         WLI_SETUP_OPENGL_FOR_2D( win_struct, 0 );
         win_struct->native_info.base_in_2d=1;
      }
   }
   
   return( WL_SUCCESS );

}  /* WLopengl_enter_2D */

/*--- WLopengl_exit_2D -------------------------------------*/

int WLopengl_exit_2D( 
   WLuint32 lwin_no,
   int hilite )

/*
NAME
   WLopengl_exit_2D

KEYWORD
   WL

DESCRIPTION
   This function exits 2D setup for hilite or base depending on the flag hilite

SYNOPSIS
int WLopengl_exit_2D( 
   WLuint32 lwin_no,
   int hilite )

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
   06/08/94    Bob Druzynski
      Initial definition
*/
{
   int sts;
   struct WLIwin *win_struct;


   sts = WLIwin_retrieve_entry_ptr( lwin_no, &win_struct );
   if ( win_struct->flags & WLI_WIN_FLAGS_USING_OPENGL )
   {
      if( hilite )
      {
         WLglx_make_window_current( lwin_no, WL_GLX_HILITE_WIN );
         WLI_RESTORE_OPENGL_TO_3D( 0 );
         win_struct->native_info.hilite_in_2d=0;
      }
      else
      {
         WLglx_make_window_current( lwin_no, WL_GLX_BASE_WIN );
         WLI_RESTORE_OPENGL_TO_3D( 0 );
         win_struct->native_info.base_in_2d=0;
      }
   }
   
   return( WL_SUCCESS );

}  /* WLopengl_exit_2D */
#endif

