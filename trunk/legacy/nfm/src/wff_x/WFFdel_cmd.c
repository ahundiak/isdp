#include "machine.h"
#include "WFF.h"
#include "WFFlist.h"
#include "WFFcmds.h"

/*  Global WFF structure  */

extern struct WFFglobal_st WFFglobal;

/********************************************************************
 *                                                                  * 
 *  Function : WFFdel_commands                                      *
 *                                                                  * 
 *                                                                  * 
 ********************************************************************/

long WFFdelete_commands ()
  {
	long	status;
        int     i;
        char    s[256];
        char    **data;
        char    cmd_name[41];
        char    app_name[41];
        char    trans_cmd[41];
        char    entity[41];
        char    nfm_cmd_no[41];
        MEMptr  attr_list = NULL;
        MEMptr  data_list = NULL;
	static	char *fname = "_WFFdelete_commands";
        
        /*  Pointer to the WFFcmd_ptr structure  */

        WFFcmd_ptr ptr;

        _NFIdebug ((fname, " Function entered\n"));

        strcpy (cmd_name, "Command Name");
        strcpy (app_name, "Application");
        strcpy (trans_cmd, "Transition Command");
        strcpy (entity, "Entity");
        strcpy (nfm_cmd_no, "I/NFM Command Number");

        /*  Initialize the structure  */

        if ((ptr = (WFFcmd_ptr) malloc
                (sizeof (struct WFFcmd_st))) == NULL)
         {
            _NFIdebug ((fname,
            "malloc failed; size = <%d>\n", sizeof (struct WFFcmd_st)));
            WFFglobal.error_no = NFI_E_MALLOC;
            ERRload_struct (NFI, NFI_E_MALLOC,
                            "%d", sizeof (struct WFFcmd_st));
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_MALLOC);
         }

       ptr->type     = WFF_DELETE_COMMAND_TYPE; 
       ptr->done     = FALSE;
       ptr->num_cmds = 0;
       ptr->num_app  = 0;
       ptr->cmd_list = NULL;

       WFFglobal.working_no = NFI_I_DELETE_COMMANDS;

       /* Put up a message */

       _WFFmessage (NFI_I_RETRIEVE, NULL);  /* Retrieving data from server */

        
       /* Get all the commands in the system */
      
       status = WFGlist_commands_long ("", "", &attr_list, &data_list);
       if (status != NFM_S_SUCCESS) 
        {
           MEMclose (&attr_list);
           MEMclose (&data_list);
           _NFIdebug ((fname, "WFGlist_commands_long = <0x%.8x>\n",
                       status));
           _WFFerase_message ();
           _WFFfree_cmd_ptr (ptr);
           _NFIdebug ((fname, " returning FAILURE\n"));
           return (status);
        }
      
       /* Prepare the attr_list for reading */
       
       status = MEMbuild_array (attr_list);
       if (status != MEM_S_SUCCESS) 
        {
           MEMclose (&attr_list);
           MEMclose (&data_list);
           _NFIdebug ((fname, "MEMbuild_array = <0x%.8x>\n", status));
           _WFFerase_message ();
           _WFFfree_cmd_ptr (ptr);
           _NFIdebug ((fname, " returning <0x%.8x>\n", NFI_E_MEM));
           return (NFI_E_MEM);
        }

       data = (char **) attr_list->data_ptr;

       /* put the synonyms into the variables */

       strcpy (cmd_name, data[0]);
       strcpy (app_name, data[1]);
       strcpy (entity, data[2]);
       strcpy (trans_cmd, data[3]);
       strcpy (nfm_cmd_no, data[4]);

       MEMclose (&attr_list);

       /* Prepare the data_list for reading */
       
       status = MEMbuild_array (data_list);
       if (status != MEM_S_SUCCESS) 
        {
           MEMclose (&data_list);
           _NFIdebug ((fname, "MEMbuild_array = <0x%.8x>\n", status));
           _WFFerase_message ();
           _WFFfree_cmd_ptr (ptr);
           _NFIdebug ((fname, " returning <0x%.8x>\n", NFI_E_MEM));
           return (NFI_E_MEM);
        }

       /* load the commands into the structure */

       status = _WFFload_cmds_in_list (data_list, ptr);
       if (status != NFI_S_SUCCESS) 
        {
           MEMclose (&data_list);
           _NFIdebug ((fname, "_WFFload_cmds_in_list = <0x%.8x>\n", status));
           _WFFerase_message ();
           _WFFfree_cmd_ptr (ptr);
           return (status);
        }
       MEMclose (&data_list);

       /*  Load in the 'Delete Commands' form  */

       if ((status = (long) FIf_new (DELETE_COMMAND_LABEL, DEL_CMD_FORM,
                     _WFFnotify, &WFFglobal.current_form)) != FI_SUCCESS)
        {
           _NFIdebug ((fname, "FIf_new = <%d>\n", status));
           _WFFerase_message ();
           _WFFfree_cmd_ptr (ptr);
           WFFglobal.error_no = NFI_E_FORM;
           ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIf_new", status);
           _NFIdebug ((fname, " returning FAILURE\n"));
           return (NFI_E_FORM);
        }

	    /*  Store a pointer to the data in the form  */
    
	    if ((status = (long) FIf_set_user_pointer
		    (WFFglobal.current_form, (char *) ptr)) != FI_SUCCESS)
	     {
		_NFIdebug ((fname, "FIf_set_user_pointer = <%d>\n", status));
                _WFFerase_message ();
		_WFFfree_cmd_ptr (ptr);
		WFFglobal.error_no = NFI_E_FORM;
		ERRload_struct
		     (NFI, NFI_E_FORM, "%s%d", "FIf_set_user_pointer", status);
	        _NFIdebug ((fname, " returning FAILURE\n"));
	        return (NFI_E_FORM);
	     }

            /* Put the synonyms in the CMDS_TITLE_MCF */

