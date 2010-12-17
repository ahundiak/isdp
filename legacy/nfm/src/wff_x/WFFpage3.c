#include "machine.h"
#include "WFF.h"
#include "WFFadd_wf.h"
#include "WFFlist.h"
#include "WFFpage3.h"

/*  Global WFF structure  */

extern struct WFFglobal_st WFFglobal;

/********************************************************************
 *                                                                  * 
 *  Function : WFFpage3                                             *
 *                                                                  * 
 *                                                                  * 
 ********************************************************************/

long _WFFpage3 (ptr)
    WFFadd_ptr   ptr;  
  {
	long	status, m_status;
        int     i, num_rows = 0;
        char    s[256];
        char    command_name[48];
        char    trans_name[48];
        char    from_state[48];
        char    to_state[48];
        char    logon_success[48];
        char    logon_failure[48];
        char    notify[48];
        char    **data;
        MEMptr  attr_list = NULL;
        MEMptr  data_list = NULL;
	static	char *fname = "_WFFpage3";

        _NFIdebug ((fname, " Function Entered\n"));

        /* Put up a message */

        _WFFmessage (NFI_I_RETRIEVE, NULL);  /* Retrieving data from server */

        strcpy (command_name, "Command Name");
        strcpy (trans_name, "Transition Name");
        strcpy (from_state, "From State");
        strcpy (to_state, "To State");
        strcpy (logon_success, "Logon Success");
        strcpy (logon_failure, "Logon Failure");
        strcpy (notify, "Notify on Transition");

        if ((strcmp (ptr->existing_wf_name, "")) ||
            (strcmp (ptr->old_wf_name, "")) ||
            (strcmp (ptr->workflow_name, ""))) 
         {
            /* Get the long list of transitions */

            if (ptr->num_trans == 0)
             {
                /* Get the long list of transitions 7 cols will be returned */

                if (strcmp (ptr->old_wf_name, "")) 
                   status = WFGn_list_transitions (ptr->old_wf_name, 
                                                   &attr_list, &data_list);
                else
                   status = WFGn_list_transitions (ptr->existing_wf_name,
                                                   &attr_list, &data_list);
                if ((status != NFM_S_SUCCESS) &&
                    (status != NFM_E_NO_TRANSITIONS_DEFINED))
                 {
                    MEMclose (&attr_list);
                    MEMclose (&data_list);
   	            _NFIdebug ((fname, "WFGn_list_transitions = <0x%.8x>\n",
                                status));
                    _WFFerase_message ();
	            _WFFfree_add_ptr (ptr);
                    return (status);
                 }

                /* get the synonyms */

                m_status = MEMbuild_array (attr_list);
                if (m_status != MEM_S_SUCCESS) 
	         {
                    MEMclose (&attr_list); 
                    MEMclose (&data_list); 
		    _NFIdebug ((fname, "MEMbuild_array = <0x%.8x>\n",
                                m_status));
                    _WFFerase_message ();
		    _WFFfree_add_ptr (ptr);
		    _NFIdebug ((fname, " returning <0x%.8x>\n",
                                NFI_E_MEM));
		    return (NFI_E_MEM);
	         }
/*
                if (WFFglobal.debug_on)
                 {
                    MEMprint_buffer ("attr_list", attr_list,  
                                     WFFglobal.debug_file);
                 }
*/
                data = (char **) attr_list->data_ptr;

                if (strcmp (data[2], ""))
                   strcpy (command_name, data[2]);

                if (strcmp (data[1], ""))
                   strcpy (trans_name, data[1]);

                if (strcmp (data[3], ""))
                   strcpy (from_state, data[3]);

                if (strcmp (data[4], ""))
                   strcpy (to_state, data[4]);

                if (strcmp (data[5], ""))
                   strcpy (logon_success, data[5]);

                if (strcmp (data[6], ""))
                   strcpy (logon_failure, data[6]);

                if (strcmp (data[7], ""))
                   strcpy (notify, data[7]);
    
                MEMclose (&attr_list);
                attr_list = NULL;
        
                if (status == NFM_S_SUCCESS)
                 {
                    /* Prepare the data buffer for reading */
        
                    status = MEMbuild_array (data_list);
                    if (status != MEM_S_SUCCESS) 
	             {
                        MEMclose (&data_list); 
		        _NFIdebug ((fname, "MEMbuild_array = <0x%.8x>\n",
                                    status));
                        _WFFerase_message ();
		        _WFFfree_add_ptr (ptr);
		        _NFIdebug ((fname, " returning <0x%.8x>\n",
                                    NFI_E_MEM));
		        return (NFI_E_MEM);
	              }
        
/*
                     if (WFFglobal.debug_on)
                      {
                        MEMprint_buffer ("transition_list", data_list,
                                         WFFglobal.debug_file);
                      }
*/
                     /* Put the data into the trans_list (array of strucs) */

                     status = _WFFload_transitions_in_list (data_list, ptr);
                     if (status != NFI_S_SUCCESS) 
	              {
                         MEMclose (&data_list); 
		         _NFIdebug ((fname,
                           "WFFload_transitions_in_list = <0x%.8x>\n", status));
                         _WFFerase_message ();
		         _WFFfree_add_ptr (ptr);
		         _NFIdebug ((fname, " returning <0x%.8x>\n", status));
		          return (status);
	              }
                 }

                MEMclose (&data_list);
                data_list = NULL;
             }

            if (ptr->num_states == 0)
             {
                 /* Get the long list of states 7 columns will be returned. */

                if (strcmp (ptr->old_wf_name, ""))
                   status = WFGn_list_states (ptr->old_wf_name, 
                                              &attr_list, &data_list);
                else
                   status = WFGn_list_states (ptr->existing_wf_name, 
                                              &attr_list, &data_list);
                if ((status != NFM_S_SUCCESS) &&
                    (status != NFM_E_NO_STATES_DEFINED))
                 {
                    MEMclose (&attr_list);
                    MEMclose (&data_list);
                    _NFIdebug ((fname, "WFGn_list_states = <0x%.8x>\n",
                                status));
                    _WFFerase_message ();
                    _WFFfree_add_ptr (ptr);
                    return (status);
                 }

                MEMclose (&attr_list);
                attr_list = NULL;

                if (status == NFM_S_SUCCESS)
                 {
                     /* Prepare the data buffer for reading */

                    status = MEMbuild_array (data_list);
                    if (status != MEM_S_SUCCESS)
                     {
                        MEMclose (&data_list);
                        _NFIdebug ((fname, "MEMbuild_array = <0x%.8x>\n",
                                    status));
                        _WFFerase_message ();
                        _WFFfree_add_ptr (ptr);
                        _NFIdebug ((fname, " returning <0x%.8x>\n", NFI_E_MEM));
                        return (NFI_E_MEM);
                     }
/*
                    if (WFFglobal.debug_on)
                     {
                        MEMprint_buffer ("data_list", data_list,
                                         WFFglobal.debug_file);
                     }
  
*/                  
                     /* Put the data into the state_list (array of strucs) */

                     status = _WFFload_states_in_list (data_list, ptr);
                     if (status != NFI_S_SUCCESS)
                      {
                         MEMclose (&data_list);
                         _NFIdebug ((fname,
                               "WFFload_states_in_list = <0x%.8x>\n", status));
                         _WFFerase_message ();
                         _WFFfree_add_ptr (ptr);
                         _NFIdebug ((fname, " returning <0x%.8x>\n", status));
                          return (status);
                      }
                 }

                MEMclose (&data_list);
                data_list = NULL;
             }
         }

       /* if the existing workflow name is given get the commands */
        
       if (!ptr->comm_list)
        {
           /* Get all the commands in the system */
      
           status = WFGlist_commands_short ("", "", &attr_list,  
                                            &(ptr->comm_list));
           if (status != NFM_S_SUCCESS)
            {
               MEMclose (&attr_list);
               attr_list = NULL; 
               _NFIdebug ((fname, "WFGlist_commands_short = <0x%.8x>\n",
                           status));
               _WFFerase_message ();
	       _WFFfree_add_ptr (ptr);
               _NFIdebug ((fname, " returning FAILURE\n"));
               return (status);
            }

           MEMclose (&attr_list);
           attr_list = NULL; 
      
           /* Prepare the comm_list for reading */
         
           status = MEMbuild_array (ptr->comm_list);
           if (status != MEM_S_SUCCESS) 
            {
               _NFIdebug ((fname, "MEMbuild_array = <0x%.8x>\n", status));
               _WFFerase_message ();
	       _WFFfree_add_ptr (ptr);
	       _NFIdebug ((fname, " returning <0x%.8x>\n", NFI_E_MEM));
               return (NFI_E_MEM);
            }
        }

        if (ptr->page3_form == NULL)
         {
	    /*  Load in the PAGE3 form  */

	    if ((status = (long) FIf_new (PAGE3_LABEL, WF_PAGE3_FORM,
		    _WFFnotify, &(ptr->page3_form))) != FI_SUCCESS)
	     {
	        _NFIdebug ((fname, "FIf_new = <%d>\n", status));
                _WFFerase_message ();
	        _WFFfree_add_ptr (ptr);
	        WFFglobal.error_no = NFI_E_FORM;
	        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIf_new", status);
	        _NFIdebug ((fname, " returning FAILURE\n"));
	        return (NFI_E_FORM);
	     }

	    /*  Store a pointer to the data in the form  */
    
	    if ((status = (long) FIf_set_user_pointer
		    (ptr->page3_form, (char *) ptr)) != FI_SUCCESS)
             {
	        _NFIdebug ((fname, "FIf_set_user_pointer = <%d>\n", status));
                _WFFerase_message ();
	        _WFFfree_add_ptr (ptr);
	        WFFglobal.error_no = NFI_E_FORM;
	        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIf_set_user_pointer",
                                status);
	        _NFIdebug ((fname, " returning FAILURE\n"));
	        return (NFI_E_FORM);
	     }
    
            /* Set the maximum of characters allowed for the fields */
    
            status = (long) FIfld_set_max_num_chars (ptr->page3_form,
                                                     TRANS_NAME_FIELD, 0, 80);
            status = (long) FIfld_set_num_rows (ptr->page3_form,
                                                COMMAND_LIST_SCF, 0);
            status = (long) FIfld_set_num_rows (ptr->page3_form,
                                                FROM_STATE_LIST_SCF, 0);
            status = (long) FIfld_set_num_rows (ptr->page3_form,
                                                TO_STATE_LIST_SCF, 0);
            status = (long) FIfld_set_num_rows (ptr->page3_form,
                                                TRANS_LIST_MCF, 0);

            /* Clear out the transition field */

	    FIfld_set_text (ptr->page3_form,
                            TRANS_NAME_FIELD, 0, 0, "", FALSE);

            /* Put the transition synonyms into the synonyms MCF */

/* IGI Intel Solaris Port - CN 31/5/95 */
#if defined(OS_SCO_UNIX) || defined(OS_INTELSOL)
	/* To set font for SCO - CRN 25 Feb 94	*/
	FIg_set_font(ptr->page3_form, TRANS_SYNONYM_MCF, "7x13bold", 15);
#endif
            for (i = 0; i < 7; ++i)
             {
                switch (i)
                 {
                    case 0:
	               status = FIfld_set_text (ptr->page3_form,
                                 TRANS_SYNONYM_MCF, 0, i, trans_name, FALSE);
                    break;

                    case 1:
	               status = FIfld_set_text (ptr->page3_form,
                                 TRANS_SYNONYM_MCF, 0, i, command_name, FALSE);
                    break;

                    case 2:
	               status = FIfld_set_text (ptr->page3_form,
                                 TRANS_SYNONYM_MCF, 0, i, from_state, FALSE);
                    break;

                    case 3:
	               status = FIfld_set_text (ptr->page3_form,
                                 TRANS_SYNONYM_MCF, 0, i, to_state, FALSE);
                    break;

                    case 4:
	               status = FIfld_set_text (ptr->page3_form,
                                 TRANS_SYNONYM_MCF, 0, i, logon_success, FALSE);
                    break;

                    case 5:
	               status = FIfld_set_text (ptr->page3_form,
                                 TRANS_SYNONYM_MCF, 0, i, logon_failure, FALSE);
                    break;

                    case 6:
	               status = FIfld_set_text (ptr->page3_form,
                                 TRANS_SYNONYM_MCF, 0, i, notify, FALSE);
                    break;
                 }  

                if (status != FI_SUCCESS)
	         {
	            _NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
	            _WFFfree_add_ptr (ptr);
	            WFFglobal.error_no = NFI_E_FORM;
	            ERRload_struct (NFI, NFI_E_FORM, "%s%d",
                                    "FIfld_set_text", status);
	            _NFIdebug ((fname, " returning FAILURE\n"));
	            return (NFI_E_FORM);
	         }
             }

	    /*  Set the title  */
    
	    status = (long) UMSGetByNum (s, NFI_P_TRANSITION_DEF, "%s",
                                         ptr->workflow_name);  
	    if (status != UMS_S_SUCCESS)  
	     {
	        _NFIdebug ((fname, "UMSGetByNum = <0x%.8x>\n", status));
	        _NFIdebug ((fname, "defaulting title\n"));
                sprintf (s,  
                    "Define the transitions allowed in workflow \"%s\"",
                         ptr->workflow_name);
	     }
    
	    if ((status = (long) FIg_set_text
		           (ptr->page3_form, TITLE1, s)) != FI_SUCCESS)
	     {
	        _NFIdebug ((fname, "FIg_set_text = <%d>\n", status));
                _WFFerase_message ();
	        _WFFfree_add_ptr (ptr);
	        WFFglobal.error_no = NFI_E_FORM;
	        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_text",
                                status);
	        _NFIdebug ((fname, " returning FAILURE\n"));
	        return (NFI_E_FORM);
	     }

            /* link scrolling of TRANS_LIST_MCF to the TRANS_SYNONYM_MCF */ 
  
            status = (long) FImcf_set_scroll_link (ptr->page3_form,
                                             TRANS_LIST_MCF, TRANS_SYNONYM_MCF);
            if (status != FI_SUCCESS)
             {
                _NFIdebug ((fname, "FImcf_set_scroll_link = <%d>\n", status));
                _WFFfree_add_ptr (ptr);
                WFFglobal.error_no = NFI_E_FORM;
                ERRload_struct (NFI, NFI_E_FORM, "%s%d",
                                       "FImcf_set_scroll_link", status);
                _NFIdebug ((fname, " returning FAILURE\n"));
                return (NFI_E_FORM);
             }
    
/* IGI Intel Solaris Port - CN 31/5/95 */
#if defined(OS_SCO_UNIX) || defined(OS_INTELSOL)
	/* To set font for SCO - CRN 25 Feb 94	*/
	FIg_set_font(ptr->page3_form, TRANS_NAME_FIELD, "7x13bold" ,15);
