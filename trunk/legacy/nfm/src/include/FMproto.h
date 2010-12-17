#ifndef FM_PROTO_H
#define FM_PROTO_H

#if defined(__STDC__) || defined(__cplusplus)
# define __FM(s) s
#else
# define __FM(s) ()
#endif


/* FMacl_t.c */
extern long NFAfill_free_list __FM((MEMptr value_list, struct SCfree_data_st *struct_data));
extern long NFAfill_free_data_list __FM((MEMptr data_list, MEMptr value_list, int data_col, struct SCfree_data_st *struct_data));
extern long NFAexclusive_fill_free_list __FM((MEMptr data_list, MEMptr value_list, int data_col, struct SCfree_data_st *struct_data));
extern long NFAfind_acl_name __FM((char *acl_name));
extern long NFAget_value_list_index __FM((char *list_num, MEMptr value_list, char *attr_name, char *synonym, char *index_num));
extern long NFAget_value_list_buffer __FM((char *list_num, MEMptr value_list, char *attr_name, char *synonym, MEMptr *buffer));
extern long NFAget_value_list_name __FM((char *list_num, MEMptr value_list, char *index_num, char *name));
extern long NFAoverride_power __FM((char *user_name, char *state_name, char *override));
extern long NFAfill_data_list __FM((MEMptr attr_list, MEMptr data_list, MEMptr value_list, struct SCfree_data_st *struct_data));
extern long NFAget_value_list_string __FM((char *column_name, char *index_num, MEMptr value_list, char *list_num, char *string));

/* FMact_data.c */
extern int define_active_data __FM((void));

/* FMactivate.c */
extern long NFAactivate_project __FM((void));
extern long NFAactivate_catalog __FM((void));
extern long NFAactivate_item __FM((void));
extern long NFAactivate_set __FM((void));
extern long NFAactivate_workflow __FM((void));
extern long NFAactivate_acl __FM((void));
extern long NFAactivate_node __FM((void));
extern long NFAactivate_sa __FM((void));
extern long NFAactivate_user __FM((void));
extern long NFAactivate_wa __FM((void));

/* FMadd_acl.c */
extern long add_acl __FM((char *acl_name, char *wf_name));

/* FMadd_files.c */
extern long add_files_to_item __FM((void));

/* FMadd_mem.c */
extern long add_members __FM((void));

/* FMcan_item.c */
extern long cancel_checkout_item __FM((void));

/* FMcan_itmflg.c */
extern long cancel_item_archive_flag __FM((void));
extern long cancel_item_backup_flag __FM((void));
extern long cancel_item_restore_flag __FM((void));
extern long cancel_item_delete_flag __FM((void));

/* FMcan_prjflg.c */
extern long cancel_project_archive_flag __FM((void));
extern long cancel_project_backup_flag __FM((void));
extern long cancel_project_restore_flag __FM((void));

/* FMcan_set.c */
extern long cancel_checkout_set __FM((void));

/* FMcan_setflg.c */
extern long cancel_set_archive_flag __FM((void));
extern long cancel_set_backup_flag __FM((void));
extern long cancel_set_restore_flag __FM((void));

/* FMcat.c */
extern long create_catalog __FM((void));
extern long delete_catalog __FM((void));

/* FMcat_map.c */
extern long add_catalog_acl_map __FM((void));
extern long delete_catalog_acl_map __FM((void));
extern long add_catalog_sa_map __FM((void));
extern long delete_catalog_sa_map __FM((void));

/* FMcheckin.c */
extern long checkin_item __FM((void));

/* FMcheckout.c */
extern long checkout_item __FM((void));

/* FMchg_cat.c */
extern long change_catalog __FM((void));

/* FMchg_files.c */
extern long change_file_attributes __FM((void));

/* FMchg_node.c */
extern long change_node __FM((void));

/* FMchg_tab.c */
extern long change_table __FM((char *table_name, char *table_type));

