#ifndef NDBA_PROTO_H
#define NDBA_PROTO_H

#if defined(__STDC__) || defined(__cplusplus)
# define __NDBA(s) s
#else
# define __NDBA(s) ()
#endif


/* NFFacl_class.c */
extern long NFFadd_acl_class_users __NDBA((int type, char *acl_name));
extern long NFFdelete_acl_class_users __NDBA((char *acl_name));

/* NFFacl_clusr.c */
extern long _NFFadd_acl_class_users __NDBA((NFFmap entity));
extern long _NFFadd_acl_class_users_notify __NDBA((int g_label, int row, Form *form));
extern long _NFFdelete_acl_class_users __NDBA((NFFmap entity));
extern long _NFFdelete_acl_class_users_notify __NDBA((int g_label, int row, Form *form));
extern long _NFFacl_load_class_data_list __NDBA((Form form, NFFmap entity, int row, char *keyword));

/* NFFacl_mcf.c */
extern long _NFFacl_load_value_list __NDBA((Form form, NFFmap entity, char *attribute, int filter_flag));
extern long _NFFacl_create_mcf __NDBA((Form form, int label));
extern long _NFFacl_load_mcf __NDBA((Form form, int filter_flag, int value_row, char *attribute, MEMptr attr_list, MEMptr data_list, MEMptr value_list));
extern long _NFFacl_load_add_mcf __NDBA((Form form, int label, int value_row, char *attribute, MEMptr attr_list, MEMptr data_list, MEMptr value_list));
extern long _NFFacl_load_delete_mcf __NDBA((Form form, int label, int value_row, char *attribute, MEMptr attr_list, MEMptr data_list, MEMptr value_list));

/* NFFacl_sign.c */
extern long NFFadd_acl_signoff_users __NDBA((char *acl_name));
extern long NFFdelete_acl_signoff_users __NDBA((char *acl_name));

/* NFFacl_susr.c */
extern long _NFFload_acl_signoff_users __NDBA((Form form, NFFmap entity));
extern long _NFFadd_acl_signoff_users __NDBA((NFFmap entity));
extern long _NFFadd_acl_signoff_users_notify __NDBA((int g_label, int row, Form *form));
extern long _NFFdelete_acl_signoff_users __NDBA((NFFmap entity));
extern long _NFFdelete_acl_signoff_users_notify __NDBA((int g_label, int row, Form *form));
extern long _NFFacl_load_signoff_data_list __NDBA((Form form, NFFmap entity, int row, char *keyword));

/* NFFacl_tools.c */
extern long _NFFacl_write_data __NDBA((NFFmap entity, int value_row, char *userno, char *attribute, char *keyword));
extern long _NFFacl_add_write_data __NDBA((NFFmap entity, int value_row, char *attribute));
extern long _NFFacl_delete_write_data __NDBA((MEMptr attr_list, MEMptr data_list, MEMptr value_list, int value_row, char *userno, char *attribute));
extern long _NFFacl_set_title __NDBA((NFFmap entity, char *title1, char *title2, char *add_or_delete));
extern long _NFFacl_set_title_add __NDBA((NFFmap entity, char *title1, char *title2, int value_row, int current_no, char *current_name));
extern long _NFFacl_set_title_delete __NDBA((NFFmap entity, char *title1, char *title2, int value_row, int current_no, char *current_name));

/* NFFadd.c */
extern long _NFFadd_attributes_field __NDBA((Form form, int row_no, char *write_or_update, NFFadd_ptr ptr));
extern long _NFFadd_value_field __NDBA((Form form, char *write_or_update, NFFadd_ptr ptr));
extern long _NFFadd_validate_field __NDBA((Form form, int row, char *write_or_update, NFFadd_ptr ptr));
extern long _NFFadd_set_lower_half __NDBA((Form form, char *write_or_update, NFFadd_ptr ptr));
extern long _NFFadd_set_advisory_info __NDBA((Form form, NFFadd_ptr ptr));
extern long _NFFadd_validate_text __NDBA((char *text, MEMptr value_list));
extern long _NFFadd_load_attributes __NDBA((Form form, NFFadd_ptr ptr, char *write_attr));
extern long _NFFadd_disable_lower_half __NDBA((Form form, NFFadd_ptr ptr));
extern long _NFFadd_validate_accept __NDBA((Form form, char *write_attr, NFFadd_ptr ptr));
extern long _NFFadd_select_next_attribute __NDBA((Form form, char *write_or_update, NFFadd_ptr ptr));
extern void _NFFfree_add __NDBA((NFFadd_ptr ptr, Form *form));

/* NFFadd_acl.c */
extern long NFFadd_acl __NDBA((void));
extern long _NFFadd_acl_notify __NDBA((int g_label, int row, Form *form));

/* NFFadd_file.c */
extern long NFFadd_files_to_item __NDBA((char *catalog, char *item, char *revision));

/* NFFadd_init.c */
extern long NFFadd_init __NDBA((char *entity, int command));
extern long _NFFadd_notify __NDBA((int g_label, int row, Form *form));

/* NFFadd_map.c */
extern long _NFFadd_mapping __NDBA((char *title1, char *title2, NFFmap entity));
extern long _NFFadd_map_notify __NDBA((int g_label, int row, Form *form));
extern long _NFFmap_bottom_mcf __NDBA((Form form, int label, int row));
extern long _NFFmap_load_data_list __NDBA((Form form, MEMptr data_list, int attr_row_offset, char *keyword));
extern long _NFFmap_write_blank_row __NDBA((MEMptr data_list));

/* NFFadd_mcf.c */
extern long _NFFadd_create_mcf __NDBA((Form form, int label, MEMptr value_list));
extern long _NFFadd_load_mcf __NDBA((Form form, int label, MEMptr value_list));

/* NFFadd_usa.c */
extern long NFFadd_util_storage_area __NDBA((char *node));
extern long _NFFadd_util_sa_notify __NDBA((int g_label, Form *form));
extern long _NFFadd_usa_get_text __NDBA((Form form, int label, int *width, NFFaddusa ptr));
extern long _NFFadd_usa_validate_accept __NDBA((NFFaddusa ptr));
extern long _NFFwrite_sa_data __NDBA((NFFaddusa ptr));
extern void NFFfree_addusa __NDBA((Form *form, NFFaddusa ptr));
extern long _NFFadjust_add_usa_form __NDBA((Form form));

/* NFFarchive.c */
extern long _NFFarchive_flagged_items __NDBA((void));

