#ifndef PDMS_RIS_PRO_H
#define PDMS_RIS_PRO_H

/* ===================================================
 * 08 Dev 2010
 * Cannot seem to find MRPcoumn stuff anywhere
 * Skip for now
 */
#if 0
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

/* ./ris/PDMrs_bom.c */
extern int PSUrs_get_pitemno __PDMS((int *p_itemno));
extern int PSUrs_get_bomname __PDMS((int pitemno, char *bomname));

/* ./ris/PDMrs_bom.rc */
extern int PSUrs_get_pitemno __PDMS((int *p_itemno));
extern int PSUrs_get_bomname __PDMS((int pitemno, char *bomname));

/* ./ris/PDMrs_cat.c */
extern int rMRPrs_free_values __PDMS((struct rMRPcolumn_info *column_info, int number_of_rows, int number_of_cols));
extern int MRPrs_get_catno __PDMS((void));
extern int MRPrs_mk_elect_cat __PDMS((void));
extern int rMRPrs_in_nfmcat __PDMS((void));
extern int rMRPrs_mk_cat_tab __PDMS((int catlst, char *catalog));
extern int rMRPrs_create_tab __PDMS((char *catalog, struct rMRPattr rmrpattr));
extern int rMRPrs_alter_tab __PDMS((char *catalog, struct rMRPattr rmrpattr));
extern int rMRPrs_get_nfmattrs_pdmcat __PDMS((void));
extern int rMRPrs_fill_nfmattr_values __PDMS((int cattype, struct rMRPcolumn_info *rmrpcolumn_info));
extern int rMRPrs_fill_nfmattr_rows __PDMS((struct rMRPcolumn_info *rmrpcolumn_info));

/* ./ris/PDMrs_cat.rc */
extern int rMRPrs_free_values __PDMS((struct rMRPcolumn_info *column_info, int number_of_rows, int number_of_cols));
extern int MRPrs_get_catno __PDMS((void));
extern int MRPrs_mk_elect_cat __PDMS((void));
extern int rMRPrs_in_nfmcat __PDMS((void));
extern int rMRPrs_mk_cat_tab __PDMS((int catlst, char *catalog));
extern int rMRPrs_create_tab __PDMS((char *catalog, struct rMRPattr rmrpattr));
extern int rMRPrs_alter_tab __PDMS((char *catalog, struct rMRPattr rmrpattr));
extern int rMRPrs_get_nfmattrs_pdmcat __PDMS((void));
extern int rMRPrs_fill_nfmattr_values __PDMS((int cattype, struct rMRPcolumn_info *rmrpcolumn_info));
extern int rMRPrs_fill_nfmattr_rows __PDMS((struct rMRPcolumn_info *rmrpcolumn_info));

/* ./ris/PDMrs_fmgr.c */
extern int PDMris_get_fmgr __PDMS((int catno, int partno, int sano, char *move_date, char *move_time, int *p_ref2, int *p_partnum));
extern int PDMris_find_references __PDMS((int p_partnum, int n_sano, int *p_ref1, int *p_ref2));
extern int PDMris_get_sano __PDMS((char *saname, int *sano));

/* ./ris/PDMrs_fmgr.rc */
extern int PDMris_get_fmgr __PDMS((int catno, int partno, int sano, char *move_date, char *move_time, int *p_ref2, int *p_partnum));
extern int PDMris_find_references __PDMS((int p_partnum, int n_sano, int *p_ref1, int *p_ref2));
extern int PDMris_get_sano __PDMS((char *saname, int *sano));

/* ./ris/PDMrs_rpt.c */
extern int PSUrs_cre_rpt __PDMS((struct PSUrpt *psurpt, char *schemaname, char *schemapwd));
extern int PSUrs_load_rpt __PDMS((struct PSUrpt *psurpt));
extern int PSUrs_cre_rtabs __PDMS((void));
extern int PSUrs_get_tempno __PDMS((struct PSUrpt *psurpt, int *tempno, int tmptype));
extern int PSUrs_update_rpt __PDMS((struct PSUrpt *psurpt));
extern int PSUrs_insert_rpt __PDMS((struct PSUrpt *psurpt));
extern int PSUrs_insert_rptlst __PDMS((struct PSUrpt *psurpt, int row, int tempno));
extern int PSUrs_load_rptlst __PDMS((struct PSUrpt *psurpt));
extern int PSUrs_load_rptopt __PDMS((struct PSUrpt *psurpt));

