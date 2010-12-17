#ifndef WF_PROTO_H
#define WF_PROTO_H

#if defined(__STDC__) || defined(__cplusplus)
# define __WF(s) s
#else
# define __WF(s) ()
#endif


/* NFMadd_act.c */
extern long NFMadd_activity_entry __WF((long user_id, char *app_name, MSGptr app_msg));

/* NFMaex_proc.c */
extern long NFMpost_execute_process __WF((long trans_no, MSGptr app_ptr));
extern long NFMget_context_info __WF((MEMptr *bufr, struct WFstruct WFinfo));

/* NFMbex_proc.c */
extern long NFMpre_execute_process __WF((long trans_no));

/* NFMqry_act.c */
extern long NFMquery_activity_attributes __WF((long user_id, MEMptr *attr_list, MEMptr *data_list));

/* NFMsend_ml.c */
extern long NFMsend_mail __WF((long user_id, char *app_name, MSGptr app_msg));

/* NFMsh_mem.c */
extern long NFMld_ctxt_shmem __WF((MEMptr buffer, int no_procs, char *NFMshmid));
extern long NFMload_mem_buffer __WF((MEMptr list, int no_procs, char *bufr));

/* NFMwf_tools.c */
extern long _NFMsearch_cmd_table_db __WF((char *cmd_name));
extern long _NFMsearch_state_table_db __WF((int state_no, char *state_name));
extern long WFload_acl __WF((long user_id, char *user_name, char *wf_name, char *acl_name));

/* WFaccess.c */
extern long WFquery_workflow_access __WF((long user_id, char *workflow_name, MEMptr *attr_list, MEMptr *data_list, MEMptr *value_list));
extern long WFupdate_workflow_access __WF((long user_id, MEMptr attr_list, MEMptr data_list));
extern long WFadd_workflow_access __WF((long user_id, MEMptr attr_list, MEMptr data_list));
extern long WFdrop_workflow_access __WF((long user_id, MEMptr attr_list, MEMptr data_list));
extern long WFset_access __WF((long user_id, MEMptr tr_attr, MEMptr tr_data, MEMptr cl_attr, MEMptr cl_data, MEMptr ac_attr, MEMptr ac_data));

/* WFacl_sign.c */
extern long WFquery_acl_signoff_users __WF((long user_id, char *acl_name, MEMptr *attr_list, MEMptr *data_list, MEMptr *value_list));
extern long WFupdate_acl_signoff_users __WF((long user_id, MEMptr attr_list, MEMptr data_list));
extern long WFadd_acl_signoff_users __WF((long user_id, MEMptr attr_list, MEMptr data_list));
extern long WFdrop_acl_signoff_users __WF((long user_id, MEMptr attr_list, MEMptr data_list));
extern long WFset_acl_signoff_users __WF((long user_id, char *wf_name, char *user_name, MEMptr attr_list, MEMptr data_list));

/* WFacl_users.c */
extern long WFquery_acl_class_users __WF((long user_id, char *acl_name, MEMptr *attr_list, MEMptr *data_list, MEMptr *value_list));
extern long WFupdate_acl_class_users __WF((long user_id, MEMptr attr_list, MEMptr data_list));
extern long WFadd_acl_class_users __WF((long user_id, MEMptr attr_list, MEMptr data_list));
extern long WFdrop_acl_class_users __WF((long user_id, MEMptr attr_list, MEMptr data_list));
extern long WFset_acl_class_users __WF((long user_id, char *wf_name, char *user_name, MEMptr attr_list, MEMptr data_list));

/* WFacls.c */
extern long WFquery_acl_attributes __WF((long user_id, MEMptr *attr_list, MEMptr *data_list, MEMptr *value_list));
extern long WFadd_acl __WF((long user_id, MEMptr attr_list, MEMptr data_list));
extern long WFset_acl __WF((long user_id, char *workflow_name, char *acl_name, MEMptr attr_list, MEMptr data_list));
extern long WFdrop_acl __WF((long user_id, char *acl_name));
extern long _WFdelete_acl __WF((long acl_no, long wf_no, char *wf_name));
extern long WFcheck_workflow_acl_inuse __WF((long user_id, long acl_no));
extern long WFcheck_catalog_acl_inuse __WF((long user_id, long acl_no));
extern long WFcheck_project_acl_inuse __WF((long user_id, long acl_no));
extern long WFcheck_item_acl_inuse __WF((long user_id, long acl_no));
extern long WFcheck_class_users_acl __WF((long user_id, long acl_no));
extern long WFcheck_signoff_users_acl __WF((long user_id, long acl_no));

