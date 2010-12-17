#ifndef wforms_pro
#define wforms_pro

/* From collapse.c */
extern int WINAPI FIf_collapse(
  Form form);
extern int WINAPI FIf_uncollapse(
  Form form);

/* From dial.c */

/* From erase.c */
extern int WINAPI FIg_display(
  Form form,
  int label);
extern int WINAPI FIg_erase(
  Form form,
  int label);

/* From f_dsplay.c */
extern int WINAPI FIf_display(
  Form form);

/* From f_getloc.c */
extern int WINAPI FIf_get_location(
  Form form,
  int *xorg,
  int *yorg);

/* From f_getsel.c */
extern int WINAPI FIfld_get_select(
  Form form,
  int label,
  int row,
  int col,
  int *sel_flag);

/* From f_getsiz.c */
extern int WINAPI FIf_get_size(
  Form form,
  int *xsize,
  int *ysize);

/* From f_gettxt.c */
extern int WINAPI FIfld_get_text(
  Form form,
  int label,
  int row,
  int col,
  int num_char,
  char *text,
  int *sel_flag,
  int *r_pos);
extern int WINAPI FIfld_get_text_length(
  Form form,
  int label,
  int row,
  int col,
  int *length);

/* From f_notify.c */
extern int WINAPI FIf_notify(
  HWND hwnd,
  WORD Message,
  WORD wParam,
  LONG lParam);

/* From f_poscur.c */
extern int WINAPI FIfld_pos_cursor(
  Form form,
  int label,
  int row,
  int r_pos,
  int col,
  int col_pos,
  int ch,
  int ch_pos);

/* From f_setloc.c */
extern int WINAPI FIf_set_location(
  Form form,
  int xorg,
  int yorg);

/* From f_setsel.c */
extern int WINAPI FIfld_set_select(
  Form form,
  int label,
  int row,
  int col,
  int sel_flag);

/* From f_setsiz.c */
extern int WINAPI FIf_set_size(
  Form form,
  int xsize,
  int ysize);

/* From f_settxt.c */
extern int WINAPI FIfld_set_text(
  Form form,
  int label,
  int row,
  int col,
  char *text,
  int sel_flag);
extern int WINAPI FIfld_build_text(
  FI_gadget *t_gadget,
  FI_gadget *gadget_ptr);

/* From f_sorloc.c */
extern int WINAPI FIf_set_orig_location(
  Form form,
  int xorg,
  int yorg);

/* From f_sorsiz.c */
extern int WINAPI FIf_set_orig_size(
  Form form,
  int xsize,
  int ysize);

/* From fi.c */
extern int WINAPI FI_clear_event(
  int event);
extern long FAR PASCAL FI_new_edit_proc(
  HWND hwnd,
  unsigned message,
  WORD wparam,
  LONG lparam);
extern long FAR PASCAL FI_new_listbox_proc(
  HWND hwnd,
  unsigned message,
  WORD wparam,
  LONG lparam);
extern int WINAPI FI_enter(
  HANDLE hInstance,
  HANDLE hPrevInstance);
extern int WINAPI FI_forms_active(
);
extern int WINAPI FI_get_form_path(
  char *form_path);
extern int WINAPI FI_get_form_path_length(
  int *form_path_length);
extern int WINAPI FI_load_font(
  char *typeface,
  int bodysize,
  int *actual_bodysize,
  int *font_id);
extern int WINAPI FI_modify_env(
  int  env_function,
  int  (*func_ptr)());
extern int WINAPI FI_process_event(
  int event_mask);
extern int WINAPI FI_set_form_path(
  char *path);
extern int WINAPI FI_set_symbol_path(
  char *path);
extern int WINAPI FI_count_chars(
  char *string,
  char it);
extern int WINAPI FI_string_width(
  char *string,
  char it);
extern int WINAPI FI_flush_queue(
);

/* From fibtn.c */
extern int WINAPI FIbtn_get_auto_pop_up_state(
  Form form,
  int label,
  int *setting);
extern int WINAPI FIbtn_set_auto_pop_up_off(
  Form form,
  int label);
extern int WINAPI FIbtn_set_auto_pop_up_on(
  Form form,
  int label);

