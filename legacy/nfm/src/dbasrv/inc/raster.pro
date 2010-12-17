#ifndef raster_pro
#define raster_pro

#include "iml.h"
#include "dba_g.def"
#include "dba_g_s.def"
#include "tgn_app.h"


/* From g_a_fl.c */
extern int dba_attach_file_link(
);

/* From g_a_l.c */
extern dba_g_attach_linkage(
);

/* From g_a_n.c */
extern int dba_attach_note(
);

/* From g_a_ul.c */
extern int dba_attach_user_link(
);

/* From g_al_s.c */
extern int dba_g_al_select(
  int  filenum,
  int page,
  struct dba_ent  *ent_ptr,
  char  *string);

/* From g_bfl.c */
extern int dba_build_font_list(
  char  *menu,
  int   label);

/* From g_bld_nl.c */
extern int dba_g_build_note_list(
  char  *filename,
  int  *num_files);
extern int dba_build_note_list(
  char  *filename,
  int  *num_files);

/* From g_build_f.c */
extern int dba_g_build_fence(
  int  *got_where,
  struct dba_ent  *ent_ptr,
  char  **s1_ptr,
  unsigned long  *s1_size,
  Form  fpt,
  int  label,
  int  row);

/* From g_check.c */
extern int dba_g_check(
  int redline);

/* From g_commands.c */
extern dba_g_commands(
  int  option);

/* From g_count_af.c */
extern int dba_count_active_files(
  int  *active_count);

/* From g_d_window.c */
extern int dba_g_delete_window(
  struct dba_g_event  *event);

/* From g_del_lnk.c */
extern int dba_g_delete_linkage(
  struct dba_g_link  *l1);

/* From g_disp_g.c */
extern int dba_display_graphics (
  char  *filename,
  int  xo,
  int  yo,
  int  width,
  int  height,
  int  page,
  int  *file_id);

/* From g_disp_l.c */
extern int dba_g_display_links(
);

/* From g_disp_n.c */
extern int dba_g_disp_note(
  int  mode,
  int  mslink);

/* From g_dm_lnk.c */
extern int dba_g_ins_dm_links(
);

/* From g_dm_str.c */
extern long dba_link_to_dm_element(
);

/* From g_dp_elm.c */
extern int dba_g_display_element(
  struct dba_g_link  *l1,
  int  opt,
  int  color);

/* From g_dyn_tg4.c */
extern int dba_g_dynamic_tg4(
);

/* From g_dyn_v.c */
extern int dba_g_dynamic_view(
);

/* From g_era_f.c */
extern int dba_erase_fence(
);

/* From g_exec.c */
extern int dba_g_exec(
  char  *string);

/* From g_exit.c */
extern int dba_g_exit(
);

/* From g_exit_g.c */
extern int dba_exit_graphics(
  int  file_id);

/* From g_expose.c */
extern int dba_g_expose(
  struct dba_g_event  *event);

/* From g_fcl.c */
extern int dba_g_build_fcl(
  int  filenum,
  int  *count,
  struct dba_g_link  **fence_list);

/* From g_fence_ex.c */
extern int dba_g_fence_exists(
);

/* From g_fit.c */
extern int dba_fit(
);

/* From g_free_l.c */
extern int dba_g_free_list(
  struct dba_g_link  *list);

/* From g_g_p.c */
extern int dba_goto_page(
  int  page);

/* From g_g_rle.c */
extern int dba_grab_rle(
  char  *file);

/* From g_get_cf.c */
extern int dba_g_get_curfile(
  tgn_win  win_handle);

/* From g_get_ex.c */
extern int dba_get_extents(
  int  file_id,
  int  *width,
  int  *height);

/* From g_get_fn.c */
extern int dba_g_get_fn(
);

/* From g_get_l.c */
extern int dba_g_get_links(
  char  *string,
  int  flag,
  int  x_pnt,
  int  y_pnt,
  int  *count,
  struct dba_g_link  **locate_list);

/* From g_get_note.c */
extern int dba_g_get_notes(
  int  number,
  char  *filename);
extern int dba_get_notes(
  int  number,
  char  *filename);

/* From g_get_pi.c */
extern int dba_get_page_info(
  int *current_page,
  int *num_pages);

/* From g_get_pts.c */
extern int dba_g_get_pts(
  double  **pts,
  int  *npts,
  int  raslink);

/* From g_get_s.c */
extern int dba_g_get_strings(
  struct dba_g_link  *link);

/* From g_get_type.c */
extern int dba_g_get_type (
  char   *filename,
  short  *type);

