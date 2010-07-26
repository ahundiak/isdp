#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "wl.h"
#include "wl_internal.h"

#if defined( OPENGL )
extern GLXContext gl_share_context /*= NULL*/;
extern int gl_attrib_list[] /*= { GLX_USE_GL, None }*/;
#endif


/*--- WLadd_hardware_window--------------------------------------------*/

int WLadd_hardware_window(
   WLhwin_no hwin_no,
   WLuint32 context_no,
   struct WLnative_info *native_info,
   WLuint32 *lwin_no)

/*
NAME
	WLadd_hardware_window
 
KEYWORD
	WL
 
DESCRIPTION
	This function adds an "externally" created window to the system so it
	can be manipulated by the WL functions

SYNOPSIS
	int WLadd_hardware_window(
   		WLhwin_no hwin_no,
   		WLuint32 context_no,
   		struct WLnative_info *native_info,
   		WLuint32 *lwin_no)
 
PARAMETERS
	hwin_no (IN) - Hardware window number
	context_no (IN) - context number to associate with the window
	native_info (IN) - The native information
	lwin_no (OUT) - logical window number

GLOBALS USED
	not yet
 
RETURN VALUES
	WL_SUCCESS
		Success
	
	WL_BAD_HARDWARE_WINDOW
		The hardware window is invalid

	WL_BAD_CONTEXT
		The context number is invalid
	
	WL_BAD_PARAMETER
		The "lwin_no" pointer is NULL 
 
HISTORY
	08/28/92 Shridar Subramanian
		Initial definition

	10/22/92 Shridar Subramanian
		Initial design
*/
{

   WLuint16   lscreen_no;
   WLuint8    group_index;
   WLuint8    offset;
   int        sts;

   if ( ( lwin_no == NULL ) || ( native_info == NULL ) )
   {
      WL_REPORT_ERROR( WL_BAD_PARAMETER  );
      return( WL_BAD_PARAMETER );
   }

#  if defined (XGL)
   native_info->xgl_context_3D = 0;
   native_info->hl_xgl_context_3D = 0;
   native_info->win_ras = 0;
   native_info->hl_win_ras = 0;
#  endif 

   WLIcontext_unpack( context_no, &lscreen_no, &group_index, &offset );

   if ( WLIcontext_validate( lscreen_no, group_index, offset) != WL_SUCCESS )
   {
      WL_REPORT_ERROR( WL_BAD_CONTEXT );
      return( WL_BAD_CONTEXT );
   }

   sts = WLIwin_add_entry( context_no, native_info, hwin_no, lwin_no, 
                           WLI_FALSE );
   if ( sts != WL_SUCCESS )
   {
      WL_REPORT_ERROR( sts );
      return( sts );
   }

   /* Set the fill pattern to solid                                   */

   if ( hwin_no >= 0 )       /* do not call for digitizer windows */
   {
      sts = WLset_blendarea( *lwin_no, NULL, WLI_TRUE );
      if ( sts != WL_SUCCESS )
      {
         WL_REPORT_ERROR( sts );
         return( sts );
      }
   }

#if defined( ENV5 )

   if ( hwin_no >= 0 )       /* do not call for digitizer windows */
   {
      enabledata( hwin_no, IMAGE_DATA, 0xffffff );
      fgdata( hwin_no, HIGHLIGHT_DATA, 0 );
      Set_win_button_mode( hwin_no, BUTTON_MODE_ALL );
   }

#elif defined( X11 )

#endif

   return( WL_SUCCESS );
	
}  /* WLadd_hardware_window */

#if defined (XGL)
static Xgl_pt_d3d		max_coord;
static int			NumActiveWindows = 0;
#endif

/*--- WLcreate_window -----------------------------------------------*/

int WLcreate_window( WLuint16 lscreen_no,
                         char *name,
              struct WLbounds *bounds,
                          int border_width,
                     WLuint32 context_no,
                     WLuint32 *lwin_no )

