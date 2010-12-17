#ifndef NFF_PROTO_H
#define NFF_PROTO_H

#if defined(__STDC__) || defined(__cplusplus)
# define __NFF(s) s
#else
# define __NFF(s) ()
#endif


/* NFFacl_class.c */
extern long NFFadd_acl_class_users __NFF((int type, char *acl_name));
extern long NFFdelete_acl_class_users __NFF((char *acl_name));

/* NFFacl_clusr.c */
extern long _NFFadd_acl_class_users __NFF((NFFmap entity));
extern long _NFFadd_acl_class_users_notify __NFF((int g_label, int row, Form *form));
extern long _NFFdelete_acl_class_users __NFF((NFFmap entity));
extern long _NFFdelete_acl_class_users_notify __NFF((int g_label, int row, Form *form));
extern long _NFFacl_load_class_data_list __NFF((Form form, NFFmap entity, int row, char *keyword));

/* NFFacl_mcf.c */
extern long _NFFacl_load_value_list __NFF((Form form, NFFmap entity, char *attribute, int filter_flag));
extern long _NFFacl_create_mcf __NFF((Form form, int label));
extern long _NFFacl_load_mcf __NFF((Form form, int filter_flag, int value_row, char *attribute, MEMptr attr_list, MEMptr data_list, MEMptr value_list));
extern long _NFFacl_load_add_mcf __NFF((Form form, int label, int value_row, char *attribute, MEMptr attr_list, MEMptr data_list, MEMptr value_list));
extern long _NFFacl_load_delete_mcf __NFF((Form form, int label, int value_row, char *attribute, MEMptr attr_list, MEMptr data_list, MEMptr value_list));

/* NFFacl_sign.c */
extern long NFFadd_acl_signoff_users __NFF((char *acl_name));
extern long NFFdelete_acl_signoff_users __NFF((char *acl_name));

/* NFFacl_susr.c */
extern long _NFFload_acl_signoff_users __NFF((Form form, NFFmap entity));
extern long _NFFadd_acl_signoff_users __NFF((NFFmap entity));
extern long _NFFadd_acl_signoff_users_notify __NFF((int g_label, int row, Form *form));
extern long _NFFdelete_acl_signoff_users __NFF((NFFmap entity));
extern long _NFFdelete_acl_signoff_users_notify __NFF((int g_label, int row, Form *form));
extern long _NFFacl_load_signoff_data_list __NFF((Form form, NFFmap entity, int row, char *keyword));

/* NFFacl_tools.c */
extern long _NFFacl_write_data __NFF((NFFmap entity, int value_row, char *userno, char *attribute, char *keyword));
extern long _NFFacl_add_write_data __NFF((NFFmap entity, int value_row, char *attribute));
extern long _NFFacl_delete_write_data __NFF((MEMptr attr_list, MEMptr data_list, MEMptr value_list, int value_row, char *userno, char *attribute));
extern long _NFFacl_set_title __NFF((NFFmap entity, char *title1, char *title2, char *add_or_delete));
extern long _NFFacl_set_title_add __NFF((NFFmap entity, char *title1, char *title2, int value_row, int current_no, char *current_name));
extern long _NFFacl_set_title_delete __NFF((NFFmap entity, char *title1, char *title2, int value_row, int current_no, char *current_name));

/* NFFadd.c */
extern long _NFFadd_attributes_field __NFF((Form form, int row_no, char *write_or_update, NFFadd_ptr ptr));
extern long _NFFadd_value_field __NFF((Form form, char *write_or_update, NFFadd_ptr ptr));
extern long _NFFadd_validate_field __NFF((Form form, int row, char *write_or_update, NFFadd_ptr ptr));
extern long _NFFadd_set_lower_half __NFF((Form form, char *write_or_update, NFFadd_ptr ptr));
extern long _NFFadd_set_advisory_info __NFF((Form form, NFFadd_ptr ptr));
extern long _NFFadd_validate_text __NFF((char *text, MEMptr value_list));
extern long _NFFadd_load_attributes __NFF((Form form, NFFadd_ptr ptr, char *write_attr));
extern long _NFFadd_disable_lower_half __NFF((Form form, NFFadd_ptr ptr));
extern long _NFFadd_validate_accept __NFF((Form form, char *write_attr, NFFadd_ptr ptr));
extern long _NFFadd_select_next_attribute __NFF((Form form, char *write_or_update, NFFadd_ptr ptr));
extern void _NFFfree_add __NFF((NFFadd_ptr ptr, Form *form));

/* NFFadd_acl.c */
extern long NFFadd_acl __NFF((void));
extern long _NFFadd_acl_notify __NFF((int g_label, int row, Form *form));

/* NFFadd_file.c */
extern long NFFadd_files_to_item __NFF((char *catalog, char *item, char *revision));

/* NFFadd_init.c */
extern long NFFadd_init __NFF((char *entity, int command));
extern long _NFFadd_notify __NFF((int g_label, int row, Form *form));

/* NFFadd_map.c */
extern long _NFFadd_mapping __NFF((char *title1, char *title2, NFFmap entity));
extern long _NFFadd_map_notify __NFF((int g_label, int row, Form *form));
extern long _NFFmap_bottom_mcf __NFF((Form form, int label, int row));
extern long _NFFmap_load_data_list __NFF((Form form, MEMptr data_list, int attr_row_offset, char *keyword));
extern long _NFFmap_write_blank_row __NFF((MEMptr data_list));

/* NFFadd_mcf.c */
extern long _NFFadd_create_mcf __NFF((Form form, int label, MEMptr value_list));
extern long _NFFadd_load_mcf __NFF((Form form, int label, MEMptr value_list));

/* NFFadd_usa.c */
extern long NFFadd_util_storage_area __NFF((char *node));
extern long _NFFadd_util_sa_notify __NFF((int g_label, Form *form));
extern long _NFFadd_usa_get_text __NFF((Form form, int label, int *width, NFFaddusa ptr));
extern long _NFFadd_usa_validate_accept __NFF((NFFaddusa ptr));
extern long _NFFwrite_sa_data __NFF((NFFaddusa ptr));
extern void NFFfree_addusa __NFF((Form *form, NFFaddusa ptr));
extern long _NFFadjust_add_usa_form __NFF((Form form));

