
/* machine.h included to take care of platform variencies MVR 23 Dec 1993 */
#include "machine.h"

#include "NFF.h"
#include "NFFadd.h"

/*  Global NFF structure  */

extern struct NFFglobal_st NFFglobal;

long _NFFadd_create_mcf (form, label, value_list)
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
    static  char    *fname = "_NFFadd_create_mcf";

    _NFIdebug ((fname, "label = <%d>\n", label));

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

    _NFIdebug ((fname, "Getting the location of the hidden mcf\n"));

    if ((status = FIg_get_location
        (form, label - 100, &xpos, &ypos)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIg_get_location = <%d>\n", status));
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_get_location", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    _NFIdebug ((fname, "xpos, ypos = (%d, %d)\n", xpos, ypos));

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
    /* IGI Intel Solaris Port - CN 31/5/95       */ 
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

    /*  Parker said to erase the damn thing  */

    _NFIdebug ((fname, "Erasing the MCF\n"));

    if ((status = FIg_erase (form, label)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIg_erase = <%d>\n", status));
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_erase", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    /*  Get the number of visible columns from the hidden mcf  */

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

    _NFIdebug ((fname, "num_vis_cols = %d\n", num_vis_cols));

    /*  Find out how many columns to set  */

    num_cols = 0;
    vis_columns = 0;
    _NFIdebug ((fname, "value_list->columns value %d\n", value_list->columns));
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

    if ((status = FIfld_get_num_vis_rows
        (form, label - 100, &num_rows)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIfld_get_num_vis_rows = <%d>\n", status));
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_get_num_rows", status);
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

    if ((status = FIfld_get_num_vis_chars
        (form, label - 100, 0, &num_chars)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIfld_get_num_vis_chars = <%d>\n", status));
        ERRload_struct
            (NFI, NFI_E_FORM, "%s%d", "FIfld_get_num_vis_chars", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

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


long _NFFadd_load_mcf (form, label, value_list)
  Form      form;
  int       label;
  MEMptr    value_list;
  {
    auto    int     status;
    auto    int     i, j, k;
    auto    int     num_rows, vis_rows, attr_mask;
    auto    char    **data_ptr;
    static  char    *fname = "_NFFadd_load_mcf";

    _NFIdebug ((fname, "label = <%d>\n", label));

    data_ptr = (char **) value_list->data_ptr;

    /*  Set the number of rows to 0 to clear out the field  */

    _NFIdebug ((fname, "Setting number of rows to 0\n"));

    if ((status = FIfld_set_num_rows (form, label, 0)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIfld_set_num_rows = <%d>\n", status));
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_num_rows", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    /*  Put the values in the mcf  */
    /* IGI Intel Solaris Port - CN 31/5/95       */ 
#if defined(OS_SCO_UNIX) || defined(OS_INTELSOL) 
    /* work around change - to set font for SCO - SSRS 7 Feb 94 */
    FIg_set_font( form, label, "7x13bold", 15 );
#endif

    for (i = 0, k = 0; i < value_list->rows; ++i)
      {
        for (j = 0; j < value_list->columns; ++j)
          {
            _NFIdebug ((fname, "Setting <%s>\n", data_ptr[k]));
            _NFIdebug ((fname, " in row %d, col %d in the mcf\n", i, j));

            if ((status = FIfld_set_text
                (form, label, i, j, data_ptr[k], FALSE)) != FI_SUCCESS)
              {
                _NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
                ERRload_struct
                    (NFI, NFI_E_FORM, "%s%d", "FIfld_set_text", status);
                _NFIdebug ((fname, " returning FAILURE\n"));
                return (NFI_E_FORM);
              }

            ++k;
          }
      }

    /*  Enable the scroll bar, if necessary  */

    FIfld_get_num_rows (form, label, &num_rows);
    FIfld_get_num_vis_rows (form, label, &vis_rows);
    FImcf_get_attr (form, label, &attr_mask);
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

    FImcf_set_attr (form, label, attr_mask);

    /*  Display the mcf  */

    _NFIdebug ((fname, "Displaying the mcf\n"));
/*
    if ((status = FIg_display (form, label)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIg_display = <%d>\n", status));
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_display", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }
*/
    _NFIdebug ((fname, " returning SUCCESS\n"));
    return (NFI_S_SUCCESS);
  }
