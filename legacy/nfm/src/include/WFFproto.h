#ifndef WFF_PROTO_H
#define WFF_PROTO_H

#if defined(__STDC__) || defined(__cplusplus)
# define __WFF(s) s
#else
# define __WFF(s) ()
#endif


/* WFFadd_cmd.c */
extern long WFFadd_commands __WFF((void));
extern long _WFFadd_commands_notify __WFF((int g_label, double value, Form form));
extern long _WFFcmd_name_field __WFF((Form form, int g_label, WFFcmd_ptr ptr));
extern long _WFFload_cmds_in_list __WFF((MEMptr data_list, WFFcmd_ptr ptr));
extern long _WFFinsert_cmd __WFF((Form form, int g_label, int row, struct WFFcommand_st cmd_st));
extern long _WFFput_cmds_in_list __WFF((Form form, int g_label, int num_cmds, struct WFFcommand_st cmd_list[]));
extern long _WFFadd_cmds __WFF((Form form, int g_label, WFFcmd_ptr ptr));
extern long _WFFdelete_cmds __WFF((Form form, int g_label, WFFcmd_ptr ptr));
extern void _WFFfree_cmd_ptr __WFF((WFFcmd_ptr ptr));
extern long _WFFadjust_cmd_form __WFF((Form form));

/* WFFadd_wf.c */
extern long WFFadd_workflow __WFF((void));

/* WFFchg_wf.c */
extern long WFFchange_workflow __WFF((char *workflow_name, int curr_page));

/* WFFconfig.c */
extern long _WFFsetup_config __WFF((char *program_name));

/* WFFconfirm.c */
extern long _WFFconfirm __WFF((char *entity1, char *entity2, char *entity3, char *prompt1, char *prompt2, int listing_type, void (*f1 )(), void (*f2 )()));
extern long _WFFconfirm_notify __WFF((int g_label, double value, Form form));
extern void _WFFfree_confirm __WFF((WFFconfirm_ptr ptr));
extern long _WFFconfirm_delete_class __WFF((Form form, int g_label, WFFadd_ptr ptr));
extern long _WFFconfirm_delete_class_notify __WFF((int g_label, double value, Form form));
extern void _WFFfree_confirm_delete_class __WFF((Form fptr));
extern long _WFFconfirm_delete_state __WFF((Form form, int g_label, WFFadd_ptr ptr));
extern long _WFFconfirm_delete_state_notify __WFF((int g_label, double value, Form form));
extern void _WFFfree_confirm_delete_state __WFF((Form fptr));

/* WFFdbg_on.c */
extern long NFIdebug_on_off __WFF((void));
extern long _NFIdebug_notify __WFF((int g_label, double value, Form form));

/* WFFdel_cmd.c */
extern long WFFdelete_commands __WFF((void));
extern long _WFFdelete_commands_notify __WFF((int g_label, double value, Form form));

/* WFFdel_wf.c */
extern long WFFdelete_workflow __WFF((char *workflowname));

/* WFFdump_wf.c */
extern long WFFdump_workflow __WFF((char *workflow));
extern long _WFFdump_wf_notify __WFF((int g_label, double value, Form form));

/* WFFenv.c */
extern long _WFFenv_popup __WFF((MEMptr buffer));
extern long _WFFenv_popup_notify __WFF((int g_label, double value, Form form));
extern long _WFFenv_popup_field __WFF((Form form, int label, int row));

/* WFFexit.c */
extern void _WFFexit __WFF((int status));

/* WFFfgets.c */
extern char *_WFFfgets __WFF((char *s, int n, FILE *stream));

/* WFFfl_tools.c */
extern long _WFFadjust_confirm_form __WFF((Form form));

/* WFFinit.c */
extern void _WFFinit_global __WFF((void));
extern long _WFFinit_graphics __WFF((char *program_name));

/* WFFlist_acc.c */
extern long WFFlist_class_access __WFF((Form form, char *workflow_name));

/* WFFlist_cl.c */
extern long WFFlist_classes_long __WFF((Form form, char *workflow_name));
extern long WFFlist_classes_short __WFF((Form form, char *workflow_name));

/* WFFlist_cmd.c */
extern long WFFlist_commands_long __WFF((Form form, char *workflow_name, char *app_name));

