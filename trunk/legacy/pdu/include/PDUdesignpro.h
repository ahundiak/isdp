#ifndef PDU_PROTO_H
#define PDU_PROTO_H

#if defined(__STDC__) || defined(__cplusplus)
# define __PDU(s) s
#else
# define __PDU(s) ()
#endif


/* ./design/PDUatt_list.c */
extern int attach_single_list_notification_routine __PDU((int f_label, int g_label, double value, Form fp));
extern int PDUattach_single_list_form __PDU((char title_str[40], char msg_str[80]));

/* ./design/PDUatt_orig.c */
extern int origin_list_notification_routine __PDU((int f_label, int g_label, double value, Form fp));
extern int PDUdisplay_origins __PDU((void));
extern int PDUload_origins __PDU((void));

/* ./design/PDUdebug.c */
extern void _pdm_debug __PDU((char *message, char *variable));
extern void _pdm_rstatus __PDU((char *meth, int sts1));
extern void _pdm_rstatus2 __PDU((char *meth, int sts1, int sts2));
extern void _pdm_status __PDU((char *meth, int sts1));
extern void _pdm_status2 __PDU((char *meth, int sts1, int sts2));
extern void _pdu_atp_debug __PDU((char *message, char *variable));
extern void _pdu_atp_status __PDU((char *meth, int sts1));
extern void _pdm_debug_list __PDU((char *name, char **list, int rows, int cols));
extern char *_pdm_colptr __PDU((MEMptr buffptr, int row, int col));
extern short PDUnullstr __PDU((char *x));

/* ./design/PDUdsgn_frm.c */
extern int design_form_notification_routine __PDU((int f_label, int g_label, double value, Form fp));
extern int design_form __PDU((void));
extern int PDUdesign_form __PDU((void));
extern int PDUupdate_design_form __PDU((void));
extern int PDUsetup_design_struct __PDU((void));
extern int PDUcheck_file_for_parts __PDU((void));
extern int PDUcheck_file_for_origins __PDU((void));
extern int PDUdisplay_design_form __PDU((void));

/* ./design/PDUdsgn_list.c */
extern int design_parts_notification_routine __PDU((int f_label, int g_label, double value, Form fp));
extern int design_parts_listing_form __PDU((void));
extern int PDUdesign_parts_listing_form __PDU((void));
extern int PDUupdate_design_parts_listing_form __PDU((void));
extern int PDUload_design_parts_listing_form __PDU((void));
extern int PDUload_list_parts_info __PDU((void));

/* ./design/PDUdsp_att.c */
extern void PDUdisplay_views __PDU((void));
extern void PDUdisplay_files __PDU((void));
extern void PDUdisplay_checkin_files __PDU((void));

/* ./design/PDUdyn_form.c */
extern int dynamic_attr_notification_routine __PDU((int f_label, int g_label, double value, Form fp));
extern int PDUadd_dyn_data __PDU((char *attr_name, char *data, MEMptr *dyn_data));
extern int dynamic_attr_form __PDU((void));
extern int PDUdynamic_attr_form __PDU((void));
extern int PDUdisplay_dynamic_form __PDU((void));
extern int PDUdynamics_for_part __PDU((MEMptr input_bufr));
extern int PDUmerge_dynamic_attribute_bufrs __PDU((MEMptr input_bufr));
extern int PDUadd_static_dyn_attributes __PDU((MEMptr *dyn_bufr, MEMptr *dyn_data, char *usageid, char *quantity, char *tagno, char *alttagno));
extern int PDUreformat_data_buffer __PDU((char *attr_name));
extern int PDUupdate_dynamics __PDU((void));

/* ./design/PDUexec.c */
extern int PDUinternal __PDU((void));
extern int PDUexternal __PDU((void));

/* ./design/PDUextern.c */
extern int PDUwork_controller __PDU((char *command_string));
extern int PDUext_get_children __PDU((void));
extern int PDUext_list_saved_views __PDU((char *catalog, char *partid, char *revision, MEMptr *view_buffer));
extern int PDUcopy __PDU((MEMptr file_bufr, int command, int type));
extern int PDUcopy_file __PDU((void));
extern int PDUlogout __PDU((void));
extern int PDUconnect __PDU((void));