#endif
            status = (long) FIfld_set_text (ptr->page3_form,
                                            TRANS_NAME_FIELD, 0, 0, "", FALSE);
            if (status != FI_SUCCESS)
             {
                _NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
                _WFFfree_add_ptr (ptr);
                WFFglobal.error_no = NFI_E_FORM;
                ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_text",
                                       status);
                _NFIdebug ((fname, " returning FAILURE\n"));
                return (NFI_E_FORM);
             }
         }

        status = (long) FIfld_set_num_rows (ptr->page3_form,
                                            TRANS_LIST_MCF, 0); 
        if (status != FI_SUCCESS)
         {
            _NFIdebug ((fname, "FIfld_set_num_rows = <%d>\n", status));
            _WFFfree_add_ptr (ptr);
            WFFglobal.error_no = NFI_E_FORM;
            ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_num_rows",
                            status);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_FORM);
         }
      
        /* Put the transitions into the list */ 
  
        status = _WFFput_transitions_in_list (ptr->page3_form,
                           TRANS_LIST_MCF, ptr->num_trans, ptr->trans_list);
        if (status != NFI_S_SUCCESS) 
         {
            _NFIdebug ((fname, "WFFput_transitions_in_list = <0x%.8x>\n",
                        status));
            _WFFerase_message ();
            _WFFfree_add_ptr (ptr);
            WFFglobal.error_no = status;
            _NFIdebug ((fname, " returning <0x%.8x>\n", status));
            return (status);
         }

        /* Put the states in the SCF */

        status = _WFFscf_put_states_in_list (ptr->page3_form,
                       FROM_STATE_LIST_SCF, ptr->num_states, ptr->state_list);
        if (status != NFI_S_SUCCESS) 
         {
            _NFIdebug ((fname, "_WFFscf_put_states_in_list = <0x%.8x>\n",
                            status));
            _WFFerase_message ();
            _WFFfree_add_ptr (ptr);
            WFFglobal.error_no = status;
            _NFIdebug ((fname, " returning <0x%.8x>\n", status));
            return (status);
         }

        status = _WFFscf_put_states_in_list (ptr->page3_form,
                        TO_STATE_LIST_SCF, ptr->num_states, ptr->state_list);
        if (status != NFI_S_SUCCESS) 
         {
            _NFIdebug ((fname, "_WFFscf_put_states_in_list = <0x%.8x>\n",
                        status));
            _WFFerase_message ();
            _WFFfree_add_ptr (ptr);
            WFFglobal.error_no = status;
            _NFIdebug ((fname, " returning <0x%.8x>\n", status));
            return (status);
         }

        /* Check to see if the commands have been placed in the SCF already */

        status = (long) FIfld_get_num_rows (ptr->page3_form,
                                            COMMAND_LIST_SCF, &num_rows); 
        if (status != FI_SUCCESS)
	 {
	     _NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
	     _WFFfree_add_ptr (ptr);
	     WFFglobal.error_no = NFI_E_FORM;
	     ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_text", status);
	     _NFIdebug ((fname, " returning FAILURE\n"));
	     return (NFI_E_FORM);
	 }
         
        if (num_rows <= 0)
         {
            status = _WFFput_data_in_list (ptr->page3_form,
                                     COMMAND_LIST_SCF, ptr->comm_list->columns,
                                     0, ptr->comm_list);
            if (status != NFI_S_SUCCESS) 
	     {
	        _NFIdebug ((fname, "_WFFput_data_in_list = <0x%.8x>\n",
                            status));
                _WFFerase_message ();
	        _WFFfree_add_ptr (ptr);
	        WFFglobal.error_no = status;
	        _NFIdebug ((fname, " returning <0x%.8x>\n", status));
	        return (status);
	     }
         }

        /* Erase the message */

        _WFFerase_message (); /* Erase "Retrieving data from server" msg */

        WFFglobal.current_form = ptr->page3_form;

	/*  Clear out the error message strip  */

	_WFFclear_msg (WFFglobal.current_form);

	/*  Adjust and Center the form */

	if ((status = _WFFadjust_wf_form
		                 (WFFglobal.current_form)) != NFI_S_SUCCESS)
	 {
	    _NFIdebug ((fname, "_WFFadjust_wf_form = <0x%.8x>\n", status));
	    _WFFfree_add_ptr (ptr);
	    WFFglobal.error_no = status;
	    _NFIdebug ((fname, " returning <0x%.8x>\n", status));
	    return (status);
         }

	/*  Display the form  */

	status = (long) FIf_display (WFFglobal.current_form);
	if (status != FI_SUCCESS)
	  {
		_NFIdebug ((fname, "FIf_display = <%d>\n", status));
		_WFFfree_add_ptr (ptr);
		WFFglobal.error_no = NFI_E_FORM;
		ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIf_display", status);
		_NFIdebug ((fname, " returning FAILURE\n"));
		return (NFI_E_FORM);
	  }

	/*  Position the cursor into the transition_name field  */

	status = (long) FIfld_pos_cursor (WFFglobal.current_form,
                                          TRANS_NAME_FIELD, 0, 0, 0, 0, 0, 0);
	if (status != FI_SUCCESS)
	  {
		_NFIdebug ((fname, "FIfld_pos_cursor = <%d>\n", status));
		_WFFfree_add_ptr (ptr);
		WFFglobal.error_no = NFI_E_FORM;
		ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_pos_cursor",
                                status);
		_NFIdebug ((fname, " returning FAILURE\n"));
		return (NFI_E_FORM);
	  }

	_NFIdebug ((fname, " returning SUCCESS\n"));
	return (NFI_S_SUCCESS);
  }


long _WFFpage3_notify (g_label, value, form)
  int		g_label;
  double	value;
  Form		form;
  {
	long	status = NFI_S_SUCCESS;
        long    _WFFchange_transition();
	WFFadd_ptr	ptr;

	static	char *fname = "_WFFpage3_notify";

	/*  Local functions  */

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

        _WFFmessage (NFI_S_CLEAR_MSG, NULL);
        status = NFI_S_SUCCESS;

	_NFMdebug ((fname, "Mouse event on label  = <%d>\n", g_label));
	switch (g_label)
	  {
		case FI_CANCEL:

			/*  Load the global error structure  */

			ERRload_struct (NFI, NFI_W_COMMAND_CANCELLED, NULL);

			/*  Set the next state  */

			if ((status = WFFset_to_state ()) != NFI_S_SUCCESS)
				_NFIdebug ((fname, "WFFset_to_state = <0x%.8x>\n", status));

			_WFFfree_add_ptr (ptr);

			/*  Enable the main form  */

			if (WFFglobal.main_form != NULL)
			  {
				FIg_enable (WFFglobal.main_form, FI_FORM_GROUP);
				_WFFprocess_event (REFRESH_EVENT);
			  }

			break;

		case FI_EXECUTE:
			/*  Put up a message  */

			_WFFmessage (WFFglobal.working_no, NULL);

			/*  Call NFM or WFG to do the command  */

                        _NFIdebug ((fname, "calling WFGadd_workflow...\n"));

                        status = WFGadd_workflow (WFFglobal.user_id,
                         ptr->workflow_name, ptr->old_wf_name,
                         ptr->workflow_desc, ptr->num_classes, ptr->class_list,
                         ptr->num_states, ptr->state_list, ptr->num_trans,
                         ptr->trans_list, ptr->num_access, ptr->access_list);

                        if (status != NFM_S_SUCCESS)
                         {
                             _NFIdebug ((fname, "WFGadd_workflow = <0x%.8x>\n",
                                         status));
                         }
                        else
                         {
                             strcpy (WFFglobal.workflow, ptr->workflow_name);
                         }

			/*  Erase the message  */

			_WFFerase_message ();

			/*  Save the return status  */

			WFFglobal.cmd_status = status;

			/*  Set the next state  */

			if ((status = WFFset_to_state ()) != NFI_S_SUCCESS)
				_NFIdebug ((fname, "WFFset_to_state = <0x%.8x>\n", status));
                       /*  Free up old data and reset form */

                        _WFFfree_add_ptr (ptr);

                        status = WFFchange_workflow( WFFglobal.workflow, 3 );

                        break;

		case FI_ACCEPT:

			/*  Put up a message  */

			_WFFmessage (WFFglobal.working_no, NULL);

			/*  Call NFM or WFG to do the command  */

                        _NFIdebug ((fname, "calling WFGadd_workflow...\n"));

                        status = WFGadd_workflow (WFFglobal.user_id,
                         ptr->workflow_name, ptr->old_wf_name,
                         ptr->workflow_desc, ptr->num_classes, ptr->class_list,
                         ptr->num_states, ptr->state_list, ptr->num_trans,
                         ptr->trans_list, ptr->num_access, ptr->access_list);

                        if (status != NFM_S_SUCCESS)
                         {
                             _NFIdebug ((fname, "WFGadd_workflow = <0x%.8x>\n",
                                         status));
                         }
                        else
                         {
                             strcpy (WFFglobal.workflow, ptr->workflow_name);
                         }

			/*  Erase the message  */

			_WFFerase_message ();

			/*  Save the return status  */

			WFFglobal.cmd_status = status;

			/*  Set the next state  */

			if ((status = WFFset_to_state ()) != NFI_S_SUCCESS)
				_NFIdebug ((fname, "WFFset_to_state = <0x%.8x>\n", status));

			/*  Clear out the appropriate fields  */

			/*  Blank out the listing on the main form  */

			_WFFfree_add_ptr (ptr);

			/*  Enable the main form  */

			if (WFFglobal.main_form != NULL)
			  {
				FIg_enable (WFFglobal.main_form, FI_FORM_GROUP);
				_WFFprocess_event (REFRESH_EVENT);
			  }

                        _WFFmain_set_wf (WFFglobal.workflow);

			break;

                  case TRANS_LIST_MCF:

                        status = _WFFset_selected_transition (form, g_label);
			break;

                  case TRANS_NAME_FIELD:
/*
                        status = _WFFupdate_trans_name (form, g_label,
                                                        TRANS_LIST_MCF, ptr);
 */
			break;

                  case COMMAND_LIST_SCF:
                        /* Get the name and put it into the TRANS_NAME_FIELD */

/*
                        status = _WFFput_list_info_in_field (form, g_label,
                                    TRANS_NAME_FIELD, 0, 100, FALSE);


                        status = _WFFupdate_t_command_name (form, g_label,
                                                   TRANS_LIST_MCF, ptr);
*/
			break;

                  case FROM_STATE_LIST_SCF:
/*
                        status =  _WFFupdate_t_from_state (form, g_label,
                                                    TRANS_LIST_MCF, ptr);
*/
			break;

                  case TO_STATE_LIST_SCF:
/*
                        status = _WFFupdate_t_to_state (form, g_label,
                                                    TRANS_LIST_MCF, ptr);
*/
			break;

                  case LOGON_SUCCESS_TOGGLE:
                  case LOGON_FAILURE_TOGGLE:
                  case NOTIFY_TOGGLE:
/*
                        status = _WFFupdate_transition_toggles (form, g_label,
                                                    TRANS_LIST_MCF, ptr);
*/
			break;

                  case ADD_TRANS_BUTTON:
                        /* Call function to add the trans to the buffer */

                        status = _WFFadd_transitions (form, TRANS_NAME_FIELD,
                                                      ptr);
			break;

                  case DELETE_TRANS_BUTTON:
                       /* Call function to delete the transtion from the list */

                        status = _WFFdelete_transitions (form, TRANS_LIST_MCF,
                                                         ptr);
			break;

                  case CHANGE_TRANS_BUTTON:
                       /* Call function to change the transtion in the list */

                        status = _WFFchange_transition (form, ptr);
			break;

                  case WF_PAGE_SCRL_BAR:
                        /* Call function to process the page scroll Bar */

                        status = _WFFscroll_pages (form, g_label, value, ptr);

			break;
	  }

	_NFIdebug ((fname, " returning <0x%.8x>\n", status));
	return (status);
  }


long _WFFload_transitions_in_list (data_list, ptr)
   MEMptr      data_list;
   WFFadd_ptr  ptr;
  {
     long  status;
     int   i, rows, cols, length;
     char  **data;

     static char *fname = "_WFFload_transitions_in_list";

     _NFIdebug ((fname, " Function entered...\n"));

     if (data_list)
      {
         rows = data_list->rows;
         cols = data_list->columns;
         data = (char **) data_list->data_ptr;
         if (ptr->trans_list)
           free ((struct WFFtrans_st *) ptr->trans_list);
         
         /* malloc memory for the list */

         ptr->trans_list = (struct WFFtrans_st *) malloc (rows * 
                            sizeof (struct WFFtrans_st));
         if (!ptr->trans_list)
          {
             _NFIdebug ((fname, "Malloc : bytes = <%d>\n",
                         rows * sizeof (struct WFFtrans_st)));
             WFFglobal.error_no = NFI_E_FORM;
             ERRload_struct (NFI, NFI_E_MALLOC, "%d",
                                     rows * sizeof (struct WFFtrans_st));
             _NFIdebug ((fname, " returning FAILURE\n"));
             return (NFI_E_MALLOC);
          }

         /* put the data into the trans_list */

         length = 40;

         if (strcmp (ptr->existing_wf_name, "") != 0)
          {
             for (i = 0; i < rows; ++i)
              {
                 ptr->trans_list[i].trans_no = 0;
                 strcpy (ptr->trans_list[i].trans_name,    data[cols * i + 1]);
                 strcpy (ptr->trans_list[i].command_name,  data[cols * i + 2]); 
                 strcpy (ptr->trans_list[i].from_state,    data[cols * i + 3]);
                 strcpy (ptr->trans_list[i].to_state,      data[cols * i + 4]);
                 strcpy (ptr->trans_list[i].logon_success, data[cols * i + 5]);
                 strcpy (ptr->trans_list[i].logon_failure, data[cols * i + 6]);
                 strcpy (ptr->trans_list[i].n_notify,      data[cols * i + 7]);
                 strcpy (ptr->trans_list[i].status, WFF_ADD); 
                 ptr->trans_list[i].row = i;
              }
          }
         else 
          {
             for (i = 0; i < rows; ++i)
              {
                 ptr->trans_list[i].trans_no = atol(data[cols * i]);
                 strcpy (ptr->trans_list[i].trans_name,    data[cols * i + 1]);
                 strcpy (ptr->trans_list[i].command_name,  data[cols * i + 2]); 
                 strcpy (ptr->trans_list[i].from_state,    data[cols * i + 3]);
                 strcpy (ptr->trans_list[i].to_state,      data[cols * i + 4]);
                 strcpy (ptr->trans_list[i].logon_success, data[cols * i + 5]);
                 strcpy (ptr->trans_list[i].logon_failure, data[cols * i + 6]);
                 strcpy (ptr->trans_list[i].n_notify,      data[cols * i + 7]);
                 strcpy (ptr->trans_list[i].status, ""); 
                 ptr->trans_list[i].row = i;
              }
          }

         ptr->num_trans = rows;
      }
      
     status = NFI_S_SUCCESS;
     _NFIdebug ((fname, " returning <0x%.8x>\n", status));
     return (status);
  }


