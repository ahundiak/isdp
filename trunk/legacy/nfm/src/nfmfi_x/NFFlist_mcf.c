
/* machine.h included to take care of platform variencies MVR 23 Dec 1993 */
#include "machine.h"

#include "NFF.h"

/*  Global NFF structure  */

extern struct NFFglobal_st NFFglobal;

#define VISIBLE_ROWS       11
#define REV_VIS_ROWS       10

#define TOP_XPOS            9
#define TOP_YPOS           65
#define BOTTOM_XPOS         9
#define BOTTOM_YPOS        86

#define REV_TOP_XPOS        9
#define REV_TOP_YPOS       85
#define REV_BOTTOM_XPOS     9
#define REV_BOTTOM_YPOS   106

long _NFFlist_load_mcf (form, mode, syn_list, data_list)
  Form      form;
  int       mode;
  MEMptr    syn_list;
  MEMptr    data_list;
  {
    auto    long    status;
    static  char    *fname = "_NFFlist_load_mcf";

    if ((status = MEMbuild_array (syn_list)) != MEM_S_SUCCESS)
      {
        _NFIdebug ((fname, "MEMbuild_array = <0x%.8x>\n", status));
        ERRload_struct (NFI, NFI_E_MEM, "%s%x", "MEMbuild_array", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_MEM);
      }

    if ((status = MEMbuild_array (data_list)) != MEM_S_SUCCESS)
      {
        _NFIdebug ((fname, "MEMbuild_array = <0x%.8x>\n", status));
        ERRload_struct (NFI, NFI_E_MEM, "%s%x", "MEMbuild_array", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_MEM);
      }

    /*  Delete the old mcfs  */
    FIg_delete (form, TOP_MCF); 
    FIg_delete (form, BOTTOM_MCF);

    if ((status = _NFFlist_create_mcf
        (form, TOP_MCF, FI_MULTI_SELECT, data_list)) != NFI_S_SUCCESS) 
      {
        _NFIdebug ((fname, "_NFFlist_create_mcf = <0x%.8x>\n", status));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    if ((status = _NFFlist_create_mcf
        (form, BOTTOM_MCF, mode, data_list)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFlist_create_mcf = <0x%.8x>\n", status));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    /*  Load the attr_list and data_list into the mcfs  */

    if ((status = _NFFlist_load_mcf_data
        (form, 0, syn_list, data_list)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFlist_load_mcf_data = <0x%.8x>\n", status));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    /*  Display the mcfs  */

    _NFIdebug ((fname, "Displaying the mcfs\n"));

    if ((status = FIg_display (form, TOP_MCF)) != FI_SUCCESS) 
      {
        _NFIdebug ((fname, "FIg_display = <%d>\n", status));
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_display", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    if ((status = FIg_display (form, BOTTOM_MCF)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIg_display = <%d>\n", status));
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_display", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }
    _NFIdebug ((fname, " returning SUCCESS\n"));
    return (NFI_S_SUCCESS);
  }


long _NFFreview_load_mcf (form, syn_list, data_list)
  Form      form;
  MEMptr    syn_list;
  MEMptr    data_list;
  {
    auto    long    status;
    static  char    *fname = "_NFFreview_load_mcf";

    if ((status = MEMbuild_array (syn_list)) != MEM_S_SUCCESS)
      {
        _NFIdebug ((fname, "MEMbuild_array = <0x%.8x>\n", status));
        ERRload_struct (NFI, NFI_E_MEM, "%s%x", "MEMbuild_array", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_MEM);
      }

    if ((status = MEMbuild_array (data_list)) != MEM_S_SUCCESS)
      {
        _NFIdebug ((fname, "MEMbuild_array = <0x%.8x>\n", status));
        ERRload_struct (NFI, NFI_E_MEM, "%s%x", "MEMbuild_array", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_MEM);
      }

    /*  Delete the old mcfs  */

/* added debug statements - PS Intel/Solaris Port */
    if ( (status = FIg_delete (form, TOP_MCF)) != FI_SUCCESS)
        _NFIdebug ((fname, "FIg_delete TOP_MCF = <0x%.8x>\n", status));

    if ( (status = FIg_delete (form, BOTTOM_MCF)) != FI_SUCCESS)
        _NFIdebug ((fname, "FIg_delete BOTTOM_MCF = <0x%.8x>\n", status));

    if ((status = _NFFreview_create_mcf
        (form, TOP_MCF, data_list)) != NFI_S_SUCCESS) 
      {
        _NFIdebug ((fname, "_NFFreview_create_mcf = <0x%.8x>\n", status));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    if ((status = _NFFreview_create_mcf
        (form, BOTTOM_MCF, data_list)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFreview_create_mcf = <0x%.8x>\n", status));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    /*  Load the attr_list and data_list into the mcfs  */

    if ((status = _NFFreview_load_mcf_data
        (form, syn_list, data_list)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFreview_load_mcf_data = <0x%.8x>\n", status));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    /*  Display the mcfs  */

    _NFIdebug ((fname, "Displaying the mcfs\n"));

    if ((status = FIg_display (form, TOP_MCF)) != FI_SUCCESS) 
      {
        _NFIdebug ((fname, "FIg_display = <%d>\n", status));
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_display", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    if ((status = FIg_display (form, BOTTOM_MCF)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIg_display = <%d>\n", status));
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_display", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    _NFIdebug ((fname, " returning SUCCESS\n"));
    return (NFI_S_SUCCESS);
  }


long _NFFlist_create_mcf (form, label, mode, data_list)
  Form      form;
  int       label;
  int       mode;
  MEMptr    data_list;
  {
    auto    int    col, status;
    auto    int    num_chars, vis_rows, num_rows;
    auto    int    attr_mask = FI_DEFAULT;
    auto    int    xpos, ypos;
    auto    int    justification = FI_CENTER_JUSTIFIED;
    auto    char   **format;
    auto    struct standard_st st_var;
    static  char   *fname = "_NFFlist_create_mcf";

    _NFIdebug ((fname, "label = <%d>\n", label));
    _NFIdebug ((fname, "mode = <%d>\n", mode));

    switch (label)
      {
        case TOP_MCF:
            xpos = TOP_XPOS;
            ypos = TOP_YPOS;
            num_rows = 2;
            vis_rows = 1;
            break;

        case BOTTOM_MCF:
            xpos = BOTTOM_XPOS;
            ypos = BOTTOM_YPOS;
            num_rows = data_list->rows;
            vis_rows = VISIBLE_ROWS;
            break;

        default:
            _NFIdebug ((fname, "unrecognized label <%d>\n", label));
            ERRload_struct (NFI, NFI_E_INVALID_INPUT, NULL);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_INVALID_INPUT);
      }

    _NFIdebug ((fname, "xpos, ypos = %d, %d\n", xpos, ypos));
 
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
    st_var.value = 0.0;
    st_var.bodysize = 15.0; 
    st_var.text = NULL;
    st_var.help_topic = NULL;
    st_var.command = NULL;
    /* fonts SSRS 28 Jan 94 */
/* Intel Solaris Port - CN 31/5/95 */
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

    if ((status = FIg_set_attr (form, label, FI_NOT_DISPLAYED)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIg_set_attr = <%d>\n", status));
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_set_attr", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    /*  Set the number of columns  */

    _NFIdebug ((fname,
        "Setting number of columns to %d\n", data_list->columns));

    if ((status = FImcf_set_num_cols
        (form, label, data_list->columns)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FImcf_set_num_cols = <%d>\n", status));
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FImcf_set_num_cols", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    /*  Set the number of rows  */

    _NFIdebug ((fname, "Setting the number of rows to <%d>\n", num_rows));

    if ((status = FIfld_set_num_rows (form, label, num_rows)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIfld_set_num_rows = <%d>\n", status));
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_num_rows", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    /*  Set the number of visible rows  */

    _NFIdebug ((fname, "Setting number of visible rows to %d\n", vis_rows));
    if ((status = FIfld_set_num_vis_rows
        (form, label, vis_rows)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIfld_set_num_vis_rows = <%d>\n", status));
        ERRload_struct
            (NFI, NFI_E_FORM, "%s%d", "FIfld_set_num_vis_rows", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    switch (label)
      {
        case TOP_MCF:
            justification = FI_CENTER_JUSTIFIED;
            break;

        case BOTTOM_MCF:
            justification = FI_LEFT_JUSTIFIED;
            break;
      }

    /*  Get the number of visible characters from the hidden MCF  */

    /* Retrun status checking added by SSRS - 24/11/93 */
    if(FIfld_get_num_vis_chars (form, label + 100, 0, &num_chars) != FI_SUCCESS)    {
            _NFIdebug ((fname, "FIfld_get_num_vis_chars = <%d>\n", status));
            ERRload_struct
                (NFI, NFI_E_FORM, "%s%d", "FIfld_get_num_vis_chars", status);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_FORM);
    }

    format = (char **) data_list->format_ptr;
    for (col = 0; col < data_list->columns; ++col)
      {
        /*  Set the number of visible characters  */
/*
        if ((status = (long) _NFFvalidate_datatype
            (format[col], &num_chars)) != NFI_S_SUCCESS)
          {
            _NFIdebug ((fname, "_NFFvalidate_datatype = <%d>\n", status));
            _NFIdebug ((fname, " returning FAILURE\n"));
            return ((long) status);
          }
*/
        _NFIdebug ((fname, "%d: Setting number of visible characters to %d\n",
            col, num_chars));

        if ((status = FIfld_set_num_vis_chars
            (form, label, col, num_chars)) != FI_SUCCESS)
          {
            _NFIdebug ((fname, "FIfld_set_num_vis_chars = <%d>\n", status));
            ERRload_struct
                (NFI, NFI_E_FORM, "%s%d", "FIfld_set_num_vis_chars", status);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_FORM);
          }

        /*  Set the mode for the columns  */

        _NFIdebug ((fname, "%d: Setting the mode\n", col));

        if ((status = FIfld_set_mode (form, label, col, mode)) != FI_SUCCESS)
          {
            _NFIdebug ((fname, "FIfld_set_mode = <%d>\n", status));
            ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_mode", status);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_FORM);
          }

        /*  Set the justification for the columns  */

        _NFIdebug ((fname, "%d: Setting the justification\n", col));

        if ((status = FImcf_set_justification
            (form, label, col, justification)) != FI_SUCCESS)
          {
            _NFIdebug ((fname, "FImcf_set_justification = <%d>\n", status));
            ERRload_struct
                (NFI, NFI_E_FORM, "%s%d", "FImcf_set_justification", status);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_FORM);
          }

        /*  Set the type for the columns  */

        _NFIdebug ((fname, "%d: Setting the type to FI_ALPHA\n", col));

        if ((status = FIfld_set_type
            (form, label, col, FI_ALPHA)) != FI_SUCCESS)
          {
            _NFIdebug ((fname, "FIfld_set_type = <%d>\n", status));
            ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_type", status);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_FORM);
          }

        switch (label)
          {
            case TOP_MCF:

                /*  No field attributes for the top mcfs  */

                attr_mask = FI_DEFAULT;
                break;

            case BOTTOM_MCF:

                /*  Disable everything but NOTIFY_BY_LINE,
                    HORT_SCROLL, DISPLAY_HSCROLL and VERT_SCROLL  */

                attr_mask = FI_NOTIFY_BY_LINE | FI_VERT_SCROLL;
                attr_mask |= FI_HORT_SCROLL | FI_DISPLAY_HSCROLL;
                break;
          }

        _NFIdebug ((fname, "%d: Setting field attributes\n", col));

        if ((status = FIfld_set_attr
            (form, label, col, attr_mask)) != FI_SUCCESS)
          {
            _NFIdebug ((fname, "FIfld_set_attr = <%d>\n", status));
            ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_attr", status);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_FORM);
          }
      }

    switch (label)
      {
        case TOP_MCF:

            /*  Don't show the scroll bars or row select buttons  */

            attr_mask = FI_HORT_SCROLL | FI_NO_ROW_BUTTONS;
            break;

        case BOTTOM_MCF:

            attr_mask = FI_VERT_SCROLL | FI_HORT_SCROLL;
            attr_mask |= FI_DISPLAY_HSCROLL | FI_DISPLAY_VSCROLL;
            attr_mask |= FI_ROW_SELECT | FI_NO_ROW_BUTTONS;
            break;
      }

    _NFIdebug ((fname, "Setting mcf attributes\n"));

    if ((status = FImcf_set_attr (form, label, attr_mask)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FImcf_set_attr = <%d>\n", status));
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FImcf_set_attr", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    /*  Set the number of visible columns  */

    switch (label)
      {
        case TOP_MCF:

            _NFIdebug ((fname,
                "Setting number of visible columns to %d\n", 2));

            if ((status = FImcf_set_num_vis_cols
                (form, label, 2)) != FI_SUCCESS)
              {
                _NFIdebug ((fname, "FImcf_set_num_vis_cols = <%d>\n", status));
                ERRload_struct (NFI,
                    NFI_E_FORM, "%s%d", "FImcf_set_num_vis_cols", status);
                _NFIdebug ((fname, " returning FAILURE\n"));
                return (NFI_E_FORM);
              }

            break;

        case BOTTOM_MCF:

            _NFIdebug ((fname,
                "Setting number of visible columns to %d\n", 2));

            if ((status = FImcf_set_num_vis_cols
                (form, label, 2)) != FI_SUCCESS)
              {
                _NFIdebug ((fname, "FImcf_set_num_vis_cols = <%d>\n", status));
                ERRload_struct (NFI,
                    NFI_E_FORM, "%s%d", "FImcf_set_num_vis_cols", status);
                _NFIdebug ((fname, " returning FAILURE\n"));
                return (NFI_E_FORM);
              }

            /*  Link the scrolling of the bottom one to the top  */
            _NFIdebug ((fname, "Linking the scrolling to the top mcf\n"));

            if ((status = FImcf_set_scroll_link
                (form, label, TOP_MCF)) != FI_SUCCESS) 
              {
                _NFIdebug ((fname, "FImcf_set_scroll_link = <%d>\n", status));
                ERRload_struct
                    (NFI, NFI_E_FORM, "%s%d", "FImcf_set_scroll_link", status);
                _NFIdebug ((fname, " returning FAILURE\n"));
                return (NFI_E_FORM);
              }
            break;
      }

    /*  Activate the gadget  */

    _NFIdebug ((fname, "Activating the mcf\n"));
    /* This call is resulting in abnormal termination in Displaying items,
       Display set members, Display project members on SUN/SOLARIS. On SCO
       it is working fine. We could not trace out the problem. So we are 
       commenting this call for SUN/SOLARIS.  On commenting, the commands 
       are working fine. This is a work around change until we find a solution 
       for this.
       SSRS 10 Feb 94
    */
#if !defined(OS_SUNOS) && (!defined(OS_SOLARIS ) ||defined(OS_INTELSOL)) 
    if ((status = FIg_activate (form, label  )) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIg_activate = <%d>\n", status));
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_activate", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }
#endif
    _NFIdebug ((fname, " returning SUCCESS\n"));
    return (NFI_S_SUCCESS);
  }


long _NFFreview_create_mcf (form, label, data_list)
  Form      form;
  int       label;
  MEMptr    data_list;
  {
    auto    int    col, status;
    auto    int    num_chars, vis_rows, num_rows;
    auto    int    attr_mask = FI_DEFAULT;
    auto    int    xpos, ypos, mode = FI_REVIEW;
    auto    int    justification = FI_CENTER_JUSTIFIED;
    auto    char   **format;
    auto    struct standard_st st_var;
    static  char   *fname = "_NFFreview_create_mcf";

    _NFIdebug ((fname, "label = <%d>\n", label));

    switch (label)
      {
        case TOP_MCF:
            xpos = REV_TOP_XPOS;
            ypos = REV_TOP_YPOS;
            num_rows = 1;
            vis_rows = 1;
            break;

        case BOTTOM_MCF:
            xpos = REV_BOTTOM_XPOS;
            ypos = REV_BOTTOM_YPOS;
            num_rows = data_list->columns;
            vis_rows = REV_VIS_ROWS;
            break;

        default:
            _NFIdebug ((fname, "unrecognized label <%d>\n", label));
            ERRload_struct (NFI, NFI_E_INVALID_INPUT, NULL);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_INVALID_INPUT);
      }

    _NFIdebug ((fname, "xpos, ypos = %d, %d\n", xpos, ypos));

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
    st_var.value = 0.0;
    st_var.bodysize = 15.0; 
    st_var.text = NULL;
    st_var.help_topic = NULL;
    st_var.command = NULL;
    /* fonts SSRS 28 Jan 94 */
/* Intel Solaris Port -CN 31/5/95 */
#if defined(OS_SCO_UNIX) || defined (OS_INTELSOL) 
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

    if ((status = FIg_set_attr (form, label, FI_NOT_DISPLAYED)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIg_set_attr = <%d>\n", status));
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_set_attr", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }
    /*  Set the number of columns  */

    _NFIdebug ((fname,
        "Setting number of columns to %d\n", data_list->rows + 1));

    if ((status = FImcf_set_num_cols
        (form, label, data_list->rows + 1)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FImcf_set_num_cols = <%d>\n", status));
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FImcf_set_num_cols", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    /*  Set the number of rows  */

    _NFIdebug ((fname, "Setting the number of rows to <%d>\n", num_rows));

    if ((status = FIfld_set_num_rows (form, label, num_rows)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIfld_set_num_rows = <%d>\n", status));
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_num_rows", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    /*  Set the number of visible rows  */

    _NFIdebug ((fname, "Setting number of visible rows to %d\n", vis_rows));

    if ((status = FIfld_set_num_vis_rows
        (form, label, vis_rows)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIfld_set_num_vis_rows = <%d>\n", status));
        ERRload_struct
            (NFI, NFI_E_FORM, "%s%d", "FIfld_set_num_vis_rows", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    switch (label)
      {
        case TOP_MCF:
            justification = FI_CENTER_JUSTIFIED;
            mode = FI_MULTI_SELECT;
            break;

        case BOTTOM_MCF:
            justification = FI_LEFT_JUSTIFIED;
            mode = FI_REVIEW;
            break;
      }

    format = (char **) data_list->format_ptr;
    for (col = 0; col < data_list->rows + 1; ++col)
      {
        /*  Set the number of visible characters
            (force all columns to have a minimum of 24 characters)  */

        num_chars = 24;

        _NFIdebug ((fname, "%d: Setting number of visible characters to %d\n",
            col, num_chars));

        if ((status = FIfld_set_num_vis_chars
            (form, label, col, num_chars)) != FI_SUCCESS)
          {
            _NFIdebug ((fname, "FIfld_set_num_vis_chars = <%d>\n", status));
            ERRload_struct
                (NFI, NFI_E_FORM, "%s%d", "FIfld_set_num_vis_chars", status);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_FORM);
          }

        /*  Set the mode for the columns  */

        _NFIdebug ((fname, "%d: Setting the mode\n", col));

        if ((status = FIfld_set_mode
            (form, label, col, mode)) != FI_SUCCESS)
          {
            _NFIdebug ((fname, "FIfld_set_mode = <%d>\n", status));
            ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_mode", status);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_FORM);
          }

        /*  Set the justification for the columns  */

        _NFIdebug ((fname, "%d: Setting the justification\n", col));

        if ((status = FImcf_set_justification
            (form, label, col, justification)) != FI_SUCCESS)
          {
            _NFIdebug ((fname, "FImcf_set_justification = <%d>\n", status));
            ERRload_struct
                (NFI, NFI_E_FORM, "%s%d", "FImcf_set_justification", status);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_FORM);
          }

        /*  Set the type for the columns  */

        _NFIdebug ((fname, "%d: Setting the type to FI_ALPHA\n", col));

        if ((status = FIfld_set_type
            (form, label, col, FI_ALPHA)) != FI_SUCCESS)
          {
            _NFIdebug ((fname, "FIfld_set_type = <%d>\n", status));
            ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_type", status);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_FORM);
          }

        switch (label)
          {
            case TOP_MCF:

                /*  No field attributes for the top mcfs  */

                attr_mask = FI_DEFAULT;
                break;

            case BOTTOM_MCF:

                /*  Disable everything but NOTIFY_BY_LINE,
                    HORT_SCROLL, DISPLAY_HSCROLL and VERT_SCROLL  */

                attr_mask = FI_NOTIFY_BY_LINE | FI_VERT_SCROLL;
                attr_mask |= FI_HORT_SCROLL | FI_DISPLAY_HSCROLL;
                break;
          }

        _NFIdebug ((fname, "%d: Setting field attributes\n", col));

        if ((status = FIfld_set_attr
            (form, label, col, attr_mask)) != FI_SUCCESS)
          {
            _NFIdebug ((fname, "FIfld_set_attr = <%d>\n", status));
            ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_attr", status);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_FORM);
          }
      }

    switch (label)
      {
        case TOP_MCF:

            /*  Don't show the scroll bars or row select buttons  */

            attr_mask = FI_HORT_SCROLL | FI_NO_ROW_BUTTONS;
            break;

        case BOTTOM_MCF:

            attr_mask = FI_VERT_SCROLL | FI_HORT_SCROLL;
            attr_mask |= FI_DISPLAY_HSCROLL | FI_DISPLAY_VSCROLL;
            attr_mask |= FI_ROW_SELECT | FI_NO_ROW_BUTTONS;
            break;
      }

    _NFIdebug ((fname, "Setting mcf attributes\n"));

    if ((status = FImcf_set_attr (form, label, attr_mask)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FImcf_set_attr = <%d>\n", status));
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FImcf_set_attr", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    /*  Set the number of visible columns  */

    switch (label)
      {
        case TOP_MCF:

            _NFIdebug ((fname,
                "Setting number of visible columns to %d\n", 2));

            if ((status = FImcf_set_num_vis_cols
                (form, label, 2)) != FI_SUCCESS)
              {
                _NFIdebug ((fname, "FImcf_set_num_vis_cols = <%d>\n", status));
                ERRload_struct (NFI,
                    NFI_E_FORM, "%s%d", "FImcf_set_num_vis_cols", status);
                _NFIdebug ((fname, " returning FAILURE\n"));
                return (NFI_E_FORM);
              }

            break;

        case BOTTOM_MCF:

            _NFIdebug ((fname,
                "Setting number of visible columns to %d\n", 2));

            if ((status = FImcf_set_num_vis_cols
                (form, label, 2)) != FI_SUCCESS)
              {
                _NFIdebug ((fname, "FImcf_set_num_vis_cols = <%d>\n", status));
                ERRload_struct (NFI,
                    NFI_E_FORM, "%s%d", "FImcf_set_num_vis_cols", status);
                _NFIdebug ((fname, " returning FAILURE\n"));
                return (NFI_E_FORM);
              }

            /*  Link the scrolling of the bottom one to the top  */

            _NFIdebug ((fname, "Linking the scrolling to the top mcf\n"));

            if ((status = FImcf_set_scroll_link
                (form, label, TOP_MCF)) != FI_SUCCESS) 
              {
                _NFIdebug ((fname, "FImcf_set_scroll_link = <%d>\n", status));
                ERRload_struct
                    (NFI, NFI_E_FORM, "%s%d", "FImcf_set_scroll_link", status);
                _NFIdebug ((fname, " returning FAILURE\n"));
                return (NFI_E_FORM);
              }

            break;
      }

    /*  Activate the gadget  */

    _NFIdebug ((fname, "Activating the mcf\n"));

    /* This call is resulting in abnormal termination in Review Item Attributes,
       on SUN/SOLARIS. On SCO it is working fine. We could not trace out the 
       problem. So we are commenting this call for SUN/SOLARIS.  On commenting, 
       the command is working fine. This is a work around change until we find 
       a solution for this.
       SSRS 10 Feb 94
    */
#if !defined(OS_SUNOS) && (!defined(OS_SOLARIS ) ||defined(OS_INTELSOL)) 
    if ((status = FIg_activate (form, label )) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIg_activate = <%d>\n", status));
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_activate", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }
#endif

    _NFIdebug ((fname, " returning SUCCESS\n"));
    return (NFI_S_SUCCESS);
  }


long _NFFlist_load_mcf_data (form, start_row, syn_list, data_list)
  Form      form;
  int       start_row;
  MEMptr    syn_list;
  MEMptr    data_list;
  {
    auto    int     fields;
    auto    int     num_rows;
    auto    int     num_cols;
    auto    int     start_col;
    auto    int     row, col;
    auto    int     offset;
    auto    int     status;
    auto    char    **col_ptr;
    auto    char    **syn_ptr;
    auto    char    **data_ptr;
    static  char    *fname = "_NFFlist_load_mcf_data";

    _NFIdebug ((fname, "start_row = <%d>\n", start_row));
    /*  Don't load synonyms if we're appending to the mcf  */
    if (start_row == 0)
      {
        col_ptr = (char **) data_list->column_ptr;
        syn_ptr = (char **) syn_list->data_ptr;

/*  Set the top mcf to reflect the synonym  */
	/* IGI IntelSolaris Port ,CN 31/5/95 */
#if defined(OS_SCO_UNIX)|| defined(OS_INTELSOL)  
	/* work around change - to set font for SCO -  SSRS 1 Feb 94 */
	FIg_set_font( form, TOP_MCF, "7x13bold", 15);
#endif

        for (col = 0; col < syn_list->rows; ++col)
          {
            /*  Check for a synonym  */

            if ((strcmp (syn_ptr[col], "")) == 0)
              {
                /*  Use the attribute name instead  */

                _NFIdebug ((fname, "Setting attribute <%s> in row %d, col %d\n",
                    col_ptr[col], 0, col));


                if ((status = FIfld_set_text (form, TOP_MCF,
                    0, col, col_ptr[col], FALSE)) != FI_SUCCESS) 
                  {
                    _NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
                    ERRload_struct
                        (NFI, NFI_E_FORM, "%s%d", "FIfld_set_text", status);
                    _NFIdebug ((fname, " returning FAILURE\n"));
                    return (NFI_E_FORM);
                  }
              }
            else
              {
                _NFIdebug ((fname, "Setting synonym <%s> in row %d, col %d\n",
                    syn_ptr[col], 0, col));

                if ((status = FIfld_set_text (form, TOP_MCF,
                    0, col, syn_ptr[col], FALSE)) != FI_SUCCESS) 
                  {
                    _NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
                    ERRload_struct
                        (NFI, NFI_E_FORM, "%s%d", "FIfld_set_text", status);
                    _NFIdebug ((fname, " returning FAILURE\n"));
                    return (NFI_E_FORM);
                  }
              }

            /*  Put the attribute names in the second row  */

            _NFIdebug ((fname, "Setting <%s> in row %d, col %d\n",
                col_ptr[col], 1, col));

            if ((status = FIfld_set_text (form, TOP_MCF,
                1, col, col_ptr[col], FALSE)) != FI_SUCCESS) 
              {
                _NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
                ERRload_struct
                    (NFI, NFI_E_FORM, "%s%d", "FIfld_set_text", status);
                _NFIdebug ((fname, " returning FAILURE\n"));
                return (NFI_E_FORM);
              }

          }
      }
    /*  The number of rows has already been set when the MCF
        was first created; only reset it if we are appending data  */

    if (start_row != 0)
      {
        /*  Set the total number of rows in the mcf  */

        FIfld_get_num_rows (form, BOTTOM_MCF, &num_rows);
        _NFIdebug ((fname, "current number of rows = <%d>\n", num_rows));
        FIfld_set_num_rows (form, BOTTOM_MCF, num_rows + data_list->rows);
        _NFIdebug ((fname,
            "new number of rows = <%d>\n", num_rows + data_list->rows));
      }

    /*  Put the values in the mcf  */

    FImcf_get_num_cols (form, BOTTOM_MCF, &num_cols);
    data_ptr = (char **) data_list->data_ptr;
    fields = data_list->rows * data_list->columns;

    /*  Beginning with the start_row,
        put data from the buffer in the MCF  */
    /* for INTELSOL -CN 25/5/95 */ 
#if defined(OS_SCO_UNIX) || defined (OS_INTELSOL)  
    /* work around change - to set font for SCO - SSRS 1 Feb 94 */
    FIg_set_font( form, BOTTOM_MCF, "7x13bold", 15); 
#endif

    for (row = start_row, offset = 0; offset < fields;
        ++row, offset += data_list->columns)
      {
        if (num_cols != data_list->columns)
          {
            /*  Skip over the first column in the buffer  */
            start_col = 1; 
          }
        else
          {
            /*  Begin with the first column in the buffer  */

            start_col = 0;
          }
        _NFIdebug ((fname, "start_col = <%d>\n", start_col));

        for (col = 0; col < num_cols; ++col)
          {
            /*  Set the bottom mcf to reflect the data_list  */

            _NFIdebug ((fname, "Setting <%s> in row %d, col %d\n",
                data_ptr[offset + start_col + col], row, col));

            if ((status = FIfld_set_text (form, BOTTOM_MCF, row, col,
                data_ptr[offset + start_col + col], FALSE)) != FI_SUCCESS)
              {
                _NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
                ERRload_struct
                    (NFI, NFI_E_FORM, "%s%d", "FIfld_set_text", status);
                _NFIdebug ((fname, " returning FAILURE\n"));
                return (NFI_E_FORM);
              }
          }
      }
    _NFIdebug ((fname, " returning SUCCESS\n"));
    return (NFI_S_SUCCESS);
  }


long _NFFreview_load_mcf_data (form, syn_list, data_list)
  Form      form;
  MEMptr    syn_list;
  MEMptr    data_list;
  {
    auto    int     row, col;
    auto    int     offset;
    auto    int     status;
    auto    char    **syn_ptr;
    auto    char    **col_ptr;
    auto    char    **data_ptr;
    auto    char    column[10];
    static  char    *fname = "_NFFreview_load_mcf_data";

    _NFIdebug ((fname, "Enter...\n"));
    /*  Set the top mcf to reflect the column headings  */

			/* IGI Intel Solaris Port -31/5/95 */
#if  defined(OS_SCO_UNIX)  || defined(OS_INTELSOL) 
    /* work around change - to set font for SCO -  SSRS 1 Feb 94 */
    FIg_set_font( form, TOP_MCF, "7x13bold", 15);
#endif
    _NFIdebug ((fname, "Number of columns <%d>\n", data_list->rows));
    for (col = 0; col < data_list->rows + 1; ++col)  
      {
        if (col == 0)
            strcpy (column, "Attribute");
        else
            strcpy (column, "Value");

        if ((status = FIfld_set_text
            (form, TOP_MCF, 0, col, column, FALSE)) != FI_SUCCESS) 
          {
            _NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
            ERRload_struct
                (NFI, NFI_E_FORM, "%s%d", "FIfld_set_text", status);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_FORM);
          }

      }
    /*  Put the values in the mcf  */

    col_ptr = (char **) data_list->column_ptr;
    syn_ptr = (char **) syn_list->data_ptr;

/* Intel Solaris Port - CN 31/5/95 */

#if defined(OS_SCO_UNIX) || defined(OS_INTELSOL) 
    /* work around change - to set font for SCO - SSRS 1 Feb 94 */
    FIg_set_font( form, BOTTOM_MCF, "7x13bold", 15); 
#endif

    for (row = 0; row < syn_list->rows; ++row)
      {
        /*  Put the synonym in the first column  */

        if ((strcmp (syn_ptr[row], "")) == 0)
          {
            /*  Use the attribute name instead  */

            _NFIdebug ((fname, "Setting attribute <%s> in row %d, col %d\n",
                col_ptr[row], row, 0));

            if ((status = FIfld_set_text
               (form, BOTTOM_MCF, row, 0, col_ptr[row], FALSE)) != FI_SUCCESS)
              {
                _NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
                ERRload_struct (NFI,
                    NFI_E_FORM, "%s%d", "FIfld_set_text", status);
                _NFIdebug ((fname, " returning FAILURE\n"));
                return (NFI_E_FORM);
              }
          }
        else
          {
            _NFIdebug ((fname, "Setting synonym <%s> in row %d, col %d\n",
                syn_ptr[row], row, 0));

            if ((status = FIfld_set_text
               (form, BOTTOM_MCF, row, 0, syn_ptr[row], FALSE)) != FI_SUCCESS)
              {
                _NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
                ERRload_struct (NFI,
                    NFI_E_FORM, "%s%d", "FIfld_set_text", status);
                _NFIdebug ((fname, " returning FAILURE\n"));
                return (NFI_E_FORM);
              }
          }
      }

    /*  Put the values in the mcf  */

    data_ptr = (char **) data_list->data_ptr;
    for (col = 1, offset = 0; col < data_list->rows + 1;
        ++col, offset += data_list->columns)
      {
        for (row = 0; row < data_list->columns; ++row)
          {
            /*  Set the bottom mcf to reflect the data_list  */

            _NFIdebug ((fname, "Setting <%s> in row %d, col %d\n",
                data_ptr[offset + row], row, col));

            if ((status = FIfld_set_text (form, BOTTOM_MCF,
                row, col, data_ptr[offset + row], FALSE)) != FI_SUCCESS)
              {
                _NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
                ERRload_struct
                    (NFI, NFI_E_FORM, "%s%d", "FIfld_set_text", status);
                _NFIdebug ((fname, " returning FAILURE\n"));
                return (NFI_E_FORM);
              }
          }
      }

    _NFIdebug ((fname, " returning SUCCESS\n"));
    return (NFI_S_SUCCESS);
  }
