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

/* ./tools/PDMattr_f.c */
extern int PDMget_attribute_no __PDM((int n_tableno, char *n_name, int *n_attrno));
extern int PDMget_attribute_name __PDM((int n_tableno, int *n_attrno, char *n_name));
extern int PDMget_table_no __PDM((char *n_tablename, char *n_tabletype, int *n_tableno));
extern int PDMi_get_nname __PDM((char *n_nfmname, char *n_tableno, char *n_name));
extern int PDMi_maxrow_no __PDM((char *table, char *attr_name, int *maxrow));
extern int PDMi_query_synonym __PDM((int n_tableno, char *n_name, char *n_synonym));
extern int PDMi_find_datatype __PDM((int n_tableno, char *n_name, char *n_datatype));
extern int PDMload_nnames __PDM((MEMptr bufr));

/* ./tools/PDMbom_f.c */
extern int PDMquery_bom_name __PDM((char *n_catalogname, char *n_itemname, char *p_partrev, char *p_bomname));
extern int PDMfind_maxlevel __PDM((char *n_catalogname, char *n_itemname, char *p_partrev, long *p_maxlevel));
extern int PDMfind_p_explode __PDM((char *catalog, char *part_num, char *part_rev, char *p_explode));
extern int PDMfind_citp_explode __PDM((char *catalog, char *part_num, char *part_rev, char *p_explode, char *p_incbom));
extern int PDMfind_citc_explode __PDM((char *catalog, char *part_num, char *part_rev, char *p_incbom));
extern int PDMswap_bom_tables __PDM((char *p_catalog, char *n_itemname, char *p_partrev, char *oldbom, char *newbom));
extern int PDMdelete_bom __PDM((void));
extern int PDMdrop_bom __PDM((int n_catalogno, int n_itemno));
extern int PDMdrop_a_bom __PDM((char *bom));
extern int PDMi_find_bomtable __PDM((char *catalog, char *part_num, char *revision, char *p_bomtype, char *p_bomname));
extern int PDMi_find_bominfo __PDM((char *catalog, char *part_num, char *revision, char *p_bomname, char *p_createdate));
extern int PDMverify_bomlock __PDM((char *catalog, char *partnum, char *revision));

/* ./tools/PDMbommnpl.c */
extern int PDMdelete_sub_tree __PDM((char *bom, int p_seqno));
extern int PDMrecursive_fetch __PDM((char *bom, int p_seqno, MEMptr *tree_bufr));
extern int PDMbuild_assembly __PDM((char *bom, int p_seqno, MEMptr *tree_bufr));
extern int PDMinsert_new_child __PDM((char *bom, char *n_catalogname, char *n_itemname, char *n_itemrev, char *p_orient, double p_quantity, char *p_history, char *p_childno, char *p_usageid, char *p_viewid, int p_tagno, char *p_alttagno, char *p_incbom, char *p_explode));
extern int PDMcopy_active_bom __PDM((char *active_bom, char *review_bom));
extern int PDMcopy_review_bom __PDM((char *review_bom, char *active_bom));
extern int PDMcopy_table __PDM((char *table1, char *table2));
extern int PDMcopy_abom_attachments __PDM((char *old_bom, char *new_bom, MEMptr attach_bufr, MEMptr *ret_bufr));
extern int PDMcopy_rbom_attachments __PDM((char *old_bom, char *new_bom));
extern int PDMset_attached_flag __PDM((char *bom, int p_seqno));
extern int PDMassemble_bottomup __PDM((int p_parentno, int p_level, int p_tagno, char p_childno[30 ], int p_seqno, char *bom, MEMptr *bufr));
extern int PDMaccumulate_parent __PDM((int p_no, char *bom, MEMptr *bufr));
extern int PDMverify_assembly __PDM((char *bom, MEMptr bufr, int *seqno));
extern int PDMcompare_assemblies __PDM((MEMptr bufr1, MEMptr bufr2, int *p_seqno));

