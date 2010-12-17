#ifndef DBT_PROTO_H
#define DBT_PROTO_H

#if defined(__STDC__) || defined(__cplusplus)
# define __DBT(s) s
#else
# define __DBT(s) ()
#endif


/* NFMacls.c */
extern long NFMget_acl_no __DBT((long user_id, char *acl_name, long *acl_no));
extern long NFMget_acl_name __DBT((long user_id, long acl_no, char *acl_name));
extern long NFMget_acl_workflow_no __DBT((long user_id, long acl_no, long *wf_no));

/* NFMattr_size.c */
extern long NFMget_max_attr_size __DBT((long user_id, char *name, char *data_type));

/* NFMattr_val.c */
extern long NFMget_attr_value __DBT((long user_id, char *cat_name, char *attr, char *cond_str, char *value));

/* NFMbftr_adv.c */
extern long NFMblockftr_adv __DBT((MEMptr attr_list, MEMptr *out_list, char *cat_name, char *cat_no, char *search_name, char *sort_name, char *adv_select, char *adv_from, char *adv_where, char *ftr_where, long query_flag, long row_size, long cursor_id));

/* NFMbftr_attr.c */
extern int NFMblockftr_attr_list __DBT((MEMptr cat_list, char *src_catalog, MEMptr *out_list, MEMptr *synonym_list, MEMptr ris_attr, char *cat_name_syn));
/* NFMbmcslmcrs.c */
extern long NFMblocksac_list_m_crs __DBT((MEMptr attr_list, MEMptr *out_list, char *cat_name, char *cat_no, char *search_name, char *sort_name, long query_flag,long row_size, long cursor_id));

/* NFMbmcslmcrs.c */
extern long NFMblocksac_list_m_crsr __DBT((MEMptr attr_list, MEMptr *out_list, char *cat_name, char *cat_no, char *search_name, char *sort_name, long query_flag, long row_size, long cursor_id));

/* NFMbsac_attr.c */
extern int NFMblocksac_attr_list __DBT((MEMptr cat_list, char *src_catalog, MEMptr *out_list, MEMptr *synonym_list, char *cat_name_syn));

/* NFMbsac_list.c */
extern long NFMblocksac_list __DBT((MEMptr attr_list, MEMptr *out_list, char *cat_name, char *cat_no, char *search_name, char *sort_name, long query_flag, long row_size));

/* NFMcatalogs.c */
extern long NFMget_catalog_no __DBT((long user_id, char *catalog_name, long *catalog_no));
extern long NFMget_catalog_name __DBT((long user_id, long catalog_no, char *catalog_name));

/* NFMclasses.c */
extern long NFMget_class_no __DBT((long user_id, long wf_no, char *class_name, long *class_no));
extern long NFMget_class_name __DBT((long user_id, long wf_no, long class_no, char *class_name));
extern long NFMget_class_workflow_no __DBT((long user_id, long class_no, long *wf_no));

/* NFMcommands.c */
extern long NFMget_command_no __DBT((long user_id, char *command_name, long *command_no));
extern long NFMget_command_name __DBT((long user_id, long command_no, char *command_name));
extern long NFMget_command_entity __DBT((long user_id, long command_no, char *entity));
extern long NFMget_nfm_command_no __DBT((long user_id, char *command_name, long *command_no));

/* NFMcond_attr.c */
extern long NFMquery_condition_definition __DBT((long user_id, char *table_type, char *table_name, char *table_str, char *cond_str, MEMptr *attr_list));
extern long NFMquery_condition_attributes __DBT((long user_id, char *table_type, char *table_name, char *table_str, char *cond_str, MEMptr *attr_list, MEMptr *data_list, MEMptr *value_list));
extern long NFMquery_condition_attributes_value2 __DBT((long user_id, char *table_type, char *table_name, char *table_str, char *cond_str, MEMptr *attr_list, MEMptr *data_list, MEMptr *value_list));
extern long NFMquery_condition_information __DBT((long user_id, char *table_type, char *table_name, char *table_str, char *cond_str, MEMptr *attr_list, MEMptr *data_list, MEMptr *value_list));
extern long NFMquery_change_condition_information __DBT((long user_id, char *table_type, char *table_name, char *table_str, char *cond_str, MEMptr *attr_list, MEMptr *data_list, MEMptr *value_list));

/* NFMdate.c */
extern long NFMascii_to_timestamp_format __DBT((char *in_str, char *out_str));
extern long NFMvalidate_and_format_date __DBT((char *input_string, char *display_date, char *timestamp_date));
extern long NFMget_date_info __DBT((char *date_type, char *time_type, char *format_string));
extern long NFMvalidate_time __DBT((char *in_time));
extern long _NFMget_date_time_str __DBT((char *input_string, char *date_time_str, char *timestamp_date, char *display_date));
extern long NFMget_datetime __DBT((char *ret_date));
extern long NFMget_date __DBT((char *ret_date));

/* NFMdb_sql.c */
extern long NFMsqlquery __DBT((char *sql_string, char *buffer_size, MEMptr *data_list));
extern long NFMsqlquery_cursor __DBT((char *sql_string, char *buffer_size, long rows, int cursor, MEMptr *data_list));
extern long NFMsqlstmt __DBT((char *sql_string, MEMptr *data_list));

