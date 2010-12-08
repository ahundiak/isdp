#ifndef PDMS_BOM_PRO_H
#define PDMS_BOM_PRO_H

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

/* ./bom/PDMactive.c */
extern int PDMXupdate_exist_bom __PDMS((char *bom_name));
extern int PDMXXXXXXupdate_exist_bom __PDMS((MEMptr *ret_bufr));

/* ./bom/PDMbom.c */
extern int PDMsmodify_bom_content __PDMS((MEMptr attr_bufr, MEMptr data_bufr, MEMptr list_bufr, MEMptr bommap_bufr));
extern int PDMsget_bommap_attributes __PDMS((MEMptr *attr_bufr));
extern int PDMmodify_attribute_buffer __PDMS((MEMptr nfm_bufr, MEMptr *attr_bufr));
extern int PDMmodify_dynamic_buffer __PDMS((MEMptr pdu_bufr, MEMptr *attr_bufr));
extern int PDMchange_attr_data __PDMS((long user_id, MEMptr pdu_bufr, char *pdc_tbl, MEMptr *attr_bufr, MEMptr *data_bufr, MEMptr *value_bufr));
extern int PDMmodify_template_buffer __PDMS((MEMptr nfm_bufr, MEMptr *attr_bufr));
extern int PDMupdate_data_buffer __PDMS((MEMptr *data_buffer, MEMptr attr_buffer));

/* ./bom/PDMbom_CID.c */
extern int _PDMget_cat_bom_vals_for_CID_part __PDMS((int catno, char *catalog, char *partnum, char *revision, int item_no, char *qry_list, int pdcno, char *dyncat, char **stat_data_str, char **stat_attr_str, MEMptr bom_attr_bufr, char *Itemdesc, char **Altpartno));
extern int PDMbom_get_view_data __PDMS((char *catalog, char *qry_list, char **where_cls, MEMptr *out_bufr));
extern int PDMbom_calc_itemdesc_n_insert __PDMS((char *catalog, int catno, int itemno, char **where_str, char *Itemdesc));
extern int PDMbom_calc_itemdesc_n_insert_for_dinpart __PDMS((char *catalog, int catno, char *part_num, int itemno, int pdcno, char *dyncat, char **where_str, char *Itemdesc));

/* ./bom/PDMbom_assy.c */
extern long PDMretrieve_members_for_bom __PDMS((struct NFMmembers *members_list, int count, int level, int curr_level, struct PDMbom_member *set_head, struct PDMbom_member *set_end, int *num_members));
extern int PDMget_bom_members __PDMS((int catno, int partno, int level, struct PDMbom_member **set_head, struct PDMbom_member **set_end, int *nch));
extern long PDMdfs_retrieve_members_for_bom __PDMS((int pcat_no, int pitem_no, int level, int curr_level, struct PDMbom_member *set_head, struct PDMbom_member *set_end, int *num_members));
extern long PDMbom_check_assy_cycle __PDMS((long p_cat_no, long p_item_no, long c_cat_no, long c_item_no));
extern long PDMbom_check_ancestor_loop __PDMS((MEMptr par_list, int cat_no, int item_no));
extern long PDMGetAssyStrForSummBom __PDMS((int pcat_no, int pitem_no, int level, int curr_level, struct PDMbom_member *set_head, struct PDMbom_member *set_end, int *num_members));
extern int PDMGetAssyForEngBom __PDMS((int catno, int partno, int level, struct PDMbom_member **set_head, struct PDMbom_member **set_end, int *nch));

