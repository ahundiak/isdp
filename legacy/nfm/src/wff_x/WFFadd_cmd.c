
/* machine.h included to take care of platform variencies MVR 23 Dec 1993 */
#include "machine.h"

#include "WFF.h"
#include "WFFlist.h"
#include "WFFcmds.h"

/*  Global WFF structure  */

extern struct WFFglobal_st WFFglobal;

/********************************************************************
 *                                                                  * 
 *  Function : WFFadd_commands                                      *
 *                                                                  * 
 *                                                                  * 
 ********************************************************************/

long WFFadd_commands ()
  {
	long	status;
        int     i, x;
        char    s[256];
        char    **data;
        char    cmd_name[41];
        char    app_name[41];
        char    trans_cmd[41];
        char    entity[41];
        char    nfm_cmd_no[41];
        MEMptr  attr_list = NULL;
        MEMptr  data_list = NULL;
	static	char *fname = "_WFFadd_commands";
        
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

       ptr->type     = WFF_ADD_COMMAND_TYPE; 
       ptr->done     = FALSE;
       ptr->num_cmds = 0;
       ptr->num_app  = 0;
       ptr->cmd_list = NULL;

       WFFglobal.working_no = NFI_I_ADD_COMMANDS;

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
       data_list = NULL;

       /* get the applications */
      
       status = WFGlist_applications (&data_list);
       if (status != NFM_S_SUCCESS) 
        {
           MEMclose (&data_list);
           _NFIdebug ((fname, "WFGlist_applications = <0x%.8x>\n", status));
           _WFFerase_message ();
           _WFFfree_cmd_ptr (ptr);
           _NFIdebug ((fname, " returning FAILURE\n"));
           return (status);
        }
      
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

       data = (char **) data_list->data_ptr;

       _NFIdebug ((fname, "Load in the ADD_COMMANDS form\n"));

       /*  Load in the 'Add Commands' form  */

       if ((status = (long) FIf_new (ADD_COMMAND_LABEL, ADD_CMD_FORM,
                     _WFFnotify, &WFFglobal.current_form)) != FI_SUCCESS)
        {
           MEMclose (&data_list);
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
                MEMclose (&data_list);
		_NFIdebug ((fname, "FIf_set_user_pointer = <%d>\n", status));
                _WFFerase_message ();
		_WFFfree_cmd_ptr (ptr);
		WFFglobal.error_no = NFI_E_FORM;
		ERRload_struct
		     (NFI, NFI_E_FORM, "%s%d", "FIf_set_user_pointer", status);
	        _NFIdebug ((fname, " returning FAILURE\n"));
	        return (NFI_E_FORM);
	     }
       _NFIdebug ((fname, "Clear out the fields and set lists\n"));

            /* clear out the associated list for the "CMD_APP_FIELD" */

	    if ((status = (long) FIfld_set_list_num_rows  
		 (WFFglobal.current_form, CMD_APP_FIELD, 0, 0)) != FI_SUCCESS)
	     {
                MEMclose (&data_list);
		_NFIdebug ((fname, "FIfld_set_list_num_rows = <%d>\n", status));
                _WFFerase_message ();
		_WFFfree_cmd_ptr (ptr);
		WFFglobal.error_no = NFI_E_FORM;
		ERRload_struct (NFI, NFI_E_FORM, "%s%d", 
                                "FIfld_set_list_num_rows_pointer", status);
	        _NFIdebug ((fname, " returning FAILURE\n"));
	        return (NFI_E_FORM);
	     }

       _NFIdebug ((fname, "put the commands in the assoc list for the CMD_APP_FIELD\n"));
            /* put the commands in the associated list for the CMD_APP_FIELD */

            for (x = 0; x < data_list->rows; ++x)
             {
                if (strcmp (data[x], "NFM") == 0) 
	           status = (long) FIfld_set_list_default_text (
                    WFFglobal.current_form, CMD_APP_FIELD, x, 0, data[x], TRUE);
                else
	           status = (long) FIfld_set_list_text (WFFglobal.current_form,
                                       CMD_APP_FIELD, x, 0, data[x], FALSE);

	        if (status != FI_SUCCESS)
	         {
                    MEMclose (&data_list);
		    _NFIdebug ((fname, "FIfld_set_list_text = <%d>\n", status));
                    _WFFerase_message ();
		    _WFFfree_cmd_ptr (ptr);
		    WFFglobal.error_no = NFI_E_FORM;
		    ERRload_struct (NFI, NFI_E_FORM, "%s%d", 
                                    "FIfld_set_list_text", status);
	            _NFIdebug ((fname, " returning FAILURE\n"));
	            return (NFI_E_FORM);
	         }
	     }

            MEMclose (&data_list);

       _NFIdebug ((fname, "Set the max chars allowed for the fields\n"));

            /* Set the maximum of characters allowed for the fields */
    
            status = (long) FIfld_set_max_num_chars (WFFglobal.current_form,
                                                     CMD_NAME_FIELD, 0, 101);
            status = (long) FIfld_set_max_num_chars (WFFglobal.current_form,
                                                     CMD_APP_FIELD, 0, 3);
            status = (long) FIfld_set_max_num_chars (WFFglobal.current_form,
                                                     CMD_ENTITY_FIELD, 0, 11);
    
            /* clear out the cmd_name field */
    
#if defined(OS_SCO_UNIX) /* || defined(OS_INTELSOL) This was causing a  refresh 
				problem IGI 17/7/95 */
            /* wrok around change - to set font for SCO - SSRS 16 Feb 94 */
            FIg_set_font( WFFglobal.current_form, CMD_NAME_FIELD, 
                                                       "7x13bold", 15 );
            FIg_set_font( WFFglobal.current_form, CMD_APP_FIELD, 
                                                       "7x13bold", 15 );
            FIg_set_font( WFFglobal.current_form, CMD_ENTITY_FIELD, 
                                                       "7x13bold", 15 );
#endif
            status = (long) FIfld_set_text (WFFglobal.current_form,
                                            CMD_NAME_FIELD, 0, 0, "", FALSE);
            /* put "NFM" in the Application field (default) */
    
/*
            status = (long) FIfld_set_text (WFFglobal.current_form,
                                            CMD_APP_FIELD, 0, 0, "NFM", FALSE);
*/

            /* put "NFMITEM" / "I"  in the entity field (default) */
    
/*
            status = (long) FIfld_set_text (WFFglobal.current_form,
                                  CMD_ENTITY_FIELD, 0, 0, "I", FALSE);
*/
       _NFIdebug ((fname, "Put the synonyms in the CMDS_TITLE_MCF\n"));

/* IGI Intel Solaris Port - CN 31/5/95 */
#if defined(OS_SCO_UNIX) || defined(OS_INTELSOL)
            /* wrok around change - to set font for SCO - SSRS 16 Feb 94 */
            FIg_set_font( WFFglobal.current_form, CMDS_TITLE_MCF, 
                                                       "7x13bold", 15 );
#endif

            /* Put the synonyms in the CMDS_TITLE_MCF */

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
 
       _NFIdebug ((fname, "Put the commands in the scroll list\n"));
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
    
	    status = (long) UMSGetByNum (s, NFI_P_ADD_COMMANDS, NULL);  
	    if (status != UMS_S_SUCCESS)  
	      {
		    _NFIdebug ((fname, "UMSGetByNum = <0x%.8x>\n", status));
		    _NFIdebug ((fname, "defaulting title\n"));
                    strcpy (s, "Add Commands to I/NFM");
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


        /*  Position the cursor into the command_name field  */

        status = (long) FIfld_pos_cursor (WFFglobal.current_form,
                                          CMD_NAME_FIELD, 0, 0, 0, 0, 0, 0);
        if (status != FI_SUCCESS)
         {
            _NFIdebug ((fname, "FIfld_pos_cursor = <%d>\n", status));
            _WFFfree_cmd_ptr (ptr);
	    WFFglobal.error_no = NFI_E_FORM;
	    ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_pos_cursor",
                            status);
	    _NFIdebug ((fname, " returning FAILURE\n"));
	    return (NFI_E_FORM);
         }

	_NFIdebug ((fname, " returning SUCCESS\n"));
	return (NFI_S_SUCCESS);
  }