long _WFFinsert_transition (form, g_label, row, trans_st)
     Form    form;
     int     g_label; 
     int     row;
     struct  WFFtrans_st trans_st;
  {
     long  status;

     static char *fname = "_WFFinsert_transition";
    
     /* call forms function to put the transition in the list. */ 

/* IGI Intel Solaris Port - CN 31/5/95 */
#if defined(OS_SCO_UNIX) || defined(OS_INTELSOL)
	/* To set font for SCO - CRN 25 Feb 94	*/
	FIg_set_font(form, g_label, "7x13bold", 15);
#endif
     status = (long) FIfld_set_text (form, g_label, row, 0,
                                     trans_st.trans_name, FALSE);
     if (status != FI_SUCCESS)
      {
          _NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
          ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_text", status);
          _NFIdebug ((fname, " returning FAILURE\n"));
          return (NFI_E_FORM);
      }

     status = (long) FIfld_set_text (form, g_label, row, 1,
                                     trans_st.command_name, FALSE);
     if (status != FI_SUCCESS)
      {
          _NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
          ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_text", status);
          _NFIdebug ((fname, " returning FAILURE\n"));
          return (NFI_E_FORM);
      }

     status = (long) FIfld_set_text (form, g_label, row, 2,
                                     trans_st.from_state, FALSE);
     if (status != FI_SUCCESS)
      {
          _NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
          ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_text", status);
          _NFIdebug ((fname, " returning FAILURE\n"));
          return (NFI_E_FORM);
      }

     status = (long) FIfld_set_text (form, g_label, row, 3,
                                     trans_st.to_state, FALSE);
     if (status != FI_SUCCESS)
      {
          _NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
          ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_text", status);
          _NFIdebug ((fname, " returning FAILURE\n"));
          return (NFI_E_FORM);
      }

     status = (long) FIfld_set_text (form, g_label, row, 4,
                                     trans_st.logon_success, FALSE);
     if (status != FI_SUCCESS)
      {
          _NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
          ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_text", status);
          _NFIdebug ((fname, " returning FAILURE\n"));
          return (NFI_E_FORM);
      }

     status = (long) FIfld_set_text (form, g_label, row, 5,
                                     trans_st.logon_failure, FALSE);
     if (status != FI_SUCCESS)
      {
          _NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
          ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_text", status);
          _NFIdebug ((fname, " returning FAILURE\n"));
          return (NFI_E_FORM);
      }

     status = (long) FIfld_set_text (form, g_label, row, 6,
                                     trans_st.n_notify, FALSE);
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



long _WFFput_transitions_in_list (form, g_label, num_trans, trans_list)
     Form                form;
     int                 g_label; 
     int                 num_trans;
     struct WFFtrans_st  trans_list[];
  {
     long  status;
     int   i, k;

     static char *fname = "_WFFput_transitions_in_list";

     _NFIdebug ((fname, " num_trans = <%d>\n", num_trans));

     k = 0;
     for (i = 0; i < num_trans; ++i)
      {
         if (strcmp (trans_list[i].status, WFF_DROP) != 0)
          {
             status = _WFFinsert_transition (form, g_label, k, trans_list[i]);
             if (status != NFI_S_SUCCESS)
              {
                 _NFIdebug ((fname, " WFFinsert_transition = <0x%.8x>\n",
                             status));
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


long _WFFadd_transitions (form, g_label, ptr)
     Form        form;
     int         g_label;   /* TRANS_NAME_FIELD */
     WFFadd_ptr  ptr;
  {
     long   status;
     int    rows, length = 80, i, j, g_state;
     int    num_rows;
     /* short  exist = FALSE; */
     short  t_name = FALSE, c_name = FALSE, f_state = FALSE, t_state = FALSE;
     char   trans_name[81];
     char   command_name[101];
     char   from_state[41];
     char   to_state[41];
     char   logon_success[2];
     char   logon_failure[2];
     char   notify[2];

     static char *fname = "_WFFadd_transitions";

     strcpy (trans_name, "");
     strcpy (command_name, "");
     strcpy (from_state, "");
     strcpy (to_state, "");
     strcpy (logon_success, "Y");
     strcpy (logon_failure, "Y");
     strcpy (notify, "Y");

     /* Unselect any selected value in the trans_list MCF */

     status = (long) FIfld_get_num_rows (form, TRANS_LIST_MCF, &num_rows);
     if (status != FI_SUCCESS)
      {
         _NFIdebug ((fname, "FIfld_get_num_rows = <%d>\n", status));
         ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_get_num_rows", status);
         _NFIdebug ((fname, " returning FAILURE\n"));
         return (NFI_E_FORM);
      }

     for (i = 0; i < num_rows; ++i)
      {
        status = (long) FImcf_set_select (form, TRANS_LIST_MCF, i, FALSE);
        if (status != FI_SUCCESS)
         {
            _NFIdebug ((fname, "FImcf_set_select = <%d>\n", status));
            ERRload_struct (NFI, NFI_E_FORM, "%s%d",
                            "FImcf_set_select", status);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_FORM);
         }
      }

     /* get the trans_name from the TRANS_NAME_FIELD */

     status = _WFFget_data_from_field (form, g_label, 0, 0, trans_name, length);
     if (status != NFI_S_SUCCESS)
      {
         _NFIdebug ((fname, " WFFget_data_from_field = <0x%.8x>\n", status));
         _NFIdebug ((fname, " returning FAILURE\n"));
         return (status);
      }

     /* If the trans_name is null, send a warning to user */ 
     if (strcmp (trans_name, "") == 0)
      {
        /* Put up a message warning user that the transition name is null */

        _WFFmessage (NFI_W_NULL_TRANS_NAME, NULL);
        return (NFI_S_SUCCESS);
      } 

     /* get the command_name from the COMMAND_LIST_SCF */

     status = _WFFget_data_from_field (form, COMMAND_LIST_SCF, -1, 0,
                                       command_name, 100);
     if (status != NFI_S_SUCCESS)
      {
         _NFIdebug ((fname, " WFFget_data_from_field = <0x%.8x>\n", status));
         _NFIdebug ((fname, " returning FAILURE\n"));
         return (status);
      }

     /* If the command_name is null, send a warning to user */ 

     if (strcmp (command_name, "") == 0)
      {
        /* Put up a message telling the user to select a command name */

        _WFFmessage (NFI_W_NULL_COMMAND_NAME, NULL);
        return (NFI_S_SUCCESS);
      } 

     /* get the from_state from the FROM_STATE_LIST_SCF */

     status = _WFFget_data_from_field (form, FROM_STATE_LIST_SCF, -1, 0,
                                       from_state, 40);
     if (status != NFI_S_SUCCESS)
       {
         _NFIdebug ((fname, " WFFget_data_from_field = <0x%.8x>\n",
                     status));
         _NFIdebug ((fname, " returning FAILURE\n"));
         return (status);
       }

     /* If the from_state is null, send a warning to user */ 

     if (strcmp (from_state, "") == 0)
      {
        /* Put up a message telling the user to select a from_state */

        _WFFmessage (NFI_W_NULL_FROM_STATE, NULL);
        return (NFI_S_SUCCESS);
      } 

     /* get the to_state from the TO_STATE_LIST_SCF */

     status = _WFFget_data_from_field (form, TO_STATE_LIST_SCF, -1, 0,
                                       to_state, 40);
     if (status != NFI_S_SUCCESS)
       {
         _NFIdebug ((fname, " WFFget_data_from_field = <0x%.8x>\n",
                     status));
         _NFIdebug ((fname, " returning FAILURE\n"));
         return (status);
       }

     /* If the to_state is null, send a warning to user */ 

     if (strcmp (to_state, "") == 0)
      {
        /* Put up a message telling the user to select a to_state */

        _WFFmessage (NFI_W_NULL_TO_STATE, NULL);
        return (NFI_S_SUCCESS);
      } 
   
   
     /* check to see if the row is a duplicate : if it is exit, send warning */

     if (ptr->trans_list != NULL)
      {
        for (i = 0; i < ptr->num_trans; ++i)
         {
             if (strcmp (ptr->trans_list[i].trans_name, trans_name) == 0)
                 t_name = TRUE;
             if (strcmp (ptr->trans_list[i].command_name, command_name) == 0)
                 c_name = TRUE;
             if (strcmp (ptr->trans_list[i].from_state, from_state) == 0)
                 f_state = TRUE;
             if (strcmp (ptr->trans_list[i].to_state, to_state) == 0)
                 t_state = TRUE;

             if ((t_name) && (f_state) && 
                 (strcmp (ptr->trans_list[i].status, WFF_DROP) != 0)) 
              {
                  /* Clear out the trans_name field */
   
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
   
                  /* Put up a message warning user that trans is a duplicate */
   
                  _WFFmessage (NFI_W_DUPLICATE_TRANS_FROM, NULL);
   
                  return (NFI_S_SUCCESS);
              }  
             else if ((c_name) && (f_state) && (t_state) &&
                      (strcmp (ptr->trans_list[i].status, WFF_DROP) != 0)) 
              {
                  /* Put up a message warning user that combination is a
                     duplicate                                            */
   
                  _WFFmessage (NFI_W_DUPLICATE_COMM_FROM_TO, NULL);
   
                  return (NFI_S_SUCCESS);
              }  
             t_name = FALSE;
             c_name = FALSE;
             f_state = FALSE;
             t_state = FALSE;
         }
      }

     /* get the gadget states for the logon_success, logon_failure and
        notify toggles                                                */

     status = (long) FIg_get_state (form, LOGON_SUCCESS_TOGGLE, &g_state);
     if (status != FI_SUCCESS)
      {
         _NFIdebug ((fname, "FIg_get_state = <%d>\n", status));
         ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_get_state", status);
         _NFIdebug ((fname, " returning FAILURE\n"));
         return (NFI_E_FORM);
      }

     if (g_state)    /* Logon Success = 'Y' is the default */
        strcpy (logon_success, "N");  

     status = (long) FIg_get_state (form, LOGON_FAILURE_TOGGLE, &g_state);
     if (status != FI_SUCCESS)
      {
         _NFIdebug ((fname, "FIg_get_state = <%d>\n", status));
         ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_get_state", status);
         _NFIdebug ((fname, " returning FAILURE\n"));
         return (NFI_E_FORM);
      }

     if (g_state)     /* Logon Failure = 'Y' is the dafault */
        strcpy (logon_failure, "N");  

     status = (long) FIg_get_state (form, NOTIFY_TOGGLE, &g_state);
     if (status != FI_SUCCESS)
      {
         _NFIdebug ((fname, "FIg_get_state = <%d>\n", status));
         ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_get_state", status);
         _NFIdebug ((fname, " returning FAILURE\n"));
         return (NFI_E_FORM);
      }

     if (g_state)  /* Notify = 'Y' is the default */
        strcpy (notify, "N");  

     rows = ptr->num_trans + 1;

     if (ptr->trans_list)  
      {
         /* reallocate memory for the list */

         ptr->trans_list = (struct WFFtrans_st *) realloc (ptr->trans_list,
                            rows * sizeof (struct WFFtrans_st));
         if (!ptr->trans_list)
          {
             _NFIdebug ((fname, "Malloc : bytes = <%d>\n",
                         rows * sizeof (struct WFFtrans_st)));
             ERRload_struct (NFI, NFI_E_MALLOC, "%d",  
                             rows * sizeof (struct WFFtrans_st));
             _NFIdebug ((fname, " returning FAILURE\n"));
             return (NFI_E_MALLOC);
          }
     }
    else
     {
         /* malloc memory for the trans_list */

         ptr->trans_list = (struct WFFtrans_st *) malloc (rows * 
                            sizeof (struct WFFtrans_st));
         if (!ptr->trans_list)
          {
             _NFIdebug ((fname, "Malloc : bytes = <%d>\n",
                         rows * sizeof (struct WFFtrans_st)));
             ERRload_struct (NFI, NFI_E_MALLOC, "%d",  
                             rows * sizeof (struct WFFtrans_st));
             _NFIdebug ((fname, " returning FAILURE\n"));
             return (NFI_E_MALLOC);
          }
     }
   
    ptr->trans_list[rows -1].trans_no = 0; 
    strcpy (ptr->trans_list[rows -1].trans_name,  trans_name); 
    strcpy (ptr->trans_list[rows -1].command_name,  command_name); 
    strcpy (ptr->trans_list[rows -1].from_state, from_state); 
    strcpy (ptr->trans_list[rows -1].to_state, to_state); 
    strcpy (ptr->trans_list[rows -1].logon_success, logon_success); 
    strcpy (ptr->trans_list[rows -1].logon_failure, logon_failure); 
    strcpy (ptr->trans_list[rows -1].n_notify, notify); 
    strcpy (ptr->trans_list[rows -1].status, WFF_ADD); 
    ptr->num_trans = rows;
    
    /* get the num_rows in the TRANS_LIST_MCF (I/FORMS returns invalid info) */

    j = 0;
    for (i = 0; i < ptr->num_trans; ++i)
     {
        if (strcmp (ptr->trans_list[i].status, WFF_DROP) != 0)
          ++j;
     }

    ptr->trans_list[rows -1].row = j - 1; 

    /* add the transition to the TRANS_LIST_MCF */

/* IGI Intel Solaris Port - CN 31/5/95 */
#if defined(OS_SCO_UNIX) || defined(OS_INTELSOL)
	/* To set font for SCO - CRN 25 Feb 94	*/
	FIg_set_font(form , TRANS_LIST_MCF,"7x13bold", 15);
#endif
    status = (long) FIfld_set_text (form, TRANS_LIST_MCF, j - 1, 0, 
                                    trans_name, FALSE);
    if (status != FI_SUCCESS)
     {
        _NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_text",
                        status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
     } 

    status = (long) FIfld_set_text (form, TRANS_LIST_MCF, j - 1, 1, 
                                    command_name, FALSE);
    if (status != FI_SUCCESS)
     {
        _NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_text",
                        status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
     } 

    status = (long) FIfld_set_text (form, TRANS_LIST_MCF, j - 1, 2, 
                                    from_state, FALSE);
    if (status != FI_SUCCESS)
     {
        _NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_text",
                        status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
     } 

    status = (long) FIfld_set_text (form, TRANS_LIST_MCF, j - 1, 3, 
                                    to_state, FALSE);
    if (status != FI_SUCCESS)
     {
        _NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_text",
                        status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
     } 

    status = (long) FIfld_set_text (form, TRANS_LIST_MCF, j - 1, 4, 
                                    logon_success, FALSE);
    if (status != FI_SUCCESS)
     {
        _NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_text",
                        status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
     } 

    status = (long) FIfld_set_text (form, TRANS_LIST_MCF, j - 1, 5, 
                                    logon_failure, FALSE);
    if (status != FI_SUCCESS)
     {
        _NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_text",
                        status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
     } 

    status = (long) FIfld_set_text (form, TRANS_LIST_MCF, j - 1, 6, 
                                    notify, FALSE);
    if (status != FI_SUCCESS)
     {
        _NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_text",
                        status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
     } 

    /* set the row to be in the viewing area */

    _WFFset_active_row (form, TRANS_LIST_MCF, j - 1, 1);

    /* Clear out the transition fields and reset toggles */
  
    FIfld_set_text (form, g_label, 0, 0, "", FALSE);

    FIfld_get_num_rows (form, COMMAND_LIST_SCF, &rows);
    for (i = 0; i < rows; ++i)
     {
       status = (long) FImcf_set_select (form, COMMAND_LIST_SCF, i, FALSE);
       if (status != FI_SUCCESS)
        {
          _NFIdebug ((fname, "FImcf_set_select = <%d>\n", status));
          break;
        }
     }

    FIfld_get_num_rows (form, FROM_STATE_LIST_SCF, &rows);
    for (i = 0; i < rows; ++i)
     {
       status = (long) FIfld_set_select (form, FROM_STATE_LIST_SCF, i,0,FALSE);
       if (status != FI_SUCCESS)
        {
          _NFIdebug ((fname, "FIfld_set_select = <%d>\n", status));
          break;
        }
     }

    FIfld_get_num_rows (form, TO_STATE_LIST_SCF, &rows);
    for (i = 0; i < rows; ++i)
     {
       status = (long) FIfld_set_select (form, TO_STATE_LIST_SCF, i, 0, FALSE);
       if (status != FI_SUCCESS)
        {
          _NFIdebug ((fname, "FIfld_set_select = <%d>\n", status));
          break;
        }
     }

    FIg_set_state (form, LOGON_SUCCESS_TOGGLE, 0);
    FIg_set_state (form, LOGON_FAILURE_TOGGLE, 0);
    FIg_set_state (form, NOTIFY_TOGGLE, 0);
  
    status = NFI_S_SUCCESS;
    _NFIdebug ((fname, " returning <0x%.8x>\n", status));
    return (status);
  }


long _WFFdelete_transitions (form, g_label, ptr)
     Form        form;
     int         g_label; 
     WFFadd_ptr  ptr;
  {
     long   status;
     int    x, i, y = 0, j = 0, k = 0, n, rows, l_rows = 0, sel_flag;
     int    length = 80;
     int    *delete_list = NULL;
     char   trans_name[81];
     char   from_state[41];
     short  delete = FALSE; 
     short  c_warning = FALSE, d_trans = TRUE;

     static char *fname = "_WFFdelete_transitions";

     /* get the num_rows in the TRANS_LIST_MCF */

     status = (long) FIfld_get_num_rows (form, g_label, &rows); 
     if (status != FI_SUCCESS)
      {
         _NFIdebug ((fname, "FIfld_get_num_rows = <%d>\n", status));
         ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_get_num_rows", status);
         _NFIdebug ((fname, " returning FAILURE\n"));
         return (NFI_E_FORM);
      } 
     _NFIdebug ((fname, "rows = <%d>\n", rows));

     if (rows == 0)
      {
         _WFFmessage (NFI_W_NO_TRANS_SELECTED, NULL);
         _NFIdebug ((fname, "No rows exist in the TRANS_LIST_MCF\n"));
         return (NFI_S_SUCCESS);
      } 

     if (ptr->num_trans == 0)
      {
         FIfld_set_num_rows (form, g_label, 0);
         _WFFmessage (NFI_W_NO_TRANS_SELECTED, NULL);
         _NFIdebug ((fname, "No rows exist in the TRANS_LIST_MCF\n"));
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

     if (ptr->trans_list != NULL)
      {
        for (i = 0; i < rows; ++i)
         {
             /* See if this transition is selected for deletion */

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

/*
         for (i = 0;  i < rows; ++i)
             _NFIdebug ((fname, "delete_list[%d] = <%d>\n", i, delete_list[i]));
*/
                  
         if (delete) 
          {
             /*  Delete the rows from the ptr-trans_list */ 

             for (i = 0; i < rows; ++i)
              {
                 if (delete_list[i])
                  { 
                    d_trans = TRUE;
                    strcpy (trans_name, "");
                    strcpy (from_state, "");

                    /* get the trans_name from the TRANS_LIST_MCF */
                    
                    status = _WFFget_data_from_field (form, g_label, i, 0,
                                                      trans_name, length);
                    if (status != NFI_S_SUCCESS)
                     {
                        free ((int *) delete_list);
                        _NFIdebug ((fname,
                             " WFFget_data_from_field = <0x%.8x>\n", status));
                        _NFIdebug ((fname, " returning FAILURE\n"));
                        return (status);
                     }

                    /* get the from_state from the TRANS_LIST_MCF */
                    
                    status = _WFFget_data_from_field (form, g_label, i, 2,
                                                      from_state, 40);
                    if (status != NFI_S_SUCCESS)
                     {
                        free ((int *) delete_list);
                        _NFIdebug ((fname,
                             " WFFget_data_from_field = <0x%.8x>\n", status));
                        _NFIdebug ((fname, " returning FAILURE\n"));
                        return (status);
                     }

                    /* check to see if the trans is being used in the access
                       if it is, set c_warning to TRUE and do not delete the
                       transition                                           */

                    for (n = 0; n < ptr->num_access; ++n)
                     {
                       for (k = 0; k < ptr->access_list[n].num_trans; ++k)
                        {
                          if ((strcmp (
                                   ptr->access_list[n].trans_ptr[k].trans_name,
                                       trans_name) == 0) && 
                              (strcmp (
                                   ptr->access_list[n].trans_ptr[k].from_state,
                                       from_state) == 0) &&
                              (strcmp (ptr->access_list[n].trans_ptr[k].status,
                                       WFF_DROP) != 0))
                           {
                               c_warning = TRUE;
                               d_trans = FALSE;
                               delete_list[i] = FALSE;
                               break;
                           }
                        }
                     }                     

                    if (!d_trans)
                       continue;
                    
                    l_rows = ptr->num_trans;

                    /* Update the MCF row position of the transitions in the
                       list */

                    x = 0;
                    for (k = 0; k < l_rows; ++k)
                     {
                        if ((strcmp (ptr->trans_list[k].trans_name,
                                    trans_name) != 0) &&
                            (strcmp (ptr->trans_list[k].from_state,
                                    from_state) != 0) &&
                            (strcmp (ptr->trans_list[k].status, WFF_DROP) != 0))
                         {
                            ptr->trans_list[k].row = x;
                            ++x;
                         }
                      } 
                    
                    /* find the transition in the trans_list */

                    for (k = 0; k < l_rows; ++k)
                     {
                        if ((strcmp (ptr->trans_list[k].trans_name,
                                     trans_name) == 0) &&
                            (strcmp (ptr->trans_list[k].from_state,
                                     from_state) == 0) &&
                            (strcmp (ptr->trans_list[k].status, WFF_DROP) != 0))
                         {
                            /* If trans does not exist in database, drop it */
                            /* otherwise mark it for deletion               */
                           
                            if (!strcmp (ptr->trans_list[k].status, WFF_ADD)) 
                             {
                               /* move/shift all values up by 1 */
                    
                               for (y = k; y < (l_rows - 1); ++y)
                                   ptr->trans_list[y] = ptr->trans_list[y + 1];
                       
                               /* delete the transition from the trans_list */
      
                               if (l_rows == 1)
                                {
                                   free((struct WFFtrans_st *) ptr->trans_list);
                                   ptr->trans_list = NULL;
                                } 
                               else
                                {
                                   ptr->trans_list = (struct WFFtrans_st *) \
                                         realloc (ptr->trans_list, (l_rows -1) *
                                         sizeof (struct WFFtrans_st));
                                   if (!ptr->trans_list)
                                    {
                                       free ((int *) delete_list);
                                       _NFIdebug ((fname,
                                                   "Realloc : bytes = <%d>\n",
                                         l_rows * sizeof (struct WFFtrans_st)));
                                       ERRload_struct (NFI, NFI_E_MALLOC, "%d",

                                          l_rows * sizeof (struct WFFtrans_st));
                                       _NFIdebug ((fname,
                                                   " returning FAILURE\n"));
                                       return (NFI_E_MALLOC);
                                    }
                                } 
                               --ptr->num_trans;
                             } 
                            else
                             {
                                strcpy (ptr->trans_list[k].status, WFF_DROP);
                                ptr->trans_list[k].row = -1;
                             }
                            break;
                         }
                     }
                  }
              }

             /* delete the transitions from the TRANS_LIST_MCF */

             j = 0;

             for (i = 0; i < rows; ++i)
              {
                 if (delete_list[i])
                  { 
                     if (rows == 1)
                        status = FIfld_set_num_rows (form, g_label, 0);
                     else 
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


     /* Unselect all the selected row(s) in the mcf */

     if ((rows -j) != 0)
      {
        for (i = 0; i < (rows - j); ++i)
         {
            status = (long) FImcf_set_select (form, TRANS_LIST_MCF, i, FALSE);
            if (status != FI_SUCCESS)
             {
                _NFIdebug ((fname, "FImcf_set_select = <%d>\n", status));
                ERRload_struct (NFI, NFI_E_FORM, "%s%d",
                                "FImcf_set_select", status);
                _NFIdebug ((fname, " returning FAILURE\n"));
                return (NFI_E_FORM);
             }
         }
      }
     else
       FIfld_set_num_rows (form, TRANS_LIST_MCF, 0);

     if (!delete)
       _WFFmessage (NFI_W_NO_TRANS_SELECTED, NULL);

     if (c_warning)
       _WFFmessage (NFI_W_TRANS_HAS_ACCESS, NULL); 

     status = NFI_S_SUCCESS;
     _NFIdebug ((fname, " returning <0x%.8x>\n", status));
     return (status);
  }


long _WFFput_list_info_in_field  (form, label1, label2, column, length,
                                  sel_value)
     Form        form;
     int         label1;     /* MCF/SCF list label; */
     int         label2;     /* Field label; */
     int         column;     /* MCF/SCF column to get the data from */
     int         length;     /* Maximum length of the text in the SCF/MCF */
     int         sel_value;  /* TRUE/FALSE : value to set the field to */
  {
     long   status;
     int    i, l_size, sel_flag;
     int    rows = 0;
     char   text[256];

     static char *fname = "_WFFput_list_info_in_field";

     _NFIdebug ((fname, " label1    = <%d>\n", label1));
     _NFIdebug ((fname, " label2    = <%d>\n", label2));
     _NFIdebug ((fname, " column    = <%d>\n", column));
     _NFIdebug ((fname, " length    = <%d>\n", length));
     _NFIdebug ((fname, " sel_value = <%d>\n", sel_value));

     /* get the num_rows in the MCF/SCF */

     status = (long) FIfld_get_num_rows (form, label1, &rows); 
     if (status != FI_SUCCESS)
      {
         _NFIdebug ((fname, "FIfld_get_num_rows = <%d>\n", status));
         ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_get_num_rows", status);
         _NFIdebug ((fname, " returning FAILURE\n"));
         return (NFI_E_FORM);
      } 

     if (rows == 0)
      {
         _WFFmessage (NFI_W_NULL_COMMAND_LIST, NULL);
         _NFIdebug ((fname, "No rows exist in the MCF/SCF\n"));
         return (NFI_S_SUCCESS);
      } 

     strcpy (text, "");

     l_size = length;

     if (length <= 0)
        l_size = 100;

/* IGI Intel Solaris Port - CN 31/5/95 */
#if defined(OS_SCO_UNIX) || defined(OS_INTELSOL)
	/* To ste font for SCO - CRN 25 Feb 94 	*/
	FIg_set_font(form, label2, "7x13bold", 15);
#endif

     for (i = 0; i < rows; ++i)
      {
         /* See if this row/column is selected */

         status = (long) FIfld_get_select (form, label1, i, column, &sel_flag); 
         if (status != FI_SUCCESS)
          {
             _NFIdebug ((fname, "FIfld_get_select = <%d>\n", status));
             ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_get_select",
                             status);
             _NFIdebug ((fname, " returning FAILURE\n"));
             return (NFI_E_FORM);
          } 
   
         if (sel_flag)
          {
              /* Get the text from the MCF/SCF */
                    
              status = _WFFget_data_from_field (form, label1, i, column,
                                                text, l_size);
              if (status != NFI_S_SUCCESS)
               {
                  _NFIdebug ((fname,
                           " WFFget_data_from_field = <0x%.8x>\n", status));
                  _NFIdebug ((fname, " returning FAILURE\n"));
                  return (status);
               }

              /* Put the text into the field */

              status = (long) FIfld_set_text (form, label2, 0, 0, text,
                                              sel_value);
              if (status != FI_SUCCESS)
               {
                  _NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
                  ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_text",
                                  status);
                  _NFIdebug ((fname, " returning FAILURE\n"));
                  return (NFI_E_FORM);
               }

              break;
          }
      }

     status = NFI_S_SUCCESS;
     _NFIdebug ((fname, " returning <0x%.8x>\n", status));
     return (status);
  }


long _WFFset_selected_transition (form, mcf_label)
     Form        form;
     int         mcf_label; 
  {
     long   status;
     int    sel_flag = FALSE;  
     int    rows = 0, length = 100, i, j;
     int    num_rows = 0;
     int    state = FALSE;
     int    r_pos;
     char   str   [128];
     char   t_str [128];

     static char *fname = "_WFFset_selected_transition";

     /* Get the number of rows from the MCF (the transition_list may
        not match the no of rows in the MCF).                     */

     status = FIfld_get_num_rows (form, mcf_label, &rows);
     if (status != FI_SUCCESS)
      {
         _NFIdebug ((fname, "FIfld_get_num_rows = <%d>\n", status));
         ERRload_struct (NFI, NFI_E_FORM, "%s%d",
                         "FIfld_get_num_rows", status);
         _NFIdebug ((fname, " returning FAILURE\n"));
         return (NFI_E_FORM);
      } 

     /* Check to see if a transition is selected */

     for (i = 0; i < rows; ++i)
      {
         status = (long) FIfld_get_select (form, mcf_label, i, 0, &sel_flag);
         if (status != FI_SUCCESS)
          {
             _NFIdebug ((fname, "FIfld_get_select = <%d>\n", status));
             ERRload_struct (NFI, NFI_E_FORM, "%s%d",
                             "FIfld_get_select", status);
             _NFIdebug ((fname, " returning FAILURE\n"));
             return (NFI_E_FORM);
          } 

         if (sel_flag)
          {
             /* Get the text string */
/* IGI Intel Solaris Port - CN 31/5/95 */
#if defined(OS_SCO_UNIX) || defined(OS_INTELSOL)
	/* To set font for SCO - CRN 25 Feb 94	*/
	FIg_set_font(form, mcf_label, "7x13bold", 15);
#endif

             status = (long) FIfld_get_text (form, mcf_label, i, 0,
                             length + 1, str, &sel_flag, &r_pos);
             if (status != FI_SUCCESS)
              {
                 _NFIdebug ((fname, "FIfld_get_text = <%d>\n", status));
                 ERRload_struct (NFI, NFI_E_FORM, "%s%d",
                                 "FIfld_get_text", status);
                 _NFIdebug ((fname, " returning FAILURE\n"));
                 return (NFI_E_FORM);
              } 

             /* Set the transition_name field to the selected value in the
                MCF */
   
/* IGI Intel Solaris Port - CN 31/5/95 */
#if defined(OS_SCO_UNIX) || defined(OS_INTELSOL)
	/* To set font for SCO - CRN 25 Feb 94	*/
	FIg_set_font(form, TRANS_NAME_FIELD, "7x13bold", 15);
#endif
             status = (long) FIfld_set_text (form, TRANS_NAME_FIELD, 0, 0, 
                                             str, FALSE);
             if (status != FI_SUCCESS)
              {
                 _NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
                 ERRload_struct (NFI, NFI_E_FORM, "%s%d",
                                 "FIfld_set_text", status);
                 _NFIdebug ((fname, " returning FAILURE\n"));
                 return (NFI_E_FORM);
              } 

             str[0] = 0;
             t_str[0] = 0;

             /* get the command name and set it to be selected in the command
                list SCF */

             status = (long) FIfld_get_num_rows (form, COMMAND_LIST_SCF,
                                                 &num_rows); 
             if (status != FI_SUCCESS)
	      {
	         _NFIdebug ((fname, "FIfld_get_num_rows = <%d>\n", status));
	         ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_get_num_rows",
                                 status);
	         _NFIdebug ((fname, " returning FAILURE\n"));
	         return (NFI_E_FORM);
	      }
         
             status = (long) FIfld_get_text (form, mcf_label, i, 1,
                             length + 1, str, &sel_flag, &r_pos);
             if (status != FI_SUCCESS)
              {
                 _NFIdebug ((fname, "FIfld_get_text = <%d>\n", status));
                 ERRload_struct (NFI, NFI_E_FORM, "%s%d",
                                 "FIfld_get_text", status);
                 _NFIdebug ((fname, " returning FAILURE\n"));
                 return (NFI_E_FORM);
              } 

             /* Set the command name to be selected in the SCF */
   
             for (j = 0; j < num_rows; ++j)
              {
                 status = (long) FIfld_get_text (form, COMMAND_LIST_SCF, j, 0,
                                 length + 1, t_str, &sel_flag, &r_pos);
                 if (status != FI_SUCCESS)
                  {
                     _NFIdebug ((fname, "FIfld_get_text = <%d>\n", status));
                     ERRload_struct (NFI, NFI_E_FORM, "%s%d",
                                     "FIfld_get_text", status);
                     _NFIdebug ((fname, " returning FAILURE\n"));
                     return (NFI_E_FORM);
                  } 

                 if (strcmp (t_str, str) == 0)
                  {
                    if (sel_flag)
                     {
                        /* command is already selected */
                        
                        _WFFset_active_row (form, COMMAND_LIST_SCF, j, 1);
                        break; 
                     }

                    /* Set the command name to be selected in the SCF */

                    status = (long) FImcf_set_select (form, COMMAND_LIST_SCF,
                                                      j, TRUE);
                    if (status != FI_SUCCESS)
                     {
                        _NFIdebug ((fname, "FIfld_set_select = <%d>\n",
                                    status));
                        ERRload_struct (NFI, NFI_E_FORM, "%s%d",
                                        "FIfld_set_select", status);
                        _NFIdebug ((fname, " returning FAILURE\n"));
                        return (NFI_E_FORM);
                     } 
         
                    _WFFset_active_row (form, COMMAND_LIST_SCF, j, 1);
                    break; 
                  } 
              } 

             str[0] = 0;
             t_str[0] = 0;
             num_rows = 0;

             /* get the from state name and set it to be selected in the 
                from_state list SCF */

             status = (long) FIfld_get_num_rows (form, FROM_STATE_LIST_SCF,
                                                 &num_rows); 
             if (status != FI_SUCCESS)
	      {
	         _NFIdebug ((fname, "FIfld_get_num_rows = <%d>\n", status));
	         ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_get_num_rows",
                                 status);
	         _NFIdebug ((fname, " returning FAILURE\n"));
	         return (NFI_E_FORM);
	      }
         
             status = (long) FIfld_get_text (form, mcf_label, i, 2,
                             41, str, &sel_flag, &r_pos);
             if (status != FI_SUCCESS)
              {
                 _NFIdebug ((fname, "FIfld_get_text = <%d>\n", status));
                 ERRload_struct (NFI, NFI_E_FORM, "%s%d",
                                 "FIfld_get_text", status);
                 _NFIdebug ((fname, " returning FAILURE\n"));
                 return (NFI_E_FORM);
              } 

             /* Set the from_state to be selected in the SCF */
   
             for (j = 0; j < num_rows; ++j)
              {
                 status = (long) FIfld_get_text (form, FROM_STATE_LIST_SCF,
                                          j, 0, 41, t_str, &sel_flag, &r_pos);
                 if (status != FI_SUCCESS)
                  {
                     _NFIdebug ((fname, "FIfld_get_text = <%d>\n", status));
                     ERRload_struct (NFI, NFI_E_FORM, "%s%d",
                                     "FIfld_get_text", status);
                     _NFIdebug ((fname, " returning FAILURE\n"));
                     return (NFI_E_FORM);
                  } 

                 if (strcmp (t_str, str) == 0)
                  {
                    if (sel_flag)
                     {
                        /* the from_state is already selected */
           
                        _WFFset_active_row (form, FROM_STATE_LIST_SCF, j, 1);
                        break; 
                     }

                    /* Set the from_state to be selected in the SCF */

                    status = (long) FIfld_set_select (form, FROM_STATE_LIST_SCF,
                                                      j, 0, TRUE);
                    if (status != FI_SUCCESS)
                     {
                        _NFIdebug ((fname, "FIfld_set_select = <%d>\n",
                                    status));
                        ERRload_struct (NFI, NFI_E_FORM, "%s%d",
                                        "FIfld_set_select", status);
                        _NFIdebug ((fname, " returning FAILURE\n"));
                        return (NFI_E_FORM);
                     } 
         
                    _WFFset_active_row (form, FROM_STATE_LIST_SCF, j, 1);
                    break; 
                  } 
              } 

             str[0] = 0;
             t_str[0] = 0;
             num_rows = 0;

             /* get the to state name and set it to be selected in the 
                to_state list SCF */

             status = (long) FIfld_get_num_rows (form, TO_STATE_LIST_SCF,
                                                 &num_rows); 
             if (status != FI_SUCCESS)
	      {
	         _NFIdebug ((fname, "FIfld_get_num_rows = <%d>\n", status));
	         ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_get_num_rows",
                                 status);
	         _NFIdebug ((fname, " returning FAILURE\n"));
	         return (NFI_E_FORM);
	      }
         
             status = (long) FIfld_get_text (form, mcf_label, i, 3,
                             41, str, &sel_flag, &r_pos);
             if (status != FI_SUCCESS)
              {
                 _NFIdebug ((fname, "FIfld_get_text = <%d>\n", status));
                 ERRload_struct (NFI, NFI_E_FORM, "%s%d",
                                 "FIfld_get_text", status);
                 _NFIdebug ((fname, " returning FAILURE\n"));
                 return (NFI_E_FORM);
              } 

             /* Set the to_state to be selected in the SCF */
   
             for (j = 0; j < num_rows; ++j)
              {
                 status = (long) FIfld_get_text (form, TO_STATE_LIST_SCF,
                                          j, 0, 41, t_str, &sel_flag, &r_pos);
                 if (status != FI_SUCCESS)
                  {
                     _NFIdebug ((fname, "FIfld_get_text = <%d>\n", status));
                     ERRload_struct (NFI, NFI_E_FORM, "%s%d",
                                     "FIfld_get_text", status);
                     _NFIdebug ((fname, " returning FAILURE\n"));
                     return (NFI_E_FORM);
                  } 

                 if (strcmp (t_str, str) == 0)
                  {
                    if (sel_flag)
                     {
                        /* The to_state is already selected */
           
                        _WFFset_active_row (form, TO_STATE_LIST_SCF, j, 1);
                        break; 
                     }

                    /* Set the to_state to be selected in the SCF */

                    status = (long) FIfld_set_select (form, TO_STATE_LIST_SCF,
                                                      j, 0, TRUE);
                    if (status != FI_SUCCESS)
                     {
                        _NFIdebug ((fname, "FIfld_set_select = <%d>\n",
                                    status));
                        ERRload_struct (NFI, NFI_E_FORM, "%s%d",
                                        "FIfld_set_select", status);
                        _NFIdebug ((fname, " returning FAILURE\n"));
                        return (NFI_E_FORM);
                     } 
         
                    _WFFset_active_row (form, TO_STATE_LIST_SCF, j, 1);
                    break; 
                  } 
              } 
             
             /* get and set the log_on_success toggle information. */

             str[0] = 0;
             status = (long) FIfld_get_text (form, mcf_label, i, 4,
                             2, str, &sel_flag, &r_pos);
             if (status != FI_SUCCESS)
              {
                 _NFIdebug ((fname, "FIfld_get_text = <%d>\n", status));
                 ERRload_struct (NFI, NFI_E_FORM, "%s%d",
                                 "FIfld_get_text", status);
                 _NFIdebug ((fname, " returning FAILURE\n"));
                 return (NFI_E_FORM);
              } 

             /* Set the toggle state based on the string */

             if (strcmp (str, "Y") == 0)
                state = FALSE;  /* OFF = 'Y' on = 'N' */
             else
                state = TRUE;  

             status = (long) FIg_set_state (form, LOGON_SUCCESS_TOGGLE, state);
             if (status != FI_SUCCESS)
              {
                 _NFIdebug ((fname, "FIg_set_state = <%d>\n", status));
                 ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_set_state",
                                 status);
                 _NFIdebug ((fname, " returning FAILURE\n"));
                 return (NFI_E_FORM);
              } 
             
             /* get and set the log_on_failure toggle information. */

             str[0] = 0;
             status = (long) FIfld_get_text (form, mcf_label, i, 5,
                             2, str, &sel_flag, &r_pos);
             if (status != FI_SUCCESS)
              {
                 _NFIdebug ((fname, "FIfld_get_text = <%d>\n", status));
                 ERRload_struct (NFI, NFI_E_FORM, "%s%d",
                                 "FIfld_get_text", status);
                 _NFIdebug ((fname, " returning FAILURE\n"));
                 return (NFI_E_FORM);
              } 

             /* Set the toggle state based on the string */

             if (strcmp (str, "Y") == 0)
                state = FALSE;  /* OFF = 'Y' on = 'N' */
             else
                state = TRUE;  

             status = (long) FIg_set_state (form, LOGON_FAILURE_TOGGLE, state);
             if (status != FI_SUCCESS)
              {
                 _NFIdebug ((fname, "FIg_set_state = <%d>\n", status));
                 ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_set_state",
                                 status);
                 _NFIdebug ((fname, " returning FAILURE\n"));
                 return (NFI_E_FORM);
              } 
             
             /* get and set the notify_on_transition toggle information. */

             str[0] = 0;
             status = (long) FIfld_get_text (form, mcf_label, i, 6,
                             2, str, &sel_flag, &r_pos);
             if (status != FI_SUCCESS)
              {
                 _NFIdebug ((fname, "FIfld_get_text = <%d>\n", status));
                 ERRload_struct (NFI, NFI_E_FORM, "%s%d",
                                 "FIfld_get_text", status);
                 _NFIdebug ((fname, " returning FAILURE\n"));
                 return (NFI_E_FORM);
              } 

             /* Set the toggle state based on the string */

             if (strcmp (str, "Y") == 0)
                state = FALSE;  /* OFF = 'Y' on = 'N' */
             else
                state = TRUE;  

             status = (long) FIg_set_state (form, NOTIFY_TOGGLE, state);
             if (status != FI_SUCCESS)
              {
                 _NFIdebug ((fname, "FIg_set_state = <%d>\n", status));
                 ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_set_state",
                                 status);
                 _NFIdebug ((fname, " returning FAILURE\n"));
                 return (NFI_E_FORM);
              } 

             break;
          }
      } 

     status = NFI_S_SUCCESS;
     _NFIdebug ((fname, " returning <0x%.8x>\n", status));
     return (status);
  }


long _WFFupdate_trans_name (form, g_label, mcf_label, ptr)
     Form        form;
     int         g_label; 
     int         mcf_label; 
     WFFadd_ptr  ptr;
  {
     long   status;
     int    sel_flag = FALSE, row = -1;  
     int    rows = 0, length = 100, i, j;
     int    r_pos, s_row = 0;
     short  t_name = FALSE, f_state = FALSE; 
     char   from_state[48];
     char   s_name[128];
     char   trans_name[128];

     static char *fname = "_WFFupdate_trans_name";

     _NFIdebug ((fname, "g_label   = <%d>\n", g_label));
     _NFIdebug ((fname, "mcf_label = <%d>\n", mcf_label));

     strcpy (s_name, "");

     /* Get the number of rows from the MCF (the trans_list may
        not match the no of rows in the MCF).                     */

     status = FIfld_get_num_rows (form, mcf_label, &rows);
     if (status != FI_SUCCESS)
      {
         _NFIdebug ((fname, "FIfld_get_num_rows = <%d>\n", status));
         ERRload_struct (NFI, NFI_E_FORM, "%s%d",
                         "FIfld_get_num_rows", status);
         _NFIdebug ((fname, " returning FAILURE\n"));
         return (NFI_E_FORM);
      } 

     /* Check to see if a transition is selected */

     for (i = 0; i < rows; ++i)
      {
         status = (long) FIfld_get_select (form, mcf_label, i, 0, &sel_flag);
         if (status != FI_SUCCESS)
          {
             _NFIdebug ((fname, "FIfld_get_select = <%d>\n", status));
             ERRload_struct (NFI, NFI_E_FORM, "%s%d",
                             "FIfld_get_select", status);
             _NFIdebug ((fname, " returning FAILURE\n"));
             return (NFI_E_FORM);
          } 

         if (sel_flag)
          {
             row = i;  /* selected row */

             /* Get the text string */

             FIfld_get_text (form, mcf_label, i, 0, length + 1, s_name,
                             &sel_flag, &r_pos);
             FIfld_get_text (form, mcf_label, i, 2, 41, from_state,
                             &sel_flag, &r_pos);
             break;
          }
      } 

     if (row == -1)
      {
         /* No row has been selected.  This is probably a new transition */

         _NFIdebug ((fname, " returning SUCCESS\n"));
         return (NFI_S_SUCCESS);
      }

     _NFIdebug ((fname, " row = <%d>\n", row));
     strcpy (trans_name, "");

     /* get the transition_name from the TRANS_NAME_FIELD */

     status = _WFFget_data_from_field (form, g_label, 0, 0, trans_name, length);
     if (status != NFI_S_SUCCESS)
      {
         _NFIdebug ((fname, " WFFget_data_from_field = <0x%.8x>\n", status));
         _NFIdebug ((fname, " returning FAILURE\n"));
         return (status);
      }

     /* If the transition_name is null, send a warning to user */ 

     if (strcmp (trans_name, "") == 0)
      {
        /* Put up a message warning user that trans_name is null */

        FIfld_set_text (form, g_label, 0, 0, s_name, FALSE);
        _WFFmessage (NFI_W_NULL_TRANS_NAME, NULL);
         _NFIdebug ((fname, " returning SUCCESS\n"));
         return (NFI_S_SUCCESS);
      } 
   
     /* check to see if the row is a duplicate : if it is exit, send warning */

     if (ptr->trans_list != NULL)
      {
/* IGI Intel Solaris Port - CN 31/5/95 */
#if defined(OS_SCO_UNIX) || defined(OS_INTELSOL)
	/* To set font for SCO - CRN 25 Feb 94	*/
	FIg_set_font(form, g_label, "7x13bold", 15);
#endif
        for (i = 0; i < ptr->num_trans; ++i)
         {
           if (ptr->trans_list[i].row != row) 
           {
             if (strcmp (ptr->trans_list[i].trans_name, trans_name) == 0)
                 t_name = TRUE;
             if (strcmp (ptr->trans_list[i].from_state, from_state) == 0)
                 f_state = TRUE;

             if ((t_name) && (f_state) && 
                 (strcmp (ptr->trans_list[i].status, WFF_DROP) != 0)) 
              {
                  /* Reset the trans_name field back to its original value */
   
                  status = (long) FIfld_set_text (form, g_label, 0, 0, 
                                                  s_name, FALSE);
                  if (status != FI_SUCCESS)
                   {
                      _NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
                      ERRload_struct (NFI, NFI_E_FORM, "%s%d",
                                      "FIfld_set_text", status);
                      _NFIdebug ((fname, " returning FAILURE\n"));
                      return (NFI_E_FORM);
                   } 
   
                  /* Put up a message warning user that transition is a
                     duplicate */
   
                  _WFFmessage (NFI_W_DUPLICATE_TRANS_FROM, NULL);
   
                  return (NFI_S_SUCCESS);
              }  

             t_name = FALSE;
             f_state = FALSE;
           }  
          else
           {
              s_row = i;
           }
         }
      }

     _NFIdebug ((fname, "s_row  = <%d>\n", s_row));
     _NFIdebug ((fname, "s_name = <%s>\n", s_name));

     /* Put up a working message */

     /* _WFFmessage (NFI_I_MODIFY_TRANSITION, "%s", s_name); */


     /* Update the access_list transition field */

     for (i = 0; i < ptr->num_access; ++i)
      {
         if (strcmp (ptr->access_list[i].status, WFF_DROP) == 0)
            continue;

         for (j = 0; j < ptr->access_list[i].num_trans; ++j)
          {
             if ((strcmp (ptr->access_list[i].trans_ptr[j].trans_name,
                          s_name) == 0) &&
                 (strcmp (ptr->access_list[i].trans_ptr[j].from_state,
                          from_state) == 0) &&
                 (strcmp (ptr->access_list[i].trans_ptr[j].status,
                          WFF_DROP) != 0)) 
              {
                 /* Modify the transition_name */
    
                 strcpy (ptr->access_list[i].trans_ptr[j].trans_name,
                         trans_name);
                 if (strcmp (ptr->access_list[i].trans_ptr[j].status, "") == 0)
                  {
                      strcpy (ptr->access_list[i].trans_ptr[j].status,
                              WFF_MODIFY);
                  }
              } 
          } 
      } 

     /* Update the existing transition in the trans_list */

     strcpy (ptr->trans_list[s_row].trans_name, trans_name); 
     if (strcmp (ptr->trans_list[s_row].status, "") == 0)
        strcpy (ptr->trans_list[s_row].status, WFF_MODIFY); 

     /* Update the MCF */

/* IGI Intel Solaris Port - CN 31/5/95 */
#if defined(OS_SCO_UNIX) || defined(OS_INTELSOL)
	/* To set font for SCO - CRN 25 Feb 94	*/
	FIg_set_font(form, mcf_label, "7x13bold", 15);
#endif
     status = (long) FIfld_set_text (form, mcf_label, row, 0, 
                                     trans_name, TRUE);
     if (status != FI_SUCCESS)
      {
         _NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
         ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_text",
                         status);
         _NFIdebug ((fname, " returning FAILURE\n"));
         return (NFI_E_FORM);
      } 

     /* set the row to be in the viewing area */

     _WFFset_active_row (form, TRANS_LIST_MCF, row, 1);

     status = NFI_S_SUCCESS;
     _NFIdebug ((fname, " returning <0x%.8x>\n", status));
     return (status);
  }


long _WFFupdate_t_command_name (form, g_label, mcf_label, ptr)
     Form        form;
     int         g_label; 
     int         mcf_label; 
     WFFadd_ptr  ptr;
  {
     long   status;
     int    sel_flag = FALSE, row = -1;  
     int    rows = 0, length = 100, i, j;
     int    r_pos, s_row = 0;
     int    num_rows;
     short  c_name = FALSE, t_state = FALSE, f_state = FALSE; 
     char   from_state[48];
     char   to_state[48];
     char   s_name[128];
     char   command_name[128];

     static char *fname = "_WFFupdate_t_command_name";

     _NFIdebug ((fname, "g_label   = <%d>\n", g_label));
     _NFIdebug ((fname, "mcf_label = <%d>\n", mcf_label));

     strcpy (s_name, "");

     /* Get the number of rows from the MCF (the trans_list may
        not match the no of rows in the MCF).                     */

     status = FIfld_get_num_rows (form, mcf_label, &rows);
     if (status != FI_SUCCESS)
      {
         _NFIdebug ((fname, "FIfld_get_num_rows = <%d>\n", status));
         ERRload_struct (NFI, NFI_E_FORM, "%s%d",
                         "FIfld_get_num_rows", status);
         _NFIdebug ((fname, " returning FAILURE\n"));
         return (NFI_E_FORM);
      } 

     /* Check to see if a transition is selected */

     for (i = 0; i < rows; ++i)
      {
         status = (long) FIfld_get_select (form, mcf_label, i, 0, &sel_flag);
         if (status != FI_SUCCESS)
          {
             _NFIdebug ((fname, "FIfld_get_select = <%d>\n", status));
             ERRload_struct (NFI, NFI_E_FORM, "%s%d",
                             "FIfld_get_select", status);
             _NFIdebug ((fname, " returning FAILURE\n"));
             return (NFI_E_FORM);
          } 

         if (sel_flag)
          {
             row = i;  /* selected row */

             /* Get the text string */

             FIfld_get_text (form, mcf_label, i, 1, length + 1, s_name,
                             &sel_flag, &r_pos);
             FIfld_get_text (form, mcf_label, i, 2, 41, from_state,
                             &sel_flag, &r_pos);
             FIfld_get_text (form, mcf_label, i, 3, 41, to_state,
                             &sel_flag, &r_pos);
             break;
          }
      } 

     if (row == -1)
      {
         /* No row has been selected.  This is probably a new transition */

         _NFIdebug ((fname, " returning SUCCESS\n"));
         return (NFI_S_SUCCESS);
      }

     _NFIdebug ((fname, " row = <%d>\n", row));
     strcpy (command_name, "");

     status = FIfld_get_num_rows (form, COMMAND_LIST_SCF, &num_rows);
     if (status != FI_SUCCESS)
      {
         _NFIdebug ((fname, "FIfld_get_num_rows = <%d>\n", status));
         ERRload_struct (NFI, NFI_E_FORM, "%s%d",
                         "FIfld_get_num_rows", status);
         _NFIdebug ((fname, " returning FAILURE\n"));
         return (NFI_E_FORM);
      } 

     /* get the command_name from the COMMAND_LIST_SCF */

     for (j = 0; j < num_rows; ++j)
      { 
         status = (long) FIfld_get_select (form, g_label, j, 0, &sel_flag);
         if (status != FI_SUCCESS)
          {
             _NFIdebug ((fname, " FIfld_get_select = <0x%.8x>\n", status));
             ERRload_struct (NFI, NFI_E_FORM, "%s%d",  
                             "FIfld_get_select", status);
             _NFIdebug ((fname, " returning FAILURE\n"));
             return (status);
          }

         if (sel_flag)
          { 
             FIfld_get_text (form, g_label, j, 0, length + 1, command_name,
                             &sel_flag, &r_pos);
             break;
          }
      }

     _NFIdebug ((fname, " command_name = <%s>\n", command_name));

     /* If the command_name is null, send a warning to user */ 

     if (strcmp (command_name, "") == 0)
      {
        /* Put up a message warning user that command_name is null */

        _WFFmessage (NFI_W_NULL_COMMAND_NAME, NULL);

        for (j = 0; j < num_rows; ++j)
         {
           FIfld_get_text (form, COMMAND_LIST_SCF, j, 0, length + 1,
                           command_name, &sel_flag, &r_pos); 
           if (strcmp (s_name, command_name) == 0)
            { 
              FImcf_set_select (form, COMMAND_LIST_SCF, j, TRUE);
              break;
            }
         } 
         _NFIdebug ((fname, " returning SUCCESS\n"));
         return (NFI_S_SUCCESS);
      } 
    _NFIdebug ((fname, " row = <%d>\n", row));
   
     /* check to see if the row is a duplicate : if it is exit, send warning */

     if (ptr->trans_list != NULL)
      {
        for (i = 0; i < ptr->num_trans; ++i)
         {
           _NFIdebug ((fname, " ptr->trans_list[%d].row = <%d>\n", i, 
                       ptr->trans_list[i].row));
           if (ptr->trans_list[i].row != row) 
           {
             if (strcmp (ptr->trans_list[i].command_name, command_name) == 0)
                 c_name = TRUE;
             if (strcmp (ptr->trans_list[i].from_state, from_state) == 0)
                 f_state = TRUE;
             if (strcmp (ptr->trans_list[i].to_state, to_state) == 0)
                 t_state = TRUE;

             if ((c_name) && (f_state) && (t_state) &&
                 (strcmp (ptr->trans_list[i].status, WFF_DROP) != 0)) 
              {
                  /* Reselect the command_name back to its original value */
   
                  for (j = 0; j < num_rows; ++j)
                   {
                      status = (long) FIfld_get_text (form, COMMAND_LIST_SCF,
                            j, 0, length + 1, command_name, &sel_flag, &r_pos); 
                      if (status != FI_SUCCESS)
                       {
                          _NFIdebug ((fname, "FIfld_get_text = <%d>\n",
                                      status));
                          ERRload_struct (NFI, NFI_E_FORM, "%s%d",
                                          "FIfld_get_text", status);
                          _NFIdebug ((fname, " returning FAILURE\n"));
                          return (NFI_E_FORM);
                       } 

                      if (strcmp (s_name, command_name) == 0)
                       { 
                          status = (long) FImcf_set_select (form, 
                                               COMMAND_LIST_SCF, j, TRUE);
                          if (status != FI_SUCCESS)
                           {
                              _NFIdebug ((fname, "FIfld_set_select = <%d>\n",
                                          status));
                              ERRload_struct (NFI, NFI_E_FORM, "%s%d",
                                              "FIfld_set_select", status);
                              _NFIdebug ((fname, " returning FAILURE\n"));
                              return (NFI_E_FORM);
                           } 
                          _WFFset_active_row (form, COMMAND_LIST_SCF, j, 1);
                          break;
                       } 
                   } 
   
                  /* Put up a message warning user that transition is a
                     duplicate */
   
                  _WFFmessage (NFI_W_DUPLICATE_COMM_FROM_TO, NULL);
   
                  return (NFI_S_SUCCESS);
              }  
           }  
          else
           {
              s_row = i;
           }
          c_name = FALSE;
          f_state = FALSE;
          t_state = FALSE;
         }
      }

     _NFIdebug ((fname, "s_row  = <%d>\n", s_row));
     _NFIdebug ((fname, "s_name = <%s>\n", s_name));

     /* Put up a working message */

     /* _WFFmessage (NFI_I_MODIFY_TRANSITION, "%s", s_name); */

     /* Update the existing command in the trans_list */

     strcpy (ptr->trans_list[s_row].command_name, command_name); 
     if (strcmp (ptr->trans_list[s_row].status, "") == 0)
        strcpy (ptr->trans_list[s_row].status, WFF_MODIFY); 

     /* Update the MCF */

/* IGI Intel Solaris Port - CN 31/5/95 */
#if defined(OS_SCO_UNIX) || defined(OS_INTELSOL)
	/* To set font for SCO - CRN 25 Feb 94	*/
	FIg_set_font(form, mcf_label, "7x13bold", 15);
#endif
     status = (long) FIfld_set_text (form, mcf_label, row, 1, 
                                     command_name, TRUE);
     if (status != FI_SUCCESS)
      {
         _NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
         ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_text",
                         status);
         _NFIdebug ((fname, " returning FAILURE\n"));
         return (NFI_E_FORM);
      } 

     /* set the row to be in the viewing area */

     _WFFset_active_row (form, TRANS_LIST_MCF, row, 1);

     status = NFI_S_SUCCESS;
     _NFIdebug ((fname, " returning <0x%.8x>\n", status));
     return (status);
  }



