#ifndef NFMU_PROTO_H
#define NFMU_PROTO_H

#if defined(__STDC__) || defined(__cplusplus)
# define __NFMU(s) s
#else
# define __NFMU(s) ()
#endif

/*	Added for SCO port MSSP 21 Dec 1993 */
#if defined(OS_SCO_UNIX) || defined(OS_HPUX) 
#include "NFMapi.h"
#endif
/*	End of addition */

/* NFMadd_item.c */
extern long NFMadd_item __NFMU((long user_id, char *cat_name, MEMptr attr_list, MEMptr data_list));
extern long NFMadd_catalog_entry __NFMU((long user_id, char *cat_name, long *item_no, MEMptr attr_list, MEMptr data_list));
extern long NFMadd_file_catalog_entry __NFMU((long user_id, char *cat_name, long item_no, MEMptr attr_list, MEMptr data_list));
extern long _NFMdelete_cat_itemno __NFMU((char *cat_name, long item_no));

/* NFMadd_sa.c */
extern long NFMquery_add_st_area_attributes __NFMU((long user_id, MEMptr *attr_list, MEMptr *data_list, MEMptr *value_list));
extern long NFMadd_storage_area __NFMU((long user_id, MEMptr attr_list, MEMptr data_list));

/* NFMall_debug.c */
extern long NFMall_debug __NFMU((int toggles[NFM_DEBUG_SUBSYSTEMS ], char files[NFM_DEBUG_SUBSYSTEMS ][NFM_DEBUG_FILE_SIZE ]));

/* NFMcan_item.c */
extern long NFMcancel_item_archive_flag __NFMU((long user_id, char *catalog, char *item_name, char *item_rev));
extern long NFMcancel_item_backup_flag __NFMU((long user_id, char *catalog, char *item_name, char *item_rev));
extern long NFMcancel_item_restore_flag __NFMU((long user_id, char *catalog, char *item_name, char *item_rev));
extern long NFMcancel_item_delete_flag __NFMU((long user_id, char *catalog, char *item_name, char *item_rev));
extern long NFMcancel_item_flag __NFMU((char *catalog, char *item_name, char *item_rev));

/* NFMcan_proj.c */
extern long NFMcancel_project_archive_flag __NFMU((char *project));
extern long NFMcancel_project_backup_flag __NFMU((char *project));
extern long NFMcancel_project_restore_flag __NFMU((char *project));
extern int NFMcancel_project_flag __NFMU((MEMptr data_list));

/* NFMcan_set.c */
extern long NFMcancel_set_archive_flag __NFMU((long user_id, char *catalog, char *set_name, char *set_rev));
extern long NFMcancel_set_backup_flag __NFMU((long user_id, char *catalog, char *set_name, char *set_rev));
extern long NFMcancel_set_restore_flag __NFMU((long user_id, char *catalog, char *set_name, char *set_rev));
extern long NFMcancel_set_flag __NFMU((char *catalog, char *set_name, char *set_rev));
extern long NFMfl_check_set_flag __NFMU((char *catalog_no, char *set_name, char *set_rev, char *set_no, char *flag));

/* NFMcancoitem.c */
extern long NFMcancel_check_out_item __NFMU((char *catalog_name, long catalog_no, char *item_name, char *item_revision, struct NFMwf_info wf_info, struct NFMoperation operation));

/* NFMcancoset.c */
extern long NFMcancel_check_out_set __NFMU((char *catalog_name, long catalog_no, char *set_name, char *set_revision, long set_no, struct NFMwf_info wf_info, long member_operations, struct NFMoperation *operation, long level));

/* NFMcco_item.c */
extern long NFMcancel_co_item __NFMU((long user_id, MEMptr item_list));
extern long NFMprep_can_co_item __NFMU((long user_id, char *cat_name, char *item_name, char *item_rev, MEMptr *attr_list, MEMptr *data_list));
extern long NFMcomplete_can_co_item __NFMU((long user_id, MEMptr attr_list, MEMptr data_list));
extern long NFMupd_cancel_co_file __NFMU((long user_id, long i_row, long f_row, char *cat_name, long item_no, MEMptr attr_list, MEMptr data_list));

/* NFMcco_set.c */
extern long NFMcancel_co_set __NFMU((long user_id, MEMptr item_list));
extern long NFMprep_can_co_set __NFMU((long user_id, char *cat_name, char *item_name, char *item_rev, MEMptr *attr_list, MEMptr *data_list));
extern long NFMcomplete_can_co_set __NFMU((long user_id, MEMptr attr_list, MEMptr data_list));

