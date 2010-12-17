#include "machine.h"
#include "WFF.h"
#include "WFFpersist.h"
#include "WFFlist.h"

/*  Global WFF structure  */

extern struct WFFglobal_st WFFglobal;

extern int NFI_MAX_COLUMNS;

long WFFlist_workflows_long (form)
  Form	form;   /*  i - main form  */
  {
	long	status;
	char	s[120];
        MEMptr  attr_list = NULL;
        MEMptr  data_list = NULL;


	static	char *fname = "WFFlist_workflows_long";

        long _WFFlist_load_mcf (); 

	_WFFmessage (NFI_I_RETRIEVE, NULL);

	_NFIdebug ((fname, "calling WFGlist_wfs ...\n"));
	if ((status = WFGlist_wfs (WFFglobal.user_id, "", "", WFF_ALL_DATA,
                                   &attr_list, &data_list)) != NFM_S_SUCCESS)
	 {
	     _NFIdebug ((fname, "WFGlist_wfs = <0x%.8x>\n", status));
	     _WFFerase_message ();
	     MEMclose (&attr_list);
	     MEMclose (&data_list);
	     _NFIdebug ((fname, " returning FAILURE\n"));
	     return (status);
	 }
	_NFIdebug ((fname, "returned from WFGlist_wfs\n"));

	_WFFerase_message ();

	if (WFFglobal.debug_on)
         {
	     MEMprint_buffers (fname, attr_list, WFFglobal.debug_file);
	     MEMprint_buffers (fname, data_list, WFFglobal.debug_file);
         }

	MEMclose (&(WFFglobal.attr_list));

	/*  Copy the attr_list into the global attr_list  */

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

        NFI_MAX_COLUMNS = MAX_NO_WF_MCF_COLUMNS;

	if ((status = _WFFlist_load_mcf (form, FI_SINGLE_SELECT, 
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
		(s, NFI_P_LIST_WF, NULL)) != UMS_S_SUCCESS)
	 {
	     _NFIdebug ((fname, "UMSGetByNum = <0x%.8x>\n", status));
	     _NFIdebug ((fname, "defaulting title\n"));
	     strcpy (s, "List of I/NFM Workflows");
	 }

        FIg_erase (form, LISTING_TITLE);
	FIg_set_text (form, LISTING_TITLE, s);
	FIg_display (form, LISTING_TITLE);

	/*  Center the title */

#ifndef XWINDOWS
	_WFFcenter_gadget (form, LISTING_TITLE);
#endif
	/*  Refresh the form  */

	FIf_display (form);

	/*  Set the current list  */

	WFFglobal.current_list = WFF_LIST_WORKFLOWS;

	_NFIdebug ((fname, " returning SUCCESS\n"));
	return (NFI_S_SUCCESS);
  }


long WFFlist_workflows_short (form)
  Form	form;   /*  i - main form  */
  {
	long	status;
	MEMptr	attr_list = NULL;
	MEMptr	data_list = NULL;

	static	char *fname = "WFFlist_workflows_short";

	WFFglobal.current_popup = WFF_LIST_WORKFLOWS;

	_WFFmessage (NFI_I_RETRIEVE, NULL);

	_NFIdebug ((fname, "calling WFGlist_wfs ...\n"));
	if ((status = WFGlist_wfs (WFFglobal.user_id, "", "", WFF_NAME_ONLY, 
		                   &attr_list, &data_list)) != NFM_S_SUCCESS)
         {
	     _NFIdebug ((fname, "WFGlist_wfs = <0x%.8x>\n", status));
	     _WFFerase_message ();
	     _WFFpopup_main_button (form);
	     MEMclose (&attr_list);
	     MEMclose (&data_list);
	     _NFIdebug ((fname, " returning FAILURE\n"));
	     return (status);
         }
	_NFIdebug ((fname, "returned from WFGlist_wfs\n"));

        MEMclose (&attr_list);
	_WFFerase_message ();

	if (WFFglobal.debug_on)
         {
	     MEMprint_buffers (fname, data_list, WFFglobal.debug_file);
         }

        status = MEMbuild_array (data_list);
        if (status != MEM_S_SUCCESS)
         {
		_NFIdebug ((fname, "MEMbuild_array = <0x%.8x>\n", status));
		_WFFpopup_main_button (form);
		MEMclose (&data_list);
                ERRload_struct (NFI, NFI_E_MEM, "%s%x", "MEMbuild_array",
                                status);
		_NFIdebug ((fname, " returning FAILURE\n"));
		return (NFI_E_MEM);
         } 

	if ((status = _WFFlist_load_popup
		("n_workflowname", data_list)) != NFI_S_SUCCESS)
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