/* NFFarchive.c */
extern long _NFFarchive_flagged_items __NFF((void));

/* NFFbackup.c */
extern long _NFFbackup_flagged_items __NFF((void));

/* NFFcan_coitm.c */
extern long NFFcancel_item_checkout __NFF((int display_flag, char *catalog, char *item_name, char *revision));
extern long _NFFcancel_item_co __NFF((int f_label, int display_flag, char *command, char *entity1, char *entity2, char *entity3, char *prompt1, char *prompt2));
extern long _NFFcancel_item_checkout_notify __NFF((int g_label, Form *form));

/* NFFcan_coset.c */
extern long NFFcancel_set_checkout __NFF((int display_flag, char *catalog, char *item_name, char *revision));
extern long _NFFcancel_set_checkout __NFF((int f_label, int display_flag, char *command, char *entity1, char *entity2, char *entity3, char *prompt1, char *prompt2));
extern long _NFFcancel_set_checkout_notify __NFF((int g_label, Form *form));

/* NFFcan_iflg.c */
extern long NFFcancel_item_flag __NFF((int display_flag, int command, char *catalog, char *item_name, char *revision));

/* NFFcan_pflg.c */
extern long NFFcancel_project_flag __NFF((int display_flag, int command, char *project));

/* NFFcan_sflg.c */
extern long NFFcancel_set_flag __NFF((int display_flag, int command, char *catalog, char *set_name, char *revision));

/* NFFcat_acl.c */
extern long NFFadd_catalog_acl_mapping __NFF((char *catalog));
extern long NFFdelete_catalog_acl_mapping __NFF((char *catalog));

/* NFFcat_sa.c */
extern long NFFadd_catalog_sa_mapping __NFF((char *catalog));
extern long NFFdelete_catalog_sa_mapping __NFF((char *catalog));

/* NFFcat_tools.c */
extern long _NFFcat_build_value_buffer __NFF((Form form, int label, char *list_or_keyin, char *value_column, char *value_type, NFFcatalog catalog));
extern long _NFFcat_convert_catalog_name __NFF((Form form, int label, MEMptr attr_list, int active_row, char *text));
extern long _NFFcat_attributes_gadgets __NFF((Form form, int mode));
extern long _NFFcat_information_gadgets __NFF((Form form, int mode));
extern long _NFFcat_bezels __NFF((Form form, int mode));
extern long _NFFfind_highest_seqno __NFF((NFFcatalog catalog, int *seqno));
extern long _NFFcat_set_range_attr __NFF((Form form, char *datatype));

/* NFFcatalog.c */
extern long _NFFcat_load_catalog_attributes __NFF((Form form, int label, NFFcatalog catalog));
extern long _NFFcat_attributes_mcf __NFF((Form form, int label, NFFcatalog catalog, int row_no));
extern long _NFFcat_set_defaults __NFF((Form form, NFFcatalog catalog, int attribute, char *attr_name, char *datatype, short delete_flag));
extern long _NFFcat_set_characteristics __NFF((Form form, NFFcatalog catalog, int attribute, short *delete_flag));
extern long _NFFcat_set_values __NFF((Form form, NFFcatalog catalog, char *attr_name));
extern long _NFFcat_advice_button __NFF((Form form));
extern long _NFFcat_advice_field __NFF((Form form, int label, NFFcatalog catalog));
extern long _NFFcat_validate_button __NFF((Form form, NFFcatalog catalog));
extern long _NFFcat_validate_toggle __NFF((Form form, int state));
extern long _NFFcat_add_user_defined __NFF((Form form, int label, NFFcatalog catalog));
extern long _NFFcat_delete_user_defined __NFF((Form form, int label, NFFcatalog catalog));
extern long _NFFcat_keyin_field __NFF((Form form, int label, NFFcatalog catalog, int mcf_col));
extern long _NFFcat_default_field __NFF((Form form, int label, NFFcatalog catalog));
extern long _NFFcat_get_characteristics __NFF((Form form, int label, char *column, NFFcatalog catalog));
extern long _NFFcat_rollthru_fields __NFF((Form form, int label, int row, char *column, NFFcatalog catalog));
extern long _NFFcat_min_field __NFF((Form form, int label, NFFcatalog catalog));
extern long _NFFcat_max_field __NFF((Form form, int label, NFFcatalog catalog));
extern long _NFFcat_list_field __NFF((Form form, int label, NFFcatalog catalog));
extern long _NFFcat_validate_accept __NFF((NFFcatalog catalog));
extern long _NFFcat_attr_new_or_old __NFF((NFFcatalog catalog, int attribute, short *new_attr));
extern void _NFFfree_catalog __NFF((NFFcatalog catalog, Form *form));

/* NFFch_cat.c */
extern long NFFchange_catalog __NFF((char *catalog_name));
extern long _NFFchcat_notify __NFF((int g_label, int row, Form *form));
extern void _NFFcat_update_buffer __NFF((NFFcatalog catalog));

/* NFFch_files.c */
extern long NFFchange_item_file_attributes __NFF((char *catalog, char *item, char *revision));

/* NFFch_item.c */
extern long NFFchange_item __NFF((char *catalog, char *item_name, char *revision));
extern long _NFFchange_item_notify __NFF((int g_label, int row, Form *form));

/* NFFch_sa_pwd.c */
extern long NFFchange_storage_area_password __NFF((char *st_area));
extern long _NFFchange_sa_password_notify __NFF((int g_label, Form *form));

/* NFFch_u_pwd.c */
extern long NFFchange_user_password __NFF((char *command, char *user_name));
extern long _NFFchange_user_password_notify __NFF((int g_label, Form *form));

/* NFFch_wa_pwd.c */
extern long NFFchange_working_area_password __NFF((char *working_area));
extern long _NFFchange_wa_password_notify __NFF((int g_label, Form *form));