/* WFFlist_mcf.c */
extern long _WFFlist_load_mcf __WFF((Form form, int mode, int num_frozen_cols, MEMptr attr_list, MEMptr data_list));
extern long _WFFlist_create_mcf __WFF((Form form, int label, int num_frozen_cols, int mode, MEMptr data_list));
extern long _WFFlist_load_mcf_data __WFF((Form form, int num_frozen_cols, int top_label1, int top_label2, int bottom_label1, int bottom_label2, MEMptr attr_list, MEMptr data_list));
extern long _WFFlist_position_mcfs __WFF((Form form));

/* WFFlist_pop.c */
extern long _WFFlist_load_popup __WFF((char *name, MEMptr buffer));
extern long _WFFpopup_list_notify __WFF((int g_label, double value, Form form));
extern long _WFFpopup_list_field __WFF((Form form, int label, int row));
extern void _WFFpopup_main_button __WFF((Form form));

/* WFFlist_st.c */
extern long WFFlist_states_long __WFF((Form form, char *workflow_name));
extern long WFFlist_states_short __WFF((Form form, char *workflow_name));

/* WFFlist_trn.c */
extern long WFFlist_transitions_long __WFF((Form form, char *workflow_name));
extern long WFFlist_transitions_short __WFF((Form form, char *workflow_name));

/* WFFlist_wf.c */
extern long WFFlist_workflows_long __WFF((Form form));
extern long WFFlist_workflows_short __WFF((Form form));

/* WFFload_wf.c */
extern long WFFload_workflow __WFF((void));
extern long _WFFload_wf_notify __WFF((int g_label, double value, Form form));

/* WFFlogin.c */
extern long WFFlogin __WFF((void));
extern long _WFFlogin_form __WFF((WFFlogin_ptr login));
extern long _WFFlogin_notify __WFF((int g_label, double value, Form form));
extern long _WFFlogin_validate_accept __WFF((Form form, WFFlogin_ptr login));
extern void _WFFfree_login __WFF((WFFlogin_ptr login));
extern long WFFlogout __WFF((void));

/* WFFmain.c */
extern long main __WFF((int argc, char *argv[]));
extern void _WFFprocess_command_file __WFF((void));

/* WFFmain_err.c */
extern void _WFFmain_error_button __WFF((void));
extern long _WFFmain_error_notify __WFF((int g_label, double value, Form form));

/* WFFmenu.c */
extern long _WFFinit_menus __WFF((void));

/* WFFnotify.c */
extern void _WFFnotify __WFF((int f_label, int g_label, double value, Form form));

/* WFFpage1.c */
extern long _WFFpage1 __WFF((WFFadd_ptr ptr));
extern long _WFFpage1_notify __WFF((int g_label, double value, Form form));
extern long _WFFname_field __WFF((Form form, int g_label, WFFadd_ptr ptr));
extern long _WFFwf_scrl_list __WFF((Form form, int g_label, WFFadd_ptr ptr));
extern long _WFFget_page1_data __WFF((Form form, WFFadd_ptr ptr));
extern long _WFFcheck_page1_data __WFF((Form form, WFFadd_ptr ptr));

/* WFFpage2.c */
extern long _WFFpage2 __WFF((WFFadd_ptr ptr));
extern long _WFFpage2_notify __WFF((int g_label, double value, Form form));
extern long _WFFload_class_in_list __WFF((MEMptr data_list, WFFadd_ptr ptr));
extern long _WFFload_states_in_list __WFF((MEMptr data_list, WFFadd_ptr ptr));
extern long _WFFinsert_class __WFF((Form form, int g_label, int row, char *class_name));
extern long _WFFput_classes_in_list __WFF((Form form, int g_label, WFFadd_ptr ptr));
extern long _WFFinsert_state __WFF((Form form, int g_label, int row, struct WFFstate_st state_st));
extern long _WFFput_states_in_list __WFF((Form form, int g_label, int num_states, struct WFFstate_st state_list[]));
extern long _WFFadd_class __WFF((Form form, int g_label, WFFadd_ptr ptr));
extern long _WFFdelete_classes __WFF((Form form, int g_label, WFFadd_ptr ptr));
extern long _WFFadd_states __WFF((Form form, int g_label, WFFadd_ptr ptr));
extern long _WFFdelete_states __WFF((Form form, int g_label, WFFadd_ptr ptr));
extern void _WFFget_next_seq_no __WFF((int num_states, struct WFFstate_st state_list[], char *seq_no));
extern long _WFFcheck_so_state __WFF((Form form));
extern long _WFFupdate_class __WFF((Form form, int g_label, int scf_label, int no_classes, struct WFFclass_st class_list[], int no_access, struct WFFaccess_st access_list[]));
extern long _WFFset_selected_class __WFF((Form form, int g_label, int scf_label));
extern long _WFFset_selected_state __WFF((Form form, int mcf_label));
extern long _WFFupdate_state_name __WFF((Form form, int g_label, int mcf_label, WFFadd_ptr ptr));
extern long _WFFupdate_state_desc __WFF((Form form, int g_label, int mcf_label, WFFadd_ptr ptr));
extern long _WFFupdate_state_seqno __WFF((Form form, int g_label, int mcf_label, WFFadd_ptr ptr));
extern long _WFFupdate_state_signoffs __WFF((Form form, int g_label, int mcf_label, WFFadd_ptr ptr));
extern long _WFFupdate_state_toggles __WFF((Form form, int g_label, int mcf_label, WFFadd_ptr ptr));
extern long _WFFdelete_class_express __WFF((int g_label, Form form));
extern long _WFFdelete_state_express __WFF((int g_label, Form form));

