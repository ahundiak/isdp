#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "wl.h"
#include "wl_internal.h"

extern int WLIset_window_functions();
 
/*--- WLIwin_add_entry--------------------------------------------*/

int WLIwin_add_entry(
   WLuint32 context_no,      
   struct WLnative_info *native_info,
   WLhwin_no hwin_no,
   WLuint32 *lwin_no,
   WLuint32 created_flag)  

/*
NAME
	WLIwin_add_entry
 
KEYWORD
	WL (INTERNAL)
 
DESCRIPTION
	This function adds an entry and initializes all the vcalues
 
SYNOPSIS
	int WLIwin_add_entry(
	   WLuint32 context_no,      
	   struct WLnative_info *native_info,
	   WLhwin_no hwin_no,
	   WLuint32 *lwin_no,
	   WLuint32 created_flag)  

PARAMETERS
	context_no (IN) - context number
	native_info (IN) - The native information
	hwin_no (IN) - Hardware window number
	lwin_no (OUT) - logical window number
 
GLOBALS USED
        not yet
 
RETURN VALUES
        WL_SUCCESS
                Success
 
        WL_ERROR
                Failed to add entry 

HISTORY
        10/19/92 Shridar Subramanian
                Initial definition
*/
{
   int sts;
   WLuint16 lscreen_no;
   WLuint8 context_group;
   WLuint8 context_offset;
   WLuint8 group_index;
   WLuint8 offset;
   int found,i,j;
   struct WLIwin_group *pwin_arr;
   struct WLIwin *temp_ptr;
#if defined( X11 )
   GC gc;
   XWindowAttributes win_attr;
   Pixmap  pmap;
   char null_data[4] = { 0, 0, 0, 0 };
   XColor null_color;
#endif

   temp_ptr = 0;
   group_index = offset = 0;
   WLIcontext_unpack( context_no, &lscreen_no, &context_group,&context_offset );

   /*  Find an empty entry to insert the window structure                   */

   pwin_arr = WLIscreens_arr[lscreen_no].pwin;
   found = WLI_FALSE;
   for ( i=0; i < WLI_MAX_WIN_GROUPS && !found; i++ )
   {
      if ( pwin_arr[i].num_entries_used < WLI_MAX_WINDOWS_PER_GROUP &&
           pwin_arr[i].pwin_group != NULL )
      {
         temp_ptr = pwin_arr[i].pwin_group;
         group_index = i;
         found = WLI_TRUE;
      }
   }

   /* If an empty entry is not found allocate an entry                      */

   if ( !found )
   {
       for ( i=0; i < WLI_MAX_WIN_GROUPS && !found; i++)
       {       
           if ( !pwin_arr[i].pwin_group )
           {               
               /* Allocate entry and initialize the values                  */

               pwin_arr[i].pwin_group = 
                         (struct WLIwin *) malloc( WLI_MAX_WINDOWS_PER_GROUP * 
                                                   sizeof( struct WLIwin ) );
               pwin_arr[i].num_entries_used = 0;
               for ( j=0; j < WLI_MAX_WINDOWS_PER_GROUP; j++)
               {
                   pwin_arr[i].pwin_group[j].used = WLI_FALSE;
               }
               temp_ptr = pwin_arr[i].pwin_group;
               group_index = i;     
               found = WLI_TRUE;   
           }       
       }
   }

   if ( !found )
   {
      WL_REPORT_ERROR( WL_ERROR );
      return( WL_ERROR );
   }

   found = WLI_FALSE;

   for ( i=0; i < WLI_MAX_WINDOWS_PER_GROUP && !found; i++)
   {
       if ( temp_ptr[i].used == WLI_FALSE )
       {
           offset = i;
           found = WLI_TRUE;
       }
   }
   
 
   if ( !found )
   {
      WL_REPORT_ERROR( WL_ERROR );
      return( WL_ERROR );
   }

   pwin_arr[group_index].num_entries_used++;

   /* Initialize the window structure values                                */

   temp_ptr[offset].used = WLI_TRUE;
   temp_ptr[offset].lscreen_no = lscreen_no;

   if ( native_info )
   {
#if defined( X11 )

      temp_ptr[offset].native_info.EXdisplay = native_info->display;
      XGetWindowAttributes( native_info->display, native_info->base_win,
                            &win_attr );
      temp_ptr[offset].native_info.depth = win_attr.depth;
      temp_ptr[offset].native_info.EXgc = native_info->gc;
      temp_ptr[offset].native_info.screen_no = native_info->screen;
      temp_ptr[offset].native_info.cursor = native_info->cursor;
      temp_ptr[offset].hwin_no = native_info->base_win;

      if ( WLIscreens_arr[lscreen_no].native_info.null_cursor == None )
      {
         pmap = XCreateBitmapFromData( native_info->display, 
                                       native_info->base_win, null_data, 2, 2 );

         null_color.red = null_color.blue = null_color.green = 0;
         WLIscreens_arr[lscreen_no].native_info.null_cursor = 
                 XCreatePixmapCursor( native_info->display, pmap, pmap, 
                                      &null_color, &null_color, 1, 1 );
         
      }
      temp_ptr[offset].native_info.null_cursor = 
                          WLIscreens_arr[lscreen_no].native_info.null_cursor;
      

      /* Explicit hilight window  */

      temp_ptr[offset].hl_hwin_no = native_info->hl_win;
      temp_ptr[offset].hl_native_info.hl_gc = native_info->hl_gc;
      temp_ptr[offset].hl_native_info.hl_colormap = native_info->hl_colormap;
      temp_ptr[offset].hl_native_info.hl_visual = native_info->hl_visual;

#if defined( OPENGL )
      temp_ptr[offset].native_info.glx_context = native_info->glx_context;
      temp_ptr[offset].native_info.hl_glx_context = native_info->hl_glx_context;
      temp_ptr[offset].native_info.base_in_2d = 0;
      temp_ptr[offset].native_info.hilite_in_2d = 0;
#endif
#if defined( XGL )
      temp_ptr[offset].native_info.xgl_color_type = native_info->xgl_color_type;
      temp_ptr[offset].native_info.xgl_hlhsr_mode = native_info->xgl_hlhsr_mode;
      temp_ptr[offset].native_info.xgl_context_3D = native_info->xgl_context_3D;
      temp_ptr[offset].native_info.hl_xgl_context_3D = 
                                                 native_info->hl_xgl_context_3D;
      temp_ptr[offset].native_info.win_ras = native_info->win_ras;
      temp_ptr[offset].native_info.hl_win_ras = native_info->hl_win_ras;
      temp_ptr[offset].native_info.mem_ras = native_info->mem_ras;
      temp_ptr[offset].native_info.hl_mem_ras = native_info->hl_mem_ras;

      if( native_info->xgl_context_3D )
         {
         xgl_object_get( native_info->xgl_context_3D, 
                         XGL_CTX_GLOBAL_MODEL_TRANS, 
                         &temp_ptr[offset].native_info.global_model_trans );
         xgl_object_get( native_info->xgl_context_3D, 
                         XGL_CTX_LOCAL_MODEL_TRANS, 
                         &temp_ptr[offset].native_info.local_model_trans );
         xgl_object_get( native_info->xgl_context_3D, 
                         XGL_CTX_VIEW_TRANS, 
                         &temp_ptr[offset].native_info.view_trans );
         }

      if ( native_info->hl_xgl_context_3D )
         {
         xgl_object_get( native_info->hl_xgl_context_3D, 
                         XGL_CTX_GLOBAL_MODEL_TRANS, 
                         &temp_ptr[offset].native_info.hl_global_model_trans );
         xgl_object_get( native_info->hl_xgl_context_3D, 
                         XGL_CTX_LOCAL_MODEL_TRANS, 
                         &temp_ptr[offset].native_info.hl_local_model_trans );
         xgl_object_get( native_info->hl_xgl_context_3D, 
                         XGL_CTX_VIEW_TRANS, 
                         &temp_ptr[offset].native_info.hl_view_trans );
         }

      temp_ptr[offset].native_info.base_in_2d = 0;
      temp_ptr[offset].native_info.hilite_in_2d = 0;
#endif

#elif defined( ENV5 )

      temp_ptr[offset].native_info.screen_no = native_info->vs_no;
      temp_ptr[offset].hwin_no = native_info->base_win;
      temp_ptr[offset].native_info.env5_vsi_flags = 
                       WLIscreens_arr[lscreen_no].native_info.env5_vsi_flags;

#elif defined( WIN32 )

      temp_ptr[offset].native_info.hdc = native_info->hdc;
      temp_ptr[offset].native_info.cursor = native_info->cursor;
      temp_ptr[offset].hwin_no = native_info->base_win;
      temp_ptr[offset].native_info.class = native_info->class;
      temp_ptr[offset].native_info.hinstance = native_info->hinstance;
      temp_ptr[offset].native_info.wnd_proc = native_info->wnd_proc;

#else
#error "A windowing system must be defined "
#endif

      temp_ptr[offset].created = WLI_FALSE;
   }
   else
   {
      /* Fill in the native windowing information */
#if defined( X11 )

      temp_ptr[offset].native_info.EXdisplay = 
                              WLIscreens_arr[lscreen_no].native_info.EXdisplay;
      gc = XCreateGC( temp_ptr[offset].native_info.EXdisplay, hwin_no,
                      0, NULL);
      
      temp_ptr[offset].native_info.EXgc = gc;
      temp_ptr[offset].native_info.screen_no = 
                              WLIscreens_arr[lscreen_no].native_info.screen_no;
      temp_ptr[offset].native_info.cursor = NULL;

      if ( WLIscreens_arr[lscreen_no].native_info.null_cursor == None )
      {
         pmap = XCreateBitmapFromData( temp_ptr[offset].native_info.EXdisplay,
                                       hwin_no, null_data, 2, 2 );

         null_color.red = null_color.blue = null_color.green = 0;
         WLIscreens_arr[lscreen_no].native_info.null_cursor = 
                 XCreatePixmapCursor( temp_ptr[offset].native_info.EXdisplay,
                                      pmap, pmap, &null_color, &null_color, 
                                      1, 1 );
         
      }
      temp_ptr[offset].native_info.null_cursor = 
                        WLIscreens_arr[lscreen_no].native_info.null_cursor;
      
#if defined( OPENGL )
      temp_ptr[offset].native_info.glx_context = NULL;
      temp_ptr[offset].native_info.hl_glx_context = NULL;
      temp_ptr[offset].native_info.base_in_2d = 0;
      temp_ptr[offset].native_info.hilite_in_2d = 0;
#endif
#if defined( XGL )
      temp_ptr[offset].native_info.xgl_color_type.rgb = 0;
      temp_ptr[offset].native_info.xgl_hlhsr_mode = XGL_HLHSR_NONE;
      temp_ptr[offset].native_info.xgl_context_3D = NULL;
      temp_ptr[offset].native_info.hl_xgl_context_3D = NULL;
      temp_ptr[offset].native_info.win_ras = NULL;
      temp_ptr[offset].native_info.hl_win_ras = NULL;
      temp_ptr[offset].native_info.mem_ras = NULL;
      temp_ptr[offset].native_info.hl_mem_ras = NULL;
      temp_ptr[offset].native_info.global_model_trans = NULL;
      temp_ptr[offset].native_info.local_model_trans = NULL;
      temp_ptr[offset].native_info.view_trans = NULL;
      temp_ptr[offset].native_info.hl_global_model_trans = NULL;
      temp_ptr[offset].native_info.hl_local_model_trans = NULL;
      temp_ptr[offset].native_info.hl_view_trans = NULL;
      temp_ptr[offset].native_info.base_in_2d = 0;
      temp_ptr[offset].native_info.hilite_in_2d = 0;
#endif
#elif defined( ENV5 )

      temp_ptr[offset].native_info.screen_no = 
                              WLIscreens_arr[lscreen_no].native_info.screen_no;
      temp_ptr[offset].native_info.env5_vsi_flags = 
                       WLIscreens_arr[lscreen_no].native_info.env5_vsi_flags;

#elif defined( WIN32 )
      
      temp_ptr[offset].native_info.hdc = GetDC( hwin_no );
      temp_ptr[offset].native_info.cursor = NULL;
      temp_ptr[offset].native_info.class = 
                              WLIscreens_arr[lscreen_no].native_info.class;
      temp_ptr[offset].native_info.hinstance = 
                              WLIscreens_arr[lscreen_no].native_info.hinstance;
      temp_ptr[offset].native_info.wnd_proc = 
                              WLIscreens_arr[lscreen_no].native_info.wnd_proc;

#else
#error "A windowing system must be defined"
#endif
      temp_ptr[offset].created= WLI_TRUE;
   }
      

   temp_ptr[offset].hwin_no = hwin_no;
   temp_ptr[offset].context_no = context_no;
   temp_ptr[offset].active_weight = 0;
   temp_ptr[offset].active_style = 0;
   temp_ptr[offset].active_blend = 0xffff;
   temp_ptr[offset].color_index = 0;
   temp_ptr[offset].red = 0;
   temp_ptr[offset].green = 0;
   temp_ptr[offset].blue = 0;
   temp_ptr[offset].background_color_index = 0;
   temp_ptr[offset].background_red = 0;
   temp_ptr[offset].background_green = 0;
   temp_ptr[offset].background_blue = 0;
   temp_ptr[offset].flags =  WLI_WIN_FLAGS_COLOR_CHANGED |
                             WLI_WIN_FLAGS_STYLE_CHANGED |
                             WLI_WIN_FLAGS_WEIGHT_CHANGED |
                             WLI_WIN_FLAGS_B_PATTERN_CHANGED |
                             WLI_WIN_FLAGS_B_PATTERN_SOLID |
                             WLI_WIN_FLAGS_BASE_DRAW;
   temp_ptr[offset].style_change_count = 0;
   temp_ptr[offset].exnuc_data = 0;
   temp_ptr[offset].data1 = NULL;
   temp_ptr[offset].blend_pattern = NULL;

   /* Window was created by WL                                */
   if( created_flag )
   {
      temp_ptr[offset].flags |= WLI_WIN_FLAGS_WL_CREATED;
   }

#if defined( OPENGL )
#if defined( X11 )
   if ( temp_ptr[offset].native_info.glx_context )
   {
      temp_ptr[offset].flags |= WLI_WIN_FLAGS_USING_OPENGL;
   }
#endif
#endif
#if defined( X11 )

#if defined( XGL )
   if ( temp_ptr[offset].native_info.xgl_context_3D )
   {
      temp_ptr[offset].flags |= WLI_WIN_FLAGS_USING_XGL;
   }
#endif

   if ( ( native_info ) && ( native_info->flags & WL_NI_SEPARATE_HILITE ) ) 
   {
      temp_ptr[offset].flags |= WLI_WIN_SEPARATE_HILITE;
   }
   else
   {
      temp_ptr[offset].flags &= ~WLI_WIN_SEPARATE_HILITE;
   }
#endif

   WLIcontext_inc_ref_ct( context_no ); 
   *lwin_no = WLIwin_pack(lscreen_no, group_index, offset );

   temp_ptr[offset].lwin_no = *lwin_no;

   sts = WLIset_window_functions( &temp_ptr[offset] );
   if ( sts != WL_SUCCESS )
   {
      WL_REPORT_ERROR( sts );
      return( sts );
   }

#if defined( OPENGL )
   /* set the OPENGL functions now because they may override */
   /* the windowing system functions                         */
   sts = WLIset_window_functions_OPENGL( &temp_ptr[offset] );
   if ( sts != WL_SUCCESS )
   {
      WL_REPORT_ERROR( sts );
      return( sts );
   }
#endif

#if defined( XGL )
   /* set the XGL functions now because they may override */
   /* the windowing system functions                         */
   sts = WLIset_window_functions_XGL( &temp_ptr[offset] );
   if ( sts != WL_SUCCESS )
   {
      WL_REPORT_ERROR( sts );
      return( sts );
   }
#endif

   sts = WLIwin_set_bounds( *lwin_no );
   if ( sts != WL_SUCCESS )
   {
      WL_REPORT_ERROR( sts );
      return( sts );
   }

   return( WL_SUCCESS );

} /* WLIwin_add_entry */


