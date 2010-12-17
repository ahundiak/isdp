#include "machine.h"
#include "WFF.h"
#include "WFFlist.h"
#include "WFFadd_wf.h"
#include "WFFpage1.h"

/*  Global WFF structure  */

extern struct WFFglobal_st WFFglobal;

/********************************************************************
 *                                                                  * 
 *  Function : WFFpage1                                             *
 *                                                                  * 
 *                                                                  * 
 ********************************************************************/

long _WFFpage1 (ptr)
    WFFadd_ptr   ptr;  
  {
	long	status;
        int     i = 0;
        MEMptr  attr_list = NULL;
        char    s[256];
        char    **data;

	static	char *fname = "_WFFpage1";

        _NFIdebug ((fname, " Function entered\n"));

       /* Put up a message */

       _WFFmessage (NFI_I_RETRIEVE, NULL);  /* Retrieving data from server */

       /* Get the short list of workflows */

       strcpy (s, "nfmworkflow.n_workflowno > 4");

       if ((ptr->wf_list == NULL) && (ptr->get_wfs == TRUE))
        {
           status = WFGlist_wfs (WFFglobal.user_id, s, "", WFF_NAME_ONLY,
                                 &attr_list, &(ptr->wf_list));
           if ((status != NFM_S_SUCCESS) &&
              (status != NFM_E_NO_WORKFLOWS_FOUND))
            {
               MEMclose (&attr_list);
               attr_list = NULL;
               _NFIdebug ((fname, "WFGlist_wfs = <0x%.8x>\n", status));
               _WFFerase_message ();
               _WFFfree_add_ptr (ptr);
               return (status);
            }

           MEMclose (&attr_list);
           attr_list = NULL;
   
           if (status == NFM_S_SUCCESS)
            {
               /* Prepare the data buffer for reading */
   
               status = MEMbuild_array (ptr->wf_list);
               if (status != MEM_S_SUCCESS) 
                {
	           _NFIdebug ((fname, "MEMbuild_array = <0x%.8x>\n", status));
                   _WFFerase_message ();
	           _WFFfree_add_ptr (ptr);
	           _NFIdebug ((fname, " returning <0x%.8x>\n", NFI_E_MEM));
	           return (NFI_E_MEM);
                }
   
               if (WFFglobal.debug_on)
               {
                  MEMprint_buffer ("wf_list", ptr->wf_list,
                                   WFFglobal.debug_file);
               }

              ptr->get_wfs = FALSE;
           }
          else
           {
               MEMclose (&(ptr->wf_list));
               ptr->wf_list = NULL;
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

       if (ptr->page1_form == NULL)
        { 
           /*  Load in the PAGE1 form  */

           if ((status = (long) FIf_new (PAGE1_LABEL, WF_PAGE1_FORM,
	                   _WFFnotify, &(ptr->page1_form))) != FI_SUCCESS)
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
		    (ptr->page1_form, (char *) ptr)) != FI_SUCCESS)
	     {
		_NFIdebug ((fname, "FIf_set_user_pointer = <%d>\n", status));
                _WFFerase_message ();
		_WFFfree_add_ptr (ptr);
		WFFglobal.error_no = NFI_E_FORM;
		ERRload_struct
		     (NFI, NFI_E_FORM, "%s%d", "FIf_set_user_pointer", status);
	        _NFIdebug ((fname, " returning FAILURE\n"));
	        return (NFI_E_FORM);
	     }
    
            /* Set the maximum of characters allowed for the fields */
    
            status = (long) FIfld_set_max_num_chars (ptr->page1_form,
                                                     WF_NAME_FIELD, 0, 20);
            status = (long) FIfld_set_max_num_chars (ptr->page1_form,
                                                     WF_DESC_FIELD, 0, 40);

            /* clear out the fields */
    
/* IGI Intel Solaris Port - CN 31/5/95 */
#if defined(OS_SCO_UNIX) || defined(OS_INTELSOL)
	/* To set font for SCO - CRN 25 Feb 94	*/
	FIg_set_font(ptr->page1_form, WF_NAME_FIELD, "7x13bold", 15);
#endif
            status = FIfld_set_text (ptr->page1_form,
                                     WF_NAME_FIELD, 0, 0, "", FALSE);

/* IGI Intel Solaris Port - CN 31/5/95 */
#if defined(OS_SCO_UNIX) || defined(OS_INTELSOL)
	/* To set font for SCO - CRN 25 Feb 94	*/
	FIg_set_font(ptr->page1_form, WF_DESC_FIELD, "7x13bold", 15);
#endif
            status = FIfld_set_text (ptr->page1_form,
                                     WF_DESC_FIELD, 0, 0, "", FALSE);

            /* put the workflow_name in the workflow name field */
    
/* IGI Intel Solaris Port - CN 31/5/95 */
#if defined(OS_SCO_UNIX) || defined(OS_INTELSOL)
	/* To set font for SCO - CRN 25 Feb 94	*/
	FIg_set_font(ptr->page1_form, WF_NAME_FIELD, "7x13bold", 15);
#endif
            status = (long) FIfld_set_text (ptr->page1_form,
                            WF_NAME_FIELD, 0, 0, ptr->workflow_name, FALSE);
            if (status != FI_SUCCESS)
             {
                _NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
                _WFFerase_message ();
	        _WFFfree_add_ptr (ptr);
	        WFFglobal.error_no = NFI_E_FORM;
	        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_text",
                                status);
	        _NFIdebug ((fname, " returning FAILURE\n"));
	        return (NFI_E_FORM);
	     }

            /* if the workflow_name is given this field should be set to
               read-only.  The workflow_name is not modifiable at this time
               because it is the active data.                              */

            if (strcmp (ptr->workflow_name, "") != 0)
             {
                 status = (long) FIfld_set_mode (ptr->page1_form,
                            WF_NAME_FIELD, 0, FI_REVIEW);
                 if (status != FI_SUCCESS)
                  {
                     _NFIdebug ((fname, "FIfld_set_mode = <%d>\n", status));
                     _WFFerase_message ();
	             _WFFfree_add_ptr (ptr);
	             WFFglobal.error_no = NFI_E_FORM;
	             ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_mode",
                                     status);
	             _NFIdebug ((fname, " returning FAILURE\n"));
	             return (NFI_E_FORM);
	          }
	     }
    
            /* put the workflow_description in the workflow desc field */
    
