#ifndef CMDT_PROTO_H
#define CMDT_PROTO_H

#if defined(__STDC__) || defined(__cplusplus)
# define __CMDT(s) s
#else
# define __CMDT(s) ()
#endif

/*      Added for SCO port MVR 20 Dec 1993 */
/* OS_HPUX added for HP PORT - IGI - 13 Jun 94 */
#if defined( OS_SCO_UNIX) || defined(OS_HPUX)
#include "NFMapi.h"
#include "NFMitems.h"
#endif

/* NFMadd_query.c */
extern long NFMadd_query __CMDT((char *query_name, char *query_desc, int query_type, char *application, long owner_no, char *query_file));
extern long NFMupdate_query __CMDT((char *query_name, char *query_desc, int query_type, char *application, long owner_no));

/* NFMbld_qry.c */
extern long _NFMbuildRISattributes __CMDT((struct NFMquery_ftr_info qInfo, MEMptr *attrList));
extern long _NFMgetAdvancedClauses __CMDT((struct NFMquery_ftr_info qInfo, char **selectClause, char **fromClause, char **whereClause));

/* NFMcat_attr.c */
extern long NFMquery_catalog_definition __CMDT((long user_id, char *cat_name, MEMptr *attr_list));
extern long NFMquery_catalog_attributes __CMDT((long user_id, char *cat_name, MEMptr *attr_list, MEMptr *data_list, MEMptr *value_list));
extern long NFMquery_catalog_information __CMDT((long user_id, char *cat_name, MEMptr *attr_list, MEMptr *data_list, MEMptr *value_list));
extern long NFMquery_change_catalog_information __CMDT((long user_id, char *cat_name, MEMptr *attr_list, MEMptr *data_list, MEMptr *value_list));
extern long NFMsplit_catalog_definition __CMDT((long user_id, MEMptr attr_list, MEMptr *attr_list1, MEMptr *attr_list2));
extern long NFMsplit_catalog_attributes __CMDT((long user_id, MEMptr attr_list, MEMptr data_list, MEMptr *attr_list1, MEMptr *data_list1, MEMptr *attr_list2, MEMptr *data_list2));
extern long _NFMquery_catalog_attributes __CMDT((char *catalog_name, MEMptr *attr_list, MEMptr *data_list, MEMptr *value_list));
extern long _NFMquery_catalog_attributes_w __CMDT((char *catalog_name, MEMptr *attr_list, MEMptr *data_list, MEMptr *value_list));
extern long _NFMquery_catalog_attributes_u __CMDT((char *catalog_name, MEMptr *attr_list, MEMptr *data_list, MEMptr *value_list));
extern long NFMget_ris_attributes __CMDT((char *catalog_name, MEMptr *attrList));

/* NFMchk_arch.c */
extern long NFMcheck_archive_state __CMDT((long user_id, char *cat_name, long item_no));

/* NFMchk_co.c */
extern long NFMcheck_co_status __CMDT((long user_id, char *cat_name, long item_no, char *state));

/* NFMchk_dev.c */
extern long NFMcheck_device_type __CMDT((char *dev_type));

/* NFMchk_proc.c */
extern long NFMcheck_process_locks __CMDT((long user_id));
extern long NFMset_process_lock __CMDT((long user_id, long lock_status));
extern long NFMreset_process_lock __CMDT((long user_id, long lock_status));

/* NFMchk_set.c */
extern long NFMcheck_item_setindicator __CMDT((long user_id, char *cat_name, long item_no));

/* NFMcleanup.c */
extern long _NFMcleanup __CMDT((struct NFMdegree *degree, struct NFMwf_info wf_info, char *cat_name, long item_no, char *file_status));
extern long _NFMfree_linked_lists __CMDT((struct NFMsto_info *sto_list, struct NFMset_member *set_list));
extern long _NFMprint_linked_lists __CMDT((struct NFMsto_info *sto_list, struct NFMset_member *set_list));

