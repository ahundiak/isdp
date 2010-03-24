#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <memory.h>

#include "wl.h"
#include "wl_internal.h"
 
 
/*--- WLget_logical_screen_from_window-------------------------------*/
 
int WLget_logical_screen_from_window(
   WLhwin_no hwin_no,
   WLuint16 *lscreen_no)
 
/*
NAME
   WLget_logical_screen_from_window
 
KEYWORD
   WL
 
DESCRIPTION
   This function gets the logical screen number, given a hardware
   window number

SYNOPSIS
   int WLget_logical_screen_from_window(
      WLhwin_no hwin_no,
      WLuint16 *lscreen_no)
 
PARAMETERS
   hwin_no (IN) - Hardware window number
   lscreen_no (OUT) - logical screen number
 
GLOBALS USED
   not yet

RETURN VALUES
   WL_SUCCESS
      Success
 
   WL_BAD_HARDWARE_WINDOW
      The hardware window is invalid
 
   WL_BAD_PARAMETER
      The "lscreen_no" pointer is NULL
 
HISTORY
   08/28/92 Shridar Subramanian
      Initial definition
 
   10/22/92 Shridar Subramanian
      Initial design
*/
{
   int screen_no;
   int status;
   int found = WLI_FALSE;
   WLuint16 i;
   int old_report_error;

#if defined(X11)
   struct WLIscreen screen_struct;
   XWindowAttributes window_attributes;
#endif
 
   if ( lscreen_no == NULL )
   {
      WL_REPORT_ERROR( WL_BAD_PARAMETER ); 
      return( WL_BAD_PARAMETER );
   }

#if defined(WIN32)
   *lscreen_no = 0;
 
#elif defined(X11)
   for( i = 0; ( i < WL_MAX_SCREENS ) && ( !found ); i++ )
   {
      if ( WLIscreen_retrieve_entry( i, &screen_struct ) == WL_SUCCESS )
      {
         found = WLI_TRUE;
      }
   }
   if (!found)
   {
      WL_REPORT_ERROR( WL_SYSTEM_ERROR );
      return( WL_SYSTEM_ERROR );
   }
 
/*
   status = XGetWindowAttributes( screen_struct.native_info.EXdisplay,
            hwin_no, &window_attributes);
*/
   status = 0;
   if ( !status )
   {

#elif defined (ENV5 )

   status = Inq_win_vs( hwin_no, &screen_no );
   if ( status )
   {

#endif

      old_report_error = WLIreport_error;
      WLIreport_error = WLI_FALSE;
      /* The hardware window may have just been deleted ( using the X icon ) */
      /* See if it is still there in the WL structures                       */
      found = WLI_FALSE;
      for ( i = 0; ( i < WL_MAX_SCREENS ) && ( !found ); i++ )
      {
         status = WLIscreen_hardware_to_logical( i, lscreen_no );
         if ( status == WL_SUCCESS )
         {
            found = WLI_TRUE;
         }
      }

      WLIreport_error = old_report_error;
      if ( !found )
      {
         WL_REPORT_ERROR( WL_BAD_HARDWARE_WINDOW );
         return( WL_BAD_HARDWARE_WINDOW );
      }
   }
   else
   {
 
#if defined( X11 )

      screen_no = XScreenNumberOfScreen( window_attributes.screen );

#endif
         
      status = WLIscreen_hardware_to_logical( screen_no, lscreen_no );
      if ( status != WL_SUCCESS ) 
      {
         WL_REPORT_ERROR( status );
         return( status );
      }
   } 
   return( WL_SUCCESS );

}  /* WLget_logical_screen_from_window */

/*--- WLget_window_name -----------------------------------------------*/
 
int WLget_window_name(
   WLuint32 lwin_no,
   char **name )
 
/*
NAME
   WLget_window_name
 
KEYWORD
   WL
 
DESCRIPTION
   This function gets the name of a window.

SYNOPSIS
   int WLget_window_name(
      WLuint32 lwin_no,
      char **name )
 
PARAMETERS
   lwin_no (IN) - logical window number
   name (OUT) - Window name. The caller is responsible for freeing the
                memory with WLfree().
 
GLOBALS USED
   not yet

RETURN VALUES
   WL_SUCCESS
      Success
 
   WL_BAD_WINDOW_NUMBER
      The logical window number is invalid
 
   WL_BAD_PARAMETER
      The "name" pointer is NULL
 
 
RELATED INFORMATION
   Functions: WLcreate_window(), WLset_window_name()
 
HISTORY
   08/28/92 Shridar Subramanian
      Initial definition
 
   10/22/92 Shridar Subramanian
      Initial design
*/
{
   int status;
   struct WLIwin win_struct;

#if defined ( X11)
   XTextProperty text_prop;
   char **list;
   int count;
#endif
 
 
   if ( ! name )
   {
      WL_REPORT_ERROR( WL_BAD_PARAMETER );
      return ( WL_BAD_PARAMETER );
   }
      
   *name = NULL;

   status = WLIwin_retrieve_entry( lwin_no, &win_struct );
   if (status != WL_SUCCESS)
   {
      WL_REPORT_ERROR( status );
      return ( status );
   }


#if defined (X11)
   status = XGetWMName( win_struct.native_info.EXdisplay, win_struct.hwin_no,
                        &text_prop);
   if ( !status )
   {
      WL_REPORT_ERROR( WL_SYSTEM_ERROR );
      return ( WL_SYSTEM_ERROR );
   }
   status = XTextPropertyToStringList( &text_prop, &list, &count );
   if ( !status )
   {
      WL_REPORT_ERROR( WL_SYSTEM_ERROR );
      return ( WL_SYSTEM_ERROR );
   }

   *name = (char *) malloc( strlen( list[0] ) + 1 );
   if ( ! *name )
   {
      WL_REPORT_ERROR( WL_ERROR );
      return( WL_ERROR );
   }
   strcpy( *name, list[0] );
 
#elif defined (ENV5)

   *name = (char *)malloc( 256 ); /* Should be plenty */
   if ( ! *name )
   {
      WL_REPORT_ERROR( WL_ERROR );
      return( WL_ERROR );
   }

   status = Inq_win_name( win_struct.hwin_no, *name, 256 );
   if ( status )
   {
      WL_REPORT_ERROR( WL_SYSTEM_ERROR );
      return ( WL_SYSTEM_ERROR );
   }
 
#elif defined (WIN32)
   *name = (char *)malloc( 256 ); /* Should be plenty */
   if ( ! *name )
   {
      WL_REPORT_ERROR( WL_ERROR );
      return( WL_ERROR );
   }

   status = GetWindowText( win_struct.hwin_no, *name, 256 );
   if ( !status )
   {
      WL_REPORT_ERROR( WL_SYSTEM_ERROR );
      return ( WL_SYSTEM_ERROR );
   }
 
#endif

   return (WL_SUCCESS);

}  /* WLget_window_name */
 
/*--- WLget_logical_window -------------------------------------------*/
 
int WLget_logical_window(
   WLhwin_no hwin_no,
   WLuint32 *lwin_no)
 
/*
NAME
   WLget_logical_window
 
KEYWORD
   WL
 
DESCRIPTION
   This function gets the logical window number associated with a
   hardware window

SYNOPSIS
   int WLget_logical_window(
      WLhwin_no hwin_no,
      WLuint32 *lwin_no)
 
PARAMETERS
   hwin_no (IN) - The hardware window number
   lwin_no (OUT) - logical window number
 
GLOBALS USED
   not yet
 
RETURN VALUES
   WL_SUCCESS
      Success
 
   WL_BAD_HARDWARE_WINDOW
      The hardware window is invalid
 
   WL_BAD_PARAMETER
      The "lwin_no" pointer is NULL
 
HISTORY
   08/28/92 Shridar Subramanian
      Initial definition
 
   10/22/92 Shridar Subramanian
      Initial design
*/
{
   int hscreen_no;
   int status;
   WLuint16 lscreen_no;
   int found = WLI_FALSE;
   WLuint16 i;
#if defined(X11)
   struct WLIscreen screen_struct;
   XWindowAttributes window_attributes;
#endif
   int old_report_error;
 
   if ( lwin_no == NULL )
   {
      WL_REPORT_ERROR( WL_BAD_PARAMETER );
      return ( WL_BAD_PARAMETER );
   }
 
#if defined(WIN32)
 
   lscreen_no = 0;
   status = WLIwin_hardware_to_logical( lscreen_no, hwin_no, lwin_no );
   if ( status != WL_SUCCESS )
   {
      WL_REPORT_ERROR( WL_BAD_HARDWARE_WINDOW );
      return( WL_BAD_HARDWARE_WINDOW );
   }
 
#elif defined(X11)
   for( i = 0; (i < WL_MAX_SCREENS) && (!found); i++ )
   {
      if ( WLIscreen_retrieve_entry( i, &screen_struct ) == WL_SUCCESS )
      {
         found = WLI_TRUE;
      }
   }
 
   if ( !found )
   {
      WL_REPORT_ERROR( WL_ERROR );
      return( WL_ERROR );
   }
 
   found = WLI_FALSE;

   /* be careful with the following code to make sure that */
   /* WLIreport_error gets reset properly                  */
   old_report_error = WLIreport_error;
   WLIreport_error = WLI_FALSE;

/*
   status = XGetWindowAttributes( screen_struct.native_info.EXdisplay, hwin_no,
                                  &window_attributes );
*/

   status = 0;
 

   if ( status )
   {
 
      hscreen_no = XScreenNumberOfScreen( window_attributes.screen );
 
      status = WLIscreen_hardware_to_logical( hscreen_no, &lscreen_no );
      if ( status != WL_SUCCESS )
      {
         goto wrapup;
      }
 
      status = WLIwin_hardware_to_logical( lscreen_no, hwin_no, lwin_no );
      if ( status != WL_SUCCESS )
      {
         goto wrapup;
      }
      else
      {
         /* logical window was found */
         found = WLI_TRUE;
      }

   }
 
# elif defined (ENV5)
   found = WLI_FALSE;

   /* be careful with the following code to make sure that */
   /* WLIreport_error gets reset properly                  */
   old_report_error = WLIreport_error;
   WLIreport_error = WLI_FALSE;

   if ( !Inq_win_vs( hwin_no, &hscreen_no ) )
   {
      status = WLIscreen_hardware_to_logical( hscreen_no, &lscreen_no );
      if ( status != WL_SUCCESS )
      {
         goto wrapup;
      }

      status = WLIwin_hardware_to_logical( lscreen_no, hwin_no, lwin_no );
      if ( status != WL_SUCCESS )
      {
         /* the hardware window may have changed screens => see if */
         /* it is still in the WL structures                       */
         for ( i = 0; i < WL_MAX_SCREENS; i++ )
         {
            status = WLIwin_hardware_to_logical( i, hwin_no, lwin_no ); 
            if ( status == WL_SUCCESS )
            {
               found = WLI_TRUE;
               break;
            }
         }
      }
      else
      {
         found = WLI_TRUE;
      }
   }

#endif

   else
   {
      /* The hardware window may have just been deleted ( using the X icon ) */
      /* See if it is still there in the WL structures                       */
      for ( i = 0; i < WL_MAX_SCREENS; i++ )
      {
         status = WLIwin_hardware_to_logical( i, hwin_no, lwin_no ); 
         if ( status == WL_SUCCESS )
         {
            found = WLI_TRUE;
            break;
         }
      }
      WLIreport_error = old_report_error;
   }

wrapup:
   
   /* make sure all ENV5  and X return paths go through here to */
   /* reset WLIreport_error correctly                           */
   WLIreport_error = old_report_error;

   if ( !found )
   {
      /* no report error here */
      return( WL_BAD_HARDWARE_WINDOW );
   }

 
   return( WL_SUCCESS );
}  /* WLget_logical_window */

/*--- WLget_native_info -------------------------------------------*/
 
int WLget_native_info(
   WLuint32 lwin_no,
   WLuint32 context_no,
   struct WLnative_info *native_info)
 
 
/*
NAME
   WLget_native_info
 
KEYWORD
   WL
 
DESCRIPTION
   This function get the native windowing system information

SYNOPSIS
   int WLget_native_info(
      WLuint32 lwin_no,
      WLuint32 context_no,
      struct WLnative_info *native_info)
 
PARAMETERS
   lwin_no (IN) - The logical window number
   context_no (IN)  - context number
   native_info (OUT) - The native windowing system information

GLOBALS USED
   not yet
 
RETURN VALUES
   WL_SUCCESS
      Success
 
   WL_BAD_WINDOW_NUMBER
      The logical window number is invalid
 
   WL_BAD_CONTEXT
      The context is invalid
 
   WL_BAD_PARAMETER
      The "native_info" pointer is NULL
 
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
 
   status = WLIwin_retrieve_entry( lwin_no, &win_struct );
   if ( status != WL_SUCCESS )
   {
      WL_REPORT_ERROR( status );
      return( status );
   }
   status = WLIcontext_retrieve_entry( context_no, &context_struct );
   if ( status != WL_SUCCESS)
   {
      WL_REPORT_ERROR( status );
      return( status );
   }
#if defined (X11)
   native_info->display = win_struct.native_info.EXdisplay;
   native_info->gc = win_struct.native_info.EXgc;
   native_info->base_win = win_struct.hwin_no;
   native_info->colormap = context_struct.native_info.EXcolormap;
   native_info->visual = context_struct.native_info.visual;
   native_info->screen = win_struct.native_info.screen_no;
#if defined( OPENGL )
   native_info->glx_context = win_struct.native_info.glx_context;
   native_info->hl_glx_context = win_struct.native_info.hl_glx_context;
#endif
#if defined( XGL )
   native_info->xgl_color_type = win_struct.native_info.xgl_color_type;
   native_info->xgl_hlhsr_mode = win_struct.native_info.xgl_hlhsr_mode;
   native_info->xgl_context_3D = win_struct.native_info.xgl_context_3D;
   native_info->hl_xgl_context_3D = win_struct.native_info.hl_xgl_context_3D;
   native_info->sys_state = win_struct.native_info.sys_state;
/*
   native_info->xgl_base_cmap = win_struct.native_info.xgl_base_cmap;
   native_info->xgl_hilite_cmap = win_struct.native_info.xgl_hilite_cmap;
*/
   native_info->win_ras = win_struct.native_info.win_ras;
   native_info->hl_win_ras = win_struct.native_info.hl_win_ras;
   native_info->mem_ras = win_struct.native_info.mem_ras;
   native_info->hl_mem_ras = win_struct.native_info.hl_mem_ras;
#endif
#elif (ENV5)
   native_info->base_win = win_struct.hwin_no;
   native_info->vlt_no = context_struct.native_info.vlt_no;
   native_info->vs_no = win_struct.native_info.screen_no;
 
#elif (WIN32)
   native_info->base_win = win_struct.hwin_no;
   native_info->hdc = win_struct.native_info.hdc;
   native_info->cursor = win_struct.native_info.cursor;
   native_info->palette = context_struct.native_info.palette;
   native_info->class = win_struct.native_info.class;
   native_info->hinstance = win_struct.native_info.hinstance;
   native_info->wnd_proc = win_struct.native_info.wnd_proc;
 
#endif
 
   return( WL_SUCCESS );

}  /* WLget_native_info */

