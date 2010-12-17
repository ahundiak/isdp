#ifndef PDM_PROTO_H
#define PDM_PROTO_H

#if defined(__STDC__) || defined(__cplusplus)
#ifndef __PDM
#define __PDM(args) args
#endif
#else
#ifndef __PDM
#define __PDM(args) ()
#endif
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./pdms/PDMattr.c */
extern int PDMsget_table_attributes __PDM((MEMptr *attribute_buffer, MEMptr *data_buffer, MEMptr *list_buffers));
extern int PDMsget_table_data __PDM((MEMptr *attribute_buffer, MEMptr *data_buffer, MEMptr *list_buffers));
extern int PDMget_table_template __PDM((PDMexec_ptr PDMexec));
extern int PDMquery_template_information __PDM((PDMexec_ptr PDMexec));
extern int PDMsquery_table_definition __PDM((MEMptr *attribute_buffer));
extern int PDMquery_dynamic_attributes __PDM((MEMptr *attribute_buffer, MEMptr *data_buffer, MEMptr *list_buffer, MEMptr *assm_bufr));
extern int PDMget_pdcattr_buffer __PDM((char *pdc_tbl, MEMptr *attr_bufr));
extern int PDMvalidate_attribute __PDM((char *attribute_name, int table_no));
extern int PDMfast_query_table_def __PDM((MEMptr *attribute_buffer));
extern int PDMcreate_application __PDM((MEMptr *application));
extern int PDMcreate_application_PDM0 __PDM((MEMptr *application));
extern int PDMcreate_application1 __PDM((MEMptr *application));
extern int PDMcreate_application2 __PDM((MEMptr *application));
extern int PDMquery_dr_template_information __PDM((PDMexec_ptr PDMexec));
extern int PDMquery_dr_table_definition __PDM((PDMexec_ptr PDMexec));
extern int PDMquery_dynamic_table_information __PDM((MEMptr *attribute_buffer, MEMptr *data_buffer, MEMptr *list_buffers));
extern int PDMsget_table_data1 __PDM((MEMptr *return_buffer));

/* ./pdms/PDMattr_func.c */
extern long PDMmap_attribute_functions __PDM((char *n_catalogname, char *working_area, MEMptr functions));
extern long PDMcopy_catalog_functions __PDM((char *template_cat, char *target_cat));
extern long PDMmove_functions __PDM((char *n_catalogname, char *working_area, MEMptr *functions));

/* ./pdms/PDMcat_attr.c */
extern int PDMqry_catalog_attributes __PDM((char *mode, MEMptr *return_bufr));
extern int PDMi_qry_catalog_attributes __PDM((char *mode, MEMptr *attr_bufr, MEMptr *data_bufr, MEMptr *list_bufr));
extern int PDMquery_catalog_writable_attributes __PDM((MEMptr *attr_bufr, MEMptr *data_bufr, MEMptr *list_bufr));
extern int PDMquery_catalog_readable_attributes __PDM((MEMptr *attr_bufr, MEMptr *data_bufr, MEMptr *list_bufr));
extern int PDMquery_catalog_updatable_attributes __PDM((MEMptr *attr_bufr, MEMptr *data_bufr, MEMptr *list_bufr));
extern int _PDMload_values_in_data_bufr __PDM((MEMptr attr_bufr, MEMptr *data_bufr));
extern int PDMOLDqry_catalog_attributes __PDM((char *mode, MEMptr *return_bufr));
extern int _PDMload_default_vals_in_data_bufr __PDM((MEMptr val_bufr, MEMptr *def_bufr));

/* ./pdms/PDMcat_class.c */
extern int PDMquery_classification __PDM((MEMptr input_buffer, MEMptr *output_class));
extern int PDMget_class_of_cat __PDM((char *catalog_name, MEMptr *class_path));
extern int PDMget_pdmloc_levels __PDM((int level, char **loc_str));
extern int PDMget_usageid_cat __PDM((char *catalog_name, char **usage_id));
extern long PDMtemplate_catalog_attributes __PDM((char *catalog_name, MEMptr *attr_list, MEMptr *data_list, MEMptr *value_list));
extern int PDMstore_classification __PDM((MEMptr class_path));

