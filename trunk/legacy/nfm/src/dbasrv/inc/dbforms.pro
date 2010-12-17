#ifndef dbforms_pro
#define dbforms_pro

/* From attach_ae.c */
extern int dba_attach_ae (
);

/* From bld_s_list.c */
extern int dba_build_select_list (
  char  *menu,
  int  label,
  char  *select);
extern int dba_do_select_list (
  int  mnunum,
  int  hwnd,
  int  label,
  char  *select,
  int  option,
  int  expand);

/* From c_fldrow.c */
extern int dba_copy_field_rows (
  Form  fpt,
  int  label,
  int  crow,
  int  num);

/* From check_mslink.c */
extern int dba_check_mslink (
  struct dba_ent  *ent_ptr,
  int  set,
  int  mslink);

/* From chk_link.c */
extern int dba_check_link (
  short  *buffer,
  short  *link_offset,
  short  *entity,
  long  *mslink,
  short  *wtf,
  char  *type);

/* From d_settab.c */
extern int dba_dbforms_set_table (
);

/* From dbf_gadg.c */
extern int dba_set_dbforms_gadgets (
  Form  fpt,
  struct dba_gadget  *gadg);

/* From dbf_menu.c */
extern int dba_dbforms_menu (
  struct dba_ent  *ment,
  Form  fpt);

/* From dbforms_g.c */
extern int dba_dbforms_gadgets (
  int  option,
  int  mnunum);

/* From f_add_find.c */
extern int dba_do_add_find (
  struct dba_att  *att_ptr,
  int  mnunum);

/* From f_add_where.c */
extern int dba_add_where (
  struct dba_ent  *ent_ptr,
  Form  fpt,
  int  label,
  int  row);

/* From f_all_on_off.c */
extern int dba_all_on_off (
);

/* From f_att_on_off.c */
extern int dba_att_on_off (
);

/* From f_bld_allfld.c */
extern int dba_build_allfld (
  int  option,
  Form  fpt,
  int  label,
  struct dba_ent  *ent_ptr,
  char  *columns,
  char  *names);

/* From f_bld_entfld.c */
extern int dba_build_entfld (
  Form  fpt,
  int  schema,
  char  *entnam,
  int  paint,
  int  label,
  int  alias);

/* From f_bld_popcod.c */
extern int dba_build_popup_codelist (
  Form  fpt,
  struct dba_gadget  *gadg);

/* From f_change_all.c */
extern int dba_change_all_rows (
  int  option);

/* From f_code.c */
extern int dba_edit_code_form (
  int  option);

/* From f_def_menu.c */
extern int dba_load_default_menu (
  struct dba_ent  *ent_ptr,
  int  display);

/* From f_delete_all.c */
extern int dba_delete_all_rows (
);

/* From f_disp_dbe.c */
extern int dba_display_dbe (
);

/* From f_ed_fnd.c */
extern int dba_edit_find (
  int  option);
extern int dba_paint_find (
  struct dba_ent  *ent_ptr);

/* From f_editor.c */
extern int dba_use_editor (
  Form  fpt,
  int  text_label,
  int  ed_label);

/* From f_gra_msg.c */
extern int dba_gra_msg (
  int  field,
  char  *text);

/* From f_multi_rpt.c */
extern int dba_multi_reports (
  int  option);
extern int dba_check_input_name (
  char  *filename);

/* From f_paint_crow.c */
extern int dba_paint_current_row (
  int  mnunum);

/* From f_pnt_attr.c */
extern int dba_paint_attributes (
  Form  fpt,
  struct dba_ent  *ent_ptr,
  int  option,
  int  mnunum,
  int  p_wrksht);
extern int dba_paint_attnam (
  Form  fpt,
  struct dba_att  *att_ptr,
  int  mnunum);
extern int dba_paint_attval (
  Form  fpt,
  int  row,
  struct dba_att  *att_ptr,
  int  p_wrksht);

/* From f_proc_doc.c */
extern int dba_process_doc_list (
  char  *menu,
  int  label);

/* From f_pt_mcf.c */
extern int dba_paint_mcf (
  Form  fpt,
  int  label,
  int  row,
  int  column,
  struct dba_att  *att_ptr,
  char  *data_ptr);

/* From f_pt_ptr.c */
extern int dba_paint_ptr (
);

/* From f_pword.c */
extern int dba_get_password (
  char  *schema,
  char  *password);

/* From f_rebld_menu.c */
extern int dba_rebuild_menu (
  char  *name_ptr);

/* From f_rev_line.c */
extern int dba_write_review_line (
  int  option,
  int  row,
  FILE  *filnam_ptr,
  int  offset,
  int  length);

/* From f_save_ascii.c */
extern int dba_save_ascii (
  Form  fpt,
  int  label,
  char  *filename);

/* From f_schfld.c */
extern int dba_build_schfld (
  Form  fpt,
  int  type,
  int  schema,
  int  label,
  int  text_label);