/* From fif.c */
extern int WINAPI FIf_reset(
  Form form);
extern int WINAPI FIf_SetTitlebarText (
  Form form,
  char *title);
extern int WINAPI FIf_delete(
  Form form);
extern int WINAPI FIf_display_gadgets(
  HDC hdc,
  Form form);
extern int WINAPI FIf_erase(
  Form form);
extern int WINAPI FIf_find_by_area(
  Form form,
  int group_label,
  int x1,
  int y1,
  int x2,
  int y2,
  int *num_labels,
  int **labels);
extern int WINAPI FIf_find_by_point(
  Form form,
  int group_label,
  int xpos,
  int ypos,
  int max_dist,
  int *label,
  int reset_search_flag);
extern int WINAPI FIf_get_attr(
  Form form,
  int *form_mask);
extern int WINAPI FIf_get_collapse_symbol(
  Form form,
  char *fontfile,
  int *symindex);
extern int WINAPI FIf_get_color(
  Form form,
  int *color);
extern int WINAPI FIf_get_label(
  Form form,
  int *label);
extern int WINAPI FIf_get_next_label(
  Form form,
  int *next_label);
extern int WINAPI FIf_get_orig_location(
  Form form,
  int *xlo,
  int *ylo);
extern int WINAPI FIf_get_scaling(
  Form form,
  int *scaling_flag);
extern int WINAPI FIf_get_start_seq(
  Form form,
  int *label);
extern int WINAPI FIf_set_start_seq(
  Form form,
  int label);
extern int WINAPI FIf_get_window(
  Form form,
  int *window);
extern int WINAPI FIf_get_form_ptr(
  Form *form,
  int window);
extern int WINAPI FIf_is_collapsed(
  Form form,
  int *collapse_status);
extern int WINAPI FIf_is_displayed(
  Form form,
  int *display_status);
extern int WINAPI FIf_new(
  int  label,
  char  *form_name,
  void  (*notify_routine)(),
  Form  *form);
extern int WINAPI FIf_set_attr(
  Form form,
  int form_mask);
extern int WINAPI FIf_set_collapse_location(
  Form form,
  int xpos,
  int ypos);
extern int WINAPI FIf_set_collapse_symbol(
  Form form,
  char *fontfile,
  int symindex);
extern int WINAPI FIf_set_color(
  Form form,
  int color);
extern int WINAPI FIf_set_initial_notification_routine(
  Form  form,
  void  (*init_routine));
extern int WINAPI FIf_set_notification_routine(
  Form  form,
  void  (*notify_routine)());
extern int WINAPI FIf_set_seq_off(
  Form form);
extern int WINAPI FIf_set_seq_on(
  Form form);
extern int WINAPI FIf_set_window_event_routine(
  Form  form,
  void  (*routine)());
extern int WINAPI FIf_set_button_intercept_routine(
);
extern int WINAPI FIf_process_point(
);
extern int WINAPI FIf_set_screen (
  Form form,
  int screen);

/* From fifld.c */
extern int WINAPI FIfld_delete_rows(
  Form form,
  int label,
  int start_row,
  int num_rows);
extern int WINAPI FIfld_erase_cursor(
);
extern int WINAPI FIfld_get_active_char(
  Form form,
  int label,
  int col,
  int *charnum,
  int *position);
extern int WINAPI FIfld_get_active_row(
  Form form,
  int label,
  int *row,
  int *position);
extern int WINAPI FIfld_get_attr(
  Form form,
  int label,
  int col,
  long *fld_mask);
extern int WINAPI FIfld_get_default_text_length(
  Form form,
  int label,
  int row,
  int col,
  int *length);
extern int WINAPI FIfld_get_default_text(
  Form form,
  int label,
  int row,
  int col,
  int num_char,
  char *text,
  int *sel_flag);
extern int WINAPI FIfld_get_format_string(
);
extern int WINAPI FIfld_get_list_default_text(
  Form form,
  int label,
  int row,
  int col,
  int num_char,
  char *text,
  int *sel_flag);
extern int WINAPI FIfld_get_list_default_text_length(
  Form form,
  int label,
  int row,
  int col,
  int *length);
