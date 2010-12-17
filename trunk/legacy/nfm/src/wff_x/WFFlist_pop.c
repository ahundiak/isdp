#include "machine.h"
#include "WFF.h"
#include "WFFpersist.h"
#include "WFFlist.h"
#include "WFFpopup.h"

/*  Global WFF structure  */

extern struct WFFglobal_st WFFglobal;

long _WFFlist_load_popup (name, buffer)
  char		*name;   /*  i - name of attribute  */
  MEMptr	buffer;  /*  i - data_list          */
  {
	int	i, row;
	int	fields;
	long	status;
	char	**data_ptr;
	short	offset;

	int	label = POPUP_FIELD;

	static	char *fname = "_WFFlist_load_popup";

	/*  External functions  */

	void _WFFnotify ();

	_NFIdebug ((fname, "name = <%s>\n", name));

	/*  Disable the main form  */

	FIg_disable (WFFglobal.main_form, FI_FORM_GROUP);

	/*  Load in the form  */

	if ((status = (long) FIf_new (POPUP_LABEL,
		POPUP_WF_FORM, _WFFnotify, &(WFFglobal.current_form))) != FI_SUCCESS)
	  {
		_NFIdebug ((fname, "FIf_new = <%d>\n", status));
		WFFglobal.error_no = NFI_E_FORM;
		ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIf_new", status);
		_NFIdebug ((fname, " returning FAILURE\n"));
		return (NFI_E_FORM);
	  }

	if ((status = _WFFfind_column_offset
		(buffer, name, &offset)) != NFI_S_SUCCESS)
	  {
		_NFIdebug ((fname, "_WFFfind_column_offset = <0x%.8x>\n", status));
		_NFIdebug ((fname, " returning FAILURE\n"));
		return (status);
	  }

	/*  Set the number of rows in the popup list  */

	if ((status = (long) FIfld_set_num_rows
		(WFFglobal.current_form, label, 0, buffer->rows)) != FI_SUCCESS)
	  {
		_NFIdebug ((fname, "FIfld_set_num_rows = <%d>\n", status));
		ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_num_rows", status);
		_NFIdebug ((fname, " returning FAILURE\n"));
		return (NFI_E_FORM);
	  }

	row = 0;
	data_ptr = (char **) buffer->data_ptr;
	fields = buffer->rows * buffer->columns;
/* IGI Intel Solaris Port - CN 31/5/95 */
#if defined(OS_SCO_UNIX) || defined(OS_INTELSOL)
        /* To set font for SCO - CRN 25 Feb 94 */
        FIg_set_font( WFFglobal.current_form, label, "7x13bold", 15);
#endif
	for (i = offset; i < fields; i += buffer->columns, ++row)
	  {
		/*  Put the data into the popup list  */

		_NFIdebug ((fname, "Setting <%s>\n", data_ptr[i]));
		_NFIdebug ((fname, " in row %d, col %d\n", row, 0));
		FIfld_set_text
			(WFFglobal.current_form, label, row, 0, data_ptr[i], FALSE);
	  }

	/*  Center the form  */

	if ((status = _WFFcenter_form
		(WFFglobal.current_form, -1, 288)) != NFI_S_SUCCESS)
	  {
		_NFIdebug ((fname, "_WFFcenter_form = <0x%.8x>\n", status));
		_NFIdebug ((fname, " returning %d\n", status));
		return (status);
	  }

	/*  Clear out the error message strip  */

	_WFFclear_msg (WFFglobal.current_form);

	/*  Display the form  */

	if ((status = (long) FIf_display (WFFglobal.current_form)) != FI_SUCCESS)
	  {
		_NFIdebug ((fname, "FIf_display = <%d>\n", status));
		ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIf_display", status);
		_NFIdebug ((fname, " returning FAILURE\n"));
		return (NFI_E_FORM);
	  }

	_NFIdebug ((fname, " returning SUCCESS\n"));
	return (NFI_S_SUCCESS);
  }


