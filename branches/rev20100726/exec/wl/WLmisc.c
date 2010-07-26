#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "wl.h"
#include "wl_internal.h"

#if defined (XGL)
extern int WLhilite_enabled;
#endif

#define WLI_BLENDAREA_WIDTH 8
#define WLI_BLENDAREA_HEIGHT 8

#if defined( WIN32 )
static int WLIflip_pattern_initialized = WLI_FALSE;
static WLuint8 WLIflip_pattern[256];

/*--- WLflip_pattern_initialize --------------------------------------------*/

static void WLflip_pattern_initialize(
   void )

/*
NAME
	WLflip_pattern_intialize (static)

DESCRIPTION
	This function is initializes the mapping array that is used to flip
	the bits in the bitmap pattern to conform to NT requirements. 00000001
	will be transformed to 10000000. Similarly 00001000 will become 00010000.

SYNOPSIS
	static void WLflip_pattern_initialize(
	   void )

PARAMETERS
	none

GLOBALS USED
	WLIflip_pattern_initialized, WLIflip_pattern

HISTORY
	01/18/93 Shridar Subramanian
		Initial Definition, Design, and Implementation
*/

{
   int i,j,k, temp;
   WLuint8 pat;

   WLIflip_pattern_initialized = WLI_TRUE;
   for ( i = 0; i < 256; i++ )
   {
      WLIflip_pattern[i] = 0;
   }
   for ( j = 0; j < 256; j++ )
   {
      pat = j;
      for ( i = 0; i < 8 ; i++ )
      {
         k = pat & ( 1 << ( 7 - i ) );
         if ( k )
         {
            WLIflip_pattern[pat] |= ( 1 << i );
         }
      }
      if ( pat == 128 )
         temp = WLIflip_pattern[pat];
  } 
} /* WLflip_pattern_initialize */

#endif

/*--- WLsync_buffers -----------------------------------------------*/

/*ARGSUSED*/
int WLsync_buffers(
   WLuint32 lwin_no)

/*
NAME
	WLsync_buffers
 
KEYWORD
	WL 
 
DESCRIPTION
	This function syncs the buffers with respect to the window

SYNOPSIS
	int WLsync_buffers(
		WLuint32 lwin_no)
 
PARAMETERS
	lwin_no (IN) - logical window number

GLOBALS USED
	none
 
RETURN VALUES
	WL_SUCCESS
		Success
	
	WL_BAD_WINDOW_NUMBER
		The logical window number is invalid

HISTORY
	09/13/93 Shridar Subramanian
		Initial definition, design and implementation

*/