extern int WINAPI FIfld_get_list_location(
  Form form,
  int label,
  int col,
  int *xpos,
  int *ypos);
extern int WINAPI FIfld_get_list_mode(
  Form form,
  int label,
  int col,
  int *mode);
extern int WINAPI FIfld_get_list_num_rows(
  Form form,
  int label,
  int col,
  int *rows);
extern int WINAPI FIfld_get_list_scroll(
  Form form,
  int label,
  int *vflag,
  int *hflag);
extern int WINAPI FIfld_get_list_select(
  Form form,
  int label,
  int row,
  int col,
  int *flag);
extern int WINAPI FIfld_get_list_size(
  Form form,
  int label,
  int col,
  int *xsize,
  int *ysize);
extern int WINAPI FIfld_get_list_text(
  Form form,
  int label,
  int row,
  int col,
  int num_char,
  char *text,
  int *sel_flag);
extern int WINAPI FIfld_get_list_text_length(
  Form form,
  int label,
  int row,
  int col,
  int *length);
extern int WINAPI FIfld_get_mode(
  Form form,
  int label,
  int col,
  int *mode);
extern int WINAPI FIfld_get_num_rows(
  Form form,
  int label,
  int *num_rows);
extern int WINAPI FIfld_get_num_vis_chars(
  Form form,
  int label,
  int col,
  int *num_chars);
extern int WINAPI FIfld_get_num_vis_rows(
  Form form,
  int label,
  int *num_rows);
extern int WINAPI FIfld_get_row_offset(
  Form form,
  int label,
  int *offset);
extern int WINAPI FIfld_get_type(
  Form form,
  int label,
  int col,
  int *type);
extern int WINAPI FIfld_get_value(
  Form form,
  int label,
  int row,
  int col,
  double *value,
  int *sel_flag,
  int *r_pos);
extern int WINAPI FIfld_insert_blank_row(
  Form form,
  int label,
  int row);
extern int WINAPI FIfld_set_active_char(
);
extern int WINAPI FIfld_set_active_row(
  Form form,
  int label,
  int row,
  int position);
extern int WINAPI FIfld_set_attr(
  Form form,
  int label,
  int col,
  long mask);
extern int WINAPI FIfld_set_default_text(
  Form form,
  int label,
  int row,
  int col,
  char *text,
  int sel_flag);
extern int WINAPI FIfld_set_format_string(
);
extern int WINAPI FIfld_set_list_default_text(
  Form form,
  int label,
  int row,
  int col,
  char *text,
  int sel_flag);
extern int WINAPI FIfld_set_list_location(
  Form form,
  int label,
  int col,
  int xpos,
  int ypos);
extern int WINAPI FIfld_set_list_mode(
  Form form,
  int label,
  int col,
  int mode);
extern int WINAPI FIfld_set_list_num_rows(
  Form form,
  int label,
  int col,
  int num_rows);
extern int WINAPI FIfld_set_list_scroll(
  Form form,
  int label,
  int vert_flag,
  int horz_flag);
extern int WINAPI FIfld_set_list_select(
  Form form,
  int label,
  int row,
  int col,
  int flag);
extern int WINAPI FIfld_set_list_size(
  Form form,
  int label,
  int col,
  int xsize,
  int ysize);
extern int WINAPI FIfld_set_list_text(
  Form form,
  int label,
  int row,
  int col,
  char *text,
  int sel_flag);
extern int WINAPI FIfld_set_max_num_chars(
  Form form,
  int label,
  int col,
  int num_chars);
extern int WINAPI FIfld_set_max_num_rows(
  Form form,
  int label,
  int num_rows);
extern int WINAPI FIfld_set_mode(
  Form form,
  int label,
  int col,
  int mode);
extern int WINAPI FIfld_set_num_rows(
  Form form,
  int label,
  int num_rows);
extern int WINAPI FIfld_clear_rows (
  FI_gadget *t_gadget,
  int num_rows);
extern int WINAPI FIfld_clear_list_rows (
  FI_gadget *gadget_ptr,
  int num_rows);
extern int WINAPI FIfld_check_num_rows(
  FI_gadget *gadget_ptr,
  int num_rows);
