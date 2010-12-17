#include "machine.h"
#include "WFF.h"
#include "WFstruct.h"
#include "WFcommands.h"
#include "WFFlist.h"
#include "WFFvalidate.h"
#include "WFFtimestamp.h"

extern struct WFstruct WFinfo;

/* extern MSGptr NFMmsg_ptr; */

/*  Global WFF structure  */

extern struct WFFglobal_st WFFglobal;

long WFFvalidate_user_access (command_key)
  char    *command_key;  /*  i - command string stored in the panel menu  */
  {
    long    status;
    char    command[120];
    char    wf_name[40];
    short   do_not_validate = FALSE;

    /*  Default validation mask  */

    long    default_mask = WFF_CONNECT | WFF_LOGIN;

    /*  Local functions  */

    long    _WFFvalidate_active_data ();

    static    char *fname = "WFFvalidate_user_access";

    _NFIdebug ((fname, "command_key = <%s>\n", command_key));

    /*  Initialize wf info  */

    strcpy (wf_name, "");

    /*  Find the workflow command name for this command  */

    if ((strcmp (command_key, WFF_M_DISPLAY_LIST_OF_WORKFLOWS)) == 0)
     {
        if ((status = _WFFvalidate_active_data (default_mask)) != NFI_S_SUCCESS)
         {
            _NFIdebug ((fname, "_WFFvalidate_active_data = <0x%.8x>\n",
                        status));
            return (status);
         }

        strcpy (command, LIST_WORKFLOWS);
     }
    else if ((strcmp (command_key, WFF_M_DISPLAY_WORKFLOWS_SHORT)) == 0)
     {
        if ((status = _WFFvalidate_active_data
            (default_mask)) != NFI_S_SUCCESS)
         {
            _NFIdebug ((fname, "_WFFvalidate_active_data = <0x%.8x>\n",
                        status));
            return (status);
         }

        strcpy (command, LIST_WORKFLOWS);
      }
    else if ((strcmp (command_key, WFF_M_DELETE_WORKFLOW)) == 0)
      {
        if ((status = _WFFvalidate_active_data
            (default_mask | WFF_WORKFLOW)) != NFI_S_SUCCESS)
          {
            _NFIdebug ((fname, "_WFFvalidate_active_data = <0x%.8x>\n", status));
            return (status);
          }

        strcpy (command, DELETE_WORKFLOW);
      }
    else if ((strcmp (command_key, WFF_M_DISPLAY_LIST_OF_ACLS)) == 0)
      {
        if ((status = _WFFvalidate_active_data
            (default_mask | WFF_WORKFLOW)) != NFI_S_SUCCESS)
          {
            _NFIdebug ((fname, "_WFFvalidate_active_data = <0x%.8x>\n", status));
            return (status);
          }

        strcpy (command, LIST_ACLS);
      }

    else if ((strcmp (command_key, WFF_M_DISPLAY_LIST_OF_CLASSES)) == 0)
      {
        if ((status = _WFFvalidate_active_data
            (default_mask | WFF_WORKFLOW)) != NFI_S_SUCCESS)
          {
            _NFIdebug ((fname, "_WFFvalidate_active_data = <0x%.8x>\n", status));
            return (status);
          }

        strcpy (command, LIST_CLASSES);
      }
    else if ((strcmp (command_key, WFF_M_DISPLAY_CLASSES_SHORT)) == 0)
      {
        if ((status = _WFFvalidate_active_data
            (default_mask | WFF_WORKFLOW)) != NFI_S_SUCCESS)
          {
            _NFIdebug ((fname, "_WFFvalidate_active_data = <0x%.8x>\n", status));
            return (status);
          }

        strcpy (command, LIST_CLASSES);
      }
    else if ((strcmp (command_key, WFF_M_DISPLAY_LIST_OF_STATES)) == 0)
      {
        if ((status = _WFFvalidate_active_data
            (default_mask | WFF_WORKFLOW)) != NFI_S_SUCCESS)
          {
            _NFIdebug ((fname, "_WFFvalidate_active_data = <0x%.8x>\n", status));
            return (status);
          }

        strcpy (command, LIST_STATES);
      }
    else if ((strcmp (command_key, WFF_M_DISPLAY_LIST_OF_TRANSITIONS)) == 0)
      {
        if ((status = _WFFvalidate_active_data
            (default_mask | WFF_WORKFLOW)) != NFI_S_SUCCESS)
          {
            _NFIdebug ((fname, "_WFFvalidate_active_data = <0x%.8x>\n", status));
            return (status);
          }

        strcpy (command, LIST_TRANSITIONS);
      }
    else if ((strcmp (command_key,WFF_M_DISPLAY_LIST_OF_CLASS_ACCESS)) == 0)
      {
        if ((status = _WFFvalidate_active_data
            (default_mask | WFF_WORKFLOW)) != NFI_S_SUCCESS)
          {
            _NFIdebug ((fname, "_WFFvalidate_active_data = <0x%.8x>\n", status));
            return (status);
          }

        strcpy (command, LIST_CLASS_TO_TRANS);
      }
    else if ((strcmp (command_key, WFF_M_DISPLAY_LIST_OF_COMMANDS)) == 0)
      {
        if ((status = _WFFvalidate_active_data
            (default_mask)) != NFI_S_SUCCESS)
         {
            _NFIdebug ((fname, "_WFFvalidate_active_data = <0x%.8x>\n",
                                status));
            return (status);
         }

        strcpy (command, LIST_COMMANDS);
      }
/*
    else if ((strcmp (command_key, WFF_M_DISPLAY_ACL_CLASS_USERS)) == 0)
      {
        if ((status = _WFFvalidate_active_data
            (default_mask | WFF_ACL)) != NFI_S_SUCCESS)
          {
            _NFIdebug ((fname, "_WFFvalidate_active_data = <0x%.8x>\n", status));
            return (status);
          }

        strcpy (command, LIST_ACL_CLASS_USERS);
      }
    else if ((strcmp (command_key, WFF_M_DISPLAY_ACL_SO_USERS)) == 0)
      {
        if ((status = _WFFvalidate_active_data
            (default_mask | WFF_ACL)) != NFI_S_SUCCESS)
          {
            _NFIdebug ((fname, "_WFFvalidate_active_data = <0x%.8x>\n", status));
            return (status);
          }

        strcpy (command, LIST_ACL_SIGNOFF_USERS);
      }
*/
    else if ((strcmp (command_key, WFF_M_LOAD_WORKFLOW)) == 0)
      {
        if ((status = _WFFvalidate_active_data
            (default_mask)) != NFI_S_SUCCESS)
          {
            _NFIdebug ((fname, "_WFFvalidate_active_data = <0x%.8x>\n", status));
            return (status);
          }

        strcpy (command, LOAD_WORKFLOW);
      }
    else if ((strcmp (command_key, WFF_M_DUMP_WORKFLOW)) == 0)
      {
        if ((status = _WFFvalidate_active_data
            (default_mask | WFF_WORKFLOW)) != NFI_S_SUCCESS)
          {
            _NFIdebug ((fname, "_WFFvalidate_active_data = <0x%.8x>\n", status));
            return (status);
          }

        strcpy (command, DUMP_WORKFLOW);
      }
    else if ((strcmp (command_key, WFF_M_ADD_WORKFLOW)) == 0)
      {
        if ((status = _WFFvalidate_active_data
            (default_mask)) != NFI_S_SUCCESS)
          {
            _NFIdebug ((fname, "_WFFvalidate_active_data = <0x%.8x>\n", status));
            return (status);
          }

        strcpy (command, ADD_WORKFLOW);
      }
    else if ((strcmp (command_key, WFF_M_CHANGE_WORKFLOW)) == 0)
      {
        if ((status = _WFFvalidate_active_data
            (default_mask | WFF_WORKFLOW )) != NFI_S_SUCCESS)
          {
            _NFIdebug ((fname, "_WFFvalidate_active_data = <0x%.8x>\n", status));
            return (status);
          }

        strcpy (command, ADD_WORKFLOW);
      }
    else if ((strcmp (command_key, WFF_M_ADD_COMMANDS)) == 0)
      {
        if ((status = _WFFvalidate_active_data
            (default_mask)) != NFI_S_SUCCESS)
          {
            _NFIdebug ((fname, "_WFFvalidate_active_data = <0x%.8x>\n", status));
            return (status);
          }

        strcpy (command, ADD_COMMANDS);
      }
    else if ((strcmp (command_key, WFF_M_DELETE_COMMANDS)) == 0)
      {
        if ((status = _WFFvalidate_active_data
            (default_mask)) != NFI_S_SUCCESS)
          {
            _NFIdebug ((fname, "_WFFvalidate_active_data = <0x%.8x>\n", status));
            return (status);
          }

        strcpy (command, DELETE_COMMANDS);
      }
/*
    else if ((strcmp (command_key, WFF_M_DEFINE_ACL)) == 0)
      {
        if ((status = _WFFvalidate_active_data
            (default_mask)) != NFI_S_SUCCESS)
          {
            _NFIdebug ((fname, "_WFFvalidate_active_data = <0x%.8x>\n", status));
            return (status);
          }

        strcpy (command, ADD_ACL);
      }
    else if ((strcmp (command_key, WFF_M_ADD_ACL_CLASS_USERS)) == 0)
      {
        if ((status = _WFFvalidate_active_data
            (default_mask | WFF_WORKFLOW | WFF_ACL)) != NFI_S_SUCCESS)
          {
            _NFIdebug ((fname, "_WFFvalidate_active_data = <0x%.8x>\n", status));
            return (status);
          }

        strcpy (command, ADD_ACL_USER);
        strcpy (wf_name, WFFglobal.workflow);
      }
*/
/*
    else if ((strcmp (command_key, WFF_M_DELETE_ACL_CLASS_USERS)) == 0)
      {
        if ((status = _WFFvalidate_active_data
            (default_mask | WFF_WORKFLOW | WFF_ACL)) != NFI_S_SUCCESS)
          {
            _NFIdebug ((fname, "_WFFvalidate_active_data = <0x%.8x>\n", status));
            return (status);
          }

        strcpy (command, DELETE_ACL_USER);
        strcpy (wf_name, WFFglobal.workflow);
      }
*/
    else if ((strcmp (command_key, WFF_M_LOGIN_TO_ENVIRONMENT)) == 0)
      {
        /*  Login To Environment  */

        if ((status = _WFFvalidate_active_data
            (WFF_CONNECT | WFF_LOGOUT)) != NFI_S_SUCCESS)
          {
            _NFIdebug ((fname,
                "_WFFvalidate_active_data = <0x%.8x>\n", status));
            return (status);
          }

        /* strcpy (command, LOGIN_ENV); */
        strcpy (command, "Login to Environment"); 
        do_not_validate = TRUE;
      }
    else if ((strcmp (command_key, WFF_M_LOGOUT_FROM_ENVIRONMENT)) == 0)
      {
        /*  Logout From Environment  */

        if ((status = _WFFvalidate_active_data
            (default_mask)) != NFI_S_SUCCESS)
          {
            _NFIdebug ((fname,
                "_WFFvalidate_active_data = <0x%.8x>\n", status));
            return (status);
          }

        /* strcpy (command, LOGOUT_ENV); */
        strcpy (command, "Logout from Environment");
        do_not_validate = TRUE;
      }
    else if ((strcmp (command_key, WFF_M_DEFINE_CLIENT_DEBUG_MODE)) == 0)
      {
        /*  Define Client Debug Mode  */

        _WFFprocess_cleanup (1);
        strcpy (command, "Define Client Debug Mode");
        do_not_validate = TRUE;
      }
    else if ((strcmp (command_key, WFF_M_DEFINE_SERVER_DEBUG_MODE)) == 0)
      {
        /*  Define Server Debug Mode  */

        if ((status = _WFFvalidate_active_data
            (default_mask)) != NFI_S_SUCCESS)
          {
            _NFIdebug ((fname,
                "_WFFvalidate_active_data = <0x%.8x>\n", status));
            return (status);
          }

        strcpy (command, "Define Server Debug Mode");
        do_not_validate = TRUE;
      }
/*
    else if ((strcmp (command_key, WFF_M_BEGIN_RECORD_SESSION)) == 0)
      {
        / *  Begin a Recording Session  * /

        if ((status = _WFFvalidate_active_data
            (WFF_BEGIN_RECORDING)) != NFI_S_SUCCESS)
          {
            _NFIdebug ((fname,
                "_WFFvalidate_active_data = <0x%.8x>\n", status));
            return (status);
          }

        strcpy (command, "Begin Recording Session");
        do_not_validate = TRUE;
      }
    else if ((strcmp (command_key, WFF_M_END_RECORD_SESSION)) == 0)
      {
        / *  End a Recording Session  * /

        if ((status = _WFFvalidate_active_data
            (WFF_END_RECORDING)) != NFI_S_SUCCESS)
          {
            _NFIdebug ((fname,
                "_WFFvalidate_active_data = <0x%.8x>\n", status));
            return (status);
          }

        strcpy (command, "End Recording Session");
        do_not_validate = TRUE;
      }
    else if ((strcmp (command_key, WFF_M_BEGIN_PLAYBACK_SESSION)) == 0)
      {
        / *  Begin a Playback Session  * /

        if ((status = _WFFvalidate_active_data
            (WFF_BEGIN_PLAYBACK)) != NFI_S_SUCCESS)
          {
            _NFIdebug ((fname,
                "_WFFvalidate_active_data = <0x%.8x>\n", status));
            return (status);
          }

        strcpy (command, "Begin Playback Session");
        do_not_validate = TRUE;
      }
*/
    else if ((strcmp (command_key, WFF_M_HELP)) == 0)
      {
        /*  Help  */

        strcpy (command, "Help");
        do_not_validate = TRUE;
      }
    else if ((strcmp (command_key, WFF_M_EXIT)) == 0)
      {
        /*  Exit  */

        strcpy (command, "Exit");
        do_not_validate = TRUE;
      }
    else
      {
        _NFIdebug ((fname, "command <%s> is not implemented\n", command_key));
        ERRload_struct (NFI, NFI_I_NO_COMMAND, "%s", command_key);
        return (NFI_I_NO_COMMAND);
      }

    /*  Write the command name in the journalling file  */
/*

    JNL_record_info_event (JNL_CHAR, strlen (command), command);
*/

    /*  Save the command name for timestamp file  */

/*
    _WFFts_data (("\nCommand             -  %s\n", command));
    _WFFts_data (("User Start Time     -  %d\n", WFFglobal.time_value));
*/

    /*  Validate the user's access to this command  */

    if (do_not_validate == FALSE)
      {
        _WFFmessage (NFI_I_ACCESS, NULL);

        _NFIdebug ((fname, "calling WFvalidate_user_access ...\n"));
        if ((status = WFvalidate_user_access
            (WFFglobal.user_id, command, wf_name,
                                "", "", "", "")) != NFM_S_SUCCESS)
          {
            _WFFerase_message ();
            _NFIdebug ((fname,
                "WFvalidate_user_access = <0x%.8x>\n", status));
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (status);
          }
        _NFIdebug ((fname, "returned from WFvalidate_user_access\n"));

        /*  Record time spent validating user access  */

/*
        _WFFts_data (("Access Validated    -  %d\n", time ((long *) 0)));
*/

        _WFFerase_message ();
      }

    _NFIdebug ((fname, " returning SUCCESS\n"));
    return (NFI_S_SUCCESS);
  }


