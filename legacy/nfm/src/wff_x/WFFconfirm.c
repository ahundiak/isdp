#include "machine.h"
#include "WFF.h"
#include "WFFconfirm.h"
#include "WFFlist.h"
#include "NFMschema.h"

/*  Global WFF structure  */

extern struct WFFglobal_st WFFglobal;

long _WFFconfirm
(entity1, entity2, entity3, prompt1, prompt2, listing_type, f1, f2)
  char	*entity1;
  char	*entity2;
  char	*entity3;
  char	*prompt1;
  char	*prompt2;
  int	listing_type;
  void	(*f1) ();       /*  Function to clear listing data  */
  void	(*f2) ();       /*  Function to clear listing data  */
  {
	long	status;

	WFFconfirm_ptr	ptr;

	static	char *fname = "_WFFconfirm";

	/*  Local functions  */

	void _WFFfree_confirm ();

	/*  External functions  */

	void _WFFnotify ();

	_NFIdebug ((fname, "entity1 = <%s>\n", entity1));
	_NFIdebug ((fname, "entity2 = <%s>\n", entity2));
	_NFIdebug ((fname, "entity3 = <%s>\n", entity3));
	_NFIdebug ((fname, "prompt1 = <%s>\n", prompt1));
	_NFIdebug ((fname, "prompt2 = <%s>\n", prompt2));
	_NFIdebug ((fname, "listing_type = <%d>\n", listing_type));

	/*  Initialize the structure  */

	if ((ptr = (WFFconfirm_ptr) malloc
		(sizeof (struct WFFconfirm_st))) == NULL)
	  {
		_NFIdebug ((fname,
			"malloc failed; size = <%d>\n", sizeof (struct WFFconfirm_st)));
		ERRload_struct
			(NFI, NFI_E_MALLOC, "%d", sizeof (struct WFFconfirm_st));
		_NFIdebug ((fname, " returning FAILURE\n"));
		return (NFI_E_MALLOC);
	  }

	ptr->type = WFF_CONFIRM_TYPE;
	ptr->listing_type = listing_type;
	strncpy (ptr->entity1, entity1, sizeof (ptr->entity1) - 1);
	strncpy (ptr->entity2, entity2, sizeof (ptr->entity2) - 1);
	strncpy (ptr->entity3, entity3, sizeof (ptr->entity3) - 1);
	ptr->clear_function[0] = f1;
	ptr->clear_function[1] = f2;

	/*  Load in the Confirm form  */

	if ((status = (long) FIf_new (CONFIRM_LABEL, CONFIRM_FORM,
		_WFFnotify, &(WFFglobal.current_form))) != FI_SUCCESS)
	  {
		_NFIdebug ((fname, "FIf_new = <%d>\n", status));
		_WFFfree_confirm (ptr);
		ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIf_new", status);
		_NFIdebug ((fname, " returning FAILURE\n"));
		return (NFI_E_FORM);
	  }

	/*  Store a pointer to the data in the form  */

	if ((status = (long) FIf_set_user_pointer
		(WFFglobal.current_form, (char *) ptr)) != FI_SUCCESS)
	  {
		_NFIdebug ((fname, "FIf_set_user_pointer = <%d>\n", status));
		_WFFfree_confirm (ptr);
		ERRload_struct
			(NFI, NFI_E_FORM, "%s%d", "FIf_set_user_pointer", status);
		_NFIdebug ((fname, " returning FAILURE\n"));
		return (NFI_E_FORM);
	  }

	/*  Center the form  */

	if ((status = _WFFcenter_form
		(WFFglobal.current_form, -1, Y_FORM_POS)) != NFI_S_SUCCESS)
	  {
		_NFIdebug ((fname, "_WFFcenter_form = <0x%.8x>\n", status));
		_WFFfree_confirm (ptr);
		_NFIdebug ((fname, " returning <0x%.8x>\n", status));
		return (status);
	  }

	/*  Put the command information on the form  */

	if ((status = (long) FIg_set_text
		(WFFglobal.current_form, FIRST_LINE, prompt1)) != FI_SUCCESS)
	  {
		_NFIdebug ((fname, "FIg_set_text = <%d>\n", status));
		_WFFfree_confirm (ptr);
		ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_set_text", status);
		_NFIdebug ((fname, " returning FAILURE\n"));
		return (NFI_E_FORM);
	  }

	if ((status = (long) FIg_set_text
		(WFFglobal.current_form, COMMAND_INFO, prompt2)) != FI_SUCCESS)
	  {
		_NFIdebug ((fname, "FIg_set_text = <%d>\n", status));
		_WFFfree_confirm (ptr);
		ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_set_text", status);
		_NFIdebug ((fname, " returning FAILURE\n"));
		return (NFI_E_FORM);
	  }

	if ((status = _WFFadjust_confirm_form
		(WFFglobal.current_form)) != NFI_S_SUCCESS)
	  {
		_NFIdebug ((fname, "_WFFadjust_confirm_form = <0x%.8x>\n", status));
		_WFFfree_confirm (ptr);
		_NFIdebug ((fname, " returning FAILURE\n"));
		return (status);
	  }

	/*  Display the Confirm form  */

	if ((status = (long) FIf_display (WFFglobal.current_form)) != FI_SUCCESS)
	  {
		_NFIdebug ((fname, "FIf_display = <%d>\n", status));
		_WFFfree_confirm (ptr);
		ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIf_display", status);
		_NFIdebug ((fname, " returning FAILURE\n"));
		return (NFI_E_FORM);
	  }

	_NFIdebug ((fname, " returning SUCCESS\n"));
	return (NFI_S_SUCCESS);
  }


