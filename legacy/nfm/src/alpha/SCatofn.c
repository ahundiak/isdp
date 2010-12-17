#include "SCstruct.h"

NFMfunction nfm_add_acl();
NFMfunction nfm_add_acl_users();
NFMfunction nfm_add_catalog_acl_map();
NFMfunction nfm_add_catalog_sa_map();
NFMfunction nfm_add_files_to_item();
NFMfunction nfm_add_item();
NFMfunction nfm_add_members();
NFMfunction nfm_add_node();
NFMfunction nfm_add_project();
NFMfunction nfm_add_project_acl_map();
NFMfunction nfm_add_project_members();
NFMfunction nfm_add_project_sa_map();
NFMfunction nfm_add_sa();
NFMfunction nfm_add_set_item();
NFMfunction nfm_add_signoff_users();
NFMfunction nfm_add_user();
NFMfunction nfm_archive();
NFMfunction nfm_backup();
NFMfunction nfm_begin_playback();
NFMfunction nfm_begin_record();
NFMfunction nfm_cancel_checkout_set();
NFMfunction nfm_cancel_item_archive_flag();
NFMfunction nfm_cancel_item_backup_flag();
NFMfunction nfm_cancel_item_checkout();
NFMfunction nfm_cancel_item_delete_flag();
NFMfunction nfm_cancel_item_restore_flag();
NFMfunction nfm_cancel_project_archive_flag();
NFMfunction nfm_cancel_project_backup_flag();
NFMfunction nfm_cancel_project_restore_flag();
NFMfunction nfm_cancel_set_archive_flag();
NFMfunction nfm_cancel_set_backup_flag();
NFMfunction nfm_cancel_set_restore_flag();
NFMfunction nfm_catalog();
NFMfunction nfm_change_catalog();
NFMfunction nfm_change_file_attributes();
NFMfunction nfm_change_item_workflow();
NFMfunction nfm_change_node();
NFMfunction nfm_change_project();
NFMfunction nfm_change_sa();
NFMfunction nfm_change_sa_passwd();
NFMfunction nfm_change_self_passwd();
NFMfunction nfm_change_user();
NFMfunction nfm_change_user_passwd();
NFMfunction nfm_change_wa_passwd();
NFMfunction nfm_check_set_in();
NFMfunction nfm_check_set_out();
NFMfunction nfm_checkin_item();
NFMfunction nfm_checkout_item();
NFMfunction nfm_client_debug_off();
NFMfunction nfm_client_debug_on();
NFMfunction nfm_copy_acl_users();
NFMfunction nfm_copy_item();
NFMfunction nfm_copy_item_files();
NFMfunction nfm_copy_set_item_files();
NFMfunction nfm_create_catalog();
NFMfunction nfm_define_active_data();
NFMfunction nfm_define_search();
NFMfunction nfm_define_sort();
NFMfunction nfm_delete();
NFMfunction nfm_delete_acl();
NFMfunction nfm_delete_acl_users();
NFMfunction nfm_delete_archives();
NFMfunction nfm_delete_catalog();
NFMfunction nfm_delete_catalog_acl_map();
NFMfunction nfm_delete_catalog_sa_map();
NFMfunction nfm_delete_copied_files();
NFMfunction nfm_delete_files_from_item();
NFMfunction nfm_delete_item();
NFMfunction nfm_delete_label();
NFMfunction nfm_delete_members();
NFMfunction nfm_delete_node();
NFMfunction nfm_delete_project();
NFMfunction nfm_delete_project_acl_map();
NFMfunction nfm_delete_project_members();
NFMfunction nfm_delete_project_sa_map();
NFMfunction nfm_delete_savesets();
NFMfunction nfm_delete_search();
NFMfunction nfm_delete_signoff_users();
NFMfunction nfm_delete_sort();
NFMfunction nfm_delete_storage_area();
NFMfunction nfm_delete_user();
NFMfunction nfm_display_acls();
NFMfunction nfm_display_aclusers();
NFMfunction nfm_display_archive_flags();
NFMfunction nfm_display_archives();
NFMfunction nfm_display_backup_flags();
NFMfunction nfm_display_catalog_acl_mapping();
NFMfunction nfm_display_catalog_sa_mapping();
NFMfunction nfm_display_catalogs();
NFMfunction nfm_display_classes();
NFMfunction nfm_display_delete_flags();
NFMfunction nfm_display_item_files();
NFMfunction nfm_display_items();
NFMfunction nfm_display_items_on_tape();
NFMfunction nfm_display_items_partial();
NFMfunction nfm_display_items_partial_short();
NFMfunction nfm_display_items_short();
NFMfunction nfm_display_local_files();
NFMfunction nfm_display_nodes();
NFMfunction nfm_display_project_acl_mapping();
NFMfunction nfm_display_project_members();
NFMfunction nfm_display_project_sa_mapping();
NFMfunction nfm_display_projects();
NFMfunction nfm_display_restore_flags();
NFMfunction nfm_display_saveset_entries();
NFMfunction nfm_display_search();
NFMfunction nfm_display_set_members();
NFMfunction nfm_display_sets();
NFMfunction nfm_display_signoff_users();
NFMfunction nfm_display_so_history();
NFMfunction nfm_display_so_on_item();
NFMfunction nfm_display_sort();
NFMfunction nfm_display_storage_areas();
NFMfunction nfm_display_user_working_areas();
NFMfunction nfm_display_users();
NFMfunction nfm_display_where_used_project();
NFMfunction nfm_display_where_used_set();
NFMfunction nfm_display_workflows();
NFMfunction nfm_display_workflows_short();
NFMfunction nfm_display_working_areas();
NFMfunction nfm_end_record();
NFMfunction nfm_flag_item_archive();
NFMfunction nfm_flag_item_backup();
NFMfunction nfm_flag_item_delete();
NFMfunction nfm_flag_item_restore();
NFMfunction nfm_flag_project_archive();
NFMfunction nfm_flag_project_backup();
NFMfunction nfm_flag_project_restore();
NFMfunction nfm_flag_set_archive();
NFMfunction nfm_flag_set_backup();
NFMfunction nfm_flag_set_restore();
NFMfunction nfm_load_workflow();
NFMfunction nfm_lock_item();
NFMfunction nfm_make_transition();
NFMfunction nfm_plot_item();
NFMfunction nfm_plot_set();
NFMfunction nfm_print_file();
NFMfunction nfm_purge_item_versions();
NFMfunction nfm_purge_signoff();
NFMfunction nfm_restore();
NFMfunction nfm_review_environment();
NFMfunction nfm_review_search();
NFMfunction nfm_review_sort();
NFMfunction nfm_roll_version_forward();
NFMfunction nfm_save_item_files();
NFMfunction nfm_save_set_files();
NFMfunction nfm_search_across_catalogs();
NFMfunction nfm_server_debug_off();
NFMfunction nfm_server_debug_on();
NFMfunction nfm_signoff();
NFMfunction nfm_sqlquery();
NFMfunction nfm_unlock_item();
NFMfunction nfm_update_item();

