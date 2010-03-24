#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "wl.h"
#include "wl_internal.h"
 
extern struct WLIscreen WLIscreens_arr[WL_MAX_SCREENS];
extern int WLIactive_screen;
extern int WLIinitialized /* = 0*/;
extern int WLIbatch_mode /* = 0*/;
extern int WLInum_phy_screens /* = 0*/;
extern int WLIreport_error /* = WLI_FALSE*/;
extern int WLISRwin_no /* = -1*/;
extern int WLIdefault_vlt_no[WL_MAX_SCREENS];
extern WLfont WLIdefault_font;
extern int WLIline_style_factor /* = WLI_FALSE*/;
extern struct WLIstyle_struct WLIline_style[WL_MAX_STYLES];
 
#if defined( WIN32 )
static char WLIwin_class_name[1000]="WLI_WINDOWS";
static char WLIapp_main_class_name[1000]="WLI_MAIN_WINDOWS";
#endif
 
#if defined( OPENGL )
extern GLUtriangulatorObj *gl_triangulator /* = NULL*/;
#endif

#if defined( XGL )
extern Xgl_sys_state sys_state/* =NULL*/;
#endif


   
/*--- WLinitialize -----------------------------------------------*/

int WLinitialize(
   struct WLinit *init_struct,
   struct WLinit_ret_val *init_ret )

