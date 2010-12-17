#ifndef xras_pro
#define xras_pro

/* From dbx_d_font.c */
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
  Window  window,
  int     font_id,
  char   *text,
  int     length,
  int     xpos,
  int     ypos,
  int     font_height,
  int    *nx,
  int    *ny);
extern int dba_g_load_fs_font (
  char  *fontname,
  int    bodysize,
  int    font_type);
extern int dba_g_find_font_id(
  char  *fontname,
  float  body_size,
  int  *font_id,
  float  *actual_bodysize,
  int  gadget_type,
  int  *font_type);

/* From dbx_get_pnt.c */
extern int dba_g_get_point(
  int  *x,
  int  *y,
  struct dba_g_event  *event);

/* From dbx_process.c */
extern int dba_g_process_event (
  XEvent  *x_event);

/* From dbx_screen_s.c */
extern int dba_g_screen_size(
  int  *sw,
  int  *sh);

/* From dbx_tgn.c */
extern int dba_tgn_event(
  XEvent  *event);

/* From dbx_wname.c */
extern int dba_g_set_window_name(
  char  *string);

/* From xrs_stub.c */

#endif
