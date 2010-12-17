#include "machine.h"
#include "WFF.h"
#include "WFFpage2.h"
#include "WFFconfirm.h"
#include "WFFtimestamp.h"

/*  Global WFF structure  */

extern struct WFFglobal_st WFFglobal;

void _WFFnotify (f_label, g_label, value, form)
  int		f_label;
  int		g_label;
  double	value;
  Form		form;
  {
        int	curr_page;
	long	status = NFI_S_SUCCESS;
	short	which_form = WFF_CURRENT_FORM;
	short	end_of_command = FALSE;

	static	char *fname = "_WFFnotify";

	/*  External functions  */

	void ERRreset_struct ();

	long _WFFmain_notify ();
	long _WFFmain_error_notify ();
	long _WFFconfirm_notify ();
	long _WFFconfirm_delete_class_notify ();
	long _WFFconfirm_delete_state_notify ();
	long _NFIdebug_notify ();
	long _WFFpopup_list_notify ();
/*
	long _WFFbegin_recording_notify ();
	long _WFFbegin_playback_notify ();
*/
	long _WFFload_wf_notify ();
	long _WFFlogin_notify ();
	long _WFFenv_popup_notify ();
	long _WFFlist_notify ();

	ERRreset_struct ();

	/*  Timestamp the end of the user's input  */

	if ((g_label == FI_ACCEPT) || (g_label == FI_CANCEL) ||
		(g_label == CANCEL_BUTTON) || (g_label == OK_BUTTON))
	  {
/*
		_WFFts_data (("User Input Finished - %d\n", time ((long *) 0)));
*/
		end_of_command = TRUE;
	  }
	else if ((g_label == LEFT_SCROLL_BUTTON) ||
		(g_label == RIGHT_SCROLL_BUTTON))
	  {
		_NFIdebug ((fname, "Message is scrolling\n"));
		_WFFscroll_message (form, g_label);
		_NFIdebug ((fname, " returning ...\n\n"));
		return;
	  }

	_NFIdebug ((fname, "f_label = <%d>\n", f_label));

	/*  Set a flag to tell which form error messages will go on -

	    NOTE:  this is to make sure that when the current form is
	           deleted and the WFFglobal.current_form pointer is set
	           to NULL that this function does not try to put an error
	           message on it.  This could also be accomplished by passing
	           the address of the form pointer to each of the notification
	           routines, however, the editing changes make that prohibitive
	           at this time.
	*/

	if (form == WFFglobal.main_form)
		which_form = WFF_MAIN_FORM;

	switch (f_label)
	  {
		case MAIN_FORM_LABEL:
			status = _WFFmain_notify (g_label, value, form);
			break;

		case ERROR_FORM_LABEL:
			status = _WFFmain_error_notify (g_label, value, form);
			break;

		case CONFIRM_LABEL:
			status = _WFFconfirm_notify (g_label, value, form);
			break;

		case CONFIRM_LABEL_DELETE_CLASS:
			status = _WFFconfirm_delete_class_notify (g_label, 
					value, form);
			_NFIdebug(( fname, "Confirm status <%d>\n", 
				    WFFglobal.confirmed ));
			if( WFFglobal.confirmed )
			{
			    status = _WFFdelete_class_express( CLASS_LIST_SCF,
					 WFFglobal.current_form );
			    curr_page = 2;
 			    status = WFFchange_workflow( WFFglobal.workflow,
						     curr_page );
			}
			break;

		case CONFIRM_LABEL_DELETE_STATE:
			status = _WFFconfirm_delete_state_notify (g_label, 
					value, form);
			_NFIdebug(( fname, "Confirm status <%d>\n", 
				    WFFglobal.confirmed ));
			if( WFFglobal.confirmed )
			{
			    status = _WFFdelete_state_express( STATE_LIST_MCF,
					 WFFglobal.current_form );
			    curr_page = 2;
 			    status = WFFchange_workflow( WFFglobal.workflow,
						     curr_page );
			}
			break;

		case DEBUG_LABEL:
			status = _NFIdebug_notify (g_label, value, form);
			break;

		case POPUP_LABEL:
			status = _WFFpopup_list_notify (g_label, value, form);
			break;
/*

		case BEGIN_RECORD_LABEL:
			status = _WFFbegin_recording_notify (g_label, value, form);
			break;

		case BEGIN_PLAYBACK_LABEL:
			status = _WFFbegin_playback_notify (g_label, value, form);
			break;
*/

		case LOAD_WF_LABEL:
			status = _WFFload_wf_notify (g_label, value, form);
			break;

		case LOGIN_LABEL:
			status = _WFFlogin_notify (g_label, value, form);
			break;

		case ENV_POPUP_LABEL:
			status = _WFFenv_popup_notify (g_label, value, form);
			break;

		case LIST_LABEL:  /* CHANGE THIS */
			status = _WFFpopup_list_notify (g_label, value, form);
			break;

		case ADD_WORKFLOW_LABEL: 
			status = _WFFpage1_notify (g_label, value, form);
			break;

		case CHANGE_WORKFLOW_LABEL: 
			status = _WFFpage1_notify (g_label, value, form);
			break;

		case PAGE1_LABEL: 
			status = _WFFpage1_notify (g_label, value, form);
			break;

		case PAGE2_LABEL: 
			status = _WFFpage2_notify (g_label, value, form);
			break;

		case PAGE3_LABEL: 
			status = _WFFpage3_notify (g_label, value, form);
			break;

		case PAGE4_LABEL: 
			status = _WFFpage4_notify (g_label, value, form);
			break;

		case ADD_COMMAND_LABEL: 
			status = _WFFadd_commands_notify (g_label, value, form);
			break;

		case DELETE_COMMAND_LABEL: 
			status = _WFFdelete_commands_notify (g_label, value, form);
			break;

		case DUMP_WF_LABEL:
			status = _WFFdump_wf_notify (g_label, value, form);
			break;

		default:
			break;
	  }

	/*  Display any messages  */

	_NFIdebug(( fname, "Command Notify Status <0x%.8x>\n", status ));

	if (status != NFI_S_SUCCESS)
	  {
		/*  Make sure the form has not been deleted  */

		if (which_form == WFF_CURRENT_FORM)
		  {
			if (WFFglobal.current_form == NULL)
				_WFFerror_message (WFFglobal.main_form);
			else
				_WFFerror_message (WFFglobal.current_form);

			/*  Reset the global error structure  */

			ERRreset_struct ();
		  }
		else
		  {
			/*  Put the message on the main form  */

			_WFFerror_message (WFFglobal.main_form);
		  }

		if (end_of_command == TRUE)
		  {
			/*  Timestamp at the end of the command  */

/*
			_WFFts_data (("End of Command      -  %d\n",
				time ((long *) 0)));

			/ *  Commit the data to the timestamp file  * /

			_WFFts_commit ();
*/
                      ;
		  }
	  }
	else if (end_of_command == TRUE)
	  {
		/*  Put every final message on the main form  */

		_WFFerror_message (WFFglobal.main_form);

		/*  Timestamp at the end of the command  */

/*
		_WFFts_data (("End of Command      -  %d\n", time ((long *) 0)));

		/ *  Commit the data to the timestamp file  * /

		_WFFts_commit ();
*/
	  }

	_NFIdebug ((fname, " returning ...\n\n"));
	return;
  }
