#ifndef wl_include
#define wl_include 1
#if defined( OPENGL )
#include <GL/gl.h>
#include <GL/glu.h>
#endif

#if defined ( XGL )
#ifndef PPL
#include <xgl/xgl.h>
#endif
#endif

#if defined( X11 )

/*#include <X11/Xlibint.h>*/
#include <X11/Xlib.h>
#include <X11/Xutil.h>
#include <X11/Xresource.h>
#include <X11/StringDefs.h>
#include <X11/IntrinsicP.h>
#include <X11/Intrinsic.h>
#include <X11/extensions/multibuf.h>
#if defined( SUNOS54 ) || defined( SUNOS55 )
#include <X11/extensions/transovl.h>
#endif
#if defined( OPENGL )
#include <GL/glx.h>
#else
typedef void *GLXContext;
#endif

#elif defined( ENV5 )

#include "tools.h"

#elif defined( WIN32 )

#include "windef.h"
#include "winuser.h"
#include "wingdi.h"

#endif

typedef unsigned int 	WLuint32;
typedef unsigned short 	WLuint16;
typedef unsigned char	WLuint8;
typedef int 		WLint32;
typedef short 		WLint16;
typedef char 		WLint8;
typedef WLuint32        WLcolorref;

#if defined( X11 )

typedef Window	        WLhwin_no;
typedef void 	        *WLhandle;
typedef void 	        *WLwndproc;
typedef Cursor          WLcursor;
typedef Colormap        WLcolormap;
typedef XImage		*WLfast_buffer;
typedef Font            WLfont;

#elif defined( ENV5 )

typedef int	        WLhwin_no;
typedef void 	        *WLhandle;
typedef void 	        *WLwndproc;
typedef int             WLcursor;
typedef int             WLcolormap;
typedef int		WLfast_buffer;
typedef int             WLfont;

#elif defined( WIN32 )

typedef HANDLE	        WLhandle;
typedef WNDPROC         WLwndproc;
typedef HWND	        WLhwin_no;
typedef HCURSOR         WLcursor;
typedef HPALETTE        WLcolormap;
typedef HDC		WLfast_buffer;
typedef HFONT           WLfont;

#else
#error " A windowing system must be defined"
#endif

#if defined( X11 )

struct WLinit
{
   char   *display_name;
   int    batch_mode;                 /* Indicates whether the application   */
                                      /* should run in batch_mode            */
   int    flags;                      /* WL_USE_XTOOLKIT                     */
   char   *shell_name;
   char   *app_class;
   XrmOptionDescRec  *options;
   Cardinal  num_options;
   Cardinal  *argc;
   char      **argv;
};

struct WLinit_ret_val
{
   Display *display;
   Widget  widget;  /* Returned only if Xtoolkit is used and WL_USE_XTOOLKIT */
                    /* is set                                                */
};

#elif defined( WIN32 )

struct WLinit
{
   WLhandle     hinstance;
   WLwndproc    wnd_proc;             /* Callback for the windows(other than
                                         main window                         */
   WLwndproc    app_wnd_proc;         /* Call back for the main window       */
   char         *app_window_name;     /* Window name for the main window     */
   LPCTSTR      app_main_class;       /* Class name of the main window       */
   LPCTSTR      win_class;            /* Class name for the windows          */
   int          batch_mode;           /* Indicates whether the application   */
                                      /* should run in batch_mode            */
   int          *nCmdShow;            /* how to display the app main window
                                         initially                           */
   int          *app_wnd_bcolor;      /* background color for main window    */
   int          *wnd_bcolor;          /* background color for windows(other
                                         than main window                    */
   LPCTSTR      app_menu_name;        /* Menu name for main window           */
   int          app_wnd_menu_pos;     /* the position of the window menu
                                         pulldown in the app menu relative to
                                         0                                   */
   UINT         *app_wnd_style;       /* application addon style bits for
                                         main window                         */
   UINT         *wnd_style;           /* application addon style bits for
                                         windows(other than main window)     */
   LPCTSTR      app_wnd_icon;         /* Name of icon resource for minimizing
                                         main window                         */
   LPCTSTR      wnd_icon;             /* Name of icon resource for minimizing
                                         windows(other than main window)     */
};