/* ./ris/PDMrs_rpt.rc */
extern int PSUrs_cre_rpt __PDMS((struct PSUrpt *psurpt, char *schemaname, char *schemapwd));
extern int PSUrs_load_rpt __PDMS((struct PSUrpt *psurpt));
extern int PSUrs_cre_rtabs __PDMS((void));
extern int PSUrs_get_tempno __PDMS((struct PSUrpt *psurpt, int *tempno, int tmptype));
extern int PSUrs_update_rpt __PDMS((struct PSUrpt *psurpt));
extern int PSUrs_insert_rpt __PDMS((struct PSUrpt *psurpt));
extern int PSUrs_insert_rptlst __PDMS((struct PSUrpt *psurpt, int row, int tempno));
extern int PSUrs_load_rptlst __PDMS((struct PSUrpt *psurpt));
extern int PSUrs_load_rptopt __PDMS((struct PSUrpt *psurpt));

/* ./ris/PDMrs_tool.c */
extern int PDMris_get_catno __PDMS((char *catalog, int *catno));
extern int PDMris_get_projectno __PDMS((char *project, int *projectno));
extern int PDMris_get_catname __PDMS((int catno, char *catalog, char *type));
extern int PDMload_catno __PDMS((char *catalog));
extern int PDMload_fcatno __PDMS((char *catalog));
extern int PDMris_maxrow_no __PDMS((char *table, char *attr_name, int *maxrow));
extern int PDMris_get_pitemno __PDMS((int *p_itemno, char *catalog, char *partid, char *revision));
extern int PDMris_get_tableno __PDMS((char *catalog, int *catno));
extern int PDMris_max_childno __PDMS((int p_catno, int p_itemno, int level, int p_pchildno, int *p_childno));
extern int PDMris_max_tempchildno __PDMS((int p_catno, int p_itemno, int level, int p_pchildno, char *temp_table, int *p_childno));
extern int PDMget_assembly_ind __PDMS((char *catalog, int itemname, int itemrev, char *n_setindicator));
extern int PDMris_get_userno __PDMS((char *user, int *userno));
extern int PDMris_get_catnodesc __PDMS((int catno, char *catalog, char *catdesc));
extern long PDMquery __PDMS((char *ris_query, int *rows, char **out_arr, int *err_code, char delim_flag));
extern int PDMris_stmt __PDMS((char *sql, int *err_code));
extern int PDMget_catno_type __PDMS((char *catalog, int *catno, char *type));
extern int PDMquery_stateno __PDMS((char *catalog, char *part, char *rev, char *statename));

/* ./ris/PDMrs_tool.rc */
extern int PDMris_get_catno __PDMS((char *catalog, int *catno));
extern int PDMris_get_projectno __PDMS((char *project, int *projectno));
extern int PDMris_get_catname __PDMS((int catno, char *catalog, char *type));
extern int PDMload_catno __PDMS((char *catalog));
extern int PDMload_fcatno __PDMS((char *catalog));
extern int PDMris_maxrow_no __PDMS((char *table, char *attr_name, int *maxrow));
extern int PDMris_get_pitemno __PDMS((int *p_itemno, char *catalog, char *partid, char *revision));
extern int PDMris_get_tableno __PDMS((char *catalog, int *catno));
extern int PDMris_max_childno __PDMS((int p_catno, int p_itemno, int level, int p_pchildno, int *p_childno));
extern int PDMris_max_tempchildno __PDMS((int p_catno, int p_itemno, int level, int p_pchildno, char *temp_table, int *p_childno));
extern int PDMget_assembly_ind __PDMS((char *catalog, int itemname, int itemrev, char *n_setindicator));
extern int PDMris_get_userno __PDMS((char *user, int *userno));
extern int PDMris_get_catnodesc __PDMS((int catno, char *catalog, char *catdesc));
extern long PDMquery __PDMS((char *ris_query, int *rows, char **out_arr, int *err_code, char delim_flag));
extern int PDMris_stmt __PDMS((char *sql, int *err_code));
extern int PDMget_catno_type __PDMS((char *catalog, int *catno, char *type));
extern int PDMquery_stateno __PDMS((char *catalog, char *part, char *rev, char *statename));

/* ./ris/SQLqry.c */
extern long PDMSQLquery __PDMS((char *sql_str, MEMptr *list, long size));

/* ./ris/SQLqry.rc */
extern long PDMSQLquery __PDMS((char *sql_str, MEMptr *list, long size));

