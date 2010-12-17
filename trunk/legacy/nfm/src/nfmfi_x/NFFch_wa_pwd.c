
/* machine.h included to take care of platform variencies MVR 23 Dec 1993 */
#include "machine.h"

#include "NFF.h"
#include "NFFpasswd.h"

/*  Global NFF structure  */

extern struct NFFglobal_st NFFglobal;

long NFFchange_working_area_password (working_area)
  char    *working_area;
  {
    long       status;
    char       title[NFF_MAX_MESSAGE];
    NFFpasswd  sa;

    static    char *fname = "NFFchange_working_area_password";

    _NFIdebug ((fname, "working_area = <%s>\n", working_area));

    /*  Initialize the sa structure  */

    if ((sa = (NFFpasswd) malloc (sizeof (struct NFFpasswd_st))) == NULL)
      {
        _NFIdebug ((fname,
            "malloc failed; size = <%d>\n", sizeof (struct NFFpasswd_st)));
        ERRload_struct (NFI, NFI_E_MALLOC, "%d", sizeof (struct NFFpasswd_st));
        NFFglobal.status = NFI_E_MALLOC;
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_MALLOC);
      }

    sa->type = 0;
    sa->done = FALSE;
    sa->verify_flag = FALSE;
    strcpy (sa->old_password, "");
    strcpy (sa->new_password, "");
    strcpy (sa->verify_password, "");

    /*  Load in the Password form  */

    if ((status = (long) FIf_new (CHANGE_WA_PASSWD_LABEL,
        PASSWORD_FORM, _NFFnotify, &(NFFglobal.current_form))) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIf_new = <%d>\n", status));
        NFFfree_passwd (&NFFglobal.current_form, sa);
        NFFglobal.status = NFI_E_FORM;
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIf_new", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    /*  Store a pointer to the data in the form  */

    if ((status = (long) FIf_set_user_pointer
        (NFFglobal.current_form, (char *) sa)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIf_set_user_pointer = <%d>\n", status));
        NFFerase_message ();
        NFFfree_passwd (&NFFglobal.current_form, sa);
        NFFglobal.status = NFI_E_FORM;
        ERRload_struct
            (NFI, NFI_E_FORM, "%s%d", "FIf_set_user_pointer", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    /*  Clear out the error message strip  */

    NFFform_message (CURRENT_LABEL, NFI_S_CLEAR_MSG, NULL);

    /*  Center the form  */

    if ((status = _NFFcenter_form
        (NFFglobal.current_form, -1, Y_FORM_POS)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFcenter_form = <0x%.8x>\n", status));
        NFFfree_passwd (&NFFglobal.current_form, sa);
        NFFglobal.status = status;
        _NFIdebug ((fname, " returning %d\n", status));
        return (status);
      }

    /*  Set the title on the form  */

    if ((status = (long) UMSGetByNum
        (title, NFI_P_CHANGE_PWD, NULL)) != UMS_S_SUCCESS)
      {
        _NFIdebug ((fname, "UMSGetByNum = <0x%.8x>\n", status));
        _NFIdebug ((fname, "defaulting title\n"));
        strcpy (title, "Change Password");
      }

    if ((status = (long) FIg_set_text
        (NFFglobal.current_form, TITLE1, title)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIg_set_text = <%d>\n", status));
        NFFfree_passwd (&NFFglobal.current_form, sa);
        NFFglobal.status = NFI_E_FORM;
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_set_text", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    if ((status = (long) UMSGetByNum
        (title, NFT_P_CHANGE_WA_PWD, "%s", working_area)) != UMS_S_SUCCESS)
      {
        _NFIdebug ((fname, "UMSGetByNum = <0x%.8x>\n", status));
        _NFIdebug ((fname, "defaulting title\n"));
        sprintf (title, "for Working Area \"%s\"", working_area);
      }

    if ((status = (long) FIg_set_text
        (NFFglobal.current_form, TITLE2, title)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIg_set_text = <%d>\n", status));
        NFFfree_passwd (&NFFglobal.current_form, sa);
        NFFglobal.status = NFI_E_FORM;
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_set_text", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    /*  Display the Password form  */

    if ((status = (long) FIf_display (NFFglobal.current_form)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIf_display = <%d>\n", status));
        NFFfree_passwd (&NFFglobal.current_form, sa);
        NFFglobal.status = NFI_E_FORM;
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIf_display", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    /*  Put the cursor in the old password field  */

    if ((status = (long) FIfld_pos_cursor (NFFglobal.current_form,
        OLD_PASSWORD_FIELD, 0, 0, 0, 0, 0, 0)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIfld_pos_cursor = <%d>\n", status));
        NFFfree_passwd (&NFFglobal.current_form, sa);
        NFFglobal.status = NFI_E_FORM;
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_pos_cursor", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    _NFIdebug ((fname, " returning SUCCESS\n"));
    return (NFI_S_SUCCESS);
  }


long _NFFchange_wa_password_notify (g_label, form)
  int       g_label;
  Form      *form;
  {
    long    status = NFI_S_SUCCESS;

    NFFpasswd    sa;

    static    char *command = NFI_M_CHANGE_WA_PASSWD;
    static    char *fname = "_NFFchange_wa_password_notify";

    _NFIdebug ((fname, "g_label = <%d>\n", g_label));

    if ((status = (long) FIf_get_user_pointer (*form,
                                           (char *) &sa)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIf_get_user_pointer = <%d>\n", status));
        ERRload_struct  
                  (NFI, NFI_E_FORM, "%s%d", "FIf_get_user_pointer", status);
        return (NFI_E_FORM);
      }

    NFFform_message (CURRENT_LABEL, NFI_S_CLEAR_MSG, NULL);

    switch (g_label)
      {
        case FI_HELP:

            if (status = _NFFhelp_topic (command))
              {
                _NFIdebug ((fname, "_NFFhelp_topic = <%d>\n", status));
                status = NFI_E_HELP;
              }

            break;

        case FI_CANCEL:

            /*  Load the global error structure  */

            ERRload_struct (NFI, NFI_W_COMMAND_CANCELLED, NULL);
            NFFglobal.status = NFI_W_COMMAND_CANCELLED;

            /*  Set the next state  */

            if ((status = NFFset_to_state ()) != NFI_S_SUCCESS)
                _NFIdebug ((fname, "NFFset_to_state = <0x%.8x>\n", status));

            /*  Free allocated memory and delete the form  */

            NFFfree_passwd (form, sa);

            break;

        case FI_ACCEPT:

            if ((status = _NFFpasswd_validate_accept (sa)) != NFI_S_SUCCESS)
                _NFIdebug ((fname,
                    "_NFFpasswd_validate_accept = <0x%.8x>\n", status));

            if (sa->done == FALSE)
              {
                /*  Reset the accept button  */

                FIg_reset (*form, FI_ACCEPT);

                break;
              }

            /*  Put up a message  */

            NFFform_message (CURRENT_LABEL, NFI_I_CHANGE_WA_PASSWORD, NULL);

            /*  Call NFMR to change the storage area password  */

            _NFIdebug ((fname,
                "calling NFMRchange_working_area_passwd ...\n"));
            status = NFMRchange_working_area_passwd ( NFFglobal.working_area,
                                           sa->old_password, sa->new_password);
            _NFIdebug ((fname,
                "NFMRchange_working_area_passwd = <0x%.8x>\n", status));

            /*  Erase the message  */

            NFFerase_message ();

            /*  Save the return status  */

            NFFglobal.status = status;

            /*  Set the next state  */

            if ((status = NFFset_to_state ()) != NFI_S_SUCCESS)
                _NFIdebug ((fname, "NFFset_to_state = <0x%.8x>\n", status));

            /*  Free allocated memory and delete the form  */

            NFFfree_passwd (form, sa);

            break;

        case OLD_PASSWORD_FIELD:

            status = _NFFold_passwd_field (*form, g_label, sa);
            break;

        case NEW_PASSWORD_FIELD:

            status = _NFFnew_passwd_field (*form, g_label, sa);
            break;

        case VERIFY_PASSWORD_FIELD:

            status = _NFFverify_passwd_field (*form, g_label, sa);
            break;
      }

    _NFIdebug ((fname, " returning <0x%.8x>\n", status));
    return (status);
  }