/*--- WLIwin_set_active_weight--------------------------------------------*/

int WLIwin_set_active_weight(
   WLuint32 lwin_no,
   int weight)
/*
NAME
	WLIwin_set_active_weight
 
KEYWORD
	WL (INTERNAL)
 
DESCRIPTION
	This function sets the active weight for a window.
	All subsequent drawing will use this line style
 
SYNOPSIS
	int WLIwin_set_active_weight(
	   WLuint32 lwin_no,
	   int weight)

PARAMETERS
	lwin_no (IN) - logical window number
	weight (IN) - the active weight
 
GLOBALS USED
        not yet
 
RETURN VALUES
        WL_SUCCESS
                Success

	WL_BAD_WINDOW_NUMBER
		The logical window number is invalid
 
HISTORY
        10/19/92 Shridar Subramanian
                Initial definition
*/
{
   WLuint16 lscreen_no;
   WLuint8  group_index;
   WLuint8  offset;
   struct WLIwin *temp_ptr;


   /* unpack the logical window number and access the window structure */

   WLIwin_unpack( lwin_no, &lscreen_no, &group_index, &offset );

   if ( WLIwin_validate( lscreen_no, group_index, offset ) != WL_SUCCESS )
   {
      WL_REPORT_ERROR( WL_BAD_WINDOW_NUMBER );
      return( WL_BAD_WINDOW_NUMBER );
   }
	
   temp_ptr = WLIscreens_arr[lscreen_no].pwin[group_index].pwin_group;

   /* Set the weight in the window structure and set the flag         */
   /* indicating that the active weight has changed                   */

   if ( ( temp_ptr[offset].active_weight != weight ) || 
        ( !( temp_ptr[offset].flags &  WLI_WIN_FLAGS_WL_CREATED ) ) )
   {
      temp_ptr[offset].active_weight = weight;
      temp_ptr[offset].flags |= WLI_WIN_FLAGS_WEIGHT_CHANGED;
   }
   return( WL_SUCCESS );

} /* WLIwin_set_active_weight */


/*--- WLIwin_set_active_style--------------------------------------------*/

int WLIwin_set_active_style(
   WLuint32 lwin_no,
   int style,
   WLuint16 blend)
/*
NAME
	WLIwin_set_active_style
 
KEYWORD
	WL (INTERNAL)
 
DESCRIPTION
	This function sets the active style for a window. 
	All subsequent drawing will use this line style
 
SYNOPSIS
	int WLIwin_set_active_style(
	   WLuint32 lwin_no,
	   int style,
           WLuint16 blend )

PARAMETERS
	lwin_no (IN) - logical window number
	style (IN) - the active style
        blend (IN) - the active blend to be used with the style
 
GLOBALS USED
        not yet
 
RETURN VALUES
        WL_SUCCESS
                Success

	WL_BAD_WINDOW_NUMBER
		The logical window number is invalid
 
HISTORY
        10/19/92 Shridar Subramanian
                Initial definition
*/

{
   WLuint16 lscreen_no;
   WLuint8  group_index;
   WLuint8  offset;
   struct WLIwin *temp_ptr;


   /* unpack the logical window number and access the window structure */

   WLIwin_unpack( lwin_no, &lscreen_no, &group_index, &offset );

   if ( WLIwin_validate( lscreen_no, group_index, offset ) != WL_SUCCESS )
   {
      WL_REPORT_ERROR( WL_BAD_WINDOW_NUMBER );	
      return( WL_BAD_WINDOW_NUMBER );
   }

   /* Fill in the active style                                          */

   temp_ptr = WLIscreens_arr[lscreen_no].pwin[group_index].pwin_group;

   if ( ( temp_ptr[offset].active_style != style ) ||
        ( temp_ptr[offset].active_blend != blend ) ||
        ( !( temp_ptr[offset].flags &  WLI_WIN_FLAGS_WL_CREATED ) ) )
   {
      temp_ptr[offset].active_style = style;
      temp_ptr[offset].active_blend = blend;
      temp_ptr[offset].flags |= WLI_WIN_FLAGS_STYLE_CHANGED;
   }
   return( WL_SUCCESS );

} /* WLIwin_set_active_style */