long _WFFupdate_t_from_state (form, g_label, mcf_label, ptr)
     Form        form;
     int         g_label; 
     int         mcf_label; 
     WFFadd_ptr  ptr;
  {
     long   status;
     int    sel_flag = FALSE, row = -1;  
     int    rows = 0, length = 40, i, j;
     int    r_pos, s_row = 0;
     int    num_rows;
     short  t_name = FALSE, c_name = FALSE, t_state = FALSE, f_state = FALSE; 
     char   from_state[48];
     char   to_state[48];
     char   s_name[48];
     char   trans_name[128];
     char   command_name[128];

     static char *fname = "_WFFupdate_t_from_state";

     _NFIdebug ((fname, "g_label   = <%d>\n", g_label));
     _NFIdebug ((fname, "mcf_label = <%d>\n", mcf_label));

     strcpy (s_name, "");

     /* Get the number of rows from the MCF (the trans_list may
        not match the no of rows in the MCF).                     */

     status = FIfld_get_num_rows (form, mcf_label, &rows);
     if (status != FI_SUCCESS)
      {
         _NFIdebug ((fname, "FIfld_get_num_rows = <%d>\n", status));
         ERRload_struct (NFI, NFI_E_FORM, "%s%d",
                         "FIfld_get_num_rows", status);
         _NFIdebug ((fname, " returning FAILURE\n"));
         return (NFI_E_FORM);
      } 

     /* Check to see if a transition is selected */

     for (i = 0; i < rows; ++i)
      {
         status = (long) FIfld_get_select (form, mcf_label, i, 0, &sel_flag);
         if (status != FI_SUCCESS)
          {
             _NFIdebug ((fname, "FIfld_get_select = <%d>\n", status));
             ERRload_struct (NFI, NFI_E_FORM, "%s%d",
                             "FIfld_get_select", status);
             _NFIdebug ((fname, " returning FAILURE\n"));
             return (NFI_E_FORM);
          } 

         if (sel_flag)
          {
             row = i;  /* selected row */

             /* Get the text string */

             FIfld_get_text (form, mcf_label, i, 0, 101, trans_name,
                             &sel_flag, &r_pos);
             FIfld_get_text (form, mcf_label, i, 1, 101, command_name,
                             &sel_flag, &r_pos);
             FIfld_get_text (form, mcf_label, i, 2, length + 1, s_name,
                             &sel_flag, &r_pos);
             FIfld_get_text (form, mcf_label, i, 3, length + 1, to_state,
                             &sel_flag, &r_pos);
             break;
          }
      } 

     if (row == -1)
      {
         /* No row has been selected.  This is probably a new transition */

         _NFIdebug ((fname, " returning SUCCESS\n"));
         return (NFI_S_SUCCESS);
      }

     _NFIdebug ((fname, " row = <%d>\n", row));
     strcpy (from_state, "");

     status = FIfld_get_num_rows (form, FROM_STATE_LIST_SCF, &num_rows);
     if (status != FI_SUCCESS)
      {
         _NFIdebug ((fname, "FIfld_get_num_rows = <%d>\n", status));
         ERRload_struct (NFI, NFI_E_FORM, "%s%d",
                         "FIfld_get_num_rows", status);
         _NFIdebug ((fname, " returning FAILURE\n"));
         return (NFI_E_FORM);
      } 

     /* get the from_state from the FROM_STATE_LIST_SCF */

     for (j = 0; j < num_rows; ++j)
      { 
         status = (long) FIfld_get_select (form, g_label, j, 0, &sel_flag);
         if (status != FI_SUCCESS)
          {
             _NFIdebug ((fname, " FIfld_get_select = <0x%.8x>\n", status));
             ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_get_select",
                             status);
             _NFIdebug ((fname, " returning FAILURE\n"));
             return (status);
          }

         if (sel_flag)
          { 
             FIfld_get_text (form, g_label, j, 0, length + 1, from_state,
                             &sel_flag, &r_pos);
             break;
          }
      }

     /* If the from_state is null, send a warning to user */ 

     if (strcmp (from_state, "") == 0)
      {
        /* Put up a message warning user that from_state is null */

        _WFFmessage (NFI_W_NULL_FROM_STATE, NULL);

        for (j = 0; j < num_rows; ++j)
         {
           FIfld_get_text (form, FROM_STATE_LIST_SCF, j, 0, length + 1,
                           to_state, &sel_flag, &r_pos); 
           if (strcmp (s_name, from_state) == 0)
            { 
              FIfld_set_select (form, FROM_STATE_LIST_SCF, j, 0, TRUE);
              break;
            }
         } 
         _NFIdebug ((fname, " returning SUCCESS\n"));
         return (NFI_S_SUCCESS);
      } 
   
     /* check to see if the row is a duplicate : if it is exit, send warning */

     if (ptr->trans_list != NULL)
      {
        for (i = 0; i < ptr->num_trans; ++i)
         {
           if (ptr->trans_list[i].row != row) 
           {
             if (strcmp (ptr->trans_list[i].command_name, command_name) == 0)
                 c_name = TRUE;
             if (strcmp (ptr->trans_list[i].from_state, from_state) == 0)
                 f_state = TRUE;
             if (strcmp (ptr->trans_list[i].to_state, to_state) == 0)
                 t_state = TRUE;

             if ((c_name) && (f_state) && (t_state) &&
                 (strcmp (ptr->trans_list[i].status, WFF_DROP) != 0)) 
              {
                  /* Reselect the from_state back to its original value */
   
                  for (j = 0; j < num_rows; ++j)
                   {
                      status = (long) FIfld_get_text (form, FROM_STATE_LIST_SCF,
                            j, 0, length + 1, from_state, &sel_flag, &r_pos); 
                      if (status != FI_SUCCESS)
                       {
                          _NFIdebug ((fname, "FIfld_get_text = <%d>\n",
                                      status));
                          ERRload_struct (NFI, NFI_E_FORM, "%s%d",
                                          "FIfld_get_text", status);
                          _NFIdebug ((fname, " returning FAILURE\n"));
                          return (NFI_E_FORM);
                       } 

                      if (strcmp (s_name, from_state) == 0)
                       { 
                          status = (long) FIfld_set_select (form, 
                                            FROM_STATE_LIST_SCF, j, 0, TRUE);
                          if (status != FI_SUCCESS)
                           {
                              _NFIdebug ((fname, "FIfld_set_select = <%d>\n",
                                          status));
                              ERRload_struct (NFI, NFI_E_FORM, "%s%d",
                                              "FIfld_set_select", status);
                              _NFIdebug ((fname, " returning FAILURE\n"));
                              return (NFI_E_FORM);
                           } 
                          _WFFset_active_row (form, FROM_STATE_LIST_SCF, j, 1);
                          break;
                       } 
                   } 
   
                  /* Put up a message warning user that transition is a
                     duplicate */
   
                  _WFFmessage (NFI_W_DUPLICATE_COMM_FROM_TO, NULL);
   
                  return (NFI_S_SUCCESS);
              }  

             if (strcmp (ptr->trans_list[i].trans_name, trans_name) == 0)
                 t_name = TRUE;

             if ((t_name) && (f_state) && 
                 (strcmp (ptr->trans_list[i].status, WFF_DROP) != 0)) 
              {
                 /* Reselect the from_state back to its original value */
   
                 for (j = 0; j < num_rows; ++j)
                  {
                     status = (long) FIfld_get_text (form, FROM_STATE_LIST_SCF,
                           j, 0, length + 1, from_state, &sel_flag, &r_pos); 
                     if (status != FI_SUCCESS)
                      {
                         _NFIdebug ((fname, "FIfld_get_text = <%d>\n",
                                     status));
                         ERRload_struct (NFI, NFI_E_FORM, "%s%d",
                                         "FIfld_get_text", status);
                         _NFIdebug ((fname, " returning FAILURE\n"));
                         return (NFI_E_FORM);
                      } 

                     if (strcmp (s_name, from_state) == 0)
                      { 
                         status = (long) FIfld_set_select (form, 
                                           FROM_STATE_LIST_SCF, j, 0, TRUE);
                         if (status != FI_SUCCESS)
                          {
                             _NFIdebug ((fname, "FIfld_set_select = <%d>\n",
                                         status));
                             ERRload_struct (NFI, NFI_E_FORM, "%s%d",
                                             "FIfld_set_select", status);
                             _NFIdebug ((fname, " returning FAILURE\n"));
                             return (NFI_E_FORM);
                          } 
                         _WFFset_active_row (form, FROM_STATE_LIST_SCF, j, 1);
                         break;
                      } 
                   } 
   
                  /* Put up a message warning user that transition is a
                     duplicate */
   
                  _WFFmessage (NFI_W_DUPLICATE_TRANS_FROM, NULL);
   
                  return (NFI_S_SUCCESS);
              }  

             t_name = FALSE;
             c_name = FALSE;
             f_state = FALSE;
             t_state = FALSE;
           }  
          else
           {
              s_row = i;
           }
         }
      }

     _NFIdebug ((fname, "s_row  = <%d>\n", s_row));
     _NFIdebug ((fname, "s_name = <%s>\n", s_name));

     /* Put up a working message */

     /* _WFFmessage (NFI_I_MODIFY_TRANSITION, "%s", s_name); */


     /* Update the access_list transition field */

     for (i = 0; i < ptr->num_access; ++i)
      {
         if (strcmp (ptr->access_list[i].status, WFF_DROP) == 0)
            continue;

         for (j = 0; j < ptr->access_list[i].num_trans; ++j)
          {
             if ((strcmp (ptr->access_list[i].trans_ptr[j].from_state,
                          s_name) == 0) &&
                 (strcmp (ptr->access_list[i].trans_ptr[j].trans_name,
                          trans_name) == 0) &&
                 (strcmp (ptr->access_list[i].trans_ptr[j].status,
                          WFF_DROP) != 0)) 
              {
                 /* Modify the transition_name */
    
                 strcpy (ptr->access_list[i].trans_ptr[j].from_state,
                         from_state);
                 if (strcmp (ptr->access_list[i].trans_ptr[j].status, "") == 0)
                  {
                      strcpy (ptr->access_list[i].trans_ptr[j].status,
                              WFF_MODIFY);
                  }
              } 
          } 
      } 

     /* Update the existing command in the trans_list */

     strcpy (ptr->trans_list[s_row].from_state, from_state); 
     if (strcmp (ptr->trans_list[s_row].status, "") == 0)
        strcpy (ptr->trans_list[s_row].status, WFF_MODIFY); 

     /* Update the MCF */

