#ifndef TFER_PROTO_H
#define TFER_PROTO_H

#if defined(__STDC__) || defined(__cplusplus)
# define __TFER(s) s
#else
# define __TFER(s) ()
#endif


/* DMfile_tr.c */
extern long _DMfs_recv_files __TFER((MEMptr *buffer_ptr));
extern long _DMfs_send_files __TFER((MEMptr *buffer_ptr, long *NETid, long close_flag));
extern long NFMs_dest_recv_dmmgr __TFER((MEMptr *buffer_ptr));
extern long NFMs_src_send_dmmgr __TFER((MEMptr *buffer_ptr));
extern long _DMfs_undo_recv_files __TFER((MEMptr *buffer_ptr));
extern long DMrm_co_files __TFER((MEMptr *buffer_ptr, long *fs_net_id));
extern long _DMrm_co_files __TFER((MEMptr *buffer_ptr, long *NETid));
extern long DMs_rm_co_files __TFER((MEMptr *buffer_ptr));
extern long DMfs_get_list_attached_reference_files __TFER((char *path, char *cofilename, MEMptr *att_files_list, long filetype));
extern long _DMdo_nothing __TFER((void));

/* NFMaccept.c */
extern int NFMaccept __TFER((int *inpipe, int *outpipe, int protocol));
extern int NFMconnect __TFER((char *nodename, char *user_name, char *passwd, int server_number, int port_number, int *NETid, int protocol));
extern int NFMdisconnect __TFER((int *NETid));

/* NFMchg_files.c */
extern long NFMfs_chg_files __TFER((MEMptr *buffer_ptr));
extern long NFMrename_files __TFER((MEMptr *buffer_ptr));
extern long NFMs_rename_files __TFER((char *node_name, char *user_name, char *passwd, int protocol, MEMptr *buffer_ptr));
extern long NFMfs_rename_files __TFER((MEMptr *buffer_ptr));
extern long NFMftp_rename_files __TFER((char *node_name, char *user_name, char *passwd, char *sano, MEMptr *buffer_ptr));
extern long NFMfmu_rename_files __TFER((char *node_name, char *user_name, char *passwd, char *sano, MEMptr *buffer_ptr));
extern long NFMmove_files __TFER((MEMptr *buffer_ptr));

/* NFMcpy_file.c */
extern long NFMcopy_in_files __TFER((long user_id, MEMptr *list));
extern long NFMftp_copy_file __TFER((char *node_name, char *user_name, char *passwd, MEMptr in_list, MEMptr *out_list));
extern long NFMfmu_copy_file __TFER((char *node_name, char *user_name, char *passwd, MEMptr in_list, MEMptr *out_list));

/* NFMdel_file.c */
extern long NFMdelete_in_files __TFER((long user_id, long sa_no, char *passwd, MEMptr *list));
extern long NFMdelete_out_files __TFER((long user_id, long sa_no, char *passwd, MEMptr *list));
extern long NFMftp_delete_files_co __TFER((char *node_name, char *user_name, char *passwd, MEMptr in_list, MEMptr *out_list));
extern long NFMftp_delete_files_ci __TFER((char *node_name, char *user_name, char *passwd, MEMptr in_list, MEMptr *out_list));
extern long NFMfmu_delete_files __TFER((char *node_name, char *user_name, char *passwd, MEMptr in_list, MEMptr *out_list, long type));

/* NFMdl_files.c */
extern long _NFMdel_in_files __TFER((long user_id, long sa_no, char *passwd, MEMptr *list));

/* NFMf_tools.c */
extern int NFMfile_send __TFER((char *src_file, char *dst_file, char *attribute, int *file_size, int *NETid, int flag));
extern int NFMfile_receive __TFER((char *src_file, char *dst_file, char *attribute, int *file_size, int *NETid));
extern int NFMfile_send_s __TFER((int *inpipe, int *outpipe));
extern int NFMfile_receive_s __TFER((int *inpipe, int *outpipe));
extern int NFMswitch_disconnect __TFER((int type, int *NETid));
extern int NFMfile_copy __TFER((char *src_file, char *dst_file, char *attribute, int delete_src_flag, int *NETid));
extern int NFMfile_copy_s __TFER((int *inpipe, int *outpipe));
extern int NFMnet_oper_fail_fs __TFER((char *buffer, FILE *file_ptr, char *filename, long status));
extern int _NFMsend_stat_buf __TFER((long *NETid, long status2, char *fname2));
extern int NFMcheck_sum __TFER((char *file_name, int *checksum));
extern int NFMrecv_info __TFER((int type, int *NETid, char *info, int *length));
extern int NFMsend_info __TFER((int type, int *NETid, char *info, int *length));

/* NFMfile_cpy.c */
extern long NFMcl_copy_file __TFER((char *node_name, char *user_name, char *passwd, long protocol, MEMptr in_list, MEMptr *out_list));
extern long NFMser_copy_file __TFER((MEMptr in_list, MEMptr *out_list));

