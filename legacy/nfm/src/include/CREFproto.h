#ifndef CREF_PROTO_H
#define CREF_PROTO_H

#if defined(__STDC__) || defined(__cplusplus)
# define __CREF(s) s
#else
# define __CREF(s) ()
#endif


/* NFMadd_query.c */
extern long NFMadd_query __CREF((char *query_name, char *query_desc, int query_type, char *application, long owner_no, char *query_file));

/* NFMcat_attr.c */
extern long NFMquery_catalog_definition __CREF((long user_id, char *cat_name, MEMptr *attr_list));
extern long NFMquery_catalog_attributes __CREF((long user_id, char *cat_name, MEMptr *attr_list, MEMptr *data_list, MEMptr *value_list));
extern long NFMquery_catalog_information __CREF((long user_id, char *cat_name, MEMptr *attr_list, MEMptr *data_list, MEMptr *value_list));
extern long NFMquery_change_catalog_information __CREF((long user_id, char *cat_name, MEMptr *attr_list, MEMptr *data_list, MEMptr *value_list));
extern long NFMsplit_catalog_definition __CREF((long user_id, MEMptr attr_list, MEMptr *attr_list1, MEMptr *attr_list2));
extern long NFMsplit_catalog_attributes __CREF((long user_id, MEMptr attr_list, MEMptr data_list, MEMptr *attr_list1, MEMptr *data_list1, MEMptr *attr_list2, MEMptr *data_list2));
extern long _NFMquery_catalog_attributes __CREF((char *catalog_name, MEMptr *attr_list, MEMptr *data_list, MEMptr *value_list));

/* NFMchk_arch.c */
extern long NFMcheck_archive_state __CREF((long user_id, char *cat_name, long item_no));

/* NFMchk_co.c */
extern long NFMcheck_co_status __CREF((long user_id, char *cat_name, long item_no, char *state));

/* NFMchk_dev.c */
extern long NFMcheck_device_type __CREF((char *dev_type));

/* NFMchk_pend.c */
extern long NFMcheck_pending_flag __CREF((long user_id, char *cat_name, long item_no));

/* NFMchk_proc.c */
extern long NFMcheck_process_locks __CREF((long user_id));
extern long NFMset_process_lock __CREF((long user_id, long lock_status));
extern long NFMreset_process_lock __CREF((long user_id, long lock_status));

/* NFMchk_set.c */
extern long NFMcheck_item_setindicator __CREF((long user_id, char *cat_name, long item_no));

/* NFMcleanup.c */
extern long _NFMcleanup __CREF((struct NFMdegree *degree, struct NFMwf_info wf_info, char *cat_name, long item_no, char *file_status));
extern long _NFMfree_linked_lists __CREF((struct NFMsto_info *sto_list, struct NFMset_member *set_list));
extern long _NFMprint_linked_lists __CREF((struct NFMsto_info *sto_list, struct NFMset_member *set_list));

/* NFMcr_tab.c */
extern long _NFMcreate_table __CREF((char *table_type, char *table_name, char *identifier, long *table_no, MEMptr attr_list, MEMptr data_list, MEMptr value_list));
extern long _NFMcreate_attributes __CREF((char *table_name, MEMptr attr_list));
extern long _NFMload_attributes __CREF((char *table_type, char *table_name, char *identifier, long *table_no, MEMptr attr_list, MEMptr data_list, MEMptr value_list));
extern long _NFMload_value_info __CREF((char *type, long attr_no, char *def_value, MEMptr value_list));
extern long _NFMdelete_n_tableno __CREF((long table_no));
extern long _NFMdelete_n_listno __CREF((long list_no));
extern long NFMcreate_table __CREF((long user_id, char *table_type, char *table_name, char *identifier, MEMptr attr_list, MEMptr data_list, MEMptr value_list));
extern long _NFMcreate_application_table __CREF((char *catalog_name, MEMptr identifier_list));
extern long _NFMcreate_index __CREF((char *table_name, long template_no));
extern int free_type_index __CREF((long rows, char **index));

/* NFMdata_def.c */
extern long NFMci_get_data_def __CREF((long table_no, long ftable_no, MEMptr *attr_list, MEMptr *data_list));

/* NFMdel_tab.c */
extern long NFMdelete_table __CREF((long user_id, char *table_type, char *table_name));
extern long NFMdrop_table __CREF((long user_id, char *table_name));
extern long NFMunload_attributes __CREF((long user_id, char *table_type, char *table_name));
extern long NFMunload_value_info __CREF((long user_id, char *type, long attr_no));
extern long NFMunload_list_info __CREF((long user_id, long list_no));

/* NFMfile_name.c */
extern long NFMold_file_name __CREF((long user_id, long cat_no, long file_no, char *file_name));