long _WFFadd_commands_notify (g_label, value, form)
  int		g_label;
  double	value;
  Form		form;
  {
	long	        status = NFI_S_SUCCESS;

	WFFcmd_ptr	ptr;

	static	char *fname = "_WFFadd_commands_notify";

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

			/*  Put up a message  */

			_WFFmessage (WFFglobal.working_no, NULL);

/*
                        status = _WFFcheck_cmd_data (form, ptr);
                        if (status != NFI_S_SUCCESS)
                         {
                            _NFIdebug ((fname,"_WFFcheck_cmd_data = <0x%.8x>\n",
                                        status));
	                    _NFIdebug ((fname, " returning FAILURE\n"));
	                    return (status);
	                 }
*/

			/*  Call NFM or WFG to do the command  */

			_NFIdebug ((fname, "calling WFGprocess_commands...\n"));

                        status = WFGprocess_commands (ptr->num_cmds,
                                                      ptr->cmd_list);

                        if (status != NFM_S_SUCCESS) 
			    _NFIdebug((fname,"WFGprocess_commands = <0x%.8x>\n",
                                       status));

			/*  Erase the message  */

			_WFFerase_message ();

			/*  Save the return status  */

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

                  case CMD_NAME_FIELD:

                       status = _WFFcmd_name_field (form, g_label, ptr);
                       if (status != NFI_S_SUCCESS)
                        {
                           _NFIdebug ((fname, "_WFFname_field = <0x%.8x>\n",
                                       status));
	                   /* _NFIdebug ((fname, " returning FAILURE\n"));
                           return (status); */
	                }
		  break;

                  case CMD_APP_FIELD:
                       /* I/Forms will handle this (associated list/variable) */

			_NFIdebug ((fname, "Description Field\n"));
		  break;

                  case CMD_ENTITY_FIELD:
                        /* I/Forms will handle this (associated list/fixed) */

			_NFIdebug ((fname, "Description Field\n"));
		  break;

                  case TRANS_CMD_TOGGLE:
                        /* this will be handled in ADD */
			_NFIdebug ((fname, "Transition Command Toggle\n"));
		  break;

                  case CMDS_LIST_MCF:
                        /* This will be handled in Add and Delete */
			_NFIdebug ((fname, "CMDS_LIST_MCF\n"));
		  break;

                  case ADD_CMD_BUTTON:
                        status = _WFFadd_cmds (form, CMD_NAME_FIELD, ptr);
                        if (status != NFI_S_SUCCESS) 
			_NFIdebug ((fname,
                             "WFFadd_commands : status = <0x%.8x\n", status));
		  break;

                  case DELETE_CMD_BUTTON:
                        status = _WFFdelete_cmds (form, CMDS_LIST_MCF, ptr);
                        if (status != NFI_S_SUCCESS) 
			_NFIdebug ((fname,
                             "WFFadd_commands : status = <0x%.8x\n", status));
		  break;
	  }

	_NFIdebug ((fname, " returning <0x%.8x>\n", status));
	return (status);
  }