long _WFFconfirm_notify (g_label, value, form)
  int		g_label;
  double	value;
  Form		form;
  {
	long	status = NFI_S_SUCCESS;

	WFFconfirm_ptr	ptr;

	static	char *fname = "_WFFconfirm_notify";

	/*  Local functions  */

	void _WFFfree_confirm ();

	_NFIdebug ((fname, "g_label = <%d>\n", g_label));
	_NFIdebug ((fname, "value = <%d>\n", value));

	/*  Pull out the pointer to the data  */

	if ((status = (long) FIf_get_user_pointer
		(form, (char *) &ptr)) != FI_SUCCESS)
	  {
		_NFIdebug ((fname, "FIf_get_user_pointer = <%d>\n", status));
		ERRload_struct
			(NFI, NFI_E_FORM, "%s%d", "FIf_get_user_pointer", status);
		_NFIdebug ((fname, " returning <0x%.8x>\n", NFI_E_FORM));
		return (NFI_E_FORM);
	  }

	switch (g_label)
	  {
		case FI_CANCEL:
		case CANCEL_BUTTON:

			/*  Clear out the appropriate fields  */
/*
			if (ptr->clear_function[0] != NULL)
				ptr->clear_function[0] ("");
			if (ptr->clear_function[1] != NULL)
				ptr->clear_function[1] ("");
*/
			/*  Load the global error structure  */

			ERRload_struct (NFI, NFI_W_COMMAND_CANCELLED, NULL);

			/*  Set the next state  */

			if ((status = WFFset_to_state ()) != NFI_S_SUCCESS)
				_NFIdebug ((fname, "WFFset_to_state = <0x%.8x>\n", status));

			_WFFfree_confirm (ptr);

			/*  Enable the main form  */

			if (WFFglobal.main_form != NULL)
			  {
				FIg_enable (WFFglobal.main_form, FI_FORM_GROUP);
				_WFFprocess_event (REFRESH_EVENT);
			  }

			break;

		case FI_ACCEPT:
		case OK_BUTTON:

			/*  Put up a message  */

			_WFFmessage (WFFglobal.working_no, NULL);

			/*  Call NFM or WFG to do the command  */

			_NFIdebug ((fname, "calling NFM function ...\n"));

                        /* B.W. changed 5th parameter from "NFM" to "R"
                           because add_report uses "R" for apptype for
                           reports created through NFM and therefore
                           delete_report will need to send "R" for apptype */
                     
			status = WFFglobal.NFMfunction[0] (WFFglobal.user_id,
				ptr->entity1, ptr->entity2, ptr->entity3, "R");
			_NFIdebug ((fname, "NFM function = <0x%.8x>\n", status));
			_NFIdebug(( fname, "Just called NFMfunction with NULL pointer\n" ));
			/*  Erase the message  */

			_WFFerase_message ();

			/*  Save the return status  */

			WFFglobal.cmd_status = status;

			/*  Set the next state  */

			if ((status = WFFset_to_state ()) != NFI_S_SUCCESS)
				_NFIdebug ((fname, "WFFset_to_state = <0x%.8x>\n", status));

			/*  Clear out the appropriate fields  */

			if (ptr->clear_function[0] != NULL)
				ptr->clear_function[0] ("");
			if (ptr->clear_function[1] != NULL)
				ptr->clear_function[1] ("");

			/*  Blank out the listing on the main form  */

			if (ptr->listing_type != -1)
				_WFFmain_blank_listing (ptr->listing_type);

			_WFFfree_confirm (ptr);

			/*  Enable the main form  */

			if (WFFglobal.main_form != NULL)
			  {
				FIg_enable (WFFglobal.main_form, FI_FORM_GROUP);
				_WFFprocess_event (REFRESH_EVENT);
			  }

			break;
	  }

	_NFIdebug ((fname, " returning <0x%.8x>\n", status));
	return (status);
  }