/* NFMcr_tab.c */
extern long _NFMcreate_table __CMDT((char *table_type, char *table_name, char *identifier, long *table_no, MEMptr attr_list, MEMptr data_list, MEMptr value_list));
extern long _NFMcreate_attributes __CMDT((char *table_name, MEMptr attr_list));
extern long _NFMload_attributes __CMDT((char *table_type, char *table_name, char *identifier, long *table_no, MEMptr attr_list, MEMptr data_list, MEMptr value_list));
extern long _NFMload_value_info __CMDT((char *type, long attr_no, char *def_value, MEMptr value_list));
extern long _NFMload_advice_info __CMDT((char *advice_string, long attr_no));
extern long _NFMdelete_values __CMDT((long attr_no));
extern long _NFMdelete_n_listno __CMDT((long list_no));
extern long NFMcreate_table __CMDT((long user_id, char *table_type, char *table_name, char *identifier, MEMptr attr_list, MEMptr data_list, MEMptr value_list));
extern long _NFMcreate_application_table __CMDT((char *catalog_name, MEMptr identifier_list));
extern long _NFMcreate_table_with_index __CMDT((char *tabletype, char *tablename, char *identifier, char *new_tablename));
extern long _NFMcreate_index __CMDT((char *table_name, long template_no));
extern int free_type_index __CMDT((long rows, char **index));

/* NFMdata_def.c */
extern long NFMci_get_data_def __CMDT((long table_no, long ftable_no, MEMptr *attr_list, MEMptr *data_list));

/* NFMdef_qry.c */
extern long _NFMdefine_query __CMDT((char *query_name, char *query_desc, int query_type, char *application, char *user_name, struct NFMquery_info query_info));
extern long _NFMdefine_ftr_query __CMDT((char *query_name, char *query_desc, int query_type, char *application, char *user_name, struct NFMquery_ftr_info query_info));

/* NFMdel_tab.c */
extern long NFMdelete_table __CMDT((long user_id, char *table_type, char *table_name));
extern long NFMdrop_table __CMDT((long user_id, char *table_name));
extern long NFMunload_attributes __CMDT((long user_id, char *table_type, char *table_name));
extern long NFMunload_value_info __CMDT((long user_id, char *type, long attr_no));
extern long NFMunload_list_info __CMDT((long user_id, long list_no));
extern long _NFMdelete_application_tables __CMDT((char *catalog_name));
extern long _NFMdelete_n_tableno __CMDT((long table_no));

/* NFMerror.c */
extern long _NFMextract_info_from_buf __CMDT((long st_code, MEMptr buf, long client, long cmd, long type, char *cat_name, char *item_name, char *item_rev));

/* NFMfile_name.c */
extern long NFMold_file_name __CMDT((long user_id, long cat_no, long file_no, char *file_name));

/* NFMfind_tape.c */
extern int NFMfind_items_on_tape __CMDT((it_list *list));
extern int NFMmap_saveset_numbers __CMDT((char *catalog_no, char *item_no, char *catalog, char *item, char *rev));

/* NFMfl_tools.c */
extern long NFMfl_get_catalog_name __CMDT((char *catalog_no, char *catalog_name));
extern long NFMfl_get_catalog_no __CMDT((char *catalog, char *catalog_no));
extern long NFMfl_get_item_no __CMDT((char *catalog, char *item_name, char *item_rev, char *item_no));
extern long NFMfl_get_item_name __CMDT((char *catalog_no, char *item_no, char *item_name, char *item_rev));
extern long NFMfl_validate_item_restore __CMDT((char *catalog_no, char *item_no, char *file_no));
extern long NFMfl_validate_set_restore __CMDT((char *catalog_no, char *item_no));
extern long NFMfl_get_max_version __CMDT((char *catalog, int itemno, int *version));
extern int NFMfl_check_for_file __CMDT((char *catalog_no, char *item_no));

/* NFMflag.c */
extern long NFMfl_flag_update_tree __CMDT((struct NFMflag_node_st *node, long level, char *flag));
extern long NFMfl_flag_build_tree __CMDT((struct NFMflag_node_st *node, long level, int op_flag));
extern void NFMfl_flag_free_tree __CMDT((struct NFMflag_node_st *node));
extern long NFMfl_cancel_build_tree __CMDT((struct NFMflag_node_st *node, long level, int utility));
extern long NFMfl_cancel_update_tree __CMDT((struct NFMflag_node_st *node));
extern long NFMfl_cancel_update_tree_new __CMDT((struct NFMflag_node_st *node));
extern long NFMfl_cancel_build_tree_new __CMDT((struct NFMflag_node_st *node, long level));

