#ifndef dba_proto_h
#define dba_proto_h

extern dba_abort (
);


extern int dba_about(
);

extern dba_active_position (
  int  *row,
  int  *col);

extern int dba_add_forms_gadget (
  char  *menu,
  int  label);


extern int dba_add_query (
  char  *logical,
  char  *schema,
  char  *table,
  char  *column,
  char  *relop,
  char  *attval);

extern int dba_add_query_string (
  char  *logical,
  char  *schema,
  char  *table,
  char  *value);

extern int dba_add_to_table_list (
  char  *schema,
  char  *table);

extern int dba_all_report_tables (
  char  *library,
  char  *template,
  char  ***schema,
  char  ***table,
  int  *total);

extern int dba_attach_dap_link (
);

extern int dba_attach_file_link(
);

extern int dba_attach_linkage (
);

extern int dba_attach_note(
);

extern int dba_attach_user_link(
);


extern int dba_build_dir_list (
  char  *menu,
  int  label,
  char  *path);


extern int dba_build_file_list (
  char  *menu,
  int  label,
  char  *path);

extern int dba_build_font_list(
  char  *menu,
  int   label);

extern int dba_build_note_list(
  char  *filename,
  int  *num_files);

extern int dba_build_select_list (
  char  *menu,
  int  label,
  char  *select);

extern int dba_build_system_list (
  char  *menu,
  int  label,
  char  *command);


extern int dba_cancel (
  char  *menu);

extern int dba_cancel_child_menus (
  char  *menu);



extern int dba_change_all (
);


extern int dba_change_row (
);

extern int dba_check_raster(
);

extern int dba_clear_report (
);

extern int dba_close_cursor (
);




extern int dba_compile_from_file (
  char  *filename);

extern int dba_compile_script (
  char  *name);

extern int dba_compress_library (
  char  *lib);

extern int dba_convert_date (
  char  *out,
  char  *in);

extern int dba_count_active_files(
  int  *active_count);

extern int dba_create_library (
  char  *library,
  int  confirm);

#if defined WIN32
extern UINT dba_dde_connect(
  char  *service,
  char  *topic);

#endif
#if defined WIN32
extern void dba_dde_disconnect(
);

#endif

extern void dba_dde_exit(
);


extern int dba_dde_initialize(
);

#if defined WIN32
extern UINT dba_dde_send_execute(
  char  *command);

#endif
#if defined WIN32
extern UINT dba_dde_send_request(
  char  *result,
  char  *request);

#endif


extern int dba_delete_all (
);

extern int dba_delete_from_table_list (
  char  *schema,
  char  *table);

extern int dba_delete_menu (
  char  *menu);


extern int dba_delete_row (
);

extern int dba_delete_template (
  char  *lib,
  char  *template,
  int  type,
  int  verify);

extern int dba_display_graphics(
);


extern int dba_display_graphics (
  char  *filename,
  int  xo,
  int  yo,
  int  width,
  int  height,
  int  page,
  int  *file_id);

extern int dba_display_menu (
  char  *menu,
  int  preserve);

extern int dba_display_report (
  char  *output);


extern int dba_dload (
  char  *path);


extern int dba_dload_complete (
);


extern int dba_dload_incremental (
  char  *path);


extern int dba_drag_query_point(
  long  *x,
  long  *y);



extern int dba_edit_code (
);

extern int dba_execute_default (
  struct dba_default_options  options,
  struct dba_default_list  *list,
  int  total,
  int  process,
  char  *where,
  int  display);







extern void dba_exit (
);

extern int dba_exit_graphics (
);

extern int dba_exit_graphics(
  int  file_id);







extern int dba_fields_on_off (
);


extern int dba_find_dirs(
  char  *dir_buf,
  char  *usr_buf,
  int   fresh_start);


extern int dba_find_files(
  char  *file_buf,
  char  *usr_buf,
  int   fresh_start);

