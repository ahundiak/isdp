#ifndef g_pro
#define g_pro

/* From g1_check.c */
extern int dba_g_check(
);

/* From g1_fence.c */
extern int dba_g_fence(
  int  *x1,
  int  *y1,
  int  *x2,
  int  *y2,
  struct dba_g_event  *event,
  int  erase_flag);
extern int dba_g_draw_rectangle(
  HDC hdc,
  int fx1,
  int fy1,
  int width,
  int height);

/* From g1_fit.c */
extern int dba_fit(
);

/* From g1_init.c */
extern int dba_check_raster(
);
extern HWND dba_g_parent_window = (
  int HWND);

/* From g1_load.c */
extern int dba_g_load (
  char *node,
  char *filename,
  int page);

/* From g1_set_c.c */
extern int dba_g_set_curfile(
  int window);

/* From g1_u_f.c */
extern int dba_g_update_fence(
);

/* From g1_warea.c */
extern int dba_window(
);

/* From g1_xf_stw.c */
extern int dba_g_xf_stw(
  int  *ip,
  double  *op,
  int  npts);

/* From g1_xf_wts.c */
extern int dba_g_xf_wts(
  double  *ip,
  int  *op,
  int  npts);

/* From g_bm_h.c */
extern HANDLE dba_g_bitmap_header (
  int width,
  int height,
  int depth,
  struct vlt_str *vlt,
  long num_entries);

/* From g_c_win.c */
extern int dba_g_create_window(
);
extern int dba_g_destroy_window(
  HWND window);

/* From g_find_l.c */
extern int dba_g_find_label(
  int parent_window,
  int child_label,
  long *file_id);

/* From g_get_ty.c */
extern int dba_g_get_type (
  char  *filename,
  int  *type);

/* From g_graph.c */
extern int dba_exit_graphics (
);
extern int dba_display_graphics(
);

/* From g_l_2.c */
extern int dba_g_load_type_2(
);

/* From g_l_rle.c */
extern int dba_g_load_rle(
);

/* From g_load_c.c */
extern int dba_g_load_cf(
);

/* From g_menu_g.c */
extern int dba_g_menu_graphics(
  char *filename,
  int window,
  int x1,
  int y1,
  int width,
  int height,
  int scale_flag,
  int child_label);

/* From g_motion.c */
extern int dba_g_get_motion(
  int  *x,
  int  *y,
  struct dba_g_event  *event);

/* From g_open.c */
extern int dba_g_open_dialog(
  char *filename);

/* From g_pnt.c */
extern int dba_g_get_point(
  int  *x,
  int  *y,
  struct dba_g_event  *event);

/* From g_ref.c */
extern int dba_g_refresh(
);

/* From g_stub.c */

/* From g_wproc.c */

/* From gs_raster.c */
extern void dba_setup_raster (
);

#endif