/* From g_get_wh.c */
extern int dba_get_win_info(
  int   *window,
  int   *win_handle,
  char  *filename);

/* From g_get_win.c */
extern int dba_get_window(
  int  *window);

/* From g_gfdata.c */
extern int dba_g_gfdata(
  int  entitynum,
  long  mslink,
  struct dba_g_files  *file_data,
  double  *x1,
  double  *y1,
  double  *z1,
  double  *x2,
  double  *y2,
  double  *z2,
  int  *linktype,
  int  *lmsl,
  int  *lpage);

/* From g_ghdl.c */
extern int  dba_g_get_hdl(
  int   window,
  long  *win_handle);

/* From g_grap.c */
extern void dba_g_hidecursor(
  int window);
extern void dba_g_showcursor(
  int window);
extern void dba_g_set_invert(
);
extern void dba_g_set_copy(
);
extern void dba_g_all_planes(
);
extern void dba_g_set_one_plane(
);
extern void dba_g_draw_rectangle(
  int  window,
  int  x,
  int  y,
  int  width,
  int  height);
extern void dba_g_draw_line(
  int  window,
  int  x1,
  int  y1,
  int  x2,
  int  y2);
extern void dba_g_draw_bitmap(
  tgn_win  win_handle,
  char  *bitmap,
  int   width,
  int   height,
  int   depth,
  int   dest_x,
  int   dest_y);
extern void dba_g_set_foreground(
  int  window,
  int  color);
extern void dba_g_set_background(
  int  window,
  int  color);
extern void dba_g_set_text_foreground(
  int  window,
  int  color);
extern void dba_g_flush(
);
extern void dba_g_lookup_color(
  char  *color_name,
  long  *number);
extern void dba_g_lookup_color_by_number(
  char  *color_name,
  long   number);
extern void dba_g_set_line_attributes(
  int  width,
  int  style,
  int  cap_style,
  int  join_style);
extern void dba_g_fill_polygon(
  int  window,
  int   *ip,
  int   np,
  int   mode,
  int   coords);
extern void dba_g_destroy_window(
  int  window);

/* From g_h_list.c */
extern int dba_g_h_list (
  struct dba_g_link  *list);

/* From g_hili.c */
extern void dba_g_highlight(
);

/* From g_hili_m.c */
extern void dba_g_highlight_m(
);

/* From g_hl.c */
extern int dba_g_hl(
  int  x1,
  int  y1,
  int  x2,
  int  y2,
  int  clr1,
  int  clr2);

/* From g_hl_m.c */
extern int dba_g_hl_m(
  double  *pts,
  int  npts,
  int  clr1,
  int  clr2);

/* From g_init.c */

/* From g_ins_l.c */
extern int dba_g_insert_linkage(
  int  filenum,
  int page,
  int  linktype,
  double  *range,
  double  *pts,
  int  npts,
  int  raslink,
  int  entnum,
  long  *mslink);

/* From g_ins_ln.c */
extern int dba_g_ins_link(
);

/* From g_ins_s.c */
extern int dba_g_insert_string(
  char  *t_string,
  int  raslink,
  int  number,
  double  text_size,
  char  *font);

/* From g_insfile.c */
extern int dba_g_insert_file(
  struct dba_g_files  *file_data);

/* From g_inside.c */
extern int dba_is_point_inside(
  struct dba_g_link  *l1,
  int  x_pnt,
  int  y_pnt);

/* From g_is_in.c */
extern int dba_is_in_fence(
  struct dba_g_link  *link);

/* From g_l_dlist.c */
extern int dba_g_load_dlist(
);

/* From g_l_file.c */
extern int dba_load_file(
);

/* From g_l_flist.c */
extern int dba_g_load_flist (
);

/* From g_load.c */
extern int dba_g_load (
  char  *node,
  char  *filename,
  int  page,
  int  flag);

/* From g_loc_gra.c */
extern int dba_g_locate_graphics(
  int  entnum,
  long  mslink,
  int  mode,
  int  view,
  double  zoom,
  int  blink);

/* From g_loc_set.c */
extern int dba_g_locate_set(
  int  set,
  int  mode,
  int  view,
  double  zoom,
  int  blink);

/* From g_locate.c */
extern int dba_locate_raster_graphics (
  int  set,
  int  mode,
  int  view,
  double  zoom,
  int  blink);

/* From g_m_form.c */
extern int dba_g_display_markup_form(
);

/* From g_m_parms.c */
extern void dba_set_color(
  char  *color);
