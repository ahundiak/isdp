#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "wl.h"
#include "wl_internal.h"

static WLuint32 WLIlast_lwin_no = WL_UNDEFINED_WINDOW;
static WLhwin_no WLIlast_hwin_no;
static int WLIlast_win_width, WLIlast_win_height;
#if defined( X11 )
static Display *WLIlast_display;
static Window last_child = 0;
#endif

/*--- WLmouse_position -------------------------------------------*/

int WLmouse_position(
	WLuint32 lwin_no,
	int *x,
	int *y,
	int *in_window,
	/* unsigned */ int *key_buttons) /*  (SHOULD WE USE KEY_BUTTONS) */
/*
NAME
	WLmouse_position
 
KEYWORD
	WL

DESCRIPTION
	This function returns the cursor position relative to a window,
	and if the cusor is within the window's working area.

SYNOPSIS
	int WLmouse_position(
        	WLuint32 lwin_no,
        	int *x,
        	int *y,
        	int *in_window,
        	int *key_buttons) 

PARAMETERS
	lwin_no (IN) - logical window number
	x (OUT) - x coordinate
	y (OUT) - y coordinate
	in_window (OUT) - The flag indicating whether the cusor is within
		       the window
	key_buttons (OUT) - The status of the buttons and keys

GLOBALS USED
	not yet

RETURN VALUES
	WL_SUCCESS
		Success

	WL_BAD_WINDOW_NUMBER
		The logical window number is invalid

	WL_BAD_PARAMETER
		One of the pointers is NULL

HISTORY
	08/28/92 Shridar Subramanian
		Initial definition

	10/22/92 Shridar Subramanian
		Initial design
*/
{
   WLuint32 context_no;
   int sts;
   struct WLIwin *win_struct;
   struct WLIcontext *context_struct;
#if defined( X11 )
   Window root, child;
   int root_x, root_y;
#elif defined( WIN32 )
   POINT cursor_pos;
   RECT rect;
#endif

   if ( ( !x ) || ( !y ) || ( !in_window ) || ( !key_buttons ) )
   {
      WL_REPORT_ERROR( WL_BAD_PARAMETER );
      return ( WL_BAD_PARAMETER );
   }

   context_no = WL_DEFAULT_CONTEXT;
   sts = WLIestablish_lwin_and_context( &lwin_no, &context_no, &win_struct, &context_struct );
   if ( sts != WL_SUCCESS )
   {
      WL_REPORT_ERROR( sts );
      return ( sts );
   }

#if defined( X11 )
   XQueryPointer( win_struct->native_info.EXdisplay, win_struct->hwin_no, &root,
      &child, &root_x, &root_y, x, y, (unsigned int *)key_buttons );

   *in_window = (*x >= 0) &&
                (*x < win_struct->area_bounds.width) &&
                (*y >= 0) &&
                (*y < win_struct->area_bounds.height);
  
#elif defined( ENV5 )
   Mouseposition( win_struct->hwin_no, x, y, in_window );
#elif defined( WIN32 )
   GetCursorPos( &cursor_pos );
   ScreenToClient( win_struct->hwin_no, &cursor_pos );
   GetClientRect( win_struct->hwin_no, &rect );

   *x = cursor_pos.x;
   *y = cursor_pos.y;
   
   *in_window = (cursor_pos.x >= 0) &&
                (cursor_pos.x < rect.right) &&
                (cursor_pos.y >= 0) &&
                (cursor_pos.y < rect.bottom);
#endif

   return ( WL_SUCCESS );

} /* WLmouse_position */


/*--- WLmouse_win_position -------------------------------------------*/

int WLmouse_win_position(
   WLuint32 *lwin_no,
   int *x,
   int *y,
   int *in_window )