long WFFset_to_state ()
  {
    long    status;
    char    message[512];

    static    char *fname = "WFFset_to_state";

    WFFglobal.error_no = WFFglobal.cmd_status; 

    if ((status = (long) UMSGetByNum
        (message, WFFglobal.error_no, NULL)) != UMS_S_SUCCESS)
     {
         _NFIdebug ((fname, "UMSGetByNum = <%d>\n", status));
         _NFIdebug ((fname, "defaulting message\n"));
     
         if (WFFglobal.error_no == NFI_S_SUCCESS)
             strcpy (message, "Successful completion");
         else
             strcpy (message, "Operation failed"); 
     }

    _NFIdebug ((fname, "WFFglobal.error_no = <0x%.8x>\n", WFFglobal.error_no));
    _NFIdebug ((fname, "Error Message = <%s>\n", message));

    _WFFmessage (NFI_I_STATE, NULL);

    /*  Timestamp before setting next workflow state  */

/*
    _WFFts_data (("Command Finished    -  %d\n", time ((long *) 0)));
*/

    _NFIdebug ((fname, "calling NFMset_wf_state ...\n"));
    if ((status = NFMset_wf_state
        ("NFM", WFFglobal.error_no, message)) != NFM_S_SUCCESS)
     {
        _WFFerase_message ();
        _NFIdebug ((fname, "NFMset_wf_state = <0x%.8x>\n", status));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
     }
    _NFIdebug ((fname, "returned from NFMset_wf_state\n"));

    /*  Record time spent setting next workflow state  */

/*
    _WFFts_data (("Workflow State Set  -  %d\n", time ((long *) 0)));
*/

    _WFFerase_message ();

    _NFIdebug ((fname, " returning SUCCESS\n"));
    return (NFI_S_SUCCESS);
  }


