#ifndef srv_pro
#define srv_pro

/* From dbasrv.c */
extern main(
  int  argc,
  char  **argv);
extern void dba_srv_crash (
);

/* From nfmcalls.c */
extern int dba_nfm_calls(
  long rcode,
  char *net_buffer,
  int *wcnt,
  int *status);

/* From srv_util.rc */
extern int dba_srv_sql_statement(
  char  *sql_statement);
extern int dba_srv_sql_report_error(
  char  **sql_err);
extern int dba_srv_sql_prepare(
  int  cursor,
      char  *sql_string);
extern dba_srv_sql_declare(
  int  cursor);
extern dba_srv_sql_describe(
  int  cursor,
  sqlda  *in_desc);
extern dba_srv_sql_open(
  int  cursor);
extern dba_srv_sql_close(
  int  cursor);
extern dba_srv_sql_clear(
  int  cursor);
extern dba_srv_sql_fetch(
  int  cursor,
  sqlda  *in_desc);

#endif
