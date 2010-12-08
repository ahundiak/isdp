#ifndef PDU_PDMR_PRO_H
#define PDU_PDMR_PRO_H

#include "MEMstruct.h"
#include "PDUprtdyn.h"

#if defined(__STDC__) || defined(__cplusplus)
#ifndef __PDU
#define __PDU(args) args
#endif
#else
#ifndef __PDU
#define __PDU(args) ()
#endif
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./pdmr/PDMrapi.c */
extern int PDMopen_buffer      __PDU((int type, MEMptr *buffer));
extern int PDMget_filenames    __PDU((char *catalog, char *part,   char *revision, MEMptr *buffer));
extern int PDMrget_imm_parents __PDU((char *catalog, char *partid, char *revision, MEMptr *buffer));

/* ./pdmr/PDMrassy.c */
extern int PDMget_assembly_structure __PDU((char *catalog, char *part, char *revision, int level, MEMptr *buffer, long place));
extern int PDMdefine_assembly_structure __PDU((char *catalog, char *part_num, char *revision, int operation, MEMptr buffer));
extern int PDMrget_cit_children __PDU((char *catalog, char *partid, char *revision, MEMptr *buffer));
extern int PDMrget_cit_parents __PDU((char *catalog, char *partid, char *revision, MEMptr *buffer));

/* ./pdmr/PDMrattr.c */
extern int PDMget_table_attributes __PDU((int operation, int entity, char *catalog, MEMptr *attribute_buffer, MEMptr *data_buffer, MEMptr *list_buffers));
extern int PDMget_table_data __PDU((int operation, int entity, char *catalog, char *part_num, char *revision, MEMptr *attribute_buffer, MEMptr *data_buffer, MEMptr *list_buffers));
extern int PDMquery_table_definition __PDU((char *table_name, char *table_type, MEMptr *attribute_buffer));
extern int PDMquery_fast_table_definition __PDU((char *table_name, MEMptr *buffer));

/* ./pdmr/PDMrbom.c */
extern int PDMmodify_bom_content __PDU((MEMptr attr_bufr, MEMptr data_bufr, MEMptr list_bufr, MEMptr map_bufr));
extern int PDMget_bommap_attributes __PDU((char *catalog, MEMptr *attr_bufr));
extern int PDMrdelete_bom __PDU((char *catalog, char *n_itemname, char *n_itemrev));
extern int PDMprepare_bomparts_list __PDU((char *catalog, char *partnum, char *revision, char *filename, char *template_name, char *saname));
extern int PDMprepare_summary_bom __PDU((char *catalog, char *partnum, char *revision, char *filename, char *template_name, char *saname));
extern int PDMprepare_explode_summary_bom __PDU((char *catalog, char *partnum, char *revision, char *filename, char *template_name, char *saname));
extern int PDMgen_where_used_imm __PDU((char *catalog, char *partnum, char *revision, char *filename, char *template_name, char *saname));
extern int PDMgen_where_used_top __PDU((char *catalog, char *partnum, char *revision, char *filename, char *template_name, char *saname));
extern int PDMgen_bom_report __PDU((char *catalog, char *partnum, char *revision, char *filename, char *template_name, char *saname));
extern int PDMrupdate_bom __PDU((char *catalog, char *partnum, char *revision));

/* ./pdmr/PDMrcanchko.c */
extern int PDMrcancel_checkout_part __PDU((char *catalog, char *part_num, char *revision, MEMptr attach_bufr, struct PDUcat_node *param_cat_list, char ***file_name_list, int *row_count));

/* ./pdmr/PDMrcatalog.c */
extern int PDMrcreate_catalog __PDU((MEMptr loc_buffer, MEMptr loc_data, MEMptr catalog_buffer, MEMptr catalog_data, MEMptr catalog_lists, char *dynamic_table, MEMptr dyn_attr, MEMptr dyn_data, MEMptr dyn_list));
extern int PDMrmodify_catalog __PDU((MEMptr loc_buffer, MEMptr loc_data, MEMptr catalog_buffer, MEMptr catalog_data, MEMptr catalog_lists, char *dynamic_table, MEMptr dyn_attr, MEMptr dyn_data, MEMptr dyn_list));
extern int PDMrdelete_catalog __PDU((char *catalog));
extern int PDMcatalog_acls __PDU((MEMptr *acl_buffer));
extern int PDMget_dynamic_attributes __PDU((char *catalog, MEMptr *dynamic_attrs_buffer, MEMptr *dynamic_data_buffer, MEMptr *dynamic_list_buffer));

