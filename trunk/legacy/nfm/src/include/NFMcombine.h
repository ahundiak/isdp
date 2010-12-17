#ifndef NFM_COMBINE_H
#define NFM_COMBINE_H

/*  This is defined at 'make' time  */

#ifdef COMBINED_MAKE

/*  Include files for a combined client/server executable  */

#include "NFMstruct.h"
#include "NFMUproto.h"
#include "NFMAproto.h"
#include "DISproto.h"

/*  Used to check for the need to connect/disconnect  */

#define COMBINED_CLIENT_SERVER

/*  Redefine the NFMR global structure to be the NFM global structure  */

#define NFMRglobal_st                     NFMglobal_st
#define NFMRglobal                        NFMglobal

/*  Redefine the NFMR functions to be NFM functions  */

#define NFMRlog_in                        NFMlog_in
#define NFMRlogout                        NFMlogout

/*  Display commands  */

#define NFMRdisplay_nodes                 NFMdisplay_nodes
#define NFMRdisplay_storage_areas         NFMdisplay_storage_areas
#define NFMRdisplay_working_areas         NFMdisplay_working_areas
#define NFMRdisplay_users                 NFMdisplay_users
#define NFMRdisplay_catalogs              NFMdisplay_catalogs
#define NFMRdisplay_workflows             NFMdisplay_workflows
#define NFMRdisplay_acls                  NFMdisplay_acls
#define NFMRdisplay_aclusers              NFMdisplay_aclusers
#define NFMRdisplay_signoff_users         NFMdisplay_signoff_users
#define NFMRdisplay_projects              NFMdisplay_projects
#define NFMRdisplay_catalog_acl_mapping   NFMdisplay_catalog_acl_mapping
#define NFMRdisplay_catalog_sa_mapping    NFMdisplay_catalog_sa_mapping
#define NFMRdisplay_project_acl_mapping   NFMdisplay_project_acl_mapping
#define NFMRdisplay_project_sa_mapping    NFMdisplay_project_sa_mapping
#define NFMRdisplay_items                 NFMdisplay_items
#define NFMRdisplay_item_files            NFMdisplay_item_files
#define NFMRdisplay_items_partial         NFMdisplay_items_partial
#define NFMRdisplay_querys                NFMdisplay_querys
#define NFMRdisplay_archive_flags         NFMdisplay_archive_flags
#define NFMRdisplay_backup_flags          NFMdisplay_backup_flags
#define NFMRdisplay_restore_flags         NFMdisplay_restore_flags
#define NFMRdisplay_delete_flags          NFMdisplay_delete_flags
#define NFMRdisplay_local_files           NFMdisplay_local_files
#define NFMRdisplay_so_on_item            NFMdisplay_so_on_item
#define NFMRdisplay_so_history            NFMdisplay_so_history
#define NFMRdisplay_where_used_project    NFMdisplay_where_used_project
#define NFMRdisplay_where_used_set        NFMdisplay_where_used_set
#define NFMRdisplay_project_members       NFMdisplay_project_members
#define NFMRdisplay_project_members_partial NFMdisplay_project_members_partial
#define NFMRdisplay_set_members           NFMdisplay_set_members
#define NFMRdisplay_set_members_partial   NFMdisplay_set_members_partial
#define NFMRdisplay_classes               NFMdisplay_classes
#define NFMRdisplay_programs              NFMdisplay_programs
#define NFMRdisplay_transitions           NFMdisplay_transitions
#define NFMRdisplay_sets                  NFMdisplay_sets
#define NFMRdisplay_archives              NFMdisplay_archives
#define NFMRdisplay_items_on_tape         NFMdisplay_items_on_tape
#define NFMRdisplay_savesets              NFMdisplay_savesets
#define NFMRlist_savesets                 NFMlist_savesets
#define NFMRlist_items_on_tape            NFMlist_items_on_tape
#define NFMRsave_item_files               NFMsave_item_files
#define NFMRsave_set_files                NFMsave_set_files

/*  Functions to validate active data  */

