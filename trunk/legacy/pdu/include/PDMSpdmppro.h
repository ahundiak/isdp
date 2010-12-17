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

/* ./pdmp/PDMadd_fly.c */
extern int PDMsget_families __PDM((MEMptr *bufr));
extern int PDMi_create_family __PDM((long user_id, char *catalog, char *part_num, char *part_rev, char *fly_name, char *fly_desc, MEMptr loc_attr, MEMptr loc_data, MEMptr catalog_buffer, MEMptr catalog_data, MEMptr catalog_lists, MEMptr parm_bufr, MEMptr prompt_bufr));

/* ./pdmp/PDMcp_macro.c */
extern long PDMcopy_macro_library __PDM((char *working_area, MEMptr copy_bufr));

/* ./pdmp/PDMmac_cpio.c */
extern int PDMbundle_macros __PDM((char *cwd, char *cpio_file, MEMptr macros));
extern int PDMsystem __PDM((char *shell_str));
extern int PDMunbundle_macros __PDM((char *cpio_file));
extern int PDMXdefine_parametric_assembly __PDM((char *param_cat, char *param_part, char *param_rev, MEMptr assembly));

/* ./pdmp/PDMmacros.c */
extern int PDMsget_macro_format __PDM((MEMptr *return_buffer));
extern int PDMadd_macro_library __PDM((char *mac_cat, MEMptr attr_bufr, MEMptr data_bufr));
extern int PDMstore_parameters __PDM((MEMptr parm_bufr));
extern int PDMmap_catalog_macro __PDM((MEMptr macro_bufr));
extern int PDMget_macro_parameters __PDM((char *catalog, MEMptr *macro, MEMptr *parameters));

/* ./pdmp/PDMmod_del.c */
extern long PDMprepare_change_parametric_catalog __PDM((long user_id, char *cat_name, MEMptr *loc_attr, MEMptr *loc_data, MEMptr *loc_list, MEMptr *attr_list, MEMptr *data_list, MEMptr *value_list, char **dyn_table, MEMptr *dynamic_attr, MEMptr *dynamic_data, MEMptr *dynamic_list));
extern long PDMchange_parametric_catalog __PDM((long user_id, MEMptr loc_attr, MEMptr loc_data, MEMptr attr_list, MEMptr data_list, MEMptr value_list, char *dyn_table, MEMptr dynamic_attr, MEMptr dynamic_data, MEMptr dynamic_list));
extern long PDMchange_view_catalog __PDM((long user_id, MEMptr loc_attr, MEMptr loc_data, MEMptr attr_list, MEMptr data_list, MEMptr value_list, char *dyn_table, MEMptr dynamic_attr, MEMptr dynamic_data, MEMptr dynamic_list));
extern long PDMdelete_parametric_catalog __PDM((long user_id, char *cat_name, long *cat_no));
extern long PDMdelete_view_catalog __PDM((long user_id, char *cat_name, long *cat_no));
extern long PDMprepare_change_view_catalog __PDM((long user_id, char *cat_name, MEMptr *loc_attr, MEMptr *loc_data, MEMptr *loc_list, MEMptr *attr_list, MEMptr *data_list, MEMptr *value_list, char **dyn_table, MEMptr *dynamic_attr, MEMptr *dynamic_data, MEMptr *dynamic_list));

/* ./pdmp/PDMmod_part.c */
extern int PDMget_list_for_modify __PDM((MEMptr *attr_list, MEMptr *data_list, char *type, MEMptr *modify_parts_list));
extern int PDMupdate_parametric_parts __PDM((MEMptr attr_list, MEMptr data_list, char *type, MEMptr *ret_bufr));
extern int PDMupdate_rows_to_parm_cat __PDM((char *catalog, MEMptr attr_list, MEMptr data_list, MEMptr *ret_bufr));
extern int PDMupdate_f_cat_rows __PDM((char *catalog, MEMptr fattr_list, MEMptr fdata_list));
extern int _PDMget_cit_childno __PDM((char *citemno_str, MEMptr *cit_bufr));
extern int _PDMconst_upd_str __PDM((char *attr_name, char *attr_type, char *data, char *out_str));