/* NFMftrtools.c */
extern long _NFMmount_add_index __CMDT((MEMptr files, long operation_type));
extern long _NFMprepare_keywords __CMDT((long cat_no, long item_no, char *filename, char **keywords, long operation_type));
extern long _NFMexpand_buffer __CMDT((MEMptr *buffer, char *cat_name, long cat_no, long item_no));
extern long _NFMprepare_files_buffer __CMDT((char *cat_name, long cat_no, char *item_name, char *item_rev, long item_no, MEMptr data_list, MEMptr *file_list));
extern long _NFMbuild_and_mount __CMDT((MEMptr files, MEMptr *m_files));
extern long _DMbuild_ftr_buffer __CMDT((MEMptr *list, long size));

/* NFMgitemfile.c */
extern long NFMload_item_file_information __CMDT((long type, MEMptr list, MEMptr file_list, struct NFMitem_entry *item_entry, struct NFMset_member *set_members));
extern long NFMfree_item_file_information __CMDT((struct NFMitem_entry *item_file_list));
extern long NFMprint_item_file_information __CMDT((struct NFMitem_entry *item_file_list));

/* NFMisfile.c */
extern long _NFMisfile __CMDT((char *filename));

/* NFMitem.c */
extern long NFMget_item_no __CMDT((long user_id, char *cat_name, char *item_name, char *item_rev, long *item_no));
extern long NFMget_item_name __CMDT((long user_id, char *cat_name, long item_no, char *item_name, char *item_rev));
extern long NFMcheck_item __CMDT((long user_id, char *cat_name, long item_no, long type));
extern long NFMqry_items_in_cat __CMDT((long user_id, char *catalog_name, MEMptr *data_list));
extern long NFMcheck_item_set_parent __CMDT((long user_id, long cat_no, long item_no));
extern long NFMcheck_item_set_member __CMDT((long user_id, long cat_no, long item_no));
extern long NFMcheck_item_project_member __CMDT((long user_id, long cat_no, long item_no));
extern long NFMcheck_pending_flag __CMDT((long user_id, char *cat_name, long item_no));

/* NFMitem_attr.c */
extern long NFMquery_item_attributes __CMDT((long user_id, char *cat_name, char *item_name, char *item_rev, MEMptr *attr_list, MEMptr *data_list, MEMptr *value_list));
extern long NFMquery_item_attributes_u __CMDT((long user_id, char *cat_name, char *item_name, char *item_rev, MEMptr *attr_list, MEMptr *data_list, MEMptr *value_list));
extern long NFMget_cat_acl_list __CMDT((long user_id, char *cat_name, MEMptr *list));
extern long NFMget_proj_acl_list __CMDT((long user_id, char *cat_name, MEMptr *list));
extern long NFMget_cat_sa_list __CMDT((long user_id, char *cat_name, MEMptr *list));
extern long NFMget_proj_sa_list __CMDT((long user_id, char *cat_name, MEMptr *list));
extern long _NFMget_cat_acl_list __CMDT((long user_no, long cat_no, MEMptr *list));
extern long _NFMget_proj_acl_list __CMDT((long user_no, long cat_no, long proj_no, MEMptr *list));
extern long _NFMget_cat_sa_list __CMDT((long cat_no, MEMptr *list));
extern long _NFMget_cat_internal_sa_list __CMDT((long cat_no, MEMptr *list));
extern long _NFMget_proj_sa_list __CMDT((long cat_no, long proj_no, MEMptr *list));
extern long _NFMget_internal_sa_list_for_item __CMDT((char *cat_name, char *item_name, char *item_rev, MEMptr *list));
extern long _NFMget_acl_for_item __CMDT((char *cat_name, char *item_name, char *item_rev, MEMptr *list));
extern long NFMcheck_item_owned_project __CMDT((long user_id, char *cat_name, char *item_name, char *item_rev, long *proj_no));
extern long _NFMget_acls_for_user __CMDT((long commandno, long userno, MEMptr *list2));

