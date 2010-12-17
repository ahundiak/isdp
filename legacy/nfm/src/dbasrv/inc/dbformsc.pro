#ifndef dbformsc_pro
#define dbformsc_pro

/* From a_dbform.c */
extern int dba_attach_dbforms (
);

/* From add_sel_col.c */
extern int dba_add_selected_columns (
  struct dba_ent  **ent_ptr,
  char  *select_text,
  struct dba_gadget  *gadg,
  int  *count);

/* From bld_join.c */
extern int dba_build_join_where (
  char  **s1_ptr,
  unsigned long  *s1_size,
  struct dba_outjoin  *outjoin,
  char  *join_ptr,
  int  *got_where);

/* From bld_ordr_txt.c */
extern int dba_build_order_text (
  char  **s1_ptr,
  unsigned long  *s1_size,
  int  mnunum,
  int  order_flag,
  char  *order);

/* From build_find.c */
extern int dba_build_find (
  char  **s1_ptr,
  unsigned long  *s1_size,
  int  mnunum,
  int  order_flag,
  char  *order);

/* From build_from.c */
extern int dba_build_from (
  char  **s1_ptr,
  unsigned long  *s1_size,
  struct dba_ent  *ment,
  int  from_review);

/* From build_key.c */
extern int dba_build_key_where (
  char  **s1_ptr,
  unsigned long  *s1_size,
  long  row_count,
  struct dba_ent  *ent_ptr,
  struct dba_ent  *kent,
  int  *got_where);

/* From build_order.c */
extern int dba_build_order_select (
  char  **s1_ptr,
  unsigned long  *s1_size,
  int  mnunum,
  int  order_flag,
  char  *order);

/* From build_select.c */
extern int dba_build_select (
  char  **s1_ptr,
  unsigned long  *s1_size,
  int  mnunum,
  int  order_flag,
  char  *order);
extern int dba_build_key_select (
  struct dba_ent  *tent,
  char  **s1_ptr,
  unsigned long  *s1_size);
extern int dba_build_outjoin_select (
  char  **s1_ptr,
  unsigned long  *s1_size,
  int  mnunum);
extern int dba_build_ment_select (
  char  **s1_ptr,
  unsigned long  *s1_size,
  int  mnunum);

/* From chg_all.c */
extern int dba_change_all (
);

/* From chg_code.c */
extern int dba_change_code (
  int  slot);

/* From code_sort.c */
extern int dba_code_text_sort (
  struct dba_code_list  *ccl);

/* From currow.c */
extern int dba_current_row (
  int  mnunum,
  long  new_row);

/* From d_s_tlst.c */
extern int dba_dbforms_set_table_list (
);

/* From dbd_attach.c */
extern int dba_attach_linkage (
);

/* From dbd_chg_row.c */
extern int dba_change_row (
);

/* From dbd_del_row.c */
extern int dba_delete_row (
);

/* From dbd_edt_code.c */
extern int dba_edit_code (
);

/* From dbd_getcval.c */
extern int dba_get_menu_column_value (
  char  *menu,
  char  *schema,
  char  *table,
  char  *column,
  char  *value);
extern int dba_get_column_value (
  char  *schema,
  char  *table,
  char  *column,
  char  *value);
extern int dba_column_value (
  int  mnunum,
  char  *schema,
  char  *table,
  char  *column,
  char  *value);

/* From dbd_in_row.c */
extern int dba_insert_row (
);

/* From dbd_next_row.c */
extern int dba_next_row (
);

/* From dbd_on_off.c */
extern int dba_fields_on_off (
);

/* From dbd_prev_row.c */
extern int dba_previous_row (
);

/* From dbd_rest_def.c */
extern int dba_restore_defaults (
);

/* From dbd_review.c */
extern int dba_review (
);

/* From dbd_set_row.c */
extern int dba_set_current_row (
  long  row);

/* From dbd_upd_act.c */
extern int dba_update_active (
);

