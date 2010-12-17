#ifndef x_pro
#define x_pro

/* From x_alloc_c.c */
extern int dba_allocate_colors(
  Colormap  cmap,
  int  cmap_size);
extern int dba_translate_color(
  int  screen,
  int  color);

/* From x_butt.c */
extern int dba_x_process_buttons(
  XEvent *event);

/* From x_ck_ras.c */
extern int dba_ck_raster(
  int  form_label,
  int  event,
  Form  form);

/* From x_clear.c */
extern void dba_clear_event (
);

/* From x_conn_ustn.c */
extern int dba_connect_ustn (
);

/* From x_dis_x2.c */
extern dba_dis_x2(
  char  *filename,
  Display  *display,
  Window  *window,
  Visual  *visual,
  unsigned int  depth,
  GC  *gc,
  Colormap  *colormap,
  int  wx1,
  int  wy1,
  int  wxh,
  int  wyh,
  int  sflag);

/* From x_disp_ras.c */
extern int dba_display_raster (
  int  mnunum);

/* From x_flush.c */
extern int dba_flush (
  int  window);

/* From x_form.c */
extern int dba_x_form (
  Form  form,
  char  *name);

/* From x_form_bot.c */
extern int dba_pop_form_to_bottom (
  Form  fpt);

/* From x_form_top.c */
extern int dba_pop_form_to_top (
  Form  fpt);

/* From x_getpnt.c */
extern int dba_get_point (
  int  window,
  int  *x,
  int  *y);

/* From x_inq_font.c */
extern int dba_inq_font (
  char  *fontname,
  int  bsize,
  int  *font_id,
  int  *height,
  int  *width,
  int  *offset);

/* From x_insig.c */
extern void dba_insig (
);

/* From x_keys.c */
extern int dba_x_process_keys(
  XEvent *event);

/* From x_logkbd.c */
extern int dba_logical_keyboard (
);

/* From x_map_char.c */
extern unsigned char dba_map_character (
);

/* From x_pixels.c */
extern int dba_get_screen_pixels (
  int  *width,
  int  *height);

/* From x_prodname.c */
extern int dba_set_prodname (
  char  *name);

/* From x_rs_win.c */
extern void dba_raise_window (
  int  window);

/* From x_setup.c */
extern void dba_x_setup(
);

/* From x_start.c */
extern int dba_x_error_handler (
  Display  *display_loc,
  XErrorEvent  *error);
extern int dba_start (
  int  ms_flag);

/* From x_stop_init.c */
extern int dba_stop_init (
  char  *support);

/* From x_stub.c */

/* From x_sync.c */
extern int dba_xsync (
  int  discard);

/* From x_title.c */
extern int dba_set_dialog_title(
  Form  fpt,
  char  *title);

/* From x_wait_event.c */
extern int dba_wait_for_events (
);

/* From x_waitcurs.c */
extern void dba_wait_cursor (
  int  flag);

#endif