/*--- WLget_window_screen -----------------------------------------------*/
 
int WLget_window_screen(
   WLuint32 lwin_no,
   WLuint16 *lscreen_no )
 
/*
NAME
   WLget_window_screen
 
KEYWORD
   WL
 
DESCRIPTION
   This function gets the screen number of a window.

SYNOPSIS
   int WLget_window_screen(
      WLuint32 lwin_no,
      WLuint16 *lscreen_no )
 
PARAMETERS
   lwin_no (IN) - logical window number
   lscreen_no (OUT) - logical screen number
 
GLOBALS USED
   not yet

RETURN VALUES
   WL_SUCCESS
      Success
 
   WL_BAD_WINDOW_NUMBER
      The logical window number is invalid
 
   WL_BAD_PARAMETER
      The "lscreen_no" pointer is NULL
 
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
 
   if ( lscreen_no == NULL )
   {
      WL_REPORT_ERROR ( WL_BAD_PARAMETER );
      return ( WL_BAD_PARAMETER );
   }
 
   status = WLIwin_unpack( lwin_no, lscreen_no, NULL, NULL );
   if (status != WL_SUCCESS)
   {
      WL_REPORT_ERROR( status );
      return(status);
   }
 
   return ( WL_SUCCESS );
}  /* WLget_window_screen */
 

