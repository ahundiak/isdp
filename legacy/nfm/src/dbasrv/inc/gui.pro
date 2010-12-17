#ifndef gui_pro
#define gui_pro

/* From a_f_gadg.c */
extern int dba_add_forms_gadget (
  char  *menu,
  int  label);
extern int dba_add_dba_forms_gadget (
  int  mnunum,
  int  label);

/* From a_rectmp.c */
extern int dba_add_recent_template (
  int  type,
  char  *template);

/* From act_menu.c */
extern int dba_activate_menu (
  char  *name,
  int  from_cancel);

/* From bld_u_list.c */
extern int dba_build_system_list (
  char  *menu,
  int  label,
  char  *command);

/* From butnot.c */
extern int dba_button_notify(
  Form form,
  int xpos,
  int ypos,
  int button,
  int trans,
  int t_tag);

/* From can_chld.c */
extern int dba_cancel_child_menus (
  char  *menu);

/* From clear_fld.c */
extern int dba_clear_field (
  Form  fpt,
  int  label);

/* From clpsorg.c */
extern int dba_get_collapse_org (
  int  window,
  int  *clps_x,
  int  *clps_y);

/* From clr_msg.c */
extern int dba_clear_msg (
);

/* From clr_prom.c */
extern int dba_clear_prompt (
);

/* From create_group.c */
extern int dba_create_group (
  int  mnunum,
  int  group_label,
  int  set,
  int  options);

/* From cvt_font.c */
extern int dba_convert_font (
  char  *out,
  char  *in,
  unsigned long  font_mask);

/* From dbd_act_pos.c */
extern dba_active_position (
  int  *row,
  int  *col);

/* From dbd_cancel.c */
extern int dba_cancel (
  char  *menu);

/* From dbd_message.c */
extern int dba_print_message (
  char  *msg);

/* From dbd_put_fld.c */
extern int dba_put_field (
  char  *menu,
  int  label,
  int  row,
  int  col,
  char  *buf);

/* From dbd_yes_no.c */
extern int dba_get_yes_no (
  char  *question,
  int  color);

/* From def_fld_opt.c */
extern int dba_default_field_options (
  int  option,
  struct dba_gadget  *gadg);

/* From del_gadg_ptr.c */
extern int dba_delete_gadget_ptr (
  struct dba_gadget  **fgadget,
  struct dba_gadget  **lgadget,
  struct dba_gadget  *gadg);

/* From del_menu.c */
extern int dba_delete_menu (
  char  *menu);
extern dba_delete_menu_number (
  int  mnunum);

/* From df_dsply.c */
extern int dba_f_display (
  Form  fpt,
  int  mnunum);

/* From df_gtloc.c */
extern int dba_f_get_location (
  Form  fpt,
  int  *x,
  int  *y);

/* From df_stloc.c */
extern int dba_f_set_location (
  Form  fpt,
  int  x,
  int  y);

/* From disp_panel.c */
extern int dba_display_panel (
  Form  fpt,
  int  label);

/* From display_menu.c */
extern int dba_display_menu (
  char  *menu,
  int  preserve);

/* From e_gui.c */
extern int dba_exit_gui (
);

/* From erase_panel.c */
extern int dba_erase_panel (
  Form  fpt,
  int  label);

/* From err_box.c */
extern int dba_error_box (
  char  *errtxt);

/* From err_form.c */
extern int dba_error_form (
  int  option);

/* From f_add_er.c */
extern int dba_gui_add_error (
  char  *message);

/* From f_add_gadg.c */
extern int dba_add_gadget (
  struct dba_gadget  **fgadget,
  struct dba_gadget  **lgadget,
  struct dba_gadget  *gadg,
  struct dba_gadget  *cgadg);

/* From f_add_row.c */
extern int dba_add_row (
  Form  fpt,
  int  label,
  int  option,
  char  *text_ptr);

/* From f_all_label.c */
extern int dba_all_label (
  int  mnunum,
  int  type,
  int  *label_ptr,
  struct dba_gadget  **gadg,
  int  first);

/* From f_bld_tmplst.c */
extern int dba_build_template_list (
  Form  form,
  int  type,
  int  label);

/* From f_ck_ras.c */
extern int dba_ck_raster(
  int  form_label,
  int  event,
  Form  form);