/* NFMdb_trans.c */
extern long NFMset_autocommit_off __DBT((long type));
extern long NFMset_autocommit_on __DBT((long type));
extern long NFMstop_transaction __DBT((long type));
extern long NFMstart_transaction __DBT((long type));
extern long NFMrollback_transaction __DBT((long type));
extern long NFMcheck_transaction __DBT((void));

/* NFMget_attrs.c */
extern long _NFMget_attributes_from_query __DBT((char *sql_string, MEMptr *attr_list));
extern long NFMquery_attr_def __DBT((long user_id, char *table_type, char *table_name, char *table_str, char *cond_str, MEMptr *attr_list));
extern long _NFMquery_systable_attributes __DBT((char *table_name, MEMptr *attr_list, MEMptr *data_list, MEMptr *value_list));
extern long NFMget_table_attr __DBT((long user_id, char *table_str, char *cond_str, MEMptr *list));
extern long NFMget_systable_attr __DBT((long user_id, char *table_str, char *cond_str, MEMptr *list));
extern long NFMget_attr_def __DBT((long user_id, char *table_str, char *cond_str, MEMptr *list));
extern long NFMget_sysattr_def __DBT((long user_id, char *table_str, char *cond_str, MEMptr *list));
extern long NFMmerge_change_attributes __DBT((long user_id, MEMptr temp_attr, MEMptr temp_data, MEMptr temp_value, MEMptr *attr_list, MEMptr *data_list, MEMptr *value_list));
extern long _NFMget_table_attr __DBT((char *table_name, MEMptr *list));
extern long _NFMget_table_attr_u __DBT((char *table_name, MEMptr *list));
extern long _NFMget_systable_attr __DBT((char *table_name, MEMptr *list, long *next_seq));
extern long _NFMget_table_attr_for_appl __DBT((MEMptr *list, MEMptr application));
extern long NFMget_attr_no __DBT((long user_id, char *table_type, char *table_name, char *attr_name, long *attr_no));
extern long NFMj_query_attributes __DBT((char *table_name, char *table_type, char *nname, char *ret_name, MEMptr *attr_list));
extern long NFMquery_attributes __DBT((char *table_name, char *table_type, MEMptr *attr_list));

/* NFMget_cat.c */
extern long NFMget_cat_list __DBT((MEMptr cat_list, MEMptr *list));

/* NFMget_prog.c */
extern long NFMget_program_filename __DBT((long user_id, char *program_name, char *file_name));

/* NFMget_vals.c */
extern long _NFMget_data_value __DBT((MEMptr attr_list, MEMptr *data_list, MEMptr *value_list, char *flag, char *data_buf_flag));
extern long _NFMget_range_list __DBT((char *min, char *max, MEMptr *list));
extern long _NFMget_list_list __DBT((long attrno, long list_no, char *type, MEMptr *list, MEMptr list_buffer, char *advice_string));
extern long NFMget_range_info __DBT((long user_id, char *min, char *max, MEMptr *list));
extern long NFMget_list_info __DBT((long user_id, long list_no, MEMptr *list));
extern long NFMbuild_attr_list __DBT((MEMptr *list));
extern long _NFMbuild_attr_list __DBT((MEMptr *list));
extern long _NFMget_data_info __DBT((MEMptr attr_list, MEMptr *data_list, MEMptr *value_list));
extern long _NFMmake_list_buf __DBT((long list_no, MEMptr *list, MEMptr list_buffer, long attrno, char *type, char *advice_string));
extern long _NFMmake_range_buf __DBT((char *min, char *max, MEMptr *list));
extern long _NFMadd_to_value_list __DBT((MEMptr *attr_list, MEMptr *value_list, char *table_type, long row, long column_of_valueno));
extern long _NFMadd_to_value_list_from_query __DBT((MEMptr *attr_list, MEMptr *value_list, char *sql_query, long row, long column_of_valueno));

/* NFMitem_l.c */
extern long NFMitem_list __DBT((MEMptr *out_buffer_list, char *cat_name, char *cat_no, char *sort_name));

/* NFMlfm_info.c */
extern long NFMlfm_information __DBT((long sa_no, long flag, char *search, char *sort, MEMptr *output_list));

/* NFMlfm_upd.c */
extern long NFMlfm_update __DBT((MEMptr input_list, long flag));

/* NFMlist_catn.c */
extern long NFMlist_cat_names __DBT((long user_id, MEMptr *list, char *search_name, char *sort_name, long flag));

/* NFMprograms.c */
extern long NFMget_program_no __DBT((long user_id, char *program_name, long *program_no));
extern long NFMget_program_name __DBT((long user_id, long program_no, char *program_name));

