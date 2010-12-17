/* $Revision: 1.1 $ */
#ifndef DBA_H
#define DBA_H

#if defined(__WIN16__) || defined(__WIN32__)
#include "windows.h"
#endif

#ifdef _MAC_
#include "mac.h"
#endif

#include "dba.def"
#include "dba.pro"
#include "report.h"
#include "mb.h"
#include "rb.h"
#include "ustn.h"

#if defined(__WIN32__)
HANDLE dba_drag_drop_handle = 0;
#endif

struct dba_gadget *dba_cgadget;
struct dba_sch *dba_csch, *dba_fsch, *dba_lsch, dba_ssch;
struct dba_ent *dba_curent, *dba_cent, *dba_ment[200];
struct dba_att *dba_catt;
struct dba_defatt *dba_fdefatt, *dba_rdefatt;
struct dba_library *dba_script_lib;
struct dba_code_list *dba_ccl;
struct dba_template *dba_template_list;
struct dba_reltemp *dba_f_reltemp, *dba_l_reltemp, *dba_c_reltemp;

char dba_rpt_desc[51], dba_str_desc[51],
 dba_key_buf[256], dba_output[260], dba_str_nam[21],
 *dba_ptr_occ, *dba_mem_ptr, *dba_prodname,
 *dba_schema_list, *dba_stext, *dba_fldval, *dba_last_keyin, *dba_errtxt, 
 *dba_datbas, *dba_lib, *dba_lib_list, dba_text[250], 
 dba_rtbnam[21], dba_relop[21], *dba_dload_debug, 
 *dba_delcond, *dba_support, *dba_drag_drop = 0,
 *dba_mnunam[101], dba_find_name[21], dba_find_desc[51], dba_sql_name[21],
 dba_sql_desc[51], dba_opt_name[21], dba_opt_desc[51],
 dba_rel_name[21], dba_rel_desc[51],
 dba_els_input[101], dba_asc_input[101],
 *dba_parser_echo, dba_errtext[250], dba_menu_name[21], 
 *dba_script_fldval, *dba_where, dba_script_name[3][21], dba_app_name[21],
 dba_app_template[21],
 dba_script_desc[3][51], dba_app_desc[51], dba_mnudesc[51], dba_menu_title[51],
 *dba_raster, *dba_da_file, dba_dap_report[21],
 **dba_script_errtxt, *dba_gadget_script, *dba_script_debug_file,
 *dba_script_trace_file, *dba_editor, **dba_dap_dgn_files,
 *dba_timestamp_format, *dba_playback_file, *dba_record_file,
 *dba_sqlptr, *dba_initial_script, *dba_raster_path, *dba_logkbd, 
 *dba_root_dir, *dba_print, *dba_error_log,
 dba_unix_delimiter, dba_ustn_delimiter, dba_script_delimiter,
 dba_path_delimiter, dba_path_separator, *dba_list_ptr,
 *dba_mslink, dba_load_pending[21], 
 *dba_help_source, *dba_key_script, *dba_button_script, dba_server_node[50],
 *dba_object_lib, *dba_table_order, dba_menu_cell[21], dba_comma_character,
 *dba_shell, *dba_batch_script_string, *dba_recent_template[MAX_TEMPTYPES][8],
 dba_version[12], *dba_async_script, *dba_keyin_text, *dba_password_text,
 *dba_username_text, dba_report_relations[21], *dba_p[6], *dba_command_string,
 *dba_report_display;

double dba_dap_index, dba_form_value, dba_defval;

#if defined __WIN32__
double dba_zero_location;
#else
float dba_zero_location;
#endif

