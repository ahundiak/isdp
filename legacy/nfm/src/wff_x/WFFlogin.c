#include "machine.h"
#include "WFF.h"
#include "WFFlogin.h"
#include "WFFlist.h"

/*  Global WFF structure  */

extern struct WFFglobal_st WFFglobal;

char  WFG_DONT_CARE_STATE [41];
char  WFG_NO_CHANGE_STATE [41];

long WFFlogin ()
  {
   long   status;

   WFFlogin_ptr   login;

   static   char *fname = "WFFlogin";

   /*  Local functions  */

   long   _WFFlogin_form ();
   void   _WFFfree_login ();

   /*  External functions  */

   void _WFFnotify ();
   void _WFFmain_set_env ();
   void _WFFmain_set_username ();

   long MEMclose ();
   long MEMbuild_array ();
   long NFMls_nodes ();

   strcpy (WFG_DONT_CARE_STATE, "DONT CARE STATE");
   strcpy (WFG_NO_CHANGE_STATE, "NO CHANGE STATE");

   /*  Initialize the global error message number  */

   WFFglobal.error_no = NFI_S_CLEAR_MSG;

   /*  Initialize the login structure  */

   if ((login = (WFFlogin_ptr) malloc
      (sizeof (struct WFFlogin_st))) == NULL)
    {
      _NFIdebug ((fname,
         "malloc failed; size = <%d>\n", sizeof (struct WFFlogin_st)));
      ERRload_struct (NFI, NFI_E_MALLOC, "%d", sizeof (struct WFFlogin_st));
      _NFIdebug ((fname, " returning FAILURE\n"));
      return (NFI_E_MALLOC);
    }

   login->type = WFF_LOGIN_TYPE;
   login->done = FALSE;
   login->attempts = 0;
   login->attr_list = NULL;
   login->data_list = NULL;
   login->value_list = NULL;
   login->wf_list = NULL;

   _WFFmessage (NFI_I_RETRIEVE, NULL); 

   /* Get the list of environments */

   status =  NFMls_nodes ("nfme_", &(login->value_list));
   if (status != NFM_S_SUCCESS)
    {
       _WFFerase_message ();
       WFFglobal.cmd_status = status;
       _NFIdebug ((fname, "NFMls_nodes = <0x%.8x>\n", status));
       _WFFfree_login (login);
       return (status);
    }

   status = MEMbuild_array (login->value_list);
   if (status != MEM_S_SUCCESS)
    {
       _WFFerase_message ();
       _NFIdebug ((fname, "MEMbuild_array = <0x%.8x>\n", status));
       ERRload_struct (NFI, NFI_E_MEM, "%s%x", "MEMbuild_array");
       WFFglobal.cmd_status = NFI_E_MEM;
       _WFFfree_login (login);
       return (NFI_E_MEM);
    }

   _WFFerase_message ();

   /*  See if the login form needs to be brought up  */

   if (((strcmp (WFFglobal.username, "")) == 0) ||
      ((strcmp (WFFglobal.environment, "")) == 0))
    {
       /*  Bring up the login form  */

       if ((status = _WFFlogin_form (login)) != NFI_S_SUCCESS)
        {
           _NFIdebug ((fname, "_WFFlogin_form = <0x%.8x>\n", status));
           _WFFfree_login (login);
           return (status);
        }
    }
   else
    {
      /*  Try to log the user in directly without displaying a form  */

      if ((status = FIf_new (LOGIN_LABEL, LOGIN_FORM,
         _WFFnotify, &(WFFglobal.current_form))) != FI_SUCCESS)
       {
          _NFIdebug ((fname, "FIf_new = <%d>\n", status));
          ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIf_new", status);
          _NFIdebug ((fname, " returning FAILURE\n"));
          return (NFI_E_FORM);
       }

      if ((status = (long) FIf_set_user_pointer
         (WFFglobal.current_form, (char *) login)) != FI_SUCCESS)
       {
          _NFIdebug ((fname, "FIf_set_user_pointer = <%d>\n", status));
         ERRload_struct
            (NFI, NFI_E_FORM, "%s%d", "FIf_set_user_pointer", status);
         _NFIdebug ((fname, " returning FAILURE\n"));
         return (NFI_E_FORM);
       }

      _WFFnotify
         (LOGIN_LABEL, FI_ACCEPT, (double) 0, WFFglobal.current_form);
    }

   _NFIdebug ((fname, " returning SUCCESS\n"));
   return (NFI_S_SUCCESS);
  }


