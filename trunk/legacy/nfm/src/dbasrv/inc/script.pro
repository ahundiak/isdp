#ifndef script_pro
#define script_pro

/* From bind.c */
extern long dba_bind_function (
  functiontype  *function);

/* From builtin.c */
extern long dba_lookup_builtin_function (
  char  *name,
  long  hash,
  dba_func_ref_desc  *fn_ptr);

/* From callfunc.c */
extern long dba_call_function (
  dba_func_list  *tfunc,
  functiontype  *pfunc,
  long  popnum);
extern void dba_dump_scr_callstack (
);

/* From callreg.c */
extern long dba_call_registered_function (
);

/* From cftime.c */
extern int dba_cftime (
);

/* From cknumarg.c */
extern int dba_check_num_arguments (
  functiontype  *bfunc,
  functiontype  *function,
  long  opnum,
  long  num);
extern long dba_check_min_num_arguments (
  functiontype  *bfunc,
  functiontype  *function,
  long  opnum,
  long  num);
extern long dba_check_max_num_arguments (
  functiontype  *bfunc,
  functiontype  *function,
  long  opnum,
  long  num);

/* From codegen1.c */
extern void dba_gen_numeric_constant (
  char  *token,
  char  *fmt,
  long  type);
extern void dba_gen_char_constant (
  char  *token);
extern void dba_gen_string_constant (
  char  *token);
extern void dba_gen_bef_postfix_subscript (
);
extern void dba_gen_aft_postfix_subscript (
);
extern void dba_gen_unary_inc_dec (
  long  inc,
  long  post);
extern void dba_gen_logical_negation (
);
extern void dba_gen_relational (
  long  gen_op);
extern void dba_gen_unary_minus (
  long  neg);
extern void dba_gen_multiplicative (
  long  gen_op,
  long  dealloc);
extern void dba_gen_addition (
  long  dealloc);
extern void dba_gen_assignment (
);
extern void dba_gen_address_of (
  long  dealloc);
extern void dba_gen_primary_expr_identifier (
);
extern void dba_gen_bad_string_literal (
);
extern void dba_gen_function_call_no_arg (
);
extern void dba_gen_function_call_bef_args (
);
extern void dba_gen_function_call_aft_args (
);
extern void dba_gen_member_expression (
);
extern void dba_gen_argument_expr_wrap_up (
);
extern void dba_gen_ones_complement (
);
extern void dba_gen_dereference (
  long  dealloc);
extern void dba_gen_unary_expression (
);
extern void dba_gen_sizeof_expression (
);
extern void dba_gen_sizeof_type_setup (
);
extern void dba_gen_sizeof_type_wrap_up (
);
extern void dba_gen_push_address_of (
);
extern void dba_gen_push_dereference (
);
extern void dba_gen_push_plus (
);
extern void dba_gen_push_minus (
);
extern void dba_gen_push_ones_complement (
);
extern void dba_gen_push_logical_negation (
);
extern void dba_gen_cast_setup (
);
extern void dba_gen_cast_type (
);
extern void dba_gen_cast_expression (
);
extern void dba_gen_subtraction (
  long  dealloc);
extern void dba_gen_shift (
  long  gen_op,
  long  dealloc);
extern void dba_gen_bitwise (
  long  gen_op,
  long  dealloc);
extern void dba_gen_logical_and1 (
);
extern void dba_gen_logical_and2 (
);
extern void dba_gen_logical_or1 (
);
extern void dba_gen_logical_or2 (
);

/* From codegen2.c */
extern void dba_gen_conditional_condition (
);
extern void dba_gen_conditional_true (
);
extern void dba_gen_conditional_false (
);
extern void dba_gen_assignment_expression (
);
extern void dba_gen_push_assignment (
);
extern void dba_gen_push_multiply_assign (
);
extern void dba_gen_push_divide_assignment (
);
extern void dba_gen_push_modulus_assignment (
);
extern void dba_gen_push_addition_assign (
);
extern void dba_gen_push_subtract_assign (
);
extern void dba_gen_push_left_shift_assign (
);
extern void dba_gen_push_right_shift_assign (
);
extern void dba_gen_push_bitwise_and_assign (
);
extern void dba_gen_push_xor_assign (
);
extern void dba_gen_push_bitwise_or_assign (
);
extern void dba_gen_comma_wrap_up (
);
extern void dba_gen_declaration_spec_setup (
);
extern void dba_gen_declarator (
  long  repush);