int dba_row, dba_column, dba_no_stop, dba_fvnch, dba_template_lines, 
 dba_curlin, dba_error, dba_srttot, dba_lintot, dba_rpt_tot, 
 dba_message_strip=1, dba_default_schema, dba_mce_command, dba_code_sort, 
 dba_save_restore, dba_report_type, dba_label, dba_sync_worksheets, 
 dba_type, dba_structure_type, dba_pause=1, dba_form_label, dba_fldtrm, 
 (*dba_orig_map)(), (*dba_before_notify)(), (*dba_after_notify)(),
 dba_rpt_ifp, dba_totadd, dba_cur_rpt, 
 dba_db_numbers, dba_user_action, dba_write_access, dba_rec_length, 
 dba_table_count, dba_user_message, dba_mnunum, dba_batch_mode, dba_first_menu,  dba_rb, dba_mb, 
 dba_columns_per_page, dba_lines_per_page, dba_no_load, dba_from_builder,
 dba_mnunum_save, dba_append_msg, dba_cr,
 dba_delete_row_toggle, dba_attach_mode, dba_graphic_mode,
 dba_insert_read_only, dba_sql_from,
 dba_inv_menu[101], dba_autocommit, dba_cur_menu,
 dba_optimize, dba_new_temp[MAX_TEMPTYPES], dba_mce_restrict,
 dba_error_lines, dba_blank_pad, dba_dap_batch_mode,
 dba_dap_num_files, dba_abort_flag, dba_return_type, dba_interrupt_flag,
 dba_lkb_pid, dba_text_size, dba_optimized_query,
 dba_field_label, dba_normal_text, dba_no_scaling,
 dba_field_mnunum, dba_no_review_totals, dba_set_gadget_mode,
 dba_fixed_vlt, dba_no_read_lock, dba_status_field = 2,
 dba_script_fldtrm, dba_script_form_label, dba_system_menu,
 dba_on_symbol, dba_help_active, dba_join_to_many, dba_open_query,
 dba_button, dba_help_only, dba_no_mscatalog,
 dba_library_timestamp, dba_open_review, dba_log_message, dba_single_range,
 dba_sync_menus, dba_app_active, dba_select_button, dba_display_screen,
 dba_put_field_column, dba_put_field_active, dba_rev1, dba_rev2, dba_slow_read,  dba_stop_pid, dba_system_window, dba_system_no_wait, dba_system_executing,
 dba_menu_lock, dba_report_nulls, dba_uppercase, dba_lowercase, dba_debug,
 dba_forms_colors, dba_forms_mode, dba_forms_fonts, dba_disp_menu_label[101],
 dba_use_names_for_titles, dba_topmost, dba_first_turbo, dba_form_window,
 dba_no_cursor, dba_locked_menu, dba_auto_change_all, dba_position,
 dba_ignore_scroll, dba_scrap, dba_border_style, dba_minor_incs,
 dba_keyin_response, dba_yes, dba_no_parent_dialogs, dba_dde, dba_native_mode,
 dba_ws_column_scroll, (*dba_report_filter)(), dba_editor_num,
 dba_editor_labels[3], dba_relxlo, dba_relylo, dba_relxhi, dba_relyhi,
 dba_default_button_cr, dba_bug_reload_function, dba_no_put_field_notify,
 dba_relations_mode, dba_use_server_flag, dba_alias_report_table,
 dba_no_pop_to_top, dba_no_blocking, dba_use_system_font, dba_wrap_not_native,
 dba_queue_ustn_cmd, dba_no_auto_wait_cursor;

long DBACODE;

long dba_rpt_last, dba_fld_attr, dba_template_total, dba_verify_mode;

unsigned long dba_fv_size, dba_dcond_lng, dba_st_size, dba_mem_size,
 dba_script_fv_size, dba_list_size, dba_font_mask, dba_command_lng;

union dba_mixed *dba_value;

Form dba_form[200], dba_form_ptr;

FILE *dba_record_ptr, *dba_playback_ptr, *dba_msg_file, *dba_rpt_ptr;

int dba_verbose_active, dba_put_field_active, dba_store_scripts,
    dba_ignore_stored;

long dba_verbose_mode;

#endif