/* IGI Intel Solaris Port - CN 31/5/95 */
#if defined(OS_SCO_UNIX) || defined(OS_INTELSOL)
	/* To set font for SCO - CRN 25 Feb 94	*/
	FIg_set_font(form, mcf_label, "7x13bold", 15);
#endif
     status = (long) FIfld_set_text (form, mcf_label, row, 2, 
                                     from_state, TRUE);
     if (status != FI_SUCCESS)
      {
         _NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
         ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_text",
                         status);
         _NFIdebug ((fname, " returning FAILURE\n"));
         return (NFI_E_FORM);
      } 

     /* set the row to be in the viewing area */

     _WFFset_active_row (form, TRANS_LIST_MCF, row, 1);

     status = NFI_S_SUCCESS;
     _NFIdebug ((fname, " returning <0x%.8x>\n", status));
     return (status);
  }



long _WFFupdate_t_to_state (form, g_label, mcf_label, ptr)
     Form        form;
     int         g_label; 
     int         mcf_label; 
     WFFadd_ptr  ptr;
  {
     long   status;
     int    sel_flag = FALSE, row = -1;  
     int    rows = 0, length = 40, i, j;
     int    r_pos, s_row = 0;
     int    num_rows;
     short  c_name = FALSE, t_state = FALSE, f_state = FALSE; 
     char   from_state[48];
     char   to_state[48];
     char   s_name[48];
     char   command_name[128];
     char   trans_name[128];

     static char *fname = "_WFFupdate_t_to_state";

     _NFIdebug ((fname, "g_label   = <%d>\n", g_label));
     _NFIdebug ((fname, "mcf_label = <%d>\n", mcf_label));

     strcpy (s_name, "");

     /* Get the number of rows from the MCF (the trans_list may
        not match the no of rows in the MCF).                     */

     status = FIfld_get_num_rows (form, mcf_label, &rows);
     if (status != FI_SUCCESS)
      {
         _NFIdebug ((fname, "FIfld_get_num_rows = <%d>\n", status));
         ERRload_struct (NFI, NFI_E_FORM, "%s%d",
                         "FIfld_get_num_rows", status);
         _NFIdebug ((fname, " returning FAILURE\n"));
         return (NFI_E_FORM);
      } 

     /* Check to see if a transition is selected */

     for (i = 0; i < rows; ++i)
      {
         status = (long) FIfld_get_select (form, mcf_label, i, 0, &sel_flag);
         if (status != FI_SUCCESS)
          {
             _NFIdebug ((fname, "FIfld_get_select = <%d>\n", status));
             ERRload_struct (NFI, NFI_E_FORM, "%s%d",
                             "FIfld_get_select", status);
             _NFIdebug ((fname, " returning FAILURE\n"));
             return (NFI_E_FORM);
          } 

         if (sel_flag)
          {
             row = i;  /* selected row */

             /* Get the text string */

             FIfld_get_text (form, mcf_label, i, 0, 101, trans_name,
                             &sel_flag, &r_pos);
             FIfld_get_text (form, mcf_label, i, 1, 101, command_name,
                             &sel_flag, &r_pos);
             FIfld_get_text (form, mcf_label, i, 2, length + 1, from_state,
                             &sel_flag, &r_pos);
             FIfld_get_text (form, mcf_label, i, 3, length + 1, s_name,
                             &sel_flag, &r_pos);
             break;
          }
      } 

     if (row == -1)
      {
         /* No row has been selected.  This is probably a new transition */

         _NFIdebug ((fname, " returning SUCCESS\n"));
         return (NFI_S_SUCCESS);
      }

     _NFIdebug ((fname, " row = <%d>\n", row));
     strcpy (to_state, "");

     status = FIfld_get_num_rows (form, TO_STATE_LIST_SCF, &num_rows);
     if (status != FI_SUCCESS)
      {
         _NFIdebug ((fname, "FIfld_get_num_rows = <%d>\n", status));
         ERRload_struct (NFI, NFI_E_FORM, "%s%d",
                         "FIfld_get_num_rows", status);
         _NFIdebug ((fname, " returning FAILURE\n"));
         return (NFI_E_FORM);
      } 

     /* get the to_state from the TO_STATE_LIST_SCF */

     for (j = 0; j < num_rows; ++j)
      { 
         status = (long) FIfld_get_select (form, g_label, j, 0, &sel_flag);
         if (status != FI_SUCCESS)
          {
             _NFIdebug ((fname, " FIfld_get_select = <0x%.8x>\n", status));
             ERRload_struct (NFI, NFI_E_FORM, "%s%d",
                             "FIfld_get_select", status);
             _NFIdebug ((fname, " returning FAILURE\n"));
             return (status);
          }

         if (sel_flag)
          { 
             FIfld_get_text (form, g_label, j, 0, length + 1, to_state,
                             &sel_flag, &r_pos);
             break;
          }
      }

     /* If the to_state is null, send a warning to user */ 

     if (strcmp (to_state, "") == 0)
      {
        /* Put up a message warning user that to_state is null */

        _WFFmessage (NFI_W_NULL_TO_STATE, NULL);

        for (j = 0; j < num_rows; ++j)
         {
           FIfld_get_text (form, TO_STATE_LIST_SCF, j, 0, length + 1,
                           to_state, &sel_flag, &r_pos); 
           if (strcmp (s_name, to_state) == 0)
            { 
              FIfld_set_select (form, TO_STATE_LIST_SCF, j, 0, TRUE);
              break;
            }
         } 

         _NFIdebug ((fname, " returning SUCCESS\n"));
         return (NFI_S_SUCCESS);
      } 
   
     /* check to see if the row is a duplicate : if it is exit, send warning */

     if (ptr->trans_list != NULL)
      {
        for (i = 0; i < ptr->num_trans; ++i)
         {
           if (ptr->trans_list[i].row != row) 
           {
             if (strcmp (ptr->trans_list[i].command_name, command_name) == 0)
                 c_name = TRUE;
             if (strcmp (ptr->trans_list[i].from_state, from_state) == 0)
                 f_state = TRUE;
             if (strcmp (ptr->trans_list[i].to_state, to_state) == 0)
                 t_state = TRUE;

             if ((c_name) && (f_state) && (t_state) &&
                 (strcmp (ptr->trans_list[i].status, WFF_DROP) != 0)) 
              {
                  /* Reselect the to_state back to its original value */
   
                  for (j = 0; j < num_rows; ++j)
                   {
                      status = (long) FIfld_get_text (form, TO_STATE_LIST_SCF,
                            j, 0, length + 1, to_state, &sel_flag, &r_pos); 
                      if (status != FI_SUCCESS)
                       {
                          _NFIdebug ((fname, "FIfld_get_text = <%d>\n",
                                      status));
                          ERRload_struct (NFI, NFI_E_FORM, "%s%d",
                                          "FIfld_get_text", status);
                          _NFIdebug ((fname, " returning FAILURE\n"));
                          return (NFI_E_FORM);
                       } 

                      if (strcmp (s_name, to_state) == 0)
                       { 
                          status = (long) FIfld_set_select (form, 
                                            TO_STATE_LIST_SCF, j, 0, TRUE);
                          if (status != FI_SUCCESS)
                           {
                              _NFIdebug ((fname, "FIfld_set_select = <%d>\n",
                                          status));
                              ERRload_struct (NFI, NFI_E_FORM, "%s%d",
                                              "FIfld_set_select", status);
                              _NFIdebug ((fname, " returning FAILURE\n"));
                              return (NFI_E_FORM);
                           } 
                          _WFFset_active_row (form, TO_STATE_LIST_SCF, j, 1);
                          break;
                       } 
                   } 
   
                  /* Put up a message warning user that transition is a
                     duplicate */
   
                  _WFFmessage (NFI_W_DUPLICATE_COMM_FROM_TO, NULL);
   
                  return (NFI_S_SUCCESS);
              }  

             c_name = FALSE;
             f_state = FALSE;
             t_state = FALSE;
           }  
          else
           {
              s_row = i;
           }
         }
      }

     _NFIdebug ((fname, "s_row  = <%d>\n", s_row));
     _NFIdebug ((fname, "s_name = <%s>\n", s_name));

     /* Put up a working message */

     /* _WFFmessage (NFI_I_MODIFY_TRANSITION, "%s", s_name); */


     /* Update the access_list transition field */

     for (i = 0; i < ptr->num_access; ++i)
      {
         if (strcmp (ptr->access_list[i].status, WFF_DROP) == 0)
            continue;

         for (j = 0; j < ptr->access_list[i].num_trans; ++j)
          {
             if ((strcmp (ptr->access_list[i].trans_ptr[j].to_state,
                          s_name) == 0) &&
                 (strcmp (ptr->access_list[i].trans_ptr[j].trans_name,
                          trans_name) == 0) &&
                 (strcmp (ptr->access_list[i].trans_ptr[j].from_state,
                          from_state) == 0) &&
                 (strcmp (ptr->access_list[i].trans_ptr[j].status,
                          WFF_DROP) != 0)) 
              {
                 /* Modify the transition_name */
    
                 strcpy (ptr->access_list[i].trans_ptr[j].to_state,
                         from_state);
                 if (strcmp (ptr->access_list[i].trans_ptr[j].status, "") == 0)
                  {
                      strcpy (ptr->access_list[i].trans_ptr[j].status,
                              WFF_MODIFY);
                  }
              } 
          } 
      } 

     /* Update the existing command in the trans_list */

     strcpy (ptr->trans_list[s_row].to_state, to_state); 
     if (strcmp (ptr->trans_list[s_row].status, "") == 0)
        strcpy (ptr->trans_list[s_row].status, WFF_MODIFY); 

     /* Update the MCF */

/* IGI Intel Solaris Port - CN 31/5/95 */
#if defined(OS_SCO_UNIX) || defined(OS_INTELSOL)
	/* To set font for SCO - CRN 25 Feb 94	*/
	FIg_set_font(form, mcf_label, "7x13bold", 15);
#endif
     status = (long) FIfld_set_text (form, mcf_label, row, 3, 
                                     to_state, TRUE);
     if (status != FI_SUCCESS)
      {
         _NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
         ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_text",
                         status);
         _NFIdebug ((fname, " returning FAILURE\n"));
         return (NFI_E_FORM);
      } 

     /* set the row to be in the viewing area */

     _WFFset_active_row (form, TRANS_LIST_MCF, row, 1);

     status = NFI_S_SUCCESS;
     _NFIdebug ((fname, " returning <0x%.8x>\n", status));
     return (status);
  }


