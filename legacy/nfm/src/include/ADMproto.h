#ifndef ADM_PROTO_H
#define ADM_PROTO_H

#if defined(__STDC__) || defined(__cplusplus)
# define __ADM(s) s
#else
# define __ADM(s) ()
#endif


/* ADMStorage_a.c */
extern long ADMvalidate_storage __ADM((void));

/* ADMactivate.c */
extern long ADMactivate_catalog __ADM((void));
extern long ADMactivate_item __ADM((void));
extern long ADMactivate_transition __ADM((void));
extern long ADMactivate_program __ADM((void));
extern long ADMactivate_workflow __ADM((void));
extern long ADMactivate_acl __ADM((void));

/* ADMblock.c */
extern long ADMblock_conf __ADM((void));

/* ADMcatname.c */
extern long ADMcatalog_list __ADM((long user_id, MEMptr *list));

/* ADMchoose.c */
extern long ADMchoose_elements __ADM((struct SCfree_data_st *struct_data, NFMlist list_struct));
extern long ADMget_display_info __ADM((NFMlist list, MEMptr *syn_list, MEMptr *data_list));
extern long ADMdisplay_data __ADM((struct SCfree_data_st *struct_data, MEMptr syn_list, MEMptr data_list, int select_set, char *title));

/* ADMcl_file.c */
extern long ADMcreate_clientfile __ADM((char *sername, char *tcp_net));

/* ADMclient.c */
extern long ADMclientserver __ADM((void));

/* ADMcommands.c */
extern NFMfunction login_in __ADM((void));
extern NFMfunction log_out __ADM((void));
extern NFMfunction change_command __ADM((void));
extern NFMfunction load_program __ADM((void));
extern NFMfunction prog_to_trans __ADM((void));
extern NFMfunction display_trans_proc __ADM((void));
extern NFMfunction cross_ref __ADM((void));
extern NFMfunction repair_uti __ADM((void));
extern NFMfunction server_file __ADM((void));
extern NFMfunction slot_file __ADM((void));
extern NFMfunction storage_file __ADM((void));
extern NFMfunction set_access __ADM((void));
extern NFMfunction set_lock __ADM((void));
extern NFMfunction ser_login_out __ADM((void));
extern NFMfunction purge_activity __ADM((void));
extern NFMfunction date_format __ADM((void));
extern NFMfunction time_format __ADM((void));
extern NFMfunction del_oper __ADM((void));
extern NFMfunction import_env __ADM((void));
extern NFMfunction export_env __ADM((void));
extern NFMfunction ris_clean __ADM((void));
extern NFMfunction client_file __ADM((void));
extern NFMfunction block_type __ADM((void));
extern NFMfunction nfs_clean __ADM((void));
extern NFMfunction debug_on __ADM((void));
extern NFMfunction debug_off __ADM((void));

/* ADMcross_ref.c */
extern long ADMcross_ref __ADM((void));

/* ADMdate.c */
extern long ADMdate_conf __ADM((void));

/* ADMdebug.c */
extern long ADMdebug_on __ADM((void));
extern long ADMdebug_off __ADM((void));

/* ADMdef_sch.c */
extern long ADMdef_schema __ADM((char *env_name));

/* ADMdrop_sch.c */
extern long ADMdrop_schema __ADM((char *env_name));

/* ADMenter.c */
extern int nfm_enter __ADM((char *server, char *env_name, char *cmd_line_user, char *cmd_line_passwd, char *path));
extern int user_login __ADM((void));
extern int nfm_exit __ADM((void));

/* ADMenv.c */
extern long NFMget_env __ADM((void));

/* ADMenv_file.c */
extern long NFMget_schema_envinfo __ADM((char *nodename, MEMptr *schema));
extern long NFMget_schema_buffer __ADM((MEMptr *attr_list));

/* ADMenv_imp.c */
extern long ADMget_import_info __ADM((char *nodename, char *local_passwd));

/* ADMerr_ret.c */
extern long NFMerr_ret __ADM((long err_no));

/* ADMexp_env.c */
extern long ADMexport_env __ADM((char *node_name, char *user_name, char *passwd, char *environment));

/* ADMexp_files.c */
extern long ADMfind_export_files __ADM((char *type, MEMptr *output_buffer));

/* ADMexport.c */
extern long ADMget_exp_env __ADM((void));