/* FMcommands.c */
extern NFMfunction nfm_debug_on __FM((void));
extern NFMfunction nfm_debug_off __FM((void));
extern NFMfunction nfm_server_debug_on __FM((void));
extern NFMfunction nfm_server_debug_off __FM((void));
extern NFMfunction nfm_client_debug_on __FM((void));
extern NFMfunction nfm_client_debug_off __FM((void));
extern NFMfunction nfm_print_file __FM((void));
extern NFMfunction nfm_catalog __FM((void));
extern int NFAalpha_validate_user_access __FM((long user_id, char *command, char *workflow, char *project, char *catalog, char *item, char *revision));
extern int NFAalpha_set_to_state __FM((long error_number, char *error_message));
extern NFMfunction nfm_add_node __FM((void));
extern NFMfunction nfm_delete_node __FM((void));
extern NFMfunction nfm_change_node __FM((void));
extern NFMfunction nfm_display_nodes __FM((void));
extern NFMfunction nfm_add_sa __FM((void));
extern NFMfunction nfm_delete_storage_area __FM((void));
extern NFMfunction nfm_change_sa __FM((void));
extern NFMfunction nfm_change_sa_passwd __FM((void));
extern NFMfunction nfm_change_wa_passwd __FM((void));
extern NFMfunction nfm_add_user __FM((void));
extern NFMfunction nfm_delete_user __FM((void));
extern NFMfunction nfm_change_user __FM((void));
extern NFMfunction nfm_change_user_passwd __FM((void));
extern NFMfunction nfm_change_self_passwd __FM((void));
extern NFMfunction nfm_define_active_data __FM((void));
extern NFMfunction nfm_add_project __FM((void));
extern NFMfunction nfm_delete_project __FM((void));
extern NFMfunction nfm_change_project __FM((void));
extern NFMfunction nfm_add_project_acl_map __FM((void));
extern NFMfunction nfm_delete_project_acl_map __FM((void));
extern NFMfunction nfm_add_project_sa_map __FM((void));
extern NFMfunction nfm_delete_project_sa_map __FM((void));
extern NFMfunction nfm_display_project_members __FM((void));
extern NFMfunction nfm_add_project_members __FM((void));
extern NFMfunction nfm_delete_project_members __FM((void));
extern NFMfunction nfm_create_catalog __FM((void));
extern NFMfunction nfm_change_catalog __FM((void));
extern NFMfunction nfm_delete_catalog __FM((void));
extern NFMfunction nfm_add_catalog_acl_map __FM((void));
extern NFMfunction nfm_delete_catalog_acl_map __FM((void));
extern NFMfunction nfm_add_catalog_sa_map __FM((void));
extern NFMfunction nfm_delete_catalog_sa_map __FM((void));
extern NFMfunction nfm_add_item __FM((void));
extern NFMfunction nfm_add_files_to_item __FM((void));
extern NFMfunction nfm_delete_files_from_item __FM((void));
extern NFMfunction nfm_change_file_attributes __FM((void));
extern NFMfunction nfm_display_where_used_set __FM((void));
extern NFMfunction nfm_display_where_used_project __FM((void));
extern NFMfunction nfm_update_item __FM((void));
extern NFMfunction nfm_delete_item __FM((void));
extern NFMfunction nfm_lock_item __FM((void));
extern NFMfunction nfm_unlock_item __FM((void));
extern NFMfunction nfm_purge_item_versions __FM((void));
extern NFMfunction nfm_roll_version_forward __FM((void));
extern NFMfunction nfm_display_set_members __FM((void));
extern NFMfunction nfm_add_set_item __FM((void));
extern NFMfunction nfm_checkin __FM((void));
extern NFMfunction nfm_checkout __FM((void));
extern NFMfunction nfm_copy_item __FM((void));
extern NFMfunction nfm_copy_files __FM((void));
extern NFMfunction nfm_delete_copied_files __FM((void));
extern NFMfunction nfm_cancel_checkout __FM((void));
extern NFMfunction nfm_add_members __FM((void));
extern NFMfunction nfm_delete_members __FM((void));
extern NFMfunction nfm_display_archive_flags __FM((void));
extern NFMfunction nfm_archive __FM((void));
extern NFMfunction nfm_display_backup_flags __FM((void));
extern NFMfunction nfm_backup __FM((void));
extern NFMfunction nfm_display_restore_flags __FM((void));
extern NFMfunction nfm_restore __FM((void));
extern NFMfunction nfm_display_delete_flags __FM((void));
extern NFMfunction nfm_maintain_saveset __FM((void));
extern NFMfunction nfm_maintain_flags __FM((void));
extern NFMfunction nfm_list_savesets __FM((void));
extern NFMfunction nfm_list_items_on_tape __FM((void));
extern NFMfunction nfm_check_set_in __FM((void));
extern NFMfunction nfm_check_set_out __FM((void));
extern NFMfunction nfm_copy_set_item_files __FM((void));
extern NFMfunction nfm_cancel_checkout_set __FM((void));
extern NFMfunction nfm_flag_item_archive __FM((void));
extern NFMfunction nfm_flag_item_backup __FM((void));
extern NFMfunction nfm_flag_item_restore __FM((void));
extern NFMfunction nfm_flag_item_delete __FM((void));
extern NFMfunction nfm_cancel_item_archive_flag __FM((void));
extern NFMfunction nfm_cancel_item_backup_flag __FM((void));
extern NFMfunction nfm_cancel_item_restore_flag __FM((void));
extern NFMfunction nfm_cancel_item_delete_flag __FM((void));
extern NFMfunction nfm_flag_set_archive __FM((void));
extern NFMfunction nfm_flag_set_backup __FM((void));
extern NFMfunction nfm_flag_set_restore __FM((void));
extern NFMfunction nfm_cancel_set_archive_flag __FM((void));
extern NFMfunction nfm_cancel_set_backup_flag __FM((void));
extern NFMfunction nfm_cancel_set_restore_flag __FM((void));
extern NFMfunction nfm_flag_project_archive __FM((void));
extern NFMfunction nfm_flag_project_backup __FM((void));
extern NFMfunction nfm_flag_project_restore __FM((void));
extern NFMfunction nfm_cancel_project_archive_flag __FM((void));
extern NFMfunction nfm_cancel_project_backup_flag __FM((void));
extern NFMfunction nfm_cancel_project_restore_flag __FM((void));
extern NFMfunction nfm_make_transition __FM((void));
extern NFMfunction nfm_add_acl __FM((void));
extern NFMfunction nfm_add_acl_users __FM((void));
extern NFMfunction nfm_delete_acl __FM((void));
extern NFMfunction nfm_delete_acl_users __FM((void));
extern NFMfunction nfm_add_signoff_users __FM((void));
extern NFMfunction nfm_delete_signoff_users __FM((void));
extern NFMfunction nfm_load_workflow __FM((void));
extern NFMfunction nfm_define_search __FM((void));
extern NFMfunction nfm_delete_search __FM((void));
extern NFMfunction nfm_define_sort __FM((void));
extern NFMfunction nfm_delete_sort __FM((void));
extern NFMfunction nfm_signoff __FM((void));
extern NFMfunction nfm_purge_signoff __FM((void));
extern NFMfunction nfm_display_storage_areas __FM((void));
extern NFMfunction nfm_display_working_areas __FM((void));
extern NFMfunction nfm_display_users __FM((void));
extern NFMfunction nfm_display_catalogs __FM((void));
extern NFMfunction nfm_display_items __FM((void));
extern NFMfunction nfm_display_item_files __FM((void));
extern NFMfunction nfm_display_workflows __FM((void));
extern NFMfunction nfm_display_acls __FM((void));
extern NFMfunction nfm_display_aclusers __FM((void));
extern NFMfunction nfm_display_classes __FM((void));
extern NFMfunction nfm_display_search __FM((void));
extern NFMfunction nfm_display_sort __FM((void));
extern NFMfunction nfm_display_signoff_users __FM((void));
extern NFMfunction nfm_display_so_on_item __FM((void));
extern NFMfunction nfm_display_so_history __FM((void));
extern NFMfunction nfm_display_projects __FM((void));
extern NFMfunction nfm_display_catalog_acl_mapping __FM((void));
extern NFMfunction nfm_display_catalog_sa_mapping __FM((void));
extern NFMfunction nfm_display_project_acl_mapping __FM((void));
extern NFMfunction nfm_display_project_sa_mapping __FM((void));
extern NFMfunction nfm_display_sets __FM((void));
extern NFMfunction nfm_display_archives __FM((void));
extern NFMfunction nfm_test_messages __FM((void));
extern NFMfunction nfm_display_local_files __FM((void));
extern NFMfunction nfm_begin_record __FM((void));
extern NFMfunction nfm_end_record __FM((void));
extern NFMfunction nfm_begin_playback __FM((void));