int SCatofn_count = 153;

struct SCatofn_st SCatofn[] = {{"nfm_add_acl",nfm_add_acl},
                               {"nfm_add_acl_users",nfm_add_acl_users},
                               {"nfm_add_catalog_acl_map",nfm_add_catalog_acl_map},
                               {"nfm_add_catalog_sa_map",nfm_add_catalog_sa_map},
                               {"nfm_add_files_to_item",nfm_add_files_to_item},
                               {"nfm_add_item",nfm_add_item},
                               {"nfm_add_members",nfm_add_members},
                               {"nfm_add_node",nfm_add_node},
                               {"nfm_add_project",nfm_add_project},
                               {"nfm_add_project_acl_map",nfm_add_project_acl_map},
                               {"nfm_add_project_members",nfm_add_project_members},
                               {"nfm_add_project_sa_map",nfm_add_project_sa_map},
                               {"nfm_add_sa",nfm_add_sa},
                               {"nfm_add_set_item",nfm_add_set_item},
                               {"nfm_add_signoff_users",nfm_add_signoff_users},
                               {"nfm_add_user",nfm_add_user},
                               {"nfm_archive",nfm_archive},
                               {"nfm_backup",nfm_backup},
                               {"nfm_begin_playback",nfm_begin_playback},
                               {"nfm_begin_record",nfm_begin_record},
                               {"nfm_cancel_checkout_set",nfm_cancel_checkout_set},
                               {"nfm_cancel_item_archive_flag",nfm_cancel_item_archive_flag},
                               {"nfm_cancel_item_backup_flag",nfm_cancel_item_backup_flag},
                               {"nfm_cancel_item_checkout",nfm_cancel_item_checkout},
                               {"nfm_cancel_item_delete_flag",nfm_cancel_item_delete_flag},
                               {"nfm_cancel_item_restore_flag",nfm_cancel_item_restore_flag},
                               {"nfm_cancel_project_archive_flag",nfm_cancel_project_archive_flag},
                               {"nfm_cancel_project_backup_flag",nfm_cancel_project_backup_flag},
                               {"nfm_cancel_project_restore_flag",nfm_cancel_project_restore_flag},
                               {"nfm_cancel_set_archive_flag",nfm_cancel_set_archive_flag},
                               {"nfm_cancel_set_backup_flag",nfm_cancel_set_backup_flag},
                               {"nfm_cancel_set_restore_flag",nfm_cancel_set_restore_flag},
                               {"nfm_catalog",nfm_catalog},
                               {"nfm_change_catalog",nfm_change_catalog},
                               {"nfm_change_file_attributes",nfm_change_file_attributes},
                               {"nfm_change_item_workflow",nfm_change_item_workflow},
                               {"nfm_change_node",nfm_change_node},
                               {"nfm_change_project",nfm_change_project},
                               {"nfm_change_sa",nfm_change_sa},
                               {"nfm_change_sa_passwd",nfm_change_sa_passwd},
                               {"nfm_change_self_passwd",nfm_change_self_passwd},
                               {"nfm_change_user",nfm_change_user},
                               {"nfm_change_user_passwd",nfm_change_user_passwd},
                               {"nfm_change_wa_passwd",nfm_change_wa_passwd},
                               {"nfm_check_set_in",nfm_check_set_in},
                               {"nfm_check_set_out",nfm_check_set_out},
                               {"nfm_checkin_item",nfm_checkin_item},
                               {"nfm_checkout_item",nfm_checkout_item},
                               {"nfm_client_debug_off",nfm_client_debug_off},
                               {"nfm_client_debug_on",nfm_client_debug_on},
                               {"nfm_copy_acl_users",nfm_copy_acl_users},
                               {"nfm_copy_item",nfm_copy_item},
                               {"nfm_copy_item_files",nfm_copy_item_files},
                               {"nfm_copy_set_item_files",nfm_copy_set_item_files},
                               {"nfm_create_catalog",nfm_create_catalog},
                               {"nfm_define_active_data",nfm_define_active_data},
                               {"nfm_define_search",nfm_define_search},
                               {"nfm_define_sort",nfm_define_sort},
                               {"nfm_delete",nfm_delete},
                               {"nfm_delete_acl",nfm_delete_acl},
                               {"nfm_delete_acl_users",nfm_delete_acl_users},
                               {"nfm_delete_archives",nfm_delete_archives},
                               {"nfm_delete_catalog",nfm_delete_catalog},
                               {"nfm_delete_catalog_acl_map",nfm_delete_catalog_acl_map},
                               {"nfm_delete_catalog_sa_map",nfm_delete_catalog_sa_map},
                               {"nfm_delete_copied_files",nfm_delete_copied_files},
                               {"nfm_delete_files_from_item",nfm_delete_files_from_item},
                               {"nfm_delete_item",nfm_delete_item},
                               {"nfm_delete_label",nfm_delete_label},
                               {"nfm_delete_members",nfm_delete_members},
                               {"nfm_delete_node",nfm_delete_node},
                               {"nfm_delete_project",nfm_delete_project},
                               {"nfm_delete_project_acl_map",nfm_delete_project_acl_map},
                               {"nfm_delete_project_members",nfm_delete_project_members},
                               {"nfm_delete_project_sa_map",nfm_delete_project_sa_map},
                               {"nfm_delete_savesets",nfm_delete_savesets},
                               {"nfm_delete_search",nfm_delete_search},
                               {"nfm_delete_signoff_users",nfm_delete_signoff_users},
                               {"nfm_delete_sort",nfm_delete_sort},
                               {"nfm_delete_storage_area",nfm_delete_storage_area},
                               {"nfm_delete_user",nfm_delete_user},
                               {"nfm_display_acls",nfm_display_acls},
                               {"nfm_display_aclusers",nfm_display_aclusers},
                               {"nfm_display_archive_flags",nfm_display_archive_flags},
                               {"nfm_display_archives",nfm_display_archives},
                               {"nfm_display_backup_flags",nfm_display_backup_flags},
                               {"nfm_display_catalog_acl_mapping",nfm_display_catalog_acl_mapping},
                               {"nfm_display_catalog_sa_mapping",nfm_display_catalog_sa_mapping},
                               {"nfm_display_catalogs",nfm_display_catalogs},
                               {"nfm_display_classes",nfm_display_classes},
                               {"nfm_display_delete_flags",nfm_display_delete_flags},
                               {"nfm_display_item_files",nfm_display_item_files},
                               {"nfm_display_items",nfm_display_items},
                               {"nfm_display_items_on_tape",nfm_display_items_on_tape},
                               {"nfm_display_items_partial",nfm_display_items_partial},
                               {"nfm_display_items_partial_short",nfm_display_items_partial_short},
                               {"nfm_display_items_short",nfm_display_items_short},
                               {"nfm_display_local_files",nfm_display_local_files},
                               {"nfm_display_nodes",nfm_display_nodes},
                               {"nfm_display_project_acl_mapping",nfm_display_project_acl_mapping},
                               {"nfm_display_project_members",nfm_display_project_members},
                               {"nfm_display_project_sa_mapping",nfm_display_project_sa_mapping},
                               {"nfm_display_projects",nfm_display_projects},
                               {"nfm_display_restore_flags",nfm_display_restore_flags},
                               {"nfm_display_saveset_entries",nfm_display_saveset_entries},
                               {"nfm_display_search",nfm_display_search},
                               {"nfm_display_set_members",nfm_display_set_members},
                               {"nfm_display_sets",nfm_display_sets},
                               {"nfm_display_signoff_users",nfm_display_signoff_users},
                               {"nfm_display_so_history",nfm_display_so_history},
                               {"nfm_display_so_on_item",nfm_display_so_on_item},
                               {"nfm_display_sort",nfm_display_sort},
                               {"nfm_display_storage_areas",nfm_display_storage_areas},
                               {"nfm_display_user_working_areas",nfm_display_user_working_areas},
                               {"nfm_display_users",nfm_display_users},
                               {"nfm_display_where_used_project",nfm_display_where_used_project},
                               {"nfm_display_where_used_set",nfm_display_where_used_set},
                               {"nfm_display_workflows",nfm_display_workflows},
                               {"nfm_display_workflows_short",nfm_display_workflows_short},
                               {"nfm_display_working_areas",nfm_display_working_areas},
                               {"nfm_end_record",nfm_end_record},
                               {"nfm_flag_item_archive",nfm_flag_item_archive},
                               {"nfm_flag_item_backup",nfm_flag_item_backup},
                               {"nfm_flag_item_delete",nfm_flag_item_delete},
                               {"nfm_flag_item_restore",nfm_flag_item_restore},
                               {"nfm_flag_project_archive",nfm_flag_project_archive},
                               {"nfm_flag_project_backup",nfm_flag_project_backup},
                               {"nfm_flag_project_restore",nfm_flag_project_restore},
                               {"nfm_flag_set_archive",nfm_flag_set_archive},
                               {"nfm_flag_set_backup",nfm_flag_set_backup},
                               {"nfm_flag_set_restore",nfm_flag_set_restore},
                               {"nfm_load_workflow",nfm_load_workflow},
                               {"nfm_lock_item",nfm_lock_item},
                               {"nfm_make_transition",nfm_make_transition},
                               {"nfm_plot_item",nfm_plot_item},
                               {"nfm_plot_set",nfm_plot_set},
                               {"nfm_print_file",nfm_print_file},
                               {"nfm_purge_item_versions",nfm_purge_item_versions},
                               {"nfm_purge_signoff",nfm_purge_signoff},
                               {"nfm_restore",nfm_restore},
                               {"nfm_review_environment",nfm_review_environment},
                               {"nfm_review_search",nfm_review_search},
                               {"nfm_review_sort",nfm_review_sort},
                               {"nfm_roll_version_forward",nfm_roll_version_forward},
                               {"nfm_save_item_files",nfm_save_item_files},
                               {"nfm_save_set_files",nfm_save_set_files},
                               {"nfm_search_across_catalogs",nfm_search_across_catalogs},
                               {"nfm_server_debug_off",nfm_server_debug_off},
                               {"nfm_server_debug_on",nfm_server_debug_on},
                               {"nfm_signoff",nfm_signoff},
                               {"nfm_sqlquery",nfm_sqlquery},
                               {"nfm_unlock_item",nfm_unlock_item},
                               {"nfm_update_item",nfm_update_item}};

char *nfm_path = "../alpha";
