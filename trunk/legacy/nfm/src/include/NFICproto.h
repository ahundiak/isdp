#if defined(__STDC__) || defined(__cplusplus)
# define _P(s) s
#else
# define _P(s) ()
#endif

long NFMchange_user _P((long user_id, MEMptr attr_list, MEMptr data_list));

long NFMadd_user _P((long user_id, MEMptr attr_list, MEMptr data_list));

long NFMchange_node _P((long user_id, MEMptr attr_list, MEMptr data_list));

long NFMadd_item _P((long user_id, char *cat_name, MEMptr attr_list, MEMptr data_list));

long NFMadd_project _P((long user_id, MEMptr attr_list, MEMptr data_list));

long NFMchange_project _P((long user_id, MEMptr lop_attr, MEMptr lop_data));

long NFMadd_storage_area _P((long user_id, MEMptr attr_list, MEMptr data_list));
long NFMchange_storage_area _P((long user_id, MEMptr attr_list, MEMptr data_list));

long NFMadd_node _P((long user_id, MEMptr attr_list, MEMptr data_list));

long NFMdelete_catalog _P((long user_id, char *cat_name, long *cat_no));

long NFMdelete_storage_area _P((long user_id, char *storage_name));

long NFMdelete_node _P((long user_id, char *node_name));

long NFMdelete_project _P((long user_id, char *proj_name, long *proj_no));

long NFMdelete_user _P((long user_id, char *user_name));

long NFMdelete_item _P((long user_id, char *cat_name, char *item_name, char *item_rev));

long NFMdelete_query _P((char *query_name));

long NFMlock_item _P((long user_id, char *cat_name, char *item_name, char *item_rev));

long NFMunlock_item _P((long user_id, char *cat_name, char *item_name, char *item_rev));

long NFMdelete_catalog _P((long user_id, char *cat_name, long *cat_no));

long NFMquery_catalog_acl_map _P((long user_id, char *cat_name, MEMptr *attr_list, MEMptr *data_list, MEMptr *value_list));

long NFMupdate_catalog_acl_map _P((long user_id, MEMptr attr_list, MEMptr data_list));

long NFMquery_catalog_sa_map _P((long user_id, char *cat_name, MEMptr *attr_list, MEMptr *data_list, MEMptr *value_list));

long NFMupdate_catalog_sa_map _P((long user_id, MEMptr attr_list, MEMptr data_list));

long NFMquery_project_acl_map _P((long user_id, char *project_name, MEMptr *attr_list, MEMptr *data_list, MEMptr *value_list));

long NFMupdate_project_acl_map _P((long user_id, MEMptr attr_list, MEMptr data_list));

long NFMquery_project_sa_map _P((long user_id, char *project_name, MEMptr *attr_list, MEMptr *data_list, MEMptr *value_list));

long NFMupdate_project_sa_map _P((long user_id, MEMptr attr_list, MEMptr data_list));

long WFquery_acl_class_users _P((long user_id, char *acl_name, MEMptr *attr_list, MEMptr *data_list, MEMptr *value_list));

long WFupdate_acl_class_users _P((long user_id, MEMptr attr_list, MEMptr data_list));

long WFquery_acl_signoff_users _P((long user_id, char *acl_name, MEMptr *attr_list, MEMptr *data_list, MEMptr *value_list));

long WFupdate_acl_signoff_users _P((long user_id, MEMptr attr_list, MEMptr data_list));

long NFMdefine_file_information _P((char *catalog_name, char *item_name, char *item_revision, long operation, MEMptr data_list));

long NFMreset_file_information _P((char *catalog_name, char *item_name, char *item_revision));

long NFMget_file_information _P((char *catalog_name, char *item_name, char *item_revision, long operation, MEMptr *attr_list, MEMptr *data_list, MEMptr *value_list));

long NFMget_item_attr_for_copy _P((char *cat_name, char *itemname, char *itemrev, MEMptr *attr_cat, MEMptr *data_cat, MEMptr *value_cat,  MEMptr *attr_f_cat, MEMptr *data_f_cat, MEMptr *value_f_cat));

