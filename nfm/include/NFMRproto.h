#ifndef NFMR_PROTO_H
#define NFMR_PROTO_H

#if defined(__STDC__) || defined(__cplusplus)
# define __NFMR(s) s
#else
# define __NFMR(s) ()
#endif


/* NFMRacl_t.c */
extern long NFMRget_acl_no __NFMR((long user_id, char *acl_name, char *acl_num));
extern long NFMRget_acl_name __NFMR((long user_id, char *acl_num, char *acl_name));

/* NFMRadd_acl.c */
extern long NFMRquery_acl_attributes __NFMR((long user_id, MEMptr *attr_list, MEMptr *data_list, MEMptr *value_list));
extern long NFMRadd_acl __NFMR((long user_id, MEMptr attr_list, MEMptr data_list));

/* NFMRadd_d_wa.c */
extern long NFMRadd_default_working_area __NFMR((char *node, char *user, char *path, char *wa, MEMptr node_info, MEMptr sa_info));

/* NFMRadd_item.c */
extern long NFMRadd_item __NFMR((long user_id, char *catalog_name, MEMptr attr_list, MEMptr data_list));

/* NFMRadd_node.c */
extern long NFMRadd_node __NFMR((long user_id, MEMptr attr_list, MEMptr data_list));
extern long NFMRquery_add_node_attributes __NFMR((long user_id, MEMptr *attr_list, MEMptr *data_list, MEMptr *value_list));

/* NFMRadd_proj.c */
extern long NFMRquery_addto_lop_attributes __NFMR((long user_id, char *lop_name, MEMptr *attr_list, MEMptr *data_list, MEMptr *value_list));
extern long NFMRadd_project __NFMR((long user_id, MEMptr attr_list, MEMptr data_list));

/* NFMRadd_sa.c */
extern long NFMRadd_storage_area __NFMR((long user_id, MEMptr attr_list, MEMptr data_list));
extern long NFMRadd_return_sa_name __NFMR((MEMptr attr_list, MEMptr data_list, char *saname));
extern long NFMRquery_add_st_area_attributes __NFMR((long user_id, MEMptr *attr_list, MEMptr *data_list, MEMptr *value_list));

/* NFMRadd_user.c */
extern long NFMRadd_user __NFMR((long user_id, MEMptr attr_list, MEMptr data_list));
extern long NFMRquery_add_user_attributes __NFMR((long user_id, MEMptr *attr_list, MEMptr *data_list, MEMptr *value_list));

/* NFMRcan_iflg.c */
extern long NFMRcancel_item_archive_flag __NFMR((long user_id, char *catalog_name, char *item_name, char *item_rev));
extern long NFMRcancel_item_backup_flag __NFMR((long user_id, char *catalog_name, char *item_name, char *item_rev));
extern long NFMRcancel_item_delete_flag __NFMR((long user_id, char *catalog_name, char *item_name, char *item_rev));
extern long NFMRcancel_item_restore_flag __NFMR((long user_id, char *catalog_name, char *item_name, char *item_rev));

/* NFMRcan_item.c */
extern long NFMRcancel_check_out_item __NFMR((char *catalog_name, long catalog_no, char *item_name, char *item_revision, struct NFMwf_info wf_info, struct NFMoperation operation));
extern long NFMRcancel_co_item __NFMR((long user_id, char *catalog_name, char *item_name, char *item_rev));

/* NFMRcan_pflg.c */
extern long NFMRcancel_project_archive_flag __NFMR((char *project));
extern long NFMRcancel_project_backup_flag __NFMR((char *project));
extern long NFMRcancel_project_restore_flag __NFMR((char *project));

/* NFMRcan_set.c */
extern long NFMRcancel_co_set __NFMR((long user_id, char *catalog_name, char *set_name, char *set_rev));
extern long NFMRcancel_check_out_set __NFMR((char *catalog_name, long catalog_no, char *set_name, char *set_revision, long set_no, struct NFMwf_info wf_info, long member_operations, struct NFMoperation *operation, long level));

/* NFMRcan_sflg.c */
extern long NFMRcancel_set_archive_flag __NFMR((long user_id, char *catalog_name, char *set_name, char *set_rev));
extern long NFMRcancel_set_backup_flag __NFMR((long user_id, char *catalog_name, char *set_name, char *set_rev));
extern long NFMRcancel_set_restore_flag __NFMR((long user_id, char *catalog_name, char *set_name, char *set_rev));

/* NFMRcat_map.c */
extern long NFMRquery_catalog_acl_map __NFMR((long user_id, char *catalog_name, MEMptr *attr_list, MEMptr *data_list, MEMptr *value_list));
extern long NFMRupdate_catalog_acl_map __NFMR((long user_id, MEMptr attr_list, MEMptr data_list));
extern long NFMRquery_catalog_sa_map __NFMR((long user_id, char *catalog_name, MEMptr *attr_list, MEMptr *data_list, MEMptr *value_list));
extern long NFMRupdate_catalog_sa_map __NFMR((long user_id, MEMptr attr_list, MEMptr data_list));

/* NFMRcat_t.c */
extern long NFMRget_catalog_no __NFMR((long user_id, char *catalog_name, char *catalog_num));
extern long NFMRget_catalog_name __NFMR((long user_id, char *catalog_num, char *catalog_name));

/* NFMRchg_cat.c */
extern long NFMRchange_catalog __NFMR((long user_id, MEMptr loc_attr, MEMptr loc_data, MEMptr attr_list, MEMptr data_list, MEMptr value_list));

/* NFMRchg_node.c */
extern long NFMRquery_change_node_attributes __NFMR((long user_id, char *node_name, MEMptr *attr_list, MEMptr *data_list, MEMptr *value_list));
extern long NFMRchange_node __NFMR((long user_id, MEMptr attr_list, MEMptr data_list));

/* NFMRchg_proj.c */
extern long NFMRquery_changeto_lop_attributes __NFMR((long user_id, char *project_name, MEMptr *attr_list, MEMptr *data_list, MEMptr *value_list));
extern long NFMRchange_project __NFMR((long user_id, MEMptr attr_list, MEMptr data_list));