/* ./pdms/PDMcatalog.c */
extern int PDMcreate_catalog __PDM((MEMptr loc_attr, MEMptr loc_data, MEMptr catalog_buffer, MEMptr catalog_data, MEMptr catalog_lists, char *dyn_table, MEMptr dynamic_attr, MEMptr dynamic_data, MEMptr dynamic_list));
extern int PDMi_create_catalog __PDM((long user_id, char auto_file[2 ], MEMptr loc_attr, MEMptr loc_data, MEMptr catalog_buffer, MEMptr catalog_data, MEMptr catalog_lists, MEMptr dynamic_attr, MEMptr dynamic_data, MEMptr dynamic_list, char *dyn_table));
extern int PDMmodify_catalog __PDM((MEMptr loc_attr, MEMptr loc_data, MEMptr catalog_buffer, MEMptr catalog_data, MEMptr catalog_lists, char *dyn_table, MEMptr dynamic_attr, MEMptr dynamic_data, MEMptr dynamic_list));
extern int PDMcreate_dynamic_table __PDM((long user_id, char *pdc_tbl, MEMptr dynamic_attr, MEMptr dynamic_data, MEMptr dynamic_list));
extern long PDMcreate_data_buffer __PDM((MEMptr attr_buffer, MEMptr *data_buffer));
extern int PDMdelete_catalog __PDM((void));
extern int PDMparse_for_illegal_char __PDM((char *string));
extern long PDMdyntable_for_catalog __PDM((char **dyn_table));

/* ./pdms/PDMdebug.c */
extern int PDMdebug_on_off __PDM((PDMexec_ptr PDMexec));
extern int PDMdebug __PDM((char s[300 ]));
extern int _PDMdebug __PDM((int va_alist));

/* ./pdms/PDMflag.c */
extern int PDMsflag_part_archive __PDM((void));
extern int PDMsflag_part_backup __PDM((void));
extern int PDMsflag_part_delete __PDM((void));
extern int PDMsflag_part_restore __PDM((void));
extern int PDMsUnflag_part_archive __PDM((void));
extern int PDMsUnflag_part_delete __PDM((void));
extern int PDMsUnflag_part_restore __PDM((void));
extern int PDMsUnflag_part_backup __PDM((void));

/* ./pdms/PDMgr_asly.c */
extern int PDMsdefine_assembly_structure __PDM((MEMptr assembly));
extern int PDMi_check_level __PDM((MEMptr bufr));
extern int PDMdron_setindicator __PDM((int n_pcatalogno, int n_pitemno));
extern int PDMload_parentnos __PDM((int catno, int partno, MEMptr bufr));
extern int PDMwrite_2_cols __PDM((MEMptr bufr, int row, int col1, int col2, char *val1, char *val2));
extern int PDMload_citnos __PDM((long user_id, MEMptr bufr));
extern int PDMload_set_members __PDM((long user_id, MEMptr bufr));
extern int PDMcheck_cycles __PDM((MEMptr bufr));

/* ./pdms/PDMloc_part.c */
extern int PDMlist_of_parts __PDM((MEMptr names_bufr, MEMptr *attr_list));
extern int PDMi_list_of_parts __PDM((int sano, MEMptr out_buffer_list, MEMptr *attr_list));
extern int PDMsearch_for_parts_in_project __PDM((MEMptr names_bufr, MEMptr *temp_bufr));
extern int PDMsearch_for_parts_in_project2 __PDM((MEMptr names_bufr, MEMptr *temp_bufr));
extern int PDMsearch_for_parts_in_catalog __PDM((MEMptr names_bufr, MEMptr *attr_list));
extern int PDMexpand_parts_list __PDM((MEMptr names_bufr, MEMptr nos_bufr, MEMptr *attr_list));

/* ./pdms/PDMmisc.c */
extern int PDMcopy_data_buffer __PDM((MEMptr bufr1, MEMptr *bufr2));

/* ./pdms/PDMnet.c */
extern int PDMverify_init __PDM((void));
extern int PDMterminate __PDM((void));

/* ./pdms/PDMnlogin.c */
extern int PDMlogin __PDM((long *user_id));

