#ifndef wl_internal_include
#define wl_internal_include 1

#define WLI_TRUE		1
#define WLI_FALSE		0

#define	WLI_MAX_WIN_GROUPS		25
#define	WLI_MAX_CONTEXT_GROUPS		25
#define WLI_MAX_WINDOWS_PER_GROUP	40
#define WLI_MAX_CONTEXTS_PER_GROUP	40

/* Change WLIwin_set_active_style,weight,foreground to set these flags */

#define WLI_WIN_FLAGS_COLOR_CHANGED     0x00000001
#define WLI_WIN_FLAGS_STYLE_CHANGED     0x00000002
#define WLI_WIN_FLAGS_WEIGHT_CHANGED    0x00000004
#define WLI_WIN_FLAGS_CURSOR_HIDDEN	0x00000008
#define WLI_WIN_FLAGS_DYNAMICS_ON	0x00000010
#define WLI_WIN_FLAGS_COLLAPSED		0x00000020
#define WLI_WIN_FLAGS_USE_ALU		0x00000040
#define WLI_WIN_FLAGS_WL_CREATED	0x00000080 /* Window was creatd by WL*/
#define WLI_WIN_FLAGS_B_PATTERN_CHANGED 0x00000100 /* Blendarea pattern */
#define WLI_WIN_FLAGS_B_PATTERN_SOLID 	0x00000200 /* Solid Blendarea  */
#define WLI_WIN_FLAGS_B_PATTERN_OPAQUE 	0x00000400 /* Opaque Blendarea  */
#define WLI_WIN_FLAGS_USING_OPENGL	0x00000800 /* window using OpenGL */

/* Base and hilight mode flags stored in the window structure */

#define WLI_WIN_FLAGS_BASE_NOOP 	0x00001000
#define WLI_WIN_FLAGS_BASE_DRAW 	0x00002000
#define WLI_WIN_FLAGS_BASE_ERASE 	0x00003000
#define WLI_WIN_FLAGS_HILITE_NOOP 	0x00004000
#define WLI_WIN_FLAGS_HILITE_DRAW 	0x00008000
#define WLI_WIN_FLAGS_HILITE_ERASE 	0x0000C000
#define WLI_WIN_BASE_MASK		0x00003000
#define WLI_WIN_HILITE_MASK		0x0000C000
#define WLI_WIN_FLAGS_DYNAMICS_DRAW	0x00010000
#define WLI_WIN_FLAGS_DYNAMICS_ERASE	0x00020000

/* Seperate hilight window overlayed on the base window */

#define WLI_WIN_SEPARATE_HILITE		0x00040000
#define WLI_WIN_DOUBLE_BUFFER_CREATED   0x00080000
#define WLI_WIN_DOUBLE_BUFFER_DISPLAYED 0x00100000
#define WLI_WIN_FLAGS_USING_XGL		0x00200000 /* window using XGL */

#if defined( X11 )
#define WLI_UNDEFINED_TRANSPARENT_INDEX 0x0000ffff
#endif

#define WLI_SCREEN_FLAGS_DEFAULT_CMAP_USED 0x00000001
#define WLI_SCREEN_FLAGS_GLX_AVAILABLE     0x00000002
#define WLI_SCREEN_FLAGS_PRIMARY           0x00000004
#define WLI_SCREEN_FLAGS_XGL_AVAILABLE     0x00000008
#define WLI_SCREEN_FLAGS_ZX_ACTIVE         0x00000010

#define WLI_SCREEN_MAX_WIDTH		10000
#define WLI_SCREEN_MAX_HEIGHT		10000
 
/* Defines used for raster functions */

#define WLI_RESERVED_BIT		     0x00000000
#define WLI_INTERNAL_BUFFER_ALLOCATED	     0x00000010
#define WLI_EXTERNAL_BUFFER_ALLOCATED	     0x00000020
#define WLI_FAST_BUFFER	 		     0x00000040
#define WLI_OPENGL_IMAGE                     0x00000080
#define WLI_INTERNAL_OPENGL_BUFFER_ALLOCATED 0x00000100

#define WLI_BUFFERS_PER_CHUNK		100
#define WLI_UNDEFINED_LOGICAL_BUFFER	0xffff
 
/* Symbology defines */

#define WLI_PATTERN_LENGTH		16
#define WLI_COLORREF_INDEX_MASK		0x0000ffff

/* Font definition */