/* ./tools/PDMctools.c */
extern int PDMquery_cit_members __PDM((long user_id, char *catalog, char *part, char *rev, int level, MEMptr *attr_bufr, MEMptr *ret_bufr));
extern int PDMget_catalog_name __PDM((long no, char *name));
extern int PDMget_itemname __PDM((long no, char *catalog, char *itemnum, char *itemrev));
extern int PDMopen_set_buffer __PDM((MEMptr *ret_bufr));
extern int PDMcount_cit_attachments __PDM((int p_citno, int *count));
extern int PDMcount_bom_attachments __PDM((int p_type, char *bom_name, char *n_catalogname, char *n_itemname, char *n_itemrev, int p_level, int *count));
extern int PDMget_itemname_filever __PDM((long no, char *catalog, char *itemnum, char *itemrev, int *filenum, int *filever));
extern int PDMget_max_filever __PDM((long no, char *catalog, int *filever));
extern int PDMget_filenum __PDM((long no, char *catalog, char *filename, int *filenum));
extern int PDMget_projectno __PDM((char *project_name, int *project_no));
extern int PDMget_max_filever_fname __PDM((int no, char *catalog, int filenum, int *filever));

/* ./tools/PDMdbms_f.c */
extern int PDMstop_transaction __PDM((long pdm_type));
extern int PDMstart_transaction __PDM((long pdm_type));
extern int PDMrollback_transaction __PDM((long pdm_type));

/* ./tools/PDMdyn_tbd.c */
extern int PDMi_find_maxdatatype __PDM((char *attribute, char *datatype));

/* ./tools/PDMdynamic.c */
extern int PDMi_find_maxtype __PDM((MEMptr buffer, int n, char *n_name, int *size));
extern int PDMexpand_copy_buffer __PDM((MEMptr bufr1, MEMptr bufr2, MEMptr *bufr3));
extern int PDMset_offsets __PDM((MEMptr attr_bufr, MEMptr data_bufr, MEMptr offsets_bufr));

/* ./tools/PDMpart_f.c */
extern int PDMquery_assembly_ind __PDM((char *catalog, char *n_itemname, char *n_itemrev, char *n_setindicator));
extern int PDMquery_assyind_parttype __PDM((char *catalog, char *n_itemname, char *n_itemrev, char *n_setindicator, char *p_parttype));
extern int PDMset_n_setindicator __PDM((char *catalog, char *n_itemname, char *n_itemrev, char *n_setindicator));
extern int PDMquery_catalog_partnos __PDM((char *catalog, char *n_itemname, char *n_itemrev, int *n_catalogno, int *n_itemno));
extern int PDMquery_catalogno __PDM((char *catalog, int *n_catalogno));
extern int PDMstorage_location_check __PDM((char *catalog, int n_itemnum, int *n_cisano));
extern int PDMquery_partno __PDM((char *catalog, char *part, char *rev, int *n_itemno));
extern int PDMquery_parttype __PDM((char *catalog, char *partnum, char *partrev, char *parttype));
extern int PDMset_parttype __PDM((char *catalog, char *partnum, char *partrev, char *parttype));
extern int PDMi_query_parmtype __PDM((char *family_name, char *attr_name, char *p_iotype));
extern int PDMi_get_partnum_rev __PDM((char *catalog, int n_itemno, char *part_num, char *part_rev));
extern int PDMi_get_cidate __PDM((char *catalog, char *part_num, char *part_rev, char *n_cidate, char *n_citime));
extern int PDMi_find_cofilename __PDM((char *catalog, char *part_num, char *part_rev, char *filename));
extern int PDMload_partdata __PDM((MEMptr bufr));
extern int PDMload_partnos __PDM((MEMptr bufr));
extern int PDMload_partnums __PDM((MEMptr bufr));
extern int PDMload_filenos __PDM((int p_sano, MEMptr bufr));
extern int PDMi_query_catalogname __PDM((char *catno, char *catalog));
extern int PDMi_query_partnumrev __PDM((char *catno, char *catalog, char *n_itemno, char **n_itemname, char **n_itemrev));
extern int PDMquery_table_no __PDM((char *table, int *p_tableno));
extern int PDMquery_file_status __PDM((char *catalog, char *n_itemname, char *n_itemrev, char **n_status));
extern int PDMget_part_info __PDM((MEMptr *temp_bufr));
extern int PDMget_file_names __PDM((MEMptr *temp_bufr));
extern int PDMget_part_rev_type __PDM((MEMptr *temp_bufr));
extern int PDMget_rev __PDM((MEMptr *temp_bufr));
extern int PDMcatalogs_of_proj_part __PDM((void));
extern int PDMget_ems_files __PDM((MEMptr *temp_bufr, MEMptr *temp_bufr1));
extern long PDMval_part_for_copy __PDM((char *n_catalogname, int n_itemno));
extern int PDMi_get_partnum_rev_desc __PDM((char *catalog, int n_itemno, char *part_num, char *part_rev, char *part_desc));
extern int PDMi_get_partnum_rev_type __PDM((char *catalog, int n_itemno, char *part_num, char *part_rev, char *part_type));
extern int PDMload_partno_filename __PDM((MEMptr bufr));
extern int PDMget_storageno __PDM((char *strg_name, int *sano));