/* FMcopy.c */
extern long copy_item __FM((void));

/* FMcp_files.c */
extern long copy_files __FM((void));
extern long delete_copied_files __FM((void));

/* FMd_choose.c */
extern long NFAdisplay_elements __FM((struct SCfree_data_st *struct_data, NFMlist list_struct));
extern long NFAget_display_information __FM((NFMlist list, MEMptr *syn_list, MEMptr *data_list));
extern long NFAnew_display_simple_data __FM((struct SCfree_data_st *struct_data, MEMptr syn_list, MEMptr data_list, int select_set, char *title));

/* FMdebug.c */
extern long debug_on __FM((void));
extern long debug_off __FM((void));
extern long server_debug_on __FM((void));
extern long client_debug_on __FM((void));
extern long server_debug_off __FM((void));
extern long client_debug_off __FM((void));
extern long catalog __FM((void));
extern long print_file __FM((void));
extern long test_messages __FM((void));

/* FMdef_search.c */
extern long define_search __FM((void));

/* FMdef_sort.c */
extern long define_sort __FM((void));

/* FMdel_files.c */
extern long delete_files_from_item __FM((void));

/* FMdel_mem.c */
extern long delete_members __FM((void));

/* FMdelete.c */
extern long delete_node __FM((void));
extern long delete_storage_area __FM((void));
extern long delete_user __FM((void));
extern long delete_search __FM((void));
extern long delete_sort __FM((void));
extern long purge_signoff __FM((void));
extern long delete_acl __FM((void));

