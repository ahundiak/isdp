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

/* ./ris/PDMdir_ris.rc */
extern int PDMris_get_catno __PDM((char *catalog, int *catno));
extern int PDMris_get_pitemno __PDM((int *p_itemno, char *catalog, char *partid, char *revision));
extern int PDMris_get_tableno __PDM((char *catalog, int *catno));
extern int PDMris_stmt __PDM((char *sql));

/* ./ris/PDMfmgr.rc */
extern int PDMris_get_fmgr __PDM((int catno, int partno, int sano, char *move_date, char *move_time, int *p_ref2, int *p_partnum));
extern int PDMris_find_references __PDM((int p_partnum, int n_sano, int *p_ref1, int *p_ref2));

/* ./ris/PDMfmgr_ris.rc */
extern int PDMris_get_fmgr __PDM((int catno, int partno, int sano, char *move_date, char *move_time, int *p_ref2, int *p_partnum));
extern int PDMris_find_references __PDM((int p_partnum, int n_sano, int *p_ref1, int *p_ref2));

/* ./ris/PDMp_qry1.rc */
extern long PDMfix_qry_prep_1 __PDM((void));
extern long PDMfix_qry_res_1 __PDM((int attr_no, char *type, char *def_value, long *def_no, char *min_no, char *max_no, long *list_no, long *prog_no));
extern int SQLp_free_2 __PDM((void));

/* ./ris/PDMrs_bom.c */
extern int PSUrs_get_pitemno __PDM((int *p_itemno));
extern int PSUrs_get_bomname __PDM((int pitemno, char *bomname));

/* ./ris/PDMrs_bom.rc */
extern int PSUrs_get_pitemno __PDM((int *p_itemno));
extern int PSUrs_get_bomname __PDM((int pitemno, char *bomname));

/* ./ris/PDMrs_cat.c */
extern int rMRPrs_free_values __PDM((struct rMRPcolumn_info *column_info, int number_of_rows, int number_of_cols));
extern int MRPrs_get_catno __PDM((void));
extern int MRPrs_mk_elect_cat __PDM((void));
extern int rMRPrs_in_nfmcat __PDM((void));
extern int rMRPrs_mk_cat_tab __PDM((int catlst, char *catalog));
extern int rMRPrs_create_tab __PDM((char *catalog, struct rMRPattr rmrpattr));
extern int rMRPrs_alter_tab __PDM((char *catalog, struct rMRPattr rmrpattr));
extern int rMRPrs_get_nfmattrs_pdmcat __PDM((void));
extern int rMRPrs_fill_nfmattr_values __PDM((int cattype, struct rMRPcolumn_info *rmrpcolumn_info));
extern int rMRPrs_fill_nfmattr_rows __PDM((struct rMRPcolumn_info *rmrpcolumn_info));

/* ./ris/PDMrs_cat.rc */
extern int rMRPrs_free_values __PDM((struct rMRPcolumn_info *column_info, int number_of_rows, int number_of_cols));
extern int MRPrs_get_catno __PDM((void));
extern int MRPrs_mk_elect_cat __PDM((void));
extern int rMRPrs_in_nfmcat __PDM((void));
extern int rMRPrs_mk_cat_tab __PDM((int catlst, char *catalog));
extern int rMRPrs_create_tab __PDM((char *catalog, struct rMRPattr rmrpattr));
extern int rMRPrs_alter_tab __PDM((char *catalog, struct rMRPattr rmrpattr));
extern int rMRPrs_get_nfmattrs_pdmcat __PDM((void));
extern int rMRPrs_fill_nfmattr_values __PDM((int cattype, struct rMRPcolumn_info *rmrpcolumn_info));
extern int rMRPrs_fill_nfmattr_rows __PDM((struct rMRPcolumn_info *rmrpcolumn_info));

/* ./ris/PDMrs_fmgr.c */
extern int PDMris_get_fmgr __PDM((int catno, int partno, int sano, char *move_date, char *move_time, int *p_ref2, int *p_partnum));
extern int PDMris_find_references __PDM((int p_partnum, int n_sano, int *p_ref1, int *p_ref2));
extern int PDMris_get_sano __PDM((char *saname, int *sano));

/* ./ris/PDMrs_fmgr.rc */
extern int PDMris_get_fmgr __PDM((int catno, int partno, int sano, char *move_date, char *move_time, int *p_ref2, int *p_partnum));
extern int PDMris_find_references __PDM((int p_partnum, int n_sano, int *p_ref1, int *p_ref2));
extern int PDMris_get_sano __PDM((char *saname, int *sano));

