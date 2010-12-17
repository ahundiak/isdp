#ifndef report_pro
#define report_pro

/* From add_outjoin.c */
extern int dba_add_outjoin (
  struct dba_ent  *ent_ptr,
  struct dba_outjoin  *outjoin_ptr);

/* From add_repatt.c */
extern int dba_add_repatt (
  struct dba_ent  *ent_ptr,
  struct dba_repatt  *repatt_ptr);

/* From add_user.c */
extern int dba_add_user_var (
  struct dba_user  **cuser,
  struct dba_user  *tuser);
extern int dba_remove_user_var (
  struct dba_user  **cuser);

/* From all_rpttab.c */
extern int dba_all_report_tables (
  char  *library,
  char  *template,
  char  ***schema,
  char  ***table,
  int  *total);
extern int dba_report_table_list (
  char  **sch_ptr,
  char  **tab_ptr,
  int  *size,
  int  *numtabs,
  int  schema,
  char  *table);

/* From auto_wrap.c */
extern int dba_wrap_line (
  struct dba_ent  *ent_ptr,
  struct dba_line  *lin_ptr,
  int  *more);
extern int dba_wrap_field (
  struct dba_field  *fld_ptr,
  char  *text,
  int  *wrapped,
  int  *again);

/* From clear_groups.c */
extern int dba_clear_groups (
);

/* From convert.c */
extern int dba_convert_fraction (
  char  *text_ptr,
  int  length);
extern int dba_convert_ft_in (
  char  *text_ptr,
  int  length);

/* From copy_join.c */
extern int dba_copy_join (
  char  **mem_ptr,
  struct dba_outjoin  *outjoin,
  int  to_row,
  int  from_row,
  int  rec_length);

/* From creat_repatt.c */
extern int dba_create_repatt (
  struct dba_ent  *ent_ptr,
  struct dba_field  *fld_ptr,
  int  schema,
  char  *entnam,
  char  *attnam,
  int  total_flag,
  struct dba_repatt  **repatt);
extern int dba_create_sort_repatt (
  struct dba_ent  *ent_ptr,
  struct dba_field  *fld_ptr,
  struct dba_repatt  **repatt);
extern int dba_set_repatt_join (
  struct dba_ent  *ent_ptr,
  struct dba_repatt  *rep_ptr,
  struct dba_field  *fld_ptr);

/* From creat_setatt.c */
extern int dba_create_outjoin (
  struct dba_ent  *ent_ptr,
  struct dba_field  *fld_ptr,
  struct dba_repatt  *repatt);
extern int dba_create_join_repatt (
  struct dba_ent  *ent_ptr,
  int  schema,
  int  entnum,
  char  *attnam,
  struct dba_repatt  **repatt,
  int  from);

/* From create_ab_bb.c */
extern int dba_create_ab_bb (
);

/* From create_user.c */
extern int dba_create_user_var (
  struct dba_user  *tuser);
extern int dba_delete_user_var (
  struct dba_user  *tuser);

/* From create_var.c */
extern int dba_create_sys_var (
);

/* From date_time.c */
extern char *dba_date_time (
  struct dba_field  *fld_ptr);

/* From db_rpt.c */
extern int dba_database_report (
);
extern int dba_copy_rpt_row (
);
extern int dba_realloc_rptmem (
);
extern int dba_sort_timestamp (
);
extern void dba_convert_repatt (
);
extern int dba_parse_where_text (
);
extern int dba_malloc_entnam (
);

/* From delete_ab_bb.c */
extern int dba_delete_ab_bb (
);

/* From delimnum.c */
extern int dba_delimit_report_number (
  char  *string,
  int  length);

