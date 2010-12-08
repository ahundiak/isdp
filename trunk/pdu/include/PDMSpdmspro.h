#ifndef PDMS_PDMS_PRO_H
#define PDMS_PDMS_PRO_H

#include "WFstruct.h"

#if defined(__STDC__) || defined(__cplusplus)
#ifndef __PDMS
#define __PDMS(args) args
#endif
#else
#ifndef __PDMS
#define __PDMS(args) ()
#endif
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./pdms/PDMattr.c */
extern int PDMsget_table_attributes      __PDMS((MEMptr *attribute_buffer, MEMptr *data_buffer, MEMptr *list_buffers));
extern int PDMsget_table_data            __PDMS((MEMptr *attribute_buffer, MEMptr *data_buffer, MEMptr *list_buffers));
extern int PDMget_table_template         __PDMS((PDMexec_ptr PDMexec));
extern int PDMquery_template_information __PDMS((PDMexec_ptr PDMexec));
extern int PDMsquery_table_definition    __PDMS((MEMptr *attribute_buffer));
extern int PDMquery_dynamic_attributes   __PDMS((MEMptr *attribute_buffer, MEMptr *data_buffer, MEMptr *list_buffer, MEMptr *assm_bufr));
extern int PDMget_pdcattr_buffer         __PDMS((char *pdc_tbl, MEMptr *attr_bufr));
extern int PDMfast_query_table_def       __PDMS((MEMptr *attribute_buffer));
extern int PDMcreate_application         __PDMS((MEMptr *application));
extern int PDMcreate_application_PDM0    __PDMS((MEMptr *application));
extern int PDMcreate_application1        __PDMS((MEMptr *application));
extern int PDMcreate_application2        __PDMS((MEMptr *application));
extern int PDMquery_dynamic_table_information __PDMS((MEMptr *attribute_buffer, MEMptr *data_buffer, MEMptr *list_buffers));
extern int PDMsget_table_data1           __PDMS((MEMptr *return_buffer));
extern int PDMget_dyn_upd_attr           __PDMS((int dyn_tab_no, MEMptr *attr_buff, MEMptr *data_buff));
extern int PDMget_list_buffer            __PDMS((char *cat_name, char *attr_name, MEMptr *list_buffer));

/* ./pdms/PDMattr_func.c */
extern long PDMmap_attribute_functions __PDMS((char *n_catalogname, char *working_area, MEMptr functions));
extern long PDMcopy_catalog_functions __PDMS((char *template_cat, char *target_cat));
extern long PDMmove_functions __PDMS((char *n_catalogname, char *working_area, MEMptr *functions));
extern long PDMdelete_functions __PDMS((char *n_catalogname, char *working_area));
extern long PDMquery_attribute_functions __PDMS((char *n_catalogname, MEMptr *functions));

/* ./pdms/PDMcat_attr.c */
extern int PDMqry_catalog_attributes __PDMS((char *mode, MEMptr *return_bufr));
extern int PDMi_qry_catalog_attributes __PDMS((char *mode, MEMptr *attr_bufr, MEMptr *data_bufr, MEMptr *list_bufr));
extern int PDMquery_catalog_writable_attributes __PDMS((MEMptr *attr_bufr, MEMptr *data_bufr, MEMptr *list_bufr));
extern int PDMquery_catalog_readable_attributes __PDMS((MEMptr *attr_bufr, MEMptr *data_bufr, MEMptr *list_bufr));
extern int PDMquery_catalog_updatable_attributes __PDMS((MEMptr *attr_bufr, MEMptr *data_bufr, MEMptr *list_bufr));
extern int _PDMload_values_in_data_bufr __PDMS((MEMptr attr_bufr, MEMptr *data_bufr));
extern int PDMOLDqry_catalog_attributes __PDMS((char *mode, MEMptr *return_bufr));
extern int _PDMload_default_vals_in_data_bufr __PDMS((MEMptr val_bufr, MEMptr *def_bufr));

/* ./pdms/PDMcat_class.c */
extern int PDMquery_classification __PDMS((MEMptr input_buffer, MEMptr *output_class));
extern int PDMget_class_of_cat __PDMS((char *catalog_name, MEMptr *class_path));
extern int PDMget_pdmloc_levels __PDMS((int level, char **loc_str));
extern int PDMget_usageid_cat __PDMS((char *catalog_name, char **usage_id));
extern long PDMtemplate_catalog_attributes __PDMS((char *catalog_name, MEMptr *attr_list, MEMptr *data_list, MEMptr *value_list));
extern int PDMstore_classification __PDMS((MEMptr class_path));
extern int PDMadd_more_levels __PDMS((MEMptr class_path));

