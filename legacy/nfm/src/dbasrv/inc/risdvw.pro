#ifndef risdvw_pro
#define risdvw_pro

/* From addwin.c */
extern int addwin (
  WINDOW  *display_id);

/* From all_on_off.c */
extern int dba_all_on_off (
);

/* From att_on_off.c */
extern int dba_att_on_off (
);

/* From bld_att_txt.c */
extern char *build_att_text (
  struct dba_att  *att_ptr);
extern int up_edit_ent (
  struct dba_att  **att_ptr);
extern int down_edit_ent (
  struct dba_att  **att_ptr);

/* From bld_attfld.c */
extern int dba_build_attfld (
  WINDOW  *display_id,
  char  *column);

/* From bld_entfld.c */
extern int dba_build_entfld (
  WINDOW  *display_id,
  char  *table);

/* From bld_schfld.c */
extern int dba_build_schfld (
  WINDOW  *display_id,
  int  row,
  int  col1,
  int  col2);

/* From border.c */
extern int bld_border (
  WINDOW  *display_id,
  int  low_y,
  int  low_x,
  int  hi_y,
  int  hi_x);

/* From change_line.c */
extern int change_line (
  struct dba_line  *lin_ptr);

/* From check_cond.c */
extern int dba_check_condition (
  char  *cond,
  struct dba_ent  *ent_ptr,
  struct dba_line  *lin_ptr,
  char  **cond_ptr,
  unsigned long  *cond_lng_ptr);

/* From chg_univ.c */
extern int dba_change_univ (
  struct dba_att  *att_ptr);

/* From chk_linsch.c */
extern int check_line_schema (
  struct dba_field  *fld_ptr,
  struct dba_line  *lin_ptr);

/* From clear_msg.c */
extern int dba_clear_msg (
);

/* From cnt_field.c */
extern int change_counter_field (
);

/* From code.c */
extern int dba_edit_code_form (
  struct dba_att  *att_ptr,
  char  *errtxt);
extern int paint_code (
  struct dba_att  *att_ptr);
extern int up_code (
  char  *paint);
extern int down_code (
  char  *paint);
extern int dba_find_code (
  struct dba_att  *att_ptr);
extern int write_code (
  struct dba_att  *att_ptr);
extern int dba_put_code_text (
);

/* From col_field.c */
extern int change_attribute_field (
);

/* From col_sort.c */
extern int change_attribute_sort (
  struct dba_field  *fld_ptr);

/* From columns.c */
extern int change_columns (
  int  width);

/* From date_field.c */
extern int change_date_field (
);

/* From dbe.c */
extern int database_edit (
);

/* From del_univ.c */
extern int dba_delete_univ (
);

/* From der_field.c */
extern int change_derived_field (
);

/* From der_sort.c */
extern int change_derived_sort (
  struct dba_field  *fld_ptr);

/* From disent.c */
extern int disent (
);

/* From display_rpt.c */
extern int display_temp_report (
);
extern int add_temp_display (
);
extern int paint_temp_report (
  WINDOW  *display_id);

/* From e_risdvw.c */
extern int dba_exit_risdvw (
);

/* From erase_line.c */
extern int erase_line (
  WINDOW  *display_id,
  int  row,
  int  column,
  int  numchar);

/* From error_screen.c */
extern int dba_risdvw_add_error (
  char  *message);
extern int dba_error_screen (
);
extern int dba_paint_error (
  WINDOW  *display_id,
  int  offset);

/* From field_format.c */
extern int field_format (
);

/* From get_join.c */
extern int get_join_columns (
  int  option,
  char  *join_from,
  int  from_schema,
  char  *from_entnam,
  char  *join_to,
  int  to_schema,
  char  *to_entnam,
  int  *outer_join);

/* From get_opt.c */
extern int dba_get_opt(
  int  argc,
  char  *argv[]);
extern int dba_options(
);

/* From get_user.c */
extern int get_user_input (
  int  line,
  int  start,
  int  maxlng,
  int  echo,
  WINDOW  *display_id,
  int  read_display,
  int  edit,
  int  option);
extern int rdstr (
  WINDOW  *display_id,
  int  row,
  int  column,
  int  maxlng,
  char  *text_ptr);

/* From help.c */
extern int keyboard_help (
);
extern int help (
  char  *char_ptr,
  int  from_help);
extern int cvt_key (
  int  curses_key);

/* From insert_fld.c */
extern int dba_insert_field (
);