/* From f_cre_ga.c */
extern int dba_create_gadget (
  Form  fpt,
  struct dba_gadget  *gadg,
  int  mnunum);

/* From f_cre_menu.c */
extern int dba_create_menu (
  int  mnunum,
  int  x,
  int  y,
  int  width,
  int  height,
  int  mask,
  int  color,
  char  *file,
  int  icon,
  int  clps_x,
  int  clps_y);
extern int dba_window_event_routine(
  int form_label,
  int flag,
  Form fpt);

/* From f_disp_rast.c */
extern int dba_display_raster (
  int  mnunum);

/* From f_disrpt.c */
extern int dba_display_report (
  char  *output);

/* From f_flush.c */
extern int dba_flush (
  int  window);

/* From f_form_error.c */
extern int dba_form_error (
  int  status,
  char  *form);

/* From f_get_field.c */
extern int dba_get_field_text (
  Form  fpt,
  int  label,
  int  row,
  int  column,
  unsigned long  *size_ptr,
  char  **char_ptr,
  int  option,
  int  strip);

/* From f_get_fldtxt.c */
extern int get_multi_row_text (
  Form  fpt,
  int  label,
  int  column,
  char  **text_ptr,
  unsigned long  *size_ptr,
  char  *delimiter,
  int  option);

/* From f_get_label.c */
extern int dba_get_label (
  int  mnunum,
  int  type,
  int  *label_ptr,
  struct dba_gadget  **gadg);
extern int dba_get_worksheet_label (
  int  mnunum,
  int  *label_ptr,
  struct dba_gadget  **gadg,
  int  first);

/* From f_get_menu.c */
extern int dba_get_menu (
  Form  fpt,
  int  *x,
  int  *y,
  int  *width,
  int  *height,
  long  *mask,
  int  *color,
  char  *file,
  int  *icon,
  int  *clps_x,
  int  *clps_y);

/* From f_gui.c */
extern int dba_free_gui (
);

/* From f_init_not.c */
extern int dba_init_notify (
  int  form_label,
  int  label,
  double  value,
  Form  fpt);

/* From f_load_menu.c */
extern int dba_load_menu (
  char  *library,
  char  *template);
extern int dba_get_broken_record (
  struct dba_library  *lib_ptr,
  char  **stext,
  unsigned long  *st_size);
extern int dba_get_menu_header (
  struct dba_library  *lib_ptr,
  struct dba_menu_hdr  *hdr_ptr);

/* From f_lst_rtb.c */
extern int dba_list_rtblib (
  int  type,
  int  menu_option,
  int  displayed_check);

/* From f_map_char.c */
extern unsigned char dba_map_character (
);

/* From f_menu_num.c */
extern int dba_set_mnunum (
  char  *name);

/* From f_msg_strip.c */
extern int dba_message_form (
  int  option);

/* From f_output.c */
extern int dba_list_output (
  int  option,
  char  *filename);
extern int dba_add_output (
  int  option);

/* From f_pass_echo.c */
extern void dba_pswd_echo (
  Form  fpt,
  int  pswd);
extern void dba_pswd_noecho (
  Form  fpt,
  int  pswd);

/* From f_playback.c */
extern int dba_playback (
  char  *filename);

/* From f_pm_exit.c */
extern int dba_pm_exit (
  int  erase_all);

/* From f_set_check.c */
extern int dba_set_checklist (
  Form  fpt,
  struct dba_gadget  *gadg,
  int  mnunum);

/* From f_set_fldtxt.c */
extern int set_multi_row_text (
  Form  form_ptr,
  int  label,
  int  column,
  char  *text_ptr,
  char  *delimiter,
  int  option);

/* From f_set_lines.c */
extern int dba_set_lines (
  Form  form_ptr,
  struct dba_gadget  *gadg_ptr);

/* From f_set_scroll.c */
extern int dba_set_scrollbar (
  Form  fpt,
  struct dba_gadget  *gadg);

/* From f_set_slider.c */
extern int dba_set_slider (
  Form  fpt,
  struct dba_gadget  *gadg);

/* From f_set_text.c */
extern int dba_set_text_size (
  Form  fpt,
  int  text_num);

/* From f_set_toggle.c */
extern int dba_set_toggle (
  Form  fpt,
  struct dba_gadget  *gadg);