extern int dba_fit(
);

extern int dba_flush_codelist (
  char  *schema,
  char  *table,
  char  *column);

extern int dba_flush_schema (
  char  *schema);

extern int dba_flush_table (
  char  *schema,
  char  *table);


extern int dba_format_default (
  char  *schema,
  char  *table,
  char  *columns,
  int  include,
  char  *sort,
  int  width,
  int  counter,
  int  spacing,
  struct dba_default_options  *options,
  struct dba_default_list  **list,
  int  *count);

extern int dba_get_code_number (
  char  *schema,
  char  *table,
  char  *column,
  long  *code_number,
  char  *code_text);

extern int dba_get_code_text (
  char  *schema,
  char  *table,
  char  *column,
  long  code_number,
  char  *code_text);

extern void dba_get_color(
  char  *color);

extern int dba_get_column_name_by_number (
  char  *schema,
  char  *table,
  int  column,
  char  *column_name);

extern int dba_get_column_number_by_name (
  char  *schema,
  char  *table,
  char  *column,
  int  *column_number);



extern int dba_get_column_value (
  char  *schema,
  char  *table,
  char  *column,
  char  *value);



extern int dba_get_current_column (
  char  *schema,
  char  *table,
  char  *column);

extern int dba_get_current_menu (
  char  *menu);


extern int dba_get_current_row (
  long  *row);


extern int dba_get_current_table (
  char  *schema,
  char  *table);


extern int dba_get_dropped_files(
  char  *file);

extern int dba_get_extents(
  int  file_id,
  int  *width,
  int  *height);






extern void dba_get_font(
  char  *font);

extern int dba_get_invoking_menu (
  char  *menu,
  char  *invoking_menu);

extern int dba_get_key_in_mode (
  char  *menu,
  int  *mode);

extern int dba_get_keyin (
  char  *prompt,
  char  *keyin);

extern int dba_get_last_keyin (
  char  **text_ptr);

extern void dba_get_level(
  int  *level);

extern void dba_get_line_width(
  int  *line_width);

extern int dba_get_menu_by_name (
  char  *menu,
  Form  *form,
  int  *label);


extern int dba_get_menu_column_value (
  char  *menu,
  char  *schema,
  char  *table,
  char  *column,
  char  *value);

extern int dba_get_notes(
  int  number,
  char  *filename);

extern int dba_get_num_script_errors (
  int  *num_errs);

extern int dba_get_point (
  int  window,
  int  *x,
  int  *y);

extern int dba_get_query (
  char  *schema,
  char  *table,
  char  **query);


extern int dba_get_relop (
  char  *menu,
  char  *relop);


extern int dba_get_report_table (
  char  *library,
  char  *template,
  char  *schema,
  char  *table);

extern void dba_get_rl_text_size(
  double  *text_size);

extern int dba_get_schema_name_by_number (
  int  schema,
  char  *schema_name);

extern int dba_get_schema_number_by_name (
  char  *schema,
  int  *schema_number);

extern int dba_get_script_error (
  int  num,
  char  **msg_ptr,
  long  *line_ptr,
  long  *col_ptr,
  int  *type_ptr);

extern int dba_get_table_name_by_number (
  char  *schema,
  int  table,
  char  *table_name);

extern int dba_get_table_number_by_name (
  char  *schema,
  char  *table,
  int  *table_number);

extern int dba_get_verbose_state (
  int *state);

extern int dba_get_win_info(
  int   *window,
  int   *win_handle,
  char  *filename);

extern int dba_get_window(
  int  *window);

extern int dba_get_yes_no (
  char  *question,
  int  color);

extern int dba_goto_page(
  int  page);

extern int dba_grab_rle(
  char  *file);


extern int dba_help(
  char   *help_file,
  int    command,
  char   *data);


extern int dba_init_menu_query (
  char  *menu);

extern int dba_init_table_query (
  char  *schema,
  char  *table);