/*
NAME
   WLcreate_window
 
KEYWORD
   WL 
 
DESCRIPTION
   This function creates a window, with the given context as the 
   "base window" or the "parent window".

SYNOPSIS
   int WLcreate_window( WLuint16 lscreen_no,
                            char *name,
                 struct WLbounds *bounds,
                             int border_width,
                        WLuint32 context_no,
                        WLuint32 *lwin_no )

NOTES
   The lwin_no is the slot number of the newly created window, if 
   multiple  transparent windows of different visuals are not supported,
   else it is the slot number of the parent window.

   Right now,only the "base window" has a background color, as we
   do not know if the transparent windows have a concept of background
   color. This note is for internal reminder only.
 
PARAMETERS
   lscreen_no (IN) - The logical screen number.
   name (IN) - name of the window to be created.
   bounds (IN) - Window bounds
   border_width (IN) - Border Width
   context_no (IN) - the context number
   lwin_no (OUT) - Logical window number. 

GLOBALS USED
   not yet
 
RETURN VALUES
   WL_SUCCESS
      Success

   WL_BAD_SCREEN_NUMBER
      The logical screen number is invalid

   WL_BAD_WINDOW_BOUNDS
      The window bounds are invalid 

   WL_BAD_PARAMETER
   One of the pointers is NULL

   WL_BAD_CONTEXT
   The context is invalid

RELATED INFORMATION
   Functions:  WLadd_context_to_window(),
   WLdisplay_window(), WLdelete_window()

HISTORY
   08/28/92 Shridar Subramanian
      Initial definition

   10/22/92 Shridar Subramanian
      Initial design
*/

   {
   int		 	sts;
   int			hilite_depth;
   struct WLIcontext	context_struct;
   struct WLIscreen	screen_struct;
   WLhwin_no		hwin_no;
   struct WLnative_info	native_info;

#  if defined( X11 )
      WLhwin_no		hl_hwin_no;
      int		flags;
      XSetWindowAttributes	attr;
      GC		gc, hl_gc;
      XSizeHints	hints;
      Atom		del_atom;

#     if defined( OPENGL )
         XVisualInfo	vinfo_template, *vinfo, *visual_info;
         int		num;
#     endif

#     if defined( XGL )
         Xgl_X_window	xgl_x_win, hl_xgl_x_win;
         Xgl_obj_desc	win_desc, hl_win_desc;
         Xgl_win_ras	win_ras, hl_win_ras;
         Xgl_color_type	cmap_type;
         unsigned long	pixel_mapping[256];
         unsigned long	hl_pixel_mapping[256];
         int		ii, cmap_size;
         Xgl_trans	model_trans, hl_model_trans, view_trans, hl_view_trans;
         Xgl_trans	local_model_trans, hl_local_model_trans;
         Xgl_bounds_d3d	xgl_window;
         int		xgl_num_buffers;
         Xgl_inquire	*xgl_inq;
#     endif /* XGL */

#  elif defined( WIN32 ) /* !X11 */
      DWORD		style;
#  endif
 
   if ( WLIscreen_validate( lscreen_no ) != WL_SUCCESS )
      {
      WL_REPORT_ERROR( WL_BAD_SCREEN_NUMBER );
      return( WL_BAD_SCREEN_NUMBER );
      }

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

   if ( ( bounds == NULL ) || ( lwin_no == NULL ) )
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

#  if defined (XGL)

   /*  if on a ZX, have to count the number of windows.  If more */
   /*  than 15, the screen manager will crash.  This count is */
   /*  decrimented in WLdelete_window.  (Mike Lanier...6/4/96) */

   if( screen_struct.flags & WLI_SCREEN_FLAGS_ZX_ACTIVE )
      {
      if( NumActiveWindows >= 15 ) return WL_ERROR;
      NumActiveWindows++;
      }
#  endif

   sts = WLIcontext_retrieve_entry( context_no, &context_struct );
   if ( sts != WL_SUCCESS )
      {
      WL_REPORT_ERROR( sts );
      return( sts );
      }

   if ( !context_struct.hilite_used )
      {
      hilite_depth = 0;
      }
   else
      {
      if ( context_struct.flags & WL_SEPARATE_HILITE )
         {
         hilite_depth = 0;
         }
      else
         {
         hilite_depth = 1;
         }
      }

#  if defined( X11 )

      /* Set the colormap and all other values that copy from parent    */
      /* Default the remaining values                                   */

      hl_hwin_no = WL_UNDEFINED_WINDOW;
      hl_gc = 0;

      attr.border_pixmap = None;
      attr.colormap = context_struct.native_info.EXcolormap;
      attr.background_pixmap = None;
      attr.background_pixel = 0;
      attr.border_pixel = 0;
      attr.bit_gravity = ForgetGravity;
      attr.win_gravity = NorthWestGravity;
      attr.backing_store = NotUseful;
      attr.backing_planes = 0xFFFFFFFF;
      attr.backing_pixel = 0;
      attr.override_redirect = False;
      attr.save_under = False;
      attr.event_mask = 0;
      attr.do_not_propagate_mask = 0;
      attr.cursor = None;

      flags = CWColormap | CWBackPixmap | CWBackPixel | CWBorderPixel |
              CWBitGravity | CWWinGravity | CWBackingStore | CWBackingPlanes |
              CWOverrideRedirect | CWSaveUnder | CWEventMask | CWDontPropagate |
              CWCursor;

      flags = CWColormap | CWBorderPixel | CWEventMask;


      hwin_no = XCreateWindow ( 
                      screen_struct.native_info.EXdisplay, 
                      RootWindow( screen_struct.native_info.EXdisplay,
                                  screen_struct.native_info.screen_no ),
                      bounds->x, 
                      bounds->y, 
                      bounds->width, 
                      bounds->height,
                      border_width, 
                      (context_struct.base_depth + hilite_depth),
                      InputOutput, 
                      context_struct.native_info.visual, 
                      flags, 
                      &attr );

      gc = XCreateGC( screen_struct.native_info.EXdisplay, 
                      hwin_no, 0, NULL );

      if ( context_struct.flags & WL_SEPARATE_HILITE )
         {
         attr.colormap = context_struct.hl_native_info.hl_colormap;
 
         flags = CWColormap | CWBackPixmap | CWBackPixel | 
                 CWBorderPixel | CWBitGravity | CWWinGravity | 
                 CWBackingStore | CWBackingPlanes | CWOverrideRedirect | 
                 CWSaveUnder | CWEventMask | CWDontPropagate |
                 CWCursor;

         flags = CWColormap | CWBorderPixel | CWEventMask;

#        if defined( X11 ) && (defined(SUNOS54) || defined(SUNOS55))

            hl_hwin_no = XSolarisOvlCreateWindow( 
                                    screen_struct.native_info.EXdisplay,
                                    hwin_no, 
                                    0, 
                                    0, 
                                    bounds->width, 
                                    bounds->height, 
                                    0, 
                                    context_struct.hilite_depth,
                                    InputOutput, 
                                    context_struct.hl_native_info.hl_visual,
                                    flags, 
                                    &attr );
   
            XSolarisOvlSetWindowTransparent( 
                                    screen_struct.native_info.EXdisplay,
                                    hl_hwin_no );

            XSetWMColormapWindows(  screen_struct.native_info.EXdisplay,
                                    hwin_no, &hl_hwin_no, 1 );

#        else /* X11 && (SUNOS54 or SUNOS55) */

            hl_hwin_no = XCreateWindow ( 
                                    screen_struct.native_info.EXdisplay, 
                                    hwin_no, 
                                    0, 
                                    0, 
                                    bounds->width, 
                                    bounds->height, 
                                    0, 
                                    context_struct.hilite_depth,
                                    InputOutput, 
                                    context_struct.hl_native_info.hl_visual,
                                    flags, 
                                    &attr );

#        endif /* else X11 && (SUNOS54 or SUNOS55) */

         hl_gc = XCreateGC( screen_struct.native_info.EXdisplay, 
                            hl_hwin_no, 0, NULL );

         XSetWMColormapWindows( screen_struct.native_info.EXdisplay, hwin_no, 
                                &hl_hwin_no, 1 );

#        if defined( X11 ) && (defined( SUNOS54) || defined( SUNOS55 ))
            XSolarisOvlSetPaintType(screen_struct.native_info.EXdisplay, 
                                    hl_gc, 
                                    XSolarisOvlPaintTransparent);
#        endif

         } /* context_struct.flags & WL_SEPARATE_HILITE */

      hints.x = bounds->x;
      hints.y = bounds->y;
      hints.width = bounds->width;
      hints.height = bounds->height;
      hints.flags = USPosition | USSize ;

      XSetWMNormalHints( screen_struct.native_info.EXdisplay, hwin_no, &hints );
      if ( context_struct.flags & WL_SEPARATE_HILITE )
         {
         hints.x = 0;
         hints.y = 0;

         XSetWMNormalHints( screen_struct.native_info.EXdisplay, 
                            hl_hwin_no, 
                            &hints );
         }

      del_atom = XInternAtom (screen_struct.native_info.EXdisplay,
                              "WM_DELETE_WINDOW", 
                              False);

      XSetWMProtocols (screen_struct.native_info.EXdisplay,
                       hwin_no, 
                       &del_atom ,
                       1 );

      XSetPlaneMask( screen_struct.native_info.EXdisplay, 
                     gc, 
                     ( 1 << context_struct.base_depth ) -1 );

      if ( context_struct.flags & WL_SEPARATE_HILITE )
         {
         XSetWMProtocols (screen_struct.native_info.EXdisplay,
                          hl_hwin_no, &del_atom ,1);

         XSetPlaneMask( screen_struct.native_info.EXdisplay, hl_gc, 
                        ( 1 << context_struct.hilite_depth ) -1 );
         }

      native_info.display = screen_struct.native_info.EXdisplay;
      native_info.gc = gc;
      native_info.base_win = hwin_no;
      native_info.colormap = context_struct.native_info.EXcolormap;
      native_info.visual = context_struct.native_info.visual;
      native_info.screen = screen_struct.native_info.screen_no;
      native_info.cursor = None;

#     if defined( XGL )
         native_info.sys_state = screen_struct.native_info.sys_state;
#     endif

      if ( context_struct.flags & WL_SEPARATE_HILITE )
         {
         native_info.hl_win = hl_hwin_no;
         native_info.hl_colormap = context_struct.hl_native_info.hl_colormap;
         native_info.hl_visual = context_struct.hl_native_info.hl_visual;
         native_info.hl_gc = hl_gc;
         native_info.flags = WL_NI_SEPARATE_HILITE;
         }
      else
         {
         native_info.hl_win = 0;
         native_info.hl_colormap = 0;
         native_info.hl_visual = NULL;
         native_info.hl_gc = 0;
         native_info.flags = 0;
         }
   
#     if defined( OPENGL )
         native_info.glx_context = native_info.hl_glx_context = NULL;
         if ( context_struct.flags & WL_USING_OPENGL )
            {

            /* create a glX context for this window */

            vinfo_template.visualid = 
                  XVisualIDFromVisual( context_struct.native_info.visual );

            vinfo = XGetVisualInfo( native_info.display, 
                                    VisualIDMask, 
                                    &vinfo_template, 
                                    &num );

            if ( vinfo )
               {

               /* get a context to share display lists with */

               if ( ! gl_share_context )
                  {
                  visual_info = glXChooseVisual( native_info.display,
                                                 native_info.screen, 
                                                 gl_attrib_list );

                  gl_share_context = glXCreateContext( native_info.display,
                                                       visual_info, 
                                                       NULL, 
                                                       TRUE );
                  XFree( (char *) visual_info );
                  }
         
               native_info.glx_context = glXCreateContext( native_info.display,
                                                           vinfo,
                                                           gl_share_context, 
                                                           TRUE );
               XFree( (char *) vinfo );

               if ( (native_info.glx_context) &&
                    (context_struct.flags & WL_SEPARATE_HILITE) )
                  {

                  /* create glx context for separate hilite window */

                  vinfo_template.visualid = XVisualIDFromVisual( 
                           context_struct.hl_native_info.hl_visual );

                  vinfo = XGetVisualInfo( native_info.display, 
                                          VisualIDMask, 
                                          &vinfo_template, 
                                          &num );
                  if ( vinfo )
                     {
                     native_info.hl_glx_context = 
                           glXCreateContext( native_info.display,
                                             vinfo, 
                                             gl_share_context, 
                                             TRUE );

                     XFree( (char *) vinfo );

                     if ( ! native_info.hl_glx_context )
                        {
                        glXDestroyContext( native_info.display, 
                                           native_info.glx_context );

                        native_info.glx_context = NULL;
                        }

                     } /* if vinfo */
                  else
                     {
                     glXDestroyContext( native_info.display, 
                                        native_info.glx_context );

                     native_info.glx_context = NULL;

                     } /* !vinfo */

                  } /* if glx_context and SEPARATE_HILITE */

               } /* if vinfo */

            } /* context_struct.flags & WL_USING_OPENGL */

#     endif /* OPENGL */

#     if defined( XGL )
         {
         native_info.xgl_context_3D = native_info.hl_xgl_context_3D = NULL;

         if ( context_struct.flags & WL_USING_XGL )
            {

            /* Create all xgl contexts */

            xgl_x_win.X_display = native_info.display;
            xgl_x_win.X_window = native_info.base_win;
            xgl_x_win.X_screen = native_info.screen;
     
            /*  Added ...PROTO_DEFAULT  6/3/94 (ml)  per ja  */
  
            win_desc.win_ras.type = XGL_WIN_X | XGL_WIN_X_PROTO_DEFAULT;
            win_desc.win_ras.desc = &xgl_x_win;

            if ( context_struct.base_cmap_type == WL_CMAP_INDEXED )
               {
               cmap_type = XGL_COLOR_INDEX;  
               cmap_size = (1 << context_struct.base_depth);
               }
            else
               {
               cmap_type = XGL_COLOR_RGB;  
               cmap_size = (1 << (context_struct.base_depth/3));
               }

            if ( context_struct.base_cmap_type == WL_CMAP_INDEXED )
               {
               for ( ii=0; ii<cmap_size; ii++ )
                  {
                  pixel_mapping[ii] = ii;
                  }
               }

            if ( context_struct.flags & WL_DOUBLE_BUFFER_ABILITY )
               {
               xgl_num_buffers = 2;
               }
            else
               {
               xgl_num_buffers = 1;
               }

            xgl_inq = xgl_inquire( native_info.sys_state, &win_desc );
            if( xgl_inq )
               {
               native_info.xgl_color_type = xgl_inq->color_type;
               native_info.xgl_hlhsr_mode = xgl_inq->hlhsr_mode;
               }

            win_ras = xgl_object_create( native_info.sys_state, 
                         XGL_WIN_RAS,        &win_desc, 
                         XGL_DEV_COLOR_TYPE, cmap_type,
                         XGL_DEV_COLOR_MAP,  
                            context_struct.native_info.xgl_base_cmap,
                         XGL_WIN_RAS_BUFFERS_REQUESTED, xgl_num_buffers, 
                         NULL );

            /* Kludge for XGL */
            XSetWindowColormap( native_info.display, native_info.base_win, 
                                native_info.colormap );

            native_info.mem_ras = xgl_object_create( native_info.sys_state,
                                     XGL_MEM_RAS, NULL,
                                     XGL_RAS_DEPTH, 1,
                                     XGL_DEV_COLOR_MAP,
                                        context_struct.native_info.xgl_base_cmap,
                                     NULL );
 
            if ( context_struct.flags & WL_SEPARATE_HILITE )
               {
               hl_xgl_x_win.X_display = native_info.display;
               hl_xgl_x_win.X_window = native_info.hl_win;
               hl_xgl_x_win.X_screen = native_info.screen;
         
               hl_win_desc.win_ras.type = XGL_WIN_X;
               hl_win_desc.win_ras.desc = &hl_xgl_x_win;
  
               hl_win_ras = xgl_object_create( native_info.sys_state, 
                               XGL_WIN_RAS, &hl_win_desc, 
                               XGL_DEV_COLOR_TYPE, XGL_COLOR_INDEX,
                               XGL_DEV_COLOR_MAP, 
                                 context_struct.native_info.xgl_hilite_cmap,
                               XGL_WIN_RAS_PIXEL_MAPPING, 
                                 context_struct.hl_native_info.hl_pixel_mapping,
                               NULL );

               XSetWindowColormap( native_info.display, native_info.hl_win, 
                                   native_info.hl_colormap );

               native_info.hl_mem_ras = 
                  xgl_object_create( native_info.sys_state,
                     XGL_MEM_RAS, NULL,
                     XGL_RAS_DEPTH, 1,
                     XGL_COLOR_INDEX,
                     XGL_DEV_COLOR_MAP,
                        context_struct.native_info.xgl_hilite_cmap,
                     XGL_WIN_RAS_PIXEL_MAPPING,
                        context_struct.hl_native_info.hl_pixel_mapping,
                     NULL );

               cmap_size = 1 << context_struct.hilite_depth;

               } /* if separate hilite */

   
            local_model_trans = xgl_object_create( native_info.sys_state, 
                                                   XGL_TRANS, NULL, NULL );

            model_trans = xgl_object_create( native_info.sys_state, 
                                             XGL_TRANS, NULL, NULL );

            view_trans = xgl_object_create( native_info.sys_state, 
                                            XGL_TRANS, NULL, NULL );

            xgl_transform_identity( local_model_trans );
            xgl_transform_identity( model_trans );
            xgl_transform_identity( view_trans );

            xgl_object_get( win_ras, XGL_DEV_MAXIMUM_COORDINATES, &max_coord );
            xgl_window.xmin = 0;
            xgl_window.xmax = 1.0 * bounds->width -1;
            xgl_window.ymin = 0;
            xgl_window.ymax = 1.0 * bounds->height -1;

            xgl_window.xmax = bounds->width / 2;
            xgl_window.ymax = bounds->height / 2;
            xgl_window.xmin = -xgl_window.xmax;
            xgl_window.ymin = -xgl_window.ymax;

            xgl_window.zmin = 0.0;
            xgl_window.zmax = max_coord.z;
      
            native_info.xgl_context_3D = 
               xgl_object_create( native_info.sys_state,
                  XGL_3D_CTX,                 NULL,
                  XGL_CTX_DEVICE,             win_ras,
                  XGL_CTX_LOCAL_MODEL_TRANS,  local_model_trans,
                  XGL_CTX_GLOBAL_MODEL_TRANS, model_trans,
                  XGL_CTX_VIEW_TRANS,         view_trans,
                  XGL_CTX_VDC_MAP,            XGL_VDC_MAP_ASPECT,
                  XGL_CTX_VDC_WINDOW,         &xgl_window,
                  /*XGL_CTX_DC_VIEWPORT,        &xgl_window,*/
                  XGL_CTX_DEFERRAL_MODE,      XGL_DEFER_ASTI,
                  NULL );
	
            native_info.win_ras = win_ras;
      
            if ( context_struct.flags & WL_SEPARATE_HILITE )
               {
               hl_local_model_trans = xgl_object_create( native_info.sys_state, 
                                                         XGL_TRANS, 
                                                         NULL, NULL );

               hl_model_trans = xgl_object_create( native_info.sys_state, 
                                                   XGL_TRANS, NULL, NULL );

               hl_view_trans = xgl_object_create( native_info.sys_state, 
                                                  XGL_TRANS, NULL, NULL );

               xgl_transform_identity( local_model_trans );
               xgl_transform_identity( model_trans );
               xgl_transform_identity( view_trans );

               native_info.hl_xgl_context_3D = xgl_object_create( 
                  native_info.sys_state,
                  XGL_3D_CTX,                        NULL,
                  XGL_CTX_DEVICE,                    hl_win_ras,
                  XGL_CTX_LOCAL_MODEL_TRANS,         hl_local_model_trans,
                  XGL_CTX_GLOBAL_MODEL_TRANS,        hl_model_trans,
                  XGL_CTX_VIEW_TRANS,                hl_view_trans,
                  XGL_CTX_VDC_MAP,                   XGL_VDC_MAP_ASPECT,
                  XGL_CTX_VDC_WINDOW,                &xgl_window,
                  /*XGL_CTX_DC_VIEWPORT,               &xgl_window,*/
                  XGL_CTX_PAINT_TYPE,                XGL_PAINT_OPAQUE,
                  XGL_CTX_DEFERRAL_MODE,             XGL_DEFER_ASTI,
                  XGL_CTX_SURF_FRONT_COLOR_SELECTOR, XGL_SURF_COLOR_CONTEXT,
                  XGL_CTX_NEW_FRAME_ACTION,
                     XGL_CTX_NEW_FRAME_CLEAR | 
                     XGL_CTX_NEW_FRAME_PAINT_TYPE_ACTION,
                  XGL_CTX_NEW_FRAME_PAINT_TYPE,      XGL_PAINT_TRANSPARENT,
                  NULL );
         
               native_info.hl_win_ras = hl_win_ras;
               }
            else
               {
               native_info.hl_win_ras = NULL;
               native_info.hl_xgl_context_3D = NULL;
               }

            native_info.flags |= WLI_WIN_FLAGS_USING_XGL;

            } /* if using xgl */

         } /* #if XGL */

#     endif /* XGL */

#  elif defined( ENV5 )
      {
      if ( border_width > 0 )
         {
         sts = Create_win( screen_struct.native_info.screen_no, 
                           name,
                           bounds->x, 
                           bounds->y, 
                           (bounds->x + bounds->width - 1),
                           (bounds->y + bounds->height - 1), 
                           &hwin_no );

         if ( sts ) 
            {
            WL_REPORT_ERROR( WL_SYSTEM_ERROR );
            return( WL_SYSTEM_ERROR );
            }

         /* enable refresh events when a window is moved */
         Refresh_on_move( hwin_no, 1 );

         /* enable virtual screen swapping for the window */
         Set_win_vs_swap( hwin_no, 1 );

         /* turn off the refresh icon so the window will */
         /* get REFRESH events when it is uncover ed      */
         Set_win_sys_icon( hwin_no, REFRESH_ICON_VALUE, 0 );
         }
      else
         {
         sts = Create_win_no_border( screen_struct.native_info.screen_no,
                                     bounds->x, 
                                     bounds->y, 
                                     (bounds->x + bounds->width - 1),
                                     (bounds->y + bounds->height - 1), 
                                     &hwin_no );
         if ( sts ) 
            {
            WL_REPORT_ERROR( WL_SYSTEM_ERROR );
            return( WL_SYSTEM_ERROR );
            }
         }
 
      enabledata( hwin_no, IMAGE_DATA, 0xffffff );
      fgdata( hwin_no, HIGHLIGHT_DATA, 0 );
      Set_win_button_mode( hwin_no, BUTTON_MODE_ALL );
      native_info.base_win = hwin_no;
      native_info.vlt_no = context_struct.native_info.vlt_no;
      native_info.vs_no = screen_struct.native_info.screen_no;
      native_info.cursor = 0;
      } 

#  elif defined( WIN32 )
      {
      style = WS_SYSMENU | WS_MAXIMIZEBOX | WS_MINIMIZEBOX |
              WS_CLIPSIBLINGS | WS_CHILD;

      if ( border_width > 0 )
         {
         style |= WS_BORDER | WS_THICKFRAME | WS_CAPTION;
         } 

      if ( screen_struct.native_info.app_main_window )
         {
         if ( screen_struct.native_info.hWindowMenu )
            {
            MDICREATESTRUCT mdiinfo;

            memset( &mdiinfo, 0, sizeof( MDICREATESTRUCT ) );
            mdiinfo.szClass = screen_struct.native_info.class;
            mdiinfo.szTitle = name;
            mdiinfo.hOwner = screen_struct.native_info.hinstance;
            mdiinfo.x = bounds->x;
            mdiinfo.y = bounds->y;
            mdiinfo.cx = bounds->width;
            mdiinfo.cy = bounds->height;
            hwin_no = (WLhwin_no) SendMessage( 
                           screen_struct.native_info.hmdi_no,
                           WM_MDICREATE, 0L,
                           (LONG) &mdiinfo );
            }
         else
            {
            hwin_no = CreateWindow( screen_struct.native_info.class, 
                                    name, 
                                    style,
                                    bounds->x, 
                                    bounds->y, 
                                    bounds->width,
                                    bounds->height, 
                                    screen_struct.native_info.hwin_no,
                                    NULL, 
                                    screen_struct.native_info.hinstance, 
                                    NULL );
            }
         }
      else
         {
         hwin_no = CreateWindow( screen_struct.native_info.class, 
                                 name, 
                                 style,
                                 bounds->x, 
                                 bounds->y, 
                                 bounds->width,
                                 bounds->height, 
                                 NULL, NULL,
                                 screen_struct.native_info.hinstance, 
                                 NULL );
         }
    
    
      native_info.base_win = hwin_no;
      native_info.hdc = GetDC( hwin_no );
      }
#  else
#     error "A windowing system must be defined"
#  endif

   sts = WLIwin_add_entry( context_no, 
                           &native_info,  
                           hwin_no, 
                           lwin_no, 
                           WLI_TRUE );

   if ( sts != WL_SUCCESS )
      {
      WL_REPORT_ERROR( sts ) ;
      return( sts );
      }

   /* Initialize the fill pattern in the window to a solid pattern  */

   sts = WLset_blendarea( *lwin_no, NULL, WLI_TRUE );
   if ( sts != WL_SUCCESS )
      {
      WL_REPORT_ERROR( sts );
      return( sts );
      }

   sts = WLset_active_font( *lwin_no, WLIdefault_font );
   if ( sts != WL_SUCCESS )
      {
      WL_REPORT_ERROR( sts );
      return( sts );
      }

#if defined (DLTEST)
DLTlog_window( lscreen_no, name, bounds, border_width, context_no, *lwin_no );
#endif
   return( WLset_window_name( *lwin_no, name ) );

   } /* WLcreate_window */