/* ./pdms/PDMpart.c */
extern int PDMadd_part __PDM((MEMptr attr_list, MEMptr data_list, MEMptr filelist_list));
extern int PDMdelete_part __PDM((void));
extern int PDMscancel_modify_part __PDM((MEMptr attr_list, MEMptr data_list));
extern int PDMsadd_part_to_project __PDM((MEMptr attr_list, MEMptr data_list));
extern int PDMscheck_delete_part __PDM((void));
extern int PDMload_state_name __PDM((MEMptr data_buffer));

/* ./pdms/PDMpartstr.c */
extern int PDMget_children_attachments __PDM((long user_id, char *n_catalogname, char *n_itemname, char *n_itemrev, MEMptr *return_buffer));
extern int PDMmake_file_list __PDM((char *n_catalogname, char *n_itemname, char *n_itemrev, MEMptr *return_buffer));
extern int PDMmake_attach_bufr __PDM((char *n_catalogname, char *n_itemname, char *n_itemrev, MEMptr *attach_buffer));
extern int PDMget_attach_count __PDM((int p_type, char *n_catalogname, char *n_itemname, char *n_itemrev, char *c_catalogname, char *c_partnum, char *c_revision, int p_level, int *attach_count));
extern int PDMsshow_saved_views __PDM((MEMptr *temp_bufr));
extern int PDMget_saved_views __PDM((MEMptr *temp_bufr));
extern int PDMmodify_assembly __PDM((MEMptr assembly, MEMptr *attach_bufr));
extern int PDMcheck_cofilename __PDM((char *filename));
extern int PDMcheck_fmgr __PDM((int n_itemname, int p_sano));
extern int PDMcheck_link_unlink __PDM((int catalog_no, int partno, int n_sano, int *link_status));

/* ./pdms/PDMquery_cat.c */
extern long PDMquery_catalog_attributes __PDM((char *cat_name, MEMptr *attr_list, MEMptr *data_list, MEMptr *value_list));
extern long PDMget_user_name __PDM((long user_id, long user_no, char *user_name));

/* ./pdms/PDMs_rtns.c */
extern int PDMdelete_set_members __PDM((long user_id, char *catalog, char *n_itemname, char *n_itemrev));
extern int PDMupdate_set_members __PDM((long user_id, char *catalog, char *n_itemname, char *n_itemrev, MEMptr child_bufr, MEMptr *old_set, MEMptr *new_set, MEMptr *citno, int p_catno, int p_itemno));
extern int PDMinsert_views __PDM((char *pdmsv_table, int p_partno, MEMptr sv_bufr));
extern int PDMinsert_citinfo __PDM((MEMptr old_set, MEMptr set_data, MEMptr child_bufr, MEMptr parm_buffer, MEMptr data_buffers));
extern int PDMset_attachments __PDM((MEMptr attach_bufr, MEMptr set_bufr));
extern int PDMupdate_bom __PDM((char *active_bom, MEMptr child_bufr));
extern int PDMcheckout_bom_parts __PDM((long user_id, char *bom, MEMptr strg_bufr));
extern int PDMupdate_citnos __PDM((MEMptr old_set, MEMptr new_set));
extern int PDMprocess_cit_atchmts __PDM((MEMptr data_bufr, int parent_row, int parent_row_offset));
extern int PDMprocess_bom_attach __PDM((MEMptr data_bufr, char *review_bom, int parent_row, int parent_row_offset));
extern int PDMold_delete_pdm_entries __PDM((MEMptr set_data));
extern int PDMdelete_pdm_entries __PDM((int n_pcatalogno, int n_pitemno));
extern int PDMcheck_dup_sa_fname __PDM((char *filename, char *strg_name));
extern int PDMXcheck_dup_sa_fname __PDM((char *filename, char *strg_name));
extern long PDMadd_child __PDM((long user_id, MEMptr cit_attr, MEMptr data_list, long cat_no, long item_no, long row_no));
extern long PDMadd_child_to_assem __PDM((long user_id, MEMptr attr_list, MEMptr data_list));
extern int PDMquery_catalogno_type __PDM((char *catalog, int *catno, char *type));
extern long PDMsetup_assembly_buffer __PDM((long user_id, char *cat_name, char *item_name, char *item_rev, long level, long type, MEMptr *attr_list, MEMptr *data_list));

