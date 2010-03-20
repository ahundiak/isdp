
/* FBprint_vers.c */
extern int FBprint_version(void);

/* bezel_gdt.c */
extern void kill_place_bezel(void);
extern void fi_bezel_form(int form_label, int gadget_label, double value, Form form_ptr);
extern void execute_place_bezel(void);
extern void edit_bezel_gadget(void);

/* builder.c */
extern int FIf_calculate_size(struct FIform_obj *form);
extern void FIgrp_calculate_size(struct FIform_obj *form, int group_label);
extern int FIf_get_description(struct FIform_obj *form, int *num_desc, char ***description_ptr);
extern int FIf_set_description(struct FIform_obj *form, int num_desc, char **description_ptr);
extern int FIf_set_builder_mode_on(struct FIform_obj *form);
extern int FIf_set_builder_mode_off(struct FIform_obj *form);
extern int FIg_set_default_attr(struct FIform_obj *form, int label, int attr_mask);
extern int FIf_fit_to_gadgets(struct FIform_obj *form, int border);
extern int _FI_g_verify_erase_color(struct FIform_obj *form, int label, int group_label);
extern int _FI_bez_pop_to_bottom(struct FIform_obj *form, int bezel_label);
extern int _FI_is_grp_member_within_bezel(struct FIform_obj *form, int group_label, int bezel_label, int *member_index, struct FIgroup_obj **member_group);
extern char *_FI_find_define(int label);
extern int _FI_g_dump_defines(struct FIgadget_obj *gadget, FILE *fout);
extern int _FI_g_dump_case(struct FIgadget_obj *gadget, FILE *fout);
extern int FIf_dump_process_code(struct FIform_obj *form, char *path);
extern int FIsld_get_slot_size(struct FIform_obj *form, int label, float *slot_size);

/* button_gdt.c */
extern void kill_place_button(void);
extern void fi_button_form(int form_label, int gadget_label, double value, Form form_ptr);
extern void execute_place_button(void);
extern void edit_button_gadget(void);

/* button_pal.c */
extern void kill_place_palette(void);
extern void fi_palette_form(int form_label, int gadget_label, double value, Form form_ptr);
extern void execute_place_palette(void);

/* change_pv.c */
extern void kill_change_pv(void);
extern void fi_master_pv_form(int form_label, int gadget_label, double value, Form form_ptr);
extern void fi_font_form(int form_label, int gadget_label, double value, Form form_ptr);
extern void fi_grid_form(int form_label, int gadget_label, double value, Form form_ptr);
extern void fi_line_weight_form(int form_label, int gadget_label, double value, Form form_ptr);
extern void fi_line_style_form(int form_label, int gadget_label, double value, Form form_ptr);
extern void fi_fg_color_form(int form_label, int gadget_label, double value, Form form_ptr);
extern void fi_bg_color_form(int form_label, int gadget_label, double value, Form form_ptr);
extern void fi_fg2_color_form(int form_label, int gadget_label, double value, Form form_ptr);
extern void execute_change_pv(void);

/* character.c */
extern void Clear_characteristics_form(void);
extern void Update_characteristics_form(void);
extern void fi_characteristics_form(int form_label, int gadget_label, double value, Form form_ptr);
extern void execute_display_characteristics_form(void);
extern void replace_attr_with_overrides(void);

/* cklist_gdt.c */
extern void kill_place_cklist(void);
extern void fi_cklist_form(int form_label, int gadget_label, double value, Form form_ptr);
extern void execute_place_cklist(void);
extern void edit_cklist_gadget(void);

/* command.c */
extern int command_screen(char *cmd);
extern int APP_process_command(int cmd_type, char *cmd);

/* copy_form.c */
extern void kill_copy_form(void);
extern int Setup_copy_description_field(void);
extern void fi_copy_form(int form_label, int gadget_label, double value, Form form_ptr);
extern void execute_copy_form(void);

/* copy_gdt.c */
extern void kill_copy_gadget(void);
extern void execute_copy_gadget(void);

/* create_grp.c */
extern void kill_create_group(void);
extern void Determine_current_gadgets(void);
extern void fi_group_form(int form_label, int gadget_label, double value, Form form_ptr);
extern void execute_create_group(void);

/* create_lnk.c */
extern void kill_create_data_link(void);
extern int Determine_current_data_links(void);
extern int check_for_loop(int from_gadget, int to_gadget);
extern void execute_create_data_link(void);