/* NFFchg_iwf.c */
extern long NFFchange_item_workflow __NFF((void));
extern long _NFFchange_item_wf_notify __NFF((int g_label, Form *form));
extern long _NFFload_wf_data __NFF((Form form, int label, MEMptr data_list));
extern long _NFFload_state_data __NFF((Form form, int label, MEMptr data_list));
extern long _NFFprocess_wf_list __NFF((Form form, NFFiwf_ptr ptr));
extern long _NFFprocess_state_list __NFF((Form form, NFFiwf_ptr ptr));
extern void _NFFfree_chgwf __NFF((Form *form, NFFiwf_ptr ptr));
extern void _NFFprocess_change_wf_list __NFF((Form *current_form, int f_label, int g_label, NFFiwf_ptr ptr));

/* NFFci_item.c */
extern long NFFcheckin_item __NFF((int display_flag, char *catalog, char *item_name, char *revision));

/* NFFci_set.c */
extern long NFFcheckin_set __NFF((int display_flag, char *catalog, char *item_name, char *revision));

/* NFFco_item.c */
extern long NFFcheckout_item __NFF((int display_flag, char *catalog, char *item_name, char *revision));

/* NFFco_set.c */
extern long NFFcheckout_set __NFF((int display_flag, char *catalog, char *item_name, char *revision));

/* NFFconfig.c */
extern long _NFFsetup_config __NFF((void));

/* NFFconfirm.c */
extern long _NFFconfirm __NFF((int f_label, int display_flag, char *entity1, char *entity2, char *entity3, char *prompt1, char *prompt2));
extern long _NFFconfirm_notify __NFF((int f_label, int g_label, Form *form));
extern void _NFFfree_confirm __NFF((NFFconfirm_ptr ptr, Form *form));

/* NFFcopy_acl.c */
extern long NFFcopy_acl_users __NFF((void));
extern long _NFFcopy_acl_notify __NFF((int g_label, int row, Form *form));
extern long _NFFcopy_acl_users __NFF((char *aclname, long wfno, char *workflow));
extern long _NFFcopy_acl_users_notify __NFF((int g_label, int row, Form *form));
extern long _NFFget_acl_wf __NFF((NFFadd_ptr ptr, char *acl, long *workflowno, char *workflow));
extern long _NFFcopy_acl_attributes_field __NFF((Form form, int row_no, NFFadd_ptr ptr));
extern long _NFFblank_entry __NFF((Form form, NFFadd_ptr ptr));
extern long _NFFcopy_acl_validate_field __NFF((Form form, int row, NFFadd_ptr ptr));
extern long _NFFcopy_acl_load_attributes __NFF((Form form, NFFadd_ptr ptr));
extern long _NFFadd_set_lower_half_for_copy_acl __NFF((Form form, NFFadd_ptr ptr, long row));
extern long _NFFcopy_acl_load_mcf __NFF((Form form, int label, MEMptr value_list));
extern long _NFFcreate_text_dyn __NFF((Form form, int *label, int x, int y, char *title));

/* NFFcopy_item.c */
extern long NFFcopy_item __NFF((char *catalog, char *item, char *revision));

/* NFFcp_item.c */
extern long _NFFcopy_item __NFF((NFFcopy_ptr ptr));
extern long _NFFcopy_item_notify __NFF((int g_label, int value, Form *form));

/* NFFcp_tools.c */
extern long _NFFcopy_list_mcf __NFF((Form form, int mode, char *read_or_write, int row_array[], MEMptr attr_list, MEMptr data_list));
extern long _NFFcreate_list_mcf __NFF((Form form, int label1, int label2, int mode, int vis_rows, int vis_cols, int vis_chars, MEMptr data_list));
extern long _NFFload_mcf_data __NFF((Form form, int label1, int label2, MEMptr attr_list, MEMptr data_list));
extern long _NFFalter_list_scroll_gadgets __NFF((Form form));
extern long _NFFload_cp_attr_list __NFF((Form form, int g_label, int row_array[], MEMptr attr_list));
extern void NFFfree_copy __NFF((Form *form, NFFcopy_ptr ptr));
extern long _NFFcreate_new_buffer __NFF((int row_array[], char *read_or_write, MEMptr attr_list, MEMptr data_list, MEMptr *nattr_list, MEMptr *ndata_list));

/* NFFcr_cat.c */
extern long NFFcreate_catalog __NFF((void));
extern long _NFFcrcat_notify __NFF((int g_label, int row, Form *form));

/* NFFd_items.c */
extern long NFFdisplay_items __NFF((int locate_flag));
extern long NFFdisplay_project_members __NFF((int locate_flag));
extern long NFFdisplay_set_members __NFF((int locate_flag));
extern long NFFreview_item __NFF((int locate_flag));
extern long _NFFdisplay_items_notify __NFF((int f_label, int g_label, int row, Form *form));
extern long _NFFmore_data __NFF((int f_label, int rows));
extern long _NFFend_block_listing __NFF((int f_label, int load_message));
extern void _NFFenable_scrollbar __NFF((Form form, int label, int scroll_at_bottom));

/* NFFdebug.c */
extern long NFFdebug __NFF((void));
extern long _NFFdebug_notify __NFF((int g_label, Form *form));

/* NFFdef_smem.c */
extern long NFFdefine_members __NFF((char *project, char *catalog_name, char *set_name, char *revision, char *command));
extern long _NFFdefine_set_members_notify __NFF((int g_label, Form *form));
extern long _NFFdefine_project_members_notify __NFF((int g_label, Form *form));
extern long _NFFadjust_members_form __NFF((Form form));

/* NFFdef_srch.c */
extern long NFFdefine_search_criteria __NFF((char *catalog));

/* NFFdefaults.c */
extern long NFFread_user_defaults __NFF((void));
extern long NFFwrite_user_defaults __NFF((void));

/* NFFdel_acl.c */
extern long NFFdelete_acl __NFF((char *workflow, char *acl_name));
extern long _NFFconfirm_acl_notify __NFF((int g_label, Form *form));

/* NFFdel_cat.c */
extern long NFFdelete_catalog __NFF((char *catalog_name));

/* NFFdel_cp.c */
extern long NFFdelete_copied_files __NFF((void));
extern long _NFFdelete_copied_files_notify __NFF((int g_label, Form *form));
extern long _NFFdelete_copied_files __NFF((MEMptr *buffer));

/* NFFdel_files.c */
extern long NFFdelete_files_from_item __NFF((char *catalog, char *item, char *revision));