/* NFMRchg_pwd.c */
extern long NFMRchange_storage_area_passwd __NFMR((long user_id, char *storage_name, char *old_passwd, char *new_passwd));
extern long NFMRchange_user_passwd __NFMR((long user_id, char *user_name, char *old_passwd, char *new_passwd));
extern long NFMRchange_working_area_passwd __NFMR((char *st_name, char *old_passwd, char *new_passwd));

/* NFMRchg_sa.c */
extern long NFMRquery_change_sa_attributes __NFMR((long user_id, char *sa_name, MEMptr *attr_list, MEMptr *data_list, MEMptr *value_list));
extern long NFMRchange_sa __NFMR((long user_id, MEMptr attr_list, MEMptr data_list));

/* NFMRchg_tab.c */
extern long NFMRchange_table __NFMR((long user_id, char *table_type, char *table_name, MEMptr attr_list, MEMptr data_list, MEMptr value_list));

/* NFMRchg_tmp.c */
extern long NFMRchange_template __NFMR((long user_id, char *table_name, char *table_type, MEMptr attr_list, MEMptr data_list, MEMptr value_list));

/* NFMRchg_user.c */
extern long NFMRquery_change_user_attributes __NFMR((long user_id, char *user_name, MEMptr *attr_list, MEMptr *data_list, MEMptr *value_list));
extern long NFMRchange_user __NFMR((long user_id, MEMptr attr_list, MEMptr data_list));

/* NFMRci_item.c */
extern long NFMRprepare_item_checkin __NFMR((long user_id, char *catalog_name, char *item_name, char *item_rev, MEMptr *attr_list, MEMptr *data_list));
extern long NFMRcancel_item_checkin __NFMR((long user_id, MEMptr attr_list, MEMptr data_list));
extern long NFMRcomplete_item_checkin __NFMR((long user_id, char *storage_name, char *tmp_node, char *tmp_user, char *tmp_passwd, char *tmp_path, MEMptr attr_list, MEMptr data_list));

/* NFMRci_set.c */
extern long NFMRprepare_set_checkin __NFMR((long user_id, char *catalog_name, char *set_name, char *set_rev, MEMptr *attr_list, MEMptr *data_list));
extern long NFMRcancel_set_checkin __NFMR((long user_id, MEMptr attr_list, MEMptr data_list));
extern long NFMRcomplete_set_checkin __NFMR((long user_id, char *storage_name, char *tmp_node, char *tmp_user, char *tmp_passwd, char *tmp_path, MEMptr attr_list, MEMptr data_list));

/* NFMRclass_t.c */
extern long NFMRget_class_no __NFMR((long user_id, char *wf_num, char *class_name, char *class_num));
extern long NFMRget_class_name __NFMR((long user_id, char *wf_num, char *class_num, char *class_name));

/* NFMRclient.c */
extern long NFMRget_host_info __NFMR((long user_id, int logon));
extern int NFMRclient_info __NFMR((long user_id, char *ret_date, char *ret_time, char *nodename, char *unix_user, int pid, char *pathname, int connect_on));

/* NFMRcmd_t.c */
extern long NFMRget_command_no __NFMR((long user_id, char *command_name, char *command_num));
extern long NFMRget_command_name __NFMR((long user_id, char *command_num, char *command_name));

/* NFMRco_item.c */
extern long NFMRprepare_item_checkout __NFMR((long user_id, char *catalog_name, char *item_name, char *item_rev, MEMptr *attr_list, MEMptr *data_list));
extern long NFMRcancel_item_checkout __NFMR((long user_id, MEMptr attr_list, MEMptr data_list));
extern long NFMRcomplete_item_checkout __NFMR((long user_id, char *storage_name, char *tmp_node, char *tmp_user, char *tmp_passwd, char *tmp_path, MEMptr attr_list, MEMptr data_list));

/* NFMRco_set.c */
extern long NFMRprepare_set_checkout __NFMR((long user_id, char *catalog_name, char *set_name, char *set_rev, long level, MEMptr *attr_list, MEMptr *data_list));
extern long NFMRcancel_set_checkout __NFMR((long user_id, MEMptr attr_list, MEMptr data_list));
extern long NFMRcomplete_set_checkout __NFMR((long user_id, char *storage_name, char *tmp_node, char *tmp_user, char *tmp_passwd, char *tmp_path, MEMptr attr_list, MEMptr data_list));

/* NFMRconnect.c */
extern long NFMRconnect __NFMR((char *node));

/* NFMRcopy_acl.c */
extern long NFMRquery_acl_attributes_condition __NFMR((char *condition, MEMptr *attr_list, MEMptr *data_list, MEMptr *value_list));
extern long NFMRget_acl_classes_for_copy __NFMR((char *old_aclname, long new_wfno, MEMptr *attr_list, MEMptr *value_list));
extern long NFMRcopy_acl_users __NFMR((char *new_aclname, long new_wfno, char *old_aclname, MEMptr data_list));

/* NFMRcp_item.c */
extern long NFMRprepare_item_copy __NFMR((long user_id, char *catalog_name, char *item_name, char *item_rev, MEMptr *attr_list, MEMptr *data_list));
extern long NFMRcancel_item_copy __NFMR((long user_id, MEMptr attr_list, MEMptr data_list));
extern long NFMRcomplete_item_copy __NFMR((long user_id, char *storage_name, char *tmp_node, char *tmp_user, char *tmp_passwd, char *tmp_path, MEMptr attr_list, MEMptr data_list));

/* NFMRcp_set.c */
extern long NFMRprepare_set_copy __NFMR((long user_id, char *catalog_name, char *set_name, char *set_rev, long level, MEMptr *attr_list, MEMptr *data_list));
extern long NFMRcancel_set_copy __NFMR((long user_id, MEMptr attr_list, MEMptr data_list));
extern long NFMRcomplete_set_copy __NFMR((long user_id, char *storage_name, char *tmp_node, char *tmp_user, char *tmp_passwd, char *tmp_path, MEMptr attr_list, MEMptr data_list));

