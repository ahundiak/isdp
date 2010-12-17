#ifndef dbnuc_pro
#define dbnuc_pro

/* From a_selcol.c */
extern int dba_add_selected_columns (
  struct dba_ent  **ent_ptr,
  char  *select_text,
  struct dba_gadget  *gadg,
  int  *count);

/* From add_att.c */
extern int dba_add_att_ptr (
  struct dba_ent  *ent_ptr,
  struct dba_att  *new_att,
  struct dba_att  *cur_att);

/* From add_column.c */
extern int dba_add_column (
  struct dba_ent  *ent_ptr,
  struct dba_att  *att_ptr);

/* From add_ent.c */
extern int dba_add_ent_ptr (
  struct dba_ent  **fent,
  struct dba_ent  **lent,
  struct dba_ent  *new_ent,
  struct dba_ent  *cur_ent);

/* From add_find.c */
extern int dba_add_find (
  char  *logical,
  struct dba_att  *att_ptr,
  char  *relop);

/* From add_fnd_ptr.c */
extern int dba_add_find_ptr (
  struct dba_find  **ffind_ptr,
  struct dba_find  **lfind_ptr,
  struct dba_find  *find_ptr);

/* From add_qry_str.c */
extern int dba_add_query_string (
  char  *logical,
  char  *schema,
  char  *table,
  char  *value);

/* From add_schema.c */
extern int dba_add_schema (
  char  *schema_name);

/* From add_table.c */
extern int dba_add_to_table_list (
  char  *schema,
  char  *table);

/* From att_db.c */
extern int dba_attach_db (
  char  *schema,
  int  msg);

/* From attach_sch.c */
extern int dba_attach_schema (
  int  schema,
  int  msg);

/* From attached.c */
extern int dba_attached (
  char  **sch_ptr);

/* From bld_att.c */
extern int dba_build_att (
  struct dba_ent  *ent_ptr,
  int  schema);
extern int dba_get_ris_text_column_length (
  char  *table,
  char  *column,
  int  *length);

/* From bld_ent.c */
extern int dba_build_ent (
  struct dba_sch  *sch_ptr);

/* From bld_wher_txt.c */
extern int dba_build_where_text (
  char  **s1_ptr,
  unsigned long  *s1_size,
  int  mnunum);

/* From branch.c */
extern int dba_select (
);
extern int dba_close_cursor (
);
extern int dba_sql (
);
extern int dba_exec_sql (
);
extern int dba_prepare_sql (
);
extern int dba_report_ris_error (
);

/* From build_where.c */
extern int dba_build_where (
  struct dba_ent  *ent_ptr,
  int  *got_where,
  int  fence,
  int  create_flag,
  char  **s1_ptr,
  unsigned long  *s1_size,
  int  from_report);
extern int dba_check_for_clause (
  char  *in_text);

/* From chk_rel.c */
extern int dba_check_relations (
  char  *template,
  int  from_schema,
  char  *from_table,
  int  to_schema,
  char  *to_table);

/* From chk_tab.c */
extern int dba_check_for_table (
  int  schema,
  char  *tabnam);

/* From clr_schlst.c */
extern int dba_clear_schema_list (
);

/* From code_num.c */
extern int dba_get_code_number (
  char  *schema,
  char  *table,
  char  *column,
  long  *code_number,
  char  *code_text);

/* From codelist.c */
extern int dba_init_codelist (
  struct dba_sch  *sch_ptr);
extern int dba_add_coded_column (
  struct dba_sch  *sch_ptr,
  char  *table_name,
  char  *column_name,
  char  *join_table,
  char  *code_column,
  char  *text_column,
  char  *index_column,
  long  index_value);
extern int dba_find_codelist (
  int  schema,
  char  *tabname,
  char  *colname,
  struct dba_code_list  **cl_ptr);
extern int dba_find_codeval (
  long  code_number,
  int  schema,
  char  *tabname,
  char  *colname,
  char  *code_text,
  int  *alen);
extern int dba_find_codenum (
  long  *code_number,
  int  schema,
  char  *tabname,
  char  *colname,
  char  *code_text);

/* From current_col.c */
extern int dba_get_current_column (
  char  *schema,
  char  *table,
  char  *column);

/* From cvt_date.c */
extern int dba_convert_date (
  char  *out,
  char  *in);

/* From cvt_in.c */
extern int dba_process_convert_input (
  int  schema,
  int  table,
  int  column,
  char  *text,
  int  length);

