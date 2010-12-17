#include "machine.h"
#include "WFF.h"
#include "WFFadd_wf.h"

/*  Global WFF structure  */

extern struct WFFglobal_st WFFglobal;

/********************************************************************
 *                                                                  * 
 *  Function : WFFprocess_pages                                     *
 *                                                                  * 
 *  This function is the driver for the add_workflow pages (forms)  * 
 *  The "Define Workflow" command will allow an administrator to    *
 *  Add/Delete/Modify an existing or new workflow definition.       *
 *                                                                  *
 *  If a workflow is in use currently if it has an ACL associated   *
 *  with it, the state definition can only be modified, that is     *
 *  a state cannot be added nor deleted.                            *
 *  The logic behind this is that an administrator could destroy    *
 *  the workflow definition leaving unreachable states or infinite  *
 *  loops.  This can change since the logic to modify a workflow    *
 *  definition is now in place.................                     *
 *                                                                  * 
 *  A major drawback to this command is that it will allow an       *
 *  administrator to create a workflow wherein the state definition *
 *  may not be a logical finite flow.  This command assumes that    *
 *  the person creating the workflow has already sat down and       *
 *  created a logical state diagram to follow.                      *
 *                                                                  * 
 *  Fortunately the administrator can come back later and modify    *
 *  the workflow when he/she discovers such mistakes.               *
 *                                                                  * 
 *  Currently only "Item Workflows" are allowed to be created       *
 *  and/or modified by the administrator.  This may later extend to *
 *  project workflows.                                              * 
 *                                                                  * 
 ********************************************************************/


/************************************************************************
 *                                                                      *
 *   Function:  _WFFprocess_pages                                       *
 *                                                                      *
 *   This function use the ptr->cur_page variable to tell it which form *
 *   (page) to process.                                                 *
 *                                                                      *
 ************************************************************************/

long _WFFprocess_pages (ptr)
    WFFadd_ptr   ptr;  
  {
	long	status = NFI_S_SUCCESS;
        short   cur_page;

	static	char *fname = "_WFFprocess_pages";

        _NFIdebug ((fname, "Current Page No = <%d>\n", ptr->curr_page));

        cur_page = ptr->curr_page;

        switch (cur_page)
         {
            case PAGE1 :
                 status = _WFFpage1 (ptr);
            break; 
    
            case PAGE2 :
                 status = _WFFpage2 (ptr);
            break; 
    
            case PAGE3 :
                 status = _WFFpage3 (ptr);
            break; 
    
            case PAGE4 :
                 status = _WFFpage4 (ptr);
            break; 

            default :
                 _NFIdebug ((fname, "Invalid page <%d>\n", cur_page));
            break; 
         }

	_NFIdebug ((fname, " returning SUCCESS\n"));
	return (NFI_S_SUCCESS);
  }


/****************************************************************************
 *                                                                          * 
 *  All the functions below are tools that are used by the 4 pages          *
 *                                                                          * 
 ****************************************************************************/


/****************************************************************************
 *                                                                          * 
 *  Function :  _WFFfree_add_ptr                                            *
 *                                                                          * 
 *  This function is used to delete the alloocated forms and to free up     *
 *  all memory allocated for the WFFadd_ptr structure.                      *
 *                                                                          * 
 *  Note : I/Forms FIf_delete (delete form) function will erase the form if *
 *  it is currently being displayed.                                        *
 *                                                                          * 
 ****************************************************************************/

