/****************************************************************/
/* XFIproto_pri.h -                                             */
/*    This is the X/Forms (XFORMSDP SN01252) ANSI-C             */
/*    function prototype header file for private functions      */
/****************************************************************/
/* Copyright 1992 Intergraph Corporation                        */
/* All Rights Reserved, Including this Release Note, the        */
/* Product it Describes, its File Formats, and Visual Displays  */
/****************************************************************/


#ifndef XFIPROTO_PRI_H_INCLUDED 
#define XFIPROTO_PRI_H_INCLUDED 1

#include <X11/Xlib.h>
#include <setjmp.h>

#include "../include/FIbezel.h"
#include "../include/FIbtn.h"
#include "../include/FIcklst.h"
#include "../include/FIdial.h"
#include "../include/FIdyn.h"
#include "../include/FIext.h"
#include "../include/FIfield.h"
#include "../include/FIgauge.h"
#include "../include/FIgraphic.h"
#include "../include/FIgroup.h"
#include "../include/FIimport.h"
#include "../include/FIline.h"
#include "../include/FImacros.h"
#include "../include/FImcf.h"
#include "../include/FImgt.h"
#include "../include/FImin.h"
#include "../include/FIread.h"
#include "../include/FIrect.h"
#include "../include/FIscroll.h"
#include "../include/FIseq.h"
#include "../include/FIslider.h"
#include "../include/FIsym.h"
#include "../include/FItext.h"
#include "../include/FItog.h"

#include "../include/MI.h"
#include "../include/MIdef.h"
#include "../include/MIext.h"
#include "../include/MS.h"
#include "../include/MSext.h"

#include "../fs_include/FSTypes.h"   /* dmb:01/11/93: Was FSXTypes.h */

    /*********************************/
    /***  X/Fontserver Functions  ***/
    /*********************************/
/* dmb:10/16/92:Exp */
extern int FSXDrawText( Display *display,
                           int      screen,
                           Window   window,
                           GC       gc,
                           Font     font_id,
                           char    *text,
                           int      length,
                           double   xpos,
                           double   ypos,
                           double  *next_x,
                           double  *next_y);

extern int FSXDrawChar( Display *display,
                           int      screen,
                           Window   window,
                           GC       gc,
                           Font     font_id,
                           short     ch,
                           double   xpos,
                           double   ypos,
                           double  *next_x,
                           double  *next_y);

extern int REAL_FSXDrawChar( Display *display,
                           int      screen,
                           Window   window,
                           GC       gc,
                           Font     font_id,
                           char     ch,
                           double   xpos,
                           double   ypos,
                           double  *next_x,
                           double  *next_y);


    /***************************/
    /***  X/Forms Functions  ***/
    /***************************/