extern int WINAPI FIfld_check_num_list_default_rows (
  FI_gadget *gadget_ptr,
  int num_rows);
extern int WINAPI FIfld_check_num_list_rows (
  FI_gadget *gadget_ptr,
  int num_rows);
extern int WINAPI FIfld_set_num_vis_chars(
  Form form,
  int label,
  int col,
  int num_chars);
extern int WINAPI FIfld_set_num_vis_rows(
  Form form,
  int label,
  int num_rows);
extern int WINAPI FIfld_set_type(
);
extern int WINAPI FIfld_set_value(
);

/* From fifm.c */
extern int WINAPI FIfm_read_font_table (
  char *font_tbl);
extern HFONT WINAPI FIfm_get_font(
  FI_form *form_ptr,
  FI_gadget *gadget_ptr);
extern int WINAPI FIfm_get_font_index (
  FI_gadget *gadget_ptr);
extern int WINAPI FIfm_load_font (
  FI_form *form_ptr,
  FI_gadget *gadget_ptr,
  int index,
  int from_table);
extern int WINAPI FIfm_unload_fonts (
);

/* From fig.c */
extern int WINAPI FIg_owner_draw_gadget(
  DRAWITEMSTRUCT *item_ptr);
extern int WINAPI FIg_owner_draw_checklist(
  DRAWITEMSTRUCT *item_ptr,
  Form form,
  FI_gadget *gadget_ptr);
extern int FIg_set_group_state(
  Form form,
  FI_gadget *gadget_ptr);
extern int WINAPI FIg_draw_checklist(
  HDC hdc,
  int x1,
  int y1,
  int width,
  int height,
  char *t1,
  char *t2,
  int state,
  int disabled);
extern int WINAPI FIg_owner_draw_toggle(
  DRAWITEMSTRUCT *item_ptr,
  Form form,
  FI_gadget *gadget_ptr);
extern int WINAPI FIg_draw_toggle(
  HDC hdc,
  int x1,
  int y1,
  int width,
  int height,
  char *t1,
  char *t2,
  int state,
  int disabled);
extern int WINAPI FIg_owner_draw_buttons(
  DRAWITEMSTRUCT *item_ptr,
  Form form,
  FI_gadget *gadget_ptr);
extern int WINAPI FIg_shade_button(
  HDC hdc,
  int x1,
  int y1,
  int width,
  int height,
  int state,
  int disabled);
extern int WINAPI FIg_draw_symbol(
  DRAWITEMSTRUCT *item_ptr,
  FI_form *form_ptr,
  FI_gadget *gadget_ptr);
extern int WINAPI FIg_activate(
  Form form,
  int label);
extern int WINAPI FIg_add_to_group(
  Form form,
  int label,
  int group_label);
extern int WINAPI FIg_disable(
  Form form,
  int label);
extern int WINAPI FIg_enable(
  Form form,
  int label);
extern int WINAPI FIg_get_attr(
  Form form,
  int label,
  int *attr_mask);
extern int WINAPI FIg_get_color(
  Form form,
  int label,
  int *color);
extern int WINAPI FIg_get_default_value(
  Form form,
  int label,
  double *value);
extern int WINAPI FIg_get_font(
  Form form,
  int label,
  char *fontname,
  float *bodysize);
extern int WINAPI FIg_get_group_label(
  Form form,
  int label,
  int *group_label);
extern int WINAPI FIg_get_help_topic(
  Form form,
  int label,
  char *topic);
extern int WINAPI FIg_get_help_topic_length(
  Form form,
  int label,
  int *length);
extern int WINAPI FIg_get_high_value(
  Form form,
  int label,
  double *value);
extern int WINAPI FIg_get_justification(
  Form form,
  int label,
  int *just);
extern int WINAPI FIg_get_line_depth(
  Form form,
  int label,
  int *depth);
extern int WINAPI FIg_get_line_style(
  Form form,
  int label,
  int *style);
extern int WINAPI FIg_get_line_weight(
  Form form,
  int label,
  int *weight);
extern int WINAPI FIg_get_location(
  Form form,
  int label,
  int *xpos,
  int *ypos);