long _WFFvalidate_active_data (mask)
  long    mask;
  {
    static    char *fname = "_WFFvalidate_active_data";

    /*  Check first to see if the user is connected and logged in  */

    if (mask & WFF_CONNECT)
      {
          ;
      }
    else if (mask & WFF_DISCONNECT)
      {
          ;
      }

    if (mask & WFF_LOGIN)
      {
        /* if (WFFglobal.user_id == 0) */
        if (WFFglobal.user_id < 0)
          {
            ERRload_struct (NFI, NFI_E_MUST_LOGIN, NULL);
            return (NFI_E_MUST_LOGIN);
          }
      }
    else if (mask & WFF_LOGOUT)
      {
        if (WFFglobal.user_id != 0)
          {
/*
            ERRload_struct (NFI, NFI_E_MUST_LOGOUT, NULL);
            return (NFI_E_MUST_LOGOUT);
*/
                     ;
          }
      }


    if (mask & WFF_WORKFLOW)
      {
        if ((strcmp (WFFglobal.workflow, "")) == 0)
          {
            if (WFFglobal.current_list != WFF_LIST_WORKFLOWS)
                _WFFprocess_data (0,
                                              WFF_M_DISPLAY_LIST_OF_WORKFLOWS);
            else
                WFFglobal.cmd_status = NFI_S_SUCCESS;

            if (WFFglobal.cmd_status == NFI_S_SUCCESS)
              {
                ERRload_struct (NFI, NFI_I_CHOOSE_WORKFLOW, NULL);
                return (NFI_I_CHOOSE_WORKFLOW);
              }
            else
                return (WFFglobal.cmd_status);
          }
      }

/*
    if (mask & WFF_ACL)
      {
        if ((strcmp (WFFglobal.acl, "")) == 0)
          {
            if (WFFglobal.current_list != WFF_LIST_ACLS)
                _WFFprocess_data (0, WFF_M_DISPLAY_ACLS);
            else
                WFFglobal.cmd_status = NFI_S_SUCCESS;

            if (WFFglobal.cmd_status == NFI_S_SUCCESS)
              {
                ERRload_struct (NFI, NFI_I_CHOOSE_ACL, NULL);
                return (NFI_I_CHOOSE_ACL);
              }
            else
                return (WFFglobal.cmd_status);
          }
      }
*/

    if (mask & WFF_BEGIN_RECORDING)
      {
        /*  See if the user is recording  */

        if ((strcmp (WFFglobal.record_file, "")) != 0)
          {
            ERRload_struct (NFI, NFI_E_ALREADY_RECORDING, NULL);
            return (NFI_E_ALREADY_RECORDING);
          }
      }

    if (mask & WFF_END_RECORDING)
      {
        /*  See if the user is recording  */

        if ((strcmp (WFFglobal.record_file, "")) == 0)
          {
            ERRload_struct (NFI, NFI_E_NOT_RECORDING, NULL);
            return (NFI_E_NOT_RECORDING);
          }
      }

    if (mask & WFF_BEGIN_PLAYBACK)
      {
        /*  See if the user is recording  */

        if ((strcmp (WFFglobal.record_file, "")) != 0)
          {
            ERRload_struct (NFI, NFI_E_MUST_END_RECORDING, NULL);
            return (NFI_E_MUST_END_RECORDING);
          }
      }

    _NFIdebug ((fname, " returning SUCCESS\n"));
    return (NFI_S_SUCCESS);
  }