/* FMdisplays.c */
extern long display_nodes __FM((void));
extern long display_nodes_short __FM((void));
extern long display_storage_areas __FM((void));
extern long display_storage_areas_short __FM((void));
extern long display_working_areas __FM((void));
extern long display_users __FM((void));
extern long display_users_short __FM((void));
extern long display_catalogs __FM((void));
extern long display_catalogs_short __FM((void));
extern long display_items __FM((void));
extern long display_items_short __FM((void));
extern long display_item_files __FM((void));
extern long display_where_used_set __FM((void));
extern long display_where_used_project __FM((void));
extern long display_workflows __FM((void));
extern long display_workflows_short __FM((void));
extern long display_acls __FM((void));
extern long display_acls_short __FM((void));
extern long display_classes __FM((void));
extern long display_classes_short __FM((void));
extern long display_search __FM((void));
extern long display_sort __FM((void));
extern long display_programs __FM((void));
extern long display_transitions __FM((void));
extern long display_transitions_short __FM((void));
extern long display_aclusers __FM((void));
extern long display_signoff_users __FM((void));
extern long display_projects __FM((void));
extern long display_project_members __FM((void));
extern long display_catalog_acl_mapping __FM((void));
extern long display_catalog_sa_mapping __FM((void));
extern long display_project_acl_mapping __FM((void));
extern long display_project_sa_mapping __FM((void));
extern long display_sets __FM((void));
extern long display_set_members __FM((void));
extern long display_signoff_on_item __FM((void));
extern long display_signoff_history __FM((void));
extern long display_archives __FM((void));
extern long display_archive_flags __FM((void));
extern long display_backup_flags __FM((void));
extern long display_restore_flags __FM((void));
extern long display_delete_flags __FM((void));
extern long display_local_files __FM((void));

/* FMenter.c */
extern int nfm_enter __FM((char *cmd_line_server, char *cmd_line_env, char *cmd_line_user, char *cmd_line_passwd, char *exec_path));

/* FMerr_ret.c */
extern long NFAcreate_error_form __FM((struct SCcolumn_data_st *struct_data));

/* FMexit.c */
extern int nfm_exit __FM((void));

/* FMflag_item.c */
extern long flag_item_archive __FM((void));
extern long flag_item_backup __FM((void));
extern long flag_item_restore __FM((void));
extern long flag_item_delete __FM((void));
extern long NFAprepare_error_form __FM((struct SCfree_data_st data_data, struct SCfree_data_st *struct_data, int count, char *title));