struct WLinit_ret_val
{
   WLhwin_no   app_main_win;
   WLhwin_no   app_mdi_win;
   WLhandle    hMainMenu;
   WLhandle    hWindowMenu;
   LPCTSTR     app_main_class;
   LPCTSTR     win_class;
};
#elif defined( ENV5 )

struct WLinit
{
   int    batch_mode;     /*Indicates whether the application should run in
                            batch_mode                                    */
};

struct WLinit_ret_val
{
   int   dummy;
};

#else
#error " A windowing system must be defined"
#endif   


#if defined( X11 )

struct WLnative_info
{
   Display       *display;
   GC            gc;
   GC            hl_gc;
   WLhwin_no     base_win;
   WLhwin_no     hl_win;
   WLcolormap    colormap;
   WLcolormap    hl_colormap;
   Visual        *visual;
   Visual        *hl_visual;
   int           screen;
   WLcursor      cursor;
   int           flags;
#if defined( OPENGL )
   GLXContext    glx_context;
   GLXContext    hl_glx_context;
#endif
#if defined( XGL )
#ifndef PPL
   Xgl_sys_state sys_state;
   Xgl_object xgl_context_3D;
   Xgl_object hl_xgl_context_3D;
   Xgl_object xgl_base_cmap;
   Xgl_object xgl_hilite_cmap;
   Xgl_win_ras win_ras;
   Xgl_win_ras hl_win_ras;
   Xgl_mem_ras mem_ras;
   Xgl_mem_ras hl_mem_ras;
   Xgl_color_type_supported xgl_color_type;
   Xgl_hlhsr_mode           xgl_hlhsr_mode;
#endif
#endif
};

#elif defined( ENV5 )

struct WLnative_info
{
   int           vs_no;
   WLhwin_no     base_win;
   WLcolormap    vlt_no;
   WLcursor      cursor;
};

#elif defined( WIN32 )

struct WLnative_info
{
   WLhwin_no     mdi_win;
   WLhwin_no     base_win;
   HDC           hdc;
   WLcursor      cursor;
   WLcolormap    palette;
   LPCTSTR       class;
   WLhandle      hinstance;
   WLwndproc     wnd_proc;
   WLhandle      hMainMenu;
   WLhandle      hWindowMenu;
};

#else
#error " A windowing system must be defined"
#endif
 
struct WLcontext_info
{
   int           base_cmap_type;
   int           base_depth;
   int           hilite_used;
   int           flags;
};

struct WLcontext_interaction
{
   WLuint32 	context_no;
   int 		number;
   int 		num_of_coexists;
};

struct WLbounds
{
   int 		x,y;        /* Upper left corner coordinates */
   int 		width;
   int 		height;
};

struct WLcmap_entry
{
   WLuint16 	slot;
   WLuint16 	red,green,blue;
   WLuint32 	flags;
};

/*
 * NOTE: Slow buffering enables memory examination after WLget_raster_data
 * is called. Call WLcreate_image with WL_SLOW_BUFFER for buffer_type to
 * disable fast buffering on hardware which supports it (i.e. some
 * Intergraph hardware). To enable, set buffer_type to WL_FAST_BUFFER)
 */


struct WLraster_data
{
   int          x,y;
   WLuint32     width, height;
   char         *buffer;
   WLuint16	lras_no;
};

#if defined( X11 ) || defined( ENV5 )

struct WLpoint
{
   short 	x,y;
};

#elif defined( WIN32 )

struct WLpoint
{
   long 	x,y;
};

#else
#error "A windowing system must be defined"
#endif

struct WLrect
{
   int 		x,y;
   int 		width,height;
};

#if defined( XGL )
#ifndef PPL
extern Xgl_sys_state sys_state;
#endif
#endif


#define WL_USE_XTOOLKIT         0x00000001

/* color map types */
#define WL_CMAP_TRUE_COLOR	0x00000001
#define WL_CMAP_INDEXED		0x00000002
#define WL_CMAP_GRAY_SCALE	0x00000004

/* base and hilite modes */
#define WL_BASE_NOOP		0x00000001
#define WL_BASE_DRAW		0x00000002
#define WL_BASE_ERASE		0x00000003

#define WL_HILITE_NOOP		0x00000004
#define WL_HILITE_DRAW		0x00000008
#define WL_HILITE_ERASE		0x0000000C