/* NFMitemtools.c */
extern long NFMset_item_status __CMDT((char *cat_name, char *item_name, char *item_rev, long item_no, char *file_status, long lock_flag, char *plus_str));
extern long _NFMlock_and_retrieve_values __CMDT((char *sql_str, long ret_type, char *ret_str, long *ret_value, MEMptr *ret_list, long lock_flag, char *table));
extern long NFMretrieve_values __CMDT((char *sql_str, long ret_type, char *ret_str, long *ret_value, MEMptr *ret_list));
extern long _NFMbuild_working_buffer_format __CMDT((struct NFMbuf_format *format, long count, MEMptr list));
extern long NFMcheck_catalog_attributes __CMDT((char *item_name, char *item_rev, MEMptr list, long command));
extern long NFMcommon_queries __CMDT((char *cat_name, char *w_clause, char *ret_string, long *ret_value, MEMptr *ret_list, long query_type, long return_type, long lock_flag));
extern long _NFMrollback_and_undo_buffer __CMDT((long command, long operand, MEMptr file_list, struct NFMlfm_file *lfm_list, MEMptr files_info, char *catalog_name, long catalog_no, long item_no, long wsano, long type));
extern long _DMcall_do_nothing __CMDT((long count));

/* NFMloadmsg.c */
extern long _NFMload_error_message __CMDT((char *item_name, char *item_rev, int operation, int operand, char *flag, char *flag2));

/* NFMlocktable.c */
extern long NFMlock_table __CMDT((char *table_names));
extern long NFMsharelock_table __CMDT((char *table_names));

/* NFMlop_attr.c */
extern long NFMquery_lop_definition __CMDT((long user_id, char *lop_name, MEMptr *attr_list));
extern long NFMquery_addto_lop_attributes __CMDT((long user_id, char *lop_name, MEMptr *attr_list, MEMptr *data_list, MEMptr *value_list));

/* NFMmod_tab.c */
extern long NFMchange_table __CMDT((long user_id, char *table_type, char *table_name, MEMptr attr_list, MEMptr data_list, MEMptr value_list));
extern long NFMchange_actual_attributes __CMDT((long user_id, char *table_name, MEMptr attr_list));
extern long NFMchange_attributes __CMDT((long user_id, char *table_type, char *table_name, MEMptr attr_list, MEMptr data_list, MEMptr value_list));
extern long NFMreset_change_table __CMDT((int user_id, int table_type, int table_name, int attr_list, int data_list, int value_list));
extern long NFMreset_actual_attributes __CMDT((long user_id, char *table_name, MEMptr attr_list));
extern long NFMreset_change_attributes __CMDT((long user_id, char *table_type, char *table_name, MEMptr attr_list, MEMptr data_list, MEMptr value_list));
extern long _NFMcheck_dup_name __CMDT((MEMptr attr_list));
extern long _NFMchange_value_info __CMDT((char *type, long attr_no, char *def_value, MEMptr value_list));
extern long _NFMchange_advice_info __CMDT((char *new_advice_string, long attr_no));
extern long _NFMchange_list_info __CMDT((MEMptr value_list, long *list_no));
extern long _NFMchange_range_info __CMDT((MEMptr value_list, char *min, char *max));

/* NFMms.c */
extern long NFMupdate_microstation_file __CMDT((long num_of_members, struct NFMset_member *list_members, struct NFMset_member **new_member_list, struct NFMsto_info sa_struct, struct NFMoperation *operation, long *no_dropped, long *no_added, long ms_p_catno, long ms_p_itemno, struct file_info_struct **file_info));
extern long NFMbuild_microstation_set __CMDT((char *p_catalogname, long p_catalogno, long p_itemno, char *n_cofilename, long *promoted_to_set, struct NFMsto_info sa_struct));