/* WFclasses.c */
extern long WFquery_workflow_classes __WF((long user_id, char *workflow_name, MEMptr *attr_list, MEMptr *data_list, MEMptr *value_list));
extern long WFupdate_workflow_classes __WF((long user_id, MEMptr attr_list, MEMptr data_list));
extern long WFadd_workflow_classes __WF((long user_id, MEMptr attr_list, MEMptr data_list));
extern long WFdrop_workflow_classes __WF((long user_id, MEMptr attr_list, MEMptr data_list));
extern long WFload_classes_list __WF((long user_id, MEMptr attr_list, MEMptr data_list, char *inline));

/* WFcomm.c */
extern long WFload_commands __WF((long user_id, char *app_name, char *file_name));
extern long WFquery_commands __WF((long user_id, char *app_name, MEMptr *attr_list, MEMptr *data_list, MEMptr *value_list));
extern long WFupdate_commands __WF((long user_id, MEMptr attr_list, MEMptr data_list));
extern long WFadd_commands __WF((long user_id, MEMptr attr_list, MEMptr data_list));
extern long WFdrop_commands __WF((long user_id, MEMptr attr_list, MEMptr data_list));
extern long WFload_commands_list __WF((long user_id, char *app_name, MEMptr attr_list, MEMptr data_list, char *inline));

/* WFcopy.c */
extern long WFcopy_workflow_structure __WF((long user_id, long type, struct WFstruct *wf_str));

/* WFcopy_acl.c */
extern long NFMquery_acl_attributes_condition __WF((char *condition, MEMptr *attr_list, MEMptr *data_list, MEMptr *value_list));
extern long NFMget_acl_classes_for_copy __WF((char *old_aclname, long new_wfno, MEMptr *synonym_list, MEMptr *value_list));
extern long NFMcopy_acl_users __WF((char *new_aclname, long new_wfno, char *old_aclname, MEMptr synonym_list));

/* WFdb_tools.c */
extern long WFget_active_proj_no __WF((long *proj_no));
extern long WFget_command_no __WF((long *command_no));
extern long WFload_item_no __WF((long item_no));
extern long WFload_acl_st __WF((long acl_no));
extern long WFload_wf_struct_for_sts __WF((void));
extern long WFload_item_name __WF((char *item_name));
extern long WFload_item_rev __WF((char *item_rev));
extern long WFload_catalog_name __WF((char *catalog_name));
extern long WFload_catalog_no __WF((long catalog_no));
extern long WFload_wf_struct_using_from_and_to_state __WF((long fromstate, long tostate));

/* WFget_error.c */
extern long _WFget_error_info __WF((char *successfail, char *failreason, MSGptr app_msg));

/* WFinit.c */
extern long _NFMreload_nfm_workflows __WF((char *comm_filename, char *sdp_filename, char *admin_filename, char *cat_filename, char *proj_filename, char *item_filename));
extern long _NFMclean_workflows_from_schema __WF((void));
extern long _NFMinitialize_workflow __WF((char *comm_filename, char *sdp_filename, char *admin_filename, char *cat_filename, char *proj_filename, char *item_filename));
extern long _WFload_sdp_workflow __WF((char *file_name));
extern long _WFload_admin_workflow __WF((char *file_name));
extern long _WFload_catalog_workflow __WF((char *file_name));
extern long _WFload_project_workflow __WF((char *file_name));
extern long _WFload_item_workflow __WF((char *file_name));

/* WFload.c */
extern long WFload_workflow __WF((long user_id, char *app_name, char *file_name));
extern long WFfread_file __WF((char *str, FILE *infile));

/* WFmake_trans.c */
extern long WFquery_override_transition __WF((long user_id, MEMptr *attr_list, MEMptr *data_list));
extern long WFquery_make_transition __WF((long user_id, MEMptr *attr_list, MEMptr *data_list));
extern long WFmake_transition __WF((long user_id, MEMptr attr_list, MEMptr data_list));
extern long _NFMcheck_item_condition_make_transition __WF((char *catalog_name, char *item_name, char *item_rev));

/* WFsign_tools.c */
extern long WFcheck_signoff __WF((long user_id));
extern long WFvalidate_signoff_users __WF((long user_id));
extern long WFvalidate_signoffusers_acl __WF((long user_id, char *cat_name, char *item_name, char *item_rev));
extern long WFhistory_signoff __WF((long user_id));
extern long WFget_signoffs __WF((long user_id, long state_no, long acl_no, long catalog_no, long item_no, long *no_users, long *no_act_users));
extern long WFdup_signoffs __WF((long user_id, long state_no, long acl_no, long catalog_no, long item_no, long *no_users, long *no_act_users));
extern long NFMcheck_no_signoff __WF((long user_id, long state_no, long acl_no, long *no_users));

