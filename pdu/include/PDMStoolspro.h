#ifndef PDMS_TOOLS_PRO_H
#define PDMS_TOOLS_PRO_H

#include "PDMbom_strct.h"

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

/* ./tools/PDMattr_f.c */
extern int PDMget_attribute_no __PDMS((int n_tableno, char *n_name, int *n_attrno));
extern int PDMget_attribute_name __PDMS((int n_tableno, int *n_attrno, char *n_name));
extern int PDMget_table_no __PDMS((char *n_tablename, char *n_tabletype, int *n_tableno));
extern int PDMi_get_nname __PDMS((char *n_nfmname, char *n_tableno, char *n_name));
extern int PDMi_maxrow_no __PDMS((char *table, char *attr_name, int *maxrow));
extern int PDMi_query_synonym __PDMS((int n_tableno, char *n_name, char *n_synonym));
extern int PDMi_find_datatype __PDMS((int n_tableno, char *n_name, char *n_datatype));
extern int PDMload_nnames __PDMS((MEMptr bufr));
extern int PDMget_bom_attr_name __PDMS((int *n_attrno, char *n_name));

/* ./tools/PDMbom_f.c */
extern int PDMquery_bom_name __PDMS((char *n_catalogname, char *n_itemname, char *p_partrev, char *p_bomname));
extern int PDMfind_maxlevel __PDMS((char *n_catalogname, char *n_itemname, char *p_partrev, long *p_maxlevel));
extern int PDMfind_p_explode __PDMS((char *catalog, char *part_num, char *part_rev, char *p_explode));
extern int PDMfind_citp_explode __PDMS((char *catalog, char *part_num, char *part_rev, char *p_explode, char *p_incbom));
extern int PDMfind_citc_explode __PDMS((char *catalog, char *part_num, char *part_rev, char *p_incbom));
extern int PDMswap_bom_tables __PDMS((char *p_catalog, char *n_itemname, char *p_partrev, char *oldbom, char *newbom));
extern int PDMdelete_bom __PDMS((void));
extern int PDMdrop_bom __PDMS((int n_catalogno, int n_itemno));
extern int PDMdrop_a_bom __PDMS((char *bom));
extern int PDMi_find_bomtable __PDMS((char *catalog, char *part_num, char *revision, char *p_bomtype, char *p_bomname));
extern int PDMi_find_bominfo __PDMS((char *catalog, char *part_num, char *revision, char *p_bomname, char *p_createdate));
extern int PDMverify_bomlock __PDMS((char *catalog, char *partnum, char *revision));

/* ./tools/PDMbom_tools.c */
extern int PDMadd_buffer_string __PDMS((char *buff_string, int *position, char *char_string));
extern void _PDMprint_bommember __PDMS((char *name, struct PDMbom_member *mem));
extern void _PDMprint_bommember_info __PDMS((char *name, struct PDMbom_member *mem));
extern void _PDMget_double_from_buf_val __PDMS((char *str, double *in_doub));
extern int _PDMasc_to_doub __PDMS((char *str, double *doub_str));
extern int PDMappend __PDMS((MEMptr *bufr, MEMptr bufr1));
extern int _PDMupdate_pdmboms __PDMS((int cat_no, int item_no, char *exist_bom));
extern long PDMget_dyntable_for_catalog __PDMS((char *catalog, char *dyn_table));
extern int _PDMi_get_dyn_catname __PDMS((int catno, char *y_catname));

/* ./tools/PDMbommnpl.c */
extern int PDMdelete_sub_tree __PDMS((char *bom, int p_seqno));
extern int PDMrecursive_fetch __PDMS((char *bom, int p_seqno, MEMptr *tree_bufr));
extern int PDMbuild_assembly __PDMS((char *bom, int p_seqno, MEMptr *tree_bufr));
extern int PDMinsert_new_child __PDMS((char *bom, char *n_catalogname, char *n_itemname, char *n_itemrev, char *p_orient, double p_quantity, char *p_history, char *p_childno, char *p_usageid, char *p_viewid, int p_tagno, char *p_alttagno, char *p_incbom, char *p_explode));
extern int PDMcopy_active_bom __PDMS((char *active_bom, char *review_bom));
extern int PDMcopy_review_bom __PDMS((char *review_bom, char *active_bom));
extern int PDMcopy_table __PDMS((char *table1, char *table2));
extern int PDMcopy_abom_attachments __PDMS((char *old_bom, char *new_bom, MEMptr attach_bufr, MEMptr *ret_bufr));
extern int PDMcopy_rbom_attachments __PDMS((char *old_bom, char *new_bom));
extern int PDMset_attached_flag __PDMS((char *bom, int p_seqno));
extern int PDMassemble_bottomup __PDMS((int p_parentno, int p_level, int p_tagno, char p_childno[30 ], int p_seqno, char *bom, MEMptr *bufr));
extern int PDMaccumulate_parent __PDMS((int p_no, char *bom, MEMptr *bufr));
extern int PDMverify_assembly __PDMS((char *bom, MEMptr bufr, int *seqno));
extern int PDMcompare_assemblies __PDMS((MEMptr bufr1, MEMptr bufr2, int *p_seqno));