/* NFMchg_pwd.c */
extern long NFMchange_working_area_passwd __NFMU((char *st_name, char *old_passwd, char *new_passwd));

/* NFMci_item.c */
extern long NFMprepare_item_checkin __NFMU((long user_id, char *cat_name, char *item_name, char *item_rev, MEMptr *attr_list, MEMptr *data_list));
extern long NFMcancel_item_checkin __NFMU((long user_id, MEMptr attr_list, MEMptr data_list));
extern long NFMcomplete_item_checkin __NFMU((long user_id, char *storage_name, char *node_name, char *user_name, char *passwd, char *path_name, MEMptr attr_list, MEMptr data_list));

/* NFMci_qtools.c */
extern long _NFMq_ci_attr __NFMU((long user_id, MEMptr *attr_list, MEMptr *data_list));
extern long _NFMtable_template __NFMU((MEMptr *attr_list));
extern long _NFMfill_rows __NFMU((MEMptr *attr_list));
extern long NFMg_item_ci_info __NFMU((long user_id, char *cat_name, MEMptr attr_list, MEMptr data_list));
extern long _NFMchk_in_user __NFMU((MEMptr attr_list, MEMptr data_list));

/* NFMci_satool.c */
extern long _NFMsa_info __NFMU((char *sa_name));
extern long _NFMsa_buffer __NFMU((MEMptr *list));
extern long _NFMsa_buffer_format __NFMU((MEMptr *list));
extern long _NFMadd_temp_sa __NFMU((long user_id, char *node_name, char *user_name, char *path_name, char *passwd));
extern void _NFMprint_STO_info __NFMU((void));

/* NFMci_set.c */
extern long NFMprepare_set_checkin __NFMU((long user_id, char *cat_name, char *item_name, char *item_rev, MEMptr *attr_list, MEMptr *data_list));
extern long NFMcancel_set_checkin __NFMU((long user_id, MEMptr attr_list, MEMptr data_list));
extern long NFMcomplete_set_checkin __NFMU((long user_id, char *storage_name, char *node_name, char *user_name, char *passwd, char *path_name, MEMptr attr_list, MEMptr data_list));

/* NFMci_tools.c */
extern long _NFMget_ci_files __NFMU((long user_id, long i_row, long f_row, MEMptr attr_list, MEMptr data_list, MEMptr file_list, long type));
extern long _NFMmake_fcat_entry __NFMU((char *cat_name, long item_no, long item_ver, long *file_no));
extern long _NFMupd_ci_cat_fcat __NFMU((long user_id, char *c_user, char *datetime, long sa_no, long i_row, long f_row, char *cat_name, long item_no, MEMptr attr_list, MEMptr data_list, MEMptr file_list));
extern long _NFMdel_fcat_fileno __NFMU((int rows, char *cat_name));
extern long _NFMpur_item_files __NFMU((long user_id, char *cat_name, long item_no));
extern long _NFMchk_item __NFMU((char *cat_name, char *item_name, int item_rev, int command));

/* NFMciitem.c */
extern long NFMcheckin_item __NFMU((char *catalog_name, long catalog_no, char *item_name, char *item_revision, char *working_area, struct NFMwf_info wf_info, struct NFMoperation operation));

/* NFMciset.c */
extern long NFMcheckin_set __NFMU((char *catalog_name, long catalog_no, char *set_name, char *set_revision, long set_no, char *working_area, struct NFMwf_info wf_info, long member_operations, struct NFMoperation *operation, long level));

/* NFMclient.c */
extern long NFMclient_info __NFMU((MEMptr item_list, long *admin_flag, long *query_rows, long *do_not_register));
extern long NFMget_server_info __NFMU((char *ret_date, char *ret_time, int *pid));

/* NFMco_item.c */
extern long NFMprepare_item_checkout __NFMU((long user_id, char *cat_name, char *item_name, char *item_rev, MEMptr *attr_list, MEMptr *data_list));
extern long NFMcancel_item_checkout __NFMU((long user_id, MEMptr attr_list, MEMptr data_list));
extern long NFMcomplete_item_checkout __NFMU((long user_id, char *storage_name, char *node_name, char *user_name, char *passwd, char *path_name, MEMptr attr_list, MEMptr data_list));

