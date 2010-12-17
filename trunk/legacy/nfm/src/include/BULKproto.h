#ifndef BULK_PROTO_H
#define BULK_PROTO_H

#if defined(__STDC__) || defined(__cplusplus)
# define __BULK(s) s
#else
# define __BULK(s) ()
#endif


/* FMactivate.c */
extern long NFAactivate_project __BULK((void));
extern long NFAactivate_catalog __BULK((void));
extern long NFAactivate_item __BULK((void));
extern long NFAactivate_sa __BULK((void));

/* FMbulk_load.c */
extern int bulk_load __BULK((void));

/* FMbulk_t.c */
extern long NFMget_value_list_string __BULK((char *list_num, MEMptr value_list, char *attr_name, char *synonym, char *index_num, char *string_val));
extern long NFMvalidate_list_entity __BULK((char *list_num, MEMptr value_list, char *attr_name, char *attr_value, char *attr_index));
extern long NFMuser_attr __BULK((MEMptr attr_list, MEMptr data_list, char *item));

/* FMchoose.c */
extern long NFAdisplay_elements __BULK((struct SCfree_data_st *struct_data, NFMlist list_struct));
extern long NFAget_display_information __BULK((NFMlist list, MEMptr *syn_list, MEMptr *data_list));
extern long NFAnew_display_simple_data __BULK((struct SCfree_data_st *struct_data, MEMptr syn_list, MEMptr data_list, int select_set, char *title));

/* FMcommands.c */
extern NFMfunction nfm_debug_on __BULK((void));
extern NFMfunction nfm_debug_off __BULK((void));
extern NFMfunction nfm_server_debug_on __BULK((void));
extern NFMfunction nfm_server_debug_off __BULK((void));
extern NFMfunction nfm_client_debug_on __BULK((void));
extern NFMfunction nfm_client_debug_off __BULK((void));
extern int NFMreset_errors __BULK((void));
extern int NFAalpha_validate_user_access __BULK((long user_id, char *command, char *workflow, char *project, char *catalog, char *item, char *revision));
extern int NFAalpha_set_to_state __BULK((long error_number, char *error_message));
extern NFMfunction nfm_display_nodes __BULK((void));
extern NFMfunction nfm_display_storage_areas __BULK((void));
extern NFMfunction nfm_display_catalogs __BULK((void));
extern NFMfunction nfm_display_items __BULK((void));
extern NFMfunction nfm_bulk_load __BULK((void));

/* FMdebug.c */
extern long debug_on __BULK((void));
extern long debug_off __BULK((void));
extern long server_debug_on __BULK((void));
extern long client_debug_on __BULK((void));
extern long server_debug_off __BULK((void));
extern long client_debug_off __BULK((void));
extern long catalog __BULK((void));
extern long print_file __BULK((void));
extern long test_messages __BULK((void));

/* FMdisplays.c */
extern long display_nodes __BULK((void));
extern long display_storage_areas __BULK((void));
extern long display_catalogs __BULK((void));
extern long display_items __BULK((void));

/* FMenter.c */
extern int nfm_enter __BULK((char *cmd_line_server, char *cmd_line_env, char *cmd_line_user, char *cmd_line_passwd, char *exec_path));

/* FMerr_rec.c */
extern int record_status __BULK((FILE *file, char *title, char *item, char *revision, int status));

/* FMerr_ret.c */
extern long NFMerr_ret __BULK((long err_no));
extern long NFAcreate_error_form __BULK((struct SCcolumn_data_st *struct_data));

/* FMexit.c */
extern int nfm_exit __BULK((void));

/* FMfunctions.c */
extern long NFAget_st_area_name __BULK((char *storage_name));
extern long NFAget_storage_info __BULK((char *storage_num, char *storage_name, char *temp_node, char *temp_user, char *temp_passwd, char *temp_path, int mode));
extern long NFAget_node_info __BULK((char *node_name, char *node_num));
extern long NFAget_search_name __BULK((char *search_name));
extern long NFAconfirm __BULK((char *title, int *confirmed));
extern long NFAcol_width __BULK((char *data_ptr1, char *data_ptr2, int *max_len));
extern long NFAget_dtype_len __BULK((char *data_ptr1, char *data_ptr2, int *len));
extern long NFAdtype_length __BULK((char *data_ptr, int *len));
extern long NFAfind_len __BULK((char **data_ptr, int column_ptr, NDXptr index, int rows, int cols, int *max_attr_len, int *max_syn_len, int *max_dtype_len));
extern long NFAfind_new_len __BULK((char **data_ptr, int column_ptr, NDXnewptr index, int rows, int cols, int *max_attr_len, int *max_syn_len, int *max_dtype_len));
extern long NFAfind_max_len __BULK((char **column_ptr, char **format_ptr, char **data_ptr, int cols, int *max_col_len, int *max_dtype_len));
extern long NFAfind_max_data_len __BULK((char **column_ptr, char **data_ptr, int start, int cols, int rows, int *max_data_len));
extern long NFAvalidate_data_type __BULK((char *data_type));
extern long NFAfill_list_struct __BULK((NFMlist *list, int rep_type, int select_set, int select_type, char *search_str, char *sort_str, char *catalog, char *item, char *rev, char *workflow, char *acl, char *title));
extern long NFAfree_list_struct __BULK((NFMlist *list));
extern long NFAvalidate_nulls __BULK((MEMptr attr_list, NDXptr index, struct SCcolumn_data_st data, int pos, int *filled));
extern long NFAvalidate_member_type __BULK((char *type));
extern long NFAvalidate_proj_member_type __BULK((char *type));
extern long NFAget_server_name __BULK((MEMptr server_list, char *server_name));
extern long NFAget_env_name __BULK((MEMptr env_list, char *env_name));
extern long NFAvalidate_env_name __BULK((MEMptr env_list, char *env_name));
extern long NFAget_user_variables __BULK((MEMptr *user_var_list));
extern long NFMRset_error __BULK((long status, char *message));
extern long NFMone_or_all __BULK((char *one_or_all));
extern int lowcase __BULK((char *str));
extern long NFAget_date_len __BULK((char *data_ptr1, int *len));
extern long NFAset_global_config_info __BULK((int wf_use, char *command, char *wf_name, char *project_name, char *application));

/* FMglobals.c */

/* FMlogin.c */
extern long nfm_login __BULK((char *server, char *cmd_line_env, char *cmd_line_user, char *cmd_line_passwd, int login_count));

/* FMlogout.c */
extern int logout __BULK((void));

/* FMtools.c */
extern int NFAmake_msg __BULK((char *mess));
extern int NFAfree_list __BULK((char **data_list, int num_rows, int num_cols));
extern int NFAput_string __BULK((char **to_string, char *string));
extern int NFAvalidate_string __BULK((char *dtype, char *string));
extern int NFAvalidate_Y_or_N __BULK((char *string));
extern int NFMput_buf_string __BULK((char **to_string, char *string, int len));
extern int NFMput_and_validate_data __BULK((char **data, int initial, int limit, int increment));
extern int NFAdisplay_message_set __BULK((char *title, MEMptr set_msg));

/* SCatofn.c */

#undef __BULK

#endif
