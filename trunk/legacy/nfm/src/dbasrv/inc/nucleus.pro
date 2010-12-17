#ifndef nucleus_pro
#define nucleus_pro

/* From add_err.c */
extern int dba_add_error (
  char  *message);

/* From append_error.c */
extern dba_append_error (
  int  add,
  char  *msg_text);

/* From avl.c */
extern long dba_add_avl_balance_tree (
  dba_avl_tree_node  **t,
  void  *newval,
  long  *inc,
  long  (*rel_lt_func)(),
  void  *extra);
extern long dba_delete_avl_balance_tree (
  dba_avl_tree_node  **t,
  void  *deldata,
  long  (*lessthan)(),
  void  *extra,
  unsigned long  data_size);

/* From blk_und.c */
extern int dba_blanks_to_underbars (
  char  *text_ptr);

/* From check_max14.c */
extern int dba_check_max14 (
  char  *char_ptr);

/* From chunk.c */
extern int dba_put_chunk (
  struct dba_library  *lib,
  char  *buf,
  long  size);
extern int dba_get_chunk (
  struct dba_library  *lib,
  char  *buf,
  long  size);

/* From code_to_tic.c */
extern int dba_code_to_tic (
  char  *char_ptr);

/* From compress.c */
extern int dba_compress_library (
  char  *lib);

/* From crash.c */
extern void dba_sigset (
);
extern void dba_crash_sigbus (
);
extern void dba_crash_sigemt (
);
extern void dba_crash_sigsegv (
);
extern void dba_crash_sigill (
);

/* From creat_rtblib.c */
extern int dba_create_library (
  char  *library,
  int  confirm);

/* From d_strcmp.c */
extern int dba_strcmp (
  char  *str1,
  char  *str2);

/* From dba_get_opt.c */
extern int dba_get_opt (
  int  argc,
  char  *argv[]);
extern int dba_options(
);

/* From dba_init.c */
extern char *dba_getenv (
  char  *shell_var);
extern int dba_init (
);
extern int dba_set_template_names (
);

/* From dba_sort.c */
extern int dba_sort (
  long  univ_size,
  char  *mem_ptr,
  int  rec_length,
  struct dba_key  *fkey);

/* From dba_strdup.c */
extern void dba_strdup (
  char  *in,
  char  **out,
  unsigned long  *lng);

/* From dba_swap.c */

/* From dbd_abort.c */
extern dba_abort (
);

/* From del_temp.c */
extern int dba_delete_template (
  char  *lib,
  char  *template,
  int  type,
  int  verify);

/* From dmalloc.c */
extern void *dba_dmalloc_ex (
  unsigned long  size,
  unsigned long  desc,
  char  *file,
  int  line);
extern void *dba_dcalloc_ex (
  unsigned long  size,
  unsigned long  num,
  unsigned long  desc,
  char  *file,
  int  line);
extern void *dba_drealloc (
  void  *ptr,
  unsigned long  size);
extern char *dba_dstrdup_ex (
  char  *str,
  unsigned long  desc,
  char  *file,
  int  line);
extern void dba_dfree (
  void  *ptr);
extern void _dba_dmalloc_dump (
  int  detail);

/* From exit.c */
extern void dba_exit (
);

/* From exit_err.c */
extern void dba_exit_with_error (
);

/* From expbs.c */
extern void dba_expand_backslash (
  char * instring,
  char * outstring);

/* From ext_temp.c */
extern int dba_extract_template (
  char  *library,
  char  *template,
  int  type,
  char  *filename);
extern int dba_extract_template_records (
  char  *library,
  struct dba_library  *ext_lib,
  char  *name,
  FILE  *out_file,
  int  type);

/* From f_nuc.c */
extern int dba_free_globals (
);

/* From g_deltmp.c */
extern int dba_get_deleted_templates (
  char  *library,
  long  template_type,
  struct dba_template  **template_list,
  long  *list_count);

/* From g_libndx.c */
extern int dba_get_lib_index (
  struct dba_library  *lib_ptr);