/* ./ris/PDMrs_rpt.c */
extern int PSUrs_cre_rpt __PDM((struct PSUrpt *psurpt, char *schemaname, char *schemapwd));
extern int PSUrs_load_rpt __PDM((struct PSUrpt *psurpt));
extern int PSUrs_cre_rtabs __PDM((void));
extern int PSUrs_get_tempno __PDM((struct PSUrpt *psurpt, int *tempno, int tmptype));
extern int PSUrs_update_rpt __PDM((struct PSUrpt *psurpt));
extern int PSUrs_insert_rpt __PDM((struct PSUrpt *psurpt));
extern int PSUrs_insert_rptlst __PDM((struct PSUrpt *psurpt, int row, int tempno));
extern int PSUrs_load_rptlst __PDM((struct PSUrpt *psurpt));
extern int PSUrs_load_rptopt __PDM((struct PSUrpt *psurpt));

/* ./ris/PDMrs_rpt.rc */
extern int PSUrs_cre_rpt __PDM((struct PSUrpt *psurpt, char *schemaname, char *schemapwd));
extern int PSUrs_load_rpt __PDM((struct PSUrpt *psurpt));
extern int PSUrs_cre_rtabs __PDM((void));
extern int PSUrs_get_tempno __PDM((struct PSUrpt *psurpt, int *tempno, int tmptype));
extern int PSUrs_update_rpt __PDM((struct PSUrpt *psurpt));
extern int PSUrs_insert_rpt __PDM((struct PSUrpt *psurpt));
extern int PSUrs_insert_rptlst __PDM((struct PSUrpt *psurpt, int row, int tempno));
extern int PSUrs_load_rptlst __PDM((struct PSUrpt *psurpt));
extern int PSUrs_load_rptopt __PDM((struct PSUrpt *psurpt));

/* ./ris/PDMrs_tool.c */
extern int PDMris_get_catno __PDM((char *catalog, int *catno));
extern int PDMris_get_projectno __PDM((char *project, int *projectno));
extern int PDMris_get_catname __PDM((int catno, char *catalog, char *type));
extern int PDMload_catno __PDM((char *catalog));
extern int PDMload_fcatno __PDM((char *catalog));
extern int PDMris_maxrow_no __PDM((char *table, char *attr_name, int *maxrow));
extern int PDMris_get_pitemno __PDM((int *p_itemno, char *catalog, char *partid, char *revision));
extern int PDMris_get_tableno __PDM((char *catalog, int *catno));
extern int PDMris_max_childno __PDM((int p_catno, int p_itemno, int level, int p_pchildno, int *p_childno));
extern int PDMris_max_tempchildno __PDM((int p_catno, int p_itemno, int level, int p_pchildno, char *temp_table, int *p_childno));
extern int PDMget_assembly_ind __PDM((char *catalog, int itemname, int itemrev, char *n_setindicator));
extern int PDMris_get_userno __PDM((char *user, int *userno));
extern int PDMris_get_catnodesc __PDM((int catno, char *catalog, char *catdesc));
extern long PDMquery __PDM((char *ris_query, int *rows, char **out_arr, int *err_code));
extern int PDMris_stmt __PDM((char *sql, int *err_code));
extern int PDMget_catno_type __PDM((char *catalog, int *catno, char *type));
extern int PDMquery_stateno __PDM((char *catalog, char *part, char *rev, char *statename));

/* ./ris/PDMrs_tool.rc */
extern int PDMris_get_catno __PDM((char *catalog, int *catno));
extern int PDMris_get_projectno __PDM((char *project, int *projectno));
extern int PDMris_get_catname __PDM((int catno, char *catalog, char *type));
extern int PDMload_catno __PDM((char *catalog));
extern int PDMload_fcatno __PDM((char *catalog));
extern int PDMris_maxrow_no __PDM((char *table, char *attr_name, int *maxrow));
extern int PDMris_get_pitemno __PDM((int *p_itemno, char *catalog, char *partid, char *revision));
extern int PDMris_get_tableno __PDM((char *catalog, int *catno));
extern int PDMris_max_childno __PDM((int p_catno, int p_itemno, int level, int p_pchildno, int *p_childno));
extern int PDMris_max_tempchildno __PDM((int p_catno, int p_itemno, int level, int p_pchildno, char *temp_table, int *p_childno));
extern int PDMget_assembly_ind __PDM((char *catalog, int itemname, int itemrev, char *n_setindicator));
extern int PDMris_get_userno __PDM((char *user, int *userno));
extern int PDMris_get_catnodesc __PDM((int catno, char *catalog, char *catdesc));
extern long PDMquery __PDM((char *ris_query, int *rows, char **out_arr, int *err_code));
extern int PDMris_stmt __PDM((char *sql, int *err_code));
extern int PDMget_catno_type __PDM((char *catalog, int *catno, char *type));
extern int PDMquery_stateno __PDM((char *catalog, char *part, char *rev, char *statename));