/* From key_att.c */
extern int dba_key_attribute (
  struct dba_att  *att_ptr);

/* From list_index.c */
extern int dba_list_index (
  int  type,
  struct dba_library  *lib_ptr);

/* From list_rtblib.c */
extern int dba_list_rtblib (
  int  type);
extern int paint_templist (
  WINDOW  *display_id,
  int  first_line,
  int  last_line,
  int  line,
  int  offset);
extern char *build_temp_text (
  struct dba_temp  *temp_ptr);
extern int up_templist (
  WINDOW  *display_id,
  int  first_line,
  int  last_line,
  int  *line,
  int  *offset);
extern int down_templist (
  WINDOW  *display_id,
  int  first_line,
  int  last_line,
  int  *line,
  int  *offset);
extern int dba_delete_template (
  char  *lib,
  WINDOW  *display_id,
  char  *curtemp,
  int  type);

/* From mod_param.c */
extern int modify_parameters (
);

/* From modify_temp.c */
extern int modify_template (
);

/* From no_temptot.c */
extern int dba_no_temptot_msg (
  int  type);

/* From num_field.c */
extern int change_total_field (
);

/* From output_err.c */
extern int dba_output_error (
  char  *message);

/* From pad.c */
extern int dba_pad_underbars (
  char  *text_ptr,
  int  length);

/* From page_field.c */
extern int change_page_field (
);

/* From paint_att.c */
extern int dba_paint_attributes (
  int  dummy1,
  struct dba_ent  *ent_ptr,
  int  dummy2,
  int  dummy3,
  int  dummy4);

/* From paint_crow.c */
extern int dba_paint_current_row (
  int  dummy);

/* From paint_temp.c */
extern int dba_paint_template (
);

/* From password.c */
extern int dba_get_password (
  char  *schema,
  char  *password);

/* From pick_row.c */
extern int pick_row (
);

/* From print_msg.c */
extern int dba_print_msg (
  char  *prompt);

/* From proc_dbe.c */
extern int process_dbe (
);

/* From put_chars.c */
extern int put_chars (
  WINDOW  *display_id,
  int  msgnum,
  char  *insert,
  char  *text,
  int  maxlng,
  int  row,
  int  column,
  int  justify,
  int  atr);

/* From read_write.c */
extern int read_write_find (
);
extern int read_find (
  char  *filename);
extern int write_find (
  char  *filename);

/* From remwin.c */
extern int remwin (
  WINDOW  *display_id);

/* From report.c */
extern int report (
);

/* From risdvw_dummy.c */
extern void dba_paint_doc_list                 (
);

/* From rtb_func.c */
extern int tab (
);
extern int up_template (
);
extern int down_template (
);
extern int left_template (
);
extern int right_template (
);
extern int next_field (
);
extern int previous_field (
);
extern int dba_insert_line (
);
extern int dba_insert_att_text (
  int  entnum,
  WINDOW  *display_id,
  int  row,
  int  column,
  int  maxchr,
  char  *text_ptr);

/* From rtb_menu.c */
extern int report_template_builder (
);

/* From rtb_user.c */
extern int user_action (
  struct dba_line  *lin_ptr);
extern int up_usact (
  WINDOW  *display_id,
  int  first_line,
  int  last_line,
  int  *line,
  int  *offset,
  struct dba_usact  **cusact,
  struct dba_usact  *fusact,
  struct dba_usact  *lusact);
extern int down_usact (
  WINDOW  *display_id,
  int  first_line,
  int  last_line,
  int  *line,
  int  *offset,
  struct dba_usact  **cusact,
  struct dba_usact  *fusact);
extern int paint_usact (
  WINDOW  *display_id,
  int  first_line,
  int  last_line,
  int  offset,
  int  *usacttot,
  struct dba_usact  *fusact);
extern int user_var (
);
extern int change_user (
  struct dba_user  *user_ptr);
extern int up_user (
  WINDOW  *display_id,
  int  first_line,
  int  last_line,
  int  *line,
  int  *offset,
  struct dba_user  **cuser);
extern int down_user (
  WINDOW  *display_id,
  int  first_line,
  int  last_line,
  int  *line,
  int  *offset,
  struct dba_user  **cuser);
extern int paint_user (
  WINDOW  *display_id,
  int  first_line,
  int  last_line,
  int  offset,
  int  *usertot);
extern char *build_user_text (
  struct dba_user  *user_ptr,
  int  linnum);