/*--- WLdelete_window -----------------------------------------------*/

int WLdelete_window(
   WLuint32 lwin_no )

/*
NAME
	WLdelete_window
 
KEYWORD
	WL 
 
DESCRIPTION
	This function deletes a window.

SYNOPSIS
	int WLdelete_window(
		WLuint32 lwin_no )
 
PARAMETERS
	lwin_no (IN) - Logical window number. 

GLOBALS USED
	not yet
 
RETURN VALUES
	WL_SUCCESS
		Success
  
	WL_BAD_WINDOW_NUMBER
		The logical window number is invalid

RELATED INFORMATION
	Functions: WLcreate_window()

HISTORY
	08/28/92 Shridar Subramanian
		Initial definition

	10/22/92 Shridar Subramanian
		Initial design
*/
{
#  if defined (XGL)
   Xgl_object	trans;
#  endif

   int   sts;
   struct   WLIwin   win_struct;

   sts = WLIwin_retrieve_entry( lwin_no, &win_struct );
   if ( sts != WL_SUCCESS )
   {
      WL_REPORT_ERROR( sts );
      return( sts );
   }

   sts = WLIwin_delete_entry( lwin_no );
   if ( sts != WL_SUCCESS )
   {
      WL_REPORT_ERROR( sts );
      return( sts );
   }

   sts = WLIunestablish_lwin();
   if ( sts != WL_SUCCESS )
   {
      WL_REPORT_ERROR( sts );
      return( sts );
   }

#if defined( OPENGL )
   if ( win_struct.flags & WLI_WIN_FLAGS_USING_OPENGL )
   {
      WLIglx_reset_last_lwin_no();
   }
#endif

   if ( ( win_struct.flags & WLI_WIN_FLAGS_WL_CREATED ) )
   {
#if defined( X11 )
#if defined( XGL )
      if ( win_struct.flags & WLI_WIN_FLAGS_USING_XGL )
         {
         if( win_struct.flags & WLI_WIN_SEPARATE_HILITE )
            {
	    if(win_struct.native_info.hl_xgl_context_3D)
	       {
               xgl_object_destroy( win_struct.native_info.hl_win_ras );
               xgl_object_destroy( win_struct.native_info.hl_mem_ras );

               xgl_object_get( win_struct.native_info.hl_xgl_context_3D, 
                               XGL_CTX_LOCAL_MODEL_TRANS, &trans );
               xgl_object_destroy( trans );

               xgl_object_get( win_struct.native_info.hl_xgl_context_3D, 
                               XGL_CTX_GLOBAL_MODEL_TRANS, &trans );
               xgl_object_destroy( trans );

               xgl_object_get( win_struct.native_info.hl_xgl_context_3D, 
                               XGL_CTX_VIEW_TRANS, &trans );
               xgl_object_destroy( trans );

               xgl_object_destroy( win_struct.native_info.hl_xgl_context_3D ); 

	       win_struct.native_info.hl_xgl_context_3D = NULL;
	       }
            }

	 if(win_struct.native_info.xgl_context_3D)
	    {
            xgl_object_destroy( win_struct.native_info.win_ras );
            xgl_object_destroy( win_struct.native_info.mem_ras );

            xgl_object_get( win_struct.native_info.xgl_context_3D, 
                            XGL_CTX_LOCAL_MODEL_TRANS, &trans );
            xgl_object_destroy( trans );

            xgl_object_get( win_struct.native_info.xgl_context_3D, 
                            XGL_CTX_GLOBAL_MODEL_TRANS, &trans );
            xgl_object_destroy( trans );

            xgl_object_get( win_struct.native_info.xgl_context_3D, 
                            XGL_CTX_VIEW_TRANS, &trans );
            xgl_object_destroy( trans );

            xgl_object_destroy( win_struct.native_info.xgl_context_3D ); 
	    win_struct.native_info.xgl_context_3D = NULL;
	    }
         }
#endif
      if( win_struct.flags & WLI_WIN_SEPARATE_HILITE )
      {
         XDestroyWindow( win_struct.native_info.EXdisplay, 
                         win_struct.hl_hwin_no );
      }
      XDestroyWindow( win_struct.native_info.EXdisplay, win_struct.hwin_no );

#elif defined( ENV5 )

      Delete_win( win_struct.hwin_no );

#elif defined( WIN32 )

      DestroyWindow( win_struct.hwin_no );

#else
#error "A windowing system must be defined"
#endif   

#if defined( OPENGL )
      if ( win_struct.flags & WLI_WIN_FLAGS_USING_OPENGL )
      {
#if defined( X11 )
         if ( win_struct.native_info.glx_context )
         {
            glXDestroyContext( win_struct.native_info.EXdisplay, 
                               win_struct.native_info.glx_context );
         }

         if ( win_struct.native_info.hl_glx_context )
         {
            glXDestroyContext( win_struct.native_info.EXdisplay, 
                               win_struct.native_info.hl_glx_context );
         }

#endif

      }
#endif

   }

#  if defined (XGL)

   /*  decriment the number of active windows.  It don't hurt to  */
   /*  decriment in all cases, so don't worry about checking for ZX  */
   /*  here..  (Mike Lanier...6/4/96)  */

   NumActiveWindows--;
#  endif
 
   return( WL_SUCCESS );
}