#define NFMRvalidate_catalog              NFMvalidate_catalog
#define NFMRvalidate_item                 NFMvalidate_item
#define NFMRvalidate_revision             NFMvalidate_revision
#define NFMRvalidate_st_area              NFMvalidate_st_area
#define NFMRvalidate_project              NFMvalidate_project
#define NFMRvalidate_search               NFMvalidate_search
#define NFMRvalidate_sort                 NFMvalidate_sort
#define NFMRvalidate_working_area         NFMvalidate_working_area
#define NFMRvalidate_node                 NFMvalidate_node
#define NFMRvalidate_user                 NFMvalidate_user
#define NFMRvalidate_workflow             NFMvalidate_workflow
#define NFMRvalidate_acl                  NFMvalidate_acl
#define NFMRvalidate_set_item             NFMvalidate_set_item
#define NFMRvalidate_set_rev              NFMvalidate_set_rev

/*  Administrator and user commands  */

#define NFMRquery_addto_loc_attributes    NFMquery_addto_loc_attributes
#define NFMRquery_catalog_template_n      NFMquery_catalog_template_n
#define NFMRquery_catalog_template        NFMquery_catalog_template
#define NFMRcreate_catalog                NFMcreate_catalog
#define NFMRvalidate_user_access          NFMvalidate_user_access
#define NFMRset_wf_state                  NFMset_wf_state
#define NFMRall_debug                     NFMall_debug
#define NFMRquery_add_item_attributes     NFMquery_add_item_attributes
#define NFMRquery_add_set_attributes      NFMquery_add_set_attributes
#define NFMRquery_addto_lop_attributes    NFMquery_addto_lop_attributes
#define NFMRquery_changeto_lop_attributes NFMquery_changeto_lop_attributes
#define NFMRquery_add_st_area_attributes  NFMquery_add_st_area_attributes
#define NFMRquery_change_sa_attributes    NFMquery_change_sa_attributes
#define NFMRquery_add_node_attributes     NFMquery_add_node_attributes
#define NFMRquery_change_node_attributes  NFMquery_change_node_attributes
#define NFMRquery_add_user_attributes     NFMquery_add_user_attributes
#define NFMRquery_change_user_attributes  NFMquery_change_user_attributes
#define NFMRadd_item                      NFMadd_item
#define NFMRadd_project                   NFMadd_project
#define NFMRchange_project                NFMchange_project
#define NFMRadd_storage_area              NFMadd_storage_area
#define NFMRchange_sa                     NFMchange_storage_area
#define NFMRadd_node                      NFMadd_node
#define NFMRchange_node                   NFMchange_node
#define NFMRadd_user                      NFMadd_user
#define NFMRchange_user                   NFMchange_user
#define NFMRprepare_update_item           NFMprepare_update_item
#define NFMRcancel_update_item            NFMcancel_update_item
#define NFMRupdate_item                   NFMupdate_item
#define NFMRdelete_catalog                NFM_delete_catalog
#define NFMRdelete_item                   NFM_delete_item
#define NFMRdelete_node                   NFMdelete_node
#define NFMRdelete_project                NFM_delete_project
#define NFMRdelete_storage_area           NFMdelete_storage_area
#define NFMRdelete_query                  NFMdelete_query
#define NFMRdelete_user                   NFMdelete_user
#define NFMRlock_item                     NFMlock_item
#define NFMRplot_item                     NFMplot_item
#define NFMRunlock_item                   NFMunlock_item
#define NFMRpurge_signoff                 NFMpurge_signoff
#define NFMRquery_make_transition         NFMquery_make_transition
#define NFMRmake_transition               NFMmake_transition
#define NFMRquery_catalog_acl_map         NFMquery_catalog_acl_map
#define NFMRupdate_catalog_acl_map        NFMupdate_catalog_acl_map
#define NFMRquery_catalog_sa_map          NFMquery_catalog_sa_map
#define NFMRupdate_catalog_sa_map         NFMupdate_catalog_sa_map
#define NFMRquery_project_acl_map         NFMquery_project_acl_map
#define NFMRupdate_project_acl_map        NFMupdate_project_acl_map
#define NFMRquery_project_sa_map          NFMquery_project_sa_map
#define NFMRupdate_project_sa_map         NFMupdate_project_sa_map
#define NFMRquery_acl_class_users         NFMquery_acl_class_users
#define NFMRupdate_acl_class_users        NFMupdate_acl_class_users
#define NFMRquery_acl_signoff_users       NFMquery_acl_signoff_users
#define NFMRupdate_acl_signoff_users      NFMupdate_acl_signoff_users
#define NFMRquery_acl_attributes          NFMquery_acl_attributes
#define NFMRadd_acl                       NFMadd_acl
#define NFMRcopy_acl_users                NFMcopy_acl_users
#define NFMRget_acl_classes_for_copy      NFMget_acl_classes_for_copy
#define NFMRquery_acl_attributes_condition NFMquery_acl_attributes_condition
#define NFMRquery_changeto_loc_attributes NFMquery_changeto_loc_attributes
#define NFMRquery_change_catalog_attributes NFMquery_change_catalog_information
#define NFMRchange_catalog                NFMchange_catalog
#define NFMRmultiple_catalog_search       NFMmultiple_catalog_search
#define NFMRget_user_defaults             NFMuser_defaults_login
#define NFMRset_user_defaults             NFMuser_defaults_logout
#define NFMRadd_default_working_area      NFMadd_default_working_area
#define NFMRget_file_information          NFMget_file_information
#define NFMRreset_file_information        NFMreset_file_information
#define NFMRdefine_file_information       NFMdefine_file_information
#define NFMRget_item_attr_for_copy        NFMget_item_attr_for_copy
#define NFMRcopy_item_n                   NFMcopy_item_n
#define NFMRcheckin_item                  NFMcheckin_item
#define NFMRcheckout_item                 NFMcheckout_item
#define NFMRcopy_item_files               NFMcopy_item_files
#define NFMRflag_project_backup           NFMflag_project_backup
#define NFMRflag_set_backup               NFMflag_set_backup
#define NFMRflag_item_backup              NFMflag_item_backup
#define NFMRflag_project_archive          NFMflag_project_archive
#define NFMRflag_set_archive              NFMflag_set_archive
#define NFMRflag_item_archive             NFMflag_item_archive
#define NFMRflag_project_restore          NFMflag_project_restore
#define NFMRflag_set_restore              NFMflag_set_restore
#define NFMRflag_item_restore             NFMflag_item_restore
#define NFMRflag_item_delete              NFMflag_item_delete
#define NFMRcheckin_set                   NFMcheckin_set
#define NFMRcheckout_set                  NFMcheckout_set
#define NFMRcopy_set_files                NFMcopy_set_files
#define NFMRplot_set                      NFMplot_set
#define NFMRcopy_item_files               NFMcopy_item_files
#define NFMRdelete_acl                    NFMdelete_acl
#define NFMRcancel_item_archive_flag      NFMcancel_item_archive_flag
#define NFMRcancel_item_backup_flag       NFMcancel_item_backup_flag
#define NFMRcancel_item_restore_flag      NFMcancel_item_restore_flag
#define NFMRcancel_item_delete_flag       NFMcancel_item_delete_flag
#define NFMRcancel_set_archive_flag       NFMcancel_set_archive_flag
#define NFMRcancel_set_backup_flag        NFMcancel_set_backup_flag
#define NFMRcancel_set_restore_flag       NFMcancel_set_restore_flag
#define NFMRcancel_project_flag           NFMcancel_project_flag_flag
#define NFMRcancel_project_archive_flag   NFMcancel_project_archive_flag
#define NFMRcancel_project_backup_flag    NFMcancel_project_backup_flag
#define NFMRcancel_project_restore_flag   NFMcancel_project_restore_flag
#define NFMRcancel_check_out_item         NFMcancel_check_out_item
#define NFMRcancel_check_out_set          NFMcancel_check_out_set
#define NFMRget_item_versions             NFMget_item_versions
#define NFMRroll_version_forward          NFMroll_version_forward
#define NFMRpurge_versions                NFMpurge_versions
#define NFMRquery_set_members             NFMquery_set_members
#define NFMRquery_project_members         NFMquery_project_members
#define NFMRupdate_project_members        NFMupdate_project_members
#define NFMRqry_items_in_cat_for_project  NFMqry_items_in_cat_for_project
#define NFMRdefine_set_information        NFMdefine_set_information
#define NFMRdelete_copied_files           NFMdelete_copied_files
#define NFMRsqlquery                      NFMsqlquery
#define NFMRretrieve_query_info           NFMretrieve_query_info
#define NFMRdefine_query                  NFMdefine_query
#define NFMRquery_savesets_to_delete      NFMquery_savesets_to_delete