/* NFFbackup.c */
extern long _NFFbackup_flagged_items __NDBA((void));

/* NFFcan_coitm.c */
extern long NFFcancel_item_checkout __NDBA((int display_flag, char *catalog, char *item_name, char *revision));
extern long _NFFcancel_item_co __NDBA((int f_label, int display_flag, char *command, char *entity1, char *entity2, char *entity3, char *prompt1, char *prompt2));
extern long _NFFcancel_item_checkout_notify __NDBA((int g_label, Form *form));

/* NFFcan_coset.c */
extern long NFFcancel_set_checkout __NDBA((int display_flag, char *catalog, char *item_name, char *revision));
extern long _NFFcancel_set_checkout __NDBA((int f_label, int display_flag, char *command, char *entity1, char *entity2, char *entity3, char *prompt1, char *prompt2));
extern long _NFFcancel_set_checkout_notify __NDBA((int g_label, Form *form));

/* NFFcan_iflg.c */
extern long NFFcancel_item_flag __NDBA((int display_flag, int command, char *catalog, char *item_name, char *revision));

/* NFFcan_pflg.c */
extern long NFFcancel_project_flag __NDBA((int display_flag, int command, char *project));

/* NFFcan_sflg.c */
extern long NFFcancel_set_flag __NDBA((int display_flag, int command, char *catalog, char *set_name, char *revision));

/* NFFcat_acl.c */
extern long NFFadd_catalog_acl_mapping __NDBA((char *catalog));
extern long NFFdelete_catalog_acl_mapping __NDBA((char *catalog));

/* NFFcat_sa.c */
extern long NFFadd_catalog_sa_mapping __NDBA((char *catalog));
extern long NFFdelete_catalog_sa_mapping __NDBA((char *catalog));

/* NFFcat_tools.c */
extern long _NFFcat_build_value_buffer __NDBA((Form form, int label, char *list_or_keyin, char *value_column, char *value_type, NFFcatalog catalog));
extern long _NFFcat_convert_catalog_name __NDBA((Form form, int label, MEMptr attr_list, int active_row, char *text));
extern long _NFFcat_attributes_gadgets __NDBA((Form form, int mode));
extern long _NFFcat_information_gadgets __NDBA((Form form, int mode));
extern long _NFFcat_bezels __NDBA((Form form, int mode));
extern long _NFFfind_highest_seqno __NDBA((NFFcatalog catalog, int *seqno));
extern long _NFFcat_set_range_attr __NDBA((Form form, char *datatype));

/* NFFcatalog.c */
extern long _NFFcat_load_catalog_attributes __NDBA((Form form, int label, NFFcatalog catalog));
extern long _NFFcat_attributes_mcf __NDBA((Form form, int label, NFFcatalog catalog, int row_no));
extern long _NFFcat_set_defaults __NDBA((Form form, NFFcatalog catalog, int attribute, char *attr_name, char *datatype, short delete_flag));
extern long _NFFcat_set_characteristics __NDBA((Form form, NFFcatalog catalog, int attribute, short *delete_flag));
extern long _NFFcat_set_values __NDBA((Form form, NFFcatalog catalog, char *attr_name));
extern long _NFFcat_advice_button __NDBA((Form form));
extern long _NFFcat_advice_field __NDBA((Form form, int label, NFFcatalog catalog));
extern long _NFFcat_validate_button __NDBA((Form form, NFFcatalog catalog));
extern long _NFFcat_validate_toggle __NDBA((Form form, int state));
extern long _NFFcat_add_user_defined __NDBA((Form form, int label, NFFcatalog catalog));
extern long _NFFcat_delete_user_defined __NDBA((Form form, int label, NFFcatalog catalog));
extern long _NFFcat_keyin_field __NDBA((Form form, int label, NFFcatalog catalog, int mcf_col));
extern long _NFFcat_default_field __NDBA((Form form, int label, NFFcatalog catalog));
extern long _NFFcat_get_characteristics __NDBA((Form form, int label, char *column, NFFcatalog catalog));
extern long _NFFcat_rollthru_fields __NDBA((Form form, int label, int row, char *column, NFFcatalog catalog));
extern long _NFFcat_min_field __NDBA((Form form, int label, NFFcatalog catalog));
extern long _NFFcat_max_field __NDBA((Form form, int label, NFFcatalog catalog));
extern long _NFFcat_list_field __NDBA((Form form, int label, NFFcatalog catalog));
extern long _NFFcat_validate_accept __NDBA((NFFcatalog catalog));
extern long _NFFcat_attr_new_or_old __NDBA((NFFcatalog catalog, int attribute, short *new_attr));
extern void _NFFfree_catalog __NDBA((NFFcatalog catalog, Form *form));

/* NFFch_cat.c */
extern long NFFchange_catalog __NDBA((char *catalog_name));
extern long _NFFchcat_notify __NDBA((int g_label, int row, Form *form));
extern void _NFFcat_update_buffer __NDBA((NFFcatalog catalog));

/* NFFch_files.c */
extern long NFFchange_item_file_attributes __NDBA((char *catalog, char *item, char *revision));

/* NFFch_item.c */
extern long NFFchange_item __NDBA((char *catalog, char *item_name, char *revision));
extern long _NFFchange_item_notify __NDBA((int g_label, int row, Form *form));

/* NFFch_sa_pwd.c */
extern long NFFchange_storage_area_password __NDBA((char *st_area));
extern long _NFFchange_sa_password_notify __NDBA((int g_label, Form *form));

/* NFFch_u_pwd.c */
extern long NFFchange_user_password __NDBA((char *command, char *user_name));
extern long _NFFchange_user_password_notify __NDBA((int g_label, Form *form));

/* NFFch_wa_pwd.c */
extern long NFFchange_working_area_password __NDBA((char *working_area));
extern long _NFFchange_wa_password_notify __NDBA((int g_label, Form *form));

/* NFFchg_iwf.c */
extern long NFFchange_item_workflow __NDBA((void));
extern long _NFFchange_item_wf_notify __NDBA((int g_label, Form *form));
extern long _NFFload_wf_data __NDBA((Form form, int label, MEMptr data_list));
extern long _NFFload_state_data __NDBA((Form form, int label, MEMptr data_list));
extern long _NFFprocess_wf_list __NDBA((Form form, NFFiwf_ptr ptr));
extern long _NFFprocess_state_list __NDBA((Form form, NFFiwf_ptr ptr));
extern void _NFFfree_chgwf __NDBA((Form *form, NFFiwf_ptr ptr));
extern void _NFFprocess_change_wf_list __NDBA((Form *current_form, int f_label, int g_label, NFFiwf_ptr ptr));

