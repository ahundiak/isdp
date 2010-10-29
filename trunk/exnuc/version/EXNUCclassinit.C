#define NULL 0
#include "OMminimum.h"


/* opl version 2.4.0 */


int EX_exit_OM_class_init();
int IGEcolsup_OM_class_init();
int cmdserver_OM_class_init();
int exec_OM_class_init();
int EX_funcky_OM_class_init();
int global_class_OM_class_init();
int EX_file_OM_class_init();
int EX_close_OM_class_init();
int EX_save_OM_class_init();
int APPcolor_OM_class_init();
int IGEgadget_OM_class_init();
int EX_saveas_OM_class_init();
int EX_swapmenu_OM_class_init();
int IGEinlisnr_OM_class_init();
int EX_menuchk_OM_class_init();
int EX_rclkeyin_OM_class_init();
int EX_retri_OM_class_init();
int EX_test_OM_class_init();
int IGEwsys_OM_class_init();
int super_cmd_OM_class_init();
int EX_defbut_OM_class_init();
int CEO_OM_class_init();
int IGEingen_OM_class_init();
int IGEcolor2_OM_class_init();
int EX_pricmd_OM_class_init();
int EX_ver_OM_class_init();
int EX_fbackup_OM_class_init();
int APPcolor2_OM_class_init();
int module_OM_class_init();
int EX_bckup_OM_class_init();
int IGEcolor_OM_class_init();
int IGEwindow_OM_class_init();
int IGEuserramp_OM_class_init();

OM_p_FUNCPTR OM_GA_class_definitions[]=
 {
  EX_exit_OM_class_init,
  IGEcolsup_OM_class_init,
  cmdserver_OM_class_init,
  exec_OM_class_init,
  EX_funcky_OM_class_init,
  global_class_OM_class_init,
  EX_file_OM_class_init,
  EX_close_OM_class_init,
  EX_save_OM_class_init,
  APPcolor_OM_class_init,
  IGEgadget_OM_class_init,
  EX_saveas_OM_class_init,
  EX_swapmenu_OM_class_init,
  IGEinlisnr_OM_class_init,
  EX_menuchk_OM_class_init,
  EX_rclkeyin_OM_class_init,
  EX_retri_OM_class_init,
  EX_test_OM_class_init,
  IGEwsys_OM_class_init,
  super_cmd_OM_class_init,
  EX_defbut_OM_class_init,
  CEO_OM_class_init,
  IGEingen_OM_class_init,
  IGEcolor2_OM_class_init,
  EX_pricmd_OM_class_init,
  EX_ver_OM_class_init,
  EX_fbackup_OM_class_init,
  APPcolor2_OM_class_init,
  module_OM_class_init,
  EX_bckup_OM_class_init,
  IGEcolor_OM_class_init,
  IGEwindow_OM_class_init,
  IGEuserramp_OM_class_init,
 };

int OM_Gi_number_of_defns=33;


OMuword OPP_EX_bckup_class_id = 65535;
OMuword OPP_IGEinlisnr_class_id = 65535;
OMuword OPP_CEO_class_id = 65535;
OMuword OPP_EX_test_class_id = 65535;
OMuword OPP_IGEwsys_class_id = 65535;
OMuword OPP_IGEwindow_class_id = 65535;
OMuword OPP_module_class_id = 65535;
OMuword OPP_EX_ver_class_id = 65535;
OMuword OPP_cmdserver_class_id = 65535;
OMuword OPP_EX_menuchk_class_id = 65535;
OMuword OPP_IGEcolor_class_id = 65535;
OMuword OPP_IGEcolsup_class_id = 65535;
OMuword OPP_global_class_class_id = 65535;
OMuword OPP_EX_funcky_class_id = 65535;
OMuword OPP_APPcolor_class_id = 65535;
OMuword OPP_EX_defbut_class_id = 65535;
OMuword OPP_IGEingen_class_id = 65535;
OMuword OPP_EX_file_class_id = 65535;
OMuword OPP_EX_swapmenu_class_id = 65535;
OMuword OPP_IGEuserramp_class_id = 65535;
OMuword OPP_EX_close_class_id = 65535;
OMuword OPP_EX_exit_class_id = 65535;
OMuword OPP_APPcolor2_class_id = 65535;
OMuword OPP_exec_class_id = 65535;
OMuword OPP_EX_pricmd_class_id = 65535;
OMuword OPP_EX_retri_class_id = 65535;
OMuword OPP_IGEgadget_class_id = 65535;
OMuword OPP_super_cmd_class_id = 65535;
OMuword OPP_EX_rclkeyin_class_id = 65535;
OMuword OPP_EX_saveas_class_id = 65535;
OMuword OPP_EX_fbackup_class_id = 65535;
OMuword OPP_IGEcolor2_class_id = 65535;
OMuword OPP_EX_save_class_id = 65535;


