#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include "wl.h"
#include "wl_internal.h"

static struct WLIwin *WLIwin_struct = NULL;
static struct WLIcontext *WLIcontext_struct = NULL;

/* Initialize to a number that's out of range */
static WLuint32 WLIold_lwin_no = WL_UNDEFINED_WINDOW;
static WLuint32 WLIold_context_no = WL_DEFAULT_CONTEXT;

/*--- WLIestablish_lwin_and_context --------------------------------------*/

int WLIestablish_lwin_and_context(
   WLuint32 *lwin_no,
   WLuint32 *context_no,
   struct WLIwin **win_struct,
   struct WLIcontext **context_struct )

/*
NAME
	WLIestablish_lwin_and_context

KEYWORD
	WL

DESCRIPTION
	Thie function establishes that the logical window and the specified
	context (if WL_DEFAULT_CONTEXT, the context stored in the window
	structure becomse the "current" context) are valid and that the
	correspond.  It passes back pointers to the "current" window and
	context structures.

SYNOPSIS
	int WLIestablish_lwin_and_context(
	   WLuint32 *lwin_no,
	   WLuint32 *context_no,
	   struct WLIwin **win_struct,
	   struct WLIcontext **context_struct )

PARAMETERS
	lwin_no (IN) - Pointer to proposed logical window number
	context_no (IN) - Pointer to proposed context number
        win_struct (OUT) - Pointer to the established window structure 
        context_struct (OUT) - Pointer to the established context structure 

GLOBALS USED
	WLIold_lwin_no - Keeps the current logical window so
           that we don't have to retrieve the structure everytime.
	WLIwin_struct - a pointer to the window structure associated with
	   WLIold_lwin_no
	WLIold_context_no - Keeps the current logical window so that we
           don't have to retrieve the structure everytime.
	WLIcontext_struct - a pointer to the context structure associated with
	   WLIold_context_no

RETURN VALUES
	WL_SUCCESS
		Success

	WL_BAD_WINDOW_NUMBER
		The logical window number is invalid

	WL_BAD_CONTEXT
		The context number is invalid

HISTORY
	11/05/92 Design and implementation. -Trevor Mink
*/
{
   WLuint32 save_lwin_no;
   int sts;

   save_lwin_no = WL_UNDEFINED_WINDOW;
   *win_struct = NULL;
   *context_struct = NULL;

   /* requested window doesn't match last one => update window structure pointer */
   if ( *lwin_no != WLIold_lwin_no )
   {
      save_lwin_no = WLIold_lwin_no;
      sts = WLIwin_retrieve_entry_ptr( *lwin_no, &WLIwin_struct );
      if ( sts != WL_SUCCESS )
      {
         WL_REPORT_ERROR( sts );
         return ( sts );
      }
      WLIold_lwin_no = *lwin_no;
   }

   /* If no context is specified, use the one associated with the window */
   if ( *context_no == WL_DEFAULT_CONTEXT )
   {
      *context_no = WLIwin_struct->context_no;
   }

   /* Verify supplied context number against context number in window */
   /* structure                                                       */
   if ( *context_no != WLIwin_struct->context_no )
   {
      /* If context doesn't match, restore previous window */
      WLIold_lwin_no = save_lwin_no;
      WLIwin_retrieve_entry_ptr( WLIold_lwin_no, &WLIwin_struct );

      WL_REPORT_ERROR( WL_BAD_CONTEXT );
      return( WL_BAD_CONTEXT );
   }

   if ( *context_no != WLIold_context_no )
   {
      sts = WLIcontext_retrieve_entry_ptr( *context_no, &WLIcontext_struct );
      if ( sts != WL_SUCCESS )
      {
         WL_REPORT_ERROR( sts );
         return ( sts );
      }
      WLIold_context_no = *context_no;
   }

   *win_struct = WLIwin_struct;
   *context_struct = WLIcontext_struct;

   return ( WL_SUCCESS );

} /* WLIestablish_lwin_and_context */

/*--- WLIunestablish_lwin ----------------------------------------------------*/

int WLIunestablish_lwin(
   void )

