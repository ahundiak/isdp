#include "machine.h"
#include "WFF.h"
#include "WFFadd_wf.h"
#include "WFFlist.h"
#include "WFFpage2.h"
#include "NFMschema.h"

/*  Global WFF structure  */

extern struct WFFglobal_st WFFglobal;

/********************************************************************
 *                                                                  * 
 *  Function : WFFpage2                                             *
 *                                                                  * 
 *                                                                  * 
 ********************************************************************/

long _WFFpage2 (ptr)
    WFFadd_ptr   ptr;  
  {
   long    status;
   long    m_status;
   int     i;
   int     num_rows = 0;
   char    s[256];
   char    state_name[48];
   char    state_desc[48];
   char    signoffs[48];
   char    majority[48];
   char    trans_from[48];
   char    trans_to[48];
   char    seqno[48];
   char    seq_no[16];
   char    **data;
   MEMptr  attr_list = NULL;
   MEMptr  data_list = NULL;
   static   char *fname = "_WFFpage2";

   _NFIdebug ((fname, " Function Entered\n"));

   /* Put up a message */

   _WFFmessage (NFI_I_RETRIEVE, NULL);  /* Retrieving data from server */

   strcpy (state_name, "State Name");
   strcpy (state_desc, "State Description");
   strcpy (signoffs, "Number Signoffs");
   strcpy (majority, "Mandatory");
   strcpy (trans_from, "Transition From");
   strcpy (trans_to, "Transition To");
   strcpy (seqno, "Sequence Number");

   _NFIdebug(( fname, "Existing workflow name <%s>\n", ptr->existing_wf_name));
   _NFIdebug(( fname, "Old workflow name <%s>\n", ptr->old_wf_name));
   _NFIdebug(( fname, "Workflow name <%s>\n", ptr->workflow_name));
   _NFIdebug(( fname, "Num of classes <%d>\n", ptr->num_classes));

   if ((strcmp (ptr->existing_wf_name, "")) ||  
       (strcmp (ptr->old_wf_name, "")) || (strcmp (ptr->workflow_name, "")))
    {
       if (ptr->num_classes == 0)
        {
           /* Get the long list of classes two columns are returned. */

            if (strcmp (ptr->old_wf_name, "")) 
              status = WFGn_list_classes (ptr->old_wf_name, &attr_list,
                                          &data_list);
           else
              status = WFGn_list_classes (ptr->existing_wf_name,
                                          &attr_list, &data_list);
           if ((status != NFM_S_SUCCESS) &&
               (status != NFM_E_NO_CLASSES_DEFINED))
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

           if ((status != NFM_S_SUCCESS) &&
               (status != NFM_E_NO_STATES_DEFINED))
            {
               MEMclose (&attr_list);
               MEMclose (&data_list);
               _NFIdebug ((fname, "WFGn_list_states = <0x%.8x>\n", status));
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
               _NFIdebug ((fname, "MEMbuild_array = <0x%.8x>\n", m_status));
               _WFFerase_message ();
               _WFFfree_add_ptr (ptr);
               _NFIdebug ((fname, " returning <0x%.8x>\n", NFI_E_MEM));
               return (NFI_E_MEM);
            }
/*
           if (WFFglobal.debug_on)
            {
               MEMprint_buffer ("attr_list", attr_list, WFFglobal.debug_file);
            }
*/
           data = (char **) attr_list->data_ptr;

           if (strcmp (data[1], ""))
              strcpy (state_name, data[1]);

           if (strcmp (data[2], ""))
              strcpy (state_desc, data[2]);

           if (strcmp (data[3], ""))
              strcpy (signoffs, data[3]);

           if (strcmp (data[4], ""))
              strcpy (majority, data[4]);

           if (strcmp (data[5], ""))
              strcpy (trans_from, data[5]);

           if (strcmp (data[6], ""))
              strcpy (trans_to, data[6]);

           if (strcmp (data[7], ""))
              strcpy (seqno, data[7]);
    
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
            }

            MEMclose (&data_list);
            data_list = NULL;
        }
    }

   if (ptr->page2_form == NULL)
    {
       /*  Load in the PAGE2 form  */
       _NFIdebug(( fname, "Load in the PAGE_2 form\n" ));
       if ((status = (long) FIf_new (PAGE2_LABEL, WF_PAGE2_FORM,
                               _WFFnotify, &(ptr->page2_form))) != FI_SUCCESS)
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
          (ptr->page2_form, (char *) ptr)) != FI_SUCCESS)
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
    
       status = (long) FIfld_set_max_num_chars (ptr->page2_form,
                                                CLASS_NAME_FIELD, 0, 20);
       status = (long) FIfld_set_max_num_chars (ptr->page2_form,
                                                STATE_NAME_FIELD, 0, 40);
       status = (long) FIfld_set_max_num_chars (ptr->page2_form,
                                                STATE_DESC_FIELD, 0, 40);
       status = (long) FIfld_set_max_num_chars (ptr->page2_form,
                                                STATE_SEQNO_FIELD, 0, 15);
       status = (long) FIfld_set_max_num_chars (ptr->page2_form,
                                                MIN_NO_SIGNOFFS_FIELD, 0, 15);

       /* clear out the fields */

/* IGI Intel Solaris Port - CN 31/5/95 */
#if defined(OS_SCO_UNIX) || defined(OS_INTELSOL)
	/* To set font for SCO - CRN 25 Feb 94	*/
	FIg_set_font(ptr->page2_form, CLASS_NAME_FIELD, "7x13bold", 15);
#endif
       FIfld_set_text (ptr->page2_form, CLASS_NAME_FIELD, 0, 0, "", FALSE);
/* IGI Intel Solaris Port - CN 31/5/95 */
#if defined(OS_SCO_UNIX) || defined(OS_INTELSOL)
	/* To set font for SCO - CRN 25 Feb 94	*/
	FIg_set_font(ptr->page2_form, STATE_NAME_FIELD, "7x13bold", 15);
#endif
       FIfld_set_text (ptr->page2_form, STATE_NAME_FIELD, 0, 0, "", FALSE);
/* IGI Intel Solaris Port - CN 31/5/95 */
#if defined(OS_SCO_UNIX) || defined(OS_INTELSOL)
	/* To set font for SCO - CRN 25 Feb 94	*/
	FIg_set_font(ptr->page2_form, STATE_DESC_FIELD, "7x13bold", 15);
#endif
       FIfld_set_text (ptr->page2_form, STATE_DESC_FIELD, 0, 0, "", FALSE);
/* IGI Intel Solaris Port - CN 31/5/95 */
#if defined(OS_SCO_UNIX) || defined(OS_INTELSOL)
	/* To set font for SCO - CRN 25 Feb 94	*/
	FIg_set_font(ptr->page2_form, STATE_SEQNO_FIELD, "7x13bold", 15);
#endif
       FIfld_set_text (ptr->page2_form, STATE_SEQNO_FIELD, 0, 0, "", FALSE);
/* IGI Intel Solaris Port - CN 31/5/95 */
#if defined(OS_SCO_UNIX) || defined(OS_INTELSOL)
	/* To set font for SCO - CRN 25 Feb 94	*/
	FIg_set_font(ptr->page2_form, MIN_NO_SIGNOFFS_FIELD, "7x13bold", 15);
#endif
       FIfld_set_text (ptr->page2_form, MIN_NO_SIGNOFFS_FIELD, 0, 0, "", FALSE);

       status = (long) FIfld_set_num_rows (ptr->page2_form,
                                           CLASS_LIST_SCF, 0);
       status = (long) FIfld_set_num_rows (ptr->page2_form,
                                           STATE_LIST_MCF, 0);

/* IGI Intel Solaris Port - CN 31/5/95 */
#if defined(OS_SCO_UNIX) || defined(OS_INTELSOL)
	/* To set font for SCO - CRN 25 Feb 94	*/
	FIg_set_font(ptr->page2_form, STATE_SYNONYM_MCF, "7x13bold", 15);
#endif
       /* Put the state synonyms into the synonyms MCF */

       for (i = 0; i < 7; ++i)
        {
           switch (i)
            {
               case 0:
                  status = FIfld_set_text (ptr->page2_form,
                            STATE_SYNONYM_MCF, 0, i, state_name, FALSE);
               break;

               case 1:
                  status = FIfld_set_text (ptr->page2_form,
                                 STATE_SYNONYM_MCF, 0, i, state_desc, FALSE);
               break;

               case 2:
                  status = FIfld_set_text (ptr->page2_form,
                                 STATE_SYNONYM_MCF, 0, i, signoffs, FALSE);
               break;

               case 3:
                  status = FIfld_set_text (ptr->page2_form,
                                 STATE_SYNONYM_MCF, 0, i, majority, FALSE);
               break;

               case 4:
                  status = FIfld_set_text (ptr->page2_form,
                                 STATE_SYNONYM_MCF, 0, i, trans_from, FALSE);
               break;

               case 5:
                  status = FIfld_set_text (ptr->page2_form,
                                 STATE_SYNONYM_MCF, 0, i, trans_to, FALSE);
               break;

               case 6:
                  status = FIfld_set_text (ptr->page2_form,
                                 STATE_SYNONYM_MCF, 0, i, seqno, FALSE);
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
    
       status = (long) UMSGetByNum (s, NFI_P_CLASS_STATE_DEF, "%s",
                                         ptr->workflow_name);  
       if (status != UMS_S_SUCCESS)  
        {
           _NFIdebug ((fname, "UMSGetByNum = <0x%.8x>\n", status));
           _NFIdebug ((fname, "defaulting title\n"));
           sprintf (s,  
                    "Define the classes and states allowed in workflow \"%s\"",
                    ptr->workflow_name);
        }
    
       if ((status = (long) FIg_set_text
                 (ptr->page2_form, TITLE1, s)) != FI_SUCCESS)
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

       if (ptr->wf_in_use)
        {
           /* Disable the 'DELETE STATE' buttons */
  
           FIg_disable (ptr->page2_form, DELETE_STATE_BUTTON);
        }
    }
    
   /* Check to see if the data has been placed in the SCF already */

   status = (long) FIfld_get_num_rows (ptr->page2_form, CLASS_LIST_SCF,
                                       &num_rows); 
   if (status != FI_SUCCESS)
    {
        _NFIdebug ((fname, "FIfld_get_num_rows = <%d>\n", status));
        _WFFerase_message ();
        _WFFfree_add_ptr (ptr);
        WFFglobal.error_no = NFI_E_FORM;
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_get_num_rows", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
    }
         
   if (num_rows <= 0)
    {
       /*  Put the classes in the scroll list  */
    
       status = _WFFput_classes_in_list (ptr->page2_form, CLASS_LIST_SCF, ptr);
       if (status != NFI_S_SUCCESS) 
        {
           _NFIdebug ((fname, "WFFput_classes_in_list = <0x%.8x>\n", status));
           _WFFerase_message ();
           _WFFfree_add_ptr (ptr);
           WFFglobal.error_no = status;
           _NFIdebug ((fname, " returning <0x%.8x>\n", status));
           return (status);
        }
    
       /*  clear out the class_name field */
    
/* IGI Intel Solaris Port - CN 31/5/95 */
#if defined(OS_SCO_UNIX) || defined(OS_INTELSOL)
	/* To set font for SCO - CRN 25 Feb 94	*/
	FIg_set_font(ptr->page2_form, CLASS_NAME_FIELD, "7x13bold", 15);
#endif
       status = FIfld_set_text (ptr->page2_form, CLASS_NAME_FIELD, 0, 0,
                                "", FALSE);
       if (status != FI_SUCCESS)
        {
           _NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
	   _WFFerase_message(); 
           _WFFfree_add_ptr (ptr);
           WFFglobal.error_no = NFI_E_FORM;
           ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_text",
                                status);
           _NFIdebug ((fname, " returning FAILURE\n"));
           return (NFI_E_FORM);
        }
    }
    
   num_rows = 0;
    
   /* Check to see if the data has been placed in the MCF already */

   status = (long) FIfld_get_num_rows (ptr->page2_form, STATE_LIST_MCF,  
                                       &num_rows); 
   if (status != FI_SUCCESS)
    {
        _NFIdebug ((fname, "FIfld_get_num_rows = <%d>\n", status));
        _WFFerase_message ();
        _WFFfree_add_ptr (ptr);
        WFFglobal.error_no = NFI_E_FORM;
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_get_num_rows", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
    }
         
   if (num_rows <= 0)
    {
       /*  Put the states in the scroll list  */
    
       status = _WFFput_states_in_list (ptr->page2_form, STATE_LIST_MCF,
                                        ptr->num_states, ptr->state_list);
       if (status != NFI_S_SUCCESS) 
        {
           _NFIdebug ((fname, "WFFput_states_in_list = <0x%.8x>\n", status));
           _WFFerase_message ();
           _WFFfree_add_ptr (ptr);
           WFFglobal.error_no = status;
           _NFIdebug ((fname, " returning <0x%.8x>\n", status));
           return (status);
        }

       /* link scrolling of STATE_LIST_MCF to the STATE_SYNONYM_MCF */ 
    
       status = (long) FImcf_set_scroll_link (ptr->page2_form,
                                         STATE_LIST_MCF, STATE_SYNONYM_MCF);
       if (status != FI_SUCCESS)
        {
           _NFIdebug ((fname, "FImcf_set_scroll_link = <%d>\n", status));
           _WFFfree_add_ptr (ptr);
           WFFglobal.error_no = NFI_E_FORM;
           ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FImcf_set_scroll_link",
                           status);
           _NFIdebug ((fname, " returning FAILURE\n"));
           return (NFI_E_FORM);
        }

       /*  clear out the state_name field */
    
       status = (long) FIfld_set_text (ptr->page2_form,
                                       STATE_NAME_FIELD, 0, 0, "", FALSE);
       if (status != FI_SUCCESS)
        {
           _NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
           _WFFfree_add_ptr (ptr);
           WFFglobal.error_no = NFI_E_FORM;
           ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_text", status);
           _NFIdebug ((fname, " returning FAILURE\n"));
           return (NFI_E_FORM);
        }
    
       /*  clear out the state_desc field */
    
       status = (long) FIfld_set_text (ptr->page2_form,
                                       STATE_DESC_FIELD, 0, 0, "", FALSE);
       if (status != FI_SUCCESS)
        {
           _NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
           _WFFfree_add_ptr (ptr);
           WFFglobal.error_no = NFI_E_FORM;
           ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_text", status);
           _NFIdebug ((fname, " returning FAILURE\n"));
           return (NFI_E_FORM);
        }
    
       /*  clear out the seq_no field */
    
       _WFFget_next_seq_no (ptr->num_states, ptr->state_list, seq_no);
       status = (long) FIfld_set_text (ptr->page2_form,
                                    STATE_SEQNO_FIELD, 0, 0, seq_no, FALSE);
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
    
       /*  set the min_no_signoffs field to zero  */
    
       status = (long) FIfld_set_text (ptr->page2_form,
                                      MIN_NO_SIGNOFFS_FIELD, 0, 0, "0", FALSE);
       if (status != FI_SUCCESS)
        {
           _NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
           _WFFfree_add_ptr (ptr);
           WFFglobal.error_no = NFI_E_FORM;
           ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_text", status);
           _NFIdebug ((fname, " returning FAILURE\n"));
           return (NFI_E_FORM);
        }
    }

   /* Erase the message */

   _WFFerase_message (); /* Erase "Retrieving data from server" msg */

   WFFglobal.current_form = ptr->page2_form;

   /*  Clear out the error message strip  */

   _WFFclear_msg (WFFglobal.current_form);

   /*  Adjust and Center the form */

   if ((status = _WFFadjust_wf_form (WFFglobal.current_form)) != NFI_S_SUCCESS)
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

   /*  Position the cursor into the class_name field  */

   status = (long) FIfld_pos_cursor (WFFglobal.current_form,
                                          CLASS_NAME_FIELD, 0, 0, 0, 0, 0, 0);
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