#define WL_BASE_MASK		0x00000003
#define WL_HILITE_MASK		0x0000000C

/* image types */
#define WL_IMAGE_TRUE_COLOR	0x00000001
#define WL_IMAGE_LOG_INDEXED	0x00000002
#define WL_IMAGE_PHY_INDEXED	0x00000003

/* Turn off/on fast buffering */
#define WL_SLOW_BUFFER		0
#define WL_FAST_BUFFER		1
 
/* Logical screen numbers start at 0 */
#define WL_MAX_SCREENS			10
#define WL_MAX_WINDOWS_POSSIBLE		1000
#define WL_MAX_CONTEXTS_POSSIBLE	1000

#define WL_MAX_WEIGHT		31
#define WL_MAX_STYLES		256
#define WL_MAX_COLOR		65535

/* fill flag */
#define WL_NO_FILL		0x00000001
#define WL_FILL			0x00000002

/* hilite_used flag */
#define WL_HILITE_NOT_USED	0x00000000
#define WL_HILITE_USED		0x00000001

/* color flags */
#define WL_COLOR_RGB		0x80000000
#define WL_COLOR_PHYSICAL	0x40000000

/* Context flags */
#define WL_COLORMAP_READ_ONLY  		0x00000001
#define WL_SYSTEM_COLORMAP     		0x00000002
#define WL_COLORMAP_SAVE_RESTORE	0x00000004  
#define WL_USING_OPENGL			0x00000008
#define WL_SAVE_RESTORE_CONTEXT		0x00000010
#define WL_SEPARATE_HILITE              0x00000020
#define WL_DOUBLE_BUFFER_ABILITY        0x00000040
#define WL_USING_XGL			0x00000080

/* Native info flags */
#define WL_NI_SEPARATE_HILITE  		0x00000001


/* Indicates the context in the active window structure */
/* should be used.                                      */
#define WL_DEFAULT_CONTEXT		0xffffffff
#define WL_UNDEFINED_WINDOW		0xffffffff
#define WL_UNDEFINED_VALUE		0xffffffff

/* Symbology flags */
#define WL_SYMB_CHANGE_COLOR	0x00000001
#define WL_SYMB_CHANGE_STYLE	0x00000002
#define WL_SYMB_CHANGE_WEIGHT	0x00000004

/* collapse flags */
#define WL_NOT_COLLAPSED	0x00000000
#define WL_COLLAPSED		0x00000001

/* Dynamics drawing modes */
#define WL_DYN_DRAW_MODE        0x00000000
#define WL_DYN_ERASE_MODE       0x00000001

/* Screen types  */
#define WL_SCREEN_PRIMARY       1
#define WL_SCREEN_SECONDARY     2
#define WL_SCREEN_OTHER         3
#define WL_SCREEN_CURRENT       4

/* GLX window type flags */
#define WL_GLX_BASE_WIN    0x00000001
#define WL_GLX_HILITE_WIN  0x00000002

/* error codes */
#define WL_SUCCESS			0x00000000
#define WL_BAD_SCREEN_NUMBER		0x00000001
#define WL_BAD_WINDOW_NUMBER		0x00000002
#define WL_BAD_COLOR_MAP		0x00000003  
#define WL_BAD_EVENT_MASK		0x00000004
#define WL_BAD_WINDOW_BOUNDS		0x00000005
#define WL_BAD_MODE			0x00000006
#define WL_BAD_CONTEXT			0x00000007
#define WL_BAD_COLOR_INDEX		0x00000008
#define WL_BAD_WEIGHT			0x00000009
#define WL_BAD_POINTS			0x0000000A
#define WL_BAD_SLOT_NUMBER		0x0000000B
#define WL_BAD_DISPLAY_BUFFER_SIZE	0x0000000C
#define WL_BAD_DISPLAY_ORIGIN		0x0000000D
#define WL_BAD_DISPLAY_BUFFER		0x0000000E
#define WL_BAD_PARAMETER		0x0000000F
#define WL_BAD_FLAG			0x00000010
#define WL_BAD_COLOR_SPECIFICATION	0x00000011
#define WL_BAD_STYLE_NUMBER		0x00000012
#define WL_SYSTEM_ERROR			0x00000013
#define WL_CANNOT_INITIALIZE		0x00000014
#define WL_BAD_RGB			0x00000015
#define WL_BAD_HARDWARE_WINDOW		0x00000016	
#define WL_BAD_PHYSICAL_SCREEN		0x00000017	
#define WL_BAD_RECTANGLE		0x00000018
#define WL_ERROR			0x00000019
#define WL_READ_ONLY			0x0000001A
#define WL_BAD_IMAGE			0x0000001B
#define WL_NO_HILITE_PLANE		0x0000001C
#define WL_DB_NOT_POSSIBLE		0x0000001D
#define WL_BAD_COLOR_REF		0x0000001E
#define WL_NOT_IN_DYNAMICS		0x0000001F
#define WL_NO_DEFAULT_COLORMAP		0x00000020