#if defined( ENV5 )
#define WLI_TEXT_FONT "/usr/ip32/resrc/rfont/drake.10"

#elif defined( XGL )
#define WLI_TEXT_FONT "Roman_C"

#elif defined( X11 )
#define WLI_TEXT_FONT "-*-*-medium-*-normal-*-15-*-*-*-*-*-*-*"

#endif

#if defined( X11 ) || defined( ENV5 )
#  if defined( XGL )
      typedef Xgl_sgn32 WLdash_type;

#  else
      typedef char WLdash_type;

#  endif
#elif defined( WIN32 )
   typedef DWORD WLdash_type;

#endif

#if defined( X11 )
   typedef Pixmap WLblend_pattern;

#elif defined( ENV5 )
   typedef long   *WLblend_pattern;

#elif defined( WIN32 )
   typedef char   *WLblend_pattern;

#endif

/* MACROS to make life easier */

#define WLI_DRAW_OVERLAY_WINDOW( ptr_win_str ) \
        ( (ptr_win_str)->flags & WLI_WIN_SEPARATE_HILITE ) && \
        ((( (ptr_win_str)->flags & WLI_WIN_HILITE_MASK ) != \
                                          WLI_WIN_FLAGS_HILITE_NOOP ) ||\
          ( (ptr_win_str)->flags & WLI_WIN_FLAGS_DYNAMICS_ON )) 

#define WLI_DRAW_BASE_WINDOW( ptr_win_str ) \
      ( !( (ptr_win_str)->flags & WLI_WIN_SEPARATE_HILITE ) ) || \
         ( ( (ptr_win_str)->flags & WLI_WIN_SEPARATE_HILITE ) && \
           (( (ptr_win_str)->flags & WLI_WIN_BASE_MASK )!=       \
                                           WLI_WIN_FLAGS_BASE_NOOP ) )

 
#if defined( OPENGL )

#if defined( X11 )
struct WLIfont_info_OPENGL
   {
   Font font_id;
   GLuint list_base;
   };
#endif

/* these macros are used for drawing 2D elements in OpenGL */

#define WLI_SETUP_OPENGL_FOR_2D( win_str, mode ) \
   if ( !mode ) \
      { \
      glPushMatrix(); \
      glLoadIdentity(); \
      glScalef( 1.0, -1.0, 1.0 ); \
      glMatrixMode( GL_PROJECTION ); \
      glPushMatrix(); \
      glLoadIdentity(); \
      gluOrtho2D( 0, (win_str)->area_bounds.width - 1, \
                     -((win_str)->area_bounds.height - 1), 0 ); \
      }

#define WLI_RESTORE_OPENGL_TO_3D(mode) \
   if ( !mode ) \
      { \
      glPopMatrix(); \
      glMatrixMode( GL_MODELVIEW ); \
      glPopMatrix(); \
      }

#define WLI_SEND_PRIMITIVE_TO_OPENGL( prim_type, npts, pts ) \
   gl_npoints = (npts); \
   gl_points = (pts); \
   glBegin( (prim_type) ); \
   while ( gl_npoints-- ) \
      { \
      glVertex2s( gl_points->x, gl_points->y ); \
      gl_points++; \
      } \
   glEnd();

#endif

#if defined( XGL )
#define WLI_SETUP_XGL_FOR_2D( context, gl_trans, loc_trans, view_trans, mode ) \
   if ( !mode ) \
      {            \
      xgl_context_push( context, push_attr_list ); \
      xgl_transform_identity( gl_trans ); \
      xgl_transform_identity( loc_trans ); \
      xgl_transform_identity( view_trans );  \
      xgl_object_set(context, XGL_CTX_VDC_WINDOW, &xgl_window,  \
                              /*XGL_CTX_DC_VIEWPORT, &xgl_window,*/ \
                              NULL ); \
      }
    

#define WLI_RESTORE_XGL_TO_3D(context, mode) \
   if ( !mode ) \
      {   \
      xgl_context_pop(  context ); \
      }
#endif

#if defined( X11 )
struct WLIhilite_native
   {
   GC hl_gc;
   Colormap hl_colormap;
   Visual *hl_visual;
   unsigned long transparent_index;
   unsigned long opaque_index;
   unsigned long hl_pixel_mapping[2];
   };