extern int dba_get_indexes (
  struct dba_library  *lib_ptr,
  long  key_block);

/* From get_msg.c */
extern char *dba_get_msg (
);

/* From get_temp_typ.c */
extern int dba_get_template_type (
  struct dba_library  *lib_ptr,
  long  block,
  int  s_byte,
  int  *type);

/* From i_bldfnc.c */
extern int dba_inq_build_fence (
  int  create_flag,
  int  *got_where,
  struct dba_ent  *ent_ptr,
  char  **s1_ptr,
  unsigned long  *s1_size,
  Form  fpt,
  int  label,
  int  row);

/* From i_cvtfnc.c */
extern int dba_inq_convert_func (
  int  option,
  int  schema,
  int  table,
  int  column,
  char  *text,
  int  length);

/* From i_fncexi.c */
extern int dba_inq_fence_exists (
);

/* From i_prcscr.c */
extern void dba_inq_process_script (
  char  *script);

/* From init_err.c */
extern int dba_init_error (
);

/* From ins_temp.c */
extern int dba_insert_template (
  char  *library,
  char  *filename,
  int  replace);

/* From int_stak.c */
extern void dba_int_push (
  jumpstacktype  *jumpstack,
  long  jump);
extern long dba_int_pop (
  jumpstacktype  *jumpstack);
extern void dba_gen_push (
  genstacktype  *genstack,
  void  *ptr);
extern void *dba_gen_pop (
  genstacktype  *genstack);
extern void *dba_gen_peek (
  genstacktype  *genstack,
  void  **loc);

/* From list_lib.c */
extern int dba_temptype_match (
  long  mask,
  long  type);
extern int dba_list_library (
  char  *library,
  long  template_type,
  struct dba_template  **template_list,
  long  *list_count);

/* From load_opt.c */
extern int dba_load_options (
  char  *library,
  char  *template);

/* From load_tmp.c */
extern int dba_load_template (
  char  *library,
  char  *template,
  int  type,
  struct dba_library  **templib);
extern int dba_load_from_library (
  char  *library,
  char  *template,
  int  type,
  struct dba_library  **templib);
extern int dba_get_template (
  char  *library,
  char  *template,
  struct dba_library  **templib,
  int  type,
  int  check,
  time_t  *time_val);

/* From look_lib.c */
extern int dba_lookup_key_from_libs (
  char  *key,
  char  *lib,
  time_t  *time_val);

/* From lower.c */
extern int dba_lower (
  char  *text_ptr);

/* From mal_nuc.c */
extern int dba_malloc_ent (
  struct dba_ent  **ent_ptr,
  struct dba_ent  *in_ent_ptr);
extern int dba_free_ent (
  struct dba_ent  **ent_ptr);
extern int dba_malloc_att (
  struct dba_att  **att_ptr,
  struct dba_att  *in_att_ptr);
extern int dba_free_att (
  struct dba_att  **att_ptr);
extern int dba_free_gadget (
  struct dba_gadget  **gadget_ptr);

/* From movefile.c */
extern int dba_move_file (
  char  *dest,
  char  *source);

/* From nuc_mgr.c */
extern void dba_register_init (
  int  key,
  int  (*func)());
extern int dba_nucleus_init(
);
extern int dba_register_service (
  int  key,
  int  (*ser)());
extern int ((*dba_inq_service (
  int key))());

/* From nuc_util.c */
extern long dba_util_rpt_save_env (
  functiontype  *bfunc);
extern long dba_util_rpt_restore_env (
  functiontype  *bfunc);
extern void dba_util_rpt_mod_return (
  int  *status);
extern void dba_util_fix_98 (
  int  *status);
extern long dba_util_save_sigcld (
  functiontype  *bfunc);
extern long dba_util_restore_sigcld (
  functiontype  *bfunc);

/* From open_msg.c */
extern char *dba_open_msg (
);

/* From out_er.c */
extern int dba_output_error (
  char  *message);

/* From pad_string.c */
extern int dba_pad_string (
  char  *text,
  int  length,
  int  fill_char);