extern int dba_initialize_query (
);


extern int dba_insert_row (
);

extern int dba_instantiate_globals (
  char  *name);

extern int dba_is_wild_hit(
  char  *wild_buf,
  char  *str_buf);

extern int dba_list_library (
  char  *library,
  long  template_type,
  struct dba_template  **template_list,
  long  *list_count);

extern int dba_load_file(
);

extern int dba_locate_graphics (
  int  set,
  int  mode,
  int  view,
  double  zoom,
  int  blink);



extern int dba_lock_menu (
  char  *menu,
  int  flag);

extern int dba_lower (
  char  *text_ptr);

extern int dba_make_args(
  char *str,
  char **argv,
  int limit);

extern int dba_measure(
);


extern int dba_microstation (
  char  *comm);

extern int dba_microstation_wait (
  char  *command);

extern int dba_new_page (
);


extern int dba_next_row (
);

extern int dba_nfm_add_acl(
  char  *wfname,
  char  *aclname);

extern int dba_nfm_add_acl_user(
  char  *aclname,
  char  *class,
  char  *user,
  char  *wfname);

extern int dba_nfm_add_file(
  char  *catalog,
  char  *name,
  char  *rev,
  char  *filename,
  char  *storage,
  char  *ci_filename,
  char  *file_type);

extern int dba_nfm_add_item(
  char  *catalog,
  char  *name,
  char  *rev,
  char  *desc,
  int  aclno,
  int  version_limit,
  int  cisano,
  char  *filename,
  char  *ci_filename,
  char  *file_type);

extern int dba_nfm_add_list_to_set(
  char  *set_catalog,
  char  *set_name,
  char  *set_rev);

extern int dba_nfm_add_multi(
  char  *filename);

extern int dba_nfm_add_node(
  char  *node,
  char  *description,
  char  *xns,
  char  *tcp,
  char  *nfs);

extern int dba_nfm_add_set(
  char  *catalog,
  char  *set_name,
  char  *set_rev,
  char  *desc,
  int  aclno,
  int  version_limit,
  int  cisano);

extern int dba_nfm_add_storage_area(
  char  *storage,
  char  *node,
  char  *user,
  char  *passwd,
  char  *path,
  char  *type,
  char  *sa_type,
  char  *owner);

extern int dba_nfm_add_to_set(
  char  *catalog,
  char  *set_name,
  char  *set_rev,
  char  *name,
  char  *rev,
  char  *type);

extern int dba_nfm_add_to_set2(
  char  *set_catalog,
  char  *set_name,
  char  *set_rev,
  char  *catalog,
  char  *name,
  char  *rev,
  char  *type);

extern int dba_nfm_add_user(
  char  *user,
  char  *passwd,
  char  *desc,
  char  *path);

extern int dba_nfm_add_user_catalog(
  char  *name,
  char  *type,
  char  *synonym);

extern int dba_nfm_add_user_data(
  char  *name,
  char  *value);

extern int dba_nfm_add_user_item(
  char  *catalog,
  char  *name,
  char  *rev,
  char  *desc,
  int  aclno,
  int  version_limit,
  int  cisano,
  char  *filename,
  char  *ci_filename,
  char  *file_type);

extern int dba_nfm_build_set_list(
  char  *name,
  char  *rev,
  char  *type);

extern int dba_nfm_build_set_list2(
  char  *catalog,
  char  *name,
  char  *rev,
  char  *type);

extern int dba_nfm_cancel_item(
  char  *catalog,
  char  *name,
  char  *rev);

extern int dba_nfm_cancel_item_archive(
  char  *catalog,
  char  *name,
  char  *rev);

extern int dba_nfm_cancel_item_backup(
  char  *catalog,
  char  *name,
  char  *rev);

extern int dba_nfm_cancel_item_delete(
  char  *catalog,
  char  *name,
  char  *rev);