long _WFFcmd_name_field  (form, g_label, ptr)
   Form        form; 
   int         g_label;
   WFFcmd_ptr  ptr;
  { 
     long  status; 
     int   i, length;
     char  text[108];

     static char *fname = "_WFFname_field";

     strcpy (text, "");
     length = 100;

     status = _WFFget_data_from_field (form, g_label, 0, 0, text, length); 
     if (status != NFI_S_SUCCESS)
      {
         _NFIdebug ((fname, "WFFget_data_from_field = <%d>\n", status));
         _NFIdebug ((fname, " returning <0x%.8x>\n", status));
	 return (status);
      }

     /* Check to see if the command name is a duplicate, if it is clear out the
        field and send a warning to the user,  otherwise add the command to
        the cmd_list                                                        */

/* IGI Intel Solaris Port - CN 31/5/95 */
#if defined(OS_SCO_UNIX)|| defined(OS_INTELSOL)
     /* wrok around change - to set font for SCO - SSRS 16 Feb 94 */
     FIg_set_font( WFFglobal.current_form, g_label, "7x13bold", 15 );
#endif
     for (i = 0; i < ptr->num_cmds; ++i)
      {
          if ((strcmp (ptr->cmd_list[i].command_name, text) == 0) &&
              (strcmp (ptr->cmd_list[i].status, WFF_DROP) != 0)) 
          {
             /* set the command_name field to "" */ 

             status = (long) FIfld_set_text (form, g_label, 0, 0,
                                             "", FALSE);
             if (status != FI_SUCCESS)
              {
                 _NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
                 ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_text",
                                 status);
                 _NFIdebug ((fname, " returning FAILURE\n"));
                 return (NFI_E_FORM);
              }

             /* send warning msg to user and return */

             _WFFmessage (NFI_W_DUPLICATE_COMMAND_NAME, "%s", text);
             return (NFI_S_SUCCESS);
          }
      }

     status = NFI_S_SUCCESS;
     _NFIdebug ((fname, " returning <0x%.8x>\n", status));
     return (status);
  }


