#ifndef mb_pro
#define mb_pro

/* From auto_seq.c */
extern int dba_auto_seq (
);

/* From cre_fgroup.c */
extern int dba_create_fgroup (
);

/* From cre_seq.c */
extern int dba_create_sequence (
);

/* From cvt_form.c */
extern int dba_convert_iform_form (
  int  option);

/* From cvt_iform.c */
extern int dba_convert_iform_callback (
  Form  fpt,
  int  label,
  char  *name);
extern int dba_convert_iform (
  char  *form,
  int  display);

/* From d_bitmap.c */
extern int dba_db_toolbox_bitmaps (
);

/* From d_labels.c */
extern int dba_display_labels (
);

/* From data_lnk.c */
extern int dba_create_data_link (
);
extern int dba_delete_data_link (
);
extern int dba_review_data_link (
);

/* From db_gadg.c */
extern int dba_database_gadget (
  int  option);
extern int dba_paint_db_gadget (
  int  mode);

/* From db_tool.c */
extern int dba_db_toolbox (
  int  option);

/* From del_fgroup.c */
extern int dba_delete_fgroup (
);

/* From del_seq.c */
extern int dba_delete_sequence (
);

/* From dis_bltn.c */
extern dba_disable_builtin (
  Form  fpt,
  int  type);
extern dba_mb_disable (
  Form  fpt,
  int  label);

/* From disp_hilite.c */
extern int dba_display_hilite_gadget (
  Form  fpt,
  int  label,
  int  dummy);
extern int dba_display_hilite_group (
  Form  fpt,
  int  group);

/* From drag_gad.c */
extern int drag_gadget (
  int  option,
  int  x_start,
  int  y_start,
  int  *final_x,
  int  *final_y,
  int  width,
  int  height);

/* From draw_arrow.c */
extern int dba_draw_arrow (
  int  window,
  int  dynamic,
  int  color,
  int  x1,
  int  y1,
  int  x2,
  int  y2);

/* From draw_gadg.c */
extern int dba_draw_gadget (
  int  option,
  int  window,
  int  color,
  int  font_id,
  int  x,
  int  y,
  int  spacing,
  int  length,
  char  *text_ptr,
  int  x_start,
  int  y_start,
  int  width,
  int  height,
  char  *symbol);

/* From drop_fgroup.c */
extern int dba_drop_from_fgroup (
);

/* From dump_menu.c */
extern int dba_dump_menu (
  char  *output);
extern int dba_gadget_text (
  struct dba_ent  *ment,
  struct dba_gadget  *gadg,
  FILE  *dump_ptr);
extern int dba_gadget_join (
  int  from_schema,
  char  *from_table,
  char  *from_column,
  int  to_schema,
  char  *to_table,
  char  *to_column,
  int  outer,
  FILE  *dump_ptr);

/* From ed_verfy.c */
extern int edit_verify (
  int  option);
extern int dba_paint_verify (
  Form  fpt);

/* From edit_columns.c */
extern int dba_edit_columns (
  int  option,
  Form  fpt);

/* From edit_fence.c */
extern int dba_edit_fence_group (
  int  option,
  int  fence);

/* From edit_fgroup.c */
extern int dba_edit_fgroup (
  int  option);

/* From edit_mcf.c */
extern int dba_edit_mcf (
  int  option);

/* From exp_summ.c */
extern int dba_expanded_summary (
  int  option);
extern int dba_paint_exp_summ (
  int  prow);

/* From f_add_group.c */
extern int add_group_gadget (
);

/* From f_add_hdr.c */
extern int dba_add_header (
  struct dba_gadget  *gadg);

/* From f_blank_menu.c */
extern int load_blank_menu (
  struct dba_ent  *ent_ptr);

/* From f_chk_group.c */
extern int check_group_gadget (
  int  option);

/* From f_cursav.c */
extern int current_saved (
  Form  fpt,
  int  saved);

/* From f_def_opts.c */
extern int dba_default_opts (
  int  option,
  long  *fld_attr_in,
  int  *data_type_in,
  char  **user_format_in,
  unsigned long  *user_format_lng,
  char  **def_ptr_in,
  unsigned long  *def_size_in,
  double  *minval_in,
  double  *maxval_in);
extern int dba_paint_default_opts (
  long  *fld_attr,
  int  *data_type,
  char  **user_format,
  double  *minval,
  double  *maxval,
  char  **def_ptr);

/* From f_del_group.c */
extern int dba_delete_group (
);

/* From f_drag_list.c */
extern int dba_drag_asso_list (
  struct dba_gadget  *gadg,
  int  abort);

/* From f_ed_fnt.c */
extern int edit_font (
  int  option,
  Form  fpt);
extern int dba_paint_font (
  Form  fpt,
  char  *name,
  int  size,
  int  style,
  int  just);

/* From f_ed_gdg.c */
extern int edit_gadget (
  int  option,
  int  new_gadget_flag,
  Form  fpt);
extern int toggle_text_symbol (
  Form  fpt,
  int  symbol_flag);
extern int toggle_multi (
  Form  fpt,
  int  entnum,
  struct dba_ent  *ent_ptr,
  int  exclude,
  char  *columns);