/* NFMfile_del.c */
extern long NFMcl_delete_files_co __TFER((char *node_name, char *user_name, char *passwd, long protocol, MEMptr in_list, MEMptr *out_list));
extern long NFMser_delete_files_co __TFER((MEMptr in_list, MEMptr *out_list));
extern long NFMcl_delete_files_ci __TFER((char *node_name, char *user_name, char *passwd, long protocol, MEMptr in_list, MEMptr *out_list));
extern long NFMser_delete_files_ci __TFER((MEMptr in_list, MEMptr *out_list));

/* NFMfile_in.c */
extern long NFMcl_get_files_in __TFER((char *node_name, char *user_name, char *passwd, long protocol, MEMptr in_list, MEMptr *out_list));
extern long NFMser_get_files_in __TFER((MEMptr in_list, MEMptr *out_list));

/* NFMfile_out.c */
extern long NFMcl_get_files_out __TFER((char *node_name, char *user_name, char *passwd, long protocol, MEMptr in_list, MEMptr *out_list));
extern long NFMser_get_files_out __TFER((MEMptr in_list, MEMptr *out_list));

/* NFMfile_plot.c */
extern long _NFMfs_plot_files __TFER((MEMptr *buffer_ptr));
extern long NFMs_dest_plot_clix __TFER((char *node_name, char *user_name, char *passwd, long protocol, MEMptr *buffer_ptr));
extern long NFMfs_dest_plot_clix __TFER((MEMptr *buffer_ptr));

/* NFMfile_tr.c */
extern long _NFMfs_recv_files __TFER((MEMptr *buffer_ptr));
extern long _NFMfs_send_files __TFER((MEMptr *buffer_ptr, long *NETid, long close_flag));

/* NFMfmu.c */
extern int NFMfmu_rcmd __TFER((char *command, char *output_file));

/* NFMfs_tools.c */
extern long NFMcl_receive_buffer __TFER((long *sock_no, long *in_command, MEMptr *list));
extern long NFMcl_send_buffer __TFER((long *sock_no, long out_command, MEMptr list));
extern long NFMsrv_receive_buffer __TFER((long *in_pipe, long *out_pipe, long *in_command, MEMptr *list));
extern long NFMsrv_send_buffer __TFER((long *in_pipe, long *out_pipe, long out_command, MEMptr list));
extern long NFMcl_fs_exit __TFER((long *sock_no));
extern long NFMsrv_fs_exit __TFER((long *in_pipe, long *out_pipe));

/* NFMftp.c */
extern long NFMset_ftp_def __TFER((long no_of_retries, long sleep_time, long verify));
extern long NFMftp_rename __TFER((char *node_name, char *user_name, char *passwd, char *src_file, char *dst_file, char *machid)); /* VAX - IGI */
extern long NFMftp_receive __TFER((char *node_name, char *user_name, char *passwd, char *src_file, char *dst_file, char *type, long *size));
extern long NFMftp_send __TFER((char *node_name, char *user_name, char *passwd, char *src_file, char *dst_file, char *type, long *size));
extern long NFMftp_delete __TFER((char *node_name, char *user_name, char *passwd, char *src_file, char *machid)); /* VAX - IGI */
extern long NFMftp_check_local __TFER((char *node_name, char *user_name, char *passwd, char *src_file));
extern long NFMftp_rexec __TFER((char *node_name, char *user_name, char *passwd, char *command_str));

/* NFMftr.c */
extern long _NFMftr_make_files_local __TFER((MEMptr *buffer_ptr));
extern long _NFMftr_undo_make_files_local __TFER((MEMptr *buffer_ptr));
extern long NFMftr_no_op_lock_s __TFER((int *inpipe, int *outpipe));
extern long NFMftr_options_file_reset_s __TFER((int *inpipe, int *outpipe));
extern long NFMftr_no_op_lock __TFER((long *NETid));
extern long NFMftr_options_file_reset __TFER((char *src_file, char *dst_file, char *attribute, long delete_src_flag, long *NETid));
extern long NFMftr_options_file_lock __TFER((char *node, char *user, char *pass, char *src_file, char *dst_file, char *ori_file, long *NETid, long flag));
extern long NFMftr_options_file_unlock __TFER((char *ori_file, char *dst_file, long *NETid, long flag));

/* NFMloc_sa.c */
extern long NFMload_local_sa __TFER((MEMptr *buffer_ptr));
extern int NFMget_server_sa_info __TFER((void));

/* NFMmicro.c */
extern long NFMfs_get_list_attached_reference_files __TFER((char *node_name, char *user_name, char *passwd, char *path, char *cofilename, MEMptr *att_files_list));
extern long NFMfs_get_micro_files __TFER((MEMptr in_list, MEMptr *out_list));

/* NFMmicro_get.c */
extern int _NFMget_micro_files __TFER((char *microfile, MEMptr *file_list));
extern char *NFMstrupr __TFER((char *string));
extern char *NFMstrlwr __TFER((char *string));
extern void m_r50asc __TFER((int length, short *input, char *output));
extern void set_lvl_typ __TFER((unsigned short array[], int num, int offset));
extern unsigned short bitset __TFER((unsigned short array[], int num, int offset));
extern long _NFMget_path_file __TFER((char *abs_path, char *path, char *file, long *flag));
extern long _NFMcheck_for_uniqueness __TFER((char *path, char *file));
extern long _NFMfree_REF_struct __TFER((void));