#define NFMRfill_index                    NFMfill_index
#define NFMRfill_new_index                NFMfill_new_index
#define NFMRfill_newer_index              NFMfill_newer_index
#define NFMRrebuild_data_buffer           NFMrebuild_data_buffer
#define NFMRquery_user_defaults           NFMquery_user_defaults
#define NFMRdefine_set_information        NFMdefine_set_information
#define NFMRchange_user_passwd            NFMchange_user_passwd
#define NFMRchange_storage_area_passwd    NFMchange_storage_area_passwd
#define NFMRquery_flag_archive            NFMquery_flag_archive
#define NFMRquery_flag_backup             NFMquery_flag_backup
#define NFMRquery_flag_restore            NFMquery_flag_restore
#define NFMRnew_query_flag_restore        NFMnew_query_flag_restore
#define NFMRquery_flag_delete             NFMquery_flag_delete
#define NFMRalpha_flag_item_restore       NFMalpha_flag_item_restore
#define NFMRload_workflow                 NFMload_workflow
#define NFMRquery_table_definition        NFMquery_table_definition
#define NFMRdefine_query                  NFMdefine_query
#define NFMRquery_project_members         NFMquery_project_members
#define NFMRqry_items_in_cat_for_project  NFMqry_items_in_cat_for_project
#define NFMRupdate_project_members        NFMupdate_project_members
#define NFMRupdate_set_members            NFMupdate_set_members
#define NFMRquery_archive                 NFMquery_archive
#define NFMRquery_archives_to_delete      NFMquery_archives_to_delete
#define NFMRdelete_archives               NFMdelete_archives
#define NFMRmaintain_savesets             NFMmaintain_savesets
#define NFMRquery_savesets_to_delete      NFMquery_savesets_to_delete
#define NFMRdelete_savesets               NFMdelete_savesets
#define NFMRdelete_copied_files           NFMdelete_copied_files
#define NFMRtic_it                        NFMtic_it
#define NFMRchange_working_area_passwd    NFMchange_working_area_passwd
#define NFMRquery_signoff_attributes      NFMquery_signoff_attributes
#define NFMRsignoff                       NFMsignoff
#define NFMRwrite_user_defaults           NFMwrite_user_defaults
#define NFMRread_user_defaults            NFMread_user_defaults
#define NFMRblock_multiple_catalog_search NFMblock_multiple_catalog_search
#define NFMRsqlquery_cursor               NFMsqlquery_cursor