long _WFFlogin_form (login)
  WFFlogin_ptr   login;  /*  i - pointer to structure with buffers  */
  {
   int      status;

   static   char *fname = "_WFFlogin_form";

   /*  External functions  */

   void ERRreset_struct ();

   void _WFFnotify ();
   long _WFFcenter_form ();

   /*  Forms Interface functions  */

   int FIf_new ();
   int FIfld_set_text ();
   int FIfld_set_select ();
   int FIf_display ();
   int FI_process_forms ();
   int FIf_delete ();

   /*  Load the form into memory  */

   if ((status = FIf_new (LOGIN_LABEL, LOGIN_FORM,
      _WFFnotify, &(WFFglobal.current_form))) != FI_SUCCESS)
    {
      _NFIdebug ((fname, "FIf_new = <%d>\n", status));
      ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIf_new", status);
      _NFIdebug ((fname, " returning FAILURE\n"));
      return (NFI_E_FORM);
    }

   if ((status = _WFFcenter_form
      (WFFglobal.current_form, -1, Y_FORM_POS)) != NFI_S_SUCCESS)
    {
      _NFIdebug ((fname, "_WFFcenter_form = <0x%.8x>\n", status));
      _NFIdebug ((fname, " returning FAILURE\n"));
      return (status);
    }

   /*  Put the environment in the ENV_FIELD  */

   _NFIdebug ((fname, "Setting <%s> into ENV_FIELD\n", WFFglobal.environment));

   if ((status = FIfld_set_text (WFFglobal.current_form, ENV_FIELD,
      0, 0, WFFglobal.environment, FALSE)) != FI_SUCCESS)
    {
      _NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
      ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_text", status);
      _NFIdebug ((fname, " returning FAILURE\n"));
      return (NFI_E_FORM);
    }

   /*  Put the username from the command line in the USER_FIELD  */

   if ((status = FIfld_set_text (WFFglobal.current_form,

      USER_FIELD, 0, 0, WFFglobal.username, FALSE)) != FI_SUCCESS)
    {
      _NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
      ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_text", status);
      _NFIdebug ((fname, " returning FAILURE\n"));
      return (NFI_E_FORM);
    }

   /*  Store a pointer to the data in the form  */

   if ((status = (long) FIf_set_user_pointer
      (WFFglobal.current_form, (char *) login)) != FI_SUCCESS)
    {
      _NFIdebug ((fname, "FIf_set_user_pointer = <0x%.8x>\n", status));
      ERRload_struct
         (NFI, NFI_E_FORM, "%s%d", "FIf_set_user_pointer", status);
      _NFIdebug ((fname, " returning FAILURE\n"));
      return (NFI_E_FORM);
    }

   /*  Put the password from the command line in the PASSWD_FIELD  */

   if ((status = FIfld_set_text (WFFglobal.current_form,
      PASSWD_FIELD, 0, 0, WFFglobal.password, FALSE)) != FI_SUCCESS)
    {
      _NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
      ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_text", status);
      _NFIdebug ((fname, " returning FAILURE\n"));
      return (NFI_E_FORM);
    }

   /*  Put any previous error messages on the form  */

   if (WFFglobal.error_no == NFI_S_CLEAR_MSG)
      _WFFclear_msg (WFFglobal.current_form);
   else
      _WFFerror_message (WFFglobal.current_form);

   /*  Reset the error structure  */

   ERRreset_struct ();

   /*  Display the login form  */

   if ((status = FIf_display (WFFglobal.current_form)) != FI_SUCCESS)
    {
      _NFIdebug ((fname, "FIf_display = <%d>\n", status));
      ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIf_display", status);
      _NFIdebug ((fname, " returning FAILURE\n"));
      return (NFI_E_FORM);
    }

   if ((strcmp (WFFglobal.username, "")) == 0)
    {
      /*  Put the cursor at the beginning of the username field  */

      if ((status = FIfld_pos_cursor (WFFglobal.current_form,
         USER_FIELD, 0, 0, 0, 0, NULL, 0)) != FI_SUCCESS)
       {
         _NFIdebug ((fname, "FIfld_pos_cursor = <%d>\n", status));
         ERRload_struct
            (NFI, NFI_E_FORM, "%s%d", "FIfld_pos_cursor", status);
         _NFIdebug ((fname, " returning FAILURE\n"));
         return (NFI_E_FORM);
       }
    }

   if (WFFglobal.call_process_forms == TRUE)
    {
      if ((status = FI_process_forms ()) != FI_SUCCESS)
       {
         _NFIdebug ((fname, "FI_process_forms = <%d>\n", status));
         ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FI_process_forms", status);
         _NFIdebug ((fname, " returning FAILURE\n"));
         return (NFI_E_FORM);
       }
    }

   _NFIdebug ((fname, " returning SUCCESS\n"));
   return (NFI_S_SUCCESS);
  }