long NFMcopy_item_n _P((char *cat_name, MEMptr attr_cat, MEMptr data_cat, MEMptr attr_f_cat, MEMptr data_f_cat));

long NFMcheckin_item _P((char *catalog_name, long catalog_no, char *item_name, char *item_revision, char *working_area, struct NFMwf_info wf_info, struct NFMoperation operation));

long NFMcheckout_item _P((char *catalog_name, long catalog_no, char *item_name, char *item_revision, char *working_area, struct NFMwf_info wf_info, struct NFMoperation operation));

long NFMcopy_item_files _P((char *catalog_name, long catalog_no, char *item_name, char *item_revision, char *working_area, struct NFMwf_info wf_info, struct NFMoperation operation));

long NFMcopy_set_files _P((char *catalog_name, long catalog_no, char *set_name, char *set_revision, long set_no, char *working_area, struct NFMwf_info wf_info, int member_operations, struct NFMoperation operation, long level));

extern long NFMcheckin_set _P((char *catalog_name, long catalog_no, char *set_name, char *set_revision, long set_no, char *working_area, struct NFMwf_info wf_info, int member_operations, struct NFMoperation *operation, long level));

long NFMcheckout_set _P((char *catalog_name, long catalog_no, char *set_name, char *set_revision, long set_no, char *working_area, struct NFMwf_info wf_info, int member_operations, struct NFMoperation *operation, long level));

long NFMdelete_acl _P((char *workflow_name, char *acl_name));

long NFMcancel_item_archive_flag _P((long user_id, char *catalog, char *item_name, char *item_rev));

long NFMcancel_item_backup_flag _P((long user_id, char *catalog, char *item_name, char *item_rev));

long NFMcancel_item_restore_flag _P((long user_id, char *catalog, char *item_name, char *item_rev));

long NFMcancel_item_delete_flag _P((long user_id, char *catalog, char *item_name, char *item_rev));

long NFMcancel_set_archive_flag _P((long user_id, char *catalog, char *set_name, char *set_rev));

long NFMcancel_set_backup_flag _P((long user_id, char *catalog, char *set_name, char *set_rev));

long NFMcancel_set_restore_flag _P((long user_id, char *catalog, char *set_name, char *set_rev));

long NFMcancel_project_archive_flag _P((char *project));

long NFMcancel_project_backup_flag _P((char *project));

long NFMcancel_project_restore_flag _P((char *project));

long NFMcancel_project_flag _P((char *project));

long NFMcancel_check_out_item _P((char *catalog_name, long catalog_no, char *item_name, char *item_revision, struct NFMwf_info wf_info, struct NFMoperation operation));

long NFMcancel_check_out_set _P((char *catalog_name, long catalog_no, char *set_name, char *set_revision, long set_no, struct NFMwf_info wf_info, int member_operations, struct NFMoperation *operation, long level));

long NFMget_item_versions _P((char *catalog_name, char *item_name, char *item_rev, MEMptr *synonym_list, MEMptr *data_list));

long NFMroll_version_forward _P((char *catalog_name, char *item_name, char *item_rev, MEMptr * data_list));

long NFMpurge_versions _P((char *catalog_name, char *item_name, char *item_rev));

long NFMflag_item_archive _P((long user_id, char *catalog, char *item_name, char *item_rev));

long NFMflag_item_backup _P((long user_id, char *catalog, char *item_name, char *item_rev));

long NFMflag_item_restore _P((long user_id, char *catalog, char *item_name, char *item_rev));

long NFMflag_item_delete _P((long user_id, char *catalog, char *item_name, char *item_rev));

long NFMflag_set_archive _P((long user_id, char *catalog, char *set_name, char *set_rev));

long NFMflag_set_backup _P((long user_id, char *catalog, char *set_name, char *set_rev));

long NFMflag_set_restore _P((long user_id, char *catalog, char *set_name, char *set_rev));

long NFMflag_project_archive _P((long user_id, char *project_name));

long NFMflag_project_backup _P((long user_id, char *project_name));

long NFMflag_project_restore _P((long user_id, char *project_name));

#undef _P