/* NFFci_item.c */
extern int NFFdba_checkin __NDBA((char *msg));
extern long NFFcheckin_item __NDBA((int display_flag, char *catalog, char *item_name, char *revision));

/* NFFci_set.c */
extern long NFFcheckin_set __NDBA((int display_flag, char *catalog, char *item_name, char *revision));

/* NFFco_item.c */
extern int NFFdba_checkout __NDBA((char *msg));
extern long NFFcheckout_item __NDBA((int display_flag, char *catalog, char *item_name, char *revision));

/* NFFco_set.c */
extern long NFFcheckout_set __NDBA((int display_flag, char *catalog, char *item_name, char *revision));

/* NFFconfig.c */
extern long _NFFsetup_config __NDBA((void));

/* NFFconfirm.c */
extern long _NFFconfirm __NDBA((int f_label, int display_flag, char *entity1, char *entity2, char *entity3, char *prompt1, char *prompt2));
extern long _NFFconfirm_notify __NDBA((int f_label, int g_label, Form *form));
extern void _NFFfree_confirm __NDBA((NFFconfirm_ptr ptr, Form *form));

/* NFFcopy_acl.c */
extern long NFFcopy_acl __NDBA((void));
extern long _NFFcopy_acl_notify __NDBA((int g_label, int row, Form *form));
extern long NFFcopy_acl_users __NDBA((char *aclname, long wfno));
extern long _NFFcopy_acl_users_notify __NDBA((int g_label, int row, Form *form));
extern long _NFFget_acl_wf __NDBA((NFFadd_ptr ptr, char *acl, long *workflowno));
extern long _NFFcopy_acl_attributes_field __NDBA((Form form, int row_no, NFFadd_ptr ptr));
extern long _NFFblank_entry __NDBA((Form form));
extern long _NFFcopy_acl_validate_field __NDBA((Form form, int row, NFFadd_ptr ptr));
extern long _NFFcopy_acl_load_attributes __NDBA((Form form, NFFadd_ptr ptr));
extern long _NFFadd_set_lower_half_for_copy_acl __NDBA((Form form, NFFadd_ptr ptr, long row));

/* NFFcopy_item.c */
extern long NFFcopy_item __NDBA((char *catalog, char *item, char *revision));

/* NFFcp_item.c */
extern long _NFFcopy_item __NDBA((NFFcopy_ptr ptr));
extern long _NFFcopy_item_notify __NDBA((int g_label, int value, Form *form));

/* NFFcp_tools.c */
extern long _NFFcopy_list_mcf __NDBA((Form form, int mode, char *read_or_write, int row_array[], MEMptr attr_list, MEMptr data_list));
extern long _NFFcreate_list_mcf __NDBA((Form form, int label1, int label2, int mode, int vis_rows, int vis_cols, int vis_chars, MEMptr data_list));
extern long _NFFload_mcf_data __NDBA((Form form, int label1, int label2, MEMptr attr_list, MEMptr data_list));
extern long _NFFalter_list_scroll_gadgets __NDBA((Form form));
extern long _NFFload_cp_attr_list __NDBA((Form form, int g_label, int row_array[], MEMptr attr_list));
extern void NFFfree_copy __NDBA((Form *form, NFFcopy_ptr ptr));

/* NFFcr_cat.c */
extern long NFFcreate_catalog __NDBA((void));
extern long _NFFcrcat_notify __NDBA((int g_label, int row, Form *form));

/* NFFdebug.c */
extern long NFFdebug __NDBA((void));
extern long _NFFdebug_notify __NDBA((int g_label, Form *form));

/* NFFdef_smem.c */
extern long NFFdefine_members __NDBA((char *project, char *catalog_name, char *set_name, char *revision, char *command));
extern long _NFFdefine_set_members_notify __NDBA((int g_label, Form *form));
extern long _NFFdefine_project_members_notify __NDBA((int g_label, Form *form));
extern long _NFFadjust_members_form __NDBA((Form form));

/* NFFdef_srch.c */
extern long NFFdefine_search_criteria __NDBA((char *catalog));

/* NFFdel_acl.c */
extern long NFFdelete_acl __NDBA((char *workflow, char *acl_name));
extern long _NFFconfirm_acl_notify __NDBA((int g_label, Form *form));

/* NFFdel_cat.c */
extern long NFFdelete_catalog __NDBA((char *catalog_name));

/* NFFdel_cp.c */
extern long NFFdelete_copied_files __NDBA((void));
extern long _NFFdelete_copied_files_notify __NDBA((int g_label, Form *form));
extern long _NFFdelete_copied_files __NDBA((MEMptr *buffer));

/* NFFdel_files.c */
extern long NFFdelete_files_from_item __NDBA((char *catalog, char *item, char *revision));

/* NFFdel_item.c */
extern long NFFdelete_item __NDBA((int display_flag, char *catalog, char *item_name, char *revision));

/* NFFdel_label.c */
extern long _NFFdelete_tape_labels_notify __NDBA((int g_label, Form *form));
extern long _NFFbuild_tape_labels_buffer __NDBA((Form form, MEMptr *data));

/* NFFdel_map.c */
extern long _NFFdelete_mapping __NDBA((char *title1, char *title2, NFFmap entity));
extern long _NFFdelete_map_notify __NDBA((int g_label, int row, Form *form));

/* NFFdel_mem.c */
extern long NFFdelete_set_members __NDBA((char *catalog, char *set_name, char *revision));
extern long NFFdelete_project_members __NDBA((char *project));
extern long _NFFdefine_members __NDBA((char *entity_name, char *set_name, char *revision, char *title, int command));
extern long _NFFdefine_members_notify __NDBA((int g_label, double value, Form *form));
extern long _NFFdefine_members_write_keyword __NDBA((Form form, MEMptr data_list, int command, char *keyword));
extern void NFFfree_fitem __NDBA((Form *form, NFFfitem item));

/* NFFdel_node.c */
extern long NFFdelete_node __NDBA((char *node));

/* NFFdel_prj.c */
extern long NFFdelete_project __NDBA((char *project));

/* NFFdel_qry.c */
extern long NFFdelete_sort_criteria __NDBA((char *sort_name));
extern long NFFdelete_search_criteria __NDBA((char *search_name));
extern long _NFFdelete_query_notify __NDBA((int f_label, int g_label, Form *form));

/* NFFdel_sa.c */
extern long NFFdelete_storage_area __NDBA((char *st_area));

