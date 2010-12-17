#ifndef wras_pro
#define wras_pro

/* From ras_dll.c */
extern int dba_ras_get_functions(
  DBA_FUNCTION_TABLE  *dba_function_tbl,
  DBA_VARIABLE_TABLE  *dba_variable_tbl);
extern BOOL WINAPI DLLEntryPoint(
  HANDLE hDLL,
  DWORD dwReason,
  LPVOID lpReserved);

/* From ras_init.c */
extern int dba_raster_load_dll (
);
extern void dba_raster_free_dll(
);

/* From set_func.c */
extern void dba_set_functions(
  long  (*func)());

/* From w_bld_f.c */
extern int dba_build_ms_where (
  struct dba_ent  *ent_ptr,
  char  **str_ptr,
  unsigned long  *str_size);

/* From w_dm_ini.c */
extern int dba_dm_init(
);

/* From w_getpnt.c */

/* From w_locmse.c */
extern int dba_locate_vector_graphics (
  int  set,
  int  mode,
  int  view,
  double  zoom,
  int  blink);

/* From w_proc.c */
extern int dba_g_process_event (
  MSG  *msg);

/* From w_revmse.c */
extern int dba_loc_ms_elm (
);
extern int dba_review_vector_element(
);

/* From w_rs_win.c */
extern void dba_raise_window (
  HWND  window);

/* From w_scrsiz.c */
extern int dba_g_screen_size(
  int  *sw,
  int  *sh);

/* From w_wname.c */
extern int dba_g_set_window_name(
  char  *window_name);

#endif
