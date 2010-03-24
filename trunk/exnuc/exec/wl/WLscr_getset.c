#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "wl.h"
#include "wl_internal.h"
 

/*--- WLget_active_screen -----------------------------------------------*/

int WLget_active_screen(
        WLuint16 *lscreen_no,
        int *screen_type )

/*
NAME
   WLget_active_screen
 
KEYWORD
   WL
 
DESCRIPTION
   This function gets the active screen number.

SYNOPSIS
   int WLget_active_screen(
        WLuint16 *lscreen_no )
 
PARAMETERS
   lscreen_no (OUT) - logical screen number.
 
GLOBALS USED
   not yet
 
RETURN VALUES
   WL_SUCCESS
	Success.
 
   WL_BAD_PARAMETER
      The "lscreen_no" pointer is NULL
 
HISTORY
   08/28/92 Shridar Subramanian
      Initial definition
 
   10/22/92 Shridar Subramanian
      Initial design
*/
{

   struct WLIscreen screen_struct; 
   int sts;
#if defined( ENV5 )
   int vs_no;
#endif
   
   if (lscreen_no == NULL)
   {
       WL_REPORT_ERROR( WL_BAD_PARAMETER );
       return( WL_BAD_PARAMETER );
   }

#if defined( ENV5 )
   sts = Inq_displayed_vs( &vs_no );
   if ( sts )
   {
       WL_REPORT_ERROR( WL_SYSTEM_ERROR );
       return( WL_SYSTEM_ERROR );
   }
   sts = WLIscreen_hardware_to_logical( vs_no, lscreen_no );
   if ( sts != WL_SUCCESS )
   {
       WL_REPORT_ERROR( WL_BAD_PARAMETER );
       return( WL_BAD_PARAMETER );
   }
#else

   *lscreen_no = WLIactive_screen;

#endif
   sts = WLIscreen_retrieve_entry( *lscreen_no, &screen_struct );
   if ( sts != WL_SUCCESS )
   {
      WL_REPORT_ERROR( sts );
      return( sts );
   }
   if ( screen_struct.flags & WLI_SCREEN_FLAGS_PRIMARY )
   {
      *screen_type = WL_SCREEN_PRIMARY;
   }
   else
   {
      *screen_type = WL_SCREEN_OTHER;
   }
   return( WL_SUCCESS );
}  /* WLget_active_screen */

 
/*--- WLget_number_of_screens ---------------------------------------------*/
 
int WLget_number_of_screens(
   int *num_screens,
   WLuint16 **list_of_screens )
 
/*
NAME
   WLget_number_of_screens
 
KEYWORD
   WL
 
DESCRIPTION
   This function gets the number of screens supported and also the list of 
   screens.

SYNOPSIS
   int WLget_number_of_screens(
      int *num_screens,
      WLuint16 **list_of_screens )
 
PARAMETERS
   num_screens (OUT) - number of screens
   list_of_screens (OUT) - The list of screens, NULL if not desired. The caller
                           is responsible for freeing the memory.
 
GLOBALS USED
   not yet
 
RETURN VALUES
   WL_SUCCESS
      Success
 
   WL_BAD_PARAMETER
       'num_screens' is NULL.
 
HISTORY
   08/28/92 Shridar Subramanian
      Initial definition
 
   10/22/92 Shridar Subramanian
      Initial design
*/
 
{
   int ii;
   WLuint16 temp_screens[WL_MAX_SCREENS];

   if ( ! num_screens )
   {
      WL_REPORT_ERROR( WL_BAD_PARAMETER );
      return( WL_BAD_PARAMETER );
   }

   if ( list_of_screens )
   {
      *list_of_screens = NULL;
   }

   for ( *num_screens = 0, ii = 0; ii < WL_MAX_SCREENS; ii++ )
   {
      if ( WLIscreen_validate( ii ) == WL_SUCCESS )
      {
         temp_screens[*num_screens] = ii;
         (*num_screens)++;
      }
   }

   if ( (*num_screens) && (list_of_screens) )
   {
      *list_of_screens = ( WLuint16 * ) malloc( sizeof( WLuint16 ) * 
                                                    ( *num_screens ) );
      if ( *list_of_screens )
      {
         memcpy( ( void * ) *list_of_screens, ( void * ) temp_screens, 
                 sizeof( WLuint16 ) * ( *num_screens ) );
      }
      else
      {
         WL_REPORT_ERROR( WL_SYSTEM_ERROR );
         return( WL_SYSTEM_ERROR );
      }

   }
 
   return( WL_SUCCESS );
}  /* WLget_number_of_screens */
 
 
/*--- WLget_logical_screen_from_screen-------------------------------*/
 
int WLget_logical_screen_from_screen(
   int screen_no,
   WLuint16 *lscreen_no)
 
