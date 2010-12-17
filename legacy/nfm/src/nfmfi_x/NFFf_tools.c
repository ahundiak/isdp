
/* machine.h included to take care of platform variencies MVR 23 Dec 1993 */
#include "machine.h"

#include "NFF.h"
#include "NFFfiles.h"

/*  Global NFF structure  */

extern struct NFFglobal_st NFFglobal;

/* This function assumes the user has already selected the row he/she wants
   to update and has selected an attribute to change in the row.  */ 

long _NFFset_select_attr_data (form, data_rows, act_row, act_col, ptr)
  Form         form;
  int          data_rows;         /* number of rows in the MCF */
  int          *act_row;           
  int          *act_col;           
  NFFadd_ptr   ptr;
  {
    long    status = NFI_S_SUCCESS;
    int     i, j, rows = 0, count = -1;
    int     num_rows, sel_flag;
    int     sel_row = -1, sel_col = -1;
    int     pos_cur = FALSE;

    static  char *fname = "_NFFset_select_attr_data";

    _NFIdebug ((fname, " Function entered\n"));

    if ((ptr->data_list)->rows <= 0)
     {
        _NFIdebug ((fname, " No rows exist.\n"));
        _NFIdebug ((fname, "returning Success\n"));
        return (NFI_S_SUCCESS);
     }

    for (i = 0; i < ptr->attr_list->rows; ++i)
     {
        if (ptr->rows[i] != -1)
          ++rows;
     } 

    num_rows = data_rows; 
    if (data_rows <= 0)
       num_rows = (ptr->data_list)->rows;

    for (i = 0; i < num_rows; ++i)  /* rows in MCF */
     {
        for (j = 0; j < rows; ++j)  /* columns in MCF */
         {
            if ((status = (long) FIfld_get_select (form, NFI_DATA_LIST, i, j, 
                                                   &sel_flag)) != FI_SUCCESS)
             {
                 _NFIdebug ((fname, "FIfld_get_select = <%d>\n", status));
                 ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_get_select",
                                 status);
                 _NFIdebug ((fname, "returning FAILURE\n"));
                 return (NFI_E_FORM);
             }
            if (sel_flag)
             {
                 sel_row = i;
                 *act_row = i;
                 sel_col = j;
                 *act_col= j;
                 break;
             }
         }
     }

    if ((sel_row == -1) || (sel_col == -1))
     {
        _NFIdebug ((fname, "No field has been selected\n", status));
        _NFIdebug ((fname, " returning SUCCESS\n"));
        return (NFI_S_SUCCESS);
     }

    /* get the list offsets */