extern int dba_toggle_sql_driven (
  Form  fpt,
  int  option);
extern int dba_toggle_width (
  Form  fpt,
  int  option);
extern int dba_paint_location (
  Form  fpt,
  int  type,
  int  xlo,
  int  ylo,
  int  xhi,
  int  yhi);
extern int dba_template_lists (
  Form  fpt);
extern int dba_set_new_gadget (
);
extern int dba_paint_new_gadget (
  Form  fpt);
extern int dba_paint_new_gadget_db (
  Form  db_fpt);
extern int dba_set_dial_fields (
  Form  fpt,
  int  option);
extern int dba_get_field_type (
  struct dba_gadget  *gadg,
  int  *type);
extern int dba_toggle_doc_list (
  Form  fpt,
  int  option);
extern int dba_enable_db_button (
  Form  fpt);
extern int dba_update_db_mcf (
  int  exclude,
  Form  fpt,
  struct dba_ent  *ent_ptr,
  char  *columns,
  char  *off_text);

/* From f_edit_color.c */
extern int edit_color (
  int  option,
  int  *color_ptr,
  Form  fpt);
extern int dba_paint_color (
  Form  fpt,
  int  color);

/* From f_edit_group.c */
extern int edit_group (
  int  option,
  int  new_group_flag);

/* From f_edit_help.c */
extern int edit_help(
  int  gadget);

/* From f_edit_menu.c */
extern int edit_menu (
  int  option);
extern int toggle_db_menu (
  int  db_menu);

/* From f_edit_opts.c */
extern int dba_edit_opts (
  int  option,
  long  *fld_attr_in,
  int  *mode_in,
  Form  fpt);
extern int dba_paint_edit_opts (
  long  *fld_attr,
  int  *mode,
  Form  fpt);

/* From f_er_mb.c */
extern int erase_mb_pop (
);

/* From f_find_fence.c */
extern int dba_find_fence (
  int  *flabels,
  int  **flabel_ptr,
  int  *vlabels,
  int  **vlabel_ptr,
  int  *xlo_ptr,
  int  *ylo_ptr,
  int  *width,
  int  *height,
  int  *x,
  int  *y);

/* From f_get_gadg.c */
extern int get_gadget (
  Form  fpt,
  struct dba_gadget  *gadg);
extern int set_schema_text (
  Form  fpt,
  int  schema);
extern int set_table_text (
  Form  fpt,
  char  *entnam);
extern int dba_get_field_options (
  struct dba_gadget  *gadg);
extern int dba_get_gadget_iforms (
  Form  fpt,
  struct dba_gadget  *gadg,
  int  type);
extern int dba_get_gadget_dba (
  Form  fpt,
  struct dba_gadget  *gadg);
extern int dba_get_gadget_dba_db (
  Form  db_fpt,
  struct dba_gadget  *gadg);
extern int set_scale_mode (
  Form  fpt,
  unsigned  option);

/* From f_get_group.c */
extern int check_label (
  Form  form_ptr,
  int  label,
  int  *label_ptr);
extern int get_group_value (
  Form  form_ptr,
  int  group,
  int  *label_ptr);

/* From f_get_symbol.c */
extern int dba_get_symbol (
  char  *filename,
  int  *font_id);

/* From f_grid_lock.c */
extern int grid_lock (
  int  option,
  Form  fpt);
extern int dba_paint_grid (
  Form  fpt);

/* From f_list_opts.c */
extern int dba_list_opts (
  int  option);
extern int dba_paint_list_opts (
);

/* From f_locdat.c */
extern int location_datapoint (
  Form  fpt,
  int  keyin);

/* From f_mb.c */
extern int dba_menu_builder (
  int  option);
extern int dba_display_mb_bar (
  int  disp_mbg);
extern int dba_erase_mb_bar (
  int  disp_mbg);

/* From f_scr_opts.c */
extern int dba_scroll_opts (
  int  option);
extern int dba_paint_scroll_opts (
);

/* From f_send_expos.c */
extern int dba_send_expose (
  Form  fpt,
  int  x,
  int  y,
  int  width,
  int  height);

/* From f_set_doc.c */
extern int dba_set_doc_list (
  Form  dba_form,
  struct dba_gadget  *gadg_ptr);

/* From f_set_gadg.c */
extern int set_gadget (
  Form  fpt,
  struct dba_gadget  *gadg,
  int  locdat);
extern int get_schema_text (
  Form  fpt);
extern int get_table_text (
  Form  fpt);
extern int get_column_text (
  Form  fpt);
extern int set_field_hw (
  Form  fpt,
  struct dba_gadget  *gadg,
  int  *tot_width,
  int  *tot_height);
extern int dba_set_field_options (
  struct dba_gadget  *gadg);
extern int dba_get_cvt_case (
  Form  fpt,
  int  label,
  struct dba_gadget  *gadg);
extern int dba_set_gadget_iforms (
  Form  fpt,
  struct dba_gadget  *gadg,
  int  type);
extern int dba_set_gadget_dba (
  Form  fpt,
  struct dba_gadget  *gadg);