extern int dba_check_existing_user_variable (
  char  *name);

/* From run_select.c */
extern int dba_run_select (
  char  *select_text);

/* From select_att.c */
extern int dba_select_attribute (
  struct dba_ent  *ent_ptr,
  int  cur_attnum,
  int  change);
extern int paint_attribute_list (
  WINDOW  *display_id,
  struct dba_ent  *ent_ptr,
  int  first_line,
  int  last_line,
  int  offset);
extern int up_attribute (
  WINDOW  *display_id,
  struct dba_ent  *ent_ptr,
  int  first_attlin,
  int  last_attlin,
  int  *attlin,
  int  *attoff);
extern int down_attribute (
  WINDOW  *display_id,
  struct dba_ent  *ent_ptr,
  int  first_attlin,
  int  last_attlin,
  int  *attlin,
  int  *attoff);

/* From select_ent.c */
extern int dba_select_entity (
);
extern int paint_entity (
  WINDOW  *display_id,
  struct dba_ent  *ent_ptr,
  int  first_line,
  int  last_line,
  int  line,
  int  offset,
  int  paint_schema);
extern int up_entity (
  WINDOW  *display_id,
  int  first_entlin,
  int  last_entlin,
  int  *entlin,
  int  *entoff);
extern int down_entity (
  WINDOW  *display_id,
  int  first_entlin,
  int  last_entlin,
  int  *entlin,
  int  *entoff);

/* From sort.c */
extern int modify_sort (
);
extern int paint_sort (
);
extern int up_sort (
);
extern int down_sort (
);
extern int insert_sort_line (
);

/* From sql.c */
extern int dba_sql_screen (
);
extern int up_sql (
  WINDOW  *display_id,
  int  first_line,
  int  last_line,
  int  *line,
  int  *offset,
  struct dba_usact  **csql,
  struct dba_usact  *fsql,
  struct dba_usact  *lsql);
extern int down_sql (
  WINDOW  *display_id,
  int  first_line,
  int  last_line,
  int  *line,
  int  *offset,
  struct dba_usact  **csql,
  struct dba_usact  *fsql);
extern int paint_sql (
  WINDOW  *display_id,
  int  first_line,
  int  last_line,
  int  offset,
  int  *sqltot,
  struct dba_usact  *fsql);

/* From structure.c */
extern int define_structure (
  int  type);
extern int dba_insert_ua_ent (
  int  type);
extern int change_ua_ent (
  int  type);
extern int delete_ua_ent (
);
extern int undelete_ua_ent (
);
extern int dba_insert_ua_att (
  int  type);
extern int change_uds_att (
);
extern int change_asc_att (
);
extern int delete_ua_att (
);
extern int undelete_ua_att (
);

/* From temp_rpt.c */
extern int template_rpt (
);
extern int paint_tempent (
  WINDOW  *display_id,
  struct dba_ent  *ent_ptr,
  int  first_line,
  int  last_line,
  int  line,
  int  offset);
extern int up_tempent (
  WINDOW  *display_id,
  struct dba_ent  *ent_ptr,
  int  first_line,
  int  last_line,
  int  *line,
  int  *offset,
  char  *paint);
extern int down_tempent (
  WINDOW  *display_id,
  struct dba_ent  *ent_ptr,
  int  first_line,
  int  last_line,
  int  *line,
  int  *offset,
  char  *paint);

/* From text_field.c */
extern int change_text_field (
);

/* From text_sort.c */
extern int change_text_sort (
  struct dba_field  *fld_ptr);

/* From time_field.c */
extern int change_time_field (
);

/* From touchall.c */
extern int touchall (
);

/* From univ_rev.c */
extern int dba_univ_review (
);
extern int dba_review_total (
);
extern int dba_review_output (
  char  *string,
  int  length,
  int  row,
  int  column);
extern int write_review (
  char  *title);
extern int paint_review (
  int  columns);

/* From up_down_row.c */
extern int up_row (
  int  *row_ptr,
  char  *list_ptr);
extern int down_row (
  int  *row_ptr,
  char  *list_ptr);

/* From up_lintxt.c */
extern int update_line_text (
  struct dba_line  *lin_ptr,
  int  line);

/* From up_status.c */
extern int update_status_line (
);

/* From verify.c */
extern int get_verify (
  char  *prompt);

/* From yes_no.c */
extern int dba_yes_no (
  long  msgnum,
  char  *insert_ptr,
  int  red);

#endif
