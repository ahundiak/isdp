#ifndef PDMS_PDMP_PRO_H
#define PDMS_PDMP_PRO_H

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

/* ./pdmp/PDMadd_fly.c */
extern int PDMsget_families   __PDMS((MEMptr *bufr));
extern int PDMi_create_family __PDMS((long user_id, char *catalog, char *part_num, char *part_rev, char *fly_name, char *fly_desc, MEMptr loc_attr, MEMptr loc_data, MEMptr catalog_buffer, MEMptr catalog_data, MEMptr catalog_lists, MEMptr parm_bufr, MEMptr prompt_bufr));

/* ./pdmp/PDMcp_macro.c */
extern long PDMcopy_macro_library __PDMS((char *working_area, MEMptr copy_bufr, MEMptr *status_buffer));
extern int PDMdetach_macro_library __PDMS((char *macro_cat, struct PDUcat_node *para_cats1, MEMptr *delete_list));
extern long PDMattach_macro_library __PDMS((char *working_area, struct PDUcat_node *families));
extern int PDMold_detach_macro_library __PDMS((char *macro_cat, struct PDUcat_node *para_cats1, MEMptr *delete_list));

/* ./pdmp/PDMmac_cpio.c */
extern int PDMbundle_macros __PDMS((char *cwd, char *cpio_file, MEMptr macros));
extern int PDMsystem __PDMS((char *shell_str));
extern int PDMunbundle_macros __PDMS((char *cpio_file));
extern int PDMXdefine_parametric_assembly __PDMS((char *param_cat, char *param_part, char *param_rev, MEMptr assembly));

/* ./pdmp/PDMmacros.c */
extern int PDMsget_macro_format __PDMS((MEMptr *return_buffer));
extern int PDMadd_macro_library __PDMS((char *mac_cat, MEMptr attr_bufr, MEMptr data_bufr));
extern int PDMstore_parameters __PDMS((MEMptr parm_bufr));
extern int PDMmap_catalog_macro __PDMS((MEMptr macro_bufr));
extern int PDMget_macro_parameters __PDMS((char *catalog, MEMptr *macro, MEMptr *parameters));

/* ./pdmp/PDMmod_del.c */
extern long PDMprepare_change_parametric_catalog __PDMS((long user_id, char *cat_name, MEMptr *loc_attr, MEMptr *loc_data, MEMptr *loc_list, MEMptr *attr_list, MEMptr *data_list, MEMptr *value_list, char **dyn_table, MEMptr *dynamic_attr, MEMptr *dynamic_data, MEMptr *dynamic_list));
extern long PDMchange_parametric_catalog __PDMS((long user_id, MEMptr loc_attr, MEMptr loc_data, MEMptr attr_list, MEMptr data_list, MEMptr value_list, char *dyn_table, MEMptr dynamic_attr, MEMptr dynamic_data, MEMptr dynamic_list));
extern long PDMchange_view_catalog __PDMS((long user_id, MEMptr loc_attr, MEMptr loc_data, MEMptr attr_list, MEMptr data_list, MEMptr value_list, char *dyn_table, MEMptr dynamic_attr, MEMptr dynamic_data, MEMptr dynamic_list));
extern long PDMdelete_parametric_catalog __PDMS((long user_id, char *cat_name, long *cat_no));
extern long PDMdelete_view_catalog __PDMS((long user_id, char *cat_name, long *cat_no));
extern long PDMprepare_change_view_catalog __PDMS((long user_id, char *cat_name, MEMptr *loc_attr, MEMptr *loc_data, MEMptr *loc_list, MEMptr *attr_list, MEMptr *data_list, MEMptr *value_list, char **dyn_table, MEMptr *dynamic_attr, MEMptr *dynamic_data, MEMptr *dynamic_list));

/* ./pdmp/PDMmod_part.c */
extern int PDMget_list_for_modify __PDMS((MEMptr *attr_list, MEMptr *data_list, char *type, MEMptr *modify_parts_list));
extern int PDMupdate_parametric_parts __PDMS((MEMptr attr_list, MEMptr data_list, char *type, MEMptr *ret_bufr));
extern int PDMupdate_rows_to_parm_cat __PDMS((char *catalog, MEMptr attr_list, MEMptr data_list, MEMptr *ret_bufr));
extern int PDMupdate_f_cat_rows __PDMS((char *catalog, MEMptr fattr_list, MEMptr fdata_list));
extern int _PDMget_cit_childno __PDMS((char *citemno_str, MEMptr *cit_bufr));
extern int _PDMconst_upd_str __PDMS((char *attr_name, char *attr_type, char *data, char *out_str));