/* ./pdms/PDMcatalog.c */
extern int PDMcreate_catalog __PDMS((MEMptr loc_attr, MEMptr loc_data, MEMptr catalog_buffer, MEMptr catalog_data, MEMptr catalog_lists, char *dyn_table, MEMptr dynamic_attr, MEMptr dynamic_data, MEMptr dynamic_list));
extern int PDMi_create_catalog __PDMS((long user_id, char auto_file[2 ], MEMptr loc_attr, MEMptr loc_data, MEMptr catalog_buffer, MEMptr catalog_data, MEMptr catalog_lists, MEMptr dynamic_attr, MEMptr dynamic_data, MEMptr dynamic_list, char *dyn_table));
extern int PDMmodify_catalog __PDMS((MEMptr loc_attr, MEMptr loc_data, MEMptr catalog_buffer, MEMptr catalog_data, MEMptr catalog_lists, char *dyn_table, MEMptr dynamic_attr, MEMptr dynamic_data, MEMptr dynamic_list));
extern int PDMcreate_dynamic_table __PDMS((long user_id, char *pdc_tbl, MEMptr dynamic_attr, MEMptr dynamic_data, MEMptr dynamic_list));
extern int PDMdelete_catalog __PDMS((void));

/* ./pdms/PDMdebug.c */
// extern int PDMdebug_on_off __PDMS((void));
// extern int PDMdebug __PDMS((char s[300 ]));
// extern int _PDMdebug __PDMS((int va_alist));

/* ./pdms/PDMflag.c */
extern int PDMsflag_part_archive __PDMS((void));
extern int PDMsflag_part_backup __PDMS((void));
extern int PDMsflag_part_delete __PDMS((void));
extern int PDMsflag_part_restore __PDMS((void));
extern int PDMsUnflag_part_archive __PDMS((void));
extern int PDMsUnflag_part_delete __PDMS((void));
extern int PDMsUnflag_part_restore __PDMS((void));
extern int PDMsUnflag_part_backup __PDMS((void));
extern int _PDMcheck_flag_status __PDMS((char *attr_name, char *flag_stat));
extern int _PDMInterpretPendingFlag __PDMS((char *PendingFlag));

/* ./pdms/PDMgr_asly.c */
extern int PDMsdefine_assembly_structure __PDMS((MEMptr assembly));
extern int PDMi_check_level __PDMS((MEMptr bufr));
extern int PDMdron_setindicator __PDMS((int n_pcatalogno, int n_pitemno));
extern int PDMload_parentnos __PDMS((int catno, int partno, MEMptr bufr));
extern int PDMwrite_2_cols __PDMS((MEMptr bufr, int row, int col1, int col2, char *val1, char *val2));
extern int PDMload_citnos __PDMS((long user_id, MEMptr bufr));
extern int PDMload_set_members __PDMS((long user_id, MEMptr bufr));
extern int PDMcheck_cycles __PDMS((MEMptr bufr));

/* ./pdms/PDMloc_part.c */
extern int PDMlist_of_parts __PDMS((MEMptr names_bufr, MEMptr *attr_list));
extern int PDMi_list_of_parts __PDMS((int sano, MEMptr out_buffer_list, MEMptr *attr_list));
extern int PDMsearch_for_parts_in_project __PDMS((MEMptr names_bufr, MEMptr *temp_bufr));
extern int PDMsearch_for_parts_in_project2 __PDMS((MEMptr names_bufr, MEMptr *temp_bufr));
extern int PDMsearch_for_parts_in_catalog __PDMS((MEMptr names_bufr, MEMptr *attr_list));
extern int PDMexpand_parts_list __PDMS((MEMptr names_bufr, MEMptr nos_bufr, MEMptr *attr_list));
extern long PDMfind_entry_in_fmgr_bufr __PDMS((int catno, int partno, char *n_filenum, char *n_fileversion, char *n_ref, char *n_co, char *n_copy, MEMptr fmgr_bufr));

/* ./pdms/PDMmisc.c */
extern int PDMcopy_data_buffer __PDMS((MEMptr bufr1, MEMptr *bufr2));