void _WFFfree_confirm (ptr)
  WFFconfirm_ptr	ptr;
  {
	if (WFFglobal.current_form != NULL)
	  {
		FIf_delete (WFFglobal.current_form);
		WFFglobal.current_form = NULL;
	  }

	if (ptr) free (ptr);
	return;
  }


long _WFFconfirm_delete_class( form, g_label, ptr )
    Form	form;
    int 	g_label;
    WFFadd_ptr  ptr;
{
    long	status;
    int		i;
    int		rows;
    int		sel_flag;
    char 	class_name[NFM_CLASSNAME+1];
    char 	prompt[120];
    Form        fptr;

    static	char *fname = "_WFFconfirm_delete_class";

    void _WFFfree_confirm_delete_class ();
    void _WFFnotify ();

    /*  Set confirm status to FALSE */

    WFFglobal.confirmed = FALSE;

    /*  Get the selected classes to delete */

    _NFIdebug(( fname, "%s\n", "Get number of class rows " ));
    status = (long) FIfld_get_num_rows( form, g_label, &rows );
    if (status != FI_SUCCESS)
    {
         _NFIdebug ((fname, "FIfld_get_num_rows = <%d>\n", status));
         ERRload_struct (NFI, NFI_E_FORM, "%s%d","FIfld_get_num_rows", status);
         _NFIdebug ((fname, " returning FAILURE\n"));
         return (NFI_E_FORM);
    } 

    if (ptr->num_classes == 0)
    {
         FIfld_set_num_rows (form, g_label, 0); 
         _WFFmessage (NFI_W_NO_CLASSES_SELECTED, NULL);
         _NFIdebug ((fname, "No rows exist in the CLASS_LIST_SCF\n"));
         return (NFI_S_SUCCESS);
    } 

    if (rows == 0)
    {
         _WFFmessage (NFI_W_NO_CLASSES_SELECTED, NULL);
         _NFIdebug ((fname, "No rows exist in the CLASS_LIST_SCF\n"));
         return (NFI_S_SUCCESS);
    } 

    for( i = 0; i < rows; ++i )
    {
	/*  See if this class is selected for deletion */

	status = (long) FIfld_get_select( form, g_label, i, 0, &sel_flag);
        if (status != FI_SUCCESS)
        {
             _NFIdebug ((fname, "FIfld_get_select = <%d>\n", status));
             ERRload_struct (NFI, NFI_E_FORM, "%s%d",
                             "FIfld_get_select", status);
             _NFIdebug ((fname, " returning FAILURE\n"));
             return (NFI_E_FORM);
        } 

	if( sel_flag )
	{
	    /*  Get the class name from the field */

	    status = _WFFget_data_from_field( form, g_label, i, 0,
			class_name, NFM_CLASSNAME );
	    if (status != NFI_S_SUCCESS)
	    {
	        _NFIdebug ((fname, "WFFget_data_from_field  <0x%.8x>\n", 
				status));
	        _NFIdebug ((fname, " returning FAILURE\n"));
	        return (status);
	    }	    
	    break;
	} /* end if( sel_flag ) */

    } /* end for( i=0; i<rows; ++i ) */

    if (!sel_flag)
    {
         _WFFmessage (NFI_W_NO_CLASSES_SELECTED, NULL);
         _NFIdebug ((fname, "No classes were selected\n"));
         return (NFI_S_SUCCESS);
    }

    status = (long) UMSGetByNum( prompt, NFI_P_CONFIRM_CLASS,"%s",class_name);
    if( status != UMS_S_SUCCESS)
    {
        _NFIdebug ((fname, "UMSGetByNum = <%d>\n", status));
        _NFIdebug ((fname, "defaulting prompt ...\n"));
        sprintf (prompt, "Class \"%s\" ?", class_name );
    }
    _NFIdebug ((fname, "prompt = <%s>\n", prompt));

    /*  Load in the Confirm form  */

    status = (long) FIf_new (CONFIRM_LABEL_DELETE_CLASS,
			     CONFIRM_FORM_DELETE_CLASS, _WFFnotify, &(fptr));
    _NFIdebug ((fname, "FIf_new = <%d>\n", status));
    if( status != FI_SUCCESS )
    {
	_WFFfree_confirm_delete_class (fptr);
	ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIf_new", status);
	_NFIdebug ((fname, " returning FAILURE\n"));
	return (NFI_E_FORM);
    }

    /*  Center the form  */

    status = _WFFcenter_form(fptr, -1, Y_FORM_POS);
    _NFIdebug ((fname, "_WFFcenter_form = <0x%.8x>\n", status));
    if( status != NFI_S_SUCCESS)
    {
	_WFFfree_confirm_delete_class (fptr);
	_NFIdebug ((fname, " returning <0x%.8x>\n", status));
	return (status);
    }

    status = (long) FIg_set_text(fptr, COMMAND_INFO_DELETE_CLASS, prompt);
    _NFIdebug ((fname, "FIg_set_text = <%d>\n", status));
    if( status != FI_SUCCESS )
    {
/* Argument 'fptr' is passed to _WFFfree_confirm_delete_class 
   HP PORT IGI 5th Sep 94 */ 

	_WFFfree_confirm_delete_class(fptr);
	ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_set_text", 
			status);
	_NFIdebug ((fname, " returning FAILURE\n"));
	return (NFI_E_FORM);
    }

    status = _WFFadjust_confirm_form(fptr);
    _NFIdebug ((fname, "_WFFadjust_confirm_form = <0x%.8x>\n", 
			status));
    if( status != NFI_S_SUCCESS)
    {
	_WFFfree_confirm_delete_class (fptr);
	_NFIdebug ((fname, " returning FAILURE\n"));	
	return (status);
    }

    /*  Display the Confirm form  */

    status = (long) FIf_display (fptr);
    _NFIdebug ((fname, "FIf_display = <%d>\n", status));
    if( status  != FI_SUCCESS)
    {
	_WFFfree_confirm_delete_class (fptr);
	ERRload_struct(NFI, NFI_E_FORM, "%s%d", "FIf_display", status);
	_NFIdebug ((fname, " returning FAILURE\n"));
	return (NFI_E_FORM);
    }

    _NFIdebug ((fname, " returning SUCCESS\n"));

    return (NFI_S_SUCCESS);
  }