/*--- WLIwin_set_blend_pattern--------------------------------------------*/

/*ARGSUSED*/
int WLIwin_set_blend_pattern(
   WLuint32 lwin_no,
   int solid_flag,
   int opaque_flag,
   WLblend_pattern blend_pattern,
   WLblend_pattern hl_blend_pattern,
   WLuint32 *exp_pattern )

/*
NAME
	WLIwin_set_blend_pattern
 
KEYWORD
	WL (INTERNAL)
 
DESCRIPTION
	This function sets the active blend area pattern for a window. 
	All subsequent filling routines will use this blend pattern
 
SYNOPSIS
	int WLIwin_set_blend_pattern(
	   WLuint32 lwin_no,
	   int solid_flag,
	   int opaque_flag,
	   WLblend_pattern blend_pattern,
           WLblend_pattern hl_blend_pattern,
	   WLuin32 *exp_pattern )

PARAMETERS
	lwin_no (IN) - logical window number
	solid_flag (IN) - flags word indicationg a solid pattern or not. 
	opaque_flag (IN) - flags word indicationg an opaque pattern or a 
			   transparent one. 
	blend_pattern (IN) - the active blend pattern, can be NULL if solid
	                     pattern
	hl_blend_pattern (IN) - the active blend pattern for the highlight , 
                                can be NULL if solid pattern
	exp_pattern (IN) - the 32x32 device ind. pattern, can be NULL
 
GLOBALS USED
        not yet
 
RETURN VALUES
        WL_SUCCESS
                Success

	WL_BAD_WINDOW_NUMBER
		The logical window number is invalid

HISTORY
        10/19/92 Shridar Subramanian
                Initial definition
*/

{
   WLuint16 lscreen_no;
   WLuint8  group_index;
   WLuint8  offset;
   struct WLIwin *temp_ptr;

   /* unpack the logical window number and access the window structure */
   WLIwin_unpack( lwin_no, &lscreen_no, &group_index, &offset );

   if ( WLIwin_validate( lscreen_no, group_index, offset ) != WL_SUCCESS )
   {
      WL_REPORT_ERROR( WL_BAD_WINDOW_NUMBER );	
      return( WL_BAD_WINDOW_NUMBER );
   }

   temp_ptr = WLIscreens_arr[lscreen_no].pwin[group_index].pwin_group;

   temp_ptr[offset].flags |=  WLI_WIN_FLAGS_B_PATTERN_CHANGED;
   if ( solid_flag )
   {
      temp_ptr[offset].flags |= WLI_WIN_FLAGS_B_PATTERN_SOLID;
   }
   else
   {
      temp_ptr[offset].flags &= ~WLI_WIN_FLAGS_B_PATTERN_SOLID;
   }

   if ( opaque_flag )
   {
      temp_ptr[offset].flags |= WLI_WIN_FLAGS_B_PATTERN_OPAQUE;
   }
   else
   {
      temp_ptr[offset].flags &= ~WLI_WIN_FLAGS_B_PATTERN_OPAQUE;
   }

   if ( exp_pattern )
   {
      memcpy( temp_ptr[offset].exp_pattern, exp_pattern, sizeof( WLuint32 ) * 32 );
   }

   if ( ( !blend_pattern ) && ( solid_flag ) )
   {
      return( WL_SUCCESS );
   }
#if defined( X11 )
   if ( temp_ptr[offset].blend_pattern )
   {
/**
      XFreePixmap( temp_ptr[offset].native_info.EXdisplay,
                   temp_ptr[offset].blend_pattern );
**/
   }
   temp_ptr[offset].blend_pattern = blend_pattern; 
   temp_ptr[offset].hl_blend_pattern = hl_blend_pattern; 
#elif defined( ENV5 )
   if ( !temp_ptr[offset].blend_pattern )
   {
      temp_ptr[offset].blend_pattern = ( WLblend_pattern )malloc( 32 * 
                                                              sizeof( long ) ); 
   }
   memcpy( temp_ptr[offset].blend_pattern, blend_pattern, 32 * sizeof( long ) );
#elif defined( WIN32 )
   /* The blend pattern is 16 bytes because of the padding required by */
   /* WIN32 bitmaps (i.e., all rows must be an even number of bytes)   */
   if ( !temp_ptr[offset].blend_pattern )
   {
      temp_ptr[offset].blend_pattern = ( WLblend_pattern )malloc( 16 * 
                                                              sizeof( char ) ); 
   }
   memcpy( temp_ptr[offset].blend_pattern, blend_pattern, 16 * sizeof( char ) );
#endif

   return( WL_SUCCESS );
}

/*--- WLIwin_set_active_foreground--------------------------------------------*/

int WLIwin_set_active_foreground(
   WLuint32 lwin_no,
   WLcolorref color_ref)
/*
NAME
	WLIwin_set_active_foreground

KEYWORD
	WL (INTERNAL)

DESCRIPTION
	This function set the active foreground color for a window

SYNOPSIS
	int WLIwin_set_active_foreground(
	   WLuint32 lwin_no,
	   WLcolorref color_ref)

PARAMETERS
	lwin_no (IN) - logical window number
	color_ref (IN) - The packed color

GLOBALS USED
        not yet

RETURN VALUES
        WL_SUCCESS
                Success

	WL_BAD_WINDOW_NUMBER
		The logical window number is invalid

HISTORY
        10/19/92 Shridar Subramanian
                Initial definition
*/
{
   WLuint16  lscreen_no=0;
   WLuint8   group_index=0;
   WLuint8   offset=0;
   WLuint32  color_index=0,new_color_index=0;
   WLuint32  red=0,green=0, blue=0;
   WLuint32  new_red=0, new_green=0, new_blue=0;
   WLuint32  color_flags=0;
   WLuint32  context_no=0;
   int       sts;

   struct WLIcontext context;
   struct WLIwin     *temp_ptr;

   WLIwin_unpack( lwin_no, &lscreen_no, &group_index, &offset );
   if ( WLIwin_validate( lscreen_no, group_index, offset) != WL_SUCCESS )
   {
      WL_REPORT_ERROR( WL_BAD_WINDOW_NUMBER );
      return( WL_BAD_WINDOW_NUMBER );
   }

   temp_ptr = WLIscreens_arr[lscreen_no].pwin[group_index].pwin_group;
   context_no = temp_ptr[offset].context_no;
   if ( sts = WLIcontext_retrieve_entry( context_no, &context ) != WL_SUCCESS )
   {
      WL_REPORT_ERROR( sts );
      return( sts );
   }
   WLIwin_unpack_colorref( color_ref, &color_index, &red,
                          &green, &blue, &color_flags );

   if ( context.base_cmap_type == WL_CMAP_TRUE_COLOR )
   {
      if ( (color_flags & WL_COLOR_RGB) &&
         ( (red > WL_MAX_COLOR) || (green > WL_MAX_COLOR) || (blue > WL_MAX_COLOR) ) )
      {
         WL_REPORT_ERROR( WL_BAD_RGB );
         return( WL_BAD_RGB );
      }
      
      if ( (color_flags & WL_COLOR_PHYSICAL) && !( color_flags & WL_COLOR_RGB ) )
      {
         WL_REPORT_ERROR( WL_BAD_COLOR_REF );
         return( WL_BAD_COLOR_REF );
      }

      if ( color_flags & WL_COLOR_PHYSICAL )
      {
         new_red = red;
         new_green = green;
         new_blue = blue;
      }
      else
      {
         /*  Convert the logical color or the rgb values into the actual rgb  */
         /* values                                                            */
         (*context.cmap_color_to_rgb)( context_no, color_index, red, green, blue,
                                     color_flags, &new_red, &new_green, &new_blue);
      }

      if ( ( temp_ptr[offset].red != new_red ) || 
           ( temp_ptr[offset].green != new_green ) ||
           ( temp_ptr[offset].blue != new_blue ) ||
           ( !( temp_ptr[offset].flags &  WLI_WIN_FLAGS_WL_CREATED ) ) )
      {
         temp_ptr[offset].red = new_red;
         temp_ptr[offset].green = new_green;
         temp_ptr[offset].blue = new_blue;
         temp_ptr[offset].flags |= WLI_WIN_FLAGS_COLOR_CHANGED;
      }
   }
   else
   {
      if ( (color_flags & WL_COLOR_PHYSICAL) && (color_flags & WL_COLOR_RGB) )
      {
         WL_REPORT_ERROR( WL_BAD_COLOR_REF );
         return( WL_BAD_COLOR_REF );
      }

      if ( color_flags & WL_COLOR_PHYSICAL )
      {
         new_color_index = color_index;
      }
      else
      {
         /*  Convert the logical color or the rgb values into the physical    */
         /* index                                                             */
         (*context.cmap_color_to_index)( context_no, color_index, red, green,
                                         blue, color_flags, &new_color_index);
      }

      if ( ( temp_ptr[offset].color_index != ( int ) new_color_index ) ||
           ( !( temp_ptr[offset].flags &  WLI_WIN_FLAGS_WL_CREATED ) ) )
      {
         temp_ptr[offset].color_index = new_color_index;
         temp_ptr[offset].flags |= WLI_WIN_FLAGS_COLOR_CHANGED;
      }
   }
   return( WL_SUCCESS );

} /* WLIwin_set_active_foreground */

/*--- WLIwin_set_context--------------------------------------------*/

int WLIwin_set_context(
   WLuint32 lwin_no,
   WLuint32 context_no)
/*
NAME
	WLIwin_set_context

KEYWORD
	WL (INTERNAL)

DESCRIPTION
	This function set the context number for a window

SYNOPSIS
	int WLIwin_set_context(
	   WLuint32 lwin_no,
	   WLuint32 context_no)

PARAMETERS
	lwin_no (IN) - logical window number
	context_no (IN) - the context number

GLOBALS USED
        not yet

RETURN VALUES
        WL_SUCCESS
                Success

	WL_BAD_WINDOW_NUMBER
		The logical window number is invalid

HISTORY
        10/19/92 Shridar Subramanian
                Initial definition
*/
{
   WLuint16   lscreen_no;
   WLuint8    group_index;
   WLuint8    offset;
   struct WLIwin   *temp_ptr;
   
   WLIwin_unpack( lwin_no, &lscreen_no, &group_index, &offset );
   if ( WLIwin_validate( lscreen_no, group_index, offset ) != WL_SUCCESS )
   {
      WL_REPORT_ERROR( WL_BAD_WINDOW_NUMBER );
      return( WL_BAD_WINDOW_NUMBER );
   }

   temp_ptr = WLIscreens_arr[lscreen_no].pwin[group_index].pwin_group;
   temp_ptr[offset].context_no = context_no;
   return ( WL_SUCCESS );

} /* WLIwin_set_context */