/* NFFdel_item.c */
extern long NFFdelete_item __NFF((int display_flag, char *catalog, char *item_name, char *revision));

/* NFFdel_label.c */
extern long _NFFdelete_tape_labels_notify __NFF((int g_label, Form *form));
extern long _NFFbuild_tape_labels_buffer __NFF((Form form, MEMptr *data));

/* NFFdel_map.c */
extern long _NFFdelete_mapping __NFF((char *title1, char *title2, NFFmap entity));
extern long _NFFdelete_map_notify __NFF((int g_label, int row, Form *form));

/* NFFdel_mem.c */
extern long NFFdelete_set_members __NFF((char *catalog, char *set_name, char *revision));
extern long NFFdelete_project_members __NFF((char *project));
extern long _NFFdefine_members __NFF((char *entity_name, char *set_name, char *revision, char *title, int command));
extern long _NFFdefine_members_notify __NFF((int g_label, double value, Form *form));
extern long _NFFdefine_members_write_keyword __NFF((Form form, MEMptr data_list, int command, char *keyword));
extern void NFFfree_fitem __NFF((Form *form, NFFfitem item));

/* NFFdel_node.c */
extern long NFFdelete_node __NFF((char *node));

/* NFFdel_prj.c */
extern long NFFdelete_project __NFF((char *project));

/* NFFdel_qry.c */
extern long NFFdelete_sort_criteria __NFF((char *sort_name));
extern long NFFdelete_search_criteria __NFF((char *search_name));
extern long _NFFdelete_query_notify __NFF((int f_label, int g_label, Form *form));

/* NFFdel_sa.c */
extern long NFFdelete_storage_area __NFF((char *st_area));

/* NFFdel_sort.c */
extern long NFFdelete_sort_criteria __NFF((char *sort_name));

/* NFFdel_srch.c */
extern long NFFdelete_search_criteria __NFF((char *search_name));

/* NFFdel_user.c */
extern long NFFdelete_user __NFF((char *user));

/* NFFdelete.c */
extern long _NFFdelete_flagged_items __NFF((void));

/* NFFdisplay.c */
extern long NFFdisplay_tape_labels __NFF((void));
extern long NFFdisplay_items_on_tape __NFF((int locate_flag));
extern long NFFdisplay_savesets __NFF((int locate_flag));
extern long NFFdisplay_archives __NFF((int locate_flag));
extern long NFFwhere_used_project __NFF((int locate_flag));
extern long NFFwhere_used_set __NFF((int locate_flag));
extern long NFFdisplay_item_signoffs __NFF((int locate_flag));
extern long NFFdisplay_signoff_history __NFF((int locate_flag));
extern long NFFdisplay_local_files __NFF((int locate_flag));
extern long NFFdisplay_nodes __NFF((int locate_flag));
extern long NFFdisplay_storage_areas __NFF((int locate_flag));
extern long NFFdisplay_working_areas_admin __NFF((int locate_flag));
extern long NFFdisplay_working_areas_user __NFF((int locate_flag));
extern long NFFdisplay_users __NFF((int locate_flag));
extern long NFFdisplay_catalogs __NFF((int locate_flag));
extern long NFFdisplay_workflows __NFF((int locate_flag));
extern long NFFdisplay_acls __NFF((int locate_flag));
extern long NFFdisplay_aclusers __NFF((int locate_flag));
extern long NFFdisplay_signoff_users __NFF((int locate_flag));
extern long NFFdisplay_projects __NFF((int locate_flag));
extern long NFFdisplay_catalog_acl_mapping __NFF((int locate_flag));
extern long NFFdisplay_catalog_sa_mapping __NFF((int locate_flag));
extern long NFFdisplay_project_acl_mapping __NFF((int locate_flag));
extern long NFFdisplay_project_sa_mapping __NFF((int locate_flag));
extern long NFFdisplay_search_criteria __NFF((int locate_flag));
extern long NFFdisplay_sort_criteria __NFF((int locate_flag));
extern long NFFdisplay_archive_flags __NFF((int locate_flag));
extern long NFFdisplay_backup_flags __NFF((int locate_flag));
extern long NFFdisplay_restore_flags __NFF((int locate_flag));
extern long NFFdisplay_delete_flags __NFF((int locate_flag));
extern long _NFFdisplay_notify __NFF((int f_label, int g_label, int row, Form *form));
extern long _NFFload_display __NFF((int f_label, char *form_name, int num_cols, char *title, MEMptr data, int locate_flag));
extern void _NFFplace_form __NFF((int f_label));
extern void NFFfind_mcf_attribute __NFF((Form form, int label, char *attrname, int *col));
extern void _NFFalter_item_text_label __NFF((char *new_text));

/* NFFexit.c */
extern void _NFFexit __NFF((long status));

/* NFFf_tools.c */
extern long _NFFset_select_attr_data __NFF((Form form, int data_rows, int *act_row, int *act_col, NFFadd_ptr ptr));
extern long _NFFprocess_value_field __NFF((Form form, int act_row, int act_col, NFFadd_ptr ptr, int val_col));
extern long _NFFprocess_validate_field __NFF((Form form, int row, int act_row, int act_col, NFFadd_ptr ptr, int val_col));
extern long _NFFset_value_info __NFF((Form form, NFFadd_ptr ptr, int sel_row, int sel_col, int *pos_cur));
extern long _NFFset_advisory_info __NFF((Form form, NFFadd_ptr ptr, int act_col));
extern long _NFIload_copy_data __NFF((Form form, NFFadd_ptr ptr, char *write_attr));
extern long _NFFdisable_value_info __NFF((Form form, NFFadd_ptr ptr));
extern long _NFFdelete_data_row __NFF((Form form, int g_label, MEMptr data_list, MEMptr *new_list));
extern long _NFFset_data_row_status __NFF((MEMptr data_list));
extern long _NFFadd_data_row __NFF((Form form, int g_label, int *act_row, int *act_col, int row_array[], MEMptr data_list, MEMptr temp_list));
extern long _NFFcreate_validation_mcf __NFF((Form form, int label, MEMptr value_list));
extern long _NFFdelete_add_rows __NFF((Form form, int g_label, int *act_row, int *act_col, MEMptr data_list, MEMptr *new_list));
extern long _NFFselect_all_rows __NFF((Form form, int g_label, int row_array[], MEMptr data_list));
extern long _NFFset_delete_data_rows __NFF((Form form, int g_label, MEMptr data_list));
extern long _NFFnadd_validate_text __NFF((char *text, MEMptr value_list, int val_col));
extern long _NFFprocess_validate_accept __NFF((Form form, char *write_attr, int *act_row, int *act_col, NFFadd_ptr ptr, int val_col));
extern long _NFFgeneric_fld_pos_cur __NFF((Form form, int g_label, int *act_row, int *act_col, NFFadd_ptr ptr));
extern long _NFFadd_fld_pos_cur __NFF((Form form, int g_label, int cur_row, int cur_col, int *act_row, int *act_col, NFFadd_ptr ptr));

