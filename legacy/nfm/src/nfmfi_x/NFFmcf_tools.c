
/* machine.h included to take care of platform variencies MVR 23 Dec 1993 */
#include "machine.h"

#include "NFF.h"

/*  Global NFF structure  */

extern struct NFFglobal_st NFFglobal;

long _NFFfcreate_list_mcfs (form, label1, label2, mode, read_or_write,
                    attr_list, data_list)
  Form      form;
  int       label1;    /* Synonym MCF */
  int       label2;    /* Data MCF    */
  int       mode;
  char      *read_or_write;
  MEMptr    attr_list;
  MEMptr    data_list;
  {
    int     vis_chars = 0;
    int     vis_cols = 0;
    int     vis_rows = 0;
    int     i, j, count;
    int     *row_array;
    short   name_offset = -1;
    long    status = NFI_S_SUCCESS;
    char    **data_ptr;

    static  char *fname = "_NFFfcreate_list_mcfs";

    _NFIdebug ((fname, "label1 = <%d>\n", label1));
    _NFIdebug ((fname, "label2 = <%d>\n", label2));

    if (attr_list != NULL)
      {
        if ((status = MEMbuild_array (attr_list)) != MEM_S_SUCCESS)
          {
            _NFIdebug ((fname, "MEMbuild_array = <0x%.8x>\n", status));
            ERRload_struct (NFI, NFI_E_MEM, "%s%x", "MEMbuild_array", status);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_MEM);
          }
        if (attr_list->rows <= 0)
          {
            _NFIdebug ((fname, "MEMbuild_array = <0x%.8x>\n", status));
            ERRload_struct (NFI, NFI_E_MEM, "%s%x", "MEMbuild_array", status);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_MEM);
          }
      }

    if ((status = MEMbuild_array (data_list)) != MEM_S_SUCCESS)
      {
        _NFIdebug ((fname, "MEMbuild_array = <0x%.8x>\n", status));
        ERRload_struct (NFI, NFI_E_MEM, "%s%x", "MEMbuild_array", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_MEM);
      }

    /* get the name_offset for read_or_write */

    status = _NFFfind_column_offset (attr_list, read_or_write, &name_offset);
    if (status != NFI_S_SUCCESS)
     {
        _NFIdebug ((fname, "_NFFfind_column_offset = <0x%.8x>\n", status));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
     }

    /* create (malloc) the row_array and populate it */

    if ((row_array = (int *) malloc (attr_list->rows * sizeof (int))) == NULL) 
      {
        _NFIdebug ((fname,
            "malloc failed; size = <%d>\n", attr_list->rows * sizeof (int)));
        ERRload_struct (NFI, NFI_E_MALLOC, "%d",
                        attr_list->rows * sizeof (int));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_MALLOC);
      }

    data_ptr = (char **) attr_list->data_ptr;

    /* j will determine the position of the value in the MCF and list */

    j = 0;
    for (i = 0; i < attr_list->rows; ++i)
     {
        count = attr_list->columns * i + name_offset;
        if (strcmp (data_ptr[count], "Y") == 0)
         {
            row_array[i] = j;
            ++j;
         }
        else
           row_array[i] = -1;
     }

    if ((status = (long) FImcf_get_num_vis_cols
                         (form, label2, &vis_cols)) != FI_SUCCESS)
     {
        _NFIdebug ((fname, "FImcf_get_num_vis_cols = <%d>\n", status));
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FImcf_get_num_vis_cols",
                        status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
     }

    if ((status = (long) FIfld_get_num_vis_rows
        (form, label2, &vis_rows)) != FI_SUCCESS)
     {
        _NFIdebug ((fname, "FIfld_get_num_vis_rows = <%d>\n", status));
        ERRload_struct
            (NFI, NFI_E_FORM, "%s%d", "FIfld_get_num_vis_rows", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
     }

    if ((status = (long) FIfld_get_num_vis_chars
        (form, label2, 0, &vis_chars)) != FI_SUCCESS)
     {
        _NFIdebug ((fname, "FIfld_get_num_vis_chars = <%d>\n", status));
        ERRload_struct
            (NFI, NFI_E_FORM, "%s%d", "FIfld_get_num_vis_chars", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
     }

    /*  Erase the hidden mcfs  */

    _NFIdebug ((fname, "Erasing the hidden mcfs ...\n"));

    if ((status = (long) FIg_erase (form, label2)) != FI_SUCCESS)
     {
        _NFIdebug ((fname, "FIg_erase = <%d>\n", status));
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_erase", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
     }

    if ((status = (long) FIg_erase (form, label1)) != FI_SUCCESS)
     {
        _NFIdebug ((fname, "FIg_erase = <%d>\n", status));
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_erase", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
     }

    /*  Create the mcf to reflect the data_list */

    if ((status = _NFFgenerate_mcfs (form, label2, label1, mode, vis_rows,
             vis_cols, vis_chars, row_array, data_list)) != NFI_S_SUCCESS)
     {
        _NFIdebug ((fname, "_NFFgenerate_mcfs = <0x%.8x>\n", status));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
     }

    /*  Load the attr_list and data_list into the mcfs  */

    if ((status = _NFFload_data_into_mcfs (form, label2, label1, row_array,
                                     attr_list, data_list)) != NFI_S_SUCCESS)
     {
        _NFIdebug ((fname, "_NFFload_mcf_data = <0x%.8x>\n", status));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
     }

    /*  Alter the scroll gadgets based on the data  */

    if ((status = _NFFalter_list_scroll_gadgets (form)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname,
            "_NFFalter_list_scroll_gadgets = <0x%.8x>\n", status));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    /*  Display the mcfs  */

    _NFIdebug ((fname, "Displaying the mcfs\n"));

    if ((status = (long) FIg_display (form, label1)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIg_display = <%d>\n", status));
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_display", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    if ((status = (long) FIg_display (form, label2)) != FI_SUCCESS)
      {
        /*  See if the gadget was created  */

        if (status != FI_NO_SUCH_GADGET)
          {
            _NFIdebug ((fname, "FIg_display = <%d>\n", status));
            ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_display", status);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_FORM);
          }
      }

    _NFIdebug ((fname, " returning SUCCESS\n"));
    return (NFI_S_SUCCESS);
  }


long _NFFgenerate_mcfs (form, label1, label2, mode, vis_rows, vis_cols,
                          vis_chars, row_array, data_list)
  Form      form;
  int       label1;
  int       label2;
  int       mode;
  int       vis_rows;
  int       vis_cols;
  int       vis_chars;
  int       row_array[];
  MEMptr    data_list;
  {
    int       i, status;
    int       total_cols = 0;
    int       attr_mask;
    int       x1pos, y1pos;
    int       x2pos, y2pos;
    int       justification = FI_CENTER_JUSTIFIED;
    char      fontname[256];
    float     bodysize = 0;
    struct    standard_st st_var;

    static    char *fname = "_NFFgenerate_mcfs";

    _NFIdebug ((fname, "label1 = <%d>\n", label1));
    _NFIdebug ((fname, "label2 = <%d>\n", label2));
    _NFIdebug ((fname, "mode = <0x%.8x>\n", mode));

    /* fonts SSRS 28 Jan 94 */
/* IGI Intel Solaris Port -CN 31/5/95 */
#if defined(OS_SCO_UNIX) || defined(OS_INTELSOL) 
    strcpy (fontname, "7x13bold");
#else
    strcpy (fontname, "");
#endif

    _NFIdebug ((fname, "Getting the location from label1 <%d>\n", label1));

    if ((status = FIg_get_location (form, label1, &x1pos, 
                                    &y1pos)) != FI_SUCCESS)
     {
        _NFIdebug ((fname, "FIg_get_location = <%d>\n", status));
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_get_location", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
     }

    _NFIdebug ((fname, "Getting the location from label2 <%d>\n", label2));

    if ((status = FIg_get_location (form, label2, &x2pos,
                                    &y2pos)) != FI_SUCCESS)
     {
        _NFIdebug ((fname, "FIg_get_location = <%d>\n", status));
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_get_location", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
     }

    _NFIdebug ((fname, "x1pos, y1pos = %d, %d\n", x1pos, y1pos));
    _NFIdebug ((fname, "x2pos, y2pos = %d, %d\n", x2pos, y2pos));

    /* get the font information and bodysize */

    if ((status = FIg_get_font (form, label1, fontname,
                                 &bodysize)) != FI_SUCCESS)
     {
        _NFIdebug ((fname, "FIg_get_font = <%d>\n", status));
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_get_font", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
     }

    /* delete the gadgets */

    if ((status = FIg_delete (form, label1)) != FI_SUCCESS)
     {
        _NFIdebug ((fname, "FIg_delete = <%d>\n", status));
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_delete", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
     }

    if ((status = FIg_delete (form, label2)) != FI_SUCCESS)
     {
        _NFIdebug ((fname, "FIg_delete = <%d>\n", status));
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_delete", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
     }

    /*  Create the new mcf  */

    _NFIdebug ((fname, "Creating the new mcf for label1\n"));

    if ((status = FIg_new (form, FI_MULTI_COL, label1)) != FI_SUCCESS)
     {
        _NFIdebug ((fname, "FIg_new = <%d>\n", status));
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_new", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
     }

    /*  Load the standard variable structure for label1  */

    st_var.xlo = x1pos;
    st_var.ylo = y1pos;
#if defined(OS_INTELSOL) /* IGI Intel Solaris Port 16/08/95 */  
    st_var.xhi = 300; 
    st_var.yhi = 200; 
#else  
    st_var.xhi = 0;
    st_var.yhi = 0;
#endif 
    st_var.attr_mask = FI_NOT_DISPLAYED;
    st_var.value = 0.0;
    st_var.bodysize = bodysize;
    st_var.text = NULL;
    st_var.help_topic = NULL;
    st_var.command = NULL;
    st_var.fontname = fontname;
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

    if ((status = FIg_set_standard_variables (form, label1,
                                              &st_var)) != FI_SUCCESS)
     {
        _NFIdebug ((fname, "FIg_set_standard_variables = <%d>\n", status));
        ERRload_struct
            (NFI, NFI_E_FORM, "%s%d", "FIg_set_standard_variables", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
     }

    attr_mask = FI_NOT_DISPLAYED;

    /*  Make sure the characteristics mask is set  */

    _NFIdebug ((fname, "Setting the attr_mask to FI_NOT_DISPLAYED\n"));

    if ((status = FIg_set_attr (form, label1, attr_mask)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIg_set_attr = <%d>\n", status));
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_set_attr", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    /*  Create the new mcf  */

    _NFIdebug ((fname, "Creating the new mcf for label2\n"));

    if ((status = FIg_new (form, FI_MULTI_COL, label2)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIg_new = <%d>\n", status));
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_new", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    /*  Load the standard variable structure for label2  */

    st_var.xlo = x2pos;
    st_var.ylo = y2pos;
#if defined(OS_INTELSOL) /* IGI Intel Solaris Port 16/08/95 */  
    st_var.xhi = 300; 
    st_var.yhi = 200; 
#else  
    st_var.xhi = 0;
    st_var.yhi = 0;
#endif 
    st_var.attr_mask = FI_NOT_DISPLAYED;
    st_var.value = 0.0;
    st_var.bodysize = bodysize;
    st_var.text = NULL;
    st_var.help_topic = NULL;
    st_var.command = NULL;
    st_var.fontname = fontname;
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
        (form, label2, &st_var)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIg_set_standard_variables = <%d>\n", status));
        ERRload_struct
            (NFI, NFI_E_FORM, "%s%d", "FIg_set_standard_variables", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    attr_mask = FI_NOT_DISPLAYED;

    /*  Make sure the characteristics mask is set  */

    _NFIdebug ((fname, "Setting the attr_mask to FI_NOT_DISPLAYED\n"));

    if ((status = FIg_set_attr (form, label2, attr_mask)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIg_set_attr = <%d>\n", status));
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_set_attr", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    /*  Find out how many columns to set  */

    for (i = 0; i < data_list->columns; ++i)
     {
         if (row_array[i] != -1)
            ++total_cols;
     }

    if (total_cols == 0)
        total_cols = data_list->columns; 

    /*  Set the number of columns  */

    _NFIdebug ((fname, "Setting number of columns to %d\n", total_cols));

    if ((status = FImcf_set_num_cols (form, label1, total_cols)) != FI_SUCCESS)
     {
        _NFIdebug ((fname, "FImcf_set_num_cols = <%d>\n", status));
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FImcf_set_num_cols", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
     }

    if ((status = FImcf_set_num_cols (form, label2, total_cols)) != FI_SUCCESS)
     {
        _NFIdebug ((fname, "FImcf_set_num_cols = <%d>\n", status));

        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FImcf_set_num_cols", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
     }

    /*  Set the number of visible rows  */

    _NFIdebug ((fname, "Setting number of visible rows to %d\n", vis_rows));

    if ((status = FIfld_set_num_vis_rows (form, label1,
                                          vis_rows)) != FI_SUCCESS)
     {
        _NFIdebug ((fname, "FIfld_set_num_vis_rows = <%d>\n", status));
        ERRload_struct
            (NFI, NFI_E_FORM, "%s%d", "FIfld_set_num_vis_rows", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
     }

    if ((status = FIfld_set_num_vis_rows (form, label2, 1)) != FI_SUCCESS)
     {
        _NFIdebug ((fname, "FIfld_set_num_vis_rows = <%d>\n", status));
        ERRload_struct
            (NFI, NFI_E_FORM, "%s%d", "FIfld_set_num_vis_rows", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
     }

    for (i = 0; i < total_cols; ++i)
     {
        /*  Set the number of visible characters  */

        _NFIdebug ((fname, "%d: Setting number of visible characters to %d\n",
            i, vis_chars));

        if ((status = FIfld_set_num_vis_chars
            (form, label1, i, vis_chars)) != FI_SUCCESS)
         {
            _NFIdebug ((fname, "FIfld_set_num_vis_chars = <%d>\n", status));
            ERRload_struct
                (NFI, NFI_E_FORM, "%s%d", "FIfld_set_num_vis_chars", status);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_FORM);
         }

        if ((status = FIfld_set_num_vis_chars
            (form, label2, i, vis_chars)) != FI_SUCCESS)
         {
            _NFIdebug ((fname, "FIfld_set_num_vis_chars = <%d>\n", status));
            ERRload_struct
                (NFI, NFI_E_FORM, "%s%d", "FIfld_set_num_vis_chars", status);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_FORM);
         }

        /*  Set the mode for the columns  */

        _NFIdebug ((fname, "%d: Setting the mode\n", i));

        if ((status = FIfld_set_mode (form, label1, i, mode)) != FI_SUCCESS)
         {
            _NFIdebug ((fname, "FIfld_set_mode = <%d>\n", status));
            ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_mode", status);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_FORM);
         }

        if ((status = FIfld_set_mode (form, label2, i,
                                      FI_REVIEW)) != FI_SUCCESS)
         {
            _NFIdebug ((fname, "FIfld_set_mode = <%d>\n", status));
            ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_mode", status);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_FORM);
         }

        /*  Set the justification for the columns  */

        _NFIdebug ((fname, "%d: Setting the justification\n", i));

        if ((status = FImcf_set_justification
            (form, label1, i, FI_LEFT_JUSTIFIED)) != FI_SUCCESS)
         {
            _NFIdebug ((fname, "FImcf_set_justification = <%d>\n", status));
            ERRload_struct
                (NFI, NFI_E_FORM, "%s%d", "FImcf_set_justification", status);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_FORM);
         }

        if ((status = FImcf_set_justification
            (form, label2, i, justification)) != FI_SUCCESS)
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
            (form, label1, i, FI_ALPHA)) != FI_SUCCESS)
         {
            _NFIdebug ((fname, "FIfld_set_type = <%d>\n", status));
            ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_type", status);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_FORM);
         }

        if ((status = FIfld_set_type
            (form, label2, i, FI_ALPHA)) != FI_SUCCESS)
         {
            _NFIdebug ((fname, "FIfld_set_type = <%d>\n", status));
            ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_type", status);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_FORM);
         }

        _NFIdebug ((fname, "%d: Setting field attributes\n", i));

        /*  Disable everything but NOTIFY_BY_LINE,
            HORT_SCROLL, DISPLAY_HSCROLL and VERT_SCROLL  */

        /* attr_mask = FI_VERT_SCROLL | FI_DISPLAY_VSCROLL; */

        /* if (total_cols > vis_cols)  should be based on data_list data */
        /* attr_mask |= FI_HORT_SCROLL | FI_DISPLAY_HSCROLL | FI_ROW_SELECT; */
         attr_mask = FI_HORT_SCROLL | FI_DISPLAY_HSCROLL; 

        if ((status = FIfld_set_attr
            (form, label1, i, attr_mask)) != FI_SUCCESS)
         {
            _NFIdebug ((fname, "FIfld_set_attr = <%d>\n", status));
            ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_attr", status);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_FORM);
         }

        /* attr_mask = FI_DISABLE_VSCROLL | FI_DISABLE_HSCROLL; */

        /* attr_mask = FI_HORT_SCROLL | FI_DISABLE_VSCROLL; */

        attr_mask = FI_DEFAULT; 

        if ((status = FIfld_set_attr
            (form, label2, i, attr_mask)) != FI_SUCCESS)
         {
            _NFIdebug ((fname, "FIfld_set_attr = <%d>\n", status));
            ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_attr", status);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_FORM);
         }
     }

    _NFIdebug ((fname, "Setting mcf attributes\n"));

    attr_mask = FI_VERT_SCROLL | FI_DISPLAY_VSCROLL | FI_NO_ROW_BUTTONS;
    if (total_cols > vis_cols)  
            attr_mask |= FI_HORT_SCROLL | FI_DISPLAY_HSCROLL | FI_ROW_SELECT;

    if ((status = FImcf_set_attr (form, label1, attr_mask)) != FI_SUCCESS)
     {
        _NFIdebug ((fname, "FImcf_set_attr = <%d>\n", status));
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FImcf_set_attr", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
     }

    attr_mask = FI_DISABLE_VSCROLL | FI_DISABLE_HSCROLL | FI_NO_ROW_BUTTONS;

    if ((status = FImcf_set_attr (form, label2, attr_mask)) != FI_SUCCESS)
     {
        _NFIdebug ((fname, "FImcf_set_attr = <%d>\n", status));
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FImcf_set_attr", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
     }

    /*  Set the number of visible columns  */

    _NFIdebug ((fname, "Setting number of visible columns to %d\n", vis_cols));
  
    if (total_cols > vis_cols)
     {
        if ((status = FImcf_set_num_vis_cols (form, label1,
                                              vis_cols)) != FI_SUCCESS)
         {
            _NFIdebug ((fname, "FImcf_set_num_vis_cols = <%d>\n", status));
            ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FImcf_set_num_vis_cols",
                            status);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_FORM);
         }

        if ((status = FImcf_set_num_vis_cols (form, label2,
                                              vis_cols)) != FI_SUCCESS)
         {
            _NFIdebug ((fname, "FImcf_set_num_vis_cols = <%d>\n", status));
            ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FImcf_set_num_vis_cols",
                            status);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_FORM);
         }
     }
    else
     {
        if ((status = FImcf_set_num_vis_cols (form, label1,
                                              total_cols)) != FI_SUCCESS)
         {
            _NFIdebug ((fname, "FImcf_set_num_vis_cols = <%d>\n", status));
            ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FImcf_set_num_vis_cols",
                            status);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_FORM);
         }

        if ((status = FImcf_set_num_vis_cols (form, label2,
                                              total_cols)) != FI_SUCCESS)
         {
            _NFIdebug ((fname, "FImcf_set_num_vis_cols = <%d>\n", status));
            ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FImcf_set_num_vis_cols",
                            status);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_FORM);
         }
     }

    /*  Link the scrolling of the bottom one to the top  */

    _NFIdebug ((fname, "Linking the scrolling to the top mcf\n"));

    if ((status = FImcf_set_scroll_link (form, label1, label2)) != FI_SUCCESS)
     {
        _NFIdebug ((fname, "FImcf_set_scroll_link = <%d>\n", status));
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FImcf_set_scroll_link",
                        status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
     }

    /*  Activate the gadget  */

    _NFIdebug ((fname, "Activating the mcf\n"));

    if ((status = FIg_activate (form, label1)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIg_activate = <%d>\n", status));
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_activate", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    if ((status = FIg_activate (form, label2)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIg_activate = <%d>\n", status));
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_activate", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    _NFIdebug ((fname, " returning SUCCESS\n"));
    return (NFI_S_SUCCESS);
  }