/* IGI Intel Solaris Port - CN 31/5/95 */
#if defined(OS_SCO_UNIX) || defined(OS_INTELSOL)
	/* To set font for SCO - CRN 25 Feb 94	*/
	FIg_set_font(ptr->page1_form, WF_DESC_FIELD, "7x13bold", 15);
#endif
            status = (long) FIfld_set_text (ptr->page1_form,
                            WF_DESC_FIELD, 0, 0, ptr->workflow_desc, FALSE);
            if (status != FI_SUCCESS)
             {
                _NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
                _WFFerase_message ();
	        _WFFfree_add_ptr (ptr);
	        WFFglobal.error_no = NFI_E_FORM;
	        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_text",
                                status);
	        _NFIdebug ((fname, " returning FAILURE\n"));
	        return (NFI_E_FORM);
	     }
    
	    /* Put the wkflows in the scroll list, it will handle NULL lists */
   
            status = _WFFput_data_in_list (ptr->page1_form,
                                           WF_LIST_SCF, 2, 1, ptr->wf_list);
            if (status != NFI_S_SUCCESS)
	     {
	         _NFIdebug ((fname, "_WFFput_data_in_list = <0x%.8x>\n",
                             status));
                 _WFFerase_message ();
	         _WFFfree_add_ptr (ptr);
	         _NFIdebug ((fname, " returning FAILURE\n"));
	         return (status);
	     }
    
            if ( (ptr->wf_list) && (strcmp (ptr->old_wf_name, "")) )
             {
                 data = (char **) ptr->wf_list->data_ptr;
                 for (i = 0; i < ptr->wf_list->rows; ++i)
                  {
                      if (!strcmp (ptr->old_wf_name, 
                          data [ptr->wf_list->columns * i + 1]))
                       {
                          /* Set the row to selected */
    
                          status = (long) FIfld_set_select ( ptr->page1_form,
                                                     WF_LIST_SCF, i, 0, TRUE);
                          if (status != FI_SUCCESS)
	                   {
		              _NFIdebug ((fname, "FIfld_set_select = <%d>\n",
                                          status));
                              _WFFerase_message ();
		              _WFFfree_add_ptr (ptr);
		              WFFglobal.error_no = NFI_E_FORM;
		              ERRload_struct
			         (NFI, NFI_E_FORM, "%s%d", "FIfld_set_select",
                                       status);
		              _NFIdebug ((fname, " returning FAILURE\n"));
		              return (NFI_E_FORM);
	                   }
                          /* set the row to be in the viewing area */

                          _WFFset_active_row (ptr->page1_form, WF_LIST_SCF,
                                              i, 1);
                          break;
                       }
                  } 
             }

    	    /*  Set the title  */
    
	    status = (long) UMSGetByNum (s, NFI_P_WF_DEF, NULL);  
	    if (status != UMS_S_SUCCESS)  
	      {
		    _NFIdebug ((fname, "UMSGetByNum = <0x%.8x>\n", status));
		    _NFIdebug ((fname, "defaulting title\n"));
                    strcpy (s, "Workflow Definition");
	      }
    
	    if ((status = (long) FIg_set_text
		    (ptr->page1_form, TITLE1, s)) != FI_SUCCESS)
	      {
		    _NFIdebug ((fname, "FIg_set_text = <%d>\n", status));
                    _WFFerase_message ();
		    _WFFfree_add_ptr (ptr);
		    WFFglobal.error_no = NFI_E_FORM;
		    ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_set_text",
                                    status);
		    _NFIdebug ((fname, " returning FAILURE\n"));
		    return (NFI_E_FORM);
	      }
         }

        /* Erase the message */

        _WFFerase_message (); /* Erase "Retrieving data from server" msg */

        WFFglobal.current_form = ptr->page1_form;

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


        if (!strcmp (ptr->workflow_name, ""))
         {
	    /*  Position the cursor into the workflow_name field  */

	    status = (long) FIfld_pos_cursor (WFFglobal.current_form,
                                              WF_NAME_FIELD, 0, 0, 0, 0, 0, 0);
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
         }

	_NFIdebug ((fname, " returning SUCCESS\n"));
	return (NFI_S_SUCCESS);
  }