long _WFFpage2_notify (g_label, value, form)
  int      g_label;
  double   value;
  Form      form;
 {
   long   status = NFI_S_SUCCESS;
   char   seq_no[16];
   long   _WFFchange_class();
   long   _WFFchange_state();

   WFFadd_ptr   ptr;

   static   char *fname = "_WFFpage2_notify";

   /*  Local functions  */

   _NFIdebug ((fname, "g_label = <%d>\n", g_label));
   _NFIdebug ((fname, "value = <%d>\n", value));

   /*  Pull out the pointer to the data  */

   if ((status = (long) FIf_get_user_pointer
      (form, (char *) &ptr)) != FI_SUCCESS)
    {
       _NFIdebug ((fname, "FIf_get_user_pointer = <%d>\n", status));
       ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIf_get_user_pointer", status);
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

         status = WFGadd_workflow (WFFglobal.user_id, ptr->workflow_name,
                        ptr->old_wf_name, ptr->workflow_desc, ptr->num_classes,
                        ptr->class_list, ptr->num_states, ptr->state_list,
                        ptr->num_trans, ptr->trans_list, ptr->num_access, 
                        ptr->access_list);

         if (status != NFM_S_SUCCESS)
          {
              _NFIdebug ((fname, "WFGadd_workflow = <0x%.8x>\n", status));
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

	/*  Put form back like it was to begin with */

        /* clear out the fields */

/* IGI Intel Solaris Port - CN 31/5/95 */
#if defined(OS_SCO_UNIX) || defined(OS_INTELSOL)
	/* To set font for SCO - CRN 25 Feb 94	*/
	FIg_set_font(ptr->page2_form, CLASS_NAME_FIELD, "7x13bold", 15);
#endif
         FIfld_set_text (ptr->page2_form, CLASS_NAME_FIELD, 0, 0, "", FALSE);
/* IGI Intel Solaris Port - CN 31/5/95 */
#if defined(OS_SCO_UNIX) || defined(OS_INTELSOL)
	/* To set font for SCO - CRN 25 Feb 94	*/
	FIg_set_font(ptr->page2_form, STATE_NAME_FIELD, "7x13bold", 15);
#endif
         FIfld_set_text (ptr->page2_form, STATE_NAME_FIELD, 0, 0, "", FALSE);
/* IGI Intel Solaris Port - CN 31/5/95 */
#if defined(OS_SCO_UNIX) || defined(OS_INTELSOL)
	/* To set font for SCO - CRN 25 Feb 94	*/
	FIg_set_font(ptr->page2_form, STATE_DESC_FIELD, "7x13bold", 15);
#endif
         FIfld_set_text (ptr->page2_form, STATE_DESC_FIELD, 0, 0, "", FALSE);
    
       /*  clear out the seq_no field */
/* IGI Intel Solaris Port - CN 31/5/95 */
#if defined(OS_SCO_UNIX) || defined(OS_INTELSOL)
	/* To set font for SCO - CRN 25 Feb 94	*/
	FIg_set_font(ptr->page2_form, STATE_SEQNO_FIELD, "7x13bold", 15);
#endif
    
       _WFFget_next_seq_no (ptr->num_states, ptr->state_list, seq_no);
       status = (long) FIfld_set_text (ptr->page2_form,
                                    STATE_SEQNO_FIELD, 0, 0, seq_no, FALSE);
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
    
       /*  set the min_no_signoffs field to zero  */
    
       status = (long) FIfld_set_text (ptr->page2_form,
                                      MIN_NO_SIGNOFFS_FIELD, 0, 0, "0", FALSE);
       if (status != FI_SUCCESS)
        {
           _NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
           _WFFfree_add_ptr (ptr);
           WFFglobal.error_no = NFI_E_FORM;
           ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_text", status);
           _NFIdebug ((fname, " returning FAILURE\n"));
           return (NFI_E_FORM);
        }
 	
	/*  Unselect all fields */

        status = _WFFset_all_transitions (form, STATE_LIST_MCF, FALSE);
        if (status != NFI_S_SUCCESS)
        {
            _NFIdebug ((fname,"_WFFset_all_transitions = <0x%.8x>\n", status));
        }

        status = _WFFset_all_transitions (form, CLASS_LIST_SCF, FALSE);
        if (status != NFI_S_SUCCESS)
        {
            _NFIdebug ((fname,"_WFFset_all_transitions = <0x%.8x>\n", status));
        }

         /*  Position the cursor into the class_name field  */

         status = (long) FIfld_pos_cursor (WFFglobal.current_form,
                                          CLASS_NAME_FIELD, 0, 0, 0, 0, 0, 0);
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

	break;

      case FI_ACCEPT:

         /*  Put up a message  */

         _WFFmessage (WFFglobal.working_no, NULL);

         /*  Call NFM or WFG to do the command  */

         _NFIdebug ((fname, "calling WFGadd_workflow...\n"));

         status = WFGadd_workflow (WFFglobal.user_id, ptr->workflow_name,
                        ptr->old_wf_name, ptr->workflow_desc, ptr->num_classes,
                        ptr->class_list, ptr->num_states, ptr->state_list,
                        ptr->num_trans, ptr->trans_list, ptr->num_access, 
                        ptr->access_list);

         if (status != NFM_S_SUCCESS)
          {
              _NFIdebug ((fname, "WFGadd_workflow = <0x%.8x>\n", status));
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

       case CLASS_NAME_FIELD:

         /* If a class is selected in the SCF */ 
         /* Update the class name in the class list structure 

         status = _WFFupdate_class (form, g_label, CLASS_LIST_SCF,
                                    ptr->num_classes, ptr->class_list,
                                    ptr->num_access, ptr->access_list);
	  */
       break;

       case ADD_CLASS_BUTTON:

         /* Call function to add the class to the buffer */

         status = _WFFadd_class (form, CLASS_NAME_FIELD, ptr);
       break;

       case DELETE_CLASS_BUTTON:

         status = (long) _WFFconfirm_delete_class( form, CLASS_LIST_SCF,
						   ptr );
       break;

       case CHANGE_CLASS_BUTTON:

         /* Call function to change the class in the buffer */

         status = _WFFchange_class (form, CLASS_NAME_FIELD, ptr);
       break;

       case CLASS_LIST_SCF:

         /* Display the class name in the class name field */

         status = _WFFset_selected_class (form, CLASS_NAME_FIELD, g_label);
       break;

       case STATE_LIST_MCF:
         /* Get the existing data from the data_list and put the values in
            the required fields and update the toggles                     */

         status = _WFFset_selected_state (form, g_label);
       break;

       case STATE_NAME_FIELD:
/*
         status = _WFFupdate_state_name (form, g_label, STATE_LIST_MCF, ptr);
*/
       break;

       case STATE_DESC_FIELD:
/*
          status = _WFFupdate_state_desc (form, g_label, STATE_LIST_MCF, ptr);
*/
       break;
 
       case MANDATORY_TOGGLE:
       case TO_STATE_TOGGLE:

          /* update the state_list MCF and data_list */ 
/*
          status=_WFFupdate_state_toggles (form, g_label, STATE_LIST_MCF, ptr);
*/
       break;

       case FROM_STATE_TOGGLE:
          status = _WFFcheck_so_state (form);
          if (status != NFI_S_SUCCESS)
           {
              _NFIdebug ((fname, "WFFcheck_so_state = <0x%.8x>\n", status));
              break;
           } 

          /* update the state_list MCF and data_list */ 

/*
          status =_WFFupdate_state_toggles (form, g_label, STATE_LIST_MCF, ptr);
*/
       break;

       case MIN_NO_SIGNOFFS_FIELD:
          status = _WFFcheck_so_state (form);
          if (status != NFI_S_SUCCESS)
           {
              _NFIdebug ((fname, "_WFFcheck_so_state = <0x%.8x>\n", status));
              break;
           } 

          /* update the state_list MCF and data_list */ 

/*
          status = _WFFupdate_state_signoffs (form, g_label, STATE_LIST_MCF,
                                              ptr);
          if (status != NFI_S_SUCCESS)
           {
              _NFIdebug ((fname, "_WFFupdate_state_signoffs = <0x%.8x>\n",
                          status));
              break;
           }
*/
          /* update the state_list MCF and data_list */ 

/*
          status = _WFFupdate_state_signoffs (form, FROM_STATE_TOGGLE,
                                              STATE_LIST_MCF, ptr);
          if (status != NFI_S_SUCCESS)
           {
              _NFIdebug ((fname, "_WFFupdate_state_toggles = <0x%.8x>\n",
                          status));
              break;
           }

           status = _WFFupdate_state_toggles (form, MANDATORY_TOGGLE,
                                              STATE_LIST_MCF, ptr);
*/
       break;

       case STATE_SEQNO_FIELD:
          /* Call function to verify that seqno is unique */
          /* update the state_list MCF and data_list */ 
/*
          status = _WFFupdate_state_seqno (form, g_label, STATE_LIST_MCF, ptr);
*/  
     break;

       case ADD_STATE_BUTTON:
         /* Call function to add the state to the list */

         status = _WFFadd_states (form, STATE_NAME_FIELD, ptr);
       break;


       case DELETE_STATE_BUTTON:
	 /* Call function to confirm delete state */

         status = (long) _WFFconfirm_delete_state( form, STATE_LIST_MCF,
						   ptr );
       break;

       case CHANGE_STATE_BUTTON:
         /* Call function to change the state in the list */

         status = _WFFchange_state (form, ptr);
       break;

       case WF_PAGE_SCRL_BAR:
         /* Call function to process the page scroll Bar */

         status = _WFFscroll_pages (form, g_label, value, ptr);
       break;
    }

   _NFIdebug ((fname, " returning <0x%.8x>\n", status));
   return (status);
  }


long _WFFload_class_in_list (data_list, ptr)
   MEMptr      data_list;
   WFFadd_ptr  ptr;   
  {
     long  status;
     int   i, rows, cols, length;
     char  **data;

     static char *fname = "_WFFload_class_in_list";

     _NFIdebug(( fname, "Existing Workflow <%s>\n",ptr->existing_wf_name ));
     _NFIdebug(( fname, "Workflow Name <%s>\n",ptr->workflow_name ));
     _NFIdebug(( fname, "Old Workflow <%s>\n",ptr->old_wf_name ));

     if (data_list)
      {
         rows = data_list->rows;
         cols = data_list->columns;
         data = (char **) data_list->data_ptr;

         if (ptr->class_list)
           free ((struct WFFclass_st *) ptr->class_list);
         
         /* malloc memory for the list */

         ptr->class_list = (struct WFFclass_st *) malloc (rows * 
                            sizeof (struct WFFclass_st));
         if (!ptr->class_list)
          {
             _NFIdebug ((fname, "Malloc : bytes = <%d>\n",
                         rows * sizeof (struct WFFclass_st)));
             WFFglobal.error_no = NFI_E_FORM;
             ERRload_struct (NFI, NFI_E_MALLOC, "%d",
                             rows * sizeof (struct WFFclass_st));
             _NFIdebug ((fname, " returning FAILURE\n"));
             return (NFI_E_MALLOC);
          }

         /* put the data into the class_list */

         length = 20;

         if (strcmp (ptr->existing_wf_name, "") != 0)
          {
             for (i = 0; i < rows; ++i)
              {
                 ptr->class_list[i].class_no = 0; 
                 strcpy (ptr->class_list[i].class_name, data[cols * i + 1]);
                 strcpy (ptr->class_list[i].status, WFF_ADD); 
                 ptr->class_list[i].row = i; 
		 _NFIdebug(( fname, "Marking class <%s> to ADD\n",
			ptr->class_list[i].class_name ));
              }
          }
         else
          {
             for (i = 0; i < rows; ++i)
              {
		 _NFIdebug(( fname, "Loading class number <%s> for class <%s>\n", data[cols*i], data[cols*i+1] ));
                 ptr->class_list[i].class_no = atol (data[cols * i]); 
                 strcpy (ptr->class_list[i].class_name, data[cols * i + 1]);
                 strcpy (ptr->class_list[i].status, ""); 
                 ptr->class_list[i].row = i; 
              }
          }

         ptr->num_classes = rows;
      }
      
     status = NFI_S_SUCCESS;
     _NFIdebug ((fname, " returning <0x%.8x>\n", status));
     return (status);
  }


long _WFFload_states_in_list (data_list, ptr)
   MEMptr      data_list;
   WFFadd_ptr  ptr;

  {
     long  status;
     int   i, rows, cols, length;
     char  **data;

     static char *fname = "_WFFload_states_in_list";

     _NFIdebug ((fname, " Function entered...\n"));

     if (data_list)
      {
         rows = data_list->rows;
         cols = data_list->columns;
         data = (char **) data_list->data_ptr;
         if (ptr->state_list)
           free ((struct WFFstate_st *) ptr->state_list);
         
         /* malloc memory for the list */

         ptr->state_list = (struct WFFstate_st *) malloc (rows * 
                            sizeof (struct WFFstate_st));
         if (!ptr->state_list)
          {
             _NFIdebug ((fname, "Malloc : bytes = <%d>\n",
                         rows * sizeof (struct WFFstate_st)));
             WFFglobal.error_no = NFI_E_FORM;
             ERRload_struct (NFI, NFI_E_MALLOC, "%d",
                                     rows * sizeof (struct WFFstate_st));
             _NFIdebug ((fname, " returning FAILURE\n"));
             return (NFI_E_MALLOC);
          }

         /* put the data into the state_list */

         length = 40;

         if (strcmp (ptr->existing_wf_name, "") != 0)
          {
             for (i = 0; i < rows; ++i)
              {
                 ptr->state_list[i].state_no = 0;
                 strcpy (ptr->state_list[i].state_name,  data[cols * i + 1]);
                 strcpy (ptr->state_list[i].state_desc,  data[cols * i + 2]); 
                 strcpy (ptr->state_list[i].no_signoffs, data[cols * i + 3]);
                 strcpy (ptr->state_list[i].majority,    data[cols * i + 4]);
                 strcpy (ptr->state_list[i].trans_from,  data[cols * i + 5]);
                 strcpy (ptr->state_list[i].trans_to,    data[cols * i + 6]);
                 strcpy (ptr->state_list[i].seq_no,      data[cols * i + 7]);
                 strcpy (ptr->state_list[i].status, WFF_ADD); 
                 ptr->state_list[i].row = i; 
                 _NFIdebug(( fname, "Marking state <%s> to ADD\n",
                        ptr->state_list[i].state_name ));
              }
          }
         else
          {
             for (i = 0; i < rows; ++i)
              {
                 ptr->state_list[i].state_no = atol(data[cols * i]);
                 strcpy (ptr->state_list[i].state_name,  data[cols * i + 1]);
                 strcpy (ptr->state_list[i].state_desc,  data[cols * i + 2]); 
                 strcpy (ptr->state_list[i].no_signoffs, data[cols * i + 3]);
                 strcpy (ptr->state_list[i].majority,    data[cols * i + 4]);
                 strcpy (ptr->state_list[i].trans_from,  data[cols * i + 5]);
                 strcpy (ptr->state_list[i].trans_to,    data[cols * i + 6]);
                 strcpy (ptr->state_list[i].seq_no,      data[cols * i + 7]);
                 strcpy (ptr->state_list[i].status, ""); 
                 ptr->state_list[i].row = i; 
              }
          }

         ptr->num_states = rows;
      }
      
     status = NFI_S_SUCCESS;
     _NFIdebug ((fname, " returning <0x%.8x>\n", status));
     return (status);
  }



long _WFFinsert_class (form, g_label, row, class_name)
     Form  form;
     int   g_label; 
     int   row;
     char  *class_name;
  {
     long  status;

     static char *fname = "_WFFinsert_class";

     _NFIdebug ((fname, " row         = <%d>\n", row));
     _NFIdebug ((fname, " class name  = <%s>\n", class_name));
    
     /* call forms function to put the class in the list. */ 

/* IGI Intel Solaris Port - CN 31/5/95 */
#if defined(OS_SCO_UNIX) || defined(OS_INTELSOL)
	/* To set font for SCO - CRN  25 Feb  94	*/
	FIg_set_font(form, g_label, "7x13bold", 15);
#endif
     status = (long) FIfld_set_text (form, g_label, row, 0, class_name, FALSE);
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



long _WFFput_classes_in_list (form, g_label, ptr)
     Form         form;
     int          g_label; 
     WFFadd_ptr   ptr; 
  {
     long  status;
     int   i, k;

     static char *fname = "_WFFput_classes_in_list";

     _NFIdebug ((fname, " num_classes = <%d>\n",  ptr->num_classes));

/*
     for (i = 0; i < ptr->num_classes; ++i)
      {
        _NFIdebug ((fname, " ptr->class_list[%d].class_name = <%s>\n", i,
                    ptr->class_list[i].class_name));
      }
*/

     k = 0;
     for (i = 0; i < ptr->num_classes; ++i)
      {
         if (strcmp (ptr->class_list[i].status, WFF_DROP) != 0)
          {
             status = _WFFinsert_class (form, g_label, k,
                                        ptr->class_list[i].class_name);
             if (status != NFI_S_SUCCESS)
              {
                 _NFIdebug ((fname, " WFFinsert_class = <0x%.8x>\n",
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


long _WFFinsert_state (form, g_label, row, state_st)
     Form    form;
     int     g_label; 
     int     row;
     struct  WFFstate_st state_st;
  {
     long  status;

     static char *fname = "_WFFinsert_state";
    
     /* call forms function to put the class in the list. */ 

/* IGI Intel Solaris Port - CN 31/5/95 */
#if defined(OS_SCO_UNIX) || defined(OS_INTELSOL)
	/* To set font for SCO - CRN  25 Feb  94	*/
	FIg_set_font(form, g_label, "7x13bold", 15);
#endif
     status = (long) FIfld_set_text (form, g_label, row, 0,
                                     state_st.state_name, FALSE);
     if (status != FI_SUCCESS)
      {
          _NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
          ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_text", status);
          _NFIdebug ((fname, " returning FAILURE\n"));
          return (NFI_E_FORM);
      }

/* IGI Intel Solaris Port - CN 31/5/95 */
#if defined(OS_SCO_UNIX) || defined(OS_INTELSOL)
	/* To set font for SCO - CRN  25 Feb  94	*/
	FIg_set_font(form, g_label, "7x13bold", 15);
#endif
     status = (long) FIfld_set_text (form, g_label, row, 1,
                                     state_st.state_desc, FALSE);
     if (status != FI_SUCCESS)
      {
          _NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
          ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_text", status);
          _NFIdebug ((fname, " returning FAILURE\n"));
          return (NFI_E_FORM);
      }

/* IGI Intel Solaris Port - CN 31/5/95 */
#if defined(OS_SCO_UNIX) || defined(OS_INTELSOL)
	/* To set font for SCO - CRN  25 Feb  94	*/
	FIg_set_font(form, g_label, "7x13bold", 15);
#endif
     status = (long) FIfld_set_text (form, g_label, row, 2,
                                     state_st.no_signoffs, FALSE);
     if (status != FI_SUCCESS)
      {
          _NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
          ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_text", status);
          _NFIdebug ((fname, " returning FAILURE\n"));
          return (NFI_E_FORM);
      }

/* IGI Intel Solaris Port - CN 31/5/95 */
#if defined(OS_SCO_UNIX) || defined(OS_INTELSOL)
	/* To set font for SCO - CRN  25 Feb  94	*/
	FIg_set_font(form, g_label, "7x13bold", 15);
#endif
     status = (long) FIfld_set_text (form, g_label, row, 3,
                                     state_st.majority, FALSE);
     if (status != FI_SUCCESS)
      {
          _NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
          ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_text", status);
          _NFIdebug ((fname, " returning FAILURE\n"));
          return (NFI_E_FORM);
      }

/* IGI Intel Solaris Port - CN 31/5/95 */
#if defined(OS_SCO_UNIX) || defined(OS_INTELSOL)
	/* To set font for SCO - CRN  25 Feb  94	*/
	FIg_set_font(form, g_label, "7x13bold", 15);
#endif
     status = (long) FIfld_set_text (form, g_label, row, 4,
                                     state_st.trans_from, FALSE);
     if (status != FI_SUCCESS)
      {
          _NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
          ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_text", status);
          _NFIdebug ((fname, " returning FAILURE\n"));
          return (NFI_E_FORM);
      }

/* IGI Intel Solaris Port - CN 31/5/95 */
#if defined(OS_SCO_UNIX) || defined(OS_INTELSOL)
	/* To set font for SCO - CRN  25 Feb  94	*/
	FIg_set_font(form, g_label, "7x13bold", 15);
#endif
     status = (long) FIfld_set_text (form, g_label, row, 5,
                                     state_st.trans_to, FALSE);
     if (status != FI_SUCCESS)
      {
          _NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
          ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_text", status);
          _NFIdebug ((fname, " returning FAILURE\n"));
          return (NFI_E_FORM);
      }

/* IGI Intel Solaris Port - CN 31/5/95 */
#if defined (OS_SCO_UNIX) || defined(OS_INTELSOL)
	/* To set font for SCO - CRN  25 Feb  94	*/
	FIg_set_font(form, g_label, "7x13bold", 15);
#endif
     status = (long) FIfld_set_text (form, g_label, row, 6,
                                     state_st.seq_no, FALSE);
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


long _WFFput_states_in_list (form, g_label, num_states, state_list)
     Form                form;
     int                 g_label; 
     int                 num_states;
     struct WFFstate_st  state_list[];
  {
     long  status;
     int   i, k;

     static char *fname = "_WFFput_states_in_list";

     _NFIdebug ((fname, " num_states = <%d>\n", num_states));

     k = 0;
     for (i = 0; i < num_states; ++i)
      {
         if (strcmp (state_list[i].status, WFF_DROP) != 0)
          {
             status = _WFFinsert_state (form, g_label, k, state_list[i]);
             if (status != NFI_S_SUCCESS)
              {
                 _NFIdebug ((fname, " WFFinsert_state = <0x%.8x>\n", status));
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


long _WFFadd_class (form, g_label, ptr)
     Form        form;
     int         g_label; 
     WFFadd_ptr  ptr;
  {
     long   status;
     int    rows, length = 20, i, j;
     int    num_rows;
     char   class_name[24];

     static char *fname = "_WFFadd_class";

     strcpy (class_name, "");

     status = (long) FIfld_get_num_rows (form, CLASS_LIST_SCF, &num_rows); 
     if (status != FI_SUCCESS)
      {
         _NFIdebug ((fname, "FIfld_get_num_rows = <%d>\n", status));
         ERRload_struct (NFI, NFI_E_FORM, "%s%d",
                         "FIfld_get_num_rows", status);
         _NFIdebug ((fname, " returning FAILURE\n"));
         return (NFI_E_FORM);
      } 
     
     /* Unselect all the rows in the SCF */

     for (i = 0; i < num_rows; ++i)
      {
        status = (long) FIfld_set_select (form, CLASS_LIST_SCF, i, 0, FALSE); 
        if (status != FI_SUCCESS)
         {
            _NFIdebug ((fname, "FIfld_set_select = <%d>\n", status));
            ERRload_struct (NFI, NFI_E_FORM, "%s%d",  
                            "FIfld_set_select", status);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_FORM);
         } 
      }

     /* get the class_name from the CLASS_NAME_FIELD */

     status = _WFFget_data_from_field (form, g_label, 0, 0, class_name, length);
     if (status != NFI_S_SUCCESS)
      {
         _NFIdebug ((fname, " WFFget_data_from_field = <0x%.8x>\n", status));
         _NFIdebug ((fname, " returning FAILURE\n"));
         return (status);
      }

     /* If the class_name is null, send a warning to user */ 
     if (strcmp (class_name, "") == 0)
      {
        /* Put up a message warning user that class null */

        _WFFmessage (NFI_W_NULL_CLASS_NAME, NULL);
        _NFIdebug ((fname, " returning SUCCESS\n"));
        return (NFI_S_SUCCESS);
      } 
   
     /* check to see if the row is a duplicate : if it is exit, send warning */

     if (ptr->class_list != NULL)
      {
        for (i = 0; i < ptr->num_classes; ++i)
         {
             if ((strcmp (ptr->class_list[i].class_name, class_name) == 0) &&
                 (strcmp (ptr->class_list[i].status, WFF_DROP) != 0)) 
              {
                  /* Clear out the class_name field */
   
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
   
                  /* Put up a message warning user that class is a duplicate */
   
                  _WFFmessage (NFI_E_DUPLICATE_CLASS, "%s", class_name);
   
                  return (NFI_S_SUCCESS);
              }  
         }
      }

     rows = ptr->num_classes + 1;

     if (ptr->class_list)  
      {
          /* reallocate memory for the list */
 
          ptr->class_list = (struct WFFclass_st *) realloc (ptr->class_list,
                             rows * sizeof (struct WFFclass_st));
          if (!ptr->class_list)
           {
              _NFIdebug ((fname, "Malloc : bytes = <%d>\n",
                          rows * sizeof (struct WFFclass_st)));
              ERRload_struct (NFI, NFI_E_MALLOC, "%d",  
                              rows * sizeof (struct WFFclass_st));
              _NFIdebug ((fname, " returning FAILURE\n"));
              return (NFI_E_MALLOC);
           }
      }
     else
      {
          /* malloc memory for the list */

          ptr->class_list = (struct WFFclass_st *) malloc (rows * 
                             sizeof (struct WFFclass_st));
          if (!ptr->class_list)
           {
              _NFIdebug ((fname, "Malloc : bytes = <%d>\n",
                          rows * sizeof (struct WFFclass_st)));
              ERRload_struct (NFI, NFI_E_MALLOC, "%d",  
                              rows * sizeof (struct WFFclass_st));
              _NFIdebug ((fname, " returning FAILURE\n"));
              return (NFI_E_MALLOC);
           }
      }

     strcpy (ptr->class_list[rows -1].class_name, class_name); 
     strcpy (ptr->class_list[rows -1].status, WFF_ADD); 
     ptr->class_list[rows -1].class_no = 0; 
     ptr->num_classes = rows;

     /* get the num_rows in the CLASS_LIST_SCF (I/FORMS returns invalid info) */

     j = 0;
     for (i = 0; i < ptr->num_classes; ++i)
      {
         if (strcmp (ptr->class_list[i].status, WFF_DROP) != 0)
           ++j;
      }
     
     ptr->class_list[rows -1].row = j - 1; 

     /* add the class to the CLASS_LIST_SCF */

/* IGI Intel Solaris Port - CN 31/5/95 */
#if defined(OS_SCO_UNIX) || defined(OS_INTELSOL)
	/* To set font for SCO - CRN 25 Feb 94	*/
	FIg_set_font(form, CLASS_LIST_SCF, "7x13bold", 15);
#endif
     status = (long) FIfld_set_text (form, CLASS_LIST_SCF, j - 1, 0, 
                                     class_name, FALSE);
     if (status != FI_SUCCESS)
      {
         _NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
         ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_text",
                         status);
         _NFIdebug ((fname, " returning FAILURE\n"));
         return (NFI_E_FORM);
      } 

     /* set the row to be in the viewing area */

     _WFFset_active_row (form, CLASS_LIST_SCF, j - 1, 1);

     /* Clear out the class_name field */
   
     FIfld_set_text (form, g_label, 0, 0, "", FALSE);
   
     status = NFI_S_SUCCESS;
     _NFIdebug ((fname, " returning <0x%.8x>\n", status));
     return (status);
  }


long _WFFdelete_classes (form, g_label, ptr)
     Form        form;
     int         g_label; 
     WFFadd_ptr  ptr;
  {
     long   status;
     int    i, j = 0, y = 0, k, x, rows, l_rows, sel_flag;
     int    length = 20;
     int    *delete_list = NULL;
     short  c_warning = FALSE, d_class = TRUE; 
     char   class_name[24];
     short  delete = FALSE; 

     static char *fname = "_WFFdelete_classes";

     /* get the num_rows in the CLASS_LIST_SCF */

     status = (long) FIfld_get_num_rows (form, g_label, &rows); 
     if (status != FI_SUCCESS)
      {
         _NFIdebug ((fname, "FIfld_get_num_rows = <%d>\n", status));
         ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_get_num_rows", status);
         _NFIdebug ((fname, " returning FAILURE\n"));
         return (NFI_E_FORM);
      } 

     if (ptr->num_classes == 0)
      {
         FIfld_set_num_rows (form, g_label, 0); 
         _WFFmessage (NFI_W_NO_CLASSES_SELECTED, NULL);
         _NFIdebug ((fname, "No rows exist in the CLASS_LIST_SCF\n"));
         return (NFI_S_SUCCESS);
      } 

     if (rows == 0)
      {
         _WFFmessage (NFI_W_NO_CLASSES_SELECTED, NULL);
         _NFIdebug ((fname, "No rows exist in the CLASS_LIST_SCF\n"));
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

     if (ptr->class_list != NULL)
      {
        for (i = 0; i < rows; ++i)
         {
             /* See if this class is selected for deletion */

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

         if (delete) 
          {
             /*  Delete the rows from the ptr->class_list */ 

             for (i = 0; i < rows; ++i)
              {
                 if (delete_list[i])
                  { 
                    d_class = TRUE;
                    strcpy (class_name, "");

                    /* get the class_name from the CLASS_LIST_SCF */
                    
                    status = _WFFget_data_from_field (form, g_label, i, 0,
                                                      class_name, length);
                    if (status != NFI_S_SUCCESS)
                     {
                        free ((int *) delete_list);
                        _NFIdebug ((fname,
                             " WFFget_data_from_field = <0x%.8x>\n", status));
                        _NFIdebug ((fname, " returning FAILURE\n"));
                        return (status);
                     }

                    /* check to see if the class has access; if it does set
                       c_warning to TRUE and do not delete the class */ 

                    for (k = 0; k < ptr->num_access; ++k)
                     {
                        if ((strcmp (ptr->access_list[k].class_name,
                                   class_name) == 0) && 
                           (strcmp (ptr->access_list[k].status, WFF_DROP) != 0))
                         {
                             c_warning = TRUE;
                             d_class = FALSE;
                             delete_list[i] = FALSE;
                             break;
                         }
                     }

                    if (!d_class)
                      continue;

                    l_rows = ptr->num_classes;

                    x = 0;
                    for (k = 0; k < l_rows; ++k)
                     {
                        if ((strcmp (ptr->class_list[k].class_name,
                                    class_name) != 0) &&
                            (strcmp (ptr->class_list[k].status, WFF_DROP) != 0))
                         {
                            ptr->class_list[k].row = x;
                            ++x;
                         }
                      }

                    /* find the class in the class_list */
                    
                    for (k = 0; k < l_rows; ++k)
                     {
                        if ((strcmp (ptr->class_list[k].class_name,  
                                     class_name) == 0) && 
                           (strcmp (ptr->class_list[k].status, WFF_DROP) != 0))
                         {
                            /* if the item does not exist in db drop it */ 
                            /* else mark it for delete                  */
   
                            if (!strcmp (ptr->class_list[k].status, WFF_ADD))
                             {
                                /* move/shift all values up by 1 */
                 
                                for (y = k; y < l_rows - 1; ++y)
                                    ptr->class_list[y] = ptr->class_list[y + 1];
                        
                                /* delete the class from the class_list */
       
                                if (l_rows == 1)
                                 {
                                   free((struct WFFclass_st *) ptr->class_list);
                                   ptr->class_list = NULL;
                                 } 
                                else
                                 {
                                    ptr->class_list = (struct WFFclass_st *) \
                                      realloc (ptr->class_list, (l_rows -1)  *
                                          sizeof (struct WFFclass_st));
                                    if (!ptr->class_list)
                                     {
                                        free ((int *) delete_list);
                                        _NFIdebug ((fname,
                                                    "Realloc : bytes = <%d>\n",
                                         l_rows * sizeof (struct WFFclass_st)));
                                        ERRload_struct (NFI, NFI_E_MALLOC, "%d",
                                         l_rows * sizeof (struct WFFclass_st));
                                        _NFIdebug ((fname,
                                                    " returning FAILURE\n"));
                                        return (NFI_E_MALLOC);
                                     }
                                 } 
                                --ptr->num_classes;
                             }
                            else
                             {
                                strcpy (ptr->class_list[k].status, WFF_DROP); 
                                ptr->class_list[k].row = -1; 
                             } 
                            break;
                         }
                     }
                  }
              }

             /* delete the classes from the CLASS_LIST_SCF */

             j = 0;

             for (i = 0; i < rows; ++i)
              {
                 if (delete_list[i])
                  { 
                     if (rows == 1)
                        status = (long) FIfld_set_num_rows (form, g_label, 0); 
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

             /* Clear out the class_name field */
   
             FIfld_set_text (form, CLASS_NAME_FIELD, 0, 0, "", FALSE);
         }
      }
     free ((int *) delete_list);

     /* Unselect all the selected row(s) in the scf */

     if ((rows - j) != 0)
      {
         for (i = 0; i < (rows - j); ++i)
          {
             status = (long) FIfld_set_select (form, CLASS_LIST_SCF, i, 0,
                                               FALSE);
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
     else
        FIfld_set_num_rows (form, CLASS_LIST_SCF, 0);

     if (!delete)
       _WFFmessage (NFI_W_NO_CLASSES_SELECTED, NULL);

     if (c_warning)
       _WFFmessage (NFI_W_CLASS_HAS_ACCESS, NULL);

     status = NFI_S_SUCCESS;
     _NFIdebug ((fname, " returning <0x%.8x>\n", status));
     return (status);
  }


long _WFFchange_class (form, g_label, ptr)
     Form        form;
     int         g_label; 
     WFFadd_ptr  ptr;
  {
     long   status;
     int    row = 0;
     int    i;
     int    num_rows;
     int    sel_flag;
     int    r_pos;
     int    length = 20;
     long   class_no = 0;
     char   old_class_name[24];
     char   new_class_name[24];

     static char *fname = "_WFFchange_class";

     strcpy (old_class_name, "");
     strcpy (new_class_name, "");

     status = (long) FIfld_get_num_rows (form, CLASS_LIST_SCF, &num_rows); 
     if (status != FI_SUCCESS)
      {
         _NFIdebug ((fname, "FIfld_get_num_rows = <%d>\n", status));
         ERRload_struct (NFI, NFI_E_FORM, "%s%d",
                         "FIfld_get_num_rows", status);
         return (NFI_E_FORM);
      } 
     
     /* Find selected row in the SCF */

     for (i = 0; i < num_rows; ++i)
      {
         /* See if this class is selected for change */

         status = (long) FIfld_get_select (form, CLASS_LIST_SCF,i,0,&sel_flag);
         if (status != FI_SUCCESS)
         {
             _NFIdebug ((fname, "FIfld_get_select = <%d>\n", status));
             ERRload_struct (NFI, NFI_E_FORM, "%s%d",
                                 "FIfld_get_select", status);
             return (NFI_E_FORM);
         } 
   
         if (sel_flag)
         {
	     /*  Save class name that is being changed  */	    

             row = i;  /* selected row */

             /* Get the text string */

             FIfld_get_text (form, CLASS_LIST_SCF, i, 0, length + 1, 
			     old_class_name, &sel_flag, &r_pos);
	     _NFIdebug(( fname, "Old class name <%s>\n", old_class_name ));
             break;
          }
      }

     if( !sel_flag )
     {
	/*  No old class was selected */

        _WFFmessage (NFI_W_NO_CLASS_SELECTED_CHANGE, NULL);
        _NFIdebug ((fname, "No old class was selected\n"));
	return( NFI_S_SUCCESS );
     }

     /* get the class_name from the CLASS_NAME_FIELD */

     status = _WFFget_data_from_field (form, g_label, 0, 0, new_class_name,
				       length);
     if (status != NFI_S_SUCCESS)
      {
         _NFIdebug ((fname, " WFFget_data_from_field = <0x%.8x>\n", status));
         return (status);
      }

     /* If the class_name is null, send a warning to user */ 
     if (strcmp (new_class_name, "") == 0)
     {
        /* Put up a message warning user that class null */

        _WFFmessage (NFI_W_NULL_CLASS_NAME, NULL);
        _NFIdebug ((fname, " returning SUCCESS\n"));
        return (NFI_S_SUCCESS);
      } 
   
     /* check to see if the row is a duplicate : if it is exit, send warning */

     if (ptr->class_list != NULL)
      {
        for (i = 0; i < ptr->num_classes; ++i)
         {
             if (strcmp (ptr->class_list[i].class_name, new_class_name) == 0)
              {
                  /* Clear out the class_name field */
   
                  status = (long) FIfld_set_text (form, g_label, 0, 0, 
                                                  "", FALSE);
                  if (status != FI_SUCCESS)
                   {
                      _NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
                      ERRload_struct (NFI, NFI_E_FORM, "%s%d",
                                      "FIfld_set_text", status);
                      return (NFI_E_FORM);
                   } 
   
                  /* Put up a message warning user that class is a duplicate */
   
                  _WFFmessage (NFI_E_DUPLICATE_CLASS, "%s", new_class_name);
   
                  return (NFI_S_SUCCESS);
              }  
 
             else if(strcmp(ptr->class_list[i].class_name,old_class_name) == 0)
              {
                  /* Save the old class number */
   
   		  class_no = ptr->class_list[i].class_no;
              }  
          }
      }

    /*  Now change the class name in the database */
     
    status = _WFGmodify_class (ptr->workflow_no, class_no, new_class_name);
    if( status != NFM_S_SUCCESS )
    {
	_NFIdebug(( fname, "_WFGmodify_class <0x%.8x>\n", status ));
	_WFFmessage( NFI_E_CHANGE_CLASS, "%s", old_class_name );
	return( NFI_S_SUCCESS );
    }

    /*  Now change the class name in the buffer */

    if (ptr->class_list != NULL)
    {
        for (i = 0; i < ptr->num_classes; ++i)
        {
             if (strcmp (ptr->class_list[i].class_name, old_class_name) == 0)
	     {
		strcpy( ptr->class_list[i].class_name, new_class_name );
		class_no = ptr->class_list[i].class_no;
		break;
	     }
        }
    }

    if (ptr->access_list != NULL)
    {
        for (i = 0; i < ptr->num_access; ++i)
        {
             if(strcmp (ptr->access_list[i].class_name, old_class_name) == 0)
		strcpy( ptr->access_list[i].class_name, new_class_name );
        }
    }

    /*  Now put the new class name in the SCF */

/* IGI Intel Solaris Port - CN 31/5/95 */
#if defined(OS_SCO_UNIX) || defined(OS_INTELSOL)
	/* To set font for SCO - CRN 25 Feb 94	*/
	FIg_set_font(form, CLASS_LIST_SCF, "7x13bold", 15);
#endif
    FIfld_set_text (form, CLASS_LIST_SCF, row, 0, new_class_name, TRUE );

    return( NFI_S_SUCCESS );
}


long _WFFadd_states (form, g_label, ptr)
     Form        form;
     int         g_label;   /* STATE_NAME_FIELD */
     WFFadd_ptr  ptr;
  {
     long   status;
     long   value1 = 0;
     long   value2 = 0;
     int    num_rows;
     int    rows;
     int    length = 40;
     int    i;
     int    j;
     int    k;
     int    g_state;
     char   state_name[41];
     char   state_desc[41];
     char   seq_no[16];
     char   min_signoffs[16];
     char   mandatory[3];
     char   trans_from[2];
     char   trans_to[2];

     static char *fname = "_WFFadd_states";

    _NFIdebug ((fname, " g_label = <%d>\n", g_label));

    /* Unselect any selected value in the state_list MCF */

    status = (long) FIfld_get_num_rows (form, STATE_LIST_MCF, &num_rows); 
    if (status != FI_SUCCESS)
     {
         _NFIdebug ((fname, "FIfld_get_num_rows = <%d>\n", status));
         ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_get_num_rows", status);
         _NFIdebug ((fname, " returning FAILURE\n"));
         return (NFI_E_FORM);

     }

     for (i = 0; i < num_rows; ++i)
      {
        status = (long) FImcf_set_select (form, STATE_LIST_MCF, i, FALSE); 
        if (status != FI_SUCCESS)
         {
            _NFIdebug ((fname, "FImcf_set_select = <%d>\n", status));
            ERRload_struct (NFI, NFI_E_FORM, "%s%d",  
                            "FImcf_set_select", status);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_FORM);
         } 
      }

     strcpy (state_name, "");
     strcpy (state_desc, "");
     strcpy (min_signoffs, "0");
     strcpy (seq_no, "");
     strcpy (mandatory, "N");
     strcpy (trans_from, "N");
     strcpy (trans_to, "N");

     /* get the state_name from the STATE_NAME_FIELD */

     status = _WFFget_data_from_field (form, g_label, 0, 0, state_name, length);
     if (status != NFI_S_SUCCESS)
      {
         _NFIdebug ((fname, " WFFget_data_from_field = <0x%.8x>\n", status));
         _NFIdebug ((fname, " returning FAILURE\n"));
         return (status);
      }

     /* If the state_name is null, send a warning to user */ 
     if (strcmp (state_name, "") == 0)
      {
        /* Put up a message warning user that state null */

        _WFFmessage (NFI_W_NULL_STATE_NAME, NULL);
        _NFIdebug ((fname, " returning SUCCESS\n"));
        return (NFI_S_SUCCESS);
      } 
   
     /* check to see if the row is a duplicate : if so exit, send warning */

     if (ptr->state_list != NULL)
      {
        for (i = 0; i < ptr->num_states; ++i)
         {
             if ((strcmp (ptr->state_list[i].state_name, state_name) == 0) &&
                 (strcmp (ptr->state_list[i].status, WFF_DROP) != 0)) 
              {
                  /* Clear out the state_name field */
   
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
   
                  /* Put up a message warning user that state is a duplicate */
   
                  _WFFmessage (NFI_E_DUPLICATE_STATE, "%s", state_name);
   
                  return (NFI_S_SUCCESS);
              }  
         }
      }

     /* get the state_desc from the STATE_DESC_FIELD */

     status = _WFFget_data_from_field (form, STATE_DESC_FIELD, 0, 0,
                                       state_desc, length);
     if (status != NFI_S_SUCCESS)
      {
         _NFIdebug ((fname, " WFFget_data_from_field = <0x%.8x>\n", status));
         _NFIdebug ((fname, " returning FAILURE\n"));
         return (status);
      }

     /* get the seq_no from the STATE_SEQNO_FIELD */

     length = 15;
     status = _WFFget_data_from_field (form, STATE_SEQNO_FIELD, 0, 0,
                                       seq_no, length);
     if (status != NFI_S_SUCCESS)
      {
         _NFIdebug ((fname, " WFFget_data_from_field = <0x%.8x>\n",
                     status));
         _NFIdebug ((fname, " returning FAILURE\n"));
         return (status);
      }

     /* get the numeric equivalent of the value */

     status = _WFFcvt_to_long (seq_no, &value1); 
     if (status != NFI_S_SUCCESS)
      {
         _NFIdebug ((fname, " WFFcvt_to_long = <0x%.8x>\n",
                     status));
          if (status == NFI_W_NULL_NUMERIC_INPUT)
          {
             /* get the next available sequence number */
                 
             _WFFget_next_seq_no (ptr->num_states, ptr->state_list, seq_no);
             _NFIdebug ((fname, " NUll seq_no : defaulting value to <%s>\n",
                         seq_no));
          }
          else if (status == NFI_W_INVALID_NUMERIC_INPUT)
           {
              FIfld_set_text (form, STATE_SEQNO_FIELD, 0, 0, "0", FALSE);
              _WFFmessage (NFI_W_NULL_NUMERIC_FIELD, "%s", "Sequence No.");
              _NFIdebug ((fname, " Non-numeric input in seq_no field\n"));
              return (NFI_S_SUCCESS);
           }
          else if (status == NFI_W_NEGATIVE_VALUE)
           {
              FIfld_set_text (form, STATE_SEQNO_FIELD, 0, 0, "0", FALSE);
              _WFFmessage (NFI_W_NEGATIVE_VALUE, "%s", "Sequence No. Field");
              _NFIdebug ((fname, " Negative numeric input in seq_no field\n"));
              return (NFI_S_SUCCESS);

           }
          else
           {
              ERRload_struct (NFI, status, NULL);
              _NFIdebug ((fname, " returning FAILURE\n"));
              return (status);
           }
       }

      for (i = 0; i < ptr->num_states; ++i)
       {
           if (strcmp (ptr->state_list[i].status, WFF_DROP) == 0)
              continue;

	   /*  'value1' has seq_no in it */
           status = _WFFcvt_to_long (ptr->state_list[i].seq_no, &value2); 
           if (value2 >= value1)
            {
            /*  Adjust sequence numbers if this is an insert in between other
             *  states.
             */
	     ++value2;
	     sprintf( ptr->state_list[i].seq_no, "%ld", value2 );
	     strcpy( ptr->state_list[i].status, WFF_MODIFY );
	     _NFIdebug(( fname, "Incrementing seq_no for state <%s> to <%d>\n",
			 ptr->state_list[i].state_name, value2 ));  
            }
       } 

      /* get the min_signoffs from the MIN_NO_SIGNOFFS_FIELD */

      status = _WFFget_data_from_field (form, MIN_NO_SIGNOFFS_FIELD, 0, 0,
                                        min_signoffs, 15);
      if (status != NFI_S_SUCCESS)
       {
          _NFIdebug ((fname, " WFFget_data_from_field = <0x%.8x>\n", status));
          _NFIdebug ((fname, " returning FAILURE\n"));
          return (status);
       }

      /* get the numeric equivalent of the value */

/* IGI Intel Solaris Port - CN 31/5/95 */
#if defined(OS_SCO_UNIX) || defined(OS_INTELSOL)
	/* To set font for SCO - CRN 25 Feb 94	*/
	FIg_set_font(form, MIN_NO_SIGNOFFS_FIELD, "7x13bold", 15);
#endif
      status = _WFFcvt_to_long (min_signoffs, &value1); 
      if (status != NFI_S_SUCCESS)
       {
          _NFIdebug ((fname, " WFFcvt_to_long = <0x%.8x>\n", status));
          if (status == NFI_W_NULL_NUMERIC_INPUT)
           {
              strcpy (min_signoffs, "0"); 
              _NFIdebug ((fname, " NUll signoff : defaulting value to 0\n"));
           }
          else if (status == NFI_W_INVALID_NUMERIC_INPUT)
           {
              FIfld_set_text (form, MIN_NO_SIGNOFFS_FIELD, 0, 0, "0", FALSE);
              _WFFmessage (NFI_W_NULL_NUMERIC_FIELD, "%s",  
                           "Minimum No. Signoffs");
              _NFIdebug ((fname, " Non-numeric input in signoffs field\n"));

              return (NFI_S_SUCCESS);
           }
          else if (status == NFI_W_NEGATIVE_VALUE)
           {
              FIfld_set_text (form, MIN_NO_SIGNOFFS_FIELD, 0, 0, "0", FALSE);
              _WFFmessage (NFI_W_NEGATIVE_VALUE, "%s", "Minimum No. Signoffs");
              _NFIdebug ((fname, "Negative numeric input in signoffs field\n"));
              return (NFI_S_SUCCESS);
           }
          else
           {
             ERRload_struct (NFI, status, NULL);
             _NFIdebug ((fname, " returning FAILURE\n"));
             return (status);
           }
       }

      if (strcmp (min_signoffs, "0") != 0)       
       {
          /* get the gadget state for the mandatory/majority toggle */

          status = (long) FIg_get_state (form, MANDATORY_TOGGLE, &g_state);
          if (status != FI_SUCCESS)
           {
              _NFIdebug ((fname, "FIg_get_state = <%d>\n", status));
              ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_get_state",
                              status);
              _NFIdebug ((fname, " returning FAILURE\n"));
           }
 
          if (g_state)
             strcpy (mandatory, "MJ");   /* Majority */
          else
             strcpy (mandatory, "MN");   /* Mandatory */
       }

      /* get the gadget state for the transition from_state toggle */
 
      status = (long) FIg_get_state (form, FROM_STATE_TOGGLE, &g_state);
      if (status != FI_SUCCESS)
       {
          _NFIdebug ((fname, "FIg_get_state = <%d>\n", status));
          ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_get_state", status);
          _NFIdebug ((fname, " returning FAILURE\n"));
       }

      if (g_state)
         strcpy (trans_from, "Y"); 

      /* get the gadget state for the transition to_state toggle */

      status = (long) FIg_get_state (form, TO_STATE_TOGGLE, &g_state);
      if (status != FI_SUCCESS)
       {
          _NFIdebug ((fname, "FIg_get_state = <%d>\n", status));
          ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_get_state", status);
          _NFIdebug ((fname, " returning FAILURE\n"));
       }

      if (g_state)
         strcpy (trans_to, "Y"); 

      rows = ptr->num_states + 1;

      if (ptr->state_list)  
       {
           /* reallocate memory for the list */
   
           ptr->state_list = (struct WFFstate_st *) realloc (ptr->state_list,
                              rows * sizeof (struct WFFstate_st));
           if (!ptr->state_list)
            {
               _NFIdebug ((fname, "Malloc : bytes = <%d>\n",
                           rows * sizeof (struct WFFstate_st)));
               ERRload_struct (NFI, NFI_E_MALLOC, "%d",  
                               rows * sizeof (struct WFFstate_st));
               _NFIdebug ((fname, " returning FAILURE\n"));
               return (NFI_E_MALLOC);
            }
       }
      else
       {
           /* malloc memory for the list */
 
           ptr->state_list = (struct WFFstate_st *) malloc (rows * 
                              sizeof (struct WFFstate_st));
           if (!ptr->state_list)
            {
               _NFIdebug ((fname, "Malloc : bytes = <%d>\n",
                           rows * sizeof (struct WFFstate_st)));
               ERRload_struct (NFI, NFI_E_MALLOC, "%d",  
                               rows * sizeof (struct WFFstate_st));
               _NFIdebug ((fname, " returning FAILURE\n"));
               return (NFI_E_MALLOC);
            }
       }
    
      ptr->state_list[rows -1].state_no = 0;
      strcpy (ptr->state_list[rows -1].state_name,  state_name); 
      strcpy (ptr->state_list[rows -1].state_desc,  state_desc); 
      strcpy (ptr->state_list[rows -1].no_signoffs, min_signoffs); 
      strcpy (ptr->state_list[rows -1].majority, mandatory); 
      strcpy (ptr->state_list[rows -1].trans_from, trans_from); 
      strcpy (ptr->state_list[rows -1].trans_to, trans_to); 
      strcpy (ptr->state_list[rows -1].seq_no, seq_no); 
      strcpy (ptr->state_list[rows -1].status, WFF_ADD); 
      ptr->num_states = rows;
    
     /* get the num_rows in the STATE_LIST_MCF (I/FORMS returns invalid info */

     j = 0;
     for (i = 0; i < ptr->num_states; ++i)
      {
         if (strcmp (ptr->state_list[i].status, WFF_DROP) != 0)
           ++j;
      }

     ptr->state_list[rows -1].row = j - 1; 

     /* add the state to the STATE_LIST_MCF */

/* IGI Intel Solaris Port - CN 31/5/95 */
#if defined(OS_SCO_UNIX) || defined(OS_INTELSOL)
	/* To set font for SCO - CRN 25 Feb 94	*/
	FIg_set_font(form , STATE_LIST_MCF, "7x13bold", 15);
#endif
     status = (long) FIfld_set_text (form, STATE_LIST_MCF, j - 1, 0, 
                                     state_name, FALSE);
     if (status != FI_SUCCESS)
      {
         _NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
         ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_text",
                         status);
         _NFIdebug ((fname, " returning FAILURE\n"));
         return (NFI_E_FORM);
      } 

     status = (long) FIfld_set_text (form, STATE_LIST_MCF, j - 1, 1, 
                                     state_desc, FALSE);
     if (status != FI_SUCCESS)
      {
         _NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
         ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_text",
                         status);
         _NFIdebug ((fname, " returning FAILURE\n"));
         return (NFI_E_FORM);
      } 

     status = (long) FIfld_set_text (form, STATE_LIST_MCF, j - 1, 2, 
                                     min_signoffs, FALSE);
     if (status != FI_SUCCESS)
      {
         _NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
         ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_text",
                         status);
         _NFIdebug ((fname, " returning FAILURE\n"));
         return (NFI_E_FORM);
      } 

     status = (long) FIfld_set_text (form, STATE_LIST_MCF, j - 1, 3, 
                                     mandatory, FALSE);
     if (status != FI_SUCCESS)
      {
         _NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
         ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_text",
                         status);
         _NFIdebug ((fname, " returning FAILURE\n"));
         return (NFI_E_FORM);
      } 

     status = (long) FIfld_set_text (form, STATE_LIST_MCF, j - 1, 4, 
                                     trans_from, FALSE);
     if (status != FI_SUCCESS)
      {
         _NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
         ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_text",
                         status);
         _NFIdebug ((fname, " returning FAILURE\n"));
         return (NFI_E_FORM);
      } 

     status = (long) FIfld_set_text (form, STATE_LIST_MCF, j - 1, 5, 
                                     trans_to, FALSE);
     if (status != FI_SUCCESS)
      {
         _NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
         ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_text",
                         status);
         _NFIdebug ((fname, " returning FAILURE\n"));
         return (NFI_E_FORM);
      } 

     /*  Rewrite all of the sequence numbers in case the state was inserted
      *  between two existing states. 
      */

/* IGI Intel Solaris Port - CN 31/5/95 */
#if defined(OS_SCO_UNIX) || defined(OS_INTELSOL)
	/* To set font for SCO - CRN 25 Feb 94	*/
	FIg_set_font(form, STATE_LIST_MCF, "7x13bold", 15);
#endif
      for( i=0,k=0; i<j; ++i )
      {
         if (strcmp (ptr->state_list[i].status, WFF_DROP) != 0)
	 {
            status = (long) FIfld_set_text (form, STATE_LIST_MCF, k, 6,
                                     ptr->state_list[i].seq_no, FALSE);
            if (status != FI_SUCCESS)
            {
                _NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
            }
	    ++k;
	 }
      }

     /* set the row to be in the viewing area */

     _WFFset_active_row (form, STATE_LIST_MCF, j - 1, 1);

     /* Clear out the state fields and reset toggles */
   
     FIfld_set_text (form, g_label, 0, 0, "", FALSE);
     FIfld_set_text (form, STATE_DESC_FIELD, 0, 0, "", FALSE);
     FIfld_set_text (form, MIN_NO_SIGNOFFS_FIELD, 0, 0, "0", FALSE);
     _WFFget_next_seq_no (ptr->num_states, ptr->state_list, seq_no);
     FIfld_set_text (form, STATE_SEQNO_FIELD, 0, 0, seq_no, FALSE);

     FIg_set_state (form, MANDATORY_TOGGLE, 0);
     FIg_set_state (form, FROM_STATE_TOGGLE, 0);
     FIg_set_state (form, TO_STATE_TOGGLE, 0);
   
     status = NFI_S_SUCCESS;
     _NFIdebug ((fname, " returning <0x%.8x>\n", status));
     return (status);
  }


long _WFFdelete_states (form, g_label, ptr)
     Form        form;
     int         g_label; 
     WFFadd_ptr  ptr;
  {
     long   status;
     int    i, j = 0, y = 0, k, x, rows, l_rows, sel_flag;
     int    length = 40;
     int    *delete_list = NULL;
     char   state_name[41];
     char   seqno[16];
     short  delete = FALSE; 
     short  c_warning = FALSE, d_state = TRUE; 

     static char *fname = "_WFFdelete_states";

     _NFIdebug ((fname, "g_label = <%d>\n", g_label));

     /* get the num_rows in the STATE_LIST_MCF */

     status = (long) FIfld_get_num_rows (form, g_label, &rows); 
     if (status != FI_SUCCESS)
      {
         _NFIdebug ((fname, "FIfld_get_num_rows = <%d>\n", status));
         ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_get_num_rows", status);
         _NFIdebug ((fname, " returning FAILURE\n"));
         return (NFI_E_FORM);
      } 

     if (ptr->num_states == 0)
      {
         FIfld_set_num_rows (form, g_label, 0); 
         _WFFmessage (NFI_W_NO_STATES_SELECTED, NULL);
         _NFIdebug ((fname, "No rows exist in the STATE_LIST_MCF\n"));
         return (NFI_S_SUCCESS);
      } 

     if (rows == 0)
      {
         _WFFmessage (NFI_W_NO_STATES_SELECTED, NULL);
         _NFIdebug ((fname, "No rows exist in the STATE_LIST_MCF\n"));
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

/*
     for (i = 0;  i < rows; ++i)
        delete_list[i] = FALSE; 
*/

     if (ptr->state_list != NULL)
      {
        for (i = 0; i < rows; ++i)
         {
             /* See if this state is selected for deletion */

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
             /*  Delete the rows from the ptr->state_list */ 

             for (i = 0; i < rows; ++i)
              {
                 if (delete_list[i])
                  { 
                    d_state = TRUE;
                    strcpy (state_name, "");

                    /* get the state_name from the STATE_LIST_MCF */
                    
                    status = _WFFget_data_from_field (form, g_label, i, 0,
                                                      state_name, length);
                    if (status != NFI_S_SUCCESS)
                     {
                        free ((int *) delete_list);
                        _NFIdebug ((fname,
                             " WFFget_data_from_field = <0x%.8x>\n", status));
                        _NFIdebug ((fname, " returning FAILURE\n"));
                        return (status);
                     }

                    /* check to see if the state is being used in a transition 
                       if it is set c_warning to TRUE and do not delete the
                       state                                                */ 

                    for (k = 0; k < ptr->num_trans; ++k)
                     {
                        if (((strcmp (ptr->trans_list[k].from_state,
                                      state_name) == 0) ||
                             (strcmp (ptr->trans_list[k].to_state,
                                      state_name) == 0)) && 
                           (strcmp (ptr->trans_list[k].status, WFF_DROP) != 0))
                         {
                             c_warning = TRUE;
                             d_state = FALSE;
                             delete_list[i] = FALSE;
                             break;
                         }
                     }

                    if (!d_state)
                       continue;

                    /* find the state in the state_list */

                    _NFIdebug ((fname, "Preparing to delete state <%s>\n",
                                state_name)); 
                    
                    l_rows = ptr->num_states;

                    x = 0;
                    for (k = 0; k < l_rows; ++k)
                     {
                        if ((strcmp (ptr->state_list[k].state_name,
                                    state_name) != 0) &&
                            (strcmp (ptr->state_list[k].status, WFF_DROP) != 0))
                         {
                            ptr->state_list[k].row = x;
                            ++x;
                         }
                      }

                    for (k = 0; k < l_rows; ++k)
                     {
                        if ((strcmp (ptr->state_list[k].state_name,
                                    state_name) == 0) &&
                            (strcmp (ptr->state_list[k].status, WFF_DROP) != 0))
                         {
                            /* If state does not exist in database, drop it */
                            /* otherwise mark it for deletion               */
                           
                            if (strcmp(ptr->state_list[k].status, WFF_ADD) == 0)
                             {
                               /* move/shift all values up by 1 */
                    
                               for (y = k; y < l_rows - 1; ++y)
                                   ptr->state_list[y] = ptr->state_list[y + 1];
                       
                               /* delete the state from the state_list */
      
                               if (l_rows == 1)
                                {
                                   free((struct WFFstate_st *) ptr->state_list);
                                   ptr->state_list = NULL;
                                } 
                               else
                                {
                                   ptr->state_list = (struct WFFstate_st *) \
                                         realloc (ptr->state_list, (l_rows -1) *
                                         sizeof (struct WFFstate_st));
                                   if (!ptr->state_list)
                                    {
                                       free ((int *) delete_list);
                                       _NFIdebug ((fname,
                                                   "Realloc : bytes = <%d>\n",
                                         l_rows * sizeof (struct WFFstate_st)));
                                       ERRload_struct (NFI, NFI_E_MALLOC, "%d",
                                          l_rows * sizeof (struct WFFstate_st));
                                       _NFIdebug ((fname,
                                                   " returning FAILURE\n"));
                                       return (NFI_E_MALLOC);
                                    }
                                } 
                               --ptr->num_states;
                             } 
                            else
                             {
                                strcpy (ptr->state_list[k].status, WFF_DROP);
                                ptr->state_list[k].row = -1;
                             }
                            break;
                         }
                     }
                  }
              }

             /* delete the states from the STATE_LIST_MCF */

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

             /* clear out the state fields and reset the toggles */
   
             FIfld_set_text (form, STATE_NAME_FIELD, 0, 0, "", FALSE);
             FIfld_set_text (form, STATE_DESC_FIELD, 0, 0, "", FALSE);
             FIfld_set_text (form, MIN_NO_SIGNOFFS_FIELD, 0, 0, "0", FALSE);
             _WFFget_next_seq_no (ptr->num_states, ptr->state_list, seqno);
/* IGI Intel Solaris Port - CN 31/5/95 */
#if defined(OS_SCO_UNIX) || defined(OS_INTELSOL)
	/* TO SET font for SCO - CRN 25 Feb 94	*/
	FIg_set_font(form, STATE_SEQNO_FIELD, "7x13bold", 15);
#endif
             FIfld_set_text (form, STATE_SEQNO_FIELD, 0, 0, seqno, FALSE);
        
             FIg_set_state (form, MANDATORY_TOGGLE, 0);
             FIg_set_state (form, FROM_STATE_TOGGLE, 0);
             FIg_set_state (form, TO_STATE_TOGGLE, 0);
         }
      }
     free ((int *) delete_list);

     /* Unselect all the selected row(s) in the mcf */

     if ((rows - j) != 0)
      {
        for (i = 0; i < (rows - j); ++i)
         {
            status = (long) FImcf_set_select (form, STATE_LIST_MCF, i, FALSE);
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
        FIfld_set_num_rows (form, STATE_LIST_MCF, 0);

     if (!delete)
       _WFFmessage (NFI_W_NO_STATES_SELECTED, NULL);

     if (c_warning)
       _WFFmessage (NFI_W_STATE_IN_USE, NULL);

     status = NFI_S_SUCCESS;
     _NFIdebug ((fname, " returning <0x%.8x>\n", status));
     return (status);
  }

long _WFFchange_state (form, ptr)
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
     char   old_state_name[24];
     char   *text;
     char   old_seqno[10];
     struct WFFstate_st chg_state;

     static char *fname = "_WFFchange_state";

     status = (long) FIfld_get_num_rows (form, STATE_LIST_MCF, &num_rows); 
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
         /* See if this state is selected for change */

         status = (long) FIfld_get_select (form, STATE_LIST_MCF,i,0,&sel_flag);
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
		/* Added below code . IGI Intel Port - CN - 25/09/95 */
 	     FIfld_get_text_length(form,STATE_LIST_MCF,i,0,&length);	
             if ((text = (char *) malloc (length)) == NULL)
             {  
        	_NFIdebug ((fname, "malloc failed; size = <%d>\n", length));
        	ERRload_struct (NFI, NFI_E_MALLOC, "%d", length);
        	_NFIdebug ((fname, " returning FAILURE\n"));
        	return (NFI_E_MALLOC);
      	     }  
	
   	     FIfld_get_text (form, STATE_LIST_MCF, i, 0, length , 
			     text, &sel_flag, &r_pos);
             FIfld_get_text (form, STATE_LIST_MCF, i, 6, length , 
			     old_seqno, &sel_flag, &r_pos);
             strcpy(old_state_name,text);	
	     if(text) free(text);

	     _NFIdebug((fname, "Old state name <%s>\n",old_state_name )); 
	     _NFIdebug((fname, "Old sequence number <%s>\n",old_seqno ));
             break;
          }
      }

     if( !sel_flag )
     {
	/*  No old state was selected */

        _WFFmessage (NFI_W_NO_STATES_SELECTED_CHANGE, NULL);
        _NFIdebug ((fname, "No old state was selected\n"));
	return( NFI_S_SUCCESS );
     }

     /* get the state_name from the STATE_NAME_FIELD */

     status = _WFFget_data_from_field (form, STATE_NAME_FIELD, 0, 0, 
				       chg_state.state_name, length);
     if (status != NFI_S_SUCCESS)
      {
         _NFIdebug ((fname, " WFFget_data_from_field = <0x%.8x>\n", status));
         return (status);
      }
     _NFIdebug(( fname, "New state name <%s>\n", chg_state.state_name ));

     /* get the state_description from the STATE_DESC_FIELD */

     status = _WFFget_data_from_field (form, STATE_DESC_FIELD, 0, 0, 
				       chg_state.state_desc, 40);
     if (status != NFI_S_SUCCESS)
      {
         _NFIdebug ((fname, " WFFget_data_from_field = <0x%.8x>\n", status));
         return (status);
      }
     _NFIdebug(( fname, "New state description <%s>\n", chg_state.state_desc));

     /* get the state_no_signoffs from the MIN_NO_SIGNOFFS_FIELD */

     status = _WFFget_data_from_field (form, MIN_NO_SIGNOFFS_FIELD, 0, 0, 
				       chg_state.no_signoffs, 15);
     if (status != NFI_S_SUCCESS)
      {
         _NFIdebug ((fname, " WFFget_data_from_field = <0x%.8x>\n", status));
         return (status);
      }
     _NFIdebug(( fname, "New no signoffs <%s>\n", chg_state.no_signoffs ));

     /* get the state_name from the STATE_SEQNO_FIELD */

     status = _WFFget_data_from_field (form, STATE_SEQNO_FIELD, 0, 0, 
				       chg_state.seq_no, 15);
     if (status != NFI_S_SUCCESS)
      {
         _NFIdebug ((fname, " WFFget_data_from_field = <0x%.8x>\n", status));
         return (status);
      }
     _NFIdebug(( fname, "New state seqno <%s>\n", chg_state.seq_no ));

     /*  Check to see if this is a unique sequence number */

/* IGI Intel Solaris Port - CN 31/5/95 */
#if defined(OS_SCO_UNIX) || defined(OS_INTELSOL)
	/* TO SET font for SCO - CRN 25 Feb 94	*/
	FIg_set_font(form, STATE_SEQNO_FIELD, "7x13bold", 15);
#endif
     for (i = 0; i < ptr->num_states; ++i)
      {

	/* check to see if the sequence no is diplicate, by checking the seq nos	of all the other states except the current one. IGI - CN -26/09/95 */ 

	  if ( i == mcf_row) continue; 
          if (strcmp (ptr->state_list[i].seq_no, chg_state.seq_no) == 0)
           {
             _WFFmessage (NFI_W_DUPLICATE_SEQUENCE_NO, "%s", chg_state.seq_no);
             FIfld_set_text (form, STATE_SEQNO_FIELD, 0, 0, old_seqno, FALSE);
             _NFIdebug ((fname, " Duplicate seq_no <%s>\n", old_seqno));
             return (NFI_S_SUCCESS);
           }
      } 

     /*  Get toggle states */

     status = (long) FIg_get_state (form, MANDATORY_TOGGLE, &g_state);
     if (status != FI_SUCCESS)
     {
         _NFIdebug ((fname, "FIg_get_state = <%d>\n", status));
         ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_get_state",status);
         _NFIdebug ((fname, " returning FAILURE\n"));
     }
 
     if (g_state)
         strcpy (chg_state.majority, "MJ");   /* Majority */
     else
         strcpy (chg_state.majority, "MN");   /* Mandatory */

     /* get the gadget state for the transition from_state toggle */
 
     status = (long) FIg_get_state (form, FROM_STATE_TOGGLE, &g_state);
     if (status != FI_SUCCESS)
     {
         _NFIdebug ((fname, "FIg_get_state = <%d>\n", status));
         ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_get_state", status);
         _NFIdebug ((fname, " returning FAILURE\n"));
     }

     if (g_state)
         strcpy (chg_state.trans_from, "Y"); 
     else
	 strcpy (chg_state.trans_from, "N" );

     /* get the gadget state for the transition to_state toggle */

     status = (long) FIg_get_state (form, TO_STATE_TOGGLE, &g_state);
     if (status != FI_SUCCESS)
     {
         _NFIdebug ((fname, "FIg_get_state = <%d>\n", status));
         ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_get_state", status);
         _NFIdebug ((fname, " returning FAILURE\n"));
     }

     if (g_state)
         strcpy (chg_state.trans_to, "Y"); 
     else
	 strcpy (chg_state.trans_to, "N" );

     /* If the state_name is null, send a warning to user */ 

     if (strcmp (chg_state.state_name, "") == 0)
     {
        /* Put up a message warning user that state null */

        _WFFmessage (NFI_W_NULL_STATE_NAME, NULL);
        _NFIdebug ((fname, " returning SUCCESS\n"));
        return (NFI_S_SUCCESS);
      } 
   
     /* check to see if the row is a duplicate : if it is exit, send warning */

     if (ptr->state_list != NULL)
      {
        for (i = 0; i < ptr->num_states; ++i)
         {
             if(strcmp(ptr->state_list[i].state_name,chg_state.state_name)==0)
              {
		  /* Just because the state name did not change doesn't
		   * mean other information is not different.
		   */
		  if( strcmp( old_state_name, chg_state.state_name ) != 0 )
		  {
                    /* Clear out the state_name field */
   
                    status = (long) FIfld_set_text (form, STATE_NAME_FIELD,
				 0, 0, "", FALSE);
                    if (status != FI_SUCCESS)
                     {
                        _NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
                        ERRload_struct (NFI, NFI_E_FORM, "%s%d",
                                        "FIfld_set_text", status);
                        return (NFI_E_FORM);
                     } 
     
                     _WFFmessage(NFI_E_DUPLICATE_STATE,"%s",chg_state.state_name);
                     return (NFI_S_SUCCESS);
		   }
                }  
          }
      }

     if (ptr->state_list != NULL)
     {
        for (i = 0; i < ptr->num_states; ++i)
         {
             if(strcmp(ptr->state_list[i].state_name,old_state_name)==0)
             {
                  row = i;
		  chg_state.state_no = ptr->state_list[i].state_no;
		  strcpy( chg_state.status, WFF_MODIFY );
                  break;
             }
	 }
      }

    /*  Now change the state name in the database */
     
    status = _WFGmodify_state (ptr->workflow_no, chg_state);
    if( status != NFM_S_SUCCESS )
    {
	_NFIdebug(( fname, "_WFGmodify_state <0x%.8x>\n", status ));
	_WFFmessage( NFI_E_CHANGE_STATE, "%s", old_state_name );
	return( NFI_S_SUCCESS );
    }

    /*  Change old information in the state list */

    strcpy( ptr->state_list[row].state_name, chg_state.state_name);
    strcpy( ptr->state_list[row].state_desc, chg_state.state_desc);
    strcpy( ptr->state_list[row].no_signoffs,chg_state.no_signoffs);
    strcpy( ptr->state_list[row].majority, chg_state.majority );
    strcpy( ptr->state_list[row].trans_from, chg_state.trans_from );
    strcpy( ptr->state_list[row].trans_to, chg_state.trans_to );
    strcpy( ptr->state_list[row].seq_no, chg_state.seq_no );
  
    if (ptr->access_list != NULL)
    {
        for (i = 0; i < ptr->num_access; ++i)
        {
	    for( j=0; j<ptr->access_list[i].num_trans; ++j )
	    {
                if(strcmp (ptr->access_list[i].trans_ptr[j].from_state, 
			   old_state_name) == 0)
	 	   strcpy( ptr->access_list[i].trans_ptr[j].from_state,
			   chg_state.state_name );
                if(strcmp (ptr->access_list[i].trans_ptr[j].to_state, 
			   old_state_name) == 0)
	 	   strcpy( ptr->access_list[i].trans_ptr[j].to_state,
			   chg_state.state_name );
	    }
        }
    }

    if (ptr->trans_list != NULL)
     {
        for (i = 0; i < ptr->num_trans; ++i)
         {
             if( strcmp( ptr->trans_list[i].from_state,old_state_name ) == 0 )
                 strcpy( ptr->trans_list[i].from_state, chg_state.state_name );
             if( strcmp( ptr->trans_list[i].to_state,old_state_name ) == 0 )
                 strcpy( ptr->trans_list[i].to_state, chg_state.state_name );
	 }
      }

    /*  Now put the new state name in the MCF */

/* IGI Intel Solaris Port - CN 31/5/95 */
#if defined(OS_SCO_UNIX) || defined(OS_INTELSOL)
	/* TO SET font for SCO - CRN 25 Feb 94	*/
	FIg_set_font(form, STATE_LIST_MCF, "7x13bold", 15);
#endif
    FIfld_set_text(form,STATE_LIST_MCF, mcf_row, 0, chg_state.state_name,TRUE);
    FIfld_set_text(form,STATE_LIST_MCF, mcf_row, 1, chg_state.state_desc,TRUE);
    FIfld_set_text(form,STATE_LIST_MCF, mcf_row, 2,chg_state.no_signoffs,TRUE);
    FIfld_set_text(form,STATE_LIST_MCF, mcf_row, 3, chg_state.majority,TRUE );
    FIfld_set_text(form,STATE_LIST_MCF, mcf_row, 4, chg_state.trans_from,TRUE);
    FIfld_set_text(form,STATE_LIST_MCF, mcf_row, 5, chg_state.trans_to, TRUE );
    FIfld_set_text(form,STATE_LIST_MCF, mcf_row, 6, chg_state.seq_no, TRUE );

    return( NFI_S_SUCCESS );
}

void  _WFFget_next_seq_no (num_states, state_list, seq_no)
    int    num_states;
    struct WFFstate_st  state_list[];
    char                *seq_no;
{
     long   max_num = 65536;   /* 2 to the 16th */
     long   i, j;
     short found = FALSE;

     static char *fname = "_WFFget_next_seq_no";

     _NFIdebug ((fname, " Number of states = <%d>\n", num_states));

     if (num_states < 1)
      {
         sprintf (seq_no, "%d", 1);
         _NFIdebug ((fname, " returning\n"));
         return;
      }

     for (i = 1; i < max_num; ++i)
      {
        found = FALSE;
        /* _NFIdebug ((fname, "  = <%d>", i)); */
        for (j = 0; j < num_states; ++j)
         {
             if (strcmp (state_list[j].status, WFF_DROP) != 0)
              {
                 _NFIdebug ((fname, " state_list[%d].seq_no = <%s>\n",
                             j, state_list[j].seq_no));
                 if (i == atol (state_list[j].seq_no))
                  {
                     found = TRUE;
                     break;
                  } 
              }
         }
         if (!found)
          {
             sprintf (seq_no, "%d", i);
             break;
          }
      } 

     _NFIdebug ((fname, " next seq_no = <%s>\n", seq_no));
     _NFIdebug ((fname, " returning\n"));
     return;
  }


/****************************************************************************
 *                                                                          *
 *  Signoff states must also be make_transition from states.  This function * 
 *  is used to guarantee that the signoff state created will also be a      *
 *  "Make Transition" from state.                                           *
 *                                                                          *
 ****************************************************************************/

long _WFFcheck_so_state (form)
     Form        form;
  {
     long   status;
     long   value = 0; 
     int    g_state;
     char   min_signoffs[16];

     static char *fname = "_WFFcheck_so_state";

      /* get the min_signoffs from the MIN_NO_SIGNOFFS_FIELD */

      status = _WFFget_data_from_field (form, MIN_NO_SIGNOFFS_FIELD, 0, 0,
                                        min_signoffs, 15);
      if (status != NFI_S_SUCCESS)
       {
          _NFIdebug ((fname, " WFFget_data_from_field = <0x%.8x>\n", status));
          _NFIdebug ((fname, " returning FAILURE\n"));
          return (status);
       }

      /* get the numeric equivalent of the value */

/* IGI Intel Solaris Port - CN 31/5/95 */
#if defined(OS_SCO_UNIX) || defined(OS_INTELSOL)
	/* To set font for SCO - CRN 25 Feb 94	*/
	FIg_set_font(form, MIN_NO_SIGNOFFS_FIELD, "7x13bold", 15);
#endif
      status = _WFFcvt_to_long (min_signoffs, &value); 
      if (status != NFI_S_SUCCESS)
       {
          _NFIdebug ((fname, " WFFcvt_to_long = <0x%.8x>\n", status));
          if (status == NFI_W_NULL_NUMERIC_INPUT)
           {
              strcpy (min_signoffs, "0"); 
              _NFIdebug ((fname, " NUll signoff : defaulting value to 0\n"));
           }
          else if (status == NFI_W_INVALID_NUMERIC_INPUT)
           {
              FIfld_set_text (form, MIN_NO_SIGNOFFS_FIELD, 0, 0, "0", FALSE);
              _WFFmessage (NFI_W_NULL_NUMERIC_FIELD, "%s",  
                           "Minimum No. Signoffs");
              _NFIdebug ((fname, " Non-numeric input in signoffs field\n"));
              return (NFI_S_SUCCESS);
           }
          else if (status == NFI_W_NEGATIVE_VALUE)
           {
              FIfld_set_text (form, MIN_NO_SIGNOFFS_FIELD, 0, 0, "0", FALSE);
              _WFFmessage (NFI_W_NEGATIVE_VALUE, "%s",
                           "Min No. Signoffs Field");
              _NFIdebug ((fname, " Negative numeric input in Signoff Field\n"));
              return (NFI_S_SUCCESS);

           }
          else
           {
             ERRload_struct (NFI, status, NULL);
             _NFIdebug ((fname, " returning FAILURE\n"));
             return (status);
           }
       }

      if (atol (min_signoffs) > 0)       
       {
          /* get the gadget state for the FROM_STATE_TOGGLE */

          status = (long) FIg_get_state (form, FROM_STATE_TOGGLE, &g_state);
          if (status != FI_SUCCESS)
           {
              _NFIdebug ((fname, "FIg_get_state = <%d>\n", status));
              ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_get_state",
                              status);
              _NFIdebug ((fname, " returning FAILURE\n"));
              return (status);
           }
 
          if (g_state == FALSE)
           {
              status = (long) FIg_set_state (form, FROM_STATE_TOGGLE, TRUE);
              if (status != FI_SUCCESS)
               {
                  _NFIdebug ((fname, "FIg_set_state = <%d>\n", status));
                  ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_set_state",
                                  status);
                  _NFIdebug ((fname, " returning FAILURE\n"));
               }
              _WFFmessage (NFI_W_SIGNOFF_STATE, NULL);
           }
       }

     _NFIdebug ((fname, " returning <0x%.8x>\n", NFI_S_SUCCESS));
     return (NFI_S_SUCCESS);
  }


long _WFFupdate_class (form, g_label, scf_label, no_classes,
                       class_list, no_access, access_list)
     Form        form;
     int         g_label; 
     int         scf_label; 
     int         no_classes;
     struct  WFFclass_st class_list[];
     int         no_access;
     struct  WFFaccess_st access_list[];
  {
     long   status;
     int    sel_flag = FALSE, row = -1;  
     int    rows = 0, length = 20, i;
     int    r_pos, c_row = 0;
     char   class_name[24];
     char   c_name[24];

     static char *fname = "_WFFupdate_class";

     strcpy (c_name, "");

     /* Get the number of rows from the SCF (the class_list may
        not match the no of rows in the SCF).                     */

     status = FIfld_get_num_rows (form, scf_label, &rows);
     if (status != FI_SUCCESS)
      {
         _NFIdebug ((fname, "FIfld_get_num_rows = <%d>\n", status));
         ERRload_struct (NFI, NFI_E_FORM, "%s%d",
                         "FIfld_get_num_rows", status);
         _NFIdebug ((fname, " returning FAILURE\n"));
         return (NFI_E_FORM);
      } 

     /* Check to see if a class is selected */

     for (i = 0; i < rows; ++i)
      {
         status = (long) FIfld_get_select (form, scf_label, i, 0, &sel_flag);
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

             FIfld_get_text (form, scf_label, i, 0, length + 1, c_name,
                             &sel_flag, &r_pos);
             break;
          }
      } 

     if (row == -1)
      {
         /* No row has been selected.  This is probably a new class */

         _NFIdebug ((fname, " returning SUCCESS\n"));
         return (NFI_S_SUCCESS);
      }

     strcpy (class_name, "");

     /* get the class_name from the CLASS_NAME_FIELD */

     status = _WFFget_data_from_field (form, g_label, 0, 0, class_name, length);
     if (status != NFI_S_SUCCESS)
      {
         _NFIdebug ((fname, " WFFget_data_from_field = <0x%.8x>\n", status));
         _NFIdebug ((fname, " returning FAILURE\n"));
         return (status);
      }

     /* If the class_name is null, send a warning to user */ 
     if (strcmp (class_name, "") == 0)
      {
        /* Put up a message warning user that class null */

        _WFFmessage (NFI_W_NULL_CLASS_NAME, NULL);
        _NFIdebug ((fname, " returning SUCCESS\n"));
        return (NFI_S_SUCCESS);
      } 
   
     /* check to see if the row is a duplicate : if it is exit, send warning */

     if (class_list != NULL)
      {
/* IGI Intel Solaris Port - CN 31/5/95 */
#if defined(OS_SCO_UNIX) || defined(OS_INTELSOL)
	/* To set font for SCO - CRN 25 Feb 94	*/
	FIg_set_font(form, g_label, "7x13bold", 15);
#endif
        for (i = 0; i < no_classes; ++i)
         {
           if (class_list[i].row != row) 
           {
             if ((strcmp (class_list[i].class_name, class_name) == 0) &&
                 (strcmp (class_list[i].status, WFF_DROP) != 0)) 
              {
                  /* Reset the class_name field back to its original value */
   
                  status = (long) FIfld_set_text (form, g_label, 0, 0, 
                                                  c_name, FALSE);
                  if (status != FI_SUCCESS)
                   {
                      _NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
                      ERRload_struct (NFI, NFI_E_FORM, "%s%d",
                                      "FIfld_set_text", status);
                      _NFIdebug ((fname, " returning FAILURE\n"));
                      return (NFI_E_FORM);
                   } 
   
                  /* Put up a message warning user that class is a duplicate */
   
                  _WFFmessage (NFI_E_DUPLICATE_CLASS, "%s", class_name);
   
                  return (NFI_S_SUCCESS);
              }  
           }  
          else
           {
              c_row = i;
           }
         }
      }

     _NFIdebug ((fname, "c_row  = <%d>\n", c_row));
     _NFIdebug ((fname, "c_name = <%s>\n", c_name));

     /* Put up a working message */

     /* _WFFmessage (NFI_I_MODIFY_CLASS, "%s", c_name); */

     /* Update the access_list class field */

     for (i = 0; i < no_access; ++i)
      {
         if ((strcmp (access_list[i].class_name, c_name) == 0) &&
             (strcmp (access_list[i].status, WFF_DROP) != 0)) 
          {
             /* Modify the class name */

             strcpy (access_list[i].class_name, class_name);
             if (strcmp (access_list[i].status, "") == 0)
              {
                  strcpy (access_list[i].status, WFF_MODIFY);
              }
          } 
      } 

     /* Update the existing class in the list */

     strcpy (class_list[c_row].class_name, class_name); 
     if (strcmp (class_list[c_row].status, "") == 0)
        strcpy (class_list[c_row].status, WFF_MODIFY); 

     /* Update the SCF */

/* IGI Intel Solaris Port - CN 31/5/95 */
#if defined(OS_SCO_UNIX) || defined(OS_INTELSOL)
	/* To set font for SCO - CRN 25 Feb 94	*/
	FIg_set_font(form, scf_label, "7x13bold", 15);
#endif
     status = (long) FIfld_set_text (form, scf_label, row, 0, 
                                     class_name, TRUE);
     if (status != FI_SUCCESS)
      {
         _NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
         ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_text",
                         status);
         _NFIdebug ((fname, " returning FAILURE\n"));
         return (NFI_E_FORM);
      } 

     /* set the row to be in the viewing area */

     _WFFset_active_row (form, CLASS_LIST_SCF, row, 1);

     status = NFI_S_SUCCESS;
     _NFIdebug ((fname, " returning <0x%.8x>\n", status));
     return (status);
  }


long _WFFset_selected_class (form, g_label, scf_label)
     Form        form;
     int         g_label; 
     int         scf_label; 
  {
     long   status;
     int    sel_flag = FALSE;  
     int    rows = 0, length = 20, i;
     int    r_pos;
     char   class_name[24];

     static char *fname = "_WFFset_selected_class";

     /* Get the number of rows from the SCF (the class_list may
        not match the no of rows in the SCF).                     */

     status = FIfld_get_num_rows (form, scf_label, &rows);
     if (status != FI_SUCCESS)
      {
         _NFIdebug ((fname, "FIfld_get_num_rows = <%d>\n", status));
         ERRload_struct (NFI, NFI_E_FORM, "%s%d",
                         "FIfld_get_num_rows", status);
         _NFIdebug ((fname, " returning FAILURE\n"));
         return (NFI_E_FORM);
      } 

     if (rows == 0) 
      {
         _NFIdebug ((fname, "rows = <%d>\n", rows));
         _NFIdebug ((fname, " returning SUCCESS\n"));
         return (NFI_S_SUCCESS);
      } 

     /* Check to see if a class is selected */

     for (i = 0; i < rows; ++i)
      {
         status = (long) FIfld_get_select (form, scf_label, i, 0, &sel_flag);
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

             status = (long) FIfld_get_text (form, scf_label, i, 0,
                             length + 1, class_name, &sel_flag, &r_pos);
             if (status != FI_SUCCESS)
              {
                 _NFIdebug ((fname, "FIfld_get_text = <%d>\n", status));
                 ERRload_struct (NFI, NFI_E_FORM, "%s%d",
                                 "FIfld_get_text", status);
                 _NFIdebug ((fname, " returning FAILURE\n"));
                 return (NFI_E_FORM);
              } 

             /* Set the class_name field to the selected value in the SCF */
   
/* IGI Intel Solaris Port - CN 31/5/95 */
#if defined(OS_SCO_UNIX) || defined(OS_INTELSOL)
	/* To set font for SCO - CRN 25 Feb 94	*/
	FIg_set_font(form, g_label, "7x13bold", 15);
#endif
             status = (long) FIfld_set_text (form, g_label, 0, 0, 
                                             class_name, FALSE);
             if (status != FI_SUCCESS)
              {
                 _NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
                 ERRload_struct (NFI, NFI_E_FORM, "%s%d",
                                 "FIfld_set_text", status);
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


long _WFFset_selected_state (form, mcf_label)
     Form        form;
     int         mcf_label; 
  {
     long   status;
     int    sel_flag = FALSE;  
     int    rows = 0, length = 40, i;
     int    state = FALSE;
     int    r_pos;
     char   str [48];

     static char *fname = "_WFFset_selected_state";

     /* Get the number of rows from the MCF (the state_list may
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

     if (rows == 0) 
      {
         _NFIdebug ((fname, "rows = <%d>\n", rows));
         _NFIdebug ((fname, " returning SUCCESS\n"));
         return (NFI_S_SUCCESS);
      } 

     /* Check to see if a state is selected */

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

             /* Set the state_name field to the selected value in the MCF */
   
/* IGI Intel Solaris Port - CN 31/5/95 */
#if defined(OS_SCO_UNIX) || defined(OS_INTELSOL)
	/* To set font for SCO - CRN 25 Feb 94	*/
	FIg_set_font(form, STATE_NAME_FIELD, "7x13bold", 15);
#endif
             status = (long) FIfld_set_text (form, STATE_NAME_FIELD, 0, 0, 
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
             /* get the state description and set it. in the state desc field */

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

             /* Set the state_desc field to the selected value in the MCF */
   
/* IGI Intel Solaris Port - CN 31/5/95 */
#if defined(OS_SCO_UNIX) || defined(OS_INTELSOL)
	/* To set font for SCO - CRN 25 Feb 94	*/
	FIg_set_font(form, STATE_DESC_FIELD, "7x13bold", 15);
#endif
             status = (long) FIfld_set_text (form, STATE_DESC_FIELD, 0, 0, 
                                             str, FALSE);
             if (status != FI_SUCCESS)
              {
                 _NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
                 ERRload_struct (NFI, NFI_E_FORM, "%s%d",
                                 "FIfld_set_text", status);
                 _NFIdebug ((fname, " returning FAILURE\n"));
                 return (NFI_E_FORM);
              } 

             /* get the sequence no and set it. in the seqno field */

             str[0] = 0;
             status = (long) FIfld_get_text (form, mcf_label, i, 6,
                             15, str, &sel_flag, &r_pos);
             if (status != FI_SUCCESS)
              {
                 _NFIdebug ((fname, "FIfld_get_text = <%d>\n", status));
                 ERRload_struct (NFI, NFI_E_FORM, "%s%d",
                                 "FIfld_get_text", status);
                 _NFIdebug ((fname, " returning FAILURE\n"));
                 return (NFI_E_FORM);
              } 

             /* Set the seqno field to the selected value in the MCF */
   
/* IGI Intel Solaris Port - CN 31/5/95 */
#if defined(OS_SCO_UNIX) || defined(OS_INTELSOL)
	/* To set font for SCO - CRN 25 Feb 94	*/
	FIg_set_font(form, STATE_SEQNO_FIELD, "7x13bold", 15);
#endif
             status = (long) FIfld_set_text (form, STATE_SEQNO_FIELD, 0, 0, 
                                             str, FALSE);
             if (status != FI_SUCCESS)
              {
                 _NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
                 ERRload_struct (NFI, NFI_E_FORM, "%s%d",
                                 "FIfld_set_text", status);
                 _NFIdebug ((fname, " returning FAILURE\n"));
                 return (NFI_E_FORM);
              } 

             /* get the min no signoffs and set it. in the signoffs field */

             str[0] = 0;
             status = (long) FIfld_get_text (form, mcf_label, i, 2,
                             15, str, &sel_flag, &r_pos);
             if (status != FI_SUCCESS)
              {
                 _NFIdebug ((fname, "FIfld_get_text = <%d>\n", status));
                 ERRload_struct (NFI, NFI_E_FORM, "%s%d",
                                 "FIfld_get_text", status);
                 _NFIdebug ((fname, " returning FAILURE\n"));
                 return (NFI_E_FORM);
              } 

             /* Set the min signoffs field to the selected value in the MCF */
   
/* IGI Intel Solaris Port - CN 31/5/95 */
#if defined(OS_SCO_UNIX) || defined(OS_INTELSOL)
	/* To set font for SCO - CRN 25 Feb 94	*/
	FIg_set_font(form, MIN_NO_SIGNOFFS_FIELD, "7x13bold", 15);
#endif
             status = (long) FIfld_set_text (form, MIN_NO_SIGNOFFS_FIELD, 0, 0, 
                                             str, FALSE);
             if (status != FI_SUCCESS)
              {
                 _NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
                 ERRload_struct (NFI, NFI_E_FORM, "%s%d",
                                 "FIfld_set_text", status);
                 _NFIdebug ((fname, " returning FAILURE\n"));
                 return (NFI_E_FORM);
              } 

             /* get and set the mandatory toggle */

             str[0] = 0;
             status = (long) FIfld_get_text (form, mcf_label, i, 3,
                             3, str, &sel_flag, &r_pos);
             if (status != FI_SUCCESS)
              {
                 _NFIdebug ((fname, "FIfld_get_text = <%d>\n", status));
                 ERRload_struct (NFI, NFI_E_FORM, "%s%d",
                                 "FIfld_get_text", status);
                 _NFIdebug ((fname, " returning FAILURE\n"));
                 return (NFI_E_FORM);
              } 

	     _NFIdebug(( fname, "Signoff type string <%s>\n", str ));

             /* Set the toggle state based on the string */

             if (strcmp (str, "MJ") == 0)
                state = TRUE;

             status = (long) FIg_set_state (form, MANDATORY_TOGGLE, state);
             if (status != FI_SUCCESS)
              {
                 _NFIdebug ((fname, "FIg_set_state = <%d>\n", status));
                 ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_set_state",
                                 status);
                 _NFIdebug ((fname, " returning FAILURE\n"));
                 return (NFI_E_FORM);
              } 
             state = FALSE;

             /* get and set the transition from toggle */

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
                state = TRUE;

             status = (long) FIg_set_state (form, FROM_STATE_TOGGLE, state);
             if (status != FI_SUCCESS)
              {
                 _NFIdebug ((fname, "FIg_set_state = <%d>\n", status));
                 ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_set_state",
                                 status);
                 _NFIdebug ((fname, " returning FAILURE\n"));
                 return (NFI_E_FORM);
              } 
             state = FALSE;

             /* get and set the transition to toggle */

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
                state = TRUE;

             status = (long) FIg_set_state (form, TO_STATE_TOGGLE, state);
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


long _WFFupdate_state_name (form, g_label, mcf_label, ptr)
     Form        form;
     int         g_label; 
     int         mcf_label; 
     WFFadd_ptr  ptr;
  {
     long   status;
     int    sel_flag = FALSE, row = -1;  
     int    rows = 0, length = 40, i, j;
     int    r_pos, s_row = 0;
     char   state_name[48];
     char   s_name[48];

     static char *fname = "_WFFupdate_state_name";

     _NFIdebug ((fname, "g_label   = <%d>\n", g_label));
     _NFIdebug ((fname, "mcf_label = <%d>\n", mcf_label));

     strcpy (s_name, "");

     /* Get the number of rows from the MCF (the state_list may
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

     /* Check to see if a state is selected */

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
             break;
          }
      } 

     if (row == -1)
      {
         /* No row has been selected.  This is probably a new state */

         _NFIdebug ((fname, " returning SUCCESS\n"));
         return (NFI_S_SUCCESS);
      }

     _NFIdebug ((fname, " row = <%d>\n", row));
     strcpy (state_name, "");

     /* get the state_name from the STATE_NAME_FIELD */

     status = _WFFget_data_from_field (form, g_label, 0, 0, state_name, length);
     if (status != NFI_S_SUCCESS)
      {
         _NFIdebug ((fname, " WFFget_data_from_field = <0x%.8x>\n", status));
         _NFIdebug ((fname, " returning FAILURE\n"));
         return (status);
      }

     /* If the state_name is null, send a warning to user */ 

     if (strcmp (state_name, "") == 0)
      {
        /* Put up a message warning user that state is null */

/* IGI Intel Solaris Port - CN 31/5/95 */
#if defined(OS_SCO_UNIX) || defined(OS_INTELSOL)
	/* To set font for SCO - CRN 25 Feb 94	*/
	FIg_set_font(form, g_label, "7x13bold", 15);
#endif
        FIfld_set_text (form, g_label, 0, 0, s_name, FALSE);
        _WFFmessage (NFI_W_NULL_STATE_NAME, NULL);
         _NFIdebug ((fname, " returning SUCCESS\n"));
         return (NFI_S_SUCCESS);
      } 
   
     /* check to see if the row is a duplicate : if it is exit, send warning */

/* IGI Intel Solaris Port - CN 31/5/95 */
#if defined(OS_SCO_UNIX) || defined(OS_INTELSOL)
 	/* To set font for SCO - CRN 25 Feb 94	*/
	FIg_set_font(form, g_label, "7x13bold", 15);
#endif
     if (ptr->state_list != NULL)
      {
        for (i = 0; i < ptr->num_states; ++i)
         {
           if (ptr->state_list[i].row != row) 
           {
             if ((strcmp (ptr->state_list[i].state_name, state_name) == 0) &&
                 (strcmp (ptr->state_list[i].status, WFF_DROP) != 0)) 
              {
                  /* Reset the state_name field back to its original value */
   
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
   
                  /* Put up a message warning user that state is a duplicate */
   
                  _WFFmessage (NFI_E_DUPLICATE_STATE, "%s", state_name);
   
                  return (NFI_S_SUCCESS);
              }  
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

     /* _WFFmessage (NFI_I_MODIFY_STATE, "%s", s_name); */

     /* Update the transition_list from_state field */

     for (i = 0; i < ptr->num_trans; ++i)
      {
         if ((strcmp (ptr->trans_list[i].from_state, s_name) == 0) &&
             (strcmp (ptr->trans_list[i].status, WFF_DROP) != 0)) 
          {
             /* Modify the from_state name */

             strcpy (ptr->trans_list[i].from_state, state_name);
             if (strcmp (ptr->trans_list[i].status, "") == 0)
              {
                  strcpy (ptr->trans_list[i].status, WFF_MODIFY);
              }
          } 
      } 

     /* Update the transition_list to_state field */

     for (i = 0; i < ptr->num_trans; ++i)
      {
         if ((strcmp (ptr->trans_list[i].to_state, s_name) == 0) &&
             (strcmp (ptr->trans_list[i].status, WFF_DROP) != 0)) 
          {
             /* Modify the to_state name */

             strcpy (ptr->trans_list[i].to_state, state_name);
             if (strcmp (ptr->trans_list[i].status, "") == 0)
              {
                  strcpy (ptr->trans_list[i].status, WFF_MODIFY);
              }
          } 
      } 

     /* Update the access_list from_state field */

     for (i = 0; i < ptr->num_access; ++i)
      {
         if (strcmp (ptr->access_list[i].status, WFF_DROP) == 0)
            continue;

         for (j = 0; j < ptr->access_list[i].num_trans; ++j)
          {
             if ((strcmp (ptr->access_list[i].trans_ptr[j].from_state,
                          s_name) == 0) &&
                 (strcmp (ptr->access_list[i].trans_ptr[j].status,
                          WFF_DROP) != 0)) 
              {
                 /* Modify the from_state name */
    
                 strcpy (ptr->access_list[i].trans_ptr[j].from_state,
                         state_name);
                 if (strcmp (ptr->access_list[i].trans_ptr[j].status, "") == 0)
                  {
                      strcpy (ptr->access_list[i].trans_ptr[j].status,
                              WFF_MODIFY);
                  }
              } 
          } 
      } 

     /* Update the access_list to_state field */

     for (i = 0; i < ptr->num_access; ++i)
      {
         if (strcmp (ptr->access_list[i].status, WFF_DROP) == 0)
            continue;

         for (j = 0; j < ptr->access_list[i].num_trans; ++j)
          {
             if ((strcmp (ptr->access_list[i].trans_ptr[j].to_state,
                          s_name) == 0) &&
                 (strcmp (ptr->access_list[i].trans_ptr[j].status,
                          WFF_DROP) != 0)) 
              {
                 /* Modify the from_state name */
    
                 strcpy (ptr->access_list[i].trans_ptr[j].to_state,
                         state_name);
                 if (strcmp (ptr->access_list[i].trans_ptr[j].status, "") == 0)
                  {
                      strcpy (ptr->access_list[i].trans_ptr[j].status,
                              WFF_MODIFY);
                  }
              } 
          } 
      } 

     /* Update the existing state in the state list */

     strcpy (ptr->state_list[s_row].state_name, state_name); 
     if (strcmp (ptr->state_list[s_row].status, "") == 0)
        strcpy (ptr->state_list[s_row].status, WFF_MODIFY); 

     /* Update the MCF */

/* IGI Intel Solaris Port - CN 31/5/95 */
#if defined(OS_SCO_UNIX) || defined(OS_INTELSOL)
	/* To set font for SCO - CRN 25 Feb 94	*/
	FIg_set_font(form, mcf_label, "7x13bold", 15);
#endif
     status = (long) FIfld_set_text (form, mcf_label, row, 0, 
                                     state_name, TRUE);
     if (status != FI_SUCCESS)
      {
         _NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
         ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_text",
                         status);
         _NFIdebug ((fname, " returning FAILURE\n"));
         return (NFI_E_FORM);
      } 

     /* set the row to be in the viewing area */

     _WFFset_active_row (form, STATE_LIST_MCF, row, 1);

     status = NFI_S_SUCCESS;
     _NFIdebug ((fname, " returning <0x%.8x>\n", status));
     return (status);
  }


long _WFFupdate_state_desc (form, g_label, mcf_label, ptr)
     Form        form;
     int         g_label; 
     int         mcf_label; 
     WFFadd_ptr  ptr;
  {
     long   status;
     int    sel_flag = FALSE, row = -1;  
     int    rows = 0, length = 40, i;
     int    r_pos, s_row = 0;
     char   state_desc[48];
     char   s_desc[48];

     static char *fname = "_WFFupdate_state_desc";

     _NFIdebug ((fname, "g_label   = <%d>\n", g_label));
     _NFIdebug ((fname, "mcf_label = <%d>\n", mcf_label));

     strcpy (s_desc, "");

     /* Get the number of rows from the MCF (the state_list may
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

     /* Check to see if a state is selected */

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

             FIfld_get_text (form, mcf_label, i, 1, length + 1, s_desc,
                             &sel_flag, &r_pos);
             break;
          }
      } 

     if (row == -1)
      {
         /* No row has been selected.  This is probably a new state */

         _NFIdebug ((fname, " returning SUCCESS\n"));
         return (NFI_S_SUCCESS);
      }

     strcpy (state_desc, "");

     /* get the state_desc from the STATE_DESC_FIELD */

     status = _WFFget_data_from_field (form, g_label, 0, 0, state_desc, length);
     if (status != NFI_S_SUCCESS)
      {
         _NFIdebug ((fname, " WFFget_data_from_field = <0x%.8x>\n", status));
         _NFIdebug ((fname, " returning FAILURE\n"));
         return (status);
      }

   
     /* Find the row in the state_list to update */

     if (ptr->state_list != NULL)
      {
        for (i = 0; i < ptr->num_states; ++i)
         {
           if ((ptr->state_list[i].row == row) &&
               (strcmp (ptr->state_list[i].status, WFF_DROP) != 0))
           {
              s_row = i;
              break;
           }
         }
      }

     _NFIdebug ((fname, "s_row  = <%d>\n", s_row));
     _NFIdebug ((fname, "s_desc = <%s>\n", s_desc));

     /* Put up a working message */

     /* _WFFmessage (NFI_I_MODIFY_STATE, "%s", s_name); */

     /* Update the existing state in the state list */

     strcpy (ptr->state_list[s_row].state_desc, state_desc); 
     if (strcmp (ptr->state_list[s_row].status, "") == 0)
        strcpy (ptr->state_list[s_row].status, WFF_MODIFY); 

     /* Update the MCF */

/* IGI Intel Solaris Port - CN 31/5/95 */
#if defined(OS_SCO_UNIX) || defined(OS_INTELSOL)
	/* To set font for SCO - CRN 25 Feb 94	*/
	FIg_set_font(form, mcf_label, "7x13bold", 15);
#endif
     status = (long) FIfld_set_text (form, mcf_label, row, 1, 
                                     state_desc, TRUE);
     if (status != FI_SUCCESS)
      {
         _NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
         ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_text",
                         status);
         _NFIdebug ((fname, " returning FAILURE\n"));
         return (NFI_E_FORM);
      } 

     /* set the row to be in the viewing area */

     _WFFset_active_row (form, STATE_LIST_MCF, row, 1);

     status = NFI_S_SUCCESS;
     _NFIdebug ((fname, " returning <0x%.8x>\n", status));
     return (status);
  }


long _WFFupdate_state_seqno (form, g_label, mcf_label, ptr)
     Form        form;
     int         g_label; 
     int         mcf_label; 
     WFFadd_ptr  ptr;
  {
     long   status;
     long   value = 0;
     int    sel_flag = FALSE, row = -1;  
     int    rows = 0, length = 15, i;
     int    r_pos, s_row = 0;
     char   seqno[16];
     char   s_seqno[16];

     static char *fname = "_WFFupdate_state_seqno";

     _NFIdebug ((fname, "g_label   = <%d>\n", g_label));
     _NFIdebug ((fname, "mcf_label = <%d>\n", mcf_label));

     strcpy (s_seqno, "");

     /* Get the number of rows from the MCF (the state_list may
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

     /* Check to see if a state is selected */

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

             FIfld_get_text (form, mcf_label, i, 6, length + 1, s_seqno,
                             &sel_flag, &r_pos);
             break;
          }
      } 

     if (row == -1)
      {
         /* No row has been selected.  This is probably a new state */

         _NFIdebug ((fname, " returning SUCCESS\n"));
         return (NFI_S_SUCCESS);
      }

     /* find the row in the state_list to update */

     for (i = 0; i < ptr->num_states; ++i)
      {
         if ((ptr->state_list[i].row == row) &&
             (strcmp (ptr->state_list[i].status, WFF_DROP) != 0))
          {
             s_row = i;
             break;
          }
      }

     _NFIdebug ((fname, "s_row   = <%d>\n", s_row));
     _NFIdebug ((fname, "s_seqno = <%s>\n", s_seqno));

     /* get the seq_no from the STATE_SEQNO_FIELD */

     status = _WFFget_data_from_field (form, STATE_SEQNO_FIELD, 0, 0,
                                       seqno, length);
     if (status != NFI_S_SUCCESS)
      {
         _NFIdebug ((fname, " WFFget_data_from_field = <0x%.8x>\n",
                     status));
         _NFIdebug ((fname, " returning FAILURE\n"));
         return (status);
      }

     /* get the numeric equivalent of the value */

/* IGI Intel Solaris Port - CN 31/5/95 */
#if defined(OS_SCO_UNIX) || defined(OS_INTELSOL)
	/* To set font for SCO - CRN 25 Feb 94	*/
	FIg_set_font(form, STATE_SEQNO_FIELD, "7x13bold", 15);
#endif
     status = _WFFcvt_to_long (seqno, &value); 
     if (status != NFI_S_SUCCESS)
      {
         _NFIdebug ((fname, " WFFcvt_to_long = <0x%.8x>\n", status));
          if (status == NFI_W_NULL_NUMERIC_INPUT)
           {
             /* get the next available sequence number */
                 
             _WFFget_next_seq_no (ptr->num_states, ptr->state_list, seqno);
             _NFIdebug ((fname, " NUll seq_no : defaulting value to <%s>\n",
                         seqno));
           }
          else if (status == NFI_W_INVALID_NUMERIC_INPUT)
           {
              FIfld_set_text (form, STATE_SEQNO_FIELD, 0, 0, s_seqno, FALSE);
              _WFFmessage (NFI_W_NULL_NUMERIC_FIELD, "%s", "Sequence No.");
              _NFIdebug ((fname, " Non-numeric input in seq_no field\n"));
              return (NFI_S_SUCCESS);
           }
          else if (status == NFI_W_NEGATIVE_VALUE)
           {
              FIfld_set_text (form, STATE_SEQNO_FIELD, 0, 0, s_seqno, FALSE);
              _WFFmessage (NFI_W_NEGATIVE_VALUE, "%s", "Sequence No. Field");
              _NFIdebug ((fname, " Negative numeric input in seq_no field\n"));
              return (NFI_S_SUCCESS);
           }
          else
           {
              ERRload_struct (NFI, status, NULL);
              _NFIdebug ((fname, " returning FAILURE\n"));
              return (status);
           }
       }

     if (ptr->state_list != NULL)
      {
         for (i = 0; i < ptr->num_states; ++i)
          {
              if (ptr->state_list[i].row == row)
                 continue;

              if (strcmp (ptr->state_list[i].status, WFF_DROP) == 0)
                 continue;
   
              if (strcmp (ptr->state_list[i].seq_no, seqno) == 0)
               {
                 _WFFmessage (NFI_W_DUPLICATE_SEQUENCE_NO, "%s", seqno);
                 FIfld_set_text (form, STATE_SEQNO_FIELD, 0, 0, s_seqno, FALSE);
                 _NFIdebug ((fname, " Duplicate seq_no <%s>\n", seqno));
                 return (NFI_S_SUCCESS);
               }
          } 
      } 

     /* Put up a working message */

     /* _WFFmessage (NFI_I_MODIFY_STATE, "%s", s_name); */

     /* Update the existing state in the state list */

     strcpy (ptr->state_list[s_row].seq_no, seqno); 
     if (strcmp (ptr->state_list[s_row].status, "") == 0)
        strcpy (ptr->state_list[s_row].status, WFF_MODIFY); 

     /* Update the MCF */

/* IGI Intel Solaris Port - CN 31/5/95 */
#if defined (OS_SCO_UNIX) || defined(OS_INTELSOL)
	/* To set font for SCO - CRN 25 Feb 94	*/
	FIg_set_font(form, mcf_label, "7x13bold", 15);
#endif
     status = (long) FIfld_set_text (form, mcf_label, row, 6, 
                                     seqno, TRUE);
     if (status != FI_SUCCESS)
      {
         _NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
         ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_text",
                         status);
         _NFIdebug ((fname, " returning FAILURE\n"));
         return (NFI_E_FORM);
      } 

     /* set the row to be in the viewing area */

     _WFFset_active_row (form, STATE_LIST_MCF, row, 1);

     status = NFI_S_SUCCESS;
     _NFIdebug ((fname, " returning <0x%.8x>\n", status));
     return (status);
  }



long _WFFupdate_state_signoffs (form, g_label, mcf_label, ptr)
     Form        form;
     int         g_label; 
     int         mcf_label; 
     WFFadd_ptr  ptr;
  {
     long   status;
     long   value = 0;
     int    sel_flag = FALSE, row = -1;  
     int    rows = 0, length = 15, i;
     int    r_pos, s_row = 0;
     char   signoffs[16];
     char   s_signoffs[16];

     static char *fname = "_WFFupdate_state_signoffs";

     _NFIdebug ((fname, "g_label   = <%d>\n", g_label));
     _NFIdebug ((fname, "mcf_label = <%d>\n", mcf_label));

     strcpy (s_signoffs, "");

     /* Get the number of rows from the MCF (the state_list may
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

     /* Check to see if a state is selected */

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

             FIfld_get_text (form, mcf_label, i, 2, length + 1, s_signoffs,
                             &sel_flag, &r_pos);
             break;
          }
      } 

     if (row == -1)
      {
         /* No row has been selected.  This is probably a new state */

         _NFIdebug ((fname, " returning SUCCESS\n"));
         return (NFI_S_SUCCESS);
      }

     /* find the row in the state_list to update */

     for (i = 0; i < ptr->num_states; ++i)
      {
         if ((ptr->state_list[i].row == row) &&
             (strcmp (ptr->state_list[i].status, WFF_DROP) != 0))
          {
             s_row = i;
             break;
          }
      }

     _NFIdebug ((fname, "s_row   = <%d>\n", s_row));
     _NFIdebug ((fname, "s_seqno = <%s>\n", s_signoffs));

     /* get the min_signoffs from the MIN_NO_SIGNOFFS_FIELD */

     status = _WFFget_data_from_field (form, MIN_NO_SIGNOFFS_FIELD, 0, 0,
                                       signoffs, length);
     if (status != NFI_S_SUCCESS)
      {
         _NFIdebug ((fname, " WFFget_data_from_field = <0x%.8x>\n", status));
         _NFIdebug ((fname, " returning FAILURE\n"));
         return (status);
      }

     /* get the numeric equivalent of the value */

     status = _WFFcvt_to_long (signoffs, &value); 
     if (status != NFI_S_SUCCESS)
      {
         _NFIdebug ((fname, " WFFcvt_to_long = <0x%.8x>\n", status));
         if (status == NFI_W_NULL_NUMERIC_INPUT)
          {
             _NFIdebug ((fname, " NUll signoff : defaulting value to %s\n",
                         s_signoffs));
             strcpy (signoffs, s_signoffs);
          }
         else if (status == NFI_W_INVALID_NUMERIC_INPUT)
          {
             FIfld_set_text (form, MIN_NO_SIGNOFFS_FIELD, 0, 0, s_signoffs,
                             FALSE);
             _WFFmessage (NFI_W_NULL_NUMERIC_FIELD, "%s",  
                          "Minimum No. Signoffs");
             _NFIdebug ((fname, " Non-numeric input in signoffs field\n"));

             return (NFI_S_SUCCESS);
          }
         else if (status == NFI_W_NEGATIVE_VALUE)
          {
             FIfld_set_text (form, MIN_NO_SIGNOFFS_FIELD, 0, 0, s_signoffs,
                             FALSE);
             _WFFmessage (NFI_W_NEGATIVE_VALUE, "%s", "Minimum No. Signoffs");
             _NFIdebug ((fname, "Negative numeric input in signoffs field\n"));
             return (NFI_S_SUCCESS);
          }
         else
          {
            ERRload_struct (NFI, status, NULL);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (status);
          }
      }

     /* Put up a working message */

     /* _WFFmessage (NFI_I_MODIFY_STATE, "%s", s_name); */

     /* Update the existing state in the state list */

     strcpy (ptr->state_list[s_row].no_signoffs, signoffs); 
     if (strcmp (ptr->state_list[s_row].status, "") == 0)
        strcpy (ptr->state_list[s_row].status, WFF_MODIFY); 

     /* Update the MCF */

/* IGI Intel Solaris Port - CN 31/5/95 */
#if defined(OS_SCO_UNIX) || defined(OS_INTELSOL)
	/* To set font for SCO - CRN 25 Feb 94	*/
	FIg_set_font(form, mcf_label, "7x13bold", 15);
#endif
     status = (long) FIfld_set_text (form, mcf_label, row, 2, 
                                     signoffs, TRUE);
     if (status != FI_SUCCESS)
      {
         _NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
         ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_text",
                         status);
         _NFIdebug ((fname, " returning FAILURE\n"));
         return (NFI_E_FORM);
      } 

     /* set the row to be in the viewing area */

     _WFFset_active_row (form, STATE_LIST_MCF, row, 1);

     status = NFI_S_SUCCESS;
     _NFIdebug ((fname, " returning <0x%.8x>\n", status));
     return (status);
  }