/* From cvt_out.c */
extern int dba_process_convert_output (
  int  schema,
  int  table,
  int  column,
  char  *text,
  int  length);

/* From dba_check.c */
extern int dba_check_name (
  char  *text_ptr,
  int  ntype);
extern int dba_check_number (
  char  *text_ptr,
  int  *itmp);
extern int dba_check_bitoff (
  int  alen,
  int  *itmp);

/* From dbd_add_qry.c */
extern int dba_add_query (
  char  *logical,
  char  *schema,
  char  *table,
  char  *column,
  char  *relop,
  char  *attval);

/* From dbd_init_qry.c */
extern int dba_initialize_query (
);

/* From dbd_ris_err.rc */
extern int dba_ris_report_ris_error (
);

/* From dbd_schema.c */
extern int dba_schema_select (
  char  *schema);

/* From dbd_select.rc */
extern int dba_ris_select (
);
extern int dba_ris_close_cursor (
);
extern int dba_scr_close_cursor0 (
);
extern int dba_scr_close_cursor1 (
);
extern int dba_scr_close_cursor2 (
);
extern int dba_scr_close_cursor3 (
);
extern int dba_scr_close_cursor4 (
);
extern int dba_scr_close_cursor5 (
);
extern int dba_scr_close_cursor6 (
);
extern int dba_scr_close_cursor7 (
);
extern int dba_scr_close_cursor8 (
);
extern int dba_scr_close_cursor9 (
);
extern int dba_scr_close_cursor10 (
);

/* From dbd_table.c */
extern int dba_table_select (
  char  *schema,
  char  *table);

/* From decl_sch.c */
extern int dba_declare_schema (
  char  *schema);

/* From del_att_ptr.c */
extern int dba_delete_att_ptr (
  struct dba_att  **fatt,
  struct dba_att  **latt,
  struct dba_att  *att);

/* From del_ent_ptr.c */
extern int dba_delete_ent_ptr (
  struct dba_ent  **fent,
  struct dba_ent  **lent,
  struct dba_ent  *ent);

/* From delete_table.c */
extern int dba_delete_from_table_list (
  char  *schema,
  char  *table);

/* From desc_index.c */
extern int dba_get_desc_index (
);

/* From double_quote.c */
extern int dba_double_quote (
  char  **text,
  unsigned long  *size);

/* From ex_dbnuc.c */
extern int dba_exit_dbnuc (
);

/* From f_dbnuc.c */
extern int dba_free_dbnuc (
);

/* From flush_code.c */
extern int dba_flush_codelist (
  char  *schema,
  char  *table,
  char  *column);

/* From flush_schema.c */
extern int dba_flush_schema (
  char  *schema);

/* From flush_table.c */
extern int dba_flush_table (
  char  *schema,
  char  *table);

/* From format_chk.c */
extern int dba_format_check (
  struct dba_att  *att_ptr);

/* From g_colnam.c */
extern int dba_get_column_name_by_number (
  char  *schema,
  char  *table,
  int  column,
  char  *column_name);

/* From g_colnum.c */
extern int dba_get_column_number_by_name (
  char  *schema,
  char  *table,
  char  *column,
  int  *column_number);

/* From g_schnam.c */
extern int dba_get_schema_name_by_number (
  int  schema,
  char  *schema_name);

/* From g_schnum.c */
extern int dba_get_schema_number_by_name (
  char  *schema,
  int  *schema_number);

/* From g_tabnam.c */
extern int dba_get_table_name_by_number (
  char  *schema,
  int  table,
  char  *table_name);

/* From g_tabnum.c */
extern int dba_get_table_number_by_name (
  char  *schema,
  char  *table,
  int  *table_number);

/* From get_attnam.c */
extern int dba_get_attnam (
  char  *entnam,
  int  attnum,
  char  *text_ptr);

/* From get_atyp.c */
extern int dba_get_atyp (
  int  in_type);

/* From get_code_txt.c */
extern int dba_get_code_text (
  char  *schema,
  char  *table,
  char  *column,
  long  code_number,
  char  *code_text);

/* From get_commit.c */
extern int dba_get_autocommit(
);

/* From get_entnam.c */
extern int dba_get_entnam (
  int  entnum,
  char  *text_ptr);

/* From get_query.c */
extern int dba_get_query (
  char  *schema,
  char  *table,
  char  **query);

/* From get_rel.c */
extern int dba_get_relations (
  int  option,
  char  *template,
  char  *from_table,
  char  *to_table,
  struct dba_entnam  **fentnam,
  struct dba_entnam  **lentnam,
  struct dba_ent  *ment,
  struct dba_att  *att_ptr);