#endif
#ifdef X11
struct WLIscreen_native
   {
   Widget   widget;
   Display  *EXdisplay;
   int      depth;
   GC       EXgc;
   Colormap EXcolormap;
   int      screen_no;
   WLcursor cursor;
   WLcursor null_cursor;

#  if defined( OPENGL )
      GLXContext glx_context;
      GLXContext hl_glx_context;
      int        base_in_2d;
      int        hilite_in_2d;
#  endif

#  if defined( XGL )
      Xgl_color_type_supported xgl_color_type;
      Xgl_hlhsr_mode           xgl_hlhsr_mode;
      Xgl_sys_state            sys_state;
      Xgl_object               xgl_context_3D;
      Xgl_object               hl_xgl_context_3D;
      Xgl_win_ras              win_ras;
      Xgl_win_ras              hl_win_ras;
      Xgl_mem_ras              mem_ras;
      Xgl_mem_ras              hl_mem_ras;
      Xgl_trans                global_model_trans;
      Xgl_trans                local_model_trans;
      Xgl_trans                view_trans;
      Xgl_trans                hl_global_model_trans;
      Xgl_trans                hl_local_model_trans;
      Xgl_trans                hl_view_trans;
      int                      base_in_2d;
      int                      hilite_in_2d;
#  endif
   };
#endif

#ifdef ENV5
struct WLIscreen_native
   {
   int      screen_no;
   WLcursor cursor;
   int      vlt_no;
   int      env5_vsi_flags;
   };
#endif

#ifdef WIN32
struct WLIscreen_native
   {
   WLhwin_no hmdi_no;
   WLhwin_no hwin_no;
   HDC       hdc;
   WLcursor  cursor;
   WLhandle  hinstance;
   WLwndproc wnd_proc;
   LPCTSTR   class;
   LPCTSTR   app_main_class;
   int       app_main_window;
   WLhandle  hMainMenu;
   WLhandle  hWindowMenu;
   };
#endif


#ifdef X11
struct	WLIcontext_native
   {
   Colormap  EXcolormap;
   Visual    *visual;
#  if defined( XGL )
      Xgl_object xgl_base_cmap;
      Xgl_object xgl_hilite_cmap;
#  endif
   };
#endif

#ifdef ENV5
struct	WLIcontext_native
   {
   int vlt_no;
   };
#endif


#ifdef WIN32
struct	WLIcontext_native
   {
   HPALETTE palette;
   };
#endif

struct WLIstyle_struct
   {
   int          nitems;
   int          offset;
   unsigned int flags;
   short        pattern;
   WLdash_type  dash_list[16];
   WLuint8      change_count;
   int          hh_nitems;         /* Half hilight nitems    */
   int          hh_offset;         /* Half hilight offset    */
   WLdash_type  hh_dash_list[32];  /* Half hilight dash list */
   char         pattern_factor;    /* factor for pattern in opengl */

#  if defined ( XGL )
      Xgl_lpat  lpat;
      Xgl_lpat  hh_lpat;
#  endif
   };

struct WLIcontext
   {
   WLuint16 lscreen_no;
   int      base_cmap_type;
   int      base_depth;
   int      hilite_depth;
   int      hilite_used;
   int      flags;
   int      base_mask;
   int      hilite_mask;
   int      red_shifter;
   int      green_shifter;
   int      blue_shifter;
   int      right_shifter;

   struct WLIcontext_native native_info;

#  if defined( X11 )
   struct WLIhilite_native  hl_native_info;
#  endif

   int      ref_ct;

   int (*cmap_color_to_index)(
      WLuint32 context_no,
      WLuint32 index,
      WLuint32 red,
      WLuint32 green,
      WLuint32 blue,
      WLuint32 flag,
      WLuint32 *phy_index );

   int (*cmap_color_to_rgb)(
      WLuint32 context_no,
      WLuint32 index,
      WLuint32 red,
      WLuint32 green,
      WLuint32 blue,
      WLuint32 flag,
      WLuint32 *out_red,
      WLuint32 *out_green,
      WLuint32 *out_blue );

   int (*cmap_init)( WLuint32 context_no );

   int                 used;
   int                 created;
   struct WLcmap_entry *local_colormap;
   int                 cmap_active;
   };