/*
NAME
	WLmouse_win_position
 
KEYWORD
	WL

DESCRIPTION
	This function determines the logical window that the mouse
	is located in, the position of the mouse with respect to
	the window, and a flag indicating whether the mouse is not
	in the working area of the window (i.e., in the title bar
	or borders).  If the mouse is not in a window that WL knows
	about, the logical window that is returned is WL_UNDEFINED_WINDOW
	and the returned position is relative to the screen.

SYNOPSIS
	int WLmouse_win_position(
        	WLuint32 *lwin_no,
        	int *x,
        	int *y,
        	int *in_window )

PARAMETERS
	lwin_no (OUT) - logical window number, WL_UNDEFINED_WINDOW is
	                mouse is not in a WL window
	x (OUT) - window relative x coordinate; screen relative if 'lwin_no'
	          is WL_UNDEFINED_WINDOW
	y (OUT) - window relative y coordinate; screen relative if 'lwin_no'
	          is WL_UNDEFINED_WINDOW
	in_window (OUT) - The flag indicating whether the cusor is within
		       the working area of the window

GLOBALS USED
	none

RETURN VALUES
	WL_SUCCESS
		Success

	WL_BAD_PARAMETER
		One of the pointers is NULL

	WL_SYSTEM_ERROR
		A windowing system error occurred.

HISTORY
	02/12/93 S.P. Rogers
		Initial definition, design, and implementation

*/