/* From parse_string.c */
extern int dba_parse_string (
  char  **in_ptr,
  char  *out_ptr,
  int  delimiter,
  int  skip_dup);

/* From parse_tics.c */
extern char *dba_parse_tics (
  char  **char_ptr);

/* From parse_var.c */
extern int dba_parse_var (
  char  **in_ptr,
  char  **out_ptr,
  unsigned long  *out_lng);

/* From r_c_w.c */
extern int dba_replace_char_with(
  char old_char,
  char new_char,
  char *string);
extern int dba_conv_to_dos(
  char  *string);
extern int dba_conv_to_unix(
  char  *string);

/* From regfunc.c */
extern long dba_is_registered_function (
  char  *name,
  reg_func_type  **ret_reg);
extern long dba_reg_func_end (
);
extern long dba_reg_func_start (
  char  *name,
  void  (*func_ptr)());
extern long dba_register_function (
  char  *name,
  void  (*func_ptr)());
extern long dba_pseudo_reg_func (
  char  *name,
  void  (*func_ptr)(),
  long  mode);
extern long dba_pseudo_reg_func_start (
  char  *name,
  void  (*func_ptr)(),
  long  mode);
extern void dba_reg_default_verbose_on (
  long  type,
  long  val);
extern void dba_reg_default_verbose_off (
);
extern void dba_reg_default_argnum_enforce_on (
);
extern void dba_reg_default_argnum_enforce_off (
);
extern void dba_reg_default_init_env_check (
  long  (*func)());
extern long dba_reg_set_func_pascal (
  long  flag);
extern long dba_reg_set_func_init_env_check (
  long  (*func)());
extern long dba_reg_set_func_ret_override_func (
  void  (*func)());
extern long dba_reg_set_func_end_env_check (
  long  (*func)());
extern long dba_reg_set_func_return_mod_func (
  void  (*func)());
extern long dba_reg_set_func_attr (
  long  type,
  long  us,
  long  indir,
  long  is_real_c);
extern long dba_reg_set_func_argnum_enforce (
  long  flag);
extern long dba_reg_set_func_var_args (
  long  min,
  long  max);
extern long dba_reg_set_func_verbose (
  long  type,
  long  val);
extern long dba_reg_set_func_option (
  void  (*func_ptr)());
extern long dba_reg_arg_end (
);
extern long dba_reg_arg_start (
  char  *name);
extern long dba_reg_set_arg_type (
  long  type,
  long  type_enforce,
  long  us,
  long  us_enforce,
  long  str_convert);
extern long dba_reg_set_arg_indir (
  long  indir,
  long  enforce,
  long  nulls_ok);
extern long dba_reg_set_arg_output (
  long  flag);
extern long dba_reg_set_arg_transform (
  long  (*func)(),
  long  trans_size,
  long  trans_type);
extern long dba_reg_set_arg_expand (
  long  (*expand_func)());
extern long dba_reg_set_arg_buffered_expand (
  unsigned long  size);
extern void _dba_reg_dump_info(
);
extern int dba_reg_arg_simple(
  char *name,
  int type,
  int indir,
  int output);
extern int dba_reg_trans_arg_simple (
  long  (*func)(),
  char  *name);
extern void dba_exit_reg(
);

/* From save_blk.c */
extern int dba_save_block (
  struct dba_library  *lib_ptr,
  long  block);

/* From search_str.c */
extern int dba_search_string (
  char  *string,
  char  *word);

/* From setup.c */
extern int dba_setup (
  int  argc,
  char  *argv[],
  int  ms_flag,
  char  *errmsg);

/* From std_err.c */
extern int dba_stderr_add_error (
  char  *message);

/* From stralloc.c */
extern void *dba_struct_allocate (
  unsigned long  size,
  char  *file,
  int  line);
extern void dba_struct_deallocate (
  void  *ptr,
  unsigned long  size);
extern void *dba_struct_realloc (
  void  *oldptr,
  unsigned long  newsize,
  unsigned long  oldsize);
extern void dba_exit_struct(
);
extern long dba_smm_search_struct_list (
  void  *ptr);
