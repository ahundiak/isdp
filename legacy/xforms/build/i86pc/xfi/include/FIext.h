#ifndef FI_EXT_INCLUDED
#define FI_EXT_INCLUDED 1

#include <stdio.h>

	/**************************************************/
	/*** taken from tools.h				***/
	/*** for hardware-independent vlt's		***/
	/*** in Readvlt/Loadvlt/Read_SR_vlt/Load_SR_vlt	***/
	/**************************************************/

struct vlt_slot
{
  unsigned short v_slot;
  unsigned short v_red;		/* max = 0xFFFF */
  unsigned short v_green;	/* max = 0xFFFF */
  unsigned short v_blue;	/* max = 0xFFFF */
};

#define MAX_WINDOW		100
#define MAX_SCREEN_WIDTH	1184
#define MAX_SCREEN_HEIGHT	884
#define FI_SINGLE_CLICK		2



/*********************************************************************/
/*********************************************************************/
/*********************************************************************/
/*** PUT ALL GLOBAL VARIABLE extern's HERE.	THEY MUST NOT	   ***/
/*** BE extern'ed IN "glob.c" ( where they're defined ), because   ***/
/*** this changes the addresses in the Clipper shared library when ***/
/*** you add a new global variable extern.			   ***/
/*********************************************************************/
/*********************************************************************/
/*********************************************************************/

#ifndef FI_INSIDE_GLOB_C

	/************************/
	/*** Texture patterns ***/
	/************************/

extern long _FIgray12[];
extern long _FIgray50[];
extern long _FIgray75[];
extern long _FIwhite[];
      
	/***************/
	/*** Pixmaps ***/
	/***************/
extern Pixmap _FIpix_gray12;
extern Pixmap _FIpix_gray50;
extern Pixmap _FIpix_gray75;
extern Pixmap _FIpix_required;

extern int (*_FI_record_notification_routine)();

extern unsigned long	( * FI_translate_color ) ();
extern int		( * FI_colormap_notify )();
extern Display		 *_FI_display;
extern Window		_FI_index_to_Xwindow[MAX_WINDOW+1];

extern GC		_FI_gc;      /** Current graphics context  **/
extern GC		_FI_text_gc; /** Graphics context used for **/
				     /**  XFontserver calls.	   **/ 
extern Colormap		_FI_cmap;  /** Current colormap    **/
extern int		_FI_dont_flush;


extern int	( * FI_calc_text )();
extern int	( * FI_find_form )();
extern int	( * FI_draw_text )();
extern int	( * FI_find_font_id )();
extern int	( * FI_find_symbol_path_and_id )();
extern int	( * FI_process_data )();
extern int	( * FI_set_window_attr )();
extern int	( * FI_get_keyboard_data )();
extern int	( * FI_activate_help )();
extern int	( * FI_map_character )();
extern int	( * FI_strlen )();
extern int	( * FI_move_index )();


extern int  _FI_default_function();

extern int  FI_display_mode;
extern int  FI_form_scaling;
extern int  FI_sr_mode;
extern int  FI_using_SR_vlt;
extern int  FI_sr_win_num;
extern int  FI_sr_area_num;
extern int  FI_current_screen_width;
extern int  FI_current_screen_height;
extern int  FI_rop_machine;
extern int  FI_db_capability;

/*** there's no message strip anymore with CSS 5.0 (Feb 91) ***
extern int  FI_message_strip_height;
***************************************************************/
/*** ...BUT... it is used in xforms for now... ***/
extern int  FI_message_strip_height;

extern int  _FI_forms_active;

extern int  _FI_system_set_up;

extern int  _FI_list_up;
extern int  _FI_form_clipping_on;
extern int  _FI_clip_xlo;
extern int  _FI_clip_ylo;
extern int  _FI_clip_xhi;
extern int  _FI_clip_yhi;

extern struct   FIform_obj   * FI_forms[MAX_WINDOW+1];
extern struct   FIform_obj   * FI_sr_forms[MAX_WINDOW+1];


extern XPoint   _FI_vertices[11];