extern void dba_gen_declarator_initialize (
);
extern void dba_gen_typedef (
);
extern void dba_gen_external_storage (
);
extern void dba_gen_static_storage (
);
extern void dba_gen_automatic_storage (
);
extern void dba_gen_register_storage (
);
extern void dba_gen_constant_storage (
);
extern void dba_gen_char_type (
);
extern void dba_gen_short_type (
);
extern void dba_gen_int_type (
);
extern void dba_gen_long_type (
);
extern void dba_gen_signed_qualifier (
);
extern void dba_gen_unsigned_qualifier (
);
extern void dba_gen_float_type (
);
extern void dba_gen_double_type (
);
extern void dba_gen_volatile_qualifier (
);
extern void dba_gen_void_type (
);
extern void dba_gen_enumeration_type (
);
extern void dba_gen_user_type (
);
extern void dba_gen_struct_union_define_tag (
);
extern void dba_gen_struct_union_def_body (
);
extern void dba_gen_struct_union_anon_body (
);
extern void dba_gen_struct_union_tag (
);
extern void dba_gen_struct_type (
);
extern void dba_gen_union_type (
);
extern void dba_gen_struct_body_setup (
);
extern void dba_gen_struct_body (
);
extern void dba_gen_array_type (
);
extern void dba_gen_function_declaration (
);
extern void dba_gen_pointer (
);
extern void dba_gen_identifier_list (
);
extern void dba_gen_labeled_statement (
);
extern void dba_gen_case_setup (
);
extern void dba_gen_case_expression (
);
extern void dba_gen_default_expression (
);
extern void dba_gen_compound_statement_decl (
);
extern void dba_gen_compound_stmt_setup (
);
extern void dba_gen_compound_stmt_wrap_up (
);
extern void dba_gen_declaration_list (
);
extern void dba_gen_expression_wrap_up (
);
extern void dba_gen_if_expression (
);
extern void dba_gen_switch_expression (
);
extern void dba_gen_while_expression_setup (
);
extern void dba_gen_while_expr_wrap_up (
);
extern void dba_gen_for_expression_1 (
);
extern void dba_gen_for_expression_2_setup (
);
extern void dba_gen_for_expr_2_wrap_up (
);
extern void dba_gen_for_expression_3_setup (
);
extern void dba_gen_for_expr_3_wrap_up (
);
extern void dba_gen_if_statement_no_else (
);
extern void dba_gen_if_then_statement (
);
extern void dba_gen_if_else_statement (
);
extern void dba_gen_switch (
);
extern void dba_gen_switch_statement (
);
extern void dba_gen_while (
);
extern void dba_gen_while_statement (
);
extern void dba_gen_do_setup (
);
extern void dba_gen_do_before_expression (
);
extern void dba_gen_do_after_expression (
);
extern void dba_gen_for_0 (
);
extern void dba_gen_for_statement_0 (
);
extern void dba_gen_for_statement_1 (
);
extern void dba_gen_for_2 (
);
extern void dba_gen_for_statement_2 (
);
extern void dba_gen_for_statement_3 (
);
extern void dba_gen_for_6 (
);
extern void dba_gen_goto (
);
extern void dba_gen_continue (
);
extern void dba_gen_break (
);
extern void dba_gen_return_void (
);
extern void dba_gen_return_expression (
);
extern void dba_gen_function_setup (
);
extern void dba_gen_function_wrap_up (
);
extern void dba_gen_func_decl_list_setup (
);
extern void dba_gen_identifier (
  char  *txt);

/* From comperr.c */
extern int dba_script_new_error (
  char  *txt);
extern long dba_script_new_warning (
  char  *txt);
extern long dba_script_store_error (
  char  *txt,
  int  lvl);
extern long dba_script_clear_errors (
);
extern int dba_get_num_script_errors (
  int  *num_errs);
extern int dba_get_script_error (
  int  num,
  char  **msg_ptr,
  long  *line_ptr,
  long  *col_ptr,
  int  *type_ptr);

/* From compfile.c */
extern int dba_compile_editor_or_file (
  int  from_file,
  char  *name);

/* From compile.c */
extern int dba_compile_script (
  char  *name);
extern int dba_compile_from_file (
  char  *filename);

/* From compound.c */
extern long dba_add_compound_operand (
  functiontype  *function,
  compoundtype  *compound,
  operandtype  *operand,
  long  struct_flag);
extern long dba_is_compound_operand (
  functiontype  *function,
  compoundtype  *compound,
  char  *operand);
extern long dba_get_member_elesize (
  operandtype  *operand);
extern long dba_upload_struct2 (
  functiontype  *sfunction,
  compoundtype  *scompound,
  char  *sname,
  functiontype  *dfunction,
  long  *elesize);
extern long dba_upload_struct (
  functiontype  *sfunction,
  operandtype  *sptrop,
  functiontype  *dfunction,
  operandtype  *dptrop);