long _WFFupdate_state_toggles (form, g_label, mcf_label, ptr)
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

     static char *fname = "_WFFupdate_state_toggles";

     _NFIdebug ((fname, "g_label   = <%d>\n", g_label));
     _NFIdebug ((fname, "mcf_label = <%d>\n", mcf_label));


     /* Get the number of rows from the MCF (the state_list may
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

     /* Check to see if a state is selected */

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
         /* No row has been selected.  This is probably a new state */

         _NFIdebug ((fname, " returning SUCCESS\n"));
         return (NFI_S_SUCCESS);
      }

     /* find the row in the state_list to update */

     for (i = 0; i < ptr->num_states; ++i)
      {
         if ((ptr->state_list[i].row == row) &&
             (strcmp (ptr->state_list[i].status, WFF_DROP) != 0))
          {
             s_row = i;
             break;
          }
      }

     _NFIdebug ((fname, "s_row   = <%d>\n", s_row));

     switch (g_label)
      {
         case MANDATORY_TOGGLE:

            /* if the min_no_signoffs is 0 then signoffs are not allowed.
               set the mandatory/majority field to "".  Otherwise get the
               state of the toggle and set the value accordingly */

            if (strcmp (ptr->state_list[s_row].no_signoffs, "0") != 0)
             { 
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
                   strcpy (s_state, "MJ");   /* Majority */
                else
                   strcpy (s_state, "MN");   /* Mandatory */
             }
            else
               strcpy (s_state, "");
     
            strcpy (ptr->state_list[s_row].majority, s_state); 

            /* Update the MCF */

/* IGI Intel Solaris Port - CN 31/5/95 */
#if defined(OS_SCO_UNIX) || defined(OS_INTELSOL)
	/* To set font for SCO - CRN 25 Feb 94	*/
	FIg_set_font(form, mcf_label, "7x13bold", 15);
#endif
            status = (long) FIfld_set_text (form, mcf_label, row, 3, 
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

         case FROM_STATE_TOGGLE:

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
               strcpy (s_state, "Y");  
            else
               strcpy (s_state, "N");  

            strcpy (ptr->state_list[s_row].trans_from, s_state); 

            /* Update the MCF */

/* IGI Intel Solaris Port - CN 31/5/95 */
#if defined(OS_SCO_UNIX) || defined(OS_INTELSOL)
	/* To set font for SCO - CRN 25 Feb 94	*/
	FIg_set_font(form, mcf_label, "7x13bold", 15);
#endif
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

         case TO_STATE_TOGGLE:

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
               strcpy (s_state, "Y");  
            else
               strcpy (s_state, "N");  

            strcpy (ptr->state_list[s_row].trans_to, s_state); 

            /* Update the MCF */

/* IGI Intel Solaris Port - CN 31/5/95 */
#if defined(OS_SCO_UNIX) || defined(OS_INTELSOL)
	/* To set font for SCO - CRN 25 Feb 94	*/
	FIg_set_font(form, mcf_label, "7x13bold", 15);
#endif
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

         default:
            /* Bad gadget label.  This case should not occur... */

            _NFIdebug ((fname, " returning SUCCESS\n"));
            status = NFI_S_SUCCESS;
         break; 
      }

     /* Put up a working message */

     /* _WFFmessage (NFI_I_MODIFY_STATE, "%s", s_name); */

     if (strcmp (ptr->state_list[s_row].status, "") == 0)
        strcpy (ptr->state_list[s_row].status, WFF_MODIFY); 

     /* set the row to be in the viewing area */

     _WFFset_active_row (form, STATE_LIST_MCF, row, 1);

     status = NFI_S_SUCCESS;
     _NFIdebug ((fname, " returning <0x%.8x>\n", status));
     return (status);
  }

