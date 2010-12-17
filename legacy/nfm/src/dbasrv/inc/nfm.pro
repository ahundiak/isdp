#ifndef nfm_pro
#define nfm_pro

/* From dbnfm.c */
extern int dba_nfm_login(
  char  *server,
  char  *user,
  char  *passwd,
  char  *environment,
  int  debug);
extern int dba_nfm_logout(
);
extern int dba_nfm_copy(
  char  *catalog,
  char  *name,
  char  *rev,
  char  *storage,
  char  *node,
  char  *user,
  char  *passwd,
  char  *path,
  char  *filename);
extern int dba_nfm_set_copy(
  char  *catalog,
  char  *set_name,
  char  *set_rev,
  int  level,
  char  *storage,
  char  *node,
  char  *user,
  char  *passwd,
  char  *path);
extern int dba_nfm_checkin(
  char  *catalog,
  char  *name,
  char  *rev,
  char  *storage,
  char  *node,
  char  *user,
  char  *passwd,
  char  *path,
  char  *filename);
extern int dba_nfm_set_checkin(
  char  *catalog,
  char  *set_name,
  char  *set_rev,
  char  *storage,
  char  *node,
  char  *user,
  char  *passwd,
  char  *path);
extern int dba_nfm_checkout(
  char  *catalog,
  char  *name,
  char  *rev,
  char  *storage,
  char  *node,
  char  *user,
  char  *passwd,
  char  *path,
  char  *filename);
extern int dba_nfm_set_checkout(
  char  *catalog,
  char  *set_name,
  char  *set_rev,
  int  level,
  char  *storage,
  char  *node,
  char  *user,
  char  *passwd,
  char  *path);
extern int dba_nfm_add_item(
  char  *catalog,
  char  *name,
  char  *rev,
  char  *desc,
  int  aclno,
  int  version_limit,
  int  cisano,
  char  *filename,
  char  *ci_filename,
  char  *file_type);
extern int dba_nfm_copy_new_item(
  char  *catalog,
  char  *name,
  char  *rev,
  char  *new_catalog,
  char  *new_name,
  char  *new_rev,
  char  *new_cofilename,
  char  *new_cifilename,
  char  *new_storage);
extern int dba_nfm_add_set(
  char  *catalog,
  char  *set_name,
  char  *set_rev,
  char  *desc,
  int  aclno,
  int  version_limit,
  int  cisano);
extern int dba_nfm_add_to_set2(
  char  *set_catalog,
  char  *set_name,
  char  *set_rev,
  char  *catalog,
  char  *name,
  char  *rev,
  char  *type);
extern int dba_nfm_add_to_set(
  char  *catalog,
  char  *set_name,
  char  *set_rev,
  char  *name,
  char  *rev,
  char  *type);
extern int dba_nfm_create_catalog(
  char  *catalog,
  char  *desc,
  int  aclno);
extern int dba_nfm_add_user(
  char  *user,
  char  *passwd,
  char  *desc,
  char  *path);
extern int dba_nfm_change_user_passwd(
  char  *user,
  char  *passwd,
  char  *new_passwd);
extern int dba_nfm_add_storage_area(
  char  *storage,
  char  *node,
  char  *user,
  char  *passwd,
  char  *path,
  char  *type,
  char  *sa_type,
  char  *owner);
extern int dba_nfm_delete_item(
  char  *catalog,
  char  *name,
  char  *rev);
extern int dba_nfm_flag_item_delete(
  char  *catalog,
  char  *name,
  char  *rev);
extern int dba_nfm_cancel_item_delete(
  char  *catalog,
  char  *name,
  char  *rev);
extern int dba_nfm_flag_item_backup(
  char  *catalog,
  char  *name,
  char  *rev);
extern int dba_nfm_cancel_item_backup(
  char  *catalog,
  char  *name,
  char  *rev);
extern int dba_nfm_delete_catalog(
  char  *catalog);
extern int dba_nfm_delete_storage_area(
  char  *storage);
extern int dba_nfm_delete_user(
  char  *user);
extern int dba_nfm_load_workflow(
  char  *app,
  char  *wfname);
extern int dba_nfm_add_acl(
  char  *wfname,
  char  *aclname);
extern int dba_nfm_add_acl_user(
  char  *aclname,
  char  *class,
  char  *user,
  char  *wfname);
extern int dba_nfm_delete_acl_user(
  char  *aclname,
  char  *class,
  char  *user,
  char  *wfname);
extern int dba_nfm_get_message(
  char  *message);
extern int dba_nfm_cancel_item(
  char  *catalog,
  char  *name,
  char  *rev);
extern int dba_nfm_cancel_set(
  char  *catalog,
  char  *set_name,
  char  *set_rev);
extern int dba_nfm_make_transition(
  char  *catalog,
  char  *name,
  char  *rev,
  char  *state);
extern int dba_nfm_signoff(
  char  *catalog,
  char  *name,
  char  *rev);
extern int dba_nfm_build_set_list(
  char  *name,
  char  *rev,
  char  *type);
extern int dba_nfm_build_set_list2(
  char  *catalog,
  char  *name,
  char  *rev,
  char  *type);
extern int dba_nfm_add_list_to_set(
  char  *set_catalog,
  char  *set_name,
  char  *set_rev);
extern int dba_nfm_drop_set(
  char  *set_catalog,
  char  *set_name,
  char  *set_rev);
extern int dba_nfm_drop_from_set(
  char  *catalog,
  char  *set_name,
  char  *set_rev,
  char  *item_name,
  char  *item_rev);