/* ./pdmr/PDMrchkin.c */
extern int PDMrcheckin_part __PDU((char *catalog, char *n_itemname, char *n_itemrev, MEMptr child_bufr, MEMptr attach_buffer, MEMptr view_buffer, MEMptr parm_buffer, MEMptr data_buffers, MEMptr param_ass_bufr, MEMptr param_child_dyn_bufr, struct PDUcat_node *param_cat_list));

/* ./pdmr/PDMrchkout.c */
extern int PDMrcheckout_part __PDU((char *catalog, char *n_itemname, char *n_itemrev, char *n_cofilename, MEMptr *files_bufr, MEMptr *attach_info_bufr));

/* ./pdmr/PDMrcopy.c */
extern int PDMcopy __PDU((MEMptr file_list, MEMptr *file_buffer));
extern int PDMrcopy_attach __PDU((MEMptr local_files, MEMptr *status_buffer));

/* ./pdmr/PDMrcriteria.c */
extern int PDMread_criteria __PDU((char *crit_name, MEMptr *criteria_buffer));
extern int PDMadd_criteria __PDU((MEMptr pdm_bufr, MEMptr criteria_bufr));
extern int PDMvalidate_criteria_name __PDU((char *name, char *nfm_type, char *pdm_type));

/* ./pdmr/PDMrdebug.c */
extern int PDUdebug_on_off __PDU((int flag));

/* ./pdmr/PDMrdetach.c */
extern int PDMdetach_part __PDU((MEMptr delete_list));

/* ./pdmr/PDMrdyn_part.c */
extern int PDMget_dyn_attr_names __PDU((char *catalog, char *n_itemname, char *n_itemrev, MEMptr *dynamic_attr_buffer));

/* ./pdmr/PDMrexec.c */
extern void PDUload_exec_structure __PDU((char *project, char *catalog, char *partid, char *revision, char *dcatalog, char *drawing, char *drevision, long operation, long entity));

/* ./pdmr/PDMrflag.c */
extern int PDMflag_part_archive __PDU((char *catalog, char *part_num, char *revision));
extern int PDMflag_part_backup __PDU((char *catalog, char *part_num, char *revision));
extern int PDMflag_part_delete __PDU((char *catalog, char *part_num, char *revision));
extern int PDMflag_part_restore __PDU((char *catalog, char *part_num, char *revision));
extern int PDMUnflag_part_archive __PDU((char *catalog, char *part_num, char *revision));
extern int PDMUnflag_part_delete __PDU((char *catalog, char *part_num, char *revision));
extern int PDMUnflag_part_restore __PDU((char *catalog, char *part_num, char *revision));
extern int PDMUnflag_part_backup __PDU((char *catalog, char *part_num, char *revision));

/* ./pdmr/PDMrfmgr.c */
extern int PDMrlist_local_files __PDU((MEMptr *buffer));
extern int PDMlist_checkedout_files __PDU((MEMptr *buffer));
extern int PDMlist_checkedin_files __PDU((MEMptr *buffer));
extern int PDMrdelete_local_files __PDU((MEMptr file_bufr, MEMptr *ret_bufr));
extern int PDMget_state __PDU((char *catalog, char *part, char *revision, MEMptr *buffer));
extern int PDMrcheck_part_status __PDU((char *catalog, char *part, char *revision));

/* ./pdmr/PDMrmisc.c */
extern int PDMget_catno_partno __PDU((char *catalog, char *partnum, char *revision, char **catalog_no, char **item_no));

/* ./pdmr/PDMrnfm_rpts.c */
extern int PDMlist_reports __PDU((char *templatetype, MEMptr *return_buffer));