/*--- WLget_user_data -----------------------------------------------*/
 
int WLget_user_data(
   WLuint32 lwin_no,
   void **exnuc_data,
   void **data1)
 
/*
NAME
   WLget_user_data
 
KEYWORD
   WL
 
DESCRIPTION
   This function gets the user data from a window

SYNOPSIS
   int WLget_user_data(
      WLuint32 lwin_no,
      void **exnuc_data,
      void **data1)
 
PARAMETERS
   lwin_no (IN) - logical window number
   exnuc_data (OUT) - the channel number for EXNUC or NULL
            if not wanted
   data1 (OUT) - data or NULL if not wanted
 
GLOBALS USED
   not yet
 
RETURN VALUES
   WL_SUCCESS
      Success
 
   WL_BAD_WINDOW_NUMBER
      The logical window number is invalid
 
RELATED INFORMATION
   Functions: WLcreate_window(), WLget_window_contexts()
 
HISTORY
   08/28/92 Shridar Subramanian
      Initial definition
 
   10/22/92 Shridar Subramanian
      Initial design
*/
 
 
{
   int status;

   status = WLIwin_get_user_data( lwin_no, exnuc_data, data1 );
   if ( status != WL_SUCCESS )
   {
      WL_REPORT_ERROR( status );
      return( status );
   }
   return ( WL_SUCCESS );
}  /* WLget_user_data */


