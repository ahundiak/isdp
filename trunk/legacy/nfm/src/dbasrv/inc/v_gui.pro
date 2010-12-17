#ifndef v_gui_pro
#define v_gui_pro

/* From dlg_grid.c */
extern int VI_dialog_grid (
  HWND  hwnd,
  struct dba_gadget  *gadg);

/* From hierarch.c */
extern int  VIh_set_default_open_icon (
);
extern int  VIh_set_default_closed_icon (
);
extern int  VIh_set_open_icon (
);
extern int  VIh_set_closed_icon (
);
extern int  VIh_get_default_open_icon_length (
);
extern int  VIh_get_default_open_icon (
);
extern int  VIh_get_default_closed_icon_length (
);
extern int  VIh_get_default_closed_icon (
);
extern int  VIh_get_open_icon_length (
);
extern int  VIh_get_open_icon (
);
extern int  VIh_get_closed_icon_length (
);
extern int  VIh_get_closed_icon (
);
extern int  VIh_set_separator (
);
extern int  VIh_get_separator (
);
extern int  VIh_get_path_length (
);
extern int  VIh_get_path (
);
extern int  VIh_set_location (
);
extern int  VIh_get_location (
);
extern int  VIh_set_size (
);
extern int  VIh_get_size (
);
extern int VIh_set_current_style (
);
extern int VIh_get_current_style (
);
extern HWND VIh_new(
);
extern int VIh_append_row (
);
extern int  VIh_clear (
);
extern int  VIh_set_text (
);
extern int  VIh_get_text_length (
);
extern int  VIh_get_text (
);
extern int  VIh_set_indent (
);
extern int  VIh_get_indent (
);
extern int  VIh_set_expand (
);
extern int  VIh_get_expand (
);
extern int  VIh_set_state (
);
extern int VIh_get_state (
);
extern int  VIh_set_attr (
);
extern int  VIh_get_attr (
);
extern int  VIh_display (
);
extern int VIh_set_command (
);
extern int VIh_get_command_length (
);
extern int VIh_get_command (
);
extern int VIh_get_event_info (
);

/* From i_bld.c */
extern int dba_init_bld (
);

/* From i_vi.c */
extern int dba_init_vi (
);

/* From mfc_init.cpp */
extern int dba_init_mfc(
  HINSTANCE hInstance,
  HINSTANCE hPrevInstance,
  LPSTR lpszCmdLine,
  int nCmdShow);

/* From mfc_term.cpp */
extern void dba_term_mfc(
);

/* From reg_bld.c */
extern int dba_register_bld(
);

/* From reg_vi.c */
extern int dba_register_vi(
);

/* From s_bld.c */
extern void dba_setup_bld (
);

/* From s_vi.c */
extern void dba_setup_vi (
);

/* From v_cb.cpp */
extern int VIgrd_set_callback(
);

/* From v_dm.cpp */

/* From v_free.c */
extern int VI_free(
);

/* From v_glook.cpp */

/* From v_gm.c */
extern int VIgm_rectangle(
  HDC hdc,
  int x1,
  int y1,
  int width,
  int height);
extern int VIgm_line(
  HDC hdc,
  int x1,
  int y1,
  int x2,
  int y2);
extern int VIgm_draw_box(
  HDC hDC,
  LPRECT lprect,
  HPEN hBorderPen,
  HPEN hShadowPen,
  int PenDepth);
extern int VIgm_load_bitmap_file(
  char *filename,
  struct VIbitmap *bitmap);

/* From v_grdapi.cpp */
extern HWND VIdm_new_window(
  char *app_name,
  int x,
  int y,
  int width,
  int height);
extern int VIdm_tile(
  char *app_name,
  int orient);
extern int VIdm_cascade(
  char *app_name);
extern int VIdm_attach_grid(
  HWND dm_window,
  int grid_label,
  double percentage);
extern int VIdm_attach_hierarchy(
  HWND dm_window,
  int h_label,
  double percentage);
extern int VIdm_detach_grid(
  HWND dm_window,
  int grid_label);
extern int VIgrd_new(
  HWND parent,
  int label,
  int x,
  int y,
  int width,
  int height,
  int rows,
  int cols,
  int fr,
  int fc,
  int rh,
  int cw,
  int visible);
extern int VIgrd_delete(
  HWND parent,
  int label);
extern int VIgrd_set_window_size(
  HWND parent,
  int label,
  int x,
  int y,
  int width,
  int height);
extern int VIgrd_get_window_size(
  HWND parent,
  int label,
  int *x,
  int *y,
  int *width,
  int *height);
extern int VIgrd_set_grid_size(
  HWND parent,
  int label,
  int n_rows,
  int n_cols,
  int nf_rows,
  int nf_cols);
extern int VIgrd_get_grid_size(
  HWND parent,
  int label,
  int *n_rows,
  int *n_cols,
  int *nf_rows,
  int *nf_cols);
extern int VIgrd_set_enabled(
  HWND parent,
  int label,
  int state);
extern int VIgrd_display(
  HWND parent,
  int label);
extern int VIgrd_erase(
  HWND parent,
  int label);
extern int VIgrd_set_font(
  HWND parent,
  int label,
  char *name,
  int size,
  int italic,
  int bold);
extern int VIgrd_get_font(
  HWND parent,
  int label,
  char *name,
  int *size,
  int *italic,
  int *bold);
extern int VIgrd_set_grid_lines(
  HWND parent,
  int label,
  int state);
extern int VIgrd_get_grid_lines(
  HWND parent,
  int label,
  int *state);
extern int VIgrd_set_border(
  HWND parent,
  int label,
  int state);
extern int VIgrd_get_border(
  HWND parent,
  int label,
  int *state);
