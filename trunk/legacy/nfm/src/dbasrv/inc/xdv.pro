#ifndef xdv_pro
#define xdv_pro

/* From x_clipbox.c */
extern void dba_clipbox (
  int  window,
  int  x_min,
  int  y_min,
  int  x_max,
  int  y_max);

/* From x_disp_label.c */
extern int dba_display_labels (
);

/* From x_draw_line.c */
extern int dba_draw_line (
  int  window,
  int  dynamic,
  int  lineweight,
  int  style,
  int  color,
  int  x1,
  int  y1,
  int  x2,
  int  y2);

/* From x_draw_text.c */
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

/* From x_get_event.c */
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

/* From x_get_symbol.c */
extern int dba_get_symbol (
  char  *filename,
  int  *font_id);

/* From x_init_bld.c */
extern int dba_init_builders (
);

/* From x_init_drag.c */
extern int dba_init_drag (
  int  window,
  int  *x_min,
  int  *y_min,
  int  *x_max,
  int  *y_max);

/* From x_send_expos.c */
extern int dba_send_expose (
  Form  fpt,
  int  x,
  int  y,
  int  width,
  int  height);

#endif
