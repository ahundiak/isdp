#ifndef FIext_included
#define FIext_included

#include "tools.h"
#include "FIform.h"
#include "FImgt.h"

extern int (*_FEI_Clear_timer_data)(); 	
extern int (*_FEI_Collapse_win)(); 	
extern int (*_FEI_Load_SR_vlt)();
extern int (*_FEI_Load_symbol_file)();
extern int (*_FEI_Create_SR_area)(); 	
extern int (*_FEI_Create_levwin_no_border)();	
extern int (*_FEI_Create_win_user_icon)();	
extern int (*_FEI_Delete_SR_area)();		
extern int (*_FEI_Delete_win)();			
extern int (*_FEI_Display_win)();		
extern int (*_FEI_Display_win_marq)();		
extern int (*_FEI_Enter_SR)();		
extern int (*_FEI_Exit_SR)();		
extern int (*_FEI_Get_button_data)();	
extern int (*_FEI_Get_collapse_data)();	
extern int (*_FEI_Get_delete_data)();	
extern int (*_FEI_Get_refresh_area_data)();  
extern int (*_FEI_Get_user_data)();  
extern int (*_FEI_Set_user_data)();  
extern int (*_FEI_Get_win_user_icon_data)();
extern int (*_FEI_Inq_button_data)();	
extern int (*_FEI_Inq_collapse_data)();	
extern int (*_FEI_Inq_delete_data)();	
extern int (*_FEI_Inq_displayed_vs)();	
extern int (*_FEI_Inq_events)();	
extern int (*_FEI_Inq_refresh_area_data)();	
extern int (*_FEI_Inq_screen_info)();		
extern int (*_FEI_Inq_user_data)();		
extern int (*_FEI_Inq_win_collapse_stat)();	
extern int (*_FEI_Inq_win_region)();	
extern int (*_FEI_Inq_win_user_icon_data)();	
extern int (*_FEI_Inq_win_vs)();	
extern int (*_FEI_Modify_win)();			
extern int (*_FEI_Mouseposition)();		
extern int (*_FEI_Mouse_win_position)();		
extern int (*_FEI_Process_win_icon_menu)();	
extern int (*_FEI_Refresh_on_move)();		
extern int (*_FEI_Set_win_bounds)();		
extern int (*_FEI_Set_win_button_mode)();	
extern int (*_FEI_Set_win_collapse_org)();
extern int (*_FEI_Set_win_collapse_symbol)();
extern int (*_FEI_Set_win_deltas)();	
extern int (*_FEI_Set_win_sys_icon)();	
extern int (*_FEI_Set_win_user_icon)();	
extern int (*_FEI_Set_win_vs_swap)();	
extern int (*_FEI_Start_timer)();	
extern int (*_FEI_Stop_timer)();	
extern int (*_FEI_Uncollapse_win)();	
extern int (*_FEI_Update_win_icon)();	

extern int (*_FEI_blendarea)(); 	
extern int (*_FEI_blendline)();		
extern int (*_FEI_clipbox)();		
extern int (*_FEI_defcursor)();		
extern int (*_FEI_draw)();		
extern int (*_FEI_drawbitmap)();		
extern int (*_FEI_drawsymbols)();		
extern int (*_FEI_fgcolor)();		
extern int (*_FEI_flushbuffer)();		
extern int (*_FEI_hidecursor)();		
extern int (*_FEI_linestring)();
extern int (*_FEI_linestyle)();
extern int (*_FEI_move)();
extern int (*_FEI_pnt)();	
extern int (*_FEI_popattributes)();
extern int (*_FEI_polyf)();
extern int (*_FEI_pushattributes)();
extern int (*_FEI_rectf)();
extern int (*_FEI_showcursor)();		
extern int (*_FEI_vsync)();		
extern int (*_FEI_Wait_for_next)();		
extern int (*_FEI_Get_scrap)();
extern int (*_FEI_weight)();		

/* Texture patterns */

extern long _FIgray12[32];
extern long _FIgray50[32];
extern long _FIgray75[32];
extern long _FIwhite[32];
			
