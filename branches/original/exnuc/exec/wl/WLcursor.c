#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "wl.h"
#include "wl_internal.h"


/*--- WLhide_cursor ---------------------------------------------*/

int WLhide_cursor(
	WLuint32 lwin_no,
	WLuint32 flag )
/*
NAME
	WLhide_cursor

KEYWORD
	WL

DESCRIPTION
	This function disables the cursor in a window.  If flag = 0, then
	the cursor is only hidden if required to avoid interference with
	drawing. If flag = 1, then the cursor is always hidden.

SYNOPSIS
	int WLhide_cursor(
	        WLuint32 lwin_no,
       		WLuint32 flag )


PARAMETERS
	lwin_no (IN) - logical window number
	flag (IN) - control flag

GLOBALS USED
	not yet

RETURN VALUES
	WL_SUCCESS
		Success

	WL_BAD_WINDOW_NUMBER
		The logical window number is invalid

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

   context_no = WL_DEFAULT_CONTEXT;
   sts = WLIestablish_lwin_and_context( &lwin_no, &context_no, &win_struct, &context_struct );
   if ( sts != WL_SUCCESS )
   {
      WL_REPORT_ERROR( sts );
      return ( sts );
   }

#if defined( ENV5 )
   hidecursor( win_struct->hwin_no );
#else
   if ( flag )
   {
      if ( !(win_struct->flags & WLI_WIN_FLAGS_CURSOR_HIDDEN) )
      {
#if defined( X11 )
         if( ( win_struct->native_info.cursor != NULL ) && 
             ( !( win_struct->flags & WLI_WIN_DOUBLE_BUFFER_DISPLAYED ) ) )
         {
            XDefineCursor( win_struct->native_info.EXdisplay, 
                           win_struct->hwin_no, 
                           win_struct->native_info.null_cursor );
         }
#elif defined( WIN32 )
         SetCursor( NULL );
#endif
      }

      win_struct->flags |= WLI_WIN_FLAGS_CURSOR_HIDDEN;
      sts = WLIwin_set_flags( lwin_no, win_struct->flags );
      if ( sts != WL_SUCCESS )
      {
         WL_REPORT_ERROR( sts );
         return ( sts );
      }
   }
#endif
   return ( WL_SUCCESS );

} /* WLhide_cursor */

/*--- WLshow_cursor ---------------------------------------------*/

int WLshow_cursor(
   WLuint32 lwin_no )
/*
NAME
	WLshow_cursor

KEYWORD
	WL

DESCRIPTION
	This function enables the cursor in a window, if it was disabled.

SYNOPSIS
	int WLshow_cursor(
		WLuint32 lwin_no )

PARAMETERS
	lwin_no	(IN)  - logical window number

GLOBALS USED
	not yet

RETURN VALUES
	WL_SUCCESS
		Success

	WL_BAD_WINDOW_NUMBER
		The logical window number is invalid

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

   context_no = WL_DEFAULT_CONTEXT;
   sts = WLIestablish_lwin_and_context( &lwin_no, &context_no, &win_struct, &context_struct );
   if ( sts != WL_SUCCESS )
   {
      WL_REPORT_ERROR( sts );
      return ( sts );
   }

#if defined( ENV5 )
   showcursor( win_struct->hwin_no );
   flushbuffer( win_struct->hwin_no ); /* for clipper machines that buffer calls */
#else
   if ( win_struct->flags & WLI_WIN_FLAGS_CURSOR_HIDDEN )
   {
#if defined( X11 )
      if( ( win_struct->native_info.cursor != NULL ) && 
             ( !( win_struct->flags & WLI_WIN_DOUBLE_BUFFER_DISPLAYED ) ) )
      {
         XDefineCursor( win_struct->native_info.EXdisplay, win_struct->hwin_no,
                        win_struct->native_info.cursor );
      }
#elif defined( WIN32 )
      SetCursor( win_struct->native_info.cursor );
#endif
      win_struct->flags &= (~WLI_WIN_FLAGS_CURSOR_HIDDEN);
      sts = WLIwin_set_flags(lwin_no,win_struct->flags);
      if ( sts != WL_SUCCESS )
      {
         WL_REPORT_ERROR( sts );
         return ( sts );
      }
   }
