
/* machine.h included to take care of platform variencies MVR 23 Dec 1993 */
#include "machine.h"

#include "NFF.h"
#include "NFFconfirm.h"

/*  Global NFF structure  */

extern struct NFFglobal_st NFFglobal;

#define LEFT_MARGIN   20
#define RIGHT_MARGIN  20

long _NFFadjust_confirm_form (form)
  Form    form;
  {
    auto    int     form_xsize;
    auto    int     form_ysize;
    auto    int     form_width;
    auto    int     form_height;
    auto    int     button_x, button_y;
    auto    int     button_width;
    auto    int     button_height;
    auto    int     first_line_width;
    auto    int     first_line_height;
    auto    int     cmd_info_width;
    auto    int     cmd_info_height;
    auto    long    status;
    static  char    *fname = "_NFFadjust_confirm_form";

    if ((status = (long) FIf_get_size
        (form, &form_xsize, &form_ysize)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIf_get_size = <%d>\n", status));
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIf_get_size", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    if ((status = (long) FIg_get_size (form,
        FIRST_LINE, &first_line_width, &first_line_height)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIg_get_size = <%d>\n", status));
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_get_size", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    if ((status = (long) FIg_get_size (form,
        COMMAND_INFO, &cmd_info_width, &cmd_info_height)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIg_get_size = <%d>\n", status));
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_get_size", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    form_height = form_ysize;

    form_width = LEFT_MARGIN + RIGHT_MARGIN;

    if (first_line_width > cmd_info_width)
        form_width += first_line_width;
    else
        form_width += cmd_info_width;

    /*  Set a minimum width for the form  */

    if (form_width < form_xsize)
        form_width = form_xsize;

    /*  Set the form width based on the longest text line  */

    if ((status = FIf_set_size (form, form_width, form_height)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIf_set_size = <%d>\n", status));
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIf_set_size", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    /*  Adjust the location of the CANCEL button  */

    if ((status = (long) FIg_get_location
        (form, CANCEL_BUTTON, &button_x, &button_y)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIg_get_location = <%d>\n", status));
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_get_location", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    if ((status = (long) FIg_set_location
        (form, CANCEL_BUTTON, LEFT_MARGIN, button_y)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIg_set_location = <%d>\n", status));
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_set_location", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    /*  Adjust the location of the OK button  */

    if ((status = (long) FIg_get_size
        (form, OK_BUTTON, &button_width, &button_height)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIg_get_size = <%d>\n", status));
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_get_size", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    if ((status = (long) FIg_get_location
        (form, OK_BUTTON, &button_x, &button_y)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIg_get_location = <%d>\n", status));
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_get_location", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    if ((status = (long) FIg_set_location (form, OK_BUTTON,
        form_width - RIGHT_MARGIN - button_width, button_y)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIg_set_location = <%d>\n", status));
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_set_location", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    /*  Adjust the length of the error bezel  */

    if ((status = (long) FIg_get_size
        (form, ERROR_BEZEL, &button_width, &button_height)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIg_get_size = <%d>\n", status));
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_get_size", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    if ((status = (long) FIg_set_size (form, ERROR_BEZEL,
        form_width - RIGHT_MARGIN, button_height)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIg_set_size = <%d>\n", status));
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_set_size", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    if ((status = _NFFcenter_gadget (form, CAUTION_TEXT)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFcenter_gadget = <0x%.8x>\n", status));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    if ((status = _NFFcenter_gadget (form, FIRST_LINE)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFcenter_gadget = <0x%.8x>\n", status));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    if ((status = _NFFcenter_gadget (form, COMMAND_INFO)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFcenter_gadget = <0x%.8x>\n", status));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    if ((status = _NFFcenter_gadget (form, ERROR_BEZEL)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFcenter_gadget = <0x%.8x>\n", status));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    if ((status = _NFFcenter_form (form, -1, Y_FORM_POS)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFcenter_form = <0x%.8x>\n", status));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    _NFIdebug ((fname, " returning SUCCESS\n"));
    return (NFI_S_SUCCESS);
  }
