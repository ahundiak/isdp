#include "NFF.h"
#include "NFFpasswd.h"

/*  Global NFF structure  */

extern struct NFFglobal_st NFFglobal;

long NFFchange_user_password (command, user_name)
  char *command; /* Change Password(NFChPswd): Change User Password(NFChUsPw) */
  char *user_name;
  {
    long        status;
    char        title[NFF_MAX_MESSAGE];
    NFFpasswd   user;

    static    char *fname = "NFFchange_user_password";

    _NFIdebug ((fname, "user_name = <%s>\n", user_name));
    _NFIdebug ((fname, "command   = <%s>\n", command));

    /*  Initialize the password structure  */

    if ((user = (NFFpasswd) malloc (sizeof (struct NFFpasswd_st))) == NULL)
      {
        _NFIdebug ((fname,
            "malloc failed; size = <%d>\n", sizeof (struct NFFpasswd_st)));
        NFFglobal.status = NFI_E_MALLOC;
        ERRload_struct (NFI, NFI_E_MALLOC, "%d", sizeof (struct NFFpasswd_st));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_MALLOC);
      }

    if (strcmp (command, NFI_M_CHANGE_PASSWD) == 0)
       user->type = 0;
    else
       user->type = 1;
    user->done = FALSE;
    user->verify_flag = FALSE;
    strcpy (user->old_password, "");
    strcpy (user->new_password, "");
    strcpy (user->verify_password, "");

    /*  Load in the Password form  */

    if ((status = (long) FIf_new (CHANGE_USER_PASSWD_LABEL,
        PASSWORD_FORM, _NFFnotify, &(NFFglobal.current_form))) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIf_new = <%d>\n", status));
        NFFerase_message ();
        NFFfree_passwd (NULL, user);
        NFFglobal.status = NFI_E_FORM;
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIf_new", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    /*  Store a pointer to the data in the form  */

    if ((status = (long) FIf_set_user_pointer
        (NFFglobal.current_form, (char *) user)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIf_set_user_pointer = <%d>\n", status));
        NFFerase_message ();
        NFFfree_passwd (&NFFglobal.current_form, user);
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
        NFFfree_passwd (&NFFglobal.current_form, user);
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
        NFFfree_passwd (&NFFglobal.current_form, user);
        NFFglobal.status = NFI_E_FORM;
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_set_text", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    _NFIdebug ((fname, "NFMRglobal.administrator <%d>  NFFglobal.user <%s>\n",
		NFMRglobal.administrator, NFFglobal.user));
    /***** Users Command ******/
    if (strcmp (command, NFI_M_CHANGE_PASSWD) == 0)
    {
	_NFIdebug((fname, "NFI_M_CHANGE_PASSWD  user_name <%s>\n", user_name));
        status = (long) UMSGetByNum
            (title, NFI_P_CHANGE_USER_PWD, "%s", user_name);
    }
    /***** Administrator/Users Commands *****/
    else if ((NFMRglobal.administrator == TRUE)  &&
           (strcmp (NFFglobal.user, "") != 0)) /* admin changing user pswd */
    {
	_NFIdebug ((fname, "Admin changing user passwd  NFFglobal.user <%s>\n",
			    NFFglobal.user));
        status = (long) UMSGetByNum
            (title, NFI_P_CHANGE_USER_PWD, "%s", NFFglobal.user);
    }
    else
    {
	_NFIdebug (( fname, "Default case  user_name <%s>\n", user_name ));
        status = (long) UMSGetByNum
            (title, NFI_P_CHANGE_USER_PWD, "%s", user_name);
    }

    if (status != UMS_S_SUCCESS)
     {
        _NFIdebug ((fname, "UMSGetByNum = <0x%.8x>\n", status));
        _NFIdebug ((fname, "defaulting title\n"));

        if (strcmp (command, NFI_M_CHANGE_PASSWD) == 0)
            sprintf (title, "for User \"%s\"", user_name);
        else if ((NFMRglobal.administrator == TRUE)  &&
           (strcmp (NFFglobal.user, "") != 0)) /* admin changing user pswd */
            sprintf (title, "for User \"%s\"", NFFglobal.user);
        else
            sprintf (title, "for User \"%s\"", user_name);
     }

    if ((status = (long) FIg_set_text
        (NFFglobal.current_form, TITLE2, title)) != FI_SUCCESS)
     {
        _NFIdebug ((fname, "FIg_set_text = <%d>\n", status));
        NFFfree_passwd (&NFFglobal.current_form, user);
        NFFglobal.status = NFI_E_FORM;
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_set_text", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
     }

    /* 04-11-91 The administrator can change any other users password
       without having to know the users old password but the administrator
       must specify his old password if he/she is changing his/her own
       password.                                                       */
/****** Users command **********/
    if (strcmp (command, NFI_M_CHANGE_PASSWD) == 0)
     {
        /*  Put the cursor in the old password field  */

        if ((status = (long) FIfld_pos_cursor (NFFglobal.current_form,
          OLD_PASSWORD_FIELD, 0, 0, 0, 0, 0, 0)) != FI_SUCCESS)
         {
            _NFIdebug ((fname, "FIfld_pos_cursor = <%d>\n", status));
            NFFfree_passwd (&NFFglobal.current_form, user);
            NFFglobal.status = NFI_E_FORM;
            ERRload_struct
                (NFI, NFI_E_FORM, "%s%d", "FIfld_pos_cursor", status);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_FORM);
         }
    }