/*--- WLIwin_set_user_data--------------------------------------------*/

int WLIwin_set_user_data(
   WLuint32 lwin_no,
   void **exnuc_data,
   void **data1)
/*
NAME
	WLIwin_set_user_data

KEYWORD
	WL (INTERNAL)

DESCRIPTION
	This function associates user data with a window

SYNOPSIS
	int WLIwin_set_user_data(
	   WLuint32 lwin_no,
	   void **exnuc_data,
	   void **data1)

PARAMETERS
	lwin_no (IN) - logical window number
	exnuc_data (IN) - used by EXNUC for storing the channel number,
			 or NULL to leave the value unchanged
	data1 (IN) - user data or NULL to leave the value unchanged

GLOBALS USED
        not yet

RETURN VALUES
        WL_SUCCESS
                Success

	WL_BAD_WINDOW_NUMBER
		The logical window number is invalid

HISTORY
        10/19/92 Shridar Subramanian
                Initial definition
*/
{
   WLuint16   lscreen_no;
   WLuint8    group_index;
   WLuint8    offset;
   struct WLIwin  *temp_ptr;

   WLIwin_unpack( lwin_no, &lscreen_no, &group_index, &offset );
   if ( WLIwin_validate( lscreen_no, group_index, offset ) != WL_SUCCESS )
   {
      WL_REPORT_ERROR( WL_BAD_WINDOW_NUMBER );
      return( WL_BAD_WINDOW_NUMBER );
   }
   temp_ptr = WLIscreens_arr[lscreen_no].pwin[group_index].pwin_group;

   if ( exnuc_data )
   {
      temp_ptr[offset].exnuc_data = *exnuc_data;
   }

   /* Need to expand the user data that can be set                        */

   if ( data1 )
   {
      temp_ptr[offset].data1 = *data1;
   }
   return ( WL_SUCCESS );

} /* WLIwin_set_user_data */

/*--- WLIwin_get_user_data--------------------------------------------*/

int WLIwin_get_user_data(
   WLuint32 lwin_no,
   void **exnuc_data,
   void **data1)
/*
NAME
	WLIwin_get_user_data
 
KEYWORD
	WL (INTERNAL)
 
DESCRIPTION
	This function gets the user data associated with a window
 
SYNOPSIS
	int WLIwin_get_user_data(
	   WLuint32 lwin_no,
	   void **exnuc_data,
	   void **data1)

PARAMETERS
	lwin_no (IN) - logical window number
	exnuc_data (IN) - used by EXNUC for storing the channel number
	data1 (IN) - user data
 
GLOBALS USED
        not yet
 
RETURN VALUES
        WL_SUCCESS
                Success

	WL_BAD_WINDOW_NUMBER
		The logical window number is invalid
 
HISTORY
        10/19/92 Shridar Subramanian
                Initial definition
*/
{
   WLuint16   lscreen_no;
   WLuint8    group_index;
   WLuint8    offset;
   struct WLIwin  *temp_ptr;

   WLIwin_unpack( lwin_no, &lscreen_no, &group_index, &offset);
   if ( WLIwin_validate( lscreen_no, group_index, offset ) != WL_SUCCESS )
   {
      WL_REPORT_ERROR( WL_BAD_WINDOW_NUMBER );
      return( WL_BAD_WINDOW_NUMBER );
   }

   temp_ptr = WLIscreens_arr[lscreen_no].pwin[group_index].pwin_group;
   if ( exnuc_data )
   {
      *exnuc_data = temp_ptr[offset].exnuc_data;
   }
   if ( data1 )
   {
      *data1 = temp_ptr[offset].data1;
   }
   return( WL_SUCCESS );

} /* WLIwin_get_user_data */


/*--- WLIwin_retrieve_entry--------------------------------------------*/

int WLIwin_retrieve_entry(
   WLuint32 lwin_no,
   struct WLIwin *win_struct)
/*
NAME
	WLIwin_retrieve_entry
 
KEYWORD
	WL (INTERNAL)
 
DESCRIPTION
	This function retrieves the window structure associated with a
	logical window
 
SYNOPSIS
	int WLIwin_retrieve_entry(
	   WLuint32 lwin_no,
	   struct WLIwin *win_struct)

PARAMETERS
	lwin_no (IN) - logical screen number
	win_struct (IN) - the window structure

GLOBALS USED
        not yet
 
RETURN VALUES
        WL_SUCCESS
                Success

	WL_BAD_WINDOW_NUMBER
		The logical window number is invalid
 
HISTORY
        10/19/92 Shridar Subramanian
                Initial definition
*/
{
   WLuint16   lscreen_no;
   WLuint8    group_index;
   WLuint8    offset;
   struct WLIwin  *temp_ptr;

   WLIwin_unpack( lwin_no, &lscreen_no, &group_index, &offset );
   if ( WLIwin_validate( lscreen_no, group_index, offset) != WL_SUCCESS)
   {
      WL_REPORT_ERROR( WL_BAD_WINDOW_NUMBER );
      return( WL_BAD_WINDOW_NUMBER );
   }
   temp_ptr = WLIscreens_arr[lscreen_no].pwin[group_index].pwin_group;
   if ( !win_struct )
   {
      WL_REPORT_ERROR( WL_ERROR );
      return( WL_ERROR );
   }
   memcpy( (char * ) win_struct, ( const char * ) &temp_ptr[offset], 
           sizeof( struct WLIwin ) );
   return( WL_SUCCESS );

} /*  WLIwin_retrieve_entry */


/*--- WLIwin_retrieve_entry--------------------------------------------*/

int WLIwin_retrieve_entry_ptr(
   WLuint32 lwin_no,
   struct WLIwin **win_struct)
/*
NAME
	WLIwin_retrieve_entry_ptr
 
KEYWORD
	WL (INTERNAL)
 
DESCRIPTION
	This function retrieves a pointer to the window structure
	associated with a logical window.
 
SYNOPSIS
	int WLIwin_retrieve_entry_ptr(
	   WLuint32 lwin_no,
	   struct WLIwin **win_struct)

PARAMETERS
	lwin_no (IN) - logical screen number
	win_struct (IN) - the window structure pointer

NOTES
	This function should be used sparingly and with caution
	because it returns a pointer to the internal window
	structure maintained by WL.

GLOBALS USED
        none
 
RETURN VALUES
        WL_SUCCESS
                Success

	WL_BAD_WINDOW_NUMBER
		The logical window number is invalid
 
	WL_BAD_PARAMETER
		The 'win_struct' parameter is NULL.

HISTORY
        12/22/92 S.P. Rogers
                Initial definition and implementation
*/

{
   WLuint16 lscreen_no;
   WLuint8 group_index;
   WLuint8 offset;
   struct WLIwin *win_group_ptr;

   if ( ! win_struct )
   {
      WL_REPORT_ERROR( WL_BAD_PARAMETER );
      return( WL_BAD_PARAMETER );
   }

   WLIwin_unpack( lwin_no, &lscreen_no, &group_index, &offset );
   if ( WLIwin_validate( lscreen_no, group_index, offset) != WL_SUCCESS )
   {
      WL_REPORT_ERROR( WL_BAD_WINDOW_NUMBER );
      return( WL_BAD_WINDOW_NUMBER );
   }

   win_group_ptr = WLIscreens_arr[lscreen_no].pwin[group_index].pwin_group;

   *win_struct = &win_group_ptr[offset];

   return( WL_SUCCESS );

} /*  WLIwin_retrieve_entry_ptr */


/*--- WLIwin_delete_entry--------------------------------------------*/

int WLIwin_delete_entry(
   WLuint32 lwin_no)
/*
NAME
	WLIwin_delete_entry
 
KEYWORD
	WL (INTERNAL)
 
DESCRIPTION
	This function deletes an entry for a logical window
 
SYNOPSIS
	int WLIwin_delete_entry(
	   WLuint32 lwin_no)

PARAMETERS
	lwin_no (IN) - logical window number

GLOBALS USED
        not yet
 
RETURN VALUES
        WL_SUCCESS
                Success

	WL_BAD_WINDOW_NUMBER
		The logical window number is invalid
 
HISTORY
        10/19/92 Shridar Subramanian
                Initial definition
*/
{
   WLuint16   lscreen_no;
   WLuint8    group_index;
   WLuint8    offset;
   struct WLIwin  *temp_ptr;

   WLIwin_unpack( lwin_no, &lscreen_no, &group_index, &offset );
   if ( WLIwin_validate( lscreen_no, group_index, offset ) != WL_SUCCESS )
   {
      WL_REPORT_ERROR( WL_BAD_WINDOW_NUMBER );
      return( WL_BAD_WINDOW_NUMBER );
   }

   temp_ptr = WLIscreens_arr[lscreen_no].pwin[group_index].pwin_group;

   temp_ptr[offset].used = 0;

   WLIcontext_dec_ref_ct( temp_ptr[offset].context_no );

   WLIscreens_arr[lscreen_no].pwin[group_index].num_entries_used --;

   /* Deallocate if required                                             */
   if ( ( WLIscreens_arr[lscreen_no].pwin[group_index].num_entries_used == 0 )
       &&  ( WLIscreens_arr[lscreen_no].pwin[group_index].pwin_group ) )
   {
      WLI_FREE( WLIscreens_arr[lscreen_no].pwin[group_index].pwin_group );
   }

   return( WL_SUCCESS );
} /*  WLIwin_delete_entry */


/*--- WLIwin_hardware_to_logical------------------------------------*/

