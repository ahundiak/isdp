
/* machine.h included to take care of platform variencies MVR 23 Dec 1993 */
#include "machine.h"

#include "NFF.h"
#include "WFcommands.h"
#include "NFFtimestamp.h"
#include "NFFjournal.h"
#include "NFFvalidate.h"

/*  Global NFF structure  */

extern struct NFFglobal_st NFFglobal;

long NFFvalidate_user_access (command_key)
  char    *command_key;  /*  i - command string stored in the panel menu  */
  {
    auto    long    status;
    auto    char    command[NFM_COMMANDNAME];
    auto    char    wf_name[NFM_WORKFLOWNAME];
    auto    char    project[NFM_PROJECTNAME];
    auto    char    catalog[NFM_CATALOGNAME];
    auto    char    item[NFM_ITEMNAME];
    auto    char    revision[NFM_ITEMREV];
    auto    short   do_not_validate = FALSE;
    auto    short   cleanup_listings = TRUE;
    auto    short   cleanup_items_only = FALSE;
    static  char    *fname = "NFFvalidate_user_access";

    /*  Default validation mask  */

    auto    long    default_mask = NFF_CONNECT | NFF_LOGIN;

    _NFIdebug ((fname, "command_key = <%s>\n", command_key));

    /*  Initialize wf info  */

    strcpy (wf_name, "");
    strcpy (project, "");
    strcpy (catalog, "");
    strcpy (item, "");
    strcpy (revision, "");

#ifdef COMBINED_CLIENT_SERVER
    default_mask = NFF_LOGIN;
#endif

    /*  Find the workflow command name for this command  */

    if ((strcmp (command_key, NFI_M_CREATE_CATALOG)) == 0)
      {
        if ((status = _NFFvalidate_active_data
            (default_mask)) != NFI_S_SUCCESS)
          {
            _NFIdebug ((fname,
                "_NFFvalidate_active_data = <0x%.8x>\n", status));
            return (status);
          }

        strcpy (command, CREATE_CATALOG);
      }
    else if ((strcmp (command_key, NFI_M_ADD_ITEM)) == 0)
      {
        if ((status = _NFFvalidate_active_data
            (default_mask | NFF_CATALOG)) != NFI_S_SUCCESS)
          {
            _NFIdebug ((fname,
                "_NFFvalidate_active_data = <0x%.8x>\n", status));
            return (status);
          }

        strcpy (command, ADD_ITEM);
        strcpy (catalog, NFFglobal.catalog);

        /*  See if there is a project active  */

        if (NFFglobal.project_active == TRUE)
            strcpy (project, NFFglobal.project);
      }
    else if ((strcmp (command_key, NFI_M_CHANGE_ITEM)) == 0)
      {
        if ((status = _NFFvalidate_active_data (default_mask |
            NFF_CATALOG | NFF_ITEM | NFF_REVISION)) != NFI_S_SUCCESS)
          {
            _NFIdebug ((fname,
                "_NFFvalidate_active_data = <0x%.8x>\n", status));
            return (status);
          }

        strcpy (command, CHANGE_ITEM);
        strcpy (catalog, NFFglobal.catalog);
        strcpy (item, NFFglobal.item);
        strcpy (revision, NFFglobal.revision);
      }
    else if ((strcmp (command_key, NFI_M_ADD_ITEM_FILES)) == 0)
       {
         if ((status = _NFFvalidate_active_data (default_mask |
             NFF_CATALOG | NFF_ITEM | NFF_REVISION)) != NFI_S_SUCCESS)
           {
             _NFIdebug ((fname,
                 "_NFFvalidate_active_data = <0x%.8x>\n", status));
             return (status);
           }

         strcpy (command, ADD_FILES_TO_ITEM);
         strcpy (catalog, NFFglobal.catalog);
         strcpy (item, NFFglobal.item);
         strcpy (revision, NFFglobal.revision);
       }
    else if ((strcmp (command_key, NFI_M_CHANGE_WORKFLOW_OF_ITEM)) == 0)
      {
        if ((status = _NFFvalidate_active_data (default_mask |
            NFF_CATALOG | NFF_ITEM | NFF_REVISION | NFF_LIST))!= NFI_S_SUCCESS)
          {
            _NFIdebug ((fname,
                "_NFFvalidate_active_data = <0x%.8x>\n", status));
            return (status);
          }

        strcpy (command, CHANGE_WF_OF_ITEM);
        strcpy (catalog, NFFglobal.catalog);
        strcpy (item, NFFglobal.item);
        strcpy (revision, NFFglobal.revision);
      }
    else if ((strcmp (command_key, NFI_M_DELETE_ITEM_FILES)) == 0)
       {
         if ((status = _NFFvalidate_active_data (default_mask |
             NFF_CATALOG | NFF_ITEM | NFF_REVISION)) != NFI_S_SUCCESS)
           {
             _NFIdebug ((fname,
                 "_NFFvalidate_active_data = <0x%.8x>\n", status));
             return (status);
           }

         strcpy (command, DELETE_FILES_FROM_ITEM);
         strcpy (catalog, NFFglobal.catalog);
         strcpy (item, NFFglobal.item);
         strcpy (revision, NFFglobal.revision);
       }
    else if ((strcmp (command_key, NFI_M_CHANGE_FILE_ATTRIBUTES)) == 0)
       {
         if ((status = _NFFvalidate_active_data (default_mask |
             NFF_CATALOG | NFF_ITEM | NFF_REVISION)) != NFI_S_SUCCESS)
           {
             _NFIdebug ((fname,
                 "_NFFvalidate_active_data = <0x%.8x>\n", status));
             return (status);
           }

         strcpy (command, CHANGE_FILE_ATTRIBUTES);
         strcpy (catalog, NFFglobal.catalog);
         strcpy (item, NFFglobal.item);
         strcpy (revision, NFFglobal.revision);
       }
    else if ((strcmp (command_key, NFI_M_ADD_NODE)) == 0)
      {
        if ((status = _NFFvalidate_active_data
            (default_mask)) != NFI_S_SUCCESS)
          {
            _NFIdebug ((fname,
                "_NFFvalidate_active_data = <0x%.8x>\n", status));
            return (status);
          }

        strcpy (command, ADD_NODE);
      }
    else if ((strcmp (command_key, NFI_M_CHANGE_NODE)) == 0)
      {
        if ((status = _NFFvalidate_active_data
            (default_mask | NFF_NODE)) != NFI_S_SUCCESS)
          {
            _NFIdebug ((fname,
                "_NFFvalidate_active_data = <0x%.8x>\n", status));
            return (status);
          }

        strcpy (command, CHANGE_NODE);
      }
    else if ((strcmp (command_key, NFI_M_ADD_USER)) == 0)
      {
        if ((status = _NFFvalidate_active_data
            (default_mask)) != NFI_S_SUCCESS)
          {
            _NFIdebug ((fname,
                "_NFFvalidate_active_data = <0x%.8x>\n", status));
            return (status);
          }

        strcpy (command, ADD_USER);
      }
    else if ((strcmp (command_key, NFI_M_CHANGE_USER)) == 0)
      {
        if ((status = _NFFvalidate_active_data
            (default_mask | NFF_USER)) != NFI_S_SUCCESS)
          {
            _NFIdebug ((fname,
                "_NFFvalidate_active_data = <0x%.8x>\n", status));
            return (status);
          }

        strcpy (command, CHANGE_USER);
      }
    else if ((strcmp (command_key, NFI_M_ADD_SA)) == 0)
      {
        if ((status = _NFFvalidate_active_data
            (default_mask)) != NFI_S_SUCCESS)
          {
            _NFIdebug ((fname,
                "_NFFvalidate_active_data = <0x%.8x>\n", status));
            return (status);
          }

        strcpy (command, ADD_SA);
      }
    else if ((strcmp (command_key, NFI_M_CHANGE_SA)) == 0)
      {
        if ((status = _NFFvalidate_active_data
            (default_mask | NFF_ST_AREA)) != NFI_S_SUCCESS)
          {
            _NFIdebug ((fname,
                "_NFFvalidate_active_data = <0x%.8x>\n", status));
            return (status);
          }

        strcpy (command, CHANGE_SA);
      }
    else if ((strcmp (command_key, NFI_M_CHANGE_WA_PASSWD)) == 0)
      {
        if ((status = _NFFvalidate_active_data
            (default_mask | NFF_WORKING_AREA )) != NFI_S_SUCCESS)
          {
            _NFIdebug ((fname,
                "_NFFvalidate_active_data = <0x%.8x>\n", status));
            return (status);
          }

        strcpy (command, CHANGE_WORKING_AREA_PWD);
      }
    else if ((strcmp (command_key, NFI_M_ADD_PROJECT)) == 0)
      {
        if ((status = _NFFvalidate_active_data
            (default_mask)) != NFI_S_SUCCESS)
          {
            _NFIdebug ((fname,
                "_NFFvalidate_active_data = <0x%.8x>\n", status));
            return (status);
          }

        strcpy (command, ADD_PROJECT);
      }
    else if ((strcmp (command_key, NFI_M_CHANGE_PROJECT)) == 0)
      {
        if ((status = _NFFvalidate_active_data
            (default_mask | NFF_PROJECT)) != NFI_S_SUCCESS)
          {
            _NFIdebug ((fname,
                "_NFFvalidate_active_data = <0x%.8x>\n", status));
            return (status);
          }

        strcpy (command, CHANGE_PROJECT);
        strcpy (project, NFFglobal.project);
      }
    else if ((strcmp (command_key, NFI_M_DEFINE_DEBUG_MODE)) == 0)
      {
        /*  There is no need to end the block listings  */

        cleanup_listings = FALSE;

        strcpy (command, "Define I/NFM Debug Mode");
        do_not_validate = TRUE;
      }
    else if ((strcmp (command_key, NFI_M_RETRIEVE_DEFAULT_DATA)) == 0)
      {
        /*  There is no need to end the block listings  */

        cleanup_listings = FALSE;

        if ((status = _NFFvalidate_active_data
            (default_mask)) != NFI_S_SUCCESS)
          {
            _NFIdebug ((fname,
                "_NFFvalidate_active_data = <0x%.8x>\n", status));
            return (status);
          }

        strcpy (command, "Retrieve Default Data");
        do_not_validate = TRUE;
      }
    else if ((strcmp (command_key, NFI_M_DISPLAY_PROJECTS)) == 0)
      {
        /*  There is no need to end the block listings  */

        cleanup_listings = FALSE;

        if ((status = _NFFvalidate_active_data
            (default_mask)) != NFI_S_SUCCESS)
          {
            _NFIdebug ((fname,
                "_NFFvalidate_active_data = <0x%.8x>\n", status));
            return (status);
          }

        strcpy (command, LIST_PROJECTS);
      }
    else if ((strcmp (command_key, NFI_M_DISPLAY_ITEMS_IN_PROJECT)) == 0)
      {
        /*  There is no need to end the block listings  */

        cleanup_listings = FALSE;

        if ((status = _NFFvalidate_active_data
            (default_mask | NFF_PROJECT)) != NFI_S_SUCCESS)
          {
            _NFIdebug ((fname,
                "_NFFvalidate_active_data = <0x%.8x>\n", status));
            return (status);
          }

        strcpy (command, LIST_PROJECT_ITEMS);
        strcpy (project, NFFglobal.project);
      }
    else if ((strcmp (command_key, NFI_M_DISPLAY_CATALOGS)) == 0)
      {
        /*  There is no need to end the block listings  */

        cleanup_listings = FALSE;

        if ((status = _NFFvalidate_active_data
            (default_mask)) != NFI_S_SUCCESS)
          {
            _NFIdebug ((fname,
                "_NFFvalidate_active_data = <0x%.8x>\n", status));
            return (status);
          }

        strcpy (command, LIST_CATALOGS);
      }
    else if ((strcmp (command_key, NFI_M_DISPLAY_CATALOGS_ALL)) == 0)
      {
        /*  There is no need to end the block listings  */

        cleanup_listings = FALSE;

        if ((status = _NFFvalidate_active_data
            (default_mask)) != NFI_S_SUCCESS)
          {
            _NFIdebug ((fname,
                "_NFFvalidate_active_data = <0x%.8x>\n", status));
            return (status);
          }

        strcpy (command, LIST_CATALOGS);
      }
    else if ((strcmp (command_key, NFI_M_DISPLAY_ITEMS)) == 0)
      {
        /*  There is no need to end the block listings  */

        cleanup_listings = FALSE;
	cleanup_items_only = TRUE;

        if ((status = _NFFvalidate_active_data
            (default_mask | NFF_CATALOG)) != NFI_S_SUCCESS)
          {
            _NFIdebug ((fname,
                "_NFFvalidate_active_data = <0x%.8x>\n", status));
            return (status);
          }

        strcpy (command, LIST_ITEMS);
        strcpy (catalog, NFFglobal.catalog);
      }
    else if ((strcmp (command_key, NFI_M_DISPLAY_ITEMS_ALL)) == 0)
      {
        /*  There is no need to end the block listings  */

        cleanup_listings = FALSE;
	cleanup_items_only = TRUE;

        if ((status = _NFFvalidate_active_data
            (default_mask | NFF_CATALOG)) != NFI_S_SUCCESS)
          {
            _NFIdebug ((fname,
                "_NFFvalidate_active_data = <0x%.8x>\n", status));
            return (status);
          }

        strcpy (command, LIST_ITEMS);
        strcpy (catalog, NFFglobal.catalog);
      }
    else if ((strcmp (command_key, NFI_M_REVIEW_ITEM_ATTRIBUTES)) == 0)
      {
        /*  There is no need to end the block listings  */

        cleanup_listings = FALSE;

        if ((status = _NFFvalidate_active_data (default_mask |
            NFF_CATALOG | NFF_ITEM | NFF_REVISION)) != NFI_S_SUCCESS)
          {
            _NFIdebug ((fname,
                "_NFFvalidate_active_data = <0x%.8x>\n", status));
            return (status);
          }

        strcpy (command, REVIEW_ITEM);
        strcpy (catalog, NFFglobal.catalog);
        strcpy (item, NFFglobal.item);
        strcpy (revision, NFFglobal.revision);
      }
    else if ((strcmp (command_key, NFI_M_DISPLAY_SET_MEMBERS)) == 0)
      {
        /*  There is no need to end the block listings  */

        cleanup_listings = FALSE;

        if ((status = _NFFvalidate_active_data (default_mask |
            NFF_CATALOG | NFF_ITEM | NFF_SET | NFF_REVISION)) != NFI_S_SUCCESS)
          {
            _NFIdebug ((fname,
                "_NFFvalidate_active_data = <0x%.8x>\n", status));
            return (status);
          }

        strcpy (command, LIST_SET_MEMBERS);
        strcpy (catalog, NFFglobal.catalog);
        strcpy (item, NFFglobal.item);
        strcpy (revision, NFFglobal.revision);
      }
    else if ((strcmp (command_key, NFI_M_DISPLAY_SA)) == 0)
      {
        /*  There is no need to end the block listings  */

        cleanup_listings = FALSE;

        if ((status = _NFFvalidate_active_data
            (default_mask)) != NFI_S_SUCCESS)
          {
            _NFIdebug ((fname,
                "_NFFvalidate_active_data = <0x%.8x>\n", status));
            return (status);
          }

        strcpy (command, LIST_SA);
      }
    else if ((strcmp (command_key, NFI_M_DISPLAY_WA_ADMIN)) == 0)
      {
        /*  There is no need to end the block listings  */

        cleanup_listings = FALSE;

        if ((status = _NFFvalidate_active_data
            (default_mask)) != NFI_S_SUCCESS)
          {
            _NFIdebug ((fname,
                "_NFFvalidate_active_data = <0x%.8x>\n", status));
            return (status);
          }

        strcpy (command, LIST_WORKING_AREA);
      }
    else if ((strcmp (command_key, NFI_M_DISPLAY_WA_USER)) == 0)
      {
        /*  There is no need to end the block listings  */

        cleanup_listings = FALSE;

        if ((status = _NFFvalidate_active_data
            (default_mask)) != NFI_S_SUCCESS)
          {
            _NFIdebug ((fname,
                "_NFFvalidate_active_data = <0x%.8x>\n", status));
            return (status);
          }

        strcpy (command, LIST_USER_WORKING_AREA);
      }
    else if ((strcmp (command_key, NFI_M_DISPLAY_USERS)) == 0)
      {
        /*  There is no need to end the block listings  */

        cleanup_listings = FALSE;

        if ((status = _NFFvalidate_active_data
            (default_mask)) != NFI_S_SUCCESS)
          {
            _NFIdebug ((fname,
                "_NFFvalidate_active_data = <0x%.8x>\n", status));
            return (status);
          }

        strcpy (command, LIST_USERS);
      }
    else if ((strcmp (command_key, NFI_M_DISPLAY_NODES)) == 0)
      {
        /*  There is no need to end the block listings  */

        cleanup_listings = FALSE;

        if ((status = _NFFvalidate_active_data
            (default_mask)) != NFI_S_SUCCESS)
          {
            _NFIdebug ((fname,
                "_NFFvalidate_active_data = <0x%.8x>\n", status));
            return (status);
          }

        strcpy (command, LIST_NODES);
      }
    else if ((strcmp (command_key, NFI_M_DISPLAY_WFS)) == 0)
      {
        /*  There is no need to end the block listings  */

        cleanup_listings = FALSE;

        if ((status = _NFFvalidate_active_data
            (default_mask)) != NFI_S_SUCCESS)
          {
            _NFIdebug ((fname,
                "_NFFvalidate_active_data = <0x%.8x>\n", status));
            return (status);
          }

        strcpy (command, LIST_WORKFLOWS);
      }
    else if ((strcmp (command_key, NFI_M_DISPLAY_ACLS)) == 0)
      {
        /*  There is no need to end the block listings  */

        cleanup_listings = FALSE;

        if ((status = _NFFvalidate_active_data
            (default_mask | NFF_WORKFLOW)) != NFI_S_SUCCESS)
          {
            _NFIdebug ((fname,
                "_NFFvalidate_active_data = <0x%.8x>\n", status));
            return (status);
          }

        strcpy (command, LIST_ACLS);
      }
    else if ((strcmp (command_key, NFI_M_DISPLAY_ACL_CLASS_USERS)) == 0)
      {
        /*  There is no need to end the block listings  */

        cleanup_listings = FALSE;

        if ((status = _NFFvalidate_active_data
            (default_mask | NFF_WORKFLOW | NFF_ACL)) != NFI_S_SUCCESS)
          {
            _NFIdebug ((fname,
                "_NFFvalidate_active_data = <0x%.8x>\n", status));
            return (status);
          }

        strcpy (command, LIST_ACL_CLASS_USERS);
      }
    else if ((strcmp (command_key, NFI_M_DISPLAY_ACL_SO_USERS)) == 0)
      {
        /*  There is no need to end the block listings  */

        cleanup_listings = FALSE;

        if ((status = _NFFvalidate_active_data
            (default_mask | NFF_WORKFLOW | NFF_ACL)) != NFI_S_SUCCESS)
          {
            _NFIdebug ((fname,
                "_NFFvalidate_active_data = <0x%.8x>\n", status));
            return (status);
          }

        strcpy (command, LIST_ACL_SIGNOFF_USERS);
      }
    else if ((strcmp (command_key, NFI_M_DISPLAY_SEARCH_CRITERIA)) == 0)
      {
        /*  There is no need to end the block listings  */

        cleanup_listings = FALSE;

        if ((status = _NFFvalidate_active_data
            (default_mask)) != NFI_S_SUCCESS)
          {
            _NFIdebug ((fname,
                "_NFFvalidate_active_data = <0x%.8x>\n", status));
            return (status);
          }

        strcpy (command, LIST_SEARCH_CRITERIA);
      }
    else if ((strcmp (command_key, NFI_M_DISPLAY_SORT_CRITERIA)) == 0)
      {
        /*  There is no need to end the block listings  */

        cleanup_listings = FALSE;

        if ((status = _NFFvalidate_active_data
            (default_mask)) != NFI_S_SUCCESS)
          {
            _NFIdebug ((fname,
                "_NFFvalidate_active_data = <0x%.8x>\n", status));
            return (status);
          }

        strcpy (command, LIST_SORT_CRITERIA);
      }
    else if ((strcmp (command_key, NFI_M_LIST_SIGNOFF_ITEM)) == 0)
      {
        /*  There is no need to end the block listings  */

        cleanup_listings = FALSE;

        if ((status = _NFFvalidate_active_data (default_mask |
            NFF_CATALOG | NFF_ITEM | NFF_REVISION)) != NFI_S_SUCCESS)
          {
            _NFIdebug ((fname,
                "_NFFvalidate_active_data = <0x%.8x>\n", status));
            return (status);
          }

        strcpy (command, LIST_SIGNOFF_ON_ITEM);
        strcpy (catalog, NFFglobal.catalog);
        strcpy (item, NFFglobal.item);
        strcpy (revision, NFFglobal.revision);
      }
    else if ((strcmp (command_key, NFI_M_LIST_SIGNOFF_HISTORY)) == 0)
      {
        /*  There is no need to end the block listings  */

        cleanup_listings = FALSE;

        if ((status = _NFFvalidate_active_data (default_mask |
            NFF_CATALOG | NFF_ITEM | NFF_REVISION)) != NFI_S_SUCCESS)
          {
            _NFIdebug ((fname,
                "_NFFvalidate_active_data = <0x%.8x>\n", status));
            return (status);
          }

        strcpy (command, LIST_SIGNOFF_HISTORY);
        strcpy (catalog, NFFglobal.catalog);
        strcpy (item, NFFglobal.item);
        strcpy (revision, NFFglobal.revision);
      }
    else if ((strcmp (command_key, NFI_M_DISPLAY_PROJECT_SA_MAPPING)) == 0)
      {
        /*  There is no need to end the block listings  */

        cleanup_listings = FALSE;

        if ((status = _NFFvalidate_active_data
            (default_mask | NFF_PROJECT)) != NFI_S_SUCCESS)
          {
            _NFIdebug ((fname,
                "_NFFvalidate_active_data = <0x%.8x>\n", status));
            return (status);
          }

        strcpy (command, LIST_PROJ_CAT_SA_MAP);
        strcpy (project, NFFglobal.project);
      }
    else if ((strcmp (command_key, NFI_M_DISPLAY_WHERE_ITEM_USED_SET)) == 0)
      {
        /*  There is no need to end the block listings  */

        cleanup_listings = FALSE;

        if ((status = _NFFvalidate_active_data (default_mask |
            NFF_CATALOG | NFF_ITEM | NFF_REVISION)) != NFI_S_SUCCESS)
          {
            _NFIdebug ((fname,
                "_NFFvalidate_active_data = <0x%.8x>\n", status));
            return (status);
          }

        strcpy (command, LIST_WHERE_USED_SET);
        strcpy (catalog, NFFglobal.catalog);
        strcpy (item, NFFglobal.item);
        strcpy (revision, NFFglobal.revision);
      }
    else if ((strcmp
        (command_key, NFI_M_DISPLAY_WHERE_ITEM_USED_PROJECT)) == 0)
      {
        /*  There is no need to end the block listings  */

        cleanup_listings = FALSE;

        if ((status = _NFFvalidate_active_data (default_mask |
            NFF_CATALOG | NFF_ITEM | NFF_REVISION)) != NFI_S_SUCCESS)
          {
            _NFIdebug ((fname,
                "_NFFvalidate_active_data = <0x%.8x>\n", status));
            return (status);
          }

        strcpy (command, LIST_WHERE_USED_PROJECT);
        strcpy (catalog, NFFglobal.catalog);
        strcpy (item, NFFglobal.item);
        strcpy (revision, NFFglobal.revision);
      }
    else if ((strcmp (command_key, NFI_M_DISPLAY_FILES_FLAGGED_ARCHIVE)) == 0)
      {
        /*  There is no need to end the block listings  */

        cleanup_listings = FALSE;

        if ((status = _NFFvalidate_active_data
            (default_mask)) != NFI_S_SUCCESS)
          {
            _NFIdebug ((fname,
                "_NFFvalidate_active_data = <0x%.8x>\n", status));
            return (status);
          }

        strcpy (command, ARCHIVE_LIST);
      }
    else if ((strcmp (command_key, NFI_M_DISPLAY_FILES_FLAGGED_BACKUP)) == 0)
      {
        /*  There is no need to end the block listings  */

        cleanup_listings = FALSE;

        if ((status = _NFFvalidate_active_data
            (default_mask)) != NFI_S_SUCCESS)
          {
            _NFIdebug ((fname,
                "_NFFvalidate_active_data = <0x%.8x>\n", status));
            return (status);
          }

        strcpy (command, BACKUP_LIST);
      }
    else if ((strcmp (command_key, NFI_M_DISPLAY_FILES_FLAGGED_DELETE)) == 0)
      {
        /*  There is no need to end the block listings  */

        cleanup_listings = FALSE;

        if ((status = _NFFvalidate_active_data
            (default_mask)) != NFI_S_SUCCESS)
          {
            _NFIdebug ((fname,
                "_NFFvalidate_active_data = <0x%.8x>\n", status));
            return (status);
          }

        strcpy (command, DELETE_LIST);
      }
    else if ((strcmp (command_key, NFI_M_DISPLAY_FILES_FLAGGED_RESTORE)) == 0)
      {
        /*  There is no need to end the block listings  */

        cleanup_listings = FALSE;

        if ((status = _NFFvalidate_active_data
            (default_mask)) != NFI_S_SUCCESS)
          {
            _NFIdebug ((fname,
                "_NFFvalidate_active_data = <0x%.8x>\n", status));
            return (status);
          }

        strcpy (command, RESTORE_LIST);
      }
    else if ((strcmp (command_key, NFI_M_DELETE_CATALOG)) == 0)
      {
        if ((status = _NFFvalidate_active_data
            (default_mask | NFF_CATALOG)) != NFI_S_SUCCESS)
          {
            _NFIdebug ((fname,
                "_NFFvalidate_active_data = <0x%.8x>\n", status));
            return (status);
          }

        strcpy (command, DELETE_CATALOG);
        strcpy (catalog, NFFglobal.catalog);
      }
    else if ((strcmp (command_key, NFI_M_CHANGE_CATALOG)) == 0)
      {
        if ((status = _NFFvalidate_active_data
            (default_mask | NFF_CATALOG)) != NFI_S_SUCCESS)
          {
            _NFIdebug ((fname,
                "_NFFvalidate_active_data = <0x%.8x>\n", status));
            return (status);
          }

        strcpy (command, CHANGE_CATALOG);
        strcpy (catalog, NFFglobal.catalog);
      }
    else if ((strcmp (command_key, NFI_M_DELETE_ITEM)) == 0)
      {
        if ((strcmp (NFFglobal.set_indicator, "")) != 0)
        {
            _NFIdebug ((fname, "Invalid Set Operation\n" ));
            ERRload_struct (NFI, NFI_E_INVALID_SET_OPERATION, NULL);
            return (NFI_E_INVALID_SET_OPERATION);
        }
        if ((status = _NFFvalidate_active_data (default_mask | NFF_CATALOG
            | NFF_ITEM | NFF_REVISION | NFF_LIST)) != NFI_S_SUCCESS)
          {
            _NFIdebug ((fname,
                "_NFFvalidate_active_data = <0x%.8x>\n", status));
            return (status);
          }

        strcpy (command, DELETE_ITEM);
        strcpy (catalog, NFFglobal.catalog);
        strcpy (item, NFFglobal.item);
        strcpy (revision, NFFglobal.revision);
      }
    else if ((strcmp (command_key, NFI_M_LOCK_ITEM)) == 0)
      {
        if ((status = _NFFvalidate_active_data (default_mask |
            NFF_CATALOG | NFF_ITEM | NFF_REVISION)) != NFI_S_SUCCESS)
          {
            _NFIdebug ((fname,
                "_NFFvalidate_active_data = <0x%.8x>\n", status));
            return (status);
          }

        strcpy (command, LOCK_ITEM);
        strcpy (catalog, NFFglobal.catalog);
        strcpy (item, NFFglobal.item);
        strcpy (revision, NFFglobal.revision);
      }
    else if ((strcmp (command_key, NFI_M_UNLOCK_ITEM)) == 0)
      {
        if ((status = _NFFvalidate_active_data (default_mask |
            NFF_CATALOG | NFF_ITEM | NFF_REVISION)) != NFI_S_SUCCESS)
          {
            _NFIdebug ((fname,
                "_NFFvalidate_active_data = <0x%.8x>\n", status));
            return (status);
          }

        strcpy (command, UNLOCK_ITEM);
        strcpy (catalog, NFFglobal.catalog);
        strcpy (item, NFFglobal.item);
        strcpy (revision, NFFglobal.revision);
      }
    else if ((strcmp (command_key, NFI_M_FLAG_ARCHIVE)) == 0)
      {
        if ((status = _NFFvalidate_active_data (default_mask | NFF_CATALOG
            | NFF_ITEM | NFF_REVISION | NFF_LIST)) != NFI_S_SUCCESS)
          {
            _NFIdebug ((fname,
                "_NFFvalidate_active_data = <0x%.8x>\n", status));
            return (status);
          }

        if ((strcmp (NFFglobal.set_indicator, "")) == 0)
           strcpy (command, FLAG_ITEM_ARCHIVE);
        else
           strcpy (command, FLAG_SET_ARCHIVE);
        strcpy (catalog, NFFglobal.catalog);
        strcpy (item, NFFglobal.item);
        strcpy (revision, NFFglobal.revision);
      }
    else if ((strcmp (command_key, NFI_M_FLAG_BACKUP)) == 0)
      {
        if ((status = _NFFvalidate_active_data (default_mask | NFF_CATALOG
            | NFF_ITEM | NFF_REVISION | NFF_LIST)) != NFI_S_SUCCESS)
          {
            _NFIdebug ((fname,
                "_NFFvalidate_active_data = <0x%.8x>\n", status));
            return (status);
          }

        if ((strcmp (NFFglobal.set_indicator, "")) == 0)
            strcpy (command, FLAG_ITEM_BACKUP);
        else
            strcpy (command, FLAG_SET_BACKUP);
        strcpy (catalog, NFFglobal.catalog);
        strcpy (item, NFFglobal.item);
        strcpy (revision, NFFglobal.revision);
      }
    else if ((strcmp (command_key, NFI_M_FLAG_DELETE)) == 0)
      {
        if ((status = _NFFvalidate_active_data (default_mask | NFF_CATALOG
            | NFF_ITEM | NFF_REVISION | NFF_LIST)) != NFI_S_SUCCESS)
          {
            _NFIdebug ((fname,
                "_NFFvalidate_active_data = <0x%.8x>\n", status));
            return (status);
          }

        strcpy (command, FLAG_ITEM_DELETE);
        strcpy (catalog, NFFglobal.catalog);
        strcpy (item, NFFglobal.item);
        strcpy (revision, NFFglobal.revision);
      }
    else if ((strcmp (command_key, NFI_M_FLAG_RESTORE)) == 0)
      {
        if ((status = _NFFvalidate_active_data (default_mask | NFF_CATALOG
            | NFF_ITEM | NFF_REVISION | NFF_LIST)) != NFI_S_SUCCESS)
          {
            _NFIdebug ((fname,
                "_NFFvalidate_active_data = <0x%.8x>\n", status));
            return (status);
          }

        if ((strcmp (NFFglobal.set_indicator, "")) == 0)
            strcpy (command, FLAG_ITEM_RESTORE);
        else
            strcpy (command, FLAG_SET_RESTORE);
        strcpy (catalog, NFFglobal.catalog);
        strcpy (item, NFFglobal.item);
        strcpy (revision, NFFglobal.revision);
      }
    else if ((strcmp (command_key, NFI_M_FLAG_SET_ITEM_FOR_BACKUP)) == 0)
      {
        if ((status = _NFFvalidate_active_data (default_mask | NFF_CATALOG
            | NFF_ITEM | NFF_REVISION | NFF_LIST)) != NFI_S_SUCCESS)
          {
            _NFIdebug ((fname,
                "_NFFvalidate_active_data = <0x%.8x>\n", status));
            return (status);
          }

        strcpy (command, FLAG_ITEM_BACKUP);
        strcpy (catalog, NFFglobal.catalog);
        strcpy (item, NFFglobal.item);
        strcpy (revision, NFFglobal.revision);
      }
    else if ((strcmp (command_key, NFI_M_FLAG_PROJECT_FILES_ARCHIVE)) == 0)
      {
        if ((status = _NFFvalidate_active_data (default_mask |
            NFF_PROJECT)) != NFI_S_SUCCESS)
          {
            _NFIdebug ((fname,
                "_NFFvalidate_active_data = <0x%.8x>\n", status));
            return (status);
          }

        strcpy (command, FLAG_PROJ_FILES_ARCHIVE);
        strcpy (project, NFFglobal.project);
      }
    else if ((strcmp (command_key, NFI_M_FLAG_PROJECT_FILES_BACKUP)) == 0)
      {
        if ((status = _NFFvalidate_active_data (default_mask |
            NFF_PROJECT)) != NFI_S_SUCCESS)
          {
            _NFIdebug ((fname,
                "_NFFvalidate_active_data = <0x%.8x>\n", status));
            return (status);
          }

        strcpy (command, FLAG_PROJ_FILES_BACKUP);
        strcpy (project, NFFglobal.project);
      }
    else if ((strcmp (command_key, NFI_M_FLAG_PROJECT_FILES_RESTORE)) == 0)
      {
        if ((status = _NFFvalidate_active_data (default_mask |
            NFF_PROJECT)) != NFI_S_SUCCESS)
          {
            _NFIdebug ((fname,
                "_NFFvalidate_active_data = <0x%.8x>\n", status));
            return (status);
          }

        strcpy (command, FLAG_PROJ_FILES_RESTORE);
        strcpy (project, NFFglobal.project);
      }
    else if ((strcmp (command_key, NFI_M_CANCEL_ARCHIVE_FLAG)) == 0)
      {
        if ((status = _NFFvalidate_active_data (default_mask |
            NFF_CATALOG | NFF_ITEM | NFF_REVISION)) != NFI_S_SUCCESS)
          {
            _NFIdebug ((fname,
                "_NFFvalidate_active_data = <0x%.8x>\n", status));
            return (status);
          }

        if (strcmp (NFFglobal.set_indicator, "") == 0)
            strcpy (command, CANCEL_ITEM_ARCHIVE_FLAG);
        else
            strcpy (command, CANCEL_SET_ARCHIVE_FLAG);
        strcpy (catalog, NFFglobal.catalog);
        strcpy (item, NFFglobal.item);
        strcpy (revision, NFFglobal.revision);
      }
    else if ((strcmp (command_key, NFI_M_CANCEL_BACKUP_FLAG)) == 0)
      {
        if ((status = _NFFvalidate_active_data (default_mask |
            NFF_CATALOG | NFF_ITEM | NFF_REVISION)) != NFI_S_SUCCESS)
          {
            _NFIdebug ((fname,
                "_NFFvalidate_active_data = <0x%.8x>\n", status));
            return (status);
          }

        if (strcmp (NFFglobal.set_indicator, "") == 0)
            strcpy (command, CANCEL_ITEM_BACKUP_FLAG);
        else
            strcpy (command, CANCEL_SET_BACKUP_FLAG);
        strcpy (catalog, NFFglobal.catalog);
        strcpy (item, NFFglobal.item);
        strcpy (revision, NFFglobal.revision);
      }
    else if ((strcmp (command_key, NFI_M_CAN_SET_ITEM_BACKUP_FLAG)) == 0)
      {
        if ((status = _NFFvalidate_active_data (default_mask |
            NFF_CATALOG | NFF_ITEM | NFF_REVISION)) != NFI_S_SUCCESS)
          {
            _NFIdebug ((fname,
                "_NFFvalidate_active_data = <0x%.8x>\n", status));
            return (status);
          }

        strcpy (command, CANCEL_ITEM_BACKUP_FLAG);
        strcpy (catalog, NFFglobal.catalog);
        strcpy (item, NFFglobal.item);
        strcpy (revision, NFFglobal.revision);
      }
    else if ((strcmp (command_key, NFI_M_CANCEL_RESTORE_FLAG)) == 0)
      {
        if ((status = _NFFvalidate_active_data (default_mask |
            NFF_CATALOG | NFF_ITEM | NFF_REVISION)) != NFI_S_SUCCESS)
          {
            _NFIdebug ((fname,
                "_NFFvalidate_active_data = <0x%.8x>\n", status));
            return (status);
          }

        if (strcmp (NFFglobal.set_indicator, "") == 0)
            strcpy (command, CANCEL_ITEM_RESTORE_FLAG);
        else
            strcpy (command, CANCEL_SET_RESTORE_FLAG);
        strcpy (catalog, NFFglobal.catalog);
        strcpy (item, NFFglobal.item);
        strcpy (revision, NFFglobal.revision);
      }
    else if ((strcmp (command_key, NFI_M_CANCEL_DELETE_FLAG)) == 0)
      {
        if ((status = _NFFvalidate_active_data (default_mask |
            NFF_CATALOG | NFF_ITEM | NFF_REVISION)) != NFI_S_SUCCESS)
          {
            _NFIdebug ((fname,
                "_NFFvalidate_active_data = <0x%.8x>\n", status));
            return (status);
          }

        strcpy (command, CANCEL_ITEM_DELETE_FLAG);
        strcpy (catalog, NFFglobal.catalog);
        strcpy (item, NFFglobal.item);
        strcpy (revision, NFFglobal.revision);
      }
    else if ((strcmp (command_key, NFI_M_CANCEL_ARCHIVE_FLAG_PROJECT)) == 0)
      {
        if ((status = _NFFvalidate_active_data (default_mask |
            NFF_PROJECT)) != NFI_S_SUCCESS)
          {
            _NFIdebug ((fname,
                "_NFFvalidate_active_data = <0x%.8x>\n", status));
            return (status);
          }

        strcpy (command, CANCEL_ARCHIVE_FLAG_PROJ_FILES);
        strcpy (project, NFFglobal.project);
      }
    else if ((strcmp (command_key, NFI_M_CANCEL_BACKUP_FLAG_PROJECT)) == 0)
      {
        if ((status = _NFFvalidate_active_data (default_mask |
            NFF_PROJECT)) != NFI_S_SUCCESS)
          {
            _NFIdebug ((fname,
                "_NFFvalidate_active_data = <0x%.8x>\n", status));
            return (status);
          }

        strcpy (command, CANCEL_BACKUP_FLAG_PROJ_FILES);
        strcpy (project, NFFglobal.project);
      }
    else if ((strcmp (command_key, NFI_M_CANCEL_RESTORE_FLAG_PROJECT)) == 0)
      {
        if ((status = _NFFvalidate_active_data (default_mask |
            NFF_PROJECT)) != NFI_S_SUCCESS)
          {
            _NFIdebug ((fname,
                "_NFFvalidate_active_data = <0x%.8x>\n", status));
            return (status);
          }

        strcpy (command, CANCEL_RESTORE_FLAG_PROJ_FILES);
        strcpy (project, NFFglobal.project);
      }
    else if ((strcmp (command_key, NFI_M_PROCESS_FLAGGED_FILES)) == 0)
      {
        if ((status = _NFFvalidate_active_data (default_mask)) != NFI_S_SUCCESS)
          {
            _NFIdebug ((fname,
                "_NFFvalidate_active_data = <0x%.8x>\n", status));
            return (status);
          }

        strcpy (command, BACKUP);
        do_not_validate = TRUE;
      }
    else if ((strcmp (command_key, NFI_M_ARCHIVE_FLAGGED_FILES)) == 0)
      {
        if ((status = _NFFvalidate_active_data (default_mask)) != NFI_S_SUCCESS)
          {
            _NFIdebug ((fname,
                "_NFFvalidate_active_data = <0x%.8x>\n", status));
            return (status);
          }

        strcpy (command, ARCHIVE);
      }
    else if ((strcmp (command_key, NFI_M_BACKUP_FLAGGED_FILES)) == 0)
      {
        if ((status = _NFFvalidate_active_data (default_mask)) != NFI_S_SUCCESS)
          {
            _NFIdebug ((fname,
                "_NFFvalidate_active_data = <0x%.8x>\n", status));
            return (status);
          }

        strcpy (command, BACKUP);
      }
    else if ((strcmp (command_key, NFI_M_RESTORE_FLAGGED_FILES)) == 0)
      {
        if ((status = _NFFvalidate_active_data (default_mask)) != NFI_S_SUCCESS)
          {
            _NFIdebug ((fname,
                "_NFFvalidate_active_data = <0x%.8x>\n", status));
            return (status);
          }

        strcpy (command, RESTORE);
      }
    else if ((strcmp (command_key, NFI_M_DELETE_FLAGGED_FILES)) == 0)
      {
        if ((status = _NFFvalidate_active_data (default_mask)) != NFI_S_SUCCESS)
          {
            _NFIdebug ((fname,
                "_NFFvalidate_active_data = <0x%.8x>\n", status));
            return (status);
          }

        strcpy (command, DELETE);
      }
    else if ((strcmp (command_key, NFI_M_CHECK_IN)) == 0)
      {
        if ((status = _NFFvalidate_active_data (default_mask | NFF_CATALOG
            | NFF_ITEM | NFF_REVISION | NFF_LIST)) != NFI_S_SUCCESS)
          {
            _NFIdebug ((fname,
                "_NFFvalidate_active_data = <0x%.8x>\n", status));
            return (status);
          }

        if ((strcmp (NFFglobal.set_indicator, "")) == 0)
            strcpy (command, CHECKIN_ITEM);
        else
            strcpy (command, CHECKIN_SET);

        strcpy (catalog, NFFglobal.catalog);
        strcpy (item, NFFglobal.item);
        strcpy (revision, NFFglobal.revision);
        do_not_validate = TRUE;
      }
    else if ((strcmp (command_key, NFI_M_CHECK_IN_SET_ITEM)) == 0)
      {
        if ((status = _NFFvalidate_active_data (default_mask | NFF_CATALOG
            | NFF_ITEM | NFF_SET | NFF_REVISION | NFF_LIST)) != NFI_S_SUCCESS)
          {
            _NFIdebug ((fname,
                "_NFFvalidate_active_data = <0x%.8x>\n", status));
            return (status);
          }

        strcpy (command, CHECKIN_ITEM);

        strcpy (catalog, NFFglobal.catalog);
        strcpy (item, NFFglobal.item);
        strcpy (revision, NFFglobal.revision);
        do_not_validate = TRUE;
      }
    else if ((strcmp (command_key, NFI_M_COPY_ITEM_FILES)) == 0)
      {
        if ((status = _NFFvalidate_active_data
            (default_mask | NFF_CATALOG | NFF_ITEM |
            NFF_REVISION | NFF_WORKING_AREA | NFF_LIST)) != NFI_S_SUCCESS)
          {
            _NFIdebug ((fname,
                "_NFFvalidate_active_data = <0x%.8x>\n", status));
            return (status);
          }

        if ((strcmp (NFFglobal.set_indicator, "")) == 0)
            strcpy (command, COPY_ITEM_FILES);
        else
            strcpy (command, COPY_SET_FILES); 

        strcpy (catalog, NFFglobal.catalog);
        strcpy (item, NFFglobal.item);
        strcpy (revision, NFFglobal.revision);
        do_not_validate = TRUE;
      }
    else if ((strcmp (command_key, NFI_M_COPY_SET_ITEM_FILES)) == 0)
      {
        if ((status = _NFFvalidate_active_data
            (default_mask | NFF_CATALOG | NFF_ITEM | NFF_SET |
            NFF_REVISION | NFF_WORKING_AREA | NFF_LIST)) != NFI_S_SUCCESS)
          {
            _NFIdebug ((fname,
                "_NFFvalidate_active_data = <0x%.8x>\n", status));
            return (status);
          }

        strcpy (command, COPY_ITEM_FILES);

        strcpy (catalog, NFFglobal.catalog);
        strcpy (item, NFFglobal.item);
        strcpy (revision, NFFglobal.revision);
        do_not_validate = TRUE;
      }
    else if ((strcmp (command_key, NFI_M_CHECK_OUT)) == 0)
      {
        if ((status = _NFFvalidate_active_data
            (default_mask | NFF_CATALOG | NFF_ITEM |
            NFF_REVISION | NFF_WORKING_AREA | NFF_LIST)) != NFI_S_SUCCESS)
          {
            _NFIdebug ((fname,
                "_NFFvalidate_active_data = <0x%.8x>\n", status));
            return (status);
          }

        if ((strcmp (NFFglobal.set_indicator, "")) == 0)
            strcpy (command, CHECKOUT_ITEM);
        else
            strcpy (command, CHECKOUT_SET);

        strcpy (catalog, NFFglobal.catalog);
        strcpy (item, NFFglobal.item);
        strcpy (revision, NFFglobal.revision);
        do_not_validate = TRUE;
      }
    else if ((strcmp (command_key, NFI_M_CHECK_OUT_SET_ITEM)) == 0)
      {
        if ((status = _NFFvalidate_active_data
            (default_mask | NFF_CATALOG | NFF_ITEM | NFF_SET |
            NFF_REVISION | NFF_WORKING_AREA | NFF_LIST)) != NFI_S_SUCCESS)
          {
            _NFIdebug ((fname,
                "_NFFvalidate_active_data = <0x%.8x>\n", status));
            return (status);
          }

        strcpy (command, CHECKOUT_ITEM);

        strcpy (catalog, NFFglobal.catalog);
        strcpy (item, NFFglobal.item);
        strcpy (revision, NFFglobal.revision);
        do_not_validate = TRUE;
      }
    else if ((strcmp (command_key, NFI_M_CANCEL_CHECK_OUT)) == 0)
      {
        if ((status = _NFFvalidate_active_data (default_mask
            | NFF_CATALOG | NFF_ITEM | NFF_REVISION)) != NFI_S_SUCCESS)
          {
            _NFIdebug ((fname,
                "_NFFvalidate_active_data = <0x%.8x>\n", status));
            return (status);
          }

        if ((strcmp (NFFglobal.set_indicator, "")) == 0)
            strcpy (command, CANCEL_ITEM_CHECKOUT);
        else
            strcpy (command, CANCEL_SET_CHECKOUT);

        strcpy (catalog, NFFglobal.catalog);
        strcpy (item, NFFglobal.item);
        strcpy (revision, NFFglobal.revision);
        do_not_validate = TRUE;
      }
    else if ((strcmp (command_key, NFI_M_CANCEL_SET_ITEM_CHECK_OUT)) == 0)
      {
        if ((status = _NFFvalidate_active_data (default_mask | NFF_CATALOG |
                         NFF_ITEM | NFF_SET | NFF_REVISION)) != NFI_S_SUCCESS)
          {
            _NFIdebug ((fname,
                "_NFFvalidate_active_data = <0x%.8x>\n", status));
            return (status);
          }

        strcpy (command, CANCEL_ITEM_CHECKOUT);

        strcpy (catalog, NFFglobal.catalog);
        strcpy (item, NFFglobal.item);
        strcpy (revision, NFFglobal.revision);
        do_not_validate = TRUE;
      }
    else if ((strcmp (command_key, NFI_M_COPY_ITEM)) == 0)
      {
        if ((status = _NFFvalidate_active_data (default_mask |
            NFF_CATALOG | NFF_ITEM | NFF_REVISION)) != NFI_S_SUCCESS)
          {
            _NFIdebug ((fname,
                "_NFFvalidate_active_data = <0x%.8x>\n", status));
            return (status);
          }

        strcpy (command, COPY_ITEM);
        strcpy (catalog, NFFglobal.catalog);
        strcpy (item, NFFglobal.item);
        strcpy (revision, NFFglobal.revision);
      }
    else if ((strcmp (command_key, NFI_M_ROLL_VERSION_FORWARD)) == 0)
      {
        if ((status = _NFFvalidate_active_data (default_mask |
            NFF_CATALOG | NFF_ITEM | NFF_REVISION)) != NFI_S_SUCCESS)
          {
            _NFIdebug ((fname,
                "_NFFvalidate_active_data = <0x%.8x>\n", status));
            return (status);
          }

        strcpy (command, ROLL_FILE_VERSION_FWD);
        strcpy (catalog, NFFglobal.catalog);
        strcpy (item, NFFglobal.item);
        strcpy (revision, NFFglobal.revision);
      }
    else if ((strcmp (command_key, NFI_M_PURGE_FILE_VERSION)) == 0)
      {
        if ((status = _NFFvalidate_active_data (default_mask |
            NFF_CATALOG | NFF_ITEM | NFF_REVISION)) != NFI_S_SUCCESS)
          {
            _NFIdebug ((fname,
                "_NFFvalidate_active_data = <0x%.8x>\n", status));
            return (status);
          }

        strcpy (command, PURGE_FILE_VERSIONS);
        strcpy (catalog, NFFglobal.catalog);
        strcpy (item, NFFglobal.item);
        strcpy (revision, NFFglobal.revision);
      }
    else if ((strcmp (command_key, NFI_M_MAKE_ITEM_TRANSITION)) == 0)
      {
        if ((status = _NFFvalidate_active_data (default_mask |
            NFF_CATALOG | NFF_ITEM | NFF_REVISION)) != NFI_S_SUCCESS)
          {
            _NFIdebug ((fname,
                "_NFFvalidate_active_data = <0x%.8x>\n", status));
            return (status);
          }

        strcpy (command, MAKE_TRANSITION);
        strcpy (catalog, NFFglobal.catalog);
        strcpy (item, NFFglobal.item);
        strcpy (revision, NFFglobal.revision);
      }
    else if ((strcmp (command_key, NFI_M_DELETE_NODE)) == 0)
      {
        if ((status = _NFFvalidate_active_data
            (default_mask | NFF_NODE)) != NFI_S_SUCCESS)
          {
            _NFIdebug ((fname,
                "_NFFvalidate_active_data = <0x%.8x>\n", status));
            return (status);
          }

        strcpy (command, DELETE_NODE);
      }
    else if ((strcmp (command_key, NFI_M_CHANGE_USER_PASSWD)) == 0)
      {
        if ((status = _NFFvalidate_active_data
            (default_mask)) != NFI_S_SUCCESS)
          {
            _NFIdebug ((fname,
                "_NFFvalidate_active_data = <0x%.8x>\n", status));
            return (status);
          }

        strcpy (command, CHG_USER_PASSWD);
      }
    else if ((strcmp (command_key, NFI_M_CHANGE_PASSWD)) == 0)
      {
        if ((status = _NFFvalidate_active_data
            (default_mask)) != NFI_S_SUCCESS)
          {
            _NFIdebug ((fname,
                "_NFFvalidate_active_data = <0x%.8x>\n", status));
            return (status);
          }

        strcpy (command, CHANGE_PASSWD);
      }
    else if ((strcmp (command_key, NFI_M_DELETE_USER)) == 0)
      {
        if ((status = _NFFvalidate_active_data
            (default_mask | NFF_USER)) != NFI_S_SUCCESS)
          {
            _NFIdebug ((fname,
                "_NFFvalidate_active_data = <0x%.8x>\n", status));
            return (status);
          }

        strcpy (command, DELETE_USER);
      }
    else if ((strcmp (command_key, NFI_M_CHANGE_SA_PASSWD)) == 0)
      {
        if ((status = _NFFvalidate_active_data
            (default_mask | NFF_ST_AREA)) != NFI_S_SUCCESS)
          {
            _NFIdebug ((fname,
                "_NFFvalidate_active_data = <0x%.8x>\n", status));
            return (status);
          }

        strcpy (command, CHG_SA_PASSWD);
      }
    else if ((strcmp (command_key, NFI_M_DELETE_SA)) == 0)
      {
        if ((status = _NFFvalidate_active_data
            (default_mask | NFF_ST_AREA)) != NFI_S_SUCCESS)
          {
            _NFIdebug ((fname,
                "_NFFvalidate_active_data = <0x%.8x>\n", status));
            return (status);
          }

        strcpy (command, DELETE_SA);
      }
    else if ((strcmp (command_key, NFI_M_ADD_ITEMS_TO_SET)) == 0)
      {
        if ((status = _NFFvalidate_active_data (default_mask |
            NFF_CATALOG | NFF_ITEM | NFF_REVISION)) != NFI_S_SUCCESS)
          {
            _NFIdebug ((fname,
                "_NFFvalidate_active_data = <0x%.8x>\n", status));
            return (status);
          }

        strcpy (command, ADD_ITEMS_TO_SET);
        strcpy (catalog, NFFglobal.catalog);
        strcpy (item, NFFglobal.item);
        strcpy (revision, NFFglobal.revision);
      }
    else if ((strcmp (command_key, NFI_M_DELETE_ITEMS_FROM_SET)) == 0)
      {
        if ((status = _NFFvalidate_active_data (default_mask |
            NFF_CATALOG | NFF_ITEM | NFF_SET | NFF_REVISION)) != NFI_S_SUCCESS)
          {
            _NFIdebug ((fname,
                "_NFFvalidate_active_data = <0x%.8x>\n", status));
            return (status);
          }

        strcpy (command, DELETE_ITEMS_FROM_SET);
        strcpy (catalog, NFFglobal.catalog);
        strcpy (item, NFFglobal.item);
        strcpy (revision, NFFglobal.revision);
      }
    else if ((strcmp (command_key, NFI_M_DEFINE_SEARCH_CRITERIA)) == 0)
      {
        if ((status = _NFFvalidate_active_data
            (default_mask | NFF_CATALOG)) != NFI_S_SUCCESS)
          {
            _NFIdebug ((fname,
                "_NFFvalidate_active_data = <0x%.8x>\n", status));
            return (status);
          }

        strcpy (command, DEFINE_SEARCH_CRITERIA);
      }
    else if ((strcmp (command_key, NFI_M_DELETE_SEARCH_CRITERIA)) == 0)
      {
        if ((status = _NFFvalidate_active_data
            (default_mask | NFF_SEARCH)) != NFI_S_SUCCESS)
          {
            _NFIdebug ((fname,
                "_NFFvalidate_active_data = <0x%.8x>\n", status));
            return (status);
          }

        strcpy (command, DELETE_SEARCH_CRITERIA);
      }
    else if ((strcmp (command_key, NFI_M_DEFINE_SORT_CRITERIA)) == 0)
      {
        if ((status = _NFFvalidate_active_data
            (default_mask)) != NFI_S_SUCCESS)
          {
            _NFIdebug ((fname,
                "_NFFvalidate_active_data = <0x%.8x>\n", status));
            return (status);
          }

        strcpy (command, DEFINE_SORT_CRITERIA);
      }
    else if ((strcmp (command_key, NFI_M_DELETE_SORT_CRITERIA)) == 0)
      {
        if ((status = _NFFvalidate_active_data
            (default_mask | NFF_SORT)) != NFI_S_SUCCESS)
          {
            _NFIdebug ((fname,
                "_NFFvalidate_active_data = <0x%.8x>\n", status));
            return (status);
          }

        strcpy (command, DELETE_SORT_CRITERIA);
      }
    else if ((strcmp (command_key, NFI_M_DELETE_PROJECT)) == 0)
      {
        if ((status = _NFFvalidate_active_data
            (default_mask | NFF_PROJECT)) != NFI_S_SUCCESS)
          {
            _NFIdebug ((fname,
                "_NFFvalidate_active_data = <0x%.8x>\n", status));
            return (status);
          }

        strcpy (command, DELETE_PROJECT);
        strcpy (project, NFFglobal.project);
      }
    else if ((strcmp (command_key, NFI_M_ADD_ITEMS_TO_PROJECT)) == 0)
      {
        if ((status = _NFFvalidate_active_data
            (default_mask | NFF_PROJECT)) != NFI_S_SUCCESS)
          {
            _NFIdebug ((fname,
                "_NFFvalidate_active_data = <0x%.8x>\n", status));
            return (status);
          }

        strcpy (command, ADD_ITEMS_TO_PROJECT);
        strcpy (project, NFFglobal.project);
      }
    else if ((strcmp (command_key, NFI_M_DELETE_ITEMS_FROM_PROJECT)) == 0)
      {
        if ((status = _NFFvalidate_active_data
            (default_mask | NFF_PROJECT)) != NFI_S_SUCCESS)
          {
            _NFIdebug ((fname,
                "_NFFvalidate_active_data = <0x%.8x>\n", status));
            return (status);
          }

        strcpy (command, DELETE_ITEMS_FROM_PROJECT);
        strcpy (project, NFFglobal.project);
      }
    else if ((strcmp (command_key, NFI_M_ADD_CATALOG_ACL_MAPPING)) == 0)
      {
        if ((status = _NFFvalidate_active_data
            (default_mask | NFF_CATALOG)) != NFI_S_SUCCESS)
          {
            _NFIdebug ((fname,
                "_NFFvalidate_active_data = <0x%.8x>\n", status));
            return (status);
          }

        strcpy (command, ADD_CAT_ACL_MAP);
        strcpy (catalog, NFFglobal.catalog);
      }
    else if ((strcmp (command_key, NFI_M_DELETE_CATALOG_ACL_MAPPING)) == 0)
      {
        if ((status = _NFFvalidate_active_data
            (default_mask | NFF_CATALOG)) != NFI_S_SUCCESS)
          {
            _NFIdebug ((fname,
                "_NFFvalidate_active_data = <0x%.8x>\n", status));
            return (status);
          }

        strcpy (command, DELETE_CAT_ACL_MAP);
        strcpy (catalog, NFFglobal.catalog);
      }
    else if ((strcmp (command_key, NFI_M_DISPLAY_CATALOG_ACL_MAPPING)) == 0)
      {
       /*  There is no need to end the block listings  */

        cleanup_listings = FALSE;

        if ((status = _NFFvalidate_active_data
            (default_mask | NFF_CATALOG)) != NFI_S_SUCCESS)
          {
            _NFIdebug ((fname,
                "_NFFvalidate_active_data = <0x%.8x>\n", status));
            return (status);
          }

        strcpy (command, LIST_CAT_ACL_MAP);
        strcpy (catalog, NFFglobal.catalog);
      }
    else if ((strcmp (command_key, NFI_M_ADD_CATALOG_SA_MAPPING)) == 0)
      {
        if ((status = _NFFvalidate_active_data
            (default_mask | NFF_CATALOG)) != NFI_S_SUCCESS)
          {
            _NFIdebug ((fname,
                "_NFFvalidate_active_data = <0x%.8x>\n", status));
            return (status);
          }

        strcpy (command, ADD_CAT_SA_MAP);
        strcpy (catalog, NFFglobal.catalog);
      }
    else if ((strcmp (command_key, NFI_M_DELETE_CATALOG_SA_MAPPING)) == 0)
      {
        if ((status = _NFFvalidate_active_data
            (default_mask | NFF_CATALOG)) != NFI_S_SUCCESS)
          {
            _NFIdebug ((fname,
                "_NFFvalidate_active_data = <0x%.8x>\n", status));
            return (status);
          }

        strcpy (command, DELETE_CAT_SA_MAP);
        strcpy (catalog, NFFglobal.catalog);
      }
    else if ((strcmp (command_key, NFI_M_DISPLAY_CATALOG_SA_MAPPING)) == 0)
      {
       /*  There is no need to end the block listings  */

        cleanup_listings = FALSE;

        if ((status = _NFFvalidate_active_data
            (default_mask | NFF_CATALOG)) != NFI_S_SUCCESS)
          {
            _NFIdebug ((fname,
                "_NFFvalidate_active_data = <0x%.8x>\n", status));
            return (status);
          }

        strcpy (command, LIST_CAT_SA_MAP);
        strcpy (catalog, NFFglobal.catalog);
      }
    else if ((strcmp (command_key, NFI_M_ADD_PROJECT_ACL_MAPPING)) == 0)
      {
        if ((status = _NFFvalidate_active_data
            (default_mask | NFF_PROJECT)) != NFI_S_SUCCESS)
          {
            _NFIdebug ((fname,
                "_NFFvalidate_active_data = <0x%.8x>\n", status));
            return (status);
          }

        strcpy (command, ADD_CAT_ACL_PROJ_MAP);
        strcpy (project, NFFglobal.project);
      }
    else if ((strcmp (command_key, NFI_M_DELETE_PROJECT_ACL_MAPPING)) == 0)
      {
        if ((status = _NFFvalidate_active_data
            (default_mask | NFF_PROJECT)) != NFI_S_SUCCESS)
          {
            _NFIdebug ((fname,
                "_NFFvalidate_active_data = <0x%.8x>\n", status));
            return (status);
          }

        strcpy (command, DELETE_CAT_ACL_PROJ_MAP);
        strcpy (project, NFFglobal.project);
      }
    else if ((strcmp (command_key, NFI_M_DISPLAY_PROJECT_ACL_MAPPING)) == 0)
      {
       /*  There is no need to end the block listings  */

        cleanup_listings = FALSE;

        if ((status = _NFFvalidate_active_data
            (default_mask | NFF_PROJECT)) != NFI_S_SUCCESS)
          {
            _NFIdebug ((fname,
                "_NFFvalidate_active_data = <0x%.8x>\n", status));
            return (status);
          }

        strcpy (command, LIST_PROJ_CAT_ACL_MAP);
        strcpy (project, NFFglobal.project);
      }
    else if ((strcmp (command_key, NFI_M_DISPLAY_ITEMS_ON_TAPE)) == 0)
      {
       /*  There is no need to end the block listings  */

        cleanup_listings = FALSE;

        if ((status = _NFFvalidate_active_data
            (default_mask)) != NFI_S_SUCCESS)
          {
            _NFIdebug ((fname,
                "_NFFvalidate_active_data = <0x%.8x>\n", status));
            return (status);
          }

        strcpy (command, LIST_ITEMS_ON_TAPE);
      }
    else if ((strcmp (command_key, NFI_M_DISPLAY_SAVESETS)) == 0)
      {
       /*  There is no need to end the block listings  */

        cleanup_listings = FALSE;

        if ((status = _NFFvalidate_active_data
            (default_mask)) != NFI_S_SUCCESS)
          {
            _NFIdebug ((fname,
                "_NFFvalidate_active_data = <0x%.8x>\n", status));
            return (status);
          }

        strcpy (command, LIST_SAVESETS);
      }
    else if ((strcmp (command_key, NFI_M_CLEAR_SAVESET)) == 0)
      {
        if ((status = _NFFvalidate_active_data
            (default_mask)) != NFI_S_SUCCESS)
          {
            _NFIdebug ((fname,
                "_NFFvalidate_active_data = <0x%.8x>\n", status));
            return (status);
          }

        strcpy (command, DELETE_SAVESET);
      }
    else if ((strcmp (command_key, NFI_M_DISPLAY_ARCHIVES)) == 0)
      {
       /*  There is no need to end the block listings  */

        cleanup_listings = FALSE;

        if ((status = _NFFvalidate_active_data
            (default_mask)) != NFI_S_SUCCESS)
          {
            _NFIdebug ((fname,
                "_NFFvalidate_active_data = <0x%.8x>\n", status));
            return (status);
          }

        strcpy (command, LIST_ARCHIVES);
      }
    else if ((strcmp (command_key, NFI_M_DISPLAY_LOCAL_FILES)) == 0)
      {
       /*  There is no need to end the block listings  */

        cleanup_listings = FALSE;

        if ((status = _NFFvalidate_active_data
            (default_mask | NFF_WORKING_AREA)) != NFI_S_SUCCESS)
          {
            _NFIdebug ((fname,
                "_NFFvalidate_active_data = <0x%.8x>\n", status));
            return (status);
          }

        strcpy (command, LIST_LOCAL_FILES);
      }
    else if ((strcmp (command_key, NFI_M_DELETE_COPIED_FILES)) == 0)
      {
        if ((status = _NFFvalidate_active_data
            (default_mask | NFF_LOCAL_FILES)) != NFI_S_SUCCESS)
          {
            _NFIdebug ((fname,
                "_NFFvalidate_active_data = <0x%.8x>\n", status));
            return (status);
          }

        strcpy (command, DELETE_COPIED_FILES);
      }
    else if ((strcmp (command_key, NFI_M_ADD_PROJECT_SA_MAPPING)) == 0)
      {
        if ((status = _NFFvalidate_active_data
            (default_mask | NFF_PROJECT)) != NFI_S_SUCCESS)
          {
            _NFIdebug ((fname,
                "_NFFvalidate_active_data = <0x%.8x>\n", status));
            return (status);
          }

        strcpy (command, ADD_CAT_SA_PROJ_MAP);
        strcpy (project, NFFglobal.project);
      }
    else if ((strcmp (command_key, NFI_M_DELETE_PROJECT_SA_MAPPING)) == 0)
      {
        if ((status = _NFFvalidate_active_data
            (default_mask | NFF_PROJECT)) != NFI_S_SUCCESS)
          {
            _NFIdebug ((fname,
                "_NFFvalidate_active_data = <0x%.8x>\n", status));
            return (status);
          }

        strcpy (command, DELETE_CAT_SA_PROJ_MAP);
        strcpy (project, NFFglobal.project);
      }
    else if ((strcmp (command_key, NFI_M_DEFINE_ACL)) == 0)
      {
        if ((status = _NFFvalidate_active_data
            (default_mask)) != NFI_S_SUCCESS)
          {
            _NFIdebug ((fname,
                "_NFFvalidate_active_data = <0x%.8x>\n", status));
            return (status);
          }

        strcpy (command, ADD_ACL);
      }
    else if ((strcmp (command_key, NFI_M_DELETE_ACL)) == 0)
      {
        if ((status = _NFFvalidate_active_data
            (default_mask | NFF_WORKFLOW | NFF_ACL)) != NFI_S_SUCCESS)
          {
            _NFIdebug ((fname,
                "_NFFvalidate_active_data = <0x%.8x>\n", status));
            return (status);
          }

        strcpy (command, DELETE_ACL);
        strcpy (wf_name, NFFglobal.workflow);
      }
    else if ((strcmp (command_key, NFI_M_ADD_ACL_CLASS_USERS)) == 0)
      {
        if ((status = _NFFvalidate_active_data
            (default_mask | NFF_WORKFLOW | NFF_ACL)) != NFI_S_SUCCESS)
          {
            _NFIdebug ((fname,
                "_NFFvalidate_active_data = <0x%.8x>\n", status));
            return (status);
          }

        strcpy (command, ADD_ACL_USER);
        strcpy (wf_name, NFFglobal.workflow);
      }
    else if ((strcmp (command_key, NFI_M_ADD_ACL_CLASS_USERS_DEFINE)) == 0)
      {
        if ((status = _NFFvalidate_active_data
            (default_mask | NFF_WORKFLOW | NFF_ACL)) != NFI_S_SUCCESS)
          {
            _NFIdebug ((fname,
                "_NFFvalidate_active_data = <0x%.8x>\n", status));
            return (status);
          }

        strcpy (command, ADD_ACL_USER);
        strcpy (wf_name, NFFglobal.workflow);
      }
    else if ((strcmp (command_key, NFI_M_DELETE_ACL_CLASS_USERS)) == 0)
      {
        if ((status = _NFFvalidate_active_data
            (default_mask | NFF_WORKFLOW | NFF_ACL)) != NFI_S_SUCCESS)
          {
            _NFIdebug ((fname,
                "_NFFvalidate_active_data = <0x%.8x>\n", status));
            return (status);
          }

        strcpy (command, DELETE_ACL_USER);
        strcpy (wf_name, NFFglobal.workflow);
      }
    else if ((strcmp (command_key, NFI_M_ADD_ACL_SIGNOFF_USERS)) == 0)
      {
        if ((status = _NFFvalidate_active_data
            (default_mask | NFF_WORKFLOW | NFF_ACL)) != NFI_S_SUCCESS)
          {
            _NFIdebug ((fname,
                "_NFFvalidate_active_data = <0x%.8x>\n", status));
            return (status);
          }

        strcpy (command, ADD_SIGNOFF_USER);
        strcpy (wf_name, NFFglobal.workflow);
      }
    else if ((strcmp (command_key, NFI_M_DELETE_ACL_SIGNOFF_USERS)) == 0)
      {
        if ((status = _NFFvalidate_active_data
            (default_mask | NFF_WORKFLOW | NFF_ACL)) != NFI_S_SUCCESS)
          {
            _NFIdebug ((fname,
                "_NFFvalidate_active_data = <0x%.8x>\n", status));
            return (status);
          }

        strcpy (command, DELETE_SIGNOFF_USER);
        strcpy (wf_name, NFFglobal.workflow);
      }
    else if ((strcmp (command_key, NFI_M_SIGNOFF_ITEM)) == 0)
      {
        if ((status = _NFFvalidate_active_data (default_mask |
            NFF_CATALOG | NFF_ITEM | NFF_REVISION)) != NFI_S_SUCCESS)
          {
            _NFIdebug ((fname,
                "_NFFvalidate_active_data = <0x%.8x>\n", status));
            return (status);
          }

        strcpy (command, SIGNOFF_ITEM);
        strcpy (catalog, NFFglobal.catalog);
        strcpy (item, NFFglobal.item);
        strcpy (revision, NFFglobal.revision);
      }
    else if ((strcmp (command_key, NFI_M_PURGE_SIGNOFF)) == 0)
      {
        if ((status = _NFFvalidate_active_data (default_mask |
            NFF_CATALOG | NFF_ITEM | NFF_REVISION)) != NFI_S_SUCCESS)
          {
            _NFIdebug ((fname,
                "_NFFvalidate_active_data = <0x%.8x>\n", status));
            return (status);
          }

        strcpy (command, PURGE_SIGNOFF);
        strcpy (catalog, NFFglobal.catalog);
        strcpy (item, NFFglobal.item);
        strcpy (revision, NFFglobal.revision);
      }
    else if ((strcmp (command_key, NFI_M_PLOT_ITEM)) == 0)
      {
        if ((status = _NFFvalidate_active_data
            (default_mask | NFF_CATALOG | NFF_ITEM |
            NFF_REVISION | NFF_LIST)) != NFI_S_SUCCESS)
          {
            _NFIdebug ((fname,
                "_NFFvalidate_active_data = <0x%.8x>\n", status));
            return (status);
          }

        if ((strcmp (NFFglobal.set_indicator, "")) == 0)
            strcpy (command, PLOT_ITEM);
        else
            strcpy (command, PLOT_SET);

        strcpy (catalog, NFFglobal.catalog);
        strcpy (item, NFFglobal.item);
        strcpy (revision, NFFglobal.revision);
      }
    else if ((strcmp (command_key, NFI_M_PLOT_SET_PARENT)) == 0)
      {
        if ((status = _NFFvalidate_active_data
            (default_mask | NFF_CATALOG | NFF_ITEM |
            NFF_SET | NFF_REVISION)) != NFI_S_SUCCESS)
          {
            _NFIdebug ((fname,
                "_NFFvalidate_active_data = <0x%.8x>\n", status));
            return (status);
          }

        strcpy (command, PLOT_ITEM);
        strcpy (catalog, NFFglobal.catalog);
        strcpy (item, NFFglobal.item);
        strcpy (revision, NFFglobal.revision);
      }
    else if ((strcmp (command_key, NFI_M_SAVE_ITEM)) == 0)
      {
        if ((status = _NFFvalidate_active_data
            (default_mask | NFF_CATALOG | NFF_ITEM |
            NFF_REVISION | NFF_LIST)) != NFI_S_SUCCESS)
          {
            _NFIdebug ((fname,
                "_NFFvalidate_active_data = <0x%.8x>\n", status));
            return (status);
          }

        if ((strcmp (NFFglobal.set_indicator, "")) == 0)
            strcpy (command, SAVE_ITEM_FILES);
        else
            strcpy (command, SAVE_SET_FILES);

        strcpy (catalog, NFFglobal.catalog);
        strcpy (item, NFFglobal.item);
        strcpy (revision, NFFglobal.revision);
      }
    else if ((strcmp (command_key, NFI_M_SAVE_SET_PARENT)) == 0)
      {
        if ((status = _NFFvalidate_active_data
            (default_mask | NFF_CATALOG | NFF_ITEM |
            NFF_SET | NFF_REVISION)) != NFI_S_SUCCESS)
          {
            _NFIdebug ((fname,
                "_NFFvalidate_active_data = <0x%.8x>\n", status));
            return (status);
          }

        strcpy (command, SAVE_ITEM_FILES);
        strcpy (catalog, NFFglobal.catalog);
        strcpy (item, NFFglobal.item);
        strcpy (revision, NFFglobal.revision);
      }
    else if ((strcmp (command_key, NFI_M_COPY_ACL_USERS)) == 0)
      {
        if ((status = _NFFvalidate_active_data
            (default_mask | NFF_WORKFLOW | NFF_ACL)) != NFI_S_SUCCESS)
          {
            _NFIdebug ((fname,
                "_NFFvalidate_active_data = <0x%.8x>\n", status));
            return (status);
          }

        strcpy (command, COPY_ACL_USERS);
      }
    else if ((strcmp (command_key, NFI_M_DELETE_TAPE_LABELS)) == 0)
      {
        if ((status = _NFFvalidate_active_data
            (default_mask)) != NFI_S_SUCCESS)
          {
            _NFIdebug ((fname,
                "_NFFvalidate_active_data = <0x%.8x>\n", status));
            return (status);
          }
/*
        strcpy (command, DELETE_LABELS);
*/
        do_not_validate = TRUE;
      }
    else if ((strcmp (command_key, NFI_M_ADD_UTIL_SA)) == 0)
      {
        if ((status = _NFFvalidate_active_data
            (default_mask)) != NFI_S_SUCCESS)
          {
            _NFIdebug ((fname,
                "_NFFvalidate_active_data = <0x%.8x>\n", status));
            return (status);
          }

        strcpy (command, ADD_SA);
        do_not_validate = TRUE;
      }
    else if ((strcmp (command_key, NFI_M_LOGIN_TO_ENVIRONMENT)) == 0)
      {
        strcpy (command, "Login to Environment");
        do_not_validate = TRUE;
      }
    else if ((strcmp (command_key, NFI_M_HELP)) == 0)
      {
        /*  There is no need to end the block listings  */

        cleanup_listings = FALSE;

        strcpy (command, "Help");
        do_not_validate = TRUE;
      }
    else if ((strcmp (command_key, NFI_M_EXIT)) == 0)
      {
        /*  There is no need to end the block listings  */

        cleanup_listings = FALSE;

        strcpy (command, "Exit");
        do_not_validate = TRUE;
      }
    else
      {
        _NFIdebug ((fname, "command <%s> is not implemented\n", command_key));
        ERRload_struct (NFI, NFI_I_NO_COMMAND, "%s", command_key);
        return (NFI_I_NO_COMMAND);
      }

    /*  Cleanup the block listings, if necessary  */

    if ((cleanup_listings == TRUE) && (NFMRglobal.query_rows > 0))
      {
        if (NFFglobal.forms[ITEMS_LABEL] != NULL)
          {
            _NFFend_block_listing (ITEMS_LABEL, TRUE);
            NFFerror_message (NFFglobal.forms[ITEMS_LABEL]);

            /*  Set the next state so that autocomitt is turned on */

            if ((status = NFFset_to_state ()) != NFI_S_SUCCESS)
                _NFIdebug ((fname, "NFFset_to_state = <0x%.8x>\n", status));
          }

        if (NFFglobal.forms[PROJM_LABEL] != NULL)
          {
            _NFFend_block_listing (PROJM_LABEL, TRUE);
            NFFerror_message (NFFglobal.forms[PROJM_LABEL]);

            /*  Set the next state so that autocomitt is turned on */

            if ((status = NFFset_to_state ()) != NFI_S_SUCCESS)
                _NFIdebug ((fname, "NFFset_to_state = <0x%.8x>\n", status));
          }

        if (NFFglobal.forms[SETM_LABEL] != NULL)
          {
            _NFFend_block_listing (SETM_LABEL, TRUE);
            NFFerror_message (NFFglobal.forms[SETM_LABEL]);

            /*  Set the next state so that autocomitt is turned on */

            if ((status = NFFset_to_state ()) != NFI_S_SUCCESS)
                _NFIdebug ((fname, "NFFset_to_state = <0x%.8x>\n", status));
          }
      }
    else if ((cleanup_items_only == TRUE) && (NFMRglobal.query_rows > 0))
      {
        /*  This is so that we cleanup any on-going
            multi-catalog search before trying to list again  */

        if (NFFglobal.forms[ITEMS_LABEL] != NULL)
          {
            _NFFend_block_listing (ITEMS_LABEL, TRUE);
            NFFerror_message (NFFglobal.forms[ITEMS_LABEL]);
          }
      }

    /*  Write the command name in the journaling file  */

#ifndef XWINDOWS
    JNL_record_info_event (JNL_CHAR, strlen (command), command);
#endif

    /*  Save the command name for timestamp file  */

    _NFFts_data (("\nCommand             -  %s\n", command));
    _NFFts_data (("User Start Time     -  %d\n", NFFglobal.time_value));

    /*  Validate the user's access to this command  */

    if (do_not_validate == FALSE)
      {
        NFFform_message (CURRENT_LABEL, NFI_I_ACCESS, NULL);

        _NFIdebug ((fname, "calling NFMRvalidate_user_access ...\n"));
        if ((status = NFMRvalidate_user_access ((long) 0, command,
            wf_name, project, catalog, item, revision)) != NFM_S_SUCCESS)
          {
            NFFerase_message ();
            _NFIdebug ((fname,
                "NFMRvalidate_user_access = <0x%.8x>\n", status));
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (status);
          }
        _NFIdebug ((fname, "returned from NFMRvalidate_user_access\n"));

        /*  Record time spent validating user access  */

        _NFFts_data (("Access Validated    -  %d\n", time ((long *) 0)));

        NFFerase_message ();
      }

    _NFIdebug ((fname, " returning SUCCESS\n"));
    return (NFI_S_SUCCESS);
  }


long NFFset_to_state ()
  {
    auto    long    status;
    auto    long    error_no;
    auto    int     subsystem;
    auto    char    error_msg[NFF_MAX_MESSAGE];
    static  char    *fname = "NFFset_to_state";

    ERRget_message (error_msg);
    ERRget_number (&error_no, &subsystem);

    NFFform_message (CURRENT_LABEL, NFI_I_STATE, NULL);

    /*  Timestamp before setting next workflow state  */

    _NFFts_data (("Command Finished    -  %d\n", time ((long *) 0)));

    _NFIdebug ((fname, "calling NFMRset_wf_state ...\n"));
    if ((status = NFMRset_wf_state
        ("NFM", error_no, error_msg)) != NFM_S_SUCCESS)
      {
        NFFerase_message ();
        _NFIdebug ((fname, "NFMRset_wf_state = <0x%.8x>\n", status));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }
    _NFIdebug ((fname, "returned from NFMRset_wf_state\n"));

    /*  Record time spent setting next workflow state  */

    _NFFts_data (("Workflow State Set  -  %d\n", time ((long *) 0)));

    NFFerase_message ();

    _NFIdebug ((fname, " returning SUCCESS\n"));
    return (NFI_S_SUCCESS);
  }