void _WFFfree_add_ptr (ptr)
  WFFadd_ptr ptr;
  {
    int    i;
    static char *fname = "_WFFfree_add_ptr";

    _NFIdebug ((fname, " function entered.\n"));

    if (ptr)
     {
        WFFglobal.current_form = NULL;

        if (ptr->page1_form)
	{
	       _NFIdebug(( fname, "Deleting FORM_1\n" ));
               FIf_delete (ptr->page1_form);
	}
        if (ptr->page2_form)
	{
	       _NFIdebug(( fname, "Deleting FORM_2\n" ));
               FIf_delete (ptr->page2_form);
	}
        if (ptr->page3_form)
	{
	       _NFIdebug(( fname, "Deleting FORM_3\n" ));
               FIf_delete (ptr->page3_form);
	}
        if (ptr->page4_form)
	{
	       _NFIdebug(( fname, "Deleting FORM_4\n" ));
               FIf_delete (ptr->page4_form);
	}

        _NFIdebug ((fname, " deleted the forms\n"));

        if (ptr->wf_list)
           MEMclose (&(ptr->wf_list));
        if (ptr->app_list)
           MEMclose (&(ptr->app_list));
        if (ptr->comm_list)
           MEMclose (&(ptr->comm_list));
        if (ptr->class_list)
           free ((struct WFFclass_list *) ptr->class_list);
        if (ptr->state_list)
           free ((struct WFFstate_list *) ptr->state_list);
        if (ptr->trans_list)
           free ((struct WFFtrans_list *) ptr->trans_list);
        _NFIdebug ((fname, " ptr->num_access = <%d>\n", ptr->num_access));
        if (ptr->access_list)
         {
           for (i = 0; i < ptr->num_access; ++i)
           {
             _NFIdebug ((fname, " access_list[%d].num_trans = <%d>\n", i,
                         ptr->access_list[i].num_trans));
              if (ptr->access_list[i].trans_ptr)
                free ((struct WFFstatus_st *) ptr->access_list[i].trans_ptr);
             _NFIdebug ((fname, " deleted access_list[%d].trans_ptr\n", i));
           }
           free ((struct WFFaccess_st *) ptr->access_list);
         }

       free (ptr);
       ptr = NULL;
       _NFIdebug ((fname, " function exited.\n"));
       return;
     }

    _NFIdebug ((fname, " function exited.\n"));
    return;
  }



/****************************************************************************
 *                                                                          * 
 *  Function :  _WFFadjust_wf_form                                          * 
 *                                                                          * 
 *  This function will center the title on the specified form and it will   *
 *  center the form on the active screen.                                   * 
 *                                                                          * 
 ****************************************************************************/