int WLIwin_hardware_to_logical(
   WLuint16 lscreen_no,
   WLhwin_no hwin_no,
   WLuint32 *lwin_no)
/*
NAME
	WLIwin_hardware_to_logical
 
KEYWORD
	WL (INTERNAL)
 
DESCRIPTION
	This function returns the logical window number, given the 
	hardware window number
 
SYNOPSIS
	int WLIwin_hardware_to_logical(
	   WLuint16 lscreen_no,
	   WLhwin_no hwin_no,
	   WLuint32 *lwin_no)

PARAMETERS
	lscreen_no (IN) - logical screen number
	hwin_no (IN) - hardware window number
	lwin_no (OUT) - logical window number

GLOBALS USED
        not yet
 
RETURN VALUES
        WL_SUCCESS
                Success

	WL_BAD_HARDWARE_WINDOW
		The hardware window does not exist as a logical window
 
HISTORY
        10/19/92 Shridar Subramanian
                Initial definition
*/
{
   WLuint8    group_index;
   WLuint8    offset;
   int        found,i,j;

   struct WLIwin        *temp_ptr;
   struct WLIwin_group  *pwin_arr;
	
   group_index = offset = 0;
   pwin_arr = WLIscreens_arr[lscreen_no].pwin;
   if ( !pwin_arr )
   {
      WL_REPORT_ERROR( WL_ERROR );
      return( WL_ERROR );
   }
   found = WLI_FALSE;
   for ( i=0; i < WLI_MAX_WIN_GROUPS && !found; i++ )
   {
      if ( pwin_arr[i].pwin_group )
      {
         temp_ptr=pwin_arr[i].pwin_group;
         for ( j=0; j< WLI_MAX_WINDOWS_PER_GROUP && !found; j++)
         {
            if ( ( temp_ptr[j].used ) && 
                 ( temp_ptr[j].hwin_no == hwin_no ) )
            {
               found = WLI_TRUE;
               offset = j;
               group_index = i;
            }
         }
      }
   }
   if ( !found )
   {
      WL_REPORT_ERROR( WL_BAD_HARDWARE_WINDOW );
      return( WL_BAD_HARDWARE_WINDOW );
   }
   *lwin_no = WLIwin_pack( lscreen_no, group_index, offset);
   return ( WL_SUCCESS );

} /* WLIwin_hardware_to_logical */


/*--- WLIwin_pack--------------------------------------------*/

WLuint32 WLIwin_pack(
   WLuint16 lscreen_no,
   WLuint8  group_index,
   WLuint8  offset)	
/*
NAME
	WLIwin_pack
 
KEYWORD
	WL (INTERNAL)
 
DESCRIPTION
	This function creates a logical window number by packing
 
SYNOPSIS
	WLuint32 WLIwin_pack(
	   WLuint16 lscreen_no,
	   WLuint8  group_index,
	   WLuint8  offset)	

PARAMETERS
	lscreen_no (IN) - The logical screen number
	group_index (IN) - The group index
	offset (IN) - The offset

GLOBALS USED
        not yet
 
RETURN VALUES
	The packed number
 
HISTORY
        10/19/92 Shridar Subramanian
                Initial definition
*/
{
   WLuint32   x=0,y=0;

   x = lscreen_no << 16;
   y = group_index << 8;   
   return ( x | y | offset );

} /*  WLIwin_pack */


/*--- WLIwin_unpack--------------------------------------------*/

int WLIwin_unpack(
   WLuint32   lwin_no,
   WLuint16 *lscreen_no,
   WLuint8  *group_index,
   WLuint8  *offset)	
/*
NAME
	WLIwin_unpack
 
KEYWORD
	WL (INTERNAL)
 
DESCRIPTION
	This function unpacks  logical windwo number
 
SYNOPSIS
	int WLIwin_unpack(
	   WLuint32   lwin_no,
	   WLuint16 *lscreen_no,
	   WLuint8  *group_index,
	   WLuint8  *offset)	

PARAMETERS
	lwin_no (IN) - The logical window number;
	lscreen_no (OUT) - The logical screen number
	group_index (OUT) - The group index
	offset (OUT) - The  offset

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
   if ( lscreen_no )
   {
      *lscreen_no = ( lwin_no >> 16 ) & 0xffff;
   }
   if ( group_index )
   {
      *group_index = ( lwin_no >> 8 ) & 0xff;
   }
   if ( offset )
   {
      *offset = lwin_no & 0xff;
   }
   return( WL_SUCCESS );
} /*  WLIwin_unpack */


/*--- WLIwin_validate--------------------------------------------*/

int WLIwin_validate(
   WLuint16 lscreen_no,
   WLuint8  group_index,
   WLuint8  offset)	
/*
NAME
	WLIwin_validate
 
KEYWORD
	WL (INTERNAL)
 
DESCRIPTION
	This function validates a logical window 
 
SYNOPSIS
	int WLIwin_validate(
	   WLuint16 lscreen_no,
	   WLuint8  group_index,
	   WLuint8  offset)	

PARAMETERS
	lscreen_no (IN) - The logical screen number
	group_index (IN) - The group index
	offset (IN) - The offset

GLOBALS USED
        not yet
 
RETURN VALUES
	WL_SUCCESS
		Success

	WL_ERROR
		Failure
 
HISTORY
        10/19/92 Shridar Subramanian
                Initial definition
*/
{
   int    sts;

   sts = WLIscreen_validate( lscreen_no );
   if ( sts != WL_SUCCESS )
   {
      WL_REPORT_ERROR( sts );
      return( sts );
   }
   if (  group_index >= WLI_MAX_WIN_GROUPS || 
         offset >= WLI_MAX_WINDOWS_PER_GROUP )
   {
      WL_REPORT_ERROR( WL_ERROR );
      return( WL_ERROR );
   }
   if ( !WLIscreens_arr[lscreen_no].pwin )
   {
      WL_REPORT_ERROR( WL_ERROR );
      return( WL_ERROR );
   }
   if ( !WLIscreens_arr[lscreen_no].pwin[group_index].pwin_group )
   {
      WL_REPORT_ERROR( WL_ERROR );
      return( WL_ERROR );
   }
   if ( !WLIscreens_arr[lscreen_no].pwin[group_index].pwin_group[offset].used )
   {
      WL_REPORT_ERROR( WL_ERROR );
      return( WL_ERROR );
   }

   return( WL_SUCCESS );
   
} /*  WLIwin_validate */


/*--- WLIwin_set_style_change_count--------------------------------------------*/

int WLIwin_set_style_change_count(
   WLuint32 lwin_no,
   WLuint8 style_change_count)
/*
NAME
	WLIwin_set_style_change_count
 
KEYWORD
	WL (INTERNAL)
 
DESCRIPTION
	This function sets the style change count for a window.
 
SYNOPSIS
	int WLIwin_set_style_change_count(
	   WLuint32 lwin_no,
	   WLuint8 style_change_count)

PARAMETERS
	lwin_no (IN) - logical window number
	style_change_count (IN) - the style change count
 
GLOBALS USED
        not yet
 
RETURN VALUES
        WL_SUCCESS
                Success

	WL_BAD_WINDOW_NUMBER
		The logical window number is invalid
 
HISTORY
        10/30/92 S.P. Rogers
                Initial definition
*/
{
   WLuint16   lscreen_no;
   WLuint8    group_index;
   WLuint8    offset;
   struct WLIwin   *temp_ptr;

   WLIwin_unpack( lwin_no, &lscreen_no, &group_index, &offset);
   if ( WLIwin_validate( lscreen_no, group_index, offset ) != WL_SUCCESS )
   {
      WL_REPORT_ERROR( WL_BAD_WINDOW_NUMBER );
      return( WL_BAD_WINDOW_NUMBER );
   }
   
   temp_ptr = WLIscreens_arr[lscreen_no].pwin[group_index].pwin_group;

   temp_ptr[offset].style_change_count = style_change_count;

   return( WL_SUCCESS );

} /* WLIwin_set_style_change_count */


/*--- WLIwin_set_flags ------------------------------------------------------*/

int WLIwin_set_flags(
   WLuint32 lwin_no,
   WLuint32 flags)
/*
NAME
	WLIwin_set_flags
 
KEYWORD
	WL (INTERNAL)
 
DESCRIPTION
	This function sets the flags word for a window.
 
SYNOPSIS
	int WLIwin_set_flags(
	   WLuint32 lwin_no,
	   WLuint32 flags)

PARAMETERS
	lwin_no (IN) - logical window number
	flags (IN) - the new flags
 
GLOBALS USED
        not yet
 
RETURN VALUES
        WL_SUCCESS
                Success

	WL_BAD_WINDOW_NUMBER
		The logical window number is invalid
 
HISTORY
        10/30/92 S.P. Rogers
                Initial definition
*/
{
   WLuint16   lscreen_no;
   WLuint8    group_index;
   WLuint8    offset;
   struct WLIwin   *temp_ptr;

   WLIwin_unpack( lwin_no, &lscreen_no, &group_index, &offset );
   if ( WLIwin_validate( lscreen_no, group_index, offset ) != WL_SUCCESS )
   {
      WL_REPORT_ERROR( WL_BAD_WINDOW_NUMBER );
      return( WL_BAD_WINDOW_NUMBER );
   }
   
   temp_ptr = WLIscreens_arr[lscreen_no].pwin[group_index].pwin_group;

   temp_ptr[offset].flags = flags;

   return( WL_SUCCESS );

} /* WLIwin_set_flags */


/*--- WLIwin_set_event_mask ------------------------------------------------------*/

int WLIwin_set_event_mask(
   WLuint32 lwin_no,
   int event_mask)