long _WFFconfirm_delete_class_notify (g_label, value, form)
  int		g_label;
  double	value;
  Form		form;
  {
    long	status = NFI_S_SUCCESS;

    static	char *fname = "_WFFconfirm_delete_class_notify";

    void _WFFfree_confirm_delete_class ();

    _NFIdebug ((fname, "g_label = <%d>\n", g_label));
    _NFIdebug ((fname, "value = <%d>\n", value));

    switch (g_label)
    {
	case FI_CANCEL:
	case CANCEL_BUTTON_DELETE_CLASS:

 	    _NFIdebug(( fname, "Command NOT Confirmed\n" ));

 	    /*  Load the global accept/reject value */

	    WFFglobal.confirmed = FALSE;
        break;

        case FI_ACCEPT:
	case OK_BUTTON_DELETE_CLASS:

  	    _NFIdebug(( fname, "Command IS Confirmed\n" ));

  	    /*  Load the global accept/reject value */

  	    WFFglobal.confirmed = TRUE;
        break;
    }

    _WFFfree_confirm_delete_class (form);

    _NFIdebug ((fname, " returning <0x%.8x>\n", status));
    return (status);
}


void _WFFfree_confirm_delete_class (fptr)
Form  fptr;
  {
    static char *fname = "_WFFfree_confirm_delete_class";

    _NFIdebug(( fname, "Freeing confirm form\n" ));

    if (fptr != NULL)
	FIf_delete (fptr);

    return;
  }


