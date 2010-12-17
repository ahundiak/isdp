#ifndef NFMS_PROTO_H
#define NFMS_PROTO_H

#if defined(__STDC__) || defined(__cplusplus)
# define __NFMS(s) s
#else
# define __NFMS(s) ()
#endif


/* NFMSacl_t.c */
extern long NFMSget_acl_no __NFMS((MEMptr in_list));
extern long NFMSget_acl_name __NFMS((MEMptr in_list));

/* NFMSadd_acl.c */
extern long NFMSquery_acl_attributes __NFMS((MEMptr in_list));
extern long NFMSadd_acl __NFMS((MEMptr in_list));

/* NFMSadd_d_wa.c */
extern long NFMSadd_default_working_area __NFMS((MEMptr in_list));

/* NFMSadd_item.c */
extern long NFMSadd_item __NFMS((MEMptr in_list));

/* NFMSadd_node.c */
extern long NFMSadd_node __NFMS((MEMptr in_list));
extern long NFMSquery_add_node_attributes __NFMS((MEMptr in_list));

/* NFMSadd_proj.c */
extern long NFMSquery_addto_lop_attributes __NFMS((MEMptr in_list));
extern long NFMSadd_project __NFMS((MEMptr in_list));

/* NFMSadd_sa.c */
extern long NFMSadd_storage_area __NFMS((MEMptr in_list));
extern long NFMSadd_return_sa_name __NFMS((MEMptr in_list));
extern long NFMSquery_add_st_area_attributes __NFMS((MEMptr in_list));

/* NFMSadd_set.c */
extern long NFMSadd_set __NFMS((MEMptr in_list));

/* NFMSadd_user.c */
extern long NFMSadd_user __NFMS((MEMptr in_list));
extern long NFMSquery_add_user_attributes __NFMS((MEMptr in_list));

/* NFMScan_iflg.c */
extern long NFMScancel_item_archive_flag __NFMS((MEMptr in_list));
extern long NFMScancel_item_backup_flag __NFMS((MEMptr in_list));
extern long NFMScancel_item_restore_flag __NFMS((MEMptr in_list));
extern long NFMScancel_item_delete_flag __NFMS((MEMptr in_list));

/* NFMScan_item.c */
extern long NFMScancel_co_item __NFMS((MEMptr in_list));
extern long NFMScancel_check_out_item __NFMS((MEMptr in_list));

/* NFMScan_pflg.c */
extern long NFMScancel_project_archive_flag __NFMS((MEMptr in_list));
extern long NFMScancel_project_backup_flag __NFMS((MEMptr in_list));
extern long NFMScancel_project_restore_flag __NFMS((MEMptr in_list));

/* NFMScan_set.c */
extern long NFMScancel_co_set __NFMS((MEMptr in_list));
extern long NFMScancel_check_out_set __NFMS((MEMptr in_list));

/* NFMScan_sflg.c */
extern long NFMScancel_set_archive_flag __NFMS((MEMptr in_list));
extern long NFMScancel_set_backup_flag __NFMS((MEMptr in_list));
extern long NFMScancel_set_restore_flag __NFMS((MEMptr in_list));

/* NFMScat_map.c */
extern long NFMSquery_catalog_acl_map __NFMS((MEMptr in_list));
extern long NFMSupdate_catalog_acl_map __NFMS((MEMptr in_list));
extern long NFMSquery_catalog_sa_map __NFMS((MEMptr in_list));
extern long NFMSupdate_catalog_sa_map __NFMS((MEMptr in_list));

/* NFMScat_t.c */
extern long NFMSget_catalog_no __NFMS((MEMptr in_list));
extern long NFMSget_catalog_name __NFMS((MEMptr in_list));

/* NFMSchg_cat.c */
extern long NFMSchange_catalog __NFMS((MEMptr in_list));

/* NFMSchg_node.c */
extern long NFMSchange_node __NFMS((MEMptr in_list));

/* NFMSchg_proj.c */
extern long NFMSquery_changeto_lop_attributes __NFMS((MEMptr in_list));
extern long NFMSchange_project __NFMS((MEMptr in_list));

