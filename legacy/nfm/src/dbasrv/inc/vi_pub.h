#ifndef vi_proto_h
#define vi_proto_h


extern int VI_choose_font(
  char *fontname,
  int *size,
  int *weight,
  int *italic);


extern int VI_dload(
  char *path);


extern HINSTANCE VI_get_instance(
);


extern int VI_message_box(
  int flag,
  char *title,
  char *szFormat,
  ...);


extern int VI_new_dialog(
  char *filename);


extern int VI_open_dialog(
  char *filename);


extern int VI_process_script(
  char *script);


extern int VI_save_dialog(
  char *filename);


extern int VIapp_delete(
  char *template_name);


extern int VIapp_display(
  char *app_template_name);


extern int VIapp_erase(
  char *app_template_name);


extern HANDLE VIapp_get_client(
  char *name);


extern HANDLE VIapp_get_mdi_client(
  char *name);


extern HANDLE VIapp_get_window(
  char *name);


extern int VIdlg_cancel(
  char *template);


extern int VIdlg_disable(
  char *template,
  int label);


extern int VIdlg_display(
  char *template,
  int perserve);


extern int VIdlg_enable(
  char *template,
  int label);


extern int VIdlg_erase(
  char *template);


extern int VIdlg_get_form(
  char *template,
  Form *form,
  int *label);


extern HANDLE VIdlg_get_item(
  char *template,
  int label);


extern HANDLE VIdlg_get_window(
  char *template);


extern int VIdm_attach_grid(
  HWND dm_window,
  int grid_label,
  double percentage);


extern int VIdm_attach_hierarchy(
  HWND dm_window,
  int h_label,
  double percentage);


extern int VIdm_cascade(
  char *app_name);


extern int VIdm_detach_grid(
  HWND dm_window,
  int grid_label);


extern HWND VIdm_new_window(
  char *app_name,
  int x,
  int y,
  int width,
  int height);


extern int VIdm_tile(
  char *app_name,
  int orient);


extern int VIgrd_delete(
  HWND parent,
  int label);


extern int VIgrd_display(
  HWND parent,
  int label);


extern int VIgrd_erase(
  HWND parent,
  int label);


extern int VIgrd_file_count(
  HWND parent,
  int label,
  char *filespec);


extern int VIgrd_file_list(
  HWND parent,
  int label,
  char *filespec);


extern int VIgrd_get_bitmap(
  HWND parent,
  int label,
  int row,
  int col,
  char *name,
  int *sel_flag);


extern int VIgrd_get_border(
  HWND parent,
  int label,
  int *state);


extern int VIgrd_get_column_width(
  HWND parent,
  int label,
  int col,
  int *width);


extern int VIgrd_get_font(
  HWND parent,
  int label,
  char *name,
  int *size,
  int *italic,
  int *bold);


extern int VIgrd_get_grid_lines(
  HWND parent,
  int label,
  int *state);


extern int VIgrd_get_grid_size(
  HWND parent,
  int label,
  int *n_rows,
  int *n_cols,
  int *nf_rows,
  int *nf_cols);


extern int VIgrd_get_row_height(
  HWND parent,
  int label,
  int row,
  int *height);


extern int VIgrd_get_scrollbars(
  HWND parent,
  int label,
  int *flag);


extern int VIgrd_get_selected(
  HWND parent,
  int label,
  int row,
  int col,
  int *state);


extern int VIgrd_get_text(
  HWND parent,
  int label,
  int row,
  int col,
  char *string,
  int *sel_flag);


extern int VIgrd_get_window_size(
  HWND parent,
  int label,
  int *x,
  int *y,
  int *width,
  int *height);


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


extern int VIgrd_set_bitmap(
  HWND parent,
  int label,
  int row,
  int col,
  char *name,
  int sel_flag);


extern int VIgrd_set_border(
  HWND parent,
  int label,
  int state);


extern int VIgrd_set_column_width(
  HWND parent,
  int label,
  int col,
  int width);


extern int VIgrd_set_enabled(
  HWND parent,
  int label,
  int state);


extern int VIgrd_set_font(
  HWND parent,
  int label,
  char *name,
  int size,
  int italic,
  int bold);


extern int VIgrd_set_grid_lines(
  HWND parent,
  int label,
  int state);


extern int VIgrd_set_grid_size(
  HWND parent,
  int label,
  int n_rows,
  int n_cols,
  int nf_rows,
  int nf_cols);


extern int VIgrd_set_row_height(
  HWND parent,
  int label,
  int row,
  int height);


