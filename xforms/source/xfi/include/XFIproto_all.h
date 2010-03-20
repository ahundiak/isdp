
/* 16stuff.c */
extern int _FI_locate_16bit_start_byte(int cpos, char *s);

/* SS.c */
extern int _FI_16DrawText(int window, FontId font, FontId fontAUX, unsigned char *text, int length, Real64 x, Real64 y, Real64 *nx, Real64 *ny, int mode, int mode2, int screen);

/* Xevent.c */
extern int FIdecode(int start, int count);
extern int FI_get_transition(XEvent *event, unsigned int *trans);
extern int FI_forms_active(void);
extern int FI_process_forms(void);
extern Bool _FI_flush_expose(Display *display, XEvent *event, Window *wind);
extern Bool _FI_flush_configure(Display *display, XEvent *event, Window *wind);
extern int FI_process_event(XEvent *event, unsigned int trans);

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
extern int FIf_set_cmd_oid_os(Form form, unsigned int cmd_oid, unsigned int cmd_os);
extern int FIf_set_cmd_oid_os_ANSI(Form form, unsigned int cmd_oid, unsigned short cmd_os);
extern int FIf_get_cmd_oid_os(Form form, unsigned int *cmd_oid, unsigned short *cmd_os);
extern int FIg_get_help_topic(Form form, int label, char *help_topic);
extern int FIg_get_command(Form form, int label, char *command);
extern int FIg_set_help_topic(Form form, int label, char *help_topic);
extern int FIg_set_command(Form form, int label, char *command);
extern int FIg_get_help_topic_length(Form form, int label, int *help_topic_length);
extern int FIg_get_command_length(Form form, int label, int *command_length);

/* common.c */
extern int FIf_set_rel_location(Form form, int xpos, int ypos, Form rel_form);

/* copy.c */
extern void _FI_g_copy(struct FIgadget_obj *old_gadget, struct FIgadget_obj *new_gadget);
extern void _FI_fld_copy(struct FIfld_obj *old_field, struct FIfld_obj *new_field);
extern int FIg_copy(Form form, int old_label, int *new_label, int generate_new_label_flag);

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
extern void FI_use_normal_bezel(void);
extern void FI_use_thin_bezel(void);
extern void _FI_draw_bezel(Window window, int xlo, int ylo, int xhi, int yhi, int bezel_size, unsigned long t_l_color, unsigned long face_color, unsigned long b_r_color, unsigned long edge_color, int type);

/* dump.c */
extern int FI_write_int(FILE *file, int value);
extern int FI_write_float_ANSI(FILE *file, float value);
extern int FI_write_float(FILE *file, double value);
extern int FI_write_short_ANSI(FILE *file, short value);
extern int FI_write_short(FILE *file, int value);
extern int FI_write_double(FILE *file, double value);
extern void _FI_dump_char(char value);
extern void _FI_dump_int(int value);
extern void _FI_dump_short(short value);
extern void _FI_dump_double(double value);
extern void _FI_dump_string(char *string);
extern void _FI_dump_enter(FILE *fp, jmp_buf env);

