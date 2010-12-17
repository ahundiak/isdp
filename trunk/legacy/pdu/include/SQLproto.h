
/* This has been moved to PDM because it is used by PDMSQLquery fn and
   it is not delivered with standard NFM API platform. MaC 080593*/


#ifndef SQL_PROTO_H
#define SQL_PROTO_H

#if defined(__STDC__) || defined(__cplusplus)
# define __SQL(s) s
#else
# define __SQL(s) ()
#endif


/* SQLerror.c */
extern long SQLerror __SQL((long code1, long code2, long code3));

/* SQLerror.rc */
extern long SQLerror __SQL((long code1, long code2, long code3));

/* SQLexec_imm.c */
extern long SQLexec_imm __SQL((char *sql_str));

/* SQLexec_imm.rc */
extern long SQLexec_imm __SQL((char *sql_str));

/* SQLg_fmax.c */
extern long SQLget_max_filenum __SQL((char *cat_name, long *num_rows));
extern long SQLget_n_name __SQL((char *cat_name, char *n_nfmname, char *n_name));

/* SQLg_fmax.rc */
extern long SQLget_max_filenum __SQL((char *cat_name, long *num_rows));
extern long SQLget_n_name __SQL((char *cat_name, char *n_nfmname, char *n_name));

/* SQLinsert.c */
extern long SQLmultiple_insert __SQL((char *sql_str, MEMptr list));

/* SQLinsert.rc */
extern long SQLmultiple_insert __SQL((char *sql_str, MEMptr list));

/* SQLp_free.c */
extern long SQLclear_fix_qrys __SQL((void));

/* SQLp_free.rc */
extern long SQLclear_fix_qrys __SQL((void));

/* SQLp_qry10.c */
extern long SQLfix_qry_prep_10 __SQL((void));
extern long SQLfix_qry_res_10 __SQL((char *project, int *projno, int *stateno, int *aclno));
extern int SQLp_free_10 __SQL((void));

/* SQLp_qry10.rc */
extern long SQLfix_qry_prep_10 __SQL((void));
extern long SQLfix_qry_res_10 __SQL((char *project, int *projno, int *stateno, int *aclno));
extern int SQLp_free_10 __SQL((void));

/* SQLp_qry11.c */
extern long SQLfix_qry_prep_11 __SQL((void));
extern long SQLfix_qry_res_11 __SQL((char *project, int *projno));
extern int SQLp_free_11 __SQL((void));

/* SQLp_qry11.rc */
extern long SQLfix_qry_prep_11 __SQL((void));
extern long SQLfix_qry_res_11 __SQL((char *project, int *projno));
extern int SQLp_free_11 __SQL((void));

/* SQLp_qry12.c */
extern long SQLfix_qry_prep_12 __SQL((void));
extern long SQLfix_qry_res_12 __SQL((char *catalog, int *catno));
extern int SQLp_free_12 __SQL((void));

/* SQLp_qry12.rc */
extern long SQLfix_qry_prep_12 __SQL((void));
extern long SQLfix_qry_res_12 __SQL((char *catalog, int *catno));
extern int SQLp_free_12 __SQL((void));

/* SQLp_qry3.c */
extern long SQLfix_qry_prep_3 __SQL((void));
extern long SQLfix_qry_res_3 __SQL((char *table_type, char *table_name, int *table_no));
extern int SQLp_free_3 __SQL((void));

/* SQLp_qry3.rc */
extern long SQLfix_qry_prep_3 __SQL((void));
extern long SQLfix_qry_res_3 __SQL((char *table_type, char *table_name, int *table_no));
extern int SQLp_free_3 __SQL((void));

/* SQLp_qry5.c */
extern long SQLfix_qry_prep_5 __SQL((void));
extern long SQLfix_qry_res_5 __SQL((int user_no, int trans_no, int acl_no, int *u_out));
extern int SQLp_free_5 __SQL((void));

/* SQLp_qry5.rc */
extern long SQLfix_qry_prep_5 __SQL((void));
extern long SQLfix_qry_res_5 __SQL((int user_no, int trans_no, int acl_no, int *u_out));
extern int SQLp_free_5 __SQL((void));

/* SQLp_qry6.c */
extern long SQLfix_qry_prep_6 __SQL((void));
extern long SQLfix_qry_res_6 __SQL((int cmd_no, int user_no, int from_state, int *u_out, char *log_f, char *log_s, char *notify, char *trans_name));
extern int SQLp_free_6 __SQL((void));

/* SQLp_qry6.rc */
extern long SQLfix_qry_prep_6 __SQL((void));
extern long SQLfix_qry_res_6 __SQL((int cmd_no, int user_no, int from_state, int *u_out, char *log_f, char *log_s, char *notify, char *trans_name));
extern int SQLp_free_6 __SQL((void));

/* SQLp_qry7.c */
extern long SQLfix_qry_prep_7 __SQL((void));
extern long SQLfix_qry_res_7 __SQL((int user_no, int trans_no, int wf_no, int *u_out));
extern int SQLp_free_7 __SQL((void));

/* SQLp_qry7.rc */
extern long SQLfix_qry_prep_7 __SQL((void));
extern long SQLfix_qry_res_7 __SQL((int user_no, int trans_no, int wf_no, int *u_out));
extern int SQLp_free_7 __SQL((void));

/* SQLp_qry8.c */
extern long SQLfix_qry_prep_8 __SQL((void));
extern long SQLfix_qry_res_8 __SQL((int cmd_no, int user_no, int *u_out, char *log_f, char *log_s, char *notify, char *trans_name));
extern int SQLp_free_8 __SQL((void));

/* SQLp_qry8.rc */
extern long SQLfix_qry_prep_8 __SQL((void));
extern long SQLfix_qry_res_8 __SQL((int cmd_no, int user_no, int *u_out, char *log_f, char *log_s, char *notify, char *trans_name));
extern int SQLp_free_8 __SQL((void));

/* SQLp_qry9.c */
extern long SQLfix_qry_prep_9 __SQL((void));
extern long SQLfix_qry_res_9 __SQL((char *catalog, int *catno, int *stateno, int *aclno));
extern int SQLp_free_9 __SQL((void));

/* SQLp_qry9.rc */
extern long SQLfix_qry_prep_9 __SQL((void));
extern long SQLfix_qry_res_9 __SQL((char *catalog, int *catno, int *stateno, int *aclno));
extern int SQLp_free_9 __SQL((void));

/* SQLqry.c */
extern long SQLquery __SQL((char *sql_str, MEMptr *list, long size));

/* SQLqry.rc */
extern long SQLquery __SQL((char *sql_str, MEMptr *list, long size));

/* SQLstmt.c */
extern long SQLstmt __SQL((char *sql_str));

/* SQLstmt.rc */
extern long SQLstmt __SQL((char *sql_str));

/* SQLstmt_VAR.c */
extern long SQLstmt_lock_filter __SQL((char *sql_str));

/* SQLstmt_VAR.rc */
extern long SQLstmt_lock_filter __SQL((char *sql_str));

/* SQLstmtf.c */
extern long SQLstmt_VAR __SQL((char *sql_str));

/* SQLtools.c */
extern long SQLload_ris_print_format __SQL((char *ris_print_format));
extern long SQLget_ris_print_format __SQL((char *ris_print_format));
extern long SQLis_ris_print_format_good __SQL((char *ris_print_format));
extern long NFMget_datetime __SQL((char *ret_date));
extern long NFMget_date __SQL((char *ret_date));
extern long SQLload_database_type __SQL((char *db_type));
extern long SQLget_database_type __SQL((char *db_type));

#undef __SQL

#endif