extern int VIgrd_set_script(
  HWND parent,
  int label,
  char *script);


extern int VIgrd_set_scrollbars(
  HWND parent,
  int label,
  int flag);


extern int VIgrd_set_selected(
  HWND parent,
  int label,
  int row,
  int col,
  int state);


extern int VIgrd_set_text(
  HWND parent,
  int label,
  int row,
  int col,
  char *string,
  int sel_flag);


extern int VIgrd_set_window_size(
  HWND parent,
  int label,
  int x,
  int y,
  int width,
  int height);

extern int VIh_append_row (
);


extern int  VIh_clear (
);


extern int  VIh_display (
);


extern int  VIh_get_attr (
);


extern int  VIh_get_closed_icon (
);


extern int  VIh_get_closed_icon_length (
);


extern int VIh_get_command (
);


extern int VIh_get_command_length (
);


extern int VIh_get_current_style (
);


extern int  VIh_get_default_closed_icon (
);


extern int  VIh_get_default_closed_icon_length (
);


extern int  VIh_get_default_open_icon (
);


extern int  VIh_get_default_open_icon_length (
);


extern int VIh_get_event_info (
);


extern int  VIh_get_expand (
);


extern int  VIh_get_indent (
);


extern int  VIh_get_location (
);


extern int  VIh_get_open_icon (
);


extern int  VIh_get_open_icon_length (
);


extern int  VIh_get_path (
);


extern int  VIh_get_path_length (
);


extern int  VIh_get_separator (
);


extern int  VIh_get_size (
);


extern int VIh_get_state (
);


extern int  VIh_get_text (
);


extern int  VIh_get_text_length (
);


extern HWND VIh_new(
);


extern int  VIh_set_attr (
);


extern int  VIh_set_closed_icon (
);


extern int VIh_set_command (
);


extern int VIh_set_current_style (
);


extern int  VIh_set_default_closed_icon (
);


extern int  VIh_set_default_open_icon (
);


extern int  VIh_set_expand (
);


extern int  VIh_set_indent (
);


extern int  VIh_set_location (
);


extern int  VIh_set_open_icon (
);


extern int  VIh_set_separator (
);


extern int  VIh_set_size (
);


extern int  VIh_set_state (
);


extern int  VIh_set_text (
);



extern int VIpd_add_command(
  char *palette_name,
  char *text,
  char *script,
  int label,
  int acc_key,
  char *acc_text);


extern int VIpd_add_palette(
  char *palette_name,
  int is_template,
  char *title,
  char *script);


extern int VIpd_blank_menubar(
);


extern int VIpd_change_command(
  char *palette_name,
  int label,
  char *text,
  char *script,
  int acc_key,
  char *acc_text);


extern int VIpd_change_palette(
  char *palette_name,
  int label,
  char *title,
  char *script);


extern int VIpd_delete_command(
  char *palette_name,
  int label);


extern int VIpd_delete_menubar(
);


extern int VIpd_delete_palette(
  char *palette_name);


extern int VIpd_disable_command(
  char *palette_name,
  int label);


extern int VIpd_enable_command(
  char *palette_name,
  int label);


extern int VIpd_get_checked(
  char *palette_name,
  int label,
  int *state);


extern int VIpd_get_index(
  char *template,
  int label);


extern HMENU VIpd_get_menu(
  char *template);


extern int VIpd_insert_command(
  char *palette_name,
  int precede_label,
  char *text,
  char *script,
  int label,
  int acc_key,
  char *acc_text);


extern int VIpd_load_menubar(
  char *name);


extern int VIpd_save_menubar(
  char *name);


extern int VIpd_set_checked(
  char *palette_name,
  int label,
  int state);


extern HANDLE VIsb_display(
  char *template);


extern int VIsb_erase(
  char *template);


extern int VIsb_get_text(
  int index,
  char *text);


extern HANDLE VIsb_get_window(
  char *template);


extern int VIsb_set_text(
  int index,
  char *text);


extern int VItb_disable(
  char *template,
  int label);


extern HANDLE VItb_display(
  char *template);


extern int VItb_enable(
  char *template,
  int label);


extern int VItb_erase(
  char *template);



extern HANDLE VItb_get_item(
  char *template,
  int label);


extern int VItb_get_item_attr(
  char *template,
  int label,
  int *mode);


extern int VItb_get_item_state(
  char *template,
  int label,
  int *state);


extern HANDLE VItb_get_window(
  char *template);


extern int VItb_set_item_attr(
  char *template,
  int label,
  int mode);


extern int VItb_set_item_state(
  char *template,
  int label,
  int state);

#endif
