
/* machine.h included to take care of platform variencies MVR 23 Dec 1993 */
#include "machine.h"

#include "NFF.h"
#include "NFFmap.h"

/*  Global NFF structure  */

extern struct NFFglobal_st NFFglobal;

long _NFFacl_load_value_list (form, entity, attribute, filter_flag)
  Form      form;
  NFFmap    entity;
  char      *attribute;  /*  "n_classno" or "n_stateno"  */
  int       filter_flag;
  {
    auto    long    status;
    static  char    *fname = "_NFFacl_load_value_list";

    _NFIdebug ((fname, "filter_flag = <0x%.8x>\n", filter_flag));
    _NFIdebug ((fname, "attribute = <%s>\n", attribute));

    /*  Find the value_list for the users  */

    if ((status = _NFFfind_value_buffer (entity->attr_list,
        entity->value_list, "n_userno", "n_valueno")) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFfind_value_buffer = <0x%.8x>\n", status));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    /*  Create the mcf to reflect the value_list  */

    if ((status = _NFFacl_create_mcf (form, MAP_TOP_MCF)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFmap_create_mcf = <0x%.8x>\n", status));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    if ((status = _NFFacl_create_mcf (form, MAP_BOTTOM_MCF)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFacl_create_mcf = <0x%.8x>\n", status));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    /*  Center the mcfs on the form  */

    _NFFcenter_gadget (form, MAP_TOP_MCF);
    _NFFcenter_gadget (form, MAP_BOTTOM_MCF);

    /*  Load the value_list into the mcf  */

    if ((status = _NFFacl_load_mcf (form, filter_flag,
        (int) entity->active_data, attribute, entity->attr_list,
        entity->data_list, entity->value_list)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFacl_load_mcf = <0x%.8x>\n", status));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    _NFIdebug ((fname, " returning SUCCESS\n"));
    return (NFI_S_SUCCESS);
  }


long _NFFacl_create_mcf (form, label)
  Form  form;
  int   label;
  {
    auto    int       i, status;
    auto    int       num_cols;
    auto    int       num_rows;
    auto    int       num_chars;
    auto    int       vis_columns;
    auto    int       num_vis_cols;
    auto    int       attr_mask;
    auto    int       xpos, ypos;
    auto    int       justification;
    auto    struct    standard_st st_var;
    static  char      *fname = "_NFFacl_create_mcf";

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
#if defined  (OS_SCO_UNIX) || defined(OS_INTELSOL) /* IGI Intel Solaris port */  
    st_var.fontname = "7x13bold";                  /* CN - 31/5/95 */
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

    /*  Set the number of columns to 1  */

    num_cols = 1;
    vis_columns = 1;

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

    _NFIdebug ((fname, " returning SUCCESS\n"));
    return (NFI_S_SUCCESS);
  }


long _NFFacl_load_mcf
(form, filter_flag, value_row, attribute, attr_list, data_list, value_list)
  Form      form;
  int       filter_flag;
  int       value_row;
  char      *attribute;
  MEMptr    attr_list;
  MEMptr    data_list;
  MEMptr    value_list;
  {
    auto    int     status;
    auto    int     label1 = MAP_TOP_MCF;
    auto    int     label2 = MAP_BOTTOM_MCF;
    static  char    *fname = "_NFFacl_load_mcf";

    _NFIdebug ((fname, "filter_flag = <0x%.8x>\n", filter_flag));

    /*  Set the top mcf to reflect the attribute name  */

    _NFIdebug ((fname, "Setting <%s>\n", "Username"));
    _NFIdebug ((fname, "in row %d, col %d in TOP_MCF\n", 0, 0));

    /* IGI Intel Solaris Port -  CN 31/5/95       */
#if defined  (OS_SCO_UNIX) || defined(OS_INTELSOL)  
    /* work around change - to set font for SCO - SSRS 3 Feb 94 */
    FIg_set_font( form, label1, "7x13bold", 15 );
#endif
    if ((status = FIfld_set_text
        (form, label1, 0, 0, "Username", FALSE)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_text", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
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
        if ((status = _NFFacl_load_add_mcf (form, label2, value_row,
            attribute, attr_list, data_list, value_list)) != NFI_S_SUCCESS)
          {
            _NFIdebug ((fname, "_NFFacl_load_add_mcf = <0x%.8x>\n", status));
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (status);
          }
      }
    else
      {
        if ((status = _NFFacl_load_delete_mcf (form, label2, value_row,
            attribute, attr_list, data_list, value_list)) != NFI_S_SUCCESS)
          {
            _NFIdebug ((fname,
                "_NFFacl_load_delete_mcf = <0x%.8x>\n", status));
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (status);
          }
      }

    /*  Display the mcf  */

    _NFIdebug ((fname, "Displaying the TOP_MCF\n"));

    if ((status = FIg_display (form, label1)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIg_display = <%d>\n", status));
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_display", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    /*  Enable the scroll bar, if necessary  */

    _NFFenable_scrollbar (form, label2, FALSE);

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


long _NFFacl_load_add_mcf
(form, label, value_row, attribute, attr_list, data_list, value_list)
  Form      form;
  int       label;
  int       value_row;   /*  current class/state in value_list  */
  char      *attribute;  /*  "n_classno" or "n_stateno"         */
  MEMptr    attr_list;
  MEMptr    data_list;
  MEMptr    value_list;
  {
    auto    int     vis_chars;
    auto    int     attr_mask;
    auto    int     i, j, row;
    auto    int     total_data;
    auto    int     total_values;
    auto    long    status;
    auto    char    **data_ptr;
    auto    char    **value_ptr;
    auto    char    attribute_no[20];
    auto    short   data_userno;
    auto    short   value_userno;
    auto    short   data_attributeno;
    auto    short   value_attributeno;
    auto    short   username;
    auto    short   continue_flag;
    auto    short   enable_scrollbar = FALSE;
    static  char    *fname = "_NFFacl_load_add_mcf";

    _NFIdebug ((fname, "label = <%d>\n", label));
    _NFIdebug ((fname, "value_row = <%d>\n", value_row));
    _NFIdebug ((fname, "attribute = <%s>\n", attribute));

    /*  Find the column offsets in the data_list
        for the user number and the class/state number  */

    if ((status = _NFFfind_column_offset
        (data_list, "n_userno", &data_userno)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFfind_column_offset = <0x%.8x>\n", status));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    if ((status = _NFFfind_column_offset
        (data_list, attribute, &data_attributeno)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFfind_column_offset = <0x%.8x>\n", status));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    /*  Find the column offsets in the value_list
        for the user number and the class/state number  */

    if ((status = _NFFfind_value_buffer (attr_list,
        value_list, attribute, "n_valueno")) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFfind_value_buffer = <0x%.8x>\n", status));

        if ((strcmp (attribute, "n_classno")) == 0)
            status = NFI_E_NO_CLASS;
        else
            status = NFI_E_NO_SIGNOFF;

        ERRload_struct (NFI, status, NULL);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    if ((status = _NFFfind_column_offset
        (value_list, attribute, &value_attributeno)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFfind_column_offset = <0x%.8x>\n", status));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    data_ptr = (char **) value_list->data_ptr;
    strcpy (attribute_no,
        data_ptr[value_attributeno + (value_row * value_list->columns)]);
    _NFIdebug ((fname, "attribute_no = <%s>\n", attribute_no));

    if ((status = _NFFfind_value_buffer (attr_list,
        value_list, "n_userno", "n_valueno")) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFfind_value_buffer = <0x%.8x>\n", status));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    if ((status = _NFFfind_column_offset
        (value_list, "n_userno", &value_userno)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFfind_column_offset = <0x%.8x>\n", status));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    /*  Find the column offset in the value_list for the user name  */

    if ((status = _NFFfind_column_offset
        (value_list, "n_username", &username)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFfind_column_offset = <0x%.8x>\n", status));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    FIfld_get_num_vis_chars (form, label, 0, &vis_chars);

    total_data = data_list->rows * data_list->columns;
    total_values = value_list->rows * value_list->columns;
    data_ptr = (char **) data_list->data_ptr;
    value_ptr = (char **) value_list->data_ptr;

    for (i = 0, row = 0; i < total_values; i += value_list->columns)
      {
        /*  Filter out usernames that are
            already in the buffer for this class/state  */

        continue_flag = FALSE;
        for (j = 0; j < total_data; j += data_list->columns)
          {
            /*  Check for the class/state number first  */

            if ((strcmp (data_ptr[j + data_attributeno], attribute_no)) == 0)
              {
                /*  Check the user number  */

                if ((strcmp (data_ptr[j + data_userno],
                    value_ptr[i + value_userno])) == 0)
                  {
                    _NFIdebug ((fname,
                        "User <%s> is already mapped to this class/state\n",
                        value_ptr[i + username]));
                    continue_flag = TRUE;
                    break;
                  }
              }
          }

        if (continue_flag == TRUE) continue;

        /*  Set the bottom mcf to reflect the usernames  */

        _NFIdebug ((fname, "Setting <%s>\n", value_ptr[i + username]));
        _NFIdebug ((fname, "in row %d, col %d in BOTTOM_MCF\n", row, 0));


    /* IGI Intel Solaris Port - CN 31/5/95       */ 
#if defined  (OS_SCO_UNIX) || defined(OS_INTELSOL) 
        /* work around change - to set font for SCO - SSRS 3 Feb 94 */
        FIg_set_font( form, label, "7x13bold", 15 );
#endif
        if ((status = (long) FIfld_set_text (form, label,
            row, 0, value_ptr[i + username], FALSE)) != FI_SUCCESS)
          {
            _NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
            ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_text", status);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_FORM);
          }

        /*  See if the character scroll bars need to be enabled  */

        if (strlen (value_ptr[i + username]) > vis_chars)
            enable_scrollbar = TRUE;

        ++row;
      }

    FIfld_get_attr (form, label, 0, &attr_mask);

    if (enable_scrollbar == TRUE)
      {
        /*  OR in the character scroll bars attribute  */

        _NFIdebug ((fname, "enabling character scrolling\n"));
        attr_mask |= FI_HORT_SCROLL | FI_DISPLAY_HSCROLL;
      }
    else
      {
        /*  Take out the character scroll bars attribute  */

        _NFIdebug ((fname, "disabling character scrolling\n"));
        if (attr_mask & (FI_HORT_SCROLL | FI_DISPLAY_HSCROLL))
            attr_mask ^= FI_HORT_SCROLL | FI_DISPLAY_HSCROLL;
      }

    FIfld_set_attr (form, label, 0, attr_mask);

    _NFIdebug ((fname, " returning SUCCESS\n"));
    return (NFI_S_SUCCESS);
  }


long _NFFacl_load_delete_mcf
(form, label, value_row, attribute, attr_list, data_list, value_list)
  Form      form;
  int       label;
  int       value_row;   /*  current class/state in value_list  */
  char      *attribute;  /*  "n_classno" or "n_stateno"         */
  MEMptr    attr_list;
  MEMptr    data_list;
  MEMptr    value_list;
  {
    auto    int     vis_chars;
    auto    int     attr_mask;
    auto    int     i, j, row;
    auto    int     total_data;
    auto    int     total_values;
    auto    int     buffer_row;
    auto    long    status;
    auto    char    **data_ptr;
    auto    char    **value_ptr;
    auto    char    *current_no;
    auto    short   data_attribute;
    auto    short   value_attribute;
    auto    short   data_userno;
    auto    short   value_userno;
    auto    short   value_username;
    auto    short   enable_scrollbar = FALSE;
    static  char    *fname = "_NFFacl_load_delete_mcf";

    _NFIdebug ((fname, "label = <%d>\n", label));
    _NFIdebug ((fname, "value_row = <0x%.8x>\n", value_row));
    _NFIdebug ((fname, "attribute = <%s>\n", attribute));

    /*  Find the value_list for the current class/state  */

    if ((status = _NFFfind_value_buffer
        (attr_list, value_list, attribute, "n_valueno")) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFfind_value_buffer = <0x%.8x>\n", status));

        if ((strcmp (attribute, "n_classno")) == 0)
            status = NFI_E_NO_CLASS;
        else
            status = NFI_E_NO_SIGNOFF;

        ERRload_struct (NFI, status, NULL);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    /*  Get the offsets for this class/state
        in the value_list and in the data_list  */

    if ((status = _NFFfind_column_offset
        (value_list, attribute, &value_attribute)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFfind_column_offset = <0x%.8x>\n", status));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    if ((status = _NFFfind_column_offset
        (data_list, attribute, &data_attribute)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFfind_column_offset = <0x%.8x>\n", status));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    data_ptr = (char **) value_list->data_ptr;

    /*  Pull out the current class/state number  */

    current_no = data_ptr[value_attribute + (value_row * value_list->columns)];

    /*  Find the value_list for the user number/name  */

    if ((status = _NFFfind_value_buffer
        (attr_list, value_list, "n_userno", "n_valueno")) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFfind_value_buffer = <0x%.8x>\n", status));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    /*  Get the offsets in the data_list and value_list  */

    if ((status = _NFFfind_column_offset
        (value_list, "n_userno", &value_userno)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFfind_column_offset = <0x%.8x>\n", status));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    if ((status = _NFFfind_column_offset
        (data_list, "n_userno", &data_userno)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFfind_column_offset = <0x%.8x>\n", status));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    if ((status = _NFFfind_column_offset
        (value_list, "n_username", &value_username)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFfind_column_offset = <0x%.8x>\n", status));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    FIfld_get_num_vis_chars (form, label, 0, &vis_chars);

    total_data = data_list->rows * data_list->columns;
    total_values = value_list->rows * value_list->columns;
    data_ptr = (char **) data_list->data_ptr;
    value_ptr = (char **) value_list->data_ptr;

    for (i = 0, row = 0; i < total_data; i += data_list->columns)
      {
        /*  Check the class/state number in the data_list  */

        if ((strcmp (data_ptr[i + data_attribute], current_no)) != 0) continue;

        /*  Find the user number in the value_list  */

        buffer_row = -1;
        for (j = 0; j < total_values; j += value_list->columns)
          {
            if ((strcmp (data_ptr[i + data_userno],
                value_ptr[j + value_userno])) == 0)
              {
                /*  Save the username offset  */

                _NFIdebug ((fname, "buffer_row = <0x%.8x>\n", j));
                buffer_row = j;
                break;
              }
          }

        if (buffer_row == -1)
          {
            _NFIdebug ((fname,
                "user number was not found in the value_list\n"));
            ERRload_struct (NFI, NFI_E_BUFFER, NULL);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_BUFFER);
          }

        /*  Set the bottom mcf to reflect the usernames  */

        _NFIdebug ((fname, "Setting <%s>\n",
            value_ptr[buffer_row + value_username]));
        _NFIdebug ((fname, "in row %d, col %d in MAP_BOTTOM_MCF\n", row, 0));

    /* IGI Intel Solaris Port - CN 31/5/95       */ 
#if defined  (OS_SCO_UNIX) || defined(OS_INTELSOL) 
        /* work around change - to set font for SCO - SSRS 3 Feb 94 */
        FIg_set_font( form, label, "7x13bold", 15 );
#endif
        if ((status = (long) FIfld_set_text (form, label, row, 0,
            value_ptr[buffer_row + value_username], FALSE)) != FI_SUCCESS)
          {
            _NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
            ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_text", status);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_FORM);
          }

        /*  See if the character scroll bars need to be enabled  */

        if (strlen (value_ptr[buffer_row + value_username]) > vis_chars)
            enable_scrollbar = TRUE;

        ++row;
      }

    FIfld_get_attr (form, label, 0, &attr_mask);

    if (enable_scrollbar == TRUE)
      {
        /*  OR in the character scroll bars attribute  */

        _NFIdebug ((fname, "enabling character scrolling\n"));
        attr_mask |= FI_HORT_SCROLL | FI_DISPLAY_HSCROLL;
      }
    else
      {
        /*  Take out the character scroll bars attribute  */

        _NFIdebug ((fname, "disabling character scrolling\n"));
        if (attr_mask & (FI_HORT_SCROLL | FI_DISPLAY_HSCROLL))
            attr_mask ^= FI_HORT_SCROLL | FI_DISPLAY_HSCROLL;
      }

    FIfld_set_attr (form, label, 0, attr_mask);

    _NFIdebug ((fname, " returning SUCCESS\n"));
    return (NFI_S_SUCCESS);
  }