/*
NAME
	WLIwin_set_event_mask
 
KEYWORD
	WL (INTERNAL)
 
DESCRIPTION
	This function sets the event mask and enables events for a 
	logical window
 
PARAMETERS
	lwin_no (IN) - logical window number
	event_mask (IN) - the event mask
 
SYNOPSIS
	int WLIwin_set_event_mask(
	   WLuint32 lwin_no,
	   int event_mask)

GLOBALS USED
        not yet
 
RETURN VALUES
        WL_SUCCESS
                Success

	WL_BAD_WINDOW_NUMBER
		The logical window number is invalid
 
HISTORY
        10/30/92 Shridar Subramanian
                Initial definition
*/
{
   WLuint16   lscreen_no;
   WLuint8    group_index;
   WLuint8    offset;
#if defined( ENV5 ) || defined( X11 )
   int        mask, new_mask;
#endif
   struct WLIwin   *temp_ptr;

   WLIwin_unpack( lwin_no, &lscreen_no, &group_index, &offset );
   if ( WLIwin_validate( lscreen_no, group_index, offset ) != WL_SUCCESS )
   {
      WL_REPORT_ERROR( WL_BAD_WINDOW_NUMBER );
      return( WL_BAD_WINDOW_NUMBER );
   }
   
   temp_ptr = WLIscreens_arr[lscreen_no].pwin[group_index].pwin_group;

   /* Convert the wl event mask to the native windowing system mask      */
   /* And set the native windowing event mask                            */

#if defined ( X11 )

   WLIevent_translate( event_mask, &mask );
   XSelectInput( temp_ptr[offset].native_info.EXdisplay,  
                 temp_ptr[offset].hwin_no, mask);

#elif defined ( ENV5 )
   new_mask = 0;
   if ( temp_ptr[offset].event_mask ^ event_mask )
   {
      new_mask =  temp_ptr[offset].event_mask & ( ~event_mask );
   }

   /* Disable the difference between the old and the new event mask        */

   WLIevent_translate( new_mask, &mask );
   Disable_events( mask );

   WLIevent_translate( event_mask, &mask );
   Enable_events( mask );
   

#elif defined ( WIN32 )

#else
#error "A windowing system must be defined"
#endif

   temp_ptr[offset].event_mask = event_mask;
   
   return( WL_SUCCESS );

} /* WLIwin_set_event_mask */


/*--- WLIwin_get_event_mask ------------------------------------------------------*/

int WLIwin_get_event_mask(
   WLuint32 lwin_no,
   WLuint32 *event_mask)
/*
NAME
	WLIwin_get_event_mask
 
KEYWORD
	WL (INTERNAL)
 
DESCRIPTION
	This function gets the event mask
 
SYNOPSIS
	int WLIwin_get_event_mask(
	   WLuint32 lwin_no,
	   WLuint32 *event_mask)

PARAMETERS
	lwin_no (IN) - logical window number
	event_mask (OUT) - the event mask
 
GLOBALS USED
        not yet
 
RETURN VALUES
        WL_SUCCESS
                Success

	WL_BAD_WINDOW_NUMBER
		The logical window number is invalid

HISTORY
        10/30/92 Shridar Subramanian
                Initial definition
*/
{
   WLuint16   lscreen_no;
   WLuint8    group_index;
   WLuint8    offset;
   struct WLIwin   *temp_ptr;

   WLIwin_unpack( lwin_no, &lscreen_no, &group_index, &offset );
   if ( WLIwin_validate( lscreen_no, group_index, offset ) != WL_SUCCESS )
   {
      WL_REPORT_ERROR( WL_BAD_WINDOW_NUMBER );
      return( WL_BAD_WINDOW_NUMBER );
   }
   
   temp_ptr = WLIscreens_arr[lscreen_no].pwin[group_index].pwin_group;

   *event_mask = temp_ptr[offset].event_mask ;
   
   return( WL_SUCCESS );

} /*  WLIwin_get_event_mask */	


/*--- WLIwin_set_cursor ------------------------------------------------------*/

int WLIwin_set_cursor(
   WLuint32 lwin_no,
   WLcursor cursor)
/*
NAME
	WLIwin_set_cursor
 
KEYWORD
	WL (INTERNAL)
 
DESCRIPTION
	This function set the cursor for a logical window
 
SYNOPSIS
	int WLIwin_set_cursor(
	   WLuint32 lwin_no,
	   WLcursor cursor)

PARAMETERS
	lwin_no (IN) - logical window number
	cursor (IN) - the cursor
 
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
   WLuint16   lscreen_no;
   WLuint8    group_index;
   WLuint8    offset;
   struct WLIwin   *temp_ptr;

   WLIwin_unpack( lwin_no, &lscreen_no, &group_index, &offset );
   if (WLIwin_validate( lscreen_no, group_index, offset ) != WL_SUCCESS )
   {
      WL_REPORT_ERROR( WL_BAD_WINDOW_NUMBER );
      return( WL_BAD_WINDOW_NUMBER );
   }
   
   temp_ptr = WLIscreens_arr[lscreen_no].pwin[group_index].pwin_group;

   temp_ptr[offset].native_info.cursor = cursor;
   
   return( WL_SUCCESS );

} /*  WLIwin_set_cursor */

/*--- WLIwin_unpack_colorref ------------------------------------------------------*/

int WLIwin_unpack_colorref(
   WLcolorref color_ref,
   WLuint32 *color_index,
   WLuint32 *red,
   WLuint32 *green,
   WLuint32 *blue,
   WLuint32 *color_flag)
   
/*
NAME
	WLIwin_unpack_colorref
 
KEYWORD
	WL (INTERNAL)
 
DESCRIPTION
	This function unpacks the packed color
 
SYNOPSIS
	int WLIwin_unpack_colorref(
	   WLcolorref color_ref,
	   WLuint32 *color_index,
	   WLuint32 *red,
	   WLuint32 *green,
	   WLuint32 *blue,
	   WLuint32 *color_flag)

PARAMETERS
	color_ref (IN) - The packed color	
	color_index (OUT) - The logical color index
	red (OUT) - The red component of the color
	green (OUT) - The green component of the color
	blue (OUT) - The blue component of the color
	color_flag (OUT) - Indicates whether the logical color index or RGB was
	   filled and whether the RGB or index was physical or logical
 
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
   *color_flag = 0x0;

   if ( color_ref & WL_COLOR_RGB )
   {
      *color_flag |= WL_COLOR_RGB;
      *red = (color_ref & 0x00ff0000) >> 16;
      *green = (color_ref & 0x0000ff00) >> 8;
      *blue = color_ref & 0x000000ff;

      /* red, green and blue are 16 bit values */
      *red = ( *red ) << 8;
      *green = ( *green ) << 8;
      *blue = ( *blue ) << 8;
   }
   else
   {
      *color_index = color_ref & WLI_COLORREF_INDEX_MASK;
   }

   if ( color_ref & WL_COLOR_PHYSICAL )
   {
      *color_flag |= WL_COLOR_PHYSICAL;
   }

   return( WL_SUCCESS );

} /* WLIwin_unpack_colorref */

/*--- WLIwin_debug ------------------------------------------------------*/

int WLIwin_debug(
   WLuint32 lwin_no)
   
/*
NAME
	WLIwin_debug
 
KEYWORD
	WL (INTERNAL)
 
DESCRIPTION
	This function prints out the window entry referenced by lwin_no 
 
SYNOPSIS
	int WLIwin_debug(
	   WLuint32 lwin_no)

PARAMETERS
	lwin_no (IN) - logical window number
 
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
   WLuint16   lscreen_no;
   WLuint8    group_index;
   WLuint8    offset;
   struct WLIwin   *temp_ptr;

   WLIwin_unpack( lwin_no, &lscreen_no, &group_index, &offset );
   if (WLIwin_validate( lscreen_no, group_index, offset ) != WL_SUCCESS )
   {
      WL_REPORT_ERROR( WL_BAD_WINDOW_NUMBER );
      return( WL_BAD_WINDOW_NUMBER );
   }
   
   temp_ptr = WLIscreens_arr[lscreen_no].pwin[group_index].pwin_group;

   fprintf(stderr," window %d screen %d  group %d  offset %d\n",lwin_no, lscreen_no, group_index, offset );
   fprintf(stderr," native info \n");
#if defined( X11 )

   fprintf(stderr," 	Display  %x\n", temp_ptr[offset].native_info.EXdisplay );
   fprintf(stderr," 	Depth    %d\n", temp_ptr[offset].native_info.depth );
   fprintf(stderr," 	GC       %x\n", temp_ptr[offset].native_info.EXgc );
   fprintf(stderr," 	Colormap %x\n", temp_ptr[offset].native_info.EXcolormap );
   fprintf(stderr," 	screen   %x\n", temp_ptr[offset].native_info.screen_no );
   fprintf(stderr," 	cursor   %x\n", temp_ptr[offset].native_info.cursor );

#elif defined( ENV5 )

   fprintf(stderr," 	screen   %x\n", temp_ptr[offset].native_info.screen_no );

#elif defined( WIN32 )

   fprintf(stderr," 	HDC      %x\n", temp_ptr[offset].native_info.hdc );
   fprintf(stderr," 	cursor   %x\n", temp_ptr[offset].native_info.cursor );
   fprintf(stderr," 	instance %x\n", temp_ptr[offset].native_info.hinstance );
   fprintf(stderr," 	wnd_proc %x\n", temp_ptr[offset].native_info.wnd_proc );

#else
#error "A windowing system must be defined"
#endif

   fprintf(stderr," Context number %d\n", temp_ptr[offset].context_no );
   fprintf(stderr," Window number  %d\n", temp_ptr[offset].hwin_no );
   fprintf(stderr," Active weight  %d\n", temp_ptr[offset].active_weight );
   fprintf(stderr," Active style   %d\n", temp_ptr[offset].active_style );
   fprintf(stderr," Color index    %d\n", temp_ptr[offset].color_index );
   fprintf(stderr," Red            %d\n", temp_ptr[offset].red );
   fprintf(stderr," Green          %d\n", temp_ptr[offset].green );
   fprintf(stderr," Blue           %d\n", temp_ptr[offset].blue );
   fprintf(stderr," flags          %x\n", temp_ptr[offset].flags );
   fprintf(stderr," Style count    %x\n", temp_ptr[offset].style_change_count );
   fprintf(stderr," Used Flags     %d\n", temp_ptr[offset].used );
   fprintf(stderr," Created Flags  %d\n", temp_ptr[offset].created );
   fprintf(stderr," Used data 1    %x\n", temp_ptr[offset].exnuc_data );
   fprintf(stderr," Used data 2    %x\n", temp_ptr[offset].data1 );
   fprintf(stderr," Event Mask     %x\n", temp_ptr[offset].event_mask );
   
   return( WL_SUCCESS );

} /* WLIwin_debug */