extern int dba_nfm_cancel_item_restore(
  char  *catalog,
  char  *name,
  char  *rev);

extern int dba_nfm_cancel_set(
  char  *catalog,
  char  *set_name,
  char  *set_rev);

extern int dba_nfm_change_file(
  char  *catalog,
  char  *name,
  char  *rev,
  char  *filename,
  char  *c_name,
  char  *c_value);

extern int dba_nfm_change_item(
  char  *catalog,
  char  *name,
  char  *rev,
  char  *c_name,
  char  *c_value);

extern int dba_nfm_change_node(
  char  *node,
  char  *c_name,
  char  *c_value);

extern int dba_nfm_change_sa_passwd(
  char  *storage,
  char  *old_passwd,
  char  *new_passwd);

extern int dba_nfm_change_storage_area(
  char  *storage,
  char  *c_name,
  char  *c_value);

extern int dba_nfm_change_user(
  char  *user,
  char  *c_name,
  char  *c_value);

extern int dba_nfm_change_user_passwd(
  char  *user,
  char  *passwd,
  char  *new_passwd);

extern int dba_nfm_checkin(
  char  *catalog,
  char  *name,
  char  *rev,
  char  *storage,
  char  *node,
  char  *user,
  char  *passwd,
  char  *path,
  char  *filename);

extern int dba_nfm_checkin_multi(
  char  *catalog,
  char  *name,
  char  *rev,
  char  *storage,
  char  *node,
  char  *user,
  char  *passwd,
  char  *path);

extern int dba_nfm_checkout(
  char  *catalog,
  char  *name,
  char  *rev,
  char  *storage,
  char  *node,
  char  *user,
  char  *passwd,
  char  *path,
  char  *filename);

extern int dba_nfm_copy(
  char  *catalog,
  char  *name,
  char  *rev,
  char  *storage,
  char  *node,
  char  *user,
  char  *passwd,
  char  *path,
  char  *filename);

extern int dba_nfm_copy_new_item(
  char  *catalog,
  char  *name,
  char  *rev,
  char  *new_catalog,
  char  *new_name,
  char  *new_rev,
  char  *new_cofilename,
  char  *new_cifilename,
  char  *new_storage);

extern int dba_nfm_create_catalog(
  char  *catalog,
  char  *desc,
  int  aclno);

extern int dba_nfm_create_user_catalog(
  char  *catalog,
  char  *desc,
  int  aclno);

extern int dba_nfm_default_schema(
);

extern int dba_nfm_delete_acl_user(
  char  *aclname,
  char  *class,
  char  *user,
  char  *wfname);

extern int dba_nfm_delete_catalog(
  char  *catalog);

extern int dba_nfm_delete_copied_file(
  char  *catalog,
  char  *name,
  char  *rev,
  char  *storage,
  char  *node,
  char  *user,
  char  *passwd,
  char  *path,
  char  *filename,
  int  version);

extern int dba_nfm_delete_file(
  char  *catalog,
  char  *name,
  char  *rev,
  char  *filename);

extern int dba_nfm_delete_item(
  char  *catalog,
  char  *name,
  char  *rev);

extern int dba_nfm_delete_node(
  char  *node);

extern int dba_nfm_delete_storage_area(
  char  *storage);

extern int dba_nfm_delete_user(
  char  *user);

extern int dba_nfm_drop_from_set(
  char  *catalog,
  char  *set_name,
  char  *set_rev,
  char  *item_name,
  char  *item_rev);

extern int dba_nfm_drop_from_set2(
  char  *set_catalog,
  char  *set_name,
  char  *set_rev,
  char  *catalog,
  char  *name,
  char  *rev);

extern int dba_nfm_drop_set(
  char  *set_catalog,
  char  *set_name,
  char  *set_rev);

extern int dba_nfm_flag_item_archive(
  char  *catalog,
  char  *name,
  char  *rev);

extern int dba_nfm_flag_item_backup(
  char  *catalog,
  char  *name,
  char  *rev);

