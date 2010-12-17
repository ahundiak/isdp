#ifndef debug_pro
#define debug_pro

/* From bldtpfld.c */
extern long dba_build_script_template_field (
  Form  fpt,
  long  label);

/* From brkpoint.c */
extern long dba_is_break_on_function (
  char  *name,
  long  hash,
  brk_func_list  **lst);
extern long dba_is_break_on_line (
  char  *name,
  long  hash,
  long  line);
extern long dba_brk_paint_linebreaks (
  Form  fpt,
  long  lab,
  char  *name);
extern long dba_brk_hilite_breaks (
  Form  fpt,
  long  lab,
  char  *name);
extern void dba_add_break_on_function (
  char  *name,
  long  hash,
  brk_func_list  *lst,
  brk_func_list  **rlst);
extern int dba_add_function_break (
  char  *name);
extern void dba_del_break_on_function (
  char  *name,
  long  hash,
  brk_func_list  *lst);
extern void dba_add_break_on_line (
  char  *name,
  long  hash,
  brk_func_list  *func,
  brk_func_list  **rfunc,
  long  line);
extern void dba_del_break_on_line (
  char  *name,
  long  hash,
  brk_func_list  *func,
  long  line);
extern void dba_brk_save_breaks (
);
extern void dba_brk_restore_breaks (
);
extern void dba_brk_clear_breaks (
);
extern void dba_brk_clear_break_array (
  brk_func_list  **farray);
extern void dba_brk_copy_break_array (
  brk_func_list  **sfarray,
  brk_func_list  **dfarray,
  brk_func_list  **dlarray);
extern void dba_brk_add_func_node (
  brk_func_list  **farray,
  brk_func_list  **larray,
  brk_func_list  **node,
  long  hash);
extern void dba_brk_del_func_node (
  brk_func_list  **farray,
  brk_func_list  **larray,
  brk_func_list  *node,
  long  hash);
extern void dba_brk_add_line_node (
  brk_func_list  *func,
  long  line);
extern void dba_brk_del_line_node (
  brk_func_list  *func,
  long  line);
extern void dba_brk_link_func_node (
  brk_func_list  **farray,
  brk_func_list  **larray,
  brk_func_list  *node,
  long  hash);
extern void dba_brk_unlink_func_node (
  brk_func_list  **farray,
  brk_func_list  **larray,
  brk_func_list  *node,
  long  hash);
extern void dba_brk_link_line_node (
  brk_func_list  *func_node,
  brk_line_list  *line_node);
extern void dba_brk_unlink_line_node (
  brk_func_list  *func,
  long  line,
  brk_line_list  **node);

/* From debug.c */
extern int dba_bug_inq_active (
);
extern int dba_bug_activate_debug(
);
extern dba_bug_deactivate_debug(
);
extern int dba_bug_set_function (
  functiontype  *function);
extern int dba_bug_set_sourceline (
  operationtype  *operation);
extern long dba_bug_hilite_sourceline (
  long  line,
  long  hilite_flag);
extern long dba_bug_set_field_view (
  Form  fpt,
  long  label,
  long  row);
extern long dba_script_debug (
  long  option);
extern int dba_bug_wait (
);
extern int dba_bug_get_action (
);
extern int dba_bug_command_buttons (
  int  state);
extern long dba_breakpoints (
  long  option);
extern int dba_bug_no_tag_break (
  int  state);
extern int dba_bug_is_func_break (
  char  *name,
  long  hash,
  long  tag);
extern int dba_bug_is_line_break (
  char  *name,
  long  hash,
  long  line);
extern int dba_bug_activate_break (
);
extern int dba_bug_deactivate_break (
);
extern long dba_bug_edit_line_breaks (
  long  mode);
extern char *dba_get_dimension_text (
  operandtype  *ptrop);
extern int dba_bug_dealloc_vars (
  functiontype  *function);
extern void dba_bug_paint_scalar_value (
  operandtype  *op,
  void  *value,
  Form  fpt,
  int  lab,
  int  row,
  int  col,
  int  sel);
extern void dba_bug_paint_type (
  functiontype  *f,
  operandtype  *op,
  int  storage,
  Form  fpt,
  int  lab,
  int  row,
  int  col,
  int  sel);
extern void dba_bug_free_var_recs (
  dba_var_rec_type  *rec);
extern void dba_bug_paint_array (
  Form  fpt,
  int  lab,
  int  *row,
  int  indent,
  functiontype  *f,
  operandtype  *op,
  void  *value,
  dba_var_rec_type  *parent_rec,
  char  *str_name);
extern void dba_bug_paint_structure (
  Form  fpt,
  int  lab,
  int  *row,
  int  indent,
  functiontype  *f,
  operandtype  *op,
  void  *value,
  dba_var_rec_type  *parent_rec);
extern void dba_bug_paint_pointer (
  Form  fpt,
  int  lab,
  int  *row,
  int  indent,
  functiontype  *f,
  operandtype  *op,
  void  *value,
  dba_var_rec_type  *parent_rec);
extern long dba_review_variables (
  long  option);
extern long dba_bug_update_variables (
  long  clr);
extern long dba_bug_build_var_list (
  Form  fpt,
  long  lab,
  char  *name,
  long  clr);

/* From i_debug.c */
extern int dba_init_debug (
);

/* From mainscrd.c */

/* From n_debug.c */
extern int dba_notify_debug (
  int  form_label);

/* From s_debug.c */
extern void dba_setup_debug (
);

#endif