#if defined( X11 )
/*--- WLIwin_get_logical_window_from_root_parent --------------------------------*/

int WLIwin_get_logical_window_from_root_parent(
   int lscreen_no,
   Display *display,
   Window root_parent,
   WLuint32 *lwin_no )

/*
NAME
	WLIwin_get_logical_window_from_root_parent

KEYWORD
	WL

DESCRIPTION
	This function gets the logical window given a parent
	of the logical window that is directly descended from
	from the root window.  If no logical window can be found,
	WL_UNDEFINED_WINDOW is returned.

SYNOPSIS
	int WLIwin_get_logical_window_from_root_parent(
	   int lscreen_no,
	   Display *display,
	   Window root_parent,
	   WLuint32 *lwin_no )

PARAMETERS
	lscreen_no (IN) - the logical screen number to check
	display (IN) - the X display for the screen
	root_parent (IN) - the parent window that is directly
                          descended from the root window
	lwin_no (OUT) - the logical window number that was found

GLOBALS USED
	WLIscreen_arr

RETURN VALUES
	WL_SUCCESS
		Success

HISTORY
	02/15/93 S.P. Rogers
		Initial definition, design, and implementation
*/

{
   int group_no, offset,found;
   unsigned int nchildren;
   struct WLIwin_group *win_group_array;
   struct WLIwin *win_array;
   Window root, parent, win, *children;

   found = FALSE;

   /* check all of the windows for this screen */
   win_group_array = WLIscreens_arr[lscreen_no].pwin;
   for ( group_no = 0; group_no < WLI_MAX_WIN_GROUPS; group_no++ )
   {
      if ( win_group_array[group_no].pwin_group )
      {
         win_array = win_group_array[group_no].pwin_group;
         for ( offset = 0; (offset < WLI_MAX_WINDOWS_PER_GROUP) && !found; offset++ )
         {
            if ( win_array[offset].used )
            {
               /* find the parent of this WL window whose parent is the root window */
               parent = win_array[offset].hwin_no;
               do
               {
                  win = parent;
                  XQueryTree( display, win, &root, &parent, &children, &nchildren );

                  if ( (nchildren > 0) && children )
                  {
                     XFree( (void *) children );
                  }
               }
               while ( parent != root );

               if ( root_parent == win )
               {
                  *lwin_no = WLIwin_pack( lscreen_no, group_no, offset );
                  found = WLI_TRUE;
               }  /* end: if ( child == win ) */

            }  /* end: if ( win_array[offset].used ) */
                           
         } /* end: for offset */

      }  /* end: if ( win_group_array[group_no].pwin_group */

   }  /* end: for group_no */

   if ( ! found )
   {
      *lwin_no = WL_UNDEFINED_WINDOW;
   }

   return( WL_SUCCESS );

}  /* WLIwin_get_logical_window_from_root_parent */
#endif

/*--- WLIwin_set_active_background--------------------------------------------*/

int WLIwin_set_active_background(
   WLuint32 lwin_no,
   WLcolorref color_ref)
/*
NAME
	WLIwin_set_active_background

KEYWORD
	WL (INTERNAL)

DESCRIPTION
	This function set the active background color for a window

SYNOPSIS
	int WLIwin_set_active_background(
	   WLuint32 lwin_no,
	   WLcolorref color_ref)

PARAMETERS
	lwin_no (IN) - logical window number
	color_ref (IN) - The packed color

GLOBALS USED
        not yet

RETURN VALUES
        WL_SUCCESS
                Success

	WL_BAD_WINDOW_NUMBER
		The logical window number is invalid

HISTORY
        10/19/92 Shridar Subramanian
                Initial definition
*/
{

   WLuint16  lscreen_no = 0;
   WLuint8   group_index = 0;
   WLuint8   offset = 0;
   WLuint32  color_index = 0,new_color_index = 0;
   WLuint32  red = 0,green = 0, blue = 0;
   WLuint32  new_red = 0, new_green = 0, new_blue = 0;
   WLuint32  color_flags = 0;
   WLuint32  context_no = 0;
   int       sts;


   struct WLIcontext context;
   struct WLIwin     *temp_ptr;

   WLIwin_unpack( lwin_no, &lscreen_no, &group_index, &offset );
   if ( WLIwin_validate( lscreen_no, group_index, offset) != WL_SUCCESS )
   {
      WL_REPORT_ERROR( WL_BAD_WINDOW_NUMBER );
      return( WL_BAD_WINDOW_NUMBER );
   }

   temp_ptr = WLIscreens_arr[lscreen_no].pwin[group_index].pwin_group;
   context_no = temp_ptr[offset].context_no;
   if ( sts = WLIcontext_retrieve_entry( context_no, &context ) != WL_SUCCESS )
   {
      WL_REPORT_ERROR( sts );
      return( sts );
   }
   WLIwin_unpack_colorref( color_ref, &color_index, &red,
                          &green, &blue, &color_flags );

   if ( context.base_cmap_type == WL_CMAP_TRUE_COLOR )
   {
      if ( (color_flags & WL_COLOR_RGB) &&
         ( (red > WL_MAX_COLOR) || (green > WL_MAX_COLOR) || (blue > WL_MAX_COLOR) ) )
      {
         WL_REPORT_ERROR( WL_BAD_RGB );
         return( WL_BAD_RGB );
      }
      
      if ( (color_flags & WL_COLOR_PHYSICAL) && !( color_flags & WL_COLOR_RGB ) )
      {
         WL_REPORT_ERROR( WL_BAD_COLOR_REF );
         return( WL_BAD_COLOR_REF );
      }

      if ( color_flags & WL_COLOR_PHYSICAL )
      {
         new_red = red;
         new_green = green;
         new_blue = blue;
      }
      else
      {
         /*  Convert the logical color or the rgb values into the actual rgb  */
         /* values                                                            */
         (*context.cmap_color_to_rgb)( context_no, color_index, red, green, blue,
                                     color_flags, &new_red, &new_green, &new_blue);
      }

      temp_ptr[offset].background_red = new_red;
      temp_ptr[offset].background_green = new_green;
      temp_ptr[offset].background_blue = new_blue;
   }
   else
   {
      if ( (color_flags & WL_COLOR_PHYSICAL) && (color_flags & WL_COLOR_RGB) )
      {
         WL_REPORT_ERROR( WL_BAD_COLOR_REF );
         return( WL_BAD_COLOR_REF );
      }

      if ( color_flags & WL_COLOR_PHYSICAL )
      {
         new_color_index = color_index;
      }
      else
      {
         /*  Convert the logical color or the rgb values into the physical    */
         /* index                                                             */
         (*context.cmap_color_to_index)( context_no, color_index, red, green,
                                         blue, color_flags, &new_color_index);
      }

      temp_ptr[offset].background_color_index = new_color_index;
   }
   return( WL_SUCCESS );

} /* WLIwin_set_active_background */

/*--- WLIenumerate_windows --------------------------------------*/

int WLIenumerate_windows( 
   int (*win_func)(
      WLuint32 lwin_no,
      void *user_data ),
   void *data )

/*
NAME
   WLIenumerate_windows

KEYWORD
   WL (INTERNAL)

DESCRIPTION
   This function finds all the windows managed by WL and calls a
   caller supplied function, 'win_func', for each one. The synopsis
   of the window function is:

      int win_func(
         WLuint32 lwin_no,
         void *data )

SYNOPSIS
   int WLIenumerate_windows( 
      int (*win_func)(
         WLuint32 lwin_no,
         void *data ),
      void *data )

PARAMETERS
   win_func (IN) - the function to call for each window
   data (IN) - caller supplied data to pass to 'win_func'

GLOBALS USED
   WLIscreens_arr

RETURN VALUES
   WL_SUCCESS
      Success

   WL_BAD_PARAMETER
      'win_func' is NULL

   WL_ERROR
      The caller supplied function returned an error

HISTORY
   03/12/93  S.P. Rogers
      Intial definition, design, and implementation
*/

{
   int status;
   WLuint16 lscreen_no;
   WLuint8 group_index, offset;
   struct WLIwin_group *win_group;
   struct WLIwin *wins;

   if ( ! win_func )
   {
      WL_REPORT_ERROR( WL_BAD_PARAMETER );
      return( WL_BAD_PARAMETER );
   }

   /* loop over all of the screens */
   for ( lscreen_no = 0; lscreen_no < WL_MAX_SCREENS; lscreen_no++ )
   {
      if ( WLIscreens_arr[lscreen_no].used )
      {
         /* loop over all window groups for this screen */
         win_group = WLIscreens_arr[lscreen_no].pwin;
         for ( group_index = 0; group_index < WLI_MAX_WIN_GROUPS; group_index++ )
         {
            if ( win_group[group_index].num_entries_used > 0 )
            {
               /* loop over all windows for this group */
               wins = win_group[group_index].pwin_group;
               for ( offset = 0; offset < WLI_MAX_WINDOWS_PER_GROUP; offset++ )
               {
                  if ( wins[offset].used )
                  {
                     status = (*win_func)( WLIwin_pack( lscreen_no, group_index, offset ),
                                           data );
                     if ( status != WL_SUCCESS )
                     {
                        WL_REPORT_ERROR( status );
                        return( status );
                     }
                  }

               }  /* end: for ( offset ... */

            }

         }  /* end: for ( group_index ... */

      }

   }  /* end: for ( lscreen_no ... */

   return( WL_SUCCESS );

}  /* WLIenumerate_windows */


/*--- WLIwin_set_bounds -----------------------------------------------*/
 
int WLIwin_set_bounds(
   WLuint32 lwin_no )
 
/*
NAME
   WLIwin_set_bounds
 
KEYWORD
   WLI
 
DESCRIPTION
   This function sets the location and size of a window in the
   internal window data structures.

SYNOPSIS
   int WLIwin_set_bounds(
      WLuint32 lwin_no )
 
PARAMETERS
   lwin_no (IN) - logical window number

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
   08/25/93 S.P. Rogers
      Initial definition, design, and implementation
*/

