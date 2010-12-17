#ifndef WFG_PROTO_H
#define WFG_PROTO_H

#if defined(__STDC__) || defined(__cplusplus)
# define __WFG(s) s
#else
# define __WFG(s) ()
#endif


/* WFGaccess.c */
extern long WFGupdate_class_access __WFG((long workflow_no, int num_access, struct WFFaccess_st access_list[], char *upd_order));
extern long _WFGadd_class_access __WFG((long workflow_no, char *class_name, struct WFFstatus_st access_ptr[], int num_trans));
extern long _WFGdelete_class_access __WFG((long workflow_no, char *class_name, struct WFFstatus_st access_ptr[], int num_trans));

/* WFGadd_wf.c */
extern long WFGadd_workflow __WFG((long user_id, char *workflow_name, char *old_wf_name, char *wf_desc, int num_classes, struct WFFclass_st class_list[], int num_states, struct WFFstate_st state_list[], int num_trans, struct WFFtrans_st trans_list[], int num_access, struct WFFaccess_st access_list[]));

/* WFGclasses.c */
extern long WFGupdate_classes __WFG((long workflow_no, int num_classes, struct WFFclass_st class_list[], char *upd_order));
extern long _WFGadd_class __WFG((long workflow_no, char *class_name, long *class_no));
extern long _WFGdelete_class __WFG((long workflow_no, long class_no));
extern long _WFGmodify_class __WFG((long workflow_no, long class_no, char *class_name));

/* WFGcommands.c */
extern long WFGprocess_commands __WFG((int num_cmds, struct WFFcommand_st command_list[]));
extern long WFGupdate_commands __WFG((int num_cmds, struct WFFcommand_st command_list[], char *upd_order));
extern long _WFGadd_command __WFG((struct WFFcommand_st command_info));
extern long _WFGdelete_command __WFG((char *command_name));

/* WFGcopy_wf.c */
extern long WFGcopy_workflow __WFG((char *workflow_name, char *wf_desc, int num_classes, struct WFFclass_st class_list[], int num_states, struct WFFstate_st state_list[], int num_trans, struct WFFtrans_st trans_list[], int num_access, struct WFFaccess_st access_list[]));

/* WFGdel_wf.c */
extern long WFGdelete_workflow __WFG((long user_id, char *workflowname));

/* WFGdump_wf.c */
extern long WFGdump_workflow __WFG((char *workflow_name, char *file_name));
extern long WFGqry_wf_info __WFG((char *workflow_name, long *workflow_no, char *workflow_desc, char *wf_type, char *acl_name));
extern long WFGoutput_line __WFG((FILE *out_file, char *wf_str, int length, int write_line));
extern long WFGqry_wf_states __WFG((long workflow_no, MEMptr *state_buffer));
extern long WFGqry_wf_classes __WFG((long workflow_no, MEMptr *class_buffer));
extern long WFGqry_wf_transitions __WFG((long workflow_no, MEMptr *trans_buffer, MEMptr state_buffer));
extern long WFGqry_wf_class_access __WFG((long trans_no, MEMptr class_buffer, MEMptr *class_list));

/* WFGlist.c */
extern long WFGlist_wfs __WFG((long user_id, char *search_str, char *sort_str, int type, MEMptr *attr_list, MEMptr *data_list));
extern long WFGlist_states __WFG((long user_id, char *workflow_name, char *search_str, char *sort_str, int type, MEMptr *attr_list, MEMptr *data_list));
extern long WFGlist_classes __WFG((long user_id, char *workflow_name, char *search_str, char *sort_str, int type, MEMptr *attr_list, MEMptr *data_list));
extern long WFGlist_transitions __WFG((long user_id, char *workflow_name, char *search_str, char *sort_str, int type, MEMptr *attr_list, MEMptr *data_list));
extern long WFGlist_class_access __WFG((long user_id, char *workflow_name, char *search_str, char *sort_str, MEMptr *attr_list, MEMptr *data_list));
extern long WFGlist_commands_short __WFG((char *workflow_name, char *app_name, MEMptr *attr_list, MEMptr *data_list));
extern long WFGlist_applications __WFG((MEMptr *output_buffer));
extern long WFGlist_commands_long __WFG((char *workflow_name, char *app_name, MEMptr *attr_list, MEMptr *data_list));