/* NFMSchg_pwd.c */
extern long NFMSchange_storage_area_passwd __NFMS((MEMptr in_list));
extern long NFMSchange_user_passwd __NFMS((MEMptr in_list));
extern long NFMSchange_working_area_passwd __NFMS((MEMptr in_list));

/* NFMSchg_sa.c */
extern long NFMSchange_storage_area __NFMS((MEMptr in_list));

/* NFMSchg_tab.c */
extern long NFMSchange_table __NFMS((MEMptr in_list));

/* NFMSchg_tmp.c */
extern long NFMSchange_template __NFMS((MEMptr in_list));

/* NFMSchg_user.c */
extern long NFMSchange_user __NFMS((MEMptr in_list));

/* NFMSci_item.c */
extern long NFMSprepare_item_checkin __NFMS((MEMptr in_list));
extern long NFMScancel_item_checkin __NFMS((MEMptr in_list));
extern long NFMScomplete_item_checkin __NFMS((MEMptr in_list));

/* NFMSci_set.c */
extern long NFMSprepare_set_checkin __NFMS((MEMptr in_list));
extern long NFMScancel_set_checkin __NFMS((MEMptr in_list));
extern long NFMScomplete_set_checkin __NFMS((MEMptr in_list));

/* NFMSclass_t.c */
extern long NFMSget_class_no __NFMS((MEMptr in_list));
extern long NFMSget_class_name __NFMS((MEMptr in_list));

/* NFMSclient.c */
extern long NFMSclient_info __NFMS((MEMptr in_list));

/* NFMScmd_t.c */
extern long NFMSget_command_no __NFMS((MEMptr in_list));
extern long NFMSget_command_name __NFMS((MEMptr in_list));

/* NFMSco_item.c */
extern long NFMSprepare_item_checkout __NFMS((MEMptr in_list));
extern long NFMScancel_item_checkout __NFMS((MEMptr in_list));
extern long NFMScomplete_item_checkout __NFMS((MEMptr in_list));

/* NFMSco_set.c */
extern long NFMSprepare_set_checkout __NFMS((MEMptr in_list));
extern long NFMScancel_set_checkout __NFMS((MEMptr in_list));
extern long NFMScomplete_set_checkout __NFMS((MEMptr in_list));

/* NFMScopy_acl.c */
extern long NFMSquery_acl_attributes_condition __NFMS((MEMptr in_list));
extern long NFMSget_acl_classes_for_copy __NFMS((MEMptr in_list));
extern long NFMScopy_acl_users __NFMS((MEMptr in_list));

/* NFMScp_item.c */
extern long NFMSprepare_item_copy __NFMS((MEMptr in_list));
extern long NFMScancel_item_copy __NFMS((MEMptr in_list));
extern long NFMScomplete_item_copy __NFMS((MEMptr in_list));

/* NFMScp_set.c */
extern long NFMSprepare_set_copy __NFMS((MEMptr in_list));
extern long NFMScancel_set_copy __NFMS((MEMptr in_list));
extern long NFMScomplete_set_copy __NFMS((MEMptr in_list));

/* NFMScr_cat.c */
extern long NFMScreate_catalog __NFMS((MEMptr in_list));

/* NFMScr_tab.c */
extern long NFMScreate_table __NFMS((MEMptr in_list));

/* NFMScr_tmp.c */
extern long NFMScreate_template __NFMS((MEMptr in_list));

/* NFMSd_cfile.c */
extern long NFMSdelete_copied_files __NFMS((MEMptr in_list));

/* NFMSdates.c */
extern long NFMSvalidate_and_format_date __NFMS((MEMptr in_list));
extern long NFMSget_date_info __NFMS((MEMptr in_list));