#define NFMRget_catalog_name              _NFMget_catalog_name
#define NFMRget_catalog_no                _NFMget_catalog_no
#define NFMRget_item_name                 _NFMget_item_name
#define NFMRget_item_no                   _NFMget_item_no
#define NFMRget_node_name                 _NFMget_node_name
#define NFMRget_node_no                   _NFMget_node_no
#define NFMRget_sa_name                   _NFMget_sa_name
#define NFMRget_sa_no                     _NFMget_sa_no
#define NFMRget_workflow_name             _NFMget_workflow_name
#define NFMRget_workflow_no               _NFMget_workflow_no
#define NFMRget_acl_name                  _NFMget_acl_name
#define NFMRget_acl_no                    _NFMget_acl_no
#define NFMRget_class_name                _NFMget_class_name
#define NFMRget_class_no                  _NFMget_class_no
#define NFMRget_user_name                 _NFMget_user_name
#define NFMRget_user_no                   _NFMget_user_no

/* Utility functions */

#define NFMRquery_archive                 NFMquery_archive
#define NFMRquery_backup                  NFMquery_backup
#define NFMRquery_restore                 NFMquery_restore
#define NFMRquery_delete                  NFMquery_delete
#define NFMRarchive_files                 NFMarchive_files
#define NFMRbackup_files                  NFMbackup_files
#define NFMRrestore_files                 NFMrestore_files
#define NFMRdelete_files                  NFMdelete_files
#define NFMRget_wf_and_completed_acl_list NFMget_wf_and_completed_acl_list
#define NFMRget_state_list_for_workflow   NFMget_state_list_for_workflow
#define NFMRchange_wf_item                NFMchange_wf_item
#define NFMRget_set_messages              NFMget_set_messages
#define NFMRdisplay_labels                NFMdisplay_labels
#define NFMRdelete_label                  NFMdelete_label
#define NFMRvalidate_and_format_date      NFMvalidate_and_format_date
#define NFMRget_date_info      		  NFMget_date_info
#else

/*  Include files for a separate client executable  */

#include "NDXstruct.h"
#include "NFMRstruct.h"
#include "NFMRproto.h"

#endif

#endif