long _WFFpage1_notify (g_label, value, form)
  int		g_label;
  double	value;
  Form		form;
  {
	long	        status;
        int		i;
	WFFadd_ptr	ptr;

	long		_WFFcopy_existing_wf();
        void  		_WFFclear_structure_status();

	static	char *fname = "_WFFpage1_notify";

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

			_WFFfree_add_ptr (ptr);

			/*  Enable the main form  */

			if (WFFglobal.main_form != NULL)
			  {
			     FIg_enable (WFFglobal.main_form, FI_FORM_GROUP);
			     _WFFprocess_event (REFRESH_EVENT);
			  }

		break;

		case FI_EXECUTE:

                   status = _WFFcheck_page1_data (form, ptr);
                   if (status != NFI_S_SUCCESS)
                    {
                       FIg_set_state (form, FI_ACCEPT, FALSE);
                       status = NFI_S_SUCCESS;
                       _NFIdebug ((fname, " returning SUCCESS\n"));
                       break;
                    }

                    status = _WFFget_page1_data (form, ptr);
                    if (status != NFI_S_SUCCESS)
                    {
                        FIg_set_state (form, FI_ACCEPT, FALSE);
                        _NFIdebug ((fname, "_WFFget_pg1_data = <0x%.8x>\n",
                                    status));
                        _NFIdebug ((fname, " returning FAILURE\n"));
                        return (status);
	             }

		    /*  Copy information from existing workflow if the old
		     *  workflow name is different from the workflow name.
		     */

		    if( strcmp( ptr->old_wf_name, ptr->workflow_name ) != 0 )
		    {
                        _NFIdebug(( fname, "Copying workflow\n" ));

      		        /*  Put up a message  */

  	                WFFglobal.working_no = NFI_I_COPY_WORKFLOW;

  	     	        _WFFmessage (WFFglobal.working_no, NULL);

  		        status = _WFFcopy_existing_wf( ptr );
			WFFglobal.copy_wf = 0;
                        if (status != NFI_S_SUCCESS)
                        {
                            FIg_set_state (form, FI_ACCEPT, FALSE);
                            _NFIdebug ((fname, "_WFFcopy_existing_wf = <0x%.8x>\n", status));
                            return (status);
  	                }

		    }

		    _WFFprint_add( ptr );
  
 		    /*  Call NFM or WFG to do the command  */

		    _NFIdebug ((fname, "calling WFGadd_workflow...\n"));

                    status = WFGcopy_workflow ( ptr->workflow_name, 
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

		    _WFFclear_structure_status( ptr );
		    strcpy (ptr->old_wf_name, ptr->workflow_name ); 

 		    /*  Erase the message  */

		     _WFFerase_message ();

	  	    /*  Save the return status  */

		     WFFglobal.cmd_status = status;

		    /*  Set the next state  */

	  	    if ((status = WFFset_to_state ()) != NFI_S_SUCCESS)
			_NFIdebug ((fname, "WFFset_to_state = <0x%.8x>\n",
				    status));

                /*  Clean up the form and display it again */
    
		for( i=0; i<ptr->wf_list->rows; ++i )
		{
                    status = (long) FIfld_set_select ( ptr->page1_form,
                                               WF_LIST_SCF, i, 0, FALSE);
                    if (status != FI_SUCCESS)
                    {
 	                _NFIdebug ((fname, "FIfld_set_select = <%d>\n",
                                          status));
                        _WFFerase_message ();
  	                _WFFfree_add_ptr (ptr);
	                WFFglobal.error_no = NFI_E_FORM;
	                ERRload_struct
		         (NFI, NFI_E_FORM, "%s%d", "FIfld_set_select", status);
 	                _NFIdebug ((fname, " returning FAILURE\n"));
		        return (NFI_E_FORM);
                    }
		}

                _WFFmain_set_wf (WFFglobal.workflow);

  	        break;

		case FI_ACCEPT:

                   status = _WFFcheck_page1_data (form, ptr);
                   if (status != NFI_S_SUCCESS)
                   {
                       FIg_set_state (form, FI_ACCEPT, FALSE);
                       status = NFI_S_SUCCESS;
                       _NFIdebug ((fname, " returning SUCCESS\n"));
                       break;
                   }

                   status = _WFFget_page1_data (form, ptr);
                   if (status != NFI_S_SUCCESS)
                   {
                       FIg_set_state (form, FI_ACCEPT, FALSE);
                       _NFIdebug ((fname, "_WFFget_pg1_data = <0x%.8x>\n",
                                        status));
                       _NFIdebug ((fname, " returning FAILURE\n"));
                       return (status);
                   }

		    /*  Copy information from existing workflow if the old
		     *  workflow name is different from the workflow name.
		     */

		    if( strcmp( ptr->old_wf_name, ptr->workflow_name ) != 0 )
		    {
                        _NFIdebug(( fname, "Copying workflow\n" ));

  		        status = _WFFcopy_existing_wf( ptr );
			WFFglobal.copy_wf = 0;
                        if (status != NFI_S_SUCCESS)
                        {
                            FIg_set_state (form, FI_ACCEPT, FALSE);
                            _NFIdebug ((fname, "_WFFcopy_existing_wf = <0x%.8x>\n", status));
                            return (status);
  	                }

      		        /*  Put up a message  */

  	                WFFglobal.working_no = NFI_I_COPY_WORKFLOW;

  	     	        _WFFmessage (WFFglobal.working_no, NULL);

		    }
		    else	 /* CN IGI 12/09/95 */ 
		    {	
			/* the workflow info may need to be modified */
 
        		status = _WFGupdate_workflow_info (ptr->workflow_name, ptr->old_wf_name, ptr->workflow_desc);      
        		if (status != NFM_S_SUCCESS)
         		{
            		_NFMdebug ((fname, " WFGupdate_workflow_info : status = <0x%.8x>\n", status));
            		NFMrollback_transaction (0);
            		return (status);
         		}
			/*  Clear out the appropriate fields  */
 
                   	/*  Blank out the listing on the main form  */
 
                   	_WFFfree_add_ptr (ptr);
 
                   	/*  Enable the main form  */
 
                   	if (WFFglobal.main_form != NULL)
                   	{
                        	FIg_enable (WFFglobal.main_form, FI_FORM_GROUP);
                               	_WFFprocess_event (REFRESH_EVENT);
                   	}

			break;

		    }	


  	 	   /*  Call NFM or WFG to do the command  */

		   _NFIdebug ((fname, "calling WFGcopy_workflow...\n"));

		   _WFFprint_add( ptr );

                   status = WFGcopy_workflow ( ptr->workflow_name, 
                         ptr->workflow_desc, ptr->num_classes, ptr->class_list,
                         ptr->num_states, ptr->state_list, ptr->num_trans,
                         ptr->trans_list, ptr->num_access, ptr->access_list);

                   if (status != NFM_S_SUCCESS) 
                   {
		     _NFIdebug ((fname, "WFGcopy_workflow = <0x%.8x>\n",
                                         status));
                   }
                   else
                   {
                       strcpy (WFFglobal.workflow, ptr->workflow_name);
                       _WFFmain_set_wf (WFFglobal.workflow);
                   }

                   _WFFclear_structure_status( ptr );
                    strcpy (ptr->old_wf_name, ptr->workflow_name ); 

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

		  break;

                  case WF_NAME_FIELD:

                       status = _WFFname_field (form, g_label, ptr);
                       if (status != NFI_S_SUCCESS)
                        {
                           _NFIdebug ((fname, "_WFFname_field = <0x%.8x>\n",
                                       status));
	                   _NFIdebug ((fname, " returning FAILURE\n"));
                           return (status);
	                }
		  break;

                  case WF_DESC_FIELD:

			_NFIdebug ((fname, "Description Field\n"));
		  break;

                  case WF_LIST_SCF:

                       status = _WFFwf_scrl_list (form, g_label, ptr);
                       if (status != NFI_S_SUCCESS)
                        {
                           _NFIdebug ((fname, "_WFFwf_scrl_list = <0x%.8x>\n",
                                       status));
	                   _NFIdebug ((fname, " returning FAILURE\n"));
                           return (status);
	                }
		  break;

                  case WF_PAGE_SCRL_BAR:

                       status = _WFFget_page1_data (form, ptr);
                       if (status != NFI_S_SUCCESS)
                        {
                           _NFIdebug ((fname, "_WFFget_pg1_data = <0x%.8x>\n",
                                       status));
	                   _NFIdebug ((fname, " returning FAILURE\n"));
	                   return (status);
	                }
                       
                       status = _WFFcheck_page1_data (form, ptr);
                       if (status != NFI_S_SUCCESS)
                        {
                           status = NFI_S_SUCCESS;
	                   _NFIdebug ((fname, " returning SUCCESS\n"));
                           break;
                        }
 
  		        /*  Copy information from existing workflow if the old
	  	         *  workflow name is different from the workflow name.
	  	         */

		        if(strcmp(ptr->old_wf_name, ptr->workflow_name ) != 0 )
		        {
			    _NFIdebug(( fname, "Copying workflow\n" ));
  		            status = _WFFcopy_existing_wf( ptr );
  			    WFFglobal.copy_wf = 0;
                            if (status != NFI_S_SUCCESS)
                            {
                                FIg_set_state (form, FI_ACCEPT, FALSE);
                                _NFIdebug ((fname, "_WFFcopy_existing_wf = <0x%.8x>\n", status));
                                return (status);
  	                    }

       		            /*  Put up a message  */

  	                    WFFglobal.working_no = NFI_I_COPY_WORKFLOW;

    	      	            _WFFmessage (WFFglobal.working_no, NULL);

 	    	            /*  Call NFM or WFG to do the command  */

   		            _NFIdebug((fname,"calling WFGcopy_workflow...\n"));

                            status = WFGcopy_workflow ( ptr->workflow_name,
                             ptr->workflow_desc, ptr->num_classes,
			     ptr->class_list, ptr->num_states, 
			     ptr->state_list, ptr->num_trans,
                             ptr->trans_list, ptr->num_access, 
			     ptr->access_list);

                            if (status != NFM_S_SUCCESS) 
                            {
   	 	                _NFIdebug ((fname, "WFGcopy_workflow = <0x%.8x>\n", status));
	                    }
                            else
                            {
                                strcpy(WFFglobal.workflow, ptr->workflow_name);
	                        _WFFmain_set_wf (WFFglobal.workflow);
                            }

			    _WFFclear_structure_status( ptr );
			    strcpy (ptr->old_wf_name, ptr->workflow_name ); 

     	  	            /*  Erase the message  */

             	            _WFFerase_message ();

	        	    /*  Save the return status  */

	  	            WFFglobal.cmd_status = status;

	                    /*  Set the next state  */

 	  	            if ((status = WFFset_to_state ()) != NFI_S_SUCCESS)
		  	    _NFIdebug ((fname, "WFFset_to_state = <0x%.8x>\n",
				    status));
  	  	        } /* end copy workflow */

                        status = _WFFscroll_pages (form, g_label, value, ptr);

		  break;
	  }

	_NFIdebug ((fname, " returning <0x%.8x>\n", status));
	return (status);
  }