/* NFMSdbg_str.c */
extern void _NFMSdebug_NFMwf_info __NFMS((char *fname, struct NFMwf_info *wf_info));
extern void _NFMSdebug_NFMoperation_item __NFMS((char *fname, struct NFMoperation operation));
extern void _NFMSdebug_NFMoperation_set __NFMS((char *fname, struct NFMoperation *operation));
extern void _NFMSdebug_NFMmember_info __NFMS((char *fname, struct NFMmember_info *member_info, int members_to_define));
extern void _NFMSdebug_NFMquery_info __NFMS((char *fname, struct NFMquery_info query_info));
extern void _NFMSdebug_synonym_list __NFMS((char *fname, char **syn_info));

/* NFMSdebug.c */
extern long NFMSdebug __NFMS((MEMptr in_list, MEMptr *out_list));
extern long NFMSall_debug __NFMS((MEMptr in_list, MEMptr *out_list));

/* NFMSdel_cat.c */
extern long NFMSdelete_catalog __NFMS((MEMptr in_list));

/* NFMSdel_item.c */
extern long NFMSdelete_item __NFMS((MEMptr in_list));

/* NFMSdel_lab.c */
extern long NFMSdelete_label __NFMS((MEMptr in_list));

/* NFMSdel_node.c */
extern long NFMSdelete_node __NFMS((MEMptr in_list));

/* NFMSdel_proj.c */
extern long NFMSdelete_project __NFMS((MEMptr in_list));

/* NFMSdel_sa.c */
extern long NFMSdelete_storage_area __NFMS((MEMptr in_list));

/* NFMSdel_user.c */
extern long NFMSdelete_user __NFMS((MEMptr in_list));