/* NFMco_qtools.c */
extern long _NFMq_co_attr __NFMU((long user_id, char *cat_name, MEMptr *attr_list, MEMptr *data_list));
extern long _NFMg_item_co_info __NFMU((long user_id, char *cat_name, MEMptr attr_list, MEMptr data_list));

/* NFMco_set.c */
extern long NFMprepare_set_checkout __NFMU((long user_id, char *cat_name, char *item_name, char *item_rev, long level, MEMptr *attr_list, MEMptr *data_list));
extern long NFMcancel_set_checkout __NFMU((long user_id, MEMptr attr_list, MEMptr data_list));
extern long NFMcomplete_set_checkout __NFMU((long user_id, char *storage_name, char *node_name, char *user_name, char *passwd, char *path_name, MEMptr attr_list, MEMptr data_list));

/* NFMco_tools.c */
extern long _NFMget_co_files __NFMU((long user_id, long i_row, long f_row, MEMptr attr_list, MEMptr data_list, MEMptr file_list, long type));
extern long _NFMupd_co_cat_fcat __NFMU((long user_id, char *c_user, char *datetime, long sa_no, long i_row, long f_row, char *level, char *cat_name, long item_no, MEMptr attr_list, MEMptr data_list, MEMptr file_list));

/* NFMcoitem.c */
extern long NFMcheckout_item __NFMU((char *catalog_name, long catalog_no, char *item_name, char *item_revision, char *working_area, struct NFMwf_info wf_info, struct NFMoperation operation));

/* NFMcoset.c */
extern long NFMcheckout_set __NFMU((char *catalog_name, long catalog_no, char *set_name, char *set_revision, long set_no, char *working_area, struct NFMwf_info wf_info, long member_operations, struct NFMoperation *operation, long level));

/* NFMcp_item.c */
extern long NFMprepare_item_copy __NFMU((long user_id, char *cat_name, char *item_name, char *item_rev, MEMptr *attr_list, MEMptr *data_list));
extern long NFMcancel_item_copy __NFMU((long user_id, MEMptr attr_list, MEMptr data_list));
extern long NFMcomplete_item_copy __NFMU((long user_id, char *storage_name, char *node_name, char *user_name, char *passwd, char *path_name, MEMptr attr_list, MEMptr data_list));
extern long _NFMs_temp_flag __NFMU((char *cat_name, char *temp_state, int lock_flag));

/* NFMcp_item_n.c */
extern long NFMcopy_item_n __NFMU((char *cat_name, MEMptr attr_cat, MEMptr data_cat, MEMptr attr_f_cat, MEMptr data_f_cat));
extern long _NFMadd_catalog_entry __NFMU((char *cat_name, long *item_no, long *original_item_no, MEMptr attr_list, MEMptr data_list, long stateno, long *move_files));
extern long _NFMadd_file_catalog_entry_and_copy __NFMU((char *cat_name, long cat_no, long item_no, long original_item_no, MEMptr attr_list, MEMptr data_list));
extern long _NFMadd_file_catalog_entry __NFMU((char *cat_name, long item_no, MEMptr data_list));
extern long _NFMundo_copied_files __NFMU((MEMptr data_list, long incl_last, long cisano_pos, long cifilename_pos, char *catalog_name, long cat_no, long item_no));

/* NFMcp_set.c */
extern long NFMprepare_set_copy __NFMU((long user_id, char *cat_name, char *item_name, char *item_rev, long level, MEMptr *attr_list, MEMptr *data_list));
extern long NFMcancel_set_copy __NFMU((long user_id, MEMptr attr_list, MEMptr data_list));
extern long NFMcomplete_set_copy __NFMU((long user_id, char *storage_name, char *node_name, char *user_name, char *passwd, char *path_name, MEMptr attr_list, MEMptr data_list));

/* NFMcpitmfile.c */
extern long NFMcopy_item_files __NFMU((char *catalog_name, long catalog_no, char *item_name, char *item_revision, char *working_area, struct NFMwf_info wf_info, struct NFMoperation operation));

/* NFMcpsetfile.c */
extern long NFMcopy_set_files __NFMU((char *catalog_name, long catalog_no, char *set_name, char *set_revision, long set_no, char *working_area, struct NFMwf_info wf_info, long member_operations, struct NFMoperation *operation, long level));