/* ./design/PDUglobal.c */
extern int PDUnfs_toggle __PDU((void));
extern int PDUtree_toggle __PDU((void));

/* ./design/PDUmath.c */
extern int PDUfix_orientation __PDU((char **orient_string));
extern int PDUstring_to_point __PDU((char *input_string, struct PDUpoint *point));
extern int PDUdump_point __PDU((double point[3 ]));

/* ./design/PDUopt_form.c */
extern int design_options_notification_routine __PDU((int f_label, int g_label, double value, Form fp));
extern int design_options_form __PDU((void));
extern int PDUdesign_options_form __PDU((void));

/* ./design/PDUplpart.c */
extern int PDUconvert_dir_to_exp __PDU((void));

/* ./design/PDUrefresh.c */
extern int PDUalloc_refresh __PDU((void));
extern int PDUdealloc_refresh __PDU((void));
extern int PDUread_refresh __PDU((void));
extern int PDUwrite_refresh __PDU((void));
extern int PDUload_refresh __PDU((void));
extern int PDUunload_refresh __PDU((void));

/* ./design/PDUtools.c */
extern int PDUget_search_path __PDU((char *search_key, char *path_name));
extern int PDUunquote __PDU((char *input_string));
extern int PDUlstrcmp __PDU((char *string1, char *string2));
extern int PDUget_date __PDU((char *date));
extern int PDUsetlevels __PDU((int *level_mask));
extern int PDUset_debug __PDU((char *env_var, int on_off_flag));
extern int PDUstrcpy __PDU((char **variable, char *value));
extern int PDUdealloc __PDU((char **variable));
extern int PDUextract_dir_value __PDU((char *dir_path, char *dir_name, char **dir_value));
extern int PDUcheck_expression_value __PDU((char **value));
extern int PDUmodify_assy_entry __PDU((char *entry_name, char *old_dir_name, char *new_dir_name, char **modified_entry));
extern int PDUprocess_pulldown_list __PDU((char *name, MEMptr attr_buffer, MEMptr list_buffer));
extern int PDUfill_attribute_list __PDU((MEMptr attr_bufr, MEMptr data_bufr, MEMptr list_bufr));
extern int PDUvalidate_data_value __PDU((char *attr_text1, char *attr_value, MEMptr attr_buffer, MEMptr list_buffer));
extern int PDUcheck_file_permissions __PDU((void));
extern int PDUget_param_data __PDU((char *catalog));
extern int PDUcheck_for_function __PDU((char *attr_name, char **func_name, MEMptr func_buffer));
extern void PDUstrip_dir_entry __PDU((char *entry));
extern int convert_tolower __PDU((char *string, char *string1));

/* ./design/PDUtopdown.c */
extern int topdown_notification_routine __PDU((int f_label, int g_label, double value, Form fp));
extern int PDUtopdown_form __PDU((void));
extern int PDUcheck_topdown_files __PDU((void));
extern int PDUload_parts_list __PDU((void));

/* ./design/PDUvalid.c */
extern int PDUvalidate_quantity __PDU((char *quantity));
extern int PDUvalid_filename __PDU((char *filename));

/* ./design/PDUverify.c */
extern int PDUverify_login __PDU((void));
extern int PDUverify_command __PDU((int command));
extern int PDUverify_part __PDU((int verify_flag));
extern int PDUverify_file __PDU((char *part_os));
extern int PDUtopdown_terminate __PDU((void));

/* ./design/dsgn_global.c */

#undef __PDU
#if defined(__STDC__) || defined(__cplusplus)
# define __PDU(s) s
#else
# define __PDU(s) ()
#endif

#if defined(__STDC__) || defined(__cplusplus)
# define __PDU(s) s
#else
# define __PDU(s) ()
#endif

#if defined(__STDC__) || defined(__cplusplus)
# define __PDU(s) s
#else
# define __PDU(s) ()
#endif

#endif