/* ./ris/PDMtools_ris.c */
extern int PDMris_get_catno __PDM((char *catalog, int *catno));
extern int PDMris_get_projectno __PDM((char *project, int *projectno));
extern int PDMris_get_catname __PDM((int catno, char *catalog));
extern int PDMload_catno __PDM((char *catalog));
extern int PDMload_fcatno __PDM((char *catalog));
extern int PDMris_maxrow_no __PDM((char *table, char *attr_name, int *maxrow));
extern int PDMris_get_pitemno __PDM((int *p_itemno, char *catalog, char *partid, char *revision));
extern int PDMris_get_tableno __PDM((char *catalog, int *catno));
extern int PDMris_stmt __PDM((char *sql));
extern int PDMris_max_childno __PDM((int p_catno, int p_itemno, int level, int p_pchildno, int *p_childno));
extern int PDMris_max_tempchildno __PDM((int p_catno, int p_itemno, int level, int p_pchildno, char *temp_table, int *p_childno));
extern int PDMget_assembly_ind __PDM((char *catalog, int itemname, int itemrev, char *n_setindicator));
extern int PDMris_get_userno __PDM((char *user, int *userno));

/* ./ris/rMRPrs_ncit.rc */
extern int rMRPrs_chknfmsetcit __PDM((int *citno, int pitemno, int citemno, int ccatno));

/* ./ris/rMRPrs_tls.rc */
extern int rMRPrs_get_catno __PDM((char *catalog, int *catno));
extern int rMRPrs_get_pitemno __PDM((int *p_itemno, char *catalog, char *partid, char *revision));
extern int rMRPrs_getindexslot __PDM((int *index_total));
extern int rMRPrs_rmindex __PDM((struct rMRPindex_slot indexslot));
extern int rMRPrs_chknfmsetcit __PDM((int *citno, int pitemno, int citemno, int ccatno));

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