/* NFMfl_tools.c */
extern long NFMfl_get_catalog_name __CREF((char *catalog_no, char *catalog_name));
extern long NFMfl_get_catalog_no __CREF((char *catalog, char *catalog_no));
extern long NFMfl_get_item_no __CREF((char *catalog, char *item_name, char *item_rev, char *item_no));
extern long NFMfl_validate_item_restore __CREF((char *catalog_no, char *item_no, char *file_no));
extern long NFMfl_validate_set_restore __CREF((char *catalog_no, char *item_no));
extern long NFMfl_catalog_attr_names __CREF((void));
extern long NFMfl_get_max_version __CREF((char *catalog, char *attr_itemno, int itemno, char *attr_version, int *version));
extern int NFMfl_check_for_file __CREF((char *catalog_no, char *item_no));

/* NFMisfile.c */
extern long _NFMisfile __CREF((char *filename));

/* NFMitem.c */
extern long NFMget_item_no __CREF((long user_id, char *cat_name, char *item_name, char *item_rev, long *item_no));
extern long NFMget_item_name __CREF((long user_id, char *cat_name, long item_no, char *item_name, char *item_rev));
extern long NFMcheck_item __CREF((long user_id, char *cat_name, long item_no, long type));
extern long NFMqry_items_in_cat __CREF((long user_id, char *catalog_name, MEMptr *data_list));
extern long NFMcheck_item_set_parent __CREF((long user_id, long cat_no, long item_no));
extern long NFMcheck_item_set_member __CREF((long user_id, long cat_no, long item_no));
extern long NFMcheck_item_project_member __CREF((long user_id, long cat_no, long item_no));

/* NFMitem_attr.c */
extern long NFMquery_item_attributes __CREF((long user_id, char *cat_name, char *item_name, char *item_rev, MEMptr *attr_list, MEMptr *data_list, MEMptr *value_list));
extern long NFMget_cat_acl_list __CREF((long user_id, char *cat_name, MEMptr *list));
extern long NFMget_proj_acl_list __CREF((long user_id, char *cat_name, MEMptr *list));
extern long NFMget_cat_sa_list __CREF((long user_id, char *cat_name, MEMptr *list));
extern long NFMget_proj_sa_list __CREF((long user_id, char *cat_name, MEMptr *list));
extern long _NFMget_cat_acl_list __CREF((long user_no, long cat_no, MEMptr *list));
extern long _NFMget_proj_acl_list __CREF((long user_no, long cat_no, int proj_no, MEMptr *list));
extern long _NFMget_cat_sa_list __CREF((long cat_no, MEMptr *list));
extern long _NFMget_proj_sa_list __CREF((long cat_no, long proj_no, MEMptr *list));

/* NFMitemtools.c */
extern long NFMset_item_status __CREF((char *cat_name, char *item_name, char *item_rev, long item_no, char *file_status, int lock_flag, char *plus_str));
extern long NFMretrieve_values __CREF((char *sql_str, long ret_type, char *ret_str, long *ret_value, MEMptr *ret_list));
extern long _NFMbuild_working_buffer_format __CREF((struct NFMbuf_format *format, long count, MEMptr list));

/* NFMloadmsg.c */
extern long _NFMload_error_message __CREF((char *item_name, char *item_rev, int operation, int operand, char *flag));

/* NFMlocktable.c */
extern long NFMlock_table __CREF((char *table_names));

/* NFMlop_attr.c */
extern long NFMquery_lop_definition __CREF((long user_id, char *lop_name, MEMptr *attr_list));
extern long NFMquery_addto_lop_attributes __CREF((long user_id, char *lop_name, MEMptr *attr_list, MEMptr *data_list, MEMptr *value_list));
extern long NFMquery_changeto_lop_attributes __CREF((long user_id, char *lop_name, char *proj_name, MEMptr *attr_list, MEMptr *data_list, MEMptr *value_list));

/* NFMmod_tab.c */
extern long NFMchange_table __CREF((long user_id, char *table_type, char *table_name, MEMptr attr_list, MEMptr data_list, MEMptr value_list));
extern long NFMchange_actual_attributes __CREF((long user_id, char *table_name, MEMptr attr_list));
extern long NFMchange_attributes __CREF((long user_id, char *table_type, char *table_name, MEMptr attr_list, MEMptr data_list, MEMptr value_list));
extern long NFMreset_change_table __CREF((int user_id, int table_type, int table_name, int attr_list, int data_list, int value_list));
extern long NFMreset_actual_attributes __CREF((long user_id, char *table_name, MEMptr attr_list));
extern long NFMreset_change_attributes __CREF((long user_id, char *table_type, char *table_name, MEMptr attr_list, MEMptr data_list, MEMptr value_list));
extern long _NFMcheck_dup_name __CREF((MEMptr attr_list));
extern long _NFMchange_value_info __CREF((char *type, long attr_no, char *def_value, MEMptr value_list));
extern long _NFMchange_list_info __CREF((MEMptr value_list, long *list_no));
extern long _NFMchange_range_info __CREF((MEMptr value_list, char *min, char *max));