extern int dba_get_reljoins (
  struct dba_reltemp  *reltemp,
  char  *from_table,
  char  *to_table);
extern int dba_get_next_reljoins (
  struct dba_reltemp  *reltemp,
  char  *from_table,
  char  *to_table,
  char  **table_list,
  unsigned long  *table_size);
extern int dba_create_reljoin_entnam (
  int  option,
  struct dba_reltemp  *reltemp,
  char  *from_table,
  char  *to_table,
  struct dba_entnam  **fentnam,
  struct dba_entnam  **lentnam,
  struct dba_ent  *ment,
  struct dba_att  *att_ptr);
extern int dba_create_entnam (
  char  *from_table,
  char  *to_table,
  int  from_include,
  int  where_include,
  struct dba_entnam  **fentnam,
  struct dba_entnam  **lentnam,
  char  *join_from,
  char  *join_to);

/* From get_sqlc.c */
extern int dba_get_sqlcode (
);

/* From i_dbnuc.c */
extern int dba_init_dbnuc (
);

/* From init_find.c */
extern int dba_init_find (
);

/* From init_tab_qry.c */
extern int dba_init_table_query (
  char  *schema,
  char  *table);

/* From join_info.c */
extern int dba_new_join_info (
  char  *join_from,
  int  from_schema,
  char  *from_entnam,
  char  *join_to,
  int  to_schema,
  char  *to_entnam,
  char  **from_ptr,
  unsigned long  *from_lng,
  char  **to_ptr,
  unsigned long  *to_lng,
  int  *outer_ptr);

/* From key_column.c */
extern int dba_key_columns (
  char  *schema,
  struct dba_ent  *ent_ptr);

/* From load_find.c */
extern int dba_load_find (
  char  *library,
  char  *template);

/* From load_rel.c */
extern int dba_load_relations (
  char  *library,
  char  *template);
extern void dba_malloc_reltemp (
  char  *template,
  struct dba_reltemp  **reltemp);
extern void dba_malloc_reltab (
  struct dba_reltab  **reltab);
extern void dba_malloc_reljoin (
  struct dba_reljoin  **reljoin);
extern void dba_add_reltab (
  struct dba_reltemp  *reltemp,
  struct dba_reltab  *reltab);
extern void dba_add_reljoin (
  struct dba_reltemp  *reltemp,
  struct dba_reljoin  *reljoin);
extern void dba_add_reltemp (
  char  *template,
  struct dba_reltemp  **reltemp);
extern void dba_free_reltemp (
  char  *template);
extern int dba_delete_current_relations (
);

/* From mal_dbnu.c */
extern int dba_malloc_sch (
  struct dba_sch  **sch_ptr,
  struct dba_sch  *in_sch_ptr);
extern int dba_free_sch (
  struct dba_sch  **sch_ptr);
extern int dba_malloc_find (
  struct dba_find  **find_ptr,
  struct dba_find  *in_find_ptr);
extern int dba_free_find (
  struct dba_ent  *ent_ptr);
extern int dba_malloc_repatt (
  struct dba_repatt  **rep_ptr,
  struct dba_repatt  *in_rep_ptr);
extern int dba_free_repatt (
  struct dba_repatt  **rep_ptr);
extern int dba_malloc_outjoin (
  struct dba_outjoin  **outjoin_ptr,
  struct dba_outjoin  *in_outjoin_ptr);
extern int dba_free_outjoin (
  struct dba_outjoin  **outjoin_ptr);

/* From nam_to_num.c */
extern int dba_name_to_numbers (
  char  *text_ptr);

/* From open_sch.c */
extern int dba_open_schema (
  struct dba_sch  *sch_ptr,
  int  msg);

/* From parse_att.c */
extern int dba_parse_att (
  char  *char_ptr,
  struct dba_att  **att_ptr);

/* From parse_ent.c */
extern int dba_parse_ent (
  char  *char_ptr,
  struct dba_ent  **ent_ptr);

/* From parse_relop.c */
extern int dba_parse_relop (
  struct dba_att  *att_ptr,
  char  *relop);

/* From parse_sch.c */
extern int dba_parse_sch (
  char  *schema,
  struct dba_sch  **sch_ptr);

/* From r_exec.rc */
extern int dba_ris_exec_sql(
  char  *string);

/* From r_prep_sql.rc */
extern int dba_ris_prepare_sql (
    char  *sqlptr);