/* ./pdms/PDMsearch.c */
extern int PDMsearch_across_catalogs __PDM((MEMptr names_bufr, MEMptr in_attr_list, MEMptr *out_buffer_list, MEMptr *mis_attr_list));
extern int PDMi_search_across_catalogs __PDM((long user_id, MEMptr names_bufr, MEMptr in_attr_list, MEMptr *out_buffer_list, MEMptr *mis_attr_list, int read_flag));
extern int PDMsearch_for_parts __PDM((MEMptr names_bufr, MEMptr *return_buffer));
extern int PDMfree_query_info_struct __PDM((struct NFMquery_info query_info));
extern int PDMinit_query_info_struct __PDM((struct NFMquery_info *query_info));

/* ./pdms/PDMstls.c */
extern int PSUexe_rpt __PDM((struct PSUrpt *psurpt, char *schema));
extern int PDMreport_from_tmpfile __PDM((char *schema, char *table, char *templib, char *template, char *saname, char *output));

/* ./pdms/PDMwf.c */
extern int PDMsvalidate_user_access __PDM((MEMptr wf_buffer));
extern int PDMsset_to_state __PDM((MEMptr wf_buffer));
extern int PDMmake_transition __PDM((MEMptr attr_buffer, MEMptr data_buffer));
extern int PDMvalidate_item __PDM((long userno, char *entity, char *wf_name, char *proj_name, char *catalog_name, char *part_num, char *revision, long command_no));
extern int PDMvalidate_catalog __PDM((long userno, char *entity, char *wf_name, char *proj_name, char *catalog_name, char *part_num, char *revision, long command_no));
extern int PDMvalidate_project __PDM((long userno, char *entity, char *wf_name, char *proj_name, char *catalog_name, char *part_num, char *revision, long command_no));
extern int PDMvalidate_noentity __PDM((long userno, char *entity, char *wf_name, char *proj_name, char *catalog_name, char *part_num, char *revision, long command_no));
extern int PDMsp_validate_item __PDM((long userno, char *entity, char *wf_name, char *proj_name, char *catalog_name, char *part_num, char *revision, long command_no));
extern int PDMsp_validate_catalog __PDM((long userno, char *entity, char *wf_name, char *proj_name, char *catalog_name, char *part_num, char *revision, long command_no));
extern int PDMsp_validate_project __PDM((long userno, char *entity, char *wf_name, char *proj_name, char *catalog_name, char *part_num, char *revision, long command_no));
extern int PDMsp_validate_noentity __PDM((long userno, char *entity, char *wf_name, char *proj_name, char *catalog_name, char *part_num, char *revision, long command_no));
extern int PDMi_backup_wfinfo __PDM((struct WFstruct *bak));
extern int PDMi_restore_wfinfo __PDM((struct WFstruct bak));
extern int PDMitem_val_in_unmapped_cat __PDM((long userno, char *entity, char *wf_name, char *proj_name, char *catalog_name, char *part_num, char *revision, long command_no));
extern int _PDMprint_nfm_global __PDM((void));
extern int PDMadd_cmd __PDM((int *commandno, char *entity));
extern long PDMquery_make_transition __PDM((long user_id, MEMptr *attr_list, MEMptr *data_list));
extern int PDMsvalidate_user_access_cl __PDM((int user_id, char *command_name, char *wf_name, char *proj_name, char *catalog_name, char *part_num, char *revision));
extern int _PDMload_wfinfo_for_make_transition __PDM((char *catalog_name, char *part_num, char *revision));

/* ./pdms/PDMwhr_usd.c */
extern int PDMget_cit_parents __PDM((MEMptr *cit_bufr));
extern int PDMget_cit_children __PDM((MEMptr *cit_bufr));
extern int PDMget_list_partinfo __PDM((MEMptr in_bufr, MEMptr *out_bufr));
extern int PDMget_imm_parents __PDM((MEMptr *cit_bufr));

#if defined(__cplusplus)
}
#endif

#if defined(__STDC__) || defined(__cplusplus)
#ifndef __PDM
#define __PDM(args) args
#endif
#else
#ifndef __PDM
#define __PDM(args) ()
#endif
#endif

#endif