/* create_seq.c */
extern void kill_create_sequence(void);
extern void Draw_arrow(int color, int x1, int y1, int x2, int y2, int index);
extern int Poke_arrow_endpoint(int anchor_x, int anchor_y, int *x_pos, int *y_pos);
extern void Clean_up_lines(void);
extern void Refresh_lines(void);
extern void Determine_current_sequences(void);
extern void Display_current_sequences(void);
extern void Paint_arrow(int label);
extern void execute_create_sequence(void);

/* define_form.c */
extern void kill_define_form(void);
extern int _is_a_form(char *file, char *directory);
extern void fi_background_form(int form_label, int gadget_label, double value, Form form_ptr);
extern void fi_define_form(int form_label, int gadget_label, double value, Form form_ptr);
extern void execute_define_form(void);

/* delete_form.c */
extern void kill_delete_form(void);
extern void List_directory_contents(Form form, int gadget, char *directory_name);
extern void fi_dummy_notify(int form_label, int gadget_label, double value, Form form_ptr);
extern void fi_delete_form(int form_label, int gadget_label, double value, Form form_ptr);
extern void execute_delete_form(void);

/* delete_gdt.c */
extern void kill_delete_gadget(void);
extern void execute_delete_gadget(void);

/* delete_grp.c */
extern void kill_delete_group(void);
extern void execute_delete_group(void);

/* delete_lnk.c */
extern void kill_delete_data_link(void);
extern void execute_delete_data_link(void);

/* delete_seq.c */
extern void kill_delete_sequence(void);
extern void execute_delete_sequence(void);

/* dial_gdt.c */
extern void kill_place_dial(void);
extern void fi_dial_form(int form_label, int gadget_label, double value, Form form_ptr);
extern void execute_place_dial(void);
extern void edit_dial_gadget(void);

/* drop_grp.c */
extern void kill_drop_from_group(void);
extern void execute_drop_from_group(void);

/* edit_gdt.c */
extern void kill_edit_gadget(void);
extern void execute_edit_gadget(void);
extern void setup_standard_attr(int edit_gadget);

/* err_msg_fld.c */
extern void execute_place_err_msg_flds(void);
extern void kill_place_err_msg_flds(void);

/* exec.c */
extern unsigned long FEI_translate_color(int screen, int color);
extern void turn_sync_on(void);
extern void turn_sync_off(void);
extern int myhandler(Display *display, XErrorEvent *myerr);

/* exit_fb.c */
extern void execute_exit_fb(void);
extern void kill_exit_fb(void);

/* exp_preview.c */
extern void kill_expanded_preview(void);
extern void fi_preview_form(int form_label, int gadget_label, double value, Form form_ptr);
extern void execute_expanded_preview(void);

/* fei.c */
extern int FEI_get_keyboard_data(char *character, int *count, int font_type);
extern int FEI_enter(void);

/* fence_copy.c */
extern void kill_fence_copy(void);
extern void execute_fence_copy(void);

/* fence_delete.c */
extern void kill_fence_delete(void);
extern void execute_fence_delete(void);

/* fence_edit.c */
extern void kill_fence_edit(void);
extern void fi_font_options_form(int form_label, int gadget_label, double value, Form form_ptr);
extern void fi_multi_edit_form(int form_label, int gadget_label, double value, Form form_ptr);
extern void Display_edit_forms(void);
extern void execute_fence_edit(void);

/* fence_move.c */
extern void kill_fence_move(void);
extern void execute_fence_move(void);

/* fence_undel.c */
extern void kill_fence_undelete(void);
extern void execute_fence_undelete(void);

/* field_gdt.c */
extern void kill_place_field(void);
extern void fi_assoc_list_field_form(int form_label, int gadget_label, double value, Form form_ptr);
extern void fi_edit_field_form(int form_label, int gadget_label, double value, Form form_ptr);
extern void fi_scroll_field_form(int form_label, int gadget_label, double value, Form form_ptr);
extern void fi_verify_field_form(int form_label, int gadget_label, double value, Form form_ptr);
extern void fi_master_field_form(int form_label, int gadget_label, double value, Form form_ptr);
extern void execute_place_field(void);
extern void edit_field_gadget(void);

/* fit_form.c */
extern void kill_fit_form(void);
extern void fi_fit_form(int form_label, int gadget_label, double value, Form form_ptr);
extern void execute_fit_form(void);

/* gauge_gdt.c */
extern void kill_place_gauge(void);
extern void fi_gauge_form(int form_label, int gadget_label, double value, Form form_ptr);
extern void execute_place_gauge(void);
extern void edit_gauge_gadget(void);

/* grid.c */
extern void display_grid_on_work_form(void);
extern void toggle_grid_mode(void);
extern void window_event_grid_check(int form_label, int event, Form form);