/******** Administrator/Users Command ***********/
    else if ((NFMRglobal.administrator == TRUE)  &&
           (strcmp (NFFglobal.user, "") != 0)) /* admin changing user pswd */
     {
        /*  Erase the old password field */

        status = (long) FIg_erase (NFFglobal.current_form,  
				   OLD_PASSWORD_FIELD);
        if (status != FI_SUCCESS)
         {
           _NFIdebug ((fname, "FIg_disable = <%d>\n", status));
           NFFfree_passwd (&NFFglobal.current_form, user);
           NFFglobal.status = NFI_E_FORM;
           ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_disable",
                                   status);
           _NFIdebug ((fname, " returning FAILURE\n"));
           return (NFI_E_FORM);
         }

        status = (long) FIg_erase (NFFglobal.current_form,  
				   OLD_PWD_LABEL_FIELD);
        if (status != FI_SUCCESS)
         {
           _NFIdebug ((fname, "FIg_disable = <%d>\n", status));
           NFFfree_passwd (&NFFglobal.current_form, user);
           NFFglobal.status = NFI_E_FORM;
           ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_disable",
                                   status);
           _NFIdebug ((fname, " returning FAILURE\n"));
           return (NFI_E_FORM);
         }

        /*  Put the cursor in the new password field  */

        if ((status = (long) FIfld_pos_cursor (NFFglobal.current_form,
            NEW_PASSWORD_FIELD, 0, 0, 0, 0, 0, 0)) != FI_SUCCESS)
         {
            _NFIdebug ((fname, "FIfld_pos_cursor = <%d>\n", status));
            NFFfree_passwd (&NFFglobal.current_form, user);
            NFFglobal.status = NFI_E_FORM;
            ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_pos_cursor",
                            status);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_FORM);
         }
     }
    else
     {
        /*  Put the cursor in the old password field  */

        if ((status = (long) FIfld_pos_cursor (NFFglobal.current_form,
          OLD_PASSWORD_FIELD, 0, 0, 0, 0, 0, 0)) != FI_SUCCESS)
         {
            _NFIdebug ((fname, "FIfld_pos_cursor = <%d>\n", status));
            NFFfree_passwd (&NFFglobal.current_form, user);
            NFFglobal.status = NFI_E_FORM;
            ERRload_struct
                (NFI, NFI_E_FORM, "%s%d", "FIfld_pos_cursor", status);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_FORM);
         }
    }

    /*  Display the Password form  */

    if ((status = (long) FIf_display (NFFglobal.current_form)) != FI_SUCCESS)
     {
        _NFIdebug ((fname, "FIf_display = <%d>\n", status));
        NFFfree_passwd (&NFFglobal.current_form, user);
        NFFglobal.status = NFI_E_FORM;
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIf_display", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
     }

    /*  Start the sequencing of the password fields */

    if (strcmp (command, NFI_M_CHANGE_PASSWD) == 0)
        FIg_start_seq (NFFglobal.current_form, OLD_PASSWORD_FIELD);
    /***** Administrator/Users Commands *****/
    else if ((NFMRglobal.administrator == TRUE)  &&
           (strcmp (NFFglobal.user, "") != 0)) /* admin changing user pswd */
        FIg_start_seq (NFFglobal.current_form, NEW_PASSWORD_FIELD);
    else
        FIg_start_seq (NFFglobal.current_form, OLD_PASSWORD_FIELD);

    _NFIdebug ((fname, " returning SUCCESS\n"));
    return (NFI_S_SUCCESS);
  }