/*
NAME
	WLInitialize
 
KEYWORD
	WL 
 
DESCRIPTION
	This function initializes all the data structures and other 
	information used by the WL layer. This function has to be called 
	before using any of the other function in the WL library.

SYNOPSIS
	int WLinitialize(
		struct WLinit *init_struct,
		struct WLinit_ret_val *init_ret )

PARAMETERS
	init_struct (IN) - The initialization structure. Contains information
                           required to intialize the native windowing system

	init_ret (OUT) - This values as a result of correct initialization
                         are returned in this.

NOTES
	The pointer init_struct can be NULL in X and in ENV5 but not in NT
	In ENV5 and X default values will be used if the pointer is NULL
        This routine will allocate space for the strings, namely
        app_main_class and win_class. The user is responsible for freeing them
        using WLfree
        
GLOBALS USED
	not yet
 
RETURN VALUES
	WL_SUCCESS
		Success

	WL_CANNOT_INITIALIZE
		Initialization failed

HISTORY
	08/28/92 Shridar Subramanian
		Initial definition

	10/22/92 Shridar Subramanian
		Initial design
*/
{
   int sts;
   int WLscreen_count;
   int i, j;
   int left_vs = -1;
   int right_vs = -1;
   char *err_sts;
   int err_value;
   int ll;
   int new_db_index, num_db_ctxs=0;
   WLfont font_id;
#if defined( X11 ) || defined( ENV5 )
   int k, count;
#endif   
#if defined( X11 )
   int screen_count, nitems;
   int vs_no;
   Display *display;
   XVisualInfo *vinfo, vinfo_template; 
   Widget widget;
   char *vendor;
   int double_buffer = 0;
   int event_base, error_base;
   int nmono = 0, nstereo = 0;
   XmbufBufferInfo *mono, *stereo;
   int x_separate_hilite=0;
#if defined( OPENGL )
   int db_value;
#endif
#if defined( XGL)
   Xgl_inquire *xgl_inq;
   Xgl_X_window xgl_x_win;
   Xgl_obj_desc win_desc;
#endif
#elif defined( ENV5 )
   int win_no;
   int vs_no;
   struct scr_info info[MAX_SCREENS];
   struct vlt_info vlt_info;
#elif defined( WIN32 )
   WNDCLASS WLIwin_class;
   WNDCLASS WLIapp_main_class;
   WLhwin_no hwin_no;
   int val;
#endif

   /* Check if error needs to be reported           */

   err_sts = getenv("WL_REPORT_ERROR");
   if (err_sts)
   {
      sscanf(err_sts,"%d",&err_value);
      if (err_value)
      {
         WLIreport_error = WLI_TRUE;
      }
   }

   if ( init_ret )
     memset( init_ret, 0, sizeof( struct WLinit_ret_val ) );

   if ( WLIinitialized )
   {
      WL_REPORT_ERROR( WL_CANNOT_INITIALIZE );
      return( WL_CANNOT_INITIALIZE );
   }

#if defined( WIN32 )
   if ( ( !init_struct ) || ( !init_ret ) )
   {
      WL_REPORT_ERROR( WL_CANNOT_INITIALIZE );
      return( WL_CANNOT_INITIALIZE );
   }
#endif

   if ( init_struct )
   {
      if ( init_struct->batch_mode )
      {
         WLIbatch_mode = WLI_TRUE;
      }
      else
      {
         WLIbatch_mode = WLI_FALSE;
      }
   }
   else
   {
      WLIbatch_mode = WLI_FALSE;
   }

   for ( i = 0; i < WL_MAX_SCREENS; i++ )
   {
      WLIscreens_arr[i].used = WLI_FALSE;
      WLIscreens_arr[i].db_count = 0;
      WLIdefault_vlt_no[i] = -1;
   }

#if defined( X11 )
   if ( init_struct )
   {
      if ( init_struct->flags & WL_USE_XTOOLKIT )
      {
         widget = XtInitialize( init_struct->shell_name, init_struct->app_class,
                                init_struct->options, init_struct->num_options,
                                ( int * )init_struct->argc, init_struct->argv );
         display = XtDisplay( widget );
      }
      else
      {
         display = XOpenDisplay( init_struct->display_name );
      }
   }
   else
   {
      display = XOpenDisplay( "" );
   }

   if ( !display )
   {
       WL_REPORT_ERROR( WL_CANNOT_INITIALIZE );
       return( WL_CANNOT_INITIALIZE );
   }
   if ( XmbufQueryExtension(  display , &event_base, &error_base  ) )  
   {
      double_buffer = WL_DOUBLE_BUFFER_ABILITY;
   }
   if ( init_ret )
   {
       init_ret->display = display;
       if ( ( init_struct ) && ( init_struct->flags & WL_USE_XTOOLKIT ) )
       {
          init_ret->widget = widget;
       }
   }

#if defined( XGL )
   sys_state = xgl_open(XGL_SYS_ST_ERROR_DETECTION, TRUE, NULL);
#endif

   screen_count = ScreenCount( display );
   WLInum_phy_screens = 1;
   
   /* Page 59 of the Xlib Vol 1 states that screen_num can be any number */
   /* between 0 and screen_count -1                                      */
   
   vs_no = DefaultScreen( display );
   if ( screen_count > WL_MAX_SCREENS )
   {
      WLscreen_count = WL_MAX_SCREENS;
   }
   else
   {
      WLscreen_count = screen_count;
   }
   for ( i = 0; i < WLscreen_count; i++ )
   {
      /*  Fill in the native information                          */
      if ( ( init_struct ) && ( init_struct->flags & WL_USE_XTOOLKIT ) )
      {
         WLIscreens_arr[i].native_info.widget = widget; 
      }
      else
      {
         WLIscreens_arr[i].native_info.widget = ( Widget ) NULL; 
      }
      WLIscreens_arr[i].native_info.EXdisplay = display; 
      WLIscreens_arr[i].native_info.depth = DefaultDepth( display, i);
      WLIscreens_arr[i].native_info.EXgc = DefaultGC( display, i);
      WLIscreens_arr[i].native_info.EXcolormap = DefaultColormap( display, i);
      WLIscreens_arr[i].native_info.screen_no = i;
      WLIscreens_arr[i].native_info.cursor = None;
      WLIscreens_arr[i].native_info.null_cursor = None;
#if defined( XGL )
      WLIscreens_arr[i].native_info.sys_state = sys_state;
#endif
      
      if ( vs_no == i )
      {
         WLIactive_screen = i;
      }
      WLIscreens_arr[i].used = WLI_TRUE;
   }
   vendor = ServerVendor( display );

#elif defined( ENV5 )

   if ( WLIbatch_mode )
   {
      sts = Enter_tools_no_act();
   }
   else
   {
      sts = Enter_tools();
   }

   if ( ( !WLIbatch_mode ) && ( sts != 0 ) )
   {	
      WL_REPORT_ERROR( WL_CANNOT_INITIALIZE );
      return( WL_CANNOT_INITIALIZE );
   }

   if ( !WLIbatch_mode )
   {
      sts = Inq_screen_info( info );
      if ( sts != 0 )
      {	
         WL_REPORT_ERROR( WL_CANNOT_INITIALIZE );
         return( WL_CANNOT_INITIALIZE );
      }
   }

   if ( !WLIbatch_mode )
   {
      sts = Inq_displayed_vs( &vs_no );
      if ( sts != 0 )
      {	
         WL_REPORT_ERROR( WL_CANNOT_INITIALIZE );
         return( WL_CANNOT_INITIALIZE );
      }
   }
   
   if ( MAX_SCREENS > WL_MAX_SCREENS )
   {
      WLscreen_count = WL_MAX_SCREENS;
   }
   else
   {
      WLscreen_count = MAX_SCREENS;
   }
  
   if( WLIbatch_mode )
   {
      WLscreen_count = 0;
      for ( i = 0; i < WL_MAX_SCREENS; i++ )
      {
          WLIscreens_arr[i].native_info.env5_vsi_flags = 0;
          WLIscreens_arr[i].used = WLI_FALSE;
          WLIscreens_arr[i].native_info.screen_no = 0;
          WLIscreens_arr[i].native_info.vlt_no = 0;
          WLIscreens_arr[i].pwin = NULL;
          WLIscreens_arr[i].pcontext = NULL;
          WLIscreens_arr[i].possible_contexts = NULL;
          WLIscreens_arr[i].num_possible_contexts = 0;
          WLIscreens_arr[i].flags = 0;
          WLIscreens_arr[i].db_count = 0;
      }
   }
         

   for ( i = 0; i < WLscreen_count; i++ )
   {
      /*  Fill in the native information                          */
      if ( ( info[i].vsi_screen_num != -1 ) && 
           ( info[i].vsi_flags & VSI_VIRTUAL_SCREEN ) ) 
      {
          WLIscreens_arr[i].native_info.screen_no = i;
          WLIscreens_arr[i].native_info.vlt_no = -1;
          WLIscreens_arr[i].native_info.env5_vsi_flags = info[i].vsi_flags;
          WLIscreens_arr[i].used = WLI_TRUE;
   
          if ( vs_no == i )
          {
              WLIactive_screen = i;
          }
      }
      else
      {
          WLIscreens_arr[i].native_info.env5_vsi_flags = 0;
      }
   }
   

#elif defined( WIN32 )
   
   /* Set up the application window                                        */

   WLIapp_main_class.style = CS_OWNDC | CS_BYTEALIGNCLIENT;
   if ( init_struct->app_wnd_style )
     WLIapp_main_class.style |= *(init_struct->app_wnd_style);

   /* SHOULD it be CS_VREDRAW and CS_HREDRAW ? */

   if ( init_struct->app_main_class )
   {
      strcpy( (char * ) WLIapp_main_class_name, init_struct->app_main_class );
      init_ret->app_main_class = ( LPCTSTR ) malloc(
                               strlen( init_struct->app_main_class ) + 1 );
      if ( !init_ret->app_main_class )
      {
         WL_REPORT_ERROR( WL_SYSTEM_ERROR );
         return( WL_SYSTEM_ERROR );
      }
      strcpy( (char * ) init_ret->app_main_class, init_struct->app_main_class );
   }

   /* Register the main window class                                    */

   if ( init_struct->app_wnd_proc )
   {
      WLIapp_main_class.lpfnWndProc = (WNDPROC) init_struct->app_wnd_proc;
   }
   else
   {
      WLIapp_main_class.lpfnWndProc = (WNDPROC) DefWindowProc;
   }

   WLIapp_main_class.cbClsExtra = 0;
   WLIapp_main_class.cbWndExtra = 0;
   WLIapp_main_class.hInstance = init_struct->hinstance;
   if ( init_struct->app_wnd_icon )
     WLIapp_main_class.hIcon = LoadIcon( init_struct->hinstance,
                                         init_struct->app_wnd_icon );
   else
     WLIapp_main_class.hIcon = LoadIcon( NULL, IDI_APPLICATION );
   WLIapp_main_class.hCursor = LoadCursor( NULL, IDC_ARROW );
   if ( init_struct->app_wnd_bcolor )
     WLIapp_main_class.hbrBackground = GetStockObject( *(init_struct->app_wnd_bcolor) );
   else
     WLIapp_main_class.hbrBackground = GetStockObject( BLACK_BRUSH );
   WLIapp_main_class.lpszMenuName =  init_struct->app_menu_name;
   WLIapp_main_class.lpszClassName = WLIapp_main_class_name;

   RegisterClass( &WLIapp_main_class );
   hwin_no = CreateWindow( WLIapp_main_class_name, 
                           init_struct->app_window_name, 
                           WS_OVERLAPPEDWINDOW |
                           WS_CLIPCHILDREN | WS_VSCROLL | WS_HSCROLL ,
                           CW_USEDEFAULT, CW_USEDEFAULT, CW_USEDEFAULT,
                           CW_USEDEFAULT, NULL, NULL,
                           init_struct->hinstance, NULL );

   if ( !WLIbatch_mode )
   {
      sts = ShowScrollBar( hwin_no, SB_BOTH, 0 );
      if ( !sts )
      {
         WL_REPORT_ERROR( sts );
         return( sts );
      }
      if ( init_struct->app_window_name )
      {
         SetWindowText( hwin_no, init_struct->app_window_name );
      }

      if ( init_struct->app_menu_name )
      {
        HMENU hMainMenu = GetMenu( hwin_no );

        if ( hMainMenu ) {
          HMENU hWindowMenu = GetSubMenu( hMainMenu,
                                          init_struct->app_wnd_menu_pos );

          if ( hWindowMenu ) {
            RECT rr;
            HWND mdi_win;
            CLIENTCREATESTRUCT childinfo;

            GetClientRect( hwin_no, &rr );
            childinfo.hWindowMenu = hWindowMenu;
            childinfo.idFirstChild = 1;

            mdi_win = CreateWindow( "MDICLIENT", NULL,
                                    WS_CHILD | WS_CLIPCHILDREN | WS_VISIBLE,
                                    rr.left, rr.top, rr.right, rr.bottom,
                                    hwin_no, NULL, init_struct->hinstance,
                                    &childinfo );
            if ( mdi_win ) {
              init_ret->hMainMenu = (WLhandle) hMainMenu;
              init_ret->hWindowMenu = (WLhandle) hWindowMenu;
              init_ret->app_mdi_win = (WLhwin_no) mdi_win;
            }
          }
        }
      }

      if ( init_struct->nCmdShow )
        ShowWindow( hwin_no, *(init_struct->nCmdShow) );
      else
        ShowWindow( hwin_no, SW_SHOW );
      UpdateWindow( hwin_no );
   }
   /* Fill in the return value                                   */

   init_ret->app_main_win = hwin_no;

   /* Fill in the native windowing information                    */

   WLIscreens_arr[0].native_info.hmdi_no = init_ret->app_mdi_win;
   WLIscreens_arr[0].native_info.hMainMenu = init_ret->hMainMenu;
   WLIscreens_arr[0].native_info.hWindowMenu = init_ret->hWindowMenu;
   WLIscreens_arr[0].native_info.hwin_no = hwin_no;
   WLIscreens_arr[0].native_info.hdc = GetDC( hwin_no );
   WLIscreens_arr[0].native_info.app_main_window = WLI_TRUE;
   WLIscreens_arr[0].native_info.app_main_class = 
                                   WLIapp_main_class.lpszClassName;
 
   
   /* Copy the window class name into local variables, if the name is */
   /* provided. If not use the default name                           */
 
   if ( init_struct->win_class )
   {
      strcpy( WLIwin_class_name, init_struct->win_class );
      init_ret->win_class = ( LPCTSTR ) malloc(
                                strlen( init_struct->win_class ) + 1 );
      if ( !init_ret->win_class )
      {
         WL_REPORT_ERROR( WL_SYSTEM_ERROR );
         return( WL_SYSTEM_ERROR );
      }
      strcpy( (char * ) init_ret->win_class, init_struct->win_class );
   }
   WLIwin_class.style = CS_OWNDC | CS_HREDRAW | CS_VREDRAW;
   if ( init_struct->wnd_style )
     WLIwin_class.style |= *(init_struct->wnd_style);

   /* If a callback procedure is specified, then use it else us the   */
   /* default                                                         */

   if ( init_struct->wnd_proc )
   {
      WLIwin_class.lpfnWndProc = (WNDPROC) init_struct->wnd_proc;
   }
   else
   {
      WLIwin_class.lpfnWndProc = (WNDPROC) DefWindowProc;
   }   
   WLIwin_class.cbClsExtra = 0;
   WLIwin_class.cbWndExtra = 0;
   WLIwin_class.hInstance = init_struct->hinstance;
   if ( init_struct->app_wnd_icon )
     WLIwin_class.hIcon = LoadIcon( init_struct->hinstance,
                                    init_struct->wnd_icon );
   else
     WLIwin_class.hIcon = LoadIcon( NULL, IDI_APPLICATION );
   WLIwin_class.hCursor = LoadCursor( NULL, IDC_ARROW );
   if ( init_struct->wnd_bcolor )
     WLIwin_class.hbrBackground = GetStockObject( *(init_struct->wnd_bcolor) );
   else
     WLIwin_class.hbrBackground = GetStockObject( BLACK_BRUSH );
   WLIwin_class.lpszMenuName =  NULL;
   WLIwin_class.lpszClassName = WLIwin_class_name;

   RegisterClass( & WLIwin_class);
  
   /* Fill in the native windowing information                    */
   
   WLIactive_screen = 0;
   WLIscreens_arr[0].used = WLI_TRUE;
   WLIscreens_arr[0].native_info.wnd_proc = init_struct->wnd_proc;
   WLIscreens_arr[0].native_info.hinstance = init_struct->hinstance;
   WLIscreens_arr[0].native_info.class = WLIwin_class.lpszClassName;
   WLIscreens_arr[0].native_info.cursor = NULL;
   WLscreen_count = 1;
   WLInum_phy_screens = 1;

#else
#error "A windowing system must be defined"
#endif

   /* Allocate memory for contexts and windows and fill in the screen  */
   /* structures                                                       */

   for ( i = 0; i < WLscreen_count; i++ )
   {
      WLIscreens_arr[i].pwin = ( struct WLIwin_group * ) malloc( 
                                               sizeof( struct WLIwin_group ) *
                                               WLI_MAX_WIN_GROUPS ); 

      if ( !WLIscreens_arr[i].pwin )
      {
         WL_REPORT_ERROR( WL_SYSTEM_ERROR );
         return( WL_SYSTEM_ERROR );
      }

      for ( j = 0; j < WLI_MAX_WIN_GROUPS; j++ )
      {
         WLIscreens_arr[i].pwin[j].pwin_group = NULL;
         WLIscreens_arr[i].pwin[j].num_entries_used = 0;
      }
      WLIscreens_arr[i].pcontext = ( struct WLIcontext_group * ) malloc( 
                                             sizeof( struct WLIcontext_group ) *
                                             WLI_MAX_CONTEXT_GROUPS ); 

      if ( !WLIscreens_arr[i].pcontext )
      {
         WL_REPORT_ERROR( WL_SYSTEM_ERROR );
         return( WL_SYSTEM_ERROR );
      }

      for ( j = 0; j < WLI_MAX_CONTEXT_GROUPS; j++ )
      {
         WLIscreens_arr[i].pcontext[j].pcontext_group = NULL;
         WLIscreens_arr[i].pcontext[j].num_entries_used = 0;
      }

      WLIscreens_arr[i].flags = 0x00000000;

/*
	Determine the number of contexts possible for each screen configuration
	Allocate (sizeof (struct WLcontext_info )* num of contexts possible)
	Fill in the values in this structure

	Set the pointer in each of the screen structures 
*/

#if defined( X11 )

#if defined( OPENGL )
      /* see if X server has the glX Extension */
      if ( glXQueryExtension( WLIscreens_arr[i].native_info.EXdisplay, NULL, NULL ) )
      {
         WLIscreens_arr[i].flags |= WLI_SCREEN_FLAGS_GLX_AVAILABLE;
         if ( ! gl_triangulator )
         {
            /* create a tesselation object to be used by WLdraw_polygon;  */
            /* set the callbacks to send the triangles directly to OpenGL */
            gl_triangulator = gluNewTess();
            gluTessCallback( gl_triangulator, GLU_BEGIN, glBegin );
            gluTessCallback( gl_triangulator, GLU_END, glEnd );
            gluTessCallback( gl_triangulator, GLU_VERTEX, glVertex2sv );
         }
      }
#endif
#if defined( XGL )
      if( WLIscreens_arr[i].native_info.sys_state != NULL )
      {
         WLIscreens_arr[i].flags |= WLI_SCREEN_FLAGS_XGL_AVAILABLE;
      }
#endif
      /* In X the first screen is assumed to be the primary screen and   */
      /* the rest are non-primary/secondary screens ( for WL )           */

      if ( right_vs == -1 )
      {
         WLInum_phy_screens++;
         right_vs = i;
         WLIscreens_arr[i].flags |= WLI_SCREEN_FLAGS_PRIMARY;
      }   
      else
      {
         left_vs = i;
         WLIscreens_arr[i].flags &= ~WLI_SCREEN_FLAGS_PRIMARY;
      }
   

      /* Get all the possible contexts supported by the X Server          */
      vinfo_template.screen = WLIscreens_arr[i].native_info.screen_no;
      vinfo = XGetVisualInfo( WLIscreens_arr[i].native_info.EXdisplay,
                              VisualScreenMask, &vinfo_template, &nitems );
      if ( !vinfo )
      {
         WL_REPORT_ERROR( WL_SYSTEM_ERROR );
         return( WL_SYSTEM_ERROR );
      }

      /* Get the double buffering information */
      if ( double_buffer )
      {
         XmbufGetScreenInfo( display, RootWindow( display, i ), &nmono, 
                             &mono, &nstereo, &stereo );
      }
    
      /* Add GRAYSCALE information later                                  */
#if defined( XGL )
      /* IF ZX then use separate hilite */

      xgl_x_win.X_display = display;
      xgl_x_win.X_window = RootWindow(display, DefaultScreen( display ) );
      xgl_x_win.X_screen = DefaultScreen( display );
      win_desc.win_ras.type = XGL_WIN_X;
      win_desc.win_ras.desc = &xgl_x_win;

      xgl_inq = xgl_inquire ( sys_state, &win_desc );
  
      if ( xgl_inq && (!(strcmp(xgl_inq->name,"Sun:LEO")) || 
                       !(strcmp(xgl_inq->name,"Sun:FFB")) ))
         {
         x_separate_hilite=1;
         }
      else
         {
         x_separate_hilite=0;
         }

      /*  If we're on a ZX, we need to know it because we have to limit */
      /*  the user to 15 active graphic windows (Mike Lanier...6/4/96)  */

      if ( xgl_inq && (!(strcmp(xgl_inq->name,"Sun:LEO"))) )
         WLIscreens_arr[i].flags |= WLI_SCREEN_FLAGS_ZX_ACTIVE;
#endif
 

      WLIscreens_arr[i].num_possible_contexts = 0;
      for ( k = 0; k < nitems; k++ )
      {
         if ( ( vinfo[k].class == StaticColor ) || 
              ( vinfo[k].class == DirectColor ) ||
              ( vinfo[k].class == TrueColor ) )
         {
            WLIscreens_arr[i].num_possible_contexts++;
            if ( !(strcmp( vendor, "Silicon Graphics" ) ) ||
                  ( x_separate_hilite ) ) 
            {
               if ( ( vinfo[k].class == DirectColor ) ||
                    ( vinfo[k].class == TrueColor ) )
               {
                  /* Add one for the separate hilight */
                  WLIscreens_arr[i].num_possible_contexts++;
               }
            }
        
         }
         else if  ( vinfo[k].class == PseudoColor )
         {
            WLIscreens_arr[i].num_possible_contexts++;
            if ( ( vinfo[k].depth == 5 ) || ( vinfo[k].depth == 8 ) )
            {
               /* support hilite for this depth, too */
               /* Do not support separate hilite for XGL */
               WLIscreens_arr[i].num_possible_contexts++;
               if ( !strcmp( vendor, "Silicon Graphics" ) )
               {
                  if ( vinfo[k].depth == 8 )
                  {
                     WLIscreens_arr[i].num_possible_contexts++;
                  }
               }
            }
         }
      }

      WLIscreens_arr[i].possible_contexts = ( struct WLcontext_info *) 
                                   malloc( sizeof( struct WLcontext_info )
                                   * WLIscreens_arr[i].num_possible_contexts );

      if ( !WLIscreens_arr[i].possible_contexts )
      {
          WL_REPORT_ERROR( WL_SYSTEM_ERROR );
          return( WL_SYSTEM_ERROR );
      }

      count = 0;
      for( k = 0; k < nitems; k++ )
      {                         
         if ( ( vinfo[k].class == StaticColor ) || 
              ( vinfo[k].class == PseudoColor ) ||
              ( vinfo[k].class == DirectColor ) ||
              ( vinfo[k].class == TrueColor ) )
         {
            WLIscreens_arr[i].possible_contexts[count].base_depth = 
                                                           vinfo[k].depth;
            WLIscreens_arr[i].possible_contexts[count].hilite_used = 
                                                            WL_HILITE_NOT_USED;
            WLIscreens_arr[i].possible_contexts[count].flags = 0;
#if defined( OPENGL )
            if ( WLIscreens_arr[i].flags & WLI_SCREEN_FLAGS_GLX_AVAILABLE )
            {
               glXGetConfig ( display, &vinfo[k], GLX_DOUBLEBUFFER,
                              &db_value );
               if ( db_value )
               {
                  WLIscreens_arr[i].possible_contexts[count].flags =
                                                                double_buffer;
               }
            }
#else
            for ( ll = 0; ll < nmono; ll++ )
            {
               if ( mono[ll].visualid == vinfo[k].visualid )
               {
                  WLIscreens_arr[i].possible_contexts[count].flags = 
                                                                double_buffer;
                  break;
               }
            }
#endif
     
            if ( vinfo[k].class == StaticColor )
            {
                WLIscreens_arr[i].possible_contexts[count].base_cmap_type = 
                                                            WL_CMAP_INDEXED;
                WLIscreens_arr[i].possible_contexts[count].flags |= 
                                                         WL_COLORMAP_READ_ONLY;
            }
            if ( vinfo[k].class == PseudoColor )
            {
                WLIscreens_arr[i].possible_contexts[count].base_cmap_type = 
                                                            WL_CMAP_INDEXED;

               /* Use hilite planes only on 5 and 8 bit indexed machines */
               if ( ( vinfo[k].depth == 5 ) || ( vinfo[k].depth == 8 ) )
               {
                  count++;
                  WLIscreens_arr[i].possible_contexts[count].base_depth = vinfo[k].depth - 1;
                  WLIscreens_arr[i].possible_contexts[count].base_cmap_type = 
                                                              WL_CMAP_INDEXED;
                  WLIscreens_arr[i].possible_contexts[count].flags = 
                        WLIscreens_arr[i].possible_contexts[count-1].flags; 
                  WLIscreens_arr[i].possible_contexts[count].hilite_used = 
                                                               WL_HILITE_USED;
                  if ( !strcmp( vendor, "Silicon Graphics" ) )
                  {
                     if ( vinfo[k].depth == 8 )
                     {
                         count++;
                         WLIscreens_arr[i].possible_contexts[count].base_depth = vinfo[k].depth;
                         WLIscreens_arr[i].possible_contexts[count].base_cmap_type = 
                                                              WL_CMAP_INDEXED;
                         WLIscreens_arr[i].possible_contexts[count].hilite_used = 
                                                               WL_HILITE_USED;
                         WLIscreens_arr[i].possible_contexts[count].flags = 
                           WLIscreens_arr[i].possible_contexts[count-1].flags |
                            WL_SEPARATE_HILITE;
                     }
                  } 
               }
            }
            if ( vinfo[k].class == TrueColor )
            {
                  WLIscreens_arr[i].possible_contexts[count].base_cmap_type = 
                                                            WL_CMAP_TRUE_COLOR;
                WLIscreens_arr[i].possible_contexts[count].flags |= 
                                                          WL_COLORMAP_READ_ONLY;
                if ( !strcmp( vendor, "Silicon Graphics" )  ||
                      ( x_separate_hilite ) )
                {
                   count++;
                   WLIscreens_arr[i].possible_contexts[count].base_depth = vinfo[k].depth;
                   WLIscreens_arr[i].possible_contexts[count].base_cmap_type = 
                                                             WL_CMAP_TRUE_COLOR;
                   WLIscreens_arr[i].possible_contexts[count].hilite_used = 
                                                             WL_HILITE_USED;
                   WLIscreens_arr[i].possible_contexts[count].flags = 
                     WLIscreens_arr[i].possible_contexts[count-1].flags |
                                  WL_COLORMAP_READ_ONLY | WL_SEPARATE_HILITE;
                }
                  
            }
            if ( vinfo[k].class == DirectColor )
            {
                WLIscreens_arr[i].possible_contexts[count].base_cmap_type = 
                                                            WL_CMAP_TRUE_COLOR;
                if ( !strcmp( vendor, "Silicon Graphics" )  ||
                     ( x_separate_hilite ) )
                {
                   count++;
                   WLIscreens_arr[i].possible_contexts[count].base_depth = vinfo[k].depth;
                   WLIscreens_arr[i].possible_contexts[count].base_cmap_type = 
                                                             WL_CMAP_TRUE_COLOR;
                   WLIscreens_arr[i].possible_contexts[count].hilite_used = 
                                                             WL_HILITE_USED;
                   WLIscreens_arr[i].possible_contexts[count].flags = 
                       WLIscreens_arr[i].possible_contexts[count-1].flags| 
                       WL_SEPARATE_HILITE;
                }
            }

            count++;
         }
      }                                                     
      XFree( (void * )vinfo );

/*
Take these out.  mono and stereo are pointers given to me by Xlib.
I don't know if there pointers to malloc'd memory or static arrays.
Purify grumps about it, so take it out.   12/05/95.  Mike Lanier

      if( mono != NULL )
      {
         WLI_FREE( mono );
      }
      if( stereo != NULL )
      {
         WLI_FREE( stereo );
      }
*/
         
         
            
#elif defined( ENV5 )

      if ( WLIscreens_arr[i].used )
      { 

         /* Determine the number of physical screens and the primary and    */
         /* secondary screens                                               */

         if ( WLIscreens_arr[i].native_info.env5_vsi_flags & VSI_LEFT_SCREEN )
         {
            WLInum_phy_screens++;
            if ( left_vs == -1 )
            {
               left_vs = i;
               WLIscreens_arr[i].flags &= ~WLI_SCREEN_FLAGS_PRIMARY;
            }   
         }
         else
         {
            if ( right_vs == -1 )
            {
               WLInum_phy_screens++;
               right_vs = i;
               WLIscreens_arr[i].flags |= WLI_SCREEN_FLAGS_PRIMARY;
            }   
            else
            {
               left_vs = i;
               WLIscreens_arr[i].flags &= ~WLI_SCREEN_FLAGS_PRIMARY;
            }
         }
         /* get the default indexed VLT number */
         sts = Create_win( WLIscreens_arr[i].native_info.screen_no, "", 0, 0, 10, 10, &win_no );
         if ( sts != 0 )
         {
            WL_REPORT_ERROR( WL_SYSTEM_ERROR );
            return( WL_SYSTEM_ERROR );
         }
         sts = Inq_activevltno( win_no, &WLIdefault_vlt_no[i] );
         if ( sts != 0 )
         {
            WL_REPORT_ERROR( WL_SYSTEM_ERROR );
            return( WL_SYSTEM_ERROR );
         }
         Delete_win( win_no );

      
         /* If on a true color machine the possible depths are 8, 12, 24     */
         /* We also want to allow for both highlight used and not used, hence*/
         /* 6 contexts                                                       */

         if ( WLIscreens_arr[i].native_info.env5_vsi_flags & VSI_TRC_ABILITY )
         {
            WLIscreens_arr[i].num_possible_contexts = 6;
            WLIscreens_arr[i].possible_contexts = ( struct WLcontext_info *) 
                                    malloc( sizeof( struct WLcontext_info )
                                    * WLIscreens_arr[i].num_possible_contexts );

            /* Fill in half the structures and copy the remaining half from  */
            /* the previous and only change the relevant information         */

            for ( k = 0; k < WLIscreens_arr[i].num_possible_contexts / 2; k++ )
            {
                WLIscreens_arr[i].possible_contexts[k].hilite_used =
                                                    WL_HILITE_NOT_USED;
                WLIscreens_arr[i].possible_contexts[k].flags = 0;
            }

            sts = Inq_vlt_info( i, INDEXED_COLOR_DATA, &vlt_info );
            WLIscreens_arr[i].possible_contexts[0].base_depth = 8;
            if ( vlt_info.vlti_flags & VLTI_DB_ABILITY )
            {
               WLIscreens_arr[i].possible_contexts[0].base_cmap_type = 
                                     WL_CMAP_INDEXED;
               WLIscreens_arr[i].possible_contexts[0].flags |=
                                     WL_DOUBLE_BUFFER_ABILITY;
            }
            else
            { 
               WLIscreens_arr[i].possible_contexts[0].base_cmap_type = 
                                                       WL_CMAP_INDEXED;
            }

            sts = Inq_vlt_info( i, PSEUDO_TRUE_COLOR_DATA, &vlt_info );
            WLIscreens_arr[i].possible_contexts[1].base_depth = 12;
            if ( vlt_info.vlti_flags & VLTI_DB_ABILITY )
            {
               WLIscreens_arr[i].possible_contexts[1].base_cmap_type = 
                              WL_CMAP_TRUE_COLOR;
               WLIscreens_arr[i].possible_contexts[1].flags |= 
                              WL_DOUBLE_BUFFER_ABILITY;
            }
            else
            { 
               WLIscreens_arr[i].possible_contexts[1].base_cmap_type = 
                                                       WL_CMAP_TRUE_COLOR;
            }

            sts = Inq_vlt_info( i, TRUE_COLOR_DATA, &vlt_info );
            WLIscreens_arr[i].possible_contexts[2].base_depth = 24;
            if ( vlt_info.vlti_flags & VLTI_DB_ABILITY )
            {
               WLIscreens_arr[i].possible_contexts[2].base_cmap_type = 
                              WL_CMAP_TRUE_COLOR;
               WLIscreens_arr[i].possible_contexts[2].flags |= 
                              WL_DOUBLE_BUFFER_ABILITY;
            }
            else
            { 
               WLIscreens_arr[i].possible_contexts[2].base_cmap_type = 
                                                       WL_CMAP_TRUE_COLOR;
            }

            /* Copy the information                                      */ 

            count = WLIscreens_arr[i].num_possible_contexts / 2;
            for ( k = 0; k < WLIscreens_arr[i].num_possible_contexts / 2; k++ )
            {
                WLIscreens_arr[i].possible_contexts[k + count] =  
                                       WLIscreens_arr[i].possible_contexts[k];
                WLIscreens_arr[i].possible_contexts[k + count].hilite_used =
                                                               WL_HILITE_USED;
            }

         }
         else
         {
            /* If the number of planes is > 8 then we want to allow for both */
            /* highlight used and highlight not used                         */

            sts = Inq_vlt_info( i, INDEXED_COLOR_DATA, &vlt_info );
            if ( info[WLIscreens_arr[i].native_info.screen_no].vsi_num_planes >
                  8 )
            {
                WLIscreens_arr[i].num_possible_contexts = 2;
                WLIscreens_arr[i].possible_contexts = ( struct WLcontext_info *)
                                   malloc( sizeof( struct WLcontext_info )
                                   * WLIscreens_arr[i].num_possible_contexts );
                if ( !WLIscreens_arr[i].possible_contexts )
                {
                   WL_REPORT_ERROR( WL_SYSTEM_ERROR );
                   return( WL_SYSTEM_ERROR );
                }



                WLIscreens_arr[i].possible_contexts[1].base_depth = 
                info[WLIscreens_arr[i].native_info.screen_no].vsi_num_planes - 1;
                WLIscreens_arr[i].possible_contexts[1].hilite_used = 
                                                       WL_HILITE_USED;
                WLIscreens_arr[i].possible_contexts[1].base_cmap_type = 
                                                            WL_CMAP_INDEXED;
                if ( vlt_info.vlti_flags & VLTI_DB_ABILITY )
                {
                   WLIscreens_arr[i].possible_contexts[1].flags = WL_DOUBLE_BUFFER_ABILITY;
                }
                else
                {
                   WLIscreens_arr[i].possible_contexts[1].flags = 0;
                }

                /* If the machine is an Edge1                               */

                if ( ( info[WLIscreens_arr[i].native_info.screen_no].vsi_num_planes == 9 ) &&
                     (info[WLIscreens_arr[i].native_info.screen_no].vsi_VLT_size == 256 ) ) 
                {
                   WLIscreens_arr[i].possible_contexts[0].base_depth = 
                  info[WLIscreens_arr[i].native_info.screen_no].vsi_num_planes - 1;
                   WLIscreens_arr[i].possible_contexts[0].hilite_used = 
                                                           WL_HILITE_NOT_USED;
                   WLIscreens_arr[i].possible_contexts[0].base_cmap_type = 
                                                           WL_CMAP_INDEXED;
                   if ( vlt_info.vlti_flags & VLTI_DB_ABILITY )
                   {
                      WLIscreens_arr[i].possible_contexts[0].flags = WL_DOUBLE_BUFFER_ABILITY;
                   }
                   else
                   {
                      WLIscreens_arr[i].possible_contexts[0].flags = 0;
                   }
                }
                else
                {
                   WLIscreens_arr[i].possible_contexts[0].base_depth = 
                  info[WLIscreens_arr[i].native_info.screen_no].vsi_num_planes;
                   WLIscreens_arr[i].possible_contexts[0].hilite_used = 
                                                           WL_HILITE_NOT_USED;
                   WLIscreens_arr[i].possible_contexts[0].base_cmap_type = 
                                                           WL_CMAP_INDEXED;
                   if ( vlt_info.vlti_flags & VLTI_DB_ABILITY )
                   {
                      WLIscreens_arr[i].possible_contexts[0].flags = WL_DOUBLE_BUFFER_ABILITY;
                   }
                   else
                   {
                      WLIscreens_arr[i].possible_contexts[0].flags = 0;
                   }
                }
            }
            else
            {
                WLIscreens_arr[i].num_possible_contexts = 2;
                WLIscreens_arr[i].possible_contexts = ( struct WLcontext_info *)
                                    malloc( sizeof( struct WLcontext_info )
                                    * WLIscreens_arr[i].num_possible_contexts );
       
                if ( !WLIscreens_arr[i].possible_contexts )
                {
                    WL_REPORT_ERROR( WL_SYSTEM_ERROR );
                    return( WL_SYSTEM_ERROR );
                }
                WLIscreens_arr[i].possible_contexts[0].base_depth = 
                  info[WLIscreens_arr[i].native_info.screen_no].vsi_num_planes;
                WLIscreens_arr[i].possible_contexts[0].hilite_used = 
                                                          WL_HILITE_NOT_USED;
                WLIscreens_arr[i].possible_contexts[0].base_cmap_type = 
                                                           WL_CMAP_INDEXED;
                if ( vlt_info.vlti_flags & VLTI_DB_ABILITY )
                {
                   WLIscreens_arr[i].possible_contexts[0].flags = WL_DOUBLE_BUFFER_ABILITY;
                }
                else
                {
                   WLIscreens_arr[i].possible_contexts[0].flags = 0;
                }

                WLIscreens_arr[i].possible_contexts[1].base_depth = 
               info[WLIscreens_arr[i].native_info.screen_no].vsi_num_planes -1;
                WLIscreens_arr[i].possible_contexts[1].hilite_used = 
                                                          WL_HILITE_USED;
                WLIscreens_arr[i].possible_contexts[1].base_cmap_type = 
                                                           WL_CMAP_INDEXED;
                if ( vlt_info.vlti_flags & VLTI_DB_ABILITY )
                {
                   WLIscreens_arr[i].possible_contexts[1].flags = WL_DOUBLE_BUFFER_ABILITY;
                }
                else
                {
                   WLIscreens_arr[i].possible_contexts[1].flags = 0;
                }

            }
         
         }
      }
#elif defined( WIN32 )

      if ( right_vs == -1 )
      {
         WLInum_phy_screens++;
         right_vs = i;
         WLIscreens_arr[i].flags |= WLI_SCREEN_FLAGS_PRIMARY;
      }   
      else
      {
         left_vs = i;
         WLIscreens_arr[i].flags &= ~WLI_SCREEN_FLAGS_PRIMARY;
      }
   

      WLIscreens_arr[i].num_possible_contexts = 1;
      WLIscreens_arr[i].possible_contexts = ( struct WLcontext_info *) 
                                malloc( sizeof( struct WLcontext_info )
                                * WLIscreens_arr[i].num_possible_contexts );

      if ( !WLIscreens_arr[i].possible_contexts )
      {
         WL_REPORT_ERROR( WL_SYSTEM_ERROR );
         return( WL_SYSTEM_ERROR );
      }

      WLIscreens_arr[i].possible_contexts[0].base_depth = 
                    GetDeviceCaps( WLIscreens_arr[i].native_info.hdc, PLANES ) *
                    GetDeviceCaps( WLIscreens_arr[i].native_info.hdc, BITSPIXEL );
      WLIscreens_arr[i].possible_contexts[0].hilite_used = WL_HILITE_NOT_USED;
      WLIscreens_arr[i].possible_contexts[0].base_cmap_type = WL_CMAP_INDEXED;

      val = GetDeviceCaps(WLIscreens_arr[i].native_info.hdc, RASTERCAPS );
      if ( !( val & RC_PALETTE ) )
      {
         WLIscreens_arr[i].possible_contexts[0].flags = WL_COLORMAP_READ_ONLY
                                                        | WL_SYSTEM_COLORMAP;
      }
      else
      {
         WLIscreens_arr[i].possible_contexts[0].flags = 0;
      }
   
#else
#error "A windowing system must be defined "
#endif

      /* Adding support for non double buffered contexts */
      for ( ll = 0; ll <   WLIscreens_arr[i].num_possible_contexts; ll ++ )    
      {
         if (  WLIscreens_arr[i].possible_contexts[ll].flags & 
               WL_DOUBLE_BUFFER_ABILITY )
         {
            num_db_ctxs++;
         }
      }
      if ( num_db_ctxs )
      {
         WLIscreens_arr[i].possible_contexts = realloc ( 
                                                 WLIscreens_arr[i].possible_contexts,
                                                 sizeof ( struct WLcontext_info ) *
                                                 ( WLIscreens_arr[i].num_possible_contexts +
                                                 num_db_ctxs ) );  
         new_db_index = WLIscreens_arr[i].num_possible_contexts;                                     
         for ( ll = 0; ll <   WLIscreens_arr[i].num_possible_contexts; ll ++ )   
         {
            if (  WLIscreens_arr[i].possible_contexts[ll].flags & 
                  WL_DOUBLE_BUFFER_ABILITY )
            {
               memcpy( &WLIscreens_arr[i].possible_contexts[new_db_index],
                       &WLIscreens_arr[i].possible_contexts[ll],
                       sizeof ( struct WLcontext_info ) );
               WLIscreens_arr[i].possible_contexts[new_db_index].flags &=
                                          (~WL_DOUBLE_BUFFER_ABILITY);
               new_db_index++;
            }     
         }
         WLIscreens_arr[i].num_possible_contexts += num_db_ctxs;
         num_db_ctxs = 0;   
      
      }
   }

   /* Initialize the line style array                                   */
   for ( i = 0; i < WL_MAX_STYLES; i++ )
   {
      WLIline_style[i].nitems = 0;
      WLIline_style[i].offset = 0;
      WLIline_style[i].flags = (WLuint32 )WLI_STYLE_SOLID;
      WLIline_style[i].pattern =( short ) 0xffff;
      WLIline_style[i].change_count = 0;
   }

   /* initialize the default fonts for the screens */
   for ( i = 0; i < WLscreen_count; i++ )
   {
      if ( WLIscreens_arr[i].used )
      {
         WLload_font( i, WLI_TEXT_FONT, &font_id );
         WLinit_default_colormap( i );
      }

   }
   WLIdefault_font = font_id;

   WLIinitialized = WLI_TRUE;
   return( WL_SUCCESS );
}
	
	