/* NFFdel_sort.c */
extern long NFFdelete_sort_criteria __NDBA((char *sort_name));

/* NFFdel_srch.c */
extern long NFFdelete_search_criteria __NDBA((char *search_name));

/* NFFdel_user.c */
extern long NFFdelete_user __NDBA((char *user));

/* NFFdelete.c */
extern long _NFFdelete_flagged_items __NDBA((void));

/* NFFf_tools.c */
extern long _NFFset_select_attr_data __NDBA((Form form, int data_rows, int *act_row, int *act_col, NFFadd_ptr ptr));
extern long _NFFprocess_value_field __NDBA((Form form, int act_row, int act_col, NFFadd_ptr ptr, int val_col));
extern long _NFFprocess_validate_field __NDBA((Form form, int row, int act_row, int act_col, NFFadd_ptr ptr, int val_col));
extern long _NFFset_value_info __NDBA((Form form, NFFadd_ptr ptr, int sel_row, int sel_col, int *pos_cur));
extern long _NFFset_advisory_info __NDBA((Form form, NFFadd_ptr ptr, int act_col));
extern long _NFIload_copy_data __NDBA((Form form, NFFadd_ptr ptr, char *write_attr));
extern long _NFFdisable_value_info __NDBA((Form form, NFFadd_ptr ptr));
extern long _NFFdelete_data_row __NDBA((Form form, int g_label, MEMptr data_list, MEMptr *new_list));
extern long _NFFset_data_row_status __NDBA((MEMptr data_list));
extern long _NFFadd_data_row __NDBA((Form form, int g_label, int *act_row, int *act_col, int row_array[], MEMptr data_list, MEMptr temp_list));
extern long _NFFcreate_validation_mcf __NDBA((Form form, int label, MEMptr value_list));
extern long _NFFdelete_add_rows __NDBA((Form form, int g_label, int *act_row, int *act_col, MEMptr data_list, MEMptr *new_list));
extern long _NFFselect_all_rows __NDBA((Form form, int g_label, int row_array[], MEMptr data_list));
extern long _NFFset_delete_data_rows __NDBA((Form form, int g_label, MEMptr data_list));
extern long _NFFnadd_validate_text __NDBA((char *text, MEMptr value_list, int val_col));
extern long _NFFprocess_validate_accept __NDBA((Form form, char *write_attr, int *act_row, int *act_col, NFFadd_ptr ptr, int val_col));
extern long _NFFgeneric_fld_pos_cur __NDBA((Form form, int g_label, int *act_row, int *act_col, NFFadd_ptr ptr));
extern long _NFFadd_fld_pos_cur __NDBA((Form form, int g_label, int cur_row, int cur_col, int *act_row, int *act_col, NFFadd_ptr ptr));

/* NFFfei.c */
extern int FEI_get_refresh_area_data __NDBA((int *window, int *vs, int *xlo, int *ylo, int *xhi, int *yhi, int *axlo, int *aylo, int *axhi, int *ayhi, int *opmask));
extern int FEI_inq_button_data __NDBA((int *window, int *x, int *y, int *button, int *trans, int *ttag));
extern int _NFFget_button_data __NDBA((int *w, int *x, int *y, int *button, int *transition, int *timetag));
extern int FEI_get_keyboard_data __NDBA((char *character, int *count, int font_type));
extern int FEI_set_window_attr __NDBA((int window));
extern int FEI_enter __NDBA((void));

/* NFFfgets.c */
extern char *_NFFfgets __NDBA((char *s, int n, FILE *stream));

/* NFFfile_io.c */
extern long _NFFfile_io __NDBA((int f_label, int display_flag, char *command, char *entity1, char *entity2, char *entity3, char *prompt1, char *prompt2));
extern int NFFdba_item_io_notify __NDBA((void));
extern int _NFFfile_io_confirm_notify __NDBA((int f_label, int g_label, double value, Form form));

/* NFFfl_item.c */
extern long NFFflag_item_files __NDBA((int display_flag, int command, char *catalog, char *item_name, char *revision));

/* NFFfl_proj.c */
extern long NFFflag_project_files __NDBA((int display_flag, int command, char *project));

/* NFFfl_set.c */
extern long NFFflag_set_files __NDBA((int display_flag, int command, char *catalog, char *set_name, char *revision));

/* NFFfl_tools.c */
extern long _NFFadjust_confirm_form __NDBA((Form form));

/* NFFflag.c */
extern long NFFprocess_flagged_files __NDBA((void));
extern long _NFFflagged_files_notify __NDBA((int g_label, Form *form));
extern void _NFFfree_flag __NDBA((NFFnflag_ptr ptr, Form *form));

/* NFFflag_item.c */
extern long NFFnflag_item_files __NDBA((char *catalog, char *item, char *revision, int type));
extern long _NFFflag_item_notify __NDBA((int g_label, Form *form));
extern long _NFFset_mcf_flag_data __NDBA((Form form, NFFflag_ptr ptr));
extern long _NFFvalidate_flag_accept __NDBA((Form form, NFFflag_ptr ptr));
extern long _NFFadjust_flag_form __NDBA((Form form));
extern void _NFFfree_flag_ptr __NDBA((Form *form, NFFflag_ptr ptr));

/* NFFg_confirm.c */
extern long _NFFgeneric_confirm_notify __NDBA((int g_label, Form *form));

/* NFFget_map.c */
extern long _NFFget_mapping __NDBA((char *entity_name, char *title1, char *title2, int command));
extern long _NFFmap_scan_attributes __NDBA((MEMptr attr_list, int *no_attributes, int *attr_row_offset));
extern void _NFFfree_map __NDBA((NFFmap entity, Form *form));

/* NFFhelp.c */
extern int _NFFhelp_toc __NDBA((void));
extern int _NFFhelp_topic __NDBA((char *command));
extern long _NFFinit_help __NDBA((void));
extern long _NFFsetup_help_vlt __NDBA((void));
extern long _NFFload_help_vlt __NDBA((int numslots, struct vlt_slot *vlt));

/* NFFinit.c */
extern void _NFFinit_global __NDBA((void));
extern long _NFFinit_graphics __NDBA((void));

