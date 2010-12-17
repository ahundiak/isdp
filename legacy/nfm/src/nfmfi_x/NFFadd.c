
/* machine.h included to take care of platform variencies MVR 23 Dec 1993 */
#include "machine.h"

#include "NFF.h"
#include "NFFadd.h"
#include "NFFmain_form.h"

#ifdef   OS_CLIX
#include "inc.h"
#endif
#define NFI_E_ITEM_LEN                  0x0801c112

/*  Global NFF structure  */

extern struct NFFglobal_st NFFglobal;

long _NFFadd_attributes_field (form, row_no, write_or_update, ptr)
  Form         form;
  int          row_no;
  char         *write_or_update;  /*  i - "n_write" or "n_update"  */
  NFFadd_ptr   ptr;
  {
    auto    int     status;
    auto    int     i, row;
    auto    int     position;
    auto    int     selected;
    auto    int     label = INFORMATION_MCF;
    static  char    *fname = "_NFFadd_attributes_field";

    _NFIdebug ((fname, "row_no = %d\n", row_no));

    /*  See if the checkbox was selected  */

    if (row_no == -1)
      {
        /*  Find out which row was selected  */

        if ((status = FIfld_get_active_row
            (form, label, &row, &position)) != FI_SUCCESS)
          {
            _NFIdebug ((fname, "FIfld_get_active_row = <%d>\n", status));
            ERRload_struct
                (NFI, NFI_E_FORM, "%s%d", "FIfld_get_active_row", status);
            _NFIdebug ((fname, "returning FAILURE\n"));
            return (NFI_E_FORM);
          }

        /*  Find out if the row is selected or not  */

        if ((status = FImcf_get_select
            (form, label, row, &selected)) != FI_SUCCESS)
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

            if ((status = (int) _NFFadd_disable_lower_half
                (form, ptr)) != NFI_S_SUCCESS)
              {
                _NFIdebug ((fname,
                    "_NFFadd_disable_lower_half = <0x%.8x>\n", status));
                _NFIdebug ((fname, "returning FAILURE\n"));
                return (status);
              }

            _NFIdebug ((fname, " returning SUCCESS\n"));
            return (NFI_S_SUCCESS);
          }
      }
    else if (row_no < 0)
      {
        _NFIdebug ((fname, "rows or columns are scrolling\n"));
        _NFIdebug ((fname, " returning SUCCESS\n"));
        return (NFI_S_SUCCESS);
      }
    else
      {
        row = row_no;

        /*  Select this entire row  */

        if ((status = FImcf_set_select
            (form, label, row, TRUE)) != FI_SUCCESS)
          {
            _NFIdebug ((fname, "FImcf_set_select = <%d>\n", status));
            ERRload_struct
                (NFI, NFI_E_FORM, "%s%d", "FImcf_set_select", status);
            _NFIdebug ((fname, "returning FAILURE\n"));
            return (NFI_E_FORM);
          }
      }

    /*  Find the buffer row for this attribute  */

    for (i = 0; i < (ptr->attr_list)->rows; ++i)
      {
        /*  Need to have a "found" flag  */

        if ((ptr->rows)[i] == row)
          {
            ptr->active_attribute = i;
            break;
          }
      }

    if ((status = _NFFadd_set_lower_half
        (form, write_or_update, ptr)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFadd_set_lower_half = <0x%.8x>\n", status));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

/*  Put the cursor in the value field  */

    _NFIdebug ((fname, "positioning cursor in the value field\n"));
 

    if ((status = FIfld_pos_cursor
        (form, VALUE_FIELD, 0, 0, 0, 0, 0, 0)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIfld_pos_cursor = <%d>\n", status));
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_pos_cursor", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }
	NFFerase_message();

    _NFIdebug ((fname, " returning SUCCESS\n"));
    return (NFI_S_SUCCESS);
  }


long _NFFadd_value_field (form, write_or_update, ptr)
  Form          form;
  char          *write_or_update;  /*  i - "n_write" or "n_update"  */
  NFFadd_ptr    ptr;
  {
    auto    int     i;
    auto    int     length;
    auto    int     selected;
    auto    int     r_pos;
    auto    int     row_no;
    auto    int     list_no;
    auto    int     attr_mask;
    auto    int     label = VALUE_FIELD;
    auto    char    *text;
    auto    char    **attr_ptr;
    auto    char    **data_ptr;
    auto    char    **value_ptr;
    auto    char    *attr_name;
    auto    long    status;
    auto    short   offset;
    auto    short   min_offset;
    auto    short   max_offset;
    static  char    *fname = "_NFFadd_value_field";
    auto    int     field_len; /* PS */
    auto    char    **d;  /* AV */

    _NFIdebug ((fname, "label = <%d>\n", VALUE_FIELD));

/* begin tmpAV */
    row_no = ptr->active_attribute * (ptr->attr_list)->columns;
   if ((status = MEMbuild_array (ptr->attr_list)) != MEM_S_SUCCESS)
      {
        _NFIdebug ((fname, "attr->list MEMbuild_array = <0x%.8x>\n", status));
      }
    else
    d = (char **) (ptr->attr_list)->data_ptr;
 
/* end tmpAV */

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

/* begin - PS  */
  field_len = 1000; /* assign some large value - PS */
 
    if ( ((strncmp(d[row_no], "n_itemname",10)) == 0) ||
         ((strncmp(d[row_no], "n_itemrev",9)) == 0)  ||
         ((strncmp(d[row_no], "n_itemdesc",10)) == 0))
                field_len = NFFget_attribute_length(d[row_no+1]);
 
   if ( length  > field_len + 1)
   {
         ERRload_struct (NFI, NFI_E_ITEM_LEN, "%d", field_len);
         return (NFI_E_ITEM_LEN);
   }
/* end - PS */

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

    data_ptr = (char **) (ptr->attr_list)->data_ptr;
    row_no = ptr->active_attribute * (ptr->attr_list)->columns;

    if ((status = _NFFfind_column_offset
        (ptr->attr_list, "n_name", &offset)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFfind_column_offset = <0x%.8x>\n", status));
        if (text) free (text);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    attr_name = data_ptr[(ptr->active_attribute *
        (ptr->attr_list)->columns) + offset];

    if ((strcmp (text, "")) == 0)
      {
        /*  See if this attribute can have a null value  */

        if ((status = _NFFfind_column_offset
            (ptr->attr_list, "n_null", &offset)) != NFI_S_SUCCESS)
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

    /*  See if this is the catalog name  */

    else if ((strcmp (attr_name, "n_catalogname")) == 0)
      {
        /*  Convert it to lower case  */

        for (i = 0; i < strlen (text); ++i)
            text[i] = tolower (text[i]);

    /* IGI Intel Solaris Port - CN 31/5/95       */ 
#if defined  (OS_SCO_UNIX) || defined(OS_INTELSOL) 
        /* work around change - setting font for SCO - SSRS 2 Feb 94 */
        FIg_set_font( form, label, "7x13bold", 15 );
#endif
        FIfld_set_text (form, label, 0, 0, text, FALSE);
      }

/* Local filename length is restricted to MAX_NAME_SIZE, which is
   the maximum file length allowd at client --- CHRN-IGI-3 Feb 1995 */

#ifdef OS_CLIX
     if ((strcmp (attr_name, "n_cofilename")) == 0)
     {
         if ( strlen(text) > MAX_NAME_SIZE ) {
         NFFform_message (CURRENT_LABEL, NFI_I_FILE_LEN, "%d", MAX_NAME_SIZE);
	for (i = MAX_NAME_SIZE; i < strlen(text); i++)
		text[i] = '\0';
        FIfld_set_text (form, label, 0, 0, text, FALSE);
	}
      } 
#endif

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

        if ((status = _NFFadd_disable_lower_half (form, ptr)) != NFI_S_SUCCESS)
          {
            if (text) free (text);
            _NFIdebug ((fname,
                "_NFFadd_disable_lower_half = <0x%.8x>\n", status));
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (status);
          }

        /*  Put the value in the buffer  */

        /*  Write ALL data in the FIRST row (GS 8/13/90)  */

        _NFIdebug ((fname, "Writing <%s>\n", text));
        _NFIdebug ((fname, " in row %d, col %d in data_list\n",
            1, ptr->active_attribute + 1));

        if ((status = MEMwrite_data (ptr->data_list, text, 1,
            ptr->active_attribute + 1)) != MEM_S_SUCCESS)
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

    /* IGI Intel Solaris Port - CN 31/5/95       */ 
#if defined  (OS_SCO_UNIX)|| defined(OS_INTELSOL) 
            /* work around change - to set font for SCO - SSRS 2 Feb 94 */
            FIg_set_font( form, INFORMATION_MCF, "7x13bold", 15 );
#endif
            if ((status = (long) FIfld_set_text
                (form, INFORMATION_MCF,
                (ptr->rows)[ptr->active_attribute],
                2, text, TRUE)) != FI_SUCCESS)
              {
                _NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
                if (text) free (text);
                ERRload_struct
                    (NFI, NFI_E_FORM, "%s%d", "FIfld_set_text", status);
                _NFIdebug ((fname, " returning FAILURE\n"));
                return (NFI_E_FORM);
              }
          }

        if (text) free (text);

        /*  Select the next attribute  */

        if ((status = _NFFadd_select_next_attribute
            (form, write_or_update, ptr)) != NFI_S_SUCCESS)
          {
            _NFIdebug ((fname,
                "_NFFadd_select_next_attribute = <0x%.8x>\n", status));
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (status);
          }

        _NFIdebug ((fname, " returning SUCCESS\n"));
        return (NFI_S_SUCCESS);
      }

    /*  Validate the value  */

    data_ptr = (char **) (ptr->value_list)->data_ptr;

    if ((status = _NFFfind_column_offset
        (ptr->value_list, "n_minvalue", &min_offset)) == NFI_S_SUCCESS)
      {
        /*  It is a range list  */

        if ((status = _NFFfind_column_offset
            (ptr->value_list, "n_maxvalue", &max_offset)) != NFI_S_SUCCESS)
          {
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

    /* IGI Intel Solaris Port - CN 31/5/95       */ 
#if defined  (OS_SCO_UNIX) || defined(OS_INTELSOL) 
            /* work around change - to set font for SCO - SSRS 2 Feb 94 */
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

            ERRload_struct (NFI, NFI_E_RANGE, NULL);
            _NFIdebug ((fname, " returning NFI_E_RANGE <%d>\n", NFI_E_RANGE));
            return (NFI_E_RANGE);
          }
      }
    else
      {
        /*  It is OK, reset the global error structure  */

        ERRload_struct (NFI, NFI_S_SUCCESS, NULL);

        /*  It is a list  */

        if ((status = _NFFadd_validate_text
            (text, ptr->value_list)) != NFI_S_SUCCESS)
          {
            /*  Blank out the value field  */

            strcpy (text, "");

    /* IGI Intel Solaris Port - CN 31/5/95       */ 
#if defined  (OS_SCO_UNIX) || defined(OS_INTELSOL) 
            /* work around change - to set  font for SCO - SSRS 2 Feb 94 */
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
                    VALIDATE_MCF, ptr->validate_row, FALSE)) != FI_SUCCESS)
                  {
                    _NFIdebug ((fname, "FImcf_set_select = <%d>\n", status));
                    ERRload_struct
                        (NFI, NFI_E_FORM, "%s%d", "FImcf_set_select", status);
                    _NFIdebug ((fname, " returning FAILURE\n"));
                    return (NFI_E_FORM);
                  }
              }

            /*  Return an error status  */

            ERRload_struct (NFI, NFI_E_VALID, NULL);
            _NFIdebug ((fname, " returning NFI_E_VALID <%d>\n", NFI_E_VALID));
            return (NFI_E_VALID);
          }
      }

    /*  Write ALL data in the FIRST row (GS 8/13/90)  */

    _NFIdebug ((fname, "Writing <%s> in row %d, col %d in data_list\n",
        text, 1, ptr->active_attribute + 1));

    if ((status = MEMwrite_data (ptr->data_list,
        text, 1, ptr->active_attribute + 1)) != MEM_S_SUCCESS)
      {
        _NFIdebug ((fname, "MEMwrite_data = <0x%.8x>\n", status));
        ERRload_struct (NFI, NFI_E_MEM, "%s%x", "MEMwrite_data", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_MEM);
      }

    /*  See if the field is NO_ECHO  */

    if ((status = (long) FIfld_get_attr
        (form, label, 0, &attr_mask)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIfld_get_attr = <%d>\n", status));
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_get_attr", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    if ((attr_mask & FI_NO_ECHO) == 0)
      {
        /*  Put the value in the attributes field  */

    /* IGI Intel Solaris Port - CN 31/5/95       */ 
#if defined  (OS_SCO_UNIX) || defined(OS_INTELSOL) 
        /* work around change -  to set font for SCO - SSRS 2 Feb 94 */
        FIg_set_font( form, INFORMATION_MCF, "7x13bold", 15 );
#endif
        if ((status = (long) FIfld_set_text (form, INFORMATION_MCF,
            (ptr->rows)[ptr->active_attribute], 2, text, TRUE)) != FI_SUCCESS)
          {
            _NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
            ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_text", status);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_FORM);
          }
      }

    if (text) free (text);

    /*  Select the next attribute  */

    if ((status = _NFFadd_select_next_attribute
        (form, write_or_update, ptr)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname,
            "_NFFadd_select_next_attribute = <0x%.8x>\n", status));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    _NFIdebug ((fname, " returning SUCCESS\n"));
    return (NFI_S_SUCCESS);
  }


long _NFFadd_validate_field (form, row, write_or_update, ptr)
  Form          form;
  int           row;
  char          *write_or_update;  /*  i - "n_write" or "n_update"  */
  NFFadd_ptr    ptr;
  {
    int     row_no;
    int     list_no;
    int     position;
    int     selected;
    long    status;
    char    **data_ptr;
    short   offset;
    MEMptr  buffer = NULL;

    int     label = VALIDATE_MCF;

    static  char *fname = "_NFFadd_validate_field";

    _NFIdebug ((fname, "row = <%d>\n", row));

    /*  See if the checkbox was selected  */

    if (row == -1)
      {
        /*  Find out which row was selected  */

        if ((status = (long) FIfld_get_active_row
            (form, label, &row, &position)) != FI_SUCCESS)
          {
            _NFIdebug ((fname, "FIfld_get_active_row = <%d>\n", status));
            ERRload_struct
                (NFI, NFI_E_FORM, "%s%d", "FIfld_get_active_row", status);
            _NFIdebug ((fname, "returning FAILURE\n"));
            return (NFI_E_FORM);
          }

        /*  Find out if the row is selected or not  */

        if ((status = (long) FImcf_get_select
            (form, label, row, &selected)) != FI_SUCCESS)
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

    ptr->validate_row = row;

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

    row_no = ptr->active_attribute * (ptr->attr_list)->columns;
    list_no = atoi (data_ptr[row_no + offset]);
    _NFIdebug ((fname, "list_no = <0x%.8x>\n", list_no));

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

        if ((status = _NFFadd_disable_lower_half (form, ptr)) != NFI_S_SUCCESS)
          {
            _NFIdebug ((fname,
                "_NFFadd_disable_lower_half = <0x%.8x>\n", status));
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

    _NFIdebug ((fname,
        "Setting <%s> in the value field\n", data_ptr[row * buffer->columns]));

    /* IGI Intel Solaris Port - CN 31/5/95       */ 
#if defined  (OS_SCO_UNIX) || defined(OS_INTELSOL) 
    /* work around change - to set font for SCO - SSRS 2 Feb 94 */
    FIg_set_font( form, VALUE_FIELD, "7x13bold", 15 );
#endif
    if ((status = (long) FIfld_set_text (form, VALUE_FIELD,
        0, 0, data_ptr[row * buffer->columns], FALSE)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_text", status);
        _NFIdebug ((fname, "returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    /*  Write ALL data in the FIRST row (GS 8/13/90)  */

    _NFIdebug ((fname, "Writing <%s>\n", data_ptr[row * buffer->columns]));
    _NFIdebug ((fname, " in row %d, col %d in data_list\n",
        1, ptr->active_attribute + 1));

    if ((status = MEMwrite_data (ptr->data_list,
        data_ptr[row * buffer->columns], 1,
        ptr->active_attribute + 1)) != MEM_S_SUCCESS)
      {
        _NFIdebug ((fname, "MEMwrite_data = <0x%.8x>\n", status));
        ERRload_struct (NFI, NFI_E_MEM, "%s%x", "MEMwrite_data", status);
        _NFIdebug ((fname, "returning FAILURE\n"));
        return (NFI_E_MEM);
      }

    /*  Put the value in the attributes field  */

    /* IGI Intel Solaris Port - CN 31/5/95       */ 
#if defined  (OS_SCO_UNIX) || defined(OS_INTELSOL) 
    /* work around change - to set font for SCO - SSRS 2 Feb 94 */
    FIg_set_font( form, INFORMATION_MCF, "7x13bold", 15 );
#endif
    if ((status = (long) FIfld_set_text
        (form, INFORMATION_MCF, (ptr->rows)[ptr->active_attribute],
        2, data_ptr[row * buffer->columns], TRUE)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_text", status);
        _NFIdebug ((fname, "returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    /*  Select the next attribute  */

    if ((status = _NFFadd_select_next_attribute
        (form, write_or_update, ptr)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname,
            "_NFFadd_select_next_attribute = <0x%.8x>\n", status));
        _NFIdebug ((fname, "returning FAILURE\n"));
        return (status);
      }

    _NFIdebug ((fname, " returning SUCCESS\n"));
    return (NFI_S_SUCCESS);
  }


long _NFFadd_set_lower_half (form, write_or_update, ptr)
  Form          form;
  char          *write_or_update;  /*  i - "n_write" or "n_update"  */
  NFFadd_ptr    ptr;
  {
    auto    int     row_no;
    auto    int     list_no;
    auto    int     attr_mask;
    auto    int     type;
    auto    char    format[5];
    auto    char    text[500];
    auto    char    **format_ptr;
    auto    char    **data_ptr;
    auto    long    status;
    auto    short   offset;
    auto    short   min_offset;
    auto    short   max_offset;
    auto    short   read_offset;
    auto    short   write_offset;
    static  char    *fname = "_NFFadd_set_lower_half";

    /*  Put any existing value in the value field  */

    data_ptr = (char **) (ptr->data_list)->data_ptr;

    /*  Check to see if the value field text has double tics. 
     *  Since this buffer has been through the 'NFMtic_it'
     *  function, a single tic may now be a double tic.
     *  If the double tic is not removed here, it will
     *  multiply itself (Sounds kinky, huh ?) as the buffer
     *  is processed.
     */

    _NFFcheck_two_tics( data_ptr[ptr->active_attribute], text );

    _NFIdebug ((fname, "Search for tics in <%s>\n",
		data_ptr[ptr->active_attribute] ));
    _NFIdebug ((fname, "Writing <%s> in the value field\n", text ));
        
    /* IGI Intel Solaris Port - CN 31/5/95       */ 
#if defined  (OS_SCO_UNIX) || defined(OS_INTELSOL) 
			  /* this  was causing display problem VALIDATE TEXT
				is being garbled CN  -7/6/95 */
    /* work around change -  to set font for SCO - SSRS 2 Feb 94 */
    FIg_set_font( form, VALUE_FIELD, "7x13bold", 15 );
#endif
    if ((status = (long) FIfld_set_text (form, VALUE_FIELD,
        0, 0, text, FALSE)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_text", status);
        _NFIdebug ((fname, "returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    if ((status = (long) FIfld_set_active_char
        (form, VALUE_FIELD, 0, 0, 0)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIfld_set_active_char = <%d>\n", status));
        ERRload_struct
            (NFI, NFI_E_FORM, "%s%d", "FIfld_set_active_char", status);
        _NFIdebug ((fname, "returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    /*  Find the datatype for data validation - Glenn 4/1/92  */

    format_ptr = (char **) (ptr->data_list)->format_ptr;

    if ((strcmp (format_ptr[ptr->active_attribute], "integer")) == 0)
      {
        type = FI_INT;
        strcpy (format,"%d");
      }
    else if ((strcmp (format_ptr[ptr->active_attribute], "smallint")) == 0)
      {
        type = FI_INT;
        strcpy (format,"%d");
      }
    else if ((strcmp (format_ptr[ptr->active_attribute], "double")) == 0)
      {
        type = FI_DOUBLE;
        strcpy (format,"%f");
      }
    else if ((strcmp (format_ptr[ptr->active_attribute], "real")) == 0)
      {
        type = FI_DOUBLE;
        strcpy (format,"%f");
      }
    else
      {
        type = FI_ALPHA;
        strcpy (format,"%s");
      }

    /*  See if this attribute has write permission  */

    data_ptr = (char **) (ptr->attr_list)->data_ptr;

    if ((status = _NFFfind_column_offset
        (ptr->attr_list, "n_read", &read_offset)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFfind_column_offset = <0x%.8x>\n", status));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }
_NFIdebug ((fname, "_NFFfind_column_offset:read_offset = <%d>\n", read_offset));

    if ((status = _NFFfind_column_offset
        (ptr->attr_list, write_or_update, &write_offset)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFfind_column_offset = <0x%.8x>\n", status));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }
_NFIdebug ((fname, "_NFFfind_column_offset:write_offset = <%d>\n", write_offset));

    row_no = ptr->active_attribute * (ptr->attr_list)->columns;
    if ((strcmp (data_ptr[row_no + write_offset], "Y")) != 0)
      {
        /*  Set the field mode to review only  */

        if ((status = (long) FIfld_set_mode
            (form, VALUE_FIELD, 0, FI_REVIEW)) != FI_SUCCESS)
          {
            _NFIdebug ((fname, "FIfld_set_mode = <%d>\n", status));
            ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_mode", status);
            _NFIdebug ((fname, "returning FAILURE\n"));
            return (NFI_E_FORM);
          }
      }
    else
      {
        /*  Set the field mode to allow inserts  */

        if ((status = (long) FIfld_set_mode
            (form, VALUE_FIELD, 0, FI_INSERT)) != FI_SUCCESS)
          {
            _NFIdebug ((fname, "FIfld_set_mode = <%d>\n", status));
            ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_mode", status);
            _NFIdebug ((fname, "returning FAILURE\n"));
            return (NFI_E_FORM);
          }

        /*  Set the field type for data validation - Glenn 4/1/92  */

        if ((status = (long) FIfld_set_type
            (form, VALUE_FIELD, 0, type)) != FI_SUCCESS)
          {
            _NFIdebug ((fname, "FIfld_set_type = <%d>\n", status));
            ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_type", status);
            _NFIdebug ((fname, "returning FAILURE\n"));
            return (NFI_E_FORM);
          }

        /*  Set the field format for data validation - Glenn 4/1/92  */

        if ((status = (long) FIfld_set_format_string
            (form, VALUE_FIELD, 0, format)) != FI_SUCCESS)
          {
            _NFIdebug ((fname, "FIfld_set_format_string = <%d>\n", status));
            ERRload_struct (NFI,
                NFI_E_FORM, "%s%d", "FIfld_set_format_string", status);
            _NFIdebug ((fname, "returning FAILURE\n"));
            return (NFI_E_FORM);
          }

        /*  Check for no echo  */

        if ((strcmp (data_ptr[row_no + read_offset], "N")) == 0)
          {
            /*  Set the field to NO_ECHO and CLEAR_ON_SELECTION  */

            if ((status = (long) FIfld_get_attr
                (form, VALUE_FIELD, 0, &attr_mask)) != FI_SUCCESS)
              {
                _NFIdebug ((fname, "FIfld_get_attr = <%d>\n", status));
                ERRload_struct
                    (NFI, NFI_E_FORM, "%s%d", "FIfld_get_attr", status);
                _NFIdebug ((fname, "returning FAILURE\n"));
                return (NFI_E_FORM);
              }

            attr_mask |= FI_NO_ECHO | FI_CLEAR_ON_SELECTION;

            if ((status = (long) FIfld_set_attr
                (form, VALUE_FIELD, 0, attr_mask)) != FI_SUCCESS)
              {
                _NFIdebug ((fname, "FIfld_set_attr = <%d>\n", status));
                ERRload_struct
                    (NFI, NFI_E_FORM, "%s%d", "FIfld_set_attr", status);
                _NFIdebug ((fname, "returning FAILURE\n"));
                return (NFI_E_FORM);
              }
          }
        else
          {
            /*  Take out NO_ECHO and CLEAR_ON_SELECTION  */

            if ((status = (long) FIfld_get_attr
                (form, VALUE_FIELD, 0, &attr_mask)) != FI_SUCCESS)
              {
                _NFIdebug ((fname, "FIfld_get_attr = <%d>\n", status));
                ERRload_struct
                    (NFI, NFI_E_FORM, "%s%d", "FIfld_get_attr", status);
                _NFIdebug ((fname, "returning FAILURE\n"));
                return (NFI_E_FORM);
              }

            if (attr_mask & FI_NO_ECHO)
              {
                /*  XOR the mask with itself to strip them out  */

                attr_mask ^= FI_NO_ECHO | FI_CLEAR_ON_SELECTION;

                if ((status = (long) FIfld_set_attr
                    (form, VALUE_FIELD, 0, attr_mask)) != FI_SUCCESS)
                  {
                    _NFIdebug ((fname, "FIfld_set_attr = <%d>\n", status));
                    ERRload_struct
                        (NFI, NFI_E_FORM, "%s%d", "FIfld_set_attr", status);
                    _NFIdebug ((fname, "returning FAILURE\n"));
                    return (NFI_E_FORM);
                  }
              }
          }
      }

    /*  Redisplay the field  */

    if ((status = (long) FIg_display (form, VALUE_FIELD)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIg_display = <%d>\n", status));
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_display", status);
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

    list_no = atoi (data_ptr[row_no + offset]);
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

        if ((status = _NFFadd_disable_lower_half (form, ptr)) != NFI_S_SUCCESS)
          {
            _NFIdebug ((fname,
                "_NFFadd_disable_lower_half = <0x%.8x>\n", status));
            _NFIdebug ((fname, " return FAILURE\n"));
            return (status);
          }

        /*  Display any advisory information  */

        if ((status = _NFFadd_set_advisory_info (form, ptr)) != NFI_S_SUCCESS)
          {
            _NFIdebug ((fname,
                "_NFFadd_set_advisory_info = <0x%.8x>\n", status));
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
        if ((status = _NFFfind_column_offset
            (ptr->value_list, "n_maxvalue", &max_offset)) != NFI_S_SUCCESS)
          {
            _NFIdebug ((fname, "_NFFfind_column_offset = <0x%.8x>\n", status));
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (status);
          }

        /*  It is a range list  */

        /*  Erase the validate group  */

        if ((status = (long) FIg_erase (form, VALIDATE_TEXT)) != FI_SUCCESS)
          {
            _NFIdebug ((fname, "FIg_erase = <%d>\n", status));
            ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_erase", status);
            _NFIdebug ((fname, "returning FAILURE\n"));
            return (NFI_E_FORM);
          }

        if ((status = (long) FIg_erase (form, VALIDATE_MCF)) != FI_SUCCESS)
          {
            /*  The validate mcf does not exist; continue  */

            _NFIdebug ((fname, "FIg_erase = <0x%.8x>\n", status));
          }

        /*  Display the range group  */

        if ((status = (long) FIg_display (form, RANGE_GROUP)) != FI_SUCCESS)
          {
            _NFIdebug ((fname, "FIg_display = <%d>\n", status));
            ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_display", status);
            _NFIdebug ((fname, "returning FAILURE\n"));
            return (NFI_E_FORM);
          }

        /*  Put the values in the fields  */

    /* IGI Intel Solaris Port - CN 31/5/95       */ 
#if defined  (OS_SCO_UNIX) || defined(OS_INTELSOL) 
        /* work around change - to set font for SCO - SSRS 2 Feb 94 */
        FIg_set_font( form, MIN_FIELD, "7x13bold", 15 );
#endif
        if ((status = (long) FIfld_set_text
            (form, MIN_FIELD, 0, 0, data_ptr[min_offset])) != FI_SUCCESS)
          {
            _NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
            ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_text", status);
            _NFIdebug ((fname, "returning FAILURE\n"));
            return (NFI_E_FORM);
          }

    /* IGI Intel Solaris Port - CN 31/5/95       */ 
#if defined  (OS_SCO_UNIX) || defined(OS_INTELSOL)  
        /* work around change -  to set font for SCO - SSRS 2 Feb 94 */
        FIg_set_font( form, MAX_FIELD, "7x13bold", 15 );
#endif
        if ((status = (long) FIfld_set_text
            (form, MAX_FIELD, 0, 0, data_ptr[max_offset])) != FI_SUCCESS)
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

        ERRload_struct (NFI, NFI_S_SUCCESS, NULL);

        /*  It is a list  */

        /*  Erase the range group  */

    /* IGI Intel Solaris Port - CN 31/5/95       */ 
#if defined  (OS_SCO_UNIX) || defined(OS_INTELSOL) 
        /*  work around change - to set font for SCO - SSRS 2 Feb 94 */
        FIg_set_font( form, MIN_FIELD, "7x13bold", 15 );
#endif
        if ((status = (long) FIfld_set_text
            (form, MIN_FIELD, 0, 0, "", FALSE)) != FI_SUCCESS)
          {
            _NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
            ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_text", status);
            _NFIdebug ((fname, "returning FAILURE\n"));
            return (NFI_E_FORM);
          }

    /* IGI Intel Solaris Port - CN 31/5/95       */ 
#if defined  (OS_SCO_UNIX) || defined(OS_INTELSOL)  
        /* work around change - to set font for SCO - SSRS 2 Feb 94 */
        FIg_set_font( form, MAX_FIELD, "7x13bold", 15 );
#endif
        if ((status = (long) FIfld_set_text
            (form, MAX_FIELD, 0, 0, "", FALSE)) != FI_SUCCESS)
          {
            _NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
            ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_text", status);
            _NFIdebug ((fname, "returning FAILURE\n"));
            return (NFI_E_FORM);
          }

        if ((status = (long) FIg_erase (form, RANGE_GROUP)) != FI_SUCCESS)
          {
            _NFIdebug ((fname, "FIg_erase = <%d>\n", status));
            ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_erase", status);
            _NFIdebug ((fname, "returning FAILURE\n"));
            return (NFI_E_FORM);
          }

/* uncommented - MVVMK 1 Apr 96 */
    if ((status = FIg_erase (form, VALIDATE_TEXT)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIg_erase = <%d>\n", status));
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_erase", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

        /*  Display the VALIDATE_TEXT  */
/* commented to avoid overwriting of Validation List Text - MVVMK 1 Apr 96 
        if ((status = (long) FIg_display (form, VALIDATE_TEXT)) != FI_SUCCESS)
          {
            _NFIdebug ((fname, "FIg_display = <%d>\n", status));
            ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_display", status);
            _NFIdebug ((fname, "returning FAILURE\n"));
            return (NFI_E_FORM);
          }
*/
        /*  Create the validate mcf to reflect the list  */

        if ((status = (long) FIg_delete (form, VALIDATE_MCF)) != FI_SUCCESS)
          {
            if (status != FI_NO_SUCH_GADGET)
              {
                _NFIdebug ((fname, "FIg_delete = <%d>\n", status));
                ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_delete", status);
                _NFIdebug ((fname, "returning FAILURE\n"));
                return (NFI_E_FORM);
              }
          }
        if ((status = _NFFadd_create_mcf
            (form, VALIDATE_MCF, ptr->value_list)) != NFI_S_SUCCESS)
          {
            _NFIdebug ((fname, "_NFFadd_create_mcf = <0x%.8x>\n", status));
            _NFIdebug ((fname, "returning FAILURE\n"));
            return (status);
          }
        /*  Load the list into the mcf  */

        if ((status = _NFFadd_load_mcf
            (form, VALIDATE_MCF, ptr->value_list)) != NFI_S_SUCCESS)
          {
            _NFIdebug ((fname, "_NFFadd_load_mcf = <0x%.8x>\n", status));
            _NFIdebug ((fname, "returning FAILURE\n"));
            return (status);
          }
        /*  Center the mcf and text on the form  */

        if ((status = _NFFcenter_gadget
            (form, VALIDATE_MCF)) != NFI_S_SUCCESS)
          {
            _NFIdebug ((fname, "_NFFcenter_gadget = <0x%.8x>\n", status));
            _NFIdebug ((fname, "returning FAILURE\n"));
            return (status);
          }

        if ((status = _NFFcenter_gadget
            (form, VALIDATE_TEXT)) != NFI_S_SUCCESS)
          {
            _NFIdebug ((fname, "_NFFcenter_gadget = <0x%.8x>\n", status));
            _NFIdebug ((fname, "returning FAILURE\n"));
            return (status);
          }

        if ((status = (long) FIf_display (form)) != FI_SUCCESS)
          {
            _NFIdebug ((fname, "FIf_display = <%d>\n", status));
            ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIf_display", status);
            _NFIdebug ((fname, "returning FAILURE\n"));
            return (NFI_E_FORM);
          }

        /*  Make the first row the active row  */

        if ((status = (long) FIfld_set_active_row
            (form, VALIDATE_MCF, 0, 0)) != FI_SUCCESS)
          {
            _NFIdebug ((fname, "FIfld_set_active_row = <%d>\n", status));
            ERRload_struct
                (NFI, NFI_E_FORM, "%s%d", "FIfld_set_active_row", status);
            _NFIdebug ((fname, "returning FAILURE\n"));
            return (NFI_E_FORM);
          }
      }

    /*  Display any advisory information  */

    if ((status = _NFFadd_set_advisory_info (form, ptr)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFadd_set_advisory_info = <0x%.8x>\n", status));
        _NFIdebug ((fname, "returning FAILURE\n"));
        return (status);
      }

    _NFIdebug ((fname, " returning SUCCESS\n"));
    return (NFI_S_SUCCESS);
  }


long _NFFadd_set_advisory_info (form, ptr)
  Form          form;
  NFFadd_ptr    ptr;
  {
    auto    int     row_no;
    auto    long    status;
    auto    char    **data_ptr;
    auto    short   offset;
    auto    int     label = ADVICE_FIELD;
    static  char    *fname = "_NFFadd_set_advisory_info";

    _NFIdebug ((fname, "label = <%d>\n", ADVICE_FIELD));

    /*  Find the value list for this attribute  */

    data_ptr = (char **) (ptr->attr_list)->data_ptr;

    if ((status = _NFFfind_column_offset
        (ptr->attr_list, "n_advice", &offset)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFfind_column_offset = <0x%.8x>\n", status));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    row_no = ptr->active_attribute * (ptr->attr_list)->columns;

    /*  Put the text in the field  */

    _NFIdebug ((fname,
        "Setting <%s>\n in ADVICE_FIELD\n", data_ptr[row_no + offset]));

    /* IGI Intel Solaris Port - CN 31/5/95       */ 
#if defined  (OS_SCO_UNIX) || defined(OS_INTELSOL)
        /* work around change -  to set font for SCO - SSRS 2 Feb 94 */
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


long _NFFadd_validate_text (text, value_list)
  char      *text;
  MEMptr    value_list;
  {
    int     i;
    int     fields;
    char    **data_ptr;
    short   found = FALSE;

    static  char *fname = "_NFFadd_validate_text";

    _NFIdebug ((fname, "text = <%s>\n", text));

    data_ptr = (char **) value_list->data_ptr;

    fields = value_list->rows * value_list->columns;
    for (i = 0; i < fields; i += value_list->columns)
      {
        /*  Check the first column only  */

        if ((strcmp (text, data_ptr[i])) == 0)
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


long _NFFadd_load_attributes (form, ptr, write_attr)
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

    int     label = INFORMATION_MCF;

    static  char *fname = "_NFFadd_load_attributes";

    _NFIdebug ((fname, "label = <%d>\n", INFORMATION_MCF));
    _NFIdebug ((fname, "write_attr = <%s>\n", write_attr));

    _NFFinit_rows (ptr->attr_list, write_attr, &(ptr->rows));

    for (i = 0; i < (ptr->attr_list)->rows; ++i)
      {
        _NFIdebug ((fname, "(ptr->rows)[%d] = %d\n", i, (ptr->rows)[i]));
      }

    /*  Find the offsets in the buffer  */

    if ((status = _NFFfind_column_offset
        (ptr->attr_list, "n_datatype", &type_offset)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFfind_column_offset = <0x%.8x>\n", status));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    /* IGI Intel Solaris Port - CN 31/5/95       */ 
#if defined  (OS_SCO_UNIX) || defined(OS_INTELSOL) 
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


long _NFFadd_disable_lower_half (form, ptr)
  Form          form;
  NFFadd_ptr    ptr;
  {
    int     status;
/*
    int     xsize;
    int     ysize;
    int     xpos;
    int     ypos;
*/
    static  char *fname = "_NFFadd_disable_lower_half";

    _NFIdebug ((fname, "label = <%d>\n", RANGE_GROUP));

    /*  Disable the range group  */

    if ((status = FIfld_set_text
        (form, MIN_FIELD, 0, 0, "", FALSE)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_text", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    if ((status = FIfld_set_text
        (form, MAX_FIELD, 0, 0, "", FALSE)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_text", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    if ((status = FIg_erase (form, RANGE_GROUP)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIg_erase = <%d>\n", status));
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_erase", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    /*  Unselect any selected row in the validate mcf  */

    if (ptr->validate_row != -1)
      {
        if ((status = FImcf_set_select
            (form, VALIDATE_MCF, ptr->validate_row, FALSE)) != FI_SUCCESS)
          {
            _NFIdebug ((fname, "FImcf_set_select(1) = <%d>\n", status));
            ERRload_struct
                (NFI, NFI_E_FORM, "%s%d", "FImcf_set_select", status);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_FORM);
          }
      }

    /*  Erase the validate group  */

    if ((status = FIg_erase (form, VALIDATE_TEXT)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIg_erase = <%d>\n", status));
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_erase", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    if ((status = FIg_erase (form, VALIDATE_MCF)) != FI_SUCCESS)
      {
        /*  The validate mcf does not exist; continue  */

        _NFIdebug ((fname, "FIg_erase = <0x%.8x>\n", status));
      }

/*

    if ((status = FIg_get_size (form, BEZEL_AREA, &xsize, &ysize)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIg_get_size = <0x%.8x>\n", status));
      }

    if ((status = FIg_get_location (form, BEZEL_AREA, &xpos, &ypos)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIg_location = <0x%.8x>\n", status));
      }

    _NFIdebug(( fname, "Bezel Size <%d, %d>  <%d, %d>\n", xpos, ypos,
                        xpos+xsize, ypos+ysize ));

    if ((status = FIf_paint_area (form, xpos, ypos, xpos+xsize, ypos+ysize)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIf_paint_area = <0x%.8x>\n", status));
      }
*/
    _NFIdebug ((fname, " returning SUCCESS\n"));
    return (NFI_S_SUCCESS);
  }


long _NFFadd_validate_accept (form, write_attr, ptr)
  Form          form;
  char          *write_attr;  /*  "n_write" or "n_update"  */
  NFFadd_ptr    ptr;
  {
    int     i, j;
    int     fields;
    int     column;
    int     wf_columns;
    int     position;
    int     total_data;
    long    status;
    char    **attr_ptr;
    char    **data_ptr;
    char    **wf_data;
    char    *attrname;
    short   nfm_offset;
    short   write_offset;
    short   null_offset;
    short   wfno_offset;
    short   wfname_offset;

    static  char *fname = "_NFFadd_validate_accept";

    _NFIdebug ((fname, "write_attr = <%s>\n", write_attr));
    _NFIdebug ((fname, "data_list->rows = <%d>\n", (ptr->data_list)->rows));

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

    /* IGI Intel Solaris Port - CN 31/5/95       */ 
#if defined  (OS_SCO_UNIX) || defined(OS_INTELSOL) 
    /* work around change - to set font for SCO - SSRS 2 Feb 94 */
    FIg_set_font( NFFglobal.forms[MAIN_LABEL], ACL_FIELD, "7x13bold", 15 );
#endif

    column = 0;
    fields = (ptr->attr_list)->rows * (ptr->attr_list)->columns;
    for (i = 0; i < fields; i += (ptr->attr_list)->columns, ++column)
      {
        /*  Pull out any values for active data  */

        if ((strcmp (attr_ptr[i + nfm_offset], "n_itemname")) == 0)
          {
             /*  Save item name if this is COPY_ITEM */
            if (ptr->command == COPY_ITEM)
              {
                _NFIdebug ((fname, "New Item Name  = <%s>\n", 
			    data_ptr[column]));
		strcpy( NFFglobal.new_item, data_ptr[column] );
              }
          }
        else if ((strcmp (attr_ptr[i + nfm_offset], "n_itemrev")) == 0)
          {
            _NFIdebug ((fname, "item revision = <%s>\n", data_ptr[column]));
	    
            /*  Save item revision if this is COPY_ITEM */
            if (ptr->command == COPY_ITEM)
              {
                _NFIdebug ((fname, "New Item Rev  = <%s>\n", 
			    data_ptr[column]));
		strcpy( NFFglobal.new_revision, data_ptr[column] );
              }
          }
        else if ((strcmp (attr_ptr[i + nfm_offset], "n_nodename")) == 0)
          {
            _NFIdebug ((fname, "node = <%s>\n", data_ptr[column]));
/*            _NFFmain_set_node (data_ptr[column]);*/
          }
        else if ((strcmp (attr_ptr[i + nfm_offset], "n_saname")) == 0)
          {
            _NFIdebug ((fname, "storage area = <%s>\n", data_ptr[column]));
/*            _NFFmain_set_sa (data_ptr[column]);*/
          }
        else if ((strcmp (attr_ptr[i + nfm_offset], "n_username")) == 0)
          {
            _NFIdebug ((fname, "user = <%s>\n", data_ptr[column]));
/*            _NFFmain_set_user (data_ptr[column]);*/
          }
        else if ((strcmp (attr_ptr[i + nfm_offset], "n_projectname")) == 0)
          {
            _NFIdebug ((fname, "project = <%s>\n", data_ptr[column]));
/*            _NFFmain_set_project (data_ptr[column]);*/
          }
        else if ((strcmp (attr_ptr[i + nfm_offset], "n_aclname")) == 0)
          {
            _NFIdebug ((fname, "acl = <%s>\n", data_ptr[column]));
            strcpy (NFFglobal.acl, data_ptr[column]);
            FIg_set_text (NFFglobal.forms[MAIN_LABEL],
                ACL_FIELD, data_ptr[column]);
          }
        else if ((strcmp (attr_ptr[i + nfm_offset], "n_workflowname")) == 0)
          {
            _NFIdebug ((fname, "workflow = <%s>\n", data_ptr[column]));
/*            _NFFmain_set_wf (data_ptr[column]);*/
          }
        else if ((strcmp (attr_ptr[i + nfm_offset], "n_workflowno")) == 0)
          {
            _NFIdebug ((fname, "workflow number = <%s>\n", data_ptr[column]));

            /*  Find the workflow name for this workflow number  */

            if ((status = _NFFfind_value_buffer (ptr->attr_list,
                ptr->value_list, "n_workflowno", "n_valueno")) == NFI_S_SUCCESS)
              {
                wf_data = (char **) (ptr->value_list)->data_ptr;
                wf_columns = (ptr->value_list)->columns;
                total_data =
                    (ptr->value_list)->columns * (ptr->value_list)->rows;

                if ((status = _NFFfind_column_offset (ptr->value_list,
                    "n_workflowname", &wfname_offset)) != NFI_S_SUCCESS)
                  {
                    _NFIdebug ((fname,
                        "_NFFfind_column_offset = <0x%.8x>\n", status));
                    ptr->done = FALSE;
                    _NFIdebug ((fname, " returning FAILURE\n"));
                    return (status);
                  }

                if ((status = _NFFfind_column_offset (ptr->value_list,
                    "n_workflowno", &wfno_offset)) != NFI_S_SUCCESS)
                  {
                    _NFIdebug ((fname,
                        "_NFFfind_column_offset = <0x%.8x>\n", status));
                    ptr->done = FALSE;
                    _NFIdebug ((fname, " returning FAILURE\n"));
                    return (status);
                  }

                for (j = 0; j < total_data; j += wf_columns)
                  {
                    if ((strcmp
                        (wf_data[j + wfno_offset], data_ptr[column])) == 0)
                      {
                        /*  Store the workflow name  */

/*                        _NFFmain_set_wf (wf_data[j + wfname_offset]);*/
                        break;
                      }
                  }
              }
            else
              {
                /*  It is OK, reset the global error structure  */

                ERRload_struct (NFI, NFI_S_SUCCESS, NULL);
              }
          }

        /*  See if this attribute can be written to  */

        if ((strcmp (attr_ptr[i + write_offset], "Y")) != 0)
          {
            /*  Don't validate  */

            continue;
          }

        /*  See if this attribute can have NULL values  */

        if ((strcmp (attr_ptr[i + null_offset], "Y")) != 0)
          {
            _NFIdebug ((fname, "checking <%s>\n", attr_ptr[i + nfm_offset]));
            _NFIdebug ((fname, "%s has a value of <%s>\n",
                attr_ptr[i + nfm_offset], data_ptr[column]));

            /*  See if this attribute has a value  */

            if ((strcmp (data_ptr[column], "")) == 0)
              {
                /*  Find the attribute name (or synonym if it exists)  */

                if ((status = _NFFfind_attribute_name
                    (ptr->attr_list, i, &attrname)) != NFI_S_SUCCESS)
                  {
                    _NFIdebug ((fname,
                        "_NFFfind_attribute_name = <0x%.8x>\n", status));
                    ptr->done = FALSE;
                    _NFIdebug ((fname, " returning FAILURE\n"));
                    return (status);
                  }

                ptr->done = FALSE;

                /*  Position the offending row in the center of the mcf  */

                if (column < 3)
                    position = column;
                else
                    position = 3;

                if ((status = FIfld_set_active_row (form, INFORMATION_MCF,
                    (ptr->rows)[column], position)) != FI_SUCCESS)
                  {
                    _NFIdebug ((fname,
                        "FIfld_set_active_row = <%d>\n", status));
                    ERRload_struct (NFI,
                        NFI_E_FORM, "%s%d", "FIfld_set_active_row", status);
                    _NFIdebug ((fname, " returning FAILURE\n"));
                    return (NFI_E_FORM);
                  }

                /*  Set the lower half as if the user selected this row  */

                if ((status = FImcf_set_select (form, INFORMATION_MCF,
                    (ptr->rows)[column], TRUE)) != FI_SUCCESS)
                  {
                    _NFIdebug ((fname, "FImcf_set_select(2) = <%d>\n", status));
                    ERRload_struct
                        (NFI, NFI_E_FORM, "%s%d", "FImcf_set_select", status);
                    _NFIdebug ((fname, " returning FAILURE\n"));
                    return (NFI_E_FORM);
                  }

                if ((status = _NFFadd_attributes_field
                    (form, -1, write_attr, ptr)) != NFI_S_SUCCESS)
                  {
                    _NFIdebug ((fname,
                        "_NFFadd_attributes_field = <0x%.8x>\n", status));
                    _NFIdebug ((fname, " returning FAILURE\n"));
                    return (status);
                  }

                /*  Load an error message  */

                status = NFI_W_MORE_DATA;
                ERRload_struct (NFI, status, "%s", attrname);

                _NFIdebug ((fname, " returning FAILURE <0x%.8x>\n", status));
                return (status);
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


long _NFFadd_select_next_attribute (form, write_or_update, ptr)
  Form          form;
  char          *write_or_update;  /*  i - "n_write" or "n_update"  */
  NFFadd_ptr    ptr;
  {
    int     i;
    int     selected_row;
    int     num_vis_rows;
    int     position;
    long    status;

    int     label = INFORMATION_MCF;

    static  char *fname = "_NFFadd_select_next_attribute";

    _NFIdebug ((fname, "command = <%d>\n", ptr->command));

    switch (ptr->command)
      {
        case CREATE_CATALOG:  
        case CHANGE_CATALOG:

            /*  Don't select the next row  */

            _NFIdebug ((fname, "returning SUCCESS <0x%.8x>\n", NFI_S_SUCCESS));
            return (NFI_S_SUCCESS);

        default:

            /*  All other commands, process normally  */

            break;
      }

    selected_row = -1;
    for (i = ptr->active_attribute + 1; i < (ptr->attr_list)->rows; ++i)
      {
        if ((ptr->rows)[i] != -1)
          {
            /*  Next attribute is found  */

            selected_row = (ptr->rows)[i];
            break;
          }
      }

    if (selected_row == -1)
      {
        /*  Cycle back through the top  */

        for (i = 0; i < (ptr->attr_list)->rows; ++i)
          {
            if ((ptr->rows)[i] != -1)
              {
                /*  Next attribute is found  */

                selected_row = (ptr->rows)[i];
                break;
              }
          }
      }

    if (selected_row == -1)
      {
        _NFIdebug ((fname, "next attribute could not be found\n"));
        ERRload_struct (NFI, NFI_E_BUFFER, NULL);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_BUFFER);
      }

    /*  Select the row as if the user had selected it  */

    if ((status = (long) FIfld_get_num_vis_rows
        (form, label, &num_vis_rows)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIfld_get_num_vis_rows = <%d>\n", status));
        ERRload_struct
            (NFI, NFI_E_FORM, "%s%d", "FIfld_get_num_vis_rows", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    /*  If the selected_row is out of the viewing area,
        set it to be at the bottom of the viewing area  */

    if (selected_row >= num_vis_rows)
        position = num_vis_rows - 1;
    else
        position = selected_row;

    _NFIdebug ((fname, "position = <0x%.8x>\n", position));

    if ((status = (long) FIfld_set_active_row
        (form, label, selected_row, position)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIfld_set_active_row = <%d>\n", status));
        ERRload_struct
            (NFI, NFI_E_FORM, "%s%d", "FIfld_set_active_row", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    if ((status = _NFFadd_attributes_field
        (form, selected_row, write_or_update, ptr)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFadd_attributes_field = <0x%.8x>\n", status));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    _NFIdebug ((fname, " returning SUCCESS\n"));
    return (NFI_S_SUCCESS);
  }


void _NFFfree_add (ptr, form)
  NFFadd_ptr    ptr;
  Form          *form;
  {
    /* '*form' is also checked for NULL, in additon to `form`. 
       SSRS - 23/11/93
    */
    if(form != NULL && *form != NULL)
      {
        FIf_delete (*form);
        NFFglobal.current_form = *form = NULL;
      }

    MEMclose (&(ptr->attr_list));
    MEMclose (&(ptr->data_list));
    MEMclose (&(ptr->value_list));

    if (ptr->rows) free (ptr->rows);
    if (ptr) free (ptr);

    return;
  }
int NFFget_attribute_length(a)
char *a;
{
 
/*
        while ( isalpha(*a++))
                ;
*/
        while ( !isdigit(*a) ) {
        a++;
        }
        return ( atoi(a) );
}

