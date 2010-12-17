#ifndef evras_pro
#define evras_pro

/* From dbv_adj.c */
extern void dba_adjust_window_origin(
  int  *sx,
  int  *sy);

/* From dbv_d_font.c */
extern int dba_g_font_available (
  char  *fontname,
  int    bodysize,
  int   *font_id);
extern int dba_g_calc_text(
  int    font_id,
  char  *text,
  int    length,
  int   *height,
  int   *width,
  int   *line_spacing,
  int    font_type);
extern int dba_g_draw_text(
  int    window,
  int    font_id,
  char  *text,
  int    length,
  int    xpos,
  int    ypos,
  int    font_height,
  int   *nx,
  int   *ny);
extern int dba_g_load_fs_font (
  char *  fontname,
  int      bodysize,
  int      font_type);
extern int dba_g_find_font_id(
  char  *fontname,
  float  body_size,
  int  *font_id,
  float  *actual_bodysize,
  int  gadget_type,
  int  *font_type);

/* From dbv_get_pnt.c */
extern int dba_g_get_point(
  int  *x,
  int  *y,
  struct dba_g_event  *event);

/* From dbv_proc2.c */
extern int dba_g_process_part2(
  int  ev_event);

/* From dbv_process.c */
extern int dba_g_process_event (
  int  ev_event);

/* From dbv_screen_s.c */
extern int dba_g_screen_size(
  int  *sw,
  int  *sh);

/* From dbv_tgn.c */
extern int dba_tgn_event(
  int  ev_event);

/* From dbv_wname.c */
extern int dba_g_set_window_name(
  char  *string);

/* From ers_stub.c */

#endif
