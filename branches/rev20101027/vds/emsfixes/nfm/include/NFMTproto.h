#ifndef NFMT_PROTO_H
#define NFMT_PROTO_H

#if defined(__STDC__) || defined(__cplusplus)
# define __NFMT(s) s
#else
# define __NFMT(s) ()
#endif


/* NFMadd_col.c */
extern int NFMadd_col __NFMT((long user_id, MEMptr list, char *new_format, long data_size, MEMptr *out_list, char *column_name));

/* NFMadd_col_v.c */
extern int NFMadd_col_val __NFMT((long user_id, MEMptr list, MEMptr *out_list, char *value));

/* NFMapp_buf.c */
extern int NFMappend_buffer __NFMT((MEMptr list, MEMptr *out_list));

/* NFMbulk.c */
extern long NFMcl_get_bulk_data __NFMT((char *node_name, char *user_name, char *passwd, long protocol, MEMptr in_list, MEMptr *out_list));
extern long NFMser_get_bulk_data __NFMT((MEMptr in_list, MEMptr *out_list));

/* NFMbulk_t.c */
extern int NFMclix_get_dir __NFMT((char *name, struct stat *buf, int flag));
extern int NFMclix_bulk_dir __NFMT((char *dirname, MEMptr *output_buffer, char *mode));
extern int NFMvms_bulk_dir __NFMT((char *dirname, MEMptr *output_buffer, char *mode));

/* NFMdir.c */
extern long NFMls_nodes __NFMT((char *type, MEMptr *output_buffer));
extern long NFMfind_files __NFMT((char *dirname, char *filename, MEMptr output_buffer));
extern long NFMsort_buffer __NFMT((MEMptr buffer));

/* NFMfto_buf.c */
extern long NFMbuild_fto_buffer __NFMT((MEMptr *list, long size));
extern int NFMwrite_format __NFMT((MEMptr *list, char *attribute, char *format, char *fname));
extern int NFMload_fto_buf __NFMT((MEMptr *list, fto_buf *buffer));

/* NFMg_str_ctr.c */
extern long NFMget_string_criteria __NFMT((long user_id, char *input_string, char *type, char *output_string));

/* NFMmulti_msg.c */
extern long NFMopen_message_buffer __NFMT((void));
extern long NFMlog_message __NFMT((void));
extern long NFMget_set_messages __NFMT((MEMptr *out_list));

/* NFMqry_t.c */
extern long NFMwrite_query_struct __NFMT((struct NFMquery_info *query, char *select, char *from, char *where, char *order, char *prompts));
extern long NFMfree_query_struct __NFMT((struct NFMquery_info *query));

/* NFMrebuild.c */
extern long NFMrebuild_data_buffer __NFMT((MEMptr attr_list, MEMptr *data_list));

/* NFMris_date.c */
extern long NFMget_ris_timestamp __NFMT((char *ret_date));

/* NFMsys_debug.c */
extern long _NFMall_debug __NFMT((int toggles[NFM_DEBUG_SUBSYSTEMS ], char files[NFM_DEBUG_SUBSYSTEMS ][NFM_DEBUG_FILE_SIZE ]));

/* NFMsys_info.c */
extern long _NFMget_wa_system_info __NFMT((char *nodename, char *username, char *pathname, MEMptr *node_info, MEMptr *sa_info));

/* NFMtic.c */
extern long NFMtic_it __NFMT((MEMptr buffer));
extern int NFMtic_to_tics __NFMT((char *in, char *out));

/* NFMtools.c */
extern long NFMfill_index __NFMT((MEMptr attr_list, NDXptr *index));
extern long NFMfill_new_index __NFMT((MEMptr attr_list, NDXnewptr *index));
extern long NFMfill_newer_index __NFMT((MEMptr attr_list, NDXnptr *index));

/* NFMutil.c */
extern long _NFMfind_column_offset __NFMT((MEMptr buffer, char *attrname, int *offset));
extern int _NFMinsert_in_place __NFMT((char *str, int position, char *value));

#undef __NFMT

#endif