/*
NAME
   WLget_logical_screen_from_screen
 
KEYWORD
   WL
 
DESCRIPTION
   This function gets the logical screen number, given the physical
   screen number

SYNOPSIS
   int WLget_logical_screen_from_screen(
      int screen_no,
      WLuint16 *lscreen_no)
 
PARAMETERS
   screen_no (IN) - physical screen number
   lscreen_no (OUT) - logical screen number
 
GLOBALS USED
   not yet
 
RETURN VALUES
   WL_SUCCESS
      Success
 
   WL_BAD_PHYSICAL_SCREEN
      The physical screen is invalid
 
   WL_BAD_PARAMETER
      The "lscreen_no" pointer is NULL
 
HISTORY
   08/28/92 Shridar Subramanian
      Initial definition
 
   10/22/92 Shridar Subramanian
      Initial design
*/
 
{
   if ( lscreen_no == NULL )
   {
      WL_REPORT_ERROR( WL_BAD_PARAMETER );
      return( WL_BAD_PARAMETER );
   }
 
#if defined( WIN32 )
   *lscreen_no = 0;
#else
   WLIscreen_hardware_to_logical( screen_no, lscreen_no );
#endif

   return( WL_SUCCESS );
}  /* WLget_logical_screen_from_screen */

 
/*--- WLget_screen_depth ---------------------------------------------*/
 
int WLget_screen_depth(
   WLuint16 lscreen_no,
   int hilite_used,
   int *depth )
 
/*
NAME
   WLget_screen_depth
 
KEYWORD
   WL
 
DESCRIPTION
   This function gets the default depth of the screen

SYNOPSIS
   int WLget_screen_depth(
      WLuint16 lscreen_no,
      int hilite_used,
      int *depth )
 
PARAMETERS
   lscreen_no (IN)  -  screen number
   hilite_used (IN) - indicates whether the depth is required with or 
                      without the hilite plane
   depth (OUT) - default depth
 
GLOBALS USED
   not yet

RETURN VALUES
   WL_SUCCESS
      Success
 
   WL_BAD_SCREEN_NUMBER
      The screen numeber is invalid
 
   WL_BAD_PARAMETER
      The "depth" pointer is NULL
 
HISTORY
   08/28/92 Shridar Subramanian
      Initial definition
 
   10/22/92 Shridar Subramanian
      Initial design
*/
{
   int status;
   int hscreen_no;
   struct WLIscreen screen_struct;

#if defined(ENV5)
   struct scr_info scr_info[WL_MAX_SCREENS];
#endif
 
   if ( WLIscreen_validate( lscreen_no ) != WL_SUCCESS )
   {
      WL_REPORT_ERROR( WL_BAD_SCREEN_NUMBER );
      return( WL_BAD_SCREEN_NUMBER );
   }
 
   if ( depth == NULL )
   {
      WL_REPORT_ERROR( WL_BAD_SCREEN_NUMBER );
      return( WL_BAD_SCREEN_NUMBER );
   }
 
   status = WLIscreen_retrieve_hardware_screen( lscreen_no, &hscreen_no );
   if ( status != WL_SUCCESS )
   {
      WL_REPORT_ERROR( status );
      return( status );
   }
 
   status = WLIscreen_retrieve_entry( lscreen_no, &screen_struct );
   if ( status != WL_SUCCESS)
   {
      WL_REPORT_ERROR( status );
      return( status );
   }
 
#if defined (X11)
   *depth = DefaultDepth( screen_struct.native_info.EXdisplay, hscreen_no );
   if ( hilite_used )
   {
      ( *depth )--;
   }
#elif defined (ENV5)
   status = Inq_screen_info( scr_info );
   if ( status )
   {
      WL_REPORT_ERROR( WL_SYSTEM_ERROR );
      return( WL_SYSTEM_ERROR );
   }
 
   if ( ( scr_info[hscreen_no].vsi_num_planes == 9 ) && 
        ( scr_info[hscreen_no].vsi_VLT_size == 256 ) )
   {
      *depth = 8;
   }
   else
   {
      if ( hilite_used )
      {
         *depth = scr_info[hscreen_no].vsi_num_planes - 1;
      }
      else
      {
         *depth = scr_info[hscreen_no].vsi_num_planes ;
      }
   }

#elif defined (WIN32)
   *depth = GetDeviceCaps( screen_struct.native_info.hdc, PLANES ) *
            GetDeviceCaps( screen_struct.native_info.hdc, BITSPIXEL );
#endif
   return( WL_SUCCESS );
}  /* WLget_screen_depth */

 
/*--- WLget_screen_size ---------------------------------------------*/
 
int WLget_screen_size(
   WLuint16 lscreen_no,
   int *width,
   int *height )
 
