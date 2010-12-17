#ifndef win16_pro
#define win16_pro

/* From comdate.c */

/* From intatod.c */

/* From intdtoa.c */

/* From w_calbak.c */
extern BOOL __export FAR PASCAL dba_system_callback (
  WORD wID,
  DWORD dwData);

/* From w_doc.c */
extern int dba_parse_doc_list(
  double  value);

/* From w_inq_fo.c */
extern int dba_inq_font (
);

/* From w_malloc.c */
extern void *dba_large_malloc(
  long size);
extern void *dba_large_realloc(
  void *memblock,
  long size);
extern void dba_large_free(
  void *memblock);
extern void *dba_malloc (
  long size);
extern void dba_free (
  void *ptr);
extern void *dba_realloc (
  void *old_ptr,
  long size);

/* From w_net_sq.c */
extern int dba_net_sql_statement(
);
extern int dba_net_sql_report_error(
);
extern int dba_net_sql_prepare(
);
extern int dba_net_sql_declare(
);
extern int dba_net_sql_describe(
);
extern int dba_net_sql_open(
);
extern int dba_net_sql_fetch(
);
extern int dba_net_sql_close(
);
extern int dba_net_sql_clear(
);
extern int dba_net_exit(
);

/* From w_prep.c */
extern int dba_srv_prepare_sql (
  char  *sqlptr);

/* From w_sql.c */
extern int dba_srv_sql (
  char  *sqlptr);
extern int dba_srv_exec_sql (
  char *sqlptr);

/* From w_sys16.c */
extern BOOL FAR PASCAL NotifyRegisterCallback (
  int WORD,
  int DWORD);

#endif