/* group_copy.c */
extern void kill_group_copy(void);
extern void execute_group_copy(void);

/* group_delete.c */
extern void kill_group_delete(void);
extern void execute_group_delete(void);

/* group_edit.c */
extern void kill_group_edit(void);
extern void execute_group_edit(void);

/* group_move.c */
extern void kill_group_move(void);
extern void execute_group_move(void);

/* group_undel.c */
extern void kill_group_undelete(void);
extern void execute_group_undelete(void);

/* line_gdt.c */
extern void kill_place_line(void);
extern void fi_line_form(int form_label, int gadget_label, double value, Form form_ptr);
extern void execute_place_line(void);
extern void edit_line_gadget(void);

/* load_sym.c */
extern int load_sym_bitmap(char *symbol_file, int sym_index, char **bitmap, int *width, int *height);

/* move_gdt.c */
extern void kill_move_gadget(void);
extern void execute_move_gadget(void);

/* multi_col.c */
extern void kill_place_multi_col_field(void);
extern void fi_column_mode_form(int form_label, int gadget_label, double value, Form form_ptr);
extern void fi_place_multi_column_form(int form_label, int gadget_label, double value, Form form_ptr);
extern void fi_verify_column_form(int form_label, int gadget_label, double value, Form form_ptr);
extern void fi_edit_column_form(int form_label, int gadget_label, double value, Form form_ptr);
extern void dummy_notification_routine(int form, int label, double value, Form form_ptr);
extern void execute_place_multi_col_field(void);
extern void edit_multi_col_field_gadget(void);

/* parse.c */
extern int Get_token(void);
extern void process_sympath_keyword(void);
extern void process_dpb_keyword(void);
extern void process_language_keyword(void);

/* place_cbar.c */
extern void kill_place_cbar(void);
extern int create_cbar_gadgets(void);
extern void fi_cbar_form(int form_label, int gadget_label, double value, Form form_ptr);
extern void execute_place_cbar(void);

/* poke.c */
extern void CreateBlankCursor(Display *display, Window window);
extern void Calculate_text_size(char string[2000 ], char fontname[2000 ], float bodysize, int *width, int *height);
extern void FB_mlt_draw(Window window, Font font_id, char *string, int xpos, int ypos, int justify, int max_width, int font_type);
extern int Get_first_point(Window window, int *x_pos, int *y_pos, int box_x, int box_y, int offset_x, int offset_y);
extern int Get_second_point(Window window, int anchor_x, int anchor_y, int *x_low, int *y_low, int *x_high, int *y_high, int width, int style);
extern int Move_field_box(Window window, int *x_pos, int *y_pos, int x_size, int y_size, int offset_x, int offset_y, int single_line_mode, int horz_flag, int vert_flag, int icon_flag);
extern int Move_MCF_box(Window window, int *x_pos, int *y_pos, int x_size, int y_size, int offset_x, int offset_y, int single_line_mode, int horz_flag, int vert_flag, int button_flag, int row_select_flag);
extern int Define_field_box(Window window, int anchor_x, int anchor_y, int *x_low, int *y_low, int *x_high, int *y_high, int *rows, int *columns, int text_width, int line_spacing, int single_line_mode, int horz_flag, int vert_flag, int icon_flag, int selectable_flag);
extern int Poke_plain_point(Window window, int *x_pos, int *y_pos);
extern int Get_endpoint(Window window, int anchor_x, int anchor_y, int *x_pos, int *y_pos);
extern int Poke_symbol_location(Window window, int *x_pos, int *y_pos, char *filename, int index, int offset_x, int offset_y);
extern int Poke_text_location(Window window, int *x_pos, int *y_pos, int offset_x, int offset_y, char *string, int justify, char *fontname, float bodysize);
extern int Move_line_gadget(Window window, int *x_pos, int *y_pos, int x_size, int y_size, int offset_x, int offset_y);
extern void FIf_gadgets_inside_area(Form form, int xlo, int ylo, int xhi, int yhi, int *num_gadgets, int gadget_array[100 ]);
extern int Poke_point_or_keyin(Window window, int *x_pos, int *y_pos, int *label);
extern int Select_gadget(int *gadget_label, int *xsize, int *ysize, int *display_flag, int *hilite_flag, int *accept_x, int *accept_y, int mode);

/* preview_form.c */
extern void FB_use_xfb_gc_mlt_draw(Window window, int font_id, char *string, int xpos, int ypos, int justify, int max_width, int font_type);
extern void FIg_draw_a_label(int label);
extern void execute_preview_form(void);
extern void kill_preview_form(void);

/* proclkb.c */
extern int process_logical_keyboard_keyword(void);