/*
NAME
   WLget_screen_size
 
KEYWORD
   WL
 
DESCRIPTION
   This function gets the screen size in pixels.

SYNOPSIS
   int WLget_screen_size(
      WLuint16 lscreen_no,
      int *width,
      int *height )
 
PARAMETERS
   lscreen_no (IN) - screen number
   width (OUT) - width of the screen in pixels
   height (OUT) - height of the screen in pixels
 
GLOBALS USED
   not yet
 
RETURN VALUES
   WL_SUCCESS
      Success
 
   WL_BAD_SCREEN_NUMBER
      The screen number is invalid
 
   WL_BAD_PARAMETER
      One of the pointers is NULL
 
HISTORY
   08/28/92 Shridar Subramanian
      Initial definition
 
   10/22/92 Shridar Subramanian
      Initial design
*/
{
   int status;
   int hscreen_no;
   struct WLIscreen screen_struct;

#if defined (ENV5)
   struct scr_info scr_info[WL_MAX_SCREENS];
#endif
 
   if ( WLIscreen_validate (lscreen_no) != WL_SUCCESS )
   {
      WL_REPORT_ERROR( WL_BAD_SCREEN_NUMBER );
      return ( WL_BAD_SCREEN_NUMBER );
   }

   if ( width == NULL )
   {
      WL_REPORT_ERROR( WL_BAD_SCREEN_NUMBER );
      return( WL_BAD_SCREEN_NUMBER );
   }

   if ( height == NULL )
   {
      WL_REPORT_ERROR( WL_BAD_SCREEN_NUMBER );
      return( WL_BAD_SCREEN_NUMBER );
   }
 
   status = WLIscreen_retrieve_hardware_screen( lscreen_no, &hscreen_no );
   if ( status != WL_SUCCESS )
   {
      WL_REPORT_ERROR( status );
      return ( status );
   }
   status = WLIscreen_retrieve_entry( lscreen_no, &screen_struct );
   if ( status != WL_SUCCESS)
   {
      WL_REPORT_ERROR (status);
      return( status );
   }
 
#if defined (X11)
 
   *width = DisplayWidth( screen_struct.native_info.EXdisplay, hscreen_no);
   *height = DisplayHeight( screen_struct.native_info.EXdisplay, hscreen_no);
 
#elif defined (ENV5)
   status = Inq_screen_info( scr_info );
   if ( status )
   {
      WL_REPORT_ERROR( WL_SYSTEM_ERROR );
      return( WL_SYSTEM_ERROR );
   }

   *width = scr_info[hscreen_no].vsi_x;
   *height = scr_info[hscreen_no].vsi_y;

#elif defined (WIN32)
   *width = GetDeviceCaps( screen_struct.native_info.hdc, HORZRES );
   *height = GetDeviceCaps( screen_struct.native_info.hdc, VERTRES );
#endif
 
   return( WL_SUCCESS );
}  /* WLget_screen_size */


/*--- WLget_screen_contexts -----------------------------------------------*/
 
int WLget_screen_contexts(
   WLuint16 lscreen_no,
   int base_cmap_type,
   int hilite_used,
   int *num_contexts,
   struct WLcontext_info **contexts )
 