/* NFFjournal.c */
extern int JNL_init_journal __NDBA((char *filename, int excl_flag));
extern int JNL_init_playback __NDBA((char *filename));
extern int JNL_record_new_window __NDBA((int window));
extern int JNL_echo_event __NDBA((int mask, int *event));
extern int JNL_process_info_event __NDBA((int new_window));
extern int JNL_process_del_info_event __NDBA((void));
extern int JNL_record_info_event __NDBA((int type, int event_nbytes, char *string));
extern int JNL_record_event __NDBA((int event));
extern int JNL_close_jnl __NDBA((void));
extern int JNL_close_jnl_pbk __NDBA((void));
extern int JNL_close_echo __NDBA((void));
extern int JNL_record_input __NDBA((int nbytes, char *buffer));
extern int JNL_echo_input __NDBA((int nbytes, char *buffer));
extern int JNL_adjust_echo __NDBA((void));
extern int JNL_adjust_echo_button __NDBA((void));
extern int JNL_adjust_echo_refresh_button __NDBA((void));
extern int JNL_adjust_echo_collapse_button __NDBA((void));
extern int JNL_adjust_delete_button __NDBA((void));
extern int JNL_wait_for_next __NDBA((int mask, int *event));
extern int JNL_inq_events __NDBA((int *event));
extern int JNL_inq_button_data __NDBA((int *window, int *x, int *y, int *btype, int *state, int *timetag));
extern int JNL_get_button_data __NDBA((int *window, int *x, int *y, int *btype, int *state, int *timetag));
extern int JNL_process_slow_echo __NDBA((void));
extern int JNL_oldwindow_to_window __NDBA((int oldwindow, int *window));
extern int JNL_get_refresh_area_data __NDBA((int *window, int *vs_no, int *x, int *y, int *x2, int *y2, int *ax1, int *ay1, int *ax2, int *ay2, int *opmask));
extern int JNL_inq_refresh_area_data __NDBA((int *window, int *vs_no, int *x, int *y, int *x2, int *y2, int *ax1, int *ay1, int *ax2, int *ay2, int *opmask));
extern int JNL_get_collapse_data __NDBA((int *window, int *opmask));
extern int JNL_inq_collapse_data __NDBA((int *window, int *opmask));
extern int JNL_get_delete_data __NDBA((int *window));
extern int JNL_inq_delete_data __NDBA((int *window));
extern int JNL_inq_user_data __NDBA((int *user_data));
extern int JNL_get_user_data __NDBA((int *user_data));
extern int JNL_inq_win_user_icon_data __NDBA((int *window, int *icon_id));
extern int JNL_get_win_user_icon_data __NDBA((int *window, int *icon_id));
extern int JNL_start_timer __NDBA((int delta_time, int repeatflag, int *timer_no));
extern int JNL_stop_timer __NDBA((int timer_no));
extern int JNL_get_timer_data __NDBA((int *timer_no));
extern int JNL_echo_timer_data __NDBA((int *timer_no));
extern int JNL_record_timer_data __NDBA((int *timer_no));
extern int JNL_set_keyboard_buffer __NDBA((char *buffer, int count));
extern int JNL_get_keyboard_data __NDBA((int *count));
extern int JNL_inq_keyboard_data __NDBA((int *count));
extern int JNL_inq_keyboard_buffer __NDBA((char **buf_addr, int *count));
extern int JNL_set_timer_playback __NDBA((int mytime));
extern int JNL_playback __NDBA((void));
extern int JNL_journal __NDBA((void));

/* NFFlist.c */
extern void _NFFprocess_list __NDBA((int f_label, int g_label));
extern long _NFFerror_notify __NDBA((int g_label, Form *form));

/* NFFlist_mcf.c */
extern long _NFFlist_load_mcf __NDBA((Form form, int mode, MEMptr syn_list, MEMptr data_list));
extern long _NFFreview_load_mcf __NDBA((Form form, MEMptr syn_list, MEMptr data_list));
extern long _NFFlist_create_mcf __NDBA((Form form, int label, int mode, MEMptr data_list));
extern long _NFFreview_create_mcf __NDBA((Form form, int label, MEMptr data_list));
extern long _NFFlist_load_mcf_data __NDBA((Form form, int start_row, MEMptr syn_list, MEMptr data_list));
extern long _NFFreview_load_mcf_data __NDBA((Form form, MEMptr syn_list, MEMptr data_list));

/* NFFlock_item.c */
extern long NFFlock_item __NDBA((char *catalog, char *item_name, char *revision));

/* NFFmap_mcf.c */
extern long _NFFmap_load_value_list __NDBA((Form form, NFFmap entity, int filter_flag));
extern long _NFFmap_create_mcf __NDBA((Form form, int label, MEMptr value_list));
extern long _NFFmap_load_mcf __NDBA((Form form, int filter_flag, int attr_row, MEMptr data_list, MEMptr value_list));
extern long _NFFmap_load_add_mcf __NDBA((Form form, int label, int attr_row, MEMptr data_list, MEMptr value_list));
extern long _NFFmap_load_delete_mcf __NDBA((Form form, int label, int attr_row, MEMptr data_list, MEMptr value_list));

/* NFFmcf_tools.c */
extern long _NFFfcreate_list_mcfs __NDBA((Form form, int label1, int label2, int mode, char *read_or_write, MEMptr attr_list, MEMptr data_list));
extern long _NFFgenerate_mcfs __NDBA((Form form, int label1, int label2, int mode, int vis_rows, int vis_cols, int vis_chars, int row_array[], MEMptr data_list));
extern long _NFFload_data_into_mcfs __NDBA((Form form, int label1, int label2, int row_array[], MEMptr attr_list, MEMptr data_list));
extern long _NFFgeneric_load_data __NDBA((Form form, int label, MEMptr data_list));
extern long _NFFgeneric_mcf_select_all_rows __NDBA((Form form, int toggle_label, int mcf_label, int num_rows));