/* ./tools/PDMcico_tool.c */
extern int PDMi_prepare_buffer1 __PDMS((MEMptr *attach_bufr));
extern int PDMXXsa_info __PDMS((int sa_no));
extern int PDMget_file_list __PDMS((long user_id, char *catalog, char *partnum, char *revision, MEMptr *list));
extern int PDMmake_data_buffer __PDMS((MEMptr *list));
extern int PDMXmake_file_buffer __PDMS((MEMptr *list));
extern int PDMXload_sano_info __PDMS((int user_id, MEMptr *list));
extern int PDMset_info_oper_struct __PDMS((char *catalog, char *p_partnum, char *p_revision));
extern int PDMset_oper_struct __PDMS((char *catalog, char *p_partnum, char *p_revision));
extern int PDMupdate_ncoout __PDMS((char *catalog, int itemno, char *upd_str));
extern int PDMreset_ncoout __PDMS((char *catalog, int itemno, char *old_coout));
extern int PDMupdate_dots __PDMS((void));
extern int PDMreset_dots __PDMS((void));
extern int PDMquery_catalog_part_rev_type __PDMS((int n_catalogno, int n_itemno, char *catalog, char *part_num, char *part_rev, char *part_type));
extern int PDMget_mul_file __PDMS((char *catalog, int itemno, MEMptr *temp_bufr1));
extern int PDMget_new_files __PDMS((char *catalog, int itemno, MEMptr *temp_bufr1));
extern int PDMcheck_dup_sa_fname __PDMS((char *filename, char *strg_name));
extern int PDMget_co_username __PDMS((char *catalog, char *partnum, char *revision, int *CoUserId));

/* ./tools/PDMctools.c */
extern int PDMquery_cit_members __PDMS((long user_id, char *catalog, char *part, char *rev, int level, MEMptr *attr_bufr, MEMptr *ret_bufr));
extern int PDMget_catalog_name __PDMS((long no, char *name));
extern int PDMget_itemname __PDMS((long no, char *catalog, char *itemnum, char *itemrev));
extern int PDMopen_set_buffer __PDMS((MEMptr *ret_bufr));
extern int PDMcount_cit_attachments __PDMS((int p_citno, int *count));
extern int PDMcount_bom_attachments __PDMS((int p_type, char *bom_name, char *n_catalogname, char *n_itemname, char *n_itemrev, int p_level, int *count));
extern int PDMget_itemname_filever __PDMS((long no, char *catalog, char *itemnum, char *itemrev, int *filenum, int *filever));
extern int PDMget_max_filever __PDMS((long no, char *catalog, int *filever));
extern int PDMget_filenum __PDMS((long no, char *catalog, char *filename, int *filenum));
extern int PDMget_projectno __PDMS((char *project_name, int *project_no));
extern int PDMget_max_filever_fname __PDMS((int no, char *catalog, int filenum, int *filever));

/* ./tools/PDMdbms_f.c */
extern int PDMstop_transaction __PDMS((long pdm_type));
extern int PDMstart_transaction __PDMS((long pdm_type));
extern int PDMrollback_transaction __PDMS((long pdm_type));

/* ./tools/PDMdebug.c */
extern int  PDMdebug_on_off __PDMS((void));
extern int  PDMdebug        __PDMS((char s[300 ]));
extern int _PDMdebug        __PDMS((char *fname, char *fmt, ...));

/* ./tools/PDMdyn_tbd.c */
extern int PDMi_find_maxdatatype __PDMS((char *attribute, char *datatype));

/* ./tools/PDMdynamic.c */
extern int PDMi_find_maxtype __PDMS((MEMptr buffer, int n, char *n_name, int *size));
extern int PDMexpand_copy_buffer __PDMS((MEMptr bufr1, MEMptr bufr2, MEMptr *bufr3));
extern int PDMset_offsets __PDMS((MEMptr attr_bufr, MEMptr data_bufr, MEMptr offsets_bufr));

