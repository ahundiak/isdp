#ifndef NFMA_PROTO_H
#define NFMA_PROTO_H

#if defined(__STDC__) || defined(__cplusplus)
# define __NFMA(s) s
#else
# define __NFMA(s) ()
#endif


/* NFMacl_sign.c */
extern long NFMquery_acl_signoff_users __NFMA((long user_id, char *acl_name, MEMptr *attr_list, MEMptr *data_list, MEMptr *value_list));
extern long NFMupdate_acl_signoff_users __NFMA((long user_id, MEMptr attr_list, MEMptr data_list));

/* NFMacl_users.c */
extern long NFMquery_acl_class_users __NFMA((long user_id, char *acl_name, MEMptr *attr_list, MEMptr *data_list, MEMptr *value_list));
extern long NFMupdate_acl_class_users __NFMA((long user_id, MEMptr attr_list, MEMptr data_list));

/* NFMacls.c */
extern long NFMquery_acl_attributes __NFMA((long user_id, MEMptr *attr_list, MEMptr *data_list, MEMptr *value_list));
extern long NFMadd_acl __NFMA((long user_id, MEMptr attr_list, MEMptr data_list));
extern long NFMdelete_acl __NFMA((char *workflow_name, char *acl_name));

/* NFMadd_node.c */
extern long NFMquery_add_node_attributes __NFMA((long user_id, MEMptr *attr_list, MEMptr *data_list, MEMptr *value_list));
extern long NFMadd_node __NFMA((long user_id, MEMptr attr_list, MEMptr data_list));

/* NFMadd_prog.c */
extern long NFMadd_program __NFMA((long user_id, char *sa_name, char *program_name, char *program_desc, char *file_name));

/* NFMadd_proj.c */
extern long NFMadd_project __NFMA((long user_id, MEMptr attr_list, MEMptr data_list));
extern long NFMadd_project_entry __NFMA((long user_id, MEMptr attr_list, MEMptr data_list));

/* NFMadd_sa.c */
extern long NFMquery_add_st_area_attributes __NFMA((long user_id, MEMptr *attr_list, MEMptr *data_list, MEMptr *value_list));
extern long NFMadd_storage_area __NFMA((long user_id, MEMptr attr_list, MEMptr data_list));
extern long NFMadd_return_sa_name __NFMA((MEMptr attr_list, MEMptr data_list, char *saname));

/* NFMadd_user.c */
extern long NFMquery_add_user_attributes __NFMA((long user_id, MEMptr *attr_list, MEMptr *data_list, MEMptr *value_list));
extern long NFMadd_user __NFMA((long user_id, MEMptr attr_list, MEMptr data_list));

/* NFMadm_del.c */
extern long NFM_delete_catalog __NFMA((long user_id, char *catalog_name));
extern long NFM_delete_project __NFMA((long user_id, char *project_name));

/* NFMcat_map.c */
extern long NFMquery_catalog_acl_map __NFMA((long user_id, char *cat_name, MEMptr *attr_list, MEMptr *data_list, MEMptr *value_list));
extern long NFMupdate_catalog_acl_map __NFMA((long user_id, MEMptr attr_list, MEMptr data_list));
extern long NFMadd_catalog_acl_map __NFMA((long user_id, MEMptr attr_list, MEMptr data_list));
extern long NFMdrop_catalog_acl_map __NFMA((long user_id, MEMptr attr_list, MEMptr data_list));
extern long NFMquery_catalog_sa_map __NFMA((long user_id, char *cat_name, MEMptr *attr_list, MEMptr *data_list, MEMptr *value_list));
extern long NFMupdate_catalog_sa_map __NFMA((long user_id, MEMptr attr_list, MEMptr data_list));
extern long NFMadd_catalog_sa_map __NFMA((long user_id, MEMptr attr_list, MEMptr data_list));
extern long NFMdrop_catalog_sa_map __NFMA((long user_id, MEMptr attr_list, MEMptr data_list));
extern long NFMupdate_catalog_state __NFMA((long user_id, long cat_num));

/* NFMchg_node.c */
extern long NFMquery_change_node_attributes __NFMA((long user_id, char *node_name, MEMptr *attr_list, MEMptr *data_list, MEMptr *value_list));
extern long NFMchange_node __NFMA((long user_id, MEMptr attr_list, MEMptr data_list));

/* NFMchg_sa.c */
extern long NFMquery_change_sa_attributes __NFMA((long user_id, char *sa_name, MEMptr *attr_list, MEMptr *data_list, MEMptr *value_list));
extern long NFMchange_storage_area __NFMA((long user_id, MEMptr attr_list, MEMptr data_list));

/* NFMchg_user.c */
extern long NFMquery_change_user_attributes __NFMA((long user_id, char *user_name, MEMptr *attr_list, MEMptr *data_list, MEMptr *value_list));
extern long NFMchange_user __NFMA((long user_id, MEMptr attr_list, MEMptr data_list));

