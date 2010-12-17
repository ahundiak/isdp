/* $Revision: 1.1 $ */
/*	Function:	dba_dummy_link */

dba_dummy_link ()
{
  dba_edit_script ();
  dba_process_script ();
  dba_process_menu_script ();
  dba_compile_report_script ();
  dba_run_report_script ();
  dba_create_global_variable ();
  dba_delete_global_variable ();
  dba_init_script ();
  dba_exec_initial_script ();
  dba_init_async ();

  dba_bug_is_func_break ();
  dba_bug_set_function ();
  dba_bug_activate_break ();
  dba_bug_get_action ();
  dba_bug_is_new_sourceline ();
  dba_bug_is_line_break ();
  dba_bug_set_sourceline ();
  dba_bug_wait ();
  dba_bug_deactivate_break ();
  dba_script_error ();
  dba_load_script ();
  dba_scr_cleanup_after_save ();
  dba_write_script ();
  dba_script_error_form ();

  dba_script_debug ();
  dba_breakpoints ();
  dba_review_variables ();
  dba_review_structure ();
  dba_review_pointer ();
  dba_process_realtime ();
  dba_reset_global_variable ();
  dba_sync_verbose_forms ();

  dba_call_convert_func ();
  dba_setup_convert_input ();
  dba_setup_convert_output ();
  dba_write_object ();

  dba_register_core ();
  dba_register_nfm ();
  dba_register_graphics ();
  dba_register_microstation ();
  dba_register_rpt ();
}
