#include "machine.h"
#include "WFF.h"
#include "WFFadd_wf.h"
#include "WFFlist.h"
#include "WFFpage4.h"

/*  Global WFF structure  */

extern struct WFFglobal_st WFFglobal;

/********************************************************************
 *                                                                  * 
 *  Function : WFFpage4                                             *
 *                                                                  * 
 *                                                                  * 
 ********************************************************************/

long _WFFpage4 (ptr)
    WFFadd_ptr   ptr;  
  {
	long	status;
        char    s[256];
        MEMptr  attr_list = NULL;
        MEMptr  data_list = NULL;
	static	char *fname = "_WFFpage4";

        _NFIdebug ((fname, " Function Entered\n"));

        /* Put up a message */

        _WFFmessage (NFI_I_RETRIEVE, NULL);  /* Retrieving data from server */

        if ((strcmp (ptr->existing_wf_name, "")) ||
            (strcmp (ptr->old_wf_name, "")) ||
            (strcmp (ptr->workflow_name, ""))) 
         {
            /* Get the long list of transitions */

            if (ptr->num_trans == 0)
             {
                /* Get the long list of transitions 8 cols will be returned */

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

            if (ptr->num_classes == 0)
             {
                 /* Get the long list of classes 1 column will be returned. */

                if (strcmp (ptr->old_wf_name, ""))
                   status = WFGn_list_classes (ptr->old_wf_name, 
                                               &attr_list, &data_list);
                else
                   status = WFGn_list_classes (ptr->existing_wf_name, 
                                               &attr_list, &data_list);
                if ((status != NFM_S_SUCCESS) &&
                    (status != NFM_E_NO_CLASSES_DEFINED))
                 {
                    MEMclose (&attr_list);
                    MEMclose (&data_list);
                    _NFIdebug ((fname, "WFGn_list_classes = <0x%.8x>\n",
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
                        _NFIdebug ((fname, " returning <0x%.8x>\n",
                                    NFI_E_MEM));
                        return (NFI_E_MEM);
                     }
/*
                    if (WFFglobal.debug_on)
                     {
                        MEMprint_buffer ("class_list", data_list,
                                         WFFglobal.debug_file);
                     }
  */                  
                     /* Put the data into the class_list (array of strucs) */

                     status = _WFFload_class_in_list (data_list, ptr);
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

            /* Get the long list of states */

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
                        _NFIdebug ((fname, " returning <0x%.8x>\n",
                                    NFI_E_MEM));
                        return (NFI_E_MEM);
                      }
/*
                     if (WFFglobal.debug_on)
                      {
                         MEMprint_buffer ("state_list", data_list,
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


            if (ptr->num_access == 0)
             {
                /* Get the list of class access to transitions (4 columns) */

                if (strcmp (ptr->old_wf_name, "")) 
                   status = WFGlist_class_access (WFFglobal.user_id, 
                                         ptr->old_wf_name, "", "",
                                         &attr_list, &data_list);
                else
                   status = WFGlist_class_access (WFFglobal.user_id, 
                                         ptr->existing_wf_name, "", "",
                                         &attr_list, &data_list);
                if ((status != NFM_S_SUCCESS) &&
                    (status != NFM_E_NO_CLASS_ACCESS_DEFINED))
                 {
                    MEMclose (&attr_list);
                    MEMclose (&data_list);
   	            _NFIdebug ((fname, "WFGlist_class_access = <0x%.8x>\n",
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
		        _NFIdebug ((fname, " returning <0x%.8x>\n",
                                    NFI_E_MEM));
		        return (NFI_E_MEM);
	              }
        
/*
                     if (WFFglobal.debug_on)
                      {
                        MEMprint_buffer ("access_list", data_list,
                                         WFFglobal.debug_file);
                      }
*/

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

/*
                     for (i1 = 0; i1 < ptr->num_access; ++i1)
                      {
                         _NFIdebug ((fname, " class = <%s>\n",
                                     ptr->access_list[i1].class_name));
                         for (irow = 0; irow < ptr->access_list[i1].num_trans; ++irow)
                          {
                             _NFIdebug ((fname, " transition = <%s>\n",
                              ptr->access_list[i1].trans_ptr[irow].trans_name));
                             _NFIdebug ((fname, " from state = <%s>\n",
                              ptr->access_list[i1].trans_ptr[irow].from_state));
                             _NFIdebug ((fname, " to state   = <%s>\n",
                              ptr->access_list[i1].trans_ptr[irow].to_state));
                          }
                      }
*/
                 }

                MEMclose (&data_list);
                data_list = NULL;
             }
         }

        if (ptr->page4_form == NULL)
         {
	    /*  Load in the PAGE4 form  */

	    if ((status = (long) FIf_new (PAGE4_LABEL, WF_PAGE4_FORM,
		    _WFFnotify, &(ptr->page4_form))) != FI_SUCCESS)
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
		    (ptr->page4_form, (char *) ptr)) != FI_SUCCESS)
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
    
            status = (long) FIfld_set_num_rows (ptr->page4_form,
                                                CLASS_LIST_SCF, 0);
            status = (long) FIfld_set_num_rows (ptr->page4_form,
                                                TRANS_LIST_MCF, 0);

	    /*  Set the title  */
    
	    status = (long) UMSGetByNum (s, NFI_P_CLASS_ACCESS_DEF, "%s",
                                         ptr->workflow_name);  
	    if (status != UMS_S_SUCCESS)  
	     {
	        _NFIdebug ((fname, "UMSGetByNum = <0x%.8x>\n", status));
	        _NFIdebug ((fname, "defaulting title\n"));
                sprintf (s,  
                   "Define the class access to transitions for workflow \"%s\"",
                         ptr->workflow_name);
	     }
    
	    if ((status = (long) FIg_set_text
		           (ptr->page4_form, TITLE1, s)) != FI_SUCCESS)
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
         }
    
        /* display / re-displayed the data */

        /* clear out the class data in the SCF */

        status = (long) FIfld_set_num_rows (ptr->page4_form,  
                                            CLASS_LIST_SCF, 0); 
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
         
        status = _WFFput_classes_in_list (ptr->page4_form,
                                          CLASS_LIST_SCF, ptr);
        if (status != NFI_S_SUCCESS) 
         {
            _NFIdebug ((fname, "_WFFput_classes_in_list = <0x%.8x>\n",
                        status));
            _WFFerase_message ();
            _WFFfree_add_ptr (ptr);
            WFFglobal.error_no = status;
            _NFIdebug ((fname, " returning <0x%.8x>\n", status));
            return (status);
         }
    
        /* display / re-displayed the transition data */

        /* clear out the transition data in the SCF */

        status = (long) FIfld_set_num_rows (ptr->page4_form,
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
         
        status = _WFFscf_put_trans_in_list (ptr->page4_form,
                                            TRANS_LIST_MCF, ptr->num_trans,
                                            ptr->trans_list);
        if (status != NFI_S_SUCCESS) 
         {
            _NFIdebug ((fname, "_WFFscf_put_trans_in_list = <0x%.8x>\n",
                        status));
            _WFFerase_message ();
            _WFFfree_add_ptr (ptr);
            WFFglobal.error_no = status;
            _NFIdebug ((fname, " returning <0x%.8x>\n", status));
            return (status);
         }

        /* Erase the message */

        _WFFerase_message (); /* Erase "Retrieving data from server" msg */

        WFFglobal.current_form = ptr->page4_form;

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

	_NFIdebug ((fname, " returning SUCCESS\n"));
	return (NFI_S_SUCCESS);
  }


long _WFFpage4_notify (g_label, value, form)
  int		g_label;
  double	value;
  Form		form;
  {
	long	status = NFI_S_SUCCESS;

	WFFadd_ptr	ptr;

	static	char *fname = "_WFFpage4_notify";

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

                        status = WFFchange_workflow( WFFglobal.workflow, 4 );

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
                        /* Do nothing, this will be handled when a class is
                           selected.                                        */ 

                        ;
			break;

                  case CLASS_LIST_SCF:
                        /* Display class to transition access for the class */
                        /* by setting all transitions allowed by the class */

                        status = _WFFdisplay_access (form, g_label,
                                           ptr->num_access, ptr->access_list);
                        if (status != NFI_S_SUCCESS)
                         {
			    _NFIdebug ((fname,
                                   "_WFFdisplay_access = <0x%.8x>\n", status));
                         }

			break;

                  case SELECT_ALL_BUTTON:
                        /* Select all the transitions in the SCF */

                        status = _WFFset_all_transitions (form, TRANS_LIST_MCF,
                                                          TRUE); 
                        if (status != NFI_S_SUCCESS)
                         {
			    _NFIdebug ((fname,
                               "_WFFset_all_transitions = <0x%.8x>\n", status));
                         }

			break;

                  case CLEAR_ALL_BUTTON:
                       /* Call function to unselect the transtions in the SCF */

                        status = _WFFset_all_transitions (form, TRANS_LIST_MCF,
                                                          FALSE); 
                        if (status != NFI_S_SUCCESS)
                         {
			    _NFIdebug ((fname,
                               "_WFFset_all_transitions = <0x%.8x>\n", status));
                         }

			break;

                  case UPDATE_ACCESS_BUTTON:
                       /* Call function to unselect the transtions in the SCF */

                        status = _WFFupdate_class_access (form, ptr);
                        if (status != NFI_S_SUCCESS)
                         {
			    _NFIdebug ((fname,
                               "_WFFupdate_class_access = <0x%.8x>\n", status));
                         }
                        ERRload_struct (NFI, NFI_I_CLASS_ACCESS_UPDATED, NULL);
 	                _WFFerror_message (WFFglobal.current_form);

	                _NFIdebug ((fname, " Update Class Acess Button\n"));
			break;

                  case WF_PAGE_SCRL_BAR:
                        /* Call function to process the page scroll Bar */

                        status = _WFFscroll_pages (form, g_label, value, ptr);

			_NFIdebug ((fname, "Select Workflow\n"));
			break;
	  }

	_NFIdebug ((fname, " returning <0x%.8x>\n", status));
	return (status);
  }



long _WFFset_all_transitions (form, g_label, sel_flag)
    Form   form;
    int    g_label;
    int    sel_flag;
  {
     long  status;
     int   i, j, num_rows;

     static char *fname = "_WFFselect_all_transitions";

     _NFIdebug ((fname, " Select Flag = <%d>\n", sel_flag));

     /* Get the number of rows in the field */ 

     status = (long) FIfld_get_num_rows (form, g_label, &num_rows); 
     if (status != FI_SUCCESS)
      {
         _NFIdebug ((fname, "FIfld_get_num_rows = <%d>\n", status));
         ERRload_struct (NFI, NFI_E_FORM, "%s%d",
                         "FIfld_get_num_rows", status);
         _NFIdebug ((fname, " returning FAILURE\n"));
         return (NFI_E_FORM);
      } 
   
     for (i = 0; i < num_rows; ++i)
      {
         for (j = 0; j < 4; ++j)
          { 
             status = (long) FIfld_set_select (form, g_label, i, j, sel_flag); 
             if (status != FI_SUCCESS)
              {
                 _NFIdebug ((fname, "FIfld_set_select = <%d>\n", status));
                 ERRload_struct (NFI, NFI_E_FORM, "%s%d",
                                 "FIfld_set_select", status);
                 _NFIdebug ((fname, " returning FAILURE\n"));
                 return (NFI_E_FORM);
              } 
          }
      } 
   
     status = NFI_S_SUCCESS;
     _NFIdebug ((fname, " returning <0x%.8x>\n", status));
     return (status);
  }


long _WFFload_access_in_list (data_list, ptr)
     MEMptr       data_list;
     WFFadd_ptr   ptr;
  {
     long  status;
     char  class_name[21];
     char  **data;
     int   i, j, k, count, num_classes, num_rows;
     int   *a_list = NULL;

     static char *fname = "_WFFload_access_in_list";

     _NFIdebug ((fname, " function entered\n"));

     data = (char **) data_list->data_ptr;
     num_rows = data_list->rows;
     if (num_rows <= 0)
      {
         status = NFI_S_SUCCESS;
         _NFIdebug ((fname, " The data list is NULL\n"));
         _NFIdebug ((fname, " returning <0x%.8x>\n", status));
         return (status);
      }

     /* find the number of unique classes */

     strcpy (class_name, data[0]);
     num_classes = 1;
     k = 1; 
     a_list = (int *) malloc (num_classes * (sizeof (int)));
     if (!a_list)
      {
         free ((int *) a_list);
         _NFIdebug ((fname, "Malloc : bytes = <%d>\n",
                                         num_classes * sizeof (int)));
         WFFglobal.error_no = NFI_E_MALLOC;
         ERRload_struct (NFI, NFI_E_MALLOC, "%d",  
                                   num_classes * sizeof (int));
         _NFIdebug ((fname, " returning FAILURE\n"));
         return (NFI_E_MALLOC);
      } 

     for (i = 1; i < num_rows; ++i)
      {
         if (strcmp (class_name, data [data_list->columns * i]) != 0)
         {
            a_list = (int *) realloc (a_list, (num_classes + 1) * (sizeof (int)));
            if (!a_list)
             {
                free ((int *) a_list);
                _NFIdebug ((fname, "Realloc : bytes = <%d>\n",
                                             num_classes * sizeof (int)));
                WFFglobal.error_no = NFI_E_MALLOC;
                ERRload_struct (NFI, NFI_E_MALLOC, "%d",  
                                    num_classes * sizeof (int));
                 _NFIdebug ((fname, " returning FAILURE\n"));
                 return (NFI_E_MALLOC);
             }

            a_list[num_classes -1] = k; 
            ++num_classes;
            k = 0; 
            strcpy (class_name, data[data_list->columns * i]);
         } 
         ++k;
      } 

     a_list[num_classes -1] = k; 
  
/*
     for (i = 0; i < num_classes; ++i)
       _NFIdebug ((fname, " a_list [%d] = <%d>\n", i, a_list[i]));
*/
     
     if (ptr->access_list)
      {
          for (i = 0; i < ptr->num_access; ++i)
           {
              free ((struct WFFstatus_st *) ptr->access_list[i].trans_ptr);
           }
           free ((struct WFFaccess_st *) ptr->access_list);
      } 

     /*  Malloc Memory for the access_list */

     ptr->access_list = (struct WFFaccess_st *) malloc (num_classes *
                         sizeof (struct WFFaccess_st));
     if (!ptr->access_list)
      {
         free ((int *) a_list);
         _NFIdebug ((fname, "Malloc : bytes = <%d>\n",
                     num_classes * sizeof (struct WFFaccess_st)));
         WFFglobal.error_no = NFI_E_MALLOC;
         ERRload_struct (NFI, NFI_E_MALLOC, "%d",
                         num_classes * sizeof (struct WFFaccess_st));
         _NFIdebug ((fname, " returning FAILURE\n"));
         return (NFI_E_MALLOC);
      }
     ptr->num_access = num_classes;

     /* malloc memory for each classes access to transitions */

     for (i = 0; i < num_classes; ++i)
      {
         if (a_list[i] > 0)
          {
             ptr->access_list[i].trans_ptr = (struct WFFstatus_st *) malloc (
                                     a_list[i] * sizeof (struct WFFstatus_st));
             if (!ptr->access_list[i].trans_ptr)
              {
                 free ((int *) a_list);
                 _NFIdebug ((fname, "Malloc : bytes = <%d>\n",
                             a_list[i] * sizeof (struct WFFstatus_st)));
                 WFFglobal.error_no = NFI_E_MALLOC;
                 ERRload_struct (NFI, NFI_E_MALLOC, "%d",
                                 a_list[i] * sizeof (struct WFFstatus_st));
                 _NFIdebug ((fname, " returning FAILURE\n"));
                 return (NFI_E_MALLOC);
              }
          }
         else
            ptr->access_list[i].trans_ptr = NULL; 

         ptr->access_list[i].num_trans = a_list[i];
         if((strcmp (ptr->existing_wf_name, "") != 0) &&
	    (WFFglobal.copy_wf))
            strcpy (ptr->access_list[i].status, WFF_ADD);
         else
            strcpy (ptr->access_list[i].status, "");
      }
     free ((int *) a_list);

     /* Put the data in the access_list */

     k = 0;
     if((strcmp (ptr->existing_wf_name, "") != 0) && (WFFglobal.copy_wf))
      {
        for (i = 0; (i < num_classes) && (k < num_rows); ++i) 
         {
           count = data_list->columns * k; 
           strcpy (ptr->access_list[i].class_name, data[count]);
           for (j = 0; (j < ptr->access_list[i].num_trans) && (k < num_rows);
                ++j)
            {
              count = data_list->columns * k; 
              strcpy (ptr->access_list[i].trans_ptr[j].trans_name,  
                      data[count + 1]);
              strcpy (ptr->access_list[i].trans_ptr[j].from_state,  
                      data[count + 2]);
              strcpy (ptr->access_list[i].trans_ptr[j].to_state,  
                      data[count + 3]);
              strcpy (ptr->access_list[i].trans_ptr[j].status, WFF_ADD);
              ++k; 
            } 
         }
      }
     else 
      {
        for (i = 0; (i < num_classes) && (k < num_rows); ++i) 
         {
           count = data_list->columns * k; 
           strcpy (ptr->access_list[i].class_name, data[count]);
           for (j = 0; (j < ptr->access_list[i].num_trans) && (k < num_rows);
                ++j)
            {
              count = data_list->columns * k; 
              strcpy (ptr->access_list[i].trans_ptr[j].trans_name,  
                      data[count + 1]);
              strcpy (ptr->access_list[i].trans_ptr[j].from_state,  
                      data[count + 2]);
              strcpy (ptr->access_list[i].trans_ptr[j].to_state,  
                      data[count + 3]);
              strcpy (ptr->access_list[i].trans_ptr[j].status, "");
              ++k; 
            } 
         }
      }

     status = NFI_S_SUCCESS;
     _NFIdebug ((fname, " returning <0x%.8x>\n", status));
     return (status);
  }



long _WFFdisplay_access (form, g_label, num_access, access_list)
    Form   form;
    int    g_label;   /* CLASS_LIST_SCF */
    int    num_access;
    struct WFFaccess_st access_list[];
  {
     long  status;
     int   i, j, k, num_rows, row;
     int found = FALSE;
     char  class_name[24];
     char  trans_name[81];
     char  from_state[41];

     static char *fname = "_WFFdisplay_access";

     _NFIdebug ((fname, " num_access = <%d>\n", num_access));
    
     strcpy (class_name, "");

     if (num_access <= 0)
      {
         status = NFI_S_SUCCESS;
         _NFIdebug ((fname, " There is no class to transition access\n"));
         _NFIdebug ((fname, " returning <0x%.8x>\n", status));
         return (status);
      }

    /* get the class_name from the CLASS_LIST_SCF */

     status = _WFFget_data_from_field (form, g_label, -1, 0, class_name, 20);
     if (status != NFI_S_SUCCESS)
      {
         _NFIdebug ((fname, " WFFget_data_from_field = <0x%.8x>\n", status));
         _NFIdebug ((fname, " returning FAILURE\n"));
         return (status);
      }

     if (strcmp (class_name, "") == 0)
      {
         _NFIdebug ((fname, "User un-selected the class\n"));
       
         /* un-select all access */
 
         status = _WFFset_all_transitions (form, TRANS_LIST_MCF, FALSE);
         if (status != NFI_S_SUCCESS)
          {
              _NFIdebug ((fname, "_WFFset_all_transitions = <%d>\n", status));
              _NFIdebug ((fname, " returning FAILURE\n"));
              return (status);
          }

         return (NFI_S_SUCCESS);
      }

     /* find the class in the access_list */ 

     k = -1;
     for (i = 0; i < num_access; ++i)
      {
          if ((strcmp (access_list[i].class_name, class_name) == 0) && 
              (strcmp (access_list[i].status, WFF_DROP) != 0))
           {
               k = i;
               break;
           }
      }

     if (k == -1)
      {
         /* the class has no defined access,  un-select all rows */
 
         status = _WFFset_all_transitions (form, TRANS_LIST_MCF, FALSE);
         if (status != NFI_S_SUCCESS)
          {
              _NFIdebug ((fname, "_WFFset_all_transitions = <%d>\n", status));
              _NFIdebug ((fname, " returning FAILURE\n"));
              return (status);
          }

         return (NFI_S_SUCCESS);
      }

     /* Get the number of rows in the field */

     status = (long) FIfld_get_num_rows (form, TRANS_LIST_MCF, &num_rows);
     if (status != FI_SUCCESS)
      {
          _NFIdebug ((fname, "FIfld_get_num_rows = <%d>\n", status));
          ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_get_num_rows",
                          status);
          _NFIdebug ((fname, " returning FAILURE\n"));
          return (NFI_E_FORM);
      }
   
     for (i = 0; i < num_rows; ++i)
      {
         /* get the trans_name from the TRANS_LIST_MCF */

         status = _WFFget_data_from_field (form, TRANS_LIST_MCF, i, 0,
                                           trans_name, 80);
         if (status != NFI_S_SUCCESS)
          {
             _NFIdebug ((fname, " WFFget_data_from_field = <0x%.8x>\n",
                         status));
             _NFIdebug ((fname, " returning FAILURE\n"));
             return (status);
          }

         status = _WFFget_data_from_field (form, TRANS_LIST_MCF, i, 2,
                                           from_state, 40);
         if (status != NFI_S_SUCCESS)
          {
             _NFIdebug ((fname, " WFFget_data_from_field = <0x%.8x>\n",
                         status));
             _NFIdebug ((fname, " returning FAILURE\n"));
             return (status);
          }

         found = FALSE;
         for (row = 0; row < access_list[k].num_trans; ++row)
          {
             if ((strcmp (access_list[k].trans_ptr[row].trans_name,
                          trans_name) == 0) &&
                 (strcmp (access_list[k].trans_ptr[row].from_state,
                          from_state) == 0) &&
                 (strcmp (access_list[k].trans_ptr[row].status, WFF_DROP) != 0))
              {
                   found = TRUE;
                   break;
              }
          }

         for (j = 0; j < 4; ++j)
          { 
             status = (long) FIfld_set_select (form, TRANS_LIST_MCF,
                                               i, j, found); 
             if (status != FI_SUCCESS)
              {
                 _NFIdebug ((fname, "FIfld_set_select = <%d>\n",
                             status));
                 ERRload_struct (NFI, NFI_E_FORM, "%s%d",
                                 "FIfld_set_select", status);
                 _NFIdebug ((fname, " returning FAILURE\n"));
                 return (NFI_E_FORM);
              } 
          }
      } 
   
     status = NFI_S_SUCCESS;
     _NFIdebug ((fname, " returning <0x%.8x>\n", status));
     return (status);
  }