/* ./pdmp/PDMpar_part.c */
extern int PDMadd_parametric_part __PDMS((MEMptr attr_list, MEMptr data_list, char *type, MEMptr *ret_bufr));
extern int PDMsadd_parametric_part_to_project __PDMS((MEMptr attr_list, MEMptr data_list));

/* ./pdmp/PDMpara_ass.c */
extern long PDMdefine_parametric_assembly __PDMS((MEMptr para_ass, MEMptr para_ass_dynamic));
extern long PDMdefine_support_libraries __PDMS((char *macro_cat, char *macro_part, char *macro_rev, MEMptr macro_ass));

/* ./pdmp/PDMpara_cat.c */
extern long PDMprepare_view_catalog_creation __PDMS((MEMptr *cat_data, MEMptr *acl_list, MEMptr *attr_list, MEMptr *data_list, MEMptr *value_list));
extern long PDMcreate_view_catalog __PDMS((MEMptr cat_data, MEMptr attr_list, MEMptr data_list, MEMptr value_list, char *dyn_table, MEMptr dyn_attr, MEMptr dyn_data, MEMptr dyn_list));
extern int PDMcreate_systable_view __PDMS((char *view_name));
extern long PDMcreate_parametric_catalog __PDMS((MEMptr cat_attr, MEMptr cat_data, MEMptr attr_list, MEMptr data_list, MEMptr value_list, char *dyn_table, MEMptr dyn_attr, MEMptr dyn_data, MEMptr dyn_list));
extern int PDMstore_compute_functions __PDMS((char *catalog_name, char *part_function, char *desc_function));
extern long PDMpopulate_attribute_info __PDMS((char *cat_name, MEMptr attr_list, MEMptr *data_list, MEMptr value_list));
extern long _PDMfake_create_table __PDMS((char *table_type, char *table_name, char *identifier, long *table_no, MEMptr attr_list, MEMptr data_list, MEMptr value_list));
extern int PDMcreate_interface_table __PDMS((char *view_name, int *cat_no));

/* ./pdmp/PDMpart_p.c */
extern int PDMsquery_part_type __PDMS((MEMptr *temp_bufr));
extern int PDMfind_part_type __PDMS((char *catalog, int n_itemno, char *part_type));
extern int PDMschange_part_type __PDMS((MEMptr temp_bufr));

/* ./pdmp/PDMpget_attr.c */
extern int PDMquery_parm_catalog_attributes __PDMS((MEMptr *attr_bufr, MEMptr *data_bufr, MEMptr *list_bufr));
extern int _PDMadd_cols_to_attr_bufr __PDMS((MEMptr bufr, MEMptr *attr_bufr));
extern long _PDMload_datalist_bufr __PDMS((MEMptr attr_list, MEMptr *data_list, MEMptr *list_bufr));
extern long _PDMXXget_list_bufr __PDMS((long attrno, char *type, char *min_value, char *max_value, long def_no, long list_no, long prog_no, char *def_value, MEMptr *list, MEMptr list_buffer));
extern long PDMXXget_range_list __PDMS((long user_id, char *min, char *max, MEMptr *list));
extern long _PDMXXget_list_list __PDMS((long attrno, long list_no, MEMptr *list, MEMptr list_buffer));
extern long _PDMXXget_list_list2 __PDMS((long attrno, long list_no, MEMptr *list, MEMptr list_buffer));
extern long PDMXXget_program_list __PDMS((long user_id, long program_no, MEMptr *list));
extern long PDMXXget_program_value __PDMS((long user_id, long program_no, char *value));
extern long PDMXXget_range_info __PDMS((long user_id, char *min, char *max, MEMptr *list));
extern long PDMXXget_list_info __PDMS((long user_id, long list_no, MEMptr *list));
extern long PDMXXget_program_info __PDMS((long user_id, long program_no, MEMptr *list));
extern long PDMXXget_program_value_info __PDMS((long user_id, long program_no, MEMptr *list));
extern long PDMXXbuild_attr_list __PDMS((MEMptr *list));
extern int _PDMcreate_new_attr_bufr __PDMS((MEMptr *attr_list));
extern int _PDMload_defaults __PDMS((MEMptr *attr_list, MEMptr *data_list, MEMptr *list_bufr, char *mode));
extern int _PDMrecreate_grandchildren_dyn_databufr __PDMS((MEMptr in_bufr, MEMptr *out_put_bufr));
extern int _PDMget_cat_index __PDMS((MEMptr in_bufr, char *column_name, int *offset));
extern int PDMrecreate_validated_dyn_databufr __PDMS((MEMptr in_bufr, MEMptr *out_put_bufr));
extern int PDMget_attr_bufr_for_dyn_cat __PDMS((char *catalog, MEMptr *attr_bufr));