/* NFMms_tools.c */
extern long NFMundo_microstation_set __CMDT((char *catalog_name, long p_catalogno, long p_itemno, long promoted_to_set));
extern long _NFMfill_f_cat_info __CMDT((struct NFMset_member *list_members, struct file_info_struct **file_info, char *p_name, struct file_info_struct **last_info, long ms_p_catno, long ms_p_itemno, long *no_first_level));
extern long _NFMdelete_file_LFM __CMDT((long no_dropped, struct NFMset_member *list_member, struct file_info_struct *file_info, struct NFMsto_info sa_struct, struct NFMoperation *operation));
extern long _NFMfree_file_info_struct __CMDT((struct file_info_struct *file_ptr));
extern long _NFMprint_file_info_struct __CMDT((struct file_info_struct *file_ptr_gold));
extern long _NFMprint_NFMset_member __CMDT((int no_members, struct NFMset_member *ptr));
extern long _NFMrollback_microstation_operation __CMDT((struct file_info_struct *file_ptr_gold, long p_catno, long p_itemno, struct sto_area_info sa_struct));
extern long _NFMappend_dropped_members __CMDT((MEMptr file_list));

/* NFMmsg.c */
extern long _NFMload_message __CMDT((char *item_name, char *item_rev, int operation, char *flag));

/* NFMnodes.c */
extern long NFMget_node_no __CMDT((long user_id, char *node_name, long *node_no));
extern long NFMget_node_name __CMDT((long user_id, long node_no, char *node_name));

/* NFMo_n_fname.c */
extern long NFMo_n_fname __CMDT((long user_id, long cat_no, long file_no, char *old_name, char *new_name));

/* NFMold_check.c */
extern long NFMset_temp_flag __CMDT((long user_id, char *cat_name, long item_no, char *temp_state));
extern long NFMquery_ci_attributes __CMDT((long user_id, char *cat_name, MEMptr *attr_list, MEMptr *data_list));
extern long NFMget_item_ci_list __CMDT((long user_id, char *cat_name, long item_no, char *ctype, char *level, char *row_id, MEMptr attr_list, MEMptr data_list));
extern long NFMget_ci_files_list __CMDT((long user_id, long i_row, long f_row, MEMptr attr_list, MEMptr data_list, MEMptr file_list, long type));
extern long NFMmake_file_cat_entry __CMDT((long user_id, char *cat_name, long item_no, long item_ver, long *file_no));
extern long NFMupdate_ci_file_cat __CMDT((long user_id, char *c_user, char *c_date, char *c_time, long sa_no, long i_row, long f_row, char *cat_name, long item_no, MEMptr attr_list, MEMptr data_list, MEMptr file_list));
extern long NFMcheck_in_user __CMDT((long user_id, MEMptr attr_list, MEMptr data_list));
extern long NFMquery_co_attributes __CMDT((long user_id, char *cat_name, MEMptr *attr_list, MEMptr *data_list));
extern long NFMget_item_co_list __CMDT((long user_id, char *cat_name, long item_no, char *ctype, char *level, char *row_id, MEMptr attr_list, MEMptr data_list, long type));
extern long NFMget_co_files_list __CMDT((long user_id, long i_row, long f_row, MEMptr attr_list, MEMptr data_list, MEMptr file_list, long type));
extern long NFMupdate_co_file_cat __CMDT((long user_id, char *c_user, char *c_date, char *c_time, long sa_no, long i_row, long f_row, char *level, long type, char *cat_name, long item_no, MEMptr attr_list, MEMptr data_list, MEMptr file_list));
extern long NFMconvert_to_set __CMDT((long user_id, char *cat_name, char *item_name, char *item_rev));
extern long NFMget_set_ci_list __CMDT((long user_id, char *cat_name, long item_no, char *item_name, char *item_rev, MEMptr attr_list, MEMptr data_list));
extern long NFMget_set_checkout_level __CMDT((long user_id, char *cat_name, long item_no, long *level));
extern long NFMconvert_to_item __CMDT((long user_id, char *cat_name, char *item_name, char *item_rev));
extern long NFMreset_co_out_set_item __CMDT((long user_id, char *cat_name, long item_no, long co_status));
extern long NFMget_set_co_list __CMDT((long user_id, char *cat_name, long item_no, char *item_name, char *item_rev, long level, MEMptr attr_list, MEMptr data_list, long type));

