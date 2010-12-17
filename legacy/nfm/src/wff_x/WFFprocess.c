#include "machine.h"
#include "WFF.h"
#include "WFFpersist.h"
#include "WFFlist.h"
#include "NFMtypes.h"
#include "WFFtimestamp.h"

/*  Global WFF structure  */

extern struct WFFglobal_st WFFglobal;

/*  This is the function that is called whenever a button
    on either the panel or bar menu is pushed by the user  */

void _WFFprocess_data (type, command)
  int	type;
  char	*command;
  {
    int		help_is_displayed = FALSE;
    int		display_command = FALSE;
    int		curr_page;
    long	status;
    static      char previous_command[15];

    static	char *fname = "_WFFprocess_data";

    void	_WFFprocess_cleanup ();

    void _WFFnotify ();
    void ERRreset_struct ();

    _NFIdebug ((fname, "type = <%d>\n", type));
    _NFIdebug ((fname, "command = <%s>\n", command));
    _NFIdebug ((fname, "previous_command = <%s>\n", previous_command));

    /*  See if another command is active so we don't exit a command
     *  in midstream.
     */

    if (WFFglobal.current_form != NULL)
      {
        _NFIdebug ((fname, "current_form is NOT NULL\n"));

        if ((strcmp (command, WFF_M_DEFINE_SERVER_DEBUG_MODE)) == 0 ||
	    (strcmp (command, WFF_M_DEFINE_CLIENT_DEBUG_MODE)) == 0 )
          {
            /*  Debug is okay  */

            ;
          }
        else if ((strcmp (command, WFF_M_EXIT)) == 0)
          {
            /*  Make sure that we don't mess anything up  */

            if (((strcmp (previous_command, WFF_M_CHANGE_WORKFLOW)) == 0) ||
                ((strcmp (previous_command, WFF_M_ADD_WORKFLOW)) == 0) ||
                ((strcmp (previous_command, WFF_M_ADD_COMMANDS)) == 0))
              {
                ERRload_struct (NFI, NFI_W_COMMAND_COMPLETE, NULL);
                _WFFerror_message (WFFglobal.current_form);
                return;
              }

            /*  Call set to state first  */

            ERRload_struct (NFI, NFI_W_COMMAND_CANCELLED, NULL);
            WFFset_to_state ();
          }
        else if ((strcmp (command, WFF_M_HELP)) == 0)
          {
            /*  Activate Help  */

            ;
          }
        else
          {
            ERRload_struct (NFI, NFI_W_COMMAND_COMPLETE, NULL);
            _WFFerror_message (WFFglobal.current_form);
            return;
          }
      }
      else
	  _NFIdebug(( fname, "GLOBAL FORM IS NULL\n" ));

    /*  Get command start time  */

/*
	_WFFts_command_start ();
*/

    /*  We don't want to remember DEBUG and HELP commands */

    if( (strcmp( command, WFF_M_DEFINE_SERVER_DEBUG_MODE ) != 0 ) &&
	(strcmp( command, WFF_M_DEFINE_CLIENT_DEBUG_MODE ) != 0 ) &&
	(strcmp( command, WFF_M_HELP ) != 0 ))
        strcpy( previous_command, command );

    /*  Clear out the error message field  */

    _WFFclear_msg (WFFglobal.main_form);

    /*  Reset the global error structure  */

    ERRreset_struct ();

    /*  Change the help topic if the help form is displayed  */

    if (WFFglobal.Help_initialized == TRUE)
      {
        if (status = Help_active (&help_is_displayed))
          {
            _NFIdebug ((fname, "Help_active = <%d>\n", status));
            help_is_displayed = FALSE;
          }
      }

    if (help_is_displayed)
      {
        if (status = _WFFhelp_topic (command))
            _NFIdebug ((fname, "_WFFhelp_topic = <%d>\n", status));
      }

    /*  Validate the user's access to this command  */

    if ((status = WFFvalidate_user_access (command)) != NFI_S_SUCCESS)
    {
	_NFIdebug ((fname, "WFFvalidate_user_access = <0x%.8x>\n", status));
	_WFFprocess_cleanup (0);
	_WFFmain_message ();
	WFFglobal.cmd_status = status;
	_NFIdebug ((fname, " returning ...\n\n"));
	return;
    }

    else if ((strcmp (command, WFF_M_DISPLAY_LIST_OF_WORKFLOWS)) == 0)
    {
	_NFIdebug ((fname, "Display Workflows Long\n"));
	status = WFFlist_workflows_long (WFFglobal.main_form);
	display_command = TRUE;
    }
    else if ((strcmp (command, WFF_M_DISPLAY_WORKFLOWS_SHORT)) == 0)
    {
	_NFIdebug ((fname, "Display Workflows Short\n"));
	status = WFFlist_workflows_short (WFFglobal.main_form);
	display_command = TRUE;
    }
    else if ((strcmp (command, WFF_M_DELETE_WORKFLOW)) == 0)
    {
 	_NFIdebug ((fname, "Delete Workflow\n"));
	status = WFFdelete_workflow (WFFglobal.workflow);
    }
    else if ((strcmp (command, WFF_M_LOAD_WORKFLOW) == 0))
    {
	_NFIdebug ((fname, "Load Workflow\n"));
	status = WFFload_workflow ();
    }
    else if ((strcmp (command, WFF_M_DUMP_WORKFLOW) == 0))
    {
	_NFIdebug ((fname, "Dump Workflow\n"));
	status = WFFdump_workflow (WFFglobal.workflow);
    }
    else if ((strcmp (command, WFF_M_DISPLAY_LIST_OF_CLASSES)) == 0)
    {
 	_NFIdebug ((fname, "Display Classes Long\n"));
	status = WFFlist_classes_long (WFFglobal.main_form,WFFglobal.workflow);
	display_command = TRUE;
    }
    else if ((strcmp (command, WFF_M_DISPLAY_CLASSES_SHORT)) == 0)
    {
	_NFIdebug ((fname, "Display classes Short\n"));
	status = WFFlist_classes_short(WFFglobal.main_form,WFFglobal.workflow);
	display_command = TRUE;
    }
    else if ((strcmp (command, WFF_M_DISPLAY_LIST_OF_STATES)) == 0)
    {
	_NFIdebug ((fname, "Display States Long\n"));
	status = WFFlist_states_long (WFFglobal.main_form, WFFglobal.workflow);
	display_command = TRUE;
    }
    else if ((strcmp (command, WFF_M_DISPLAY_LIST_OF_TRANSITIONS)) == 0)
    {
 	_NFIdebug ((fname, "Display Transitions Long\n"));
	status = WFFlist_transitions_long (WFFglobal.main_form,
			WFFglobal.workflow);
	display_command = TRUE;
    }
    else if ((strcmp (command, WFF_M_DISPLAY_LIST_OF_CLASS_ACCESS)) == 0)
    {
	_NFIdebug ((fname, "Display Class Access Long\n"));
	status = WFFlist_class_access (WFFglobal.main_form,
                                               WFFglobal.workflow);
	display_command = TRUE;
    }
    else if ((strcmp (command, WFF_M_DISPLAY_LIST_OF_COMMANDS)) == 0)
    {
	_NFIdebug ((fname, "Display Commands Long\n"));
	status = WFFlist_commands_long (WFFglobal.main_form,
                                               WFFglobal.workflow, "");
	display_command = TRUE;
    }
    else if ((strcmp (command, WFF_M_ADD_WORKFLOW)) == 0)
    {
 	_NFIdebug ((fname, "Add Workflow\n"));
	status = WFFadd_workflow ();
    }
    else if ((strcmp (command, WFF_M_ADD_COMMANDS)) == 0)
    {
	_NFIdebug ((fname, "Add Commands\n"));
	status = WFFadd_commands ();
    }
    else if ((strcmp (command, WFF_M_DELETE_COMMANDS)) == 0)
    {
	_NFIdebug ((fname, "Delete Commands\n"));
	status = WFFdelete_commands ();
    }
    else if ((strcmp (command, WFF_M_CHANGE_WORKFLOW)) == 0)
    {
	_NFIdebug ((fname, "Change Workflow\n"));
	curr_page = 1;
	status = WFFchange_workflow (WFFglobal.workflow, curr_page);
    }
    else if ((strcmp (command, WFF_M_LOGIN_TO_ENVIRONMENT)) == 0)
    {
	_NFIdebug ((fname, "Login to Environment\n"));
	status = WFFlogin ();
    }
    else if ((strcmp (command, WFF_M_LOGOUT_FROM_ENVIRONMENT)) == 0)
    {
	_NFIdebug ((fname, "Logout from Environment\n"));
	status = WFFlogout ();
    }
    else if ((strcmp (command, WFF_M_DEFINE_SERVER_DEBUG_MODE)) == 0)
    {
 	_NFIdebug ((fname, "Define Server Debug Mode\n"));
 	status = NFIdebug_on_off ();
    }
    else if ((strcmp (command, WFF_M_HELP)) == 0)
    {
	_NFIdebug ((fname, "Help\n"));
	_WFFnotify (MAIN_FORM_LABEL, FI_HELP, (double) 0, WFFglobal.main_form);
	display_command = TRUE;
	status = NFI_S_SUCCESS;
    }
    else if ((strcmp (command, WFF_M_EXIT)) == 0)
    {
	_NFIdebug ((fname, "Exit\n"));
	_WFFnotify (MAIN_FORM_LABEL, FI_CANCEL, (double) 0, NULL);
    }
    else
    {
	/*  For now, until all commands have been implemented  */

	status = NFI_S_SUCCESS;
	_WFFprocess_cleanup (0);
	ERRload_struct (NFI, NFI_I_NO_COMMAND, NULL);
    }

    /*  Display any messages  */

    if (status != NFI_S_SUCCESS)
	_WFFprocess_cleanup (0);

    _WFFmain_message ();

    /*  Save the status  */

    WFFglobal.cmd_status = status;

    /*  Timestamp the first part of the command  */

    if (display_command == TRUE)
    {
	/*  Commit the data into the timestamp file  */

/*
	_WFFts_data (("End of Command      -  %d\n", time ((long *) 0)));
	_WFFts_commit ();
*/
        ;
    }
    else
    {
	/*  End of the first part of the command  */

/*
	_WFFts_data (("User Form Displayed -  %d\n", time ((long *) 0)));
*/
        ;
    }

    _NFIdebug ((fname, " returning ...\n\n"));
    return;
}