long _WFFupdate_transition_toggles (form, g_label, mcf_label, ptr)
     Form        form;
     int         g_label;    /* toggle label */
     int         mcf_label; 
     WFFadd_ptr  ptr;
  {
     long   status;
     int    g_state;
     int    sel_flag = FALSE, row = -1;  
     int    rows = 0, i;
     int    s_row = 0;
     char   s_state[8];

     static char *fname = "_WFFupdate_transition_toggles";

     _NFIdebug ((fname, "g_label   = <%d>\n", g_label));
     _NFIdebug ((fname, "mcf_label = <%d>\n", mcf_label));

     /* Get the number of rows from the MCF (the transition_list may
        not match the no of rows in the MCF).                     */

     status = FIfld_get_num_rows (form, mcf_label, &rows);
     if (status != FI_SUCCESS)
      {
         _NFIdebug ((fname, "FIfld_get_num_rows = <%d>\n", status));
         ERRload_struct (NFI, NFI_E_FORM, "%s%d",
                         "FIfld_get_num_rows", status);
         _NFIdebug ((fname, " returning FAILURE\n"));
         return (NFI_E_FORM);
      } 

     /* Check to see if a transition is selected */

     for (i = 0; i < rows; ++i)
      {
         status = (long) FIfld_get_select (form, mcf_label, i, 0, &sel_flag);
         if (status != FI_SUCCESS)
          {
             _NFIdebug ((fname, "FIfld_get_select = <%d>\n", status));
             ERRload_struct (NFI, NFI_E_FORM, "%s%d",
                             "FIfld_get_select", status);
             _NFIdebug ((fname, " returning FAILURE\n"));
             return (NFI_E_FORM);
          } 

         if (sel_flag)
          {
             row = i;  /* selected row */
             break;
          }
      } 

     if (row == -1)
      {
         /* No row has been selected.  This is probably a new transition */

         _NFIdebug ((fname, " returning SUCCESS\n"));
         return (NFI_S_SUCCESS);
      }

     /* find the row in the trans_list to update */

     for (i = 0; i < ptr->num_trans; ++i)
      {
         if ((ptr->trans_list[i].row == row) &&
             (strcmp (ptr->trans_list[i].status, WFF_DROP) != 0))
          {
             s_row = i;
             break;
          }
      }

     _NFIdebug ((fname, "s_row   = <%d>\n", s_row));

/* IGI Intel Solaris Port - CN 31/5/95 */
#if defined(OS_SCO_UNIX) || defined(OS_INTELSOL)
	/* To set font for SCO - CRN 25 Feb 94	*/
	FIg_set_font(form, mcf_label, "7x13bold", 15);
#endif
     switch (g_label)
      {
         case LOGON_SUCCESS_TOGGLE:

            /* get the toggle's state */

            status = (long) FIg_get_state (form, g_label, &g_state);
            if (status != FI_SUCCESS)
             {
                _NFIdebug ((fname, "FIg_get_state = <%d>\n", status));
                ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_get_state",
                                status);
                _NFIdebug ((fname, " returning FAILURE\n"));
             }
 
            if (g_state)
               strcpy (s_state, "N");   /* "N" = on */
            else
               strcpy (s_state, "Y");   /* "Y" = off */
     
            strcpy (ptr->trans_list[s_row].logon_success, s_state); 

            /* Update the MCF */

            status = (long) FIfld_set_text (form, mcf_label, row, 4, 
                                            s_state, TRUE);
            if (status != FI_SUCCESS)
             {
                _NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
                ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_text",
                                status);
                _NFIdebug ((fname, " returning FAILURE\n"));
                return (NFI_E_FORM);
             } 
 
         break;

         case LOGON_FAILURE_TOGGLE :

            /* get the toggle's state */

            status = (long) FIg_get_state (form, g_label, &g_state);
            if (status != FI_SUCCESS)
             {
                _NFIdebug ((fname, "FIg_get_state = <%d>\n", status));
                ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_get_state",
                                status);
                _NFIdebug ((fname, " returning FAILURE\n"));
             }
 
            if (g_state)
               strcpy (s_state, "N");  
            else
               strcpy (s_state, "Y");  

            strcpy (ptr->trans_list[s_row].logon_failure, s_state); 

            /* Update the MCF */

            status = (long) FIfld_set_text (form, mcf_label, row, 5, 
                                            s_state, TRUE);
            if (status != FI_SUCCESS)
             {
                _NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
                ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_text",
                                status);
                _NFIdebug ((fname, " returning FAILURE\n"));
                return (NFI_E_FORM);
             } 
         break;

         case NOTIFY_TOGGLE:

            /* get the toggle's state */

            status = (long) FIg_get_state (form, g_label, &g_state);
            if (status != FI_SUCCESS)
             {
                _NFIdebug ((fname, "FIg_get_state = <%d>\n", status));
                ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_get_state",
                                status);
                _NFIdebug ((fname, " returning FAILURE\n"));
             }
 
            if (g_state)
               strcpy (s_state, "N");  
            else
               strcpy (s_state, "Y");  

            strcpy (ptr->trans_list[s_row].n_notify, s_state); 

            /* Update the MCF */

            status = (long) FIfld_set_text (form, mcf_label, row, 6, 
                                            s_state, TRUE);
            if (status != FI_SUCCESS)
             {
                _NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
                ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_text",
                                status);
                _NFIdebug ((fname, " returning FAILURE\n"));
                return (NFI_E_FORM);
             } 
         break;

         default:
            /* Bad gadget label.  This case should not occur... */

            _NFIdebug ((fname, " returning SUCCESS\n"));
            status = NFI_S_SUCCESS;
         break; 
      }

     /* Put up a working message */

     /* _WFFmessage (NFI_I_MODIFY_STATE, "%s", s_name); */

     if (strcmp (ptr->trans_list[s_row].status, "") == 0)
        strcpy (ptr->trans_list[s_row].status, WFF_MODIFY); 

     status = NFI_S_SUCCESS;
     _NFIdebug ((fname, " returning <0x%.8x>\n", status));
     return (status);
  }