/* rectangle.c */
extern void kill_place_rectangle(void);
extern void fi_rectangle_form(int form_label, int gadget_label, double value, Form form_ptr);
extern void execute_place_rectangle(void);
extern void edit_rectangle_gadget(void);

/* review_lnk.c */
extern void kill_review_data_link(void);
extern void execute_review_data_link(void);

/* review_seq.c */
extern void kill_review_sequence(void);
extern int Draw_line_between_gadgets(int from_gadget, int to_gadget);
extern int Backtrack(int gadget);
extern void execute_review_sequence(void);

/* save_form.c */
extern void kill_save_form(void);
extern void fi_save_form(int form_label, int gadget_label, double value, Form form_ptr);
extern void execute_save_form(void);

/* save_pv.c */
extern void kill_save_pv(void);
extern void fi_save_pv_form(int form_label, int gadget_label, double value, Form form_ptr);
extern void execute_save_pv(void);

/* scroll_gdt.c */
extern void kill_place_scroll(void);
extern void fi_scroll_form(int form_label, int gadget_label, double value, Form form_ptr);
extern void execute_place_scroll(void);
extern void edit_scroll_gadget(void);

/* shellvar.c */
extern char *expand_shell_vars(char *unexpanded_filename);

/* show_grp.c */
extern void kill_show_group(void);
extern void execute_show_group(void);

/* slider_gdt.c */
extern void kill_place_slider(void);
extern void format_integer_field(int value, char *format_string);
extern void format_float_field(double value, char *format_string);
extern void fi_slider_form(int form_label, int gadget_label, double value, Form form_ptr);
extern void execute_place_slider(void);
extern void edit_slider_gadget(void);
extern void initial_notify_slider(int form, int gadget, double value, Form fp);

/* symbol_dir.c */
extern int BSfilter(char *font_file);
extern int list_symbol_files(char *sym_dir);
extern void fi_sym_dir_form(int form_label, int gadget_label, double value, Form form_ptr);
extern void Display_symbol_dir_form(void);

/* symbol_gdt.c */
extern void kill_place_symbol(void);
extern void fi_symbol_form(int form_label, int gadget_label, double value, Form form_ptr);
extern void execute_place_symbol(void);
extern void edit_symbol_gadget(void);

/* symbol_scrl.c */
extern void Init_scroll_area(char *Symbol_file, int Symbol_index);
extern void Set_scroll_view_area(int Symbol_index);
extern void Set_scroll_symbol_file(char *Symbol_file);
extern void fi_symbol_scroll(int form_label, int gadget_label, double value, Form form_ptr);

/* talktokb.c */
extern int talk_to_kb(char *character, int *count);

/* text_gdt.c */
extern void kill_place_text(void);
extern void fi_text_form(int form_label, int gadget_label, double value, Form form_ptr);
extern void execute_place_text(void);
extern void edit_text_gadget(void);

/* toggle_gdt.c */
extern void kill_place_toggle(void);
extern void fi_toggle_form(int form_label, int gadget_label, double value, Form form_ptr);
extern void execute_place_toggle(void);
extern void edit_toggle_gadget(void);

/* toolbox.c */
extern void Set_new_gadget_defaults(void);
extern void Create_and_init_gadget(Form form, int gadget_type, int new_label);
extern int forms_intersect(Form form1, Form form2);
extern void Refresh_work_form(void);
extern void Report_fatal_form_error(int status, char *file_string);
extern void Report_fatal_error(char *error_string);
extern void Report_nonfatal_error(char *error_string);
extern void Break_up_multi_line_string(Form form, int label, char *string);
extern void Form_multi_line_string(Form form, int label, char *string);
extern void _FI_free(void *pointer);
extern int _FI_draw_box(Window window, int xlo, int ylo, int xhi, int yhi);
extern int sort_font_names(void);
extern int Redisplay(Form form);

/* undelete_gdt.c */
extern void kill_undelete_gadget(void);
extern void execute_undelete_gadget(void);

/* validate.c */
extern int validate_integer_field(char *i_str, Form form, int err_field_index, int *status);
extern double validate_double_field(char *f_str, Form form, int err_field_index, int *status);
extern int print_error(Form form, int err_field_index, char *t_str);

/* whence.c */
extern char *IIwhence(char *name, char *workdir);

/* work_form.c */
extern void fi_work_form(int form_label, int gadget_label, double value, Form form_ptr);
extern void fi_dummy_work_form(int form_label, int gadget_label, double value, Form form_ptr);
extern void fi_message_form(int form_label, int gadget_label, double value, Form form_ptr);