long _WFFlogin_notify (g_label, value, form)
  int      g_label;
  double   value;
  Form      form;
  {
   int      status = NFI_S_SUCCESS;
   int      select;
   int      loc, pos;
   int      position;
   int      is_displayed;
   char   env[256];

   WFFlogin_ptr   login;

   static   char *command = WFF_M_LOGIN_TO_ENVIRONMENT;
   static   char *fname = "_WFFlogin_notify";

   /*  Local functions  */

   long   _WFFlogin_validate_accept ();
   void   _WFFfree_login ();
   void   _WFFmain_set_env ();
   void   _WFFmain_set_username ();

   /*  External functions  */

   void _WFFexit ();

   _NFIdebug ((fname, "value = <%d>\n", value));

   /*  Clear out the error message field  */

   WFFglobal.cmd_status = NFM_S_SUCCESS;
   WFFglobal.error_no = NFI_S_CLEAR_MSG;
   _WFFclear_msg (form);

   /*  Pull the pointer out of the login form  */

   FIf_get_user_pointer (form, (char *) &login);

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
            ERRload_struct (NFI, NFI_E_HELP, "%s%d", "_WFFhelp_topic", status);
            status = NFI_E_HELP;
          }
#endif

         break;

      case FI_CANCEL:

         if (WFFglobal.main_form == NULL)
            _WFFexit (NFI_S_SUCCESS);

         strcpy (WFFglobal.username, "");
         strcpy (WFFglobal.password, "");
         strcpy (WFFglobal.environment, "");
         _WFFfree_login (login);

         if (WFFglobal.main_form != NULL)
          {
            FIg_enable (WFFglobal.main_form, FI_FORM_GROUP);
            _WFFprocess_event (REFRESH_EVENT);
          }

         break;

      case FI_ACCEPT:

         /*  Default password to same as username (per Durwood 8/7/90)  */

         if ((strcmp (WFFglobal.password, "")) == 0)
          {
            strncpy (WFFglobal.password,
               WFFglobal.username, sizeof (WFFglobal.password) - 1);
          }

         status = _WFFlogin_validate_accept (form, login);
         _NFIdebug ((fname,"login->done = <%d>\n", login->done));

         if (login->done == FALSE)
          {
            FIg_set_state_off (form, FI_ACCEPT);
            break;
          }

         /*  Attempt to log the user in  */

         sprintf (env, "nfme_%s", WFFglobal.environment);
         _NFIdebug ((fname, "environment = <%s>\n", env));
         _WFFmessage (NFI_I_LOGIN, "%s", WFFglobal.environment);

         _NFIdebug ((fname, "calling NFMlog_in ...\n"));
         status = NFMlog_in (WFFglobal.username, WFFglobal.password, env,
                             "NFM");
         if (status != NFM_S_SUCCESS)
          {
            /*  Login failed  */
            _NFIdebug ((fname, "NFMlog_in = <0x%.8x>\n", status));
            _WFFerase_message ();
            WFFglobal.cmd_status = status;
            WFFglobal.user_id = 0;
            WFFglobal.error_no = NFI_E_LOGIN_ENV;
            FIg_set_state_off (form, FI_ACCEPT);
          }
         else
          {
              /* Get the state names for states 0 and 1 */

              status = _WFGget_state_name ((long) 0, (long) 0,
                                          WFG_DONT_CARE_STATE);
              if (status != NFM_S_SUCCESS)
               {
                  _NFIdebug ((fname,"_WFGget_state_name = <0x%.8x>\n", status));
                  _NFIdebug ((fname, "Defaulting WFG_DONT_CARE_STATE name\n"));
                  strcpy (WFG_DONT_CARE_STATE, "DONT CARE STATE");
                  ERRload_struct (NFM, NFM_S_SUCCESS, NULL);
               }
              _NFIdebug ((fname," WFG_DONT_CARE_STATE = <%s>\n", 
                          WFG_DONT_CARE_STATE));

              status = _WFGget_state_name ((long) 0, (long) 1,
                                          WFG_NO_CHANGE_STATE);
              if (status != NFM_S_SUCCESS)
               {
                  _NFIdebug ((fname,"_WFGget_state_name = <0x%.8x>\n", status));
                  _NFIdebug ((fname, "Defaulting WFG_NO_CHANGE_STATE name\n"));
                  strcpy (WFG_NO_CHANGE_STATE, "DONT CARE STATE");
                  ERRload_struct (NFM, NFM_S_SUCCESS, NULL);
               }
              _NFIdebug ((fname," WFG_NO_CHANGE_STATE = <%s>\n", 
                          WFG_NO_CHANGE_STATE));
          }

         _NFIdebug ((fname, "returned from NFMlog_in\n"));

         _NFIdebug ((fname, "user_id = <%d>\n", WFFglobal.user_id));

         _WFFerase_message ();
         FIf_is_displayed (form, &is_displayed);
         if (is_displayed == 1)
            FIf_display (form);

         _NFIdebug ((fname, "increasing number of attempts counter\n"));
         ++(login->attempts);

         if (login->attempts == MAX_LOGIN_ATTEMPTS)
          {
            _NFIdebug ((fname,
               "maximum number of login attempts <%d> has been reached\n",
               login->attempts));

            strcpy (WFFglobal.username, "");
            strcpy (WFFglobal.password, "");
            strcpy (WFFglobal.environment, "");
            _WFFfree_login (login);

            /*  Enable the main form if it exists, otherwise exit  */

            if (WFFglobal.main_form != NULL)
             {
               FIg_enable (WFFglobal.main_form, FI_FORM_GROUP);
               _WFFprocess_event (REFRESH_EVENT);
             }
            else
             {
               fprintf (stderr, "Unable to login; try again later.\n");
               _WFFexit (WFFglobal.cmd_status);
             }

            break;
          }

         if ((WFFglobal.user_id >= 0) &&
             (WFFglobal.cmd_status == NFM_S_SUCCESS))
          {
            WFFglobal.cmd_status = NFI_S_SUCCESS;
            _NFIdebug ((fname, "login was successful\n"));

            /* Set the environment text on the main form */

            _WFFmain_set_env (WFFglobal.environment);
            _WFFmain_set_username (WFFglobal.username);
            _WFFfree_login (login);

            /*  Enable the main form, if it exists  */

            if (WFFglobal.main_form != NULL)
              {
               FIg_enable (WFFglobal.main_form, FI_FORM_GROUP);
               _WFFprocess_event (REFRESH_EVENT);
              }

            break;
          }

         /*  If this is the first login attempt,
             the login form may not be displayed  */

         if (is_displayed == 0)
          {
            _NFIdebug ((fname, "login failed; calling _WFFlogin_form\n"));
	    if (form != NULL)
                FIf_delete (form);
	    
            WFFglobal.current_form = NULL;
            _WFFlogin_form (login);
          }

         break;

      case USER_FIELD:

         /*  Get the username  */

         if ((status = FIfld_get_text (form,
            g_label, 0, 0, sizeof (WFFglobal.username) - 1,
            WFFglobal.username, &select, &position)) != FI_SUCCESS)
          {
            _NFIdebug ((fname, "FIfld_get_text = <%d>\n", status));
            ERRload_struct
               (NFI, NFI_E_FORM, "%s%d", "FIfld_get_text", status);
            status = NFI_E_FORM;
            break;
          }
         else
            status = NFI_S_SUCCESS;

         FIfld_get_active_char (form, g_label, 0, &loc, &pos);
         if (pos != 0)
          {
            /*  Bump the cursor into the password field  */

            FIfld_pos_cursor (form, PASSWD_FIELD, 0, 0, 0, 0, NULL, 0);
          }

         break;

      case PASSWD_FIELD:

         /*  Get the password  */

         if ((status = FIfld_get_text (form,
            g_label, 0, 0, sizeof (WFFglobal.password) - 1,
            WFFglobal.password, &select, &position)) != FI_SUCCESS)
          {
            _NFIdebug ((fname, "FIfld_get_text = <%d>\n", status));
            ERRload_struct
               (NFI, NFI_E_FORM, "%s%d", "FIfld_get_text", status);
            status = NFI_E_FORM;
            break;
          }
         else
            status = NFI_S_SUCCESS;

         FIfld_get_active_char (form, g_label, 0, &loc, &pos);
         if (pos != 0)
          {
            /*  Bump the cursor into the environment field  */

            FIfld_pos_cursor (form, ENV_FIELD, 0, 0, 0, 0, NULL, 0);
          }

         break;

      case ENV_FIELD:

         /*  Get the environment  */

         if ((status = FIfld_get_text (form,
            g_label, 0, 0, sizeof (WFFglobal.environment) - 1,
            WFFglobal.environment, &select, &position)) != FI_SUCCESS)
          {
            _NFIdebug ((fname, "FIfld_get_text = <%d>\n", status));
            ERRload_struct
               (NFI, NFI_E_FORM, "%s%d", "FIfld_get_text", status);
            status = NFI_E_FORM;
            break;
          }
         else
            status = NFI_S_SUCCESS;

         FIfld_get_active_char (form, g_label, 0, &loc, &pos);
         if (pos != 0)
          {
            /*  Bump the cursor into the username field  */

            FIfld_pos_cursor (form, USER_FIELD, 0, 0, 0, 0, NULL, 0);
          }

         break;

      case ENV_BUTTON:

         /*  Bring up a popup list with the valid environments  */

         if ((status = (long) _WFFenv_popup
            (login->value_list)) != NFI_S_SUCCESS)
            _NFIdebug ((fname, "_WFFenv_popup = <0x%.8x>\n", status));

         break;
     }

   _NFIdebug ((fname, " returning <0x%.8x>\n", status));
   return (status);
  }


