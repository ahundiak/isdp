#ifndef v_pub_pro
#define v_pub_pro

/* From v_lib.c */

/* From v_pubapi.c */
extern int VI_enter(
  HINSTANCE  instance,
  struct VIapp  **app_ptr,
  struct VIapp  **list_ptr,
  int  *(*inq_service)());
extern int VI_get_inq_service(
  int  (*(**inq_service)())());
extern int VI_set_current_app_name(
  char *app_name);
extern int VI_set_current_app(
  HWND window);
extern int VIapp_display(
  char *app_template_name);
extern int VIapp_erase(
  char *app_template_name);
extern int VIapp_set_title(
  char *app_template_name,
  char *title);
extern int VIapp_set_callback(
  char  *app_template_name,
  int  (*app_callback)());
extern int VIpd_set_callback(
  char  *app_template_name,
  int  (*app_pd_callback)());
extern int VItb_set_callback(
  char  *app_template_name,
  char  *template_name,
  int  (*tb_callback)());
extern int VIpd_add_palette(
  char *palette_name,
  int is_template,
  char *title,
  char *script);
extern int VIpd_delete_palette(
  char *palette_name);
extern struct VIcommand *VIpd_lookup_command(
  char *palette_name,
  char *command_text);
extern struct VIpalette *VIpd_lookup_palette(
  char *palette_name);
extern int VIpd_add_command(
  char *palette_name,
  char *text,
  char *script,
  int label,
  int acc_key,
  char *acc_text);
extern int VIpd_delete_command(
  char *palette_name,
  int label);
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
extern int VIpd_insert_command(
  char *palette_name,
  int precede_label,
  char *text,
  char *script,
  int label,
  int acc_key,
  char *acc_text);
extern int VIpd_enable_command(
  char *palette_name,
  int label);
extern int VIpd_disable_command(
  char *palette_name,
  int label);
extern int VIpd_set_checked(
  char *palette_name,
  int label,
  int state);
extern int VIpd_get_checked(
  char *palette_name,
  int label,
  int *state);
extern HMENU VIpd_get_menu(
  char *template);
extern int VIpd_get_index(
  char *template,
  int label);
extern HANDLE VIapp_get_window(
  char *name);
extern HANDLE VIapp_get_client(
  char *name);
extern HINSTANCE VI_get_instance(
);
extern HANDLE VIapp_get_mdi_client(
  char *name);
extern HANDLE VIdlg_get_item(
  char *template,
  int label);
extern HANDLE VIdlg_get_window(
  char *template);
extern int VIdlg_display(
  char *template,
  int perserve);
extern int VIdlg_cancel(
  char *template);
extern int VIdlg_get_form(
  char *template,
  Form *form,
  int *label);
extern int VIdlg_erase(
  char *template);
extern int VIdlg_enable(
  char *template,
  int label);
extern struct VItoolbar_item *VItb_add_button(
  char *template,
  int x,
  int y,
  int width,
  int height,
  char *off_bitmap,
  char *on_bitmap,
  char *disabled_bitmap,
  char *script,
  int label);
extern int VItb_disable(
  char *template,
  int label);
extern int VItb_enable(
  char *template,
  int label);
extern int VItb_set_item_attr(
  char *template,
  int label,
  int mode);
extern int VItb_get_item_attr(
  char *template,
  int label,
  int *mode);
extern int VItb_set_item_state(
  char *template,
  int label,
  int state);
extern int VItb_get_item_state(
  char *template,
  int label,
  int *state);
extern int VItb_delete_item(
  char *template,
  int label);
extern int VIdlg_disable(
  char *template,
  int label);
extern HANDLE VItb_get_window(
  char *template);
extern HANDLE VItb_get_item(
  char *template,
  int label);
extern HANDLE VItb_display(
  char *template);
extern int VItb_delete(
  char *template_name);
extern int VIapp_delete(
  char *template_name);
extern int VIsb_delete(
  char *template_name);
extern int VItb_erase(
  char *template);
extern HANDLE VIsb_display(
  char *template);
extern int VIsb_erase(
  char *template);
extern HANDLE VIsb_get_window(
  char *template);
extern int VIsb_set_text(
  int index,
  char *text);
extern int VIsb_get_text(
  int index,
  char *text);
extern int VI_process_script(
  char *script);
extern int VI_dload(
  char *path);
extern int VI_message_box(
  int flag,
  char *title,
  char *szFormat,
  ...);

/* From v_utl.c */
extern int VI_open_dialog(
  char *filename);
extern int VI_new_dialog(
  char *filename);
extern int VI_save_dialog(
  char *filename);
extern int VI_choose_font(
  char *fontname,
  int *size,
  int *weight,
  int *italic);

#endif
