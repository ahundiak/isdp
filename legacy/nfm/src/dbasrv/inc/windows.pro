#ifndef windows_pro
#define windows_pro

/* From dba_ini.c */
extern void dba_ini(
  char  *file);

/* From dtxt_32s.c */
extern int dba_draw_text (
  int  window,
  int  font_id,
  int  x,
  int  y,
  int  height,
  int  width,
  int  spacing,
  int  length,
  char  *text_ptr,
  int  option);

/* From file_loc.c */
extern int dba_file_lock(
  int fd,
  char *mode);
extern int dba_file_unlock(
  int fd);

/* From g_select.c */
extern int dba_select_gadget (
  Form  fpt,
  struct dba_gadget  *gadg);
extern int dba_unselect_gadget (
  Form  fpt,
  struct dba_gadget  *gadg);

/* From getopt.c */
extern int  getopt (
  int   argc,
  char   **argv,
  char   *optstring);

/* From i_net.c */
extern int dba_init_net (
);

/* From is_w32s.c */
extern int dba_is_win32s (
);

/* From lex_yy.c */

/* From ndba_pi.c */

/* From nris_pi.c */

/* From nrun_pi.c */

/* From s_net.c */
extern void dba_setup_net (
);

/* From v_bm.c */
extern int VIbm_load_from_file(
  char *filename);
extern int VIbm_load_from_template(
  char *library,
  char *name);
extern int VIbm_display_in_rect(
  HDC hdc,
  int index,
  RECT *rc);
extern int VIbm_display(
  HDC hdc,
  int index,
  int x,
  int y);
extern int VIbm_display_invert(
  HDC hdc,
  int index,
  int x,
  int y);
extern int VIbm_display_scaled(
  HDC hdc,
  int index,
  int x,
  int y,
  int width,
  int height,
  int flag);
extern int VIbm_clear(
  HDC hdc,
  int x,
  int y,
  int width,
  int height);
extern int VIbm_lookup(
  char *name);
extern int VIbm_get_size(
  int index,
  int *bm_width,
  int *bm_height);
extern int VIbm_check_array(
);
extern PBITMAPINFO VIbm_bitmap_header (
  int width,
  int height,
  int depth,
  struct vlt_str *vlt,
  long num_entries,
  size_t data_size);
extern VIbm_load_from_t2_file(
  int filename);

/* From v_grids.cpp */

/* From w_args.c */
extern int dba_make_args(
  char *str,
  char **argv,
  int limit);

/* From w_blk_nt.c */
extern int WINAPI dba_blocking_hook (
);
extern int dba_set_blocking_hook (
  FARPROC  hook_function);
extern int dba_unhook_blocking (
);

/* From w_blk_s.c */
extern int WINAPI dba_blocking_hook (
);
extern int dba_set_blocking_hook (
  FARPROC  hook_function);
extern int dba_unhook_blocking (
);

/* From w_butt.c */
extern int dba_w32_process_buttons(
  MSG  *msg);

/* From w_clr_ev.c */
extern void dba_clear_event (
);

/* From w_curpos.c */
extern int dba_get_point (
  HWND  window,
  int  *x,
  int  *y);

/* From w_dload.c */
extern int dba_dload (
  char  *path);
extern void dba_unload_dll_list (
);
extern void *dba_lookup_func_symbol (
  char  *name);
extern void *dba_lookup_var_symbol (
  char  *name);
extern int dba_dload_incremental (
  char  *path);
extern int dba_dload_complete (
);
extern int dba_get_last_dload_handle (
  int  *handle);

/* From w_drwlin.c */
extern int dba_draw_line (
  HWND  window,
  int  dynamic,
  int  weight,
  int  style,
  int  color,
  int  x1,
  int  y1,
  int  x2,
  int  y2);

/* From w_drwtxt.c */
extern int dba_draw_text (
  HWND  window,
  int  font_id,
  int  x,
  int  y,
  int  height,
  int  width,
  int  spacing,
  int  length,
  char  *text_ptr,
  int  option);

/* From w_form_b.c */
extern int dba_pop_form_to_bottom (
  Form  *fpt);

/* From w_form_t.c */
extern int dba_pop_form_to_top (
  Form  *fpt);

/* From w_get_ev.c */
extern int dba_get_hard_event (
  int  window,
  int  *same,
  int  *x,
  int  *y,
  int  *button,
  int  *work_status,
  int  allow_keyin,
  int  x_min,
  int  y_min,
  int  x_max,
  int  y_max,
  int  x_loc,
  int  y_loc);

/* From w_help.c */
extern int dba_about(
);
extern int dba_help(
  char   *help_file,
  int    command,
  char   *data);

/* From w_i_ras.c */
extern int dba_init_raster (
);

/* From w_keys.c */
extern int dba_w32_process_keys(
  MSG  *msg);

/* From w_mainm.c */
extern int main_menu (
  int  option);

/* From w_msgbox.c */
extern int dba_message_box(
  char *szFormat,
  ...);

/* From w_net.c */
extern int dba_net_connect(
  char *node);
extern int dba_net_close(
);
extern int dba_net_write(
  char *buffer,
  int length);
extern int dba_net_read(
  char *buffer,
  int length);

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

/* From w_nfm.c */
extern int dba_nfm_load_args(
  char *p1,
  int *offset);
extern int dba_nfm_login(
  char *server,
  char *user,
  char *passwd,
  char *env,
  		  int debug);
extern int dba_nfm_logout(
);
extern int dba_nfm_add_item(
  char *catalog,
  char *name,
  char *rev,
  char *desc,
  		     int aclno,
  int versionlimit,
  int cisano,
  char *filename,
  		     char *ci_filename,
  char *filetype);