long  _WFFname_field  (form, g_label, ptr)
   Form        form; 
   int         g_label;
   WFFadd_ptr  ptr;
  { 
     long  status; 
     int   i, length;
     char  text[40];
     char  **data;

     static char *fname = "_WFFname_field";

     strcpy (text, "");
     length = 20;

     status = _WFFget_data_from_field (form, g_label, 0, 0, text, length); 
     if (status != NFI_S_SUCCESS)
      {
         _NFIdebug ((fname, "WFFget_data_from_field = <%d>\n", status));
         _NFIdebug ((fname, " returning <0x%.8x>\n", status));
	 return (status);
      }

     if (ptr->wf_list)
      { 
         /* Check to see if the workflow is a duplicate, if it is set the
            field to ptr->workflow_name and send warning, otherwise put the
            data in ptr->workflow_name                                      */

/* IGI Intel Solaris Port - CN 31/5/95 */
#if defined(OS_SCO_UNIX) || defined(OS_INTELSOL)
	/* To set font for SCO - CRN 25 Feb 94	*/
	FIg_set_font(form, g_label, "7x13bold", 15);
#endif
         data = (char **) ptr->wf_list->data_ptr;
         for (i = 0; i < ptr->wf_list->rows; ++i)
          {
             length = ptr->wf_list->columns * i + 1;

             if ((strcmp (text, data[length]) == 0)  && 
                 (strcmp (ptr->workflow_name, data[length]) != 0)) 
              {
                 /* set the workflow_name field to whatever is in 
                    ptr->workflow_name                                     */

                 status = (long) FIfld_set_text (form, g_label, 0, 0,
                                                 ptr->workflow_name, FALSE);
                 if (status != FI_SUCCESS)
                  {
                     _NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
	             ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_text",
                                     status);
	             _NFIdebug ((fname, " returning FAILURE\n"));
	             return (NFI_E_FORM);
	          }
 
                 /* send warning msg to user and return */

                 _WFFmessage (NFI_E_DUPLICATE_WORKFLOW, "%s", text);
                 return (NFI_S_SUCCESS);
              }
          }
      }

     strcpy (ptr->workflow_name, text);
 
     status = NFI_S_SUCCESS;
     _NFIdebug ((fname, " returning <0x%.8x>\n", status));
     return (status);
  }