extern void (*_FI_record_notification_routine)();

extern int  ( * FI_translate_color )();
extern int  ( * FI_calc_text )();
extern int  ( * FI_find_form )();
extern int  ( * FI_draw_text )();
extern int  ( * FI_find_font_id )();
extern int  ( * FI_find_symbol_path_and_id )();
extern int  ( * FI_process_data )();
extern int  ( * FI_set_window_attr )();
extern int  ( * FI_get_keyboard_data )();
extern int  ( * FI_activate_help )();
extern int  ( * FI_map_character )();

/* CHUNN Added 02/17/90 */

extern int  ( * FI_strlen )();
extern int  ( * FI_move_index )();


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

extern int  _FI_forms_active;
extern int  _FI_list_up;
extern int  _FI_form_clipping_on;
extern int  _FI_clip_xlo;
extern int  _FI_clip_ylo;
extern int  _FI_clip_xhi;
extern int  _FI_clip_yhi;

extern struct   FIform_obj   ** FI_forms;
extern struct   FIform_obj   ** FI_sr_forms;
extern struct   FIgadget_obj * _FI_g_get_id();
extern int      _FI_grp_get_next_slot();
extern struct   scr_info     * _FI_info;

extern struct vlt_slot	* _FI_fixed_vlt;
extern int	_FI_fixed_vlt_size;
extern int	 ** _FI_closest_colors;
extern int        * _FI_closest_SR_vlt_colors;


extern char 	FI_data[1000];
extern char 	* FI_keyin_buffer;
extern int 	  FI_keyin_buffer_size;

extern char 	** _FI_symbol_path;
extern char 	** _FI_form_path;
extern char 	** _FI_font_path;
extern char 	** _FI_FSfont_path;

extern struct FIgroup_obj * _FI_form_list;

extern int 	_FI_symbol_path_size;
extern int 	_FI_form_path_size;
extern int 	_FI_font_path_size;
extern int 	_FI_FSfont_path_size;

extern int 	_FI_symbol_path_index;
extern int 	_FI_form_path_index;
extern int 	_FI_font_path_index;
extern int 	_FI_FSfont_path_index;


extern long 	FI_enable_pttn[32];
extern long 	FI_enable_pttn2[32];
extern long 	FI_enable_pttn3[32];
extern long 	FI_enable_pttn4[32];


extern int 	_FI_mcf_Reason_for_notify;
extern int 	_FI_poke_inside_mcf;
extern int 	_FI_mcf_break_navigation;
extern char     _FI_read_char();
extern short    _FI_read_short();
extern double   _FI_read_double();
extern void     _FI_s_rep();
extern short	FI_kill_size;
extern unsigned char *FI_kill_buffer;

extern char *   _FI_read_string();
extern char *   _FI_reada_string();
extern char *   _FI_s_new();

extern void     _FI_g_display();
extern void     _FI_g_erase();
extern int      _FI_generic_erase();

extern void 	_FI_g_enable();
extern void 	_FI_g_disable();

extern void 	_FI_g_hilite();
extern void 	_FI_g_unhilite();

extern void 	_FI_g_set_state();
extern void 	_FI_g_adjust_size();

extern void 	_FI_g_activate();

extern int 	_FI_g_set_notify();
extern int  	_FI_g_add_to_group();

extern int      _FI_symbol_array_size;
extern int      _FI_font_array_size;

extern int      _FI_next_font;
extern int      _FI_next_symbol;

extern struct _FI_sym_st  * _FI_symbols;
extern struct _FI_font_st * _FI_fonts;

extern int	_FI_notification_type;

extern int FI_push_mode_flag;
extern int FI_push_mode_ac;
extern int FI_push_mode_count;

             /*** sml:03/15/93 ***/
extern double FI_auto_scale_factor_x;
extern double FI_auto_scale_factor_y;

/* sml:12-13-93 Add override for Put_scrap */
extern int (*_FEI_Put_scrap)();

#endif