/* ./pdms/PDMnet.c */
extern int PDMverify_init __PDMS((void));
extern int PDMterminate __PDMS((void));

/* ./pdms/PDMnfm_sac.c */
extern long NFMsearch_across_catalogs __PDMS((long user_id, char *cat_search_str, char *cat_sort_str, char *item_search_str, char *item_sort_str, MEMptr in_attr_list, MEMptr *out_buffer_list, MEMptr *mis_attr_list));
extern long NFMgen_list __PDMS((long user_id, MEMptr attr_list, MEMptr *out_list, char *cat_name, char *cat_no, char *search_name, char *sort_name));

/* ./pdms/PDMnlogin.c */
extern int PDMlogin __PDMS((long *user_id));
extern int PDMreset_ris_env __PDMS((void));

/* ./pdms/PDMpart.c */
extern int PDMadd_part __PDMS((MEMptr attr_list, MEMptr data_list, MEMptr filelist_list));
extern int PDMdelete_part __PDMS((void));
extern int PDMscancel_modify_part __PDMS((MEMptr attr_list, MEMptr data_list));
extern int PDMsadd_part_to_project __PDMS((MEMptr attr_list, MEMptr data_list));
extern int PDMscheck_delete_part __PDMS((void));
extern int PDMload_state_name __PDMS((MEMptr data_buffer));
extern long PDMdel_part __PDMS((char *cat_name, char *item_name, char *item_rev));
extern long PDMcheck_for_delete_part __PDMS((char *item_name, long cat_no, long item_no, long *delete_saveset_flag));
extern int PDMreset_transfer_status __PDMS((char *catalog, char *partnum, char *revision));

/* ./pdms/PDMpartstr.c */
extern int PDMget_children_attachments __PDMS((long user_id, char *n_catalogname, char *n_itemname, char *n_itemrev, MEMptr *return_buffer));
extern int PDMmake_file_list __PDMS((char *n_catalogname, char *n_itemname, char *n_itemrev, MEMptr *return_buffer));
extern int PDMmake_attach_bufr __PDMS((char *n_catalogname, char *n_itemname, char *n_itemrev, MEMptr *attach_buffer));
extern int PDMget_attach_count __PDMS((int p_type, char *n_catalogname, char *n_itemname, char *n_itemrev, char *c_catalogname, char *c_partnum, char *c_revision, int p_level, int *attach_count));
extern int PDMsshow_saved_views __PDMS((MEMptr *temp_bufr));
extern int PDMget_saved_views __PDMS((MEMptr *temp_bufr));
extern int PDMmodify_assembly __PDMS((MEMptr assembly, MEMptr *attach_bufr));

/* ./pdms/PDMquery_cat.c */
extern long PDMquery_catalog_attributes __PDMS((char *cat_name, MEMptr *attr_list, MEMptr *data_list, MEMptr *value_list));
extern long PDMget_user_name __PDMS((long user_id, long user_no, char *user_name));

/* ./pdms/PDMs_rtns.c */
extern int PDMupdate_set_members __PDMS((char *catalog, char *n_itemname, char *n_itemrev, int p_catno, int p_itemno, MEMptr child_bufr, MEMptr *citno_bufr, MEMptr *cit_bufr));
extern int PDMinsert_citinfo __PDMS((int p_catalogno, int p_itemno, MEMptr child_bufr, MEMptr parm_buffer, MEMptr parmdata_buffers, MEMptr citno, char *p_update));
extern int PDMdelete_pdm_entries __PDMS((int n_pcatalogno, int n_pitemno, MEMptr *citno));
extern int PDMadd_child __PDMS((char *catalog, char *n_itemname, char *n_itemrev, int p_catno, int p_itemno, char *c_catalog, char *c_itemname, char *c_itemrev, int *child_catno, int *child_itemno, int next_citno, int *n_citno));

// Different proto in PDMSpdmppro.h
//tern int PDMi_delete_dynamic_info __PDMS((MEMptr pdcno));

extern int PDMget_citno __PDMS((int p_catno, int p_itemno, int c_catno, int c_itemno, int *n_citno));
extern int PDMinsert_dynamic_table_info __PDMS((char *n_catalogname, MEMptr cit_bufr, MEMptr parm_data));
extern int PDMinsert_views __PDMS((char *pdmsv_table, int p_partno, MEMptr sv_bufr));
extern int PDMConvertToAtomic __PDMS((char *catalog, char *n_itemname, char *n_itemrev, int p_catno, int p_itemno, MEMptr *citno_bufr, MEMptr *cit_bufr));