/*
NAME
	WLIunestablish_lwin

KEYWORD
	WL

DESCRIPTION
	This function sets the last logical window used indicator to undefined
	so that the next call to WLIestablish_lwin_and_context() will
	update the window and context structures.

SYNOPSIS
	int WLIunestablish_lwin(
	   void )

PARAMETERS
	none

GLOBALS USED
	WLIold_lwin_no
		Indicates the last logical window used

RETURN VALUES
	WL_SUCCESS
		Function was successful.

HISTORY
	12/14/92 Created. -Trevor Mink
*/
{
   WLIold_lwin_no = WL_UNDEFINED_WINDOW;
   return( WL_SUCCESS );
} /* WLIunestablish_lwin */


/*---WLIstyle_get_entry-----------------------------------------*/

int WLIstyle_get_entry(
   int lstyle_no,
   struct WLIstyle_struct *entry )

/*
NAME
	WLIstyle_get_entry
 
KEYWORD
	WL (INTERNAL)
 
DESCRIPTION
	This function gets the internal style entry structure for a
	logical style.

SYNOPSIS
	int WLIstyle_get_entry(
	   int lstyle_no,
	   struct WLIstyle_struct *entry )

PARAMETERS
	lstyle_no (IN) - The logical style number
	entry (OUT) - The internal style entry structure

GLOBALS USED
	WLIline_style
 
RETURN VALUES
	WL_SUCCESS
		Success

	WL_BAD_STYLE_NUMBER
		The logical style number is < 0 or > WL_MAX_STYLES

HISTORY
	10/29/92 S.P.Rogers
		Initial definition
*/

{
   if ( (lstyle_no) < 0 || (lstyle_no > WL_MAX_STYLES) )
   {
      WL_REPORT_ERROR( WL_BAD_STYLE_NUMBER );
      return( WL_BAD_STYLE_NUMBER );
   }

   *entry = WLIline_style[lstyle_no];

   return( WL_SUCCESS );
} /*  WLIstyle_get_entry */


/*---WLIactivate_symbology-----------------------------------------*/

/*ARGSUSED*/
int WLIactivate_symbology(
   struct WLIwin *win_struct,
   struct WLIcontext *context_struct,
   int fill_flag )

/*
NAME
	WLIactivate_symbology
 
KEYWORD
	WL (INTERNAL)
 
DESCRIPTION
	This function activates the current active symbology in the
	native windowing system.  All drawing routines show call this
	function prior to drawing to make sure that the active symbology
	is up to date.

SYNOPSIS
	int WLIactivate_symbology(
           struct WLIwin *win_struct,
           struct WLIcontext *context_struct,
	   int fill_flag )

PARAMETERS
	win_struct (IN) - The window structure for the window
	context_struct (IN) - The context structure for the window's context
        fill_flag (IN) - TRUE, if the drawing routine is going to fill
 
RETURN VALUES
	WL_SUCCESS
		Success

HISTORY
	10/29/92 S.P.Rogers
		Initial definition
        03/31/93 S.P. Rogers
                Added the 'else-if' close in the color setting section
                to handle the case where dynamics is on and a hilite
                plane is being used.  This was needed because the
                dynamics drawing mode controls the color instead of
                the base and hilite drawing modes.
        07/06/93 Shridar Subramanian
                Added function pointers
*/

