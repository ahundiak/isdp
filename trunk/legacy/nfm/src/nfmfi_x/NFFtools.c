
/* machine.h included to take care of platform variencies MVR 23 Dec 1993 */
#include "machine.h"

#include "NFF.h"
/* Added to get INT_MAX                     -Jujare  05-Apr-1995  */ 
#include <limits.h> 
#include "NFFmap.h"

/*  Global NFF structure  */

extern struct NFFglobal_st NFFglobal;

long _NFFcenter_form (form, xlocation, ylocation)
  Form   form;
  int    xlocation;  /*  i - if < 0, center along x axis  */
  int    ylocation;  /*  i - if < 0, center along y axis  */
  {
    static  char    *fname = "_NFFcenter_form";

    auto    int     scr_height;
    auto    int     scr_width;
    auto    int     vs, status;
    auto    int     xlo, ylo;
    auto    int     xsize, ysize;
    auto    struct  scr_info info[MAX_SCREENS];

    /*  Make sure the form is valid  */

    if (form == NULL)
      {
        _NFIdebug ((fname, "form is NULL\n"));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_NULL_FORM);
      }

#ifndef XWINDOWS

    /*  Get information about the current virtual screen  */

    if (status = Inq_screen_info (info))
      {
        _NFIdebug ((fname, "Inq_screen_info = %d\n", status));
        ERRload_struct
            (NFI, NFI_E_GRAPHICS, "%s%d", "Inq_screen_info", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_GRAPHICS);
      }

    if (status = Inq_displayed_vs (&vs))
      {
        _NFIdebug ((fname, "Inq_displayed_vs = %d\n", status));
        ERRload_struct
            (NFI, NFI_E_GRAPHICS, "%s%d", "Inq_displayed_vs", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_GRAPHICS);
      }

    if (info[vs].vsi_screen_num == -1)
      {
        _NFIdebug ((fname, "error getting screen info\n"));
        ERRload_struct (NFI, NFI_E_GRAPHICS, "%s%d", "screen number", -1);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_GRAPHICS);
      }

    if ((info[vs].vsi_flags & VSI_VIRTUAL_SCREEN) == 0)
      {
        _NFIdebug ((fname, "virtual screen %d is not usable\n", vs));
        ERRload_struct (NFI, NFI_E_GRAPHICS, "%s%d", "virtual screen", vs);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_GRAPHICS);
      }
    scr_height = info[vs].vsi_y;
    scr_width  = info[vs].vsi_x;
#else
    scr_height = XDisplayHeight( NFFglobal.display, 0 );
    scr_width  = XDisplayWidth ( NFFglobal.display, 0 );