long _WFFload_cmds_in_list (data_list, ptr)
   MEMptr      data_list;
   WFFcmd_ptr  ptr;
  {
     long  status;
     int   i, rows, cols, length;
     char  **data;

     static char *fname = "_WFFload_cmds_in_list";

     _NFIdebug ((fname, " Number Commands = <%d>\n", data_list->rows));

     if (data_list)
      {
         rows = data_list->rows;
         cols = data_list->columns;
         data = (char **) data_list->data_ptr;
         if (ptr->cmd_list)
           free ((struct WFFcommand_st *) ptr->cmd_list);
         
         _NFIdebug ((fname, " Malloc memory for the cmd_list\n"));

         /* malloc memory for the list */

         ptr->cmd_list = (struct WFFcommand_st *) malloc (rows * 
                            sizeof (struct WFFcommand_st));
         if (!ptr->cmd_list)
          {
             _NFIdebug ((fname, "Malloc : bytes = <%d>\n",
                         rows * sizeof (struct WFFcommand_st)));
             WFFglobal.error_no = NFI_E_FORM;
             ERRload_struct (NFI, NFI_E_MALLOC, "%d",
                                     rows * sizeof (struct WFFcommand_st));
             _NFIdebug ((fname, " returning FAILURE\n"));
             return (NFI_E_MALLOC);
          }

         _NFIdebug ((fname, " Put the data into the cmd_list\n"));

         /* put the data into the cmd_list */

         length = 40;

         for (i = 0; i < rows; ++i)
          {
             strcpy (ptr->cmd_list[i].command_name, data[cols * i]);
             strcpy (ptr->cmd_list[i].app_name,     data[cols * i + 1]); 
             strcpy (ptr->cmd_list[i].entity,       data[cols * i + 2]);
             strcpy (ptr->cmd_list[i].trans_cmd,    data[cols * i + 3]);
             strcpy (ptr->cmd_list[i].nfm_cmd_no,   data[cols * i + 4]);
             strcpy (ptr->cmd_list[i].status,       ""); 
          }

         ptr->num_cmds = rows;
      }
      
     status = NFI_S_SUCCESS;
     _NFIdebug ((fname, " returning <0x%.8x>\n", status));
     return (status);
  }


long _WFFinsert_cmd (form, g_label, row, cmd_st)
     Form    form;
     int     g_label; 
     int     row;
     struct  WFFcommand_st cmd_st;
  {
     long  status;

     static char *fname = "_WFFinsert_cmd";

/* IGI Intel Solaris Port - CN 31/5/95 */
#if defined(OS_SCO_UNIX) || defined(OS_INTELSOL)
     /* wrok around change - to set font for SCO - SSRS 16 Feb 94 */
     FIg_set_font( WFFglobal.current_form, g_label, "7x13bold", 15 );
#endif

     /* call forms function to put the command in the list. */ 

     status = (long) FIfld_set_text (form, g_label, row, 0,
                                     cmd_st.command_name, FALSE);
     if (status != FI_SUCCESS)
      {
          _NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
          ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_text", status);
          _NFIdebug ((fname, " returning FAILURE\n"));
          return (NFI_E_FORM);
      }

     status = (long) FIfld_set_text (form, g_label, row, 1,
                                     cmd_st.app_name, FALSE);
     if (status != FI_SUCCESS)
      {
          _NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
          ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_text", status);
          _NFIdebug ((fname, " returning FAILURE\n"));
          return (NFI_E_FORM);
      }

     status = (long) FIfld_set_text (form, g_label, row, 2,
                                     cmd_st.entity, FALSE);
     if (status != FI_SUCCESS)
      {
          _NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
          ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_text", status);
          _NFIdebug ((fname, " returning FAILURE\n"));
          return (NFI_E_FORM);
      }

     status = (long) FIfld_set_text (form, g_label, row, 3,
                                     cmd_st.trans_cmd, FALSE);
     if (status != FI_SUCCESS)
      {
          _NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
          ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_text", status);
          _NFIdebug ((fname, " returning FAILURE\n"));
          return (NFI_E_FORM);
      }

     status = (long) FIfld_set_text (form, g_label, row, 4,
                                     cmd_st.nfm_cmd_no, FALSE);
     if (status != FI_SUCCESS)
      {
          _NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
          ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_text", status);
          _NFIdebug ((fname, " returning FAILURE\n"));
          return (NFI_E_FORM);
      }

     status = NFI_S_SUCCESS;
     _NFIdebug ((fname, " returning <0x%.8x>\n", status));
     return (status);
  }



long _WFFput_cmds_in_list (form, g_label, num_cmds, cmd_list)
     Form                 form;
     int                  g_label; 
     int                  num_cmds;
     struct WFFcommand_st cmd_list[];
  {
     long  status;
     int   i, k;

     static char *fname = "_WFFput_cmds_in_list";

     _NFIdebug ((fname, " num_cmds = <%d>\n", num_cmds));

     k = 0;

/* IGI Intel Solaris Port - CN 31/5/95 */
#if defined(OS_SCO_UNIX) || defined(OS_INTELSOL)
     /* wrok around change - to set font for SCO - SSRS 16 Feb 94 */
     FIg_set_font( form, g_label, "7x13bold", 15 );
#endif

     for (i = 0; i < num_cmds; ++i)
      {
         if (strcmp (cmd_list[i].status, WFF_DROP) != 0)
          {
             status = _WFFinsert_cmd (form, g_label, k, cmd_list[i]);
             if (status != NFI_S_SUCCESS)
              {
                 _NFIdebug ((fname, " WFFinsert_cmd = <0x%.8x>\n", status));
                 _NFIdebug ((fname, " returning FAILURE\n"));
                 return (status);
              }
             ++k;
          }
      } 
      
     status = NFI_S_SUCCESS;
     _NFIdebug ((fname, " returning <0x%.8x>\n", status));
     return (status);
  }