extern void dba_resolve_struct_members (
  genstacktype  *parent_stack,
  jumpstacktype  *index_stack,
  genstacktype  *name_stack);

/* From compscr.c */
extern long dba_internal_compile_script (
  char  *name,
  char  *oname);

/* From computil.c */
extern void dba_partial_init_compiler (
);
extern void dba_initialize_script_env (
);
extern void dba_init_compiler (
  int  option,
  char  *name,
  long  instance);
extern void dba_multiple_function (
);
extern int dba_compute_hash (
  char  *name);
extern void dba_token_push (
  char  *token);
extern char *dba_token_pop (
);
extern int dba_generic_check_label (
  genstacktype  *genstack,
  char  *ptr,
  gennodetype  **parent,
  gennodetype  **node);
extern void dba_clear_tmp_var_list (
);
extern void dba_alloc_tmp_var (
  functiontype  *function,
  long  size,
  operandtype  **operand,
  long  *retindex);
extern int dba_dealloc_tmp_var (
  long  size,
  long  index);
extern int dba_mark_tmp_for_dealloc (
  long  size,
  long  index);
extern void dba_dealloc_marked_vars (
);
extern int dba_get_info_from_token_stack (
  functiontype  *function,
  int  chk_lval,
  long  *index,
  operandtype  **operand,
  lvoid  *opaddr);
extern int dba_convert_ptr_to_int4 (
  functiontype  *function,
  operandtype  **op,
  long  *index,
  lvoid  *addr);
extern int dba_std_integral_promotion (
  functiontype  *function,
  operandtype  **op,
  long  *index,
  lvoid  *addr);
extern int dba_std_promote_from_stack (
  functiontype  *function,
  int  allow_ptr,
  int  ptr_req,
  int  chk_lval,
  long  *index,
  operandtype  **op,
  lvoid  *addr);
extern int dba_std_convert_from_stack (
  functiontype  *function,
  int  input_valid,
  int  multi_ptr_allow,
  int  multi_ptr_req,
  int  passive2,
  int  allow_ptr2,
  int  cvt_ptr2,
  int  never_cvt2,
  int  chk_lval2,
  long  *index2,
  operandtype  **op2,
  lvoid  *addr2,
  int  allow_ptr1,
  int  cvt_ptr1,
  int  never_cvt1,
  int  chk_lval1,
  long  *index1,
  operandtype  **op1,
  lvoid  *addr1);
extern int dba_force_operand_to_type (
  functiontype  *function,
  operandtype  *lop,
  long  *rindex,
  operandtype  **rop,
  lvoid  *raddr);
extern int dba_create_stack_space (
  functiontype  *function);
extern int dba_release_stack_space (
  functiontype  *function);
extern void dba_create_continue_stack (
);
extern void dba_create_break_stack (
);
extern void dba_restore_continue_stack (
);
extern void dba_restore_break_stack (
);
extern void dba_set_gotos_on_stack (
  jumpstacktype  *stack,
  functiontype  *function,
  long  loc);
extern void dba_scr_lookup_function (
  char  *name_in,
  char  *oname,
  dba_func_list  **retfunc,
  int  hash,
  int  verb_look,
  long  *found);
extern void dba_add_error_operand (
  functiontype  *function,
  char  *token,
  int  indir,
  long  *index,
  operandtype  **op,
  lvoid  *addr);
extern int dba_scr_generate_error (
  int  errcode,
  int  run);
extern void dba_scr_undef_symbol (
  char  *symbol);

/* From conv_io.c */
extern long dba_setup_convert_input (
  char  *name);
extern long dba_setup_convert_output (
  char  *name);
extern int dba_call_convert_func (
  int  outflg,
  int  schema_num,
  int  table_num,
  int  column_num,
  char  *value,
  int  length);

/* From d_verb.c */
extern int dba_set_verbose_on (
);
extern int dba_set_verbose_off (
);
extern int dba_set_verbose_mode (
  int  dload,
  int  resize,
  int  all,
  int  standard,
  int  dba,
  int  forms,
  int  nfm,
  int  ris);
extern int dba_get_verbose_state (
  int *state);

/* From dealloc.c */
extern long dba_deallocate_function (
  functiontype  *function);

/* From dumpstor.c */
extern void dba_dump_store (
  long  mode);

/* From dumpxref.c */
extern int dba_dump_script_xref (
);

/* From e_script.c */
extern void dba_exit_script(
);

/* From engine.c */
extern dba_script_engine (
  functiontype  *function,
  functiontype  *pfunc,
  long  popnum);