long _WFFupdate_class_access (form, ptr)
    Form   form;
    WFFadd_ptr ptr;
  {
     long  status;
     int   i, j= 0, k, l, num_rows, row;
     int   sel_flag, x;
     int   found = FALSE;
     int   rem_class, m;
     char  class_name[24];
     char  trans_name[81];
     char  from_state[41];
     char  to_state[41];

     static char *fname = "_WFFupdate_class_access";

     _NFIdebug ((fname, " num_access = <%d>\n", ptr->num_access));
    
     strcpy (class_name, "");

    /* get the class_name from the CLASS_LIST_SCF */

     status = _WFFget_data_from_field (form, CLASS_LIST_SCF, -1, 0,
                                       class_name, 20);
     if (status != NFI_S_SUCCESS)
      {
         _NFIdebug ((fname, " WFFget_data_from_field = <0x%.8x>\n", status));
         _NFIdebug ((fname, " returning FAILURE\n"));
         return (status);
      }

     /* If the class_name is null, send a warning to user */
     if (strcmp (class_name, "") == 0)
      {
         _NFIdebug ((fname, "No class has been selected\n"));

         /* Put up a message warning user that the class is null */

         _WFFmessage (NFI_W_NULL_CLASS_NAME, NULL);
         return (NFI_S_SUCCESS);
      }

     /* find the class in the access_list */ 

     k = -1;
     for (i = 0; i < ptr->num_access; ++i)
      {
          if ((strcmp (ptr->access_list[i].class_name, class_name) == 0) && 
              (strcmp (ptr->access_list[i].status, WFF_DROP) != 0))
           {
               k = i;
               break;
           }
      }

     /* Get the number of rows in the field */

     status = (long) FIfld_get_num_rows (form, TRANS_LIST_MCF, &num_rows);
     if (status != FI_SUCCESS)
      {
          _NFIdebug ((fname, "FIfld_get_num_rows = <%d>\n", status));
          ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_get_num_rows",
                          status);
          _NFIdebug ((fname, " returning FAILURE\n"));
          return (NFI_E_FORM);
      }
   
     for (i = 0; i < num_rows; ++i)
      {
         /* get the trans_name from the TRANS_LIST_MCF */

         status = _WFFget_data_from_field (form, TRANS_LIST_MCF, i, 0,
                                           trans_name, 80);
         if (status != NFI_S_SUCCESS)
          {
             _NFIdebug ((fname, " WFFget_data_from_field = <0x%.8x>\n",
                         status));
             _NFIdebug ((fname, " returning FAILURE\n"));
             return (status);
          }

         status = _WFFget_data_from_field (form, TRANS_LIST_MCF, i, 2,
                                           from_state, 40);
         if (status != NFI_S_SUCCESS)
          {
             _NFIdebug ((fname, " WFFget_data_from_field = <0x%.8x>\n",
                         status));
             _NFIdebug ((fname, " returning FAILURE\n"));
             return (status);
          }

         status = _WFFget_data_from_field (form, TRANS_LIST_MCF, i, 3,
                                           to_state, 40);
         if (status != NFI_S_SUCCESS)
          {
             _NFIdebug ((fname, " WFFget_data_from_field = <0x%.8x>\n",
                         status));
             _NFIdebug ((fname, " returning FAILURE\n"));
             return (status);
          }

         /* see if the row is selected */

         status = (long) FIfld_get_select (form, TRANS_LIST_MCF,
                                           i, 0, &sel_flag); 
         if (status != FI_SUCCESS)
          {
             _NFIdebug ((fname, "FIfld_get_select = <%d>\n",
                         status));
             ERRload_struct (NFI, NFI_E_FORM, "%s%d",
                             "FIfld_get_select", status);
             _NFIdebug ((fname, " returning FAILURE\n"));
             return (NFI_E_FORM);
          } 

         if (k != -1) 
          {              /* The class exists in the access list */
             found = FALSE;
             for (row = 0; row < ptr->access_list[k].num_trans; ++row)
              {
                 if ((strcmp (ptr->access_list[k].trans_ptr[row].trans_name,
                              trans_name) == 0) &&
                     (strcmp (ptr->access_list[k].trans_ptr[row].from_state,
                              from_state) == 0) &&
                     (strcmp (ptr->access_list[k].trans_ptr[row].status,
                              WFF_DROP) != 0))
                  {
                       found = TRUE;
                       j = row;
                       break;
                  }
              }
             if ((sel_flag) && (!found))
              {
                  /* add the transition to the class */
    
                  x = ptr->access_list[k].num_trans + 1;
    
                  /* Realloc memory for the transition */
    
                  ptr->access_list[k].trans_ptr =
                  (struct WFFstatus_st *) realloc(ptr->access_list[k].trans_ptr,
                        x * sizeof (struct WFFstatus_st));
                  if (!ptr->access_list[k].trans_ptr)
                   {
                      _NFIdebug ((fname, "Realloc : bytes = <%d>\n",
                                  x * sizeof (struct WFFstatus_st)));
                      WFFglobal.error_no = NFI_E_MALLOC;
                      ERRload_struct (NFI, NFI_E_MALLOC, "%d",
                                      x * sizeof (struct WFFstatus_st));
                      _NFIdebug ((fname, " returning FAILURE\n"));
                      return (NFI_E_MALLOC);
                   }

                  /* put the data in the row and set the status to "WFF_ADD" */
    
                  strcpy (ptr->access_list[k].trans_ptr[x - 1].trans_name,
                          trans_name);
                  strcpy (ptr->access_list[k].trans_ptr[x - 1].from_state,
                          from_state);
                  strcpy (ptr->access_list[k].trans_ptr[x - 1].to_state,
                          to_state);
                  strcpy (ptr->access_list[k].trans_ptr[x - 1].status, WFF_ADD);
                  ptr->access_list[k].num_trans = x;
             }
            else if ((!sel_flag) && (found))
             {
                  /* delete the transition from the class */

                  if (strcmp (ptr->access_list[k].trans_ptr[j].status,
                              WFF_ADD) == 0)
                   {
                      x = ptr->access_list[k].num_trans - 1;
           
                      if (x == 0)
                       {
                           /* delete the trans_ptr */
       
                           free ((struct WFFstatus_st *)
                                  ptr->access_list[k].trans_ptr);

                           if (ptr->num_access == 1)
                            {
                               /* there is only one class, free it */

                               free ((struct WFFaccess_st *) ptr->access_list);
                               ptr->access_list = NULL;
                               ptr->num_access = 0;
                            }
                           else
                            {
                               /* move all classes up by 1 */

                               for (j = k; j < ptr->num_access -1; ++j)
                                  ptr->access_list[j] = ptr->access_list[j + 1];
    
                               /* Realloc memory for the class */
        
                               ptr->access_list=(struct WFFaccess_st *)realloc (
                                  ptr->access_list, (ptr->num_access - 1) * 
                                              sizeof (struct WFFaccess_st));
                               if (!ptr->access_list)
                                { 
                                  _NFIdebug ((fname, "Realloc : bytes = <%d>\n",
                                  (ptr->num_access - 1) * sizeof (struct WFFaccess_st)));
                                   WFFglobal.error_no = NFI_E_MALLOC;
                                   ERRload_struct (NFI, NFI_E_MALLOC, "%d",
                                   (ptr->num_access - 1) * sizeof(struct WFFaccess_st));
                                   _NFIdebug ((fname, " returning FAILURE\n"));
                                   return (NFI_E_MALLOC);
                                }
                               --(ptr->num_access); 
                           }
                          status = NFI_S_SUCCESS;
                          _NFIdebug ((fname, " returning <0x%.8x>\n", status));
                          return (status);
                       }
                      else
                       {
                           /* move all transitions up by 1 */

                           for (l= j; l < ptr->access_list[k].num_trans -1; ++l)
                              ptr->access_list[k].trans_ptr[l] =
                                         ptr->access_list[k].trans_ptr[l + 1];
    
                           /* Realloc memory for the transition */
        
                           ptr->access_list[k].trans_ptr =
                                             (struct WFFstatus_st *) realloc (
                                             ptr->access_list[k].trans_ptr, x * 
                                                 sizeof (struct WFFstatus_st));
                           if (!ptr->access_list[k].trans_ptr)
                            { 
                               _NFIdebug ((fname, "Realloc : bytes = <%d>\n",
                                           x * sizeof (struct WFFstatus_st)));
                               WFFglobal.error_no = NFI_E_MALLOC;
                               ERRload_struct (NFI, NFI_E_MALLOC, "%d",
                                               x * sizeof(struct WFFstatus_st));
                               _NFIdebug ((fname, " returning FAILURE\n"));
                               return (NFI_E_MALLOC);
                            }

                           ptr->access_list[k].num_trans = x; 
                       }
                  }
                 else
                  {
                     /* mark the transition as dropped */
                     rem_class = TRUE; 
                     strcpy (ptr->access_list[k].trans_ptr[j].status, WFF_DROP);
                     for (m = 0; m < ptr->access_list[k].num_trans; ++m)
                      {
                          if (strcmp (ptr->access_list[k].trans_ptr[m].status,
                                      WFF_DROP) != 0)
                           {
                               rem_class = FALSE;
                               break;
                           }
                      }

                     if (rem_class)
                      {
                          /* all the transitions have been marked as dropped */
                          /* so, mark the class as dropped also */ 

                          strcpy (ptr->access_list[k].status, WFF_DROP);
                      }
                  }
             }
          }
         else if (sel_flag)
          {
             /* malloc memory for a new class access and put the trans in it */

             x = ptr->num_access + 1;

             if (ptr->access_list == NULL)
              {
                 _NFIdebug ((fname, "Malloc memory for the access_list\n"));
                 ptr->access_list = (struct WFFaccess_st *)  malloc (x *
                                              sizeof (struct WFFaccess_st));
                 if (!ptr->access_list)
                  { 
                      _NFIdebug ((fname, "Malloc : bytes = <%d>\n",
                                 x * sizeof(struct WFFaccess_st)));
                      WFFglobal.error_no = NFI_E_MALLOC;
                      ERRload_struct (NFI, NFI_E_MALLOC, "%d",
                                             x * sizeof(struct WFFaccess_st));
                      _NFIdebug ((fname, " returning FAILURE\n"));
                      return (NFI_E_MALLOC);
                  }
              }
             else
              {
                 ptr->access_list = (struct WFFaccess_st *)  realloc (
                            ptr->access_list, x * sizeof (struct WFFaccess_st));
                 if (!ptr->access_list)
                  { 
                      _NFIdebug ((fname, "Realloc : bytes = <%d>\n",
                                 x * sizeof(struct WFFaccess_st)));
                      WFFglobal.error_no = NFI_E_MALLOC;
                      ERRload_struct (NFI, NFI_E_MALLOC, "%d",
                                             x * sizeof(struct WFFaccess_st));
                      _NFIdebug ((fname, " returning FAILURE\n"));
                      return (NFI_E_MALLOC);
                  }
              }

             /* put the class information in the struct */

             strcpy (ptr->access_list[x -1].class_name, class_name);
             strcpy (ptr->access_list[x -1].status, WFF_ADD);
             ptr->access_list[x - 1].num_trans = 1;
             ptr->num_access = x;
        
             /* Malloc memory for the transition */

             ptr->access_list[x - 1].trans_ptr=(struct WFFstatus_st *) malloc ( 
                                              sizeof (struct WFFstatus_st));
             if (!ptr->access_list[x - 1].trans_ptr)
              { 
                  _NFIdebug ((fname, "Malloc : bytes = <%d>\n",
                                     sizeof(struct WFFstatus_st)));
                  WFFglobal.error_no = NFI_E_MALLOC;
                  ERRload_struct (NFI, NFI_E_MALLOC, "%d",
                                                  sizeof(struct WFFstatus_st));
                  _NFIdebug ((fname, " returning FAILURE\n"));
                  return (NFI_E_MALLOC);
              }

             strcpy (ptr->access_list[x -1].trans_ptr[0].trans_name,
                     trans_name);
             strcpy (ptr->access_list[x -1].trans_ptr[0].from_state,
                     from_state);
             strcpy (ptr->access_list[x -1].trans_ptr[0].to_state, to_state);
             strcpy (ptr->access_list[x -1].trans_ptr[0].status, WFF_ADD);

             k = x - 1;  
          }
      }

     status = NFI_S_SUCCESS;
     _NFIdebug ((fname, " returning <0x%.8x>\n", status));
     return (status);
  }