{
#if defined( X11 )
   int sts;
   struct WLIwin       *ptr_win_struct;
   struct WLIcontext   context_struct;
   WLuint32            flags;
   WLcolorref color_ref;
   WLhwin_no src, dest1, dest2;
   XGCValues values;
#if defined( XGL )
   Xgl_bounds_i2d  rect;
   Xgl_pt_i2d     pos;
   int old_draw_buf, old_source_buf;
#endif
#if defined( OPENGL )
   GLboolean db_flag;
#endif

   

   sts = WLIwin_retrieve_entry_ptr( lwin_no, &ptr_win_struct);
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
   if ( !(  context_struct.flags & WL_DOUBLE_BUFFER_ABILITY ) )
   {
      WL_REPORT_ERROR( WL_DB_NOT_POSSIBLE );
      return( WL_DB_NOT_POSSIBLE );
   }

#  if defined( XGL )
   if (ptr_win_struct->flags & WLI_WIN_FLAGS_USING_XGL )
      {
      if ( !(ptr_win_struct->flags & WLI_WIN_DOUBLE_BUFFER_CREATED ) )
         {
         sts = WLIwin_create_db( lwin_no );
         if ( sts != WL_SUCCESS )
            {
            WL_REPORT_ERROR ( sts );
            return( sts );
            }
         }

      WLxgl_enter_2D( lwin_no, FALSE ); 
   
      pos.x = pos.y = 0;
      rect.xmin =  0;
      rect.ymin =  0;
      rect.xmax = ptr_win_struct->area_bounds.width -1;
      rect.ymax = ptr_win_struct->area_bounds.height -1;

      xgl_object_get( ptr_win_struct->native_info.win_ras,
                      XGL_RAS_SOURCE_BUFFER, &old_source_buf );

      xgl_object_get( ptr_win_struct->native_info.win_ras,
                      XGL_WIN_RAS_BUF_DRAW, &old_draw_buf );

      if ( ptr_win_struct->flags & WLI_WIN_DOUBLE_BUFFER_DISPLAYED )
         {
         if ( ptr_win_struct->buffer0 )
            {

            /* Copy from 1 to 0 */

            xgl_object_set( ptr_win_struct->native_info.win_ras,
                            XGL_RAS_SOURCE_BUFFER, 1 , NULL );

            xgl_object_set( ptr_win_struct->native_info.win_ras,
                            XGL_WIN_RAS_BUF_DRAW, 0 , NULL );

            xgl_context_copy_buffer( ptr_win_struct->native_info.xgl_context_3D,
                             &rect, &pos, ptr_win_struct->native_info.win_ras );
            }
         else
            {

            /* Copy from 0 to 1 */

            xgl_object_set( ptr_win_struct->native_info.win_ras,
                            XGL_RAS_SOURCE_BUFFER, 0 , NULL );

            xgl_object_set( ptr_win_struct->native_info.win_ras,
                            XGL_WIN_RAS_BUF_DRAW, 1 , NULL );
            }
         }
      else
         {

         /* Copy from 0 to 1 */

         xgl_object_set( ptr_win_struct->native_info.win_ras,
                         XGL_RAS_SOURCE_BUFFER, 0 , NULL );

         xgl_object_set( ptr_win_struct->native_info.win_ras,
                         XGL_WIN_RAS_BUF_DRAW, 1 , NULL );

         xgl_context_copy_buffer( ptr_win_struct->native_info.xgl_context_3D,
                          &rect, &pos, ptr_win_struct->native_info.win_ras );
         } 

      xgl_context_copy_buffer( ptr_win_struct->native_info.xgl_context_3D,
                      &rect, &pos, ptr_win_struct->native_info.win_ras );

      xgl_object_set( ptr_win_struct->native_info.win_ras,
                      XGL_RAS_SOURCE_BUFFER, old_source_buf, 0 );

      xgl_object_set( ptr_win_struct->native_info.win_ras,
                      XGL_WIN_RAS_BUF_DRAW, old_draw_buf, 0 );

      WLxgl_exit_2D( lwin_no, FALSE );

      return( WL_SUCCESS );
      }
#  endif  /* if XGL */
  

   if ( ptr_win_struct->flags & WLI_WIN_FLAGS_USING_OPENGL )
   {
#if defined( OPENGL )
      WLglx_make_window_current( lwin_no, WL_GLX_BASE_WIN );
      WLI_SETUP_OPENGL_FOR_2D( ptr_win_struct,
                               ptr_win_struct->native_info.base_in_2d );

      glPushAttrib( GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
      glReadBuffer( GL_FRONT );
      glDrawBuffer( GL_BACK );
      glDisable( GL_DEPTH_TEST );
         glIndexMask( context_struct.hilite_mask );
/*
      if ( context_struct.base_cmap_type == WL_CMAP_INDEXED )
      {
         glIndexMask( context_struct.base_mask );
      }
      else
      {
         glColorMask( GL_TRUE, GL_TRUE, GL_TRUE, GL_TRUE );
      }
*/
      glClear( GL_COLOR_BUFFER_BIT );

      glRasterPos2s( 0, ptr_win_struct->area_bounds.height - 1 );
      glCopyPixels( 0, 0, ptr_win_struct->area_bounds.width, 
                    ptr_win_struct->area_bounds.height, GL_COLOR );
      glPopAttrib( );
      glDrawBuffer( GL_FRONT );
      WLI_RESTORE_OPENGL_TO_3D( ptr_win_struct->native_info.base_in_2d);


      /*
       *  Need to sync the hilite plane if it has double buffer ability
       *  (Mike Lanier: 4/1/96)
       */

      WLglx_make_window_current( lwin_no, WL_GLX_HILITE_WIN );
      glGetBooleanv( GL_DOUBLEBUFFER, &db_flag );
      if ( db_flag )
         {
         WLI_SETUP_OPENGL_FOR_2D( ptr_win_struct,
                                  ptr_win_struct->native_info.base_in_2d );

         glPushAttrib( GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
         glReadBuffer( GL_FRONT );
         glDrawBuffer( GL_BACK );
         glDisable( GL_DEPTH_TEST );
         if ( context_struct.base_cmap_type == WL_CMAP_INDEXED )
            {
            glIndexMask( context_struct.base_mask );
            }
         else
            {
            glColorMask( GL_TRUE, GL_TRUE, GL_TRUE, GL_TRUE );
            }
         glClear( GL_COLOR_BUFFER_BIT );

         glRasterPos2s( 0, ptr_win_struct->area_bounds.height - 1 );
         glCopyPixels( 0, 0, ptr_win_struct->area_bounds.width, 
                       ptr_win_struct->area_bounds.height, GL_COLOR );
         glPopAttrib( );
         glDrawBuffer( GL_FRONT );
         WLI_RESTORE_OPENGL_TO_3D( ptr_win_struct->native_info.base_in_2d);
         }
#endif 
   }
   else
   {
      if ( !(ptr_win_struct->flags & WLI_WIN_DOUBLE_BUFFER_CREATED ) )
      {
         sts = WLIwin_create_db( lwin_no );
         if ( sts != WL_SUCCESS )
         {
            WL_REPORT_ERROR ( sts );
            return( sts );
         }
      }
      if ( ptr_win_struct->flags & WLI_WIN_DOUBLE_BUFFER_DISPLAYED )
      {
         if ( ptr_win_struct->buffer0 )
         {
            src = ptr_win_struct->double_buffer[1];
            dest1 = ptr_win_struct->hwin_no;
            dest2 = ptr_win_struct->double_buffer[0];
         }
         else
         {
            src = ptr_win_struct->double_buffer[0];
            dest1 = ptr_win_struct->hwin_no;
            dest2 = ptr_win_struct->double_buffer[1];
         }
      }
      else
      {
         src = ptr_win_struct->hwin_no;
         dest1 = ptr_win_struct->double_buffer[0];
         dest2 = ptr_win_struct->double_buffer[1];
      }
  
      XGetGCValues( ptr_win_struct->native_info.EXdisplay,
                    ptr_win_struct->native_info.EXgc,
                    GCPlaneMask, &values);

      XSetPlaneMask( ptr_win_struct->native_info.EXdisplay,
                     ptr_win_struct->native_info.EXgc,
                     AllPlanes );

      XCopyArea( ptr_win_struct->native_info.EXdisplay, 
                 src, dest1,
                 ptr_win_struct->native_info.EXgc,
                 0, 0, ptr_win_struct->bounds.width,
                 ptr_win_struct->bounds.height, 0, 0 );
      XCopyArea( ptr_win_struct->native_info.EXdisplay, 
                 src, dest2,
                 ptr_win_struct->native_info.EXgc,
                 0, 0, ptr_win_struct->bounds.width,
                 ptr_win_struct->bounds.height, 0, 0 );

      XSetPlaneMask( ptr_win_struct->native_info.EXdisplay,
                     ptr_win_struct->native_info.EXgc,
                     values.plane_mask );

   }
#endif
   return( WL_SUCCESS );
} /* WLsync_buffers */

/*--- WLenter_dynamics -----------------------------------------------*/

int WLenter_dynamics(
   WLuint32 lwin_no)

/*
NAME
	WLenter_dynamics 
 
KEYWORD
	WL 
 
DESCRIPTION
	This function enables the logical operation, XOR, for dynamics
	on all platforms except the ones that have an explicit hilight
	plane in ENV5. On these machines the hilight plane is enabled.

SYNOPSIS
	int WLenter_dynamics(
		WLuint32 lwin_no)
 
PARAMETERS
	lwin_no (IN) - logical window number

NOTES
        This function messes with the drawing modes, therefore 
        WLset_drawing_modes should be called after WLexit_dynamics.

GLOBALS USED
	none
 
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

	01/21/93 S.P Rogers
		Added OpenGL implementation
*/

{
   int sts;
   struct WLIwin       win_struct;
   struct WLIcontext   context_struct;
   WLuint32            flags;
   WLcolorref color_ref;

   sts = WLIwin_retrieve_entry( lwin_no, &win_struct);
   if ( sts != WL_SUCCESS )
   {
      WL_REPORT_ERROR( sts );
      return( sts );
   }

   sts = WLIcontext_retrieve_entry( win_struct.context_no, &context_struct );
   if ( sts != WL_SUCCESS )
   {
      WL_REPORT_ERROR( sts );
      return( sts );
   }


   if ( ! (context_struct.hilite_used & WL_HILITE_USED) )
   {
      WLpack_index_colorref( (1 << context_struct.base_depth) / 2, &color_ref, WLI_TRUE );
      WLset_active_symbology( lwin_no, color_ref, 0, 0, 0, WL_SYMB_CHANGE_COLOR );
      WLIactivate_symbology( &win_struct, &context_struct, WLI_FALSE );
   }

   flags = win_struct.flags | WLI_WIN_FLAGS_DYNAMICS_ON;

#if defined( X11 )

   if ( context_struct.hilite_used & WL_HILITE_USED )
   {
      if ( ! ( context_struct.flags & WL_SEPARATE_HILITE ) )
      {
         XSetPlaneMask( win_struct.native_info.EXdisplay, 
                        win_struct.native_info.EXgc, 
                        context_struct.hilite_mask );
#if defined( XGL )
         if ( win_struct.flags & WLI_WIN_FLAGS_USING_XGL )
         {
            xgl_object_set( win_struct.native_info.xgl_context_3D,
                         XGL_CTX_PLANE_MASK, context_struct.hilite_mask, NULL );
         }
#endif
      }
      else
      {
         XSetPlaneMask( win_struct.native_info.EXdisplay,
                        win_struct.native_info.EXgc,
                        0 );
         XSetPlaneMask( win_struct.native_info.EXdisplay,
                        win_struct.hl_native_info.hl_gc,
                        context_struct.hilite_mask );
#if defined( XGL ) || FALSE
         if ( win_struct.flags & WLI_WIN_FLAGS_USING_XGL )
         {
            xgl_object_set( win_struct.native_info.xgl_context_3D,
                            XGL_CTX_PLANE_MASK, 0, NULL );
            xgl_object_set( win_struct.native_info.hl_xgl_context_3D,
                         XGL_CTX_PLANE_MASK, context_struct.hilite_mask, NULL );
         }
#endif

      }
   }
   else
   {
      XSetFunction( win_struct.native_info.EXdisplay, 
                    win_struct.native_info.EXgc, GXxor );
   }

#elif defined( WIN32 )

   sts =  SetROP2( win_struct.native_info.hdc, R2_XORPEN );
   if ( !sts )
   {
      WL_REPORT_ERROR( WL_SYSTEM_ERROR );
      return( WL_SYSTEM_ERROR );
   }

#elif defined( ENV5 )

   if ( context_struct.hilite_used & WL_HILITE_USED )
   {
      if ( win_struct.native_info.env5_vsi_flags & VSI_HL )  
      {
         /* the screen has highlight ability */
         enabledata( win_struct.hwin_no, HIGHLIGHT_DATA, 1 );
         enabledata( win_struct.hwin_no, IMAGE_DATA, 0 );
         fgdata( win_struct.hwin_no, HIGHLIGHT_DATA, 1 );
      }
      else
      {
         /* the screen doesn't have highlight ability */
         enabledata( win_struct.hwin_no, IMAGE_DATA,
                     context_struct.hilite_mask );
         fgdata( win_struct.hwin_no, IMAGE_DATA,
                 context_struct.hilite_mask );
      }
   }
   else
   {
      /* Set the dynamics flag.   To be used mainly with Env 5. Use this to  */
      /* call either ALUlinestring or linestring                             */
      flags |= WLI_WIN_FLAGS_USE_ALU;
   }

#else
#error "A windowing system must be defined"
#endif

#if defined( OPENGL )
   if ( win_struct.flags & WLI_WIN_FLAGS_USING_OPENGL )
   {


      if ( context_struct.hilite_used & WL_HILITE_USED )
      {
         if ( !(win_struct.flags & WLI_WIN_SEPARATE_HILITE) )
         {
#if defined( X11 )
            sts = WLglx_make_window_current( lwin_no, WL_GLX_BASE_WIN );
            if ( sts != WL_SUCCESS )
            {
               WL_REPORT_ERROR( sts );
               return( sts );
            }
#endif
            glIndexMask( context_struct.hilite_mask );
         }
         else
         {
#if defined( X11 )
            sts = WLglx_make_window_current( lwin_no, WL_GLX_HILITE_WIN );
            if ( sts != WL_SUCCESS )
            {
               WL_REPORT_ERROR( sts );
               return( sts );
            }
#endif
            glIndexMask( context_struct.hilite_mask );
         }
      }
      else
      {
#if defined( X11 )
         sts = WLglx_make_window_current( lwin_no, WL_GLX_BASE_WIN );
         if ( sts != WL_SUCCESS )
         {
            WL_REPORT_ERROR( sts );
            return( sts );
         }
#endif
         if ( context_struct.base_cmap_type == WL_CMAP_INDEXED )
         {
            /* can only do XOR in indexed mode */
            glLogicOp( GL_XOR );
            glEnable( GL_LOGIC_OP );
         }
         else
         {
            /* simulate XOR by using blending to set the frame buffer */
            /* value to (1 - frame buffer value)                      */
            glBlendFunc( GL_ZERO, GL_ONE_MINUS_DST_COLOR );
            glEnable( GL_BLEND );
         }
      }
   }
#endif

   flags &= ~(WLI_WIN_FLAGS_DYNAMICS_ERASE | WLI_WIN_FLAGS_DYNAMICS_DRAW | WLI_WIN_BASE_MASK | WLI_WIN_HILITE_MASK );
   flags |= ( WLI_WIN_FLAGS_DYNAMICS_DRAW | WLI_WIN_FLAGS_BASE_NOOP |
                         WLI_WIN_FLAGS_HILITE_DRAW );

   sts = WLIwin_set_flags( lwin_no, flags );
   if ( sts != WL_SUCCESS )
   {
       WL_REPORT_ERROR( sts );
       return( sts );
   }

#if defined (OPENGL)
/*WLsync_buffers( lwin_no );*/
#endif

   return( WL_SUCCESS );
} /* WLenter_dynamics */      


/*--- WLexit_dynamics -----------------------------------------------*/

int WLexit_dynamics(
   WLuint32 lwin_no)

/*
NAME
	WLexit_dynamics 
 
KEYWORD
	WL 
 
DESCRIPTION
	This function disables the logical operation, XOR, for dynamics
	on all platforms except the ones that have an explicit hilight
	plane in ENV5. On these machines the hilight plane is disabled
	and the background planes are enabled.

SYNOPSIS
	int WLexit_dynamics(
		WLuint32 lwin_no)
 
PARAMETERS
	lwin_no (IN) - logical window number

NOTES
        WLenter_dynamics messes with the drawing modes, therefore 
        WLset_drawing_modes should be called after WLexit_dynamics.


GLOBALS USED
	none
 
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

	01/21/93 S.P Rogers
		Added OpenGL implementation
*/

{
   int sts;
   struct WLIwin win_struct;
   struct WLIcontext context_struct;
   WLuint32 flags;
   int mode = 0;

   sts = WLIwin_retrieve_entry( lwin_no, &win_struct);
   if ( sts != WL_SUCCESS )
   {
      WL_REPORT_ERROR( sts );
      return( sts );
   }

   flags = win_struct.flags;

   sts = WLIcontext_retrieve_entry( win_struct.context_no, &context_struct);
   if ( sts != WL_SUCCESS )
   {
      WL_REPORT_ERROR( sts );
      return( sts );
   }

#if defined( X11 )

   if ( context_struct.hilite_used & WL_HILITE_USED )
   {
      if ( ! ( context_struct.flags & WL_SEPARATE_HILITE ) )
      {
         XSetPlaneMask( win_struct.native_info.EXdisplay,
                        win_struct.native_info.EXgc,
                        context_struct.base_mask );
#if defined( XGL )
         if ( win_struct.flags & WLI_WIN_FLAGS_USING_XGL )
         {
            xgl_object_set( win_struct.native_info.xgl_context_3D,
                         XGL_CTX_PLANE_MASK, context_struct.base_mask, NULL );
         }
#endif
      }
      else
      {
         XSetPlaneMask( win_struct.native_info.EXdisplay,
                        win_struct.native_info.EXgc,
                        context_struct.base_mask );
         XSetPlaneMask( win_struct.native_info.EXdisplay,
                        win_struct.hl_native_info.hl_gc,
                        0 );
#if defined( XGL ) || FALSE
         if ( win_struct.flags & WLI_WIN_FLAGS_USING_XGL )
         {
            xgl_object_set( win_struct.native_info.xgl_context_3D,
                           XGL_CTX_PLANE_MASK, context_struct.base_mask, NULL );
            xgl_object_set( win_struct.native_info.hl_xgl_context_3D,
                            XGL_CTX_PLANE_MASK, 0, NULL );
         }
#endif
      }
   }
   else
   {
      XSetFunction( win_struct.native_info.EXdisplay, 
                    win_struct.native_info.EXgc, GXcopy );
   }

#elif defined( WIN32 )

   sts =  SetROP2( win_struct.native_info.hdc, R2_COPYPEN );
   if ( !sts )
   {
      WL_REPORT_ERROR( WL_SYSTEM_ERROR );
      return( WL_SYSTEM_ERROR );
   }

#elif defined( ENV5 )

   if ( context_struct.hilite_used & WL_HILITE_USED )
   {
      if ( win_struct.native_info.env5_vsi_flags & VSI_HL )  
      {
         /* the screen has highlight ability */
         enabledata( win_struct.hwin_no, IMAGE_DATA, 0xFFFFFF );
         enabledata( win_struct.hwin_no, HIGHLIGHT_DATA, 0 );
         fgdata( win_struct.hwin_no, HIGHLIGHT_DATA, 0 );
      }
      else
      {
         /* the screen doesn't have highlight ability */
         enabledata( win_struct.hwin_no, IMAGE_DATA,
                     context_struct.base_mask );
         fgdata( win_struct.hwin_no, IMAGE_DATA,
                 context_struct.base_mask );
      }
   }
   else
   {
      /* Turn off the alu flag */
      flags &= ~WLI_WIN_FLAGS_USE_ALU;
   }
#else
#error "A windowing system must be defined"
#endif

#if defined( OPENGL )
   if ( win_struct.flags & WLI_WIN_FLAGS_USING_OPENGL )
   {
#if defined( X11 )
      sts = WLglx_make_window_current( lwin_no, WL_GLX_BASE_WIN );
      if ( sts != WL_SUCCESS )
      {
         WL_REPORT_ERROR( sts );
         return( sts );
      }
#endif

      if ( context_struct.hilite_used & WL_HILITE_USED )
      {
         if ( ! (win_struct.flags & WLI_WIN_SEPARATE_HILITE) )
         {
            glIndexMask( context_struct.base_mask );
         }
      }
      else
      {
         if ( context_struct.base_cmap_type == WL_CMAP_INDEXED )
         {
            /* set the logic operation back to its default */
            glLogicOp( GL_COPY );
            glDisable( GL_LOGIC_OP );
         }
         else
         {
            /* set the blend function back to the default of copying */
            /* the incoming color directly to the frame buffer       */
            glBlendFunc( GL_ONE, GL_ZERO );
            glDisable( GL_BLEND );
         }

      }
   }
#endif

   /* Clear the dynamics flags and also clear the drawing mode bits so they */
   /* can be restored w/ their previous values.  They are cleared to get    */
   /* around the code in WLset_drawing_mode() that checks if the bits have  */
   /* changed before doing anything.                                        */
   flags &= ~(WLI_WIN_FLAGS_DYNAMICS_ON |
              WLI_WIN_FLAGS_DYNAMICS_ERASE | WLI_WIN_FLAGS_DYNAMICS_DRAW |
              WLI_WIN_BASE_MASK | WLI_WIN_HILITE_MASK);

   /* maks sure color is updated at the next drawing request */
   flags |= WLI_WIN_FLAGS_COLOR_CHANGED;

   sts = WLIwin_set_flags( lwin_no, flags );
   if ( sts != WL_SUCCESS )
   {
       WL_REPORT_ERROR( sts );
       return( sts );
   }

   /* restore the drawing mode => this will get the planes enabled properly */
   switch ( win_struct.flags & WLI_WIN_BASE_MASK )
   {
      case WLI_WIN_FLAGS_BASE_NOOP :
         mode = WL_BASE_NOOP;
         break;
      case WLI_WIN_FLAGS_BASE_DRAW :
         mode = WL_BASE_DRAW;
         break;
      case WLI_WIN_FLAGS_BASE_ERASE :
         mode = WL_BASE_ERASE;
         break;
   }

   switch ( win_struct.flags & WLI_WIN_HILITE_MASK )
   {
      case WLI_WIN_FLAGS_HILITE_NOOP :
         mode |= WL_HILITE_NOOP;
         break;
      case WLI_WIN_FLAGS_HILITE_DRAW :
         mode |= WL_HILITE_DRAW;
         break;
      case WLI_WIN_FLAGS_HILITE_ERASE :
         mode |= WL_HILITE_ERASE;
         break;
   }

   sts = WLset_drawing_mode( lwin_no, mode );
   if ( sts != WL_SUCCESS )
   {
       WL_REPORT_ERROR( sts );
       return( sts );
   }

   return( WL_SUCCESS );

} /* WLexit_dynamics */


/*--- WLset_blendarea -----------------------------------------------*/

int WLset_blendarea(
   WLuint32 lwin_no,
   WLuint8  area_pattern[8],
   int opaque_flag )

/*
NAME
	WLset_blendarea 
 
KEYWORD
	WL 
 
DESCRIPTION
	This function sets the pattern that will be used to fill rectangles and
	polygons. The default is solid. If area_pattern is NULL the pattern is
	set to solid.

SYNOPSIS
	int WLset_blendarea(
		WLuint32 lwin_no,
		WLuint8  area_pattern[8],
                int opaque_flag )
 
PARAMETERS
	lwin_no (IN) - logical window number
	area_pattern (IN) - The 8x8 pattern to be used in filling a rectangle or
                            polygon
	paque_flag (IN) - flags word indicationg an opaque pattern or a
			transparent one.

NOTES
	!!! Need description of the area pattern

GLOBALS USED
	none
 
RETURN VALUES
	WL_SUCCESS
		Success
	
	WL_BAD_WINDOW_NUMBER
		The logical window number is invalid

HISTORY
	12/17/92 Shridar Subramanian
		Initial definition

	12/17/92 Shridar Subramanian
		Initial design
*/

{
   int sts;
   struct WLIwin win_struct;
   struct WLIcontext context_struct;
   int  i, index, j;
   int  solid_flag;
   WLuint32 exp_pattern[32];
#if defined( X11 )
   Pixmap  stipple, hl_stipple;
#if defined( XGL )
   Xgl_usgn16 *xgl_pattern;
#endif
#elif defined( WIN32 )
   char pattern[16];
#endif

   solid_flag = WLI_TRUE;

   /* Check to see if the pattern is solid */
   if ( area_pattern )
   {
      for ( i = 0; i < 8; i++ )
      {
         if ( area_pattern[i] != 0xff )
         {
            solid_flag = WLI_FALSE;
            break;
         }
      }

   }

   /* make a 32x32 bit pattern */
   if ( solid_flag )
   {
      memset( exp_pattern, 0xFF, sizeof( WLuint32 ) * 32 );
   }
   else
   {
      for ( i = 0; i < WLI_BLENDAREA_WIDTH; i++ )
      {
         index = 4 * i; 
         ( (char *) exp_pattern )[index] = ( (char *) exp_pattern )[index + 1] = 
         ( (char *) exp_pattern )[index + 2] = ( (char *) exp_pattern )[index + 3] =
         area_pattern[i];
      } 

      for ( j = 1; j < 4 ; j++ )
      {
         for ( i = 0; i < WLI_BLENDAREA_HEIGHT; i++ )
         {
            exp_pattern[(j * WLI_BLENDAREA_HEIGHT ) + i ] = exp_pattern[i];
         }
      }
   }

   /* If the pattern is Solid, there is no need to do any computations */
   if ( solid_flag )
   {
      sts = WLIwin_set_blend_pattern( lwin_no, solid_flag, opaque_flag,
                                      ( WLblend_pattern ) 0, 
                                      ( WLblend_pattern ) 0, exp_pattern );
      if ( sts != WL_SUCCESS )
      {
         WL_REPORT_ERROR( sts );
         return( sts );
      }
      return( WL_SUCCESS );
   }

   sts = WLIwin_retrieve_entry( lwin_no, &win_struct );
   if ( sts != WL_SUCCESS )
   {
      WL_REPORT_ERROR( sts );
      return( sts );
   }

   sts = WLIcontext_retrieve_entry( win_struct.context_no, &context_struct );
   if ( sts != WL_SUCCESS )
   {
      WL_REPORT_ERROR( sts );
      return( sts );
   }

#if defined( X11 )
   stipple = XCreateBitmapFromData( win_struct.native_info.EXdisplay,
                win_struct.hwin_no, ( char * )area_pattern, WLI_BLENDAREA_WIDTH, WLI_BLENDAREA_HEIGHT );

   if ( !stipple )
   {
      WL_REPORT_ERROR( WL_SYSTEM_ERROR );
      return( WL_SYSTEM_ERROR );
   }

   if ( win_struct.flags & WLI_WIN_SEPARATE_HILITE )
   {
      hl_stipple = XCreateBitmapFromData( win_struct.native_info.EXdisplay,
                                          win_struct.hl_hwin_no, 
                                         ( char * )area_pattern, 
                                         WLI_BLENDAREA_WIDTH, 
                                         WLI_BLENDAREA_HEIGHT );

      if ( !hl_stipple )
      {
         WL_REPORT_ERROR( WL_SYSTEM_ERROR );
         return( WL_SYSTEM_ERROR );
      }
   }
   else
   {
      hl_stipple = 0;
   }
   sts = WLIwin_set_blend_pattern( lwin_no, solid_flag, opaque_flag, stipple,
                                   hl_stipple, exp_pattern );
   if ( sts != WL_SUCCESS )
   {
      WL_REPORT_ERROR( sts );
      return( sts );
   }
#if defined( XGL )
   if ( win_struct.flags & WLI_WIN_FLAGS_USING_XGL )
   {
      xgl_object_set( win_struct.native_info.mem_ras, 
                      XGL_RAS_HEIGHT, 16 /*WLI_BLENDAREA_HEIGHT*/, 
                      XGL_RAS_WIDTH, 16 /*WLI_BLENDAREA_WIDTH*/, 
                      XGL_RAS_DEPTH, 1,  NULL );
      xgl_object_get( win_struct.native_info.mem_ras, 
                      XGL_MEM_RAS_IMAGE_BUFFER_ADDR, &xgl_pattern );

      for ( i = 0; i < 8; i++ )
      {
         xgl_pattern[i] = area_pattern[i] | area_pattern[i] << 8;
         xgl_pattern[i+8] = area_pattern[i] | area_pattern[i] << 8;
      }

   /*
      if ( win_struct.flags & WLI_WIN_SEPARATE_HILITE )
      {
         xgl_object_set( win_struct.native_info.hl_mem_ras, 
                         XGL_RAS_HEIGHT, 16, 
                         XGL_RAS_WIDTH, 16 
                         XGL_RAS_DEPTH, 1,  NULL );
         xgl_object_get( win_struct.native_info.hl_mem_ras, 
                         XGL_MEM_RAS_IMAGE_BUFFER_ADDR, &xgl_pattern );
         for ( i = 0; i < 8; i++ )
         {
            xgl_pattern[i] = area_pattern[i] | area_pattern[i] << 8;
            xgl_pattern[i+8] = area_pattern[i] | area_pattern[i] << 8;
         }
      }
   */
   }
#endif
   
#elif defined( ENV5 )
 
   sts = WLIwin_set_blend_pattern( lwin_no, solid_flag, opaque_flag, (long *)exp_pattern, (long * ) NULL, exp_pattern );
   if ( sts != WL_SUCCESS )
   {
      WL_REPORT_ERROR( sts );
      return( sts );
   }

#elif defined( WIN32 )

   /* The data for the bitmap must be padded so that */
   /* each line consists of an even number of bytes  */
   for ( i = 0; i < 8 ; i++ )
   {
      pattern[i*2] = ~area_pattern[i];
      pattern[i*2+1] = 0;  /* pad byte */
   } 

   sts = WLIwin_set_blend_pattern( lwin_no, solid_flag, opaque_flag, pattern, 0, exp_pattern );
   if ( sts != WL_SUCCESS )
   {
      WL_REPORT_ERROR( sts );
      return( sts );
   }

#else
#error "A windowing system must be defined"
#endif

    return( WL_SUCCESS );
} /*  WLset_blendarea */
 
/*--- WLflush ---------------------------------------------*/
 
int WLflush(
   WLuint32 lwin_no )
 
/*
NAME
   WLflush
 
KEYWORD
   WL
 
DESCRIPTION
   This function flushes the graphics pipeline for a window.

SYNOPSIS
   int WLflush(
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
 
HISTORY
   08/28/92 Shridar Subramanian
      Initial definition
 
   10/22/92 Shridar Subramanian
      Initial design

   12/04/92 Ravi Parthasarathy
      Implementation
*/
 
 
{
   WLint32 sts;
   struct WLIwin win_struct;
 
   sts = WLIwin_retrieve_entry( lwin_no, &win_struct );
   if ( sts != WL_SUCCESS)
   {
      WL_REPORT_ERROR( sts );
      return( sts );
   }
 
#if defined( X11 )
   XSync( win_struct.native_info.EXdisplay, False );
#if defined( XGL )
   if( win_struct.flags & WLI_WIN_FLAGS_USING_XGL )
   {
      xgl_context_flush (win_struct.native_info.xgl_context_3D, 
                      XGL_FLUSH_BUFFERS);

      if( WLhilite_enabled )
      if( win_struct.native_info.hl_xgl_context_3D )
      {     
         xgl_context_flush (win_struct.native_info.hl_xgl_context_3D, 
                            XGL_FLUSH_BUFFERS);
      }
   }

#endif
#elif defined( ENV5 )
   flushbuffer( win_struct.hwin_no );
#elif defined( WIN32 )
   if ( !GdiFlush() )
   {
      WL_REPORT_ERROR( WL_SYSTEM_ERROR );
      return( WL_SYSTEM_ERROR );
   }
#else
#error " A windowing system must be defined"
#endif

#if defined( OPENGL )
   if ( win_struct.flags & WLI_WIN_FLAGS_USING_OPENGL )
   {
       /* Do nothing as too many context switches occur */
       return( WL_SUCCESS );
   }
#endif

   return( WL_SUCCESS );

} /* WLflush */

/*--- WLfree -----------------------------------------------*/
 
int WLfree(
   void *ptr )
 
/*
NAME
   WLfree
 
KEYWORD
   WL
 
DESCRIPTION
   This function frees the memory allocated by a WL function.

SYNOPSIS
   int WLfree(
        void *ptr )
 
PARAMETERS
   ptr (IN) - The pointer to be freed.
 
GLOBALS USED
   not yet
 
RETURN VALUES
   WL_SUCCESS
	Success
 
   WL_BAD_PARAMETER
	'ptr' is NULL

HISTORY
   08/28/92 Shridar Subramanian
         Initial definition
 
   10/22/92 Shridar Subramanian
      Initial design
*/
{
   if ( ptr == NULL )
   {
       WL_REPORT_ERROR( WL_BAD_PARAMETER );
       return( WL_BAD_PARAMETER );
   }
 
   free( ptr );
   return( WL_SUCCESS );
} /* WLfree */

 
/*--- WLbell ------------------------------------------------*/
 
int WLbell(
   WLuint32 lwin_no,
   int percent )
 
/*
NAME
   WLbell
 
KEYWORD
   WL
 
DESCRIPTION
   This function sounds a bell

SYNOPSIS
   int WLbell(
      WLuint32 lwin_no,
      int percent )
 
PARAMETERS
   lwin_no (IN) - logical window number
   percent (IN) - Specifies the volume/tone for the bell
 
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
   struct WLIwin win_struct;
 
   status = WLIwin_retrieve_entry( lwin_no, &win_struct );
   if ( status != WL_SUCCESS )
   {
      WL_REPORT_ERROR( status );
      return ( status );
   }
 
#if defined (X11)
   XBell( win_struct.native_info.EXdisplay, percent );
 
#elif defined (ENV5)
 
   status = Keybdbell( percent );
   if ( status )
   {
      WL_REPORT_ERROR( WL_SYSTEM_ERROR );
      return( status );
   }
 
#elif defined (WIN32)
   status = MessageBeep(-1);
   if ( ! status )
   {
      WL_REPORT_ERROR( WL_SYSTEM_ERROR );
      return( WL_SYSTEM_ERROR );
   }
#endif

   return( WL_SUCCESS );
}  /* WLbell */


/*--- WLset_active_screen -------------------------------------------*/

int WLset_active_screen(
	WLuint16 lscreen_no )
/*
NAME
	WLset_active_screen
 
KEYWORD
	WL

DESCRIPTION
	This function sets the active screen

SYNOPSIS
	int WLset_active_screen(
		WLuint16 lscreen_no )

PARAMETERS
	lscreen_no (IN) - logical screen number

GLOBALS USED
	not yet

RETURN VALUES
	WL_SUCCESS
		Success

	WL_BAD_SCREEN
		The logical screen number is invalid

HISTORY
	08/28/92 Shridar Subramanian
		Initial definition

	10/22/92 Shridar Subramanian
		Initial design
*/
{

   int sts;

   sts = WLIscreen_validate( lscreen_no );
   if ( sts != WL_SUCCESS )
   {
      WL_REPORT_ERROR( sts );
      return( sts );
   }
   WLIactive_screen = lscreen_no;
   return( WL_SUCCESS );
} /* WLset_active_screen */

/*--- WLdraw_bitmap -------------------------------------------*/

int WLdraw_bitmap(
   WLuint32 lwin_no,
   int x_org,
   int y_org,
   int width,
   int height,
   unsigned char *bitmap )
/*
NAME
	WLdraw_bitmap
 
KEYWORD
	WL

DESCRIPTION
	This function draws the bitmap in the specified window 

SYNOPSIS
	int WLdraw_bitmap(
   		WLuint32 lwin_no,
   		int x_org,
   		int y_org,
   		int width,
   		int height,
   		char *bitmap )

PARAMETERS
	lscreen_no (IN) - logical screen number
	x_org (IN) - Specifies the corordinates where the left corner of the 
			bitmap is drawn
	y_org (IN) - Specifies the corordinates where the left corner of the 
			bitmap is drawn
	width (IN) - The width of the bitmap
	height (IN) - The height of the bitmap
	bitmap (IN) - The bitmap to be drawn

NOTES
	!!! Need description of the bitmap format

GLOBALS USED
	not yet

RETURN VALUES
	WL_SUCCESS
		Success

	WL_BAD_WINDOW
		The logical window number is invalid

HISTORY
	01/05/93 Shridar Subramanian
		Initial definition

	01/05/93 Shridar Subramanian
		Initial design
*/
{

   int sts;
   WLuint32 context_no;
   struct WLIwin *win_struct;
   struct WLIcontext *context_struct;
#if defined( X11 )
   int solid_flag, opaque_flag;
   XGCValues old_gc_val;
   XGCValues hl_old_gc_val;
   Pixmap    xpixmap;
   Pixmap    hl_xpixmap;
   struct WLrect rect;
   WLuint32 old_win_flags, old_exp_pattern[32];
   WLblend_pattern old_blend_pattern, old_hl_blend_pattern;
#elif defined( ENV5 )
   WLuint32 planes;
#elif defined( WIN32 )
   HBITMAP bmap, old_bmap;
   int old_colorref;
   int cplanes;
   HDC memdc;
   char *new_bitmap;
   int new_width;
   int index1, index2;
   int i,j;
#endif
#if defined( OPENGL )
   GLint gl_unpack_alignment, gl_unpack_lsb_first;
   int bytes_per_line, ii;
   unsigned char *bitmap_ptr;
#endif
   
   context_no = WL_DEFAULT_CONTEXT;
   sts = WLIestablish_lwin_and_context( &lwin_no, &context_no, &win_struct, &context_struct );
   if ( sts != WL_SUCCESS )
   {
      WL_REPORT_ERROR( sts );
      return ( sts );
   }

#if defined( OPENGL )
   if ( win_struct->flags & WLI_WIN_FLAGS_USING_OPENGL )
   {
      /* only need to activate symbology for OpenGL */
      WLIactivate_symbology( win_struct, context_struct, WLI_FALSE );

      bytes_per_line = (width + 7) / 8;

      if ( WLI_DRAW_OVERLAY_WINDOW( win_struct ) )
      {
         WLI_SETUP_OPENGL_FOR_2D( win_struct,
                                  win_struct->native_info.hilite_in_2d );

         glGetIntegerv( GL_UNPACK_ALIGNMENT, &gl_unpack_alignment );
         glGetIntegerv( GL_UNPACK_LSB_FIRST, &gl_unpack_lsb_first );
         glPixelStorei( GL_UNPACK_ALIGNMENT, 1 );
         glPixelStorei( GL_UNPACK_LSB_FIRST, TRUE );

         bitmap_ptr = bitmap;
         glRasterPos2s( x_org, y_org );
         for ( ii = 0; ii < height; ii++ )
         {
            glBitmap( width, 1, 0.0, ii, 0.0, 0.0, (const GLubyte *) bitmap_ptr );
            bitmap_ptr += bytes_per_line;
         }

         glPixelStorei( GL_UNPACK_ALIGNMENT, gl_unpack_alignment );
         glPixelStorei( GL_UNPACK_LSB_FIRST, gl_unpack_lsb_first );

         WLI_RESTORE_OPENGL_TO_3D( win_struct->native_info.hilite_in_2d);
      
      }

      if ( WLI_DRAW_BASE_WINDOW( win_struct ) )
      {
         WLI_SETUP_OPENGL_FOR_2D( win_struct,
                                  win_struct->native_info.base_in_2d );

         glGetIntegerv( GL_UNPACK_ALIGNMENT, &gl_unpack_alignment );
         glGetIntegerv( GL_UNPACK_LSB_FIRST, &gl_unpack_lsb_first );
         glPixelStorei( GL_UNPACK_ALIGNMENT, 1 );
         glPixelStorei( GL_UNPACK_LSB_FIRST, TRUE );

         bitmap_ptr = bitmap;
         glRasterPos2s( x_org, y_org );
         for ( ii = 0; ii < height; ii++ )
         {
            glBitmap( width, 1, 0.0, ii, 0.0, 0.0, (const GLubyte *) bitmap_ptr );
            bitmap_ptr += bytes_per_line;
         }

         glPixelStorei( GL_UNPACK_ALIGNMENT, gl_unpack_alignment );
         glPixelStorei( GL_UNPACK_LSB_FIRST, gl_unpack_lsb_first );

         WLI_RESTORE_OPENGL_TO_3D( win_struct->native_info.base_in_2d);
      }
      return( WL_SUCCESS );
   }
#endif

#if defined( X11 )
   /* As drawbitmap is a one time operation and not a continuous state, save  */
   /* the old values and restore them when done                               */

   sts = XGetGCValues( win_struct->native_info.EXdisplay,
                       win_struct->native_info.EXgc,
                       GCTileStipXOrigin | GCTileStipYOrigin, &old_gc_val );
   if ( sts == 0 )
   {
      WL_REPORT_ERROR( WL_SYSTEM_ERROR );
      return( WL_SYSTEM_ERROR );
   }

   old_win_flags = win_struct->flags;
   old_blend_pattern = win_struct->blend_pattern;
   old_hl_blend_pattern = win_struct->hl_blend_pattern;
   memcpy( old_exp_pattern, win_struct->exp_pattern, 32 * sizeof( WLuint32 ) );
   
   if ( win_struct->flags & WLI_WIN_SEPARATE_HILITE )
   {
      sts = XGetGCValues( win_struct->native_info.EXdisplay,
                          win_struct->hl_native_info.hl_gc,
                          GCTileStipXOrigin | GCTileStipYOrigin, &hl_old_gc_val );
   }

   xpixmap = XCreateBitmapFromData( win_struct->native_info.EXdisplay,
                                    win_struct->hwin_no, (char *)bitmap, width, height ); 
  
   if ( !xpixmap )
   {
      WL_REPORT_ERROR( WL_SYSTEM_ERROR );
      return( WL_SYSTEM_ERROR );
   }

   if ( win_struct->flags & WLI_WIN_SEPARATE_HILITE )
   {
      hl_xpixmap = XCreateBitmapFromData( win_struct->native_info.EXdisplay,
                                          win_struct->hl_hwin_no, 
                                          (char *)bitmap, width, height );
      if ( !hl_xpixmap )
      {
         WL_REPORT_ERROR( WL_SYSTEM_ERROR );
         return( WL_SYSTEM_ERROR );
      }
   }
   else
   {
      hl_xpixmap = 0;
   }
  
 
   /* Set the pixmap values in the GC */
   WLIwin_set_blend_pattern( lwin_no, WLI_FALSE, WLI_FALSE, xpixmap, 
                             hl_xpixmap, NULL );
   rect.x = x_org;
   rect.y = y_org;
   rect.width = width;
   rect.height = height ;
 
   /* Draw the bitmap */
   XSetTSOrigin( win_struct->native_info.EXdisplay,win_struct->native_info.EXgc,
                 x_org, y_org );

   if ( win_struct->flags & WLI_WIN_SEPARATE_HILITE )
   {
      XSetTSOrigin( win_struct->native_info.EXdisplay,
                    win_struct->hl_native_info.hl_gc,
                    x_org, y_org );
   }

   sts = WLdraw_rectangle( lwin_no, &rect, WL_FILL );
   if ( sts != WL_SUCCESS )
   {
      WL_REPORT_ERROR( sts );
      return( sts );
   }
  
 
   /* Restore the values */
   if (old_win_flags & WLI_WIN_FLAGS_B_PATTERN_SOLID )
   {
      solid_flag = WLI_TRUE;
   }
   else
   {
      solid_flag = WLI_FALSE;
   }
  
   if ( old_win_flags & WLI_WIN_FLAGS_B_PATTERN_OPAQUE )
   {
      opaque_flag = WLI_TRUE;
   }
   else
   {
      opaque_flag = WLI_FALSE;
   }

   sts = WLIwin_set_blend_pattern( lwin_no, solid_flag, opaque_flag, 
                                   old_blend_pattern, 
                                   old_hl_blend_pattern,
                                   old_exp_pattern );
   if ( sts != WL_SUCCESS )
   {
      WL_REPORT_ERROR( sts );
      return( sts );
   }

   /* free the pixmaps that were created */
   XFreePixmap( win_struct->native_info.EXdisplay, xpixmap );
   if ( hl_xpixmap != 0 )
   {
      XFreePixmap( win_struct->native_info.EXdisplay, hl_xpixmap );
   }
   
   XSetTSOrigin( win_struct->native_info.EXdisplay,
                 win_struct->native_info.EXgc,
                 old_gc_val.ts_x_origin, old_gc_val.ts_y_origin );

   if ( win_struct->flags & WLI_WIN_SEPARATE_HILITE )
   {
      XSetTSOrigin( win_struct->native_info.EXdisplay,
                    win_struct->hl_native_info.hl_gc,
                    hl_old_gc_val.ts_x_origin, hl_old_gc_val.ts_y_origin );
   }

#elif defined( ENV5 )
   if ( ( context_struct->hilite_used ) && 
        ( win_struct->flags & WLI_WIN_FLAGS_DYNAMICS_ON ) )
   {
      planes = context_struct->hilite_mask;
   }
   else
   {
      planes = 0;
      if ( (win_struct->flags & WLI_WIN_BASE_MASK) != WLI_WIN_FLAGS_BASE_NOOP )
      {
         planes = context_struct->base_mask;
      }
      if ( (win_struct->flags & WLI_WIN_HILITE_MASK) != 
                                                WLI_WIN_FLAGS_HILITE_NOOP )
      {
         planes |= context_struct->hilite_mask;
      }
   }
    
   sts = WLIactivate_symbology( win_struct, context_struct, WLI_TRUE );
   if ( sts != WL_SUCCESS )
   {
      WL_REPORT_ERROR( sts );
      return( sts );
   }

   drawbitmap(win_struct->hwin_no, planes, x_org, y_org, x_org + width -1,
              y_org + height - 1,bitmap);
#elif defined( WIN32 )

   /* Initialize the static flip_pattern */
   if ( !WLIflip_pattern_initialized )
   {
      WLflip_pattern_initialize();
   }

   /* Save the old values */
   old_colorref = GetBkColor( win_struct->native_info.hdc );
   SetBkColor( win_struct->native_info.hdc, PALETTEINDEX( 0 ) );
   WLIactivate_symbology( win_struct, context_struct, WLI_FALSE );

   /* In NT the bitmap should have an even number of bytes for the width */
   new_width = ( width + 7 ) / 8; 
   if ( new_width % 2 )
   {
      new_width++;
   }
   new_bitmap = ( char * )malloc( new_width * height );
  
   /* Copy the old bitmap into the new format and add the appropriate  */
   /* padding                                                          */
   
   index1 = index2 = 0;
   for ( j = 0; j < height; j++ )
   {
      for( i = 0; i < ( width + 7 ) / 8; i++ )
      {
         new_bitmap[index1] = ~WLIflip_pattern[bitmap[index2]];

         index1++;
         index2++;
      }

      /* Add the padding */
      for ( i = ( width + 7 ) / 8; i < new_width; i++)
      {
         new_bitmap[index1] = 0; 
         index1++;
      }
   }

   /* Create bitmaps and dcs */
   memdc = CreateCompatibleDC( win_struct->native_info.hdc );
   bmap = CreateBitmap ( width, height, 1, 1, new_bitmap );
   WLI_FREE( new_bitmap );
 
   if ( ( !memdc ) || ( !bmap ) )
   {
      SetBkColor( win_struct->native_info.hdc, old_colorref );
      if ( memdc )
      {
         DeleteDC( memdc );
      }
      if ( bmap )
      {
          DeleteObject( bmap );
      }
      WL_REPORT_ERROR( WL_SYSTEM_ERROR );
      return( WL_SYSTEM_ERROR );
   }

   /* Save the old values */
   old_bmap = SelectObject( memdc, bmap );

   /* The ROP code 0xE20746L comes from Petzold's book, pg. 632 */
   /* It corresponds to:  ( (Dest ^ Pattern) & Source ) ^ Dest  */
   /* or in English: 0 bits in the bitmap (i.e., the Source)    */
   /* dont affect anything; 1 bits in the bitmap affect the     */
   /* destination only if the pattern (i.e., the current brush) */
   /* is also a 1.                                              */
   BitBlt( win_struct->native_info.hdc, x_org, y_org, width, height,
           memdc, 0, 0, 0xE20746L );

   /* Restore the old values */
   SetBkColor( win_struct->native_info.hdc, old_colorref );
   DeleteDC( memdc );
   DeleteObject( bmap );
  
#else
#error "A windowing system must be defined"
#endif

   return( WL_SUCCESS );
} /*  WLdraw_bitmap */

/*--- WLset_dynamics_drawing_mode -------------------------------------------*/

int WLset_dynamics_drawing_mode(
   WLuint32 lwin_no,
   int mode )
/*
NAME
	WLset_dynamics_drawing_mode
 
KEYWORD
	WL

DESCRIPTION
	This function sets the dynamics drawing mode

SYNOPSIS
	int WLset_dynamics_drawing_mode(
   		WLuint32 lwin_no,
   		int mode )

PARAMETERS
	lwin_no (IN) - logical window number
	mode (IN) - Specifies the dynamics drawing mode. Values are 
			 WL_DYN_DRAW_MODE or WL_DYN_ERASE_MODE

GLOBALS USED
	not yet

RETURN VALUES
	WL_SUCCESS
		Success

	WL_BAD_WINDOW
		The logical window number is invalid

	WL_NOT_IN_DYNAMICS
		The window is not in dynamics

HISTORY
	01/05/93 Shridar Subramanian
		Initial definition

	01/05/93 Shridar Subramanian
		Initial design

	02/05/93 S.P. Rogers
		Implemented
*/
{
   int sts;
   struct WLIwin win_struct;
   struct WLIcontext context_struct;

   sts = WLIwin_retrieve_entry( lwin_no, &win_struct );
   if ( sts != WL_SUCCESS )
   {
      WL_REPORT_ERROR( sts );
      return( sts );
   }
  
   if ( !(win_struct.flags & WLI_WIN_FLAGS_DYNAMICS_ON) )
   {
      WL_REPORT_ERROR( WL_NOT_IN_DYNAMICS );
      return( WL_NOT_IN_DYNAMICS );
   }

   sts = WLIcontext_retrieve_entry( win_struct.context_no, &context_struct );
   if ( sts != WL_SUCCESS )
   {
      WL_REPORT_ERROR( sts );
      return( sts );
   }
  
   if ( context_struct.hilite_used )
   {
      (*win_struct.set_dynamics_drawing_mode)( &win_struct, &context_struct, mode );
   }

   win_struct.flags &= ~(WLI_WIN_FLAGS_DYNAMICS_ERASE | WLI_WIN_FLAGS_DYNAMICS_DRAW);
   if ( mode == WL_DYN_ERASE_MODE )
   {
      win_struct.flags |= WLI_WIN_FLAGS_DYNAMICS_ERASE;
   }
   else
   {
      win_struct.flags |= WLI_WIN_FLAGS_DYNAMICS_DRAW;
   }
#if defined( XGL )
   win_struct.flags |= WLI_WIN_FLAGS_COLOR_CHANGED;
#endif

   sts = WLIwin_set_flags( lwin_no, win_struct.flags );
   if ( sts != WL_SUCCESS )
   {
      WL_REPORT_ERROR( sts );
      return( sts );
   }

   return( WL_SUCCESS );

} /*  WLset_dynamics_drawing_mode */

/*--- WLenter_db -----------------------------------------------*/

int WLenter_db(
   WLuint32 lwin_no )

/*
NAME
	WLenter_db 
 
KEYWORD
	WL 
 
DESCRIPTION
	This function enters double buffering mode only on systems where
	available.
        In ENV5 the first WLenter_db for that particular screen is the only
        one that takes effect

SYNOPSIS
	int WLenter_db(
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
	01/05/93 Shridar Subramanian
		Initial definition

	01/05/93 Shridar Subramanian
		Initial design

	01/21/93 S.P Rogers
		Added OpenGL implementation
*/

{
   int sts;
   struct WLIwin       win_struct;
   struct WLIcontext       context_struct;
   
#if defined( ENV5 )
   struct WLIscreen  screen_struct;
#endif

#if defined( X11 )
   int event_base, error_base, x,y;
   unsigned int width, height, border, depth;
   struct WLIwin       *ptr_win_struct;
   Window root;
   WLhwin_no tmp_win_no;
   XGCValues values;
   int fgcolor;
   int left_shift_factor, right_shift_factor, red, green, blue;
#endif
#if defined( OPENGL )
   GLboolean flag;
#endif

   sts = WLIwin_retrieve_entry( lwin_no, &win_struct );
   if ( sts != WL_SUCCESS )
   {
      WL_REPORT_ERROR( sts );
      return( sts );
   }

   sts = WLIcontext_retrieve_entry( win_struct.context_no, &context_struct );
   if ( sts != WL_SUCCESS )
   {
      WL_REPORT_ERROR( sts );
      return( sts );
   }

   if ( !(context_struct.flags & WL_DOUBLE_BUFFER_ABILITY ) )
   {
      return( WL_DB_NOT_POSSIBLE );
   }

#if defined( ENV5 )
   /* Enable db only once per screen */
   sts = WLIscreen_retrieve_entry( win_struct.lscreen_no, &screen_struct );
   if ( sts != WL_SUCCESS )
   {
      WL_REPORT_ERROR( sts );
      return( sts );
   }
   if ( screen_struct.db_count == 0 )
   {
      enter_db( win_struct.native_info.screen_no, 0 );
   }
   screen_struct.db_count++;
   sts = WLIscreen_set_db_count( win_struct.lscreen_no, 
                                 screen_struct.db_count );
#elif defined( X11 )
#if defined( XGL )
   sts = WLIwin_retrieve_entry_ptr( lwin_no, &ptr_win_struct );
   if ( sts != WL_SUCCESS )
   {
      WL_REPORT_ERROR( sts );
      return( sts );
   }
   if ( ptr_win_struct->flags & WLI_WIN_FLAGS_USING_XGL )
   {
      if(!( ptr_win_struct->flags & WLI_WIN_DOUBLE_BUFFER_CREATED ))
      {
         sts = WLIwin_create_db( lwin_no );
         if ( sts != WL_SUCCESS )
         {
            WL_REPORT_ERROR ( sts );
            return( sts );
         }
      }
      if( ptr_win_struct->buffer0 )
      {
         xgl_object_set( ptr_win_struct->native_info.win_ras,
                         XGL_WIN_RAS_BUF_DRAW, 1, NULL );
      }
      else if(  ptr_win_struct->buffer1 )
      {
         xgl_object_set( ptr_win_struct->native_info.win_ras,
                         XGL_WIN_RAS_BUF_DRAW, 0, NULL );
   
      }
      ptr_win_struct->flags = ptr_win_struct->flags |
                              WLI_WIN_DOUBLE_BUFFER_DISPLAYED;
      return( WL_SUCCESS );
   }
#endif

   
   if ( !(win_struct.flags & WLI_WIN_FLAGS_USING_OPENGL ) )
   {
      sts = WLIwin_retrieve_entry_ptr( lwin_no, &ptr_win_struct );
      if ( sts != WL_SUCCESS )
      {
         WL_REPORT_ERROR( sts );
         return( sts );
      }
 
 
      if(!( ptr_win_struct->flags & WLI_WIN_DOUBLE_BUFFER_CREATED ))
      {
         sts = WLIwin_create_db( lwin_no );
         if ( sts != WL_SUCCESS )
         {
            WL_REPORT_ERROR ( sts );
            return( sts );
         }
      }
 
      if( ptr_win_struct->buffer0 )
      {
         tmp_win_no = ptr_win_struct->hwin_no;
         ptr_win_struct->hwin_no = ptr_win_struct->double_buffer[1];
         ptr_win_struct->double_buffer[1] = tmp_win_no;
      }
      else if(  ptr_win_struct->buffer1 )
      {
         tmp_win_no = ptr_win_struct->hwin_no;
         ptr_win_struct->hwin_no = ptr_win_struct->double_buffer[0];
         ptr_win_struct->double_buffer[0] = tmp_win_no;

      }
      ptr_win_struct->flags = ptr_win_struct->flags |
                              WLI_WIN_DOUBLE_BUFFER_DISPLAYED;
   }
 
#endif
#if defined( OPENGL )
   if ( win_struct.flags & WLI_WIN_FLAGS_USING_OPENGL )
   {
#if defined( X11 )
      sts = WLglx_make_window_current( lwin_no, WL_GLX_BASE_WIN );
      if ( sts != WL_SUCCESS )
      {
         WL_REPORT_ERROR( sts );
         return( sts );
      }
#endif

      glGetBooleanv( GL_DOUBLEBUFFER, &flag );
      if ( flag )
      {
         glDrawBuffer( GL_BACK );
      
         if ( context_struct.base_cmap_type == WL_CMAP_INDEXED )
         {
            if ( ( win_struct.flags & WLI_WIN_BASE_MASK ) ==
                                      WLI_WIN_FLAGS_BASE_NOOP )
            { 
               glIndexMask( 0 );
            } 
            else 
            { 
               glIndexMask( context_struct.base_mask );
            } 
         }
         else
         {
            if ( ( win_struct.flags & WLI_WIN_BASE_MASK ) ==
                                      WLI_WIN_FLAGS_BASE_NOOP )
            { 
               glColorMask( GL_FALSE, GL_FALSE, GL_FALSE, GL_FALSE );
            } 
            else 
            { 
               glColorMask( GL_TRUE, GL_TRUE, GL_TRUE, GL_TRUE );
            } 
         }
 
      }

#if defined( X11 )
      if ( win_struct.flags & WLI_WIN_SEPARATE_HILITE )
      {
         sts = WLglx_make_window_current( lwin_no, WL_GLX_HILITE_WIN );
         if ( sts != WL_SUCCESS )
         {
            WL_REPORT_ERROR( sts );
            return( sts );
         }

         glGetBooleanv( GL_DOUBLEBUFFER, &flag );
flag = 0;
         if ( flag )
         {
            glDrawBuffer( GL_BACK );
            if ( ( win_struct.flags & WLI_WIN_HILITE_MASK ) ==
                                      WLI_WIN_FLAGS_HILITE_NOOP )
            { 
               glIndexMask( 0 );
            } 
            else 
            { 
               glIndexMask( context_struct.base_mask );
            } 
         }
      }
#endif
   }
#endif

   return( WL_SUCCESS );
} /* WLenter_db */      

/*--- WLexit_db -----------------------------------------------*/

int WLexit_db(
   WLuint32 lwin_no )

/*
NAME
	WLexit_db 
 
KEYWORD
	WL 
 
DESCRIPTION
	This function exits double buffering mode only on systems where
	available.

SYNOPSIS
	int WLexit_db(
   		WLuint32 lwin_no)
 
PARAMETERS

GLOBALS USED
	none
 
RETURN VALUES
	WL_SUCCESS
		Success
	
	WL_DB_NOT_POSSIBLE
		Cannot exit double buffering mode

 	WL_BAD_WINDOW_NUMBER
		The logical window number is invalid

HISTORY
	01/05/93 Shridar Subramanian
		Initial definition

	01/05/93 Shridar Subramanian
		Initial design

	01/21/93 S.P Rogers
		Added OpenGL implementation
*/

{
   int sts;
   struct WLIwin       win_struct;
   struct WLIcontext       context_struct;

#if defined( ENV5 )
   struct WLIscreen    screen_struct;
#endif
#if defined( X11 )
   struct WLIwin   *ptr_win_struct;
   int event_base, error_base;
   WLhwin_no tmp_win_no;
#endif
#if defined( OPENGL )
   GLboolean flag;
#endif

   sts = WLIwin_retrieve_entry( lwin_no, &win_struct );
   if ( sts != WL_SUCCESS )
   {
      WL_REPORT_ERROR( sts );
      return( sts );
   }
   sts = WLIcontext_retrieve_entry( win_struct.context_no, &context_struct );
   if ( sts != WL_SUCCESS )
   {
      WL_REPORT_ERROR( sts );
      return( sts );
   }

   if ( !(context_struct.flags & WL_DOUBLE_BUFFER_ABILITY ) )
   {
      return( WL_DB_NOT_POSSIBLE );
   }

#if defined( ENV5 )
   sts = WLIscreen_retrieve_entry( win_struct.lscreen_no, &screen_struct );
   if ( sts != WL_SUCCESS )
   {
      WL_REPORT_ERROR( sts );
      return( sts );
   }

   if ( screen_struct.db_count == 1 )
   {
      exit_db( win_struct.native_info.screen_no, 0 );
   }

   screen_struct.db_count--;
   if( screen_struct.db_count < 0 )
   {
      screen_struct.db_count = 0;
   }
   sts = WLIscreen_set_db_count( win_struct.lscreen_no, 
                                 screen_struct.db_count );
#elif defined( X11 )
#if defined( XGL )
   sts = WLIwin_retrieve_entry_ptr( lwin_no, &ptr_win_struct );
   if ( sts != WL_SUCCESS )
   {
      WL_REPORT_ERROR( sts );
      return( sts );
   }
   if( ptr_win_struct->flags & WLI_WIN_FLAGS_USING_XGL )
   {
      if(!( ptr_win_struct->flags & WLI_WIN_DOUBLE_BUFFER_CREATED ))
      {
         return( WL_DB_NOT_POSSIBLE );
      }
      if( ptr_win_struct->buffer0 )
      {
         xgl_object_set( ptr_win_struct->native_info.win_ras, 
                         XGL_WIN_RAS_BUF_DISPLAY, 1, NULL );
         ptr_win_struct->buffer1 = WLI_TRUE;
         ptr_win_struct->buffer0 = WLI_FALSE;
      }
      else if( ptr_win_struct->buffer1 )
      {
         xgl_object_set( ptr_win_struct->native_info.win_ras, 
                         XGL_WIN_RAS_BUF_DISPLAY, 0, NULL );
         ptr_win_struct->buffer0 = WLI_TRUE;
         ptr_win_struct->buffer1 = WLI_FALSE;
      }
      ptr_win_struct->flags &= (~( WLI_WIN_DOUBLE_BUFFER_DISPLAYED ));
      return( WL_SUCCESS );
   }
#endif   
 
   if ( !(win_struct.flags & WLI_WIN_FLAGS_USING_OPENGL ) )
   {
      sts = WLIwin_retrieve_entry_ptr( lwin_no, &ptr_win_struct );
      if ( sts != WL_SUCCESS )
      {
         WL_REPORT_ERROR( sts );
         return( sts );
      }
 
      if( ptr_win_struct->buffer0 )
      {
         tmp_win_no = ptr_win_struct->hwin_no;
         ptr_win_struct->hwin_no = ptr_win_struct->double_buffer[1]   ;
         ptr_win_struct->double_buffer[1] =  tmp_win_no ;

         XmbufDisplayBuffers( ptr_win_struct->native_info.EXdisplay, 1,
                              &(ptr_win_struct->double_buffer[1]), 100, 1);
         ptr_win_struct->buffer1 = WLI_TRUE;
         ptr_win_struct->buffer0 = WLI_FALSE;
      }
      else if( ptr_win_struct->buffer1 )
      {
         tmp_win_no = ptr_win_struct->hwin_no;
         ptr_win_struct->hwin_no = ptr_win_struct->double_buffer[0]   ;
         ptr_win_struct->double_buffer[0] =  tmp_win_no ;
         XmbufDisplayBuffers( ptr_win_struct->native_info.EXdisplay, 1,
                              &(ptr_win_struct->double_buffer[0]), 100, 1);
         ptr_win_struct->buffer0 = WLI_TRUE;
         ptr_win_struct->buffer1 = WLI_FALSE;
      }
      ptr_win_struct->flags &= (~( WLI_WIN_DOUBLE_BUFFER_DISPLAYED ));
   }
 
#endif
#if defined( OPENGL )
   if ( win_struct.flags & WLI_WIN_FLAGS_USING_OPENGL )
   {
#if defined( X11 )
      sts = WLglx_make_window_current( lwin_no, WL_GLX_BASE_WIN );
      if ( sts != WL_SUCCESS )
      {
        WL_REPORT_ERROR( sts );
        return( sts );
      }
#endif

      glGetBooleanv( GL_DOUBLEBUFFER, &flag );
      if ( flag )
      {
#if defined( X11 )
         glXSwapBuffers( win_struct.native_info.EXdisplay, win_struct.hwin_no );
#endif
         glDrawBuffer( GL_FRONT );
         if ( context_struct.base_cmap_type == WL_CMAP_INDEXED )
         {
            if ( ( win_struct.flags & WLI_WIN_BASE_MASK ) ==
                                      WLI_WIN_FLAGS_BASE_NOOP )
            { 
               glIndexMask( 0 );
            } 
            else 
            { 
               glIndexMask( context_struct.base_mask );
            } 
         }
         else
         {
            if ( ( win_struct.flags & WLI_WIN_BASE_MASK ) ==
                                      WLI_WIN_FLAGS_BASE_NOOP )
            { 
               glColorMask( GL_FALSE, GL_FALSE, GL_FALSE, GL_FALSE );
            } 
            else 
            { 
               glColorMask( GL_TRUE, GL_TRUE, GL_TRUE, GL_TRUE );
            } 
         }
      }

#if defined( X11 )
      if ( win_struct.flags & WLI_WIN_SEPARATE_HILITE )
      {
         sts = WLglx_make_window_current( lwin_no, WL_GLX_HILITE_WIN );
         if ( sts != WL_SUCCESS )
         {
           WL_REPORT_ERROR( sts );
           return( sts );
         }

         glGetBooleanv( GL_DOUBLEBUFFER, &flag );
flag = 0;
         if ( flag )
         {
            glXSwapBuffers( win_struct.native_info.EXdisplay, win_struct.hl_hwin_no );
            glDrawBuffer( GL_FRONT );
            if ( ( win_struct.flags & WLI_WIN_HILITE_MASK ) ==
                                      WLI_WIN_FLAGS_HILITE_NOOP )
            { 
               glIndexMask( 0 );
            } 
            else 
            { 
               glIndexMask( context_struct.base_mask );
            } 
         }
      }
#endif
   }
#endif

   return( WL_SUCCESS );
}


/*--- WLexit -----------------------------------------------*/

int WLexit(
   void )

/*
NAME
	WLexit 
 
KEYWORD
	WL 
 
DESCRIPTION
	This function exits wl

SYNOPSIS
	int WLexit(
	   void )
 
PARAMETERS
	none

GLOBALS USED
	none
 
RETURN VALUES
	WL_SUCCESS
		Success

HISTORY
	01/05/93 Shridar Subramanian
		Initial definition

	01/05/93 Shridar Subramanian
		Initial design
*/

{
   return( WL_SUCCESS );
}

/*--- WLset_drawing_mode -------------------------------------------*/

int WLset_drawing_mode(
   WLuint32 lwin_no,
   int mode )
/*
NAME
	WLset_drawing_mode
 
KEYWORD
	WL

DESCRIPTION
	This function sets the drawing mode

SYNOPSIS
	int WLset_hilite_drawing_mode(
   		WLuint32 lwin_no,
   		int mode )

PARAMETERS
	lwin_no (IN) - logical window number
	mode (IN) - Specifies the dynamics drawing mode. Values could be 
		    WL_BASE_DRAW, WLBASE_ERASE, WL_BASE_NOOP, WL_HILITE_DRAW,
                    WL_HILITE_ERASE, WL_HILITE_NOOP
                    

GLOBALS USED
	not yet

RETURN VALUES
	WL_SUCCESS
		Success

	WL_BAD_WINDOW
		The logical window number is invalid

HISTORY
	01/05/93 Shridar Subramanian
		Initial definition

	01/05/93 Shridar Subramanian
		Initial design

	02/25/93 Shridar Subramanian
		Implemented
*/
{
   int sts, hilite_mask, base_mask;
   int base_mode, hilite_mode;
   unsigned int hilite_flags, base_flags, new_flags;
   struct WLIwin win_struct;
   struct WLIcontext context_struct;

   sts = WLIwin_retrieve_entry( lwin_no, &win_struct );
   if ( sts != WL_SUCCESS )
   {
      WL_REPORT_ERROR( sts );
      return( sts );
   }
  
   sts = WLIcontext_retrieve_entry( win_struct.context_no, &context_struct );
   if ( sts != WL_SUCCESS )
   {
      WL_REPORT_ERROR( sts );
      return( sts );
   }
  
   base_mode = mode & WL_BASE_MASK;
   if ( !context_struct.hilite_used )
   {
      hilite_mode = WL_HILITE_NOOP;
   }
   else
   {
      hilite_mode = mode & WL_HILITE_MASK;
   }

   if ( ( base_mode == WL_BASE_DRAW ) || ( base_mode == WL_BASE_ERASE ) )
   {
      if ( base_mode == WL_BASE_DRAW )
      {
         base_flags = WLI_WIN_FLAGS_BASE_DRAW;
      }
      else
      {
         base_flags = WLI_WIN_FLAGS_BASE_ERASE;
      }
      base_mask = context_struct.base_mask;
   }
   else
   {
      base_flags = WLI_WIN_FLAGS_BASE_NOOP;
      base_mask = 0;
   }

   if ( ( hilite_mode == WL_HILITE_DRAW ) || 
        ( hilite_mode == WL_HILITE_ERASE ) )
   {

      if ( hilite_mode == WL_HILITE_DRAW )
      {
         hilite_flags = WLI_WIN_FLAGS_HILITE_DRAW;
      }
      else
      {
         hilite_flags = WLI_WIN_FLAGS_HILITE_ERASE;
      }

      hilite_mask = context_struct.hilite_mask;
   }
   else
   {
      hilite_flags = WLI_WIN_FLAGS_HILITE_NOOP;
      hilite_mask = 0;
   }
   if ( ( base_flags == ( win_struct.flags & WLI_WIN_BASE_MASK ) ) &&
        ( hilite_flags == ( win_struct.flags & WLI_WIN_HILITE_MASK ) ) )
   {
      return( WL_SUCCESS );
   }
   
   (*win_struct.set_drawing_mode)( &win_struct, &context_struct, base_mask,
                                   hilite_mask );

   new_flags = win_struct.flags & ~WLI_WIN_BASE_MASK & 
                                  ~WLI_WIN_HILITE_MASK;

   new_flags |= ( base_flags | hilite_flags | WLI_WIN_FLAGS_COLOR_CHANGED );
   sts = WLIwin_set_flags ( lwin_no, new_flags );
   if ( sts != WL_SUCCESS )
   {
      WL_REPORT_ERROR( sts );
      return( sts );
   }
        
   return( WL_SUCCESS );
} /*  WLset_drawing_mode */

/*--- WLenter_2D --------------------------------------------------------------*/

int WLenter_2D( WLuint32 lwin_no,
                int mode )
/*
NAME
	WLenter_2D
 
KEYWORD
	WL

DESCRIPTION
	This function is used to set up 2D for hilite planes or base planes 
        depending on the mode.  

SYNOPSIS
	int WLenter_2D(
   		WLuint32 lwin_no,
   		int mode )

PARAMETERS
	lwin_no (IN) - logical window number
	mode (IN) - Base planes or hilight planes
                    
GLOBALS USED
        none 

RETURN VALUES
	WL_SUCCESS
		Success

	WL_BAD_WINDOW
		The logical window number is invalid

HISTORY
	06/08/94 Bob Druzynski
		Implemented
*/
{
#if defined( XGL )
   WLxgl_enter_2D( lwin_no, mode);
#elif defined( OPENGL )
   WLopengl_enter_2D(lwin_no, mode);
#endif 
}

/*--- WLexit_2D -------------------------------------------*/

int WLexit_2D( WLuint32 lwin_no,
               int mode )
/*
NAME
	WLexit_2D
 
KEYWORD
	WL

DESCRIPTION
	This function exits 2D setup for hilite or base depending on the flag
        mode.

SYNOPSIS
	int WLexit_2D(
   		WLuint32 lwin_no,
   		int mode )

PARAMETERS
	lwin_no (IN) - logical window number
	mode (IN) - whether the hilite or base planes are to be restored.
                    

GLOBALS USED
	not yet

RETURN VALUES
	WL_SUCCESS
		Success

	WL_BAD_WINDOW
		The logical window number is invalid

HISTORY
	06/08/94 Bob Druzynski
		Implemented
*/
{
#if defined( XGL )
   WLxgl_exit_2D( lwin_no, mode );
#elif defined( OPENGL )
   WLopengl_exit_2D( lwin_no, mode );
#endif 
}