/* From f_text_size.c */
extern int dba_text_size_form (
  int  option,
  Form  fpt);
extern int dba_paint_text_size (
  Form  fpt);

/* From f_title.c */
extern int dba_set_dialog_title(
  Form  fpt,
  char  *title);

/* From f_x_form.c */
extern int dba_x_form (
  Form  form,
  char  *name);

/* From f_xsync.c */
extern int dba_xsync (
  int  discard);

/* From f_yes_no.c */
extern int dba_yes_no (
  long  msgnum,
  char  *insert_ptr,
  int  red);

/* From form_scl.c */
extern int dba_form_scale (
  int  label,
  Form  fpt,
  int  built_x,
  int  built_y,
  int  init_x,
  int  init_y);

/* From g_active.c */
extern int dba_get_active_col (
  Form  fpt,
  int  label,
  int  *col,
  int  *pos);
extern int dba_get_active_row (
  Form  fpt,
  int  label,
  int  *row,
  int  *pos);

/* From g_curmnu.c */
extern int dba_get_current_menu (
  char  *menu);

/* From g_iforms.c */
extern int dba_get_iforms_gadget (
  int  mnunum,
  struct dba_gadget  *gadg);

/* From g_keyin.c */
extern int dba_get_keyin (
  char  *prompt,
  char  *keyin);

/* From gadg_siz.c */
extern int dba_get_gadget_size (
  struct dba_gadget  *gadg);

/* From gadget_type.c */
extern int dba_get_gadget_type (
  int  mnunum,
  int  label,
  int  *type_ptr);

/* From get_fi_err.c */
extern char *dba_get_fi_error_msg (
  int  err);

/* From get_help.c */
extern int dba_get_help (
  Form  fpt,
  int  label);

/* From get_keyin.c */
extern int dba_get_last_keyin (
  char  **text_ptr);

/* From get_mnunum.c */
extern int dba_get_mnunum (
  char  *menu,
  int  *mnunum);

/* From get_next.c */
extern int dba_get_next_label (
  int  mnunum,
  int  *label_ptr);

/* From grid_gdg.c */
extern int dba_create_grid (
  Form  fpt,
  struct dba_gadget  *gadg);

/* From grp_disp.c */
extern int dba_display_group (
  struct dba_gadget  *gadg);

/* From gui_g.c */
extern int dba_gui_gadgets (
  int  option,
  int  mnunum);

/* From gui_util.c */
extern int dba_util_get_yes_no (
  char  *question);
extern int dba_FIfld_pos_cursor (
  Form  fpt,
  int  label,
  int  row,
  int  r_pos,
  int  col,
  int  col_pos,
  int  ch,
  int  ch_pos);
extern int dba_FIfld_set_list_default_text_kludge (
  Form  fpt,
  int  label,
  int  row,
  int  col,
  char  *text,
  int  sel);
extern int dba_FIfld_set_list_text_kludge (
  Form  fpt,
  int  label,
  int  row,
  int  col,
  char  *text,
  int  sel);
extern void dba_ovrd_FIf_arg (
  void  **args,
  char  *types);
extern long dba_exp_FIfld_get_text (
  genstacktype  *stack,
  void  **args,
  char  *types,
  int  *override_flag,
  int  *override_value);
extern long dba_exp_FIg_get_text (
  genstacktype  *stack,
  void  **args,
  char  *types,
  int  *override_flag,
  int  *override_value);
extern long dba_exp_FIg_get_on_text (
  genstacktype  *stack,
  void  **args,
  char  *types,
  int  *override_flag,
  int  *override_value);
extern long dba_exp_FIg_get_off_text (
  genstacktype  *stack,
  void  **args,
  char  *types,
  int  *override_flag,
  int  *override_value);
extern long dba_trans_fpt_arg (
  operandtype  *ptrop,
  void  *valptr,
  Form  **arg_ptr,
  Form  **alloc_ptr,
  int  alloc_size,
  char  *func_name,
  int  *ret_override_flag,
  int  *ret_override_value);
extern long dba_trans_menu_arg (
  operandtype  *ptrop,
  void  *valptr,
  char  ***arg_ptr,
  char  ***alloc_ptr,
  int  alloc_size,
  char  *func_name,
  int  *ret_override_flag,
  int  *ret_override_value);
