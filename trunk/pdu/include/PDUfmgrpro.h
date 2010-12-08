#ifndef PDU_FMGR_PRO_H
#define PDU_FMGR_PRO_H

#include "FI.h"
#include "MEMstruct.h"

#if defined(__STDC__) || defined(__cplusplus)
#ifndef __PDU
#define __PDU(args) args
#endif
#else
#ifndef __PDU
#define __PDU(args) ()
#endif
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./filemgr/PDUbuffers.c */
extern void PDUsetup_single_buffer __PDU((MEMptr buffer));
extern int  PDUbufr_to_form        __PDU((Form form, int gadget, MEMptr *buffer));
extern int  PDUbufr_to_form_single __PDU((Form form, int gadget, MEMptr *buffer));
/*kcmk 2apr97*/
extern int PDUmerge_bufrs_to_form_single __PDU(( Form form, int gadget, MEMptr *buffer ));
extern void PDUbufr_to_form1 __PDU((Form form, int gadget, MEMptr *buffer));
extern int PDUbufr_to_form_fields __PDU((Form form, int gadget, MEMptr *buffer));
extern void PDUsetup_popup_list __PDU((char **headers, int count, int flag, MEMptr buffer));
extern void PDUsetup_form_fields __PDU((char **headers, int count, int flag, MEMptr buffer));
extern void PDUsetup_struct_fields __PDU((char **headers, int count, int flag, MEMptr buffer));
extern void PDUbufr_to_mcf __PDU((MEMptr buffer, Form form, int field));
extern int PDUadd_catalog_to_buffer __PDU((char *search_catalog, MEMptr *buffer));

/* ./filemgr/PDUbufrs.c */
extern int PDUinit_stack __PDU((int **stack, int stack_size));
extern int PDUpush_into_stack __PDU((int **stack, int stack_size, int row_id));
extern int PDUget_top_of_stack __PDU((int *stack, int *top));
extern int PDUdelete_from_stack __PDU((int **stack, int stack_size, int row_id));
extern int PDUprint_stack __PDU((int *stack, int stack_size));
extern int PDUpull_from_bufr __PDU((void));
extern int PDUlist_dmgn_bufr __PDU((MEMptr *buffer));
extern int PDUlist_pgn_bufr __PDU((MEMptr *buffer));
extern int PDUlist_pan_bufr __PDU((MEMptr *buffer));
extern int PDUlist_pag_bufr __PDU((MEMptr *buffer));
extern int PDUlist_gn_bufr __PDU((MEMptr *buffer));
extern int PDUlist_an_bufr __PDU((MEMptr *buffer));
extern int PDUlist_ag_bufr __PDU((MEMptr *buffer));
extern int PDUremove_data __PDU((Form fp, int field_label, int max_rows, int num_cols));
extern int PDUremove_col_data __PDU((Form fp, int field_label, int max_rows, int col));
extern int PDUpull_when_diff __PDU((void));
extern int PDUpull_diff_values __PDU((void));
extern int PDUsamecat_defaults __PDU((void));
extern int PDUcopy_buffer_format __PDU((MEMptr bufr1, MEMptr *bufr2));
extern int PDUcheck_file_info_privileges __PDU((MEMptr file_bufr, MEMptr attr_bufr, short *filedesc_update, short *filedesc_read, short *filedesc_write, short *cofile_update, short *cofile_read, short *cofile_write, short *cifile_update, short *cifile_read, short *cifile_write, short *filetype_update, short *filetype_read, short *filetype_write));

/* ./filemgr/PDUcancl_lst.c */
extern int cancel_list_notification_routine __PDU((int f_label, int g_label, double value, Form fp));
extern int PDUcancel_list_form __PDU((void));

/* ./filemgr/PDUcheckin.c */
extern int PDUext_checkin __PDU((void));
extern int PDUcheckin __PDU((void));
extern int PDUupdate_list_after_deactchkin __PDU((Form form, int field));

/* ./filemgr/PDUcheckout.c */
extern int PDUext_checkout __PDU((void));
extern int PDUcheckout __PDU((void));
extern int PDUupdate_form_after_checkin_out __PDU((int type));
extern int PDUupdate_checked_out_parts __PDU((void));