/* From export_s.c */
extern void dba_export_script_function (
  functiontype  *function,
  long  hash,
  dba_func_list  **funclst,
  long  assign_only);
extern void dba_remark_unknown_function (
  char  *name,
  char  *oname,
  dba_func_list  *funclst);
extern void dba_export_unknown_function (
  char  *name,
  char  *oname,
  dba_func_list  **funclst);

/* From findfunc.c */
extern void dba_find_function (
  char  *name,
  char  *orig,
  dba_func_list  **func,
  long  hash,
  long  *multi);
extern long dba_find_function_continue (
  dba_func_list  *func_cur);

/* From flexarg.c */
extern int dba_set_flexible_args (
  int flag);

/* From funcerr.c */
extern void dba_standard_function_error (
  char  *function_name);
extern void dba_standard_return_error (
  char  *function_name);

/* From function.c */
extern unsigned long dba_add_name_to_pool (
  functiontype  *function,
  char  *name);
extern void dba_symtree_debug (
  functiontype  *function);
extern long dba_add_to_symbol_tree (
  functiontype  *function,
  operandtype  *operand,
  unsigned long  index);
extern long dba_check_symtree (
  functiontype  *function,
  dba_avl_tree_node  *tree,
  char  *val);
extern void dba_symtree_deallocate (
  dba_avl_tree_node  *tree);
extern void dba_clear_function_scope_level (
  functiontype  *function,
  long  scope);
extern void dba_delete_from_symbol_tree (
  functiontype  *function,
  operandtype  *operand);
extern void dba_set_function_name (
  functiontype  *function,
  char  *name);
extern void dba_set_original_name (
  functiontype  *function,
  char  *name);
extern void dba_dup_original_name (
  functiontype  *function);
extern long dba_is_function_operand (
  functiontype  *function,
  char  *operand);
extern long dba_add_function_operand2 (
  functiontype  *function,
  operandtype  *operand,
  int  dlook);
extern long dba_add_function_operand (
  functiontype  *function,
  operandtype   *operand,
  int  dlook);
extern void dba_add_function_operation (
  functiontype  *function,
  unsigned int  opcode,
  int  opsr1,
  int  opsr2,
  int  opsr3,
  int  optmp1,
  int  optmp2,
  int  optmp3,
  lvoid  *opaddr1,
  lvoid  *opaddr2,
  lvoid  *opaddr3,
  int  opdyn1,
  int  opdyn2,
  int  set_source_line);
extern long dba_copy_function (
  functiontype  *dfunc,
  functiontype  *sfunc);
extern long dba_add_function_argument (
  functiontype  *function,
  char  *argument);
extern long dba_add_function_compound (
  functiontype  *function,
  compoundtype  *compound);
extern long dba_is_function_compound2 (
  functiontype  *function,
  char  *compname);
extern long dba_is_function_compound (
  functiontype  *function,
  char  *compname);
extern void dba_preset_globals (
  functiontype  *function);
extern long dba_upload_global (
  functiontype  *function,
  operandtype  *op,
  int  exist_only);
extern long dba_create_global_variable (
  char  *name,
  long  type,
  void  *addr,
  long  x_dim,
  long  y_dim,
  long  ptr,
  int  dlook);
extern long dba_delete_global_variable (
  char  *name);
extern long dba_reset_global_variable (
  char  *name);

/* From initials.c */
extern int dba_exec_initial_script (
);

/* From initscr.c */
extern int dba_init_script (
);

/* From instant.c */
extern long dba_instantiate_variables (
  functiontype  *function);
extern long dba_destroy_variables (
  functiontype  *function);
extern int dba_instantiate_globals (
  char  *name);

/* From intern_err.c */
extern void dba_internal_error (
  char  *function,
  char  *file);

/* From mainscr.c */

/* From memgrow.c */
extern int dba_mem_grow (
  functiontype  *function,
  long  opnum,
  long  arg,
  long  len,
  void  **value);

/* From operand.c */
extern int dba_set_operand_type (
  operandtype  *operand,
  long  type);
extern void dba_set_operand_indir (
  operandtype  *operand,
  long  indir);
extern long dba_create_value_space (
  operandtype  *operand,
  void  **addr,
  long  rw);
extern long dba_create_const_value_space (
  operandtype  *operand,
  void  **addr);
extern long dba_create_static_value_space (
  operandtype  *operand,
  void  **addr);
extern int dba_create_special_value_space (
  operandtype  *operand,
  void  **addr,
  long  (*handler)(),
  void  *data);
extern long dba_alloc_dynamic_operand (
  functiontype  *function,
  operandtype  *operand);