/* ./pdmr/PDMrpart.c */
extern int PDMradd_part __PDU((char *project, char *catalog, char *partnum, char *rev, MEMptr attribute_buffer, MEMptr data_buffer, MEMptr add_buffer));
extern int PDMrdelete_part __PDU((char *catalog, char *part_num, char *revision));
extern int PDMcheck_delete_part __PDU((char *catalog, char *part_num, char *revision));
extern int PDMrmodify_part __PDU((char *catalog, char *part, char *rev, int operation, MEMptr attribute_buffer, MEMptr data_buffer, MEMptr file_bufr, MEMptr add_bufr));
extern int PDMdelete_files __PDU((char *catalog, char *partnum, char *revision, MEMptr file_bufr));
extern int PDMcancel_modify_part __PDU((char *catalog, char *part_num, char *part_rev, MEMptr attr_bufr, MEMptr data_bufr));
extern int PDMadd_part_to_project __PDU((MEMptr attribute_buffer, MEMptr data_buffer));
extern int PDMcheck_if_checkedin __PDU((char *catalog, char *n_itemname, char *n_itemrev));

/* ./pdmr/PDMrpart_p.c */
extern int PDMquery_part_type __PDU((char *catalog, char *n_itemname, char *n_itemrev, MEMptr *part_type_buffer));
extern int PDMchange_part_type __PDU((char *catalog, char *n_itemname, char *n_itemrev, char *part_type));

/* ./pdmr/PDMrpartstr.c */
extern int PDMget_children __PDU((char *catalog, char *n_itemname, char *n_itemrev, MEMptr *child_buffer));
extern int PDMshow_saved_views __PDU((char *catalog, char *n_itemname, char *n_itemrev, MEMptr *view_buffer));
extern int PDMget_part_attach_info __PDU((char *catalog, char *n_itemname, char *n_itemrev, int n_itemno, MEMptr *view_buffer, MEMptr *file_buffer));
extern int PDMget_part_view_list __PDU((char *catalog, char *n_itemname, char *n_itemrev, MEMptr *view_buffer));

/* ./pdmr/PDMrpdm_rpts.c */
extern int PDMvalidate_report_name __PDU((char *report_name, char *templatetype));
extern int PDMread_report_format __PDU((char *catalog, char *partnum, char *revision, int list_total, char *templatetype, int process, char *where, char *templib, MEMptr *def_op, MEMptr *def_list));
extern int PDMadd_report __PDU((char *catalog, char *partnum, char *revision, int list_total, char *templatetype, int process, char *where, char *templib, MEMptr def_op, MEMptr def_list));
extern int PDMdelete_report __PDU((char *report_name, int templatetype));
extern int PDMshow_boms __PDU((MEMptr *bom_list));
extern int PDMgen_loc_report __PDU((char *template_name, char *saname, char *filename));
extern int PDMgen_parts_in_catalog __PDU((char *catalog, char *template_name, char *saname, char *filename));

/* ./pdmr/PDMrrps_f.c */
extern int PDMopen_report_buffer __PDU((int type, MEMptr *bufr));

/* ./pdmr/PDMrsearch.c */
extern int PDMsearch_across_cats __PDU((char *loc_search, char *cat_search, char *cat_sort, MEMptr in_attr, MEMptr *out_buffer, MEMptr *mis_attr));
extern int PDMsearch_parts_in_catalog __PDU((char *catalog, MEMptr *buffer));
extern int PDMsearch_parts_in_project __PDU((char *project, char *catalog, MEMptr *buffer));
extern int PDMsearch_parts_in_project2 __PDU((char *project, char *catalog, MEMptr *buffer));
extern int PDMrlist_of_parts __PDU((MEMptr *buffer));