long _NFFload_data_into_mcfs (form, label1, label2, row_array,
                              attr_list, data_list) 
  Form      form;
  int       label1;
  int       label2;
  int       row_array[]; 
  MEMptr    attr_list;
  MEMptr    data_list;
  {
    int     i, j;
    int     fields;
    long    status;
    char    **attr_ptr;
    char    **data_ptr;
    short   syn_offset = 0;

    static  char *fname = "_NFFload_data_into_mcfs";

    _NFIdebug ((fname, "label1 = <%d>\n", label1));
    _NFIdebug ((fname, "label2 = <%d>\n", label2));

    /*  Set the number of rows to 0 to clear out the field  */

    _NFIdebug ((fname,  
        "Setting the number of rows to 0 to clear out the field\n"));

    if ((status = (long) FIfld_set_num_rows (form, label2, 0)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIfld_set_num_rows = <%d>\n", status));
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_num_rows", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    /*  Set the number of rows  */

    _NFIdebug ((fname, "Setting the number of rows to %d\n", 1));

    if ((status = (long) FIfld_set_num_rows (form, label2, 1)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIfld_set_num_rows = <%d>\n", status));
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_num_rows", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    if (attr_list != NULL)
     {
        /*  Find the synonym offset  */

        if ((status = _NFFfind_column_offset (attr_list, "n_synonym",
                                              &syn_offset)) != NFI_S_SUCCESS)
         {
            _NFIdebug ((fname, "_NFFfind_list_offsets = <0x%.8x>\n", status));
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (status);
         }

/* IGI Intel Solaris Port -CN 31/5/95 */
#if defined(OS_SCO_UNIX)  || defined(OS_INTELSOL)  
	/* work around change - to set font for SCO - SSRS 4 Feb 94 */
        FIg_set_font( form, label2, "7x13bold", 15 );
#endif

        attr_ptr = (char **) attr_list->data_ptr;

        for (i = 0; i < attr_list->rows; ++i)
         {
            if (row_array[i] != -1)
             {
                fields = attr_list->columns * i;

                /*  See if there is a synonym for this attribute  */

                _NFIdebug ((fname,"Setting <%s>\n", 
                            attr_ptr[fields + syn_offset]));
                _NFIdebug ((fname, "in row %d, col %d in label <%d>\n",
                            0, row_array[i], label2));

                if ((status = (long) FIfld_set_text (form, label2, 0,
                                    row_array[i], attr_ptr[fields + syn_offset],
                                                     FALSE)) != FI_SUCCESS)
                 {
                    _NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
                    ERRload_struct
                        (NFI, NFI_E_FORM, "%s%d", "FIfld_set_text", status);
                    _NFIdebug ((fname, " returning FAILURE\n"));
                    return (NFI_E_FORM);
                 }
             }
         }
     }
    else
      {
        /*  Set the top mcfs to reflect the column names in the data_list  */

/* IGI Intel Solaris Port -CN 31/5/95 */
#if defined(OS_SCO_UNIX) || defined(OS_INTELSOL) 
	/* work around change - to set font for SCO - SSRS 4 Feb 94 */
        FIg_set_font( form, label2, "7x13bold", 15 );
#endif

        attr_ptr = (char **) data_list->column_ptr;
        for (i = 0; i < data_list->columns; ++i)
          {
            if (row_array[i] != -1)
             {
                _NFIdebug ((fname, "Setting <%s>\n", attr_ptr[i]));
                _NFIdebug ((fname, "in row %d, col %d in label <%d>\n",
                            0, row_array[i], label2));

                if ((status = (long) FIfld_set_text (form, label2, 0,  
                              row_array[i], attr_ptr[i], FALSE)) != FI_SUCCESS)
                  {
                    _NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
                    ERRload_struct
                        (NFI, NFI_E_FORM, "%s%d", "FIfld_set_text", status);
                    _NFIdebug ((fname, " returning FAILURE\n"));
                    return (NFI_E_FORM);
                  }
              }
          }
      }

    /*  Set the number of rows to 0 to clear out the field  */

    _NFIdebug ((fname,  
        "Setting the number of rows to 0 to clear out the field\n"));

    if ((status = (long) FIfld_set_num_rows (form, label1, 0)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIfld_set_num_rows = <%d>\n", status));
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_num_rows", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    /*  Set the number of rows  */

    _NFIdebug ((fname, "Setting the number of rows to %d\n", data_list->rows));

    if ((status = (long) FIfld_set_num_rows (form, label1,
                                      data_list->rows)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIfld_set_num_rows = <%d>\n", status));
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_num_rows", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    /*  Put the values in the mcf  */
/* IGI Intel Solaris Port -CN 31/5/95 */
#if defined(OS_SCO_UNIX) || defined(OS_INTELSOL) 
    /* work around change - to set font for SCO - SSRS 4 Feb 94 */
    FIg_set_font( form, label1, "7x13bold", 15 );
#endif

    data_ptr = (char **) data_list->data_ptr;
    for (i = 0; i < data_list->rows; ++i)
      {
        fields = data_list->columns * i;
        for (j = 0; j < data_list->columns; ++j)
          {
            if (row_array[j] != -1)
             {
                _NFIdebug ((fname, "Setting <%s>\n", data_ptr[fields + j]));
                _NFIdebug ((fname, "in row %d, col %d in label <%d>\n",
                            i, row_array[j], label1));

                if ((status = (long) FIfld_set_text (form, label1, i, 
                     row_array[j], data_ptr[fields + j], FALSE)) != FI_SUCCESS)
                 {
                    _NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
                    ERRload_struct
                        (NFI, NFI_E_FORM, "%s%d", "FIfld_set_text", status);
                    _NFIdebug ((fname, " returning FAILURE\n"));
                    return (NFI_E_FORM);
                 }
             }
          }
      }

    _NFIdebug ((fname, " returning SUCCESS\n"));
    return (NFI_S_SUCCESS);
  }


long _NFFgeneric_load_data (form, label, data_list) 
  Form      form;
  int       label;
  MEMptr    data_list;  
  {
    auto    int     i, j;
    auto    int     count;
    auto    int     vis_rows;
    auto    int     attr_mask;
    auto    long    status;
    auto    char    **data_ptr;
    static  char    *fname = "_NFFgeneric_load_data";

    _NFIdebug ((fname, "label = <%d>\n", label));

    /*  Set the number of rows to 0 to clear out the field  */

    _NFIdebug ((fname,  
        "Setting the number of rows to 0 to clear out the field\n"));

    if ((status = (long) FIfld_set_num_rows (form, label, 0)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIfld_set_num_rows = <%d>\n", status));
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_num_rows", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    /* If the MEMbuffer is null or has no rows exit */

    if (!data_list)
      {
        _NFIdebug ((fname, "MEMbuffer is NULL\n"));
        _NFIdebug ((fname, " returning Success\n"));
        return (NFI_S_SUCCESS);
      }

    if (data_list->rows <= 0)
      {
        _NFIdebug ((fname, "MEMbuffer has no row(s) of data\n"));
        _NFIdebug ((fname, " returning Success\n"));
        return (NFI_S_SUCCESS);
      }

    /*  Set the number of rows  */

    _NFIdebug ((fname, "Setting the number of rows to %d\n", data_list->rows));

    if ((status = (long) FIfld_set_num_rows (form, label,
                                             data_list->rows)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIfld_set_num_rows = <%d>\n", status));
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_num_rows", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

/* IGI Intel Solaris Port -CN 31/5/95 */
#if defined(OS_SCO_UNIX)|| defined(OS_INTELSOL) 
    /* work around change - to set font for SCO - SSRS 4 Feb 94 */
    FIg_set_font( form, label, "7x13bold", 15 );
#endif

    data_ptr = (char **) data_list->data_ptr;

    for (i = 0; i < data_list->rows; ++i)
     {
        count = data_list->columns * i;
        for (j = 0; j < data_list->columns; ++j)
         {
            if ((status = (long) FIfld_set_text (form, label, i, j,
                                    data_ptr[count + j], FALSE)) != FI_SUCCESS)
             {
                _NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
                ERRload_struct
                      (NFI, NFI_E_FORM, "%s%d", "FIfld_set_text", status);
                _NFIdebug ((fname, " returning FAILURE\n"));
                return (NFI_E_FORM);
             }
          }
      }

    /*  Added 5/21/92 - Glenn  */

    FIfld_get_num_vis_rows (form, label, &vis_rows);
    FImcf_get_attr (form, label, &attr_mask);
    if (data_list->rows > vis_rows)
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

    _NFIdebug ((fname, " returning SUCCESS\n"));
    return (NFI_S_SUCCESS);
  }


long _NFFgeneric_mcf_select_all_rows (form, toggle_label, mcf_label, num_rows)
  Form          form;
  int           toggle_label;  /* < 10 if there is no toggle gadget */
  int           mcf_label;
  int           num_rows;
  {
    long        status = NFI_S_SUCCESS;
    int         i;
    int         state = TRUE;

    static  char *fname = "_NFFgeneric_mcf_select_all_rows";

    _NFIdebug ((fname, "label    = <%d>\n", toggle_label));
    _NFIdebug ((fname, "label    = <%d>\n", mcf_label));
    _NFIdebug ((fname, "num_rows = <%d>\n", num_rows));

    if (toggle_label > 10)   /* I/Forms reserver 1-10 */
     {
        /* get the gadget state */

        status = (long) FIg_get_state (form, toggle_label, &state);
        if (status != FI_SUCCESS)
         {
            _NFIdebug ((fname, "FIg_get_state = <%d>\n", status));
            ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_get_state",status);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_FORM);
         }
     }

    if (!state)  /*  files will be selected individually  */
     {
        _NFIdebug ((fname, "Files will be selected individually\n"));
        _NFIdebug ((fname, " returning SUCCESS\n"));
        return (NFI_S_SUCCESS);
     }

    /***********  Modify this part to see if num_rows > 0,  if it is not
                  get the number of rows from the MCF and use it.
     ***********************************************************************/

    if (num_rows <= 0)
     {
        NFFform_message (CURRENT_LABEL, NFI_W_NO_FILES_EXIST_IN_MCF, NULL);
        _NFIdebug ((fname, "No rows exist in the mcf field\n"));
        _NFIdebug ((fname, " returning SUCCESS\n"));
        return (NFI_S_SUCCESS);
     }

    for (i = 0; i < num_rows; ++i)
     {
        status = (long) FImcf_set_select (form, mcf_label, i, TRUE);
        if (status != FI_SUCCESS)
         {
             _NFIdebug ((fname, "FImcf_set_select = <%d>\n", status));
             ERRload_struct (NFI, NFI_E_FORM, "%s%d",  
                                   "FImcf_set_select", status);
             _NFIdebug ((fname, " returning FAILURE\n"));
             return (NFI_E_FORM);
         }
     }

    _NFIdebug ((fname, " returning SUCCESS\n"));
    return (NFI_S_SUCCESS);
  }