struct WLIwin
   {
   WLuint16                lscreen_no;
   WLuint32                lwin_no;
   struct WLIscreen_native native_info;

#  if defined( X11 )
      struct WLIhilite_native hl_native_info;
      WLhwin_no               hl_hwin_no;
      Multibuffer             double_buffer[2];
      int                     buffer0;
      int                     buffer1;
#  endif

   WLuint32           context_no;
   WLhwin_no          hwin_no;
   int                active_weight;	
   int                active_style;
   WLuint16           active_blend; /* Blendline patternce assoc with style*/
   int                color_index;
   int                red;
   int                green;
   int                blue;
   int                background_color_index;
   int                background_red;
   int                background_green;
   int                background_blue;
   WLuint32           flags;
   WLuint8            style_change_count;
   int                used;
   int                created;
   void               *exnuc_data;
   void               *data1;
   int                event_mask;
   WLblend_pattern    blend_pattern;
   WLblend_pattern    hl_blend_pattern;
   WLuint32           exp_pattern[32];  /* 32x32 dev ind. blend pattern */
   struct WLbounds    bounds;
   struct WLbounds    area_bounds;

   int (*clear_hilite)(
      struct WLIwin *win_struct,
      struct WLIcontext *context_struct );

   int (*clear_window)(
      struct WLIwin *win_struct,
      struct WLIcontext *context_struct );

   int (*set_drawing_mode)(
      struct WLIwin *win_struct,
      struct WLIcontext *context_struct,
      int base_mask,
      int hilite_mask );

   int (*set_dynamics_drawing_mode)(
      struct WLIwin *win_struct,
      struct WLIcontext *context_struct,
      int mode );

   int (*get_fg_and_hl)(
      struct WLIwin *win_struct,
      struct WLIcontext *context_struct,
      int *fg_color,
      int *hl_color );

   int (*activate_symbology)(
      struct WLIwin *win_struct,
      struct WLIcontext *context_struct,
      struct WLIstyle_struct *style_struct,
      int fill_flag );

#  if defined( OPENGL )
      int (*get_fg_and_hl_OPENGL)(
         struct WLIwin *win_struct,
         struct WLIcontext *context_struct);
#  endif

#  if defined( XGL )
      int (*get_fg_and_hl_XGL)(
         struct WLIwin *win_struct,
         struct WLIcontext *context_struct);
#  endif
};

struct WLIscreen
{
   struct WLIscreen_native native_info;
   struct WLIwin_group *pwin;
   struct WLIcontext_group *pcontext;
   struct WLcontext_info *possible_contexts;
   int used;
   int num_possible_contexts;
   int flags;
   int db_count;
};

struct WLIwin_group
{
   struct WLIwin *pwin_group;
   int num_entries_used;
};

struct WLIcontext_group
{
   struct WLIcontext *pcontext_group;
   int num_entries_used;
};

struct WLIraster_detail_data
{
   WLfast_buffer fast_buffer; /* Set to WL_SLOW_BUFFER to enable */
                              /* slow buffering                  */
   WLuint32     bits_per_pixel;
   WLuint32     flags;
   WLuint32     width, height;
   WLuint32     red_shift;
   WLuint32     green_shift;
   WLuint32     blue_shift;
#if defined( OPENGL )
   char *opengl_buffer;
   GLuint opengl_fast_buffer;
#endif
};

struct WLIdefault_cmap
{
   WLuint32   cmap_type;
   WLuint32   size_of_cmap;
   struct WLcmap_entry *cmap_entry;
};

extern struct WLIscreen		WLIscreens_arr[WL_MAX_SCREENS];

/* Global data , Should be minimum */

extern int 	WLIactive_screen;
extern int 	WLIinitialized;
extern int 	WLIbatch_mode;
extern int      WLInum_phy_screens;
extern int      WLIreport_error;
extern int      WLISRwin_no;
extern WLfont 	WLIdefault_font;
extern int  WLIline_style_factor;

/* Line style data structures */
extern struct WLIstyle_struct		WLIline_style[WL_MAX_STYLES];

#define WLI_STYLE_SOLID 0x00000001

/* error checking macro */
#define WL_REPORT_ERROR( err_num ) \
   if ( WLIreport_error )          \
   {                               \
      fprintf( stderr, "WL ERROR: %d; File: %s; Line: %d\n", (err_num), __FILE__, __LINE__ );                      \
   }            

 
/* This macro frees memory and sets the pointer to NULL */
#define WLI_FREE( mem_ptr )                                               \
                                                                          \
   {                                                                      \
      free( (char *) (mem_ptr) );                                         \
      (mem_ptr) = NULL;                                                   \
   } 