/* NFMqry_chg.c */
extern long NFMj_query_attributes __CMDT((char *table_name, char *table_type, char *nname, char *ret_name, MEMptr *attr_list));
extern int NFMj_tic_search __CMDT((char *pwd, char *temp));

/* NFMquery_t.c */
extern long NFMfind_user_no __CMDT((char *user_name, long *user_no));
extern long NFMgen_query_file_name __CMDT((char *table_name, long table_index, char *query_file));
extern long NFMget_query_filename __CMDT((char *query_name, char *file_name));
extern long _NFMbuild_system_path __CMDT((char *admin_user, char *path));
extern long NFMget_ftr_query_filename __CMDT((char *query_name, char *query_type, char *file_name));

/* NFMret_qry.c */
extern long _NFMretrieve_query __CMDT((char *query_name, struct NFMquery_info *query_info));
extern long _NFMretrieve_query_info __CMDT((char *query_name, char *query_type, char *application, char *appl_type, char *query_desc, char *owner, struct NFMquery_info *query_info));
extern long _NFMread_query_info __CMDT((char *report_file, struct NFMquery_info *query_struct));
extern long _NFMretrieve_ftr_query __CMDT((char *query_name, char *query_type, struct NFMquery_ftr_info *query_info));
extern long _NFMretrieve_ftr_query_info __CMDT((char *query_name, char *query_type, char *application, char *appl_type, char *query_desc, char *owner, struct NFMquery_ftr_info *query_info));
extern long _NFMread_ftr_query_info __CMDT((char *report_file, struct NFMquery_ftr_info *query_struct));

/* NFMrlbk_dlcp.c */
extern long NFMrollback_delete_copied_files_status __CMDT((struct NFMitem_entry *items_list));

/* NFMsatools.c */
extern long NFMget_storage_info __CMDT((char *sa_name, long *sa_no, char *nodename, char *username, char *passwd, char *pathname, char *devicetype, char *plattername, char *partition, char *nfs, char *compress, char *machid, char *opsys, char *tcpip, char *xns, char *decnet, char *netware));
extern long NFMget_storages_information __CMDT((struct NFMsto_info *sto_list, long sto_no, long type));
extern long _NFMprint_storages_information __CMDT((struct NFMsto_info *sto_list, long sto_no));

/* NFMsettools.c */
extern long NFMretrieve_set_members __CMDT((struct NFMmembers *members_list, long count, long level, struct NFMset_member *set_head, struct NFMset_member *set_end, long *num_members));
extern long NFMget_catalog_names __CMDT((struct NFMset_member *set_head, long num_members));
extern long NFMget_members_info __CMDT((struct NFMset_member *head_process, long count, long command));
extern long NFMrollback_set_status __CMDT((long command, struct NFMset_member *set_list, MEMptr files_info, long records, long frecords, long lfm_records, struct NFMlfm_file *lfm_list1, struct NFMlfm_file *lfm_list2));
extern long NFMget_catalog_numbers __CMDT((struct NFMset_member *set_head, long num_members));

/* NFMstackerr.c */
extern long _NFMstack_error_from_buffer __CMDT((MEMptr list, char *catalog_name, char *item_name, char *item_rev, long operation, MEMptr list1));

/* NFMstools.c */
extern long NFMget_cat_fcat_no __CMDT((char *cat_name, long *cat_no, long *fcat_no, int type));

