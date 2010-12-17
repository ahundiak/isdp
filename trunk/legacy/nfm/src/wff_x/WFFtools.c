#include "machine.h"
#include "WFF.h"
#include "WFFlabels.h"
#include "WFFpersist.h"

/*  Global WFF structure  */

extern struct WFFglobal_st WFFglobal;

long _WFFcenter_form (form, xlocation, ylocation)
  Form   form;
  int    xlocation;  /*  i - if < 0, center along x axis  */
  int    ylocation;  /*  i - if < 0, center along y axis  */
  {
    static  char *fname = "_WFFcenter_form";

    int     vs, status;
    int     xlo, ylo;
    int     xpos, ypos;
    int     xsize, ysize;
    int     main_xsize, main_ysize;
    int     scr_height;
    int     scr_width;
    struct  scr_info info[MAX_SCREENS];

    /*  Make sure the form is valid  */

    if (form == NULL)
      {
        _NFIdebug ((fname, "form is NULL\n"));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_NULL_FORM);
      }

    /*  Get information about the current virtual screen  */

#ifndef XWINDOWS

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
    scr_height = XDisplayHeight( WFFglobal.display, 0 );
    scr_width  = XDisplayWidth ( WFFglobal.display, 0 );
#endif

    /*  Calculate the location to center the form on the screen  */

    xlo = scr_width / 2;
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
        if (WFFglobal.main_form != NULL)
          {
            /*  Center the form on the main form  */

            _NFIdebug ((fname, "x: centering form on the main form\n"));

            if ((status = FIf_get_size (WFFglobal.main_form,
                &main_xsize, &main_ysize)) != FI_SUCCESS)
              {
                _NFIdebug ((fname, "FIf_get_size = <%d>\n", status));
                ERRload_struct
                    (NFI, NFI_E_FORM, "%s%d", "FIf_get_size", status);
                _NFIdebug ((fname, " returning FAILURE\n"));
                return (NFI_E_FORM);
              }

            if ((status = FIf_get_location
                (WFFglobal.main_form, &xpos, &ypos)) != FI_SUCCESS)
              {
                _NFIdebug ((fname, "FIf_get_location = <0x%.8x>\n", status));
                ERRload_struct
                    (NFI, NFI_E_FORM, "%s%d", "FIf_get_location", status);
                _NFIdebug ((fname, " returning FAILURE\n"));
                return (NFI_E_FORM);
              }

#ifdef OS_INTELSOL
            xlo = scr_width -  ( main_xsize + PANEL_MENU_WIDTH + 5 );
#else
            xlo = (xpos + (main_xsize / 2)) - (xsize / 2);
#endif
          }
        else
          {
            /*  Center the form on the screen  */

            _NFIdebug ((fname, "x: centering form on the screen\n"));

            xlo -= (xsize / 2);
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
        else if (WFFglobal.main_form != NULL)
          {
            /*  Position the form below the BAR_MENU  */

            _NFIdebug ((fname, "y: positioning form below the BAR_MENU\n"));

            ylo = WFFglobal.bar_menu_height + 5;
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


long _WFFcenter_gadget (form, label)
  Form   form;
  int    label;
  {
    int     xpos, ypos;
    int     fx_size, fy_size;
    int     gx_size, gy_size;

    static  char *fname = "_WFFcenter_gadget";

    /*  Make sure the form is valid  */

    if (form == NULL)
      {
        _NFIdebug ((fname, "form is NULL\n"));
/*
        ERRload_struct (NFI, NFI_E_NULL_FORM, NULL);
*/
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_NULL_FORM);
      }

    /*  Get the size of the form  */

    FIf_get_size (form, &fx_size, &fy_size);

    /*  Center the gadget on the form  */

    FIg_get_location (form, label, &xpos, &ypos);
    FIg_get_size (form, label, &gx_size, &gy_size);

    xpos = (fx_size / 2) - (gx_size / 2);

    FIg_set_location (form, label, xpos, ypos);

    _NFIdebug ((fname, " returning SUCCESS\n"));
    return (NFI_S_SUCCESS);
  }


long _WFFmessage (int message_no, char *message_fmt, ...)
  {
    int     attr_mask;
    int     current_form_is_displayed = 0;
    int     main_form_is_displayed = 0;

    va_list vars;

    static  char *fname = "_WFFmessage";

    _NFIdebug ((fname, "message_no = <0x%.8x>\n", message_no));
    if (message_fmt != NULL)
        _NFIdebug ((fname, "message_fmt = <%s>\n", message_fmt));

    /*  Figure out which form to put the message on  */

    if (WFFglobal.current_form != NULL)
      {
        /*  See if the current form is displayed or not  */

        FIf_is_displayed (WFFglobal.current_form, &current_form_is_displayed);
      }
    else if (WFFglobal.main_form != NULL)
      {
        /*  See if the main form is displayed or not  */

        FIf_is_displayed (WFFglobal.main_form, &main_form_is_displayed);

        if (main_form_is_displayed)
          {
            /*  See if the main form is enabled or not
                (just check the ERROR_BUTTON since it
                will be disabled if the form is disabled)  */

            FIg_get_attr (WFFglobal.main_form, ERROR_BUTTON, &attr_mask);

            if (attr_mask & FI_NOT_ENABLED)
                main_form_is_displayed = FALSE;
          }
      }

    va_start (vars, message_fmt);

    if (current_form_is_displayed)
      {
        /*  Put the message on the current form  */

	_NFIdebug(( fname, "Putting message on current form\n" ));

        _WFFform_message
            (WFFglobal.current_form, message_no, message_fmt, vars);

        WFFglobal.where_message_is = WFF_CURRENT_FORM;
      }
    else if (main_form_is_displayed)
      {
        /*  Put the message on the main form  */
	
	_NFIdebug(( fname, "Putting message on main form\n" ));

        _WFFform_message
            (WFFglobal.main_form, message_no, message_fmt, vars);

        WFFglobal.where_message_is = WFF_MAIN_FORM;
      }
    else
      {
        /*  Bring up the message form  */
	
	_NFIdebug(( fname, "Bringing up the message form\n" ));

        _WFFmessage_old (message_no, message_fmt, vars);

        WFFglobal.where_message_is = WFF_MESSAGE_FORM;
      }

    va_end (vars);

    _NFIdebug ((fname, " returning SUCCESS\n"));
    return (NFI_S_SUCCESS);
  }


long _WFFmessage_old (int message_no, char *message_fmt, va_list vars)
  {
    int      status;
    int      xwidth;
    int      xsize, ysize;
    int      form_xsize, form_ysize;
    int      xsym_size, ysym_size;

    static   char message[512] = "";
    static   char *fname = "_WFFmessage_old";

    WFFglobal.message_form = NULL;

    _NFIdebug ((fname, "message_no = <0x%.8x>\n", message_no));
    if (message_fmt != NULL)
        _NFIdebug ((fname, "message_fmt = <%s>\n", message_fmt));

    /*  Translate the message number into a string  */

    if ((status = UMSGetByNumVar
        (message, message_no, message_fmt, vars)) != UMS_S_SUCCESS)
      {
        _NFIdebug ((fname, "UMSGetByNumVar = <%d>\n", status));
        ERRload_struct (NFI, NFI_E_UMS, "%s%d", "UMSGetByNumVar", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_UMS);
      }

    _NFIdebug ((fname, "message = <%s>\n", message));

    /*  Create the message form  */

    if ((status = FIf_new (0, MSG_FORM,
        NULL, &(WFFglobal.message_form))) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIf_new = <%d>\n", status));
        WFFglobal.message_form = NULL;
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIf_new", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    /*  Put the message on the form  */

    if ((status = FIg_set_text
        (WFFglobal.message_form, MSG_FORM_TEXT, message)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIg_set_text = <0x%.8x>\n", status));
        if (WFFglobal.message_form != NULL)
	    FIf_delete (WFFglobal.message_form);
        WFFglobal.message_form = NULL;
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_set_text", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    /*  Set the size of the form based on the text length  */

    if ((status = FIf_get_size
        (WFFglobal.message_form, &form_xsize, &form_ysize)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIf_get_size = <%d>\n", status));
        if (WFFglobal.message_form != NULL)
            FIf_delete (WFFglobal.message_form);

        WFFglobal.message_form = NULL;
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIf_get_size", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    if ((status = FIg_get_size
        (WFFglobal.message_form, MSG_FORM_TEXT, &xsize, &ysize)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIg_get_size = <%d>\n", status));
        if (WFFglobal.message_form != NULL)
            FIf_delete (WFFglobal.message_form);
        WFFglobal.message_form = NULL;
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_get_size", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    if ((status = FIg_get_size (WFFglobal.message_form,
        MSG_FORM_SYMBOL, &xsym_size, &ysym_size)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIg_get_size = <%d>\n", status));
        if (WFFglobal.message_form != NULL)
            FIf_delete (WFFglobal.message_form);
        WFFglobal.message_form = NULL;
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_get_size", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    /*  Leave the same amount of room at the
        end of the text as the width of the symbol  */

    xwidth = xsize + (xsym_size * 4);

    if ((status = FIf_set_size
        (WFFglobal.message_form, xwidth, form_ysize)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIf_set_size = <%d>\n", status));
        if (WFFglobal.message_form != NULL)
            FIf_delete (WFFglobal.message_form);
        WFFglobal.message_form = NULL;
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIf_set_size", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    /*  Center the form  */

    _WFFcenter_form (WFFglobal.message_form, -1, Y_FORM_POS);

    /*  Display the form  */

    if ((status = FIf_display (WFFglobal.message_form)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIf_display = <%d>\n", status));
        if (WFFglobal.message_form != NULL)
            FIf_delete (WFFglobal.message_form);
        WFFglobal.message_form = NULL;
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIf_display", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    _NFIdebug ((fname, " returning SUCCESS\n"));
    return (NFI_S_SUCCESS);
  }


long _WFFerase_message ()
  {
    static    char *fname = "_WFFerase_message";

    _NFIdebug ((fname, "entering ...\n"));

    /*  Figure out which form the message is on  */

    switch (WFFglobal.where_message_is)
      {
        case WFF_MESSAGE_FORM:

            /*  Delete the message form  */

            _WFFerase_message_old ();

            break;

        case WFF_CURRENT_FORM:

            /*  Erase the message on the current form  */

            _WFFclear_msg (WFFglobal.current_form);

            break;

        case WFF_MAIN_FORM:

            /*  Erase the message on the main form  */

            _WFFclear_msg (WFFglobal.main_form);

            break;
      }

    _NFIdebug ((fname, " returning SUCCESS\n"));
    return (NFI_S_SUCCESS);
  }


long _WFFerase_message_old ()
  {
    int     status;

    static  char *fname = "_WFFerase_message_old";

    _NFIdebug ((fname, "entering ...\n"));

    /*  Delete the message form  */

    if (WFFglobal.message_form == NULL)
      {
        _NFIdebug ((fname, "message_form is NULL\n"));
        _NFIdebug ((fname, " returning SUCCESS\n"));
        return (NFI_S_SUCCESS);
      }

    if ((status = FIf_delete (WFFglobal.message_form)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIf_delete = <%d>\n", status));
        WFFglobal.message_form = NULL;
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIf_delete", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    WFFglobal.message_form = NULL;

    _NFIdebug ((fname, " returning SUCCESS\n"));
    return (NFI_S_SUCCESS);
  }


long _WFFerror_message (form)
  Form    form;
  {
    int     status;
    int     bx_size, by_size;
    int     bx_pos, by_pos;
    int     tx_size, ty_size;
    int     tx_pos, ty_pos;
    int     text_label = ERROR_TEXT;
    int     bezel_label = ERROR_BEZEL;
    int     error_label = ERROR_BUTTON;
    int     attr_mask;
    char    *visible_msg;
    short   full_size = FALSE;

    static  long beginning_char = 0;
    static  long ending_char = 0;
    static  char message[4096] = "";
    static  char *fname = "_WFFerror_message";

    /*  Make sure the form is valid  */

    if (form == NULL)
      {
        _NFIdebug ((fname, "form is NULL\n"));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_NULL_FORM);
      }

    /*  Let the error processor retrieve the message  */

    if ((status = ERRget_message (message)) != ERR_S_SUCCESS)
      {
        _NFIdebug ((fname, "ERRget_message = <0x%.8x>\n", status));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    _NFIdebug ((fname, "message = <%s>\n", message));

    if (form != WFFglobal.main_form)
      {
        /*  Initialize the beginning and ending character positions  */

        beginning_char = ending_char = 0;

        FIg_erase (form, text_label);
        FIg_set_text (form, text_label, message);

        /*  Find out if the scroll buttons are displayed  */

        FIg_get_attr (form, LEFT_SCROLL_BUTTON, &attr_mask);
        if (attr_mask & FI_NOT_DISPLAYED)
          {
            /*  The bezel area is full size  */

            _NFIdebug ((fname, "The Bezel area is full size\n"));
            full_size = TRUE;
          }
        else
          {
            /*  The bezel area is short 50 pixels  */

            _NFIdebug ((fname, "The scroll buttons are displayed\n"));
            full_size = FALSE;
          }

        FIg_get_size (form, bezel_label, &bx_size, &by_size);
        FIg_get_size (form, text_label, &tx_size, &ty_size);
        FIg_get_location (form, bezel_label, &bx_pos, &by_pos);
        FIg_get_location (form, text_label, &tx_pos, &ty_pos);

        _NFIdebug ((fname, "tx_size = <%d>\n", tx_size));
        _NFIdebug ((fname, "bx_size = <%d>\n", bx_size));

        if ((tx_size <= (bx_size + 30)) && (full_size == TRUE))
          {
            /*  Center the text on the bezel  */

            _NFIdebug ((fname, "Center the text on the full bezel\n"));
            tx_pos = (bx_pos + (bx_size / 2)) - (tx_size / 2);
          }
        else if ((tx_size <= (bx_size + 80)) && (full_size == FALSE))
          {
            bx_size += 50;
            FIg_erase (form, bezel_label);
            FIg_set_size (form, bezel_label, bx_size, by_size);

            /*  Center the text on the bezel  */

            tx_pos = (bx_pos + (bx_size / 2)) - (tx_size / 2);

            FIg_erase (form, LEFT_SCROLL_BUTTON);
            FIg_erase (form, RIGHT_SCROLL_BUTTON);
            _NFIdebug ((fname, "Center the text on the full bezel\n"));
          }
        else
          {
            /*  Left justify the text on the bezel, shorten
                the bezel area, and display the scroll buttons  */

            tx_pos = bx_pos + 10;

            if (full_size == TRUE)
              {
                FIg_erase (form, bezel_label);
                bx_size -= 50;
                FIg_set_size (form, bezel_label, bx_size, by_size);
                FIg_display (form, LEFT_SCROLL_BUTTON);
                FIg_display (form, RIGHT_SCROLL_BUTTON);
              }

            if ((visible_msg = (char *) malloc (strlen (message) + 1)) == NULL)
              {
                _NFIdebug ((fname,
                    "malloc failed; size = <%d>\n", strlen (message) + 1));
                ERRload_struct (NFI, NFI_E_MALLOC, "%d", strlen (message) + 1);
                _NFIdebug ((fname, " returning FAILURE\n"));
                return (status);
              }

            /*  Try a best guess at how many characters to display  */

            ending_char = strlen (message) * (bx_size - 30) / tx_size;

            strncpy (visible_msg, message, ending_char);
            visible_msg[ending_char] = NULL;
            _NFIdebug ((fname, "visible_msg = <%s>\n", visible_msg));
            FIg_set_text (form, text_label, visible_msg);

            if (visible_msg) free (visible_msg);
            _NFIdebug ((fname, "Center the text on bezel with scrolling\n"));
          }

        FIg_set_location (form, text_label, tx_pos, ty_pos);
        FIg_set_user_pointer (form, text_label, message);
        FIg_set_user_pointer (form,
            LEFT_SCROLL_BUTTON, (char *) &beginning_char);
        FIg_set_user_pointer (form,
            RIGHT_SCROLL_BUTTON, (char *) &ending_char);
        FIg_display (form, bezel_label);
        FIg_display (form, text_label);
      }
    else
      {
        /*  Put the message on the error button  */

        FIg_erase (form, error_label);
        FIg_set_text (form, error_label, message);
        FIg_display (form, error_label);
        _NFIdebug ((fname, "Put the text on message error button\n"));
      }

    _NFIdebug ((fname, " returning SUCCESS\n"));
    return (NFI_S_SUCCESS);
  }


long _WFFform_message
(Form form, int message_no, char *message_fmt, va_list vars)
  {
    int      status;
    int      bx_size, by_size;
    int      bx_pos, by_pos;
    int      tx_size, ty_size;
    int      tx_pos, ty_pos;
    int      text_label = ERROR_TEXT;
    int      bezel_label = ERROR_BEZEL;
    int      error_label = ERROR_BUTTON;
    int      attr_mask = 0;
    short    full_size = FALSE;
    char     *visible_msg;

    static  long beginning_char = 0;
    static  long ending_char = 0;
    static  char message[1024] = "";

    static   char *fname = "_WFFform_message";

    /*  Make sure the form is valid  */

    if (form == NULL)
      {
        _NFIdebug ((fname, "form is NULL\n"));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_NULL_FORM);
      }

    _NFIdebug ((fname, "message_no = <0x%.8x>\n", message_no));
    if (message_fmt != NULL)
        _NFIdebug ((fname, "message_fmt = <%s>\n", message_fmt));

    if ((status = UMSGetByNumVar
        (message, message_no, message_fmt, vars)) != UMS_S_SUCCESS)
      {
        _NFIdebug ((fname, "UMSGetByNumVar = <0x%.8x>\n", status));
        va_end (vars);
        ERRload_struct (NFI, NFI_E_UMS, "%s%d", "UMSGetByNumVar", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_UMS);
      }

    _NFIdebug ((fname, "message = <%s>\n", message));

    if (form != WFFglobal.main_form)
      {
        /*  Initialize the beginning and ending character positions  */

        beginning_char = ending_char = 0;

        FIg_erase (form, text_label);
        FIg_set_text (form, text_label, message);

        /*  Find out if the scroll buttons are displayed  */

        FIg_get_attr (form, LEFT_SCROLL_BUTTON, &attr_mask);
        if (attr_mask & FI_NOT_DISPLAYED)
          {
            /*  The bezel area is full size  */

            _NFIdebug ((fname, "The Bezel area is full size\n"));
            full_size = TRUE;
          }
        else
          {
            /*  The bezel area is short 50 pixels  */

            _NFIdebug ((fname, "The scroll buttons are displayed\n"));
            full_size = FALSE;
          }

        FIg_get_size (form, bezel_label, &bx_size, &by_size);
        FIg_get_size (form, text_label, &tx_size, &ty_size);
        FIg_get_location (form, bezel_label, &bx_pos, &by_pos);
        FIg_get_location (form, text_label, &tx_pos, &ty_pos);

        _NFIdebug ((fname, "tx_size = <%d>\n", tx_size));
        _NFIdebug ((fname, "bx_size = <%d>\n", bx_size));

        /* if ((tx_size <= (bx_size + 30)) && (full_size == TRUE)) */
        if ((tx_size <= (bx_size - 20)) && (full_size == TRUE))
          {
            /*  Center the text on the bezel  */

            _NFIdebug ((fname, "Center the text on the full bezel\n"));
            tx_pos = (bx_pos + (bx_size / 2)) - (tx_size / 2);
          }
        else if ((tx_size <= (bx_size + 80)) && (full_size == FALSE))
          {
            bx_size += 50;
            FIg_erase (form, bezel_label);
            FIg_set_size (form, bezel_label, bx_size, by_size);

            /*  Center the text on the bezel  */

            tx_pos = (bx_pos + (bx_size / 2)) - (tx_size / 2);

            FIg_erase (form, LEFT_SCROLL_BUTTON);
            FIg_erase (form, RIGHT_SCROLL_BUTTON);
            _NFIdebug ((fname, "Center the text on the full bezel\n"));
          }
        else
          {
            /*  Left justify the text on the bezel, shorten
                the bezel area, and display the scroll buttons  */

            tx_pos = bx_pos + 10;

            if (full_size == TRUE)
              {
                FIg_erase (form, bezel_label);
                bx_size -= 50;
                FIg_set_size (form, bezel_label, bx_size, by_size);
                FIg_display (form, LEFT_SCROLL_BUTTON);
                FIg_display (form, RIGHT_SCROLL_BUTTON);
              }

            if ((visible_msg = (char *) malloc (strlen (message) + 1)) == NULL)
              {
                _NFIdebug ((fname,
                    "malloc failed; size = <%d>\n", strlen (message) + 1));
                ERRload_struct (NFI, NFI_E_MALLOC, "%d", strlen (message) + 1);
                _NFIdebug ((fname, " returning FAILURE\n"));
                return (status);
              }

            /*  Try a best guess at how many characters to display  */

            ending_char = strlen (message) * (bx_size - 30) / tx_size;

            strncpy (visible_msg, message, ending_char);
            visible_msg[ending_char] = NULL;
            _NFIdebug ((fname, "visible_msg = <%s>\n", visible_msg));
            FIg_set_text (form, text_label, visible_msg);

            if (visible_msg) free (visible_msg);
            _NFIdebug ((fname, "Center the text on bezel with scrolling\n"));
          }

        FIg_set_location (form, text_label, tx_pos, ty_pos);
        FIg_set_user_pointer (form, text_label, message);
        FIg_set_user_pointer (form,  
                              LEFT_SCROLL_BUTTON, (char *) &beginning_char);
        FIg_set_user_pointer (form,
                              RIGHT_SCROLL_BUTTON, (char *) &ending_char);
        FIg_display (form, bezel_label);
        FIg_display (form, text_label);
      }
    else
      {
        /*  Put the message on the error button (bezel_label)  */

        FIg_erase (form, error_label);
        FIg_set_text (form, error_label, message);
        FIg_display (form, error_label);
      }

    _NFIdebug ((fname, " returning SUCCESS\n"));
    return (NFI_S_SUCCESS);
  }


long _WFFfind_column_offset (buffer, attrname, offset)
  MEMptr   buffer;
  char     *attrname;
  short    *offset;
  {
    int     i;
    char    **column;
    short   found = FALSE;

    static  char *fname = "_WFFfind_column_offset";

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


long _WFFbuild_value_buffer (buffer)
  MEMptr    *buffer;
  {
    long    status;

    static  char *fname = "_WFFbuild_value_buffer";

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


long _WFFfind_attribute_name (buffer, row, name)
  MEMptr    buffer;
  int       row;
  char      **name;
  {
    long    status;
    char    **data_ptr;
    short   offset;

    static  char *fname = "_WFFfind_attribute_name";

    _NFIdebug ((fname, "row = <0x%.8x>\n", row));

    /*  Make sure the buffer is valid  */

    if (buffer == NULL)
      {
        _NFIdebug ((fname, "input buffer is NULL\n"));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (MEM_E_NULL_BUFFER);
      }

    /*  Look for a synonym first  */

    if ((status = _WFFfind_column_offset
        (buffer, "n_synonym", &offset)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_WFFfind_column_offset = <0x%.8x>\n", status));
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

    if ((status = _WFFfind_column_offset
        (buffer, "n_name", &offset)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_WFFfind_column_offset = <0x%.8x>\n", status));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    *name = data_ptr[row + offset];

    _NFIdebug ((fname, "name = <%s>\n", *name));

    _NFIdebug ((fname, " returning SUCCESS\n"));
    return (NFI_S_SUCCESS);
  }


long _WFFinit_rows (buffer, write_attr, row_array)
  MEMptr    buffer;
  char      *write_attr;  /*  "n_write" or "n_update"  */
  int       *row_array[];
  {
    int     i;
    int     row;
    int     fields;
    int     displayed;
    long    status;
    char    **data_ptr;
    short   write_offset;

    static  char *fname = "_WFFinit_rows";

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

    if ((status = _WFFfind_column_offset
        (buffer, write_attr, &write_offset)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_WFFfind_column_offset = <0x%.8x>\n", status));
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


long _WFFinit_cols
(buffer, col_array, read_attr, write_attr, read_value, write_value)
  MEMptr    buffer;
  int       *col_array[];
  char      *read_attr;
  char      *write_attr;
  char      *read_value;
  char      *write_value;
  {
    int     i;
    int     fields;
    int     column;
    int     displayed;
    long    status;
    char    **data_ptr;
    short   update_offset;

    static    char *fname = "_WFFinit_cols";

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

    if ((status = _WFFfind_column_offset
        (buffer, write_attr, &update_offset)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_WFFfind_column_offset = <0x%.8x>\n", status));
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


long _WFFfind_next_writable_row
(buffer, write_attr, write_value, current_row, next_row)
  MEMptr    buffer;       /*  i  */
  char      *write_attr;  /*  i  */
  char      *write_value; /*  i  */
  int       current_row;  /*  i  */
  int       *next_row;    /*  o  */
  {
    int     i;
    int     start_row;
    long    status;
    long    fields;
    char    **data_ptr;
    short   offset;
    short   found = FALSE;

    static  char *fname = "_WFFfind_next_writable_row";

    _NFIdebug ((fname, "write_attr = <%s>\n", write_attr));
    _NFIdebug ((fname, "current_row = <0x%.8x>\n", current_row));

    /*  Make sure the buffer is valid  */

    if (buffer == NULL)
      {
        _NFIdebug ((fname, "input buffer is NULL\n"));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (MEM_E_NULL_BUFFER);
      }

    if ((status = _WFFfind_column_offset
        (buffer, write_attr, &offset)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_WFFfind_column_offset = <0x%.8x>\n", status));
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


long _WFFfind_list_offsets (attr_list, syn_offset, name_offset)
  MEMptr    attr_list;
  short     *syn_offset;
  short     *name_offset;
  {
    long    status;

    static  char *fname = "_WFFfind_list_offsets";

    /*  Find out if this is an RPS select_list or an NFM attr_list  */

    if ((status = _WFFfind_column_offset
        (attr_list, "synonym1", syn_offset)) != NFI_S_SUCCESS)
      {
        /*  It is OK, reset the global error structure  */

        ERRreset_struct ();

        /*  It is an NFM attribute buffer  */

        if ((status = _WFFfind_column_offset
            (attr_list, "n_synonym", syn_offset)) != NFI_S_SUCCESS)
          {
            _NFIdebug ((fname, "_WFFfind_column_offset = <0x%.8x>\n", status));
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (status);
          }
        else
          {
            /*  It is OK, reset the global error structure  */

            ERRreset_struct ();

            /*  Find the attribute name offset in the attribute buffer  */

            if ((status = _WFFfind_column_offset
                (attr_list, "n_name", name_offset)) != NFI_S_SUCCESS)
              {
                _NFIdebug ((fname,
                    "_WFFfind_column_offset = <0x%.8x>\n", status));
                _NFIdebug ((fname, " returning FAILURE\n"));
                return (status);
              }
          }
      }
    else
      {
        /*  It is an RPS select_list, find the attribute name offset  */

        if ((status = _WFFfind_column_offset
            (attr_list, "attr_name", name_offset)) != NFI_S_SUCCESS)
          {
            _NFIdebug ((fname, "_WFFfind_column_offset = <0x%.8x>\n", status));
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (status);
          }
      }

    _NFIdebug ((fname, "synonym offset = <%d>\n", *syn_offset));
    _NFIdebug ((fname, "name offset = <%d>\n", *name_offset));

    _NFIdebug ((fname, " returning SUCCESS\n"));
    return (NFI_S_SUCCESS);
  }


void _WFFclear_msg (form)
  Form    form;
  {
    int     status;
    int     attr_mask = 0;
    int     bx_size, by_size;

    static  char *fname = "_WFFclear_msg";

    /*  Make sure the form is valid  */

    if (form == NULL)
      {
        _NFIdebug ((fname, "form is NULL\n"));
        _NFIdebug ((fname, " returning ...\n"));
        return;
      }

    if (form != WFFglobal.main_form)
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
        if ((status = FIg_set_text (form, ERROR_BUTTON, "")) != FI_SUCCESS)
          {
            _NFIdebug ((fname, "FIg_set_text = <%d>\n", status));
            return;
          }

        if ((status = FIg_display (form, ERROR_BUTTON)) != FI_SUCCESS)
            _NFIdebug ((fname, "FIg_display = <%d>\n", status));
      }

    return;
  }


long _WFFget_attr_info (attr_list, attrname, offset, n_read, n_write,
                         type, length)
  MEMptr    attr_list;       /* "I"  :                                */
  char      *attrname;       /* "I"  : n_nfmname for the attribute    */
  int       *offset;         /* "O"  :                                */
  char      *n_read;         /* "O"  : "Y" readable attribute or "N"  */ 
  char      *n_write;        /* "O"  : "Y" writeable attribute or "N" */ 
  char      *type;           /* "O"  : datatype of the attribute.     */
  int       *length;         /* "O"  : length if char otherwise 0     */   
  {
    int     a, b, c, d, i, j, x, y, count;
    char    **column, **a_data;
    char    wsize[40];
    short   found = FALSE;

    static  char *fname = "_WFFget_attr_info";
        
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
                if (strcmp (column[y], "n_nfmname") == 0)   a = y;
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


long _WFFcvt_to_long (str, value) 
  char      *str;           /* "I"  : string to convert.     */
  long      *value;         /* "O"  : converted value        */   
  {
    int     i, j;
    long    status;

    static  char *fname = "_WFFcvt_to_long";
        
    _NFIdebug ((fname, "String = <%s>\n", str));

    if (!str)
     {
        status = NFI_W_NULL_NUMERIC_INPUT; 
        _NFIdebug ((fname, " The string is NULL : returning <0x%.8x>\n",
                    status));
        return (status);
     }

    if (strcmp (str, "") == 0)
     {
        status = NFI_W_NULL_NUMERIC_INPUT; 
        _NFIdebug ((fname, " The string is NULL : returning <0x%.8x>\n",
                    status));
        return (status);
     }

    /* Check to see if each character in the string is numeric */

    j = strlen (str);

    for (i = 0; i < j; ++i)
     {
         if ((str[i] == ' ') || (str[i] == '\t'))
          {
             continue;   /* ignore tabs and blanks */
          }

         if (! isdigit (str[i]))
          {
             status = NFI_W_INVALID_NUMERIC_INPUT; 
             _NFIdebug ((fname, " The string is NULL : returning <0x%.8x>\n",
                         status));
             return (status);
          }
     } 

    *value = atol (str);
    _NFIdebug ((fname, " value = <%d>\n", *value));
    status = NFI_S_SUCCESS;

    if (*value < 0)
        status = NFI_W_NEGATIVE_VALUE;

    _NFIdebug ((fname, "returning : status = <0x%.8x>\n", status));
    return (status);
  }


void _WFFset_active_row (form, g_label, active_row, row_pos)
  Form    form;
  int     g_label;
  int     active_row; 
  int     row_pos;  /* 0 = top : 1 = bottom */
  {
    int     status;
    int     pos = 0;
    int     act_row = 0;
    int     num_vis_rows = 0;
    int     num_rows = 0;

    static  char *fname = "_WFFset_active_row";

    _NFIdebug ((fname, " Active Row = <%d>\n", active_row));

    /*  Make sure the form is valid  */

    if (form == NULL)
     {
        _NFIdebug ((fname, "form is NULL\n"));
        _NFIdebug ((fname, " returning ...\n"));
        return;
     }

    /* get the active row */

    status = FIfld_get_active_row (form, g_label, &act_row, &pos);
    if (status != FI_SUCCESS)
     {
        _NFIdebug ((fname, " FIfld_get_active_row : status = <%d>\n", status));
        _NFIdebug ((fname, " returning ...\n"));
        return;
     }

    if ((pos != -1) && (act_row == active_row))
     {
         /* The row is within the viewing area; just return */

        _NFIdebug ((fname, " The row is within the viewing area\n"));
        _NFIdebug ((fname, " returning ...\n"));
        return;
     }

    if (active_row > -1)
       act_row = active_row;

    /* Get the number of visible rows in the field */

    status = FIfld_get_num_vis_rows (form, g_label, &num_vis_rows);
    if (status != FI_SUCCESS)
     {
        _NFIdebug ((fname, " FIfld_get_num_vis_rows : status = <%d>\n",
                    status));
        _NFIdebug ((fname, " returning ...\n"));
        return;
     }

    /* Get the number of rows in the field */

    status = FIfld_get_num_rows (form, g_label, &num_rows);
    if (status != FI_SUCCESS)
     {
        _NFIdebug ((fname, " FIfld_get_num_rows : status = <%d>\n", status));
        _NFIdebug ((fname, " returning ...\n"));
        return;
     }

    /* The row is not within the viewing area; put it there */

    /* set the active row within the viewing area at row 1 */

    if (row_pos)  /* bottom */
     {
       if (act_row < num_rows - num_vis_rows)
           status = FIfld_set_active_row (form, g_label, act_row,
                                          num_vis_rows -1);
       else 
           status = FIfld_set_active_row (form, g_label, act_row,
                                          act_row - (num_rows - num_vis_rows));
     }
    else  /* top */
       status = FIfld_set_active_row (form, g_label, act_row, 0);
     
    if (status != FI_SUCCESS)
     {
        _NFIdebug ((fname, " FIfld_set_active_row : status = <%d>\n", status));
        _NFIdebug ((fname, " returning ...\n"));
        return;
     }

    return;
  }

void  _WFFprint_add( ptr )
  WFFadd_ptr  ptr;
{

    int  i;
    int  j;
    int  k;

    static char *fname = "_WFFprint_add";

    if( ptr->num_classes == 0 )
	_NFIdebug(( fname, "NO classes\n" ));
    if( ptr->num_states == 0 )
	_NFIdebug(( fname, "NO states\n" ));

    for( i=0; i<ptr->num_classes; ++i )
    {
	_NFIdebug(( fname, "Class <%s>\n", ptr->class_list[i].class_name ));
	_NFIdebug(( fname, "Class status <%s>\n", ptr->class_list[i].status ));

        /*  Search for any accesses for the selected class */

        for( k = 0; k < ptr->num_access; ++k )
        {
 	    if( strcmp( ptr->access_list[k].class_name,
			ptr->class_list[i].class_name ) == 0 )
 	    {
		for( j=0; j<ptr->access_list[k].num_trans; ++j )
     	        {
		    _NFIdebug(( fname, "Transition <%s> for class <%s>\n",
			ptr->access_list[k].trans_ptr[j].trans_name,
			ptr->class_list[i].class_name));
		    _NFIdebug(( fname, "Status <%s> for Transition <%s>\n",
			ptr->access_list[k].trans_ptr[j].status,
			ptr->access_list[k].trans_ptr[j].trans_name ));
		}
	    }
	}
    }

    for( i=0; i<ptr->num_states; ++i )
    {
	_NFIdebug(( fname, "State <%s>\n", ptr->state_list[i].state_name ));
	_NFIdebug(( fname, "State status <%s>\n", ptr->state_list[i].status ));
    }

    for( i=0; i<ptr->num_trans; ++i )
    {
	_NFIdebug(( fname, "Transitions <%s>  Status  <%s>\n",
		   ptr->trans_list[i].trans_name, ptr->trans_list[i].status ));
    }

    return;
}
 
