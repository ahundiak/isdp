#ifndef dba_proto_h
#define dba_proto_h

extern dba_abort (
);

extern dba_active_position (
  int  *row,
  int  *col);

extern dba_add_query (
  char  *logical,
  char  *schema,
  char  *entnam,
  char  *attnam,
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

extern int dba_attach_dap_link (
);

extern int dba_attach_file_link(
);

extern int dba_attach_linkage (
);

extern int dba_attach_note(
);

extern int dba_cancel (
  char  *menu);

extern int dba_change_all (
);


extern int dba_change_row (
);

extern int dba_close_cursor (
);

extern int dba_compile_script (
  char  *name);

extern int dba_delete_all (
);


extern int dba_delete_from_table_list (
  char  *schema,
  char  *table);

extern int dba_delete_menu (
  char  *menu);

extern int dba_delete_row (
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


extern int dba_edit_code (
);



extern int dba_exit_graphics(
  int  file_id);

extern int dba_fetch (
);


extern int dba_fields_on_off (
);

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

extern int dba_get_code_number (
  char  *schema,
  char  *table,
  char  *column,
  int  *code_number,
  char  *code_text);

extern int dba_get_code_text (
  char  *schema,
  char  *table,
  char  *column,
  int  code_number,
  char  *code_text);

extern int dba_get_column_value (
  char  *schema,
  char  *table,
  char  *column,
  char  *value);

extern int dba_get_current_column (
  char  *schema,
  char  *table,
  char  *column);

extern int dba_get_current_row (
  int  *row);

extern int dba_get_extents(
  int  file_id,
  int  *width,
  int  *height);



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

extern int dba_get_menu_by_name (
  char  *menu,
  Form  *form,
  int  *label);

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

extern int dba_get_table_number_by_name (
  char  *schema,
  char  *table,
  int  *table_number);

extern int dba_get_yes_no (
  char  *question,
  int  color);

extern int dba_init_table_query (
  char  *schema,
  char  *table);

extern int dba_initialize_query (
);

extern int dba_insert_row (
);

extern int dba_load_file(
);

extern int dba_locate_graphics (
  int  set,
  int  mode,
  int  view,
  double  zoom,
  int  blink);

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

extern int dba_nfm_add_acl(
  char  *wfname,
  char  *aclname);

extern int dba_nfm_add_acl_user(
  char  *aclname,
  char  *class,
  char  *user,
  char  *wfname);

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
  char  *storage);

extern int dba_nfm_add_item(
  char  *catalog,
  char  *name,
  char  *rev,
  char  *desc,
  int  aclno,
  int  version_limit,
  int  cisano,
  char  *filename);

extern int dba_nfm_add_item(
  char  *catalog,
  char  *name,
  char  *rev,
  char  *desc,
  int  aclno,
  int  version_limit,
  int  cisano,
  char  *filename);

extern int dba_nfm_add_list_to_set(
  char  *catalog,
  char  *set_name,
  char  *set_rev);

extern int dba_nfm_add_list_to_set(
  char  *catalog,
  char  *set_name,
  char  *set_rev);

extern int dba_nfm_add_multi(
  char  *filename);

extern int dba_nfm_add_multi(
  char  *filename);

extern int dba_nfm_add_set(
  char  *catalog,
  char  *set_name,
  char  *set_rev,
  char  *desc,
  int  aclno,
  int  version_limit,
  int  cisano);

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
  char  *type);

extern int dba_nfm_add_storage_area(
  char  *storage,
  char  *node,
  char  *user,
  char  *passwd,
  char  *path,
  char  *type);

extern int dba_nfm_add_to_set(
  char  *catalog,
  char  *set_name,
  char  *set_rev,
  char  *name,
  char  *rev,
  char  *type);

extern int dba_nfm_add_to_set(
  char  *catalog,
  char  *set_name,
  char  *set_rev,
  char  *name,
  char  *rev,
  char  *type);