/* NFFfei.c */
extern int FEI_get_refresh_area_data __NFF((int *window, int *vs, int *xlo, int *ylo, int *xhi, int *yhi, int *axlo, int *aylo, int *axhi, int *ayhi, int *opmask));
extern int FEI_inq_button_data __NFF((int *window, int *x, int *y, int *button, int *trans, int *ttag));
extern int _NFFget_button_data __NFF((int *w, int *x, int *y, int *button, int *transition, int *timetag));
extern int _NFFinq_button_data __NFF((int *w, int *x, int *y, int *button, int *transition, int *timetag));
extern int FEI_get_keyboard_data __NFF((char *character, int *count, int font_type));
extern int FEI_set_window_attr __NFF((int window));
extern int FEI_enter __NFF((void));

/* NFFfgets.c */
extern char *_NFFfgets __NFF((char *s, int n, FILE *stream));

/* NFFfile_io.c */
extern long _NFFfile_io __NFF((int f_label, int display_flag, char *command, char *entity1, char *entity2, char *entity3, char *prompt1, char *prompt2));
extern long _NFFfile_io_confirm_notify __NFF((int g_label, Form *form));

/* NFFfl_item.c */
extern long NFFflag_item_files __NFF((int display_flag, int command, char *catalog, char *item_name, char *revision));

/* NFFfl_proj.c */
extern long NFFflag_project_files __NFF((int display_flag, int command, char *project));

/* NFFfl_set.c */
extern long NFFflag_set_files __NFF((int display_flag, int command, char *catalog, char *set_name, char *revision));

/* NFFfl_tools.c */
extern long _NFFadjust_confirm_form __NFF((Form form));

/* NFFflag.c */
extern long NFFprocess_flagged_files __NFF((void));
extern long _NFFflagged_files_notify __NFF((int g_label, Form *form));
extern void _NFFfree_flag __NFF((NFFnflag_ptr ptr, Form *form));

/* NFFflag_item.c */
extern long NFFnflag_item_files __NFF((char *catalog, char *item, char *revision, int type));
extern long _NFFflag_item_notify __NFF((int g_label, Form *form));
extern long _NFFset_mcf_flag_data __NFF((Form form, NFFflag_ptr ptr));
extern long _NFFvalidate_flag_accept __NFF((Form form, NFFflag_ptr ptr));
extern long _NFFadjust_flag_form __NFF((Form form));
extern void _NFFfree_flag_ptr __NFF((Form *form, NFFflag_ptr ptr));

/* NFFg_confirm.c */
extern long _NFFgeneric_confirm_notify __NFF((int g_label, Form *form));

/* NFFget_map.c */
extern long _NFFget_mapping __NFF((char *entity_name, char *title1, char *title2, int command));
extern long _NFFmap_scan_attributes __NFF((MEMptr attr_list, int *no_attributes, int *attr_row_offset));
extern void _NFFfree_map __NFF((NFFmap entity, Form *form));

/* NFFhelp.c */
extern int _NFFhelp_toc __NFF((void));
extern int _NFFhelp_topic __NFF((char *command));
extern long _NFFinit_help __NFF((void));

/* NFFinit.c */
extern void _NFFinit_global __NFF((void));
extern long _NFFinit_graphics __NFF((void));

/* NFFjournal.c */
extern int JNL_init_journal __NFF((char *filename, int excl_flag));
extern int JNL_init_playback __NFF((char *filename));
extern int JNL_record_new_window __NFF((int window));
extern int JNL_echo_event __NFF((int mask, int *event));
extern int JNL_process_info_event __NFF((int new_window));
extern int JNL_process_del_info_event __NFF((void));
extern int JNL_record_info_event __NFF((int type, int event_nbytes, char *string));
extern int JNL_record_event __NFF((int event));
extern int JNL_close_jnl __NFF((void));
extern int JNL_close_jnl_pbk __NFF((void));
extern int JNL_close_echo __NFF((void));
extern int JNL_record_input __NFF((int nbytes, char *buffer));
extern int JNL_echo_input __NFF((int nbytes, char *buffer));
extern int JNL_adjust_echo __NFF((void));
extern int JNL_adjust_echo_button __NFF((void));
extern int JNL_adjust_echo_refresh_button __NFF((void));
extern int JNL_adjust_echo_collapse_button __NFF((void));
extern int JNL_adjust_delete_button __NFF((void));
extern int JNL_wait_for_next __NFF((int mask, int *event));
extern int JNL_inq_events __NFF((int *event));
extern int JNL_inq_button_data __NFF((int *window, int *x, int *y, int *btype, int *state, int *timetag));
extern int JNL_get_button_data __NFF((int *window, int *x, int *y, int *btype, int *state, int *timetag));
extern int JNL_process_slow_echo __NFF((void));
extern int JNL_oldwindow_to_window __NFF((int oldwindow, int *window));
extern int JNL_get_refresh_area_data __NFF((int *window, int *vs_no, int *x, int *y, int *x2, int *y2, int *ax1, int *ay1, int *ax2, int *ay2, int *opmask));
extern int JNL_inq_refresh_area_data __NFF((int *window, int *vs_no, int *x, int *y, int *x2, int *y2, int *ax1, int *ay1, int *ax2, int *ay2, int *opmask));
extern int JNL_get_collapse_data __NFF((int *window, int *opmask));
extern int JNL_inq_collapse_data __NFF((int *window, int *opmask));
extern int JNL_get_delete_data __NFF((int *window));
extern int JNL_inq_delete_data __NFF((int *window));
extern int JNL_inq_user_data __NFF((int *user_data));
extern int JNL_get_user_data __NFF((int *user_data));
extern int JNL_inq_win_user_icon_data __NFF((int *window, int *icon_id));
extern int JNL_get_win_user_icon_data __NFF((int *window, int *icon_id));
extern int JNL_start_timer __NFF((int delta_time, int repeatflag, int *timer_no));
extern int JNL_stop_timer __NFF((int timer_no));
extern int JNL_get_timer_data __NFF((int *timer_no));
extern int JNL_echo_timer_data __NFF((int *timer_no));
extern int JNL_record_timer_data __NFF((int *timer_no));
extern int JNL_set_keyboard_buffer __NFF((char *buffer, int count));
extern int JNL_get_keyboard_data __NFF((int *count));
extern int JNL_inq_keyboard_data __NFF((int *count));
extern int JNL_inq_keyboard_buffer __NFF((char **buf_addr, int *count));
extern int JNL_set_timer_playback __NFF((int mytime));
extern int JNL_playback __NFF((void));
extern int JNL_journal __NFF((void));