extern long dba_trans_menu_arg_no_zero (
  operandtype  *ptrop,
  void  *valptr,
  char  ***arg_ptr,
  char  ***alloc_ptr,
  int  alloc_size,
  char  *func_name,
  int  *ret_override_flag,
  int  *ret_override_value);
extern long dba_get_fpt_from_arg (
  functiontype  *function,
  long  opnum,
  Form  *fpt,
  char  *func_name);
extern long dba_get_std_fi_args (
  functiontype  *function,
  long  opnum,
  Form  *fpt,
  long  *label,
  char  *func_name);
extern long dba_get_3_fi_args (
  functiontype  *function,
  long  opnum,
  Form  *fpt,
  long  *label,
  long  *arg,
  char  *func_name);
extern long dba_get_4_fi_args (
  functiontype  *function,
  long  opnum,
  Form  *fpt,
  long  *label,
  long  *arg1,
  long  *arg2,
  char  *func_name);
extern long dba_get_5_fi_args (
  functiontype  *function,
  long  opnum,
  Form  *fpt,
  long  *label,
  long  *arg1,
  long  *arg2,
  long  *arg3,
  char  *func_name);

/* From hilite.c */
extern int dba_hilite (
  Form  fpt,
  struct dba_gadget  *gadg);
extern int dba_unhilite (
  Form  fpt,
  struct dba_gadget  *gadg);

/* From i_gui.c */
extern int dba_init_gui (
);

/* From invok_menu.c */
extern int dba_get_invoking_menu (
  char  *menu,
  char  *invoking_menu);
extern int dba_set_invoking_menu (
  char  *menu,
  char  *invoking_menu);

/* From is_left.c */
extern int dba_is_left_justify (
  int  type);

/* From is_user.c */
extern int dba_is_user_gadget (
  int  type);

/* From lib_form.c */
extern int dba_lib_form (
  int  type,
  int  option,
  int  dm);
extern int dba_paint_type_list (
  Form  fpt,
  int  label);

/* From lkmnudsp.c */
extern int dba_lock_menu_display (
  int  locked,
  Form  fpt,
  int  mnunum);
extern void dba_set_form (
  Form  fpt,
  int  mnunum);

/* From lockmenu.c */
extern int dba_lock_menu (
  char  *menu,
  int  flag);

/* From mal_gui.c */
extern int dba_malloc_gadget (
  struct dba_gadget  **gadg,
  struct dba_gadget  *in_gadg_ptr);

/* From mb_notfy.c */
extern int dba_mb_notify (
  int  menu_label,
  int  label,
  double  value,
  Form  fpt);

/* From menu_by_name.c */
extern int dba_get_menu_by_name (
  char  *menu,
  Form  *form,
  int  *label);

/* From menu_new.c */
extern int dba_menu_new (
  int  label,
  char  *name,
  int  (*notify)(),
  Form  *fpt);

/* From n_after.c */
extern int dba_set_after_notify (
  int  (*after_notify)());

/* From n_all.c */
extern int dba_notify_all (
  int  form_label);

/* From n_before.c */
extern int dba_set_before_notify (
  int  (*before_notify)());

/* From n_gui.c */
extern int dba_notify_gui (
  int  form_label);

/* From new_fi.c */
extern int dba_register_fi (
);

/* From normal_text.c */
extern int dba_change_to_normal (
  Form  fpt,
  int  label,
  int  dummy);
extern int dba_set_normal_text (
  Form  fpt);

/* From notify.c */
extern int dba_notify (
  int  form_label,
  int  label,
  double  value,
  Form  fpt);
extern int dba_save_notify_env(
);
extern int dba_restore_notify_env(
);

/* From p_liblst.c */
extern int dba_paint_lib_list (
  Form  fpt,
  int  label);

/* From parse_spec.c */
extern int dba_parse_spec (
  int  schema,
  char  **in_ptr,
  char  *out_ptr,
  int  number);

/* From pop_to_bot.c */
extern int dba_pop_to_bottom (
  char  *menu);

/* From pop_to_top.c */
extern int dba_pop_to_top (
  char  *menu);

/* From prn_msg.c */
extern int dba_print_msg (
  char  *message);

/* From prn_prom.c */
extern int dba_print_prompt (
  char  *prompt_text);

/* From prn_stat.c */
extern int dba_print_status (
  char  *status_text);