long _WFFconfirm_delete_state( form, g_label, ptr )
Form	    form;
int	    g_label;
WFFadd_ptr  ptr;
{
    int		sel_flag;
    int		i;
    int		rows;
    long	status;
    char	state_name[ NFM_STATENAME+1];
    char 	prompt[120];
    Form        fptr;

    static	char *fname = "_WFFconfirm_delete_state";

    void _WFFfree_confirm_delete_state ();
    void _WFFnotify ();

    /*  Set confirm status to FALSE */

    WFFglobal.confirmed = FALSE;

    /*  Get the selected state to delete */

    _NFIdebug(( fname, "%s\n", "Get number of state rows " ));
    status = (long) FIfld_get_num_rows( form, g_label, &rows );
    if (status != FI_SUCCESS)
    {
         _NFIdebug ((fname, "FIfld_get_num_rows = <%d>\n", status));
         ERRload_struct (NFI, NFI_E_FORM, "%s%d","FIfld_get_num_rows", status);
         _NFIdebug ((fname, " returning FAILURE\n"));
         return (NFI_E_FORM);
    } 

    if (ptr->num_states == 0)
    {
         FIfld_set_num_rows (form, g_label, 0); 
         _WFFmessage (NFI_W_NO_STATES_SELECTED, NULL);
         _NFIdebug ((fname, "No rows exist in the STATE_LIST_MCF\n"));
         return (NFI_S_SUCCESS);
    } 

    if (rows == 0)
    {
         _WFFmessage (NFI_W_NO_STATES_SELECTED, NULL);
         _NFIdebug ((fname, "No rows exist in the STATE_LIST_MCF\n"));
         return (NFI_S_SUCCESS);
    } 

    for( i = 0; i < rows; ++i )
    {
	/*  See if this state is selected for deletion */

	status = (long) FIfld_get_select( form, g_label, i, 0, &sel_flag);
        if (status != FI_SUCCESS)
        {
             _NFIdebug ((fname, "FIfld_get_select = <%d>\n", status));
             ERRload_struct (NFI, NFI_E_FORM, "%s%d",
                             "FIfld_get_select", status);
             _NFIdebug ((fname, " returning FAILURE\n"));
             return (NFI_E_FORM);
        } 

	if( sel_flag )
	{
	    /*  Get the state name from the field */

	    status = _WFFget_data_from_field( form, g_label, i, 0,
			state_name, NFM_STATENAME );
	    if (status != NFI_S_SUCCESS)
	    {
	        _NFIdebug ((fname, "WFFget_data_from_field  <0x%.8x>\n", 
				status));
	        _NFIdebug ((fname, " returning FAILURE\n"));
	        return (status);
	    }	    
	    break;
	} /* end if( sel_flag ) */

    } /* end for( i=0; i<rows; ++i ) */

    if (!sel_flag)
    {
         _WFFmessage (NFI_W_NO_STATES_SELECTED, NULL);
         _NFIdebug ((fname, "No states were selected\n"));
         return (NFI_S_SUCCESS);
    }

    status = (long) UMSGetByNum( prompt, NFI_P_CONFIRM_STATE,"%s",state_name);
    if( status != UMS_S_SUCCESS)
    {
        _NFIdebug ((fname, "UMSGetByNum = <%d>\n", status));
        _NFIdebug ((fname, "defaulting prompt ...\n"));
        sprintf (prompt, "State \"%s\" ?", state_name );
    }
    _NFIdebug ((fname, "prompt = <%s>\n", prompt));

    /*  Load in the Confirm form  */

    status = (long) FIf_new (CONFIRM_LABEL_DELETE_STATE,
			     CONFIRM_FORM_DELETE_STATE, _WFFnotify, &(fptr));
    _NFIdebug ((fname, "FIf_new = <%d>\n", status));
    if( status != FI_SUCCESS )
    {
	_WFFfree_confirm_delete_state (fptr);
	ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIf_new", status);
	_NFIdebug ((fname, " returning FAILURE\n"));
	return (NFI_E_FORM);
    }

    /*  Center the form  */

    status = _WFFcenter_form(fptr, -1, Y_FORM_POS);
    _NFIdebug ((fname, "_WFFcenter_form = <0x%.8x>\n", status));
    if( status != NFI_S_SUCCESS)
    {
	_WFFfree_confirm_delete_state (fptr);
	_NFIdebug ((fname, " returning <0x%.8x>\n", status));
	return (status);
    }

    status = (long) FIg_set_text(fptr, COMMAND_INFO_DELETE_STATE, prompt);
    _NFIdebug ((fname, "FIg_set_text = <%d>\n", status));
    if( status != FI_SUCCESS )
    {
/* Argument 'fptr' is passed to _WFFfree_confirm_delete_state
   HP PORT IGI 5th Sep 94 */ 

	_WFFfree_confirm_delete_state(fptr);
	ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_set_text", 
			status);
	_NFIdebug ((fname, " returning FAILURE\n"));
	return (NFI_E_FORM);
    }

    status = _WFFadjust_confirm_form(fptr);
    _NFIdebug ((fname, "_WFFadjust_confirm_form = <0x%.8x>\n", 
			status));
    if( status != NFI_S_SUCCESS)
    {
	_WFFfree_confirm_delete_state (fptr);
	_NFIdebug ((fname, " returning FAILURE\n"));	
	return (status);
    }

    /*  Display the Confirm form  */

    status = (long) FIf_display (fptr);
    _NFIdebug ((fname, "FIf_display = <%d>\n", status));
    if( status  != FI_SUCCESS)
    {
	_WFFfree_confirm_delete_state (fptr);
	ERRload_struct(NFI, NFI_E_FORM, "%s%d", "FIf_display", status);
	_NFIdebug ((fname, " returning FAILURE\n"));
	return (NFI_E_FORM);
    }

    _NFIdebug ((fname, " returning SUCCESS\n"));

    return (NFI_S_SUCCESS);
  }


