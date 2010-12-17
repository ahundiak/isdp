
/* machine.h included to take care of platform variencies MVR 23 Dec 1993 */
#include "machine.h"

#include "NFF.h"
#include "NFFlogin.h"
#include "NFFmain_form.h"

/*  Global NFF structure  */

extern struct NFFglobal_st NFFglobal;

long NFFlogin ()
  {
    auto   int    no_need = FALSE;
    auto   long   status;
    auto   char   s[256];
    static char   *fname = "NFFlogin";

    NFFglobal.status = NFI_S_SUCCESS;

    /*  See if there is enough info to avoid bringing up the form  */

    if ((strcmp (NFFglobal.username, "")) != 0)
      {
        no_need = TRUE;
        if ((strcmp (NFFglobal.environment, "")) != 0)
          {
            no_need = TRUE;

#ifndef COMBINED_CLIENT_SERVER
            if ((strcmp (NFFglobal.server, "")) != 0)
                no_need = TRUE;
            else
                no_need = FALSE;
#endif
          }
        else
          {
            /*  Need to select an environment  */

            no_need = FALSE;
          }
      }

    if (no_need == TRUE)
      {
        /*  Call the appropriate function directly  */

#ifndef COMBINED_CLIENT_SERVER
        sprintf (s, "nfms_%s", NFFglobal.server);
        _NFIdebug ((fname, "calling NFMRconnect ...\n"));
        if ((status = NFMRconnect (s)) != NFM_S_SUCCESS)
          {
            _NFIdebug ((fname, "NFMRconnect = <0x%.8x>\n", status));
            _NFIdebug ((fname, "returning <0x%.8x>\n", status));
            return (status);
          }
        _NFIdebug ((fname, "returned from NFMRconnect\n"));
#endif
        sprintf (s, "nfme_%s", NFFglobal.environment);
        _NFIdebug ((fname, "calling NFMRlog_in ...\n"));

        _NFIdebug ((fname, "username = <%s>\n", NFFglobal.username));
        _NFIdebug ((fname, "password = <%s>\n", "NOT PRINTED"));
        _NFIdebug ((fname, "environment = <%s>\n", s));

        if ((status = NFMRlog_in (NFFglobal.username,
            NFFglobal.password, s, "NFM")) != NFM_S_SUCCESS)
          {
            _NFIdebug ((fname, "NFMRlog_in = <0x%.8x>\n", status));
            _NFIdebug ((fname, "returning <0x%.8x>\n", status));
            return (status);
          }
        _NFIdebug ((fname, "returned from NFMRlog_in\n"));

        _NFIdebug ((fname, "returning SUCCESS <0x%.8x>\n", NFI_S_SUCCESS));
        return (NFI_S_SUCCESS);
      }

    /*  Bring up the form  */

    if ((status = NFFform_login ()) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "NFFform_login = <0x%.8x>\n", status));
        _NFIdebug ((fname, "returning <0x%.8x>\n", status));
        return (status);
      }
    
    _NFIdebug ((fname, "returning SUCCESS <0x%.8x>\n", NFI_S_SUCCESS));
    return (NFI_S_SUCCESS);
  }