/* From r_sql.rc */
extern int dba_ris_sql (
    char  *sqlptr);

/* From rd_mscols.c */
extern int dba_read_mscolumns (
  char  *schema,
  int  entnum,
  char  **mscolumns,
  int  **attnums,
  char  ***defvals,
  char  ***aliases,
  char  ***formats);

/* From read_schema.c */
extern int dba_read_schema (
  char  *schema,
  char  *file);

/* From reg_dbnu.c */
extern int dba_register_dbnuc(
);

/* From replace_sch.c */
extern int dba_replace_schema (
  struct dba_sch  *sch_ptr,
  char  *schema_name,
  int  position);

/* From s_addqry.c */
extern long dba_s_add_query (
  functiontype  *bfunc,
  functiontype  *function,
  long  opnum);

/* From s_dbnuc.c */
extern void dba_setup_dbnuc (
);

/* From s_getcod.c */
extern long dba_s_get_code_number_text (
  functiontype  *bfunc,
  functiontype  *function,
  long  opnum,
  long  mode);

/* From s_getqry.c */
extern long dba_s_get_query (
  functiontype  *bfunc,
  functiontype  *function,
  long  opnum);

/* From s_select.c */
extern long dba_s_select (
  functiontype  *bfunc,
  functiontype  *function,
  long  opnum);
extern long dba_s_fetch (
  functiontype  *bfunc,
  functiontype  *function,
  long  opnum);
extern long dba_s_close_cursor (
  functiontype  *bfunc,
  functiontype  *function,
  long  opnum);

/* From s_tabnum.c */
extern int dba_set_table_number_by_name (
  char  *schema,
  char  *table,
  int  table_number);

/* From save_qry.c */
extern int dba_save_query (
  char  *library,
  char  *template,
  char  *description,
  char  *schema,
  char  *table,
  char  *query_text);

/* From set_att_ptr.c */
extern int dba_set_att_ptr (
  struct dba_ent  *ent_ptr,
  char  *entnam,
  char  *attnam,
  struct dba_att  **att_ptr,
  int  msg,
  int  alias);

/* From set_catt.c */
extern int dba_set_catt (
);

/* From set_ent_ptr.c */
extern int dba_set_ent_ptr (
  int  schema,
  int  entnum,
  char  *entnam,
  struct dba_ent  **ent_ptr,
  int  msg,
  int  alias);

/* From set_sch_ptr.c */
extern int dba_set_sch_ptr (
  int  schema,
  char  *schnam,
  struct dba_sch  **sch_ptr,
  int  msg);

/* From set_schent.c */
extern int dba_set_schent_ptr (
  char  *schema,
  char  *table,
  struct dba_ent  **ent_ptr);

/* From set_schlst.c */
extern int dba_set_schema_list (
  char  *text_ptr);

/* From set_table.c */
extern int dba_set_table_list (
  char  *schema,
  char  *list);

/* From single_quote.c */
extern int dba_single_quote (
  char  *text);

/* From sprintf_spec.c */
extern char *dba_ent_spec (
  struct dba_ent  *ent_ptr);
extern char *dba_att_spec (
  struct dba_att  *att_ptr);
extern char *dba_gadg_ent_spec (
  struct dba_gadget  *gadg);
extern char *dba_gadg_att_spec (
  struct dba_gadget  *gadg);
extern char *dba_line_ent_spec (
  struct dba_line  *lin_ptr);
extern char *dba_field_att_spec (
  struct dba_field  *fld_ptr);
extern char *dba_column_spec (
  struct dba_gadget  *gadg);
extern int dba_parse_column_spec (
  struct dba_gadget  *gadg);
extern char *dba_join_spec (
  int  from_schema,
  char  *from_table,
  char  *from_join,
  int  to_schema,
  char  *to_table,
  char  *to_join);

/* From sql_debug.c */
extern int dba_sql_debug (
  char  *args);

/* From sqlerr.c */
extern int dba_sqlerr (
);

/* From tb_alias.c */
extern int dba_set_table_alias (
  char  *schema,
  char  *table,
  char  *alias);

/* From u_ristxt.rc */
extern void dba_ris_text (
    char  *sql_txt,
  char  **values);

/* From up_sqltype.c */
extern int dba_upgrade_sqltype (
);

/* From write_schema.c */
extern int dba_write_schema (
  char  *schema,
  char  *file);

/* From is_ora.c */
extern int dba_is_oracle (
  char *schema);

#endif