/* NFMmove_in.c */
extern long NFMmove_files_in __TFER((long user_id, long sa_no, char *passwd, MEMptr *list));
extern long NFMundo_move_files_in __TFER((long user_id, long sa_no, char *passwd, MEMptr *list));
extern long NFMfmu_ftp_get_files_in __TFER((int user_id, char *node_name, char *user_name, char *passwd, MEMptr in_list, MEMptr sa1_list, MEMptr *out_list, long type));

/* NFMmove_out.c */
extern long NFMmove_files_out __TFER((long user_id, long sa_no, char *passwd, MEMptr *list));
extern long NFMundo_move_files_out __TFER((long user_id, MEMptr *list));
extern long NFMfmu_ftp_get_files_out __TFER((int user_id, char *node_name, char *user_name, char *passwd, MEMptr in_list, MEMptr sa1_list, MEMptr *out_list, long type));

/* NFMmv_files.c */
extern long _NFMmv_files_out __TFER((long user_id, long sa_no, char *passwd, MEMptr *list));
extern long _NFMmv_files_in __TFER((long user_id, long sa_no, char *passwd, MEMptr *list));

/* NFMmv_list.c */
extern long NFMget_move_files_list __TFER((long user_id, MEMptr *list));

/* NFMnfs_clean.c */
extern long NFMfs_nfs_cleanup __TFER((char *node_name, char *user_name, char *passwd));
extern long NFMfs_dest_nfs_cleanup __TFER((MEMptr *buffer_ptr));

/* NFMpurge.c */
extern long NFMfs_purge __TFER((MEMptr *buffer_ptr));
extern long _NFMfs_undo_recv_files __TFER((MEMptr *buffer_ptr));
extern long _NFMfs_undo_send_files __TFER((MEMptr *buffer_ptr));
extern long NFMset_buf_stat __TFER((MEMptr list, long row_no, long col_no, long n_status));

/* NFMrm_files.c */
extern long NFMrm_co_files __TFER((MEMptr *buffer_ptr, long NETid));
extern long NFMs_rm_co_files __TFER((char *node_name, char *user_name, char *passwd, int protocol, MEMptr *buffer_ptr, long NETid));
extern long NFMfs_rm_co_files __TFER((MEMptr *buffer_ptr));
extern long NFMftp_rm_co_files __TFER((char *node_name, char *user_name, char *passwd, MEMptr *buffer_ptr));
extern long NFMfmu_rm_co_files __TFER((char *node_name, char *user_name, char *passwd, MEMptr *buffer_ptr));
extern long NFMrm_ci_files __TFER((MEMptr *buffer_ptr));
extern long NFMs_rm_ci_files __TFER((char *node_name, char *user_name, char *passwd, int protocol, MEMptr *buffer_ptr));
extern long NFMfs_rm_ci_files __TFER((MEMptr *buffer_ptr));
extern long NFMftp_rm_ci_files __TFER((char *node_name, char *user_name, char *passwd, char *sano, MEMptr *buffer_ptr));
extern long NFMfmu_rm_ci_files __TFER((char *node_name, char *user_name, char *passwd, char *sano, MEMptr *buffer_ptr));

/* NFMtr_files.c */
extern long NFMs_dest_recv_clix __TFER((char *node_name, char *user_name, char *passwd, long protocol, MEMptr *buffer_ptr));
extern long NFMs_src_send_clix __TFER((char *node_name, char *user_name, char *passwd, long protocol, MEMptr *buffer_ptr, long *NETid, long close_flag));
extern long NFMfs_dest_recv_clix __TFER((MEMptr *buffer_ptr));
extern long NFMfs_src_send_clix __TFER((MEMptr *buffer_ptr));
extern long NFMs_dest_recv_nonclix __TFER((char *node_name, char *user_name, char *passwd, long protocol, MEMptr *buffer_ptr));
extern long NFMs_src_send_nonclix __TFER((char *node_name, char *user_name, char *passwd, long protocol, MEMptr *buffer_ptr));

/* NFMuchg.c */
extern long NFMfs_undo_chg_files __TFER((MEMptr *buffer_ptr));
extern long NFMundo_rename_files __TFER((MEMptr *buffer_ptr));
extern long NFMs_undo_rename_files __TFER((char *node_name, char *user_name, char *passwd, int protocol, MEMptr *buffer_ptr));
extern long NFMfs_undo_rename_files __TFER((MEMptr *buffer_ptr));
extern long NFMftp_undo_rename_files __TFER((char *node_name, char *user_name, char *passwd, char *sano, MEMptr *buffer_ptr));
extern long NFMfmu_undo_rename_files __TFER((char *node_name, char *user_name, char *passwd, char *sano, MEMptr *buffer_ptr));
extern long NFMundo_move_files __TFER((MEMptr *buffer_ptr));

#undef __TFER

#endif