/*--- WLset_event_mask -----------------------------------------------*/

int WLset_event_mask(
   WLuint32 lwin_no,
   WLuint32 event_mask)

/*
NAME
	WLset_event_mask
 
KEYWORD
	WL
 
DESCRIPTION
	This function enables the events specified by event_mask,
	for  a logical window

SYNOPSIS
	int WLset_event_mask(
		WLuint32 lwin_no,
		WLuint32 event_mask)	
 
PARAMETERS
	lwin_no (IN) - logical window number
	event_mask (IN) - The event mask

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
   int sts;
   struct WLIwin    win_struct;

   sts = WLIwin_retrieve_entry( lwin_no,&win_struct );
   if ( sts != WL_SUCCESS )
   {
      WL_REPORT_ERROR( sts );
      return( sts );
   }

   sts = WLIwin_set_event_mask( lwin_no, event_mask );
   if ( sts != WL_SUCCESS )
   {
      WL_REPORT_ERROR( sts );
      return( sts );
   }
   return( WL_SUCCESS );
} /* WLset_event_mask */



/*--- WLget_event_mask -----------------------------------------------*/

int WLget_event_mask(
   WLuint32 lwin_no,
   WLuint32 *event_mask)

/*
NAME
	WLget_event_mask
 
KEYWORD
	WL
 
DESCRIPTION
	This function retrieves the events enabled for a window
	for  a logical window

SYNOPSIS
	int WLget_event_mask(
		WLuint32 lwin_no,
		WLuint32 *event_mask)
 
PARAMETERS
	lwin_no (IN) - logical window number
	event_mask (OUT) - The event mask

GLOBALS USED
	not yet
 
RETURN VALUES
	WL_SUCCESS
		Success
	
	WL_BAD_WINDOW_NUMBER
		The logical window number is invalid

	WL_BAD_PARAMETER
		The event_mask pointer is NULL

RELATED INFORMATION

HISTORY
	08/28/92 Shridar Subramanian
		Initial definition

	10/22/92 Shridar Subramanian
		Initial design
*/
{
   int sts;

   if ( !event_mask )
   {
      WL_REPORT_ERROR( WL_BAD_PARAMETER );
      return( WL_BAD_PARAMETER );
   }

   sts = WLIwin_get_event_mask( lwin_no, event_mask );
   if ( sts != WL_SUCCESS )
   {
      WL_REPORT_ERROR( sts );
      return( sts );
   }

   return( WL_SUCCESS );

} /* WLget_event_mask */