/* NFMdef_query.c */
extern long NFMdefine_query __NFMU((char *query_name, char *query_desc, int query_type, char *application, char *user_name, struct NFMquery_info query_info));

/* NFMdeffile.c */
extern long NFMdefine_file_information __NFMU((char *catalog_name, char *item_name, char *item_revision, long operation, MEMptr data_list));
extern long NFMadd_files_to_item __NFMU((char *cat_name, long item_no, char *file_status, MEMptr data_list));
extern long NFMdelete_files_from_item __NFMU((char *cat_name, long item_no, char *file_status, MEMptr data_list));
extern long NFMchange_files_information __NFMU((char *cat_name, long item_no, char *file_status, MEMptr data_list));

/* NFMdefmember.c */
extern long NFMdefine_set_information __NFMU((char *catalog_name, long catalog_no, char *set_name, char *set_revision, long file_status_check, long members_to_define, struct NFMmember_info *members_info));
extern long _NFMprint_members_info __NFMU((struct NFMmember_info *members_info, long num_members));

/* NFMdel_dev.c */
extern long NFMdelete_storage_area __NFMU((long user_id, char *storage_name));
extern long NFMcheck_files_sa __NFMU((long user_id, long sa_no));
extern long NFMcheck_sa_in_catalog_map __NFMU((long user_id, long sa_no));

/* NFMdel_item.c */
extern long NFMdelete_item __NFMU((long user_id, char *cat_name, char *item_name, char *item_rev, long *item_no));
extern long _NFMcheck_item_condition_delete_item __NFMU((char *catalog_name, char *item_name, char *item_rev, long cat_no, long item_no, long *delete_saveset_flag, char *file_status));

/* NFMdel_query.c */
extern long NFMdelete_query __NFMU((char *query_name));

/* NFMdel_user.c */
extern long NFMdelete_user __NFMU((long user_id, char *user_name));
extern long NFMcheck_user_in_sa __NFMU((long user_id, long user_no));
extern long NFMcheck_user_in_acls __NFMU((long user_id, long user_no));
extern long NFMcheck_user_in_signoff __NFMU((long user_id, long user_no));
extern long NFMcheck_user_in_project __NFMU((long user_id, char *user_name));

/* NFMdelcpfile.c */
extern long NFMdelete_copied_files __NFMU((char *working_area, MEMptr data_list));

/* NFMfl_tools.c */
extern long NFMfl_get_catalog_name __NFMU((char *catalog_no, char *catalog_name));
extern long NFMfl_get_catalog_no __NFMU((char *catalog, char *catalog_no));
extern long NFMfl_get_item_no __NFMU((char *catalog, char *item_name, char *item_rev, char *item_no));
extern long NFMfl_get_item_name __NFMU((char *catalog_no, char *item_no, char *item_name, char *item_rev));
extern long NFMfl_validate_item_restore __NFMU((char *catalog_no, char *item_no, char *file_no));
extern long NFMfl_validate_set_restore __NFMU((char *catalog_no, char *item_no));
extern long NFMfl_get_max_version __NFMU((char *catalog, int itemno, int *version));
extern int NFMfl_check_for_file __NFMU((char *catalog_no, char *item_no));

/* NFMflag_item.c */
extern long NFMflag_item_archive __NFMU((long user_id, char *catalog, char *item_name, char *item_rev));
extern long NFMflag_item_backup __NFMU((long user_id, char *catalog, char *item_name, char *item_rev));
extern long NFMflag_item_restore __NFMU((long user_id, char *catalog, char *item_name, char *item_rev));
extern long NFMflag_item_delete __NFMU((long user_id, char *catalog, char *item_name, char *item_rev));
extern long NFMfl_flag_validate_item __NFMU((char *catalog, char *item_no, char *item_name, int op_flag));
extern long NFMalpha_flag_item_restore __NFMU((long user_id, char *catalog, char *item_name, char *item_rev, char *item_ver));

/* NFMflag_proj.c */
extern long NFMflag_project_archive __NFMU((long user_id, char *project_name));
extern long NFMflag_project_backup __NFMU((long user_id, char *project_name));
extern long NFMflag_project_restore __NFMU((long user_id, char *project_name));
extern int NFMvalidate_project_flagging __NFMU((char *flag, MEMptr data_list));
extern int NFMflag_project __NFMU((char *flag, MEMptr data_list));
extern int NFMvalidate_project_member __NFMU((char *flag, char *type, char *catalog, char *item, char *rev));
extern int NFMflag_project_member __NFMU((char *flag, char *type, char *catalog, char *item, char *rev));

