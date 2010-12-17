#ifndef DIS_PROTO_H
#define DIS_PROTO_H

#if defined(__STDC__) || defined(__cplusplus)
# define __DIS(s) s
#else
# define __DIS(s) ()
#endif


/* NFMblocksac.c */
extern long NFMblock_multiple_catalog_search __DIS((MEMptr cat_list, char *search_name, char *sort_name, MEMptr *buffer_list, MEMptr *synonym_list, long row_size));
extern int NFMbmcs_globals_cleanup __DIS((void));

/* NFMmcrsbmcs.c */
extern long NFMblock_multi_cat_srch_m_crsr __DIS((MEMptr cat_list, char *search_name, char *sort_name, MEMptr *buffer_list, MEMptr *synonym_list, long row_size, long cursor_id));
extern long NFMbmcsmc_globals_cleanup __DIS((long cursor_id));

/* NFMdItmTape.c */
extern long NFMlist_items_on_tape __DIS((MEMptr *data_list));
extern long NFMdisplay_items_on_tape __DIS((char *search, char *sort, MEMptr *syn_list, MEMptr *data_list));

/* NFMdSaveset.c */
extern long NFMlist_savesets __DIS((long user_id, MEMptr *data_list));
extern long NFMdisplay_savesets __DIS((char *search, char *sort, MEMptr *syn_list, MEMptr *data_list));

/* NFMd_acls.c */
extern long NFMdisplay_acls __DIS((char *wf_name, char *search, char *sort, int type, MEMptr *syn_list, MEMptr *data_list));
extern long NFMdisplay_acls_short __DIS((char *wf_name, char *search, char *sort, MEMptr *syn_list, MEMptr *data_list));

/* NFMd_aclu.c */
extern long NFMdisplay_aclusers __DIS((char *acl_name, char *search, char *sort, MEMptr *syn_list, MEMptr *data_list));

/* NFMd_arch.c */
extern long NFMdisplay_archives __DIS((char *search, char *sort, MEMptr *syn_list, MEMptr *data_list));

/* NFMd_catmap.c */
extern long NFMdisplay_catalog_acl_mapping __DIS((char *catalog, char *search, char *sort, MEMptr *syn_list, MEMptr *data_list));
extern long NFMdisplay_catalog_sa_mapping __DIS((char *catalog, char *search, char *sort, MEMptr *syn_list, MEMptr *data_list));

/* NFMd_cats.c */
extern long NFMdisplay_catalogs __DIS((char *search, char *sort, int type, MEMptr *syn_list, MEMptr *data_list));
extern long NFMdisplay_catalogs_short __DIS((char *search, char *sort, MEMptr *syn_list, MEMptr *data_list));

/* NFMd_class.c */
extern long NFMdisplay_classes __DIS((char *wf_name, char *search, char *sort, int type, MEMptr *syn_list, MEMptr *data_list));
extern long NFMdisplay_classes_short __DIS((char *wf_name, char *search, char *sort, MEMptr *syn_list, MEMptr *data_list));

/* NFMd_files.c */
extern long NFMdisplay_item_files __DIS((char *catalog, char *item, char *rev, char *search, char *sort, MEMptr *syn_list, MEMptr *data_list));

/* NFMd_flags.c */
extern long NFMdisplay_archive_flags __DIS((char *search, char *sort, MEMptr *syn_list, MEMptr *data_list));
extern long NFMdisplay_backup_flags __DIS((char *search, char *sort, MEMptr *syn_list, MEMptr *data_list));
extern long NFMdisplay_restore_flags __DIS((char *search, char *sort, MEMptr *syn_list, MEMptr *data_list));
extern long NFMdisplay_delete_flags __DIS((char *search, char *sort, MEMptr *syn_list, MEMptr *data_list));

/* NFMd_items.c */
extern long NFMdisplay_items __DIS((char *catalog, char *search, char *sort, int type, MEMptr *syn_list, MEMptr *data_list));
extern long NFMdisplay_items_partial __DIS((char *catalog, char *search, char *sort, int type, long rows, MEMptr *syn_list, MEMptr *data_list));
extern long NFMdisplay_items_short __DIS((char *catalog, char *search, char *sort, MEMptr *syn_list, MEMptr *data_list));
extern long NFMdisplay_items_short_partial __DIS((char *catalog, char *search, char *sort, long rows, MEMptr *syn_list, MEMptr *data_list));

/* NFMd_labels.c */
extern long NFMdisplay_labels __DIS((char *search, char *sort, MEMptr *syn_list, MEMptr *data_list));

/* NFMd_local.c */
extern long NFMdisplay_local_files __DIS((char *storage, char *search, char *sort, MEMptr *syn_list, MEMptr *data_list));

/* NFMd_nodes.c */
extern long NFMdisplay_nodes __DIS((char *search, char *sort, int type, MEMptr *syn_list, MEMptr *data_list));
extern long NFMdisplay_nodes_short __DIS((char *search, char *sort, MEMptr *syn_list, MEMptr *data_list));