#endif
   return ( WL_SUCCESS );

} /* WLshow_cursor */

/*--- WLdefine_cursor ---------------------------------------------*/

int WLdefine_cursor(
	WLuint32 lwin_no,
	char *data,
	char *mask,
	int length,
	int width,
	int lfgcolor,
	int lbgcolor,
	int x_hot,
	int y_hot)

/*
NAME
	WLdefine_cursor

KEYWORD
	WL

DESCRIPTION
	This function defines a cursor and assocites it with the window

SYNOPSIS
	int WLdefine_cursor(
		WLuint32 lwin_no,
		char *data,
		char *mask,
		int length,
		int width,
		int lfgcolor,
		int lbgcolor,
		int x_hot,
		int y_hot)

PARAMETERS
	lwin_no (IN) - logical window number
	data (IN) - The shape of the cursor
	mask (IN) - determines the bits of the cursor to be displayed
		    mask must be the same size as data
	length (IN) - The length of the data and mask
	width (IN) - The width of the data and mask
	lfgcolor (IN) - The foreground color to be used for the cursor
	lbgcolor (IN) - The background color to be used for the cursor
	x_hot (IN) - The x coordinate of the cursor's hot point
	y_hot (IN) - The y coordinate of the cursor's hot point

GLOBALS USED
	not yet

RETURN VALUES
	WL_SUCCESS
		Success

	WL_BAD_WINDOW_NUMBER
		The logical window number is invalid

HISTORY
	08/28/92 Shridar Subramanian
		Initial definition

	10/22/92 Shridar Subramanian
		Initial design
*/
{
   WLuint32 context_no;
   int sts;
   WLcursor cursor;
   struct WLIwin *win_struct;
   struct WLIcontext *context_struct;
   WLuint32 red, green, blue, color_index, color_flags;
   WLuint32 new_red, new_green, new_blue;
   struct WLcmap_entry cmap_entry;
#if defined( X11 )
   XColor fgcolor, bgcolor;
   Pixmap PixelMap, mask_map;
#elif defined( ENV5 )
   struct rgb_color fgcolor, bgcolor;
#endif

   red = green = blue = new_red = new_green = new_blue = 
   color_index = 0;
   context_no = WL_DEFAULT_CONTEXT;
   sts = WLIestablish_lwin_and_context( &lwin_no, &context_no, 
                                        &win_struct, &context_struct );
   if ( sts != WL_SUCCESS )
   {
      WL_REPORT_ERROR( sts );
      return ( sts );
   }

#if defined( X11 ) || defined( ENV5 )
   WLIwin_unpack_colorref( lfgcolor, &color_index, &red, &green, &blue,
                           &color_flags );
   
   if ( color_flags & WL_COLOR_PHYSICAL )
   {
      if ( color_flags & WL_COLOR_RGB )
      {
         fgcolor.red = red;
         fgcolor.green = green;
         fgcolor.blue = blue;
      }
      else
      {
         cmap_entry.slot = color_index;
         WLread_cmap_entries( win_struct->context_no, 1, &cmap_entry );
         fgcolor.red = cmap_entry.red;
         fgcolor.green = cmap_entry.green;
         fgcolor.blue = cmap_entry.blue;
      }
   }
   else
   {
      (*context_struct->cmap_color_to_rgb)( win_struct->context_no, 
                                            color_index, (WLuint32)red, 
                                            (WLuint32)green, (WLuint32)blue, 
                                            (WLuint32)color_flags, &new_red, 
                                            &new_green, 
                                            &new_blue );
      fgcolor.red = new_red;
      fgcolor.green = new_green;
      fgcolor.blue = new_blue;
   }
   WLIwin_unpack_colorref( lbgcolor, &color_index, &red, &green, &blue,
                           &color_flags );
   if ( color_flags & WL_COLOR_PHYSICAL )
   {
      if ( color_flags & WL_COLOR_RGB )
      {
         bgcolor.red = red;
         bgcolor.green = green;
         bgcolor.blue = blue;
      }
      else
      {
         cmap_entry.slot = color_index;
         WLread_cmap_entries( win_struct->context_no, 1, &cmap_entry );
         bgcolor.red = cmap_entry.red;
         bgcolor.green = cmap_entry.green;
         bgcolor.blue = cmap_entry.blue;
      }
   }
   else
   {
      (*context_struct->cmap_color_to_rgb)( win_struct->context_no, 
                                            color_index, (WLuint32)red,
                                            (WLuint32)green,  (WLuint32)blue, 
                                            (WLuint32)color_flags, 
                                            &new_red, &new_green, 
                                            &new_blue );
      bgcolor.red = new_red;
      bgcolor.green = new_green;
      bgcolor.blue = new_blue;
   }
#endif

#if defined( X11 )
   /* Format the data and mask */

   PixelMap = XCreateBitmapFromData( win_struct->native_info.EXdisplay,
      win_struct->hwin_no, data, (unsigned int)width, (unsigned int)length );
   mask_map = XCreateBitmapFromData( win_struct->native_info.EXdisplay,
      win_struct->hwin_no, mask, (unsigned int)width, (unsigned int)length );
   cursor = XCreatePixmapCursor( win_struct->native_info.EXdisplay, PixelMap,
      mask_map, &fgcolor, &bgcolor, x_hot, y_hot );

   XDefineCursor( win_struct->native_info.EXdisplay, win_struct->hwin_no,
      cursor );
#elif defined( ENV5 )
   {
      struct scr_info scrns[MAX_SCREENS];
      WLuint16 lscreen_no;
      WLuint8 group_index;
      WLuint8 offset;

      WLIwin_unpack( lwin_no, &lscreen_no, &group_index, &offset );
      if ( WLIwin_validate( lscreen_no, group_index, offset) != WL_SUCCESS)
      {
         WL_REPORT_ERROR( WL_BAD_WINDOW_NUMBER );
         return( WL_BAD_WINDOW_NUMBER );
      }

      /* Look for vsi_cursor_color */
      Inq_screen_info ( scrns );

      hidecursor( win_struct->hwin_no );

      if ( scrns[(WLIscreens_arr[(lwin_no>>16)].native_info.screen_no)].vsi_flags
         | VSI_CURSOR_COLOR )
      {
         defcursorcolor( win_struct->hwin_no, &fgcolor, &bgcolor );
      }
      defcursor( win_struct->hwin_no, mask, data, x_hot, y_hot );
      showcursor( win_struct->hwin_no );
   }
#elif defined( WIN32 )
   /* Format the data and mask */
   cursor = CreateCursor( win_struct->native_info.hinstance, x_hot, y_hot, width,
      length, data, mask );
   sts = WLIwin_set_cursor( lwin_no, cursor );
   if (sts != WL_SUCCESS)
   {
      WL_REPORT_ERROR( sts );
      return( sts );
   }
#endif

#if defined( ENV5 )
#else
   sts = WLIwin_set_cursor( lwin_no, cursor );
   if ( sts != WL_SUCCESS )
   {
      WL_REPORT_ERROR( sts );
      return ( sts );
   }
#endif

   win_struct->flags &= (~WLI_WIN_FLAGS_CURSOR_HIDDEN);
   sts = WLIwin_set_flags( lwin_no, win_struct->flags );

   if ( sts != WL_SUCCESS )
   {
      WL_REPORT_ERROR( sts );
      return ( sts );
   }
   return ( WL_SUCCESS );

} /* WLdefine_cursor */