/* NFFlist.c */
extern void _NFFprocess_list __NFF((int f_label, int g_label));
extern long _NFFerror_notify __NFF((int g_label, Form *form));

/* NFFlist_mcf.c */
extern long _NFFlist_load_mcf __NFF((Form form, int mode, MEMptr syn_list, MEMptr data_list));
extern long _NFFreview_load_mcf __NFF((Form form, MEMptr syn_list, MEMptr data_list));
extern long _NFFlist_create_mcf __NFF((Form form, int label, int mode, MEMptr data_list));
extern long _NFFreview_create_mcf __NFF((Form form, int label, MEMptr data_list));
extern long _NFFlist_load_mcf_data __NFF((Form form, int start_row, MEMptr syn_list, MEMptr data_list));
extern long _NFFreview_load_mcf_data __NFF((Form form, MEMptr syn_list, MEMptr data_list));

/* NFFlock_item.c */
extern long NFFlock_item __NFF((char *catalog, char *item_name, char *revision));

/* NFFlogin.c */
extern long NFFlogin __NFF((void));
extern long NFFform_login __NFF((void));
extern long _NFFlogin_notify __NFF((int g_label, Form *form));
extern void NFFpost_login __NFF((int first_time_flag));
extern long NFFlogout __NFF((void));
extern void NFFerase_active_data __NFF((void));
extern long _NFFvalidate_login_accept __NFF((void));

/* NFFmain.c */
extern int main __NFF((int argc, char *argv[]));

/* NFFmain_form.c */
extern long NFFinit_main_form __NFF((void));
extern long _NFFmain_notify __NFF((int g_label, int value, Form form));
extern void _NFFmain_window_event_routine __NFF((int f_label, int event, Form form));

/* NFFmap_mcf.c */
extern long _NFFmap_load_value_list __NFF((Form form, NFFmap entity, int filter_flag));
extern long _NFFmap_create_mcf __NFF((Form form, int label, MEMptr value_list));
extern long _NFFmap_load_mcf __NFF((Form form, int filter_flag, int attr_row, MEMptr data_list, MEMptr value_list));
extern long _NFFmap_load_add_mcf __NFF((Form form, int label, int attr_row, MEMptr data_list, MEMptr value_list));
extern long _NFFmap_load_delete_mcf __NFF((Form form, int label, int attr_row, MEMptr data_list, MEMptr value_list));

/* NFFmcf_tools.c */
extern long _NFFfcreate_list_mcfs __NFF((Form form, int label1, int label2, int mode, char *read_or_write, MEMptr attr_list, MEMptr data_list));
extern long _NFFgenerate_mcfs __NFF((Form form, int label1, int label2, int mode, int vis_rows, int vis_cols, int vis_chars, int row_array[], MEMptr data_list));
extern long _NFFload_data_into_mcfs __NFF((Form form, int label1, int label2, int row_array[], MEMptr attr_list, MEMptr data_list));
extern long _NFFgeneric_load_data __NFF((Form form, int label, MEMptr data_list));
extern long _NFFgeneric_mcf_select_all_rows __NFF((Form form, int toggle_label, int mcf_label, int num_rows));

/* NFFmem_tools.c */
extern long _NFFload_members_mcf __NFF((Form form, NFFset_ptr entity, char *command));
extern void _NFFfree_setm __NFF((Form *form, NFFset_ptr entity));
extern long _NFFadd_set_members_mcf __NFF((int g_label, Form form, NFFset_ptr entity, char *command));
extern long _NFFget_field_text __NFF((int g_label, Form form, char *text));
extern long _NFFremove_set_members_mcf __NFF((int g_label, Form form, NFFset_ptr entity));
extern long _NFFprocess_select_scf __NFF((int g_label, Form form, NFFset_ptr entity));
extern long _NFFprocess_field_entry __NFF((int g_label, Form form, NFFset_ptr entity));
extern long _NFFvalidate_user_data __NFF((int g_label, char *text, NFFset_ptr entity, int *row));
extern long _NFFprocess_type __NFF((int g_label, Form form, NFFset_ptr entity));
extern long _NFFvalidate_item_type __NFF((char *item_name, char *revision, int state, short type_offset, short item_name_offset, short rev_name_offset, MEMptr data_list));
extern long _NFFget_scf_data_list __NFF((int g_label, Form form, NFFset_ptr entity));
extern long _NFFget_list_of_catalogs __NFF((MEMptr *cat_data, short *offset));
extern long _NFFmem_set_text __NFF((Form form, int g_label, char *title));
extern long _NFFdisplay_catalogs __NFF((Form form, int g_label, NFFset_ptr entity));
extern long _NFFget_list_of_items __NFF((Form form, int g_label, int display_values, NFFset_ptr entity, char *project_name, char *catalog_name));
extern long _NFFdisplay_items __NFF((Form form, int g_label, NFFset_ptr entity));
extern long _NFFdisplay_revisions __NFF((Form form, int g_label, NFFset_ptr entity));
extern long _NFFinsert_set_members_in_list __NFF((NFFset_ptr entity, int *rows, struct NFMmember_info *member_list[]));
extern long _NFFinsert_project_members_in_list __NFF((NFFset_ptr entity));
extern long _NFFadjust_set_members_form __NFF((Form form));
extern long _NFFupdate_set_members_in_list __NFF((Form form, int g_label, NFFfitem entity, int *rows, struct NFMmember_info *member_list[]));

