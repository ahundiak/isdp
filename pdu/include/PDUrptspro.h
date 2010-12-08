#ifndef PDU_PROTO_H
#define PDU_PROTO_H

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

/* ./reports/MRPdyn_gad.c */
extern void MRPdyn_text __PDU((int x_start_pos, int y_start_pos, int body_size, Form mrp_form_id, char *text_string, int glabel, char color));
extern void MRPdyn_rect __PDU((int x_lo_pos, int y_lo_pos, int x_hi_pos, int y_hi_pos, Form mrp_form_id, int glabel, char color));

/* ./reports/MRPforms_tls.c */
extern void MRPdyn_gadget_init __PDU((struct standard_st *dyn_std_var));

/* ./reports/MRPinit_var.c */
extern int MRPalloc_var __PDU((void));

/* ./reports/PDUblk_frm.c */
extern int blank_form_notification_routine __PDU((int f_label, int g_label, double value, Form fp));
extern int PDUblank_report_form __PDU((void));

/* ./reports/PDUbom_cnts.c */
extern int bom_contents_notification_routine __PDU((int f_label, int g_label, double value, Form fp));
extern int bom_contents_form __PDU((void));
extern int PDUbom_contents_form __PDU((void));
extern int PDUcheck_bom_mapping_commands __PDU((void));
extern int PDUadd_to_contents __PDU((char *attr_name, char *datatype, char *synonym, MEMptr *attr_bufr));
extern int PDUmap_attribute __PDU((char *bom_attribute, char *catalog, char *catalog_attribute));
extern int PDUmerge_cat_and_dyn_attr __PDU((MEMptr dyn_attr, MEMptr *attr_bufr));
extern int PDUload_attributes_for_mapping __PDU((MEMptr *attribute_buffer));

/* ./reports/PDUcrt_buff.c */
extern int PDUcreate_table_group_search_sort_buffers __PDU((MEMptr *tbl_bufr, MEMptr *grp_bufr, MEMptr *search_name_bufr, MEMptr *search_str_bufr, MEMptr *sort_name_bufr, MEMptr *sort_str_bufr));

/* ./reports/PDUdef_crit.c */
extern int PDUdefine_criteria_string __PDU((char *nfm_type, char *pdm_type, char *name, char *string, char *add_mod));

/* ./reports/PDUdef_rpt.c */
extern int PDUdefine_report_attributes __PDU((MEMptr *rpt_buffer));
extern int PDUdefine_report_format __PDU((void));
extern int PDUfinish_define_format __PDU((void));
extern int PDUimport_ris_report __PDU((char *template_file, int local_flag));

/* ./reports/PDUdef_sort.c */
extern int PDUsort_criteria_on_off __PDU((void));

/* ./reports/PDUdel_rpt.c */
extern int PDUdelete_report __PDU((void));

/* ./reports/PDUdsp_rpt.c */
extern int PDUdisplay_report __PDU((void));

/* ./reports/PDUget_strin.c */
extern int PDUget_criteria_string __PDU((char *nfm_type, char *pdm_type, char *name, char **string));

/* ./reports/PDUlist_rpts.c */
extern int PDUlist_reports __PDU((int type, char ***list, int *count));
extern int PDUlist_report_buffer __PDU((int type, MEMptr *output_bufr));

/* ./reports/PDUrpt_form.c */
extern int reports_notification_routine __PDU((int f_label, int g_label, double value, Form fp));
extern int reports_form __PDU((void));
extern int PDUreports_form __PDU((void));
extern int PDUsetup_report_struct __PDU((void));
extern int PDUcheck_output_filename __PDU((void));
extern int PDUcheck_reportname __PDU((char *templatetype));
extern int PDUget_templatetype __PDU((char *templatetype));
extern int PDUdelete_report_from_field __PDU((void));
extern int PDUupdate_report_form __PDU((void));
extern int PDUload_bom_list __PDU((void));
extern int PDUdelete_boms __PDU((void));
extern int PDUdisplay_local_report_file __PDU((char *filename));

/* ./reports/PDUrpt_tools.c */
extern int PDUload_PSUattr_struct __PDU((struct PSUattr **attr_struct, MEMptr attr_bufr, int *num_rows));
extern int PDUformat_report_buffers __PDU((MEMptr *options_bufr, MEMptr *list_bufr));
extern int PDUfrom_bufrs_to_structures __PDU((MEMptr options_buffer, MEMptr list_buffer));
extern int PDUfrom_struct_to_buffers __PDU((MEMptr *def_op, MEMptr *def_list));
extern int PDUformat_delete_report_bufr __PDU((MEMptr *buffer));
extern int PDUdelete_report_locally __PDU((void));
extern int PDUformat_bom_map_bufr __PDU((MEMptr *buffer));