long _WFFchange_transition (form, ptr)
     Form        form;
     WFFadd_ptr  ptr;
  {
     long   status;
     int    row = 0;
     int    mcf_row = 0;
     int    j;
     int    i;
     int    num_rows;
     int    sel_flag;
     int    r_pos;
     int    length = 20;
     int    g_state;
     char   old_trans_name[24];
/* PS */
     char   old_command_name[101];
     char   old_from_state[41];
     char   old_to_state[41];

     struct WFFtrans_st *chg_trans;

     static char *fname = "_WFFchange_transition";
     _NFMdebug ((fname, "Enter..\n"));

     chg_trans = (struct WFFtrans_st *) malloc ( sizeof (struct WFFtrans_st));

     status = (long) FIfld_get_num_rows (form, TRANS_LIST_MCF, &num_rows); 
     if (status != FI_SUCCESS)
      {
         _NFIdebug ((fname, "FIfld_get_num_rows = <%d>\n", status));
         ERRload_struct (NFI, NFI_E_FORM, "%s%d",
                         "FIfld_get_num_rows", status);
         return (NFI_E_FORM);
      } 
     
     /* Find selected row in the MCF */

     for (i = 0; i < num_rows; ++i)
      {
         /* See if this transition is selected for change */

         status = (long) FIfld_get_select (form, TRANS_LIST_MCF,i,0,&sel_flag);
         if (status != FI_SUCCESS)
         {
             _NFIdebug ((fname, "FIfld_get_select = <%d>\n", status));
             ERRload_struct (NFI, NFI_E_FORM, "%s%d",
                                 "FIfld_get_select", status);
             return (NFI_E_FORM);
         } 

         if (sel_flag)
         {
             mcf_row = i;  /* selected row */

             /* Get the text string */

             FIfld_get_text (form, TRANS_LIST_MCF, i, 0, length + 1, 
			     old_trans_name, &sel_flag, &r_pos);
	     _NFIdebug((fname, "Old trans name <%s>\n",old_trans_name ));

/* store current command name also - PS */
	     length = 100; /* command names length */

             FIfld_get_text (form, TRANS_LIST_MCF, i, 1, length + 1, 
			     chg_trans[0].command_name, &sel_flag, &r_pos);
	     _NFIdebug((fname, "Command_name <%s>\n",
			     chg_trans[0].command_name ));

	     length = 40; /* state names length */

             FIfld_get_text (form, TRANS_LIST_MCF, i, 2, length + 1, 
			     chg_trans[0].from_state, &sel_flag, &r_pos);
	     _NFIdebug((fname, "FROM_STATE name <%s>\n",
			     chg_trans[0].from_state ));

             FIfld_get_text (form, TRANS_LIST_MCF, i, 3, length + 1, 
			     chg_trans[0].to_state, &sel_flag, &r_pos);
	     _NFIdebug((fname, "TO_STATE name <%s>\n",chg_trans[0].to_state ));

             break;
          }
      }
     if( !sel_flag )
     {
	/*  No old transition was selected */

        _WFFmessage (NFI_W_NO_TRANSITION_SELECTED_CHANGE, NULL);
        _NFIdebug ((fname, "No old transition was selected\n"));
	return( NFI_S_SUCCESS );
     }

     /* get the transition_name from the TRANS_NAME_FIELD */

     status = _WFFget_data_from_field (form, TRANS_NAME_FIELD, 0, 0, 
				       chg_trans[0].trans_name, length);
     if (status != NFI_S_SUCCESS)
      {
         _NFIdebug ((fname, " WFFget_data_from_field = <0x%.8x>\n", status));
         return (status);
      }

     _NFIdebug(( fname, "New trans name <%s>\n", chg_trans[0].trans_name ));

/* PS */
     /* get the command_name from the COMMAND_LIST_SCF */
 
     status = _WFFget_data_from_field (form, COMMAND_LIST_SCF, -1, 0,
                                       chg_trans[0].command_name, 100);
     if (status != NFI_S_SUCCESS)
      {
         _NFIdebug ((fname, " WFFget_data_from_field = <0x%.8x>\n", status));
         return (status);
      }

     /* get the from_state from the FROM_STATE_LIST_SCF */
 
     status = _WFFget_data_from_field (form, FROM_STATE_LIST_SCF, -1, 0,
                                       chg_trans[0].from_state, 40);
     if (status != NFI_S_SUCCESS)
       {
         _NFIdebug ((fname, " WFFget_data_from_field = <0x%.8x>\n",
                     status));
         return (status);
       }

     /* get the to_state from the TO_STATE_LIST_SCF */
 
     status = _WFFget_data_from_field (form, TO_STATE_LIST_SCF, -1, 0,
                                       chg_trans[0].to_state, 40);
     if (status != NFI_S_SUCCESS)
       {
         _NFIdebug ((fname, " WFFget_data_from_field = <0x%.8x>\n",
                     status));
         return (status);
       }

/* end PS */
 
     /*  Get toggle states */

     status = (long) FIg_get_state (form, LOGON_SUCCESS_TOGGLE, &g_state);
     if (status != FI_SUCCESS)
     {
         _NFIdebug ((fname, "FIg_get_state = <%d>\n", status));
         ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_get_state",status);
         _NFIdebug ((fname, " returning FAILURE\n"));
     }

     if (g_state)
         strcpy (chg_trans[0].logon_success, "N"); 
     else
	 strcpy (chg_trans[0].logon_success, "Y" );

     status = (long) FIg_get_state (form, LOGON_FAILURE_TOGGLE, &g_state);
     if (status != FI_SUCCESS)
     {
         _NFIdebug ((fname, "FIg_get_state = <%d>\n", status));
         ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_get_state", status);
         _NFIdebug ((fname, " returning FAILURE\n"));
     }

     if (g_state)
         strcpy (chg_trans[0].logon_failure, "N"); 
     else
	 strcpy (chg_trans[0].logon_failure, "Y" );

     status = (long) FIg_get_state (form, NOTIFY_TOGGLE, &g_state);
     if (status != FI_SUCCESS)
     {
         _NFIdebug ((fname, "FIg_get_state = <%d>\n", status));
         ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_get_state", status);
         _NFIdebug ((fname, " returning FAILURE\n"));
     }

     if (g_state)
         strcpy (chg_trans[0].n_notify, "N"); 
     else
	 strcpy (chg_trans[0].n_notify, "Y" );


     /* If the trans_name is null, send a warning to user */ 

     if (strcmp (chg_trans[0].trans_name, "") == 0)
     {
        /* Put up a message warning user that state null */

        _WFFmessage (NFI_W_NULL_TRANS_NAME, NULL);
        _NFIdebug ((fname, " returning SUCCESS\n"));
        return (NFI_S_SUCCESS);
      } 

     if (ptr->trans_list != NULL)
     {
        for (i = 0; i < ptr->num_trans; ++i)
         {
           if((strcmp(ptr->trans_list[i].trans_name,old_trans_name)==0)&&
	   (strcmp(ptr->trans_list[i].from_state,chg_trans[0].from_state)==0)&&
	   (strcmp(ptr->trans_list[i].to_state,chg_trans[0].to_state) == 0 ))
             {
		_NFIdebug(( fname, "Matched member <%d> in trans_list\n",i));
		_NFMdebug(( fname, "Matched member <%d> in trans_list\n",i));

                row = i;
/* PS 
                strcpy(chg_trans[0].command_name,
		       ptr->trans_list[i].command_name);
*/
	        chg_trans[0].trans_no = ptr->trans_list[i].trans_no;
                strcpy( chg_trans[0].status, WFF_MODIFY );

                break;
             }
	 }
      }
    /*  Now change the transition name in the database */

    _NFMdebug(( fname, "Transition Status <%s>\n", chg_trans[0].status));

    _NFMdebug(( fname, "New transition definition ..\n" ));
    _NFMdebug(( fname, "Transition Name <%s>\n", chg_trans[0].trans_name));
    _NFMdebug(( fname, "Command Name <%s>\n", chg_trans[0].command_name));
    _NFMdebug(( fname, "From State <%s>\n", chg_trans[0].from_state));
    _NFMdebug(( fname, "To State <%s>\n", chg_trans[0].to_state));
    _NFMdebug(( fname, "Logon Success <%s>\n", chg_trans[0].logon_success));
    _NFMdebug(( fname, "Logon Failure <%s>\n", chg_trans[0].logon_failure));
    _NFMdebug(( fname, "Notify <%s>\n", chg_trans[0].n_notify));

/* Do not Update Database now since user may discard the changes - PS 12 Sep 95 

    status = WFGupdate_trans (ptr->workflow_no, 1, chg_trans, "MODIFY" );
    if( status != NFM_S_SUCCESS )
    {
	_NFIdebug(( fname, "_WFGupdate_trans <0x%.8x>\n", status ));
	_WFFmessage( NFI_E_CHANGE_TRANSITION, "%s", old_trans_name );
	return( NFI_E_CHANGE_TRANSITION );
    }
PS IGI */
    /*  Change old information in the trans list */

    _NFIdebug(( fname, "Updating trans_list\n" ));
    strcpy(ptr->trans_list[row].trans_name,chg_trans[0].trans_name);
/* PS */
    strcpy(ptr->trans_list[row].command_name,chg_trans[0].command_name);
    strcpy(ptr->trans_list[row].from_state,chg_trans[0].from_state);
    strcpy(ptr->trans_list[row].to_state,chg_trans[0].to_state);

    strcpy(ptr->trans_list[row].logon_success,chg_trans[0].logon_success);
    strcpy(ptr->trans_list[row].logon_failure, chg_trans[0].logon_failure);
    strcpy(ptr->trans_list[row].n_notify, chg_trans[0].n_notify);

/* to note modified transactions brought from database  PS  12th Sep 95 */
    if(strcmp(ptr->trans_list[row].status,"") == 0)
	strcpy( ptr->trans_list[row].status, WFF_MODIFY );

    if (ptr->access_list != NULL)
    {
        for (i = 0; i < ptr->num_access; ++i)
        {
	    for( j=0; j<ptr->access_list[i].num_trans; ++j )
	    {
                if((strcmp (ptr->access_list[i].trans_ptr[j].trans_name, 
			    chg_trans[0].trans_name) == 0) &&
                   (strcmp (ptr->access_list[i].trans_ptr[j].from_state, 
			    chg_trans[0].from_state) == 0) &&
                   (strcmp (ptr->access_list[i].trans_ptr[j].to_state, 
			    chg_trans[0].to_state) == 0))
		   {
	 	    strcpy (ptr->access_list[i].trans_ptr[j].trans_name,
			    chg_trans[0].trans_name );
/* PS */
                    if (strcmp (ptr->access_list[i].trans_ptr[j].status,
                            "") == 0)
	 	    	strcpy (ptr->access_list[i].trans_ptr[j].status,
			    WFF_MODIFY );
		   }
	    }
        }
    }

    /*  Now put the new transition name in the MCF */

/* IGI Intel Solaris Port - CN 31/5/95 */
#if defined(OS_SCO_UNIX) || defined(OS_INTELSOL)
	/* To set font for SCO - CRN 25 Feb 94	*/
	FIg_set_font(form, TRANS_LIST_MCF, "7x13bold", 15);
#endif
    FIfld_set_text(form,TRANS_LIST_MCF,mcf_row,0,chg_trans[0].trans_name,TRUE);

/* change command, from state and to state also - PS Sep 12th 95 */

    FIfld_set_text(form,TRANS_LIST_MCF, mcf_row, 1, chg_trans[0].command_name,
		   TRUE);
    FIfld_set_text(form,TRANS_LIST_MCF, mcf_row, 2, chg_trans[0].from_state,
		   TRUE);
    FIfld_set_text(form,TRANS_LIST_MCF, mcf_row, 3, chg_trans[0].to_state,
		   TRUE);

    FIfld_set_text(form,TRANS_LIST_MCF, mcf_row, 4, chg_trans[0].logon_success,
		   TRUE);
    FIfld_set_text(form,TRANS_LIST_MCF, mcf_row, 5, chg_trans[0].logon_failure,
		   TRUE );
    FIfld_set_text(form,TRANS_LIST_MCF, mcf_row,6,chg_trans[0].n_notify,TRUE);

    return( NFI_S_SUCCESS );
}