long NFFform_login ()
  {
    auto   long   status;
    auto   char   s[256];
    auto   char   form_name[20];
    static char   *fname = "NFFform_login";

#ifdef COMBINED_CLIENT_SERVER
    strcpy (form_name, LOGIN_FORM);
#else
    strcpy (form_name, LOGIN_CLIENT_FORM);
#endif

    if ((status = FIf_new (LOGIN_LABEL, form_name,
        &_NFFnotify, &NFFglobal.current_form)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIf_new = <%d>\n", status));
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIf_new", status);
        _NFIdebug ((fname, "returning <0x%.8x>\n", NFI_E_FORM));
        return (NFI_E_FORM);
      }

    /*  Put the title on the form  */

    if ((status = (long) UMSGetByNum
        (s, NFT_P_LOGIN, NULL)) != UMS_S_SUCCESS)
      {
        _NFIdebug ((fname, "UMSGetByNum = <0x%.8x>\n", status));
        _NFIdebug ((fname, "defaulting title\n"));
        strcpy (s, "Log In to I/NFM");
      }

    FIg_set_text (NFFglobal.current_form, TITLE, s);

    /*  Put the text in the appropriate fields  */

#ifndef COMBINED_CLIENT_SERVER
#ifdef OS_SCO_UNIX
    FIg_set_font( NFFglobal.current_form, SERVER_FIELD, "7x13bold", 15 );
#endif
    FIfld_set_text (NFFglobal.current_form,
        SERVER_FIELD, 0, 0, NFFglobal.server, FALSE);
#endif

#ifdef OS_SCO_UNIX
    FIg_set_font( NFFglobal.current_form, USERNAME_FIELD, "7x13bold", 15 );
#endif
    FIfld_set_text (NFFglobal.current_form,
        USERNAME_FIELD, 0, 0, NFFglobal.username, FALSE);
#ifdef OS_SCO_UNIX
    FIg_set_font( NFFglobal.current_form, PASSWD_FIELD, "7x13bold", 15 );
#endif
    FIfld_set_text (NFFglobal.current_form,
        PASSWD_FIELD, 0, 0, NFFglobal.password, FALSE);
#ifdef OS_SCO_UNIX
    FIg_set_font( NFFglobal.current_form, ENV_FIELD, "7x13bold", 15 );
#endif
    FIfld_set_text (NFFglobal.current_form,
        ENV_FIELD, 0, 0, NFFglobal.environment, FALSE);

    /*  Display the form  */

    FIf_display (NFFglobal.current_form);

#ifndef COMBINED_CLIENT_SERVER
    FIg_start_seq (NFFglobal.current_form, SERVER_FIELD);
#else
    FIg_start_seq (NFFglobal.current_form, USERNAME_FIELD);
#endif

    _NFIdebug ((fname, "returning SUCCESS <0x%.8x>\n", NFI_S_SUCCESS));
    return (NFI_S_SUCCESS);
  }


long _NFFlogin_notify (g_label, form)
  int     g_label;
  Form    *form;
  {
    auto    int    sel, r_pos;
    auto    long   status = NFI_S_SUCCESS;
    auto    short  call_login = FALSE;
    auto    short  call_logout = TRUE;
    auto    char   s[40];
    static  short  login_failed = FALSE;
    void           NFFerase_active_data();
    static  char   *fname = "_NFFlogin_notify";

    /*  This may be the initial login from the command line  */

    if (NFFglobal.forms[MAIN_LABEL] == NULL)
      {
        call_login = TRUE;
        call_logout = FALSE;
      }

    NFFglobal.status = NFI_S_SUCCESS;

    _NFIdebug ((fname, "g_label = <%d>\n", g_label));

    switch (g_label)
      {
/* added case statements for FI_HELP button - PS */
        case FI_HELP:
              _NFIdebug ((fname, "_NFFhelp_topic = <%d>\n", -1));
              ERRload_struct (NFI, NFI_E_HELP, "%s%d", "_NFFhelp_topic", -1);
              status = NFI_E_HELP;
              break;
 
        case SERVER_BUTTON:
            NFFserver_popup ();
            break;

        case ENV_BUTTON:
            NFFenv_popup ();
            break;

        case FI_CANCEL:
            FIf_delete (*form);
            NFFglobal.current_form = *form = NULL;
            NFFglobal.status = NFI_W_COMMAND_CANCELLED;
            status = NFI_S_SUCCESS;
            ERRload_struct (NFI, NFFglobal.status, NULL);
            login_failed = FALSE;
            break;

        case FI_ACCEPT:
#ifndef COMBINED_CLIENT_SERVER

            /*  Are we connected to the server?  */

            if (NFMRglobal.NETid == -1)
              {
                FIfld_get_text (*form,
                    SERVER_FIELD, 0, 0, sizeof (s), s, &sel, &r_pos);
                if ((strcmp (s, "")) == 0)
                  {
                    /*  User needs to choose a server  */

                    status = NFI_E_SERVER;
                    ERRload_struct (NFI, status, NULL);
                    break;
                  }

                /*  We need to connect to the server  */

                NFFform_message (CURRENT_LABEL, NFI_I_CONNECT, "%s", s);

                strcpy (NFFglobal.server, s);
                sprintf (s, "nfms_%s", NFFglobal.server);

                _NFIdebug ((fname, "calling NFMRconnect ...\n"));
                if ((status = NFMRconnect (s)) != NFM_S_SUCCESS)
                  {
                    _NFIdebug ((fname, "NFMRconnect = <0x%.8x>\n", status));
                    NFFerase_message ();
                    NFFglobal.status = status;
                    FIg_reset (*form, g_label);
                    break;
                  }
                _NFIdebug ((fname, "returned from NFMRconnect\n"));

                NFFerase_message ();

                /*  No need to logout below  */

                call_logout = FALSE;
              }
            else
              {
                /*  We ARE connected to the server -
                    see if we need to connect to a different server  */

                FIfld_get_text (*form,
                    SERVER_FIELD, 0, 0, sizeof (s), s, &sel, &r_pos);
                if ((strcmp (s, NFFglobal.server)) != 0)
                  {
                    /*  Logout first  */

                    NFFform_message (CURRENT_LABEL, NFI_I_LOGOUT, NULL);
                    _NFIdebug ((fname, "calling NFMRlogout ...\n"));
                    NFMRlogout ((long) 0);
                    NFFerase_message ();

                    /*  No need to logout below  */

                    call_logout = FALSE;

                    /*  Disconnect from current server  */

                    NFFform_message (CURRENT_LABEL, NFI_I_DISCONNECT, NULL);
                    _NFIdebug ((fname, "calling NFMRterminate ...\n"));
                    NFMRterminate ();
                    NFFerase_message ();

                    /*  Connect to the new server  */

                    NFFform_message (CURRENT_LABEL, NFI_I_CONNECT, "%s", s);

                    strcpy (NFFglobal.server, s);
                    sprintf (s, "nfms_%s", NFFglobal.server);

                    _NFIdebug ((fname, "calling NFMRconnect ...\n"));
                    if ((status = NFMRconnect (s)) != NFM_S_SUCCESS)
                      {
                        _NFIdebug ((fname,
                            "NFMRconnect = <0x%.8x>\n", status));
                        NFFerase_message ();
                        NFFglobal.status = status;
                        FIg_reset (*form, g_label);
                        break;
                      }
                    _NFIdebug ((fname, "returned from NFMRconnect\n"));

                    NFFerase_message ();
                  }
              }
#endif
            /*  See if login needs to be called  */

            FIfld_get_text (*form,
                USERNAME_FIELD, 0, 0, sizeof (s), s, &sel, &r_pos);
            if ((strcmp (s, NFFglobal.username)) != 0)
                call_login = TRUE;
            strcpy (NFFglobal.username, s);

            FIfld_get_text (*form,
                PASSWD_FIELD, 0, 0, sizeof (s), s, &sel, &r_pos);
            if ((strcmp (s, NFFglobal.password)) != 0)
                call_login = TRUE;
            strcpy (NFFglobal.password, s);

            FIfld_get_text (*form,
                ENV_FIELD, 0, 0, sizeof (s), s, &sel, &r_pos);
            if ((strcmp (s, NFFglobal.environment)) != 0)
                call_login = TRUE;
            strcpy (NFFglobal.environment, s);

            if ((status = _NFFvalidate_login_accept ()) != NFI_S_SUCCESS)
              {
                /*  Pop the button back up  */

                FIg_reset (*form, g_label);
                break;
              }

            _NFIdebug ((fname, "call_login = <%d>\n", call_login));
            _NFIdebug ((fname, "call_logout = <%d>\n", call_logout));
            _NFIdebug ((fname, "login_failed = <%d>\n", login_failed));

            if ((call_login == TRUE) || (login_failed == TRUE))
              {
                if ((call_logout == TRUE) && (login_failed == FALSE))
                  {
                    /*  Logout first  */

                    NFFform_message (CURRENT_LABEL, NFI_I_LOGOUT, NULL);
                    NFMRlogout ((long) 0);
                    NFFerase_message ();
                  }

                NFFform_message (CURRENT_LABEL,
                    NFI_I_LOGIN, "%s", NFFglobal.environment);

                sprintf (s, "nfme_%s", NFFglobal.environment);
                _NFIdebug ((fname, "calling NFMRlog_in ...\n"));

                _NFIdebug ((fname, "username = <%s>\n", NFFglobal.username));
                _NFIdebug ((fname, "password = <%s>\n", "NOT PRINTED"));
                _NFIdebug ((fname, "environment = <%s>\n", s));

                if ((status = NFMRlog_in (NFFglobal.username,
                    NFFglobal.password, s, "NFM")) != NFM_S_SUCCESS)
                  {
                    _NFIdebug ((fname, "NFMRlog_in = <0x%.8x>\n", status));
                    NFFerase_message ();
                    NFFglobal.status = status;
                    login_failed = TRUE;
                    FIg_reset (*form, g_label);
                    break;
                  }
                _NFIdebug ((fname, "returned from NFMRlog_in\n"));

                NFFerase_message ();
		
		NFFerase_active_data ();

                /*  Get the administrator info (if this is indeed
                    the first time, post_login will be called from
                    main, but this will insure that administrator
                    info is returned if this is not the first time)  */

                NFFpost_login (FALSE);

                login_failed = FALSE;
              }

/*the if condition line added on 17.1.94 by KMM */
            if (*form != NULL)
              FIf_delete (*form);

            NFFglobal.current_form = *form = NULL;
            status = NFI_S_SUCCESS;
            break;
      }

    _NFIdebug ((fname, "returning <0x%.8x> ...\n", status));
    return (status);
  }


void NFFpost_login (first_time_flag)
  int   first_time_flag;
  {
    auto    long    status;
    auto    char    nodename[NFM_NODENAME + 1];
    auto    char    username[NFM_USERNAME + 1];
    auto    char    pathname[NFM_PATHNAME + 1];
    auto    char    saname[NFM_SANAME + 1];
    auto    MEMptr  node_info = NULL;
    auto    MEMptr  sa_info = NULL;
    static  char    *fname = "NFFpost_login";

    _NFIdebug ((fname,
        "Entering with first_time_flag <%d>\n", first_time_flag));

    /*  Get the user's default data  */

    if (first_time_flag == TRUE)
      {
        if ((status = NFFread_user_defaults ()) != NFI_S_SUCCESS)
          {
            _NFIdebug ((fname, "NFFread_user_defaults = <0x%.8x>\n", status));
          }
      }
    else
      {
        /*  Clear out working_area name since read_user_defaults is 
         *  not called and working area is specific to the current user.
         */

        if (NFFglobal.forms[MAIN_LABEL] != NULL)
          {
#ifdef OS_SCO_UNIX
            /* work around change added 1 line to set font SSRS 1 Feb 94 */
            FIg_set_font( NFFglobal.forms[MAIN_LABEL], WA_FIELD, "7x13bold", 15 );
#endif
            FIfld_set_text (NFFglobal.forms[MAIN_LABEL], WA_FIELD, 0, 0, "", 
			FALSE);
            strcpy( NFFglobal.working_area, "" );
          }
      }

    NFFform_message (MAIN_LABEL, NFI_I_RETRIEVE, NULL);

    /*  Create/get the user's default working area  */

    if (first_time_flag == TRUE)
      {
        if ((status = _NFMget_wa_system_info (nodename,
            username, pathname, &node_info, &sa_info)) != NFM_S_SUCCESS)
          {
            _NFIdebug ((fname, "_NFMget_wa_system_info = <0x%.8x>\n", status));
            MEMclose (&node_info);
            MEMclose (&sa_info);
          }
        else
          {
            if (_NFMdebug_st.NFIdebug_on)
              {
                MEMprint_buffer (fname, node_info, _NFMdebug_st.NFIdebug_file);
                MEMprint_buffer (fname, sa_info, _NFMdebug_st.NFIdebug_file);
              }

            if ((status = NFMRadd_default_working_area (nodename, username,
                pathname, saname, node_info, sa_info)) != NFM_S_SUCCESS)
              {
                _NFIdebug ((fname,
                    "NFMRadd_default_working_area = <0x%.8x>\n", status));
              }
            else
              {
                /*  Use the default working area  */

                _NFIdebug ((fname, "default working area = <%s>\n", saname));

#ifdef OS_SCO_UNIX
                /* work around change added 1 line to set font SSRS 1 Feb 94 */
                FIg_set_font( NFFglobal.forms[MAIN_LABEL], WA_FIELD, "7x13bold", 15 );
#endif
                FIfld_set_text (NFFglobal.forms[MAIN_LABEL],
                    WA_FIELD, 0, 0, saname, FALSE);
                strcpy (NFFglobal.working_area, saname);
              }

            MEMclose (&node_info);
            MEMclose (&sa_info);
          }
      }

    /*  Get the administrator information  */

#ifdef COMBINED_CLIENT_SERVER
    if ((status = (long) NFMload_user_info ("nfmadmin")) != NFM_S_SUCCESS)
      {
        _NFIdebug ((fname, "NFMload_user_info = <0x%.8x>\n", status));
      }
#else
    if ((status = NFMRget_host_info ((long) 0, 1)) != NFM_S_SUCCESS)
      {
        _NFIdebug ((fname, "NFMRget_host_info = <0x%.8x>\n", status));
      }
#endif

    NFFerase_message ();

    _NFIdebug ((fname,
        "NFMRglobal.administrator = <%d>\n", NFMRglobal.administrator));

    _NFIdebug ((fname, "returning ...\n"));
    return;
  }


long NFFlogout ()
  {
    auto    long    status;
    static  char    *fname = "NFFlogout";

#ifndef COMBINED_CLIENT_SERVER
    if (NFMRglobal.NETid == -1)
      {
        /*  We're not connected  */

        _NFIdebug ((fname, "not connected to I/NFM server\n"));
        _NFIdebug ((fname, "returning SUCCESS <0x%.8x> ...\n", NFI_S_SUCCESS));
        return (NFI_S_SUCCESS);
      }
#endif

    /*  Send active data to database  */

    if ((status = NFFwrite_user_defaults ()) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "NFFwrite_user_defaults = <0x%.8x>\n", status));
        _NFIdebug ((fname, "returning <0x%.8x> ...\n", status));

/*  Jill - August 27, 1992 - this 'return(status)' was causing
    a lot of problems in that the 'NFMRlogout' routine at the bottom
    of this routine was not being called. I don't think we really
    care at this point if NFFwrite_user_defaults was successful.
	 
    return (status);
 */
      }