extern int WINAPI FIg_get_low_value(
  Form form,
  int label,
  double *value);
extern int WINAPI FIg_get_off_color(
  Form form,
  int label,
  int *color);
extern int WINAPI FIg_get_off_symbol_index(
  Form form,
  int label,
  int *index);
extern int WINAPI FIg_get_off_text(
  Form form,
  int label,
  char *text);
extern int WINAPI FIg_get_off_text_length(
  Form form,
  int label,
  int *length);
extern int WINAPI FIg_get_on_color(
  Form form,
  int label,
  int *color);
extern int WINAPI FIg_get_on_symbol_index(
  Form form,
  int label,
  int *index);
extern int WINAPI FIg_get_on_text(
  Form form,
  int label,
  char *text);
extern int WINAPI FIg_get_on_text_length(
  Form form,
  int label,
  int *length);
extern int WINAPI FIg_get_orientation(
  Form form,
  int label,
  int *orient);
extern int WINAPI FIg_get_size(
  Form form,
  int label,
  int *xsize,
  int *ysize);
extern int WINAPI FIg_get_state(
  Form form,
  int label,
  int *state);
extern int WINAPI FIg_get_text(
  Form form,
  int label,
  char *text);
extern int WINAPI FIg_get_text_length(
  Form form,
  int label,
  int *length);
extern int WINAPI FIg_get_text_style(
  Form form,
  int label,
  int *style);
extern int WINAPI FIg_get_type(
  Form form,
  int label,
  int *gadget_type);
extern int WINAPI FIg_get_gadget_ptr(
  Form form,
  int label,
  struct FI_gadget **gadget);
extern FI_gadget *FIg_get_gadget(
  Form form,
  int label);
extern HANDLE WINAPI FIg_get_gadget_window(
  Form form,
  int label);
extern int WINAPI FIg_get_gadget_label(
  Form form,
  HWND window);
extern FI_gadget *FIg_get_gadget_from_window(
  Form form,
  int window);
extern int WINAPI FIg_hilite(
  Form form,
  int label);
extern int WINAPI FIg_new(
  Form form,
  int gadget_type,
  int label);
extern FI_gadget *FIg_alloc_gadget(
  int gadget_type,
  FI_form *form_ptr,
  int label,
  int new,
  int fld_mode);
extern int WINAPI FIg_set_attr(
  Form form,
  int label,
  int attr_mask);
extern int WINAPI FIg_set_default_value(
  Form form,
  int label,
  double value);
extern int WINAPI FIg_set_help_topic(
  Form form,
  int label,
  char *topic);
extern int WINAPI FIg_set_off_color(
  Form form,
  int label,
  int color);
extern int WINAPI FIg_set_off_text(
  Form form,
  int label,
  char *text);
extern int WINAPI FIg_set_symbol_index(
  Form form,
  int label,
  int index);
extern int WINAPI FIg_unhilite(
  Form form,
  int label);
extern int WINAPI FIg_reset(
  Form form,
  int label);
extern int WINAPI FIg_set_color(
  Form form,
  int label,
  int color);
extern int WINAPI FIg_set_font(
  Form form,
  int label,
  char *fontname,
  float bodysize);
extern int WINAPI FIg_set_justification(
  Form form,
  int label,
  int just);
extern int WINAPI FIg_set_line_depth(
  Form form,
  int label,
  int depth);
extern int WINAPI FIg_set_line_style(
  Form form,
  int label,
  int style);
extern int WINAPI FIg_set_line_weight(
  Form form,
  int label,
  int weight);
extern int WINAPI FIg_set_low_value(
  Form form,
  int label,
  double value);
extern int WINAPI FIg_set_high_value(
  Form form,
  int label,
  double value);
extern int WINAPI FIg_set_value(
  Form form,
  int label,
  double value);
extern int WINAPI FIg_get_value(
  Form form,
  int label,
  double *value);
extern int WINAPI FIg_set_on_color(
  Form form,
  int label,
  int color);
extern int WINAPI FIg_set_on_symbol_index(
  Form form,
  int label,
  int index);
extern int WINAPI FIg_set_on_text(
  Form form,
  int label,
  char *text);
