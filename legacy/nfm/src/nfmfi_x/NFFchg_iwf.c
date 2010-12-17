
/* machine.h included to take care of platform variencies MVR 23 Dec 1993 */
#include "machine.h"

#include "NFF.h"
#include "NFFtimestamp.h"
#include "NFFchg_wf.h"

#define  WF_MESSAGE_FIELD   13

/*****************************************************************************
 *                                                                           *
 *   This function is used to change the workflow of an item.                *
 *                                                                           *
 *****************************************************************************/

/*  Global NFF structure  */

extern struct NFFglobal_st NFFglobal;

long NFFchange_item_workflow ()
  {
    long    status;
    char    title[NFF_MAX_MESSAGE];
    MEMptr  syn_list = NULL;
    char    **data;
    NFFiwf_ptr    ptr;        /*  Pointer to the change item wf structure  */

    static  char *fname = "NFFchange_item_workflow";

    _NFIdebug ((fname, " Function entered\n"));

    /* Malloc memory for the change item wf ptr */

    if ((ptr = (NFFiwf_ptr) malloc (sizeof (struct NFFchangewf_st))) == NULL)
      {
        _NFIdebug ((fname,
            "malloc failed; size = <%d>\n", sizeof (struct NFFchangewf_st)));
        ERRload_struct (NFI, NFI_E_MALLOC, "%d",
                        sizeof (struct NFFchangewf_st));
        NFFglobal.status = NFI_E_MALLOC;
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_MALLOC);
      }

    ptr->type = 0;
    ptr->done = FALSE;
    strcpy (ptr->workflow, "");
    strcpy (ptr->acl, "");
    ptr->acl_no = 0;
    strcpy (ptr->state, "");
    ptr->state_no = 0;
    ptr->wf_list = NULL;
    ptr->state_list = NULL;

    NFFglobal.NFMRfunction[0] = NFMRchange_wf_item;

    NFFform_message (CURRENT_LABEL, NFI_I_RETRIEVE, NULL);

    /* Call the NFMRget_wf_and_completed_acl_list function to get the
       list of item workflows and the ACL's associated with them        */

    status = NFMRget_wf_and_completed_acl_list (&syn_list, &(ptr->wf_list));
    if (status != NFM_S_SUCCESS)
      {
        MEMclose (&syn_list);
        _NFIdebug ((fname,
              " NFMRget_wf_and_completed_acl_list : status = <%d>\n", status));
        NFFerase_message ();
        _NFFfree_chgwf (NULL, ptr);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }
    MEMclose (&syn_list);
    syn_list = NULL;

    if ((ptr->wf_list)->rows <= 0)
     {
        status = NFI_E_NO_WF;
        _NFIdebug ((fname, "No Item Workflows exist : status = <0x%.8x>\n",
                    status));
        NFFerase_message ();
        _NFFfree_chgwf (NULL, ptr);
        ERRload_struct (NFI, status, NULL);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
     }

    if ((status = MEMbuild_array (ptr->wf_list)) != MEM_S_SUCCESS)
      {
        _NFIdebug ((fname, "MEMbuild_array = <0x%.8x>\n", status));
        NFFerase_message ();
        _NFFfree_chgwf (NULL, ptr);
        ERRload_struct (NFI, NFI_E_MEM, "%s%x", "MEMbuild_array", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_MEM);
      }

    /* use the first workflow/ACL combination in the list and get the
       states for it.                                                 */

    data = (char **) ptr->wf_list->data_ptr;
    strcpy (ptr->workflow, data[0]); 
    strcpy (ptr->acl, data[1]);
    ptr->acl_no = atol (data[2]);

    status = NFMRget_state_list_for_workflow (data[0], &syn_list,
                                              &(ptr->state_list));
    if (status != NFM_S_SUCCESS)
      {
        MEMclose (&syn_list);
        _NFIdebug ((fname,
              " NFMRget_wf_and_completed_acl_list : status = <%d>\n", status));
        NFFerase_message ();
        _NFFfree_chgwf (NULL, ptr);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }
    MEMclose (&syn_list);
    syn_list = NULL;

    if ((status = MEMbuild_array (ptr->state_list)) != MEM_S_SUCCESS)
      {
        _NFIdebug ((fname, "MEMbuild_array = <0x%.8x>\n", status));
        NFFerase_message ();
        _NFFfree_chgwf (NULL, ptr);
        ERRload_struct (NFI, NFI_E_MEM, "%s%x", "MEMbuild_array", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_MEM);
      }

    data = (char **) ptr->state_list->data_ptr;
    strcpy (ptr->state, data[0]); 
    ptr->state_no = atol (data[2]);

    if (_NFMdebug_st.NFIdebug_on)
      {
        MEMprint_buffer ("workflow_list", ptr->wf_list,
            _NFMdebug_st.NFIdebug_file);
        MEMprint_buffer ("state_list", ptr->state_list,
            _NFMdebug_st.NFIdebug_file);
      }

    /*  Load in the CHANGE_ITEM_WF_FORM form  */

    if ((status = (long) FIf_new (CHANGE_ITEM_WF_LABEL, CHANGE_ITEM_WF_FORM,
        _NFFnotify, &(NFFglobal.current_form))) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIf_new = <%d>\n", status));
        NFFerase_message ();
        _NFFfree_chgwf (NULL, ptr);
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIf_new", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    /*  Load the data from the wf_list into the wf mcf. */

    status = _NFFload_wf_data (NFFglobal.current_form, WF_ACL_MCF,
                               ptr->wf_list); 
    if (status != NFI_S_SUCCESS)
     {
        _NFIdebug ((fname, "_NFFload_wfdata = <0x%.8x>\n", status));
        NFFerase_message ();
        _NFFfree_chgwf (&NFFglobal.current_form, ptr);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
     }

    /*  Load the data from the state_list into the state mcf. */

    status = _NFFload_state_data (NFFglobal.current_form, WF_STATE_MCF, 
                                  ptr->state_list); 
    if (status != NFI_S_SUCCESS)
     {
        _NFIdebug ((fname, "_NFFload_stata_data = <0x%.8x>\n", status));
        NFFerase_message ();
        _NFFfree_chgwf (&NFFglobal.current_form, ptr);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
     }

    /*  Store a pointer to the data in the form  */

    if ((status = (long) FIf_set_user_pointer
        (NFFglobal.current_form, (char *) ptr)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIf_set_user_pointer = <%d>\n", status));
        NFFerase_message ();
        _NFFfree_chgwf (&NFFglobal.current_form, ptr);
        ERRload_struct
            (NFI, NFI_E_FORM, "%s%d", "FIf_set_user_pointer", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    /*  Erase the message  */

    NFFerase_message ();

    /*  Center the form  */

    if ((status = _NFFcenter_form
        (NFFglobal.current_form, -1, Y_FORM_POS)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFcenter_form = <0x%.8x>\n", status));
        _NFFfree_chgwf (&NFFglobal.current_form, ptr);
        _NFIdebug ((fname, " returning %d\n", status));
        return (status);
      }

    /*  Set the title  */

    if ((status = (long) UMSGetByNum (title, NFT_P_CHANGE_ITEM_WF,
                                      NULL)) != UMS_S_SUCCESS)
     {
        _NFIdebug ((fname, "UMSGetByNum = <0x%.8x>\n", status));
        _NFIdebug ((fname, "defaulting title\n"));
        strcpy (title, "Change workflow of the selected items");
     }

    if ((status = (long) FIg_set_text
        (NFFglobal.current_form, CHG_WF_TITLE, title)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIg_set_text = <%d>\n", status));
        _NFFfree_chgwf (&NFFglobal.current_form, ptr);
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_set_text", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    /* select the first workflow and the first state to selected */

    FImcf_set_select (NFFglobal.current_form, WF_ACL_MCF, 0, TRUE);
    FImcf_set_select (NFFglobal.current_form, WF_STATE_MCF, 0, TRUE);
 

    /*  Display the form  */

    if ((status = (long) FIf_display
        (NFFglobal.current_form)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIf_display = <%d>\n", status));
        _NFFfree_chgwf (&NFFglobal.current_form, ptr);
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIf_display", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    _NFIdebug ((fname, " returning SUCCESS\n"));
    return (NFI_S_SUCCESS);
  }

long _NFFchange_item_wf_notify (g_label, form)
  int       g_label;
  Form      *form;
  {
    int     working_message = 0;
    int     error_message;
    long    status;
    char    help_command[15];

    static    char *fname = "_NFFchange_item_wf_notify";

    NFFiwf_ptr    ptr;

    _NFIdebug ((fname, "g_label = %d\n", g_label));

    strcpy (help_command, NFI_M_CHANGE_WORKFLOW_OF_ITEM); 

    /*  Pull out the pointer to the structure  */

    if ((status = (long) FIf_get_user_pointer
        (*form, (char *) &ptr)) != FI_SUCCESS)
     {
        _NFIdebug ((fname, "FIf_get_user_pointer = <%d>\n", status));
        ERRload_struct
            (NFI, NFI_E_FORM, "%s%d", "FIf_get_user_pointer", status);
        _NFIdebug ((fname, " returning <0x%.8x>\n", NFI_E_FORM));
        return (NFI_E_FORM);
     }

    /* Clear out the message strip */

    NFFform_message (CURRENT_LABEL, NFI_S_CLEAR_MSG, NULL);

    working_message = NFI_I_CHANGE_ITEM_WF;
    error_message = NFI_E_CHANGE_ITEM_WF;

    status = NFI_S_SUCCESS;

    switch (g_label)
      {
        case FI_HELP:

            if (status = _NFFhelp_topic (help_command))
              {
                _NFIdebug ((fname, "_NFFhelp_topic = <%d>\n", status));
                ERRload_struct (NFI, NFI_E_HELP, "%s%d", "_NFFhelp_topic",
                                status);
                status = NFI_E_HELP;
              }

        break;

        case FI_CANCEL:

            /*  Load the global error structure  */

            ERRload_struct (NFI, NFI_W_COMMAND_CANCELLED, NULL);
            NFFglobal.status = NFI_W_COMMAND_CANCELLED;

            /*  Set the next state  */

            if ((status = NFFset_to_state ()) != NFI_S_SUCCESS)
                _NFIdebug ((fname, "NFFset_to_state = <0x%.8x>\n", status));

            /*  Close all allocated buffers and delete the form  */

            _NFFfree_chgwf (form, ptr);
            ptr = NULL; 

        break;

        case FI_ACCEPT:

            /*  Put up a message  */

            NFFform_message (CURRENT_LABEL, working_message, "%s%s%s",
                        NFFglobal.item, NFFglobal.revision, NFFglobal.catalog);

            /*  Call NFMR to process the item  */

            _NFIdebug ((fname, "calling NFMR function ...\n"));

            /* change the workflow of the active data */

            status = (long) NFFglobal.NFMRfunction[0] (NFFglobal.catalog,
                                NFFglobal.item, NFFglobal.revision,
                                ptr->workflow, ptr->acl, ptr->acl_no,
                                ptr->state, ptr->state_no);
            if (status != NFM_S_SUCCESS)
                _NFIdebug ((fname, "NFMRfunction = <0x%.8x>\n", status));

            /*  Erase the message  */

            NFFerase_message ();

            /*  Save the return status  */

            NFFglobal.status = status;

            /* process the list if there is a list.  This will free up the form
               and ptr.                                                      */ 

            _NFFprocess_change_wf_list (form, CHANGE_ITEM_WF_LABEL, FI_ACCEPT,
                                        ptr);

        break;

        case WF_ACL_MCF:

            status = _NFFprocess_wf_list (*form, ptr);
            if (status != NFI_S_SUCCESS)
               _NFIdebug ((fname, " _NFFprocess_wf_list <0x%.8x>\n",
                           status));
        break;

        case WF_STATE_MCF:

            status = _NFFprocess_state_list (*form, ptr);
            if (status != NFI_S_SUCCESS)
               _NFIdebug ((fname, " _NFFprocess_state_list <0x%.8x>\n",
                           status));
        break;

        default:
            _NFIdebug ((fname, " unknown gadget <%d>\n", g_label));
        break; 
      }

    _NFIdebug ((fname, " returning <0x%.8x>\n", status));
    return (status);
  }


long _NFFload_wf_data (form, label, data_list)
  Form      form;
  int       label;
  MEMptr    data_list;
  {
    auto    int     vis_chars;
    auto    int     attr_mask;
    auto    int     row, col;
    auto    int     row_offset;
    auto    int     status;
    auto    char    **data_ptr;
    auto    short   enable_scrollbar = FALSE;
    static  char    *fname = "_NFFload_wf_data";

    _NFIdebug ((fname, "label = <%d>\n", label));

    /*  Set the number of rows to 0 to clear out the field  */

    _NFIdebug ((fname,
        "Setting the number of rows to 0 to clear out the field\n"));

    if ((status = FIfld_set_num_rows (form, label, 0)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIfld_set_num_rows = <%d>\n", status));
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_num_rows", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    /*  Set the number of rows  */

    _NFIdebug ((fname, "Setting the number of rows to %d\n", data_list->rows));

    if ((status = FIfld_set_num_rows
        (form, label, data_list->rows)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIfld_set_num_rows = <%d>\n", status));
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_num_rows", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    data_ptr = (char **) data_list->data_ptr;

/* Intel Solaris Port -IGI CN 31/5/95   */ 
#if defined(OS_SCO_UNIX)|| defined(OS_INTELSOL) 
    /* work around change - to set font for SCO - SSRS 4 Feb 94 */
    FIg_set_font( form, label, "7x13bold", 15 );
#endif

    for (col = 0; col < data_list->columns - 1; ++col)
      {
        FIfld_get_num_vis_chars (form, label, col, &vis_chars);

        for (row = 0; row < data_list->rows; ++row)
          {
            row_offset = row * data_list->columns;
            if ((status = FIfld_set_text (form, label,
                row, col, data_ptr[col + row_offset], FALSE)) != FI_SUCCESS)
              {
                _NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
                ERRload_struct (NFI,
                    NFI_E_FORM, "%s%d", "FIfld_set_text", status);
                _NFIdebug ((fname, " returning FAILURE\n"));
                return (NFI_E_FORM);
              }

            /*  See if the character scroll bars need to be enabled  */

            if (strlen (data_ptr[col + row_offset]) > vis_chars)
                enable_scrollbar = TRUE;
          }

        FIfld_get_attr (form, label, col, &attr_mask);

        if (enable_scrollbar == TRUE)
          {
            /*  OR in the character scroll bars attribute  */

            _NFIdebug ((fname, "enabling character scrolling\n"));
            attr_mask |= FI_HORT_SCROLL | FI_DISPLAY_HSCROLL;
            enable_scrollbar = FALSE;
          }
        else
          {
            /*  Take out the character scroll bars attribute  */

            _NFIdebug ((fname, "disabling character scrolling\n"));
            if (attr_mask & (FI_HORT_SCROLL | FI_DISPLAY_HSCROLL))
                attr_mask ^= FI_HORT_SCROLL | FI_DISPLAY_HSCROLL;
          }

        FIfld_set_attr (form, label, col, attr_mask);
      }

    /*  Enable the scroll bar, if necessary  */

    _NFFenable_scrollbar (form, label, FALSE);

    _NFIdebug ((fname, "returning SUCCESS <0x%.8x>\n", NFI_S_SUCCESS));
    return (NFI_S_SUCCESS);
  }


long _NFFload_state_data (form, label, data_list)
  Form      form;
  int       label;
  MEMptr    data_list;
  {
    auto    int     buffer_col;
    auto    int     row, col;
    auto    int     row_offset;
    auto    int     attr_mask;
    auto    int     vis_chars;
    auto    int     status;
    auto    char    **data_ptr;
    auto    short   enable_scrollbar = FALSE;
    static  char    *fname = "_NFFload_state_data";

    _NFIdebug ((fname, "label = <%d>\n", label));

    /*  Set the number of rows to 0 to clear out the field  */

    _NFIdebug ((fname,
        "Setting the number of rows to 0 to clear out the field\n"));

    if ((status = FIfld_set_num_rows (form, label, 0)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIfld_set_num_rows = <%d>\n", status));
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_num_rows", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    /*  Set the number of rows  */

    _NFIdebug ((fname, "Setting the number of rows to %d\n", data_list->rows));

    if ((status = FIfld_set_num_rows
        (form, label, data_list->rows)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIfld_set_num_rows = <%d>\n", status));
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_num_rows", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    data_ptr = (char **) data_list->data_ptr;

/* Intel Solaris Port -IGI CN 31/5/95   */ 
#if defined(OS_SCO_UNIX) || defined(OS_INTELSOL) 
    /* work around change - to set font for SCO - SSRS 4 Feb 94 */
    FIg_set_font( form, label, "7x13bold", 15 );
#endif

    col = 0;
    for (buffer_col = 0; buffer_col < data_list->columns; ++buffer_col)
      {
        /*  Skip over the third column in the buffer  */

        if (buffer_col == 2) continue;

        FIfld_get_num_vis_chars (form, label, col, &vis_chars);

        for (row = 0; row < data_list->rows; ++row)
          {
            row_offset = row * data_list->columns;
            if ((status = FIfld_set_text (form, label, row, col,
                data_ptr[buffer_col + row_offset], FALSE)) != FI_SUCCESS)
              {
                _NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
                ERRload_struct (NFI,
                    NFI_E_FORM, "%s%d", "FIfld_set_text", status);
                _NFIdebug ((fname, " returning FAILURE\n"));
                return (NFI_E_FORM);
              }

            /*  See if the character scroll bars need to be enabled  */

            if (strlen (data_ptr[buffer_col + row_offset]) > vis_chars)
                enable_scrollbar = TRUE;
          }

        FIfld_get_attr (form, label, col, &attr_mask);

        if (enable_scrollbar == TRUE)
          {
            /*  OR in the character scroll bars attribute  */

            _NFIdebug ((fname, "enabling character scrolling\n"));
            attr_mask |= FI_HORT_SCROLL | FI_DISPLAY_HSCROLL;
            enable_scrollbar = FALSE;
          }
        else
          {
            /*  Take out the character scroll bars attribute  */

            _NFIdebug ((fname, "disabling character scrolling\n"));
            if (attr_mask & (FI_HORT_SCROLL | FI_DISPLAY_HSCROLL))
                attr_mask ^= FI_HORT_SCROLL | FI_DISPLAY_HSCROLL;
          }

        FIfld_set_attr (form, label, col, attr_mask);

        ++col;
      }

    /*  Enable the scroll bar, if necessary  */

    _NFFenable_scrollbar (form, label, FALSE);

    _NFIdebug ((fname, " returning SUCCESS\n"));
    return (NFI_S_SUCCESS);
  }


long _NFFprocess_wf_list (form, ptr)
  Form        form;
  NFFiwf_ptr  ptr;
  {
    int     i, num_rows = -1;
    int     r_pos, sel_flag;
    int     offset = 0;      /* workflow_name offset */
    long    status = NFI_S_SUCCESS;
    char    text[NFM_WORKFLOWNAME+1];
    char    text1[NFM_ACLNAME+1];
    char    **data;
    MEMptr  syn_list = NULL;

    static  char *fname = "_NFFprocess_wf_list";

    _NFIdebug ((fname, " Function entered.\n"));

    strcpy (text, "");

    /*  Get the number of rows from the list  */

    num_rows = (ptr->wf_list)->rows;

    _NFIdebug ((fname, "num_rows = <%d>\n", num_rows));

    for (i = 0; i < num_rows; ++i)
     {
        /* get the selected row and the selected text for the WF */

        if ((status = (long) FIfld_get_text (form, WF_ACL_MCF, i, offset,
                       sizeof(text),text, &sel_flag, &r_pos)) != FI_SUCCESS)
         {
            _NFIdebug ((fname, "FIfld_get_text = <%d>\n", status));
            ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_get_text", status);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_FORM);
         }
 
        if (sel_flag)
         {
           /* get the selected text for the ACL */

           if ((status = (long) FIfld_get_text (form, WF_ACL_MCF, i, offset+1,
                 sizeof(text1), text1, &sel_flag, &r_pos)) != FI_SUCCESS)
           {
              _NFIdebug ((fname, "FIfld_get_text = <%d>\n", status));
              ERRload_struct(NFI,NFI_E_FORM, "%s%d", "FIfld_get_text", status);
              _NFIdebug ((fname, " returning FAILURE\n"));
              return (NFI_E_FORM);
           }

           if (strcmp (text, ptr->workflow) != 0)
            {
               /* Put up the retieve message */

               NFFform_message (CURRENT_LABEL, NFI_I_RETRIEVE, NULL);

               /* Get the new state_list */
 
               MEMclose (&(ptr->state_list));
               ptr->state_list = NULL;
               status = NFMRget_state_list_for_workflow (text, &syn_list,
                                                         &(ptr->state_list));
               if (status != NFM_S_SUCCESS)
                {
                  MEMclose (&syn_list);
                  NFFerase_message();
                  _NFIdebug ((fname, 
                     " NFMRget_state_list_for_workflow : status = <%d>\n",
                              status));
                  _NFIdebug ((fname, " returning FAILURE\n"));
                  return (status);
                }

               MEMclose (&syn_list);
               syn_list = NULL;

               if ((status = MEMbuild_array (ptr->state_list)) != MEM_S_SUCCESS)
                {
                  _NFIdebug ((fname, "MEMbuild_array = <0x%.8x>\n", status));
                  NFFerase_message();
                  ERRload_struct (NFI, NFI_E_MEM, "%s%x", "MEMbuild_array",
                                  status);
                  _NFIdebug ((fname, " returning FAILURE\n"));
                  return (NFI_E_MEM);
                }

               status = _NFFload_state_data (form, WF_STATE_MCF,
                                             ptr->state_list);
               if (status != NFI_S_SUCCESS)
                {
                  NFFerase_message();
                   _NFIdebug ((fname, "_NFFload_stata_data = <0x%.8x>\n",
                               status));
                   _NFIdebug ((fname, " returning FAILURE\n"));
                   return (status);
                }
               NFFerase_message();
              
               /* Set the first state to be selected */
 
               FImcf_set_select (NFFglobal.current_form, WF_STATE_MCF, 0,
                                 TRUE);
               data = (char **) (ptr->wf_list)->data_ptr;
               strcpy (ptr->acl, data[(ptr->wf_list)->columns * i + 1]);
               ptr->acl_no = atol (data[(ptr->wf_list)->columns * i + 2]);

               data = (char **) (ptr->state_list)->data_ptr;
               strcpy (ptr->state, data[0]);
               ptr->state_no = atol (data[2]);
               strcpy (ptr->workflow, text);
            }
	    else  /* Workflow did not change but ACL may have */
	    {
	        data = (char**)(ptr->wf_list)->data_ptr;

  	        for (i=0; i< ((ptr->wf_list)->rows*(ptr->wf_list)->columns);
		      i+=(ptr->wf_list)->columns )
  	        {
		    if( (strcmp( text,  data[i] )  == 0 ) &&
	  	        (strcmp( text1, data[i+1]) == 0 ))
	  	    {
		        strcpy( ptr->acl, data[i+1] );
	  	        ptr->acl_no = atol( data[i+2] );
		        break;
		    }
	        }
	        _NFIdebug(( fname, "Chosen WF <%s>  ACL <%s>  ACL # <%d>\n",
			text, ptr->acl,	ptr->acl_no ));
	    }
           _NFIdebug ((fname, " returning Success\n"));
           return (NFI_S_SUCCESS);
        }
     }

    /* The user has unselected the workflow set it back to selected */

    for (i = 0; i < num_rows; ++i)
     {
        /* get the workflowname text */

	_NFIdebug(( fname, "Unselected the workflow\n" ));

        if ((status = (long) FIfld_get_text (form, WF_ACL_MCF, i, offset,
                                   21, text, &sel_flag, &r_pos)) != FI_SUCCESS)
         {
            _NFIdebug ((fname, "FIfld_get_text = <%d>\n", status));
            ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_get_text", status);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_FORM);
         }

        if (strcmp (ptr->workflow, text) == 0)
         {
	    _NFIdebug(( fname, "Set workflow as selected\n" ));

            if ((status = (long) FImcf_set_select (form, WF_ACL_MCF, i, 
                                                   TRUE)) != FI_SUCCESS)
             {
                _NFIdebug ((fname, "FImcf_set_select = <%d>\n", status));
                ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_get_text",
                                status);
                _NFIdebug ((fname, " returning FAILURE\n"));
                return (NFI_E_FORM);
             }
            break;
         }
     }
 

    _NFIdebug ((fname, " returning SUCCESS\n"));
    return (NFI_S_SUCCESS);
  }


long _NFFprocess_state_list (form, ptr)
  Form        form;
  NFFiwf_ptr  ptr;
  {
    int     i, num_rows = -1, count;
    int     r_pos, sel_flag;
    int     offset = 0;      /* state_name offset */
    long    status = NFI_S_SUCCESS;
    char    text[48];
    char    **data;

    static  char *fname = "_NFFprocess_state_list";

    _NFIdebug ((fname, " Function entered.\n"));

    strcpy (text, "");

    /*  Get the number of rows from the list  */

    num_rows = (ptr->state_list)->rows;

    _NFIdebug ((fname, "num_rows = <%d>\n", num_rows));

    for (i = 0; i < num_rows; ++i)
     {
        /* get the selected row and the selected text */

        if ((status = (long) FIfld_get_text (form, WF_STATE_MCF, i, offset,
                                   41, text, &sel_flag, &r_pos)) != FI_SUCCESS)
         {
            _NFIdebug ((fname, "FIfld_get_text = <%d>\n", status));
            ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_get_text", status);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_FORM);
         }
 
        if (sel_flag)
         {
           if (strcmp (text, ptr->state) != 0)
            {
               data = (char **) (ptr->state_list)->data_ptr;
               count = (ptr->state_list)->columns * i + 2;
               strcpy (ptr->state, text);
               ptr->state_no = atol (data[count]);
            }

           _NFIdebug ((fname, " returning Success\n"));
           return (NFI_S_SUCCESS);
        }
     }

    /* The user has unselected the state; re-select it */

    for (i = 0; i < num_rows; ++i)
     {
        /* get the statename text */

        if ((status = (long) FIfld_get_text (form, WF_STATE_MCF, i, offset,
                                   41, text, &sel_flag, &r_pos)) != FI_SUCCESS)
         {
            _NFIdebug ((fname, "FIfld_get_text = <%d>\n", status));
            ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_get_text", status);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_FORM);
         }

        if (strcmp (ptr->workflow, text) == 0)
         {
            if ((status = (long) FImcf_set_select (form, WF_STATE_MCF, i, 
                                                   TRUE)) != FI_SUCCESS)
             {
                _NFIdebug ((fname, "FImcf_set_select = <%d>\n", status));
                ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_get_text",
                                status);
                _NFIdebug ((fname, " returning FAILURE\n"));
                return (NFI_E_FORM);
             }
            break;
         }
     }

    _NFIdebug ((fname, " returning SUCCESS\n"));
    return (NFI_S_SUCCESS);
  }


void _NFFfree_chgwf (form, ptr)
  Form         *form;
  NFFiwf_ptr   ptr;
  {
    if (form != NULL)
      {
        FIf_delete (*form);
        NFFglobal.current_form = *form = NULL;
      }

    if (ptr != NULL)
      {
          MEMclose (&(ptr->wf_list));
          MEMclose (&(ptr->state_list));
          free (ptr);
          ptr = NULL;
      }

    return;
  }


void _NFFprocess_change_wf_list (current_form, f_label, g_label, ptr)
  Form   *current_form;
  int    f_label;
  int    g_label;
  NFFiwf_ptr    ptr;
  {
    auto    char    catalog[NFM_CATALOGNAME + 1];
    auto    char    item[NFM_ITEMNAME + 1];
    auto    char    revision[NFM_ITEMREV + 1];
    auto    char    set_indicator[NFM_SETINDICATOR + 1];
    auto    char    command[20];
    auto    char    s[NFF_MAX_MESSAGE];
    auto    char    error_message[NFF_MAX_MESSAGE];
    auto    int     list, row, col, num_rows;
    auto    int     sel, r_pos, error_row = 0;
    auto    int     vis_rows, attr_mask;
    auto    int     working_message = 0;
    auto    long    status;
    auto    Form    form = NULL;
    static  char    *fname = "_NFFprocess_change_wf_list";

    _NFIdebug ((fname, "f_label = <%d>\n", f_label));
    _NFIdebug ((fname, "g_label = <%d>\n", g_label));

    /* if (g_label == FI_CANCEL_BUTTON) return; */

    /*  Figure out the command string  */

    switch (f_label)
      {
        case CHANGE_ITEM_WF_LABEL:
            strcpy (command, NFI_M_CHANGE_WORKFLOW_OF_ITEM);
            working_message = NFI_I_CHANGE_ITEM_WF;
            break;

        default:
            return;
      }

    /*  Save current active data  */

    strcpy (catalog, NFFglobal.catalog);
    strcpy (item, NFFglobal.item);
    strcpy (revision, NFFglobal.revision);
    strcpy (set_indicator, NFFglobal.set_indicator);

    /*  Only load the error form if it's not already up  */

    if (NFFglobal.error_form == NULL)
      {
        /*  Load in the error form  */

        if ((status = (long) FIf_new (ERROR_FORM_LABEL,
            ERROR_FORM, _NFFnotify, &(NFFglobal.error_form))) != FI_SUCCESS)
          {
            _NFIdebug ((fname, "FIf_new = <%d>\n", status));
            ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIf_new", status);
            NFFerror_message (NFFglobal.forms[MAIN_LABEL]);
            NFFset_to_state ();
            _NFIdebug ((fname, " returning ...\n"));
            return;
          }
      }

    /*  Add the first error message to the error form  */

    ERRget_message (s);
    sprintf (error_message, "%s.%s.%s - %s",
        NFFglobal.catalog, NFFglobal.item, NFFglobal.revision, s);
    FIfld_set_text (NFFglobal.error_form,
        WF_MESSAGE_FIELD, error_row++, 0, error_message, FALSE);

    /*  Clean up the display (force the deleted form to go away)  */

    /* _NFFprocess_event (REFRESH_EVENT); */

    /*  Go thru list_items, list_setm, list_prjm for active items  */
    
    for (list = 0; list < 3; ++list)
      {
        switch (list)
          {
            case 0:
                if (NFFglobal.forms[ITEMS_LABEL] != NULL)
                    form = NFFglobal.forms[ITEMS_LABEL];
                else
                    continue;
                break;

            case 1:
                if (NFFglobal.forms[SETM_LABEL] != NULL)
                    form = NFFglobal.forms[SETM_LABEL];
                else
                    continue;
                break;

            case 2:
                if (NFFglobal.forms[PROJM_LABEL] != NULL)
                    form = NFFglobal.forms[PROJM_LABEL];
                else
                    continue;
                break;
          }

        FIfld_get_num_rows (form, MCF, &num_rows);

        for (row = 0; row < num_rows; ++row)
          {
            /*  Get the next selected row  */

            FIfld_get_select (form, MCF, row, 0, &sel);
            if (sel == FALSE) continue;

            if (list == 0)
              {
                /*  Get the selected catalog name  */

                NFFfind_mcf_attribute (form, TOP_MCF, "n_catalogname", &col);
                if (col != -1)
                  {
                    /*  There might not be a catalog name in the form  */

                    FIfld_get_text (form, MCF, row, col,
                        NFM_CATALOGNAME + 1, NFFglobal.catalog, &sel, &r_pos);
                  }

                _NFIdebug ((fname,
                    "catalog name = <%s>\n", NFFglobal.catalog));

                /*  Get the selected item name  */

                NFFfind_mcf_attribute (form, TOP_MCF, "n_itemname", &col);
                if (col != -1)
                  {
                    FIfld_get_text (form, MCF, row, col,
                        NFM_ITEMNAME + 1, NFFglobal.item, &sel, &r_pos);
                    _NFIdebug ((fname, "item name = <%s>\n", NFFglobal.item));
                  }
                else
                  {
                    /*  This is bad; they made item name non-readable  */

                    _NFIdebug ((fname,
                        "couldn't find item name; continuing\n"));
                    continue;
                  }

                /*  Get the selected item revision  */

                NFFfind_mcf_attribute (form, TOP_MCF, "n_itemrev", &col);
                if (col != -1)
                  {
                    FIfld_get_text (form, MCF, row, col,
                        NFM_ITEMREV + 1, NFFglobal.revision, &sel, &r_pos);
                    _NFIdebug ((fname,
                        "revision = <%s>\n", NFFglobal.revision));
                  }
                else
                  {
                    /*  This is bad; they made revision non-readable  */

                    _NFIdebug ((fname,
                        "couldn't find revision; continuing\n"));
                    continue;
                  }

                /*  Find out if it is a set  */

                NFFfind_mcf_attribute (form, TOP_MCF, "n_setindicator", &col);
                if (col != -1)
                  {
                    FIfld_get_text (form, MCF, row, col, NFM_SETINDICATOR + 1,
                        NFFglobal.set_indicator, &sel, &r_pos);
                    _NFIdebug ((fname,
                        "set_indicator = <%s>\n", NFFglobal.set_indicator));
                  }
                else
                  {
                    /*  This is bad; they made set indicator non-readable  */

                    _NFIdebug ((fname,
                        "couldn't find set indicator; continuing\n"));
                    continue;
                  }
              }
            else
              {
                /*  Get the selected catalog name  */

                FIfld_get_text (form, MCF, row, 0,
                    NFM_CATALOGNAME + 1, NFFglobal.catalog, &sel, &r_pos);
                _NFIdebug ((fname,
                    "catalog name = <%s>\n", NFFglobal.catalog));

                /*  Get the selected item name  */

                FIfld_get_text (form, MCF, row, 1,
                    NFM_ITEMNAME + 1, NFFglobal.item, &sel, &r_pos);
                _NFIdebug ((fname, "item name = <%s>\n", NFFglobal.item));

                /*  Get the selected item revision  */

                FIfld_get_text (form, MCF, row, 2,
                    NFM_ITEMREV + 1, NFFglobal.revision, &sel, &r_pos);
                _NFIdebug ((fname,
                    "revision = <%s>\n", NFFglobal.revision));

                if (list == 1)
                  {
                    /*  Find out if it is a set  */

                    FIfld_get_text (form, MCF, row, 3, NFM_SETINDICATOR + 1,
                        NFFglobal.set_indicator, &sel, &r_pos);
                  }
                else
                  {
                    /*  Assume all project members are NOT set members  */

                    strcpy (NFFglobal.set_indicator, "");
                  }

                _NFIdebug ((fname,
                    "set_indicator = <%s>\n", NFFglobal.set_indicator));
              }

            /*  See if this is the one that has already been processed  */

            if (((strcmp (NFFglobal.catalog, catalog)) == 0) &&
               ((strcmp (NFFglobal.item, item)) == 0) &&
               ((strcmp (NFFglobal.revision, revision)) == 0))
              {
                _NFIdebug ((fname,
                    "already processed this item; continuing ...\n"));
                continue;
              }

            /*  Timestamp the beginning of the command  */

            _NFFts_command_start ();

            ERRreset_struct ();

            NFFform_message (CURRENT_LABEL, NFI_S_CLEAR_MSG, NULL);

            /*  call the appropriate command  */

            switch (f_label)
              {
                case CHANGE_ITEM_WF_LABEL:
                   /*  Put up a message  */

                   NFFform_message (CURRENT_LABEL, working_message, "%s%s%s",
                       NFFglobal.item, NFFglobal.revision, NFFglobal.catalog); 

                   _NFIdebug ((fname, "calling NFMR function ...\n"));

                   /* change the workflow of the active data */

                   status = (long) NFFglobal.NFMRfunction[0](NFFglobal.catalog,
                                NFFglobal.item, NFFglobal.revision,
                                ptr->workflow, ptr->acl, ptr->acl_no,
                                ptr->state, ptr->state_no);
                   if (status != NFM_S_SUCCESS)
                       _NFIdebug ((fname, "NFMRfunction = <0x%.8x>\n", status));
       
                   /*  Erase the message  */
       
                   NFFerase_message ();

                   /*  Save the return status  */
       
                   NFFglobal.status = status;

                break;

                default: 
                    _NFIdebug ((fname, "Unknown label = <%d>\n", f_label));
                break;
              } 
            NFFerror_message (NFFglobal.forms[MAIN_LABEL]);

            /*  Add the error message to the error form  */

            ERRget_message (s);
            sprintf (error_message, "%s.%s.%s - %s",
                NFFglobal.catalog, NFFglobal.item, NFFglobal.revision, s);
            FIfld_set_text (NFFglobal.error_form,
                WF_MESSAGE_FIELD, error_row++, 0, error_message, FALSE);

            /*  Timestamp the end of the command  */

            _NFFts_data (("End of Command      -  %d\n", time ((long *) 0)));

            /*  Commit the data to the timestamp file  */

            _NFFts_commit ();
          }
      }

    /*  Erase the form and free up the ptr */

    if ((status = NFFset_to_state ()) != NFI_S_SUCCESS)
        _NFIdebug ((fname, "NFFset_to_state = <0x%.8x>\n", status));

    /*  Close all allocated buffers and delete the form  */

    _NFFfree_chgwf (current_form, ptr);
    ptr = NULL;

    /*  Restore previous active data  */

    strcpy (NFFglobal.catalog, catalog);
    strcpy (NFFglobal.item, item);
    strcpy (NFFglobal.revision, revision);
    strcpy (NFFglobal.set_indicator, set_indicator);

    /*  Enable the scroll bar, if necessary  */

    FIfld_get_num_rows (NFFglobal.error_form, WF_MESSAGE_FIELD, &num_rows);
    FIfld_get_num_vis_rows (NFFglobal.error_form, WF_MESSAGE_FIELD, &vis_rows);
    FIfld_get_attr (NFFglobal.error_form, WF_MESSAGE_FIELD, 0, &attr_mask);
    if (num_rows > vis_rows)
      {
        /*  OR in the vertical scroll bar attribute  */

        attr_mask |= FI_VERT_SCROLL | FI_DISPLAY_VSCROLL;
      }
    else
      {
        /*  Take out the vertical scroll bar attribute  */

        if (attr_mask & (FI_VERT_SCROLL | FI_DISPLAY_VSCROLL))
            attr_mask ^= FI_VERT_SCROLL | FI_DISPLAY_VSCROLL;
      }

    FIfld_set_attr (NFFglobal.error_form, WF_MESSAGE_FIELD, 0, attr_mask);

    /*  Display the list of errors  */

    if (error_row > 1)
      {
        /*  Display the form  */

        _NFFcenter_form (NFFglobal.error_form, -1, Y_FORM_POS);
        FIf_display (NFFglobal.error_form);
      }
    else
      {
        /*  Delete the form  */

        FIf_delete (NFFglobal.error_form);
        NFFglobal.error_form = NULL;
      }

    return;
  }

