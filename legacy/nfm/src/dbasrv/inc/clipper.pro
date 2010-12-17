#ifndef clipper_pro
#define clipper_pro

/* From clear_event.c */
extern void dba_clear_event (
);

/* From dis_t2.c */
extern dba_dis_t2(
  char  *filename,
  int  wno,
  int  wx1,
  int  wy1,
  int  wxh,
  int  wyh,
  int  sflag);

/* From f_clear_data.c */
extern int dba_clear_data (
  int  user_event);

/* From f_draw_line.c */
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

/* From f_draw_text.c */
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

/* From f_form_bot.c */
extern int dba_pop_form_to_bottom (
  Form  fpt);

/* From f_form_top.c */
extern int dba_pop_form_to_top (
  Form  fpt);

/* From f_get_event.c */
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

/* From f_inq_font.c */
extern int dba_inq_font (
  char  *fontname,
  int  bodysize,
  int  *font_id,
  int  *height,
  int  *width,
  int  *offset);

/* From f_insig.c */
extern void dba_insig (
);

/* From f_pixels.c */
extern int dba_get_screen_pixels (
  int  *width,
  int  *height);

/* From f_start.c */
extern int dba_start (
  int  ms_flag);

/* From f_stop_init.c */
extern int dba_stop_init (
  char  *support);

/* From f_wait_event.c */
extern int dba_wait_for_events (
);

/* From get_pnt.c */
extern int dba_get_point (
  int  window,
  int  *x,
  int  *y);

/* From getcwd.c */

/* From menu_cvt.c */
extern main (
  int  argc,
  char  *argv[]);
extern int load_menu (
  int  level);

/* From nfm_vlt.c */
extern int dba_setup_vlt (
);

/* From p_butt.c */
extern int dba_process_buttons(
  int event);

/* From p_keys.c */
extern int dba_process_keys(
  int event);

/* From risdvw.c */
extern main (
  int  argc,
  char  *argv[]);

/* From risdvw_rt.c */
extern main (
  int  argc,
  char  *argv[]);

/* From rs_win.c */
extern void dba_raise_window (
  int  window);

/* From talk_to_kb.c */
extern dba_talk_to_kb(
  char  *character,
  int  *count);

/* From trn_colr.c */
extern int dba_translate_color (
    int     vs,
    int     color);

/* From waitcurs.c */
extern void dba_wait_cursor (
  int  flag);

#endif