/* NFFmem_tools.c */
extern long _NFFload_members_mcf __NDBA((Form form, NFFset_ptr entity, char *command));
extern void _NFFfree_setm __NDBA((Form *form, NFFset_ptr entity));
extern long _NFFadd_set_members_mcf __NDBA((int g_label, Form form, NFFset_ptr entity, char *command));
extern long _NFFget_field_text __NDBA((int g_label, Form form, char *text));
extern long _NFFremove_set_members_mcf __NDBA((int g_label, Form form, NFFset_ptr entity));
extern long _NFFprocess_select_scf __NDBA((int g_label, Form form, NFFset_ptr entity));
extern long _NFFprocess_field_entry __NDBA((int g_label, Form form, NFFset_ptr entity));
extern long _NFFvalidate_user_data __NDBA((int g_label, char *text, NFFset_ptr entity, int *row));
extern long _NFFprocess_type __NDBA((int g_label, Form form, NFFset_ptr entity));
extern long _NFFvalidate_item_type __NDBA((char *item_name, char *revision, int state, short type_offset, short item_name_offset, short rev_name_offset, MEMptr data_list));
extern long _NFFget_scf_data_list __NDBA((int g_label, Form form, NFFset_ptr entity));
extern long _NFFget_list_of_catalogs __NDBA((MEMptr *cat_data, short *offset));
extern long _NFFmem_set_text __NDBA((Form form, int g_label, char *title));
extern long _NFFdisplay_catalogs __NDBA((Form form, int g_label, NFFset_ptr entity));
extern long _NFFget_list_of_items __NDBA((Form form, int g_label, int display_values, NFFset_ptr entity, char *project_name, char *catalog_name));
extern long _NFFdisplay_items __NDBA((Form form, int g_label, NFFset_ptr entity));
extern long _NFFdisplay_revisions __NDBA((Form form, int g_label, NFFset_ptr entity));
extern long _NFFinsert_set_members_in_list __NDBA((NFFset_ptr entity, int *rows, struct NFMmember_info *member_list[]));
extern long _NFFinsert_project_members_in_list __NDBA((NFFset_ptr entity));
extern long _NFFadjust_set_members_form __NDBA((Form form));
extern long _NFFupdate_set_members_in_list __NDBA((Form form, int g_label, NFFfitem entity, int *rows, struct NFMmember_info *member_list[]));

/* NFFmenu.c */
extern long _NFFinit_menus __NDBA((void));

/* NFFmessage.c */
extern void NFFform_message __NDBA((int f_label, int message_no, char *message_fmt, ...));
extern void NFFerror_message __NDBA((Form form));
extern void NFFerase_message __NDBA((void));

/* NFFmk_trans.c */
extern long NFFmake_transition __NDBA((void));
extern long _NFFmk_trans_notify __NDBA((int g_label, int row, Form *form));
extern long _NFFmk_trans_load_states __NDBA((Form form, NFFmk_trans trans));
extern long _NFFmk_trans_next_state __NDBA((Form form, NFFmk_trans trans));
extern long _NFFmk_trans_possible_states __NDBA((Form form, int row));
extern long _NFFmk_trans_validate_accept __NDBA((Form form, NFFmk_trans trans));
extern void _NFFfree_make_trans __NDBA((NFFmk_trans trans, Form *form));

/* NFFncp_item.c */
extern long NFFn_copy_item_files __NDBA((int display_flag, char *catalog, char *item_name, char *revision));

/* NFFncp_set.c */
extern long NFFn_copy_set_files __NDBA((int display_flag, char *catalog, char *item_name, char *revision));

/* NFFnotify.c */
extern void _NFFnotify __NDBA((int f_label, int g_label, double value, Form form));

/* NFFparse.c */
extern int _NFFparse_input __NDBA((int argc, char *argv[]));

/* NFFpasswd.c */
extern long _NFFold_passwd_field __NDBA((Form form, int label, NFFpasswd entity));
extern long _NFFnew_passwd_field __NDBA((Form form, int label, NFFpasswd entity));
extern long _NFFpasswd_validate_accept __NDBA((NFFpasswd entity));
extern void NFFfree_passwd __NDBA((Form *form, NFFpasswd entity));

/* NFFplot.c */
extern long NFFplot_item __NDBA((int display_flag, char *catalog, char *item, char *revision));
extern long NFFplot_set __NDBA((int display_flag, char *catalog, char *set, char *revision));
extern long NFFplot_set_parent __NDBA((char *catalog, char *set, char *revision));

/* NFFpopup.c */
extern long NFFserver_popup __NDBA((void));
extern long NFFenv_popup __NDBA((void));
extern long NFFproject_popup __NDBA((void));
extern long NFFcatalog_popup __NDBA((void));
extern long NFFitem_popup __NDBA((void));
extern long NFFrevision_popup __NDBA((void));
extern long NFFsearch_popup __NDBA((void));
extern long NFFsort_popup __NDBA((void));
extern long NFFwa_popup __NDBA((void));
extern long NFFsa_popup __NDBA((void));
extern long NFFnode_popup __NDBA((void));
extern long NFFuser_popup __NDBA((void));
extern long NFFwf_popup __NDBA((void));
extern long NFFacl_popup __NDBA((void));
extern long _NFFload_popup __NDBA((int f_label, char *title, MEMptr data));
extern long _NFFpopup_notify __NDBA((int f_label, int g_label, int row, Form *form));

/* NFFprint.c */
extern long _NFFprint_listing __NDBA((int f_label));
extern long _NFFprint_to_file __NDBA((Form form, int num_cols, int *cols, char *time_string, char *filename));

/* NFFprj_acl.c */
extern long NFFadd_project_acl_mapping __NDBA((char *project));
extern long NFFdelete_project_acl_mapping __NDBA((char *project));

/* NFFprj_sa.c */
extern long NFFadd_project_sa_mapping __NDBA((char *project));
extern long NFFdelete_project_sa_mapping __NDBA((char *project));

/* NFFproc_file.c */
extern long _NFFprocess_item_files __NDBA((NFFcopy_ptr ptr));
extern long _NFFprocess_files_notify __NDBA((int g_label, int value, Form *form));

/* NFFprocess.c */
extern void _NFFprocess_data __NDBA((int type, char *command));
extern void _NFFdelete_forms __NDBA((void));

/* NFFpur_so.c */
extern long NFFpurge_signoff __NDBA((char *catalog, char *item_name, char *revision));

/* NFFpur_vers.c */
extern long NFFpurge_file_versions __NDBA((int display_flag, char *catalog, char *item_name, char *revision));

/* NFFrestore.c */
extern long _NFFrestore_flagged_items __NDBA((void));

/* NFFsave.c */
extern long NFFsave_item __NDBA((int display_flag, char *catalog, char *item, char *revision));
extern long NFFsave_set __NDBA((int display_flag, char *catalog, char *set, char *revision));
extern long NFFsave_set_parent __NDBA((char *catalog, char *set, char *revision));

/* NFFsaveset.c */
extern long NFFdelete_saveset_entries __NDBA((void));
extern long _NFFdelete_saveset_entries_notify __NDBA((int g_label, Form *form));
extern long _NFFbuild_savesets_buffer __NDBA((Form form, MEMptr old_buffer, MEMptr *new_buffer));

/* NFFscroll.c */
extern void _NFFscroll_message __NDBA((Form form, int label));
extern void _NFFscroll_message_one_word __NDBA((Form form, int label));