/* NFMtemplate.c */
extern long NFMquery_table_template __CMDT((long user_id, MEMptr *attr_list));
extern long NFMquery_template_definition __CMDT((char *table_type, char *table_name, char *identifier, MEMptr *attr_list));
extern long NFMquery_template_attributes __CMDT((char *table_type, char *table_name, char *identifier, MEMptr *attr_list, MEMptr *data_list, MEMptr *value_list));
extern long NFMquery_template_information __CMDT((char *table_type, char *table_name, char *identifier, MEMptr *attr_list, MEMptr *data_list, MEMptr *value_list));
extern long NFMcreate_template __CMDT((char *table_type, char *table_name, char *identifier, MEMptr attr_list, MEMptr data_list, MEMptr value_list));
extern long NFMdelete_template __CMDT((char *table_type, char *table_name, char *identifier));
extern long _NFMget_template_no __CMDT((char *table_type, char *table_name, char *identifier, long *table_no));
extern long NFMchange_template __CMDT((char *table_name, char *table_type, char *identifier, MEMptr attr_list, MEMptr data_list, MEMptr value_list));
extern long NFMi_template __CMDT((MEMptr *attr_list));
extern long _NFMchange_attributes_for_template __CMDT((char *table_type, char *table_name, char *identifier, MEMptr attr_list, MEMptr data_list, MEMptr value_list));
extern long NFMquery_change_template_information __CMDT((char *table_type, char *table_name, char *identifier, MEMptr *attr_list, MEMptr *data_list, MEMptr *value_list));
extern long NFMsplit_template_definition __CMDT((MEMptr attr_list, MEMptr *attr_list1, MEMptr *attr_list2, MEMptr *identifier_list));
extern long NFMsplit_template_attributes __CMDT((MEMptr attr_list, MEMptr data_list, MEMptr *attr_list1, MEMptr *data_list1, MEMptr *attr_list2, MEMptr *data_list2, MEMptr *identifier_list));

/* NFMvalidmem.c */
extern long NFMvalid_user_and_members_to_be __CMDT((long user_no, long members_to_define, struct NFMmember_info *members_info));

/* NFMver_tools.c */
extern long _NFMinsert_synonym __CMDT((MEMptr sql_buffer, char *column_name, char **data, char *read_flag, MEMptr *synonym_list));
extern long _NFMrename_NFMencrypted_to_ud __CMDT((long sano, long cat_no, long file_no, char *filename, MEMptr *move_buffer));
extern long _NFMrename_ud_to_NFMencrypted __CMDT((long sano, long cat_no, long file_no, char *filename, MEMptr *move_buffer));
extern long _NFMrename_NFMencrypted_to_NFMencrypted __CMDT((long sano, long cat_no, long from_file_no, long to_file_no, MEMptr *move_buffer));

/* NFMw_ris_par.c */
extern long NFMwrite_ris_parameters __CMDT((char *env_name, char *node_name));
extern int NFMreset_ris_env __CMDT((void));
extern int NFMget_ris_location __CMDT((char *loc));

/* NFMwr_query.c */
extern long NFMwrite_query_file __CMDT((char *report_name, int query_type, struct NFMquery_info query_info));
extern long NFMwrite_ftr_query_file __CMDT((char *report_name, int query_type, struct NFMquery_ftr_info query_info));

/* _NFMadd_node.c */
extern long _NFMadd_node __CMDT((long user_id, MEMptr attr_list, MEMptr data_list));

/* _NFMadd_sa.c */
extern long _NFMadd_storage_area __CMDT((long user_id, MEMptr attr_list, MEMptr data_list));
extern long _NFMadd_return_sa_name __CMDT((MEMptr attr_list, MEMptr data_list, char *saname));

/* _NFMcombine.c */
extern long _NFMget_catalog_no __CMDT((long user_id, char *catalog_name, char *catalog_num));
extern long _NFMget_catalog_name __CMDT((long user_id, char *catalog_num, char *catalog_name));
extern long _NFMget_item_no __CMDT((long user_id, char *cat_name, char *item_name, char *item_rev, char *item_num));
extern long _NFMget_item_name __CMDT((long user_id, char *cat_name, char *item_num, char *item_name, char *item_rev));
extern long _NFMget_node_no __CMDT((long user_id, char *node_name, char *node_num));
extern long _NFMget_node_name __CMDT((long user_id, char *node_num, char *node_name));
extern long _NFMget_sa_no __CMDT((long user_id, char *sa_name, char *sa_num));
extern long _NFMget_sa_name __CMDT((long user_id, char *sa_num, char *sa_name));
extern long _NFMget_acl_no __CMDT((long user_id, char *acl_name, char *acl_num));
extern long _NFMget_acl_name __CMDT((long user_id, char *acl_num, char *acl_name));
extern long _NFMget_class_no __CMDT((long user_id, char *wf_num, char *class_name, char *class_num));
extern long _NFMget_class_name __CMDT((long user_id, char *wf_num, char *class_num, char *class_name));
extern long _NFMget_user_no __CMDT((long user_id, char *user_name, char *user_num));
extern long _NFMget_user_name __CMDT((long user_id, char *user_num, char *user_name));
extern long _NFMget_workflow_no __CMDT((long user_id, char *workflow_name, char *workflow_num));
extern long _NFMget_workflow_name __CMDT((long user_id, char *workflow_num, char *workflow_name));