/* efpi.c */
extern int _FI_get_active_screen(int *xscreen);
extern int FIf_is_displayed(Form form, int *status);
extern int FIf_set_window_event_routine(Form form, int (*routine )());
extern int FIf_get_window_event_routine(Form form, int (**routine )());
extern int FIf_set_button_intercept_routine(Form form, int (*routine )());
extern int FIf_get_button_intercept_routine(Form form, int (**routine )());
extern int FIf_set_window_icon_routine(Form form, int (*routine )());
extern int FIf_set_initial_notification_routine(Form form, int (*routine )());
extern int FIf_get_initial_notification_routine(Form form, int (**routine )());
extern int FIf_set_button_event_routine(Form form, int (*routine )());
extern int FIf_get_button_event_routine(Form form, int (**routine )());
extern int FIf_set_notification_routine(Form form, int (*routine )());
extern int FIf_get_notification_routine(Form form, int (**routine )());
extern int FIf_get_window(Form form, Window *window);
extern int FIf_set_resize_off(Form form_ptr);
extern int FIf_set_resize_on(Form form_ptr);
extern int FIf_is_collapsed(Form form_ptr, int *status);
extern int FIf_collapse(Form form_ptr);
extern int FIf_uncollapse(Form form_ptr);
extern int FIf_set_orig_location(Form form_ptr, int xlo, int ylo);
extern int FIf_get_orig_location(Form form_ptr, int *xlo, int *ylo);
extern int FIf_set_orig_size(Form form_ptr, int xsize, int ysize);
extern int FIf_get_orig_size(Form form_ptr, int *xsize, int *ysize);
extern int FIf_set_seq_on(Form form);
extern int FIf_set_seq_off(Form form);
extern int FIf_get_seq(Form form, int *seq_flag);
extern int FIf_find_gadget(Form form_ptr, int group_label, int xpos, int ypos, int *label);
extern int FIf_get_attr(Form form, long *form_mask);
extern int FIf_set_attr(Form form_ptr, int form_mask);
extern int FIf_reset(Form form);
extern int FIf_get_user_pointer(Form form, char **user_pointer);
extern int FIf_set_user_pointer(Form form, char *user_pointer);
extern int FIf_get_location(Form form_ptr, int *xpos, int *ypos);
extern int FIf_set_collapse_location(Form form_ptr, int xpos, int ypos);
extern int FIf_get_collapse_location(Form form_ptr, int *xpos, int *ypos);
extern int FIf_set_collapse_symbol(Form form_ptr, char *fontfile, int symindex);
extern int FIf_get_collapse_symbol(Form form_ptr, char fontfile[], int *symindex);
extern int FIf_set_min_size(Form form_ptr, int xsize, int ysize);
extern int FIf_get_min_size(Form form_ptr, int *min_xsize, int *min_ysize);
extern int FIf_set_max_size(Form form_ptr, int xsize, int ysize);
extern int FIf_get_max_size(Form form_ptr, int *max_xsize, int *max_ysize);
extern int FIf_set_start_seq(Form form_ptr, int gadget_label);
extern int FIf_get_start_seq(Form form_ptr, int *gadget_label);
extern int FIf_get_next_label(Form form_ptr, int *next_label);
extern int FIf_get_size(Form form_ptr, int *xsize, int *ysize);
extern int FIf_get_screen(Form form, int *screen);
extern int FIf_get_name(Form form, char name[]);
extern int FIf_get_label(Form form, int *form_label);
extern int FIf_set_label(Form form, int form_label);
extern int FIf_set_scaling_on(Form form);
extern int FIf_set_scaling_off(Form form);
extern int FIf_get_scaling(Form form, int *scaling_flag);
extern int FIf_set_window_level(Form form_ptr, int level);
extern int FIf_set_screen(Form form_ptr, int screen);
extern int FIf_set_Xscreen(Form form, int logical_screen, int absolute_screen);
extern int FIf_get_Xscreen(Form form, int *logical_screen, int *absolute_screen);
extern int FIf_get_color(Form form, int *color);
extern int FIf_set_color(Form form, int color);

/* egpi.c */
extern int _FI_g_set_stan_vars(struct FIgadget_obj *gadget, struct standard_st *str);
extern int FIg_set_standard_variables(Form form, int label, struct standard_st *str);
extern int FIg_get_line_depth(Form form, int label, int *depth);
extern int FIg_set_line_depth(Form form, int label, int depth);
extern int FIg_activate(Form form, int label);
extern int FIg_set_state(Form form, int label, int state);
extern int FIg_get_size(Form form, int label, int *xsize, int *ysize);
extern int FIg_get_dsize(Form form, int label, double *xsize, double *ysize);
extern int FIg_set_size(Form form, int label, int xsize, int ysize);
extern int FIg_get_dlocation(Form form, int label, double *xpos, double *ypos);
extern int FIg_get_location(Form form, int label, int *xpos, int *ypos);
extern int FIg_get_off_color(Form form, int label, int *off_color);
extern int FIg_get_on_color(Form form, int label, int *on_color);
extern int FIg_set_on_color(Form form, int label, int on_color);
extern int FIg_set_off_color(Form form, int label, int off_color);
extern int FIg_set_color(Form form, int label, int color);
extern int FIg_get_color(Form form, int label, int *color);
extern int FIg_get_type(Form form, int label, int *type);
extern int FIg_is_displayed(Form form, int label, int *displayed);
extern int FIg_get_high_value(Form form, int label, double *high_value);
extern int FIg_get_low_value(Form form, int label, double *low_value);
extern int FIg_set_high_value(Form form, int label, double high_value);
extern int FIg_set_low_value(Form form, int label, double low_value);
extern int FIg_get_attr(Form form, int label, int *attr_mask);
extern int FIg_set_attr(Form form, int label, int attr_mask);
extern int FIg_get_user_pointer(Form form, int label, char **user_pointer);
extern int FIg_set_user_pointer(Form form, int label, char *user_pointer);
extern int FIg_set_off_symbol_index(Form form, int label, int sym_index);
extern int FIg_set_symbol_index(Form form, int label, int sym_index);
extern int FIg_set_on_symbol_index(Form form, int label, int sym_index);
extern int FIg_get_off_symbol_index(Form form, int label, int *sym_index);
extern int FIg_get_symbol_index(Form form, int label, int *sym_index);
extern int FIg_get_on_symbol_index(Form form, int label, int *sym_index);
extern int FIg_set_justification(Form form, int label, int just);
extern int FIg_set_on_text(Form form, int label, char *text);
extern int FIg_get_on_text(Form form, int label, char *text);
extern int FIg_get_on_text_length(Form form, int label, int *length);
extern int FIg_delete(Form form, int label);
extern int FIg_new(Form form, int gadget_type, int label);