/* ./filemgr/PDUckin_tls.c */
extern int PDUverify_files_exist_locally __PDU((char *cpr_catalogname, char *cpr_itemname, char *cpr_itemrev, MEMptr *filenames));

/* ./filemgr/PDUdate.c */
extern int PDUascii_to_timestamp __PDU((char *in_str, char *out_str));
extern int Ethnic_to_timestamp __PDU((char *token1, char *token2, char *token3, char *time_str, char *out_str));
extern int PDUget_RISdate __PDU((char *ret_date));
extern int PDUvalidate_American __PDU((char *date, char *token1, char *token2, char *token3));
extern int TIMEdebug __PDU((char s[300 ]));
extern int _TIMEdebug __PDU((double enter, double exit, char *fn));
extern double system_time __PDU((void));
extern long call_time __PDU((void));

/* ./filemgr/PDUfile.c */
extern int PDUdelete_local_files __PDU((MEMptr file_bufr, int command, int type));
extern int PDUext_cancel_checkout __PDU((void));
extern int PDUcancel_checkout __PDU((void));
extern int PDUdelete_file __PDU((void));
extern int PDUremove_files_locally __PDU((MEMptr file_buffer));
extern int PDUremove_local_files_after_delete __PDU((MEMptr file_buffer));
extern int PDUdelete_cpio_files __PDU((char *path));
extern int PDUchange_to_read_only __PDU((MEMptr part_files));
extern int PDUcopy_attach __PDU((long p_seqno, char *catalog, char *part_num, char *revision, int attach_type, MEMptr *file_buffer));
extern int PDUcheck_if_file_attached __PDU((char *filename, short *attached, MEMptr *ret_bufr));
extern int PDUcopy_files_for_refresh_part __PDU((void));

/* ./filemgr/PDUfile_list.c */
extern int file_list_notification_routine __PDU((int f_label, int g_label, double value, Form fp));
extern int PDUfile_list_form __PDU((void));
extern int PDUload_file_list __PDU((int type));

/* ./filemgr/PDUfileapi.c */
extern int PDUget_envs __PDU((MEMptr *env_bufr));
extern int PDUget_ris_path __PDU((char ris_path[80 ]));
extern int PDUget_buffer_col __PDU((MEMptr bufr, char *col_name, int *col_num));
extern int PDUsetup_buffer __PDU((MEMptr buffer, int type, char ***data));
extern int PDUsetup_buffer_list __PDU((MEMptr buffer, int vert_bufr_no, int horz_bufr_no, char ***data_row, char ***data_col, char ***data_format, MEMptr *temp_bufr));
extern int PDUget_col_number __PDU((MEMptr bufr, char *col_name, char **data_col, int *col_num));
extern int PDUmake_transition __PDU((char *to_state));
extern int PDUverify_add_file_list __PDU((char *cpr_catalog, char *cpr_partnum, char *cpr_revision, char *cpr_stg_name, struct file_info *spr_file_list));
extern int PDUverify_attr_list __PDU((struct attribute_info *attr_list, MEMptr attr_bufr, MEMptr list_bufr, MEMptr *data_bufr, short mode));
extern int PDUverify_PDUattr_list __PDU((struct PDUattribute_info *attr_list, MEMptr attr_bufr, MEMptr list_bufr, MEMptr *data_bufr, short mode));
extern int PDUprint_file_list __PDU((struct file_info *file_list));
extern int PDUprint_change_list __PDU((struct chg_file_info *file_list));
extern int PDUadd_files_to_buffer __PDU((MEMptr *file_bufr, struct file_info *add_list, char *saname));
extern int PDUchange_files_in_buffer __PDU((MEMptr *file_bufr, struct chg_file_info *chg_list));
extern int PDUmark_files_for_delete __PDU((MEMptr *file_bufr, struct file_info *delete_list));
extern int PDUverify_change_file_list __PDU((char *cpr_catalog, char *cpr_partnum, char *cpr_revision, char *cpr_stg_name, struct chg_file_info *spr_files));
extern void PDUcleanup_change_part __PDU((char *cpr_catalog, char *cpr_partnum, char *cpr_revision, MEMptr attr_bufr, MEMptr data_bufr, MEMptr file_bufr, MEMptr add_bufr, MEMptr acl_bufr, MEMptr stg_bufr));
extern int PDUprint_PDUattr_list __PDU((struct PDUattribute_info *list));
extern int PDUget_all_catalogs __PDU((MEMptr *cat_bufr));
extern int PDUbackup_refresh_data __PDU((void));
extern int PDUrestore_refresh_data __PDU((void));