#if defined(__cplusplus)
extern "C" {
#endif

/* ./ris/PDMdir_ris.rc */
extern int PDMris_get_catno __PDM((char *catalog, int *catno));
extern int PDMris_get_pitemno __PDM((int *p_itemno, char *catalog, char *partid, char *revision));
extern int PDMris_get_tableno __PDM((char *catalog, int *catno));
extern int PDMris_stmt __PDM((char *sql));

/* ./ris/PDMfmgr.rc */
extern int PDMris_get_fmgr __PDM((int catno, int partno, int sano, char *move_date, char *move_time, int *p_ref2, int *p_partnum));
extern int PDMris_find_references __PDM((int p_partnum, int n_sano, int *p_ref1, int *p_ref2));

/* ./ris/PDMfmgr_ris.rc */
extern int PDMris_get_fmgr __PDM((int catno, int partno, int sano, char *move_date, char *move_time, int *p_ref2, int *p_partnum));
extern int PDMris_find_references __PDM((int p_partnum, int n_sano, int *p_ref1, int *p_ref2));

/* ./ris/PDMp_qry1.rc */
extern long PDMfix_qry_prep_1 __PDM((void));
extern long PDMfix_qry_res_1 __PDM((int attr_no, char *type, char *def_value, long *def_no, char *min_no, char *max_no, long *list_no, long *prog_no));
extern int SQLp_free_2 __PDM((void));

/* ./ris/PDMrs_bom.rc */
extern int PSUrs_get_pitemno __PDM((int *p_itemno));
extern int PSUrs_get_bomname __PDM((int pitemno, char *bomname));

/* ./ris/PDMrs_cat.rc */
extern int rMRPrs_free_values __PDM((struct rMRPcolumn_info *column_info, int number_of_rows, int number_of_cols));
extern int MRPrs_get_catno __PDM((void));
extern int MRPrs_mk_elect_cat __PDM((void));
extern int rMRPrs_in_nfmcat __PDM((void));
extern int rMRPrs_mk_cat_tab __PDM((int catlst, char *catalog));
extern int rMRPrs_create_tab __PDM((char *catalog, struct rMRPattr rmrpattr));
extern int rMRPrs_alter_tab __PDM((char *catalog, struct rMRPattr rmrpattr));
extern int rMRPrs_get_nfmattrs_pdmcat __PDM((void));
extern int rMRPrs_fill_nfmattr_values __PDM((int cattype, struct rMRPcolumn_info *rmrpcolumn_info));
extern int rMRPrs_fill_nfmattr_rows __PDM((struct rMRPcolumn_info *rmrpcolumn_info));

/* ./ris/PDMrs_fmgr.rc */
extern int PDMris_get_fmgr __PDM((int catno, int partno, int sano, char *move_date, char *move_time, int *p_ref2, int *p_partnum));
extern int PDMris_find_references __PDM((int p_partnum, int n_sano, int *p_ref1, int *p_ref2));
extern int PDMris_get_sano __PDM((char *saname, int *sano));

/* ./ris/PDMrs_rpt.rc */
extern int PSUrs_cre_rpt __PDM((struct PSUrpt *psurpt, char *schemaname, char *schemapwd));
extern int PSUrs_load_rpt __PDM((struct PSUrpt *psurpt));
extern int PSUrs_cre_rtabs __PDM((void));
extern int PSUrs_get_tempno __PDM((struct PSUrpt *psurpt, int *tempno, int tmptype));
extern int PSUrs_update_rpt __PDM((struct PSUrpt *psurpt));
extern int PSUrs_insert_rpt __PDM((struct PSUrpt *psurpt));
extern int PSUrs_insert_rptlst __PDM((struct PSUrpt *psurpt, int row, int tempno));
extern int PSUrs_load_rptlst __PDM((struct PSUrpt *psurpt));
extern int PSUrs_load_rptopt __PDM((struct PSUrpt *psurpt));

/* ./ris/PDMrs_tool.rc */
extern int PDMris_get_catno __PDM((char *catalog, int *catno));
extern int PDMris_get_projectno __PDM((char *project, int *projectno));
extern int PDMris_get_catname __PDM((int catno, char *catalog, char *type));
extern int PDMload_catno __PDM((char *catalog));
extern int PDMload_fcatno __PDM((char *catalog));
extern int PDMris_maxrow_no __PDM((char *table, char *attr_name, int *maxrow));
extern int PDMris_get_pitemno __PDM((int *p_itemno, char *catalog, char *partid, char *revision));
extern int PDMris_get_tableno __PDM((char *catalog, int *catno));
extern int PDMris_max_childno __PDM((int p_catno, int p_itemno, int level, int p_pchildno, int *p_childno));
extern int PDMris_max_tempchildno __PDM((int p_catno, int p_itemno, int level, int p_pchildno, char *temp_table, int *p_childno));
extern int PDMget_assembly_ind __PDM((char *catalog, int itemname, int itemrev, char *n_setindicator));
extern int PDMris_get_userno __PDM((char *user, int *userno));
extern int PDMris_get_catnodesc __PDM((int catno, char *catalog, char *catdesc));
extern long PDMquery __PDM((char *ris_query, int *rows, char **out_arr, int *err_code));
extern int PDMris_stmt __PDM((char *sql, int *err_code));
extern int PDMget_catno_type __PDM((char *catalog, int *catno, char *type));
extern int PDMquery_stateno __PDM((char *catalog, char *part, char *rev, char *statename));

/* ./ris/rMRPrs_ncit.rc */
extern int rMRPrs_chknfmsetcit __PDM((int *citno, int pitemno, int citemno, int ccatno));

/* ./ris/rMRPrs_tls.rc */
extern int rMRPrs_get_catno __PDM((char *catalog, int *catno));
extern int rMRPrs_get_pitemno __PDM((int *p_itemno, char *catalog, char *partid, char *revision));
extern int rMRPrs_getindexslot __PDM((int *index_total));
extern int rMRPrs_rmindex __PDM((struct rMRPindex_slot indexslot));
extern int rMRPrs_chknfmsetcit __PDM((int *citno, int pitemno, int citemno, int ccatno));

#if defined(__cplusplus)
}
#endif

#endif
