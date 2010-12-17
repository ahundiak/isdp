
/* machine.h included to take care of platform variencies MVR 23 Dec 1993 */
#include "machine.h"

#include "NFF.h"
#include "NFFadd.h"
#include "NFFtimestamp.h"

/*  Global NFF structure  */

extern struct NFFglobal_st NFFglobal;

/*  This is the function that is called whenever a button
    on either the panel or bar menu is pushed by the user  */

void _NFFprocess_data (type, command)
  int    type;
  char   *command;
  {
    auto    int   f_label = -1;
    auto    int   help_is_displayed = FALSE;
    auto    int   num_rows = 0;
    auto    int   row = 0;
    auto    int   sel = FALSE;
    auto    long  status = NFI_S_SUCCESS;
    static  char  previous_command[15];
    static  char  *fname = "_NFFprocess_data";

    type = type;

    /*  See if another command is active  */

    if (NFFglobal.current_form != NULL)
      {
        _NFIdebug ((fname, "current_form is NOT NULL\n"));

        if ((strcmp (command, NFI_M_DEFINE_DEBUG_MODE)) == 0)
          {
            /*  Debug is okay  */

            ;
          }
        else if ((strcmp (command, NFI_M_EXIT)) == 0)
          {
            /*  Make sure that we don't mess anything up  */

            if (((strcmp (previous_command, NFI_M_ADD_ITEM_FILES)) == 0) ||
                ((strcmp (previous_command, NFI_M_DELETE_ITEM_FILES)) == 0) ||
                ((strcmp (previous_command, NFI_M_CHANGE_FILE_ATTRIBUTES)) == 0))
              {
                ERRload_struct (NFI, NFI_W_COMMAND_COMPLETE, NULL);
                NFFerror_message (NFFglobal.current_form);
                return;
              }

            /*  Call set to state first  */

            ERRload_struct (NFI, NFI_W_COMMAND_CANCELLED, NULL);
            NFFset_to_state ();
          }
        else if ((strcmp (command, NFI_M_ADD_UTIL_SA)) == 0)
          {
            /*  Add utility storage area is okay  */

            ;
          }
        else if ((strcmp (command, NFI_M_HELP)) == 0)
          {
            /*  Activate Help  */

            ;
          }
        else
          {
            ERRload_struct (NFI, NFI_W_COMMAND_COMPLETE, NULL);
            NFFerror_message (NFFglobal.current_form);
            return;
          }
      }

    /*  Save the command for checking later  */

    strcpy (previous_command, command);

    ERRreset_struct ();


    /*  Change the help topic if the help form is displayed  */

    if (NFFglobal.Help_initialized == TRUE)
      {
        if (status = Help_active (&help_is_displayed))
          {
            _NFIdebug ((fname, "Help_active = <%d>\n", status));
            help_is_displayed = FALSE;
          }
      }

    if (help_is_displayed)
      {
        if (status = _NFFhelp_topic (command))
            _NFIdebug ((fname, "_NFFhelp_topic = <%d>\n", status));
      }

#if defined(OS_SUNOS) || defined(OS_SOLARIS) || \
    defined(OS_SCO_UNIX) || defined(OS_HPUX)

    /* Plot is not available for SCO. - IGI - 22 Aug 1994 */

    if ((strcmp (command, NFI_M_PLOT_ITEM) == 0) ||
        (strcmp (command, NFI_M_PLOT_SET_PARENT) == 0))
      {
        NFFform_message( CURRENT_LABEL, NFM_E_PLOT_NOT_CLIX, NULL);
        return;
      }
#endif

    /*  Get command start time  */
    _NFFts_command_start ();

    /*  Validate the user's access to this command  */

    if ((status = NFFvalidate_user_access (command)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "NFFvalidate_user_access = <0x%.8x>\n", status));
        NFFerror_message (NFFglobal.forms[MAIN_LABEL]);
        _NFIdebug ((fname, " returning ...\n\n"));
        return;
      }

    if ((strcmp (command, NFI_M_EXIT)) == 0)
      {
        _NFIdebug ((fname, "Exit\n"));
        _NFFexit (status);
      }
    else if ((strcmp (command, NFI_M_HELP)) == 0)
      {
        _NFIdebug ((fname, "Help\n"));
        if (status = _NFFhelp_toc ())
          {
            _NFIdebug ((fname, "_NFFhelp_toc = <%d>\n", status));
            ERRload_struct (NFI, NFI_E_HELP, "%s%d", "_NFFhelp_toc", status);
            status = NFI_E_HELP;
          }
	_NFIdebug(( fname, "Status from _NFFhelp_toc() <%d>\n", status ));
        status = NFI_S_SUCCESS;
      }
    else if ((strcmp (command, NFI_M_RETRIEVE_DEFAULT_DATA)) == 0)
      {
        _NFIdebug ((fname, "Retrieve Default Data\n"));
        NFFread_user_defaults ();
        FIf_display (NFFglobal.forms[MAIN_LABEL]);
      }
    else if ((strcmp (command, NFI_M_DISPLAY_NODES)) == 0)
      {
        _NFIdebug ((fname, "Display Nodes\n"));
        status = NFFdisplay_nodes (TRUE);
        f_label = NODES_LABEL;
      }
    else if ((strcmp (command, NFI_M_DISPLAY_SA)) == 0)
      {
        _NFIdebug ((fname, "Display Storage Areas\n"));
        status = NFFdisplay_storage_areas (TRUE);
        f_label = STORAGE_AREAS_LABEL;
      }
    else if ((strcmp (command, NFI_M_DISPLAY_WA_ADMIN)) == 0)
      {
        _NFIdebug ((fname, "Display Working Areas (Admin)\n"));
        status = NFFdisplay_working_areas_admin (TRUE);
        f_label = WORKING_AREAS_LABEL_ADMIN;
      }
    else if ((strcmp (command, NFI_M_DISPLAY_WA_USER)) == 0)
      {
        _NFIdebug ((fname, "Display Working Areas (User)\n"));
        status = NFFdisplay_working_areas_user (TRUE);
        f_label = WORKING_AREAS_LABEL_USER;
      }
    else if ((strcmp (command, NFI_M_DISPLAY_USERS)) == 0)
      {
        _NFIdebug ((fname, "Display Users\n"));
        status = NFFdisplay_users (TRUE);
        f_label = USERS_LABEL;
      }
    else if ((strcmp (command, NFI_M_DISPLAY_CATALOGS)) == 0)
      {
        _NFIdebug ((fname, "Display Catalogs\n"));
        status = NFFdisplay_catalogs (TRUE);
        f_label = CATALOGS_LABEL;
      }
    else if ((strcmp (command, NFI_M_DISPLAY_ITEMS)) == 0)
      {
        _NFIdebug ((fname, "Display Items\n"));
        status = NFFdisplay_items (TRUE);
        f_label = ITEMS_LABEL;
      }
    else if ((strcmp (command, NFI_M_REVIEW_ITEM_ATTRIBUTES)) == 0)
      {
        _NFIdebug ((fname, "Review Item Attributes\n"));
        status = NFFreview_item (TRUE);
        f_label = REVIEW_LABEL;
      }
    else if ((strcmp (command, NFI_M_DISPLAY_WFS)) == 0)
      {
        _NFIdebug ((fname, "Display Workflows\n"));
        status = NFFdisplay_workflows (TRUE);
        f_label = WORKFLOWS_LABEL;
      }
    else if ((strcmp (command, NFI_M_DISPLAY_ACLS)) == 0)
      {
        _NFIdebug ((fname, "Display ACLs\n"));
        status = NFFdisplay_acls (TRUE);
        f_label = ACLS_LABEL;
      }
    else if ((strcmp (command, NFI_M_DISPLAY_PROJECTS)) == 0)
      {
        _NFIdebug ((fname, "Display Projects\n"));
        status = NFFdisplay_projects (TRUE);
        f_label = PROJECTS_LABEL;
      }
    else if ((strcmp (command, NFI_M_DISPLAY_CATALOG_ACL_MAPPING)) == 0)
      {
        _NFIdebug ((fname, "Display Catalog ACL Mapping\n"));
        status = NFFdisplay_catalog_acl_mapping (TRUE);
        f_label = CATALOGACL_LABEL;
      }
    else if ((strcmp (command, NFI_M_DISPLAY_CATALOG_SA_MAPPING)) == 0)
      {
        _NFIdebug ((fname, "Display Catalog SA Mapping\n"));
        status = NFFdisplay_catalog_sa_mapping (TRUE);
        f_label = CATALOGSA_LABEL;
      }
    else if ((strcmp (command, NFI_M_DISPLAY_PROJECT_ACL_MAPPING)) == 0)
      {
        _NFIdebug ((fname, "Display Project ACL Mapping\n"));
        status = NFFdisplay_project_acl_mapping (TRUE);
        f_label = PROJECTACL_LABEL;
      }
    else if ((strcmp (command, NFI_M_DISPLAY_PROJECT_SA_MAPPING)) == 0)
      {
        _NFIdebug ((fname, "Display Project SA Mapping\n"));
        status = NFFdisplay_project_sa_mapping (TRUE);
        f_label = PROJECTSA_LABEL;
      }
    else if ((strcmp (command, NFI_M_DISPLAY_ITEMS_IN_PROJECT)) == 0)
      {
        _NFIdebug ((fname, "Display Items in Project\n"));
        status = NFFdisplay_project_members (TRUE);
        f_label = PROJM_LABEL;
      }
    else if ((strcmp (command, NFI_M_DISPLAY_SET_MEMBERS)) == 0)
      {
        _NFIdebug ((fname, "Display Set Members\n"));
        status = NFFdisplay_set_members (TRUE);
        f_label = SETM_LABEL;
      }
    else if ((strcmp (command, NFI_M_DISPLAY_WHERE_ITEM_USED_PROJECT)) == 0)
      {
        _NFIdebug ((fname, "Display Where Item Used in Project\n"));
        status = NFFwhere_used_project (TRUE);
        f_label = WHERE_PROJECT_LABEL;
      }
    else if ((strcmp (command, NFI_M_DISPLAY_WHERE_ITEM_USED_SET)) == 0)
      {
        _NFIdebug ((fname, "Display Where Item Used in Set\n"));
        status = NFFwhere_used_set (TRUE);
        f_label = WHERE_SET_LABEL;
      }
    else if ((strcmp (command, NFI_M_DISPLAY_ACL_CLASS_USERS)) == 0)
      {
        _NFIdebug ((fname, "Display Class Users\n"));
        status = NFFdisplay_aclusers (TRUE);
        f_label = ACLUSERS_LABEL;
      }
    else if ((strcmp (command, NFI_M_DISPLAY_ACL_SO_USERS)) == 0)
      {
        _NFIdebug ((fname, "Display Signoff Users\n"));
        status = NFFdisplay_signoff_users (TRUE);
        f_label = SIGNOFFUSERS_LABEL;
      }
    else if ((strcmp (command, NFI_M_DISPLAY_FILES_FLAGGED_ARCHIVE)) == 0)
      {
        _NFIdebug ((fname, "Display Archive Flags\n"));
        status = NFFdisplay_archive_flags (TRUE);
        f_label = ARCHIVES_LABEL;
      }
    else if ((strcmp (command, NFI_M_DISPLAY_FILES_FLAGGED_BACKUP)) == 0)
      {
        _NFIdebug ((fname, "Display Backup Flags\n"));
        status = NFFdisplay_backup_flags (TRUE);
        f_label = BACKUPS_LABEL;
      }
    else if ((strcmp (command, NFI_M_DISPLAY_FILES_FLAGGED_RESTORE)) == 0)
      {
        _NFIdebug ((fname, "Display Restore Flags\n"));
        status = NFFdisplay_restore_flags (TRUE);
        f_label = RESTORE_LABEL;
      }
    else if ((strcmp (command, NFI_M_DISPLAY_FILES_FLAGGED_DELETE)) == 0)
      {
        _NFIdebug ((fname, "Display Delete Flags\n"));
        status = NFFdisplay_delete_flags (TRUE);
        f_label = DELETE_LABEL;
      }
    else if ((strcmp (command, NFI_M_DISPLAY_ARCHIVES)) == 0)
      {
        _NFIdebug ((fname, "Display Archives\n"));
        status = NFFdisplay_archives (TRUE);
        f_label = LIST_ARCHIVES_LABEL;
      }
    else if ((strcmp (command, NFI_M_DISPLAY_SAVESETS)) == 0)
      {
        _NFIdebug ((fname, "Display Savesets\n"));
        status = NFFdisplay_savesets (TRUE);
        f_label = SAVESETS_LABEL;
      }
    else if ((strcmp (command, NFI_M_DISPLAY_ITEMS_ON_TAPE)) == 0)
      {
        _NFIdebug ((fname, "Display Items on Tape\n"));
        status = NFFdisplay_items_on_tape (TRUE);
        f_label = ITEMS_TAPE_LABEL;
      }
    else if ((strcmp (command, NFI_M_DISPLAY_SEARCH_CRITERIA)) == 0)
      {
        _NFIdebug ((fname, "Display Search Criteria\n"));
        status = NFFdisplay_search_criteria (TRUE);
        f_label = SEARCH_LABEL;
      }
    else if ((strcmp (command, NFI_M_DISPLAY_SORT_CRITERIA)) == 0)
      {
        _NFIdebug ((fname, "Display Sort Criteria\n"));
        status = NFFdisplay_sort_criteria (TRUE);
        f_label = SORT_LABEL;
      }
    else if ((strcmp (command, NFI_M_DISPLAY_LOCAL_FILES)) == 0)
      {
        _NFIdebug ((fname, "Display Local Files\n"));
        status = NFFdisplay_local_files (TRUE);
        f_label = LOCAL_FILES_LABEL;
      }
    else if ((strcmp (command, NFI_M_DISPLAY_LOCAL_FILES)) == 0)
      {
        _NFIdebug ((fname, "Display Local Files\n"));
        status = NFFdisplay_local_files (TRUE);
        f_label = LOCAL_FILES_LABEL;
      }
    else if ((strcmp (command, NFI_M_DELETE_COPIED_FILES)) == 0)
      {
        _NFIdebug ((fname, "Delete Copied Files\n"));
        status = NFFdelete_copied_files ();
        f_label = LOCAL_FILES_LABEL;
      }
    else if ((strcmp (command, NFI_M_LIST_SIGNOFF_ITEM)) == 0)
      {
        _NFIdebug ((fname, "Display Item Signoffs\n"));
        status = NFFdisplay_item_signoffs (TRUE);
        f_label = ITEM_SIGNOFF_LABEL;
      }
    else if ((strcmp (command, NFI_M_LIST_SIGNOFF_HISTORY)) == 0)
      {
        _NFIdebug ((fname, "Display Signoff History\n"));
        status = NFFdisplay_signoff_history (TRUE);
        f_label = SIGNOFF_HISTORY_LABEL;
      }
    else if ((strcmp (command, NFI_M_DISPLAY_ITEMS_ON_TAPE)) == 0)
      {
        _NFIdebug ((fname, "Display Items on Tape\n"));
        status = NFFdisplay_items_on_tape (TRUE);
        f_label = ITEMS_TAPE_LABEL;
      }
    else if ((strcmp (command, NFI_M_DISPLAY_SAVESETS)) == 0)
      {
        _NFIdebug ((fname, "Display List of Savesets\n"));
        status = NFFdisplay_savesets (TRUE);
        f_label = SAVESETS_LABEL;
      }
    else if ((strcmp (command, NFI_M_CLEAR_SAVESET)) == 0)
      {
        _NFIdebug ((fname, "Delete Saveset Entries\n"));
        status = NFFdelete_saveset_entries ();
      }
    else if ((strcmp (command, NFI_M_DISPLAY_ARCHIVES)) == 0)
      {
        _NFIdebug ((fname, "Display List of Archives\n"));
        status = NFFdisplay_archives (TRUE);
        f_label = LIST_ARCHIVES_LABEL;
      }
    else if ((strcmp (command, NFI_M_CREATE_CATALOG)) == 0)
      {
        _NFIdebug ((fname, "Create Catalog\n"));
        status = NFFcreate_catalog ();
      }
    else if ((strcmp (command, NFI_M_DELETE_CATALOG)) == 0)
      {
        _NFIdebug ((fname, "Delete Catalog\n"));
        status = NFFdelete_catalog (NFFglobal.catalog);
      }
    else if ((strcmp (command, NFI_M_CHANGE_CATALOG)) == 0)
      {
        _NFIdebug ((fname, "Change Catalog\n"));
        status = NFFchange_catalog (NFFglobal.catalog);
      }
    else if ((strcmp (command, NFI_M_ADD_ITEM)) == 0)
      {
        _NFIdebug ((fname, "Add Item\n"));
        status = NFFadd_init (NFFglobal.catalog, ADD_ITEM);
      }
    else if ((strcmp (command, NFI_M_CHANGE_ITEM)) == 0)
      {
        _NFIdebug ((fname, "Change Item\n"));
        status = NFFchange_item
            (NFFglobal.catalog, NFFglobal.item, NFFglobal.revision);
      }
    else if ((strcmp (command, NFI_M_DELETE_ITEM)) == 0)
      {
        _NFIdebug ((fname, "Delete Item\n"));
        status = NFFdelete_item (TRUE,
            NFFglobal.catalog, NFFglobal.item, NFFglobal.revision);
      }
    else if ((strcmp (command, NFI_M_LOCK_ITEM)) == 0)
      {
        _NFIdebug ((fname, "Lock Item\n"));
        status = NFFlock_item
            (NFFglobal.catalog, NFFglobal.item, NFFglobal.revision);
      }
    else if ((strcmp (command, NFI_M_UNLOCK_ITEM)) == 0)
      {
        _NFIdebug ((fname, "Unlock Item\n"));
        status = NFFunlock_item
            (NFFglobal.catalog, NFFglobal.item, NFFglobal.revision);
      }
    else if ((strcmp (command, NFI_M_COPY_ITEM)) == 0)
      {
        _NFIdebug ((fname, "Copy Item\n"));
        status = NFFcopy_item
            (NFFglobal.catalog, NFFglobal.item, NFFglobal.revision);
      }
    else if ((strcmp (command, NFI_M_ADD_ITEM_FILES)) == 0)
      {
        _NFIdebug ((fname, "Add Files to Item\n"));
        status = NFFadd_files_to_item
            (NFFglobal.catalog, NFFglobal.item, NFFglobal.revision);
      }
    else if ((strcmp (command, NFI_M_DELETE_ITEM_FILES)) == 0)
      {
        _NFIdebug ((fname, "Delete Files from Item\n"));
        status = NFFdelete_files_from_item
           (NFFglobal.catalog, NFFglobal.item, NFFglobal.revision);
      }
   else if ((strcmp (command, NFI_M_CHANGE_FILE_ATTRIBUTES)) == 0)
     {
        _NFIdebug ((fname, "Change File Attributes\n"));
        status = NFFchange_item_file_attributes
           (NFFglobal.catalog, NFFglobal.item, NFFglobal.revision);
      }
    else if ((strcmp (command, NFI_M_MAKE_ITEM_TRANSITION)) == 0)
      {
        _NFIdebug ((fname, "Make Transition\n"));
        status = NFFmake_transition ();
      }
    else if ((strcmp (command, NFI_M_ADD_NODE)) == 0)
      {
        _NFIdebug ((fname, "Add Node\n"));
        status = NFFadd_init ("", ADD_NODE);
      }
    else if ((strcmp (command, NFI_M_ADD_UTIL_SA)) == 0)
      {
        _NFIdebug ((fname, "Add Util Storage Area\n"));
        status = NFFadd_util_storage_area (NFFglobal.node);
      }
    else if ((strcmp (command, NFI_M_CHANGE_NODE)) == 0)
      {
        _NFIdebug ((fname, "Change Node\n"));
        status = NFFadd_init (NFFglobal.node, CHANGE_NODE);
      }
    else if ((strcmp (command, NFI_M_DELETE_NODE)) == 0)
      {
        _NFIdebug ((fname, "Delete Node\n"));
        status = NFFdelete_node (NFFglobal.node);
      }
    else if ((strcmp (command, NFI_M_ADD_USER)) == 0)
      {
        _NFIdebug ((fname, "Add User\n"));
        status = NFFadd_init ("", ADD_USER);
      }
    else if ((strcmp (command, NFI_M_CHANGE_USER)) == 0)
      {
        _NFIdebug ((fname, "Change User\n"));
        status = NFFadd_init (NFFglobal.user, CHANGE_USER);
      }
    else if ((strcmp (command, NFI_M_CHANGE_USER_PASSWD)) == 0)
      {
        _NFIdebug ((fname, "Change User's Password\n"));
        status = NFFchange_user_password (command, NFFglobal.username);
      }
    else if ((strcmp (command, NFI_M_CHANGE_PASSWD)) == 0)
      {
        _NFIdebug ((fname, "Change User's Password\n"));
        status = NFFchange_user_password (command, NFFglobal.username);
      }
    else if ((strcmp (command, NFI_M_DELETE_USER)) == 0)
      {
        _NFIdebug ((fname, "Delete User\n"));
        status = NFFdelete_user (NFFglobal.user);
      }
    else if ((strcmp (command, NFI_M_ADD_SA)) == 0)
      {
        _NFIdebug ((fname, "Add Storage Area\n"));
        status = NFFadd_init ("", ADD_SA);
      }
    else if ((strcmp (command, NFI_M_CHANGE_SA)) == 0)
      {
        _NFIdebug ((fname, "Change Storage Area\n"));
        status = NFFadd_init (NFFglobal.storage_area, CHANGE_SA);
      }
    else if ((strcmp (command, NFI_M_CHANGE_SA_PASSWD)) == 0)
      {
        _NFIdebug ((fname, "Change Storage Area Password\n"));
        status = NFFchange_storage_area_password (NFFglobal.storage_area);
      }
    else if ((strcmp (command, NFI_M_CHANGE_WA_PASSWD)) == 0)
      {
        _NFIdebug ((fname, "Change Working Area Password\n"));
        status = NFFchange_working_area_password (NFFglobal.working_area);
      }
    else if ((strcmp (command, NFI_M_DELETE_SA)) == 0)
      {
        _NFIdebug ((fname, "Delete Storage Area\n"));
        status = NFFdelete_storage_area (NFFglobal.storage_area);
      }
    else if ((strcmp (command, NFI_M_ADD_PROJECT)) == 0)
      {
        _NFIdebug ((fname, "Add Project\n"));
        status = NFFadd_init ("", ADD_PROJECT);
      }
    else if ((strcmp (command, NFI_M_CHANGE_PROJECT)) == 0)
      {
        _NFIdebug ((fname, "Change Project\n"));
        status = NFFadd_init (NFFglobal.project, CHANGE_PROJECT);
      }
    else if ((strcmp (command, NFI_M_DEFINE_DEBUG_MODE)) == 0)
      {
        _NFIdebug ((fname, "Define Debug\n"));
        status = NFFdebug ();
      }
    else if ((strcmp (command, NFI_M_ADD_ITEMS_TO_SET)) == 0)
      {
        _NFIdebug ((fname, "Add Items to Set\n"));
        status = NFFdefine_members
            (NFFglobal.project, NFFglobal.catalog,
            NFFglobal.item, NFFglobal.revision, command);
      }
    else if ((strcmp (command, NFI_M_DELETE_ITEMS_FROM_SET)) == 0)
      {
        _NFIdebug ((fname, "Delete Items from Set\n"));
        status = NFFdelete_set_members
            (NFFglobal.catalog, NFFglobal.item, NFFglobal.revision);
      }
    else if ((strcmp (command, NFI_M_DEFINE_SORT_CRITERIA)) == 0)
      {
        _NFIdebug ((fname, "Define Sort Criteria\n"));
        status = NFFdefine_sort_criteria (NFFglobal.catalog);
      }
    else if ((strcmp (command, NFI_M_DELETE_SORT_CRITERIA)) == 0)
      {
        _NFIdebug ((fname, "Delete Sort Criteria\n"));
        status = NFFdelete_sort_criteria (NFFglobal.sort);
      }
    else if ((strcmp (command, NFI_M_DEFINE_SEARCH_CRITERIA)) == 0)
      {
        _NFIdebug ((fname, "Define Search Criteria\n"));
        status = NFFdefine_search_criteria (NFFglobal.catalog);
      }
    else if ((strcmp (command, NFI_M_DELETE_SEARCH_CRITERIA)) == 0)
      {
        _NFIdebug ((fname, "Delete Search Criteria\n"));
        status = NFFdelete_search_criteria (NFFglobal.search);
      }
    else if ((strcmp (command, NFI_M_DELETE_PROJECT)) == 0)
      {
        _NFIdebug ((fname, "Delete Project\n"));
        status = NFFdelete_project (NFFglobal.project);
      }
    else if ((strcmp (command, NFI_M_ADD_ITEMS_TO_PROJECT)) == 0)
      {
        _NFIdebug ((fname, "Add Items to a Project\n"));
        status = NFFdefine_members (NFFglobal.project,
            NFFglobal.catalog, NFFglobal.item, NFFglobal.revision, command);
      }
    else if ((strcmp (command, NFI_M_DELETE_ITEMS_FROM_PROJECT)) == 0)
      {
        _NFIdebug ((fname, "Delete Items from a Project\n"));
        status = NFFdelete_project_members (NFFglobal.project);
      }
    else if ((strcmp (command, NFI_M_ADD_CATALOG_ACL_MAPPING)) == 0)
      {
        _NFIdebug ((fname, "Add Catalog ACL Mapping\n"));
        status = NFFadd_catalog_acl_mapping (NFFglobal.catalog);
      }
    else if ((strcmp (command, NFI_M_DELETE_CATALOG_ACL_MAPPING)) == 0)
      {
        _NFIdebug ((fname, "Delete Catalog ACL Mapping\n"));
        status = NFFdelete_catalog_acl_mapping (NFFglobal.catalog);
      }
    else if ((strcmp (command, NFI_M_ADD_CATALOG_SA_MAPPING)) == 0)
      {
        _NFIdebug ((fname, "Add Catalog SA Mapping\n"));
        status = NFFadd_catalog_sa_mapping (NFFglobal.catalog);
      }
    else if ((strcmp (command, NFI_M_DELETE_CATALOG_SA_MAPPING)) == 0)
      {
        _NFIdebug ((fname, "Delete Catalog SA Mapping\n"));
        status = NFFdelete_catalog_sa_mapping (NFFglobal.catalog);
      }
    else if ((strcmp (command, NFI_M_ADD_PROJECT_ACL_MAPPING)) == 0)
      {
        _NFIdebug ((fname, "Add Project ACL Mapping\n"));
        status = NFFadd_project_acl_mapping (NFFglobal.project);
      }
    else if ((strcmp (command, NFI_M_DELETE_PROJECT_ACL_MAPPING)) == 0)
      {
        _NFIdebug ((fname, "Delete Project ACL Mapping\n"));
        status = NFFdelete_project_acl_mapping (NFFglobal.project);
      }
    else if ((strcmp (command, NFI_M_ADD_PROJECT_SA_MAPPING)) == 0)
      {
        _NFIdebug ((fname, "Add Project SA Mapping\n"));
        status = NFFadd_project_sa_mapping (NFFglobal.project);
      }
    else if ((strcmp (command, NFI_M_DELETE_PROJECT_SA_MAPPING)) == 0)
      {
        _NFIdebug ((fname, "Delete Project SA Mapping\n"));
        status = NFFdelete_project_sa_mapping (NFFglobal.project);
      }
    else if ((strcmp (command, NFI_M_DEFINE_ACL)) == 0)
      {
        _NFIdebug ((fname, "Define an Access Control List\n"));
        status = NFFadd_acl ();
      }
    else if ((strcmp (command, NFI_M_DELETE_ACL)) == 0)
      {
        _NFIdebug ((fname, "Delete an Access Control List\n"));
        status = NFFdelete_acl (NFFglobal.workflow, NFFglobal.acl);
      }
    else if ((strcmp (command, NFI_M_ADD_ACL_CLASS_USERS)) == 0)
      {
        _NFIdebug ((fname, "Add Class Users to an ACL\n"));
        status = NFFadd_acl_class_users (0, NFFglobal.acl);
      }
    else if ((strcmp (command, NFI_M_ADD_ACL_CLASS_USERS_DEFINE)) == 0)
      {
        _NFIdebug ((fname, "Add Class Users to an ACL\n"));
        status = NFFadd_acl_class_users (1, NFFglobal.acl);
      }
    else if ((strcmp (command, NFI_M_DELETE_ACL_CLASS_USERS)) == 0)
      {
        _NFIdebug ((fname, "Delete Class Users from an ACL\n"));
        status = NFFdelete_acl_class_users (NFFglobal.acl);
      }
    else if ((strcmp (command, NFI_M_ADD_ACL_SIGNOFF_USERS)) == 0)
      {
        _NFIdebug ((fname, "Add Signoff Users to an ACL\n"));
        status = NFFadd_acl_signoff_users (NFFglobal.acl);
      }
    else if ((strcmp (command, NFI_M_DELETE_ACL_SIGNOFF_USERS)) == 0)
      {
        _NFIdebug ((fname, "Delete Signoff Users from an ACL\n"));
        status = NFFdelete_acl_signoff_users (NFFglobal.acl);
      }
    else if ((strcmp (command, NFI_M_SIGNOFF_ITEM)) == 0)
      {
        _NFIdebug ((fname, "Signoff on Item\n"));
        status = NFFsignoff_on_item ();
      }
    else if ((strcmp (command, NFI_M_PURGE_SIGNOFF)) == 0)
      {
        _NFIdebug ((fname, "Purge Signoff\n"));
        status = NFFpurge_signoff
            (NFFglobal.catalog, NFFglobal.item, NFFglobal.revision);
      }
    else if ((strcmp (command, NFI_M_LOGIN_TO_ENVIRONMENT)) == 0)
      {
        _NFIdebug ((fname, "Login to Environment\n"));
        status = NFFform_login ();
      }
    else if ((strcmp (command, NFI_M_CHECK_IN)) == 0)
      {
        if (strcmp (NFFglobal.set_indicator, "") == 0)
         {
            _NFIdebug ((fname, "Checkin Item\n"));
            status = NFFcheckin_item (TRUE,
                NFFglobal.catalog, NFFglobal.item, NFFglobal.revision);
         }
        else
         {
            _NFIdebug ((fname, "Checkin Set\n"));
            status = NFFcheckin_set (TRUE,
                NFFglobal.catalog, NFFglobal.item, NFFglobal.revision);
         }
      }
    else if ((strcmp (command, NFI_M_CHECK_IN_SET_ITEM)) == 0)
      {
         _NFIdebug ((fname, "Checkin Item\n"));
         status = NFFcheckin_item (TRUE,
                NFFglobal.catalog, NFFglobal.item, NFFglobal.revision);
      }
    else if ((strcmp (command, NFI_M_CHECK_OUT)) == 0)
      {
        if (strcmp (NFFglobal.set_indicator, "") == 0)
         {
            _NFIdebug ((fname, "Checkout Item\n"));
            status = NFFcheckout_item (TRUE,
                NFFglobal.catalog, NFFglobal.item, NFFglobal.revision);
         }
        else
         {
             _NFIdebug ((fname, "Checkout Set\n"));
             status = NFFcheckout_set (TRUE,
                 NFFglobal.catalog, NFFglobal.item, NFFglobal.revision);
         }
      }
    else if ((strcmp (command, NFI_M_CHECK_OUT_SET_ITEM)) == 0)
      {
         _NFIdebug ((fname, "Checkout Item\n"));
         status = NFFcheckout_item (TRUE,
                NFFglobal.catalog, NFFglobal.item, NFFglobal.revision);
      }
    else if ((strcmp (command, NFI_M_COPY_ITEM_FILES)) == 0)
      {
        if (strcmp (NFFglobal.set_indicator, "") == 0)
         {
            _NFIdebug ((fname, "Copy Item Files\n"));
            status = NFFn_copy_item_files (TRUE,
                NFFglobal.catalog, NFFglobal.item, NFFglobal.revision);
         }
        else
         {
            _NFIdebug ((fname, "Copy Set Files\n"));
            status = NFFn_copy_set_files (TRUE,
                NFFglobal.catalog, NFFglobal.item, NFFglobal.revision);
         }
      }
    else if ((strcmp (command, NFI_M_COPY_SET_ITEM_FILES)) == 0)
      {
         _NFIdebug ((fname, "Copy Item Files\n"));
         status = NFFn_copy_item_files (TRUE,
                NFFglobal.catalog, NFFglobal.item, NFFglobal.revision);
      }
    else if ((strcmp (command, NFI_M_CANCEL_CHECK_OUT)) == 0)
      {
        if (strcmp (NFFglobal.set_indicator, "") == 0)
         {
            _NFIdebug ((fname, "Cancel Item Checkout\n"));
            status = NFFcancel_item_checkout (TRUE, NFFglobal.catalog,
                                          NFFglobal.item, NFFglobal.revision);
         }
        else
         {
            _NFIdebug ((fname, "Cancel Set Checkout\n"));
            status = NFFcancel_set_checkout (TRUE, NFFglobal.catalog,
                                          NFFglobal.item, NFFglobal.revision);
         }
      }
    else if ((strcmp (command, NFI_M_CANCEL_SET_ITEM_CHECK_OUT)) == 0)
      {
         _NFIdebug ((fname, "Cancel Item Checkout\n"));
         status = NFFcancel_item_checkout (TRUE, NFFglobal.catalog,
                                          NFFglobal.item, NFFglobal.revision);
      }
    else if ((strcmp (command, NFI_M_FLAG_ARCHIVE)) == 0)
      {
        if (strcmp (NFFglobal.set_indicator, "") == 0)
         {
            _NFIdebug ((fname, "Flag Item Files for Archive\n"));
            status = NFFflag_item_files (TRUE, FLAG_ARCHIVE, NFFglobal.catalog,
                                         NFFglobal.item, NFFglobal.revision);
         }
        else
         {
            _NFIdebug ((fname, "Flag Set Files for Archive\n"));
            status = NFFflag_set_files (TRUE, FLAG_ARCHIVE, NFFglobal.catalog,
                                        NFFglobal.item, NFFglobal.revision);
         }
      }
    else if ((strcmp (command, NFI_M_FLAG_BACKUP)) == 0)
      {
        if (strcmp (NFFglobal.set_indicator, "") == 0)
         {
            _NFIdebug ((fname, "Flag Item Files for Backup\n"));
            status = NFFflag_item_files (TRUE, FLAG_BACKUP, NFFglobal.catalog,
                                         NFFglobal.item, NFFglobal.revision);
         }
        else
         {
            _NFIdebug ((fname, "Flag Set Files for Backup\n"));
            status = NFFflag_set_files (TRUE, FLAG_BACKUP, NFFglobal.catalog,
                                        NFFglobal.item, NFFglobal.revision);
         }
      }
    else if ((strcmp (command, NFI_M_FLAG_RESTORE)) == 0)
      {
        if (strcmp (NFFglobal.set_indicator, "") == 0)
          {
            _NFIdebug ((fname, "Flag Item Versions for Restore\n")) ;
	    sel = FALSE;

            if (NFFglobal.forms[ITEMS_LABEL] != NULL)
              {
		/*  Make sure there are rows selected in the List of
		 *  Items.
		 */

	        FIfld_get_num_rows (NFFglobal.forms[ITEMS_LABEL], MCF, 
				    &num_rows);

	        for (row = 0; row < num_rows; ++row)
	          {
	            FIfld_get_select (NFFglobal.forms[ITEMS_LABEL], MCF, 
				      row, 0, &sel);
	            if( sel )
		    {
                        _NFIdebug ((fname, "Flag Item Files for Restore\n"));
                        status = NFFflag_item_files (TRUE, FLAG_RESTORE, 
                              NFFglobal.catalog, NFFglobal.item, 
                              NFFglobal.revision);
		        break;
		    }
		  }

	        if( !sel )
 		  {
		     _NFIdebug(( fname, "Flag Files from a Restore List -- No selected items in List of Items\n" ));
	             status = NFFnflag_item_files (NFFglobal.catalog,
                          NFFglobal.item, NFFglobal.revision, FLAG_RESTORE);
		  }
              }
            else
              {
                _NFIdebug(( fname, "The item is a set\n" ));
                status = NFFnflag_item_files (NFFglobal.catalog,
                           NFFglobal.item, NFFglobal.revision, FLAG_RESTORE) ;
              }
          }
        else
          {
            _NFIdebug ((fname, "Flag Set Files for Restore\n"));
            status = NFFflag_set_files (TRUE, FLAG_RESTORE, NFFglobal.catalog,
                                        NFFglobal.item, NFFglobal.revision);
          }
      }
    else if ((strcmp (command, NFI_M_FLAG_DELETE)) == 0)
      {
        _NFIdebug ((fname, "Flag Item Files for Delete\n"));
        status = NFFflag_item_files (TRUE, FLAG_DELETE, NFFglobal.catalog,
                                     NFFglobal.item, NFFglobal.revision);
      }
    else if ((strcmp (command, NFI_M_FLAG_SET_ITEM_FOR_BACKUP)) == 0)
      {
        _NFIdebug ((fname, "Flag Set Item Files for Backup\n"));
        status = NFFflag_item_files (TRUE, FLAG_BACKUP, NFFglobal.catalog,
                                     NFFglobal.item, NFFglobal.revision);
      }
    else if ((strcmp (command, NFI_M_ROLL_VERSION_FORWARD)) == 0)
      {
        _NFIdebug ((fname, "Roll Item Version Forward\n"));
        status = NFFroll_version_forward (NFFglobal.catalog,
                                          NFFglobal.item, NFFglobal.revision);
      }
    else if ((strcmp (command, NFI_M_PURGE_FILE_VERSION)) == 0)
      {
        _NFIdebug ((fname, "Purge Item File Version\n"));
        status = NFFpurge_file_versions (TRUE, NFFglobal.catalog,
                                         NFFglobal.item, NFFglobal.revision);
      }
    else if ((strcmp (command, NFI_M_FLAG_PROJECT_FILES_ARCHIVE)) == 0)
      {
        _NFIdebug ((fname, "Flag Project Files for archive\n"));
        status = NFFflag_project_files (TRUE, FLAG_ARCHIVE, NFFglobal.project);
      }
    else if ((strcmp (command, NFI_M_FLAG_PROJECT_FILES_BACKUP)) == 0)
      {
        _NFIdebug ((fname, "Flag Project Files for backup\n"));
        status = NFFflag_project_files (TRUE, FLAG_BACKUP, NFFglobal.project);
      }
    else if ((strcmp (command, NFI_M_FLAG_PROJECT_FILES_RESTORE)) == 0)
      {
        _NFIdebug ((fname, "Flag Project Files for restore\n"));
        status = NFFflag_project_files (TRUE, FLAG_RESTORE, NFFglobal.project);
      }
    else if ((strcmp (command, NFI_M_CANCEL_ARCHIVE_FLAG)) == 0)
      {
         if (strcmp (NFFglobal.set_indicator, "") == 0)
          {
             _NFIdebug ((fname, "Cancel Item Archive Flag \n"));
             status = NFFcancel_item_flag (TRUE, CANCEL_ARCHIVE,
                       NFFglobal.catalog, NFFglobal.item, NFFglobal.revision);
          }
         else
          {
             _NFIdebug ((fname, "Cancel Set Archive Flag \n"));
             status = NFFcancel_set_flag (TRUE, CANCEL_ARCHIVE,
                        NFFglobal.catalog, NFFglobal.item, NFFglobal.revision);
          }
      }
    else if ((strcmp (command, NFI_M_CANCEL_BACKUP_FLAG)) == 0)
      {
         if (strcmp (NFFglobal.set_indicator, "") == 0)
          {
             _NFIdebug ((fname, "Cancel Item Backup Flag \n"));
             status = NFFcancel_item_flag (TRUE, CANCEL_BACKUP,
                       NFFglobal.catalog, NFFglobal.item, NFFglobal.revision);
          }
         else
          {
             _NFIdebug ((fname, "Cancel Set Backup Flag \n"));
             status = NFFcancel_set_flag (TRUE, CANCEL_BACKUP,
                       NFFglobal.catalog, NFFglobal.item, NFFglobal.revision);
          }
      }
    else if ((strcmp (command, NFI_M_CANCEL_RESTORE_FLAG)) == 0)
      {
         if (strcmp (NFFglobal.set_indicator, "") == 0)
          {
             _NFIdebug ((fname, "Cancel Item Restore Flag \n"));
             status = NFFcancel_item_flag (TRUE, CANCEL_RESTORE,
                       NFFglobal.catalog, NFFglobal.item, NFFglobal.revision);
          }
         else
          {
             _NFIdebug ((fname, "Cancel Set Restore Flag \n"));
             status = NFFcancel_set_flag (TRUE, CANCEL_RESTORE,
                       NFFglobal.catalog, NFFglobal.item, NFFglobal.revision);
          }
      }
    else if ((strcmp (command, NFI_M_CANCEL_DELETE_FLAG)) == 0)
      {
        _NFIdebug ((fname, "Cancel Item Flag \n"));
        status = NFFcancel_item_flag (TRUE, CANCEL_DELETE, NFFglobal.catalog,
                                      NFFglobal.item, NFFglobal.revision);
      }
    else if ((strcmp (command, NFI_M_CAN_SET_ITEM_BACKUP_FLAG)) == 0)
      {
          _NFIdebug ((fname, "Cancel Item Backup Flag \n"));
          status = NFFcancel_item_flag (TRUE, CANCEL_BACKUP,
                         NFFglobal.catalog, NFFglobal.item, NFFglobal.revision);
      }
    else if ((strcmp (command, NFI_M_CANCEL_ARCHIVE_FLAG_PROJECT)) == 0)
      {
        _NFIdebug ((fname, "Cancel Item Flag \n"));
        status = NFFcancel_project_flag (TRUE, CANCEL_ARCHIVE,
                                         NFFglobal.project);
      }
    else if ((strcmp (command, NFI_M_CANCEL_BACKUP_FLAG_PROJECT)) == 0)
      {
        _NFIdebug ((fname, "Cancel Item Flag \n"));
        status = NFFcancel_project_flag (TRUE, CANCEL_BACKUP,
                                         NFFglobal.project);
      }
    else if ((strcmp (command, NFI_M_CANCEL_RESTORE_FLAG_PROJECT)) == 0)
      {
        _NFIdebug ((fname, "Cancel Item Flag \n"));
        status = NFFcancel_project_flag (TRUE, CANCEL_RESTORE,
                                         NFFglobal.project);
      }
    else if ((strcmp (command, NFI_M_PROCESS_FLAGGED_FILES)) == 0)
      {
        _NFIdebug ((fname, "Process Flagged Files\n"));
        status = NFFprocess_flagged_files ();
      }
    else if ((strcmp (command, NFI_M_ROLL_VERSION_FORWARD)) == 0)
      {
        _NFIdebug ((fname, "Roll File Version Forward \n"));
        status = NFFroll_version_forward (NFFglobal.catalog,  
                                          NFFglobal.item, NFFglobal.revision);
      }
    else if ((strcmp (command, NFI_M_CHANGE_WORKFLOW_OF_ITEM)) == 0)
      {
        _NFIdebug ((fname, "Change Workflow of Item \n"));
        status = NFFchange_item_workflow ();
      }
    else if ((strcmp (command, NFI_M_PLOT_ITEM)) == 0)
      {
        if (strcmp (NFFglobal.set_indicator, "") == 0)
          {
            _NFIdebug ((fname, "Plot Item\n"));
            status = NFFplot_item (TRUE,
                NFFglobal.catalog, NFFglobal.item, NFFglobal.revision);
          }
        else
          {
            _NFIdebug ((fname, "Plot Set\n"));
            status = NFFplot_set (TRUE,
                NFFglobal.catalog, NFFglobal.item, NFFglobal.revision);
          }
      }
    else if ((strcmp (command, NFI_M_PLOT_SET_PARENT)) == 0)
      {
        _NFIdebug ((fname, "Plot Set Parent\n"));
        status = NFFplot_set_parent
            (NFFglobal.catalog, NFFglobal.item, NFFglobal.revision);
      }
    else if ((strcmp (command, NFI_M_SAVE_ITEM)) == 0)
      {
        if (strcmp (NFFglobal.set_indicator, "") == 0)
          {
            _NFIdebug ((fname, "Save Item\n"));
            status = NFFsave_item (TRUE,
                NFFglobal.catalog, NFFglobal.item, NFFglobal.revision);
          }
        else
          {
            _NFIdebug ((fname, "Save Set\n"));
            status = NFFsave_set (TRUE,
                NFFglobal.catalog, NFFglobal.item, NFFglobal.revision);
          }
      }
    else if ((strcmp (command, NFI_M_SAVE_SET_PARENT)) == 0)
      {
        _NFIdebug ((fname, "Save Set Parent\n"));
        status = NFFsave_set_parent
            (NFFglobal.catalog, NFFglobal.item, NFFglobal.revision);
      }
    else if ((strcmp (command, NFI_M_COPY_ACL_USERS)) == 0)
      {
        _NFIdebug ((fname, "Copy ACL Users\n")) ;
        status = NFFcopy_acl_users ();
      }
    else if ((strcmp (command, NFI_M_DELETE_TAPE_LABELS)) == 0)
      {
        _NFIdebug ((fname, "Display List of Tape Labels\n"));
        status = NFFdisplay_tape_labels ();
      }
    else
      {
        /*  For now, until all commands have been implemented  */

        ERRload_struct (NFI, NFI_I_NO_COMMAND, NULL);
      }

    /*  Timestamp the first part of the command  */

    if ((NFFglobal.current_form != NULL) && (status != NFI_S_SUCCESS))
      {
	_NFIdebug(( fname, "Call NFFerror_message with CURRENT FORM\n" ));
        NFFerror_message (NFFglobal.current_form);
 
        /*  End of the first part of the command  */

        _NFFts_data (("User Form Displayed -  %d\n", time ((long *) 0)));
      }
    else if (f_label != -1) 
      {
        NFFerror_message (NFFglobal.forms[f_label]);

        /*  Commit the data into the timestamp file  */

        _NFFts_data (("End of Command      -  %d\n", time ((long *) 0)));
        _NFFts_commit ();
      }
    else if (status != NFI_S_SUCCESS)
      {
        NFFerror_message (NFFglobal.forms[MAIN_LABEL]);

        /*  Commit the data into the timestamp file  */

        _NFFts_data (("End of Command      -  %d\n", time ((long *) 0)));
        _NFFts_commit ();
      }
    else
      {
        /*  End of the first part of the command  */

        _NFFts_data (("User Form Displayed -  %d\n", time ((long *) 0)));
      }

    _NFIdebug ((fname, " returning ...\n\n"));
    return;
  }


void _NFFdelete_forms ()
  {
    auto   int  i;

    MS_delete_menus ();

    for (i = 0; i < NUMBER_OF_FORMS; ++i)
      {
        if (NFFglobal.forms[i] != NULL)
	  {
            FIf_delete (NFFglobal.forms[i]);
	    NFFglobal.forms[i] = NULL;
	  }
      }

    if (NFFglobal.current_form != NULL)
      {
        FIf_delete (NFFglobal.current_form);
	NFFglobal.current_form = NULL;
      }


    if (NFFglobal.debug_form != NULL)
      {
        FIf_delete (NFFglobal.debug_form);
	NFFglobal.debug_form = NULL;
      }

    if (NFFglobal.popup_form != NULL)
      {
        FIf_delete (NFFglobal.popup_form);
	NFFglobal.popup_form = NULL;
      }

    if (NFFglobal.error_form != NULL)
      {
        FIf_delete (NFFglobal.error_form);
	NFFglobal.error_form = NULL;
      }

    if (NFFglobal.add_util_sa_form != NULL)
      {
        FIf_delete (NFFglobal.add_util_sa_form);
	NFFglobal.add_util_sa_form = NULL;
      }
  }