extern int WINAPI FIg_set_standard_variables(
  Form form,
  int label,
  struct standard_st *stan_st);
extern int WINAPI FIg_set_state(
  Form form,
  int label,
  int state);
extern int WINAPI FIg_set_state_off(
  Form form,
  int label);
extern int WINAPI FIg_set_state_on(
  Form form,
  int label);
extern int WINAPI FIg_set_text(
  Form form,
  int label,
  char *text);
extern int WINAPI FIg_set_text_style(
  Form form,
  int label,
  int style);
extern int WINAPI FIg_lb_mode(
  FI_gadget *gadget_ptr);

/* From figm.c */
extern int WINAPI FIgm_draw_text(
  HDC hdc,
  FI_form *form_ptr,
  FI_gadget *gadget_ptr,
  int ix,
  int iy,
  char *text,
  int just,
  RECT *trc,
  int erase);
extern int WINAPI FIgm_rectangle(
  HDC hdc,
  int x1,
  int y1,
  int width,
  int height);
extern int WINAPI FIgm_line(
  HDC hdc,
  int x1,
  int y1,
  int x2,
  int y2);
extern PBITMAPINFO FIgm_bitmap_header (
  int width,
  int height,
  int depth,
  struct vlt_str *vlt,
  long num_entries);
extern FIgm_flip(
  unsigned char  *raster,
  int  len);
extern FIgm_create_flip_buf(
);
extern int WINAPI FIgm_build_vlt_slot(
  struct vlt_str *vlt,
  int slot,
  int color);

/* From figrp.c */
extern int WINAPI FIgrp_callback(
);
extern int WINAPI FIgrp_delete(
);
extern int WINAPI FIgrp_get_pass(
);
extern int WINAPI FIgrp_get_single_select(
  Form form,
  int group_label,
  int *state);
extern int WINAPI FIgrp_set_pass_off(
);
extern int WINAPI FIgrp_set_pass_on(
);
extern int WINAPI FIgrp_set_single_select_off(
  Form form,
  int group_label);
extern int WINAPI FIgrp_set_single_select_on(
  Form form,
  int group_label);

/* From filb.c */
extern int WINAPI FIlb_insert_item(
  HANDLE window,
  int index,
  char *icon,
  char *string,
  char *script);
extern int WINAPI FIlb_add_item(
  HANDLE window,
  char *icon,
  char *string,
  char *script);
extern int WINAPI FIlb_owner_draw_listbox(
  DRAWITEMSTRUCT *item_ptr);

/* From fimcf.c */
extern int WINAPI FImcf_delete_col(
  Form form,
  int label,
  int col);
extern int WINAPI FImcf_get_active_col(
  Form form,
  int label,
  int *col,
  int *pos);
extern int WINAPI FImcf_get_attr(
  Form form,
  int label,
  int *mask);
extern int WINAPI FImcf_get_num_cols(
  Form form,
  int label,
  int *cols);
extern int WINAPI FImcf_get_num_vis_cols(
  Form form,
  int label,
  int *cols);
extern int WINAPI FImcf_get_select(
  Form form,
  int label,
  int row,
  int *sel_flag);
extern int WINAPI FImcf_set_select(
  Form form,
  int label,
  int row,
  int sel_flag);
extern int WINAPI FImcf_get_view_data(
  Form form,
  int label,
  int *offset,
  int *vis_cols);
extern int WINAPI FImcf_set_active_col(
  Form form,
  int label,
  int col,
  int pos);
extern int WINAPI FImcf_set_attr(
  Form form,
  int label,
  int attr_mask);
extern int WINAPI FImcf_set_num_cols(
  Form form,
  int label,
  int num_cols);
extern int WINAPI FImcf_set_num_vis_cols(
  Form form,
  int label,
  int num_cols);
extern int WINAPI FImcf_set_scroll_link(
  Form form,
  int master,
  int header);
extern int WINAPI FImcf_set_low_value(
  Form form,
  int label,
  int col,
  double value);
extern int WINAPI FImcf_set_high_value(
  Form form,
  int label,
  int col,
  double value);
extern int WINAPI FImcf_set_justification(
  Form form,
  int label,
  int col,
  int justify);