/* 16stuff.c */
extern int _FI_locate_16bit_start_byte(int cpos, char *s);
/* SS.c */
extern int _FI_16DrawText(int window, FontId font, FontId fontAUX, unsigned char *text, int length, Real64 x, Real64 y, Real64 *nx, Real64 *ny, int mode, int mode2, int screen);
/* Xevent.c */
extern Bool _FI_flush_expose(Display *display, XEvent *event, Window *wind);
extern Bool _FI_flush_configure(Display *display, XEvent *event, Window *wind);
/* bar.c */
extern int _MI_bar_notify_routine(int form_label, int gadget_label, double value, struct FIform_obj *menu);
/* bezel.c */
extern int _FI_bezel_display(struct FIbez_obj *bezel, Window window);
/* button.c */
extern int _FI_btn_display(struct FIbtn_obj *button_obj, Window window);
extern int _FI_btn_track_mouse(struct FIbtn_obj *button_obj, Window window, int *complete, double *value);
extern int _FI_btn_adjust(struct FIbtn_obj *button_obj, double delta_x, double delta_y);
extern int _FI_btn_activate(struct FIbtn_obj *button_obj);
/* cklst.c */
extern void _FI_cklst_get_area(struct FIcklst_obj *cklst, int *xlo, int *ylo, int *xhi, int *yhi);
extern int _FI_cklst_erase(struct FIcklst_obj *cklst, Window window);
extern int _FI_cklst_display(struct FIcklst_obj *cklst, Window window, int display_all_flag);
extern void _FI_cklst_track_mouse(struct FIcklst_obj *cklst, Window window, int *complete, double *value);
extern void _FI_cklst_calc_coord(struct FIcklst_obj *cklst);
extern int _FI_cklst_adjust(struct FIcklst_obj *cklst, double delta_x, double delta_y);
extern int _FI_cklst_activate(struct FIcklst_obj *cklst);
extern int _FI_cklst_find_gadget(struct FIcklst_obj *cklst, int xpos, int ypos, struct FIgadget_obj **search_gadget);
/* cmd_oid.c */
/* common.c */
/* copy.c */
extern void _FI_g_copy(struct FIgadget_obj *old_gadget, struct FIgadget_obj *new_gadget);
extern void _FI_fld_copy(struct FIfld_obj *old_field, struct FIfld_obj *new_field);
/* dial.c */
extern void _FI_dial_draw_ticks(struct FIdial_obj *dial, Window window);
extern void _FI_dial_draw_needle(struct FIdial_obj *dial, Window window, double needle_value, int point_color, int needle_color, int erasing);
extern void _FI_dial_draw_bezels(struct FIdial_obj *dial);
extern int _FI_dial_display(struct FIdial_obj *dial, Window window);
extern void _FI_dial_draw_new_needle(struct FIdial_obj *dial, double last_value, double new_value);
extern void _FI_dial_track_mouse(struct FIdial_obj *dial, Window window, int xpos, int ypos, int *complete, double *value);
extern void _FI_dial_modify_radian_value(double *rad_value);
extern void _FI_dial_find_angle_in_radians(struct FIdial_obj *dial, int xpos, int ypos);
extern void _FI_dial_calc(struct FIdial_obj *dial);
extern int _FI_dial_adjust(struct FIdial_obj *dial, double delta_x, double delta_y);
extern int _FI_dial_activate(struct FIdial_obj *dial);
extern void _FI_dial_set_value(struct FIdial_obj *dial, double value);
/* drawbezel.c */
extern void _FI_draw_normal_bezel(Window window, int xlo, int ylo, int xhi, int yhi, int bezel_size, unsigned long t_l_color, unsigned long face_color, unsigned long b_r_color, unsigned long edge_color, int type);
extern void _FI_assign_bezel_function(Window window, int xlo, int ylo, int xhi, int yhi, int bezel_size, unsigned long t_l_color, unsigned long face_color, unsigned long b_r_color, unsigned long edge_color, int type);
extern void _FI_draw_thin_bezel(Window window, int xlo, int ylo, int xhi, int yhi, int bezel_size, unsigned long t_l_color, unsigned long face_color, unsigned long b_r_color, unsigned long edge_color, int type);
extern void _FI_draw_bezel(Window window, int xlo, int ylo, int xhi, int yhi, int bezel_size, unsigned long t_l_color, unsigned long face_color, unsigned long b_r_color, unsigned long edge_color, int type);
/* dump.c */
extern void _FI_dump_char(char value);
extern void _FI_dump_int(int value);
extern void _FI_dump_short(short value);
extern void _FI_dump_double(double value);
extern void _FI_dump_string(char *string);
extern void _FI_dump_enter(FILE *fp, jmp_buf env);
/* efpi.c */
extern int _FI_get_active_screen(int *xscreen);
/* egpi.c */
extern int _FI_g_set_stan_vars(struct FIgadget_obj *gadget, struct standard_st *str);
/* egpi2.c */
/* fei.c */
extern int _FI_iforms_strlen(char *s, int font_type);
extern int _FI_move_index(unsigned char *string, int index, int no_char, int font_type);
extern int _FI_symbol_available(char *symbol_file, int *font_id, char *path);
extern int _FI_font_available(char *font_file, int bodysize, Font *font_id, int *font_type);
extern int _FI_load_symbol(char *symbol_file, char *path);
extern int _FI_colormap_notify(Colormap cmap, int cmap_size);
extern unsigned long _FI_translate_color(int screen, int color);
extern int _FI_map_character(XKeyEvent *key, char *character);
extern int _FI_get_keyboard_data(char *character, int *count, int font_type);
extern int _FI_calc_text(Font font_id, char *text, int length, int *height, int *width, int *line_spacing, int font_type);
extern int _FI_draw_text(Window window, Font font_id, char *text, int length, int xpos, int ypos, int font_height, int *nx, int *ny, int font_type);
extern int _FI_find_symbol_path_and_id(char *path, char *symbol_name, int *symbol_id);
extern int _FI_find_font_id(char *fontname, double bodysize, Font *font_id, float *actual_bodysize, int gadget_type, int *font_type);
extern int _FI_find_form(char *path, char *form_name);
/* field.c */
extern int _FI_fld_get_line_OFF_COLOR(struct FIfld_obj *field, int line);
extern int _FI_fld_get_line_ON_COLOR(struct FIfld_obj *field, int line);
extern int _FI_fld_activate(struct FIfld_obj *field);
extern void _FI_fld_calc_nv(struct FIfld_obj *field);
extern void _FI_fld_change_text(struct FIfld_obj *field, double delta_x, double delta_y);
extern void _FI_fld_add_vscrl(struct FIfld_obj *field);
extern void _FI_fld_add_hscrl(struct FIfld_obj *field);
extern int _FI_fld_set_erase_color(struct FIfld_obj *field, int erase_color);
extern int _FI_fld_erase(struct FIfld_obj *field, Window window);
extern int _FI_fld_display(struct FIfld_obj *field, Window window);
extern void _FI_fld_draw_bezel(struct FIfld_obj *field, Window window);
extern void _FI_fld_draw_sym_area(struct FIfld_obj *field, Window window);
extern int _FI_fld_refresh_data(struct FIfld_obj *field, Window window);
extern int _FI_fld_set_buffer(struct FIfld_obj *field, int size, int reset_all_columns);
extern void _FI_fld_add_to_line(struct FIfld_obj *field, int row, int new_len);
extern void _FI_fld_set_defaults(struct FIfld_obj *field, int size);
extern void _FI_fld_reset_buffer(struct FIfld_obj *field);
extern void _FI_fld_reset(struct FIfld_obj *field);
extern void _FI_fld_set_vscrl(struct FIfld_obj *field);
extern void _FI_fld_load(struct FIfld_obj *field, int form_version);
extern void _FI_fld_delete(struct FIfld_obj *field);
extern int _FI_fld_adjust(struct FIfld_obj *field, double delta_x, double delta_y);
extern int _FI_widest_char(int font_type, char *str);
/* field2.c */
extern int _FI_fld_notify(struct FIfld_obj *field, double value);
extern void _FI_fld_hilite(struct FIfld_obj *field);
extern void _FI_fld_unhilite(struct FIfld_obj *field);
extern void _FI_fld_disable(struct FIfld_obj *field);
extern void _FI_fld_enable(struct FIfld_obj *field);
extern int _FI_fld_call_notify(struct FIfld_obj *field, int *complete, double value);
extern int _FI_fld_toggle_select_flag(struct FIfld_obj *field, Window window, int xpos, int ypos, int *complete, double *value);
extern int _FI_fld_process_displayed_list(struct FIfld_obj *list);
extern void _FI_fld_adjust_row_col(struct FIfld_obj *field, int xpos, int ypos);
extern void _FI_fld_get_xy(struct FIfld_obj *field, int num_chars, int *xpos, int *ypos);
extern void _FI_fld_draw_cursor(struct FIfld_obj *field, Window window, int focus, int block_color, int char_color);
extern void _FI_fld_un_select_row(struct FIfld_obj *field, Window window, int row);
extern void _FI_fld_select_row(struct FIfld_obj *field, Window window, int row);
extern void _FI_fld_refresh_row(struct FIfld_obj *field, Window window, int row);
extern int _FI_fld_find_gadget(struct FIfld_obj *field, int xpos, int ypos, struct FIgadget_obj **search_gadget);
extern int _FI_fld_change_case(struct FIfld_obj *field, int upper_lower_flag);
extern int _FI_fld_transpose(struct FIfld_obj *field);
extern int _FI_fld_verify_data(struct FIfld_obj *field);
extern void _FI_fld_justify_data(struct FIfld_obj *field);
/* fieldAdd.c */
extern void _FI_flip_string(char *str1, char *str2);
extern void _FI_shift_string(char s1[], char s2[], int n);
extern int _FI_fld_add_char(struct FIfld_obj *field, unsigned char *ch, int *pos);
extern void _FI_fld_insert_str(unsigned char *target_str, unsigned char *src_str, int num_insert);
extern int _FI_fld_add_CR(struct FIfld_obj *field, int *delete_status);
extern int _FI_fld_shift_buffer_down(struct FIfld_obj *field);
/* fieldDel.c */
extern int _FI_fld_back_space(struct FIfld_obj *field);
extern void _FI_fld_delete_char(struct FIfld_obj *field);
extern void _FI_fld_delete_eol(struct FIfld_obj *field);
extern void _FI_fld_delete_line(struct FIfld_obj *field);
extern int _FI_fld_undelete(struct FIfld_obj *field);
extern void _FI_fld_erase_to_eol(struct FIfld_obj *field, int *len, int *x, int *y);
extern void _FI_fld_shift_buffer_up(struct FIfld_obj *field);
/* fieldMove.c */
extern int _FI_fld_next(struct FIfld_obj *field, int count);
extern int _FI_fld_previous(struct FIfld_obj *field, int count);
extern int _FI_fld_forward(struct FIfld_obj *field, int count);
extern int _FI_fld_back(struct FIfld_obj *field, int count);
extern void _FI_fld_bol(struct FIfld_obj *field);
extern int _FI_fld_eol(struct FIfld_obj *field);
/* fieldScrl.c */
extern void _FI_fld_scrl_next(struct FIfld_obj *field, int count);
extern void _FI_fld_scrl_previous(struct FIfld_obj *field, int count);
extern void _FI_fld_scrl_forward(struct FIfld_obj *field, int count);
extern void _FI_fld_scrl_back(struct FIfld_obj *field, int count);
extern int _FI_fld_vscrl(struct FIfld_obj *field, double value);
/* fieldTrack.c */
extern void _FI_initialize_fld_new_values(void);
extern int _FI_fld_track_mouse(struct FIfld_obj *field, Window window, int xpos, int ypos, int *complete, double *value);
extern int _FI_fld_track_kbd(struct FIfld_obj *field, int direction, int prev_gadget_label);
extern int _FI_fld_track_keyboard(struct FIfld_obj *field, Window window, int *complete, double *value, int *delete_status);
extern int _FI_fld_track_keyboard2(struct FIfld_obj *field, Window window, int *complete, double *value, int *delete_status);
extern void _FI_fld_track_hscrl(struct FIfld_obj *field, int direction);
/* fieldWrap.c */
extern int _FI_fld_refresh_wrap_data(struct FIfld_obj *field, int start_row);
extern int _FI_fld_remove_last_word_from_line(int ac, int nc, char line[], char word[], int *pos);
extern void _FI_fld_add_word_to_start_of_line(char line[], char word[]);
extern void _FI_fld_reshuffle_lines(struct FIfld_obj *field, int start_line);
extern void _FI_fld_reshuffle_up(struct FIfld_obj *field, int start_line);
extern void _FI_fld_reshuffle_down(struct FIfld_obj *field, int start_line);
extern int _FI_fld_remove_first_word_from_line(char line[]);
extern void _FI_fld_get_first_word_of_line(char *line, char word[]);
extern void _FI_fld_calc_remaining_space(int nvc, char *line, int *blank_spaces);
/* find.c */
extern int _FI_f_is_gadget_found(int gadget_label, int _FI_found_gadgets[], int _FI_found_gadgets_next_index);
extern int _FI_f_find_by_point_maybe_return(int gadget_label, int **_FI_found_gadgets, int *_FI_found_gadgets_size, int *_FI_found_gadgets_next_index);
extern int _FI_grp_find_by_area(struct FIform_obj *form, int group_label, int x1, int y1, int x2, int y2, int *labels_size, int *num_labels, int **labels);
extern int _FI_is_pt_next_to_line_seg(int max_dist, int wt, int x1, int y1, int x2, int y2, int x, int y);
extern void _FI_get_line_ABC(int x1, int y1, int x2, int y2, double *A, double *B, double *C);
extern int _FI_get_dist_pt_line(int x1, int y1, int x2, int y2, int x, int y);
/* fldpi.c */
extern int _FI_fld_get_field(struct FIform_obj *form, int label, int col, struct FIfld_obj **field);
/* fldpi2.c */
/* fldpiRow.c */
extern int _FI_fld_delete_rows(struct FIfld_obj *field, int start_row, int num_rows, int *roff_adjusted);
extern int _FI_fld_insert_blank_row(struct FIfld_obj *field, int row);
/* form.c */
extern void _FI_f_paint(struct FIform_obj *form);
extern void _FI_f_modify_window(struct FIform_obj *form);
extern void _FI_f_set_window_attr(Window window, int Xscreen);
extern int _FI_f_load_form(struct FIform_obj *form, int *num_gadgets, int *form_version);
extern int _FI_f_load_gadgets(struct FIform_obj *form, int form_version);
extern void _FI_f_adjust_location(int screen, short *xlo, short *ylo, short *xhi, short *yhi);
extern int _FI_f_get_next_neg_label(struct FIform_obj *form, int *next_label);
extern int _FI_Xwindow_to_index(Window win);
/* fpi.c */
extern int _FI_make_Xwindow(struct FIform_obj *fp);
extern int _FI_default_function(void);
extern int _FI_default_process_data_function(int data_type, char *data_string, Form form);
extern int _FI_default_set_window_attr_function(Window window_number);
extern int _FI_default_activate_help_function(Form form);
extern Bool _FI_flush_destroy(Display *display, XEvent *event, Window *wind);
extern int _FI_f_new(int label, char *form_name, int (*notification_routine )(), struct FIform_obj **form);
extern int _FI_f_delete(struct FIform_obj *form);
/* fs.c */
/* gad_disp.c */
extern int _FI_g_display(struct FIgadget_obj *gadget, Window window);
extern int _FI_g_set_displayable(struct FIgadget_obj *gadget);
extern int _FI_g_erase(struct FIgadget_obj *gadget);
extern int _FI_g_hilite(struct FIgadget_obj *gadget);
extern int _FI_g_unhilite(struct FIgadget_obj *gadget);
extern int _FI_g_disable(struct FIgadget_obj *gadget);
extern int _FI_g_enable(struct FIgadget_obj *gadget);
extern int _FI_g_find_contrasting_on_color(int screen, int translated_on_color, int translated_form_bg_color);
/* gad_load.c */
extern void _FI_read_hooks(struct FIgadget_obj *gadget);
extern void _FI_g_load(struct FIgadget_obj *gadget, int form_version, int gadget_version);
extern void _FI_group_load(struct FIform_obj *form, int label, int to_grp_label, int form_version);
/* gad_loc.c */
extern void _FI_g_adjust_size(struct FIgadget_obj *gadget, double delta_x, double delta_y);
extern int _FI_g_change_location(struct FIgadget_obj *gadget, int delta_x, int delta_y);
extern int _FI_g_track_mouse(struct FIgadget_obj *gadget, Window window, int xpos, int ypos, int *complete, double *value);
extern int _FI_g_find_gadget(struct FIgroup_obj *group, int xpos, int ypos, struct FIgadget_obj **search_gadget);
extern int _FI_g_get_dsize(struct FIgadget_obj *gadget, double *xsize, double *ysize);
extern int _FI_g_get_size(struct FIgadget_obj *gadget, int *xsize, int *ysize);
extern int _FI_g_find_parent_gadget(struct FIgroup_obj *group, int xpos, int ypos, struct FIgadget_obj **search_gadget);
/* gad_mem.c */
extern int _FI_g_delete(struct FIgadget_obj *gadget, int calc_flag);
extern int _FI_g_new(struct FIform_obj *form, int gadget_type, int label, struct FIgadget_obj **ret_gadget);
/* gad_sym.c */
extern void _FI_g_load_symbol(struct FIgadget_obj *gadget);
extern void _FI_g_change_symbol(struct FIgadget_obj *gadget);
/* gad_text.c */
extern int _FI_mlt_get_token(unsigned char *text, int *offset, int *num_chars, int font_type);
extern void _FI_mlt_get_lines(unsigned char *text, int *num_lines, int *largest_width, int font_id, int font_type);
extern void _FI_g_draw_text(struct FIgadget_obj *gadget, int xlo, int ylo, int xhi, int yhi, unsigned char *text, int num_lines, int font_height, int borders, int erase_flag);
extern void _FI_g_change_text(struct FIgadget_obj *gadget, double delta_y);
/* gad_util.c */
extern int _FI_g_activate(struct FIgadget_obj *gadget);
extern void _FI_g_common(struct FIgadget_obj *gadget);
extern int _FI_g_set_notify(struct FIgadget_obj *gadget, int notify_flag);
extern int _FI_g_reset(struct FIgadget_obj *gadget);
extern struct FIgadget_obj *_FI_g_get_id(struct FIform_obj *form, int gadget_label);
extern int _FI_g_set_state(struct FIgadget_obj *gadget, double state);
/* gauge.c */
extern void _FI_gauge_fill_rect(struct FIgauge_obj *gauge, int rect, int translated_color);
extern int _FI_gauge_set_value(struct FIgauge_obj *gauge, double value);
extern void _FI_gauge_get_area(struct FIgauge_obj *gauge, int *xlo, int *ylo, int *xhi, int *yhi);
extern int _FI_gauge_display(struct FIgauge_obj *gauge, Window window);
extern int _FI_gauge_erase(struct FIgauge_obj *gauge, Window window);
/* generic.c */
extern void _FI_generic_move_hort(struct FIgadget_obj *gadget, int new_x);
extern void _FI_generic_move_vert(struct FIgadget_obj *gadget, int new_y);
extern int _FI_generic_adjust(struct FIgadget_obj *gadget, double delta_x, double delta_y);
extern int _FI_generic_find_gadget(struct FIgadget_obj *gadget, int xpos, int ypos);
extern int _FI_generic_erase(struct FIgadget_obj *gadget, Window window);
extern void _FI_clipping_off(struct FIgadget_obj *gadget);
extern int _FI_is_in_clip_rectangle(struct FIgadget_instance *gad_inst);
extern int _FI_adjust_clip_rectangle(XRectangle *rect);
extern int _FI_expand_clip_rectangle(int x, int y, int width, int height, int *xlo, int *ylo, int *xhi, int *yhi);
extern int _FI_generic_timer(double wait_secs, int set);
/* gpi.c */
/* group.c */
extern int _FI_grp_count(struct FIgroup_obj *group);
extern void _FI_grp_pass_on_double(struct FIgadget_obj *gadget, int (*function_ptr )(), double arg1);
extern void _FI_grp_pass_on_float(struct FIgadget_obj *gadget, int (*function_ptr )(), float arg1);
extern void _FI_grp_pass_on_int(struct FIgadget_obj *gadget, int (*function_ptr )(), int arg1, int arg2);
extern void _FI_grp_pass_on_int_float(struct FIgadget_obj *gadget, int (*function_ptr )(), int arg1, float arg2);
extern void _FI_grp_pass_on_int_double(struct FIgadget_obj *gadget, int (*function_ptr )(), int arg1, double arg2);
extern void _FI_grp_notify_selected(struct FIgadget_obj *gadget);
extern void _FI_grp_pass_on_id_double(struct FIgadget_obj *gadget, int (*function_ptr )(), double arg1, double arg2);
extern void _FI_grp_pass_on_id_double_always(struct FIgadget_obj *gadget, int (*function_ptr )(), double arg1, double arg2);
extern void _FI_grp_pass_on_id_float(struct FIgadget_obj *gadget, int (*function_ptr )(), float arg1, float arg2);
extern void _FI_grp_pass_on_id_float_always(struct FIgadget_obj *gadget, int (*function_ptr )(), float arg1, float arg2);
extern int _FI_grp_pass_on_id_int(struct FIgadget_obj *gadget, int (*function_ptr )(), int arg1, int arg2);
extern void _FI_grp_pass_on_id_int_always(struct FIgadget_obj *gadget, int (*function_ptr )(), int arg1, int arg2);
extern int _FI_grp_alloc(struct FIgroup_obj *group, int alloc_size);
extern int _FI_grp_delete(struct FIgroup_obj *group);
extern int _FI_grp_get_next_slot(struct FIgroup_obj *group);
extern int _FI_grp_get_slot(struct FIgroup_obj *group, struct FIgadget_obj *gadget);
extern struct FIgadget_obj *_FI_g_get_id_from_group(struct FIgroup_obj *group, int gadget_label);
extern int _FI_grp_is_label_used_within_group(struct FIgroup_obj *group, int label);
extern void _FI_grp_change_size(struct FIgroup_obj *group, struct FIgadget_obj *gadget);
extern void _FI_grp_calculate_size(struct FIgroup_obj *group);
extern int _FI_g_add_to_group(struct FIgadget_obj *gadget, int group_label, int add_group_itself);
extern void _FI_grp_pass_on_int_always(struct FIgadget_obj *gadget, int (*function_ptr )(), int arg1, int arg2);
/* grppi.c */
/* hm.c */
extern int _FIh_add_child_form(struct FIform_obj *parent_form, struct FIform_obj *child_form);
extern int _FIh_remove_child_form(struct FIform_obj *parent_form, struct FIform_obj *child_form);
/* icon.c */
extern int _MI_window_routine(int menu_label, int event, struct FIform_obj *menu);
extern int _MI_process_icon(int menu_label, int icon_id, struct FIform_obj *menu);
/* iforms_stub.c */
/* import.c */
/* line.c */
extern void _FI_graphic_activate(struct FIgraphic_instance *graph);
extern void _FI_line_draw_line(struct FIline_obj *line, int Xscreen, Window window, int off_color, int shadow_color, int glint_color);
extern int _FI_line_display(struct FIline_obj *line, Window window);
extern int _FI_line_erase(struct FIline_obj *line, Window window);
/* listpi.c */
/* listpi2.c */
/* load.c */
extern void _FI_read_bytes(int num, char *str);
extern char _FI_read_char(void);
extern int _FI_read_int(void);
extern short _FI_read_short(void);
extern double _FI_read_double(void);
extern char *_FI_read_string(int size, char *string);
extern char *_FI_reada_string(void);
extern int _FI_read_strlen(void);
extern void _FI_read_enter(FILE *fp, jmp_buf env);
/* load_sym.c */
extern int _FI_symbol_is_defined(unsigned char *symbol_data, unsigned char symbol_index);
extern int _FI_get_symbol_info(unsigned char *symbol_data, unsigned char symbol_index, int *bitmapoffset, unsigned char *bitmap_width, unsigned char *bitmap_height, unsigned char *xoff, unsigned char *yoff, unsigned char *cell_width, unsigned char *cell_height);
extern int _FI_create_symbol_bitmap(unsigned char *symbol_data, int bitmapoffset, unsigned char bitmap_width, unsigned char bitmap_height, unsigned char **bitmap);
extern int _FI_load_symbol_file(char *path, struct _FI_sym_st *symbol_data);
/* look.c */
extern void _FI_look_look_group(struct FIgroup_obj *group);
extern void _FI_look_fill_in_type(int gadget_type, char **type_string);
extern void _FI_look_display_gadget(struct FIgadget_obj *gadget, int index);
/* mcf.c */
extern void _FI_mcf_set_color(struct FImcf_obj *mcf, int color, int on_color_flag);
extern void _FI_mcf_set_erase_color(struct FImcf_obj *mcf, int erase_color);
extern int _FI_mcf_find_gadget(struct FImcf_obj *mcfield, int xpos, int ypos, struct FIgadget_obj **search_gadget);
extern void _FI_mcf_hilite(struct FImcf_obj *mcfield);
extern void _FI_mcf_unhilite(struct FImcf_obj *mcfield);
extern void _FI_mcf_disable(struct FImcf_obj *mcfield);
extern void _FI_mcf_enable(struct FImcf_obj *mcfield);
extern void _FI_mcf_load(struct FImcf_obj *mcfield, int form_version);
extern int _FI_mcf_activate(struct FImcf_obj *mcfield);
extern void _FI_mcf_adjust_xhi(struct FImcf_obj *mcfield);
extern void _FI_mcf_adjust_cols(struct FImcf_obj *mcfield);
extern int _FI_mcf_display(struct FImcf_obj *mcfield, Window window);
extern void _FI_mcf_set_active_row(struct FImcf_obj *mcfield, struct FIfld_obj *field);
extern int _FI_mcf_erase(struct FImcf_obj *mcfield, Window window);
extern int _FI_mcf_adjust(struct FImcf_obj *mcfield, double delta_x, double delta_y);
/* mcfScrlTrk.c */
extern int _FI_mcf_vscrl(struct FImcf_obj *mcfield, double value);
extern void _FI_mcf_set_hscrl(struct FImcf_obj *mcfield);
extern int _FI_mcf_hscrl(struct FImcf_obj *mcfield, double value);
extern void _FI_mcf_set_vscrl(struct FImcf_obj *mcfield);
extern void _FI_mcf_add_hscrl(struct FImcf_obj *mcfield);
extern void _FI_mcf_add_vscrl(struct FImcf_obj *mcfield);
extern int _FI_mcf_track_mouse(struct FImcf_obj *mcfield, Window window, int xpos, int ypos, int *complete, double *value);
extern int _FI_mcf_track_kbd(struct FImcf_obj *mcfield, int direction, int prev_gadget_label);
extern int _FI_mcf_track_keyboard(struct FImcf_obj *mcfield, Window window, int *complete, double *value, int *delete_status);
/* mcfpi.c */
/* memory.c */
extern char *_FI_s_new(char *string);
extern void _FI_s_free(char *sp);
extern void _FI_s_rep(char **sp, char *string);
extern void _FI_g_free_symbols(struct FIgadget_obj *gadget);
/* menusub.c */
extern void _MS_check_ptr(struct FIform_obj *menu_ptr);
extern int _MS_window_routine(int form_label, int event, struct FIform_obj *menu);
extern int _MS_menu_move(int menu_label, int location);
extern int _MS_notify(int form_label, int gadget_label, double value, struct FIform_obj *form_ptr);
/* mepi.c */
/* message.c */
extern int _FI_confirm_box(int screen, int xpos, int ypos, char *title, int title_color, char *title_font, double title_bodysize, char *message, int message_color, char *message_font, double message_bodysize, int display_mode, int presentation_mode, int line_length);
/* miset.c */
/* modify.c */
/* mpi.c */
extern int _MI_btn_set_user_pointer(struct FIgadget_obj *gadget, struct pal_info_st *pal_info);
extern int _MI_btn_set_menu_button(struct FIgadget_obj *gadget);
/* palette.c */
extern int _MI_create_palette(struct FIform_obj *form, char *menu_name, struct FIgroup_obj **palette);
extern void _MI_display_palette(struct FIgroup_obj *palette);
extern void _MI_erase_palette(struct FIgroup_obj *palette);
/* panel.c */
extern void _MI_panel_set_button_off(struct FIgadget_obj *button);
extern int _MI_panel_notify_routine(int form_label, int gadget_label, double value, struct FIform_obj *menu);
/* pass.c */
extern int _FI_g_receive_data(struct FIgadget_obj *gadget, double value);
extern void _FI_g_pass_data(struct FIgadget_obj *gadget);
/* pocket.c */
extern void _MI_setup_pocket(struct FIform_obj *menu);
extern void _MI_process_pocket(struct FIform_obj *menu);
extern void _MI_reset_mi_last_button(void);
/* rect.c */
extern void _FI_rect_draw_box(Window window, int xlo, int ylo, int xhi, int yhi);
extern void _FI_rect_draw(struct FIrect_obj *rect, Window window, int glint_color, int shadow_color, int gadget_color, int fill_color);
extern int _FI_rect_display(struct FIrect_obj *rect, Window window);
extern int _FI_rect_erase(struct FIrect_obj *rect, Window window);
/* save.c */
extern void _FI_fld_dump(struct FIfld_obj *field);
extern void _FI_mcf_dump(struct FImcf_obj *mcfield);
extern void _FI_f_dump_form(struct FIform_obj *form);
extern void _FI_dump_hooks(struct FIgadget_obj *gadget);
extern int _FI_g_dump(struct FIgadget_obj *gadget);
/* scale.c */
extern void _FI_sym_scale_up_x_up_y(Window window_no, struct FIsym_instance *symbol_ptr, double scale_factor_x, double scale_factor_y, int font_id);
extern void _FI_sym_scale_down_x_down_y(Window window_no, struct FIsym_instance *symbol_ptr, double scale_factor_x, double scale_factor_y, int font_id);
extern void _FI_sym_scale_down_x_up_y(Window window_no, struct FIsym_instance *symbol_ptr, double scale_factor_x, double scale_factor_y, int font_id);
extern void _FI_sym_scale_up_x_down_y(Window window_no, struct FIsym_instance *symbol_ptr, double scale_factor_x, double scale_factor_y, int font_id);
extern void _FI_sym_get_pattern(double scale_factor, char **pattern, int shrinking_flag);
extern int _FI_sym_load(char *symbol_file, struct FIgadget_obj *gadget, struct FIsym_instance *symbol_ptr);
extern void _FI_sym_draw(Window window_no, int xpos, int ypos, Font font_id, struct FIsym_instance *symbol_ptr, double scale_factor_x, double scale_factor_y, int screen);
/* scroll.c */
extern int _FI_scrl_erase(struct FIscrl_obj *scroll, Window window);
extern int _FI_scrl_adjust(struct FIscrl_obj *scroll, double delta_x, double delta_y);
extern int _FI_scrl_activate(struct FIscrl_obj *scroll);
extern void _FI_scrl_calc_puck(struct FIscrl_obj *scroll);
extern void _FI_scrl_calc_bar(struct FIscrl_obj *scroll);
extern int _FI_scrl_display(struct FIscrl_obj *scroll, Window window);
extern void _FI_scrl_set_value(struct FIscrl_obj *scroll, double value);
extern int _FI_scrl_track_mouse(struct FIscrl_obj *scroll, Window window, int xpos, int ypos, int *complete, double *value);
/* seq.c */
extern int _FI_range_set_notify(struct FIgadget_obj *gadget, char *value);
extern int _FI_add_value(struct FIgadget_obj *gadget, double value);
extern int _FI_add_minor(struct FIgadget_obj *gadget, int pos);
extern int _FI_generic_track_kbd(struct FIgadget_obj *gadget, int direction, int prev_gadget_label);
extern int _FI_g_track_kbd(struct FIgadget_obj *gadget, int direction, int prev_in_seq);
/* setup.c */
extern void _FI_parse_unix_path(char *path, char ***dirs, int *num_dirs);
extern int _FI_is_in_list(char **list, int num_list, char *string);
extern int _FI_set_generic_path(char *path, char ***path_list, int *num_paths);
extern char *_FI_font_alias(char *name, int size);
extern int _FI_find_closest_font(char *name, int size);
extern int _FI_create_pixmaps(Window window, int screen);
/* slider.c */
extern void _FI_snap_value(struct FIgadget_obj *gadget, double *value, double max_value);
extern void _FI_format_string(struct FIgadget_obj *gadget, char *string, double value);
extern void _FI_sld_erase_button(struct FIsld_obj *slider, Window window, int current_xlo, int current_ylo);
extern void _FI_sld_display_button(struct FIsld_obj *slider, Window window, int xpos, int ypos);
extern void _FI_sld_get_btn_location(struct FIsld_obj *slider, double value, int *xpos, int *ypos);
extern void _FI_sld_calc_display_low_high(struct FIsld_obj *slider, int *display_low, int *display_high);
extern int _FI_sld_erase(struct FIsld_obj *slider, Window window);
extern int _FI_sld_display(struct FIsld_obj *slider, Window window);
extern void _FI_sld_calc(struct FIsld_obj *slider);
extern void _FI_sld_calc_value(struct FIsld_obj *slider, int xpos, int ypos);
extern void _FI_sld_adjust_location(struct FIsld_obj *slider, int *xpos, int *ypos);
extern void _FI_sld_track_mouse(struct FIsld_obj *slider, Window window, int xpos, int ypos, int *complete, double *value);
extern int _FI_sld_adjust(struct FIsld_obj *slider, double delta_x, double delta_y);
extern int _FI_sld_activate(struct FIsld_obj *slider);
extern void _FI_sld_set_value(struct FIsld_obj *slider, double value);
/* sym_info.c */
/* symbol.c */
extern int _FI_sym_display(struct FIsym_obj *symbol_obj, Window window);
extern int _FI_sym_erase(struct FIsym_obj *symbol_obj, Window window);
extern int _FI_sym_adjust(struct FIsym_obj *symbol_obj, double delta_x, double delta_y);
extern int _FI_sym_activate(struct FIsym_obj *symbol_obj);
/* text.c */
extern int _FI_txt_erase(struct FItext_obj *text_obj, Window window);
extern int _FI_txt_display(struct FItext_obj *text_obj, Window window);
extern int _FI_txt_adjust(struct FItext_obj *text_obj, double delta_x, double delta_y);
extern int _FI_txt_activate(struct FItext_obj *text_obj);
/* toggle.c */
extern int _FI_tog_display(struct FItog_obj *toggle_obj, Window window);
extern void _FI_tog_track_mouse(struct FItog_obj *toggle_obj, Window window, int *complete, double *value);
extern void _FI_tog_delete(struct FItog_obj *toggle_obj);
extern int _FI_tog_adjust(struct FItog_obj *toggle_obj, double delta_x, double delta_y);
extern int _FI_tog_activate(struct FItog_obj *toggle_obj);

#endif