/* ./reports/PDUsearch.c */
extern int PDUsearch_on_off __PDU((void));

/* ./reports/PDUsetup_def.c */
extern int PDUsetup_report_definition __PDU((int type, MEMptr *report_def, char *report_name, char *nfm_type, char *pdm_type, char *add_mod, char *table_name, char *grp_name, char *search_string, char *sort_string));

/* ./reports/PDUsort_name.c */
extern int PDUget_loc_sort_names __PDU((int *count, char ***sort_names, char *stat_msg));
extern int PDUget_cat_sort_names __PDU((int *count, char ***sort_names, char *stat_msg));

/* ./reports/PDUsrchname.c */
extern int PDUget_cat_search_names __PDU((int *count, char ***search_names, char *stat_msg));
extern int PDUget_loc_search_names __PDU((int *count, char ***search_names, char *stat_msg));
extern int PDUget_search_criteria_names __PDU((int *count, char ***search_crit_names, char *stat_msg));

/* ./reports/PSUattr_list.c */
extern void attrl_notify_routine __PDU((int f_label, int g_label, double value, Form fp));
extern int PSUattrl_load_cre_init_dp __PDU((void));

/* ./reports/PSUcom_tls.c */
extern int rMRPfree_pdurpt __PDU((struct PSUrpt **pdurpt));
extern int rMRPfree_psurpt __PDU((void));
extern int rMRPfree_psuattr __PDU((int total));
extern int MRPstrcpy __PDU((char **variable, char *value));
extern int MRPstrcpy2 __PDU((char **variable, char *value));
extern int MRPdealloc __PDU((char **variable));
extern int PSUfree_list __PDU((char **data_list, int number_of_rows, int number_of_cols));

/* ./reports/PSUformat.c */
extern int MRPdelete_form __PDU((Form cur_form_id));
extern int MRPGet_form_text __PDU((Form fp, int g_label, char **text, int *text_size));
extern int pformat_notify_routine __PDU((int f_label, int g_label, double value, Form fp));
extern int PSUload_list_format __PDU((int command, struct PSUattr *attr, int attr_total));
extern int PSUfind_attr __PDU((char *text));
extern int PSUdelete_attr_from_pulldown __PDU((void));
extern int PSUadd_attr_to_pulldown __PDU((short recreate_pulldown));

/* ./reports/PSUtools.c */
extern int MRPcalc_width __PDU((char *datatype, int *width));
extern int MRPmatch_attr_row __PDU((int attr_total));
extern int MRPmatch_attr_rpt_row __PDU((int attr_total));
extern int MRPcheck_position __PDU((int g_label, int *y_pos, Form fp, int attr_total));
extern int PSUplace_attr_fmt __PDU((int attr_total));
extern int PSUget_datestamp __PDU((char *datetime));
extern int MRPget_time __PDU((char *times));
extern int MRPget_date __PDU((char *date));
extern long PSUdisplay_rpt __PDU((char *filename));
extern int rMRPget_fsize __PDU((long *size, char *filename));
extern int rMRPfree_lev_val_struct __PDU((int total));
extern int rMRPfree_index_slot __PDU((int total));
extern int rMRPfree_struct_list __PDU((int total));

/* ./reports/display_rpt.c */
extern int PDUdba_display_report __PDU((char *output));
extern int PDUdba_list_output __PDU((int option, char *filename));
extern int PDUdba_add_output __PDU((int option));
extern int PDUdba_notify __PDU((int form_label, int label, double value, Form fpt));
extern int PDUdba_text_size_form __PDU((int option, Form fpt));
extern int PDUdba_set_text_size __PDU((Form fpt, int text_num));
extern char *PDUdba_get_msg __PDU((int msgnum, char *msgfmt, int maxlng, void *ptr1, void *ptr2));
extern int PDUdba_print_msg __PDU((char *message));

/* ./reports/rMRPinit_var.c */
extern int rMRPalloc_var __PDU((void));
extern int PDUalloc_rpt __PDU((struct PSUrpt **pdurpt));
extern int PSUalloc_rpt __PDU((void));

/* ./reports/rMRPmessage.c */
extern int MRPinterpret_message __PDU((int msgNum, char *var1, char *var2, char *var3));

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