/* ./bom/PDMbom_attr.c */
extern int PDMget_bom_attrs __PDMS((MEMptr *attr_bufr, MEMptr *data_bufr));
extern int PDMget_bom_map_attrs __PDMS((char *cat_list, MEMptr *attr_bufr, MEMptr *data_bufr, struct PDMbom_member **link_head, struct PDMbom_member **link_end, MEMptr *map_bufr, MEMptr *cattr_bufr));
extern int PDMget_new_bom_attr_bufr __PDMS((MEMptr *attr_bufr, MEMptr *data_bufr, MEMptr cattr_bufr, struct PDMbom_member **link_head, struct PDMbom_member **link_end, MEMptr *attr1_bufr));
extern int _PDMcreate_bom_attr_bufr __PDMS((MEMptr *attr1_bufr));
extern int _PDMload_bom_attr_bufr __PDMS((MEMptr *attr_bufr, MEMptr *data_bufr, MEMptr cattr_bufr, struct PDMbom_member *head, MEMptr *attr1_bufr));
extern int _PDMload_sel_strs __PDMS((MEMptr *attr_bufr, MEMptr *attr1_bufr, struct PDMbom_member *head, struct PDMbom_member *end));
extern int _PDMget_sel_str __PDMS((char **sel_str, char **insert_str, char **dyn_sel_str, char **dyn_insert_str, char *catalog, int cat_no, int dyn_catno, MEMptr attr_bufr, MEMptr cattr_bufr));
extern int PDMget_new_map_bom_attr_bufr __PDMS((MEMptr map_bufr, MEMptr *attr_bufr, MEMptr *data_bufr, MEMptr cattr_bufr, struct PDMbom_member **link_head, struct PDMbom_member **link_end, MEMptr *attr1_bufr));
extern int _PDMget_map_sel_str __PDMS((char **sel_str, char **insert_str, char **dyn_sel_str, char **dyn_insert_str, char *catalog, int cat_no, int dyn_catno, MEMptr attr1_bufr, MEMptr cattr_bufr));
extern int _PDMload_bom_map_attr_bufr __PDMS((MEMptr *attr_bufr, MEMptr *data_bufr, MEMptr cattr_bufr, struct PDMbom_member *head, MEMptr *attr1_bufr, MEMptr map_bufr));
extern int _PDMXcreate_map_bufr __PDMS((MEMptr qry_bufr, MEMptr qry_bufr1, MEMptr *tmp_bufr));
extern int _PDMcreate_map_bufr __PDMS((MEMptr pdm_bom_bufr, MEMptr attrnames_bufr, MEMptr *tmp_bufr));
extern int _PDMupdate_catnos_in_llist __PDMS((struct PDMbom_member **set_head, struct PDMbom_member **set_end, int nch));
extern int _PDMbom_load_cattype_in_ll __PDMS((char *cat_list, struct PDMbom_member **set_head));

/* ./bom/PDMbom_parst.c */
extern int PDMload_dyn_catname_no __PDMS((struct PDMbom_member *set_head, struct PDMbom_member *set_end, int num_members));
extern int _PDMget_alternate_parentname __PDMS((int row_no, char *dyn_cat_name, char *alt_attr, char *alt_parent));
extern long PDMdfs_retrieve_alt_bom_struct __PDMS((struct PDMbom_member *set_head, struct PDMbom_member *set_end, char *alt_parent, int level, int curr_level, struct PDMbom_member *alt_head, struct PDMbom_member *alt_end));
extern int _PDMcopy_bom_llist __PDMS((struct PDMbom_member *set_mem, struct PDMbom_member *alt_mem));
extern int _PDMcheck_duplicate_parent __PDMS((struct PDMbom_member *cat_head, int citno, int *duplicate));
extern int PDMget_alt_bom_members __PDMS((int catno, int partno, int level, struct PDMbom_member **set_head, struct PDMbom_member **set_end, int *nch, char *alt_parent_attr));