/* NFMSdisplays.c */
extern long NFMSdisplay_acls __NFMS((MEMptr in_list, MEMptr *syn_list, MEMptr *data_list));
extern long NFMSdisplay_aclusers __NFMS((MEMptr in_list, MEMptr *syn_list, MEMptr *data_list));
extern long NFMSdisplay_archives __NFMS((MEMptr in_list, MEMptr *syn_list, MEMptr *data_list));
extern long NFMSdisplay_catalog_acl_mapping __NFMS((MEMptr in_list, MEMptr *syn_list, MEMptr *data_list));
extern long NFMSdisplay_catalog_sa_mapping __NFMS((MEMptr in_list, MEMptr *syn_list, MEMptr *data_list));
extern long NFMSdisplay_catalogs __NFMS((MEMptr in_list, MEMptr *syn_list, MEMptr *data_list));
extern long NFMSdisplay_classes __NFMS((MEMptr in_list, MEMptr *syn_list, MEMptr *data_list));
extern long NFMSdisplay_item_files __NFMS((MEMptr in_list, MEMptr *syn_list, MEMptr *data_list));
extern long NFMSdisplay_items __NFMS((MEMptr in_list, MEMptr *syn_list, MEMptr *data_list));
extern long NFMSdisplay_items_partial __NFMS((MEMptr in_list, MEMptr *syn_list, MEMptr *data_list));
extern long NFMSdisplay_items_short __NFMS((MEMptr in_list, MEMptr *syn_list, MEMptr *data_list));
extern long NFMSdisplay_items_short_partial __NFMS((MEMptr in_list, MEMptr *syn_list, MEMptr *data_list));
extern long NFMSdisplay_nodes __NFMS((MEMptr in_list, MEMptr *syn_list, MEMptr *data_list));
extern long NFMSdisplay_project_acl_mapping __NFMS((MEMptr in_list, MEMptr *syn_list, MEMptr *data_list));
extern long NFMSdisplay_project_sa_mapping __NFMS((MEMptr in_list, MEMptr *syn_list, MEMptr *data_list));
extern long NFMSdisplay_programs __NFMS((MEMptr in_list, MEMptr *syn_list, MEMptr *data_list));
extern long NFMSdisplay_projects __NFMS((MEMptr in_list, MEMptr *syn_list, MEMptr *data_list));
extern long NFMSdisplay_project_members __NFMS((MEMptr in_list, MEMptr *syn_list, MEMptr *data_list));
extern long NFMSdisplay_project_members_partial __NFMS((MEMptr in_list, MEMptr *syn_list, MEMptr *data_list));
extern long NFMSdisplay_where_used_project __NFMS((MEMptr in_list, MEMptr *syn_list, MEMptr *data_list));
extern long NFMSdisplay_querys __NFMS((MEMptr in_list, MEMptr *syn_list, MEMptr *data_list));
extern long NFMSdisplay_storage_areas __NFMS((MEMptr in_list, MEMptr *syn_list, MEMptr *data_list));
extern long NFMSdisplay_working_areas __NFMS((MEMptr in_list, MEMptr *syn_list, MEMptr *data_list));
extern long NFMSdisplay_sets __NFMS((MEMptr in_list, MEMptr *syn_list, MEMptr *data_list));
extern long NFMSdisplay_set_members __NFMS((MEMptr in_list, MEMptr *syn_list, MEMptr *data_list));
extern long NFMSdisplay_set_members_partial __NFMS((MEMptr in_list, MEMptr *syn_list, MEMptr *data_list));
extern long NFMSdisplay_where_used_set __NFMS((MEMptr in_list, MEMptr *syn_list, MEMptr *data_list));
extern long NFMSdisplay_signoff_users __NFMS((MEMptr in_list, MEMptr *syn_list, MEMptr *data_list));
extern long NFMSdisplay_so_on_item __NFMS((MEMptr in_list, MEMptr *syn_list, MEMptr *data_list));
extern long NFMSdisplay_so_history __NFMS((MEMptr in_list, MEMptr *syn_list, MEMptr *data_list));
extern long NFMSdisplay_transitions __NFMS((MEMptr in_list, MEMptr *syn_list, MEMptr *data_list));
extern long NFMSdisplay_users __NFMS((MEMptr in_list, MEMptr *syn_list, MEMptr *data_list));
extern long NFMSdisplay_workflows __NFMS((MEMptr in_list, MEMptr *syn_list, MEMptr *data_list));
extern long NFMSdisplay_archive_flags __NFMS((MEMptr in_list, MEMptr *syn_list, MEMptr *data_list));
extern long NFMSdisplay_backup_flags __NFMS((MEMptr in_list, MEMptr *syn_list, MEMptr *data_list));
extern long NFMSdisplay_restore_flags __NFMS((MEMptr in_list, MEMptr *syn_list, MEMptr *data_list));
extern long NFMSdisplay_delete_flags __NFMS((MEMptr in_list, MEMptr *syn_list, MEMptr *data_list));
extern long NFMSdisplay_local_files __NFMS((MEMptr in_list, MEMptr *syn_list, MEMptr *data_list));
extern long NFMSdisplay_savesets __NFMS((MEMptr in_list, MEMptr *syn_list, MEMptr *data_list));
extern long NFMSdisplay_items_on_tape __NFMS((MEMptr in_list, MEMptr *syn_list, MEMptr *data_list));
extern long NFMSdisplay_labels __NFMS((MEMptr in_list, MEMptr *syn_list, MEMptr *data_list));
extern long NFMSdisplay_master __NFMS((MEMptr in_list));

/* NFMSerr_buff.c */
extern long NFMSbuild_error_buffer __NFMS((MEMptr *error_list));

/* NFMSerr_ums.c */
extern long NFMSerror_status_buffer __NFMS((MEMptr *err_status));
extern long NFMSerror_csd_buffer __NFMS((MEMptr *err_csd));

/* NFMSerror.c */
extern int _NFMS_num __NFMS((char *str, long var));
extern int _NFMS_str __NFMS((char *str, char *var));

/* NFMSfile_inf.c */
extern long NFMSdefine_file_information __NFMS((MEMptr in_list));
extern long NFMSget_file_information __NFMS((MEMptr in_list));
extern long NFMSreset_file_information __NFMS((MEMptr in_list));

/* NFMSflg_item.c */
extern long NFMSflag_item_archive __NFMS((MEMptr in_list));
extern long NFMSflag_item_backup __NFMS((MEMptr in_list));
extern long NFMSflag_item_restore __NFMS((MEMptr in_list));
extern long NFMSflag_item_delete __NFMS((MEMptr in_list));

