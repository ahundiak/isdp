#ifndef private_pro
#define private_pro

/* From b_colfld.c */
extern int dba_build_colfld (
  Form  fpt,
  char  *colnam,
  int  label,
  int  paint);

/* From batch_rpt.c */
extern void dba_batch_report (
);

/* From batch_script.c */
extern void dba_batch_script (
);

/* From clipbox.c */
extern void dba_clipbox (
  int  window,
  int  x_min,
  int  y_min,
  int  x_max,
  int  y_max);

/* From crosshairs.c */
extern int dba_crosshairs (
  int  window,
  int  x,
  int  y,
  int  x_min,
  int  x_max,
  int  y_min,
  int  y_max);

/* From dba.c */
extern dba_dba (
  int  argc,
  char  *argv[]);

/* From dba_proc.c */
extern dba_process_all (
  int  argc,
  char  *argv[],
  char  *app,
  char  *toolbar,
  char  *dialog);

/* From del_join.c */
extern int dba_delete_reljoin (
);
extern int dba_delete_orphan_reltabs (
);

/* From del_tab.c */
extern int dba_delete_reltab (
);
extern int dba_delete_reljoin_ptr (
  struct dba_reltemp  *reltemp,
  struct dba_reljoin  *reljoin);
extern int dba_delete_reltab_ptr (
  struct dba_reltemp  *reltemp,
  struct dba_reltab  *reltab);

/* From des_opts.c */
extern int dba_design_opts (
  int  option,
  Form  fpt);
extern int dba_paint_design_opts (
);

/* From edit_rel.c */
extern int dba_edit_relations (
  int  option);

/* From editcomp.c */
extern int dba_compile_from_editor (
);

/* From editscr.c */
extern int dba_edit_script (
  long  option);
extern long dba_add_script (
  struct dba_script_line  **fscript,
  struct dba_script_line  **lscript,
  char  *stext);

/* From extra.c */
extern long dba_script_extra (
  long  option);

/* From f_bld_attfld.c */
extern int build_attfld (
  Form  fpt,
  char  *attnam,
  int  paint);

/* From f_bld_lngfld.c */
extern int build_lngfld (
  Form  fpt,
  int  atyp,
  int  length,
  int  decimal,
  int  codval);

/* From f_get_join.c */
extern int get_join_columns (
  int  option,
  char  **join_from,
  unsigned long  *from_lng,
  int  from_schema,
  char  *from_entnam,
  char  **join_to,
  unsigned long  *to_lng,
  int  to_schema,
  char  *to_entnam,
  int  *outer_join);

/* From f_init_drag.c */
extern int dba_init_drag (
  int  window,
  int  *x_min,
  int  *y_min,
  int  *x_max,
  int  *y_max);

/* From f_main_menu.c */
extern int main_menu (
  int  option);

/* From f_pick_table.c */
extern int pick_table (
  int  option,
  int  function);

/* From f_pm.c */
extern int dba_process_menu_form (
  int  option);

/* From get_evnt.c */
extern int dba_get_event (
  int  window,
  int  *same,
  int  *x,
  int  *y,
  int  *button,
  int  *work_status,
  int  allow_keyin,
  int  x_min,
  int  y_min,
  int  x_max,
  int  y_max,
  int  x_loc,
  int  y_loc);

/* From i_admin.c */
extern int dba_init_admin (
);

/* From i_privat.c */
extern int dba_init_private (
);

/* From i_runtim.c */
extern int dba_init_runtime (
);

/* From init_bld.c */
extern int dba_init_builders (
);

/* From loadscr.c */
extern int dba_load_script (
  char  *library,
  char  *template);

/* From logkbd.c */
extern int dba_logical_keyboard(
);
extern int dba_get_keyboard_data (
  char  *character,
  int  *count,
  int  font_type);
extern dba_talk_to_kb(
  char	 *character,
  int	 *count);

/* From move_tab.c */
extern int dba_move_reltab (
);

/* From n_admin.c */
extern int dba_notify_admin (
  int  form_label);

/* From n_runtim.c */
extern int dba_notify_runtime (
  int  form_label);

/* From new_join.c */
extern int dba_new_reljoin (
);
extern int dba_get_reljoin (
  int option);
extern int dba_new_reltab (
  int  schema,
  char  *table);
extern int dba_get_reltab_origin (
  int  *x,
  int  *y);

/* From pnt_rel.c */
extern int dba_paint_relations (
);
extern int dba_paint_reltabs (
);
extern int dba_paint_reljoins (
);
extern int dba_paint_reltab (
  Form  fpt,
  struct dba_reltab  *reltab);
extern int dba_paint_reljoin (
  Form  fpt,
  struct dba_reltemp  *reltemp,
  struct dba_reljoin  *reljoin);
extern int dba_delete_relation (
  int  label);
extern int dba_check_relcol (
  int  group,
  char  *text,
  int  *label);
extern int dba_scale_relations (
  Form  fpt,
  struct standard_st  *std_gadg);

/* From proc_db.c */
extern int dba_process_db (
);

/* From prodname.c */
extern int dba_set_prodname (
  char  *name);

/* From risrpt.c */
extern dba_risrpt (
  int  argc,
  char  *argv[]);

/* From rundba.c */
extern dba_rundba (
  int  argc,
  char  *argv[]);

/* From s_admin.c */
extern void dba_setup_admin (
);

/* From s_runtim.c */
extern void dba_setup_runtime (
);

/* From savclean.c */
extern int dba_scr_cleanup_after_save (
);

/* From save_all.c */
extern int dba_admin_save_all (
);

/* From scrpterr.c */
extern int dba_script_error_form (
  long  option);

/* From shellvars.c */
extern char *dba_expand_shell_vars (
  char  *unexpanded_filename);

/* From start_stop.c */
extern int dba_start_stop (
);

/* From syncverb.c */
extern int dba_sync_verbose_forms (
);

/* From u_l_join.c */
extern int dba_update_like_joins (
  char  *from,
  struct dba_ent  *fent,
  char  *to,
  struct dba_ent  *tent,
  int  outer);

/* From verb_dv.c */
extern int dba_script_verbose (
  long  option);

/* From writ_rel.c */
extern int dba_write_relations (
  char  *library,
  char  *template,
  int  verify_lib,
  int  verify_temp);

/* From write_opt.c */
extern int dba_write_options (
  char  *library,
  char  *template,
  int  verify_lib,
  int  verify_temp);

/* From writescr.c */
extern int dba_write_script (
  char  *library,
  char  *template,
  int  verify_lib,
  int  verify_temp);

#endif