/* ./tools/PDMfasttool.c */
extern int PDMload_part_info __PDMS((char *catalog, char *partnum, char *revision));
extern int PDMload_child_info __PDMS((char *catalog, char *partnum, char *revision));
extern int PDMquery_part_info __PDMS((MEMptr *bufr));
extern void _PDMinit_part_struct __PDMS((PDMpart_ptr PDMchild));
extern void _PDMprint_setinfo1_struct __PDMS((char *struct_name, struct set_info1 *set));
extern void _PDMprint_childinfo_struct __PDMS((char *struct_name, struct child_info *set));

/* ./tools/PDMfmgr_tool.c */
extern int PDMlogin_find_sainfo __PDMS((int *n_sano, char *n_saname));
extern int PDMi_find_storageno_name __PDMS((int *n_sano, char *n_saname));
extern int _PDMCheckDuplPath __PDMS((int nodeno));

/* ./tools/PDMlfm_tools.c */
extern void _PDMprint_setmember __PDMS((char *name, struct NFMset_member *mem));
extern void _PDMprint_fileentry __PDMS((char *name, struct NFMfile_entry *mem));
extern void _PDMprint_itementry __PDMS((char *name, struct NFMitem_entry *mem));
extern void _PDMprint_all_setmember __PDMS((char *name, struct NFMset_member *mem));
extern void PDMprint_storage_area __PDMS((void));
extern int _PDMget_cofilename_cprfnum __PDMS((char *catalog, char *itemno, char *filenum, char *cofilename));
extern int PDMGetPartInfoGivenFileName __PDMS((char *filename, char *catalog, char *partnum, char *revision));
extern long PDMget_stg_filename __PDMS((char *cpr_catalog, char *cpr_part, char *cpr_rev, MEMptr *file_buff));

/* ./tools/PDMmisc.c */
extern int PDMcopy_data_buffer __PDMS((MEMptr bufr1, MEMptr *bufr2));

/* ./tools/PDMpara_tool.c */
extern int PDMquery_catalog_type __PDMS((char *catalog, char *type));
extern int PDMcheck_for_view __PDMS((char *catalog));
extern int PDMplacement_attributes __PDMS((MEMptr *attr_bufr));
extern int PDMparse_for_tic __PDMS((char *in, char *out));
extern int PDMcr_para_ass_bufr __PDMS((MEMptr *bufr));