/* NFFset_io.c */
extern long _NFFset_io __NDBA((int f_label, int display_flag, char *command, char *entity1, char *entity2, char *entity3, char *prompt1, char *prompt2));
extern long _NFFset_io_confirm_notify __NDBA((int g_label, Form *form));

/* NFFsignal.c */
extern long _NFFsetup_signals __NDBA((void));
extern void _NFFsignal __NDBA((int type));

/* NFFsignoff.c */
extern long NFFsignoff_on_item __NDBA((void));
extern long _NFFsignoff_on_item_notify __NDBA((int g_label, int value, Form *form));
extern long _NFFsignoff_override_button __NDBA((int label, int state, NFFsignoff signoff));
extern long _NFFsignoff_reason_field __NDBA((Form form, int label, NFFsignoff signoff));
extern long _NFFadjust_signoff_form __NDBA((Form form));
extern void NFFfree_signoff __NDBA((Form *form, NFFsignoff ptr));

/* NFFsort.c */
extern long NFFdefine_sort_criteria __NDBA((char *catalog_name));
extern long _NFFdefine_sort_criteria_notify __NDBA((int g_label, double value, Form *form));
extern long _NFFprocess_sort_mcf __NDBA((Form form, int g_label, NFFsort_ptr entity));
extern long _NFFprocess_sort_input __NDBA((Form form, NFFsort_ptr entity, struct NFMquery_info *query_info));
extern long _NFFload_attributes_mcf __NDBA((Form form, int g_label, NFFsort_ptr entity));
extern long _NFFprocess_sort_name __NDBA((Form form, int g_label, NFFsort_ptr entity));
extern void _NFFfree_sortptr __NDBA((NFFsort_ptr entity, Form *form));

/* NFFtimestamp.c */
extern void __NFFts_data __NDBA((char *format, ...));
extern void __NFFts_commit __NDBA((void));

/* NFFtools.c */
extern long _NFFcenter_form __NDBA((Form form, int xlocation, int ylocation));
extern long _NFFcenter_gadget __NDBA((Form form, int label));
extern long _NFFfind_column_offset __NDBA((MEMptr buffer, char *attrname, short *offset));
extern long _NFFbuild_value_buffer __NDBA((MEMptr *buffer));
extern long _NFFfind_attribute_name __NDBA((MEMptr buffer, int row, char **name));
extern long _NFFinit_rows __NDBA((MEMptr buffer, char *write_attr, int *row_array[]));
extern long _NFFinit_cols __NDBA((MEMptr buffer, int *col_array[], char *read_attr, char *write_attr, char *read_value, char *write_value));
extern long _NFFfind_next_writable_row __NDBA((MEMptr buffer, char *write_attr, char *write_value, int current_row, int *next_row));
extern long _NFFfind_value_buffer __NDBA((MEMptr attr_list, MEMptr value_list, char *attr_name, char *list_or_keyin));
extern long _NFFfind_list_offsets __NDBA((MEMptr attr_list, short *syn_offset, short *name_offset));
extern long _NFFvalidate_datatype __NDBA((char *datatype, int *width));
extern void _NFFclear_msg __NDBA((Form form));
extern long _NFFget_attr_info __NDBA((MEMptr attr_list, char *attrname, int *offset, char *n_read, char *n_write, char *type, int *length));
extern void _NFFfind_active_data __NDBA((MEMptr buffer, char *attribute, char *data));
extern void _NFFprocess_event __NDBA((int refresh_event));

/* NFFunlk_item.c */
extern long NFFunlock_item __NDBA((char *catalog, char *item_name, char *revision));

/* NFFusage.c */
extern void _NFFinit_usage __NDBA((char *program_name, char *usage));

/* NFFutil_msg.c */
extern long NFFprocess_utility_message __NDBA((MEMptr msg_buffer));
extern long _NFFutility_message_notify __NDBA((int g_label, Form *form));

/* NFFutility.c */
extern long _NFFprocess_ab_items_notify __NDBA((int g_label, Form *form));
extern long _NFFutil_load_item_data __NDBA((Form form, int label, MEMptr data_list));
extern long _NFFprocess_label_field __NDBA((Form form, char *label));
extern long _NFFprocess_util_sa_list __NDBA((Form form, NFFutil_ptr ptr));
extern long _NFFcheck_util_user_input __NDBA((Form form, NFFutil_ptr ptr, char *sa_no, MEMptr *flist));
extern void _NFFfree_utility __NDBA((Form *form, NFFutil_ptr ptr));
extern long _NFFget_util_user_input __NDBA((Form form, NFFutil_ptr ptr, MEMptr *flist));
extern long _NFFprocess_label_list __NDBA((Form form, char *label));

/* NFFvalid.c */
extern long _NFFvalid_catalog __NDBA((char *catalog_name));
extern long _NFFvalid_item __NDBA((char *catalog, char *item_name));
extern long _NFFvalid_revision __NDBA((char *catalog, char *item, char *revision, int *set_or_not));
extern long _NFFvalid_sa __NDBA((char *saname));
extern long _NFFvalid_project __NDBA((char *project));
extern long _NFFvalid_search __NDBA((char *search, char *owner));
extern long _NFFvalid_sort __NDBA((char *sort, char *owner));
extern long _NFFvalid_wa __NDBA((char *waname, char *owner));
extern long _NFFvalid_user __NDBA((char *user));
extern long _NFFvalid_node __NDBA((char *node));
extern long _NFFvalid_wf __NDBA((char *workflow));
extern long _NFFvalid_acl __NDBA((char *workflow, char *acl));
extern long _NFFvalidate_active_data __NDBA((long mask));

/* NFFversions.c */
extern long NFFroll_version_forward __NDBA((char *catalog, char *item_name, char *revision));
extern long _NFFroll_versions_notify __NDBA((int g_label, Form *form));
extern void _NFFfree_version __NDBA((Form *form, NFFversion_ptr ptr));
extern long _NFFtoggle_unselect_rows __NDBA((int g_label, Form form, int num_rows));
extern long _NFFcheck_selected_versions __NDBA((int g_label, Form form, MEMptr data_list));
extern long _NFFget_file_versions __NDBA((int g_label, Form form, NFFversion_ptr ptr, MEMptr *data_list));

/* NFFvlt.c */
extern long _NFFsetup_vlt __NDBA((void));
extern int _NFFtranslate_color __NDBA((int vs, int color));