/*--- WLclear_hilite-----------------------------------------------*/
 
int WLclear_hilite(
   WLuint32 lwin_no)
 
/*
NAME
   WLclear_hilite
 
KEYWORD
   WL
 
DESCRIPTION
   This function clears the hilite plane, only if the the window has
   a context that has a separate hilite plane

SYNOPSIS
   int WLclear_hilite(
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

   WL_NO_HILITE_PLANE
      There is no hilite plane associated with this window
 
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
   struct WLIcontext context_struct;

   status = WLIwin_retrieve_entry( lwin_no, &win_struct );
   if ( status != WL_SUCCESS )
   {
      WL_REPORT_ERROR( status );
      return( status );
   }

   status = WLIcontext_retrieve_entry( win_struct.context_no, &context_struct );
   if ( status != WL_SUCCESS)
   {
      WL_REPORT_ERROR( status );
      return( status );
   }

   if ( context_struct.hilite_used & WL_HILITE_USED )
   {
      (*win_struct.clear_hilite)( &win_struct, &context_struct );

      if ( !( win_struct.flags & WLI_WIN_FLAGS_DYNAMICS_ON ) )
      {
         /* color is now bad => set flag to indicate symbology is out of date */
         status = WLIwin_set_flags( lwin_no, win_struct.flags | 
                                             WLI_WIN_FLAGS_COLOR_CHANGED |
                                             WLI_WIN_FLAGS_B_PATTERN_CHANGED );
         if ( status != WL_SUCCESS )
         {
            WL_REPORT_ERROR( status );
            return( status );
         }

      }
   }
   else
   {
      return( WL_NO_HILITE_PLANE );
   }
   return( WL_SUCCESS );
}  /* WLclear_hilite */