/* NFFmenu.c */
extern long _NFFinit_menus __NFF((void));

/* NFFmessage.c */
extern void NFFform_message __NFF((int f_label, int message_no, char *message_fmt, ...));
extern void NFFerror_message __NFF((Form form));
extern void NFFerase_message __NFF((void));

/* NFFmk_trans.c */
extern long NFFmake_transition __NFF((void));
extern long _NFFmk_trans_notify __NFF((int g_label, int row, Form *form));
extern long _NFFmk_trans_load_states __NFF((Form form, NFFmk_trans trans));
extern long _NFFmk_trans_next_state __NFF((Form form, NFFmk_trans trans));
extern long _NFFmk_trans_possible_states __NFF((Form form, int row));
extern long _NFFmk_trans_validate_accept __NFF((Form form, NFFmk_trans trans));
extern void _NFFfree_make_trans __NFF((NFFmk_trans trans, Form *form));

/* NFFncp_item.c */
extern long NFFn_copy_item_files __NFF((int display_flag, char *catalog, char *item_name, char *revision));

/* NFFncp_set.c */
extern long NFFn_copy_set_files __NFF((int display_flag, char *catalog, char *item_name, char *revision));

/* NFFnotify.c */
extern void _NFFnotify __NFF((int f_label, int g_label, double value, Form form));

/* NFFparse.c */
extern int _NFFparse_input __NFF((int argc, char *argv[]));

/* NFFpasswd.c */
extern long _NFFold_passwd_field __NFF((Form form, int label, NFFpasswd entity));
extern long _NFFnew_passwd_field __NFF((Form form, int label, NFFpasswd entity));
extern long _NFFverify_passwd_field __NFF((Form form, int label, NFFpasswd entity));
extern long _NFFpasswd_validate_accept __NFF((NFFpasswd entity));
extern void NFFfree_passwd __NFF((Form *form, NFFpasswd entity));

/* NFFplot.c */
extern long NFFplot_item __NFF((int display_flag, char *catalog, char *item, char *revision));
extern long NFFplot_set __NFF((int display_flag, char *catalog, char *set, char *revision));
extern long NFFplot_set_parent __NFF((char *catalog, char *set, char *revision));

/* NFFpopup.c */
extern long NFFserver_popup __NFF((void));
extern long NFFenv_popup __NFF((void));
extern long NFFproject_popup __NFF((void));
extern long NFFcatalog_popup __NFF((void));
extern long NFFitem_popup __NFF((void));
extern long NFFrevision_popup __NFF((void));
extern long NFFsearch_popup __NFF((void));
extern long NFFsort_popup __NFF((void));
extern long NFFwa_popup __NFF((void));
extern long NFFsa_popup __NFF((void));
extern long NFFnode_popup __NFF((void));
extern long NFFuser_popup __NFF((void));
extern long NFFwf_popup __NFF((void));
extern long NFFacl_popup __NFF((void));
extern long _NFFload_popup __NFF((int f_label, char *title, MEMptr data));
extern long _NFFpopup_notify __NFF((int f_label, int g_label, int row, Form *form));

/* NFFprint.c */
extern long _NFFprint_listing __NFF((int f_label));
extern long _NFFprint_to_file __NFF((Form form, int num_cols, int *cols, char *time_string, char *filename));

/* NFFprj_acl.c */
extern long NFFadd_project_acl_mapping __NFF((char *project));
extern long NFFdelete_project_acl_mapping __NFF((char *project));

/* NFFprj_sa.c */
extern long NFFadd_project_sa_mapping __NFF((char *project));
extern long NFFdelete_project_sa_mapping __NFF((char *project));

/* NFFproc_file.c */
extern long _NFFprocess_item_files __NFF((NFFcopy_ptr ptr));
extern long _NFFprocess_files_notify __NFF((int g_label, int value, Form *form));

/* NFFproc_form.c */
extern long _NFF_process_environv_forms __NFF((void));
extern long _NFF_process_x_forms __NFF((void));

/* NFFprocess.c */
extern void _NFFprocess_data __NFF((int type, char *command));
extern void _NFFdelete_forms __NFF((void));

/* NFFpur_so.c */
extern long NFFpurge_signoff __NFF((char *catalog, char *item_name, char *revision));

/* NFFpur_vers.c */
extern long NFFpurge_file_versions __NFF((int display_flag, char *catalog, char *item_name, char *revision));

/* NFFrestore.c */
extern long _NFFrestore_flagged_items __NFF((void));

/* NFFsave.c */
extern long NFFsave_item __NFF((int display_flag, char *catalog, char *item, char *revision));
extern long NFFsave_set __NFF((int display_flag, char *catalog, char *set, char *revision));
extern long NFFsave_set_parent __NFF((char *catalog, char *set, char *revision));

/* NFFsaveset.c */
extern long NFFdelete_saveset_entries __NFF((void));
extern long _NFFdelete_saveset_entries_notify __NFF((int g_label, Form *form));
extern long _NFFbuild_savesets_buffer __NFF((Form form, MEMptr old_buffer, MEMptr *new_buffer));

/* NFFscroll.c */
extern void _NFFscroll_message __NFF((Form form, int label));
extern void _NFFscroll_message_one_word __NFF((Form form, int label));

/* NFFset_io.c */
extern long _NFFset_io __NFF((int f_label, int display_flag, char *command, char *entity1, char *entity2, char *entity3, char *prompt1, char *prompt2));
extern long _NFFset_io_confirm_notify __NFF((int g_label, Form *form));

/* NFFsignal.c */
extern long _NFFsetup_signals __NFF((void));
extern void _NFFsignal __NFF((int type));

