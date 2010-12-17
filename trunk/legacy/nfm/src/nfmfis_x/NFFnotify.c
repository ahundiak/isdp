
/* machine.h included to take care of platform variencies MVR 23 Dec 1993 */
#include "machine.h"

#include "NFF.h"
#include "NFFconfirm.h"
#include "NFFtimestamp.h"
#include "QUI.h"
#include "NFFmain_form.h"

/*  Global NFF structure  */

extern struct NFFglobal_st NFFglobal;

void _NFFnotify (f_label, g_label, value, form)
  int       f_label;
  int       g_label;
  double    value;
  Form      form;
  {
    auto    long    status = NFI_S_SUCCESS;
    auto    short   end_of_command = FALSE;
    auto    short   clear_item_globals = FALSE;
    static  char    *fname = "_NFFnotify";

    /*  Timestamp the end of the user's input  */

    if ((g_label == FI_ACCEPT) || (g_label == FI_EXECUTE) ||
        (g_label == FI_CANCEL) || (g_label == CANCEL_BUTTON) ||
        (g_label == NFF_CANCEL) || (g_label == NFF_EXECUTE) ||
        (g_label == OK_BUTTON))
      {
        _NFFts_data (("User Input Finished -  %d\n", time ((long *) 0)));
        end_of_command = TRUE;
      }
    else if ((g_label == LEFT_SCROLL_BUTTON) ||
        (g_label == RIGHT_SCROLL_BUTTON))
      {
        _NFIdebug ((fname, "Message is scrolling\n"));
        _NFFscroll_message (form, g_label);
        _NFIdebug ((fname, " returning ...\n\n"));
        return;
      }

    /*  Reset the global error structure  */

    ERRreset_struct ();
    NFFform_message (f_label, NFI_S_CLEAR_MSG, NULL);

    _NFIdebug ((fname, "f_label = <%d>\n", f_label));

    switch (f_label)
      {
        case LOGIN_LABEL:
            status = _NFFlogin_notify (g_label, &form);
            break;

        case MAIN_LABEL:
            status = _NFFmain_notify (g_label, (int) value, form);
            break;

        case PROJECTS_LABEL:
        case CATALOGS_LABEL:
        case WORKING_AREAS_LABEL_ADMIN:
        case WORKING_AREAS_LABEL_USER:
        case NODES_LABEL:
        case STORAGE_AREAS_LABEL:
        case USERS_LABEL:
        case WORKFLOWS_LABEL:
        case ACLS_LABEL:
        case ACLUSERS_LABEL:
        case SIGNOFFUSERS_LABEL:
        case CATALOGACL_LABEL:
        case CATALOGSA_LABEL:
        case PROJECTACL_LABEL:
        case PROJECTSA_LABEL:
        case ARCHIVES_LABEL:
        case BACKUPS_LABEL:
        case RESTORE_LABEL:
        case DELETE_LABEL:
        case SEARCH_LABEL:
        case SORT_LABEL:
        case LOCAL_FILES_LABEL:
        case ITEM_SIGNOFF_LABEL:
        case SIGNOFF_HISTORY_LABEL:
        case WHERE_PROJECT_LABEL:
        case WHERE_SET_LABEL:
        case LIST_ARCHIVES_LABEL:
        case SAVESETS_LABEL:
        case ITEMS_TAPE_LABEL:
            status = _NFFdisplay_notify (f_label, g_label, (int) value, &form);
            break;

        case ITEMS_LABEL:
        case REVIEW_LABEL:
        case PROJM_LABEL:
        case SETM_LABEL:
            status = _NFFdisplay_items_notify
                (f_label, g_label, (int) value, &form);
            break;

        case TAPE_LABELS_LABEL:
            status = _NFFdelete_tape_labels_notify (g_label, &form);
            break;

        case SAVESET_ENTRIES_LABEL:
            status = _NFFdelete_saveset_entries_notify (g_label, &form);
            break;

        case CREATE_CAT_LABEL:
            status = _NFFcrcat_notify (g_label, (int) value, &form);
            break;

        case ADD_LABEL:
            status = _NFFadd_notify (g_label, (int) value, &form);
            break;

        case CHANGE_ITEM_LABEL:
            status = _NFFchange_item_notify (g_label, (int) value, &form);
            break;

        case DEBUG_LABEL:
            status = _NFFdebug_notify (g_label, &form);
            break;

        case DELETE_CONFIRM_LABEL:
        case CONFIRM_LABEL:
        case FLAG_ARCHIVE_LABEL:
        case FLAG_PROJECT_ARCHIVE_LABEL:
        case FLAG_BACKUP_LABEL:
        case FLAG_PROJECT_BACKUP_LABEL:
        case FLAG_RESTORE_LABEL:
        case FLAG_PROJECT_RESTORE_LABEL:
        case FLAG_DELETE_LABEL:
        case DELETE_SA_LABEL:
        case DELETE_CAT_LABEL:
        case DELETE_NODE_LABEL:
        case DELETE_PROJECT_LABEL:
        case DELETE_USER_LABEL:
            status = _NFFconfirm_notify (f_label, g_label, &form);
            break;

        case DELETE_ACL_CONFIRM_LABEL:
            status = _NFFconfirm_acl_notify (g_label, &form);
            break;

        case DELETE_COPIED_FILES_LABEL:
            status = _NFFdelete_copied_files_notify (g_label, &form);
            break;

        case DELETE_SORT_LABEL:
        case DELETE_SEARCH_LABEL:
            status = _NFFdelete_query_notify (f_label, g_label, &form);
            break;

        case CHECKIN_CONFIRM_LABEL:
            if (strcmp (NFFglobal.set_indicator, "") == 0)
                status = _NFFfile_io_confirm_notify (g_label, &form);
            else
                status = _NFFset_io_confirm_notify (g_label, &form);
            break;

        case CI_SET_ITEM_LABEL:
            status = _NFFfile_io_confirm_notify (g_label, &form);
            break;

        case CHECKOUT_CONFIRM_LABEL:
            if (strcmp (NFFglobal.set_indicator, "") == 0)
                status = _NFFfile_io_confirm_notify (g_label, &form);
            else
                status = _NFFset_io_confirm_notify (g_label, &form);
            break;

        case CO_SET_ITEM_LABEL:
            status = _NFFfile_io_confirm_notify (g_label, &form);
            break;

        case CANCEL_CO_CONFIRM_LABEL:
            if (strcmp (NFFglobal.set_indicator, "") == 0)
                status = _NFFcancel_item_checkout_notify (g_label, &form);
            else
                status = _NFFcancel_set_checkout_notify (g_label, &form);
            break;

        case CN_SET_ITEM_CO_LABEL:
            status = _NFFcancel_item_checkout_notify (g_label, &form);
            break;

        case COPY_FILES_CONFIRM_LABEL:
            if (strcmp (NFFglobal.set_indicator, "") == 0)
                status = _NFFfile_io_confirm_notify (g_label, &form);
            else
                status = _NFFset_io_confirm_notify (g_label, &form);
            break;

        case CP_SET_ITEM_FILES_LABEL:
            status = _NFFfile_io_confirm_notify (g_label, &form);
            break;

        case MK_TRANS_LABEL:
            status = _NFFmk_trans_notify (g_label, (int) value, &form);
            break;

        case ADD_ACL_CLASS_USERS_LABEL:
            status = _NFFadd_acl_class_users_notify
                (g_label, (int) value, &form);
            break;

        case DELETE_ACL_CLASS_USERS_LABEL:
            status = _NFFdelete_acl_class_users_notify
                (g_label, (int) value, &form);
            break;

        case ADD_ACL_LABEL:
            status = _NFFadd_acl_notify (g_label, (int) value, &form);
            break;

        case ADD_ACL_SIGNOFF_USERS_LABEL:
            status = _NFFadd_acl_signoff_users_notify
                (g_label, (int) value, &form);
            break;

        case DELETE_ACL_SIGNOFF_USERS_LABEL:
            status = _NFFdelete_acl_signoff_users_notify
                (g_label, (int) value, &form);
            break;

        case ADD_MAPPING_LABEL:
            status = _NFFadd_map_notify (g_label, (int) value, &form);
            break;

        case DELETE_MAPPING_LABEL:
            status = _NFFdelete_map_notify (g_label, (int) value, &form);
            break;

        case CHANGE_CAT_LABEL:
            status = _NFFchcat_notify (g_label, (int) value, &form);
            break;

        case ERROR_FORM_LABEL:
            status = _NFFerror_notify (g_label, &form);
            break;

        case SERVERS_POPUP_LABEL:
        case ENVS_POPUP_LABEL:
        case PROJECTS_POPUP_LABEL:
        case CATALOGS_POPUP_LABEL:
        case BLOCK_ITEMS_POPUP_LABEL:
        case ITEMS_POPUP_LABEL:
        case REVISIONS_POPUP_LABEL:
        case SEARCH_POPUP_LABEL:
        case SORT_POPUP_LABEL:
        case WORKING_AREAS_POPUP_LABEL:
        case NODES_POPUP_LABEL:
        case STORAGE_AREAS_POPUP_LABEL:
        case USERS_POPUP_LABEL:
        case WORKFLOWS_POPUP_LABEL:
        case ACLS_POPUP_LABEL:
            status = _NFFpopup_notify (f_label, g_label, (int) value, &form);
            break;

        case COPY_ITEM_LABEL:
            status = _NFFcopy_item_notify (g_label, (int) value, &form);
            break;

/* This label needs to be changed to "PROCESS_FILE_LABEL" */ 
        case ADD_FILE_LABEL:
            status = _NFFprocess_files_notify (g_label, (int) value, &form);
            break;

        case PLOT_ITEM_LABEL:
        case SAVE_ITEM_LABEL:
        case GENERIC_CONFIRM_LABEL:
            status = _NFFgeneric_confirm_notify (g_label, &form);
            break;

        case ROLL_VERSION_LABEL:
            status = _NFFroll_versions_notify (g_label, &form);
            break; 

        case QUI_FORM_LABEL:
            status = _QUInotify (g_label, value, &form);

            /*  Make the return status the same  */

            if (status == QUI_S_SUCCESS)
                status = NFI_S_SUCCESS;

            /*  Check to see if the form pointer is NULL  */

            if (form == NULL)
                NFFglobal.current_form = NULL;

            break; 

        case DEFINE_SORT_LABEL:
            status = _NFFdefine_sort_criteria_notify (g_label, value, &form);
            break; 

        case ADD_SET_MEMBERS_LABEL:
            status = _NFFdefine_set_members_notify (g_label, &form);
            break;

        case ADD_PROJECT_MEMBERS_LABEL:
            status = _NFFdefine_project_members_notify (g_label, &form);
            break;

        case ADD_UTIL_SA_LABEL:
            status = _NFFadd_util_sa_notify (g_label, &form);
            break;

        case CHANGE_SA_PASSWD_LABEL:
            status = _NFFchange_sa_password_notify (g_label, &form);
            break;

        case CHANGE_USER_PASSWD_LABEL:
            status = _NFFchange_user_password_notify (g_label, &form);
            break;

        case CHANGE_WA_PASSWD_LABEL:
            status = _NFFchange_wa_password_notify (g_label, &form);
            break;

        case DELETE_MEMBERS_LABEL:
            status = _NFFdefine_members_notify (g_label, value, &form);
            break;

        case SIGNOFF_ITEM_LABEL:
            status = _NFFsignoff_on_item_notify (g_label, (int) value, &form);
            break; 

        case FLAG_LABEL:
            status = _NFFflagged_files_notify (g_label, &form);
            break;

        case AB_UTILITY_LABEL:
            status = _NFFprocess_ab_items_notify (g_label, &form);
            break;

        case UTILITY_MSG_LABEL:
            status = _NFFutility_message_notify (g_label, &form);
            break;

        case CHANGE_ITEM_WF_LABEL:
            status = _NFFchange_item_wf_notify (g_label, &form);
            break;

        case COPY_ACL_LABEL:
            status = _NFFcopy_acl_notify (g_label, (int) value, &form);
            break;

        case COPY_ACL_USERS_LABEL:
            status = _NFFcopy_acl_users_notify (g_label, (int) value, &form);
            break;

        case FLAG_ITEM_LABEL:
            status = _NFFflag_item_notify (g_label, &form) ;
            break;

        default:
            break;
      }

    /*  Display any messages  */

    if (status != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "status is not successful <%d>\n", status));

        /*  Make sure the form has not been deleted  */

        if (form == NULL){
            _NFIdebug ((fname, "Message on NFFglobal.main_label form\n"));
            NFFerror_message (NFFglobal.forms[MAIN_LABEL]);
	}
        else {
            _NFIdebug ((fname, "Message on current form\n"));
            NFFerror_message (form);
	}

        if (end_of_command == TRUE)
          {
            /*  Timestamp at the end of the command  */

            _NFFts_data (("End of Command      -  %d\n", time ((long *) 0)));

            /*  Commit the data to the timestamp file  */

            _NFFts_commit ();
          }
      }
    else if (end_of_command == TRUE)
      {
        /*  Make sure the form has not been deleted  */

        if (form == NULL)
            NFFerror_message (NFFglobal.forms[MAIN_LABEL]);
        else
/*            NFFerror_message (form);   */
/* Changed to take out the confusing "Successful Completion" 
   message when verify password is entered for User -> Change 
   working area password     - Jujare-IGI-16 FEB 1995 */ 
           {
            if ( (f_label == CHANGE_WA_PASSWD_LABEL) || 
		 ( f_label == ADD_LABEL ) ) {
                NFFform_message (f_label, NFI_S_CLEAR_MSG, NULL);
                _NFIdebug ((fname, "Entered into if clause <%d>\n", f_label));
	    }
            else {
                _NFIdebug ((fname, "Entered into else clause <%d>\n", f_label));
                NFFerror_message (form);
            }
           }

        /*  Timestamp at the end of the command  */

        _NFFts_data (("End of Command      -  %d\n", time ((long *) 0)));

        /*  Commit the data to the timestamp file  */

        _NFFts_commit ();
      }

    _NFIdebug ((fname, "Form label before NFFprocess_list <%d>\n", f_label));
    if ((status == NFI_S_SUCCESS) && (f_label == DELETE_CONFIRM_LABEL))
      { 
        _NFIdebug ((fname, "Setting clear_item_globals flag\n"));
        clear_item_globals = TRUE;
      }

    _NFFprocess_list (f_label, g_label);

    /*  If this is DELETE_ITEM, these global values were used in list
     *  processing and need to be kept until the bloody end.
     */

    if (clear_item_globals == TRUE)
      {
        strcpy (NFFglobal.item, "");
        FIfld_set_text (NFFglobal.forms[MAIN_LABEL],
            ITEM_FIELD, 0, 0, NFFglobal.item, FALSE);

        strcpy (NFFglobal.revision, "");
        FIfld_set_text (NFFglobal.forms[MAIN_LABEL],
            REVISION_FIELD, 0, 0, NFFglobal.revision, FALSE);
      }

    _NFIdebug ((fname, " returning ...\n\n"));
    return;
  }