/*
NAME
   WLget_screen_contexts
 
KEYWORD
   WL
 
DESCRIPTION
   This function gets the contexts supported for a screen that
   match the specified base_cmap_type and hilte_used. If both,
   base_cmap_type and hilite_used are 0, it returns all
   the contexts for the screen.

SYNOPSIS
   int WLget_screen_contexts(
      WLuint16 lscreen_no,
      int base_cmap_type,
      int hilite_used,
      int *num_contexts,
      struct WLcontext_info **contexts )
 
PARAMETERS
   lscreen_no (IN) - logical screen number.
   base_cmap_type (IN) - base cmap type
   hilite_used (IN) - Indicates whether a hilite plane is used
   num_contexts (OUT) - number of contexts returned
   contexts (OUT) - array of contexts. The caller is responsible for
                    freeing this array with WLfree().
 
GLOBALS USED
   not yet
 
RETURN VALUES
   WL_SUCCESS
      Success
 
   WL_BAD_SCREEN_NUMBER
      The logical screen number is invalid
 
   WL_BAD_PARAMETER
      One of the pointers is NULL.
 
   WL_BAD_MODE
      The  base_cmap_type is invalid
 
HISTORY
   08/28/92 Shridar Subramanian
      Initial definition
 
   10/22/92 Shridar Subramanian
      Initial design
*/
{
   int i;
   int j = 0;
   int count = 0;
 
   if ( WLIscreen_validate (lscreen_no) != WL_SUCCESS )
   {
      WL_REPORT_ERROR( WL_BAD_SCREEN_NUMBER );
      return( WL_BAD_SCREEN_NUMBER );
   }
   if ( ( num_contexts == NULL )||( contexts == NULL ) )
   {
      WL_REPORT_ERROR( WL_BAD_PARAMETER );
      return( WL_BAD_PARAMETER );
   }

   /* allocate the space for all the infos that match.     */
   *contexts = (struct WLcontext_info *) malloc( 
               WLIscreens_arr[lscreen_no].num_possible_contexts *
               sizeof( struct WLcontext_info ) );

   if ( ! *contexts )
   {
      WL_REPORT_ERROR( WL_ERROR );
      return( WL_ERROR );
   }

   if ( ( base_cmap_type == 0 ) && ( hilite_used == 0 ) )
   {
      memcpy( (char *) *contexts,
              (char *) WLIscreens_arr[lscreen_no].possible_contexts,
              WLIscreens_arr[lscreen_no].num_possible_contexts *
              sizeof( struct WLcontext_info ) );
      *num_contexts = WLIscreens_arr[lscreen_no].num_possible_contexts;
   }
   else
   {
   /* search thru all the contexts associated for that screen (WLcontext_info) */
 
      for( i = 0; i < WLIscreens_arr[lscreen_no].num_possible_contexts; i++ )
      {
         if (
             ( WLIscreens_arr[lscreen_no].possible_contexts[i].base_cmap_type ==
               base_cmap_type ) &&
             ( WLIscreens_arr[lscreen_no].possible_contexts[i].hilite_used ==
                hilite_used )
           )
         {
            (*contexts)[j] = WLIscreens_arr[lscreen_no].possible_contexts[i];
            j++;
            ++count;
         }
      }

      *num_contexts = count;

   }
 
 
   return( WL_SUCCESS );
}  /* WLget_screen_contexts */

 
/*--- WLget_screen_type -----------------------------------------------*/
 
int WLget_screen_type(
        WLuint16 lscreen_no,
        int *screen_type )
 
/*
NAME
   WLget_screen_type
 
KEYWORD
   WL
 
DESCRIPTION
   This function gets the type of the screen - primary or other. 
 
SYNOPSIS
   int WLget_screen_type(
        WLuint16 lscreen_no,
        int *screen_type )
 
PARAMETERS
   lscreen_no (IN) - logical screen number.
   screen_type (OUT) - screen_type.
 
GLOBALS USED
   not yet
 
RETURN VALUES
   WL_SUCCESS
   Success.
 
   WL_BAD_PARAMETER
      The "lscreen_no" pointer is NULL
 
HISTORY
   08/28/92 Shridar Subramanian

   10/22/92 Shridar Subramanian
      Initial design
   
   03/12/93 Ravi Parthasarathy
      Implementation
*/
{
 
   struct WLIscreen screen_struct;
   int sts;
 
   sts = WLIscreen_retrieve_entry( lscreen_no, &screen_struct );
   if ( sts != WL_SUCCESS )
   {
      WL_REPORT_ERROR( sts );
      return( sts );
   }

   if ( screen_struct.flags & WLI_SCREEN_FLAGS_PRIMARY )
   {
      *screen_type = WL_SCREEN_PRIMARY;
   }
   else
   {
      *screen_type = WL_SCREEN_OTHER;
   }
   return( WL_SUCCESS );
}  /* WLget_screen_type */

/*--- WLget_hardware_screen_from_logical ------------------------------------*/

int WLget_hardware_screen_from_logical(
        WLuint16 lscreen_no,
        int *screen_no )

/*
NAME
   WLget_hardware_screen_from_logical
 
KEYWORD
   WL
 
DESCRIPTION
   This function gets the hardware_screen number given the logical screen 
   number

SYNOPSIS
   int WLget_hardware_screen_from_logical(
        WLuint16 lscreen_no,
        int *screen_no )
 
PARAMETERS
   lscreen_no (IN) - logical screen number.
   screen_no (OUT) - hardware_screen number
 
GLOBALS USED
   not yet
 
RETURN VALUES
   WL_SUCCESS
	Success.
 
   WL_BAD_PARAMETER
      The "screen_no" pointer is NULL
 
HISTORY
   08/28/92 Shridar Subramanian
      Initial definition
 
   10/22/92 Shridar Subramanian
      Initial design
*/
{
   struct WLIscreen screen_struct;
   int sts;
   
   if (screen_no == NULL)
   {
       WL_REPORT_ERROR( WL_BAD_PARAMETER );
       return( WL_BAD_PARAMETER );
   }

   sts = WLIscreen_retrieve_entry( lscreen_no, &screen_struct );
   if ( sts != WL_SUCCESS )
   {
      WL_REPORT_ERROR( sts );
      return( sts );
   }
   *screen_no = screen_struct.native_info.screen_no;
   return( WL_SUCCESS );
}  /* WLget_hardware_screen_from_logical */

 
 