/* ./filemgr/PDUflag.c */
extern int PDUflag_part __PDU((int type));

/* ./filemgr/PDUflag_form.c */
extern int flag_notification_routine __PDU((int f_label, int g_label, double value, Form fp));
extern int PDUflag_form __PDU((void));

/* ./filemgr/PDUgen_valid.c */
extern int PDUvalidate_project __PDU((char *project, char *catalog));
extern int PDUvalidate_catalog __PDU((char *project, char *catalog, short buffer));
extern int PDUcheck_part_syntax __PDU((char *partnum));
extern int PDUcheck_rev_syntax __PDU((char *rev));
extern int PDUcheck_part_datatype __PDU((char *partnum, MEMptr attr_bufr));
extern int PDUcheck_rev_datatype __PDU((char *rev, MEMptr attr_bufr));
extern int PDUcheck_desc_datatype __PDU((char *desc, MEMptr attr_bufr));
extern int PDUvalidate_parttype __PDU((char *catalog, char *parttype));
extern int PDUverify_file_desc __PDU((char *file_desc));
extern int PDUverify_addpart_filename __PDU((char *filename));
extern int PDUverify_filetype __PDU((char *filetype));
extern int PDUverify_aclname __PDU((char *aclname, char aclno[5 ], MEMptr acl_bufr));
extern int PDUverify_storage_name __PDU((char *stgname, char stgno[5 ], MEMptr stg_bufr));
extern void PDUunlock_item __PDU((char *catalog, char *part, char *revision));
extern int PDUget_storage_name __PDU((char **stgname, char stgno[5 ], MEMptr stg_bufr, MEMptr data_bufr));
extern int PDUget_acl_name __PDU((char **aclname, char aclno[5 ], MEMptr acl_bufr));

/* ./filemgr/PDUlf_form.c */
extern int PDUsetup_env __PDU((void));
extern int local_files_notification_routine __PDU((int f_label, int g_label, double value, Form fp));
extern int PDUlocal_files_form __PDU((void));
extern int PDUload_local_files_form __PDU((void));
extern int PDUdisable_local_files_gadgets __PDU((void));
extern int PDUenable_local_files_gadgets __PDU((void));
extern int PDUcheck_file_commands __PDU((void));
extern void PDUrefresh_local_files_form __PDU((void));
extern int PDUdismiss_subforms __PDU((void));
extern int PDUload_refresh_at_login __PDU((void));
extern int PDUload_refresh_from_parts_list __PDU((void));
extern int PDUcopy_structure_buffer_to_parts_buffer __PDU((MEMptr buffer));
extern int PDURetFromSelect __PDU((Form form));
extern int PDUupdate_topdown_form_after_select __PDU((void));
extern int PDUupdate_local_files_form_after_select __PDU((void));
extern int PDUvalidate_refresh_data __PDU((void));
extern int PDUblank_out_multiple_files __PDU((void));
extern int PDUcount_selected_parts __PDU((void));
extern int PDUpaint_form __PDU((Form form));
extern void PDUclear_mcf __PDU((void));
extern int PDUcheck_part_data_for_utilities __PDU((void));
extern void PDUreset_local_files_form __PDU((void));
extern void PDUset_edit_assy_toggle_after_select __PDU((void));

/* ./filemgr/PDUlist_file.c */
extern int PDUlist_files __PDU((int type));

/* ./filemgr/PDUlogin.c */
extern int login_notification_routine __PDU((int f_label, int g_label, double value, Form fp));
extern int PDUlogin_form __PDU((void));
extern int PDUprocess_login __PDU((void));
extern int PDUdefault_env __PDU((Form fp));
extern char *get_remote_path __PDU((char *path, char **node));
extern int PDUautomatic_login __PDU((short flag));