/* egpi2.c */
extern int FIg_call_notification_routine(Form form, int label);
extern int FIdial_set_range(Form form, int label, double range);
extern int FIdial_get_range(Form form, int label, float *range);
extern int FIdial_set_zero_location(Form form, int label, double zero);
extern int FIdial_get_zero_location(Form form, int label, float *zero);
extern int FIrect_set_style(Form form, int label, int style);
extern int FIrect_get_style(Form form, int label, int *style);
extern int FIdial_set_border_style(Form form, int label, int border_style);
extern int FIdial_get_border_style(Form form, int label, int *border_style);
extern int FIg_add_to_group(Form form, int gadget_label, int group_label);
extern int FIg_set_erase_color(Form form, int label, int color);
extern int FIg_get_erase_color(Form form, int label, int *erase_color);
extern int FIg_set_orientation(Form form, int label, int orientation);
extern int FIg_get_orientation(Form form, int label, int *orientation);
extern int FIg_set_minor_increments(Form form, int label, int incrs);
extern int FIg_get_minor_increments(Form form, int label, int *incrs);
extern int FIg_set_increment(Form form, int label, double increment);
extern int FIg_get_increment(Form form, int label, float *increment);
extern int FIg_get_notify(Form form, int label, int *notify_flag);
extern int FIg_set_notify_on(Form form, int label);
extern int FIg_set_notify_off(Form form, int label);
extern int FIg_set_display(Form form, int label, int display_mask);
extern int FIg_get_display(Form form, int label, int *display_mask);
extern int FIg_set_continuous_routine(Form form, int label, int (*cont_routine )());
extern int FIg_get_continuous_routine(Form form, int label, int (**cont_routine )());
extern int FIg_get_default_value(Form form, int label, double *default_value);
extern int FIg_set_default_value(Form form, int label, double default_value);
extern int FIg_get_font_ANSI(Form form, int label, char *fontname, double *bodysize);
extern int FIg_get_font(Form form, int label, char *fontname, float *bodysize);
extern int FIg_set_symbol_file(Form form, int label, char *symbol_file);
extern int FIg_get_symbol_file(Form form, int label, char *symbol_file);
extern int FIg_set_font(Form form, int label, char *fontname, double bodysize);
extern int FIg_set_line_weight(Form form, int label, int wt);
extern int FIg_get_line_weight(Form form, int label, int *wt);
extern int FIg_set_line_style(Form form, int label, int style);
extern int FIg_get_line_style(Form form, int label, int *style);
extern int FIg_set_text_style(Form form, int label, int style);
extern int FIg_get_text_style(Form form, int label, int *style);
extern int FIg_set_next_in_seq(Form form, int label, int next_label);
extern int FIg_get_next_in_seq(Form form, int label, int *next_label);
extern int FIg_set_pass_data(Form form, int label, int next_label);
extern int FIg_get_pass_data(Form form, int label, int *next_label);
extern int FIg_set_value_format(Form form, int label, int field_width, int decimal_accuracy);
extern int FIg_get_value_format(Form form, int label, int *field_width, int *decimal_accuracy);
extern int FIbtn_set_auto_pop_up_on(Form form, int label);
extern int FIbtn_set_auto_pop_up_off(Form form, int label);
extern int FIbtn_get_auto_pop_up_state(Form form, int label, int *state);
extern int FIg_get_group_label(Form form, int label, int *group_label);
extern int FIg_reset(Form form, int label);
extern int FIscrl_get_view(Form form, int label, double *view);
extern int FIscrl_set_view(Form form, int label, double view);
extern int FIg_in_group(Form form, int gadget_label, int group_label, int *in_group);
extern int FIg_get_justification(Form form, int label, int *just);
extern int FI_get_last_notification_type(int *notify_type);

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
extern int FI_define_widest_wchar(short ch);
extern int FI_define_widest_char(char ch);
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
extern int FIfld_get_notify_info(int *event, int *event_value, Form *form, int *gad_label);

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
extern int FIf_find_by_point(Form form_ptr, int group_label, int xpos, int ypos, int max_dist, int *label, int reset_search_flag);
extern int FIf_find_by_area(Form form_ptr, int group_label, int x1, int y1, int x2, int y2, int *num_labels, int **labels);
extern int _FI_grp_find_by_area(struct FIform_obj *form, int group_label, int x1, int y1, int x2, int y2, int *labels_size, int *num_labels, int **labels);
extern int _FI_is_pt_next_to_line_seg(int max_dist, int wt, int x1, int y1, int x2, int y2, int x, int y);
extern void _FI_get_line_ABC(int x1, int y1, int x2, int y2, double *A, double *B, double *C);
extern int _FI_get_dist_pt_line(int x1, int y1, int x2, int y2, int x, int y);