long _WFFadd_cmds (form, g_label, ptr)
     Form        form;
     int         g_label;   /* CMD_NAME_FIELD */
     WFFcmd_ptr  ptr;
  {
     long   status;
     int    rows, length = 100, i, j, g_state;
     char   command_name[101];
     char   app_name[8];
     char   trans_cmd[8];
     char   entity [16];
     char   nfm_cmd_no[16];

     static char *fname = "_WFFadd_cmds";

     strcpy (command_name, "");
     strcpy (app_name, "NFM");
     strcpy (trans_cmd, "N");
     strcpy (entity, "I");
     strcpy (nfm_cmd_no, "null");

     /* get the command_name from the CMD_NAME_FIELD */

     status = _WFFget_data_from_field (form, g_label, 0, 0, command_name,
                                       length);
     if (status != NFI_S_SUCCESS)
      {
         _NFIdebug ((fname, " WFFget_data_from_field = <0x%.8x>\n", status));
         _NFIdebug ((fname, " returning FAILURE\n"));
         return (status);
      }

     /* If the command_name is null, send a warning to user */ 
     if (strcmp (command_name, "") == 0)
      {
        /* Put up a message warning the user that command name is null */

        _WFFmessage (NFI_W_NULL_COMMAND_NAME, NULL);
        return (NFI_S_SUCCESS);
      } 
   
/* IGI Intel Solaris Port - CN 31/5/95 */
#if defined(OS_SCO_UNIX) || defined(OS_INTELSOL)
     /* wrok around change - to set font for SCO - SSRS 16 Feb 94 */
     FIg_set_font( WFFglobal.current_form, g_label, "7x13bold", 15 );
#endif

     /* check to see if the row is a duplicate : if it is exit, send warning */

     if (ptr->cmd_list != NULL)
      {
        for (i = 0; i < ptr->num_cmds; ++i)
         {
             if ((strcmp (ptr->cmd_list[i].command_name, command_name) == 0) &&
                 (strcmp (ptr->cmd_list[i].status, WFF_DROP) != 0)) 
              {
                  /* Clear out the command_name field */
   
                  status = (long) FIfld_set_text (form, g_label, 0, 0, 
                                                  "", FALSE);
                  if (status != FI_SUCCESS)
                   {
                      _NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
                      ERRload_struct (NFI, NFI_E_FORM, "%s%d",
                                      "FIfld_set_text", status);
                      _NFIdebug ((fname, " returning FAILURE\n"));
                      return (NFI_E_FORM);
                   } 
   
                  /* Put up a message warning that command is a duplicate */
   
                  _WFFmessage (NFI_W_DUPLICATE_COMMAND_NAME, "%s",
                               command_name);
   
                  return (NFI_S_SUCCESS);
              }  
         }
      }

     strcpy (trans_cmd, "N");

     /* get the state_desc from the CMD_APP_FIELD */

     status = _WFFget_data_from_field (form, CMD_APP_FIELD, 0, 0, app_name, 3);
     if (status != NFI_S_SUCCESS)
      {
         _NFIdebug ((fname, " WFFget_data_from_field = <0x%.8x>\n", status));
         _NFIdebug ((fname, " returning FAILURE\n"));
         return (status);
      }

     /* get the entity from the CMD_ENTITY_FIELD */

     status = _WFFget_data_from_field (form, CMD_ENTITY_FIELD, 0, 0,
                                       entity, 11);
     if (status != NFI_S_SUCCESS)
      {
         _NFIdebug ((fname, " WFFget_data_from_field = <0x%.8x>\n",
                     status));
         _NFIdebug ((fname, " returning FAILURE\n"));
         return (status);
      }

     /* get the gadget state for the transition command toggle */

      status = (long) FIg_get_state (form, TRANS_CMD_TOGGLE, &g_state);
      if (status != FI_SUCCESS)
       {
          _NFIdebug ((fname, "FIg_get_state = <%d>\n", status));
          ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_get_state",
                          status);
          _NFIdebug ((fname, " returning FAILURE\n"));
       }
 
       if (g_state)
             strcpy (trans_cmd, "Y");

      _NFIdebug ((fname, "reallocate memory for cmd_list\n"))
      _NFIdebug ((fname, " ptr->num_cmds = <%d>\n", ptr->num_cmds))

      rows = ptr->num_cmds + 1;

      /* reallocate memory for the list */
 
      ptr->cmd_list = (struct WFFcommand_st *) realloc (ptr->cmd_list,
                         rows * sizeof (struct WFFcommand_st));
      if (!ptr->cmd_list)
       {
          _NFIdebug ((fname, "Realloc : bytes = <%d>\n",
                      rows * sizeof (struct WFFcommand_st)));
          ERRload_struct (NFI, NFI_E_MALLOC, "%d",  
                          rows * sizeof (struct WFFcommand_st));
          _NFIdebug ((fname, " returning FAILURE\n"));
          return (NFI_E_MALLOC);
       }
    
      strcpy (ptr->cmd_list[rows -1].command_name, command_name); 
      strcpy (ptr->cmd_list[rows -1].app_name,     app_name); 
      strcpy (ptr->cmd_list[rows -1].entity,       entity); 
      strcpy (ptr->cmd_list[rows -1].trans_cmd,    trans_cmd); 
      strcpy (ptr->cmd_list[rows -1].nfm_cmd_no,   nfm_cmd_no); 
      strcpy (ptr->cmd_list[rows -1].status,       WFF_ADD); 
      ptr->num_cmds = rows;
    
     /* get the num_rows in the CMDS_LIST_MCF (I/FORMS returns invalid info */