/* NFMms.c */
extern long NFMupdate_microstation_file __CREF((long num_of_members, struct NFMset_member *list_members, struct NFMset_member **new_member_list, struct NFMsto_info sa_struct, struct NFMoperation *operation, long *no_dropped, long *no_added));
extern long _NFMfill_f_cat_info __CREF((long num_of_members, struct NFMset_member *list_members, struct file_info_struct **file_info, char *p_name, long *parent_catalog_no, long *parent_item_no));
extern long _NFMdelete_file_LFM __CREF((long no_dropped, struct NFMset_member *list_member, struct file_info_struct *file_info, struct sto_area_info sa_struct, struct NFMoperation *operation));
extern long _NFMfree_file_info_struct __CREF((struct file_info_struct *file_ptr));
extern long _NFMprint_NFMset_member __CREF((int no_members, struct NFMset_member *ptr));
extern long _NFMs_get_list_attached_reference_files __CREF((char *nodename, char *username, char *passwd, char *cofilename, MEMptr *attr_list));

/* NFMmsg.c */
extern long _NFMload_message __CREF((char *item_name, char *item_rev, int operation, char *flag));

/* NFMnodes.c */
extern long NFMget_node_no __CREF((long user_id, char *node_name, long *node_no));
extern long NFMget_node_name __CREF((long user_id, long node_no, char *node_name));

/* NFMo_n_fname.c */
extern long NFMo_n_fname __CREF((long user_id, long cat_no, long file_no, char *old_name, char *new_name));

/* NFMold_check.c */
extern long NFMset_temp_flag __CREF((long user_id, char *cat_name, long item_no, char *temp_state));
extern long NFMquery_ci_attributes __CREF((long user_id, char *cat_name, MEMptr *attr_list, MEMptr *data_list));
extern long NFMget_item_ci_list __CREF((long user_id, char *cat_name, long item_no, char *ctype, char *level, char *row_id, MEMptr attr_list, MEMptr data_list));
extern long NFMget_ci_files_list __CREF((long user_id, long i_row, long f_row, MEMptr attr_list, MEMptr data_list, MEMptr file_list, long type));
extern long NFMmake_file_cat_entry __CREF((long user_id, char *cat_name, long item_no, long item_ver, long *file_no));
extern long NFMupdate_ci_file_cat __CREF((long user_id, char *c_user, char *c_date, char *c_time, long sa_no, long i_row, long f_row, char *cat_name, long item_no, MEMptr attr_list, MEMptr data_list, MEMptr file_list));
extern long NFMcheck_in_user __CREF((long user_id, MEMptr attr_list, MEMptr data_list));
extern long NFMquery_co_attributes __CREF((long user_id, char *cat_name, MEMptr *attr_list, MEMptr *data_list));
extern long NFMget_item_co_list __CREF((long user_id, char *cat_name, long item_no, char *ctype, char *level, char *row_id, MEMptr attr_list, MEMptr data_list, long type));
extern long NFMget_co_files_list __CREF((long user_id, long i_row, long f_row, MEMptr attr_list, MEMptr data_list, MEMptr file_list, long type));
extern long NFMupdate_co_file_cat __CREF((long user_id, char *c_user, char *c_date, char *c_time, long sa_no, long i_row, long f_row, char *level, long type, char *cat_name, long item_no, MEMptr attr_list, MEMptr data_list, MEMptr file_list));
extern long NFMconvert_to_set __CREF((long user_id, char *cat_name, char *item_name, char *item_rev));
extern long NFMget_set_ci_list __CREF((long user_id, char *cat_name, long item_no, char *item_name, char *item_rev, MEMptr attr_list, MEMptr data_list));
extern long NFMget_set_checkout_level __CREF((long user_id, char *cat_name, long item_no, long *level));
extern long NFMconvert_to_item __CREF((long user_id, char *cat_name, char *item_name, char *item_rev));
extern long NFMreset_co_out_set_item __CREF((long user_id, char *cat_name, long item_no, long co_status));
extern long NFMget_set_co_list __CREF((long user_id, char *cat_name, long item_no, char *item_name, char *item_rev, long level, MEMptr attr_list, MEMptr data_list, long type));

