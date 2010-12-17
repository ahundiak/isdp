#include "machine.h"
#include "WFF.h"
#include "WFFpopup.h"
#include "WFFlogin.h"

/*  Global WFF structure  */

extern struct WFFglobal_st WFFglobal;

long _WFFenv_popup (buffer)
  MEMptr   buffer;   /*  i - value buffer with valid environments      */
 {
   int      i, row;
   int      fields;
   long     status;
   char     **data_ptr;
   short    offset;
   Form     form;

   int      label = POPUP_FIELD;

   static   char *fname = "_WFFenv_popup";

   /*  External functions  */

   void _WFFnotify ();

   _NFIdebug ((fname, "label = <%d>\n", label));

   /*  Disable the login form  */

   FIg_disable (WFFglobal.current_form, FI_FORM_GROUP);

   /*  Load in the form  */

   if ((status = (long) FIf_new (ENV_POPUP_LABEL,
      POPUP_ENV_FORM, _WFFnotify, &form)) != FI_SUCCESS)
    {
      _NFIdebug ((fname, "FIf_new = <%d>\n", status));
      WFFglobal.error_no = NFI_E_FORM;
      FIg_set_state_off (WFFglobal.current_form, ENV_BUTTON);
      ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIf_new", status);
      _NFIdebug ((fname, " returning FAILURE\n"));
      return (NFI_E_FORM);
    }

   if ((status = _WFFfind_column_offset
      (buffer, "name", &offset)) != NFI_S_SUCCESS)
    {
      _NFIdebug ((fname, "_WFFfind_column_offset = <0x%.8x>\n", status));
      FIg_set_state_off (WFFglobal.current_form, ENV_BUTTON);
      _NFIdebug ((fname, " returning FAILURE\n"));
      return (status);
    }

   /*  Set the number of rows in the popup list  */

   if ((status = (long) FIfld_set_num_rows
      (form, label, 0, buffer->rows)) != FI_SUCCESS)
     {
      _NFIdebug ((fname, "FIfld_set_num_rows = <%d>\n", status));
      FIg_set_state_off (WFFglobal.current_form, ENV_BUTTON);
      ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_num_rows", status);
      _NFIdebug ((fname, " returning FAILURE\n"));
      return (NFI_E_FORM);
     }

   row = 0;
   data_ptr = (char **) buffer->data_ptr;
   fields = buffer->rows * buffer->columns;
/* IGI Intel Solaris Port - CN 31/5/95 */
#if defined(OS_SCO_UNIX) || defined(OS_INTELSOL)
	/* To set font for SCO - CRN 25 Feb 94	*/
	FIg_set_font(form, label, "7x13bold", 15);
#endif
   for (i = offset; i < fields; i += buffer->columns, ++row)
     {
      /*  Put the data into the popup list  */

      _NFIdebug ((fname, "Setting <%s>\n", data_ptr[i]));
      _NFIdebug ((fname, " in row %d, col %d\n", row, 0));
      FIfld_set_text (form, label, row, 0, data_ptr[i], FALSE);
     }

   /*  Center the form  */

   if ((status = _WFFcenter_form (form, -1, 243)) != NFI_S_SUCCESS)
     {
      _NFIdebug ((fname, "_WFFcenter_form = <0x%.8x>\n", status));
      FIg_set_state_off (WFFglobal.current_form, ENV_BUTTON);
      WFFglobal.error_no = NFI_E_FORM;
      _NFIdebug ((fname, " returning %d\n", status));
      return (status);
     }

   /*  Clear out the error message strip  */

   _WFFclear_msg (form);

   /*  Display the form  */

   if ((status = (long) FIf_display (form)) != FI_SUCCESS)
     {
      _NFIdebug ((fname, "FIf_display = <%d>\n", status));
      FIg_set_state_off (WFFglobal.current_form, ENV_BUTTON);
      WFFglobal.error_no = NFI_E_FORM;
      ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIf_display", status);
      _NFIdebug ((fname, " returning FAILURE\n"));
      return (NFI_E_FORM);
     }

   _NFIdebug ((fname, " returning SUCCESS\n"));
   return (NFI_S_SUCCESS);
 }