/* IGI Intel Solaris Port - CN 31/5/95 */
#if defined(OS_SCO_UNIX) || defined(OS_INTELSOL)
     /* wrok around change - to set font for SCO - SSRS 16 Feb 94 */
     FIg_set_font( WFFglobal.current_form, CMDS_LIST_MCF, "7x13bold", 15);
#endif

     j = 0;
     for (i = 0; i < ptr->num_cmds; ++i)
      {
         if (strcmp (ptr->cmd_list[i].status, WFF_DROP) != 0)
           ++j;
      }

     /* add the command to the CMDS_LIST_MCF */

/* IGI Intel Solaris Port - CN 31/5/95 */
#if defined(OS_SCO_UNIX) || defined(OS_INTELSOL)
     /* wrok around change - to set font for SCO - SSRS 16 Feb 94 */
     FIg_set_font( form, CMDS_LIST_MCF, "7x13bold", 15 );
#endif

     status = (long) FIfld_set_text (form, CMDS_LIST_MCF, j - 1, 0, 
                                     command_name, FALSE);
     if (status != FI_SUCCESS)
      {
         _NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
         ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_text",
                         status);
         _NFIdebug ((fname, " returning FAILURE\n"));
         return (NFI_E_FORM);
      } 

     status = (long) FIfld_set_text (form, CMDS_LIST_MCF, j - 1, 1, 
                                     app_name, FALSE);
     if (status != FI_SUCCESS)
      {
         _NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
         ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_text",
                         status);
         _NFIdebug ((fname, " returning FAILURE\n"));
         return (NFI_E_FORM);
      } 

     status = (long) FIfld_set_text (form, CMDS_LIST_MCF, j - 1, 2, 
                                     entity, FALSE);
     if (status != FI_SUCCESS)
      {
         _NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
         ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_text",
                         status);
         _NFIdebug ((fname, " returning FAILURE\n"));
         return (NFI_E_FORM);
      } 

     status = (long) FIfld_set_text (form, CMDS_LIST_MCF, j - 1, 3, 
                                     trans_cmd, FALSE);
     if (status != FI_SUCCESS)
      {
         _NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
         ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_text",
                         status);
         _NFIdebug ((fname, " returning FAILURE\n"));
         return (NFI_E_FORM);
      } 

     status = (long) FIfld_set_text (form, CMDS_LIST_MCF, j - 1, 4, 
                                     "", FALSE);
     if (status != FI_SUCCESS)
      {
         _NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
         ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_text",
                         status);
         _NFIdebug ((fname, " returning FAILURE\n"));
         return (NFI_E_FORM);
      } 

     /* Clear out the command fields and reset toggles */
/* IGI Intel Solaris Port - CN 31/5/95 */
#if defined(OS_SCO_UNIX) || defined(OS_INTELSOL)
     /* wrok around change - to set font for SCO - SSRS 16 Feb 94 */
     FIg_set_font( WFFglobal.current_form, g_label, "7x13bold", 15 );
     FIg_set_font( WFFglobal.current_form, CMD_APP_FIELD, "7x13bold", 15 );
     FIg_set_font( WFFglobal.current_form, CMD_ENTITY_FIELD, "7x13bold", 15 );