long _WFFdelete_class_express (g_label, form)
  int      g_label;
  Form     form;
{
    long   status;
    int    i;
    int    k;
    int    j;
    int    rows;
    int    sel_flag;
    int    modify_workflow = FALSE;
    char   class_name[NFM_CLASSNAME+1];
    char   action[10];

    WFFadd_ptr ptr;

    static char *fname = "_WFFdelete_class_express";

    _NFIdebug(( fname, "%s\n", "Entering ..." ));

   /*  Pull out the pointer to the data  */

   if ((status = (long) FIf_get_user_pointer
      (form, (char *) &ptr)) != FI_SUCCESS)
    {
       _NFIdebug ((fname, "FIf_get_user_pointer = <%d>\n", status));
       ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIf_get_user_pointer", status);
       _NFIdebug ((fname, " returning <0x%.8x>\n", NFI_E_FORM));
       return (NFI_E_FORM);
    }

    /*  Get the selected classes to delete */
    _NFIdebug(( fname, "%s\n", "Get number of class rows " ));

    status = (long) FIfld_get_num_rows( form, g_label, &rows );
    if (status != FI_SUCCESS)
    {
	 _WFFfree_add_ptr (ptr);
         _NFIdebug ((fname, "FIfld_get_num_rows = <%d>\n", status));
         ERRload_struct (NFI, NFI_E_FORM, "%s%d","FIfld_get_num_rows", status);
         _NFIdebug ((fname, " returning FAILURE\n"));
         return (NFI_E_FORM);
    } 

    if (ptr->num_classes == 0)
    {
	 _WFFfree_add_ptr (ptr);
         FIfld_set_num_rows (form, g_label, 0); 
         _WFFmessage (NFI_W_NO_CLASSES_SELECTED, NULL);
         _NFIdebug ((fname, "No rows exist in the CLASS_LIST_SCF\n"));
         return (NFI_S_SUCCESS);
    } 

    if (rows == 0)
    {
	 _WFFfree_add_ptr (ptr);
         _WFFmessage (NFI_W_NO_CLASSES_SELECTED, NULL);
         _NFIdebug ((fname, "No rows exist in the CLASS_LIST_SCF\n"));
         return (NFI_S_SUCCESS);
    } 

    for( i = 0; i < rows; ++i )
    {
	/*  See if this class is selected for deletion */

	status = (long) FIfld_get_select( form, g_label, i, 0, &sel_flag);
        if (status != FI_SUCCESS)
        {
             _NFIdebug ((fname, "FIfld_get_select = <%d>\n", status));
             ERRload_struct (NFI, NFI_E_FORM, "%s%d",
                             "FIfld_get_select", status);
             _WFFfree_add_ptr (ptr);
             _NFIdebug ((fname, " returning FAILURE\n"));
             return (NFI_E_FORM);
        } 

	if( sel_flag )
	{
	    /*  Get the class name from the field */

	    status = _WFFget_data_from_field( form, g_label, i, 0,
			class_name, NFM_CLASSNAME );
	    if (status != NFI_S_SUCCESS)
	    {
	        _NFIdebug ((fname, "WFFget_data_from_field  <0x%.8x>\n", 
				status));
	        _NFIdebug ((fname, " returning FAILURE\n"));
  	        _WFFfree_add_ptr (ptr);
	        return (status);
	    }
	    
	    strcpy( action, WFF_DROP );
	    
	    /*  Mark the class for deletion */
	    for( k = 0; k < ptr->num_classes; ++k )
	    {
		if( strcmp( ptr->class_list[k].class_name, class_name ) == 0 )
		{
		    _NFIdebug(( fname, "Current status <%s> for class <%s>\n",
				ptr->class_list[k].status, class_name ));
		    if( strcmp( ptr->class_list[k].status, WFF_ADD ) == 0 )
		    {
			/*  User is trying to DROP a class that was added
			 *  in this session -- i.e., it is not in the DB
			 *  yet.
			 */
			strcpy( action, "" );
		    }
		    strcpy( ptr->class_list[k].status, action );
		   _NFIdebug(( fname, "Action for class <%s> -> <%s>\n", 
				class_name, action ));
		}
	    }	    
	    
 	    /*  Search for any accesses for the selected class */

	    for( k = 0; k < ptr->num_access; ++k )
	    {
		if( strcmp( ptr->access_list[k].class_name, class_name ) == 0 )
		{
		    strcpy( ptr->access_list[k].status, action );
		    _NFIdebug(( fname, "Action for access_list[%d] -> <%s>\n",
				 k, action ));
		    for( j=0; j<ptr->access_list[k].num_trans; ++j )
		    {
			_NFIdebug(( fname, "Action for access_list[%d].trans_ptr[%d] -> <%s>\n", k, j, action ));
			strcpy( ptr->access_list[k].trans_ptr[j].status,
				action );
		    }
		}
	    }
            modify_workflow = 1;

	    break;

	} /* end if( sel_flag ) */

    } /* end for( i=0; i<rows; ++i ) */

    /*  If something was marked for deletion - Do it now */

    if( modify_workflow )
    {
        WFFglobal.working_no = NFI_I_MODIFY_WORKFLOW;
        _WFFmessage (WFFglobal.working_no, NULL);

        _NFIdebug ((fname, "calling WFGadd_workflow...\n"));

        status = WFGadd_workflow (WFFglobal.user_id, ptr->workflow_name,
                        ptr->old_wf_name, ptr->workflow_desc, ptr->num_classes,
                        ptr->class_list, ptr->num_states, ptr->state_list,
                        ptr->num_trans, ptr->trans_list, ptr->num_access, 
                        ptr->access_list);

        if (status != NFM_S_SUCCESS)
        {
            _NFIdebug ((fname, "WFGadd_workflow = <0x%.8x>\n", status));
        }
        else
        {
            strcpy (WFFglobal.workflow, ptr->workflow_name);
        }

        /*  Erase the message  */

        _WFFerase_message ();

        /*  Save the return status  */

        WFFglobal.cmd_status = status;

    }
    /*  Set the next state  */

    status = WFFset_to_state ();
    if( status != NFI_S_SUCCESS )
        _NFIdebug ((fname, "WFFset_to_state = <0x%.8x>\n", status));

    if( modify_workflow )
        _WFFfree_add_ptr (ptr);

    return( NFI_S_SUCCESS );
}