/* WFFpage3.c */
extern long _WFFpage3 __WFF((WFFadd_ptr ptr));
extern long _WFFpage3_notify __WFF((int g_label, double value, Form form));
extern long _WFFload_transitions_in_list __WFF((MEMptr data_list, WFFadd_ptr ptr));
extern long _WFFinsert_transition __WFF((Form form, int g_label, int row, struct WFFtrans_st trans_st));
extern long _WFFput_transitions_in_list __WFF((Form form, int g_label, int num_trans, struct WFFtrans_st trans_list[]));
extern long _WFFadd_transitions __WFF((Form form, int g_label, WFFadd_ptr ptr));
extern long _WFFdelete_transitions __WFF((Form form, int g_label, WFFadd_ptr ptr));
extern long _WFFput_list_info_in_field __WFF((Form form, int label1, int label2, int column, int length, int sel_value));
extern long _WFFset_selected_transition __WFF((Form form, int mcf_label));
extern long _WFFupdate_trans_name __WFF((Form form, int g_label, int mcf_label, WFFadd_ptr ptr));
extern long _WFFupdate_t_command_name __WFF((Form form, int g_label, int mcf_label, WFFadd_ptr ptr));
extern long _WFFupdate_t_from_state __WFF((Form form, int g_label, int mcf_label, WFFadd_ptr ptr));
extern long _WFFupdate_t_to_state __WFF((Form form, int g_label, int mcf_label, WFFadd_ptr ptr));
extern long _WFFupdate_transition_toggles __WFF((Form form, int g_label, int mcf_label, WFFadd_ptr ptr));

/* WFFpage4.c */
extern long _WFFpage4 __WFF((WFFadd_ptr ptr));
extern long _WFFpage4_notify __WFF((int g_label, double value, Form form));
extern long _WFFset_all_transitions __WFF((Form form, int g_label, int sel_flag));
extern long _WFFload_access_in_list __WFF((MEMptr data_list, WFFadd_ptr ptr));
extern long _WFFdisplay_access __WFF((Form form, int g_label, int num_access, struct WFFaccess_st access_list[]));
extern long _WFFupdate_class_access __WFF((Form form, WFFadd_ptr ptr));

/* WFFparse.c */
extern void _WFFparse_input __WFF((int argc, char *argv[], int *errflag));

/* WFFpersist.c */
extern long _WFFinit_main __WFF((void));
extern long _WFFmain_notify __WFF((int g_label, double value, Form form));
extern void _WFFmain_message __WFF((void));
extern long _WFFmain_top_left_mcf __WFF((Form form, int row));
extern long _WFFmain_bottom_left_or_right_mcf __WFF((Form form, int label1, int label2, int row));
extern long _WFFmain_bottom_mcf __WFF((Form form, int row));
extern long _WFFprocess_list_mcf __WFF((Form form, int label, int column, int current_list));
extern long _WFFmain_find_name __WFF((char **name, int row));
extern long _WFFmain_set_field __WFF((char *name, int type));
extern void _WFFmain_set_wf __WFF((char *workflow));
extern void _WFFmain_set_acl __WFF((char *acl_name));
extern void _WFFmain_set_server __WFF((char *server));
extern void _WFFmain_set_env __WFF((char *environment));
extern void _WFFmain_set_username __WFF((char *username));
extern void _WFFmain_set_user __WFF((char *user));
extern void _WFFmain_blank_listing __WFF((int listing_type));
extern long _WFFmain_get_text __WFF((Form form, int label));