#endif
   
     FIfld_set_text (form, g_label, 0, 0, "", FALSE);
     FIfld_set_text (form, CMD_APP_FIELD, 0, 0, "NFM", FALSE);
     FIfld_set_text (form, CMD_ENTITY_FIELD, 0, 0, "I", FALSE);
     FIg_set_state (form, TRANS_CMD_TOGGLE, 0);

     /* set the active row to reflect the new row */

     _WFFset_active_row (form, CMDS_LIST_MCF, j -1, 1);
   
     status = NFI_S_SUCCESS;
     _NFIdebug ((fname, " returning <0x%.8x>\n", status));
     return (status);
  }


long _WFFdelete_cmds (form, g_label, ptr)
     Form        form;
     int         g_label; 
     WFFcmd_ptr  ptr;
  {
     long   status;
     int    i, j, k, rows, l_rows, sel_flag;
     int    length = 100;
     int    *delete_list = NULL;
     char   command_name[101];
     short  delete = FALSE; 
     short  c_warning = FALSE, d_state = TRUE; 

     static char *fname = "_WFFdelete_cmds";

     /* get the num_rows in the CMD_LIST_MCF */

     status = (long) FIfld_get_num_rows (form, g_label, &rows); 
     if (status != FI_SUCCESS)
      {
         _NFIdebug ((fname, "FIfld_get_num_rows = <%d>\n", status));
         ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_get_num_rows", status);
         _NFIdebug ((fname, " returning FAILURE\n"));
         return (NFI_E_FORM);
      } 
     _NFIdebug ((fname, "Number rows in CMD_LIST_MCF = <%d>\n", rows));

     if (rows == 0)
      {
         _WFFmessage (NFI_W_NO_COMMANDS_SELECTED, NULL);
         _NFIdebug ((fname, "No rows exist in the CMD_LIST_MCF\n"));
         return (NFI_S_SUCCESS);
      } 

     delete_list = (int *) malloc (rows * sizeof (int));
     if (!delete_list)
      {
         _NFIdebug ((fname, "Malloc : bytes = <%d>\n", rows * sizeof (int)));
         ERRload_struct (NFI, NFI_E_MALLOC, "%d", rows * sizeof (int));
         _NFIdebug ((fname, " returning FAILURE\n"));
         return (NFI_E_MALLOC);
      }

     for (i = 0;  i < rows; ++i)
        delete_list[i] = FALSE; 

     if (ptr->cmd_list != NULL)
      {
        for (i = 0; i < rows; ++i)
         {
             /* See if this command is selected for deletion */

             status = (long) FIfld_get_select (form, g_label, i, 0, &sel_flag); 
             if (status != FI_SUCCESS)
              {
                 free ((int *) delete_list);
                 _NFIdebug ((fname, "FIfld_get_select = <%d>\n", status));
                 ERRload_struct (NFI, NFI_E_FORM, "%s%d",
                                 "FIfld_get_select", status);
                 _NFIdebug ((fname, " returning FAILURE\n"));
                 return (NFI_E_FORM);
              } 
   
             if (sel_flag)
              {
                 delete_list[i] = TRUE;
                 delete = TRUE;
              }
          }

         for (i = 0;  i < rows; ++i)
             _NFIdebug ((fname, "delete_list[%d] = <%d>\n", i, delete_list[i]));
                  
         if (delete) 
          {
             /*  Delete the rows from the ptr->cmd_list */ 

             for (i = 0; i < rows; ++i)
              {
                 if (delete_list[i])
                  { 
                    d_state = TRUE;
                    strcpy (command_name, "");

                    /* get the command_name from the COMMAND_LIST_MCF */
                    
                    status = _WFFget_data_from_field (form, g_label, i, 0,
                                                      command_name, length);
                    if (status != NFI_S_SUCCESS)
                     {
                        free ((int *) delete_list);
                        _NFIdebug ((fname,
                             " WFFget_data_from_field = <0x%.8x>\n", status));
                        _NFIdebug ((fname, " returning FAILURE\n"));
                        return (status);
                     }

                    /* check to see if the command is being used in a wf 
                       if it is set c_warning to TRUE and do not delete the
                       command                                           */ 

                    status = _WFGcheck_command_in_use (0, command_name);
                    if ((status != NFM_I_COMMAND_IN_USE) &&
                        (status != NFM_I_COMMAND_NOT_IN_USE))
                     {
                        free ((int *) delete_list);
                        _NFIdebug ((fname,
                             " WFGcheck_command_in_use = <0x%.8x>\n", status));
                        _NFIdebug ((fname, " returning FAILURE\n"));
                        return (status);
                     }

                    if (status == NFM_I_COMMAND_IN_USE) 
                     {
                         c_warning = TRUE;
                         d_state = FALSE;
                         delete_list[i] = FALSE;
                         _NFIdebug ((fname, " The command is in use\n"));
                     }

                    if (!d_state)
                       continue;

                    /* find the command in the cmd_list */
                    
                    l_rows = ptr->num_cmds;

                    for (k = 0; k < l_rows; ++k)
                     {
                        if ((strcmp (ptr->cmd_list[k].command_name,
                                     command_name) == 0) &&
                            (strcmp (ptr->cmd_list[k].status, WFF_DROP) != 0))
                         {
                            /* If cmd does not exist in database, drop it */
                            /* otherwise mark it for deletion               */
                           
                            if (!strcmp (ptr->cmd_list[k].status, WFF_ADD)) 
                             {
                               /* move/shift all values up by 1 */
                    
                               for (j = k; j < l_rows - 1; ++j)
                                   ptr->cmd_list[j] = ptr->cmd_list[j + 1];
                       
                               /* delete the command from the cmd_list */
      
                               if (l_rows == 1)
                                {
                                   free((struct WFFcommand_st *) ptr->cmd_list);
                                   ptr->cmd_list = NULL;
                                } 
                               else
                                {
                                   ptr->cmd_list = (struct WFFcommand_st *) \
                                         realloc (ptr->cmd_list, (l_rows -1) *
                                         sizeof (struct WFFcommand_st));
                                   if (!ptr->cmd_list)
                                    {
                                       free ((int *) delete_list);
                                       _NFIdebug ((fname,
                                                   "Realloc : bytes = <%d>\n",
                                       l_rows * sizeof (struct WFFcommand_st)));
                                       ERRload_struct (NFI, NFI_E_MALLOC, "%d",
                                       l_rows * sizeof (struct WFFcommand_st));
                                       _NFIdebug ((fname,
                                                   " returning FAILURE\n"));
                                       return (NFI_E_MALLOC);
                                    }
                                } 
                               --ptr->num_cmds;
                             } 
                            else
                                strcpy (ptr->cmd_list[k].status, WFF_DROP);
                            break;
                         }
                     }
                  }
              }

             /* delete the commands from the CMDS_LIST_MCF */

             j = 0;

             for (i = 0; i < rows; ++i)
              {
                 if (delete_list[i])
                  { 
                     status = (long) FIfld_delete_rows (form, g_label,  
                                                        i - j, 1);
                     if (status != FI_SUCCESS)
                      {
                         free ((int *) delete_list);
                         _NFIdebug ((fname, "FIfld_delete_rows = <%d>\n", status));
                         ERRload_struct (NFI, NFI_E_FORM, "%s%d",
                                         "FIfld_delete_rows", status);
                         _NFIdebug ((fname, " returning FAILURE\n"));
                         return (NFI_E_FORM);
                      } 
                     ++j;
                  }
              }
         }
      }
     free ((int *) delete_list);

     if (!delete)
      { 
         ptr->done = NO_ACTIVITY ; 
         _WFFmessage (NFI_W_NO_COMMANDS_SELECTED, NULL);
      }
     else if (c_warning)
      { 
         ptr->done = COMMAND_IN_USE; 
         _WFFmessage (NFI_W_COMMAND_IN_USE, NULL);
      }
     else
      { 
         ptr->done = FALSE; 
      }

     status = NFI_S_SUCCESS;
     _NFIdebug ((fname, " returning <0x%.8x>\n", status));
     return (status);
  }


