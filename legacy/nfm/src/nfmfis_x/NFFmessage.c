
/* machine.h included to take care of platform variencies MVR 23 Dec 1993 */
#include "machine.h"
#include "NFF.h"
/*
	As ERR.h defines va_start to use va_alist, i had to undefine va_start 
	before including the stdarg.h.  MVR 7 Jan 1994 
*/
#ifdef OS_SCO_UNIX
#undef	va_start
#include <stdarg.h>
#define va_start(list, parmN) \
     list = ((char *)(&parmN)) + ((sizeof(parmN) + sizeof(int) - 1) & \
                     ~(sizeof(int)-1));
#endif

/*  Global structure  */

extern struct NFFglobal_st NFFglobal;

void NFFform_message
(int f_label, int message_no, char *message_fmt, ...)
  {
    auto   int      status;
    auto   int      bx_size, by_size;
    auto   int      bx_pos, by_pos;
    auto   int      tx_size, ty_size;
    auto   int      tx_pos, ty_pos;
    auto   int      text_label = ERROR_TEXT;
    auto   int      bezel_label = ERROR_BEZEL;
    auto   int      attr_mask = 0;
    auto   int      displayed = 0;
    auto   char     type[5];
    auto   Form     form = NULL;
    auto   short    full_size = FALSE;
    auto   va_list  vars;
    static char     message[NFF_MAX_MESSAGE] = "";
    static char     *fname = "NFFform_message";

    NFFglobal.where_message_is = f_label;

    /*  Make sure the form is valid  */

    if (f_label >= CURRENT_LABEL)
        form = NFFglobal.current_form;
    else
        form = NFFglobal.forms[f_label];

    if (form == NULL)
      {
        /*  Check the main form  */

        if (NFFglobal.forms[MAIN_LABEL] == NULL) return;

        FIf_is_displayed (NFFglobal.forms[MAIN_LABEL], &displayed);
        if (displayed == TRUE)
          {
            NFFglobal.where_message_is = MAIN_LABEL;
            form = NFFglobal.forms[MAIN_LABEL];
          }
        else
          {
            /*  There is no place to put the message  */

            return;
          }
      }
    else
      {
        /*  Make sure the form is displayed (for list-driven commands)  */

        FIf_is_displayed (form, &displayed);
        if (displayed == FALSE)
          {
            /*  Check the main form  */

            if (NFFglobal.forms[MAIN_LABEL] == NULL) return;

            FIf_is_displayed (NFFglobal.forms[MAIN_LABEL], &displayed);
            if (displayed == TRUE)
              {
                NFFglobal.where_message_is = MAIN_LABEL;
                form = NFFglobal.forms[MAIN_LABEL];
              }
            else
              {
                /*  There is no place to put the message  */

                return;
              }
          }
      }

    _NFIdebug ((fname, "message_no = <0x%.8x>\n", message_no));
    if (message_fmt != NULL)
        _NFIdebug ((fname, "message_fmt = <%s>\n", message_fmt));

    va_start (vars, message_fmt);

    if ((status = UMSGetByNumVar
       (message, message_no, message_fmt, vars)) != UMS_S_SUCCESS)
      {
        _NFIdebug ((fname, "UMSGetByNumVar = <0x%.8x>\n", status));
        va_end (vars);
        _NFIdebug ((fname, " returning ...\n"));
        return;
      }

    va_end (vars);

    /*  Get the message type  */

    if ((status = UMSMsgCode (type, message_no,
        UMS_SUPPRESS_COMP | UMS_SUPPRESS_EXT,
        NULL, NULL, NULL)) != UMS_S_SUCCESS)
      {
        _NFIdebug ((fname, "UMSMsgCode = <0x%.8x>\n", status));
        _NFIdebug ((fname, " returning ...\n"));
        return;
      }

    _NFIdebug ((fname, "message = <%s>\n", message));
    _NFIdebug ((fname, "type = <%s>\n", type));

    if ((strcmp (type, "E")) == 0)
      {
        FIg_set_on_color (form, text_label, FI_RED);
        FIg_set_off_color (form, text_label, FI_WHITE);
      }
    else if ((strcmp (type, "W")) == 0)
      {
        FIg_set_on_color (form, text_label, FI_YELLOW);
        FIg_set_off_color (form, text_label, FI_BLACK);
      }
    else if ((strcmp (type, "I")) == 0)
      {
        FIg_set_on_color (form, text_label, FI_BLUE);
        FIg_set_off_color (form, text_label, FI_WHITE);
      }
    else  /*  "S"  */
      {
        FIg_set_on_color (form, text_label, FI_BLACK);
        FIg_set_off_color (form, text_label, FI_WHITE);
      }

    /*  Find out if the scroll buttons are displayed  */

    if ((status = FIg_get_attr
        (form, LEFT_SCROLL_BUTTON, &attr_mask)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIg_get_attr = <%d>\n", status));
        _NFIdebug ((fname, "returning ...\n"));
        return;
      }

    if (attr_mask & FI_NOT_DISPLAYED)
      {
        /*  The bezel area is full size  */

        full_size = TRUE;
      }
    else
      {
        /*  The bezel area is short 50 pixels  */

        full_size = FALSE;
      }

    /*  Find out how long the text and bezel are  */

    FIg_erase (form, text_label);
    FIg_set_text (form, text_label, message);
    FIg_get_size (form, bezel_label, &bx_size, &by_size);
    FIg_get_location (form, bezel_label, &bx_pos, &by_pos);
    FIg_get_size (form, text_label, &tx_size, &ty_size);
    FIg_get_location (form, text_label, &tx_pos, &ty_pos);

    if (full_size == FALSE)
      {
        _NFIdebug ((fname, "bezel is NOT full size\n"));
        bx_size += 50;
        FIg_erase (form, bezel_label);
        FIg_set_size (form, bezel_label, bx_size, by_size);

        /*  Erase the scroll buttons  */

        FIg_erase (form, LEFT_SCROLL_BUTTON);
        FIg_erase (form, RIGHT_SCROLL_BUTTON);
      }

    /*  Center the text on the bezel  */

    _NFIdebug ((fname, "centering text on bezel ...\n"));
    tx_pos = (bx_pos + (bx_size / 2)) - (tx_size / 2);
    FIg_set_location (form, text_label, tx_pos, ty_pos);
    FIg_display (form, bezel_label);
    FIg_display (form, text_label);

    _NFIdebug ((fname, " returning ...\n"));
    return;
  }


void NFFerror_message (form)
  Form    form;
  {
    auto    int     status;
    auto    int     bx_size, by_size;
    auto    int     bx_pos, by_pos;
    auto    int     tx_size, ty_size;
    auto    int     tx_pos, ty_pos;
    auto    int     text_label = ERROR_TEXT;
    auto    int     bezel_label = ERROR_BEZEL;
    auto    int     attr_mask;
    auto    int     subsystem;
    auto    long    message_no;
    auto    char    *visible_msg, type[5];
    auto    short   full_size = FALSE;
    static  long    beginning_char = 0;
    static  long    ending_char = 0;
    static  char    message[NFF_MAX_MESSAGE] = "";
    static  char    *fname = "NFFerror_message";

    /*  Make sure the form is valid  */

    if (form == NULL)
      {
        /*  Put the error on the main form
            (even if it isn't currently displayed)  */

        form = NFFglobal.forms[MAIN_LABEL];
        if (form == NULL) return;
      }

    /*  Let the error processor retrieve the message  */

    if ((status = ERRget_message (message)) != ERR_S_SUCCESS)
      {
        _NFIdebug ((fname, "ERRget_message = <0x%.8x>\n", status));
        _NFIdebug ((fname, " returning ...\n"));
        return;
      }

    ERRget_number (&message_no, &subsystem);

    /*  Get the message type  */

    if ((status = UMSMsgCode (type, message_no,
        UMS_SUPPRESS_COMP | UMS_SUPPRESS_EXT,
        NULL, NULL, NULL)) != UMS_S_SUCCESS)
      {
        _NFIdebug ((fname, "UMSMsgCode = <0x%.8x>\n", status));
        _NFIdebug ((fname, " returning ...\n"));
        return;
      }

    _NFIdebug ((fname, "message = <%s>\n", message));
    _NFIdebug ((fname, "type = <%s>\n", type));

    if ((strcmp (type, "E")) == 0)
      {
        FIg_set_on_color (form, text_label, FI_RED);
        FIg_set_off_color (form, text_label, FI_WHITE);
      }
    else if ((strcmp (type, "W")) == 0)
      {
        FIg_set_on_color (form, text_label, FI_YELLOW);
        FIg_set_off_color (form, text_label, FI_BLACK);
      }
    else if ((strcmp (type, "I")) == 0)
      {
        FIg_set_on_color (form, text_label, FI_BLUE);
        FIg_set_off_color (form, text_label, FI_WHITE);
      }
    else  /*  "S"  */
      {
        FIg_set_on_color (form, text_label, FI_BLACK);
        FIg_set_off_color (form, text_label, FI_WHITE);
      }

    /*  Initialize the beginning and ending character positions  */

    beginning_char = ending_char = 0;

    FIg_erase (form, text_label);
    FIg_set_text (form, text_label, message);

    /*  Find out if the scroll buttons are displayed  */

    FIg_get_attr (form, LEFT_SCROLL_BUTTON, &attr_mask);
    if (attr_mask & FI_NOT_DISPLAYED)
      {
        /*  The bezel area is full size  */

        full_size = TRUE;
      }
    else
      {
        /*  The bezel area is short 50 pixels  */

        full_size = FALSE;
      }

    FIg_get_size (form, bezel_label, &bx_size, &by_size);
    FIg_get_size (form, text_label, &tx_size, &ty_size);
    FIg_get_location (form, bezel_label, &bx_pos, &by_pos);
    FIg_get_location (form, text_label, &tx_pos, &ty_pos);
/*
    if ((tx_size <= (bx_size + 30)) && (full_size == TRUE))
*/
    if (((tx_size + 30) <= bx_size) && (full_size == TRUE))
      {
        /*  Center the text on the bezel  */

        tx_pos = (bx_pos + (bx_size / 2)) - (tx_size / 2);
      }
/*
    else if ((tx_size <= (bx_size + 80)) && (full_size == FALSE))
*/
    else if (((tx_size + 80) <= bx_size) && (full_size == FALSE))
      {
        bx_size += 50;
        FIg_erase (form, bezel_label);
        FIg_set_size (form, bezel_label, bx_size, by_size);

        /*  Center the text on the bezel  */

        tx_pos = (bx_pos + (bx_size / 2)) - (tx_size / 2);

        FIg_erase (form, LEFT_SCROLL_BUTTON);
        FIg_erase (form, RIGHT_SCROLL_BUTTON);
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
            _NFIdebug ((fname, " returning ...\n"));
            return;
          }

        /*  Try a best guess at how many characters to display  */

        ending_char = strlen (message) * (bx_size - 30) / tx_size;

        strncpy (visible_msg, message, ending_char);
        visible_msg[ending_char] = NULL;
        _NFIdebug ((fname, "visible_msg = <%s>\n", visible_msg));
        FIg_set_text (form, text_label, visible_msg);

        if (visible_msg) free (visible_msg);
      }

    FIg_set_location (form, text_label, tx_pos, ty_pos);
    FIg_set_user_pointer (form, text_label, message);
    FIg_set_user_pointer (form,
        LEFT_SCROLL_BUTTON, (char *) &beginning_char);
    FIg_set_user_pointer (form,
        RIGHT_SCROLL_BUTTON, (char *) &ending_char);
    FIg_display (form, bezel_label);
    FIg_display (form, text_label);

    _NFIdebug ((fname, " returning ...\n"));
    return;
  }


void NFFerase_message ()
  {
    auto   Form  form;
    static char  *fname = "NFFerase_message";
    char   form_name[20];
    int    status;

    _NFIdebug ((fname, "where_message_is = %d\n", NFFglobal.where_message_is));

    if (NFFglobal.where_message_is >= CURRENT_LABEL)
        form = NFFglobal.current_form;
    else
        form = NFFglobal.forms[NFFglobal.where_message_is];

    if (form == NULL)
      {
        _NFIdebug ((fname, "form is NULL\n"));
        return;
      }

    FIg_set_text (form, ERROR_TEXT, "");
    FIg_display (form, ERROR_TEXT);
    FIg_display (form, ERROR_BEZEL);
    
    _NFIdebug(( fname, "Returning ...\n" ));

  }