long  _WFFwf_scrl_list  (form, g_label, ptr)
   Form        form; 
   int         g_label;
   WFFadd_ptr  ptr;
  { 
     long  status; 
     int   i, rows, cols, length, sel_flag = FALSE;
     char  text[40];
     char  **data;

     static char *fname = "_WFFwf_scrl_list";

     strcpy (text, "");    /* in case user de-selected the field */ 
     data = (char **) ptr->wf_list->data_ptr;
     rows = ptr->wf_list->rows;
     cols = ptr->wf_list->columns;
     length = 20;


     /* get the selected field/value if any */

     for (i = 0; i < rows; ++i)
      {
         status = (long) FIfld_get_select (form, g_label, i, 0, &sel_flag);
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
            strcpy (text, data[cols * i + 1]);
            break;
         }
      }

     if (!sel_flag)
      {
         /* no row was selected; one was un-selected */

         if (strcmp (ptr->old_wf_name, "") != 0)
          {
             for (i = 0; i < rows; ++i)
              {
                 if (strcmp (ptr->old_wf_name, data[cols * i + 1]) == 0)
                  {
                     status = (long) FIfld_set_select (form, g_label, i, 0, 
                                                       TRUE);
                     if (status != FI_SUCCESS)
                      {
                         _NFIdebug ((fname, "FIfld_set_select = <%d>\n",
                                     status));
                         ERRload_struct (NFI, NFI_E_FORM, "%s%d", 
                                         "FIfld_set_select", status);
	                 _NFIdebug ((fname, " returning FAILURE\n"));
	                 return (NFI_E_FORM);
                      }

                     /* set the row to be in the viewing area */

                     _WFFset_active_row (ptr->page1_form, WF_LIST_SCF, i, 1);
                     break;
                  } 
              }
          }
         else if (strcmp (ptr->existing_wf_name, "") != 0)
          {
             for (i = 0; i < rows; ++i)
              {
                 if (strcmp (ptr->existing_wf_name, data[cols * i + 1]) == 0)
                  {
                     status = (long) FIfld_set_select (form, g_label, i, 0, 
                                                       TRUE);
                     if (status != FI_SUCCESS)
                      {
                         _NFIdebug ((fname, "FIfld_set_select = <%d>\n",
                                     status));
                         ERRload_struct (NFI, NFI_E_FORM, "%s%d", 
                                         "FIfld_set_select", status);
	                 _NFIdebug ((fname, " returning FAILURE\n"));
	                 return (NFI_E_FORM);
                      }

                     /* set the row to be in the viewing area */

                     _WFFset_active_row (ptr->page1_form, WF_LIST_SCF, i, 1);
                     break;
                  } 
              }
          }

         status = NFI_S_SUCCESS;
         _NFIdebug ((fname, " returning <0x%.8x>\n", status));
         return (status);
      } 

     if ((ptr->class_list) || (ptr->trans_list) || (ptr->state_list) ||
         (strcmp(ptr->complete,"Y") == 0) || (strcmp(ptr->old_wf_name,"") != 0))
      {
         /* if ptr->workflow_name reset the list to ptr->workflow_name */ 

         if (strcmp (ptr->old_wf_name, "") != 0)
          { 
             for (i = 0; i < rows; ++i)
              {
                 if (strcmp (ptr->old_wf_name, data[cols * i + 1]) == 0)
                  {
                     status = (long) FIfld_set_select (form, g_label, i, 0, 
                                                       TRUE);
                     if (status != FI_SUCCESS)
                      {
                         _NFIdebug ((fname, "FIfld_set_select = <%d>\n",
                                     status));
                         ERRload_struct (NFI, NFI_E_FORM, "%s%d", 
                                         "FIfld_set_select", status);
	                 _NFIdebug ((fname, " returning FAILURE\n"));
	                 return (NFI_E_FORM);
                      }

                     /* set the row to be in the viewing area */

                     _WFFset_active_row (ptr->page1_form, WF_LIST_SCF, i, 1);
                     break;
                  } 
              }
          }
         else if (strcmp (ptr->existing_wf_name, "") != 0)
          { 
             for (i = 0; i < rows; ++i)
              {
                 if (strcmp (ptr->existing_wf_name, data[cols * i + 1]) == 0)
                  {
                     status = (long) FIfld_set_select (form, g_label, i, 0, 
                                                       TRUE);
                     if (status != FI_SUCCESS)
                      {
                         _NFIdebug ((fname, "FIfld_set_select = <%d>\n",
                                     status));
                         ERRload_struct (NFI, NFI_E_FORM, "%s%d", 
                                         "FIfld_set_select", status);
	                 _NFIdebug ((fname, " returning FAILURE\n"));
	                 return (NFI_E_FORM);
                      }

                     /* set the row to be in the viewing area */

                     _WFFset_active_row (ptr->page1_form, WF_LIST_SCF, i, 1);
                     break;
                  } 
              }
          }

         /* put up a message warning the user that data already exists for
            this and exit.                                               */ 

         _WFFmessage (NFI_E_WF_DATA_EXISTS, NULL);
         return (NFI_S_SUCCESS);
      }

     strcpy (ptr->existing_wf_name, text);
     
     status = NFI_S_SUCCESS;
     _NFIdebug ((fname, " returning <0x%.8x>\n", status));
     return (status);
  }


