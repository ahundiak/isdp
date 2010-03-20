/* dmb:08/31/92:This file is now obsolete. It is replaced by FBproto_priv.h" */

#ifndef FBEXT_H_DEFINED
#define FBEXT_H_DEFINED


extern char *realloc();
extern char *calloc();

extern char *expand_shell_vars();

extern int APP_process_command();

extern void Break_up_multi_line_string();

extern void Determine_current_gadgets();

extern void List_directory_contents();

extern void Clear_characteristics_form();

extern void Update_characteristics_form();

extern void Create_and_init_gadget();

extern void Calculate_text_size();
extern void CreateBlankCursor();
extern void FB_mlt_draw();
extern void FIf_gadgets_inside_area();

extern void Display_edit_forms();
extern void Display_symbol_dir_form();

extern void FIg_draw_a_label();
extern void FIgrp_calculate_size();

extern void Form_multi_line_string();

extern int Get_token();

extern void Init_scroll_area();
extern void Set_scroll_view_area();
extern void Set_scroll_symbol_file();
extern void Set_new_gadget_defaults();

extern void Clean_up_lines();
extern void Refresh_lines();
extern void Determine_current_sequences();
extern void Display_current_sequences();
extern void Draw_arrow();
extern void Paint_arrow();
extern void Refresh_work_form();

extern void Report_fatal_form_error();
extern void Report_fatal_error();
extern void Report_nonfatal_error();

extern void display_grid_on_work_form();

extern void edit_bezel_gadget();
extern void edit_button_gadget();
extern void edit_cklist_gadget();
extern void edit_dial_gadget();
extern void edit_field_gadget();
extern void edit_gauge_gadget();
extern void edit_line_gadget();
extern void edit_multi_col_field_gadget();
extern void edit_rectangle_gadget();
extern void edit_scroll_gadget();
extern void edit_slider_gadget();
extern void edit_symbol_gadget();
extern void edit_text_gadget();
extern void edit_toggle_gadget();

extern void execute_change_pv();
extern void execute_copy_form();
extern void execute_copy_gadget();
extern void execute_create_data_link();
extern void execute_create_group();
extern void execute_create_sequence();
extern void execute_define_form();
extern void execute_delete_data_link();
extern void execute_delete_form();
extern void execute_delete_gadget();
extern void execute_delete_group();
extern void execute_delete_sequence();
extern void execute_display_characteristics_form();
extern void execute_drop_from_group();
extern void execute_edit_gadget();
extern void execute_exit_fb();
extern void execute_expanded_preview();
extern void execute_fence_copy();
extern void execute_fence_delete();
extern void execute_fence_edit();
extern void execute_fence_move();
extern void execute_fence_undelete();
extern void execute_fit_form();
extern void execute_group_copy();
extern void execute_group_delete();
extern void execute_group_edit();
extern void execute_group_move();
extern void execute_group_undelete();
extern void execute_move_gadget();
extern void execute_place_bezel();
extern void execute_place_button();
extern void execute_place_cbar();
extern void execute_place_cklist();
extern void execute_place_dial();
extern void execute_place_err_msg_flds();
extern void execute_place_field();
extern void execute_place_gauge();
extern void execute_place_line();
extern void execute_place_multi_col_field();
extern void execute_place_palette();
extern void execute_place_rectangle();
extern void execute_place_scroll();
extern void execute_place_slider();
extern void execute_place_symbol();
extern void execute_place_text();
extern void execute_place_toggle();
extern void execute_preview_form();
extern void execute_review_data_link();
extern void execute_review_sequence();
extern void execute_save_form();
extern void execute_save_pv();
extern void execute_show_group();
extern void execute_undelete_gadget();

/* Form Notification: "form input" functions */
extern void dummy_notification_routine();
extern void fi_assoc_list_field_form();
extern void fi_background_form();
extern void fi_bezel_form();
extern void fi_bg_color_form();
extern void fi_button_form();
extern void fi_cbar_form();
extern void fi_characteristics_form();
extern void fi_cklist_form();
extern void fi_column_mode_form();
extern void fi_copy_form();
extern void fi_define_form();
extern void fi_delete_form();
extern void fi_dial_form();
extern void fi_dummy_notify();
extern void fi_dummy_work_form();
extern void fi_edit_column_form();
extern void fi_edit_field_form();
extern void fi_fg2_color_form();
extern void fi_fg_color_form();
extern void fi_fit_form();
extern void fi_font_form();
extern void fi_font_options_form();
extern void fi_gauge_form();
extern void fi_grid_form();
extern void fi_group_form();
extern void fi_line_form();
extern void fi_line_style_form();
extern void fi_line_weight_form();
extern void fi_master_field_form();
extern void fi_master_pv_form();
extern void fi_message_form();
extern void fi_multi_edit_form();
extern void fi_palette_form();
extern void fi_place_multi_column_form();
extern void fi_preview_form();
extern void fi_rectangle_form();
extern void fi_save_form();
extern void fi_save_pv_form();
extern void fi_scroll_field_form();
extern void fi_scroll_form();
extern void fi_slider_form();
extern void fi_sym_dir_form();
extern void fi_symbol_form();
extern void fi_symbol_scroll();
extern void fi_text_form();
extern void fi_toggle_form();
extern void fi_verify_column_form();
extern void fi_verify_field_form();
extern void fi_work_form();

extern void format_integer_field();
extern void format_float_field();

extern void kill_change_pv();
extern void kill_copy_form();
extern void kill_copy_gadget();
extern void kill_create_data_link();
extern void kill_create_group();
extern void kill_create_sequence();
extern void kill_define_form();
extern void kill_delete_data_link();
extern void kill_delete_form();
extern void kill_delete_gadget();
extern void kill_delete_group();
extern void kill_delete_sequence();
extern void kill_drop_from_group();
extern void kill_edit_gadget();
extern void kill_exit_fb();
extern void kill_expanded_preview();
extern void kill_fence_copy();
extern void kill_fence_delete();
extern void kill_fence_edit();
extern void kill_fence_move();
extern void kill_fence_undelete();
extern void kill_fit_form();
extern void kill_group_copy();
extern void kill_group_delete();
extern void kill_group_edit();
extern void kill_group_move();
extern void kill_group_undelete();
extern void kill_move_gadget();
extern void kill_place_bezel();
extern void kill_place_button();
extern void kill_place_cbar();
extern void kill_place_cklist();
extern void kill_place_dial();
extern void kill_place_field();
extern void kill_place_gauge();
extern void kill_place_line();
extern void kill_place_multi_col_field();
extern void kill_place_palette();
extern void kill_place_rectangle();
extern void kill_place_scroll();
extern void kill_place_slider();
extern void kill_place_symbol();
extern void kill_place_text();
extern void kill_place_toggle();
extern void kill_preview_form();
extern void kill_review_data_link();
extern void kill_review_sequence();
extern void kill_save_form();
extern void kill_save_pv();
extern void kill_show_group();
extern void kill_undelete_gadget();

extern void setup_standard_attr();

extern int validate_integer_field ();
extern double validate_double_field ();

extern int window_event_grid_check();

extern int _is_a_form();
extern void _FI_free();
extern int _FI_bez_pop_to_bottom();

extern void process_dpb_keyword();
extern void process_language_keyword();
extern void process_sympath_keyword();

extern void toggle_grid_mode();

#endif
