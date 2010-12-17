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

/* ./bom/PDMactive.c */
extern int PDMXupdate_exist_bom __PDM((char *bom_name));
extern int PDMXXXXXXupdate_exist_bom __PDM((MEMptr *ret_bufr));

/* ./bom/PDMbom.c */
extern int PDMsmodify_bom_content __PDM((MEMptr attr_bufr, MEMptr data_bufr, MEMptr list_bufr, MEMptr bommap_bufr));
extern int PDMsget_bommap_attributes __PDM((MEMptr *attr_bufr));
extern int PDMmodify_attribute_buffer __PDM((MEMptr nfm_bufr, MEMptr *attr_bufr));
extern int PDMmodify_dynamic_buffer __PDM((MEMptr pdu_bufr, MEMptr *attr_bufr));
extern int PDMchange_attr_data __PDM((long user_id, MEMptr pdu_bufr, char *pdc_tbl, MEMptr *attr_bufr, MEMptr *data_bufr, MEMptr *value_bufr));
extern int PDMmodify_template_buffer __PDM((MEMptr nfm_bufr, MEMptr *attr_bufr));
extern int PDMupdate_data_buffer __PDM((MEMptr *data_buffer, MEMptr attr_buffer));
extern int PDMadd_buffer_string __PDM((char *buff_string, int *position, char *char_string));

/* ./bom/PDMbom_assy.c */
extern long PDMretrieve_members_for_bom __PDM((struct NFMmembers *members_list, int count, int level, int curr_level, struct PDMbom_member *set_head, struct PDMbom_member *set_end, int *num_members));
extern void _PDMprint_bommember __PDM((char *name, struct PDMbom_member *mem));
extern void _PDMprint_bommember_info __PDM((char *name, struct PDMbom_member *mem));
extern int PDMget_bom_members __PDM((int catno, int partno, int level, struct PDMbom_member **set_head, struct PDMbom_member **set_end, int *nch));
extern long PDMXdfs_retrieve_members_for_bom __PDM((int pcat_no, int pitem_no, int level, int curr_level, struct PDMbom_member *set_head, struct PDMbom_member **set_end, int *num_members));
extern long PDMXXdfs_retrieve_members_for_bom __PDM((int pcat_no, int pitem_no, int level, int curr_level, struct PDMbom_member *set_head, struct PDMbom_member *set_end, int *num_members));
extern long PDMdfs_retrieve_members_for_bom __PDM((int pcat_no, int pitem_no, int level, int curr_level, struct PDMbom_member *set_head, struct PDMbom_member *set_end, int *num_members));

/* ./bom/PDMbom_attr.c */
extern int PDMget_bom_attrs __PDM((MEMptr *attr_bufr, MEMptr *data_bufr));
extern int PDMget_bom_map_attrs __PDM((char *cat_list, MEMptr *attr_bufr, MEMptr *data_bufr, struct PDMbom_member **link_head, struct PDMbom_member **link_end, MEMptr *map_bufr, MEMptr *cattr_bufr));
extern int PDMget_new_bom_attr_bufr __PDM((MEMptr *attr_bufr, MEMptr *data_bufr, MEMptr cattr_bufr, struct PDMbom_member **link_head, struct PDMbom_member **link_end, MEMptr *attr1_bufr));
extern int _PDMcreate_bom_attr_bufr __PDM((MEMptr *attr1_bufr));
extern int _PDMload_bom_attr_bufr __PDM((MEMptr *attr_bufr, MEMptr *data_bufr, MEMptr cattr_bufr, struct PDMbom_member *head, MEMptr *attr1_bufr));
extern int _PDMload_sel_strs __PDM((MEMptr *attr_bufr, MEMptr *attr1_bufr, struct PDMbom_member *head, struct PDMbom_member *end));
extern int _PDMget_sel_str __PDM((char **sel_str, char **insert_str, char **dyn_sel_str, char **dyn_insert_str, char *catalog, int cat_no, int dyn_catno, MEMptr attr_bufr, MEMptr cattr_bufr));
extern int PDMget_new_map_bom_attr_bufr __PDM((MEMptr map_bufr, MEMptr *attr_bufr, MEMptr *data_bufr, MEMptr cattr_bufr, struct PDMbom_member **link_head, struct PDMbom_member **link_end, MEMptr *attr1_bufr));
extern int _PDMget_map_sel_str __PDM((char **sel_str, char **insert_str, char **dyn_sel_str, char **dyn_insert_str, char *catalog, int cat_no, int dyn_catno, MEMptr attr1_bufr, MEMptr cattr_bufr));
extern int _PDMload_bom_map_attr_bufr __PDM((MEMptr *attr_bufr, MEMptr *data_bufr, MEMptr cattr_bufr, struct PDMbom_member *head, MEMptr *attr1_bufr, MEMptr map_bufr));
extern int _PDMXcreate_map_bufr __PDM((MEMptr qry_bufr, MEMptr qry_bufr1, MEMptr *tmp_bufr));
extern int _PDMcreate_map_bufr __PDM((MEMptr pdm_bom_bufr, MEMptr attrnames_bufr, MEMptr *tmp_bufr));
extern int _PDMXXget_map_sel_str __PDM((char **sel_str, char **insert_str, char *catalog, MEMptr *attr_bufr, MEMptr attr1_bufr, int cat_no));