/* NFMflag_set.c */
extern long NFMflag_set_archive __NFMU((long user_id, char *catalog, char *set_name, char *set_rev));
extern long NFMflag_set_backup __NFMU((long user_id, char *catalog, char *set_name, char *set_rev));
extern long NFMflag_set_restore __NFMU((long user_id, char *catalog, char *set_name, char *set_rev));
extern long NFMfl_flag_validate_set __NFMU((char *catalog, char *set_no, char *ctype, int op_flag));
extern long NFMfl_flag_get_set_members __NFMU((char *catalog_no, char *set_no, long level, MEMptr *buffer));
extern int NFMfl_update_nfmsetcit __NFMU((char *catalog_no, char *set_no, char *flag));
extern long NFMfl_flag_validate_set_item __NFMU((char *catalog, char *item_no, int op_flag));

/* NFMgetfile.c */
extern long NFMget_file_information __NFMU((char *catalog_name, char *item_name, char *item_revision, long operation, MEMptr *attr_list, MEMptr *data_list, MEMptr *value_list));

/* NFMitem_lock.c */
extern long NFMlock_item __NFMU((long user_id, char *cat_name, char *item_name, char *item_rev));
extern long NFMunlock_item __NFMU((long user_id, char *cat_name, char *item_name, char *item_rev));
extern long _NFMcheck_condition_for_lock __NFMU((char *catalog_name, char *item_name, char *item_rev));

/* NFMiteminfo1.c */
extern long NFMget_item_data_def_and_values1 __NFMU((long table_no, long ftable_no, char *cat_name, char *item_name, char *item_rev, struct set_info1 **new_set_info));
extern long NFMget_items_data_def_values1 __NFMU((long cur_cat_no, long cur_fcat_no, char *cur_cat_name, long *item_no_list, long item_num, struct set_info1 **head_set, struct set_info1 **end_set));
extern long NFMprint_linked_list1 __NFMU((void));
extern long NFMprint_an_entry_of_linked_list1 __NFMU((struct set_info1 *set));

/* NFMlogin.c */
extern long NFMlog_in __NFMU((char *user_name, char *passwd, char *environment, char *application));
extern long NFMget_schema_info __NFMU((char *node_name, char *schema_name));
extern long NFMget_db_info __NFMU((char *schema_name));
extern long NFMfix_queries __NFMU((void));
extern long NFMlogoff __NFMU((void));
extern long NFMglobal_ris_data __NFMU((char *schema_name, char *dbtype));
extern long NFMlogin __NFMU((MEMptr attr_list, MEMptr data_list, MEMptr wf_list, long *us_id));
extern long NFMquery_login_attributes __NFMU((char *app_id, char *env_type, MEMptr *attr_list, MEMptr *data_list, MEMptr *value_list, MEMptr *wf_list));
extern long NFMlogout __NFMU((long user_id));
extern long NFMget_syscat_configuration __NFMU((void));
extern long NFMcheck_version __NFMU((void));
extern long NFMset_client_info __NFMU((void));
extern long _NFMcheck_vault_version_number __NFMU((void));

/* NFMmaint.c */
extern long NFMquery_savesets_to_delete __NFMU((MEMptr *syn_list, MEMptr *data_list));
extern long NFMdelete_savesets __NFMU((MEMptr data_list));
extern long NFMquery_archives_to_delete __NFMU((MEMptr *syn_list, MEMptr *data_list));
extern long NFMdelete_archives __NFMU((MEMptr data_list));

/* NFMmake_tran.c */
extern long NFMquery_make_transition __NFMU((long user_id, MEMptr *attr_list, MEMptr *data_list));
extern long NFMmake_transition __NFMU((long user_id, MEMptr attr_list, MEMptr data_list));

/* NFMn_usrdef.c */
extern long NFMuser_defaults_login __NFMU((long user_id, MEMptr *data_list));
extern int NFMk_query_three_attr __NFMU((char *table_no, char *nfm1, char *nfm2, char *nfm3, char *attr1, char *attr2, char *attr3));