/* ./ris/PDMrs_bom.rc */
extern int PSUrs_get_pitemno __PDMS((int *p_itemno));
extern int PSUrs_get_bomname __PDMS((int pitemno, char *bomname));

/* ./ris/PDMrs_cat.rc */
extern int rMRPrs_free_values __PDMS((struct rMRPcolumn_info *column_info, int number_of_rows, int number_of_cols));
extern int MRPrs_get_catno __PDMS((void));
extern int MRPrs_mk_elect_cat __PDMS((void));
extern int rMRPrs_in_nfmcat __PDMS((void));
extern int rMRPrs_mk_cat_tab __PDMS((int catlst, char *catalog));
extern int rMRPrs_create_tab __PDMS((char *catalog, struct rMRPattr rmrpattr));
extern int rMRPrs_alter_tab __PDMS((char *catalog, struct rMRPattr rmrpattr));
extern int rMRPrs_get_nfmattrs_pdmcat __PDMS((void));
extern int rMRPrs_fill_nfmattr_values __PDMS((int cattype, struct rMRPcolumn_info *rmrpcolumn_info));
extern int rMRPrs_fill_nfmattr_rows __PDMS((struct rMRPcolumn_info *rmrpcolumn_info));

/* ./ris/PDMrs_fmgr.rc */
extern int PDMris_get_fmgr __PDMS((int catno, int partno, int sano, char *move_date, char *move_time, int *p_ref2, int *p_partnum));
extern int PDMris_find_references __PDMS((int p_partnum, int n_sano, int *p_ref1, int *p_ref2));
extern int PDMris_get_sano __PDMS((char *saname, int *sano));

/* ./ris/PDMrs_rpt.rc */
extern int PSUrs_cre_rpt __PDMS((struct PSUrpt *psurpt, char *schemaname, char *schemapwd));
extern int PSUrs_load_rpt __PDMS((struct PSUrpt *psurpt));
extern int PSUrs_cre_rtabs __PDMS((void));
extern int PSUrs_get_tempno __PDMS((struct PSUrpt *psurpt, int *tempno, int tmptype));
extern int PSUrs_update_rpt __PDMS((struct PSUrpt *psurpt));
extern int PSUrs_insert_rpt __PDMS((struct PSUrpt *psurpt));
extern int PSUrs_insert_rptlst __PDMS((struct PSUrpt *psurpt, int row, int tempno));
extern int PSUrs_load_rptlst __PDMS((struct PSUrpt *psurpt));
extern int PSUrs_load_rptopt __PDMS((struct PSUrpt *psurpt));

/* ./ris/PDMrs_tool.rc */
extern int PDMris_get_catno __PDMS((char *catalog, int *catno));
extern int PDMris_get_projectno __PDMS((char *project, int *projectno));
extern int PDMris_get_catname __PDMS((int catno, char *catalog, char *type));
extern int PDMload_catno __PDMS((char *catalog));
extern int PDMload_fcatno __PDMS((char *catalog));
extern int PDMris_maxrow_no __PDMS((char *table, char *attr_name, int *maxrow));
extern int PDMris_get_pitemno __PDMS((int *p_itemno, char *catalog, char *partid, char *revision));
extern int PDMris_get_tableno __PDMS((char *catalog, int *catno));
extern int PDMris_max_childno __PDMS((int p_catno, int p_itemno, int level, int p_pchildno, int *p_childno));
extern int PDMris_max_tempchildno __PDMS((int p_catno, int p_itemno, int level, int p_pchildno, char *temp_table, int *p_childno));
extern int PDMget_assembly_ind __PDMS((char *catalog, int itemname, int itemrev, char *n_setindicator));
extern int PDMris_get_userno __PDMS((char *user, int *userno));
extern int PDMris_get_catnodesc __PDMS((int catno, char *catalog, char *catdesc));
extern long PDMquery __PDMS((char *ris_query, int *rows, char **out_arr, int *err_code, char delim_flag));
extern int PDMris_stmt __PDMS((char *sql, int *err_code));
extern int PDMget_catno_type __PDMS((char *catalog, int *catno, char *type));
extern int PDMquery_stateno __PDMS((char *catalog, char *part, char *rev, char *statename));

/* ./ris/SQLqry.rc */
extern long PDMSQLquery __PDMS((char *sql_str, MEMptr *list, long size));

#if defined(__cplusplus)
}
#endif
#endif
#endif
