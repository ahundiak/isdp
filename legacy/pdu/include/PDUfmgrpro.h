
#if defined(__STDC__) || defined(__cplusplus)
# define __PDU(s) s
#else
# define __PDU(s) ()
#endif

#include "pwd.h"

/* ./filemgr/PDUbuffers.c */
extern void PDUsetup_single_buffer __PDU((MEMptr buffer));
extern int PDUbufr_to_form __PDU((Form form, int gadget, MEMptr *buffer));
extern void PDUbufr_to_form1 __PDU((Form form, int gadget, MEMptr *buffer));
extern int PDUbufr_to_form_fields __PDU((Form form, int gadget, MEMptr *buffer));
extern void PDUsetup_popup_list __PDU((char **headers, int count, int flag, MEMptr buffer));
extern void PDUsetup_form_fields __PDU((char **headers, int count, int flag, MEMptr buffer));
extern void PDUsetup_struct_fields __PDU((char **headers, int count, int flag, MEMptr buffer));
extern int PDUsetup_buffer __PDU((MEMptr buffer, int type, char ***data));
extern int PDUsetup_buffer_list __PDU((MEMptr buffer, int vert_bufr_no, int horz_bufr_no, char ***data_row, char ***data_col, char ***data_format, MEMptr *temp_bufr));
extern int PDUget_col_number __PDU((MEMptr bufr, char *col_name, char **data_col, int *col_num));
extern int PDUget_buffer_col __PDU((MEMptr bufr, char *col_name, int *col_num));
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
extern int PDUpull_existing_values __PDU((void));
extern int PDUsamecat_defaults __PDU((void));
extern int PDUcopy_buffer_format __PDU((MEMptr bufr1, MEMptr *bufr2));

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
extern int PDUcopy_attach __PDU((long p_seqno, char *catalog, char *part_num, char *revision, int attach_type, MEMptr *file_buffer));
extern int PDUdelete_local_file __PDU((char *catalog, char *partid, char *revision, int attach_type));
extern int PDUdelete_local_files __PDU((MEMptr file_bufr, int command, int type));
extern int PDUext_cancel_checkout __PDU((void));
extern int PDUcancel_checkout __PDU((void));
extern int PDUdelete_file __PDU((void));
extern int PDUremove_files_locally __PDU((MEMptr file_buffer));
extern int PDUremove_local_files_after_delete __PDU((MEMptr file_buffer));
extern int PDUdelete_cpio_files __PDU((char *path));

/* ./filemgr/PDUfile_list.c */
extern int file_list_notification_routine __PDU((int f_label, int g_label, double value, Form fp));
extern int PDUfile_list_form __PDU((void));
extern int PDUload_file_list __PDU((int type));

/* ./filemgr/PDUflag.c */
extern int PDUflag_part __PDU((int type));

/* ./filemgr/PDUlf_form.c */
extern int PDUsetup_env __PDU((void));
extern int local_files_notification_routine __PDU((int f_label, int g_label, double value, Form fp));
extern int PDUlocal_files_form __PDU((void));
extern int PDUload_local_files_form __PDU((void));
extern int PDUload_assembly_search_list __PDU((void));
extern int PDUdisable_local_files_gadgets __PDU((void));
extern int PDUenable_local_files_gadgets __PDU((void));
extern int PDUcheck_file_commands __PDU((void));
extern void PDUrefresh_local_files_form __PDU((void));
extern int PDUdismiss_subforms __PDU((void));
extern int PDUload_refresh_at_login __PDU((void));
extern int PDUload_refresh_from_parts_list __PDU((void));
extern int PDUload_refresh_from_structure_list __PDU((void));
extern int PDUcopy_structure_buffer_to_parts_buffer __PDU((MEMptr buffer));
extern int PDURetFromSelect __PDU((Form form));
extern int PDUupdate_define_assy_form_after_select __PDU((void));
extern int PDUupdate_topdown_form_after_select __PDU((void));
extern int PDUupdate_local_files_form_after_select __PDU((void));
extern int PDUvalidate_refresh_data __PDU((void));
extern int PDUblank_out_multiple_files __PDU((void));

/* ./filemgr/PDUlist_file.c */
extern int PDUlist_files __PDU((int type));

/* ./filemgr/PDUlogin.c */
extern int login_notification_routine __PDU((int f_label, int g_label, double value, Form fp));
extern int PDUlogin_form __PDU((void));
extern int PDUprocess_login __PDU((void));
extern int PDUdefault_env __PDU((Form fp));
extern char *PDUgetcwd __PDU((char *buf, int size));
extern char *get_remote_path __PDU((char *path, char **node));

/* ./filemgr/PDUmcf_list.c */
extern int mcf_list_notification_routine __PDU((int f_label, int g_label, double value, Form fp));
extern int PDUmcf_list_form __PDU((char title_str[80]));

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
extern int PDUcreate_file_buffer_from_list __PDU((int action, MEMptr *file_bufr));
extern int PDUupdate_local_column_for_refresh __PDU((int command, MEMptr file_bufr, MEMptr orig_bufr));
extern int PDUprint_refresh __PDU((void));
extern int PDUcreate_file_buffer_from_structure __PDU((int command, MEMptr *file_bufr));
extern int PDUcreate_delete_buffer __PDU((void));
extern int PDUextract_row_from_buffer __PDU((MEMptr *return_buffer, MEMptr in_bufr, int f_row));

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

/* ./filemgr/PDUstring.c */
extern int PDUsearch_string_to_arrays __PDU((char *string, MEMptr attr_list, char ***attrs, char ***expressions, int *entry));
extern int PDUsearch_arrays_to_form __PDU((char **attrs, char **exprs, Form form, int field, int no_attrs));
extern int PDUtrunc_string __PDU((char **string));
extern int PDUunquote_string __PDU((char **string));
extern int PDUcheck_column __PDU((char **string, int *column));
extern int PDUget_search_string __PDU((Form form, int field, MEMptr attr_bufr, char **search_string));
extern int PDUadd_quotes __PDU((char **string, char *attr, char *datatype));
extern void PDUget_display_attrs __PDU((MEMptr buffer, char **attr_list));
extern void PDUcheck_string_for_attribute __PDU((char **string, char *attr));
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
extern int PDUget_servers __PDU((MEMptr *server_bufr));
extern int PDUget_envs __PDU((MEMptr *env_bufr));

/* ./filemgr/fmgr_global.c */

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