long _WFFlogin_validate_accept (form, login)
  Form         form;
  WFFlogin_ptr   login;
  {
   static   char *fname = "_WFFlogin_validate_accept";

   form = form;

   /*  Assume that we are finished  */

   login->done = TRUE;

   /*  Verify that all fields have values  */

   if ((strcmp (WFFglobal.username, "")) == 0)
    {
      login->done = FALSE;
      ERRload_struct (NFI, NFI_E_USER, NULL);
      _NFIdebug ((fname, "returning FAILURE\n"););
      return (NFI_E_USER);
    }

   if ((strcmp (WFFglobal.environment, "")) == 0)
    {
      login->done = FALSE;
      ERRload_struct (NFI, NFI_E_ENV, NULL);
      _NFIdebug ((fname, "returning FAILURE\n"););
      return (NFI_E_ENV);
    }

   _NFIdebug ((fname, " returning SUCCESS\n"));
   return (NFI_S_SUCCESS);
  }


void _WFFfree_login (login)
  WFFlogin_ptr   login;
  {
        long  MEMclose ();

   if (WFFglobal.current_form != NULL)
    {
      FIf_delete (WFFglobal.current_form);
      WFFglobal.current_form = NULL;
    }

   if (login)
    {
       MEMclose (&(login->attr_list));
       MEMclose (&(login->data_list));
       MEMclose (&(login->value_list));
       MEMclose (&(login->wf_list));
       free (login);
    }

   return;
  }