extern int dba_nfm_checkin(
  char *catalog,
  char *name,
  char *rev,
  char *storage,
  		    char *node,
  char *user,
  char *passwd,
  		    char *path,
  char *filename);
extern int dba_nfm_checkout(
  char *catalog,
  char *name,
  char *rev,
  char *storage,
  		     char *node,
  char *user,
  char *passwd,
  		     char *path,
  char *filename);
extern int dba_nfm_copy(
  char *catalog,
  char *name,
  char *rev,
  char *storage,
  		 char *node,
  char *user,
  char *passwd,
  char *path,
  		 char *filename);
extern int dba_nfm_get_message(
  char *message);
extern int dba_nfm_delete_item(
  char *catalog,
  char *name,
  char *rev);
extern int dba_nfm_flag_item_delete(
  char *catalog,
  char *name,
  char *rev);
extern int dba_nfm_checkin_multi(
  char *catalog,
  char *name,
  char *rev,
  			  char *storage,
  char *node,
  char *user,
  			  char *passwd,
  char *path);
extern int dba_nfm_add_multi(
  char *filename);
extern int dba_nfm_add_file(
  char *catalog,
  char *name,
  char *rev,
  char *filename,
  		      char *storage,
  char *ci_filename,
  char *filetype);
extern dba_nfm_cancel_item(
  char *catalog,
  char *name,
  char *rev);
extern int dba_nfm_delete_copied_file (
  char *catalog_name,
  char *item_name,
  char *item_rev,
  char *storage_name,
  char *node,
  char *user,
  char *passwd,
  char *path,
  char *filename,
  int version);
extern int dba_nfm_set_local_file_manager (
  int state);
extern int dba_nfm_set_workflow (
  int state);
extern dba_nfm_add_node(
  char *node,
  char *desc,
  char *xns,
  			 char *tcp,
  char *nfs);
extern dba_nfm_change_node(
  char *node,
  char *c_name,
  char *c_value);
extern dba_nfm_delete_node(
  char *node);
extern dba_nfm_change_storage_area(
  char *storage,
  char *c_name,
  char *c_value);
extern dba_nfm_plot_item(
  char *catalog,
  char *name,
  char *rev);
extern dba_nfm_plot_set(
  char *catalog,
  char *name,
  char *rev);
extern dba_nfm_save_item(
  char *catalog,
  char *name,
  char *rev);
extern dba_nfm_save_set(
  char *catalog,
  char *name,
  char *rev);

/* From w_pixels.c */
extern int dba_get_screen_pixels (
  int  *width,
  int  *height);

/* From w_prep.c */
extern int dba_srv_prepare_sql (
  char  *sqlptr);

/* From w_print.c */
extern void dba_connect_console (
);
extern int dba_printf(
);
extern int dba_dprintf(
);

/* From w_prn32s.c */
extern void dba_connect_console (
);
extern int dba_printf(
  char *szFormat,
  ...);
extern int dba_dprintf(
  char *szFormat,
  ...);

/* From w_prtfil.c */
extern UINT WINAPI dba_printproc(
  HWND hwnd,
  UINT msg,
  UINT wParam,
  LONG lParam);
extern int dba_print_manager (
  char  *filename);

/* From w_pubtst.c */
extern int dba_pub_test (
);

/* From w_ris_e.c */
extern int dba_srv_report_ris_error (
);

/* From w_risrpt.c */
extern int PASCAL WinMain(
  HANDLE hInstance,
  HANDLE hPrevInstance,
  LPSTR lpszCmdLine,
  int nCmdShow);

/* From w_rundba.c */
extern int PASCAL WinMain(
  HANDLE hInstance,
  HANDLE hPrevInstance,
  LPSTR lpszCmdLine,
  int nCmdShow);

/* From w_sel.c */
extern int dba_srv_select (
);
extern int dba_srv_fetch (
);
extern int dba_srv_close_cursor (
);

/* From w_sleep.c */
extern int dba_sleep(
  int val);

/* From w_sql.c */
extern int dba_srv_sql (
  char  *sqlptr);
extern int dba_srv_exec_sql (
  char *sqlptr);

/* From w_start.c */
extern dba_start (
  int  ms_flag);

/* From w_title.c */
extern int dba_set_dialog_title(
  Form  fpt,
  char  *title);

/* From w_tmpnam.c */
extern int dba_tmpnam (
  char  *file);

/* From w_usleep.c */
extern int dba_usleep(
  int val);

/* From w_varg.c */
extern void dba_call_var_args (
  void  (*func)(),
  long  num,
  void  **args,
  char  *types,
  void  *retval,
  long  rettype,
  int  is_pascal);

/* From w_wt_ev.c */
extern int dba_wait_for_events(
);

/* From w_wtcurs.c */
extern void dba_wait_cursor (
  int  flag);

/* From wdba_pi.c */

/* From winmain.c */

/* From wm_dba.c */
extern int PASCAL WinMain(
  HANDLE hInstance,
  HANDLE hPrevInstance,
  LPSTR lpszCmdLine,
  int nCmdShow);

/* From wris_pi.c */

/* From wrun_pi.c */

/* From wtl_mallo.c */
extern void *dba_dmalloc_ex (
  unsigned long  size,
  unsigned long  desc,
  char  *file,
  int  line);
extern void *dba_dcalloc_ex (
  unsigned long  size,
  unsigned long  num,
  unsigned long  desc,
  char  *file,
  int  line);
extern void *dba_drealloc (
  void  *ptr,
  unsigned long  size);
extern char *dba_dstrdup_ex (
  char  *str,
  unsigned long  desc,
  char  *file,
  int  line);
extern void dba_dfree (
  void  *ptr);

/* From y_tab.c */
extern yyerror(
  char  *s);

#endif
