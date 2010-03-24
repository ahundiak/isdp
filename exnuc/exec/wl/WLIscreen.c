#include <stdio.h>
#include <stdlib.h>
#include "wl.h"
#include "wl_internal.h"
/*
The following internal functions will be used to access the data structures 
associated wil logical screens
	WLIscreen_hardware_to_logical()
	WLIscreen_retrieve_hardware_screen()
	WLIscreen_validate()
	WLIscreen_retrieve_entry()

*/


/*--- WLIscreen_hardware_to_logical--------------------------------------------*/

int WLIscreen_hardware_to_logical(
   int hscreen_no,
   WLuint16 *lscreen_no)
/*
NAME
	WLIscreen_hardware_to_logical
 
KEYWORD
	WL (INTERNAL)
 
DESCRIPTION
	This function returns the logical screen number, given the 
	hardware screen id
 
PARAMETERS
	hscreen_no (IN) - hardware screen number
	lscreen_no (OUT) - logical screen number

GLOBALS USED
        not yet
 
RETURN VALUES
        WL_SUCCESS
                Success

	WL_BAD_PHYSICAL_SCREEN
		The physical screen is invalid
 
HISTORY
        10/19/92 Shridar Subramanian
                Initial definition
*/
{
#if defined( X11 ) || defined( ENV5 )

   int   found, i;

   found = WLI_FALSE;
   for ( i=0; i < WL_MAX_SCREENS && !found; i++)
   {
      if ( WLIscreens_arr[i].used )
      {
         if ( WLIscreens_arr[i].native_info.screen_no == hscreen_no )
         {
            found = WLI_TRUE;
            *lscreen_no = i;
         }
      }
   }

   if ( !found )
   {
      WL_REPORT_ERROR( WL_BAD_PHYSICAL_SCREEN );
      return( WL_BAD_PHYSICAL_SCREEN );
   }


#endif
   return( WL_SUCCESS );

} /* WLIscreen_hardware_to_logical */


/*--- WLIscreen_retrieve_hardware_screen-------------------------------------*/

int WLIscreen_retrieve_hardware_screen(
   WLuint16 lscreen_no,
   int *hscreen_no)
/*
NAME
	WLIscreen_retrieve_hardware_screen
 
KEYWORD
	WL (INTERNAL)
 
DESCRIPTION
	This function returns the hardware screen number, given the 
	logical screen id
 
PARAMETERS
	lscreen_no (IN) - logical screen number
	hscreen_no (OUT) - hardware screen number

GLOBALS USED
        not yet
 
RETURN VALUES
        WL_SUCCESS
                Success

	WL_BAD_SCREEN_NUMBER
		The logical screen number is invalid
 
HISTORY
        10/19/92 Shridar Subramanian
                Initial definition
*/
{
#if defined( X11 ) || defined( ENV5 )

   if ( WLIscreen_validate( lscreen_no ) != WL_SUCCESS )
   {
      WL_REPORT_ERROR( WL_BAD_SCREEN_NUMBER );
      return( WL_BAD_SCREEN_NUMBER );
   }
   *hscreen_no = WLIscreens_arr[lscreen_no].native_info.screen_no;

#endif
   return( WL_SUCCESS );
} /* WLIscreen_retrieve_hardware_screen */

/*--- WLIscreen_validate--------------------------------------------*/

int WLIscreen_validate(
   WLuint16 lscreen_no)
/*
NAME
	WLIscreen_validate
 
KEYWORD
	WL (INTERNAL)
 
DESCRIPTION
	This function validates the logical screen
 
PARAMETERS
	lscreen_no (IN) - logical screen number

GLOBALS USED
        not yet
 
RETURN VALUES
        WL_SUCCESS
                Success
 
HISTORY
        10/19/92 Shridar Subramanian
                Initial definition
*/
{
   if (  lscreen_no >= WL_MAX_SCREENS )
   {
      /* don't report an error here */
      return( WL_ERROR );
   }

   if ( !WLIscreens_arr[lscreen_no].used )
   {
      /* don't report an error here */
      return( WL_ERROR );
   }
   return( WL_SUCCESS );
} /*  WLIscreen_validate */


/*--- WLIscreen_retrieve_entry--------------------------------------------*/

int WLIscreen_retrieve_entry(
   WLuint16 lscreen_no,
   struct WLIscreen *screen_struct)