/*
    if ((status = _NFFn_find_list_offsets ((ptr->attr_list,
                                 &syn_offset, &name_offset)) != NFI_S_SUCCESS)
     {
         _NFIdebug ((fname, "_NFFn_find_list_offsets = <0x%.8x>\n", status));
         _NFIdebug ((fname, " returning FAILURE\n"));
         return (status);
     }
*/

    /* get the actual column from the sel_col */

    for (i = 0; i < ptr->attr_list->rows; ++i)
     {
        if (ptr->rows[i] == sel_col)
         { 
            count = i; 
            break;
         } 
     } 

    if (count == -1)  /* this needs to be changed to return an error */
     {
        _NFIdebug ((fname, "No field has been selected\n", status));
        _NFIdebug ((fname, " returning SUCCESS\n"));
        return (NFI_S_SUCCESS);
     }

    /* ptr->active_attribute = num_rows * sel_row + count; */
    ptr->active_attribute = (ptr->attr_list)->rows * sel_row + count; 

    /* set the values in the gadgets */

    if ((status = _NFFset_value_info
        (form, ptr, sel_row, sel_col, &pos_cur)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFset_value_info = <0x%.8x>\n", status));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }
    _NFIdebug ((fname, "pos_cursor = <%d>\n", pos_cur));

    /* clear out the Error structure and message strip*/

    ERRload_struct (NFI, NFI_S_SUCCESS, NULL); 
    NFFerase_message ();

    /* if the value is to be selected from a validation list, there is
       no need to position the cursor in the value field               */ 

    /*  Put the cursor in the value field  */

    _NFIdebug ((fname, "positioning cursor in the value field\n"));

    if ((status = FIfld_pos_cursor
        (form, NFI_VALUE_FIELD, 0, 0, 0, 0, NULL, 0)) != FI_SUCCESS)
     {
        _NFIdebug ((fname, "FIfld_pos_cursor = <%d>\n", status));
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_pos_cursor",
                        status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
     }

    _NFIdebug ((fname, " returning SUCCESS\n"));
    return (NFI_S_SUCCESS);
  }


long _NFFprocess_value_field (form, act_row, act_col, ptr, val_col)
  Form          form;
  int           act_row;
  int           act_col;
  NFFadd_ptr    ptr;
  int           val_col; /* the column of data to use in validation_list */
  {
    int     length;
    int     selected;
    int     i, count = -1;
    int     r_pos;
    int     row_no, list_no;
    int     attr_mask;
    char    *text;
    char    **data_ptr;
    char    *attr_name;
    long    status;
    short   offset, min_offset, max_offset;

    int     label = NFI_VALUE_FIELD;

    static  char *fname = "_NFFprocess_value_field";

    _NFIdebug ((fname, "label   = <%d>\n", label));
    _NFIdebug ((fname, "act_row = <%d>\n", act_row));
    _NFIdebug ((fname, "act_col = <%d>\n", act_col));
    _NFIdebug ((fname, "val_col = <%d>\n", val_col));
    _NFIdebug ((fname, "ptr->active_attribute = <%d>\n",
                ptr->active_attribute));

	/* IGI Intel Solaris Port -CN 31/5/95 */
#if defined(OS_SCO_UNIX) || defined(OS_INTELSOL) 
        /* work around change - to set font for SCO - SSRS 7 Feb 94 */
        FIg_set_font( form, label, "7x13bold", 15 );
#endif
    if ((ptr->data_list)->rows <= 0)
     {
        if ((status = (long) FIfld_set_text
            (form, label, 0, 0, "", FALSE)) != FI_SUCCESS)
        _NFIdebug ((fname, " there are no rows in the data_list\n"));
        return (NFI_S_SUCCESS);
     }

    /*  Allocate space for the data  */

    if ((status = (long) FIfld_get_text_length
        (form, label, 0, 0, &length)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIfld_get_text_length = <%d>\n", status));
        ERRload_struct
            (NFI, NFI_E_FORM, "%s%d", "FIfld_get_text_length", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    /*  Make sure that the length will hold an expanded date  */

    if (length < 11) length = 11;

    if ((text = (char *) malloc (length)) == NULL)
      {
        _NFIdebug ((fname, "malloc failed; size = <%d>\n", length));
        ERRload_struct (NFI, NFI_E_MALLOC, "%d", length);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_MALLOC);
      }

    if ((status = (long) FIfld_get_text
        (form, label, 0, 0, length, text, &selected, &r_pos)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIfld_get_text = <%d>\n", status));
        if (text) free (text);
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_get_text", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    for (i = 0; i < (ptr->attr_list)->rows; ++i)
     {
         if (ptr->rows[i] == act_col)
          {
             count = i;
	     _NFIdebug(( fname, "break at <%d>\n", i ));
             break;
          }
     }

    if (count == -1)
       count = act_col;

    data_ptr = (char **) (ptr->attr_list)->data_ptr;
    row_no = count * (ptr->attr_list)->columns;

    if (strcmp (text, "") == 0)
      {
        /*  See if this attribute can have a null value  */

        if ((status = _NFFfind_column_offset (ptr->attr_list, "n_null",
                                              &offset)) != NFI_S_SUCCESS)
          {
            _NFIdebug ((fname, "_NFFfind_column_offset = <0x%.8x>\n", status));
            if (text) free (text);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (status);
          }

        if ((strcmp (data_ptr[row_no + offset], "Y")) != 0)
          {
            _NFIdebug ((fname, "This attribute is not allowed NULL values\n"));
            if (text) free (text);
            ERRload_struct (NFI, NFI_E_NULL, NULL);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_NULL);
          }
      }

    /*  See if this is a character 'date' attribute  */

    if ((status = _NFFfind_column_offset
        (ptr->attr_list, "n_name", &offset)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFfind_column_offset = <0x%.8x>\n", status));
        if (text) free (text);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    attr_name = data_ptr [count * (ptr->attr_list)->columns + offset];

    /* attr_name = data_ptr[(ptr->active_attribute *
        (ptr->attr_list)->columns) + offset]; */

    /*  Find the value list for this attribute  */

    if ((status = _NFFfind_column_offset
        (ptr->attr_list, "n_valueno", &offset)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFfind_column_offset = <0x%.8x>\n", status));
        if (text) free (text);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    list_no = atoi (data_ptr[row_no + offset]);
    _NFIdebug ((fname, "list_no = <%d>\n", list_no));

    if (list_no > 0)
      {
        /*  Reset to the values buffer  */

        if ((status = MEMreset_buffer_no
            (ptr->value_list, list_no)) != MEM_S_SUCCESS)
          {
            _NFIdebug ((fname, "MEMreset_buffer_no = <0x%.8x>\n", status));
            if (text) free (text);
            ERRload_struct
                (NFI, NFI_E_MEM, "%s%x", "MEMreset_buffer_no", status);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_MEM);
          }
      }
    else
      {
        /*  There is no value list for this attribute  */

        _NFIdebug ((fname, "There is no value list for this attribute\n"));

        if ((status = _NFFdisable_value_info (form, ptr)) != NFI_S_SUCCESS)
          {
            if (text) free (text);
            _NFIdebug ((fname,
                "_NFFdisable_value_info = <0x%.8x>\n", status));
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (status);
          }

        /*  Put the value in the buffer  */

        _NFIdebug ((fname, "Writing <%s>\n", text));
        _NFIdebug ((fname, " in row %d, col %d in data_list\n",
                    act_row, count));

        if ((status = MEMwrite_data (ptr->data_list, text, act_row + 1,
                                     count + 1)) != MEM_S_SUCCESS)
          {
            _NFIdebug ((fname, "MEMwrite_data = <0x%.8x>\n", status));
            if (text) free (text);
            ERRload_struct (NFI, NFI_E_MEM, "%s%x", "MEMwrite_data", status);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_MEM);
          }

        /*  See if the field is NO_ECHO  */

        if ((status = (long) FIfld_get_attr
            (form, label, 0, &attr_mask)) != FI_SUCCESS)
          {
            _NFIdebug ((fname, "FIfld_get_attr = <%d>\n", status));
            if (text) free (text);
            ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_get_attr", status);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_FORM);
          }

        if ((attr_mask & FI_NO_ECHO) == 0)
          {
            /*  Put the value in the attributes field  */

/* IGI Intel Solaris Port -CN 31/5/95 */
#if defined(OS_SCO_UNIX) || defined(OS_INTELSOL) 
            /* work around change - to set font for SCO - SSRS 2 Feb 94 */
            FIg_set_font( form, NFI_DATA_LIST, "7x13bold", 15 );
#endif
            if ((status = (long) FIfld_set_text (form, NFI_DATA_LIST,
                                  act_row, act_col, text, TRUE)) != FI_SUCCESS)
              {
                _NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
                if (text) free (text);
                ERRload_struct
                    (NFI, NFI_E_FORM, "%s%d", "FIfld_set_text", status);
                _NFIdebug ((fname, " returning FAILURE\n"));
                return (NFI_E_FORM);
              }

/* IGI Intel Solaris Port -CN 31/5/95 */
#if defined(OS_SCO_UNIX) || defined(OS_INTELSOL) 
            /* work around change - to set font for SCO - SSRS 2 Feb 94 */
            FIg_set_font( form, NFI_DEL_DATA_LIST, "7x13bold", 15 );
#endif
            if ((status = (long) FIfld_set_text (form, NFI_DEL_DATA_LIST,
                                 act_row, act_col, text, FALSE)) != FI_SUCCESS)
             {
                 _NFIdebug ((fname, "The Bottom MCF does not exist...\n"));
             }
          }

        if (text) free (text);

        _NFIdebug ((fname, " returning SUCCESS\n"));
        return (NFI_S_SUCCESS);
      }

    /*  Validate the value  */

    data_ptr = (char **) (ptr->value_list)->data_ptr;

    if ((status = _NFFfind_column_offset
        (ptr->value_list, "n_minvalue", &min_offset)) == NFI_S_SUCCESS)
      {
        /*  It is a range list  */
   
        ERRreset_struct ();

        if ((status = _NFFfind_column_offset
            (ptr->value_list, "n_maxvalue", &max_offset)) != NFI_S_SUCCESS)
          {
            if (text) free (text);
            _NFIdebug ((fname, "_NFFfind_column_offset = <0x%.8x>\n", status));
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (status);
          }

        _NFIdebug ((fname,
            "verifying that <%d> is between <%d> and <%d>\n", atoi (text),
            atoi (data_ptr[min_offset]), atoi (data_ptr[max_offset])));

        if ((atoi (text) < atoi (data_ptr[min_offset])) ||
            (atoi (text) > atoi (data_ptr[max_offset])))
          {
            /*  Blank out the value field  */

            strcpy (text, "");

/* IGI Intel Solaris Port -CN 31/5/95 */
#if defined(OS_SCO_UNIX) || defined(OS_INTELSOL) 
        /* work around change - to set font for SCO - SSRS 7 Feb 94 */
        FIg_set_font( form, label, "7x13bold", 15 );
#endif
            if ((status = (long) FIfld_set_text
                (form, label, 0, 0, text, FALSE)) != FI_SUCCESS)
              {
                _NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
                ERRload_struct
                    (NFI, NFI_E_FORM, "%s%d", "FIfld_set_text", status);
                _NFIdebug ((fname, " returning FAILURE\n"));
                return (NFI_E_FORM);
              }

            /*  Return an error status  */

            if (text) free (text);
            ERRload_struct (NFI, NFI_E_RANGE, NULL);
            _NFIdebug ((fname, " returning NFI_E_RANGE <%d>\n", NFI_E_RANGE));
            return (NFI_E_RANGE);
          }
      }
    else
      {
        /*  It is OK, reset the global error structure  */

        ERRreset_struct ();

        /*  It is a list  */

        if ((status = _NFFnadd_validate_text
            (text, ptr->value_list, val_col)) != NFI_S_SUCCESS)
          {
            /*  Blank out the value field  */

            strcpy (text, "");

/* IGI Intel Solaris Port -CN 31/5/95 */
#if defined(OS_SCO_UNIX) || defined(OS_INTELSOL)
        /* work around change - to set font for SCO - SSRS 7 Feb 94 */
        FIg_set_font( form, label, "7x13bold", 15 );
#endif
            if ((status = (long) FIfld_set_text
                (form, label, 0, 0, text, FALSE)) != FI_SUCCESS)
              {
                _NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
                ERRload_struct
                    (NFI, NFI_E_FORM, "%s%d", "FIfld_set_text", status);
                _NFIdebug ((fname, " returning FAILURE\n"));
                return (NFI_E_FORM);
              }

            /*  Unselect any selected rows in the validate mcf  */

            if (ptr->validate_row != -1)
              {
                if ((status = (long) FImcf_set_select (form,  
                  NFI_VALIDATION_LIST, ptr->validate_row, FALSE)) != FI_SUCCESS)
                  {
                    _NFIdebug ((fname, "FImcf_set_select = <%d>\n", status));
                    ERRload_struct
                        (NFI, NFI_E_FORM, "%s%d", "FImcf_set_select", status);
                    _NFIdebug ((fname, " returning FAILURE\n"));
                    return (NFI_E_FORM);
                  }
              }

            /*  Return an error status  */

            if (text) free (text);
            ERRload_struct (NFI, NFI_E_VALID, NULL);
            _NFIdebug ((fname, " returning NFI_E_VALID <%d>\n", NFI_E_VALID));
            return (NFI_E_VALID);
          }
      }

    /*  Write ALL data in the active row */

    _NFIdebug ((fname, "Writing <%s> in row %d, col %d in data_list\n",
        text, act_row, act_col));

    if ((status = MEMwrite_data (ptr->data_list, text, act_row + 1,
                                 count + 1)) != MEM_S_SUCCESS)
      {
        if (text) free (text);
        _NFIdebug ((fname, "MEMwrite_data = <0x%.8x>\n", status));
        ERRload_struct (NFI, NFI_E_MEM, "%s%x", "MEMwrite_data", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_MEM);
      }

    /*  See if the field is NO_ECHO  */

    if ((status = (long) FIfld_get_attr
        (form, label, 0, &attr_mask)) != FI_SUCCESS)
      {
        if (text) free (text);
        _NFIdebug ((fname, "FIfld_get_attr = <%d>\n", status));
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_get_attr", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    if ((attr_mask & FI_NO_ECHO) == 0)
      {
        /*  Put the value in the attributes field  */

/* IGI Intel Solaris Port -CN 31/5/95 */
#if defined(OS_SCO_UNIX) || defined(OS_INTELSOL) 
            /* work around change - to set font for SCO - SSRS 2 Feb 94 */
            FIg_set_font( form, NFI_DATA_LIST, "7x13bold", 15 );
#endif
        if ((status = (long) FIfld_set_text (form, NFI_DATA_LIST, act_row,
                                           act_col, text, TRUE)) != FI_SUCCESS)
          {
            if (text) free (text);
            _NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
            ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_text", status);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_FORM);
          }

/* IGI Intel Solaris Port -CN 31/5/95 */
#if defined(OS_SCO_UNIX) || defined(OS_INTELSOL) 
            /* work around change - to set font for SCO - SSRS 2 Feb 94 */
            FIg_set_font( form, NFI_DEL_DATA_LIST, "7x13bold", 15 );
#endif
        if ((status = (long) FIfld_set_text (form, NFI_DEL_DATA_LIST, act_row,
                                           act_col, text, FALSE)) != FI_SUCCESS)
          {
            _NFIdebug ((fname, "The Bottom MCF does not exist...\n"));
          }
      }

    if (text) free (text);

    ERRreset_struct ();

    _NFIdebug ((fname, " returning SUCCESS\n"));
    return (NFI_S_SUCCESS);
  }


long _NFFprocess_validate_field (form, row, act_row, act_col, ptr, val_col)
  Form          form;
  int           row;
  int           act_row; 
  int           act_col; 
  NFFadd_ptr    ptr;
  int           val_col; /* the column of data to use in validation_list */
  {
    int     row_no, i, d_row;
    int     cur_row, cur_col = 0, attr_pos = -1;
    int     list_no;
    int     position;
    int     selected;
    long    status;
    char    **data_ptr;
    short   offset;
    MEMptr  buffer = NULL;

    int     label = NFI_VALIDATION_LIST;

    static  char *fname = "_NFFprocess_validate_field";

    _NFIdebug ((fname, "row        = <%d>\n", row));
    _NFIdebug ((fname, "act_row    = <%d>\n", act_row));
    _NFIdebug ((fname, "act_column = <%d>\n", act_col));
    _NFIdebug ((fname, "ptr->active_attribute = <%d>\n",
                ptr->active_attribute));
    _NFIdebug ((fname, "val_col = <%d>\n", val_col));

    /*  See if the checkbox was selected  */

    if (row == -1)
      {
        /*  Find out which row was selected  */

        if ((status = (long) FIfld_get_active_row
            (form, label, &cur_row, &position)) != FI_SUCCESS)
          {
            _NFIdebug ((fname, "FIfld_get_active_row = <%d>\n", status));
            ERRload_struct
                (NFI, NFI_E_FORM, "%s%d", "FIfld_get_active_row", status);
            _NFIdebug ((fname, "returning FAILURE\n"));
            return (NFI_E_FORM);
          }
        _NFIdebug ((fname, "cur_row = <%d>\n", cur_row));

        /*  Find out if the row is selected or not  */

        if ((status = (long) FImcf_get_select
            (form, label, cur_row, &selected)) != FI_SUCCESS)
          {
            _NFIdebug ((fname, "FImcf_get_select = <%d>\n", status));
            ERRload_struct
                (NFI, NFI_E_FORM, "%s%d", "FImcf_get_select", status);
            _NFIdebug ((fname, "returning FAILURE\n"));
            return (NFI_E_FORM);
          }

        if (selected == FALSE)
          {
            _NFIdebug ((fname, "Row was unselected with the checkbox\n"));

            ptr->validate_row = -1;

            _NFIdebug ((fname, " returning SUCCESS\n"));
            return (NFI_S_SUCCESS);
          }
      }
    else if (row < 0)
      {
        _NFIdebug ((fname, "rows or columns are scrolling\n"));
        _NFIdebug ((fname, " returning SUCCESS\n"));
        return (NFI_S_SUCCESS);
      }
    else
      {
        cur_row = row;
        /*  Set this entire row to be selected  */

        if ((status = (long) FImcf_set_select
            (form, label, row, TRUE)) != FI_SUCCESS)
          {
            _NFIdebug ((fname, "FImcf_set_select = <%d>\n", status));
            ERRload_struct
                (NFI, NFI_E_FORM, "%s%d", "FImcf_set_select", status);
            _NFIdebug ((fname, "returning FAILURE\n"));
            return (NFI_E_FORM);
          }
      }

    /*  Remember that this row is selected  */

    ptr->validate_row = cur_row;
    
    _NFIdebug ((fname, "cur_row = <%d>\n", cur_row));

    /*  For now, put what's in the first column of
        the MCF in the attributes field and in the buffer  */

    buffer = ptr->value_list;
    data_ptr = (char **) (ptr->attr_list)->data_ptr;

    if ((status = _NFFfind_column_offset
        (ptr->attr_list, "n_valueno", &offset)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFfind_column_offset = <0x%.8x>\n", status));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    /* find the row_no using the ptr->rows integer array */

    for (i = 0; i < (ptr->attr_list)->columns; ++i)
     {
         if (ptr->rows [i] == act_col)
          {
            attr_pos = i;
            break;
          }
     }

   if (attr_pos != -1) 
       row_no = attr_pos * (ptr->attr_list)->columns;
   else  
       row_no = act_col * (ptr->attr_list)->columns;
/*
        row_no = ptr->active_attribute * (ptr->attr_list)->columns;
*/
    _NFIdebug ((fname, "row_no = <%d>\n", row_no));
    _NFIdebug ((fname, "offset = <%d>\n", offset));
    list_no = atoi (data_ptr[row_no + offset]);
    _NFIdebug ((fname, "list_no = <%d>\n", list_no));

    if (list_no > 0)
      {
        /*  Reset to the values buffer  */

        if ((status = MEMreset_buffer_no
            (buffer, list_no)) != MEM_S_SUCCESS)
          {
            _NFIdebug ((fname, "MEMreset_buffer_no = <0x%.8x>\n", status));
            ERRload_struct
                (NFI, NFI_E_MEM, "%s%x", "MEMreset_buffer_no", status);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_MEM);
          }
      }
    else
      {
        /*  There is no value list for this attribute  */

        _NFIdebug ((fname, "There is no value list for this attribute\n"));

        if ((status = _NFFdisable_value_info (form, ptr)) != NFI_S_SUCCESS)
          {
            _NFIdebug ((fname,
                "_NFFdisable_value_info = <0x%.8x>\n", status));
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (status);
          }

         ptr->validate_row = -1;

         ERRload_struct (NFI, NFI_E_BUFFER, NULL);
         _NFIdebug ((fname, " returning FAILURE\n"));
         return (NFI_E_BUFFER);
      }

    /*  Put the data (probably the index) in the
        attributes field and in the data_list buffer  */

    data_ptr = (char **) buffer->data_ptr;

    cur_col = val_col;
    if (val_col > 0)
     {
        if (val_col >= buffer->columns)
          cur_col = 0;
     }
    else
     cur_col = 0;

    _NFIdebug ((fname, "Setting <%s> in the value field\n",
                data_ptr[cur_row * buffer->columns + cur_col]));

/* IGI Intel Solaris Port -CN 31/5/95 */
#if defined(OS_SCO_UNIX)|| defined(OS_INTELSOL) 
            /* work around change - to set font for SCO - SSRS 2 Feb 94 */
            FIg_set_font( form, NFI_VALUE_FIELD, "7x13bold", 15 );
#endif
    if ((status = (long) FIfld_set_text (form, NFI_VALUE_FIELD, 0, 0,
          data_ptr[cur_row * buffer->columns + cur_col], FALSE)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_text", status);
        _NFIdebug ((fname, "returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    /* Use the act_row and act_col with the ptr->rows array to determine actual
       column to write the data to. */

    d_row = act_col;
    for (i = 0; i < ptr->data_list->columns; ++i)
     {
         if (ptr->rows[i] == act_col)
          {
              d_row = i;
              break;
          }
     }

    /*  Write ALL data in the specified row */

    _NFIdebug ((fname, "Writing <%s>\n",
                data_ptr[cur_row * buffer->columns + cur_col]));
    _NFIdebug ((fname, " in row %d, col %d in data_list\n",
                act_row, d_row));

    if ((status = MEMwrite_data (ptr->data_list,  
                   data_ptr[cur_row * buffer->columns + cur_col], act_row + 1,
                                 d_row + 1)) != MEM_S_SUCCESS)
      {
        _NFIdebug ((fname, "MEMwrite_data = <0x%.8x>\n", status));
        ERRload_struct (NFI, NFI_E_MEM, "%s%x", "MEMwrite_data", status);
        _NFIdebug ((fname, "returning FAILURE\n"));
        return (NFI_E_MEM);
      }

    /*  Put the value in the attributes field  */

/* IGI Intel Solaris Port -CN 31/5/95 */
#if defined(OS_SCO_UNIX) || defined(OS_INTELSOL) 
            /* work around change - to set font for SCO - SSRS 2 Feb 94 */
            FIg_set_font( form, NFI_DATA_LIST, "7x13bold", 15 );
#endif
    if ((status = (long) FIfld_set_text (form, NFI_DATA_LIST, act_row, act_col,
           data_ptr[cur_row * buffer->columns + cur_col], TRUE)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_text", status);
        _NFIdebug ((fname, "returning FAILURE\n"));
        return (NFI_E_FORM);
      }

/* IGI Intel Solaris Port -CN 31/5/95 */
#if defined(OS_SCO_UNIX) || defined(OS_INTELSOL) 
            /* work around change - to set font for SCO - SSRS 2 Feb 94 */
            FIg_set_font( form, NFI_DEL_DATA_LIST, "7x13bold", 15 );
#endif
     if ((status = (long) FIfld_set_text (form, NFI_DEL_DATA_LIST, act_row,
                      act_col, data_ptr[cur_row * buffer->columns + cur_col],
                      FALSE)) != FI_SUCCESS)
      {
         _NFIdebug ((fname, "The Bottom MCF does not exist...\n"));
      }

     /*  Unselect and erase the validation info  */

     if ((status = _NFFdisable_value_info (form, ptr)) != NFI_S_SUCCESS)
      {
         _NFIdebug ((fname, "_NFFdisable_value_info = <0x%.8x>\n", status));
         _NFIdebug ((fname, " returning FAILURE\n"));
         return (status);
      }

    /* clear out the error structure */

    ERRreset_struct ();

    _NFIdebug ((fname, " returning SUCCESS\n"));
    return (NFI_S_SUCCESS);
 }
  


long _NFFset_value_info (form, ptr, sel_row, sel_col, pos_cur)
    Form       form;
    NFFadd_ptr ptr;
    int        sel_row;
    int        sel_col;
    int        *pos_cur;
  {
    int     i, row_no, count = -1;
    int     list_no;
    char    **data_ptr, **attr_ptr;
    long    status = NFI_S_SUCCESS;
    short   offset;
    short   min_offset;
    short   max_offset;

    static  char *fname = "_NFFset_value_info";

    *pos_cur = FALSE;

    /*  Put any existing value in the value field  */

    data_ptr = (char **) (ptr->data_list)->data_ptr;

    _NFIdebug ((fname, "sel_row = <%d>\n", sel_row));
    _NFIdebug ((fname, "sel_col = <%d>\n", sel_col));
    _NFIdebug ((fname, "Writing <%s> in the value field\n",
        data_ptr[ptr->active_attribute]));

/* IGI Intel Solaris Port -CN 31/5/95 */
#if defined(OS_SCO_UNIX) || defined(OS_INTELSOL) 
            /* work around change - to set font for SCO - SSRS 2 Feb 94 */
            FIg_set_font( form, NFI_VALUE_FIELD, "7x13bold", 15 );
#endif
    if ((status = (long) FIfld_set_text (form, NFI_VALUE_FIELD,
        0, 0, data_ptr[ptr->active_attribute], FALSE)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_text", status);
        _NFIdebug ((fname, "returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    if ((status = (long) FIfld_set_active_char
        (form, NFI_VALUE_FIELD, 0, 0, 0)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIfld_set_active_char = <%d>\n", status));
        ERRload_struct
            (NFI, NFI_E_FORM, "%s%d", "FIfld_set_active_char", status);
        _NFIdebug ((fname, "returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    /*  Find the value list for this attribute  */

    if ((status = _NFFfind_column_offset
        (ptr->attr_list, "n_valueno", &offset)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFfind_column_offset = <0x%.8x>\n", status));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    for (i = 0; i < ptr->attr_list->rows; ++i)
     {
        if (ptr->rows[i] == sel_col)
         {
            count = i;
            break;
         }
     }
   
    if (count == -1)  /* this needs to be changed to return an error */
     {
        _NFIdebug ((fname, "No field has been selected\n", status));
        _NFIdebug ((fname, " returning SUCCESS\n"));
        return (NFI_S_SUCCESS);
     } 

    attr_ptr = (char **) (ptr->attr_list)->data_ptr;
    row_no =  (ptr->attr_list)->columns * count;   
    list_no = atoi (attr_ptr[row_no + offset]);
    _NFIdebug ((fname, "list_no = <0x%.8x>\n", list_no));

    if (list_no > 0)
      {
        /*  Reset to the values buffer  */

        if ((status = MEMreset_buffer_no
            (ptr->value_list, list_no)) != MEM_S_SUCCESS)
          {
            _NFIdebug ((fname, "MEMreset_buffer_no = <0x%.8x>\n", status));
            ERRload_struct
                (NFI, NFI_E_MEM, "%s%x", "MEMreset_buffer_no", status);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_MEM);
          }

        data_ptr = (char **) (ptr->value_list)->data_ptr;
      }
    else
      {
        /*  There is no value list for this attribute  */

        _NFIdebug ((fname, "There is no value list for this attribute\n"));

        if ((status = _NFFdisable_value_info (form, ptr)) != NFI_S_SUCCESS)
         {
            _NFIdebug ((fname,
                "_NFFdisable_value_info = <0x%.8x>\n", status));
            _NFIdebug ((fname, " return FAILURE\n"));
            return (status);
         }

        /*  Display any advisory information  */

        if ((status = _NFFset_advisory_info (form, ptr, count)) != NFI_S_SUCCESS)
          {
            _NFIdebug ((fname,
                "_NFFset_advisory_info = <0x%.8x>\n", status));
            _NFIdebug ((fname, " return FAILURE\n"));
            return (status);
          }

        _NFIdebug ((fname, " returning SUCCESS\n"));
        return (NFI_S_SUCCESS);
      }

    /*  Find out which type of list it is  */

    if ((status = _NFFfind_column_offset
        (ptr->value_list, "n_minvalue", &min_offset)) == NFI_S_SUCCESS)
      {
        ERRreset_struct ();
        if ((status = _NFFfind_column_offset
            (ptr->value_list, "n_maxvalue", &max_offset)) != NFI_S_SUCCESS)
          {
            _NFIdebug ((fname, "_NFFfind_column_offset = <0x%.8x>\n", status));
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (status);
          }

        /*  It is a range list  */

        /*  Erase the validate group  */

        status = (long) FIg_erase (form, NFI_VALIDATION_TEXT);
        if (status != FI_SUCCESS)
          {
            _NFIdebug ((fname, "FIg_erase = <%d>\n", status));
            ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_erase", status);
            _NFIdebug ((fname, "returning FAILURE\n"));
            return (NFI_E_FORM);
          }

        status = (long) FIg_erase (form, NFI_VALIDATION_LIST);
        if (status != FI_SUCCESS)
          {
            /*  The validate mcf does not exist; continue  */

            _NFIdebug ((fname, "FIg_erase = <0x%.8x>\n", status));
          }

        /*  Display the range group  */

        if ((status = (long) FIg_display (form, NFI_RANGE_GROUP)) != FI_SUCCESS)
          {
            _NFIdebug ((fname, "FIg_display = <%d>\n", status));
            ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_display", status);
            _NFIdebug ((fname, "returning FAILURE\n"));
            return (NFI_E_FORM);
          }

        /*  Put the values in the fields  */

/* IGI Intel Solaris Port -CN 31/5/95 */
#if defined(OS_SCO_UNIX) || defined(OS_INTELSOL) 
            /* work around change - to set font for SCO - SSRS 2 Feb 94 */
            FIg_set_font( form, NFI_MIN_FIELD, "7x13bold", 15 );
#endif
        if ((status = (long) FIfld_set_text
            (form, NFI_MIN_FIELD, 0, 0, data_ptr[min_offset])) != FI_SUCCESS)
          {
            _NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
            ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_text", status);
            _NFIdebug ((fname, "returning FAILURE\n"));
            return (NFI_E_FORM);
          }

/* IGI Intel Solaris Port -CN 31/5/95 */
#if defined(OS_SCO_UNIX) || defined(OS_INTELSOL) 
            /* work around change - to set font for SCO - SSRS 2 Feb 94 */
            FIg_set_font( form, NFI_MAX_FIELD, "7x13bold", 15 );
#endif
        if ((status = (long) FIfld_set_text
            (form, NFI_MAX_FIELD, 0, 0, data_ptr[max_offset])) != FI_SUCCESS)
          {
            _NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
            ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_text", status);
            _NFIdebug ((fname, "returning FAILURE\n"));
            return (NFI_E_FORM);
          }
      }
    else
      {
        /*  It is OK, reset the global error structure  */

        /* ERRload_struct (NFI, NFI_S_SUCCESS, NULL); */
        ERRreset_struct ();

        /*  It is a list  */

        /*  Erase the range group  */

/* IGI Intel Solaris Port -CN 31/5/95 */
#if defined(OS_SCO_UNIX) || defined(OS_INTELSOL) 
            /* work around change - to set font for SCO - SSRS 2 Feb 94 */
            FIg_set_font( form, NFI_MIN_FIELD, "7x13bold", 15 );
#endif
        if ((status = (long) FIfld_set_text
            (form, NFI_MIN_FIELD, 0, 0, "", FALSE)) != FI_SUCCESS)
          {
            _NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
            ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_text", status);
            _NFIdebug ((fname, "returning FAILURE\n"));
            return (NFI_E_FORM);
          }

/* IGI Intel Solaris Port -CN 31/5/95 */
#if defined(OS_SCO_UNIX) || defined(OS_INTELSOL) 
            /* work around change - to set font for SCO - SSRS 2 Feb 94 */
            FIg_set_font( form, NFI_MAX_FIELD, "7x13bold", 15 );
#endif
        if ((status = (long) FIfld_set_text
            (form, NFI_MAX_FIELD, 0, 0, "", FALSE)) != FI_SUCCESS)
          {
            _NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
            ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_text", status);
            _NFIdebug ((fname, "returning FAILURE\n"));
            return (NFI_E_FORM);
          }

        if ((status = (long) FIg_erase (form, NFI_RANGE_GROUP)) != FI_SUCCESS)
          {
            _NFIdebug ((fname, "FIg_erase = <%d>\n", status));
            ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_erase", status);
            _NFIdebug ((fname, "returning FAILURE\n"));
            return (NFI_E_FORM);
          }

        /*  Display the NFI_VALIDATION_TEXT  */
/* commented to avoid overwriting the Validation Text Title
   - MVVMK - 19th April 1996 
        if ((status = (long) FIg_display (form, 
                                          NFI_VALIDATION_TEXT)) != FI_SUCCESS)
          {
            _NFIdebug ((fname, "FIg_display = <%d>\n", status));
            ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_display", status);
            _NFIdebug ((fname, "returning FAILURE\n"));
            return (NFI_E_FORM);
          }
 MVVMK */
        /*  Create the validate mcf to reflect the list  */

        if ((status = _NFFcreate_validation_mcf
            (form, NFI_VALIDATION_LIST, ptr->value_list)) != NFI_S_SUCCESS)
          {
            _NFIdebug ((fname, "_NFFcreate_validation_mcf = <0x%.8x>\n",
                        status));
            _NFIdebug ((fname, "returning FAILURE\n"));
            return (status);
          }

        /*  Load the list into the mcf  */

        if ((status = _NFFadd_load_mcf
            (form, NFI_VALIDATION_LIST, ptr->value_list)) != NFI_S_SUCCESS)
          {
            _NFIdebug ((fname, "_NFFadd_load_mcf = <0x%.8x>\n", status));
            _NFIdebug ((fname, "returning FAILURE\n"));
            return (status);
          }

        /*  Center the mcf and text on the form  */

        if ((status = _NFFcenter_gadget
            (form, NFI_VALIDATION_LIST)) != NFI_S_SUCCESS)
          {
            _NFIdebug ((fname, "_NFFcenter_gadget = <0x%.8x>\n", status));
            _NFIdebug ((fname, "returning FAILURE\n"));
            return (status);
          }

        if ((status = _NFFcenter_gadget
            (form, NFI_VALIDATION_TEXT)) != NFI_S_SUCCESS)
          {
            _NFIdebug ((fname, "_NFFcenter_gadget = <0x%.8x>\n", status));
            _NFIdebug ((fname, "returning FAILURE\n"));
            return (status);
          }

        FIg_add_to_group (form, NFI_VALIDATION_LIST, NFI_VALIDATION_GROUP);

        /*****************  WHY is this being done **********************/

        if ((status = (long) FIf_display (form)) != FI_SUCCESS)
          {
            _NFIdebug ((fname, "FIf_display = <%d>\n", status));
            ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIf_display", status);
            _NFIdebug ((fname, "returning FAILURE\n"));
            return (NFI_E_FORM);
          }

        /*  Make the first row the active row  */

        if ((status = (long) FIfld_set_active_row
            (form, NFI_VALIDATION_LIST, 0, 0)) != FI_SUCCESS)
          {
            _NFIdebug ((fname, "FIfld_set_active_row = <%d>\n", status));
            ERRload_struct
                (NFI, NFI_E_FORM, "%s%d", "FIfld_set_active_row", status);
            _NFIdebug ((fname, "returning FAILURE\n"));
            return (NFI_E_FORM);
          }

        *pos_cur = TRUE;
      }

    /*  Display any advisory information  */

    if ((status = _NFFset_advisory_info (form, ptr, count)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFset_advice_info = <0x%.8x>\n", status));
        _NFIdebug ((fname, "returning FAILURE\n"));
        return (status);
      }

    _NFIdebug ((fname, " returning SUCCESS\n"));
    return (NFI_S_SUCCESS);
  }


long _NFFset_advisory_info (form, ptr, act_col)
  Form          form;
  NFFadd_ptr    ptr;
  int           act_col;
  {
    auto    int     i, row_no;
    auto    int     attr_pos;
    auto    long    status;
    auto    char    **data_ptr;
    auto    short   offset;
    auto    int     label = NFI_ADVISORY_FIELD;
    static  char    *fname = "_NFFset_advisory_info";

    _NFIdebug ((fname, "label = <%d>\n", label));
    _NFIdebug ((fname, "act_col = <%d>\n", act_col));

    /*  Find the value list for this attribute  */

    data_ptr = (char **) (ptr->attr_list)->data_ptr;

    if ((status = _NFFfind_column_offset
        (ptr->attr_list, "n_advice", &offset)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFfind_column_offset = <0x%.8x>\n", status));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    /*  Find the row_no using the ptr->rows integer array  */

    for (i = 0, attr_pos = -1; i < (ptr->attr_list)->rows; ++i)
      {
        if (ptr->rows[i] == act_col)
          {
            attr_pos = i;
            break;
          }
      }

    _NFIdebug(( fname, "attr_pos <%d>\n", attr_pos ));
    _NFIdebug(( fname, "command <%d>\n", ptr->command ));
 
    if( (ptr->command == NFI_F_ADD)  ||
	(ptr->command == NFI_F_COPY) ||
	(ptr->command == NFI_F_CHANGE) )
        row_no = act_col * (ptr->attr_list)->columns;
    else if (attr_pos != -1) 
        row_no = attr_pos * (ptr->attr_list)->columns;
    else  
        row_no = act_col * (ptr->attr_list)->columns;

    _NFIdebug(( fname, "row_no <%d>\n", row_no ));

    /*  Put the text in the field  */

    _NFIdebug ((fname,
        "Setting <%s>\n in NFI_ADVISORY_FIELD\n", data_ptr[row_no + offset]));

/* IGI Intel Solaris Port -CN 31/5/95 */
#if defined(OS_SCO_UNIX) || defined(OS_INTELSOL) 
            /* work around change - to set font for SCO - SSRS 2 Feb 94 */
            FIg_set_font( form, label, "7x13bold", 15 );
#endif
    if ((status = FIfld_set_text
        (form, label, 0, 0, data_ptr[row_no + offset], FALSE)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_text", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    _NFIdebug ((fname, " returning SUCCESS\n"));
    return (NFI_S_SUCCESS);
  }


long _NFIload_copy_data (form, ptr, write_attr)
  Form          form;
  NFFadd_ptr    ptr;
  char          *write_attr;  /*  "n_write" or "n_update"  */
  {
    int     i, row;
    int     fields;
    long    status;
    char    *name;
    char    **attr_data;
    char    **data_data;
    short   type_offset;

    int     label = NFI_DATA_LIST;

    static  char *fname = "_NFIload_copy_data";

    _NFIdebug ((fname, "label = <%d>\n", label));
    _NFIdebug ((fname, "write_attr = <%s>\n", write_attr));

    _NFFinit_rows (ptr->attr_list, write_attr, &(ptr->rows));

    /*  Find the offsets in the buffer  */

    if ((status = _NFFfind_column_offset
        (ptr->attr_list, "n_datatype", &type_offset)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFfind_column_offset = <0x%.8x>\n", status));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

/* IGI Intel Solaris Port -CN 31/5/95 */
#if defined(OS_SCO_UNIX) || defined(OS_INTELSOL) 
    /* work around change - to set font for SCO - SSRS 2 Feb 94 */
    FIg_set_font( form, label, "7x13bold", 15 );
#endif

    attr_data = (char **) (ptr->attr_list)->data_ptr;
    data_data = (char **) (ptr->data_list)->data_ptr;

    fields = (ptr->attr_list)->rows * (ptr->attr_list)->columns;
    for (i = 0; i < fields; i += (ptr->attr_list)->columns)
      {
        row = i / (ptr->attr_list)->columns;

        /*  Only load in attributes that have read or write permission  */

        if ((ptr->rows)[row] == -1) continue;

        /*  Load in the attribute name  */

        if ((status = _NFFfind_attribute_name
            (ptr->attr_list, i, &name)) != NFI_S_SUCCESS)
          {
            _NFIdebug ((fname,
                "_NFFfind_attribute_name = <0x%.8x>\n", status));
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (status);
          }

        _NFIdebug ((fname, "Setting <%s>\n", name));
        _NFIdebug ((fname, " in row %d col %d\n", (ptr->rows)[row], 0));

        if ((status = FIfld_set_text
            (form, label, (ptr->rows)[row], 0, name, FALSE)) != FI_SUCCESS)
          {
            _NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
            ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_text", status);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_FORM);
          }

        /*  Load in "n_datatype"  */

        _NFIdebug ((fname, "Setting <%s>\n", attr_data[i + type_offset]));
        _NFIdebug ((fname, " in row %d col %d\n", (ptr->rows)[row], 1));

        if ((status = FIfld_set_text (form, label, (ptr->rows)[row],
            1, attr_data[i + type_offset], FALSE)) != FI_SUCCESS)
          {
            _NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
            ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_text", status);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_FORM);
          }

        /*  Load in any default value  */

        _NFIdebug ((fname, "Setting <%s>\n", data_data[row]));
        _NFIdebug ((fname, " in row %d col %d\n", (ptr->rows)[row], 2));

        if ((status = FIfld_set_text (form, label,
            (ptr->rows)[row], 2, data_data[row], FALSE)) != FI_SUCCESS)
          {
            _NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
            ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_text", status);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_FORM);
          }
      }

    _NFIdebug ((fname, " returning SUCCESS\n"));
    return (NFI_S_SUCCESS);
  }


long _NFFdisable_value_info (form, ptr)
  Form          form;
  NFFadd_ptr    ptr;
  {
    int     status;

    static  char *fname = "_NFFdisable_value_info";

    _NFIdebug ((fname, "label = <%d>\n", NFI_RANGE_GROUP));

    /*  Disable the range group  */

    if ((status = FIfld_set_text
        (form, NFI_MIN_FIELD, 0, 0, "", FALSE)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_text", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    if ((status = FIfld_set_text
        (form, NFI_MAX_FIELD, 0, 0, "", FALSE)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_text", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    if ((status = FIg_erase (form, NFI_RANGE_GROUP)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIg_erase = <%d>\n", status));
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_erase", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    /*  Unselect any selected row in the validate mcf  */

    if (ptr->validate_row != -1)
      {
        if ((status = FImcf_set_select (form, NFI_VALIDATION_LIST,
                                     ptr->validate_row, FALSE)) != FI_SUCCESS)
          {
            _NFIdebug ((fname, "FImcf_set_select = <%d>\n", status));
            ERRload_struct
                (NFI, NFI_E_FORM, "%s%d", "FImcf_set_select", status);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_FORM);
          }
      }

    /*  Erase the validate group  */

    if ((status = FIg_erase (form, NFI_VALIDATION_GROUP)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIg_erase = <%d>\n", status));
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_erase", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    _NFIdebug ((fname, " returning SUCCESS\n"));
    return (NFI_S_SUCCESS);
  }

/************************************************************************
 * Function _NFFdelete_data_rows                                        *
 *                                                                      *
 * This function will delete the row(s) of data from the mcf and the    *
 * data_list.                                                           *    
 * This function assumes that there is a one to one correspondence      *
 * between the data in the data_list and the mcf.                       * 
 *                                                                      *
 ************************************************************************/

long _NFFdelete_data_row (form, g_label, data_list, new_list)
  Form          form;
  int           g_label;
  MEMptr        data_list;
  MEMptr        *new_list;
  {
    long        status;
    int         i, j, count;
    int         rows = 0;
    int         sel_flag = FALSE;
    char        **data_ptr, **format_ptr, **column_ptr; 
    char        str[2048];

    static  char *fname = "_NFFdelete_data_row";

    _NFIdebug ((fname, "label = <%d>\n", g_label));

    if (data_list->rows <= 0)
     {
        status = NFI_W_NO_FILES_EXIST_IN_MCF;
        NFFform_message (CURRENT_LABEL, NFI_W_NO_FILES_EXIST_IN_MCF, NULL); 
        _NFIdebug ((fname, "No rows exist in the mcf field\n"));
        _NFIdebug ((fname, " returning SUCCESS\n"));
        return (status);
     }

    for (i = 0; i < data_list->rows; ++i)
     {
        status = (long) FIfld_get_select (form, g_label, i, 0, &sel_flag);
        if (status != FI_SUCCESS)
         {
            _NFIdebug ((fname, "FIfld_get_select = <%d>\n", status));
            ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_get_select",status);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_FORM);
         }

        if (sel_flag)
         {
           ++rows;
         }
     } 

    if (!rows)
     {
        status = NFI_W_NO_FILES_TO_DELETE;
        NFFform_message (CURRENT_LABEL, NFI_W_NO_FILES_TO_DELETE, NULL); 
        _NFIdebug ((fname, "No rows exist in the gadget field\n"));
        _NFIdebug ((fname, " returning SUCCESS\n"));
        return (status);
     }

    /*  Open the new_list */

   if ((status = MEMopen (new_list, data_list->rows * data_list->row_size +
                          MEM_SIZE)) != MEM_S_SUCCESS)
    {
        _NFIdebug ((fname, "MEMopen = <0x%.8x>\n", status));
        ERRload_struct (NFI, NFI_E_MEM, "%s%x", "MEMopen", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_MEM);
     }

    /*  Put the attributes into the new_list */
    
   column_ptr = (char **) data_list->column_ptr; 
   format_ptr = (char **) data_list->format_ptr; 
   data_ptr   = (char **) data_list->data_ptr; 

   for (i = 0; i < data_list->columns; ++i) 
    {
      if ((status = MEMwrite_format (*new_list, column_ptr[i], 
                                     format_ptr[i])) != MEM_S_SUCCESS)
       {
           _NFIdebug ((fname, "MEMwrite_format = <0x%.8x>\n", status));
           ERRload_struct (NFI, NFI_E_MEM, "%s%x", "MEMwrite_format", status);
           _NFIdebug ((fname, " returning FAILURE\n"));
           return (NFI_E_MEM);
        }
     }

    /* delete the selected row from the new_list */

    for (i = 0; i < data_list->rows; ++i)
     {
        status = (long) FIfld_get_select (form, g_label, i, 0, &sel_flag);
        if (status != FI_SUCCESS)
         {
            _NFIdebug ((fname, "FIfld_get_select = <%d>\n", status));
            ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_get_select",status);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_FORM);
         }

        if (!sel_flag)
         {
            str[0] = 0;
            for (j = 0; j < data_list->columns; ++j)
             {
                count = data_list->columns * i + j;
                strcat (str, data_ptr[count]);
                strcat (str, "\1");
             }

            if ((status = MEMwrite (*new_list, str)) != MEM_S_SUCCESS)
             {
                 _NFIdebug ((fname, "MEMwrite = <0x%.8x>\n", status));
                 ERRload_struct (NFI, NFI_E_MEM, "%s%x", "MEMwrite", status);
                 _NFIdebug ((fname, " returning FAILURE\n"));
                 return (NFI_E_MEM);
             }
         }
     } 

    status = MEMbuild_array (*new_list);
    if (status != MEM_S_SUCCESS)
     {
        _NFIdebug ((fname, "MEMbuild_array = <0x%.8x>\n", status));
        ERRload_struct (NFI, NFI_E_MEM, "%s%x", "MEMbuild_array", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_MEM);
     }

    /* Update the mcf */

    j = 0;
    for (i = 0; i < data_list->rows; ++i)
     {
        status = (long) FIfld_get_select (form, g_label, i - j, 0, &sel_flag);
        if (status != FI_SUCCESS)
         {
            _NFIdebug ((fname, "FIfld_get_select = <%d>\n", status));
            ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_get_select",status);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_FORM);
         }

        if (sel_flag)
         {
            status = (long) FIfld_delete_rows (form, g_label, i - j, 1);
            if (status != FI_SUCCESS)
             {
                _NFIdebug ((fname, "FIfld_delete_rows = <%d>\n", status));
                ERRload_struct
                    (NFI, NFI_E_FORM, "%s%d", "FIfld_delete_rows", status);
                _NFIdebug ((fname, " returning FAILURE\n"));
                return (NFI_E_FORM);
             }

            status = (long) FIfld_delete_rows (form, NFI_DATA_LIST, i - j, 1);
            if (status != FI_SUCCESS)
             {
                _NFIdebug ((fname, "FIfld_delete_rows = <%d>\n", status));
                ERRload_struct
                    (NFI, NFI_E_FORM, "%s%d", "FIfld_delete_rows", status);
                _NFIdebug ((fname, " returning FAILURE\n"));
                return (NFI_E_FORM);
             }
            ++j;
         }
     }

    _NFIdebug ((fname, " returning SUCCESS\n"));
    return (NFI_S_SUCCESS);
  }


long _NFFset_data_row_status (data_list)
  MEMptr        data_list;
  {
    long        status;
    int         i;
    short       status_offset = -1;

    static  char *fname = "_NFFset_data_row_status";

    _NFIdebug ((fname, " Function entered\n"));

    if (data_list->rows <= 0)
     {
        _NFIdebug ((fname, " The data_list has no rows\n"));
        _NFIdebug ((fname, " returning SUCCESS\n"));
        return (NFI_S_SUCCESS);
     }

    status = MEMbuild_array (data_list);
    if (status != MEM_S_SUCCESS)
     {
        _NFIdebug ((fname, "MEMbuild_array = <0x%.8x>\n", status));
        ERRload_struct (NFI, NFI_E_MEM, "%s%x", "MEMbuild_array", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_MEM);
     }

    /* Get the "n_action" offset in the data_list  */

    status = _NFFfind_column_offset (data_list, "n_action", &status_offset); 
    if (status != NFI_S_SUCCESS)
     {
        _NFIdebug ((fname, "NFFfind_column_offset = <0x%.8x>\n", status));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
     }

    for (i = 0; i < data_list->rows; ++i)
     {
         status = MEMwrite_data (data_list, "ADD", i + 1, status_offset + 1);
         if (status != MEM_S_SUCCESS)
          {
             _NFIdebug ((fname, "MEMwrite_data = <0x%.8x>\n", status));
             ERRload_struct (NFI, NFI_E_MEM, "%s%x", "MEMwrite_data", status);
             _NFIdebug ((fname, " returning FAILURE\n"));
             return (NFI_E_MEM);
          }
     }

    _NFIdebug ((fname, " returning SUCCESS\n"));
    return (NFI_S_SUCCESS);
  }


/*****************************************************************************
 *                                                                           *
 *  Function : _NFFadd_data_row                                              *
 *                                                                           *
 *  This function will only add a new row of data to a field SCF or MCFs     *
 *  and it will add a row to the data_list defaulting all the input data     *
 *  to the values in the 1st row in the buffer row [0]                       *
 *                                                                           *
 *****************************************************************************/

long _NFFadd_data_row (form, g_label, act_row, act_col, row_array,
                       data_list, temp_list)
  Form          form;
  int           g_label;
  int           *act_row;
  int           *act_col;
  int           row_array[]; 
  MEMptr        data_list;
  MEMptr        temp_list;
  {
    long        status = NFI_S_SUCCESS;
    short       status_offset = -1;
    int         i, num_rows = 0;
    char        **data_ptr;
    char        *str;

    static  char *fname = "_NFFadd_data_row";

    _NFIdebug ((fname, "label = <%d>\n", g_label));

    /* Get the number of rows in the list */

    status = (long) FIfld_get_num_rows (form, g_label, &num_rows);
    if (status != FI_SUCCESS)
     {
        _NFIdebug ((fname, "FIfld_get_num_rows = <%d>\n", status));
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_get_num_rows", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
     }

    if ((num_rows <= 0) || (data_list->rows <= 0))
     {
        /* Set the number of rows in the field to zero to clear it out */

        status = (long) FIfld_set_num_rows (form, g_label, 0);
        if (status != FI_SUCCESS)
         {
            _NFIdebug ((fname, "FIfld_set_num_rows = <%d>\n", status));
            ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_num_rows",
                            status);

            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_FORM);
         }

        num_rows = 0;  

        /* Set the number of rows in the field to zero to clear it out */

        status = (long) FIfld_set_num_rows (form, NFI_DEL_DATA_LIST, 0);
        if (status != FI_SUCCESS)
         {
            _NFIdebug ((fname, "FIfld_set_num_rows = <%d>\n", status));
            ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_num_rows",
                            status);

            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_FORM);
         }
     }

    /* Get the "n_action" offset in the data_list */

    status = _NFFfind_column_offset (data_list, "n_action", &status_offset); 
    if (status != NFI_S_SUCCESS)
     {
        _NFIdebug ((fname, "The status attribute 'n_action' does not exist\n"));

        /* check to see if the offset is called "n_status" */

        status = _NFFfind_column_offset (data_list, "n_status", &status_offset);
        if (status != NFI_S_SUCCESS)
         {
            _NFIdebug ((fname, "NFFfind_column_offset = <0x%.8x>\n", status));

            /*  There is no status attribute to update... continue on. */

            status_offset = -1; 
         } 
        ERRreset_struct ();
     }

    str = (char *) malloc (data_list->row_size + MEM_SIZE);
    if (!str)
     {
        _NFIdebug ((fname, "malloc failed; size = <%d>\n", data_list->row_size +
                    MEM_SIZE));
        ERRload_struct (NFI, NFI_E_MALLOC, "%d",
                        data_list->row_size + MEM_SIZE);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_MALLOC);
     }

    _NFIdebug ((fname, "num_rows = <%d>\n", num_rows));

    status = (long) FIfld_set_num_rows (form, g_label, num_rows + 1);
    if (status != FI_SUCCESS)
     {
        free (str);
        _NFIdebug ((fname, "FIfld_set_num_rows = <%d>\n", status));
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_num_rows",
                        status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
     }

    status = (long) FIfld_set_num_rows (form, NFI_DEL_DATA_LIST, num_rows + 1);
    if (status != FI_SUCCESS)
     {
        free (str);
        _NFIdebug ((fname, "FIfld_set_num_rows = <%d>\n", status));
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_num_rows",
                        status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
     }

    data_ptr = (char **) temp_list->data_ptr;
    str[0] = 0;

    /* update the n_status field for the row */

/* IGI Intel Solaris Port -CN 31/5/95 */
#if defined(OS_SCO_UNIX) || defined(OS_INTELSOL) 
            /* work around change - to set font for SCO - SSRS 2 Feb 94 */
            FIg_set_font( form, g_label, "7x13bold", 15 );
            FIg_set_font( form, NFI_DEL_DATA_LIST, "7x13bold", 15 );
#endif

    for (i = 0; i < temp_list->columns; ++i)
     {
        if (i == status_offset) 
         {
            strcat (str, "ADD"); 
            strcat (str, "\1"); 
         }
        else
         {
            strcat (str, data_ptr[i]); 
            strcat (str, "\1"); 
         }

        if (row_array[i] != -1)
         {
            status = (long) FIfld_set_text (form, g_label, num_rows,
                                            row_array[i], data_ptr[i], FALSE);
            if (status != FI_SUCCESS)
             {
                free (str);
                _NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
                ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_text",
                                status);
                _NFIdebug ((fname, " returning FAILURE\n"));
                return (NFI_E_FORM);
             }

            status = (long) FIfld_set_text (form, NFI_DEL_DATA_LIST,
                               num_rows, row_array[i], data_ptr[i], FALSE);
            if (status != FI_SUCCESS)
             {
                free (str);
                _NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
                ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_text",
                                status);
                _NFIdebug ((fname, " returning FAILURE\n"));
                return (NFI_E_FORM);
             }
         }
     }

    _NFIdebug ((fname, "str = <%s>\n", str));
    status = MEMwrite (data_list, str);
    free (str);
    if (status != MEM_S_SUCCESS)
     {
        _NFIdebug ((fname, "MEMwrite = <0x%.8x>\n", status));
        ERRload_struct (NFI, NFI_E_MEM, "%s%x", "MEMwrite", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_MEM);
     }

    status = MEMbuild_array (data_list);
    if (status != MEM_S_SUCCESS)
     {
        _NFIdebug ((fname, "MEMbuild_array = <0x%.8x>\n", status));
        ERRload_struct (NFI, NFI_E_MEM, "%s%x", "MEMbuild_array", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_MEM);
     }

     /* unselect the current row/column */

     if (*act_row >= 0)
      {
         status = (long) FIfld_set_select (form, g_label, *act_row, *act_col, FALSE);
         if (status != FI_SUCCESS)
          {
             _NFIdebug ((fname, "FIfld_pos_cursor = <%d>\n", status));
             ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_pos_cursor", status);
             _NFIdebug ((fname, " returning FAILURE\n"));
             return (NFI_E_FORM);
          } 
      }

    *act_row = *act_row + 1;
    *act_col = 0;

    _NFIdebug ((fname, " returning SUCCESS\n"));
    return (NFI_S_SUCCESS);
  }

long _NFFcreate_validation_mcf (form, label, value_list)
  Form      form;
  int       label;
  MEMptr    value_list;
  {
    auto    int     i, j;
    auto    int     status;
    auto    int     num_cols;
    auto    int     num_rows;
    auto    int     num_chars;
    auto    int     vis_columns;
    auto    int     num_vis_cols;
    auto    int     attr_mask;
    auto    int     xpos, ypos;
    auto    int     justification;
    auto    int     total_data;
    auto    int     largest_data;
    auto    char    **data_ptr;
    auto    struct  standard_st st_var;
    static  char    *fname = "_NFFcreate_validation_mcf";

    _NFIdebug ((fname, "label = <%d>\n", label));

    /*  Load the standard variable structure  */

    _NFIdebug ((fname, "Getting the location of the mcf\n"));

    if ((status = FIg_get_location
        (form, label, &xpos, &ypos)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIg_get_location = <%d>\n", status));
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_get_location", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    _NFIdebug ((fname, "xpos, ypos = (%d, %d)\n", xpos, ypos));

    /*  Get the number of visible columns from the mcf  */

    _NFIdebug ((fname,
        "Getting the number of visible columns of the hidden mcf\n"));

    if ((status = FImcf_get_num_vis_cols
        (form, label, &num_vis_cols)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FImcf_get_num_vis_cols = <%d>\n", status));
        ERRload_struct
            (NFI, NFI_E_FORM, "%s%d", "FImcf_get_num_vis_cols", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    _NFIdebug ((fname, "num_vis_cols = <%d>\n", num_vis_cols));

    /*  Get the number of visible rows  */

    if ((status = FIfld_get_num_vis_rows
        (form, label, &num_rows)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIfld_get_num_vis_rows = <%d>\n", status));
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_get_num_rows", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    _NFIdebug ((fname, "Number of visible rows to %d\n", num_rows));

    /*  Get the number of visible characters in the first column  */

    _NFIdebug ((fname,
        "Getting the number of visible characters from the mcf\n"));

    if ((status = FIfld_get_num_vis_chars
        (form, label, 0, &num_chars)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIfld_get_num_vis_chars = <%d>\n", status));
        ERRload_struct
            (NFI, NFI_E_FORM, "%s%d", "FIfld_get_num_vis_chars", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    /*  Delete the existing mcf  */

    _NFIdebug ((fname, "Deleting the existing mcf\n"));

    if ((status = FIg_delete (form, label)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIg_delete = <%d>\n", status));
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_delete", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    /*  Create the new mcf  */

    _NFIdebug ((fname, "Creating the new mcf\n"));

    if ((status = FIg_new (form, FI_MULTI_COL, label)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIg_new = <%d>\n", status));
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FI", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    /*  Load the standard variable structure  */

    st_var.xlo = xpos;
    st_var.ylo = ypos;
#if defined(OS_INTELSOL) /* IGI Intel Solaris Port 16/08/95 */  
    st_var.xhi = 400; 
    st_var.yhi = 340; 
#else  
    st_var.xhi = 0;
    st_var.yhi = 0;
#endif 
    st_var.attr_mask = FI_NOT_DISPLAYED;
    st_var.value = (double) 0;
    st_var.bodysize = 15.0;
    st_var.text = NULL;
    st_var.help_topic = NULL;
    st_var.command = NULL;
    /* fonts SSRS 28 Jan 94 */
/* IGI Intel Solaris Port -CN 31/5/95 */
#if defined(OS_SCO_UNIX) || defined(OS_INTELSOL) 
    st_var.fontname = "7x13bold";
#else
    st_var.fontname = "mono821b";
#endif
    st_var.user_pointer = NULL;
    st_var.off_color = FI_BLACK;
    st_var.on_color = FI_YELLOW;
    st_var.off_color2 = 0;
    st_var.on_color2 = 0;
    st_var.symbol_index = 0;
    st_var.symbol_index2 = 0;
    st_var.next_in_seq = 0;

    /*  Set the standard variable structure for the mcfs  */

    _NFIdebug ((fname, "Setting the standard variables\n"));

    if ((status = FIg_set_standard_variables
        (form, label, &st_var)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIg_set_standard_variables = <%d>\n", status));
        ERRload_struct
            (NFI, NFI_E_FORM, "%s%d", "FIg_set_standard_variables", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    /*  Make sure the characteristics mask is set  */

    _NFIdebug ((fname, "Setting the attr_mask to FI_NOT_DISPLAYED\n"));

    if ((status = FIg_set_attr
        (form, label, FI_NOT_DISPLAYED)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIg_set_attr = <%d>\n", status));
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_set_attr", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

/*
    _NFIdebug ((fname, "Erasing the MCF\n"));

    if ((status = FIg_erase (form, label)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIg_erase = <%d>\n", status));
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_erase", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }
*/

    /*  Find out how many columns to set  */

    num_cols = 0;
    vis_columns = 0;
    for (i = 0; i < value_list->columns; ++i)
      {
        ++num_cols;

        if (vis_columns < num_vis_cols) ++vis_columns;
      }

    /*  Set the number of columns  */

    _NFIdebug ((fname, "Setting number of columns to %d\n", num_cols));

    if ((status = FImcf_set_num_cols
        (form, label, num_cols)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FImcf_set_num_cols = <%d>\n", status));
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FImcf_set_num_cols", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    /*  Set the number of visible rows  */

    _NFIdebug ((fname, "Setting number of visible rows to %d\n", num_rows));

    if ((status = FIfld_set_num_vis_rows
        (form, label, num_rows)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIfld_set_num_vis_rows = <%d>\n", status));
        ERRload_struct
            (NFI, NFI_E_FORM, "%s%d", "FIfld_set_num_vis_rows", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    attr_mask = FI_VERT_SCROLL | FI_HORT_SCROLL;
    attr_mask |= FI_DISPLAY_VSCROLL | FI_ROW_SELECT | FI_NO_ROW_BUTTONS;

    if (num_cols > vis_columns)
        attr_mask |= FI_DISPLAY_HSCROLL;
    else
        attr_mask |= FI_DISABLE_HSCROLL;

    if ((status = FImcf_set_attr (form, label, attr_mask)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FImcf_set_attr = <%d>\n", status));
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FImcf_set_attr", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    /*  Get the number of visible characters in the first column  */

    _NFIdebug ((fname,
        "Getting the number of visible characters from the hidden mcf\n"));

    justification = FI_LEFT_JUSTIFIED;

    for (i = 0; i < value_list->columns; ++i)
      {
        /*  Set the number of visible characters  */

        _NFIdebug ((fname,
            "%d: Setting number of visible characters to %d\n", i, num_chars));

        if ((status = FIfld_set_num_vis_chars
            (form, label, i, num_chars)) != FI_SUCCESS)
          {
            _NFIdebug ((fname, "FIfld_set_num_vis_chars = <%d>\n", status));
            ERRload_struct
                (NFI, NFI_E_FORM, "%s%d", "FIfld_set_num_vis_chars", status);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_FORM);
          }

        /*  Set the mode for the columns  */

        _NFIdebug ((fname, "%d: Setting the mode to FI_SINGLE_SELECT\n", i));

        if ((status = FIfld_set_mode
            (form, label, i, FI_SINGLE_SELECT)) != FI_SUCCESS)
          {
            _NFIdebug ((fname, "FIfld_set_mode = <%d>\n", status));
            ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_mode", status);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_FORM);
          }

        /*  Set the justification for the columns  */

        _NFIdebug ((fname, "%d: Setting the justification\n", i));

        if ((status = FImcf_set_justification
            (form, label, i, justification)) != FI_SUCCESS)
          {
            _NFIdebug ((fname, "FImcf_set_justification = <%d>\n", status));
            ERRload_struct
                (NFI, NFI_E_FORM, "%s%d", "FImcf_set_justification", status);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_FORM);
          }

        /*  Set the type for the columns  */

        _NFIdebug ((fname, "%d: Setting the type to FI_ALPHA\n", i));

        if ((status = FIfld_set_type
            (form, label, i, FI_ALPHA)) != FI_SUCCESS)
          {
            _NFIdebug ((fname, "FIfld_set_type = <%d>\n", status));
            ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_type", status);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_FORM);
          }

        /*  Find out how big the largest row of data in this column is  */

        total_data = value_list->columns * value_list->rows;
        data_ptr = (char **) value_list->data_ptr;
        largest_data = i;

        for (j = i; j < total_data; j += value_list->columns)
          {
            if ((strlen (data_ptr[j])) > (strlen (data_ptr[largest_data])))
                largest_data = j;
          }

        _NFIdebug ((fname,
            "%d: largest_data = <%s>\n", i, data_ptr[largest_data]));

        if ((status = FIfld_get_attr
            (form, label, i, &attr_mask)) != FI_SUCCESS)
          {
            _NFIdebug ((fname, "FIfld_get_attr = <%d>\n", status));
            ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_get_attr", status);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_FORM);
          }

        _NFIdebug ((fname, "%d: Setting FI_NOTIFY_BY_LINE\n", i));

        attr_mask |= FI_NOTIFY_BY_LINE;

        if ((strlen (data_ptr[largest_data])) > num_chars)
          {
            _NFIdebug ((fname,
                "%d: Setting FI_HORT_SCROLL and FI_DISPLAY_HSCROLL\n", i));

            attr_mask |= FI_HORT_SCROLL | FI_DISPLAY_HSCROLL;
          }

        if ((status = FIfld_set_attr
            (form, label, i, attr_mask)) != FI_SUCCESS)
          {
            _NFIdebug ((fname, "FIfld_set_attr = <%d>\n", status));
            ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_attr", status);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_FORM);
          }
      }

    /*  Set the number of visible columns  */

    _NFIdebug ((fname,
        "Setting number of visible columns to %d\n", vis_columns));

    if ((status = FImcf_set_num_vis_cols
        (form, label, vis_columns)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FImcf_set_num_vis_cols = <%d>\n", status));
        ERRload_struct
            (NFI, NFI_E_FORM, "%s%d", "FImcf_set_num_vis_cols", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    /*  Set the maximum number of rows to be infinite  */

    _NFIdebug ((fname, "Setting max num rows to 0\n"));

    if ((status = FIfld_set_max_num_rows (form, label, 0)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIfld_set_max_num_rows = <%d>\n", status));
        ERRload_struct
            (NFI, NFI_E_FORM, "%s%d", "FIfld_set_max_num_rows", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    /*  Activate the gadget  */

    _NFIdebug ((fname, "Activating the mcf\n"));

    if ((status = FIg_activate (form, label)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIg_activate = <%d>\n", status));
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_activate", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    _NFIdebug ((fname, " returning SUCCESS\n"));
    return (NFI_S_SUCCESS);
  }


/************************************************************************
 *                                                                      *
 * Function _NFFdelete_add_rows                                         *
 *                                                                      *
 * This function will delete the row(s) of data from the mcf and the    *
 * data_list.                                                           *    
 *                                                                      *
 ************************************************************************/

long _NFFdelete_add_rows (form, g_label, act_row, act_col, data_list, new_list)
  Form          form;
  int           g_label;
  int           *act_row;
  int           *act_col;
  MEMptr        data_list;
  MEMptr        *new_list;
  {
    long        status;
    int         i, j, count;
    int         num_rows = 0;
    int         rows = 0;
    int         sel_flag = FALSE;
    char        **data_ptr, **format_ptr, **column_ptr; 
    char        str[2048];

    static  char *fname = "_NFFdelete_add_rows";

    _NFIdebug ((fname, "label = <%d>\n", g_label));

    if (data_list->rows <= 0)
     {
        status = NFI_W_NO_FILES_EXIST_IN_MCF;
        NFFform_message (CURRENT_LABEL, NFI_W_NO_FILES_EXIST_IN_MCF, NULL); 
        _NFIdebug ((fname, "No rows exist in the mcf field\n"));
        _NFIdebug ((fname, " returning SUCCESS\n"));
        return (status);
     }

    for (i = 0; i < data_list->rows; ++i)
     {
        status = (long) FIfld_get_select (form, g_label, i, 0, &sel_flag);
        if (status != FI_SUCCESS)
         {
            _NFIdebug ((fname, "FIfld_get_select = <%d>\n", status));
            ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_get_select",status);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_FORM);
         }

        if (sel_flag)
         {
           ++rows;
           ++num_rows;
         }
     } 

    if (!rows)
     {
        status = NFI_W_NO_FILES_TO_DELETE;
        NFFform_message (CURRENT_LABEL, NFI_W_NO_FILES_TO_DELETE, NULL); 
        _NFIdebug ((fname, "No rows exist in the gadget field\n"));
        _NFIdebug ((fname, " returning SUCCESS\n"));
        return (status);
     }

    /*  Open the new_list */

   if ((status = MEMopen (new_list, data_list->rows * data_list->row_size +
                          MEM_SIZE)) != MEM_S_SUCCESS)
    {
        _NFIdebug ((fname, "MEMopen = <0x%.8x>\n", status));
        ERRload_struct (NFI, NFI_E_MEM, "%s%x", "MEMopen", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_MEM);
     }

    /*  Put the attributes into the new_list */
    
   column_ptr = (char **) data_list->column_ptr; 
   format_ptr = (char **) data_list->format_ptr; 
   data_ptr   = (char **) data_list->data_ptr; 

   for (i = 0; i < data_list->columns; ++i) 
    {
      if ((status = MEMwrite_format (*new_list, column_ptr[i], 
                                     format_ptr[i])) != MEM_S_SUCCESS)
       {
           _NFIdebug ((fname, "MEMwrite_format = <0x%.8x>\n", status));
           ERRload_struct (NFI, NFI_E_MEM, "%s%x", "MEMwrite_format", status);
           _NFIdebug ((fname, " returning FAILURE\n"));
           return (NFI_E_MEM);
        }
     }

    /* Add the unselected rows to the new_list */

    for (i = 0; i < data_list->rows; ++i)
     {
        sel_flag = FALSE;
        status = (long) FIfld_get_select (form, g_label, i, 0, 
                                              &sel_flag);
        if (status != FI_SUCCESS)
         {
            _NFIdebug ((fname, "FIfld_get_select = <%d>\n", status));
            ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_get_select",
                            status);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_FORM);
         }

        if (!sel_flag)
         {
            str[0] = 0;
            for (j = 0; j < data_list->columns; ++j)
             {
                count = data_list->columns * i + j;
                strcat (str, data_ptr[count]);
                strcat (str, "\1");
             }

            if ((status = MEMwrite (*new_list, str)) != MEM_S_SUCCESS)
             {
                 _NFIdebug ((fname, "MEMwrite = <0x%.8x>\n", status));
                 ERRload_struct (NFI, NFI_E_MEM, "%s%x", "MEMwrite", status);
                 _NFIdebug ((fname, " returning FAILURE\n"));
                 return (NFI_E_MEM);
             }
         }
        else
         {
            if (*act_row == i)
             {
                /* the active row is no longer valid.  It is to be deleted */
    
                *act_row = 0;
                *act_col = 0;
             } 
         }
     } 

    status = MEMbuild_array (*new_list);
    if (status != MEM_S_SUCCESS)
     {
        _NFIdebug ((fname, "MEMbuild_array = <0x%.8x>\n", status));
        ERRload_struct (NFI, NFI_E_MEM, "%s%x", "MEMbuild_array", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_MEM);
     }

    /* Update the mcf */

    j = 0;
    for (i = 0; i < data_list->rows; ++i)
     {
        status = (long) FIfld_get_select (form, g_label, i - j, 0, &sel_flag);
        if (status != FI_SUCCESS)
         {
            _NFIdebug ((fname, "FIfld_get_select = <%d>\n", status));
            ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_get_select",status);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_FORM);
         }

        if (sel_flag)
         {
            status = (long) FIfld_delete_rows (form, g_label, i - j, 1);
            if (status != FI_SUCCESS)
             {
                _NFIdebug ((fname, "FIfld_delete_rows = <%d>\n", status));
                ERRload_struct
                    (NFI, NFI_E_FORM, "%s%d", "FIfld_delete_rows", status);
                _NFIdebug ((fname, " returning FAILURE\n"));
                return (NFI_E_FORM);
             }

            status = (long) FIfld_delete_rows (form, NFI_DATA_LIST, i - j,
                                               1);
            if (status != FI_SUCCESS)
             {
                _NFIdebug ((fname, "FIfld_delete_rows = <%d>\n", status));
                ERRload_struct
                    (NFI, NFI_E_FORM, "%s%d", "FIfld_delete_rows", status);
                _NFIdebug ((fname, " returning FAILURE\n"));
                return (NFI_E_FORM);
             }
            ++j;
         }
     }

    _NFIdebug ((fname, " num_rows = <%d>\n", num_rows));

    if (num_rows >= data_list->rows)
     {
        *act_row = -1;
        *act_col = 0;
        _NFIdebug ((fname, " Clearing out the MCF's\n"));
        
        /* clear out the MCF's */

        status = (long) FIfld_set_num_rows (form, NFI_DATA_LIST, 0);
        if (status != FI_SUCCESS)
         {
            _NFIdebug ((fname, " returning SUCCESS\n"));
            return (NFI_S_SUCCESS);
         }

        status = (long) FIfld_set_num_rows (form, g_label, 0);
        if (status != FI_SUCCESS)
         {
            _NFIdebug ((fname, " returning SUCCESS\n"));
            return (NFI_S_SUCCESS);
         }
     }

    _NFIdebug ((fname, " returning SUCCESS\n"));
    return (NFI_S_SUCCESS);
  }

long _NFFselect_all_rows (form, g_label, row_array, data_list)
  Form          form;
  int           g_label;
  int           row_array[];
  MEMptr        data_list;
  {
    long        status = NFI_S_SUCCESS;
    int         i, j;
    int         state = FALSE;

    static  char *fname = "_NFFselect_all_rows";

    _NFIdebug ((fname, "label = <%d>\n", g_label));

    /* get the gadget state */

    status = (long) FIg_get_state (form, NFI_DELETE_FILE_TOGGLE, &state);
    if (status != FI_SUCCESS)
     {
        _NFIdebug ((fname, "FIg_get_state = <%d>\n", status));
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_get_state",status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
     }

    if (!state)  /*  files will be selected individually  */
     {
        _NFIdebug ((fname, "Files will be selected individually\n"));
        _NFIdebug ((fname, " returning SUCCESS\n"));
        return (NFI_S_SUCCESS);
     }

    if (data_list->rows <= 0)
     {
        NFFform_message (CURRENT_LABEL, NFI_W_NO_FILES_EXIST_IN_MCF, NULL); 
        _NFIdebug ((fname, "No rows exist in the mcf field\n"));
        _NFIdebug ((fname, " returning SUCCESS\n"));
        return (NFI_S_SUCCESS);
     }

    for (i = 0; i < data_list->rows; ++i)
     {
        for (j = 0; j < data_list->columns; ++j)
         {
            if (row_array[j] != -1)
             {
                status = (long) FIfld_set_select (form, g_label, i,
                                                  row_array[j], TRUE);
                if (status != FI_SUCCESS)
                 {
                    _NFIdebug ((fname, "FIfld_set_select = <%d>\n", status));
                    ERRload_struct (NFI, NFI_E_FORM, "%s%d",
                                    "FIfld_set_select",status);
                    _NFIdebug ((fname, " returning FAILURE\n"));
                    return (NFI_E_FORM);
                 }
             }
         }
     } 

    _NFIdebug ((fname, " returning SUCCESS\n"));
    return (NFI_S_SUCCESS);
  }

/************************************************************************
 * Function _NFFset_delete_data_rows                                    *
 *                                                                      *
 * This function will mark the rows to be deleted in the data_list.     *
 *                                                                      *
 * This function assumes that there is a one to one correspondence      *
 * between the data in the data_list and the mcf.                       * 
 *                                                                      *
 ************************************************************************/

long _NFFset_delete_data_rows (form, g_label, data_list)
  Form          form;
  int           g_label;
  MEMptr        data_list; 
  {
    long        status;
    int         i;
    int         rows = 0;
    short       status_offset;
    int         sel_flag = FALSE;

    static  char *fname = "_NFFset_delete_data_rows";

    _NFIdebug ((fname, "label = <%d>\n", g_label));

    if (data_list->rows <= 0)
     {
        status = NFI_W_NO_FILES_EXIST_IN_MCF;
      /* NFFform_message (CURRENT_LABEL, NFI_W_NO_FILES_EXIST_IN_MCF, NULL); */
        ERRload_struct (NFI, status, NULL);
        _NFIdebug ((fname, "No rows exist in the mcf field\n"));
        _NFIdebug ((fname, " returning WARNING\n"));
        return (status);
     }

    /* find the n_status offset */

    if ((status = _NFFfind_column_offset (data_list, "n_status",
                                          &status_offset)) != NFI_S_SUCCESS)
     {
        _NFIdebug ((fname, "_NFFfind_column_offset = <0x%.8x>\n", status));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
     }

    for (i = 0; i < data_list->rows; ++i)
     {
        status = (long) FIfld_get_select (form, g_label, i, 0, &sel_flag);
        if (status != FI_SUCCESS)
         {
            _NFIdebug ((fname, "FIfld_get_select = <%d>\n", status));
            ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_get_select",status);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_FORM);
         }

        if (sel_flag)
         {
            /* write the "Y" keyword into the row in the n_status field */

            if ((status = MEMwrite_data (data_list, "Y", i + 1,
                                         status_offset + 1)) != MEM_S_SUCCESS)
             {
                 _NFIdebug ((fname, "MEMwrite_data = <0x%.8x>\n", status));
                 ERRload_struct (NFI, NFI_E_MEM, "%s%x", "MEMwrite_data",
                                 status);
                 _NFIdebug ((fname, " returning FAILURE\n"));
                 return (NFI_E_MEM);
             }
           ++rows;
         }
     } 

    if (!rows)
     {
        status = NFI_W_NO_FILES_TO_DELETE;
        /* NFFform_message (CURRENT_LABEL, NFI_W_NO_FILES_TO_DELETE, NULL); */
        _NFIdebug ((fname, "No rows exist in the gadget field\n"));
        ERRload_struct (NFI, status, NULL);
        _NFIdebug ((fname, " returning WARNING\n"));
        return (status);
     }

    _NFIdebug ((fname, " returning SUCCESS\n"));
    return (NFI_S_SUCCESS);
  }

long _NFFnadd_validate_text (text, value_list, val_col)
  char      *text;
  MEMptr    value_list;
  int       val_col;
  {
    int     i, count;
    int     cur_col;
    char    **data_ptr;
    short   found = FALSE;

    static  char *fname = "_NFFnadd_validate_text";

    _NFIdebug ((fname, "text = <%s>\n", text));

    cur_col = val_col; 
    if ((val_col < 0) || (val_col >= value_list->columns))
       cur_col = 0;

    data_ptr = (char **) value_list->data_ptr;

    for (i = 0; i < value_list->rows; ++i)
      {
        count = value_list->columns * i + cur_col;

        /*  Check the column pointed to by cur_col  */

        if ((strcmp (text, data_ptr[count])) == 0)
         {
            found = TRUE;
            break;
          }
      }

    if (found == TRUE)
      {
        _NFIdebug ((fname, " returning SUCCESS\n"));
        return (NFI_S_SUCCESS);
      }
    else
      {
        ERRload_struct (NFI, NFI_E_VALID, NULL);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_VALID);
      }
  }



long _NFFprocess_validate_accept (form, write_attr, act_row, act_col, ptr,
                                  val_col)
  Form          form;
  char          *write_attr;  /*  "n_write" or "n_update"  */
  int           *act_row;
  int           *act_col;
  NFFadd_ptr    ptr;
  int           val_col; /* the column of data to use in validation_list */
  {
    int     i, j;
    int     column;
    int     position, count;
    long    status;
    char    **attr_ptr;
    char    **data_ptr;
    char    *attrname;
    short   nfm_offset;
    short   write_offset;
    short   null_offset;

    static  char *fname = "_NFFprocess_validate_accept";

    _NFIdebug ((fname, "write_attr = <%s>\n", write_attr));
    _NFIdebug ((fname, "data_list->rows = <%d>\n", (ptr->data_list)->rows));
    _NFIdebug ((fname, "val_col = <%d>\n", val_col));

    /*  See if there is any data at all  */

    if ((ptr->data_list)->rows == 0)
      {
        ptr->done = FALSE;
        _NFIdebug ((fname, " returning SUCCESS\n"));
        return (NFI_S_SUCCESS);
      }

    if ((status = MEMbuild_array (ptr->attr_list)) != MEM_S_SUCCESS)
      {
        _NFIdebug ((fname, "MEMbuild_array = <0x%.8x>\n", status));
        ERRload_struct (NFI, NFI_E_MEM, "%s%x", "MEMbuild_array", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_MEM);
      }

    attr_ptr = (char **) (ptr->attr_list)->data_ptr;

    if ((status = MEMbuild_array (ptr->data_list)) != MEM_S_SUCCESS)
      {
        _NFIdebug ((fname, "MEMbuild_array = <0x%.8x>\n", status));
        ERRload_struct (NFI, NFI_E_MEM, "%s%x", "MEMbuild_array", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_MEM);
      }

    data_ptr = (char **) (ptr->data_list)->data_ptr;

    /*  Make sure that there is data for all non-NULL attributes  */

    if ((status = _NFFfind_column_offset
        (ptr->attr_list, "n_name", &nfm_offset)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFfind_column_offset = <0x%.8x>\n", status));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    if ((status = _NFFfind_column_offset
        (ptr->attr_list, write_attr, &write_offset)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFfind_column_offset = <0x%.8x>\n", status));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    if ((status = _NFFfind_column_offset
        (ptr->attr_list, "n_null", &null_offset)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFfind_column_offset = <0x%.8x>\n", status));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    /*  Assume that we are finished  */

    ptr->done = TRUE;
    
    column = 0;
    for (i = 0; i < (ptr->data_list)->rows; ++i) 
     {
       for (j = 0; j < (ptr->data_list)->columns; ++j)
       { 
         column = (ptr->data_list)->columns * i + j; 
         count = (ptr->attr_list)->columns * j; 
        /*  See if this attribute can be written to  */

        if ((strcmp (attr_ptr[count + write_offset], "Y")) != 0)
          {
            /*  Don't validate  */

            continue;
          }

        /*  See if this attribute can have NULL values  */

        if ((strcmp (attr_ptr[count + null_offset], "Y")) != 0)
          {
            _NFIdebug ((fname, "checking <%s>\n", attr_ptr[count + nfm_offset]));
            _NFIdebug ((fname, "%s has a value of <%s>\n",
                attr_ptr[count + nfm_offset], data_ptr[column]));

            /*  See if this attribute has a value  */

            if ((strcmp (data_ptr[column], "")) == 0)
              {
                /*  Find the attribute name (or synonym if it exists)  */

                if ((status = _NFFfind_attribute_name
                    (ptr->attr_list, count, &attrname)) != NFI_S_SUCCESS)
                  {
                    _NFIdebug ((fname,
                        "_NFFfind_attribute_name = <0x%.8x>\n", status));
                    ptr->done = FALSE;
                    _NFIdebug ((fname, " returning FAILURE\n"));
                    return (status);
                  }

                ptr->done = FALSE;

                /*  Position the offending row in the center of the mcf  */

                if (i < 3)
                    position = i;
                else
                    position = 3;

                if ((status = FIfld_set_active_row (form, NFI_DATA_LIST,
                                                    i, position)) != FI_SUCCESS)
                  {
                    _NFIdebug ((fname,
                        "FIfld_set_active_row = <%d>\n", status));
                    ERRload_struct (NFI,
                        NFI_E_FORM, "%s%d", "FIfld_set_active_row", status);
                    _NFIdebug ((fname, " returning FAILURE\n"));
                    return (NFI_E_FORM);
                  }
                 
                /* Unselect the current active row */

                FIfld_set_select (form, NFI_DATA_LIST, *act_row, *act_col,
                                  FALSE);

                /*  Set the lower half as if the user selected this row  */

                if ((status = FIfld_set_select (form, NFI_DATA_LIST,
                                 i, (ptr->rows)[j], TRUE)) != FI_SUCCESS)
                  {
                    _NFIdebug ((fname, "FIfld_set_select = <%d>\n", status));
                    ERRload_struct
                        (NFI, NFI_E_FORM, "%s%d", "FIfld_set_select", status);
                    _NFIdebug ((fname, " returning FAILURE\n"));
                    return (NFI_E_FORM);
                  }

                *act_row = i;
                *act_col = (ptr->rows)[j];
                if ((status = _NFFset_select_attr_data (form, 0, act_row,
                                      act_col, ptr)) != NFI_S_SUCCESS)
                  {
                    _NFIdebug ((fname,
                           "_NFFprocess_validate_field = <0x%.8x>\n", status));
                    _NFIdebug ((fname, " returning FAILURE\n"));
                    return (status);
                  }

                /*  Load an error message  */

                ERRload_struct (NFI, NFI_W_MORE_DATA, "%s", attrname);
                NFFform_message (NFI, NFI_W_MORE_DATA, "%s", attrname);

                _NFIdebug ((fname, " returning FAILURE\n"));
                return (NFI_W_MORE_DATA);
              }
          }
       }
     }

    /*  Scan for any single tics (') in the data buffer  */

    if ((status = NFMtic_it (ptr->data_list)) != NFM_S_SUCCESS)
      {
        _NFIdebug ((fname, "NFMtic_it = <0x%.8x>\n", status));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    _NFIdebug ((fname, " returning SUCCESS\n"));
    return (NFI_S_SUCCESS);
  }


long _NFFgeneric_fld_pos_cur (form, g_label, act_row, act_col, ptr)
  Form       form;
  int        g_label;       /* MCF gadget label */
  int        *act_row;      /* current row to put the cursor in */
  int        *act_col;      /* current column */
  NFFadd_ptr ptr;
  { 
     long   status = NFI_S_SUCCESS;
     int    c_col; 
     int    offset = 0; 
     int    next_col = 0; 
     int    vis_cols = 0; 
     int    vis_rows = 5; 
     int    i, j; 
 
     static  char *fname = "_NFFgeneric_fld_pos_cur";

     _NFIdebug ((fname, "row      = <%d>\n", *act_row));
     _NFIdebug ((fname, "cur_col  = <%d>\n", *act_col));

     c_col = *act_col;

     if (c_col == -1)
      {
         /* attempt to find the active_column */
          
         c_col = 0;
         _NFIdebug ((fname, "The current column is unknown\n"));
      } 

     for (i = 0; i < (ptr->data_list)->columns; ++i)
      {
         if (ptr->rows[i] == c_col)
          {
             for (j = (i + 1); j < (ptr->data_list)->columns; ++j)
              {
                 if (ptr->rows[j] != -1)
                  {
                     next_col = ptr->rows[j];
                     break;
                  }
              } 
             break;
          }
      } 

     _NFIdebug ((fname, "next_col = <%d>\n", next_col));

     /* Get the number of visible columns in the MCF and the position */

     status = (long) FImcf_get_view_data (form, g_label, &offset, &vis_cols);
     if (status != FI_SUCCESS)
      {
         _NFIdebug ((fname, "FImcf_get_view_data = <%d>\n", status));
         ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FImcf_get_view_data",
                         status);
         _NFIdebug ((fname, " returning FAILURE\n"));
         return (NFI_E_FORM);
      } 
     _NFIdebug ((fname, "vis_cols     = <%d>\n", vis_cols));
     _NFIdebug ((fname, "Left offset  = <%d>\n", offset));

     /* unselect the current row/column */

     status = (long) FIfld_set_select (form, g_label, *act_row, *act_col,
                                       FALSE);
     if (status != FI_SUCCESS)
      {
         _NFIdebug ((fname, "FIfld_pos_cursor = <%d>\n", status));
         ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_pos_cursor", status);
         _NFIdebug ((fname, " returning FAILURE\n"));
         return (NFI_E_FORM);
      } 

     /* if the next col is not in the viewing area put it in the viewing area */

/*
     if ((next_col - offset) >= vis_cols) 
      {
         _NFIdebug ((fname, "Shifting the MCF\n"));

         / * Shift the mcf by one right by one column * /

         status = (long) FImcf_set_active_col (form, g_label, next_col, 
                                               vis_cols - 1);
         if (status != FI_SUCCESS)
          {
             _NFIdebug ((fname, "FImcf_set_active_col = <%d>\n", status));

             ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FImcf_set_active_col",
                             status);
             _NFIdebug ((fname, " returning FAILURE\n"));
             return (NFI_E_FORM);
          } 
      }
     else if (((vis_cols + next_col) - offset) == 0)
      {
         _NFIdebug ((fname, "Resetting the MCF\n"));

         / * Shift the mcf to display the first column thru number of vis_cols * /

         status = (long) FImcf_set_active_col (form, g_label, next_col, 0);
         if (status != FI_SUCCESS)
          {
             _NFIdebug ((fname, "FImcf_set_active_col = <%d>\n", status));
             ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FImcf_set_active_col",
                             status);
             _NFIdebug ((fname, " returning FAILURE\n"));
             return (NFI_E_FORM);
          } 
      }
*/

     /* if the row is not in the viewing area position it to be. */
     /* This function assumes that there is always 5 visible rows in the mcf */

     if (*act_row >= vis_rows)
      {
         if ((status = FIfld_set_active_row (form, g_label,
                                             3, *act_row)) != FI_SUCCESS)
          {
              _NFIdebug ((fname, "FIfld_set_active_row = <%d>\n", status));
              ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_active_row",
                              status);
              _NFIdebug ((fname, " returning FAILURE\n"));
              return (NFI_E_FORM);
          }
      } 

     /* set the row/column to selected */

     status = (long) FIfld_set_select (form, g_label, *act_row, next_col, TRUE);
     if (status != FI_SUCCESS)
      {
         _NFIdebug ((fname, "FIfld_set_select = <%d>\n", status));
         ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_select", status);
         _NFIdebug ((fname, " returning FAILURE\n"));
         return (NFI_E_FORM);
      } 

     *act_col = next_col;

     /* call _NFFset_select_attr_data to process the values */

     status = _NFFset_select_attr_data (form, 0, act_row, act_col, ptr);
     if (status != NFI_S_SUCCESS)
      {
         _NFIdebug ((fname, "_NFFset_select_attr_data = <%d>\n", status));
         _NFIdebug ((fname, " returning FAILURE\n"));
         return (status);
      } 
    
     _NFIdebug ((fname, " returning SUCCESS\n"));
     return (NFI_S_SUCCESS);
  }


long _NFFadd_fld_pos_cur (form, g_label, cur_row, cur_col, act_row,
                          act_col, ptr)
  Form       form;
  int        g_label;       /* MCF gadget label */
  int        cur_row;       /* current row the cursor is in */
  int        cur_col;       /* current column the cursor is in */
  int        *act_row;      /* row to put the cursor in */
  int        *act_col;      /* column to put the cursor in*/
  NFFadd_ptr ptr;
  { 
     long   status = NFI_S_SUCCESS;
     int    offset = 0; 
     int    vis_cols = 0; 
     int    vis_rows = 5; 
 
     static  char *fname = "_NFFadd_fld_pos_cur";

     _NFIdebug ((fname, "cur_row  = <%d>\n", cur_row));
     _NFIdebug ((fname, "cur_col  = <%d>\n", cur_row));
     _NFIdebug ((fname, "next row = <%d>\n", *act_row));
     _NFIdebug ((fname, "next col = <%d>\n", *act_col));


     /* Get the number of visible columns in the MCF and the position */

     status = (long) FImcf_get_view_data (form, g_label, &offset, &vis_cols);
     if (status != FI_SUCCESS)
      {
         _NFIdebug ((fname, "FImcf_get_view_data = <%d>\n", status));
         ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FImcf_get_view_data",
                         status);
         _NFIdebug ((fname, " returning FAILURE\n"));
         return (NFI_E_FORM);
      } 
     _NFIdebug ((fname, "vis_cols     = <%d>\n", vis_cols));
     _NFIdebug ((fname, "Left offset  = <%d>\n", offset));

     /* unselect the current row/column */

     status = (long) FIfld_set_select (form, g_label, cur_row, cur_col, FALSE);
     if (status != FI_SUCCESS)
      {
         _NFIdebug ((fname, "FIfld_pos_cursor = <%d>\n", status));
         ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_pos_cursor", status);
         _NFIdebug ((fname, " returning FAILURE\n"));
         return (NFI_E_FORM);
      } 

     /* if the act col is not in the viewing area put it in the viewing area */

     if ((*act_col - offset) >= vis_cols) 
      {
         /* Shift the mcf by one right by one column */

         status = (long) FImcf_set_active_col (form, g_label, *act_col, 
                                               vis_cols -1);
         if (status != FI_SUCCESS)
          {
             _NFIdebug ((fname, "FImcf_set_active_col = <%d>\n", status));

             ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FImcf_set_active_col",
                             status);
             _NFIdebug ((fname, " returning FAILURE\n"));
             return (NFI_E_FORM);
          } 
      }
     else if (((vis_cols + *act_col) - offset) == 0)
      {
         /* Shift the mcf to display the first column thru number of vis_cols */

         status = (long) FImcf_set_active_col (form, g_label, *act_col, 0);
         if (status != FI_SUCCESS)
          {
             _NFIdebug ((fname, "FImcf_set_active_col = <%d>\n", status));
             ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FImcf_set_active_col",
                             status);
             _NFIdebug ((fname, " returning FAILURE\n"));
             return (NFI_E_FORM);
          } 
      }

     /* if the row is not in the viewing area position it to be. */
     /* This function assumes that there is always 5 visible rows in the mcf */

     if (*act_row >= vis_rows)
      {
         if ((status = FIfld_set_active_row (form, g_label,
                                             3, *act_row)) != FI_SUCCESS)
          {
              _NFIdebug ((fname, "FIfld_set_active_row = <%d>\n", status));
              ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_active_row",
                              status);
              _NFIdebug ((fname, " returning FAILURE\n"));
              return (NFI_E_FORM);
          }
      } 

     /* set the row/column to selected */

     status = (long) FIfld_set_select (form, g_label, *act_row, *act_col, TRUE);
     if (status != FI_SUCCESS)
      {
         _NFIdebug ((fname, "FIfld_set_select = <%d>\n", status));
         ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_select", status);
         _NFIdebug ((fname, " returning FAILURE\n"));
         return (NFI_E_FORM);
      } 

     /* call _NFFset_select_attr_data to process the values */

     status = _NFFset_select_attr_data (form, 0, act_row, act_col, ptr);
     if (status != NFI_S_SUCCESS)
      {
         _NFIdebug ((fname, "_NFFset_select_attr_data = <%d>\n", status));
         _NFIdebug ((fname, " returning FAILURE\n"));
         return (status);
      } 
    
     _NFIdebug ((fname, " returning SUCCESS\n"));
     return (NFI_S_SUCCESS);
  }