/*--- WLpop_window_to_top -------------------------------------------*/

int WLpop_window_to_top(
	WLuint32 lwin_no)
/*
NAME
	WLpop_window_to_top

KEYWORD
	WL

DESCRIPTION
	This function pops the window to the top

SYNOPSIS
	int WLpop_window_to_top(
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

#if defined( X11 )
   XRaiseWindow( win_struct->native_info.EXdisplay, win_struct->hwin_no );
#elif defined( ENV5 )
   sts = Pop_win_to_top( win_struct->hwin_no );
   if( sts )
   {
      WL_REPORT_ERROR( WL_SYSTEM_ERROR );
      return( WL_SYSTEM_ERROR );
   }
#elif defined( WIN32 )
/*	BringWindowToTop();
*/
#endif
   return ( WL_SUCCESS );

} /* WLpop_window_to_top */

/*--- WLpop_window_to_bottom -------------------------------------------*/

int WLpop_window_to_bottom(
	WLuint32 lwin_no)
/*
NAME
	WLpop_window_to_top

KEYWORD
	WL

DESCRIPTION
	This function pops the window to the top

SYNOPSIS
	int WLpop_window_to_bottom(
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

#if defined( X11 )
   XLowerWindow( win_struct->native_info.EXdisplay, win_struct->hwin_no );
#elif defined( ENV5 )
   sts = Pop_win_to_bottom( win_struct->hwin_no );
   if( sts )
   {
      WL_REPORT_ERROR( WL_SYSTEM_ERROR );
      return( WL_SYSTEM_ERROR );
   }
#elif defined( WIN32 )
/*	BringWindowToBottom();
*/
#endif
   return ( WL_SUCCESS );

} /* WLpop_window_to_bottom */