#endif

    /*  Calculate the location to center the form on the screen  */

    xlo = (scr_width  - PANEL_MENU_WIDTH) / 2;
    ylo = (scr_height - MESSAGE_STRIP_HEIGHT) / 2;
  
    if ((status = FIf_get_size (form, &xsize, &ysize)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIf_get_size = <%d>\n", status));
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIf_get_size", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    if (xlocation < 0)
      {
        if (NFFglobal.forms[MAIN_LABEL] != NULL)
          {
            /*  Center the form between the left screen
                edge and the left edge of the PANEL_MENU  */

            _NFIdebug ((fname, "x: centering form left of the PANEL_MENU\n"));

            xlo -= (xsize / 2);
          }
        else
          {
            /*  Center the form on the screen  */

            _NFIdebug ((fname, "x: centering form on the screen\n"));

            xlo = (scr_width / 2) - (xsize / 2);
          }
      }
    else
      {
        /*  Position the form on the screen  */

        _NFIdebug ((fname, "x: positioning form on the screen\n"));

        xlo = xlocation;
      }

    if (ylocation < 0)
      {
        /*  Center the form on the screen  */

        _NFIdebug ((fname, "y: centering form on the screen\n"));

        ylo -= (ysize / 2);
      }
    else
      {
        if (ylocation > Y_FORM_POS)
          {
            /*  Take the absolute position on the screen  */

            _NFIdebug ((fname, "y: positioning form on the screen\n"));

            ylo = ylocation;
          }
        else if (NFFglobal.forms[MAIN_LABEL] != NULL)
          {
            /*  Position the form below the BAR_MENU  */

            _NFIdebug ((fname, "y: positioning form below the BAR_MENU\n"));

            ylo = BAR_MENU_HEIGHT + 5;
          }
        else
          {
            /*  There is no main form, position the form on the screen  */

            _NFIdebug ((fname, "y: positioning form on the screen\n"));

            ylo = ylocation;
          }
      }

    _NFIdebug ((fname, "xlo, ylo = (%d, %d)\n", xlo, ylo));

    if ((status = FIf_set_location (form, xlo, ylo)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIf_set_location = <%d>\n", status));
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIf_set_location", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    _NFIdebug ((fname, " returning SUCCESS\n"));
    return (NFI_S_SUCCESS);
  }

#define ROW_SELECT_BUTTON_SIZE  10

long _NFFcenter_gadget (form, label)
  Form   form;
  int    label;
  {
    auto    int     type;
    auto    int     attr_mask;
    auto    int     xpos, ypos;
    auto    int     fx_size, fy_size;
    auto    int     gx_size, gy_size;
    auto    long    status;
    static  char    *fname = "_NFFcenter_gadget";

    /*  Make sure the form is valid  */

    if (form == NULL)
      {
        _NFIdebug ((fname, "form is NULL\n"));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_NULL_FORM);
      }

    /*  Get the size of the form  */

    FIf_get_size (form, &fx_size, &fy_size);

#if defined  (OS_SCO_UNIX)  || defined(OS_INTELSOL) 
    /* INTELSOL is included 'coz VALIDATE_TEXT is getting jumbled up - CN
					IGI IntelSolaris Port 13/6/95 */
    /* Fix for TR # 249405780 per Steve Lanham's suggestion - IGI 08/24/94*/
    FIg_erase(form, label);
#endif

    /*  Center the gadget on the form  */

    FIg_get_location (form, label, &xpos, &ypos);
    FIg_get_size (form, label, &gx_size, &gy_size);

    /*  Find out what type of gadget it is  */

    FIg_get_type (form, label, &type);
    _NFIdebug ((fname, "gadget type  is %d\n", type));
    if (type == FI_FIELD)
      {
        /*  We need to see if there is a vertical scroll bar enabled  */

        FIfld_get_attr (form, label, 0, &attr_mask);
        if (attr_mask & FI_VERT_SCROLL)
          {
            /*  The gadget is actually wider than they say  */

            gx_size += FI_SCROLL_SIZE + ROW_SELECT_BUTTON_SIZE;
          }
      }
    else if (type == FI_MULTI_COL)
      {
        /*  We need to see if there is a vertical scroll bar enabled  */

        FImcf_get_attr (form, label, &attr_mask);
        if (attr_mask & FI_VERT_SCROLL)
          {
            /*  The gadget is actually wider than they say  */

            gx_size += FI_SCROLL_SIZE + ROW_SELECT_BUTTON_SIZE;
          }
        else if (label == MAP_TOP_MCF)
          {
            /*  This will compensate for the top
                and bottom mcfs not being centered together  */

            gx_size += FI_SCROLL_SIZE + ROW_SELECT_BUTTON_SIZE;
          }
      }
    xpos = (fx_size / 2) - (gx_size / 2);

    FIg_set_location (form, label, xpos, ypos);

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


long _NFFfind_column_offset (buffer, attrname, offset)
  MEMptr   buffer;
  char     *attrname;
  short    *offset;
  {
    auto    int     i;
    auto    char    **column;
    auto    short   found = FALSE;
    static  char    *fname = "_NFFfind_column_offset";

    _NFIdebug ((fname, "attrname = <%s>\n", attrname));

    if (buffer == NULL)
      {
        _NFIdebug ((fname, "input buffer is NULL\n"));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (MEM_E_NULL_BUFFER);
      }

    column = (char **) buffer->column_ptr;

    for (i = 0; i < buffer->columns; ++i)
      {
        if ((strcmp (column[i], attrname)) == 0)
          {
            *offset = i;
            found = TRUE;
            break;
          }
      }

    if (found == FALSE)
      {
        ERRload_struct (NFI, NFI_E_BUFFER, NULL);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_BUFFER);
      }

    _NFIdebug ((fname, "offset = <%d>\n", *offset));

    _NFIdebug ((fname, "returning SUCCESS\n"));
    return (NFI_S_SUCCESS);
  }


long _NFFbuild_value_buffer (buffer)
  MEMptr    *buffer;
  {
    auto    long    status;
    static  char    *fname = "_NFFbuild_value_buffer";

    if ((status = MEMopen (buffer, MEM_SIZE)) != MEM_S_SUCCESS)
      {
        _NFIdebug ((fname, "MEMopen = <0x%.8x>\n", status));
        ERRload_struct (NFI, NFI_E_MEM, "%s%x", "MEMopen", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_MEM);
      }

    if ((status = MEMwrite_format
        (*buffer, "n_input", "char(20)")) != MEM_S_SUCCESS)
      {
        _NFIdebug ((fname, "MEMwrite_format = <0x%.8x>\n", status));
        ERRload_struct (NFI, NFI_E_MEM, "%s%x", "MEMwrite_format", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_MEM);
      }

    if ((status = MEMwrite_format
        (*buffer, "n_minvalue", "char(40)")) != MEM_S_SUCCESS)
      {
        _NFIdebug ((fname, "MEMwrite_format = <0x%.8x>\n", status));
        ERRload_struct (NFI, NFI_E_MEM, "%s%x", "MEMwrite_format", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_MEM);
      }

    if ((status = MEMwrite_format
        (*buffer, "n_maxvalue", "char(40)")) != MEM_S_SUCCESS)
      {
        _NFIdebug ((fname, "MEMwrite_format = <0x%.8x>\n", status));
        ERRload_struct (NFI, NFI_E_MEM, "%s%x", "MEMwrite_format", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_MEM);
      }

    if ((status = MEMwrite_format
        (*buffer, "n_value", "char(40)")) != MEM_S_SUCCESS)
      {
        _NFIdebug ((fname, "MEMwrite_format = <0x%.8x>\n", status));
        ERRload_struct (NFI, NFI_E_MEM, "%s%x", "MEMwrite_format", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_MEM);
      }

    if ((status = MEMwrite_format
        (*buffer, "n_filename", "char(14)")) != MEM_S_SUCCESS)
      {
        _NFIdebug ((fname, "MEMwrite_format = <0x%.8x>\n", status));
        ERRload_struct (NFI, NFI_E_MEM, "%s%x", "MEMwrite_format", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_MEM);
      }

    if ((status = MEMwrite_format
        (*buffer, "n_type", "char(1)")) != MEM_S_SUCCESS)
      {
        _NFIdebug ((fname, "MEMwrite_format = <0x%.8x>\n", status));
        ERRload_struct (NFI, NFI_E_MEM, "%s%x", "MEMwrite_format", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_MEM);
      }

    if ((status = MEMwrite_format
        (*buffer, "n_appname", "char(3)")) != MEM_S_SUCCESS)
      {
        _NFIdebug ((fname, "MEMwrite_format = <0x%.8x>\n", status));
        ERRload_struct (NFI, NFI_E_MEM, "%s%x", "MEMwrite_format", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_MEM);
      }

    if ((status = MEMwrite_format
        (*buffer, "n_apptype", "char(1)")) != MEM_S_SUCCESS)
      {
        _NFIdebug ((fname, "MEMwrite_format = <0x%.8x>\n", status));
        ERRload_struct (NFI, NFI_E_MEM, "%s%x", "MEMwrite_format", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_MEM);
      }

    _NFIdebug ((fname, " returning SUCCESS\n"));
    return (NFI_S_SUCCESS);
  }


long _NFFfind_attribute_name (buffer, row, name)
  MEMptr    buffer;
  int       row;
  char      **name;
  {
    auto    long    status;
    auto    char    **data_ptr;
    auto    short   offset;
    static  char    *fname = "_NFFfind_attribute_name";

    _NFIdebug ((fname, "row = <%d>\n", row));

    /*  Make sure the buffer is valid  */

    if (buffer == NULL)
      {
        _NFIdebug ((fname, "input buffer is NULL\n"));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (MEM_E_NULL_BUFFER);
      }

    /*  Look for a synonym first  */

    if ((status = _NFFfind_column_offset
        (buffer, "n_synonym", &offset)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFfind_column_offset = <0x%.8x>\n", status));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    data_ptr = (char **) buffer->data_ptr;

    if ((strcmp (data_ptr[row + offset], "")) != 0)
      {
        *name = data_ptr[row + offset];
        _NFIdebug ((fname, "name = <%s>\n", *name));
        _NFIdebug ((fname, " returning SUCCESS\n"));
        return (NFI_S_SUCCESS);
      }

    /*  Find the real attribute name  */

    if ((status = _NFFfind_column_offset
        (buffer, "n_name", &offset)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFfind_column_offset = <0x%.8x>\n", status));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    *name = data_ptr[row + offset];

    _NFIdebug ((fname, "name = <%s>\n", *name));

    _NFIdebug ((fname, " returning SUCCESS\n"));
    return (NFI_S_SUCCESS);
  }


long _NFFinit_rows (buffer, write_attr, row_array)
  MEMptr    buffer;
  char      *write_attr;  /*  "n_write" or "n_update"  */
  int       *row_array[];
  {
    auto    int     i;
    auto    int     row;
    auto    int     fields;
    auto    int     displayed;
    auto    long    status;
    auto    char    **data_ptr;
    auto    short   write_offset;
    static  char    *fname = "_NFFinit_rows";

    _NFIdebug ((fname, "write_attr = <%s>\n", write_attr));

    /*  Make sure the buffer is valid  */

    if (buffer == NULL)
      {
        _NFIdebug ((fname, "input buffer is NULL\n"));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (MEM_E_NULL_BUFFER);
      }

    if ((*row_array = (int *) malloc (buffer->rows * (sizeof (int)))) == NULL)
      {
        _NFIdebug ((fname,
            "malloc failed; size = <%d>\n", buffer->rows * (sizeof (int))));
        ERRload_struct
            (NFI, NFI_E_MALLOC, "%d", buffer->rows * (sizeof (int)));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_MALLOC);
      }

    if ((status = _NFFfind_column_offset
        (buffer, write_attr, &write_offset)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFfind_column_offset = <0x%.8x>\n", status));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    row = 0;
    displayed = 0;
    data_ptr = (char **) buffer->data_ptr;
    fields = buffer->columns * buffer->rows;
    for (i = 0; i < fields; i += buffer->columns, ++row)
      {
        /*  See if this attribute is to be shown  */

        if ((strcmp (data_ptr[i + write_offset], "Y")) != 0)
          {
            _NFIdebug ((fname, "Buffer row %d is NOT being displayed\n", row));
            (*row_array)[row] = -1;
          }
        else
          {
            _NFIdebug ((fname, "Buffer row %d IS being displayed\n", row));
            (*row_array)[row] = displayed;

            ++displayed;
          }
      }

    _NFIdebug ((fname, " returning SUCCESS\n"));
    return (NFI_S_SUCCESS);
  }


long _NFFinit_cols
(buffer, col_array, read_attr, write_attr, read_value, write_value)
  MEMptr    buffer;
  int       *col_array[];
  char      *read_attr;
  char      *write_attr;
  char      *read_value;
  char      *write_value;
  {
    auto    int     i;
    auto    int     fields;
    auto    int     column;
    auto    int     displayed;
    auto    long    status;
    auto    char    **data_ptr;
    auto    short   update_offset;
    static  char    *fname = "_NFFinit_cols";

    _NFIdebug ((fname, "read_attr = <%s>\n", read_attr));
    _NFIdebug ((fname, "read_value = <%s>\n", read_value));
    _NFIdebug ((fname, "write_attr = <%s>\n", write_attr));
    _NFIdebug ((fname, "write_value = <%s>\n", write_value));

    /*  Make sure the buffer is valid  */

    if (buffer == NULL)
      {
        _NFIdebug ((fname, "input buffer is NULL\n"));
        ERRload_struct (NFI, MEM_E_NULL_BUFFER, NULL);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (MEM_E_NULL_BUFFER);
      }

    if ((*col_array = (int *) malloc (buffer->rows * (sizeof (int)))) == NULL)
      {
        _NFIdebug ((fname,
            "malloc failed; size = <%d>\n", buffer->rows * (sizeof (int))));
        ERRload_struct
            (NFI, NFI_E_MALLOC, "%d", buffer->rows * (sizeof (int)));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_MALLOC);
      }

    if ((status = _NFFfind_column_offset
        (buffer, write_attr, &update_offset)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFfind_column_offset = <0x%.8x>\n", status));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    column = 0;
    displayed = 0;
    data_ptr = (char **) buffer->data_ptr;
    fields = buffer->columns * buffer->rows;
    for (i = 0; i < fields; i += buffer->columns, ++column)
      {
        /*  See if this attribute is to be shown  */

        if ((strcmp (data_ptr[i + update_offset], write_value)) != 0)
          {
            _NFIdebug ((fname, "Buffer column %d is NOT being displayed\n",
                column));
            (*col_array)[column] = -1;
          }
        else
          {
            _NFIdebug ((fname, "Buffer column %d IS being displayed\n",
                column));
            (*col_array)[column] = displayed;

            ++displayed;
          }
      }

    _NFIdebug ((fname, " returning SUCCESS\n"));
    return (NFI_S_SUCCESS);
  }


long _NFFfind_next_writable_row
(buffer, write_attr, write_value, current_row, next_row)
  MEMptr    buffer;       /*  i  */
  char      *write_attr;  /*  i  */
  char      *write_value; /*  i  */
  int       current_row;  /*  i  */
  int       *next_row;    /*  o  */
  {
    auto    int     i;
    auto    int     start_row;
    auto    long    status;
    auto    long    fields;
    auto    char    **data_ptr;
    auto    short   offset;
    auto    short   found = FALSE;
    static  char    *fname = "_NFFfind_next_writable_row";

    _NFIdebug ((fname, "write_attr = <%s>\n", write_attr));
    _NFIdebug ((fname, "current_row = <0x%.8x>\n", current_row));

    /*  Make sure the buffer is valid  */

    if (buffer == NULL)
      {
        _NFIdebug ((fname, "input buffer is NULL\n"));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (MEM_E_NULL_BUFFER);
      }

    if ((status = _NFFfind_column_offset
        (buffer, write_attr, &offset)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFfind_column_offset = <0x%.8x>\n", status));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    data_ptr = (char **) buffer->data_ptr;
    fields = buffer->rows * buffer->columns;
    start_row = current_row * buffer->columns;

    for (i = start_row; i < fields; i += buffer->columns)
      {
        if ((strcmp (data_ptr[i + offset], write_value)) == 0)
          {
            *next_row = i / buffer->columns;
            found = TRUE;
            break;
          }
      }

    if (found == FALSE)
      {
        for (i = 0; i < fields; i += buffer->columns)
          {
            if ((strcmp (data_ptr[i + offset], write_value)) == 0)
              {
                *next_row = i / buffer->columns;
                found = TRUE;
                break;
              }
          }
      }

    if (found == FALSE)
      {
        _NFIdebug ((fname, "No rows are writable\n"));
        ERRload_struct (NFI, NFI_E_FAILURE, NULL);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FAILURE);
      }

    _NFIdebug ((fname, "next writable row = <%d>\n", *next_row));

    _NFIdebug ((fname, " returning SUCCESS\n"));
    return (NFI_S_SUCCESS);
  }


long _NFFfind_value_buffer (attr_list, value_list, attr_name, list_or_keyin)
  MEMptr    attr_list;
  MEMptr    value_list;
  char      *attr_name;
  char      *list_or_keyin;
  {
    auto    int     i;
    auto    int     data_offset;
    auto    int     total_data;
    auto    int     list_no;
    auto    long    status;
    auto    char    new_list_or_keyin[20];
    auto    char    **data_ptr;
    auto    short   offset;
    static  char    *fname = "_NFFfind_value_buffer";

    _NFIdebug ((fname, "attr_name = <%s>\n", attr_name));
    _NFIdebug ((fname, "list_or_keyin = <%s>\n", list_or_keyin));

    if ((status = _NFFfind_column_offset
        (attr_list, "n_name", &offset)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFfind_column_offset = <0x%.8x>\n", status));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    data_ptr = (char **) attr_list->data_ptr;
    total_data = attr_list->columns * attr_list->rows;
    data_offset = -1;

    for (i = 0; i < total_data; i += attr_list->columns)
      {
        if ((strcmp (data_ptr[i + offset], attr_name)) == 0)
          {
            data_offset = i;
            break;
          }
      }

    _NFIdebug ((fname, "data_offset = <%d>\n", data_offset));

    if (data_offset == -1)
      {
        _NFIdebug ((fname, "error finding <%s>\n", attr_name));
        ERRload_struct (NFI, NFI_E_BUFFER, NULL);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_BUFFER);
      }

    /*  Try to find the "new_" list_or_keyin first  */

    strcpy (new_list_or_keyin, "new_");
    strncat (new_list_or_keyin, list_or_keyin, sizeof (new_list_or_keyin) - 5);

    if ((status = _NFFfind_column_offset
        (attr_list, new_list_or_keyin, &offset)) != NFI_S_SUCCESS)
      {
        /*  It is NOT a "change" command  */

        ERRload_struct (NFI, NFI_S_SUCCESS, NULL);

        if ((status = _NFFfind_column_offset
            (attr_list, list_or_keyin, &offset)) != NFI_S_SUCCESS)
          {
            _NFIdebug ((fname, "_NFFfind_column_offset = <0x%.8x>\n", status));
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (status);
          }
      }
    else if ((strcmp (data_ptr[data_offset + offset], "")) == 0)
      {
        /*  This is a user-defined attribute that was
            added during THIS invocation of the command  */

        if ((status = _NFFfind_column_offset
            (attr_list, list_or_keyin, &offset)) != NFI_S_SUCCESS)
          {
            _NFIdebug ((fname, "_NFFfind_column_offset = <0x%.8x>\n", status));
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (status);
          }
      }

    list_no = atoi (data_ptr[data_offset + offset]);
    _NFIdebug ((fname, "buffer number = <%d>\n", list_no));

    if (list_no == -1)
      {
        ERRload_struct (NFI, NFI_I_NO_VALIDATION_ALLOWED, NULL);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_I_NO_VALIDATION_ALLOWED);
      }
    else if (list_no == 0)
      {
        ERRload_struct (NFI, NFI_E_FAILURE, NULL);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FAILURE);
      }

    if ((status = MEMreset_buffer_no
        (value_list, list_no)) != MEM_S_SUCCESS)
      {
        _NFIdebug ((fname, "MEMreset_buffer_no = <0x%.8x>\n", status));
        ERRload_struct (NFI, NFI_E_MEM, "%s%x", "MEMreset_buffer_no", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_MEM);
      }

    _NFIdebug ((fname, " returning SUCCESS\n"));
    return (NFI_S_SUCCESS);
  }


long _NFFfind_list_offsets (attr_list, syn_offset, name_offset)
  MEMptr    attr_list;
  short     *syn_offset;
  short     *name_offset;
  {
    auto    long    status;
    static  char    *fname = "_NFFfind_list_offsets";

    /*  Find out if this is an RPS select_list or an NFM attr_list  */

    if ((status = _NFFfind_column_offset
        (attr_list, "synonym1", syn_offset)) != NFI_S_SUCCESS)
      {
        /*  It is OK, reset the global error structure  */

        ERRreset_struct ();

        /*  It is an NFM attribute buffer  */

        if ((status = _NFFfind_column_offset
            (attr_list, "n_synonym", syn_offset)) != NFI_S_SUCCESS)
          {
            _NFIdebug ((fname, "_NFFfind_column_offset = <0x%.8x>\n", status));
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (status);
          }
        else
          {
            /*  It is OK, reset the global error structure  */

            ERRreset_struct ();

            /*  Find the attribute name offset in the attribute buffer  */

            if ((status = _NFFfind_column_offset
                (attr_list, "n_name", name_offset)) != NFI_S_SUCCESS)
              {
                _NFIdebug ((fname,
                    "_NFFfind_column_offset = <0x%.8x>\n", status));
                _NFIdebug ((fname, " returning FAILURE\n"));
                return (status);
              }
          }
      }
    else
      {
        /*  It is an RPS select_list, find the attribute name offset  */

        if ((status = _NFFfind_column_offset
            (attr_list, "attr_name", name_offset)) != NFI_S_SUCCESS)
          {
            _NFIdebug ((fname, "_NFFfind_column_offset = <0x%.8x>\n", status));
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (status);
          }
      }

    _NFIdebug ((fname, "synonym offset = <%d>\n", *syn_offset));
    _NFIdebug ((fname, "name offset = <%d>\n", *name_offset));

    _NFIdebug ((fname, " returning SUCCESS\n"));
    return (NFI_S_SUCCESS);
  }


long _NFFvalidate_datatype (datatype, width)
  char    *datatype;
  int     *width;
  {
    auto    int     i;
    auto    char    size[20];
    static  char    *fname = "_NFFvalidate_datatype";

    _NFIdebug ((fname, "datatype = <%s>\n", datatype));

    if ((strcmp (datatype, "integer")) == 0)
        *width = 15;
    else if ((strcmp (datatype, "smallint")) == 0)
        *width = 15;
    else if ((strcmp (datatype, "double")) == 0)
        *width = 30;
    else if ((strcmp (datatype, "real")) == 0)
        *width = 30;
    else if ((strcmp (datatype, "timestamp")) == 0)
        *width = 19;
    else if ((strncmp (datatype, "char(", 5)) == 0)
      {
        /*  Make sure there is a right paren  */

        if (datatype[strlen (datatype) - 1] != ')')
          {
            _NFIdebug ((fname, "no right paren for char datatype\n"));
            ERRload_struct (NFI, NFI_E_INVALID_DATATYPE, "%s", datatype);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_INVALID_DATATYPE);
          }

        for (i = 5; i < strlen (datatype) - 1; ++i)
          {
            if ((isdigit (datatype[i])) == 0)
              {
                _NFIdebug ((fname, "digit <%d> is NOT numeric\n", i));
                ERRload_struct (NFI, NFI_E_INVALID_DATATYPE, "%s", datatype);
                _NFIdebug ((fname, " returning FAILURE\n"));
                return (NFI_E_INVALID_DATATYPE);
              }
          }

/* Added condition to test whether the size of 'datatype' is has exceeded 
   the size of the array 'size'                -Jujare  05-Apr-1995  */

        if ( (strlen(&datatype[5])-1) > sizeof(size) )
        {
           _NFIdebug ((fname, "datatype size has exceeded the limit [%d]\n", sizeof(size)-1));
           ERRload_struct (NFI, NFI_E_INVALID_DATATYPE, "%s", datatype);
           _NFIdebug ((fname, " returning FAILURE\n"));
           return (NFI_E_INVALID_DATATYPE);
         }
             
        strncpy (size, &datatype[5], strlen (&datatype[5]) - 1);
        *width = atoi (size);

/* Added condition to test whether the integer represented by 'datatype' 
   has exceeded INT_MAX                          -Jujare  05-Apr-1995  */

        if (*width == INT_MAX) 
        {
           _NFIdebug ((fname, "datatype size has exceeded the limit [%d]\n",INT_MAX));
           ERRload_struct (NFI, NFI_E_INVALID_DATATYPE, "%s", datatype);
           _NFIdebug ((fname, " returning FAILURE\n"));
           return (NFI_E_INVALID_DATATYPE);
        }
      }
    else
      {
        *width = 0;
        _NFIdebug ((fname, "unrecognized datatype\n"));
        ERRload_struct (NFI, NFI_E_INVALID_DATATYPE, "%s", datatype);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_INVALID_DATATYPE);
      }

    _NFIdebug ((fname, " returning SUCCESS\n"));
    return (NFI_S_SUCCESS);
  }


void _NFFclear_msg (form)
  Form    form;
  {
    auto    int     status;
    auto    int     attr_mask = 0;
    auto    int     bx_size, by_size;
    static  char    *fname = "_NFFclear_msg";

    /*  Make sure the form is valid  */

    if (form == NULL)
      {
        _NFIdebug ((fname, "form is NULL\n"));
        _NFIdebug ((fname, " returning ...\n"));
        return;
      }

    if (form != NFFglobal.forms[MAIN_LABEL])
      {
        /*  Find out if the scroll buttons are displayed  */

        if ((status = FIg_get_attr
            (form, LEFT_SCROLL_BUTTON, &attr_mask)) != FI_SUCCESS)
          {
            _NFIdebug ((fname, "FIg_get_attr = <%d>\n", status));
            return;
          }

        if ((attr_mask & FI_NOT_DISPLAYED) == 0)
          {
            /*  The bezel area is short 50 pixels  */

            FIg_get_size (form, ERROR_BEZEL, &bx_size, &by_size);
            bx_size += 50;
            FIg_erase (form, ERROR_BEZEL);
            FIg_set_size (form, ERROR_BEZEL, bx_size, by_size);

            /*  Erase the scroll buttons  */

            FIg_erase (form, LEFT_SCROLL_BUTTON);
            FIg_erase (form, RIGHT_SCROLL_BUTTON);

            FIg_display (form, ERROR_BEZEL);
          }

        if ((status = FIg_erase (form, ERROR_TEXT)) != FI_SUCCESS)
          {
            _NFIdebug ((fname, "FIg_erase = <%d>\n", status));
            return;
          }

        if ((status = FIg_set_text (form, ERROR_TEXT, "")) != FI_SUCCESS)
          {
            _NFIdebug ((fname, "FIg_set_text = <%d>\n", status));
            return;
          }

        if ((status = FIg_display (form, ERROR_TEXT)) != FI_SUCCESS)
            _NFIdebug ((fname, "FIg_display = <%d>\n", status));
      }
    else
      {
        if ((status = FIg_set_text (form, ERROR_BEZEL, "")) != FI_SUCCESS)
          {
            _NFIdebug ((fname, "FIg_set_text = <%d>\n", status));
            return;
          }

        if ((status = FIg_display (form, ERROR_BEZEL)) != FI_SUCCESS)
            _NFIdebug ((fname, "FIg_display = <%d>\n", status));
      }

    return;
  }


long _NFFget_attr_info (attr_list, attrname, offset, n_read, n_write,
                         type, length)
  MEMptr    attr_list;       /* "I"  :                                */
  char      *attrname;       /* "I"  : n_name for the attribute       */
  int       *offset;         /* "O"  :                                */
  char      *n_read;         /* "O"  : "Y" readable attribute or "N"  */ 
  char      *n_write;        /* "O"  : "Y" writeable attribute or "N" */ 
  char      *type;           /* "O"  : datatype of the attribute.     */
  int       *length;         /* "O"  : length if char otherwise 0     */   
  {
    auto    int     a, b, c, d, i, j, x, y, count;
    auto    char    **column, **a_data;
    auto    char    wsize[40];
    auto    short   found = FALSE;
    static  char    *fname = "_NFFget_attr_info";
        
    _NFIdebug ((fname, "attrname = <%s>\n", attrname));

    *offset = -1;
    strcpy (n_read, "");
    strcpy (n_write, "");
    strcpy (type, "");
    *length = 0;

    if (attr_list == NULL)
      {
        _NFIdebug ((fname, "attr_list is NULL\n"));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (MEM_E_NULL_BUFFER);
      }

    column = (char **) attr_list->column_ptr;

    a = -1; b = -1; c = -1; d = -1;

    for (y = 0; y < attr_list->columns; ++y)
      {
             if (strcmp (column[y], "n_name") == 0)      a = y;
        else if (strcmp (column[y], "n_read") == 0)      b = y;
        else if (strcmp (column[y], "n_write") == 0)     c = y;
        else if (strcmp (column[y], "n_datatype") == 0)  d = y;
      }

    if (a < 0 || b < 0 || c < 0 || d < 0)
      {
         ERRload_struct (NFI, NFI_E_BUFFER, NULL);
         _NFIdebug ((fname, " corrupted attr_list\n"));
         _NFIdebug ((fname, " returning FAILURE\n"));
         return (NFI_E_BUFFER);
      }

    a_data = (char **) attr_list->data_ptr;

    for (x = 0; x < attr_list->rows; ++x)
      {
         count = attr_list->columns * x; 
         if (strcmp (a_data[count + a], attrname) == 0) 
           {
              found = TRUE;
              *offset = x;   /* attr column in data_list . */ 
              strcpy (n_read,  a_data[count + b]);
              strcpy (n_write, a_data[count + c]);

              strcpy (type,  a_data[count + d]);
              if (strncmp (type, "char", 4) == 0)
              {
                 wsize[0] = 0;
                 i = 4;
                 while ((type[i] != '\0') && (! isdigit (type[i])))
                   ++i;
                 if (type[i] != '\0')
                 {
                    j = 0;
                    while ((type[i] != '\0') && (isdigit (type[i])))
                    {
                      wsize[j] = type[i];
                      ++i;
                      ++j;
                    }
                    wsize[j] = 0;  /* add null character to end of string. */
                    if (strlen (wsize))
                       *length = atoi (wsize);
                 }
                 if (strlen (wsize))
                     *length = atoi (wsize);
              } 
              break;
           }
        }

        if (!found)
        {
           ERRload_struct (NFI, NFI_E_BUFFER, NULL);
           _NFIdebug ((fname, "attribute <%s> not in attr_list\n", attrname));
           _NFIdebug ((fname, " returning FAILURE\n"));
           return (NFI_E_BUFFER);
        } 

    _NFIdebug ((fname, "offset   = <%d>\n", *offset));
    _NFIdebug ((fname, "n_read   = <%s>\n", n_read));
    _NFIdebug ((fname, "n_write  = <%s>\n", n_write));
    _NFIdebug ((fname, "datatype = <%s>\n", type));
    _NFIdebug ((fname, "length   = <%d>\n", *length));
    _NFIdebug ((fname, "returning SUCCESS\n"));
    return (NFI_S_SUCCESS);
  }


void _NFFfind_active_data (buffer, attribute, data)
  MEMptr    buffer;
  char      *attribute;
  char      *data;
  {
    auto    int     i;
    auto    int     column = -1;
    auto    char    **data_ptr;
    auto    char    **column_ptr;
    static  char    *fname = "_NFFfind_active_data";

    _NFIdebug ((fname, "entering for attribute <%s>\n", attribute));

    column_ptr = (char **) buffer->column_ptr;

    for (i = 0; i < buffer->columns; ++i)
      {
        if ((strcmp (column_ptr[i], attribute)) == 0)
          {
            column = i;
            break;
          }
      }

    if (column == -1)
      {
        _NFIdebug ((fname, "%s not found in data_list\n", attribute));
        _NFIdebug ((fname, "returning ...\n"));
        return;
      }

    data_ptr = (char **) buffer->data_ptr;

    strcpy (data, data_ptr[column]);

    _NFIdebug ((fname, "returning ...\n"));
    return;
  }


void _NFFprocess_event (refresh_event)
  int    refresh_event;
  {
    auto    int    event;
#ifndef XWINDOWS
    JNL_inq_events (&event);
#endif
    FI_process_event (refresh_event);
  }

void  _NFFcheck_two_tics( in, out )
  char *in;
  char *out;
{
    static char *fname = "_NFFcheck_two_tics";

    _NFIdebug(( fname, "Entering ...\n" ));
    _NFIdebug(( fname, "in string <%s>\n", in ));

    while( *in )
    {
        if( (*in == '\'') && (*(in+1) == '\'') )
        {
            ++in;
        }
        *out++ = *in++;
    }
    *out = '\0';

    _NFIdebug(( fname, "out string <%s>\n", out ));
}