/* NFMRcr_cat.c */
extern long NFMRcreate_catalog __NFMR((long user_id, MEMptr loc_attr, MEMptr loc_data, MEMptr attr_list, MEMptr data_list, MEMptr value_list));

/* NFMRcr_tab.c */
extern long NFMRcreate_table __NFMR((long user_id, char *table_type, char *table_name, MEMptr attr_list, MEMptr data_list, MEMptr value_list));

/* NFMRcr_tmp.c */
extern long NFMRcreate_template __NFMR((long user_id, char *table_name, char *table_type, MEMptr attr_list, MEMptr data_list, MEMptr value_list));

/* NFMRd_cfile.c */
extern long NFMRdelete_copied_files __NFMR((char *working_area, MEMptr data_list));

/* NFMRdates.c */
extern long NFMRvalidate_and_format_date __NFMR((char *in_str, char *display_date, char *timestamp_date));
extern long NFMRget_date_info __NFMR((char *date_type, char *time_type, char *format_string));

/* NFMRdbg_str.c */
extern void _NFMRdebug_NFMoperation_set __NFMR((char *fname, struct NFMoperation *operation));
extern void _NFMRdebug_NFMwf_info __NFMR((char *fname, struct NFMwf_info wf_info));
extern void _NFMRdebug_NFMoperation_item __NFMR((char *fname, struct NFMoperation operation));
extern void _NFMRdebug_NFMmember_info __NFMR((char *fname, struct NFMmember_info *member_info, int members_to_define));
extern void _NFMRdebug_NFMquery_info __NFMR((char *fname, struct NFMquery_info query_info));
extern void _NFMRdebug_synonym_list __NFMR((char *fname, char **syn_info));

/* NFMRdebug.c */
extern long NFMRall_debug __NFMR((int toggles[NFM_DEBUG_SUBSYSTEMS ], char files[NFM_DEBUG_SUBSYSTEMS ][NFM_DEBUG_FILE_SIZE ]));
extern long NFMRclient_debug __NFMR((int toggles[NFM_DEBUG_SUBSYSTEMS ], char files[NFM_DEBUG_SUBSYSTEMS ][NFM_DEBUG_FILE_SIZE ]));
extern long NFMRdebug __NFMR((int nfm, char *nfm_file, int net, char *net_file, int sql, char *sql_file, int mem, char *mem_file));

/* NFMRdel_cat.c */
extern long NFMRdelete_catalog __NFMR((long user_id, char *catalog_name));

/* NFMRdel_item.c */
extern long NFMRdelete_item __NFMR((long user_id, char *catalog_name, char *item_name, char *item_rev));

/* NFMRdel_lab.c */
extern long NFMRdelete_label __NFMR((MEMptr label_buffer));

/* NFMRdel_node.c */
extern long NFMRdelete_node __NFMR((long user_id, char *nodename));

/* NFMRdel_proj.c */
extern long NFMRdelete_project __NFMR((long user_id, char *project_name));

/* NFMRdel_sa.c */
extern long NFMRdelete_storage_area __NFMR((long user_id, char *storagename));

/* NFMRdel_user.c */
extern long NFMRdelete_user __NFMR((long user_id, char *username));