/* IGI Intel Solaris Port - CN 31/5/95 */
#if defined(OS_SCO_UNIX) || defined(OS_INTELSOL) 
	/* To set the font for SCO - CRN  25 Feb 94 	*/
	FIg_set_font(WFFglobal.current_form, CMDS_TITLE_MCF, "7x13bold", 15);
#endif
            for (i = 0; i < 5; ++i)
             {
                switch (i)
                 {
                    case 0:
                       status = FIfld_set_text (WFFglobal.current_form,
                                 CMDS_TITLE_MCF, 0, i, cmd_name, FALSE);
                    break;

                    case 1:
                       status = FIfld_set_text (WFFglobal.current_form,
                                 CMDS_TITLE_MCF, 0, i, app_name, FALSE);
                    break;

                    case 2:
                       status = FIfld_set_text (WFFglobal.current_form,
                                 CMDS_TITLE_MCF, 0, i, entity, FALSE);
                    break;

                    case 3:
                       status = FIfld_set_text (WFFglobal.current_form,
                                 CMDS_TITLE_MCF, 0, i, trans_cmd, FALSE);
                    break;

                    case 4:
                       status = FIfld_set_text (WFFglobal.current_form,
                                 CMDS_TITLE_MCF, 0, i, nfm_cmd_no, FALSE);
                    break;
                 }
             }
 
	    /* Put the commands in the scroll list, it will handle NULL lists */
   
            status = _WFFput_cmds_in_list (WFFglobal.current_form,  
                                   CMDS_LIST_MCF, ptr->num_cmds, ptr->cmd_list);
            if (status != NFI_S_SUCCESS)
	     {
	         _NFIdebug ((fname, "_WFFput_cmds_in_list = <0x%.8x>\n",
                             status));
                 _WFFerase_message ();
	         _WFFfree_cmd_ptr (ptr);
	         _NFIdebug ((fname, " returning FAILURE\n"));
	         return (status);
	     }

            _NFIdebug ((fname, "Link scroll of CMDS_LIST_MCF to SYNONYM \n"));

            /* link scrolling of CMDS_LIST_MCF to the CMDS_TITLE_MCF */

            status = (long) FImcf_set_scroll_link (WFFglobal.current_form,
                                         CMDS_LIST_MCF, CMDS_TITLE_MCF);
            if (status != FI_SUCCESS)
             {
                _NFIdebug ((fname, "FImcf_set_scroll_link = <%d>\n", status));
                _WFFfree_cmd_ptr (ptr);
                WFFglobal.error_no = NFI_E_FORM;
                ERRload_struct (NFI, NFI_E_FORM, "%s%d",
                                "FImcf_set_scroll_link", status);
                _NFIdebug ((fname, " returning FAILURE\n"));
                return (NFI_E_FORM);
             }
    
    	    /*  Set the title  */
    
	    status = (long) UMSGetByNum (s, NFI_P_DELETE_COMMANDS, NULL);  
	    if (status != UMS_S_SUCCESS)  
	      {
		    _NFIdebug ((fname, "UMSGetByNum = <0x%.8x>\n", status));
		    _NFIdebug ((fname, "defaulting title\n"));
                    strcpy (s, "Delete Commands from I/NFM");
	      }
    
	    if ((status = (long) FIg_set_text
		    (WFFglobal.current_form, TITLE1, s)) != FI_SUCCESS)
	      {
		    _NFIdebug ((fname, "FIg_set_text = <%d>\n", status));
                    _WFFerase_message ();
		    _WFFfree_cmd_ptr (ptr);
		    WFFglobal.error_no = NFI_E_FORM;
		    ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_set_text",
                                    status);
		    _NFIdebug ((fname, " returning FAILURE\n"));
		    return (NFI_E_FORM);
	      }

        /* Erase the message */

        _WFFerase_message (); /* Erase "Retrieving data from server" msg */

	/*  Clear out the error message strip  */

	_WFFclear_msg (WFFglobal.current_form);

	/*  Adjust and Center the form */

	if ((status = _WFFadjust_cmd_form
	   	      (WFFglobal.current_form)) != NFI_S_SUCCESS)
	 {
	    _NFIdebug ((fname, "_WFFadjust_cmd_form = <0x%.8x>\n", status));
	    _WFFfree_cmd_ptr (ptr);
	    WFFglobal.error_no = status;
	    _NFIdebug ((fname, " returning <0x%.8x>\n", status));
	    return (status);
         }

	/*  Display the form  */

	status = (long) FIf_display (WFFglobal.current_form);
	if (status != FI_SUCCESS)
	 {
	    _NFIdebug ((fname, "FIf_display = <%d>\n", status));
	    _WFFfree_cmd_ptr (ptr);
	    WFFglobal.error_no = NFI_E_FORM;
	    ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIf_display", status);
	    _NFIdebug ((fname, " returning FAILURE\n"));
	    return (NFI_E_FORM);
	 }

	_NFIdebug ((fname, " returning SUCCESS\n"));
	return (NFI_S_SUCCESS);
  }