extern int VIgrd_set_scrollbars(
  HWND parent,
  int label,
  int flag);
extern int VIgrd_get_scrollbars(
  HWND parent,
  int label,
  int *flag);
extern int VIgrd_set_text(
  HWND parent,
  int label,
  int row,
  int col,
  char *string,
  int sel_flag);
extern int VIgrd_get_text(
  HWND parent,
  int label,
  int row,
  int col,
  char *string,
  int *sel_flag);
extern int VIgrd_set_bitmap(
  HWND parent,
  int label,
  int row,
  int col,
  char *name,
  int sel_flag);
extern int VIgrd_get_bitmap(
  HWND parent,
  int label,
  int row,
  int col,
  char *name,
  int *sel_flag);
extern int VIgrd_set_selected(
  HWND parent,
  int label,
  int row,
  int col,
  int state);
extern int VIgrd_get_selected(
  HWND parent,
  int label,
  int row,
  int col,
  int *state);
extern int VIgrd_set_column_width(
  HWND parent,
  int label,
  int col,
  int width);
extern int VIgrd_get_column_width(
  HWND parent,
  int label,
  int col,
  int *width);
extern int VIgrd_set_row_height(
  HWND parent,
  int label,
  int row,
  int height);
extern int VIgrd_get_row_height(
  HWND parent,
  int label,
  int row,
  int *height);
extern int VIgrd_file_list(
  HWND parent,
  int label,
  char *filespec);
extern int VIgrd_file_count(
  HWND parent,
  int label,
  char *filespec);
extern int VIgrd_set_script(
  HWND parent,
  int label,
  char *script);
extern int VIgrd_find_by_area(
  HWND parent,
  int xlo,
  int ylo,
  int xhi,
  int yhi,
  int *num_labels,
  int **labels);
extern int VIgrd_free_memory(
);

/* From v_grid.cpp */

/* From v_gridnt.cpp */

/* From v_hl.cpp */
extern int VIh_add_to_list(
  HWND parent,
  int label,
  HWND h_w);
extern HWND VIh_lookup(
  HWND parent,
  int label);

/* From v_menu.c */
extern HMENU VIpd_create(
);
extern HMENU VIpd_create_popup(
);
extern int VIpd_set(
  HANDLE window,
  HMENU app_menu);
extern int VIpd_append(
  HMENU menu,
  UINT flags,
  UINT label,
  char *text);
extern int VIpd_get_selection(
  int index,
  int *palette_index,
  struct VIpalette **palette,
  struct VIcommand **command);
extern int VIpd_get_item(
  int palette_index,
  int label,
  int *index);
extern struct VIpalette *VIpd_get_palette_from_handle(
  HMENU hmenu);
extern struct VImb *VIpd_lookup_menubar(
  char *name);
extern int VIpd_save_menubar(
  char *name);
extern int VIpd_blank_menubar(
);
extern int VIpd_load_menubar(
  char *name);

/* From v_proces.c */
extern int VI_process_application(
  char *template_name);
extern int VI_load_application(
  char *library,
  char *template);
extern int VI_attach_app_menu(
  struct dba_library *templib);
extern int VI_load_toolbar(
  char *library,
  char *template);
extern int VI_load_statusbar(
  char *library,
  char *template);
extern int VI_load_palette(
  char *library,
  char *template,
  HMENU *menu,
  int connect);
extern int VIpd_delete_menubar(
);
extern struct VIapp *VIapp_in_builder(
);
extern int VI_check_acc_size(
);
extern int VI_load_acc_table(
  int acc_index,
  int acc_key);

/* From v_regapp.c */
extern LONG FAR PASCAL VI_new_mdi_proc(
  HWND hWnd,
  UINT Message,
  UINT wParam,
  LONG lParam);
extern int VI_register_app(
  struct VIapp *app);
extern int VI_create_app_window(
  struct VIapp *app);
extern int VI_create_toolbar_window(
  struct VIapp *app);
extern int VI_create_statusbar_window(
  struct VIapp *app);
extern LONG FAR PASCAL VIapp_wndproc(
  HWND hWnd,
  UINT Message,
  UINT wParam,
  LONG lParam);
extern LONG FAR PASCAL VItoolbar_wndproc(
  HWND hWnd,
  UINT Message,
  UINT wParam,
  LONG lParam);
extern LONG FAR PASCAL VIstatusbar_wndproc(
  HWND hWnd,
  UINT Message,
  UINT wParam,
  LONG lParam);
extern LONG FAR PASCAL VIclient_wndproc(
  HWND hWnd,
  UINT Message,
  UINT wParam,
  LONG lParam);
extern int VI_set_app_no_show(
  int app_no_show);
extern int VI_translate_accelerator(
  HWND hWnd,
  UINT Message,
  UINT wParam,
  LONG lParam);

/* From v_rt.c */
extern int VIbld_check_save(
);
extern int VIbld_set_app(
  int display_error,
  char *module);
extern int VIbld_set_edit_flag(
  int flag);
extern int VIbld_tb_enable(
);
extern int VIbld_save_no_verify(
);

/* From v_status.c */
extern int VI_draw_statusbar(
  HDC hdc,
  HANDLE window);

/* From v_tool.c */
extern int VI_draw_toolbar(
  HDC hdc,
  HANDLE window);
extern int VI_create_toolbar_items(
  struct VIapp *app);
extern struct VItoolbar_item *VI_get_toolbar_item(
  HANDLE window);
extern struct VItoolbar_item *VItb_get_item_from_label(
  int label);
extern int VI_owner_draw_button(
  DRAWITEMSTRUCT *item_ptr);
extern int VI_shade_button(
  HDC hdc,
  int x1,
  int y1,
  int width,
  int height,
  int state);

#endif