/*--- WLclear_window -----------------------------------------------*/

int WLclear_window(
	WLuint32 lwin_no )
/*
NAME
	WLclear_window

KEYWORD
	WL

DESCRIPTION
	This function clears all of the contexts for a window by flooding the
	drawing area with the background color.

SYNOPSIS
	int WLclear_window(
		WLuint32 lwin_no )

NOTES
	A context parameter might be added later, once we understand how
	base color and clearing windows are implemented, for transparent
	windows in the different versions of Xlib.

PARAMETERS
	lwin_no (IN) - Logical window number.

GLOBALS USED
	not yet

RETURN VALUES
	WL_SUCCESS
		Success

	WL_BAD_WINDOW_NUMBER
		The logical window number is invalid

RELATED INFORMATION
	Functions: WLcreate_window(), WLadd_context_to_window(),
           WLset_background()

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
   if( sts != WL_SUCCESS )
   {
      WL_REPORT_ERROR( sts );
      return( sts );
   }

   return( (*(win_struct->clear_window))( win_struct, context_struct) );

} /* WLclear_window */

/*--- WLdisplay_window -----------------------------------------------*/

int WLdisplay_window(
	WLuint32 lwin_no )

/*
NAME
	WLdisplay_window

KEYWORD
	WL

DESCRIPTION
	This function displays a window on the screen.

SYNOPSIS
	int WLdisplay_window(
		WLuint32 lwin_no )

PARAMETERS
	lwin_no (IN) - Logical window number.

GLOBALS USED
	not yet

RETURN VALUES
	WL_SUCCESS
		Success

	WL_BAD_WINDOW_NUMBER
		The logical window number is invalid

	WL_SYSTEM_ERROR
		Windowing system error

RELATED INFORMATION
	Functions: WLcreate_window()
	 

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

   if( WLIbatch_mode )
   {
      return ( WL_SUCCESS );
   }
   
   context_no = WL_DEFAULT_CONTEXT;
   sts = WLIestablish_lwin_and_context( &lwin_no, &context_no, &win_struct, &context_struct );
   if (sts != WL_SUCCESS)
   {
      WL_REPORT_ERROR( sts );
      return ( sts );
   }

#if defined( X11 )
   XMapWindow( win_struct->native_info.EXdisplay, win_struct->hwin_no );
   if ( win_struct->flags & WLI_WIN_SEPARATE_HILITE )
   {
      XMapWindow( win_struct->native_info.EXdisplay, win_struct->hl_hwin_no );
      XInstallColormap( win_struct->native_info.EXdisplay, 
                        context_struct->hl_native_info.hl_colormap );
   }
#elif defined( ENV5 )
   sts = Display_win( win_struct->hwin_no );
   if( sts )
   {
      WL_REPORT_ERROR( WL_SYSTEM_ERROR );
      return( WL_SYSTEM_ERROR );
   }
#elif defined( WIN32 )
   BringWindowToTop( win_struct->hwin_no );
   ShowWindow( win_struct->hwin_no, SW_SHOW );
   UpdateWindow( win_struct->hwin_no );
#endif

   /* initialize the gl context */