/* fldpi.c */
extern int _FI_fld_get_field(struct FIform_obj *form, int label, int col, struct FIfld_obj **field);
extern int FIfld_get_select(Form form, int label, int row, int col, int *sel_flg);
extern int FIfld_get_text_length(Form form, int label, int row, int col, int *length);
extern int FIfld_get_text(Form form, int label, int row, int col, int num_ch, unsigned char text[], int *sel_flg, int *r_pos);
extern int FIfld_set_text(Form form, int label, int row, int col, char *apptext, int sel_flg);
extern int FIfld_get_value(Form form, int label, int row, int col, double *value, int *sel_flg, int *r_pos);
extern int FIfld_set_value(Form form, int label, int row, int col, double value, int sel_flg);
extern int FIfld_find_row_and_column(Form form, int gadget, int x, int y, int *row, int *column);

/* fldpi2.c */
extern int FIfld_get_format_string_length(Form form, int label, int col, int *format_str_length);
extern int FIfld_get_format_string(Form form, int label, int col, unsigned char *text);
extern int FIfld_set_format_string(Form form, int label, int col, char *format_string);
extern int FIfld_set_list_scroll(Form form, int label, int vert_flag, int horz_flag);
extern int FIfld_get_list_scroll(Form form, int label, int *vert_flag, int *horz_flag);
extern int FIfld_get_default_text_length(Form form, int label, int row, int col, int *length);
extern int FIfld_get_default_text(Form form, int label, int row, int col, int num_ch, unsigned char *text, int *sel_flg);
extern int FIfld_set_default_text(Form form, int label, int row, int col, char *text, int sel_flg);
extern int FIfld_pos_cursor(Form form, int label, int row, int r_pos, int col, int col_pos, int ch, int ch_pos);
extern int FIfld_erase_cursor(Form form, int label);
extern int FIfld_get_active_char(Form form, int label, int col, int *ch, int *pos);
extern int FIfld_set_active_char(Form form, int label, int col, int ch, int pos);
extern int FIfld_set_select(Form form, int label, int row, int col, int sel_flg);
extern int FIfld_set_verify_routine(Form form, int label, int col, int (*func )());
extern int FIfld_get_verify_routine(Form form, int label, int col, int (**func )());
extern int FIfld_set_format_routine(Form form, int label, int col, int (*func )());
extern int FIfld_get_format_routine(Form form, int label, int col, int (**func )());
extern int FIfld_get_attr(Form form, int label, int col, long *attr_mask);
extern int FIfld_set_attr(Form form, int label, int col, long attr_mask);
extern int FIfld_get_max_num_chars(Form form, int label, int col, int *num_chars);
extern int FIfld_set_max_num_chars(Form form, int label, int col, int num_chars);
extern int FIfld_get_mode(Form form, int label, int col, int *mode);
extern int FIfld_set_mode(Form form, int label, int col, int mode);
extern int FIfld_get_num_vis_chars(Form form, int label, int col, int *num_chars);
extern int FIfld_set_num_vis_chars(Form form, int label, int col, int num_chars);
extern int FIfld_get_type(Form form, int label, int col, int *type);
extern int FIfld_set_type(Form form, int label, int col, int type);
extern int FIfld_set_line_color(Form form, int label, int row, int col, int color);
extern int FIfld_get_line_color(Form form, int label, int row, int col, int *color);