/* NFMSflg_proj.c */
extern long NFMSflag_project_archive __NFMS((MEMptr in_list));
extern long NFMSflag_project_backup __NFMS((MEMptr in_list));
extern long NFMSflag_project_restore __NFMS((MEMptr in_list));

/* NFMSflg_set.c */
extern long NFMSflag_set_archive __NFMS((MEMptr in_list));
extern long NFMSflag_set_backup __NFMS((MEMptr in_list));
extern long NFMSflag_set_restore __NFMS((MEMptr in_list));

/* NFMSget_bulk.c */
extern long NFMSget_bulk_data __NFMS((MEMptr in_list));

/* NFMSget_udef.c */
extern long NFMSget_user_defaults __NFMS((MEMptr in_list));
extern long NFMSread_user_defaults __NFMS((MEMptr in_list));

/* NFMSitem_t.c */
extern long NFMSget_item_no __NFMS((MEMptr in_list));
extern long NFMSget_item_name __NFMS((MEMptr in_list));
extern long NFMScheck_co_status __NFMS((MEMptr in_list));

/* NFMSlItmTape.c */
extern long NFMSlist_items_on_tape __NFMS((MEMptr in_list, MEMptr *out_list));

/* NFMSlSaveset.c */
extern long NFMSlist_savesets __NFMS((MEMptr in_list, MEMptr *out_list));

/* NFMSlfm.c */
extern long NFMSlfm_information __NFMS((MEMptr in_list));
extern long NFMSlfm_update __NFMS((MEMptr in_list));

/* NFMSload_wf.c */
extern long NFMSload_workflow __NFMS((MEMptr in_list));

/* NFMSlock.c */
extern long NFMSlock_item __NFMS((MEMptr in_list));
extern long NFMSunlock_item __NFMS((MEMptr in_list));

/* NFMSlog_in.c */
extern long NFMSlog_in __NFMS((MEMptr in_list));

/* NFMSlogin.c */
extern long NFMSlogin __NFMS((MEMptr in_list));
extern long NFMSquery_login_attributes __NFMS((MEMptr in_list));

/* NFMSlogout.c */
extern long NFMSlogout __NFMS((MEMptr in_list));

/* NFMSmaint.c */
extern long NFMSquery_savesets_to_delete __NFMS((MEMptr in_list));
extern long NFMSdelete_savesets __NFMS((MEMptr in_list));
extern long NFMSquery_archives_to_delete __NFMS((MEMptr in_list));
extern long NFMSdelete_archives __NFMS((MEMptr in_list));

/* NFMSmod_acl.c */
extern long NFMSquery_acl_class_users __NFMS((MEMptr in_list));
extern long NFMSupdate_acl_class_users __NFMS((MEMptr in_list));
extern long NFMSdelete_acl __NFMS((MEMptr in_list));

/* NFMSmod_i_wf.c */
extern long NFMSget_wf_and_completed_acl_list __NFMS((MEMptr in_list));
extern long NFMSget_state_list_for_workflow __NFMS((MEMptr in_list));
extern long NFMSchange_wf_item __NFMS((MEMptr in_list));

/* NFMSnci_item.c */
extern long NFMScheckin_item __NFMS((MEMptr in_list));

/* NFMSnci_set.c */
extern long NFMScheckin_set __NFMS((MEMptr in_list));

/* NFMSnco_item.c */
extern long NFMScheckout_item __NFMS((MEMptr in_list));

/* NFMSnco_set.c */
extern long NFMScheckout_set __NFMS((MEMptr in_list));

/* NFMSncp_item.c */
extern long NFMScopy_item_files __NFMS((MEMptr in_list));
extern long NFMScopy_item_n __NFMS((MEMptr in_list));

/* NFMSncp_set.c */
extern long NFMScopy_set_files __NFMS((MEMptr in_list));

