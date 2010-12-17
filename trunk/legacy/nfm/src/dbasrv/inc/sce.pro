#ifndef sce_pro
#define sce_pro

/* From bld_avail.c */
extern int dba_build_avail_list (
  Form  fpt,
  int  gpt);

/* From cre_ms.c */
extern int dba_create_mslink (
  struct ct_env_desc  *d,
  char  *cols,
  int  numcols);

/* From cre_tab.c */
extern int dba_proc_create_tab (
  struct ct_env_desc  *d,
  int  *aux_error);

/* From drop_tab.c */
extern int dba_proc_drop_tab (
  char  *tabnam);

/* From f_bld_list.c */
extern int dba_build_sch_list (
  int  option,
  char  *errmsg);

/* From f_coded_col.c */
extern int dba_coded_col_opts (
  int  option,
  struct ct_env_desc  *d);

/* From f_col_entry.c */
extern void dba_clear_col_entry (
  struct ct_env_desc  *d);
extern void dba_clear_types (
  struct ct_env_desc  *d);
extern int dba_add_col_entry (
  struct ct_env_desc  *d);
extern void dba_delete_col_entry (
  struct ct_env_desc  *d);

/* From f_create_tab.c */
extern int dba_create_table (
  int  option,
  char  *schnam,
  char  *errmsg);
extern dba_ct_unpack (
  Form  fpt,
  struct ct_env_desc  *d);
extern int dba_ct_pack (
  Form  fpt,
  int  gpt,
  struct ct_env_desc  *d);
extern int dba_sync_desc (
  Form  fpt,
  struct ct_env_desc  *d);

/* From f_drop_tab.c */
extern int dba_drop_table (
  int  option,
  char  *schnam,
  char  *errmsg);

/* From f_edit_privs.c */
extern int dba_edit_privs (
  int  option,
  char  *schnam,
  char  *errmsg);
extern int dba_build_ent_list (
  Form  form_ptr,
  char  *entnam,
  int  paint,
  int  label);

/* From f_get_ex_col.c */
extern int dba_get_existing_cols (
  struct ct_env_desc  *d,
  char  **columns);

/* From f_key_col.c */
extern int dba_get_key_col (
  struct ct_env_desc  *d,
  char  **cols,
  int  *numselected);
extern int dba_get_key_col_form (
  int  option);

/* From f_put_field.c */
extern int dba_put_to_forms_field (
  Form  fpt,
  int  gadlab,
  char  *cp[],
  int  maxlen,
  int  check);

/* From get_desc.c */
extern int dba_get_col_desc (
);

/* From get_schnam.c */
extern int dba_get_schema_names (
);

/* From grant_tab.c */
extern int dba_proc_grant_tab (
  Form  fpt,
  int  grflag);

/* From i_sce.c */
extern int dba_init_sce (
);

/* From n_sce.c */
extern int dba_notify_sce (
  int  form_label);

/* From ris_schmgr.c */
extern int dba_ris_schema_mgr (
);

/* From s_sce.c */
extern void dba_setup_sce (
);

/* From schema_edit.c */
extern int dba_schema_edit (
  int  option,
  char  *schnam,
  char  *errmsg);

#endif