long _WFFget_page1_data (form, ptr)
   Form        form; 
   WFFadd_ptr  ptr;
  { 
     long  status; 
     int   length;
     char  text[48];

     static char *fname = "_WFFget_page1_data";

     strcpy (text, "");
     length = 40;

     /* get the description out of the WF_DESC_FIELD and put it into
        ptr->workflow_desc.                                          */

     status = _WFFget_data_from_field (form, WF_DESC_FIELD, 0, 0, text, length);
     if (status != NFI_S_SUCCESS)
      {
         _NFIdebug ((fname, "WFFget_data_from_field = <0x%.8x>\n", status));
         _NFIdebug ((fname, " returning <0x%.8x>\n", status));
         return (status);
      }

     strcpy (ptr->workflow_desc, text); 

     status = NFI_S_SUCCESS;
     _NFIdebug ((fname, " returning <0x%.8x>\n", status));
     return (status);
  }


long _WFFcheck_page1_data (form, ptr)
   Form        form; 
   WFFadd_ptr  ptr;
  { 
     long  status; 
     Form  temp;

     static char *fname = "_WFFcheck_page1_data";

     _NFIdebug ((fname, " Function entered\n"));
     temp = form;

     if (strcmp (ptr->workflow_name, "") == 0)
      {
         status = NFI_W_NULL_WORKFLOW_NAME;
         _WFFmessage (NFI_W_NULL_WORKFLOW_NAME, NULL);
         _NFIdebug ((fname, " returning <0x%.8x>\n", status));
         return (status);
      }

     status = NFI_S_SUCCESS;
     _NFIdebug ((fname, " returning <0x%.8x>\n", status));
     return (status);
  }