long _WFFdelete_state_express (g_label, form)
    int         g_label; 
    Form        form;
{
    long   status;
    int    i;
    int    k;
    int    j;
    int    rows;
    int    sel_flag;
    int    drop_access;
    int    modify_workflow;
    char   state_name[NFM_STATENAME+1];
    char   action[10];
    long   WFFadd_workflow();

    WFFadd_ptr ptr;

    static char *fname = "_WFFdelete_state_express";

    _NFIdebug(( fname, "%s\n", "Entering ..." ));

    modify_workflow = FALSE;
    
    /*  Pull out the pointer to the data  */

    if ((status = (long) FIf_get_user_pointer
	 (form, (char *) &ptr)) != FI_SUCCESS)
    {
       _NFIdebug ((fname, "FIf_get_user_pointer = <%d>\n", status));
       ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIf_get_user_pointer", status);
       _NFIdebug ((fname, " returning <0x%.8x>\n", NFI_E_FORM));
       return (NFI_E_FORM);
    }

    /*  Get the selected states to delete */
    status = (long) FIfld_get_num_rows( form, g_label, &rows );
    if (status != FI_SUCCESS)
    {
         _NFIdebug ((fname, "FIfld_get_num_rows = <%d>\n", status));
         ERRload_struct (NFI, NFI_E_FORM, "%s%d","FIfld_get_num_rows", status);
         _NFIdebug ((fname, " returning FAILURE\n"));
         return (NFI_E_FORM);
    } 

    if (ptr->num_states == 0)
    {
         FIfld_set_num_rows (form, g_label, 0); 
         _WFFmessage (NFI_W_NO_STATES_SELECTED, NULL);
         _NFIdebug ((fname, "No rows exist in the STATE_LIST_SCF\n"));
         return (NFI_S_SUCCESS);
    } 

    if (rows == 0)
    {
         _WFFmessage (NFI_W_NO_STATES_SELECTED, NULL);
         _NFIdebug ((fname, "No rows exist in the STATE_LIST_SCF\n"));
         return (NFI_S_SUCCESS);
    } 

    for( i = 0; i < rows; ++i )
    {
	/*  See if this state is selected for deletion */
	_NFIdebug(( fname, "%s\n", "Find states selected to delete" ));
	status = (long) FIfld_get_select( form, g_label, i, 0, &sel_flag);
        if (status != FI_SUCCESS)
        {
             _NFIdebug ((fname, "FIfld_get_select = <%d>\n", status));
             ERRload_struct (NFI, NFI_E_FORM, "%s%d",
                             "FIfld_get_select", status);
             _NFIdebug ((fname, " returning FAILURE\n"));
             return (NFI_E_FORM);
        } 
        _NFIdebug(( fname, "Select flag <%d>\n", sel_flag ));

	if( sel_flag )
	{
	    /*  Get the state name from the field */
	    status = _WFFget_data_from_field( form, g_label, i, 0,
			state_name, NFM_STATENAME );
	    if (status != NFI_S_SUCCESS)
	    {
	        _NFIdebug ((fname, "WFFget_data_from_field  <0x%.8x>\n", 
				status));
	        _NFIdebug ((fname, " returning FAILURE\n"));
	        return (status);
	    }
 	
	    strcpy( action, WFF_DROP );

	    /*  Mark the state for deletion */
	    for( k = 0; k < ptr->num_states; ++k )
	    {
		if( strcmp( ptr->state_list[k].state_name, state_name ) == 0 )
		{
		    _NFIdebug(( fname, "Current status <%s> for state <%s>\n",
				ptr->state_list[k].status, state_name ));
		    if( strcmp( ptr->state_list[k].status, WFF_ADD ) == 0 )
		    {	
			/*  User is trying to DROP a state that hasn't been
			 *  added to the database yet.
			 */
			strcpy( action, "" );			 
		    }
		    strcpy( ptr->state_list[k].status, action );
		    modify_workflow = TRUE;
		}
	    }	    

 	    /*  Search for any accesses using the selected state */
	    for( k = 0; k < ptr->num_access; ++k )
	    {
		drop_access = 0;
		for( j=0; j<ptr->access_list[k].num_trans; ++j )
     		{
		    if( (strcmp( ptr->access_list[k].trans_ptr[j].from_state,
				 state_name ) == 0 ) ||
			(strcmp( ptr->access_list[k].trans_ptr[j].to_state,
				 state_name ) == 0 ) )
		    {
		        _NFIdebug(( fname, "Marking transition <%s> for class <%s> to DROP\n",ptr->access_list[k].trans_ptr[j].trans_name,ptr->access_list[k].class_name ));
 		        drop_access = 1;
			strcpy( ptr->access_list[k].trans_ptr[j].status,
				action );
		    }
		    if( drop_access )
			strcpy( ptr->access_list[k].status, action );
	        }
	    }
	    
	    /*  Search for any transitions using the selected state */
            for (k = 0; k < ptr->num_trans; ++k)
            {
                if((strcmp (ptr->trans_list[k].from_state,state_name) == 0)||
                   (strcmp (ptr->trans_list[k].to_state, state_name) == 0))
                {
		    _NFIdebug(( fname, "Marking transition <%s> to DROP\n",
			ptr->trans_list[k].trans_name ));
		    strcpy( ptr->trans_list[k].status, action );
                }
            }

	    break;
  
	} /* end if( sel_flag ) */

    } /* end for( i=0; i<rows; ++i ) */

    /*  Call NFM or WFG to do the command  */

    _NFIdebug ((fname, "calling WFGadd_workflow...\n"));

    if( modify_workflow )
    {
       WFFglobal.working_no = NFI_I_MODIFY_WORKFLOW;
       _WFFmessage (WFFglobal.working_no, NULL);

       status = WFGadd_workflow (WFFglobal.user_id, ptr->workflow_name,
                        ptr->old_wf_name, ptr->workflow_desc, ptr->num_classes,
                        ptr->class_list, ptr->num_states, ptr->state_list,
                        ptr->num_trans, ptr->trans_list, ptr->num_access, 
                        ptr->access_list);

        if (status != NFM_S_SUCCESS)
        {
            _NFIdebug ((fname, "WFGadd_workflow = <0x%.8x>\n", status));
        }
        else
        {
            strcpy (WFFglobal.workflow, ptr->workflow_name);
        }
   
        /*  Erase the message  */

        _WFFerase_message ();

        /*  Save the return status  */

        WFFglobal.cmd_status = status;
  
    }
    /*  Set the next state  */

    status = WFFset_to_state ();
    if( status != NFI_S_SUCCESS )
        _NFIdebug ((fname, "WFFset_to_state = <0x%.8x>\n", status));

    if( modify_workflow )
	_WFFfree_add_ptr( ptr );

    _NFIdebug(( fname, "%s\n", "Returning Success" ));

    return( NFI_S_SUCCESS );
}