/* ./bom/PDMbomrtns.c */
extern int PDMcreate_temp_table __PDM((char *temp_table));
extern int PDMload_temp_table __PDM((char *temp_table, MEMptr set_bufr));
extern int PDMcreate_bom_table1 __PDM((char *temp_table));
extern int PDMjoin_cits __PDM((char *temp_table, MEMptr *join_bufr));
extern int PDMload_bom_table1 __PDM((long user_id, char *bom_table, MEMptr join_bufr));
extern int PDMcreate_bom_table __PDM((long uid, char *temp_table));
extern int PDMload_bom_table __PDM((long user_id, char *bom_table, MEMptr join_bufr, MEMptr cat_attr, char *cat_str, MEMptr usr_attr, char *usr_str, MEMptr set_bufr));
extern int PDMupdate_bom_attributes __PDM((long user_id, char *bom_table, MEMptr cat_attr, char *cat_str, MEMptr usr_attr, char *usr_str));
extern int PDMget_bom_attrbs __PDM((long user_id, MEMptr *cat_attr, MEMptr *cit_attr, MEMptr *usr_attr));
extern int PDMquery_load_members __PDM((long user_id, char *bom_temp, char *temp_table, long no1, long no2, int a1, int a2, int a3, int a4, int *members));
extern int PDMappend __PDM((MEMptr *bufr, MEMptr bufr1));
extern int PDMbuild_select_string __PDM((long user_id, MEMptr cat_attr, MEMptr usr_attr, char *catalog, char *part_num, char *part_rev, int *map_row_size, char **sql_str, MEMptr *usr_bufr));
extern int PDMbuild_attribute_string __PDM((MEMptr cat_attr, char **cat_str, int *size));
extern int PDMmap_user_attributes __PDM((long user_id, char *catalog, MEMptr *map_attr, MEMptr *usr_bufr));
extern int PDMupdatebom_tagnos __PDM((char *bom, char *old_bom));
extern int PDMactive_carry_tagnos __PDM((char *bom, MEMptr child_bufr));
extern int PDMreview_carry_tagnos __PDM((char *bom, MEMptr child_bufr));
extern int PDMcreate_join_buffer __PDM((MEMptr set_bufr, MEMptr *join_bufr));
extern int NFMquery_set_members1 __PDM((long user_id, char *catalog, char *part_num, char *revision, long qry_level, MEMptr *attr_bufr, MEMptr *data_bufr));
extern int PDMstructure_bom __PDM((char *t1, char *t1_str, char *t2, char *attr_str, MEMptr cat_attr, MEMptr cit_attr, MEMptr usr_attr, MEMptr bufr));
extern int PDMxyz __PDM((MEMptr *cat_attr));
extern int PDMreview_child_tags __PDM((int pp_partno, int p_tagno, char *p_alttagno));
extern int PDMactive_child_tags __PDM((char *bom, int p_parentno, int n_level, char *p_childno, int p_tagno, char *p_alttagno));

/* ./bom/PDMgen_bom.c */
extern int PDMupdate_exist_bom __PDM((char *exist1_bom));
extern int _PDMget_cat_bom_vals __PDM((char **indata_str, char **attrx_str, char *qry_list, char *dyn_qry_list, int item_no, int pdcno, int catno, char *catalog, char *dyn_catname));
extern int _PDMupdate_pdmboms __PDM((int cat_no, int item_no, char *exist_bom));
extern int _PDMrollback_pdmboms __PDM((int cat_no, int item_no, char *exist_bom));
extern int PDMadd_rows_to_bom __PDM((MEMptr *attr_bufr, MEMptr *data_bufr, struct PDMbom_member *head));

/* ./bom/PDMreview.c */
extern int PDMgenerate_review_bom __PDM((MEMptr *bufr));
extern int PDMconvert_to_lower __PDM((char *string, char *string1));

/* ./bom/PDMxsum_rps.c */
extern int PDMgen_explode_summary_bom __PDM((MEMptr *ret_bufr));
extern int PDMgen_xplode_summary_bom __PDM((MEMptr *return_buffer));
extern int _PDMi_get_dyn_catname __PDM((int catno, char *y_catname));
extern int PDMi_setup_explode_summ_table __PDM((char *bom, int req_level, char *table_name));
extern int PDMget_exp_summ_bufr __PDM((char *bom, MEMptr *bufr, int max_level));
extern int _PDMold_load_exp_summ_bufr __PDM((MEMptr qry_bufr, MEMptr *exp_bufr, int curr_level));
extern int _PDMload_exp_summ_bufr __PDM((MEMptr bom_bufr, MEMptr *exp_bufr, int curr_level));

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