/* From f_scroll_ws.c */
extern int dba_scroll_worksheets (
  Form  fpt,
  int  row,
  int  position,
  int  mnunum);

/* From f_set_multi.c */
extern int dba_set_multiple_field (
  Form  fpt,
  struct dba_gadget  *gadg);

/* From f_set_wrksht.c */
extern int dba_set_worksheet (
  Form  fpt,
  struct dba_gadget  *gadg);

/* From f_sql.c */
extern int dba_sql_form (
  int  option,
  int  mnunum);

/* From f_univ_rev.c */
extern int dba_univ_review (
  int  option);
extern int dba_review_total (
);
extern int dba_review_output (
  char  *text_ptr,
  int  length,
  int  row,
  int  column);
extern int dba_review_eof (
  struct dba_ent  *ment,
  struct dba_ent  *kent,
  int  outjoin);

/* From f_upd_multi.c */
extern int dba_update_multiple_field (
  Form  fpt,
  struct dba_ent  *ment,
  struct dba_ent  *ent_ptr,
  struct dba_gadget  *gadg);

/* From f_upd_no_db.c */
extern int dba_update_no_db (
);
extern int dba_update_menu_table (
  int  mnunum,
  struct dba_ent  *ent_ptr);

/* From f_upd_single.c */
extern int dba_update_single_column (
  Form  fpt,
  struct dba_ent  *ment,
  struct dba_ent  *ent_ptr,
  struct dba_gadget  *gadg);

/* From f_upd_wrksht.c */
extern int dba_update_worksheet (
  Form  fpt,
  struct dba_ent  *ment,
  struct dba_ent  *ent_ptr,
  struct dba_gadget  *gadg);
extern int dba_set_worksheet_column (
  Form  fpt,
  struct dba_gadget  *gadg,
  int  column,
  struct dba_att  *att_ptr,
  char  *attnam);

/* From f_wt_mnu.c */
extern int dba_write_menu (
  char  *library,
  char  *template,
  int  verify_lib,
  int  verify_temp);
extern int dba_check_single_column (
  struct dba_ent  *ment,
  struct dba_gadget  *gadg);
extern int dba_check_multi_column (
  struct dba_ent  *ment,
  struct dba_gadget  *gadg);

/* From f_wt_sql.c */
extern int dba_write_sql (
  char  *library,
  char  *template,
  int  verify_lib,
  int  verify_temp);

/* From get_u_pw.c */
extern int dba_get_user_pass (
  char  *schema,
  char  *db_user,
  char  *db_pass,
  char  *os_user,
  char  *os_pass);

/* From graph_g.c */
extern int dba_graphics_gadgets (
  int  option,
  int  mnunum);

/* From i_dbforms.c */
extern int dba_init_dbforms (
);

/* From key_in_mode.c */
extern int dba_get_key_in_mode (
  char  *menu,
  int  *mode);
extern int dba_set_key_in_mode (
  char  *menu,
  int  mode);

/* From load_ascii.c */
extern int dba_load_ascii (
  char  *form,
  int  label,
  char  *file);

/* From locate.c */
extern int dba_locate_graphics (
  int  set,
  int  mode,
  int  view,
  double  zoom,
  int  blink);

/* From n_dbforms.c */
extern int dba_notify_dbforms (
  int  form_label);

/* From n_graph.c */
extern int dba_notify_graphics (
  int  form_label);

/* From paint_doc.c */
extern int dba_paint_doc_list (
  int  query);

/* From proc_mnu.c */
extern int dba_process_menu (
  char  *templib,
  char  *menu_name,
  char  *schema,
  char  *schema_list,
  char  *table);

/* From pswdform.c */
extern int dba_password_form (
  int  option);

/* From r_dbform.c */
extern int dba_register_dbforms(
);

/* From relop.c */
extern int dba_get_relop (
  char  *menu,
  char  *relop);
extern int dba_set_relop (
  char  *menu,
  char  *relop);

/* From revele.c */
extern int dba_review_element (
  char  *table,
  int  no_verify,
  int  multiple);

/* From rm_fence.c */
extern int dba_remove_fence (
);

/* From rm_link.c */
extern int dba_remove_linkage(
);

/* From s_gtcval.c */
extern long dba_s_get_column_value (
  functiontype  *bfunc,
  functiontype  *function,
  long  opnum,
  long  mode);

/* From sel_form.c */
extern int dba_select_form (
  char  *select_text);

/* From set_wrkhdr.c */
extern int dba_set_worksheet_hdr (
  Form  fpt,
  struct dba_gadget  *gadg);

/* From sync_mnu.c */
extern void dba_sync_same_menus (
  int  mnunum);

/* From u_pw_frm.c */
extern int dba_user_pass_form (
  int  option);

/* From wt_rev.c */
extern int dba_write_review (
  char  *filename,
  int  offset,
  int  columns_per_page,
  int  lines_per_page);
extern int dba_review_top (
  int  page,
  FILE  *filnam_ptr,
  int  offset,
  int  columns_per_page);

#endif