/* ./pdmp/PDMpar_part.c */
extern int PDMadd_parametric_part __PDM((MEMptr attr_list, MEMptr data_list, char *type, MEMptr *ret_bufr));
extern int PDMsadd_parametric_part_to_project __PDM((MEMptr attr_list, MEMptr data_list));
extern int PDMinsert_rows_to_parm_cat __PDM((char *catalog, MEMptr attr_list, MEMptr data_list, MEMptr *ret_bufr));
extern int PDMinsert_f_cat_rows __PDM((char *catalog, MEMptr fattr_list, MEMptr fdata_list, MEMptr *ret_bufr));
extern int _PDMget_data_type __PDM((char *attr, char *data, char *val));
extern int PDMdelete_parametric_parts __PDM((MEMptr attr_list, MEMptr data_list, char *type, MEMptr *ret_bufr));
extern int _PDMcreate_parm_ret_buffer __PDM((MEMptr attr_list, MEMptr *ret_bufr));
extern int _PDMadd_errrow_to_retbufr __PDM((char *itemname, char *itemrev, char *itemdesc, long status, MEMptr *ret_bufr));
extern int PDMmove_parametric_parts_to_next_state __PDM((MEMptr attr_list, MEMptr data_list, char *type, MEMptr *ret_bufr));
extern int _PDMget_to_state __PDM((int workflowno, char *fromstate, char *tostate));
extern int _PDMget_uniq_no_list __PDM((MEMptr data_list, int x, char *out_list));
extern int PDMvalidate_parametric_part __PDM((void));

/* ./pdmp/PDMpara_ass.c */
extern long PDMdefine_parametric_assembly __PDM((MEMptr para_ass));
extern long PDMdefine_support_libraries __PDM((char *macro_cat, char *macro_part, char *macro_rev, MEMptr macro_ass));
extern int PDMcr_para_ass_bufr __PDM((MEMptr *bufr));

/* ./pdmp/PDMpara_cat.c */
extern long PDMprepare_view_catalog_creation __PDM((MEMptr *cat_data, MEMptr *acl_list, MEMptr *attr_list, MEMptr *data_list, MEMptr *value_list));
extern long PDMcreate_view_catalog __PDM((MEMptr cat_data, MEMptr attr_list, MEMptr data_list, MEMptr value_list, char *dyn_table, MEMptr dyn_attr, MEMptr dyn_data, MEMptr dyn_list));
extern int PDMquery_catalog_type __PDM((char *catalog, char *type));
extern int PDMcheck_for_view __PDM((char *catalog));
extern int PDMcreate_systable_view __PDM((char *view_name));
extern long PDMcreate_parametric_catalog __PDM((MEMptr cat_attr, MEMptr cat_data, MEMptr attr_list, MEMptr data_list, MEMptr value_list, char *dyn_table, MEMptr dyn_attr, MEMptr dyn_data, MEMptr dyn_list));
extern int PDMstore_compute_functions __PDM((char *catalog_name, char *part_function, char *desc_function));
extern long PDMpopulate_attribute_info __PDM((char *cat_name, MEMptr attr_list, MEMptr data_list, MEMptr value_list));
extern int PDMplacement_attributes __PDM((MEMptr *attr_bufr));
extern int PDMparse_for_tic __PDM((char *in, char *out));
extern long _PDMfake_create_table __PDM((char *table_type, char *table_name, char *identifier, long *table_no, MEMptr attr_list, MEMptr data_list, MEMptr value_list));
extern int PDMcreate_interface_table __PDM((char *view_name, int *cat_no));

/* ./pdmp/PDMpart_p.c */
extern int PDMsquery_part_type __PDM((MEMptr *temp_bufr));
extern int PDMfind_part_type __PDM((char *catalog, int n_itemno, char *part_type));
extern int PDMschange_part_type __PDM((MEMptr temp_bufr));