long _WFFadjust_wf_form (form)
  Form  form;
  {
        long    status;
        static  char *fname = "_WFFadjust_wf_form";

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


/****************************************************************************
 *                                                                          * 
 *  Function :  _WFFscroll_pages                                            *
 *                                                                          * 
 *  This function will erase the current form and use the value returned    *
 *  from the users click on the scroll bars (page) to determine the next    *
 *  form (page) to make active.  It will call _WFFprocess_pages with the    *
 *  (page to make active) to process the next requested form (page).        * 
 *                                                                          * 
 ****************************************************************************/

long _WFFscroll_pages (form, g_label, value, ptr)
     Form       form;
     int        g_label;
     double     value;
     WFFadd_ptr ptr; 
  {

     long   status = NFI_S_SUCCESS; 
     static  char *fname = "_WFFscroll_pages";
 
     _NFIdebug ((fname, " g_label = <%d>\n", g_label));
     _NFIdebug ((fname, " value   = <%d>\n", value));

     /* Erase the current form */

     FIf_erase (form); 
     _WFFprocess_event (REFRESH_EVENT); 
     WFFglobal.current_form = NULL;

     /* Set the next page */  

    if (value)     /* value should have a value of 0 or 1 only */
     {
        if (ptr->curr_page == PAGE4)
            ptr->next_page = PAGE1; 
        else
            ptr->next_page = ptr->curr_page + 1; 
     }
    else
     {
        if (ptr->curr_page == PAGE1)
            ptr->next_page = PAGE4; 
        else
            ptr->next_page = ptr->curr_page - 1; 
     }

    ptr->curr_page = ptr->next_page;

    status = _WFFprocess_pages (ptr);

    _NFIdebug ((fname, " returning : status = <0x%.8x>\n", status));
    return (status);
  }



/****************************************************************************
 *                                                                          * 
 *  Function :  _WFFput_data_in_list                                        *
 *                                                                          * 
 *  This function is used to load data into a single or multicolumn field.  *
 *  it will wipe out all data that exists in the SCF or MCF and use the     *
 *  data in the data_list to populate the SCF/MCF.                          *
 *                                                                          *
 *  The no_cols variable is used to tell this function how many columns     *
 *  exist in the MCF (SCF's only have one column).                          *
 *  The starting_col variable is used to determine which column in the      *
 *  data_list to begin using to populate the SCF/MCF.                       * 
 *                                                                          * 
 ****************************************************************************/

long _WFFput_data_in_list (form, g_label, no_cols, starting_col, data_list)
     Form       form;
     int        g_label;
     int        no_cols;
     int        starting_col;
     MEMptr     data_list;
  {
     long   status = NFI_S_SUCCESS; 
     int    i, j, count;
     char   **data;

     static  char *fname = "WFF_put_data_in_list";
 
     _NFIdebug ((fname, " g_label = <%d>\n", g_label));
     _NFIdebug ((fname, " no_columns  = <%d>\n", no_cols));

    /*  set the no_rows to display to 0 to clear out fields */

    status = (long) FIfld_set_num_rows (form, g_label, 0); 
    if (status != FI_SUCCESS)
     {
        _NFIdebug ((fname, "FIfld_set_num_rows = <%d>\n", status));
        WFFglobal.error_no = NFI_E_FORM;
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_num_rows", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
     }

    if (!data_list)
     {
        status = NFI_S_SUCCESS;  /* this is not an error condition */
        _NFIdebug ((fname, "returning: data_list is NULL: status = <0x%.8x>\n",
                    status));
        return (status);
     }

    /* Put the data into the field */

    data = (char **) data_list->data_ptr;

#ifdef OS_SCO_UNIX
	/* To set font for SCO - CRN 25 Feb  94	*/
	FIg_set_font(form, g_label, "7x13bold", 15);
#endif
    for (i = 0; i < data_list->rows; ++i)
     {
         for (j = starting_col; j < no_cols; ++j)
          {
             count = data_list->columns * i + j; 
             status = (long) FIfld_set_text (form, g_label, i, j,
                                             data[count], FALSE);
             if (status != FI_SUCCESS)
              {
                 _NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
                 WFFglobal.error_no = NFI_E_FORM;
                 ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_text",
                                 status);
                 _NFIdebug ((fname, " returning FAILURE\n"));
                 return (NFI_E_FORM);
              }
          }
     }

    status = NFI_S_SUCCESS;
    _NFIdebug ((fname, " returning : status = <0x%.8x>\n", status));
    return (status);
  }


/*****************************************************************************
 *                                                                           *
 *    Function :  _WFFget_data_from_field                                    *
 *                                                                           *
 *    This function will retrieve the text from the specified field gadget.  * 
 *                                                                           *
 *    This function will do a strncpy into the text parameter (output value) *
 *    hence it assumes that text has already been allocated at least         *
 *    length + 1 bytes of memory.                                            * 
 *                                                                           *
 *****************************************************************************/
 
