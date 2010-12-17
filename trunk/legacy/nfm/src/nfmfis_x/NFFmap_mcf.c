
/* machine.h included to take care of platform variencies MVR 23 Dec 1993 */
#include "machine.h"

#include "NFF.h"
#include "NFFmap.h"

/*  Global NFF structure  */

extern struct NFFglobal_st NFFglobal;

long _NFFmap_load_value_list (form, entity, filter_flag)
  Form      form;
  NFFmap    entity;
  int       filter_flag;
  {
    auto    int     row_no;
    auto    int     list_no;
    auto    long    status;
    auto    char    **data_ptr;
    auto    short   offset;
    static  char    *fname = "_NFFmap_load_value_list";

    _NFIdebug ((fname, "filter_flag = <%d>\n", filter_flag));

    /*  Find the value_list for the attribute  */

    if ((status = _NFFfind_column_offset
        (entity->attr_list, "n_valueno", &offset)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFfind_column_offset = <0x%.8x>\n", status));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    data_ptr = (char **) (entity->attr_list)->data_ptr;
    row_no = entity->validate_row * (entity->attr_list)->columns;
    list_no = atoi (data_ptr[row_no + offset]);

    _NFIdebug ((fname, "list_no = <%d>\n", list_no));

    if (list_no == -1)
      {
        _NFIdebug ((fname, "this attribute cannot accept values\n"));
        ERRload_struct (NFI, NFI_I_NO_CAT_VALUES, NULL);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_I_NO_CAT_VALUES);
      }
    else if (list_no == 0)
      {
        _NFIdebug ((fname, "this attribute has no value_list\n"));
        ERRload_struct (NFI, NFI_I_NO_CAT_VALUES, NULL);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_I_NO_CAT_VALUES);
      }

    if ((status = MEMreset_buffer_no
        (entity->value_list, list_no)) != MEM_S_SUCCESS)
      {
        _NFIdebug ((fname, "MEMreset_buffer_no = <0x%.8x>\n", status));
        ERRload_struct (NFI, NFI_E_MEM, "%s%x", "MEMreset_buffer_no", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_MEM);
      }

    /*  Create the mcf to reflect the value_list  */

    if ((status = _NFFmap_create_mcf
        (form, MAP_TOP_MCF, entity->value_list)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFmap_create_mcf = <0x%.8x>\n", status));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    if ((status = _NFFmap_create_mcf
        (form, MAP_BOTTOM_MCF, entity->value_list)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFmap_create_mcf = <0x%.8x>\n", status));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    /*  Load the value_list into the mcf  */

    if ((status = _NFFmap_load_mcf (form, filter_flag, entity->validate_row,
        entity->data_list, entity->value_list)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFmap_load_mcf = <0x%.8x>\n", status));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    /*  Center the mcfs on the form  */

    _NFFcenter_gadget (form, MAP_TOP_MCF);
    _NFFcenter_gadget (form, MAP_BOTTOM_MCF);

    _NFIdebug ((fname, " returning SUCCESS\n"));
    return (NFI_S_SUCCESS);
  }


long _NFFmap_create_mcf (form, label, value_list)
  Form      form;
  int       label;
  MEMptr    value_list;
  {
    auto    int     i, status;
    auto    int     num_cols;
    auto    int     num_rows;
    auto    int     num_chars;
    auto    int     vis_columns;
    auto    int     num_vis_cols;
    auto    int     attr_mask;
    auto    int     xpos, ypos;
    auto    int     justification;
    auto    struct  standard_st st_var;
    static  char    *fname = "_NFFmap_create_mcf";

    _NFIdebug ((fname, "label = <%d>\n", label));

    /*  Create the new mcf  */

    _NFIdebug ((fname, "Creating the new mcf\n"));

    if ((status = FIg_new (form, FI_MULTI_COL, label)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIg_new = <%d>\n", status));
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_new", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    /*  Load the standard variable structure  */

    _NFIdebug ((fname, "Getting the location of the hidden mcf\n"));

    if ((status = FIg_get_location
        (form, label - 100, &xpos, &ypos)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIg_get_location = <%d>\n", status));
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_get_location", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    st_var.xlo = xpos;
    st_var.ylo = ypos;
#if defined(OS_INTELSOL) /* IGI Intel Solaris Port 16/08/95 */  
    st_var.xhi = 300; 
    st_var.yhi = 200; 
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

    _NFIdebug ((fname,
        "Getting the number of visible columns of the hidden mcf\n"));

    if ((status = FImcf_get_num_vis_cols
        (form, label - 100, &num_vis_cols)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FImcf_get_num_vis_cols = <%d>\n", status));
        ERRload_struct
            (NFI, NFI_E_FORM, "%s%d", "FImcf_get_num_vis_cols", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

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

    if ((status = FImcf_set_num_cols (form, label, num_cols)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FImcf_set_num_cols = <%d>\n", status));
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FImcf_set_num_cols", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    /*  Set the number of visible rows  */

    if ((status = FIfld_get_num_vis_rows
        (form, label - 100, &num_rows)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIfld_get_num_vis_rows = <%d>\n", status));
        ERRload_struct
            (NFI, NFI_E_FORM, "%s%d", "FIfld_get_num_vis_rows", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

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

    if (label == MAP_TOP_MCF)
      {
        /*  Don't show the scroll bars  */

        attr_mask = FI_HORT_SCROLL | FI_NO_ROW_BUTTONS;
/*
        attr_mask = FI_DISABLE_VSCROLL | FI_DISABLE_HSCROLL;
*/
      }
    else
      {
        attr_mask = FI_VERT_SCROLL | FI_HORT_SCROLL;
        attr_mask |= FI_DISPLAY_VSCROLL | FI_ROW_SELECT | FI_NO_ROW_BUTTONS;

        if (num_cols > vis_columns)
            attr_mask |= FI_DISPLAY_HSCROLL;
        else
            attr_mask |= FI_DISABLE_HSCROLL;
      }

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

    if ((status = FIfld_get_num_vis_chars
        (form, label - 100, 0, &num_chars)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIfld_get_num_vis_chars = <%d>\n", status));
        ERRload_struct
            (NFI, NFI_E_FORM, "%s%d", "FIfld_get_num_vis_chars", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    if (label == MAP_TOP_MCF)
        justification = FI_CENTER_JUSTIFIED;
    else
        justification = FI_LEFT_JUSTIFIED;

    for (i = 0; i < num_cols; ++i)
      {
        /*  Set the number of visible characters  */

        _NFIdebug ((fname, "%d: Setting number of visible characters to %d\n",
            i, num_chars));

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

        _NFIdebug ((fname, "%d: Setting the mode to FI_MULTI_SELECT\n", i));

        if ((status = FIfld_set_mode
            (form, label, i, FI_MULTI_SELECT)) != FI_SUCCESS)
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

        if (label == MAP_BOTTOM_MCF)
          {
            /*  Disable every thing but NOTIFY_BY_LINE,
                HORT_SCROLL, DISPLAY_HSCROLL, and VERT_SCROLL  */

            attr_mask = FI_NOTIFY_BY_LINE | FI_VERT_SCROLL;
            attr_mask |= FI_HORT_SCROLL | FI_DISPLAY_HSCROLL;

            _NFIdebug ((fname, "%d: Setting field attributes\n", i));

            if ((status = FIfld_set_attr
                (form, label, i, attr_mask)) != FI_SUCCESS)
              {
                _NFIdebug ((fname, "FIfld_set_attr = <%d>\n", status));
                ERRload_struct
                    (NFI, NFI_E_FORM, "%s%d", "FIfld_set_attr", status);
                _NFIdebug ((fname, " returning FAILURE\n"));
                return (NFI_E_FORM);
              }
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

    if (label == MAP_BOTTOM_MCF)
      {
        /*  Link the scrolling of the bottom one to the top  */

        if ((status = FImcf_set_scroll_link
            (form, label, MAP_TOP_MCF)) != FI_SUCCESS)
          {
            _NFIdebug ((fname, "FImcf_set_scroll_link = <%d>\n", status));
            ERRload_struct
                (NFI, NFI_E_FORM, "%s%d", "FImcf_set_scroll_link", status);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_FORM);
          }
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

    /*  Display the gadget  */

    _NFIdebug ((fname, "Displaying the mcf\n"));

    if ((status = FIg_display (form, label)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIg_display = <%d>\n", status));
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_display", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    _NFIdebug ((fname, " returning SUCCESS\n"));
    return (NFI_S_SUCCESS);
  }


long _NFFmap_load_mcf (form, filter_flag, attr_row, data_list, value_list)
  Form      form;
  int       filter_flag;
  int       attr_row;
  MEMptr    data_list;
  MEMptr    value_list;
  {
    auto    int     i, status;
    auto    char    **column_ptr;
    auto    char    synonym[NFM_SYNONYM + 1];
    auto    int     label1 = MAP_TOP_MCF;
    auto    int     label2 = MAP_BOTTOM_MCF;
    static  char    *fname = "_NFFmap_load_mcf";

    _NFIdebug ((fname, "filter_flag = <%d>\n", filter_flag));
    _NFIdebug ((fname, "attr_row = <%d>\n", attr_row));

/* IGI Intel Solaris Port -CN 31/5/95 */
#if defined(OS_SCO_UNIX) || defined(OS_INTELSOL)
    /* work around change - to set font for SCO - SSRS 3 Feb 94 */
    FIg_set_font( form, label1, "7x13bold", 15 );
#endif

    column_ptr = (char **) value_list->column_ptr;

    for (i = 0; i < value_list->columns; ++i)
      {
        /*  Set the top mcf to reflect the attribute name  */

        if ((strcmp (column_ptr[i], "n_mapno")) == 0)
            strcpy (synonym, "Map Number");
        else if ((strcmp (column_ptr[i], "n_catalogname")) == 0)
            strcpy (synonym, "Catalog");
        else if ((strcmp (column_ptr[i], "n_aclno")) == 0)
            strcpy (synonym, "ACL Number");
        else if ((strcmp (column_ptr[i], "n_aclname")) == 0)
            strcpy (synonym, "ACL Name");
        else if ((strcmp (column_ptr[i], "n_workflowname")) == 0)
            strcpy (synonym, "Workflow Name");
        else if ((strcmp (column_ptr[i], "n_sano")) == 0)
            strcpy (synonym, "Storage Number");
        else if ((strcmp (column_ptr[i], "n_saname")) == 0)
            strcpy (synonym, "Storage Area");
        else
            strcpy (synonym, column_ptr[i]);

        _NFIdebug ((fname, "Setting <%s>\n", synonym));
        _NFIdebug ((fname, "in row %d, col %d in MAP_TOP_MCF\n", 0, i));

        if ((status = FIfld_set_text
            (form, label1, 0, i, synonym, FALSE)) != FI_SUCCESS)
          {
            _NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
            ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_text", status);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_FORM);
          }
      }

    /*  Set the number of rows to 0 to clear out the field  */

    _NFIdebug ((fname, "Setting number of rows to 0\n"));

    if ((status = FIfld_set_num_rows (form, label2, 0)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIfld_set_num_rows = <%d>\n", status));
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_num_rows", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    /*  Put the values in the mcf  */

    if (filter_flag == TRUE)
      {
        if ((status = _NFFmap_load_add_mcf
            (form, label2, attr_row, data_list, value_list)) != NFI_S_SUCCESS)
          {
            _NFIdebug ((fname, "_NFFmap_load_add_mcf = <0x%.8x>\n", status));
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (status);
          }
      }
    else
      {
        if ((status = _NFFmap_load_delete_mcf
            (form, label2, attr_row, data_list, value_list)) != NFI_S_SUCCESS)
          {
            _NFIdebug ((fname,
                "_NFFmap_load_delete_mcf = <0x%.8x>\n", status));
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (status);
          }
      }

    /*  Display the mcf  */

    _NFIdebug ((fname, "Displaying the MAP_TOP_MCF\n"));

    if ((status = FIg_display (form, label1)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIg_display = <%d>\n", status));
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_display", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    _NFIdebug ((fname, "Displaying the MAP_BOTTOM_MCF\n"));

    if ((status = FIg_display (form, label2)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIg_display = <%d>\n", status));
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_display", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    _NFIdebug ((fname, " returning SUCCESS\n"));
    return (NFI_S_SUCCESS);
  }


long _NFFmap_load_add_mcf (form, label, attr_row, data_list, value_list)
  Form      form;
  int       label;
  int       attr_row;
  MEMptr    data_list;
  MEMptr    value_list;
  {
    auto    int     status;
    auto    int     i, j;
    auto    int     mcf_row;
    auto    int     data_offset;
    auto    int     fields;
    auto    char    **data_ptr;
    auto    char    **value_ptr;
    auto    short   continue_flag;
    auto    short   at_least_one_row;
    static  char    *fname = "_NFFmap_load_add_mcf";

    _NFIdebug ((fname, "label = <%d>\n", label));
    _NFIdebug ((fname, "attr_row = <%d>\n", attr_row));

    at_least_one_row = FALSE;

    data_ptr = (char **) data_list->data_ptr;
    value_ptr = (char **) value_list->data_ptr;
    fields = data_list->rows * data_list->columns;

    for (i = 0, data_offset = 0, mcf_row = 0; i < value_list->rows; ++i)
      {
        /*  See if this row already exists in the data_list  */

        continue_flag = FALSE;

        for (j = 0; j < fields; j += data_list->columns)
          {
            /*  Check the index in the first column  */

            _NFIdebug ((fname, "comparing <%s> to <%s>\n",
                value_ptr[data_offset], data_ptr[j + attr_row]));

            if ((strcmp (value_ptr[data_offset], data_ptr[j + attr_row])) == 0)
              {
                _NFIdebug ((fname,
                    "row <%d> already exists in the data_list\n", i));
                continue_flag = TRUE;
                break;
              }
          }

        if (continue_flag == TRUE)
          {
            /*  Jump past this row  */

            data_offset += value_list->columns;
            continue;
          }

/* IGI Intel Solaris Port -CN 31/5/95 */
#if defined(OS_SCO_UNIX) || defined(OS_INTELSOL) 
        /* work around change - to set font for SCO - SSRS 3 Feb 94 */
        FIg_set_font( form, label, "7x13bold", 15 );
#endif

        for (j = 0; j < value_list->columns; ++j, ++data_offset)
          {
            /*  Set the bottom mcf to reflect the value_list  */

            _NFIdebug ((fname, "Setting <%s>\n", value_ptr[data_offset]));
            _NFIdebug ((fname,
                "in row %d, col %d in MAP_BOTTOM_MCF\n", mcf_row, j));

            if ((status = FIfld_set_text (form, label,
                mcf_row, j, value_ptr[data_offset], FALSE)) != FI_SUCCESS)
              {
                _NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
                ERRload_struct
                    (NFI, NFI_E_FORM, "%s%d", "FIfld_set_text", status);
                _NFIdebug ((fname, " returning FAILURE\n"));
                return (NFI_E_FORM);
              }
          }

        ++mcf_row;

        at_least_one_row = TRUE;
      }

    if (at_least_one_row == FALSE)
      {
        _NFIdebug ((fname,
            "all possible values already exist in the data_list\n"));
        ERRload_struct (NFI, NFI_I_ALL_VALUES, NULL);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_I_ALL_VALUES);
      }

    _NFIdebug ((fname, " returning SUCCESS\n"));
    return (NFI_S_SUCCESS);
  }


long _NFFmap_load_delete_mcf (form, label, attr_row, data_list, value_list)
  Form      form;
  int       label;
  int       attr_row;
  MEMptr    data_list;
  MEMptr    value_list;
  {
    auto    int     status;
    auto    int     i, j;
    auto    int     mcf_row;
    auto    int     mcf_col;
    auto    int     data_fields;
    auto    int     value_fields;
    auto    int     value_row = 0;
    auto    char    **data_ptr;
    auto    char    **value_ptr;
    auto    short   found;
    static  char    *fname = "_NFFmap_load_delete_mcf";

    _NFIdebug ((fname, "label = <%d>\n", label));
    _NFIdebug ((fname, "attr_row = <%d>\n", attr_row));

    if (data_list->rows == 0)
      {
        _NFIdebug ((fname, "there are no rows to delete\n"));
        ERRload_struct (NFI, NFI_I_ALL_VALUES, NULL);
        _NFIdebug ((fname, "returning FAILURE <0x%.8x>\n", NFI_I_ALL_VALUES));
        return (NFI_I_ALL_VALUES);
      }

    data_ptr = (char **) data_list->data_ptr;
    value_ptr = (char **) value_list->data_ptr;
    data_fields = data_list->rows * data_list->columns;
    value_fields = value_list->rows * value_list->columns;

    mcf_row = 0;
    for (i = 0; i < data_fields; i += data_list->columns)
      {
        found = FALSE;
        for (j = 0; j < value_fields; j += value_list->columns)
          {
            /*  Check the index in the first column  */

            _NFIdebug ((fname, "comparing <%s> to <%s>\n",
                data_ptr[i + attr_row], value_ptr[j]));

            if ((strcmp (data_ptr[i + attr_row], value_ptr[j])) == 0)
              {
                value_row = j;
                found = TRUE;
                break;
              }
          }

        if (found == FALSE)
          {
            _NFIdebug ((fname, "data row does not exist in the value list\n"));
            ERRload_struct (NFI, NFI_E_BUFFER, NULL);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_BUFFER);
          }

/* IGI Intel Solaris Port -CN 31/5/95 */
#if defined(OS_SCO_UNIX) || defined(OS_INTELSOL) 
        /* work around change - to set font for SCO - SSRS 3 Feb 94 */
        FIg_set_font( form, label, "7x13bold", 15 );
#endif

        mcf_col = 0;
        for (j = value_row; j < value_row + value_list->columns; ++j)
          {
            /*  Set the bottom mcf to reflect the value_list  */

            _NFIdebug ((fname, "Setting <%s>\n", value_ptr[j]));
            _NFIdebug ((fname, "in row %d, col %d in BOTTOM_MCF\n",
                mcf_row, mcf_col));

            if ((status = FIfld_set_text (form, label,
                mcf_row, mcf_col, value_ptr[j], FALSE)) != FI_SUCCESS)
              {
                _NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
                ERRload_struct
                    (NFI, NFI_E_FORM, "%s%d", "FIfld_set_text", status);
                _NFIdebug ((fname, " returning FAILURE\n"));
                return (NFI_E_FORM);
              }

            ++mcf_col;
          }

        ++mcf_row;
      }

    _NFIdebug ((fname, " returning SUCCESS\n"));
    return (NFI_S_SUCCESS);
  }