long _NFFchange_user_password_notify (g_label, form)
  int       g_label;
  Form      *form;
  {
    long    status = NFI_S_SUCCESS;

    NFFpasswd    user;

    static  char *command = NFI_M_CHANGE_PASSWD;
    static  char *fname = "_NFFchange_user_password_notify";

    _NFIdebug ((fname, "g_label = <%d>\n", g_label));

    FIf_get_user_pointer (*form, (char *) &user);

    NFFform_message (CURRENT_LABEL, NFI_S_CLEAR_MSG, NULL);

    switch (g_label)
      {
        case FI_HELP:

            if (status = _NFFhelp_topic (command))
              {
                _NFIdebug ((fname, "_NFFhelp_topic = <%d>\n", status));
                ERRload_struct (NFI, NFI_E_HELP, "%s%d", "_NFFhelp_topic", status);
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

            NFFfree_passwd (form, user);

            break;

        case FI_ACCEPT:

            if ((status = _NFFpasswd_validate_accept (user)) != NFI_S_SUCCESS)
                _NFIdebug ((fname,
                    "_NFFpasswd_validate_accept = <0x%.8x>\n", status));

            if (user->done == FALSE)
              {
                /*  Reset the accept button  */

                FIg_reset (*form, FI_ACCEPT);

                break;
              }

            /*  Put up a message  */

            NFFform_message (CURRENT_LABEL, NFI_I_CHANGE_USER_PASSWORD, NULL);

            /*  Call NFMR to change the user password  */

            _NFIdebug ((fname, "calling NFMRchange_user_passwd ...\n"));

            if (user->type) /* Change User Password */
               status = NFMRchange_user_passwd ((long) 0,
                   NFFglobal.user, user->old_password, user->new_password);
            else

/*  This causes the user's password to not be validated
    against the existing password in the server - Glenn 11/5/93

               status = NFMRchange_user_passwd ((long) 0,
                   NFFglobal.username, user->old_password, user->new_password);
*/
               /*  This will cause the server to change the
                   password for the user that is currently
                   logged in and validate it - Glenn 11/5/93  */

               status = NFMRchange_user_passwd ((long) 0,
                   "", user->old_password, user->new_password);

            _NFIdebug ((fname, "NFMRchange_user_passwd = <0x%.8x>\n", status));

            /*  Erase the message  */

            NFFerase_message ();

            /*  Save the return status  */

            NFFglobal.status = status;

            /*  Set the next state  */

            if ((status = NFFset_to_state ()) != NFI_S_SUCCESS)
                _NFIdebug ((fname, "NFFset_to_state = <0x%.8x>\n", status));

            /*  Free allocated memory and delete the form  */

            NFFfree_passwd (form, user);

            break;

        case OLD_PASSWORD_FIELD:
            status = _NFFold_passwd_field (*form, g_label, user);
            break;

        case NEW_PASSWORD_FIELD:
            status = _NFFnew_passwd_field (*form, g_label, user);
            break;

        case VERIFY_PASSWORD_FIELD:
            status = _NFFverify_passwd_field (*form, g_label, user);
            break;

	    
      }

    _NFIdebug ((fname, " returning <0x%.8x>\n", status));
    return (status);
  }







