#ifndef NFMpc_PROTO_H
#define NFMpc_PROTO_H

#if defined(__STDC__) || defined(__cplusplus)
# define __NFMpc(s) s
#else
# define __NFMpc(s) ()
#endif

/*	Added for SCO port MSSP 03 Jan 1994 */
#ifdef OS_SCO_UNIX
#include "NFMitems.h"
#include "NFMapi.h"
#endif
/*	End of addition */

/* NFMSpcfuncs.c */
extern long NFMSpc_log_in __NFMpc((char *in_list, char *out_list));
extern long NFMSpc_logout __NFMpc((char *in_list, char *out_list));
extern long NFMSpc_post_log_in __NFMpc((char *in_list, char *out_list));
extern long NFMSpc_copy_item __NFMpc((char *in_list, char *out_list));
extern long NFMSpc_co_item __NFMpc((char *in_list, char *out_list));
extern long NFMSpc_cancel_co_item __NFMpc((char *in_list, char *out_list));
extern long NFMSpc_ci_item __NFMpc((char *in_list, char *out_list));
extern long NFMSpc_copy_set __NFMpc((char *in_list, char *out_list));
extern long NFMSpc_co_set __NFMpc((char *in_list, char *out_list));
extern long NFMSpc_cancel_co_set __NFMpc((char *in_list, char *out_list));
extern long NFMSpc_ci_set __NFMpc((char *in_list, char *out_list));
extern long NFMSpc_flag_item_archive __NFMpc((char *in_list, char *out_list));
extern long NFMSpc_flag_item_backup __NFMpc((char *in_list, char *out_list));
extern long NFMSpc_flag_item_restore __NFMpc((char *in_list, char *out_list));
extern long NFMSpc_flag_set_archive __NFMpc((char *in_list, char *out_list));
extern long NFMSpc_flag_set_backup __NFMpc((char *in_list, char *out_list));
extern long NFMSpc_flag_set_restore __NFMpc((char *in_list, char *out_list));
extern long NFMSpc_cancel_item_archive __NFMpc((char *in_list, char *out_list));
extern long NFMSpc_cancel_item_backup __NFMpc((char *in_list, char *out_list));
extern long NFMSpc_cancel_item_restore __NFMpc((char *in_list, char *out_list));
extern long NFMSpc_cancel_set_archive __NFMpc((char *in_list, char *out_list));
extern long NFMSpc_cancel_set_backup __NFMpc((char *in_list, char *out_list));
extern long NFMSpc_cancel_set_restore __NFMpc((char *in_list, char *out_list));
extern long NFMSpc_validate_user_access __NFMpc((char *in_list, char *out_list));
extern long NFMSpc_set_to_state __NFMpc((char *in_list, char *out_list));
extern long NFMSpc_add_item __NFMpc((char *in_list, char *out_list));
extern long NFMSpc_query_add_item_attributes __NFMpc((char *in_list, char *out_list));
extern long NFMSpc_display_items __NFMpc((char *in_list, char *out_list));

/* NFMSpcswitch.c */
extern long NFMpc_switch_command __NFMpc((char *in_buffer, char *out_list));