/*
NAME
	WLIscreen_retrieve_entry
 
KEYWORD
	WL (INTERNAL)
 
DESCRIPTION
	This function returns the native information, number of possible 
	contexts and the used fields associated with a screen
 
PARAMETERS
	lscreen_no (IN) - logical screen number
	screen_struct (OUT) - the screen information to be returned

GLOBALS USED
        not yet
 
RETURN VALUES
        WL_SUCCESS
                Success
	
 	WL_BAD_SCREEN_NUMBER
		Bad logical screen number
	
 
HISTORY
        10/19/92 Shridar Subramanian
                Initial definition
*/
{
   int   sts;

   sts = WLIscreen_validate( lscreen_no );
   if ( sts != WL_SUCCESS)
   {
      WL_REPORT_ERROR( sts );
      return( sts );
   }

   /* Structure assignments and not just pointer assignments */
   screen_struct->native_info = WLIscreens_arr[lscreen_no].native_info;
 
   screen_struct->used = WLIscreens_arr[lscreen_no].used;
   screen_struct->num_possible_contexts = 
                              WLIscreens_arr[lscreen_no].num_possible_contexts;
   screen_struct->flags = WLIscreens_arr[lscreen_no].flags;
   screen_struct->db_count = WLIscreens_arr[lscreen_no].db_count;

   /* don't copy these fields */
   screen_struct->pwin = NULL;
   screen_struct->pcontext = NULL;
   screen_struct->possible_contexts = NULL;

   return( WL_SUCCESS );
} /* WLIscreen_retrieve_entry */

/*--- WLIscreen_set_flags--------------------------------------------*/

int WLIscreen_set_flags(
   WLuint16 lscreen_no,
   int  flags )
/*
NAME
	WLIscreen_set_flags
 
KEYWORD
	WL (INTERNAL)
 
DESCRIPTION
	This function sets the flags field in the screen structure
 
PARAMETERS
	lscreen_no (IN) - logical screen number
	flags (OUT) - the flags to be set

GLOBALS USED
        not yet
 
RETURN VALUES
        WL_SUCCESS
                Success
	
 	WL_BAD_SCREEN_NUMBER
		Bad logical screen number
	
HISTORY
        10/19/92 Shridar Subramanian
                Initial definition
*/
{
   int   sts;

   sts = WLIscreen_validate( lscreen_no );
   if ( sts != WL_SUCCESS)
   {
      WL_REPORT_ERROR( sts );
      return( sts );
   }
   WLIscreens_arr[lscreen_no].flags = flags;

   return( WL_SUCCESS );
} /*  WLIscreen_set_flags */



/*--- WLIscreen_set_vlt--------------------------------------------*/

int WLIscreen_set_vlt(
   WLuint16 lscreen_no,
   int  vlt_no )
/*
NAME
	WLIscreen_set_vlt
 
KEYWORD
	WL (INTERNAL)
 
DESCRIPTION
	This function sets the vlt field in the screen structure only in ENV5
 
PARAMETERS
	lscreen_no (IN) - logical screen number
	vlt_no (OUT) - the vlt_no to be set

GLOBALS USED
        not yet
 
RETURN VALUES
        WL_SUCCESS
                Success
	
 	WL_BAD_SCREEN_NUMBER
		Bad logical screen number
	
HISTORY
        10/19/92 Shridar Subramanian
                Initial definition
*/
{
   int   sts;

   sts = WLIscreen_validate( lscreen_no );
   if ( sts != WL_SUCCESS)
   {
      WL_REPORT_ERROR( sts );
      return( sts );
   }
   
   /* The vlt is set so that we can use Loadvlt instead of Load_allocated_vlt */
   /* if the vlt_no of the window is same as stored in the screen structure   */
   /* The vlt_no stored in the screen structure is the default vlt,           */
   /* in the Edge2                                                            */

#if defined( ENV5 )
   WLIscreens_arr[lscreen_no].native_info.vlt_no = vlt_no;
#endif

   return( WL_SUCCESS );
} /*  WLIscreen_set_vlt */


/*--- WLIscreen_set_db_count--------------------------------------------*/

int WLIscreen_set_db_count(
   WLuint16 lscreen_no,
   int  db_count )
/*
NAME
	WLIscreen_set_db_count
 
KEYWORD
	WL (INTERNAL)
 
DESCRIPTION
	This function sets the db_count field in the screen structure
 
PARAMETERS
	lscreen_no (IN) - logical screen number
	db_count (OUT) - the db_count to be set

GLOBALS USED
        not yet
 
RETURN VALUES
        WL_SUCCESS
                Success
	
 	WL_BAD_SCREEN_NUMBER
		Bad logical screen number
	
HISTORY
        10/19/92 Shridar Subramanian
                Initial definition
*/
{
   int   sts;

   sts = WLIscreen_validate( lscreen_no );
   if ( sts != WL_SUCCESS)
   {
      WL_REPORT_ERROR( sts );
      return( sts );
   }
   WLIscreens_arr[lscreen_no].db_count = db_count;

   return( WL_SUCCESS );
} /*  WLIscreen_set_db_count */