/* NFMRdisplays.c */
extern long NFMRdisplay_nodes __NFMR((char *search, char *sort, int type, MEMptr *syn_list, MEMptr *data_list));
extern long NFMRdisplay_storage_areas __NFMR((char *search, char *sort, int type, MEMptr *syn_list, MEMptr *data_list));
extern long NFMRdisplay_working_areas __NFMR((char *search, char *sort, int type, MEMptr *syn_list, MEMptr *data_list));
extern long NFMRdisplay_users __NFMR((char *search, char *sort, int type, MEMptr *syn_list, MEMptr *data_list));
extern long NFMRdisplay_catalogs __NFMR((char *search, char *sort, int type, MEMptr *syn_list, MEMptr *data_list));
extern long NFMRdisplay_items __NFMR((char *catalog, char *search, char *sort, int type, MEMptr *syn_list, MEMptr *data_list));
extern long NFMRdisplay_items_partial __NFMR((char *catalog, char *search, char *sort, int type, long rows, MEMptr *syn_list, MEMptr *data_list));
extern long NFMRdisplay_item_files __NFMR((char *catalog, char *item, char *rev, char *search, char *sort, MEMptr *syn_list, MEMptr *data_list));
extern long NFMRdisplay_workflows __NFMR((char *search, char *sort, int type, MEMptr *syn_list, MEMptr *data_list));
extern long NFMRdisplay_acls __NFMR((char *wf_name, char *search, char *sort, int type, MEMptr *syn_list, MEMptr *data_list));
extern long NFMRdisplay_classes __NFMR((char *wf_name, char *search, char *sort, int type, MEMptr *syn_list, MEMptr *data_list));
extern long NFMRdisplay_programs __NFMR((char *search, char *sort, int type, MEMptr *syn_list, MEMptr *data_list));
extern long NFMRdisplay_querys __NFMR((char *type, char *search, char *sort, int l_type, MEMptr *syn_list, MEMptr *data_list));
extern long NFMRdisplay_transitions __NFMR((char *wf_name, char *search, char *sort, int type, MEMptr *syn_list, MEMptr *data_list));
extern long NFMRdisplay_aclusers __NFMR((char *acl_name, char *search, char *sort, MEMptr *syn_list, MEMptr *data_list));
extern long NFMRdisplay_archives __NFMR((char *search, char *sort, MEMptr *syn_list, MEMptr *data_list));
extern long NFMRdisplay_projects __NFMR((char *search, char *sort, int type, MEMptr *syn_list, MEMptr *data_list));
extern long NFMRdisplay_project_members __NFMR((char *project, char *search, char *sort, MEMptr *syn_list, MEMptr *data_list));
extern long NFMRdisplay_project_members_partial __NFMR((char *project, char *search, char *sort, long rows, MEMptr *syn_list, MEMptr *data_list));
extern long NFMRdisplay_catalog_acl_mapping __NFMR((char *catalog, char *search, char *sort, MEMptr *syn_list, MEMptr *data_list));
extern long NFMRdisplay_catalog_sa_mapping __NFMR((char *catalog, char *search, char *sort, MEMptr *syn_list, MEMptr *data_list));
extern long NFMRdisplay_project_acl_mapping __NFMR((char *project, char *search, char *sort, MEMptr *syn_list, MEMptr *data_list));
extern long NFMRdisplay_project_sa_mapping __NFMR((char *project, char *search, char *sort, MEMptr *syn_list, MEMptr *data_list));
extern long NFMRdisplay_sets __NFMR((char *catalog, char *search, char *sort, MEMptr *syn_list, MEMptr *data_list));
extern long NFMRdisplay_signoff_users __NFMR((char *acl_name, char *search, char *sort, MEMptr *syn_list, MEMptr *data_list));
extern long NFMRdisplay_so_history __NFMR((char *catalog, char *item, char *rev, MEMptr *syn_list, MEMptr *data_list));
extern long NFMRdisplay_so_on_item __NFMR((char *catalog, char *item, char *rev, MEMptr *syn_list, MEMptr *data_list));
extern long NFMRdisplay_set_members __NFMR((char *catalog, char *item, char *rev, char *search, char *sort, MEMptr *syn_list, MEMptr *data_list));
extern long NFMRdisplay_set_members_partial __NFMR((char *catalog, char *item, char *rev, char *search, char *sort, long rows, MEMptr *syn_list, MEMptr *data_list));
extern long NFMRdisplay_where_used_set __NFMR((char *catalog, char *item, char *rev, MEMptr *syn_list, MEMptr *data_list));
extern long NFMRdisplay_where_used_project __NFMR((char *catalog, char *item, char *rev, MEMptr *syn_list, MEMptr *data_list));
extern long NFMRdisplay_archive_flags __NFMR((char *search, char *sort, MEMptr *syn_list, MEMptr *data_list));
extern long NFMRdisplay_backup_flags __NFMR((char *search, char *sort, MEMptr *syn_list, MEMptr *data_list));
extern long NFMRdisplay_restore_flags __NFMR((char *search, char *sort, MEMptr *syn_list, MEMptr *data_list));
extern long NFMRdisplay_delete_flags __NFMR((char *search, char *sort, MEMptr *syn_list, MEMptr *data_list));
extern long NFMRdisplay_local_files __NFMR((char *storage_area, char *search, char *sort, MEMptr *syn_list, MEMptr *data_list));
extern long NFMRget_acl_list_for_catalog __NFMR((char *catalog_name, MEMptr *syn_list, MEMptr *data_list));
extern long NFMRget_state_list_for_acl __NFMR((long acl_no, MEMptr *syn_list, MEMptr *data_list));
extern long NFMRdisplay_savesets __NFMR((char *search, char *sort, MEMptr *syn_list, MEMptr *data_list));
extern long NFMRdisplay_items_on_tape __NFMR((char *search, char *sort, MEMptr *syn_list, MEMptr *data_list));
extern long NFMRdisplay_labels __NFMR((char *search, char *sort, MEMptr *syn_list, MEMptr *data_list));

/* NFMRerr_buff.c */
extern long NFMRclear_msg_ptrs __NFMR((void));

/* NFMRerr_load.c */
extern int NFMRload_ERRstruct __NFMR((MEMptr status_buffer, MEMptr csd_buffer));

/* NFMRerror.c */
extern int _NFMR_num __NFMR((char *str, long var));
extern int _NFMR_str __NFMR((char *str, char *var));

/* NFMRfile_inf.c */
extern long NFMRget_file_information __NFMR((char *catalog_name, char *item_name, char *item_revision, long operation, MEMptr *attr_list, MEMptr *data_list, MEMptr *value_list));
extern long NFMRdefine_file_information __NFMR((char *catalog_name, char *item_name, char *item_revision, long operation, MEMptr data_list));
extern long NFMRreset_file_information __NFMR((char *catalog_name, char *item_name, char *item_revision));

/* NFMRflg_item.c */
extern long NFMRflag_item_archive __NFMR((long user_id, char *catalog_name, char *item_name, char *item_rev));
extern long NFMRflag_item_backup __NFMR((long user_id, char *catalog_name, char *item_name, char *item_rev));
extern long NFMRflag_item_delete __NFMR((long user_id, char *catalog_name, char *item_name, char *item_rev));
extern long NFMRflag_item_restore __NFMR((long user_id, char *catalog_name, char *item_name, char *item_rev));
extern long NFMRalpha_flag_item_restore __NFMR((long user_id, char *catalog_name, char *item_name, char *item_rev, char *item_ver));

/* NFMRflg_proj.c */
extern long NFMRflag_project_archive __NFMR((long user_id, char *project_name));
extern long NFMRflag_project_backup __NFMR((long user_id, char *project_name));
extern long NFMRflag_project_restore __NFMR((long user_id, char *project_name));

/* NFMRflg_set.c */
extern long NFMRflag_set_archive __NFMR((long user_id, char *catalog_name, char *set_name, char *set_rev));
extern long NFMRflag_set_backup __NFMR((long user_id, char *catalog_name, char *set_name, char *set_rev));
extern long NFMRflag_set_restore __NFMR((long user_id, char *catalog_name, char *set_name, char *set_rev));

/* NFMRget_bulk.c */
extern long NFMRget_bulk_data __NFMR((long user_id, char *storage_name, char *mode, MEMptr *data_list));

/* NFMRget_udef.c */
extern long NFMRget_user_defaults __NFMR((long user_id, MEMptr *data_list));
extern long NFMRread_user_defaults __NFMR((MEMptr *data_list));

/* NFMRglobals.c */