/* NFMget_vals.c */
extern long NFMget_data_value __NFMpc((long user_id, MEMptr attr_list, MEMptr *data_list, MEMptr *value_list));
extern long NFMget_data_value2 __NFMpc((long user_id, MEMptr attr_list, MEMptr *data_list, MEMptr *value_list));
extern long _NFMget_data_value __NFMpc((MEMptr attr_list, MEMptr *data_list, MEMptr *value_list));
extern long _NFMget_data_value_w __NFMpc((MEMptr attr_list, MEMptr *data_list, MEMptr *value_list));
extern long NFMget_data_info __NFMpc((long user_id, MEMptr attr_list, MEMptr *data_list, MEMptr *value_list));
extern long _NFMget_value_list __NFMpc((long attrno, char *type, char *min_value, char *max_value, long def_no, long list_no, long prog_no, char *def_value, MEMptr *list, MEMptr list_buffer));
extern long _NFMget_value_list2 __NFMpc((long attrno, char *type, char *min_value, char *max_value, long def_no, long list_no, long prog_no, char *def_value, MEMptr *list, MEMptr list_buffer));
extern long NFMget_range_list __NFMpc((long user_id, char *min, char *max, MEMptr *list));
extern long _NFMget_list_list __NFMpc((long attrno, long list_no, MEMptr *list, MEMptr list_buffer));
extern long _NFMget_list_list2 __NFMpc((long attrno, long list_no, MEMptr *list, MEMptr list_buffer));
extern long NFMget_program_list __NFMpc((long user_id, long program_no, MEMptr *list));
extern long NFMget_program_value __NFMpc((long user_id, long program_no, char *value));
extern long NFMget_range_info __NFMpc((long user_id, char *min, char *max, MEMptr *list));
extern long NFMget_list_info __NFMpc((long user_id, long list_no, MEMptr *list));
extern long NFMget_program_info __NFMpc((long user_id, long program_no, MEMptr *list));
extern long NFMget_program_value_info __NFMpc((long user_id, long program_no, MEMptr *list));
extern long NFMbuild_attr_list __NFMpc((MEMptr *list));
extern long _NFMget_data_info __NFMpc((MEMptr attr_list, MEMptr *data_list, MEMptr *value_list));
extern long _NFMget_data_value_no_data_rows __NFMpc((MEMptr attr_list, MEMptr *data_list, MEMptr *value_list));
extern long _NFMget_value_info __NFMpc((long attrno, char *type, char *min_value, char *max_value, long def_no, long list_no, long prog_no, char *def_value, MEMptr *list, MEMptr list_buffer));
extern long _NFMmake_list_buf __NFMpc((long list_no, MEMptr *list, MEMptr list_buffer, long attrno));
extern long _NFMmake_range_buf __NFMpc((char *min, char *max, MEMptr *list));
extern long _NFMadd_to_value_list __NFMpc((MEMptr *attr_list, MEMptr *value_list, char *table_type, long row, long column_of_valueno));
extern long _NFMadd_to_value_list_from_query __NFMpc((MEMptr *attr_list, MEMptr *value_list, char *sql_query, long row, long column_of_valueno));
extern long _NFMget_data_value_u __NFMpc((MEMptr attr_list, MEMptr *data_list, MEMptr *value_list));

/* NFMpccanco_i.c */
extern long NFMpccancel_check_out_item __NFMpc((char *catalog_name, long catalog_no, char *item_name, char *item_revision, struct NFMwf_info wf_info, struct NFMoperation operation));

/* NFMpccanco_s.c */
extern long NFMpccancel_check_out_set __NFMpc((char *catalog_name, long catalog_no, char *set_name, char *set_revision, long set_no, struct NFMwf_info wf_info, long member_operations, struct NFMoperation *operation, long level));

/* NFMpcciitem.c */
extern long NFMpccheckin_item __NFMpc((char *catalog_name, long catalog_no, char *item_name, char *item_revision, char *working_area, struct NFMwf_info wf_info, struct NFMoperation operation));

/* NFMpcciset.c */
extern long NFMpccheckin_set __NFMpc((char *catalog_name, long catalog_no, char *set_name, char *set_revision, long set_no, char *working_area, struct NFMwf_info wf_info, long member_operations, struct NFMoperation *operation, long level));

/* NFMpccoitem.c */
extern long NFMpccheckout_item __NFMpc((char *catalog_name, long catalog_no, char *item_name, char *item_revision, char *working_area, struct NFMwf_info wf_info, struct NFMoperation operation));

/* NFMpccoset.c */
extern long NFMpccheckout_set __NFMpc((char *catalog_name, long catalog_no, char *set_name, char *set_revision, long set_no, char *working_area, struct NFMwf_info wf_info, long member_operations, struct NFMoperation *operation, long level));

/* NFMpccpitmf.c */
extern long NFMpccopy_item_files __NFMpc((char *catalog_name, long catalog_no, char *item_name, char *item_revision, char *working_area, struct NFMwf_info wf_info, struct NFMoperation operation));

/* NFMpccpsetf.c */
extern long NFMpccopy_set_files __NFMpc((char *catalog_name, long catalog_no, char *set_name, char *set_revision, long set_no, char *working_area, struct NFMwf_info wf_info, long member_operations, struct NFMoperation *operation, long level));

/* NFMpcerror.c */
extern long _NFMpc_load_message __NFMpc((char *message));
extern long _NFMpc_load_command_error __NFMpc((void));