#ifndef COMBINED_CLIENT_SERVER
    if ((status = NFMRget_host_info ((long) 0, 0)) != NFM_S_SUCCESS)
      {
        _NFIdebug ((fname, "NFMRget_host_info = <0x%.8x>\n", status));
      }
#endif

    /*  Cleanup the block listings, if necessary  */

    if (NFMRglobal.query_rows > 0)
      {
        if (NFFglobal.forms[ITEMS_LABEL] != NULL)
          {
            _NFFend_block_listing (ITEMS_LABEL, TRUE);
            NFFerror_message (NFFglobal.forms[ITEMS_LABEL]);
          }

        if (NFFglobal.forms[PROJM_LABEL] != NULL)
          {
            _NFFend_block_listing (PROJM_LABEL, TRUE);
            NFFerror_message (NFFglobal.forms[PROJM_LABEL]);
          }

        if (NFFglobal.forms[SETM_LABEL] != NULL)
          {
            _NFFend_block_listing (SETM_LABEL, TRUE);
            NFFerror_message (NFFglobal.forms[SETM_LABEL]);
          }
      }

    NFMRlogout ((long) 0);

#ifndef COMBINED_CLIENT_SERVER
    _NFIdebug ((fname, "calling NFMRterminate ...\n"));
    NFMRterminate ();