extern void dba_smm_dump_struct_lists (
  long  flag);

/* From strchr.c */
extern char *dba_strchr (
  char  *in_string,
  char  search_char);

/* From strip.c */
extern int dba_strip_underbars (
  char  *text_ptr);

/* From temptype.c */
extern int dba_template_type_from_string (
  char  *ctype,
  int  *itype);
extern int dba_template_type_from_number (
  char  *ctype,
  int  itype);

/* From text_lib.c */
extern struct dba_library *dba_lib_open (
  char  *filespec,
  char  *mode);
extern int dba_malloc_lib (
  struct dba_library  **lib_ptr);
extern int dba_add_lib (
  struct dba_library  **flib,
  struct dba_library  **llib,
  struct dba_library  *lib);
extern int dba_lib_close (
  struct dba_library  *lib_ptr);
extern int dba_free_library (
  struct dba_library  **lib_ptr);
extern int dba_lookup_key (
  struct dba_library  *lib_ptr,
  char  *key_ptr,
  int  type,
  time_t  *time_val);
extern int dba_insert_key (
  struct dba_library  *lib_ptr,
  char  *key_ptr,
  time_t  time_val,
  int  type);
extern int dba_delete_key (
  struct dba_library  *lib_ptr,
  char  *key_ptr,
  int  type,
  int  save_block);
extern int dba_turbo_get_record (
  struct dba_library  *lib_ptr,
  char  **text_ptr,
  unsigned long  *maxlng,
  unsigned long  *lng,
  int  binary);
extern int dba_put_record (
  struct dba_library  *lib_ptr,
  char  *text_ptr,
  unsigned long  lng);
extern int dba_put_end (
  struct dba_library  *lib_ptr,
  char  *key_ptr,
  long  data_block);
extern int dba_turbo_get_index (
  struct dba_library  *lib_ptr,
  char  *key_ptr,
  int  *key_lng,
  long  *key_block,
  int  *key_byte,
  long  *data_block,
  int  *data_byte);
extern int dba_get_index (
  struct dba_library  *lib_ptr,
  char  *key_ptr,
  int  *key_lng,
  long  *key_block,
  int  *key_byte,
  long  *data_block,
  int  *data_byte);
extern int dba_add_block (
  struct dba_library  *lib_ptr);
extern int dba_update_rcnt (
  struct dba_library  *lib_ptr);
extern int dba_update_hdr (
  struct dba_library  *lib_ptr);
extern int dba_update_index (
  struct dba_library  *lib_ptr,
  char  *key_ptr,
  long  nd_block,
  long  k_block,
  int  k_byte);
extern int dba_to_master (
  struct dba_library  *lib_ptr,
  long  block,
  long  m_block);
extern int dba_update_master (
  struct dba_library  *lib_ptr,
  long  m_block,
  long  block1,
  char  *key1,
  long  block2,
  char  *key2);
extern int dba_get_record (
  struct dba_library  *lib_ptr,
  char  **text_ptr,
  unsigned long  *maxlng,
  unsigned long  *lng,
  int  binary);

/* From tic_to_code.c */
extern char *dba_tic_to_code (
  char  *char_ptr);

/* From typed_temps.c */
extern int dba_get_typed_templates (
  int  type,
  struct dba_template  **temp_ptr);

/* From undel.c */
extern int dba_undelete_template (
  char  *lib,
  struct dba_template  *temp_ptr,
  int  replace);
extern int dba_mark_deleted_template (
  struct dba_library  *lib_ptr,
  long  block);

/* From upper.c */
extern int dba_upper (
  char  *text_ptr);

/* From ustrcmp.c */
extern int dba_ustrcmp (
  char  *str1,
  char  *str2);

/* From wild.c */
extern int dba_is_wild_hit(
  char  *wild_buf,
  char  *str_buf);

/* From win32s.c */
extern int dba_is_win32s (
);

/* From write_temp.c */
extern int dba_write_template (
  char  *library,
  char  *template,
  int  type,
  int  verify_library,
  int  verify_template,
  struct dba_library  **templib);

#endif