/* NFMRitem_t.c */
extern long NFMRget_item_no __NFMR((long user_id, char *cat_name, char *item_name, char *item_rev, char *item_num));
extern long NFMRget_item_name __NFMR((long user_id, char *cat_name, char *item_num, char *item_name, char *item_rev));

/* NFMRlItmTape.c */
extern long NFMRlist_items_on_tape __NFMR((long user_id, MEMptr *data_list));

/* NFMRlSaveset.c */
extern long NFMRlist_savesets __NFMR((long user_id, MEMptr *data_list));

/* NFMRl_arch.c */
extern int list_archive __NFMR((void));

/* NFMRl_back.c */
extern int list_backup __NFMR((void));

/* NFMRl_del.c */
extern int list_delete __NFMR((void));

/* NFMRl_item_s.c */
extern long NFMRlist_items_short __NFMR((long user_id, char *catalog_name, MEMptr *data_list));

/* NFMRl_rstr.c */
extern int list_restore __NFMR((void));

/* NFMRlfm.c */
extern long NFMlfm_information __NFMR((long sa_no, long flag, char *search, char *sort, MEMptr *output_list));
extern long NFMlfm_update __NFMR((MEMptr input_list, long flag));

/* NFMRload_wf.c */
extern long NFMRload_workflow __NFMR((long user_id, char *appl_name, char *wf_file_name));

/* NFMRlock.c */
extern long NFMRlock_item __NFMR((long user_id, char *catalog_name, char *item_name, char *item_rev));
extern long NFMRunlock_item __NFMR((long user_id, char *catalog_name, char *item_name, char *item_rev));

/* NFMRlog_in.c */
extern long NFMRlog_in __NFMR((char *user_name, char *password, char *environment, char *application));

/* NFMRlogin.c */
extern long NFMRlogin __NFMR((MEMptr login_attr, MEMptr login_data, MEMptr login_wf, long *user_id));
extern long NFMRquery_login_attributes __NFMR((char *app_id, char *env_type, MEMptr *attr_list, MEMptr *data_list, MEMptr *value_list, MEMptr *wf_list));

/* NFMRlogout.c */
extern long NFMRlogout __NFMR((long user_id));

/* NFMRmaint.c */
extern long NFMRquery_savesets_to_delete __NFMR((MEMptr *syn_list, MEMptr *data_list));
extern long NFMRdelete_savesets __NFMR((MEMptr data_list));
extern long NFMRquery_archives_to_delete __NFMR((MEMptr *syn_list, MEMptr *data_list));
extern long NFMRdelete_archives __NFMR((MEMptr data_list));

/* NFMRmod_acl.c */
extern long NFMRquery_acl_class_users __NFMR((long user_id, char *acl_name, MEMptr *attr_list, MEMptr *data_list, MEMptr *value_list));
extern long NFMRupdate_acl_class_users __NFMR((long user_id, MEMptr attr_list, MEMptr data_list));
extern long NFMRdelete_acl __NFMR((char *wf_name, char *acl_name));

/* NFMRmod_i_wf.c */
extern long NFMRget_wf_and_completed_acl_list __NFMR((MEMptr *syn_list, MEMptr *data_list));
extern long NFMRget_state_list_for_workflow __NFMR((char *wf_name, MEMptr *syn_list, MEMptr *data_list));
extern long NFMRchange_wf_item __NFMR((char *catalog_name, char *item_name, char *item_rev, char *workflow, char *acl_name, long acl_no, char *state_name, long state_no));

/* NFMRnci_item.c */
extern long NFMRcheckin_item __NFMR((char *catalog_name, long catalog_no, char *item_name, char *item_revision, char *working_area, struct NFMwf_info wf_info, struct NFMoperation operation));

/* NFMRnci_set.c */
extern long NFMRcheckin_set __NFMR((char *catalog_name, long catalog_no, char *set_name, char *set_revision, long set_no, char *working_area, struct NFMwf_info wf_info, long member_operations, struct NFMoperation *operation, long level));

/* NFMRnco_item.c */
extern long NFMRcheckout_item __NFMR((char *catalog_name, long catalog_no, char *item_name, char *item_revision, char *working_area, struct NFMwf_info wf_info, struct NFMoperation operation));

/* NFMRnco_set.c */
extern long NFMRcheckout_set __NFMR((char *catalog_name, long catalog_no, char *set_name, char *set_revision, long set_no, char *working_area, struct NFMwf_info wf_info, long member_operations, struct NFMoperation *operation, long level));

/* NFMRncp_item.c */
extern long NFMRcopy_item_files __NFMR((char *catalog_name, long catalog_no, char *item_name, char *item_revision, char *working_area, struct NFMwf_info wf_info, struct NFMoperation operation));
extern long NFMRcopy_item_n __NFMR((char *catalog_name, MEMptr attr_list, MEMptr data_list, MEMptr attr_f_list, MEMptr data_f_list));

/* NFMRncp_set.c */
extern long NFMRcopy_set_files __NFMR((char *catalog_name, long catalog_no, char *set_name, char *set_revision, long set_no, char *working_area, struct NFMwf_info wf_info, long member_operations, struct NFMoperation *operation, long level));

/* NFMRnode_t.c */
extern long NFMRget_node_no __NFMR((long user_id, char *node_name, char *node_num));
extern long NFMRget_node_name __NFMR((long user_id, char *node_num, char *node_name));

/* NFMRplt_item.c */
extern long NFMRplot_item __NFMR((char *catalog_name, char *item_name, char *item_rev));

/* NFMRplt_set.c */
extern long NFMRplot_set __NFMR((char *catalog_name, char *set_name, char *set_rev));

/* NFMRpr_util.c */
extern long NFMRarchive_files __NFMR((char *server, char *env, char *user, char *passwd, char *sa_no, char *label, MEMptr flist, MEMptr *msg_buffer));
extern long NFMRbackup_files __NFMR((char *server, char *env, char *user, char *passwd, char *sa_no, char *label, MEMptr flist, MEMptr *msg_buffer));
extern long NFMRrestore_files __NFMR((char *server, char *env, char *user, char *passwd, MEMptr flist, MEMptr *msg_buffer));
extern long NFMRdelete_files __NFMR((char *server, char *env, char *user, char *passwd, MEMptr flist));