extern int dba_nfm_flag_item_delete(
  char  *catalog,
  char  *name,
  char  *rev);

extern int dba_nfm_flag_item_restore(
  char  *catalog,
  char  *name,
  char  *rev);

extern int dba_nfm_get_message(
  char  *message);

extern dba_nfm_get_schema_name(
  char  *schema,
  char  *passwd);

extern int dba_nfm_load_workflow(
  char  *app,
  char  *wfname);

extern int dba_nfm_lock_item(
  char  *catalog,
  char  *name,
  char  *rev);

extern int dba_nfm_login(
  char  *server,
  char  *user,
  char  *passwd,
  char  *environment,
  int  debug);

extern int dba_nfm_logout(
);

extern int dba_nfm_make_transition(
  char  *catalog,
  char  *name,
  char  *rev,
  char  *state);

extern int dba_nfm_plot_item(
  char  *catalog,
  char  *name,
  char  *rev);

extern int dba_nfm_plot_set(
  char  *catalog,
  char  *name,
  char  *rev);

extern int dba_nfm_save_item(
  char  *catalog,
  char  *name,
  char  *rev);

extern int dba_nfm_save_set(
  char  *catalog,
  char  *name,
  char  *rev);

extern int dba_nfm_set_checkin(
  char  *catalog,
  char  *set_name,
  char  *set_rev,
  char  *storage,
  char  *node,
  char  *user,
  char  *passwd,
  char  *path);

extern int dba_nfm_set_checkout(
  char  *catalog,
  char  *set_name,
  char  *set_rev,
  int  level,
  char  *storage,
  char  *node,
  char  *user,
  char  *passwd,
  char  *path);

extern int dba_nfm_set_copy(
  char  *catalog,
  char  *set_name,
  char  *set_rev,
  int  level,
  char  *storage,
  char  *node,
  char  *user,
  char  *passwd,
  char  *path);

extern int dba_nfm_set_local_file_manager(
  int  state);

extern int dba_nfm_set_workflow(
  int  state);

extern int dba_nfm_signoff(
  char  *catalog,
  char  *name,
  char  *rev);

extern int dba_nfm_unlock_item(
  char  *catalog,
  char  *name,
  char  *rev);

extern int dba_pan(
);

extern int dba_place_arc(
);

extern int dba_place_arrow(
);

extern int dba_place_circle(
);

extern int dba_place_ellipse(
);

extern int dba_place_filled_circle(
);

extern int dba_place_filled_ellipse(
);

extern int dba_place_filled_rectangle(
);

extern int dba_place_filled_shape(
);

extern int dba_place_freehand(
);

extern int dba_place_line(
);

extern int dba_place_rectangle(
);

extern int dba_place_shape(
);

extern int dba_place_symbol(
);

extern int dba_place_text(
);

extern int dba_playback (
  char  *filename);

extern int dba_plot_window(
);

extern int dba_pop_to_bottom (
  char  *menu);

extern int dba_pop_to_top (
  char  *menu);


extern int dba_pop_to_topmost (
  char  *menu);


extern int dba_previous_row (
);

extern int dba_print_file (
  char  *filename);

extern int dba_print_line (
  char  *text_ptr);

extern int dba_print_message (
  char  *msg);

extern int dba_print_prompt (
  char  *prompt_text);

extern int dba_print_status (
  char  *status_text);










extern dba_process (
);


extern int dba_process_default_report (
  char  *schema,
  char  *table,
  char  *sort,
  char  *output,
  char  *where,
  int  display);

extern int dba_process_doc_list (
  char  *menu,
  int  label);

extern int dba_process_menu (
  char  *templib,
  char  *menu_name,
  char  *schema,
  char  *schema_list,
  char  *table);


extern int dba_process_query (
  char  *menu,
  long  *rows_found,
  int  order_flag,
  char  *order);