long _WFFget_data_from_field (form, g_label, row, column, text, length)
     Form       form;      /* I */
     int        g_label;   /* I */ 
     int        row;       /* I */
     int        column;    /* I */
     char       *text;     /* O: length contains maximum length of the string */
     int        length;    /* I */ 
  {
     long   status = NFI_S_SUCCESS; 
     int    s_length = 0;
     int    s_row = 0;
     int    i, num_rows = 0;
     int    sel_flag = FALSE, r_pos = 0;
     char   *str = NULL;      /* O : memory will be malloc'd for this */

     static  char *fname = "_WFF_get_data_from_field";
 
     _NFIdebug ((fname, " g_label = <%d>\n", g_label));
     _NFIdebug ((fname, " row     = <%d>\n", row));
     _NFIdebug ((fname, " column  = <%d>\n", column));
     _NFIdebug ((fname, " length  = <%d>\n", length));

    if (row < 0)   /*  find the selected row if any */
     {
        status = (long) FIfld_get_num_rows (form, g_label, &num_rows);
        if (status != FI_SUCCESS)
         {
            _NFIdebug ((fname, "FIfld_get_num_rows = <%d>\n", status));
            WFFglobal.error_no = NFI_E_FORM;
            ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_get_num_rows",
                            status);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_FORM);
         }

        for (i = 0; i < num_rows; ++i)
         {
            status = (long) FIfld_get_select (form, g_label, i, column,
                                              &sel_flag);
            if (status != FI_SUCCESS)
             {
                _NFIdebug ((fname, "FIfld_get_select = <%d>\n", status));
                WFFglobal.error_no = NFI_E_FORM;
                ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_get_select",
                                status);
                _NFIdebug ((fname, " returning FAILURE\n"));
                return (NFI_E_FORM);
             }

            if (sel_flag)
             {
                s_row = i;
                break;
             } 
         }
        if (!sel_flag)
         {
             _NFIdebug ((fname, " No data was selected\n"));

             _NFIdebug ((fname, " returning Successful\n"));
             return (NFI_S_SUCCESS);
         } 
     }
    else 
       s_row = row;

    s_length = length;

    if (length <= 0)
     {
        status = (long) FIfld_get_text_length (form, g_label, s_row, column,
                                               &s_length);  
        if (status != FI_SUCCESS)
         {
            _NFIdebug ((fname, "FIfld_get_text_length = <%d>\n", status));
            WFFglobal.error_no = NFI_E_FORM;
            ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_get_text_length",
                            status);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_FORM);
         }

        if (s_length <= 0)
          s_length = 1;    /* null strings are allowed */
     }

    str = (char *) malloc (s_length + 1);
    if (!str)
     {
        _NFIdebug ((fname, "Malloc : length = <%d>\n", s_length));
        WFFglobal.error_no = NFI_E_FORM;
        ERRload_struct (NFI, NFI_E_MALLOC, "%d", s_length);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_MALLOC);
     }

    /* allow room for the null character in the string */

    status = (long) FIfld_get_text (form, g_label, s_row, column, s_length + 1,
                                    str, &sel_flag, &r_pos);  
    if (status != FI_SUCCESS)
     {
        if (str)
           free (str); 
        _NFIdebug ((fname, "FIfld_get_text = <%d>\n", status));
        WFFglobal.error_no = NFI_E_FORM;
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_get_text", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
     }

    strncpy (text, str, s_length);
    text [s_length] = '\0';
    free (str);
    _NFIdebug ((fname, " text = <%s>\n", text));

    status = NFI_S_SUCCESS;
    _NFIdebug ((fname, " returning : status = <0x%.8x>\n", status));
    return (status);
  }



/****************************************************************************
 *                                                                          * 
 *  Function :  _WFFscf_put_states_in_list                                  *
 *                                                                          * 
 *  This function is used to load the states into the page2 STATE_LIST_MCF  *
 *                                                                          * 
 ****************************************************************************/

long _WFFscf_put_states_in_list (form, g_label, num_rows, state_list)
     Form       form;
     int        g_label;
     int        num_rows;
     struct WFFstate_st state_list[];
  {
     long   status = NFI_S_SUCCESS; 
     int    i, j;

     static  char *fname = "WFFscf_put_states_in_list";
 
     _NFIdebug ((fname, " g_label   = <%d>\n", g_label));
     _NFIdebug ((fname, " num rows  = <%d>\n", num_rows));

    /*  set the rows to display to 0 to clear out fields */

    status = (long) FIfld_set_num_rows (form, g_label, 0); 
    if (status != FI_SUCCESS)
     {
        _NFIdebug ((fname, "FIfld_set_num_rows = <%d>\n", status));
        WFFglobal.error_no = NFI_E_FORM;
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_num_rows", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
     }

    if (!state_list)
     {
        status = NFI_S_SUCCESS;  /* this is not an error condition */
        _NFIdebug ((fname, "returning: data_list is NULL: status = <0x%.8x>\n",
                    status));
        return (status);
     }

    /* Put the data into the field */

#ifdef OS_SCO_UNIX
	/* To set font for SCO - CRN 25 Feb  94	*/
	FIg_set_font(form, g_label, "7x13bold", 15);
#endif
    j = 0;
    for (i = 0; i < num_rows; ++i)
     {
         if (strcmp (state_list[i].status, WFF_DROP) != 0)
          { 
              status = (long) FIfld_set_text (form, g_label, j, 0,
                                              state_list[i].state_name, FALSE);
              if (status != FI_SUCCESS)
               {
                  _NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
                  WFFglobal.error_no = NFI_E_FORM;
                  ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_text",
                                  status);
                  _NFIdebug ((fname, " returning FAILURE\n"));
                  return (NFI_E_FORM);
               }
              ++j;
          }
     }

    status = NFI_S_SUCCESS;
    _NFIdebug ((fname, " returning : status = <0x%.8x>\n", status));
    return (status);
  }