extern char   FI_data[1000];
extern char   * FI_keyin_buffer;
extern int     FI_keyin_buffer_size;

extern char   ** _FI_symbol_path;
extern char   ** _FI_form_path;
extern char   ** _FI_font_path;
extern char   ** _FI_FSfont_path;
extern char   ** _FI_charmap_path;

extern int   _FI_num_sym_dirs;
extern int   _FI_num_form_dirs;
extern int   _FI_num_font_dirs;
extern int   _FI_num_FSfont_dirs;
extern int   _FI_num_charmap_dirs;

extern long  _FI_enable_pttn3[32];

extern struct FIgroup_obj * _FI_form_list;

extern int   _FI_symbol_path_index;
extern int   _FI_form_path_index;
extern int   _FI_font_path_index;
extern int   _FI_FSfont_path_index;


extern int   _FI_mcf_Reason_for_notify;
extern int   _FI_poke_inside_mcf;
extern int   _FI_mcf_break_navigation;
extern unsigned char *FI_kill_buffer;
extern int   FI_kill_buffer_index;
extern int   FI_kill_buffer_size;

extern int      _FI_symbol_array_size;
extern int      _FI_font_array_size;

extern int      _FI_next_font;
extern int      _FI_next_symbol;

extern struct _FI_sym_st  * _FI_symbols;
extern struct _FI_font_st * _FI_fonts;

			/*** JAJ:11/11/91 ***/
extern double FI_auto_scale_factor_x;
extern double FI_auto_scale_factor_y;

extern int (* FI_next_event)();		/* GMD 1/13/92 */
extern Window (* FI_create_window)(); /* Window, not int SML:04-29-92 */
extern int  _FI_select_button;	 	/* GMD 1/14/92 */

extern int  _FI_notification_type;	/* JAJ: 01/20/92 */

/* GMD 1/24/92 */

extern int (* FI_mask_event)();
extern int (* FI_check_mask_event)();
extern int (* FI_if_event)();
extern int (* FI_put_back_event)();
extern int (* FI_send_event)();

/* GMD 2/24/92 */

extern int (* FI_grab_pointer)();
extern int (* FI_ungrab_pointer)();

/* GMD 3/10/92 */

extern int SaveRestoreFormsDisplayed;

/* GMD 3/17/92 */

extern int (* FI_check_if_event)();
extern int (* FI_map_raised)();
extern int (* FI_map_window)();

/* GMD 3/18/92 */

extern int (* FI_configure_window)();
extern int (* FI_destroy_window)();
extern int (* FI_iconify_window)();
extern int (* FI_query_pointer)();
extern int (* FI_unmap_window)();
extern int (* FI_withdraw_window)();

/* GMD 3/18/92    Merge push mode, set screen with xfi24 source */

extern int FIf_get_Xscreen ();
extern int FIf_set_Xscreen ();
extern int _FI_get_active_screen ();
extern int _FI_make_window ();

extern int FI_push_mode_flag;
extern int FI_push_mode_ac;
extern int FI_push_mode_count;

extern Pixmap _FIpix_gray12_array[8];
extern Pixmap _FIpix_gray50_array[8];
extern Pixmap _FIpix_gray75_array[8];
extern Pixmap _FIpix_required_array[8];

extern Colormap _FI_cmap_array[8];

/* GMD 3/24/92 */

extern Form SaveRestoreFormsArray[20];

/* GMD 4/20/92 */

extern int FI_lock_SR_in_Display;

/* sml 06-09-93 */

extern int FI_font_strategy;

/*sml 11-18-93 */

extern int	( * FI_window_event )();

/* sml:12-10-93 */
extern int _FI_fld_new_event;
extern int _FI_fld_new_event_value;
extern Form _FI_fld_new_form;
extern int _FI_fld_new_gadget;
extern int _FI_fld_new_xpos;
extern int _FI_fld_new_ypos;
extern int _FI_fld_new_event_status;

/* sml:12-17-93 */
extern int (* FI_check_window_event) ();


#endif      /* #ifndef FI_INSIDE_GLOB_C */


#endif	/* FI_EXT_INCLUDED */