/*--- WLget_collapse_parms-----------------------------------------------*/
 
int WLget_collapse_parms(
   WLuint32 lwin_no,
   int *x,
   int *y)
 
/*
NAME
   WLget_collapse_parms
 
KEYWORD
   WL
 
DESCRIPTION
   This function get the collapse origin for a window

SYNOPSIS
   int WLget_collapse_parms(
      WLuint32 lwin_no,
      int *x,
      int *y)
 
PARAMETERS
   lwin_no (IN) - logical window number
   x (OUT) - The x coordinate of the collapse origin
   y (OUT) - The y coordinate of the collapse origin
 
GLOBALS USED
   not yet

RETURN VALUES
   WL_SUCCESS
      Success
 
   WL_BAD_WINDOW_NUMBER
      The logical window number is invalid
 
   WL_BAD_PARAMETER
      Either 'x' or 'y' is NULL

RELATED INFORMATION
 
HISTORY
   08/28/92 Shridar Subramanian
      Initial definition
 
   10/22/92 Shridar Subramanian
      Initial design
*/
{
   int status;
   struct WLIwin win_struct;
#if defined (X11)
   XWMHints *hints;
#endif
 
   if ( (!x) || (!y) )
   {
      WL_REPORT_ERROR( WL_BAD_PARAMETER );
      return( WL_BAD_PARAMETER );
   }

   status = WLIwin_retrieve_entry( lwin_no, &win_struct );
   if (status != WL_SUCCESS)
   {
      WL_REPORT_ERROR ( status );
      return ( status );
   }
 
#if defined (X11)
 
   hints = XGetWMHints( win_struct.native_info.EXdisplay, win_struct.hwin_no );
   if ( hints == NULL )
   {
      WL_REPORT_ERROR( WL_SYSTEM_ERROR );
      return( WL_SYSTEM_ERROR );
   }
   *x = hints->icon_x;
   *y = hints->icon_y;

   XFree( (caddr_t)hints );

#elif (ENV5)
   status = Inq_win_collapse_org( win_struct.hwin_no, x, y);
   if ( status )
   {
      WL_REPORT_ERROR( WL_SYSTEM_ERROR );
      return ( WL_SYSTEM_ERROR );
   }
#elif (WIN32)
   /* !!! need NT implementation */ 
#endif
   return( WL_SUCCESS );
}  /* WLget_collapse_parms */


/*--- WLset_user_data -----------------------------------------------*/
 
int WLset_user_data(
   WLuint32 lwin_no,
   void **exnuc_data,
   void **data1)
 
/*
NAME
   WLset_user_data
 
KEYWORD
   WL
 
DESCRIPTION
   This function associates user data with a window

SYNOPSIS
   int WLset_user_data(
      WLuint32 lwin_no,
      void **exnuc_data,
      void **data1)
 
PARAMETERS
   lwin_no (IN) - logical window number
   exnuc_data (IN) - the channel number for EXNUC or NULL
            if not to be set
   data1 (IN) - data or NULL if not to be set
 
GLOBALS USED
   not yet
 
RETURN VALUES
   WL_SUCCESS
      Success
 
   WL_BAD_WINDOW_NUMBER
      The logical window number is invalid
 
RELATED INFORMATION
   Functions: WLcreate_window(), WLget_window_contexts()
 
HISTORY
   08/28/92 Shridar Subramanian
      Initial definition
 
   10/22/92 Shridar Subramanian
      Initial design
*/
{
   int status;
 
   status = WLIwin_set_user_data( lwin_no, exnuc_data, data1 );
   if ( status != WL_SUCCESS )
   {
      WL_REPORT_ERROR( status );
      return( status );
   }
   return( WL_SUCCESS );
}  /* WLset_user_data */

/*--- WLset_collapse_parms -----------------------------------------------*/
 
int WLset_collapse_parms(
   WLuint32 lwin_no,
   int x,
   int y,
   int collapse_state )
 
/*
NAME
   WLset_collapse_parms
 
KEYWORD
   WL
 
DESCRIPTION
   This function set the collapse origin for a window, and its
   collapse state (collapsed ot not)

SYNOPSIS
   int WLset_collapse_parms(
      WLuint32 lwin_no,
      int x,
      int y,
      int collapse_state )
 
PARAMETERS
   lwin_no (IN) - logical window number

   x (IN) - The x coordinate of the collapse origin
   y (IN) - The y coordinate of the collapse origin
   collapse_state (IN) - The collapse state
 
GLOBALS USED
   not yet
 
RETURN VALUES
   WL_SUCCESS
      Success
 
   WL_BAD_WINDOW_NUMBER
      The logical window number is invalid
 
RELATED INFORMATION
 
HISTORY
   08/28/92 Shridar Subramanian
      Initial definition
 
   10/22/92 Shridar Subramanian
      Initial design
*/
 