{
   int sts = WL_SUCCESS;
   int found = WLI_FALSE;
   int old_report_error;
   struct WLbounds bounds, area_bounds;
#if defined( NOT_USED )
   WLuint16 lscreen_no;
   WLuint8 group_index, offset;
#endif
#if defined( ENV5 )
   int hwin_no;
#elif defined( X11 )
   WLuint16 lscreen_no;
   struct WLIwin *ptr_win_struct;
   struct WLIscreen screen_struct;
   Window root, child, mapped_child;
   int root_x, root_y, win_x, win_y;
   unsigned int keys_buttons;
#endif

   if ( (! lwin_no ) || ( !x ) || ( !y ) || ( !in_window ) )
   {
      WL_REPORT_ERROR( WL_BAD_PARAMETER );
      return ( WL_BAD_PARAMETER );
   }

   /* turn of WL error reporting temporarily because   */
    /* this code does this that might generate an error */
   old_report_error = WLIreport_error;
   WLIreport_error = WLI_FALSE;

#if defined( NOT_USED )
/*
This portion of the code that is commented out speeds up the mouse movement
but has a drawback in X, in which if two windows are overlapping, if 
the mouse moves over from the window that is below to one above, this
will not be detected.  
*/
   if ( WLIlast_lwin_no != WL_UNDEFINED_WINDOW )
   {
      /* try the last window that the mouse was in */
      sts = WLIwin_unpack( WLIlast_lwin_no, &lscreen_no, &group_index, &offset );
      if ( WLIwin_validate( lscreen_no, group_index, offset ) == WL_SUCCESS )
      {
#if defined( ENV5 )
         sts = ! Mouseposition( WLIlast_hwin_no, x, y, in_window );
#elif defined( X11 )
         sts = XQueryPointer( WLIlast_display, WLIlast_hwin_no, &root, &child,
                              &root_x, &root_y, x, y, &keys_buttons );
#endif

         if ( (sts) && 
              (*x > 0) && (*y > 0) &&
              (*x < WLIlast_win_width) && (*y < WLIlast_win_height) )
         {
            *in_window = WLI_TRUE;
            *lwin_no = WLIlast_lwin_no;
            found = WLI_TRUE;
         }
      }
   }
#endif

   if ( ! found )
   {
#if defined( ENV5 )

      found = WLI_TRUE;
      Mouse_win_position( &hwin_no, x, y, in_window );

      sts = WLget_logical_window( hwin_no, lwin_no );

      if ( sts != WL_SUCCESS )
      {
         /* mouse is not in a window that WL knows about => return */
         /* the mouse coordinates relative to the screen           */ 
         *lwin_no = WLIlast_lwin_no = WL_UNDEFINED_WINDOW;

         /* window 0 is the root window for the RIGHT screen */
         Mouseposition( 0, x, y, in_window );
         if ( ! *in_window )
         {
            /* NOTE:  we'll only get in here if the workstation */
            /* has two physical screens and the mouse is in the */
            /* LEFT screen.                                     */

            /* window 1 is the root window for the LEFT screen */
            Mouseposition( 1, x, y, in_window );
         }
      }
      else
      {
         WLIlast_hwin_no = hwin_no;
         WLIlast_lwin_no = *lwin_no;
         WLget_window_bounds( WLIlast_lwin_no, &bounds, &area_bounds );
         WLIlast_win_width = area_bounds.width;
         WLIlast_win_height = area_bounds.height;
      }

#elif defined( X11 )

      for ( lscreen_no = 0; (lscreen_no < WL_MAX_SCREENS) && !found; lscreen_no++ )
      {
         if ( WLIscreen_retrieve_entry( lscreen_no, &screen_struct ) == WL_SUCCESS )
         {
            /* see if pointer is on this screen */
            if ( XQueryPointer( screen_struct.native_info.EXdisplay,
                                RootWindow( screen_struct.native_info.EXdisplay,
                                            screen_struct.native_info.screen_no ),
                                &root, &child,
                                &root_x, &root_y, &win_x, &win_y, &keys_buttons ) )
            {
               if ( child != 0 )
               {
                  if ( child == last_child )
                  {
                     *lwin_no = WLIlast_lwin_no;
                     *in_window = TRUE;
                     last_child = child;
                  }
                  else
                  {
                     last_child = child;
                     /* pointer is in a child of the root window => see if */
                     /* it's a window that WL knows about                  */
                     sts = WLIwin_get_logical_window_from_root_parent( lscreen_no,
                                                                       screen_struct.native_info.EXdisplay,
                                                                       child, lwin_no );
   
                     if ( sts != WL_SUCCESS )
                     {
                        goto wrapup;
                     }
   
                  }

                  if ( *lwin_no != WL_UNDEFINED_WINDOW )
                  {
                      sts = WLIwin_retrieve_entry_ptr( *lwin_no, &ptr_win_struct );
                     if ( sts != WL_SUCCESS )
                     {
                        last_child = 0;
                        *lwin_no  = WL_UNDEFINED_WINDOW ;
                        found = WLI_TRUE;
                        goto wrapup;
                     }
                      WLIlast_hwin_no = ptr_win_struct->hwin_no;
                      WLIlast_lwin_no = *lwin_no;
                      WLIlast_display = screen_struct.native_info.EXdisplay;
                      WLIlast_win_width = ptr_win_struct->area_bounds.width;
                      WLIlast_win_height = ptr_win_struct->area_bounds.height;

                     /* map root window coordinates to this window */
                     XTranslateCoordinates( screen_struct.native_info.EXdisplay,
                                            RootWindow( screen_struct.native_info.EXdisplay,
                                                        screen_struct.native_info.screen_no ),
                                            WLIlast_hwin_no,
                                            root_x, root_y,
                                            x, y, &mapped_child );

                     if ( (*x > 0) && (*y > 0) &&
                          (*x < WLIlast_win_width) && (*y < WLIlast_win_height) )
                     {
                        /* the cursor is in the window working area */
                        *in_window = WLI_TRUE;
                     }
                     else
                     {
                        /* the cursor is in the window decorations */
                        *in_window = WLI_FALSE;
                     }

                     found = WLI_TRUE;

                  }  /* end: if ( *lwin_no != WL_UNDEFINED_WINDOW ) */
                  else
                  {
                     /* not a WL window => return screen relative */
                     WLIlast_lwin_no = *lwin_no = WL_UNDEFINED_WINDOW;
                     *x = root_x;
                     *y = root_y;
                     *in_window = WLI_TRUE;
                  }

               }  /* if ( child != 0 ) */
               else
               {
                  /* not in a window on the screen => return screen relative */
                  WLIlast_lwin_no = *lwin_no = WL_UNDEFINED_WINDOW;
                  *x = root_x;
                  *y = root_y;
                  *in_window = WLI_TRUE;
                  found = WLI_TRUE;
               }

            }  /* end: if ( XQueryPointer ... */

         }  /* end: if ( WLIscreen_retrieve_entry ... */

      }  /* end: for lscreen_no */

#elif defined( WIN32 )
   /* !!! need NT implementation !!! */
#endif

   }  /* end: if ( ! found ) */

#if defined( X11 )
wrapup:
#endif

   /* turn error reporting back on */
   WLIreport_error = old_report_error;

   if ( ! found )
   {
      WL_REPORT_ERROR( WL_SYSTEM_ERROR );
      return( WL_SYSTEM_ERROR );
   }

   return ( WL_SUCCESS );

} /* WLmouse_win_position */