long _WFFcopy_existing_wf( ptr )
  WFFadd_ptr  ptr;
{
    long  status;
    static char *fname = "_WFFcopy_existing_wf";


    MEMptr  attr_list = NULL;
    MEMptr  data_list = NULL;

    _NFIdebug(( fname, "Entering ...\n" ));
    _NFIdebug(( fname, "Old Workflow Name <%s>\n", ptr->old_wf_name ));
    _NFIdebug(( fname, "Existing Workflow Name <%s>\n",ptr->existing_wf_name));
    _NFIdebug(( fname, "Workflow Name <%s>\n", ptr->workflow_name ));

    /*  Set Copy Workflow Flag */

    WFFglobal.copy_wf = 1;

    if (ptr->num_classes == 0)
    {
       /* Get the long list of classes two columns are returned. */

       if (strcmp (ptr->old_wf_name, "")) 
          status = WFGn_list_classes (ptr->old_wf_name, &attr_list,
                                          &data_list);
       else
          status = WFGn_list_classes (ptr->existing_wf_name,
                                          &attr_list, &data_list);
       if ((status != NFM_S_SUCCESS) && (status != NFM_E_NO_CLASSES_DEFINED))
       {
          MEMclose (&attr_list);
          MEMclose (&data_list);
          _NFIdebug ((fname, "WFGn_list_classes = <0x%.8x>\n", status));
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
               _NFIdebug ((fname, "MEMbuild_array = <0x%.8x>\n", status));
               _WFFerase_message ();
               _WFFfree_add_ptr (ptr);
               _NFIdebug ((fname, " returning <0x%.8x>\n", NFI_E_MEM));
               return (NFI_E_MEM);
            }
        
            if (WFFglobal.debug_on)
            {
                MEMprint_buffer ("class_list", data_list,
                                WFFglobal.debug_file);
            }

            /* Put the data into the class_list (array of strucs) */

            status = _WFFload_class_in_list (data_list, ptr);
            if (status != NFI_S_SUCCESS) 
            {
                MEMclose (&data_list); 
                _NFIdebug ((fname,
                               "WFFload_class_in_list = <0x%.8x>\n", status));
                _WFFerase_message ();
                _WFFfree_add_ptr (ptr);
                _NFIdebug ((fname, " returning <0x%.8x>\n", status));
                return (status);
            }
        }
    
        MEMclose (&data_list);
        data_list = NULL;
    }
 
    /* Get the long list of states */

    if (ptr->num_states == 0)
    {
       /* Get the long list of states 8 columns will be returned. */

       if (strcmp (ptr->old_wf_name, "")) 
          status = WFGn_list_states (ptr->old_wf_name,
                                         &attr_list, &data_list);
       else
          status = WFGn_list_states (ptr->existing_wf_name,
                                         &attr_list, &data_list);
       if ((status != NFM_S_SUCCESS) && (status != NFM_E_NO_STATES_DEFINED))
       {
           MEMclose (&attr_list);
           MEMclose (&data_list);
           _NFIdebug ((fname, "WFGn_list_states = <0x%.8x>\n", status));
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
               _NFIdebug ((fname, "MEMbuild_array = <0x%.8x>\n", status));
               _WFFerase_message ();
               _WFFfree_add_ptr (ptr);
               _NFIdebug ((fname, " returning <0x%.8x>\n", NFI_E_MEM));
               return (NFI_E_MEM);
           }
        
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
           _NFIdebug ((fname, "WFGn_list_transitions = <0x%.8x>\n", status));
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
               _NFIdebug ((fname, "MEMbuild_array = <0x%.8x>\n", status));
               _WFFerase_message ();
               _WFFfree_add_ptr (ptr);
               _NFIdebug ((fname, " returning <0x%.8x>\n", NFI_E_MEM));
               return (NFI_E_MEM);
           }

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

    if (ptr->num_access == 0)
    {
        /* Get the list of class access to transitions (4 columns) */

        if (strcmp (ptr->old_wf_name, ""))
           status = WFGlist_class_access (WFFglobal.user_id,  
                         ptr->old_wf_name, "", "", &attr_list, &data_list);
        else
           status = WFGlist_class_access (WFFglobal.user_id,
                        ptr->existing_wf_name, "", "", &attr_list, &data_list);
        if ((status != NFM_S_SUCCESS) &&
            (status != NFM_E_NO_CLASS_ACCESS_DEFINED))
        {
            MEMclose (&attr_list);
            MEMclose (&data_list);
            _NFIdebug ((fname, "WFGlist_class_access = <0x%.8x>\n", status));
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
                _NFIdebug ((fname, "MEMbuild_array = <0x%.8x>\n", status));
                _WFFerase_message ();
                _WFFfree_add_ptr (ptr);
                _NFIdebug ((fname, " returning <0x%.8x>\n", NFI_E_MEM));
                return (NFI_E_MEM);
             }

             /* Put the data into the access_list (array of strucs) */

             status = _WFFload_access_in_list (data_list, ptr);
             if (status != NFI_S_SUCCESS)
             {
                 MEMclose (&data_list);
                 _NFIdebug ((fname,
                          "WFFload_access_in_list = <0x%.8x>\n", status));
                 _WFFerase_message ();
                 _WFFfree_add_ptr (ptr);
                 _NFIdebug ((fname, " returning <0x%.8x>\n", status));
                 return (status);
             } 
         }

         MEMclose (&data_list);
         data_list = NULL;
    }

    strcpy (ptr->existing_wf_name,ptr->workflow_name );
    WFFglobal.working_no = NFI_I_MODIFY_WORKFLOW;

    _NFIdebug(( fname, "Returning NFI_S_SUCCESS ...\n" ));

    return( NFI_S_SUCCESS );
}