{

   int    sts;
   WLuint32 new_flags;
   struct WLIstyle_struct style_entry;

   sts = WLIstyle_get_entry( win_struct->active_style, &style_entry );
   if ( sts != WL_SUCCESS )
   {
      WL_REPORT_ERROR( sts );
      return( sts );
   }

   if ( ( win_struct->flags & WLI_WIN_FLAGS_COLOR_CHANGED ) ||
        ( win_struct->flags & WLI_WIN_FLAGS_WEIGHT_CHANGED ) ||
        ( win_struct->flags & WLI_WIN_FLAGS_STYLE_CHANGED ) ||
        ( win_struct->flags & WLI_WIN_FLAGS_B_PATTERN_CHANGED ) ||
        ( win_struct->style_change_count != style_entry.change_count ) )
   {

      (*(win_struct->activate_symbology))( win_struct, context_struct, 
                                           &style_entry, fill_flag );
     
      /* reset data in window to indicate symbology is in sync */
      sts = WLIwin_set_style_change_count( win_struct->lwin_no, style_entry.change_count );
      if ( sts != WL_SUCCESS )
      {
         WL_REPORT_ERROR( sts );
         return( sts );
      }

      new_flags = win_struct->flags &
                    ~( WLI_WIN_FLAGS_COLOR_CHANGED |
                       WLI_WIN_FLAGS_WEIGHT_CHANGED |
                       WLI_WIN_FLAGS_STYLE_CHANGED |
                       WLI_WIN_FLAGS_B_PATTERN_CHANGED );

      /* If we didn't fill, we set the blend pattern to solid.  So we */
      /* must set the blend pattern changed flag if the active blend  */
      /* pattern is not solid.                                        */
      if ( !(fill_flag) && !(win_struct->flags & WLI_WIN_FLAGS_B_PATTERN_SOLID) )
      {
         new_flags |= WLI_WIN_FLAGS_B_PATTERN_CHANGED;
      }

      sts = WLIwin_set_flags( win_struct->lwin_no, new_flags );
      if ( sts != WL_SUCCESS )
      {
         WL_REPORT_ERROR( sts );
         return( sts );
      }
   }

   return( WL_SUCCESS );

} /*  WLIactivate_symbology */

/*--- WLIevent_translate ------------------------------------------------------*/

int WLIevent_translate(
   int event_mask,
   int *win_mask)
/*
NAME
	WLIevent_translate
 
KEYWORD
	WL (INTERNAL)
 
DESCRIPTION
	This function translates a WL event mask to a windowing system
	mask
 
SYNOPSIS
	int WLIevent_translate(
	   int event_mask,
	   int *win_mask)

PARAMETERS
	event_mask (IN) - the event mask
	win_mask (OUT) - The windowing system mask

GLOBALS USED
        not yet

RETURN VALUES
        WL_SUCCESS
                Success

HISTORY
        10/30/92 Shridar Subramanian
                Initial definition
*/
{
#if defined( X11 )

/* Translate each WL event into a X event */

   *win_mask = 0;
   if ( event_mask & WL_BUTTON )
   {
      *win_mask |= (ButtonPressMask | ButtonReleaseMask );
   }
   if ( event_mask & WL_KEY )
   {
      *win_mask |= (KeyPressMask | KeyReleaseMask );
   }
   if ( ( event_mask & WL_REFRESH ) || ( event_mask & WL_DELETE ) ||
        ( event_mask & WL_COLLAPSE ) )
   {
      *win_mask |= (StructureNotifyMask | SubstructureNotifyMask );
   }
   if ( event_mask & WL_EXPOSE )
   {
      *win_mask |= ExposureMask;
   }
   if ( event_mask & WL_ENTER_LEAVE_WIN )
   {
      *win_mask |= ( EnterWindowMask | LeaveWindowMask | FocusChangeMask );
   }
   if ( event_mask & WL_POINTER_MOTION )
   {
      *win_mask |= ( PointerMotionMask | PointerMotionHintMask );
   }
   if ( event_mask & WL_VISIBILITY )
   {
      *win_mask |=  VisibilityChangeMask;
   }
   if ( event_mask & WL_COLORMAP_NOTIFY )
   {
      *win_mask |=  ColormapChangeMask;
   }

#elif defined( ENV5 )
   *win_mask = 0;
   if ( event_mask & WL_BUTTON )
   {
      *win_mask |= BUTTON_EVENT;
   }
   if ( event_mask & WL_KEY )
   {
      *win_mask |= ( KEYBOARD_EVENT | KEYIN_EVENT );
   }
   if  ( event_mask & WL_REFRESH )
   {
      *win_mask |= REFRESH_EVENT;
   }
   if  ( event_mask & WL_DELETE )
   {
      *win_mask |= DELETE_EVENT;
   }
   if  ( event_mask & WL_COLLAPSE )
   {
      *win_mask |= ( COLLAPSE_EVENT | WINDOW_ICON_EVENT );
   }
   if ( event_mask & WL_EXPOSE )
   {
      *win_mask |= REFRESH_EVENT;
   }
   if ( event_mask & WL_POINTER_MOTION )
   {
      *win_mask |= MOTION_EVENT;
   }
   if ( event_mask & WL_VISIBILITY )
   {
      *win_mask |=  COVER_EVENT;
   }
   if ( event_mask & WL_USER )
   {
      *win_mask |=  USER_EVENT;
   }
   if ( event_mask & WL_SWAP_SCREEN )
   {
      *win_mask |=  SWAPVS_EVENT;
   }
   if ( event_mask & WL_TIMER )
   {
      *win_mask |=  TIMER_EVENT;
   }
#elif defined( WIN32 )
   *win_mask = 0;
#else
#error "A windowing system must be defined"
#endif
	
   return( WL_SUCCESS );
} /*  WLIevent_translate */