/* From dbfm_utl.c */
extern int dba_util_process_query_no_arg (
);
extern long dba_trans_key_in_mode (
  operandtype  *ptrop,
  void  *valptr,
  int  **arg_ptr,
  int  **alloc_ptr,
  int  alloc_size,
  char  *func_name,
  int  *ret_override_flag,
  int  *ret_override_value);

/* From del_all.c */
extern int dba_delete_all (
);

/* From delrec.c */
extern int dba_delete_record (
);

/* From disp_dbf.c */
extern int dba_display_dbforms_menu (
  struct dba_ent  *ment,
  int  mnunum,
  Form  fpt,
  char  *name,
  int  from_cancel);

/* From do_query.c */
extern int dba_do_query (
  int  mnunum,
  long  *rows_found,
  int  order_flag,
  char  *order,
  int  max_rows);
extern int dba_fetch_row (
  struct dba_ent  *ment,
  struct dba_ent  *kent,
  int  mnunum,
  long  count,
  int  option);
extern int dba_save_key_value (
  struct dba_ent  *tent,
  struct dba_ent  *kent,
  long  count);
extern int dba_check_key_lng (
  struct dba_ent  *kent,
  long  count,
  int  add);
extern int dba_alter_univ (
  struct dba_ent  *ment,
  struct dba_ent  *kent,
  long  start_row,
  long  *tot_ptr,
  int  option,
  int  mnunum);
extern void dba_get_key_offset (
  struct dba_ent  *ent_ptr,
  int  *offset);

/* From f_pad.c */
extern int dba_pad_underbars (
  char  *text_ptr,
  int  length);

/* From f_parse_doc.c */
extern int dba_parse_doc_list (
  double  value);

/* From f_strip.c */
extern int dba_strip_underbars (
  char  *text_ptr);

/* From fetch_opt.c */
extern int dba_fetch_opt (
  struct dba_ent  *ment,
  struct dba_ent  *kent,
  int  mnunum,
  long  *row_ptr,
  long  *tot_ptr,
  int  cursor,
  int  option);

/* From g_curtab.c */
extern int dba_get_current_table (
  char  *schema,
  char  *table);

/* From get_currow.c */
extern int dba_get_current_row (
  long  *row);

/* From init_mnu_qry.c */
extern int dba_init_menu_query (
  char  *menu);

/* From init_rev.c */
extern int dba_init_review (
);

/* From insert.c */
extern int dba_insert_record (
);

/* From join_db.c */
extern int dba_join_db (
  struct dba_ent  *ment,
  struct dba_ent  *kent,
  long  *row_ptr,
  long  *tot_ptr,
  int  option,
  int  mnunum);
extern int dba_no_join (
  struct dba_outjoin  *outjoin,
  int  option);

/* From key_rows.c */
extern int dba_add_key_rows (
  struct dba_ent  *ment,
  long  num,
  long  row,
  long  total);
extern int dba_copy_key_rows (
  struct dba_ent  *ment,
  long  num,
  long  to_row,
  long  from_row);
extern int dba_copy_outjoin_key (
  struct dba_ent  *tent,
  struct dba_ent  *kent,
  long  to_row,
  long  from_row);

/* From load_sql.c */
extern int dba_load_sql (
  Form  form,
  int  label,
  char  *library,
  char  *template);

/* From max_mslink.c */
extern int dba_get_max_mslink (
  char  *tabnam,
  long  *max);

/* From menu_outjoin.c */
extern int dba_create_menu_outjoin (
  struct dba_ent  *ment,
  int  from_schema,
  char  *from_entnam,
  struct dba_att  *att_ptr,
  int  to_schema,
  char  *to_entnam,
  int  outer,
  char  *join_from,
  char  *join_to);
extern int dba_create_menu_repatt (
  int  schema,
  char  *entnam,
  char  *attnam,
  int  outer,
  struct dba_repatt  **repatt);

/* From new_code.c */
extern int dba_new_code (
  int  slot,
  char  *text_ptr);

/* From new_value.c */
extern int dba_new_value (
  struct dba_att  *att_ptr,
  int  mnunum);