/* NFFsignoff.c */
extern long NFFsignoff_on_item __NFF((void));
extern long _NFFsignoff_on_item_notify __NFF((int g_label, int value, Form *form));
extern long _NFFsignoff_override_button __NFF((int label, int state, NFFsignoff signoff));
extern long _NFFsignoff_reason_field __NFF((Form form, int label, NFFsignoff signoff));
extern long _NFFadjust_signoff_form __NFF((Form form));
extern void NFFfree_signoff __NFF((Form *form, NFFsignoff ptr));

/* NFFsort.c */
extern long NFFdefine_sort_criteria __NFF((char *catalog_name));
extern long _NFFdefine_sort_criteria_notify __NFF((int g_label, double value, Form *form));
extern long _NFFprocess_sort_mcf __NFF((Form form, int g_label, NFFsort_ptr entity));
extern long _NFFprocess_sort_input __NFF((Form form, NFFsort_ptr entity, struct NFMquery_info *query_info));
extern long _NFFload_attributes_mcf __NFF((Form form, int g_label, NFFsort_ptr entity));
extern long _NFFprocess_sort_name __NFF((Form form, int g_label, NFFsort_ptr entity));
extern void _NFFfree_sortptr __NFF((NFFsort_ptr entity, Form *form));

/* NFFtimestamp.c */
extern void __NFFts_data __NFF((char *format, ...));
extern void __NFFts_commit __NFF((void));

/* NFFtools.c */
extern long _NFFcenter_form __NFF((Form form, int xlocation, int ylocation));
extern long _NFFcenter_gadget __NFF((Form form, int label));
extern long _NFFfind_column_offset __NFF((MEMptr buffer, char *attrname, short *offset));
extern long _NFFbuild_value_buffer __NFF((MEMptr *buffer));
extern long _NFFfind_attribute_name __NFF((MEMptr buffer, int row, char **name));
extern long _NFFinit_rows __NFF((MEMptr buffer, char *write_attr, int *row_array[]));
extern long _NFFinit_cols __NFF((MEMptr buffer, int *col_array[], char *read_attr, char *write_attr, char *read_value, char *write_value));
extern long _NFFfind_next_writable_row __NFF((MEMptr buffer, char *write_attr, char *write_value, int current_row, int *next_row));
extern long _NFFfind_value_buffer __NFF((MEMptr attr_list, MEMptr value_list, char *attr_name, char *list_or_keyin));
extern long _NFFfind_list_offsets __NFF((MEMptr attr_list, short *syn_offset, short *name_offset));
extern long _NFFvalidate_datatype __NFF((char *datatype, int *width));
extern void _NFFclear_msg __NFF((Form form));
extern long _NFFget_attr_info __NFF((MEMptr attr_list, char *attrname, int *offset, char *n_read, char *n_write, char *type, int *length));
extern void _NFFfind_active_data __NFF((MEMptr buffer, char *attribute, char *data));
extern void _NFFprocess_event __NFF((int refresh_event));
extern void _NFFcheck_two_tics __NFF((char *in, char *out));

/* NFFunlk_item.c */
extern long NFFunlock_item __NFF((char *catalog, char *item_name, char *revision));

/* NFFusage.c */
extern void _NFFinit_usage __NFF((char *program_name, char *usage));

/* NFFutil_msg.c */
extern long NFFprocess_utility_message __NFF((MEMptr msg_buffer));
extern long _NFFutility_message_notify __NFF((int g_label, Form *form));

/* NFFutility.c */
extern long _NFFprocess_ab_items_notify __NFF((int g_label, Form *form));
extern long _NFFutil_load_item_data __NFF((Form form, int label, MEMptr data_list));
extern long _NFFprocess_label_field __NFF((Form form, char *label));
extern long _NFFprocess_util_sa_list __NFF((Form form, NFFutil_ptr ptr));
extern long _NFFcheck_util_user_input __NFF((Form form, NFFutil_ptr ptr, char *sa_no, MEMptr *flist));
extern void _NFFfree_utility __NFF((Form *form, NFFutil_ptr ptr));
extern long _NFFget_util_user_input __NFF((Form form, NFFutil_ptr ptr, MEMptr *flist));
extern long _NFFprocess_label_list __NFF((Form form, char *label));
extern long _NFFerase_label_gadgets __NFF((Form form));
extern long _NFFinit_label_gadgets __NFF((Form form));
extern long _NFFerase_label_list __NFF((Form form));
extern long _NFFdisplay_label_list __NFF((Form form));

/* NFFvalid.c */
extern long _NFFvalid_catalog __NFF((char *catalog_name));
extern long _NFFvalid_item __NFF((char *catalog, char *item_name));
extern long _NFFvalid_revision __NFF((char *catalog, char *item, char *revision, int *set_or_not));
extern long _NFFvalid_sa __NFF((char *saname));
extern long _NFFvalid_project __NFF((char *project));
extern long _NFFvalid_search __NFF((char *search, char *owner));
extern long _NFFvalid_sort __NFF((char *sort, char *owner));
extern long _NFFvalid_wa __NFF((char *waname, char *owner));
extern long _NFFvalid_user __NFF((char *user));
extern long _NFFvalid_node __NFF((char *node));
extern long _NFFvalid_wf __NFF((char *workflow));
extern long _NFFvalid_acl __NFF((char *workflow, char *acl));
extern long _NFFvalidate_active_data __NFF((long mask));

/* NFFversions.c */
extern long NFFroll_version_forward __NFF((char *catalog, char *item_name, char *revision));
extern long _NFFroll_versions_notify __NFF((int g_label, Form *form));
extern void _NFFfree_version __NFF((Form *form, NFFversion_ptr ptr));
extern long _NFFtoggle_unselect_rows __NFF((int g_label, Form form, int num_rows));
extern long _NFFcheck_selected_versions __NFF((int g_label, Form form, MEMptr data_list));
extern long _NFFget_file_versions __NFF((int g_label, Form form, NFFversion_ptr ptr, MEMptr *data_list));

/* NFFvlt.c */
extern long _NFFsetup_vlt __NFF((void));
extern int _NFFtranslate_color __NFF((int vs, int color));

/* NFFwf.c */
extern long NFFvalidate_user_access __NFF((char *command_key));
extern long NFFset_to_state __NFF((void));

#undef __NFF

#endif