/* Event masks */
#define WL_BUTTON			0x00000001
#define WL_KEY				0x00000002
#define WL_REFRESH			0x00000004
#define WL_USER				0x00000008
#define WL_SWAP_SCREEN			0x00000010
#define WL_TIMER			0x00000020
#define WL_DELETE			0x00000040
#define WL_EXPOSE			0x00000080
#define WL_ENTER_LEAVE_WIN		0x00000100
#define WL_POINTER_MOTION		0x00000200
#define WL_COLLAPSE			0x00000400
#define WL_VISIBILITY			0x00000800
#define WL_COLORMAP_NOTIFY		0x00001000

#if defined(__STDC__) || defined(__cplusplus)
#define __(p) p
#else
#define __(p) ()
#endif

extern int WLadd_hardware_window __((
   WLhwin_no hwin_no,
   WLuint32 context_no,
   struct WLnative_info *native_info,
   WLuint32 *lwin_no));
   
extern int WLset_num_wm_colors __((
   WLint32 num_wm_colors ));
   
extern int WLset_num_ingr_colors __((
   WLint32 num_ingr_colors ));

extern int WLchange_window_cmap __((
   WLuint16 lscreen_no,
   WLuint32 lwin_no,
   WLuint32 context_no ));

extern int WLcreate_context __((
   WLuint16 lscreen_no,
   struct WLcontext_info *context,
   int (*cmap_color_to_index)(
      WLuint32 context_no,
      WLuint32 index,
      WLuint32 red,
      WLuint32 green,
      WLuint32 blue,
      WLuint32 flag,
      WLuint32 *phy_index ),
   int (*cmap_color_to_rgb)(
      WLuint32 context_no,
      WLuint32 index,
      WLuint32 red,
      WLuint32 green,
      WLuint32 blue,
      WLuint32 flag,
      WLuint32 *out_red,
      WLuint32 *out_green,
      WLuint32 *out_blue ),
   int (*cmap_init)(
      WLuint32 context_no ),
   WLuint32 *context_no));

extern int WLcreate_window __((
   WLuint16 lscreen_no,
   char *name,
   struct WLbounds *bounds,
   int border_width,
   WLuint32 context_no,
   WLuint32 *lwin_no ));

extern int WLdelete_context __((
   WLuint16 lscreen_no,
   WLuint32 context_no));

extern int WLdelete_window __((
   WLuint32 lwin_no ));

extern int WLinitialize __((
   struct WLinit *init_struct,
   struct WLinit_ret_val *init_ret ));
 
extern int WLflush __((
   WLuint32 lwin_no ));

extern int WLfree __((
   void *ptr ));
 
extern int WLget_active_screen __((
   WLuint16 *lscreen_no,
   int *screen_type ));
 
extern int WLget_context_depth __((
    WLuint32 context_no,
    int *depth ));
 
extern int WLget_number_of_screens __((
   int *num_screens,
   WLuint16 **list_of_screens ));
 
extern int WLget_logical_screen_from_window __((
   WLhwin_no hwin_no,
   WLuint16 *lscreen_no));
 
extern int WLget_logical_screen_from_screen __((
   int screen_no,
   WLuint16 *lscreen_no));
 
extern int WLget_window_name __((
   WLuint32 lwin_no,
   char **name ));
 
extern int WLget_logical_window __((
   WLhwin_no hwin_no,
   WLuint32 *lwin_no));
 
extern int WLget_native_info __((
   WLuint32 lwin_no,
   WLuint32 context_no,
   struct WLnative_info *native_info));
 
extern int WLget_screen_depth __((
   WLuint16 lscreen_no,
   int hilite_used,
   int *depth ));
 