{
   int status;
   struct WLIwin   win_struct;
#if defined (X11)
   XWMHints hints;
#endif
 
   status = WLIwin_retrieve_entry( lwin_no, &win_struct );
   if ( status != WL_SUCCESS )
   {
      WL_REPORT_ERROR( status );
      return( status );
   }
 
#if defined (X11)
   hints.icon_x = x;
   hints.icon_y = y;
   hints.flags = IconPositionHint;

   if ( collapse_state == WL_COLLAPSED)
   {
      hints.flags = StateHint;
      hints.initial_state = IconicState;
   }
 
   XSetWMHints( win_struct.native_info.EXdisplay, win_struct.hwin_no, &hints );
 
#elif defined (ENV5)
   if ( collapse_state == WL_COLLAPSED )
   {
      Collapse_win( win_struct.hwin_no, x, y);
   }
   else
   {
      Set_win_collapse_org( win_struct.hwin_no, x, y);
   }
 
#elif defined (WIN32)
   /* !!! Need NT implementation */
#endif
   return( WL_SUCCESS );
}  /* WLset_collapse_parms */

/*--- WLset_window_name-----------------------------------------------*/
 
int WLset_window_name(
   WLuint32 lwin_no,
   char *new_name )
 
/*
NAME
   WLset_window_name
 
KEYWORD
   WL
 
DESCRIPTION
   This function changes the name of a window.

SYNOPSIS
   int WLset_window_name(
      WLuint32 lwin_no,
      char *new_name )

 
PARAMETERS
   lwin_no (IN) - Logical window number.
   new_name (IN) - new name for the window
 
GLOBALS USED
   not yet
 
RETURN VALUES
   WL_SUCCESS
      Success
 
   WL_BAD_WINDOW_NUMBER
      The logical window number is invalid
 
   WL_BAD_PARAMETER
      The "new_name" pointer is NULL
 
RELATED INFORMATION
   Functions: WLcreate_window( )
 
HISTORY
   08/28/92 Shridar Subramanian
      Initial definition
 
   10/22/92 Shridar Subramanian
      Initial design
*/
 
{
   int status;
   struct  WLIwin win_struct;
#if defined (X11)
    XTextProperty text_prop;
#endif
 
   status = WLIwin_retrieve_entry( lwin_no, &win_struct );
   if ( status != WL_SUCCESS )
   {
      WL_REPORT_ERROR( status );
      return( status );
   }
 
#if defined (X11)
   status = XStringListToTextProperty( &new_name, 1, &text_prop );
   if ( !status )
   {
      WL_REPORT_ERROR( WL_SYSTEM_ERROR );
      return ( WL_SYSTEM_ERROR );
   }
 
   XSetWMName( win_struct.native_info.EXdisplay, win_struct.hwin_no, &text_prop );

   XFree( (caddr_t)text_prop.value );

 
#elif defined (ENV5)
   status = Set_win_name( win_struct.hwin_no, new_name );
   if ( status )
   {
      WL_REPORT_ERROR( WL_SYSTEM_ERROR );
      return( WL_SYSTEM_ERROR );
   }
#elif defined (WIN32)
   SetWindowText( win_struct.hwin_no, new_name );
#endif
   return( WL_SUCCESS );
}  /* WLset_window_name */
 
/*--- WLset_clip_box -----------------------------------------------*/
 
/*ARGSUSED*/
int WLset_clip_box(
   WLuint32 lwin_no,
   WLuint32 context_no,
   int xmin,
   int ymin,
   int width,
   int height)
 
/*
NAME
   WLset_clip_box
 
KEYWORD
   WL
 
DESCRIPTION
   This function sets the clip box for the window

SYNOPSIS
   int WLset_clip_box(
      WLuint32 lwin_no,
      WLuint32 context_no,
      int xmin,
      int ymin,
      int width,
      int height)
 
PARAMETERS
   lwin_no (IN)  - logical window number
   context_no (IN) - The context number
   xmin (IN) - The x coordinate of the upper left corner of the
          clip box
   ymin (IN) - The y coordinate of the upper left corner of the
          clip box
   width (IN) - The width of the clip box
   height (IN) - The height of the clip box
 
GLOBALS USED
   not yet
 
RETURN VALUES
   WL_SUCCESS
      Success
 
   WL_BAD_WINDOW_NUMBER
      The logical window number is invalid
 
   WL_BAD_CONTEXT
      The context number is invalid
 
   WL_BAD_P_PARAMETER
      One of the clip box coordinates is invalid
 
HISTORY
   08/28/92 Shridar Subramanian
      Initial definition
 
   10/22/92 Shridar Subramanian
      Initial design
*/
{
   int status;
   struct WLIwin win_struct;
#if defined (X11)
   XRectangle rectangles;
#elif defined (WIN32)
   HRGN hrgn;
#endif
 
   if ( (xmin < 0) || (ymin < 0) ||
        (width < 0) || (height < 0) )
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
 
#if defined (X11)
   rectangles.x = (short)xmin;
   rectangles.y = (short)ymin;
   rectangles.width = (short)width;
   rectangles.height = (short)height;

   XSetClipRectangles( win_struct.native_info.EXdisplay, 
         win_struct.native_info.EXgc, xmin, ymin, &rectangles, 1,
         Unsorted );
 
#elif defined (ENV5)
   status = clipbox( win_struct.hwin_no, xmin, ymin, xmin+width, ymin+height );
   if ( status )
   {
      WL_REPORT_ERROR( WL_SYSTEM_ERROR );
      return( WL_SYSTEM_ERROR );
   }
 
#elif defined (WIN32)
   hrgn = CreateRectRgn( xmin, ymin, xmin+width, ymin+height );
   if ( !hrgn )
   {
      WL_REPORT_ERROR( WL_SYSTEM_ERROR );
      return( WL_SYSTEM_ERROR );
   }
   status = SelectClipRgn( win_struct.hwin_no, hrgn );
   if ( status == ERROR )
   {
      WL_REPORT_ERROR( WL_SYSTEM_ERROR );
      return( WL_SYSTEM_ERROR );
   }
   DeleteObject( hrgn );
#endif
   return( WL_SUCCESS );

}  /* WLset_clip_box */
 

