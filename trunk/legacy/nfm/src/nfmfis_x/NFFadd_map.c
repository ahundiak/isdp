
/* machine.h included to take care of platform variencies MVR 23 Dec 1993 */
#include "machine.h"

#include "NFF.h"
#include "NFFmap.h"

/*  Global NFF structure  */

extern struct NFFglobal_st NFFglobal;

long _NFFadd_mapping (title1, title2, entity)
  char      *title1;
  char      *title2;
  NFFmap    entity;
  {
    auto    long    status;
    static  char    *fname = "_NFFadd_mapping";

    /*  Load in the form  */

    if ((status = (long) FIf_new (ADD_MAPPING_LABEL, MAPPING_FORM,
        _NFFnotify, &(NFFglobal.current_form))) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIf_new = <%d>\n", status));
        _NFFfree_map (entity, NULL);
        NFFset_to_state ();
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIf_new", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    /*  Create the mcf from the value_list  */

    if ((status = _NFFmap_load_value_list
        (NFFglobal.current_form, entity, TRUE)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFmap_load_value_list = <0x%.8x>\n", status));
        _NFFfree_map (entity, &NFFglobal.current_form);
        NFFset_to_state ();
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    /*  Store a pointer to the data in the form  */

    if ((status = (long) FIf_set_user_pointer
        (NFFglobal.current_form, (char *) entity)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIf_set_user_pointer = <%d>\n", status));
        _NFFfree_map (entity, &NFFglobal.current_form);
        NFFset_to_state ();
        ERRload_struct
            (NFI, NFI_E_FORM, "%s%d", "FIf_set_user_pointer", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    /*  Center the form  */

    if ((status = _NFFcenter_form
        (NFFglobal.current_form, -1, Y_FORM_POS)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFcenter_form = <0x%.8x>\n", status));
        _NFFfree_map (entity, &NFFglobal.current_form);
        NFFset_to_state ();
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    /*  Set the title  */

    FIg_set_text (NFFglobal.current_form, TITLE1, title1);
    FIg_set_text (NFFglobal.current_form, TITLE2, title2);

    /*  Display the form  */

    if ((status = (long) FIf_display (NFFglobal.current_form)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIf_display = <%d>\n", status));
        _NFFfree_map (entity, &NFFglobal.current_form);
        NFFset_to_state ();
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIf_display", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    _NFIdebug ((fname, " returning SUCCESS\n"));
    return (NFI_S_SUCCESS);
  }


long _NFFadd_map_notify (g_label, row, form)
  int       g_label;
  int       row;
  Form      *form;
  {
    auto    long    status = NFI_S_SUCCESS;
    auto    char    command[15];
    static  char    *fname = "_NFFadd_map_notify";

    /*  Pointer to structure to store the MEM pointers in  */

    NFFmap  entity;

    _NFIdebug ((fname, "g_label = %d\n", g_label));

    /*  Pull out the pointer to all of the buffers  */

    FIf_get_user_pointer (*form, &entity);

    switch (g_label)
      {
        case FI_HELP:

            switch (entity->command)
              {
                case ADD_CATALOG_ACL_MAP:
                    strcpy (command, NFI_M_ADD_CATALOG_ACL_MAPPING);
                    break;

                case ADD_CATALOG_SA_MAP:
                    strcpy (command, NFI_M_ADD_CATALOG_SA_MAPPING);
                    break;

                case ADD_PROJECT_ACL_MAP:
                    strcpy (command, NFI_M_ADD_PROJECT_ACL_MAPPING);
                    break;

                case ADD_PROJECT_SA_MAP:
                    strcpy (command, NFI_M_ADD_PROJECT_SA_MAPPING);
                    break;

                case ADD_ACL_CLASS_USERS:
                    strcpy (command, NFI_M_ADD_ACL_CLASS_USERS);
                    break;

                case ADD_ACL_SIGNOFF_USERS:
                    strcpy (command, NFI_M_ADD_ACL_SIGNOFF_USERS);
                    break;
              }

            if (status = _NFFhelp_topic (command))
              {
                _NFIdebug ((fname, "_NFFhelp_topic = <%d>\n", status));
                ERRload_struct (NFI, NFI_E_HELP, "%s%d", "_NFFhelp_topic", status);
                status = NFI_E_HELP;
              }

            break;

        case FI_CANCEL:

            /*  Load the global error structure  */

            ERRload_struct (NFI, NFI_W_COMMAND_CANCELLED, NULL);

            /*  Set the next state  */

            if ((status = NFFset_to_state ()) != NFI_S_SUCCESS)
                _NFIdebug ((fname, "NFFset_to_state = <0x%.8x>\n", status));

            /*  Close all allocated buffers and delete the form  */

            _NFFfree_map (entity, form);

            break;

        case FI_ACCEPT:

            /*  Prepare the data_list  */

            if ((status = _NFFmap_load_data_list (*form, entity->data_list,
                (int) entity->validate_row, "ADD")) != NFI_S_SUCCESS)
              {
                _NFIdebug ((fname,
                    "_NFFmap_load_data_list = <0x%.8x>\n", status));
                FIg_reset (*form, FI_ACCEPT);
                break;
              }

            if (_NFMdebug_st.NFIdebug_on)
              {
                MEMprint_buffer ("attr_list",
                    entity->attr_list, _NFMdebug_st.NFIdebug_file);
                MEMprint_buffer ("data_list",
                    entity->data_list, _NFMdebug_st.NFIdebug_file);
              }

            /*  Put up a message  */

            NFFform_message (CURRENT_LABEL, NFFglobal.working_no, NULL);

            /*  Call NFMR to update the mapping  */

            status = (long) NFFglobal.NFMRfunction[1]
                ((long) 0, entity->attr_list, entity->data_list);
            _NFIdebug ((fname,
                "NFMR update map function = <0x%.8x>\n", status));

            /*  Erase the message  */

            NFFerase_message ();

            /*  Save the return status  */

            NFFglobal.status = status;

            /*  Set the next state  */

            if ((status = NFFset_to_state ()) != NFI_S_SUCCESS)
                _NFIdebug ((fname, "NFFset_to_state = <0x%.8x>\n", status));

            /*  Close all allocated buffers and delete the form  */

            _NFFfree_map (entity, form);

            break;

        case BOTTOM_MCF:
            status = _NFFmap_bottom_mcf (*form, g_label, row);
            break;
      }

    _NFIdebug ((fname, " returning <0x%.8x>\n", status));
    return (status);
  }


long _NFFmap_bottom_mcf (form, label, row)
  Form   form;
  int    label;
  int    row;
  {
    auto    int     status;
    auto    int     selected;
    auto    int     col, pos;
    static  char    *fname = "_NFFmap_bottom_mcf";

    _NFIdebug ((fname, "row = <0x%.8x>\n", row));

    /*  See if the checkbox was selected  */

    if (row == -1)
      {
        /*  Find out which row was selected  */

        if ((status = (long) FIfld_get_active_row
            (form, label, &row, &pos)) != FI_SUCCESS)
          {
            _NFIdebug ((fname, "FIfld_get_active_row = <%d>\n", status));
            ERRload_struct
                (NFI, NFI_E_FORM, "%s%d", "FIfld_get_active_row", status);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_FORM);
          }

        /*  Find out if the row is selected or not  */

        if ((status = (long) FImcf_get_select
            (form, label, row, &selected)) != FI_SUCCESS)
          {
            _NFIdebug ((fname, "FImcf_get_select = <%d>\n", status));
            ERRload_struct
                (NFI, NFI_E_FORM, "%s%d", "FImcf_get_select", status);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_FORM);
          }

        if (selected == FALSE)
          {
            _NFIdebug ((fname, "Row was unselected with the checkbox\n"));
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
        /*  Find out if the row is selected or not  */

        if ((status = (long) FImcf_get_active_col
            (form, label, &col, &pos)) != FI_SUCCESS)
          {
            _NFIdebug ((fname, "FImcf_get_active_col = <%d>\n", status));
            ERRload_struct
                (NFI, NFI_E_FORM, "%s%d", "FImcf_get_active_col", status);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_FORM);
          }

        if ((status = (long) FIfld_get_select
            (form, label, row, col, &selected)) != FI_SUCCESS)
          {
            _NFIdebug ((fname, "FIfld_get_select = <%d>\n", status));
            ERRload_struct
                (NFI, NFI_E_FORM, "%s%d", "FIfld_get_select", status);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_FORM);
          }

        /*  Select or unselect this entire row  */

        if ((status = (long) FImcf_set_select
            (form, label, row, selected)) != FI_SUCCESS)
          {
            _NFIdebug ((fname, "FImcf_set_select = <%d>\n", status));
            ERRload_struct
                (NFI, NFI_E_FORM, "%s%d", "FImcf_set_select", status);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_FORM);
          }

        if (selected == FALSE)
          {
            _NFIdebug ((fname, "Row was unselected\n"));
            _NFIdebug ((fname, " returning SUCCESS\n"));
            return (NFI_S_SUCCESS);
          }
      }

    _NFIdebug ((fname, " returning SUCCESS\n"));
    return (NFI_S_SUCCESS);
  }


long _NFFmap_load_data_list (form, data_list, attr_row_offset, keyword)
  Form      form;
  MEMptr    data_list;
  int       attr_row_offset;
  char      *keyword;
  {
    auto    int     i, j;
    auto    int     num_rows;
    auto    int     selected;
    auto    int     sel_flag = 0;
    auto    int     r_pos;
    auto    int     length;
    auto    int     fields;
    auto    int     data_row = 0;
    auto    long    status;
    auto    char    *text;
    auto    char    **data_ptr;
    auto    short   found;
    auto    short   offset;
    auto    int     label = MAP_BOTTOM_MCF;
    static  char    *fname = "_NFFmap_load_data_list";

    _NFIdebug ((fname, "keyword = <%s>\n", keyword));

    if ((status = MEMbuild_array (data_list)) != MEM_S_SUCCESS)
      {
        _NFIdebug ((fname, "MEMbuild_array = <0x%.8x>\n", status));
        ERRload_struct (NFI, NFI_E_MEM, "%s%x", "MEMbuild_array", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_MEM);
      }

    /*  Scan the mcf for all selected rows  */

    if ((status = (long) FIfld_get_num_rows
        (form, label, &num_rows)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIfld_get_num_rows = <%d>\n", status));
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_get_num_rows", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    for (i = 0; i < num_rows; ++i)
      {
        if ((status = (long) FIfld_get_select
            (form, label, i, 0, &selected)) != FI_SUCCESS)
          {
            _NFIdebug ((fname, "FIfld_get_select = <%d>\n", status));
            ERRload_struct
                (NFI, NFI_E_FORM, "%s%d", "FIfld_get_select", status);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_FORM);
          }

        if (selected == FALSE) continue;
	sel_flag++;
        /*  Put the first column's data in the data_list  */

        if ((status = (long) FIfld_get_text_length
            (form, label, i, 0, &length)) != FI_SUCCESS)
          {
            _NFIdebug ((fname, "FIfld_get_text_length = <%d>\n", status));
            ERRload_struct
                (NFI, NFI_E_FORM, "%s%d", "FIfld_get_text_length", status);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_FORM);
          }

        _NFIdebug ((fname, "length of text = <0x%.8x>\n", length));

        if (length == 0)
          {
            ERRload_struct (NFI, NFI_E_BUFFER, NULL);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_BUFFER);
          }

        if ((text = (char *) malloc (length)) == NULL)
          {
            _NFIdebug ((fname, "malloc failed; size = <%d>\n", length));
            ERRload_struct (NFI, NFI_E_MALLOC, "%d", length);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_MALLOC);
          }

        if ((status = (long) FIfld_get_text (form, label,
            i, 0, length, text, &selected, &r_pos)) != FI_SUCCESS)
          {
            _NFIdebug ((fname, "FIfld_get_text = <%d>\n", status));
            if (text) free (text);
            ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_get_text", status);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_FORM);
          }

        /*  Look in the buffer to see if this row already exists  */

        data_ptr = (char **) data_list->data_ptr;
        fields = data_list->rows * data_list->columns;

        found = FALSE;
        for (j = attr_row_offset; j < fields; j += data_list->columns)
          {
            if ((strcmp (data_ptr[j], text)) == 0)
              {
                data_row = (j / data_list->columns) + 1;
                found = TRUE;
                break;
              }
          }

        if (found == FALSE)
          {
            _NFIdebug ((fname, "An existing row was not found\n"));

            if ((status = _NFFmap_write_blank_row
                (data_list)) != NFI_S_SUCCESS)
              {
                _NFIdebug ((fname,
                    "_NFFmap_write_blank_row = <0x%.8x>\n", status));
                _NFIdebug ((fname, " returning FAILURE\n"));
                return (status);
              }

            data_row = data_list->rows;
          }

        _NFIdebug ((fname, "Writing <%s> into row %d, col %d in data_list\n",
            text, data_row, attr_row_offset + 1));

        if ((status = MEMwrite_data (data_list, text,
            data_row, attr_row_offset + 1)) != MEM_S_SUCCESS)
          {
            _NFIdebug ((fname, "MEMwrite_data = <0x%.8x>\n", status));
            if (text) free (text);
            ERRload_struct (NFI, NFI_E_MEM, "%s%x", "MEMwrite_data", status);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_MEM);
          }

        if ((status = _NFFfind_column_offset
            (data_list, "n_status", &offset)) != NFI_S_SUCCESS)
          {
            _NFIdebug ((fname, "_NFFfind_column_offset = <0x%.8x>\n", status));
            if (text) free (text);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (status);
          }

        _NFIdebug ((fname, "Writing <%s> into row %d, col %d in data_list\n",
            keyword, data_row, offset + 1));

        if ((status = MEMwrite_data (data_list,
            keyword, data_row, (int) offset + 1)) != MEM_S_SUCCESS)
          {
            _NFIdebug ((fname, "MEMwrite_data = <0x%.8x>\n", status));
            if (text) free (text);
            ERRload_struct (NFI, NFI_E_MEM, "%s%x", "MEMwrite_data", status);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_MEM);
          }

        if (text) free (text);
      }

/**** start of modification -   IGI  CN - 13/09/95    */
    if (sel_flag == 0 )
    {
	if ((status = (long) FIg_get_text_length
            (form, TITLE1, &length)) != FI_SUCCESS)
          {
            _NFIdebug ((fname, "FIg_get_text_length = <%d>\n", status));
            ERRload_struct
                (NFI, NFI_E_FORM, "%s%d", "FIg_get_text_length", status);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_FORM);
          }
 
        _NFIdebug ((fname, "length of text = <0x%.8x>\n", length));
 
        if (length == 0)
          {
            ERRload_struct (NFI, NFI_E_BUFFER, NULL);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_BUFFER);
          }
 
        if ((text = (char *) malloc (length)) == NULL)
          {
            _NFIdebug ((fname, "malloc failed; size = <%d>\n", length));
            ERRload_struct (NFI, NFI_E_MALLOC, "%d", length);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_MALLOC);
          }
	if ((status = (long) FIg_get_text (form, TITLE1,text)) != FI_SUCCESS)
          {
            _NFIdebug ((fname, "FIfld_get_text = <%d>\n", status));
            if (text) free (text);
            ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_get_text", status);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_FORM);
          }

	if ( strstr(text,"ACL") == NULL )
              ERRload_struct(NFI,NFI_E_NO_ST_AREA,NULL);
	else
              ERRload_struct (NFI, NFI_E_NO_ACL, NULL);

	if (text) free(text);
     }