extern void dba_get_color(
  char  *color);
extern void dba_set_font(
  char  *font);
extern void dba_get_font(
  char  *font);
extern void dba_set_level(
  int  level);
extern void dba_get_level(
  int  *level);
extern void dba_set_line_width(
  int  line_width);
extern void dba_get_line_width(
  int  *line_width);
extern void dba_set_rl_text_size(
  double  text_size);
extern void dba_get_rl_text_size(
  double  *text_size);

/* From g_max.c */
extern int dba_g_max(
  double  *pnts,
  int  npnts,
  double  *range);

/* From g_maxfn.c */
extern int dba_g_maxfn(
  int  *max_fn);

/* From g_maxlink.c */
extern int dba_g_maxlink(
  char  *tblname,
  long  *max_link);

/* From g_measure.c */
extern int dba_measure(
);

/* From g_n_name.c */
extern int dba_g_note_name(
  char  *ifile,
  char  *ofile,
  int  mslink);

/* From g_note_l.c */
extern int dba_g_note_link(
);

/* From g_ns.c */
extern int dba_not_supported(
);

/* From g_num_o.c */
extern int dba_g_num_open(
  struct dba_g_files  *in_file,
  int  *count);

/* From g_page_d.c */
extern int dba_g_page_down(
);

/* From g_page_f.c */
extern int dba_g_page_first(
);

/* From g_page_l.c */
extern int dba_g_page_last(
);

/* From g_page_u.c */
extern int dba_g_page_up(
);

/* From g_pan.c */
extern int dba_pan(
);

/* From g_pan_d.c */
extern int dba_pan_down(
);

/* From g_pan_l.c */
extern int dba_pan_left(
);

/* From g_pan_r.c */
extern int dba_pan_right(
);

/* From g_pan_u.c */
extern int dba_pan_up(
);

/* From g_parc.c */
extern int dba_place_arc(
);

/* From g_parrow.c */
extern int dba_place_arrow(
);

/* From g_pcir.c */
extern int dba_place_circle(
);

/* From g_pelli.c */
extern int dba_place_ellipse(
);

/* From g_pfcir.c */
extern int dba_place_filled_circle(
);

/* From g_pfelli.c */
extern int dba_place_filled_ellipse(
);

/* From g_pfhand.c */
extern int dba_place_freehand(
);

/* From g_pfrect.c */
extern int dba_place_filled_rectangle(
);

/* From g_pfshap.c */
extern int dba_place_filled_shape(
);

/* From g_pline.c */
extern int dba_place_line(
);

/* From g_plot_w.c */
extern int dba_plot_window(
);

/* From g_pnt_s.c */
extern void dba_g_pnt_select(
  int  filenum,
  int  page,
  double  x_pnt,
  double  y_pnt,
  char  *string);

/* From g_prect.c */
extern int dba_place_rectangle(
);

/* From g_prep.c */
extern void dba_prep_for_redlines(
);

/* From g_prlp.c */
extern int dba_place_redline_prep(
  long  color);

/* From g_pshape.c */
extern int dba_place_shape(
);

/* From g_psym.c */
extern int dba_place_symbol(
);

/* From g_ptext.c */
extern int dba_place_text(
);

/* From g_pud.c */
extern int dba_page_down(
  int file_id);
extern int dba_page_up(
  int file_id);

/* From g_put_note.c */
extern int dba_g_put_note(
  int  mslink);

/* From g_quit.c */
extern int dba_quit(
);

/* From g_r_l.c */
extern int dba_review_raster_element (
  int  change_ent,
  int  no_verify,
  int  multiple);

/* From g_r_paint.c */
extern int dba_g_r_paint (
  int  entnum,
  int  raslink,
  struct dba_ent  *ent_ptr,
  int  change_ent);

/* From g_r_sort.c */
extern void dba_g_range_sort (
  dba_g_nodeptr  low_ptr,
  dba_g_nodeptr  high_ptr);
extern dba_g_nodeptr dba_g_partition(
  dba_g_nodeptr  low_ptr,
  dba_g_nodeptr  high_ptr);
extern void dba_g_swap (
  dba_g_nodeptr  low_ptr,
  dba_g_nodeptr  high_ptr);
extern int dba_g_previous (
  dba_g_nodeptr  low_ptr,
  dba_g_nodeptr  high_ptr);

/* From g_ras_f.c */
extern int dba_g_raster_fence(
  int  type);

/* From g_rd_ctrl.c */
extern int dba_g_rd_ctrl(
  char  *filename);