/* WFsignoff.c */
extern long WFquery_signoff_attributes __WF((long user_id, MEMptr *attr_list, MEMptr *data_list, MEMptr *value_list));
extern long WFsignoff __WF((long user_id, MEMptr attr_list, MEMptr data_list));
extern long WFcheck_user_override __WF((long user_id));
extern long WFpurge_signoff __WF((long user_id, char *catalog_name, char *item_name, char *item_rev));

/* WFstates.c */
extern long WFquery_workflow_states __WF((long user_id, char *workflow_name, MEMptr *attr_list, MEMptr *data_list, MEMptr *value_list));
extern long WFupdate_workflow_states __WF((long user_id, MEMptr attr_list, MEMptr data_list));
extern long WFadd_workflow_states __WF((long user_id, MEMptr attr_list, MEMptr data_list));
extern long WFdrop_workflow_states __WF((long user_id, MEMptr attr_list, MEMptr data_list));
extern long WFload_states_list __WF((long user_id, MEMptr attr_list, MEMptr data_list, char *inline));

/* WFto_state.c */
extern long WFset_to_state __WF((long user_id, char *app_name, MSGptr app_ptr));
extern long WFenter_sdp_trans __WF((long user_id));
extern long WFenter_admin_trans __WF((long user_id));
extern long WFenter_catalog_trans __WF((long user_id));
extern long WFenter_project_trans __WF((long user_id));
extern long WFenter_item_trans __WF((long user_id));
extern long WFdelete_signoff __WF((long user_id));

/* WFtools.c */
extern long WFcheck_acl_complete __WF((long wf_no, long acl_no));
extern long WFcheck_acl_class_users __WF((long user_id, long wf_no, long acl_no));
extern long WFcheck_acl_signoff_users __WF((long user_id, long wf_no, long acl_no));
extern long WFenter_acl_complete __WF((long user_id));
extern long WFenter_acl_not_complete __WF((long user_id));
extern long WFcheck_workflow_usable __WF((long user_id, long wf_no));
extern long WFenter_workflow_complete __WF((long user_id, MEMptr attr_list, MEMptr data_list));
extern long WFenter_workflow_usable __WF((long user_id, long wf_no));
extern long WFenter_workflow_not_usable __WF((long user_id, long wf_no));
extern long WFtransition_log __WF((long user_id, char *app_name, MSGptr app_ptr));
extern long WFtransition_mail __WF((long user_id, char *app_name, MSGptr app_ptr));
extern long _WFquery_state_name __WF((int state_no, char *state_name));

/* WFtrans.c */
extern long WFquery_workflow_transitions __WF((long user_id, char *app_name, char *workflow_name, MEMptr *attr_list, MEMptr *data_list, MEMptr *value_list));
extern long WFupdate_workflow_transitions __WF((long user_id, MEMptr attr_list, MEMptr data_list));
extern long WFadd_workflow_transitions __WF((long user_id, MEMptr attr_list, MEMptr data_list));
extern long WFdrop_workflow_transitions __WF((long user_id, MEMptr attr_list, MEMptr data_list));
extern long WFload_trans_acc_list __WF((long user_id, long no_classes, MEMptr trans_attr, MEMptr trans_data, MEMptr access_attr, MEMptr access_data, char *inline));
extern long WFset_transitions __WF((long user_id, MEMptr st_attr, MEMptr st_data, MEMptr tr_attr, MEMptr tr_data));
extern long NFMenter_command __WF((long user_id, char *app_name, char *comm_name, long *comm_no));

/* WFvalid.c */
extern long WFvalidate_user_access __WF((long user_id, char *command, char *workflow_name, char *project_name, char *catalog_name, char *item_name, char *item_rev));
extern long _WFsdp_validate __WF((long user_id));
extern long _WFadmin_validate __WF((long user_id));
extern long _WFcatalog_validate __WF((long user_id));
extern long _WFproject_validate __WF((long user_id));
extern long _WFload_cat_proj_info __WF((void));
extern int _WFinit_wfinfo_login __WF((void));
extern int _WFinit_wfinfo __WF((void));
extern int NFMprint_wfinfo __WF((void));
extern int _WFitem_transition_validate __WF((long user_id));
extern int _WFitem_user_acl_validate __WF((long user_id));
extern long _WFitem_any_wf_acl_validate __WF((long user_id));
extern long _WFnoentity_validate __WF((long user_id));
extern long NFMget_transition_error __WF((void));

/* WFwfs.c */
extern long WFquery_workflow_attributes __WF((long user_id, MEMptr *attr_list, MEMptr *data_list, MEMptr *value_list));
extern long WFadd_workflow __WF((long user_id, MEMptr attr_list, MEMptr data_list));
extern long WFload_workflow_list __WF((long user_id, MEMptr attr_list, MEMptr data_list, char *inline, char *workflow_name));

#undef __WF

#endif