/* ./bom/PDMbomrtns.c */
extern int PDMcreate_temp_table __PDMS((char *temp_table));
extern int PDMload_temp_table __PDMS((char *temp_table, MEMptr set_bufr));
extern int PDMcreate_bom_table1 __PDMS((char *temp_table));
extern int PDMjoin_cits __PDMS((char *temp_table, MEMptr *join_bufr));
extern int PDMload_bom_table1 __PDMS((long user_id, char *bom_table, MEMptr join_bufr));
extern int PDMcreate_bom_table __PDMS((long uid, char *temp_table));
extern int PDMload_bom_table __PDMS((long user_id, char *bom_table, MEMptr join_bufr, MEMptr cat_attr, char *cat_str, MEMptr usr_attr, char *usr_str, MEMptr set_bufr));
extern int PDMupdate_bom_attributes __PDMS((long user_id, char *bom_table, MEMptr cat_attr, char *cat_str, MEMptr usr_attr, char *usr_str));
extern int PDMget_bom_attrbs __PDMS((long user_id, MEMptr *cat_attr, MEMptr *cit_attr, MEMptr *usr_attr));
extern int PDMquery_load_members __PDMS((long user_id, char *bom_temp, char *temp_table, long no1, long no2, int a1, int a2, int a3, int a4, int *members));
extern int PDMbuild_select_string __PDMS((long user_id, MEMptr cat_attr, MEMptr usr_attr, char *catalog, char *part_num, char *part_rev, int *map_row_size, char **sql_str, MEMptr *usr_bufr));
extern int PDMbuild_attribute_string __PDMS((MEMptr cat_attr, char **cat_str, int *size));
extern int PDMmap_user_attributes __PDMS((long user_id, char *catalog, MEMptr *map_attr, MEMptr *usr_bufr));
extern int PDMupdatebom_tagnos __PDMS((char *bom, char *old_bom));
extern int PDMactive_carry_tagnos __PDMS((char *bom, MEMptr child_bufr));
extern int PDMreview_carry_tagnos __PDMS((char *bom, MEMptr child_bufr));
extern int PDMcreate_join_buffer __PDMS((MEMptr set_bufr, MEMptr *join_bufr));
extern int NFMquery_set_members1 __PDMS((long user_id, char *catalog, char *part_num, char *revision, long qry_level, MEMptr *attr_bufr, MEMptr *data_bufr));
extern int PDMstructure_bom __PDMS((char *t1, char *t1_str, char *t2, char *attr_str, MEMptr cat_attr, MEMptr cit_attr, MEMptr usr_attr, MEMptr bufr));
extern int PDMxyz __PDMS((MEMptr *cat_attr));
extern int PDMreview_child_tags __PDMS((int pp_partno, int p_tagno, char *p_alttagno));
extern int PDMactive_child_tags __PDMS((char *bom, int p_parentno, int n_level, char *p_childno, int p_tagno, char *p_alttagno));

/* ./bom/PDMgen_bom.c */
extern int PDMupdate_exist_bom __PDMS((char *exist1_bom));
extern int _PDMget_cat_bom_vals __PDMS((int catno, char *catalog, char *cattype, int dyn_catno, char *dyn_catname, char *partnum, char *revision, int item_no, int pdcno, char *qry_list, char *dyn_qry_list, char **stat_data_str, char **stat_attr_str, char **dyn_data_str, char **dyn_attr_str, MEMptr bom_attr_bufr, char *Itemdesc, char **Altpartno));
extern int _PDMrollback_pdmboms __PDMS((int cat_no, int item_no, char *exist_bom));
extern int PDMadd_rows_to_bom __PDMS((MEMptr *attr_bufr, MEMptr *data_bufr, struct PDMbom_member *head));
extern int _PDMorig_get_cat_bom_vals __PDMS((char **dyn_val_str, char **insert_attr_str, char **stat_val_str, char *qry_list, char *dyn_qry_list, int item_no, int pdcno, int catno, char *catalog, char *dyn_catname));
extern int _PDMget_altpartno_from_tab_dyntab __PDMS((char *catalog, int type, int itemno, char *dyn_catname, int pdcno, char *where_cls, char *altpartno));

/* ./bom/PDMreview.c */
extern int PDMgenerate_review_bom __PDMS((MEMptr *bufr));

/* ./bom/PDMxsum_rps.c */
extern int  PDMgen_explode_summary_bom    __PDMS((MEMptr *ret_bufr));
extern int  PDMi_setup_explode_summ_table __PDMS((char *bom, int req_level, char *table_name));
extern int  PDMOLDget_exp_summ_bufr       __PDMS((char *bom, MEMptr *bufr, int max_level));
extern int  PDMget_exp_summ_bufr          __PDMS((char *BomName, MEMptr AttrBufr, MEMptr *bufr, int max_level));
extern int _PDMload_exp_summ_bufr         __PDMS((char *BomName, int pcatno, int ppartno, int curr_level, char *SelStr, MEMptr *exp_bufr));
extern int _PDMnewold_load_exp_summ_bufr  __PDMS((MEMptr bom_bufr, MEMptr *exp_bufr, int curr_level));
extern int  PDMGetBomAttrBufr             __PDMS((char *bomname, MEMptr *AttrBufr));
extern int  PDMGetAssyStrNUpdateBomBufr   __PDMS((int catno, int partno, char *BomTable, MEMptr AttrBufr, MEMptr *InsertBufr));

#if defined(__cplusplus)
}
#endif

#endif