/* ./pdmp/PDMppart.c */
extern int PDMi_copy_library __PDMS((long user_id, char *catalog, char *part_num, char *revision, MEMptr strg_bufr, char *n_cofilename));
extern int PDMcopy_macrolib_file __PDMS((long user_id, char *catalog, char *part_num, char *revision, MEMptr strg_bufr, char *n_cofilename));

/* ./pdmp/PDMptools.c */
extern int PDMi_query_families __PDMS((char *catalog, char *part_num, char *revision, int type, MEMptr *bufr));
extern int PDMi_create_pdc_table __PDMS((long user_id, char *table_name, MEMptr parm_bufr, MEMptr prompt_bufr));
extern int PDMi_create_databuffer __PDMS((MEMptr attr_buffer, MEMptr *data_buffer));
extern int PDMi_query_familyno __PDMS((char *p_familyname, int *p_familyno));
extern int PDMi_query_libraryno __PDMS((char *p_familyname, int *p_libraryno));
extern int PDMi_query_flyname __PDMS((int catno, char *p_familyname));
extern int PDMi_verify_macronames __PDMS((int p_libraryno, MEMptr macro_names));
extern int PDMi_verify_macrodefn __PDMS((char *p_familyname, MEMptr def_bufr));
extern int PDMi_delete_pdcentry __PDMS((char *p_familyname, long citno));
extern int PDMi_insert_pdcinfo __PDMS((char *p_flyname, MEMptr pdc_bufr, MEMptr parm_data));
extern int PDMi_find_sizes __PDMS((char *n_tablename, int *size1, int *size2));
extern int PDMi_delete_pdc_entries __PDMS((int p_citno, char *p_flyname));
extern int PDMinsert_nthlevel_dynamic_info __PDMS((int p_pdcno, char *pdc_table, MEMptr parm_data));

// Different proto in PDMSpdmspro.h
//tern int PDMi_delete_dynamic_info __PDMS((char *p_citno, char *p_flyname, MEMptr pdcno));

/* ./pdmp/PDMviews.c */
extern int PDMget_views_of_paracat __PDMS((MEMptr *para_views));
extern int PDMstore_usageid_cat __PDMS((char *catalog_name, char *usage_id));
extern int PDMget_attr_of_view __PDMS((char *table_type, char *table_name, char *identifier, MEMptr *attr_list, MEMptr *data_list, MEMptr *value_list));
extern int PDMget_dyntable_for_attr __PDMS((int flag, MEMptr attr_bufr, MEMptr *dyn_bufr));

#if defined(__cplusplus)
}
#endif

#if defined(__STDC__) || defined(__cplusplus)
#ifndef __PDMS
#define __PDMS(args) args
#endif
#else
#ifndef __PDMS
#define __PDMS(args) ()
#endif
#endif

#if defined(__STDC__) || defined(__cplusplus)
#ifndef __PDMS
#define __PDMS(args) args
#endif
#else
#ifndef __PDMS
#define __PDMS(args) ()
#endif
#endif

#if defined(__STDC__) || defined(__cplusplus)
#ifndef __PDMS
#define __PDMS(args) args
#endif
#else
#ifndef __PDMS
#define __PDMS(args) ()
#endif
#endif

#if defined(__STDC__) || defined(__cplusplus)
#ifndef __PDMS
#define __PDMS(args) args
#endif
#else
#ifndef __PDMS
#define __PDMS(args) ()
#endif
#endif

#if defined(__STDC__) || defined(__cplusplus)
#ifndef __PDMS
#define __PDMS(args) args
#endif
#else
#ifndef __PDMS
#define __PDMS(args) ()
#endif
#endif

#endif