/* NFMRprog_t.c */
extern long NFMRget_program_no __NFMR((long user_id, char *program_name, char *program_num));
extern long NFMRget_program_name __NFMR((long user_id, char *program_num, char *program_name));

/* NFMRproj_map.c */
extern long NFMRquery_project_acl_map __NFMR((long user_id, char *project_name, MEMptr *attr_list, MEMptr *data_list, MEMptr *value_list));
extern long NFMRupdate_project_acl_map __NFMR((long user_id, MEMptr attr_list, MEMptr data_list));
extern long NFMRquery_project_sa_map __NFMR((long user_id, char *project_name, MEMptr *attr_list, MEMptr *data_list, MEMptr *value_list));
extern long NFMRupdate_project_sa_map __NFMR((long user_id, MEMptr attr_list, MEMptr data_list));

/* NFMRproj_t.c */
extern long NFMRget_project_no __NFMR((long user_id, char *project_name, char *project_num));
extern long NFMRget_project_name __NFMR((long user_id, char *project_num, char *project_name));

/* NFMRq_cat.c */
extern long NFMRquery_catalog_attributes __NFMR((long user_id, char *catalog_name, MEMptr *attr_list, MEMptr *data_list, MEMptr *value_list));
extern long NFMRquery_catalog_template __NFMR((long user_id, MEMptr *attr_list, MEMptr *data_list, MEMptr *value_list));
extern long NFMRquery_catalog_template_n __NFMR((MEMptr *attr_list, MEMptr *data_list, MEMptr *value_list, MEMptr application));
extern long NFMRquery_catalog_definition __NFMR((long user_id, char *catalog_name, MEMptr *attr_list));

/* NFMRq_chgcat.c */
extern long NFMRquery_change_catalog_attributes __NFMR((long user_id, char *catalog_name, MEMptr *attr_list, MEMptr *data_list, MEMptr *value_list));
extern long NFMRquery_changeto_loc_attributes __NFMR((long user_id, char *loc_name, char *catalog_name, MEMptr *attr_list, MEMptr *data_list, MEMptr *value_list));

/* NFMRq_chgtab.c */
extern long NFMRquery_change_table_attributes __NFMR((long user_id, char *table_type, char *table_name, MEMptr *attr_list, MEMptr *data_list, MEMptr *value_list));

/* NFMRq_chgtmp.c */
extern long NFMRquery_change_template_attributes __NFMR((long user_id, char *table_type, MEMptr *attr_list, MEMptr *data_list, MEMptr *value_list));

/* NFMRq_cit.c */
extern long NFMRquery_cit_attributes __NFMR((long user_id, char *cit_name, MEMptr *attr_list, MEMptr *data_list));
extern long NFMRquery_cit_definition __NFMR((long user_id, char *cit_name, MEMptr *attr_list));

/* NFMRq_item.c */
extern long NFMRquery_add_item_attributes __NFMR((long user_id, char *catalog_name, MEMptr *attr_list, MEMptr *data_list, MEMptr *value_list));
extern long NFMRquery_item_attributes __NFMR((long user_id, char *catalog_name, char *item_name, char *item_rev, MEMptr *attr_list, MEMptr *data_list, MEMptr *value_list));
extern long NFMRquery_item_versions __NFMR((long user_id, char *catalog_name, char *item_name, char *item_rev, MEMptr *attr_list, MEMptr *data_list));
extern long NFMRget_item_attr_for_copy __NFMR((char *catalog_name, char *itemname, char *itemrev, MEMptr *attr_list, MEMptr *data_list, MEMptr *value_list, MEMptr *attr_f_list, MEMptr *data_f_list, MEMptr *value_f_list));

/* NFMRq_loc.c */
extern long NFMRquery_addto_loc_attributes __NFMR((long user_id, char *loc_name, MEMptr *attr_list, MEMptr *data_list, MEMptr *value_list));
extern long NFMRquery_loc_definition __NFMR((long user_id, char *loc_name, MEMptr *attr_list));

/* NFMRq_lop.c */
extern long NFMRquery_lop_attributes __NFMR((long user_id, char *lop_name, char *project_name, MEMptr *attr_list, MEMptr *data_list, MEMptr *value_list));
extern long NFMRquery_lop_definition __NFMR((long user_id, char *lop_name, MEMptr *attr_list));

/* NFMRq_set.c */
extern long NFMRquery_set_members __NFMR((long user_id, char *catalog_name, char *item_name, char *item_rev, long level, long type, MEMptr *attr_list, MEMptr *data_list));
extern long NFMRquery_add_set_attributes __NFMR((long user_id, char *catalog_name, MEMptr *attr_list, MEMptr *data_list, MEMptr *value_list));
extern long NFMRqry_set_members __NFMR((long user_id, char *catalog_name, char *item_name, char *item_rev, long level, long type, MEMptr *attr_list, MEMptr *data_list));

/* NFMRq_tab.c */
extern long NFMRquery_table_attributes __NFMR((long user_id, char *table_type, char *table_name, MEMptr *attr_list, MEMptr *data_list, MEMptr *value_list));
extern long NFMRquery_table_template __NFMR((long user_id, MEMptr *attr_list));
extern long NFMRquery_table_definition __NFMR((long user_id, char *table_type, char *table_name, MEMptr *attr_list));

/* NFMRq_tmp.c */
extern long NFMRquery_template_attributes __NFMR((long user_id, char *table_type, char *table_name, MEMptr *attr_list, MEMptr *data_list, MEMptr *value_list));
extern long NFMRquery_template_definition __NFMR((long user_id, char *table_type, char *table_name, MEMptr *attr_list));

/* NFMRq_util.c */
extern long NFMRquery_archive __NFMR((MEMptr *sa_value, MEMptr *f_value, MEMptr *label_value));
extern long NFMRquery_backup __NFMR((MEMptr *sa_value, MEMptr *f_value, MEMptr *label_value));
extern long NFMRquery_restore __NFMR((MEMptr *f_value));
extern long NFMRquery_delete __NFMR((MEMptr *f_value));