/*--- WLset_window_bounds-----------------------------------------------*/
 
int WLset_window_bounds(
   WLuint32 lwin_no,
   struct WLbounds *bounds )
 
/*
NAME
   WLset_window_bounds
 
KEYWORD
   WL
 
DESCRIPTION
   This function changes the location and/or size of a window.

SYNOPSIS
   int WLset_window_bounds(
      WLuint32 lwin_no,
      struct WLbounds *bounds )
 
PARAMETERS
   lwin_no (IN) - Logical window number.
   bounds (IN) - Window bounds
 
GLOBALS USED
   not yet
 
RETURN VALUES
   WL_SUCCESS
      Success
 
   WL_BAD_WINDOW_NUMBER
      The logical window number is invalid
 
   WL_BAD_WINDOW_BOUNDS
      The window bounds are invalid or the "bounds" pointer is NULL
 
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

#if defined (X11)
   XSizeHints hints;
   XWindowChanges values;
#endif
 
 
   if ( bounds == NULL )
   {
      WL_REPORT_ERROR( WL_BAD_WINDOW_BOUNDS );
      return( WL_BAD_WINDOW_BOUNDS );
   }
   if ( ( bounds->width < 0 ) || ( bounds->height < 0 ) )
   {
      WL_REPORT_ERROR( WL_BAD_WINDOW_BOUNDS );
      return( WL_BAD_WINDOW_BOUNDS );
   }

   status = WLIwin_retrieve_entry( lwin_no,&win_struct );
   if ( status != WL_SUCCESS )
   {
      WL_REPORT_ERROR( status );
      return( status );
   }
#if defined (X11)
   hints.x = bounds->x;
   hints.y = bounds->y;
   hints.width = bounds->width;
   hints.height = bounds->height;
   hints.flags = USPosition | USSize ;

#  if defined (XGL)
   {

   /*
    *  Reset the VDC_WINDOW and DC_VIEWPORT now.  I don't do this
    *  later because it messes up reference files.  (Mike 5/11/95)
    */

   Xgl_bounds_d3d	xgl_viewport;

   xgl_object_get( win_struct.native_info.xgl_context_3D, 
                   XGL_CTX_VDC_WINDOW, &xgl_viewport );

   xgl_viewport.xmax = bounds->width / 2;
   xgl_viewport.ymax = bounds->height / 2;
   xgl_viewport.xmin = -xgl_viewport.xmax;
   xgl_viewport.ymin = -xgl_viewport.ymax;

   xgl_object_set( win_struct.native_info.xgl_context_3D, 
                   XGL_CTX_VDC_WINDOW, &xgl_viewport,
                   /*XGL_CTX_DC_VIEWPORT, &xgl_viewport,*/
                   0 );

   if ( win_struct.flags & WLI_WIN_SEPARATE_HILITE )
      xgl_object_set( win_struct.native_info.hl_xgl_context_3D, 
                      XGL_CTX_VDC_WINDOW, &xgl_viewport,
                      /*XGL_CTX_DC_VIEWPORT, &xgl_viewport,*/
                      0 );
   }
#  endif
 
   XSetWMNormalHints( win_struct.native_info.EXdisplay,
                               win_struct.hwin_no, &hints );
   if ( win_struct.flags & WLI_WIN_SEPARATE_HILITE )
   {
      hints.x = 0;
      hints.y = 0;
      XSetWMNormalHints( win_struct.native_info.EXdisplay,
                         win_struct.hl_hwin_no, &hints );
   }
 
   values.x = bounds->x;
   values.y = bounds->y;
   values.width = bounds->width;
   values.height = bounds->height;
 
   
   status = XReconfigureWMWindow( win_struct.native_info.EXdisplay,
                                  win_struct.hwin_no,
                                  win_struct.native_info.screen_no,
                                  CWX|CWY|CWWidth|CWHeight,
                                  &values );
   if ( win_struct.flags & WLI_WIN_SEPARATE_HILITE )
   {
      values.x = 0;
      values.y = 0;
      status = XReconfigureWMWindow( win_struct.native_info.EXdisplay,
                                     win_struct.hl_hwin_no,
                                     win_struct.native_info.screen_no,
                                     CWX|CWY|CWWidth|CWHeight,
                                     &values );
   }
   if ( !status )
   {
      WL_REPORT_ERROR( WL_SYSTEM_ERROR );
      return( WL_SYSTEM_ERROR );
   }
 
#elif defined (ENV5)
   if ( win_struct.hwin_no != WLISRwin_no )
   {
      status = Modify_win( win_struct.hwin_no,
                           bounds->x, bounds->y,
                           bounds->x + bounds->width -1, 
                           bounds->y + bounds->height -1 );
      if ( status )
      {
         WL_REPORT_ERROR( WL_SYSTEM_ERROR );
         return( WL_SYSTEM_ERROR );
      }
   }
 
#elif defined (WIN32)
   status = SetWindowPos( win_struct.hwin_no, HWND_TOP, bounds->x, bounds->y,
                          bounds->width, bounds->height, SWP_SHOWWINDOW );
   if ( !status )
   {
      WL_REPORT_ERROR( WL_SYSTEM_ERROR );
      return( WL_SYSTEM_ERROR );
   }
#endif
 
   status = WLIwin_set_bounds( lwin_no );
   if ( status != WL_SUCCESS )
   {
      WL_REPORT_ERROR( status );
      return( status );
   }
   
   return( WL_SUCCESS );
}  /* WLset_window_bounds */


/*--- WLget_window_contexts -----------------------------------------------*/
 
int WLget_window_contexts(
   WLuint32 lwin_no,
   int *num_contexts,
   WLuint32 **context_no,
   struct WLcontext_info **contexts )
 