extern int dba_process_report (
  char  *templib,
  char  *rtbnam,
  char  *schema,
  char  *schema_list,
  char  *output_ptr,
  char  *text_ptr,
  char  *p0,
  char  *p1,
  char  *p2,
  char  *p3,
  char  *p4,
  char  *p5);

extern int dba_process_script (
  char  *script_template);


extern int dba_process_sql_template (
  char  *library,
  char  *template);

extern int dba_purge_function (
  char  *name);

extern int dba_put_field (
  char  *menu,
  int  label,
  int  row,
  int  col,
  char  *buf);

extern int dba_quit(
);

extern int dba_raster_fence(
);

extern int dba_raster_fence_multi(
);

extern int dba_read_schema (
  char  *schema,
  char  *file);

extern int dba_rebuild_menu (
  char  *name_ptr);

extern int dba_red_draw_ann_text(
);

extern int dba_red_draw_arc(
);

extern int dba_red_draw_arrow(
);

extern int dba_red_draw_circle(
);

extern int dba_red_draw_ellipse(
);

extern int dba_red_draw_filled_circle(
);

extern int dba_red_draw_filled_ellipse(
);

extern int dba_red_draw_filled_rectangle(
);

extern int dba_red_draw_filled_shape(
);

extern int dba_red_draw_freehand(
);

extern int dba_red_draw_line(
);

extern int dba_red_draw_rectangle(
);

extern int dba_red_draw_shape(
);

extern int dba_red_draw_sound_annotation(
);

extern int dba_red_draw_symbol(
);

extern int dba_red_draw_text(
);

extern int dba_red_get_unique_filename(
  char  *path,
  char  *filename,
  char  *redline_filename);




extern int dba_red_undo(
);

extern int dba_remove_fence (
);

extern int dba_remove_linkage(
);


extern int dba_report_from_file (
  char  *templib,
  char  *rtbnam,
  char  *output_ptr,
  char  *input_ptr,
  char  *p0,
  char  *p1,
  char  *p2,
  char  *p3,
  char  *p4,
  char  *p5);


extern int dba_report_from_memory (
  char  *templib,
  char  *rtbnam,
  char  *output_ptr,
  char  *input_ptr,
  int  total,
  char  *p0,
  char  *p1,
  char  *p2,
  char  *p3,
  char  *p4,
  char  *p5);


extern int dba_report_from_userdata (
  char  *templib,
  char  *rtbnam,
  char  *output_ptr,
  char  *input_ptr,
  char  *p0,
  char  *p1,
  char  *p2,
  char  *p3,
  char  *p4,
  char  *p5);

extern int dba_report_ris_error (
);



extern int dba_restore_defaults (
);





extern int dba_review (
);

extern int dba_review_element (
  char  *table,
  int  no_verify,
  int  multiple);


extern int dba_rotate(
);


extern int dba_save_default (
  struct dba_default_options  options,
  struct dba_default_list  *list,
  int  total,
  char  *library,
  int  verify_library,
  int  verify_template);


extern int dba_save_menu (
  char  *menu,
  char  *library,
  int  verify_lib,
  int  verify_menu);


extern int dba_save_query (
  char  *library,
  char  *template,
  char  *description,
  char  *schema,
  char  *table,
  char  *query_text);

extern long dba_save_redlines(
  char  *fname);

extern int dba_schema_select (
  char  *schema);



extern int dba_scroll(
);


extern int dba_select (
);









extern int dba_set_after_notify (
  int  (*after_notify)());


extern int dba_set_after_script (
  char  *menu,
  int  label,
  char  *script);

extern int dba_set_before_notify (
  int  (*before_notify)());


extern int dba_set_before_script (
  char  *menu,
  int  label,
  char  *script);

extern void dba_set_color(
  char  *color);


extern int dba_set_columns (
  char  *menu,
  int  label,
  int  mode,
  char  *columns,
  char  *names);


