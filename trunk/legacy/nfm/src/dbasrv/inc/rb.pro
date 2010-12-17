#ifndef rb_pro
#define rb_pro

/* From confirm.c */
extern int confirm_delete (
  char  *text_ptr);

/* From def_columns.c */
extern int dba_select_default_columns (
  int  option);

/* From drag_text.c */
extern int drag_text (
  char  *text_ptr);

/* From dump_rpt.c */
extern int dba_dump_report (
  char  *output);
extern int dba_fputs (
  FILE  *file_ptr,
  char  *text);
extern int dba_user_text (
  struct dba_user  *user_ptr,
  FILE  *dump_ptr);
extern int dba_key_text (
  int  count,
  struct dba_field  *fld_ptr,
  FILE  *dump_ptr);
extern int dba_line_text (
  int  count,
  struct dba_line  *lin_ptr,
  FILE  *dump_ptr);
extern int dba_field_text (
  struct dba_field  *fld_ptr,
  FILE  *dump_ptr);
extern int dba_format_text (
  struct dba_field  *fld_ptr,
  FILE  *dump_ptr);
extern int dba_dump_error (
);
extern int dba_join_text (
  struct dba_line  *lin_ptr,
  struct dba_field  *fld_ptr,
  FILE  *dump_ptr);

/* From f_check_cond.c */
extern int dba_check_condition (
  char  *cond,
  struct dba_ent  *ent_ptr,
  struct dba_line  *lin_ptr);

/* From f_chk_linsch.c */
extern int check_line_schema (
  struct dba_field  *fld_ptr,
  struct dba_line  *lin_ptr);

/* From f_copy_field.c */
extern int copy_field (
);

/* From f_copy_line.c */
extern int copy_line (
  int  col_off);

/* From f_dump_temp.c */
extern int dba_dump_template (
  int  option);

/* From f_edit_field.c */
extern int edit_field (
  int  option,
  int  new_field_flag);

/* From f_edit_line.c */
extern int edit_line (
  int  option,
  int  new_line_flag);
extern int paint_line_table (
  int  entnum,
  int  schema,
  char  *entnam);

/* From f_edit_rpt.c */
extern int edit_report (
  int  option);
extern int paint_rent (
  Form  fpt,
  int  rent,
  struct dba_ent  *ent_ptr);

/* From f_erase_rb.c */
extern int erase_rb_pop (
);

/* From f_fld_format.c */
extern int field_format (
  int  option);

/* From f_move_field.c */
extern int move_field (
);

/* From f_move_line.c */
extern int move_line (
  int  col_off);

/* From f_pt_tmp.c */
extern int dba_paint_template (
);

/* From f_rb.c */
extern int dba_report_builder (
  int  option);
extern int dba_do_field (
  int  option);
extern int dba_do_line (
  int  option,
  int  col_off);
extern int dba_display_rb_bar (
  int  disp_rbf);
extern int dba_erase_rb_bar (
  int  disp_rbf);

/* From f_set_afield.c */
extern int set_att_field (
  int  int_lng,
  int  dec_lng,
  int  decimal,
  int  codval);

/* From f_set_field.c */
extern int set_field (
);

/* From f_sort.c */
extern int modify_sort (
  int  option);
extern int paint_sort (
);
extern int paint_type (
  int  type,
  Form  fpt);
extern int display_sort (
  int  type,
  Form  fpt);
extern int erase_sort (
  int  type,
  Form  fpt);

/* From f_structure.c */
extern int dba_structure (
  int  option);
extern int dba_paint_structure (
  Form  fpt);
extern int dba_paint_str_tab (
  Form  fpt);
extern int dba_paint_str_columns (
  Form  fpt);
extern int dba_paint_str_col (
  Form  fpt);
extern int dba_add_str_tab (
  Form  fpt);
extern int dba_add_str_col (
  Form  fpt);
extern int dba_set_str_flds (
  Form  fpt,
  int  subtyp);
extern int dba_change_selected_text (
  Form  fpt,
  int  label,
  int  column,
  char  *text);
extern int dba_check_existing_structure_name (
  Form  fpt,
  int  label,
  char  *name,
  int  number);

/* From f_up_lintxt.c */
extern int update_line_text (
  struct dba_line  *lin_ptr,
  int  line);

/* From f_up_status.c */
extern int update_status_line (
  int  row,
  int  column);

/* From f_user_act.c */
extern int user_action (
  int  option,
  int  sort);

/* From f_user_var.c */
extern int user_var (
  int  option);
extern char *build_user_text (
  char  *name,
  int  type,
  int  x,
  int  y);
extern int dba_check_existing_user_variable (
  char  *name);

/* From init_rb_drag.c */
extern int dba_init_rb_drag (
  char  *text_ptr,
  int  *window,
  int  *x_min,
  int  *y_min,
  int  *x_max,
  int  *y_max,
  int  *width,
  int  *height,
  int  *spacing,
  int  *length,
  int  *font_id,
  int  *rows);

/* From n_rb.c */
extern int dba_notify_rb (
  int  form_label);

/* From rb_spell.c */
extern int dba_rb_spellcheck (
);

/* From shift_chars.c */
extern int dba_shift_chars (
  Form  fpt,
  int  label,
  int  column,
  int  option);

#endif