extern int dba_nfm_drop_from_set2(
  char  *set_catalog,
  char  *set_name,
  char  *set_rev,
  char  *catalog,
  char  *name,
  char  *rev);
extern int dba_nfm_free_items(
);
extern int dba_nfm_add_file(
  char  *catalog,
  char  *name,
  char  *rev,
  char  *filename,
  char  *storage,
  char  *ci_filename,
  char  *file_type);
extern int dba_nfm_delete_file(
  char  *catalog,
  char  *name,
  char  *rev,
  char  *filename);
extern int dba_nfm_change_file(
  char  *catalog,
  char  *name,
  char  *rev,
  char  *filename,
  char  *c_name,
  char  *c_value);
extern int dba_nfm_change_item(
  char  *catalog,
  char  *name,
  char  *rev,
  char  *c_name,
  char  *c_value);
extern int dba_nfm_change_user(
  char  *user,
  char  *c_name,
  char  *c_value);
extern int dba_nfm_add_multi(
  char  *filename);
extern int dba_nfm_checkin_multi(
  char  *catalog,
  char  *name,
  char  *rev,
  char  *storage,
  char  *node,
  char  *user,
  char  *passwd,
  char  *path);
extern int dba_nfm_free_files(
);
extern int dba_nfm_add_user_catalog(
  char  *name,
  char  *type,
  char  *synonym);
extern int dba_nfm_create_user_catalog(
  char  *catalog,
  char  *desc,
  int  aclno);
extern int dba_nfm_free_cols(
);
extern int dba_nfm_add_user_data(
  char  *name,
  char  *value);
extern int dba_nfm_add_user_item(
  char  *catalog,
  char  *name,
  char  *rev,
  char  *desc,
  int  aclno,
  int  version_limit,
  int  cisano,
  char  *filename,
  char  *ci_filename,
  char  *file_type);
extern int dba_nfm_flag_item_archive(
  char  *catalog,
  char  *name,
  char  *rev);
extern int dba_nfm_cancel_item_archive(
  char  *catalog,
  char  *name,
  char  *rev);
extern int dba_nfm_flag_item_restore(
  char  *catalog,
  char  *name,
  char  *rev);
extern int dba_nfm_cancel_item_restore(
  char  *catalog,
  char  *name,
  char  *rev);
extern int dba_nfm_change_sa_passwd(
  char  *storage,
  char  *old_passwd,
  char  *new_passwd);
extern int dba_nfm_get_schema(
  char  *environment,
  char  *schema,
  char  *password);
extern dba_nfm_get_schema_name(
  char  *schema,
  char  *passwd);
extern dba_nfm_make_working_area(
  char  *working_area);
extern dba_nfm_create_temporary_storage(
  char  *node,
  char  *user,
  char  *path,
  char  *storage);
extern int dba_nfm_lock_item(
  char  *catalog,
  char  *name,
  char  *rev);
extern int dba_nfm_unlock_item(
  char  *catalog,
  char  *name,
  char  *rev);
extern int dba_nfm_set_local_file_manager(
  int  state);
extern int dba_nfm_set_workflow(
  int  state);
extern int dba_nfm_default_schema(
);
extern int dba_nfm_delete_copied_file(
  char  *catalog,
  char  *name,
  char  *rev,
  char  *storage,
  char  *node,
  char  *user,
  char  *passwd,
  char  *path,
  char  *filename,
  int  version);
extern int dba_nfm_add_node(
  char  *node,
  char  *description,
  char  *xns,
  char  *tcp,
  char  *nfs);
extern int dba_nfm_delete_node(
  char  *node);
extern int dba_nfm_change_node(
  char  *node,
  char  *c_name,
  char  *c_value);
extern int dba_nfm_change_storage_area(
  char  *storage,
  char  *c_name,
  char  *c_value);
extern int dba_nfm_plot_item(
  char  *catalog,
  char  *name,
  char  *rev);
extern int dba_nfm_plot_set(
  char  *catalog,
  char  *name,
  char  *rev);
extern int dba_nfm_save_item(
  char  *catalog,
  char  *name,
  char  *rev);
extern int dba_nfm_save_set(
  char  *catalog,
  char  *name,
  char  *rev);

/* From e_nfm.c */
extern int dba_exit_nfm (
);

/* From i_nfm.c */
extern int dba_init_nfm (
);

/* From nfm_util.c */
extern int dba_util_nfm_add_user_item (
  char  *catalog,
  char  *name,
  char  *rev,
  char  *desc,
  int  aclno,
  int  vers,
  int  cisano,
  char  *filename);
extern int dba_util_nfm_add_item (
  char  *catalog,
  char  *name,
  char  *rev,
  char  *desc,
  int  aclno,
  int  vers,
  int  cisano,
  char  *filename);
extern int dba_util_nfm_add_file (
  char  *catalog,
  char  *name,
  char  *rev,
  char  *filename,
  char  *storage);
extern int dba_util_nfm_copy_new_item (
  char  *catalog,
  char  *name,
  char  *rev,
  char  *new_catalog,
  char  *new_name,
  char  *new_rev);
extern int dba_util_nfm_add_storage_area (
  char  *storage,
  char  *node,
  char  *user,
  char  *passwd,
  char  *path,
  char  *type);

/* From reg_nfm.c */
extern int dba_register_nfm(
);

/* From s_nfm.c */
extern void dba_setup_nfm (
);

#endif