extern int dba_nfm_add_user(
  char  *user,
  char  *passwd,
  char  *desc,
  char  *path);

extern int dba_nfm_add_user(
  char  *user,
  char  *passwd,
  char  *desc,
  char  *path);

extern int dba_nfm_add_user_catalog(
  char  *name,
  char  *type,
  char  *synonym);

extern int dba_nfm_add_user_catalog(
  char  *name,
  char  *type,
  char  *synonym);

extern int dba_nfm_add_user_data(
  char  *name,
  char  *value);

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
  char  *filename);

extern int dba_nfm_add_user_item(
  char  *catalog,
  char  *name,
  char  *rev,
  char  *desc,
  int  aclno,
  int  version_limit,
  int  cisano,
  char  *filename);

extern int dba_nfm_build_set_list(
  char  *name,
  char  *rev,
  char  *type);

extern int dba_nfm_build_set_list(
  char  *name,
  char  *rev,
  char  *type);

extern int dba_nfm_cancel_item(
  char  *catalog,
  char  *name,
  char  *rev);

extern int dba_nfm_cancel_item(
  char  *catalog,
  char  *name,
  char  *rev);

extern int dba_nfm_cancel_item_archive(
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

extern int dba_nfm_cancel_item_backup(
  char  *catalog,
  char  *name,
  char  *rev);

extern int dba_nfm_cancel_item_delete(
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

extern int dba_nfm_cancel_item_restore(
  char  *catalog,
  char  *name,
  char  *rev);

extern int dba_nfm_cancel_set(
  char  *catalog,
  char  *set_name,
  char  *set_rev);

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

extern int dba_nfm_change_sa_passwd(
  char  *storage,
  char  *old_passwd,
  char  *new_passwd);

extern int dba_nfm_change_sa_passwd(
  char  *storage,
  char  *old_passwd,
  char  *new_passwd);

extern int dba_nfm_change_user_passwd(
  char  *user,
  char  *passwd,
  char  *new_passwd);

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

extern int dba_nfm_create_catalog(
  char  *catalog,
  char  *desc,
  int  aclno);

extern int dba_nfm_create_catalog(
  char  *catalog,
  char  *desc,
  int  aclno);

extern int dba_nfm_create_user_catalog(
  char  *catalog,
  char  *desc,
  int  aclno);

extern int dba_nfm_create_user_catalog(
  char  *catalog,
  char  *desc,
  int  aclno);

extern int dba_nfm_delete_acl_user(
  char  *aclname,
  char  *class,
  char  *user,
  char  *wfname);

extern int dba_nfm_delete_acl_user(
  char  *aclname,
  char  *class,
  char  *user,
  char  *wfname);

extern int dba_nfm_delete_catalog(
  char  *catalog);

extern int dba_nfm_delete_catalog(
  char  *catalog);

extern int dba_nfm_delete_file(
  char  *catalog,
  char  *name,
  char  *rev,
  char  *filename);

extern int dba_nfm_delete_item(
  char  *catalog,
  char  *name,
  char  *rev);

extern int dba_nfm_delete_item(
  char  *catalog,
  char  *name,
  char  *rev);

extern int dba_nfm_delete_storage_area(
  char  *storage);

extern int dba_nfm_delete_storage_area(
  char  *storage);

extern int dba_nfm_delete_user(
  char  *user);

extern int dba_nfm_delete_user(
  char  *user);

extern int dba_nfm_drop_from_set(
  char  *catalog,
  char  *set_name,
  char  *set_rev,
  char  *item_name,
  char  *item_rev);

extern int dba_nfm_drop_from_set(
  char  *catalog,
  char  *set_name,
  char  *set_rev,
  char  *item_name,
  char  *item_rev);

extern int dba_nfm_drop_set(
  char  *catalog,
  char  *set_name,
  char  *set_rev);

extern int dba_nfm_drop_set(
  char  *catalog,
  char  *set_name,
  char  *set_rev);

extern int dba_nfm_flag_item_archive(
  char  *catalog,
  char  *name,
  char  *rev);

extern int dba_nfm_flag_item_archive(
  char  *catalog,
  char  *name,
  char  *rev);

extern int dba_nfm_flag_item_backup(
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

extern int dba_nfm_flag_item_delete(
  char  *catalog,
  char  *name,
  char  *rev);

extern int dba_nfm_flag_item_restore(
  char  *catalog,
  char  *name,
  char  *rev);

extern int dba_nfm_flag_item_restore(
  char  *catalog,
  char  *name,
  char  *rev);

extern int dba_nfm_get_message(
  char  *message);

extern int dba_nfm_get_message(
  char  *message);

extern int dba_nfm_load_workflow(
  char  *app,
  char  *wfname);

extern int dba_nfm_load_workflow(
  char  *app,
  char  *wfname);

extern int dba_nfm_login(
  char  *server,
  char  *user,
  char  *passwd,
  char  *environment,
  int  debug);

extern int dba_nfm_login(
  char  *server,
  char  *user,
  char  *passwd,
  char  *environment,
  int  debug);

extern int dba_nfm_logout(
);

extern int dba_nfm_logout(
);

extern int dba_nfm_make_transition(
  char  *catalog,
  char  *name,
  char  *rev,
  char  *state);

extern int dba_nfm_make_transition(
  char  *catalog,
  char  *name,
  char  *rev,
  char  *state);

extern int dba_nfm_set_checkin(
  char  *catalog,
  char  *set_name,
  char  *set_rev,
  char  *storage,
  char  *node,
  char  *user,
  char  *passwd,
  char  *path);

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


extern int dba_pan(
);

extern int dba_playback (
  char  *filename);

extern int dba_plot_window(
);

extern int dba_pop_to_bottom (
  char  *menu);

extern int dba_pop_to_top (
  char  *menu);

extern int dba_previous_row (
);

extern int dba_print_line (
  char  *text_ptr);

extern int dba_print_message (
  char  *msg);

extern int dba_print_prompt (
  char  *prompt_text);

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

extern int dba_process_query (
  char  *menu,
  int  *rows_found,
  int  order_flag,
  char  *order);



extern int dba_process_script (
  char  *script_template);

extern int dba_process_sql_template (
  char  *library,
  char  *template);

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

extern int dba_rebuild_menu (
  char  *name_ptr);

extern int dba_remove_fence (
);


extern int dba_remove_linkage(
);


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


extern int dba_save_menu (
  char  *menu,
  char  *library,
  int  verify_lib,
  int  verify_menu);

extern int dba_schema_select (
  char  *schema);



extern int dba_scroll(
);

extern int dba_select (
);




extern int dba_set_after_script (
  char  *menu,
  int  label,
  char  *script);

extern int dba_set_before_script (
  char  *menu,
  int  label,
  char  *script);

extern int dba_set_columns (
  char  *menu,
  int  label,
  int  mode,
  char  *columns,
  char  *names);

extern int dba_set_current_menu (
  char  *menu);

extern int dba_set_current_row (
  int  row);

extern int dba_set_invoking_menu (
  char  *menu,
  char  *invoking_menu);

extern int dba_set_key_in_mode (
  char  *menu,
  int  mode);

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

extern int dba_set_schema_list (
  char  *text_ptr);

extern int dba_set_table_list (
  char  *schema,
  char  *list);

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
    char  *sqlptr);


extern int dba_table_select (
  char  *schema,
  char  *table);







extern int dba_update(
);


extern int dba_update_active (
);


extern int dba_window(
);


extern int dba_window_area(
  int  file_id,
  int  x1,
  int  y1,
  int  x2,
  int  y2);

extern int dba_zoom_in(
);

extern int dba_zoom_out(
);

#endif