long _WFFdelete_commands_notify (g_label, value, form)
  int		g_label;
  double	value;
  Form		form;
  {
	long	        status;

	WFFcmd_ptr	ptr;

	static	char *fname = "_WFFdelete_commands_notify";

	_NFIdebug ((fname, "g_label = <%d>\n", g_label));
	_NFIdebug ((fname, "value = <%d>\n", value));

	/*  Pull out the pointer to the data  */

	if ((status = (long) FIf_get_user_pointer
		(form, (char *) &ptr)) != FI_SUCCESS)
	  {
		_NFIdebug ((fname, "FIf_get_user_pointer = <%d>\n", status));
		ERRload_struct (NFI, NFI_E_FORM, "%s%d",
                                "FIf_get_user_pointer", status);
		_NFIdebug ((fname, " returning <0x%.8x>\n", NFI_E_FORM));
		return (NFI_E_FORM);
	  }

        _WFFmessage (NFI_S_CLEAR_MSG, NULL);
        status = NFI_S_SUCCESS;

	switch (g_label)
	  {
		case FI_CANCEL:

			/*  Load the global error structure  */

			ERRload_struct (NFI, NFI_W_COMMAND_CANCELLED, NULL);

			/*  Set the next state  */

			if ((status = WFFset_to_state ()) != NFI_S_SUCCESS)
			  _NFIdebug ((fname, "WFFset_to_state = <0x%.8x>\n",
                                      status));

			_WFFfree_cmd_ptr (ptr);

			/*  Enable the main form  */

			if (WFFglobal.main_form != NULL)
			  {
			     FIg_enable (WFFglobal.main_form, FI_FORM_GROUP);
			     _WFFprocess_event (REFRESH_EVENT);
			  }

		break;

		case FI_ACCEPT:

                        status = _WFFdelete_cmds (form, CMDS_LIST_MCF, ptr);
                        if (status != NFI_S_SUCCESS)
                         {
                            FIg_set_state (form, g_label, FALSE);
                            _NFIdebug ((fname,
                             "WFFdelete_commands : status = <0x%.8x\n",status));
                            return (status);
                         }

                        if (ptr->done == NO_ACTIVITY)  
                         {
                            FIg_set_state (form, g_label, FALSE);
                            _WFFmessage (NFI_I_NO_ACTIVITY, NULL); 
                            return (NFI_S_SUCCESS);
                         }
/*
                        else if (ptr->done == COMMAND_IN_USE)
                         { 
			    / * _WFFerase_message (); * /
                            _WFFmessage (NFI_S_CLEAR_MSG, NULL);
                            _WFFmessage (NFI_W_COMMAND_IN_USE, NULL); 
                         }
*/

			/*  Put up a message  */

			_WFFmessage (WFFglobal.working_no, NULL);

			/*  Call NFM or WFG to do the command  */

			_NFIdebug ((fname, "calling WFGupdate_commands...\n"));

                        status = WFGprocess_commands (ptr->num_cmds,
                                                      ptr->cmd_list);

                        if (status != NFM_S_SUCCESS) 
			    _NFIdebug((fname,"WFGprocess_commands = <0x%.8x>\n",
                                       status));

			/*  Erase the message  */

			_WFFerase_message ();

			/*  Save the return status  */

                        if ((status == NFM_S_SUCCESS) && 
                            (ptr->done == COMMAND_IN_USE))
                         { 
                            ERRreset_struct ();
                            ERRload_struct (NFI, NFI_W_COMMAND_IN_USE, NULL);
                         } 

			WFFglobal.cmd_status = status;

			/*  Set the next state  */

			if ((status = WFFset_to_state ()) != NFI_S_SUCCESS)
				_NFIdebug ((fname, "WFFset_to_state = <0x%.8x>\n", status));

			/*  Clear out the appropriate fields  */

			/*  Blank out the listing on the main form  */

			_WFFfree_cmd_ptr (ptr);

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