/* NFMSnode_t.c */
extern long NFMSget_node_no __NFMS((MEMptr in_list));
extern long NFMSget_node_name __NFMS((MEMptr in_list));

/* NFMSplt_item.c */
extern long NFMSplot_item __NFMS((MEMptr in_list));

/* NFMSplt_set.c */
extern long NFMSplot_set __NFMS((MEMptr in_list));

/* NFMSpr_util.c */
extern long NFMSarchive_files __NFMS((MEMptr in_list));
extern long NFMSbackup_files __NFMS((MEMptr in_list));
extern long NFMSrestore_files __NFMS((MEMptr in_list));
extern long NFMSdelete_files __NFMS((MEMptr in_list));

/* NFMSprog_t.c */
extern long NFMSget_program_no __NFMS((MEMptr in_list));
extern long NFMSget_program_name __NFMS((MEMptr in_list));

/* NFMSproj_map.c */
extern long NFMSquery_project_acl_map __NFMS((MEMptr in_list));
extern long NFMSupdate_project_acl_map __NFMS((MEMptr in_list));
extern long NFMSquery_project_sa_map __NFMS((MEMptr in_list));
extern long NFMSupdate_project_sa_map __NFMS((MEMptr in_list));

/* NFMSproj_t.c */
extern long NFMSget_project_no __NFMS((MEMptr in_list));
extern long NFMSget_project_name __NFMS((MEMptr in_list));

/* NFMSq_can.c */
extern long NFMSquery_cancel_archive __NFMS((MEMptr in_list, MEMptr *out_list));
extern long NFMSquery_cancel_backup __NFMS((MEMptr in_list, MEMptr *out_list));
extern long NFMSquery_cancel_restore __NFMS((MEMptr in_list, MEMptr *out_list));
extern long NFMSquery_cancel_delete __NFMS((MEMptr in_list, MEMptr *out_list));

/* NFMSq_cat.c */
extern long NFMSquery_catalog_attributes __NFMS((MEMptr in_list));
extern long NFMSquery_catalog_template __NFMS((MEMptr in_list));
extern long NFMSquery_catalog_template_n __NFMS((MEMptr in_list));
extern long NFMSquery_catalog_definition __NFMS((MEMptr in_list));

/* NFMSq_chgcat.c */
extern long NFMSquery_change_catalog_attributes __NFMS((MEMptr in_list));
extern long NFMSquery_changeto_loc_attributes __NFMS((MEMptr in_list));

/* NFMSq_chgnod.c */
extern long NFMSquery_change_node_attributes __NFMS((MEMptr in_list));

/* NFMSq_chgsa.c */
extern long NFMSquery_change_sa_attributes __NFMS((MEMptr in_list));

/* NFMSq_chgtab.c */
extern long NFMSquery_change_table_attributes __NFMS((MEMptr in_list, MEMptr *out_list));

/* NFMSq_chgtmp.c */
extern long NFMSquery_change_template_attributes __NFMS((MEMptr in_list));

/* NFMSq_chgusr.c */
extern long NFMSquery_change_user_attributes __NFMS((MEMptr in_list));

/* NFMSq_flag.c */
extern long NFMSquery_flag_archive __NFMS((MEMptr in_list));
extern long NFMSquery_flag_backup __NFMS((MEMptr in_list));
extern long NFMSquery_flag_restore __NFMS((MEMptr in_list));
extern long NFMSnew_query_flag_restore __NFMS((MEMptr in_list));
extern long NFMSquery_flag_delete __NFMS((MEMptr in_list));

/* NFMSq_item.c */
extern long NFMSquery_add_item_attributes __NFMS((MEMptr in_list));
extern long NFMSquery_item_attributes __NFMS((MEMptr in_list));
extern long NFMSget_item_attr_for_copy __NFMS((MEMptr in_list));

/* NFMSq_loc.c */
extern long NFMSquery_addto_loc_attributes __NFMS((MEMptr in_list));
extern long NFMSquery_loc_definition __NFMS((MEMptr in_list));