extern int WLget_screen_size __((
   WLuint16 lscreen_no,
   int *width,
   int *height ));
 
extern int WLget_window_screen __((
   WLuint32 lwin_no,
   WLuint16 *lscreen_no ));
 
extern int WLbell __((
   WLuint32 lwin_no,
   int percent ));
 
extern int WLget_user_data __((
   WLuint32 lwin_no,
   void **exnuc_data,
   void **data1));
 
extern int WLget_collapse_parms __((
   WLuint32 lwin_no,
   int *x,
   int *y));
 
extern int WLset_user_data __((
   WLuint32 lwin_no,
   void **exnuc_data,
   void **data1));
 
extern int WLset_collapse_parms __((
   WLuint32 lwin_no,
   int x,
   int y,
   int collapse_state ));
 
extern int WLpack_rgb_colorref __((
   WLuint32 red,
   WLuint32 green,
   WLuint32 blue,
   WLcolorref *color_ref,
   WLuint32 physical));
 
extern int WLpack_index_colorref __((
   WLuint32 color_index,
   WLcolorref *color_ref,
   WLuint32 physical));
 
extern int WLmap_colorref __((
   WLuint32 lwin_no,
   WLcolorref color_ref,
   WLuint32 *color_index,
   WLuint32 *red,
   WLuint32 *green,
   WLuint32 *blue,
   WLuint32 *color_flag));
 
extern int WLset_window_name __((
   WLuint32 lwin_no,
   char *new_name ));
 
extern int WLset_active_symbology __((
   WLuint32 lwin_no,
   WLcolorref color_ref,
   int lstyle_no,
   WLuint16 blend,
   int weight,
   int change_mask ));

extern int WLset_clip_box __((
   WLuint32 lwin_no,
   WLuint32 context_no,
   int xmin,
   int ymin,
   int width,
   int height));
 
extern int WLread_cmap_entries __((
   WLuint32 context_no,
   int num_entries,
   struct WLcmap_entry *cmap_entries ));
 
extern int WLget_number_of_contexts_possible __((
   WLuint16 lscreen_no,
   WLuint32 context_no,
   int *num_possible ));

extern int WLget_screen_contexts __((
   WLuint16 lscreen_no,
   int base_cmap_type,
   int hilite_used,
   int *num_contexts,
   struct WLcontext_info **contexts ));
 
extern int WLset_window_bounds __((
   WLuint32 lwin_no,
   struct WLbounds *bounds ));

extern int WLget_window_bounds __((
   WLuint32 lwin_no,
   struct WLbounds *bounds,
   struct WLbounds *area_bounds ));
 
extern int WLget_window_contexts __((
   WLuint32 lwin_no,
   int *num_contexts,
   WLuint32 **context_no,
   struct WLcontext_info **contexts ));
 
extern int WLget_context_info __((
   WLuint32 context_no,
   struct WLcontext_info *context_info));
 
extern int WLload_cmap_entries __((
   WLuint32 context_no,
   int num_entries,
   struct WLcmap_entry *cmap_entries ));

extern int WLblock_move __((
   WLuint32 lwin_no,
   WLuint32 context_no,
   int src_x,
   int src_y,
   int width,
   int height,
   int dest_x,
   int dest_y));

extern int WLclear_window __((
   WLuint32 lwin_no ));

extern int WLdisplay_window __((
   WLuint32 lwin_no ));

extern int WLdraw_2D_line_string __((
   WLuint32 lwin_no,
   int npoints,
   struct WLpoint *points ));

extern int WLdraw_2D_point_string __((
   WLuint32 lwin_no,
   int npoints,
   struct WLpoint *points ));

extern int WLdraw_polygon __((
   WLuint32 lwin_no,
   int num_points,
   struct WLpoint *points,
   WLuint32 fill));

extern int WLdraw_rectangle __((
   WLuint32 lwin_no,
   struct WLrect *rect,
   WLuint32 fill));

extern int WLget_defined_style __((
   int lstyle_no,
   WLuint16 *pattern ));

extern int WLget_raster_data __((
   WLuint32 lwin_no,
   WLuint32 context_no,
   struct WLraster_data *image));

extern int WLhide_cursor __((
   WLuint32 lwin_no,
   WLuint32 flag ));