extern int dba_g_key(
  char  *token);

/* From g_red_ar.c */
extern int dba_red_draw_arc(
);

/* From g_red_at.c */
extern int dba_red_draw_ann_text(
);

/* From g_red_aw.c */
extern int dba_red_draw_arrow(
);

/* From g_red_c.c */
extern int dba_red_draw_circle(
);

/* From g_red_e.c */
extern int dba_red_draw_ellipse(
);

/* From g_red_f.c */
extern int dba_red_draw_freehand(
);

/* From g_red_fc.c */
extern int dba_red_draw_filled_circle(
);

/* From g_red_fe.c */
extern int dba_red_draw_filled_ellipse(
);

/* From g_red_fr.c */
extern int dba_red_draw_filled_rectangle(
);

/* From g_red_fs.c */
extern int dba_red_draw_filled_shape(
);

/* From g_red_gf.c */
extern char *dba_hash_ascii_value(
  char  *word,
  long  len,
  long  set);
extern char *dba_red_hash_ascii_value(
  char  *word);
extern int dba_red_get_unique_filename(
  char  *path,
  char  *filename,
  char  *redline_filename);

/* From g_red_l.c */
extern int dba_red_draw_line(
);

/* From g_red_r.c */
extern int dba_red_draw_rectangle(
);

/* From g_red_s.c */
extern int dba_red_draw_shape(
);

/* From g_red_sa.c */
extern int dba_red_draw_sound_annotation(
);

/* From g_red_sy.c */
extern int dba_red_draw_symbol(
);

/* From g_red_t.c */
extern int dba_red_draw_text(
);

/* From g_redraw.c */
extern int dba_g_redraw(
  int  update_fence);

/* From g_rem_lnk.c */
extern int dba_g_remove_linkage(
);

/* From g_rf.c */
extern int dba_raster_fence(
);
extern int dba_raster_fence_multi(
);

/* From g_rlc.c */
extern long RLC_get_displayed_redlines(
);

/* From g_rm_fence.c */
extern int dba_g_remove_fence(
);

/* From g_rotate.c */
extern int dba_rotate(
);

/* From g_rsdrl.c */
extern int dba_g_reset_dmredl(
  int  val);

/* From g_sav_rl.c */
extern long dba_save_redlines(
  char  *fname);

/* From g_scroll.c */
extern int dba_scroll(
);

/* From g_sd_file.c */
extern int dba_g_shutdown_file(
  struct dba_g_files  *file);

/* From g_selfile.c */
extern int dba_g_select_file(
  struct dba_g_files  *file_data);

/* From g_set_cf.c */
extern int dba_g_set_curfile(
);

/* From g_set_sz.c */
extern int dba_g_set_w_size(
  int  *x1,
  int  *y1);

/* From g_set_type.c */
extern int dba_g_set_type(
);

/* From g_shape.c */
extern int dba_g_shape(
  int  window,
  int  npts,
  int  *pts);

/* From g_show_l.c */
extern int dba_show_links(
);

/* From g_tst_col.c */
extern int dba_g_test_column(
  char  *z_table,
  char  *z_column);

/* From g_u_f.c */
extern int dba_g_update_fence(
);

/* From g_undo.c */
extern int dba_red_undo(
);

/* From g_upd_rl.c */
extern void dba_g_upd_rl(
);

/* From g_upd_win.c */
extern void dba_update_window(
);

/* From g_update.c */
extern int dba_update(
);

/* From g_user_wn.c */
extern int dba_user_window_name(
  int  file_id,
  char  *name);

/* From g_wa.c */
extern int dba_window_area(
  int  file_id,
  int  x1,
  int  y1,
  int  x2,
  int  y2);

/* From g_warea.c */
extern int dba_window(
);

/* From g_wc.c */
extern int dba_window_center(
);

/* From g_wn.c */
extern int dba_window_name(
  int  file_id,
  char  *name);

/* From g_xf_stw.c */
extern int dba_g_xf_stw(
  int  *ip,
  double  *op,
  int  npts);

/* From g_xf_wts.c */
extern int dba_g_xf_wts(
  double  *ip,
  int  *op,
  int  npts);

/* From g_zi.c */
extern int dba_zoom_in(
);

/* From g_zo.c */
extern int dba_zoom_out(
);

/* From n_raster.c */
extern int dba_notify_raster (
  int  form_label);

/* From r_raster.c */
extern int dba_register_raster(
);

/* From scrgchek.c */
extern long dba_DM_RED_env_check (
  functiontype  *bfunc);

#endif