/* From drpt_f_f.c */
extern int dba_format_default_from_file (
  char  *library,
  char  *structure_template,
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

/* From exec_defrpt.c */
extern int dba_execute_default (
  struct dba_default_options  options,
  struct dba_default_list  *list,
  int  total,
  int  process,
  char  *where,
  int  display);

/* From exit_rpt.c */
extern int dba_exit_report (
);

/* From fld_justify.c */
extern int dba_set_field_justify (
  int  line,
  int  field,
  int  justify);

/* From form_defrpt.c */
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
extern int dba_do_format_default (
  struct dba_ent  *tent,
  char  *columns,
  int  include,
  char  *sort,
  int  width,
  int  counter,
  int  spacing,
  struct dba_default_options  *options,
  struct dba_default_list  **list,
  int  *count);
extern int dba_add_default_column (
  struct dba_att  *att_ptr,
  int  *count,
  int  *start,
  char  *sort,
  int  *high_sort,
  int  *totals,
  int  counter,
  int  spacing,
  struct dba_default_list  **list,
  int  *list_size,
  int  *width);

/* From formula.c */
extern int dba_process_formula (
  struct dba_formula  *form,
  union dba_mixed  *value_ptr,
  int  mode);
extern struct dba_formula *dba_parse_formula (
  char  *text_ptr,
  struct dba_ent  *ent_ptr,
  struct dba_line  *lin_ptr,
  int  mode,
  int  cvt_upper,
  int  assign);
extern int dba_check_formula (
  char  *text_ptr,
  struct dba_ent  *ent_ptr,
  struct dba_line  *lin_ptr,
  int  mode,
  int  cvt_upper,
  int  assign);

/* From get_justify.c */
extern int dba_get_justify (
  struct dba_field  *fld_ptr,
  int  *justify);

/* From get_numfld.c */
extern int dba_get_numeric_field_value (
  struct dba_field  *fld_ptr,
  double  *value);

/* From i_report.c */
extern int dba_init_report (
);

/* From init_rpt.c */
extern int dba_initialize_report (
  int  *rec_length);
extern int dba_init_rptent (
  struct dba_sch  *sch_ptr);

/* From init_temp.c */
extern int dba_clear_report (
);

/* From join_rpt.c */
extern int dba_join_rpt (
  struct dba_outjoin  *outjoin,
  char  *ptr_occ,
  char  **mem_ptr,
  unsigned long  *mem_size,
  long  *univ_size,
  int  rec_length,
  long  from_row);
extern void dba_load_join_rpt (
  struct dba_outjoin  *outjoin,
  char  *ptr_occ);

/* From load_rpt.c */
extern int dba_load_rpt (
  char  *library,
  char  *template);
extern int dba_get_report_header (
  struct dba_library  *lib_ptr,
  struct dba_rpt_hdr  *hdr_ptr);
extern int dba_parse_line_script (
  struct dba_line  *lin_ptr,
  int  after,
  int  first);

/* From load_struct.c */
extern int dba_load_structure (
  char  *library,
  char  *template);
extern int dba_set_att_atyp (
  struct dba_att  *tatt);

/* From mal_rpt.c */
extern int dba_malloc_line (
  struct dba_line  **lin_ptr,
  struct dba_line  *in_lin_ptr);
extern int dba_free_line (
  struct dba_line  **lin_ptr);
extern int dba_malloc_field (
  struct dba_field  **fld_ptr,
  struct dba_field  *in_fld_ptr);
extern int dba_free_field (
  struct dba_field  **fld_ptr);
extern int dba_malloc_user_var (
  struct dba_user  **user_ptr,
  struct dba_user  *in_user_ptr);
extern int dba_free_user_var (
  struct dba_user  **user_ptr);
extern int dba_malloc_key (
  struct dba_key  **key_ptr,
  struct dba_key  *in_key_ptr);
extern int dba_free_key (
  struct dba_key  **key_ptr);

/* From new_page.c */
extern int dba_new_page (
);

/* From parcom_form.c */
extern int dba_parse_compile_formula (
  char  *text_ptr,
  struct dba_ent  *ent_ptr,
  struct dba_line  *lin_ptr,
  int  mode,
  int  cvt_upper,
  int  assign,
  struct dba_formula  **formula,
  char  *prefix,
  int  line,
  int  type);

/* From parcom_user.c */
extern int dba_parse_compile_user (
  char  *text_ptr,
  struct dba_ent  *ent_ptr,
  struct dba_line  *lin_ptr,
  struct dba_group  **group,
  char  *prefix,
  int  line,
  int  type);

/* From print_line.c */
extern int dba_print_line (
  char  *text_ptr);

/* From print_tbnl.c */
extern int dba_print_top (
  struct dba_ent  *ent_ptr,
  struct dba_line  *lin_ptr);
extern int dba_print_bottom (
  struct dba_ent  *ent_ptr,
  struct dba_line  *lin_ptr);
extern int dba_new_line (
  struct dba_ent  *ent_ptr,
  struct dba_line  *lin_ptr);

/* From proc_ascii.c */
extern int dba_process_ascii (
  char  **mem_ptr,
  unsigned long  *mem_size,
  int  rec_length,
  char  *filnam,
  long  *univ_size);

/* From proc_binary.c */
extern int dba_process_binary (
  char  **mem_ptr,
  unsigned long  *mem_size,
  int  rec_length,
  char  *input_ptr,
  long  *univ_size);

/* From proc_defrpt.c */
extern int dba_process_default_report (
  char  *schema,
  char  *table,
  char  *sort,
  char  *output,
  char  *where,
  int  display);

/* From proc_rpt.c */
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

/* From prorun_form.c */
extern int dba_process_run_formula (
  char  *text_ptr,
  struct dba_formula  *formula,
  union dba_mixed  *value_ptr,
  int  mode);

/* From prorun_user.c */
extern int dba_process_run_user (
  struct dba_group  *group,
  struct dba_line  *lin_ptr,
  struct dba_ent  *ent_ptr);

/* From prrptscr.c */
extern long dba_compile_report_script (
  char  *script_template,
  char  *prefix,
  long  line,
  long  type,
  struct dba_ent  *ent_ptr,
  struct dba_line  *line_ptr,
  functiontype  **func_ptr);
extern long dba_run_report_script (
  char  *script_template,
  functiontype  *func_ptr);

/* From reg_rpt.c */
extern int dba_register_report(
);

/* From report_table.c */
extern int dba_change_report_table (
  struct dba_ent  *ent_ptr);

/* From reset_update.c */
extern int dba_update_fields (
  int  entnum);
extern int dba_reset_fields (
);

/* From reset_var.c */
extern int dba_reset_sys_var (
  char  *p0,
  char  *p1,
  char  *p2,
  char  *p3,
  char  *p4,
  char  *p5);
extern int dba_reset_user_var (
  struct dba_user  *tuser);

/* From rpt_file.c */
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

/* From rpt_fltr.c */
extern int dba_set_report_filter (
  int  (*report_filter)());

/* From rpt_memory.c */
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

/* From rpt_table.c */
extern int dba_get_report_table (
  char  *library,
  char  *template,
  char  *schema,
  char  *table);

/* From rpt_userdata.c */
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

/* From rpt_util.c */
extern int dba_util_execute_default (
  struct dba_default_options  *options,
  struct dba_default_list  *list,
  int  total,
  int  process,
  char  *where,
  int  display);
extern int dba_util_save_default (
  struct dba_default_options  *options,
  struct dba_default_list  *list,
  int  total,
  char  *library,
  int  verify_library,
  int  verify_template);

/* From rptents.c */
extern int dba_rebuild_rptents (
);

/* From rptscrer.c */
extern void dba_compile_report_script_error (
  char  *prefix,
  long  line,
  long  type);
extern int dba_run_report_script_error (
  functiontype  *function);

/* From s_evlrpt.c */
extern long dba_s_eval_rpt (
  functiontype  *bfunc,
  functiontype  *function,
  long  opnum);

/* From s_report.c */
extern void dba_setup_report (
);

/* From s_sglrpt.c */
extern long dba_s_single_report (
  functiontype  *bfunc,
  functiontype  *function,
  long  opnum);

/* From save_defrpt.c */
extern int dba_save_default (
  struct dba_default_options  options,
  struct dba_default_list  *list,
  int  total,
  char  *library,
  int  verify_library,
  int  verify_template);

/* From set_fld_ptr.c */
extern int dba_set_fld_ptr (
  int  line,
  int  field,
  struct dba_field  **fld_ptr);

/* From set_lin_ptr.c */
extern int dba_set_lin_ptr (
  int  line,
  struct dba_line  **lin_ptr);

/* From set_sort.c */
extern int dba_set_sort_line (
  struct dba_line  **fsline,
  struct dba_line  **lsline,
  int  schema,
  int  entnum,
  struct dba_line  **lin_ptr);

/* From single_rpt.c */
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

/* From specvars.c */
extern long dba_check_special_vars (
  functiontype  *function,
  char  *operand);
extern long dba_scr_handle_f_vars (
  void  *addr,
  smm_generic_list  *list);
extern long dba_scr_handle_c_vars (
  void  *addr,
  smm_generic_list  *list);
extern long dba_scr_handle_n_vars (
  void  *addr,
  smm_generic_list  *list);

/* From total_pages.c */
extern void dba_total_pages (
  int  option,
  int  start,
  int  length);

/* From ud_bin_rec.c */
extern int dba_ud_bin_record (
  char  *buffer,
  char  **mem_ptr,
  unsigned long  *mem_size,
  int  rec_length,
  long  *univ_size,
  int  *lng);

/* From user_action.c */
extern int dba_process_group (
  struct dba_group  *grp_ptr,
  struct dba_line  *lin_ptr,
  struct dba_ent  *ent_ptr);
extern int dba_process_user (
  struct dba_line  *lin_ptr,
  struct dba_ent  *ent_ptr);
extern struct dba_group *dba_parse_user (
  char  *text_ptr,
  struct dba_ent  *ent_ptr,
  struct dba_line  *lin_ptr);
extern int dba_check_user (
  struct dba_ent  *ent_ptr,
  struct dba_line  *lin_ptr);
extern int dba_check_before_after_user (
  struct dba_ent  *ent_ptr,
  struct dba_line  *lin_ptr,
  int  before_after);

/* From user_var.c */
extern struct dba_user *dba_process_user_var (
  char  *user_name,
  int  *lng_ptr);
extern struct dba_user *dba_check_user_var (
  char  *user_name);

/* From var_start.c */
extern int dba_set_variable_start (
  int  line,
  int  field,
  char  *formula);

/* From write_line.c */
extern int dba_write_line (
  struct dba_ent  *ent_ptr,
  struct dba_line  *lin_ptr);
extern int dba_rpt_fputs (
  char  *text);
extern int dba_write_justified_text (
  char  *s1_ptr,
  char  *s2_ptr,
  struct dba_field  *tfield);

/* From write_report.c */
extern int dba_write_report (
  char  *mem_ptr,
  long  univ_size,
  int  rec_length);

/* From write_rpt.c */
extern int dba_write_rpt (
  char  *library,
  char  *template,
  int  verify_lib,
  int  verify_temp);
extern int dba_strcat (
  char  *char_ptr);
extern int dba_write_line_script (
  struct dba_line  *tline,
  struct dba_library  *templib);

#endif
