
/* machine.h included to take care of platform variencies MVR 23 Dec 1993 */
#include "machine.h"

#include "NFF.h"
#include "NFFfiles.h"

/*  Global NFF structure  */

extern struct NFFglobal_st NFFglobal;

long _NFFcopy_list_mcf (form, mode, read_or_write, row_array, attr_list,
                        data_list)
  Form      form;
  int       mode;
  char      *read_or_write;
  int       row_array[];
  MEMptr    attr_list;
  MEMptr    data_list;
  {
    int     vis_chars = 0;
    int     vis_cols = 0;
    int     vis_rows = 0;
    long    status;
    long    _NFFcreate_new_buffer();
    MEMptr  nattr_list = NULL;
    MEMptr  ndata_list = NULL;

    static  char *fname = "_NFFcopy_list_mcf";

    _NFIdebug ((fname, "Function entered ...\n"));

    /*  Create a new attr and data buffer with the subset of readable and
     *  writeable rows only.
     */

    if ((status = _NFFcreate_new_buffer( row_array, read_or_write,
	attr_list, data_list, &nattr_list, &ndata_list )) != NFI_S_SUCCESS )
     {
        _NFIdebug ((fname, "_NFFcreate_new_buffer = <0x%.8x>\n", status));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
     }

    if ((status = (long) FImcf_get_num_vis_cols
        (form, NFI_DATA_LIST, &vis_cols)) != FI_SUCCESS)
     {
        MEMclose (&nattr_list);
        MEMclose (&ndata_list);
        _NFIdebug ((fname, "FImcf_get_num_vis_cols = <%d>\n", status));
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FImcf_get_num_vis_cols",
                        status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
     }

    if ((status = (long) FIfld_get_num_vis_rows
        (form, NFI_DATA_LIST, &vis_rows)) != FI_SUCCESS)
     {
        MEMclose (&nattr_list);
        MEMclose (&ndata_list);
        _NFIdebug ((fname, "FIfld_get_num_vis_rows = <%d>\n", status));
        ERRload_struct
            (NFI, NFI_E_FORM, "%s%d", "FIfld_get_num_vis_rows", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
     }

    if ((status = (long) FIfld_get_num_vis_chars
        (form, NFI_DATA_LIST, 0, &vis_chars)) != FI_SUCCESS)
     {
        MEMclose (&nattr_list);
        MEMclose (&ndata_list);
        _NFIdebug ((fname, "FIfld_get_num_vis_chars = <%d>\n", status));
        ERRload_struct
            (NFI, NFI_E_FORM, "%s%d", "FIfld_get_num_vis_chars", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
     }

    /*  Erase the hidden mcfs  */

    _NFIdebug ((fname, "Erasing the hidden mcfs ...\n"));

    if ((status = (long) FIg_erase (form, NFI_DATA_LIST)) != FI_SUCCESS)
     {
        MEMclose (&nattr_list);
        MEMclose (&ndata_list);
        _NFIdebug ((fname, "FIg_erase = <%d>\n", status));
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_erase", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
     }

    if ((status = (long) FIg_erase (form, NFI_SYNONYM_LIST)) != FI_SUCCESS)
     {
        MEMclose (&nattr_list);
        MEMclose (&ndata_list);
        _NFIdebug ((fname, "FIg_erase = <%d>\n", status));
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_erase", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
     }

    /*  Create the mcf to reflect the attr_list;
        mode is FI_MULTI_SELECT for the data */

    if ((status = _NFFcreate_list_mcf (form, NFI_DATA_LIST, NFI_SYNONYM_LIST,
                                       mode, vis_rows, vis_cols, vis_chars,
                                       ndata_list)) != NFI_S_SUCCESS)
     {
        MEMclose (&nattr_list);
        MEMclose (&ndata_list);
        _NFIdebug ((fname, "_NFFcreate_list_mcf = <0x%.8x>\n", status));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
     }

    /*  Position the mcfs on the form  */
/*

    if ((status = _NFFposition_list_mcf (form)) != NFI_S_SUCCESS)
     {
        MEMclose (&nattr_list);
        MEMclose (&ndata_list);
        _NFIdebug ((fname, "_NFFposition_list_mcf = <0x%.8x>\n", status));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
     }
*/

    /*  Load the attr_list and data_list into the mcfs  */

    if ((status = _NFFload_mcf_data (form, NFI_DATA_LIST, NFI_SYNONYM_LIST,
                                     nattr_list, ndata_list)) != NFI_S_SUCCESS)
     {
        MEMclose (&nattr_list);
        MEMclose (&ndata_list);
        _NFIdebug ((fname, "_NFFload_mcf_data = <0x%.8x>\n", status));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
     }

    MEMclose (&nattr_list);
    MEMclose (&ndata_list);

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

    if ((status = (long) FIg_display (form, NFI_DATA_LIST)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIg_display = <%d>\n", status));
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_display", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    if ((status = (long) FIg_display (form, NFI_SYNONYM_LIST)) != FI_SUCCESS)
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


long _NFFcreate_list_mcf (form, label1, label2, mode, vis_rows, vis_cols,
                          vis_chars, data_list)
  Form      form;
  int       label1;
  int       label2;
  int       mode;
  int       vis_rows;
  int       vis_cols;
  int       vis_chars;
  MEMptr    data_list;
  {
    int       i, status;
    int       total_cols = 0;
    int       attr_mask;
    int       x1pos, y1pos;
    int       x2pos, y2pos;
/*
    int       x1size, y1size;
    int       x2size, y2size;
*/
    int       justification = FI_CENTER_JUSTIFIED;
    char      fontname[256];
    float     bodysize = 0;
    struct    standard_st st_var;

    static    char *fname = "_NFFcreate_list_mcf";

    _NFIdebug ((fname, "label1 = <%d>\n", label1));
    _NFIdebug ((fname, "label2 = <%d>\n", label2));
    _NFIdebug ((fname, "mode = <0x%.8x>\n", mode));

    /* fonts SSRS 28 Jan 94 */
/* Intel Solaris Port -IGI CN 31/5/95   */ 
#if defined(OS_SCO_UNIX)|| defined(OS_INTELSOL) 
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

    total_cols = data_list->columns;

    /*  See if there are any columns  */
/*
    if (total_cols == 0)
     {
     }
*/

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

        attr_mask = FI_VERT_SCROLL | FI_DISPLAY_VSCROLL | FI_NO_ROW_BUTTONS;

        /* if (total_cols > vis_cols)  should be based on data_list data */
            attr_mask |= FI_HORT_SCROLL | FI_DISPLAY_HSCROLL;

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
            attr_mask |= FI_HORT_SCROLL | FI_DISPLAY_HSCROLL;
   
    if ((mode == FI_REVIEW) || (mode == FI_MULTI_SELECT))
            attr_mask |=  FI_ROW_SELECT;

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


long _NFFload_mcf_data (form, label1, label2, attr_list, data_list) 
  Form      form;
  int       label1;
  int       label2;
  MEMptr    attr_list;
  MEMptr    data_list;
  {
    int     i, j;
    int     fields;
    long    status;
    char    **attr_ptr;
    char    **data_ptr;
    short   offset;
    short   syn_offset = 0;
    short   name_offset = 0;

    static  char *fname = "_NFFload_mcf_data";

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
        /*  Find the synonym and name offsets  */

        if ((status = _NFFfind_list_offsets (attr_list, &syn_offset,
                                               &name_offset)) != NFI_S_SUCCESS)
          {
            _NFIdebug ((fname, "_NFFfind_list_offsets = <0x%.8x>\n", status));
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (status);
          }

/* Intel Solaris Port -IGI CN 31/5/95   */ 
#if defined(OS_SCO_UNIX)   || defined(OS_INTELSOL)   
        /* work around change - to set font for SCO - SSRS 2 Feb 94 */
        FIg_set_font( form, label2, "7x13bold", 15 );
#endif

        attr_ptr = (char **) attr_list->data_ptr;

        for (i = 0; i < attr_list->rows; ++i)
          {
            fields = attr_list->columns * i;
            offset = syn_offset;

            /*  See if there is a synonym for this attribute  */

            if ((strcmp (attr_ptr[fields + syn_offset], "")) == 0)
                offset = name_offset;

            _NFIdebug ((fname, "Setting <%s>\n", attr_ptr[fields + offset]));
            _NFIdebug ((fname,
                "in row %d, col %d in label <%d>\n", 0, i, label2));

            if ((status = (long) FIfld_set_text (form, label2, 0, i,
                              attr_ptr[fields + offset], FALSE)) != FI_SUCCESS)
              {
                _NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
                ERRload_struct
                    (NFI, NFI_E_FORM, "%s%d", "FIfld_set_text", status);
                _NFIdebug ((fname, " returning FAILURE\n"));
                return (NFI_E_FORM);
              }
          }
     }
    else
      {
        /*  Set the top mcfs to reflect the column names in the data_list  */

/* Intel Solaris Port -IGI CN 31/5/95   */ 
#if defined(OS_SCO_UNIX)|| defined(OS_INTELSOL) 
        /* work around change - to set font for SCO - SSRS 2 Feb 94 */
        FIg_set_font( form, label2, "7x13bold", 15 );
#endif

        attr_ptr = (char **) data_list->column_ptr;
        for (i = 0; i < data_list->columns; ++i)
          {
            _NFIdebug ((fname, "Setting <%s>\n", attr_ptr[i]));
            _NFIdebug ((fname,
                "in row %d, col %d in label <%d>\n", 0, 1, label2));

            if ((status = (long) FIfld_set_text (form, label2, 0, i, 
                                            attr_ptr[i], FALSE)) != FI_SUCCESS)
              {
                _NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
                ERRload_struct
                    (NFI, NFI_E_FORM, "%s%d", "FIfld_set_text", status);
                _NFIdebug ((fname, " returning FAILURE\n"));
                return (NFI_E_FORM);
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

/* Intel Solaris Port -IGI CN 31/5/95   */ 
#if defined(OS_SCO_UNIX)|| defined(OS_INTELSOL) 
    /* work around change - to set font for SCO - SSRS 2 Feb 94 */
    FIg_set_font( form, label1, "7x13bold", 15 );
#endif

    data_ptr = (char **) data_list->data_ptr;
    for (i = 0; i < data_list->rows; ++i)
      {
        fields = data_list->columns * i;
        for (j = 0; j < data_list->columns; ++j)
          {
            _NFIdebug ((fname, "Setting <%s>\n", data_ptr[fields + j]));
            _NFIdebug ((fname,
                "in row %d, col %d in label <%d>\n", i, j, label1));

            if ((status = (long) FIfld_set_text (form, label1, i, j,
                                   data_ptr[fields + j], FALSE)) != FI_SUCCESS)
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


long _NFFalter_list_scroll_gadgets (form)
  Form    form;
  {
    int     col, row;
    int     status = FI_SUCCESS;
    int     length;
    int     label = NFI_DATA_LIST;
    int     num_cols;
    int     num_rows;
    int     num_chars;
    int     vis_rows;
    int     attr_mask;
    int     hscroll_mask = FI_HORT_SCROLL | FI_DISPLAY_HSCROLL;
    int     vscroll_mask = FI_VERT_SCROLL | FI_DISPLAY_VSCROLL;
    short   enable_buttons;

    static  char *fname = "_NFFalter_list_scroll_gadgets";

    FIfld_get_num_rows (form, label, &num_rows);
    if (status != FI_SUCCESS)
     {
        _NFIdebug ((fname, " returning SUCCESS\n"));
        return (NFI_S_SUCCESS);
     }

    status = FImcf_get_num_cols (form, label, &num_cols);
    if (status != FI_SUCCESS)
     {
        _NFIdebug ((fname, " returning SUCCESS\n"));
        return (NFI_S_SUCCESS);
     }

    for (col = 0; col < num_cols; ++col)
     {
        enable_buttons = FALSE;
        FIfld_get_num_vis_chars (form, label, col, &num_chars);
        for (row = 0; row < num_rows; ++row)
         {
            FIfld_get_text_length (form, label, row, col, &length);
            if (length > num_chars)
             {
                _NFIdebug ((fname, "enabling buttons on col %d\n", col));
                enable_buttons = TRUE;
                break;
             }
          }

         FIfld_get_attr (form, label, col, &attr_mask);

         if (enable_buttons == TRUE)
          {
              _NFIdebug ((fname, "adding hscroll_mask for col %d\n", col));
              attr_mask |= hscroll_mask;
          }
         else
          {
             if (attr_mask & hscroll_mask)
              {
                _NFIdebug ((fname,
                    "removing hscroll_mask for col %d\n", col));
                attr_mask ^= hscroll_mask;
              }
          }

         _NFIdebug ((fname, "fld attr_mask = <0x%.8x>\n", attr_mask));
         FIfld_set_attr (form, label, col, attr_mask);
     }

    /*  Only display the vertical scroll bar if there is reason to  */

    FIfld_get_num_vis_rows (form, label, &vis_rows);
    FImcf_get_attr (form, label, &attr_mask);

    if (num_rows > vis_rows)
      {
        _NFIdebug ((fname, "adding vscroll_mask for label\n"));
        attr_mask |= vscroll_mask;
      }
    else
      {
        if (attr_mask & vscroll_mask)
          {
            _NFIdebug ((fname,
                "removing vscroll_mask for label\n"));
            attr_mask ^= vscroll_mask;
          }
      }

    _NFIdebug ((fname, "mcf attr_mask = <0x%.8x>\n", attr_mask));
    FImcf_set_attr (form, label, attr_mask);

    _NFIdebug ((fname, " returning SUCCESS\n"));
    return (NFI_S_SUCCESS);
  }


long _NFFload_cp_attr_list (form, g_label, row_array, attr_list)
  Form    form;
  int     g_label;
  int     row_array[];
  MEMptr  attr_list;
  {
    int     i, j;
    int     rows = 0;
    int     count;
    short   name_offset = -1, syn_offset = -1;  
    short   offset; 
    long    status;
    char    **attr_ptr;

    static  char *fname = "_NFFload_cp_attr_list";

    _NFIdebug ((fname, "gadget label = <%d>\n", g_label));

    if ((status = MEMbuild_array (attr_list)) != MEM_S_SUCCESS)
    {
        _NFIdebug ((fname, "MEMbuild_array = <0x%.8x>\n", status));
        ERRload_struct (NFI, NFI_E_MEM, "%s%x", "MEMbuild_array", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_MEM);
     }

    for (i = 0; i < attr_list->rows; ++i)
     {
        if (row_array[i] != -1)
          ++rows;
     }

    if (rows == 0)
     {
        _NFIdebug ((fname, "There are no writeable rows in the attr_list\n"));
        _NFIdebug ((fname, " returning SUCCESS\n"));
        return (NFI_S_SUCCESS);
     }

    /* get the n_name and n_synonym offsets */

    /*  Find the synonym and name offsets  */

    if ((status = _NFFfind_list_offsets (attr_list, &syn_offset,
                                           &name_offset)) != NFI_S_SUCCESS)
     {
         _NFIdebug ((fname, "_NFFfind_list_offsets = <0x%.8x>\n", status));
         _NFIdebug ((fname, " returning FAILURE\n"));
         return (status);
     }

    FIfld_set_list_num_rows (form, g_label, 0, 0); /* clear out list */

    if ((status = (long) FIfld_set_list_num_rows (form, g_label, 0,
                                                  rows)) != FI_SUCCESS)
     {
        _NFIdebug ((fname, "FIfld_set_list_num_rows = <%d>\n", status));
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_list_num_rows",
                        status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
     }

    attr_ptr = (char **) attr_list->data_ptr;

    /* put the writeable attributes into the scroll_list */

    j = 0;
    for (i = 0; i < attr_list->rows; ++i)
     {
        if (row_array[i] != -1)
         {
            offset = syn_offset;
            count = attr_list->columns * i + offset;
            if (strcmp (attr_ptr[count], "") == 0) 
                count = attr_list->columns * i + name_offset;
            
            /* put the data in the associated list */

            if (j == 0)
               status = (long) FIfld_set_list_text (form, g_label, j, 0,
                                                    attr_ptr[count], TRUE);
            else
               status = (long) FIfld_set_list_text (form, g_label, j, 0,
                                                    attr_ptr[count], FALSE);
            if (status != FI_SUCCESS)
             {
                _NFIdebug ((fname, "FIfld_set_list_text = <%d>\n", status));
                ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_list_text",
                                status);
                _NFIdebug ((fname, " returning FAILURE\n"));
                return (NFI_E_FORM);
             }

            ++j;
            if (j >= rows)
               break;
         }
     }

    _NFIdebug ((fname, " returning SUCCESS\n"));
    return (NFI_S_SUCCESS);
  }


void NFFfree_copy (form, ptr)
  Form          *form;
  NFFcopy_ptr    ptr;
  {
    /*  Changed this function completely because 'ptr'
        was being freed 3 times (TR# 249301971) - Glenn 10/26/93  */

    if (form != NULL)
      {
        FIf_delete (*form);
        NFFglobal.current_form = *form = NULL;
      }

    /*  Free up the 'add' buffers  */

    if (ptr->add_ptr != NULL)
      {
        MEMclose (&(ptr->add_ptr->attr_list));
        MEMclose (&(ptr->add_ptr->data_list));
        MEMclose (&(ptr->add_ptr->value_list));
        if (ptr->add_ptr->rows) free (ptr->add_ptr->rows);
      }

    /*  Free up the 'file' buffers  */

    if (ptr->file_ptr != NULL)
      {
        MEMclose (&(ptr->file_ptr->attr_list));
        MEMclose (&(ptr->file_ptr->data_list));
        MEMclose (&(ptr->file_ptr->value_list));
        if (ptr->file_ptr->rows) free (ptr->file_ptr->rows);
      }

    /*  Free up the temp_list buffer  */

    MEMclose (&(ptr->temp_list));

    if (ptr) free (ptr);

    return;
  }

long  _NFFcreate_new_buffer( row_array, read_or_write, attr_list, data_list, 
			     nattr_list, ndata_list )
  int       row_array[];
  char      *read_or_write;
  MEMptr    attr_list;
  MEMptr    data_list;
  MEMptr    *nattr_list;
  MEMptr    *ndata_list;
  {
    int     i;
    int     j;
    int     rows;
    int     length;
    short   name_offset = -1;
    short   datatype_offset = -1;
    long    status;
    char    **data_ptr;
    char    **column_ptr;
    char    **format_ptr;
    char    *str = NULL;

    static  char *fname = "_NFFcreate_new_buffer";

    _NFIdebug ((fname, "Entering ...\n"));

    if (attr_list != NULL)
      {
        if ((status = MEMbuild_array (attr_list)) != MEM_S_SUCCESS)
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

    /* re-create the attr_list and data_list to reflect all the read_or_write 
       rows only.                                                          */

    rows = 0; 

    for (i = 0; i < attr_list->rows; ++i)
     {
         if (row_array[i] != -1)
            ++rows;
     } 
    _NFIdebug ((fname, "Number of writeable columns = <%d>\n", rows));

    if (!rows)
     {
        if (!strcmp (read_or_write, "n_read"))
         {
            status = NFI_W_NO_READABLE_ATTRIBUTES; 
            _NFIdebug ((fname, "There are no readable rows = <0x%.8x>\n",
                        status));
            _NFIdebug ((fname, " returning no readable rows\n"));
         }
        else
         {
            status = NFI_W_NO_WRITEABLE_ATTRIBUTES; 
            _NFIdebug ((fname, "There are no writeable rows = <0x%.8x>\n",
                        status));
            _NFIdebug ((fname, " returning no writeable rows\n"));
         }
        return (status);
     } 

    /* get the n_name and n_datatype offsets out of the attr_list */

    status = _NFFfind_column_offset (attr_list, "n_name", &name_offset);
    if (status != NFI_S_SUCCESS)
     {
        _NFIdebug ((fname, "_NFFfind_column_offset = <0x%.8x>\n", status));
        _NFIdebug ((fname, " returning Failure\n"));
        return (status);
     } 
    _NFIdebug ((fname, "name_offset = <%d>\n", name_offset));

    status = _NFFfind_column_offset (attr_list, "n_datatype", &datatype_offset);
    if (status != NFI_S_SUCCESS)
     {
        _NFIdebug ((fname, "_NFFfind_column_offset = <0x%.8x>\n", status));
        _NFIdebug ((fname, " returning Failure\n"));
        return (status);
     } 
    _NFIdebug ((fname, "datatype_offset = <%d>\n", datatype_offset));
    
    if (data_list->row_size < attr_list->row_size)
       length = attr_list->row_size + MEM_SIZE;
    else
       length = data_list->row_size + MEM_SIZE;

    str = (char *) malloc (length);
    if (!str)
     {
        status = NFI_E_MALLOC; 
        _NFIdebug ((fname, "malloc failed; size = <%d>\n", length));
        ERRload_struct (NFI, status, "%d", length);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
     }

    status = MEMopen (nattr_list, (rows * attr_list->row_size) + MEM_SIZE); 
    if (status != MEM_S_SUCCESS)
     {
        free (str);
        _NFIdebug ((fname, "MEMopen = <0x%.8x>\n", status));
        ERRload_struct (NFI, NFI_E_MEM, "%s%x", "MEMopen", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_MEM);
     }

    status = MEMopen (ndata_list, (rows * data_list->row_size) + MEM_SIZE); 
    if (status != MEM_S_SUCCESS)
     {
        free (str);
        MEMclose (nattr_list);
        _NFIdebug ((fname, "MEMopen = <0x%.8x>\n", status));
        ERRload_struct (NFI, NFI_E_MEM, "%s%x", "MEMopen", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_MEM);
     }

    format_ptr = (char **) attr_list->format_ptr;
    column_ptr = (char **) attr_list->column_ptr;
    data_ptr   = (char **) attr_list->data_ptr;

    for (i = 0; i < attr_list->columns; ++i) 
     {
        status = MEMwrite_format (*nattr_list, column_ptr[i], format_ptr[i]);
        if (status != MEM_S_SUCCESS)
         {
            free (str);
            MEMclose (nattr_list);
            MEMclose (ndata_list);
            _NFIdebug ((fname, "MEMwrite_format = <0x%.8x>\n", status));
            ERRload_struct (NFI, NFI_E_MEM, "%s%x", "MEMwrite_format", status);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_MEM);
         }
     }

    for (i = 0; i < attr_list->rows; ++i) 
     {
        if (row_array[i] != -1)
         {
            str[0] = 0;
            length = attr_list->columns * i;
            for (j = 0; j < attr_list->columns; ++j)
             {
                strcat (str, data_ptr[length + j]);
                strcat (str, "\1");
             } 

            status = MEMwrite (*nattr_list, str);
            if (status != MEM_S_SUCCESS)
             {
                free (str);
                MEMclose (nattr_list);
                MEMclose (ndata_list);
                _NFIdebug ((fname, "MEMwrite = <0x%.8x>\n", status));
                ERRload_struct (NFI, NFI_E_MEM, "%s%x", "MEMwrite", status);
                _NFIdebug ((fname, " returning FAILURE\n"));
                return (NFI_E_MEM);
             }

            /* write the column information to the ndata_list */

            status = MEMwrite_format (*ndata_list,  
                                      data_ptr[length + name_offset],
                                      data_ptr[length + datatype_offset]);
            if (status != MEM_S_SUCCESS)
             {
                free (str);
                MEMclose (nattr_list);
                MEMclose (ndata_list);
                _NFIdebug ((fname, "MEMwrite_format = <0x%.8x>\n", status));
                ERRload_struct (NFI, NFI_E_MEM, "%s%x", "MEMwrite_format",
                                status);
                _NFIdebug ((fname, " returning FAILURE\n"));
                return (NFI_E_MEM);
             }
            
         }
     }

    data_ptr = (char **) data_list->data_ptr;

    /* put the data into the ndata_list */  

    for (i = 0; i < data_list->rows; ++i)
     {
        length = data_list->columns * i;
        str[0] = 0;
        for (j = 0; j < data_list->columns; ++j)
         {
            if (row_array[j] != -1)
             {
                /* add the row to the str to write into ndata_list */
    
                strcat (str, data_ptr[length + j]);
                strcat (str, "\1");
             }
         }

        status = MEMwrite (*ndata_list, str);
        if (status != MEM_S_SUCCESS)
         {
            free (str);
            MEMclose (nattr_list);
            MEMclose (ndata_list);
            _NFIdebug ((fname, "MEMwrite = <0x%.8x>\n", status));
            ERRload_struct (NFI, NFI_E_MEM, "%s%x", "MEMwrite", status);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_MEM);
         }
     }

    if ((status = MEMbuild_array (*nattr_list)) != MEM_S_SUCCESS)
     {
        _NFIdebug ((fname, "MEMbuild_array = <0x%.8x>\n", status));
        ERRload_struct (NFI, NFI_E_MEM, "%s%x", "MEMbuild_array", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_MEM);
     }

    if ((status = MEMbuild_array (*ndata_list)) != MEM_S_SUCCESS)
     {
        _NFIdebug ((fname, "MEMbuild_array = <0x%.8x>\n", status));
        ERRload_struct (NFI, NFI_E_MEM, "%s%x", "MEMbuild_array", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_MEM);
     }

    if (_NFMdebug_st.NFIdebug_on)
     {
        MEMprint_buffer ("nattr_list", *nattr_list,_NFMdebug_st.NFIdebug_file);
        MEMprint_buffer ("ndata_list", *ndata_list,_NFMdebug_st.NFIdebug_file);
     } 

    free (str);

    _NFIdebug(( fname, "Returning NFI_S_SUCCESS\n" ));

    return( NFI_S_SUCCESS );
}