extern int dba_set_gadget_dba_db (
  Form  db_fpt,
  struct dba_gadget  *gadg);

/* From f_set_popup.c */
extern int dba_set_popup_field (
  Form  fpt,
  struct dba_gadget  *gadg);

/* From f_set_single.c */
extern int dba_set_single_field (
  Form  form_ptr,
  struct dba_gadget  *gadg);

/* From f_style.c */
extern int edit_style (
  int  option,
  Form  fpt);
extern int dba_paint_line_style (
  Form  fpt);

/* From f_topics.c */
extern int dba_get_topic(
  char  *topic,
  Form  output_form);
extern int dba_ck_topic(
  char  *topic);
extern int dba_add_topic(
  char  *topic);
extern int dba_rw_topic(
  char  *topic);
extern int dba_source_open(
  FILE  **fp,
  char  *filename);

/* From f_weight.c */
extern int edit_weight (
  int  option,
  Form  fpt);
extern int dba_paint_line_weight (
  Form  fpt);

/* From fen_del.c */
extern int dba_delete_fence (
  struct dba_ent  *dfent);

/* From find_group.c */
extern int dba_find_group (
  int  *label,
  int  *x,
  int  *y);

/* From fld_opt.c */
extern int dba_field_options (
  int  option,
  Form  fpt);
extern int dba_paint_cvt_case (
  Form  fpt,
  struct dba_gadget  *gadg);

/* From fnd_bpnt.c */
extern int dba_find_by_point (
  Form  fpt,
  int  x,
  int  y,
  int  *found_gadget,
  int  reset);

/* From fnd_gadg.c */
extern int dba_find_gadget (
  int  *x,
  int  *y,
  int  option);

/* From g_dtext.c */
extern int dba_get_dba_text (
  int  type,
  char  **text);

/* From g_dtype.c */
extern int dba_get_dba_type (
  char  *text,
  int  *type);

/* From g_itext.c */
extern int dba_get_iforms_text (
  int  type,
  char  **itext);

/* From g_itype.c */
extern int dba_get_iforms_type (
  int  type,
  int  *itype);

/* From gad_chrs.c */
extern int dba_gadget_chars (
  int  option,
  struct dba_gadget  *gadg);

/* From gadg_del.c */
extern int dba_delete_gadget (
  int  option,
  struct dba_gadget  **dgadg,
  int  *label);

/* From gdg_opts.c */
extern int dba_gadget_options (
  int  option);

/* From gdg_type.c */
extern int dba_load_gadget_types (
);

/* From group_add.c */
extern int dba_group_add_gadgets (
);

/* From group_delete.c */
extern int dba_group_delete (
  int  option,
  struct dba_ent  *dgent,
  struct dba_gadget  **dggadg,
  int  *group_label);

/* From grp_buttons.c */
extern int dba_paint_group_buttons (
);

/* From i_mb.c */
extern int dba_init_mb (
);

/* From m_c_fence.c */
extern int dba_move_copy_fence (
  int  option);

/* From m_c_gadget.c */
extern int dba_move_copy_gadget (
  int  option);

/* From m_c_group.c */
extern int dba_move_copy_group (
  int  option);

/* From mb_spell.c */
extern int dba_mb_spellcheck (
);

/* From n_mb.c */
extern int dba_notify_mb (
  int  form_label);

/* From p_builtn.c */
extern int dba_paint_builtin (
  Form  fpt,
  int  field,
  int  button,
  int  type,
  int  itype);

/* From p_mcf_at.c */
extern int dba_paint_mcf_atts (
  Form  fpt,
  struct dba_gadget  *gadg);

/* From p_mcf_cc.c */
extern int dba_paint_mcf_curcol (
  int  curcol,
  Form  fpt);

/* From pla_cell.c */
extern int dba_place_cell (
);

/* From rev_seq.c */
extern int dba_review_sequence (
);

/* From s_mb.c */
extern void dba_setup_mb (
);

/* From sel_sym.c */
extern int dba_select_symbol (
  int  option,
  int  symopt);
extern int dba_paint_selsym (
  int  calc_offset,
  int  symopt);

/* From set_poplst.c */
extern int dba_set_popup_list (
  Form  fpt,
  struct dba_gadget  *gadg);

/* From show_fgroup.c */
extern int dba_show_fgroup (
);

/* From snp_grid.c */
extern int dba_snap_to_grid (
);

/* From undel_fence.c */
extern int dba_undelete_fence (
  struct dba_ent  *dfent);

/* From undel_gadg.c */
extern int dba_undelete_gadget (
  struct dba_gadget  **dgadg);

/* From undel_group.c */
extern int dba_undelete_group (
  struct dba_ent  *dgent,
  struct dba_gadget  **dggadg);

/* From user_mcf_col.c */
extern int dba_build_user_mcf_columns (
  int  numcols);

/* From wrksht_cols.c */
extern int dba_build_worksheet_columns (
);
extern int dba_add_worksheet_column (
  struct dba_att  *tatt,
  struct dba_gadget  **fgadget,
  struct dba_gadget  **lgadget);

#endif