/* fldpiRow.c */
extern int FIfld_get_active_row(Form form, int label, int *row, int *pos);
extern int FIfld_get_row_offset(Form form, int label, int *row_offset);
extern int FIfld_get_row_height(Form form, int label, int *row_height);
extern int _FI_fld_delete_rows(struct FIfld_obj *field, int start_row, int num_rows, int *roff_adjusted);
extern int FIfld_delete_rows(Form form, int label, int start_row, int num_rows);
extern int _FI_fld_insert_blank_row(struct FIfld_obj *field, int row);
extern int FIfld_insert_blank_row(Form form, int label, int row);
extern int FIfld_set_active_row(Form form, int label, int row, int pos);
extern int FIfld_get_num_rows(Form form, int label, int *num_rows);
extern int FIfld_set_num_rows(Form form, int label, int num_rows);
extern int FIfld_get_max_num_rows(Form form, int label, int *num_rows);
extern int FIfld_set_max_num_rows(Form form, int label, int num_rows);
extern int FIfld_get_num_vis_rows(Form form, int label, int *num_rows);
extern int FIfld_set_num_vis_rows(Form form, int label, int num_rows);

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
extern int FIf_display(Form form_ptr);
extern int FIf_erase(Form form_ptr);
extern int _FI_default_function(void);
extern int _FI_default_process_data_function(int data_type, char *data_string, Form form);
extern int _FI_default_set_window_attr_function(Window window_number);
extern int _FI_default_activate_help_function(Form form);
extern int FIf_process_point(Form form_ptr, int xpos, int ypos, int button, unsigned int state, Time ttag);
extern int FIf_paint_area(Form form_ptr, int xlo, int ylo, int xhi, int yhi);
extern int FI_get_last_paint_area(int *xlo, int *ylo, int *xhi, int *yhi);
extern Bool _FI_flush_destroy(Display *display, XEvent *event, Window *wind);
extern int FIf_cvrt_to_perm_win(Form form_ptr);
extern int FIf_set_location(Form form_ptr, int xpos, int ypos);
extern int _FI_f_new(int label, char *form_name, int (*notification_routine )(), struct FIform_obj **form);
extern int FIf_new(int label, char *form_name, int (*notification_routine )(), Form *form);
extern int FIf_set_size(Form form_ptr, int xsize, int ysize);
extern int _FI_f_delete(struct FIform_obj *form);
extern int FIf_delete(Form form);
extern int FIf_is_valid(Form form_ptr);
extern int FIg_is_valid(Form form_ptr, int gadget_label);
extern int FIf_get_GC(Form form_ptr, GC *form_GC);
extern int FI_set_auto_scaling_factors(double scale_factor_x, double scale_factor_y);
extern int FI_get_auto_scaling_factors(double *scale_factor_x, double *scale_factor_y);
extern int FI_get_form_menu_type(Form form_menu, int *form_menu_type);
extern int FI_get_num_forms_menus(int *num_forms_menus);
extern int FI_get_forms_menus(Form forms_menus_array[], int *num_forms_menus);
extern Form FI_get_save_restore_form(void);
extern int FI_set_SR_lockout(void);
extern Form FI_get_form_by_window(Window window);