/* NFMSq_set.c */
extern long NFMSquery_add_set_attributes __NFMS((MEMptr in_list));
extern long NFMSquery_set_members __NFMS((MEMptr in_list));
extern long NFMSqry_set_members __NFMS((MEMptr in_list));

/* NFMSq_tab.c */
extern long NFMSquery_table_attributes __NFMS((MEMptr in_list));
extern long NFMSquery_table_template __NFMS((MEMptr in_list));
extern long NFMSquery_table_definition __NFMS((MEMptr in_list));

/* NFMSq_tmp.c */
extern long NFMSquery_template_attributes __NFMS((MEMptr in_list));
extern long NFMSquery_template_definition __NFMS((MEMptr in_list));

/* NFMSq_util.c */
extern long NFMSquery_archive __NFMS((MEMptr in_list));
extern long NFMSquery_backup __NFMS((MEMptr in_list));
extern long NFMSquery_restore __NFMS((MEMptr in_list));
extern long NFMSquery_delete __NFMS((MEMptr in_list));

/* NFMSquery.c */
extern long NFMSdefine_query __NFMS((MEMptr in_list));
extern long NFMSdelete_query __NFMS((MEMptr in_list));
extern long NFMSretrieve_query __NFMS((MEMptr in_list));
extern long NFMSretrieve_query_info __NFMS((MEMptr in_list));

/* NFMSrev_st.c */
extern long NFMSreview_state __NFMS((MEMptr in_list));

/* NFMSsa_t.c */
extern long NFMSget_sa_no __NFMS((MEMptr in_list));
extern long NFMSget_sa_name __NFMS((MEMptr in_list));
extern long NFMSget_sa_no_info __NFMS((MEMptr in_list));

/* NFMSserver.c */
extern int main __NFMS((int argc, char *argv[]));
extern int Signal_function __NFMS((int sig));

/* NFMSset_inf.c */
extern long NFMSdefine_set_information __NFMS((MEMptr in_list));
extern long NFMSget_set_messages __NFMS((MEMptr in_list));

/* NFMSset_st.c */
extern long NFMSset_to_state __NFMS((MEMptr in_list));
extern long NFMSset_wf_state __NFMS((MEMptr in_list));

/* NFMSset_udef.c */
extern long NFMSset_user_defaults __NFMS((MEMptr in_list));
extern long NFMSwrite_user_defaults __NFMS((MEMptr in_list));

/* NFMSsignoff.c */
extern long NFMSquery_acl_signoff_users __NFMS((MEMptr in_list));
extern long NFMSupdate_acl_signoff_users __NFMS((MEMptr in_list));
extern long NFMSsignoff __NFMS((MEMptr in_list));
extern long NFMSquery_signoff_attributes __NFMS((MEMptr in_list));
extern long NFMSpurge_signoff __NFMS((MEMptr in_list));

/* NFMSsnd_buff.c */
extern long NFMSsend_error_buffers __NFMS((long status1, long status2));
extern long NFMSsend_one_buffer __NFMS((long cmd_status, MEMptr buffer1));
extern long NFMSsend_two_buffers __NFMS((long cmd_status, MEMptr buffer1, MEMptr buffer2));
extern long NFMSsend_three_buffers __NFMS((long cmd_status, MEMptr buffer1, MEMptr buffer2, MEMptr buffer3));
extern long NFMSsend_four_buffers __NFMS((long cmd_status, MEMptr buffer1, MEMptr buffer2, MEMptr buffer3, MEMptr buffer4));
extern long NFMSsend_five_buffers __NFMS((long cmd_status, MEMptr buffer1, MEMptr buffer2, MEMptr buffer3, MEMptr buffer4, MEMptr buffer5));
extern long NFMSsend_six_buffers __NFMS((long cmd_status, MEMptr buffer1, MEMptr buffer2, MEMptr buffer3, MEMptr buffer4, MEMptr buffer5, MEMptr buffer6));
extern long NFMSsend_end_buffer __NFMS((long cmd_status));

/* NFMSsqlquery.c */
extern long NFMSsqlquery __NFMS((MEMptr in_list));
extern long NFMSsqlquery_cursor __NFMS((MEMptr in_list));