/* ./filemgr/PDUmcf_list.c */
extern int mcf_list_notification_routine __PDU((int f_label, int g_label, double value, Form fp));
extern int PDUmcf_list_form __PDU((char title_str[80 ]));

/* ./filemgr/PDUmisc2.c */
extern void PDUfree_string __PDU((char **string));
extern int PDUfree_string_array __PDU((char ***string_array, int size));

/* ./filemgr/PDUmodes.c */
extern void PDUnew_mode __PDU((void));
extern void PDUsimilar_mode __PDU((void));
extern void PDUchange_mode __PDU((void));
extern void PDUreview_mode __PDU((void));

/* ./filemgr/PDUp_login.c */
extern int PDUcheck_part __PDU((char *command, int type));
extern int PDUcreate_file_buffer __PDU((int command, MEMptr *file_bufr));
extern int PDUupdate_local_column __PDU((int command, MEMptr file_bufr, MEMptr orig_bufr));
extern int PDUcreate_file_buffer_from_refresh __PDU((int action, MEMptr *file_bufr));
extern int PDUupdate_local_column_for_refresh __PDU((int command, MEMptr file_bufr, MEMptr orig_bufr));
extern int PDUprint_refresh __PDU((void));
extern int PDUcreate_delete_buffer __PDU((void));
extern int PDUextract_row_from_buffer __PDU((MEMptr *return_buffer, MEMptr in_bufr, int f_row));
extern int PDUcheckout_structure __PDU((char *command, int type));

/* ./filemgr/PDUpart_lst.c */
extern int parts_list_notification_routine __PDU((int f_label, int g_label, double value, Form fp));
extern int PDUparts_list_form __PDU((void));

/* ./filemgr/PDUpt_fl_lst.c */
extern int part_file_list_notification_routine __PDU((int f_label, int g_label, double value, Form fp));
extern int PDUpart_file_list_form __PDU((void));
extern int PDUload_file_buffer __PDU((char *catalog, char *partid, char *revision, char *description, char *filename));
extern int PDUload_file_buffer_after_copy __PDU((MEMptr file_buffer, int load_buffer, int row, char *catalog, char *partid, char *revision, char *filename));

/* ./filemgr/PDUsgl_list.c */
extern int single_list_notification_routine __PDU((int f_label, int g_label, double value, Form fp));
extern int PDUsingle_list_form __PDU((void));

/* ./filemgr/PDUsort.c */
extern int PDUdisplay_part_sort_conditions __PDU((void));

/* ./filemgr/PDUsort_form.c */
extern int sort_notification_routine __PDU((int f_label, int g_label, double value, Form fp));
extern int PDUsort_form __PDU((int NumAttribs, char **AttrList, char **AttrSynonym));

/* ./filemgr/PDUsort_opt.c */
extern int sort_options_notification_routine __PDU((int f_label, int g_label, double value, Form fp));
extern int PDUsort_options_form __PDU((void));
extern int PDUreset_part_sort_fields __PDU((void));

/* ./filemgr/PDUstate_frm.c */
extern int state_notification_routine __PDU((int f_label, int g_label, double value, Form fp));
extern int PDUstate_form __PDU((void));
extern void PDUselect_row_in_list_mcf __PDU((char *cat, char *part, char *rev, int row_select));
extern int PDUmulti_move_state __PDU((char *to_state));
extern int PDUprocess_state_form_parts __PDU((void));
extern int PDUadd_node_to_acl_list __PDU((char catalog[21 ], char partid[41 ], char revision[41 ], char description[256 ], char filename[15 ], char parttype[5 ], char aclname[21 ], char state[41 ], char workflow[21 ], struct PDUacl_node **node));
extern int PDUprint_acl_list __PDU((struct PDUacl_node *node));
extern int PDUgroup_parts_for_transition __PDU((void));
extern int PDUdelete_node_from_acl_list __PDU((char *catalog, char *partid, char *revision, struct PDUacl_node **acl_list));
extern int PDUprocess_individual_state_form_part __PDU((char *catalog, char *partid, char *revision, char *description, char *filename, char *parttype));
extern int PDUload_move_state_form __PDU((void));
extern int PDUupdate_state_form_after_move_state __PDU((void));
extern int PDUremove_node_from_group_list __PDU((char *catalog, char *partid, char *revision));
extern int PDUdelete_current_state_from_states_buffer __PDU((MEMptr states_bufr, MEMptr *temp_buffer));
extern int PDUload_acl_parts_mcf __PDU((struct PDUacl_node *parts_list));
extern int PDUfree_acl_structure __PDU((struct PDUacl_node **acl_list));