/* From nextocc.c */
extern int dba_get_nextocc (
  char  *tabnam,
  long  *max);

/* From occload.c */
extern int dba_occload (
  struct dba_ent  *ment,
  int  mnunum);
extern int dba_occload_ent (
  struct dba_ent  *ment,
  int  skip_join,
  int  mnunum);

/* From paint_rev.c */
extern int dba_paint_review (
  int  row,
  struct dba_defatt  *tda,
  char  *data_ptr,
  long  ind);

/* From parse_select.c */
extern int dba_parse_select (
  char  *select_text);

/* From pnt_main.c */
extern int dba_paint_main_menu (
);

/* From proc_sql.c */
extern int dba_process_sql_template (
  char  *library,
  char  *template);

/* From query.c */
extern int dba_process_query (
  char  *menu,
  long  *rows_found,
  int  order_flag,
  char  *order);

/* From reg_gra.c */
extern int dba_register_graphics(
);

/* From restore.c */
extern int dba_defaults (
  int  preserve_univ,
  int  mnunum);

/* From rev_query.c */
extern int dba_review_outjoin (
);

/* From rev_sql.c */
extern int dba_review_sql (
);
extern int dba_add_review (
  struct dba_ent  *ment,
  struct dba_ent  *kent,
  int  outjoin,
  int  rows);
extern int dba_review_close (
);

/* From s_curcol.c */
extern long dba_s_get_current_column (
  functiontype  *bfunc,
  functiontype  *function,
  long  opnum);

/* From s_dbforms.c */
extern void dba_setup_dbforms (
);

/* From s_revele.c */
extern long dba_s_review_element (
  functiontype  *bfunc,
  functiontype  *function,
  long  opnum);

/* From s_setrow.c */
extern long dba_s_set_current_row (
  functiontype  *bfunc,
  functiontype  *function,
  long  opnum);

/* From save_key.c */
extern int dba_save_key (
  int  mnunum);
extern int dba_build_key (
  int  *key_lng);
extern int dba_compare_key (
  int  mnunum);
extern int dba_init_key (
  int  mnunum);

/* From save_mnu.c */
extern int dba_save_menu (
  char  *menu,
  char  *library,
  int  verify_lib,
  int  verify_menu);

/* From set_cent.c */
extern int dba_set_current_entity (
  int  mnunum);

/* From set_columns.c */
extern int dba_set_columns (
  char  *menu,
  int  label,
  int  mode,
  char  *columns,
  char  *names);

/* From set_currow.c */
extern int dba_set_currow (
  int  mnunum);

/* From set_mentab.c */
extern int dba_set_menu_table (
  char  *menu,
  char  *schema,
  char  *table);

/* From set_order.c */
extern int dba_set_order (
  char  *menu,
  char  *order);

/* From set_query.c */
extern int dba_set_query (
  char  *library,
  char  *template);

/* From set_r_w.c */
extern int dba_set_read_write (
  char  *menu,
  char  *schema,
  char  *table,
  char  *column,
  int  write_flag);

/* From set_select.c */
extern int dba_set_select (
  struct dba_ent  *ent_ptr);

/* From set_sincol.c */
extern int dba_set_single_column (
  Form  fpt,
  struct dba_gadget  *gadg);

/* From set_sqlvar.c */
extern void dba_set_all_sqlvar (
);
extern void dba_set_key_sqlvar (
);
extern void dba_set_outjoin_sqlvar (
);
extern void dba_set_ment_sqlvar (
);
extern void dba_set_defatt_sqlvar (
);

/* From std_menu_att.c */
extern int dba_standard_menu_att (
  struct dba_att  **new_att,
  struct dba_att  *att_ptr,
  struct dba_ent  *ment,
  struct dba_gadget  *gadg);

/* From upd_row.c */
extern int dba_update_row (
);

/* From write_find.c */
extern int dba_write_find (
  char  *library,
  char  *template,
  int  verify_lib,
  int  verify_temp);

#endif