/****************************************************************************
 *                                                                          * 
 *  Function :  _WFFscf_put_trans_in_list                                   *
 *                                                                          * 
 *  This function is used to load the transitions into the page3            *
 *  TRANS_LIST_SCF.                                                         *
 *                                                                          * 
 ****************************************************************************/

long _WFFscf_put_trans_in_list (form, g_label, num_rows, trans_list)
     Form       form;
     int        g_label;
     int        num_rows;
     struct WFFtrans_st trans_list[];
  {
     long   status = NFI_S_SUCCESS; 
     int    i, j;

     static  char *fname = "WFFscf_put_trans_in_list";
 
     _NFIdebug ((fname, " g_label   = <%d>\n", g_label));
     _NFIdebug ((fname, " num rows  = <%d>\n", num_rows));

    /*  set the rows to display to 0 to clear out fields */

    status = (long) FIfld_set_num_rows (form, g_label, 0); 
    if (status != FI_SUCCESS)
     {
        _NFIdebug ((fname, "FIfld_set_num_rows = <%d>\n", status));
        WFFglobal.error_no = NFI_E_FORM;
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_num_rows", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
     }

    if (!trans_list)
     {
        status = NFI_S_SUCCESS;  /* this is not an error condition */
        _NFIdebug ((fname, "returning: data_list is NULL: status = <0x%.8x>\n",
                    status));
        return (status);
     }

    /* Put the data into the field */

#ifdef OS_SCO_UNIX
	/* To set font for SCO - CRN 25 Feb  94	*/
	FIg_set_font(form, g_label, "7x13bold", 15);
#endif
    j = 0;
    for (i = 0; i < num_rows; ++i)
     {
         if (strcmp (trans_list[i].status, WFF_DROP) != 0)
          { 
              status = (long) FIfld_set_text (form, g_label, j, 0,
                                              trans_list[i].trans_name, FALSE);
              if (status != FI_SUCCESS)
               {
                  _NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
                  WFFglobal.error_no = NFI_E_FORM;
                  ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_text",
                                  status);
                  _NFIdebug ((fname, " returning FAILURE\n"));
                  return (NFI_E_FORM);
               }

              status = (long) FIfld_set_text (form, g_label, j, 1,
                                             trans_list[i].command_name, FALSE);
              if (status != FI_SUCCESS)
               {
                  _NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
                  WFFglobal.error_no = NFI_E_FORM;
                  ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_text",
                                  status);
                  _NFIdebug ((fname, " returning FAILURE\n"));
                  return (NFI_E_FORM);
               }

              status = (long) FIfld_set_text (form, g_label, j, 2,
                                              trans_list[i].from_state, FALSE);
              if (status != FI_SUCCESS)
               {
                  _NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
                  WFFglobal.error_no = NFI_E_FORM;
                  ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_text",
                                  status);
                  _NFIdebug ((fname, " returning FAILURE\n"));
                  return (NFI_E_FORM);
               }

              status = (long) FIfld_set_text (form, g_label, j, 3,
                                              trans_list[i].to_state, FALSE);
              if (status != FI_SUCCESS)
               {
                  _NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
                  WFFglobal.error_no = NFI_E_FORM;
                  ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_text",
                                  status);
                  _NFIdebug ((fname, " returning FAILURE\n"));
                  return (NFI_E_FORM);
               }
              ++j;
          }
     }

    status = NFI_S_SUCCESS;
    _NFIdebug ((fname, " returning : status = <0x%.8x>\n", status));
    return (status);
  }


