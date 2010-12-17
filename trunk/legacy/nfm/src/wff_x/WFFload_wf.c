#include "machine.h"
#include "WFF.h"
#include "WFFldfile.h"

/*  Global WFF structure  */

extern struct WFFglobal_st WFFglobal;

long WFFload_workflow ()
  {
    long    status;
    char    title[256];

    int     label = FILENAME_FIELD;

    static  char *fname = "WFFload_workflow";

    /*  Load in the form  */

    if ((status = (long) FIf_new (LOAD_WF_LABEL,
        LOAD_WF_FORM, _WFFnotify, &(WFFglobal.current_form))) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIf_new = <%d>\n", status));
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIf_new", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    /*  Clear out the error message strip  */

    _WFFclear_msg (WFFglobal.current_form);

    /*  Center the form  */

    if ((status = _WFFcenter_form
        (WFFglobal.current_form, -1, Y_FORM_POS)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_WFFcenter_form = <0x%.8x>\n", status));
        _NFIdebug ((fname, " returning %d\n", status));
        return (status);
      }

    /*  Set the title  */

    if ((status = (long) UMSGetByNum
        (title, NFI_P_LOAD_WF, NULL)) != UMS_S_SUCCESS)
      {
        _NFIdebug ((fname, "UMSGetByNum = <0x%.8x>\n", status));
        _NFIdebug ((fname, "defaulting title\n"));
        strcpy (title, "Load a Workflow into I/NFM");
      }

    if ((status = (long) FIg_set_text
        (WFFglobal.current_form, TITLE, title)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIg_set_text = <%d>\n", status));
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_set_text", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    /*  Display the form  */

    if ((status = (long) FIf_display (WFFglobal.current_form)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIf_display = <%d>\n", status));
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIf_display", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    /*  Put the cursor in FILENAME_FIELD  */
/* IGI Intel Solaris Port - CN 31/5/95 */
#if defined(OS_SCO_UNIX) || defined(OS_INTELSOL)
    /* To set font for SCO - CRN 25 Feb 94 */
    FIg_set_font( WFFglobal.current_form, label, "7x13bold", 15);
#endif

    if ((status = (long) FIfld_pos_cursor
        (WFFglobal.current_form, label, 0, 0, 0, 0, NULL, 0)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIfld_pos_cursor = <%d>\n", status));
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_pos_cursor", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    _NFIdebug ((fname, " returning SUCCESS\n"));
    return (NFI_S_SUCCESS);
  }


long _WFFload_wf_notify (g_label, value, form)
  int       g_label;
  double    value;
  Form      form;
  {
    int     length;
    int     sel, pos;
    long    status = NFI_S_SUCCESS;
    char    *filename;

    static  char *command = WFF_M_LOAD_WORKFLOW;
    static  char *fname = "_WFFload_wf_notify";

    _NFIdebug ((fname, "g_label = <%d>\n", g_label));
    _NFIdebug ((fname, "value = <%f>\n", value));

    /*  Clear out the error message strip  */

    _WFFclear_msg (form);

    switch (g_label)
      {
        case FI_HELP:

#if (defined(OS_SUNOS) || defined(OS_SOLARIS) || \
    defined(OS_SCO_UNIX) || defined(OS_HPUX))
         _NFIdebug ((fname, "Help not available\n"));
         ERRload_struct (NFI, NFI_E_HELP, NULL);
         status = NFI_E_HELP;
#else
            if (status = _WFFhelp_topic (command))
              {
                _NFIdebug ((fname, "_WFFhelp_topic = <%d>\n", status));
                ERRload_struct (NFI, NFI_E_HELP, "%s%d", "_WFFelp_topic", 
				status);
                status = NFI_E_HELP;
              }
#endif

            break;

        case FI_CANCEL:

            /*  Load the global error structure  */

            ERRload_struct (NFI, NFI_W_COMMAND_CANCELLED, NULL);

            /*  Set the next state  */

            if ((status = WFFset_to_state ()) != NFI_S_SUCCESS)
                _NFIdebug ((fname, "WFFset_to_state = <0x%.8x>\n", status));

            /*  Delete the form  */

            FIf_delete (form);
            WFFglobal.current_form = NULL;

            /*  Enable the main form  */

            if (WFFglobal.main_form != NULL)
              {
                FIg_enable (WFFglobal.main_form, FI_FORM_GROUP);
                _WFFprocess_event (REFRESH_EVENT);
              }

            break;

        case FI_ACCEPT:

            /*  Get the filename out of the field  */

            FIfld_get_text_length (form, FILENAME_FIELD, 0, 0, &length);

            _NFIdebug ((fname, "length of text = <%d>\n", length));

            if (length <= 0)
              {
                ERRload_struct (NFI, NFI_E_NULL_FILENAME, NULL);
                status = NFI_E_NULL_FILENAME;

                /*  Reset the accept button  */

                FIg_reset (form, FI_ACCEPT);

                break;
              }

            if ((filename = (char *) malloc (length + 1)) == NULL)
              {
                _NFIdebug ((fname, "malloc failed; size = <%d>\n", length));
                ERRload_struct (NFI, NFI_E_MALLOC, "%d", length);
                status = NFI_E_MALLOC;

                /*  Reset the accept button  */

                FIg_reset (form, FI_ACCEPT);

                break;
              }

            FIfld_get_text
                (form, FILENAME_FIELD, 0, 0, length, filename, &sel, &pos);

            _NFIdebug ((fname, "filename = <%s>\n", filename));

            /*  Put up a message  */

            _WFFmessage (NFI_I_LOADWF, NULL);

            /*  Call NFM to load the workflow  */

            _NFIdebug ((fname, "calling WFload_workflow ...\n"));
            status = WFload_workflow (WFFglobal.user_id, "NFM", filename);
            _NFIdebug ((fname, "WFload_workflow = <0x%.8x>\n", status));

            /*  Erase the message  */

            _WFFerase_message ();

            if (filename) free (filename);

            /*  Save the return status  */

            WFFglobal.cmd_status = status;

            /*  Set the next state  */

            if ((status = WFFset_to_state ()) != NFI_S_SUCCESS)
                _NFIdebug ((fname, "NFIset_to_state = <0x%.8x>\n", status));

            /*  Delete the form  */

            FIf_delete (form);
            WFFglobal.current_form = NULL;

            /*  Enable the main form  */

            if (WFFglobal.main_form != NULL)
              {
                FIg_enable (WFFglobal.main_form, FI_FORM_GROUP);
                _WFFprocess_event (REFRESH_EVENT);
              }

            break;
      }

    _NFIdebug ((fname, " returning <0x%.8x>\n", status));
    return (status);
  }