long _WFFconfirm_delete_state_notify (g_label, value, form)
  int		g_label;
  double	value;
  Form		form;
  {
    long	status = NFI_S_SUCCESS;

    static	char *fname = "_WFFconfirm_delete_state_notify";

    void _WFFfree_confirm_delete_state ();

    _NFIdebug ((fname, "g_label = <%d>\n", g_label));
    _NFIdebug ((fname, "value = <%d>\n", value));

    switch (g_label)
    {
	case FI_CANCEL:
	case CANCEL_BUTTON_DELETE_STATE:

 	    _NFIdebug(( fname, "Command NOT Confirmed\n" ));

 	    /*  Load the global accept/reject value */

	    WFFglobal.confirmed = FALSE;
        break;

        case FI_ACCEPT:
	case OK_BUTTON_DELETE_STATE:

  	    _NFIdebug(( fname, "Command IS Confirmed\n" ));

  	    /*  Load the global accept/reject value */

  	    WFFglobal.confirmed = TRUE;
        break;
    }

    _WFFfree_confirm_delete_state (form);

    _NFIdebug ((fname, " returning <0x%.8x>\n", status));
    return (status);
}


void _WFFfree_confirm_delete_state (fptr)
Form  fptr;
  {
    static char *fname = "_WFFfree_confirm_delete_state";

    _NFIdebug(( fname, "Freeing confirm form\n" ));

    if (fptr != NULL)
	FIf_delete (fptr);

    return;
  }