/* NFMnew_tools.c */
extern long _NFMquery_data_defn1 __NFMU((long tabno, char *itemno, char *dtype1, char *itemname, char *dtype2, char *itemrev, char *dtype3));
extern long _NFMget_cat_fcat_no __NFMU((char *cat_name));
extern long _NFMprepare_item_info __NFMU((char *item_name, char *item_rev));
extern long _NFMprepare_item_values __NFMU((char *cat_name, char *item_name, char *item_rev));
extern long _NFMg_fileversion __NFMU((char *cat_name));

/* NFMplot_item.c */
extern long NFMplot_item __NFMU((char *catalog_name, char *item_name, char *item_rev));

/* NFMplot_set.c */
extern long NFMplot_set __NFMU((char *catalog_name, char *set_name, char *set_rev));

/* NFMpost_lg.c */
extern long NFMadd_default_working_area __NFMU((char *nodename, char *username, char *pathname, char *saname, MEMptr node_info, MEMptr sa_info));
extern long _NFMadd_default_sa __NFMU((long *sano, char *nodename, char *username, char *path, char *saname, long nodeno, MEMptr sano_info));
extern long _NFMadd_default_node __NFMU((long *nodeno, char *nodename, MEMptr node_info));

/* NFMprint_gp.c */
extern int _NFMprint_global_item_ptr __NFMU((void));

/* NFMqa_item.c */
extern long NFMquery_add_item_attributes __NFMU((long user_id, char *cat_name, MEMptr *attr_list, MEMptr *data_list, MEMptr *value_list));
extern long NFMquery_add_set_attributes __NFMU((long user_id, char *cat_name, MEMptr *attr_list, MEMptr *data_list, MEMptr *value_list));

/* NFMqa_item_n.c */
extern long NFMget_item_attr_for_copy __NFMU((char *cat_name, char *itemname, char *itemrev, MEMptr *attr_cat, MEMptr *data_cat, MEMptr *value_cat, MEMptr *attr_f_cat, MEMptr *data_f_cat, MEMptr *value_f_cat));
extern long _NFMquery_catalog_attributes_for_copy __NFMU((char *catalog_name, MEMptr *attr1_list, MEMptr *data1_list, MEMptr *value1_list, MEMptr *attr2_list, MEMptr *data2_list, MEMptr *value2_list));
extern long _NFMget_tables_attr_for_copy __NFMU((char *catalog_name, MEMptr *list, MEMptr *f_list));
extern long _NFMbuild_row_string __NFMU((char *str, MEMptr attr_list, char **column, char *n_name, char *n_synonym, char *n_datatype));

/* NFMqry_can.c */
extern long NFMquery_cancel_archive __NFMU((long user_id, char *catalog, MEMptr *files));
extern long NFMquery_cancel_backup __NFMU((long user_id, char *catalog, MEMptr *files));
extern long NFMquery_cancel_restore __NFMU((long user_id, char *catalog, MEMptr *files));
extern long NFMquery_cancel_delete __NFMU((long user_id, char *catalog, MEMptr *files));

/* NFMqry_flag.c */
extern long NFMquery_flag_archive __NFMU((long user_id, char *catalog, MEMptr *files));
extern long NFMquery_flag_backup __NFMU((long user_id, char *catalog, MEMptr *files));
extern long NFMquery_flag_restore __NFMU((long user_id, char *catalog, MEMptr *files));
extern long NFMnew_query_flag_restore __NFMU((char *catalog, char *item, char *rev, MEMptr *files));
extern long NFMquery_flag_delete __NFMU((long user_id, char *catalog, MEMptr *files));

/* NFMqry_set.c */
extern long NFMquery_set_members __NFMU((long user_id, char *cat_name, char *item_name, char *item_rev, long level, long type, MEMptr *attr_list, MEMptr *data_list));
extern long NFMload_set_members __NFMU((long user_id, char *p_catno, char *p_itemno, char *p_type, char *c_catno, long c_catoffset, long c_itemoffset, long c_typeoffset, char *cit_str, long max_level, long curr_level, long type, long cat_no, long item_no, MEMptr attr_list, MEMptr data_list));
extern long NFMset_attributes __NFMU((long user_id, char *p_catno, char *p_itemno, char *p_type, char *c_catno, long *c_catoffset, long *c_itemoffset, long *c_typeoffset, char *cit_str, MEMptr *attr_list, MEMptr *data_list));
extern long NFMqry_set_members __NFMU((long user_id, char *cat_name, char *item_name, char *item_rev, MEMptr *attr_list, MEMptr *data_list));
extern long _NFMset_buffer __NFMU((long user_id, MEMptr *attr_list, MEMptr *data_list));
extern long _NFMload_set_mem_short __NFMU((long user_id, long p_catno, long p_itemno, MEMptr attr_list, MEMptr data_list));