/* NFMchg_wf_it.c */
extern long NFMchange_wf_item __NFMA((char *catalog_name, char *item_name, char *item_rev, char *workflow_name, char *aclname, long acl_no, char *statename, long state_no));
extern long NFMget_wf_and_completed_acl_list __NFMA((MEMptr *syn_list, MEMptr *data_list));
extern long _NFMget_synonym_buffer_acl_list __NFMA((MEMptr *synonym_list));
extern long NFMget_state_list_for_workflow __NFMA((char *workflowname, MEMptr *syn_list, MEMptr *data_list));
extern long _NFMget_synonym_buffer_state_list __NFMA((MEMptr *synonym_list));
extern long _NFMcheck_item_condition_for_ch_wf __NFMA((char *catalog_name, char *item_name, char *item_rev, long cat_no, long item_no, long acl_no));

/* NFMcr_cat.c */
extern long NFMcreate_catalog __NFMA((long user_id, MEMptr loc_attr, MEMptr loc_data, MEMptr attr_list, MEMptr data_list, MEMptr value_list));
extern long _NFMadd_loc_entry __NFMA((char *cat_name, char *identifier, long catalog_no, MEMptr loc_attr, MEMptr loc_data));

/* NFMdel_cat.c */
extern long NFMdelete_catalog __NFMA((long user_id, char *cat_name, long *cat_no));
extern long NFMcheck_catalog_empty __NFMA((long user_id, char *cat_name));
extern long NFMdelete_default_catalog_acl_map __NFMA((long user_id, long cat_no));
extern long NFMdelete_default_catalog_sa_map __NFMA((long user_id, long cat_no));
extern long NFMdelete_loc_entry __NFMA((long user_id, long cat_no));
extern long NFMdelete_default_project_acl_map __NFMA((long user_id, long map_no));
extern long NFMdelete_default_project_sa_map __NFMA((long user_id, long map_no));
extern long _NFMcheck_cat_no_mapping __NFMA((long user_id, long cat_no));
extern long _NFMrm_nfmsafiles_entry __NFMA((long catalog_no));

/* NFMdel_dev.c */
extern long NFMdelete_storage_area __NFMA((long user_id, char *storage_name));
extern long NFMcheck_files_sa __NFMA((long user_id, long sa_no));
extern long NFMcheck_sa_in_catalog_map __NFMA((long user_id, long sa_no));

/* NFMdel_node.c */
extern long NFMdelete_node __NFMA((long user_id, char *node_name));
extern long NFMcheck_node_sa __NFMA((long user_id, long node_no));

/* NFMdel_proj.c */
extern long NFMdelete_project __NFMA((long user_id, char *proj_name, long *proj_no));

/* NFMdel_user.c */
extern long NFMdelete_user __NFMA((long user_id, char *user_name));
extern long NFMcheck_user_in_acls __NFMA((long user_id, long user_no));
extern long NFMcheck_user_in_signoff __NFMA((long user_id, long user_no));
extern long NFMcheck_user_in_project __NFMA((long user_id, char *user_name));

/* NFMld_proc.c */
extern long NFMload_processes __NFMA((long user_id, MEMptr attr_list, MEMptr data_list));

/* NFMld_prog.c */
extern long NFMload_program __NFMA((long user_id, char *sa_name, char *program_name, char *program_desc, char *file_name));

/* NFMload.c */
extern long NFMload_workflow __NFMA((long user_id, char *app_name, char *file_name));

/* NFMmod_cat.c */
extern long NFMchange_catalog __NFMA((long user_id, MEMptr loc_attr, MEMptr loc_data, MEMptr attr_list, MEMptr data_list, MEMptr value_list));
extern long NFMupdate_loc_entry __NFMA((long user_id, MEMptr attr_list, MEMptr data_list));
extern long NFMreset_loc_entry __NFMA((long user_id, MEMptr attr_list, MEMptr data_list));

/* NFMmod_proj.c */
extern long NFMchange_project __NFMA((long user_id, MEMptr lop_attr, MEMptr lop_data));
extern long NFMupdate_lop_entry __NFMA((long user_id, MEMptr attr_list, MEMptr data_list));

/* NFMpasswd.c */
extern int NFMchange_storage_area_passwd __NFMA((long user_id, char *st_name, char *old_passwd, char *new_passwd));
extern int NFMchange_user_passwd __NFMA((long user_id, char *user_name, char *old_passwd, char *new_passwd));

/* NFMpr_util.c */
extern long NFMarchive_files __NFMA((char *server, char *env, char *user, char *passwd, char *sa_no, char *label, MEMptr file_list, MEMptr *msg_buffer));
extern long NFMbackup_files __NFMA((char *server, char *env, char *user, char *passwd, char *sa_no, char *label, MEMptr file_list, MEMptr *msg_buffer));
extern long NFMrestore_files __NFMA((char *server, char *env, char *user, char *passwd, MEMptr file_list, MEMptr *msg_buffer));
extern long NFMdelete_files __NFMA((char *server, char *env, char *user, char *passwd, MEMptr file_list));
extern long NFMdelete_label __NFMA((MEMptr label));