/* ./tools/PDMrefresh.c */
extern int PDMverify_catalog __PDM((MEMptr *return_buffer));
extern int PDMi_verify_catalog __PDM((char *catalog));
extern int PDMverify_part __PDM((char *catalog, char *partnum, char *revision));
extern int PDMquery_part_status __PDM((void));
extern int PDMsshow_catalogs __PDM((MEMptr bufr, MEMptr *temp_bufr));
extern int PDMshow_parts __PDM((MEMptr *bufr));
extern int PDMs_sql_query __PDM((MEMptr bufr, MEMptr *return_buffer));
extern int PDMs_sql_distinct __PDM((MEMptr bufr, MEMptr *return_buffer));
extern int PDMcatalogs_in_project __PDM((MEMptr *temp_bufr));
extern int PDMprojects_of_catalog __PDM((MEMptr *temp_bufr));
extern int PDMlist_of_projects __PDM((MEMptr *temp_bufr));
extern int PDMsverify_project __PDM((void));
extern int convert_toupper __PDM((char *string, char *string1));
extern int PDMparts_of_catalog __PDM((MEMptr *bufr));
extern int PDMget_desc __PDM((MEMptr *bufr));
extern int PDMget_state_name __PDM((MEMptr *bufr));
extern int PDMshow_catalog_acls __PDM((MEMptr *return_buffer));
extern int PDMget_part_type_desc __PDM((MEMptr *bufr));
extern int PDMsget_catno_partno __PDM((MEMptr *ret_bufr));
extern int PDMcheck_part_status __PDM((void));

/* ./tools/PDMreport_f.c */
extern int PDMappend_10_buffers __PDM((MEMptr *ret_bufr, MEMptr b1, MEMptr b2, MEMptr b3, MEMptr b4, MEMptr b5, MEMptr b6, MEMptr b7, MEMptr b8, MEMptr b9, MEMptr b10));
extern int PDMsplit_10_buffers __PDM((MEMptr ws_buffer, MEMptr *b1, MEMptr *b2, MEMptr *b3, MEMptr *b4, MEMptr *b5, MEMptr *b6, MEMptr *b7, MEMptr *b8, MEMptr *b9, MEMptr *b10));
extern int PDMsplit_16_buffers __PDM((MEMptr ws_buffer, MEMptr *b1, MEMptr *b2, MEMptr *b3, MEMptr *b4, MEMptr *b5, MEMptr *b6, MEMptr *b7, MEMptr *b8, MEMptr *b9, MEMptr *b10, MEMptr *b11, MEMptr *b12, MEMptr *b13, MEMptr *b14, MEMptr *b15, MEMptr *b16));
extern int PDMappend_16_buffers __PDM((MEMptr *ret_bufr, MEMptr b1, MEMptr b2, MEMptr b3, MEMptr b4, MEMptr b5, MEMptr b6, MEMptr b7, MEMptr b8, MEMptr b9, MEMptr b10, MEMptr b11, MEMptr b12, MEMptr b13, MEMptr b14, MEMptr b15, MEMptr b16));

