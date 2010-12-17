#ifndef dload_pro
#define dload_pro

/* From d_dldflg.c */
extern int dba_set_dload_msg_flags (
  int  info,
  int  warn,
  int  err,
  int  fatal);

/* From i_dload.c */
extern int dba_init_dload (
);

/* From reg_dld.c */
extern int dba_register_dload(
);

/* From s_dload.c */
extern void dba_setup_dload (
);

/* From trap_err.c */
extern dba_trap_dload_err_msg (
  char  *txt,
  long  severity);
extern dba_ignore_dload_err_msg (
  char  *txt,
  long  severity);

#endif