/* ./tools/PDMpart_f.c */
extern int PDMquery_assembly_ind __PDMS((char *catalog, char *n_itemname, char *n_itemrev, char *n_setindicator));
extern int PDMquery_itemno_assind __PDMS((char *catalog, char *n_itemname, char *n_itemrev, char *type, char *n_setindicator, int *n_itemno));
extern int PDMquery_assyind_parttype __PDMS((char *catalog, char *n_itemname, char *n_itemrev, char *n_setindicator, char *p_parttype));
extern int PDMset_n_setindicator __PDMS((char *catalog, char *n_itemname, char *n_itemrev, char *n_setindicator));
extern int PDMquery_catalog_partnos __PDMS((char *catalog, char *n_itemname, char *n_itemrev, int *n_catalogno, int *n_itemno));
extern int PDMquery_catalogno __PDMS((char *catalog, int *n_catalogno));
extern int PDMstorage_location_check __PDMS((char *catalog, int n_itemnum, int *n_cisano));
extern int PDMquery_partno __PDMS((char *catalog, char *part, char *rev, int *n_itemno));
extern int PDMprint_exec __PDMS((char s1[200 ], PDMexec_ptr PDMexec));
extern int PDMquery_parttype __PDMS((char *catalog, char *partnum, char *partrev, char *parttype));
extern int PDMset_parttype __PDMS((char *catalog, char *partnum, char *partrev, char *parttype));
extern int PDMi_query_parmtype __PDMS((char *family_name, char *attr_name, char *p_iotype));
extern int PDMi_get_partnum_rev __PDMS((char *catalog, int n_itemno, char *part_num, char *part_rev));
extern int PDMget_partnum_rev_CID __PDMS((char *catalog, int n_itemno, char *part_num, char *part_rev));
extern int PDMi_get_cidate __PDMS((char *catalog, char *part_num, char *part_rev, char *n_cidate, char *n_citime));
extern int PDMi_find_cofilename __PDMS((char *catalog, char *part_num, char *part_rev, char *filename));
extern int PDMload_partdata __PDMS((MEMptr bufr));
extern int PDMload_partnos __PDMS((MEMptr bufr));
extern int PDMload_partnums __PDMS((MEMptr bufr));
extern int PDMload_filenos __PDMS((int p_sano, MEMptr bufr));
extern int PDMi_query_catalogname __PDMS((char *catno, char *catalog));
extern int PDMi_query_partnumrev __PDMS((char *catno, char *catalog, char *n_itemno, char **n_itemname, char **n_itemrev));
extern int PDMquery_table_no __PDMS((char *table, int *p_tableno));
extern int PDMquery_file_status __PDMS((char *catalog, char *n_itemname, char *n_itemrev, char **n_status));
extern int PDMget_part_info __PDMS((MEMptr *temp_bufr));
extern int PDMget_file_names __PDMS((MEMptr *temp_bufr));
extern int PDMget_part_rev_type __PDMS((MEMptr *temp_bufr));
extern int PDMget_rev __PDMS((MEMptr *temp_bufr));
extern int PDMcatalogs_of_proj_part __PDMS((void));
extern int PDMget_ems_files __PDMS((MEMptr *temp_bufr, MEMptr *temp_bufr1));
extern long PDMval_part_for_copy __PDMS((char *n_catalogname, int n_itemno));
extern int PDMi_get_partnum_rev_desc __PDMS((char *catalog, int n_itemno, char *part_num, char *part_rev, char *part_desc));
extern int PDMi_get_partnum_rev_type __PDMS((char *catalog, int n_itemno, char *part_num, char *part_rev, char *part_type));
extern int PDMload_partno_filename __PDMS((MEMptr bufr));
extern int PDMget_storageno __PDMS((char *strg_name, int *sano));
extern int PDMcheck_partnum_without_rev __PDMS((char *catalog, char *n_itemname));
extern int PDMquery_dyn_table_no __PDMS((char *dyn_table, int *p_dyn_tableno));
extern int PDMconvert_to_lower __PDMS((char *string, char *string1));
extern int _PDMget_db_error __PDMS((int status2));
extern int _PDMget_attribute_value __PDMS((char *catalog, char *part, char *rev, char *attr, char *value));
extern int PDMquery_catalogtype_no __PDMS((char *catalog, char *type, int *catno));
extern int PDMQueryAssyIndPTypePDesc __PDMS((char *catalog, char *n_itemname, char *n_itemrev, char *n_setindicator, char *p_parttype, char *n_itemdesc));
extern int PDMQueryAssyIndPFlag __PDMS((char *catalog, char *n_itemname, char *n_itemrev, char *n_setindicator, char *n_pendingflag));
extern int PDMQueryAssyIndGivenPartno __PDMS((char *catalog, int itemno, char *n_setindicator));

/* ./tools/PDMpart_p.c */
extern int PDMsquery_part_type __PDMS((MEMptr *temp_bufr));
extern int PDMfind_part_type __PDMS((char *catalog, int n_itemno, char *part_type));
extern int PDMschange_part_type __PDMS((MEMptr temp_bufr));

/* ./tools/PDMpdms_tool.c */
extern int PDMvalidate_attribute __PDMS((char *attribute_name, int table_no));
extern long PDMcreate_data_buffer __PDMS((MEMptr attr_buffer, MEMptr *data_buffer));
extern int PDMparse_for_illegal_char __PDMS((char *string));
extern long PDMdyntable_for_catalog __PDMS((char **dyn_table));
extern int PDMquery_catalogno_type __PDMS((char *catalog, int *catno, char *type));
extern int PDMfree_query_info_struct __PDMS((struct NFMquery_info query_info));
extern int PDMinit_query_info_struct __PDMS((struct NFMquery_info *query_info));

/* ./tools/PDMpget_attr.c */
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
extern int _PDMCreateValueListBufr __PDMS((MEMptr attr_bufr, MEMptr list_bufr, MEMptr *ValListBufr));

/* ./tools/PDMptools.c */
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
extern int PDUXi_delete_dynamic_info __PDMS((char *p_citno, char *p_flyname, MEMptr pdcno));

/* ./tools/PDMquery_cat.c */
extern long PDMquery_catalog_attributes __PDMS((char *cat_name, MEMptr *attr_list, MEMptr *data_list, MEMptr *value_list));
extern long PDMget_user_name __PDMS((long user_id, long user_no, char *user_name));