/* WFGlogin.c */
extern long WFGquick_login __WFG((long *user_id, char *user_name, char *passwd, char *env));

/* WFGn_list.c */
extern long WFGn_list_states __WFG((char *workflow_name, MEMptr *attr_list, MEMptr *data_list));
extern long WFGn_list_classes __WFG((char *workflow_name, MEMptr *attr_list, MEMptr *data_list));
extern long WFGn_list_transitions __WFG((char *workflow_name, MEMptr *attr_list, MEMptr *data_list));
extern long WFGn_list_commands_long __WFG((char *workflow_name, char *app_name, MEMptr *attr_list, MEMptr *data_list));

/* WFGqry.c */
extern long WFGqry_classes __WFG((char *workflow_name, MEMptr *output_buffer));
extern long WFGquery_states __WFG((char *workflow_name, MEMptr *output_buffer));
extern long WFGquery_transitions __WFG((char *workflow_name, MEMptr *output_buffer));
extern long WFGget_wf_info __WFG((char *workflow_name, long *workflow_no, char *wf_complete, char *workflow_desc));

/* WFGstates.c */
extern long WFGupdate_states __WFG((long workflow_no, int num_states, struct WFFstate_st state_list[], char *upd_order));
extern long _WFGadd_state __WFG((long workflow_no, struct WFFstate_st state_info));
extern long _WFGdelete_state __WFG((long workflow_no, char *state_name));
extern long _WFGmodify_state __WFG((long workflow_no, struct WFFstate_st state_info));

/* WFGtic.c */
extern void WFGtic_it __WFG((char *in_str, char *out_str));

/* WFGtools.c */
extern long _WFGcheck_wf_in_use __WFG((long wf_no));
extern long _WFGget_workflow_no __WFG((char *workflowname, long *wf_no));
extern long WFGvalidate_workflow __WFG((char *workflowname));
extern long _WFGget_class_no __WFG((long workflow_no, char *class_name, long *class_no));
extern long _WFGget_state_no __WFG((long workflow_no, char *state_name, long *state_no));
extern long _WFGget_trans_no __WFG((long workflow_no, char *trans_name, long from_state, long *trans_no));
extern long _WFGget_command_no __WFG((char *command_name, long *command_no));
extern long _WFGget_acl_no __WFG((char *acl_name, long *acl_no));
extern long _WFGget_wf_state __WFG((long workflow_no, long *state_no, char *state_name));
extern long _WFGget_table_no __WFG((char *table_name, long *table_no));
extern long _WFGget_attribute_synonyms __WFG((long table_no, char *attr_list, MEMptr *synonym_list));
extern long _WFGcheck_command_in_use __WFG((long command_no, char *command_name));
extern long _WFGget_cmd_synonyms __WFG((int type, MEMptr *attr_list));
extern long _WFGget_state_name __WFG((long workflow_no, long state_no, char *state_name));

/* WFGtrans.c */
extern long WFGupdate_trans __WFG((long workflow_no, int num_trans, struct WFFtrans_st trans_list[], char *upd_order));
extern long _WFGadd_transition __WFG((long workflow_no, struct WFFtrans_st trans_info));
extern long _WFGdelete_transition __WFG((long workflow_no, char *trans_name, char *from_state));
extern long _WFGmodify_transition __WFG((long workflow_no, struct WFFtrans_st trans_info));

/* WFGwf.c */
extern long _WFGinsert_workflow_info __WFG((char *workflow_name, char *workflow_desc));
extern long _WFGupdate_workflow_info __WFG((char *workflow_name, char *old_wf_name, char *workflow_desc));
extern long _WFGupdate_wf_state __WFG((long workflow_no));

#undef __WFG

#endif