#if defined(__STDC__) || defined(__cplusplus)
#define __(p) p
#else
#define __(p) ()
#endif

/* prototypes for internal WL functions */

extern int WLIwin_add_entry __((
   WLuint32 context_no,
   struct WLnative_info *native_info,
   WLhwin_no hwin_no,
   WLuint32 *lwin_no,
   WLuint32 created_flag ));

extern int WLIwin_set_active_weight __((
   WLuint32 lwin_no,
   int weight ));

extern int WLIwin_set_bounds __((
   WLuint32 lwin_no ));

extern int WLIwin_set_active_style __((
   WLuint32 lwin_no,
   int style,
   WLuint16 blend ));

extern int WLIwin_set_active_foreground __((
   WLuint32 lwin_no,
   WLcolorref color_ref ));

extern int WLIwin_set_active_background __((
   WLuint32 lwin_no,
   WLcolorref color_ref ));

extern int WLIwin_set_context __((
   WLuint32 lwin_no,
   WLuint32 context_no ));

extern int WLIwin_set_user_data __((
   WLuint32 lwin_no,
   void **exnuc_data,
   void **data1 ));

extern int WLIwin_get_user_data __((
   WLuint32 lwin_no,
   void **exnuc_data,
   void **data1 ));

extern int WLIwin_retrieve_entry __((
   WLuint32 lwin_no,
   struct WLIwin *win_struct ));

extern int WLIwin_delete_entry __((
   WLuint32 lwin_no ));

extern int WLIwin_hardware_to_logical __((
   WLuint16 lscreen_no,
   WLhwin_no hwin_no,
   WLuint32 *lwin_no ));

extern WLuint32 WLIwin_pack __((
   WLuint16 lscreen_no,
   WLuint8  group_index,
   WLuint8  offset ));   

extern int WLIwin_unpack __((
   WLuint32   lwin_no,
   WLuint16 *lscreen_no,
   WLuint8  *group_index,
   WLuint8  *offset ));   

extern int WLIwin_validate __((
   WLuint16 lscreen_no,
   WLuint8  group_index,
   WLuint8  offset ));   

extern int WLIwin_set_style_change_count __((
   WLuint32 lwin_no,
   WLuint8 style_change_count ));

extern int WLIwin_set_flags __((
   WLuint32 lwin_no,
   unsigned int flags ));

extern int WLIwin_set_event_mask __((
   WLuint32 lwin_no,
   int event_mask ));

extern int WLIwin_get_event_mask __((
   WLuint32 lwin_no,
   WLuint32 *event_mask ));

extern int WLIwin_set_cursor __((
   WLuint32 lwin_no,
   WLcursor cursor ));

extern int WLIcontext_add_entry __((
   WLuint16 lscreen_no,
   struct WLnative_info   *native_info,
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
   struct WLcontext_info *context_info,
   WLuint32 *context_no,
   int created_flag ));  

extern int WLIcontext_retrieve_entry __((
   WLuint32 context_no,
   struct WLIcontext *context_struct ));

extern int WLIcontext_delete_entry __((
   WLuint32 context_no ));

extern int WLIcontext_inc_ref_ct __((
   WLuint32 context_no ));

extern int WLIcontext_dec_ref_ct __((
   WLuint32 context_no ));

extern WLuint32 WLIcontext_pack __((
   WLuint16 lscreen_no,
   WLuint8  group_index,
   WLuint8  offset ));   

extern int WLIcontext_unpack __((
   WLuint32   lcontext_no,
   WLuint16 *lscreen_no,
   WLuint8  *group_index,
   WLuint8  *offset ));   

extern int WLIcontext_validate __((
   WLuint16 lscreen_no,
   WLuint8  group_index,
   WLuint8  offset ));   

extern int WLIscreen_hardware_to_logical __((
   int hscreen_no,
   WLuint16 *lscreen_no ));

extern int WLIscreen_retrieve_hardware_screen __((
   WLuint16 lscreen_no,
   int *hscreen_no ));

extern int WLIscreen_validate __((
   WLuint16 lscreen_no ));

extern int WLIstyle_get_entry __((
   int lstyle_no,
   struct WLIstyle_struct *entry ));

extern int WLIactivate_symbology __((
   struct WLIwin *win_struct,
   struct WLIcontext *context_struct,
   int fill_flag ));

extern int WLIevent_translate __((
   int event_mask,
   int *win_mask ));