extern int dba_set_current_menu (
  char  *menu);


extern int dba_set_current_row (
  long  row);

extern int dba_set_dialog_title(
  Form  fpt,
  char  *title);

extern int dba_set_dload_msg_flags (
  int  info,
  int  warn,
  int  err,
  int  fatal);

extern int dba_set_flexible_args (
  int flag);

extern void dba_set_font(
  char  *font);

extern int dba_set_gadget_redraw(
  char *menu_name,
  int gadget_label,
  int flag);

extern int dba_set_invoking_menu (
  char  *menu,
  char  *invoking_menu);

extern int dba_set_key_in_mode (
  char  *menu,
  int  mode);

extern void dba_set_level(
  int  level);

extern void dba_set_line_width(
  int  line_width);


extern int dba_set_menu_script (
  char  *menu,
  char  *script);


extern int dba_set_menu_table (
  char  *menu,
  char  *schema,
  char  *table);


extern int dba_set_order (
  char  *menu,
  char  *order);


extern int dba_set_query (
  char  *library,
  char  *template);


extern int dba_set_read_write (
  char  *menu,
  char  *schema,
  char  *table,
  char  *column,
  int  write_flag);


extern int dba_set_relop (
  char  *menu,
  char  *relop);

extern void dba_set_rl_text_size(
  double  text_size);


extern int dba_set_schema_list (
  char  *text_ptr);


extern int dba_set_table_alias (
  char  *schema,
  char  *table,
  char  *alias);


extern int dba_set_table_list (
  char  *schema,
  char  *list);


extern int dba_set_table_number_by_name (
  char  *schema,
  char  *table,
  int  table_number);

extern int dba_set_verbose_mode (
  int  dload,
  int  resize,
  int  all,
  int  standard,
  int  dba,
  int  forms,
  int  nfm,
  int  ris);

extern int dba_set_verbose_off (
);

extern int dba_set_verbose_on (
);















extern int dba_setup (
  int  argc,
  char  *argv[],
  int  ms_flag,
  char  *errmsg);


extern int dba_setup_button_script(
  char *button_script);


extern long dba_setup_convert_input (
  char  *name);


extern long dba_setup_convert_output (
  char  *name);

extern void dba_setup_dbforms (
);

extern void dba_setup_dbnuc (
);

extern void dba_setup_debug (
);

extern void dba_setup_dload (
);

extern void dba_setup_gui (
);


extern int dba_setup_key_script(
  char *key_script);

extern void dba_setup_net (
);

extern void dba_setup_nfm (
);

extern void dba_setup_raster (
);

extern void dba_setup_raster (
);

extern void dba_setup_report (
);

extern void dba_setup_script (
);

extern void dba_setup_ustn (
);

extern void dba_setup_vi (
);

extern int dba_setup_vlt (
);

extern int dba_show_links(
);



extern int dba_single_report (
  char  *rtblib,
  char  *rtbnam,
  char  *schema,
  char  *schema_list,
  char  *table,
  char  *output,
  char  *where_clause,
  char  *p0,
  char  *p1,
  char  *p2,
  char  *p3,
  char  *p4,
  char  *p5);


extern int dba_sql (
);






extern int dba_table_select (
  char  *schema,
  char  *table);

extern int dba_template_type_from_number (
  char  *ctype,
  int  itype);












extern int dba_update(
);


extern int dba_update_active (
);


extern int dba_update_row (
);

extern int dba_upper (
  char  *text_ptr);

extern void dba_wait_cursor (
  int  flag);

extern int dba_window(
);

extern int dba_window_area(
  int  file_id,
  int  x1,
  int  y1,
  int  x2,
  int  y2);

extern int dba_window_center(
);

extern int dba_window_name(
  int  file_id,
  char  *name);


extern int dba_write_schema (
  char  *schema,
  char  *file);

extern int dba_zoom_in(
);

extern int dba_zoom_out(
);

#endif
