
/* machine.h included to take care of platform variencies MVR 23 Dec 1993 */
#include "machine.h"

#include "NFF.h"
#include "NFFcatalog.h"

/*  Take this out when Jeff gives us prototype files  */

extern  int FIg_erase (Form, int);
extern  int FIg_display (Form, int);

/*  Global NFF structure  */

extern struct NFFglobal_st NFFglobal;

long _NFFcat_build_value_buffer
(form, label, list_or_keyin, value_column, value_type, catalog)
  Form         form;
  int          label;
  char         *list_or_keyin;  /*  "n_valueno" or "n_adviceno"      */
  char         *value_column;   /*  "n_value", "n_minvalue", etc.    */
  char         *value_type;     /*  "NFM_STATIC", "NFM_RANGE", etc.  */
  NFFcatalog   catalog;
  {
    auto    int     i;
    auto    int     row;
    auto    int     position;
    auto    int     length;
    auto    int     selected;
    auto    int     r_pos;
    auto    int     row_no;
    auto    int     list_no;
    auto    int     no_buffers;
    auto    int     row_size;
    auto    long    status;
    auto    char    list_str[20];
    auto    char    new_list_or_keyin[20];
    auto    char    *text = NULL;
    auto    char    *blank_row;
    auto    char    **attr_ptr;
    auto    short   offset, list_offset;
    auto    short   value_buffer_flag;
    auto    short   old_attr = FALSE;
    auto    MEMptr  buffer = NULL;
    static  char    *fname = "_NFFcat_build_value_buffer";

    _NFIdebug ((fname, "label = <%d>\n", label));

    /*  Find out which row to get the data from  */

    if ((status = (long) FIfld_get_active_row
        (form, label, &row, &position)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIfld_get_active_row = <%d>\n", status));
        ERRload_struct
            (NFI, NFI_E_FORM, "%s%d", "FIfld_get_active_row", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    _NFIdebug ((fname, "active row = <%d>\n", row));
    _NFIdebug ((fname, "position = <%d>\n", position));

    /*  Get the length of the string  */

    if ((status = (long) FIfld_get_text_length
        (form, label, row, 0, &length)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIfld_get_text_length = <%d>\n", status));
        ERRload_struct
            (NFI, NFI_E_FORM, "%s%d", "FIfld_get_text_length", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    _NFIdebug ((fname, "length = <%d>\n", length));

    if ((text = (char *) malloc (length)) == NULL)
      {
        _NFIdebug ((fname, "malloc failed; size = <%d>\n", length));
        ERRload_struct (NFI, NFI_E_MALLOC, "%d", length);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_MALLOC);
      }

    /*  Get the string from the form  */

    if ((status = (long) FIfld_get_text
        (form, label, row, 0, length, text, &selected, &r_pos)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIfld_get_text = <%d>\n", status));
        if (text) free (text);
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_get_text", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    _NFIdebug ((fname, "text = <%s>\n", text));

    /*  There needs to be a better way to delete value buffer info  */
/*
    if ((strcmp (text, "")) == 0)
      {
        if (text) free (text);
        _NFIdebug ((fname, " returning SUCCESS\n"));
        return (NFI_S_SUCCESS);
      }
*/
    attr_ptr = (char **) (catalog->cat_attr)->data_ptr;
    row_no = catalog->active_attribute * (catalog->cat_attr)->columns;

    /*  See if this is a "create" or "change" command  */

    if (catalog->command == CREATE)
      {
        /*  Use list_or_keyin  */

        if ((status = _NFFfind_column_offset
            (catalog->cat_attr, list_or_keyin, &list_offset)) != NFI_S_SUCCESS)
          {
            _NFIdebug ((fname, "_NFFfind_column_offset = <0x%.8x>\n", status));
            if (text) free (text);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (status);
          }
      }
    else
      {
        /*  Check new_list_or_keyin  */

        strcpy (new_list_or_keyin, "new_");
        strcat (new_list_or_keyin, list_or_keyin);

        if ((status = _NFFfind_column_offset (catalog->cat_attr,
            new_list_or_keyin, &list_offset)) != NFI_S_SUCCESS)
          {
            _NFIdebug ((fname, "_NFFfind_column_offset = <0x%.8x>\n", status));
            if (text) free (text);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (status);
          }

        /*  If "", use list_or_keyin  */

        if ((strcmp (attr_ptr[row_no + list_offset], "")) == 0)
          {
            /*  This is a user-defined attribute that was
                added during THIS invocation of the command  */

            /*  Use list_or_keyin  */

            if ((status = _NFFfind_column_offset (catalog->cat_attr,
                list_or_keyin, &list_offset)) != NFI_S_SUCCESS)
              {
                _NFIdebug ((fname,
                    "_NFFfind_column_offset = <0x%.8x>\n", status));
                if (text) free (text);
                _NFIdebug ((fname, " returning FAILURE\n"));
                return (status);
              }
          }
        else
          {
            /*  This is a user-defined attribute that was
                added in a PREVIOUS invocation of the command  */

            old_attr = TRUE;
          }
      }

    list_no = atoi (attr_ptr[row_no + list_offset]);
    _NFIdebug ((fname, "list_no = <%d>\n", list_no));

    if (list_no == -1)
      {
        _NFIdebug ((fname, "This attribute cannot have values\n"));
        if (text) free (text);
        ERRload_struct (NFI, NFI_I_NO_VALIDATION_ALLOWED, NULL);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_I_NO_VALIDATION_ALLOWED);
      }
    else if (list_no > 0)
      {
        _NFIdebug ((fname, "Resetting to cat_value buffer #%d\n", list_no));

        if ((status = MEMreset_buffer_no
            (catalog->cat_value, list_no)) != MEM_S_SUCCESS)
          {
            _NFIdebug ((fname, "MEMreset_buffer_no = <0x%.8x>\n", status));
            if (text) free (text);
            ERRload_struct
                (NFI, NFI_E_MEM, "%s%x", "MEMreset_buffer_no", status);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_MEM);
          }

        row_size = (catalog->cat_value)->row_size;
        value_buffer_flag = EXISTING_LIST;
        buffer = catalog->cat_value;
      }
    else
      {
        _NFIdebug ((fname, "Building the buffer\n"));

        if ((status = _NFFbuild_value_buffer (&buffer)) != NFI_S_SUCCESS)
          {
            _NFIdebug ((fname, "_NFFbuild_value_buffer = <0x%.8x>\n", status));
            if (text) free (text);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (status);
          }

        row_size = buffer->row_size;
        list_no = 1;

        if (catalog->cat_value == NULL)
          {
            /*  There is no value buffer at all  */

            value_buffer_flag = NO_BUFFER;
	    _NFIdebug(( fname, "There is NO value buffer.\n" ));
          }
        else
          {
            /*  There is no value buffer for this attribute  */

            value_buffer_flag = NO_LIST;
	    _NFIdebug(( fname, "There is NO value buffer for this attribute.\n" ));
          }
      }

    /*  See if there needs to be a blank row written in the buffer  */

    if (buffer->rows < (row + 1))
      {
        /*  Find out how many buffers there are in the chain  */

	/*  JM - Sept. 2 
	 *  First check to see if this is a NULL buffer pointer
	 *  i.e., no value list.
	 */

	if( catalog->cat_value != NULL )
	  {
            if ((status = MEMno_buffers
                (catalog->cat_value, &no_buffers)) != MEM_S_SUCCESS)
              {
                _NFIdebug ((fname, "MEMno_buffers = <0x%.8x>\n", status));
                ERRload_struct (NFI,NFI_E_MEM,"%s%x", "MEMno_buffers", status);
                if (text) free (text);
                _NFIdebug ((fname, " returning FAILURE\n"));
                return (NFI_E_MEM);
              }
	  }

        /*  Everything's okay as long as this
            buffer is the last one in the chain  */

        if ((value_buffer_flag == EXISTING_LIST) && (no_buffers != list_no))
          {
            /*  This will not work at this time;  MEMwrite () will
                not honor the current buffer pointer.  It will blindly
                write a new row into the last buffer in the chain.
                For now, we will display a warning message for the user
                and return.  Glenn 3/10/92                              */

            status = NFI_W_ADD_TO_VALUE_LIST;
            ERRload_struct (NFI, status, NULL);
            _NFIdebug ((fname,
                "value lists cannot be added to at this time\n"));
            if (text) free (text);
            _NFIdebug ((fname, "returning FAILURE <0x%.8x>\n", status));
            return (status);
          }

        /*  Allocate space for a blank row
            (even though all space may not be needed)  */

        if ((blank_row = (char *) malloc (row_size)) == NULL)
          {
            _NFIdebug ((fname, "malloc failed; size = <%d>\n", row_size));
            if (text) free (text);
            if (value_buffer_flag != EXISTING_LIST)
                MEMclose (&buffer);
            ERRload_struct (NFI, NFI_E_MALLOC, "%d", row_size);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_MALLOC);
          }

        strcpy (blank_row, "");
        for (i = 0; i < buffer->columns; ++i)
            strcat (blank_row, "\1");

        _NFIdebug ((fname, "Writing a blank row into the buffer\n"));

        if ((status = MEMwrite (buffer, blank_row)) != MEM_S_SUCCESS)
          {
            _NFIdebug ((fname, "MEMwrite = <0x%.8x>\n", status));
            if (text) free (text);
            if (blank_row) free (blank_row);
            if (value_buffer_flag != EXISTING_LIST)
                MEMclose (&buffer);
            ERRload_struct (NFI, NFI_E_MEM, "%s%x", "MEMwrite", status);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_MEM);
          }

        if (blank_row) free (blank_row);

        _NFIdebug ((fname, "Rebuilding pointers in the buffer\n"));

        if ((status = MEMreset_buffer_no
            (buffer, list_no)) != MEM_S_SUCCESS)
          {
            _NFIdebug ((fname, "MEMreset_buffer_no = <0x%.8x>\n", status));
            if (text) free (text);
            if (value_buffer_flag != EXISTING_LIST)
                MEMclose (&buffer);
            ERRload_struct
                (NFI, NFI_E_MEM, "%s%x", "MEMreset_buffer_no", status);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_MEM);
          }
      }

    /*  Put the value type in the buffer  */

    if ((status = _NFFfind_column_offset
        (buffer, "n_input", &offset)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFfind_column_offset = <0x%.8x>\n", status));
        if (text) free (text);
        if (value_buffer_flag != EXISTING_LIST)
            MEMclose (&buffer);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    if ((status = MEMwrite_data
        (buffer, value_type, row + 1, offset + 1)) != MEM_S_SUCCESS)
      {
        _NFIdebug ((fname, "MEMwrite_data = <0x%.8x>\n", status));
        if (text) free (text);
        if (value_buffer_flag != EXISTING_LIST)
            MEMclose (&buffer);
        ERRload_struct (NFI, NFI_E_MEM, "%s%x", "MEMwrite_data", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_MEM);
      }

    /*  Put the data into the buffer  */

    if ((status = _NFFfind_column_offset
        (buffer, value_column, &offset)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFfind_column_offset = <0x%.8x>\n", status));
        if (text) free (text);
        if (value_buffer_flag != EXISTING_LIST)
            MEMclose (&buffer);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    _NFIdebug ((fname, "Writing <%s> in row %d, col %d in the buffer\n",
        text, row + 1, offset + 1));

    if ((status = MEMwrite_data
        (buffer, text, row + 1, offset + 1)) != MEM_S_SUCCESS)
      {
        _NFIdebug ((fname, "MEMwrite_data = <0x%.8x>\n", status));
        if (text) free (text);
        if (value_buffer_flag != EXISTING_LIST)
            MEMclose (&buffer);
        ERRload_struct (NFI, NFI_E_MEM, "%s%x", "MEMwrite_data", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_MEM);
      }

    if (text) free (text);

    /*  Put the type and application in for every input  */

    if ((status = _NFFfind_column_offset
        (buffer, "n_type", &offset)) != NFI_S_SUCCESS)
      {
        /*  This may not be in the buffer; if not, apparently,
            the buffer is still okay. COntinue, just don't
            try to write anything into it - Glenn 10/25/93    */

        _NFIdebug ((fname, "_NFFfind_column_offset = <0x%.8x>\n", status));
/*
        if (value_buffer_flag != EXISTING_LIST)
            MEMclose (&buffer);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
*/
      }

    else if ((status = MEMwrite_data
        (buffer, "S", row + 1, offset + 1)) != MEM_S_SUCCESS)
      {
        _NFIdebug ((fname, "MEMwrite_data = <0x%.8x>\n", status));
        if (value_buffer_flag != EXISTING_LIST)
            MEMclose (&buffer);
        ERRload_struct (NFI, NFI_E_MEM, "%s%x", "MEMwrite_data", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_MEM);
      }

    if ((status = _NFFfind_column_offset
        (buffer, "n_appname", &offset)) != NFI_S_SUCCESS)
      {
        /*  Same thing here as above - Glenn 10/25/93  */

        _NFIdebug ((fname, "_NFFfind_column_offset = <0x%.8x>\n", status));
/*
        if (value_buffer_flag != EXISTING_LIST)
            MEMclose (&buffer);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
*/
      }

    else if ((status = MEMwrite_data
        (buffer, "NFM", row + 1, offset + 1)) != MEM_S_SUCCESS)
      {
        _NFIdebug ((fname, "MEMwrite_data = <0x%.8x>\n", status));
        if (value_buffer_flag != EXISTING_LIST)
            MEMclose (&buffer);
        ERRload_struct (NFI, NFI_E_MEM, "%s%x", "MEMwrite_data", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_MEM);
      }

    /*  Put this buffer into the value buffer list  */

    if (value_buffer_flag == NO_BUFFER)
      {
        _NFIdebug ((fname, "Copying the buffer into cat_value\n"));

        if ((status = MEMsplit_copy_buffer
            (buffer, &(catalog->cat_value), 0)) != MEM_S_SUCCESS)
          {
            _NFIdebug ((fname, "MEMsplit_copy_buffer = <0x%.8x>\n", status));
            if (value_buffer_flag != EXISTING_LIST)
                MEMclose (&buffer);
            ERRload_struct
                (NFI, NFI_E_MEM, "%s%x", "MEMsplit_copy_buffer", status);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_MEM);
          }
      }
    else if (value_buffer_flag == NO_LIST)
      {
        _NFIdebug ((fname, "Appending buffer to cat_value\n"));

        if ((status = MEMappend (buffer, catalog->cat_value)) != MEM_S_SUCCESS)
          {
            _NFIdebug ((fname, "MEMappend = <0x%.8x>\n", status));
            if (value_buffer_flag != EXISTING_LIST)
                MEMclose (&buffer);
            ERRload_struct (NFI, NFI_E_MEM, "%s%x", "MEMappend", status);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_MEM);
          }
      }
    else
      {
        /*  There was an existing value buffer  */

        ;
      }

    /*  Close the temporary buffer  */

    if (value_buffer_flag != EXISTING_LIST)
        MEMclose (&buffer);

    /*  Update the list_no for this attribute  */

    if (value_buffer_flag != EXISTING_LIST)
      {
        if ((status = MEMno_buffers
            (catalog->cat_value, &list_no)) != MEM_S_SUCCESS)
          {
            _NFIdebug ((fname, "MEMno_buffers = <0x%.8x>\n", status));
            ERRload_struct (NFI, NFI_E_MEM, "%s%x", "MEMno_buffers", status);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_MEM);
          }
      }

    sprintf (list_str, "%d", list_no);

    _NFIdebug ((fname, "Writing list_no <%s> at row %d, col %d in cat_attr\n",
        list_str, catalog->active_attribute + 1, list_offset + 1));

    if ((status = MEMwrite_data (catalog->cat_attr, list_str,
        catalog->active_attribute + 1, list_offset + 1)) != MEM_S_SUCCESS)
      {
        _NFIdebug ((fname, "MEMwrite_data = <0x%.8x>\n", status));
        ERRload_struct (NFI, NFI_E_MEM, "%s%x", "MEMwrite_data", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_MEM);
      }

    /*  If this is a change to an existing list (in a "change" command),
        overwrite the n_valueno in the attribute buffer (set it to "0").
        This way the server will think that the new_n_valueno is a newly
        added value list.  The old list is not needed on the server.    */

    if (old_attr == TRUE)
      {
        if ((status = _NFFfind_column_offset
            (catalog->cat_attr, list_or_keyin, &offset)) != NFI_S_SUCCESS)
          {
            _NFIdebug ((fname, "_NFFfind_column_offset = <0x%.8x>\n", status));
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (status);
          }

        sprintf (list_str, "%d", 0);

        _NFIdebug ((fname, "Overwriting n_valueno in cat_attr\n"));

        if ((status = MEMwrite_data (catalog->cat_attr, list_str,
            catalog->active_attribute + 1, offset + 1)) != MEM_S_SUCCESS)
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


long _NFFcat_convert_catalog_name (form, label, attr_list, active_row, text)
  Form      form;
  int       label;
  MEMptr    attr_list;
  int       active_row;
  char      *text;
  {
    int     i;
    int     row_no;
    int     total_data;
    long    status;
    char    **data_ptr;
    short   offset;

    static    char *fname = "_NFFcat_convert_catalog_name";

    _NFIdebug ((fname, "text = <%s>\n", text));

    if ((status = _NFFfind_column_offset
        (attr_list, "n_name", &offset)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFfind_column_offset = <0x%.8x>\n", status));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    data_ptr = (char **) attr_list->data_ptr;

    row_no = -1;
    total_data = attr_list->rows * attr_list->columns;
    for (i = 0; i < total_data; i += attr_list->columns)
      {
        if ((strcmp (data_ptr[i + offset], "n_catalogname")) == 0)
          {
            row_no = i / attr_list->columns;
            break;
          }
      }

    if (row_no == -1)
      {
        _NFIdebug ((fname, "catalog name was not found in loc_attr\n"));
        ERRload_struct (NFI, NFI_E_BUFFER, NULL);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_BUFFER);
      }

    if (row_no == active_row)
      {
        _NFIdebug ((fname, "catalog name = <%s>\n", text));

        for (i = 0; i < strlen (text); ++i)
            text[i] = tolower (text[i]);

        _NFIdebug ((fname, "catalog name = <%s>\n", text));

        FIfld_set_text (form, label, 0, 0, text, FALSE);
      }

    _NFIdebug ((fname, " returning SUCCESS\n"));
    return (NFI_S_SUCCESS);
  }


long _NFFcat_attributes_gadgets (form, mode)
  Form   form;
  int    mode;
  {
    int     status;
    int     (*function_ptr) ();
    char    function_name[20];

    static  char *fname = "_NFFcat_attributes_gadgets";

    if (mode == ERASE)
      {
        _NFIdebug ((fname, "form function is FIg_erase\n"));
        function_ptr = FIg_erase;
        strcpy (function_name, "FIg_erase");
      }
    else
      {
        _NFIdebug ((fname, "form function is FIg_display\n"));
        function_ptr = FIg_display;
        strcpy (function_name, "FIg_display");
      }

    if ((status = (*function_ptr) (form, ATTRIBUTES_GROUP)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "form function status = <%d>\n", status));
        _NFIdebug ((fname,
            "label is ATTRIBUTES_GROUP <%d>\n", ATTRIBUTES_GROUP));
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", function_name, status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    if ((status = (long) _NFFcat_bezels (form, mode)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFcat_bezels = <0x%.8x>\n", status));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    if ((status = (*function_ptr) (form, USER_DEFINED_BUTTONS)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "form function status = <%d>\n", status));
        _NFIdebug ((fname,
            "label is USER_DEFINED_BUTTONS <%d>\n", USER_DEFINED_BUTTONS));
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", function_name, status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    if ((status = (*function_ptr) (form, KEYIN_FIELD_GROUP)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "form function status = <%d>\n", status));
        _NFIdebug ((fname,
            "label is KEYIN_FIELD_GROUP <%d>\n", KEYIN_FIELD_GROUP));
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", function_name, status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    if ((status = (*function_ptr) (form, CHARACTERISTICS_GROUP)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "form function status = <%d>\n", status));
        _NFIdebug ((fname,
            "label is CHARACTERISTICS_GROUP <%d>\n", CHARACTERISTICS_GROUP));
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", function_name, status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    if ((status = (*function_ptr)
        (form, VALIDATE_BUTTON_PALETTE)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "form function status = <%d>\n", status));
        _NFIdebug ((fname, "label is VALIDATE_BUTTON_PALETTE <%d>\n",
            VALIDATE_BUTTON_PALETTE));
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", function_name, status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    if ((status = (*function_ptr) (form, VALIDATE_TOGGLE)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "form function status = <%d>\n", status));
        _NFIdebug ((fname,
            "label is VALIDATE_TOGGLE <%d>\n", VALIDATE_TOGGLE));
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", function_name, status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    if ((status = (*function_ptr) (form, ADVISORY_FIELD)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "form function status = <%d>\n", status));
        _NFIdebug ((fname, "label is ADVISORY_FIELD <%d>\n", ADVISORY_FIELD));
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", function_name, status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    if ((status = (*function_ptr) (form, INFO_RANGE_GROUP)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "form function status = <%d>\n", status));
        _NFIdebug ((fname,
            "label is INFO_RANGE_GROUP <%d>\n", INFO_RANGE_GROUP));
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", function_name, status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    if ((status = (*function_ptr) (form, VALIDATE_LIST_GROUP)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "form function status = <%d>\n", status));
        _NFIdebug ((fname,
            "label is VALIDATE_LIST_GROUP <%d>\n", VALIDATE_LIST_GROUP));
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", function_name, status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    _NFIdebug ((fname, " returning SUCCESS\n"));
    return (NFI_S_SUCCESS);
  }


long _NFFcat_information_gadgets (form, mode)
  Form   form;
  int    mode;
  {
    int     status;
    int     (*function_ptr) ();
    char    function_name[20];

    static  char *fname = "_NFFcat_information_gadgets";

    if (mode == ERASE)
      {
        _NFIdebug ((fname, "form function is FIg_erase\n"));
        function_ptr = FIg_erase;
        strcpy (function_name, "FIg_erase");
      }
    else
      {
        _NFIdebug ((fname, "form function is FIg_display\n"));
        function_ptr = FIg_display;
        strcpy (function_name, "FIg_display");
      }

    if ((status = (*function_ptr) (form, LOC_BEZEL)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "form function status = <%d>\n", status));
        _NFIdebug ((fname, "label is LOC_BEZEL <%d>\n", LOC_BEZEL));
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", function_name, status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    if ((status = (*function_ptr) (form, INFORMATION_GROUP)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "form function status = <%d>\n", status));
        _NFIdebug ((fname,
            "label is INFORMATION_GROUP <%d>\n", INFORMATION_GROUP));
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", function_name, status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    _NFIdebug ((fname, " returning SUCCESS\n"));
    return (NFI_S_SUCCESS);
  }


long _NFFcat_bezels (form, mode)
  Form   form;
  int    mode;
  {
    int     status;
    int     (*function_ptr) ();
    char    function_name[20];

    static    char *fname = "_NFFcat_bezels";

    if (mode == ERASE)
      {
        _NFIdebug ((fname, "form function is FIg_erase\n"));
        function_ptr = FIg_erase;
        strcpy (function_name, "FIg_erase");
      }
    else
      {
        _NFIdebug ((fname, "form function is FIg_display\n"));
        function_ptr = FIg_display;
        strcpy (function_name, "FIg_display");
      }

    if ((status = (*function_ptr) (form, LEFT_BEZEL)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "form function status = <%d>\n", status));
        _NFIdebug ((fname, "label is LEFT_BEZEL <%d>\n", LEFT_BEZEL));
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", function_name, status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    if ((status = (*function_ptr) (form, MID_TOP_BEZEL)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "form function status = <%d>\n", status));
        _NFIdebug ((fname, "label is MID_TOP_BEZEL <%d>\n", MID_TOP_BEZEL));
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", function_name, status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    if ((status = (*function_ptr) (form, MID_BOTTOM_BEZEL)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "form function status = <%d>\n", status));
        _NFIdebug ((fname,
            "label is MID_BOTTOM_BEZEL <%d>\n", MID_BOTTOM_BEZEL));
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", function_name, status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    if ((status = (*function_ptr) (form, RIGHT_BEZEL)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "form function status = <%d>\n", status));
        _NFIdebug ((fname, "label is RIGHT_BEZEL <%d>\n", RIGHT_BEZEL));
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", function_name, status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    _NFIdebug ((fname, " returning SUCCESS\n"));
    return (NFI_S_SUCCESS);
  }


long _NFFfind_highest_seqno (catalog, seqno)
  NFFcatalog   catalog;
  int          *seqno;
  {
    int     i;
    int     temp;
    int     highest = 0;
    int     total_fields;
    long    status;
    char    **data_ptr;
    short   offset;

    static  char *fname = "_NFFfind_highest_seqno";

    _NFIdebug ((fname, "entering ...\n"));

    /*  Find the maximum seqno from the attribute buffer  */

    data_ptr = (char **) (catalog->cat_attr)->data_ptr;

    if ((status = _NFFfind_column_offset
        (catalog->cat_attr, "n_seqno", &offset)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFfind_column_offset = <0x%.8x>\n", status));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    total_fields = (catalog->cat_attr)->rows * (catalog->cat_attr)->columns;
    for (i = 0; i < total_fields; i += (catalog->cat_attr)->columns)
      {
        temp = atoi (data_ptr[i + offset]);
        if (temp > highest)
            highest = temp;
      }

    _NFIdebug ((fname, "highest = <%d>\n", highest));

    *seqno = highest;

    _NFIdebug ((fname, " returning SUCCESS\n"));
    return (NFI_S_SUCCESS);
  }


long _NFFcat_set_range_attr (form, datatype)
  Form    form;
  char    *datatype;
  {
    int     status;
    int     type;
    char    format[5];

    static  char *fname = "_NFFcat_set_range_attr";

    /*  Set the input type and format string of the range fields  */

    if ((strcmp (datatype, "integer")) == 0)
      {
        type = FI_INT;
        strcpy (format, "%d");
      }
    else if ((strcmp (datatype, "smallint")) == 0)
      {
        type = FI_INT;
        strcpy (format, "%d");
      }
    else if ((strcmp (datatype, "double")) == 0)
      {
        type = FI_DOUBLE;
        strcpy (format, "%lG");
      }
    else if ((strcmp (datatype, "real")) == 0)
      {
        type = FI_DOUBLE;
        strcpy (format, "%lG");
      }
    else if ((strcmp (datatype, "decimal")) == 0)
      {
        type = FI_DOUBLE;
        strcpy (format, "%lG");
      }
    else if ((strcmp (datatype, "date")) == 0)
      {
        type = FI_INT;
        strcpy (format, "%d");
      }
    else
      {
        type = FI_ALPHA;
        strcpy (format, "%s");
      }

    _NFIdebug ((fname, "Setting min and max fields to type <%d>\n", type));

    if ((status = FIfld_set_type
        (form, INFO_MIN_FIELD, 0, type)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIfld_set_type = <%d>\n", status));
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_type", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    if ((status = FIfld_set_type
        (form, INFO_MAX_FIELD, 0, type)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIfld_set_type = <%d>\n", status));
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_type", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    _NFIdebug ((fname, "Setting min and max fields to format <%s>\n", format));

    if ((status = FIfld_set_format_string
        (form, INFO_MIN_FIELD, 0, format)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIfld_set_format_string = <%d>\n", status));
        ERRload_struct
            (NFI, NFI_E_FORM, "%s%d", "FIfld_set_format_string", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    if ((status = FIfld_set_format_string
        (form, INFO_MAX_FIELD, 0, format)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIfld_set_format_string = <%d>\n", status));
        ERRload_struct
            (NFI, NFI_E_FORM, "%s%d", "FIfld_set_format_string", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    _NFIdebug ((fname, " returning SUCCESS\n"));
    return (NFI_S_SUCCESS);
  }