/* ./pdmr/PDMrtools.c */
extern int PDMverify_project __PDU((char *project, char *catalog));
extern int PDMrverify_catalog __PDU((char *project, char *catalog));
extern int PDMcheck_partnum __PDU((char *catalog, char *partnum, char *revision));
extern int PDMverify_partnum __PDU((char *catalog, char *partnum));
extern int PDMget_part_data __PDU((char *catalog, char *partnum, char *revision));
extern int PDMget_existing_data __PDU((char *catalog, char *partnum, char *revision));
extern int PDMget_add_buffer __PDU((char *catalog, char *partnum, char *revision));
extern int PDMpart_in_project __PDU((char *project, char *catalog, char *partnum, char *revision));
extern int PDMget_part_from_desc __PDU((char *catalog, char *description));
extern int PDMget_pt_desc __PDU((char *catalog, char *part, char *rev));
extern int PDMcatalog_list __PDU((char *project, char *search_str));
extern int PDMproject_catalog_listing __PDU((char *project, char *catalog, char *flag));
extern int PDMparts_listing __PDU((char *catalog));
extern int PDMrev_listing __PDU((char *catalog, char *partnum));
extern int PDMdescription_list __PDU((char *catalog));
extern int PDMparts_in_catalog __PDU((char *catalog));
extern int PDMget_trans __PDU((char *catalog, char *partnum, char *revision));
extern int PDMshow_catalogs __PDU((char *search_criteria, char *sort_criteria, char *n_type, MEMptr *ret_bufr));
extern int PDMrverify_part __PDU((char *catalog, char *n_itemname, char *n_itemrev));
extern int PDMquery_dynamic_attrs __PDU((char *catalog, char *n_itemname, char *n_itemrev, MEMptr *dynamic_attrs_buffer, MEMptr *dynamic_data_buffer, MEMptr *dynamic_list_buffer, char **p_explode));
extern int build_part_occurrence_list __PDU((char *cat, char *part, char *rev, MEMptr attr_list, MEMptr data_list, MEMptr list_list, char *p_exp));
extern int pdmcheck_part_occurrence __PDU((char *catalog, struct part_dynamic_attrs **place_part_info));
extern void pdmfree_part_occurrence __PDU((void));
extern int PDMsql_query __PDU((char *table_name, char *attribute_list, char *search_criteria, char *sort_criteria, MEMptr *ret_bufr));
extern int PDMopen_copy_buffer3 __PDU((char *n_cofilename, char *storage_name, char *node_name, char *user_name, char *passwd, char *path_name, MEMptr *strg_buffer));
extern int PDMcheck_item __PDU((char *catalog, char *n_itemname, char *n_itemrev, int command_no, char *username));
extern int PDMrcheck_dup_sa_fname __PDU((char *catalog, char *part_num, char *rev, char *filename, char *saname));
extern int PDMsql_distinct __PDU((char *table_name, char *attribute_list, char *search_criteria, char *sort_criteria, MEMptr *ret_bufr));
extern int PDUstrip_buffer __PDU((MEMptr *buffer));

/* ./pdmr/PDMruser.c */
extern int PDMrlogin __PDU((char *username, char *password, char *environment, short login_flag, long *user_id));
extern int PDMrterminate __PDU((void));
extern int PDMrverify_init __PDU((char *prod_name, char *prod_version));

/* ./pdmr/PDMrwf.c */
extern int PDMvalidate_user_access __PDU((char *command, char *workflow_name, char *table_name, char *project_name, char *part_num, char *part_rev));
extern int PDMset_to_state __PDU((int error_no, char *application, char *error_msg));
extern int PDMrmake_transition __PDU((char *catalog, char *part, char *rev, MEMptr attr_list, MEMptr data_list));

/* ./pdmr/PDUstatus.c */
extern int PDUsetup_status_structure __PDU((void));

#if defined(__cplusplus)
}
#endif

#if defined(__STDC__) || defined(__cplusplus)
#ifndef __PDU
#define __PDU(args) args
#endif
#else
#ifndef __PDU
#define __PDU(args) ()
#endif
#endif

#if defined(__STDC__) || defined(__cplusplus)
#ifndef __PDU
#define __PDU(args) args
#endif
#else
#ifndef __PDU
#define __PDU(args) ()
#endif
#endif

#if defined(__STDC__) || defined(__cplusplus)
#ifndef __PDU
#define __PDU(args) args
#endif
#else
#ifndef __PDU
#define __PDU(args) ()
#endif
#endif

#if defined(__STDC__) || defined(__cplusplus)
#ifndef __PDU
#define __PDU(args) args
#endif
#else
#ifndef __PDU
#define __PDU(args) ()
#endif
#endif

#if defined(__STDC__) || defined(__cplusplus)
#ifndef __PDU
#define __PDU(args) args
#endif
#else
#ifndef __PDU
#define __PDU(args) ()
#endif
#endif

#endif