/* ./tools/PDMstools1.c */
extern int PDMget_cwd __PDM((char **cwd));
extern int PDMi_get_date __PDM((char *c_date, char *c_time));
extern int PDMget_date_time __PDM((char *current_date, char *current_time, char *delimiter, int format_flag));
extern int PDMcheck_for_double_quotes __PDM((char *s1, char *s2));
extern int PDMgen_bomtable_name __PDM((char *temp_table));
extern int PDMgen_table_name __PDM((char *temp_table));
extern int PDMgen_file_name __PDM((char *file_name));
extern int PDMcreate_ris_table __PDM((char *table_name, MEMptr bufr1, MEMptr bufr2, MEMptr bufr3));
extern int PDMquery_cit_attachment __PDM((long p_citno, char *p_attached));
extern int PDMquery_bom_attachment __PDM((char *review_bom, char *n_itemname, char *n_itemrev, char *catalog, int level, char *p_attached));
extern int PDMi_delete_rows __PDM((MEMptr buffer, char *table_name, int n));
extern int PDMi_query_passwd __PDM((char *username, char *passwd));
extern int PDMi_delete_fileno __PDM((char *p_fileno));
extern int PDMi_delete_partnum __PDM((char *n_itemname));
extern int PDMcofilename __PDM((char *cofilename));
extern int PDMcheck_for_autofilename __PDM((char *cat));

/* ./tools/PDMstools2.c */
extern int PDMi_find_nodeno __PDM((char *n_nodename, int *n_nodeno));
extern int PDMi_find_partnum __PDM((int n_catalogno, int n_itemno, int *n_itemname));
extern int PDMi_find_fileno __PDM((int n_itemname, int p_sano, int *p_fileno));
extern int PDMi_find_filenos __PDM((int n_itemname, int p_sano, MEMptr *bufr));
extern int PDMi_find_references __PDM((int n_itemname, int p_sano, int *p_ref1, int *p_ref2));
extern int PDMi_find_allrefs __PDM((int n_itemname, int p_sano, int *p_ref1, int *p_ref2));
extern int PDMi_update_references __PDM((int n_itemname, int p_sano, int p_type));
extern int PDMi_next_negativeno __PDM((char *table, int *p_citno));
extern int PDMi_find_sano __PDM((int n_nodeno, char *n_username, char *n_pathname, int *n_sano));
extern int PDMi_copy_format __PDM((MEMptr bufr1, MEMptr *bufr2));
extern int PDMi_compare_dates __PDM((char *date1, char *date2));
extern int PDMi_update_attachments __PDM((int n_itemname, int p_sano));
extern int PDMsano_to_name __PDM((int n_sano, char *p_local));
extern int PDMcheck_to_update __PDM((void));
extern int PDMupdate_to_define __PDM((void));

/* ./tools/PDMtable_f.c */
extern int PDMi_find_tablename __PDM((char *catalog, char *part_num, char *revision, char *p_tabletype, char *p_tablename));
extern int PDMi_find_tableinfo __PDM((char *catalog, char *part_num, char *revision, char *p_tabletype, char *p_tablename, char *p_createdate));
extern int PDMi_insert_pdmtables __PDM((char *catalog, char *part_num, char *revision, char *p_tabletype, char *p_tablename));
extern int PDMget_ris_datatype __PDM((char *table_name, char *column_name, char *type));
extern int PDMi_delete_from_pdmtables __PDM((char *catalog, char *part_num, char *revision, char *p_tabletype, char *p_tablename));

/* ./tools/PDMwf_acl.c */
extern int PDMget_commandno __PDM((char *command, int *command_no));

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