/* ADMfunctions.c */
extern int NFMget_network_types __ADM((char *node_name, char *tcp, char *xns, char *dec));
extern int NFMget_dtype_len __ADM((char *data_ptr1, char *data_ptr2, int *len));
extern long NFMfill_index __ADM((MEMptr attr_list, NDXptr *index));
extern long ADMvalidate_nulls __ADM((MEMptr attr_list, NDXptr index, struct SCcolumn_data_st *struct_data, int pos, int *filled));
extern long NFMfind_len __ADM((char **data_ptr, NDXptr index, int rows, int cols, int *max_attr_len, int *max_syn_len, int *max_dtype_len));
extern long ADMget_pre_post_seq __ADM((char *program, char *prog_num, char *transition, char *trans_num, char *trans_state, MEMptr process_list, char *pre_post, char *seq_num));
extern long NFMfill_list_struct __ADM((NFMlist *list, int rep_type, int select_set, int select_type, char *search_str, char *sort_str, char *catalog, char *item, char *rev, char *workflow, char *acl, char *title));
extern long NFMfree_list_struct __ADM((NFMlist *list));
extern long NFMcol_width __ADM((char *data_ptr1, char *data_ptr2, int *max_len));
extern long ADMone_or_all __ADM((char *one_or_all));
extern long ADMget_env_name __ADM((MEMptr env_list, char *env_name));
extern long NFMvalidate_nulls __ADM((MEMptr attr_list, NDXptr index, struct SCcolumn_data_st data, int pos, int *filled));
extern int ADMmessage __ADM((void));
extern long ADMscan_processes __ADM((MEMptr process_list, char *trans_num, char *prog_num, int *map_count, char *seq_str));
extern long ADMconfirm __ADM((char *title, int *confirmed));

/* ADMget_block.c */
extern long ADMadd_block_type __ADM((long *next_row_no, long *block_type));

/* ADMget_date.c */
extern long ADMadd_date_type __ADM((long *next_row_no, char *date_type));

/* ADMget_ser.c */
extern long ADMfind_server __ADM((struct ps_buffer ps_buf[200 ], int *ps_count, int *actual_count));
extern int ADMfill_ps_struct __ADM((char *buffer, struct ps_buffer *ps_buf, int flag));

/* ADMget_time.c */
extern long ADMadd_time_type __ADM((long *next_row_no, char *date_type));

/* ADMglobals.c */

/* ADMimp.c */
extern long ADMget_heard_env __ADM((void));

/* ADMimp_env.c */
extern long ADMimport_env __ADM((char *node_name, char *user_name, char *passwd, char *environment, char *local_passwd));

/* ADMindex.c */
extern long ADMindex_comp __ADM((void));

/* ADMload_prog.c */
extern long ADMload_program __ADM((void));

/* ADMlock_itm.c */
extern long ADMlock_item_config __ADM((void));

/* ADMlogin.c */
extern int ADMlogin __ADM((void));
extern int ADMlogout __ADM((void));

/* ADMlogoff.c */
extern long ADMlogoff __ADM((char *envname));

/* ADMmod_trans.c */
extern long ADMprog_to_trans __ADM((void));
extern long ADMchoose_transitions __ADM((struct SCfree_data_st *struct_data));

/* ADMnfm_op.c */
extern long OPnodes_oper __ADM((MEMptr *output_buffer));

/* ADMnfme.c */
extern long NETLs_nodes_nfme __ADM((char *type, MEMptr *output_buffer));

/* ADMnfmex.c */
extern long ADMLs_nodes_nfmexp __ADM((char *type, MEMptr *output_buffer));

/* ADMnfmh.c */
extern long NETLs_nodes_nfmh __ADM((char *type, MEMptr *output_buffer));

/* ADMnfsclean.c */
extern long ADMnfs_clean __ADM((void));

/* ADMnodes.c */
extern long ADMnode_list __ADM((long user_id, MEMptr *list));

/* ADMop_env.c */
extern long ADMget_env __ADM((void));

/* ADMproctrans.c */
extern long ADMdisplay_transition_processes __ADM((void));

/* ADMpur_ac.c */
extern long ADMactivity __ADM((void));

/* ADMpurg.c */
extern long ADMpurge_activity __ADM((long user_id, MEMptr *out_list));

/* ADMr_op.c */
extern long ADMdrop_table __ADM((long user_id, char *oper_env));

/* ADMrepair.c */
extern long ADMrepair_uti __ADM((void));

/* ADMrislog.c */
extern long ADMris_file __ADM((void));

/* ADMser.c */
extern long ADMserver __ADM((void));

/* ADMser_file.c */
extern long ADMcreate_server __ADM((char *sername, char *tcp_net));

/* ADMser_log.c */
extern int server_log __ADM((void));

/* ADMsetc1.c */
extern long ADMset_conf __ADM((void));

/* ADMslot.c */
extern long ADMempty_slot __ADM((void));

/* ADMstorage.c */
extern int ADMget_adm_file_in __ADM((long user_id, long d_sano));

/* ADMtable.c */
extern long ADMtables_list __ADM((long user_id, MEMptr *list));

/* ADMtime.c */
extern long ADMtime_conf __ADM((void));

/* ADMtools.c */
extern int NFAmake_msg __ADM((char *mess));
extern int NFMfree_list __ADM((char **data_list, int num_rows, int num_cols));
extern int NFMput_string __ADM((char **to_string, char *string));
extern int NFMvalidate_string __ADM((char *dtype, char *string));
extern int NFMvalidate_Y_or_N __ADM((char *string));
extern int NFMput_buf_string __ADM((char **to_string, char *string, int len));
extern int NFMput_and_validate_data __ADM((char **data, int initial, int limit, int increment));
extern int ADMcheck_login_flag __ADM((void));
extern int ADMcheck_logout_flag __ADM((void));

/* ADMwr_env.c */
extern long NFMcreate_env_node __ADM((char *nodename, MEMptr schema));

/* SCatofn.c */

#undef __ADM

#endif