/* NFFwf.c */
extern long NFFvalidate_user_access __NDBA((char *command_key));
extern long NFFset_to_state __NDBA((void));

/* d_items.c */
extern long NFFdisplay_items __NDBA((int locate_flag));
extern long NFFdisplay_project_members __NDBA((int locate_flag));
extern long NFFdisplay_set_members __NDBA((int locate_flag));
extern long NFFreview_item __NDBA((int locate_flag));
extern int _NFFdisplay_items_notify __NDBA((int f_label, int g_label, double row, Form form));
extern long _NFFmore_data __NDBA((int f_label, int rows));
extern long _NFFend_block_listing __NDBA((int f_label, int load_message));
extern void _NFFenable_scrollbar __NDBA((Form form, int label, int scroll_at_bottom));

/* defaults.c */
extern long NFFdba_read_user_defaults __NDBA((void));
extern long NFFdba_write_user_defaults __NDBA((void));

/* exit.c */
extern void _NFFdba_exit __NDBA((int label, long status));

/* init.c */
extern void _NFFdba_init_global __NDBA((void));
extern long _NFFdba_init_graphics __NDBA((void));

/* login.c */
extern long NFFdba_login __NDBA((void));
extern long NFFdba_form_login __NDBA((void));
extern void NFFdba_post_login __NDBA((int first_time_flag));
extern long NFFdba_logout __NDBA((void));
extern long _NFFdba_validate_login_accept __NDBA((void));
extern int NFFdba_login_button __NDBA((char *msg));
extern int NFFdba_cancel_login __NDBA((void));
extern int NFFdba_delete_menu_login __NDBA((void));
extern int NFFlogin_keyins __NDBA((char *msg, int g_label, char *str, char *str2));
extern int NFFdba_user_main_notify __NDBA((void));
extern int NFFdba_list_catalogs __NDBA((void));
extern int NFFdba_display_notify __NDBA((void));
extern int NFFdba_display_items_notify __NDBA((void));
extern int NFFdba_list_items __NDBA((void));
extern int NFMlistings __NDBA((int listing_type));
extern int NFFdba_review_items __NDBA((void));

/* main.c */
extern int main __NDBA((int argc, char *argv[]));

/* main_form.c */
extern long NFFdba_init_main_form __NDBA((void));
extern void _NFFdba_main_window_event_routine __NDBA((int f_label, int event, Form form));
extern int NFFdba_main_notify __NDBA((int f_label, int g_label, double value, Form form));

/* nffdisplay.c */
extern long NFFdisplay_tape_labels __NDBA((void));
extern long NFFdisplay_items_on_tape __NDBA((int locate_flag));
extern long NFFdisplay_savesets __NDBA((int locate_flag));
extern long NFFdisplay_archives __NDBA((int locate_flag));
extern long NFFwhere_used_project __NDBA((int locate_flag));
extern long NFFwhere_used_set __NDBA((int locate_flag));
extern long NFFdisplay_item_signoffs __NDBA((int locate_flag));
extern long NFFdisplay_signoff_history __NDBA((int locate_flag));
extern long NFFdisplay_local_files __NDBA((int locate_flag));
extern long NFFdisplay_nodes __NDBA((int locate_flag));
extern long NFFdisplay_storage_areas __NDBA((int locate_flag));
extern long NFFdisplay_working_areas_admin __NDBA((int locate_flag));
extern long NFFdisplay_working_areas_user __NDBA((int locate_flag));
extern long NFFdisplay_users __NDBA((int locate_flag));
extern long NFFdisplay_catalogs __NDBA((int locate_flag));
extern long NFFdisplay_workflows __NDBA((int locate_flag));
extern long NFFdisplay_acls __NDBA((int locate_flag));
extern long NFFdisplay_aclusers __NDBA((int locate_flag));
extern long NFFdisplay_signoff_users __NDBA((int locate_flag));
extern long NFFdisplay_projects __NDBA((int locate_flag));
extern long NFFdisplay_catalog_acl_mapping __NDBA((int locate_flag));
extern long NFFdisplay_catalog_sa_mapping __NDBA((int locate_flag));
extern long NFFdisplay_project_acl_mapping __NDBA((int locate_flag));
extern long NFFdisplay_project_sa_mapping __NDBA((int locate_flag));
extern long NFFdisplay_search_criteria __NDBA((int locate_flag));
extern long NFFdisplay_sort_criteria __NDBA((int locate_flag));
extern long NFFdisplay_archive_flags __NDBA((int locate_flag));
extern long NFFdisplay_backup_flags __NDBA((int locate_flag));
extern long NFFdisplay_restore_flags __NDBA((int locate_flag));
extern long NFFdisplay_delete_flags __NDBA((int locate_flag));
extern int _NFFdisplay_notify __NDBA((int f_label, int g_label, double row, Form form));
extern long _NFFload_display __NDBA((int f_label, char *form_name, int num_cols, char *title, MEMptr data, int locate_flag));
extern void _NFFplace_form __NDBA((int f_label));
extern void NFFfind_mcf_attribute __NDBA((Form form, int label, char *attrname, int *col));
extern void _NFFalter_item_text_label __NDBA((char *new_text));

/* popup.c */
extern int NFFprocess_popup __NDBA((char *msg, int p_label));
extern long NFFdba_server_popup __NDBA((NFFpopup_ptr ptr));
extern long NFFdba_env_popup __NDBA((NFFpopup_ptr ptr));
extern long NFFdba_project_popup __NDBA((void));
extern long NFFdba_catalog_popup __NDBA((void));
extern long NFFdba_item_popup __NDBA((void));
extern long NFFdba_revision_popup __NDBA((void));
extern long NFFdba_search_popup __NDBA((void));
extern long NFFdba_sort_popup __NDBA((void));
extern long NFFdba_wa_popup __NDBA((void));
extern long NFFdba_sa_popup __NDBA((void));
extern long NFFdba_node_popup __NDBA((void));
extern long NFFdba_user_popup __NDBA((void));
extern long NFFdba_wf_popup __NDBA((void));
extern long NFFdba_acl_popup __NDBA((void));
extern long _NFFdba_load_popup __NDBA((int p_label, char *title, MEMptr data));
extern int NFFdba_invoke_popup_notify __NDBA((void));
extern int _NFFdba_popup_notify __NDBA((int f_label, int g_label, double row, Form form));
extern int NFFdba_popup_select_one __NDBA((char *str, char *msg));
extern int NFFdba_process_popup __NDBA((int t_label, int g_label, char *msg));

#undef __NDBA

#endif