extern int WLIslot_validate __((
   struct WLcmap_entry *cmap_entries,
   int num_entries,
   WLuint32 context_no ));

extern int WLIscreen_retrieve_entry __((
   WLuint16 lscreen_no,
   struct WLIscreen *screen_struct));

extern int WLIstyle_convert_to_dashes __((
   short pattern,
   int *n,
   int *offset,
   WLdash_type *points));

extern int WLIwin_unpack_colorref __((
   WLcolorref color_ref,
   WLuint32 *lcolor_index,
   WLuint32 *red,
   WLuint32 *green,
   WLuint32 *blue,
   WLuint32 *color_flag));
   

extern int WLIcontext_change_color_funcs __((
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

extern int WLIcontext_install_cmap __((
   WLuint32 lwin_no,
   WLuint32 context_no));

extern int WLIcontext_read_cmap_entries __((
   WLuint32 context_no,
   int num_entries,
   struct WLcmap_entry *cmap_entries ));

extern int WLIcontext_load_cmap_entries __((
   WLuint32 context_no,
   int num_entries,
   struct WLcmap_entry *cmap_entries ));

extern int WLIestablish_lwin_and_context __((
   WLuint32 *lwin_no,
   WLuint32 *context_no,
   struct WLIwin **win_struct,
   struct WLIcontext **context_struct ));

extern int WLIunestablish_lwin __((
   void ));

extern int WLIwin_create_db __((
   WLuint32 lwin_no ));

extern WLIwin_retrieve_entry_ptr __((
   WLuint32 lwin_no,
   struct WLIwin **win_struct ));

extern int WLIcontext_retrieve_entry_ptr __((
   WLuint32 context_no,
   struct WLIcontext **context_struct ));

extern int WLIwin_set_blend_pattern __((
   WLuint32 lwin_no,
   int solid_flag,
   int opaque_flag,
   WLblend_pattern blend_pattern,
   WLblend_pattern hl_blend_pattern,
   WLuint32 *exp_pattern ));

extern int WLIcreate_font __((
   WLuint16 lscreen_no ));

extern int WLIscreen_set_flags __((
   WLuint16 lscreen_no,
   int flags ));

extern int WLIscreen_set_db_count __((
   WLuint16 lscreen_no,
   int db_count ));

extern int WLIscreen_set_vlt __((
   WLuint16 lscreen_no,
   int vlt_no ));

extern int WLIwin_debug __((
   WLuint32 lwin_no));

extern int WLIenumerate_windows __(( 
   int (*win_func)(
      WLuint32 lwin_no,
      void *user_data ),
   void *data ));

extern int WLIconvert_dashes_with_blend __((
   int old_nitems,
   int old_offset,
   WLdash_type *old_dash_list,
   int *new_items,
   WLdash_type *new_dash_list ));

extern int WLIset_window_functions __((
   struct WLIwin *win_struct ));

extern int WLIget_fg_and_hl_IX __((
   struct WLIwin *win_struct,
   struct WLIcontext *context_struct,
   int *fg_color,
   int *hl_color ));

extern int WLIget_fg_and_hl_HL_IX __((
   struct WLIwin *win_struct,
   struct WLIcontext *context_struct,
   int *fg_color,
   int *hl_color ));

extern int WLIget_fg_and_hl_HL_TC __((
   struct WLIwin *win_struct,
   struct WLIcontext *context_struct,
   int *fg_color,
   int *hl_color ));

extern int WLIget_fg_and_hl_TC __((
   struct WLIwin *win_struct,
   struct WLIcontext *context_struct,
   int *fg_color,
   int *hl_color ));

#if defined( ENV5 )
extern int WLIcontext_fill_pseudo_vlt __((
   struct vlt_slot *base_color,
   int base_count,
   struct vlt_slot *pseudo_vlt,
   int *pseudo_count ));
#endif

#if defined( X11 )
extern int WLIwin_get_logical_window_from_root_parent __((
   int lscreen_no,
   Display *display,
   Window root_parent,
   WLuint32 *lwin_no ));

extern int WLIclear_double_buffer __((
   struct WLIwin *,
   Multibuffer ));
#endif

#if defined( OPENGL )
extern int WLIset_window_functions_OPENGL __((
   struct WLIwin *win_struct ));

extern int WLIglx_reset_last_lwin_no __((
   void ));
#endif

#undef __

#endif