/* FMflag_proj.c */
extern long flag_project_archive __FM((void));
extern long flag_project_backup __FM((void));
extern long flag_project_restore __FM((void));

/* FMflag_set.c */
extern long flag_set_archive __FM((void));
extern long flag_set_backup __FM((void));
extern long flag_set_restore __FM((void));

/* FMfunctions.c */
extern long NFAget_st_area_name __FM((char *storage_name));
extern long NFAget_storage_info __FM((char *storage_num, char *storage_name, char *temp_node, char *temp_user, char *temp_passwd, char *temp_path, int mode));
extern long NFAget_node_info __FM((char *node_name, char *node_num));
extern long NFAget_search_name __FM((char *search_name));
extern long NFAconfirm __FM((char *title, int *confirmed));
extern long NFAcol_width __FM((char *data_ptr1, char *data_ptr2, int *max_len));
extern long NFAget_dtype_len __FM((char *data_ptr1, char *data_ptr2, int *len));
extern long NFAdtype_length __FM((char *data_ptr, int *len));
extern long NFAfind_len __FM((char **data_ptr, int column_ptr, NDXptr index, int rows, int cols, int *max_attr_len, int *max_syn_len, int *max_dtype_len));
extern long NFAfind_new_len __FM((char **data_ptr, int column_ptr, NDXnewptr index, int rows, int cols, int *max_attr_len, int *max_syn_len, int *max_dtype_len));
extern long NFAfind_max_len __FM((char **column_ptr, char **format_ptr, char **data_ptr, int cols, int *max_col_len, int *max_dtype_len));
extern long NFAfind_max_data_len __FM((char **column_ptr, char **data_ptr, int start, int cols, int rows, int *max_data_len));
extern long NFAvalidate_data_type __FM((char *data_type));
extern long NFAfill_list_struct __FM((NFMlist *list, int rep_type, int select_set, int select_type, char *search_str, char *sort_str, char *catalog, char *item, char *rev, char *workflow, char *acl, char *title));
extern long NFAfree_list_struct __FM((NFMlist *list));
extern long NFAvalidate_nulls __FM((MEMptr attr_list, NDXptr index, struct SCcolumn_data_st data, int pos, int *filled));
extern long NFAvalidate_member_type __FM((char *type));
extern long NFAvalidate_proj_member_type __FM((char *type));
extern long NFAget_server_name __FM((MEMptr server_list, char *server_name));
extern long NFAget_env_name __FM((MEMptr env_list, char *env_name));
extern long NFAvalidate_env_name __FM((MEMptr env_list, char *env_name));
extern long NFAget_user_variables __FM((MEMptr *user_var_list));
extern long NFMRset_error __FM((long status, char *message));
extern int lowcase __FM((char *str));
extern long NFAget_date_len __FM((char *data_ptr1, int *len));
extern long NFAset_global_config_info __FM((int wf_use, char *command, char *wf_name, char *project_name, char *application));
extern long NFAalpha_defaults_logout __FM((MEMptr *logout_defaults));
extern long NFAalpha_defaults_login __FM((MEMptr login_defaults));

/* FMglobals.c */

/* FMitem.c */
extern long add_item __FM((void));
extern long delete_item __FM((void));

/* FMlItmTape.c */
extern long list_items_on_tape __FM((void));

/* FMlSaveset.c */
extern long list_savesets __FM((void));

/* FMload_wf.c */
extern long load_workflow __FM((void));

/* FMlock.c */
extern long lock_item __FM((void));
extern long unlock_item __FM((void));

/* FMlogin.c */
extern long nfm_login __FM((char *server, char *cmd_line_env, char *cmd_line_user, char *cmd_line_passwd, int login_count));
extern long NFAget_user_pwd __FM((char *user, char *passwd));

/* FMlogout.c */
extern int logout __FM((void));

/* FMmaint.c */
extern int maintain_flags __FM((void));
extern int maintain_saveset __FM((void));

/* FMmake_trans.c */
extern long make_transition __FM((void));

/* FMmod_acl.c */
extern long add_acl_users __FM((char *acl_name));
extern long delete_acl_users __FM((char *acl_name));

/* FMnode.c */
extern long add_node __FM((void));
extern long change_node __FM((void));