/* NFMRqry_can.c */
extern int NFMRquery_cancel_archive __NFMR((long user_id, char *catalog, MEMptr *files));
extern int NFMRquery_cancel_backup __NFMR((long user_id, char *catalog, MEMptr *files));
extern int NFMRquery_cancel_restore __NFMR((long user_id, char *catalog, MEMptr *files));
extern int NFMRquery_cancel_delete __NFMR((long user_id, char *catalog, MEMptr *files));

/* NFMRqry_flag.c */
extern int NFMRquery_flagged_files __NFMR((long user_id, int utility, MEMptr *files));
extern int NFMRquery_flag_archive __NFMR((long user_id, char *catalog, MEMptr *files));
extern int NFMRquery_flag_backup __NFMR((long user_id, char *catalog, MEMptr *files));
extern int NFMRquery_flag_restore __NFMR((long user_id, char *catalog, MEMptr *files));
extern int NFMRnew_query_flag_restore __NFMR((char *catalog, char *item, char *revision, MEMptr *files));
extern int NFMRquery_flag_delete __NFMR((long user_id, char *catalog, MEMptr *files));

/* NFMRquery.c */
extern long NFMRdefine_query __NFMR((char *query_name, char *query_desc, long query_type, char *application, char *user_name, struct NFMquery_info query_info));
extern long NFMRdelete_query __NFMR((char *query_name));
extern long NFMRretrieve_query __NFMR((char *query_name, struct NFMquery_info *query_info));
extern long NFMRretrieve_query_info __NFMR((char *query_name, char *query_type, char *application, char *appl_type, char *query_desc, char *owner, struct NFMquery_info *query_info));

/* NFMRrebuild.c */
extern long NFMRrebuild_data_buffer __NFMR((MEMptr attr_list, MEMptr *data_list));

/* NFMRrec_buff.c */
extern long NFMRreceive_buffer __NFMR((long *netid, long *ret_status, MEMptr *return_buffer));
extern long NFMRreceive_error_buffers __NFMR((long *netid, long *ret_status));
extern long NFMRreceive_one_buffer __NFMR((long *netid, long *ret_status, MEMptr *return_buffer1));
extern long NFMRreceive_two_buffers __NFMR((long *netid, long *ret_status, MEMptr *return_buffer1, MEMptr *return_buffer2));
extern long NFMRreceive_three_buffers __NFMR((long *netid, long *ret_status, MEMptr *return_buffer1, MEMptr *return_buffer2, MEMptr *return_buffer3));
extern long NFMRreceive_four_buffers __NFMR((long *netid, long *ret_status, MEMptr *return_buffer1, MEMptr *return_buffer2, MEMptr *return_buffer3, MEMptr *return_buffer4));
extern long NFMRreceive_five_buffers __NFMR((long *netid, long *ret_status, MEMptr *return_buffer1, MEMptr *return_buffer2, MEMptr *return_buffer3, MEMptr *return_buffer4, MEMptr *return_buffer5));
extern long NFMRreceive_six_buffers __NFMR((long *netid, long *ret_status, MEMptr *return_buffer1, MEMptr *return_buffer2, MEMptr *return_buffer3, MEMptr *return_buffer4, MEMptr *return_buffer5, MEMptr *return_buffer6));

/* NFMRrev_st.c */
extern long NFMRreview_state __NFMR((long user_id, char *catalog_name, char *item_name, char *item_rev, char *state_number, char *state_name));

/* NFMRsa_t.c */
extern long NFMRget_sa_no __NFMR((long user_id, char *sa_name, char *sa_num));
extern long NFMRget_sa_name __NFMR((long user_id, char *sa_num, char *sa_name));
extern long NFMRget_sa_no_info __NFMR((long user_id, char *sa_num, char *node_name, char *user_name, char *encr_passwd, char *path_name, char *dev_type, char *mach_id, char *op_sys, char *net_tcp, char *net_xns, char *net_dec));

/* NFMRset_inf.c */
extern long NFMRdefine_set_information __NFMR((char *catalog_name, long catalog_no, char *set_name, char *set_revision, long file_status_check, long members_to_define, struct NFMmember_info *members_info));
extern long NFMRget_set_messages __NFMR((MEMptr *data_list));

/* NFMRset_st.c */
extern long NFMRset_to_state __NFMR((long user_id, char *application));
extern long NFMRset_wf_state __NFMR((char *application, long err_number, char *err_message));

/* NFMRset_udef.c */
extern long NFMRset_user_defaults __NFMR((long user_id, MEMptr data_list));
extern long NFMRwrite_user_defaults __NFMR((MEMptr data_list));

/* NFMRsignoff.c */
extern long NFMRquery_acl_signoff_users __NFMR((long user_id, char *acl_name, MEMptr *attr_list, MEMptr *data_list, MEMptr *value_list));
extern long NFMRupdate_acl_signoff_users __NFMR((long user_id, MEMptr attr_list, MEMptr data_list));
extern long NFMRquery_signoff_attributes __NFMR((long user_id, MEMptr *attr_list, MEMptr *data_list, MEMptr *value_list));
extern long NFMRsignoff __NFMR((long user_id, MEMptr attr_list, MEMptr data_list));
extern long NFMRpurge_signoff __NFMR((long user_id, char *catalog_name, char *item_name, char *item_rev));

/* NFMRsqlquery.c */
extern long NFMRsqlquery __NFMR((char *sql_string, char *buffer_size, MEMptr *sql_buffer));
extern long NFMRsqlquery_cursor __NFMR((char *sql_string, char *buffer_size, long rows, int cursor, MEMptr *sql_buffer));

/* NFMRsqlstmt.c */
extern long NFMRsqlstmt __NFMR((char *sql_string));