#endif

    _NFIdebug ((fname, "returning SUCCESS <0x%.8x> ...\n", NFI_S_SUCCESS));
    return (NFI_S_SUCCESS);
  }


void NFFerase_active_data ()
  {
    static  char   *fname = "NFFerase_active_data";

    _NFIdebug ((fname, "entering ...\n"));

    if( NFFglobal.forms[MAIN_LABEL] != NULL )
      {
        FIfld_set_text (NFFglobal.forms[MAIN_LABEL], PROJECT_FIELD, 0, 0,
			"", FALSE);
        strcpy( NFFglobal.project, "" );

        FIfld_set_text (NFFglobal.forms[MAIN_LABEL], CATALOG_FIELD, 0, 0,
			"", FALSE);
        strcpy( NFFglobal.catalog, "" );

        FIfld_set_text (NFFglobal.forms[MAIN_LABEL], ITEM_FIELD, 0, 0,
			"", FALSE);
        strcpy( NFFglobal.item, "" );

        FIfld_set_text (NFFglobal.forms[MAIN_LABEL], REVISION_FIELD, 0, 0,
			"", FALSE);
        strcpy( NFFglobal.revision, "" );

        FIfld_set_text (NFFglobal.forms[MAIN_LABEL], SEARCH_FIELD, 0, 0,
			"", FALSE);
        strcpy( NFFglobal.search, "" );

        FIfld_set_text (NFFglobal.forms[MAIN_LABEL], SORT_FIELD, 0, 0,
			"", FALSE);
        strcpy( NFFglobal.sort, "" );

        FIfld_set_text (NFFglobal.forms[MAIN_LABEL], WA_FIELD, 0, 0,"", FALSE);
        strcpy( NFFglobal.working_area, "" );

        FIfld_set_text (NFFglobal.forms[MAIN_LABEL], SA_FIELD, 0, 0,"", FALSE);
        strcpy( NFFglobal.storage_area, "" );

        FIfld_set_text (NFFglobal.forms[MAIN_LABEL], NODE_FIELD, 0, 0,
			"", FALSE);
        strcpy( NFFglobal.node, "" );

        FIfld_set_text (NFFglobal.forms[MAIN_LABEL], USER_FIELD, 0, 0,
			"", FALSE);
        strcpy( NFFglobal.user, "" );

        FIfld_set_text (NFFglobal.forms[MAIN_LABEL], WF_FIELD, 0, 0,"", FALSE);
        strcpy( NFFglobal.workflow, "" );

        FIfld_set_text (NFFglobal.forms[MAIN_LABEL], ACL_FIELD, 0, 0,
			"", FALSE);
        strcpy( NFFglobal.acl, "" );
      }
    else
      {
        _NFIdebug(( fname, "Persistent form was not up\n" ));
      }

    _NFIdebug ((fname, "returning SUCCESS <0x%.8x> ...\n", NFI_S_SUCCESS));
  }