/* ./tools/PDMrefresh.c */
extern int PDMverify_catalog __PDMS((MEMptr *return_buffer));
extern int PDMi_verify_catalog __PDMS((char *catalog));
extern int PDMverify_part __PDMS((char *catalog, char *partnum, char *revision));
extern int PDMquery_part_status __PDMS((void));
extern int PDMsshow_catalogs __PDMS((MEMptr bufr, MEMptr *temp_bufr));
extern int PDMshow_parts __PDMS((MEMptr *bufr));
extern int PDMs_sql_query __PDMS((MEMptr bufr, MEMptr *return_buffer));
extern int PDMs_sql_distinct __PDMS((MEMptr bufr, MEMptr *return_buffer));
extern int PDMcatalogs_in_project __PDMS((MEMptr *temp_bufr));
extern int PDMprojects_of_catalog __PDMS((MEMptr *temp_bufr));
extern int PDMlist_of_projects __PDMS((MEMptr *temp_bufr));
extern int PDMcatalog_project_map __PDMS((PDMexec_ptr PDMexec));
extern int PDMsverify_project __PDMS((void));
extern int convert_toupper __PDMS((char *string, char *string1));
extern int PDMparts_of_catalog __PDMS((MEMptr *bufr));
extern int PDMget_desc __PDMS((MEMptr *bufr));
extern int PDMget_state_name __PDMS((MEMptr *bufr));
extern int PDMshow_catalog_acls __PDMS((MEMptr *return_buffer));
extern int PDMget_part_type_desc __PDMS((MEMptr *bufr));
extern int PDMsget_catno_partno __PDMS((MEMptr *ret_bufr));
extern int PDMcheck_part_status __PDMS((void));
extern int PDMquery_lower_case_catalogname __PDMS((char *catname));

/* ./tools/PDMrep_tools.c */
extern int PDMfind_system_path __PDMS((char *pathname, int *sano));
extern int PDMquery_report_type __PDMS((char *report, char *type, char *lib, char *out_file));

/* ./tools/PDMreport_f.c */
extern int PDMappend_10_buffers __PDMS((MEMptr *ret_bufr, MEMptr b1, MEMptr b2, MEMptr b3, MEMptr b4, MEMptr b5, MEMptr b6, MEMptr b7, MEMptr b8, MEMptr b9, MEMptr b10));
extern int PDMsplit_10_buffers __PDMS((MEMptr ws_buffer, MEMptr *b1, MEMptr *b2, MEMptr *b3, MEMptr *b4, MEMptr *b5, MEMptr *b6, MEMptr *b7, MEMptr *b8, MEMptr *b9, MEMptr *b10));
extern int PDMsplit_16_buffers __PDMS((MEMptr ws_buffer, MEMptr *b1, MEMptr *b2, MEMptr *b3, MEMptr *b4, MEMptr *b5, MEMptr *b6, MEMptr *b7, MEMptr *b8, MEMptr *b9, MEMptr *b10, MEMptr *b11, MEMptr *b12, MEMptr *b13, MEMptr *b14, MEMptr *b15, MEMptr *b16));
extern int PDMappend_16_buffers __PDMS((MEMptr *ret_bufr, MEMptr b1, MEMptr b2, MEMptr b3, MEMptr b4, MEMptr b5, MEMptr b6, MEMptr b7, MEMptr b8, MEMptr b9, MEMptr b10, MEMptr b11, MEMptr b12, MEMptr b13, MEMptr b14, MEMptr b15, MEMptr b16));
extern int PDMget_templateno __PDMS((struct PSUrpt *psurpt, int *tempno, int tmptype));

/* ./tools/PDMstls.c */
extern int PSUexe_rpt __PDMS((struct PSUrpt *psurpt, char *schema));
extern int PDMreport_from_tmpfile __PDMS((char *schema, char *table, char *templib, char *template, char *saname, char *output));