/* fs.c */
extern int FI_load_FSfont(char *fontname, int bodysize, int *actual_bodysize, int *font_id);

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
extern void _FI_draw_bezel(Window window, int xlo, int ylo, int xhi, int yhi, int bezel_size, unsigned long t_l_color, unsigned long face_color, unsigned long b_r_color, unsigned long edge_color, int type);
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
extern int FIg_adjust_size(Form form, int label, double delta_x, double delta_y);
extern int FIg_enable(Form form, int label);
extern int FIg_display(Form form, int label);
extern int FIg_erase(Form form, int label);
extern int FIg_hilite(Form form, int label);
extern int FIg_unhilite(Form form, int label);
extern int FIg_disable(Form form, int label);
extern int FIg_get_value(Form form, int label, double *value);
extern int FIg_set_value(Form form, int label, double value);
extern int FIg_get_state(Form form, int label, int *state);
extern int FIg_set_state_on(Form form, int label);
extern int FIg_set_state_off(Form form, int label);
extern int FIg_get_off_text(Form form, int label, char *text);
extern int FIg_set_text(Form form, int label, char *text);
extern int FIg_get_off_text_length(Form form, int label, int *length);
extern int FIg_get_text(Form form, int label, char *text);
extern int FIg_get_text_length(Form form, int label, int *length);
extern int FIg_set_location(Form form, int label, int xpos, int ypos);
extern int FIg_start_seq(Form form, int label);
extern int FIg_set_off_text(Form form, int label, char *string);

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
extern int FIgrp_get_single_select(Form form, int group_label, int *status);
extern int FIgrp_set_single_select_on(Form form, int group_label);
extern int FIgrp_set_single_select_off(Form form, int group_label);
extern int FIgrp_add_to_group(Form form, int group_gadget_label, int to_group_label);
extern int FIgrp_get_pass(Form form, int group_label, int *pass_status);
extern int FIgrp_set_pass_on(Form form, int group_label);
extern int FIgrp_set_pass_off(Form form, int group_label);
extern int FIgrp_delete(Form form, int group_label);
extern int FIgrp_callback(Form form, int group_label, int (*callback_routine )(), int user_arg);

/* hm.c */
extern int FIh_attach_to_parent(Form form, Form parent_form);
extern int FIh_detach_from_parent(Form form);
extern int _FIh_add_child_form(struct FIform_obj *parent_form, struct FIform_obj *child_form);
extern int _FIh_remove_child_form(struct FIform_obj *parent_form, struct FIform_obj *child_form);
extern int FIh_callback(Form form, int mode, int top_flag, int (*routine )(), int user_arg);
extern int FIh_set_reply_routine(Form form, int (*reply_routine )());
extern int FIh_get_reply_routine(Form form, int (**reply_routine )());
extern int FIh_reply_to_parent(Form form, int user_arg);

/* icon.c */
extern int _MI_window_routine(int menu_label, int event, struct FIform_obj *menu);
extern int _MI_process_icon(int menu_label, int icon_id, struct FIform_obj *menu);

/* iforms_stub.c */
extern int FIf_set_revert_size_icon_on(Form form);
extern int FIf_set_revert_size_icon_off(Form form);
extern int FIf_set_SR_vlt(Form form, char *SR_vlt, int num_SR_vlt_slots);
extern int FIf_get_SR_vlt_num_slots(Form form, int *num_SR_vlt_slots);
extern int FIf_get_SR_vlt(Form form, char *SR_vlt, int num_SR_vlt_slots);

/* import.c */

/* line.c */
extern void _FI_graphic_activate(struct FIgraphic_instance *graph);
extern void _FI_line_draw_line(struct FIline_obj *line, int Xscreen, Window window, int off_color, int shadow_color, int glint_color);
extern int _FI_line_display(struct FIline_obj *line, Window window);
extern int _FI_line_erase(struct FIline_obj *line, Window window);

/* listpi.c */
extern int FIfld_get_list_num_rows(Form form, int label, int col, int *num_rows);
extern int FIfld_set_list_num_rows(Form form, int label, int col, int num_rows);
extern int FIfld_get_list_text_length(Form form, int label, int row, int col, int *length);
extern int FIfld_get_list_text(Form form, int label, int row, int col, int num_ch, unsigned char *text, int *sel_flg);
extern int FIfld_get_list_default_text_length(Form form, int label, int row, int col, int *length);
extern int FIfld_get_list_default_text(Form form, int label, int row, int col, int num_ch, unsigned char *text, int *sel_flg);
extern int FIfld_get_list_select(Form form, int label, int row, int col, int *sel_flg);
extern int FIfld_set_list_select(Form form, int label, int row, int col, int sel_flg);
extern int FIfld_set_list_text(Form form, int label, int row, int col, unsigned char *text, int sel_flg);
extern int FIfld_set_list_default_text(Form form, int label, int row, int col, char *text, int sel_flg);