/*--- WLIslot_validate ------------------------------------------------------*/

int WLIslot_validate(
   struct WLcmap_entry *cmap_entries,
   int num_entries,
   WLuint32 context_no)
/*
NAME
	WLIslot_validate
 
KEYWORD
	WL (INTERNAL)
 
DESCRIPTION
	This validates the slots in the WLcmap_entry structure
 
SYNOPSIS
	int WLIslot_validate(
	   struct WLcmap_entry *cmap_entries,
	   int num_entries,
	   WLuint32 context_no)

PARAMETERS
	cmap_entries (IN) - Colormap entries
	num_entries (IN) - The number of entries
	context_no (IN) - The context number
 
GLOBALS USED
        not yet
 
RETURN VALUES
        WL_SUCCESS
                Success

	WL_BAD_SLOT_NUMBER
		One of the slot numbers is invalid

HISTORY
        10/30/92 Shridar Subramanian
                Initial definition
*/
{
   int        sts, i;
   WLuint16   max_entries;
   struct WLIcontext   context_struct;

   sts = WLIcontext_retrieve_entry( context_no, &context_struct );
   if ( sts != WL_SUCCESS )
   {
      WL_REPORT_ERROR( sts );
      return( sts );
   }

   if ( context_struct.base_cmap_type == WL_CMAP_TRUE_COLOR )
   {
      max_entries = 1 << ( (context_struct.base_depth/3) +
                    context_struct.hilite_used );
   }
   else
   {
      max_entries = 1 << ( context_struct.base_depth +
                    context_struct.hilite_used );
   }
 

   for ( i = 0; i < num_entries; i++ )
   {
      if ( cmap_entries[i].slot > max_entries )
      {
         WL_REPORT_ERROR( WL_BAD_SLOT_NUMBER );
         return( WL_BAD_SLOT_NUMBER );
      }
   }
      
   return( WL_SUCCESS );
} /* WLIslot_validate */


/*--- WLIstyle_convert_to_dashes ---------------------------------------------*/

int WLIstyle_convert_to_dashes(
   short pattern,
   int *n,
   int *offset,
   WLdash_type *points)
