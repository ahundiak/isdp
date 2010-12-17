#ifndef dde_pro
#define dde_pro

/* From dde_cb.c */
extern HDDEDATA CALLBACK DdeCallback(
  UINT wType,
  UINT wFmt,
  HCONV hConv,
  HSZ hsz1,
  HSZ hsz2,
  HDDEDATA hData,
  DWORD dwData1,
  DWORD dwData2);

/* From dde_cl.c */
#if defined WIN32
extern UINT dba_dde_connect(
  char  *service,
  char  *topic);
extern void dba_dde_disconnect(
);
extern UINT dba_dde_send_execute(
  char  *command);
extern UINT dba_dde_send_request(
  char  *result,
  char  *request);

#endif
/* From dde_init.c */
extern int dba_init_dde (
);

/* From dde_reg.c */
extern int dba_register_dde(
);

/* From dde_srv.c */
extern int dba_dde_initialize(
);
extern void dba_dde_exit(
);

/* From s_dde.c */
extern void dba_setup_dde (
);

#endif