OMuword CEO_OPP_read_t_file_method_index = 65535;
OMuword IGEcolsup_OPP_color_table_changed_method_index = 65535;
OMuword module_OPP_GRmd_active_method_index = 65535;
OMuword IGEcolor2_OPP_get_color_from_name_method_index = 65535;
OMuword IGEuserramp_OPP_get_sim_user_ramp_method_index = 65535;
OMuword IGEwindow_OPP_change_screen_method_index = 65535;
OMuword IGEgadget_OPP_clpicon_method_index = 65535;
OMuword cmdserver_OPP_init_cs_method_index = 65535;
OMuword CEO_OPP_status_method_index = 65535;
OMuword IGEcolor2_OPP_set_inq_color_params_method_index = 65535;
OMuword super_cmd_OPP_cmd_name_method_index = 65535;
OMuword IGEcolor2_OPP_delete_context_method_index = 65535;
OMuword exec_OPP_passon_method_index = 65535;
OMuword IGEcolor2_OPP_delete_clr_nam_method_index = 65535;
OMuword IGEcolor2_OPP_configure_table_method_index = 65535;
OMuword IGEwindow_OPP_reactivate_method_index = 65535;
OMuword IGEcolor2_OPP_get_name_from_color_method_index = 65535;
OMuword CEO_OPP_initial_form_notification_method_index = 65535;
OMuword IGEwindow_OPP_passon_method_index = 65535;
OMuword IGEgadget_OPP_range_intersect_method_index = 65535;
OMuword CEO_OPP_dynamics_method_index = 65535;
OMuword IGEgadget_OPP_change_gadget_size_method_index = 65535;
OMuword cmdserver_OPP_disconnect_from_stack_method_index = 65535;
OMuword module_OPP_sleep_method_index = 65535;
OMuword module_OPP_mod_init_method_index = 65535;
OMuword module_OPP_execute_mod_method_index = 65535;
OMuword IGEwindow_OPP_pop_window_method_index = 65535;
OMuword IGEcolor2_OPP_add_context_method_index = 65535;
OMuword exec_OPP_wait_for_input_method_index = 65535;
OMuword IGEgadget_OPP_delicon_method_index = 65535;
OMuword CEO_OPP_error_box_method_index = 65535;
OMuword IGEwindow_OPP_set_collapse_pos_method_index = 65535;
OMuword super_cmd_OPP_form_input_method_index = 65535;
OMuword IGEcolor2_OPP_app_con_method_index = 65535;
OMuword IGEgadget_OPP_covicon_method_index = 65535;
OMuword IGEgadget_OPP_indep_extents_method_index = 65535;
OMuword cmdserver_OPP_exec_cs_method_index = 65535;
OMuword IGEgadget_OPP_movicon_method_index = 65535;
OMuword IGEingen_OPP_generate_method_index = 65535;
OMuword IGEcolor2_OPP_get_rgb_value_method_index = 65535;
OMuword CEO_OPP_get_form_ptr_method_index = 65535;
OMuword IGEwindow_OPP_deactivate_method_index = 65535;
OMuword IGEgadget_OPP_change_process_from_method_index = 65535;
OMuword CEO_OPP_erase_form_by_label_method_index = 65535;
OMuword IGEgadget_OPP_activate_method_index = 65535;
OMuword super_cmd_OPP_wakeup_method_index = 65535;
OMuword IGEgadget_OPP_calc_dep_extents_method_index = 65535;
OMuword CEO_OPP_prompt_method_index = 65535;
OMuword CEO_OPP_display_form_by_label_method_index = 65535;
OMuword IGEgadget_OPP_change_process_to_method_index = 65535;
OMuword CEO_OPP_arg_name_to_value_method_index = 65535;
OMuword CEO_OPP_filter_method_index = 65535;
OMuword super_cmd_OPP_help_topic_method_index = 65535;
OMuword super_cmd_OPP_pre_wakeup_method_index = 65535;
OMuword global_class_OPP_super_construct_method_index = 65535;
OMuword APPcolor_OPP_load_color_table_method_index = 65535;
OMuword APPcolor2_OPP_get_color_table_method_index = 65535;
OMuword super_cmd_OPP_pre_sleep_method_index = 65535;
OMuword super_cmd_OPP_execute_method_index = 65535;
OMuword super_cmd_OPP_init_method_index = 65535;
OMuword IGEgadget_OPP_convert_pnt_method_index = 65535;
OMuword IGEcolor2_OPP_change_clr_tbl_method_index = 65535;
OMuword IGEcolor2_OPP_remap_logical_color_table_method_index = 65535;
OMuword module_OPP_mod_info_method_index = 65535;
OMuword IGEcolor2_OPP_read_clr_tbl_method_index = 65535;
OMuword cmdserver_OPP_wakeup_cs_method_index = 65535;
OMuword IGEcolor2_OPP_change_clr_nam_method_index = 65535;
OMuword super_cmd_OPP_sleep_method_index = 65535;
OMuword IGEwindow_OPP_display_name_method_index = 65535;
OMuword IGEwindow_OPP_change_cusror_def_method_index = 65535;
OMuword IGEinlisnr_OPP_listen_method_index = 65535;
OMuword IGEwindow_OPP_DPinquire_method_index = 65535;
OMuword CEO_OPP_predicate_method_index = 65535;
OMuword module_OPP_get_chan_cnt_method_index = 65535;
OMuword super_cmd_OPP_help_method_index = 65535;
OMuword module_OPP_GRmd_deactive_method_index = 65535;
OMuword super_cmd_OPP_get_command_info_method_index = 65535;
OMuword IGEcolor_OPP_app_con_method_index = 65535;
OMuword IGEcolor2_OPP_set_data_for_IGEcolor2_method_index = 65535;
OMuword CEO_OPP_real_execute_method_index = 65535;
OMuword IGEcolor_OPP_get_data_for_IGEcolor2_method_index = 65535;
OMuword super_cmd_OPP_undo_method_index = 65535;
OMuword module_OPP_GRmod_passon_method_index = 65535;
OMuword IGEwindow_OPP_window_cons_method_index = 65535;
OMuword module_OPP_GRmd_add_super_method_index = 65535;
OMuword CEO_OPP_form_notification_method_index = 65535;
OMuword IGEcolor2_OPP_get_color_functions_method_index = 65535;
OMuword IGEwindow_OPP_collapse_window_method_index = 65535;
OMuword IGEgadget_OPP_calc_indep_extents_method_index = 65535;
OMuword IGEgadget_OPP_add_gadget_method_index = 65535;
OMuword global_class_OPP_wake_up_method_index = 65535;
OMuword super_cmd_OPP_status_disp_method_index = 65535;
OMuword global_class_OPP_place_method_index = 65535;
OMuword IGEcolor2_OPP_read_clr_nam_method_index = 65535;
OMuword module_OPP_get_chan_obj_method_index = 65535;
OMuword CEO_OPP_msg_method_index = 65535;
OMuword global_class_OPP_sleep_method_index = 65535;
OMuword IGEgadget_OPP_dep_extents_method_index = 65535;
OMuword exec_OPP_wake_up_method_index = 65535;
OMuword cmdserver_OPP_sleep_cs_method_index = 65535;
OMuword cmdserver_OPP_clear_stack_method_index = 65535;
OMuword IGEwindow_OPP_draw_border_method_index = 65535;
OMuword super_cmd_OPP_abort_method_index = 65535;
OMuword CEO_OPP_action_method_index = 65535;
OMuword IGEwindow_OPP_reset_cursor_def_method_index = 65535;
OMuword IGEgadget_OPP_clear_method_index = 65535;
OMuword IGEwindow_OPP_DPset_method_index = 65535;
OMuword module_OPP_wake_up_method_index = 65535;