long _NFFvalidate_login_accept ()
  {
    static  char   *fname = "_NFFvalidate_login_accept";

    _NFIdebug ((fname, "entering ...\n"));

    /*  Make sure the user has entered enough data  */

#ifndef COMBINED_CLIENT_SERVER
    if ((strcmp (NFFglobal.server, "")) == 0)
      {
        ERRload_struct (NFI, NFI_E_SERVER, NULL);
        _NFIdebug ((fname, "returning <0x%.8x> ...\n", NFI_E_SERVER));
        return (NFI_E_SERVER);
      }
#endif

    if ((strcmp (NFFglobal.username, "")) == 0)
      {
        ERRload_struct (NFI, NFI_E_USER, NULL);
        _NFIdebug ((fname, "returning <0x%.8x> ...\n", NFI_E_USER));
        return (NFI_E_USER);
      }

    if ((strcmp (NFFglobal.environment, "")) == 0)
      {
        ERRload_struct (NFI, NFI_E_ENV, NULL);
        _NFIdebug ((fname, "returning <0x%.8x> ...\n", NFI_E_ENV));
        return (NFI_E_ENV);
      }

    _NFIdebug ((fname, "returning SUCCESS <0x%.8x> ...\n", NFI_S_SUCCESS));
    return (NFI_S_SUCCESS);
  }
