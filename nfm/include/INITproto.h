#ifndef INIT_PROTO_H
#define INIT_PROTO_H

#if defined(__STDC__) || defined(__cplusplus)
# define __INIT(s) s
#else
# define __INIT(s) ()
#endif


/* NFMi_crdb.c */
extern long NFMcreate_nfmdb __INIT((MEMptr db_data, char *user_name,char *passwd, long def, MEMptr db2_data, MEMptr os_data, char *SYserver, char *SYinterfaces));

/* NFMi_dbattr.c */
extern long NFMi_init_attr __INIT((MEMptr *node_attr, MEMptr *node_data, MEMptr *st_attr, MEMptr *st_data, MEMptr *user_attr, MEMptr *user_data, MEMptr *db_attr, MEMptr *db_data, MEMptr *db2_attr, MEMptr *db2_data, MEMptr *os_attr, MEMptr *os_data));
extern long NFMi_query_db __INIT((MEMptr *attr_list, MEMptr *data_list));
extern long NFMi_query_db2 __INIT((MEMptr *attr_list, MEMptr *data_list));
extern long NFMi_query_node __INIT((MEMptr *attr_list, MEMptr *data_list));
extern long NFMi_query_storage_area __INIT((MEMptr *attr_list, MEMptr *data_list));
extern long NFMi_query_user __INIT((MEMptr *attr_list, MEMptr *data_list));

/* NFMi_enter.c */
extern int nfm_enter __INIT((char *server, char *environment, char *username, char *password, char *exec_path));
extern int nfm_exit __INIT((void));

/* NFMi_funct.c */
extern int NFMget_network_types __INIT((char *node_name, char *tcp, char *xns, char *dec));
extern int NFMget_dtype_len __INIT((char *data_ptr1, char *data_ptr2, int *len));
extern long NFMfill_index __INIT((MEMptr attr_list, NDXptr *index));
extern long NFMvalidate_nulls __INIT((MEMptr attr_list, NDXptr index, struct SCcolumn_data_st data, int pos, int *filled));
extern int NFMfree_list __INIT((char **data_list, int num_rows, int num_cols));
extern int NFMput_string __INIT((char **to_string, char *string));
extern int NFMvalidate_string __INIT((char *dtype, char *string));
extern int NFMput_buf_string __INIT((char **to_string, char *string, int len));
extern int NFMput_and_validate_data __INIT((char **data, int initial, int limit, int increment));

/* NFMi_init.c */
extern long NFMris_init __INIT((MEMptr node_attr, MEMptr node_data,MEMptr st_attr, MEMptr st_data, MEMptr user_attr, MEMptr user_data,MEMptr db_attr, MEMptr db_data, MEMptr db2_attr, MEMptr db2_data, MEMptr os_attr, MEMptr os_data, char *SYserver, char *SYinterfaces));
extern long NFMvalidate_init_buffers __INIT((MEMptr node_data, MEMptr st_data, MEMptr user_data, MEMptr db_data, MEMptr os_data, char *user_name, char *passwd));
extern long NFMupdate_db __INIT((MEMptr node_data, MEMptr user_data, MEMptr st_data));
extern long _NFMcheck_ris_bad __INIT((char *ris_bad_file));

/* NFMi_qry.c */
extern long NFMdefault_queries __INIT((void));

/* NFMi_sc.c */
extern int nfm_init __INIT((void));

/* NFMi_util.c */
extern int _NFMencrypt __INIT((char *passwd, char *e_passwd));
extern long NFMwrite_init_files __INIT((MEMptr node_attr, MEMptr node_data, MEMptr st_attr, MEMptr st_data, MEMptr user_attr, MEMptr user_data, MEMptr db_attr, MEMptr db_data));
extern long NFMcreate_ser_node __INIT((char *ser_name, MEMptr node_attr, MEMptr node_data, MEMptr st_attr, MEMptr st_data));
extern long NFMunlink_env_files __INIT((MEMptr db_attr, MEMptr db_data));
extern long NFMpre_user_interface __INIT((void));
extern long NFMcreate_directories __INIT((void));
extern long NFMremove_directories __INIT((void));
extern long NFMcreate_env_node __INIT((MEMptr node_data, MEMptr st_data, MEMptr db_data));
extern int NFMtic_to_tics __INIT((char *in, char *out));
extern int _NFMcreate_header_of_node __INIT((char *file_name));
extern int _NFMenable_nfm_sql_debug __INIT((long nfm_debug_flag, long sql_debug_flag));
extern int _NFMdisable_nfm_sql_debug __INIT((long *nfm_debug_flag, long *sql_debug_flag));

/* SCatofn.c */

#undef __INIT

#endif