void _WFFfree_cmd_ptr (ptr)
  WFFcmd_ptr ptr;
  {
    static char *fname = "_WFFfree_cmd_ptr";

    _NFIdebug ((fname, " function entered.\n"));

    if (WFFglobal.current_form)
     {
        FIf_delete (WFFglobal.current_form);
        WFFglobal.current_form = NULL;
     } 

    if (ptr)
     {
        if (ptr->cmd_list)
           free ((struct WFFcommand_st *) ptr->cmd_list);   

       free (ptr);
       ptr = NULL;
     }

    _NFIdebug ((fname, " function exited.\n"));
    return;
  }


long _WFFadjust_cmd_form (form)
  Form  form;
  {
        long    status;
        static  char *fname = "_WFFadjust_cmd_form";

        if ((status = _WFFcenter_gadget (form, TITLE1)) != NFI_S_SUCCESS)
          {
                _NFIdebug ((fname, "_WFFcenter_gadget = <0x%.8x>\n", status));
                _NFIdebug ((fname, " returning FAILURE\n"));
                return (status);
          }

        if ((status = _WFFcenter_form (form, -1, Y_FORM_POS)) != NFI_S_SUCCESS)
          {
                _NFIdebug ((fname, "_WFFcenter_form = <0x%.8x>\n", status));
                _NFIdebug ((fname, " returning FAILURE\n"));
                return (status);
          }

        _NFIdebug ((fname, " returning SUCCESS\n"));
        return (NFI_S_SUCCESS);
  }