/*
NAME
   WLget_window_contexts
 
KEYWORD
   WL
 
DESCRIPTION
   This function gets the contexts currently supported for a window.

SYNOPSIS
   int WLget_window_contexts(
      WLuint32 lwin_no,
      int *num_contexts,
      WLuint32 **context_no,
      struct WLcontext_info **contexts )
 
NOTES
   Currently this function retruns only one context
 
PARAMETERS
   lwin_no (IN) - logical window number
   num_contexts (OUT) - number of handles returned
   context_no (OUT) - array of context numbers; The caller is responsible
                    for freeing this array with WLfree().
   contexts (OUT) - array of contexts; The caller is responsible for
                    freeing this array with WLfree().
 
GLOBALS USED
   not yet
 
RETURN VALUES
   WL_SUCCESS
      Success
 
   WL_BAD_WINDOW_NUMBER
      The logical window number is invalid
 
   WL_BAD_PARAMETER
      One of the pointers is NULL
 
RELATED INFORMATION
   Functions: WLcreate_window(), WLadd_context_to_window()
 
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
 
   if ( (!num_contexts) || (!context_no) || (!contexts) )
   {
      WL_REPORT_ERROR( WL_BAD_PARAMETER );
      return( WL_BAD_PARAMETER );
   }

   *context_no = NULL;
   *contexts = NULL;

   *num_contexts = 1;
 
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
 
   *context_no = (WLuint32 *) malloc( sizeof(WLuint32) * (*num_contexts) );
   if ( *context_no == NULL )
   {
      WL_REPORT_ERROR( WL_ERROR );
      return( WL_ERROR );
   }

   (*context_no)[0] = (WLuint32) win_struct.context_no;
   
   *contexts = ( struct WLcontext_info * )malloc(
                        sizeof(struct WLcontext_info) * (*num_contexts) );
   if ( *contexts == NULL )
   {
      WL_REPORT_ERROR( WL_ERROR );
      return( WL_ERROR );
   }

   (*contexts)->base_cmap_type = context_struct.base_cmap_type;
   (*contexts)->base_depth = context_struct.base_depth;
   (*contexts)->hilite_used = context_struct.hilite_used;
   (*contexts)->flags = context_struct.flags;
 
   return( WL_SUCCESS );
}  /* WLget_window_contexts */
 

/*--- WLget_window_bounds -----------------------------------------------*/
 
int WLget_window_bounds(
   WLuint32 lwin_no,
   struct WLbounds *bounds,
   struct WLbounds *area_bounds )
 
/*
NAME
   WLget_window_bounds
 
KEYWORD
   WL
 
DESCRIPTION
   This function gets the location and size of a window.

SYNOPSIS
   int WLget_window_bounds(
      WLuint32 lwin_no,
      struct WLbounds *bounds,
      struct WLbounds *area_bounds )
 
PARAMETERS
   lwin_no (IN) - logical window number
   bounds (OUT) - window bounds including border etc.
   area_bounds (OUT) - window working area bounds
GLOBALS USED
   not yet
 
RETURN VALUES
   WL_SUCCESS
      Success
 
   WL_BAD_WINDOW_NUMBER
      The logical window number is invalid
 
RELATED INFORMATION
   Functions: WLcreate_window(), WLset_window_bounds()
 
HISTORY
   08/28/92 Shridar Subramanian
      Initial definition
 
   10/22/92 Shridar Subramanian
      Initial design
 
*/

{
   int status;
   struct WLIwin win_struct;
 
   status = WLIwin_retrieve_entry( lwin_no, &win_struct );
   if ( status != WL_SUCCESS )
   {
      WL_REPORT_ERROR( status );
      return( status );
   }

   if ( bounds )
   {
      *bounds = win_struct.bounds;
   }
   
   if ( area_bounds )
   {
      *area_bounds = win_struct.area_bounds;
   }

   return( WL_SUCCESS );

}  /* WLget_window_bounds */

/*--- WLget_window_base_context -----------------------------*/

int WLget_window_base_context(
   WLuint32 lwin_no,
   WLuint32 *base_context_no )

/*
NAME
   WLget_window_base_context
 
KEYWORD
   WL
 
DESCRIPTION
   This function gets the base context for a logical
   window.  This is the context associated with the
   base hardware window.

SYNOPSIS
   int WLget_window_base_context(
      WLuint32 lwin_no,
      WLuint32 *base_context_no )

PARAMETERS
   lwin_no (IN) - logical window number
   base_context_no (OUT) - the base context number

GLOBALS USED
   none
 
RETURN VALUES
   WL_SUCCESS
      Success
 
   WL_BAD_WINDOW_NUMBER
      The logical window number is invalid
 
   WL_BAD_PARAMETER
      The 'base_context_no' parameter is NULL
 
HISTORY
   02/05/93 S.P. Rogers
      Initial definition, design and implementation
*/

{
   int status;
   struct WLIwin win_struct;
 
   if ( ! base_context_no )
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
 
   *base_context_no = win_struct.context_no;

   return( WL_SUCCESS );
}  /* WLget_window_base_context */

/*--- WLget_hardware_screen_number -----------------------------*/

int WLget_hardware_screen_number(
   WLhwin_no hwin_no,
   int *screen_no )

/*
NAME
   WLget_hardware_screen_number
 
KEYWORD
   WL
 
DESCRIPTION
   This function gets the hardware screen number of a hardware window

SYNOPSIS
   int WLget_hardware_screen_number(
	WLhwin_no hwin_no,
        int *screen_no )
PARAMETERS
   hwin_no (IN) - hardware window number
   screen_no (OUT) - the hardware screen number

GLOBALS USED
   none
 
RETURN VALUES
   WL_SUCCESS
      Success
 
   WL_BAD_HARDWARE_WINDOW
      The hardware window number is invalid

   WL_BAD_PARAMETER
      The pointer screen_no is NULL
 
HISTORY
   05/13/93 Shridar Subramanian
      Initial definition, design and implementation
*/