/* NFMd_prog.c */
extern long NFMdisplay_programs __DIS((char *search, char *sort, int type, MEMptr *syn_list, MEMptr *data_list));
extern long NFMdisplay_programs_short __DIS((char *search, char *sort, MEMptr *syn_list, MEMptr *data_list));

/* NFMd_proj.c */
extern long NFMdisplay_projects __DIS((char *search, char *sort, int type, MEMptr *syn_list, MEMptr *data_list));
extern long NFMdisplay_projects_short __DIS((char *search, char *sort, MEMptr *syn_list, MEMptr *data_list));
extern long NFMdisplay_project_members __DIS((char *project, char *search, char *sort, MEMptr *syn_list, MEMptr *data_list));
extern long NFMdisplay_project_members_partial __DIS((char *project, char *search, char *sort, long rows, MEMptr *syn_list, MEMptr *data_list));
extern long NFMdisplay_where_used_project __DIS((char *catalog, char *item, char *rev, MEMptr *syn_list, MEMptr *data_list));

/* NFMd_projmap.c */
extern long NFMdisplay_project_acl_mapping __DIS((char *project, char *search, char *sort, MEMptr *syn_list, MEMptr *data_list));
extern long NFMdisplay_project_sa_mapping __DIS((char *project, char *search, char *sort, MEMptr *syn_list, MEMptr *data_list));

/* NFMd_querys.c */
extern long NFMdisplay_querys __DIS((char *query_type, char *search, char *sort, int type, MEMptr *syn_list, MEMptr *data_list));
extern long NFMdisplay_querys_short __DIS((char *query_type, char *search, char *sort, MEMptr *syn_list, MEMptr *data_list));

/* NFMd_sa.c */
extern long NFMdisplay_storage_areas __DIS((char *search, char *sort, int type, MEMptr *syn_list, MEMptr *data_list));
extern long NFMdisplay_storage_areas_short __DIS((char *search, char *sort, MEMptr *syn_list, MEMptr *data_list));

/* NFMd_sets.c */
extern long NFMdisplay_sets __DIS((char *catalog, char *search, char *sort, MEMptr *syn_list, MEMptr *data_list));
extern long NFMdisplay_set_members __DIS((char *catalog, char *item, char *rev, char *search, char *sort, MEMptr *syn_list, MEMptr *data_list));
extern long NFMdisplay_set_members_partial __DIS((char *catalog, char *item, char *rev, char *search, char *sort, long rows, MEMptr *syn_list, MEMptr *data_list));
extern long NFMdisplay_where_used_set __DIS((char *catalog, char *item, char *rev, MEMptr *syn_list, MEMptr *data_list));

/* NFMd_so.c */
extern long NFMdisplay_signoff_users __DIS((char *acl_name, char *search, char *sort, MEMptr *syn_list, MEMptr *data_list));
extern long NFMdisplay_so_history __DIS((char *catalog, char *item, char *rev, MEMptr *syn_list, MEMptr *data_list));
extern long NFMdisplay_so_on_item __DIS((char *catalog, char *item, char *rev, MEMptr *syn_list, MEMptr *data_list));

/* NFMd_stubs.c */
extern long NFMget_string_criteria __DIS((char *search, char *type, char *return_str));

/* NFMd_tools.c */
extern long NFMd_get_name_synonym __DIS((char *name, char *table, char *ret_syn));

/* NFMd_trans.c */
extern long NFMdisplay_transitions __DIS((char *wf_name, char *search, char *sort, int type, MEMptr *syn_list, MEMptr *data_list));
extern long NFMdisplay_transitions_short __DIS((char *wf_name, char *search, char *sort, MEMptr *syn_list, MEMptr *data_list));

/* NFMd_users.c */
extern long NFMdisplay_users __DIS((char *search, char *sort, int type, MEMptr *syn_list, MEMptr *data_list));
extern long NFMdisplay_users_short __DIS((char *search, char *sort, MEMptr *syn_list, MEMptr *data_list));

/* NFMd_wa.c */
extern long NFMdisplay_working_areas __DIS((char *search, char *sort, int type, MEMptr *syn_list, MEMptr *data_list));
extern long NFMdisplay_working_areas_short __DIS((char *search, char *sort, MEMptr *syn_list, MEMptr *data_list));

/* NFMd_wf.c */
extern long NFMdisplay_workflows __DIS((char *search, char *sort, int type, MEMptr *syn_list, MEMptr *data_list));
extern long NFMdisplay_workflows_short __DIS((char *search, char *sort, MEMptr *syn_list, MEMptr *data_list));

/* NFMlist_f.c */
extern long NFMlist_f __DIS((long user_id, char *cat_sort_str, char *item_sort_str, MEMptr *out_buffer_list));

/* NFMsa_cat.c */
extern long NFMmultiple_catalog_search __DIS((MEMptr cat_list, char *search_name, char *sort_name, MEMptr *buffer_list, MEMptr *synonym_list));

#undef __DIS

#endif