/* From firect.c */
extern int WINAPI FIrect_get_style(
);
extern int WINAPI FIrect_set_style(
);

/* From fiscrl.c */
extern int WINAPI FIscrl_get_view(
);
extern int WINAPI FIscrl_set_view(
);

/* From fistyle.c */
extern int WINAPI FI_win_types (
  FI_gadget *t_gadget,
  int *type_ptr);
extern int WINAPI FI_win_props (
  FI_gadget *t_gadget,
  FI_gadget *gadget_ptr,
  DWORD *style_ptr,
  int *type_ptr);
extern int WINAPI FImcf_win_scroll_style (
  FI_gadget *t_gadget,
  DWORD *style);

/* From fisym.c */
extern int WINAPI FIsym_read_file(
  char *filename,
  int number,
  int *width,
  int *height,
  char **sym_bitmap);

/* From fiwp.c */
extern LONG FAR PASCAL FIWndProc(
  HWND hWnd,
  UINT Message,
  WPARAM wParam,
  LONG lParam);
extern int FImcf_to_pos(
  FI_gadget *gadget_ptr,
  HANDLE hscroll,
  int pos);
extern int FImcf_pageup(
  FI_gadget *gadget_ptr,
  HANDLE hscroll);
extern int FImcf_pagedown(
  FI_gadget *gadget_ptr,
  HANDLE hscroll);
extern int FImcf_linedown(
  FI_gadget *gadget_ptr,
  HANDLE hscroll);
extern int FImcf_lineup(
  FI_gadget *gadget_ptr,
  HANDLE hscroll);

/* From fld_calc.c */
extern int FIfld_calc_size (
  FI_form *form_ptr,
  FI_gadget *gadget_ptr,
  char *fontname,
  HFONT hfnt,
  int *iwidth,
  int *iheight,
  int *ix,
  int *iy);
extern int FIfld_calc_space (
  int  height,
  int  *space);

/* From fld_recr.c */
extern int WINAPI FIfld_recreate_gadget (
  FI_form *form_ptr,
  FI_gadget *t_gadget,
  int label);

/* From g_cl_not.c */
extern int WINAPI FIg_call_notification_routine (
  Form form,
  int label);

/* From g_delete.c */
extern int WINAPI FIg_delete (
  Form form,
  int label);

/* From g_free.c */
extern int WINAPI FIg_free (
  FI_gadget **gadg);

/* From g_next.c */
extern int WINAPI FIg_set_next_in_seq (
  Form form,
  int label,
  int next_label);
extern int WINAPI FIg_get_next_in_seq (
  Form form,
  int label,
  int *next_label);

/* From g_setloc.c */
extern int WINAPI FIg_set_location (
  Form form,
  int label,
  int xorg,
  int yorg);

/* From g_setsiz.c */
extern int WINAPI FIg_set_size(
  Form form,
  int label,
  int xsize,
  int ysize);

/* From g_st_seq.c */
extern int WINAPI FIg_start_seq (
  Form form,
  int label);

/* From row_text.c */
extern int WINAPI FIfld_sync_row (
  FI_gadget *t_gadget,
  HANDLE window,
  int line);
extern int WINAPI FI_sync_edit_firows (
  FI_gadget *t_gadget,
  FI_gadget *gadget_ptr);
extern int WINAPI FI_sync_firows (
  FI_form *form_ptr,
  FI_gadget *t_gadget);

/* From slider.c */
extern int WINAPI FIg_set_increment(
  Form form,
  int label,
  float increment);
extern int WINAPI FIg_set_value_format(
  Form form,
  int label,
  int width,
  int decimal);
extern int WINAPI FIg_set_display(
  Form form,
  int label,
  int mask);
extern int WINAPI FIg_set_orientation(
  Form form,
  int label,
  int orient);
extern int FIg_owner_draw_slider(
  DRAWITEMSTRUCT *item_ptr,
  Form form,
  FI_gadget *gadget_ptr);
extern int FIg_draw_slider(
  HDC hdc,
  int x1,
  int y1,
  int width,
  int height,
  struct FI_gadget *gadget_ptr);

#endif