void  _WFFclear_structure_status( ptr )
    WFFadd_ptr  ptr;
{
    int   i;
    int   j;

    static  char *fname = "_WFFclear_structure_status";

    _NFIdebug(( fname, "Entering ...\n" ));

    /*  This function is called after doing the WFGadd_workflow function
     *  in order to clear out all of the "ADD" statuses.
     */

    if( ptr->num_classes > 0 )
    {
	for( i=0; i<ptr->num_classes; ++i )
	{
	    if( strcmp( ptr->class_list[i].status, WFF_ADD ) == 0 )
		strcpy( ptr->class_list[i].status, "" );
	}
    }    

    if( ptr->num_states > 0 )
    {
	for( i=0; i<ptr->num_states; ++i )
	{
	    if( strcmp( ptr->state_list[i].status, WFF_ADD ) == 0 )
		strcpy( ptr->state_list[i].status, "" );
	}
    }    

    if( ptr->num_trans > 0 )
    {
	for( i=0; i<ptr->num_trans; ++i )
	{
	    if( strcmp( ptr->trans_list[i].status, WFF_ADD ) == 0 )
		strcpy( ptr->trans_list[i].status, "" );
	}
    }    

    if( ptr->num_access > 0 )
    {
	for( i=0; i<ptr->num_access; ++i )
	{
	    if( strcmp( ptr->access_list[i].status, WFF_ADD ) == 0 )
		strcpy( ptr->access_list[i].status, "" );

	    for( j=0; j<ptr->access_list[i].num_trans; ++j )
	    {
     	      if( strcmp( ptr->access_list[i].trans_ptr[j].status,WFF_ADD)==0)
		strcpy( ptr->access_list[i].trans_ptr[j].status, "" );
	    }
	}

    }    

    return;
}