/* ./pdms/PDMsearch.c */
extern int PDMsearch_across_catalogs __PDMS((MEMptr names_bufr, MEMptr in_attr_list, MEMptr *out_buffer_list, MEMptr *mis_attr_list));
extern int PDMi_search_across_catalogs __PDMS((long user_id, MEMptr names_bufr, MEMptr in_attr_list, MEMptr *out_buffer_list, MEMptr *mis_attr_list, int read_flag));
extern int PDMsearch_for_parts __PDMS((MEMptr names_bufr, MEMptr *return_buffer));

/* ./pdms/PDMupd_mem.c */
extern long PDMcheck_set_loop __PDMS((long user_id, MEMptr cit_attr, long p_cat_no, long p_item_no, long c_cat_no, long c_item_no, long pc_off, long pi_off, long cc_off, long ci_off));
extern long PDMcheck_parent_loop __PDMS((long user_id, MEMptr cit_attr, MEMptr par_list, long cat_no, long item_no, long pc_off, long pi_off, long cc_off, long ci_off));

/* ./pdms/PDMwf.c */
extern int PDMsvalidate_user_access __PDMS((MEMptr wf_buffer));
extern int PDMsset_to_state __PDMS((MEMptr wf_buffer));
extern int PDMmake_transition __PDMS((MEMptr attr_buffer, MEMptr data_buffer));
extern int PDMvalidate_item __PDMS((long userno, char *entity, char *wf_name, char *proj_name, char *catalog_name, char *part_num, char *revision, long command_no));
extern int PDMvalidate_catalog __PDMS((long userno, char *entity, char *wf_name, char *proj_name, char *catalog_name, char *part_num, char *revision, long command_no));
extern int PDMvalidate_project __PDMS((long userno, char *entity, char *wf_name, char *proj_name, char *catalog_name, char *part_num, char *revision, long command_no));
extern int PDMvalidate_noentity __PDMS((long userno, char *entity, char *wf_name, char *proj_name, char *catalog_name, char *part_num, char *revision, long command_no));
extern int PDMsp_validate_item __PDMS((long userno, char *entity, char *wf_name, char *proj_name, char *catalog_name, char *part_num, char *revision, long command_no));
extern int PDMsp_validate_catalog __PDMS((long userno, char *entity, char *wf_name, char *proj_name, char *catalog_name, char *part_num, char *revision, long command_no));
extern int PDMsp_validate_project __PDMS((long userno, char *entity, char *wf_name, char *proj_name, char *catalog_name, char *part_num, char *revision, long command_no));
extern int PDMsp_validate_noentity __PDMS((long userno, char *entity, char *wf_name, char *proj_name, char *catalog_name, char *part_num, char *revision, long command_no));
extern int PDMi_backup_wfinfo __PDMS((struct WFstruct *bak));
extern int PDMi_restore_wfinfo __PDMS((struct WFstruct bak));
extern int PDMitem_val_in_unmapped_cat __PDMS((long userno, char *entity, char *wf_name, char *proj_name, char *catalog_name, char *part_num, char *revision, long command_no));
extern int _PDMprint_nfm_global __PDMS((void));
extern int PDMadd_cmd __PDMS((int *commandno, char *entity));
extern long PDMquery_make_transition __PDMS((long user_id, MEMptr *attr_list, MEMptr *data_list));
extern int PDMsvalidate_user_access_cl __PDMS((int user_id, char *command_name, char *wf_name, char *proj_name, char *catalog_name, char *part_num, char *revision));
extern int _PDMload_wfinfo_for_make_transition __PDMS((char *catalog_name, char *part_num, char *revision));

/* ./pdms/PDMwhr_usd.c */
extern int PDMget_cit_parents __PDMS((MEMptr *cit_bufr));
extern int PDMget_cit_children __PDMS((MEMptr *cit_bufr));
extern int PDMget_list_partinfo __PDMS((MEMptr in_bufr, MEMptr *out_bufr));
extern int PDMget_imm_parents __PDMS((MEMptr *cit_bufr));

#if defined(__cplusplus)
}
#endif

#endif
