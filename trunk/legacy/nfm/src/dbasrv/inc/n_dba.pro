#ifndef n_dba_pro
#define n_dba_pro

/* From ab_pldwn.c */
extern int dba_ab_pulldown (
);

/* From db_items.c */
extern int dba_display_db_items (
);
extern int dba_erase_db_items (
);
extern int dba_tb_display (
  char  *toolbar,
  int  label);
extern int dba_tb_erase (
  char  *toolbar,
  int  label);
extern int dba_enable_db_items (
);
extern int dba_disable_db_items (
);
extern int dba_tb_enable (
  char  *toolbar,
  int  label);
extern int dba_tb_disable (
  char  *toolbar,
  int  label);

/* From db_pldwn.c */
extern int dba_db_pulldown (
);

/* From pd_clbak.c */
extern int dba_pd_callback (
  struct VIpalette  *palette,
  struct VIcommand  *command);

/* From rb_items.c */
extern int dba_display_rb_items (
);
extern int dba_erase_rb_items (
);

/* From rb_pldwn.c */
extern int dba_rb_pulldown (
);

/* From tb_clbak.c */
extern int dba_tb_callback (
  struct VItoolbar_item  *item);
extern int dba_process_command (
  int  label);
extern int dba_main_menu (
);
extern int dba_exit_builder (
  int  builder);

/* From v_build.c */
extern int VIbld_bitmap_from_library(
);
extern int VIbld_load_from_library(
);
extern int VIbld_palette_from_library(
);
extern int VIbld_toolbar_from_library(
);
extern int VIbld_statusbar_from_library(
);
extern int VIbld_process_application(
);
extern int VIbld_delete_current_app(
);
extern int VIbld_load_application(
  char *template);
extern int VIbld_load_palette(
  char *template);
extern int VIbld_load_toolbar(
  char *template);
extern int VIbld_load_bitmap(
  char *template);
extern int VIbld_tb_setup(
);
extern int VIbld_load_statusbar(
  char *template);
extern int VIbld_load_blank(
);
extern int VIbld_load_default(
);
extern int VIbld_default_palette(
);
extern int VIbld_blank_palette(
);
extern int VIbld_blank_toolbar(
);
extern int VIbld_default_toolbar(
);
extern int VIbld_blank_statusbar(
);
extern int VIbld_new_bitmap(
);
extern int VIbld_default_statusbar(
);
extern int VIbld_save_all(
);
extern int VIbld_save_application(
);
extern int VIbld_save_palette(
);
extern int VIbld_save_toolbar(
);
extern int VIbld_save_statusbar(
);
extern int VIbld_save_bitmap(
);
extern int VIbld_exit(
);
extern int VIbld_write_application(
  char *library,
  char *template,
  int verify_lib,
  int verify_replace);
extern int VIbld_load_app_styles(
);
extern int VIbld_load_sb_styles(
);
extern int VIbld_load_tb_styles(
);
extern int VIbld_load_tbi_styles(
  struct VItoolbar_item *item);
extern int VIbld_set_app_styles(
);
extern int VIbld_sb_ok(
);
extern int VIbld_tb_ok(
);
extern int VIbld_tbi_ok(
);
extern int VIbld_sb_dialog(
);
extern int VIbld_tb_dialog(
);
extern int VIbld_tbi_dialog(
  struct VItoolbar_item *item);
extern int VIbld_styles_dialog(
);
extern int VIbld_app_dialog(
);
extern int VIbld_pd_dialog(
  struct VIpalette *palette,
  struct VIcommand *command);
extern int VIbld_load_command_data(
  struct VIpalette *palette,
  struct VIcommand *command);
extern int VIbld_set_command_data(
);
extern int VIbld_set_palette_data(
);
extern int VIbld_add_palette_data(
);
extern int VIbld_edit_command(
  char *palette_name,
  char *command_text);
extern int VIbld_edit_palette(
  char *palette_name);
extern int VIbld_add_palette(
  char *palette_name);
extern int VIbld_get_first_not(
  char *c,
  char *string);
extern int VIbld_load_palette_data(
  struct VIpalette *palette);
extern int VIbld_load_palette_field(
);
extern int VIbld_drop_palette(
);
extern int VIbld_drop_command(
);
extern int VIbld_add_command(
  char *palette_name,
  char *command_text);
extern int VIbld_load_command_label(
);
extern int VIbld_add_command_data(
);
extern int VIbld_write_palette(
  char *library,
  struct VIpalette *palette,
  int verify_lib,
  int verify_replace);
extern int VIbld_p_ok(
);
extern int VIbld_ep_button(
);
extern int VIbld_ap_button(
);
extern int VIbld_ec_button(
);
extern int VIbld_ac_button(
);
extern int VIbld_e_ok(
);
extern int VIbld_write_toolbar(
  char *library,
  struct VItoolbar *toolbar,
  int verify_lib,
  int verify_replace);
extern int VIbld_write_statusbar(
  char *library,
  struct VIstatusbar *statusbar,
  int verify_lib,
  int verify_replace);
extern int VIbld_tb_button(
);
extern struct VIapp *VIbld_find_main(
);
extern int VIbld_delete_active_item(
);
extern int VIbld_erase_dialogs(
);
extern int VIbld_bm_ok(
);
extern int VIbld_write_bitmap(
  char *library,
  struct VIapp *app,
  int verify_lib,
  int verify_replace);
extern char *VIbld_get_bm_template_ptr(
);
extern char *VIbld_get_bm_description_ptr(
);
extern int VIbld_set_lock(
  int value);
extern int VIbld_load_acc_keys(
);
extern int VIbld_acc_drop_down(
  Form fpt,
  int label);
extern int VIbld_lookup_acc_text(
  int acc_key,
  char *string);
extern int VIbld_lookup_acc_key(
  char *string,
  int *acc_key);
extern int VI_rebuild_menubar(
);
extern int VI_rebuild_palette(
  char *palette_name,
  HMENU *menu);
extern int VIbld_down_button(
);
extern int VIbld_down_command(
  struct VIpalette *edit_palette,
  char *prev_command_text,
  char *command_text,
  char *next_command_text);
extern int VIbld_up_button(
);
extern int VIbld_up_command(
  struct VIpalette *edit_palette,
  char *prev_prev_command_text,
  char *prev_command_text,
  char *command_text);
extern int VIbld_update_commands_field(
  struct VIpalette *palette,
  char *select_command);
extern int VIbld_reset_button(
);
extern int VIbld_refresh_bitmap(
  int  form_label,
  int  event,
  Form  form);
extern int VIbld_set_menu(
);

#endif
