#ifndef win32_pro
#define win32_pro

/* From b_g_slst.c */
extern int dba_build_grid_select_list (
  int  hwnd,
  int  label,
  char  *select,
  int  expand);

/* From exit_aud.c */
extern void dba_exit_audit (
);

/* From n_inq_fo.c */
extern int dba_inq_font (
  char  *fontname,
  int  bodysize,
  int  *font_id,
  int  *height,
  int  *width,
  int  *offset);

/* From w_brchk.c */
extern BOOL CALLBACK dba_dlg_proc(
  HWND  hDlg,
  UINT  Msg,
  WPARAM  wParam,
  LPARAM  lParam);
extern int dba_get_branding_info(
  char  *user,
  char  *company,
  char  *serno);
extern int dba_check_branding(
  char  *user,
  char  *company,
  char  *serno);
extern int dba_concurrent_licensing(
  char  *user,
  char  *company,
  char  *serno,
  int   unregistered);

/* From w_chklic.c */
extern int dba_check_license(
);

/* From w_crsprf.c */
extern char *dba_crash_getmsg (
);
extern int dba_crashproof_char (
  char  *str,
  char  *ptr);
extern int dba_crashproof_short (
  char  *str,
  char  *fmt,
  short  *ptr);
extern int dba_crashproof_long (
  char  *str,
  char  *fmt,
  long  *ptr);
extern int dba_crashproof_float (
  char  *str,
  char  *fmt,
  float  *ptr);
extern int dba_crashproof_double (
  char  *str,
  char  *fmt,
  double  *ptr);
extern int dba_crashproof_lvoid (
  char  *str,
  char  *fmt,
  lvoid  *lvp);
extern int dba_crashproof_assign (
  void  **dest,
  void  **src);
extern int dba_crashproof_fld_txt (
  Form  form,
  int  lab,
  int  row,
  int  col,
  char  *text,
  int  sel);

/* From w_dis_t2.c */
extern dba_dis_t2(
  char *filename,
  int wno,
  int wx1,
  int wy1,
  int wxh,
  int wyh,
  int sflag);

/* From w_drag.c */
extern int dba_get_dropped_files(
  char  *file);
extern int dba_drag_query_point(
  long  *x,
  long  *y);

/* From w_find_d.c */
extern int dba_find_dirs(
  char  *dir_buf,
  char  *usr_buf,
  int   fresh_start);

/* From w_find_f.c */
extern int dba_find_files(
  char  *file_buf,
  char  *usr_buf,
  int   fresh_start);

/* From w_sys32.c */
extern int dba_system (
  char  *command);

/* From w_sys32s.c */
extern int dba_system (
  char  *command);

#endif
