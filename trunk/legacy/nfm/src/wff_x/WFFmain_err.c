#include "machine.h"
#include "WFF.h"
#include "WFFpersist.h"
#include "WFFmain_err.h"

/*  Global I/NFM error structure  */

extern struct _ERRstruct _ERRstruct;

/*  NFM message structures  */
/*
extern MSGptr NFMRmsg_ptr;
*/
/*
extern MSGptr NFMmsg_ptr;
extern MSGptr SQLmsg_ptr;
extern MSGptr DBmsg_ptr;
extern MSGptr NETmsg_ptr;
extern MSGptr MEMmsg_ptr;
*/

/*  Global WFF structure  */

extern struct WFFglobal_st WFFglobal;

void _WFFmain_error_button ()
  {
	int		num_chars;
	int		attr_mask;
	long	status;
	char	hex_number[20];
	char	message[256];

	static	char *fname = "_NFMmain_error_button";

	/*  External functions  */

	void _WFFnotify ();

	/*  Temporary structure to use to set
	    the command type in the current form  */

	struct	temp_structure_st
	  {
		short	type;
	  } temp_structure;

	_NFIdebug ((fname, "entering ...\n"));

	/*  Disable the main form  */

	if ((status = (long) FIg_disable
		(WFFglobal.main_form, FI_FORM_GROUP)) != FI_SUCCESS)
	  {
		_NFIdebug ((fname, "FIg_disable = <%d>\n", status));
		ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_disable", status);
		return;
	  }

	/*  Load in the form  */

	if ((status = (long) FIf_new (ERROR_FORM_LABEL, ERROR_FORM,
		_WFFnotify, &(WFFglobal.current_form))) != FI_SUCCESS)
	  {
		_NFIdebug ((fname, "FIf_new = <%d>\n", status));
		FIg_enable (WFFglobal.main_form, FI_FORM_GROUP);
		_WFFprocess_event (REFRESH_EVENT);
		ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIf_new", status);
		return;
	  }

	/*  Store the form type in the form  */

	temp_structure.type = WFF_ERROR_TYPE;

	if ((status = (long) FIf_set_user_pointer
		(WFFglobal.current_form, (char *) &temp_structure)) != FI_SUCCESS)
	  {
		_NFIdebug ((fname, "FIf_set_user_pointer = <%d>\n", status));
	        if (WFFglobal.current_form != NULL)
	 	    FIf_delete (WFFglobal.current_form);
		WFFglobal.current_form = NULL;
		FIg_enable (WFFglobal.main_form, FI_FORM_GROUP);
		_WFFprocess_event (REFRESH_EVENT);
		ERRload_struct
			(NFI, NFI_E_FORM, "%s%d", "FIf_set_user_pointer", status);
		return;
	  }

	/*  Find the length and attribute mask of the message fields  */

	if ((status = (long) FIfld_get_num_vis_chars
		(WFFglobal.current_form, NFMR_MESSAGE, 0, &num_chars)) != FI_SUCCESS)
	  {
		_NFIdebug ((fname, "FIfld_get_num_vis_chars = <%d>\n", status));
                if (WFFglobal.current_form != NULL)
                    FIf_delete (WFFglobal.current_form);
		WFFglobal.current_form = NULL;
		FIg_enable (WFFglobal.main_form, FI_FORM_GROUP);
		_WFFprocess_event (REFRESH_EVENT);
		ERRload_struct
			(NFI, NFI_E_FORM, "%s%d", "FIfld_get_num_vis_chars", status);
		return;
	  }

	if ((status = (long) FIfld_get_attr
		(WFFglobal.current_form, NFMR_MESSAGE, 0, &attr_mask)) != FI_SUCCESS)
	  {
		_NFIdebug ((fname, "FIfld_get_attr = <%d>\n", status));
                if (WFFglobal.current_form != NULL)
                    FIf_delete (WFFglobal.current_form);
		WFFglobal.current_form = NULL;
		FIg_enable (WFFglobal.main_form, FI_FORM_GROUP);
		_WFFprocess_event (REFRESH_EVENT);
		ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_get_attr", status);
		return;
	  }

	/*  Load the forms interface status and message  */

	sprintf (hex_number, "0x%.8x", _ERRstruct.NFIstatus);
	if ((status = (long) FIfld_set_text (WFFglobal.current_form,
		NFF_STATUS, 0, 0, hex_number, FALSE)) != FI_SUCCESS)
	  {
		_NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
                if (WFFglobal.current_form != NULL)
                    FIf_delete (WFFglobal.current_form);
		WFFglobal.current_form = NULL;
		FIg_enable (WFFglobal.main_form, FI_FORM_GROUP);
		_WFFprocess_event (REFRESH_EVENT);
		ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_value", status);
		return;
	  }

	/*  Retrieve the error message  */

	ERRget_specific_message (NFI, message);

	/*  Display the horizontal scroll bars if the message is too long  */

	if (num_chars < strlen (message))
	  {
		if ((status = FIfld_set_attr (WFFglobal.current_form,
			NFF_MESSAGE, 0, attr_mask | FI_DISPLAY_HSCROLL)) != FI_SUCCESS)
		  {
			_NFIdebug ((fname, "FIfld_set_attr = <%d>\n", status));
 	                if (WFFglobal.current_form != NULL)
	                    FIf_delete (WFFglobal.current_form);
			WFFglobal.current_form = NULL;
			FIg_enable (WFFglobal.main_form, FI_FORM_GROUP);
			_WFFprocess_event (REFRESH_EVENT);
			ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_attr", status);
			return;
		  }
	  }

	if ((status = (long) FIfld_set_text (WFFglobal.current_form,
		NFF_MESSAGE, 0, 0, message, FALSE)) != FI_SUCCESS)
	  {
		_NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
                if (WFFglobal.current_form != NULL)
                    FIf_delete (WFFglobal.current_form);
		WFFglobal.current_form = NULL;
		FIg_enable (WFFglobal.main_form, FI_FORM_GROUP);
		_WFFprocess_event (REFRESH_EVENT);
		ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_text", status);
		return;
	  }

	/*  Load the NFM requestor status and message  */

	sprintf (hex_number, "0x%.8x", _ERRstruct.NFMRstatus);
	if ((status = (long) FIfld_set_text (WFFglobal.current_form,
		NFMR_STATUS, 0, 0, hex_number, FALSE)) != FI_SUCCESS)
	  {
		_NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
                if (WFFglobal.current_form != NULL)
                    FIf_delete (WFFglobal.current_form);
		WFFglobal.current_form = NULL;
		FIg_enable (WFFglobal.main_form, FI_FORM_GROUP);
		_WFFprocess_event (REFRESH_EVENT);
		ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_value", status);
		return;
	  }

	/*  Retrieve the error message  */

	ERRget_specific_message (NFMR, message);

	/*  Display the horizontal scroll bars if the message is too long  */

	if (num_chars < strlen (message))
	  {
		if ((status = FIfld_set_attr (WFFglobal.current_form,
			NFMR_MESSAGE, 0, attr_mask | FI_DISPLAY_HSCROLL)) != FI_SUCCESS)
		  {
			_NFIdebug ((fname, "FIfld_set_attr = <%d>\n", status));
 	                if (WFFglobal.current_form != NULL)
	                    FIf_delete (WFFglobal.current_form);
			WFFglobal.current_form = NULL;
			FIg_enable (WFFglobal.main_form, FI_FORM_GROUP);
			_WFFprocess_event (REFRESH_EVENT);
			ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_attr", status);
			return;
		  }
	  }

	if ((status = (long) FIfld_set_text (WFFglobal.current_form,
		NFMR_MESSAGE, 0, 0, message, FALSE)) != FI_SUCCESS)
	  {
		_NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
                if (WFFglobal.current_form != NULL)
                    FIf_delete (WFFglobal.current_form);
		WFFglobal.current_form = NULL;
		FIg_enable (WFFglobal.main_form, FI_FORM_GROUP);
		_WFFprocess_event (REFRESH_EVENT);
		ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_text", status);
		return;
	  }

	/*  Load the NET client status and message  */

	sprintf (hex_number, "0x%.8x", _ERRstruct.NETCstatus);
	if ((status = (long) FIfld_set_text (WFFglobal.current_form,
		NETC_STATUS, 0, 0, hex_number, FALSE)) != FI_SUCCESS)
	  {
		_NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
                if (WFFglobal.current_form != NULL)
                    FIf_delete (WFFglobal.current_form);
		WFFglobal.current_form = NULL;
		FIg_enable (WFFglobal.main_form, FI_FORM_GROUP);
		_WFFprocess_event (REFRESH_EVENT);
		ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_value", status);
		return;
	  }

	/*  Retrieve the error message  */

	ERRget_specific_message (NETC, message);

	/*  Display the horizontal scroll bars if the message is too long  */

	if (num_chars < strlen (message))
	  {
		if ((status = FIfld_set_attr (WFFglobal.current_form,
			NETC_MESSAGE, 0, attr_mask | FI_DISPLAY_HSCROLL)) != FI_SUCCESS)
		  {
			_NFIdebug ((fname, "FIfld_set_attr = <%d>\n", status));
	                if (WFFglobal.current_form != NULL)
 	                   FIf_delete (WFFglobal.current_form);
			WFFglobal.current_form = NULL;
			FIg_enable (WFFglobal.main_form, FI_FORM_GROUP);
			_WFFprocess_event (REFRESH_EVENT);
			ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_attr", status);
			return;
		  }
	  }

	if ((status = (long) FIfld_set_text (WFFglobal.current_form,
		NETC_MESSAGE, 0, 0, message, FALSE)) != FI_SUCCESS)
	  {
		_NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
                if (WFFglobal.current_form != NULL)
                    FIf_delete (WFFglobal.current_form);
		WFFglobal.current_form = NULL;
		FIg_enable (WFFglobal.main_form, FI_FORM_GROUP);
		_WFFprocess_event (REFRESH_EVENT);
		ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_text", status);
		return;
	  }

	/*  Load the NET server status and message  */

	sprintf (hex_number, "0x%.8x", _ERRstruct.NETSstatus);
	if ((status = (long) FIfld_set_text (WFFglobal.current_form,
		NETS_STATUS, 0, 0, hex_number, FALSE)) != FI_SUCCESS)
	  {
		_NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
                if (WFFglobal.current_form != NULL)
                    FIf_delete (WFFglobal.current_form);
		WFFglobal.current_form = NULL;
		FIg_enable (WFFglobal.main_form, FI_FORM_GROUP);
		_WFFprocess_event (REFRESH_EVENT);
		ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_value", status);
		return;
	  }

	/*  Retrieve the error message  */

	ERRget_specific_message (NETS, message);

	/*  Display the horizontal scroll bars if the message is too long  */

	if (num_chars < strlen (message))
	  {
		if ((status = FIfld_set_attr (WFFglobal.current_form,
			NETS_MESSAGE, 0, attr_mask | FI_DISPLAY_HSCROLL)) != FI_SUCCESS)
		  {
			_NFIdebug ((fname, "FIfld_set_attr = <%d>\n", status));
 	                if (WFFglobal.current_form != NULL)
	                    FIf_delete (WFFglobal.current_form);
			WFFglobal.current_form = NULL;
			FIg_enable (WFFglobal.main_form, FI_FORM_GROUP);
			_WFFprocess_event (REFRESH_EVENT);
			ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_attr", status);
			return;
		  }
	  }

	if ((status = (long) FIfld_set_text (WFFglobal.current_form,
		NETS_MESSAGE, 0, 0, message, FALSE)) != FI_SUCCESS)
	  {
		_NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
                if (WFFglobal.current_form != NULL)
                    FIf_delete (WFFglobal.current_form);
		WFFglobal.current_form = NULL;
		FIg_enable (WFFglobal.main_form, FI_FORM_GROUP);
		_WFFprocess_event (REFRESH_EVENT);
		ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_text", status);
		return;
	  }

	/*  Load the NFM server status and message  */

	sprintf (hex_number, "0x%.8x", _ERRstruct.NFMSstatus);
	if ((status = (long) FIfld_set_text (WFFglobal.current_form,
		NFMS_STATUS, 0, 0, hex_number, FALSE)) != FI_SUCCESS)
	  {
		_NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
                if (WFFglobal.current_form != NULL)
                    FIf_delete (WFFglobal.current_form);
		WFFglobal.current_form = NULL;
		FIg_enable (WFFglobal.main_form, FI_FORM_GROUP);
		_WFFprocess_event (REFRESH_EVENT);
		ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_value", status);
		return;
	  }

	/*  Retrieve the error message  */

	ERRget_specific_message (NFMS, message);

	/*  Display the horizontal scroll bars if the message is too long  */

	if (num_chars < strlen (message))
	  {
		if ((status = FIfld_set_attr (WFFglobal.current_form,
			NFMS_MESSAGE, 0, attr_mask | FI_DISPLAY_HSCROLL)) != FI_SUCCESS)
		  {
			_NFIdebug ((fname, "FIfld_set_attr = <%d>\n", status));
 	                if (WFFglobal.current_form != NULL)
	                    FIf_delete (WFFglobal.current_form);
			WFFglobal.current_form = NULL;
			FIg_enable (WFFglobal.main_form, FI_FORM_GROUP);
			_WFFprocess_event (REFRESH_EVENT);
			ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_attr", status);
			return;
		  }
	  }

	if ((status = (long) FIfld_set_text (WFFglobal.current_form,
		NFMS_MESSAGE, 0, 0, message, FALSE)) != FI_SUCCESS)
	  {
		_NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
                if (WFFglobal.current_form != NULL)
                    FIf_delete (WFFglobal.current_form);
		WFFglobal.current_form = NULL;
		FIg_enable (WFFglobal.main_form, FI_FORM_GROUP);
		_WFFprocess_event (REFRESH_EVENT);
		ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_text", status);
		return;
	  }

	/*  Load the NFM status and message  */

	sprintf (hex_number, "0x%.8x", _ERRstruct.NFMstatus);
	if ((status = (long) FIfld_set_text (WFFglobal.current_form,
		NFM_STATUS, 0, 0, hex_number, FALSE)) != FI_SUCCESS)
	  {
		_NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
                if (WFFglobal.current_form != NULL)
                    FIf_delete (WFFglobal.current_form);
		WFFglobal.current_form = NULL;
		FIg_enable (WFFglobal.main_form, FI_FORM_GROUP);
		_WFFprocess_event (REFRESH_EVENT);
		ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_value", status);
		return;
	  }

	/*  Retrieve the error message  */

	ERRget_specific_message (NFM, message);

	/*  Display the horizontal scroll bars if the message is too long  */

	if (num_chars < strlen (message))
	  {
		if ((status = FIfld_set_attr (WFFglobal.current_form,
			NFM_MESSAGE, 0, attr_mask | FI_DISPLAY_HSCROLL)) != FI_SUCCESS)
		  {
			_NFIdebug ((fname, "FIfld_set_attr = <%d>\n", status));
	                if (WFFglobal.current_form != NULL)
 	                   FIf_delete (WFFglobal.current_form);
			WFFglobal.current_form = NULL;
			FIg_enable (WFFglobal.main_form, FI_FORM_GROUP);
			_WFFprocess_event (REFRESH_EVENT);
			ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_attr", status);
			return;
		  }
	  }

	if ((status = (long) FIfld_set_text (WFFglobal.current_form,
		NFM_MESSAGE, 0, 0, message, FALSE)) != FI_SUCCESS)
	  {
		_NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
                if (WFFglobal.current_form != NULL)
                    FIf_delete (WFFglobal.current_form);
		WFFglobal.current_form = NULL;
		FIg_enable (WFFglobal.main_form, FI_FORM_GROUP);
		_WFFprocess_event (REFRESH_EVENT);
		ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_text", status);
		return;
	  }

	/*  Load the SQL status and message  */

	sprintf (hex_number, "0x%.8x", _ERRstruct.SQLstatus);
	if ((status = (long) FIfld_set_text (WFFglobal.current_form,
		SQL_STATUS, 0, 0, hex_number, FALSE)) != FI_SUCCESS)
	  {
		_NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
                if (WFFglobal.current_form != NULL)
                    FIf_delete (WFFglobal.current_form);
		WFFglobal.current_form = NULL;
		FIg_enable (WFFglobal.main_form, FI_FORM_GROUP);
		_WFFprocess_event (REFRESH_EVENT);
		ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_value", status);
		return;
	  }

	/*  Retrieve the error message  */

	ERRget_specific_message (SQL, message);

	/*  Display the horizontal scroll bars if the message is too long  */

	if (num_chars < strlen (message))
	  {
		if ((status = FIfld_set_attr (WFFglobal.current_form,
			SQL_MESSAGE, 0, attr_mask | FI_DISPLAY_HSCROLL)) != FI_SUCCESS)
		  {
			_NFIdebug ((fname, "FIfld_set_attr = <%d>\n", status));
 	                if (WFFglobal.current_form != NULL)
	                    FIf_delete (WFFglobal.current_form);
			WFFglobal.current_form = NULL;
			FIg_enable (WFFglobal.main_form, FI_FORM_GROUP);
			_WFFprocess_event (REFRESH_EVENT);
			ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_attr", status);
			return;
		  }
	  }

	if ((status = (long) FIfld_set_text (WFFglobal.current_form,
		SQL_MESSAGE, 0, 0, message, FALSE)) != FI_SUCCESS)
	  {
		_NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
                if (WFFglobal.current_form != NULL)
                    FIf_delete (WFFglobal.current_form);
		WFFglobal.current_form = NULL;
		FIg_enable (WFFglobal.main_form, FI_FORM_GROUP);
		_WFFprocess_event (REFRESH_EVENT);
		ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_text", status);
		return;
	  }

	/*  Load the particular relational db status and message  */

	sprintf (hex_number, "0x%.8x", _ERRstruct.SQLstatus);
	if ((status = (long) FIfld_set_text (WFFglobal.current_form,
		RDBMS_STATUS, 0, 0, hex_number, FALSE)) != FI_SUCCESS)
	  {
		_NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
                if (WFFglobal.current_form != NULL)
                    FIf_delete (WFFglobal.current_form);
		WFFglobal.current_form = NULL;
		FIg_enable (WFFglobal.main_form, FI_FORM_GROUP);
		_WFFprocess_event (REFRESH_EVENT);
		ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_value", status);
		return;
	  }

	/*  Retrieve the error message  */

	/* ERRget_specific_message (RDB, message); */

	/*  Display the horizontal scroll bars if the message is too long  */

	if (num_chars < strlen (message))
	  {
		if ((status = FIfld_set_attr (WFFglobal.current_form,
			RDBMS_MESSAGE, 0, attr_mask | FI_DISPLAY_HSCROLL)) != FI_SUCCESS)
		  {
			_NFIdebug ((fname, "FIfld_set_attr = <%d>\n", status));
	                if (WFFglobal.current_form != NULL)
 	                   FIf_delete (WFFglobal.current_form);
			WFFglobal.current_form = NULL;
			FIg_enable (WFFglobal.main_form, FI_FORM_GROUP);
			_WFFprocess_event (REFRESH_EVENT);
			ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_attr", status);
			return;
		  }
	  }

	if ((status = (long) FIfld_set_text (WFFglobal.current_form,
		RDBMS_MESSAGE, 0, 0, message, FALSE)) != FI_SUCCESS)
	  {
		_NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
                if (WFFglobal.current_form != NULL)
                    FIf_delete (WFFglobal.current_form);
		WFFglobal.current_form = NULL;
		FIg_enable (WFFglobal.main_form, FI_FORM_GROUP);
		_WFFprocess_event (REFRESH_EVENT);
		ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_text", status);
		return;
	  }

	/*  Load the report subsystem status and message  */

	sprintf (hex_number, "0x%.8x", NFM_S_SUCCESS);
	if ((status = (long) FIfld_set_text (WFFglobal.current_form,
		RPS_STATUS, 0, 0, hex_number, FALSE)) != FI_SUCCESS)
	  {
		_NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
                if (WFFglobal.current_form != NULL)
                    FIf_delete (WFFglobal.current_form);
		WFFglobal.current_form = NULL;
		FIg_enable (WFFglobal.main_form, FI_FORM_GROUP);
		_WFFprocess_event (REFRESH_EVENT);
		ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_value", status);
		return;
	  }

	/*  Retrieve the error message  */

	ERRget_specific_message (NFM, message);

	/*  Display the horizontal scroll bars if the message is too long  */

	if (num_chars < strlen (message))
	  {
		if ((status = FIfld_set_attr (WFFglobal.current_form,
			RPS_MESSAGE, 0, attr_mask | FI_DISPLAY_HSCROLL)) != FI_SUCCESS)
		  {
			_NFIdebug ((fname, "FIfld_set_attr = <%d>\n", status));
 	                if (WFFglobal.current_form != NULL)
	                    FIf_delete (WFFglobal.current_form);
			WFFglobal.current_form = NULL;
			FIg_enable (WFFglobal.main_form, FI_FORM_GROUP);
			_WFFprocess_event (REFRESH_EVENT);
			ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_attr", status);
			return;
		  }
	  }

	if ((status = (long) FIfld_set_text (WFFglobal.current_form,
		RPS_MESSAGE, 0, 0, message, FALSE)) != FI_SUCCESS)
	  {
		_NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
                if (WFFglobal.current_form != NULL)
                    FIf_delete (WFFglobal.current_form);
		WFFglobal.current_form = NULL;
		FIg_enable (WFFglobal.main_form, FI_FORM_GROUP);
		_WFFprocess_event (REFRESH_EVENT);
		ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_text", status);
		return;
	  }

	/*  Load the MEM status and message  */

	/*  Commented out MEM errors per Durwood (GS 8/13/90)  */
/*
	sprintf (hex_number, "0x%.8x", _ERRstruct.MEMstatus);
	if ((status = (long) FIfld_set_text (WFFglobal.current_form,
		MEM_STATUS, 0, 0, hex_number, FALSE)) != FI_SUCCESS)
	  {
		_NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
                if (WFFglobal.current_form != NULL)
                    FIf_delete (WFFglobal.current_form);
		WFFglobal.current_form = NULL;
		FIg_enable (WFFglobal.main_form, FI_FORM_GROUP);
		_WFFprocess_event (REFRESH_EVENT);
		ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_value", status);
		return;
	  }
*/
	/*  Retrieve the error message  */
/*
	ERRget_specific_message (MEM, message);
*/
	/*  Display the horizontal scroll bars if the message is too long  */
/*
	if (num_chars < strlen (message))
	  {
		if ((status = FIfld_set_attr (WFFglobal.current_form,
			MEM_MESSAGE, 0, attr_mask | FI_DISPLAY_HSCROLL)) != FI_SUCCESS)
		  {
			_NFIdebug ((fname, "FIfld_set_attr = <%d>\n", status));
	                if (WFFglobal.current_form != NULL)
	                    FIf_delete (WFFglobal.current_form);
			WFFglobal.current_form = NULL;
			FIg_enable (WFFglobal.main_form, FI_FORM_GROUP);
			_WFFprocess_event (REFRESH_EVENT);
			ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_attr", status);
			return;
		  }
	  }

	if ((status = (long) FIfld_set_text (WFFglobal.current_form,
		MEM_MESSAGE, 0, 0, message, FALSE)) != FI_SUCCESS)
	  {
		_NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
                if (WFFglobal.current_form != NULL)
                    FIf_delete (WFFglobal.current_form);
		WFFglobal.current_form = NULL;
		FIg_enable (WFFglobal.main_form, FI_FORM_GROUP);
		_WFFprocess_event (REFRESH_EVENT);
		ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_text", status);
		return;
	  }
*/
	/*  Center the form below the error button  */

	if ((status = _WFFcenter_form
		(WFFglobal.current_form, -1, 288)) != NFI_S_SUCCESS)
	  {
		_NFIdebug ((fname, "_WFFcenter_form = <0x%.8x>\n", status));
                if (WFFglobal.current_form != NULL)
                    FIf_delete (WFFglobal.current_form);
		WFFglobal.current_form = NULL;
		FIg_enable (WFFglobal.main_form, FI_FORM_GROUP);
		_WFFprocess_event (REFRESH_EVENT);
		return;
	  }

	/*  Display the form  */

	if ((status = (long) FIf_display (WFFglobal.current_form)) != FI_SUCCESS)
	  {
		_NFIdebug ((fname, "FIf_display = <%d>\n", status));
                if (WFFglobal.current_form != NULL)
                    FIf_delete (WFFglobal.current_form);
		WFFglobal.current_form = NULL;
		FIg_enable (WFFglobal.main_form, FI_FORM_GROUP);
		_WFFprocess_event (REFRESH_EVENT);
		ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIf_display", status);
		return;
	  }

	_NFIdebug ((fname, " returning ...\n"));
	return;
  }


long _WFFmain_error_notify (g_label, value, form)
  int		g_label;
  double	value;
  Form		form;
  {
	long	status = NFI_S_SUCCESS;

	static	char *fname = "_WFFmain_error_notify";

	_NFIdebug ((fname, "g_label = %d\n", g_label));
	_NFIdebug ((fname, "value   = %d\n", value));

	switch (g_label)
	  {
		case FI_CANCEL:

			/*  Delete the form  */
	                if (WFFglobal.current_form != NULL)
	                    FIf_delete (WFFglobal.current_form);
			WFFglobal.current_form = NULL;

			/*  Pop the error button back up  */

			FIg_set_state_off (WFFglobal.main_form, ERROR_BUTTON);

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