long _WFFpopup_list_notify (g_label, value, form)
  int		g_label;
  double	value;
  Form		form;
  {
	long	status = NFI_S_SUCCESS;
	/* char	command[15]; */
	MEMptr  buffer = NULL;

	static	char *fname = "_WFFpopup_list_notify";

	/*  Local functions  */

	long	_WFFpopup_list_field ();
	void	_WFFpopup_main_button ();

	_NFIdebug ((fname, "g_label = %d\n", g_label));

	/*  Clear out the error message strip  */

	_WFFclear_msg (form);

	switch (g_label)
	  {
		case FI_HELP:
/*
			if (status = _WFFhelp_topic (command))
			  {
				_NFIdebug ((fname, "_WFFhelp_topic = <%d>\n", 
					 status));
				ERRload_struct (NFI, NFI_E_HELP, "%s%d",
					 "_WFFhelp_topic", status);
				status = NFI_E_HELP;
			  }
*/
			ERRload_struct (NFI, NFI_I_HELP, NULL);
			status = NFI_I_HELP;

			break;

		case FI_CANCEL:

			/*  Load the global error structure  */

			ERRload_struct (NFI, NFI_W_COMMAND_CANCELLED, NULL);
			status = MEMopen (&buffer, 512);

			/*  Set the next state  */

			if ((status = WFFset_to_state ()) != NFI_S_SUCCESS)
				_NFIdebug ((fname, "WFFset_to_state = <0x%.8x>\n", status));

			/*  Enable the main form  */

			if (WFFglobal.main_form != NULL)
			  {
				FIg_enable (WFFglobal.main_form, FI_FORM_GROUP);
			  }

			/*  Pop the appropriate button back up  */

			_WFFpopup_main_button (WFFglobal.main_form);

			/*  Delete the form  */

			if (form != NULL)
			    FIf_delete (form);
			WFFglobal.current_form = NULL;

			MEMclose (&buffer);

			break;

		case POPUP_FIELD:

			if (value < 0.0)
			  {
				_NFIdebug ((fname, "rows or columns are scrolling\n"));
				break;
			  }

			if ((status = _WFFpopup_list_field
				(form, g_label, (int) value)) != NFI_S_SUCCESS)
			  {
				_NFIdebug ((fname, "_WFFpopup_list_field = <0x%.8x>\n", status));
				break;
			  }

			/*  Set the next state  */
/*
			if ((status = WFFset_to_state ()) != NFI_S_SUCCESS)
				_NFIdebug ((fname, "WFFset_to_state = <0x%.8x>\n", status));
*/
			/*  Delete the form  */
			if (form != NULL)
  			    FIf_delete (form);
			WFFglobal.current_form = NULL;

			/*  Enable the main form  */

			if (WFFglobal.main_form != NULL)
			  {
				FIg_enable (WFFglobal.main_form, FI_FORM_GROUP);
				_WFFprocess_event (REFRESH_EVENT);
			  }

			/*  Pop the appropriate button back up  */

			_WFFpopup_main_button (WFFglobal.main_form);

			break;
	  }

	_NFIdebug ((fname, " returning <0x%.8x>\n", status));
	return (status);
  }


long _WFFpopup_list_field (form, label, row)
  Form	form;
  int	label;
  int	row;
  {
	int		status;
	int		length;
	int		selected;
	int		pos;
	char	        *text;

	static	char *fname = "_WFFpopup_list_field";

	_NFIdebug ((fname, "row = %d\n", row));

	/*  Find the length of the text  */

	if ((status = FIfld_get_text_length
		(form, label, row, 0, &length)) != FI_SUCCESS)
	  {
		_NFIdebug ((fname, "FIfld_get_text_length = <%d>\n", status));
		ERRload_struct
			(NFI, NFI_E_FORM, "%s%d", "FIfld_get_text_length", status);
		_NFIdebug ((fname, " returning FAILURE\n"));
		return (NFI_E_FORM);
	  }

	if ((text = (char *) malloc (length+1)) == NULL)
	  {
		_NFIdebug ((fname, "malloc failed; size = <%d>\n", length));
		ERRload_struct (NFI, NFI_E_MALLOC, "%d", length);
		_NFIdebug ((fname, " returning FAILURE\n"));
		return (NFI_E_MALLOC);
	  }

	if ((status = FIfld_get_text
		(form, label, row, 0, length, text, &selected, &pos)) != FI_SUCCESS)
	  {
		_NFIdebug ((fname, "FIfld_get_text = <%d>\n", status));
		ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_get_text", status);
		_NFIdebug ((fname, " returning FAILURE\n"));
		return (NFI_E_FORM);
	  }

	/*  Put the selected text in the appropriate field  */

	if ((status = (long) _WFFmain_set_field
		(text, WFF_POPUP_LIST)) != NFI_S_SUCCESS)
	  {
		_NFIdebug ((fname, "_WFFmain_set_field = <0x%.8x>\n", status));
		_NFIdebug ((fname, " returning FAILURE\n"));
		return (status);
	  }

	if (text) free (text);

	_NFIdebug ((fname, " returning SUCCESS\n"));
	return (NFI_S_SUCCESS);
  }


void _WFFpopup_main_button (form)
  Form	form;
  {
	int		label;

	static	char *fname = "_WFFpopup_main_button";

	switch (WFFglobal.current_popup)
	  {
		case WFF_LIST_WORKFLOWS:
			label = WORKFLOW_BUTTON;
			break;

		default:
			_NFIdebug ((fname,
				"unknown list type <%d>\n", WFFglobal.current_popup));
			_NFIdebug ((fname, " returning ...\n"));
			return;
	  }

	FIg_set_state_off (form, label);

	_NFIdebug ((fname, " returning ...\n"));
	return;
  }