extern long dba_resize_dynamic_operand (
  functiontype  *function,
  operandtype  *operand,
  unsigned long  newsize);
extern long dba_calc_ptr_dynamic_size (
  functiontype  *function,
  long  opnum,
  long  arg,
  unsigned long  *size);
extern long dba_expand_dynamic_operand (
  lvoid  *lv);
extern long dba_release_dynamic_operand (
  functiontype  *function,
  operandtype  *operand);
extern long dba_release_static_operand (
  functiontype  *function,
  operandtype  *operand);
extern int dba_add_operand_dim (
  operandtype  *operand,
  long  dimsize);
extern operandtype *dba_get_operand_parent (
  functiontype  *function,
  long  popnum,
  long  argnum);
extern void dba_unpack_result_info (
  operationtype  *operation,
  long  *indir,
  long  *struct_info,
  long  *type,
  long  *us,
  long  *is_real_c);
extern void dba_unpack_parent_arg_info (
  functiontype  *function,
  long  popnum,
  long  argnum,
  long  *indir,
  long  *struct_info,
  long  *type,
  long  *mode,
  long  *us,
  long  *is_real_c);
extern operandtype *dba_get_operand_child (
  functiontype  *function,
  long  argnum);
extern void dba_convert_argument (
  long  par_indir,
  long  par_type,
  long  par_is_real_c,
  long  par_us,
  operandtype  *cld_operand,
  functiontype  *function,
  long  popnum,
  long  argnum,
  functiontype  *cfunc);
extern void dba_copyback_result (
  functiontype  *pfunc,
  long  popnum,
  functiontype  *func,
  long  opnum,
  void  *addr);
extern long dba_has_zero_value (
  functiontype  *function,
  long  opnum,
  long  argnum,
  long  type,
  long  indir,
  long  is_real_c);
extern void dba_get_operand (
  functiontype  *function,
  long  opnum,
  long  num,
  operandtype  **ptrop,
  void  **value);
extern long dba_get_int_from_pointer (
  operandtype  *ptrop,
  void  *value,
  long  *arg,
  char  *name);
extern long dba_get_double_from_pointer (
  operandtype  *ptrop,
  void  *value,
  double  *arg,
  char  *name);
extern int dba_get_int_from_ptrop (
  operandtype  *ptrop,
  void  *value,
  long  *arg,
  char  *name);
extern int dba_get_int_from_operand (
  functiontype  *function,
  long  opnum,
  long  num,
  long  *arg,
  char  *name);
extern int dba_get_double_from_ptrop (
  operandtype  *ptrop,
  void  *value,
  double  *arg,
  char  *name);
extern long dba_get_double_from_operand (
  functiontype  *function,
  long  opnum,
  long  num,
  double  *arg,
  char  *name);
extern long dba_get_char_from_operand (
  functiontype  *function,
  long  opnum,
  long  num,
  char  *arg,
  char  *name);
extern long dba_get_short_from_ptrop (
  operandtype  *ptrop,
  void  *value,
  short  *arg,
  char  *name);
extern long dba_get_short_from_operand (
  functiontype  *function,
  long  opnum,
  long  num,
  short  *arg,
  char  *name);
extern long dba_get_float_from_operand (
  functiontype  *function,
  long  opnum,
  long  num,
  float  *arg,
  char  *name);
extern long dba_store_ptr_result (
  functiontype  *function,
  long  opnum,
  lvoid  result,
  char  *func_name);
extern long dba_store_short_result (
  functiontype  *function,
  long  opnum,
  short  result,
  char  *name);
extern long dba_store_float_result (
  functiontype  *function,
  long  opnum,
  float  result,
  char  *name);
extern int dba_store_int_result (
  functiontype  *function,
  long  opnum,
  long  result,
  char  *name);
extern long dba_store_double_result (
  functiontype  *function,
  long  opnum,
  double  result,
  char  *name);
extern int dba_get_ptr_from_ptrop (
  operandtype  *ptrop,
  void  *value,
  void  **arg,
  long  indir_level,
  long  ck_indir,
  long  type,
  long  ck_type,
  long  nulls_ok,
  char  *name);
extern int dba_get_ptr_from_operand (
  functiontype  *function,
  long  opnum,
  long  num,
  void  **arg,
  long  indir_level,
  long  ck_indir,
  long  type,
  long  ck_type,
  long  nulls_ok,
  char  *name);
extern int dba_get_str_val_from_operand (
  functiontype  *function,
  long  opnum,
  long  num,
  char  **arg,
  char  *buf,
  char  *name);
extern int dba_store_int_to_ptrop (
  operandtype  *ptrop,
  void  *value,
  long  val);