/* listpi2.c */
extern int FIfld_get_list_mode(Form form, int label, int col, int *mode);
extern int FIfld_set_list_mode(Form form, int label, int col, int mode);
extern int FIfld_get_list_location(Form form, int label, int col, int *xpos, int *ypos);
extern int FIfld_set_list_location(Form form, int label, int col, int xpos, int ypos);
extern int FIfld_get_list_size(Form form, int label, int col, int *xsize, int *ysize);
extern int FIfld_set_list_size(Form form, int label, int col, int xsize, int ysize);

/* load.c */
extern int FI_read_int(FILE *file, int *value);
extern int FI_read_float(FILE *file, float *value);
extern int FI_read_short(FILE *file, short *value);
extern int FI_read_double(FILE *file, double *value);
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
extern int FIf_look(Form form, int group_label, char *string);

/* mcf.c */
extern void _FI_mcf_set_color(struct FImcf_obj *mcf, int color, int on_color_flag);
extern void _FI_mcf_set_erase_color(struct FImcf_obj *mcf, int erase_color);
extern int FImcf_get_active_col(Form form, int label, int *col, int *pos);
extern int FImcf_set_active_col(Form form, int label, int col, int pos);
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
extern int FImcf_set_scroll_link(Form form, int master_mcf, int header_mcf);
extern int FImcf_get_scroll_link(Form form, int master_mcf, int *header_mcf);
extern int FImcf_insert_col(Form form, int label, int col, int chars, int mode, int Type);
extern int FImcf_delete_col(Form form, int label, int col);
extern int FImcf_get_view_data(Form form, int label, int *col_offset, int *num_vis_cols);
extern int FImcf_set_low_value(Form form, int label, int col, double value);
extern int FImcf_set_high_value(Form form, int label, int col, double value);
extern int FImcf_get_low_value(Form form, int label, int col, double *value);
extern int FImcf_get_high_value(Form form, int label, int col, double *value);
extern int FImcf_get_justification(Form form, int label, int col, int *just);
extern int FImcf_set_justification(Form form, int label, int col, int just);
extern int FImcf_get_attr(Form form, int label, long *attr_mask);
extern int FImcf_set_attr(Form form, int label, long attr_mask);
extern int FImcf_get_num_cols(Form form, int label, int *num_col);
extern int FImcf_set_num_cols(Form form, int label, int num_col);
extern int FImcf_get_num_vis_cols(Form form, int label, int *num_col);
extern int FImcf_set_num_vis_cols(Form form, int label, int num_col);
extern int FImcf_get_col_size(Form form, int label, int col, int *xsize, int *ysize);
extern int FImcf_set_col_size(Form form, int label, int col, int xsize, int ysize);
extern int FImcf_get_select(Form form, int label, int row, int *sel_flg);
extern int FImcf_set_select(Form form, int label, int row, int sel_flg);

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
extern int MS_pop_up_last_button(void);
extern void FIf_set_wm_offsets(int xoffset, int yoffset);
extern int FIf_get_wm_offsets(int *xoffset, int *yoffset);
extern int FIf_overlay(Form form_a, Form form_b);
extern int MS_swap_menu(int menu_type, char *menu_name);
extern int MS_save_locations(char *file);
extern int MS_set_startup_file(char *file);
extern int MS_get_startup_file(char file[]);
extern int MS_init_menus(void);
extern int MS_display_menus(void);
extern int MS_erase_menus(void);
extern int MS_delete_menus(void);
extern int MS_process_pocket(int Xscreen, int xpos, int ypos);
extern int MS_enter(void);

/* mepi.c */
extern int FIbtn_get_palette(Form form, int label, char pal_name[]);
extern int FIbtn_set_palette(Form form, int label, char *pal_name);
extern int FIbtn_set_menu_status(Form form, int label, int status);
extern int FIbtn_get_menu_status(Form form, int label, int *status);
extern int FIg_get_off_color2(Form form, int label, int *off_color2);
extern int FIg_get_on_color2(Form form, int label, int *on_color2);
extern int FIg_set_off_color2(Form form, int label, int off_color2);
extern int FIg_set_on_color2(Form form, int label, int on_color2);