/* NFMprojects.c */
extern long NFMget_project_no __DBT((long user_id, char *project_name, long *project_no));
extern long NFMget_project_name __DBT((long user_id, long project_no, char *project_name));
extern long NFMcheck_projectcit_empty __DBT((long user_id, long proj_no));
extern long NFMcheck_project_aclmap_empty __DBT((long user_id, long proj_no));
extern long NFMcheck_project_samap_empty __DBT((long user_id, long proj_no));
extern long NFMdelete_lop_entry __DBT((long user_id, long proj_no));
extern long NFMinternal_add_project_member __DBT((long user_id, long proj_no, long cat_no, long item_no));
extern long _NFMcheck_project_state __DBT((long proj_no));
extern long _NFMcheck_project_complete_mapping __DBT((long proj_no));

/* NFMsa.c */
extern long NFMget_sa_no __DBT((long user_id, char *sa_name, long *sa_no));
extern long NFMget_sa_name __DBT((long user_id, long sa_no, char *sa_name));
extern long NFMcheck_sa_no __DBT((long user_id, long sa_no));
extern long NFMget_sa_no_info __DBT((long user_id, long sa_no, char *node_name, char *user_name, char *passwd, char *path_name, char *device_type, char *mach_id, char *op_sys, char *net_tcp, char *net_xns, char *net_dec));
extern long NFMget_sa_no_buffer __DBT((long user_id, long sa_no, MEMptr *list));
extern long _NFMget_sano_info_fto_buf __DBT((long sa_no, char *sa_name, struct fto_buf *file_buffer));

/* NFMsac_attr.c */
extern int NFMsac_attr_list __DBT((MEMptr cat_list, char *src_catalog, MEMptr *out_list, MEMptr *synonym_list, char *cat_name_syn));

/* NFMsac_list.c */
extern long NFMsac_list __DBT((MEMptr attr_list, MEMptr *out_list, char *cat_name, char *cat_no, char *search_name, char *sort_name, long query_flag));

/* NFMserial.c */
extern long NFMget_serial_slot __DBT((long user_id, char *table_name, char *col_name, long *serial_no));
extern long NFMreturn_serial_slot __DBT((long user_id, char *table_name, char *col_name, long serial_no));
extern long NFMget_serial_slot_no_index __DBT((long user_id, char *table_name, char *col_name, long *serial_no));
extern long NFMget_serial_slot_wck __DBT((long user_id, char *table_name, char *col_name, long *serial_no, long *flag));

/* NFMstates.c */
extern long NFMget_state_no __DBT((long user_id, long wf_no, char *state_name, long *state_no));
extern long NFMget_state_name __DBT((long user_id, long wf_no, long state_no, char *state_name));
extern long NFMget_state_workflow_no __DBT((long user_id, long state_no, long *wf_no));
extern long NFMcheck_state_signoff __DBT((long user_id, long state_no, long *no_signoff, char *override));
extern long NFMget_acl_state_no __DBT((long user_id, long acl_no, long *state_no));

/* NFMtab_attr.c */
extern long NFMquery_attributes_definition __DBT((long user_id, char *table_type, char *table_name, MEMptr *attr_list));
extern long NFMquery_table_definition __DBT((long user_id, char *table_type, char *table_name, MEMptr *attr_list));
extern long NFMquery_table_attributes __DBT((long user_id, char *table_type, char *table_name, MEMptr *attr_list, MEMptr *data_list, MEMptr *value_list));
extern long NFMquery_table_attributes_value2 __DBT((long user_id, char *table_type, char *table_name, MEMptr *attr_list, MEMptr *data_list, MEMptr *value_list));
extern long NFMquery_table_information __DBT((long user_id, char *table_type, char *table_name, MEMptr *attr_list, MEMptr *data_list, MEMptr *value_list));
extern long NFMquery_change_table_information __DBT((long user_id, char *table_type, char *table_name, MEMptr *attr_list, MEMptr *data_list, MEMptr *value_list));

/* NFMtables.c */
extern long NFMget_table_no __DBT((long user_id, char *table_type, char *table_name, long *table_no));
extern long NFMget_table_name __DBT((long user_id, long table_no, char *table_type, char *table_name));

/* NFMtrans.c */
extern long NFMget_transition_no __DBT((long user_id, long wf_no, char *trans_name, long *trans_no));
extern long NFMget_transition_name __DBT((long user_id, long wf_no, long trans_no, char *trans_name));
extern long NFMcheck_transition_notify __DBT((long user_id, long trans_no));
extern long NFMcheck_transition_success_log __DBT((long user_id, long trans_no));
extern long NFMcheck_transition_fail_log __DBT((long user_id, long trans_no));

/* NFMusers.c */
extern long NFMget_user_no __DBT((long user_id, char *user_name, long *user_no));
extern long NFMget_user_name __DBT((long user_id, long user_no, char *user_name));
extern long NFMget_current_user_name __DBT((long user_id, char *user_name));

/* NFMval_list.c */
extern long NFMget_transition_acl_list __DBT((long user_id, MEMptr *list));
extern long _NFMget_catalog_acl_list __DBT((MEMptr *list));

/* NFMworkflow.c */
extern long NFMget_workflow_no __DBT((long user_id, char *workflow_name, long *workflow_no));
extern long NFMget_workflow_name __DBT((long user_id, long workflow_no, char *workflow_name));

#undef __DBT

#endif