extern long dba_store_int_to_operand (
  functiontype  *function,
  long  opnum,
  long  num,
  long  val);
extern int dba_store_double_to_ptrop (
  operandtype  *ptrop,
  void  *value,
  double  val);
extern long dba_store_double_to_operand (
  functiontype  *function,
  long  opnum,
  long  num,
  double  val);
extern int dba_store_ptr_to_ptrop (
  operandtype  *ptrop,
  void  *value,
  void  *val);

/* From operatio.c */
extern long dba_set_jump_address (
  operationtype  *operation,
  long  address);
extern lvoid dba_get_address_8 (
  functiontype  *function,
  operationtype  *operation);
extern void *dba_get_address (
  functiontype  *function,
  operationtype  *operation);
extern void *dba_get_result_address (
  functiontype  *function,
  operationtype  *operation);

/* From pragma.c */
extern int dba_script_parse_pragma (
  char *prag_str);

/* From printabl.c */
extern char *dba_get_printable_opcode_name (
  long  opcode);
extern char *dba_get_printable_storage_name (
  long  mode);
extern char *dba_get_printable_type_name (
  long  type);

/* From prmnuscr.c */
extern long dba_process_menu_script (
  char  *script_template);

/* From prscript.c */
extern int dba_process_script (
  char  *script_template);

/* From prspec.c */
extern long dba_fill_special_var (
  void  *addr);
extern int dba_specvar_undef_ovrd (
);
extern void dba_specvar_ignore (
  int  flag);
extern int dba_inq_specvar_ignore (
);
extern void dba_set_specvar_encountered (
  int  flag);

/* From ptr_err.c */
extern void dba_standard_pointer_error (
  functiontype  *bfunc,
  functiontype  *function,
  operandtype  *operand);

/* From purge.c */
extern int dba_purge_function (
  char  *name);

/* From qfordeal.c */
extern void dba_queue_for_dealloc (
  char  *name);

/* From reg_scr.c */
extern int dba_register_script(
);

/* From reg_scr2.c */
extern int dba_register_script2(
);

/* From regutil.c */
extern long dba_exp_fread_fwrite (
  genstacktype  *stack,
  void  **args,
  char  *types,
  int  *override_flag,
  int  *override_value);

/* From s_calloc.c */
extern long dba_s_calloc (
  functiontype  *bfunc,
  functiontype  *function,
  long  opnum);

/* From s_cftime.c */
extern long dba_s_cftime (
  functiontype  *bfunc,
  functiontype  *function,
  long  opnum);

/* From s_fgets.c */
extern long dba_s_fgets (
  functiontype  *bfunc,
  functiontype  *function,
  long  opnum);

/* From s_fopen.c */
extern long dba_s_fopen (
  functiontype  *bfunc,
  functiontype  *function,
  long  opnum);

/* From s_fprint.c */
extern long dba_s_fprintf (
  functiontype  *bfunc,
  functiontype  *function,
  long  opnum);

/* From s_free.c */
extern long dba_s_free (
  functiontype  *bfunc,
  functiontype  *function,
  long  opnum);

/* From s_fscanf.c */
extern long dba_s_fscanf (
  functiontype  *bfunc,
  functiontype  *function,
  long  opnum);

/* From s_getenv.c */
extern long dba_s_getenv (
  functiontype  *bfunc,
  functiontype  *function,
  long  opnum);

/* From s_malloc.c */
extern long dba_s_malloc (
  functiontype  *bfunc,
  functiontype  *function,
  long  opnum);

/* From s_memset.c */
extern long dba_s_memset (
  functiontype  *bfunc,
  functiontype  *function,
  long  opnum);

/* From s_popen.c */
extern long dba_s_popen (
  functiontype  *bfunc,
  functiontype  *function,
  long  opnum);

/* From s_printf.c */
extern long dba_s_printf (
  functiontype  *bfunc,
  functiontype  *function,
  long  opnum);

/* From s_reallo.c */
extern long dba_s_realloc (
  functiontype  *bfunc,
  functiontype  *function,
  long  opnum);

/* From s_scanf.c */
extern long dba_s_scanf (
  functiontype  *bfunc,
  functiontype  *function,
  long  opnum);

/* From s_script.c */
extern void dba_setup_script (
);

/* From s_sprint.c */
extern long dba_s_sprintf (
  functiontype  *bfunc,
  functiontype  *function,
  long  opnum);

/* From s_sscanf.c */
extern long dba_s_sscanf (
  functiontype  *bfunc,
  functiontype  *function,
  long  opnum);

/* From s_strchr.c */
extern long dba_s_strchr (
  functiontype  *bfunc,
  functiontype  *function,
  long  opnum,
  long  mode);

