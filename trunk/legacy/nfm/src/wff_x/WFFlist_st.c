#include "machine.h"
#include "WFF.h"
#include "WFFpersist.h"
#include "WFFlist.h"

/*  Global WFF structure  */

extern struct WFFglobal_st WFFglobal;
extern int NFI_MAX_COLUMNS;

long WFFlist_states_long (form, workflow_name)
  Form	form;   /*  i - main form  */
  char  *workflow_name;
  {
	long	status;
	char	s[120];
	MEMptr	attr_list = NULL;
	MEMptr	data_list = NULL;

	static	char *fname = "WFFlist_states_long";

        long _WFFlist_load_mcf (); 

        _NFIdebug ((fname, "Workflow Name = <%s>\n", workflow_name));

        if (strcmp (workflow_name, "") == 0)
         {
             status = NFI_E_NO_WF;
	     _NFIdebug ((fname, "The workflow_name is null", status));
	     _NFIdebug ((fname, " returning FAILURE\n"));
	     return (status);
         } 

	_WFFmessage (NFI_I_RETRIEVE, NULL);

	_NFIdebug ((fname, "calling WFGlist_states ...\n"));
	if ((status = WFGlist_states (WFFglobal.user_id, workflow_name, "", "",
                     WFF_ALL_DATA, &attr_list, &data_list)) != NFM_S_SUCCESS)
	  {
		_NFIdebug ((fname, "WFGlist_states = <0x%.8x>\n", status));
		_WFFerase_message ();
		MEMclose (&attr_list);
		MEMclose (&data_list);
		_NFIdebug ((fname, " returning FAILURE\n"));
                if (status == NFM_E_NO_STATES_DEFINED)
                   ERRload_struct (NFM, status, NULL);
		return (status);
	  }
	_NFIdebug ((fname, "returned from WFGlist_states\n"));

	_WFFerase_message ();

	if (WFFglobal.debug_on)
         {
	    MEMprint_buffers (fname, attr_list, WFFglobal.debug_file);
	    MEMprint_buffers (fname, data_list, WFFglobal.debug_file);
         }

	/*  Close the attr_list with the old list info  */

	MEMclose (&(WFFglobal.attr_list));

	/*  Copy the attr_list into WFFglobal.attr_list */

	if ((status = MEMsplit_copy_buffer
		(attr_list, &(WFFglobal.attr_list), 0)) != MEM_S_SUCCESS)
	  {
	     _NFIdebug ((fname, "MEMsplit_copy_buffer = <0x%.8x>\n", status));
	     MEMclose (&attr_list);
	     MEMclose (&data_list);
	     ERRload_struct
	             (NFI, NFI_E_MEM, "%s%x", "MEMsplit_copy_buffer", status);
	     _NFIdebug ((fname, " returning FAILURE\n"));
	     return (NFI_E_MEM);
	  }

	/*  Close the list_buffer with the old list info  */

	MEMclose (&(WFFglobal.list_buffer));

	if ((status = MEMsplit_copy_buffer
		(data_list, &(WFFglobal.list_buffer), 0)) != MEM_S_SUCCESS)
	  {
		_NFIdebug ((fname, "MEMsplit_copy_buffer = <0x%.8x>\n", status));
	        MEMclose (&attr_list);
	        MEMclose (&data_list);
		MEMclose (&(WFFglobal.attr_list));
		MEMclose (&(WFFglobal.list_buffer));
		ERRload_struct
			(NFI, NFI_E_MEM, "%s%x", "MEMsplit_copy_buffer", status);
		_NFIdebug ((fname, " returning FAILURE\n"));
		return (NFI_E_MEM);
	  }

	MEMclose (&attr_list);
	MEMclose (&data_list);

	/*  Erase the previous title  */

	FIg_erase (form, LISTING_TITLE);

        NFI_MAX_COLUMNS = MAX_NO_STATES_MCF_COLUMNS;

	if ((status = _WFFlist_load_mcf (form, FI_REVIEW, 
		                         2, WFFglobal.attr_list,
                                         WFFglobal.list_buffer)) != NFI_S_SUCCESS)
	  {
		_NFIdebug ((fname,"_WFFlist_load_mcf = <0x%.8x>\n", status));
		MEMclose (&(WFFglobal.attr_list));
		MEMclose (&(WFFglobal.list_buffer));
		_NFIdebug ((fname, " returning FAILURE\n"));
		return (status);
	  }

	/*  Set the title  */

	if ((status = (long) UMSGetByNum
		(s, NFI_P_LIST_STATES, "%s", workflow_name)) != UMS_S_SUCCESS)
	  {
		_NFIdebug ((fname, "UMSGetByNum = <0x%.8x>\n", status));
		_NFIdebug ((fname, "defaulting title\n"));
		sprintf (s, "List of I/NFM States in Workflow \"%s\"",
                         workflow_name);
	  }

        FIg_erase (form, LISTING_TITLE);
	FIg_set_text (form, LISTING_TITLE, s);
	FIg_display (form, LISTING_TITLE);

	/*  Center the title  */

#ifndef XWINDOWS
        _WFFcenter_gadget (form, LISTING_TITLE);
#endif
 
	/*  Refresh the form  */

	FIf_display (form);

	/*  Set the current list  */

	WFFglobal.current_list = WFF_LIST_STATES;

	_NFIdebug ((fname, " returning SUCCESS\n"));
	return (NFI_S_SUCCESS);
  }


long WFFlist_states_short (form, workflow_name)
  Form	form;   /*  i - main form  */
  char  *workflow_name;
  {
	long	status;
	MEMptr	attr_list = NULL;
	MEMptr	data_list = NULL;

	static	char *fname = "WFFlist_states_short";

	WFFglobal.current_popup = WFF_LIST_STATES;

        if (strcmp (workflow_name, "") == 0)
         {
             status = NFI_E_NO_WF;
	     _NFIdebug ((fname, "The workflow_name is null", status));
	     _NFIdebug ((fname, " returning FAILURE\n"));
	     return (status);
         } 

	_WFFmessage (NFI_I_RETRIEVE, NULL);

	_NFIdebug ((fname, "calling WFGlist_states ...\n"));
	status = WFGlist_states (WFFglobal.user_id, workflow_name, "", "",
                                 WFF_NAME_ONLY, &attr_list, &data_list); 
        if (status != NFM_S_SUCCESS)
	  {
		_NFIdebug ((fname, "WFGlist_states = <0x%.8x>\n", status));
		_WFFerase_message ();
		_WFFpopup_main_button (form);
		MEMclose (&attr_list);
		MEMclose (&data_list);
		_NFIdebug ((fname, " returning FAILURE\n"));
		return (status);
	  }
	_NFIdebug ((fname, "returned from WFGlist_states\n"));

        MEMclose (&attr_list);
	_WFFerase_message ();

	if (WFFglobal.debug_on)
		MEMprint_buffers (fname, data_list, WFFglobal.debug_file);

	if ((status = _WFFlist_load_popup
		("n_statename", data_list)) != NFI_S_SUCCESS)
	  {
		_NFIdebug ((fname, "_WFFlist_load_popup = <0x%.8x>\n", status));
		_WFFpopup_main_button (form);
		MEMclose (&data_list);
		_NFIdebug ((fname, " returning FAILURE\n"));
		return (status);
	  }

	MEMclose (&data_list);

	_NFIdebug ((fname, " returning SUCCESS\n"));
	return (NFI_S_SUCCESS);
  }