{
   int status;
   WLuint16 lscreen_no;
   WLuint8  group_index;
   WLuint8  offset;
   struct WLIwin *temp_ptr;
   struct WLIscreen screen_struct;
#if defined( ENV5 )
   int xmin, ymin, xmax, ymax;
#elif defined (X11 )
   XWindowAttributes win_attrib;
   XWindowAttributes win_attrib1;
   Window child;
   Window root;
   Window parent;
   Window win;
   Window *children = NULL;
   unsigned int nchildren;
   int in_x, in_y;
#elif defined ( WIN32 )
   RECT rect1;
   RECT rect2;
   POINT tag1;
   POINT tag2;
#endif

   /* unpack the logical window number and access the window structure */

   WLIwin_unpack( lwin_no, &lscreen_no, &group_index, &offset );

   if ( WLIwin_validate( lscreen_no, group_index, offset ) != WL_SUCCESS )
   {
      WL_REPORT_ERROR( WL_BAD_WINDOW_NUMBER );
      return( WL_BAD_WINDOW_NUMBER );
   }
	
   temp_ptr = WLIscreens_arr[lscreen_no].pwin[group_index].pwin_group;

   status = WLIscreen_retrieve_entry( lscreen_no, &screen_struct );
   if ( status != WL_SUCCESS )
   {
      WL_REPORT_ERROR( status );
      return( status );
   }
 
#if defined ( X11 )
   XGetWindowAttributes( temp_ptr[offset].native_info.EXdisplay,
                         temp_ptr[offset].hwin_no, &win_attrib );
   status = XTranslateCoordinates( temp_ptr[offset].native_info.EXdisplay,
                                   temp_ptr[offset].hwin_no, 
                                   RootWindow( temp_ptr[offset].native_info.EXdisplay,
                                   screen_struct.native_info.screen_no ),
                                   win_attrib.x, win_attrib.y,
                                   &in_x, &in_y, &child ); 
   if ( !status )
   {
      WL_REPORT_ERROR( WL_SYSTEM_ERROR );
      return( WL_SYSTEM_ERROR );
   }

   win = temp_ptr[offset].hwin_no;
   while( 1 )
   {
      status = XQueryTree( temp_ptr[offset].native_info.EXdisplay,
                           win,
                           &root, &parent, &children, &nchildren ); 
      if ( !status )
      {
         WL_REPORT_ERROR( WL_SYSTEM_ERROR );
         return( WL_SYSTEM_ERROR );
      }
      if ( (nchildren > 0) && children )
      {
         XFree( (void *) children );
      }
      if ( parent == root )
      {
         break;
      }
      else
      {
         win = parent;
      }
   }
   
   XGetWindowAttributes( temp_ptr[offset].native_info.EXdisplay,
                         win, &win_attrib1 );

   temp_ptr[offset].area_bounds.x = in_x;
   temp_ptr[offset].area_bounds.y = in_y;
   temp_ptr[offset].area_bounds.width = win_attrib.width;
   temp_ptr[offset].area_bounds.height = win_attrib.height;

   temp_ptr[offset].bounds.x = win_attrib1.x; 
   temp_ptr[offset].bounds.y = win_attrib1.y;
   temp_ptr[offset].bounds.width = win_attrib1.width;
   temp_ptr[offset].bounds.height = win_attrib1.height;
#if defined( XGL )
   if( temp_ptr[offset].native_info.win_ras )
      xgl_window_raster_resize( temp_ptr[offset].native_info.win_ras );

   if ( temp_ptr[offset].native_info.hl_win_ras )
      xgl_window_raster_resize( temp_ptr[offset].native_info.hl_win_ras );

#endif
 
#elif defined ( ENV5 )
   if ( ( temp_ptr[offset].hwin_no != WLISRwin_no ) &&
        ( temp_ptr[offset].hwin_no >= 0 ) )
   {
      status = Inq_win_region( temp_ptr[offset].hwin_no, 
                               &xmin, &ymin, &xmax, &ymax );
      if ( status )
      {
         WL_REPORT_ERROR( WL_SYSTEM_ERROR );
         return( WL_SYSTEM_ERROR );
      }

      temp_ptr[offset].area_bounds.x = xmin;
      temp_ptr[offset].area_bounds.y = ymin;
      temp_ptr[offset].area_bounds.width =  xmax - xmin + 1;
      temp_ptr[offset].area_bounds.height = ymax - ymin + 1;
   
      temp_ptr[offset].bounds.x = xmin - WINDOW_LEFT_BORDER;
      temp_ptr[offset].bounds.y = ymin - WINDOW_TOP_BORDER; 
      temp_ptr[offset].bounds.width =  ( xmax + WINDOW_RIGHT_BORDER ) -
                                       ( xmin - WINDOW_LEFT_BORDER ) + 1;
      temp_ptr[offset].bounds.height = ( ymax + WINDOW_BOTTOM_BORDER ) - 
                                       ( ymin - WINDOW_TOP_BORDER ) + 1;  
   }

#elif defined ( WIN32 )
   status = GetWindowRect( temp_ptr[offset].hwin_no, &rect1 );
   if ( !status )
   {
      WL_REPORT_ERROR( WL_SYSTEM_ERROR );
      return( WL_SYSTEM_ERROR );
   }

   status = GetClientRect( temp_ptr[offset].hwin_no, &rect2 );
   if ( !status )
   {
      WL_REPORT_ERROR( WL_SYSTEM_ERROR );
      return( WL_SYSTEM_ERROR );
   }

   temp_ptr[offset].bounds.x = rect1.left; 
   temp_ptr[offset].bounds.y = rect1.top; 
   temp_ptr[offset].bounds.width = rect1.right - rect1.left; 
   temp_ptr[offset].bounds.height = rect1.bottom - rect1.top; 
   
   tag1.x = rect2.left;   
   tag1.y = rect2.top;   

   ClientToScreen( temp_ptr[offset].hwin_no, &tag1 );
   if ( !status )
   {
      WL_REPORT_ERROR( WL_SYSTEM_ERROR );
      return( WL_SYSTEM_ERROR );
   }

   tag2.x = rect2.right;   
   tag2.y = rect2.bottom;   

   ClientToScreen( temp_ptr[offset].hwin_no, &tag2 );
   if ( !status )
   {
      WL_REPORT_ERROR( WL_SYSTEM_ERROR );
      return( WL_SYSTEM_ERROR );

   }

   temp_ptr[offset].area_bounds.x = tag1.x; 
   temp_ptr[offset].area_bounds.y = tag1.y; 

   temp_ptr[offset].area_bounds.width = tag2.x - tag1.x;
   temp_ptr[offset].area_bounds.height = tag2.y - tag1.y;

#endif 
 
   return( WL_SUCCESS );

}  /* WLIwin_set_bounds */


/*--- WLIwin_create_db -----------------------------------------------*/

/*ARGSUSED*/
int WLIwin_create_db(
   WLuint32 lwin_no )

/*
NAME
	WLIwin_create_db 
 
KEYWORD
	WL 
 
DESCRIPTION
	This function creates double buffers in X

SYNOPSIS
	int WLIwin_create_db(
		WLuin32 lwin_no)
 
PARAMETERS
	lwin_no (IN) - logical window number

GLOBALS USED
	none
 
RETURN VALUES
	WL_SUCCESS
		Success
	
	WL_DB_NOT_POSSIBLE
		Cannot enter double buffering mode

 	WL_BAD_WINDOW_NUMBER
		The logical window number is invalid

HISTORY
	09/15/93 Shridar Subramanian
		Initial definition, design and implementation

*/

{
#if defined( X11 )
   int sts;
   struct WLIcontext       context_struct;
   struct WLIwin       *ptr_win_struct;
#if defined( XGL ) 
   int xgl_num_buffers;
#endif

   sts = WLIwin_retrieve_entry_ptr( lwin_no, &ptr_win_struct );
   if ( sts != WL_SUCCESS )
   {
      WL_REPORT_ERROR( sts );
      return( sts );
   }

   sts = WLIcontext_retrieve_entry( ptr_win_struct->context_no, 
                                    &context_struct );
   if ( sts != WL_SUCCESS )
   {
      WL_REPORT_ERROR( sts );
      return( sts );
   }

   if ( !(context_struct.flags & WL_DOUBLE_BUFFER_ABILITY ) )
   {
      return( WL_DB_NOT_POSSIBLE );
   }

 
#if defined( XGL )
   if ( ptr_win_struct->flags & WLI_WIN_FLAGS_USING_XGL )
   {
      xgl_object_get( ptr_win_struct->native_info.win_ras, 
                      XGL_WIN_RAS_BUFFERS_REQUESTED, &xgl_num_buffers );
      if ( xgl_num_buffers > 1 )
      {
         ptr_win_struct->flags = ptr_win_struct->flags |
                                 WLI_WIN_DOUBLE_BUFFER_CREATED;
         ptr_win_struct->buffer0 = WLI_TRUE;
         
      }
      else
      {
         return( WL_DB_NOT_POSSIBLE );
      }
      return( WL_SUCCESS );
   }
#endif
 
   if(!( ptr_win_struct->flags & WLI_WIN_DOUBLE_BUFFER_CREATED ))
   {
      sts = XmbufCreateBuffers( ptr_win_struct->native_info.EXdisplay,
                                ptr_win_struct->hwin_no, 2,
                                MultibufferUpdateActionUntouched,
                                MultibufferUpdateHintFrequent,
                                ptr_win_struct->double_buffer );
      ptr_win_struct->buffer0 = WLI_TRUE;
      if( sts != 2)
      {
         WL_REPORT_ERROR( sts );
         return( sts );
      }

      /* Buffer[0] will be associated with the window ID and its  */
      /* contents will not be modified.  The displayed image      */
      /* attribute will be set to buffer[0]                       */

      sts = WLIclear_double_buffer( ptr_win_struct, 
                                    ptr_win_struct->double_buffer[1] );
      if ( sts != WL_SUCCESS )
      {
         WL_REPORT_ERROR( sts );
         return( sts );
      }

      ptr_win_struct->flags = ptr_win_struct->flags |
                              WLI_WIN_DOUBLE_BUFFER_CREATED;

   }

#endif
   return( WL_SUCCESS );
} /* WLIwin_create_db */      