/* NFMresetinfo.c */
extern long NFMreset_file_information __NFMU((char *catalog_name, char *item_name, char *item_revision));

/* NFMret_query.c */
extern long NFMretrieve_query __NFMU((char *query_name, struct NFMquery_info *query_info));
extern long NFMretrieve_query_info __NFMU((char *query_name, char *query_type, char *application, char *appl_type, char *query_desc, char *owner, struct NFMquery_info *query_info));

/* NFMsave_item.c */
extern long NFMsave_item_files __NFMU((char *catalog_name, char *item_name, char *item_revision));

/* NFMsave_set.c */
extern long NFMsave_set_files __NFMU((char *catalog_name, char *set_name, char *set_revision));

/* NFMset.c */
extern long NFMprocess_selected_set_members __NFMU((char *catalog_name, long catalog_no, char *set_name, char *set_revision, long set_no, char *working_area, struct NFMwf_info wf_info, int member_operations, struct NFMoperation *operation, long level, long command));

/* NFMset_func.c */
extern long NFMget_children_info __NFMU((void));
extern long NFMget_ci_set_files __NFMU((long user_id, MEMptr attr_list, MEMptr data_list, MEMptr file_list));
extern long NFMupd_ci_set_cat_fcat __NFMU((long user_id, char *c_user, char *c_datetime, long sa_no, MEMptr attr_list, MEMptr data_list, MEMptr file_list));
extern long NFMpurge_ci_set_item_files __NFMU((long user_id));

/* NFMset_mem.c */
extern long NFMget_set_members __NFMU((long cat_no, long *item_no_list, long num_item, long level));
extern long NFMsort_linked_list __NFMU((struct child_info *sorting_list));
extern long NFMfree_linked_list __NFMU((void));

/* NFMsetfunc1.c */
extern long NFMget_data_def1 __NFMU((long table_no, long ftable_no, MEMptr *attr_list, MEMptr *data_list));
extern long NFMget_set_ci_files_info1 __NFMU((struct set_info1 *head, int quantity, MEMptr attr_list, MEMptr data_list));
extern long NFMcheck_and_update_items_status1 __NFMU((struct set_info1 *head_set, int quantity, int type));
extern long NFMget_co_set_files __NFMU((long user_id, MEMptr attr_list, MEMptr data_list, MEMptr file_list));
extern long NFMupd_co_set_cat_fcat __NFMU((long user_id, char *c_user, char *c_datetime, long sa_no, MEMptr attr_list, MEMptr data_list, MEMptr file_list));
extern long NFMset_colevel __NFMU((char *cat_name, long *item_no, char *level, MEMptr attr_list));

/* NFMsetgflag.c */
extern long NFMset_load_item_files __NFMU((long flag));

/* NFMsetrol_bk.c */
extern long _NFMrollback_set __NFMU((void));
extern long _NFMrollback_fcat_records __NFMU((void));

/* NFMsignoff.c */
extern long NFMpurge_signoff __NFMU((long user_id, char *catalog, char *item, char *revision));
extern long NFMquery_signoff_attributes __NFMU((long user_id, MEMptr *attr_list, MEMptr *data_list, MEMptr *value_list));
extern long NFMsignoff __NFMU((long user_id, MEMptr attr_list, MEMptr data_list));

/* NFMto_state.c */
extern long NFMset_wf_state __NFMU((char *app_name, long error_no, char *error_msg));

/* NFMupd_item.c */
extern long NFMprepare_update_item __NFMU((long user_id, char *cat_name, char *item_name, char *item_rev, MEMptr *attr_list, MEMptr *data_list, MEMptr *value_list));
extern long NFMcancel_update_item __NFMU((long user_id, MEMptr attr_list, MEMptr data_list));
extern long NFMupdate_item __NFMU((long user_id, char *cat_name, MEMptr attr_list, MEMptr data_list));
extern long NFMupdate_catalog_entry __NFMU((long user_id, char *cat_name, MEMptr attr_list, MEMptr data_list));
extern long NFMupdate_file_catalog_entry __NFMU((long user_id, char *cat_name, MEMptr attr_list, MEMptr data_list, char *coout, long item_no));
extern long NFMcheck_sa_mappings __NFMU((long user_id, long cat_no, long item_no, long sa_no));
extern long _NFMcheck_item_condition_update_item __NFMU((char *catalog_name, char *item_name, char *item_rev, char *file_status, char *archive_flag, long *archiveno, char *fileco));
extern long _NFMrollback_file_operation __NFMU((char *cat_name, MEMptr attr_list, MEMptr data_list, char *coout, long ci_last));

