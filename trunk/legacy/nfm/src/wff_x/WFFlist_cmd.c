#include "machine.h"
#include "WFF.h"
#include "WFFpersist.h"
#include "WFFlist.h"

/*  Global WFF structure  */

extern struct WFFglobal_st WFFglobal;

extern int NFI_MAX_COLUMNS;

long WFFlist_commands_long (form, workflow_name, app_name)
  Form	form;   /*  i - main form  */
  char  *workflow_name;
  char  *app_name;       /* currently not used but is here if needed */
  {
	long	status;
	char	s[256];
	MEMptr	attr_list = NULL;
	MEMptr	data_list = NULL;

	static	char *fname = "WFFlist_commands_long";

        long _WFFlist_load_mcf (); 

        _NFIdebug ((fname, "Workflow Name    = <%s>\n", workflow_name));
        _NFIdebug ((fname, "Application Name = <%s>\n", app_name));

	_WFFmessage (NFI_I_RETRIEVE, NULL);

	_NFIdebug ((fname, "calling WFGlist_commands_long ...\n"));
	if ((status = WFGlist_commands_long (workflow_name, app_name,
                                     &attr_list, &data_list)) != NFM_S_SUCCESS)
	 {
	    _NFIdebug ((fname, "WFGlist_commands = <0x%.8x>\n", status));
	    _WFFerase_message ();
	    MEMclose (&attr_list);
	    MEMclose (&data_list);
	    _NFIdebug ((fname, " returning FAILURE\n"));
            if (status == NFM_E_NO_COMMANDS_FOUND) 
               ERRload_struct (NFM, status, NULL);
	    return (status);
	 }
	_NFIdebug ((fname, "returned from WFGlist_commands\n"));

	_WFFerase_message ();

	if (WFFglobal.debug_on)
         {
		MEMprint_buffers (fname, attr_list, WFFglobal.debug_file);
		MEMprint_buffers (fname, data_list, WFFglobal.debug_file);
         } 

	/*  Close the attr_list with the old list info  */

	MEMclose (&(WFFglobal.attr_list));

	/*  Split the buffers apart  */

	if ((status = MEMsplit_copy_buffer
		(attr_list, &(WFFglobal.attr_list), 0)) != MEM_S_SUCCESS)
	  {
		_NFIdebug ((fname,"MEMsplit_copy_buffer = <0x%.8x>\n", status));
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
		_NFIdebug ((fname,"MEMsplit_copy_buffer = <0x%.8x>\n", status));
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

        NFI_MAX_COLUMNS = MAX_NO_COMMANDS_MCF_COLUMNS;

	if ((status = _WFFlist_load_mcf (form, FI_REVIEW, 
               3, WFFglobal.attr_list, WFFglobal.list_buffer)) != NFI_S_SUCCESS)
	 {
	    _NFIdebug ((fname,"_WFFlist_load_mcf = <0x%.8x>\n", status));
	    MEMclose (&(WFFglobal.attr_list));
	    MEMclose (&(WFFglobal.list_buffer));
	    _NFIdebug ((fname, " returning FAILURE\n"));
	    return (status);
	 }

	/*  Set the title  */

        if (strcmp (workflow_name, "") != 0)
         {
	    if ((status = (long) UMSGetByNum (s, NFI_P_LIST_WF_COMMANDS, "%s",
                                              workflow_name)) != UMS_S_SUCCESS)
	     {
	        _NFIdebug ((fname, "UMSGetByNum = <0x%.8x>\n", status));
	         _NFIdebug ((fname, "defaulting title\n"));
	         sprintf (s, "List of I/NFM Commands for Workflow \"%s\"",
                          workflow_name);
	     }
	 }
        else if (strcmp (workflow_name, "") != 0)
         {
	    if ((status = (long) UMSGetByNum (s, NFI_P_LIST_APP_COMMANDS, "%s",
                                              workflow_name)) != UMS_S_SUCCESS)
	     {
	        _NFIdebug ((fname, "UMSGetByNum = <0x%.8x>\n", status));
	         _NFIdebug ((fname, "defaulting title\n"));
	         sprintf (s, "List of I/NFM Commands for Application \"%s\"",
                          app_name);
	     }
	 }
        else
         {
	    if ((status = (long) UMSGetByNum (s, NFI_P_LIST_COMMANDS,
                                              NULL)) != UMS_S_SUCCESS)
	     {
	        _NFIdebug ((fname, "UMSGetByNum = <0x%.8x>\n", status));
	         _NFIdebug ((fname, "defaulting title\n"));
	         strcpy (s, "List of I/NFM Commands");
	     }
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

	WFFglobal.current_list = WFF_LIST_COMMANDS;

	_NFIdebug ((fname, " returning SUCCESS\n"));
	return (NFI_S_SUCCESS);
  }