extern int WLmouse_position __((
   WLuint32 lwin_no,
   int *x,
   int *y,
   int *in_window,
   /* unsigned */ int *key_buttons)); /*  (SHOULD WE USE KEY_BUTTONS) */

extern int WLpop_window_to_top __((
   WLuint32 lwin_no));

extern int WLpop_window_to_bottom __((
   WLuint32 lwin_no));

extern int WLput_raster_data __((
   WLuint32 lwin_no,
   WLuint32 context_no,
   struct WLraster_data *image));

extern int WLshow_cursor __((
   WLuint32 lwin_no ));

extern int WLdefine_style __((
   int lstyle_no,
   WLuint16 pattern ));



extern int WLdefine_cursor __((
   WLuint32 lwin_no,
   char *data,
   char *mask,
   int length,
   int width,
   int lfgcolor,
   int lbgcolor,
   int x_hot,
   int y_hot));

 
extern int WLcreate_raster_data __((
   WLuint32 win_no,
   WLuint32 context_no,
   struct WLraster_data *image,
   int x,
   int y,
   int width,
   int height,
   int bits_per_pixel,
   WLuint32 buffer_type,
   char *buffer));
 
extern int WLfree_raster_data __((
   struct WLraster_data *image));

extern int WLcreate_context_native_info __((
   WLuint16 lscreen_no,
   struct WLcontext_info *context,
   int (*cmap_color_to_index)(
      WLuint32 context_no,
      WLuint32 index,
      WLuint32 red,
      WLuint32 green,
      WLuint32 blue,
      WLuint32 flag,
      WLuint32 *phy_index ),
   int (*cmap_color_to_rgb)(
      WLuint32 context_no,
      WLuint32 index,
      WLuint32 red,
      WLuint32 green,
      WLuint32 blue,
      WLuint32 flag,
      WLuint32 *out_red,
      WLuint32 *out_green,
      WLuint32 *out_blue ),
   int (*cmap_init)(
      WLuint32 context_no ),
   struct WLnative_info *native_info,
   WLuint32 *context_no));

extern int WLenter_dynamics __((
   WLuint32 lwin_no));

extern int WLexit_dynamics __((
   WLuint32 lwin_no));

extern int WLset_event_mask __((
   WLuint32 lwin_no,
   WLuint32 event_mask));

extern int WLget_event_mask __((
   WLuint32 lwin_no,
   WLuint32 *event_mask));

extern int WLsync_buffers __((
   WLuint32 lwin_no));
 
extern int WLenter_db __((
   WLuint32 lwin_no ));

extern int WLexit_db __((
   WLuint32 lwin_no ));

extern int WLdraw_text __((
   WLuint32 lwin_no,
   int x,
   int y,
   char *text,
   int length ));

extern int WLdraw_bitmap __((
   WLuint32 lwin_no,
   int x_org,
   int y_org,
   int width,
   int height,
   unsigned char *bitmap ));

extern int WLset_dynamics_drawing_mode __((
   WLuint32 lwin_no,
   int mode ));

extern int WLexit __((
   void ));

extern int WLactivate_symbology __((
   WLuint32 lwin_no,
   int fill_flag,
   int force_flag ));

extern int WLget_window_base_context __((
   WLuint32 lwin_no,
   WLuint32 *base_context_no ));

extern int WLchange_context_color_functions __((
   WLuint32 context_no,
   int (*cmap_color_to_index)(
      WLuint32 context_no,
      WLuint32 index,
      WLuint32 red,
      WLuint32 green,
      WLuint32 blue,
      WLuint32 flag,
      WLuint32 *phy_index ),
   int (*cmap_color_to_rgb)(
      WLuint32 context_no,
      WLuint32 index,
      WLuint32 red,
      WLuint32 green,
      WLuint32 blue,
      WLuint32 flag,
      WLuint32 *out_red,
      WLuint32 *out_green,
      WLuint32 *out_blue ),
   int (*cmap_init)(
      WLuint32 context_no ) ));

extern int WLclear_hilite __((
   WLuint32 lwin_no));