/* ./tools/PDMstools1.c */
extern int PDMget_cwd __PDMS((char **cwd));
extern int PDMi_get_date __PDMS((char *c_date, char *c_time));
extern int PDMget_date_time __PDMS((char *current_date, char *current_time, char *delimiter, int format_flag));
extern int PDMcheck_for_double_quotes __PDMS((char *s1, char *s2));
extern int PDMgen_bomtable_name __PDMS((char *temp_table));
extern int PDMgen_table_name __PDMS((char *temp_table));
extern int PDMgen_file_name __PDMS((char *file_name));
extern int PDMcreate_ris_table __PDMS((char *table_name, MEMptr bufr1, MEMptr bufr2, MEMptr bufr3));
extern int PDMquery_cit_attachment __PDMS((long p_citno, char *p_attached));
extern int PDMquery_bom_attachment __PDMS((char *review_bom, char *n_itemname, char *n_itemrev, char *catalog, int level, char *p_attached));
extern int PDMi_delete_rows __PDMS((MEMptr buffer, char *table_name, int n));
extern int PDMi_query_passwd __PDMS((char *username, char *passwd));
extern int PDMi_delete_fileno __PDMS((char *p_fileno));
extern int PDMi_delete_partnum __PDMS((char *n_itemname));
extern int PDMcofilename __PDMS((char *cofilename));
extern int PDMcheck_for_autofilename __PDMS((char *cat));

/* ./tools/PDMstools2.c */
extern int PDMi_find_nodeno __PDMS((char *n_nodename, int *n_nodeno));
extern int PDMi_find_partnum __PDMS((int n_catalogno, int n_itemno, int *n_itemname));
extern int PDMi_find_fileno __PDMS((int n_itemname, int p_sano, int *p_fileno));
extern int PDMi_find_filenos __PDMS((int n_itemname, int p_sano, MEMptr *bufr));
extern int PDMi_find_references __PDMS((int n_itemname, int p_sano, int *p_ref1, int *p_ref2));
extern int PDMi_find_allrefs __PDMS((int n_itemname, int p_sano, int *p_ref1, int *p_ref2));
extern int PDMi_update_references __PDMS((int n_itemname, int p_sano, int p_type));
extern int PDMi_next_negativeno __PDMS((char *table, int *p_citno));
extern int PDMi_find_sano __PDMS((int n_nodeno, char *n_username, char *n_pathname, int *n_sano));
extern int PDMi_copy_format __PDMS((MEMptr bufr1, MEMptr *bufr2));
extern int PDMi_compare_dates __PDMS((char *date1, char *date2));
extern int PDMi_update_attachments __PDMS((int n_itemname, int p_sano));
extern int PDMsano_to_name __PDMS((int n_sano, char *p_local));
extern int PDMcheck_to_update __PDMS((void));
extern int PDMupdate_to_define __PDMS((void));
extern int PDMupdate_os_necessary __PDMS((void));
extern int PDMset_update_os_flag __PDMS((char *flag));

/* ./tools/PDMtable_f.c */
extern int PDMi_find_tablename __PDMS((char *catalog, char *part_num, char *revision, char *p_tabletype, char *p_tablename));
extern int PDMi_find_tableinfo __PDMS((char *catalog, char *part_num, char *revision, char *p_tabletype, char *p_tablename, char *p_createdate));
extern int PDMi_insert_pdmtables __PDMS((char *catalog, char *part_num, char *revision, char *p_tabletype, char *p_tablename));
extern int PDMget_ris_datatype __PDMS((char *table_name, char *column_name, char *type));
extern int PDMi_delete_from_pdmtables __PDMS((char *catalog, char *part_num, char *revision, char *p_tabletype, char *p_tablename));

/* ./tools/PDMtimestamp.c */
extern void _PDMtime_data __PDMS((char *format, ...));
extern void _PDMtime_commit __PDMS((void));

/* ./tools/PDMviews.c */
extern int PDMget_views_of_paracat __PDMS((MEMptr *para_views));
extern int PDMstore_usageid_cat __PDMS((char *catalog_name, char *usage_id));
extern int PDMget_attr_of_view __PDMS((char *table_type, char *table_name, char *identifier, MEMptr *attr_list, MEMptr *data_list, MEMptr *value_list));
extern int PDMget_dyntable_for_attr __PDMS((int flag, MEMptr attr_bufr, MEMptr *dyn_bufr));

/* ./tools/PDMwf_acl.c */
extern int PDMwfacl_of_catalog __PDMS((PDMexec_ptr PDMexec));
extern int PDMstrg_of_catalog __PDMS((PDMexec_ptr PDMexec));
extern int PDMget_commandno __PDMS((char *command, int *command_no));
extern int PDMget_workflowno __PDMS((int aclno, int *workflowno));
extern int PDMget_state_aclno __PDMS((char *catalog, char *itemname, char *revision, int *aclno, int *stateno));
extern int PDMgetacl_info __PDMS((char *cat_name, char *part_num, char *revision, char acl_name[20 ], char state_name[40 ], char wkfl_name[20 ]));

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