/* From process.c */
extern dba_process (
);

/* From prtfil.c */
extern int dba_print_file (
  char  *filename);

/* From redraw.c */
extern int dba_set_menu_redraw(
  char *menu_name,
  int flag);
extern int dba_set_gadget_redraw(
  char *menu_name,
  int gadget_label,
  int flag);
extern int dba_menu_redraw(
  Form form,
  int flag);
extern int dba_gadget_redraw(
  Form form,
  int gadget_label,
  int flag);

/* From reg_gui.c */
extern int dba_reg_form_arg_simple (
  char  *name);
extern int dba_register_gui(
);

/* From reg_gui2.c */

/* From s_bitmap.c */
extern int dba_set_bitmap (
  Form  fpt,
  struct dba_gadget  *gadg);

/* From s_butscr.c */
extern int dba_setup_button_script(
  char *button_script);

/* From s_dial.c */
extern int dba_set_dial (
  Form  fpt,
  struct dba_gadget  *gadg);

/* From s_gauge.c */
extern int dba_set_gauge (
  Form  fpt,
  struct dba_gadget  *gadg);

/* From s_getfld.c */
extern long dba_s_get_field (
  functiontype  *bfunc,
  functiontype  *function,
  long  opnum);

/* From s_gui.c */
extern void dba_setup_gui (
);

/* From s_keyin.c */
extern long dba_s_get_keyin (
  functiontype  *bfunc,
  functiontype  *function,
  long  opnum);

/* From s_keyscr.c */
extern int dba_setup_key_script(
  char *key_script);

/* From s_lastky.c */
extern long dba_s_get_last_keyin (
  functiontype  *bfunc,
  functiontype  *function,
  long  opnum);

/* From s_putfld.c */
extern long dba_s_put_field (
  functiontype  *bfunc,
  functiontype  *function,
  long  opnum);

/* From sav_temp.c */
extern int dba_save_template (
  int  option,
  int  type,
  int  function);

/* From scale8.c */
extern dba_scaleraster8(
  char  *source,
  int  sx,
  int  sy,
  char  *dest,
  int  dx,
  int  dy);

/* From scrap.c */
extern int dba_put_scrap (
  char  *type,
  char  *data,
  int  size);
extern int dba_get_scrap (
  char  *type,
  char  *buffer,
  int  *buffer_size,
  int  *index);

/* From scrkform.c */
extern int dba_script_keyin_form (
  int  option);

/* From set_after.c */
extern int dba_set_after_script (
  char  *menu,
  int  label,
  char  *script);

/* From set_before.c */
extern int dba_set_before_script (
  char  *menu,
  int  label,
  char  *script);

/* From set_clps.c */
extern int dba_set_collapse (
  int  mnunum,
  char  *file,
  int  icon,
  int  clps_x,
  int  clps_y);

/* From set_curmenu.c */
extern int dba_set_current_menu (
  char  *menu);

/* From set_gadg_ptr.c */
extern int dba_set_gadg_ptr (
  int  mnunum,
  int  label,
  struct dba_gadget  **gadg);

/* From set_m_sc.c */
extern int dba_set_menu_script (
  char  *menu,
  char  *script);

/* From set_mcf.c */
extern int dba_set_mcf_columns (
  Form  fpt,
  int  label,
  int  columns,
  int  column_scroll);

/* From set_menu.c */
extern int dba_set_menu (
  int  form_label,
  int  label,
  int  itype);
extern int dba_validate_field_input (
  struct dba_gadget  *gadg,
  int  itype);

/* From set_spin.c */
extern int dba_set_spin_box (
  Form  fpt,
  struct dba_gadget  *gadg);

/* From set_ufld.c */
extern int dba_set_user_field (
  Form  fpt,
  struct dba_gadget  *gadg);

/* From set_umcf.c */
extern int dba_set_user_mcf (
  Form  fpt,
  struct dba_gadget  *gadg);

/* From topmost.c */
extern int dba_pop_to_topmost (
  char  *menu);
extern int dba_pop_form_to_topmost (
  Form  fpt);

/* From wrap_text.c */
extern int dba_get_wrap_text (
  Form  fpt,
  int  label,
  int  column,
  char  **text_ptr,
  unsigned long  *size_ptr,
  int  strip);

#endif