/* NFMRsr_a_cat.c */
extern long NFMRmultiple_catalog_search __NFMR((MEMptr cat_buffer, char *item_search_str, char *item_sort_str, MEMptr *out_buffer_list, MEMptr *syn_list));
extern long NFMRblock_multiple_catalog_search __NFMR((MEMptr cat_buffer, char *item_search_str, char *item_sort_str, MEMptr *out_buffer_list, MEMptr *syn_list, long row_size));

/* NFMRstate_t.c */
extern long NFMRget_state_no __NFMR((long user_id, char *wf_num, char *state_name, char *state_num));
extern long NFMRget_state_name __NFMR((long user_id, char *wf_num, char *state_num, char *state_name));

/* NFMRsv_files.c */
extern long NFMRsave_item_files __NFMR((char *catalog_name, char *item_name, char *item_revision));

/* NFMRsv_sfile.c */
extern long NFMRsave_set_files __NFMR((char *catalog_name, char *set_name, char *set_revision));

/* NFMRtab_t.c */
extern long NFMRget_table_no __NFMR((long user_id, char *table_type, char *table_name, char *table_num));
extern long NFMRget_table_name __NFMR((long user_id, char *table_num, char *table_type, char *table_name));

/* NFMRterm.c */
extern long NFMRterminate __NFMR((void));

/* NFMRtic.c */
extern long NFMRtic_it __NFMR((MEMptr buffer));
extern int NFMRtic_to_tics __NFMR((char *in, char *out));

/* NFMRtools.c */
extern long NFMRfill_index __NFMR((MEMptr attr_list, NDXptr *index));
extern long NFMRfill_new_index __NFMR((MEMptr attr_list, NDXnewptr *index));
extern long NFMRfill_newer_index __NFMR((MEMptr attr_list, NDXnptr *index));

/* NFMRtrans.c */
extern long NFMRquery_make_transition __NFMR((long user_id, MEMptr *attr_list, MEMptr *data_list));
extern long NFMRmake_transition __NFMR((long user_id, MEMptr attr_list, MEMptr data_list));

/* NFMRupd_proj.c */
extern long NFMRquery_project_members __NFMR((long user_id, char *project_name, MEMptr *attr_list, MEMptr *data_list));
extern long NFMRupdate_project_members __NFMR((long user_id, MEMptr attr_list, MEMptr data_list));
extern long NFMRqry_items_in_cat_for_project __NFMR((long user_id, char *project_name, char *catalog_name, MEMptr *item_list));
extern long NFMRqry_project_members __NFMR((long user_id, char *project_name, MEMptr *attr_list, MEMptr *data_list));

/* NFMRupd_set.c */
extern long NFMRupdate_set_members __NFMR((long user_id, MEMptr attr_list, MEMptr data_list));

/* NFMRupd_st.c */
extern long NFMRupdate_state __NFMR((long user_id, char *catalog_name, char *item_name, char *item_rev, int state_no));
extern long NFMRquery_states __NFMR((long user_id, char *catalog_name, char *item_name, char *item_rev, MEMptr *buffer));

/* NFMRupdate.c */
extern long NFMRprepare_update_item __NFMR((long user_id, char *catalog_name, char *item_name, char *item_rev, MEMptr *attr_list, MEMptr *data_list, MEMptr *value_list));
extern long NFMRcancel_update_item __NFMR((long user_id, MEMptr attr_list, MEMptr data_list));
extern long NFMRupdate_item __NFMR((long user_id, char *cat_name, MEMptr attr_list, MEMptr data_list));

/* NFMRuser_def.c */
extern long NFMRupdate_user_defaults __NFMR((long user_id, MEMptr attr_list, MEMptr data_list));
extern long NFMRquery_user_defaults __NFMR((long user_id, MEMptr *attr_list, MEMptr *data_list, MEMptr *value_list));

/* NFMRuser_t.c */
extern long NFMRget_user_no __NFMR((long user_id, char *user_name, char *user_num));
extern long NFMRget_user_name __NFMR((long user_id, char *user_num, char *user_name));

/* NFMRval_info.c */
extern long NFMRvalidate_project __NFMR((char *project_name));
extern long NFMRvalidate_catalog __NFMR((char *catalog_name));
extern long NFMRvalidate_item __NFMR((char *catalog_name, char *item_name));
extern long NFMRvalidate_revision __NFMR((char *catalog_name, char *item_name, char *item_revision, int *flag));
extern long NFMRvalidate_search __NFMR((char *search_name, char *owner));
extern long NFMRvalidate_sort __NFMR((char *sort_name, char *owner));
extern long NFMRvalidate_working_area __NFMR((char *wa_name, char *owner));
extern long NFMRvalidate_st_area __NFMR((char *st_area_name));
extern long NFMRvalidate_node __NFMR((char *node_name));
extern long NFMRvalidate_set_item __NFMR((char *set_cat_name, char *set_item_name));
extern long NFMRvalidate_set_rev __NFMR((char *set_cat_name, char *set_item_name, char *set_item_rev));
extern long NFMRvalidate_workflow __NFMR((char *workflow_name));
extern long NFMRvalidate_acl __NFMR((char *wf_name, char *acl_name));
extern long NFMRvalidate_user __NFMR((char *user_name));

/* NFMRvalid.c */
extern long NFMRvalidate_user_access __NFMR((long user_id, char *command, char *workflow, char *project, char *catalog_name, char *item_name, char *item_rev));

/* NFMRversions.c */
extern long NFMRpurge_versions __NFMR((char *catalog_name, char *item_name, char *item_rev));
extern long NFMRroll_version_forward __NFMR((char *catalog_name, char *item_name, char *item_rev, MEMptr data_list));
extern long NFMRget_item_versions __NFMR((char *catalog_name, char *item_name, char *item_rev, MEMptr *syn_list, MEMptr *data_list));

/* NFMRwf_t.c */
extern long NFMRget_workflow_no __NFMR((long user_id, char *workflow_name, char *workflow_num));
extern long NFMRget_workflow_name __NFMR((long user_id, char *workflow_num, char *workflow_name));

#undef __NFMR

#endif