/* NFMpcfile_s.c */
extern long _NFMpcfs_commands __NFMpc((long type_of_transfer, MEMptr *move_list));
extern long _NFMsend_buf_pc_fs_by_row __NFMpc((char *list));
extern long _NFMhandshake_abort __NFMpc((void));
extern long _NFMreceive_buf_pc_fs_by_row __NFMpc((char **list));
extern long _NFMconvert_buf_to_pcbuf __NFMpc((MEMptr list, char **pc_list));
extern long _NFMconvert_pcbuf_to_buf __NFMpc((MEMptr list, char **pc_list));
extern long _NFMpc_file_server __NFMpc((MEMptr move_list));
extern long _NFMpcfs_send_files __NFMpc((MEMptr *move_list, long *NETid, long close_flag));
extern long _NFMpcfs_undo_send_files __NFMpc((MEMptr *move_list));
extern long NFMpcfs_purge __NFMpc((MEMptr *move_list));
extern long _NFMpcfs_undo_recv_files __NFMpc((MEMptr *move_list));
extern long _NFMpcfs_recv_files __NFMpc((MEMptr *move_list));
extern long NFMpcrm_co_files __NFMpc((MEMptr *move_list, long net_id));
extern long NFMpcfs_get_list_attached_reference_files __NFMpc((char *nodename, char *username, char *passwd, char *path, char *cofilename, MEMptr *att_files_list));
extern long _NFMwrite_status_to_buffer __NFMpc((long type_of_transfer, char *pc_list, MEMptr **move_list, long *transfer_status));
extern long _NFMconvert_buf_to_list __NFMpc((MEMptr list, char **pc_list));
extern long _NFMconvert_format_to_list __NFMpc((MEMptr list, char **pc_list));
extern long _NFMsend_by_row_for_display __NFMpc((char *list));

/* NFMpcmem.c */
extern long PCmem_no_rows_columns __NFMpc((char *serverbuf, long *num_rows, long *num_cols));
extern long PCmem_get_row_size __NFMpc((char *serverbuf, long row_number, long *row_size));
extern long PCmem_get_buffer_size __NFMpc((char *serverbuf, long *buffer_size));
extern long PCmem_read_data __NFMpc((char *serverbuf, long row_number, long column_number, char *value));
extern long PCmem_read_row __NFMpc((char *serverbuf, long row_number, char *str));
extern long PCmem_get_address_of_read_data __NFMpc((char *serverbuf, long row_number, long column_number, long *address));
extern long PCmem_write_data __NFMpc((char *serverbuf, long row_number, long column_number, char *new_data));
extern long PCmem_read_data_non_string __NFMpc((char *serverbuf, long row_number, long column_number, char *value));
extern long _NFMpc_write_row __NFMpc((char **list_ptr, char *str));
extern long _NFMpc_print_mem_buffer __NFMpc((char *title, char *list, char *filename));
extern long _NFMpc_build_buffer __NFMpc((char **list_ptr, long no_columns));
extern long _NFMfind_value_pc_buf __NFMpc((char *in_list, char *column_name, long row_number, char *value));

/* NFMpcms.c */
extern long NFMpcupdate_microstation_file __NFMpc((long num_of_members, struct NFMset_member *list_members, struct NFMset_member **new_member_list, struct NFMsto_info sa_struct, struct NFMoperation *operation, long *no_dropped, long *no_added, long ms_p_catno, long ms_p_itemno, struct file_info_struct **file_info));
extern long NFMpcbuild_microstation_set __NFMpc((char *p_catalogname, long p_catalogno, long p_itemno, char *n_cofilename, long *promoted_to_set, struct NFMsto_info sa_struct));

/* NFMpcms_t.c */
extern long _NFMpcdelete_file_LFM __NFMpc((long no_dropped, struct NFMset_member *list_member, struct file_info_struct *file_info, struct NFMsto_info sa_struct, struct NFMoperation *operation));

/* NFMpcserver.c */
extern int main __NFMpc((int argc, char *argv[]));
extern int Signal_function __NFMpc((int sig));

/* NFMpctools.c */
extern long NFMvalidate_pc_filename __NFMpc((char *filename));

#undef __NFMpc

#endif