/* ./filemgr/PDUstring.c */
extern int PDUsearch_string_to_arrays __PDU((char *string, MEMptr attr_list, char ***attrs, char ***expressions, int *entry));
extern int PDUsearch_arrays_to_form __PDU((char **attrs, char **exprs, Form form, int field, int no_attrs));
extern int PDUtrunc_string __PDU((char **string));
extern int PDUunquote_string __PDU((char **string));
extern int PDUcheck_column __PDU((char **string, int *column));
extern int PDUget_search_string __PDU((Form form, int field, MEMptr attr_bufr, char **search_string));
extern int PDUadd_quotes __PDU((char **string, char *attr, char *datatype));
extern void PDUget_display_attrs __PDU((MEMptr buffer, char **attr_list));
extern void PDUadd_tablename __PDU((char **string, char *catalog));
extern int PDUcheck_search_string_syntax __PDU((char *string));
extern void PDUadd_tablename_to_sort_string __PDU((char **string, char *catalog));
extern int PDUtic_it __PDU((char **string));
extern void PDUlike_search_string __PDU((char **string));
extern int PDUfind_server_in_string __PDU((char *string, char ***servers, int *no_servers));
extern int PDUfind_env_in_string __PDU((char *string, char ***envs, int *no_envs));
extern int PDUvalidate_criteria __PDU((Form form, char *string));
extern int PDUtrunc_usageid __PDU((char **string));

/* ./filemgr/PDUsv_refrsh.c */
extern int PDUdefine_refresh __PDU((void));
extern int PDUget_refresh __PDU((void));
extern int PDUwrite_refresh_file __PDU((char *field, FILE *outfile));
extern int PDUread_refresh_file __PDU((char **field, char *path, FILE *infile));
extern char *myfgets __PDU((char *s, int n, FILE *stream));
extern int PDUget_login_form_data __PDU((void));

/* ./filemgr/PDUvalidate.c */
extern int PDUvalid_project __PDU((char *project, char *catalog));
extern int PDUvalid_catalog __PDU((char *project, char *catalog));
extern int PDUvalid_partnum __PDU((char *catalog, char *partnum));
extern int PDUvalid_rev __PDU((char *rev));
extern int PDUvalid_desc __PDU((char *desc));
extern int PDUcheck_partnum __PDU((char *catalog, char *partnum, char *revision));
extern int PDUget_part_from_desc __PDU((char *catalog, char *description));

/* ./filemgr/PDUwher_used.c */
extern int where_used_notification_routine __PDU((int f_label, int g_label, double value, Form fp));
extern int PDUwhere_used_form __PDU((void));

/* ./filemgr/PDUwrkst_mgr.c */
extern int PDUprocess_wrkst_info __PDU((void));

#if defined(__cplusplus)
}
#endif

#if defined(__STDC__) || defined(__cplusplus)
#ifndef __PDU
#define __PDU(args) args
#endif
#else
#ifndef __PDU
#define __PDU(args) ()
#endif
#endif

#if defined(__STDC__) || defined(__cplusplus)
#ifndef __PDU
#define __PDU(args) args
#endif
#else
#ifndef __PDU
#define __PDU(args) ()
#endif
#endif

#if defined(__STDC__) || defined(__cplusplus)
#ifndef __PDU
#define __PDU(args) args
#endif
#else
#ifndef __PDU
#define __PDU(args) ()
#endif
#endif

#if defined(__STDC__) || defined(__cplusplus)
#ifndef __PDU
#define __PDU(args) args
#endif
#else
#ifndef __PDU
#define __PDU(args) ()
#endif
#endif

#if defined(__STDC__) || defined(__cplusplus)
#ifndef __PDU
#define __PDU(args) args
#endif
#else
#ifndef __PDU
#define __PDU(args) ()
#endif
#endif

#endif