long WFFlogout ()
  {
   long   status;

   static   char *fname = "WFFlogout";

   /*  External functions  */

   void _WFFmain_set_env ();
   void _WFFmain_set_username ();

   _WFFmessage (NFI_I_LOGOUT, NULL);

   _NFIdebug ((fname, "calling NFMlogoff ...\n"));
   if ((status = NFMlogoff ()) != NFM_S_SUCCESS)
    {
      _NFIdebug ((fname, "NFMlogoff = <0x%.8x>\n", status));
      _WFFerase_message ();
      _NFIdebug ((fname, "returning <0x%.8x>\n", status));
      return (status);
    }
   _NFIdebug ((fname, "returned from NFMlogoff\n"));

   _WFFerase_message ();

   /*  Clear out the appropriate fields  */

   WFFglobal.user_id = 0;
   strcpy (WFFglobal.username, "");
   strcpy (WFFglobal.password, "");
   strcpy (WFFglobal.environment, "");

   _WFFmain_set_wf ("");
   _WFFmain_set_user ("");

   /*  Clear out the environment and username text on the main form  */

   _WFFmain_set_env ("UNDEFINED");
   _WFFmain_set_username ("LOGGED OUT");

   /*  Wipe out the current listing on the main form  */

   _WFFmain_blank_listing (WFF_ALL_LISTS);

   _NFIdebug ((fname, "returning SUCCESS\n"));
   return (NFI_S_SUCCESS);
  }