/* ./pdmp/PDMpget_attr.c */
extern int PDMquery_parm_catalog_attributes __PDM((MEMptr *attr_bufr, MEMptr *data_bufr, MEMptr *list_bufr));
extern int _PDMadd_cols_to_attr_bufr __PDM((MEMptr bufr, MEMptr *attr_bufr));
extern long _PDMload_datalist_bufr __PDM((MEMptr attr_list, MEMptr *data_list, MEMptr *list_bufr));
extern long _PDMXXget_list_bufr __PDM((long attrno, char *type, char *min_value, char *max_value, long def_no, long list_no, long prog_no, char *def_value, MEMptr *list, MEMptr list_buffer));
extern long PDMXXget_range_list __PDM((long user_id, char *min, char *max, MEMptr *list));
extern long _PDMXXget_list_list __PDM((long attrno, long list_no, MEMptr *list, MEMptr list_buffer));
extern long _PDMXXget_list_list2 __PDM((long attrno, long list_no, MEMptr *list, MEMptr list_buffer));
extern long PDMXXget_program_list __PDM((long user_id, long program_no, MEMptr *list));
extern long PDMXXget_program_value __PDM((long user_id, long program_no, char *value));
extern long PDMXXget_range_info __PDM((long user_id, char *min, char *max, MEMptr *list));
extern long PDMXXget_list_info __PDM((long user_id, long list_no, MEMptr *list));
extern long PDMXXget_program_info __PDM((long user_id, long program_no, MEMptr *list));
extern long PDMXXget_program_value_info __PDM((long user_id, long program_no, MEMptr *list));
extern long PDMXXbuild_attr_list __PDM((MEMptr *list));
extern int _PDMcreate_new_attr_bufr __PDM((MEMptr *attr_list));
extern int _PDMload_defaults __PDM((MEMptr *attr_list, MEMptr *data_list, MEMptr *list_bufr));

/* ./pdmp/PDMppart.c */
extern int PDMi_copy_library __PDM((long user_id, char *catalog, char *part_num, char *revision, MEMptr strg_bufr, char *n_cofilename));
extern int PDMcopy_macrolib_file __PDM((long user_id, char *catalog, char *part_num, char *revision, MEMptr strg_bufr, char *n_cofilename));

/* ./pdmp/PDMptools.c */
extern int PDMi_query_families __PDM((char *catalog, char *part_num, char *revision, int type, MEMptr *bufr));
extern int PDMi_create_pdc_table __PDM((long user_id, char *table_name, MEMptr parm_bufr, MEMptr prompt_bufr));
extern int PDMi_create_databuffer __PDM((MEMptr attr_buffer, MEMptr *data_buffer));
extern int PDMi_query_familyno __PDM((char *p_familyname, int *p_familyno));
extern int PDMi_query_libraryno __PDM((char *p_familyname, int *p_libraryno));
extern int PDMi_query_flyname __PDM((int catno, char *p_familyname));
extern int PDMi_verify_macronames __PDM((int p_libraryno, MEMptr macro_names));
extern int PDMi_verify_macrodefn __PDM((char *p_familyname, MEMptr def_bufr));
extern int PDMi_delete_pdcentry __PDM((char *p_familyname, long citno));
extern int PDMi_insert_pdcinfo __PDM((char *p_flyname, MEMptr pdc_bufr, MEMptr parm_data));
extern int PDMi_find_sizes __PDM((char *n_tablename, int *size1, int *size2));
extern int PDMi_delete_pdc_entries __PDM((int p_citno, char *p_flyname));

/* ./pdmp/PDMviews.c */
extern int PDMget_views_of_paracat __PDM((MEMptr *para_views));
extern int PDMstore_usageid_cat __PDM((char *catalog_name, char *usage_id));
extern int PDMget_attr_of_view __PDM((char *table_type, char *table_name, char *identifier, MEMptr *attr_list, MEMptr *data_list, MEMptr *value_list));
extern int PDMget_dyntable_for_attr __PDM((int flag, MEMptr attr_bufr, MEMptr *dyn_bufr));

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