#if defined( OPENGL )
   if ( win_struct->flags & WLI_WIN_FLAGS_USING_OPENGL )
   {
#if defined( X11 )
      WLglx_make_window_current( lwin_no, WL_GLX_BASE_WIN );
#endif
      glDrawBuffer( GL_FRONT );

#if defined( X11 )
      if ( win_struct->native_info.hl_glx_context )
      {
         WLglx_make_window_current( lwin_no, WL_GLX_BASE_WIN );
         glDrawBuffer( GL_FRONT );
      }
#endif

   }
#endif

   return( WL_SUCCESS );

} /* WLdisplay_window */

/*--- WLset_active_SR_window -----------------------------------------------*/

int WLset_active_SR_window(
	WLhwin_no hwin_no )

/*
NAME
	WLset_active_SR_window

KEYWORD
	WL

DESCRIPTION
	This function sets the active Save Restore window

SYNOPSIS
	int WLdisplay_window(
  	   WLhwin_no hwin_no )

PARAMETERS
	hwin_no (IN) - hardware window number.

GLOBALS USED
	not yet

RETURN VALUES
	WL_SUCCESS
		Success

RELATED INFORMATION
	 

HISTORY
	08/28/92 Shridar Subramanian
		Initial definition

	10/22/92 Shridar Subramanian
		Initial design
*/
{
   WLISRwin_no = hwin_no;
   return ( WL_SUCCESS );

} /* WLset_active_SR_window */

/*--- WLchange_window_screen -----------------------------------------------*/

int WLchange_window_screen(
   WLuint32 lwin_no,
   WLuint32 new_context_no,
   WLuint16 new_lscreen_no,
   WLuint32 *new_lwin_no )

/*
NAME
	WLchange_window_screen

KEYWORD
	WL

DESCRIPTION
	This function changes the screen of a window.  It is
	meant to be used for Envrion V only.  Changing the screen
        will result in a new logical window number, so the
        applications data structures will have to be updated.

SYNOPSIS
	int WLchange_window_screen(
	   WLuint32 lwin_no,
	   WLuint32 new_context_no,
	   WLuint16 new_lscreen_no,
	   WLuint32 *new_lwin_no )

PARAMETERS
	lwin_no (IN) - Logical window number.
	new_context_no (IN) - the new context for the window
	new_lscreen_no (IN) - the new logical screen
	new_lwin_no (OUT) - the new logical window number

GLOBALS USED
	not yet

RETURN VALUES
	WL_SUCCESS
		Success

	WL_BAD_WINDOW_NUMBER
		The logical window number is invalid

	WL_BAD_PARAMETER
		The 'new_context_no' is not associated with
		'new_lscreen_no' or 'new_lwin_no' is NULL.

	WL_ERROR
		The 'new_context_no' is invalid.

HISTORY
	02/18/92 S.P. Rogers
		Initial definition, design and implementation
*/

{
#if defined( ENV5 )
   int sts;
   void *exnuc_data;
   void *data1;
   struct WLIwin win_struct;
   struct WLIcontext context_struct;
   struct WLIscreen screen_struct;
   struct WLnative_info native_info;
   WLuint32 colorref;

   if ( ! new_lwin_no )
   {
      WL_REPORT_ERROR( WL_BAD_PARAMETER );
      return( WL_BAD_PARAMETER );
   }

   sts = WLIcontext_retrieve_entry( new_context_no, &context_struct );
   if ( sts != WL_SUCCESS )
   {
      WL_REPORT_ERROR( sts );
      return( sts );
   }

   if ( new_lscreen_no != context_struct.lscreen_no )
   {
      WL_REPORT_ERROR( WL_BAD_PARAMETER );
      return( WL_BAD_PARAMETER );
   }

   /* get the current data for the window */
   sts = WLIwin_retrieve_entry( lwin_no, &win_struct );
   if ( sts != WL_SUCCESS )
   {
      WL_REPORT_ERROR( sts );
      return( sts );
   }

   sts = WLget_native_info( lwin_no, win_struct.context_no, &native_info );
   if ( sts != WL_SUCCESS )
   {
      WL_REPORT_ERROR( sts );
      return( sts );
   }

   /* change native info */
   sts = WLIscreen_retrieve_entry( new_lscreen_no, &screen_struct );
   if ( sts != WL_SUCCESS )
   {
      WL_REPORT_ERROR( sts );
      return( sts );
   }

   native_info.vs_no = screen_struct.native_info.screen_no;
   native_info.vlt_no = context_struct.native_info.vlt_no;

   /* add the window to the other screen */
   sts = WLIwin_add_entry( new_context_no, &native_info,
                           win_struct.hwin_no, new_lwin_no,
	                   !(win_struct.flags & WLI_WIN_FLAGS_WL_CREATED) );

   if ( sts != WL_SUCCESS )
   {
      WL_REPORT_ERROR( sts );
      return( sts );
   }

   /* install the colormap for the new window */
   sts = WLinstall_cmap( *new_lwin_no, new_context_no );
   if ( sts != WL_SUCCESS )
   {
      WL_REPORT_ERROR( sts );
      return( sts );
   }

   /* copy the user data from the old to the new window */
   sts = WLget_user_data( lwin_no, &exnuc_data, &data1 );
   if ( sts != WL_SUCCESS )
   {
      WL_REPORT_ERROR( sts );
      return( sts );
   }

   sts = WLset_user_data( *new_lwin_no, &exnuc_data, &data1 );
   if ( sts != WL_SUCCESS )
   {
      WL_REPORT_ERROR( sts );
      return( sts );
   }

   if ( context_struct.base_cmap_type == WL_CMAP_TRUE_COLOR )
   {
      WLpack_rgb_colorref( win_struct.background_red, 
                           win_struct.background_green, 
                           win_struct.background_blue, &colorref, 1 );
   }
   else
   {
      WLpack_index_colorref( win_struct.background_color_index, 
                               &colorref, 1 );
   }

   sts = WLset_background( *new_lwin_no, colorref );
   /* remove the window from the old screen */
   sts = WLIwin_delete_entry( lwin_no );
   if ( sts != WL_SUCCESS )
   {
      WL_REPORT_ERROR( sts );
      return( sts );
   }

#endif

   return ( WL_SUCCESS );

} /* WLchange_window_screen */