/* From s_strcpy.c */
extern long dba_s_strcpy (
  functiontype  *bfunc,
  functiontype  *function,
  long  opnum,
  long  mode);

/* From s_strdup.c */
extern long dba_s_strdup (
  functiontype  *bfunc,
  functiontype  *function,
  long  opnum);

/* From scerrout.c */
extern long dba_script_error (
  long  option);

/* From scr_getc.c */
extern int dba_is_tree_pp_key (
  dba_avl_tree_node  *tree,
  char  *key,
  pp_node  **node);
extern int dba_is_pp_key (
  char  *key,
  pp_node  **node);
extern int dba_add_pp_key (
  dba_avl_tree_node  **tree,
  pp_node  *node);
extern int dba_record_include_file (
  char  *inc_name,
  time_t  timestamp);
extern void dba_include_list_clear (
);
extern void dba_get_include_list (
  smm_generic_list  **list);
extern int dba_read_line (
);
extern int dba_backout (
);
extern int dba_script_getc (
);
extern void dba_getc_cleanup (
  int  close_file_flag);
extern int dba_getc_set_input_file (
  char  *filename);
extern void dba_getc_setup (
  int  option);
extern int dba_is_include_file (
);
extern void dba_exit_pp (
);
extern void dba_gen_parse_error (
);

/* From scrnfmut.c */
extern long dba_check_nfm_active (
  functiontype  *bfunc);
extern long dba_get_1_nfm_arg (
  functiontype  *function,
  long  opnum,
  char  **arg);
extern long dba_get_2_nfm_arg (
  functiontype  *function,
  long  opnum,
  char  **arg1,
  char  **arg2);
extern long dba_get_3_nfm_arg (
  functiontype  *function,
  long  opnum,
  char  **arg1,
  char  **arg2,
  char  **arg3);
extern long dba_get_4_nfm_arg (
  functiontype  *function,
  long  opnum,
  char  **arg1,
  char  **arg2,
  char  **arg3,
  char  **arg4);
extern long dba_get_5_nfm_arg (
  functiontype  *function,
  long  opnum,
  char  **arg1,
  char  **arg2,
  char  **arg3,
  char  **arg4,
  char  **arg5);
extern long dba_get_6_nfm_arg (
  functiontype  *function,
  long  opnum,
  char  **arg1,
  char  **arg2,
  char  **arg3,
  char  **arg4,
  char  **arg5,
  char  **arg6);
extern long dba_get_7_nfm_arg (
  functiontype  *function,
  long  opnum,
  char  **arg1,
  char  **arg2,
  char  **arg3,
  char  **arg4,
  char  **arg5,
  char  **arg6,
  char  **arg7);
extern long dba_get_8_nfm_arg (
  functiontype  *function,
  long  opnum,
  char  **arg1,
  char  **arg2,
  char  **arg3,
  char  **arg4,
  char  **arg5,
  char  **arg6,
  char  **arg7,
  char  **arg8);
extern long dba_get_9_nfm_arg (
  functiontype  *function,
  long  opnum,
  char  **arg1,
  char  **arg2,
  char  **arg3,
  char  **arg4,
  char  **arg5,
  char  **arg6,
  char  **arg7,
  char  **arg8,
  char  **arg9);
extern long dba_get_3_nfm_arg_int (
  functiontype  *function,
  long  opnum,
  char  **arg1,
  char  **arg2,
  long  *arg3,
  char  *func_name);
extern long dba_get_5_nfm_arg_int (
  functiontype  *function,
  long  opnum,
  char  **arg1,
  char  **arg2,
  char  **arg3,
  char  **arg4,
  long  *arg5,
  char  *func_name);
extern long dba_get_7_nfm_arg_int (
  functiontype  *function,
  long  opnum,
  char  **arg1,
  char  **arg2,
  char  **arg3,
  char  **arg4,
  long  *arg5,
  long  *arg6,
  long  *arg7,
  char  *func_name);
extern long dba_get_8_nfm_arg_int (
  functiontype  *function,
  long  opnum,
  char  **arg1,
  char  **arg2,
  char  **arg3,
  char  **arg4,
  long  *arg5,
  long  *arg6,
  long  *arg7,
  char  **arg8,
  char  *func_name);
extern long dba_get_9_nfm_arg_int (
  functiontype  *function,
  long  opnum,
  char  **arg1,
  char  **arg2,
  char  **arg3,
  long  *arg4,
  char  **arg5,
  char  **arg6,
  char  **arg7,
  char  **arg8,
  char  **arg9,
  char  *func_name);

/* From smm.c */
extern void dba_set_static_rw_block_size (
  unsigned long  size);