{
   int status;
#if defined(X11)
   int i, found;
   struct WLIscreen screen_struct;
   XWindowAttributes window_attributes;
#endif
 
   if ( screen_no == NULL )
   {
      WL_REPORT_ERROR( WL_BAD_PARAMETER );
      return( WL_BAD_PARAMETER );
   }


#if defined( X11 )
   found = WLI_FALSE;
   for( i = 0; ( i < WL_MAX_SCREENS ) && ( !found ); i++ )
   {
      if ( WLIscreen_retrieve_entry( i, &screen_struct ) == WL_SUCCESS )
      {
         found = WLI_TRUE;
      }
   }
   if (!found)
   {
      WL_REPORT_ERROR( WL_SYSTEM_ERROR );
      return( WL_SYSTEM_ERROR );
   }
 
   status = XGetWindowAttributes( screen_struct.native_info.EXdisplay,
            hwin_no, &window_attributes);
   if ( !status )
   {
#elif defined (ENV5 )
 
   status = Inq_win_vs( hwin_no, screen_no );
   if ( status )
   {
 
#endif
      WL_REPORT_ERROR( WL_BAD_HARDWARE_WINDOW );
      return( WL_BAD_HARDWARE_WINDOW );
   }
   else
   {
 
#if defined( X11 )
 
      *screen_no = XScreenNumberOfScreen( window_attributes.screen );
 
#endif
   }
   return( WL_SUCCESS );
}  /* WLget_hardware_screen_number */

/*--- WLwindow_bounds_changed-----------------------------------------------*/
 
int WLwindow_bounds_changed(
   WLuint32 lwin_no,
   struct WLbounds *bounds )
 
/*
NAME
   WLwindow_bounds_changed
 
KEYWORD
   WL
 
DESCRIPTION
   This function changes the size of the separate hilite window, if one exists,
   when the size of the parent window changes.

SYNOPSIS
   int WLwindow_bounds_changed(
      WLuint32 lwin_no,
      struct WLbounds *bounds )
 
PARAMETERS
   lwin_no (IN) - Logical window number.
   bounds (IN) - Window bounds
 
GLOBALS USED
   not yet
 
RETURN VALUES
   WL_SUCCESS
      Success
 
   WL_BAD_WINDOW_NUMBER
      The logical window number is invalid
 
   WL_BAD_WINDOW_BOUNDS
      The window bounds are invalid or the "bounds" pointer is NULL
 
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

#if defined (X11)
   XSizeHints hints;
   XWindowChanges values;
#endif
 
 
   if ( bounds == NULL )
   {
      WL_REPORT_ERROR( WL_BAD_WINDOW_BOUNDS );
      return( WL_BAD_WINDOW_BOUNDS );
   }
   if ( ( bounds->width < 0 ) || ( bounds->height < 0 ) )
   {
      WL_REPORT_ERROR( WL_BAD_WINDOW_BOUNDS );
      return( WL_BAD_WINDOW_BOUNDS );
   }

   status = WLIwin_retrieve_entry( lwin_no, &win_struct );
   if ( status != WL_SUCCESS )
   {
      WL_REPORT_ERROR( status );
      return( status );
   }

   if ( win_struct.flags & WLI_WIN_SEPARATE_HILITE )
   {
#if defined (X11)
      hints.x = 0;
      hints.y = 0;
      hints.width = bounds->width;
      hints.height = bounds->height;
      hints.flags = USPosition | USSize ;
 
      XSetWMNormalHints( win_struct.native_info.EXdisplay,
                         win_struct.hl_hwin_no, &hints );
 
      values.x = 0;
      values.y = 0;
      values.width = bounds->width;
      values.height = bounds->height;
 
   
      status = XReconfigureWMWindow( win_struct.native_info.EXdisplay,
                                     win_struct.hl_hwin_no,
                                     win_struct.native_info.screen_no,
                                     CWX|CWY|CWWidth|CWHeight,
                                     &values );
      if ( !status )
      {
         WL_REPORT_ERROR( WL_SYSTEM_ERROR );
         return( WL_SYSTEM_ERROR );
      }
 
#endif
   } 

   status = WLIwin_set_bounds( lwin_no );
   if ( status != WL_SUCCESS )
   {
      WL_REPORT_ERROR( status );
      return( status );
   }
   
#  if defined (XGL)
   {

   /*
    *  Reset the VDC_WINDOW and DC_VIEWPORT now.  I don't do this
    *  later because it messes up reference files.  (Mike 5/11/95)
    */

   Xgl_bounds_d3d	xgl_viewport;

   xgl_object_get( win_struct.native_info.xgl_context_3D, 
                   XGL_CTX_VDC_WINDOW, &xgl_viewport );

   xgl_viewport.xmax = bounds->width / 2;
   xgl_viewport.ymax = bounds->height / 2;
   xgl_viewport.xmin = -xgl_viewport.xmax;
   xgl_viewport.ymin = -xgl_viewport.ymax;

   xgl_object_set( win_struct.native_info.xgl_context_3D, 
                   XGL_CTX_VDC_WINDOW, &xgl_viewport,
                   /*XGL_CTX_DC_VIEWPORT, &xgl_viewport,*/
                   0 );

   if ( win_struct.flags & WLI_WIN_SEPARATE_HILITE )
      xgl_object_set( win_struct.native_info.hl_xgl_context_3D, 
                      XGL_CTX_VDC_WINDOW, &xgl_viewport,
                      /*XGL_CTX_DC_VIEWPORT, &xgl_viewport,*/
                      0 );
   }
#  endif
 
   return( WL_SUCCESS );
}  /* WLwindow_bounds_changed */