/* NFMproj_map.c */
extern long NFMquery_project_acl_map __NFMA((long user_id, char *project_name, MEMptr *attr_list, MEMptr *data_list, MEMptr *value_list));
extern long NFMupdate_project_acl_map __NFMA((long user_id, MEMptr attr_list, MEMptr data_list));
extern long NFMadd_project_acl_map __NFMA((long user_id, MEMptr attr_list, MEMptr data_list));
extern long NFMdrop_project_acl_map __NFMA((long user_id, MEMptr attr_list, MEMptr data_list));
extern long NFMquery_project_sa_map __NFMA((long user_id, char *project_name, MEMptr *attr_list, MEMptr *data_list, MEMptr *value_list));
extern long NFMupdate_project_sa_map __NFMA((long user_id, MEMptr attr_list, MEMptr data_list));
extern long NFMadd_project_sa_map __NFMA((long user_id, MEMptr attr_list, MEMptr data_list));
extern long NFMdrop_project_sa_map __NFMA((long user_id, MEMptr attr_list, MEMptr data_list));
extern long NFMconvert_project_owned_members __NFMA((long user_id, long proj_no, long map_no, char *table_name));
extern long NFMcheck_project_owned_members __NFMA((long user_id, long proj_no, long map_no, char *table_name));
extern long _NFMcheck_acl_project_owned_members __NFMA((long user_id, long proj_no, long map_no));
extern long _NFMcheck_sa_project_owned_members __NFMA((long user_id, long proj_no, long map_no));
extern long NFMupdate_project_state __NFMA((long user_id, long proj_num));

/* NFMq_util.c */
extern long NFMquery_archive __NFMA((MEMptr *sa_value, MEMptr *file_value, MEMptr *label_value));
extern long NFMquery_backup __NFMA((MEMptr *sa_value, MEMptr *file_value, MEMptr *label_value));
extern long NFMquery_restore __NFMA((MEMptr *file_value));
extern long NFMquery_delete __NFMA((MEMptr *file_value));

/* NFMqa_cat.c */
extern long NFMquery_catalog_template_n __NFMA((MEMptr *attr_list, MEMptr *data_list, MEMptr *value_list, MEMptr application_list));
extern long _NFMquery_template_attributes __NFMA((MEMptr *attr_list, MEMptr *data_list, MEMptr *value_list, MEMptr application_list));
extern long NFMquery_catalog_template __NFMA((long user_id, MEMptr *attr_list, MEMptr *data_list, MEMptr *value_list));

/* NFMqa_loc.c */
extern long NFMquery_loc_definition __NFMA((long user_id, char *loc_name, MEMptr *attr_list));
extern long NFMquery_changeto_loc_attributes __NFMA((long user_id, char *loc_name, char *cat_name, MEMptr *attr_list, MEMptr *data_list, MEMptr *value_list));
extern long NFMquery_addto_loc_attributes __NFMA((long user_id, char *loc_name, MEMptr *attr_list, MEMptr *data_list, MEMptr *value_list));

/* NFMqry_proc.c */
extern long NFMquery_process_attributes __NFMA((long user_id, MEMptr *attr_list, MEMptr *data_list, MEMptr *value_list));

/* NFMqry_proj.c */
extern long NFMquery_project_members __NFMA((long user_id, char *project_name, MEMptr *attr_list, MEMptr *data_list));
extern long NFMquery_changeto_lop_attributes __NFMA((long user_id, char *proj_name, MEMptr *attr_list, MEMptr *data_list, MEMptr *value_list));

/* NFMupd_proj.c */
extern long NFMupdate_project_members __NFMA((long user_id, MEMptr attr_list, MEMptr data_list));
extern long NFMdrop_project_member __NFMA((long user_id, MEMptr cit_attr, MEMptr data_list, long proj_no, long row_no));
extern long NFMadd_project_member __NFMA((long user_id, MEMptr cit_attr, MEMptr data_list, long proj_no, long row_no));
extern long NFMcheck_project_sa_mapping __NFMA((long user_id, long proj_no, long cat_no, long item_no));
extern long NFMcheck_project_acl_mapping __NFMA((long user_id, long proj_no, long cat_no, long item_no));
extern long NFMcheck_project_mapping __NFMA((long user_id, long proj_no, long cat_no, long item_no));
extern long NFMcheck_project_ownership __NFMA((long user_id, long proj_no, long cat_no, long item_no, char *type));

/* NFMversions.c */
extern long NFMpurge_versions __NFMA((char *catalog_name, char *item_name, char *item_rev));
extern long NFMget_item_versions __NFMA((char *catalog_name, char *item_name, char *item_rev, MEMptr *synonym_list, MEMptr *data_list));
extern long NFMroll_version_forward __NFMA((char *catalog_name, char *item_name, char *item_rev, MEMptr data_list));
extern long _NFMcheck_item_condition_roll_version __NFMA((char *catalog_name, char *item_name, char *item_rev, long *max_version, MEMptr *item_condition));
extern long _NFMinvert_buffer __NFMA((MEMptr list1, MEMptr *list2));

#undef __NFMA

#endif