/* WFFprint.c */
extern long _WFFmain_print_listing __WFF((Form form, int label1, int label2, char *filename));
extern long _WFFmain_print_to_file __WFF((int *cols, char *time_string, char *filename));

/* WFFproc_pg.c */
extern long _WFFprocess_pages __WFF((WFFadd_ptr ptr));
extern void _WFFfree_add_ptr __WFF((WFFadd_ptr ptr));
extern long _WFFadjust_wf_form __WFF((Form form));
extern long _WFFscroll_pages __WFF((Form form, int g_label, double value, WFFadd_ptr ptr));
extern long _WFFput_data_in_list __WFF((Form form, int g_label, int no_cols, int starting_col, MEMptr data_list));
extern long _WFFget_data_from_field __WFF((Form form, int g_label, int row, int column, char *text, int length));
extern long _WFFscf_put_states_in_list __WFF((Form form, int g_label, int num_rows, struct WFFstate_st state_list[]));
extern long _WFFscf_put_trans_in_list __WFF((Form form, int g_label, int num_rows, struct WFFtrans_st trans_list[]));

/* WFFprocess.c */
extern void _WFFprocess_data __WFF((int type, char *command));
extern void _WFFprocess_cleanup __WFF((int flag));
extern void _WFFprocess_event __WFF((int refresh_event));

/* WFFscroll.c */
extern void _WFFscroll_message __WFF((Form form, int label));
extern void _WFFscroll_message_one_word __WFF((Form form, int label));

/* WFFsignal.c */
extern long _WFFsetup_signals __WFF((void));
extern void _WFFsignal __WFF((int type));

/* WFFtools.c */
extern long _WFFcenter_form __WFF((Form form, int xlocation, int ylocation));
extern long _WFFcenter_gadget __WFF((Form form, int label));
extern long _WFFmessage __WFF((int message_no, char *message_fmt, ...));
extern long _WFFmessage_old __WFF((int message_no, char *message_fmt, va_list vars));
extern long _WFFerase_message __WFF((void));
extern long _WFFerase_message_old __WFF((void));
extern long _WFFerror_message __WFF((Form form));
extern long _WFFform_message __WFF((Form form, int message_no, char *message_fmt, va_list vars));
extern long _WFFfind_column_offset __WFF((MEMptr buffer, char *attrname, short *offset));
extern long _WFFbuild_value_buffer __WFF((MEMptr *buffer));
extern long _WFFfind_attribute_name __WFF((MEMptr buffer, int row, char **name));
extern long _WFFinit_rows __WFF((MEMptr buffer, char *write_attr, int *row_array[]));
extern long _WFFinit_cols __WFF((MEMptr buffer, int *col_array[], char *read_attr, char *write_attr, char *read_value, char *write_value));
extern long _WFFfind_next_writable_row __WFF((MEMptr buffer, char *write_attr, char *write_value, int current_row, int *next_row));
extern long _WFFfind_list_offsets __WFF((MEMptr attr_list, short *syn_offset, short *name_offset));
extern void _WFFclear_msg __WFF((Form form));
extern long _WFFget_attr_info __WFF((MEMptr attr_list, char *attrname, int *offset, char *n_read, char *n_write, char *type, int *length));
extern long _WFFcvt_to_long __WFF((char *str, long *value));
extern void _WFFset_active_row __WFF((Form form, int g_label, int active_row, int row_pos));

/* WFFusage.c */
extern void _WFFinit_usage __WFF((char *program_name, char *usage));

/* WFFvalidate.c */
extern long WFFvalidate_workflow __WFF((char *workflow));

/* WFFvlt.c */
extern long _WFFsetup_vlt __WFF((void));
extern long _WFFload_help_vlt __WFF((int numslots, struct vlt_slot *vlt));
extern int _WFFtranslate_color __WFF((int vs, int color));

/* WFFwf.c */
extern long WFFvalidate_user_access __WFF((char *command_key));
extern long WFFset_to_state __WFF((void));
extern long _WFFvalidate_active_data __WFF((long mask));

#undef __WFF

#endif