/* NFMupd_mem.c */
extern long NFMupdate_set_members __NFMU((long user_id, MEMptr attr_list, MEMptr data_list));
extern long NFMdrop_set_member __NFMU((long user_id, MEMptr cit_attr, MEMptr data_list, long cat_no, long item_no, long p_co_status, long row_no));
extern long NFMadd_set_member __NFMU((long user_id, MEMptr cit_attr, MEMptr data_list, long cat_no, long item_no, long p_co_status, long row_no));
extern long NFMcheck_set_loop __NFMU((long user_id, MEMptr cit_attr, long p_cat_no, long p_item_no, long c_cat_no, long c_item_no, long pc_off, long pi_off, long cc_off, long ci_off));
extern long NFMcheck_parent_loop __NFMU((long user_id, MEMptr cit_attr, MEMptr par_list, long cat_no, long item_no, long pc_off, long pi_off, long cc_off, long ci_off));
extern long NFMreset_co_out_deleted_member __NFMU((long user_id, char *cat_name, long item_no, long level, long set_status, long co_status));
extern long NFMget_parent_checkout_level __NFMU((long user_id, long cat_no, long item_no, long *level, char *sel_str, char *c_catno, char *c_itemno, char *c_type));
extern long NFMupd_set_mem_co __NFMU((long user_id, MEMptr attr_list, MEMptr data_list));

/* NFMuser_def.c */
extern long NFMuser_defaults_login_old __NFMU((long user_id, MEMptr *data_list));
extern long NFMuser_defaults_logout __NFMU((long user_id, MEMptr data_list));
extern int NFMj_query_name_or_num __NFMU((char *table_name, char *attr1, char *attr2, char *val2, char *val1, int flag));
extern int NFMj_query_one_AND __NFMU((char *table_name, char *attr1, char *attr2, char *attr3, char *val2, char *val3, char *val1));
extern int NFMj_query_two __NFMU((char *table_name, char *attr1, char *attr2, char *attr3, char *val3, char *val1, char *val2, int flag));
extern long NFMread_user_defaults __NFMU((MEMptr *data_list));
extern long NFMread_defaults_file __NFMU((char *def_file, MEMptr *data_list));
extern long NFMwrite_user_defaults __NFMU((MEMptr data_list));
extern long NFMwrite_defaults_file __NFMU((char *def_file, MEMptr data_list));

/* NFMusr_del.c */
extern long NFM_delete_item __NFMU((long user_id, char *cat_name, char *item_name, char *item_rev));

/* NFMval_info.c */
extern int NFMvalidate_project __NFMU((char *project_name));
extern int NFMvalidate_catalog __NFMU((char *catalog_name));
extern int NFMvalidate_item __NFMU((char *catalog_name, char *item_name));
extern int NFMvalidate_revision __NFMU((char *catalog_name, char *item_name, char *item_revision, int *flag));
extern int NFMvalidate_search __NFMU((char *search_name, char *owner));
extern int NFMvalidate_sort __NFMU((char *sort_name, char *owner));
extern int NFMvalidate_st_area __NFMU((char *st_area_name));
extern int NFMvalidate_working_area __NFMU((char *working_area_name, char *owner));
extern int NFMvalidate_node __NFMU((char *node_name));
extern int NFMvalidate_set_item __NFMU((char *set_cat_name, char *set_item_name));
extern int NFMvalidate_set_rev __NFMU((char *set_cat_name, char *set_item_name, char *set_item_rev));
extern int NFMvalidate_workflow __NFMU((char *workflow_name));
extern int NFMvalidate_acl __NFMU((char *wf_name, char *acl_name));
extern int NFMvalidate_user __NFMU((char *user_name));
extern int NFMval_map_name __NFMU((char *catalog, char *nfm_name, char *attr_name));

/* NFMvalid.c */
extern long NFMvalidate_user_access __NFMU((long user_id, char *command, char *workflow, char *project, char *catalog, char *item, char *revision));

#undef __NFMU

#endif