/* NFMSsqlstmt.c */
extern long NFMSsqlstmt __NFMS((MEMptr in_list));

/* NFMSsr_a_cat.c */
extern long NFMSmultiple_catalog_search __NFMS((MEMptr in_list));
extern long NFMSblock_multiple_catalog_search __NFMS((MEMptr in_list));
extern long NFMSblock_multi_cat_srch_m_crsr __NFMS((MEMptr in_list));

/* NFMSstate_t.c */
extern long NFMSget_state_no __NFMS((MEMptr in_list));
extern long NFMSget_state_name __NFMS((MEMptr in_list));

/* NFMSsv_files.c */
extern long NFMSsave_item_files __NFMS((MEMptr in_list));

/* NFMSsv_sfile.c */
extern long NFMSsave_set_files __NFMS((MEMptr in_list));

/* NFMSswitch.c */
extern long NFMswitch_command __NFMS((long in_command, MEMptr in_list));

/* NFMStab_t.c */
extern long NFMSget_table_no __NFMS((MEMptr in_list));
extern long NFMSget_table_name __NFMS((MEMptr in_list));

/* NFMStools.c */
extern int NFMconsole __NFMS((char *mess));
extern int NFMfree_list __NFMS((char **data_list, int num_rows, int num_cols));
extern int NFMput_string __NFMS((char **to_string, char *string));
extern int NFMvalidate_string __NFMS((char *dtype, char *string));
extern int NFMput_buf_string __NFMS((char **to_string, char *string, int len));
extern int NFMput_and_validate_data __NFMS((char **data, int initial, int limit, int increment));
extern int NFMget_dtype_len __NFMS((char *data_ptr1, char *data_ptr2, int *len));

/* NFMStrans.c */
extern long NFMSquery_make_transition __NFMS((MEMptr in_list));
extern long NFMSmake_transition __NFMS((MEMptr in_list));

/* NFMSupd_proj.c */
extern long NFMSquery_project_members __NFMS((MEMptr in_list));
extern long NFMSupdate_project_members __NFMS((MEMptr in_list));
extern long NFMSqry_items_in_cat_for_project __NFMS((MEMptr in_list));
extern long NFMSqry_project_members __NFMS((MEMptr in_list));

/* NFMSupd_set.c */
extern long NFMSupdate_set_members __NFMS((MEMptr in_list));

/* NFMSupd_st.c */
extern long NFMSupdate_state __NFMS((MEMptr in_list));
extern long NFMSquery_states __NFMS((MEMptr in_list));

/* NFMSupdate.c */
extern long NFMSprepare_update_item __NFMS((MEMptr in_list));
extern long NFMScancel_update_item __NFMS((MEMptr in_list));
extern long NFMSupdate_item __NFMS((MEMptr in_list));

/* NFMSuser_def.c */
extern long NFMSupdate_user_defaults __NFMS((MEMptr in_list));
extern long NFMSquery_user_defaults __NFMS((MEMptr in_list));

/* NFMSuser_t.c */
extern long NFMSget_user_no __NFMS((MEMptr in_list));
extern long NFMSget_user_name __NFMS((MEMptr in_list));

/* NFMSutil_upd.c */
extern long NFMSutilities_update __NFMS((MEMptr in_list));

/* NFMSval_info.c */
extern long NFMSvalidate_info __NFMS((MEMptr in_list));

/* NFMSvalid.c */
extern long NFMSvalidate_user_access __NFMS((MEMptr in_list));

/* NFMSversions.c */
extern long NFMSpurge_versions __NFMS((MEMptr in_list));
extern long NFMSget_item_versions __NFMS((MEMptr in_list));
extern long NFMSroll_version_forward __NFMS((MEMptr in_list));

/* NFMSwf_t.c */
extern long NFMSget_workflow_no __NFMS((MEMptr in_list));
extern long NFMSget_workflow_name __NFMS((MEMptr in_list));

#undef __NFMS

#endif