extern void dba_get_static_rw_block_size (
  unsigned long  *size);
extern void dba_set_static_ro_block_size (
  unsigned long  size);
extern void dba_get_static_ro_block_size (
  unsigned long  *size);
extern void dba_set_stack_block_size (
  unsigned long  size);
extern void dba_get_stack_block_size (
  unsigned long  *size);
extern void dba_set_dynamic_block_size (
  unsigned long  size);
extern void dba_get_dynamic_block_size (
  unsigned long  *size);
extern void dba_set_dynamic_auto_block_size (
  unsigned long  size);
extern void dba_get_dynamic_auto_block_size (
  unsigned long  *size);
extern void dba_set_special_block_size (
  unsigned long  size);
extern void dba_get_special_block_size (
  unsigned long  *size);
extern void dba_set_new_static_rw_mode (
  long  allow,
  unsigned long  maxsize);
extern void dba_get_new_static_rw_mode (
  long  *allow,
  unsigned long  *maxsize);
extern void dba_set_new_static_ro_mode (
  long  allow,
  unsigned long  maxsize);
extern void dba_get_new_static_ro_mode (
  long  *allow,
  unsigned long  *maxsize);
extern void dba_set_new_stack_mode (
  long  allow,
  unsigned long  maxsize);
extern void dba_get_new_stack_mode (
  long  *allow,
  unsigned long  *maxsize);
extern void dba_set_new_dynamic_mode (
  long  allow,
  unsigned long  maxsize);
extern void dba_get_new_dynamic_mode (
  long  *allow,
  unsigned long  *maxsize);
extern void dba_set_new_dynamic_auto_mode (
  long  allow,
  unsigned long  maxsize);
extern void dba_get_new_dynamic_auto_mode (
  long  *allow,
  unsigned long  *maxsize);
extern void dba_set_new_special_mode (
  long  allow,
  unsigned long  maxsize);
extern void dba_get_new_special_mode (
  long  *allow,
  unsigned long  *maxsize);
extern void dba_smm_dump_freelists (
);
extern void dba_smm_check_integrity (
);
extern long dba_smm_alloc_block (
  smm_blocktype  **bptr,
  unsigned long  size,
  unsigned long  flags);
extern long dba_smm_alloc_static_space (
  smm_generic_list  **sptr,
  unsigned long  size,
  long  rw);
extern long dba_smm_dealloc_space (
  smm_generic_list  *seg);
extern long dba_smm_alloc_stack_space (
  smm_generic_list  **sptr,
  unsigned long  size);
extern long dba_smm_alloc_dynamic_space (
  smm_generic_list  **sptr,
  unsigned long  size,
  long  static_mode);
extern long dba_smm_resize_dynamic_space (
  smm_generic_list  *optr,
  smm_generic_list  **nptr,
  unsigned long  size,
  long  static_mode);
extern long dba_smm_alloc_special_space (
  smm_generic_list  **sptr,
  unsigned long  size,
  void  *data);
extern long dba_smm_locate_special_segment (
  void  *addr,
  smm_generic_list  **segment);
extern long dba_smm_is_special_segment (
  smm_generic_list  *segment);
extern void dba_exit_smm(
);

/* From stdscrer.c */
extern void dba_standard_script_error (
  functiontype  *function,
  long  sourceline);
extern void dba_standard_proc_script_error (
  functiontype  *function);
extern void dba_standard_gadget_script_error (
);
extern void dba_standard_menu_script_error (
);
extern void dba_standard_conv_script_error (
);
extern void dba_standard_initial_script_error (
);

/* From storescr.c */
extern long dba_save_object (
);
extern int dba_write_object (
  char  *library,
  char  *template,
  int  verify_lib,
  int  verify_temp);
extern long dba_read_object (
  struct dba_library  *templib,
  functiontype  *f);

/* From tl_start.c */
extern int dba_start_template_librarian (
);

/* From typesize.c */
extern long dba_get_type_size (
  long  type);
extern long dba_get_type_alignment (
  long  type);
extern long dba_get_effective_size (
  functiontype  *function,
  operandtype  *op,
  long  ptr_adj);

/* From verbose.c */
extern int dba_verbose_result_check (
  char  *fname,
  long  result,
  long  type,
  long  ok_val);
extern int dba_verbose_dload (
  char  *name);
extern void dba_verbose_range (
  char  *name,
  unsigned long  old_size,
  unsigned long  new_size);

/* From virt.c */
extern void dba_cvt_virt_addr_8 (
  lvoid  *lv,
  void  *ptr);
extern void dba_remap_virt_addr (
  lvoid  *lv);

#endif