/* NFMqry_chg.c */
extern long NFMj_query_attributes __CREF((char *table_name, char *table_type, char *nname, char *ret_name, MEMptr *attr_list));
extern int NFMj_tic_search __CREF((char *pwd, char *temp));

/* NFMquery_t.c */
extern long NFMfind_user_no __CREF((char *user_name, long *user_no));
extern long NFMgen_query_file_name __CREF((char *table_name, long table_index, char *query_file));
extern long NFMget_query_filename __CREF((char *query_name, char *file_name));
extern long NFMwrite_query_struct __CREF((struct NFMquery_info *query, char *select, char *from, char *where, char *order, char *prompts));
extern long NFMfree_query_struct __CREF((struct NFMquery_info *query));

/* NFMsatools.c */
extern long NFMget_storage_info __CREF((char *sa_name, long *sa_no, char *nodename, char *username, char *passwd, char *pathname, char *devicetype, char *plattername, char *partition, char *nfs, char *compress, char *machid, char *opsys, char *tcpip, char *xns, char *decnet, char *netware));
extern long NFMget_storages_information __CREF((struct NFMsto_info *sto_list, long sto_no, long type));
extern long _NFMprint_storages_information __CREF((struct NFMsto_info *sto_list, long sto_no));

/* NFMsettools.c */
extern long NFMretrieve_set_members __CREF((struct NFMmembers *members_list, long count, long level, struct NFMset_member *set_head, struct NFMset_member *set_end, long *num_members));
extern long NFMget_catalog_numbers __CREF((struct NFMset_member *set_head, long num_members));
extern long NFMget_members_info __CREF((struct NFMset_member *head_process, long count, long command));
extern long NFMrollback_set_status __CREF((struct NFMset_member *list, long count, long count1, long count2, struct NFMlfm_file *list1, struct NFMlfm_file *list2));

/* NFMstackerr.c */
extern long _NFMstack_error_from_buffer __CREF((MEMptr list, char *catalog_name, char *item_name, char *item_rev, long operation, MEMptr list1));

/* NFMstools.c */
extern long NFMget_cat_fcat_no __CREF((char *cat_name, long *cat_no, long *fcat_no, int type));

/* NFMtemplate.c */
extern long NFMquery_table_template __CREF((long user_id, MEMptr *attr_list));
extern long NFMquery_template_definition __CREF((char *table_type, char *table_name, char *identifier, MEMptr *attr_list));
extern long NFMquery_template_attributes __CREF((char *table_type, char *table_name, char *identifier, MEMptr *attr_list, MEMptr *data_list, MEMptr *value_list));
extern long NFMquery_template_information __CREF((char *table_type, char *table_name, char *identifier, MEMptr *attr_list, MEMptr *data_list, MEMptr *value_list));
extern long NFMcreate_template __CREF((char *table_type, char *table_name, char *identifier, MEMptr attr_list, MEMptr data_list, MEMptr value_list));
extern long NFMdelete_template __CREF((char *table_type, char *table_name, char *identifier));
extern long _NFMget_template_no __CREF((char *table_type, char *table_name, char *identifier, long *table_no));
extern long NFMchange_template __CREF((char *table_name, char *table_type, char *identifier, MEMptr attr_list, MEMptr data_list, MEMptr value_list));
extern long NFMi_template __CREF((MEMptr *attr_list));
extern long _NFMchange_attributes_for_template __CREF((char *table_type, char *table_name, char *identifier, MEMptr attr_list, MEMptr data_list, MEMptr value_list));
extern long NFMquery_change_template_information __CREF((char *table_type, char *table_name, char *identifier, MEMptr *attr_list, MEMptr *data_list, MEMptr *value_list));
extern long NFMsplit_template_definition __CREF((MEMptr attr_list, MEMptr *attr_list1, MEMptr *attr_list2, MEMptr *identifier_list));
extern long NFMsplit_template_attributes __CREF((MEMptr attr_list, MEMptr data_list, MEMptr *attr_list1, MEMptr *data_list1, MEMptr *attr_list2, MEMptr *data_list2, MEMptr *identifier_list));

/* NFMusers.c */
extern long NFMget_user_no __CREF((long user_id, char *user_name, long *user_no));
extern long NFMget_user_name __CREF((long user_id, long user_no, char *user_name));
extern long NFMget_current_user_name __CREF((long user_id, char *user_name));

/* NFMval_list.c */
extern long NFMget_transition_acl_list __CREF((long user_id, MEMptr *list));

/* NFMw_ris_par.c */
extern long NFMwrite_ris_parameters __CREF((char *env_name, char *node_name));

/* NFMwr_query.c */
extern long NFMwrite_query_file __CREF((char *report_name, int query_type, struct NFMquery_info query_info));

#undef __CREF

#endif