/* message.c */
extern int _FI_confirm_box(int screen, int xpos, int ypos, char *title, int title_color, char *title_font, double title_bodysize, char *message, int message_color, char *message_font, double message_bodysize, int display_mode, int presentation_mode, int line_length);
extern int FI_msg_box(char *title, int title_color, char *message, int message_color);
extern int FI_msg_box2(char *title, int title_color, char *message, int message_color);
extern int FI_message_box(int screen, int xpos, int ypos, char *title, int title_color, char *title_font, double title_bodysize, char *message, int message_color, char *message_font, double message_bodysize, int display_mode, int line_length);
extern int FI_message_box2(int screen, int xpos, int ypos, char *title, int title_color, char *title_font, double title_bodysize, char *message, int message_color, char *message_font, double message_bodysize, int display_mode, int line_length);

/* miset.c */
extern int MI_set_tear_off_notification_routine(int (*tear_off_routine )());
extern int MI_get_tear_off_notification_routine(int (**tear_off_routine )());
extern int MI_set_menu_move_routine(int (*menu_move_routine )());
extern int MI_get_menu_move_routine(int (**menu_move_routine )());
extern int MI_set_window_routine(int (*window_routine )());
extern int MI_get_window_routine(int (**window_routine )());
extern int MI_enter(void);

/* modify.c */
extern int FI_modify_env(int function, int (*func_ptr )());
extern int FI_get_env(int function, int (**func_ptr )());
extern int FI_set_graphic_env(int function, int (*func_ptr )());
extern int FI_get_graphic_env(int function, int (**func_ptr )());

/* mpi.c */
extern int _MI_btn_set_user_pointer(struct FIgadget_obj *gadget, struct pal_info_st *pal_info);
extern int _MI_btn_set_menu_button(struct FIgadget_obj *gadget);
extern int MIm_new(int menu_type, int menu_label, char *menu_name, int (*notification_routine )(), Form *menu);
extern int MIm_display(Form menu);
extern int MI_pop_up_button(Menu menu, int gadget_label);
extern int MI_get_palette_vert_offset(int *offset);
extern int MI_set_palette_vert_offset(int offset);
extern void MI_set_tear_off_menu_modify_routine(void (*p_function )());
/* palette.c */
extern void MI_set_menu_button_creation_routine(int (*p_function )());
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
extern int FIf_save(Form form, char *path);

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
extern int FI_set_select_button(int button);
extern int FI_get_select_button(int *button);
extern void _FI_parse_unix_path(char *path, char ***dirs, int *num_dirs);
extern int FI_set_quiet_mode_on(void);
extern int FI_set_quiet_mode_off(void);
extern int FI_get_quiet_mode(int *quiet_mode);
extern int FI_set_record_notification_routine(int (*routine )());
extern int FI_get_record_notification_routine(int (**routine )());
extern int FI_set_form_path(char *form_path);
extern int _FI_is_in_list(char **list, int num_list, char *string);
extern char *FI_get_ingr_root(char *ingr_root);
extern int _FI_set_generic_path(char *path, char ***path_list, int *num_paths);
extern int FI_set_symbol_path(char *symbol_path);
extern int FI_append_form_path(char *form_path);
extern int FI_append_symbol_path(char *symbol_path);
extern int FI_get_form_path(char form_path[]);
extern int FI_get_form_path_length(int *form_path_length);
extern int FI_get_symbol_path(char symbol_path[]);
extern int FI_get_symbol_path_length(int *symbol_path_length);
extern int FI_set_font_path(char *path);
extern int FI_set_FSfont_path(char *FSfont_path);
extern int FI_set_charmap_path(char *charmap_path);
extern char *_FI_font_alias(char *name, int size);
extern int _FI_find_closest_font(char *name, int size);
extern int FI_load_font(char *fontname, int bodysize, int *actual_bodysize, Font *font_id, int *font_type);
extern int FI_set_keyboard_buffer(char *buffer, int size);
extern int FI_get_form(Window window, Form *form);
extern int FI_get_form_by_name(char *name, Form *form_ptr);
extern int _FI_create_pixmaps(Window window, int screen);
extern void FI_select_FS_fonts_first(void);
extern void FI_select_X_fonts_first(void);
extern int FI_enter(Display *display, Colormap cmap, int cmap_size);

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
extern int FI_inq_symbol_attr(char *symbol_file, int index, int *total_width, int *total_height, int *xoff, int *yoff, int *sym_width, int *sym_height);

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