extern int WLget_context_color_functions __((
   WLuint32 context_no,
   int (**cmap_color_to_index)(
      WLuint32 context_no,
      WLuint32 index,
      WLuint32 red,
      WLuint32 green,
      WLuint32 blue,
      WLuint32 flag,
      WLuint32 *phy_index ),
   int (**cmap_color_to_rgb)(
      WLuint32 context_no,
      WLuint32 index,
      WLuint32 red,
      WLuint32 green,
      WLuint32 blue,
      WLuint32 flag,
      WLuint32 *out_red,
      WLuint32 *out_green,
      WLuint32 *out_blue ),
   int (**cmap_init)(
      WLuint32 context_no ) ));

extern int WLget_context_interaction __((
   WLuint16 lscreen_no,
   WLuint32 context_no,
   struct WLcontext_interaction **inter ));

extern int WLget_native_info_from_context __((
   WLuint16 lscreen_no,
   WLuint32 context_no,
   struct WLnative_info *native_info ));

extern int WLget_number_of_color_cells __((
   WLuint32 context_no,
   int *num_of_cells ));

extern int WLget_wm_colors __((
   WLuint32 context_no,
   int *num_entries,
   struct WLcmap_entry **cmap_entries,
   int *ingr_num_entries,
   struct WLcmap_entry **ingr_entries ));

extern int WLinstall_cmap __((
   WLuint32 lwin_no,
   WLuint32 context_no ));

extern int WLset_active_screen __((
   WLuint16 lscreen_no ));

extern int WLset_background __((
   WLuint32 lwin_no,
   WLcolorref color_ref ));

extern int WLset_blendarea __((
   WLuint32 lwin_no,
   WLuint8  area_pattern[8],
   int opaque_flag ));

extern int WLmouse_win_position __((
   WLuint32 *lwin_no,
   int *x,
   int *y,
   int *in_window ));

extern int WLset_active_SR_window __((
        WLhwin_no hwin_no ));

extern int WLchange_window_screen __((
   WLuint32 lwin_no,
   WLuint32 new_context_no,
   WLuint16 new_lscreen_no,
   WLuint32 *new_lwin_no ));

extern int WLset_drawing_mode __((
   WLuint32 lwin_no,
   int mode ));

extern int WLget_background __((
   WLuint32 lwin_no,
   WLcolorref *color_ref ));

extern int WLget_screen_type __((
   WLuint16 lscreen_no,
   int *screen_type ));


extern int WLset_active_font __((
   WLuint32 lwin_no,
   WLfont font_id ));

extern int WLload_font __((
   WLuint16 lscreen_no,
   char *font_name,
   WLfont *font_id ));

extern int WLget_hardware_screen_number __((
   WLhwin_no hwin_no,
   int *screen_no ));

extern int WLunload_font __((
   WLuint16 lscreen_no,
   WLfont font_id ));

extern int WLget_hardware_screen_from_logical __((
        WLuint16 lscreen_no,
        int *screen_no ));

extern int WLis_region_empty __((
        WLuint32 lwin_no,
        int x,
        int y,
        int pixels,
        int *region ));

extern int WLwindow_bounds_changed __((
   WLuint32 lwin_no,
   struct WLbounds *bounds ));

extern int WLinit_default_colormap __((
   WLuint16 lscreen_no ));

extern int WLget_default_colormap_entries __((
   WLuint32 context_no,
   int start_slot,
   int num_entries,
   int *num_valid_entries,
   struct WLcmap_entry *default_entries ));

extern int WLset_line_style_factor __((
   int flag ));

/* prototypes for OpenGL support */
#if defined( OPENGL )
#if defined( X11 )
extern int WLglx_get_choose_visual_function __((
   int (**glx_choose_function)(
      struct WLcontext_info *context,
      XVisualInfo *avail_visuals,
      int num_avail,
      int *chosen_index ) ));

extern int WLglx_set_choose_visual_function __((
   int (*glx_choose_function)(
      struct WLcontext_info *context,
      XVisualInfo *avail_visuals,
      int num_avail,
      int *chosen_index ) ));

extern int WLglx_make_window_current __((
   WLuint32 lwin_no,
   int win_type ));

extern int WLglx_get_window_contexts __(( 
   WLuint32 lwin_no,
   GLXContext *glx_context,
   GLXContext *hl_glx_context ));

extern int WLopengl_enter_2D __((
        WLuint32 lwin_no,
        int mode ));

extern int WLopengl_exit_2D __((
        WLuint32 lwin_no,
        int mode ));

#endif
#endif

#undef __

#endif