/* FMpasswd.c */
extern long change_user_passwd __FM((void));
extern long change_self_passwd __FM((void));
extern long change_sa_passwd __FM((void));
extern long change_wa_passwd __FM((void));

/* FMproj_map.c */
extern long add_project_acl_map __FM((void));
extern long delete_project_acl_map __FM((void));
extern long add_project_sa_map __FM((void));
extern long delete_project_sa_map __FM((void));

/* FMproj_mem.c */
extern long add_project_members __FM((void));
extern long delete_project_members __FM((void));

/* FMproject.c */
extern long add_project __FM((void));
extern long delete_project __FM((void));
extern long change_project __FM((void));

/* FMpur_vers.c */
extern long purge_versions __FM((void));

/* FMrap.c */
extern long begin_record __FM((void));
extern long end_record __FM((void));
extern long begin_playback __FM((void));

/* FMreview.c */
extern long review_item __FM((void));

/* FMroll_vers.c */
extern long roll_version_forward __FM((void));

/* FMsa.c */
extern long add_sa __FM((void));
extern long change_sa __FM((void));
extern long add_util_sa __FM((char *node_name, char *node_num));

/* FMsearch.c */
extern int NFAdefine_search __FM((char **search_string, MEMptr attr_buffer));

/* FMsearch_t.c */
extern long NFAsearch_attr_form __FM((struct SCfree_data_st *form, MEMptr attr_buffer));
extern long NFAsearch_oper1_form __FM((struct SCfree_data_st *form));
extern long NFAsearch_oper2_form __FM((struct SCfree_data_st *form));
extern long NFAsearch_form __FM((struct SCcolumn_data_st *form, int form_rows, int *old_tot_data));
extern long NFAreset_search_form __FM((struct SCcolumn_data_st *form, int form_rows, int *old_tot_data, int *new_tot_data));
extern long NFAclear_form_selects __FM((struct SCfree_data_st *form));
extern long NFAverify_row_selected __FM((struct SCfree_data_st form, int *select_index));
extern long NFAfind_report_name __FM((char *rep_type, char *rep_name, char *rep_desc));
extern long NFAfind_report_info __FM((char *rep_name, char *file_name));
extern long NFAsort_attr_form __FM((struct SCfree_data_st *form, MEMptr attr_buffer));

/* FMset.c */
extern long add_set_item __FM((void));

/* FMset_copy.c */
extern long copy_set_item_files __FM((void));

/* FMset_in.c */
extern long check_set_in __FM((void));

/* FMset_out.c */
extern long check_set_out __FM((void));

/* FMsign_users.c */
extern long add_signoff_users __FM((char *acl_name, int call_case));
extern long delete_signoff_users __FM((char *acl_name));

/* FMsignoff.c */
extern long signoff __FM((void));

/* FMsort.c */
extern int NFAdefine_sort __FM((char **sort_string, MEMptr attr_buffer));

/* FMsqlquery.c */
extern long sqlquery __FM((void));

/* FMsqlstmt.c */
extern long sqlstmt __FM((void));

/* FMstate.c */
extern long review_state __FM((void));

/* FMtools.c */
extern int NFAmake_msg __FM((char *mess));
extern int NFAfree_list __FM((char **data_list, int num_rows, int num_cols));
extern int NFAput_string __FM((char **to_string, char *string));
extern int NFAvalidate_string __FM((char *dtype, char *string));
extern int NFAvalidate_Y_or_N __FM((char *string));
extern int NFAvalidate_P_or_S __FM((char *string));
extern int NFAput_buf_string __FM((char **to_string, char *string, int len));
extern int NFAput_and_validate_data __FM((char **data, int initial, int limit, int increment));
extern int NFAdisplay_message_set __FM((char *title, MEMptr set_msg));

/* FMupd_item.c */
extern long update_item __FM((void));

/* FMuser.c */
extern long add_user __FM((void));
extern long change_user __FM((void));

/* FMutilities.c */
extern int create_archive __FM((void));
extern int create_backup __FM((void));
extern int create_restore __FM((void));

/* FMwh_used.c */
extern long where_used_set __FM((void));
extern long where_used_project __FM((void));

/* SCatofn.c */

#undef __FM

#endif