long _WFFenv_popup_notify (g_label, value, form)
  int      g_label;
  double   value;
  Form      form;
 {
   long   status = NFI_S_SUCCESS;
   /* char   command[15]; */

   static   char *fname = "_WFFenv_popup_notify";

   long   _WFFenv_popup_field ();
   void   _WFFnotify ();

   _NFIdebug ((fname, "g_label = %d\n", g_label));

   /*  Clear out the error message strip  */

   _WFFclear_msg (form);

   switch (g_label)
     {
      case FI_HELP:
/*
         if (status = _WFFhelp_topic (command))
           {
            _NFIdebug ((fname, "_WFFhelp_topic = <%d>\n", status));
            ERRload_struct (NFI, NFI_E_HELP, "%s%d", "_WFFhelp_topic", status);
            status = NFI_E_HELP;
           }
*/
         ERRload_struct (NFI, NFI_I_HELP, NULL);
         status = NFI_I_HELP;

         break;

      case FI_CANCEL:
      case FI_ACCEPT:

         /*  Delete the form  */

         FIf_delete (form);

         /*  Enable the login form  */

         FIg_enable (WFFglobal.current_form, FI_FORM_GROUP);
         FIg_set_state_off (WFFglobal.current_form, ENV_BUTTON);

         break;

      case POPUP_FIELD:

         if (value >= 0)
           {
            status = _WFFenv_popup_field (form, g_label, (int) value);
            _WFFnotify (ENV_POPUP_LABEL, FI_ACCEPT, value, form);
           }

         break;
     }

   _NFIdebug ((fname, " returning <0x%.8x>\n", status));
   return (status);
 }


long _WFFenv_popup_field (form, label, row)
  Form   form;
  int   label;
  int   row;
 {
   int      length;
   int      selected;
   int      pos;
   int      status;
   char   *text;

   static   char *fname = "_WFFenv_popup_field";

   _NFIdebug ((fname, "row = <%d>\n", row));

   if (row < 0)
     {
      _NFIdebug ((fname, "rows or columns are scrolling\n"));
      _NFIdebug ((fname, " returning SUCCESS\n"));
      return (NFI_S_SUCCESS);
     }

   /*  Find the length of the text  */

   if ((status = FIfld_get_text_length
      (form, label, row, 0, &length)) != FI_SUCCESS)
     {
      _NFIdebug ((fname, "FIfld_get_text_length = <%d>\n", status));
      ERRload_struct
         (NFI, NFI_E_FORM, "%s%d", "FIfld_get_text_length", status);
      _NFIdebug ((fname, " returning FAILURE\n"));
      return (NFI_E_FORM);
     }

   if ((text = (char *) malloc (length)) == NULL)
     {
      _NFIdebug ((fname, "malloc failed; size = <%d>\n", length));
      ERRload_struct (NFI, NFI_E_MALLOC, "%d", length);
      _NFIdebug ((fname, " returning FAILURE\n"));
      return (NFI_E_MALLOC);
     }

   if ((status = FIfld_get_text (form, label,
      row, 0, length, text, &selected, &pos)) != FI_SUCCESS)
     {
      _NFIdebug ((fname, "FIfld_get_text = <%d>\n", length));
      if (text) free (text);
      ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_get_text", status);
      _NFIdebug ((fname, " returning FAILURE\n"));
      return (NFI_E_FORM);
     }

   /*  Put the selected text in the environment field  */

/* IGI Intel Solaris Port - CN 31/5/95 */
#if defined(OS_SCO_UNIX) || defined(OS_INTELSOL)
	/* To set font for SCO - CRN  25 Feb 94	*/
	FIg_set_font(WFFglobal.current_form, 17, "7x13bold", 15);
#endif
   if ((status = FIfld_set_text
      (WFFglobal.current_form, 17, 0, 0, text, FALSE)) != FI_SUCCESS)
     {
      _NFIdebug ((fname, "FIfld_set_text = <%d>\n", length));
      if (text) free (text);
      ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_text", status);
      _NFIdebug ((fname, " returning FAILURE\n"));
      return (NFI_E_FORM);
     }

   strncpy (WFFglobal.environment, text, sizeof (WFFglobal.environment) - 1);

   if (text) free (text);

   _NFIdebug ((fname, " returning SUCCESS\n"));
   return (NFI_S_SUCCESS);
 }