/* _NFMqry_proj.c */
extern long _NFMquery_project_members __CMDT((long user_id, char *project_name, MEMptr *attr_list, MEMptr *data_list));
extern long NFMqry_items_in_cat_for_project __CMDT((long user_id, char *project_name, char *catalog_name, MEMptr *data_list));
extern long NFMload_project_members __CMDT((long user_id, char *proj_name, char *p_name, long c_projoffset, long c_catoffset, long c_itemoffset, char *cit_str, MEMptr attr_list, MEMptr data_list));
extern long NFMprojectcit_attributes __CMDT((long user_id, long *projoffset, long *catoffset, long *itemoffset, char *p_no, char *cit_str, MEMptr *attr_list, MEMptr *data_list));
extern long NFMqry_proj_members __CMDT((long user_id, char *project_name, MEMptr *attr_list, MEMptr *data_list));
extern long _NFMprojectcit_buffer __CMDT((long user_id, MEMptr *attr_list, MEMptr *data_list));

/* flag.c */
/* ****duplicate declarations - not required - PS 
extern long NFMfl_flag_update_tree __CMDT((struct NFMflag_node_st *node, long level, char *flag));
extern int if __CMDT(((status =SQLquery (flag_s, &buffer, MEM_SIZE ))!=SQL_S_SUCCESS));
extern int if __CMDT((status ==SQL_S_SUCCESS));
extern int if __CMDT(((status =SQLquery (flag_s, &buffer, MEM_SIZE ))!=SQL_S_SUCCESS));
extern int if __CMDT(((status =MEMbuild_array (buffer ))!=MEM_S_SUCCESS));
extern int if __CMDT(((pendflag[1 ]==0 )&&((strcmp (node ->ctype, 0 ))==0 )));
extern else if __CMDT(((strcmp (node ->ctype, 0 )==0 )&&(tmpflag[1 ]==0 )));
extern int if __CMDT(((status =SQLstmt (flag_s ))!=SQL_S_SUCCESS));
extern int while __CMDT((node !=NULL));
extern }long NFMfl_flag_build_tree __CMDT((struct NFMflag_node_st *node, long level, int op_flag));
extern void NFMfl_flag_free_tree __CMDT((struct NFMflag_node_st *node));
extern long NFMfl_cancel_build_tree __CMDT((struct NFMflag_node_st *node, long level, int utility));
extern long NFMfl_cancel_update_tree __CMDT((struct NFMflag_node_st *node));
extern long NFMfl_cancel_update_tree_new __CMDT((struct NFMflag_node_st *node));
extern long NFMfl_cancel_build_tree_new __CMDT((struct NFMflag_node_st *node, long level));
*/

/* itemtools.c */
/* ****duplicate declarations - not required - PS 
extern long NFMset_item_status __CMDT((char *cat_name, char *item_name, char *item_rev, long item_no, char *file_status, int lock_flag, char *plus_str));
extern long NFMretrieve_values __CMDT((char *sql_str, long ret_type, char *ret_str, long *ret_value, MEMptr *ret_list));
extern long _NFMbuild_working_buffer_format __CMDT((struct NFMbuf_format *format, long count, MEMptr list));
extern long NFMcheck_catalog_attributes __CMDT((char *item_name, char *item_rev, MEMptr list, long command));
extern long NFMcommon_queries __CMDT((char *cat_name, char *w_clause, char *ret_string, long *ret_value, MEMptr *ret_list, long query_type, long return_type, long lock_flag));
extern long _NFMrollback_and_undo_buffer __CMDT((long command, long operand, MEMptr file_list, struct NFMlfm_file *lfm_list, MEMptr files_info, char *catalog_name, long catalog_no, long item_no, long wsano, long type));
*/
#undef __CMDT

#endif