/*
NAME
	WLIstyle_convert_to_dashes

KEYWORD
	WL (INTERNAL)

DESCRIPTION
	This function converts a bit pattern of length WLI_PATTERN_LENGTH into
	the "Dashes" pattern required by X Windows.

SYNOPSIS
	int WLIstyle_convert_to_dashes(
	   short pattern,
	   int *n,
	   int *offset,
	   WLdash_type *points)

PARAMETERS
	pattern (IN) - bit pattern to convert
	*n (OUT) - ?
	*offset (OUT) - ?
	*points (OUT) - On/off pattern for X Windows

GLOBALS USED
        not yet

RETURN VALUES
        WL_SUCCESS
		Successfully completed the function.

HISTORY
        10/30/92 Shridar Subramanian
                Initial definition
*/
{
   int i, res;
   unsigned short mask;
   int count, num_of_1, num_of_0, start;

   mask = 32768;
   count = num_of_0 = num_of_1  = 0;
   start = 0;

   res = mask & pattern;
   while ( (!res) && (mask) )
   {
      mask = mask >> 1;
      res = mask & pattern;
      start++;
   }

   for ( i = start; i < 16; i++ )
   {
      res = mask & pattern;
      if ( res )
      {
         if ( num_of_0 )
         {
            points[count] = num_of_0;
            num_of_0 = 0;
            count++;
	 }
	 num_of_1++;
      }
      else
      {
         if ( num_of_1 )
         {
            points[count] = num_of_1;
            num_of_1 = 0;
            count++;
         }
         num_of_0++;
      }
      mask = mask >> 1;
   }
   if ( num_of_1 )
   {
      points[count] = num_of_1;
      num_of_1 = 0;
      count++;
   }

   /* Add zeros that were skipped at the front to the end */
   num_of_0 += start;

   if ( num_of_0 )
   {
      points[count] = num_of_0;
      num_of_0 = 0;
      count++;
   }

   *n = count;
   if ( start )
   {
      /* If zeros skipped at beginning, they are the start point */
      *offset = WLI_PATTERN_LENGTH - start;
   }
   else
   {
      *offset = 0;
   }
   
   if( WLIline_style_factor == WLI_TRUE )
   {
      for( i=0; i< count; i++ )
      {
         points[i] = 2 * points[i] ;
      }
   }

   return( WL_SUCCESS );

} /* WLIstyle_convert_to_dashes */



/*--- WLIconvert_dashes_with_blend ---------------------------------------------*/

int WLIconvert_dashes_with_blend(
   int old_nitems,
   int old_offset,
   WLdash_type *old_dash_list,
   int *new_nitems,
   WLdash_type *new_dash_list )
/*
NAME
	WLIconvert_dashes_with_blend

KEYWORD
	WL (INTERNAL)

DESCRIPTION
	This function a dash list to a new dash list that takes into account
        a blend style 0xaaaa. This is mainly used for half hilight 

SYNOPSIS
	int WLIconvert_dashes_with_blend(
      	   int old_nitems,
   	   int old_offset,
   	   WLdash_type *old_dash_list,
   	   int *new_nitems,
   	   WLdash_type *new_dash_list )

PARAMETERS
	old_nitems (IN) - The old number of items in the dash list
        old_offset (IN) - The old offset
        old_dash_list (IN) - The old dash  list
        new_nitems (OUT) - The number of items in the new dash list
        new_dash_list  (OUT) - The new dash list

GLOBALS USED
        not yet

RETURN VALUES
        WL_SUCCESS
		Successfully completed the function.

HISTORY
        05/11/93 Shridar Subramanian
                Initial definition

*/

{
   int i,j,temp_count,value;
 
   /* if offset is 1 => list of old_dash_list starts with gap */
   /* gaps are left as they are. Only dashes are reset        */
   /* to alternate */
 
   if ( old_offset ==1 )
   {
      new_dash_list[0] = old_dash_list[0];
      i = 1;
      temp_count =1;
   }
   else
   {
      temp_count=0;
      i = 0;
   }
 
   while ( i < old_nitems  )
   {
      value = old_dash_list[i];
      if ( value % 2 )
      {
          for  ( j = 0; j < value; j++ )
          {
             new_dash_list[temp_count] = 1;
             temp_count++;
          }
          if ( i+1 < old_nitems)
          {
             new_dash_list[temp_count] = old_dash_list[i+1]; /* Gaps */
             temp_count++;
          }
      }
      else
      {
         for  ( j = 0; j < ( value -1 ); j++ )
         {
            new_dash_list[temp_count] = 1;
            temp_count++;
         }
 
         if ( ( i+1 ) < old_nitems)
         {
            new_dash_list[temp_count] = old_dash_list[i+1] + 1; /* Gaps */
            temp_count++;
         }
         else
         {
            new_dash_list[temp_count] = 1;
            temp_count++;
         }
 
      }
      i = i + 2;
   }
   *new_nitems = temp_count;

   return( WL_SUCCESS );
} /* WLIconvert_dashes_with_blend  */