void _WFFprocess_cleanup (flag)
int	flag;
{
    int		status;
    int		attr_mask;

    void _WFFnotify ();

    /*  Temporary structure to use to get
     *  the command type out of the current form .
     */

    struct	type_st
    {
	short	type;
    } *t;

    static	char *fname = "_WFFprocess_cleanup";

    _NFIdebug ((fname, "flag = %d\n", flag));

    /*  Determine whether or not to
     *  cleanup any previous forms hanging around.
     */

    if (WFFglobal.current_form != NULL)
    {
	status = FIf_get_user_pointer(WFFglobal.current_form, (char *) &t);
  	if( status != FI_SUCCESS)
        {
	    _NFIdebug ((fname, "FIf_get_user_pointer = <%d>\n", status));
	    t->type = -1;
	}

	_NFIdebug ((fname, "form type = <%d>\n", t->type));

	switch (t->type)
        {
	    case WFF_LOGIN_TYPE:
		_WFFnotify (LOGIN_LABEL,
			FI_CANCEL, (double) 0, WFFglobal.current_form);
		break;


	    case WFF_ERROR_TYPE:
		_WFFnotify (ERROR_FORM_LABEL,
			FI_CANCEL, (double) 0, WFFglobal.current_form);
		break;

  	    case WFF_DEBUG_TYPE:
		_WFFnotify (DEBUG_LABEL,
			FI_CANCEL, (double) 0, WFFglobal.current_form);
		break;

 	    case WFF_RECORD_TYPE:
		_WFFnotify (BEGIN_RECORD_LABEL,
			FI_CANCEL, (double) 0, WFFglobal.current_form);
		break;

	    case WFF_PLAYBACK_TYPE:
		_WFFnotify (BEGIN_PLAYBACK_LABEL,
			FI_CANCEL, (double) 0, WFFglobal.current_form);
		break;

	    case WFF_CONFIRM_TYPE:
		_WFFnotify (CONFIRM_LABEL,
			FI_CANCEL, (double) 0, WFFglobal.current_form);
		break;

	    case WFF_CONFIRM_DELETE_CLASS_TYPE:
		_WFFnotify (CONFIRM_LABEL_DELETE_CLASS,
			FI_CANCEL, (double) 0, WFFglobal.current_form);
		break;

	    case WFF_CONFIRM_DELETE_STATE_TYPE:
		_WFFnotify (CONFIRM_LABEL_DELETE_STATE,
			FI_CANCEL, (double) 0, WFFglobal.current_form);
		break;

 	    case WFF_ADD_WF_TYPE:
		_WFFnotify (ADD_WORKFLOW_LABEL,
			FI_CANCEL, (double) 0, WFFglobal.current_form);
		break;

	    case WFF_CHANGE_WF_TYPE:
		_WFFnotify (CHANGE_WORKFLOW_LABEL,
			FI_CANCEL, (double) 0, WFFglobal.current_form);
		break;

 	    case WFF_ADD_COMMAND_TYPE:
		_WFFnotify (ADD_COMMAND_LABEL,
			FI_CANCEL, (double) 0, WFFglobal.current_form);
		break;

	    case WFF_DELETE_COMMAND_TYPE:
		_WFFnotify (DELETE_COMMAND_LABEL,
			FI_CANCEL, (double) 0, WFFglobal.current_form);
		break;

	    case WFF_LOAD_WF_TYPE:
		_WFFnotify (LOAD_WF_LABEL,
			FI_CANCEL, (double) 0, WFFglobal.current_form);
		break;

	    case WFF_DUMP_WF_TYPE:
		_WFFnotify (DUMP_WF_LABEL,
			FI_CANCEL, (double) 0, WFFglobal.current_form);
		break;

	    default:

	    _NFIdebug ((fname, "unknown type = <%d>\n", t->type));

	    /*  Just call a generic cancel function that
	     *  will delete the form and call WFFset_to_state ()
	     */

	    _WFFnotify (LIST_LABEL, FI_CANCEL, (double) 0, 
			WFFglobal.current_form);
	    break;
	}
    }

    if (WFFglobal.main_form != NULL)
    {
	FIg_get_attr (WFFglobal.main_form, ERROR_BUTTON, &attr_mask);
	if (flag)
        {
	    /*  Find out if the main form is already disabled  */

	    if ((attr_mask & FI_NOT_ENABLED) == 0)
	    {
		/*  Disable the main form  */
		FIg_disable (WFFglobal.main_form, FI_FORM_GROUP);
	    }
        }
	else
	{
	    /*  Find out if the main form is already enabled  */

	    if (attr_mask & FI_NOT_ENABLED)
	    {
		/*  Enable the main form  */
		FIg_enable (WFFglobal.main_form, FI_FORM_GROUP);
	    }
	}
    }

    _NFIdebug ((fname, " returning ...\n"));
    return;
}


void _WFFprocess_event (refresh_event)
int	refresh_event;
{
    int		event;
    
#ifndef XWINDOWS
    Inq_events (&event);
    FI_process_event (refresh_event);
#endif

}