/***** end of modification *****/

    _NFIdebug ((fname, " returning SUCCESS\n"));
    return (NFI_S_SUCCESS);
  }


long _NFFmap_write_blank_row (data_list)
  MEMptr    data_list;
  {
    auto    int     i;
    auto    long    status;
    auto    char    *blank_row;
    static  char    *fname = "_NFFmap_write_blank_row";

    _NFIdebug ((fname, "Writing a blank row in the data_list\n"));

    if ((blank_row = (char *) malloc (data_list->columns + 1)) == NULL)
      {
        _NFIdebug ((fname,
            "malloc failed; size = <%d>\n", data_list->columns + 1));
        ERRload_struct (NFI, NFI_E_MALLOC, "%d", data_list->columns + 1);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_MALLOC);
      }

    strcpy (blank_row, "");
    for (i = 0; i < data_list->columns; ++i)
        strcat (blank_row, "\1");

    /*  Write a blank row into the data_list  */

    if ((status = MEMwrite (data_list, blank_row)) != MEM_S_SUCCESS)
      {
        _NFIdebug ((fname, "MEMwrite = <0x%.8x>\n", status));
        ERRload_struct (NFI, NFI_E_MEM, "%s%x", "MEMwrite", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_MEM);
      }

    if (blank_row) free (blank_row);

    if ((status = MEMbuild_array (data_list)) != MEM_S_SUCCESS)
      {
        _NFIdebug ((fname, "MEMbuild_array = <0x%.8x>\n", status));
        ERRload_struct (NFI, NFI_E_MEM, "%s%x", "MEMbuild_array", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_MEM);
      }

    _NFIdebug ((fname, " returning SUCCESS\n"));
    return (NFI_S_SUCCESS);
  }
